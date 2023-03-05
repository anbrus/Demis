On  = 0FFh
Off = 00h
Blank=00h

TimeHz=5 

Waiting=00h
Input=01h
Count=02h

ESPort = 03h
DSPOrt = 02h
EMPort = 01h
DMPort = 00h

BinPort = 04h

ButPort = 00h

data segment
  Flasher db 0
  Timer db TimeHz

  InFixator db Off
  SelFixator db Off
  StartFixator db Off

  Buttons db 00000000b
  Mode   db Waiting
  Position db 3

  Digits db 0,0,0,0
  Bufer  db 0,0,0,0

  DispArray db ?,?,?,?
  DigTable db 3FH,0CH,76H,5EH,4DH,5BH,7BH,0EH,7FH,5FH	
data ends

code segment
  assume DS:data,CS:code
Start:  mov ax,data
        mov ds,ax
Begin:
;***** FormirMassOtobr *****
        lea bx,DigTable
	lea si,Digits
	lea di,DispArray
	mov cx,4
Formir: mov al,[si]
	xlat
	mov [di],al
	inc si
	inc di
	loop Formir
	cmp Mode,Input
	jne EndFormir
	inc Flasher
	test Flasher,00000001b
	jnz EndFormir
	lea bx,DispArray
	add bl,Position
	mov byte ptr [bx],Blank
EndFormir:

;***** OutDigInfo *****
        lea bx,DispArray
	mov al,[bx]
	out ESPort,al
	mov al,[bx+1]
	out DSPort,al
	mov al,[bx+2]
	out EMPort,al
	mov al,[bx+3]
	out DMPort,al 

;***** OutMessage *****
        mov al,11110000b
	cmp Mode,Waiting
	je  ActiveInd
	mov al,00h
	cmp Mode,Input
	je  ActiveInd
	cmp word ptr Digits+2,0000h ;min>0?
	ja ActiveInd
	cmp word ptr Digits,0100h ; =10 sec
	ja  ActiveInd
	mov al,11110000b
	cmp word ptr Digits,00h
	je  ActiveInd
	mov al,00001111b
ActiveInd:out BinPort,al

;***** InButtons *****
	in al,ButPort
	mov Buttons,al

;***** InModes *****
	cmp Mode,Input
	jne CnWtMode
;----- TestSelBut -----
	test Buttons,00010000b
	jnz YesPushSelBut
	mov SelFixator,Off
	jmp EndInModes
YesPushSelBut:cmp SelFixator,On
	jne NewPushSelBut
	jmp EndInModes
NewPushSelBut:mov SelFixator,On
	cmp Position,00h
	je QuitFromInMode
	dec Position
	jmp EndInModes
QuitFromInMode:mov Mode,Waiting
	mov Position,03h
	mov dx,word ptr Digits
	mov word ptr Bufer,dx
	mov dx,word ptr Digits+2
	mov word ptr Bufer+2,dx
	jmp EndInModes

CnWtMode:cmp Mode,Count
	jne WaitMode
;----- TestStartBut -----
	test Buttons,10000000b
	jnz YesPushStartBut
	mov StartFixator,Off
	mov dx,word ptr Digits
	or  dx,word ptr Digits+2
	jnz EndInModes
	jmp ToWaitMode
YesPushStartBut:cmp StartFixator,On
	je EndInModes
	mov StartFixator,On
ToWaitMode:mov dx,word ptr Bufer
	mov word ptr Digits,dx
	mov dx,word ptr Bufer+2
	mov word ptr Digits+2,dx
	mov Mode,Waiting
	jmp EndInModes

;----- TestWtMode -----
WaitMode:test Buttons,10000000b
	jz NoPushStartBut
	cmp StartFixator,On
	je EndInModes
	mov ax,word ptr Digits
	or ax,word ptr Digits+2
	jz EndInModes
	mov StartFixator,On
	mov Mode,Count
	jmp EndInModes
NoPushStartBut:mov StartFixator,Off
	test Buttons,00010000b
	jnz PushSelBut
	mov SelFixator,Off
	jmp EndInModes
PushSelBut:cmp SelFixator,On
	je EndInModes
	mov SelFixator,On
	mov Mode,Input
EndInModes:

;***** FormirDispData *****
	cmp Mode,Input
	jne WCMode
;----- FormDataInMode -----
	test Buttons,00000001b
	jnz YesPushDigBut
	mov InFixator,Off
	jmp Ende
YesPushDigBut:cmp InFixator,On
	jne IncDig
	jmp Ende
IncDig:	mov InFixator,On
	mov al,10
	test Position,00000001b
	jz ChetnPos
	mov al,6
ChetnPos:lea bx,Digits
	add bl,Position
	inc byte ptr [bx]
	cmp byte ptr [bx],al
	jne Ende
	mov byte ptr [bx],0
	jmp Ende

WCMode:	cmp Mode,Count
	jne Ende
;----- FormDataCnMode -----		
	cmp Timer,0
	je Decrement
	dec Timer
	jmp Ende
Decrement:mov Timer,TimeHz
	;*********
	mov ax,word ptr Digits
	mov dx,word ptr Digits+2
	sub al,1
	aas
	mov bl,al
	mov al,ah
	sub al,0
	aas
	mov bh,al
	mov al,dl
	sbb al,0
	aas
	mov dl,al
	mov al,dh
	sbb al,0
	aas
	mov dh,al

	cmp bh,9
	jne MoveMass
	mov bh,5
MoveMass:mov word ptr Digits,bx
	mov word ptr Digits+2,dx

Ende:jmp begin

code ends
end start