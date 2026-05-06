// Instruction memory has 1 cycle delay
// So one cycle after every instruction has to be added
module stall_unit (
    input wire clk,
    input wire rst,
    input wire stall,

    output wire out_stall
);
    reg stall_fsm [0:1];

    always @(posedge clk) begin
        if(rst | stall) begin
            stall_fsm[0] <= 1'b1;
            stall_fsm[1] <= 1'b0;
        end
        else begin
            stall_fsm[0] <= stall_fsm[1];
            stall_fsm[1] <= stall_fsm[0];
        end
    end

    assign out_stall = ~stall_fsm[0];
endmodule