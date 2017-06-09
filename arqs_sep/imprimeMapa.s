.section .data

str1: .string "#"
str2: .string "+"
str3: .string "-"

.equ ST_FIRST_PARAMETER, 16 # stack position of the first parameter
.equ print_gap, 10

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
    movq HDR_SIZE_OFFSET(%rax), %rcx #%rcx <- current block size

    while_heap: #scroll through the heap
    cmpq %rax, current_break #if you have reached the end of the heap
    jl imprimeMapa_fim #end function imprimeMapa

    pushq %rax #store regs
    pushq %rbx
    pushq %rcx

    pushq $str1
    call print_char #print '#' - avaible
    subq $8, %rsp

    pushq $str1
    call print_char #print '#' - block size
    subq $8, %rsp

    popq %rcx #restore regs
    popq %rbx
    popq %rax

    pushq $str2 #if unavaible, print '+'
    cmpq $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax) #If the space is unavailable
    je not_a #start printing

    subq $8, %rsp #if avaible, remove '+'
    pushq $str3 #and put '-'

    not_a: #start printing
    movq $0, %rbx

    while_block: #scroll through the block
    pushq %rax #store regs
    pushq %rbx
    pushq %rcx
    
    call print_char #print '+' or '-'
    
    popq %rcx #restore regs
    popq %rbx
    popq %rax

    addq print_gap, %rbx #skip print_gap bytes

    cmpq %rcx, %rbx
    jl while_block

    subq $8, %rsp #remove '+' or '-'

    addq $HEADER_SIZE, %rax #next block
    addq %rcx, %rax
    jmp while_heap


imprimeMapa_fim:
    popq %rbp
    ret
##end imprimeMapa##

print_char:
  pushq %rbp
  movq %rsp, %rbp

  movq ST_FIRST_PARAMETER(%rbp), %rax
  movq %rax, %rdi
  xor %rax, %rax  # tem q ter esse xor (não sei pq)
  call printf

  popq %rbp
  ret