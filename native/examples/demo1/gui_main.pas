unit gui_main;

{$mode objfpc}{$H+}

{$define useLTC2309}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  A3nalogGauge, MKnob, LedNumber, i2c, ads1x1x, pwm_pca9685, ltc2309;

type

  { TForm1 }

  TForm1 = class(TForm)
    A3nalogGauge1: TA3nalogGauge;
    Label1: TLabel;
    Label2: TLabel;
    LEDNumber1: TLEDNumber;
    mKnob1: TmKnob;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure mKnob1Change(Sender: TObject; AValue: Longint);
    procedure Timer1Timer(Sender: TObject);
  private
    i2cMaster: TI2cMaster;
    {$ifdef useLTC2309}
    adc: TLTC2309;
    {$else}
    adc: TADS101x;
    {$endif}
    pwm: TPwmPca9685;
  public

  end;

var
  Form1: TForm1;

implementation

const
  errMsg = 'Error: ';
  {$ifdef useLTC2309}
  adcAddress = $08;
  adcChannel = 6;
  {$else}
  adcAddress = $48;
  adcChannel = 3;
  {$endif}
  pwmAddress = $41;
  pwmChannel = 4;

var
  val: uint16;

{$R *.lfm}

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);
var
  voltage: single;
  s: string;
begin
  if Assigned(adc) then
  begin
    val := (3*val + adc.readChannel(adcAddress, adcChannel)) div 4;
    {$ifdef useLTC2309}
    // Assume external 10V reference
    voltage := val / 65535 * 10;
    {$else}
    // Assume internal 4.096V reference
    voltage := val / 32768 * 4.096;
    {$endif}
    A3nalogGauge1.Position := voltage;
    s := format('%5.2f', [voltage]);
    LEDNumber1.Caption := s;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  i2cMaster := TI2cMaster.Create;

  if i2cMaster.Initialize(i2c_1) then
  begin
    pwm.Initialize(i2cMaster, pwmAddress);
    if not pwm.setPWMFreq(1000) then
      WriteLn(errMsg, 'setPWMFreq');
    pwm.setPWM(pwmChannel, 0, 4095);
    mKnob1.Position := 4095;

    {$ifdef useLTC2309}
    adc := TLTC2309.Create;
    {$else}
    adc := TADS101x.Create;
    {$endif}
    if not Assigned(i2cMaster) or not adc.Initialize(i2cMaster, adcAddress) then
    begin
      WriteLn(errMsg, 'Initialize');
      FreeAndNil(adc);
    end;
  end
  else
    FreeAndNil(i2cMaster);
end;

procedure TForm1.mKnob1Change(Sender: TObject; AValue: Longint);
begin
  pwm.setPWM(pwmChannel, 0, AValue);
end;

end.

