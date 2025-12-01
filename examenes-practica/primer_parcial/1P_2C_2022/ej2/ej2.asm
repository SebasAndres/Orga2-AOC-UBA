extern malloc
global filtro

;########### SECCION DE DATOS
section .data
    cleanMask dw 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x00,0x00
    joinerMask db 0,0x80,4,0x80,8,0x80,12,0x80,2,0x80,6,0x80,10,0x80,14,0x80,
                  
;########### SECCION DE TEXTO (PROGRAMA)
section .text

;int16_t* filtro (const int16_t* entrada, unsigned size)
; params:
;   rdi: const int16_t* entrada
;   rsi: unsigned size
filtro:
    ;prologo
    push rbp
    mov rbp, rsp

    ;preservamos los registros no volátiles que vamos a usar
    push r15 ; src
    push r14 ; size
    push r13 ; rax
    sub rsp, 8

    ;guardo rdi en un registro no volátil
    mov r15, rdi 
    mov r14, rsi  
 
    ;pido memoria para el resultado (numDatos * tamañoDatos)
    mov rdi, r14    ;numDatos
    shl rdi, 2      ;*=4
    call malloc  
    mov r13, rax 

    ; son (numDatos - 2) iteraciones
    sub r14, 3

    ; cargo las mascaras
    movdqu xmm15, [cleanMask]
    movdqu xmm14, [joinerMask]

    ;iteramos cada dato
    xor rcx, rcx
    .loop:
        ; vamos a procesar de a 1 dato por iteracion
        movdqu xmm1, [r15] ; r0 l0 | r1 l1 | r2 l2 | r3 l3 
        movdqu xmm3, xmm1 ; copia       

        ; juntamos los canales r1 r2 r3 r4 l1 l2 l3 l4
        pshufb xmm1, xmm14

        ; sumamos todos los rights y todos los words
        ; validar que trunque el resultado
        phaddw xmm1, xmm1
        phaddw xmm1, xmm1        

        ; dividimos el resultado de la suma por 4
        psraw xmm1, 2

        ; escribimos el dato (32bits) en res
        movd [r13], xmm1

        ;iteramos
        add r15, 4 ; dato
        add r13, 4 ; res
        inc rcx
        cmp rcx, r14
        je .end

    .end:
        ; Últimos 3 elementos (procesados manualmente)
        movdqu xmm1, [r15]         ; Cargar 16 bytes (4 valores de 32 bits: r0l0 | r1l1 | r2l2 | basura)
        pand xmm1, xmm15           ; Aplicar máscara para limpiar (dejar r0l0 | r1l1 | r2l2 | 00 00)

        ; Cálculo del dato final (posición size - 1)
        mov r11d, dword [r15 + 8]   ; Cargar r2l2 (32 bits)
        shr r11d, 2                 ; Dividir el resultado por 4
        mov dword [r13 + 8], r11d   ; Guardar en la salida (32 bits)

        ; Cálculo del anteúltimo dato (posición size - 2)
        mov r11d, dword [r15 + 4]   ; Cargar r1l1 (32 bits)
        shr r11d, 2                 ; Dividir el resultado por 4
        add r11d, dword [r13 + 8]   ; Sumar con el dato siguiente
        mov dword [r13 + 4], r11d  ; Guardar en la salida (32 bits)

        ; Cálculo del primer dato (posición size - 3)
        mov r11d, dword [r15]       ; Cargar r0l0 (32 bits)
        shr r11d, 2                 ; Dividir el resultado por 4
        add r11d, dword [r13 + 4]   ; Sumar con el dato siguiente
        mov dword [r13], r11d       ; Guardar en la salida (32 bits)
        
        ;recuperamos los registros no volátiles pre-llamada
        add rsp, 8
        pop r13
        pop r14
        pop r15

        ;epilogo
        pop rbp
        ret