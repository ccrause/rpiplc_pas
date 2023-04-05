program i2c_write_test;

uses
  sysutils, i2c;

const
  EEPROMaddress = $50;

var
  i2cMaster: TI2cMaster;
  startAddr: uint16 = $38;
  data: TBytes;
  i: integer;

begin
  // Prepare data packet
  SetLength(data, 18);
  data[0] := hi(startAddr);
  data[1] := lo(startAddr);
  for i := 0 to 15 do
    data[i+2] := i;

  i2cMaster := TI2cMaster.Create;
  if not i2cMaster.Initialize(i2c_1) then
  begin
    WriteLn('Error opening i2c device i2c_1');
    i2cMaster.Free;
    Halt(1);
  end;

  if i2cMaster.WriteBytes(byte(EEPROMaddress), @data[0], Length(data)) then
  begin
    WriteLn('Success: WriteBytes');
    // Wait a bit, then read data back
    Sleep(500);
    SetLength(data, 15);
    FillByte(data, Length(data), $81);
    if i2cMaster.ReadBytesFromReg(byte(EEPROMaddress), startAddr, @data[0], Length(data)) then
    begin
      WriteLn('Success: ReadBytes');
      WriteLn('Addr  Value');
      for i := 0 to 15 do
        WriteLn('$', HexStr(i+startAddr, 2), '   $', HexStr(data[i], 2));
    end
    else
      WriteLn('Error: ReadBytes');
  end
  else
    WriteLn('Error: WriteBytes');

  i2cMaster.Free;
end.

