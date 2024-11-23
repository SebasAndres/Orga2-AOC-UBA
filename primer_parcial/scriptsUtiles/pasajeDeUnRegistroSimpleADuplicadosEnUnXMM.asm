section .data
      mask_ammount: times 8 db 0x00, 0x0F ;0, 15 

section .text

      add r8, 10 ; este vendría por parametro normalmente

      ; copio mascara
      ; xmm1 = 15 0 15 0 15 0 15 0 15 0 15 0 15 0 15 0
      movdqu xmm1, [mask_ammount]

      ; copio en eax el valor de r8b con zero extension (a 32 bits)
      movzx eax, r8b ; como r8b tiene 8 bits el bit 15 de eax es 0 por zero-extension

      ; copio en un registro xmm el valor de eax 
      ; xmm2 = 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 10
      ;        ^                             ^  
      ;        |- este es el byte 15         |- este es el byte 0
      movd xmm2, eax

      ; hago un pshufb de eax con la mascara
      ; xmm2 = 0 10 0 10 0 10 0 10 0 10 0 10 0 10 0 10
      ;      = 10 10 10 10 10 10 10 10
      pshufb xmm2, xmm1
