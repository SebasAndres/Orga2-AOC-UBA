global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm
extern malloc 
extern strcmp
extern cant_blacklist


section .data 
%define OFFSET_MONTO 0
%define OFFSET_COMERCIO 8
%define OFFSET_CLIENTE 16
%define OFFSET_APROBADO 17
%define SIZE_STRUCT 24
%define UINT32_SIZE 4
%define SIZE_PUNTERO_A_PAGO 8


;########### SECCION DE TEXTO (PROGRAMA)
section .text

;uint32_t* acumuladoPorCliente_asm(uint8_t cantidadDePagos, pago_t* arr_pagos);
acumuladoPorCliente_asm:
	;rdi <- cantidadDePagos
	;rsi <- arrPagos

	;Prólogo
	push rbp
	mov rbp, rsp

	; Guardo todos los registros no volátiles
	push r15 
	push r14 
	push r13
	push r12
	push rbx 
	sub rsp, 8 ; alinear la pila
	
	; Guardo los parámetros en r15 y r14
	mov r15, rdi ; cantidadDePagos
	mov r14, rsi ; arrayDePagos

	; Pido memoria para armar un arreglo de 10 enteros 32bits (10 * 4)
	mov rdi, 10
	shl rdi, 2
	call malloc
	mov r13, rax

	; Initializo los valores en 0
	mov rcx, 10
	.initialize_res:
		mov dword [r13 + (rcx - 1) * UINT32_SIZE], 0
		dec rcx
		jnz .initialize_res

	; Itero por el array de pagos
	xor rcx, rcx ; i=0
	.loop:
		; Leemos los datos
		movzx r10, byte [r14 + OFFSET_CLIENTE] ; r10=cliente
		movzx r11, byte [r14 + OFFSET_MONTO] ; r11=monto
		movzx r9, byte [r14 + OFFSET_APROBADO]

		; Validamos si es un pago aprobado
		cmp r9, 0
		je .nextIter

		; Pisamos el valor actual (leemos, sumamos y guardamos)
		mov r12, [r13 + r10 * 4] ; leo el monto actual para ese cliente
		add r12, r11 		 ; le sumo el monto nuevo
		mov [r13 + r10*4], r12   ; lo escribo en memoria

		; Iteramos
		.nextIter:
			add r14, SIZE_STRUCT		
			inc rcx
			cmp rcx, r15		
			jne .loop

	; Restauro los registros no volátiles
	add rsp, 8
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15 

	; Epílogo
	pop rbp
	ret

;uint8_t en_blacklist_asm(char* comercio, char** lista_comercios, uint8_t n);
en_blacklist_asm:
    ; rdi = comercio
    ; rsi = listaComercios
    ; rdx = n
    push rbp
    mov rbp, rsp

    ; Guardar registros no volátiles
    push r15 
    push r14 
    push r13
    push r12
    push rbx 
    sub rsp, 8  ; Alinear la pila

    ; Guardar parámetros en registros no volátiles
    mov r15, rdi ; comercioBuscado
    mov r14, rsi ; listaComercios
	mov r13, rdx ; i
	dec r13

    .loop:
		; Leer listaComercios[i]
		mov r10, [r14 + r13 * 8]   

		; Comparar con strcmp(comercioBuscado, comercios[i])
		mov rdi, r10    ; rdi = comercio[i] (puntero)
		mov rsi, r15    ; rsi = comercioBuscado (puntero)
		call strcmp

		cmp eax, 0       ; Si strcmp devuelve 0, las cadenas son iguales
		jne .nextIter   ; Si no son iguales, pasa a la siguiente iteración
		
		mov rax, 1
		jmp .end        ; Si son iguales, salta al final

		.nextIter:
			dec r13         ; Decrementar el índice
			jnz .loop       ; Si rcx != 0, sigue con la siguiente iteración
			
			mov rax, 0

		.end:
			add rsp, 8
			pop rbx
			pop r12
			pop r13
			pop r14
			pop r15 
			pop rbp
			ret


;pago_t** blacklistComercios_asm(
; uint8_t cantidad_pagos,
; pago_t* arr_pagos,
; char** arr_comercios,
; uint8_t size_comercios);
blacklistComercios_asm:
	; rdi = cantidadPagos
	; rsi = arrPagos
	; rdx = arrComercios
	; rcx = sizeComercios

	push rbp
	mov rbp, rsp

	; por el call a strcmp
	push r15 
	push r14 
	push r13
	push r12
	push rbx 
	sub rsp, 8 ; alinear la pila

	; guardo regs no volatiles
	mov r15, rdi ; #pagos
	mov r14, rsi ; arrPagos
	mov r13, rdx ; arrComercios
	mov r12, rcx ; #comercios

	; pido memoria para el res con un malloc(cantidadPagos * sizePointer)
	shl rdi, 3
	call malloc
	mov rbx, rax
	push rax 
	sub rsp, 8

	; inicializamos la estructura poniendo 0s
	mov r8, r15
	.initializeRes:
		mov dword [rbx + 8 * r8], 0
		dec r8
		jnz .initializeRes

	; recorro la estructura de pagos y valido si es de un comercio en la lista
	.loop:

		mov r10, [r14 + OFFSET_COMERCIO] ; arrPagos[i].comercio

		; valido si ese pago está blacklisteado
		mov rdi, r10 ; comercio
		mov rsi, r13 ; listaComercios
		mov rdx, r12 ; |listaComercios|
		call en_blacklist_asm

		cmp al, 1
		jne .nextIter

		; sino, lo agrego a res
		mov [rbx], r14
		add rbx, 8

		.nextIter:
			add r14, SIZE_STRUCT
			dec r15
			jnz .loop

	add rsp, 8
	pop rax

	; recupero regs no volátiles
	add rsp, 8
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15 
	pop rbp
	ret