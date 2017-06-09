.section .text
.globl iniciaAlocador
.globl finalizaAlocador

# #########FUNCTIONS############
# #iniciaAlocador##
# PURPOSE: call this function to initialize
# (specifically, this sets heap_begin and current_break).
# This has no parameters and no return value.
iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $SYS_BRK, %rax
    movq $0, %rdi
    syscall #find out where the break is

    #%rax now has the last valid address, 
    #and we want the memory location after that
    addq $1, %rax 

    movq %rax, heap_begin

    #Store the current break as our first address.
    #This will cause the allocate function to get
    #more memory from Linux the first time it is run
    movq %rax, current_break #store the current break
    movq %rax, mem_avaible
    
    popq %rbp #exit the function
    ret
# #end iniciaAlocador##

# #finalizaAlocador##
# PURPOSE: call this function to ends (specifically,
# this sets current_break = heap_begin).
# This has no parameters and no return value.
finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $SYS_BRK, %rax
    movq heap_begin, %rdi
    syscall #desallocate heap

    movq heap_begin, %rdi
    movq %rdi, current_break
    
    popq %rbp #exit the function
    ret
# #end finalizaAlocador##
