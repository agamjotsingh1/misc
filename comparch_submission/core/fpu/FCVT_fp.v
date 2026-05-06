module FCVT_fp #(
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
  localparam PAD_ONE = (BUS_WIDTH == 64) ? 64'b1 : 32'b1;
  localparam EXP_PAD = (BUS_WIDTH == 64) ? 11'd0 : 8'd0;
  localparam MANTISSA_PAD = (BUS_WIDTH == 64) ? 52'd0 : 23'd0;
  localparam ZERO = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;
  localparam OHNE = 1'b1;

  // Checking sign
  wire S = in1[BUS_WIDTH-1];
  wire [BUS_WIDTH-1:0] mod = (S) ? (~in1 + PAD_ONE) : in1;

  // Finding leading 1
  wire [EXPONENT_SIZE-1:0] index;

  leading_1 #(
      .BUS_WIDTH(BUS_WIDTH)
  ) FCVT (
      .num  (mod),
      .index(index)
  );

  wire [EXPONENT_SIZE-1:0] idex = (|mod) ? (index) : (EXP_PAD);
  wire [EXPONENT_SIZE-1:0] E = idex + BIAS;
  wire [BUS_WIDTH-1:0] mantissa_shifted = mod << (BUS_WIDTH - 1 - index);
  //wire [MANTISSA_SIZE-1:0] M = (|mod) ? mantissa_shifted[BUS_WIDTH-2:EXPONENT_SIZE] : MANTISSA_PAD;
  wire is_zero = ~|in1[BUS_WIDTH-1:0];
  
  wire [MANTISSA_SIZE-1:0] M_init = (|mod) ? mantissa_shifted[BUS_WIDTH-2:EXPONENT_SIZE] : MANTISSA_PAD;

  // Extract bits for rounding
  wire [EXPONENT_SIZE-1:0] extra = mantissa_shifted[EXPONENT_SIZE-1:0];
  wire G = extra[EXPONENT_SIZE-1];
  wire R = extra[EXPONENT_SIZE-2];
  wire S = |extra[EXPONENT_SIZE-3:0];
  wire L = M_init[0];
    // Round to nearest, ties to even
  wire round = G & (R | S );

  wire [MANTISSA_SIZE:0] M_rounded = M_init + round; 

  wire [EXPONENT_SIZE-1:0] E_final = E + M_rounded[MANTISSA_SIZE];
  wire [MANTISSA_SIZE-1:0] M_final = M_rounded[MANTISSA_SIZE-1:0];
  
  assign out = (is_zero) ? ZERO : ({S, E_final, M_final});

endmodule
