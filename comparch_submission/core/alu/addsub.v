module addsub #(
    parameter BUS_WIDTH=64
)(
    input wire [(BUS_WIDTH - 1):0] in1,
    input wire [(BUS_WIDTH - 1):0] in2,

    /*
       00 -> add
       01 -> sub
       10 -> slt (set less than)
       11 -> sltu (set less than)
    */
    input wire [1:0] control,
    output reg [(BUS_WIDTH - 1):0] out
);
    always @(*) begin
        casez (control)
            2'b00: out = in1 + in2;
            2'b01: out = in1 - in2;
            2'b10: out = {{(BUS_WIDTH - 1){1'b0}}, $signed(in1) < $signed(in2)};
            2'b11: out = {{(BUS_WIDTH - 1){1'b0}}, $unsigned(in1) < $unsigned(in2)};
            default: out = {BUS_WIDTH{1'b0}};
        endcase
    end
endmodule