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
	movq $BL_FREE, %r8
	cmpq %r8, BL_OCC_OFFSET(%rbx)
	je error

	pushq %rbx # salvar endereço de A
	movq $occ_list, %rsi
	call aux_remove # remover da lista de ocupados

	# SE A não foi removido da occ_list (ex: ele não estava lá)
	cmpq $0, %rax
	je error

	popq %rbx

	movq $BL_FREE, %r8
	movq %r8, BL_OCC_OFFSET(%rbx) # A.occ = livre

	pushq %rbx
	movq %rbx, %rdi
	movq $fr_lst, %rsi
	call aux_insert # inserir A na lista de livres

	popq %rbx

	# checagem de erro
	cmpq $0, %rax
	je error

	pushq %rbx # salvar endereço de A
	movq %rbx, %rdi
	movq BL_NXT_OFFSET(%rbx), %rsi
	call aux_merge # unir A e A.prox, se possível

	popq %rbx
if1:
	# SE fr_lst != A (A não é o primeiro elemento da lista)
	cmpq fr_lst, %rbx
	je end_if1

	# aux = fr_lst
	movq fr_lst, %rcx

while1:
	#	ENQUANTO aux.prox != A
	movq BL_NXT_OFFSET(%rcx), %r8
	cmpq %r8, %rbx

	je end_while1

	#		aux = aux.prox
	movq BL_NXT_OFFSET(%rcx), %rcx
	jmp while1

end_while1:
	# merge(aux,A)
	movq %rcx, %rdi
	movq %rbx, %rsi
	call aux_merge

end_if1:

	movq $1, %rax
	popq %rbp
	ret
