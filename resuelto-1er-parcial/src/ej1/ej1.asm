extern malloc
extern sleep
extern wakeup
extern create_dir_entry

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
sleep_name: DB "sleep", 0
wakeup_name: DB "wakeup", 0

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - init_fantastruco_dir
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - summon_fantastruco
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24
DIRENTRY_PTR_SIZE EQU 8

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

global init_fantastruco_dir

; void init_fantastruco_dir(fantastruco_t* card);
; r/m64 = fantastruco_t*     card [rdi]
init_fantastruco_dir:
	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r14
	push r15

	mov r12, rdi ; card

    ;card->__dir = malloc(sizeof(directory_entry_t*) * 2);
	mov rdi, DIRENTRY_PTR_SIZE
	shl rdi, 1
	call malloc
	mov qword [r12 + FANTASTRUCO_DIR_OFFSET], qword rax 
	mov r13, rax ; guardo el puntero a la memoria reservada

	;card->__dir[0] = create_dir_entry("sleep", &sleep);
    mov rdi, sleep_name
	mov rsi, sleep
	call create_dir_entry
	mov [r13], rax 
	
	;card->__dir[1] = create_dir_entry("wakeup", &wakeup);
    mov rdi, wakeup_name
	mov rsi, wakeup
	call create_dir_entry
	mov [r13 + DIRENTRY_PTR_SIZE], rax 

	;card->__dir_entries = 2;
	mov word [r12 + FANTASTRUCO_ENTRIES_OFFSET], word 2

	;card->__archetype = NULL;
	mov qword [r12 + FANTASTRUCO_ARCHETYPE_OFFSET], qword 0

    ;card->face_up = 1;
	mov byte [r12 + FANTASTRUCO_FACEUP_OFFSET], byte 1

	pop r15
	pop r14
	pop r13
	pop r12

	pop rbp
	ret 

; fantastruco_t* summon_fantastruco();
global summon_fantastruco
summon_fantastruco:
	push rbp
	mov rbp, rsp

	push r12
	push r13

	mov rdi, FANTASTRUCO_SIZE
	call malloc

	mov r12, rax

	mov rdi, rax
	call init_fantastruco_dir

	mov rax, r12

	pop r13
	pop r12

	pop rbp
	ret 