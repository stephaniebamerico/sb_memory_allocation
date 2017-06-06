.section .data
#######GLOBAL VARIABLES########
#This points to the beginning of the memory we are managing
heap_begin : .quad 0
#This points to one location past the memory we are managing
current_break : .quad 0
str1: .string "------\nSize_mem: %d\n"
str2: .string "Adress_m: %d\n"
str3: .string "Current_: %d\n"
here: .string "******Here******\n"
n: .string "* N: %d *\n"

######STRUCTURE INFORMATION####
.equ HEADER_SIZE, 16 #size of space for memory region header
.equ HDR_AVAIL_OFFSET, 0 #Location of the "available" flag in the header
.equ HDR_SIZE_OFFSET, 8 #Location of the size field in the header
.equ ST_MEM_SIZE, 16 #stack position of the memory size to allocate/desallocate
.equ ST_FIRST_PARAMETER, 16 #stack position of the first parameter
.equ ST_SECOND_PARAMETER, 24 #stack position of second parameter

###########CONSTANTS###########
.equ AVAILABLE, 1 #available for giving
.equ UNAVAILABLE, 0 #space that has been given out
.equ SYS_BRK, 12 #system call number for the break
.equ SYS_EXIT, 60 #system call number for exit

.section .text
.globl _start

_start:
    pushq %rbp
    movq %rsp, %rbp

    call allocate_init

    pushq $4000 #Size_mem
    call allocate
    pushq %rax #Adress_m
    call debug #print
    popq %rax #remove Adress_m
    subq $8, %rsp #remove Size_mem

    pushq $5000 #Size_mem
    call allocate
    pushq %rax #Adress_m
    call debug #print
    popq %rax #remove Adress_m
    subq $8, %rsp #remove Size_mem

    pushq %rax #Size_mem, or in this case: adress to desallocate
    call deallocate
    pushq %rax #Adress_m
    call debug #print
    popq %rax #remove Adress_m
    subq $8, %rsp #remove Size_mem

    pushq $4000 #Size_mem
    call allocate
    pushq %rax #Adress_m
    call debug #print
    popq %rax #remove Adress_m
    subq $8, %rsp #remove Size_mem
    
    pushq $65 #Size_mem
    call allocate
    pushq %rax #Adress_m
    call debug #print
    popq %rax #remove Adress_m
    subq $8, %rsp #remove Size_mem

    pushq $64 #Size_mem
    call allocate
    pushq %rax #Adress_m
    call debug #print
    popq %rax #remove Adress_m
    subq $8, %rsp #remove Size_mem

    pushq $5000 #Size_mem
    call allocate
    pushq %rax #Adress_m
    call debug #print
    popq %rax #remove Adress_m
    subq $8, %rsp #remove Size_mem

    call allocate_end

    popq %rbp
    movq %rax, %rdi
    movq $SYS_EXIT, %rax
    syscall

##########FUNCTIONS############
##allocate_init##
# PURPOSE: call this function to initialize 
# (specifically, this sets heap_begin and current_break). 
# This has no parameters and no return value.
allocate_init:
    pushq %rbp
    movq %rsp, %rbp

    movq $SYS_BRK, %rax
    movq $0, %rdi
    syscall #find out where the break is

    #%rax now has the last valid address, 
    #and we want the memory location after that
    addq $1, %rax 

    movq %rax, heap_begin

    #Store the current break as our first address.
    #This will cause the allocate function to get
    #more memory from Linux the first time it is run
    movq %rax, current_break #store the current break
    
    popq %rbp #exit the function
    ret
##end allocate_init##

##allocate_end##
# PURPOSE: call this function to ends (specifically, 
# this sets current_break = heap_begin). 
# This has no parameters and no return value.
allocate_end:
    pushq %rbp
    movq %rsp, %rbp

    movq $SYS_BRK, %rax
    movq heap_begin, %rdi
    syscall #desallocate heap

    #if it fail
    cmpq heap_begin, %rax
    jne error

    movq %rax, current_break
    
    popq %rbp #exit the function
    ret
##end allocate_end##

##allocate##
# PURPOSE: This function is used to grab a section of memory.
# It checks to see if there are any free blocks, and, if not,
# it asks Linux for a new one.
#
# PARAMETERS: (1) The size of the memory block to allocate
#
# RETURN VALUE: Returns the address of the allocated memory in %rax.
# If there is no memory available, it will return 0 in %rax.
#
######PROCESSING########
# Variables used:
#
# %rcx - hold the size of the requested memory (parameter (1))
# %rax - current memory region being examined
# %rbx - current break position
# %rdx - size of current memory region
#
# We scan through each memory region starting with heap_begin. 
# We look at the size of each one, and if it has been allocated. 
# If it’s big enough for the requested size, and its available, 
# it grabs that one. If it does not find a region large enough, 
# it asks Linux for more memory (it moves current_break up)
allocate:
    pushq %rbp
    movq %rsp, %rbp

    movq ST_MEM_SIZE(%rbp), %rcx #%rcx <- size we are looking for (parameter (1))
    movq heap_begin, %rax #%rax <- current search location
    movq current_break, %rbx #%rbx <- current break

alloc_loop_begin:
    cmpq %rbx, %rax #need more memory if these are equal
    je move_break

    movq HDR_SIZE_OFFSET(%rax), %rdx #grab the size of this memory
    cmpq $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax) #If the space is unavailable,
    je next_location #go to the next one
    
    cmpq %rdx, %rcx #If the space is available, compare the size to the needed size.
    jle allocate_here #If its big enough, go to allocate_here

next_location:
    #The total size of the memory region is the sum of the current
    #region size (%rdx), plus another 16 bytes for the header
    #(8 - AVAILABLE/UNAVAILABLE, 8 - size of the region).
    #So, adding %rdx and $16 to %rax will get the address
    #of the next memory region.
    addq $HEADER_SIZE, %rax
    addq %rdx, %rax
    jmp alloc_loop_begin #go look at the next location

allocate_here: #header of the region to allocate is in %rax
    movq $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax) #mark space as unavailable

    subq %rcx, %rdx
    subq $HEADER_SIZE, %rdx #leftover memory

    cmpq $26, %rdx
    jl allocate_here_end #check if leftover memory < 26

    movq %rcx, HDR_SIZE_OFFSET(%rax) #mark the new size of the block allocated
    pushq %rax #store return adress

    addq $HEADER_SIZE, %rax
    addq %rcx, %rax #next available position

    movq $AVAILABLE, HDR_AVAIL_OFFSET(%rax) #mark space as available
    movq %rdx, HDR_SIZE_OFFSET(%rax) #mark the new size of the block leftover
    
    popq %rax #restores return adress

allocate_here_end:
    addq $HEADER_SIZE, %rax #%rax (return) <- usable memory adress

    popq %rbp
    ret

move_break: #we have exhausted all addressable memory, so ask for more.
#%rbx <- current endpoint of the data, %rcx <- current endpoint size
    movq %rcx, %rdi
    addq $HEADER_SIZE, %rdi #total memory needed
    movq $0, %rdx

while:
	addq $4096, %rdx
	cmpq %rdi, %rdx
	jl while

	addq %rdx, %rbx #memory size request
	subq $HEADER_SIZE, %rdx #memory region size

    #now its time to ask Linux for more memory
    pushq %rax #save needed registers
    pushq %rbx
    pushq %rcx
    pushq %rdx

    movq %rbx, %rdi #%rdi <- memory size request
    movq $SYS_BRK, %rax
    syscall

    #Return the new break in %rax, which will be either 0 if it fails,
    #or it will be equal to or larger than we asked for.
    cmpq $0, %rax #check for error conditions
    je error

    popq %rdx #restore saved registers
    popq %rcx
    popq %rbx
    popq %rax

    movq %rbx, current_break #save the new break
    movq %rdx, HDR_SIZE_OFFSET(%rax) #set the size of the memory

    jmp allocate_here

error:
    movq $0, %rax #on error, we return zero
    popq %rbp
    ret
##end allocate##

##deallocate##
# PURPOSE:
# The purpose of this function is to give back a region of memory to
# the pool after we’re done using it. There is no return  value.
#
# PARAMETERS:
# (1) The address of the memory we want to return to the memory pool.
#
# PROCESSING:
# If you remember, we actually hand the program the start of the memory
# that they can use, which is 16 storage locations after the actual start
# of the memory region. All we have to do is go back 16 locations and mark
# that memory as available, so that the allocate function knows it can use it.

deallocate:
    pushq %rbp
    movq %rsp, %rbp

    movq ST_MEM_SIZE(%rbp), %rax #get the address of the memory to free
    subq $HEADER_SIZE, %rax #get the pointer to the real beginning of the memory
    movq $AVAILABLE, HDR_AVAIL_OFFSET(%rax) #mark it as available

    popq %rbp
    ret
##end deallocate##

debug:
    pushq %rbp
    movq %rsp, %rbp

    #tam
    movq ST_SECOND_PARAMETER(%rbp), %rax
    movq $str1, %rdi
    movq %rax, %rsi
    xor %rax, %rax  # tem q ter esse xor (não sei pq)
    call printf

    #endereco
    movq ST_FIRST_PARAMETER(%rbp), %rax
    movq $str2, %rdi
    movq %rax, %rsi
    xor %rax, %rax  # tem q ter esse xor (não sei pq)
    call printf
    #current end
    movq $str3, %rdi
    movq current_break, %rsi
    xor %rax, %rax  # tem q ter esse xor (não sei pq)
    call printf

    popq %rbp
    ret