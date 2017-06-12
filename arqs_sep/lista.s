.section .text
.globl map_lista_occ
.globl map_lista_free

map_lista_occ:
	pushq %rbp
	movq %rsp, %rbp

	movq occ_list, %rax
whiletrue1:
	pushq %rax
	call debug
	popq %rax

	movq BL_NXT_OFFSET(%rax),%rax
	jmp whiletrue1

	popq %rbp
	ret


	map_lista_free:
		pushq %rbp
		movq %rsp, %rbp

		movq fr_lst, %rax
	whiletrue:
		pushq %rax
		call debug
		popq %rax

		movq BL_NXT_OFFSET(%rax),%rax
		jmp whiletrue

		popq %rbp
		ret
