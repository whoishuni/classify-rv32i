.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Binary Matrix File Reader
#
# Loads matrix data from a binary file into dynamically allocated memory.
# Matrix dimensions are read from file header and stored at provided addresses.
#
# Binary File Format:
#   Header (8 bytes):
#     - Bytes 0-3: Number of rows (int32)
#     - Bytes 4-7: Number of columns (int32)
#   Data:
#     - Subsequent 4-byte blocks: Matrix elements
#     - Stored in row-major order: [row0|row1|row2|...]
#
# Arguments:
#   Input:
#     a0: Pointer to filename string
#     a1: Address to write row count
#     a2: Address to write column count
#
#   Output:
#     a0: Base address of loaded matrix
#
# Error Handling:
#   Program terminates with:
#   - Code 26: Dynamic memory allocation failed
#   - Code 27: File access error (open/EOF)
#   - Code 28: File closure error
#   - Code 29: Data read error
#
# Memory Note:
#   Caller is responsible for freeing returned matrix pointer
# ==============================================================================

read_matrix:

    # Function Prologue
    addi   sp, sp, -48            # Allocate stack frame
    sw     ra, 44(sp)             # Save return address
    sw     s0, 40(sp)             # Save s0-s4 registers
    sw     s1, 36(sp)
    sw     s2, 32(sp)
    sw     s3, 28(sp)
    sw     s4, 24(sp)

    mv     s3, a1                 # Save address to store row count
    mv     s4, a2                 # Save address to store column count

    # Open the binary file
    li     a1, 0                  # Mode 0 for reading
    jal    fopen                  # Open file

    li     t0, -1
    beq    a0, t0, fopen_error    # Check for fopen error

    mv     s0, a0                 # Save file pointer

    # Read the header (rows and columns)
    mv     a0, s0                 # File pointer
    addi   a1, sp, 0              # Buffer on stack
    li     a2, 8                  # Number of bytes to read
    jal    fread                  # Read header

    li     t0, 8
    bne    a0, t0, fread_error    # Check if 8 bytes were read

    lw     t1, 0(sp)              # Load number of rows
    lw     t2, 4(sp)              # Load number of columns

    sw     t1, 0(s3)              # Store rows at provided address
    sw     t2, 0(s4)              # Store columns at provided address

    # Calculate total number of elements (rows * columns)
    # Optimized multiplication using Russian Peasant Multiplication
    li     s1, 0                  # Initialize product to 0
    mv     t3, t1                 # t3 = multiplicand (rows)
    mv     t4, t2                 # t4 = multiplier (columns)

multiply_loop:
    beqz   t4, multiply_done      # Exit loop when multiplier is 0
    andi   t5, t4, 1              # Check if LSB of multiplier is 1
    beqz   t5, skip_add           # If LSB is 0, skip addition
    add    s1, s1, t3             # Add multiplicand to product
skip_add:
    slli   t3, t3, 1              # Double the multiplicand
    srli   t4, t4, 1              # Halve the multiplier
    j      multiply_loop
multiply_done:

    # Calculate size in bytes (elements * 4)
    slli   s1, s1, 2              # Multiply total elements by 4, store back in s1

    # Allocate memory for the matrix
    mv     a0, s1                 # Size in bytes
    jal    malloc                 # Allocate memory

    beq    a0, x0, malloc_error   # Check for malloc error

    mv     s2, a0                 # Save matrix pointer

    # Read matrix data into allocated memory
    mv     a0, s0                 # File pointer
    mv     a1, s2                 # Destination buffer
    mv     a2, s1                 # Number of bytes to read
    jal    fread                  # Read data

    bne    a0, s1, fread_error    # Check if all data was read

    # Close the file
    mv     a0, s0                 # File pointer
    jal    fclose                 # Close file

    li     t0, -1
    beq    a0, t0, fclose_error   # Check for fclose error

    mv     a0, s2                 # Return matrix pointer

    # Function Epilogue
    lw     ra, 44(sp)             # Restore saved registers
    lw     s0, 40(sp)
    lw     s1, 36(sp)
    lw     s2, 32(sp)
    lw     s3, 28(sp)
    lw     s4, 24(sp)
    addi   sp, sp, 48             # Deallocate stack frame
    jr     ra                     # Return to caller

# Error Handling Labels
malloc_error:
    li     a0, 26                 # Error code for malloc failure
    j      error_exit

fopen_error:
    li     a0, 27                 # Error code for fopen failure
    j      error_exit

fread_error:
    li     a0, 29                 # Error code for fread failure
    j      error_exit

fclose_error:
    li     a0, 28                 # Error code for fclose failure
    j      error_exit

error_exit:
    lw     ra, 44(sp)             # Restore saved registers
    lw     s0, 40(sp)
    lw     s1, 36(sp)
    lw     s2, 32(sp)
    lw     s3, 28(sp)
    lw     s4, 24(sp)
    addi   sp, sp, 48             # Deallocate stack frame
    j      exit                   # Terminate program
