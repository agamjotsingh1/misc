module mantissa_normalize #(
    parameter MANTISSA_SIZE = 52,
    parameter EXPONENT_SIZE = 11,
    parameter BUS_WIDTH = 64
) (
    input wire [2*BUS_WIDTH -1:0] mantissa_product,
    input wire [EXPONENT_SIZE:0] exponent_init,
    output wire [BUS_WIDTH-1:0] mantissa_normalized,
    output wire round,
    output wire [EXPONENT_SIZE:0] exponent_modified
);

  // ---- Generating lead_index via MUX tree ----
  localparam SHIFT_SIZE_MAX = 7;
  localparam SHIFT_INIT = 7'd0;
  localparam NO_ROUND = 1'b0;
  reg [SHIFT_SIZE_MAX-1:0] lead_index;
  integer i;

  always @* begin
    lead_index = SHIFT_INIT;
    for (i = 0; i < 2 * BUS_WIDTH; i = i + 1) begin
      if (mantissa_product[i]) lead_index = i;
    end
  end

  // Finding shift direction, shifting accordingly
  wire left_shift = (lead_index < MANTISSA_SIZE);
  wire [2*BUS_WIDTH-1:0] if_left_shifted = mantissa_product << (MANTISSA_SIZE - lead_index);
  wire [2*BUS_WIDTH-1:0] if_right_shifted = mantissa_product << (lead_index - MANTISSA_SIZE);
  wire [EXPONENT_SIZE:0] shift_amt = (left_shift) ? (MANTISSA_SIZE - lead_index) : (lead_index - MANTISSA_SIZE);
  // Updating exponent
  assign exponent_modified = (left_shift)?(exponent_init - shift_amt):(exponent_init + shift_amt);

  // To round or to not round that is the question
  // Again, following RTNE (rount to nearest integer)
  // Calculated using kmaps made from LSB, Guard, ROund, Sticky bits
  wire L = mantissa_product[BUS_WIDTH];
  wire G = mantissa_product[BUS_WIDTH-1];
  wire R = mantissa_product[BUS_WIDTH-2];
  wire S = |mantissa_product[BUS_WIDTH-3];

  assign round = (left_shift) ? (NO_ROUND) : (G & (R | S)) | (L & G & (~R) & (~S));
  assign mantissa_normalized = (left_shift)?(mantissa_product << shift_amt):(mantissa_product >> shift_amt);

endmodule
