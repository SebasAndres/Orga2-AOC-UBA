#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - init_fantastruco_dir
 */
bool EJERCICIO_1A_HECHO = true;


/*
Tips del enunciado:

__dir: 
Se encuentra un directorio de las habilidades implementadas por la carta.
Dicho directorio se compone de entradas de tipo directory_entry_t que 
contienen el nombre de la habilidad implementada y un puntero a la 
función que ejecuta dicha habilidad.

__dir_entries:
Indica cuántas entradas hay en el directorio. Por ejemplo, si un monstruo 
genérico fantastruco implementa dos habilidades del arquetipo, sleep y 
wakeup, __dir_entries = 2 indicando que hay dos directory_entry_t.
*/


// OPCIONAL: implementar en C
void init_fantastruco_dir(fantastruco_t* card) {
    // Inicializo el directorio de la carta con la única 
    // habilidad común
    card->__dir = malloc(sizeof(directory_entry_t*) * 2);

    card->__dir[0] = create_dir_entry("sleep", &sleep);
    card->__dir[1] = create_dir_entry("wakeup", &wakeup);

    // Inicializo el número de entradas del directorio
    card->__dir_entries = 2;

    // Inicializo el puntero al arquetipo como NULL (por consigna)
    card->__archetype = NULL;

    // Inicializo la carta como boca abajo (por consigna)
    card->face_up = 1;
}

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - summon_fantastruco
 */
bool EJERCICIO_1B_HECHO = true;

// OPCIONAL: implementar en C
fantastruco_t* summon_fantastruco() {
    fantastruco_t* card = malloc(sizeof(fantastruco_t));
    init_fantastruco_dir(card);
    return card;
}