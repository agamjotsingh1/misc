module comparator #(
    parameter BUS_WIDTH=64
) (
    input wire [(BUS_WIDTH - 1):0] in1,
    input wire [(BUS_WIDTH - 1):0] in2,

    // BRANCH Flags
    output wire zero, // if in1 == in2, zero = 1, 0 otherwise
    output wire neg, // if in1 < in2, neg = 1, 0 otherwise
    output wire negu // unsigned in1 and in2
);
    assign zero = in1 == in2;
    assign neg = $signed(in1) < $signed(in2);
    assign negu = $unsigned(in1) < $unsigned(in2);
endmodule