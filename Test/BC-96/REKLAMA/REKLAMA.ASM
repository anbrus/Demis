page 50,120

      ;Программа работы устройства управления световой рекламой

                        NAME LigthReklama

      ;Описание данных
Data1 segment at 0ba00h

      ;Описание служебных данных
      codes    db  14 dup (?)
      addrr&p  dw  ?
      datakbd  db  ?
      olddata0 db  ?
      olddata1 db  ?
      oldtype  db  ?

      ;Описание флагов
      clean    db  ?
      endin    db  ?
      endr     db  ?
      follr    db  ?
      loading  db  ?
      mode     db  ?
      nokbd    db  ?
      ok       db  ?
      switch   db  ?
      typectrl db  ?
      typed    db  ?
      typers   db  ?

      ;Описание счетчиков
      cnt      dw  ?
      cntdp    dw  ?
      cntp     dw  ?
      cntr     db  ?
      cntrek   dw  ?

      ;Описание структурированных данных
      report1  db  20 dup (?)
      report2  db  20 dup (?)
      report3  db  20 dup (?)
      decprice db  6 dup (?)
      price1   db  2 dup (?)
      price2   db  2 dup (?)
      price3   db  2 dup (?)
      amount   db  3 dup (?)
      reklama  db  252 dup (?)
Data1 ends

      ;Описание стека
Stack1 segment at 0ba80h
               db 512 dup (?)
      stktop   label word
Stack1 ends

      ;Описание выполняемых действий
Code1 segment
      assume cs:Code1,ds:Data1,ss:Stack1

      ;Описание программных модулей

;Модуль "Инициализация таблицы кодов"
InitCodes proc near
       mov codes[0],3fh  ;"0"
       mov codes[1],0ch  ;"1"
       mov codes[2],76h  ;"2"
       mov codes[3],5eh  ;"3"
       mov codes[4],4dh  ;"4"
       mov codes[5],5bh  ;"5"
       mov codes[6],7bh  ;"6"
       mov codes[7],0eh  ;"7"
       mov codes[8],7fh  ;"8"
       mov codes[9],5fh  ;"9"
       mov codes[10],73h ;"E"
       mov codes[11],67h ;"P"
       mov codes[12],6fh ;"R"
       mov codes[13],60h ;"r"
       mov ok,1
       ret
InitCodes endp

;Модуль "Подготовка к старту"
GetStart proc near
       cmp ok,1
       jnz gs1
       mov al,0ch
       out 1,al
       mov si,0eh
       mov cx,0b8h
gs2:   mov word ptr [si],0
       add si,2
       loop gs2
       mov nokbd,1
       mov cntr,1
       mov cntrek,1
gs1:   ret
GetStart endp

;1. Модуль "Ввод режимов"
InputMode proc near
       in al,1
       cmp al,4      ;Обработка
       jnz im1       ;ввода
       mov mode,0    ;режима
       mov ok,1      ;"Ввод"
       mov clean,1
       mov endin,0
       jmp im2
im1:   cmp al,32     ;Обработка
       jnz im2       ;ввода
       mov mode,1    ;режима
       mov loading,1 ;"Вывод"
im2:   ret
InputMode endp

;2. Модуль "Ввод типа данных"
InputType proc near
       cmp mode,0
       jnz it1
       cmp endin,0
       jnz it1
       in al,1
       cmp al,oldtype ;Защита
       jz it1         ;от повторного
       mov oldtype,al ;нажатия
       cmp al,8       ;Обработка
       jnz it2        ;ввода
       mov typed,1    ;типа данных
       mov typectrl,1 ;"Цена"
       jmp it3
it2:   cmp al,10h     ;Обработка
       jnz it1        ;ввода
       mov typed,0    ;типа данных
       mov follr,1    ;"Сообщение"
it3:   mov endr,0
       mov clean,1
it1:   ret
InputType endp

;3. Модуль "Контроль за вводимым сообщением"
CtrlReport proc near
       cmp mode,0
       jnz cre1
       cmp endin,0
       jnz cre1
       cmp typectrl,0 ;Проверка
       jnz cre3       ;"Конец сообщения?"
       cmp cnt,14h
       jnz cre1
       mov endr,1
cre3:  mov typectrl,0
       mov cnt,0
       mov al,3       ;Предупреждение
       out 0,al       ;о конце сообщения
       mov cx,2ffh    ;на двоичном
cre2:  nop            ;индикаторе
       loop cre2
       mov al,1
       out 0,al
cre1:  ret
CtrlReport endp

;4. Модуль "Контроль за вводимой ценой"
CtrlPrice proc near
       cmp mode,0
       jnz cp1
       cmp endin,0
       jnz cp1
       cmp cntp,2  ;Проверка
       jnz cp1     ;"Конец ввода цены?"
       mov endr,1
       mov cntp,0
cp1:   ret
CtrlPrice endp

;5. Модуль "Очистка дисплея"
Cleaning proc near
       cmp clean,1
       jnz c2
       mov al,0    ;Очистка
       mov dx,2    ;десятиразрядного
       mov cx,10   ;знакосинтезирующего
c1:    out dx,al   ;дисплея
       inc dx
       loop c1
       cmp mode,1  ;Если режим "Вывод",то очистка
       jnz c3      ;семисегментного знакосинтезирующего
       out 1,al    ;индикатора "Номер сообщения"
c3:    mov clean,0
c2:    ret
Cleaning endp

;6. Модуль "Ввод сообщения и цены"
InputR&P proc near
       cmp mode,0
       jnz erc7
       cmp endin,0
       jnz erc7
       cmp endr,0
       jnz erc7
       mov cl,0ffh
       in al,0
       cmp al,olddata0 ;Защита
       jz erc2         ;от повторного
       mov olddata0,al ;нажатия
       cmp al,0        ;Обработка
       jz erc2         ;порта
erc1:  inc cl          ;ввода
       shr al,1        ;с номером 0
       jnc erc1
       mov al,cl
       jmp erc4
erc2:  in al,1
       cmp al,olddata1 ;Защита
       jz erc5         ;от повторного
       mov olddata1,al ;нажатия
       cmp al,1        ;Обработка
       jnz erc3        ;порта
       mov al,8        ;ввода
       jmp erc4        ;с номером 1
erc3:  cmp al,2
       jnz erc5
       mov al,9
erc4:  mov datakbd,al
       mov nokbd,0
       cmp typed,1
       jnz erc7
       lea si,decprice
       add si,cntdp
       mov [si],al
       inc cntdp
       jmp erc7
erc5:  mov nokbd,1
erc7:  ret
InputR&P endp

;7. Модуль "Формирование сообщения и цены"
ShapingR&P proc near
       cmp mode,0
       jnz srp3
       cmp endin,0
       jnz srp3
       cmp endr,0
       jnz srp3
       cmp nokbd,0
       jnz srp3
       cmp typed,0    ;Загрузка
       jnz srp4       ;необходимых
       lea si,report1 ;параметров,
       lea di,cnt     ;в зависимости
       mov dx,14h     ;от типа данных
srp4:  cmp typed,1
       jnz srp5
       lea si,price1
       lea di,cntp
       mov dx,2
srp5:  cmp cntr,2     ;Проверка
       jnz srp1       ;номера
       add si,dx      ;сообщения
       jmp srp2       ;и корректировка
srp1:  cmp cntr,3     ;параметров
       jnz srp2
       add dx,dx
       add si,dx
srp2:  mov addrr&p,si ;Сохранение адреса массива
       mov al,datakbd ;Формирование
       mov cx,[di]    ;массива
       xlat           ;отображения
       add si,cx
       mov [si],al
       inc cx
       mov [di],cx
srp3:  ret
ShapingR&P endp

;8. Модуль "Вывод сообщения ErrP"
OutNoPrice proc near
       cmp mode,0
       jnz onp1
       cmp endin,0
       jnz onp1
       cmp follr,1
       jnz onp1
       mov si,addrr&p
       cmp si,offset price1
       jnb onp1
       mov typed,1
       mov follr,0
       mov al,codes[10] ;Вывод
       out 5,al         ;сообщения
       mov al,codes[13] ;ErrP
       out 4,al
       mov al,codes[13]
       out 3,al
       mov al,codes[11]
       out 2,al
       mov cx,0affh
onp2:  nop
       loop onp2
       mov clean,1
onp1:  ret
OutNoPrice endp

;9. Модуль "Вывод номера вводимого сообщения"
OutNumR proc near
       cmp mode,0
       jnz onr1
       cmp endin,0
       jnz onr1
       cmp follr,1
       jnz onr1
       mov follr,0
       inc cntr
       cmp cntr,4
       jnz onr2
       dec cntr
       mov endin,1
       jmp onr1
onr2:  lea bx,codes ;Вывод
       mov al,cntr  ;номера
       xlat         ;вводимого
       out 1,al     ;сообщения
onr1:  ret
OutNumR endp

;10. Модуль "Вывод сообщения и цены"
OutR&P proc near
       cmp mode,0
       jnz orp2
       cmp endin,0
       jnz orp2
       cmp endr,0
       jnz orp2
       cmp nokbd,0
       jnz orp2
       cmp typed,0 ;Проверка
       jnz orp3    ;типа
       mov cx,cnt  ;данных
       add si,cx   ;и соответсвующая
orp3:  cmp typed,1 ;подготовка
       jnz orp4    ;параметров
       mov cx,cntp
       add si,cx
orp4:  dec si
orp1:  mov al,[si] ;Вывод
       out dx,al   ;сообщения или цены,
       inc dx      ;в зависимомти от
       dec si      ;типа данных
       loop orp1
orp2:  ret
OutR&P endp

;11. Модуль "Вывод сообщения ErrR"
OutNoOut proc near
       cmp mode,1
       jnz ono1
       cmp loading,1
       jnz ono1
       cmp endin,0
       jnz ono1
       mov mode,0
       mov al,codes[10] ;Вывод
       out 5,al         ;сообщения
       mov al,codes[13] ;ErrR
       out 4,al
       mov al,codes[13]
       out 3,al
       mov al,codes[12]
       out 2,al
       mov cx,0affh
ono2:  nop
       loop ono2
       mov clean,1
ono1:  ret
OutNoOut endp

;12. Модуль "Тестирование цен введенных сообщений"
TestPrice proc near
       cmp mode,1
       jnz tp1
       cmp loading,1
       jnz tp1
       lea si,decprice
       lea bx,amount
       mov cx,3
tp6:   mov dx,word ptr [si] ;Преобразование
       mov ah,dl            ;цены
       mov al,dh
       shl ah,4
       or al,ah
       cmp al,76h           ;Тестирование
       jb tp2               ;цены
       mov byte ptr [bx],4  ;и формирование
       jmp tp5              ;частоты
tp2:   cmp al,51h           ;вывода
       jb tp3               ;для каждого
       mov byte ptr [bx],3  ;сообщения
       jmp tp5
tp3:   cmp al,26h
       jb tp4
       mov byte ptr [bx],2
       jmp tp5
tp4:   cmp al,1
       jb tp5
       mov byte ptr [bx],1
tp5:   add si,2
       inc bx
       loop tp6
       mov ax,15h           ;Вычисление
       mov bl,amount[0]     ;количества
       add bl,amount[1]     ;символов
       add bl,amount[2]     ;в массиве
       mul bl               ;световой
       inc ax               ;рекламы
       mov cnt,ax
tp1:   ret
TestPrice endp

;13. Модуль "Формирование световой рекламы"
ShapingRek proc near
       cmp mode,1
       jnz shr1
       cmp loading,1
       jnz shr1
       mov cx,4
       lea di,reklama      ;Загрузка
shr5:  lea si,report1      ;необходимых
       lea bx,amount       ;параметров
shr4:  mov dx,0
       cmp byte ptr [bx],0 ;Формирование
       ja shr3             ;массива
       add si,20           ;отображения
       jmp shr2            ;"Световая реклама"
shr3:  mov al,[si]
       mov [di],al
       inc si
       inc di
       inc dx
       cmp dx,20
       jnz shr3
       mov byte ptr [di],0
       inc di
       dec byte ptr [bx]
shr2:  inc bx
       cmp bx,offset reklama
       jb shr4
       loop shr5
       mov clean,1
       mov loading,0
shr1:  ret
ShapingRek endp

;14. Модуль "Пуск/Стоп световой рекламы"
SwitchOn_Off proc near
       cmp mode,1
       jnz is1
       in al,1
       cmp al,40h   ;Обработка
       jnz is2      ;нажатия кнопки
       mov switch,1 ;"Пуск"
is2:   cmp al,80h   ;Обработка
       jnz is1      ;нажатия кнопки
       mov switch,0 ;"Стоп"
is1:   ret
SwitchOn_Off endp

;15. Модуль "Ввод типа бегущей строки"
InputTypeRS proc near
       cmp mode,1
       jnz itrs1
       in al,2      ;Обработка
       cmp al,0     ;ввода типа
       je itrs1     ;бегущей строки
       cmp al,1
       jnz itrs2
       mov typers,0 ;обычная БС
       mov al,0
itrs2: cmp al,2
       jnz itrs3
       mov typers,1 ;обычная БС с миганием
       mov al,0
itrs3: cmp al,4
       jnz itrs5
       mov typers,2 ;инверсная БС
       mov al,7fh
itrs5: mov cx,10    ;Подготовка
       mov dx,2     ;десятиразрядного
itrs4: out dx,al    ;знакосинтезирующего
       inc dx       ;дисплея
       loop itrs4   ;к выводу
itrs1: ret
InputTypeRS endp

;16. Модуль "Вывод СР в форме обычной БС"
OutDirectRS proc near
       cmp mode,1
       jnz odrs1
       cmp switch,1
       jnz odrs1
       cmp typers,0
       jnz odrs1
       cmp bx,cntrek ;Подготовка
       ja odrs4      ;необходимых
       mov cntrek,1  ;параметров
odrs4: mov cx,cntrek
       add si,cx
       dec si
odrs2: mov al,[si]   ;Вывод
       out dx,al     ;световой рекламы
       inc dx        ;в форме
       dec si        ;обычной
       loop odrs2    ;бегущей строки
       mov bx,1ffh
odrs3: dec bx
       cmp bx,0
       jnz odrs3
       inc cntrek
odrs1: ret
OutDirectRS endp

;17. Модуль "Вывод СР в форме обычной БС с миганием"
OutFlickRS proc near
       cmp mode,1
       jnz ofrs1
       cmp switch,1
       jnz ofrs1
       cmp typers,1
       jnz ofrs1
       cmp bx,cntrek ;Подготовка
       ja ofrs4      ;необходимых
       mov cntrek,1  ;параметров
ofrs4: mov cx,cntrek
       add si,cx
       dec si
ofrs2: mov al,[si]   ;Вывод
       out dx,al     ;световой рекламы
       inc dx        ;в форме
       dec si        ;обычной
       loop ofrs2    ;бегущей строки
       mov bx,0ffh   ;с миганием
ofrs3: dec bx
       cmp bx,0
       jnz ofrs3
       mov dx,2
       mov cx,cntrek
ofrs5: mov al,0
       out dx,al
       inc dx
       loop ofrs5
       mov bx,0ffh
ofrs6: dec bx
       cmp bx,0
       jnz ofrs6
       inc cntrek
ofrs1: ret
OutFlickRS endp

;18. Модуль "Вывод СР в форме инверсной БС"
OutInversRS proc near
       cmp mode,1
       jnz oirs1
       cmp switch,1
       jnz oirs1
       cmp typers,2
       jnz oirs1
       cmp bx,cntrek ;Подготовка
       ja oirs4      ;необходимых
       mov cntrek,1  ;параметров
oirs4: mov cx,cntrek
       add si,cx
       dec si
oirs2: mov al,[si]   ;Вывод
       not al        ;световой рекламы
       out dx,al     ;в форме
       inc dx        ;инверсной
       dec si        ;бегущей строки
       loop oirs2
       mov bx,1ffh
oirs3: dec bx
       cmp bx,0
       jnz oirs3
       inc cntrek
oirs1: ret
OutInversRS endp

;19. Модуль "Индикация режимов"
IndicModes proc near
       cmp mode,0 ;Режим "Ввод"?
       jnz inm1
       mov al,1   ;Да
       jmp inm2
inm1:  mov al,4   ;Нет
inm2:  out 0,al   ;Включение необходимого
                  ;двоичного индикатора
       ret
IndicModes endp

      ;Макроуровень программы

begin1:                  ;Системная подготовка
       mov ax,data1      ;Инициализация
       mov ds,ax         ;сегментных
       mov ax,stack1     ;регистров
       mov ss,ax
       lea sp,StkTop     ;и указателя стека
       call InitCodes    ;Инициализация таблицы кодов
begin2:call GetStart     ;Подготовка к старту
       call InputMode    ;Ввод режимов
       call InputType    ;Ввод типа данных
       call CtrlReport   ;Контроль за вводимым сообщением
       call CtrlPrice    ;Контроль за вводимой ценой
       call Cleaning     ;Очистка дисплея
       call InputR&P     ;Ввод сообщения и цены
       lea bx,codes      ;Загрузка таблицы кодов
       call ShapingR&P   ;Формирование сообщения и цены
       call OutNoPrice   ;Вывод сообщения ErrP
       call OutNumR      ;Вывод номера вводимого сообщения
       mov si,addrr&p    ;Передача параметров для вывода
       mov dx,2          ;сообщения и цены
       call OutR&P       ;Вывод сообщения и цены
       call OutNoOut     ;Вывод сообщения ErrR
       call TestPrice    ;Тестирование цен введенных сообщений
       call ShapingRek   ;Формирование световой рекламы
       call SwitchOn_Off ;Пуск/Стоп световой рекламы
       call InputTypeRS  ;Ввод типа бегущей строки
       mov bx,cnt        ;Передача параметров
       lea si,reklama    ;для вывода
       mov dx,2          ;световой рекламы
       call OutDirectRS  ;Вывод СР в форме обычной БС
       call OutFlickRS   ;Вывод СР в форме обычной БС с миганием
       call OutInversRS  ;Вывод СР в форме инверсной БС
       call IndicModes   ;Индикация режимов
       jmp begin2        ;Замыкание программного кольца
       org 7f0h          ;Обеспечение начального запуска
start: jmp begin1        ;программы при включении устройства
code1 ends
      end start