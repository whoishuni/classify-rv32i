.globl classify

.text
# =====================================
# NEURAL NETWORK CLASSIFIER
# =====================================
# Description:
#   Command line program for matrix-based classification
#
# Command Line Arguments:
#   1. M0_PATH      - First matrix file location
#   2. M1_PATH      - Second matrix file location
#   3. INPUT_PATH   - Input matrix file location
#   4. OUTPUT_PATH  - Output file destination
#
# Register Usage:
#   a0 (int)        - Input: Argument count
#                   - Output: Classification result
#   a1 (char **)    - Input: Argument vector
#   a2 (int)        - Input: Silent mode flag
#                     (0 = verbose, 1 = silent)
#
# Error Codes:
#   31 - Invalid argument count
#   26 - Memory allocation failure
#
# Usage Example:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
# =====================================
classify:
    # Error handling
    li t0, 5
    blt a0, t0, error_args

    # Prologue
    addi sp, sp, -48

    sw ra, 0(sp)

    sw s0, 4(sp) # m0 matrix
    sw s1, 8(sp) # m1 matrix
    sw s2, 12(sp) # input matrix

    sw s3, 16(sp) # m0 matrix rows
    sw s4, 20(sp) # m0 matrix cols

    sw s5, 24(sp) # m1 matrix rows
    sw s6, 28(sp) # m1 matrix cols

    sw s7, 32(sp) # input matrix rows
    sw s8, 36(sp) # input matrix cols
    sw s9, 40(sp) # h
    sw s10, 44(sp) # o

    # Read pretrained m0

    addi sp, sp, -12

    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s3, a0 # save m0 rows pointer for later

    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s4, a0 # save m0 cols pointer for later

    lw a1, 4(sp) # restores the argument pointer

    lw a0, 4(a1) # set argument 1 for the read_matrix function
    mv a1, s3 # set argument 2 for the read_matrix function
    mv a2, s4 # set argument 3 for the read_matrix function

    jal read_matrix

    mv s0, a0 # setting s0 to the m0, aka the return value of read_matrix

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)

    addi sp, sp, 12
    # Read pretrained m1

    addi sp, sp, -12

    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s5, a0 # save m1 rows pointer for later

    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s6, a0 # save m1 cols pointer for later

    lw a1, 4(sp) # restores the argument pointer

    lw a0, 8(a1) # set argument 1 for the read_matrix function
    mv a1, s5 # set argument 2 for the read_matrix function
    mv a2, s6 # set argument 3 for the read_matrix function

    jal read_matrix

    mv s1, a0 # setting s1 to the m1, aka the return value of read_matrix

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)

    addi sp, sp, 12

    # Read input matrix

    addi sp, sp, -12

    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s7, a0 # save input rows pointer for later

    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s8, a0 # save input cols pointer for later

    lw a1, 4(sp) # restores the argument pointer

    lw a0, 12(a1) # set argument 1 for the read_matrix function
    mv a1, s7 # set argument 2 for the read_matrix function
    mv a2, s8 # set argument 3 for the read_matrix function

    jal read_matrix

    mv s2, a0 # setting s2 to the input matrix, aka the return value of read_matrix

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)

    addi sp, sp, 12

    # Compute h = matmul(m0, input)
    addi sp, sp, -28

    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)

    lw t0, 0(s3)       # m0 rows
    lw t1, 0(s8)       # input cols

    # 呼叫 multiply 函數計算 t0 * t1
    mv a0, t0          # multiplicand
    mv a1, t1          # multiplier
    jal multiply        # a0 = t0 * t1

    slli a0, a0, 2     # a0 = a0 * 4 (size in bytes)
    jal malloc
    beq a0, x0, error_malloc
    mv s9, a0          # h

    mv a6, a0          # h

    mv a0, s0          # m0 array
    lw a1, 0(s3)       # m0 rows
    lw a2, 0(s4)       # m0 cols

    mv a3, s2          # input array
    lw a4, 0(s7)       # input rows
    lw a5, 0(s8)       # input cols

    jal matmul

    # 恢復暫存器和堆疊
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)

    addi sp, sp, 28

    # Compute h = relu(h)
    addi sp, sp, -8

    sw a0, 0(sp)
    sw a1, 4(sp)

    # 呼叫 multiply 函數計算 t0 * t1 (h array length)
    lw t0, 0(s3)       # m0 rows
    lw t1, 0(s8)       # input cols

    mv a0, t0          # multiplicand
    mv a1, t1          # multiplier
    jal multiply        # a0 = t0 * t1

    mv t2, a0          # store length in t2

    mv a0, s9          # set a0 to h array pointer
    mv a1, t2          # set a1 to h array length
    jal relu

    lw a0, 0(sp)
    lw a1, 4(sp)

    addi sp, sp, 8

    # Compute o = matmul(m1, h)
    addi sp, sp, -28

    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)

    lw t0, 0(s3)       # m0 rows
    lw t1, 0(s6)       # m1 cols

    # 呼叫 multiply 函數計算 t0 * t1
    mv a0, t0          # multiplicand
    mv a1, t1          # multiplier
    jal multiply        # a0 = t0 * t1

    slli a0, a0, 2     # a0 = a0 * 4 (size in bytes)
    jal malloc
    beq a0, x0, error_malloc
    mv s10, a0         # o

    mv a6, a0          # o

    mv a0, s1          # m1 array
    lw a1, 0(s5)       # m1 rows
    lw a2, 0(s6)       # m1 cols

    mv a3, s9          # h array
    lw a4, 0(s3)       # h rows
    lw a5, 0(s8)       # h cols

    jal matmul

    # 恢復暫存器和堆疊
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)

    addi sp, sp, 28

    # Write output matrix o
    addi sp, sp, -16

    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)

    lw a0, 16(a1) # load filename string into first arg
    mv a1, s10    # load array into second arg
    lw a2, 0(s5)   # load number of rows into fourth arg
    lw a3, 0(s8)   # load number of cols into third arg

    jal write_matrix

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)

    addi sp, sp, 16

    # Compute and return argmax(o)
    addi sp, sp, -12

    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    mv a0, s10 # load o array into first arg
    lw t0, 0(s3) # m0 rows
    lw t1, 0(s6) # m1 cols

    # 呼叫 multiply 函數計算 t0 * t1 (o array length)
    mv a0, t0          # multiplicand
    mv a1, t1          # multiplier
    jal multiply        # a0 = t0 * t1

    mv t2, a0          # store length in t2

    mv a0, s10         # set a0 to o array pointer
    mv a1, t2          # set a1 to o array length
    jal argmax

    mv t0, a0 # move return value of argmax into t0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)

    addi sp, sp, 12

    mv a0, t0

    # If enabled, print argmax(o) and newline
    bne a2, x0, epilogue

    addi sp, sp, -4
    sw a0, 0(sp)

    jal print_int
    li a0, '\n'
    jal print_char

    lw a0, 0(sp)
    addi sp, sp, 4

    # Epilogue
epilogue:
    addi sp, sp, -4
    sw a0, 0(sp)

    mv a0, s0
    jal free

    mv a0, s1
    jal free

    mv a0, s2
    jal free

    mv a0, s3
    jal free

    mv a0, s4
    jal free

    mv a0, s5
    jal free

    mv a0, s6
    jal free

    mv a0, s7
    jal free

    mv a0, s8
    jal free

    mv a0, s9
    jal free

    mv a0, s10
    jal free

    lw a0, 0(sp)
    addi sp, sp, 4

    lw ra, 0(sp)

    lw s0, 4(sp) # m0 matrix
    lw s1, 8(sp) # m1 matrix
    lw s2, 12(sp) # input matrix

    lw s3, 16(sp)
    lw s4, 20(sp)

    lw s5, 24(sp)
    lw s6, 28(sp)

    lw s7, 32(sp)
    lw s8, 36(sp)

    lw s9, 40(sp) # h
    lw s10, 44(sp) # o

    addi sp, sp, 48

    jr ra

error_args:
    li a0, 31
    j exit

error_malloc:
    li a0, 26
    j exit

# 定義 multiply 函數
multiply:
    # 保存暫存器
    addi    sp, sp, -16
    sw      ra, 12(sp)
    sw      t0, 8(sp)
    sw      t1, 4(sp)
    sw      t2, 0(sp)

    # 初始化
    li      t0, 0          # result = 0
    li      t1, 1          # mask = 1

multiply_loop:
    and     t2, a1, t1     # t2 = a1 & t1
    beqz    t2, skip_add    # 如果當前位為 0，跳過加法
    add     t0, t0, a0     # result += a0

skip_add:
    slli    a0, a0, 1      # a0 <<= 1
    slli    t1, t1, 1      # t1 <<= 1
    bnez    t1, multiply_loop  # 如果 t1 != 0，繼續迴圈

    mv      a0, t0         # 返回結果

    # 恢復暫存器
    lw      ra, 12(sp)
    lw      t0, 8(sp)
    lw      t1, 4(sp)
    lw      t2, 0(sp)
    addi    sp, sp, 16
    jr      ra             # 返回
