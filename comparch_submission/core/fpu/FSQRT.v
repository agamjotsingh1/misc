// STALL REQUIREMENT = 10
module FSQRT #(
    parameter BUS_WIDTH = 32
) (
    input clk,
    input rst,
    input  [BUS_WIDTH-1:0] x,
    output [BUS_WIDTH-1:0] y
);
  // Main parameters
  localparam MANTISSA_SIZE = (BUS_WIDTH == 64) ? 52 : 23;
  localparam EXPONENT_SIZE = (BUS_WIDTH == 64) ? 11 : 8;
  localparam BIAS = (BUS_WIDTH == 64) ? 1023 : 127;

  wire [BUS_WIDTH-1:0] ONE = (BUS_WIDTH == 64) ? 64'h3ff0000000000000 : 32'h3f800000;
  localparam NAN = (BUS_WIDTH == 64) ? 64'h7ff8000000000000 : 32'h7fc00000;
  localparam INFINITY_P = (BUS_WIDTH == 64) ? 64'h7ff0000000000000 : 32'h7f800000;
  localparam INFINITY_N = (BUS_WIDTH == 64) ? 64'hfff0000000000000 : 32'hff800000;
  localparam ZERO = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;

  wire [BUS_WIDTH-1:0] y_1;
  wire [BUS_WIDTH-1:0] quotient;

  FPDiv_approx #(
      .BUS_WIDTH(BUS_WIDTH)
  ) FSQRT_div (
      .clk(clk),
      .rst(rst),
      .in1(ONE),
      .in2(x),
      .out(quotient)
  );

  quake3 #(
      .BUS_WIDTH(BUS_WIDTH)
  ) FSQRT_quake (
      .clk(clk),
      .rst(rst),
      .x(quotient),
      .y(y_1)
  );

  wire is_underflow = ~(|y_1[BUS_WIDTH-2:MANTISSA_SIZE]) & (|y_1[MANTISSA_SIZE-1:0]);
  wire is_inf = (x == INFINITY_P);
  wire is_zero = ~(|x[BUS_WIDTH-2:0]) | is_underflow;
  wire is_neg = x[BUS_WIDTH-1];

  assign y = (is_neg) ? (NAN) : (is_zero ? (ZERO) : (is_inf ? (INFINITY_P) : (y_1)));

endmodule