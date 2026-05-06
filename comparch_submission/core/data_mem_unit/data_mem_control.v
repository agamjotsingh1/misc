module data_mem_control #(
    parameter MEM_BIT_WIDTH=2
)(
    input wire [2:0] funct3,
    input wire mem_read,
    input wire mem_write,
    input wire mem_stall, // memory stall status

    output reg en, // data memory enable flag (for both read and write)
    output reg wea, // data memory write enable flag
    output reg sign_extend,
    output reg [(MEM_BIT_WIDTH - 1):0] bit_width
);
    always @(*) begin
        if(mem_read) begin // load instructions
            en = ~mem_stall;
            wea = 0;

            case (funct3)
                3'b000: begin // lb
                    bit_width = 2'b00;
                    sign_extend = 1;
                end
                3'b001: begin // lh
                    bit_width = 2'b01;
                    sign_extend = 1;
                end
                3'b010: begin // lw
                    bit_width = 2'b10;
                    sign_extend = 1;
                end
                3'b011: begin // ld
                    bit_width = 2'b11;
                    sign_extend = 1;
                end
                3'b100: begin // lbu
                    bit_width = 2'b00;
                    sign_extend = 0;
                end
                3'b101: begin // lhu
                    bit_width = 2'b01;
                    sign_extend = 0;
                end
                3'b110: begin // lwu
                    bit_width = 2'b10;
                    sign_extend = 0;
                end
                default: begin
                    bit_width = 2'b11;
                    sign_extend = 1;
                end
            endcase
        end
        else if(mem_write) begin // store instructions
            en = ~mem_stall;
            wea = ~mem_stall;
            sign_extend = 1; // not needed

            case (funct3)
                3'b000: begin // sb
                    bit_width = 2'b00;
                end
                3'b001: begin // sh
                    bit_width = 2'b01;
                end
                3'b010: begin // sw
                    bit_width = 2'b10;
                end
                3'b011: begin // sd
                    bit_width = 2'b11;
                end
                default: begin
                    bit_width = 2'b11;
                end
            endcase
        end
        else begin
            en = 0;
            wea = 0;
            sign_extend = 0;
            bit_width = 2'b00;
        end
    end
endmodule