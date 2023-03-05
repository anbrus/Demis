; Денормализация мантиссы, параметры:
; в di - смещение вещественного числа,
; в cx - разность порядков
DenormMant PROC  NEAR
           PUSH  AX
           INC   DI                  ; переход к мантиссе

DN_cyc:    PUSH  CX
           MOV   CX,10               ; цикл деления мантиссы
           CALL  Div_DD_DW          ; на 10 и увеличения
           INC   BYTE PTR [DI-1]     ; порядка на 1
           POP   CX
           LOOP  DN_cyc

           DEC   DI
           POP   ax
           RET
DenormMant ENDP

; Нормализация мантиссы, параметры:
; в di - смещение вещественного числа
NormMant   PROC  NEAR
           PUSH  AX CX
           
           XOR   AX,AX
           INC   DI                  ; переход к мантиссе
           PUSH  [DI+2]              ; ее сохранение
           PUSH  [DI]

           MOV   CX,10
NM_cyc:    CALL  Div_DD_DW           ; подсчет числа
           INC   AH                  ; десятичных цифр
           CMP   WORD PTR [DI+2],0   ; в мантиссе путем
           JNE   NM_cyc              ; деления ее на 10
           CMP   WORD PTR [DI],0     ; до тех пор, пока
           JNE   NM_cyc              ; она не обнулится

           POP   [DI]                ; восстановление
           POP   [DI+2]              ; мантиссы

           CMP   AH,8                ; нормализованная
           JE    NM_3                ; мантисса содержит
           JB    NM_2                ; 8 DEC цифр

NM_4:      CALL  Div_DD_DW           ; если мантисса содер-
           INC   BYTE PTR [DI-1]     ; жит больше DEC цифр,
           DEC   AH                  ; то ее надо делить на
           CMP   AH,8                ; 10 и инкрементировать
           JNE   NM_4                ; порядок
           JMP   NM_3

NM_2:      CALL  Mul_DD_DW           ; если же мантисса со-
           DEC   BYTE PTR [DI-1]     ; держит меньше DEC
           INC   AH                  ; цифр чем 8, то ее
           CMP   AH,8                ; надо множить на 10 и
           JNE   NM_2                ; декрементить порядок

NM_3:      DEC   DI
NM_end:    POP   CX AX
           RET
NormMant   ENDP

; Проверка переполнения и антипереполения вещественного числа, параметры:
; в di - смещение вещественного числа,
; в al - флаг переполнения (0 - все нормально, FFh - переполнение)
Overflow   PROC NEAR
           CMP BYTE PTR [DI],9     ; проверка переполнения
           JL    O_1
           MOV   AL,0FFh
           JMP   O_end

O_1:       CMP BYTE PTR [DI],-7    ; проверка антипереполнения
           JG    O_end
           CALL  FloatClear
O_end:     RET
Overflow   ENDP

; Сложение двух вещественных чисел, параметры:
; в di - смещение 1-ого слагаемого и суммы,
; в si - смещение 2-ого аргумента
AddFunc    PROC  NEAR
           PUSH  AX CX DX DI SI

           MOV   AL,[DI]             ; сравнение
           CMP   AL,[SI]             ; порядков
           JE    A_1
           JL    A_cyc
           XCHG  DI,SI

A_cyc:     XOR   CH,CH               ; выравнивание
           MOV   CL,[SI]             ; порядков
           SUB   CL,[DI]
           CALL  DenormMant

A_1:       POP   SI DI

           MOV   AX,DI[1]            ; пословное
           MOV   DX,DI[3]            ; сложение
           ADD   AX,SI[1]            ; мантисс
           ADC   DX,SI[3]
           MOV   DI[1],AX
           MOV   DI[3],DX

           CALL  NormMant
           POP   DX CX AX
           RET
AddFunc    ENDP

; Умножение двойного слова на двойного слово; параметры: 
; в di - смещение аргумента1, 
; в si - смещение аргумента2, 
; в переменной MulRez - результат
Mul_DD_DD  PROC  NEAR
           PUSH  AX DX

           MOV   WORD PTR [MulRez],0
           MOV   WORD PTR [MulRez+2],0
           MOV   WORD PTR [MulRez+4],0
           MOV   WORD PTR [MulRez+6],0

           MOV   AX,[DI]
           MUL   WORD PTR [SI]
           MOV   MulRez,AX
           MOV   MulRez+2,DX

           MOV   AX,[DI]
           MUL   WORD PTR [SI+2]
           ADD   MulRez+2,AX
           ADC   MulRez+4,DX

           MOV   AX,[DI+2]
           MUL   WORD PTR [si]
           ADD   MulRez+2,AX
           ADC   MulRez+4,DX

           MOV   AX,[DI+2]
           MUL   WORD PTR [si+2]
           ADD   MulRez+4,AX
           ADC   MulRez+6,DX

           POP   DX AX
           RET
Mul_DD_DD  ENDP

; Умножение двойного слова на слово; параметры:
; в di - смещение dd, 
; в cx - значение dw
Mul_DD_DW  PROC  NEAR
           PUSH  AX DX

           MOV   AX,[DI+2]
           MUL   CX
           MOV   [DI+2],AX
           MOV   AX,[DI]
           MUL   CX
           MOV   [DI],AX
           ADD   [DI+2],DX

           POP   DX AX
           RET
Mul_DD_DW  EndP

; Деление квадрослова на слово; параметры:
; в di - смещение dq, 
; в cx - значение dw
Div_DQ_DW  PROC  NEAR
           PUSH  AX BX DX

           XOR   DX,DX
           MOV   BX,8

D_cyc:     DEC   BX
           DEC   BX

           MOV   AX,[DI+BX]
           DIV   CX
           MOV   [DI+BX],AX

           CMP   BX,0
           JNE   D_cyc

           POP   DX BX AX
           RET
Div_DQ_DW  ENDP

; Деление двойного слова на слово; параметры:
; в di - смещение dd, 
; в cx - значение dw, 
; частное помещается на место делимого, остаток теряется
Div_DD_DW  PROC  NEAR
           PUSH  AX DX

           XOR   DX,DX               ; расширение старшего
           MOV   AX,[DI+2]           ; слова dd и его
           DIV   CX                  ; деление на dw
           MOV   [DI+2],AX
           MOV   AX,[DI]             ; деление младшего слова dd и остака
           DIV   CX                  ; от деления старшего слова на dw

           MOV   [DI],AX
           POP   DX AX
           RET
Div_DD_DW  ENDP

; Умножение двух вещественных чисел; параметры:
; в di - смещение 1-ого множителя и произведения,
; в si - смещение 2-ого множителя
MulFunc    PROC  NEAR
           PUSH  AX BX CX

           MOV   AL,[DI]             ; сложение
           ADD   AL,[SI]             ; порядков
           MOV   [DI],AL

           INC   SI                  ; переход к
           INC   DI                  ; мантиссам
           CALL  Mul_DD_DD

           PUSH  DI                  ; коррекция произведе-
           MOV   CX,10000            ; ния мантисс путем
           LEA   DI,MulRez           ; деления ее на 10Е7,
           CALL  Div_DQ_DW           ; а т.к. делить надо
           MOV   CX,1000             ; было на 10Е8, то
           CALL  Div_DQ_DW           ; декремент порядка
           POP   DI                  ; полученного вешест-
           DEC   BYTE PTR [DI-1]     ; венного числа

           MOV   AX,MulRez           ; пословное
           MOV   [DI],AX             ; запоминание
           MOV   AX,MulRez+2         ; результата
           MOV   [DI+2],AX

           DEC   SI
           DEC   DI
           CALL  NormMant            ; нормализация мантиссы

MF_end:    POP   CX BX AX
           RET
MulFunc    ENDP