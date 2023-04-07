unit ads1015;

interface

uses
  SysUtils, i2c;

type
  TADS101x = class
  private
    fi2c: TI2cMaster;
    fI2Caddress: byte;
  public
    // I2C address should be 7-bit address
    function Initialize(Ai2c: TI2cMaster; I2Caddress: byte = $50): boolean;
    // Reset to power up state
    function reset: boolean;
    // This mimicks the rpiplc analog read settings.
    // TODO: For general use expose config register
    function readChannel(const address: byte; index: byte): int16;
  end;

const
  // Register addresses
  ConversionReg = 0;
  ConfigReg     = 1;
  LoThreshReg   = 2;
  HiThresReg    = 3;

  // Config register bit fields - 16 bit register.
  // Positions below refer to bit number of hi/lo byte respectively
  // Operational status or single shot conversion start
  ConfigOS_pos_h          = 7;
  ConfigOSStartConversion = 1 shl ConfigOS_pos_h;
  // Input multiplexer (ADS1015 only)
  ConfigMUX_pos_h         = 4;
  // Differential measurements
  ConfigMUX_AIn_0_1       = 0 shl ConfigMUX_pos_h;
  ConfigMUX_AIn_0_3       = 1 shl ConfigMUX_pos_h;
  ConfigMUX_AIn_1_3       = 2 shl ConfigMUX_pos_h;
  ConfigMUX_AIn_2_3       = 3 shl ConfigMUX_pos_h;
  // Single ended measurements
  ConfigMUX_AIn_0_Gnd     = 4 shl ConfigMUX_pos_h;
  ConfigMUX_AIn_1_Gnd     = 5 shl ConfigMUX_pos_h;
  ConfigMUX_AIn_2_Gnd     = 6 shl ConfigMUX_pos_h;
  ConfigMUX_AIn_3_Gnd     = 7 shl ConfigMUX_pos_h;
  // Programmable gain amplifier - full scale range [mV]
  ConfigPGA_pos_h         = 1;
  ConfigPGA_FSR_6144      = 0 shl ConfigPGA_pos_h;
  ConfigPGA_FSR_4096      = 1 shl ConfigPGA_pos_h;
  ConfigPGA_FSR_2048      = 2 shl ConfigPGA_pos_h;
  ConfigPGA_FSR_1024      = 3 shl ConfigPGA_pos_h;
  ConfigPGA_FSR_0512      = 4 shl ConfigPGA_pos_h;
  ConfigPGA_FSR_0256      = 5 shl ConfigPGA_pos_h;  // 6, 7 also means 256 mV range
  // Mode
  ConfigMode_pos_h        = 0;
  ConfigModeContinuous    = 0 shl ConfigMode_pos_h;
  ConfigModeSingleShot    = 1 shl ConfigMode_pos_h;
  // Data rate in samples per second
  ConfigDataRate_pos_l    = 5;
  ConfigDataRate128       = 0 shl ConfigDataRate_pos_l;
  ConfigDataRate250       = 1 shl ConfigDataRate_pos_l;
  ConfigDataRate490       = 2 shl ConfigDataRate_pos_l;
  ConfigDataRate920       = 3 shl ConfigDataRate_pos_l;
  ConfigDataRate1600      = 4 shl ConfigDataRate_pos_l;
  ConfigDataRate2400      = 5 shl ConfigDataRate_pos_l;
  ConfigDataRate3300      = 6 shl ConfigDataRate_pos_l;  // 7 also means 3300 SPS
  // Comparator mode
  ConfigCompMode_pos_l    = 4;
  ConfigCompModeStandard  = 0 shl ConfigCompMode_pos_l;
  ConfigCompModeWindow    = 1 shl ConfigCompMode_pos_l;
  // Comparator polarity (active level)
  ConfigCompPol_pos_l        = 3;
  ConfigCompPolLow           = 0 shl ConfigCompPol_pos_l;
  ConfigCompPolHigh          = 1 shl ConfigCompPol_pos_l;
  // Comparator latching
  ConfigCompLatch_pos_l   = 2;
  ConfigCompLatchOff      = 0 shl ConfigCompLatch_pos_l;
  ConfigCompLatchOn       = 1 shl ConfigCompLatch_pos_l;
  // Comparator queue, number of samples or disable
  ConfigCompQue_pos_l     = 0;
  ConfigCompQue1          = 0 shl ConfigCompQue_pos_l;
  ConfigCompQue2          = 1 shl ConfigCompQue_pos_l;
  ConfigCompQue4          = 2 shl ConfigCompQue_pos_l;
  ConfigCompQueOff        = 3 shl ConfigCompQue_pos_l;  // Disable comparator and set ALERT/READY pin to high impedance

implementation

const
  errMsg = 'Error calling ';

function TADS101x.Initialize(Ai2c: TI2cMaster; I2Caddress: byte): boolean;
begin
  fi2c := Ai2c;
  fI2Caddress := I2Caddress;
  Result := true;
end;

function TADS101x.reset: boolean;
const
  configResetStateHi = %10000101; // Start single shot mode, FSR = 2.048V, Single shot mode or power down
  configResetStateLo = %10000011; // 128 SPS, Disable comparator
var
  buf: array[0..1] of byte;
begin
  buf[0] := configResetStateHi;
  buf[1] := configResetStateLo;
  Result := fi2c.WriteBytesToReg(fI2Caddress, byte(ConfigReg), @buf[0], length(buf));
  if not Result then
    WriteLn(errMsg, 'WriteBytesToReg');
end;

function TADS101x.readChannel(const address: byte; index: byte): int16;
const
  muxSingleEnded: array[0..3] of byte = (
    ConfigMUX_AIn_0_Gnd,
    ConfigMUX_AIn_1_Gnd,
    ConfigMUX_AIn_2_Gnd,
    ConfigMUX_AIn_3_Gnd);
var
  buf: array[0..1] of byte;
begin
  buf[0] := ConfigModeSingleShot or ConfigPGA_FSR_4096 or
            ConfigOSStartConversion or muxSingleEnded[index];
  buf[1] := ConfigCompQueOff or ConfigCompLatchOff or ConfigCompPolLow or
            ConfigCompModeStandard or ConfigDataRate1600;

  Result := -1;
  if fi2c.WriteBytesToReg(address, byte(ConfigReg), @buf[0], length(buf)) then
  begin
    // Wait for conversion to complete - could also poll Status bit of configuration register
    Sleep(1);
    if fi2c.ReadBytesFromReg(address, byte(ConversionReg), @buf[0], length(buf)) then
    begin
      // Convert from right adjusted 12 bit value
      Result := ((buf[0] shl 8) or buf[1]);
      // Limit negative values to 0
      //if Result > $07ff then
      //  Result := 0;
    end
    else
      WriteLn(errMsg, 'ReadBytesFromReg');
  end
  else
    WriteLn(errMsg, 'WriteBytesToReg');
end;

end.

