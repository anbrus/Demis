nmax =25
data segment at 0BA00H
       Map db 0AH dup (?)
sek db(?)
min db(?)
hor db(?)
sb db(?)
mb db(?)
hb db(?)
ts db(?)
tm db(?)
th db(?)
fcl db(?);          1       2 
fbud db(?);0-no use 1-setup 2-use 3-usedownplane
ftim db(?);0-no use 1-setup 2-use 3-usedownplane
beep db(?);0-beep           2-sleep
knop dw(?)
d1 db(?)
d2 db(?)
d3 db(?)
o1 db(?)
o2 db(?)
o3 db(?)
o10 db(?);            O1      O2      O3  
o11 db(?);	   o10 o11 o20 o21 o30 o31
o20 db(?);           hor     min     sek  ( часы. основной индикатор)

;                     D1      D2      D3  
o21 db(?);         d10 d11 od0 d21 d30 d31        
o30 db(?);           hor     min     sek  ( часы, будильник, таймер.
o31 db(?);                                 дополнительный индикатор)
d10 db(?);
d11 db(?);
d20 db(?);
d21 db(?);
d30 db(?);
d31 db(?);
data ends 
stack1 segment at 0BA80H
   db 200H dup (?)
   StkTop label Word
stack1 ends
code segment
assume cs:code, ds:data
load proc near
; загрузка
mov fcl,2
mov fbud,0
mov ftim,0
       mov Map[0], 3FH
       mov Map[1], 0CH
       mov Map[2], 76H
       mov Map[3], 05EH
       mov Map[4], 4DH
       mov Map[5], 5BH
       mov Map[6], 7BH
       mov Map[7], 0EH
       mov Map[8], 7FH
       mov Map[9], 5FH
       mov bx,offset Map
       mov ax,0
out 0eh,al
ret
load endp
gashenie proc
vd1:       mov ah,al
           mov bh,0
vd2:       in al,dx
           cmp ah,al
           jne vd1
           inc bh
           cmp bh,nmax
           jne vd2
           mov al,ah
       ret
gashenie endp

delay proc
push cx
mov cx,0fffh
soon: nop
           push cx 
           mov cx,025h
           soon1: nop
                  loop soon1 
           pop cx

      loop soon
pop cx
ret
delay endp
decoder proc near
    mov al,d1
    call razb    
    mov d11,ah
    mov d10,al
    mov al,d2
    call razb
    mov d21,ah
    mov d20,al
    mov al,d3
    call razb    
    mov d31,ah
    mov d30,al
    mov al,o1
    call razb
    mov o11,ah
    mov o10,al
    mov al,o2    
    call razb
    mov o21,ah
    mov o20,al
    mov al,o3    
    call razb
    mov o31,ah
    mov o30,al
ret
decoder endp
razb proc near		; разбивка двузначного 10-ного числа
       push bx		; на две 10-ые цифры - десятки и единицы
       xor ah,ah
       mov bh,0ah
       div bh ; ах делим на 10 = аl-десятки, ah-единицы
       pop bx
       ret
razb endp
sozd proc near
        mov d1,0
	mov d2,0
	mov d3,0
	mov al,hor
	mov o1,al
	mov al,min
	mov o2,al
	mov al,sek
	mov o3,al         

        cmp fbud,1
	je outbud
        cmp fbud,2
        je outbud
        jmp nextcmp
outbud:	mov al,hb
	mov d1,al
	mov al,mb
	mov d2,al
	mov al,sb
	mov d3,al         
	jmp konsozd
nextcmp:
	cmp ftim,1
	je outtim
        cmp ftim,2
        je outtim
        jmp vso 
outtim:	mov al,th
	mov d1,al
	mov al,tm
	mov d2,al
	mov al,ts
	mov d3,al  
	jmp konsozd
vso: 
konsozd: 
ret
sozd endp
vivod proc
       cmp fcl,1
       je trueclok
       cmp ftim,1
       je truetim
       cmp fbud,1
	je truebud
       mov al,0
	jmp @EO
trueclok:
mov al,20h
jmp @EO
truetim:
mov al,80h
jmp @EO
truebud:
mov al,40h 
@EO:   
 out 0eh,al
       call decoder
       mov al,o31                 ;
       xlat                       ; вывод секунд
       out 01,al                  ;
       mov al,o30                 ;
       xlat                       ; вывод десятков секунд
       out 02,al                  ;
       mov al,o21                 ;
       xlat                       ; вывод минут
       out 03,al                  ;
       mov al,o20                 ;
       xlat                       ; вывод десятков минут
       out 04,al                  ;
       mov al,o11                 ;
       xlat                       ; вывод часов
       out 05,al                  ;
       mov al,o10                 ;
       xlat                       ; вывод десятков часов
       out 06,al                  ;
       mov al,d31                 ;
       xlat                       ; вывод секунд
       out 08,al                 ;  доп. индикатор
       mov al,d30 
       xlat                       ; вывод десятков секунд
       out 09,al                 ; доп. индикатор    
       mov al,d21                 ;
       xlat                       ; вывод минут
       out 0ah,al                  ; доп. индикатор
       mov al,d20                 ;
       xlat                       ; вывод десятков минут
       out 0bh,al                  ; доп. индикатор
       mov al,d11                 ;
       xlat                       ; вывод часов
       out 0ch,al                 ; доп. индикатор
       mov al,d10  
       xlat                       ; вывод десятков часов
       out 0dh,al                 ; доп. индикатор
cmp beep,0 
je pisk
cmp beep,2
je tishina
pisk:         ; there is an alarm - signal  
mov al,0ffh
out 00,al
jmp otbibikali
tishina:
mov al,00
out 00,al
otbibikali:
ret
vivod endp
vvod proc
;из порта в AL
in al,07
;здесь надо написать проверку переключения режимов
cmp al,20h
je setstartclok
cmp al,40h
je setstartbud
cmp al,80h
je gosstim
jmp provplus
setstartclok:
cmp fcl,1
	je startclok
cmp fcl,2
	je setclok
startclok:
    mov fcl,2
jmp provplus
setclok:
mov fcl,1
cmp fbud,1
jne noizmbud
cmp ftim,0
je @nt@
mov fbud,3
jmp provplus 
@nt@:
mov fbud,2   
noizmbud:
jmp provplus
gosstim:jmp setstarttim
setstartbud:
mov fcl,2
cmp fbud,0
  je setbud;
cmp fbud,2
  je setbud
cmp fbud,3
  je setbud
cmp fbud,1 
  je startbud
jmp provplus
setbud:
mov fbud,1
cmp ftim,0
 je notimer
 mov ftim,3
notimer:
jmp provplus
startbud:
cmp ftim,3
jne beztim
mov ftim,2
mov fbud,3
jmp provplus
beztim:
mov fbud,2
jmp provplus
setstarttim:
mov fcl,2
cmp ftim,0
je settim
cmp ftim,1
je starttim
cmp ftim,2
je settim
cmp ftim,3
je settim
jmp provplus
settim:
mov ftim,1
     cmp fbud,0
     je @nobud1  
     mov fbud,3 
@nobud1:
jmp provplus
starttim:
mov ftim,2
jmp provplus
provplus:
;push ax
;mov ax,knop
;mov diver,0ffh
;div diver
;mov diver,ah
;pop ax
;cmp diver,0
;jne @ni0 
cmp al,01        ;+1s
je @1sek
cmp al,02        ;+1m
je @1min
cmp al,04
je @1hor
jmp indplus
@1sek:
        cmp fcl,1 
	je @sc
        cmp fbud,1 
	je @sb
        cmp ftim,1 
	je @st
jmp indplus
@1min:  cmp fcl,1 
	je @GOmc
        cmp fbud,1 
	je @gomb
        cmp ftim,1 
	je @mt
jmp indplus
@1hor:  cmp fcl,1 
	je @GOhc
        cmp fbud,1 
	je @gohb
        cmp ftim,1 
	je @goht
jmp indplus
@st:
inc ts
cmp ts,60
jne @NI0
mov ts,0
@ni0:
jmp indplus
@sb:
inc sb
cmp sb,60
jne @NI1
mov sb,0
@ni1:
jmp indplus
@gomc:
jmp @mc
@sc:
inc sek
cmp sek,60
jne @NI2
mov sek,0
@ni2:
jmp indplus
@gohc:
jmp @hc
@gomb:
jmp @mb
@gohb:
jmp @hb
@goht:
jmp @ht
@mt:
inc tm
cmp tm,60
jne @NI3
mov tm,0
@ni3:
jmp indplus
@mb:
inc mb
cmp mb,60
jne @NI4
mov mb,0
@ni4:
jmp indplus
@mc:
inc min
cmp min,60
jne @NI5
mov min,0
@ni5:
jmp indplus
@ht:
inc th
cmp th,24
jne @NI6
mov th,0
@ni6:
jmp indplus
@hb:
inc hb
cmp hb,24
jne @NI7
mov hb,0
@ni7:
jmp indplus
@hc:
inc hor
cmp hor,24
jne @NI8
mov hor,0
@ni8:
indplus:
ret
vvod endp
plus proc
mov beep,2
cmp fcl,1
je nxtb
       inc byte ptr sek		; сек+1
       cmp sek,03ch 		; =60?
       jne nxtb
       mov sek,0		; да - обнулить
       inc byte ptr min	; мин+1
       cmp min,03ch  		; =60?
       jne nxtb
       mov min,0		; да - обнулить
       inc byte ptr hor	; час+1
       cmp hor,018h		; =24?
       jne nxtb
       mov hor,0		; да - обнулить
nxtb:
cmp fbud,2
je sravn
cmp fbud,3
je sravn
jmp nextb1
@@1:jmp @1
sravn:
   mov ah,sb 
   cmp sek,ah
   jne nextb1   
   mov ah,mb 
   cmp min,ah
   jne nextb1   
   mov ah,hb 
   cmp hor,ah
   jne nextb1   
mov beep,0
mov fbud,0
nextb1:

cmp ftim,2
je decrement
cmp ftim,3
je decrement
jmp nextb3
decrement:                 
        cmp th,0
	jne notbeep
	cmp tm,0
	jne notbeep
	cmp ts,0
	jne notbeep
mov beep,0
mov ftim,0
jmp oposla
notbeep:
mov beep,2
oposla:
       cmp ts,0
       je decmin
       dec ts
       jmp enddoun
decmin:mov ts,59
       cmp tm,0 
       je dechor
       dec tm
       jmp enddoun
dechor:mov tm,59
       cmp th,0
       je enddoun
       dec th
enddoun:
	
nextb3:
@1:
	;inc knop
ret
plus endp
start: mov ax,data
       mov ds,ax
       mov ax,stack1
       mov ss,ax       
       mov sp,offset StkTop 
       call load
next  :
	call vvod
        call sozd
	call vivod   
        call delay
	call plus 
jmp next
org 0ff0h
assume cs:nothing
jmp far ptr Start
code ends
end start
