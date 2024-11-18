.globl abs

.text
# =================================================================
# FUNCTION: Absolute Value Converter
#
# Transforms any integer into its absolute (non-negative) value by
# modifying the original value through pointer dereferencing.
# For example: -5 becomes 5, while 3 remains 3.
#
# Args:
#   a0 (int *): Memory address of the integer to be converted
#
# Returns:
#   None - The operation modifies the value at the pointer address
# =================================================================
abs:
    # Prologue - Load the value from memory
    lw      t1, 0(a0)           # Load the value pointed to by a0 into t1

    # Perform absolute value calculation
    bgez    t1, finish_abs      # If t1 >= 0, skip negation
    sub     t1, x0, t1          # Compute absolute value: t1 = 0 - t1

finish_abs:
    # Store the absolute value back to memory
    sw      t1, 0(a0)           # Store the result back at the address in a0
    ret                         # Return to the caller
