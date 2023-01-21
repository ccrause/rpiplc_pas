unit rpiplc_arduino;

{$linklib rpiplc}

interface

const
  INPUT = $0;
  OUTPUT = $1;

procedure initPins; cdecl; external;
procedure pinMode(pin: uint32; mode: byte); cdecl; external;
procedure digitalWrite(pin: uint32; value:longint); cdecl; external;
function digitalRead(pin: uint32):longint; cdecl; external;
procedure analogWrite(pin: uint32; value:longint); cdecl; external;
function analogRead(pin: uint32): uint16; cdecl; external;
procedure delay(milliseconds: uint32); cdecl; external;
procedure delayMicroseconds(micros: uint32); cdecl; external;
procedure digitalWriteAll(addr: byte; values: uint32); cdecl; external ;
function digitalReadAll(addr: byte): uint32; cdecl; external;
procedure analogWriteAll(addr: byte; var values: uint16); cdecl; external;

implementation

end.
