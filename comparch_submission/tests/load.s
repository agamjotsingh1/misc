#############################################################
# Base address setup
#############################################################

lui   x20, 0x1            # x20 = 0x00001000 (RAM base)

#############################################################
# Initialize basic constants in registers
#############################################################

addi  x1, x0, 10          # 10
addi  x2, x0, 3           # 3
addi  x3, x0, -5          # -5
lui   x4, 0xF0F0F
addi  x4, x4, 0x0F0       # 0xF0F0F0F0
lui   x5, 0x0F0F0
addi  x5, x5, 0xF0F       # 0x0F0F0F0F
addi  x6, x0, 1           # shift amount

#############################################################
# Store constants into memory using sb, sh, sw, sd
#############################################################

sb    x1, 0(x20)          # store byte 10 at 0x1000
sh    x2, 2(x20)          # store halfword 3 at 0x1002
sw    x3, 4(x20)          # store word -5 at 0x1004
sd    x4, 8(x20)          # store doubleword 0xF0F0F0F0 at 0x1008
sw    x5, 16(x20)         # store 0x0F0F0F0F at 0x1010

#############################################################
# Load them back (mixed load widths)
#############################################################

lb    x7, 0(x20)          # load byte → 10
lh    x8, 2(x20)          # load halfword → 3
lw    x9, 4(x20)          # load word → -5
ld    x10, 8(x20)         # load doubleword → 0xF0F0F0F0
lw    x11, 16(x20)        # load word → 0x0F0F0F0F

#############################################################
# R-type and hazard testing
#############################################################

add   x12, x7, x8         # 10 + 3 = 13
sub   x13, x7, x8         # 10 - 3 = 7
and   x14, x10, x11       # bitwise AND
or    x15, x10, x11       # bitwise OR
xor   x16, x10, x11       # bitwise XOR
sll   x17, x8, x6         # 3 << 1 = 6
srl   x18, x10, x6        # logical right shift
sra   x19, x9, x6         # arithmetic right shift (-5 >> 1 = -3)
slt   x21, x9, x7         # signed less than (-5 < 10 = 1)
sltu  x22, x7, x9         # unsigned less than (false)

#############################################################
# Store R-type results using various store sizes
#############################################################

sb    x12, 20(x20)        # store ADD result (byte)
sh    x13, 22(x20)        # store SUB result (halfword)
sw    x14, 24(x20)        # store AND result (word)
sd    x15, 28(x20)        # store OR result (doubleword)
sw    x16, 36(x20)        # store XOR result (word)

#############################################################
# Immediate load-use hazard test (no delay slot)
#############################################################

lb    x23, 20(x20)        # x23 = ADD result (13)
add   x24, x23, x7        # depends on freshly loaded value (13 + 10 = 23)
lh    x25, 22(x20)        # x25 = SUB result (7)
sub   x26, x25, x8        # depends on load (7 - 3 = 4)

#############################################################
# Store results again with mixed sizes (store hazards)
#############################################################

sb    x24, 40(x20)        # store byte 23
sh    x26, 42(x20)        # store halfword 4
sw    x24, 44(x20)        # store word 23
sd    x26, 48(x20)        # store doubleword 4

#############################################################
# Reload and recombine (store-load + forwarding)
#############################################################

lb    x27, 40(x20)        # 23
lh    x28, 42(x20)        # 4
lw    x29, 44(x20)        # 23
ld    x30, 48(x20)        # 4
add   x31, x27, x28       # 23 + 4 = 27

#############################################################
# Chain dependencies (multi-stage RAW hazards)
#############################################################

add   x5, x31, x1         # x5 = 27 + 10 = 37
xor   x6, x5, x2          # x6 = 37 XOR 3
and   x7, x6, x4          # x7 = (x6 & 0xF0F0F0F0)
or    x8, x7, x11         # combine with previous word
add   x9, x8, x31         # depends on chain result

#############################################################
# Final mixed stores
#############################################################

sb    x9,  56(x20)
sh    x9,  58(x20)
sw    x9,  60(x20)
sd    x9,  64(x20)

#############################################################
# End of program (infinite loop)
#############################################################

done:
j done
