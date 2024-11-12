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
#   - Terminates with error code 53 on `fopen` error
#   - Terminates with error code 54 on `fwrite` error
#   - Terminates with error code 55 on `fclose` error
# ==============================================================================

write_matrix:
    # Prologue: 保存寄存器狀態
    addi sp, sp, -44
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    # 保存參數到暫存寄存器
    mv s1, a1        # s1 = 矩陣起始地址
    mv s2, a2        # s2 = 矩陣行數
    mv s3, a3        # s3 = 矩陣列數

    # 打開文件
    li a1, 1         # "write" 模式
    jal fopen

    # 檢查文件是否打開成功
    li t0, -1
    beq a0, t0, fopen_error   # 如果 fopen 失敗，跳轉到錯誤處理

    mv s0, a0        # 保存文件指針

    # 將行數和列數寫入文件
    sw s2, 24(sp)    # 將行數存入緩衝區
    sw s3, 28(sp)    # 將列數存入緩衝區

    mv a0, s0        # 文件指針
    addi a1, sp, 24  # 緩衝區地址（包含行數和列數）
    li a2, 2         # 要寫入的元素數量（行數和列數）
    li a3, 4         # 每個元素的大小（4字節）

    jal fwrite

    # 檢查 fwrite 是否成功
    li t0, 2
    bne a0, t0, fwrite_error  # 若 fwrite 失敗，跳轉到錯誤處理

    # 計算矩陣的總元素數量
    mul s4, s2, s3            # s4 = 總元素數量

    # 將矩陣數據寫入文件
    mv a0, s0        # 文件指針
    mv a1, s1        # 矩陣數據的起始地址
    mv a2, s4        # 要寫入的元素數量
    li a3, 4         # 每個元素的大小（4字節）

    jal fwrite

    # 檢查 fwrite 是否成功
    bne a0, s4, fwrite_error  # 若 fwrite 失敗，跳轉到錯誤處理

    # 關閉文件
    mv a0, s0
    jal fclose

    # 檢查文件關閉是否成功
    li t0, -1
    beq a0, t0, fclose_error  # 若 fclose 失敗，跳轉到錯誤處理

    # Epilogue: 恢復寄存器狀態
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44

    jr ra

# 錯誤處理
fopen_error:
    li a0, 53        # fopen 錯誤碼
    j error_exit

fwrite_error:
    li a0, 54        # fwrite 錯誤碼
    j error_exit

fclose_error:
    li a0, 55        # fclose 錯誤碼
    j error_exit

error_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44
    j exit
