.section .text
.globl _start

_start:
	pushq %rbp
    movq %rsp, %rbp

    
    popq %rbp
    movq $0, %rdi
    movq $SYS_EXIT, %rax
    syscall
