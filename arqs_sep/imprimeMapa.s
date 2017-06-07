.section .text
.globl imprimeMapa

##imprimeMapa##
# PURPOSE:
# Function that prints a memory map of the heap region.
# This has no parameters and no return value.

imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp

    

    popq %rbp
    ret
##end imprimeMapa##