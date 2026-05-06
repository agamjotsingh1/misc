module core #(
    parameter BUS_WIDTH=64,
    parameter INSTR_MEM_LEN=15, // actual instr mem length = pow(2, INSTR_MEM_LEN)
    parameter INSTR_WIDTH=32,
    parameter DATA_MEM_LEN=12 // actual data mem length = pow(2, DATA_MEM_LEN)
)(
    input wire sys_clk,
    input wire running,
    input wire rst,

    // Output number of cycles for program to run
    output wire [(BUS_WIDTH - 1):0] program_cycles,

    // Exposed pins to instruction memory
    output wire [31:0] axi_if_pc,
    output wire [31:0] axi_if_instr,

    // Some analysis sake pins
    input wire axi_is_static_prediction,
    input wire axi_static_prediction,
    output wire axi_is_program_done,

    // INSTR MEM AXI controller
    input wire axi_instr_clk,
    input wire axi_instr_en,
    input wire [3:0] axi_instr_we,
    input wire [(INSTR_MEM_LEN - 1):0] axi_instr_addr,
    input wire [(INSTR_WIDTH - 1):0] axi_instr_din,
    output wire [(INSTR_WIDTH - 1):0] axi_instr_dout,

    // DATA MEM AXI controller
    input wire axi_data_clk,
    input wire axi_data_en,
    input wire axi_data_we,
    input wire [(BUS_WIDTH - 1):0] axi_data_addr,
    input wire [7:0] axi_data_din,  // byte addressable axi debugging
    output wire [7:0] axi_data_dout // byte addressable axi debugging
);
    localparam REGFILE_LEN=6;
    localparam ALU_CONTROL_WIDTH=2;
    localparam ALU_SELECT_WIDTH=3;
    localparam FPU_OP_WIDTH=6;
    localparam BRANCH_SRC_WIDTH=3;
    localparam MEM_BIT_WIDTH=2;
    localparam FORWARD_ALU_SELECT_WIDTH=2;
    localparam OPCODE_WIDTH=7;
    localparam FUNCT3_WIDTH=3;

    wire clk = sys_clk & running;

    reg [(BUS_WIDTH - 1):0] cycles; // number of for the program cycles used
    reg is_program_done; // 1 when program is complete (0 offset jal is reached)
    assign axi_is_program_done = is_program_done;
    assign program_cycles = cycles + 3; // jal 0 offset detection is in ID stage, to compensate 3 is added

    wire id_jump_taken;
    wire [(BUS_WIDTH - 1):0] id_imm;

    always @(posedge clk) begin
        if(rst) begin
            cycles <= 0;
            is_program_done <= 0;
        end
        // if 0 offset jal is taken
        else if((id_jump_taken & (id_imm == {BUS_WIDTH{1'b0}})) & (~is_program_done)) is_program_done <= 1;
        else if(~is_program_done) cycles <= cycles + 1;
    end

    // GLOBAL interconnects
    wire imm_pc, wb_reg_write;
    wire [(BUS_WIDTH - 1):0] next_imm_pc;
    wire [(REGFILE_LEN - 1):0] wb_rd;
    wire [(BUS_WIDTH - 1):0] wb_write_data;
    wire id_branch_taken;
    wire id_is_branch;

    // Forwarding interconnects
    wire [(FORWARD_ALU_SELECT_WIDTH - 1):0] forward_A;
    wire [(FORWARD_ALU_SELECT_WIDTH - 1):0] forward_B;
    wire forward_jalr_ID_EX;
    wire forward_jalr_EX_MEM;
    wire forward_jalr_MEM_WB;
    wire forward_branch_ID_EX_A;
    wire forward_branch_ID_EX_B;
    wire forward_branch_EX_MEM_A;
    wire forward_branch_EX_MEM_B;
    wire forward_branch_MEM_WB_A;
    wire forward_branch_MEM_WB_B;


    wire [(BUS_WIDTH - 1):0] ex_alu_fpu_result;
    wire [(BUS_WIDTH - 1):0] mem_alu_fpu_result;
    wire [(BUS_WIDTH - 1):0] wb_reg_write_data;

    //==============================================
    // IF STAGE 
    //==============================================

    wire pc_stall;

    wire [(BUS_WIDTH - 1):0] if_pc;
    wire [(INSTR_WIDTH - 1):0] if_instr;
    wire branch_prediction_failed;

    (* dont_touch = "yes" *)
    if_stage #(
        .BUS_WIDTH(BUS_WIDTH),
        .INSTR_MEM_LEN(INSTR_MEM_LEN),
        .INSTR_WIDTH(INSTR_WIDTH)
    ) if_stage_instance (
        .clk(clk),
        .rst(rst),
        .stall(pc_stall),
        .compulsory_stall(compulsory_stall),
        .imm_pc(imm_pc),
        .next_imm_pc(next_imm_pc),
        .pc(if_pc),
        .instr(if_instr),
        .jump_taken_IF_ID(id_jump_taken),
        .branch_prediction_failed(branch_prediction_failed),
        .id_branch_taken(id_branch_taken),
        .load_stall(load_stall | load_jump_branch_stall),
        .is_static_prediction(axi_is_static_prediction),
        .static_prediction(axi_static_prediction),

        // INSTR MEM AXI controller
        .axi_instr_clk(axi_instr_clk),
        .axi_instr_en(axi_instr_en),
        .axi_instr_we(axi_instr_we),
        .axi_instr_addr(axi_instr_addr),
        .axi_instr_din(axi_instr_din),
        .axi_instr_dout(axi_instr_dout)
    );

    assign axi_if_pc = if_pc;
    assign axi_if_instr = if_instr;

    //==============================================
    // IF ID PIPELINE REGISTER
    //==============================================

    wire if_id_stall;
    wire if_id_rst;

    wire [(BUS_WIDTH - 1):0] id_pc;
    wire [(INSTR_WIDTH - 1):0] id_instr;

    (* dont_touch = "yes" *)
    if_id_reg #(
        .BUS_WIDTH(BUS_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH)
    ) if_id_reg_instance (
        .clk(clk),
        .rst(if_id_rst | rst),
        .stall(if_id_stall),
        .in_pc(if_pc),
        .in_instr(if_instr),
        .out_pc(id_pc),
        .out_instr(id_instr)
    );


    //==============================================
    // ID Stage
    //==============================================

    // Control Pins
    wire id_reg_write; 
    wire id_mem_write;
    wire id_mem_read;
    wire id_mem_to_reg;
    wire id_jump_src;
    wire id_jalr_src;
    wire id_u_src;
    wire id_uj_src;
    wire id_alu_src;
    wire id_alu_fpu;

    // REGFILE Outputs
    wire [(BUS_WIDTH - 1):0] id_read_data1;
    wire [(BUS_WIDTH - 1):0] id_read_data2;
    wire [(REGFILE_LEN - 1):0] id_rs1;
    wire [(REGFILE_LEN - 1):0] id_rs2;
    wire [(REGFILE_LEN - 1):0] id_rd;

    // ALU Controls
    wire [(ALU_CONTROL_WIDTH - 1):0] id_control;
    wire [(ALU_SELECT_WIDTH - 1):0] id_select;

    // FPU Controls
    wire id_fpu_rd;
    wire [(FPU_OP_WIDTH - 1):0] id_fpu_op;
    wire [(INSTR_WIDTH - 1):0] id_morphed_instr;


    (* dont_touch = "yes" *)
    id_stage #(
        .BUS_WIDTH(BUS_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH),
        .REGFILE_LEN(REGFILE_LEN),
        .ALU_CONTROL_WIDTH(ALU_CONTROL_WIDTH),
        .ALU_SELECT_WIDTH(ALU_SELECT_WIDTH),
        .FPU_OP_WIDTH(FPU_OP_WIDTH),
        .BRANCH_SRC_WIDTH(BRANCH_SRC_WIDTH)
    ) id_stage_instance (
        .clk(clk),
        .pc(id_pc),
        .instr(id_instr),
        .morphed_instr(id_morphed_instr),
        .wb_rd(wb_rd),
        .wb_write_data(wb_write_data),
        .wb_reg_write(wb_reg_write),

        // from FORWARDING unit
        .forward_jalr_ID_EX(forward_jalr_ID_EX),
        .forward_jalr_EX_MEM(forward_jalr_EX_MEM),
        .forward_jalr_MEM_WB(forward_jalr_MEM_WB),

        .forward_branch_ID_EX_A(forward_branch_ID_EX_A),
        .forward_branch_ID_EX_B(forward_branch_ID_EX_B),
        .forward_branch_EX_MEM_A(forward_branch_EX_MEM_A),
        .forward_branch_EX_MEM_B(forward_branch_EX_MEM_B),
        .forward_branch_MEM_WB_A(forward_branch_MEM_WB_A),
        .forward_branch_MEM_WB_B(forward_branch_MEM_WB_B),

        .id_ex_reg_val(ex_alu_fpu_result),
        .ex_mem_reg_val(mem_mem_read ? mem_mem_out: mem_write_data),
        .mem_wb_reg_val(wb_write_data),

        // CONTROL Signals
        .reg_write(id_reg_write),
        .mem_write(id_mem_write),
        .mem_read(id_mem_read),
        .mem_to_reg(id_mem_to_reg),
        .jump_src(id_jump_src),
        .jalr_src(id_jalr_src),
        .u_src(id_u_src),
        .uj_src(id_uj_src),
        .alu_src(id_alu_src),
        .alu_fpu(id_alu_fpu),

        // REGFILE Outputs
        .read_data1(id_read_data1),
        .read_data2(id_read_data2),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(id_rd),

        // ALU Controls
        .control(id_control),
        .select(id_select),

        // FPU Controls
        .fpu_rd(id_fpu_rd),
        .fpu_op(id_fpu_op),

        // IMMGEN output
        .imm(id_imm),

        .jump_taken(id_jump_taken),
        .branch_taken(id_branch_taken),
        .is_branch(id_is_branch),

        .imm_pc(imm_pc),
        .next_imm_pc(next_imm_pc)
    );


    //==============================================
    // ID EX PIPELINE REGISTER
    //==============================================

    wire id_ex_stall;
    wire id_ex_rst;

    wire [(BUS_WIDTH - 1):0] ex_pc;
    wire [(INSTR_WIDTH - 1):0] ex_instr;

    // Control Pins
    wire ex_reg_write; 
    wire ex_mem_write;
    wire ex_mem_read;
    wire ex_mem_to_reg;
    wire ex_jump_src;
    wire ex_jalr_src;
    wire ex_u_src;
    wire ex_uj_src;
    wire ex_alu_src;
    wire ex_alu_fpu;

    // REGFILE Outputs
    wire [(BUS_WIDTH - 1):0] ex_read_data1;
    wire [(BUS_WIDTH - 1):0] ex_read_data2;
    wire [(REGFILE_LEN - 1):0] ex_rs1;
    wire [(REGFILE_LEN - 1):0] ex_rs2;
    wire [(REGFILE_LEN - 1):0] ex_rd;

    // ALU Controls
    wire [(ALU_CONTROL_WIDTH - 1):0] ex_control;
    wire [(ALU_SELECT_WIDTH - 1):0] ex_select;

    // FPU Controls
    wire [(FPU_OP_WIDTH - 1):0] ex_fpu_op;

    // IMMGEN output
    wire [(BUS_WIDTH - 1):0] ex_imm;

    (* dont_touch = "yes" *)
    id_ex_reg #(
        .BUS_WIDTH(BUS_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH),
        .REGFILE_LEN(REGFILE_LEN),
        .ALU_CONTROL_WIDTH(ALU_CONTROL_WIDTH),
        .ALU_SELECT_WIDTH(ALU_SELECT_WIDTH),
        .FPU_OP_WIDTH(FPU_OP_WIDTH)
    ) id_ex_reg_instance (
        .clk(clk),
        .rst(id_ex_rst | rst),
        .stall(id_ex_stall),
        
        // In Control Pins
        .in_reg_write(id_reg_write),
        .in_mem_write(id_mem_write),
        .in_mem_read(id_mem_read),
        .in_mem_to_reg(id_mem_to_reg),
        .in_jump_src(id_jump_src),
        .in_jalr_src(id_jalr_src),
        .in_u_src(id_u_src),
        .in_uj_src(id_uj_src),
        .in_alu_src(id_alu_src),
        .in_alu_fpu(id_alu_fpu),
        
        // In REGFILE Pins
        .in_read_data1(id_read_data1),
        .in_read_data2(id_read_data2),
        .in_rs1(id_rs1),
        .in_rs2(id_rs2),
        .in_rd(id_rd),
        
        // In ALU Pins
        .in_control(id_control),
        .in_select(id_select),

        // In FPU Pins
        .in_fpu_op(id_fpu_op),

        .in_imm(id_imm),
        .in_pc(id_pc),
        .in_instr(id_morphed_instr),

        // Out Control Pins
        .out_reg_write(ex_reg_write),
        .out_mem_write(ex_mem_write),
        .out_mem_read(ex_mem_read),
        .out_mem_to_reg(ex_mem_to_reg),
        .out_jump_src(ex_jump_src),
        .out_jalr_src(ex_jalr_src),
        .out_u_src(ex_u_src),
        .out_uj_src(ex_uj_src),
        .out_alu_src(ex_alu_src),
        .out_alu_fpu(ex_alu_fpu),

        // Out REGFILE Pins
        .out_read_data1(ex_read_data1),
        .out_read_data2(ex_read_data2),
        .out_rs1(ex_rs1),
        .out_rs2(ex_rs2),
        .out_rd(ex_rd),
        
        // Out ALU Pins
        .out_control(ex_control),
        .out_select(ex_select),

        // Out FPU Pins
        .out_fpu_op(ex_fpu_op),

        .out_imm(ex_imm),
        .out_pc(ex_pc),
        .out_instr(ex_instr)
    );

    //==============================================
    // EX Stage
    //==============================================


    wire [(BUS_WIDTH - 1):0] ex_forwarded_read_data1;
    wire [(BUS_WIDTH - 1):0] ex_forwarded_read_data2;


    // forward_A =
    // 10 -> from EX/MEM
    // 01 -> from MEM/WB
    // 00 -> Neither
    /*assign ex_forwarded_read_data1 =
        (forward_A == 2'b10) ? (mem_mem_read ? mem_mem_out: mem_write_data):
        (forward_A == 2'b01) ? wb_write_data:
        ex_read_data1;  
    */

    assign ex_forwarded_read_data1 =
        (forward_A == 2'b10) ? mem_write_data:
        (forward_A == 2'b01) ? wb_write_data:
        ex_read_data1;  



    // forward_B =
    // 10 -> from EX/MEM
    // 01 -> from MEM/WB
    // 00 -> Neither
    assign ex_forwarded_read_data2 =
        (forward_B == 2'b10) ? mem_write_data:
        (forward_B == 2'b01) ? wb_write_data:
        ex_read_data2;

    wire div_stall;
    wire fpu_stall;

    (* dont_touch = "yes" *)
    ex_stage #(
        .BUS_WIDTH(BUS_WIDTH),
        .ALU_CONTROL_WIDTH(ALU_CONTROL_WIDTH),
        .ALU_SELECT_WIDTH(ALU_SELECT_WIDTH),
        .FPU_OP_WIDTH(FPU_OP_WIDTH)
    ) ex_stage_instance (
        .clk(clk),
        .rst(rst),
        .alu_src(ex_alu_src),
        .alu_fpu(ex_alu_fpu),
        .jump_src(ex_jump_src),
        
        .read_data1(ex_forwarded_read_data1),
        .read_data2(ex_forwarded_read_data2),
        
        .control(ex_control),
        .select(ex_select),
        
        .fpu_op(ex_fpu_op),
        
        .imm(ex_imm),
        .pc(ex_pc),
        
        .div_stall(div_stall),
        .fpu_stall(fpu_stall),
        .alu_fpu_result(ex_alu_fpu_result)
    );

    //==============================================
    // EX MEM PIPELINE REGISTER
    //==============================================

    wire ex_mem_stall;
    wire ex_mem_rst;

    // Control Pins
    wire mem_reg_write;
    wire mem_mem_write;
    wire mem_mem_read;
    wire mem_mem_to_reg;
    wire mem_jalr_src;
    wire mem_u_src;
    wire mem_uj_src;

    // REGFILE Outputs
    wire [(REGFILE_LEN - 1):0] mem_rs1;
    wire [(REGFILE_LEN - 1):0] mem_rs2;
    wire [(REGFILE_LEN - 1):0] mem_rd;

    // IMMGEN and ALU Results
    wire [(BUS_WIDTH - 1):0] mem_imm;

    wire [(BUS_WIDTH - 1):0] mem_pc;
    wire [(INSTR_WIDTH - 1):0] mem_instr;

    // pretty trippy but bare with me
    // first "mem" indicates stage, next "mem_in" is the variable name
    wire [(BUS_WIDTH - 1):0] mem_mem_in;

    (* dont_touch = "yes" *)
    ex_mem_reg #(
        .BUS_WIDTH(BUS_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH),
        .REGFILE_LEN(REGFILE_LEN)
    ) ex_mem_reg_instance (
        .clk(clk),
        .rst(ex_mem_rst | rst),
        .stall(ex_mem_stall),
        
        .in_reg_write(ex_reg_write),
        .in_mem_write(ex_mem_write),
        .in_mem_read(ex_mem_read),
        .in_mem_to_reg(ex_mem_to_reg),
        .in_jalr_src(ex_jalr_src),
        .in_u_src(ex_u_src),
        .in_uj_src(ex_uj_src),
        
        .in_rs1(ex_rs1),
        .in_rs2(ex_rs2),
        .in_rd(ex_rd),
        
        .in_imm(ex_imm),
        .in_pc(ex_pc),
        .in_instr(ex_instr),
        .in_alu_fpu_result(ex_alu_fpu_result),
        .in_mem_in(ex_forwarded_read_data2),
        
        .out_reg_write(mem_reg_write),
        .out_mem_write(mem_mem_write),
        .out_mem_read(mem_mem_read),
        .out_mem_to_reg(mem_mem_to_reg),
        .out_jalr_src(mem_jalr_src),
        .out_u_src(mem_u_src),
        .out_uj_src(mem_uj_src),
        
        .out_rs1(mem_rs1),
        .out_rs2(mem_rs2),
        .out_rd(mem_rd),
        
        .out_imm(mem_imm),
        .out_pc(mem_pc),
        .out_instr(mem_instr),
        .out_alu_fpu_result(mem_alu_fpu_result),
        .out_mem_in(mem_mem_in)
    );

    //==============================================
    // MEM STAGE
    //==============================================

    wire [(BUS_WIDTH - 1):0] mem_mem_out;
    wire [(BUS_WIDTH - 1):0] mem_write_data;

    (* dont_touch = "yes" *)
    mem_stage #(
        .BUS_WIDTH(BUS_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH),
        .DATA_MEM_LEN(DATA_MEM_LEN),
        .MEM_BIT_WIDTH(MEM_BIT_WIDTH)
    ) mem_stage_instance (
        .clk(clk),
        
        // Control Pins
        .mem_write(mem_mem_write),
        .mem_read(mem_mem_read),
        .jalr_src(mem_jalr_src),
        .u_src(mem_u_src),
        .uj_src(mem_uj_src),
        
        // Data Inputs
        .imm(mem_imm),
        .pc(mem_pc),
        .alu_fpu_result(mem_alu_fpu_result),
        .mem_in(mem_mem_in),
        .instr(mem_instr),
        
        // Data Outputs
        .mem_out(mem_mem_out),
        .write_data(mem_write_data),

        // DATA MEM AXI Control
        .axi_clk(axi_data_clk),
        .axi_en(axi_data_en),
        .axi_we(axi_data_we),
        .axi_addr(axi_data_addr),
        .axi_din(axi_data_din),
        .axi_dout(axi_data_dout)
    );

    //==============================================
    // MEM WB PIPELINE REGISTER
    //==============================================

    wire mem_wb_stall;
    wire mem_wb_rst;

    wire wb_mem_to_reg;
    wire [(BUS_WIDTH - 1):0] wb_mem_out;

    (* dont_touch = "yes" *)
    mem_wb_reg #(
        .BUS_WIDTH(BUS_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH),
        .REGFILE_LEN(REGFILE_LEN)
    ) mem_wb_reg_instance (
        .clk(clk),
        .rst(rst),
        .stall(mem_wb_rst | mem_wb_stall),
        
        .in_reg_write(mem_reg_write),
        .in_mem_to_reg(mem_mem_to_reg),
        .in_rd(mem_rd),
        .in_mem_out(mem_mem_out),
        .in_write_data(mem_write_data),
        
        .out_reg_write(wb_reg_write),
        .out_mem_to_reg(wb_mem_to_reg),
        .out_rd(wb_rd),
        .out_mem_out(wb_mem_out),
        .out_write_data(wb_reg_write_data)
    );

    assign wb_write_data = wb_mem_to_reg ? wb_mem_out: wb_reg_write_data;


    //==============================================
    // STALLING UNIT
    //==============================================

    // to add a stall because of instruction memory
    // having 1 cycle latency
    wire compulsory_stall;

    // Load Hazard Stalling
    wire load_stall;
    wire load_jump_branch_stall;

    // Branch Hazard Stalling
    wire jump_stall;

    (* dont_touch = "yes" *)
    stall_unit stall_unit_instance (
        .clk(clk),
        .rst(rst),
        .stall(1'b0),
        .out_stall(compulsory_stall)
    );

    assign pc_stall = compulsory_stall | load_stall | load_jump_branch_stall | div_stall | fpu_stall;
    assign if_id_stall = compulsory_stall | load_stall | load_jump_branch_stall | div_stall | fpu_stall;
    assign id_ex_stall = compulsory_stall | load_jump_branch_stall | div_stall | fpu_stall;
    assign ex_mem_stall = compulsory_stall | div_stall | fpu_stall;
    assign mem_wb_stall = compulsory_stall | div_stall | fpu_stall;

    assign if_id_rst = (~compulsory_stall) & (jump_stall & ~load_jump_branch_stall) & (~div_stall) & (~fpu_stall);
    assign id_ex_rst = (~compulsory_stall) & (load_stall | load_jump_branch_stall);
    assign ex_mem_rst = 1'b0;
    assign mem_wb_rst = 1'b0;


    //==============================================
    // FORWARDING UNIT
    //==============================================

    (* dont_touch = "yes" *)
    forwarding_unit #(
        .REGFILE_LEN(REGFILE_LEN),
        .INSTR_WIDTH(INSTR_WIDTH),
        .FORWARD_ALU_SELECT_WIDTH(FORWARD_ALU_SELECT_WIDTH),
        .OPCODE_WIDTH(OPCODE_WIDTH),
        .FUNCT3_WIDTH(FUNCT3_WIDTH)
    ) forwarding_unit_instance (
        .reg_write_ID_EX(ex_reg_write),
        .reg_write_EX_MEM(mem_reg_write),
        .reg_write_MEM_WB(wb_reg_write),
        
        .instr_IF_ID(id_instr),
        
        .rs1_IF_ID(id_rs1),
        .rs2_IF_ID(id_rs2),
        .rs1_ID_EX(ex_rs1),
        .rs2_ID_EX(ex_rs2),
        .rd_ID_EX(ex_rd),
        .rd_EX_MEM(mem_rd),
        .rd_MEM_WB(wb_rd),
        
        .forward_A(forward_A),
        .forward_B(forward_B),
        
        .forward_jalr_ID_EX(forward_jalr_ID_EX),
        .forward_jalr_EX_MEM(forward_jalr_EX_MEM),
        .forward_jalr_MEM_WB(forward_jalr_MEM_WB),

        .forward_branch_ID_EX_A(forward_branch_ID_EX_A),
        .forward_branch_ID_EX_B(forward_branch_ID_EX_B),
        .forward_branch_EX_MEM_A(forward_branch_EX_MEM_A),
        .forward_branch_EX_MEM_B(forward_branch_EX_MEM_B),
        .forward_branch_MEM_WB_A(forward_branch_MEM_WB_A),
        .forward_branch_MEM_WB_B(forward_branch_MEM_WB_B)
    );
    
    //==============================================
    // HAZARD DETECTION UNIT
    //==============================================

    (* dont_touch = "yes" *)
    hdu #(
        .REGFILE_LEN(REGFILE_LEN)
    ) hdu_instance (
        .clk(clk),
        .rst(rst),
        .rs1_IF_ID(id_rs1),
        .rs2_IF_ID(id_rs2),
        .rd_ID_EX(ex_rd),
        .rd_EX_MEM(mem_rd),
        .mem_read_ID_EX(ex_mem_read),
        .mem_read_EX_MEM(mem_mem_read),
        .branch_prediction_failed(branch_prediction_failed),
        .is_branch_IF_ID(id_is_branch),
        .jump_taken_IF_ID(id_jump_taken),
        .load_stall(load_stall),
        .load_jump_branch_stall(load_jump_branch_stall),
        .jump_stall(jump_stall)
    );
endmodule