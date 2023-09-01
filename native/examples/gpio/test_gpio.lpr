program test_gpio;

{ This program demonstrates pin access via the IOCTL interface. }

uses
  baseunix, gpio;

var
  fHandle: integer;
  fpins: array[0..63] of integer; // Store private file handle to pin IO

procedure initGPIOChip;
begin
  fHandle := FpOpen('/dev/gpiochip0', O_RDONLY);
  if fHandle < 0 then
    writeln('Error opening handle to /dev/gpiochip0: ', fHandle)
  else
    writeln('success: ', fHandle);
end;

procedure finitGPIOChip;
begin
  if fHandle > -1 then
    FpClose(fHandle);
end;

procedure printChipInfo;
var
  r: integer;
  info: Tgpiochip_info;
begin
  if fHandle > -1 then
  begin
    r := FpIOCtl(fHandle, GPIO_GET_CHIPINFO_IOCTL, @info);
    if r >= 0 then
    begin
      writeln('Name: ', info.name);
      writeln('Label: ', info.&label);
      writeln('Number of lines: ', info.lines);
    end
    else
      writeln('Error: ', r);
  end;
end;

begin
  initGPIOChip;
  printChipInfo;
  finitGPIOChip;
end.

