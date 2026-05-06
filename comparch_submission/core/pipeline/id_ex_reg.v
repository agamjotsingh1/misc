module id_ex_reg #(
    parameter BUS_WIDTH=64,
    parameter INSTR_WIDTH=32,
    parameter REGFILE_LEN=6,
    parameter ALU_CONTROL_WIDTH=2,
    parameter ALU_SELECT_WIDTH=3,
    parameter FPU_OP_WIDTH=6
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
    input wire in_jump_src,
    input wire in_jalr_src,
    input wire in_u_src,
    input wire in_uj_src,
    input wire in_alu_src,
    input wire in_alu_fpu,

    // REGFILE Outputs
    input wire [(BUS_WIDTH - 1):0] in_read_data1,
    input wire [(BUS_WIDTH - 1):0] in_read_data2,
    input wire [(REGFILE_LEN - 1):0] in_rs1,
    input wire [(REGFILE_LEN - 1):0] in_rs2,
    input wire [(REGFILE_LEN - 1):0] in_rd,

    // ALU Controls
    input wire [(ALU_CONTROL_WIDTH - 1):0] in_control,
    input wire [(ALU_SELECT_WIDTH - 1):0] in_select,

    // FPU Controls
    input wire [(FPU_OP_WIDTH - 1):0] in_fpu_op,

    // IMMGEN output
    input wire [(BUS_WIDTH - 1):0] in_imm,

    input wire [(BUS_WIDTH - 1):0] in_pc,
    input wire [(INSTR_WIDTH - 1):0] in_instr,

    // ------ OUTPUTS ------

    // Control Pouts
    output wire out_reg_write, 
    output wire out_mem_write,
    output wire out_mem_read,
    output wire out_mem_to_reg,
    output wire out_jump_src,
    output wire out_jalr_src,
    output wire out_u_src,
    output wire out_uj_src,
    output wire out_alu_src,
    output wire out_alu_fpu,

    // REGFILE Outputs
    output wire [(BUS_WIDTH - 1):0] out_read_data1,
    output wire [(BUS_WIDTH - 1):0] out_read_data2,
    output wire [(REGFILE_LEN - 1):0] out_rs1,
    output wire [(REGFILE_LEN - 1):0] out_rs2,
    output wire [(REGFILE_LEN - 1):0] out_rd,

    // ALU Controls
    output wire [(ALU_CONTROL_WIDTH - 1):0] out_control,
    output wire [(ALU_SELECT_WIDTH - 1):0] out_select,

    // FPU Controls
    output wire [(FPU_OP_WIDTH - 1):0] out_fpu_op,

    // IMMGEN output
    output wire [(BUS_WIDTH - 1):0] out_imm,

    output wire [(BUS_WIDTH - 1):0] out_pc,
    output wire [(INSTR_WIDTH - 1):0] out_instr
);
    // Control Pins
    reg reg_write; 
    reg mem_write;
    reg mem_read;
    reg mem_to_reg;
    reg jump_src;
    reg jalr_src;
    reg u_src;
    reg uj_src;
    reg alu_src;
    reg alu_fpu;

    // REGFILE Outputs
    reg [(BUS_WIDTH - 1):0] read_data1;
    reg [(BUS_WIDTH - 1):0] read_data2;
    reg [(REGFILE_LEN - 1):0] rs1;
    reg [(REGFILE_LEN - 1):0] rs2;
    reg [(REGFILE_LEN - 1):0] rd;

    // ALU Controls
    reg [(ALU_CONTROL_WIDTH - 1):0] control;
    reg [(ALU_SELECT_WIDTH - 1):0] select;

    // FPU Controls
    reg [(FPU_OP_WIDTH - 1):0] fpu_op;

    // IMMGEN output
    reg [(BUS_WIDTH - 1):0] imm;

    reg [(BUS_WIDTH - 1):0] pc;
    reg [(INSTR_WIDTH - 1):0] instr;

    always @(posedge clk) begin
        if(rst) begin
            // Control Pins
            reg_write <= 1'b0;
            mem_write <= 1'b0;
            mem_read <= 1'b0;
            mem_to_reg <= 1'b0;
            jump_src <= 1'b0;
            jalr_src <= 1'b0;
            u_src <= 1'b0;
            uj_src <= 1'b0;
            alu_src <= 1'b0;
            alu_fpu <= 1'b0;
            
            // REGFILE Outputs
            read_data1 <= {BUS_WIDTH{1'b0}};
            read_data2 <= {BUS_WIDTH{1'b0}};
            rs1 <= {REGFILE_LEN{1'b0}};
            rs2 <= {REGFILE_LEN{1'b0}};
            rd <= {REGFILE_LEN{1'b0}};
            
            // ALU Controls
            control <= {ALU_CONTROL_WIDTH{1'b0}};
            select <= {ALU_SELECT_WIDTH{1'b0}};
            
            // FPU Controls
            fpu_op <= {FPU_OP_WIDTH{1'b0}};
            
            // IMMGEN output
            imm <= {BUS_WIDTH{1'b0}};
            
            // PC
            pc <= {BUS_WIDTH{1'b0}};
            instr <= {INSTR_WIDTH{1'b0}};
        end
        else if(~stall) begin
            // Control Pins
            reg_write <= in_reg_write;
            mem_write <= in_mem_write;
            mem_read <= in_mem_read;
            mem_to_reg <= in_mem_to_reg;
            jump_src <= in_jump_src;
            jalr_src <= in_jalr_src;
            u_src <= in_u_src;
            uj_src <= in_uj_src;
            alu_src <= in_alu_src;
            alu_fpu <= in_alu_fpu;
            
            // REGFILE Outputs
            read_data1 <= in_read_data1;
            read_data2 <= in_read_data2;
            rs1 <= in_rs1;
            rs2 <= in_rs2;
            rd <= in_rd;
            
            // ALU Controls
            control <= in_control;
            select <= in_select;
            
            // FPU Controls
            fpu_op <= in_fpu_op;
            
            // IMMGEN output
            imm <= in_imm;
            
            // PC
            pc <= in_pc;
            instr <= in_instr;
        end
    end

    // Continuous assignments to output wires
    // Control Pins
    assign out_reg_write = reg_write;
    assign out_mem_write = mem_write;
    assign out_mem_read = mem_read;
    assign out_mem_to_reg = mem_to_reg;
    assign out_jump_src = jump_src;
    assign out_jalr_src = jalr_src;
    assign out_u_src = u_src;
    assign out_uj_src = uj_src;
    assign out_alu_src = alu_src;
    assign out_alu_fpu = alu_fpu;
    
    // REGFILE Outputs
    assign out_read_data1 = read_data1;
    assign out_read_data2 = read_data2;
    assign out_rs1 = rs1;
    assign out_rs2 = rs2;
    assign out_rd = rd;
    
    // ALU Controls
    assign out_control = control;
    assign out_select = select;
    
    // FPU Controls
    assign out_fpu_op = fpu_op;
    
    // IMMGEN output
    assign out_imm = imm;
    
    // PC
    assign out_pc = pc;
    assign out_instr = instr;
endmodule