maxaddr=2048
drebdelay=1
data segment at 0B940H
       arr_kbd db 3 dup (?)
       next_digit db ?
       addr    dw ?
       dan     db ?
       fl_a    db ?
       fl_v    db ?
       lamp    db ?
       fl_kbd  db ?
       fl_nul_kbd db ?
       fl_err  db ?
       Map     db 16 dup (?)
       ozu     db maxaddr dup (?)
data ends

code segment
assume cs:code,ds:data

InitMap proc near
       mov Map[0], 3FH
       mov Map[1], 0CH
       mov Map[2], 76H
       mov Map[3], 5EH
       mov Map[4], 4DH
       mov Map[5], 5BH
       mov Map[6], 7BH
       mov Map[7], 0EH
       mov Map[8], 7FH
       mov Map[9], 5FH
       mov Map[10], 6FH
       mov Map[11], 79H
       mov Map[12], 33H
       mov Map[13], 7CH
       mov Map[14], 73H
       mov Map[15], 63H
       ret
InitMap endp

PrintValue macro NPort
       xlat
       out NPort,al
	   endm

ADOut proc near
       mov si,addr
       mov dl,ozu[si]
       mov dan,dl
       mov dx,addr
       mov al,dl
       and al,00001111b
       PrintValue 3
       mov al,dl
       mov cl,4
       shr al,cl
       PrintValue 2
       mov al,dh
       and al,00001111b
       PrintValue 1
       mov al,dh
       mov cl,4
       shr al,cl
       PrintValue 0
       mov al,dan
       and al,00001111b
       PrintValue 5
       mov al,dan
       mov cl,4
       shr al,cl
       PrintValue 4

       cmp fl_a,0
       je  ADO1
       or lamp,00000001b
	and lamp,11111101b
       jmp ADO2
ADO1:  or lamp,00000010b
	and lamp,11111110b

ADO2:  cmp fl_v,0
       je  ADO3
       or lamp,00000100b
	and lamp,11110111b
       jmp ADO4
ADO3:  or lamp,00001000b
	and lamp,11111011b

ADO4:  mov al,lamp
       out 9,al
       ret
ADOut endp

InitInd proc near
       mov addr,0000h
       mov lamp,0
       mov fl_a,0ffh
       mov fl_v,0
       call ADOut
       ret
InitInd endp

dreb proc
       mov ah,al
dbeg:  mov ch,0
dvvod: in al,dx
       cmp ah,al
       jne dbeg
       inc ch
       cmp ch,drebdelay
       jne dvvod
       ret
dreb endp

InKbd proc
       mov di,0
       mov cl,3
       mov dx,6
ikbeg: in al,dx
       cmp al,0
       jne iksig
       mov arr_kbd[di],al
       jmp ikmod
iksig: call dreb
       mov arr_kbd[di],al
ikof:  in al,dx
       cmp al,0
       jne ikof
       call dreb
ikmod: inc di
       inc dx
       dec cl
       jnz ikbeg
       ret
InKbd endp

contr proc
       mov fl_nul_kbd,0
       mov fl_err,0
       mov ah,0
       mov di,0
       mov cl,3
cns:   mov ch,8
       mov al,arr_kbd[di]
cnb:   shr al,1
       adc ah,0
       dec ch
       jnz cnb
       inc di
       dec cl
       jnz cns
       cmp ah,0
       jne cnz
       mov fl_nul_kbd,0ffh
       jmp cend
cnz:   cmp ah,1
       je  cend
       mov fl_err,0ffh
cend:  ret
contr endp

select proc
       cmp arr_kbd[2],0
       je  s_end
       test arr_kbd[2],00000001b
       jnz  s_a
       test arr_kbd[2],00000010b
       jnz  s_d
       test arr_kbd[2],00000100b
       jnz  s_v
       test arr_kbd[2],00001000b
       jnz  s_p
       test arr_kbd[2],00010000b
       jnz  s_plus
       test arr_kbd[2],00100000b
       jnz  s_minus
       jmp s_end
s_a:   mov fl_a,0ffh
       jmp s_end
s_d:   mov fl_a,0
       jmp s_end
s_v:   mov fl_v,0ffh
       jmp s_end
s_p:   mov fl_v,0
       jmp s_end
s_plus:  inc addr
	 cmp addr,maxaddr
	 jb  s_end
	 mov addr,0
	 jmp s_end
s_minus: dec addr
	 cmp addr,maxaddr
	 jb  s_end
	 mov addr,maxaddr-1
	 jmp s_end
s_end: ret
select endp

modif proc
       cmp fl_a,0
       je  md
       mov ax,addr
       mov cl,4
       shl ax,cl
       or al,next_digit
       mov addr,ax
       jmp mend
md:    cmp fl_v,0
       je  mend
       cmp addr,maxaddr
       ja  mend
       mov si,addr
       mov al,ozu[si]
       mov cl,4
       shl al,cl
       or al,next_digit
       mov ozu[si],al
mend:  ret
modif endp

conv proc
       cmp fl_nul_kbd,0
       jne vend
       cmp fl_err,0
       jne vend
       mov ax,word ptr arr_kbd
       cmp ax,0
       je  upr
       mov cl,0ffh
vnb:   inc cl
       shr ax,1
       jnc vnb
       mov next_digit,cl
       call modif
       jmp vend
upr:   call select
vend:  ret
conv endp

start: mov ax,data
       mov ds,ax
       mov bx,offset Map
       call InitMap
       call InitInd
nach:  call InKbd
       call contr
       call conv
       call ADOut
       jmp  nach
       int 92H
code ends
end start
