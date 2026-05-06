module FPDiv #(
    parameter BUS_WIDTH = 64
) (
    input clk,
    input rst,
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
  localparam ROUND_UP = (BUS_WIDTH == 64) ? 64'd1 : 32'd1;
  localparam ROUND_DOWN = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;
  localparam EXPONENT_INC = (BUS_WIDTH == 64) ? 12'd1 : 9'd1;
  localparam EXPONENT_NO_CHANGE = (BUS_WIDTH == 64) ? 12'd0 : 9'd0;
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

  // Subtracting exponnts E_1, E_2 then adding bias
  wire [EXPONENT_SIZE:0] exponent_1 = E_1 - E_2;
  wire [EXPONENT_SIZE:0] exponent_2 = exponent_1 + BIAS;


  // Dividing M_1 and M_2
  wire [2*BUS_WIDTH-1:0] mantissa_pre_product;
  //wire [2*BUS_WIDTH-1:0] mantissa_product = (({LEADING_ONE, M_1}) << MANTISSA_SIZE) / ({LEADING_ONE, M_2});

/*
  wire [2*BUS_WIDTH-1:0] dividend = ({LEADING_ONE, M_1} << MANTISSA_SIZE);
  wire [BUS_WIDTH-1:0] divisor = {LEADING_ONE, M_2};
  wire [BUS_WIDTH-1:0] q1;
  wire [BUS_WIDTH-1:0] r1;

    if(BUS_WIDTH == 64) begin
        div_unsigned_gen div_unsigned_instance_low (
            .aclk(clk),
            .s_axis_divisor_tvalid(1'b1),
            .s_axis_divisor_tdata(divisor),
            .s_axis_dividend_tvalid(1'b1),
            .s_axis_dividend_tdata(dividend[BUS_WIDTH-1:0]),
            .m_axis_dout_tdata(mantissa_pre_product[BUS_WIDTH-1:0])
        );

        div_unsigned_gen div_unsigned_instance_high (
            .aclk(clk),
            .s_axis_divisor_tvalid(1'b1),
            .s_axis_divisor_tdata(divisor),
            .s_axis_dividend_tvalid(1'b1),
            .s_axis_dividend_tdata(dividend[2*BUS_WIDTH-1:BUS_WIDTH]),
            .m_axis_dout_tdata(mantissa_pre_product[2*BUS_WIDTH-1:BUS_WIDTH])
        );
    end
    else if(BUS_WIDTH == 32) begin
        div_unsigned32_gen div_unsigned_instance_low (
            .aclk(clk),
            .s_axis_divisor_tvalid(1'b1),
            .s_axis_divisor_tdata(divisor),
            .s_axis_dividend_tvalid(1'b1),
            .s_axis_dividend_tdata(dividend[BUS_WIDTH-1:0]),
            .m_axis_dout_tdata(mantissa_pre_product)
        );

        div_unsigned32_gen div_unsigned_instance_high (
            .aclk(clk),
            .s_axis_divisor_tvalid(1'b1),
            .s_axis_divisor_tdata(divisor),
            .s_axis_dividend_tvalid(1'b1),
            .s_axis_dividend_tdata(dividend[2*BUS_WIDTH-1:BUS_WIDTH]),
            .m_axis_dout_tdata(mantissa_pre_product[2*BUS_WIDTH-1:BUS_WIDTH])
        );
    end*/


  wire [BUS_WIDTH-1:0] q1;
  wire [BUS_WIDTH-1:0] r1;

  wire [2*BUS_WIDTH-1:0] mantissa_product = mantissa_pre_product;

  // Normalizing mantissa, updating exponent (if needed)
  wire [BUS_WIDTH-1:0] mantissa_normalized;
  wire round;
  wire [EXPONENT_SIZE:0] exponent_3;

  mantissa_normalize #(
      .MANTISSA_SIZE(MANTISSA_SIZE),
      .EXPONENT_SIZE(EXPONENT_SIZE),
      .BUS_WIDTH(BUS_WIDTH)
  ) FPdiv_normalize (
      .mantissa_product(mantissa_product),
      .exponent_init(exponent_2),
      .mantissa_normalized(mantissa_normalized),
      .round(round),
      .exponent_modified(exponent_3)
  );

  // Rounding
  wire [MANTISSA_SIZE:0] mantissa_normalized_shifted;
  assign mantissa_normalized_shifted = mantissa_normalized[MANTISSA_SIZE:0];
  wire [BUS_WIDTH-1:0] mantissa_rounded = mantissa_normalized + ((round) ? (ROUND_UP) : (ROUND_DOWN));

  // Renormalizing
  wire [MANTISSA_SIZE-1:0] mantissa_renormalized = (mantissa_rounded[MANTISSA_SIZE+1]) ? mantissa_rounded[MANTISSA_SIZE:1] : mantissa_rounded[MANTISSA_SIZE-1:0];
  // Updating exponent (if needed) after normalizing
  wire [EXPONENT_SIZE:0] exponent_4 = exponent_3 + ((mantissa_rounded[MANTISSA_SIZE+1]) ? EXPONENT_INC : EXPONENT_NO_CHANGE);


  // Checking exponent overflow
  wire exp_overflow = (exponent_4 >= 2 * BIAS + 1);
  wire exp_underflow = exponent_4[EXPONENT_SIZE] | (|exponent_4);

  // Checking A, B for infinities
  wire is_inf_1 = (E_1 == IS_INFINITY) && ~(|M_1);
  wire is_inf_2 = (E_2 == IS_INFINITY) && ~(|M_2);

  wire is_NaN = (is_inf_1 & is_inf_2) | (~(|E_1) & ~(|E_2));
  wire is_inf = ~is_NaN & (is_inf_1 | ~(|in2[BUS_WIDTH-2:0]) | exp_overflow);


  //(is_inf_1 & |E_2) | (is_inf_2 & |E_1);  // 0 * infinity
  // Checking for multiplication by 0

  wire is_zero = ~is_NaN & (~(|in1[BUS_WIDTH-2:0]) & (|in2[BUS_WIDTH-2:0]));
  //(~(|E_1)) | (~(|E_2)) | exp_underflow;


  wire [BUS_WIDTH-1:0] out_1 = {S_1 ^ S_2, exponent_4[EXPONENT_SIZE-1:0], mantissa_renormalized};

  wire [BUS_WIDTH-1:0] out_2 = NAN;  // NaN
  wire [BUS_WIDTH-1:0] out_3 = (S_1 ^ S_2) ? INFINITY_N : INFINITY_P;
  assign out = (is_zero) ? (ZERO) : ((is_NaN) ? (out_2) : ((is_inf) ? (out_3) : (out_1)));
endmodule