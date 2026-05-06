module alu #(
    parameter BUS_WIDTH=64,
    parameter ALU_CONTROL_WIDTH=2,
    parameter ALU_SELECT_WIDTH=3
)(
    input wire clk, // for multicycle division

    input wire [(BUS_WIDTH - 1):0] in1,
    input wire [(BUS_WIDTH - 1):0] in2,

    // ALUOp
    input wire [(ALU_CONTROL_WIDTH - 1):0] control,
    input wire [(ALU_SELECT_WIDTH - 1):0] select,
    output reg [(BUS_WIDTH - 1):0] out
);
    wire [(BUS_WIDTH - 1):0] addsub_out;
    wire [(BUS_WIDTH - 1):0] mul_out;
    wire [(BUS_WIDTH - 1):0] div_out;
    wire [(BUS_WIDTH - 1):0] shift_left_out;
    wire [(BUS_WIDTH - 1):0] shift_right_out;
    wire [(BUS_WIDTH - 1):0] xor_out;
    wire [(BUS_WIDTH - 1):0] or_out;
    wire [(BUS_WIDTH - 1):0] and_out;

    addsub #(
        .BUS_WIDTH(BUS_WIDTH)
    ) addsub_instance (
        .in1(in1),
        .in2(in2),
        .control(control),
        .out(addsub_out)
    );

    mul #(
        .BUS_WIDTH(BUS_WIDTH),
        .ALU_CONTROL_WIDTH(ALU_CONTROL_WIDTH)
    ) mul_instance (
        .in1(in1),
        .in2(in2),
        .control(control),
        .out(mul_out)
    );

    div #(
        .BUS_WIDTH(BUS_WIDTH),
        .ALU_CONTROL_WIDTH(ALU_CONTROL_WIDTH)
    ) div_instance (
        .clk(clk),
        .in1(in1),
        .in2(in2),
        .control(control),
        .out(div_out)
    );
    
    shift_left #(
        .BUS_WIDTH(BUS_WIDTH)
    ) shift_left_instance (
        .in(in1),
        .amt(in2[($clog2(BUS_WIDTH) - 1):0]),
        .out(shift_left_out)
    );

    shift_right #(
        .BUS_WIDTH(BUS_WIDTH)
    ) shift_right_instance (
        .in(in1),
        .amt(in2[($clog2(BUS_WIDTH) - 1):0]),
        .control(control[0]),
        .out(shift_right_out)
    );

    _xor #(
        .BUS_WIDTH(BUS_WIDTH)
    ) xor_instance (
        .in1(in1),
        .in2(in2),
        .out(xor_out)
    );

    _or #(
        .BUS_WIDTH(BUS_WIDTH)
    ) or_instance (
        .in1(in1),
        .in2(in2),
        .out(or_out)
    );

    _and #(
        .BUS_WIDTH(BUS_WIDTH)
    ) and_instance (
        .in1(in1),
        .in2(in2),
        .out(and_out)
    );

    always @(*) begin
        case (select)
            3'b000: out = addsub_out;
            3'b001: out = mul_out;
            3'b010: out = div_out;
            3'b011: out = shift_left_out;
            3'b100: out = shift_right_out;
            3'b101: out = xor_out;
            3'b110: out = or_out;
            3'b111: out = and_out;
            default: out = {BUS_WIDTH{1'b0}};
        endcase
    end
endmodule