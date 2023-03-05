data segment at 0h 
	Map db 0AH dup (?)
	Mode db ?
	NumPl db ?
	FuncGr db ?
	GameTime1 dd ?
	GameTime2 dd ?
	Flags db ?
	MassOut db 10 dup (?)
	SaveTime db ?

data ends 

code segment
assume cs:code,ds:data,ss:stak
subtime proc near
	dec byte ptr [si+1]
	jns t
	add byte ptr [si+1],60d
	dec byte ptr [si+2]
t:	jns t1
	add byte ptr [si+2],60d
	dec byte ptr [si+3]
t1:	jns t2
	mov byte ptr [si+3],0
t2:	
	ret
subtime endp

outtime proc near
	push dx
	push cx
	push si
	push ax
	xor dx,dx
	mov cx,0Ah
	lea si,MassOut
ou:	mov al,[si]
	out dx,al
	inc dx
	inc si
	loop ou
	pop ax
	pop si
	pop cx
	pop dx
	ret
outtime endp

settime proc near
	push si
	push ax
	cmp mode,0
	jnz send
	test Flags,8
	jnz send
	test Flags,4
	jnz send
	mov Flags,0h
	mov word ptr GameTime1,0h
	mov word ptr GameTime2,0h
	cmp FuncGr,0FFh
	jnz sccc
	mov FuncGr,0h
	mov word ptr GameTime1,0h
	mov word ptr GameTime2,0h
	mov word ptr GameTime1+2,0h
	mov word ptr GameTime2+2,0h
	jmp entt
sccc:	cmp NumPl,0Fh
	jnz sccc1
	mov al,4h
	out 0ch,al
sccc1:	cmp NumPl,0F0h
	jnz sccc3
	mov al,20h
	out 0ch,al
	jmp sccc2
send:	jmp entt
sccc3:;	xor al,al
;	out 0Ch,al
sccc2:	cmp FuncGr,0
	jz enSt
	mov flags,0h
	cmp NumPl,00h
	jz enSt 
	cmp NumPl,0Fh
	jnz sct1
	lea si,GameTime1
	jmp sct2

sct1:	lea si,GameTime2
	
sct2:
	call addtime
;	cmp FuncGr,0
;	jz enSt
	mov cx,100d
enext:	nop
	loop enext
enSt:	mov FuncGr,0
entt:	pop ax
	pop si

	ret
settime endp

AddTime proc near
	cmp FuncGr,0fh
	jnz a1
	inc byte ptr [si+2]
	cmp byte ptr [si+2],60d
	jnz a1
	mov byte ptr [si+2],0
	jmp aend
a1:	cmp FuncGr,0F0H
	jnz aend
	inc byte ptr[si+3]
	cmp byte ptr[si+3],5
	jnz aend
	mov byte ptr[si+3],0
aend:
	ret
AddTime endp

GetTime proc near
	inc ax
	cmp ax,200d
	js gg
	inc dh
	xor ax,ax
gg:	
	ret
GetTime endp

ReadKn proc near 
	push ax
r12:	in al,0
	
	test al,1
	jnz r1
	mov flags,0
	mov Mode,00h
	jmp r2
r1:	cmp mode,0
	jnz r11
	and al,6h
	
	out 0Ch,al
	jz r12
	mov NumPl,0
r11:	mov Mode,0ffh

r2:	test al,2
	jz r3
	mov NumPl,0Fh
	jmp r4

r3:	test al,4
	jz r4
	mov NumPl,0F0h

r4:	test al,40h
	jz r5
	mov FuncGr,0fh
	mov cx,0ffffh
rnext:	nop
	loop rnext
	in al,0
	test al,40h
	jnz r6
	mov funcGr,0
	jmp r6
r5:	test al,80h
	jz r6
;	mov NumPl,0h
	mov FuncGr,0F0h
	mov cx,0ffffh
renext:	nop
	loop renext
	in al,0
	test al,80h
	jnz r6
	mov funcGr,0

r6:		
r8:	test al,20h
	jz r10
	test al,1
	jnz r10
	mov FuncGr,0ffh
r10:	pop ax
	ret
ReadKn endp

GetMassOut proc near
	push bx
	push si	
	push ax
	xor dx,dx
	lea di,MassOut
	lea si,GameTime1
	
	lea bx,Map

g2:	mov al,byte ptr [si+3]
        aam
        xlat
        mov [di],al

	inc di
	mov al,byte ptr [si+2]
        aam
        xlat
        mov [di],al

	inc di
        mov al,ah
        xlat
        mov [di],al

	inc di
	mov al,byte ptr [si+1]
        aam
        xlat
        mov [di],al

	inc di
        mov al,ah
        xlat
        mov [di],al 
	cmp si,offset GameTime2
	je g1
	mov si,offset GameTime2
	inc di
	jmp g2
g1:	pop ax
	pop si
	pop bx
	ret
GetMassOut endp

ControlTime proc near
	test Flags,8
	jnz c2
	test Flags,4
	jnz c2
	cmp mode,0
	jz c2
	cmp word ptr [GameTime1+2],0002h
	jns c1
	cmp byte ptr [GameTime1+3],0000h
	jne c1
	or Flags,01h
	cmp word ptr [GameTime1+1],0000h
	jne c1
	cmp byte ptr [GameTime1+2],0000h
	jne c1
	cmp byte ptr [GameTime1+3],0000h
	jne c1
	cmp NumPl,0Fh
	jnz c1
	or Flags,04h

c1:	cmp word ptr [GameTime2+2],0002h
	jns c2
	cmp byte ptr [GameTime2+3],0000h
	jne c2
	or Flags,02h
	cmp byte ptr[GameTime2+1],00h
	jne c2
	cmp byte ptr[GameTime2+2],00h
	jne c2
	cmp byte ptr[GameTime2+3],00h
	jne c2
	cmp NumPL,0F0h
	jnz c2
	or Flags,08h
c2:	ret
ControlTime endp

OutFlags proc near
	push ax
	cmp mode,0
	jz ouend
	xor al,al
	test Flags,04h
	jz ou1
	or al,01h
	mov ah,0FEh
	jmp ou3
ou1:	test Flags,08h
	jz ou2
	or al,80h
	mov ah,7Fh
	jmp ou3
ou2:	test Flags,01h
	jz ou4
	or al,01h
ou4:	test Flags,02h
	jz ou5
	or al,80h
ou5:	
	out 0Ch,al
	jmp ouend
		
ou3:	out 0Ch,al
	mov cx,8000h
oun:	nop
	loop oun
	xor al,al
	out 0Ch,al
	mov cx,8000h
oun1:	nop
	loop oun1
ouend:	pop ax
	ret
OutFlags endp

Score proc near
	push si
	test Flags,8
	jnz enS
	test Flags,4
	jnz enS
	cmp mode,0h
	je enS
	cmp NumPl,00h
	jz enS

sc1:	cmp NumPl,0Fh
	jnz sc3
	lea si,GameTime1
	jmp sc4

sc3:	lea si,GameTime2

sc4:	call GetTime
	cmp ax,0h
	jnz sc2	
	mov Savetime,dh
	call subtime
sc2:	
enS:	
	pop si
	ret
Score endp

Podgotov proc
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
	mov word ptr GameTime1,0h
	mov word ptr GameTime1+2,0h
	mov word ptr GameTime2,0h
	mov word ptr GameTime2+2,0h
	mov Flags,0h
	xor ax,ax
	out 0Ch,al
	ret
Podgotov endp


begin: mov ax,data
       mov ds,ax

       mov ax,STAK
       mov ss,ax       
       mov sp,offset StkTop 

	call Podgotov
next:	call ReadKn
	call Score
	call SetTime
	call GetMassOut
	call OutTime
	call ControlTime
	call OutFlags
	jmp next

        org  0ff0h
        assume cs:nothing
        jmp far ptr begin
code ends

STAK segment stack  at 200h
  dw 100H dup (?)
  StkTop label word
STAK ends

end          