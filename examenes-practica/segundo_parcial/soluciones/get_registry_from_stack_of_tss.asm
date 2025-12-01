section .text
global fuiLlamadaMasVeces
global getUTC

; Prototipo de getUTC
; getUTC:
;   input: task_id en eax
;   output: UTC en eax

getUTC:
    ; Guardar el task_id
    push eax            ; Almacenar task_id en la pila

    ; Obtener la tarea TSS usando getTSS
    ; `sched_tasks` es un array global que debemos tener definido.
    ; sched_tasks[task_id].selector está en [sched_tasks + task_id * tamaño_de_tss]
    ; Llamar a getTSS
    movzx ecx, ax      ; Cargar task_id en ecx (extendiendo a 32 bits si es necesario)
    shl ecx, 2        ; Multiplicar por 4 (suponiendo que cada tss_t ocupa 4 bytes)
    mov ebx, sched_tasks ; Dirección base de sched_tasks
    add ebx, ecx      ; Dirección de sched_tasks[task_id]
    mov ebx, [ebx]    ; Cargar el selector de la tarea

    ; Llamar a getTSS
    push ebx          ; Pasar el selector al stack
    call getTSS
    add esp, 4        ; Limpiar el stack (1 argumento de 4 bytes)

    ; La dirección de tss_task ahora está en eax
    ; Acceder a tss_task->esp
    mov ebx, [eax]    ; Obtener el valor de tss_task (que es un puntero)
    mov eax, [ebx + 24] ; Cargar stack[6], asumiendo que esp está en el offset 24

    pop eax            ; Restaurar task_id
    ret

getTSS:
    ; Guardar el selector
    push eax                    ; Almacenar selector en la pila

    shr eax, 3                                ; selector >> 3
    mov ebx, gdt                              ; Dirección base de la GDT
    mov ebx, [ebx + eax*4]                    ; Cargar el descriptor en ebx
    mov eax, [ebx + BASE_OFFSET]              ; Cargar la base del descriptor en eax

    pop eax                     ; Restaurar el selector (opcional)
    ret

fuiLlamadaMasVeces:
    ; Guardar el valor de task_id
    push eax
    ; Obtener el tiempo UTC actual
    call getUTC
    ; Guardar curr_utc
    mov ebx, eax   ; curr_utc en ebx
    
    ; Inicializar el índice de la tarea
    xor ecx, ecx   ; ecx = i = 0

    .loop:
        ; Comprobar si hemos alcanzado el límite de tareas
        cmp ecx, MAX_TASKS
        jge .end_loop   ; Si i >= MAX_TASKS, salir del bucle

        ; Llamar a getUTC con el índice actual
        push ecx        ; Guardar i en la pila
        push ebx        ; Preservar curr_utc
        call getUTC
        pop ebx         ; Restaurar curr_utc
        pop ecx         ; Restaurar i desde la pila

        ; Comparar curr_utc con el resultado de getUTC
        cmp ebx, eax    ; curr_utc > getUTC(i)
        jg .return_zero ; Si curr_utc > getUTC(i), retornar 0

        ; Incrementar el índice de la tarea
        inc ecx
        jmp .loop       ; Volver al inicio del bucle

    .return_zero:
        mov eax, 0      ; Retornar 0
        pop eax         ; Restaurar task_id
        ret

    .end_loop:
        mov eax, 1      ; Retornar 1
        pop eax         ; Restaurar task_id
        ret

