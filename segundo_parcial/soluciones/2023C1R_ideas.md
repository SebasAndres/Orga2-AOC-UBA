> context switch: cr3
> task switch: regs

IRET Para ISR y RET para normal

## Ejercicio 1

(a)

~~~asm
; isr.asm
global _isr99
_isr99:
    pushad
    call inactive_current_task
    popad 
    ret
~~~

~~~c
// sched.c
void inactive_current_task(void){
	sched_disable_task(currTask);
	force_next_task();
}
~~~

(b)
Podría modificar inactive_current_task:

~~~c
//sched.c

void inactive_current_task(void){
	sched_disable_task(currTask);
	last_task = currTask;
	force_next_task();
	set_in_eax_of_tss(value=last_task, currTask);
}

void set_in_eax_of_kernel_stack(value, task_id){
	// Pone en la pila de la tarea pasada por param el valor
	// value en el offset de eax de la pila de kernel
	tss_t* task_tss = getTSSFromId(task_id);
	*(OFFSET_EAX + task_tss->esp0) = value;
}
~~~

```asm
force_next_task:
	call sched_next_task

	str bx 
	cmp ax, bx
	jne .jmp2next

	.jmp2next:
		mov word [sched_task_sel], ax
		jmp far [sched_task_offset]
		ret
```

(c)
Debería guardar la última tarea que recibió la interrupción en una variable global
(FLAG) y modifico la _isr del clock de la siguiente forma:

~~~c
void inactive_current_task(void){
	sched_disable_task(currTask);
	task_id_that_called_isr97 = currTask;
	force_next_task();
}

void set_in_eax_of_kernel_stack(void){
	// Pone en la pila de la tarea pasada por param el valor
	// value en el offset de eax de la pila de kernel
	tss_t* task_tss = getTSSFromId(currTask);
	*(OFFSET_EAX + task_tss->esp0) = task_id_that_called_isr97;
}
~~~

~~~asm
_isr32:    
    pushad
    
    call pic_finish1
    call next_clock
    
    call sched_next_task
    cmp ax, 0
    je .fin

    str bx
    cmp ax, bx
    je .fin
   
    call set_in_eax_of_kernel_stack

    mov word [sched_task_selector], ax
    jmp far [sched_task_offset]

    .fin:
      call tasks_tick
      call tasks_screen_update
      popad
      iret
~~~

(d)
No. Porque estamos restringiendo el uso que las tareas pueden hacer sobre sus registros
Como alternativa, podemos:

	- Utilizar una página en la region de memoria compartida.
	- Copiar en la pila nivel 3 de la próxima tarea el dato (aumentar esp de la nueva tarea, agregar dato y volverlo a incrementar).

-----------------------------------------------------------------------------------------------------------------------------------

## Ejercicio 2

Intrucción invalida

OBSERVACION:
[ESP] = EIP

(a) Ocurre la excepción #6 - Invalid Opcode Exception

(b) y (c)

	Pila de kernel de la tarea al suceder la ISR (pre pushad)
	----------------------------------
	SS_3
	ESP_3
	EFLAGS
	CS_3     <--- dónde se produjo la isr
	EIP_3    <--- dónde se produjo la isr
	-----------------------------------

(d)

~~~asm

; version #1
global _isr6
_isr6:
	; EIP_3
	mov ecx, [esp] ; leo la dir de la pila
	mov cx, [ecx]  ; obtengo el dato de la pila
	cmp cx, 0x0B0F 
	je .is_RSTLOOP

	; disable currTask
	push DWORD [currTask]
	call sched_disable_task	
	add esp, 4
	jmp (12 << 3): 0 ; Salto a IDLE

	.is_RSTLOOP:
		mov ecx, 0		 ; ecx = 0
		add DWORD [esp], 2 ; eip + 2 (siguiente instrucción de la tarea actual)
		iret

; version #2
global _isr6
_isr6:
	pushad

	; EIP_3
	mov ecx, [esp] ; leo la dir de la pila
	mov cx, [ecx]  ; obtengo el dato de la pila
	cmp cx, 0x0B0F 
	je .is_RSTLOOP

	; disable currTask
	push DWORD [currTask]
	call sched_disable_task	
	add esp, 4
	popad
	;      SS    : offset
	jmp GDT_IDLE_SEL: 0 ; Salto a IDLE

	.is_RSTLOOP:
		mov [esp+OFFSET_ECX], 0		 ; ecx = 0
		add DWORD [esp], 2 ; eip + 2 (siguiente instrucción de la tarea actual)
		popad
		iret
~~~

~~~c
void changeEDX(void){
	tss_t* curr_task_tss = getTSSOfTask(currTask);
	curr_task_tss->edx = 0;
}

tss_t* getTSSOfTask(uint16_t task_id){
	selector = task_o
}
~~~