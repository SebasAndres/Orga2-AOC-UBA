
-------------------------------------------------------------------------------------------------------------------------------
## EJERCICIO 1

(a) Mapa memoria virtual ???????????

(b) Cambios:

Al crear una tarea:
- que las tareas tengan el CS con permisos de kernel -->
	[tss.c/tss_create_user_task] al crearse el TS en  el codigo debería ser GDT_CODE_0_SEL.

- al mapear las paginas de código en [mmu.c/mmu_init_task_dir] agregar en los attr MMU_S.

- en [mmu.c/mmu_task_dir] mapear como memoria compartida la dummy:	

	~~~c
	paddr_t mmu_init_task_dir(paddr_t phy_start) {
	  pd_entry_t* tpd = (pd_entry_t*)mmu_next_free_kernel_page();
	  zero_page((paddr_t)tpd);

	  tpd[0].pt = ((uint32_t)kpt) >> 12;
	  tpd[0].attrs = MMU_P | MMU_W;

	  // Mapear las dos paginas de codigo como solo lectura (a partir de 0x08000000)
	  mmu_map_page((uint32_t)tpd, TASK_CODE_VIRTUAL, phy_start, MMU_P | MMU_U);
	  mmu_map_page((uint32_t)tpd, TASK_CODE_VIRTUAL + PAGE_SIZE, phy_start + PAGE_SIZE, MMU_P | MMU_U);

	  // Mapear la pagina de stack como lectura/escritura (a partir de 0x08003000)
	  mmu_map_page((uint32_t)tpd, TASK_STACK_BASE - PAGE_SIZE, mmu_next_free_user_page(), MMU_P | MMU_W | MMU_U);  

	  // Mapear la pagina de memoria compartida como lectura/escritura (despues del stack)
	  mmu_map_page((uint32_t)tpd, TASK_STACK_BASE, 0x1D000, MMU_P | MMU_W | MMU_U);

	  // AGREGADO !!! 
	  for (page=0; page<=(END_VIRT_VIDEO-BASE_VIRT_VIDEO); page += PAGE_SIZE)
		mmu_map_page(tpd, BASE_VIRT_VIDEO+page, PHY_BASE_VIDEO+page, MMU_P | MMU_U | MMU_U)

	  return (paddr_t)tpd;
	}
	~~~

(c) En el scheduler:
- vamos a tener una variable global que contiene cual es la tarea con la pantalla real asignada: 
	
	task_id_t screenTaskManager = [ task_id of curr task with SCREEN_VIDEO_PHY mapped ]

(d) Al presionar TAB:
- modificamos la interrupción del teclado para que en task_input_process se valide si se apretó TAB:

	~~~asm
	_isr33:
		pushad
		call pic_finish1
		in al, 0x60
		push eax
		call tasks_input_process
		add esp, 4
		popad
    		iret
	~~~

	~~~c
	// tasks.c
	void tasks_input_process(uint8_t scancode) {
	  uint8_t* keyboard_state = (uint8_t*) &ENVIRONMENT->keyboard;
	  keyboard_state[scancode & 0x7F] = (scancode & 0x80) == 0;	  
	  if ((scancode & 0x7F) == KEY_TAB && (scancode & 0x80) == 0)
	  	changeScreenManagerTask();
	}

	[sched.c]
	void changeScreenManagerTask(void){
		nextTaskManager = currTaskManager + 1 % MAX_TASKS;
		if (nextTaskManager == currTaskManager) { return ; }		
		unmapRealVideoMapDummy(currTaskManager);
		unmapFakeMapRealVideo(nextTaskManager);
	}
	
	void unmapRealVideoMapDummy(int task_id){
		// Desmapea de la tarea con ese task_id la memoria asignada al video real		
		cr3 = getCR3(task_id);
		for (page=0; page<=(END_VIRT_VIDEO-BASE_VIRT_VIDEO); page += PAGE_SIZE){
			mmu_unmap_page(tpd, BASE_VIRT_VIDEO+page, PHY_REAL_VIDEO_BASE+page)
			mmu_map_page(tpd, BASE_VIRT_VIDEO+page, PHY_DUMMT_VIDEO_BASE+page)					
		}
	}
	
	void mapRealVideoUnmapDummy(int task_id){
		// Mapea de la tarea con ese task_id la memoria asignada al video real		
		cr3 = getCR3(task_id);
		for (page=0; page<=(END_VIRT_VIDEO-BASE_VIRT_VIDEO); page += PAGE_SIZE){
			mmu_unmap_page(tpd, BASE_VIRT_VIDEO+page, PHY_DUMMY_VIDEO_BASE+page)
			mmu_map_page(tpd, BASE_VIRT_VIDEO+page, PHY_REAL_VIDEO_BASE+page)					
		}
	}
	~~~
??

(e) En el mecanismo propuesto las tareas no tienen forma sencilla de saber si “es su turno” de usar la pantalla. 
   Proponga una solución. No se pide código ni pseudocódigo, sólo la idea.
	-[IDEA] Una syscall que valide si currTask == currTaskManager

(f) En el mecanismo propuesto la tarea debe redibujar toda su pantalla cuando logra conseguir
   acceso a la misma. ¿Cómo podría evitarse eso? No se pide código ni pseudocódigo, sólo la idea.
	- ??  

--------------------------------------------------------------------------------------------------------------------------------
## EJERCICIO 2

Se me ocurre la siguiente implementación:

~~~c
copiarPagina(task_id_t tarea_espiada_id, vaddr_t virt){
	// Copia el dato en virt de la tarea espiada en virt de la tarea actual
	cr3 = getCR3(tarea_espiada_id);
	paddr_t phy_address = dirFisica(cr3, virt);
	mmu_map_page(rcr3(), virt, phy_address, MMU_P | MMU_U);
}
~~~

a. Dibujar un esquema que muestre una posible distribución de memoria para este sistema.

b. Implementar el servicio pedido. Definir para esto cualquier variable global utilizada. Indicar todo
lo que se asume para resolver este ejercicio.

-> Asumimos que virt apunta a un phy_address en la region de memoria compartida

c. Para que el servicio pedido funcione, ¿deben modificar la interrupción de reloj?. Si la respuesta
es sí, como deben modificarla?. Si la respuesta es no, explicar por qué.

-> No (?


