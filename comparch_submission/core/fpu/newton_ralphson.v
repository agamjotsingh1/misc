// STALL REQUIREMENT = 4
module newton_ralphson #(
    parameter BUS_WIDTH = 64
) (
    input wire clk,
    input wire rst,
    input wire [BUS_WIDTH-1:0] x,
    input wire [BUS_WIDTH-1:0] y,
    output wire [BUS_WIDTH-1:0] y_nr
);

    // --- Constants ---
    wire [BUS_WIDTH-1:0] XOR_CONST = (BUS_WIDTH == 64) ? 64'h8000000000000000 : 32'h80000000;
    wire [BUS_WIDTH-1:0] HALF = (BUS_WIDTH == 64) ? 64'h3fe0000000000000 : 32'h3f000000;
    wire [BUS_WIDTH-1:0] THREE_HALVES = (BUS_WIDTH == 64) ? 64'h3ff8000000000000 : 32'h3fc00000;

    // --- Pipeline Registers ---
    
    // Stage 1 Registers (after y*y)
    reg [BUS_WIDTH-1:0] s1_y_sq; 
    reg [BUS_WIDTH-1:0] s1_x;    // Delaying x
    reg [BUS_WIDTH-1:0] s1_y;    // Delaying y

    // Stage 2 Registers (after y^2 * 0.5)
    reg [BUS_WIDTH-1:0] s2_y_2;
    reg [BUS_WIDTH-1:0] s2_x;    // Delaying x
    reg [BUS_WIDTH-1:0] s2_y;    // Delaying y

    // Stage 3 Registers (after (y^2 * 0.5) * x)
    reg [BUS_WIDTH-1:0] s3_y_3;
    reg [BUS_WIDTH-1:0] s3_y;    // Delaying y (x is used here, so we stop delaying it)

    // Stage 4 Registers (after 1.5 - ...)
    reg [BUS_WIDTH-1:0] s4_y_5;
    reg [BUS_WIDTH-1:0] s4_y;    // Delaying y

    // --- Combinational Wires (Outputs of FP units) ---
    wire [BUS_WIDTH-1:0] w_y_sq;
    wire [BUS_WIDTH-1:0] w_y_2;
    wire [BUS_WIDTH-1:0] w_y_3;
    wire [BUS_WIDTH-1:0] w_y_5;

    // ============================================================
    // STAGE 1: Calculate y^2
    // ============================================================
    FPMul #(.BUS_WIDTH(BUS_WIDTH)) mul_sq (
        .in1(y),
        .in2(y),
        .out(w_y_sq)
    );

    always @(posedge clk) begin
        if (rst) begin
            s1_y_sq <= 0;
            s1_x    <= 0;
            s1_y    <= 0;
        end else begin
            s1_y_sq <= w_y_sq; // Register result
            s1_x    <= x;      // Start delaying x
            s1_y    <= y;      // Start delaying y
        end
    end

    // ============================================================
    // STAGE 2: Calculate y^2 * 0.5
    // ============================================================
    FPMul #(.BUS_WIDTH(BUS_WIDTH)) mul_half (
        .in1(s1_y_sq),
        .in2(HALF),
        .out(w_y_2)
    );

    always @(posedge clk) begin
        if(rst) begin
            s2_y_2 <= 0;
            s2_x   <= 0;
            s2_y   <= 0;
        end else begin
            s2_y_2 <= w_y_2;
            s2_x   <= s1_x;    // Pass x forward
            s2_y   <= s1_y;    // Pass y forward
        end
    end

    // ============================================================
    // STAGE 3: Calculate (y^2 * 0.5) * x
    // ============================================================
    // We finally use the delayed 'x' here (s2_x)
    FPMul #(.BUS_WIDTH(BUS_WIDTH)) mul_x (
        .in1(s2_y_2),
        .in2(s2_x),    // Using delayed x
        .out(w_y_3)
    );

    always @(posedge clk) begin
        if (rst) begin
            s3_y_3 <= 0;
            s3_y   <= 0;
        end else begin
            s3_y_3 <= w_y_3;
            s3_y   <= s2_y;    // Keep passing y forward
        end
    end

    // ============================================================
    // STAGE 4: Calculate 1.5 - (result)
    // ============================================================
    // Note: Floating point subtraction is often done by flipping the sign bit (XOR) and Adding.
    wire [BUS_WIDTH-1:0] y_4_negated = s3_y_3 ^ XOR_CONST;

    FPAdder #(.BUS_WIDTH(BUS_WIDTH)) add_sub (
        .in1(THREE_HALVES),
        .in2(y_4_negated),
        .out(w_y_5)
    );

    always @(posedge clk) begin
        if (rst) begin
            s4_y_5 <= 0;
            s4_y   <= 0;
        end else begin
            s4_y_5 <= w_y_5;
            s4_y   <= s3_y;    // Keep passing y forward
        end
    end

    // ============================================================
    // STAGE 5: Final Multiplication y * (result)
    // ============================================================
    // We finally use the delayed 'y' here (s4_y)
    FPMul #(.BUS_WIDTH(BUS_WIDTH)) mul_final (
        .in1(s4_y),     // Using delayed y
        .in2(s4_y_5),
        .out(y_nr)
    );
endmodule