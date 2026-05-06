module shift_right #(
    parameter BUS_WIDTH=64
)(
    input wire signed [(BUS_WIDTH - 1):0] in,
    input wire [($clog2(BUS_WIDTH) - 1):0] amt,

    /* 0 -> logical shift
       1 -> arithmetic shift */
    input wire control,

    output wire [(BUS_WIDTH - 1):0] out
);
    assign out = control ? (in >>> amt): (in >> amt);
endmodule