module mem_wb_reg #(
    parameter BUS_WIDTH=64,
    parameter INSTR_WIDTH=32,
    parameter REGFILE_LEN=6
)(
    input wire clk,
    input wire rst,
    input wire stall,

    // ------ INPUTS ------

    // Control Pins
    input wire in_reg_write, 
    input wire in_mem_to_reg,

    // REGFILE Outputs
    input wire [(REGFILE_LEN - 1):0] in_rd,


    input wire [(BUS_WIDTH - 1):0] in_mem_out, // trippy, but its an input
    input wire [(BUS_WIDTH - 1):0] in_write_data,

    // ------ OUTPUTS ------

    // Control Pouts
    output wire out_reg_write, 
    output wire out_mem_to_reg,

    // REGFILE Outputs
    output wire [(REGFILE_LEN - 1):0] out_rd,

    output wire [(BUS_WIDTH - 1):0] out_mem_out, // trippy again, but its an output
    output wire [(BUS_WIDTH - 1):0] out_write_data
);
    // Control Pins
    reg reg_write; 
    reg mem_to_reg;

    reg [(REGFILE_LEN - 1):0] rd;

    reg [(BUS_WIDTH - 1):0] mem_out;
    reg [(BUS_WIDTH - 1):0] write_data;

    always @(posedge clk) begin
        if(rst) begin
            reg_write <= 1'b0;
            mem_to_reg <= 1'b0;
            rd <= 1'b0;

            mem_out <= {BUS_WIDTH{1'b0}};
            write_data <= {BUS_WIDTH{1'b0}};
        end
        else if(~stall) begin
            // Control Pins
            reg_write <= in_reg_write;
            mem_to_reg <= in_mem_to_reg;
            
            rd <= in_rd;

            mem_out <= in_mem_out;
            write_data <= in_write_data;
        end
    end

    // Control Pins
    assign out_reg_write = reg_write;
    assign out_mem_to_reg = mem_to_reg;

    assign out_rd = rd;

    assign out_mem_out = mem_out;
    assign out_write_data = write_data;
endmodule