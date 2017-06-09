.section .text
.globl _start

_start:
    pushq %rbp
    movq %rsp, %rbp

    call iniciaAlocador

    pushq $4000 #Size_mem
    call meuMalloc
    pushq %rax #Adress_m
    call debug #print
    call imprimeMapa
    popq %rax #remove Adress_m
    subq $8, %rsp #remove Size_mem

    pushq $50 #Size_mem
    call meuMalloc
    pushq %rax #Adress_m
    call debug #print
    call imprimeMapa
    popq %rax #remove Adress_m
    subq $8, %rsp #remove Size_mem

    pushq $5000 #Size_mem
    call meuMalloc
    pushq %rax #Adress_m
    call debug #print
    call imprimeMapa
    popq %rax #remove Adress_m
    subq $8, %rsp #remove Size_mem

    pushq %rax #Size_mem, or in this case: adress to desallocate
    call meuFree
    pushq %rax #Adress_m
    call debug #print
    call imprimeMapa
    popq %rax #remove Adress_m
    subq $8, %rsp #remove Size_mem

    
    call finalizaAlocador

    popq %rbp
    movq $1, %rdi
    movq $SYS_EXIT, %rax
    syscall

