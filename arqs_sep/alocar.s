.section .data
	.equ pedido, -8
	.equ novo_bloco, -16
	.equ menor_bloco, -24
	.equ menor_dif, -32

	str1: .string "parte1"
	str2: .string "parte2"

.section .text
.globl meuMalloc

meuMalloc:
	pushq %rbp
	movq %rsp, %rbp
	subq 32, %rsp

	# Algoritmo: (first fit)
	#	PERCORRE lista_livre COM bloco_atual
	#		SE bloco_atual.tam > pedido
	#			bloco_div = divide(bloco_atual,pedido)
	#			insere(bloco_atual,lista_ocupado)
	#			SE bloco_div != NULL
	#				insere(bloco_div,lista_livre)
	#			RETORNA bloco_atual
	#
	#	novo_bloco = aloca(4096)
	#	ENQUANTO novo_bloco.tam < pedido
	#		aux = aloca(4096)
	#		novo_bloco = merge(novo_bloco,aux)
	#	bloco_div = divide(novo_bloco,pedido)
	#	insere(novo_bloco,lista_ocupado)
	#	SE bloco_div != NULL
	#		insere(bloco_div,lista_livre)
	#	RETORNA novo_bloco



	# Algoritmo: (best fit)
	# parte1:
	#	bloco_atual = lista_livre
	#	ENQUANTO (bloco_atual.tam <= pedido) (+) SE bloco_atual == NULL : GOTO parte2
	#		bloco_atual = bloco_atual.prox
	#	menor_bloco = bloco_atual
	#	menor_dif = bloco_atual.tam - pedido
	#
	#	ENQUANTO bloco_atual != NULL
	#		SE bloco_atual.tam > pedido && (bloco_atual.tam - pedido) < menor_dif
	#			menor_bloco = bloco_atual
	#			menor_dif = (bloco_atual.tam - pedido)
	#		bloco_atual = bloco_atual.prox
	#
	#	bloco_div = divide(bloco_atual,pedido)
	#	insere(bloco_atual,lista_ocupado)
	#	SE bloco_div != NULL
	#		insere(bloco_div,lista_livre)
	#	RETORNA bloco_atual
	#
	# parte2:
	#	novo_bloco = aloca(4096)
	#	ENQUANTO novo_bloco.tam < pedido
	#		aux = aloca(4096)
	#		novo_bloco = merge(novo_bloco,aux)
	#	bloco_div = divide(novo_bloco,pedido)
	#	insere(novo_bloco,lista_ocupado)
	#	SE bloco_div != NULL
	#		insere(bloco_div,lista_livre)
	#	RETORNA novo_bloco
part1:
	movq %rdi, pedido(%rbp)
	movq free_list, %rcx # %rcx := bloco_atual

while1:
	# SE bloco_atual == NULL : GOTO parte2
	cmpq $0, %rcx
	je part2
	# ENQUANTO (bloco_atual.tam <= pedido)
	movq pedido(%rbp), %r8
	cmpq %r8, BL_SIZ_OFFSET(%rcx)
	jg end_while1
	# 	bloco_atual = bloco_atual.prox
	movq BL_NXT_OFFSET(%rcx), %rcx
	jmp while1
end_while1:

	# menor_bloco = bloco_atual
	movq %rcx, menor_bloco(%rbp)
	# menor_dif = bloco_atual.tam - pedido
	movq BL_SIZ_OFFSET(%rcx), %rax
	subq pedido(%rbp), %rax
	movq %rax, menor_dif(%rbp)

while2:
	# ENQUANTO bloco_atual != NULL
	cmpq $0, %rcx
	je end_while2
if1:
	# 	SE bloco_atual.tam > pedido
	movq pedido(%rbp), %r8
	cmpq %r8, BL_SIZ_OFFSET(%rcx)
	jle end_if1
	# 	SE (bloco_atual.tam - pedido) < menor_dif
	movq BL_SIZ_OFFSET(%rcx), %rax
	subq pedido(%rbp), %rax
	cmpq menor_dif(%rbp), %rax
	jge end_if1
	#		menor_bloco = bloco_atual
	movq %rcx, menor_bloco(%rbp)
	#		menor_dif = (bloco_atual.tam - pedido)
	movq %rax, menor_dif(%rbp)
end_if1:
	# 	bloco_atual = bloco_atual.prox
	movq BL_NXT_OFFSET(%rcx), %rcx
	jmp while2
end_while2:

	# bloco_div = divide(bloco_atual,pedido)
	pushq %rcx # salvar o valor de bloco_atual
	movq %rcx, %rdi
	movq pedido(%rbp), %rsi
	call aux_divide

	# checagem de erro
	cmpq $0, %rax
	je error32

	popq %rcx

	# remove(bloco_atual,lista_livre)
	pushq %rax # salvar o valor de bloco_div
	pushq %rcx # salvar o valor de bloco_atual
	movq %rcx, %rdi
	movq $occ_list, %rsi
	call aux_remove

	# checagem de erro
	cmpq $0, %rax
	je error32

	popq %rcx

	# insere(bloco_atual,lista_ocupado)
	pushq %rcx # salvar o valor de bloco_atual
	movq %rcx, %rdi
	movq $occ_list, %rsi
	call aux_insert

	# checagem de erro
	cmpq $0, %rax
	je error32

	popq %rcx
	popq %rax

if2:
	# SE bloco_div != NULL
	cmp $0, %rax
	je end_if2
	#	insere(bloco_div,lista_livre)
	pushq %rcx
	movq %rax, %rdi
	movq $free_list, %rsi
	call aux_insert

	# checagem de erro
	cmpq $0, %rax
	je error32

	popq %rcx
end_if2:

	# bloco_atual.occ = ocupado
	movq BL_OCC, %r8
	movq %r8, BL_OCC_OFFSET(%rcx)

	# RETORNA bloco_atual
	movq %rcx, %rax
	addq 32, %rsp
	popq %rbp
	ret

part2:
	# novo_bloco = aloca(4096)
	movq $4096, %rdi
	call aux_alloc_brk

	# checagem de erro
	cmpq $0, %rax
	je error32

	movq %rax, novo_bloco(%rbp)

while3:
	# ENQUANTO novo_bloco.tam < pedido
	movq pedido(%rbp), %r8
	cmpq %r8, BL_SIZ_OFFSET(%rax)
	jg end_while3

	# 	aux = aloca(4096)
	pushq %rax # salvar o endereço de novo_bloco
	movq $4096, %rdi
	call aux_alloc_brk

	# checagem de erro
	cmpq $0, %rax
	je error32

	# 	novo_bloco = merge(novo_bloco,aux)
	movq %rax, %rbx # %rbx := aux
	popq %rax

	movq %rax, %rdi
	movq %rbx, %rsi
	call aux_merge

	# checagem de erro
	cmpq $0, %rax
	je error32

end_while3:



	# bloco_div = divide(novo_bloco,pedido)
	pushq %rax # salvar o valor de novo_bloco
	movq %rax, %rdi
	movq pedido(%rbp), %rsi
	call aux_divide
	movq %rax, %rbx # %rbx := bloco_div
	popq %rax

	# insere(novo_bloco,lista_ocupado)
	pushq %rax # salvar valor de novo_bloco
	pushq %rbx # salvar valor de bloco_div
	movq %rax, %rdi
	movq $occ_list, %rsi
	call aux_insert
	popq %rbx

if3:
	# SE bloco_div != NULL
	cmpq $0, %rbx
	je end_if3

	# 	insere(bloco_div,lista_livre)
	movq %rbx, %rdi
	movq $free_list, %rsi
	call aux_insert
end_if3:

	popq %rax # recupera valor de novo_bloco

	# novo_bloco.occ = ocupado
	movq BL_OCC, %r8
	movq %r8, BL_OCC_OFFSET(%rax)

	addq 32, %rsp
	popq %rbp
	ret
