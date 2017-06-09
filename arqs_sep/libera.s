.section .text
.globl meuFree
.globl insert_list_avaible

##meuFree##
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

meuFree:
    pushq %rbp
    movq %rsp, %rbp

    movq ST_MEM_SIZE(%rbp), %rax #get the address of the memory to free
    subq $HEADER_SIZE, %rax #get the pointer to the real beginning of the memory
    movq HDR_SIZE_OFFSET(%rax), %rcx #%rcx <- current block size
    movq $AVAILABLE, HDR_AVAIL_OFFSET(%rax) #mark it as available

    call insert_list_avaible
    call free_nodes_fusion

    popq %rbp
    ret
##end meuFree##

insert_list_avaible:
    pushq %rax
    subq $HEADER_SIZE, %rax #current position

    movq avaible_list, %rbx #list begin
    movq heap_begin, %rdx
    cmpq %rdx, %rbx #list is "null"
    je first_time_allocate

    subq $HEADER_SIZE, %rbx #header begin

while_insert_list:
    movq HDR_LIST_OFFSET(%rbx), %rcx #next position
    cmpq %rdx, %rcx #next is "null"
    je insert_at_end
    
    cmpq %rcx, %rax #if rax > rcx
    je insert_avaible_end
    jg next_list

    #if rax < rcx
    movq %rax, HDR_LIST_OFFSET(%rbx) #rbx.next <- rax
    movq %rcx, HDR_LIST_OFFSET(%rax) #rax.next <- rcx
    jmp insert_avaible_end

    #list is "null"
    first_time_allocate:
    movq %rdx, HDR_LIST_OFFSET(%rax) #next is "null"
    addq $HEADER_SIZE, %rax #begin memory region
    movq %rax, avaible_list
    jmp insert_avaible_end

    #next is "null"
    insert_at_end:
        cmpq %rax, %rbx
        jg insert_before

        #insert after
        movq %rax, HDR_LIST_OFFSET(%rbx) #rbx.next <- rax
        movq %rdx, HDR_LIST_OFFSET(%rax) #rax.next <- "null"
        jmp insert_avaible_end

        insert_before:
        movq %rbx, HDR_LIST_OFFSET(%rax) #rax.next <- rbx
        cmpq unavaible_list, %rbx #if rbx not is the head of the list
        jne  insert_avaible_end

        #if rbx is the head of the list
        movq %rax, avaible_list
        jmp insert_avaible_end

    next_list:
        movq %rcx, %rbx
        jmp while_insert_list

insert_avaible_end:
    call remove_unavaible_list

    popq %rax
    ret

remove_unavaible_list:
    movq HDR_SIZE_OFFSET(%rax), %rdi #next position
    movq unavaible_list, %rbx #list begin
    movq heap_begin, %rdx
    cmpq %rdx, %rbx #list is "null"
    je remove_unavaible_list_end

    subq $HEADER_SIZE, %rbx
    while_remove_list:
        movq HDR_LIST_OFFSET(%rbx), %rcx #next position
        cmpq %rdx, %rcx #next is "null"
        je remove_unavaible_list_end

        cmpq %rax, %rcx
        je remove_list
        movq %rcx, %rbx
        jmp while_remove_list

        remove_list: #rbx.next = rax.next
        movq HDR_LIST_OFFSET(%rax), %rdx #next position
        movq %rdx, HDR_LIST_OFFSET(%rbx)

remove_unavaible_list_end:
    ret

free_nodes_fusion:
    movq avaible_list, %rbx #list begin
    movq heap_begin, %rdx
    cmpq %rdx, %rbx #list is "null"
    je fusion_end

    while_fusion:
        movq HDR_SIZE_OFFSET(%rbx), %rsi ######
        movq HDR_LIST_OFFSET(%rbx), %rcx #next position
        cmpq %rdx, %rbx #list is "null"
        je fusion_end

        subq $HEADER_SIZE, %rcx

        movq HDR_SIZE_OFFSET(%rbx), %rdi
        addq %rbx, %rdi

        cmpq %rcx, %rdi #sequencial positions
        je fusion

        movq %rcx, %rbx
        jmp while_fusion

    fusion:
        movq HDR_SIZE_OFFSET(%rcx), %rsi #rbx.size += rcx.size+header
        addq $HEADER_SIZE, %rsi
        addq %rsi, HDR_SIZE_OFFSET(%rbx)
        movq HDR_LIST_OFFSET(%rcx), %rsi # rbx.next = rcx.next
        movq %rsi, HDR_LIST_OFFSET(%rbx)

        jmp while_fusion

fusion_end:
    ret
