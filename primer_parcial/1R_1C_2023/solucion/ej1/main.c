#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <stddef.h>
#include "ej1.h"

void testA(){
    
    uint8_t cantidadDePagos = 5;
    pago_t* arrPagos = malloc(sizeof(pago_t)*cantidadDePagos);
    arrPagos[0].monto = 6;
    arrPagos[0].cliente = 1;
    arrPagos[0].aprobado = 1;
    arrPagos[1].monto = 0;
    arrPagos[1].cliente = 1;
    arrPagos[1].aprobado = 1;
    arrPagos[2].monto = 1;
    arrPagos[2].cliente = 2;
    arrPagos[2].aprobado = 1;
    arrPagos[3].monto = 40;
    arrPagos[3].cliente = 3;
    arrPagos[3].aprobado = 1;
    arrPagos[4].monto = 50;
    arrPagos[4].cliente = 4;
    arrPagos[4].aprobado = 1;
    
    // printeo 
    printf("arrPagos:\n");
    for(uint8_t i = 0; i < cantidadDePagos; i++){
        printf("monto: %d, cliente: %d, aprobado: %d\n", arrPagos[i].monto, arrPagos[i].cliente, arrPagos[i].aprobado); //anduvo vamos!! ;) 
    }
    uint32_t* montosPorCliente = acumuladoPorCliente_asm(5, arrPagos);
    for (int i=0;i<10;i++){
        printf("%d : %d \n", i, montosPorCliente[i]);
    }
}

void testB(){
    char* comercio = "comercio9";
    char** lista_comercios = malloc(sizeof(char*)*3);
    lista_comercios[0] = "comercio1";
    lista_comercios[1] = "comercio2";
    lista_comercios[2] = "comercio3";
    uint8_t n = 3;
    uint8_t res = en_blacklist_asm(comercio, lista_comercios, n);
    printf("res: %d\n", res); //anduvo
    free(lista_comercios);
}

void testC(){
    uint8_t cantidad_pagos = 5;
    pago_t* arrPagos = malloc(sizeof(pago_t)*cantidad_pagos);
    arrPagos[0].monto = 10;
    arrPagos[0].cliente = 0;
    arrPagos[0].comercio = "comercio1";
    arrPagos[1].monto = 0;
    arrPagos[1].cliente = 1;
    arrPagos[1].comercio = "comercio2";
    arrPagos[2].monto = 1;
    arrPagos[2].cliente = 2;
    arrPagos[2].comercio = "comercio3";
    arrPagos[3].monto = 40;
    arrPagos[3].cliente = 3;
    arrPagos[3].comercio = "comercio4";
    arrPagos[4].monto = 50;
    arrPagos[4].cliente = 4;
    arrPagos[4].comercio = "comercio5";

    uint8_t size_comercios = 3;
    char** arr_comercios = malloc(sizeof(char*)*size_comercios);
    arr_comercios[0] = "comercio1";
    arr_comercios[1] = "comercio2";
    arr_comercios[2] = "comercio3";

    pago_t** res = blacklistComercios_asm(cantidad_pagos, arrPagos, arr_comercios, size_comercios);
    printf("res:\n");
    uint8_t size_res = cantidad_pagos;
    for(uint8_t i = 0; i < size_res; i++){
        if (res[i] == NULL) { printf ("no bro \n"); continue; } 
        printf("monto: %d, cliente: %d, comercio: %s\n", res[i]->monto, res[i]->cliente, res[i]->comercio); //anduvo vamos!! ;) 
    }
}

int main (void){
    // Quiero ver los offsets de la estructura  y su tamaño 
    printf("OFFSETS: \n");
    printf("size of pago_t: %lu\n", sizeof(pago_t));
    printf("offset monto: %lu\n", offsetof(pago_t, monto));
    printf("offset comercio: %lu\n", offsetof(pago_t, comercio));
    printf("offset cliente: %lu\n", offsetof(pago_t, cliente));
    printf("offset aprobado: %lu\n", offsetof(pago_t, aprobado));
    printf("\n");

    // test para acumuladoPorCliente_asm
    // testA();

    //test para la funcion en_blacklist_asm
    // testB();

    //test para la funcion pago_t** blacklistComercios_asm(uint8_t cantidad_pagos, pago_t* arrPagos, char** arr_comercios, uint8_t size_comercios);
    testC();
}


