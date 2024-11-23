
;directivas preensamblador
%define SIZE_POINTER 8 ; en bytes
%define SIZE_OF_ITEM_T 24 ; en bytes

extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global es_indice_ordenado

; Te recomendamos llenar una tablita acá con cada parámetro y su
; ubicación según la convención de llamada. Prestá atención a qué
; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
;
; r/m64 = item_t**     inventario [rdi]
; r/m64 = uint16_t*    indice	  [rsi]
; r/m16 = uint16_t     tamanio	  [rdx]
; r/m64 = comparador_t comparador [rcx]
es_indice_ordenado:
    push rbp
    mov rbp, rsp

    ; guardamos registros no volatiles xq tenemos un call
	push r15
	push r14
	push r13
	push r12
	push rbx 
	sub rsp, 8 ; alinear la pila

    ; guardamos los params en regs no volatiles
    mov r15, rsi           ; r15 = indice
    mov r14, rdi           ; r14 = inventario
    mov r13, rcx           ; r13 = comparador
    mov r12, rdx           ; r12 = tamaño
    
    xor r8, r8             ; r8 = i
    dec r12                ; tamaño--

    .forloop:
        
        ; Obtener indices (indice tiene uint16_T elementos -> +2 por cada elem)
        movzx r10, word [r15]        ; r10 = indice[i]
        movzx r11, word [r15 + 2]    ; r11 = indice[i+1]

        ; Acceder a elementos en inventario (los punteros miden 8)
        mov rdi, [r14 + r10 * 8] ; rsi = inventario[indice[i]]
        mov rsi, [r14 + r11 * 8] ; rdi = inventario[indice[i+1]]

        ; Llamar al comparador
        call r13               ; ax = comparador(inventario[indice[i]], inventario[indice[i+1]])
        cmp ax, 0                ; ¿comparador() == true?
        je .end         ; Si es true, retornar false

        inc r8                   ; i++
        add r15, 2                  

        cmp r8, r12            ; ¿i >= tamanio - 1?
        je .end

        jmp .forloop


    .end:
        ; recuperamos los registros no volatiles
		add rsp, 8
		pop rbx
		pop r12
		pop r13
		pop r14
		pop r15

        pop rbp
        ret


global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = item_t**  inventario [rdi]
	; r/m64 = uint16_t* indice [rsi]
	; r/m16 = uint16_t  tamanio [rdx]

    push rbp
    mov rbp, rsp

    ; guardamos registros no volatiles xq tenemos un call
	push r15
	push r14
	push r13
	push r12
	push rbx 
	sub rsp, 8 ; alinear la pila

    ; guardamos datos
    mov r15, rdi ; inventario
    mov r14, rsi ; indice
    mov r13, rdx ; tamaño

    ; pedimos memoria para res (tamaño * size_of(item_t*))
    mov rdi, rdx
    imul rdi, 8
    call malloc  ; en eax tenemos la dir de res
    mov r12, rax

    xor r8, r8
    .forloop:
        cmp r8, r13
        je .end

        movzx r10, word [r14 + r8 * 2] ; r10 = indice[i]
        mov r11, [r15 + r10 * 8] ; r11 = inventario[indice[i]]
        mov [r12 + r8 * 8], r11

        inc r8
        jmp .forloop

    .end:
        ; recuperamos los registros no volatiles
		add rsp, 8
		pop rbx
		pop r12
		pop r13
		pop r14
		pop r15

        pop rbp
        ret