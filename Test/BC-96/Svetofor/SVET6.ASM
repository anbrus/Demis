Name Svetofor
	Tik = 18             ;Количество тиков
	Sredn = 10           ;среднее число машин
	BeginPortSvet = 4    ;начальный порт вывода сигналов светофора
	MaxPos = 3           ;максимальное число состояний
	MaxPotok = 9         ;максимальное количество машин в потоке
	KolSvet = 2          ;количество светофоров
data segment at 0ba00h
	Flags dw ?
	Map db 0AH dup (?)  ;Для индикации
	MapSvet db 4 dup (?);Для вывода сигналов светофора
	Svetofor db 2 dup (?);Сигналы светофоров
	Time dw ?           ;Время в секундах 
	OldTime dw ?        ;Старое время
	Period dw ?         ;Разность Time и OldTime
                            ;изменяется то 0 до TimePos[i]
	TimePos db 4 dup (?);
	Port0 db ?	    ;Номер нажатой клавиши порта ввода 0
	Port0Old db ?       ;Старое значение порта ввода 0
	Rezult_Port0 db ?   ;
	Potok db 4 dup (?)  ;Кол-во машин в потоках																										
	ObKol db 4 dup (?)  ;Общее кол-во проехавших машин в ASCII-формате
	Position dw 4 dup (?);Позиции света светофоров
	PosS db ?            ;Состояние светофоров
	MaxX db ?            ;Максимальное число машин по
	MaxY db ?            ;направлениям X и Y
data ends

steck segment at 0ba80h
	dw 200 dup(?)
StkLabel label far
steck ends

code segment
 	assume cs:code,ds:data,es:data,ss:steck

ReadTime proc
;Чтение времени и преобразование в нужный период
	push ax
	push bx
	push cx
	push dx
	mov ah,0

	int 1ah   ;SysClk 
	xchg dx,cx
	mov ax,cx
	xor dx,dx

;в DX,AX текущие тики
	mov bx,Tik
	div bx

	mov word ptr Time,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
ReadTime endp

Time_move_to_OldTime proc
	push ax
	mov ax,word ptr Time
	mov word ptr OldTime,ax
	pop ax
	ret
Time_move_to_OldTime endp

Sub_Time proc
;Формирование периода свечения сигналов светофоров
	push ax
	mov ax,word ptr Time
	sub ax,word ptr OldTime
	mov Period,ax
	pop ax
	ret
Sub_Time endp

InitSvet proc
;Инициализаиция сигналов светофора
       mov MapSvet[0], 1
       mov MapSvet[1], 2
       mov MapSvet[2], 4
       mov MapSvet[3], 3
	ret
InitSvet endp
InitMap proc
;Инициализация цифр
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
	ret
InitMap endp
InitPosition proc
;Инициализаиция:
;         Порты                 05  04
;                                \  /
	mov word ptr Position[0],0002h
	mov word ptr Position[2],0301h
	mov word ptr Position[4],0200h
	mov word ptr Position[6],0103h
;-начального состояния
	mov PosS,0
	mov Rezult_Port0,0
;-Port0Old
	mov Port0Old,0
;-время горения желтого света
	mov byte ptr TimePos[1],1
	mov byte ptr TimePos[3],1
;-времени
	call ReadTime
	call Time_move_to_OldTime
	ret
InitPosition endp

SvetScreen proc
;Формирование сигналов светофоров
	push ax
	push bx
	mov bl,PosS
	xor bh,bh
	shl bx,1  ;Умножение на 2
	mov ax,word ptr Position[bx]
	mov byte ptr Svetofor[0],al
	mov byte ptr Svetofor[1],ah
	pop bx
	pop ax
	ret
SvetScreen endp

Max proc
;Вычисление максимального числа
; ds:si - address rezult
; ah,al - числа
	cmp ah,al
	jl AlMax
	mov [si],ah
	ret
AlMax:	mov [si],al
NxRet:	ret
Max endp

Calculat proc
;Вычисление времени для всех потоков
	push ax
	push bx
	push cx
	push dx
	
	mov al,Potok[0]
	mov ah,Potok[2]
	lea si,MaxY
	call Max
	mov al,Potok[1]
	mov ah,Potok[3]
	lea si,MaxX
	call Max
	mov ah,Sredn
	mov TimePos[0],ah
	mov TimePos[2],ah

	mov al,MaxY
	sub al,MaxX
	add TimePos[0],al
	sub TimePos[2],al
	
NextCal:pop dx
	pop cx
	pop bx
	pop ax
	ret
Calculat endp

Cmp_Period_and_TimePos proc
	push ax
	push bx
	mov bl,PosS
	mov al,TimePos[bx]
	cbw
	cmp ax,Period
	jge NextCmp
	;Перейти в следующее состояние
	inc byte ptr PosS
;Проверка на переполнение PosS
	mov al,PosS
	cmp al,MaxPos     
	jna NextPosS
	mov PosS,0    ;перейти в первое состояние
NextPosS:mov Period,0 ;Обнулить таймер
;Обновить OldTime
	call Time_move_to_OldTime
NextCmp:
	pop bx
	pop ax
	ret
Cmp_Period_and_TimePos endp

InputPort0 proc
;Чтение порта номер 0
	push ax
	mov al,Port0
	mov Port0Old,al
	in al,0
;-----
	cmp al,0
	jnz Inp1
	mov Port0,0
	jmp nextIn
Inp1:	cmp al,1
	jnz Inp2
	mov Port0,1
	jmp nextIn
Inp2:	cmp al,2
	jnz Inp3
	mov Port0,2
	jmp nextIn
Inp3:	cmp al,4
	jnz Inp4
	mov Port0,3
	jmp nextIn
Inp4:	cmp al,8
	jnz Inp5
	mov Port0,4
	jmp nextIn
Inp5:	cmp al,16
	jnz Inp6
	mov Port0,5
	jmp nextIn
Inp6:	cmp al,32
	jnz Inp7
	mov Port0,6
	jmp nextIn
Inp7:	cmp al,64
	jnz Inp8
	mov Port0,7
	jmp nextIn
Inp8:	cmp al,128
	jnz InpNone
	mov Port0,8
	jmp nextIn
InpNone:mov Port0,0
;-----
nextIn:	call Cmp_Port0_and_Port0Old
	pop ax
	ret
InputPort0 endp

Cmp_Port0_and_Port0Old proc
;Формирование еденичного нажатия
	mov al,Port0Old
	mov ah,Port0
	cmp al,ah
	je NP1
	mov Rezult_Port0,ah
	ret
	cmp al,0
	jne NP1
	mov Rezult_Port0,ah
	ret
NP1:	mov Rezult_Port0,0
	ret
Cmp_Port0_and_Port0Old endp

InputPotok proc
;Обработка клавиш
	push ax
	push bx
	push cx
	push dx
	push si
	mov al,Rezult_Port0
	cmp al,0
	jz NextPotok
;Клавиши "+1"
	cmp al,1
	jnz Inpot3
	mov cx,0
	call AddPotok
	jmp NextPotok
Inpot3: cmp al,3
	jnz Inpot5
	mov cx,1
	call AddPotok
	jmp NextPotok
Inpot5: cmp al,5
	jnz Inpot7
	mov cx,2
	call AddPotok
	jmp NextPotok
Inpot7: cmp al,7
	jnz Inpot2
	mov cx,3
	call AddPotok
	jmp NextPotok
;----
;Клавиши "-1"
Inpot2: cmp al,2
	jnz Inpot4
	mov ch,0
	mov cl,0
	call SubPotok
	jmp NextPotok
Inpot4: cmp al,4
	jnz Inpot6
	mov ch,1
	mov cl,1
	call SubPotok
	jmp NextPotok
Inpot6: cmp al,6
	jnz Inpot8
	mov ch,2
	mov cl,0
	call SubPotok
	jmp NextPotok
Inpot8: mov ch,3
	mov cl,1
	call SubPotok

NextPotok: pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
InputPotok endp

AddPotok proc
;Клавиши "+1"
;cx - номер потока
	push ax
	push si
	lea si,Potok
	add si,cx
	;Сложение
	mov al,[si]
	cmp al,MaxPotok   ;=9
	jge NextAddPotok
	inc byte ptr [si]
NextAddPotok: pop si
	pop ax
	ret
AddPotok endp

SubPotok proc
;Клавиши "-1"
;ch - номер потока
;cl - номер светофора
	push ax
	push bx

	;проверка на зеленый свет светофора
	lea bx,Svetofor
	add bl,cl
	mov al,ds:[bx]
	cmp al,2
	jnz NextSub
	;
	lea bx,Potok
	add bl,ch
	mov al,ds:[bx]
	cmp al,0
	jle NextSub
;	уменьшение числа в данном потоке
	dec byte ptr ds:[bx]
;	увеличение общего числа
	call IncObKol

NextSub:pop bx
	pop ax
	ret
SubPotok endp

OutputPotok proc
;Вывод потоков на экран
	push ax
	push bx
	push cx
	push dx
	mov cx,4
	lea si,Potok
	xor dx,dx
Outpotok:call OutputPortInfo
	inc dx
	inc si
	loop Outpotok
	pop dx
	pop cx
	pop bx
	pop ax
	ret
OutputPotok endp

OutputPortInfo proc
;Вывод одной цифры на экран
;ds:si - address 
;dx - port
	push ax
	push bx

	lea bx,Map
	mov al,[si]
	xlat
	out dx,al

	pop bx
	pop ax
	ret
OutputPortInfo endp

OutObKol proc
;Вывод общего кол-ва машин
	push ds
	push ax
	push cx
	push dx
	push si

	lea si,ObKol
	lea bx,Map
	mov al,[si]
	xlat
	mov ah,[si+3]
	cmp ah,0
	jz NOutOb
	or al,128
NOutOb:	out 6,al

	lea si,ObKol+1
	mov dx,7
	mov cx,2
OutObm:	call OutputPortInfo
	inc dx
	inc si
	loop OutObm

	pop si
	pop dx
	pop cx
	pop ax
	pop ds
	ret
OutObKol endp

IncObKol proc
;Увеличение общего числа машин
	mov al,ObKol[0]
	add al,1
	aaa
	mov ObKol[0],al
	mov al,ObKol[1]
	adc al,0
	aaa
	mov ObKol[1],al
	mov al,ObKol[2]
	adc al,0
	aaa
	mov ObKol[2],al
	mov al,ObKol[3]
	adc al,0
	aaa
	mov ObKol[3],al
	ret
IncObKol endp

OutputSvet proc
;вывод на экран сигналов светофора
	push ax
	push bx
	push cx
	push dx
	push si

	xor ax,ax
	mov cx,KolSvet   
	lea si,Svetofor
	lea bx,MapSvet
	mov dx,BeginPortSvet
NextS:  mov al,[si]
	xlat
	out dx,al
	inc dx
	inc si
	loop NextS

	pop si	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
OutputSvet endp

Kbd_Reset proc
;Клавиша "RESET"
	push ax
	xor ax,ax
	in al,1
	and al,1
	cmp al,1
	jnz NextKbd0
	mov ObKol[0],0
	mov ObKol[1],0
	mov ObKol[2],0
	mov ObKol[3],0
NextKbd0:pop ax
	ret
Kbd_Reset endp

 	assume cs:code,ds:data,es:data,ss:steck

begin:  mov ax,steck
	mov ss,ax
	lea sp,StkLabel
	mov ax,data
	mov ds,ax

;Инициализация начальных данных
	call InitMap
	call InitSvet
	call InitPosition
	
next:   call ReadTime
	call Sub_Time
	call Cmp_Period_and_TimePos
	call Calculat
	call InputPort0     ;чтение номера клавиши
	call InputPotok	    ;реакция на введенную клавишу
	call Kbd_Reset      ;обработка клавиши "СБРОС"
	call OutputPotok    ;вывод количества машин в потоках на экран
	call OutObKol       ;вывод общего количества машин на экран
	call SvetScreen     ;Состояние светофоров
	call OutputSvet     ;вывод сигналов светофоров

	jmp next

	org 07F0H
start:  jmp begin
code ends
	end start
