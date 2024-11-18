.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================

relu:
    li t0, 1               # Load 1 into t0 for comparison
    blt a1, t0, error       # If a1 < 1, jump to error

    li t1, 0               # Load 0 into t1 for ReLU comparison
    li t2, 4               # Load 4 into t2, as each integer is 4 bytes

loop_start:
    beqz a1, end_relu      # If a1 is 0, we are done with the array

    lw t3, 0(a0)           # Load current array element into t3
    bge t3, t1, skip_relu  # If element >= 0, skip to the next element

    sw t1, 0(a0)           # Else, store 0 in current position

skip_relu:
    add a0, a0, t2         # Move to the next element (increment pointer by 4 bytes)
    addi a1, a1, -1        # Decrement element count
    j loop_start           # Repeat for the next element

error:
    li a0, 36              # Set exit code to 36 for invalid input
    j exit                 # Exit program

end_relu:
    jr ra                  # Return to caller
