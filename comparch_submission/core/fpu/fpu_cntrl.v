/*
* Arithmetic
1.  fadd.d     6'b000000
2.  fadd.s     6'b000001
3.  fsub.d     6'b000010
4.  fsub.s     6'b000011
5.  fmul.d     6'b000100
6.  fmul.s     6'b000101
7.  fdiv.d     6'b000110
8.  fdiv.s     6'b000111
9.  fsqrt.d    6'b001000
10. fsqrt.s    6'b001001

* Min/Max
11. fmin.d     6'b010000
12. fmin.s     6'b010001
13. fmax.d     6'b010010
14. fmax.s     6'b010011

* Comparission
15. feq.d      6'b010100
16. feq.s      6'b010101
17. flt.d      6'b010110
18. flt.s      6'b010111
19. fge.d      6'b011000
20. fge.s      6'b011001

* Sign Injection
21. fsgnj.d    6'b011010
22. fsgnj.s    6'b011011
23. fsgnjn.d   6'b011100
24. fsgnjn.s   6'b011101
25. fsgnjx.d   6'b011110
26. fsgnjx.s   6'b011111

* MV

27. fmv.x.d    6'b100000
28. fmv.d.x    6'b100001
29. fmv.x.w    6'b101000
30. fmv.w.x    6'b101001

* CVT

31. fcvt.l.d   6'b100010
32. fcvt.d.l   6'b100011
33. fcvt.s.d   6'b100100
34. fcvt.d.s   6'b100101
35. fcvt.s.w   6'b100110
36. fcvt.w.s   6'b100111

* Load Store
37. fld        6'b110000
38. flw        6'b110001
39. fsd        6'b110010
40. fsw        6'b110011

*/
/*
* Flags to be added
* fpu_rd -> 1 if destination resistor is fp
* fpu_rs1 -> 1 if input resistor 1 is rs
* fpu_rs2 -> 1 if input resistor 2 is rs
*/
module fpu_cntrl #(
    parameter BUS_WIDTH  = 64,
    parameter INSTR_LEN  = 32,
    parameter FPU_OP_LEN = 6
) (
    input [INSTR_LEN-1:0] instr,
    output reg [FPU_OP_LEN-1:0] fpu_op,
    output reg fpu_rs1,
    output reg fpu_rs2,
    output reg fpu_rd
);
  wire [ 4:0] funct5 = instr[31:27];
  wire [ 1:0] fmt = instr[26:25];
  wire [ 6:0] opcode = instr[6:0];
  wire [ 2:0] rm = instr[14:12];
  wire [16:0] diff = {funct5, fmt, rm, opcode};

  always @(*) begin
    casez (diff)
      {  // fadd.d
        5'b00000, 2'b01, 3'bz, 7'b1010011
      } : begin
        fpu_op  = 6'b000000;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fadd.s
        5'b00000, 2'b00, 3'bz, 7'b1010011
      } : begin
        fpu_op  = 6'b000001;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fsub.d
        5'b00001, 2'b01, 3'bz, 7'b1010011
      } : begin
        fpu_op  = 6'b000010;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fsub.s
        5'b00001, 2'b00, 3'bz, 7'b1010011
      } : begin
        fpu_op  = 6'b000011;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fmul.d
        5'b00010, 2'b01, 3'bz, 7'b1010011
      } : begin
        fpu_op  = 6'b000100;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fmul.s
        5'b00010, 2'b00, 3'bz, 7'b1010011
      } : begin
        fpu_op  = 6'b000101;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fdiv.d
        5'b00011, 2'b01, 3'bz, 7'b1010011
      } : begin
        fpu_op  = 6'b000110;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fdv.s
        5'b00011, 2'b00, 3'bz, 7'b1010011
      } : begin
        fpu_op  = 6'b000111;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fsqrt.d
        5'b01011, 2'b01, 3'bz, 7'b1010011
      } : begin
        fpu_op  = 6'b001000;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 0;
      end
      {  // fsqrt.s
        5'b01011, 2'b00, 3'bz, 7'b1010011
      } : begin
        fpu_op  = 6'b001001;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 0;
      end


      {  // fmin.d
        5'b00101, 2'b01, 3'b000, 7'b1010011
      } : begin
        fpu_op  = 6'b010000;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fmin.s
        5'b00101, 2'b00, 3'b000, 7'b1010011
      } : begin
        fpu_op  = 6'b010001;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fmax.d
        5'b00101, 2'b01, 3'b001, 7'b1010011
      } : begin
        fpu_op  = 6'b010010;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fmax.s
        5'b00101, 2'b00, 3'b001, 7'b1010011
      } : begin
        fpu_op  = 6'b010011;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end


      {  // feq.d
        5'b10100, 2'b01, 3'b010, 7'b1010011
      } : begin
        fpu_op  = 6'b010100;
        fpu_rd  = 0;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fmax.s
        5'b10100, 2'b00, 3'b010, 7'b1010011
      } : begin
        fpu_op  = 6'b010101;
        fpu_rd  = 0;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end

      {  // flt.d
        5'b10100, 2'b01, 3'b001, 7'b1010011
      } : begin
        fpu_op  = 6'b010110;
        fpu_rd  = 0;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // flt.s
        5'b10100, 2'b00, 3'b001, 7'b1010011
      } : begin
        fpu_op  = 6'b010111;
        fpu_rd  = 0;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end

      {  // fle.d
        5'b10100, 2'b01, 3'b000, 7'b1010011
      } : begin
        fpu_op  = 6'b011000;
        fpu_rd  = 0;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fle.s
        5'b10100, 2'b00, 3'b000, 7'b1010011
      } : begin
        fpu_op  = 6'b011001;
        fpu_rd  = 0;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end


      {  // fsgnj.d
        5'b00100, 2'b01, 3'b000, 7'b1010011
      } : begin
        fpu_op  = 6'b011010;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fsgnj.s
        5'b00100, 2'b00, 3'b000, 7'b1010011
      } : begin
        fpu_op  = 6'b011011;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fsgnjn.d
        5'b00100, 2'b01, 3'b001, 7'b1010011
      } : begin
        fpu_op  = 6'b011100;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fsgnj.s
        5'b00100, 2'b00, 3'b001, 7'b1010011
      } : begin
        fpu_op  = 6'b011101;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fsgnjx.d
        5'b00100, 2'b01, 3'b010, 7'b1010011
      } : begin
        fpu_op  = 6'b011110;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end
      {  // fsgnjs.s
        5'b00100, 2'b00, 3'b010, 7'b1010011
      } : begin
        fpu_op  = 6'b011111;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 1;
      end

      {  // fmv.x.d
        5'b11100, 2'b01, 3'b000, 7'b1010011
      } : begin
        fpu_op  = 6'b100000;
        fpu_rd  = 0;
        fpu_rs1 = 1;
        fpu_rs2 = 0;
      end
      {  // fmv.d.x
        5'b11110, 2'b01, 3'b000, 7'b1010011
      } : begin
        fpu_op  = 6'b100001;
        fpu_rd  = 1;
        fpu_rs1 = 0;
        fpu_rs2 = 0;
      end
      {  // fmv.x.w
        5'b11100, 2'b00, 3'b000, 7'b1010011
      } : begin
        fpu_op  = 6'b101000;
        fpu_rd  = 0;
        fpu_rs1 = 1;
        fpu_rs2 = 0;
      end
      {  // fmv.w.x
        5'b11110, 2'b00, 3'bzzz, 7'b1010011
      } : begin
        fpu_op  = 6'b101001;
        fpu_rd  = 1;
        fpu_rs1 = 0;
        fpu_rs2 = 0;
      end
      {  // fcvt.l.d
        5'b11000, 2'b01, 3'bzzz, 7'b1010011
      } : begin
        fpu_op  = 6'b100010;
        fpu_rd  = 0;
        fpu_rs1 = 1;
        fpu_rs2 = 0;
      end
      {  // fcvt.d.l
        5'b11010, 2'b01, 3'bzzz, 7'b1010011
      } : begin
        fpu_op  = 6'b100011;
        fpu_rd  = 1;
        fpu_rs1 = 0;
        fpu_rs2 = 0;
      end

      {  // fcvt.w.s
        5'b11000, 2'b00, 3'bzzz, 7'b1010011
      } : begin
        fpu_op  = 6'b100110;
        fpu_rd  = 0;
        fpu_rs1 = 1;
        fpu_rs2 = 0;
      end
      {  // fcvt.s.w
        5'b11010, 2'b00, 3'bzzz, 7'b1010011
      } : begin
        fpu_op  = 6'b100111;
        fpu_rd  = 1;
        fpu_rs1 = 0;
        fpu_rs2 = 0;
      end
      {  // fcvt.s.d
        5'b01000, 2'b00, 3'bzzz, 7'b1010011
      } : begin
        fpu_op  = 6'b100100;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 0;
      end
      {  // fcvt.d.s
        5'b01000, 2'b01, 3'bzzz, 7'b1010011
      } : begin
        fpu_op  = 6'b100101;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 0;
      end
      {  // fld
        5'bzzzzz, 2'bzz, 3'b011, 7'b0000111
      } : begin
        fpu_op  = 6'b110000;
        fpu_rd  = 1;
        fpu_rs1 = 0;
        fpu_rs2 = 0;
      end
      {  // flw
        5'bzzzzz, 2'bzz, 3'b010, 7'b0000111
      } : begin
        fpu_op  = 6'b110001;
        fpu_rd  = 1;
        fpu_rs1 = 0;
        fpu_rs2 = 0;
      end
      {  // fsd
        5'bzzzzz, 2'bzz, 3'b011, 7'b0100111
      } : begin
        fpu_op  = 6'b110010;
        fpu_rd  = 0;
        fpu_rs1 = 0;
        fpu_rs2 = 1;
      end
      {  // fsw
        5'bzzzzz, 2'bzz, 3'b010, 7'b0100111
      } : begin
        fpu_op  = 6'b110011;
        fpu_rd  = 0;
        fpu_rs1 = 0;
        fpu_rs2 = 1;
      end
      default: begin
        fpu_op  = 6'b111111;
        fpu_rd  = 1;
        fpu_rs1 = 1;
        fpu_rs2 = 0;
      end
    endcase
  end
endmodule
