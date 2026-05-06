module FPSub #(
    parameter BUS_WIDTH = 64
) (
    input  [BUS_WIDTH-1:0] in1,
    input  [BUS_WIDTH-1:0] in2,
    output [BUS_WIDTH-1:0] out
);
  wire[BUS_WIDTH-1:0] NEGATE = (BUS_WIDTH == 64) ? 64'h8000000000000000 : 32'h80000000;
  FPAdder #(
      .BUS_WIDTH(BUS_WIDTH)
  ) FP_subtraction (
      .in1(in1),
      .in2(in2 ^ NEGATE),
      .out(out)
  );
endmodule
