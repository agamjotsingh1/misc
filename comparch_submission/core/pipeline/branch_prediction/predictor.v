module predictor #(
    parameter INSTR_WIDTH=32
)(
    input wire [(INSTR_WIDTH - 1):0] instruction,
    input wire truth, // 1 means it has branched previously
    input wire clk,
    input wire reset,
    input wire stall,
    input wire enable,
    output wire next_prediction // 1 means predicting it will branch
);
    reg [4:0] incoming_sequence;
    reg [1:0] matching_sequence [15:0];
    wire [3:0] index = incoming_sequence[4:1];

    integer i;

    always @(negedge clk) begin
        if(reset) begin
            incoming_sequence <= 5'b00000;
            for(i = 0; i < 16; i = i + 1) begin
                matching_sequence[i] <= 2'b01; 
            end
        end

        else if(enable & ~stall) begin
            incoming_sequence <= (incoming_sequence << 1) | truth;
            if(truth) begin
                if(matching_sequence[index] != 2'b11)
                    matching_sequence[index] <= matching_sequence[index] + 1'b1;
            end

            else begin
                if(matching_sequence[index] != 2'b00) matching_sequence[index] <= matching_sequence[index] - 1'b1;
            end
        end
    end

    assign next_prediction = enable & matching_sequence[index][1];
endmodule
