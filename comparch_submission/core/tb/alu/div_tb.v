`timescale 1ns/1ps

module tb_div;
    reg [63:0] in1;
    reg [63:0] in2;
    reg [1:0] control;
    wire [63:0] out;

    // Expected value
    reg [63:0] expected_out;
    
    // Test counters
    integer test_num;
    integer pass_count;
    integer fail_count;

    // Instantiate DUT
    div dut (
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
        $display("Starting div Module Testbench");
        $display("========================================\n");

        // ========================================
        // DIV TESTS (control = 2'b00) - Signed division quotient
        // ========================================
        $display("--- DIV TESTS (Signed Division - Quotient) ---\n");

        // Test 1: Simple positive division
        control = 2'b00;
        in1 = 64'h000000000000000A; // 10
        in2 = 64'h0000000000000002; // 2
        expected_out = $signed(in1) / $signed(in2);
        check_result("DIV: 10 / 2 = 5");

        // Test 2: Division with remainder
        control = 2'b00;
        in1 = 64'h000000000000000B; // 11
        in2 = 64'h0000000000000003; // 3
        expected_out = $signed(in1) / $signed(in2);
        check_result("DIV: 11 / 3 = 3");

        // Test 3: Division by 1
        control = 2'b00;
        in1 = 64'h123456789ABCDEF0;
        in2 = 64'h0000000000000001;
        expected_out = $signed(in1) / $signed(in2);
        check_result("DIV: X / 1 = X");

        // Test 4: Zero divided by non-zero
        control = 2'b00;
        in1 = 64'h0000000000000000;
        in2 = 64'h0000000000000005;
        expected_out = $signed(in1) / $signed(in2);
        check_result("DIV: 0 / 5 = 0");

        // Test 5: Positive / negative
        control = 2'b00;
        in1 = 64'h000000000000000A; // 10
        in2 = 64'hFFFFFFFFFFFFFFFE; // -2
        expected_out = $signed(in1) / $signed(in2);
        check_result("DIV: 10 / (-2) = -5");

        // Test 6: Negative / positive
        control = 2'b00;
        in1 = 64'hFFFFFFFFFFFFFFF6; // -10
        in2 = 64'h0000000000000002; // 2
        expected_out = $signed(in1) / $signed(in2);
        check_result("DIV: (-10) / 2 = -5");

        // Test 7: Negative / negative
        control = 2'b00;
        in1 = 64'hFFFFFFFFFFFFFFF6; // -10
        in2 = 64'hFFFFFFFFFFFFFFFE; // -2
        expected_out = $signed(in1) / $signed(in2);
        check_result("DIV: (-10) / (-2) = 5");

        // Test 8: -1 / 1
        control = 2'b00;
        in1 = 64'hFFFFFFFFFFFFFFFF; // -1
        in2 = 64'h0000000000000001; // 1
        expected_out = $signed(in1) / $signed(in2);
        check_result("DIV: (-1) / 1 = -1");

        // Test 9: Large positive division
        control = 2'b00;
        in1 = 64'h0000000000000064; // 100
        in2 = 64'h000000000000000A; // 10
        expected_out = $signed(in1) / $signed(in2);
        check_result("DIV: 100 / 10 = 10");

        // Extra Test: Division by zero
        control = 2'b00;
        in1 = 64'h0000000000000064; // 100
        in2 = 64'h0000000000000000; // 0
        expected_out = 64'hFFFFFFFFFFFFFFFF;
        check_result("DIV: 100/0 = FFFFFFFFFFFFFFFF");
        
        // Extra Test: Division overflow
        control = 2'b00;
        in1 = 64'h8000000000000000; // Most negative number
        in2 = 64'hFFFFFFFFFFFFFFFF; // -1
        expected_out = 64'h8000000000000000;
        check_result("DIV: Overflow case = 8000000000000000");

        // ========================================
        // DIVU TESTS (control = 2'b01) - Unsigned division quotient
        // ========================================
        $display("--- DIVU TESTS (Unsigned Division - Quotient) ---\n");

        // Test 10: Simple unsigned division
        control = 2'b01;
        in1 = 64'h000000000000000A; // 10
        in2 = 64'h0000000000000002; // 2
        expected_out = $unsigned(in1) / $unsigned(in2);
        check_result("DIVU: 10 / 2 = 5");

        // Test 11: Unsigned division with remainder
        control = 2'b01;
        in1 = 64'h000000000000000B; // 11
        in2 = 64'h0000000000000003; // 3
        expected_out = $unsigned(in1) / $unsigned(in2);
        check_result("DIVU: 11 / 3 = 3");

        // Test 12: Large unsigned / small unsigned
        control = 2'b01;
        in1 = 64'hFFFFFFFFFFFFFFFF; // Max unsigned
        in2 = 64'h0000000000000002;
        expected_out = $unsigned(in1) / $unsigned(in2);
        check_result("DIVU: MAX_UINT / 2");

        // Test 13: Zero / non-zero (unsigned)
        control = 2'b01;
        in1 = 64'h0000000000000000;
        in2 = 64'h0000000000000005;
        expected_out = $unsigned(in1) / $unsigned(in2);
        check_result("DIVU: 0 / 5 = 0");

        // Test 14: Division by 1 (unsigned)
        control = 2'b01;
        in1 = 64'h123456789ABCDEF0;
        in2 = 64'h0000000000000001;
        expected_out = $unsigned(in1) / $unsigned(in2);
        check_result("DIVU: X / 1 = X");

        // Test 15: Large unsigned values
        control = 2'b01;
        in1 = 64'h0000000000000064; // 100
        in2 = 64'h000000000000000A; // 10
        expected_out = $unsigned(in1) / $unsigned(in2);
        check_result("DIVU: 100 / 10 = 10");

        // Test 16: Power of 2 division
        control = 2'b01;
        in1 = 64'h0000000000000100; // 256
        in2 = 64'h0000000000000010; // 16
        expected_out = $unsigned(in1) / $unsigned(in2);
        check_result("DIVU: 256 / 16 = 16");

        // ========================================
        // REM TESTS (control = 2'b10) - Signed remainder
        // ========================================
        $display("--- REM TESTS (Signed Division - Remainder) ---\n");

        // Test 17: Simple remainder
        control = 2'b10;
        in1 = 64'h000000000000000B; // 11
        in2 = 64'h0000000000000003; // 3
        expected_out = $signed(in1) % $signed(in2);
        check_result("REM: 11 % 3 = 2");

        // Test 18: No remainder
        control = 2'b10;
        in1 = 64'h000000000000000A; // 10
        in2 = 64'h0000000000000002; // 2
        expected_out = $signed(in1) % $signed(in2);
        check_result("REM: 10 % 2 = 0");

        // Test 19: Remainder with larger divisor
        control = 2'b10;
        in1 = 64'h0000000000000005; // 5
        in2 = 64'h000000000000000A; // 10
        expected_out = $signed(in1) % $signed(in2);
        check_result("REM: 5 % 10 = 5");

        // Test 20: Zero remainder
        control = 2'b10;
        in1 = 64'h0000000000000000;
        in2 = 64'h0000000000000005;
        expected_out = $signed(in1) % $signed(in2);
        check_result("REM: 0 % 5 = 0");

        // Test 21: Positive % negative
        control = 2'b10;
        in1 = 64'h000000000000000B; // 11
        in2 = 64'hFFFFFFFFFFFFFFFD; // -3
        expected_out = $signed(in1) % $signed(in2);
        check_result("REM: 11 % (-3)");

        // Test 22: Negative % positive
        control = 2'b10;
        in1 = 64'hFFFFFFFFFFFFFFF5; // -11
        in2 = 64'h0000000000000003; // 3
        expected_out = $signed(in1) % $signed(in2);
        check_result("REM: (-11) % 3");

        // Test 23: Negative % negative
        control = 2'b10;
        in1 = 64'hFFFFFFFFFFFFFFF5; // -11
        in2 = 64'hFFFFFFFFFFFFFFFD; // -3
        expected_out = $signed(in1) % $signed(in2);
        check_result("REM: (-11) % (-3)");

        // Test 24: Remainder by 1
        control = 2'b10;
        in1 = 64'h123456789ABCDEF0;
        in2 = 64'h0000000000000001;
        expected_out = $signed(in1) % $signed(in2);
        check_result("REM: X % 1 = 0");

        // Test 25: -1 % any
        control = 2'b10;
        in1 = 64'hFFFFFFFFFFFFFFFF; // -1
        in2 = 64'h0000000000000005; // 5
        expected_out = $signed(in1) % $signed(in2);
        check_result("REM: (-1) % 5");

        // Extra Test: Remainder by zero
        control = 2'b10;
        in1 = 64'h0000000000000064; // 100
        in2 = 64'h0000000000000000; // 0
        expected_out = in1;
        check_result("REM: Remainder by zero = in1");
        
        // Extra Test: Remainder overflow
        control = 2'b10;
        in1 = 64'h8000000000000000; // Most negative number
        in2 = 64'hFFFFFFFFFFFFFFFF; // -1
        expected_out = 64'h0000000000000000;
        check_result("REM: Overflow case = 0");

        // ========================================
        // REMU TESTS (control = 2'b11) - Unsigned remainder
        // ========================================
        $display("--- REMU TESTS (Unsigned Division - Remainder) ---\n");

        // Test 26: Simple unsigned remainder
        control = 2'b11;
        in1 = 64'h000000000000000B; // 11
        in2 = 64'h0000000000000003; // 3
        expected_out = $unsigned(in1) % $unsigned(in2);
        check_result("REMU: 11 % 3 = 2");

        // Test 27: No remainder (unsigned)
        control = 2'b11;
        in1 = 64'h000000000000000A; // 10
        in2 = 64'h0000000000000002; // 2
        expected_out = $unsigned(in1) % $unsigned(in2);
        check_result("REMU: 10 % 2 = 0");

        // Test 28: Remainder with larger divisor (unsigned)
        control = 2'b11;
        in1 = 64'h0000000000000005; // 5
        in2 = 64'h000000000000000A; // 10
        expected_out = $unsigned(in1) % $unsigned(in2);
        check_result("REMU: 5 % 10 = 5");

        // Test 29: Zero remainder (unsigned)
        control = 2'b11;
        in1 = 64'h0000000000000000;
        in2 = 64'h0000000000000005;
        expected_out = $unsigned(in1) % $unsigned(in2);
        check_result("REMU: 0 % 5 = 0");

        // Test 30: Large unsigned remainder
        control = 2'b11;
        in1 = 64'hFFFFFFFFFFFFFFFF;
        in2 = 64'h0000000000000010; // 16
        expected_out = $unsigned(in1) % $unsigned(in2);
        check_result("REMU: MAX_UINT % 16");

        // Test 31: Remainder by 1 (unsigned)
        control = 2'b11;
        in1 = 64'h123456789ABCDEF0;
        in2 = 64'h0000000000000001;
        expected_out = $unsigned(in1) % $unsigned(in2);
        check_result("REMU: X % 1 = 0");

        // Test 32: Power of 2 remainder
        control = 2'b11;
        in1 = 64'h0000000000000123; // 291
        in2 = 64'h0000000000000010; // 16
        expected_out = $unsigned(in1) % $unsigned(in2);
        check_result("REMU: 291 % 16");

        // ========================================
        // EDGE CASES
        // ========================================
        $display("--- EDGE CASES ---\n");

        // Test 33: Self division (signed)
        control = 2'b00;
        in1 = 64'h0000000000000007;
        in2 = 64'h0000000000000007;
        expected_out = $signed(in1) / $signed(in2);
        check_result("DIV: X / X = 1");

        // Test 34: Self division (unsigned)
        control = 2'b01;
        in1 = 64'h123456789ABCDEF0;
        in2 = 64'h123456789ABCDEF0;
        expected_out = $unsigned(in1) / $unsigned(in2);
        check_result("DIVU: X / X = 1");

        // Test 35: Self remainder (signed)
        control = 2'b10;
        in1 = 64'h0000000000000007;
        in2 = 64'h0000000000000007;
        expected_out = $signed(in1) % $signed(in2);
        check_result("REM: X % X = 0");

        // Test 36: Self remainder (unsigned)
        control = 2'b11;
        in1 = 64'h123456789ABCDEF0;
        in2 = 64'h123456789ABCDEF0;
        expected_out = $unsigned(in1) % $unsigned(in2);
        check_result("REMU: X % X = 0");

        // Test 37: MAX_INT signed division
        control = 2'b00;
        in1 = 64'h7FFFFFFFFFFFFFFF;
        in2 = 64'h0000000000000002;
        expected_out = $signed(in1) / $signed(in2);
        check_result("DIV: MAX_INT / 2");

        // Test 38: MIN_INT signed division
        control = 2'b00;
        in1 = 64'h8000000000000000;
        in2 = 64'hFFFFFFFFFFFFFFFE; // -2
        expected_out = $signed(in1) / $signed(in2);
        check_result("DIV: MIN_INT / (-2)");

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
