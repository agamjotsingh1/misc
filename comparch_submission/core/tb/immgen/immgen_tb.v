`timescale 1ns/1ps

module tb_immgen;
    reg [31:0] instr;
    wire [63:0] imm;

    // Expected value
    reg [63:0] expected_imm;
    
    // Test counters
    integer test_num;
    integer pass_count;
    integer fail_count;

    // Instantiate DUT
    immgen dut (
        .instr(instr),
        .imm(imm)
    );

    initial begin
        // Initialize
        test_num = 0;
        pass_count = 0;
        fail_count = 0;
        instr = 0;

        $display("========================================");
        $display("Starting Immediate Generator Testbench");
        $display("========================================\n");

        // ========================================
        // R-TYPE TESTS
        // ========================================
        $display("--- R-TYPE TESTS ---\n");

        test_num = test_num + 1;
        instr = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
        expected_imm = 64'h0000000000000000;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: R-type - no immediate", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: R-type", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        // ========================================
        // I-TYPE TESTS
        // ========================================
        $display("--- I-TYPE TESTS ---\n");

        test_num = test_num + 1;
        instr = {12'd100, 5'd1, 3'b000, 5'd2, 7'b0010011};
        expected_imm = 64'h0000000000000064;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: I-type ADDI (imm=100)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: I-type ADDI", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        test_num = test_num + 1;
        instr = {12'hFFF, 5'd1, 3'b000, 5'd2, 7'b0010011};
        expected_imm = 64'hFFFFFFFFFFFFFFFF;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: I-type ADDI (imm=-1)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: I-type ADDI negative", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        test_num = test_num + 1;
        instr = {12'h7FF, 5'd1, 3'b000, 5'd2, 7'b0010011};
        expected_imm = 64'h00000000000007FF;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: I-type max positive (2047)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: I-type max positive", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        test_num = test_num + 1;
        instr = {12'h800, 5'd1, 3'b000, 5'd2, 7'b0010011};
        expected_imm = 64'hFFFFFFFFFFFFF800;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: I-type min negative (-2048)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: I-type min negative", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        test_num = test_num + 1;
        instr = {12'd8, 5'd1, 3'b010, 5'd2, 7'b0000011};
        expected_imm = 64'h0000000000000008;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: I-type LW (offset=8)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: I-type LW", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        // ========================================
        // S-TYPE TESTS
        // ========================================
        $display("--- S-TYPE TESTS ---\n");

        test_num = test_num + 1;
        // SW with offset=8: imm[11:5]=0000000, imm[4:0]=01000
        instr = {7'b0000000, 5'd2, 5'd1, 3'b010, 5'b01000, 7'b0100011};
        expected_imm = 64'h0000000000000008;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: S-type SW (offset=8)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: S-type SW", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        test_num = test_num + 1;
        instr = {7'b0000000, 5'd2, 5'd1, 3'b010, 5'b00000, 7'b0100011};
        expected_imm = 64'h0000000000000000;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: S-type SW (offset=0)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: S-type SW zero", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        test_num = test_num + 1;
        // SW with offset=-1: all bits set
        instr = {7'b1111111, 5'd2, 5'd1, 3'b010, 5'b11111, 7'b0100011};
        expected_imm = 64'hFFFFFFFFFFFFFFFF;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: S-type SW (offset=-1)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: S-type SW negative", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        // ========================================
        // B-TYPE TESTS
        // ========================================
        $display("--- B-TYPE TESTS ---\n");

        test_num = test_num + 1;
        // BEQ with offset=8
        // offset = 0000_0000_1000 → imm[12]=0, imm[11]=0, imm[10:5]=000000, imm[4:1]=0100, imm[0]=0
        // instr[31]=0, instr[7]=0, instr[30:25]=000000, instr[11:8]=0100
        instr = {1'b0, 6'b000000, 5'd2, 5'd1, 3'b000, 4'b0100, 1'b0, 7'b1100011};
        expected_imm = 64'h0000000000000008;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: B-type BEQ (offset=8)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: B-type BEQ offset=8", test_num);
            $display("       Instruction: %h", instr);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        test_num = test_num + 1;
        // BEQ with offset=16
        // offset = 0000_0001_0000 → imm[12]=0, imm[11]=0, imm[10:5]=000000, imm[4:1]=1000, imm[0]=0
        instr = {1'b0, 6'b000000, 5'd2, 5'd1, 3'b000, 4'b1000, 1'b0, 7'b1100011};
        expected_imm = 64'h0000000000000010;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: B-type BEQ (offset=16)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: B-type BEQ offset=16", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        test_num = test_num + 1;
        // BEQ with offset=-4
        // offset = 1111_1111_1100 → imm[12]=1, imm[11]=1, imm[10:5]=111111, imm[4:1]=1110, imm[0]=0
        instr = {1'b1, 6'b111111, 5'd2, 5'd1, 3'b000, 4'b1110, 1'b1, 7'b1100011};
        expected_imm = 64'hFFFFFFFFFFFFFFFC;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: B-type BEQ (offset=-4)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: B-type BEQ offset=-4", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        // ========================================
        // U-TYPE TESTS
        // ========================================
        $display("--- U-TYPE TESTS ---\n");

        test_num = test_num + 1;
        instr = {20'h12345, 5'd2, 7'b0110111};
        expected_imm = 64'h0000000012345000;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: U-type LUI (imm=0x12345000)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: U-type LUI", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        test_num = test_num + 1;
        instr = {20'hFFFFF, 5'd2, 7'b0010111};
        expected_imm = 64'hFFFFFFFFFFFFF000;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: U-type AUIPC (negative)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: U-type AUIPC", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        test_num = test_num + 1;
        instr = {20'h00000, 5'd2, 7'b0110111};
        expected_imm = 64'h0000000000000000;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: U-type LUI (imm=0)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: U-type LUI zero", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        // ========================================
        // J-TYPE TESTS
        // ========================================
        $display("--- J-TYPE TESTS ---\n");

        test_num = test_num + 1;
        // JAL with offset=8
        // offset = 0_0000_0000_1000 → imm[20]=0, imm[10:1]=0000000100, imm[11]=0, imm[19:12]=00000000
        // instr[31]=0, instr[30:21]=0000000100, instr[20]=0, instr[19:12]=00000000
        instr = {1'b0, 10'b0000000100, 1'b0, 8'b00000000, 5'd1, 7'b1101111};
        expected_imm = 64'h0000000000000008;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: J-type JAL (offset=8)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: J-type JAL offset=8", test_num);
            $display("       Instruction: %h", instr);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        test_num = test_num + 1;
        // JAL with offset=-2
        // offset = 1_1111_1111_1110 → imm[20]=1, imm[10:1]=1111111111, imm[11]=1, imm[19:12]=11111111
        instr = {1'b1, 10'b1111111111, 1'b1, 8'b11111111, 5'd1, 7'b1101111};
        expected_imm = 64'hFFFFFFFFFFFFFFFE;
        #1;
        if (imm === expected_imm) begin
            $display("[PASS] Test %0d: J-type JAL (offset=-2)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: J-type JAL offset=-2", test_num);
            $display("       Expected: %h, Got: %h", expected_imm, imm);
            fail_count = fail_count + 1;
        end
        $display("");

        // ========================================
        // FINAL RESULTS
        // ========================================
        $display("========================================");
        $display("Testbench Complete");
        $display("========================================");
        $display("Total Tests: %0d", test_num);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        $display("========================================");
        
        if (fail_count == 0) begin
            $display("*** ALL TESTS PASSED ***");
        end else begin
            $display("*** SOME TESTS FAILED ***");
        end
        $display("========================================\n");

        $finish;
    end

endmodule
