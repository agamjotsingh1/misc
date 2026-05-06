.text
    .globl _start

_start:
    # --- Register Map ---
    # t0 = Current value 'n'
    # t1 = Step counter (just for stats)
    # t2 = Constant 1 (Stop condition)
    # t3 = Temporary for calculations
    
    li      t0, 27          # Start with 27 (Long path: 111 steps)
    li      t1, 0           # Steps = 0
    li      t2, 1           # Stop value

collatz_loop:
    # --- Branch 1: Check for Termination ---
    # Predictable: Taken only once at the very end.
    beq     t0, t2, end_program

    # Increment step counter
    addi    t1, t1, 1

    # --- Branch 2: The "Chaos" Branch (Even vs Odd) ---
    # check if (n % 2 == 0)
    andi    t3, t0, 1       # Get LSB. If 0, it's even.
    
    # This branch direction depends on the chaotic math properties of 3n+1
    beqz    t3, is_even     

is_odd:
    # Formula: n = 3n + 1
    # Optimized RISC-V multiplication by 3: (n << 1) + n
    slli    t3, t0, 1       # t3 = 2*n
    add     t0, t3, t0      # t0 = 2*n + n = 3n
    addi    t0, t0, 1       # t0 = 3n + 1
    
    # Jump back to start
    j       collatz_loop

is_even:
    # Formula: n = n / 2
    srli    t0, t0, 1       # Logical Shift Right by 1 (divide by 2)
    
    # Jump back to start
    j       collatz_loop

end_program:
    # Result: t1 contains the number of steps (should be 111 for n=27)
    jal x0, end_program
    #li a7, 10
    #ecall
