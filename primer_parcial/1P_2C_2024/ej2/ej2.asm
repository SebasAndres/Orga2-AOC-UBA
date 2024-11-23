section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el filtro
ALIGN 16
	todos128: times 8 dw 128
	todos0: times 8 dw 0
	mask_ammount: times 8 db 0x00, 0x0F 
	mask_alpha: times 4 db 0x00, 0x00, 0x00, 0xFF
    	mask_ej2b: db 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x02, 0x03, 0x03, 0x03, 0x03
	mask_shuffle_b: db 0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3 	; cuadriplicamos los valores en mask
	
section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 2A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2a
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 2B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2b
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 2C (opcional) como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2c
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
; provista.
;
; Parámetros:
;   - dst:    La imagen destino. Es RGBA (8 bits sin signo por canal).
;   - src:    La imagen origen. Es RGBA (8 bits sin signo por canal).
;   - width:  El ancho en píxeles de `dst`, `src` y `mask`.
;   - height: El alto en píxeles de `dst`, `src` y `mask`.
;   - amount: El nivel de intensidad a aplicar.
global ej2a
ej2a:
	; r/m64 = rgba_t*  dst [rdi]
	; r/m64 = rgba_t*  src [rsi]
	; r/m32 = uint32_t width [rdx]
	; r/m32 = uint32_t height [rcx]
	; r/m8  = uint8_t  amount [r8]

	;prologo
	push rbp
	mov rbp, rsp

	;# iteraciones = totalPixeles / pixelPorIteracion = width * height / 4
	xor r9, r9 
	mov r10, rdx 
	imul r10, rcx
	shr r10, 2 

	;cargo las mascaras
	movdqu xmm13, [todos128] ; 8 words con el valor 128
	movdqu xmm12, [mask_shuffle_b] ; cuadriplicamos los valores en mask

	; ammount a xmm4 (8 words con el valor de amount)
	movdqu xmm3, [mask_ammount] 
	movzx eax, r8b        
	movd xmm4, eax       
	pshufb xmm4, xmm3 

	.ciclo:
		; leo los 4 pixeles de src
		movdqu xmm5, [rsi]

		; paso de 8bits a 16bits
		movdqu xmm6, xmm5
		pxor xmm0, xmm0
		punpcklbw xmm5, xmm0
		punpckhbw xmm6, xmm0

		; resto 128 a cada componente de los 4 pixeles
		psubw xmm5, xmm13
		psubw xmm6, xmm13

		; multiplico por amount
		pmullw xmm5, xmm4
		pmullw xmm6, xmm4

		; divido por 32
		psraw xmm5, 5
		psraw xmm6, 5

		; sumo 128
		paddw xmm5, xmm13
		paddw xmm6, xmm13

		; paso los valores a 8 bits
		packuswb xmm5, xmm6		

		; ponemos 255 en transparencia
		movdqu xmm2, [mask_alpha]
		por xmm5, xmm2

		; escribimos en dest
		movdqu [rdi], xmm5

		; chequeo si termino
		add r9, 1
		cmp r9, r10
		je .fin	

		;avanzamos a los proximos 4 pixeles
		add rsi, 16
		add rdi, 16
		jmp .ciclo

	.fin:
		;epilogo
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

	;prologo
	push rbp
	mov rbp, rsp

	;# iteraciones = totalPixeles / pixelPorIteracion = width * height / 4
	mov r10, rdx 
	imul r10, rcx
	shr r10, 2 

	;cargo las mascaras
	movdqu xmm13, [todos128] ; 8 words con el valor 128
	movdqu xmm9, [mask_ej2b]
	movdqu xmm11, [mask_alpha]

	; ammount a xmm4 (8 words con el valor de amount)
	movdqu xmm3, [mask_ammount] 
	movzx eax, r8b        
	movd xmm4, eax       
	pshufb xmm4, xmm3 

	.ciclo:
		; leo los 4 pixeles de src
		movdqu xmm5, [rsi]
		movdqa xmm10, xmm5

		; paso de 8bits a 16bits
		movdqu xmm6, xmm5
		pxor xmm0, xmm0
		punpcklbw xmm5, xmm0
		punpckhbw xmm6, xmm0

		; resto 128 a cada componente de los 4 pixeles
		psubw xmm5, xmm13
		psubw xmm6, xmm13

		; multiplico por amount
		pmullw xmm5, xmm4
		pmullw xmm6, xmm4

		; divido por 32
		psraw xmm5, 5
		psraw xmm6, 5

		; sumo 128
		paddw xmm5, xmm13
		paddw xmm6, xmm13

		; paso los valores a 8 bits
		packuswb xmm5, xmm6		

		; ponemos 255 en transparencia
		por xmm5, xmm11

		; aplicamos la mascara
		movdqu xmm15, [r9] ; leemos mascara
		pshufb xmm15, xmm9 ;  
		pand xmm5, xmm15   ; ponemos 0 en los valores de los pixeles no marcados en la mascara de xmm5	
						   ; en los marcados ponemos el valor modificado
		pandn xmm15, xmm10 ; a la imagen original le ponemos 0 a los pixeles marcados
		por xmm5, xmm15	   ; juntamos las imagenes

		; escribimos en dest el resultado
		movdqu [rdi], xmm5

		; chequeo si termino
		sub r10, 1
		cmp r10, 0
		je .fin	

		; avanzamos la mascara
		add r9, 4

		;avanzamos a los proximos 4 pixeles
		add rsi, 16
		add rdi, 16
		jmp .ciclo

	.fin:
		;epilogo
		pop rbp
		ret

; [IMPLEMENTACIÓN OPCIONAL]
; El enunciado sólo solicita "la idea" de este ejercicio.
;
; Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
; provista.
;
; Parámetros:
;   - dst:     La imagen destino. Es RGBA (8 bits sin signo por canal).
;   - src:     La imagen origen. Es RGBA (8 bits sin signo por canal).
;   - width:   El ancho en píxeles de `dst`, `src` y `mask`.
;   - height:  El alto en píxeles de `dst`, `src` y `mask`.
;   - control: Una imagen que que regula el nivel de intensidad del filtro en
;              cada píxel. Es en escala de grises a 8 bits por canal.
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
