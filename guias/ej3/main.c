#include <stdio.h>
#include "ej3.h"

int main(){
    size_t size = sizeof(packed_cliente_t);
    printf("%zu", size);
}

cliente_t cliente_random(cliente_t* arreglo_clientes, size_t longitud){
    int indice_random = rand() % longitud;
    return arreglo_clientes[indice_random];
}