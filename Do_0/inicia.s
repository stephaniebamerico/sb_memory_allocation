.section .text

iniciaAlocador:
	# procedimentos iniciais da função
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp

	# valor inicial do brk
	movq	$0, %rdi
	movq 	$12, %rax
	syscall

	movq %rax, INIT_VAL_BRK # valor inicial do brk
	movq %rax, CURR_VAL_BRK # valor atual do brk

	# procedimentos finais
	addq	$8, %rsp
	popq	%rbp
	ret
