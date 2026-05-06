module if_id_reg #(
    parameter BUS_WIDTH=64,
    parameter INSTR_WIDTH=32
)(
    input wire clk,
    input wire rst,
    input wire stall,

    input wire [(BUS_WIDTH - 1):0] in_pc,
    input wire [(INSTR_WIDTH - 1):0] in_instr,

    output wire [(BUS_WIDTH - 1):0] out_pc,
    output wire [(INSTR_WIDTH - 1):0] out_instr
);
    reg [(BUS_WIDTH - 1):0] pc;
    reg [(INSTR_WIDTH - 1):0] instr;

    always @(posedge clk) begin
        if(rst) begin
            pc <= {BUS_WIDTH{1'b0}};
            instr <= {INSTR_WIDTH{1'b0}};
        end
        else if(~stall) begin 
            pc <= in_pc;
            instr <= in_instr;
        end
    end

    assign out_pc = pc;
    assign out_instr = instr;
endmodule