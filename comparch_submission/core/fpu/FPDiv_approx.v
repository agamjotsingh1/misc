// STALL REQUIREMENT = 10
module FPDiv_approx #(
    parameter BUS_WIDTH = 64
) (
    input  wire                    clk,
    input  wire                    rst,
    input  wire [BUS_WIDTH-1:0]    in1,
    input  wire [BUS_WIDTH-1:0]    in2,
    output wire [BUS_WIDTH-1:0]    out
);
  localparam MANTISSA_SIZE = (BUS_WIDTH == 64) ? 52 : 23;
  localparam EXPONENT_SIZE = (BUS_WIDTH == 64) ? 11 : 8;
  localparam BIAS = (BUS_WIDTH == 64) ? 1023 : 127;
  localparam IS_INFINITY = (BUS_WIDTH == 64) ? 11'h7FF : 8'hFF;
  localparam NAN = (BUS_WIDTH == 64) ? 64'h7ff8000000000000 : 32'h7fc00000;
  localparam INFINITY_P = (BUS_WIDTH == 64) ? 64'h7ff0000000000000 : 32'h7f800000;
  localparam INFINITY_N = (BUS_WIDTH == 64) ? 64'hfff0000000000000 : 32'hff800000;
  localparam ZERO = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;

  // =======================================
  // STAGE 0: b^2
  // =======================================

  wire [BUS_WIDTH-1:0] divisor_sq_comb;
  FPMul #(BUS_WIDTH) mul_sq (
      .in1(in2),
      .in2(in2),
      .out(divisor_sq_comb)
  );

  // Pipeline register between FPMul and quake3  <<< ADDED >>>
  reg [BUS_WIDTH-1:0] divisor_sq;
  always @(posedge clk) begin
      if (rst)
          divisor_sq <= 0;
      else
          divisor_sq <= divisor_sq_comb;
  end

  // =======================================
  // STAGE 1: quake3 → 1/|b| → sign fix
  // =======================================

  wire [BUS_WIDTH-1:0] inv_abs_divisor;
  quake3 #(BUS_WIDTH) quake (
      .clk(clk),
      .rst(rst),
      .x(divisor_sq),           // <<< now uses registered value
      .y(inv_abs_divisor)
  );

  wire [BUS_WIDTH-1:0] inv_divisor_comb;
  assign inv_divisor_comb = {S_2, inv_abs_divisor[BUS_WIDTH-2:0]};

  /*
  // =======================================
  // STAGE 1: b^2 → quake3 → 1/|b| → sign fix
  // =======================================

  wire [BUS_WIDTH-1:0] divisor_sq;
  FPMul #(BUS_WIDTH) mul_sq (
      .in1(in2),
      .in2(in2),
      .out(divisor_sq)
  );

  wire [BUS_WIDTH-1:0] inv_abs_divisor;
  quake3 #(BUS_WIDTH) quake (
      .x(divisor_sq),
      .y(inv_abs_divisor)
  );

  wire [BUS_WIDTH-1:0] inv_divisor_comb;
  assign inv_divisor_comb = {S_2, inv_abs_divisor[BUS_WIDTH-2:0]};
  */

  // Pipeline registers (Stage 1 → Stage 2)
  reg [BUS_WIDTH-1:0] r_in1;
  reg [BUS_WIDTH-1:0] r_in2;
  reg [BUS_WIDTH-1:0] r_invdiv;

  always @(posedge clk) begin
      if(rst) begin
        r_in1    <= 0;
        r_in2    <= 0;
        r_invdiv <= 0;
      end
      else begin
        r_in1    <= in1;
        r_in2    <= in2;
        r_invdiv <= inv_divisor_comb;
      end
  end

  // =======================================
  // STAGE 2: Multiply a * (1/b)
  // =======================================

  wire [MANTISSA_SIZE-1:0] M_1 = r_in1[MANTISSA_SIZE-1:0];
  wire [MANTISSA_SIZE-1:0] M_2 = r_in2[MANTISSA_SIZE-1:0];
  wire [EXPONENT_SIZE-1:0] E_1 = r_in1[BUS_WIDTH-2:MANTISSA_SIZE];
  wire [EXPONENT_SIZE-1:0] E_2 = r_in2[BUS_WIDTH-2:MANTISSA_SIZE];
  wire S_1 = r_in1[BUS_WIDTH-1];
  wire S_2 = r_in2[BUS_WIDTH-1];

  wire [BUS_WIDTH-1:0] out_1;
  FPMul #(BUS_WIDTH) mul_final (
      .in1(r_in1),
      .in2(r_invdiv),
      .out(out_1)
  );

  // ===========================
  // Special case detection
  // ===========================

  wire is_inf_1 = (E_1 == IS_INFINITY) && ~(|M_1);
  wire is_inf_2 = (E_2 == IS_INFINITY) && ~(|M_2);
  wire is_nan_1 = (E_1 == IS_INFINITY) && (|M_1);
  wire is_nan_2 = (E_2 == IS_INFINITY) && (|M_2);
  wire is_zero_1 = ~(|in1[BUS_WIDTH-2:0]);
  wire is_zero_2 = ~(|in2[BUS_WIDTH-2:0]);

  wire [EXPONENT_SIZE-1:0] exp_result = out_1[BUS_WIDTH-2:MANTISSA_SIZE];
  wire exp_overflow = (exp_result == IS_INFINITY);
  wire exp_underflow = ~(|exp_result) && ~(|out_1[MANTISSA_SIZE-1:0]);

  wire is_NaN = (is_zero_1 & is_zero_2) | (is_inf_1 & is_inf_2) | is_nan_1 | is_nan_2;
  wire is_inf = ~is_NaN &
                (is_inf_1 | (is_zero_2 & ~is_zero_1) | exp_overflow);
  wire is_zero = ~is_NaN &
                 ((is_zero_1 & ~is_zero_2) | (is_inf_2 & ~is_inf_1) | exp_underflow);

  wire [BUS_WIDTH-1:0] out_inf = (S_1 ^ S_2) ? INFINITY_N : INFINITY_P;

  // Final output
  assign out = is_NaN ? NAN :
               is_inf ? out_inf :
               is_zero ? ZERO :
               out_1;

endmodule