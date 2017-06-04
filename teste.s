.data
msg: .ascii "Hello World\n"

.text
.global _start

_start:
    movq $1, %rax   # use the write syscall
    movq $1, %rdi   # write to stdout
    movq $msg, %rsi # use string "Hello World"
    movq $12, %rdx  # write 12 characters
    syscall         # make syscall
    
    movq $60, %rax  # use the _exit syscall
    movq $0, %rdi   # error code 0
    syscall         # make syscall