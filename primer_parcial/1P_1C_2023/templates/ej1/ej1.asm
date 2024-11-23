global agrupar
    extern malloc
    extern realloc
    extern strlen
    extern strcat

;########### SECCION DE DATOS
section .data
    %define OFFSET_MSG_TEXT 0
    %define OFFSET_MSG_TEXT_LEN 8
    %define OFFSET_MSG_TAG 16
    %define MAX_TAG 4
    %define SIZE_POINTER 8

    mask_1: db 0x1

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;char** agrupar_c(msg_t* msgArr, size_t msgArr_len)
;params:
;--> msgArr: [rdi]
;--> msgArr_len: [rsi]
agrupar:
    push rbp
    mov rbp, rsp

    ;preservamos registros no volatiles
    push r15
    push r14

    ;copio rdi y rsi a registros no volatiles para no perderlos
    mov r15, rdi
    mov r14, rsi

    ;pedimos memoria para res :: char**  
    ;; r13 = malloc (rdi=SIZE_POINTER * MAX_TAGS)
    mov qword rdi, SIZE_POINTER * MAX_TAG
    call malloc
    mov r13, rax
    
    ;inicializamos tags
    xor r8, r8
    .init_tags:
        ;comparador
        cmp r8, MAX_TAG
        je .end_init_tags        
        
        ;pedimos memoria para res[i] :: char*
        ;; rax = malloc(1)
        mov rdi, [mask_1] 
        call malloc
        mov [r13 + r8 * SIZE_POINTER], rax
        
        ;res[i] = NULL
        mov qword [rax], 0

        ;iterador
        add r8, 1
        jmp .init_tags

    ;forloop sobre msgArr
    .end_init_tags:

        xor r8, r8
        .loop:
            ;comparador
            cmp r8, r14
            je .end_loop                        

            ;rdx = msgArr[i].tag
            mov byte rdx, [r13 + r8 * SIZE_POINTER + OFFSET_MSG_TAG]

            ; Calcular strlen(res[tag])
            mov rdi, [r13 + rdx * SIZE_POINTER]
            call strlen
            mov rbx, rax ; Guardar la longitud en rbx

            ; Obtener it.text_len
            mov rcx, [r13 + r8 * SIZE_POINTER + OFFSET_MSG_TEXT_LEN]

            ; Sumar las longitudes y agregar 1
            add rbx, rcx
            add rbx, 1

            ; Reasignar memoria para res[tag]
            ;; res[tag] = realloc(res[tag], strlen(res[tag])+it.text_len+1);
            mov rdi, [r13 + r8 * SIZE_POINTER]
            mov rsi, rbx
            call realloc
            mov [r13 + rdx * SIZE_POINTER], rax

            ;res[tag] = strcat(res[tag], it.text);
            mov rdi, [r13 + rdx * SIZE_POINTER]
            mov rsi, [r15 + r8 * SIZE_POINTER + OFFSET_MSG_TEXT]
            call strcat
            mov r12, [r13 + rdx * SIZE_POINTER]
            mov [r12], rax 

            ;iterador
            add r8, 1
            jmp .loop

        .end_loop:
            pop r14
            pop r15

    pop rbp
    ret


