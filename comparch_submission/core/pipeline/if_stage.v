module if_stage #(
    parameter BUS_WIDTH=64,
    parameter INSTR_MEM_LEN=15, // actual instr mem length = pow(2, INSTR_MEM_LEN)
    parameter INSTR_WIDTH=32
)(
    input wire clk,
    input wire compulsory_stall,
    input wire rst,
    input wire stall,
    input wire imm_pc, // 1 if jump to next_imm_pc, 0 if jump to PC + 4
    input wire id_branch_taken,
    input wire load_stall,
    input wire jump_taken_IF_ID,

    input wire is_static_prediction,
    input wire static_prediction,

    // NOTE next_jmp_pc should be given in word addressable format
    input wire [(BUS_WIDTH - 1):0] next_imm_pc,

    output wire [(BUS_WIDTH - 1):0] pc,
    output wire [(INSTR_WIDTH - 1):0] instr,
    output wire branch_prediction_failed,

    // INSTR MEM AXI controller
    input wire axi_instr_clk,
    input wire axi_instr_en,
    input wire [3:0] axi_instr_we, // 4 bits, axi interface critieria
    input wire [(INSTR_MEM_LEN - 1):0] axi_instr_addr,
    input wire [(INSTR_WIDTH - 1):0] axi_instr_din,
    output wire [(INSTR_WIDTH - 1):0] axi_instr_dout
);
    reg [(BUS_WIDTH - 1):0] cur_pc;
    wire [(BUS_WIDTH - 1):0] next_pc;
    wire [(BUS_WIDTH - 1):0] next_unpredicted_pc;

    // PC + 1 (plus 1 because instr memory is word addressable)
    //assign next_pc = imm_pc ? (next_imm_pc >> 2): (cur_pc + 1);

    // multiply by 4 to give actual pc (in byte addressable format)
    assign pc = cur_pc << 2;
    assign next_unpredicted_pc = imm_pc ? (next_imm_pc): (pc + 4);

    always @(posedge clk) begin
        if(rst) cur_pc <= {BUS_WIDTH{1'b0}};
        else if(~stall) cur_pc <= next_pc >> 2;
    end

    //==============================================
    // BRANCH PREDICTION UNIT 
    //==============================================

    branch_predictor #(
        .BUS_WIDTH(BUS_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH)
    ) branch_predictor_instance (
        .clk(clk),
        .stall(stall),
        .compulsory_stall(compulsory_stall),
        .rst(rst),
        .is_jump(jump_taken_IF_ID),
        .if_pc(pc),
        .if_instr(instr),
        .id_branch_taken(id_branch_taken),
        .next_unpredicted_pc(next_unpredicted_pc),
        .is_static_prediction(is_static_prediction),
        .static_prediction(static_prediction),
        .next_predicted_pc(next_pc),
        .branch_prediction_failed(branch_prediction_failed)
    );

    wire [(INSTR_MEM_LEN - 1):0] axi_instr_addr_shifted_raw = axi_instr_addr >> 2;
    wire [(INSTR_MEM_LEN - 1):0] axi_instr_addr_shifted = axi_instr_addr_shifted_raw | {INSTR_MEM_LEN{1'b0}};


    instr_mem_gen instr_mem (
        .clka(clk), // input, clock for Port A
        .addra(cur_pc[(INSTR_MEM_LEN - 1):0]), // input, address for Port A
        .ena(1'b1), // enable pin for Port A  
        .wea(4'b0), // enable pin for Port A  
        .dina({INSTR_WIDTH{1'b0}}),
        .douta(instr), // output, data output for Port A
        .clkb(axi_instr_clk), // input, clock for Port B
        .addrb(axi_instr_addr_shifted), // input, address for Port B
        .enb(axi_instr_en), // enable pin for Port B
        .web(axi_instr_we), // enable pin for Port B  
        .dinb(axi_instr_din), // data input for port B
        .doutb(axi_instr_dout) // output, data output for Port B
    );
endmodule