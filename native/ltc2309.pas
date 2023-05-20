unit ltc2309;

interface

uses
  SysUtils, i2c;

type
  TLTC2309 = class
  private
    fi2c: TI2cMaster;
    fI2Caddress: byte;
  public
    // I2C address should be 7-bit address
    function Initialize(Ai2c: TI2cMaster; I2Caddress: byte = $30): boolean;
    // Reset to power up state
    function reset: boolean;
    // This mimicks the rpiplc analog read settings.
    // TODO: For general use expose config register and a general read method
    function readChannel(const address: byte; index: byte): uint16;
  end;

const
  // The LTC2309 only has one register for configuration.
  // This register should be written to right after transmitting the device address,
  // no register number should be written.
  modeSingleEnded         = 1 shl 7;
  //modeOdd                 = 1 shl 6;
  modeUnipolar            = 1 shl 3;
  modeSleep               = 1 shl 2;

  // Channel encoding, contains the bits O/S, S1, S0
  chan0                   = 0 shl 4;
  chan1                   = 4 shl 4;
  chan2                   = 1 shl 4;
  chan3                   = 5 shl 4;
  chan4                   = 2 shl 4;
  chan5                   = 6 shl 4;
  chan6                   = 3 shl 4;
  chan7                   = 7 shl 4;

implementation

function TLTC2309.Initialize(Ai2c: TI2cMaster; I2Caddress: byte): boolean;
begin
  fi2c := Ai2c;
  fI2Caddress := I2Caddress;
  Result := true;
end;

function TLTC2309.reset: boolean;
var
  b: byte;
begin
  b := 0;
  Result := fi2c.WriteBytes(fI2Caddress, @b, 1);
end;

function TLTC2309.readChannel(const address: byte; index: byte): uint16;
const
  data: array[0..7] of byte = (
    modeSingleEnded or chan0 or modeUnipolar,
    modeSingleEnded or chan1 or modeUnipolar,
    modeSingleEnded or chan2 or modeUnipolar,
    modeSingleEnded or chan3 or modeUnipolar,
    modeSingleEnded or chan4 or modeUnipolar,
    modeSingleEnded or chan5 or modeUnipolar,
    modeSingleEnded or chan6 or modeUnipolar,
    modeSingleEnded or chan7 or modeUnipolar);
var
  b: byte;
  buf: array[0..1] of byte;
begin
  b := data[index];

  Result := 0;
  if fi2c.WriteBytes(address, @b, 1) then
  begin
    // Wait for conversion to complete - could also poll Status bit of configuration register
    Sleep(1);
    // b is config, not register address, but this follows fig 10 - Write, read, start conversion
    // TODO: confirm that repeated start bit is not required
    if fi2c.ReadBytesFromReg(address, b, @buf[0], length(buf)) then
    begin
      // Convert from right adjusted 12 bit value
      Result := ((buf[0] shl 8) or buf[1]) shr 4;

      // Limit negative values to 0 - not required for single ended conversion
      //if Result > $07ff then
      //  Result := 0;
    end;
  end
  else
    Result := $FFFF;
end;

end.

