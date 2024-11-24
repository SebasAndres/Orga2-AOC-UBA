## Ejercicio 2

Intrucciones SIMD + usadas

### movdqu xmm0, [mem] 
>  Carga 128 bits desde memoria no alineada a xmm0 

### pshufb xmm0, xmm1 
> Reordena los bytes de xmm0 según el patrón en xmm1. <br>
> Nota: Puede asignar valores cero usando el bit alto del patrón

### pxor xmm0, xmm1 
> Función: Realiza un XOR bit a bit entre los registros SIMD. <br>

> xmm0 = xmm0 XOR xmm1.

### punpcklbw xmm0, xmm1 (Unpack Low Packed Bytes)
> Función: Intercala los bytes de los 64 bits inferiores de dos registros SIMD. <br>

### punpckhbw xmm0, xmm1 (Unpack High Packed Bytes)
> Función: Intercala los bytes de los 64 bits superiores de dos registros SIMD.

### psubw xmm0, xmm1
> Función: Resta palabras (16 bits) de dos registros SIMD de manera empaquetada. <BR>

> psubw xmm0, xmm1; xmm0[i] = xmm0[i] - xmm1[i].

### paddw xmm0, xmm1
> Funcion: Suma palabras de dos registros SIMD de manera empaquetada. <br>

> paddw xmm0, xmm1; xmm0[i] = xmm0[i] + xmm0[i]

### paddusb xmm0, xmm1
> aa

### pmullw xmm0, xmm1 (Packed Multiply Low Words)
> Función: Multiplica palabras (16 bits) de dos registros SIMD y almacena los 16 bits bajos del resultado. <br>

> pmullw xmm0, xmm1 ; xmm0[i] = Low(xmm0[i] * xmm1[i]).

### psraw xmm0, 3 (Packed Shift Right Arithmetic Words)
> Función: Realiza un desplazamiento aritmético a la derecha de palabras (16 bits) con signo. <br>

> psraw xmm0, 3 ;Desplaza cada palabra 3 bits a la derecha (signo preservado)

### packusb (Pack Unsigned Saturate Words to Bytes)
> Función: Convierte palabras (16 bits) en bytes (8 bits) con saturación (trunca valores fuera del rango [0, 255]).

> packuswb xmm0, xmm1 ; Combina palabras de xmm0 y xmm1 en bytes saturados.

### por xmm0, xmm1
> Función: Realiza un OR bit a bit entre registros SIMD.

> por xmm0, xmm1 ; xmm0 = xmm0 OR xmm1.

### pand xmm0, xmm1
> Función: Realiza un AND bit a bit entre registros SIMD.

### phaddsw (Packed Horizontal Add Signed Words with Saturation)
> Función: Suma horizontalmente pares de palabras (16 bits) con signo y aplica saturación.

### pcmpgtb

### pblendvb

### pmovsxwd