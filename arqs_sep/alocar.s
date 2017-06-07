.section .text
.globl alocaMem

alocaMem:
	pushq %rbp
	movq %rsp, %rbp

	# Algoritmo:
	#	PERCORRE lista_livre COM bloco_atual
	#		SE bloco_atual.tam > pedido
	#			divide(bloco_atual,bloco_div,pedido)
	#			insere(bloco_atual,lista_ocupado)
	#			SE bloco_div != NULL
	#				insere(bloco_div,lista_livre)
	#			RETORNA bloco_atual
	#
	#	novo_bloco = aloca(4096)
	#	ENQUANTO novo_bloco.tam < pedido
	#		aux = aloca(4096)
	#		novo_bloco = merge(novo_bloco,aux)
	#	divide(novo_bloco,bloco_div,pedido)
	#	insere(novo_bloco,lista_ocupado)
	#	SE bloco_div != NULL
	#		insere(bloco_div,lista_livre)
	#	RETORNA novo_bloco
