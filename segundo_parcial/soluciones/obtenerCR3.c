// Dado un Selector queremos obtener el CR3 correspondiente
// 1. Sacar del selector el indice de la GDT
// 2. Obtener la base de la GDT
// 3. Sumarle el indice de la GDT multiplicado por el tamaño de la entrada 
// 4. Sumarle el offset del cr3 y retomar el valor 

tss_t* obtenerCR3(uint16_t selector) {
    uint16_t idx = selector >> 3;
    tss_t* tss_task = gdt[idx].base;
    return tss_task->cr3;
} 
