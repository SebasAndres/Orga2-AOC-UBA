section .data
                    ;r      g      b    a
maskCoefs dq 0.299, 0.587, 0.114, 0

;########### SECCION DE TEXTO (PROGRAMA)
section .text
global miraQueCoincidencia
miraQueCoincidencia:    
    ; uint8_t *A[rdi],
    ; uint8_t *B[rsi],
    ; uint32_t N[rdx], 
    ; uint8_t *laCoincidencia[rcx] )

    ; Prólogo
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15      ; laCoincidencia
    sub rsp, 8    ; Únicamente para realinear la pila a 16bytes

    ; Guardo params en registros no volatiles
    mov r15, rcx 

    ; Calculamos la # iteraciones del ciclo de procesamiento
    imul rdx, rdx ; N^2 (en este caso vamos de a 1 pixel)

    ; Mascaras usadas
    movdqu xmm15, [maskCoefs]

    ; Iteramos 
    .loop:
        cmp rdx, 0
        je .end

        ; Leemos de a 1 pixel (porque tenemos que pasar cada color a 32bits para operar)
        movdqu xmm1, [rdi] ; A
        movdqu xmm2, [rsi] ; B 

        ; Desempaqueto ambos pixeles para que cada componente tenga 32bits
        pmovzxbd xmm1, xmm1 ; todo el xmm1 tiene 4 dwords de 1 mismo pixel
        pmovzxbd xmm2, xmm2 ; todo el xmm2 tiene 4 dwords de 1 mismo pixel
        
        ; Guardamos en xmm4 dwords con 1 y 0 si son = los pixeles
        movdqu xmm4, xmm1 ; para no perder A (en xmm1)
        pcmpeqd xmm4, xmm2 ; devuelve 0xFFFF si son = y 0x0000 si son != en cada dWord  
        psrld xmm4, 31 ; shifteamos para quedarnos con 1 o 0 para hacer la suma

        ; De aca en adelante:
        ;  |-> Si son = --> escala de grises 
        ;  |-> Sino --> 255 

        ; Son iguales si en los dwords rojo, verde y azul la comparación dio 1
        ; (no importa la transparencia)
        phaddd xmm4, xmm4 ; rojoIgual? + verdeIgual? | azulIgual? + alphaIgual?
        phaddd xmm4, xmm4 ; rojoIgual? + verdeIgual? + azulIgual? + alphaIgual? | idem
        pextrd r13d, xmm4, 0 ; extraemos el resultado de la suma a r13d

        mov r8d, 2
        cmp r13d, r8d
        jg .setPixelAsGrey

        ; set pixel as 255        
        mov eax, 0xFFFFFFFF       ; 4 bytes con valor 255
        movd xmm0, eax            ; Mueve 0xFFFFFFFF a xmm0
        movd [r15], xmm0          ; Guardar los 4 bytes (un píxel) en la memoria
        jmp .nextIteration

    .nextIteration:
        add rdi, 4
        add rsi, 4
        add rcx, 4
        dec rdx
        jmp .loop

    .setPixelAsGrey:
        cvtdq2ps xmm2, xmm2 ; a float 
        mulps xmm2, xmm15   ; mul por coeficientes
        haddps xmm2, xmm2   ; sumas horizontales para flotante
        haddps xmm2, xmm2   ; acá estan todos sumados (cada color sigue en 32 bits)

        ; reconvertimos a int32
        cvtps2dq xmm2, xmm2
        
        ; pasamos los floats de 32b saturados a 8 c/u
        packusdw xmm2, xmm2 ; Cada DWORD saturado a un WORD en xmm0
        packuswb xmm2, xmm2 ; Saturar WORDs a BYTES (de 16 bits a 8 bits)

        ; copiamos el dato en res
        movdqu [r15], xmm2        ; Guardar los 4 bytes (un píxel) en la memoria
        
        ; avanzamos
        jmp .nextIteration        

    .end:
        ; Epílogo
        add rsp, 8
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
        ret