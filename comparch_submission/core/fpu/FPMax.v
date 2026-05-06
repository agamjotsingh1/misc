module FPMax #(
    parameter BUS_WIDTH = 64
) (
    input  [BUS_WIDTH-1:0] in1,
    input  [BUS_WIDTH-1:0] in2,
    output [BUS_WIDTH-1:0] out
);

  // Main parameters
  localparam MANTISSA_SIZE = (BUS_WIDTH == 64) ? 52 : 23;
  localparam EXPONENT_SIZE = (BUS_WIDTH == 64) ? 11 : 8;
  localparam BIAS = (BUS_WIDTH == 64) ? 1023 : 127;


  // Other parameters

  localparam IS_INFINITY = (BUS_WIDTH == 64) ? 11'h7FF : 8'hFF;
  localparam ZERO = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;
  localparam INFINITY_P = (BUS_WIDTH == 64) ? 64'h7ff0000000000000 : 32'h7f800000;
  localparam INFINITY_N = (BUS_WIDTH == 64) ? 64'hfff0000000000000 : 32'hff800000;
  localparam IS_NAN = (BUS_WIDTH == 64) ? 11'h7FF : 8'hFF;
  localparam NAN = (BUS_WIDTH == 64) ? 64'h7ff8000000000000 : 32'h7fc00000;

  // Extracting Sign, Exponent, Mantissa
  wire [MANTISSA_SIZE-1:0] M_1;
  wire [MANTISSA_SIZE-1:0] M_2;
  wire [EXPONENT_SIZE-1:0] E_1;
  wire [EXPONENT_SIZE-1:0] E_2;
  wire S_1;
  wire S_2;

  assign M_1 = in1[MANTISSA_SIZE-1:0];
  assign M_2 = in2[MANTISSA_SIZE-1:0];

  assign E_1 = in1[BUS_WIDTH-2:MANTISSA_SIZE];
  assign E_2 = in2[BUS_WIDTH-2:MANTISSA_SIZE];

  assign S_1 = in1[BUS_WIDTH-1];
  assign S_2 = in2[BUS_WIDTH-1];

  // Special Cases
  wire is_infinity_A = (E_1 == IS_INFINITY & ~|M_1 & ~S_1);
  wire is_infinity_B = (E_2 == IS_INFINITY & ~|M_2 & ~S_2);
  wire is_infinity = is_infinity_A | is_infinity_B;

  // result in the event of infinity
  wire [BUS_WIDTH-1:0] infinity_res = (is_infinity_A) ? ((is_infinity_B) ? ((S_1 == S_2) ? (in1) : ((S_1) ? (in2) : (in1) )) : (in1)) : (in2);

  wire is_nan_A = (E_1 == IS_NAN & |M_1);
  wire is_nan_B = (E_2 == IS_NAN & |M_2);
  wire is_nan = is_nan_A | is_nan_B;


  wire is_zero_A = ~|{E_1, M_1};
  wire is_zero_B = ~|{E_2, M_2};
  wire is_zero = is_zero_A | is_zero_B;

  // Normaml Result (if there are no NaNs, Infinities)

  // Sign
  wire sign_eq = ~(S_1 ^ S_2);
  wire in1_pos = ~S_1;

  wire [BUS_WIDTH-1:0] greater_magnitude = (M_1 > M_2) ? in1 : in2;
  wire [BUS_WIDTH-1:0] smaller_magnitude = (M_1 > M_2) ? in2 : in1;

  wire [BUS_WIDTH-1:0] greater_exponent = (E_1 > E_2) ? in1 : in2;
  wire [BUS_WIDTH-1:0] smaller_exponent = (E_1 > E_2) ? in2 : in1;

  wire equal_exp = E_1 == E_2;

  wire [BUS_WIDTH-1:0] greater_pos = (equal_exp) ? (greater_magnitude) : (greater_exponent);
  wire [BUS_WIDTH-1:0] greater_neg = (equal_exp) ? (smaller_magnitude) : (smaller_exponent);

  wire [BUS_WIDTH-1:0] normal_result = (sign_eq) ? ((in1_pos) ? greater_pos : greater_neg) : ((in1_pos) ? in1 : in2);

  assign out = (is_infinity) ? (infinity_res) : ((~is_nan) ? normal_result : ((is_nan_A) ? ((is_nan_B) ? (NAN) : (in2)) : (in1)));
endmodule