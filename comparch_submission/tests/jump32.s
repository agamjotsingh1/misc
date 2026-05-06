li x1, 10
    li x2, 10
    li x3, 5

    beq x1, x2, equal
    addi x4, x0, 1        # should skip
equal:
    bne x1, x3, notequal
    addi x5, x0, 2        # should skip
notequal:
    blt x3, x1, less
    addi x6, x0, 3        # skip
less:
    bge x1, x3, greater
    addi x7, x0, 4        # skip
greater:
    j done
done:
    j done
