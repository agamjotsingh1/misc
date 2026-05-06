module _and #(
    parameter BUS_WIDTH=64
)(
    input wire [(BUS_WIDTH - 1):0] in1,
    input wire [(BUS_WIDTH - 1):0] in2,
    output wire [(BUS_WIDTH - 1):0] out
);
    assign out = in1 & in2;
endmodule