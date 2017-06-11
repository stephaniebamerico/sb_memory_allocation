.section .data
print1: .string "inicio heap: %ld \n"
print2: .string "\nfim heap: %ld \n"
str1: .string "------\nSize_mem: %d\n"
str2: .string "Adress_m: %ld\n"
str3: .string "Current_: %ld\n"
str4: .string "Occupied: %ld\n"
str5: .string "Next_blk: %ld\n"
here: .string "******Here******\n"
n: .string "* N: %ld *\n"

.equ ST_FIRST_PARAMETER, 16 # stack position of the first parameter
.equ ST_SECOND_PARAMETER, 24 # stack position of second parameter

.section .text
.globl _start
.globl debug

_start:
	pushq %rbp
    movq %rsp, %rbp

	call iniciaAlocador

	movq $print1, %rdi
	movq heap_begin, %rsi
	xor %rax, %rax
	call printf

	movq $1000, %rdi # Size_mem
    call meuMalloc


	# pushq %rax # Adress_m
    # call debug # print
    # popq %rax # remove Adress_m
	call mapa

	# movq %rax, %rdi
	# call meuFree
	# call mapa

	movq $2000, %rdi # Size_mem
    call meuMalloc

    # pushq %rax # Adress_m
    # call debug # print
    # popq %rax # remove Adress_m
	call mapa

	# movq %rax, %rdi
	# call meuFree
	# call mapa

	movq $4000, %rdi # Size_mem
    call meuMalloc

    # pushq %rax # Adress_m
    # call debug # print
    # popq %rax # remove Adress_m
	call mapa

	# movq %rax, %rdi
	# call meuFree
	# call mapa


	movq $5000, %rdi # Size_mem
    call meuMalloc

    # pushq %rax # Adress_m
    # call debug # print
    # popq %rax # remove Adress_m
	call mapa

	# movq %rax, %rdi
	# call meuFree
	# call mapa

	movq $100000, %rdi # Size_mem
    call meuMalloc

    # pushq %rax # Adress_m
    # call debug # print
    # popq %rax # remove Adress_m
	call mapa


	movq $100, %rdi # Size_mem
    call meuMalloc

    # pushq %rax # Adress_m
    # call debug # print
    # popq %rax # remove Adress_m
	call mapa


	movq $print2, %rdi
	movq current_break, %rsi
	xor %rax, %rax
	call printf

	call finalizaAlocador

	popq %rbp
    movq $0, %rdi
    movq $SYS_EXIT, %rax
    syscall


	debug:
	    pushq %rbp
	    movq %rsp, %rbp

	    # tam
	    movq ST_FIRST_PARAMETER(%rbp), %rax
		movq BL_SIZ_OFFSET(%rax), %rsi
	    movq $str1, %rdi
	    xor %rax, %rax  # tem q ter esse xor (não sei pq)
	    call printf

	    # endereco
	    movq ST_FIRST_PARAMETER(%rbp), %rax
	    movq $str2, %rdi
	    movq %rax, %rsi
	    xor %rax, %rax  # tem q ter esse xor (não sei pq)
	    call printf

		# ocupado
		movq ST_FIRST_PARAMETER(%rbp), %rax
		movq BL_OCC_OFFSET(%rax), %rsi
	    movq $str4, %rdi
	    xor %rax, %rax  # tem q ter esse xor (não sei pq)
	    call printf

		# prox

		movq ST_FIRST_PARAMETER(%rbp), %rax
		movq BL_NXT_OFFSET(%rax), %rsi
	    movq $str5, %rdi
	    xor %rax, %rax  # tem q ter esse xor (não sei pq)
	    call printf

	    # current end
	    movq $str3, %rdi
	    movq current_break, %rsi
	    xor %rax, %rax  # tem q ter esse xor (não sei pq)
	    call printf

	    popq %rbp
	    ret
