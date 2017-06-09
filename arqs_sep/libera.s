.section .text
.globl meuFree

##meuFree##
# PURPOSE:
# The purpose of this function is to give back a region of memory to
# the pool after we’re done using it. There is no return  value.
#
# PARAMETERS:
# (1) The address of the memory we want to return to the memory pool.
#
# PROCESSING:
# If you remember, we actually hand the program the start of the memory
# that they can use, which is 16 storage locations after the actual start
# of the memory region. All we have to do is go back 16 locations and mark
# that memory as available, so that the allocate function knows it can use it.

meuFree:
    pushq %rbp
    movq %rsp, %rbp

    movq ST_MEM_SIZE(%rbp), %rax #get the address of the memory to free
    subq $HEADER_SIZE, %rax #get the pointer to the real beginning of the memory
    movq HDR_SIZE_OFFSET(%rax), %rcx #%rcx <- current block size
    movq $AVAILABLE, HDR_AVAIL_OFFSET(%rax) #mark it as available
    movq HDR_SIZE_OFFSET(%rax), %rdx #%rcx <- current block size

    popq %rbp
    ret
##end meuFree##

