module fpu_cntrl_tb;
  reg  [31:0] instruction;
  wire [ 5:0] fpu_op;
  wire [63:0] out;
  // wire [31:0] in1 = 32'h3f800000;  //1.0
  wire [63:0] in1 = 64'h4048800000000000;  // 49
  //32'h41bd999a;  //23.7
  wire [63:0] in2 = 64'h402a000000000000;  // 13
  //32'h4134cccd;  //11.3


  // Instantiate DUT
  fpu_cntrl dut (
      .instruction(instruction),
      .fpu_op(fpu_op)
  );
  FPU #(
      .BUS_WIDTH(64)
  ) uut (
      .in1(in1),
      .in2(in2),
      .fpu_op(fpu_op),
      .out(out)
  );
  initial begin
    // Test fadd.s f1, f2, f3;
    instruction = 32'h0a20f253;  // funct5[31:27], fmt[26:25], x [24:7], opcode[6:0]
    #10;
    $display("fadd.s op = %b (expected: 000)", fpu_op);
    $display("fadd.s f1, f2, f3 output = %h", out);
    /*
    // Test fsub.s f11, f20, f13;
    instruction = 32'h08da75d3;
    #10;
    $display("fsub.s op = %b (expected: 001)", fpu_op);
    $display("fsub.s output = %h", out);

    // Test fmul.s f21, f7, f9;
    instruction = 32'h1093fad3;
    #10;
    $display("fmul.s op = %b (expected: 010)", fpu_op);
    $display("fmul.s output = %h", out);

    // Test fdiv.s f30, f16, f15;
    instruction = 32'h18f87f53;
    #10;
    $display("fdiv.s op = %b (expected: 011)", fpu_op);
    $display("fdiv.s output = %h", out);

    // Test fsqrt.s f23, f3;
    instruction = 32'h5801fbd3;
    #10;
    $display("fsqrt.s op = %b (expected: 100)", fpu_op);
    $display("fsqrt.s output = %h", out);
  */
    // // Test fcvt.l.d x19, f11;
    // instruction = 32'hc225f9d3;
    // #10;
    // $display("fcvt.l.d op = %b (expected: 101)", fpu_op);
    // $display("fcvt.l.d output = %h (expected: 000)", out);
    //
    // // Test fcvt.d.l f27, x12;
    // instruction = 32'hd2267dd3;
    // #10;
    // $display("fcvt.d.l op = %b (expected: 110)", fpu_op);
    // $display("fcvt.d.l output = %h (expected: 000)", out);

    /*
    // Test unknown instruction (default)
    instruction = 32'b11111_00_xxxxxxxxxxxxxxxxxxxxxxxxxxx_0000000;
    #10;
    $display("unknown op = %b (expected: 111)", fpu_op);
    */
    $display("FPU MORE OPs ADDED");
    $finish;
  end
endmodule
