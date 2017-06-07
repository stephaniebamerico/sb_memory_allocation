.section .data

.globl heap_begin
.globl current_break

.globl mem_avaible

.globl HEADER_SIZE
.globl HDR_AVAIL_OFFSET
.globl HDR_SIZE_OFFSET

.globl ST_MEM_SIZE

.globl AVAILABLE
.globl UNAVAILABLE
.globl SYS_BRK
.globl SYS_EXIT

# ######GLOBAL VARIABLES########
# This points to the beginning of the memory we are managing
heap_begin : .quad 0
# This points to one location past the memory we are managing
current_break : .quad 0

mem_avaible: .quad 0

# #####STRUCTURE INFORMATION####
.equ HEADER_SIZE, 16 #size of space for memory region header
.equ HDR_AVAIL_OFFSET, 0 #Location of the "available" flag in the header
.equ HDR_SIZE_OFFSET, 8 #Location of the size field in the header
.equ ST_MEM_SIZE, 16 #stack position of the memory size to allocate/desallocate

# ##########CONSTANTS###########
.equ AVAILABLE, 1 #available for giving
.equ UNAVAILABLE, 0 #space that has been given out
.equ SYS_BRK, 12 #system call number for the break
.equ SYS_EXIT, 60 #system call number for exit

.section .text
.globl error

# Error: returns 0
error:
	movq $0, %rax
	popq %rbp
	ret
