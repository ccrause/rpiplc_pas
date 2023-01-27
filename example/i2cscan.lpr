program i2cscan;

uses
  sysutils, i2c;

var
  i, j, addr: uint32;
  i2cMaster: TI2cMaster;

begin
  i2cMaster := TI2cMaster.Create;
  if not i2cMaster.Initialize(i2c_1) then
  begin
    writeln('Error opening i2c device: ', i2c_1);
    exit;
  end;

  writeln('Starting scanning right adjusted addresses $00 - $7f.');
  writeln;
  writeln('   00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F');
  for i := 0 to 7 do
  begin
    write(HexStr(i, 1), '0 ');
    for j := 0 to 15 do
    begin
      addr := (i shl 4) or j;
      if i2cMaster.CheckAddress(addr) then
          write(HexStr(addr, 2), ' ')
      else
        write('.. ');
    end;
    writeln;
  end;
end.

