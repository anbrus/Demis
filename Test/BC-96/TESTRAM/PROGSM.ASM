;Файл вспомогательных процедур

TestNumber1	=0AAh
TestNumber2	=055h
TestOkLamp	=1000000b
EnterKey	=10000000b
;===================================
GetKeyNumber proc
	mov ah,0
@@1:
	shr al,1
	cmp al,0
	je @@exit
	inc ah
	jmp @@1
@@exit:
	mov cl,ah
	ret
GetKeyNumber endp

;================================
MakeAddress proc
	mov ax,word ptr RealAddress
	mov dx,1111000000000000b
	and dx,ax
	shl ax,4
	add al,NewKey
	dec al
	mov word ptr RealAddress,ax
	mov word ptr RealAddress[2],dx
	ret
MakeAddress endp

;================================
MakeSize proc
	mov ax,CurSize
	shl ax,4
	mov dl,NewKey
	dec dl
	add al,dl
	mov CurSize,ax
	ret
MakeSize endp

;================================
MakeAutoVars proc		;создание переменных 
				;для автоматического режима
	cmp NewKey,0		;устанавливаем факт нажатия
	jne @@1
	jmp @@exit
@@1:
	mov al,OLdKey
	cmp al,NewKey		;факт однократного нажатия
	jne @@2
	jmp @@exit

@@2:
	cmp Address_Size,Address;устанавливаем адрес ?
	jne @@3
	call MakeAddress	;собираем адрес
	jmp @@exit

@@3:
	cmp Address_Size,_Size
	jne @@exit
	call MakeSize
	 
@@exit:
	ret			;
MakeAutoVars endp

;================================
MakeMemData proc
	call MakeAcces
	push es
	les di,RealAddress
	mov al,es:[di]
	shl al,4
	mov ah,NewKey
	dec ah
	add al,ah
	mov es:[di],al
	pop es
	call NoAcces
	ret
MakeMemData endp

;================================
MakeManualVars proc		;создание переменных 
				;для автоматического режима
	cmp NewKey,0		;устанавливаем факт нажатия
	jne @@1
	jmp @@exit
@@1:
	mov al,OLdKey
	cmp al,NewKey		;факт однократного нажатия
	jne @@2
	jmp @@exit

@@2:
	cmp Address_Data,Address;устанавливаем адрес ?
	jne @@3
	call MakeAddress	;собираем адрес
	jmp @@exit

@@3:
	cmp Address_Data,_Data
	jne @@exit
	call MakeMemData
	 
@@exit:
	ret			;
MakeManualVars endp

;================================
ManualMake proc
	cmp NewMode,Manual
	je @@111
	jmp @@exit
@@111:
	cmp Dir,Forward
	jne @@1
	add word ptr RealAddress,1
	pushf
	mov ax,word ptr RealAddress[2]
	shr ax,12
	popf
	adc ax,0
	mov dx,ax
	lahf
	and ah,00001000b
	je @@move1			;если есть перенос всп.
	mov word ptr RealAddress[2],0
	jmp @@exit

@@move1:				;нет всп. переноса
	shl dx,12
	mov word ptr RealAddress[2],dx	
	jmp @@exit
;========направление назад

@@1:					;направление назад
	sub  word ptr RealAddress,1
	pushf
	mov ax,word ptr RealAddress[2]
	shr ax,12
	popf
	sbb ax,0
	jnc @@MovHighPart
	mov word ptr RealAddress[2],0F000h
	jmp @@exit
@@MovHighPart:
	shl ax,12
	mov word ptr RealAddress[2],ax
@@exit:
	ret
ManualMake endp

;================================
TestProcess proc			;процедура тестирования

@@UnPressWait:				;ожидание отжатия клавиш
	in al,OptionPort
	cmp al,0
	jne @@UnPressWait

	mov al,0
	out LampPort,al			;потушить лампочки

	cmp CurSize,0			;проверка размера проверяемой области
	jne @@NoE			;если размер >0 то переход к тесту

	mov ErrFlag,SizeErr		;иначе действия при ошибке
	mov al,SizeErr
	call DannErrorProcess
	jmp @@exit
@@NoE:
	;непосредственно операторы теста
	;сначала проверка на правильность записи
	;в ячейки памяти
	call MakeAcces
	mov cx,CurSize			;длинна проверяемой области
	les di,RealAddress		;загрузка адреса провряемой области
	mov si,word ptr Dir
@@TestLoop:
	mov dl,es:[di]			;сохраняем знячение ячейки памяти
	mov es:[di],byte ptr TestNumber1;запись первого тестового числа
	mov al,es:[di]			;считывание числа
	cmp al,TestNumber1		;сравнение считанного числа с эталоном
	jne @@FindError			;если не совпало то ???
	mov es:[di],byte ptr TestNumber2;запись второго тестового числа
	mov al,es:[di]			;считывание числа
	cmp al,TestNumber2		;сравнение
	jne @@FindError			;если не совпало то ???
@@ContinueTest:
	mov es:[di],dl			;если все хорошо то восстановление ЯП
	cmp si,Forward
	jne @@Bc
	add di,1
	jmp @@trim
@@Bc:
	sub di,1
@@trim:
	jnc @@Loop			;исли переполнение в смещении то
	mov ax,si
	shl ax,12
	push bx
	mov bx,es
	add ax,bx
	pop bx
	mov es,ax
					;инкремент нормализованного сегмента
@@Loop:
	loop @@TestLoop			;зацикливание
	call NoAcces
	jmp @@NextTest			;переход на следующий тест

@@FindError:				;обработка ошибок

	mov word ptr DispAdr,di
	mov word ptr DispAdr[2],es
	push ax				;сохранить ax
	push si
	push es
	push cx
	push dx
	mov al,MemDBusErr		;тип ошибки в al
	call NoAcces		
	call DannErrorProcess		;действия пользователя при ошибке
	cmp al,ContinueKey			;анализ действий
	jne @@exit11
	call MAkeAcces
	pop dx
	pop cx
	pop es
	pop si
	pop ax
	jmp @@ContinueTest
@@exit11:
	pop dx
	pop cx
	pop ax
	pop si
	pop ax
	jmp @@exit1
@@NextTest:	
@@exit:
	call DispOkResult
	mov ErrFlag,NoErr
@@exit1:
	ret				;выход
TestProcess endp

;================================
StopKey=10000000b			;кнопка Cтоп
ContinueKey=01000000b			;кнопка Продолжить
ErrorPort=11

DannErrorProcess proc			;действия при ошибках
					;показать сообщение об ошибке
	
					;обнуление массива отображения
	push bx				;сохранение bx
	lea bx,DispArray		;в bx адрес массива отображения
	mov cx,7			;в cx длинна массива отображения
@@ZeroDisp:				;цикл обнуления
	mov [bx],byte ptr 0
	inc bx
	loop @@ZeroDisp
	pop bx				;восстановление bx

	push ax
	mov al,Map[14]
	mov DispArray[4],al
	mov al,MAp[16]
	mov DispArray[3],al
	mov DispArray[2],al
	mov al,Map[2]
	mov DispArray[1],al
	pop ax

	cmp al,SizeErr
	jne @@1
	push ax
	mov al,Map[1]
	mov DispArray[1],al		;дописать ошибку
	pop ax
	call OutputDispArr
@@SE:
	in al,OptionPort
	cmp al,EnterKey
	jne @@SE
@@1:	
	cmp al,MemDBusErr
	jne @@2
	call MakeAdr1
	call OutputDispArr
	mov al,1
	out ErrorPort,al
@@Wp:
	in al,OptionPort
	cmp al,ContinueKey
	jne @@3
@@WUp:					;ожидание отжатия клавиши
	in al,OptionPort
	cmp al,0
	jne @@WUp
	mov al,ContinueKey
	jmp @@exit	
@@3:	
	cmp al,EnterKey
	jne @@Wp
	mov al,1
	jmp @@exit
@@2:
@@exit:	
	push ax
	mov al,0
	out ErrorPort,al
	pop ax
	ret;
DannErrorProcess endp

;=========================================
MakeAcces proc				;освобождение от пошагового режима
	push ax

	mov ax,es
	mov KeepEs,ax
					;сохранение регистров
	pushf				;извлечение флагов
	pop ax				;помещение флагов в аккумулятор
	mov KeepFlag,ax			;сохранение флагов
	and ax,1111111011111111b	;снятие флага
	push ax				;новые флаги  в стек
	popf				;новые флаги в регистр флагов
	pop ax				;восстановление регистров
	ret
MakeAcces endp

;=========================================
NoAcces proc
	push ax
	mov ax,KeepEs
	mov es,ax

	mov ax,KeepFlag			;в axсохранненый регистр флагов
	push ax				;сохраненные флаги в стек
	popf				;восстановление регистра флагов
	pop ax
	ret
NoAcces endp

;=========================================
MakeAdr1 proc
	push ax
	push bx
	push si
	push di
	push cx
	lea bx,map
	lea si,DispArray	
	mov dx,word ptr DispAdr
	mov cx,4
@@1:
	mov ax,0Fh
	and ax,dx
	xlat
	mov [si],al
	shr dx,4
	inc si
	loop @@1	
	
	mov ax,word ptr DispAdr[2]
	shr ax,12
	xlat
	mov [si],al
	inc si	
	call MakeAcces
	les di,DispAdr
	mov dl,es:[di]
	call NoAcces
	mov cx,2
@@2:
	mov al,0fh
	and al,dl
	xlat 
	mov [si],al
	inc si
	loop @@2

	pop cx
	pop di
	pop si
	pop bx
	pop ax
	ret
MakeAdr1 endp
;=========================================
DispOkResult proc
	mov al,TestOkLamp
	out LampPort,al			;высветить индикатор конца теста

@@1:					;ожидание нажатия ввода
	in al,OptionPort	
	cmp al,EnterKey
	jne @@1
	
	ret
DispOkResult endp