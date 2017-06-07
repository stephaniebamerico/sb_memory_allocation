.section .text
.globl _start

_start:
	pushq %rbp
    movq %rsp, %rbp

    call iniciaAlocador

    pushq $100 # Size_mem
    call meuMalloc
    pushq %rax # Adress_m
    call debug # print
    popq %rax # remove Adress_m
    subq $8, %rsp # remove Size_mem

    pushq $80 # Size_mem
    call meuMalloc
    pushq %rax # Adress_m
    call debug # print
    popq %rax # remove Adress_m
    subq $8, %rsp # remove Size_mem

	pushq %rax # Size_mem, or in this case: adress to desallocate
    call meuFree
    pushq %rax # Adress_m
    call debug # print
    popq %rax # remove Adress_m
    subq $8, %rsp # remove Size_mem

    pushq $50 # Size_mem
    call meuMalloc
    pushq %rax # Adress_m
    call debug # print
    popq %rax # remove Adress_m
    subq $8, %rsp # remove Size_mem

    pushq $10 # Size_mem
    call meuMalloc
    pushq %rax # Adress_m
    call debug # print
    popq %rax # remove Adress_m
    subq $8, %rsp # remove Size_mem

	pushq $10 # Size_mem
    call meuMalloc
    pushq %rax # Adress_m
    call debug # print
    popq %rax # remove Adress_m
    subq $8, %rsp # remove Size_mem

    pushq $10 # Size_mem
    call meuMalloc
    pushq %rax # Adress_m
    call debug # print
    popq %rax # remove Adress_m
    subq $8, %rsp # remove Size_mem

    call finalizaAlocador

    popq %rbp
    movq $0, %rdi
    movq $SYS_EXIT, %rax
    syscall
