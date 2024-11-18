.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    # Check if element count < 1 (error code 36)
    li t0, 1
    blt a2, t0, error_36

    # Check if stride0 or stride1 < 1 (error code 37)
    blt a3, t0, error_37
    blt a4, t0, error_37

    # Initialize result accumulator to 0
    li t0, 0              # t0 will hold the result (dot product sum)
    li t1, 0              # t1 will be our loop counter

loop_start:
    # Check if we've reached the end of the element count
    bge t1, a2, loop_end

    # Calculate arr0[i * stride0] by loading element with offset
    mul t2, t1, a3        # t2 = i * stride0
    slli t2, t2, 2        # Multiply by 4 to get byte offset (word size)
    add t3, a0, t2        # Adjust arr0 address by stride offset
    lw t4, 0(t3)          # Load arr0[i * stride0] into t4

    # Calculate arr1[i * stride1] by loading element with offset
    mul t5, t1, a4        # t5 = i * stride1
    slli t5, t5, 2        # Multiply by 4 to get byte offset
    add t6, a1, t5        # Adjust arr1 address by stride offset
    lw t3, 0(t6)          # Load arr1[i * stride1] into t3

    # Multiply arr0[i * stride0] * arr1[i * stride1] and add to result
    mul t4, t4, t3        # t4 = arr0[i * stride0] * arr1[i * stride1]
    add t0, t0, t4        # Accumulate product in t0

    # Increment loop counter
    addi t1, t1, 1        # Increment index counter
    j loop_start          # Repeat loop

loop_end:
    mv a0, t0             # Store the result in a0
    jr ra                 # Return to caller

# Error handling
error_36:
    li a0, 36             # Set error code 36 for invalid length
    j exit                # Exit program

error_37:
    li a0, 37             # Set error code 37 for invalid stride
    j exit                # Exit program
