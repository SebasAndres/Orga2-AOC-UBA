	; pasamos el contraste a 8 words en un xmm
	movdqu xmm0, [mask_ammount] 
	movzx eax, r8b        
	movd xmm1, eax       
	pshufb xmm1, xmm0 
