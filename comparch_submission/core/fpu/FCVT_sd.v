module FCVT_S_D #(
    parameter BUS_WIDTH = 64,
    parameter INPUT_WIDTH = 32,
    parameter OUTPUT_WIDTH = 64
) (
    input  [ INPUT_WIDTH-1:0] in1,
    output [OUTPUT_WIDTH-1:0] out
);

  // Main parameters
  localparam INPUT_MANTISSA_SIZE = 23;
  localparam OUTPUT_MANTISSA_SIZE = 52;
  localparam INPUT_EXPONENT_SIZE = 8;
  localparam OUTPUT_EXPONENT_SIZE = 11;
  localparam INPUT_BIAS = 127;
  localparam OUTPUT_BIAS = 1023;

  // localparam EXPONENT_SIZE = (BUS_WIDTH == 64) ? 11 : 8;
  // localparam BIAS = (BUS_WIDTH == 64) ? 1023 : 127;

  // Other non-important parameters
  localparam LEADING_ONE = (BUS_WIDTH == 64) ? 12'd1 : 9'd1;
  localparam PRODUCT_PAD = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;
  localparam ROUND_UP = (BUS_WIDTH == 64) ? 64'd1 : 32'd1;
  localparam PAD_ZERO = 1'b0;
  localparam ROUND_DOWN = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;
  localparam EXPONENT_INC = (BUS_WIDTH == 64) ? 12'd1 : 9'd1;
  localparam EXPONENT_NO_CHANGE = (BUS_WIDTH == 64) ? 12'd0 : 9'd0;
  localparam PAD_2 = (BUS_WIDTH == 64) ? 12'd0 : 9'd0;
  localparam IS_INFINITY = 8'hFF;
  localparam ZERO_IN = 31'd0;
  localparam ZERO_OUT = 63'd0;
  localparam ROUND_PAD = 32'd0;
  //8'hFF;
  localparam NAN_IN = 32'h7fc00000;
  localparam NAN_OUT = 64'h7ff8000000000000;
  localparam INFINITY_P_IN = 32'h7f800000;
  localparam INFINITY_N_IN = 32'hff800000;
  localparam INFINITY_P_OUT = 64'h7ff0000000000000;
  localparam INFINITY_N_OUT = 64'hfff0000000000000;
  localparam MANTISSA_PAD = 29'd0;


  // Extracting Sign, Exponent, Mantissa
  wire [INPUT_MANTISSA_SIZE-1:0] M_1;
  wire [OUTPUT_MANTISSA_SIZE-1:0] M_2;
  wire [INPUT_EXPONENT_SIZE-1:0] E_1;
  wire [OUTPUT_EXPONENT_SIZE-1:0] E_2;
  wire S_1;
  wire S_2;
  assign M_1 = in1[INPUT_MANTISSA_SIZE-1:0];

  assign E_1 = in1[INPUT_WIDTH-2:INPUT_MANTISSA_SIZE];

  assign S_1 = in1[INPUT_WIDTH-1];


  wire is_inf_P = in1 == INFINITY_P_IN;
  wire is_inf_N = in1 == INFINITY_N_IN;
  wire is_nan = (E_1 == IS_INFINITY) & (|M_1);
  wire is_zero = ({E_1, M_1} == ZERO_IN);
  wire [OUTPUT_WIDTH-1:0] zero_op = {S_1, ZERO_OUT};


  wire [OUTPUT_WIDTH-1:0] overflow_rs = (S_1) ? (INFINITY_N_OUT) : (INFINITY_P_OUT);

  assign E_2 = E_1 - INPUT_BIAS + OUTPUT_BIAS;
  assign M_2 = {M_1, MANTISSA_PAD};

  wire [OUTPUT_WIDTH-1:0] normal_res = {S_1, E_2, M_2};

  assign out = (is_zero) ? (zero_op) : ((is_inf_P) ?(INFINITY_P_OUT) : ((is_inf_N) ? (INFINITY_N_OUT) : ((is_nan) ? (NAN_OUT) : ((normal_res)  ))));
endmodule
