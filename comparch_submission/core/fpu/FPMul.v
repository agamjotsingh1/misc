module FPMul #(
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
  localparam EXPONENT_INC = (BUS_WIDTH == 64) ? 12'd1 : 9'd1;
  localparam EXPONENT_NO_CHANGE = (BUS_WIDTH == 64) ? 12'd0 : 9'd0;
  localparam PAD_2 = (BUS_WIDTH == 64) ? 12'd0 : 9'd0;
  localparam IS_INFINITY = (BUS_WIDTH == 64) ? 11'h7FF : 8'hFF;
  localparam NAN = (BUS_WIDTH == 64) ? 64'h7ff8000000000000 : 32'h7fc00000;
  localparam INFINITY_P = (BUS_WIDTH == 64) ? 64'h7ff0000000000000 : 32'h7f800000;
  localparam INFINITY_N = (BUS_WIDTH == 64) ? 64'hfff0000000000000 : 32'hff800000;
  localparam ZERO = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;

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


  //wire [BUS_WIDTH-1:0] temp1 = {11'b0, |E_1, M_1};
  //wire [BUS_WIDTH-1:0] temp2 = {11'b0, |E_2, M_2};


  // Adding exponnts E_1, E_2 and subtracting bias
  wire [EXPONENT_SIZE:0] exponent_1 = {PAD_ZERO, E_1} + {PAD_ZERO, E_2};
  wire [EXPONENT_SIZE:0] exponent_2 = exponent_1 - BIAS;

  // Multiplying mantissas M_1 and M_2
  wire [2*MANTISSA_SIZE + 1:0] mantissa_product = {PRODUCT_PAD, LEADING_ONE, M_1} * {PRODUCT_PAD, LEADING_ONE, M_2};

  // Normalizing mantissa (LSB, Guard, Round, Sticky)
  // Round to nearest even has been followed
  // Also setting LSB, Guard, Round, Sticky bits
  wire [52:0] mantissa_normalized = (mantissa_product[2*MANTISSA_SIZE+1])?mantissa_product[2*MANTISSA_SIZE+1:MANTISSA_SIZE+1]:mantissa_product[2*MANTISSA_SIZE:MANTISSA_SIZE];
  wire L = (mantissa_product[2*MANTISSA_SIZE+1]) ? mantissa_product[MANTISSA_SIZE+1] : mantissa_product[MANTISSA_SIZE];
  wire G = (mantissa_product[2*MANTISSA_SIZE+1]) ? mantissa_product[MANTISSA_SIZE] : mantissa_product[MANTISSA_SIZE-1];
  wire R = (mantissa_product[2*MANTISSA_SIZE+1]) ? mantissa_product[MANTISSA_SIZE-1] : mantissa_product[MANTISSA_SIZE-2];
  wire S = (mantissa_product[2*MANTISSA_SIZE+1]) ? |mantissa_product[MANTISSA_SIZE-2:0] : |mantissa_product[MANTISSA_SIZE-3:0];

  // Updating exponent (if needed) after normalizing
  wire [EXPONENT_SIZE:0] exponent_3 = exponent_2 + (mantissa_product[2*MANTISSA_SIZE+1] ? EXPONENT_INC : EXPONENT_NO_CHANGE);

  // To add up or not to reach nearest even

  //wire round = (G & (R | S)) | (L& G & (~R) & (~S));
  //wire round = G & (L | R | S);
  wire round = (G & (L | R | S));


  wire [BUS_WIDTH:0] mantissa_rounded_cout = {PAD_2, mantissa_normalized} + (round ? {PRODUCT_PAD, ~PAD_ZERO} : {PRODUCT_PAD, PAD_ZERO});

  // Renormalizing
  wire [BUS_WIDTH-1:0] mantissa_rounded = mantissa_rounded_cout[BUS_WIDTH-1:0];
  wire cout = mantissa_rounded_cout[BUS_WIDTH];
  // Updating exponent value after renormalizing
  wire [EXPONENT_SIZE:0] exponent_4 = exponent_3 + ((cout) ? EXPONENT_INC : EXPONENT_NO_CHANGE);
  wire [MANTISSA_SIZE-1:0] mantissa_renormalized = (cout) ? mantissa_rounded[MANTISSA_SIZE:1] : mantissa_rounded[MANTISSA_SIZE-1:0];

  // Checking exponent overflow
  //wire exp_overflow = (exponent_4 >= 12'd2047);
  wire exp_overflow = (exponent_4[EXPONENT_SIZE-1:0] >= 2 * BIAS + 1) & ~exponent_4[EXPONENT_SIZE];

  wire exp_underflow = exponent_4[EXPONENT_SIZE];

  // Checking A, B for infinities
  wire is_inf_1 = (E_1 == IS_INFINITY) && ~(|M_1);
  wire is_inf_2 = (E_2 == IS_INFINITY) && ~(|M_2);

  wire is_nan_1 = (E_1 == IS_INFINITY) && (|M_1);
  wire is_nan_2 = (E_2 == IS_INFINITY) && (|M_2);

  wire is_zero_1 = ~|in1[BUS_WIDTH-2:0];
  wire is_zero_2 = ~|in2[BUS_WIDTH-2:0];

  wire is_NaN = is_nan_1 | is_nan_2;
  wire is_inf = ((is_inf_1 | is_inf_2) & ~is_NaN) | exp_overflow;

  // Checking for multiplication by 0
  wire is_zero = (is_zero_1 | is_zero_2) & (~is_NaN) & (~is_inf);

  wire [BUS_WIDTH-1:0] out_1 = {S_1 ^ S_2, exponent_4[EXPONENT_SIZE-1:0], mantissa_renormalized};

  wire [BUS_WIDTH-1:0] out_2 = NAN;  // NaN
  //wire [BUS_WIDTH-1:0] out_3 = (is_inf_1)?((S_1)?(64'hFFF0000000000000):(64'h7FF0000000000000)):((is_inf_2)?((S_2)?(64'hFFF0000000000000):(64'h7FF0000000000000)):(64'b1));  // infinity
  wire [BUS_WIDTH-1:0] out_3 = (S_1 ^ S_2) ? INFINITY_N : INFINITY_P;
  //{S_1 ^ S_2, 11'h7FF, 52'h0};


  assign out = ((is_zero) ? (ZERO) : ((is_NaN) ? (out_2) : ((is_inf) ? (out_3) : (out_1))));

  /*
  // Final exponent and mantissa values
  assign out[MANTISSA_SIZE-1:0] = mantissa_renormalized;
  assign out[62:52] = exponent_4[10:0];
  assign out[BUS_WIDTH-1] = S_1 ^ S_2;
  */

endmodule