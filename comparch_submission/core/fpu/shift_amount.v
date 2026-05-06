module shift_amount #(
    parameter MANTISSA_SIZE = 52,
    parameter EXPONENT_SIZE = 11,
    parameter BUS_WIDTH = 64,
    parameter SHIFT_MAX = 7
) (
    input [MANTISSA_SIZE+1:0] A,
    input add,
    output [SHIFT_MAX-1:0] shift_amoont
);

  localparam SHIFT_ADD_1 = 7'd1;
  localparam SHIFT_ADD_0 = 7'd0;
  localparam NOT_FOUND = 1'b0;
  localparam SHIFT_INIT = 7'd53;
  // For the case of Adddition
  wire [SHIFT_MAX-1:0] shift_amount_2 = (A[MANTISSA_SIZE+1]) ? SHIFT_ADD_1 : SHIFT_ADD_0;

  reg [SHIFT_MAX-1:0] shift_amount_1;
  integer i;
  reg found;

  always @(*) begin
    shift_amount_1 = SHIFT_INIT;
    found = NOT_FOUND;

    // Scan from MSB down to LSB
    for (i = MANTISSA_SIZE; i >= 0; i = i - 1) begin
      if (!found && A[i]) begin
        shift_amount_1 = MANTISSA_SIZE - i;
        found = ~NOT_FOUND;  // stop updating after first 1
      end
    end
  end
  // For the case of Subtraction
  // Finding leading 1
  // Accordingly setting shift amount
  assign shift_amoont = (add) ? shift_amount_2 : shift_amount_1;
endmodule
