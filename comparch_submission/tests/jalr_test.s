addi x2, x0, 10
nop
nop
nop
jal x1, add_func
addi x3, x3, 5
nop
nop
nop
jal x0, end

add_func:
    nop
    nop
    nop
    nop
    addi x3, x2, 20
    jalr x0, x1, 0

end:
    nop
    nop
    nop
    nop
    addi x4, x0, 99
    nop
    nop
    nop