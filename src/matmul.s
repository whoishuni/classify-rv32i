.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication Implementation
#
# Performs operation: D = M0 × M1
# Where:
#   - M0 is a (rows0 × cols0) matrix
#   - M1 is a (rows1 × cols1) matrix
#   - D is a (rows0 × cols1) result matrix
#
# Arguments:
#   First Matrix (M0):
#     a0: Memory address of first element
#     a1: Row count
#     a2: Column count
#
#   Second Matrix (M1):
#     a3: Memory address of first element
#     a4: Row count
#     a5: Column count
#
#   Output Matrix (D):
#     a6: Memory address for result storage
#
# Validation:
#   Checks matrix dimensions and compatibility for multiplication.
#   Exits with code 38 on failure.
# =======================================================
matmul:
    # Validate matrix dimensions for multiplication
    li t0, 1
    blt a1, t0, error_dim            # Check if M0 rows > 0
    blt a2, t0, error_dim            # Check if M0 columns > 0
    blt a4, t0, error_dim            # Check if M1 rows > 0
    blt a5, t0, error_dim            # Check if M1 columns > 0
    bne a2, a4, error_dim            # Ensure M0 columns == M1 rows

    # Stack setup: save link register and temporary registers
    addi sp, sp, -36
    sw ra, 32(sp)
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)

    # Initialize base pointers and counters
    mv s7, a6            # Result matrix D pointer
    li s0, 0             # M0 row counter
    mv s1, a0            # Base pointer for M0 rows
    mv s2, a3            # Base pointer for M1 columns

outer_row_loop:
    li s3, 0             # Reset column counter for M1
    mv s4, a3            # Reset M1 base pointer for each new row in M0

    row_check:
    bge s0, a1, restore_and_exit    # Exit loop if all rows are processed

    column_process:
    bge s3, a5, next_row           # If all columns are processed, go to next row

    # Temporarily save arguments for dot product calculation
    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)

    # Prepare parameters for dot product function
    mv a0, s1            # Pass current row in M0
    mv a1, s4            # Pass current column in M1
    mv a2, a2            # Number of elements in row and column
    li a3, 1             # M0 row stride
    mv a4, a5            # M1 column stride

    jal dot              # Call dot product function
    mv t2, a0            # Store result from dot product in t2

    # Restore original state after dot product
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 24

    # Write result to D and advance pointer
    sw t2, 0(s7)
    addi s7, s7, 4       # Move to the next element in D

    addi s4, s4, 4       # Advance to next column in M1
    addi s3, s3, 1       # Increment M1 column counter
    j column_process

next_row:
    # Move to the next row in M0 and reset column pointer for M1
    li t1, 4
    mul t1, t1, a2       # Compute row offset for M0
    add s1, s1, t1       # Move M0 pointer to the next row
    addi s0, s0, 1       # Increment M0 row counter
    j outer_row_loop     # Restart row processing

restore_and_exit:
    # Restore registers and return
    lw ra, 32(sp)
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    addi sp, sp, 36
    ret

error_dim:
    li a0, 38           # Load error code for dimension mismatch
    j exit
