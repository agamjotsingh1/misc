`timescale 1ns/1ps

module tb_shift_left;
    reg signed [63:0] in;
    reg [5:0] amt;
    wire [63:0] out;

    // Expected value
    reg [63:0] expected_out;
    
    // Test counters
    integer test_num;
    integer pass_count;
    integer fail_count;

    // Instantiate DUT
    shift_left dut (
        .in(in),
        .amt(amt),
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
                $display("       Input: in=%h, amt=%d", in, amt);
                $display("       Expected: out=%h", expected_out);
                $display("       Got:      out=%h", out);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %0d: %s", test_num, test_name);
                $display("       Input: in=%h, amt=%d", in, amt);
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
        in = 0;
        amt = 0;

        $display("========================================");
        $display("Starting shift_left Module Testbench");
        $display("========================================\n");

        // ========================================
        // BASIC SHIFT TESTS
        // ========================================
        $display("--- BASIC SHIFT TESTS ---\n");

        // Test 1: Shift by 0 (no shift)
        in = 64'h123456789ABCDEF0;
        amt = 6'd0;
        expected_out = in << amt;
        check_result("Shift by 0 (no change)");

        // Test 2: Shift by 1
        in = 64'h0000000000000001;
        amt = 6'd1;
        expected_out = in << amt;
        check_result("Shift 1 by 1 position");

        // Test 3: Shift by 2
        in = 64'h0000000000000001;
        amt = 6'd2;
        expected_out = in << amt;
        check_result("Shift 1 by 2 positions");

        // Test 4: Shift by 4
        in = 64'h000000000000000F;
        amt = 6'd4;
        expected_out = in << amt;
        check_result("Shift 0xF by 4 positions");

        // Test 5: Shift by 8
        in = 64'h00000000000000FF;
        amt = 6'd8;
        expected_out = in << amt;
        check_result("Shift 0xFF by 8 positions");

        // ========================================
        // POWER OF 2 SHIFTS
        // ========================================
        $display("--- POWER OF 2 SHIFT TESTS ---\n");

        // Test 6: Shift by 16
        in = 64'h0000000000001234;
        amt = 6'd16;
        expected_out = in << amt;
        check_result("Shift by 16 positions");

        // Test 7: Shift by 32
        in = 64'h0000000012345678;
        amt = 6'd32;
        expected_out = in << amt;
        check_result("Shift by 32 positions");

        // Test 8: Shift by 48
        in = 64'h000000000000ABCD;
        amt = 6'd48;
        expected_out = in << amt;
        check_result("Shift by 48 positions");

        // ========================================
        // MAXIMUM SHIFT TESTS
        // ========================================
        $display("--- MAXIMUM SHIFT TESTS ---\n");

        // Test 9: Shift by 63 (maximum valid shift)
        in = 64'h0000000000000001;
        amt = 6'd63;
        expected_out = in << amt;
        check_result("Shift by 63 positions");

        // Test 10: Shift by 63 with different value
        in = 64'h0000000000000003;
        amt = 6'd63;
        expected_out = in << amt;
        check_result("Shift 0x3 by 63 positions");

        // ========================================
        // OVERFLOW/WRAPAROUND TESTS
        // ========================================
        $display("--- OVERFLOW TESTS ---\n");

        // Test 11: Shift that causes overflow
        in = 64'hFFFFFFFFFFFFFFFF;
        amt = 6'd1;
        expected_out = in << amt;
        check_result("Shift all 1s by 1 (overflow)");

        // Test 12: Shift that loses upper bits
        in = 64'hF000000000000000;
        amt = 6'd4;
        expected_out = in << amt;
        check_result("Shift with upper bits set");

        // Test 13: Large shift causing complete overflow
        in = 64'h00000000FFFFFFFF;
        amt = 6'd32;
        expected_out = in << amt;
        check_result("Shift lower 32 bits to upper");

        // Test 14: Shift that clears all bits
        in = 64'h0000000000000001;
        amt = 6'd63;
        expected_out = in << amt;
        check_result("Shift to MSB position");

        // ========================================
        // SIGNED NUMBER TESTS
        // ========================================
        $display("--- SIGNED NUMBER TESTS ---\n");

        // Test 15: Positive signed number
        in = 64'h0000000000000007;
        amt = 6'd4;
        expected_out = in << amt;
        check_result("Shift positive signed number");

        // Test 16: Negative signed number (MSB set)
        in = 64'hFFFFFFFFFFFFFFFE; // -2 in signed
        amt = 6'd1;
        expected_out = in << amt;
        check_result("Shift negative signed number");

        // Test 17: Negative number shifted multiple positions
        in = 64'hFFFFFFFFFFFFFFFF; // -1 in signed
        amt = 6'd8;
        expected_out = in << amt;
        check_result("Shift -1 by 8 positions");

        // Test 18: MIN_INT shifted
        in = 64'h8000000000000000;
        amt = 6'd1;
        expected_out = in << amt;
        check_result("Shift MIN_INT by 1");

        // ========================================
        // PATTERN TESTS
        // ========================================
        $display("--- PATTERN TESTS ---\n");

        // Test 19: Alternating bit pattern
        in = 64'h5555555555555555;
        amt = 6'd1;
        expected_out = in << amt;
        check_result("Shift alternating pattern 0x5555...");

        // Test 20: Alternating bit pattern (other)
        in = 64'hAAAAAAAAAAAAAAAA;
        amt = 6'd1;
        expected_out = in << amt;
        check_result("Shift alternating pattern 0xAAAA...");

        // Test 21: Checkerboard pattern shifted by 4
        in = 64'h0F0F0F0F0F0F0F0F;
        amt = 6'd4;
        expected_out = in << amt;
        check_result("Shift checkerboard by 4");

        // ========================================
        // ZERO TESTS
        // ========================================
        $display("--- ZERO TESTS ---\n");

        // Test 22: Shift zero
        in = 64'h0000000000000000;
        amt = 6'd10;
        expected_out = in << amt;
        check_result("Shift zero");

        // Test 23: Zero shift amount with large value
        in = 64'hFFFFFFFFFFFFFFFF;
        amt = 6'd0;
        expected_out = in << amt;
        check_result("Zero shift of all 1s");

        // ========================================
        // VARIOUS SHIFT AMOUNTS
        // ========================================
        $display("--- VARIOUS SHIFT AMOUNTS ---\n");

        // Test 24: Shift by 3
        in = 64'h0000000000000123;
        amt = 6'd3;
        expected_out = in << amt;
        check_result("Shift by 3 positions");

        // Test 25: Shift by 5
        in = 64'h0000000000000123;
        amt = 6'd5;
        expected_out = in << amt;
        check_result("Shift by 5 positions");

        // Test 26: Shift by 7
        in = 64'h0000000000000123;
        amt = 6'd7;
        expected_out = in << amt;
        check_result("Shift by 7 positions");

        // Test 27: Shift by 12
        in = 64'h0000000000000ABC;
        amt = 6'd12;
        expected_out = in << amt;
        check_result("Shift by 12 positions");

        // Test 28: Shift by 20
        in = 64'h0000000000000FFF;
        amt = 6'd20;
        expected_out = in << amt;
        check_result("Shift by 20 positions");

        // Test 29: Shift by 31
        in = 64'h0000000000000001;
        amt = 6'd31;
        expected_out = in << amt;
        check_result("Shift by 31 positions");

        // Test 30: Shift by 40
        in = 64'h00000000000000FF;
        amt = 6'd40;
        expected_out = in << amt;
        check_result("Shift by 40 positions");

        // ========================================
        // EDGE CASES
        // ========================================
        $display("--- EDGE CASES ---\n");

        // Test 31: Maximum input, maximum shift
        in = 64'hFFFFFFFFFFFFFFFF;
        amt = 6'd63;
        expected_out = in << amt;
        check_result("Max value shift by 63");

        // Test 32: Single bit in middle positions
        in = 64'h0000000100000000;
        amt = 6'd10;
        expected_out = in << amt;
        check_result("Single bit in middle shifted");

        // Test 33: All upper bits set, shifted
        in = 64'hFFFFFFFF00000000;
        amt = 6'd8;
        expected_out = in << amt;
        check_result("Upper half set, shifted by 8");

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
