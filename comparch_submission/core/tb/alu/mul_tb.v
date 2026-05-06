`timescale 1ns/1ps

module tb_mul;
    reg [63:0] in1;
    reg [63:0] in2;
    reg [1:0] control;
    wire [63:0] out;

    // Expected values
    reg [63:0] expected_out;
    reg [127:0] temp_result;  // Temporary variable for full multiplication result
    
    // Test counters
    integer test_num;
    integer pass_count;
    integer fail_count;

    // Instantiate DUT
    mul dut (
        .in1(in1),
        .in2(in2),
        .control(control),
        .out(out)
    );

    // Task to check results
    task check_result;
        input [200:0] test_name;
        begin
            test_num = test_num + 1;
            #1; // Small delay for signals to settle
            if (out === expected_out) begin
                $display("[PASS] Test %0d: %s", test_num, test_name);
                $display("       Inputs: in1=%h, in2=%h, control=%b", in1, in2, control);
                $display("       Expected: out=%h", expected_out);
                $display("       Got:      out=%h", out);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %0d: %s", test_num, test_name);
                $display("       Inputs: in1=%h, in2=%h, control=%b", in1, in2, control);
                $display("       Expected: out=%h", expected_out);
                $display("       Got:      out=%h", out);
                fail_count = fail_count + 1;
            end
            $display("");
        end
    endtask

    initial begin
        // Initialize
        test_num = 0;
        pass_count = 0;
        fail_count = 0;
        in1 = 0;
        in2 = 0;
        control = 0;

        $display("========================================");
        $display("Starting mul Module Testbench");
        $display("========================================\n");

        // ========================================
        // MUL TESTS (control = 2'b00) - Lower 64 bits, signed multiplication
        // ========================================
        $display("--- MUL TESTS (Lower 64 bits, Signed x Signed) ---\n");

        // Test 1: Simple positive multiplication
        control = 2'b00;
        in1 = 64'h0000000000000005;
        in2 = 64'h0000000000000003;
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[63:0];
        check_result("MUL: 5 * 3");

        // Test 2: Multiplication by zero
        control = 2'b00;
        in1 = 64'h123456789ABCDEF0;
        in2 = 64'h0000000000000000;
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[63:0];
        check_result("MUL: X * 0");

        // Test 3: Multiplication by one
        control = 2'b00;
        in1 = 64'h123456789ABCDEF0;
        in2 = 64'h0000000000000001;
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[63:0];
        check_result("MUL: X * 1");

        // Test 4: Positive * negative
        control = 2'b00;
        in1 = 64'h0000000000000007;
        in2 = 64'hFFFFFFFFFFFFFFFE; // -2 in signed
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[63:0];
        check_result("MUL: 7 * (-2)");

        // Test 5: Negative * negative
        control = 2'b00;
        in1 = 64'hFFFFFFFFFFFFFFFE; // -2
        in2 = 64'hFFFFFFFFFFFFFFFD; // -3
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[63:0];
        check_result("MUL: (-2) * (-3)");

        // Test 6: Large positive numbers
        control = 2'b00;
        in1 = 64'h0000000012345678;
        in2 = 64'h0000000087654321;
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[63:0];
        check_result("MUL: Large positive * positive");

        // ========================================
        // MULH TESTS (control = 2'b01) - Upper 64 bits, signed multiplication
        // ========================================
        $display("--- MULH TESTS (Upper 64 bits, Signed x Signed) ---\n");

        // Test 7: Simple multiplication - upper bits
        control = 2'b01;
        in1 = 64'h0000000000000005;
        in2 = 64'h0000000000000003;
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[127:64];
        check_result("MULH: 5 * 3 (upper)");

        // Test 8: Large numbers requiring upper bits
        control = 2'b01;
        in1 = 64'h7FFFFFFFFFFFFFFF;
        in2 = 64'h0000000000000002;
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[127:64];
        check_result("MULH: MAX_INT * 2 (upper)");

        // Test 9: Positive * negative (upper bits)
        control = 2'b01;
        in1 = 64'h7FFFFFFFFFFFFFFF;
        in2 = 64'hFFFFFFFFFFFFFFFE; // -2
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[127:64];
        check_result("MULH: MAX_INT * (-2) (upper)");

        // Test 10: Negative * negative (upper bits)
        control = 2'b01;
        in1 = 64'h8000000000000000; // MIN_INT
        in2 = 64'hFFFFFFFFFFFFFFFE; // -2
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[127:64];
        check_result("MULH: MIN_INT * (-2) (upper)");

        // Test 11: Multiplication by zero (upper)
        control = 2'b01;
        in1 = 64'hFFFFFFFFFFFFFFFF;
        in2 = 64'h0000000000000000;
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[127:64];
        check_result("MULH: X * 0 (upper)");

        // ========================================
        // MULHSU TESTS (control = 2'b10) - Upper 64 bits, signed * unsigned
        // ========================================
        $display("--- MULHSU TESTS (Upper 64 bits, Signed x Unsigned) ---\n");

        // Test 12: Positive signed * unsigned
        control = 2'b10;
        in1 = 64'h0000000000000007;
        in2 = 64'h0000000000000003;
        temp_result = $signed(in1) * $unsigned(in2);
        expected_out = temp_result[127:64];
        check_result("MULHSU: 7 * 3u (upper)");

        // Test 13: Negative signed * unsigned
        control = 2'b10;
        in1 = 64'hFFFFFFFFFFFFFFFE; // -2 signed
        in2 = 64'h0000000000000005; // 5 unsigned
        temp_result = $signed(in1) * $unsigned(in2);
        expected_out = temp_result[127:64];
        check_result("MULHSU: (-2) * 5u (upper)");

        // Test 14: Positive signed * large unsigned
        control = 2'b10;
        in1 = 64'h0000000000000002;
        in2 = 64'hFFFFFFFFFFFFFFFF; // Max unsigned
        temp_result = $signed(in1) * $unsigned(in2);
        expected_out = temp_result[127:64];
        check_result("MULHSU: 2 * MAX_UINT (upper)");

        // Test 15: Negative signed * large unsigned
        control = 2'b10;
        in1 = 64'hFFFFFFFFFFFFFFFE; // -2 signed
        in2 = 64'hFFFFFFFFFFFFFFFF; // Max unsigned
        temp_result = $signed(in1) * $unsigned(in2);
        expected_out = temp_result[127:64];
        check_result("MULHSU: (-2) * MAX_UINT (upper)");

        // Test 16: Multiplication by zero
        control = 2'b10;
        in1 = 64'hFFFFFFFFFFFFFFFE; // -2
        in2 = 64'h0000000000000000;
        temp_result = $signed(in1) * $unsigned(in2);
        expected_out = temp_result[127:64];
        check_result("MULHSU: (-2) * 0u (upper)");

        // ========================================
        // MULHU TESTS (control = 2'b11) - Upper 64 bits, unsigned * unsigned
        // ========================================
        $display("--- MULHU TESTS (Upper 64 bits, Unsigned x Unsigned) ---\n");

        // Test 17: Simple unsigned multiplication
        control = 2'b11;
        in1 = 64'h0000000000000005;
        in2 = 64'h0000000000000003;
        temp_result = $unsigned(in1) * $unsigned(in2);
        expected_out = temp_result[127:64];
        check_result("MULHU: 5u * 3u (upper)");

        // Test 18: Large unsigned numbers
        control = 2'b11;
        in1 = 64'hFFFFFFFFFFFFFFFF;
        in2 = 64'h0000000000000002;
        temp_result = $unsigned(in1) * $unsigned(in2);
        expected_out = temp_result[127:64];
        check_result("MULHU: MAX_UINT * 2u (upper)");

        // Test 19: Max unsigned * max unsigned
        control = 2'b11;
        in1 = 64'hFFFFFFFFFFFFFFFF;
        in2 = 64'hFFFFFFFFFFFFFFFF;
        temp_result = $unsigned(in1) * $unsigned(in2);
        expected_out = temp_result[127:64];
        check_result("MULHU: MAX_UINT * MAX_UINT (upper)");

        // Test 20: Multiplication by zero
        control = 2'b11;
        in1 = 64'hFFFFFFFFFFFFFFFF;
        in2 = 64'h0000000000000000;
        temp_result = $unsigned(in1) * $unsigned(in2);
        expected_out = temp_result[127:64];
        check_result("MULHU: MAX_UINT * 0u (upper)");

        // Test 21: Multiplication by one
        control = 2'b11;
        in1 = 64'h123456789ABCDEF0;
        in2 = 64'h0000000000000001;
        temp_result = $unsigned(in1) * $unsigned(in2);
        expected_out = temp_result[127:64];
        check_result("MULHU: X * 1u (upper)");

        // Test 22: Powers of 2
        control = 2'b11;
        in1 = 64'h8000000000000000;
        in2 = 64'h0000000000000002;
        temp_result = $unsigned(in1) * $unsigned(in2);
        expected_out = temp_result[127:64];
        check_result("MULHU: 2^63 * 2 (upper)");

        // ========================================
        // EDGE CASES
        // ========================================
        $display("--- EDGE CASES ---\n");

        // Test 23: MUL with -1 * -1
        control = 2'b00;
        in1 = 64'hFFFFFFFFFFFFFFFF; // -1
        in2 = 64'hFFFFFFFFFFFFFFFF; // -1
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[63:0];
        check_result("MUL: (-1) * (-1)");

        // Test 24: MULH with MIN_INT * MIN_INT
        control = 2'b01;
        in1 = 64'h8000000000000000;
        in2 = 64'h8000000000000000;
        temp_result = $signed(in1) * $signed(in2);
        expected_out = temp_result[127:64];
        check_result("MULH: MIN_INT * MIN_INT (upper)");

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
