#include "ej5.h"

str_array_t* strArrayNew(uint8_t capacity){
    str_array_t* res = (str_array_t*)malloc(sizeof(str_array_t));
    res->capacity=capacity;
    return res;
}

char* strArrayRemove(str_array_t* a, uint8_t i){
    //Quita el i-esimo elemento del arreglo, si i se encuentra fuera de rango, retorna NULL.
    //El arreglo es reacomodado de forma que ese elemento indicado sea quitado y retornado.

    if(a->size<i)
        return NULL;
    
        

}