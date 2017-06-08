.section .text
.globl meuFree


# Desaloca bloco de memória
# PARAMETROS bloco * A
# RETORNA 0 se ocorreu erro, 1 se deu tudo certo
meuFree:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rbx # carrega endereço de A

	# SE A está livre: erro
	cmpq BL_FREE, BL_OCC_OFFSET(%rbx)
	je error

	pushq %rbx # salvar endereço de A
	movq $occ_list, %rsi
	call aux_remove

	# SE A não foi removido da occ_list (ex: ele não estava lá)
	cmpq $0, %rax
	je error

	popq %rbx

	movq BL_FREE, BL_OCC_OFFSET(%rbx)

	movq %rbx, %rdi
	movq $free_list, %rsi
	call aux_insert

	# checagem de erro
	cmpq $0, %rax
	je error

	movq $1, %rax
	popq %rbp
	ret
