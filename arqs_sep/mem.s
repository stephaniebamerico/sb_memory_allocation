.section .data
print1: .string "\n\n\tINICO MAPA\n"
print2: .string "\n\tFIM MAPA\n"
str1: .string "----------\nAddr: %d\n\tSize: %d\n\tOcc: %d"

.section .text
.globl mapa

mapa:
	pushq %rbp
	movq %rsp, %rbp

	movq $print1, %rdi
	xor %rax, %rax
	call printf


	movq occ_list, %rbx

while1:
	# ENQUANTO bloco_atual < current_break
	cmpq current_break, %rbx
	jg end_while1

	movq $str1, %rdi
	movq (%rbx), %rsi
	movq BL_SIZ_OFFSET(%rbx), %rdx
	movq BL_OCC_OFFSET(%rbx), %rcx

	pushq %rbx
	xor %rax, %rax
	call printf
	popq %rbx

	movq BL_SIZ_OFFSET(%rbx), %rcx
	addq $BL_HEAD_SIZE, %rcx
	addq %rbx, %rcx # endereço do próximo bloco na memória
	movq %rcx, %rbx
	jmp while1
end_while1:

	movq $print2, %rdi
	xor %rax, %rax
	call printf

	popq %rbp
	ret
