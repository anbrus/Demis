MulDDwithDW Proc near ; в регистре di смещение dd, а в cx - значение dw
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

CalculateMantissa Proc near  ; di задает ячейку куда положить мантиссу
         push ax
         push bx
         push cx

         xor ah,ah
         mov cx,10

         mov bl,Str[10]      ; число действительных цифр {смещение старшего
                             ; разряда} если есть точка
         cmp Str[11],0FFh    ; точка есть?
         je CMMcyc           ; да, и переход
         dec bl

; для всех цифр числа начиная со старшей
  CMMcyc:mov al,Str[bx]
         dec bl

         cmp al,10           ; точка?
         jne CMm1            ; нет
         cmp bl,-1           ; в конце строки?
         je CMMend
         jne CMMcyc

    CMm1:call MulDDwithDW

; сложение dd c обрабатываемой цифрой
         add [di],ax
         adc word ptr [di+2],0

         cmp bl,-1           ; занятые разряды кончились?
         jnz CMMcyc

  CMMend:nop

; обработка незанятых разрядов, если они есть
         mov al,8

         cmp byte ptr [di-1],0
         jg CMm2
         sub al,[di-1]
         inc al            ; 0-ая целая часть считалась разрядом

    CMm2:sub al,Str[10]
         jz CMend          ; нету

    CMm3:call MulDDwithDW
         dec al
         jnz CMm3

   CMend:pop cx
         pop bx
         pop ax
         ret
CalculateMantissa EndP

CalculateOrder Proc near     ; di задает ячейку куда положить порядок
         push ax
         push bx
         push cx

         xor bh,bh
         mov bl,Str[10]      ; число действительных цифр {смещение старшего
                             ; разряда} если есть точка
         cmp Str[11],0       ; точки нет?
         jne COm1            ; есть, и переход
         mov [di],bl         ; порядок равен число действ. цифр
         jmp COend

    COm1:xor cx,cx
         mov al,Str[bx]
         cmp al,0            ; целой части нет?
         jne COm2            ; есть, и переход

; расчет отрицательного порядка
         dec bl              ; пропуск точки
  COcyc1:dec bl
         dec cx
         mov al,Str[bx]

         cmp bl,-1 ; а может быть строка вообще
                   ; не имеет цифр больше 0
         je COend

         cmp al,0
         je COcyc1

         inc cl
         mov [di],cl
         jmp COend

; расчет положительного порядка
    COm2:dec bl
         inc cx
         mov al,Str[bx]
         cmp al,10
         jne COm2
         mov [di],cl

   COend:pop cx
         pop bx
         pop ax
         ret
CalculateOrder EndP

ConvertStringToFloat Proc near ; в регистре di смещение вещественного числа
         call FloatClear
         cmp Str[10],0       ; строка пустая?
         je CSFend

         call CalculateOrder ; определение порядка

; определение мантиссы
         inc di
         call CalculateMantissa
         dec di

; смена знака
         cmp Str[9],11       ; число отрицательное?
         jne CSFend          ; нет, и переход
         call FloatNeg       ; да, и обращение знака числа

  CSFend:ret
ConvertStringToFloat EndP

MantissaConvert Proc near ; в si откуда брать мантиссу
         push ax
         push cx
         push dx

; выдвижение DEC цифр числа по одной, начиная с младшей
         mov cx,10
  MCMcyc:mov ax,[si+2]
         xor dx,dx
         div cx
         mov [si+2],ax
         mov ax,[si]
         div cx
         mov [si],ax

         call RotateStringRight ; сдвиг разрядов строки
         mov Str[7],dl ; запись остатка

         cmp word ptr [si+2],0
         jne MCMcyc
         cmp word ptr [si],0
         jne MCMcyc

         mov Str[10],8

         pop dx
         pop cx
         pop ax
         ret
MantissaConvert EndP

OrderConvert Proc near ; в si откуда брать порядок
         push ax
         push bx
         push cx

         cmp byte ptr [si],1 ; оценка порядка
         jl OCm1 ; порядок меньше 1 {нет целой части}, и переход

; расстановка точки, если есть целая часть
         mov bx,7
         xor cx,cx
         add cx,[si]
 OCMcyc1:mov al,Str[bx] ; сдвиг старших
         mov Str[bx+1],al ; разрядов влево
         dec bx
         loop OCMcyc1
         mov Str[bx+1],10 ; запись на место младшего
                          ; из старших разрядов точки
         mov Str[11],0FFh ; установка флага наличия точки
         jmp OCend

; расстановка точки если нет целой части
    OCm1:mov cx,1
         sub cl,[si]
         mov Str[8],0
 OCMcyc2:call RotateStringRight
         mov Str[8],0
         loop OCMcyc2
         mov Str[7],10 ; запись точки
         mov Str[11],0FFh ; установка флага наличия точки

   OCend:pop cx
         pop bx
         pop ax
         ret
OrderConvert EndP

ConvertFloatToString Proc near ; в регистре si смещение числа
         push [si+3]
         push [si+1]
         push [si]
         push di

         call StrClear

         cmp word ptr [si+3],0
         jne CFSst
         cmp word ptr [si+1],0
         je CFSend

   CFSst:inc si ; переход к обработке мантиссы
         mov Str[9],12 ; считается, что число положительно
         cmp byte ptr [si+3],7Fh ; отрицательное число?
         jb CFSm1 ; нет, положительное

         mov Str[9],11       ; да, отрицательное,
         mov di,si           ; тогда учесть это, а
         dec di              ; число сделать
         call FloatNeg       ; положительным

   CFSm1:call MantissaConvert

         dec si
         call OrderConvert ; учет порядка

; удаление незначащих нулей в конце мантиссы
   CFSZD:cmp Str[0],0
         jne CFSPD
         call RotateStringRight
         dec Str[10]
         jmp CFSZD

; удаление точки в конце
   CFSPD:cmp Str[0],10
         jne CFSend
         call RotateStringRight
         mov Str[11],0 ; сброс флага наличия точки

  CFSend:pop di
         pop [si]
         pop [si+1]
         pop [si+3]
         ret
ConvertFloatToString EndP
