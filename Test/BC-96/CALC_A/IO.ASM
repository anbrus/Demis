RotateStringRight Proc near
         push ax
         push bx

         xor bx,bx
  RSRcyc:mov ah,Str[bx+1]
         mov Str[bx],ah
         inc bx
         cmp bx,8
         jne RSRcyc
         mov Str[8],12

         pop bx
         pop ax
         ret
RotateStringRight EndP

RotateStringLeft Proc near
         push ax
         push bx

         mov bx,8
  RSLcyc:mov ah,Str[bx-1]
         mov Str[bx],ah
         dec bx
         jnz RSLcyc
         mov Str[0],12

         pop bx
         pop ax
         ret
RotateStringLeft EndP

KbdRead Proc near
         push ax
         push cx
         push dx

; опрос портов ввода 2-0 и выход только после
; нажатия какой-либо кнопки из соединенных с портами
    KRm1:mov dx,3
   KRCyc:dec dl
         in al,dx
         cmp al,0
         jne KRexit
         cmp dl,0
         jnz KRCyc
         jmp KRm1
  KRexit:push ax

; ввод по отжатию клавиши
    KRm2:in al,dx
         or al,al
         jnz KRm2

         pop ax ; теперь в dl-номер активного порта, а в al-его содержимое

; определение номера активного входа активного порта
         xor cl,cl
    KRm3:inc cl
         shr al,1
         jnz KRm3 ; двигать до тех пор, пока 1 не уйдет
         dec cl

; рассчет кода клавиши
         mov al,dl
         shl al,3
         add al,cl

         mov ActiveButtonCode,al

         pop dx
         pop cx
         pop ax
         ret
KbdRead EndP

; ввод очередной цифры числа
DigInput Proc near
         push ax

         cmp Error,0
         jne DIend

         mov al,ActiveButtonCode

; проверка, а действительно ли нажата цифровая клавиша
         cmp al,0
         jb DIend
         cmp al,9
         ja DIend

; а может быть строку надо вводить заново ?
         cmp Str[12],0FFh
         jne DIm1
         call StrClear
         mov Str[12],0

    DIm1:cmp Str[10],8
         je  DIend ; уже ввели 8 цифр {больше некуда}

         cmp Str[10],0 ; строка пустая?
         jne DIm2
         cmp al,0 ; и нажата кнопка "0"
         jne DIm2
         call DispClear ; вывести в младший разряд '0'
         jmp DIend

    DIm2:call RotateStringLeft ; сдвиг ранее введенных разрядов

; запись символа-цифры в младший разряд
         mov Str[0],al
         inc Str[10]

   DIend:pop ax
         ret
DigInput EndP

PointInput Proc near
         push ax

         cmp Error,0
         jne PIend

         mov al,ActiveButtonCode

         cmp al,10 ; нажата клавиша "." ?
         jne PIend ; нет, тогда выходим из процедуры

; а может быть строку надо вводить заново ?
         cmp Str[12],0FFh
         jne PIm1
         call StrClear
         mov Str[12],0

    PIm1:cmp Str[11],0FFh ; а может быть точку уже вводили?
         je PIend ; да, и этот ввод точки игнорируется

         cmp Str[10],0 ; строка пустая?
         jne PIm2 ; нет и переход
         mov Str[0],0  ; да, тогда самый старший
         inc Str[10] ; байт должен стать нулевым

    PIm2:call RotateStringLeft ; сдвиг ранее введенных разрядов

; запись точки в младший разряд и установка
; флага наличия точки в строке
         mov Str[0],al
         mov Str[11],0FFh

   PIend:pop ax
         ret
PointInput EndP

SignChange Proc near
         cmp Error,0
         jne SCend

         cmp ActiveButtonCode,11 ; нажата клавиша "+/-" ?
         jne SCend ; нет, тогда выходим из процедуры

; смена знака
         cmp Str[9],12
         jne SCSP
         mov Str[9],11 ; знак "-"
         jmp SCend
    SCSP:mov Str[9],12 ; знак "+"

   SCend:ret
SignChange EndP

Calculate Proc near
         push ax

         cmp Error,0
         jne Calcend

         cmp ActiveButtonCode,12
         jne Calcend

         cmp Operation,0
         je Calcend

         lea di,Arg
         call ConvertStringToFloat
         lea si,Rez
         xchg di,si

         cmp Operation,1
         jne Calcm1

         call AddFunc
         jmp Calcm4

  Calcm1:cmp Operation,2
         jne Calcm2

         call SubFunc
         jmp Calcm4

  Calcm2:cmp Operation,3
         jne Calcm3

         call MulFunc
         jmp Calcm4

  Calcm3:cmp Operation,4
         jne Calcend

         cmp Str[10],0 ; строка ввода пуста и делим
         je CalcEr

         call DivFunc

  Calcm4:call OverflowChecking
         cmp al,0FFh
         jne Calcm5
  Calcer:mov Error,0Fh
         jmp Calcend

  Calcm5:lea si,Rez
         call ConvertFloatToString
         mov Str[12],0FFh

         mov Operation,0

 Calcend:pop ax
         ret
Calculate EndP

AddRezArg Proc near
         cmp Error,0
         jne ARAend

         cmp ActiveButtonCode,13
         jne ARAend

; сохранить строку ввода/вывода в переменной Rez и запомнить операцию +
         mov Operation,1
         lea di,Rez
         call ConvertStringToFloat
         mov Str[12],0FFh

  ARAend:ret
AddRezArg EndP

SubRezArg Proc near
         cmp Error,0
         jne SRAend

         cmp ActiveButtonCode,14
         jne SRAend

; сохранить строку ввода/вывода в переменной Rez и запомнить операцию -
         mov Operation,2
         lea di,Rez
         call ConvertStringToFloat
         mov Str[12],0FFh

  SRAend:ret
SubRezArg EndP

MulRezArg Proc near
         cmp Error,0
         jne MRAend

         cmp ActiveButtonCode,15
         jne MRAend

; сохранить строку ввода/вывода в переменной Rez и запомнить операцию *
         mov Operation,3
         lea di,Rez
         call ConvertStringToFloat
         mov Str[12],0FFh

  MRAend:ret
MulRezArg EndP

DivRezArg Proc near
         cmp Error,0
         jne DRAend

         cmp ActiveButtonCode,16
         jne DRAend

; сохранить строку ввода/вывода в переменной Rez и запомнить операцию /
         mov Operation,4
         lea di,Rez
         call ConvertStringToFloat
         mov Str[12],0FFh

  DRAend:ret
DivRezArg EndP

Clear Proc near
         push di

         cmp ActiveButtonCode,17 ; нажата клавиша "C" ?
         jne Cend ; нет, тогда выходим из процедуры

         lea di,Rez
         call FloatClear
         lea di,Arg
         call FloatClear

         mov Operation,0

         call StrClear

         cmp Error,0Fh
         jne Cend
         mov Error,0

    Cend:pop di
         ret
Clear EndP

CE Proc near
         cmp Error,0
         jne CEend

         cmp ActiveButtonCode,18 ; нажата клавиша "CE" ?
         jne CEend ; нет, тогда выходим из процедуры

         call StrClear  ; очистка строки ввода/вывода
   CEend:ret
CE EndP

Undo Proc near
         push cx

         cmp Error,0
         jne Uend

         cmp ActiveButtonCode,19 ; нажата клавиша "BKSP" ?
         jne Uend  ; нет, тогда выходим из процедуры

         cmp Str[10],0 ; строка пустая?
         je Uend ; да, и отменять нечего

         mov cx,1
         cmp Str[0],10 ; в младшем байте точка?
         jne Um1 ; нет, тогда 1 цикл удаления младшего байта
         mov cx,2
     Um1:call RotateStringRight
         loop Um1
         dec Str[10]

         cmp Str[10],0 ; а может на дисплее уже ничего не осталось?
         jne Uend
         call StrClear  ; очистка строки ввода/вывода

    Uend:pop cx
         ret
Undo EndP

MemoryClear Proc near
         push di

         cmp ActiveButtonCode,20 ; нажата клавиша "MC" ?
         jne MCend

         lea di,Mem
         call FloatClear

         cmp Error,0F0h
         jne MCend
         mov Error,0

   MCend:pop di
         ret
MemoryClear EndP

MemoryRead Proc near
         push si

         cmp Error,0
         jne MRend

         cmp ActiveButtonCode,21 ; нажата клавиша "MR" ?
         jne MRend

         lea si,Mem
         call ConvertFloatToString
         mov Str[12],0FFh

   MRend:pop si
         ret
MemoryRead EndP

MemorySet Proc near
         push di

         cmp Error,0
         jne MSend

         cmp ActiveButtonCode,22 ; нажата клавиша "X->M" ?
         jne MSend

         lea di,Mem
         call ConvertStringToFloat
         mov Str[12],0FFh

   MSend:pop di
         ret
MemorySet EndP

MemoryAdd Proc near
         push ax
         push si
         push di

         cmp Error,0
         jne MAend

         cmp ActiveButtonCode,23 ; нажата клавиша "M+" ?
         jne MAend

         lea di,Arg
         call ConvertStringToFloat
         lea si,Mem
         xchg di,si

         call AddFunc
         call OverflowChecking
         cmp al,0FFh
         jne MAend
         mov Error,0F0h

   MAend:pop di
         pop si
         pop ax
         ret
MemoryAdd EndP

StrOutput Proc near
         push ax
         push bx
         push dx
         push si

         cmp Error,0
         je SOm1
         call ErrMsgOut
         jmp SOend

    SOm1:cmp Str[10],0 ; строка пустая?
         jne SOst
         call DispClear ; да, и нужно очистить дисплей
         jmp SOend

; вывод строки
    SOst:xor dx,dx
         mov bx,offset OutputMap
         lea si,Str
         push si
   SOCyc:lodsb
         xlat
         cmp al,80h
         jne SOm2
         mov ah,al
         lodsb
         xlat
         or al,ah
    SOm2:out dx,al
         inc dx
         cmp dx,8
         jne SOCyc

; вывод знака
         pop si
         add si,9
         lodsb
         xlat
         out dx,al

   SOend:pop si
         pop dx
         pop bx
         pop ax
         ret
StrOutput EndP
