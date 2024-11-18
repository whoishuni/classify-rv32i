.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Write a matrix of integers to a binary file
# FILE FORMAT:
#   - The first 8 bytes store two 4-byte integers representing the number of 
#     rows and columns, respectively.
#   - Each subsequent 4-byte segment represents a matrix element, stored in 
#     row-major order.
#
# Arguments:
#   a0 (char *) - Pointer to a string representing the filename.
#   a1 (int *)  - Pointer to the matrix's starting location in memory.
#   a2 (int)    - Number of rows in the matrix.
#   a3 (int)    - Number of columns in the matrix.
#
# Returns:
#   None
#
# Exceptions:
#   - Terminates with error code 27 on `fopen` error or end-of-file (EOF).
#   - Terminates with error code 28 on `fclose` error or EOF.
#   - Terminates with error code 30 on `fwrite` error or EOF.
# ==============================================================================
write_matrix:
    # Prologue: Save registers on the stack
    addi sp, sp, -36
    sw ra, 32(sp)
    sw s0, 28(sp)
    sw s1, 24(sp)
    sw s2, 20(sp)
    sw s3, 16(sp)
    sw s4, 12(sp)
    sw s5, 8(sp)
    sw s6, 4(sp)
    sw s7, 0(sp)

    # Save arguments in callee-saved registers
    mv s1, a0        # s1 = filename pointer
    mv s2, a1        # s2 = matrix pointer
    mv s3, a2        # s3 = number of rows
    mv s4, a3        # s4 = number of columns

    # Open the file for writing
    mv a0, s1        # a0 = filename
    li a1, 1         # a1 = mode (1 for write)
    jal fopen        # Call fopen
    li t0, -1
    beq a0, t0, fopen_error
    mv s0, a0        # s0 = file descriptor

    # Prepare buffer with number of rows and columns
    addi sp, sp, -8
    sw s3, 0(sp)     # Store number of rows at sp[0]
    sw s4, 4(sp)     # Store number of columns at sp[4]

    # Write the number of rows and columns to the file
    mv a0, s0        # a0 = file descriptor
    addi a1, sp, 0   # a1 = address of buffer
    li a2, 2         # a2 = number of elements (rows and cols)
    li a3, 4         # a3 = size of each element (4 bytes)
    jal fwrite       # Call fwrite
    li t0, 2
    bne a0, t0, fwrite_error

    addi sp, sp, 8   # Clean up buffer from stack

    # Initialize row index
    li s5, 0         # s5 = row index (i)

write_rows_loop:
    blt s5, s3, write_row    # If i < num_rows, write the row
    j write_done             # Else, we're done

write_row:
    # Calculate byte offset for the current row without using 'mul'
    # Offset = i * num_columns * 4
    mv s6, s5                # s6 = current row index
    mv s7, x0                # s7 = byte offset accumulator

calculate_offset:
    beq s6, x0, offset_done
    add s7, s7, s4           # s7 += num_columns
    addi s6, s6, -1
    j calculate_offset

offset_done:
    slli s7, s7, 2           # Multiply by 4 to get byte offset

    # Calculate address of the current row
    add t1, s2, s7           # t1 = matrix base + byte offset

    # Write the current row to the file
    mv a0, s0                # a0 = file descriptor
    mv a1, t1                # a1 = address of row data
    mv a2, s4                # a2 = number of elements in the row
    li a3, 4                 # a3 = size of each element (4 bytes)
    jal fwrite               # Call fwrite
    bne a0, s4, fwrite_error # Check if all elements were written

    addi s5, s5, 1           # Increment row index
    j write_rows_loop        # Loop back to write the next row

write_done:
    # Close the file
    mv a0, s0                # a0 = file descriptor
    jal fclose               # Call fclose
    li t0, -1
    beq a0, t0, fclose_error

    # Epilogue: Restore registers from the stack
    lw s7, 0(sp)
    lw s6, 4(sp)
    lw s5, 8(sp)
    lw s4, 12(sp)
    lw s3, 16(sp)
    lw s2, 20(sp)
    lw s1, 24(sp)
    lw s0, 28(sp)
    lw ra, 32(sp)
    addi sp, sp, 36

    jr ra                   # Return from function

# Error handling labels
fopen_error:
    li a0, 27               # Error code 27 for fopen error
    j error_exit

fwrite_error:
    li a0, 30               # Error code 30 for fwrite error
    j error_exit

fclose_error:
    li a0, 28               # Error code 28 for fclose error
    j error_exit

error_exit:
    # Epilogue: Restore registers and exit with error code
    lw s7, 0(sp)
    lw s6, 4(sp)
    lw s5, 8(sp)
    lw s4, 12(sp)
    lw s3, 16(sp)
    lw s2, 20(sp)
    lw s1, 24(sp)
    lw s0, 28(sp)
    lw ra, 32(sp)
    addi sp, sp, 36
    j exit                  # Jump to exit (assumes exit handles a0 as exit code)
