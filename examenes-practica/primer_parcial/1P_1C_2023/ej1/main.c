#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "ej1.h"

templo* sampleTempleArr(){
	templo t1 = {
		3, // largo
		"temploClasico", // nombre 
		1 // corto
	};
	templo t2 = {
		1, // largo
		"temploNoClasico", // nombre 
		1 // corto
	};
	templo t3 = {
		3, // largo
		"temploClasico", // nombre 
		1 // corto
	};

	templo* templosArr = malloc(sizeof(templo)*3);
	templosArr[0] = t1;
	templosArr[1] = t2;
	templosArr[2] = t3;
	return templosArr;
}

void validacionEjA(){

	// printf("Dirección de memoria de t: %p \n", (void*)&t);
	// printf("Dirección de memoria de tArr: %p \n", (void*)&templosArr);

	templo* templosArr = sampleTempleArr();
	printf("Contador de Templos Clasicos: ");
	printf("%d \n", cuantosTemplosClasicos(templosArr, 3));

	free(templosArr);
}

void validacionEjB(){
	templo* templosArr = sampleTempleArr();
	templo* tClasicos = templosClasicos(templosArr, 3);
	int numTemplosClasicos = cuantosTemplosClasicos(templosArr, 3);
	for (int i = 0; i < numTemplosClasicos; i++) {
		printf("Templo %d: colum_largo = %d, nombre = %s, colum_corto = %d\n",
			i, tClasicos[i].colum_largo, tClasicos[i].nombre, tClasicos[i].colum_corto);
	}
	free(templosArr);
	free(tClasicos);
}

int main (void){
	/* Acá pueden realizar sus propias pruebas */

	// validacionEjA();
	validacionEjB();

	return 0;    
}

