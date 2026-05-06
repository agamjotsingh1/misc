li x1, 5
li x2, 10

add x3, x1, x2       # 15
sub x4, x2, x1       # 5
sll x5, x1, x0       # 5 << 0 = 5
srl x6, x2, x1       # 10 >> 5 = 0
xor x7, x1, x2       # 15
or  x8, x1, x2       # 15
and x9, x1, x2       # 0

slt x10, x1, x2      # 1
sltu x11, x2, x1     # 0

loop_r:
    j loop_r             # hang
