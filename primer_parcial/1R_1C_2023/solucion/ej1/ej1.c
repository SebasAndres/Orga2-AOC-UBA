#include "ej1.h"





uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos){
    uint32_t* acumulados = malloc(sizeof(uint32_t)*10);
    //inicializo en cero 
    for(uint8_t i = 0; i < 10; i++){
        acumulados[i] = 0;
    }

    for(uint32_t i = 0; i < cantidadDePagos; i++){
        uint8_t cliente = arr_pagos[i].cliente;
        acumulados[cliente] = acumulados[cliente] + arr_pagos[i].monto;
    }
    return acumulados;
}


uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n){
    for(uint8_t i = 0; i < n; i++){
        if(strcmp(comercio, lista_comercios[i]) == 0){
            return 1;
        }
    }
    return 0;
}

//voy a definir como auxiliar la funcion que devuelve la cantidad de pagos blacklisteados 
uint8_t cant_blacklist(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
    uint8_t cant_blacklist = 0;
    for(uint8_t i = 0; i < cantidad_pagos; i++){
        if(en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios) == 1){
            cant_blacklist++;
        }
    }
    return cant_blacklist;
}



pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
    
    uint8_t cant_en_blacklist = cant_blacklist(cantidad_pagos, arr_pagos, arr_comercios, size_comercios);
    //llamo a mallloc para la cantidad de pagos que hay en la blacklist 
    pago_t** arr_pagos_blacklist = malloc(sizeof(pago_t*)*cant_en_blacklist);
    uint8_t j = 0;
    for(uint8_t i = 0; i < cantidad_pagos; i++){
        if(en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios) == 1){
            arr_pagos_blacklist[j] = &arr_pagos[i];
            j++;
        }
    }
    return arr_pagos_blacklist;
}


