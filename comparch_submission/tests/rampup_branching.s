.text
    .globl _start

_start:
    # --- Register Map ---
    # t0 = Main loop limit (total iterations)
    # t1 = Current Ramp Target (N). We want N Takens then N Not-Takens.
    # t2 = Counter for current phase (how many we have done so far)
    # t3 = Phase Flag (0 = Doing Takens, 1 = Doing Not-Takens)
    
    li      t0, 200        # Run for 2000 total iterations
    li      t1, 1           # Start with a ramp size of 1
    li      t2, 0           # Reset phase counter
    li      t3, 0           # Start in "Taken" phase (0)

main_loop:
    beqz    t0, end_program # Exit if total iterations done

    # --- The Branch Logic ---
    # We branch based on our phase flag (t3).
    # If t3 == 0, we WANT to branch (Taken).
    # If t3 == 1, we want to fall through (Not Taken).
    
    beqz    t3, do_taken    # If Phase is 0, jump to Taken path

do_not_taken:
    # Path A: Not Taken
    nop                     # Execute Not-Taken logic
    j       update_stats

do_taken:
    # Path B: Taken
    nop                     # Execute Taken logic
    # (Fall through to update logic)

update_stats:
    addi    t2, t2, 1       # Increment phase counter
    addi    t0, t0, -1      # Decrement total loop counter

    # --- Check if Phase is Complete ---
    # Have we done 'N' iterations of this type?
    bne     t2, t1, main_loop # If not done with this phase, repeat loop

    # --- Switch Phase ---
    # We finished N Takens (or N Not-Takens).
    li      t2, 0           # Reset phase counter
    xori    t3, t3, 1       # Toggle Phase: 0->1 or 1->0

    # --- Increase Ramp Size? ---
    # We only increase N after we have done BOTH a Taken phase and a Not-Taken phase.
    # We know we just finished a phase. If we are now back to Phase 0 (Taken),
    # it means we just finished Phase 1 (Not Taken), so we completed a full cycle.
    bnez    t3, main_loop   # If we just switched to Not-Taken, don't increase N yet.
    
    addi    t1, t1, 1       # Increase Ramp Target (1 -> 2 -> 3...)
    j       main_loop

end_program:
    jal x0, end_program
    #li a7, 10
    #ecall
