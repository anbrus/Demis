data segment at 0BA00H
   player struc
	number db ?
	time_pl dd ?
	place db ?
   player ends	
   all_players player 04H dup (?)
   kol_igr db ?	
   ch_sigr db ?	
   fl_eg db ?
   error db 04H dup (?)
   n_plrs db ?	
   digits db 0BH dup (?)
   ready_fl db ?	
   prig_fl db ?	
   pl db ?

   Prt_err macro 
		mov al,ds:error[0]	
		out 1,al
		mov al,ds:error[1]	
		out 2,al
		mov al,ds:error[2]	
		out 3,al
		mov al,ds:error[3]	
		out 4,al
	   endm	
data ends

code segment 
assume cs:code,ds:data

;ввод числа участников
;----------------------

InpAmountPls proc near

	cmp fl_eg,1
	je NotExIAP

	cmp ch_sigr,0
	jne NotExIAP

n_ch1:	
	push ax
	call reset
	pop ax	

	in al,01
	cmp al,04h
	je y_ch1
	jmp n_ch1

y_ch1:  mov si,0
	in al,00
	mov ah,al	
	shr ah,4
	cmp ah,0
	jne n_ch1	
	cmp al,0
	je y_ch1

n_dg1:	inc si
	shr al,1
	cmp al,0	
	jne n_dg1

	mov al,digits[si]
	out 05,al
	
	mov ax,si
	xor ah,ah
	mov kol_igr,al	
	
NotExIAP: ret
InpAmountPls endp

;----------------------
;ввод номера участника
;----------------------
InpNumPls proc near

pov_vv:	
	cmp fl_eg,1
	je s

n_ch2:

	push ax
	call reset
	pop ax

	push ax
	call ModeInput
	pop ax

	in al,01
	cmp al,08h
	je y_ch2
	
	cmp fl_eg,1
	je s

	jmp n_ch2 	
s:	jmp NotExINP 	

y_ch2:	
	mov al,3Fh
	out 01h,al
	out 02h,al
	out 03h,al
	out 04h,al
	out 06h,al

	push ax
	call reset
	pop ax

	mov si,0
	in al,00
	mov ah,al	
	shr ah,4
	cmp ah,0
	jne y_ch2	
	cmp al,0
	je y_ch2
n_dg2:	inc si
	shr al,1
	cmp al,0	
	jne n_dg2

	mov di,0
	mov ax,si

	xor cl,cl
Next:	cmp al,all_players[di].number
	je err_povt
	add di,6
	inc cl
	cmp cl,4
	je prav
	jne next

err_povt: Prt_err
	jmp pov_vv


prav:	mov al,digits[si]
	out 06,al
	mov ax,si
	push ax


	dec ax
	mov cl,6
	mul cl
	mov si,ax	
	
	pop ax

	mov n_plrs,al
	mov all_players[si].number,al

NotExINP: ret

InpNumPls endp

;----------------------
;ожидание "Готов"	
;----------------------
TestReady proc near

	cmp fl_eg,1
	je NotExR

	mov ready_fl,0
	in al,00
	cmp al,10h
	je NotExR

n_r:	push ax
	call reset
	pop ax
	in al,01
	cmp al,01
	je InpR
	jmp n_r

inpR:	mov ready_fl,1

NotExR: ret
TestReady endp

;----------------------
;формирование "Приглашения"	
;----------------------
InpPrig proc near

	cmp fl_eg,1
	je NotExTR

	mov prig_fl,0
	in al,00
	cmp al,10h
	je NotExTR 
	cmp ready_fl,01
	jne NotExTR 
        mov ax,2C00H
        int 21h
        mov al,dh
        aam
        mov ah,al
        mov si,ax
      
       mov ax,si		
       cmp ax,0
       jne n_z		
       mov ax,1	
n_z:   shl ax,2	
       mov cl,75		
       mul cl
       mov si,ax
next1:  dec si
       cmp si,0
       jne next1			
			  		
InpPr: mov al,1
       out 0,al	       	
       mov prig_fl,1	

NotExTR: ret
InpPrig endp
	
;--------------------------
;вычисление времени реакции	
;--------------------------
TimeReac proc near

	cmp fl_eg,1
	je NotExTR

	cmp prig_fl,01
	jne NotExTR
	
        mov al,n_plrs
	
	push ax
	xor ah,ah
	dec ax
	mov cl,6
	mul cl
	mov di,ax	
	pop ax
	mov si,1
	

	mov byte ptr all_players.time_pl[di],0
	mov byte ptr all_players.time_pl[di]+1,0
	mov byte ptr all_players.time_pl[di]+2,0
	mov byte ptr all_players.time_pl[di]+3,0
	mov al,3Fh
	out 01h,al
	out 02h,al
	out 03h,al
	out 04h,al

u1:    in al,01
       cmp al,02h
        je u5

	push ax
	call ModeInput
	pop ax


	cmp byte ptr all_players.time_pl[di],09d
	je u2
	inc byte ptr all_players.time_pl[di]	
	mov al,byte ptr all_players[di].time_pl
        xlat
        out 04h,al
	jmp u1

u2:	mov byte ptr all_players[di].time_pl,0
	mov al,byte ptr all_players[di].time_pl
        xlat
        out 04h,al
	cmp byte ptr all_players.time_pl[di]+1,09d
	je u3
	inc byte ptr all_players.time_pl[di]+1
	mov al,byte ptr all_players[di].time_pl+1
        xlat
        out 03h,al
	jmp u1

u3:	mov byte ptr all_players[di].time_pl+1,0
	mov al,byte ptr all_players[di].time_pl+1
        xlat
        out 03h,al
	cmp byte ptr all_players.time_pl[di]+2,09d
	je u4
	inc byte ptr all_players.time_pl[di]+2
	mov al,byte ptr all_players[di].time_pl+2
        xlat
        out 02h,al
	jmp u1

u4:     mov byte ptr all_players[di].time_pl+2,0
	mov al,byte ptr all_players[di].time_pl+2
        xlat
        out 02h,al
     	inc byte ptr all_players[di].time_pl+3
	mov al,byte ptr all_players[di].time_pl+3
        xlat
        out 01h,al
u5:

        inc ch_sigr	
	mov al,ch_sigr
	cmp al,kol_igr
	jge wer

	jmp NotExTM


wer:	mov fl_eg,1

NotExTM: ret
TimeReac endp

;--------------------------
;формирование мест участников	
;--------------------------
Form_Place proc
	
	cmp byte ptr all_players[00h].number,0Ah
	je q1
	mov byte ptr all_players[00h].place,0
q1:	cmp byte ptr all_players[06h].number,0Ah
	je q2
	mov byte ptr all_players[06h].place,0
q2:	cmp byte ptr all_players[0Ch].number,0Ah
	je q3
	mov byte ptr all_players[0Ch].place,0
q3:	cmp byte ptr all_players[12h].number,0Ah
	je q4
	mov byte ptr all_players[12h].place,0
q4:
	cmp fl_eg,1
	jne NotExFP

	mov pl,1

t0:     mov si,0
	mov di,si
t0_1:	cmp byte ptr all_players[di].place,0
	je t1
	add di,6
	cmp di,24d
	jge ext
	jmp t0_1
	
t1:	add si,6
t2:	cmp byte ptr all_players[si].place,0
	je t3
	add si,6 
	cmp si,24d
	jge ext
	jmp t2

t3:	mov ax,word ptr all_players[di].time_pl+2
	sub ax,word ptr all_players[si].time_pl+2
	js t1
	jz t4
	mov di,si
	jmp t1
t4:	mov ax,word ptr all_players[di].time_pl
	sub ax,word ptr all_players[si].time_pl
	js t1
	jz t5
	mov di,si
	jmp t1
t5: 	mov di,si
	jmp t1	
ext:    mov al,pl
	mov byte ptr all_players[di].place,al
eee:	inc pl
	cmp pl,5
	jne t0
	
NotExFP: ret
endp

;--------------------------
;просмотр по месту
;--------------------------
Pros_place proc
	
	mov al,0
	out 00,al

	in al,00h
	cmp al,50h
	jne NotExPP
	cmp al,90h
	je NotExPP
	

	mov si,0
	mov cl,1

pp:

ggg:	in al,00
	cmp al,70h
	je ggg

	cmp all_players[si].place,cl
	je pp2 

	add si,06h 
	cmp si,18h 
	jge jjj 
	jmp pp
	
pp2:	mov al,all_players[si].place
	xlat
	out 05,al

	mov al,all_players[si].number
	xlat
	out 06,al

	mov al,byte ptr all_players[si].time_pl+3
	xlat
	out 01,al 
        mov al,byte ptr all_players[si].time_pl+2
	xlat
	out 02,al 
	mov al,byte ptr all_players[si].time_pl+1
	xlat
	out 03,al 
	mov al,byte ptr all_players[si].time_pl
	xlat
	out 04,al 
	
pp1:
	push ax
	call reset
	pop ax
	in al,00
	cmp al,10h
	je NotExPP
	cmp al,70h
	jne pp1

	mov dl,250
sd:	nop
	dec dl
	cmp dl,0
	jne sd

jjj:	inc cl
	cmp cl,5 
	jne pp6

	mov cl,1
pp6:	xor si,si
	jmp pp


NotExPP: ret		
endp	

;--------------------------
;просмотр по номеру
;--------------------------
Pros_number proc
	
	mov al,0
	out 00,al

	mov si,0
	mov cl,1

	in al,00h
	cmp al,90h
	jne NotExPN
	cmp al,50h
	je NotExPN

jj:

	in al,00
	cmp al,0B0h
	je jj


	cmp all_players[si].number,cl
	je jj2 

	add si,06h 
	cmp si,18h 
	jge ffff;jj1
	jmp jj
	
jj2:	mov al,all_players[si].place
	xlat
	out 05,al

	mov al,all_players[si].number
	xlat
	out 06,al

	mov al,byte ptr all_players[si].time_pl+3
	xlat
	out 01,al 
        mov al,byte ptr all_players[si].time_pl+2
	xlat
	out 02,al 
	mov al,byte ptr all_players[si].time_pl+1
	xlat
	out 03,al 
	mov al,byte ptr all_players[si].time_pl
	xlat
	out 04,al 
	
jj1:	push ax
	call reset
	pop ax

	mov dl,250
sd1:	nop
	dec dl
	cmp dl,0
	jne sd1

	cmp al,10h
	je NotExPP
	in al,00
	cmp al,0B0h
	jne jj1

ffff:	inc cl
	cmp cl,5
	jne jj6

	mov cl,1
jj6:	xor si,si
	jmp jj

NotExPN: ret	
endp	

;--------------------------
;подготовка
;--------------------------
podg proc near

	lea bx,error
        mov error[0], 73H
        mov error[1], 60H
        mov error[2], 60H
        mov error[3], 80H

	lea bx,digits
        mov digits[0], 3FH
        mov digits[1], 0CH
        mov digits[2], 76H
        mov digits[3], 5EH
        mov digits[4], 4DH
        mov digits[5], 5BH
        mov digits[6], 7BH
        mov digits[7], 0EH
        mov digits[8], 7FH
        mov digits[9], 5FH
        mov digits[10],63H

	mov si,0
nt:	mov byte ptr all_players[si].time_pl,10d
	mov byte ptr all_players[si].time_pl+1,10d	
	mov byte ptr all_players[si].time_pl+2,10d	
	mov byte ptr all_players[si].time_pl+3,10d	
	mov byte ptr all_players[si].number,10d
	mov byte ptr all_players[si].place,10d
	add si,06h
	cmp si,18h
	jne nt

	mov kol_igr,0
	mov ch_sigr,0
	mov fl_eg,0

	ret
endp

;--------------------------
;сброс
;--------------------------
reset proc near

	in al,01
	and al,10h
	cmp al,10h
	jne qas
	mov al,0
	out 00,al
	out 01,al
	out 02,al
	out 03,al
	out 04,al
	out 05,al
	out 06,al
	jmp start
qas:    ret
endp

;--------------------------
;проверка режима
;--------------------------

ModeInput proc near

	in al,00
	cmp al,10h
	jne lll

	mov byte ptr fl_eg,1

lll:    ret 
endp

start:
	mov ax,data
	mov ds,ax

	mov ax,stack
	mov ss,ax
	mov sp,offset stktop
	
	call podg	   ; подготовка	

begin:
	call reset         ; сброс
	call ModeInput     ; ввод режимов
        call InpAmountPls  ; формирование инф. о числе участников
        call InpNumPls     ; формирование инф. о номере участников
        call TestReady     ; проверка готовности участника
        call InpPrig       ; формирование приглашения участнику
        call TimeReac      ; вычисление времени, через которое среагирует уч.       
	call form_place    ; формирование мест для участников
	call pros_place    ; просмотр по месту 
	call pros_number   ; просмотр по времени

	jmp begin
code ends

stack segment at 0BA80H
	db 200H dup(?)
	stktop label word
stack ends

end start	

