; Модуль, содержащий все необходимые
; процедуры для интерфейсной части

; Сдвиг строки ввода/вывода на 1 разряд вправо
RotateStringRight Proc near
         push ax
         push bx

         xor bx,bx
  RSRcyc:mov ah,StrDisplay[bx+1]
         mov StrDisplay[bx],ah
         inc bx
         cmp bx,8
         jne RSRcyc
         mov StrDisplay[8],12

         pop bx
         pop ax
         ret
RotateStringRight EndP

; Сдвиг строки ввода/вывода на 1 разряд влево
RotateStringLeft Proc near
         push ax
         push bx

         mov bx,8
  RSLcyc:mov ah,StrDisplay[bx-1]
         mov StrDisplay[bx],ah
         dec bx
         jnz RSLcyc
         mov StrDisplay[0],12

         pop bx
         pop ax
         ret
RotateStringLeft EndP

; ПРОГРАММНЫЕ ИСПОЛНИТЕЛИ

; Опрос клавиатуры
KbdRead Proc near
    KRm1:mov dx,3                ; опрос портов ввода
   KRCyc:dec dl                  ; 2-0 и выход из цикла
         in al,dx                ; только после нажатия
         cmp al,0                ; какой-либо кнопки из
         jne KRexit              ; соединенных с портами
         cmp dl,0
         jnz KRCyc
         jmp KRm1
  KRexit:push ax

    KRm2:in al,dx                ; ввод по отжатию
         or al,al                ; клавиши
         jnz KRm2

         pop ax                  ; теперь в dl-номер
                                 ; активного порта, а
                                 ; в al-его содержимое

                                 ; определение номера
                                 ; активного входа
         xor cl,cl               ; активного порта
    KRm3:inc cl
         shr al,1                ; двигать до тех пор,
         jnz KRm3                ; пока 1 не уйдет
         dec cl

         mov al,dl               ; расчет кода
         shl al,1                ; клавиши
         shl al,1
         shl al,1
         add al,cl

         mov ActiveButtonCode,al

         ret
KbdRead EndP

; Ввод очередной цифры числа
DigInput Proc near
         cmp Error,0
         jne DIend

         mov al,ActiveButtonCode

         cmp al,0                ; проверка, а
         jb DIend                ; действительно ли
         cmp al,9                ; нажата цифровая
         ja DIend                ; клавиша

         cmp StrDisplay[12],0FFh        ; а может быть строку
         jne DIm1                ; надо вводить заново ?
         call StrClear
         mov StrDisplay[12],0

    DIm1:cmp StrDisplay[10],8           ; уже ввели 8 цифр
         je  DIend               ; {больше некуда}

         cmp StrDisplay[10],0           ; строка пустая?
         jne DIm2
         cmp al,0                ; и нажата кнопка "0" ?
         je DIend                ; да, и ничего вводить
                                 ; не надо
         jne DIm3                ; нет, и сдвигать раз-
                                 ; ряды строки не надо

    DIm2:call RotateStringLeft   ; сдвиг ранее введенных
                                 ; разрядов

    DIm3:mov StrDisplay[0],al           ; запись символа-цифры
         inc StrDisplay[10]             ; в младший разряд

   DIend:ret
DigInput EndP

; Ввод точки
PointInput Proc near
         cmp Error,0
         jne PIend

         mov al,ActiveButtonCode

         cmp al,Point            ; нажата клавиша "." ?
         jne PIend               ; нет, тогда выходим

         cmp StrDisplay[12],0FFh        ; а может быть строку
         jne PIm1                ; надо вводить заново ?
         call StrClear
         mov StrDisplay[12],0

    PIm1:cmp StrDisplay[11],0FFh        ; если точку уже вводи-
         je PIend                ; ли, то этот ввод точки
                                 ; игнорируется

         cmp StrDisplay[10],0           ; строка пустая?
         jne PIm2                ; нет, и переход
         inc StrDisplay[10]             ; да, тогда байт перед
                                 ; точкой - нулевой

    PIm2:call RotateStringLeft   ; сдвиг ранее введенных
                                 ; разрядов

         mov StrDisplay[0],al           ; запись точки в
                                 ; младший разряд
         mov StrDisplay[11],0FFh        ; установка флага на-
                                 ; личия точки в строке
   PIend:ret
PointInput EndP

; Смена знака
SignChange Proc near
         cmp Error,0
         jne SCend

         cmp ActiveButtonCode,SignChg
         jne SCend

         cmp StrDisplay[9],12           ; смена знака
         jne SCSP
         mov StrDisplay[9],11           ; знак "-"
         jmp SCend
    SCSP:mov StrDisplay[9],12           ; знак "+"

   SCend:ret
SignChange EndP

; Сложение того что на дисплее с тем,
; что будет введено позднее
AddRezArg Proc near
         cmp Error,0
         jne ARAend

         cmp ActiveButtonCode,Addition
         jne ARAend

         mov Operation,1         ; запомнить операцию '+'

         lea di,Rez              ; сохранить строку
                                 ; ввода/вывода в
                                 ; переменной Rez -
                                 ; 1-ое слагаемое

         call ConvertStringToFloat
         mov StrDisplay[12],0FFh

  ARAend:ret
AddRezArg EndP

; Вычитание из того что на дисплее того,
; что будет введено позднее
SubRezArg Proc near
         cmp Error,0
         jne SRAend

         cmp ActiveButtonCode,Subtraction
         jne SRAend

         mov Operation,2         ; запомнить операцию '-'

         lea di,Rez              ; сохранить строку
                                 ; ввода/вывода в
                                 ; переменной Rez -
                                 ; уменьшаемое

         call ConvertStringToFloat
         mov StrDisplay[12],0FFh

  SRAend:ret
SubRezArg EndP

; Умножение того что на дисплее с тем,
; что будет введено позднее
MulRezArg Proc near
         cmp Error,0
         jne MRAend

         cmp ActiveButtonCode,Multiplication
         jne MRAend

         mov Operation,3         ; запомнить операцию '*'

         lea di,Rez              ; сохранить строку
                                 ; ввода/вывода в
                                 ; переменной Rez -
                                 ; 1-ый множитель

         call ConvertStringToFloat
         mov StrDisplay[12],0FFh

  MRAend:ret
MulRezArg EndP

; Деление того что на дисплее на то,
; что будет введено позднее
DivRezArg Proc near
         cmp Error,0
         jne DRAend

         cmp ActiveButtonCode,Division
         jne DRAend

         mov Operation,4         ; запомнить операцию '/'

         lea di,Rez              ; сохранить строку
                                 ; ввода/вывода в
                                 ; переменной Rez -
                                 ; делимое

         call ConvertStringToFloat
         mov StrDisplay[12],0FFh

  DRAend:ret
DivRezArg EndP

; Выполнение действий
Calculate Proc near
         cmp Error,0
         jne Calcend

         cmp ActiveButtonCode,Calculation
         jne Calcend

         cmp Operation,0         ; если просто нажимать
         je Calcend              ; '=', то ничего не
                                 ; будет

         lea di,Arg              ; 2-ой аргумент операции

         call ConvertStringToFloat
         lea si,Rez
         xchg di,si

         cmp Operation,1
         jne Calcm1

         call AddFunc            ; сложение
         jmp Calcm4

  Calcm1:cmp Operation,2
         jne Calcm2

         call SubFunc            ; вычитание
         jmp Calcm4

  Calcm2:cmp Operation,3
         jne Calcm3

         call MulFunc            ; умножение
         jmp Calcm4

  Calcm3:cmp Operation,4
         jne Calcend

         cmp StrDisplay[10],0           ; если строка ввода
         je CalcEr               ; пуста, то деление
                                 ; на нуль

         call DivFunc            ; деление

  Calcm4:call OverflowChecking   ; контроль переполнения
         cmp al,0FFh
         jne Calcm5

  Calcer:mov Error,0Fh           ; ошибка
         jmp Calcend

  Calcm5:lea si,Rez              ; преобразование полу-
                                 ; ченного результата
                                 ; для дальнейшего
                                 ; отображения

         call ConvertFloatToString
         mov StrDisplay[12],0FFh

         mov Operation,0

 Calcend:ret
Calculate EndP

; Очистка переменных
Clear Proc near
         cmp ActiveButtonCode,Clr
         jne Cend

         lea di,Rez              ; обнуление 1-ого
         call FloatClear         ; аргумента
         lea di,Arg              ; обнуление 2-ого
         call FloatClear         ; агрумента

         mov Operation,0         ; операции нет

         call StrClear           ; очистка строки
                                 ; ввода/вывода

         cmp Error,0Fh           ; если это не ошибка
         jne Cend                ; памяти, то и
         mov Error,0             ; ошибки больше нет

    Cend:ret
Clear EndP

; Очистка строки ввода вывода
CE Proc near
         cmp Error,0
         jne CEend

         cmp ActiveButtonCode,ClrE
         jne CEend

         call StrClear           ; очистка строки
   CEend:ret
CE EndP

; Откат
Undo Proc near
         cmp Error,0
         jne Uend

         cmp ActiveButtonCode,Bksp
         jne Uend

         cmp StrDisplay[10],0           ; если строка пуста,
         je Uend                 ; то отменять нечего

         mov cx,1
         cmp StrDisplay[0],10           ; если в младшем байте
                                 ; не точка, то
         jne Um1 ;               ; цикл удаления младшего
                                 ; байта,
         mov cx,2                ; иначе цикл удаления
         mov StrDisplay[11],0           ; точки и следующего
                                 ; за ней байта

     Um1:call RotateStringRight  ; цикл удаления байта
         loop Um1
         dec StrDisplay[10]

         cmp StrDisplay[10],0           ; если на дисплее уже
         jne Uend                ; ничего не осталось,
         call StrClear           ; то строку ввода/вывода
                                 ; надо почистить

    Uend:ret
Undo EndP

; Очистка памяти
MemoryClear Proc near
         cmp ActiveButtonCode,MemClr
         jne MCend

         lea di,Mem
         call FloatClear

         cmp Error,0F0h
         jne MCend               ; переполнения памяти
         mov Error,0             ; после ее очистки нет

   MCend:ret
MemoryClear EndP

; Вывод содержимого памяти на дисплей
MemoryRead Proc near
         cmp Error,0
         jne MRend

         cmp ActiveButtonCode,MemRd
         jne MRend

         lea si,Mem              ; преобразование содер-
                                 ; жимого памяти для
                                 ; дальнейшего отображения

         call ConvertFloatToString
         mov StrDisplay[12],0FFh

   MRend:ret
MemoryRead EndP

; Сохранение в памяти
MemorySet Proc near
         cmp Error,0
         jne MSend

         cmp ActiveButtonCode,MemSet
         jne MSend

         lea di,Mem              ; пробразование строки
                                 ; ввода/вывода, отобра-
                                 ; женной на дисплее во
                                 ; внутренний формат
                                 ; для хранения в памяти

         call ConvertStringToFloat
         mov StrDisplay[12],0FFh

   MSend:ret
MemorySet EndP

; Сложение с памятью
MemoryAdd Proc near
         cmp Error,0
         jne MAend

         cmp ActiveButtonCode,MemAdd
         jne MAend

         lea di,Arg              ; второе слагаемое
         call ConvertStringToFloat
         lea si,Mem              ; 1-ое слагаемое -
         xchg di,si              ; память

         call AddFunc            ; сложение с памятью
         call OverflowChecking   ; контроль переполнения
         cmp al,0FFh
         jne MAend
         mov Error,0F0h          ; установка флага
                                 ; переполнения памяти
   MAend:ret
MemoryAdd EndP

; Вывод на дисплей сообщения Error
ErrMsgOutput Proc near
         cmp Error,0
         je EMOend

         xor al,al
         out 8,al                ; погасить
         out 7,al                ; индикаторы
         out 6,al                ; с номерами 8-5
         out 5,al

         mov al,73h              ; очертания символа E
         out 4,al                ; в порт вывода №4
         mov al,60h              ; очертания символа r
         out 3,al                ; в порты вывода №3,
         out 2,al                ; №2
         out 0,al                ; №0
         mov al,78h              ; очертания символа o
         out 1,al                ; в порт №1

  EMOend:ret
ErrMsgOutput EndP

; Отображение строки вывода
StrOutput Proc near
         cmp Error,0
         jne SOend

    SOst:xor dx,dx               ; вывод строки
         mov bx,offset OutputMap
         lea si,StrDisplay
         push si
   SOCyc:lodsb
         xlat
         cmp al,80h              ; если текущий байт -
         jne SOm1                ; точка, то ее надо
         mov ah,al               ; приORить к следую-
         lodsb                   ; щему байту
         xlat
         or al,ah
    SOm1:out dx,al
         inc dx
         cmp dx,8
         jne SOCyc

         pop si                  ; адрес начала строки
         add si,9                ; байт знака
         lodsb
         xlat                    ; преобразование
         out dx,al               ; вывод знака

   SOend:ret
StrOutput EndP