.section .data
print1: .string "inicio heap: %ld \n"
str1: .string "------\nSize_mem: %d\n"
str2: .string "Adress_m: %d\n"
str3: .string "Current_: %d\n"
here: .string "******Here******\n"
n: .string "* N: %d *\n"

.equ ST_FIRST_PARAMETER, 16 # stack position of the first parameter
.equ ST_SECOND_PARAMETER, 24 # stack position of second parameter

.section .text
.globl _start

_start:
	pushq %rbp
    movq %rsp, %rbp

	call iniciaAlocador

	movq $print1, %rdi
	movq heap_begin, %rsi
	xor %rax, %rax
	call printf

	movq $100, %rdi # Size_mem
    call meuMalloc

	pushq $100
    pushq %rax # Adress_m
    call debug # print
    popq %rax # remove Adress_m
    subq $8, %rsp # remove Size_mem

	movq $100, %rdi # Size_mem
    call meuMalloc

	pushq $100
    pushq %rax # Adress_m
    call debug # print
    popq %rax # remove Adress_m
    subq $8, %rsp # remove Size_mem

	movq $100, %rdi # Size_mem
    call meuMalloc

	pushq $100
    pushq %rax # Adress_m
    call debug # print
    popq %rax # remove Adress_m
    subq $8, %rsp # remove Size_mem

	movq $100, %rdi # Size_mem
    call meuMalloc

	pushq $100
    pushq %rax # Adress_m
    call debug # print
    popq %rax # remove Adress_m
    subq $8, %rsp # remove Size_mem



	call finalizaAlocador

	popq %rbp
    movq $0, %rdi
    movq $SYS_EXIT, %rax
    syscall


	debug:
	    pushq %rbp
	    movq %rsp, %rbp

	    # tam
	    movq ST_SECOND_PARAMETER(%rbp), %rax
	    movq $str1, %rdi
	    movq %rax, %rsi
	    xor %rax, %rax  # tem q ter esse xor (não sei pq)
	    call printf

	    # endereco
	    movq ST_FIRST_PARAMETER(%rbp), %rax
	    movq $str2, %rdi
	    movq %rax, %rsi
	    xor %rax, %rax  # tem q ter esse xor (não sei pq)
	    call printf
	    # current end
	    movq $str3, %rdi
	    movq current_break, %rsi
	    xor %rax, %rax  # tem q ter esse xor (não sei pq)
	    call printf

	    popq %rbp
	    ret
