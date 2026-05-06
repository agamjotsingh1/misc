module mem_stage #(
    parameter BUS_WIDTH=64,
    parameter INSTR_WIDTH=32,
    parameter DATA_MEM_LEN=12,
    parameter MEM_BIT_WIDTH=2
)(
    input wire sys_clk,
    input wire clk,

    // Control Pins
    input wire mem_write,
    input wire mem_read,
    input wire jalr_src,
    input wire u_src,
    input wire uj_src,

    input wire [(BUS_WIDTH - 1):0] alu_fpu_result,
    input wire [(BUS_WIDTH - 1):0] mem_in,

    // IMMGEN output
    input wire [(BUS_WIDTH - 1):0] imm,

    input wire [(BUS_WIDTH - 1):0] pc,
    input wire [(INSTR_WIDTH - 1):0] instr,

    output wire [(BUS_WIDTH - 1):0] mem_out,
    output wire [(BUS_WIDTH - 1):0] write_data,

    // AXI controller
    input wire axi_clk,
    input wire axi_en,
    input wire axi_we,
    input wire [63:0] axi_addr,
    input wire [7:0] axi_din,
    output wire [7:0] axi_dout
);
    // NOTE: for the following code
    // please refer to the report for this
    // this is not understantable without glancing the datapath

    // auipc, lui, branch, jal support 
    // note that immgen block already gives out shifted by 12
    // for branch and jal, imm is shifted by just 1
    wire [(BUS_WIDTH - 1):0] pc_plus_imm;
    assign pc_plus_imm = pc + imm;

    wire [(BUS_WIDTH - 1):0] pc_plus_4 = pc + 4;

    assign write_data = uj_src ?
                        (jalr_src ? pc_plus_4: alu_fpu_result)
                        :(u_src ? pc_plus_imm: imm);

    // DATA MEM is split into 8 sepereate interleaved memory units
    // All of these 8 units will be written/read in parallel
    // This is to support all store and load variants
    // W/ Parallel 2 cycle clock delay
    wire mem_en, mem_wea, mem_sign_extend;
    wire [(MEM_BIT_WIDTH - 1):0] mem_bit_width;

    data_mem_control #(
        .MEM_BIT_WIDTH(MEM_BIT_WIDTH)
    ) data_mem_control_instance (
        .funct3(instr[14:12]),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_stall(1'b0),
        .en(mem_en),
        .wea(mem_wea),
        .sign_extend(mem_sign_extend),
        .bit_width(mem_bit_width)
    );

    data_mem_unit #(
        .BUS_WIDTH(BUS_WIDTH),
        .DATA_MEM_LEN(DATA_MEM_LEN),
        .MEM_BIT_WIDTH(MEM_BIT_WIDTH)
    ) data_mem_instance (
        .clk(clk),
        .en(mem_en),
        .wea(mem_wea),
        .addr(alu_fpu_result),
        .din(mem_in),
        .sign_extend(mem_sign_extend),
        .bit_width(mem_bit_width),
        .dout(mem_out),
        .axi_clk(axi_clk),
        .axi_en(axi_en),
        .axi_we(axi_we),
        .axi_addr(axi_addr),
        .axi_din(axi_din),
        .axi_dout(axi_dout)
    );
endmodule