module FPAdder #(
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

  // Other non-important parameters
  localparam LEADING_ONE = (BUS_WIDTH == 64) ? 12'd1 : 9'd1;
  localparam PRODUCT_PAD = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;
  localparam ROUND_UP = (BUS_WIDTH == 64) ? 64'd1 : 32'd1;
  localparam PAD_ZERO = 1'b0;
  localparam ROUND_DOWN = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;
  localparam MANTISSA_PAD = (BUS_WIDTH == 64) ? 52'd0 : 23'd0;
  localparam MANTISSA_SHIFT = (BUS_WIDTH == 64) ? 11'd1 : 8'd1;
  localparam EXPONENT_INC = (BUS_WIDTH == 64) ? 12'd1 : 9'd1;
  localparam EXPONENT_NO_CHANGE = (BUS_WIDTH == 64) ? 12'd0 : 9'd0;
  localparam PAD_2 = (BUS_WIDTH == 64) ? 12'd0 : 9'd0;
  localparam SHIFT_MAX = 7;
  localparam IS_INFINITY = (BUS_WIDTH == 64) ? 11'h7FF : 8'hFF;
  localparam NAN = (BUS_WIDTH == 64) ? 64'h7ff8000000000000 : 32'h7fc00000;
  localparam INFINITY_P = (BUS_WIDTH == 64) ? 64'h7ff0000000000000 : 32'h7f800000;
  localparam INFINITY_N = (BUS_WIDTH == 64) ? 64'hfff0000000000000 : 32'hff800000;
  localparam ZERO = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;

  // Extracting Sign, Exponent, Mantissa
  wire [MANTISSA_SIZE-1:0] M_A;
  wire [MANTISSA_SIZE-1:0] M_B;
  wire [EXPONENT_SIZE-1:0] E_A;
  wire [EXPONENT_SIZE-1:0] E_B;
  wire S_A;
  wire S_B;
  assign M_A =in1[MANTISSA_SIZE-1:0];
  assign M_B =in2[MANTISSA_SIZE-1:0];
  assign E_A =in1[BUS_WIDTH-2:MANTISSA_SIZE];
  assign E_B =in2[BUS_WIDTH-2:MANTISSA_SIZE];
  assign S_A =in1[BUS_WIDTH-1];
  assign S_B =in2[BUS_WIDTH-1];

  // Check for NaN inputs (exponent all 1s and non-zero mantissa)
  wire is_NaN_A = (E_A == IS_INFINITY) && (|M_A);
  wire is_NaN_B = (E_B == IS_INFINITY) && (|M_B);
  wire input_is_NaN = is_NaN_A | is_NaN_B;

  // Shifting smaller number

  // Setting control bit - need to compare full magnitude
  // Compare exponents first, then mantissas if equal
  wire exp_equal = (E_A == E_B);
  wire mant_compare = ({|E_A, M_A} < {|E_B, M_B});  // Compare full significands
  wire cntrl = (E_A < E_B) | (exp_equal & mant_compare);

  // Amount to shift smaller number by
  wire [EXPONENT_SIZE:0] shift_amt = (cntrl) ? (E_B - E_A) : (E_A - E_B);


  // Setting M_1, M_2 as operands of Add/Sub unit
  wire [MANTISSA_SIZE-1:0] M = (cntrl) ? M_A : M_B;
  wire [MANTISSA_SIZE-1:0] M2 = (~cntrl) ? M_A : M_B;
  wire [EXPONENT_SIZE:0] exp_1 = (cntrl) ? {PAD_ZERO, E_B} : {PAD_ZERO, E_A};

  wire [MANTISSA_SIZE:0] M1 = {(cntrl) ? |E_A : |E_B, M};
  wire [MANTISSA_SIZE:0] M_2 = {(cntrl) ? |E_B : |E_A, M2};


  // Before shifting smaller number, properly accounting for truncation
  wire [MANTISSA_SIZE:0] temp_1 = M1 >> ((shift_amt) - MANTISSA_SHIFT);
  wire G_1 = (shift_amt >= MANTISSA_SHIFT) ? (temp_1[0]) : (PAD_ZERO);  // Guard Bit

  wire [MANTISSA_SIZE:0] temp_2 = M1 >> ((shift_amt) - (MANTISSA_SHIFT + 1));
  wire R_1 = (shift_amt >= (MANTISSA_SHIFT + 1)) ? (temp_2[0]) : (PAD_ZERO);  // Round Bit

  // Fixed: temp_3 typo
  wire [MANTISSA_SIZE:0] temp_3 = M1 << ((MANTISSA_SIZE + 1) - shift_amt);
  wire S_1 = (shift_amt >= (MANTISSA_SHIFT + 2)) ? (|temp_3) : (PAD_ZERO);  // Sticky Bit

  wire [MANTISSA_SIZE:0] M_1 = M1 >> shift_amt;


  // Performing addition/subtraction
  wire add = ~(S_A ^ S_B);
  wire [MANTISSA_SIZE+1:0] temp_mantissa = ~add ? ({PAD_ZERO, M_2} - {PAD_ZERO, M_1}) : ({PAD_ZERO, M_2} + {PAD_ZERO, M_1});

  // FIXED: Sign bit determination
  wire zer0;
  assign zer0 = ~|temp_mantissa;

  // For addition (same signs): use the common sign
  wire temp1 = (~(S_A ^ S_B) & (S_A & S_B));

  // For subtraction (different signs): use sign of larger magnitude operand
  // cntrl determines which is larger in magnitude
  wire temp2 = ((S_A ^ S_B) & (((~cntrl) & S_A) | (cntrl & S_B)));
  wire temp3 = zer0 ? 0 : temp1 | temp2;

  // Normalizing mantissa
  wire [SHIFT_MAX-1:0] shift_amt_1;
  shift_amount #(
      .MANTISSA_SIZE(MANTISSA_SIZE),
      .EXPONENT_SIZE(EXPONENT_SIZE),
      .BUS_WIDTH(BUS_WIDTH)
  ) shift_amont (
      .A(temp_mantissa),
      .add(add),
      .shift_amoont(shift_amt_1)
  );

  wire [MANTISSA_SIZE+1:0] sub_shift = temp_mantissa << shift_amt_1;
  wire [MANTISSA_SIZE+1:0] add_shift = temp_mantissa >> shift_amt_1;


  wire [MANTISSA_SIZE:0] shifted_mantissa = (add) ? (add_shift[MANTISSA_SIZE:0]) : (sub_shift[MANTISSA_SIZE:0]);

  // Updating exponent based on mantissa shift
  wire [EXPONENT_SIZE:0] add_exp = exp_1 + ((temp_mantissa[MANTISSA_SIZE+1]) ? EXPONENT_INC : EXPONENT_NO_CHANGE);
  wire [EXPONENT_SIZE:0] sub_exp = exp_1 - (shift_amt_1);
  wire [EXPONENT_SIZE:0] exp_2 = add ? add_exp : sub_exp;

  // FIXED: Rounding Logic for catastrophic cancellation
  wire L = (add & temp_mantissa[MANTISSA_SIZE+1]) ? (temp_mantissa[1]) : (shifted_mantissa[1]);
  wire G = (add & temp_mantissa[MANTISSA_SIZE+1]) ? (temp_mantissa[0]) : (shifted_mantissa[0]);
  wire R = (add & temp_mantissa[MANTISSA_SIZE+1]) ? (G_1) : (R_1);
  wire S = (add & temp_mantissa[MANTISSA_SIZE+1]) ? (R_1 | S_1) : S_1;

  // Round to nearest, ties to even (IEEE 754 default)
  wire round_add = (add) ? (G & (L | R | S)) : PAD_ZERO;
  wire round_sub = PAD_ZERO;  // Don't round on subtraction normalize

  wire [MANTISSA_SIZE+1:0] rounded_mantissa_cout = (add) ? (shifted_mantissa + {MANTISSA_PAD, round_add}) : (shifted_mantissa + {MANTISSA_PAD, round_sub});

  wire [MANTISSA_SIZE:0] rounded_mantissa = rounded_mantissa_cout[MANTISSA_SIZE:0];
  wire cout = rounded_mantissa_cout[MANTISSA_SIZE+1];
  wire [EXPONENT_SIZE:0] exp_rnorm = exp_2 + (cout ? EXPONENT_INC : EXPONENT_NO_CHANGE);

  // Checking for 0's
  wire [EXPONENT_SIZE:0] exp_3 = zer0 ? EXPONENT_NO_CHANGE : exp_rnorm;

  // Checking exponent overflow
  wire exp_overflow = (exp_3 >= 2 * BIAS + 1);

  // Checking A, B for infinities
  wire is_inf_A = (E_A == IS_INFINITY) && ~(|M_A);
  wire is_inf_B = (E_B == IS_INFINITY) && ~(|M_B);

  wire is_NaN = input_is_NaN | ((S_A ^ S_B) & (is_inf_A & is_inf_B));  // NaN input or Inf-Inf
  wire is_inf = ((is_inf_A | is_inf_B) & !is_NaN) | exp_overflow;

  wire [BUS_WIDTH-1:0] out_1 = {
    temp3,
    exp_3[EXPONENT_SIZE-1:0],
    cout ? rounded_mantissa[MANTISSA_SIZE:1] : rounded_mantissa[MANTISSA_SIZE-1:0]
  };
  wire [BUS_WIDTH-1:0] out_2 = NAN;  // NaN
  wire [BUS_WIDTH-1:0] out_3 = (is_inf_A) ? ((S_A) ? (INFINITY_N) : (INFINITY_P)) :
                    ((is_inf_B) ? ((S_B) ? (INFINITY_N) : (INFINITY_P)) :
                    ((temp3) ? (INFINITY_N) : (INFINITY_P)));

  assign out = (is_NaN) ? (out_2) : ((is_inf) ? (out_3) : (out_1));

endmodule