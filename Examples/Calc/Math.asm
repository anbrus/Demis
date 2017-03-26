; Модуль содержит основные и вспомо-
; гательные математические процедуры

; Деление двойного слова на слово; в регистре di -
; смещение dd, а в cx - значение dw; частное
; помещается на место делимого, остаток теряется
DivDDtoDW Proc near
         push ax
         push dx

         xor dx,dx               ; расширение старшего
         mov ax,[di+2]           ; слова dd и его
         div cx                  ; деление на dw
         mov [di+2],ax
         mov ax,[di]             ; деление младшего
         div cx                  ; слова dd и остака
                                 ; от деления старшего
                                 ; слова на dw
         mov [di],ax

         pop dx
         pop ax
         ret
DivDDtoDW EndP

; Денормализация мантиссы, параметры:
; в di смещение вещественного числа,
; а в cx - разность порядков
MDeNorm Proc near
         push ax

         xor al,al
         cmp byte ptr [di+4],7Fh ; работаю только с
         jb DeNst                ; положительными
         call FloatNeg           ; мантиссами
         mov al,0FFh

   DeNst:inc di                  ; переход к мантиссе
 MDeNcyc:push cx

         mov cx,10               ; цикл деления мантиссы
         call DivDDtoDW          ; на 10 и увеличения
         inc byte ptr [di-1]     ; порядка на 1

         pop cx
         loop MDeNcyc
         dec di

         cmp al,0FFh             ; если мантисса изна-
         jne DeNend              ; чально была отрица-
         call FloatNeg           ; тельна, то она и
                                 ; после денормализации
                                 ; должна быть отрица-
                                 ; тельна
  DeNend:pop ax
         ret
MDeNorm EndP

; Нормализация мантиссы, параметры:
; в di смещение вещественного числа
MantNorm Proc near
         push ax
         push cx

         xor ax,ax
         cmp byte ptr [di+4],7Fh ; работаю только с
         jb MantNst              ; положительными
         call FloatNeg           ; мантиссами
         mov al,0FFh

 MantNst:inc di                  ; переход к мантиссе
         push [di+2]             ; ее сохранение
         push [di]

         mov cx,10
   MNcyc:call DivDDtoDW          ; подсчет числа
         inc ah                  ; десятичных цифр
         cmp word ptr [di+2],0   ; в мантиссе путем
         jne MNcyc               ; деления ее на 10
         cmp word ptr [di],0     ; до тех пор, пока
         jne MNcyc               ; она не обнулится

         pop [di]                ; восстановление
         pop [di+2]              ; мантиссы

         cmp ah,8                ; нормализованная
         je MantNm3              ; мантисса содержит
         jb MantNm2              ; 8 DEC цифр

 MantNm1:call DivDDtoDW          ; если мантисса содер-
         inc byte ptr [di-1]     ; жит больше DEC цифр,
         dec ah                  ; то ее надо делить на
         cmp ah,8                ; 10 и инкрементировать
         jne MantNm1             ; порядок
         jmp MantNm3

 MantNm2:call MulDDwithDW        ; если же мантисса со-
         dec byte ptr [di-1]     ; держит меньше DEC
         inc ah                  ; цифр чем 8, то ее
         cmp ah,8                ; надо множить на 10 и
         jne MantNm2             ; декрементить порядок

 MantNm3:dec di
         cmp al,0FFh             ; если мантисса изна-
         jne MNend               ; чально была отрица-
         call FloatNeg           ; тельна, то она и
                                 ; после нормализации
                                 ; должна быть отрица-
                                 ; тельной
   MNend:pop cx
         pop ax
         ret
MantNorm EndP

; Проверка переполнения и антипереполения
; вещественного числа; параметры:
; в di смещение вещественного числа,
; в регистре al возвращается флаг переполнения:
; al = 0 - все нормально, al = FFh - переполнение
OverflowChecking Proc near
         cmp byte ptr [di],9     ; проверка
         jl OvChm1               ; переполнения
         mov al,0FFh
         jmp OvChend

  OvChm1:cmp byte ptr [di],-7    ; проверка
         jg OvChend              ; антипереполнения
         call FloatClear         ; возврат машинного
                                 ; нуля
 OvChend:ret
OverflowChecking EndP

; Сложение двух вещественных чисел; параметры:
; в di - смещение 1-ого слагаемого и суммы,
; а в si - смещение 2-ого аргумента
AddFunc Proc near
         push ax
         push cx
         push dx
         push di
         push si

         mov al,[di]             ; сравнение
         cmp al,[si]             ; порядков
         je Ast
         jl ADcyc
         xchg di,si

   ADcyc:xor ch,ch               ; выравнивание
         mov cl,[si]             ; порядков
         sub cl,[di]
         call MDeNorm

     Ast:pop si
         pop di

         mov ax,[di+1]            ; пословное
         mov dx,[di+3]            ; сложение
         add ax,[si+1]            ; мантисс
         adc dx,[si+3]
         mov [di+1],ax
         mov [di+3],dx

         call MantNorm           ; нормализация
                                 ; мантиссы
         pop dx
         pop cx
         pop ax
         ret
AddFunc EndP

; Вычитание двух вещественных чисел; параметры:
; в di - смещение уменьшаемого и разности,
; а в si - смещение вычитаемого
SubFunc Proc near
         push ax
         push cx
         push dx
         push di
         push si

         mov al,[di]             ; сравнение
         cmp al,[si]             ; порядков
         je Sst
         jl SDcyc
         xchg di,si

   SDcyc:xor ch,ch               ; выравнивание
         mov cl,[si]             ; порядков
         sub cl,[di]
         call MDeNorm

     Sst:pop si
         pop di

         mov ax,[di+1]            ; пословное
         mov dx,[di+3]            ; вычитание
         sub ax,[si+1]            ; мантисс
         sbb dx,[si+3]
         mov [di+1],ax
         mov [di+3],dx

         call MantNorm           ; нормализация
                                 ; мантиссы
         pop dx
         pop cx
         pop ax
         ret
SubFunc EndP

; Деление квадрослова на слово; параметры:
; в регистре - di смещение dq, а в cx - значение dw
DivDQToDW Proc near
         push ax
         push bx
         push dx

         xor dx,dx
         mov bx,8

    Dcyc:dec bx                  ; все делается
         dec bx                  ; аналогично
                                 ; процедуре
         mov ax,[di+bx]          ; DivDDToDw
         div cx
         mov [di+bx],ax

         cmp bx,0
         jne Dcyc

         pop dx
         pop bx
         pop ax
         ret
DivDQToDW EndP

; Умножение двойного слова на двойного слово;
; параметры: в di - смещение аргумента1,
; в si - аргумента2; результат в переменной MulRez
MulDDWithDD Proc near
         push ax
         push dx

         mov word ptr [MulRez],0
         mov word ptr [MulRez+2],0
         mov word ptr [MulRez+4],0
         mov word ptr [MulRez+6],0

         mov ax,[di]             ; умножение
         mul word ptr [si]       ; младших слов
         mov MulRez,ax
         mov MulRez+2,dx

         mov ax,[di]             ; умножение
         mul word ptr [si+2]     ; средних
         add MulRez+2,ax         ; слов
         adc MulRez+4,dx

         mov ax,[di+2]
         mul word ptr [si]
         add MulRez+2,ax
         adc MulRez+4,dx

         mov ax,[di+2]           ; умножение
         mul word ptr [si+2]     ; старших слов
         add MulRez+4,ax
         adc MulRez+6,dx

         pop dx
         pop ax
         ret
MulDDWithDD EndP

; Умножение двух вещественных чисел; параметры:
; в di - смещение 1-ого множителя и произведения,
; а в si - смещение 2-ого множителя
MulFunc Proc near
         push ax
         push bx
         push cx

         xor bx,bx

         cmp byte ptr [di+4],7Fh ; работаю
         jb MFm1                 ; только с
         call FloatNeg           ; положительными
         mov bl,1                ; мантиссами

    MFm1:cmp byte ptr [si+4],7Fh
         jb MFst
         xchg si,di
         call FloatNeg
         xchg si,di
         mov bh,1

    MFst:mov al,[di]             ; сложение
         add al,[si]             ; порядков
         mov [di],al

         inc si                  ; переход к
         inc di                  ; мантиссам

         call MulDDWithDD        ; собственно умножение

         push di                 ; коррекция произведе-
         mov cx,10000            ; ния мантисс путем
         lea di,MulRez           ; деления ее на 10Е7,
         call DivDQToDW          ; а т.к. делить надо
         mov cx,1000             ; было на 10Е8, то
         call DivDQToDW          ; декремент порядка
         pop di                  ; полученного вешест-
         dec byte ptr [di-1]     ; венного числа

         mov ax,MulRez           ; пословное
         mov [di],ax             ; запоминание
         mov ax,MulRez+2         ; результата
         mov [di+2],ax

         dec si
         dec di

         call MantNorm           ; нормализация мантиссы

         add bl,bh               ; определение знака
         cmp bl,1                ; произведения
         jne MFend               ; вещественных
         call FloatNeg           ; чисел

   MFend:pop cx
         pop bx
         pop ax
         ret
MulFunc EndP

; Деление двух вещественных чисел; параметры:
; в di - смещение делимого и частного,
; а в si - смещение делителя
DivFunc Proc near
         push ax
         push bx
         push cx

         xor bx,bx

         cmp byte ptr [di+4],7Fh ; работаю
         jb DFnextS              ; только с
         call FloatNeg           ; положительными
         mov bl,1                ; мантиссами

 DFnextS:cmp byte ptr [si+4],7Fh
         jb DFst
         xchg si,di
         call FloatNeg
         xchg si,di
         mov bh,1

    DFst:mov al,[di]             ; вычитание
         sub al,[si]             ; порядков
         mov [di],al

         inc si                  ; переход к
         inc di                  ; мантиссам

         push [si]
         push [si+2]
         push ax
         mov ax, 05F5h
         mov [si+2],ax           ; коррекция мантиссы
         mov ax, 0E100h
         mov [si],ax             ; делимого путем
         pop ax
         call MulDDWithDD        ; умножения ее на 10Е8
         pop [si+2]
         pop [si]

         mov cx,32               ; деление мантисс по
                                 ; алгоритму с восста-
                                 ; новление остатка
                                 
  DFDcyc:shl word ptr MulRez,1   ; сдвиг влево частного
         rcl word ptr MulRez+2,1 ; и остатка
         rcl word ptr MulRez+4,1
         rcl word ptr MulRez+6,1
         pushf                   ; сохранение переноса

         mov ax,MulRez+4         ; вычитание из 
         sub ax,[si]             ; остатка делителя
         mov MulRez+4,ax
         mov ax,MulRez+6
         sbb ax,[si+2]
         mov MulRez+6,ax

         jc DFm2                 ; если разность < 0
         popf

    DFm1:add word ptr MulRez,1   ; разряд
         adc word ptr MulRez+2,0 ; частного = 1
         jmp Dloop

    DFm2:popf
         jc DFm1                 ; проверка переноса от
                                 ; сдвига остатка

         mov ax,MulRez+4         ; восстановление
         add ax,[si]             ; остатка
         mov MulRez+4,ax
         mov ax,MulRez+6
         adc ax,[si+2]
         mov MulRez+6,ax

   Dloop:loop DFDcyc

         mov ax,MulRez           ; пословное
         mov [di],ax             ; запоминание
         mov ax,MulRez+2         ; результата
         mov [di+2],ax

         dec si
         dec di

         call MantNorm           ; нормализация мантиссы

         add bl,bh               ; определение знака
         cmp bl,1                ; частного двух
         jne DFend               ; вещественных
         call FloatNeg           ; чисел

   DFend:pop cx
         pop bx
         pop ax
         ret
DivFunc EndP