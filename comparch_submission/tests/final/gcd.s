.data
A:
.word 0x30 # 48 in decimal
.word 0x12 # 18 in decimal

.text
main:
    li sp, 0x300          # initialize stack pointer

    # example: gcd(48, 18)
    la t0, A
    # la t0, 0x100
    # data segment starts at 0x100

    lw a0, 0(t0)
    lw a1, 4(t0)
    jal ra, gcd

    sw a0, 0(x0)

    # result in a0
    end: jal x0, end

# ---------------------------------------------------------
#   uint64_t gcd(uint64_t a, uint64_t b)
#   Inputs:  a0 = a, a1 = b
#   Returns: gcd(a, b) in a0
# ---------------------------------------------------------

gcd:
    addi sp, sp, -24       # allocate stack frame
    sd   ra, 16(sp)        # save return address
    sd   a0, 8(sp)         # save a
    sd   a1, 0(sp)         # save b

    # base case: if b == 0 return a
    beq a1, x0, base_case

    # recursive case: gcd(b, a % b)
    rem a0, a0, a1         # a0 = a mod b
    mv  a1, a0             # wrong order? No — fix below.
                           # Actually: need gcd(b, a % b)

    # correct setup:
    ld t0, 0(sp)           # t0 = b
    mv a1, a0              # a1 = a % b
    mv a0, t0              # a0 = b

    jal ra, gcd            # gcd(b, a % b)
    jal x0, done

base_case:
    ld a0, 8(sp)           # return a

done:
    ld   ra, 16(sp)        # restore return address
    addi sp, sp, 24        # destroy stack frame
    ret