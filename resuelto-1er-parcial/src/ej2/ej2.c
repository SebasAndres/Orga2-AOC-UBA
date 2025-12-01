#include "ej2.h"

#include <string.h>

// OPCIONAL: implementar en C
void invocar_habilidad(void* carta_generica, char* habilidad) {

	card_t* carta = carta_generica;
	if (carta == NULL){
		return;
	}

	uint16_t num_card_abilities = carta->__dir_entries;
	for (uint16_t i=0; i<num_card_abilities; i++){
		directory_entry_t* ability_entry_ptr = carta->__dir[i];
		char* ability_name = ability_entry_ptr->ability_name;
		if (strcmp(ability_name, habilidad) == 0) {
			ability_function_t* ability_function = ability_entry_ptr->ability_ptr;
			ability_function(carta);
			return;
		}
	}

	fantastruco_t* archetype = carta->__archetype;
	invocar_habilidad(archetype, habilidad);
}