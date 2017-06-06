.section .text
.globl iniciaAlocador
.globl finalizaAlocador

iniciaAlocador:
	pushq %rbp
	movq %rsp, %rbp

	movq $SYS_BRK, %rax
	movq $0, %rdi
	syscall

	addq $1, %rax
	movq %rax, heap_begin
	movq %rax, current_break

	popq %rbp
	ret

finalizaAlocador:
	pushq %rbp
	movq %rsp, %rbp

	movq $SYS_BRK, %rax
	movq heap_begin, %rdi
	syscall

	cmpq heap_begin, %rax
	jne error

	movq %rax, current_break

	popq %rbp
	ret
