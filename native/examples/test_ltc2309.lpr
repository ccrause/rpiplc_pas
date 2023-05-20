program test_ltc2309;

{ This program demonstrates generating a simple 1 kHz PWM signal
  on pin LED0 of the PCA9685 chip.  The duty cycle is varied from about 5% to
  100% and back to generate a pulsing light when connected to an LED. }

uses
  sysutils, ltc2309, i2c;

const
  channel = 6;
  errMsg = 'Error calling ';

var
  i2cMaster: TI2cMaster;
  adc: TLTC2309;

begin
  i2cMaster := TI2cMaster.Create;
  adc := TLTC2309.Create;
  if i2cMaster.Initialize(i2c_1) then
  begin
   if not Assigned(i2cMaster) or not adc.Initialize(i2cMaster, $08) then
    begin
      WriteLn(errMsg, 'Initialize');
      exit;
    end;

    repeat
      writeln(adc.readChannel($08, channel));
      sleep(500);
    until false;
  end
  else
  begin
    WriteLn('Error opening i2c device i2c_1');
    i2cMaster.Free;
    Halt(1);
  end;
end.

