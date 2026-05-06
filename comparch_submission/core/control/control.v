module control #(
    parameter INSTR_WIDTH=32,
    parameter BRANCH_SRC_WIDTH=3
)(
    input wire [(INSTR_WIDTH - 1):0] instr,

    output reg reg_write,
    output reg mem_write,
    output reg mem_read,
    output reg mem_to_reg,
    output reg jump_src,
    output reg [(BRANCH_SRC_WIDTH - 1):0] branch_src,
    output reg jalr_src,
    output reg u_src,
    output reg uj_src,
    output reg alu_src,
    output reg alu_fpu // 0 for alu, 1 for fpu
);
    /* branch_src specs
        000 -> no branch
        001 -> beq 
        010 -> bne
        011 -> blt 
        100 -> bge
        101 -> bltu
        110 -> bgeu
    */

    always @(*) begin
        case (instr[6:0]) // opcode
            // R - type
            7'b0110011: begin 
                reg_write = 1;
                mem_write = 0;
                mem_read = 0;
                mem_to_reg = 0;
                jump_src = 0;
                branch_src = 3'b000;
                jalr_src = 0;
                u_src = 0;
                uj_src = 1;
                alu_src = 0;
                alu_fpu = 0;
            end

            // I - type
            7'b0010011: begin 
                reg_write = 1;
                mem_write = 0;
                mem_read = 0;
                mem_to_reg = 0;
                jump_src = 0;
                branch_src = 3'b000;
                jalr_src = 0;
                u_src = 0;
                uj_src = 1;
                alu_src = 1;
                alu_fpu = 0;
            end

            // I - type (load)
            7'b0000011: begin 
                reg_write = 1;
                mem_write = 0;
                mem_read = 1;
                mem_to_reg = 1;
                jump_src = 0;
                branch_src = 3'b000;
                jalr_src = 0;
                u_src = 0;
                uj_src = 1;
                alu_src = 1;
                alu_fpu = 0;
            end

            // I - type (jalr)
            7'b1100111: begin 
                reg_write = 1;
                mem_write = 0;
                mem_read = 0;
                mem_to_reg = 0;
                jump_src = 1;
                branch_src = 3'b000;
                jalr_src = 1;
                u_src = 0;
                uj_src = 1;
                alu_src = 1;
                alu_fpu = 0;
            end

            // S - type
            7'b0100011: begin 
                reg_write = 0;
                mem_write = 1;
                mem_read = 0;
                mem_to_reg = 0;
                jump_src = 0;
                branch_src = 3'b000;
                jalr_src = 0;
                u_src = 0;
                uj_src = 1;
                alu_src = 1;
                alu_fpu = 0;
            end

            // B - type
            7'b1100011: begin 
                reg_write = 0;
                mem_write = 0;
                mem_read = 0;
                mem_to_reg = 0;
                jump_src = 0;

                // funct3 check for determining type of branch
                case({instr[14:12]})
                    3'b000: branch_src = 3'b001; // beq
                    3'b001: branch_src = 3'b010; // bne
                    3'b100: branch_src = 3'b011; // blt
                    3'b101: branch_src = 3'b100; // bge
                    3'b110: branch_src = 3'b101; // bltu
                    3'b111: branch_src = 3'b110; // bgeu
                    default: branch_src = 3'b000;
                endcase

                jalr_src = 0;
                u_src = 0;
                uj_src = 1;
                alu_src = 0;
                alu_fpu = 0;
            end

            // U - type (lui)
            7'b0110111: begin 
                reg_write = 1;
                mem_write = 0;
                mem_read = 0;
                mem_to_reg = 0;
                jump_src = 0;
                branch_src = 3'b000;
                jalr_src = 0;
                u_src = 0;
                uj_src = 0;
                alu_src = 0;
                alu_fpu = 0;
            end

            // U - type (auipc)
            7'b0010111: begin 
                reg_write = 1;
                mem_write = 0;
                mem_read = 0;
                mem_to_reg = 0;
                jump_src = 0;
                branch_src = 3'b000;
                jalr_src = 0;
                u_src = 1;
                uj_src = 0;
                alu_src = 0;
                alu_fpu = 0;
            end

            // J - type
            7'b1101111: begin 
                reg_write = 1;
                mem_write = 0;
                mem_read = 0;
                mem_to_reg = 0;
                jump_src = 1;
                branch_src = 3'b000;
                jalr_src = 0;
                u_src = 0;
                uj_src = 1;
                alu_src = 0;
                alu_fpu = 0;
            end

            // D and F Class (FPU)
            7'b1010011, 7'b0000111: begin 
                reg_write = 1;
                mem_write = 0;
                mem_read = 0;
                mem_to_reg = 0;
                jump_src = 0;
                branch_src = 3'b000;
                jalr_src = 0;
                u_src = 0;
                uj_src = 1;
                alu_src = 0;
                alu_fpu = 1;
            end


            default: begin 
                reg_write = 0;
                mem_write = 0;
                mem_read = 0;
                mem_to_reg = 0;
                jump_src = 0;
                branch_src = 3'b000;
                jalr_src = 0;
                u_src = 0;
                uj_src = 0;
                alu_src = 0;
                alu_fpu = 0;
            end

        endcase
    end
endmodule