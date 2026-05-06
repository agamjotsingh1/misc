module FSGNJN #(
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

  //wire is_nan_B = (E_2 == IS_NAN & |M_2);

  //assign out = (is_nan_B) ? (in1) : {~S_2, in1[BUS_WIDTH-2:0]};
  assign out = {~S_2, in1[BUS_WIDTH-2:0]};
endmodule
