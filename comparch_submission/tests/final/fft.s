.text
############################################################
# 8-POINT FFT — Radix-2 DIT Cooley-Tukey
############################################################

############################################################
# Initialize X array at 0x00001000
############################################################
    li x1, 0x1000

    # 0x3f800000   (1.0)
    lui  x6, 0x3f800
    sw   x6, 0(x1)

    # 0x00000000   (0.0)
    lui  x6, 0x00000
    sw   x6, 4(x1)

    # 0x00000000   (0.0)
    lui  x6, 0x00000
    sw   x6, 8(x1)

    # 0x00000000   (0.0)
    lui  x6, 0x00000
    sw   x6, 12(x1)

    # 0x00000000   (0.0)
    lui  x6, 0x00000
    sw   x6, 16(x1)

    # 0x00000000   (0.0)
    lui  x6, 0x00000
    sw   x6, 20(x1)

    # 0x00000000   (0.0)
    lui  x6, 0x00000
    sw   x6, 24(x1)

    # 0x00000000   (0.0)
    lui  x6, 0x00000
    sw   x6, 28(x1)

############################################################
# Initialize TWIDDLE array at 0x00004000
############################################################

    #lui  x2, 0x00002
    #addi x2, x2, 0              # x2 = 0x2000
    li x2, 0x2000

    lui  x6, 0x3f800            # W^0 real: 1.0
    sw   x6, 0(x2)
    sw   x0, 4(x2)              # W^0 imag: 0.0

    lui  x6, 0x3f350
    addi x6, x6, 0x4f3          # W^1 real: 0.707...
    sw   x6, 8(x2)
    lui  x6, 0xbf350
    addi x6, x6, 0x4f3          # W^1 imag: -0.707...
    sw   x6, 12(x2)

    sw   x0, 16(x2)             # W^2 real: 0.0
    lui  x6, 0xbf800            # W^2 imag: -1.0
    sw   x6, 20(x2)

    lui  x6, 0xbf350
    addi x6, x6, 0x4f3          # W^3 real: -0.707...
    sw   x6, 24(x2)
    lui  x6, 0xbf350
    addi x6, x6, 0x4f3          # W^3 imag: -0.707...
    sw   x6, 28(x2)

    lui  x6, 0xbf800            # W^4 real: -1.0
    sw   x6, 32(x2)
    sw   x0, 36(x2)             # W^4 imag: 0.0

    lui  x6, 0xbf350
    addi x6, x6, 0x4f3          # W^5 real: -0.707...
    sw   x6, 40(x2)
    lui  x6, 0x3f350
    addi x6, x6, 0x4f3          # W^5 imag: 0.707...
    sw   x6, 44(x2)

    sw   x0, 48(x2)             # W^6 real: 0.0
    lui  x6, 0x3f800            # W^6 imag: 1.0
    sw   x6, 52(x2)

    lui  x6, 0x3f350
    addi x6, x6, 0x4f3          # W^7 real: 0.707...
    sw   x6, 56(x2)
    lui  x6, 0x3f350
    addi x6, x6, 0x4f3          # W^7 imag: 0.707...
    sw   x6, 60(x2)

############################################################
# Initialize BIT_REV array at 0x00008000
############################################################
    #lui  x3, 0x00003
    #addi x3, x3, 0              # x3 = 0x3000
    li x3, 0x3000

    sw   x0, 0(x3)              # 0
    addi x6, x0, 4
    sw   x6, 4(x3)              # 4
    addi x6, x0, 2
    sw   x6, 8(x3)              # 2
    addi x6, x0, 6
    sw   x6, 12(x3)             # 6
    addi x6, x0, 1
    sw   x6, 16(x3)             # 1
    addi x6, x0, 5
    sw   x6, 20(x3)             # 5
    addi x6, x0, 3
    sw   x6, 24(x3)             # 3
    addi x6, x0, 7
    sw   x6, 28(x3)             # 7

############################################################
# Setup output pointer
############################################################
    addi x4, x0, 0              # x4 = OUT = 0x0000

############################################################
# STEP 1: Bit-reversal permutation
############################################################
    addi x5, x0, 0              # i = 0

BIT_REV_LOOP:
    slli x6, x5, 2              # offset = i*4
    add  x7, x3, x6
    lw   x8, 0(x7)              # x8 = bit_rev(i)

    add  x9, x1, x6
    flw  f0, 0(x9)              # f0 = X[i]

    slli x10, x8, 3             # bit_rev(i) * 8
    add  x11, x4, x10
    fsw  f0, 0(x11)             # store real part
    fmv.w.x f1, x0              # f1 = 0.0
    fsw  f1, 4(x11)             # store imag = 0

    addi x5, x5, 1
    addi x12, x0, 8
    blt  x5, x12, BIT_REV_LOOP

############################################################
# STAGE 1: 4 butterflies, span=1
############################################################
    addi x5, x0, 0

STAGE1_LOOP:
    slli x6, x5, 4
    add  x7, x4, x6

    flw  f0, 0(x7)
    flw  f1, 4(x7)
    flw  f2, 8(x7)
    flw  f3, 12(x7)

    fadd.s f4, f0, f2
    fadd.s f5, f1, f3
    fsub.s f6, f0, f2
    fsub.s f7, f1, f3

    fsw  f4, 0(x7)
    fsw  f5, 4(x7)
    fsw  f6, 8(x7)
    fsw  f7, 12(x7)

    addi x5, x5, 1
    addi x12, x0, 4
    blt  x5, x12, STAGE1_LOOP

############################################################
# STAGE 2: 4 butterflies, span=2
############################################################
    addi x5, x0, 0

STAGE2_LOOP:
    slli x6, x5, 5
    add  x7, x4, x6

    addi x8, x0, 0

STAGE2_INNER:
    slli x9, x8, 3
    add  x10, x7, x9
    addi x11, x10, 16

    flw  f0, 0(x10)
    flw  f1, 4(x10)
    flw  f2, 0(x11)
    flw  f3, 4(x11)

    slli x12, x8, 1
    slli x12, x12, 3
    add  x13, x2, x12
    flw  f4, 0(x13)
    flw  f5, 4(x13)

    fmul.s f6, f2, f4
    fmul.s f7, f3, f5
    fsub.s f8, f6, f7

    fmul.s f6, f2, f5
    fmul.s f7, f3, f4
    fadd.s f9, f6, f7

    fadd.s f10, f0, f8
    fadd.s f11, f1, f9
    fsub.s f12, f0, f8
    fsub.s f13, f1, f9

    fsw  f10, 0(x10)
    fsw  f11, 4(x10)
    fsw  f12, 0(x11)
    fsw  f13, 4(x11)

    addi x8, x8, 1
    addi x14, x0, 2
    blt  x8, x14, STAGE2_INNER

    addi x5, x5, 1
    addi x15, x0, 2
    blt  x5, x15, STAGE2_LOOP

############################################################
# STAGE 3: 4 butterflies, span=4
############################################################
    addi x5, x0, 0

STAGE3_LOOP:
    slli x6, x5, 3
    add  x7, x4, x6
    addi x8, x7, 32

    flw  f0, 0(x7)
    flw  f1, 4(x7)
    flw  f2, 0(x8)
    flw  f3, 4(x8)

    slli x9, x5, 3
    add  x10, x2, x9
    flw  f4, 0(x10)
    flw  f5, 4(x10)

    fmul.s f6, f2, f4
    fmul.s f7, f3, f5
    fsub.s f8, f6, f7

    fmul.s f6, f2, f5
    fmul.s f7, f3, f4
    fadd.s f9, f6, f7

    fadd.s f10, f0, f8
    fadd.s f11, f1, f9
    fsub.s f12, f0, f8
    fsub.s f13, f1, f9

    fsw  f10, 0(x7)
    fsw  f11, 4(x7)
    fsw  f12, 0(x8)
    fsw  f13, 4(x8)

    addi x5, x5, 1
    addi x11, x0, 4
    blt  x5, x11, STAGE3_LOOP

############################################################
# END
############################################################
END:
   jal x0, END