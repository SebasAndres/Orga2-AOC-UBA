## Ejercicio 1

* Arrancar con el prologo y terminar con el epilogo
  ~~~asm
  prologo
      push rbp
	mov rbp, rsp

  epilogo
      pop rbp
      ret
  ~~~

* Si hay alguna call en la funcion o necesitamos usar registros no volátiles => guardarlos todos en la pila antes de hacer otra cosa
  y al final popearlos (en el orden inverso).
~~~asm
  push r15
	push r14
	push r13
	push r12
	push rbx 
	sub rsp, 8 ; alinear la pila
~~~

* Si hacemos una cantidad impar de push a la pila, para que vuelva a estar alineada en 16 bits hacer un sub rsp, 8 (y al final restaurar el rsp con add rsp, 8)

* Cuando recorro estructuras datos = tipoDeDato*, para avanzar en la misma hacer
      ~~~asm
      mov r10, [ dirOriginal + indice * sizeOf(tipoDeDato) ]
      ~~~
      donde:
      * dirOriginal suele venir en un registro
      * indice es un entero en [0, N]
      * sizeOf(tipoDeDato) es el tamaño en bytes del tipoDeDato (ej: los punteros miden 8 y los uint16_t miden 2)
   
   Hacer el compare del forloop al final de la rutina.

* 0 es NULL

* Copiar un dato en .data a un registro:
> mov qword rdi, SIZE_POINTER * MAX_TAG

* Funciones utiles pa assembler
> malloc
> realloc
> strcat
> strlen

> El error "invalid 64-bit effective address" ocurre porque las instrucciones lea no permiten directamente operar con multiplicadores mayores a 1, 2, 4, u 8 en modo de direccionamiento efectivo. Por lo tanto, multiplicar directamente por TAM_STRUCT_TEMPLO (24 en este caso) en una instrucción lea es inválido. Esto se debe a que lea solo admite índices escalados por 1, 2, 4 u 8.