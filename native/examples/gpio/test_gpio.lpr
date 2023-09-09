program test_gpio;

{ This program demonstrates pin access via the IOCTL interface. }

// References
// https://elixir.bootlin.com/linux/latest/source/tools/gpio/gpio-utils.c
// https://elinux.org/images/9/9b/GPIO_for_Engineers_and_Makers.pdf
// https://blog.lxsang.me/post/id/33

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

function getLineHandle(const pin, flags: integer; defaultValue: boolean): integer;
var
  fHandle: integer;
  req: Tgpiohandle_request;
  r: integer;
begin
  FillByte(req, SizeOf(req), 0);
  req.lineoffsets[0] := pin;
  req.lines := 1;
  req.flags := flags;
  req.consumer_label[0] := '@';
  req.consumer_label[1] := #0;

  if defaultValue then
    req.default_values[0] := 1;

  fHandle := initGPIOChip;
  if fHandle > -1 then
  begin
    r := FpIOCtl(fHandle, GPIO_GET_LINEHANDLE_IOCTL, @req);
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

procedure writePin(const fLineHandle, pin: integer; value: boolean);
var
  data: Tgpiohandle_data;
  r: integer;
begin
  FillByte(data.values[0], SizeOf(data.values), 0);
  if value then
    data.values[0] := 1
  else
    data.values[0] := 0;

  if fLineHandle > -1 then
  begin
    r := FpIOCtl(fLineHandle, GPIOHANDLE_SET_LINE_VALUES_IOCTL, @data);

    if r = -1 then
      writeln('Unable to set line value using ioctl :', errno);
  end
  else
    writeln('Invalid line handle passed to writePin: ', fLineHandle);
end;

function readPin(const fLineHandle, pin: integer): boolean;
var
  data: Tgpiohandle_data;
  r: integer;
begin
  Result := false;
  FillByte(data.values[0], SizeOf(data.values), 0);

  if fLineHandle > -1 then
  begin
    r := FpIOCtl(fLineHandle, GPIOHANDLE_GET_LINE_VALUES_IOCTL, @data);

    if r = -1 then
      writeln('Unable to set line value using ioctl :', errno)
    else
      Result := data.values[0] = 1;
  end
  else
    writeln('Invalid line handle passed to writePin: ', fLineHandle);
end;

var
  count: integer = 9;
  fLineHandle: integer;

begin
  printChipInfo;
  fLineHandle := getLineHandle(PinNumber, GPIOHANDLE_REQUEST_OUTPUT, false);
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

