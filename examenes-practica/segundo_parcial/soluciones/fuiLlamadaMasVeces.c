uint8_t fuiLlamadaMasVeces(uint16_t task_id){
	uint32_t curr_utc = getUTC(task_id);
	for (uint16_t i=0; i<MAX_TASKS; i++){
		if (curr_utc > getUTC(i))
			return 0;	
	}
	return 1;
}

uint32_t getUTC(uint16_t task_id){
	tss_t* tss_task = getTSS(sched_tasks[task_id].selector);
	uint32_t* stack = tss_task->esp;
	return stack[6];
}

tss_t* getTSS(uint16_t selector){
      return (tss_t*) (gdt[selector >> 3].base);
}