module forwarding_unit #(
    parameter REGFILE_LEN=6,
    parameter INSTR_WIDTH=32,
    parameter FORWARD_ALU_SELECT_WIDTH=2,
    parameter OPCODE_WIDTH=7,
    parameter FUNCT3_WIDTH=3
)(
    input wire reg_write_ID_EX,
    input wire reg_write_EX_MEM,
    input wire reg_write_MEM_WB,

    input wire [(INSTR_WIDTH - 1):0] instr_IF_ID,

    input wire [(REGFILE_LEN - 1):0] rs1_IF_ID,
    input wire [(REGFILE_LEN - 1):0] rs2_IF_ID,
    input wire [(REGFILE_LEN - 1):0] rs1_ID_EX,
    input wire [(REGFILE_LEN - 1):0] rs2_ID_EX,
    input wire [(REGFILE_LEN - 1):0] rd_ID_EX,
    input wire [(REGFILE_LEN - 1):0] rd_EX_MEM,
    input wire [(REGFILE_LEN - 1):0] rd_MEM_WB,

    output wire [(FORWARD_ALU_SELECT_WIDTH - 1):0] forward_A,
    output wire [(FORWARD_ALU_SELECT_WIDTH - 1):0] forward_B,

    output wire forward_jalr_ID_EX,
    output wire forward_jalr_EX_MEM,
    output wire forward_jalr_MEM_WB,
    output wire forward_branch_ID_EX_A,
    output wire forward_branch_ID_EX_B,
    output wire forward_branch_EX_MEM_A,
    output wire forward_branch_EX_MEM_B,
    output wire forward_branch_MEM_WB_A,
    output wire forward_branch_MEM_WB_B
);
    // Checking write enabled
    wire write_enabled_EX_MEM = reg_write_EX_MEM;
    wire write_enabled_MEM_WB = reg_write_MEM_WB;

    // Checking for write to x0
    wire write_to_x0_EX_MEM = rd_EX_MEM == {REGFILE_LEN{1'b0}};
    wire write_to_x0_MEM_WB = rd_MEM_WB == {REGFILE_LEN{1'b0}};

    // Checking if register values match that of rd of EX_MEM
    wire reg_eq_EX_MEM_A = rd_EX_MEM == rs1_ID_EX;
    wire reg_eq_EX_MEM_B = rd_EX_MEM == rs2_ID_EX;

    // Checking if register values match that of rd of MEM_WB
    wire reg_eq_MEM_WB_A = (rd_MEM_WB == rs1_ID_EX);
    wire reg_eq_MEM_WB_B = (rd_MEM_WB == rs2_ID_EX);

    // Checking if forward from EX_MEM/MEM_WB is valid (write enabled & non x0 write)
    wire forward_EX_MEM_valid = write_enabled_EX_MEM & (~write_to_x0_EX_MEM);
    wire forward_MEM_WB_valid = write_enabled_MEM_WB & (~write_to_x0_MEM_WB);

    // Forward A

    // forward from EX_MEM
    wire from_EX_MEM_A = forward_EX_MEM_valid & reg_eq_EX_MEM_A;
    // forward from MEM_WB
    wire from_MEM_WB_A = forward_MEM_WB_valid & reg_eq_MEM_WB_A;

    // forward_A =
    // 10 -> from EX/MEM
    // 01 -> from MEM/WB
    // 00 -> Neither
    assign forward_A = (from_EX_MEM_A)
                      ?(2'b10)
                      :((from_MEM_WB_A) ? (2'b01) : 2'b0);

    // Forward B

    // forward from EX_MEM
    wire from_EX_MEM_B = forward_EX_MEM_valid & reg_eq_EX_MEM_B;
    // forward from MEM_WB
    wire from_MEM_WB_B = forward_MEM_WB_valid & reg_eq_MEM_WB_B;

    // forward_B =
    // 10 -> from EX/MEM
    // 01 -> from MEM/WB
    // 00 -> Neither
    assign forward_B = (from_EX_MEM_B)
                       ?(2'b10)
                       :((from_MEM_WB_B) ? (2'b01) : 2'b0);

    // JALR Forwarding
    wire [(OPCODE_WIDTH - 1):0] opcode_IF_ID = instr_IF_ID[6:0];
    wire [(FUNCT3_WIDTH - 1):0] funct3 = instr_IF_ID[14:12];

    wire is_jalr = (opcode_IF_ID == 7'b1100111 & funct3 == 3'b000);

    // Checking JALR forwarding from ID/EX to IF/ID
    assign forward_jalr_ID_EX = (is_jalr & reg_write_ID_EX & (rs1_IF_ID == rd_ID_EX));

    // Checking JALR forwarding from EX/MEM to IF/ID
    assign forward_jalr_EX_MEM = (is_jalr & reg_write_EX_MEM & (rs1_IF_ID == rd_EX_MEM));

    // Checking JALR forwarding from MEM/WB to IF/ID
    assign forward_jalr_MEM_WB = (is_jalr & reg_write_MEM_WB & (rs1_IF_ID == rd_MEM_WB));

    wire is_branch = opcode_IF_ID == 7'b1100011;

    // Checking JALR forwarding from ID/EX to IF/ID
    assign forward_branch_ID_EX_A = (is_branch & reg_write_ID_EX & (rs1_IF_ID == rd_ID_EX) & (rd_ID_EX != {REGFILE_LEN{1'b0}}));
    assign forward_branch_ID_EX_B = (is_branch & reg_write_ID_EX & (rs2_IF_ID == rd_ID_EX) & (rd_ID_EX != {REGFILE_LEN{1'b0}}));

    // Checking JALR forwarding from EX/MEM to IF/ID
    assign forward_branch_EX_MEM_A = (is_branch & reg_write_EX_MEM & (rs1_IF_ID == rd_EX_MEM) & (rd_EX_MEM != {REGFILE_LEN{1'b0}}));
    assign forward_branch_EX_MEM_B = (is_branch & reg_write_EX_MEM & (rs2_IF_ID == rd_EX_MEM) & (rd_EX_MEM != {REGFILE_LEN{1'b0}}));

    // Checking JALR forwarding from MEM/WB to IF/ID
    assign forward_branch_MEM_WB_A = (is_branch & reg_write_MEM_WB & (rs1_IF_ID == rd_MEM_WB) & (rd_MEM_WB != {REGFILE_LEN{1'b0}}));
    assign forward_branch_MEM_WB_B = (is_branch & reg_write_MEM_WB & (rs2_IF_ID == rd_MEM_WB) & (rd_MEM_WB != {REGFILE_LEN{1'b0}}));
endmodule