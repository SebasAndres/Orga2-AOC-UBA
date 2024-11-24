; pasamos los floats de 32b saturados a 8 c/u
      packusdw xmm0, xmm0 ; Cada DWORD saturado a un WORD en xmm0
      packuswb xmm0, xmm0 ; Saturar WORDs a BYTES (de 16 bits a 8 bits)
