global templosClasicos
global cuantosTemplosClasicos

extern malloc
extern strcpy
extern strlen

TAM_STRUCT_TEMPLO equ           24
OFFSET_LARGO equ                0
OFFSET_NOMBRE equ               8
OFFSET_CORTO equ                16

;########### SECCION DE TEXTO (PROGRAMA)
section .text

templosClasicos: 
    ; templo *temploArr[rdi],
    ; size_t temploArr_len[rsi]
    
    push rbp
    mov rbp, rsp

    push r12 ; direccion de retorno
    push r13 ; # templos clasicos
    push r14 ; temploArr
    push r15 ; size

    mov r14, rdi ; temploArr
    mov r15, rsi ; size

    ; cuento la # de templos clásicos
    call cuantosTemplosClasicos 
    mov r13, rax 

    ; pido memoria para armar un nuevo array de longitud igual al contador obtenido
    ; malloc(#templosClasicos * TAM_TEMPLO)
    imul r13, TAM_STRUCT_TEMPLO 
    call malloc
    mov r12, rax 

    ; recorro nuevamente la estructura y agrego los templos que son clásicos
    mov rcx, 0 ; i = 0 (itera sobre templeArr)
    mov r8, 0 ; j = 0  (indice en res)
    .loop:
        ; Validamos si terminamos
        cmp rcx, r15
        je .end 
            
        ; Calculamos la dirección base de la estructura actual
        mov rdx, rcx                ; i
        imul rdx, TAM_STRUCT_TEMPLO ; i * TAM_STRUCT_TEMPLO
        add rdx, r14                ; rdx = baseArr + i * TAM_STRUCT_TEMPLO

        ; Cargamos colum_largo (M) y colum_corto (N)
        movzx r11, byte [rdx + OFFSET_LARGO]    ; colum_largo (M)
        movzx r10, byte [rdx + OFFSET_CORTO]    ; colum_corto (N)
        shl r10, 1  ; 2 * colum_corto (2N)
        inc r10     ; 2N + 1

        ; Verificamos si 2N + 1 == M
        cmp r10, r11
        je .add

        .next_iter:
            inc rcx
            jmp .loop
                
    .add:
        ; Calculamos la dirección base de origen (r10)
        mov r10, rcx                  ; índice actual (i)
        imul r10, TAM_STRUCT_TEMPLO   ; i * TAM_STRUCT_TEMPLO
        add r10, r14                  ; baseArr + i * TAM_STRUCT_TEMPLO

        ; Calculamos la dirección base de destino (r11)
        mov r11, r8                   ; índice en el nuevo arreglo (j)
        imul r11, TAM_STRUCT_TEMPLO   ; j * TAM_STRUCT_TEMPLO
        add r11, r12                  ; baseRes + j * TAM_STRUCT_TEMPLO 

        ; Copiamos colum_largo
        movzx rax, byte [r10 + OFFSET_LARGO] ; Cargar colum_largo
        mov [r11 + OFFSET_LARGO], al         ; Guardar en destino

        ; Reservamos memoria para nombre y copiamos su contenido
        mov rax, [r10 + OFFSET_NOMBRE]  ; Dirección del nombre original
        call strlen                     ; Longitud de la cadena
        inc rax                         ; Espacio para '\0'
        call malloc                     ; Reservar memoria
        mov rbx, rax                    ; Guardar la nueva dirección en rbx

        mov rsi, [r10 + OFFSET_NOMBRE]  ; Dirección origen (cadena original)
        mov rdi, rbx                    ; Dirección destino (nueva memoria)
        call strcpy                     ; Copiar cadena
        mov [r11 + OFFSET_NOMBRE], rbx  ; Guardar el nuevo puntero en `tClasicos`

        ; Copiamos colum_corto
        movzx rax, byte [r10 + OFFSET_CORTO] ; Cargar colum_corto
        mov [r11 + OFFSET_CORTO], al         ; Guardar en destino

        ; Incrementamos el índice del nuevo arreglo
        inc r8
        jmp .next_iter

    .end:
        pop r15
        pop r14
        pop r13
        pop r12

        pop rbp
        ret
 
cuantosTemplosClasicos: 
    ; templo* temploArr[rdi],
    ; size_t temploArr_len[rsi]

    ; Prologo
    push rbp
    mov rbp, rsp

    xor eax, eax ; contadorDeTemplosClasicos 

    ; Iteramos por cada templo sumando uno si se cumple la propiedad
    mov rcx, 0 ; i = 0  
    .loop:
        ; Validamos si terminamos
        cmp rcx, rsi
        je .end 
            
        ; Calculamos la dirección base de la estructura actual
        mov rdx, rcx                ; i
        imul rdx, TAM_STRUCT_TEMPLO ; i * TAM_STRUCT_TEMPLO
        add rdx, rdi                ; rdx = baseArr + i * TAM_STRUCT_TEMPLO

        ; Cargamos colum_largo (M) y colum_corto (N)
        movzx r11, byte [rdx + OFFSET_LARGO]    ; colum_largo (M)
        movzx r12, byte [rdx + OFFSET_CORTO]    ; colum_corto (N)
        shl r12, 1  ; 2 * colum_corto (2N)
        inc r12     ; 2N + 1

        ; Verificamos si 2N + 1 == M
        cmp r12, r11
        je .sumar

        .next_iter:
            inc rcx
            jmp .loop
                
    .sumar:
        inc eax
        jmp .next_iter

    .end:
        ; Epilogo
        pop rbp
        ret
