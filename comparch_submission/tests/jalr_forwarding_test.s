addi x2, x0, 0
jal x1, L1
nop
addi x2, x2, 10
jal x0, end
nop

L1:
    addi x2, x2, 1
    jalr x0, x1, 0
    nop
    
end:
    jal x0, end