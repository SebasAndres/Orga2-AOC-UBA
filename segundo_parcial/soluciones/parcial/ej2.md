## Ejercicio 2

Cada tarea guarda en la dir virtual 0xACCE50 (mapeada como r/w) un uint8_t con posibles valores 0,1,2
Para cada tarea:
0: la tarea no accedera al buffer de video
1: accede mediand DMA
2: accede por copia

Syscall OpenDevice:
- Se pide acceso al buffer de video con la syscall openDevice.
- Si accede por copia la dir virtual donde se realiza la copia está dada por el valor del registro ecx al momento de llamar la syscall opendevice.
- Pone la tarea en no ejecutable hasta que se termine de realizar la copia

Cuando la copia se termina se lo indica con la syscall closeDevice:
- Cambia el valor de la dir virtual con 0, 1, 2

Cada vez que el buffer se indique completo: --> IRQ40
La IRQ40:
      - Se debera mapear el buffer a las tareas que utilicen DMA y hayan solilcitado acceso al buffer
      - o actualizar la copua del buffer de las tareas que acceden por copia y hayan solicitado acceso al mismo

Las tareas que acceden por copia que compartan la pagina física (una unica copia, la mem dummy)


~~~asm

_isr40:
      pushad
      call map_buffer_of_requested_tasks
      popad
      iret

~~~

~~~c

uint8_t* tasks_ids_that_require_bufer_dma;
int dma_count
uint8_t* tasks_ids_that_require_bufer_copy 
int copy_count

void initGlobalBufferFLAGS(){
      uint8_t* tasks_ids_that_require_bufer_dma = malloc(MAX_TASKS * sizeof(uint8_t));
      int dma_count = 0;
      uint8_t* tasks_ids_that_require_bufer_copy = malloc(MAX_TASKS * sizeof(uint8_t));
      int copy_count = 0;
      copy_page_virts = malloc(MAX_TASKS * sizeof(uint8_t)); // copyvirts[i] = dir retorno de tarea con id i
}

void map_buffer_of_requested_tasks(void){
      // Recorro todas las tareas y me guardo las que solicitaron el buffer por dma o copia

      // Copio en todas las tareas que lo necesiten por DMA
      for (int i = 0; i < dma_count; i++) {
            buffer_dma(pd=getCR3Task(dma[i])));
      }

      // Copio en todas las tareas que lo necesiten por COPY
      for (int i=0; i< copy_count; i++){
            // la dir virtual donde se ocopia
            virt = getVirtAddressFromTask(count[i]);

            // ejecutar copia
            copy_page_prima(pd=getPDFromVIRT(virt), PHYS_BUFF_VIDEO, virt)
      }
}

getPDFromVirt(virt){
      return VIRT_PAGE_DIR(virt);
}

/*
Donde copy_page_prima mapea la nueva pagina virtual creada a una pagina fija (igual en todas las tareas) en la region de memoria compartida.

*/

~~~


Inhabilitamos la ejecucion de las tareas con la syscall opendevice

OPENDEVICE
~~~asm
_isr97:
      pushad

      push word [CURR_TASK]
      call sched_disable_task
      add esp, 4

      push [0xACC350]
      call set_flag_4_buffer
      add esp, 4

      call force_next_task

      popad
      iret
~~~

~~~c
void set_flag_4_buffer(){
      tipoDeTarea = getValueOf(cr3_from_task(currTask), virt=0xacce50)
      if (tipoTarea == 1) { dma[dma_count] = taskID; dma_count ++}
      else if (tipoTarea == 2) {
            copy[copy_count] = taskId;
            copyCount ++;
            copyPagesVirt = leerDirVirtualDeTarea(taskId)
      }
}

vaddr_t leerDirVIrtualDeTarea(taskID){
      // En registro ecx (pila kernel de tarea offset ecx)
      tss_t* task_tss = getTSS(taskID);
	uint32_t* stack = tss_task->esp;
	return stack[7]; // 24
}
~~~

CLOSEDEVICE
~~~asm
_isr98:
      pushad

	push DWORD [currTask]
	call sched_enable_task	

      popad
      iret
~~~