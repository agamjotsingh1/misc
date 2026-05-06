module FCVT_int #(
    parameter BUS_WIDTH = 64
) (
    input  [BUS_WIDTH-1:0] in1,
    output [BUS_WIDTH-1:0] out
);

  // Main parameters
  localparam MANTISSA_SIZE = (BUS_WIDTH == 64) ? 52 : 23;
  localparam EXPONENT_SIZE = (BUS_WIDTH == 64) ? 11 : 8;
  localparam BIAS = (BUS_WIDTH == 64) ? 1023 : 127;

  // Other parameters
  localparam PAD_ZERO = 1'b0;
  localparam MID = (BUS_WIDTH == 64) ? 6 : 5;
  localparam MAX_INT_N = (BUS_WIDTH == 64) ? 64'h8000000000000000 : 32'h80000000;
  localparam MAX_INT_P = (BUS_WIDTH == 64) ? 64'h7fffffffffffffff : 32'h7fffffff;
  localparam MANTISSA_PAD = (BUS_WIDTH == 64) ? 12'd1 : 9'd1;
  localparam ZERO = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;
  localparam ONE = (BUS_WIDTH == 64) ? 64'd1 : 32'd1;
  localparam IS_INFINITY = (BUS_WIDTH == 64) ? 11'h7FF : 8'h7F;

  wire [MANTISSA_SIZE-1:0] M = in1[MANTISSA_SIZE-1:0];
  wire [EXPONENT_SIZE-1:0] E = in1[BUS_WIDTH-2:MANTISSA_SIZE];
  wire S = in1[BUS_WIDTH-1];

  wire [EXPONENT_SIZE:0] exponent = {PAD_ZERO, E} - BIAS;

  //wire too_large = |exponent[11:6];

  wire too_large = (exponent[EXPONENT_SIZE] == 0) && (|exponent[EXPONENT_SIZE-1:MID]);
  wire [BUS_WIDTH-1:0] overflow = (S) ? MAX_INT_N : MAX_INT_P;

  wire neg_exp = exponent[EXPONENT_SIZE];

  wire [BUS_WIDTH-1:0] mantissa = {MANTISSA_PAD, M};  // 64-bit mantissa with leading 1

  // Shift left if exponent >= 52, else shift right
  wire [BUS_WIDTH-1:0] num_shifted_left = mantissa << (exponent[MID-1:0] - MANTISSA_SIZE);
  wire [BUS_WIDTH-1:0] num_shifted_right = mantissa >> (MANTISSA_SIZE - exponent[MID-1:0]);


  // Choose left/right shift without comparisons
  wire shift_left = (exponent[EXPONENT_SIZE] == 0) & (exponent[MID-1:0] >= MANTISSA_SIZE);
  wire [BUS_WIDTH-1:0] num = exponent[EXPONENT_SIZE] ? ZERO :  // exponent negative → value <1 → truncate to 0
  shift_left ? num_shifted_left :  // exponent > 63 → use left shift (overflow handled naturally)
  num_shifted_right;

  wire is_inf = (E == IS_INFINITY) & (~|M);
  wire is_NaN = (E == IS_INFINITY) & (|M);
  wire is_zero = (~|E) & (~|M);
  wire [BUS_WIDTH-1:0] nan_res = (in1[BUS_WIDTH-1]) ? (MAX_INT_N) : (MAX_INT_P);
  assign out = (is_NaN)?(nan_res):((is_zero)?(ZERO):((is_inf) ? (overflow) : ((too_large) ? (overflow) : (S ? (~num + ONE) : num))));

endmodule
