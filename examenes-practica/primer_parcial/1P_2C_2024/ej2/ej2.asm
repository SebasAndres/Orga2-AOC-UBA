section .rodata
	; Acá se pueden poner todas las máscaras y datos que necesiten para el filtro
	ALIGN 16
	maskContraste times 8 db 0x00, 0xFF ; En el byte 00 está el dato, el resto de bytes de xmm1 tiene 0
	mask128 times 8 dw 128
	maskAlpha times 4 db 0,0,0,255

section .text

FALSE EQU 0 ; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
TRUE  EQU 1 ; Marca un ejercicio como hecho

global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

global ej2a
ej2a:
	; r/m64 = rgba_t*  dst [rdi]
	; r/m64 = rgba_t*  src [rsi]
	; r/m32 = uint32_t width [rdx]
	; r/m32 = uint32_t height [rcx]
	; r/m8  = uint8_t  amount [r8]

	; Prologo
	push rbp
	mov rbp, rsp

	; # Iteraciones = totalPixeles / pixelPorIteracion = width * height / 4
	mov r10, rdx 
	imul r10, rcx
	shr r10, 2 

	; Mascaras
	; XMM4 <-- Mask 128
	; XMM6 <-- Mask 255
	movdqu xmm4, [mask128]
	movdqu xmm6, [maskAlpha]

	; Pasamos el contraste a 8 words en un xmm
	; XMM1 <-- Contraste
	movdqu xmm0, [maskContraste] 
	movzx eax, r8b        
	movd xmm1, eax       
	pshufb xmm1, xmm0

	; Loop
	xor r9, r9 ; i
	.loop:			
		; Leemos los 4 pixeles
		movdqu xmm2, [rsi] ; tengo los 4 pixeles acá 

		; Distribuyo en dos XMM los 4 pixeles de la iteracion (xmm2, xmm3)
		movdqu xmm3, xmm2
		pxor xmm0, xmm0
		punpcklbw xmm2, xmm0
		punpckhbw xmm3, xmm0

		; Restamos 128 en cada color (como word)
		psubw xmm2, xmm4
		psubw xmm3, xmm4

		; Multiplicamos por C
		pmullw xmm2, xmm1
		pmullw xmm3, xmm1

		; Dividimos por 32
		psraw xmm2, 5
		psraw xmm3, 5

		; Sumamos 128 a cada word
		paddw xmm2, xmm4
		paddw xmm3, xmm4

		; Saturamos y reconvertimos a bytes
		packuswb xmm2, xmm3

		; Ponemos 255 en transparencia
		por xmm2, xmm6

		; Guardamos el dato en res
		movdqu [rdi], xmm2

		; Validamos si terminó
		inc r9
		cmp r9, r10
		je .end
		
		; Iteramos
		add rdi, 16
		add rsi, 16
		jmp .loop

	.end:
		; Epilogo
		pop rbp
		ret


global ej2b
ej2b:
	; r/m64 = rgba_t*  dst [rdi]
	; r/m64 = rgba_t*  src [rsi]
	; r/m32 = uint32_t width [rdx]
	; r/m32 = uint32_t height [rcx]
	; r/m8  = uint8_t  amount [r8]
	; r/m64 = uint8_t* mask [r9]

	; Prologo
	push rbp
	mov rbp, rsp

	; # Iteraciones = totalPixeles / pixelPorIteracion = width * height / 4
	mov r10, rdx 
	imul r10, rcx
	shr r10, 2 

	; Mascaras
	; XMM4 <-- Mask 128
	; XMM6 <-- Mask 255
	movdqu xmm4, [mask128]
	movdqu xmm6, [maskAlpha]

	; Pasamos el contraste a 8 words en un xmm
	; XMM1 <-- Contraste
	movdqu xmm0, [maskContraste] 
	movzx eax, r8b        
	movd xmm1, eax       
	pshufb xmm1, xmm0

	; Loop
	xor r11, r11 ; i
	.loop:			
		; Leemos los 4 pixeles
		movdqu xmm2, [rsi] ; tengo los 4 pixeles acá 
		movdqu xmm5, xmm2 ; Copia imagen original

		; Distribuyo en dos XMM los 4 pixeles de la iteracion (xmm2, xmm3)
		movdqu xmm3, xmm2
		pxor xmm0, xmm0
		punpcklbw xmm2, xmm0
		punpckhbw xmm3, xmm0

		; Restamos 128 en cada color (como word)
		psubw xmm2, xmm4
		psubw xmm3, xmm4

		; Multiplicamos por C
		pmullw xmm2, xmm1
		pmullw xmm3, xmm1

		; Dividimos por 32
		psraw xmm2, 5
		psraw xmm3, 5

		; Sumamos 128 a cada word
		paddw xmm2, xmm4
		paddw xmm3, xmm4

		; Saturamos y reconvertimos a bytes
		packuswb xmm2, xmm3

		; Ponemos 255 en transparencia
		por xmm2, xmm6

		; Validamos si hay que aplicar el filtro o no
		movdqu xmm7, [r9] ; aca tengo mask de 16 pixeles, pero yo proceso de a 4
		pmovzxbd xmm7, xmm7
		pslld xmm7, 31
		psrad xmm7, 31 ; xmm7 tiene una dword con 0 si no hay que aplicarlo, sino 0xFFFFFFFF

		pand xmm2, xmm7 ; En el filtro ponemos en 0 los pixeles que no deben ser modificados		
		; xmm7 = ~xmm7 & xmm5 
		pandn xmm7, xmm5 ; En la original ponemos 0 los pixeles que deben quedar como el filtro
					
		; Juntamos la imagen original con la del filtro
		por xmm2, xmm7

		; Guardamos el dato en res
		movdqu [rdi], xmm2

		; Validamos si terminó
		inc r11
		cmp r11, r10
		je .end
		
		; Iteramos
		add rdi, 16
		add rsi, 16
		add r9, 4		; mask
		jmp .loop

	.end:
		; Epilogo
		pop rbp
		ret

; [IMPLEMENTACIÓN OPCIONAL]
global ej2c
ej2c:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = rgba_t*  dst
	; r/m64 = rgba_t*  src
	; r/m32 = uint32_t width
	; r/m32 = uint32_t height
	; r/m64 = uint8_t* control

	ret
