# RISC-V Bubble Sort - Manual Memory Initialization
# Sorts an array of integers in ascending order

.text
.globl _start

_start:
    # Define array parameters
    addi sp, x0, 0x1ff
    li t0, 5                    # Array size = 5
    li t1, 0x10000000          # Base address for array storage
    
    # Manually store array values in memory
    # Array: [64, 25, 12, 22, 11]
    li t2, 64
    sw t2, 0(t1)               # array[0] = 64
    
    li t2, 25
    sw t2, 4(t1)               # array[1] = 25
    
    li t2, 12
    sw t2, 8(t1)               # array[2] = 12
    
    li t2, 22
    sw t2, 12(t1)              # array[3] = 22
    
    li t2, 11
    sw t2, 16(t1)              # array[4] = 11
    
    # Initialize bubble sort
    mv a0, t1                  # a0 = base address of array
    mv a1, t0                  # a1 = size of array
    
    # Call bubble sort
    jal ra, bubble_sort
    
    # Exit program (for simulation/testing)
    li t1, 0x10000000
    lw t2, 0(t1)               # array[0] = 64
    lw t3, 4(t1)               # array[1] = 25
    lw t4, 8(t1)               # array[2] = 12
    lw t5, 12(t1)              # array[3] = 22
    lw t6, 16(t1)              # array[4] = 11
    #end: jal x0, end
    li a7, 10 
    ecall

# Bubble Sort Function
# Arguments:
#   a0 = base address of array
#   a1 = size of array
# Uses registers: t0-t6, s1-s2
bubble_sort:
    addi sp, sp, -20           # Allocate stack space
    sw ra, 16(sp)              # Save return address
    sw s1, 12(sp)              # Save s1
    sw s2, 8(sp)               # Save s2
    sw s3, 4(sp)               # Save s3
    sw s4, 0(sp)               # Save s4
    
    li s1, 0                   # s1 = outer loop counter (sorted elements)
    addi s2, a1, -1            # s2 = size - 1 (max outer loop count)
    
outer_loop:
    bge s1, s2, done           # if s1 >= size-1, exit
    
    li s3, 0                   # s3 = swapped flag (0 = false)
    li t0, 0                   # t0 = inner loop index
    sub t1, s2, s1             # t1 = (size-1) - sorted_count
    
inner_loop:
    bge t0, t1, check_swapped  # if index >= remaining elements, exit inner
    
    # Calculate addresses
    slli t2, t0, 2             # t2 = index * 4 (byte offset)
    add t3, a0, t2             # t3 = address of array[i]
    
    # Load array[i] and array[i+1]
    lw t4, 0(t3)               # t4 = array[i]
    lw t5, 4(t3)               # t5 = array[i+1]
    
    # Compare and swap if needed
    ble t4, t5, no_swap        # if array[i] <= array[i+1], skip swap
    
    # Swap elements
    sw t5, 0(t3)               # array[i] = array[i+1]
    sw t4, 4(t3)               # array[i+1] = array[i]
    li s3, 1                   # set swapped flag = true
    
no_swap:
    addi t0, t0, 1             # index++
    j inner_loop
    
check_swapped:
    beqz s3, done              # if no swap occurred, array is sorted
    addi s1, s1, 1             # sorted_count++
    j outer_loop
    
done:
    # Restore saved registers
    lw s4, 0(sp)
    lw s3, 4(sp)
    lw s2, 8(sp)
    lw s1, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20            # Deallocate stack space
    ret
