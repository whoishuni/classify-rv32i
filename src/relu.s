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
    li t0, 1                # 設置 t0 = 1 作為驗證的閾值
    blt a1, t0, error       # 如果數組長度小於 1，跳轉到錯誤處理

    li t1, 0                # 設置 t1 = 0，作為與數組值比較的基準
    mv t2, a0               # 將數組起始地址存入 t2 進行遍歷

loop_start:
    beq a1, t0, exit        # 如果所有元素都處理完畢，跳轉到結束
    lw t3, 0(t2)            # 從地址 t2 加載當前元素至 t3
    blt t3, t1, set_zero    # 如果當前元素小於 0，跳轉到設置 0
    j next                  # 否則，跳轉到下一個元素

set_zero:
    sw t1, 0(t2)            # 將 0 存入當前地址（即將負值設為 0）

next:
    addi t2, t2, 4          # 將地址指向下一個元素
    addi t0, t0, 1          # 更新計數器
    j loop_start            # 迴圈回到 loop_start 繼續處理下一元素

error:
    li a0, 36               # 設置錯誤代碼 36
    j exit                  # 跳轉到結束

exit:
    ret                     # 返回

