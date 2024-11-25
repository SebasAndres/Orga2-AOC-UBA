#include "ej1.h"

char** agrupar_c(msg_t* msgArr, size_t msgArr_len){
    char** res = (char**)malloc(sizeof(char*)*MAX_TAGS);  // pido memoria para el arreglo de arreglos por tag
    for(size_t j=0; j<MAX_TAGS; j++){
        res[j] = (char*)malloc(sizeof(char));             // inicializo cada arreglo de tag
        *res[j] = '\0';                                   // escribo como primer valor de cada arreglo a NULL
    }

    for(size_t i=0; i<msgArr_len; i++){
        msg_t it = msgArr[i];
        uint8_t tag = it.tag;
        
        // pido memoria para agregarle al arreglo del tag correspondiente un texto 
        // con la longitud de it.text_len+1 por el NULL
        res[tag] = realloc(res[tag], strlen(res[tag])+it.text_len+1);

        // hacemos el cambio
        res[tag] = strcat(res[tag], it.text);
    }
    return res;
}

