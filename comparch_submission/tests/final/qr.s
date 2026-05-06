.data
A:
.word 0x40a00000   # 5.0
    .word 0x40000000   # 2.0
    .word 0x3f800000   # 1.0

    .word 0x40000000   # 2.0
    .word 0x40400000   # 3.0
    .word 0x00000000   # 0.0

    .word 0x3f800000   # 1.0
    .word 0x00000000   # 0.0
    .word 0x40800000   # 4.0

.text
############################################################
# Load A (3x3) into f0..f8
# f0=A00, f1=A01, f2=A02
# f3=A10, f4=A11, f5=A12
# f6=A20, f7=A21, f8=A22
############################################################
    la t0, A
    # li t0, 0x100
    # data segment starts at 0x100
    flw  f0,  0(t0)
    flw  f1,  4(t0)
    flw  f2,  8(t0)
    flw  f3, 12(t0)
    flw  f4, 16(t0)
    flw  f5, 20(t0)
    flw  f6, 24(t0)
    flw  f7, 28(t0)
    flw  f8, 32(t0)

# constants: f29=1.0, f30=0.0, f31=2.0
    li t1,1
    fcvt.s.w f29,t1
    fsgnj.s f30,f0,f0
    fsub.s  f30,f30,f30
    li t2,2
    fcvt.s.w f31,t2

############################################################
# HOUSEHOLDER 1 on column 0 (rows 0..2)
# build v = x + sign(x0)*||x|| e1, normalize into f12..f14
############################################################

    # norm_x = sqrt(A00^2 + A10^2 + A20^2)
    fmul.s f10,f0,f0
    fmul.s f11,f3,f3
    fadd.s f10,f10,f11
    fmul.s f11,f6,f6
    fadd.s f10,f10,f11
    fsqrt.s f10,f10        # f10 = norm_x

    # alpha = sign(A00) * norm_x
    fsgnj.s f11,f10,f0     # f11 = alpha

    # v = x + alpha*e1
    fadd.s f12,f0,f11      # v0 -> f12
    fsgnj.s f13,f3,f3      # v1 -> f13
    fsgnj.s f14,f6,f6      # v2 -> f14

    # vnorm = sqrt(v0^2 + v1^2 + v2^2)
    fmul.s f15,f12,f12
    fmul.s f16,f13,f13
    fadd.s f15,f15,f16
    fmul.s f16,f14,f14
    fadd.s f15,f15,f16
    fsqrt.s f15,f15        # f15 = vnorm

    # normalize v
    fdiv.s f12,f12,f15
    fdiv.s f13,f13,f15
    fdiv.s f14,f14,f15

############################################################
# Apply H1 = I - 2 v v^T to A (all columns)
############################################################

# column 0
    fmul.s f16,f12,f0
    fmul.s f17,f13,f3
    fadd.s f16,f16,f17
    fmul.s f17,f14,f6
    fadd.s f16,f16,f17     # dot = f16

    fmul.s f16,f16,f31     # 2*dot

    fmul.s f17,f12,f16
    fsub.s f0,f0,f17
    fmul.s f17,f13,f16
    fsub.s f3,f3,f17
    fmul.s f17,f14,f16
    fsub.s f6,f6,f17

# column 1
    fmul.s f16,f12,f1
    fmul.s f17,f13,f4
    fadd.s f16,f16,f17
    fmul.s f17,f14,f7
    fadd.s f16,f16,f17

    fmul.s f16,f16,f31

    fmul.s f17,f12,f16
    fsub.s f1,f1,f17
    fmul.s f17,f13,f16
    fsub.s f4,f4,f17
    fmul.s f17,f14,f16
    fsub.s f7,f7,f17

# column 2
    fmul.s f16,f12,f2
    fmul.s f17,f13,f5
    fadd.s f16,f16,f17
    fmul.s f17,f14,f8
    fadd.s f16,f16,f17

    fmul.s f16,f16,f31

    fmul.s f17,f12,f16
    fsub.s f2,f2,f17
    fmul.s f17,f13,f16
    fsub.s f5,f5,f17
    fmul.s f17,f14,f16
    fsub.s f8,f8,f17

############################################################
# HOUSEHOLDER 2 on subcolumn (rows 1..2, col 1)
# x2 = [A11;A21] in f4,f7 -> build v2 into f10,f11
############################################################

    # norm_x2 = sqrt(A11^2 + A21^2)
    fmul.s f16,f4,f4
    fmul.s f17,f7,f7
    fadd.s f16,f16,f17
    fsqrt.s f16,f16        # f16 = norm_x2

    # alpha2 = sign(A11) * norm_x2
    fsgnj.s f17,f16,f4     # f17 = alpha2

    # v' = [A11 + alpha2; A21]
    fadd.s f10,f4,f17      # v2_0 -> f10
    fsgnj.s f11,f7,f7      # v2_1 -> f11

    # v2norm = sqrt(v0'^2 + v1'^2)
    fmul.s f18,f10,f10
    fmul.s f19,f11,f11
    fadd.s f18,f18,f19
    fsqrt.s f18,f18        # f18 = v2norm

    # normalize v2
    fdiv.s f10,f10,f18
    fdiv.s f11,f11,f18

############################################################
# Apply H2 = I - 2 v2 v2^T to A (only affects rows 1..2)
############################################################

# column 1 (A11,A21) -> f4,f7
    fmul.s f17,f10,f4
    fmul.s f19,f11,f7
    fadd.s f17,f17,f19    # dot
    fmul.s f17,f17,f31    # 2*dot

    fmul.s f19,f10,f17
    fsub.s f4,f4,f19
    fmul.s f19,f11,f17
    fsub.s f7,f7,f19

# column 2 (A12,A22) -> f5,f8
    fmul.s f17,f10,f5
    fmul.s f19,f11,f8
    fadd.s f17,f17,f19    # dot
    fmul.s f17,f17,f31

    fmul.s f19,f10,f17
    fsub.s f5,f5,f19
    fmul.s f19,f11,f17
    fsub.s f8,f8,f19

# Note: column 0 unaffected by H2

############################################################
# Now A (f0..f8) is upper-triangular R
# Compute Q columns c0,c1,c2 = H1 * (H2 * e_i) and store them into row-major Q
# Base address for Q_out = 0x00000000
############################################################

    li t3, 0    # base pointer (address 0x0)

# -----------------------------
# Column 0: compute q = H1*(H2*e0)
# -----------------------------
# start q = e0
    fsgnj.s f20,f29,f29   # q0 = 1.0
    fsgnj.s f21,f30,f30   # q1 = 0.0
    fsgnj.s f22,f30,f30   # q2 = 0.0

# apply H2: only rows 1..2
    fmul.s f23,f10,f21
    fmul.s f24,f11,f22
    fadd.s f23,f23,f24    # dot2

    fmul.s f24,f23,f31    # 2*dot2
    fmul.s f25,f10,f24
    fsub.s f21,f21,f25
    fmul.s f25,f11,f24
    fsub.s f22,f22,f25

# apply H1: full 3x3
    fmul.s f23,f12,f20
    fmul.s f24,f13,f21
    fadd.s f23,f23,f24
    fmul.s f24,f14,f22
    fadd.s f23,f23,f24     # dot1

    fmul.s f24,f23,f31
    fmul.s f25,f12,f24
    fsub.s f20,f20,f25
    fmul.s f25,f13,f24
    fsub.s f21,f21,f25
    fmul.s f25,f14,f24
    fsub.s f22,f22,f25

# STORE COLUMN 0 INTO ROW-MAJOR Q:
# locations: base + (row*12 + col*4)
# col=0 => offsets 0,12,24
    fsw f20, 0(t3)        # Q[0][0]
    fsw f21, 12(t3)       # Q[1][0]
    fsw f22, 24(t3)       # Q[2][0]

# -----------------------------
# Column 1: compute q = H1*(H2*e1)
# -----------------------------
# start q = e1
    fsgnj.s f20,f30,f30   # q0 = 0
    fsgnj.s f21,f29,f29   # q1 = 1
    fsgnj.s f22,f30,f30   # q2 = 0

# apply H2
    fmul.s f23,f10,f21
    fmul.s f24,f11,f22
    fadd.s f23,f23,f24
    fmul.s f24,f23,f31
    fmul.s f25,f10,f24
    fsub.s f21,f21,f25
    fmul.s f25,f11,f24
    fsub.s f22,f22,f25

# apply H1
    fmul.s f23,f12,f20
    fmul.s f24,f13,f21
    fadd.s f23,f23,f24
    fmul.s f24,f14,f22
    fadd.s f23,f23,f24
    fmul.s f24,f23,f31
    fmul.s f25,f12,f24
    fsub.s f20,f20,f25
    fmul.s f25,f13,f24
    fsub.s f21,f21,f25
    fmul.s f25,f14,f24
    fsub.s f22,f22,f25

# STORE COLUMN 1 INTO ROW-MAJOR Q:
# col=1 => offsets 4,16,28
    fsw f20, 4(t3)        # Q[0][1]
    fsw f21, 16(t3)       # Q[1][1]
    fsw f22, 28(t3)       # Q[2][1]

# -----------------------------
# Column 2: compute q = H1*(H2*e2)
# -----------------------------
# start q = e2
    fsgnj.s f20,f30,f30   # q0 = 0
    fsgnj.s f21,f30,f30   # q1 = 0
    fsgnj.s f22,f29,f29   # q2 = 1

# apply H2
    fmul.s f23,f10,f21
    fmul.s f24,f11,f22
    fadd.s f23,f23,f24
    fmul.s f24,f23,f31
    fmul.s f25,f10,f24
    fsub.s f21,f21,f25
    fmul.s f25,f11,f24
    fsub.s f22,f22,f25

# apply H1
    fmul.s f23,f12,f20
    fmul.s f24,f13,f21
    fadd.s f23,f23,f24
    fmul.s f24,f14,f22
    fadd.s f23,f23,f24
    fmul.s f24,f23,f31
    fmul.s f25,f12,f24
    fsub.s f20,f20,f25
    fmul.s f25,f13,f24
    fsub.s f21,f21,f25
    fmul.s f25,f14,f24
    fsub.s f22,f22,f25

# STORE COLUMN 2 INTO ROW-MAJOR Q:
# col=2 => offsets 8,20,32
    fsw f20, 8(t3)        # Q[0][2]
    fsw f21, 20(t3)       # Q[1][2]
    fsw f22, 32(t3)       # Q[2][2]

############################################################
# write the two 0 padding words (addr+36 and addr+40)
############################################################
    sw x0, 36(t3)
    sw x0, 40(t3)

############################################################
# STORE R (A now upper-triangular) starting at addr+44
# Desired ordering:
# R00 R01 R02
# R10 R11 R12
# R20 R21 R22
############################################################

    # R row 0 (addr 44..56)
    fsw f0, 44(t3)      # R00
    fsw f1, 48(t3)      # R01
    fsw f2, 52(t3)      # R02

    # R row 1 (addr 56..68)
    sw  x0, 56(t3)      # R10 = 0
    fsw f4, 60(t3)      # R11
    fsw f5, 64(t3)      # R12

    # R row 2 (addr 68..80)
    sw x0, 68(t3)       # R20 = 0
    sw x0, 72(t3)       # R21 = 0
    fsw f8, 76(t3)      # R22

############################################################
# HALT
############################################################
halt:
    jal x0, halt