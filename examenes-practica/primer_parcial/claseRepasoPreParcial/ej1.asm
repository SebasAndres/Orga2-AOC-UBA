; /** defines bool y puntero **/
    %define NULL 0
    %define TRUE 1
    %define FALSE 0

section .data
    %define LIST_SIZE 16
    %define LIST_FIRST 0
    %define LIST_LAST 8
    %define NODE_SIZE 32
    %define NODE_NEXT 0
    %define NODE_PREV 8
    %define NODE_TYPE 16
    %define NODE_HASH 24

section .text
    global string_proc_list_create_asm
    global string_proc_node_create_asm
    global string_proc_list_add_node_asm
    global string_proc_list_concat_asm

    ; FUNCIONES auxiliares que pueden llegar a necesitar:
    extern malloc
    extern free
    extern str_concat

    ; string_proc_list* string_proc_list_create(void)
    string_proc_list_create_asm:
        push rbp
        mov rbp, rsp ; prologo + alinear
        
        mov rdi, STRUCT_SIZE_LIST ; 16
        call malloc
        
        mov qword [rax + OFFSET_LIST_FIRST], 0 ; res.first = NULL
        mov qword [rax + OFFSET_LIST_LAST], 0  ; res.last = NULL
        
        pop rbp ; epilogo
        ret

    ;string_proc_node* string_proc_node_create_asm(uint8_t type, char* hash)
    ;params:
    ;  dil=type,
    ;  rsi=hash
    string_proc_node_create_asm:
        push rbp
        mov rbp, rsp ; prologo + alinear
       
        push rdi
        push rsi
        mov rdi, STRUCT_SIZE_NODE
        call malloc
        pop rsi
        pop rdi
        
        mov qword [rax + OFFSET_NODE_NEXT], 0 ; new_node->next = NULL
        mov qword [rax + OFFSET_NODE_PREVIOUS], 0 ; new_node->prev = NULL
        
        mov [rax + OFFSET_NODE_TYPE], dil ; new_node->type = type
        mov [rax + OFFSET_NODE_HASH], rsi ; new_node->hash = hash
        
        pop rbp ; epilogo
        ret
    
    ;void string_proc_list_add_node_asm(string_proc_list* list, uint8_t type, char* hash);
    ;params:
    ;   rdi: string_proc_list* list
    ;   rsi: uint8_t type
    ;   rdx: char* hash
    string_proc_list_add_node_asm:
        push rbp
        mov rbp, rsp
        
        sub rsp, 16 ;por??

        ; creamos el nodo nuevo
        push rdi
        push rsi
        mov rdi, rsi
        mov rsi, rdx
        call string_proc_node_create_asm
        pop rsi
        pop rdi

        mov r8, [rdi + LIST_FIRST] ; r8 = list->first
        mov [rdi + OFFSET_LIST_LAST], rax ; list->last = new_node

        cmp r8, 0 ; if list->first == NULL
        jne .not_first_node ; else
        jmp .end 

        .not_first_node:
            mov r9, [rdi + LIST_LAST]   ; r9 = list->last
            mov [r9 + NODE_NEXT], rax   ; r9->next = new_node
            mov [rax + NODE_PREV], r9   ; new_node->prev = r9 
            mov [rdi + LIST_LAST], rax  ; list->last = new_node

        .end:
            add rsp, 16
            pop rbp
            ret

    ; char* string_proc_list_concat_asm(string_proc_list* list, uint8_t type, char* hash);
    ;params:
    ;   rdi: string_proc_list* list
    ;   rsi: uint8_t type
    ;   rdx: char* hash
    string_proc_list_concat_asm:
        push rbp
        mov rbp, rsp

        mov r8, [rdi + LIST_FIRST] ; r8 = list->first
        cmp r8, 0 ; if list->first == NULL
        je .end

        .for:
            cmp [r8 + NODE_TYPE], rsi ; if r8->type == type
            je .concat_hash
 
            mov r8, [r8 + NODE_NEXT] ; r8 = r8->next
            cmp r8, 0 ; if r8 == NULL
            je .end
            jne .for

        .concat_hash:
            mov rdi, [r8 + NODE_HASH] ; rdi = r8->hash
            mov rsi, rdx 
            call str_concat
            mov rdx, rax ; rdx = str_concat(r8->hash, hash)

        .end:
            pop rbp
            ret
        