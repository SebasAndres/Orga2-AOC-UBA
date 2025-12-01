
paddr_t dirFisica(uint32_t cr3, uint32_t* dirVirtual){
    
    /*
        virtual = directory (10b)| table (10b) | offset (12b)
        cr3 = address_of_page_dir (20b) | ignored (7b) | pcd (1) | pwt (1) | ignored (3)
    */

   pd_entry_t* pd = (pd_entry_t*)CR3_TO_PAGE_DIR(cr3);
   int pd_index = VIRT_PAGE_DIR(dirVirtual);

    // Validamos que este mapeada
    if (!(pd[pd_index].attrs & MMU_P))
        return 0;

    int pt_index = VIRT_PAGE_TABLE(dirVirtual);
    pt_entry_t* pt = (pt_entry_t*) MMU_ENTRY_PADDR(pd[pd_index].pt);
    
    // Validamos que esté mapeada
    if (!(pt[pt_index] & MMU_P))
        return 0;

    paddr_t dirFisica = MMY_ENTRY_PADDR(pt[pt_index].page);
    return dirFisica;
}

uint32_t virtual_to_physical_address(uint32_t virt, uint32_t cr3) {
    directory = cr3 & 0xFFFFF000;
    dir_index = (virt >> 22) & 0x3FF; // los 10 bits mas significativos
    page_table_index = (virt >> 12) & 0x3FF; // los 10 bits del medio
    offset = virt & 0xFFF; // los 12 bits menos significativos
    page_table = directory[dir_index] & 0xFFFFF000; // solo la direccion
    page_address = page_table[page_table_index] & 0xFFFFF000; // solo la direccion
    physical_address = page_address | offset;
    return physical_address;
}