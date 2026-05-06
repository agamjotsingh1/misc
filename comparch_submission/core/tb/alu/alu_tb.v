`timescale 1ns/1ps

module tb_alu;
    reg [63:0] in1;
    reg [63:0] in2;
    reg [1:0] control;
    reg [2:0] select;
    wire zero;
    wire neg;
    wire negu;
    wire [63:0] out;

    // Expected values
    reg [63:0] expected_out;
    reg expected_zero;
    reg expected_neg;
    reg expected_negu;
    reg [127:0] temp_mul_result;
    
    // Test counters
    integer test_num;
    integer pass_count;
    integer fail_count;

    // Instantiate DUT
    alu dut (
        .in1(in1),
        .in2(in2),
        .control(control),
        .select(select),
        .zero(zero),
        .neg(neg),
        .negu(negu),
        .out(out)
    );

    initial begin
        // Initialize
        test_num = 0;
        pass_count = 0;
        fail_count = 0;
        in1 = 0;
        in2 = 0;
        control = 0;
        select = 0;

        $display("========================================");
        $display("Starting ALU Module Testbench");
        $display("========================================\n");

        // ========================================
        // ADDSUB TESTS (select = 3'b000)
        // ========================================
        $display("--- ADD TESTS ---\n");

        // Test 1: ADD
        test_num = test_num + 1;
        select = 3'b000;
        control = 2'b00;
        in1 = 64'h0000000000000005;
        in2 = 64'h0000000000000003;
        expected_out = in1 + in2;
        expected_zero = (in1 == in2);
        expected_neg = ($signed(in1) < $signed(in2));
        expected_negu = ($unsigned(in1) < $unsigned(in2));
        #1;
        if (out === expected_out && zero === expected_zero && neg === expected_neg && negu === expected_negu) begin
            $display("[PASS] Test %0d: ADD (5 + 3 = 8)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: ADD", test_num);
            $display("       Expected: out=%h, zero=%b, neg=%b, negu=%b", expected_out, expected_zero, expected_neg, expected_negu);
            $display("       Got:      out=%h, zero=%b, neg=%b, negu=%b", out, zero, neg, negu);
            fail_count = fail_count + 1;
        end
        $display("");

        // Test 2: ADD with overflow
        test_num = test_num + 1;
        select = 3'b000;
        control = 2'b00;
        in1 = 64'hFFFFFFFFFFFFFFFF;
        in2 = 64'h0000000000000001;
        expected_out = in1 + in2;
        expected_zero = (in1 == in2);
        expected_neg = ($signed(in1) < $signed(in2));
        expected_negu = ($unsigned(in1) < $unsigned(in2));
        #1;
        if (out === expected_out && zero === expected_zero && neg === expected_neg && negu === expected_negu) begin
            $display("[PASS] Test %0d: ADD overflow (MAX + 1)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: ADD overflow", test_num);
            $display("       Expected: out=%h, zero=%b, neg=%b, negu=%b", expected_out, expected_zero, expected_neg, expected_negu);
            $display("       Got:      out=%h, zero=%b, neg=%b, negu=%b", out, zero, neg, negu);
            fail_count = fail_count + 1;
        end
        $display("");

        $display("--- SUB TESTS ---\n");

        // Test 3: SUB
        test_num = test_num + 1;
        select = 3'b000;
        control = 2'b01;
        in1 = 64'h0000000000000008;
        in2 = 64'h0000000000000003;
        expected_out = in1 - in2;
        expected_zero = (in1 == in2);
        expected_neg = ($signed(in1) < $signed(in2));
        expected_negu = ($unsigned(in1) < $unsigned(in2));
        #1;
        if (out === expected_out && zero === expected_zero && neg === expected_neg && negu === expected_negu) begin
            $display("[PASS] Test %0d: SUB (8 - 3 = 5)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: SUB", test_num);
            $display("       Expected: out=%h, zero=%b, neg=%b, negu=%b", expected_out, expected_zero, expected_neg, expected_negu);
            $display("       Got:      out=%h, zero=%b, neg=%b, negu=%b", out, zero, neg, negu);
            fail_count = fail_count + 1;
        end
        $display("");

        $display("--- SLT TESTS ---\n");

        // Test 4: SLT (true)
        test_num = test_num + 1;
        select = 3'b000;
        control = 2'b10;
        in1 = 64'h0000000000000003;
        in2 = 64'h0000000000000005;
        expected_out = ($signed(in1) < $signed(in2)) ? 64'b1 : 64'b0;
        expected_zero = (in1 == in2);
        expected_neg = ($signed(in1) < $signed(in2));
        expected_negu = ($unsigned(in1) < $unsigned(in2));
        #1;
        if (out === expected_out && zero === expected_zero && neg === expected_neg && negu === expected_negu) begin
            $display("[PASS] Test %0d: SLT (3 < 5 = true)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: SLT", test_num);
            $display("       Expected: out=%h, zero=%b, neg=%b, negu=%b", expected_out, expected_zero, expected_neg, expected_negu);
            $display("       Got:      out=%h, zero=%b, neg=%b, negu=%b", out, zero, neg, negu);
            fail_count = fail_count + 1;
        end
        $display("");

        $display("--- SLTU TESTS ---\n");

        // Test 5: SLTU (false)
        test_num = test_num + 1;
        select = 3'b000;
        control = 2'b11;
        in1 = 64'hFFFFFFFFFFFFFFFE;
        in2 = 64'h0000000000000005;
        expected_out = ($unsigned(in1) < $unsigned(in2)) ? 64'b1 : 64'b0;
        expected_zero = (in1 == in2);
        expected_neg = ($signed(in1) < $signed(in2));
        expected_negu = ($unsigned(in1) < $unsigned(in2));
        #1;
        if (out === expected_out && zero === expected_zero && neg === expected_neg && negu === expected_negu) begin
            $display("[PASS] Test %0d: SLTU (large < 5 = false)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: SLTU", test_num);
            $display("       Expected: out=%h, zero=%b, neg=%b, negu=%b", expected_out, expected_zero, expected_neg, expected_negu);
            $display("       Got:      out=%h, zero=%b, neg=%b, negu=%b", out, zero, neg, negu);
            fail_count = fail_count + 1;
        end
        $display("");

        // ========================================
        // MULTIPLICATION TESTS (select = 3'b001)
        // ========================================
        $display("--- MUL TESTS ---\n");

        // Test 6: MUL
        test_num = test_num + 1;
        select = 3'b001;
        control = 2'b00;
        in1 = 64'h0000000000000005;
        in2 = 64'h0000000000000003;
        temp_mul_result = $signed(in1) * $signed(in2);
        expected_out = temp_mul_result[63:0];
        expected_zero = (in1 == in2);
        expected_neg = ($signed(in1) < $signed(in2));
        expected_negu = ($unsigned(in1) < $unsigned(in2));
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: MUL (5 * 3 = 15)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: MUL", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // Test 7: MULH
        test_num = test_num + 1;
        select = 3'b001;
        control = 2'b01;
        in1 = 64'h7FFFFFFFFFFFFFFF;
        in2 = 64'h0000000000000002;
        temp_mul_result = $signed(in1) * $signed(in2);
        expected_out = temp_mul_result[127:64];
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: MULH (MAX_INT * 2 upper)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: MULH", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // Test 8: MULHSU
        test_num = test_num + 1;
        select = 3'b001;
        control = 2'b10;
        in1 = 64'hFFFFFFFFFFFFFFFE;
        in2 = 64'h0000000000000005;
        temp_mul_result = $signed(in1) * $unsigned(in2);
        expected_out = temp_mul_result[127:64];
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: MULHSU ((-2) * 5u upper)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: MULHSU", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // Test 9: MULHU
        test_num = test_num + 1;
        select = 3'b001;
        control = 2'b11;
        in1 = 64'hFFFFFFFFFFFFFFFF;
        in2 = 64'h0000000000000002;
        temp_mul_result = $unsigned(in1) * $unsigned(in2);
        expected_out = temp_mul_result[127:64];
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: MULHU (MAX_UINT * 2 upper)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: MULHU", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // ========================================
        // DIVISION TESTS (select = 3'b010)
        // ========================================
        $display("--- DIV TESTS ---\n");

        // Test 10: DIV
        test_num = test_num + 1;
        select = 3'b010;
        control = 2'b00;
        in1 = 64'h000000000000000A;
        in2 = 64'h0000000000000002;
        expected_out = $signed(in1) / $signed(in2);
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: DIV (10 / 2 = 5)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: DIV", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // Test 11: DIVU
        test_num = test_num + 1;
        select = 3'b010;
        control = 2'b01;
        in1 = 64'h000000000000000A;
        in2 = 64'h0000000000000002;
        expected_out = $unsigned(in1) / $unsigned(in2);
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: DIVU (10 / 2 = 5)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: DIVU", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // Test 12: REM
        test_num = test_num + 1;
        select = 3'b010;
        control = 2'b10;
        in1 = 64'h000000000000000B;
        in2 = 64'h0000000000000003;
        expected_out = $signed(in1) % $signed(in2);
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: REM (11 %% 3 = 2)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: REM", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // Test 13: REMU
        test_num = test_num + 1;
        select = 3'b010;
        control = 2'b11;
        in1 = 64'h000000000000000B;
        in2 = 64'h0000000000000003;
        expected_out = $unsigned(in1) % $unsigned(in2);
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: REMU (11 %% 3 = 2)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: REMU", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // ========================================
        // SHIFT TESTS
        // ========================================
        $display("--- SHIFT LEFT TESTS ---\n");

        // Test 14: SLL
        test_num = test_num + 1;
        select = 3'b011;
        control = 2'b00;
        in1 = 64'h0000000000000001;
        in2 = 64'h0000000000000004;
        expected_out = in1 << in2[5:0];
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: SLL (1 << 4 = 16)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: SLL", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        $display("--- SHIFT RIGHT TESTS ---\n");

        // Test 15: SRL
        test_num = test_num + 1;
        select = 3'b100;
        control = 2'b00;
        in1 = 64'h00000000000000F0;
        in2 = 64'h0000000000000004;
        expected_out = in1 >> in2[5:0];
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: SRL (0xF0 >> 4 = 0x0F)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: SRL", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // Test 16: SRA
        test_num = test_num + 1;
        select = 3'b100;
        control = 2'b01;
        in1 = 64'h8000000000000000;
        in2 = 64'h0000000000000004;
        expected_out = $signed(in1) >>> in2[5:0];
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: SRA (0x8000... >>> 4 sign extend)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: SRA", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // ========================================
        // LOGICAL OPERATIONS
        // ========================================
        $display("--- LOGICAL OPERATION TESTS ---\n");

        // Test 17: XOR
        test_num = test_num + 1;
        select = 3'b101;
        control = 2'b00;
        in1 = 64'h5555555555555555;
        in2 = 64'hAAAAAAAAAAAAAAAA;
        expected_out = in1 ^ in2;
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: XOR (0x5555 ^ 0xAAAA = 0xFFFF)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: XOR", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // Test 18: OR
        test_num = test_num + 1;
        select = 3'b110;
        control = 2'b00;
        in1 = 64'h5555555555555555;
        in2 = 64'hAAAAAAAAAAAAAAAA;
        expected_out = in1 | in2;
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: OR (0x5555 | 0xAAAA = 0xFFFF)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: OR", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // Test 19: AND
        test_num = test_num + 1;
        select = 3'b111;
        control = 2'b00;
        in1 = 64'h5555555555555555;
        in2 = 64'hAAAAAAAAAAAAAAAA;
        expected_out = in1 & in2;
        #1;
        if (out === expected_out) begin
            $display("[PASS] Test %0d: AND (0x5555 & 0xAAAA = 0)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: AND", test_num);
            $display("       Expected: out=%h", expected_out);
            $display("       Got:      out=%h", out);
            fail_count = fail_count + 1;
        end
        $display("");

        // ========================================
        // FLAG TESTS
        // ========================================
        $display("--- FLAG TESTS ---\n");

        // Test 20: Zero flag (equal values)
        test_num = test_num + 1;
        select = 3'b000;
        control = 2'b00;
        in1 = 64'h0000000000000005;
        in2 = 64'h0000000000000005;
        expected_zero = 1'b1;
        expected_neg = 1'b0;
        expected_negu = 1'b0;
        #1;
        if (zero === expected_zero && neg === expected_neg && negu === expected_negu) begin
            $display("[PASS] Test %0d: Zero flag (5 == 5)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: Zero flag", test_num);
            $display("       Expected: zero=%b, neg=%b, negu=%b", expected_zero, expected_neg, expected_negu);
            $display("       Got:      zero=%b, neg=%b, negu=%b", zero, neg, negu);
            fail_count = fail_count + 1;
        end
        $display("");

        // Test 21: Neg flag (signed less than)
        test_num = test_num + 1;
        in1 = 64'h0000000000000003;
        in2 = 64'h0000000000000005;
        expected_zero = 1'b0;
        expected_neg = 1'b1;
        expected_negu = 1'b1;
        #1;
        if (zero === expected_zero && neg === expected_neg && negu === expected_negu) begin
            $display("[PASS] Test %0d: Neg flag (3 < 5)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: Neg flag", test_num);
            $display("       Expected: zero=%b, neg=%b, negu=%b", expected_zero, expected_neg, expected_negu);
            $display("       Got:      zero=%b, neg=%b, negu=%b", zero, neg, negu);
            fail_count = fail_count + 1;
        end
        $display("");

        // Test 22: Negu flag (unsigned comparison)
        test_num = test_num + 1;
        in1 = 64'h0000000000000005;
        in2 = 64'hFFFFFFFFFFFFFFFE;
        expected_zero = 1'b0;
        expected_neg = 1'b0; // 5 > -2 in signed
        expected_negu = 1'b1; // 5 < large unsigned
        #1;
        if (zero === expected_zero && neg === expected_neg && negu === expected_negu) begin
            $display("[PASS] Test %0d: Negu flag (5 < 0xFFFE unsigned)", test_num);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: Negu flag", test_num);
            $display("       Expected: zero=%b, neg=%b, negu=%b", expected_zero, expected_neg, expected_negu);
            $display("       Got:      zero=%b, neg=%b, negu=%b", zero, neg, negu);
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