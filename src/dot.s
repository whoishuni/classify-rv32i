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
    # 檢查參數是否有效
    li t0, 1
    blt a2, t0, error_terminate  # 若元素數量小於1，跳轉到錯誤處理
    blt a3, t0, error_terminate  # 若第一數組的步長小於1，跳轉到錯誤處理
    blt a4, t0, error_terminate  # 若第二數組的步長小於1，跳轉到錯誤處理

    li t0, 0              # 初始化點積總和為0，存入 t0
    li t1, 0              # 設置迭代計數器 t1 為0

loop_start:
    bge t1, a2, loop_end  # 若已處理所有元素，跳轉到結束

    # 加載第一數組的元素 a0[t1 * a3]，並存入 t2
    mul t3, t1, a3        # t3 = t1 * stride0
    add t3, a0, t3        # t3 = address of arr0[t1 * stride0]
    lw t2, 0(t3)          # 將 arr0[t1 * stride0] 加載到 t2

    # 加載第二數組的元素 a1[t1 * a4]，並存入 t4
    mul t3, t1, a4        # t3 = t1 * stride1
    add t3, a1, t3        # t3 = address of arr1[t1 * stride1]
    lw t4, 0(t3)          # 將 arr1[t1 * stride1] 加載到 t4

    # 計算產品並累加到總和
    mul t5, t2, t4        # t5 = arr0[i * stride0] * arr1[i * stride1]
    add t0, t0, t5        # 將 t5 累加到總和 t0

    addi t1, t1, 1        # 迭代計數器加1
    j loop_start          # 回到循環開頭

loop_end:
    mv a0, t0             # 將計算結果存入 a0 作為返回值
    ret                   # 返回

error_terminate:
    blt a2, t0, set_error_36 # 若元素數量 < 1，設置錯誤代碼36
    li a0, 37                # 若步長無效，設置錯誤代碼37
    j exit                   # 跳轉到結束

set_error_36:
    li a0, 36                # 設置錯誤代碼36
    j exit                   # 跳轉到結束
