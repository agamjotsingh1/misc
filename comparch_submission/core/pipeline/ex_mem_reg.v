module ex_mem_reg #(
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
    input wire in_mem_write,
    input wire in_mem_read,
    input wire in_mem_to_reg,
    input wire in_jalr_src,
    input wire in_u_src,
    input wire in_uj_src,

    // REGFILE Outputs
    input wire [(REGFILE_LEN - 1):0] in_rs1,
    input wire [(REGFILE_LEN - 1):0] in_rs2,
    input wire [(REGFILE_LEN - 1):0] in_rd,
    input wire [(INSTR_WIDTH - 1):0] in_instr,

    // IMMGEN output
    input wire [(BUS_WIDTH - 1):0] in_imm,

    input wire [(BUS_WIDTH - 1):0] in_pc,

    input wire [(BUS_WIDTH - 1):0] in_alu_fpu_result,
    input wire [(BUS_WIDTH - 1):0] in_mem_in,

    // ------ OUTPUTS ------

    // Control Pouts
    output wire out_reg_write, 
    output wire out_mem_write,
    output wire out_mem_read,
    output wire out_mem_to_reg,
    output wire out_jalr_src,
    output wire out_u_src,
    output wire out_uj_src,

    // REGFILE Outputs
    output wire [(REGFILE_LEN - 1):0] out_rs1,
    output wire [(REGFILE_LEN - 1):0] out_rs2,
    output wire [(REGFILE_LEN - 1):0] out_rd,

    // IMMGEN output
    output wire [(BUS_WIDTH - 1):0] out_imm,

    output wire [(BUS_WIDTH - 1):0] out_pc,
    output wire [(INSTR_WIDTH - 1):0] out_instr,
    output wire [(BUS_WIDTH - 1):0] out_alu_fpu_result,
    output wire [(BUS_WIDTH - 1):0] out_mem_in
);
    // Control Pins
    reg reg_write; 
    reg mem_write;
    reg mem_read;
    reg mem_to_reg;
    reg jalr_src;
    reg u_src;
    reg uj_src;

    // REGFILE Outputs
    reg [(REGFILE_LEN - 1):0] rs1;
    reg [(REGFILE_LEN - 1):0] rs2;
    reg [(REGFILE_LEN - 1):0] rd;

    // immgen output
    reg [(BUS_WIDTH - 1):0] imm;

    reg [(BUS_WIDTH - 1):0] pc;
    reg [(INSTR_WIDTH - 1):0] instr;
    reg [(BUS_WIDTH - 1):0] alu_fpu_result;
    reg [(BUS_WIDTH - 1):0] mem_in;

    always @(posedge clk) begin
        if(rst) begin
            // Control Pins
            reg_write <= 1'b0;
            mem_write <= 1'b0;
            mem_read <= 1'b0;
            mem_to_reg <= 1'b0;
            jalr_src <= 1'b0;
            u_src <= 1'b0;
            uj_src <= 1'b0;
            
            // REGFILE Outputs
            rs1 <= {REGFILE_LEN{1'b0}};
            rs2 <= {REGFILE_LEN{1'b0}};
            rd <= {REGFILE_LEN{1'b0}};
            
            // IMMGEN output
            imm <= {BUS_WIDTH{1'b0}};
            
            // PC
            pc <= {BUS_WIDTH{1'b0}};
            instr <= {INSTR_WIDTH{1'b0}};

            alu_fpu_result <= {BUS_WIDTH{1'b0}};
            mem_in <= {BUS_WIDTH{1'b0}};
        end
        else if(~stall) begin
            // Control Pins
            reg_write <= in_reg_write;
            mem_write <= in_mem_write;
            mem_read <= in_mem_read;
            mem_to_reg <= in_mem_to_reg;
            jalr_src <= in_jalr_src;
            u_src <= in_u_src;
            uj_src <= in_uj_src;
            
            // REGFILE Outputs
            rs1 <= in_rs1;
            rs2 <= in_rs2;
            rd <= in_rd;
           
            // PC
            pc <= in_pc;
            instr <= in_instr;

            // IMMGEN output
            imm <= in_imm;

            alu_fpu_result <= in_alu_fpu_result;
            mem_in <= in_mem_in;
        end
    end

    // Continuous assignments to output wires
    // Control Pins
    assign out_reg_write = reg_write;
    assign out_mem_write = mem_write;
    assign out_mem_read = mem_read;
    assign out_mem_to_reg = mem_to_reg;
    assign out_jalr_src = jalr_src;
    assign out_u_src = u_src;
    assign out_uj_src = uj_src;
    
    // REGFILE Outputs
    assign out_rs1 = rs1;
    assign out_rs2 = rs2;
    assign out_rd = rd;

    // IMMGEN output
    assign out_imm = imm;

    // PC
    assign out_pc = pc;
    assign out_instr = instr;

    assign out_alu_fpu_result = alu_fpu_result;
    assign out_mem_in = mem_in;
endmodule