program test_pca9685;

{ This program demonstrates generating a simple 1 kHz PWM signal
  on pin LED0 of the PCA9685 chip.  The duty cycle is varied from about 5% to
  100% and back to generate a pulsing light when connected to an LED. }

uses
  sysutils, pwm_pca9685, i2c;

const
  channel = 0;
  errMsg = 'Error calling ';

var
  i2cMaster: TI2cMaster;
  PWM: TPwmPca9685;
  brightness: uint16;
  sign: int16;

begin
  i2cMaster := TI2cMaster.Create;
  if i2cMaster.Initialize(i2c_1) then
  begin
   if not Assigned(i2cMaster) or not PWM.Initialize(i2cMaster) then
    begin
      WriteLn(errMsg, 'Initialize');
      exit;
    end;

    if not pwm.setPWMFreq(1000) then
      WriteLn(errMsg, 'setPWMFreq');

    // brightness ranges from 0 to 4095
    brightness := 405; // about 10% of 4095
    sign := 1;
    repeat
      if not pwm.setPWM(channel, 0, brightness) then
        WriteLn(errMsg, 'setPWM');

      Sleep(50);
      brightness := brightness + sign*205;
      if brightness > (4095 - 205) then
       sign := -1
      else if (sign = -1) and (brightness <= 205) then
       sign := 1;
    until false;
  end
  else
  begin
    WriteLn('Error opening i2c device i2c_1');
    i2cMaster.Free;
    Halt(1);
  end;
end.

