section .data      
      mask128: times 16 db 128;

section .text

      ; 16 datos de 1B en xmm1 y xmm2 
      ; como pcmpgt compara signado entonces le tengo que sumar 128 antes de comparar

      movdqa xmm3, [mask128]

      paddb xmm1, xmm3
      paddb xmm2, xmm3
      pcmpgtb xmm1, xmm2  ; el resultado queda en xmm0

      ; si xmm1 es mayor --> poner lo que está en xmm4
      movdqu xmm4, xmm1 ; por ejemplo el mismo dato xmm1
      ; sino --> poner lo que está en xmm5
      movdqu xmm5, xmm2 ; por ejemplo el mismo dato xmm2

      ; es decir, xmm0[i] = 1 si xmm1[i] > xmm2[i] para i en [0, 16]
      pblendvb xmm4, xmm5 ; lee la mascara de xmm0
 
