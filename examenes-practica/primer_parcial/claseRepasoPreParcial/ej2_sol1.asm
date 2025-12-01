.section .data
    ;este está en formato bgra 
    mask_red: times 4 db 0x00, 0x00, 0xFF, 0x00
    mask_green: times 4 db 0x00, 0xFF, 0x00, 0x00
    mask_blue: times 4 db 0xFF, 0x00, 0x00, 0x00
    mask_alpha: times 4 db 0x00, 0x00, 0x00, 0xFF

    mask_todos128: times 16 db 128

.section .text

    ;void combinar_imagenes(uint8_t *src1, uint8_t *src2, uint8_t *dst, uint32_t width, uint32_t height);
    ;params
    ;   rdi: uint8_t *src1
    ;   rsi: uint8_t *src2
    ;   rdx: uint8_t *dst
    ;   rcx: uint32_t width
    ;   r8: uint32_t height
    combinar_imagenes:
        ;prologo
        push rbp
        mov rbp, rsp

        ;guardamos los registros no volatiles para usarlos ;)
        push r12
        push r13
        push r14
        push r15

        ;cantidad de iteraciones
        ;r12 = width * height / 4
        ;r13 = 0
        xor r13, r13
        mov r12, rcx
        imul r12, r8
        shr r12, 2

        ;iterador
        .process_chunk:
            ;comparador
            cmp r13, r12            
            je .end_process_chunk

            ;cargamos los valores de src1 y src2
            movdqu xmm0, [rdi + r13 * 16]
            movdqu xmm1, [rsi + r13 * 16]

            ;blue
            movdqu xmm3, xmm0 ;xmm3 = A
            movdqu xmm4, xmm1 ;xmm4 = B
            pand xmm3, [mask_blue] ;xmm3 = A[blue]      | 0x00 | 0x00   | 0x00
            pand xmm4, [mask_red]  ;xmm4 = 0x00         | 0x00 | B[red] | 0x00
            pslld xmm4, 16         ;xmm4 = B[red]       | 0x00 | 0x00   | 0x00
            paddusb xmm3, xmm4 ;xmm3 = A[blue] + B[red] | 0x00 | 0x00   | 0x00
            
            ;red
            movdqu xmm4, xmm0 ;xmm4 = A
            movdqu xmm5, xmm1 ;xmm5 = B
            pand xmm4, [mask_red]  ;xmm4 = 0x00      | 0x00             | A[red]           | 0x00
            pand xmm5, [mask_blue] ;xmm5 = B[blue]   | 0x00             | 0x00             | 0x00
            psrld xmm5, 16         ;xmm5 = 0x00      | 0x00             | B[blue]          | 0x00 
            psubusb xmm5, xmm4     ;xmm5 = 0x00      | 0x00             | B[blue] - A[red] | 0x00
            por xmm3, xmm5 ;xmm3 =  A[blue] + B[red] | 0x00             | B[blue] - A[red] | 0x00

            ;green
            movdqu xmm4, xmm0 ;xmm4 = A
            movdqu xmm5, xmm0 ;xmm5 = A
            movdqu xmm6, xmm1 ;xmm6 = B
            movdqu xmm7, xmm0
            ;avg
            pavgb xmm4, xmm1  ;xmm4 = avg(A,B)            
            ;resta
            psubusb xmm5, xmm1 ;xmm5 = A - B
            ;sumamos 128 para que funcione el greater than signado
            paddusb xmm7, [mask_todos128]
            paddusb xmm6, [mask_todos128]           
            pcmpgtb xmm7, xmm6 

            ;xmm4 = A > B ? A : avg(A,B)
            pblendvb xmm4, xmm5, xmm7 

            ;guardamos el resultado en dst
            movdqu [rdx + r13 * 16], xmm3

            ;iterador
            add r13, 1
            jmp .process_chunk

        ;recuperamos los registros no volatiles
        pop r15
        pop r14
        pop r13
        pop r12

        ;epilogo
        pop rbp
        ret