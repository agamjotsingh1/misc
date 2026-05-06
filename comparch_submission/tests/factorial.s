main:
    # initialize stack pointer
    li sp, 0x100

    # compute factorial(5) example
    li a0, 5
    jal ra, fact
    sd a0, 0(x0)

    # result now in a0
    # end program
    end: jal x0, end

# ---------------------------------------------------------
#   uint64_t fact(uint64_t n)
#   Returns n! in a0
# ---------------------------------------------------------

fact:
    addi sp, sp, -16      # allocate stack frame
    sd   ra, 8(sp)        # save return address
    sd   a0, 0(sp)        # save n

    # base case: if n <= 1 return 1
    li t0, 1
    ble a0, t0, base_case

    # recursive case
    addi a0, a0, -1       # a0 = n-1
    jal ra, fact          # fact(n-1)

    ld t1, 0(sp)          # restore original n
    mul a0, a0, t1        # a0 = n * fact(n-1)
    j done

base_case:
    li a0, 1              # return 1

done:
    ld ra, 8(sp)          # restore return address
    addi sp, sp, 16       # deallocate stack frame
    ret
