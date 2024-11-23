extern malloc
global filtro

;########### SECCION DE DATOS
section .data
    mask_shufb: times 2 db 0,1,4,5,8,9,12,13,2,3,6,7,10,11,14,15

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
    push r15
    push r14

    ;guardo rdi en un registro no volátil
    mov r15, rdi
    mov r14, rsi

    ;pedimos memoria para res :: int16_t*
    mov rdi, rsi
    sub rdi, 3
    sal rdi, 2
    call malloc
    mov r8, rax

    ;calculamos la cantidad de pasadas
    mov rcx, r14
    sub rcx, 3

    ;cargamos en xmm1 la mascara del shuffle
    movdqu xmm1, [mask_shufb]

    ;iteramos sobre los chunks    
    .process_head:
        ;cargamos el chunk
        movdqu xmm0, [r15]

        ;shuffle L1 | L2 | L3 | L4 | R1 | R2 | R3 | R4
        ;cada x_i es un int16_t
        pshufb xmm0, xmm1

        ;dividimos por 4
        psraw xmm0, 2

        ;horizontal adds saturado
        phaddsw xmm0, xmm0
        phaddsw xmm0, xmm0 
        ;xmm0 queda con YL1 | YR1 repetido 8 veces (c/u en 16bits)        

        ;guardamos en res
        movd [r8], xmm0

        add r8, 4 ;como escribimos 2 words -> res = res + 4 bytes
        add r15, 16 ;como leemos 8 words -> entrada = entrada + 16 bytes
        loop .process_head

    ;recuperamos los registros no volátiles pre-llamada
    pop r14
    pop r15

    ;epilogo
    pop rbp
