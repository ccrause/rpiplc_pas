program rpiplc_pas;

uses
  rpi_pins,
  sysutils, rpiplc_arduino;

procedure cmdlineHelp;
begin
  WriteLn('Usage:');
  WriteLn('rpiplc_pas <operation> <channel> <pin> [<value>]');
  WriteLn('');
  WriteLn('<operation> is:');
  WriteLn('  ai - read analog input pin');
  WriteLn('  ao - write analog output pin');
  WriteLn('  di - read digital input pin');
  WriteLn('  do - write digital output pin');
  WriteLn('  ro - write relay output pin');
  WriteLn('');
  WriteLn('<channel> is 0, 1, 2 (channels depend on the specific shield option)');
  WriteLn('');
  WriteLn('-<pin> is the pin number (pins depend on the specific shield option)');
  WriteLn('');
  WriteLn('<value> (Optional) value to write to pin( 0/1 for digital and relay pins, 0-4095 for analog pins)');
end;

var
  s: string;
  chan, pin, pinAddr: integer;
  val: int32;

procedure processInputs;
begin
  if (ParamCount < 3) then
  begin
    cmdlineHelp;
    halt(1);
  end;

  s := ParamStr(1);
  // Check input options first
  if not (s[1] in ['a', 'd', 'r']) or
     not (s[2] in ['i', 'o']) then
  begin
    WriteLn('Error: Parameter 1 should be one of: ai, ao, di, do, ro');
    Halt(1);
  end;

  if ((s[2] = 'i') and (ParamCount > 3)) then
  begin
    WriteLn('Error: an input operation should have two integer parameters');
    Halt(1);
  end;

  if   ((s[2] = 'o') and not(ParamCount = 4)) then
  begin
    WriteLn('Error: an output operation should have three integer parameters');
    Halt(1);
  end;

  if not TryStrToInt(ParamStr(2), chan) then
  begin
    WriteLn('Error: Expected an integer for parameter 2');
    Halt(1);
  end;

  if not TryStrToInt(ParamStr(3), pin) then
  begin
    WriteLn('Error: Expected an integer for parameter 3');
    Halt(1);
  end;

  if (s[2] = 'o') and not TryStrToInt(ParamStr(4), val) then
  begin
    WriteLn('Error: Expected an integer for parameter 4');
    Halt(1);
  end;

  case s of
    'ai':  pinAddr := analogInputs[chan, pin];
    'ao':  pinAddr := analogOutputs[chan, pin];
    'di':  pinAddr := digitalInputs[chan, pin];
    'do':  pinAddr := digitalOutputs[chan, pin];
    'ro':  pinAddr := relayOutputs[chan, pin];
  end;

  if pinAddr = -1 then
  begin
    WriteLn('Error: Invalid channel/pin combination');
    Halt(1);
  end;
end;

begin
  processInputs;
  rpiplc_arduino.initPins;
  case s of
    'ai':
      begin
        pinMode(pinAddr, INPUT);
        val := analogRead(pinAddr);
      end;
    'ao':
      begin
        pinMode(pinAddr, OUTPUT);
        analogWrite(pinAddr, val);
      end;
    'di':
      begin
        pinMode(pinAddr, INPUT);
        val := digitalRead(pinAddr);
      end;
    'do', 'ro':
      begin
        pinMode(pinAddr, OUTPUT);
        digitalWrite(pinAddr, val);
      end;
  end;
end.

