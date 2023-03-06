unit mcp23008;

interface

uses
  SysUtils, i2c;

type
  TMCP23008 = class
  private
    fi2cMaster: TI2cMaster;
    fI2Caddress: byte;
  public
    // I2C address should be 7-bit address
    function Initialize(Ai2c: TI2cMaster; I2Caddress: byte = $40): boolean;
    function readPin(address: byte; pinIndex: byte; out value: byte): boolean;
    function writePin(address: byte; pinIndex: byte; value: byte): boolean;
    function readAllPins(address: byte; out values: byte): boolean;
    function writeAllPins(address: byte; const values: byte): boolean;
  end;

implementation

const
  // Register addresses
  IODIRreg   = $00;   // I/O direction register
  IPOLreg    = $01;   // Input polarity register
  GPINTENreg = $02;   // Interrupt on change register
  DEFVALreg  = $03;   // Default compare register for interrupt on change
  INTCONreg  = $04;   // Interrupt control register
  IOCONreg   = $05;   // Configuration register
  GPPUreg    = $06;   // Pullup register configuration register
  INTFreg    = $07;   // Interrupt flag register
  INTCAPreg  = $08;   // Interrupt capture register
  GPIOreg    = $09;   // Port register
  OLATreg    = $0a;   // Output latch register

  // Configuration register bits
  SEQOP            = $20;   // Sequential operationmode
  DISSLW           = $10;   // Disable slew rate control
  HAEN             = $08;   // Hardware address enable (MCP23S08 only, always active for MCP23008)
  ODR              = $04;   // Open drain output
  INTPOL           = $02;   // Polarity of the INT output pin

function TMCP23008.Initialize(Ai2c: TI2cMaster; I2Caddress: byte): boolean;
var
  iocon, gppu: byte;
begin
  fi2cMaster := Ai2c;
  fI2Caddress := I2Caddress;

  fi2cMaster.ReadByteFromReg(fI2Caddress, byte(IOCONreg), iocon);
  fi2cMaster.ReadByteFromReg(fI2Caddress, byte(GPPUreg), gppu);

  Result := (iocon = (SEQOP and ODR)) and (gppu = 0);
  if not Result then
  begin
    if not fi2cMaster.WriteByteToReg(fI2Caddress, byte(IODIRreg), $FF) then
      exit(false);

    if not fi2cMaster.WriteByteToReg(fI2Caddress, byte(IOCONreg), (SEQOP or ODR)) then
      exit(false);

    Result := fi2cMaster.WriteByteToReg(fI2Caddress, byte(GPPUreg), 0)
  end;
end;

function TMCP23008.readPin(address: byte; pinIndex: byte; out
  value: byte): boolean;
begin
  Result := fi2cMaster.ReadByteFromReg(address, byte(GPIOreg), value);
  if Result then
    value := (value shr pinIndex) and 1
  else
    value := $FF;
end;

function TMCP23008.writePin(address: byte; pinIndex: byte;
  value: byte): boolean;
var
  gpio_reg: byte;
begin
  Result := fi2cMaster.ReadByteFromReg(address, byte(GPIOreg), gpio_reg);
  if not Result then exit;

  if value = 0 then
    gpio_reg := gpio_reg and ($FF - byte(1 shl pinIndex))
  else
    gpio_reg:= gpio_reg or byte(1 shl pinIndex);

  Result := fi2cMaster.WriteByteToReg(address, byte(GPIOreg), gpio_reg);
end;

function TMCP23008.readAllPins(address: byte; out values: byte): boolean;
begin
  Result := fi2cMaster.ReadByteFromReg(address, byte(GPIOreg), values);
end;

function TMCP23008.writeAllPins(address: byte; const values: byte): boolean;
begin
  Result := fi2cMaster.WriteByteToReg(address, byte(GPIOreg), values);
end;

end.

