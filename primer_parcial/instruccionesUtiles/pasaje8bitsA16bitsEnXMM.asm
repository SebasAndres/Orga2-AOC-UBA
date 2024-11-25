; vamos a necesitar otro registro xmm para pasar los 16 datos de 8 bytes que hay en el xmm original
; a 16 bytes cada dato

section .text

      ; xmm1 tiene el dato de interes, lo copiamos en otro xmm
	movdqu xmm2, xmm1

      ; utilizamos un xmm auxiliar para usar las instrucciones de punpcklbh y punpckhbl
      pxor xmm0, xmm0
      
      ; dejamos en xmm1 las 8 words bajas
      punpcklbw xmm1, xmm0

      ; dejamos en xmm2 las 8 words altas
      punpckhbw xmm2, xmm0

