

.section .text
.globl aux_merge
.globl aux_divide
.globl aux_insert
.globl aux_alloc_brk
.globl aux_remove


# Faz o merge de dois blocos.
# PARAMETROS: bloco *A, bloco *B
# RETORNA: bloco *novo_bloco
aux_merge:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rax # carrega o endereço de A
	movq %rsi, %rbx # carrega o endereço de B

	# calcula endereço do bloco adjacente a A
	movq BL_SIZ_OFFSET(%rax), %rcx
	addq BL_HEAD_SIZE, %rcx
	addq %rax, %rcx

	# SE endr_adj == &B
if1:
	cmpq %rcx, %rbx
	jne end_if1

	#	A.prox = B.prox
	movq BL_NXT_OFFSET(%rbx), %r8
	movq %r8, BL_NXT_OFFSET(%rax)
	#	A.tam = B.tam + BL_HEAD_SIZE
	movq BL_HEAD_SIZE, %r8
	addq %r8, BL_SIZ_OFFSET(%rax)
	movq BL_SIZ_OFFSET(%rbx), %r8
	addq %r8, BL_SIZ_OFFSET(%rax)

	# como o novo_bloco tem o endr de A, e A já está em %rax
	popq %rbp
	ret
end_if1:
	# A e B não são blocos adjacentes
	call error


# Faz a divisão de um bloco de acordo com o tamanho especificado
# PARAMETROS: bloco *A, tam
# RETORNA: bloco *B
aux_divide:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rbx # carrega o endereço de A
	movq %rsi, %rcx # carrega o valor de tam

if2:
	# SE A.tam > tam + BL_HEAD_SIZE + 50 bytes
	movq %rcx, %rax
	addq BL_HEAD_SIZE, %rax
	addq $50, %rax

	cmpq %rax, BL_SIZ_OFFSET(%rbx)
	jle end_if2

	#	&B = &A + tam + BL_HEAD_SIZE
	movq %rbx, %rax # %rax := B (é que vai ser retornado da função)
	addq %rcx, %rax
	addq BL_HEAD_SIZE, %rax

	#	B.prox = A.prox
	movq BL_NXT_OFFSET(%rbx), %r8
	movq %r8, BL_NXT_OFFSET(%rax)

	#	A.prox = B
	movq %rax, BL_NXT_OFFSET(%rbx)

	#	B.tam = A.tam - (tam + BL_HEAD_SIZE)
	movq %rcx, %rdx
	addq BL_HEAD_SIZE, %rdx
	movq BL_SIZ_OFFSET(%rbx), %r8
	movq %r8, BL_SIZ_OFFSET(%rax)
	subq %rdx, BL_SIZ_OFFSET(%rax)

	#	B.occ = livre
	movq BL_FREE, %r8
	movq %r8, BL_OCC_OFFSET(%rax)

	popq %rbp
	ret
end_if2:
	# não há espaço para dividir A
	call error



# Insere um bloco em uma lista especificada
# PARAMETROS bloco *novo_bloco, bloco *lista
# RETORNA: 	0 se não foi inserido (bloco já está na lista)
#			1 se foi inserido
aux_insert:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rax # carrega endereço de novo_bloco
	movq %rsi, %rbx # carrega endereço da lista

	movq (%rbx), %rcx # carrega endereço do bloco_atual

if3:
	# SE lista == NULL (lista vazia)
	cmpq $0, %rcx
	jne end_if3

	#	lista = novo_bloco
	#	novo_bloco.prox = NULL
	movq %rax, (%rbx)
	movq $0, BL_NXT_OFFSET(%rax)

	#	RETORNA 1
	movq $1, %rax
	popq %rbp
	ret
end_if3:

if4:
	# SE &bloco_atual == &novo_bloco
	cmpq %rax, %rcx
	jne end_if4

	#	novo_bloco já está na lista
	call error
end_if4:

if5:
	# SE &bloco_atual > &novo_bloco
	jl end_if5

	#	lista = novo_bloco
	movq %rax, (%rbx)
	movq %rcx, BL_NXT_OFFSET(%rax)  # novo_bloco.prox = &bloco_atual

	movq $1, %rax
	popq %rbp
	ret
end_if5:

while1:
	# ENQUANTO &bloco_atual.prox < &novo_bloco (+) SE bloco_atual.prox == NULL : insere no final
while1_p1:
	# SE bloco_atual.prox == NULL : insere no final
	cmpq $0, BL_NXT_OFFSET(%rcx)
	jne while1_p2

	#	bloco_atual.prox = novo_bloco
	movq %rax, BL_NXT_OFFSET(%rcx)

	movq $1, %rax
	popq %rbp
	ret
while1_p2:
	# ENQUANTO &bloco_atual.prox < &novo_bloco
	cmpq BL_NXT_OFFSET(%rcx), %rax
while1_err:
	jne while1_err_end
	# &bloco_atual.prox == &novo_bloco : erro
	call error
while1_err_end:
	jg while1_end

	#	bloco_atual = bloco_atual.prox
	movq BL_NXT_OFFSET(%rcx), %rcx
	jmp while1
while1_end:

	# novo_bloco.prox = bloco_atual.prox
	movq BL_NXT_OFFSET(%rcx), %r8
	movq %r8, BL_NXT_OFFSET(%rax)
	# bloco_atual.prox = novo_bloco
	movq %rax, BL_NXT_OFFSET(%rcx)

	movq $1, %rax
	popq %rbp
	ret


# Aumenta o valor da BRK
# PARAMETROS: int valor
# RETORNA: bloco de tamanho liberado e começando no antigo valor da BRK (ou NULL)
aux_alloc_brk:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rbx # salvar valor

	addq current_break, %rdi # current_break + valor
	movq SYS_BRK, %rax
	syscall

	# verificação para garantir que foi alocado espaço
	movq $0, %rdi
	movq SYS_BRK, %rax
	syscall

	# SE %rax (novo brk) =< current_break (antigo)
	cmpq current_break, %rax
	jle error

	movq current_break, %rcx # salva current_break antigo
	movq %rax, current_break # atualiza current_break

	# prepara endereço do novo_bloco
	movq %rcx, %rax
	addq BL_HEAD_SIZE, %rax

	# prepara tamanho do novo_bloco
	# novo_bloco.tam = current_break - &novo_bloco
	movq current_break, %rdx
	subq %rax, %rdx
	movq %rdx, BL_SIZ_OFFSET(%rax)

	# novo_bloco.occ = livre
	movq BL_FREE, %r8
	movq %r8, BL_OCC_OFFSET(%rax)
	# novo_bloco.prox = NULL
	movq $0, BL_NXT_OFFSET(%rax)

	popq %rbp
	ret


# Remove bloco de uma lista
# PARAMETROS: bloco *A
# RETORNA: 0 se não encontrou o bloco, 1 se removeu
aux_remove:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rbx # carrega endereço de A
	movq (%rsi), %rcx # carrega primeiro elemento da lista (bloco_atual)

if_6:
	# SE bloco_atual == A
	cmpq %rcx, %rbx
	jne end_if6

	# 	lista = &A.prox
	movq BL_NXT_OFFSET(%rbx), %r8
	movq %r8, (%rsi)

	movq $1, %rax
	popq %rbp
	ret
end_if6:

while2:
	# ENQUANTO bloco_atual.prox != A
	# SE bloco_atual.prox == NULL : erro
	cmpq $0, BL_NXT_OFFSET(%rcx)
	je error

	cmpq %rbx, BL_NXT_OFFSET(%rcx)
	je end_while2

	# bloco_atual = bloco_atual.prox
	movq BL_NXT_OFFSET(%rcx), %rcx
end_while2:

	# bloco_atual.prox = A.prox
	movq BL_NXT_OFFSET(%rbx), %r8
	movq %r8, BL_NXT_OFFSET(%rcx)

	# A.prox = NULL
	movq $0, BL_NXT_OFFSET(%rbx)

	movq $1, %rax
	popq %rbp
	ret
