extern strcmp
global invocar_habilidad

; Completar las definiciones o borrarlas (en este ejercicio NO serán revisadas por el ABI enforcer)
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24
DIRENTRY_PTR_SIZE EQU 8


FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

ABILITY_NAME_OFFSET EQU 0
ABILITY_PTR_OFFSET EQU 16
ABILITY_ENTRY_SIZE EQU 24

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text

; void invocar_habilidad(void* carta, char* habilidad);
	; r/m64 = void*    card [rdi]; Vale asumir que card siempre es al menos un card_t*
	; r/m64 = char*    habilidad [rsi]
invocar_habilidad:
	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8

	mov r12, rdi ; carta
	mov r13, rsi ; habilidad

	;if (carta == NULL) {return;}
	cmp r12, 0
	je .end

	;uint16_t num_card_abilities = carta->__dir_entries;
	xor rbx, rbx
	mov bx, word [r12 + FANTASTRUCO_ENTRIES_OFFSET]

	xor r14, r14 ; i = 0
	.forloop:
		cmp r14w, bx
		je .all_card_dir_entries_checked

		;directory_entry_t* ability_entry_ptr = carta->__dir[i];
		mov r10, [r12 + FANTASTRUCO_DIR_OFFSET]
		mov r15, [r10 + r14 * 8] ; cada elemento de dir es un puntero (8bytes) 

		mov rdi, r15; ability_name;
		mov rsi, r13 ; habilidad
		call strcmp 

		cmp eax, 0
		je .found

		; sigo iterando
		inc r14	
		cmp r14w, bx
		jne .forloop


	.all_card_dir_entries_checked:
	; caso no encontré la habilidad
	mov rdi, qword [r12 + FANTASTRUCO_ARCHETYPE_OFFSET]
	mov rsi, r13
	call invocar_habilidad

	.end:
		add rsp, 8
		pop rbx
		pop r15
		pop r14
		pop r13
		pop r12

		pop rbp
		ret 

	.found:
		mov r10, qword [r15 + ABILITY_PTR_OFFSET]
		mov rdi, r12
		call r10
		jmp .end