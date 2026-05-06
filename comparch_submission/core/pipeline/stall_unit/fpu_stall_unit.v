module fpu_stall_unit (
    input wire clk,
    input wire rst,
    input wire is_fpu_div,
    input wire is_fpu_sqrt,
    output wire fpu_stall
);
    localparam CYCLE_BIT_WIDTH = 5;
    localparam FPU_DIV_STALL_CYCLES = 6;
    localparam FPU_SQRT_STALL_CYCLES = 10;

    reg [(CYCLE_BIT_WIDTH - 1):0] counter = 0;
    reg active;
    reg prev_active;

    always @(posedge clk) begin
        if (rst) begin
            active  <= 0;
            prev_active  <= 0;
            counter <= 0;
        end else begin
            if (is_fpu_div & (~active) & (~prev_active)) begin
                active  <= 1;
                counter <= (FPU_DIV_STALL_CYCLES - 1);
            end else if (is_fpu_sqrt & (~active) & (~prev_active)) begin
                active  <= 1;
                counter <= (FPU_SQRT_STALL_CYCLES - 1);
            end else if (active) begin
                if (counter == 0) begin
                    active <= 0;
                    prev_active <= 1;
                end
                else begin
                    counter <= counter - 1;
                end
            end else begin
                prev_active <= 0;
            end
        end
    end

    assign fpu_stall = active;
endmodule