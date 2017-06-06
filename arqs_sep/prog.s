.section .text
.globl _start

_start:
	call iniciaAlocador
	movq $60, %rax
	syscall
