section .text

      ; obtenemos el valor absoluto para
      pabsd xmm1, xmm0

      ; shift a izquierda hasta el ultimo bit
      ; x00000000000000000000000000000 | ... | ... | ...
      ; x es 1 si la dobleword es impar y 0 si es par
      pslld xmm1, 31

      ; extendemos el valor de x en los 32 bits de cada dword
      ; xxxxxxxxxxxxxxxxxxxxxxxxxxxxx | ... | ... | ... |
      psrad xmm1, 31
      
      ; hacemos un and not porque los dobleword con FFFF son impares
      pandn xmm1, xmm0

      ; acá xmm1 tiene 0 en los impares y el valor original en los pares
      