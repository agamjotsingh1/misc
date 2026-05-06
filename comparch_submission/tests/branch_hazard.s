addi x1, x0, 5
addi x2, x0, 5
addi x3, x0, 0
beq x1, x2, target
addi x3, x3, 1
target: addi x3, x3, 2
