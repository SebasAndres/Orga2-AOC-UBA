.section .data 
    ;bgra
    maskAlpha: times 4 db 0x00, 0x00, 0x00, 0xFF
    maskBlend1: times 4 db 0x00, 0x00, 0x80, 0x00
    maskBlend2: times 4 db 0x00, 0x80, 0x00, 0x80    

    suffle_img2: db 0x02, 0x01, 0x00, 0x03, 0x06, 0x05, 0x04, 0x07, 0x0A, 0x09, 0x08, 0x0B, 0x0E, 0x0D, 0x0C, 0x0F

.section .text

    combinarImagenes_asm:
        push rbp
        mov rbp, rsp
        mov r10, rdx 

        mov eax, r8d
        mul ecx
        shr eax, 2
        mov r8d, eax ; r8 = width * height / 4

        xor rax, rax
        movdqa xmm7, [maskAlpha]
        movdqa xmm8, [todos128]
        movdqu xmm9, [shuffle_img2]

        .ciclo 
            movdqu xmm1, [rdi+rax]
            movdqu xmm2, [rsi+rax]

            ;shuffle para tratar datos facilmente
            pshufb xmm2, xmm9

            ;blue
            movdqu xmm3, xmm1
            paddusb xmm3, xmm2

            ;green
            movdqu xmm4, xmm1
            movdqu xmm0, xmm1
            movdqu xmm6, xmm1
            pavgb xmm4, xmm2
            movdqa xmm5, xmm2
            paddb xmm5, xmm8
            paddb xmm0, xmm8
            pcmpgtb xmm0, xmm5
            pblendvb xmm4, xmm6

            ;red
            movdqu xmm5, xmm2
            psubusb xmm5, xmm1

            ;merge componentes
            movdqa xmm0, [maskblend1]
            pblendvb xmm3, xmm4

            movdqa xmm0, [maskblend2]
            pblendvb xmm3, xmm5

            por xmm4, xmm7
            movdqu [r10+rax], xmm3

            add rax, 16
            dec r8w
            jnz .ciclo

        pop rbp
        ret 