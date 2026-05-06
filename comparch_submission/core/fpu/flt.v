module FLT #(
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

  localparam IS_NAN = (BUS_WIDTH == 64) ? 11'h7FF : 8'hFF;
  localparam NAN = (BUS_WIDTH == 64) ? 64'h7ff8000000000000 : 32'h7fc00000;
  localparam LESSER = (BUS_WIDTH == 64) ? 64'd1 : 32'd1;
  localparam GREATER_EQUAL = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;
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


  wire [BUS_WIDTH-1:0] max;
  FPMax #(
      .BUS_WIDTH(BUS_WIDTH)
  ) flt (
      .in1(in1),
      .in2(in2),
      .out(max)
  );

  wire is_nan_A = (E_1 == IS_NAN & |M_1);
  wire is_nan_B = (E_2 == IS_NAN & |M_2);
  wire is_nan = is_nan_A | is_nan_B;

  wire both_zero = ~|{in1[BUS_WIDTH-2:0], in2[BUS_WIDTH-2:0]};
  wire eq = (in1 == in2) | both_zero;
  assign out = (eq | is_nan) ? (GREATER_EQUAL) : ((max == in1) ? (GREATER_EQUAL) : LESSER);

  //assign out = (in1 == in2) ? EQUAL : NOT_EQUAL;
endmodule
