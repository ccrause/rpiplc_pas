unit rpiplc_pins;

interface

uses
  rpiplc_pin_addresses;

{$writeableconst off}

const
  // PWM pins not yet assigned below
  // not sure how this is handled
  //{"PWM1", PWM1}, {"PWM2", PWM2}, {"PWM3", PWM3}, {"EXP1_RST", EXP1_RST}, {"EXP1_RST_2", EXP1_RST_2},

  digitalInputs: array[0..2, 0..6] of int32 = (
  {$if defined(RPIPLC_21) or defined(RPIPLC_38AR) or defined(RPIPLC_42) or defined(RPIPLC_53ARR) or defined(RPIPLC_54ARA) or defined(RPIPLC_57AAR) or defined(RPIPLC_58)}
    (I0_0, I0_1, I0_2, I0_3, I0_4, I0_5, I0_6),
  {$elseif defined(RPIPLC_19R) or defined(RPIPLC_38R) or defined(RPIPLC_50RRA) or defined(RPIPLC_57R)}
    (I0_0, I0_1, -1, -1, -1, -1, -1),
  {$endif}

  {$if defined(RPIPLC_42) or defined(RPIPLC_57AAR) or defined(RPIPLC_58)}
    (I1_0, I1_1, I1_2, I1_3, I1_4, I1_5, I1_6),
  {$elseif defined(RPIPLC_38R) or defined(RPIPLC_38AR) or defined(RPIPLC_50RRA) or defined(RPIPLC_53ARR) or defined(RPIPLC_54ARA) or defined(RPIPLC_57R)}
    (I1_0, I1_1, -1, -1, -1, -1, -1),
  {$endif}

  {$if defined(RPIPLC_50RRA) or defined(RPIPLC_54ARA) or defined(RPIPLC_58)}
    (I2_0, I2_1, I2_2, I2_3, I2_4, I2_5, I2_6)
  {$elseif defined(RPIPLC_53ARR) or defined(RPIPLC_57AAR) or defined(RPIPLC_57R)}
    (I2_0, I2_1, -1, -1, -1, -1, -1)
  {$endif}
  );

  digitalOutputs: array[0..2, 0..6] of int32 = (
  {$if defined(RPIPLC_21) or defined(RPIPLC_38AR) or defined(RPIPLC_42) or defined(RPIPLC_53ARR) or defined(RPIPLC_54ARA) or defined(RPIPLC_57AAR) or defined(RPIPLC_58)}
    (Q0_0, Q0_1, Q0_2, Q0_3, Q0_4, Q0_5, Q0_6),
  {$elseif defined(RPIPLC_19R) or defined(RPIPLC_38R) or defined(RPIPLC_50RRA) or defined(RPIPLC_57R)}
    (Q0_0, Q0_1, Q0_2, -1, -1, -1, -1),
  {$endif}

  {$if defined(RPIPLC_42) or defined(RPIPLC_57AAR) or defined(RPIPLC_58)}
    (Q1_0, Q1_1, Q1_2, Q1_3, Q1_4, Q1_5, Q1_6),
  {$elseif defined(RPIPLC_38R) or defined(RPIPLC_38AR) or defined(RPIPLC_50RRA) or defined(RPIPLC_53ARR) or defined(RPIPLC_54ARA) or defined(RPIPLC_57R)}
    (Q1_0, Q1_1, Q1_2, -1, -1, -1, -1),
  {$endif}

  {$if defined(RPIPLC_50RRA) or defined(RPIPLC_54ARA) or defined(RPIPLC_58)}
    (Q2_0, Q2_1, Q2_2, Q2_3, Q2_4, Q2_5, Q2_6)
  {$elseif defined(RPIPLC_53ARR) or defined(RPIPLC_57AAR) or defined(RPIPLC_57R)}
    (Q2_0, Q2_1, Q2_2, -1, -1, -1, -1)
  {$endif}
  );

  analogInputs: array[0..2, 0..12] of int32 = (
  {$if defined(RPIPLC_21) or defined(RPIPLC_38AR) or defined(RPIPLC_42) or defined(RPIPLC_53ARR) or defined(RPIPLC_54ARA) or defined(RPIPLC_57AAR) or defined(RPIPLC_58)}
    (-1, -1, -1, -1, -1, -1, -1, I0_7, I0_8, I0_9, I0_10, I0_11, I0_12),
  {$elseif defined(RPIPLC_19R) or defined(RPIPLC_38R) or defined(RPIPLC_50RRA) or defined(RPIPLC_57R)}
    (-1, -1, I0_2, I0_3, I0_4, I0_5, -1, -1, -1, -1, -1, -1, -1),
  {$endif}

  {$if defined(RPIPLC_42) or defined(RPIPLC_57AAR) or defined(RPIPLC_58)}
    (-1, -1, -1, -1, -1, -1, -1, I1_7, I1_8, I1_9, I1_10, I1_11, I1_12),
  {$elseif defined(RPIPLC_38R) or defined(RPIPLC_38AR) or defined(RPIPLC_50RRA) or defined(RPIPLC_53ARR) or defined(RPIPLC_54ARA) or defined(RPIPLC_57R)}
    (-1, -1, I1_2, I1_3, I1_4, I1_5, -1, -1, -1, -1, -1, -1, -1),
  {$endif}

  {$if defined(RPIPLC_50RRA) or defined(RPIPLC_54ARA) or defined(RPIPLC_58)}
    (-1, -1, -1, -1, -1, -1, -1, I2_7, I2_8, I2_9, I2_10, I2_11, I2_12)
  {$elseif defined(RPIPLC_53ARR) or defined(RPIPLC_57AAR) or defined(RPIPLC_57R)}
    (-1, -1, I2_2, I2_3, I2_4, I2_5, -1, -1, -1, -1, -1, -1, -1)
  {$endif}
  );

  analogOutputs: array[0..2, 0..7] of int32 = (
  {$if defined(RPIPLC_21) or defined(RPIPLC_38AR) or defined(RPIPLC_42) or defined(RPIPLC_53ARR) or defined(RPIPLC_54ARA) or defined(RPIPLC_57AAR) or defined(RPIPLC_58)}
    (-1, -1, -1, -1, -1, A0_5, A0_6, A0_7),
  {$elseif defined(RPIPLC_19R) or defined(RPIPLC_38R) or defined(RPIPLC_50RRA) or defined(RPIPLC_57R)}
    (A0_0, A0_1, A0_2, -1, -1, -1, -1, -1),
  {$endif}
  {$if defined(RPIPLC_42) or defined(RPIPLC_57AAR) or defined(RPIPLC_58)}
    (-1, -1, -1, -1, -1, A1_5, A1_6, A1_7),
  {$elseif defined(RPIPLC_38R) or defined(RPIPLC_38AR) or defined(RPIPLC_50RRA) or defined(RPIPLC_53ARR) or defined(RPIPLC_54ARA) or defined(RPIPLC_57R)}
    (A1_0, A1_1, A1_2, -1, -1, -1, -1, -1),
  {$endif}
  {$if defined(RPIPLC_50RRA) or defined(RPIPLC_54ARA) or defined(RPIPLC_58)}
    (-1, -1, -1, -1, -1, A2_5, A2_6, A2_7)
  {$elseif defined(RPIPLC_53ARR) or defined(RPIPLC_57AAR) or defined(RPIPLC_57R)}
    (A2_0, A2_1, A2_2, -1, -1, -1, -1, -1)
  {$endif}
  );

  relayOutputs: array[0..2, 0..8] of int32 = (
  {$if defined(RPIPLC_19R) or defined(RPIPLC_38R) or defined(RPIPLC_50RRA) or defined(RPIPLC_57R)}
    (R0_1, R0_2, R0_3, R0_4, R0_5, R0_6, R0_7, R0_8),
  {$else}
    (-1, -1, -1, -1, -1, -1, -1, -1, -1),
  {$endif}
  {$if defined(RPIPLC_38R) or defined(RPIPLC_38AR) or defined(RPIPLC_50RRA) or defined(RPIPLC_53ARR) or defined(RPIPLC_54ARA) or defined(RPIPLC_57R)}
    (R1_1, R1_2, R1_3, R1_4, R1_5, R1_6, R1_7, R1_8),
  {$else}
    (-1, -1, -1, -1, -1, -1, -1, -1, -1),
  {$endif}
  {$if defined(RPIPLC_53ARR) or defined(RPIPLC_57AAR) or defined(RPIPLC_57R)}
    (R2_1, R2_2, R2_3, R2_4, R2_5, R2_6, R2_7, R2_8)
  {$else}
    (-1, -1, -1, -1, -1, -1, -1, -1, -1)
  {$endif}
  );

implementation

end.

