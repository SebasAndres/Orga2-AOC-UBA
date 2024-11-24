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

    mask1: db 0x1

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;char** agrupar_c(msg_t* msgArr, size_t msgArr_len)
;params:
;--> msgArr: [rdi]
;--> msgArr_len: [rsi]
agrupar:
    ; prologo
    push rbp 
    mov rbp, rsp

    ; como hacemos un malloc -> pusheamos todos los regs no volatiles
    push r15 ; msgArr
	push r14 ; msgArrLen
	push r13 ; retorno
	push r12 ; tag actual
	push rbx  ; indice en msgArr
	sub rsp, 8 ; alinear la pila

    ; guardo en registros no volatiles los parametros
    mov r15, rdi ; msg_t* msgArr
    mov r14, rsi ; size_t msgArr_len

    ; pedimos memoria para el resultado final (MAX_TAG*sizePointer)
    mov qword rdi, SIZE_POINTER * MAX_TAG    
    call malloc
    mov r13, rax ; direccion de memoria a retornar

    ; inicializamos los tags    
    ; foreach tag: { res[tag] = malloc(SIZE_POINTER) }
    mov rcx, MAX_TAG
    .loop:
        mov rdi, [mask1]
        call malloc
        mov [r15 + rbx * SIZE_POINTER], rax
        mov qword [rax], 0              ; res[i] = \n = NULL

    ; recorremos msgArr y agregamos en res segun el tag
    xor rbx, rbx ; i de msgArr
    .add_msg_loop:

        ; validación
        cmp rbx, rsi
        je .end

        ; leemos el tag del mensaje actual
        movzx r12, byte [r15 + rbx*SIZE_POINTER + OFFSET_MSG_TAG] 

        ; necesitamos hacer un realloc de res[tag] para agregar las palabras nuevas 

        ; (1) para esto necesito primero la longitud actual strlen(res[tag])
        mov rdi, [r13 + r12 * SIZE_POINTER]         
        call strlen 
        mov r11, rax   ; r11 = strlen(res[tag])

        ; (2)hacemos la suma 
        ; r11 = strlen(res[tag]) + msgArr[i].len + 1
        mov r10, [r15 + rbx*SIZE_POINTER + OFFSET_MSG_TEXT_LEN] ; msgArr[i].len
        add r11, r10 ; strlen(res[tag]) + msgArr[i].len 
        inc r11 ; +1 

        ; (3) llamamos al realloc(res[tag], strlen(res[tag])+msgArr[i].len+1)
        mov rdi, [r13 + r12 * SIZE_POINTER]
        mov rsi, r11
        call realloc
        
        ; (4) guardamos en res[tag] la nueva dir de memoria
        mov [r13 + r12 * SIZE_POINTER], rax

        ; concatenamos en la nueva direccion los dos textos
        ; res[tag] = strcat(res[tag], it.text);
        mov rdi, [r13 + r12 * SIZE_POINTER]
        mov rsi, [r15 + rbx * SIZE_POINTER + OFFSET_MSG_TEXT] ; texto del mensaje
        call strcat

        ; copiamos en la direccion de memoria en res[tag] el puntero a los string concatenados        
        mov r11, [r13 + r12 * SIZE_POINTER]
        mov [r11], rax 

        ; siguiente iteracion
        inc rbx
        jmp .add_msg_loop

    .end:
        ; recuperar regs no volátiles
        add rsp, 8
        pop rbx
        pop r12
        pop r13
        pop r14
        pop r15

        ; epilogo
        pop rbp
        ret
