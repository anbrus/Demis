X=2
data segment
        mas1 db 4,1,2,3,2
	mas2 db 6,1,5,2,3,4,2
	mas3 db 6,1,6,2,3,7,2
	time db 0,4,2,4,2,2,2,2
	viv1 db 0,12,18,33,35,28,140,161
	viv2 db 0,12,18,33,35,28,136,129
	t db 1
data ends
	
code segment
       assume cs:code,ds:data,es:data
 keyent proc 
        in al,0
        and al,00011111b
        cmp al,01h
	jnz m1
	lea bx,mas1
	mov si,1
 m1:	cmp al,02
	jnz m2
	lea bx,mas2
	mov si,1
 m2:	cmp al,04
	jnz m3
	lea bx,mas3
	mov si,1
 m3:	cmp al,08
	jnz m4
	rol t,1
	mov cl,t
        mov al,t
	out 02h,al
	xor dl,dl
 m4:	cmp al,16
 	jnz m5
 	ror t,1
	mov cl,t
        mov al,t
	out 02h,al
	xor dl,dl
 m5:	ret
keyent  endp

Signal  proc
	mov  di,[bx+si]
        and  di,00ffh
	mov  al,viv1[di]
	test al,128
	jz  m6
	dec  bp
 	jnz m7
	mov  bp,X
	not  ah
 m7:	add  ah,0
	jnz m6
	mov  al,viv2[di]
 m6:	out  00h,al
	dec  cl
	jnz m8
        mov cl,t
	inc  ch
	cmp  ch,time[di]
	jnz m8
        xor ch,ch
	inc  si
        mov dx,si
	cmp [BX],dl
	jae m8
	mov  si,1
 m8:	ret
Signal  endp
START:  mov ax,data
	mov ds,ax
	mov es,ax
        mov al,t
        out 02h,al
        lea bx,mas1
	mov bp,X
	mov si,1
	xor cx,cx
	mov cl,t
	xor ch,ch
        mov ah,0ffh
start1:	call keyent
	call signal 	
        jmp start1
code ends
end start
