li x1, 0x100        # base address in data memory
li x2, 0xAABBCCDD   # test pattern

    ###################################
    # --- Store Tests ---
    ###################################
    sw  x2, 0(x1)        # store word: [0x100] = 0xAABBCCDD
    sh  x2, 4(x1)        # store halfword (lower 16 bits = 0xCCDD)
    sb  x2, 6(x1)        # store byte (lowest 8 bits = 0xDD)

    ###################################
    # --- Load Tests ---
    ###################################
    lw  x3, 0(x1)        # full word load -> 0xAABBCCDD
    lh  x4, 4(x1)        # signed halfword -> 0xFFFFCCDD (since 0xCCDD has MSB=1)
    lhu x5, 4(x1)        # unsigned halfword -> 0x0000CCDD
    lb  x6, 6(x1)        # signed byte -> 0xFFFFFFDD
    lbu x7, 6(x1)        # unsigned byte -> 0x000000DD

    ###################################
    # --- Check Data Combos ---
    ###################################
    add x8, x3, x5       # combine loaded word + halfword
    add x9, x6, x7       # signed vs unsigned byte mix
