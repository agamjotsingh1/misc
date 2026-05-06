module branch_predictor #(
    parameter BUS_WIDTH=64,
    parameter INSTR_WIDTH=32
)(
    input wire clk,
    input wire compulsory_stall,
    input wire stall,
    input wire rst,
    input wire is_jump,
    input wire [(BUS_WIDTH - 1):0] if_pc,
    input wire [(INSTR_WIDTH - 1):0] if_instr,
    input wire id_branch_taken,
    input wire [(BUS_WIDTH - 1):0] next_unpredicted_pc,
    // for comparison sake
    input wire is_static_prediction,
    input wire static_prediction,
    output wire [(BUS_WIDTH - 1):0] next_predicted_pc,
    output reg branch_prediction_failed
);
    // 1 if currently in process of prediction
    reg is_branch_state;

    wire [6:0] opcode = if_instr[6:0];

    // Extract immediate to predict
    wire [(BUS_WIDTH - 1):0] imm = {{51{if_instr[31]}}, if_instr[31], if_instr[7], if_instr[30:25], if_instr[11:8], 1'b0}; // B type

    reg prediction;
    wire next_dynamic_prediction;
    wire next_prediction;

    predictor predictor_instance (
        .clk(clk),
        .reset(rst),
        .stall(compulsory_stall),
        .enable(is_branch_state),
        .instruction(if_instr),
        .truth(id_branch_taken), // 1 means it has branched previously
        .next_prediction(next_dynamic_prediction) // 1 means predicting it will branch
    );

    assign next_prediction = is_static_prediction ? static_prediction: next_dynamic_prediction;

    reg [(BUS_WIDTH - 1):0] failed_pc;
    reg [(BUS_WIDTH - 1):0] stored_imm;

    always @(negedge clk) begin
        if(rst) begin
            is_branch_state <= 0;
            branch_prediction_failed <= 0;
            failed_pc <= 0;
            prediction <= 0;
            stored_imm <= 0;
        end
        else if(~stall) begin
            if(is_branch_state) begin
                is_branch_state <= (opcode == 7'b1100011) & branch_prediction_failed;
                branch_prediction_failed <= (is_branch_state & (next_prediction != id_branch_taken));
                failed_pc <= next_prediction ? (if_pc - stored_imm + 4): next_unpredicted_pc;
                prediction <= next_prediction;
                stored_imm <= imm;
            end
            else if(opcode == 7'b1100011) begin
                is_branch_state <= 1;
                branch_prediction_failed <= 0;
                prediction <= next_prediction;
                stored_imm <= imm;
            end
            else begin
                is_branch_state <= 0;
                branch_prediction_failed <= 0;
            end
        end
    end

    assign next_predicted_pc = branch_prediction_failed
                               ? failed_pc
                               : (is_branch_state & next_prediction ? if_pc + imm
                               : (~is_jump & prediction & ~branch_prediction_failed ? if_pc + 4: next_unpredicted_pc));
endmodule