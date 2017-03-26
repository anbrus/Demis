; Модуль содержит процедуры преобразования
; строки ввода/вывода данных на дисплей в
; вещественное число в соответствии с выбранным
; форматом строки ввода/вывода и вещественных
; чисел и процедуры преобразования вещественных
; чисел в строку ввода/вывода

; Умножение двойного слова на слово; параметры:
; в регистре di - смещение dd, а в cx - значение dw
MulDDwithDW Proc near
         push ax
         push dx

         mov ax,[di+2]
         mul cx
         mov [di+2],ax
         mov ax,[di]
         mul cx
         mov [di],ax
         add [di+2],dx

         pop dx
         pop ax
         ret
MulDDwithDW EndP

; Вычисление мантиссы вещественного числа;
; регистр di задает ячейку памяти, в
; которую нужно положить мантиссу
CalculateMantissa Proc near
         push ax
         push bx
         push cx

         xor ah,ah
         mov cx,10

         mov bl,StrDisplay[10]          ; смещение старшего из
                                 ; введенных разрядов =
                                 ; числу введенных цифр
         cmp StrDisplay[11],0FFh        ; если есть точка, и
         je CMcyc                ; число цифр - 1, если
         dec bl                  ; точки нет

   CMcyc:mov al,StrDisplay[bx]          ; для всех введенных
         dec bl                  ; цифр, начиная со
                                 ; старшей

         cmp al,10               ; точка?
         jne CMm1                ; нет

         cmp bl,-1               ; пропуск точки
         je CMend                ; в конце строки

         jne CMcyc               ; пропуск точки
                                 ; в середине строки

    CMm1:call MulDDwithDW        ; накопление
         add [di],ax             ; мантиссы
         adc word ptr [di+2],0

         cmp bl,-1               ; зацикливание, если
         jnz CMcyc               ; обработаны не все
                                 ; заполненные разряды
   CMend:pop cx
         pop bx
         pop ax
         ret
CalculateMantissa EndP

; Расчет порядка вещественного числа;
; регистр di задает ячейку памяти, в
; которую нужно положить порядок
CalculateOrder Proc near
         push ax
         push bx
         push cx

         xor bh,bh
         mov bl,StrDisplay[10]          ; смещение старшего из
                                 ; введенных разрядов =
                                 ; числу введенных цифр,
                                 ; если есть точка

         cmp StrDisplay[11],0           ; точка есть?
         jne COm1                ; есть, и переход
         mov [di],bl             ; если же точки нет, то
         jmp COend               ; порядок = число цифр

    COm1:xor cx,cx
         mov al,StrDisplay[bx]
         cmp al,0                ; целой части нет?
         jne COm2                ; есть, и переход

         dec bl                  ; пропуск точки

  COcyc1:dec bl                  ; расчет отрицатель-
         dec cx                  ; ного порядка
         mov al,StrDisplay[bx]

         cmp bl,-1               ; если строка вообще
                                 ; не имеет цифр
         je COend                ; больших 0, то выход

         cmp al,0
         je COcyc1

         inc cl
         mov [di],cl
         jmp COend

    COm2:dec bl                  ; расчет
         inc cx                  ; положительного
         mov al,StrDisplay[bx]          ; порядка
         cmp al,10
         jne COm2
         mov [di],cl

   COend:pop cx
         pop bx
         pop ax
         ret
CalculateOrder EndP

; Преобразование строки ввода/вывода
; в вещественное число; параметры:
; в регистре di - смещение числа
ConvertStringToFloat Proc near
         call FloatClear
         cmp StrDisplay[10],0           ; если строка пуста,
         je CSFend               ; то вещественное
                                 ; число - нулевое

         inc di                  ; вычисление
         call CalculateMantissa  ; мантиссы
         dec di

         call MantNorm           ; ее нормализация

         call CalculateOrder     ; расчет порядка

         cmp StrDisplay[9],11           ; если в строке есть
         jne CSFend              ; знак "-", то
         call FloatNeg           ; обращение знака числа

  CSFend:ret
ConvertStringToFloat EndP

; Преобразование мантиссы; параметры:
; регистр si задает ячейку, из которой
; надо брать мантиссу
MantissaConvert Proc near
         push ax
         push cx
         push dx

         mov cx,10
  MCMcyc:mov ax,[si+2]           ; выдвижение DEC цифр
         xor dx,dx               ; мантиссы по одной,
         div cx                  ; начиная с младшей,
         mov [si+2],ax           ; путем деления ее
         mov ax,[si]             ; на 10
         div cx
         mov [si],ax

         call RotateStringRight  ; сдвиг разрядов строки
         mov StrDisplay[7],dl           ; накопление строки
         inc StrDisplay[10]

         cmp word ptr [si+2],0   ; цикл деления длится
         jne MCMcyc              ; до тех пор, пока
         cmp word ptr [si],0     ; мантисса не кончится
         jne MCMcyc              ; {не обнулится}

         pop dx
         pop cx
         pop ax
         ret
MantissaConvert EndP

; Преобразование порядка {расстановка точки};
; параметры: регистр si задает ячейку, из которой
; следует взять порядок
OrderConvert Proc near
         push ax
         push bx
         push cx

         mov StrDisplay[11],0FFh        ; установка флага
                                 ; наличия точки

         cmp byte ptr [si],1     ; оценка порядка
         jl OCm1                 ; если порядок < 1
                                 ; {нет целой части}

         mov bx,7                ; расстановка точки,
         xor cx,cx               ; если есть целая часть
         add cx,[si]
 OCMcyc1:mov al,StrDisplay[bx]          ; цикл сдвига старших
         mov StrDisplay[bx+1],al        ; разрядов влево
         dec bx
         loop OCMcyc1
         mov StrDisplay[bx+1],10        ; запись на место
                                 ; младшего из старших
                                 ; разрядов точки
         jmp OCend

    OCm1:mov cx,1                ; расстановка точки
         sub cl,[si]             ; если нет целой части
         mov StrDisplay[8],0
 OCMcyc2:call RotateStringRight
         mov StrDisplay[8],0
         loop OCMcyc2
         mov StrDisplay[7],10           ; запись точки

   OCend:pop cx
         pop bx
         pop ax
         ret
OrderConvert EndP

; Преобразование вещественного числа
; в строку ввода/вывода; параметры:
; в регистре si - смещение числа
ConvertFloatToString Proc near
         push [si+3]             ; сохранение
         push [si+1]             ; мантиссы
         push [si]               ; и порядка
         push di

         call StrClear           ; очистка строки вывода

         cmp word ptr [si+3],0   ; если мантисса преоб-
         jne CFSst               ; разуемого числа = 0,
         cmp word ptr [si+1],0   ; то и строка пуста
         je CFSend

   CFSst:inc si                  ; переход к обработке
                                 ; мантиссы, при этом
         mov StrDisplay[9],12           ; считается, что
                                 ; она положительна

         cmp byte ptr [si+3],7Fh
         jb CFSm1
         mov StrDisplay[9],11           ; если же она все-таки
         mov di,si               ; отрицательная, то это
         dec di                  ; надо учесть, а ее
         call FloatNeg           ; сделать положительной

   CFSm1:call MantissaConvert    ; преобразование
         dec si                  ; мантиссы
         call OrderConvert       ; и порядка

   CFSZD:cmp StrDisplay[0],0            ; удаление незначащих
         jne CFSPD               ; нулей в конце мантиссы
         call RotateStringRight  ; мантиссы
         dec StrDisplay[10]
         jmp CFSZD

   CFSPD:cmp StrDisplay[0],10           ; если в конце строки
         jne CFSend              ; точка, то ее удаление
         call RotateStringRight  ; и сброс флага
         mov StrDisplay[11],0           ; наличия точки

  CFSend:pop di
         pop [si]
         pop [si+1]
         pop [si+3]
         ret
ConvertFloatToString EndP