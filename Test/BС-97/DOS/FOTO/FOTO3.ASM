	Name u_foto

	pt_m equ 01h
	pt_ss equ 02h
	pt_sm equ 03h
	pt_l equ 04h
	pt_key equ 01h
	
	temp=21


	code segment
	 assume cs:code,ds:code,ss:code
	tab_sc  db 3fh; 0
		db 0ch; 1
		db 76h; 2
		db 5eh; 3
		db 4dh; 4
 		db 5bh; 5 
		db 7bh; 6
		db 0eh; 7
		db 7fh; 8
		db 5fh; 9

	indic proc near
		lea bx,tab_sc
		mov cl,dl
		and Cl,0fh
		mov al,Cl
		xlat		
		out pt_sm,al
		mov al,dl
		mov cl,4
		shr al,cl
		xlat
		out pt_ss,al
		mov al,dh
		xlat
		out pt_m,al
		ret
	indic endp

	del_kl proc near
		mov ax,temp;
	del_1:  dec ax
		jnz del_1
	;	nop
		ret		
	del_kl endp


	start:  mov ax,code
		mov ds,ax
		mov ss,ax
		mov sp,0800h
		mov dx,100h
	 	call indic
		mov al,0
		out pt_l,al
	
	ver_u:  in al,pt_key
		and al,01h
		jz ver_u 


	Merz:   call indic
		mov cx,4
	M1:     call del_kl
		loop M1
		mov al,0
		out pt_m,al
		mov cx,4
	m2:     call del_kl
		loop M2
	        call indic

	Plus:   in al,pt_key
		mov cl,al
		and cl,02h
		jz Minus
		cmp dh,09h
		jne p1
		mov dh,0ffh
	p1:     inc dh
;	p2:	in al,pt_key
;		and al,02h
;		jnz p2
	
	Minus:  in al,pt_key
		and al,04h
		jz Otschet
		cmp dh,0
		jne s1
		mov dh,10
	s1:     dec dh
;	s2:	in al,pt_key
;		and al,04h
;		jnz s2

	Otschet:
		in al,pt_key
		not al
		and al,08h
		jz Pus
		jmp ust
Pus:            jmp Pusk  
		
	Ust:   	in al,pt_key
		not al
		and al,01h
		jz Mer		
		jmp Merz
	Mer:	jmp Mer1 

	Mer1:	call indic
		mov cx,4
	MS1:	call del_kl
		loop MS1
		mov al,0
		out pt_ss,al
		out pt_sm,al
		mov cx,4
	MS2:	call del_kl
		loop MS2
	call indic

	MSP:	in al,pt_key
		and al,02h
		jz MSM
		mov al,dl
		add al,1
		daa
		mov dl,al
		cmp dl,60h
		jne z1
		mov dl,0
	z1:	call indic
;	z2:	in al,pt_key
;		and al,02h
;		jnz z2

	MSM:	in al,pt_key
		and al,04h
		jz UST_1
		mov al,dl
		sub al,1
		das
		mov dl,al
		cmp dl,99h
		jne q1
		mov dl,59h
	q1:	call indic
;	q2:	in al,pt_key
;		and al,04h
;		jnz q2

	UST_1:	in al,pt_key
		not al
		and al,01h
		jnz ots
		jmp MERZ

	OTS:	in al,pt_key
		not al
		and al,08h
		jnz Mer1

	PUSK:	in al,pt_key
		and al,10h
		jz PUSK
		
		mov al,01h
		out pt_l,al
		
		push dx
	PS0:	cmp dx,0
		je OFF
		mov cx,temp
	zad:	call del_kl
		loop zad
		cmp dl,0
		jne ps1
		mov dl,59h
		dec dh
		jmp ps2
	PS1:	mov al,dl
		sub al,01h
		das
		mov dl,al

	PS2:	call indic
		jmp ps0
	
	OFF:	mov al,0
		out pt_l,al
		pop dx
		jmp MERZ


	  code ends
	end start
		
		
















	
			









		
	