.section .data

str1: .string "------\nSize_mem: %d\n"
str2: .string "Adress_m: %d\n"
str3: .string "Current_: %d\n"

.equ ST_FIRST_PARAMETER, 16 # stack position of the first parameter
.equ ST_SECOND_PARAMETER, 24 # stack position of second parameter

.section .text
.globl debug

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