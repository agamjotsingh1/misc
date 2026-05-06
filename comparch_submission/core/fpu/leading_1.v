module leading_1 #(
    parameter BUS_WIDTH = 64,
    parameter INDEX_MAX = 11
) (
    input [BUS_WIDTH-1:0] num,
    output reg [INDEX_MAX-1:0] index
);

  localparam INDEX_INIT = 11'd0;
  localparam NOT_FOUND = 1'b0;

  integer i;
  reg found;

  always @(*) begin
    index = 11'd0;
    found = NOT_FOUND;

    for (i = BUS_WIDTH - 1; i >= 0; i = i - 1) begin
      if (!found && num[i]) begin
        index = i[INDEX_MAX-1:0];
        found = ~NOT_FOUND;
      end
    end
  end
endmodule
