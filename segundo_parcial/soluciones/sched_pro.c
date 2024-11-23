// YA esta
int8_t current_task = 0;

// NUEVO
int8_t last_task_priority = 0;
int8_t last_task_no_priority = 0;

uint16_t sched_next_task(void) {

  // Devuelve el selector de la próxima tarea a ejecutar.

  int8_t i;

  // Buscamos la prox tarea viva con prioridad
  for ( i = last_task_priority + 1;
        i%MAX_TASKS != last_task_priority; // termina la ronda
        i++ ){

    if (sched_tasks[i%MAX_TASKS].state == TASK_RUNNABLE & esPrioritaria(i))
      break;      
  }

  // Ajustamos i para que esté entre 0 y MAX_TASKS-1
  i = i % MAX_TASKS;
  if (i != current_task){
    // Hay mas de una tarea prioritaria viva o la ultima tarea 
    // ejecutada fue sin prioridad
    last_task_priority = i;
    current_task = i;
    return sched_tasks[i].selector;
  }

  // Buscamos una tarea no prioritaria
  for ( i = last_task_no_priority + 1;
        i%MAX_TASKS != last_task_no_priority; // termina la ronda
        i++ ){

    // no hace falta validar que no sea prioritaria
    if (sched_tasks[i%MAX_TASKS].state == TASK_RUNNABLE) 
      break;      
  }

  // Ajustamos i para que esté entre 0 y MAX_TASKS-1
  i = i % MAX_TASKS;
  if (sched_tasks[i].state == TASK_RUNNABLE){
    last_task_no_priority = i;
    current_task = i;
    return sched_tasks[i].selector;
  }

  // En el peor de los casos no hay ninguna tarea viva. Usemos la idle como
  // selector.
  return GDT_TASK_IDLE_SEL;
}

tss_t* obtener_TSS(uint16_t selector){
  uint16_t idx = selector >>3;
  return gdt[idx].base;
}

uint8_t esPrioritaria(int8_t indice){
  tss_t* tss_task = obtener_TSS(sched_tasks[indice].selector);
  uint32_t* tss_kernel_stack = tss_task->esp;
  uint32_t task_edx = tss_kernel_stack[5];
  return task_edx == 0x00FAFAFA;
}