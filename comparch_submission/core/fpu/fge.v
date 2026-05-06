
module FLE #(
    parameter BUS_WIDTH = 64
) (
    input  [BUS_WIDTH-1:0] in1,
    input  [BUS_WIDTH-1:0] in2,
    output [BUS_WIDTH-1:0] out
);
  localparam LESSER_EQUAL = (BUS_WIDTH == 64) ? 64'd1 : 32'd1;
  localparam GRATER = (BUS_WIDTH == 64) ? 64'd0 : 32'd0;

  wire [BUS_WIDTH-1:0] lt;
  wire [BUS_WIDTH-1:0] eq;

  FLT #(
      .BUS_WIDTH(BUS_WIDTH)
  ) fle_flt (
      .in1(in1),
      .in2(in2),
      .out(lt)
  );
  FEQ #(
      .BUS_WIDTH(BUS_WIDTH)
  ) fle_feq (
      .in1(in1),
      .in2(in2),
      .out(eq)
  );
  assign out = (lt[0] | eq[0]) ? LESSER_EQUAL : GRATER;
endmodule
