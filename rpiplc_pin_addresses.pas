unit rpiplc_pin_addresses;

interface

const
  PIN8 = 8;
  PWM3 = $00004109;
  PWM2 = $0000410A;
  PWM1 = $0000410B;
  EXP1RST  = $00004008;
  EXP1RST2 = $0000400A;

{$if defined(RPIPLC_21) or defined(RPIPLC_38AR) or defined(RPIPLC_42) or defined(RPIPLC_53ARR) or defined(RPIPLC_54ARA) or defined(RPIPLC_57AAR) or defined(RPIPLC_58)}
const
  I0_0 = $00002105;
  I0_1 = $00002102;
  I0_2 = $00002104;
  I0_3 = $00002101;
  I0_4 = $00002103;
  I0_5 = 13;
  I0_6 = 12;
  I0_7 = $00000806;
  I0_8 = $00000805;
  I0_9 = $00000807;
  I0_10 = $00000A00;
  I0_11 = $00000A06;
  I0_12 = $00000A03;
  Q0_0 = $0000410C;
  Q0_1 = $00004000;
  Q0_2 = $0000410F;
  Q0_3 = $0000410E;
  Q0_4 = $00004105;
  Q0_5 = $00004104;
  Q0_6 = $00004102;
  Q0_7 = $00004100;
  A0_5 = Q0_5;
  A0_6 = Q0_6;
  A0_7 = Q0_7;
{$elseif defined(RPIPLC_19R) or defined(RPIPLC_38R) or defined(RPIPLC_50RRA) or defined(RPIPLC_57R)}
const
  I0_0 = 13;
  I0_1 = 12;
  I0_2 = $00000806;
  I0_3 = $00000805;
  I0_4 = $00000807;
  I0_5 = $00000A00;

  Q0_0 = $00004104;
  Q0_1 = $00004102;
  Q0_2 = $00004100;
  A0_0 = Q0_0;
  A0_1 = Q0_1;
  A0_2 = Q0_2;

  R0_1 = $00002102;
  R0_2 = $00002105;
  R0_3 = $00002101;
  R0_4 = $00002104;
  R0_5 = $00004105;
  R0_6 = $0000410E;
  R0_7 = $0000410F;
  R0_8 = $00004000;
{$else}
  {$error The specific model of RPi-PLC must be specified, e.g. -dRPIPLC_58 }
{$endif}

{$if defined(RPIPLC_42) or defined(RPIPLC_57AAR) or defined(RPIPLC_58)}
const
  I1_0 = $00002004;
  I1_1 = $00002000;
  I1_2 = $00002001;
  I1_3 = $00002106;
  I1_4 = $00002107;
  I1_5 = 27;
  I1_6 = 5;
  I1_7 = $00002807;
  I1_8 = $00000800;
  I1_9 = $00002800;
  I1_10 = $00000A02;
  I1_11 = $00000804;
  I1_12 = $00000A04;
  Q1_0 = $00004003;
  Q1_1 = $00004006;
  Q1_2 = $00004002;
  Q1_3 = $00004005;
  Q1_4 = $0000410D;
  Q1_5 = $00004001;
  Q1_6 = $00004103;
  Q1_7 = $00004101;
  A1_5 = Q1_5;
  A1_6 = Q1_6;
  A1_7 = Q1_7;
{$elseif defined(RPIPLC_38R) or defined(RPIPLC_38AR) or defined(RPIPLC_50RRA) or defined(RPIPLC_53ARR) or defined(RPIPLC_54ARA) or defined(RPIPLC_57R)}
const
  I1_0 = 27;
  I1_1 = 5;
  I1_2 = $00002807;
  I1_3 = $00000800;
  I1_4 = $00002800;
  I1_5 = $00000A02;
  Q1_0 = $00004001;
  Q1_1 = $00004103;
  Q1_2 = $00004101;
  A1_0 = Q1_0;
  A1_1 = Q1_1;
  A1_2 = Q1_2;
  R1_1 = $00002000;
  R1_2 = $00002004;
  R1_3 = $00002106;
  R1_4 = $00002001;
  R1_5 = $0000410D;
  R1_6 = $00004005;
  R1_7 = $00004002;
  R1_8 = $00004006;
{$else}
  {$error The specific model of RPi-PLC must be specified, e.g. -dRPIPLC_58 }
{$endif}

{$if defined(RPIPLC_50RRA) or defined(RPIPLC_54ARA) or defined(RPIPLC_58)}
const
  I2_0 = $00002007;
  I2_1 = $00002003;
  I2_2 = $00002006;
  I2_3 = $00002002;
  I2_4 = $00002005;
  I2_5 = 26;
  I2_6 = 4;
  I2_7 = $00000803;
  I2_8 = $00002803;
  I2_9 = $00000802;
  I2_10 = $00000801;
  I2_11 = $00002806;
  I2_12 = $00000A01;
  Q2_0 = $0000400E;
  Q2_1 = $0000400C;
  Q2_2 = $0000400F;
  Q2_3 = $0000400D;
  Q2_4 = $00004007;
  Q2_5 = $00004004;
  Q2_6 = $00004107;
  Q2_7 = $00004106;
  A2_5 = Q2_5;
  A2_6 = Q2_6;
  A2_7 = Q2_7;
{$elseif defined(RPIPLC_53ARR) or defined(RPIPLC_57AAR) or defined(RPIPLC_57R)}
const
  I2_0 = 26;
  I2_1 = 4;
  I2_2 = $00000803;
  I2_3 = $00002803;
  I2_4 = $00000802;
  I2_5 = $00000801;
  Q2_0 = $00004004;
  Q2_1 = $00004107;
  Q2_2 = $00004106;
  A2_0 = Q2_0;
  A2_1 = Q2_1;
  A2_2 = Q2_2;
  R2_1 = $00002003;
  R2_2 = $00002007;
  R2_3 = $00002002;
  R2_4 = $00002006;
  R2_5 = $00004007;
  R2_6 = $0000400D;
  R2_7 = $0000400F;
  R2_8 = $0000400C;
{$else}
  {$error The specific model of RPi-PLC must be specified, e.g. -dRPIPLC_58 }
{$endif}

implementation

end.
