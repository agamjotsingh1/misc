module ex_stage #(
    parameter BUS_WIDTH=64,
    parameter ALU_CONTROL_WIDTH=2,
    parameter ALU_SELECT_WIDTH=3,
    parameter FPU_OP_WIDTH=6
)(
    input wire clk, // for multicycle division
    input wire rst,

    // Control Pins
    input wire jump_src,
    input wire alu_src,
    input wire alu_fpu,

    // REGFILE Outputs
    input wire [(BUS_WIDTH - 1):0] read_data1,
    input wire [(BUS_WIDTH - 1):0] read_data2,

    // ALU Controls
    input wire [(ALU_CONTROL_WIDTH - 1):0] control,
    input wire [(ALU_SELECT_WIDTH - 1):0] select,

    // FPU Controls
    input wire [(FPU_OP_WIDTH - 1):0] fpu_op,

    // IMMGEN output
    input wire [(BUS_WIDTH - 1):0] imm,

    input wire [(BUS_WIDTH - 1):0] pc,

    output wire div_stall, // stall for multicycle division
    output wire fpu_stall, // stall for multicycle fpu 
    output wire [(BUS_WIDTH - 1):0] alu_fpu_result
);
    wire [(BUS_WIDTH - 1):0] alu_fpu_in1 = read_data1;
    wire [(BUS_WIDTH - 1):0] alu_fpu_in2 = alu_src ? imm: read_data2;

    wire [(BUS_WIDTH - 1):0] alu_out;
    wire [(BUS_WIDTH - 1):0] fpu_out;

    alu #(
        .BUS_WIDTH(BUS_WIDTH),
        .ALU_CONTROL_WIDTH(ALU_CONTROL_WIDTH),
        .ALU_SELECT_WIDTH(ALU_SELECT_WIDTH)
    ) alu_instance (
        .clk(clk),
        .in1(alu_fpu_in1),
        .in2(alu_fpu_in2),
        .control(control),
        .select(select),
        .out(alu_out)
    );

    wire is_div_instr = (select == 3'b010);
    
    wire is_fpu_sqrt  = (fpu_op == 6'b001000)     // fsqrt.d
                        | (fpu_op == 6'b001001);  // fsqrt.s

    wire is_fpu_div   = (fpu_op == 6'b000110)     // fdiv.d
                        | (fpu_op == 6'b000111);  // fdiv.s

    div_stall_unit div_stall_unit_instance (
        .clk(clk),
        .rst(rst),
        .is_div_instr(is_div_instr),
        .div_stall(div_stall)
    );

    fpu_stall_unit fpu_stall_unit_instance (
        .clk(clk),
        .rst(rst),
        .is_fpu_div(is_fpu_div),
        .is_fpu_sqrt(is_fpu_sqrt),
        .fpu_stall(fpu_stall)
    );

    fpu #(
        .BUS_WIDTH(BUS_WIDTH),
        .FPU_OP_LEN(FPU_OP_WIDTH)
    ) fpu_instance (
        .clk(clk),
        .rst(rst),
        .in1(alu_fpu_in1),
        .in2(alu_fpu_in2),
        .fpu_op(fpu_op),
        .out(fpu_out)
    );

    wire [(BUS_WIDTH - 1):0] pc_plus_4 = pc + 4;
    wire [(BUS_WIDTH - 1):0] alu_fpu_out = alu_fpu ? fpu_out: alu_out;

    // handling jal and jalr instructions
    // rd = PC + 4
    assign alu_fpu_result = jump_src ? pc_plus_4: alu_fpu_out;
endmodule