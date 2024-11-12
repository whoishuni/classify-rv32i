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
    li t6, 1                 # t6 = 1, 用於檢查數組長度
    blt a1, t6, handle_error # 若數組長度小於1，跳轉到錯誤處理

    lw t0, 0(a0)             # 將第一個元素載入 t0 作為初始最大值
    li t1, 0                 # 初始化最大值的索引為 0
    li t2, 1                 # 設置 t2 為 1，用於循環中的元素索引

loop_start:
    beq t2, a1, exit         # 若已處理完所有元素，跳轉到結束

    lw t3, 0(a0)             # 將當前元素載入 t3
    addi a0, a0, 4           # 移動指針至下一元素
    bgt t3, t0, update_max   # 若 t3 > t0，跳轉到更新最大值

    j next_element           # 否則，進入下一個元素

update_max:
    mv t0, t3                # 更新最大值為 t3
    mv t1, t2                # 更新最大值的索引為當前索引 t2

next_element:
    addi t2, t2, 1           # 索引加1
    j loop_start             # 回到循環開頭

handle_error:
    li a0, 36                # 設置錯誤代碼 36
    j exit                   # 跳轉到結束

exit:
    mv a0, t1                # 返回最大值的索引
    ret                      # 返回
