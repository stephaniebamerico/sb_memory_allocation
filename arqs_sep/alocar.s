.section .text
.globl meuMalloc

# PURPOSE: This function is used to grab a section of memory.
# It checks to see if there are any free blocks, and, if not,
# it asks Linux for a new one.
#
# PARAMETERS: (1) The size of the memory block to meuMalloc
#
# RETURN VALUE: Returns the address of the allocated memory in %rax.
# If there is no memory available, it will return 0 in %rax.
#
# #####PROCESSING########
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
meuMalloc:
    pushq %rbp
    movq %rsp, %rbp

    movq ST_MEM_SIZE(%rbp), %rcx #%rcx <- size we are looking for (parameter (1))
    movq avaible_list, %rax #%rax <- current search location
    movq current_break, %rbx #%rbx <- current break

alloc_loop_begin:
    cmpq %rbx, %rax #need more memory if these are equal
    je move_break

    movq HDR_SIZE_OFFSET(%rax), %rdx #grab the size of this block
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

    cmpq $34, %rdx
    jl allocate_here_end #check if leftover memory < 34

    movq %rcx, HDR_SIZE_OFFSET(%rax) #mark the new size of the block allocated
    pushq %rax #store return adress

    addq $HEADER_SIZE, %rax
    addq %rcx, %rax #next available position

    movq $AVAILABLE, HDR_AVAIL_OFFSET(%rax) #mark space as available
    movq %rdx, HDR_SIZE_OFFSET(%rax) #mark the new size of the block leftover
    movq heap_begin, %rdx
    movq %rdx, HDR_LIST_OFFSET(%rax) #next is "null"

    addq $HEADER_SIZE, %rax
    call insert_list_avaible

    popq %rax #restores return adress

allocate_here_end:
    addq $HEADER_SIZE, %rax #%rax (return) <- usable memory adress

    call insert_list_unavaible
    popq %rbp
    ret

insert_list_unavaible:
    pushq %rax
    subq $HEADER_SIZE, %rax #current position

    movq unavaible_list, %rbx #list begin
    movq heap_begin, %rdx
    cmpq %rdx, %rbx #list is "null"
    je first_time_allocate

    subq $HEADER_SIZE, %rbx #header begin

while_insert_list:
    movq HDR_LIST_OFFSET(%rbx), %rcx #next position
    cmpq %rdx, %rcx #next is "null"
    je insert_at_end
    
    cmpq %rcx, %rax
    je insert_unavaible_end
    jg next_list #if rax > rcx

    #if rax < rcx
    movq %rax, HDR_LIST_OFFSET(%rbx) #rbx.next <- rax
    movq %rcx, HDR_LIST_OFFSET(%rax) #rax.next <- rcx
    jmp insert_unavaible_end

    #list is "null"
    first_time_allocate:
    movq %rdx, HDR_LIST_OFFSET(%rax) #next is "null"
    addq $HEADER_SIZE, %rax #begin memory region
    movq %rax, unavaible_list
    jmp insert_unavaible_end

    #next is "null"
    insert_at_end:
        cmpq %rax, %rbx
        jg insert_before

        #insert after
        movq %rax, HDR_LIST_OFFSET(%rbx) #rbx.next <- rax
        movq %rdx, HDR_LIST_OFFSET(%rax) #rax.next <- "null"
        jmp insert_unavaible_end

        insert_before:
        movq %rbx, HDR_LIST_OFFSET(%rax) #rax.next <- rbx
        cmpq unavaible_list, %rbx #if rbx not is the head of the list
        jne  insert_unavaible_end

        #if rbx is the head of the list
        movq %rax, unavaible_list
        jmp insert_unavaible_end

    next_list:
        movq %rcx, %rbx
        jmp while_insert_list

insert_unavaible_end:
    call remove_avaible_list

    popq %rax
    ret

remove_avaible_list:
    movq avaible_list, %rbx #list begin
    movq heap_begin, %rdx
    cmpq %rdx, %rbx #list is "null"
    je remove_avaible_list_end

    subq $HEADER_SIZE, %rbx
    while_remove_list:
        movq HDR_LIST_OFFSET(%rbx), %rcx #next position
        cmpq %rdx, %rcx #next is "null"
        je remove_avaible_list_end

        cmpq %rax, %rcx
        je remove_list
        movq %rcx, %rbx
        jmp while_remove_list

        remove_list: #rbx.next = rax.next
        movq HDR_LIST_OFFSET(%rax), %rdx #next position
        movq %rdx, HDR_LIST_OFFSET(%rbx)

remove_avaible_list_end:
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

