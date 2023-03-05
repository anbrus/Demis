
data segment at 0BA00H
	IndMenu db ?
	CurSeg  db ?
	WashPr	db ?,?,?,?
	MaxPr	db ?,?,?,?
	PrSt    db ?,?,?,?,?,?,?,?,?
	PrOt    db ?,?,?,?,?,?,?,?,?
	PrT     db ?,?,?,?
	StTemp  db ?
	StirTm  db ?
	OtjmTm  db ?
		
	btUp	db ?
	btDown	db ?
	btStart db ?
	btStop  db ?

	flWash  db ?
	flFull	db ?
	flErr	db ?

        Map	db 0AH dup (?)
	Segm	db 4 dup (?)
	Temp    dw ?
data ends 

code segment 

	assume cs:code,ds:data

Prepare proc
	mov  IndMenu, 0
	mov  CurSeg, 0
	mov  btUp, 0
	mov  btDown, 0
	mov  btStart, 0
	mov  btStop, 0
	mov  flWash, 0
	mov  flFull, 0
	mov  flErr, 0
	mov  StTemp, 20
	mov  MaxPr[0], 6
	mov  MaxPr[1], 6
	mov  MaxPr[2], 3
	mov  MaxPr[3], 3
	mov  WashPr[0], 0
	mov  WashPr[1], 0
	mov  WashPr[2], 0
	mov  WashPr[3], 0

	mov  cx, 7
	mov  bx, 0
	mov  ax, 0

a1:	mov  PrSt[bx], al
	add  al, 5
	inc  bl
	loop a1

	mov  cx, 7
	mov  bx, 0
	mov  ax, 0
a2:	mov  PrOt[bx], al
	add  al, 5
	inc  bl
	loop a2

	mov  PrT[0], 0
	mov  PrT[1], 40
	mov  PrT[2], 60
	mov  PrT[3], 95

        mov  Map[0], 3FH
        mov  Map[1], 0CH
        mov  Map[2], 76H
        mov  Map[3], 05EH
        mov  Map[4], 4DH
        mov  Map[5], 5BH
        mov  Map[6], 7BH
        mov  Map[7], 0EH
        mov  Map[8], 7FH
        mov  Map[9], 5FH

	mov  Segm[0], 1
	mov  Segm[1], 2
	mov  Segm[2], 4
	mov  Segm[3], 64
	mov  al, 0
	out  06, al

	ret
Prepare EndP


ReadKey proc
	in   al, 0Ah	
	and  al, 3
	jz   ReadKeyEnd
	cmp  al, 1
	je   StartPress
	cmp  al, 2
	jne  ReadKeyEnd
	cmp  IndMenu, 3
	je   MenuFirst
	inc  IndMenu
	jmp  ReadKeyEnd
MenuFirst:
	mov  IndMenu, 0
	jmp  ReadKeyEnd
StartPress:
	cmp  flWash, 0FFh
	jne  PrStart
	mov  btStop, 0FFh
	jmp  ReadKeyEnd
PrStart:
	mov  btStart, 0FFh
ReadKeyEnd:
	in   al, 0Ah
	and  al, 3
	jnz  ReadKeyEnd

	ret
ReadKey EndP

ReadSelKey proc
	cmp  flWash, 0FFh
	je   RSK

	in   al, 09h
	and  al, al
	jz   NotPressSel
	cmp  al, 1
	je   Up
	cmp  al, 2
	jne  NotPressSel
	mov  btDown, 0FFh
	jmp  NotPressSel
Up:	mov  btUp, 0FFh
	jmp  NotPressSel
	
NotPressSel:
    	in   al, 09h
	and  al, al
	jnz  NotPressSel
RSK:	ret
ReadSelKey EndP

ShowMenu proc
	cmp  flWash, 0FFh       ;
	je   SMExit		; проверка флага стирки

	mov  cl, IndMenu	; 
	mov  al, 1		;формирование кода	
	shl  al, cl		;для порта индикации
    	out  05, al		;позиции меню

	mov  bl, cl		;получение номер значения
	mov  bh, 0		;параметра текущего 
	mov  al, WashPr[bx]     ;пункта меню

	mov  ah, 0				;
 	mov  bx, ax				;
 	mov  ax, offset MnuOp1 - offset MnuOp0  ;
 	mul  cl				;
 	add  ax, offset MnuOp0		;
	jmp  ax				;
MnuOp0:	mov  al, PrSt[bx]		;преобразование номера 
	jmp  ShowMenuEnd		;значения параметра в
MnuOp1:	mov  al, PrOt[bx]		;его величину
	jmp  ShowMenuEnd		;
MnuOp2:	mov  al, PrT[bx]		;
	jmp  ShowMenuEnd		;
MnuOp3:	mov  ax, bx			;

ShowMenuEnd:
	mov  ah, 0	;
	mov  dx, ax	;
	mov  bl, 10	;
	div  bl		;
	and  al, al	; отображение старшего
	jz   SM1	; байта на индикаторе
	lea  bx, Map	;
	xlat		;
	out  03, al 	;
	jmp  SM2	;
SM1:	mov  al, 0	;
	out  03, al	;

SM2:	mov  ax, dx	;
	mov  bl, 10	;
	div  bl		;
	mov  al, ah	; отображение младшего
	lea  bx, Map	; байта на индикаторе
	xlat		;
	out  04, al 	;
SMExit:	
	ret
ShowMenu EndP

SetParam proc
	cmp  flWash, 0FFh	;
	je   SetParamEnd	; проверка флага стирки

	cmp  btUp, 0FFh		; 
	jne  chflDown		; проверка флага кнопки "+"

	mov  btUp, 0		; если нажата кнопка "+"
	mov  bl, IndMenu
	mov  bh, 0
	mov  al, MaxPr[bx]	; и текущее значение 
	cmp  WashPr[bx], al	; парметра меню не максимальное
	je   SetParamEnd
	inc  WashPr[bx]		; то инкриментируем его
chflDown:
	cmp  btDown, 0FFh	;
	jne  SetParamEnd	; проверка флага кнопки "-"

	mov  btDown, 0		; если нажата кнопка "-"
	mov  bl, IndMenu
	mov  bh, 0
	cmp  WashPr[bx], 0	; и текущее значение 
	je   SetParamEnd	; парметра меню не минимпльное
	dec  WashPr[bx]		; то декриментируем его

SetParamEnd:
	ret
SetParam EndP

Filling proc
	cmp  btStart, 0FFh	;
	jne  FillEx		; проверка флага кнопки старт

	cmp  flErr, 0FFh	;
	je   FillEx		; проверка флага ошибки

	mov  flWash, 0FFh	; устанавливаем флаг стирки

	mov  al, WashPr[0]	;
	mov  ah, 0		; получаем время стирки
	mov  bl, 5		; в минутах
	mul  bl			;
	mov  StirTm, al		;

	mov  al, WashPr[1]	;
	mov  ah, 0		; получаем время отжима
	mov  bl, 5		; в минутах
	mul  bl			;
	mov  OtjmTm, al		;

	mov  al, 0
	mov  cx, 08h
Fill1:	
	push cx			;
	mov  cx, 0FFFh		;
Fill2:	loop Fill2		; наполнение,
	pop  cx			; формирование задержки
	stc			; наполнения, а также 
	rcr  al, 1 		; отображения количества
	out  06, al		; воды в баке
	out  0Ch, al		;
	loop Fill1		;

	mov  al, StTemp		;
	mov  ah, 0		;
	mov  dx, ax		;
	mov  bl, 10		; отображение старшего 
	div  bl			; разряда температуры воды
	lea  bx, Map		; в баке
	xlat			;
	out  01, al 		;

	mov  ax, dx		;
	mov  bl, 10		;
	div  bl			; 
	mov  al, ah		; отображение младшего
	lea  bx, Map		; разряда температуры воды
	xlat			; в баке
	out  02, al 		;

	mov  flFull, 0FFh	; устанавливаем флаг 
				; наполнености бака
FillEx:	ret
Filling EndP

Drushing proc
	cmp  flWash, 0FFh	; проверка флага стирки
	jne  DrushEx

	cmp  flErr, 0FFh	; проверка флага ошибки
	je   DrushEx

	cmp  StirTm, 0		
	jne  DrushEx		; время стирки = 0 ?
  	cmp  OtjmTm, 0
	je   DrushEx		; время отжима = 0 ?
	cmp  flFull, 0FFh
	jne  DrushEx		; бак полон ?

	mov  al, 0FFh		;
	mov  cx, 08h		;
Drush1:		
	push cx			;
	mov  cx, 0FFFh		;
Drush2: loop Drush2		; слив,
	pop  cx			; формирование задержки 
	clc			; и отображения кол.
	rcl  al, 1 		; воды в баке
	out  06, al		;
	out  0Ch, al		;
	loop Drush1		;
	mov  flFull, 0		;
	mov  al, 0		;
	out  01, al		;
	out  02, al		;
DrushEx:ret
Drushing EndP

Wash proc
	cmp  flErr, 0FFh
	je   WashTrace		; проверка флага ошибки

	cmp  flWash, 0FFh	; проверка флага стирки
	jne  WashTrace

	cmp  StirTm, 0		; время стирки = 0 ?
	je   WashTrace

	cmp  temp, 0
	jz   WashInit
	dec  temp		; уменьшение оставшегося 
	jmp  WashEnd		; времени стирки
WashInit:
	mov  al, WashPr[3]	;
	inc  al			; подсчет количества 
	mov  ah, 0		; тиков которое таймер
	shl  ax, 6		; должен сделать до того
	mov  Temp, ax		; как наступит конец стирки

	cmp  StirTm, 0		; 
	je   WashEnd		; время стирки = 0 ?

	mov  al, 21h		; вывод режима в котором
	out  05, al		; находится машина
	dec  StirTm		; уменьшение прошедшего времени

	mov  al, StirTm		;
	mov  ah, 0		;
	mov  dx, ax		;
	mov  bl, 10		;
	div  bl			;
	and  al, al		; вывод старшего разряда
	jz   Wa1		; оставшегося времени
	lea  bx, Map		;
	xlat			;
	out  03, al 		;
	jmp  Wa2		;

WashTrace:
	jmp  WashExit

Wa1:	mov  al, 0		;
	out  03, al		;
Wa2:	mov  ax, dx		;
	mov  bl, 10		; вывод младшего разряда
	div  bl			; оставшегося времени
	mov  al, ah		;
	lea  bx, Map		;
	xlat			;
	out  04, al 		;
WashEnd:	
	mov  ax, temp		;
	shl  al, 4		; стирка закончена ?
	cmp  al, 0		;
	jne  WashExit		;

	cmp  CurSeg, 3		; если нет, то 
	je   Wash1		; изображаем текущий 
	inc  CurSeg		; сегмент положения  
	jmp  Wash2		; барабана
Wash1:	mov  CurSeg, 0		;
Wash2:	mov  bl, CurSeg		;
	mov  bh, 0		;
	mov  al, Segm[bx]	;
	out  07, al		;

WashExit:
	ret
Wash EndP

Extract proc
	cmp  flWash, 0FFh
	jne  ExtrTrace		; проверяем флаг стирки

	cmp  flErr, 0FFh	; проверяем флаг ошибки
	je   ExtrTrace

	cmp  StirTm, 0		; время стирки = 0 ?
	jne  ExtrTrace

	cmp  OtjmTm, 0		; время отжима = 0 ?
	je   ExtrTrace

	cmp  temp, 0		;
	jz   ExtrInit		; 
	dec  temp		;
	jmp  ExtrEnd		;
ExtrInit:
	mov  al, WashPr[3]
	inc  al
	mov  ah, 0
	shl  ax, 6
	mov  Temp, ax

	cmp  OtjmTm, 0	
	je   ExtrEnd
	mov  al, 22h
	out  05, al
	dec  OtjmTm
	mov  al, OtjmTm
	mov  ah, 0
	mov  dx, ax
	mov  bl, 10
	div  bl
	and  al, al
	jz   Ea1
	lea  bx, Map
	xlat
	out  03, al 
	jmp  Ea2
ExtrTrace:
	jmp  ExtrExit
Ea1:	mov  al, 0
	out  03, al
Ea2:	mov  ax, dx
	mov  bl, 10
	div  bl
	mov  al, ah
	lea  bx, Map
	xlat
	out  04, al 
ExtrEnd:
	mov  ax, temp
	shl  al, 6
	cmp  al, 0
	jne  ExtrExit

	cmp  CurSeg, 3
	je   Extr1
	inc  CurSeg
	jmp  Extr2
Extr1:	mov  CurSeg, 0

Extr2:	mov  bl, CurSeg
	mov  bh, 0
	mov  al, Segm[bx]
	out  07, al

ExtrExit:
	cmp  btStop, 0FFh
	jne  ExtrRet1
  	mov  btStop, 0h
	mov  flWash, 0h
ExtrRet1:
	cmp  OtjmTm, 0
	jne  ExtrRet2
	cmp  StirTm, 0
	jne  ExtrRet2
  	mov  btStop, 0h
	mov  flWash, 0h
ExtrRet2:ret
Extract EndP

Warm proc
	cmp  btStart, 0FFh
	jne  WarmEnd

	cmp  flErr, 0FFh
	je   WarmEnd

	mov  btStart, 0

	mov  bl, WashPr[2]
	and  bl, bl
	jz   WarmEnd

	mov  cl, IndMenu	;
	mov  al, 1		;
	shl  al, cl		; индуцируем сигнал об 
	or   al, 0A0h		; нагреве
	out  05, al		;

	mov  bh, 0
	mov  cl, PrT[bx]
	sub  cl, StTemp
	mov  dl, StTemp
W1:	push cx
	mov  cx, 0FFFH
W2:	loop W2
	inc  dl

	mov  al, dl
	mov  ah, 0
	mov  dx, ax
	mov  bl, 10
	div  bl
	lea  bx, Map
	xlat
	out  01, al 

	mov  ax, dx
	mov  bl, 10
	div  bl
	mov  al, ah
	lea  bx, Map
	xlat
	out  02, al 

	pop  cx
	loop W1
WarmEnd:
	ret
Warm EndP

Err proc
	cmp  btStart, 0FFh	; проверяем флаг кнопки старт
	jne  ErrTr

	cmp  WashPr[0], 0	; задано время стирки ?
	jz   Err1

	cmp  WashPr[1], 0	; задано время отжима
	jz   Err2

	in   al, 0Ah		;
	mov  bl, al		; открыт ли слив
	and  bl, 10h		;
	jz   Err3		;

	mov  bl, al		;
	and  bl, 20h		; открыта ли подача
	jz   Err4		;

	mov  flErr, 00h		; если ошибок нет 
	jmp  ErrTr		; снимаем флаг ошибки

Err1:	mov  al, 73h
	out  01, al
	mov  al, 23h		; отображаем ошибку № 1
	out  02, al		; 
	mov  al, 0		;
	out  03, al
	mov  al, Map[1]
	out  04, al
	jmp  ErrEnd

Err2:	mov  al, 73h
	out  01, al
	mov  al, 23h
	out  02, al		; отображаем ошибку № 2
	mov  al, 0
	out  03, al
	mov  al, Map[2]
	out  04, al
	jmp  ErrEnd

ErrTr:  jmp  ErrEx

Err3:	mov  al, 73h
	out  01, al
	mov  al, 23h
	out  02, al
	mov  al, 0		; отображаем ошибку № 3
	out  03, al
	mov  al, Map[3]
	out  04, al
	jmp  ErrEnd

Err4:	mov  al, 73h
	out  01, al
	mov  al, 23h
	out  02, al
	mov  al, 0		; отображаем ошибку № 4
	out  03, al
	mov  al, Map[4]
	out  04, al

ErrEnd:
	mov  flErr, 0FFh	; устанавливаем флажок ошибки

	in   al, 0Ah		;
	mov  bl, al		;
	and  bl, 0Fh		; ждем нажатия любой кнопки 
	in   al, 09h		; 
	or   al, bl		;
	jz   ErrEnd		;

	mov  al, 0		; 	
	out  01, al		;
	out  02, al		; гасим индикаторы
	out  03, al		;
	out  04, al		;

	mov  btStart, 0		; снимаем флаг кнопки старат

ErrEx:	ret
Err EndP

begin:  mov  ax,data
	mov  ds,ax
	mov  ax,stack
	mov  ss, ax       
	mov  sp, offset StkTop 

	call Prepare
a:	call ReadKey
	call ReadSelKey
	call SetParam
	call ShowMenu		
	call Err
	call Filling
	call Warm
	call Wash
	call Drushing
  	call Extract
	jmp  a

	org 07F0H
start:  jmp begin

code ends

stack segment at 0BA80H
  db 200H dup (?)
  StkTop label word
stack ends

end start
