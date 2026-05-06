// each data mem sub unit is 64 x (2^17) dimensions long
module data_mem_unit #(
    parameter BUS_WIDTH=64,
    parameter DATA_MEM_LEN=12,
    parameter MEM_BIT_WIDTH=2
)(
    input wire clk,
    input wire en,
    input wire wea, // write enable
    input wire [(BUS_WIDTH - 1):0] addr, // only last 11 bits will be used
    input wire [(BUS_WIDTH - 1):0] din,
    input wire sign_extend, // 1 if sign has to be extended (signed)

    /* bit_width
       00 -> 8 bits (byte)
       01 -> 16 bits (half word)
       10 -> 32 bits (word)
       11 -> 64 bits (double word)
    */
    input wire [(MEM_BIT_WIDTH - 1):0] bit_width,
    output wire [(BUS_WIDTH - 1):0] dout,

    // DEBUG
    output wire [63:0] axi_col_dout,

    // AXI controller
    input wire axi_clk,
    input wire axi_en,
    input wire axi_we,
    input wire [(BUS_WIDTH - 1):0] axi_addr,
    input wire [7:0] axi_din, // 1 byte
    output wire [7:0] axi_dout // 1 byte
);

    localparam COL_WIDTH = 3;
    localparam ROW_WIDTH = (BUS_WIDTH - COL_WIDTH);
    localparam BYTE = 8;

    wire [(COL_WIDTH - 1):0] col = addr[(COL_WIDTH - 1):0];
    wire [(ROW_WIDTH - 1):0] row = addr[(BUS_WIDTH - 1):COL_WIDTH];

    // short for "write enables"
    wire [(BYTE - 1):0] weas;  // enables for all 8 seperate data memory instances
    reg [(BYTE - 1):0] weas_unrotated;  // unrotated weas

    always @(*) begin
        case (bit_width)
            2'b00: weas_unrotated = 8'b00000001; // 8 bits
            2'b01: weas_unrotated = 8'b00000011; // 16 bits
            2'b10: weas_unrotated = 8'b00001111; // 32 bits
            2'b11: weas_unrotated = (BUS_WIDTH == 64) ? 8'b11111111: 8'b0; // 64 bits
            default: weas_unrotated = 8'b00000000;
        endcase
    end

    // circular left shift by 'col' to find actual write enables
    assign weas = (weas_unrotated << col) | (weas_unrotated >> (BYTE - col));

    // multiply by 8 (shift by 3)
    wire [(2*COL_WIDTH - 1):0] col_shift = {{COL_WIDTH{1'b0}}, col} << COL_WIDTH;

    wire [(2*COL_WIDTH - 1):0] reverse_col_shift = 64 - col_shift;

    localparam MEM_DEPTH_WIDTH = 64; // number of bits in one row of a sub unit

    // same thing for din, but with shift amount = col * 8
    wire [(MEM_DEPTH_WIDTH - 1):0] din_rotated =
                    ({{(MEM_DEPTH_WIDTH-BUS_WIDTH){1'b0}}, din} << col_shift) | 
                    ({{(MEM_DEPTH_WIDTH-BUS_WIDTH){1'b0}}, din} >> reverse_col_shift); 

    // memory addresses is arranged in a matrix-ish grid
    // [0, 1, 2, 3, 4, 5, 6, 7
    //  9,10,11,12,13,14,15,16
    // .......................]

    wire [(MEM_DEPTH_WIDTH - 1):0] dout_raw_unrotated_z;  // May contain z instead of zero

    wire [(BUS_WIDTH - 1):0] axi_addr_shifted = axi_addr >> 2;
    wire [(COL_WIDTH - 1):0] axi_col = axi_addr_shifted[(COL_WIDTH - 1):0];
    wire [(ROW_WIDTH - 1):0] axi_row = axi_addr_shifted[(BUS_WIDTH - 1):COL_WIDTH];

    genvar i;
    generate
        for(i = 0; i < 8; i = i + 1) begin
            data_mem data_mem_sub_unit (
                .clka(clk),
                .ena(en),
                .wea(weas[i] & wea),
                .addra(row[(DATA_MEM_LEN - 1):0] + (i < col ? {{(DATA_MEM_LEN - 1){1'b0}}, 1'b1}: {DATA_MEM_LEN{1'b0}})),
                .dina(din_rotated[(i << 3) +: 8]),
                .douta(dout_raw_unrotated_z[(i << 3) +: 8]),
                .clkb(axi_clk),
                .enb(axi_en),
                .web(axi_we & (i == axi_col)),
                .addrb(axi_row[(DATA_MEM_LEN - 1):0]),
                .dinb(axi_din),
                .doutb(axi_col_dout[(i << 3) +: 8])
            );
        end
    endgenerate

    wire [(2*COL_WIDTH - 1):0] axi_shifted_col = (axi_col) << 3;
    assign axi_dout = axi_col_dout[axi_shifted_col +: 8];

    // Convert z to 0 using or with 0
    wire [(MEM_DEPTH_WIDTH - 1):0] dout_raw_unrotated = dout_raw_unrotated_z | {MEM_DEPTH_WIDTH{1'b0}};
    reg [(MEM_DEPTH_WIDTH - 1):0] dout_raw_rotated;

    // right circular shift for dout to get what was actually put in
    always @(*) begin
        dout_raw_rotated = (dout_raw_unrotated >> col_shift) | (dout_raw_unrotated << reverse_col_shift);

        case (bit_width)
            2'b00: dout_raw_rotated[63:8] = sign_extend ? {56{dout_raw_rotated[7]}} : 56'b0;
            2'b01: dout_raw_rotated[63:16] = sign_extend ? {48{dout_raw_rotated[15]}} : 48'b0;
            2'b10: dout_raw_rotated[63:32] = sign_extend ? {32{dout_raw_rotated[31]}} : 32'b0;
            default: dout_raw_rotated[63:0] = dout_raw_rotated[63:0]; // to prevent unecessary latches
        endcase
    end

    assign dout = dout_raw_rotated[(BUS_WIDTH - 1):0];
endmodule