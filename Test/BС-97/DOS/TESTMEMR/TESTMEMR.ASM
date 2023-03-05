Name TestMemr

Empty=1
NoEmpty=2

On=1
Off=2

True=0
False=1

Yes=1
No=2

Segm=1
Offs=2

;Constants for Mode

Testing=0
InAddrBeg=1
InAddrEnd=2
Waiting=3

DigPort=0
RezTestPort=9
VolumePort=8
ModePort=0Ah
KeyPort=2
KeybPortLow=0
KeybPortHigh=1

;_stack segment para 'stack'
;	dw 128 dup(?)
;StkPtr label word
;_stack ends

data segment 
	VolFix db Off
	StartFix db Off
	KeybFix db Off

	NumberKey db ?

	Position dw 4
	
	SegmOrOffs db Segm

	KeybImage dw ?
	SostKeyb db Empty

	SostKlav db 00000000b

	MassOtobr db 8 dup(?)

	Mode db Waiting
	Volume db 00000001b ; 16kB
	Vol dw ?,?
	Buf dw ?,?
	SizeBlock dw ?,?
	AbortTest db ?
; ADDRESSES
	SegmBegBlock db 11,8,0,0
	OffsBegBlock db 0,0,0,0
	SegmBegObl db 2,2,2,2
	OffsBegObl db 3,3,3,3
	SegmEndObl db 4,4,4,4
	OffsEndObl db 5,5,5,5
	SegmEndZone db 11,8,0,0
	OffsEndZone db 0,0,10,0

	LogAddrBlock dw ?,?
	LogBegAddrObl dw ?,?
	LogEndAddrObl dw ?,?
	LogAddrZone dw ?,?
	FizAddrBlock dw ?,?
	FizAddrZone dw ?,?

	FizAddrBlock2 dw ?,?

	Message db 13H,13H,10H,11H,0AH,0DH,0DH,12H
        AError db no
        DError db no
	Error  db ?
        NoTest db true

	Tabl db 3FH,0CH,76H,5EH,4DH,5BH,7BH,0EH,7FH,5FH
	     db 6FH,79H,33H,7CH,73H,63H    ,68H,78H,60H,00H

data ends

code segment
    assume cs:code,ds:data,es:data;,ss:_stack

OutDigits proc
	lea si,MassOtobr
        mov cx,length MassOtobr
	xor dx,dx
NextOut:mov al,[si]
        out dx,al
        inc dx
        inc si
        loop NextOut
	ret
OutDigits endp

KodirMassOtobr proc    ;  si-Pointer
	lea bx,Tabl
	lea di,MassOtobr
	mov cx,length MassOtobr
Again:	mov al,[si]
	xlat
	mov [di],al
	inc si
	inc di
	loop Again
	ret
KodirMassOtobr endp

VyvRezTest proc
	mov al,10000000b ; fictive bit
	cmp NoTest,True
	je  VyvodRezTest
	mov al,00000001b
	cmp DError,Yes
	jne NoDError
	mov al,00010000b
NoDError:cmp AError,Yes
	jne VyvodRezTest
	or  al,00000100b
	and al,11111110b
VyvodRezTest:out RezTestPort,al
	ret
VyvRezTest endp

VyvodVolume proc
	mov al,Volume
	out VolumePort,al
	ret
VyvodVolume endp

SelDispArray proc
	lea si,SegmBegBlock
	cmp Mode,Waiting
	je  DispWaitMode
	cmp Mode,InAddrBeg
	je  EndSelDispArray
	lea si,SegmEndZone
	jmp EndSelDispArray
DispWaitMode:cmp SostKlav,00000100b
	je  YesBegKlav
	cmp SostKlav,00001000b
	jne EndSelDispArray
	lea si,Message
	cmp NoTest,True
	je  EndSelDispArray
	cmp Error,Yes
	jne EndSelDispArray
	lea si,SegmEndObl
	jmp EndSelDispArray
YesBegKlav:lea si,Message
	cmp NoTest,True
	je  EndSelDispArray
	cmp Error,Yes
	jne EndSelDisparray
	lea si,SegmBegObl
EndSelDisparray:ret
SelDispArray endp

VyvodMode proc
	mov al,00010000b
    	cmp Mode,InAddrBeg
	je  SegmOrOffs?
	mov al,01000000b
	cmp Mode,InAddrEnd
	je  SegmOrOffs?
	mov al,10000000b
	jmp VyvMode
SegmOrOffs?:cmp SegmOrOffs,Segm
	jne  Offs?
	or  al,00000001b
	jmp VyvMode
Offs?:	or  al,00000100b

VyvMode:out ModePort,al
	ret
VyvodMode endp

SetMode	proc
	cmp Position,4
	je  YesSetMode
	jmp EndSetMode
YesSetMode:Test SostKlav,00000010b
	jnz YesPushStartKey
	mov StartFix,Off
	jmp SkanVolKey
YesPushStartKey:cmp StartFix,On
	je  SkanVolKey
	mov StartFix,On
	cmp Mode,Waiting
	je  YesWaitingMode
	mov Mode,Waiting
	ret
YesWaitingMode:mov Mode,Testing
	ret
SkanVolKey:test SostKlav,00000001b
	jnz YesPushVolKey
	mov VolFix,Off
	jmp SkanInKeys
YesPushVolKey:cmp VolFix,On
	je  SkanInKeys
	mov VolFix,On
	rol Volume,1
	rol Volume,1
SkanInKeys:test SostKlav,01000000b
	jz  SkanInKey1
	mov Mode,InAddrBeg
	jmp SegmOrOffsMode?
SkanInKey1:test SostKlav,10000000b
	jz  Segm_Offs
	mov Mode,InAddrEnd
	jmp SegmOrOffsMode?

Segm_Offs:test Mode,InAddrBeg
	je  SegmOrOffsMode?
	test Mode,InAddrEnd
	je  SegmOrOffsMode?
	jmp EndSetMode

SegmOrOffsMode?:test SostKlav,00010000b
	jz  OffsMode?
	mov SegmOrOffs,Segm
	ret
OffsMode?:test SostKlav,00100000b
	jz EndSetMode
	mov SegmOrOffs,Offs
EndSetMode:ret
SetMode endp

FormirDigit proc	; dx - Obraz KeyBoard
	mov SostKeyb,Empty
	mov al,dl
	or  al,dh
	jz  EndFormirDigit
	mov SostKeyb,NoEmpty
	mov bl,0
NextKey:shr dx,1
	jc  EndFormirDigit
	inc bl
	loop NextKey
EndFormirDigit:ret	;  bl - Number Key
FormirDigit endp

FormirAddr proc
	cmp SostKeyb,NoEmpty
	je  NoEmptyKeyb
	mov KeybFix,Off
	ret
NoEmptyKeyb:cmp KeybFix,On
	je  EndFormirAddr
	mov KeybFix,On
	lea di,SegmBegBlock
	cmp Mode,InAddrBeg
	je  InBegin
	lea di,SegmEndZone
InBegin:cmp SegmOrOffs,Segm
	je  InSegment
	add di,4
InSegment:cmp Position,4
	jne OldAddress
	mov word ptr Position,0
	mov word ptr [di],1313h
	mov word ptr [di+2],1313h
OldAddress:mov bl,NumberKey
	add di,Position
	mov byte ptr [di],bl
	inc Position
EndFormirAddr:	ret
FormirAddr endp

VolumeSize proc
	mov Vol,0
	mov Vol+2,16*1024
	cmp Volume,1
	je EndVS
	mov Vol+2,32*1024
	cmp Volume,4
	je EndVS
	inc Vol
	mov Vol+2,0
	cmp Volume,16
	je EndVS
	inc Vol
EndVS:	ret
VolumeSize endp

FormLogAddr proc
	mov ah,[si]     ;Segment
	rol ah,1
	rol ah,1
	rol ah,1
	rol ah,1
	mov dl,[si+1]
	or  ah,dl
	mov al,[si+2]
	rol al,1
	rol al,1
	rol al,1
	rol al,1
	mov dl,[si+3]
	or  al,dl
	mov [di],ax

	mov ah,[si+4]   ;Offset
	rol ah,1
	rol ah,1
	rol ah,1
	rol ah,1
	mov dl,[si+5]
	or  ah,dl
	mov al,[si+6]
	rol al,1
	rol al,1
	rol al,1
	rol al,1
	mov dl,[si+7]
	or  al,dl
	mov [di+2],ax
	ret
FormLogAddr endp

FormFizAddr proc
	mov word ptr [di],0
	mov ax,[si]
	shl ax,1
	rcl word ptr [di],1
	shl ax,1
	rcl word ptr [di],1
	shl ax,1
	rcl word ptr [di],1
	shl ax,1
	rcl word ptr [di],1
	add ax,[si+2]
	adc word ptr [di],0
	mov [di+2],ax
	ret
FormFizAddr endp

ConvLogAddr proc
	mov bp,0
	mov cx,8
CLA2:	mov dl,0
	mov dh,4
CLA1:	shl bx,1
	rcl ax,1
	rcl dl,1
	dec dh
	jnz CLA1
	mov cs:[di+bp],dl
	inc bp
	loop CLA2
	ret
ConvLogAddr endp

DTest proc
	mov AbortTest,No
	mov DError,No
	lea di,SegmBegObl
	mov ax,LogAddrBlock
	mov es,ax
	mov bx,LogAddrBlock+2

NextDTest:mov dh,es:[bx]

	mov dl,01010101b
	mov es:[bx],dl
	mov al,es:[bx]
	cmp dl,dl
	jne YesDError

	mov dl,10101010b
	mov es:[bx],dl
	mov al,es:[bx]
	cmp al,dl
	jne YesDError

	mov es:[bx],dh
	jmp TestDStop?

YesDError:
	cmp DError,No
	je  FirstDError
	lea di,SegmEndObl
FirstDError:mov ax,es
	call ConvLogAddr
	mov DError,Yes

TestDStop?:in al,KeyPort
	test al,00000010b
	jnz  StopDtest?
	mov StartFix,Off
	jmp ContDtest
StopDTest?:cmp StartFix,On
	je  ContDTest
	mov StartFix,On
	mov AbortTest,Yes
	ret

ContDTest:inc bx
	jnz NoIncSeg
	mov ax,es
	add ax,1000h
	mov es,ax
NoIncSeg:sub Vol+2,1
	sbb Vol,0
	mov ax,Vol
	or  ax,Vol+2
	jnz NextDTest
	
	ret
DTest endp

ATest proc
	mov AError,No
	mov AbortTest,No

	mov ax,Buf
	mov Vol,ax
	mov ax,Buf+2
	mov Vol+2,ax

	mov ax,LogAddrBlock
	mov es,ax
	mov bx,LogAddrBlock+2

	mov bp,FizAddrBlock
	mov cx,FizAddrBlock+2

NextATest1:mov Byte ptr es:[bx],00000000b
	mov ax,bp
	xor ax,cx
	xor al,ah
	jp  ContATest1
	mov Byte ptr es:[bx],11111111b
ContATest1:
	add cx,1
	adc bp,0
	inc bx
	jnz NoIncSegm1
	mov ax,es
	add ax,1000h
	mov es,ax
NoIncSegm1:sub Vol+2,1
	sbb Vol,0
	mov ax,Vol
	or  ax,Vol+2
	jnz NextATest1

	mov ax,Buf
	mov Vol,ax
	mov ax,Buf+2
	mov Vol+2,ax

	mov bp,FizAddrBlock
	mov cx,FizAddrBlock+2

	mov bx,LogAddrBlock+2
NextATest2:mov dl,00000000b
	mov ax,bp
	xor ax,cx
	xor al,ah
	jp  ContATest2
	mov dl,11111111b
ContATest2:cmp byte ptr es:[bx],dl
	jne YesAError
	jmp TestAStop?2

YesAError:
	mov AError,Yes

TestAStop?2:in al,KeyPort
	test al,00000010b
	jnz  StopAtest?2
	mov StartFix,Off
	jmp ContAtest
StopATest?2:cmp StartFix,On
	je  ContATest
	mov StartFix,On
	mov AbortTest,Yes
	ret

ContATest:
	add cx,1
	adc bp,0
	inc bx
	jnz NoIncSegm2
	mov ax,es
	add ax,1000h
	mov es,ax
NoIncSegm2:sub Vol+2,1
	sbb Vol,0
	mov ax,Vol
	or  ax,Vol+2
	jnz NextATest2

	ret
Atest endp

start:	;mov ax,_stack
	;mov ss,ax
	;lea sp,StkPtr
	mov ax,data
	mov ds,ax
	mov es,ax
Begin:
	cmp Mode,Testing	;Режим теста ?
	je  TestingMode		;Да-выполнить тест

	mov Error,Yes		;Формирование сообщения
	cmp AError,Yes		; об ошибках
	je  YesError
	cmp DError,Yes
	je  YesError
	mov Error,No
YesError:
				;Формирование массива отображения
	call SelDispArray	; Выбор массива отображения
	call KodirMassOtobr	; Кодирование массива отображения

	call OutDigits		;Вывод цифровой информации
	call SetMode		;Установка режима
	call VyvodVolume	;Вывод обьема блока
	call VyvodMode		;Вывод сообщения о режиме

	in al,KeyPort		;Ввод кнопок
	mov SostKlav,al

	call VyvRezTest		;Вывод сообщений о результате тестирования

	in  al,KeybPortLow	;Ввод клавиатуры
	mov dl,al
	in  al,KeybPortHigh
	mov dh,al

				;dx-Образ клавиатуры
	call FormirDigit	;Формирование очередной цифры
				;bl-Номер клавиши (0..15)
	mov NumberKey,bl

	call FormirAddr		;Формирование адреса
	jmp Begin

TestingMode:
	mov al,01000000b
	out RezTestPort,al

	lea si,SegmBegBlock
	lea di,LogAddrBlock
	call FormLogAddr		;Формирование лог.адресa нач блока

        lea si,SegmEndZone
	lea di,LogAddrZone
	call FormLogAddr		;Формирование лог.адресa конц зоны
	
	lea si,LogAddrBlock
	lea di,FizAddrBlock
	call FormFizaddr	;Формир физ адр нач блока

	lea si,LogAddrZone
	lea di,FizAddrZone
	call FormFizaddr	;Формир физ адр конца зоны

	mov ax,FizaddrZone+2
	sub ax,FizAddrBlock+2
	mov SizeBlock+2,ax
	mov ax,FizaddrZone
	sbb ax,FizAddrBlock
	mov SizeBlock,ax
	jc  EndTest	
	or  ax,SizeBlock+2
	jz  EndTest

	call VolumeSize		;Формирование обьема блока

	mov ax,SizeBlock
	sub ax,Vol
	jc  MinVol
	jnz NoMin
	mov ax,SizeBlock+2
	sub ax,Vol+2
	jc  MinVol
	jmp NoMin
MinVol:	mov ax,SizeBlock
	mov Vol,ax
	mov ax,SizeBlock+2
	mov Vol+2,ax
NoMin:
	mov ax,Vol
	mov Buf,ax
	mov ax,Vol+2
	mov Buf+2,ax

	call DTest		;Тест ШД
	cmp AbortTest,Yes
	je  EndTest

	call ATest		;Тест ША
	cmp AbortTest,Yes
	je  EndTest	

	mov NoTest,false
	mov Mode,Waiting
	jmp Begin

EndTest:mov NoTest,true
	mov Mode,Waiting
	jmp Begin
code ends
end start