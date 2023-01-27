program i2c_read_reg;

uses
  sysutils, i2c;

procedure cmdlineHelp;
begin
  WriteLn('Usage:');
  WriteLn('i2c_read_reg <bus> <address> <register>');
  WriteLn('');
  WriteLn('  <bus> is either 0 or 1 (should typically be 1)');
  WriteLn('  <address> is the right ajusted device i2c address');
  WriteLn('  <register> is the register number to read');
  WriteLn();
end;

var
  bus: TI2CBus;
  address, reg: integer;

procedure processInputs;
var
  s: string;
begin
  if (ParamCount < 3) then
  begin
    cmdlineHelp;
    halt(1);
  end;

  s := ParamStr(1);
  // Check input options first
  if not (s[1] in ['0', '1']) then
  begin
    WriteLn('Error: Parameter 1 should be either 0 or 1');
    Halt(1);
  end;
  bus := TI2CBus(StrToInt(s));

  if not TryStrToInt(ParamStr(2), address) then
  begin
    WriteLn('Error: Expected an integer for parameter 2, in the range 0...255');
    Halt(1);
  end;
  if (address < 0) or (address > 255) then
  begin
    Writeln('address parameter should be in the range 0...255');
    Halt(1);
  end;

  if not TryStrToInt(ParamStr(3), reg) then
  begin
    WriteLn('Error: Expected an integer for parameter 3');
    Halt(1);
  end;
  if (reg < 0) or (reg > 255) then
  begin
    Writeln('register parameter should be in the range 0...255');
    Halt(1);
  end;
end;

var
  i2cMaster: TI2cMaster;
  val: byte;

begin
  processInputs;
  i2cMaster := TI2cMaster.Create;
  if not i2cMaster.Initialize(bus) then
  begin
    writeln('Error opening i2c device: ', bus);
    i2cMaster.Free;
    Halt(1);
  end;

  if i2cMaster.ReadByteFromReg(byte(address), byte(reg), val) then
  begin
    Writeln(IntToHex(val));
  end
  else
    WriteLn(Format('Error reading register $%X from device $%X', [reg, address]));

  i2cMaster.Free;
end.

