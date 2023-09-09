program test_gpiov2;

{ This program demonstrates pin access via the IOCTL interface V2. }

// References
// https://elixir.bootlin.com/linux/latest/source/tools/gpio/gpio-utils.c

uses
  baseunix, gpio, sysutils;

const
  PinNumber = 26;

function initGPIOChip: integer;
begin
  Result := FpOpen('/dev/gpiochip0', O_RDONLY);
  if Result < 0 then
    writeln('Error opening handle to /dev/gpiochip0: ', errno);
end;

procedure finitGPIOChip(const fHandle: integer);
begin
  if fHandle > -1 then
    FpClose(fHandle);
end;

procedure printChipInfo;
var
  fHandle: integer;
  r: integer;
  info: Tgpiochip_info;
  line_info: Tgpioline_info;
  i: integer;
begin
  fHandle := initGPIOChip;
  if fHandle > -1 then
  begin
    r := FpIOCtl(fHandle, GPIO_GET_CHIPINFO_IOCTL, @info);
    if r >= 0 then
    begin
      writeln('Name: ', info.name);
      writeln('Label: ', info.&label);
      writeln('Number of lines: ', info.lines);

     for i := 0 to info.lines-1 do
      begin
        line_info.line_offset := i;
        r := FpIOCtl(fHandle, GPIO_GET_LINEINFO_IOCTL, @line_info);
        if (r = -1) then
          writeln('Unable to get line info from offset ', i, ': ', errno)
        else
          writeln('offset: ', i:2, ' name: ', line_info.name, ' consumer: ', line_info.consumer:16, ' Flags: ', HexStr(line_info.flags, 2));
      end;
    end
    else
      writeln('Error: ', r);
    finitGPIOChip(fHandle);
  end;
end;

function getLineHandle(const pin: integer; config: Tgpio_v2_line_config): integer;
var
  fHandle: integer;
  req: Tgpio_v2_line_request;
  r: integer;
begin
  FillByte(req, SizeOf(req), 0);
  req.offsets[0] := pin;
  req.num_lines := 1;
  req.config := config;
  req.consumer := 'test';

  fHandle := initGPIOChip;
  if fHandle > -1 then
  begin
    r := FpIOCtl(fHandle, GPIO_V2_GET_LINE_IOCTL, @req);
    finitGPIOChip(fHandle);

    if r < 0 then
    begin
      Result := -1;
      writeln('Unable to get line handle from ioctl: ', errno);
    end
    else
      Result := req.fd;
  end
  else
    Result := -1;
end;

// Note that the pin number is not used here or in readPin.
// The pin number is set by the call to getLineHandle
// and remembered by the driver while the returned handle is used (fLineHandle)
procedure writePin(const fLineHandle, pin: integer; value: boolean);
var
  data: Tgpio_v2_line_values;
  r: integer;
begin
  data.bits := 0;
  data.mask := 1;
  if value then
    data.bits := 1;

  if fLineHandle > -1 then
  begin
    r := FpIOCtl(fLineHandle, GPIO_V2_LINE_SET_VALUES_IOCTL, @data);

    if r = -1 then
      writeln('Unable to set line value using ioctl: ', errno);
  end
  else
    writeln('Invalid line handle passed to writePin: ', fLineHandle);
end;

function readPin(const fLineHandle, pin: integer): boolean;
var
  data: Tgpio_v2_line_values;
  r: integer;
begin
  Result := false;
  data.bits := 0;
  data.mask := 1;

  if fLineHandle > -1 then
  begin
    r := FpIOCtl(fLineHandle, GPIO_V2_LINE_GET_VALUES_IOCTL, @data);

    if r = -1 then
      writeln('Unable to get line value using ioctl: ', errno)
    else
      Result := data.bits and 1 > 0;
  end
  else
    writeln('Invalid line handle passed to readPin: ', fLineHandle);
end;

var
  count: integer = 9;
  fLineHandle: integer;
  config: Tgpio_v2_line_config;

begin
  printChipInfo;
  FillByte(config, SizeOf(config), 0);
  config.flags := ord(GPIO_V2_LINE_FLAG_OUTPUT);
  fLineHandle := getLineHandle(PinNumber, config);
  if fLineHandle < 0 then exit;

  repeat
    writePin(fLineHandle, PinNumber, true);
    writeln('*');
    writeln('Reading: ', readPin(fLineHandle, PinNumber));
    sleep(1000);
    writePin(fLineHandle, PinNumber, false);
    writeln('.');
    writeln('Reading: ', readPin(fLineHandle, PinNumber));
    sleep(1000);
    dec(count);
  until count < 1;

  FpClose(fLineHandle);
end.

