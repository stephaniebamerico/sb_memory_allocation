.section .text
.globl alocaMem

alocaMem:
	pushq %rbp
	movq %rsp, %rbp

	# Algoritmo:
	#c	//bloco a ser verificado para a alocação
	#	bloco_atual ← cabeça_lista_livre
	#c	//se já foi alocada alguma memória
	#	SE bloco_atual != NULL
	#c		//o primeiro espaço livre tem tamanho suficiente
	#		SE bloco_atual.tam > espaço_pedido
	#c			//essa função divide o bloco no tamanho desejado e cria um novo bloco
	#c			//se possível (couber um cabeçalho e tals)
	#c			//PS: é automático : bloco_div.prox ← bloco_atual.pros
	#			divide (bloco_atual,bloco_div, espaço_pedido)
	#c			//atualiza o ponteiro da cabeça_lista_livre
	#			cabeça_lista_livre ← bloco_div
	#c			//bloco ocupado
	#			bloco_atual.livre ← falso
	#c			//se o bloco recém ocupado for antes da cabeça_lista_ocupado ou
	#c			//se nada estiver oucupado
	#			SE (cabeça_lista_ocupado > &bloco_atual) || (cabeça_lista_ocupado == NULL)
	#				bloco_atual.prox ← cabeça_lista_ocupado
	#				cabeça_lista_ocupado ← bloco_atual
	#			SENÃO
	#c				//percorre a lista de ocupados
	#				aux ← cabeça_lista_ocupado
	#				ENQUANTO (aux.prox < &bloco_atual) && (aux.prox != NULL)
	#					aux ← aux.prox
	#c				//se chegou ao final da lista
	#				SE aux.prox == NULL
	#					aux.prox ← bloco_atual
	#				SENÂO
	#					bloco_atual.prox ← aux.prox
	#					aux.prox ← bloco_atual
	#			RETORNA bloco_atual
	#
	#c		//se o primeiro bloco livre não tem espaço suficinte
	#		SENÂO
	#c			//percorre lista de livres
	#			ENQUANTO (bloco_atual.prox.tam < espaço_pedido) && (bloco_atual.prox != NULL)
	#				bloco_atual ← bloco_atual.prox
	#
	#c			//se chegou ao fim da lista sem encontrar um bloco com tamanho suficiente ...
	#			SE bloco_atual.prox == NULL
	#c				// ... é alocado 4096 bytes ...
	#				inicio_bloco ← fim_brk
	#				brk(4096)
	#c				// ... é criado un novo bloco na antiga "última posição" da heap ...
	#				novo_bloco ← criaBloco(inicio_bloco,4096)
	#c				// ... e
	#				divide (novo_bloco,bloco_div,espaço_pedido)
	#				novo_bloco.livre ← falso
	#				bloco_atual.prox ← bloco_div
	#
	#				aux ← cabeça_lista_ocupado
	#				ENQUANTO aux.pro != NULL
	#					aux ← aux.prox
	#				aux.prox ← novo_bloco
	#
	#			SENÂO
	#				divide (bloco_atual.prox,bloco_div,espaço_pedido)
	#				bloco_atual.prox.livre ← falso
	#
	#				aux ← cabeça_lista_ocupado
	#				ENQUANTO (aux.prox < &bloco_atual.prox) && (aux.prox != NULL)
	#					aux ← aux.prox
	#				SE aux.prox == NULL
	#					aux.prox ← bloco_atual
	#				SENÂO
	#					bloco_atual.prox ← aux.prox
	#					aux.prox ← bloco_atual
	#			RETORNA bloco_atual
	#
	#
	#
	#
	#
	#
	#
	#
	#
	#
	#
	#
	#
	#
	#
	#
	#
	#
