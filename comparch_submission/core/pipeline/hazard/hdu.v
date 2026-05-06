// short for "Hazard Detection Unit"
module hdu #(
    parameter REGFILE_LEN=6
)(
    input wire clk,
    input wire rst,
    input wire [(REGFILE_LEN - 1):0] rs1_IF_ID,
    input wire [(REGFILE_LEN - 1):0] rs2_IF_ID,
    input wire [(REGFILE_LEN - 1):0] rd_ID_EX,
    input wire [(REGFILE_LEN - 1):0] rd_EX_MEM,
    input wire mem_read_ID_EX,
    input wire mem_read_EX_MEM,
    input wire branch_prediction_failed,
    input wire is_branch_IF_ID,
    input wire jump_taken_IF_ID,
    output wire load_stall,
    output wire load_jump_branch_stall,
    output wire jump_stall
);
    wire reg_eq_ID_EX_A = (rd_ID_EX == rs1_IF_ID);
    wire reg_eq_ID_EX_B = (rd_ID_EX == rs2_IF_ID);

    wire reg_eq_EX_MEM_A = (rd_EX_MEM == rs1_IF_ID);
    wire reg_eq_EX_MEM_B = (rd_EX_MEM == rs2_IF_ID);

    assign load_stall = (mem_read_ID_EX) & (reg_eq_ID_EX_A | reg_eq_ID_EX_B);
    assign load_jump_branch_stall = (mem_read_EX_MEM) & (reg_eq_EX_MEM_A | reg_eq_EX_MEM_B) & (jump_taken_IF_ID | is_branch_IF_ID);
    assign jump_stall = jump_taken_IF_ID | branch_prediction_failed; // if branch then stall
endmodule