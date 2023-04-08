program test_ads1xxx;

{ This program demonstrates generating a simple 1 kHz PWM signal
  on pin LED0 of the PCA9685 chip.  The duty cycle is varied from about 5% to
  100% and back to generate a pulsing light when connected to an LED. }

uses
  sysutils, ads1x1x, i2c;

const
  channel = 3;
  errMsg = 'Error calling ';

var
  i2cMaster: TI2cMaster;
  adc: TADS101x;
  val: int16;
  voltage: integer;

begin
  i2cMaster := TI2cMaster.Create;
  adc := TADS101x.Create;

  if i2cMaster.Initialize(i2c_1) then
  begin
    if not Assigned(i2cMaster) or not adc.Initialize(i2cMaster, $48) then
    begin
      WriteLn(errMsg, 'Initialize');
      exit;
    end;

    repeat
      val := adc.readChannel($48, channel);
      voltage := (integer(val) * 4096) div 32768;
      WriteLn('Value read from channel ', channel, ' = ', val, ' [', voltage, 'mV]');
      Sleep(250);
    until false
  end
  else
  begin
    WriteLn('Error opening i2c device i2c_1');
    i2cMaster.Free;
    Halt(1);
  end;
end.

