module id_stage #(
    parameter BUS_WIDTH=64,
    parameter INSTR_WIDTH=32,
    parameter REGFILE_LEN=6,
    parameter ALU_CONTROL_WIDTH=2,
    parameter ALU_SELECT_WIDTH=3,
    parameter FPU_OP_WIDTH=6,
    parameter BRANCH_SRC_WIDTH=3
)(
    input wire clk,
    input wire [(BUS_WIDTH - 1):0] pc,
    input wire [(INSTR_WIDTH - 1):0] instr,
    output wire [(INSTR_WIDTH - 1):0] morphed_instr,

    // from FORWARDING unit
    input wire forward_jalr_ID_EX,
    input wire forward_jalr_EX_MEM,
    input wire forward_jalr_MEM_WB,
    input wire forward_branch_ID_EX_A,
    input wire forward_branch_ID_EX_B,
    input wire forward_branch_EX_MEM_A,
    input wire forward_branch_EX_MEM_B,
    input wire forward_branch_MEM_WB_A,
    input wire forward_branch_MEM_WB_B,

    input wire [(BUS_WIDTH - 1):0] id_ex_reg_val,
    input wire [(BUS_WIDTH - 1):0] ex_mem_reg_val,
    input wire [(BUS_WIDTH - 1):0] mem_wb_reg_val,

    // from WB stage
    input wire [(REGFILE_LEN - 1):0] wb_rd,
    input wire [(BUS_WIDTH - 1):0] wb_write_data,
    input wire wb_reg_write,

    // Control Pins
    output wire reg_write, 
    output wire mem_write,
    output wire mem_read,
    output wire mem_to_reg,
    output wire jump_src,
    output wire jalr_src,
    output wire u_src,
    output wire uj_src,
    output wire alu_src,
    output wire alu_fpu,

    // REGFILE Outputs
    output wire [(BUS_WIDTH - 1):0] read_data1,
    output wire [(BUS_WIDTH - 1):0] read_data2,
    output wire [(REGFILE_LEN - 1):0] rs1,
    output wire [(REGFILE_LEN - 1):0] rs2,
    output wire [(REGFILE_LEN - 1):0] rd,

    // ALU Controls
    output wire [(ALU_CONTROL_WIDTH - 1):0] control,
    output wire [(ALU_SELECT_WIDTH - 1):0] select,

    // FPU Controls
    output wire fpu_rd,
    output wire [(FPU_OP_WIDTH - 1):0] fpu_op,

    // IMMGEN output
    output wire [(BUS_WIDTH - 1):0] imm,

    output wire jump_taken,
    output wire branch_taken,
    output wire is_branch,

    // NEXT IMM PC (wont go to next stage)
    output wire imm_pc,
    output wire [(BUS_WIDTH - 1):0] next_imm_pc
);

    wire fpu_rs1, fpu_rs2;

    fpu_cntrl #(
        .BUS_WIDTH(BUS_WIDTH),
        .FPU_OP_LEN(FPU_OP_WIDTH)
    ) fpu_cntrl_instance (
        .instr(instr),
        .fpu_rs1(fpu_rs1),
        .fpu_rs2(fpu_rs2),
        .fpu_rd(fpu_rd),
        .fpu_op(fpu_op)
    );

    localparam [(FPU_OP_WIDTH - 1):0] FLD_OP = 6'b110000;
    localparam [(FPU_OP_WIDTH - 1):0] FLW_OP = 6'b110001;
    localparam [(FPU_OP_WIDTH - 1):0] FSD_OP = 6'b110010;
    localparam [(FPU_OP_WIDTH - 1):0] FSW_OP = 6'b110011;

    localparam [6:0] LOAD_OPCODE = 7'b0000011;
    localparam [6:0] STORE_OPCODE = 7'b0100011;

    wire is_fld = fpu_op == FLD_OP;
    wire is_flw = fpu_op == FLW_OP;
    wire is_fsd = fpu_op == FSD_OP;
    wire is_fsw = fpu_op == FSW_OP;
    wire is_morphed = is_fld | is_flw | is_fsd | is_fsw;

    // Morphed opcode
    wire [6:0] morphed_opcode = (is_fld | is_flw) ? LOAD_OPCODE : ((is_fsd | is_fsw) ? STORE_OPCODE: instr[6:0]);
    assign morphed_instr = {instr[31:7], morphed_opcode};

    control #(
        .INSTR_WIDTH(INSTR_WIDTH),
        .BRANCH_SRC_WIDTH(BRANCH_SRC_WIDTH)
    ) control_instance (
        .instr(morphed_instr),
        .reg_write(reg_write), 
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .jump_src(jump_src),
        .branch_src(branch_src),
        .jalr_src(jalr_src),
        .u_src(u_src),
        .uj_src(uj_src),
        .alu_src(alu_src),
        .alu_fpu(alu_fpu)
    );

    alu_control #(
        .INSTR_WIDTH(INSTR_WIDTH),
        .ALU_CONTROL_WIDTH(ALU_CONTROL_WIDTH),
        .ALU_SELECT_WIDTH(ALU_SELECT_WIDTH)
    ) alu_control_instance (
        .instr(morphed_instr),
        .control(control),
        .select(select)
    );

    // if register is floating point
    // 32 has to be added (register file design)
    // this is same as keeping the first bit as 1
    assign rs1 = {(alu_fpu | is_morphed) & fpu_rs1, instr[19:15]};
    assign rs2 = {(alu_fpu | is_morphed) & fpu_rs2, instr[24:20]};
    assign rd =  {(alu_fpu | is_morphed) & fpu_rd, instr[11:7]};

    regfile #(
        .BUS_WIDTH(BUS_WIDTH),
        .REGFILE_LEN(REGFILE_LEN)
    ) regfile_instance (
        .clk(clk),
        .write_enable(wb_reg_write),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .write_addr(wb_rd),
        .write_data(wb_write_data)
    );
    
    immgen #(
        .BUS_WIDTH(BUS_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH)
    ) immgen_instance (
        .instr(morphed_instr),
        .imm(imm)
    );

    // BRANCH Flags
    wire zero, neg, negu;

    // BRANCH Forwarding detection
    wire [(BUS_WIDTH - 1):0] comparator_forwarded_read_data1 =
        forward_branch_ID_EX_A ? id_ex_reg_val:
        forward_branch_EX_MEM_A ? ex_mem_reg_val:
        forward_branch_MEM_WB_A ? mem_wb_reg_val:
        read_data1;

    wire [(BUS_WIDTH - 1):0] comparator_forwarded_read_data2 =
        forward_branch_ID_EX_B ? id_ex_reg_val:
        forward_branch_EX_MEM_B ? ex_mem_reg_val:
        forward_branch_MEM_WB_B ? mem_wb_reg_val:
        read_data2;

    comparator #(
        .BUS_WIDTH(BUS_WIDTH)
    ) comparator_instance (
        .in1(comparator_forwarded_read_data1),
        .in2(comparator_forwarded_read_data2),
        .zero(zero),
        .neg(neg),
        .negu(negu)
    );

    // To branch or not to branch, that is the question
    wire [(BRANCH_SRC_WIDTH -1):0] branch_src;

    branch_control #(
        .BRANCH_SRC_WIDTH(BRANCH_SRC_WIDTH)
    ) branch_control_instance (
        .branch_src(branch_src),
        .zero(zero),
        .neg(neg),
        .negu(negu),
        .branch(branch_taken)
    );

    assign imm_pc = branch_taken | jump_src;
    assign jump_taken = jump_src;
    assign is_branch = (branch_src != 0);

    localparam ADD_CNTRL = 2'b00;

    // JALR Forwarding detection
    wire [(BUS_WIDTH - 1):0] forwarded_read_data1 =
        forward_jalr_ID_EX ? id_ex_reg_val:
        forward_jalr_EX_MEM ? ex_mem_reg_val:
        forward_jalr_MEM_WB ? mem_wb_reg_val:
        read_data1;

    // adding immediate to pc (or forwarded register data in jalr)
    addsub #(
        .BUS_WIDTH(BUS_WIDTH)
    ) addsub_jump_instance (
        .in1(jalr_src ? forwarded_read_data1: pc),
        .in2(imm),
        .control(ADD_CNTRL),
        .out(next_imm_pc)
    );
endmodule