;Основной файл программы
LOCALS
Address=0			;тип ввода адрес
_Size=0ffh			;тип ввода размер
_Data=0ffh			;тип ввода данные
Keyb1=1				;первый порт клавиатуры
Keyb2=2				;второй порт клавиатуры
Auto=0;				;автоматичечкий режим
Manual=0ffh			;ручной режим
OptionPort=0			;Порт для всего всего
ModeInputKey=1b                ;Идет ввод режимов
Press=1				;нажали
UnPress=0			;отжали
SetupAddress=1000b
SetupSize=100b
DirPlus=10000b
DirMinus=100000b
Forward=1;
Backward=-1
NOErr=0				;нет ошибок
SizeErr=1			;не тот размер
MemDBusErr=2			;ошибка по шине данных
MemABusErr=3			;ошибка по шине адреса
;=============================
AutoLamp	=1
ManualLamp	=2
AddressLamp	=8
SizeLamp	=4
ForwardLamp	=16
BackWardLamp	=32
LampPort	=10
;=============================
TestKey=1000000b
;=============================

data segment at 0BA00H
	Map      db 17 dup (?)	;Карта преобразования
	NewKey      	  db ?	;Код с клавиатуры новый
	OldKey	    	  db ?	;Код с клавиатуры старый
	Address_Data  label byte;Тип ввода адрес/размер
	Address_Size 	  db ?	;Тип ввода адрес/размер
;	Address_Data  label byte;Тип ввода адрес/размер
	NewMode	          db ?	;новый Режим
	PressMode         db ?   ;старый режим
	Setup		  db ?	;тип ввода
	Dir		  db ?
	DirPress	  db ?
	RealAddress       DD ?
	CurSize		  dw ?
        DispArray	  db 7 dup(?)	;строка для преобразования 
	ErrFlag		  db ?
	KeepFlag	  dw ?
	KeepEs		  dw ?
	DispAdr		  dd ?
data ends 

;================================================
stack segment at 0BA80H
  db 200H dup (?)
  StkTop label word
stack ends

;================================================
code segment
assume cs:code,ds:data,ss:stack
include progsm.asm

Prepare proc			;Подготовка данных
        			;Инициализация карты преобразования
	mov Map[0], 3FH
        mov Map[1], 0Ch
        mov Map[2], 76h
        mov Map[3], 5Eh
        mov Map[4], 4DH
        mov Map[5], 5BH
        mov Map[11], 79H
        mov Map[7], 0EH
        mov Map[8], 7FH
        mov Map[9], 5FH
        mov Map[10], 6FH
        mov Map[6], 7BH
        mov Map[12], 33H
        mov Map[13], 7CH
        mov Map[14], 73H
        mov Map[15], 63H
	mov Map[16],01100000b

	mov Address_Size,Address

	mov OldKey,0
	mov NewKey,0

	mov NewMode,Auto
	mov Dir,Forward

	mov word ptr RealAddress,0F000h
	mov word ptr RealAddress[2],0F000h
	mov CurSize,0;

	mov ErrFlag,NoErr

	ret			;выход
Prepare endp

;==================================
KeybInput proc			;ввод с клавиатуры
	cmp ErrFlag,NoErr	;если нет ошибок
	je @@NoE
	jmp @@exit
@@NoE:
	in al,Keyb1		;чтение из первого порта клавиатуры
	cmp al,0		;сравнение с нулем значения в порту
	je  @@1
        call GetKeyNumber 
	inc cl
	jmp @@DoIt
@@1:	
	in al,Keyb2
	cmp al,0
	je @@DoNo

	call GetKeyNumber
	add cl,9
@@DoIt:
	mov ah,NewKey
	mov OldKey,ah
	mov NewKey,cl
	jmp @@exit
@@DoNo:
	mov NewKey,0
	mov OldKey,0
	
@@exit:
	ret			;выход
KeybInput endp	

;=============================
ModeInput proc			;ввод режимов 
	cmp ErrFlag,NoErr	;проверка ошибок
	je @@NoE
	jmp @@exit
@@Noe:
	in al,OptionPort
	cmp al,ModeInputkey	;проверка на установку режимов
        jne @@exit
	cmp PressMode,Press
	je @@exit1
        not NewMode
	mov PressMode,Press
	jmp @@exit1
@@exit: 
	mov PressMode,UnPress;
@@exit1:
	ret			;выход
ModeInput endp

;=============================
SetupInput proc			;ввод типа ввода 
	cmp ErrFlag,NoErr	;проверка ошибок
	je @@NoE
	jmp @@exit
@@Noe:
	in al,OptionPort
	cmp al,SetupAddress
	jne @@1
	mov Address_Size,Address
	jmp @@exit
@@1:
	cmp al,SetupSize
	jne @@exit
	mov Address_Size,_Size
@@exit:
     	ret			;выход
SetupInput endp

;=============================
DirInput proc			;ввод напраления
	cmp ErrFlag,NoErr	;проверка ошибок
	je @@NoE
	jmp @@exit
@@Noe:

	in al,OptionPort
	cmp al,DirPlus
	jne @@1
	cmp DirPress,Press
	je @@exit1
	mov Dir,Forward
	call ManualMake
	mov DirPress,Press
	jmp @@exit1
@@1:
	cmp al,DirMinus
	jne @@exit
	cmp DirPress,Press
	je @@exit1
	mov Dir,BackWard
	mov DirPress,Press
	call ManualMake
	jmp @@exit1	
@@exit:
	mov DirPress,UnPress
@@exit1:
	ret			;выход
DirInput endp

;=============================
MakeData proc			;Подготовка данных
	cmp ErrFlag,NoErr	;проверка ошибок
	je @@NoE
	jmp @@exit
@@Noe:

	cmp NewMode,Auto
	je @@AutoSetup
	jmp @@1
@@AutoSetup:
        call MakeAutoVars
	jmp @@exit;	
@@1:
	call MakeManualVars
@@exit:
	ret
MakeData endp

;=============================
MakeDispArr proc		;Формирование массива отображения
	mov cx,Length DispArray	;в CX длинну массива отображения
	lea si,DispArray	;в SI адресс массива отображения
@@l1:
	mov byte ptr [si],0
	inc si
	loop @@l1		;обнуление массива отображеия

	mov cx,Length DispArray	;в CX длинну массива отображения
	lea si,DispArray	;в SI адресс массива отображения
	lea bx,Map		;в BX адрес карты преобразования

	cmp NewMode,Auto	;проверка установленного режима
	je @@1			;если режим автоматический
	jmp @@2			;если ручной
@@1:
	cmp Address_Size,Address;тип ввода ?
	jne @@3			;вводим размер
@@MAdr:				;вводим адрес
	mov dx,word ptr RealAddress;в DX младшую часть адреса
	mov cx,4		;загрузка счетчика для преобразования
@@l2:				;цикл преобразования
	mov ax,1111b
	and ax,dx
	xlat
	mov [si],al
	inc si
	shr dx,4
	loop @@l2
	mov ax,word ptr RealAddress[2];в AX старшую часть адреса
	shr ax,12
	xlat
	mov [si],al			;составляем массив отображения
					;для адреса
	jmp @@exit	
@@3:
	mov dx,CurSize			;для размера
	mov cx,4
@@l3:
	mov ax,1111b
	and ax,dx
	xlat
	mov [si],al
	inc si
	shr dx,4
	loop @@l3

	jmp @@exit
;ручной режим
@@2:
	call MakeAcces
	push ds
	lds si,RealAddress
	mov dl,[si]
	pop ds
	call NoAcces

	lea si,DispArray
	lea bx,Map
	Add si,5
	mov al,0fh
	and al,dl
	xlat
	mov [si],al
	shr dl,4
	mov al,dl
	xlat
	inc si
	mov [si],al
	lea si,DispArray
	jmp @@MAdr

@@exit:
	ret
MakeDispArr endp

;=============================
OutputDispArr proc		;Вывод массива отображения на дисплей
	mov cx,Length DispArray	; в CX длинну масива лтображения
	mov dx,3		; в DX начало портов для вывода
	lea si,DispArray	; в SI адрес массива отображения
@@l1:				;цикл вывода в порты вывода
	mov al,[si]
	out dx,al
	inc si
	inc dx
	loop @@l1

	ret			;выход
OutputDispArr endp

;=============================
LampOutput proc
	xor ax,ax
	cmp NewMode,Auto
	jne @@1
	or ax,AutoLAmp
	jmp  @@SizeDann
@@1:
	or ax,ManualLamp

@@SizeDann:
	cmp Address_Size,Address
	jne @@2
	or ax,AddressLamp
	jmp @@DirOut
@@2:
	or ax,SizeLamp
@@DirOut:	
	cmp Dir,Forward
	jne @@3
	or ax,ForwardLamp
	jmp @@exit
@@3:
	or ax,BackwardLamp
	

@@exit:	
	out LampPort,al
@@exit1:
	ret
LampOutPut endp

;===================================
TestProgress proc		;тестирование
	cmp NewMode,Auto
	je @@Noe
	jmp @@exit
@@NoE:
	in al,OptionPort
	cmp al,TestKey
	jne @@exit
	call TestProcess
@@exit:	
	ret			;выход
TestProgress endp

;===================================
begin: 
	mov ax,data
	mov ds,ax

	mov ax,stack
	mov ss,ax       
	mov sp,offset StkTop
	call Prepare
MainProgramLoop:
	;==================
	call KeybInput		;ввод с клавиатуры
	call ModeInput		;ввод режимов
	call SetupInput		;ввод типа ввода 
	call DirInput		;ввод напраления
        ;==================
	call MakeData		;Подготовка данных
	call MakeDispArr	;Формирование массива отображения
	call OutputDispArr	;Вывод массива отображения на дисплей
	call TestProgress	;Процедура тестирования
	call LampOutput		;зажигание лампочек
	;==================
	jmp MainProgramLoop
       org 07F0H
start: jmp begin
code ends
end start
                  