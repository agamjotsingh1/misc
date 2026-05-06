addi x1, x0, 10          # x1 = 10
addi x2, x0, 3           # x2 = 3
addi x3, x0, -5          # x3 = -5
lui  x4, 0xF0F0F         # x4 = 0xF0F0F000
addi x4, x4, 0x0F0       # x4 = 0xF0F0F0F0
lui  x5, 0x0F0F0         # x5 = 0x0F0F0000
addi x5, x5, 0xF0F       # x5 = 0x0F0F0F0F
addi x6, x0, 1           # x6 = 1 (shift amount)
addi x7, x0, 0           # clear register

# Arithmetic Instructions

add  x8,  x1, x2         # 10 + 3 = 13
sub  x9,  x1, x2         # 10 - 3 = 7
add  x10, x3, x1         # -5 + 10 = 5

# Logical Instructions

and  x11, x4, x5         # AND
or   x12, x4, x5         # OR
xor  x13, x4, x5         # XOR

# Shift Instructions

sll  x14, x2, x6         # logical left shift
srl  x15, x4, x6         # logical right shift
sra  x16, x3, x6         # arithmetic right shift (sign extend)

# Comparison Instructions

slt  x17, x3, x1         # signed less than
slt  x18, x1, x3         # signed less than (false)
sltu x19, x3, x1         # unsigned less than
sltu x20, x1, x3         # unsigned less than (true)

# Combined R-type Operations

add  x21, x8, x9         # 13 + 7 = 20
xor  x22, x21, x12       # combine results
and  x23, x22, x13       # final logical test
