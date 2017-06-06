.section .data
.globl heap_begin
.globl current_break

	# Variaveis globaisde controle da brk
	heap_begin: .quad 0
	current_break: .quad 0


.globl SYS_BRK
.globl SYS_EXIT

	# Constantes de syscall
	.equ SYS_BRK, 12
	.equ SYS_EXIT, 60

.section .text
.globl error


# Rotina de erro : retorna 0
error:
	movq $0, %rax
	popq %rbp
	ret
