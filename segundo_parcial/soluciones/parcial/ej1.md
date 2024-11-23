## Ejercicio 1

(a) DMA

~~~c

#define PHYS_PAGE_VIDEO
#define VIRT_PAGE_VIDEO

// Mapeo del buffer en modo DMA
void buffer_dma(pd_entry_t* pd){  

      // mmu_map_page_from_pd(pd, VIRT_ADDRESS_VIDEO, PHY_BUFF_VIDEO, MMU_P | MMU_U);
      
      uint32_t pd_index = VIRT_PAGE_DIR(VIRT_ADDRESS_VIDEO);
      
      // Si la tabla de paginas no esta presente, la tengo que crear
      if (!(pd[pd_index].attrs & MMU_P)) {
            // Buscamos una página libre
            paddr_t new_table = mmu_next_free_kernel_page();    

            // La limpiamos 
            zero_page(new_table);

            // Guardamos la dirección de la nueva tabla en el directory
            // shifteamos 12 bits porque no va el offset acá
            pd[pd_index].pt = new_table >> 12;
      }

      // Le ponemos a la tabla de páginas los atributos pasados por parámetros para esa página
      pd[pd_index].attrs |= attrs | MMU_P;
      
      // Obtenemos tabla y entrada en la misma donde mapear la dir física pasada
      pt_entry_t* pt = (pt_entry_t*)MMU_ENTRY_PADDR(pd[pd_index].pt);  
      uint32_t pt_index = VIRT_PAGE_TABLE(virt);

      // Mapeamos la dirección física pasada
      pt[pt_index].page = PHYS_PAGE_VIDEO >> 12;
      pt[pt_index].attrs = attrs | MMU_P;

      // Limpiamos la TLB para que el caché no funcione mal
      tlbflush();
}

~~~
b) Se realiza una copia de esa pagina fisica a otra y se la mapea en la dir virtual hardcodeada.

~~~c

#define SRC_ADDRESS_VIDEO // solo para operar

// Similar a copyPage

void buffer_copy(pd_entry_y* pd, paddr_t phys, vaddr_t virt){

      // mapeamos la pagina con la dir fisica para leerla en una dir hardcodeada
      mmu_map_page_from_pd(pd, SRC_ADDRESS_VIDEO, PHY_BUFF_VIDEO, MMU_P | MMU_U)
      mmu_map_page_from_pd(pd, virt,  mmu_next_free_user_page(), MMU_P | MMU_U);

      // leemos el contenido y lo pegamos en la pagina virtual nueva
      uint8_t* src = (uint8_t*)SRC_VIRT_PAGE;
      uint8_t* dst = (uint8_t*)virt;
      for (size_t i = 0; i < PAGE_SIZE; i++) {
           dst[i] = src[i];
      }

      // desmapeamos la pagina que hicimos para leer la dir física
      mmu_unmap_page_from_pd(pd, SRC_VIRT_PAGE);
}
~~~


