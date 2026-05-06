// To stall for 10 cycles for division to work
// Division IP is manually configured to have 10 cycle delay
// Done to reduce clock timing
module div_stall_unit (
    input wire clk,
    input wire rst,
    input wire is_div_instr,
    output wire div_stall
);
    localparam STALL_CYCLES = 10;

    reg [$clog2(STALL_CYCLES):0] counter = 0;
    reg active;

    always @(posedge clk) begin
        if (rst) begin
            active  <= 0;
            counter <= 0;
        end else begin
            if (is_div_instr & (~active)) begin
                active  <= 1;
                counter <= (STALL_CYCLES - 1);
            end else if (active) begin
                if (counter == 0)
                    active <= 0;
                else
                    counter <= counter - 1;
            end
        end
    end

    assign div_stall = active;
endmodule