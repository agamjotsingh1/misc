module branch_control #(
    parameter BRANCH_SRC_WIDTH=3
)(
    input wire [(BRANCH_SRC_WIDTH - 1):0] branch_src,

    // ALU Flags
    input wire zero,
    input wire neg,
    input wire negu,

    output reg branch
);
    always @(*) begin
        case (branch_src)
            3'b000: branch = 0; // no branch
            3'b001: branch = zero; // beq
            3'b010: branch = ~zero; // bne
            3'b011: branch = neg; // blt
            3'b100: branch = (~neg) | zero; // bge
            3'b101: branch = negu; // bltu
            3'b110: branch = (~negu) | zero; // bgeu
            default: branch = 0;
        endcase
    end
endmodule