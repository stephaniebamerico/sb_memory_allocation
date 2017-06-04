# Para Compilar:
# as testeM.s -o testeM.o
# ld -I /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc -s -o testeM testeM.o

.section .data
	format: .string "%d\n"
.section .text
    .globl _start
_start:
  	pushq	%rbp
  	movq 	%rsp, %rbp
  	movq 	$format, %rdi
  	movq  	$10, %rsi
   	xor 	%rax, %rax  # tem q ter esse xor (não sei pq)
  	call 	printf
  	popq 	%rbp
  	movq 	$60, %rax
  	syscall
