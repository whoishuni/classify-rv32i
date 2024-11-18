.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================

argmax:
    li t6, 1                   # Load 1 into t6 for comparison
    blt a1, t6, handle_error   # If a1 < 1, jump to handle_error

    lw t0, 0(a0)               # Load the first element of the array into t0 (max value)
    li t1, 0                   # Initialize index for max value (result index)
    addi t2, a0, 4             # Start pointer at the second element
    li t3, 1                   # Start index at 1 for the loop

loop_start:
    beq t3, a1, end_argmax     # If we have reached the end, jump to end_argmax

    lw t4, 0(t2)               # Load the current element into t4
    blt t4, t0, skip_update    # If current element < max, skip update

    # Update max if current element > t0
    bgt t4, t0, update_max

skip_update:
    addi t2, t2, 4             # Move to the next element (increment pointer by 4 bytes)
    addi t3, t3, 1             # Increment the index
    j loop_start               # Repeat for the next element

update_max:
    mv t0, t4                  # Update max value with the current element
    mv t1, t3                  # Update max index with the current index
    j skip_update              # Continue loop

handle_error:
    li a0, 36                  # Set exit code to 36 for invalid input
    j exit                     # Exit program

end_argmax:
    mv a0, t1                  # Move result index to a0
    jr ra                      # Return to caller
