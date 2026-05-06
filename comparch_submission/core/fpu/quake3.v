// STALL REQUIREMENT = 8
module quake3 #(
    parameter BUS_WIDTH = 64
) (
    input clk,
    input rst,
    input  [BUS_WIDTH-1:0] x,
    output [BUS_WIDTH-1:0] y
);
  localparam MAGIC_NUMBER = (BUS_WIDTH == 64) ? 64'h5FE6EB50C7B537A9 : 32'h5f3759df;
  wire [BUS_WIDTH-1:0] y_1 = (MAGIC_NUMBER) - (x >> 1'b1);
  wire [BUS_WIDTH-1:0] y_nr_1;
  wire [BUS_WIDTH-1:0] y_nr_2;

  newton_ralphson #(
      .BUS_WIDTH(BUS_WIDTH)
  ) nr_1 (
      .clk(clk),
      .rst(rst),
      .x(x),
      .y(y_1),
      .y_nr(y_nr_1)
  );

  // Switch this on for increased accuracy but much more hardware
  /*newton_ralphson #(
      .BUS_WIDTH(BUS_WIDTH)
  ) nr_2 (
      .clk(clk),
      .rst(rst),
      .x(x),
      .y(y_nr_1),
      .y_nr(y_nr_2)
  );*/

  assign y = y_nr_1;
endmodule