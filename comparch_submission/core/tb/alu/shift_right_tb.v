`timescale 1ns/1ps

module tb_shift;
    reg signed [63:0] in;
    reg [5:0] amt;
    reg control;
    wire [63:0] out;

    // Expected value
    reg [63:0] expected_out;
    
    // Test counters
    integer test_num;
    integer pass_count;
    integer fail_count;

    // Instantiate DUT
    shift dut (
        .in(in),
        .amt(amt),
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
                $display("       Input: in=%h, amt=%d, control=%b", in, amt, control);
                $display("       Expected: out=%h", expected_out);
                $display("       Got:      out=%h", out);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %0d: %s", test_num, test_name);
                $display("       Input: in=%h, amt=%d, control=%b", in, amt, control);
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
        control = 0;

        $display("========================================");
        $display("Starting shift Module Testbench");
        $display("========================================\n");

        // ========================================
        // LOGICAL SHIFT RIGHT TESTS (control = 0)
        // ========================================
        $display("--- LOGICAL SHIFT RIGHT TESTS ---\n");

        // Test 1: Logical shift by 0
        control = 1'b0;
        in = 64'h123456789ABCDEF0;
        amt = 6'd0;
        expected_out = in >> amt;
        check_result("Logical shift by 0 (no change)");

        // Test 2: Logical shift by 1
        control = 1'b0;
        in = 64'h0000000000000002;
        amt = 6'd1;
        expected_out = in >> amt;
        check_result("Logical shift 2 by 1");

        // Test 3: Logical shift by 4
        control = 1'b0;
        in = 64'h00000000000000F0;
        amt = 6'd4;
        expected_out = in >> amt;
        check_result("Logical shift 0xF0 by 4");

        // Test 4: Logical shift by 8
        control = 1'b0;
        in = 64'h000000000000FF00;
        amt = 6'd8;
        expected_out = in >> amt;
        check_result("Logical shift 0xFF00 by 8");

        // Test 5: Logical shift by 16
        control = 1'b0;
        in = 64'h0000000012340000;
        amt = 6'd16;
        expected_out = in >> amt;
        check_result("Logical shift by 16");

        // Test 6: Logical shift by 32
        control = 1'b0;
        in = 64'h1234567800000000;
        amt = 6'd32;
        expected_out = in >> amt;
        check_result("Logical shift by 32");

        // Test 7: Logical shift by 63
        control = 1'b0;
        in = 64'h8000000000000000;
        amt = 6'd63;
        expected_out = in >> amt;
        check_result("Logical shift by 63 (MSB to LSB)");

        // Test 8: Logical shift of all 1s
        control = 1'b0;
        in = 64'hFFFFFFFFFFFFFFFF;
        amt = 6'd4;
        expected_out = in >> amt;
        check_result("Logical shift all 1s by 4");

        // Test 9: Logical shift of negative number
        control = 1'b0;
        in = 64'hFFFFFFFFFFFFFFFE; // -2 in signed
        amt = 6'd1;
        expected_out = in >> amt;
        check_result("Logical shift negative number");

        // Test 10: Logical shift to clear all bits
        control = 1'b0;
        in = 64'h0000000000000001;
        amt = 6'd1;
        expected_out = in >> amt;
        check_result("Logical shift 1 to 0");

        // ========================================
        // ARITHMETIC SHIFT RIGHT TESTS (control = 1)
        // ========================================
        $display("--- ARITHMETIC SHIFT RIGHT TESTS ---\n");

        // Test 11: Arithmetic shift positive number by 0
        control = 1'b1;
        in = 64'h123456789ABCDEF0;
        amt = 6'd0;
        expected_out = in >>> amt;
        check_result("Arithmetic shift by 0 (no change)");

        // Test 12: Arithmetic shift positive by 1
        control = 1'b1;
        in = 64'h0000000000000008;
        amt = 6'd1;
        expected_out = in >>> amt;
        check_result("Arithmetic shift positive 8 by 1");

        // Test 13: Arithmetic shift positive by 4
        control = 1'b1;
        in = 64'h00000000000000F0;
        amt = 6'd4;
        expected_out = in >>> amt;
        check_result("Arithmetic shift positive by 4");

        // Test 14: Arithmetic shift negative by 1 (sign extend)
        control = 1'b1;
        in = 64'hFFFFFFFFFFFFFFFE; // -2
        amt = 6'd1;
        expected_out = in >>> amt;
        check_result("Arithmetic shift -2 by 1 (sign extend)");

        // Test 15: Arithmetic shift negative by 4
        control = 1'b1;
        in = 64'hFFFFFFFFFFFFFF00; // negative
        amt = 6'd4;
        expected_out = in >>> amt;
        check_result("Arithmetic shift negative by 4");

        // Test 16: Arithmetic shift -1 by various amounts
        control = 1'b1;
        in = 64'hFFFFFFFFFFFFFFFF; // -1
        amt = 6'd8;
        expected_out = in >>> amt;
        check_result("Arithmetic shift -1 by 8");

        // Test 17: Arithmetic shift MIN_INT by 1
        control = 1'b1;
        in = 64'h8000000000000000; // MIN_INT
        amt = 6'd1;
        expected_out = in >>> amt;
        check_result("Arithmetic shift MIN_INT by 1");

        // Test 18: Arithmetic shift MIN_INT by 63
        control = 1'b1;
        in = 64'h8000000000000000; // MIN_INT
        amt = 6'd63;
        expected_out = in >>> amt;
        check_result("Arithmetic shift MIN_INT by 63");

        // Test 19: Arithmetic shift negative by 32
        control = 1'b1;
        in = 64'hFFFFFFFF00000000;
        amt = 6'd32;
        expected_out = in >>> amt;
        check_result("Arithmetic shift negative by 32");

        // Test 20: Arithmetic shift MAX_INT by 4
        control = 1'b1;
        in = 64'h7FFFFFFFFFFFFFFF; // MAX_INT
        amt = 6'd4;
        expected_out = in >>> amt;
        check_result("Arithmetic shift MAX_INT by 4");

        // ========================================
        // COMPARISON: LOGICAL vs ARITHMETIC
        // ========================================
        $display("--- LOGICAL vs ARITHMETIC COMPARISON ---\n");

        // Test 21: Compare logical vs arithmetic on positive
        control = 1'b0;
        in = 64'h0000000000001234;
        amt = 6'd4;
        expected_out = in >> amt;
        check_result("Logical shift positive (compare)");

        control = 1'b1;
        in = 64'h0000000000001234;
        amt = 6'd4;
        expected_out = in >>> amt;
        check_result("Arithmetic shift positive (compare)");

        // Test 22-23: Compare logical vs arithmetic on negative
        control = 1'b0;
        in = 64'h8000000000000000;
        amt = 6'd4;
        expected_out = in >> amt;
        check_result("Logical shift MIN_INT (zero-fill)");

        control = 1'b1;
        in = 64'h8000000000000000;
        amt = 6'd4;
        expected_out = in >>> amt;
        check_result("Arithmetic shift MIN_INT (sign-extend)");

        // Test 24-25: Compare on -1
        control = 1'b0;
        in = 64'hFFFFFFFFFFFFFFFF;
        amt = 6'd1;
        expected_out = in >> amt;
        check_result("Logical shift -1 (becomes positive)");

        control = 1'b1;
        in = 64'hFFFFFFFFFFFFFFFF;
        amt = 6'd1;
        expected_out = in >>> amt;
        check_result("Arithmetic shift -1 (stays -1)");

        // ========================================
        // EDGE CASES - LOGICAL
        // ========================================
        $display("--- EDGE CASES - LOGICAL ---\n");

        // Test 26: Logical shift zero
        control = 1'b0;
        in = 64'h0000000000000000;
        amt = 6'd10;
        expected_out = in >> amt;
        check_result("Logical shift zero");

        // Test 27: Logical shift alternating pattern
        control = 1'b0;
        in = 64'hAAAAAAAAAAAAAAAA;
        amt = 6'd1;
        expected_out = in >> amt;
        check_result("Logical shift 0xAAAA... by 1");

        // Test 28: Logical shift alternating pattern
        control = 1'b0;
        in = 64'h5555555555555555;
        amt = 6'd1;
        expected_out = in >> amt;
        check_result("Logical shift 0x5555... by 1");

        // Test 29: Logical shift by 48
        control = 1'b0;
        in = 64'hABCD000000000000;
        amt = 6'd48;
        expected_out = in >> amt;
        check_result("Logical shift by 48");

        // ========================================
        // EDGE CASES - ARITHMETIC
        // ========================================
        $display("--- EDGE CASES - ARITHMETIC ---\n");

        // Test 30: Arithmetic shift zero
        control = 1'b1;
        in = 64'h0000000000000000;
        amt = 6'd10;
        expected_out = in >>> amt;
        check_result("Arithmetic shift zero");

        // Test 31: Arithmetic shift by 16
        control = 1'b1;
        in = 64'hFFFF000000000000;
        amt = 6'd16;
        expected_out = in >>> amt;
        check_result("Arithmetic shift negative by 16");

        // Test 32: Arithmetic shift single negative bit
        control = 1'b1;
        in = 64'h8000000000000000;
        amt = 6'd32;
        expected_out = in >>> amt;
        check_result("Arithmetic shift MIN_INT by 32");

        // Test 33: Arithmetic shift with mixed bits
        control = 1'b1;
        in = 64'hF0F0F0F0F0F0F0F0;
        amt = 6'd8;
        expected_out = in >>> amt;
        check_result("Arithmetic shift mixed pattern");

        // ========================================
        // VARIOUS SHIFT AMOUNTS
        // ========================================
        $display("--- VARIOUS SHIFT AMOUNTS ---\n");

        // Test 34: Logical shift by 3
        control = 1'b0;
        in = 64'h0000000000001000;
        amt = 6'd3;
        expected_out = in >> amt;
        check_result("Logical shift by 3");

        // Test 35: Arithmetic shift by 7
        control = 1'b1;
        in = 64'hFFFFFFFFFFFF8000;
        amt = 6'd7;
        expected_out = in >>> amt;
        check_result("Arithmetic shift by 7");

        // Test 36: Logical shift by 20
        control = 1'b0;
        in = 64'h1234567800000000;
        amt = 6'd20;
        expected_out = in >> amt;
        check_result("Logical shift by 20");

        // Test 37: Arithmetic shift by 31
        control = 1'b1;
        in = 64'h8000000000000000;
        amt = 6'd31;
        expected_out = in >>> amt;
        check_result("Arithmetic shift by 31");

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
