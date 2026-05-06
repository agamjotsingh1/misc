addi x1, x0, 5
nop
addi x2, x0, 6
nop
nop
nop
nop
blt x1, x2, label
nop
nop
addi x3, x0, 8
nop
nop
nop

label:
    addi x3, x0, 9
    nop
    nop
    nop