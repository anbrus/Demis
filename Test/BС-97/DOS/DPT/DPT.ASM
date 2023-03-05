page	70,132
	Name	Motor
STACKG	SEGMENT	PARA STACK 'Stack'
	DW	32 DUP(?)
STACKG	ENDS
;----------------------------------------
DATASG	SEGMENT PARA 'Data'
StopStart	DB 0
SecondInc	DB ?
SecondDec	DB ?
Spid1		DB ?
Spid2		DB ?
Spid3		DB ?
Spid4		DB ?
TablSym		DB 3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7Fh,5Fh,40h
TimeInSecond	DB 0 ;{12}
InSpid		DB 1	;заданная скор.
SPIDINFO	DW 9675

TekInSpid	DB 2	;текущ. скор. вывода на ДВ.
SHIM		DB ? ;ШИM
dopSHIM		DB ? ;неизменяемая ШИМ для доп. использов.
Takt		DW 0 ;счётчик тактов
IndicNumbe8	DB 0 ;индик. номера скорости	
CouSS		DB 0 ; - - - - - - - - 
Count		DB 0 ;счетчик ожидания удерж_я клавиши
CoundVar	DB 0 ;дискрета изменения времени
DATASG	ENDS
;---------------------------------------------
CODESG	SEGMENT
	ASSUME	CS:CODESG,DS:DATASG,SS:STACKG
;--------------	Описанае процедур ----------
;(П)	Задержка , Счёт времени
;	~~~~~~~~~~~~~~~~~~~~~~~
CouTime	PROC	NEAR	
	CMP	StopStart,0
	JZ	M1	
    ;--- счёт ---
	INC 	Takt		;inc счётчика тактов
	CMP 	Takt,4	;условие if <= Xh то вых.  
	JB 	M1	
	DEC 	TimeInSecond	;dec врем. , обнул. сч. тактов 
	MOV 	Takt,0
   ;--- время кончилось ---
	CMP	TimeInSecond,0
	JNBE	M1
	MOV	StopStart,0
M1:	RET
	ENDP
;(ОП)	Формирование цифры отображ. и вывод на дисплей
;	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OutDisp PROC	NEAR
	LEA	BX,TablSym
	MOV	AL,TimeInSecond
	AAM	
	XLAT
	OUT	1,AL
	MOV	AL,AH
	XLAT
 	OUT	0,AL	
	RET
OutDisp ENDP
;(ОП)	Ввод   режимов
;	~~~~~~~~~~~~~~
KbdIn	PROC	NEAR
	MOV	AL,1
	NEG	AL
	MOV	AL,2
	NEG	AL
	MOV	AL,3
	NEG	AL
	MOV	AL,4
	NEG	AL

	IN	AL,3
     ;--- Пуск/Стоп ---
 	MOV	AH,AL
 	SHL	AH,1
	JNC	S0
	MOV	CouSS,1
	JMP	SX
S0:	CMP	CouSS,1
	JNZ	SX
	 CMP	TimeInSecond,0	;-C-
	 JZ	SZ		;-Ч-
	  ADD	StopStart,1	;-Ё-
	  NEG	StopStart	;-Т-
SZ:	  MOV	CouSS,0
SX:
	;---время---
	MOV	AL,0
	ROL	AX,1
	MOV	SecondDec,AL
	MOV	AL,0
	ROL	AX,1
	MOV	SecondInc,AL
	;---скорость---
	MOV	AL,0	
	ROL	AX,1	;№4
	MOV	Spid4,AL
	MOV	AL,0	
	ROL	AX,1	;№3
	MOV	Spid3,AL
	MOV	AL,0	
	ROL	AX,1	;№2
	MOV	Spid2,AL
	MOV	AL,0	
	ROL	AX,1	;№1
	MOV	Spid1,AL
	RET
KbdIn	ENDP
;(О)	Формировани набир.времени
;	~~~~~~~~~~~~~~~~~~~~~~~~~
FormTim	PROC	NEAR
	CMP	StopStart,0
	JNZ	FTend
	MOV	DL,SecondInc	
	MOV	DH,SecondDec	
	CMP	DX,0
	JZ	Fout	

	MOV	CoundVar,1
	INC	Count		;счёт
	CMP	Count,2 	;тактов
	JNZ	MMM
	MOV	CoundVar,5
MMM:	 CMP	DH,1	    ;-N-
	 JNZ	Fplus	    ;-E-
	 NEG	CoundVar    ;-G-
Fplus:	MOV	AL,CoundVar
	 CMP	AL,0	;<0
	 JNG	A0  	; yes -> A0
	 CMP	AL,5
	 JNZ	FTend
	 JMP	Fout	 
A0:	 CMP	AL,-5
	 JNZ	FTend
Fout:	MOV	AL,TimeInSecond
	ADD	AL,CoundVar
	 CMP	AL,99
	 JNG	Gut ;<=99 
	 MOV	AL,00	
Gut:	 CMP	AL,0
	 JNL	SerGut ;>=0
	 MOV	AL,99
SerGut:	MOV	TimeInSecond,AL
	MOV	Count,0
	MOV	CoundVar,0
FTend:	RET
FormTim	ENDP
;(ОП)	Формир.скор.и выдача подтвержденея на светодид
;	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
InSpSv	PROC	NEAR
	MOV	AL,1 ;AH-счётчик скорости
	CMP	Spid1,1
	JZ	NmbeSp
	INC	AL
	CMP	Spid2,1
	JZ	NmbeSp
	INC	AL
	CMP	Spid3,1
	JZ	NmbeSp
	INC	AL
	CMP	Spid4,1
	JZ	NmbeSp
	JMP	Iexit
NmbeSp:	MOV	InSpid,AL ;!!! знач. input скор.
	MOV	CL,AL
	MOV	AL,1
	SHL	AL,CL
	OUT	8,AL 
Iexit:	RET
InSpSv	ENDP
;(П)	Вывод управлерия
;	~~~~~~~~~~~~~~~~
UnEmul	PROC	NEAR
	CMP	StopStart,0
	JE	Mpic
      ;--- Ш И M ----

	MOV	AL,11111111b
	MOV	CL,InSpid
	DEC	CL
	SHL	CL,1
	SHR	AL,CL
	OUT	9,AL

	MOV	AH,InSpid
	CMP	AH,TekInSpid
	JE	Mign	

	MOV	SHIM,AL
	;MOV	dopSHIM,AL

	MOV	AL,InSpid
	MOV	TekInSpid,AL
     ;--- миган. св_диода ---
Mign:	
	MOV	AL,1
	MOV	AH,SHIM	
	ROL	AH,1
	JC	Diod1		
	MOV	AL,0  

Diod1:	OUT	0Ah,AL ;зажеч ДВ.
	MOV	SHIM,AH
	JMP	Mexit

Mpic:	MOV	AL,0  ;потушить ШИР
	OUT	9,AL
	MOV	AL,0  ;потушить ДВ.
	OUT	0Ah,AL		
Mexit:	RET
UnEmul	ENDP

;(ОП)	Формирование цифры отображ. и вывод на дисплей
;	~~~~~~~~С К О Р О С Т Ь~~~~~~~~~~~~~~~~~~~~~~
OutSpid PROC	NEAR
	CMP	StopStart,0
	JE	OSend
	MOV	AX,SPIDINFO
	MOV	DX,0
	MOV	BL,InSpid
	MOV	BH,0	
	DIV	BX ;рез_т в AX

	LEA	BX,TablSym

	mov	CX,10
	mov	DX,0
	div	cx
	XCHG	al,dL
	XLAT
	out	7,al
	XCHG	al,dL

	mov	CX,10
	mov	DX,0
	div	cx
	XCHG	al,dL
	XLAT
	out	6,al
	XCHG	al,dL

	mov	CX,10
	mov	DX,0
	div	cx
	XCHG	al,dL
	XLAT
	out	5,al
	XCHG	al,dL

	mov	CX,10
	mov	DX,0
	div	cx
	XCHG	al,dL
	XLAT
	out	4,al
	XCHG	al,dL
	
OSend:
OSexit:	RET
OutSpid ENDP

;-------------------МАКРОУРОВЕНЬ----------------------
START:
	MOV	AX,STACKG
	MOV	SS,AX
	MOV	AX,DATASG
	MOV	DS,AX	
Comon:	
	CALL	KbdIn	
	CALL	FormTim
	CALL	CouTime
	CALL	OutDisp
	CALL	InSpSv
	CALL	UnEmul
	CALL	OutSpid 

	JMP	Comon
CODESG	ENDS
END START






