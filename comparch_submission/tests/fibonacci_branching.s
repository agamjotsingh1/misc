.text
    .globl _start

_start:
    # --- Register Map ---
    # t0 = current loop index (i)
    # t1 = max loop count
    # t2 = fib_current (F_n)
    # t3 = fib_next (F_n+1)
    # t4 = temp for swap
    
    li      t0, 1           # i = 1
    li      t1, 100        # Run for 1000 iterations
    li      x30, 0
    
    # Initialize Fibonacci state: 1, 2
    li      t2, 1           # fib_current starts at 1
    li      t3, 2           # fib_next starts at 2

loop_start:
    bge     t0, t1, end_program  # if i >= 1000, exit

    # --- The Fibonacci Check ---
    # We check if the current index 'i' (t0) matches the current fib number (t2)
    # This branch is the one we are testing.
    beq     t0, t2, is_fibonacci
    
not_fibonacci:
    # Path A: The number is NOT a fibonacci number.
    # As 'i' gets larger, we will stay in this path more and more often.
    nop
    j       loop_continue

is_fibonacci:
    # Path B: The number IS a fibonacci number.
    # We found a match, so we need to advance our fibonacci state to the next number.
    # Logic: next_fib = current + next; current = next
    add     t4, t2, t3      # t4 = fib_current + fib_next
    mv      t2, t3          # fib_current = fib_next
    mv      t3, t4          # fib_next = new calculated value
    
    # (Optional) Add a nop or dummy instruction here if you want to see the branch target clearly
    addi x30, x30, 1

loop_continue:
    addi    t0, t0, 1       # Increment loop index i
    j       loop_start

end_program:
    jal x0, end_program
    #li a7, 10
    #ecall
