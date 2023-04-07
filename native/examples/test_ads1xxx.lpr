program test_ads1xxx;

{ This program demonstrates generating a simple 1 kHz PWM signal
  on pin LED0 of the PCA9685 chip.  The duty cycle is varied from about 5% to
  100% and back to generate a pulsing light when connected to an LED. }

uses
  sysutils, ads1015, i2c;

const
  channel = 3;
  errMsg = 'Error calling ';

var
  i2cMaster: TI2cMaster;
  adc: TADS101x;
  val: uint16;
  voltage: double;

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
      voltage := val / 32768 *4.096;
      WriteLn('Value read from channel ', channel, ' = ', val, ' [', voltage:4:3, 'V]');
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

