`timescale 1ns/1ps

module tb_addsub;
    reg [63:0] in1;
    reg [63:0] in2;
    reg [1:0] control;
    wire cout;
    wire [63:0] out;

    // Expected values
    reg [63:0] expected_out;
    reg expected_cout;
    reg [64:0] temp_result;  // Temporary variable for carry calculation
    
    // Test counters
    integer test_num;
    integer pass_count;
    integer fail_count;

    // Instantiate DUT
    addsub dut (
        .in1(in1),
        .in2(in2),
        .control(control),
        .cout(cout),
        .out(out)
    );

    // Task to check results
    task check_result;
        input [200:0] test_name;
        begin
            test_num = test_num + 1;
            #1;
            if (out === expected_out && cout === expected_cout) begin
                $display("[PASS] Test %0d: %s", test_num, test_name);
                $display("       Inputs: in1=%h, in2=%h, control=%b", in1, in2, control);
                $display("       Expected: out=%h, cout=%b", expected_out, expected_cout);
                $display("       Got:      out=%h, cout=%b", out, cout);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %0d: %s", test_num, test_name);
                $display("       Inputs: in1=%h, in2=%h, control=%b", in1, in2, control);
                $display("       Expected: out=%h, cout=%b", expected_out, expected_cout);
                $display("       Got:      out=%h, cout=%b", out, cout);
                fail_count = fail_count + 1;
            end
            $display("");
        end
    endtask

    initial begin
        test_num = 0;
        pass_count = 0;
        fail_count = 0;
        in1 = 0;
        in2 = 0;
        control = 0;

        $display("========================================");
        $display("Starting addsub Module Testbench");
        $display("========================================\n");

        // ========================================
        // ADDITION TESTS
        // ========================================
        $display("--- ADDITION TESTS ---\n");

        control = 2'b00;
        in1 = 64'h0000000000000005;
        in2 = 64'h0000000000000003;
        temp_result = {1'b0, in1} + {1'b0, in2};
        expected_out = temp_result[63:0];
        expected_cout = temp_result[64];
        check_result("Simple addition: 5 + 3");

        control = 2'b00;
        in1 = 64'hFFFFFFFFFFFFFFFF;
        in2 = 64'h0000000000000001;
        temp_result = {1'b0, in1} + {1'b0, in2};
        expected_out = temp_result[63:0];
        expected_cout = temp_result[64];
        check_result("Addition with carry: MAX + 1");

        control = 2'b00;
        in1 = 64'h0000000000000000;
        in2 = 64'h0000000000000000;
        expected_out = in1 + in2;
        expected_cout = 1'b0;
        check_result("Zero addition: 0 + 0");

        control = 2'b00;
        in1 = 64'h123456789ABCDEF0;
        in2 = 64'h0FEDCBA987654321;
        temp_result = {1'b0, in1} + {1'b0, in2};
        expected_out = temp_result[63:0];
        expected_cout = temp_result[64];
        check_result("Large number addition");

        control = 2'b00;
        in1 = 64'hFFFFFFFFFFFFFFFF;
        in2 = 64'hFFFFFFFFFFFFFFFF;
        temp_result = {1'b0, in1} + {1'b0, in2};
        expected_out = temp_result[63:0];
        expected_cout = temp_result[64];
        check_result("Addition overflow: MAX + MAX");

        // ========================================
        // SUBTRACTION TESTS
        // ========================================
        $display("--- SUBTRACTION TESTS ---\n");

        control = 2'b01;
        in1 = 64'h0000000000000008;
        in2 = 64'h0000000000000003;
        temp_result = {1'b0, in1} - {1'b0, in2};
        expected_out = temp_result[63:0];
        expected_cout = temp_result[64];
        check_result("Simple subtraction: 8 - 3");

        control = 2'b01;
        in1 = 64'h123456789ABCDEF0;
        in2 = 64'h123456789ABCDEF0;
        expected_out = in1 - in2;
        expected_cout = 1'b0;
        check_result("Equal subtraction: X - X");

        control = 2'b01;
        in1 = 64'h0000000000000000;
        in2 = 64'h0000000000000001;
        temp_result = {1'b0, in1} - {1'b0, in2};
        expected_out = temp_result[63:0];
        expected_cout = temp_result[64];
        check_result("Subtraction with borrow: 0 - 1");

        control = 2'b01;
        in1 = 64'hFFFFFFFFFFFFFFFF;
        in2 = 64'h0000000000000001;
        expected_out = in1 - in2;
        expected_cout = 1'b0;
        check_result("Large subtraction: MAX - 1");

        control = 2'b01;
        in1 = 64'h0000000000000005;
        in2 = 64'h000000000000000A;
        temp_result = {1'b0, in1} - {1'b0, in2};
        expected_out = temp_result[63:0];
        expected_cout = temp_result[64];
        check_result("Negative result: 5 - 10");

        // ========================================
        // SIGNED COMPARISON TESTS (SLT)
        // ========================================
        $display("--- SIGNED COMPARISON TESTS (SLT) ---\n");

        control = 2'b10;
        in1 = 64'h0000000000000003;
        in2 = 64'h0000000000000005;
        expected_out = ($signed(in1) < $signed(in2)) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLT: 3 < 5 (true)");

        control = 2'b10;
        in1 = 64'h0000000000000005;
        in2 = 64'h0000000000000003;
        expected_out = ($signed(in1) < $signed(in2)) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLT: 5 < 3 (false)");

        control = 2'b10;
        in1 = 64'h0000000000000007;
        in2 = 64'h0000000000000007;
        expected_out = ($signed(in1) < $signed(in2)) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLT: 7 < 7 (false)");

        control = 2'b10;
        in1 = 64'hFFFFFFFFFFFFFFFE;
        in2 = 64'h0000000000000005;
        expected_out = ($signed(in1) < $signed(in2)) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLT: -2 < 5 (true)");

        control = 2'b10;
        in1 = 64'h0000000000000005;
        in2 = 64'hFFFFFFFFFFFFFFFE;
        expected_out = ($signed(in1) < $signed(in2)) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLT: 5 < -2 (false)");

        control = 2'b10;
        in1 = 64'hFFFFFFFFFFFFFFF5;
        in2 = 64'hFFFFFFFFFFFFFFFE;
        expected_out = ($signed(in1) < $signed(in2)) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLT: -11 < -2 (true)");

        control = 2'b10;
        in1 = 64'hFFFFFFFFFFFFFFFE;
        in2 = 64'hFFFFFFFFFFFFFFF5;
        expected_out = ($signed(in1) < $signed(in2)) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLT: -2 < -11 (false)");

        // ========================================
        // UNSIGNED COMPARISON TESTS (SLTU)
        // ========================================
        $display("--- UNSIGNED COMPARISON TESTS (SLTU) ---\n");

        control = 2'b11;
        in1 = 64'h0000000000000003;
        in2 = 64'h0000000000000005;
        expected_out = (in1 < in2) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLTU: 3 < 5 (true)");

        control = 2'b11;
        in1 = 64'h0000000000000005;
        in2 = 64'h0000000000000003;
        expected_out = (in1 < in2) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLTU: 5 < 3 (false)");

        control = 2'b11;
        in1 = 64'h0000000000000007;
        in2 = 64'h0000000000000007;
        expected_out = (in1 < in2) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLTU: 7 < 7 (false)");

        control = 2'b11;
        in1 = 64'h0000000000000005;
        in2 = 64'hFFFFFFFFFFFFFFFE;
        expected_out = (in1 < in2) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLTU: 5 < large unsigned (true)");

        control = 2'b11;
        in1 = 64'hFFFFFFFFFFFFFFFE;
        in2 = 64'h0000000000000005;
        expected_out = (in1 < in2) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLTU: large unsigned < 5 (false)");

        control = 2'b11;
        in1 = 64'hFFFFFFFFFFFFFFFF;
        in2 = 64'hFFFFFFFFFFFFFFFE;
        expected_out = (in1 < in2) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLTU: MAX < MAX-1 (false)");

        control = 2'b11;
        in1 = 64'h0000000000000000;
        in2 = 64'h0000000000000001;
        expected_out = (in1 < in2) ? 64'b1 : 64'b0;
        expected_cout = 1'b0;
        check_result("SLTU: 0 < 1 (true)");

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
