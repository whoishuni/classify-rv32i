# Assignment 2: Classify

---
## [Visit the HackMD Document](https://hackmd.io/@whoishuni/rkDN16ufJe)

---
1. [Introduction](#introduction)
2. [Task 1: ReLU Activation Function](#task-1-relu-activation-function)
   - [Overview](#overview)
   - [Implementation Details](#implementation-details)
   - [Summary](#summary)
3. [Task 2: ArgMax Function](#task-2-argmax-function)
   - [Overview](#overview-1)
   - [Implementation Details](#implementation-details-1)
   - [Summary](#summary-1)
4. [Task 3: Dot Product and Matrix Multiplication](#task-3-dot-product-and-matrix-multiplication)
   - [Dot Product Function](#dot-product-function)
     - [Overview](#overview-2)
     - [Implementation Details](#implementation-details-2)
     - [Summary](#summary-2)
   - [Matrix Multiplication](#matrix-multiplication)
     - [Overview](#overview-3)
     - [Implementation Details](#implementation-details-3)
     - [Summary](#summary-3)
5. [Task 4: File Operations](#task-4-file-operations)
   - [Read Matrix](#read-matrix)
     - [Overview](#overview-4)
     - [Implementation Details](#implementation-details-4)
     - [Summary](#summary-4)
   - [Write Matrix](#write-matrix)
     - [Overview](#overview-5)
     - [Implementation Details](#implementation-details-5)
     - [Summary](#summary-5)
6. [Task 5: Classification](#task-5-classification)
   - [Overview](#overview-6)
   - [Steps](#steps)
   - [Code Breakdown](#code-breakdown-6)
   - [Summary](#summary-6)
7. [Overall System Integration](#overall-system-integration)
   - [Architectural Considerations](#architectural-considerations)
   - [Performance Optimization](#performance-optimization)
   - [Scalability and Extensibility](#scalability-and-extensibility)
   - [Robustness and Error Handling](#robustness-and-error-handling)
8. [Conclusions](#conclusions)
9. [Results](#results)

---


## Introduction

The implementation of neural network components in RISC-V assembly presents a unique intersection of low-level programming and high-level machine learning concepts. This document provides an in-depth analysis of several fundamental functions—ReLU activation, ArgMax, Dot Product, Matrix Multiplication, and file operations—crafted in RISC-V assembly. Emphasizing both functional correctness and performance optimization, this analysis delves into the architectural nuances, algorithmic efficiency, and potential areas for enhancement, offering insights befitting an advanced scholarly discourse.

---


## Task 1: ReLU Activation Function

### Overview

The Rectified Linear Unit (ReLU) activation function is pivotal in introducing non-linearity into neural networks, facilitating complex pattern recognition. The `relu` function implemented in RISC-V assembly operates directly on a flattened 1D integer array, transforming it in-place by setting all negative values to zero while preserving non-negative values. This approach leverages the efficiency of in-place modifications to minimize memory overhead, a critical consideration in resource-constrained environments.



### Implementation Details

#### 1️⃣ Input Validation

```assembly
li t0, 1               # Load 1 into t0 for comparison
blt a1, t0, error      # If a1 < 1, jump to error
```

**Purpose**: Ensures the function operates on a valid, non-empty array.  
**Mechanism**: Compares the number of elements (a1) against the minimum valid count (1). If the array is empty, it triggers an error handling routine.

#### 2️⃣ Initialization

```assembly
li t1, 0               # Load immediate value 0 into register t1 for comparison
li t2, 4               # Load immediate value 4 into register t2 (size of integer in bytes)
```

**Registers Used**:  
- `t1`: Represents the value 0 for the ReLU comparison.  
- `t2`: Denotes the byte size of each integer element (4 bytes), facilitating pointer arithmetic.

#### 3️⃣ ReLU Loop

```assembly
loop_start:
    beqz a1, end_relu      # If a1 is 0, exit the loop

    lw t3, 0(a0)           # Load current array element into t3
    bge t3, t1, skip_relu  # If element >= 0, skip to the next element

    sw t1, 0(a0)           # Else, store 0 in current position

skip_relu:
    add a0, a0, t2         # Move to the next element (increment pointer by 4 bytes)
    addi a1, a1, -1        # Decrement element count
    j loop_start           # Repeat for the next element
```

**Loop Mechanics**:  
- **Termination**: The loop continues until all elements (`a1`) are processed.  
- **Element Processing**:  
  - **Load**: Retrieves the current array element into `t3`.  
  - **Compare**: Checks if the element is non-negative.  
  - **Modify**: If negative, sets the element to 0 via the `sw` instruction.  
  - **Pointer Arithmetic**: Advances the pointer to the next array element by adding 4 bytes (`t2`) to `a0`.  
  - **Counter Decrement**: Reduces the element count (`a1`) by 1 to track progress.

#### 4️⃣ Error Handling

```assembly
error:
    li a0, 36              # Set exit code to 36 for invalid input
    j exit                 # Exit program
```

**Functionality**: Safeguards against invalid input by terminating the program with a specific error code (36) if the array length is insufficient.

#### 5️⃣ Function Exit

```assembly
end_relu:
    jr ra                  # Return to caller
```

**Purpose**: Concludes the function execution by returning control to the calling context.



### Summary

The `relu` function adeptly implements the ReLU activation in RISC-V assembly, emphasizing in-place modifications to optimize memory usage. Through meticulous input validation and efficient loop constructs, it ensures both correctness and performance. However, the potential for further optimization exists, particularly in leveraging parallel processing capabilities and refining control flow mechanisms. Such enhancements could significantly amplify the function's efficiency, rendering it even more suited for high-performance neural network applications.



# Task 2: ArgMax

## Overview

The `argmax` function identifies the index of the largest element in a given integer array. In scenarios where multiple elements share the maximum value, the function returns the smallest index among them. This operation is essential in various applications, including machine learning algorithms and optimization problems, where determining the position of the maximum value is required.

### Argmax Function Definition

$$
\text{argmax}(A) = \underset{i \in \{0, 1, \dots, n-1\}}{\text{argmax}} \, A[i]
$$


Given a 1D vector \( A \) of length \( n \), the function scans through each element to find the index \( i \) where \( A[i] \) is maximized. If multiple indices have the same maximum value, the smallest index \( i \) is returned.



### Arguments
- **a0 (int \*)**: Pointer to the first element of the integer array.
- **a1 (int)**: Number of elements in the array.

### Returns
- **a0 (int)**: The 0-based index of the first occurrence of the maximum element in the array.

### Validation
- **Input Requirement**: The array must contain at least one element.
- **Error Handling**: If the array length is less than 1 (`a1 < 1`), the function terminates the program with exit code `36`.

### Example
#### Input
```plaintext
Array: [3, 1, 4, 4, 2]
```

#### Output
```plaintext
Index: 2
```

#### Explanation
The maximum value is `4`, which first occurs at index `2`.

---

## Implementation Details

### Initialization
```assembly
li t6, 1                   # Load immediate value 1 into register t6
blt a1, t6, handle_error   # Branch to handle_error if a1 (array length) < 1

lw t0, 0(a0)               # Load the first element of the array into t0 (current max value)
li t1, 0                   # Initialize t1 to 0 (index of current max)
addi t2, a0, 4             # Initialize t2 to point to the second element of the array
li t3, 1                   # Initialize t3 to 1 (current index)
```

- **Registers Used**:
  - **t6**: Holds the value `1` for comparison to ensure the array is non-empty.
  - **t0**: Stores the current maximum value, initialized to the first element of the array.
  - **t1**: Stores the index of the current maximum value, initialized to `0`.
  - **t2**: Pointer to the current element being examined, starting from the second element.
  - **t3**: Current index in the array, starting from `1`.

---

### Loop Structure
```assembly
loop_start:
    beq t3, a1, end_argmax     # If current index t3 equals array length a1, exit loop

    lw t4, 0(t2)               # Load the current element into t4
    blt t4, t0, skip_update    # If current element < current max, skip updating

    bgt t4, t0, update_max     # If current element > current max, update max and index

skip_update:
    addi t2, t2, 4             # Move pointer to the next element (increment by 4 bytes)
    addi t3, t3, 1             # Increment the current index
    j loop_start               # Jump back to the start of the loop

update_max:
    mv t0, t4                  # Update current max value with the new maximum
    mv t1, t3                  # Update current max index with the new index
    j skip_update              # Continue loop
```

- **Loop Condition**:
  - Continues iterating until all elements have been processed (`t3` reaches `a1`).

- **Element Processing**:
  - **Load**: The current element pointed to by `t2` is loaded into `t4`.
  - **Compare**:
    - If `t4` (current element) is less than `t0` (current max), skip updating.
    - If `t4` is greater than `t0`, update both the current max value and its index.

- **Pointer and Index Update**:
  - The pointer `t2` is incremented by 4 bytes to point to the next element.
  - The index `t3` is incremented by 1.

---

### Error Handling
```assembly
handle_error:
    li a0, 36                  # Load exit code 36 into register a0
    j exit                     # Jump to exit the program
```

- **Condition**: Triggered if the input array is empty (`a1 < 1`).
- **Action**: Sets the exit code to `36` and terminates the program.

---

### Function Exit
```assembly
end_argmax:
    mv a0, t1                  # Move the result index from t1 to a0
    jr ra                      # Return to the caller
```

- **Action**:
  - The index of the first maximum element (`t1`) is moved to `a0`.
  - Control is returned to the calling function.

---

## Summary
The `argmax` function efficiently scans through an integer array to identify the index of the first occurrence of the maximum value. It initializes by assuming the first element is the maximum and iterates through the array, updating the maximum value and its index whenever a larger element is found. The function ensures robustness by validating the input array length and handling errors gracefully by terminating with a specific exit code if the array is empty. Utilizing RISC-V assembly instructions, the implementation performs in-place comparisons and updates, ensuring both space and time efficiency.


# ask 3.1: Dot Product Function

## Overview
The `dot` function computes the dot product of two vectors with customizable strides, enabling flexible and efficient processing of sub-sampled data. By accommodating varying strides, the function can handle scenarios where vectors are not contiguous in memory, a common occurrence in optimized data storage and retrieval schemes. This implementation prioritizes performance and adaptability, critical for scalable neural network operations.



### Implementation Details
#### 1️⃣ Input Validation
```assembly
li t0, 1              # Load immediate value 1
blt a2, t0, error_36  # Exit if element count < 1
blt a3, t0, error_37  # Exit if stride0 < 1
blt a4, t0, error_37  # Exit if stride1 < 1
```
**Purpose:** Ensures that the function receives valid input parameters, safeguarding against undefined behavior and potential memory access violations.

#### 2️⃣ Initialization
```assembly
li t0, 0              # Initialize accumulator (dot product sum)
li t1, 0              # Initialize loop counter
```
**Registers Used:**
- `t0`: Accumulates the dot product result.
- `t1`: Tracks the current iteration count within the loop.

#### 3️⃣ Main Loop
```assembly
loop_start:
    beq t1, a2, loop_end    # If loop counter equals element count, exit loop

    # Calculate byte offset for first array
    mul t2, t1, a3          # Compute offset: i * stride0
    slli t2, t2, 2          # Convert word offset to byte offset (4 bytes per word)
    add t3, a0, t2          # Address of a[i * stride0]
    lw t4, 0(t3)            # Load a[i * stride0] into t4

    # Calculate byte offset for second array
    mul t5, t1, a4          # Compute offset: i * stride1
    slli t5, t5, 2          # Convert word offset to byte offset
    add t6, a1, t5          # Address of b[i * stride1]
    lw t3, 0(t6)            # Load b[i * stride1] into t3

    mul t4, t4, t3          # Multiply a[i * stride0] * b[i * stride1]
    add t0, t0, t4          # Accumulate the product into t0

    addi t1, t1, 1          # Increment loop counter
    j loop_start            # Repeat the loop
```

**Loop Mechanics:**
- **Termination:** The loop terminates once all elements (`a2`) are processed.
- **Element Processing:**
  - Offset Calculation: Determines the memory addresses of the current elements in both input arrays based on their respective strides.
  - Load Operations: Retrieves the current elements from both arrays.
  - Multiplication and Accumulation: Computes the product of the current pair of elements and adds it to the accumulator (`t0`).
  - Iteration Management: Advances the loop counter to process the next pair of elements.

#### 4️⃣ Exit Condition
```assembly
loop_end:
    mv a0, t0         # Move result to return register
    jr ra             # Return to caller
```
**Purpose:** Finalizes the function by moving the accumulated dot product into the return register (`a0`) and returning control to the caller.

#### 5️⃣ Error Handling
```assembly
error_36:
    li a0, 36         # Error code 36 for element count < 1
    j exit            # Exit program

error_37:
    li a0, 37         # Error code 37 for invalid strides
    j exit            # Exit program
```
**Functionality:** Provides clear termination with specific error codes in cases of invalid input parameters, enhancing debuggability and reliability.


## Summary
The `dot` function proficiently calculates the dot product of two integer vectors with customizable strides, adhering to essential input validation protocols. While the implementation ensures functional correctness and operational efficiency, integrating advanced optimization strategies—such as loop unrolling, vectorization, and optimized memory access patterns—could substantially elevate its performance. These enhancements would render the function more adept at handling large-scale computations inherent in sophisticated neural network architectures and high-performance computing applications.



# Task 3.2: Matrix Multiplication

## Overview
Matrix multiplication is a cornerstone operation in numerous computational domains, particularly within neural networks where it facilitates the transformation of data through interconnected layers. The `matmul` function in RISC-V assembly orchestrates the multiplication of two matrices, producing a resultant matrix that encapsulates the product. This implementation meticulously validates input dimensions, leverages efficient looping constructs, and utilizes the previously implemented `dot` function to streamline computations, thereby ensuring both correctness and performance.



### Implementation Details
#### 1️⃣ Validation
```assembly
li t0, 1
blt a1, t0, error_dim      # Check M0 rows > 0
blt a2, t0, error_dim      # Check M0 columns > 0
blt a4, t0, error_dim      # Check M1 rows > 0
blt a5, t0, error_dim      # Check M1 columns > 0
bne a2, a4, error_dim      # Ensure M0 cols == M1 rows
```
**Purpose:** Validates that both input matrices have positive dimensions and that their dimensions are compatible for multiplication (i.e., the number of columns in Matrix A equals the number of rows in Matrix B).

#### 2️⃣ Setup
```assembly
addi sp, sp, -36
sw ra, 32(sp)           # Save return address
sw s0, 0(sp)            # Save register s0
sw s1, 4(sp)            # Save register s1
sw s2, 8(sp)            # Save register s2
# ... Save other necessary registers
```
**Functionality:** Establishes a stack frame to preserve the state of registers, ensuring that the function can safely perform operations without disrupting the caller's context.

#### 3️⃣ Outer Loop: Rows of Matrix A
```assembly
outer_row_loop:
    bge s0, a1, restore_and_exit    # Exit when all rows are processed
    # Initialize inner loop variables
    li s3, 0                        # Column index for Matrix B
    j column_process
```
**Mechanism:** Iterates over each row of Matrix A (M0), setting up the necessary variables for processing corresponding columns of Matrix B (M1).

#### 4️⃣ Inner Loop: Columns of Matrix B
```assembly
column_process:
    bge s3, a5, next_row            # Exit when all columns are processed
    # Compute dot product for current row and column
    mv a0, s1                        # Pointer to current row of M0
    mv a1, s4                        # Pointer to current column of M1
    mv a2, a2                        # Number of elements (cols0)
    li a3, 1                         # Stride for M0 rows
    mv a4, a5                        # Stride for M1 columns
    jal dot                          # Compute dot product
    sw a0, 0(s7)                     # Store result in Matrix D
    addi s7, s7, 4                   # Advance pointer in Matrix D
    addi s3, s3, 1                   # Increment column index
    j column_process
```
**Functionality:** For each row of Matrix A and each column of Matrix B, it invokes the `dot` function to compute the corresponding element in the resulting Matrix D.

#### 5️⃣ Result Storage
```assembly
sw a0, 0(s7)         # Store dot product result
addi s7, s7, 4       # Advance result pointer
```
**Purpose:** Places the computed dot product into the appropriate position within Matrix D, ensuring accurate placement in row-major order.

#### 6️⃣ Row Advancement
```assembly
next_row:
    mul t1, a2, 4       # Compute row offset (cols0 * 4 bytes)
    add s1, s1, t1      # Move to the next row of M0
    addi s0, s0, 1      # Increment row counter
    j outer_row_loop    # Repeat for next row
```
**Mechanism:** Advances the pointer to the next row of Matrix A (M0) and increments the row counter to continue processing subsequent rows.

#### 7️⃣ Restore State and Exit
```assembly
restore_and_exit:
    lw ra, 32(sp)        # Restore return address
    lw s0, 0(sp)         # Restore register s0
    lw s1, 4(sp)         # Restore register s1
    lw s2, 8(sp)         # Restore register s2
    addi sp, sp, 36      # Deallocate stack frame
    jr ra                # Return to caller
```
**Functionality:** Restores the preserved registers and deallocates the stack frame, ensuring the function exits without side effects on the caller's environment.

#### 8️⃣ Error Handling
```assembly
error_dim:
    li a0, 38           # Load error code for dimension mismatch
    j exit              # Exit program
```
**Purpose:** Handles cases where matrix dimensions are incompatible for multiplication by terminating the program with a specific error code (38), facilitating debugging and error tracking.


## Summary
The `matmul` function proficiently executes matrix multiplication in RISC-V assembly, integrating input validation, efficient looping constructs, and the utilization of the `dot` function for element-wise computations. While the current implementation ensures functional accuracy and operational efficiency, the incorporation of advanced optimization techniques—such as cache optimization, parallel processing, and loop unrolling—can substantially augment its performance. These enhancements would render the function more capable of handling large-scale matrices and high-throughput computational tasks inherent in complex neural network architectures.


# Part B: File Operations and Main
## Task 1: Read Matrix

### Overview
The `read_matrix` function is engineered to ingest binary matrix data from a file, facilitating dynamic memory allocation based on the matrix's dimensions. By adhering to a defined binary format comprising a header and data payload, the function ensures seamless interoperability and efficient data retrieval. This implementation emphasizes robust error handling and memory management, critical for maintaining system stability and preventing resource leaks.

### Binary File Format
- **Header (8 bytes):**
  - Bytes 0–3: Number of rows (int32)
  - Bytes 4–7: Number of columns (int32)
- **Matrix Data:**
  - Elements stored as 4-byte integers in row-major order.

### Function Arguments
#### Input:
- `a0`: Pointer to the filename string.
- `a1`: Address to store the number of rows.
- `a2`: Address to store the number of columns.

#### Output:
- `a0`: Base address of the dynamically allocated matrix.

### Error Handling
The program exits with specific error codes for failures:
- `26`: Memory allocation failure.
- `27`: File open failure.
- `28`: File close failure.
- `29`: File read failure.

### Memory Responsibility
The caller is responsible for freeing the dynamically allocated memory.


#### 1️⃣ Function Prologue
```assembly
addi   sp, sp, -48      # Allocate stack frame
sw     ra, 44(sp)       # Save return address
sw     s0, 0(sp)        # Save register s0
sw     s1, 4(sp)        # Save register s1
sw     s2, 8(sp)        # Save register s2
```
**Purpose:** Establishes a secure stack frame by allocating space and preserving the state of essential registers, ensuring that the function's operations do not interfere with the caller's context.
    
#### 2️⃣ File Opening
```assembly
li     a1, 0            # Mode 0 for reading
jal    fopen            # Open file

li     t0, -1
beq    a0, t0, fopen_error    # Check for fopen error
```
**Functionality:** Invokes the `fopen` function to open the specified file in read mode. It verifies the success of the operation by checking if the returned file pointer is -1, indicating an error.

#### 3️⃣ Read Header
```assembly
mv     a0, s0           # File pointer
addi   a1, sp, 0        # Buffer on stack
li     a2, 8            # Read 8 bytes (header)
jal    fread            # Read header

bne    a0, t0, fread_error    # Check if 8 bytes were read

lw     t1, 0(sp)        # Rows
lw     t2, 4(sp)        # Columns
sw     t1, 0(s3)        # Store rows
sw     t2, 0(s4)        # Store columns
```
**Mechanism:**
- **Reading the Header:** Extracts the number of rows and columns from the first 8 bytes of the file.
- **Validation:** Ensures that exactly 8 bytes are read to prevent partial or corrupted header data from being processed.

#### 4️⃣ Compute Total Elements
```assembly
li     s1, 0            # Initialize product
mv     t3, t1           # Rows
mv     t4, t2           # Columns

multiply_loop:
    beqz   t4, multiply_done    # Exit loop if multiplier is 0
    andi   t5, t4, 1            # Check LSB of multiplier
    beqz   t5, skip_add         # Skip if LSB is 0
    add    s1, s1, t3           # Add multiplicand to product
skip_add:
    slli   t3, t3, 1            # Double multiplicand
    srli   t4, t4, 1            # Halve multiplier
    j      multiply_loop
multiply_done:
slli   s1, s1, 2        # Multiply total elements by 4 (word size)
```
**Technique:** Implements the Russian Peasant Multiplication algorithm to efficiently compute the total byte size required for the matrix data, leveraging bitwise operations to optimize multiplication.
    
#### 5️⃣ Allocate Memory
```assembly
mv     a0, s1           # Size in bytes
jal    malloc            # Allocate memory

beq    a0, x0, malloc_error    # Check for malloc error

mv     s2, a0           # Save matrix pointer
```
**Functionality:** Dynamically allocates memory based on the computed byte size, ensuring that the matrix data has sufficient space. It verifies the success of the allocation, handling failures gracefully.

#### 6️⃣ Read Matrix Data
```assembly
mv     a0, s0           # File pointer
mv     a1, s2           # Destination buffer
mv     a2, s1           # Bytes to read
jal    fread            # Read data

bne    a0, s1, fread_error    # Check if all data was read
```
**Mechanism:** Reads the matrix data from the file into the allocated memory buffer, ensuring that the correct number of bytes is read to maintain data integrity.

#### 7️⃣ Close File
```assembly
mv     a0, s0           # File pointer
jal    fclose           # Close file

li     t0, -1
beq    a0, t0, fclose_error    # Check for fclose error
```
**Purpose:** Safely closes the file, releasing system resources and preventing file descriptor leaks.

#### 8️⃣ Function Epilogue
```assembly
mv     a0, s2           # Return matrix pointer

lw     ra, 44(sp)       # Restore registers
lw     s0, 0(sp)        
lw     s1, 4(sp)        
lw     s2, 8(sp)        
addi   sp, sp, 48       # Deallocate stack frame
jr     ra               # Return to caller
```
**Functionality:** Concludes the function by restoring the preserved registers, deallocating the stack frame, and returning the pointer to the dynamically allocated matrix to the caller.

#### 9️⃣ Error Handling
- **Memory Allocation Failure**
```assembly
malloc_error:
    li a0, 26       # Error code 26 for malloc failure
    j      error_exit
```
- **File Open Failure**
```assembly
fopen_error:
    li a0, 27       # Error code 27 for fopen failure
    j      error_exit
```
    
- **File Read Failure**
```assembly
fread_error:
    li a0, 29       # Error code 29 for fread failure
    j      error_exit
```

- **File Close Failure**
```assembly
fclose_error:
    li a0, 28       # Error code 28 for fclose failure
    j      error_exit
```

- **Exit Procedure**
```assembly
error_exit:
    lw     ra, 44(sp)
    lw     s0, 0(sp)
    lw     s1, 4(sp)
    lw     s2, 8(sp)
    addi   sp, sp, 48
    j      exit
```
**Functionality:** Manages various error conditions by setting specific error codes and ensuring proper restoration of the execution context before terminating the program.

---

## Summary
The `read_matrix` function dynamically loads a binary matrix into memory while handling errors gracefully. Key features include:
- Dynamic memory allocation to support variable-sized matrices.
- Error handling for file operations and memory allocation.
- Efficient multiplication for calculating matrix size.

By adhering to strict validation protocols and implementing comprehensive error handling, it ensures reliable and efficient data ingestion. Nevertheless, integrating advanced optimization techniques—such as asynchronous I/O, memory allocation strategies, and enhanced error reporting—could substantially bolster its performance and robustness, rendering it even more suitable for high-performance computing applications and large-scale neural network deployments.



# Task 2: Write Matrix

## Overview
The `write_matrix` function encapsulates the process of exporting a matrix to a binary file, adhering to a structured format comprising a header and data payload. By meticulously managing file operations and ensuring data integrity, the function facilitates seamless data persistence and interoperability with other systems or components. This implementation emphasizes efficiency, error handling, and adherence to the defined binary format, critical for reliable data storage and retrieval.

---

## Binary File Format
- **Header (8 bytes):**
  - Bytes 0–3: Number of rows (int32)
  - Bytes 4–7: Number of columns (int32)
- **Matrix Data:**
  - Elements stored as 4-byte integers in row-major order.

---

## Function Arguments
- `a0 (char *)`: Pointer to the filename string.
- `a1 (int *)`: Pointer to the matrix's starting location in memory.
- `a2 (int)`: Number of rows in the matrix.
- `a3 (int)`: Number of columns in the matrix.

---

## Error Handling
The function terminates the program with specific error codes for failures:
- `53`: File open (fopen) error.
- `54`: File write (fwrite) error.
- `55`: File close (fclose) error.

---

## Code Breakdown

### 1️⃣ Function Prologue
```assembly
addi sp, sp, -36       # Allocate stack frame
sw ra, 32(sp)          # Save return address
sw s0, 0(sp)           # Save register s0
sw s1, 4(sp)           # Save register s1
sw s2, 8(sp)           # Save register s2
sw s3, 12(sp)          # Save register s3
sw s4, 16(sp)          # Save register s4
sw s5, 20(sp)          # Save register s5
sw s6, 24(sp)          # Save register s6
sw s7, 28(sp)          # Save register s7
```
**Purpose:** Establishes a stack frame by allocating space and preserving the state of necessary registers, ensuring that the function's operations do not disrupt the caller's environment.

---

### 2️⃣ File Opening
```assembly
mv a0, s1              # a0 = filename
li a1, 1               # a1 = mode (1 for write)
jal fopen              # Call fopen
li t0, -1
beq a0, t0, fopen_error    # Check for fopen error
mv s0, a0              # Save file descriptor
```
**Functionality:** Opens the file for writing by invoking the `fopen` function. It verifies the success of the operation by checking if the returned file pointer is -1, indicating an error.

---

### 3️⃣ Write Header
```assembly
addi sp, sp, -8        # Allocate buffer on stack
sw s3, 0(sp)           # Store number of rows
sw s4, 4(sp)           # Store number of columns

mv a0, s0              # a0 = file descriptor
addi a1, sp, 0         # a1 = address of buffer
li a2, 2               # a2 = number of elements (rows and cols)
li a3, 4               # a3 = size of each element (4 bytes)
jal fwrite             # Call fwrite
li t0, 2
bne a0, t0, fwrite_error   # Check if all elements were written

addi sp, sp, 8         # Clean up buffer from stack
```
**Mechanism:**
- **Buffer Allocation:** Allocates space on the stack to temporarily hold the matrix's row and column counts.
- **Writing the Header:** Writes the number of rows and columns to the file as two consecutive 4-byte integers.
- **Validation:** Ensures that exactly two elements (rows and columns) are written successfully.

---

### 4️⃣ Write Matrix Rows

#### Outer Loop
```assembly
li s5, 0               # Initialize row index (i)
write_rows_loop:
    blt s5, s3, write_row    # If i < num_rows, write the row
    j write_done             # Else, we're done
```
**Functionality:** Iterates over each row of the matrix, initiating the process to write each row's data to the file.

#### Inner Row Processing
```assembly
# Calculate byte offset for the current row
mv s6, s5              # s6 = current row index
mv s7, x0              # s7 = byte offset accumulator

calculate_offset:
    beq s6, x0, offset_done
    add s7, s7, s4      # s7 += num_columns
    addi s6, s6, -1
    j calculate_offset

offset_done:
    slli s7, s7, 2       # Multiply by 4 to get byte offset

# Calculate address of the current row
add t1, s2, s7          # t1 = matrix base + byte offset

# Write the current row to the file
mv a0, s0               # a0 = file descriptor
mv a1, t1               # a1 = address of row data
mv a2, s4               # a2 = number of elements in the row
li a3, 4                # a3 = size of each element (4 bytes)
jal fwrite              # Call fwrite
bne a0, s4, fwrite_error    # Check if all elements were written

addi s5, s5, 1          # Increment row index
j write_rows_loop        # Loop back to write the next row
```
### Mechanism
1. **Offset Calculation:** Determines the byte offset for the current row based on the number of columns and the row index.
2. **Address Computation:** Calculates the memory address of the current row's data.
3. **Writing Data:** Invokes `fwrite` to write the current row's elements to the file.
4. **Validation:** Ensures that all elements of the row are written successfully.

---

## File Closing
```assembly
mv a0, s0               # a0 = file descriptor
jal fclose              # Call fclose
li t0, -1
beq a0, t0, fclose_error    # Check for fclose error
```
**Purpose:** Safely closes the file, releasing system resources and preventing file descriptor leaks.

---

## Function Epilogue
```assembly
lw s7, 0(sp)            # Restore registers
lw s6, 4(sp)
lw s5, 8(sp)
lw s4, 12(sp)
lw s3, 16(sp)
lw s2, 20(sp)
lw s1, 24(sp)
lw s0, 28(sp)
lw ra, 32(sp)
addi sp, sp, 36         # Deallocate stack frame
jr ra                   # Return from function
```
**Functionality:** Concludes the function by restoring the preserved registers, deallocating the stack frame, and returning control to the caller.

---

## Error Handling

### File Open Error
```assembly
fopen_error:
    li a0, 53           # Error code 53 for fopen error
    j error_exit
```

### File Write Error
```assembly
fwrite_error:
    li a0, 54           # Error code 54 for fwrite error
    j error_exit
```

### File Close Error
```assembly
fclose_error:
    li a0, 55           # Error code 55 for fclose error
    j error_exit
```

### Exit Procedure
```assembly
error_exit:
    lw s7, 0(sp)        # Restore registers
    lw s6, 4(sp)
    lw s5, 8(sp)
    lw s4, 12(sp)
    lw s3, 16(sp)
    lw s2, 20(sp)
    lw s1, 24(sp)
    lw s0, 28(sp)
    lw ra, 32(sp)
    addi sp, sp, 36
    j exit              # Jump to exit (assumes exit handles a0 as exit code)
```
**Functionality:** Manages various error conditions by setting specific error codes and ensuring proper restoration of the execution context before terminating the program.

---


## Summary
The `write_matrix` function proficiently serializes a matrix into a binary file, adhering to a strict format and ensuring data integrity through comprehensive error handling. While the implementation is robust and efficient, integrating advanced optimization and security techniques—such as buffered I/O, asynchronous operations, and data compression—can substantially elevate its performance and reliability. These enhancements would render the function more versatile and secure, catering to a broader range of applications and deployment scenarios in high-performance computing and neural network infrastructures.



# Task 3: Classification

## Overview
The `classify` function orchestrates a sequence of operations—matrix multiplication, ReLU activation, and ArgMax—to perform classification based on input data and weight matrices. This pipeline emulates a simple neural network's forward pass, transforming input data through weighted layers and activation functions to derive classification outcomes. The function embodies an integration of previously implemented components, showcasing the synergy between low-level assembly operations and high-level machine learning paradigms.

---

## Steps
1. **Matrix Multiplication:** Compute the hidden layer \(h = 	ext{matmul}(M_0, 	ext{input})\).
2. **ReLU Activation:** Apply the ReLU activation to \(h\).
3. **Second Matrix Multiplication:** Compute scores \(o = 	ext{matmul}(M_1, h)\).
4. **Classification:** Use ArgMax to determine the index of the highest score.

---

## Error Handling
- **31:** Invalid argument count.
- **26:** Memory allocation failure.

---

## Code Breakdown

### 1️⃣ Input Validation
```assembly
li t0, 5
blt a0, t0, error_args   # Check if argument count is less than 5
```
**Purpose:** Ensures that the function receives the requisite number of arguments, preventing undefined behavior due to insufficient inputs.

---

### 2️⃣ Reading Matrices

#### First Matrix (\(M_0\))
```assembly
li a0, 4
jal malloc                # Allocate memory for rows
mv s3, a0                 # Save M0 rows pointer

li a0, 4
jal malloc                # Allocate memory for columns
mv s4, a0                 # Save M0 cols pointer

lw a0, 4(a1)              # Load filename for M0
mv a1, s3                 # Set argument to store rows
mv a2, s4                 # Set argument to store cols
jal read_matrix           # Read M0 into memory
mv s0, a0                 # Save M0 base pointer
```
**Functionality:** Allocates memory for storing the number of rows and columns of Matrix \(M_0\), reads the matrix from a file, and stores its base address for subsequent operations.

---

### 3️⃣ Hidden Layer Computation (\(h\))

#### Matrix Multiplication
```assembly
lw t0, 0(s3)              # M0 rows
lw t1, 0(s8)              # Input cols
mv a0, t0                 # Multiplicand
mv a1, t1                 # Multiplier
jal multiply              # Compute total elements (t0 * t1)
slli a0, a0, 2            # Convert to bytes (4 bytes per element)
jal malloc                # Allocate memory for h
mv s9, a0                 # Save h base pointer

mv a0, s0                 # M0 base pointer
lw a1, 0(s3)              # M0 rows
lw a2, 0(s4)              # M0 cols
mv a3, s2                 # Input base pointer
lw a4, 0(s7)              # Input rows
lw a5, 0(s8)              # Input cols
jal matmul                # Compute h = matmul(M0, input)
```
**Mechanism:** Utilizes the `matmul` function to compute the hidden layer (\(h\)) by multiplying Matrix \(M_0\) with the input matrix.

#### ReLU Activation
```assembly
mv a0, s9                 # Base pointer for h
lw t0, 0(s3)              # M0 rows
lw t1, 0(s8)              # Input cols
mv a0, t0                 # Multiplicand
mv a1, t1                 # Multiplier
jal multiply              # Compute total elements
mv a1, a0                 # Length of h
jal relu                  # Apply ReLU activation
```
**Functionality:** Applies the ReLU activation function to the computed hidden layer (\(h\)), introducing non-linearity.

---

### 4️⃣ Output Computation (\(o\))
```assembly
lw t0, 0(s3)              # M0 rows
lw t1, 0(s6)              # M1 cols
mv a0, t0                 # Multiplicand
mv a1, t1                 # Multiplier
jal multiply              # Compute total elements (t0 * t1)
slli a0, a0, 2            # Convert to bytes (4 bytes per element)
jal malloc                # Allocate memory for o
mv s10, a0                # Save o base pointer

mv a0, s1                 # M1 base pointer
lw a1, 0(s5)              # M1 rows
lw a2, 0(s6)              # M1 cols
mv a3, s9                 # h base pointer
lw a4, 0(s3)              # h rows
lw a5, 0(s8)              # h cols
jal matmul                # Compute o = matmul(M1, h)
```

---

### 5️⃣ Writing the Output Matrix
```assembly
lw a0, 16(a1)             # Load output filename
mv a1, s10                # Base pointer for o
lw a2, 0(s5)              # Number of rows in o
lw a3, 0(s8)              # Number of columns in o
jal write_matrix          # Write o to file
```

---

### 6️⃣ Classification
```assembly
mv a0, s10                # Base pointer for o
lw t0, 0(s3)              # M0 rows
lw t1, 0(s6)              # M1 cols
mv a0, t0                 # Multiplicand
mv a1, t1                 # Multiplier
jal multiply              # Compute total elements (length of o)
mv a1, a0                 # Length of o
jal argmax                # Find index of highest score
```

---

### 7️⃣ Cleanup
```assembly
mv a0, s0                 # Free M0
jal free
mv a0, s1                 # Free M1
jal free
mv a0, s2                 # Free input
jal free
mv a0, s9                 # Free h
jal free
mv a0, s10                # Free o
jal free
```

---


## Summary
The `classify` function epitomizes the integration of foundational assembly-based operations to emulate a neural network's classification pipeline. By orchestrating matrix multiplications, ReLU activations, and ArgMax computations, it effectively transforms input data through weighted layers to derive classification outcomes. While the current implementation is functionally robust, the incorporation of advanced optimization techniques—such as pipeline parallelism, dynamic memory management enhancements, and function inlining—could significantly amplify its performance and scalability. These enhancements would render the function more adept at handling complex, large-scale classification tasks inherent in advanced neural network architectures.


# Overall System Integration

## Architectural Considerations
Integrating the individual components—ReLU, ArgMax, Dot Product, Matrix Multiplication, and File Operations—requires a coherent architectural strategy to ensure seamless interoperability and optimal performance. Key considerations include:

### Modular Design
- **Approach:** Maintain a modular structure where each function encapsulates a specific operation, promoting reusability and ease of maintenance.
- **Benefit:** Facilitates independent testing and debugging of individual components, enhancing system reliability.

### Efficient Memory Management
- **Approach:** Implement dynamic memory allocation judiciously, ensuring that memory is allocated only when necessary and deallocated promptly after use.
- **Benefit:** Prevents memory leaks and optimizes memory usage, crucial for large-scale data processing.

### Register Allocation Strategy
- **Approach:** Develop a consistent register allocation scheme across all functions to minimize register spilling and maximize data throughput.
- **Benefit:** Enhances performance by reducing memory access latency and enabling more efficient instruction pipelining.

---

## Performance Optimization
To elevate the system's performance, the following optimization strategies are imperative:

### Instruction-Level Parallelism
- **Opportunity:** Exploit the inherent parallelism in RISC-V's instruction set to execute multiple operations concurrently.
- **Implementation:** Reorder instructions to minimize dependencies and enable parallel execution, leveraging the processor's pipelining capabilities.

### Cache Optimization
- **Opportunity:** Enhance cache utilization by structuring data access patterns to align with cache lines and minimize cache misses.
- **Implementation:** Organize matrices in contiguous memory blocks and access elements in a cache-friendly manner, reducing access latency.

### Loop Unrolling and Vectorization
- **Opportunity:** Reduce loop overhead and exploit data-level parallelism by unrolling loops and utilizing vector instructions.
- **Implementation:** Expand loop bodies to handle multiple iterations per cycle and leverage RISC-V's vector extensions for parallel data processing.

---

## Scalability and Extensibility
Ensuring that the system scales efficiently with increasing data sizes and complexity is paramount. Strategies include:

### Support for Larger Matrices
- **Approach:** Design functions to handle matrices of varying sizes without hard-coded limitations.
- **Implementation:** Utilize dynamic memory allocation and parameterize functions based on matrix dimensions.

### Extensible Activation Functions
- **Approach:** Facilitate the integration of additional activation functions beyond ReLU to accommodate diverse neural network architectures.
- **Implementation:** Abstract activation function implementations, allowing for easy addition or modification.

### Batch Processing Capabilities
- **Approach:** Enable the system to process multiple inputs or matrices in a single operation.
- **Implementation:** Introduce loop constructs or parallel processing techniques to handle batches of data efficiently.

---

## Robustness and Error Handling
Enhancing the system's robustness involves comprehensive error handling and validation mechanisms:

### Granular Error Reporting
- **Opportunity:** Provide detailed error messages and codes to facilitate precise debugging and issue resolution.
- **Implementation:** Extend error codes to cover a broader range of failure scenarios and include contextual information where applicable.

### Input Validation Enhancements
- **Opportunity:** Incorporate thorough input validation to detect and handle anomalous or malicious inputs gracefully.
- **Implementation:** Implement bounds checking, type verification, and integrity checks to ensure data consistency.

### Recovery Mechanisms
- **Opportunity:** Transition from fatal error terminations to recoverable error states, allowing the system to maintain operational continuity.
- **Implementation:** Introduce error flags, status codes, or fallback procedures to manage errors without halting execution.

---

## Conclusions
The assembly-level implementations of foundational neural network components—ReLU activation, ArgMax, Dot Product, Matrix Multiplication, and file operations—demonstrate a meticulous approach to low-level programming aligned with high-level machine learning objectives. Through comprehensive input validation, efficient memory management, and robust error handling, these functions establish a reliable foundation for more complex neural network operations.

However, the potential for further optimization and enhancement is substantial. By integrating advanced strategies such as vectorization, loop unrolling, and asynchronous I/O operations, the system's performance and scalability can be significantly augmented. Additionally, adopting a modular and extensible architectural framework will facilitate the seamless integration of additional functionalities and support for larger, more complex data structures.

Ultimately, the synergy between low-level assembly optimizations and high-level machine learning paradigms embodies a sophisticated and efficient approach to neural network implementation, poised to meet the demands of modern computational tasks.

---
## Results
```assembly
(base) yckuo@MacBook-Pro-2 classify-rv32i % ./test.sh all
test_abs_minus_one (__main__.TestAbs) ... ok
test_abs_one (__main__.TestAbs) ... ok
test_abs_zero (__main__.TestAbs) ... ok
test_argmax_invalid_n (__main__.TestArgmax) ... ok
test_argmax_length_1 (__main__.TestArgmax) ... ok
test_argmax_standard (__main__.TestArgmax) ... ok
test_chain_1 (__main__.TestChain) ... ok
test_classify_1_silent (__main__.TestClassify) ... ok
test_classify_2_print (__main__.TestClassify) ... ok
test_classify_3_print (__main__.TestClassify) ... ok
test_classify_fail_malloc (__main__.TestClassify) ... ok
test_classify_not_enough_args (__main__.TestClassify) ... ok
test_dot_length_1 (__main__.TestDot) ... ok
test_dot_length_error (__main__.TestDot) ... ok
test_dot_length_error2 (__main__.TestDot) ... ok
test_dot_standard (__main__.TestDot) ... ok
test_dot_stride (__main__.TestDot) ... ok
test_dot_stride_error1 (__main__.TestDot) ... ok
test_dot_stride_error2 (__main__.TestDot) ... ok
test_matmul_incorrect_check (__main__.TestMatmul) ... ok
test_matmul_length_1 (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_y (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_y (__main__.TestMatmul) ... ok
test_matmul_nonsquare_1 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_2 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_outer_dims (__main__.TestMatmul) ... ok
test_matmul_square (__main__.TestMatmul) ... ok
test_matmul_unmatched_dims (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m0 (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m1 (__main__.TestMatmul) ... ok
test_read_1 (__main__.TestReadMatrix) ... ok
test_read_2 (__main__.TestReadMatrix) ... ok
test_read_3 (__main__.TestReadMatrix) ... ok
test_read_fail_fclose (__main__.TestReadMatrix) ... ok
test_read_fail_fopen (__main__.TestReadMatrix) ... ok
test_read_fail_fread (__main__.TestReadMatrix) ... ok
test_read_fail_malloc (__main__.TestReadMatrix) ... ok
test_relu_invalid_n (__main__.TestRelu) ... ok
test_relu_length_1 (__main__.TestRelu) ... ok
test_relu_standard (__main__.TestRelu) ... ok
test_write_1 (__main__.TestWriteMatrix) ... ok
test_write_fail_fclose (__main__.TestWriteMatrix) ... ok
test_write_fail_fopen (__main__.TestWriteMatrix) ... ok
test_write_fail_fwrite (__main__.TestWriteMatrix) ... ok

----------------------------------------------------------------------
Ran 46 tests in 15.668s

OK

```
