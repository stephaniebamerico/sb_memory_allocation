.section .data

.globl fr_lst
.globl occ_list
.globl heap_begin
.globl current_break

	fr_lst: .quad 0
	occ_list: .quad 0
	heap_begin: .quad 0
	current_break: .quad 0

.globl BL_SIZ_OFFSET
.globl BL_OCC_OFFSET
.globl BL_NXT_OFFSET
.globl BL_HEAD_SIZE

.globl BL_OCC
.globl BL_FREE

.globl SYS_BRK
.globl SYS_EXIT

	.equ BL_SIZ_OFFSET, -8
	.equ BL_OCC_OFFSET, -16
	.equ BL_NXT_OFFSET, -24
	.equ BL_HEAD_SIZE, 24

	.equ BL_OCC, 1
	.equ BL_FREE, 0


	.equ SYS_BRK, 12
	.equ SYS_EXIT, 60

.section .text
.globl error
.globl error32

# rotina de erro sem variáveis locais
error:
    movq $0, %rax # retorna 0
    popq %rbp
    ret

# rotina de erro com 4 variáveis locais
error32:
	addq $32, %rsp
    movq $0, %rax # retorna 0
    popq %rbp
    ret
