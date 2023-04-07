unit gui_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, A3nalogGauge,
  MKnob, i2c, ads1x1x, pwm_pca9685;

type

  { TForm1 }

  TForm1 = class(TForm)
    A3nalogGauge1: TA3nalogGauge;
    mKnob1: TmKnob;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure mKnob1Change(Sender: TObject; AValue: Longint);
    procedure Timer1Timer(Sender: TObject);
  private
    i2cMaster: TI2cMaster;
    adc: TADS101x;
    pwm: TPwmPca9685;
  public

  end;

var
  Form1: TForm1;

implementation

const
  errMsg = 'Error: ';

{$R *.lfm}

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);
var
  val: uint16;
  voltage: single;
begin
  if Assigned(adc) then
  begin
    val := adc.readChannel($48, 3);
    voltage := val / 32768 * 4.096;
    A3nalogGauge1.Position := voltage;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  i2cMaster := TI2cMaster.Create;

  if i2cMaster.Initialize(i2c_1) then
  begin
    pwm.Initialize(i2cMaster);
    if not pwm.setPWMFreq(1000) then
      WriteLn(errMsg, 'setPWMFreq');

    adc := TADS101x.Create;
    if not Assigned(i2cMaster) or not adc.Initialize(i2cMaster, $48) then
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
  pwm.setPWM(0, 0, AValue);
end;

end.

