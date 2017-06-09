.section .data

str1: .string "#"
str2: .string "+"
str3: .string "-"
str4: .string "\n"

.equ ST_FIRST_PARAMETER, 16 # stack position of the first parameter
print_gap : .quad 500

.section .text
.globl imprimeMapa

##imprimeMapa##
# PURPOSE:
# Function that prints a memory map of the heap region.
# This has no parameters and no return value.
#
#####PROCESSING########
# Variables used:
# %rax - current memory region being examined
# %rbx - counter
# %rcx - current memory size

imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp

    movq heap_begin, %rax #%rax <- current search location

    while_heap: #scroll through the heap
    cmpq %rax, current_break #if you have reached the end of the heap
    jle imprimeMapa_fim #end function imprimeMapa
    
    movq HDR_SIZE_OFFSET(%rax), %rcx #%rcx <- current block size

    pushq %rax #store regs
    pushq %rbx
    pushq %rcx

    call print_1 #print '#' - avaible
    call print_1 #print '#' - block size
    call print_1 #print '#' - list

    popq %rcx #restore regs
    popq %rbx
    popq %rax

    cmpq $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax) #If the space is unavailable
    je not_a #start printing

        movq $0, %rbx

        while_block_is: #scroll through the block
        pushq %rax #store regs
        pushq %rbx
        pushq %rcx
        
        call print_3 #print '-'
        
        popq %rcx #restore regs
        popq %rbx
        popq %rax

        addq print_gap, %rbx #skip print_gap bytes

        cmpq %rcx, %rbx
        jl while_block_is

        jmp end_while_block

    not_a: #start printing
        movq $0, %rbx

        while_block_not: #scroll through the block
        pushq %rax #store regs
        pushq %rbx
        pushq %rcx
        
        call print_2 #print '+'
        
        popq %rcx #restore regs
        popq %rbx
        popq %rax

        addq print_gap, %rbx #skip print_gap bytes

        cmpq %rcx, %rbx
        jl while_block_not

    end_while_block:
    addq $HEADER_SIZE, %rax #next block
    addq %rcx, %rax
    jmp while_heap

imprimeMapa_fim:
    call print_4
    popq %rbp
    ret
##end imprimeMapa##

print_1:
  movq $str1, %rax
  movq %rax, %rdi
  xor %rax, %rax  # tem q ter esse xor (não sei pq)
  call printf

  ret

print_2:
  movq $str2, %rax
  movq %rax, %rdi
  xor %rax, %rax  # tem q ter esse xor (não sei pq)
  call printf

  ret

print_3:
  movq $str3, %rax
  movq %rax, %rdi
  xor %rax, %rax  # tem q ter esse xor (não sei pq)
  call printf

  ret

print_4:
  movq $str4, %rax
  movq %rax, %rdi
  xor %rax, %rax  # tem q ter esse xor (não sei pq)
  call printf

  ret