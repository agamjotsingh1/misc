module alu_control #(
    parameter INSTR_WIDTH=32,
    parameter ALU_CONTROL_WIDTH=2,
    parameter ALU_SELECT_WIDTH=3
)(
    input wire [(INSTR_WIDTH - 1):0] instr,

    // ALUOp
    output reg [(ALU_CONTROL_WIDTH - 1):0] control,
    output reg [(ALU_SELECT_WIDTH - 1):0] select
);
    wire [6:0] opcode;
    assign opcode = instr[6:0];

    wire [2:0] funct3;
    assign funct3 = instr[14:12];

    wire [6:0] funct7;
    assign funct7 = instr[31:25];

    always @(*) begin
        casez ({opcode, funct3, funct7})
            17'b0110011_000_0000000, // add
            17'b0010011_000_zzzzzzz, // addi
            17'b0000011_000_zzzzzzz, // lb
            17'b0000011_001_zzzzzzz, // lh
            17'b0000011_010_zzzzzzz, // lw
            17'b0000011_011_zzzzzzz, // ld
            17'b0000011_100_zzzzzzz, // lbu
            17'b0000011_101_zzzzzzz, // lhu
            17'b0100011_000_zzzzzzz, // sb
            17'b0100011_001_zzzzzzz, // sh
            17'b0100011_010_zzzzzzz, // sw
            17'b0100011_011_zzzzzzz // sd
            : begin
                select = 3'b000;
                control = 2'b00;
            end

            17'b0110011_000_0100000 // sub
            : begin
                select = 3'b000;
                control = 2'b01;
            end

            17'b0110011_010_0000000, // slt
            17'b0010011_010_zzzzzzz // slti
            : begin
                select = 3'b000;
                control = 2'b10;
            end

            17'b0110011_011_0000000, // sltu
            17'b0010011_011_zzzzzzz // sltui
            : begin
                select = 3'b000;
                control = 2'b11;
            end

            17'b0110011_000_0000001 // mul
            : begin
                select = 3'b001;
                control = 2'b00;
            end

            17'b0110011_001_0000001 // mulh
            : begin
                select = 3'b001;
                control = 2'b01;
            end

            17'b0110011_010_0000001 // mulhsu
            : begin
                select = 3'b001;
                control = 2'b10;
            end

            17'b0110011_011_0000001 // mulhu
            : begin
                select = 3'b001;
                control = 2'b11;
            end

            17'b0110011_100_0000001 // div
            : begin
                select = 3'b010;
                control = 2'b00;
            end

            17'b0110011_101_0000001 // divu
            : begin
                select = 3'b010;
                control = 2'b01;
            end

            17'b0110011_110_0000001 // rem
            : begin
                select = 3'b010;
                control = 2'b10;
            end

            17'b0110011_111_0000001 // remu
            : begin
                select = 3'b010;
                control = 2'b11;
            end

            17'b0110011_001_0000000, // sll
            17'b0010011_001_zzzzzzz // slli
            : begin
                select = 3'b011;
                control = 2'b00; // not needed
            end

            17'b0110011_101_0000000, // srl
            17'b0010011_101_zzzzzzz // srli
            : begin
                select = 3'b100;
                control = 2'b00; // only first bit used
            end

            17'b10110011_101_0100000, // sra
            17'b0010011_101_zzzzzzz // srai
            : begin
                select = 3'b100;
                control = 2'b01; // only first bit used
            end

            17'b0110011_100_0000000, // xor
            17'b0010011_100_zzzzzzz // xori
            : begin
                select = 3'b101;
                control = 2'b00; // not needed
            end

            17'b0110011_110_0000000, // or
            17'b0010011_110_zzzzzzz // ori
            : begin
                select = 3'b110;
                control = 2'b00; // not needed
            end

            17'b0110011_111_0000000, // and
            17'b0010011_111_zzzzzzz // andi
            : begin
                select = 3'b111;
                control = 2'b00; // not needed
            end

            default: begin
                select = 3'b000;
                control = 2'b00;
            end
        endcase
    end
endmodule