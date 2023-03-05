data    segment at 0BA00h
	mas1 db 80 dup(0) ;	три массива с цифрами, управляющими
	mas2 db 80 dup(0) ; 		клавишами и
 	mas3 db 80 dup(0) ;	символами русского алфавита
	RegimIO db 0 	  ;	режим работы I/O  (1-I 2-O)
	RegimKb db 0	  ;	режим переключателей клавиатуры
	temp1	db  0	  ; переменные для получения переднего 
	temp2	db  0	  ; фронта сигнала нажатой клавиши
	NumPort db  0	  ; номер порта с которого проиходит ввод символа	
	codekey  db  0	  ; непосредственно код нажатой клавиши
	LengthSoob db 0   ; длинна вводимого сообщения
	Memory db 684 dup(0); память 9+9x15x5	
	OffsetMem dw 0    ; смещение относительно Memory
	Soob db 75 dup(0) ; массив для хранения вводимого сообщения
	Temp dw 0	  ; вспомгательная переменная
	Chislo db 0	  ; вспомгательная переменная	
	RegimOut db 0	  ; 0-ввод символа 1-ввод номера 2-просмотр/редактир.
	Summa db 0	  ; колличество сообщений на данный символ в Memory
	FirstSymbol db 5 dup(0); содержит коды одного символа
	NumSoob	db 0	  ; номер выбранного в Memory сообщения
	Tempp db 0	  ; вспомгательная переменная
	SSGood db 0	  ; флаг сообщение выбрано в SelectSoob верно или нет
			  ; 0-верно 1-не правильно
	GoodKey	db 0	  ; 0-нажата цифровая клавиша 1-нет
	FirstSymbol1 db 5 dup(0); содержит коды одного символа
	MaxLS db 0	  ; исходная длина просматриваемого сообщения
	KolSoob db 0	  ; колличество сообщений 1-нет 0-есть
	OffsetMem2 dw 0	  ; вспомогательная переменная
	OffsetEnd dw 0	  ; смещение по которому в Memory  запишется 
			    новое сообщение	
	TempLS db 0 
data    ends 
;---------------------------------------------------------------------
code    segment	
	assume 	cs:code,ds:data,es:data
;---------------------------------------------------------------------
Install proc near
	mov 	ax,data
       	mov 	ds,ax
	mov 	es,ax
	xor	bx,bx
	mov	OffsetEnd,0
	
	; инициализация mas1
        mov mas1[bx],7eh	;цифра 0
        mov mas1[bx+1],81h
        mov mas1[bx+2],81h
        mov mas1[bx+3],81h
        mov mas1[bx+4],7eh

        mov mas1[bx+5],84h	;цифра 1
        mov mas1[bx+6],82h
        mov mas1[bx+7],0ffh
        mov mas1[bx+8],80h
        mov mas1[bx+9],80h

        mov mas1[bx+10],0c2h	;цифра 2
        mov mas1[bx+11],0a1h
        mov mas1[bx+12],91h
        mov mas1[bx+13],89h
        mov mas1[bx+14],6h

        mov mas1[bx+15],41h	;цифра 3
        mov mas1[bx+16],81h
        mov mas1[bx+17],85h
        mov mas1[bx+18],8bh
        mov mas1[bx+19],71h

        mov mas1[bx+20],0fh	;цифра 4
        mov mas1[bx+21],8h
        mov mas1[bx+22],8h
        mov mas1[bx+23],8h
        mov mas1[bx+24],0ffh

        mov mas1[bx+25],8fh	;цифра 5
        mov mas1[bx+26],89h
        mov mas1[bx+27],89h
        mov mas1[bx+28],89h
        mov mas1[bx+29],0f0h

        mov mas1[bx+30],0f8h	;цифра 6
        mov mas1[bx+31],94h
        mov mas1[bx+32],92h
        mov mas1[bx+33],91h
        mov mas1[bx+34],0f1h

        mov mas1[bx+35],01h	;цифра 7
        mov mas1[bx+36],0f1h
        mov mas1[bx+37],9h
        mov mas1[bx+38],5h
        mov mas1[bx+39],3h

        mov mas1[bx+40],0ffh	;цифра 8
        mov mas1[bx+41],89h
        mov mas1[bx+42],89h
        mov mas1[bx+43],89h
        mov mas1[bx+44],0ffh

        mov mas1[bx+45],8fh	;цифра 9
        mov mas1[bx+46],89h
        mov mas1[bx+47],49h
        mov mas1[bx+48],29h
        mov mas1[bx+49],1fh

	; инициализация mas2
        mov mas2[bx],0fch	;буква А
        mov mas2[bx+1],22h
        mov mas2[bx+2],21h
        mov mas2[bx+3],22h
        mov mas2[bx+4],0fch

        mov mas2[bx+5],0ffh	;буква Б
        mov mas2[bx+6],89h
        mov mas2[bx+7],89h
        mov mas2[bx+8],89h
        mov mas2[bx+9],0f8h

        mov mas2[bx+10],0ffh	;буква В
        mov mas2[bx+11],89h
        mov mas2[bx+12],89h
        mov mas2[bx+13],8eh
        mov mas2[bx+14],0f8h

        mov mas2[bx+15],0ffh	;буква Г
        mov mas2[bx+16],01h
        mov mas2[bx+17],01h
        mov mas2[bx+18],01h
        mov mas2[bx+19],01h

        mov mas2[bx+20],0c0h	;буква Д
        mov mas2[bx+21],7eh
        mov mas2[bx+22],41h
        mov mas2[bx+23],7eh
        mov mas2[bx+24],0c0h

        mov mas2[bx+25],0FFh	;буква Е
        mov mas2[bx+26],89h
        mov mas2[bx+27],89h
        mov mas2[bx+28],89h
        mov mas2[bx+29],81h

        mov mas2[bx+30],0e3h	;буква Ж
        mov mas2[bx+31],14h
        mov mas2[bx+32],0ffh
        mov mas2[bx+33],14h
        mov mas2[bx+34],0e3h

        mov mas2[bx+35],42h	;буква З
        mov mas2[bx+36],89h
        mov mas2[bx+37],89h
        mov mas2[bx+38],89h
        mov mas2[bx+39],76h

        mov mas2[bx+40],0ffh	;буква И
        mov mas2[bx+41],20h
        mov mas2[bx+42],10h
        mov mas2[bx+43],08h
        mov mas2[bx+44],0ffh

        mov mas2[bx+45],0ffh	;буква К
        mov mas2[bx+46],08h
        mov mas2[bx+47],14h
        mov mas2[bx+48],23h
        mov mas2[bx+49],0c0h

        mov mas2[bx+50],80h	;буква Л
        mov mas2[bx+51],0fch
        mov mas2[bx+52],02h
        mov mas2[bx+53],01h
        mov mas2[bx+54],0ffh

        mov mas2[bx+55],0ffh	;буква М
        mov mas2[bx+56],02h
        mov mas2[bx+57],0ch
        mov mas2[bx+58],02h
        mov mas2[bx+59],0ffh

        mov mas2[bx+60],0ffh	;буква Н
        mov mas2[bx+61],10h
        mov mas2[bx+62],10h
        mov mas2[bx+63],10h
        mov mas2[bx+64],0ffh

        mov mas2[bx+65],7eh	;буква О
        mov mas2[bx+66],81h
        mov mas2[bx+67],81h
        mov mas2[bx+68],81h
        mov mas2[bx+69],7eh

        mov mas2[bx+70],0ffh	;буква П
        mov mas2[bx+71],01h
        mov mas2[bx+72],01h
        mov mas2[bx+73],01h
        mov mas2[bx+74],0ffh

        mov mas2[bx+75],0ffh	;буква Р
        mov mas2[bx+76],11h
        mov mas2[bx+77],11h
        mov mas2[bx+78],11h
        mov mas2[bx+79],0eh

	; инициализация mas3
        mov mas3[bx],7eh	;буква С
        mov mas3[bx+1],81h
        mov mas3[bx+2],81h
        mov mas3[bx+3],81h
        mov mas3[bx+4],42h

        mov mas3[bx+5],01h	;буква Т
        mov mas3[bx+6],01h
        mov mas3[bx+7],0ffh
        mov mas3[bx+8],01h
        mov mas3[bx+9],01h

        mov mas3[bx+10],47h	;буква У
        mov mas3[bx+11],88h
        mov mas3[bx+12],88h
        mov mas3[bx+13],88h
        mov mas3[bx+14],7fh

        mov mas3[bx+15],1fh	;буква Ф
        mov mas3[bx+16],11h
        mov mas3[bx+17],0ffh
        mov mas3[bx+18],11h
        mov mas3[bx+19],1fh

        mov mas3[bx+20],0e3h	;буква Х
        mov mas3[bx+21],14h
        mov mas3[bx+22],08h
        mov mas3[bx+23],14h
        mov mas3[bx+24],0e3h

        mov mas3[bx+25],7Fh	;буква Ц
        mov mas3[bx+26],40h
        mov mas3[bx+27],40h
        mov mas3[bx+28],7fh
        mov mas3[bx+29],0c0h

        mov mas3[bx+30],0fh	;буква Ч
        mov mas3[bx+31],10h
        mov mas3[bx+32],10h
        mov mas3[bx+33],10h
        mov mas3[bx+34],0ffh

        mov mas3[bx+35],0ffh	;буква Ш
        mov mas3[bx+36],80h
        mov mas3[bx+37],0f8h
        mov mas3[bx+38],80h
        mov mas3[bx+39],0ffh

        mov mas3[bx+40],7fh	;буква Щ
        mov mas3[bx+41],40h
        mov mas3[bx+42],78h
        mov mas3[bx+43],40h
        mov mas3[bx+44],0ffh

        mov mas3[bx+45],01h	;буква Ъ
        mov mas3[bx+46],0ffh
        mov mas3[bx+47],88h
        mov mas3[bx+48],88h
        mov mas3[bx+49],70h

        mov mas3[bx+50],0ffh	;буква Ы
        mov mas3[bx+51],88h
        mov mas3[bx+52],70h
        mov mas3[bx+53],0h
        mov mas3[bx+54],0ffh

        mov mas3[bx+55],0ffh	;буква Ь
        mov mas3[bx+56],88h
        mov mas3[bx+57],88h
        mov mas3[bx+58],88h
        mov mas3[bx+59],70h

        mov mas3[bx+60],42h	;буква Э
        mov mas3[bx+61],81h
        mov mas3[bx+62],89h
        mov mas3[bx+63],89h
        mov mas3[bx+64],7eh

        mov mas3[bx+65],0ffh	;буква Ю
        mov mas3[bx+66],08h
        mov mas3[bx+67],0ffh
        mov mas3[bx+68],81h
        mov mas3[bx+69],0ffh

        mov mas3[bx+70],8eh	;буква Я
        mov mas3[bx+71],51h
        mov mas3[bx+72],31h
        mov mas3[bx+73],11h
        mov mas3[bx+74],0ffh

        mov mas3[bx+75],0h	; пробел
        mov mas3[bx+76],0h
        mov mas3[bx+77],0h
        mov mas3[bx+78],0h
        mov mas3[bx+79],0h

	ret
Install	endp
;---------------------------------------------------------------------
SetupIO proc near
m1_SetupIO:
	mov	RegimKb,0
	in	al,3

	cmp	al,2
	jne	m2_SetupIO
	mov	RegimIO,2
	jmp	m3_SetupIO
m2_SetupIO:
	cmp	al,1
	jne	m1_SetupIO
	mov	RegimIO,1
m3_SetupIO:
	ret
SetupIO endp
;---------------------------------------------------------------------
Input proc near
begin_proc:

	call	SetupIO
	cmp	RegimIO,1
	jne	exit_proc_1

	in 	al,2	;считываем режим переключателя клавиатуры
	cmp	al,0
	je	begin_proc
        cmp 	al,1    
        je 	m0	
	cmp 	al,2    
	je 	m1	
	cmp 	al,4    
	je 	m2	
	jmp	begin_proc
m0:
	mov 	RegimKb,1
	jmp	m3
m1:
	mov 	RegimKb,2
	jmp	m3
m2:
	mov 	RegimKb,3
m3:
	mov	ah,temp1
	in	al,0
	mov	temp1,al
	xor	al,ah
	and	al,ah
	cmp	al,0
	je	next_port
	mov	NumPort,1
	mov     codekey,al
	jmp	Next_Code

next_port:
	mov	ah,temp2
	in	al,1
	mov	temp2,al
	xor	al,ah
	and	al,ah
	cmp	al,0
	je      begin_proc
	mov 	NumPort,2
	mov	codekey,al

Next_Code:
;?
	cmp	NumPort,2
	jne	GoodCode
	cmp	RegimKb,1
	jne	GoodCode
	cmp	codekey,4h
	jne	Next1_Code
	jmp	begin_proc
;- - - - - - - - - - - - - - 
begin_proc_1:
	jmp	begin_proc
exit_proc_1:
	jmp	exit_proc
;- - - - - - - - - - - - - - 
Next1_Code:
	cmp	codekey,8h
	jne	Next2_Code
	jmp	begin_proc

Next2_Code:
;ввод сообщения ?
	cmp	codekey,10h
	jne	Next3_Code

	cmp	OffsetEnd,2ach
	jne	Next2go_Code	
	call	Out_of_Mem
	call	Delay
	call	ClearScr
	jmp	exit_proc	

Next2go_Code:	
	mov	dx,0
	call	InputSoob
	add	OffsetEnd,76	
	jmp	exit_proc

Next3_Code:
	cmp	codekey,20h
	jne	Next4_Code
	jmp	begin_proc

Next4_Code:
;затереть последний символ ?
	cmp	codekey,40h
	jne	Next5_Code
	call	BackSp
	jmp	begin_proc
Next5_Code:
	cmp	codekey,80h
	jne	GoodCode
	jmp	begin_proc
GoodCode:
	cmp	LengthSoob,0fh
	je	begin_proc_1

	cmp	dx,0fh
	jne	good
	mov	dx,0
	call	ClearScr	
good:
	call	Out
	call	SaveSoob
	inc	LengthSoob
	jmp	begin_proc_1
exit_proc:
	mov	RegimIO,0	
	ret
Input endp
;---------------------------------------------------------------------
Out_of_Mem proc near
	mov 	dx,0
	mov	bx,55
	mov	cx,5
OoM_m1:
	mov	al,mas2[bx]
	out	dx,al
	inc	dx
	inc	bx
	loop	OoM_m1
	mov	bx,25
	mov	cx,5
OoM_m2:
	mov	al,mas2[bx]
	out	dx,al
	inc	dx
	inc	bx
	loop	OoM_m2
	mov	bx,55
	mov	cx,5
OoM_m3:
	mov	al,mas2[bx]
	out	dx,al
	inc	dx
	inc	bx
	loop	OoM_m3
	mov	dx,0
	ret
Out_of_Mem endp
;---------------------------------------------------------------------
InputSoob proc near
	;запись длины сообщения в память
	mov 	bx,OffsetEnd
	mov	al,LengthSoob
	mov	Memory[bx],al
	inc	bx
	;формирование счетчика
	mov	al,5
	mul	LengthSoob
	mov	cx,ax	
	xor	di,di
	;запись в память
m1_IS:
	xchg    al,Soob[di]
	xchg	al,Memory[bx+di]
	inc	di
	loop	m1_IS
	call	ClearScr
;	add	OffsetMem,76	
	mov	cx,75
	;очистка массива Soob
	mov	si,0
	mov	al,0
m2_IS:
	mov	Soob[si],al
	inc	si
	loop	m2_IS
	;обнуление длины вводимого сообщения
	mov 	LengthSoob,0
	ret
InputSoob endp
;---------------------------------------------------------------------
BackSp proc near
	;сообщение не пустое ?
	cmp 	LengthSoob,0
	je  	exit_BkSpace
	dec	LengthSoob
	mov	al,5
	mul	LengthSoob
	mov	bp,ax
	;удаление последнего символа в Soob
	mov	Soob[bp],0
	mov	Soob[bp+1],0
	mov	Soob[bp+2],0
	mov	Soob[bp+3],0
	mov	Soob[bp+4],0
	;затирание последнего инициированного индикатора
	mov	al,0
	mov	cx,5
	dec	dx
Clear_symbol:
	out	dx,al
	dec	dx
	loop	Clear_symbol
	inc	dx
	;если затерли все три знакоместа
	cmp	dx,0
	jne	exit_BkSpace
	cmp	LengthSoob,0
	je	exit_BkSpace

	mov	al,05h
	mul	LengthSoob
	mov	di,ax
	sub	di,15
	mov	cx,15
Shift_met:
	mov	al,Soob[di]
	out	dx,al
	inc	di
	inc	dx
	loop	Shift_met
	
exit_BkSpace:
	ret
BackSp endp
;---------------------------------------------------------------------
ClearScr proc near	; процедура очистки экрана
	push	dx
	mov	al,0
	mov	cx,16
	mov	dx,0
m_ClearScr:
	out	dx,al
	inc	dx
	loop	m_ClearScr
	pop	dx
	ret
ClearScr  endp	
;---------------------------------------------------------------------
Out proc near
	
	; Формируем смещение в зависимости от переключателя клавиатуры
	cmp	RegimKb,1
	jne	m1_Out
	mov	bx,offset mas1
	jmp	m22_Out
m1_Out:
	cmp	RegimKb,2
	jne	m2_Out
	mov	bx,offset mas2
	jmp	m22_Out
m2_Out:
	mov	bx,offset mas3
m22_Out:
	mov	OffsetMem,bx

	mov 	Temp,bx	
	
	;получение смещения символа в массиве
	mov	cx,8
	mov	si,0
	mov	Chislo,1
m3_Out:
	mov	al,2
	mov	ah,Chislo
	cmp	ah,codekey
	jne	m4_Out
	mov	bx,si
	jmp	m5_Out
m4_Out:
	mul	Chislo
	mov	Chislo,al
	add	si,5
	loop	m3_Out
m5_Out:
	add	bx,Temp
	cmp	NumPort,2
	jne	m55_Out
	add	bx,40	
m55_Out:
	;вывод символа на индикатор
	mov	cx,5
m6_Out:	
	mov	al,byte ptr ds:[bx]	
	out	dx,al
	inc	dx
	inc	bx
	loop	m6_Out
	
	ret
Out endp
;---------------------------------------------------------------------
SaveSoob proc near
	; Формируем смещение в зависимости от переключателя клавиатуры
	cmp	RegimKb,1
	jne	m1_SS
	mov	bx,offset mas1
	jmp	m22_SS
m1_SS:
	cmp	RegimKb,2
	jne	m2_SS
	mov	bx,offset mas2
	jmp	m22_SS
m2_SS:
	mov	bx,offset mas3
m22_SS:

	mov 	Temp,bx	
	
	;получение смещения символа в массиве
	mov	cx,8
	mov	si,0
	mov	Chislo,1
m3_SS:
	mov	al,2
	mov	ah,Chislo
	cmp	ah,codekey
	jne	m4_SS
	mov	bx,si
	jmp	m5_SS
m4_SS:
	mul	Chislo
	mov	Chislo,al
	add	si,5
	loop	m3_SS
m5_SS:
	add	bx,Temp
	cmp	NumPort,2
	jne	m55_SS
	add	bx,40	
m55_SS:
	;вывод символа на индикатор
	mov	cx,5
	mov	al,5
	mul	LengthSoob
	mov	di,ax
m6_SS:	
	mov	al,byte ptr ds:[bx]	
	mov	Soob[di],al
	inc	bx
	inc	di
	loop	m6_SS
	
	ret
SaveSoob endp
;---------------------------------------------------------------------
Output proc near
beg_proc:
	call	SetupIO
	cmp	RegimIO,2
	jne	ext_proc1

	in 	al,2	;считываем режим переключателя клавиатуры
	cmp	al,0
	je	beg_proc
        cmp 	al,1    
        je 	m0_Output	
	cmp 	al,2    
	je 	m1_Output		
	cmp 	al,4    
	je 	m2_Output		
	jmp	beg_proc
m0_Output:
	mov 	RegimKb,1
	jmp	m3_Output	
m1_Output:
	mov 	RegimKb,2
	jmp	m3_Output	
m2_Output:
	mov 	RegimKb,3
m3_Output:
	mov	ah,temp1
	in	al,0
	mov	temp1,al
	xor	al,ah
	and	al,ah
	cmp	al,0
	je	n_port
	mov	NumPort,1
	mov     codekey,al
	jmp	N_Code
; - - - - - - - - - - - - - - 
beg11_proc:
	jmp	beg_proc
; - - - - - - - - - - - - - - 
n_port:
	mov	ah,temp2
	in	al,1
	mov	temp2,al
	xor	al,ah
	and	al,ah
	cmp	al,0
	je      beg_proc
	mov 	NumPort,2
	mov	codekey,al
N_Code:
	cmp	RegimOut,0
	jne	F1_Regim
	call 	FindMem	;выводит на индикатор колличество сообщений
	cmp	KolSoob,1
	jne	N1_Code
	call	Delay
	call	ClearScr
	jmp	beg_proc	
;- - - - - - - - - - - - - - 
ext_proc1:
	jmp	ext_proc
;- - - - - - - - - - - - - - 
N1_Code:
	mov	RegimOut,1
	jmp	beg_proc
F1_Regim:
	cmp	RegimOut,1
	jne	F2_Regim
	call	SelSoob;получает смещения сообщения в памяти
	cmp	SSGood,1
	je	beg11_proc
	mov	al,Memory[bx]
	mov	LengthSoob,al
	mov	MaxLS,al
	mov	TempLS,0
	mov	RegimOut,2	
	jmp	GCode
F2_Regim:
;?
	cmp	NumPort,2
	jne	GCode
	cmp	RegimKb,1
	jne	GCode
;сдвиг сообщения влево ?
	cmp	codekey,4h
	jne	Nn1_Code
	call	MovLeft
	jmp	GCode
;- - - - - - - - - - - - - - 
beg_proc_1:
	jmp	beg_proc
;- - - - - - - - - - - - - - 
Nn1_Code:
;сдвиг сообщения вправо?
	cmp	codekey,8h
	jne	N2_Code
	mov	al,LengthSoob
	out 	0fh,al
	call	MovRigth
	jmp	GCode
N2_Code:
;окончание просмотра сообщения ?
	cmp	codekey,10h
	jne	N3_Code
	mov	RegimOut,0
	mov	LengthSoob,0
	mov	MaxLS,0
	mov	dx,0
	call	ClearScr
	jmp	ext_proc
N3_Code:
;?
	cmp	codekey,20h
	jne	N4_Code
	jmp	beg_proc
N4_Code:
;?
	cmp	codekey,40h
	jne	N5_Code
	jmp	beg_proc
N5_Code:
;удалить сообщение ?
	cmp	codekey,80h
	jne	GCode
	call	DelSoob
	call	ClearScr
	sub	OffsetEnd,76	
	mov	RegimOut,0
	jmp	begin_proc
GCode:
	call	OutSoob
	jmp	begin_proc
ext_proc:
	mov	RegimIO,0	
	ret
Output endp
;---------------------------------------------------------------------
Delay proc near
	mov 	cx,02ffh
Delay_m:	
	mov	ah,0ffh
	mov	al,0
	sub	al,ah
	loop	Delay_m
	ret
Delay endp
;---------------------------------------------------------------------
FindMem proc near
	mov	KolSoob,0
	mov	Summa,0
	
	cmp	RegimKb,1
	jne	FM_m1
	mov	bx,offset mas1
	jmp	FM_m3
FM_m1:
	cmp	RegimKb,2
	jne	FM_m2
	mov	bx,offset mas2
	jmp	FM_m3
FM_m2:
	cmp	RegimKB,3
	jne	FM_m3
	mov	bx,offset mas3
FM_m3:
	cmp	NumPort,2
	jne	FM_m4
	add	bx,40

FM_m4:

FM_Go_:
	mov	cx,8
	mov	si,0
	mov	Chislo,1
FM_m1_:
	mov	al,2
	mov	ah,Chislo
	cmp	ah,codekey
	jne	FM_m2_
	add	bx,si
	jmp	FM_m3_
FM_m2_:
	mul	Chislo
	mov	Chislo,al
	add	si,5
	loop	FM_m1_
FM_m3_:

	call	SaveFirst
	mov 	si,0	
	mov	cx,9
FM_st_:	
	inc	si
	mov	bx,5
	mov	di,0
FM_Find:
	mov	al,Memory[si]
	cmp 	al,FirstSymbol[di]
	jnz 	end_
	inc	di
	inc	si
	dec	bx
	cmp	bx,0
	jne	FM_Find
	inc	Summa
end_:	
	sub	si,di
	add	si,75
	loop    FM_st_		

	call	ClearScr
	mov	dx,0
	mov	al,5
	mul	Summa	
	mov	bx,ax
	mov	cx,5
	mov	si,0
	mov	dx,0
Out_Summa:
	mov	al,mas1[bx+si]
	out	dx,al
	inc	dx
	inc	si
	loop	Out_Summa
	mov	dx,0

	cmp	Summa,0
	jne	Out_exit
	mov	KolSoob,1

Out_exit:	
	ret
FindMem endp
;---------------------------------------------------------------------
SaveFirst proc near
	mov	cx,5
	mov	si,0
M1_SaveFS:
	mov	al,ds:[bx+si]
	mov	FirstSymbol[si],al
	inc	si
	loop	M1_SaveFS
	ret
SaveFirst endp
;---------------------------------------------------------------------
DelFS   proc near
	mov	cx,5
	mov	si,0
	mov	al,0
M1_DFS:
	mov	FirstSymbol[si],al
	inc	si
	loop	M1_DFS
	ret
DelFS endp
;---------------------------------------------------------------------
SaveFirst1 proc near
	mov	cx,5
	mov	si,0
M1_SaveFS1:
	mov	al,ds:[bx+si]
	mov	FirstSymbol1[si],al
	inc	si
	loop	M1_SaveFS1
	ret
SaveFirst1 endp
;---------------------------------------------------------------------
SelSoob proc near
	mov	NumSoob,0
	mov	Tempp,0
	mov	GoodKey,0
	mov 	SSGood,0
	call	NumberKey
	cmp	GoodKey,1
	je	Sel_exit	
	call	Offset_
	call	NmSoob
	cmp	GoodKey,1
	je	Sel_exit	
	call	OfMem	
	jmp	Sel_ext
Sel_exit:
	mov	SSGood,1
Sel_ext:
	ret
SelSoob	endp
;---------------------------------------------------------------------
NumberKey proc near
	;проверка на то, что нажата именно цифра
	mov	GoodKey,0	

	cmp	RegimKb,2
	je	NK_exit
	cmp	RegimKB,3
	je	NK_exit
	cmp	NumPort,2
	jne	NK_exit_
	cmp	codekey,4
	je	NK_exit
	cmp	codekey,8
	je	NK_exit
	cmp	codekey,10h
	je	NK_exit
	cmp	codekey,20h
	je	NK_exit
	cmp	codekey,40h
	je	NK_exit
	cmp	codekey,80h
	je	NK_exit
	
NK_exit:
	mov	GoodKey,1
NK_exit_:
	ret
NumberKey endp
;---------------------------------------------------------------------
Offset_ proc near
	;получение смещения символа в массиве
	mov	bx,offset mas1
	cmp	NumPort,2
	jne	Of_Go_
	add	bx,40
Of_Go_:
	mov	cx,8
	mov	si,0
	mov	Chislo,1
Of_m1_:
	mov	al,2
	mov	ah,Chislo
	cmp	ah,codekey
	jne	Of_m2_
	add	bx,si
	jmp	Of_m3_
Of_m2_:
	mul	Chislo
	mov	Chislo,al
	add	si,5
	loop	Of_m1_
Of_m3_:
	ret
Offset_ endp
;---------------------------------------------------------------------
NmSoob proc near
	mov	SSGood,0		
	;получение номера посматриваемого сообщения
	call	SaveFirst1
	mov 	si,0
	mov	cx,10
	mov	bl,0
Nm_st_:
	mov	bh,5
	mov	di,0
Nm_Find:
	mov	al,mas1[si]	
	cmp	FirstSymbol1[di],al
	jne	Nm_Fnext
	dec	bh
	inc	di
	inc	si		
	cmp	bh,0
	jne	Nm_Find
	mov	NumSoob,bl
	jmp	Nn_exit
Nm_Fnext:
	inc	bl
	sub	si,di
	add	si,5
	loop    Nm_st_		
Nn_exit:
	;входит ли полученный номер в допустимые пределы от 1..Summa	
	xor	ch,ch
	mov	cl,Summa
Nm1_ext:
	cmp	cl,NumSoob
	je	Nm_ext
	loop	Nm1_ext
	mov	SSGood,1		
Nm_ext:
	ret
NmSoob endp

;---------------------------------------------------------------------
OfMem proc near
	; получение смещения искомого сообщения в Memory
OM_Go:	
	mov 	si,0	
	mov	cx,9
OM_st_:	
	inc	si
	mov	bx,5
	mov	di,0
OM_Find:
	mov	al,Memory[si]
	cmp 	al,FirstSymbol[di]
	jne 	OM_end
	inc	di
	inc	si
	dec	bx
	cmp	bx,0
	jne	OM_Find
	inc	Tempp
	mov	al,Tempp
	cmp	NumSoob,al
	je	OM_end_
OM_end:	
	sub	si,di
	add	si,75
	loop	OM_st_
OM_end_:	
	sub	si,di
	mov	OffsetMem,si
	mov	OffsetMem2,si
	ret
OfMem endp
;---------------------------------------------------------------------
OutSoob proc near
	mov	dx,0
	mov	cx,15
	mov	di,OffsetMem
OS_m1:
	mov	al,Memory[di]
	out	dx,al
	inc 	dx
	inc	di
	loop OS_m1
	ret
OutSoob	endp
;---------------------------------------------------------------------
MovLeft proc near
	mov	al,TempLS
	cmp	al,0
	jz	ML_exit

	mov	dx,0
	sub	TempLS,3
	sub	OffsetMem,15
ML_exit:
	ret
MovLeft endp
;---------------------------------------------------------------------
MovRigth proc near
	mov	al,LengthSoob
	mov	ah,TempLS
	add	ah,3
	cmp	al,ah
 	jbe	MR_exit

	mov	dx,0
	add	TempLS,3
	add	OffsetMem,15
MR_exit:
	ret
MovRigth endp
;---------------------------------------------------------------------
DelSoob proc near
	mov	cx,684
	mov	bx,OffsetMem2
	dec	bx
	sub	cx,bx
Del_next:
	mov	al,Memory[bx+76]
	mov	Memory[bx],al
	inc	bx	
	loop	Del_next

	mov	al,0
	mov	cx,76
	mov	bx,683
Del1_next:	
	mov	Memory[bx],al
	dec	bx
	loop	Del1_next

	ret
DelSoob endp
;---------------------------------------------------------------------
start:
	call	Install ;процедура инициализации параметров	
begin:
	call	SetupIO	;процедура выбора режима работы	
	call	Input	;процедура ввода собщения
	call	Output  ;процедура вывода сообщения с перемоткой и удалением
	jmp	begin
code 	ends
end 	start