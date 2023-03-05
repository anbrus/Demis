DelMax	equ	55 ;Максимальная величина задержки.
DelMin	equ	1  ;Минимальная величина задержки.
dV	equ	3  ;Шаг изменения скорости вращения.

DATA	segment at 0B940h
KbdImg	db	? ;Состояние нефикс кл.
Indic	db  4 dup(?) ;Образ экрана 7-сегментных индикаторов.
TypeDir db	? ;Направление вращения: 00h - по час стрелке, 0FFh - против.
Delay	db	? ;Величина задержки.
DelCnt	db	? ;Счетчик задержки.
FixK	db	?
DATA	ends

;bit 0 - Speed Up
;bit 1 - Speed Down
;bit 2 - Inv Dir

CODE	segment
	assume cs:CODE, ds:DATA

   ;Подпрограмма обработки ввода (нефикс кл).
InProc	PROC	;AL - инфо о нажатии нефикс кл.
	mov	dl,Delay
	shr	al,1
	jnc	L1m1
	sub	dl,dV ;Если нажата Speed Up, то уменьш задержку.
L1m1:	shr	al,1
	jnc	L1m2
	add	dl,dV ;Если нажата Speed Down, то увелич задержку.
L1m2:	mov	bl,al ;Временно сохраняем сост нефикс кл в bl.
	cmp	dl,DelMin ;Проверка величины задержки.
	jg	Cmpmax
	mov	dl,DelMin   ;Если она слишком мала, то устан min вел
	jmp	short Errsp ;задержки и зажечь "Недоп скорость".
Cmpmax: cmp	dl,DelMax
	jb	Cmpok ;Если она нормальная, то переход.
	mov	dl,DelMax ;Если она слишком велика, то устан макс вел
Errsp:	mov	al,1      ;задержки и зажечь "Недоп скорость".
	out	4,al
	jmp	short Tstdir
Cmpok:	xor	al,al  ;Гашение "Недоп скорость".
	out	4,al
Tstdir:	mov	dh,dl    ;Коррекция
	cmp	dl,Delay ;счетчика
	je	Tstd2	 ;задержки
	sub	dl,Delay ;под
	add	dl,DelCnt;новую
	jnle	Tstd1	 ;величину
	mov	dl,1	 ;задержки.
Tstd1:	mov	DelCnt,dl
Tstd2:	mov	Delay,dh ;Запоминание величины задержки.
	mov	al,bl ;Восстан сост нефикс кл из bl.
	shr	al,1
	jnc	IPon
	not	TypeDir ;Если нажата InvDir, то изменить направл вращения.
IPon:	shr	al,1
	jnc	IPexit
	mov	FixK,bh
IPexit:	ret
InProc	ENDP

   ;Подпрограмма индикации.
Disp	PROC	
	mov	al,Delay  ;Обновление
	mov	DelCnt,al ;счетчика задержки.
	mov	bx,4	;Адрес хвоста образа экрана и счетчик индикаторов.
	mov	ah,FixK	;Чтение сост фикс кл в AH.
   ;Цикл по индикаторам.
DLoop1: shl	ah,1   ;Если фикс кл текущего индикатора нажата,
	jc	Disp1  ;то переход на вращение.
	xor	al,al  ;Иначе - гашение
	jmp	Outscr ;текущего индикатора.
Disp1:	mov	al,[bx] ;Текущая инфо на текущем индикаторе.
	cmp	TypeDir,0 ;Иначе - вращаем сегменты.
	je	Cw   ;Если TypeDir=0, то переход на вращение по час стрелке.
	shr	al,1 ;Иначе - вращение против час стрелки.
;	cmp	al,00000000b
	jnz	cwok
	mov	al,00100000b
	jmp	short cwok
Cw:	shl	al,1
	cmp	al,01000000b
	jb	Cwok
	mov	al,00000001b
Cwok:	mov	[bx],al
Outscr: dec	bx	;Адрес следующ индикатора в образе в памяти.	{<-}
	mov	dx,bx	;Адрес следующ порта индикатора и декр счетч цикла.
	out	dx,al	;Выдача данных на текущий индикатор.
	jnz	DLoop1	;Переход к обработке следующего индикатора.
	ret
Disp	ENDP

;М А К Р О У Р О В Е Н Ь
   ;Подготовка
start:	mov	ax,DATA
	mov	ds,ax
	mov	ax,10 ;Величина задержки для скорости приблиз 1Гц.
	mov	Delay,al
	mov	DelCnt,al
	mov	TypeDir,ah ;Направление вращения - по час стрелке.
	mov	KbdImg,ah
	mov	FixK,ah
	mov	al,1
	mov	Indic[0],al
	mov	Indic[1],al
	mov	Indic[2],al
	mov	Indic[3],al

   ;Чтение клавиатуры
Mloop:	in	al,[0]
	mov	bh,al	  ;Запоминаем состояние фикс клавиш в bh.

   ;Расшифровка клавиатуры
	xor	al,KbdImg ;Если сост нефикс кл изменилось, соотв бит = 1.
	and	al,bh	  ;Если нефикс кл стала нажатой, соотв бит = 1.
	mov	KbdImg,bh ;Запоминаем состояние нефикс клавиш.

   ;Обработка ввода (нефикс кл)
	jz	mDisp
	call	InProc

   ;Отображение
mDisp:	dec	DelCnt	;Если счетчик задержки не обнулился,
	jnz	Mloop	;то переход на начало цикла,
	call	Disp	;иначе повенуть и отобразить сегменты.
	jmp	Mloop

CODE	ends
	end start