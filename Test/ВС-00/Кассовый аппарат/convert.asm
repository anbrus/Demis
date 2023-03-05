; Модуль содержит процедуры преобразования
; строки ввода/вывода данных на дисплей в
; вещественное число в соответствии с выбранным
; форматом строки ввода/вывода и вещественных
; чисел и процедуры преобразования вещественных
; чисел в строку ввода/вывода

; Вычисление мантиссы вещественного числа;
; регистр di задает ячейку памяти, в
; которую нужно положить мантиссу
CalcMant   PROC NEAR
         push ax bx cx

         xor ah,ah
         mov cx,10

         mov bl,Str[10]          ; смещение старшего из
                                 ; введенных разрядов =
                                 ; числу введенных цифр
         cmp Str[11],0FFh        ; если есть точка, и
         je CMcyc                ; число цифр - 1, если
         dec bl                  ; точки нет

   CMcyc:mov al,Str[bx]          ; для всех введенных
         dec bl                  ; цифр, начиная со
                                 ; старшей

         cmp al,10               ; точка?
         jne CMm1                ; нет

         cmp bl,-1               ; пропуск точки
         je CMend                ; в конце строки

         jne CMcyc               ; пропуск точки
                                 ; в середине строки

    CMm1:call Mul_DD_DW        ; накопление
         add [di],ax             ; мантиссы
         adc word ptr [di+2],0

         cmp bl,-1               ; зацикливание, если
         jnz CMcyc               ; обработаны не все
                                 ; заполненные разряды
   CMend:pop cx bx ax
           RET
CalcMant   ENDP

; Расчет порядка вещественного числа;
; регистр di задает ячейку памяти, в
; которую нужно положить порядок
CalcOrder  PROC  NEAR
           PUSH  AX BX CX

           XOR   BH,BH
           MOV   BL,Str[10]          ; смещение старшего из введенных разрядов =
                                     ; числу введенных цифр, если есть точка

           CMP   Str[11],0           ; точка есть?
           JNE   CO_1                ; есть, и переход
           MOV   [DI],BL             ; если же точки нет, то
           JMP   CO_end               ; порядок = число цифр

CO_1:      XOR   CX,CX
           MOV   AL,Str[BX]
           CMP   AL,0                ; целой части нет?
           JNE   CO_2                ; есть, и переход

           DEC   BL                  ; пропуск точки

CO_cyc:    DEC   BL                  ; расчет отрицатель-
           DEC   CX                  ; ного порядка
           MOV   AL,Str[BX]

           CMP   BL,-1                ; если строка вообще не имеет цифр
           JE    CO_end               ; больших 0, то выход

           CMP   AL,0
           JE    CO_cyc

           INC   CL
           MOV   [DI],CL
           JMP   CO_end

CO_2:      DEC   BL                  ; расчет
           INC   CX                  ; положительного
           MOV   AL,Str[BX]          ; порядка
           CMP   AL,10
           JNE   CO_2
           MOV   [DI],CL

CO_end:    POP   CX BX AX
           RET
CalcOrder  ENDP

; Преобразование мантиссы; параметры:
; регистр si задает ячейку, из которой
; надо брать мантиссу
ConvMant   PROC  NEAR
           PUSH  AX CX DX

           MOV   CX,10
CM_cyc:    MOV   AX,[SI+2]           ; выдвижение DEC цифр
           XOR   DX,DX               ; мантиссы по одной,
           DIV   CX                  ; начиная с младшей,
           MOV   [SI+2],AX           ; путем деления ее
           MOV   AX,[SI]             ; на 10
           DIV   CX
           MOV   [SI],AX

           CALL  RotateRight         ; сдвиг разрядов строки
           MOV   Str[7],DL           ; накопление строки
           INC   Str[10]

           CMP   WORD PTR [SI+2],0   ; цикл деления длится
           JNE   CM_cyc              ; до тех пор, пока
           CMP   WORD PTR [SI],0     ; мантисса не кончится
           JNE   CM_cyc              ; {не обнулится}

           POP DX CX AX
           RET
ConvMant   ENDP

; Преобразование порядка {расстановка точки};
; параметры: регистр si задает ячейку, из которой
; следует взять порядок
ConvOrder  PROC  NEAR
           push  AX BX CX

           MOV   Str[11],0FFh        ; установка флага наличия точки

           CMP   BYTE PTR [SI],1     ; оценка порядка
           JL    COr_1               ; если порядок < 1 {нет целой части}

           MOV   BX,7                ; расстановка точки,
           XOR   CX,CX               ; если есть целая часть
           ADD   CX,[SI]
COr_cyc1:  MOV   AL,Str[BX]          ; цикл сдвига старших
           MOV   Str[BX+1],AL        ; разрядов влево
           DEC   BX
           LOOP  COr_cyc1
           MOV   Str[BX+1],10        ; запись на место младшего из старших
                                     ; разрядов точки
           JMP   COr_end

COr_1:     MOV   CX,1                ; расстановка точки
           SUB   CL,[SI]             ; если нет целой части
           MOV   Str[8],0
COr_cyc2:  CALL  RotateRight
           MOV   Str[8],0
           LOOP  COr_cyc2
           MOV   Str[7],10           ; запись точки

COr_end:   POP   CX BX AX
           RET
ConvOrder  ENDP

; Преобразование строки ввода/вывода в вещественное число;
; параметры: в регистре di - смещение числа
StrToFloat PROC  NEAR
           CALL  FloatClear
           CMP   Str[10],0               ; если строка пуста,
           JE    STF_end                 ; то вещественное число - нулевое

           INC   DI                      ; вычисление
           CALL  CalcMant                ; мантиссы
           DEC   DI

           CALL  NormMant                ; ее нормализация
           CALL  CalcOrder               ; расчет порядка
STF_end:   RET
StrToFloat ENDP

; Преобразование вещественного числа
; в строку ввода/вывода; параметры:
; в регистре si - смещение числа
FloatToStr PROC  NEAR
           PUSH  [SI+3]                 ; сохранение
           PUSH  [SI+1]                 ; мантиссы
           PUSH  [SI]                   ; и порядка
           PUSH  DI
           
           CALL  DispZero               ; очистка строки вывода

           CMP   WORD PTR [SI+3],0      ; если мантисса преоб-
           JNE   FTS_1                  ; разуемого числа = 0,
           CMP   WORD PTR [SI+1],0      ; то и строка пуста
           JE    FTS_end

FTS_1:     INC   SI                     ; переход к обработке мантиссы, при этом
           MOV   Str[9],12              ; считается, что она положительна

           CALL  ConvMant              ; преобразование
           DEC   SI                    ; мантиссы
           CALL  ConvOrder             ; и порядка

FTS_4:     CMP   Str[0],0              ; удаление незначащих
           JNE   FTS_3                 ; нулей в конце мантиссы
           CALL  RotateRight           ; мантиссы
           DEC   Str[10]
           JMP   FTS_4

FTS_3:     CMP   Str[0],10             ; если в конце строки
           JNE   FTS_end               ; точка, то ее удаление
           CALL  RotateRight           ; и сброс флага
           MOV   Str[11],0             ; наличия точки

FTS_end:   POP   DI
           POP   [SI]
           POP   [SI+1]
           POP   [SI+3]
           RET
FloatToStr ENDP

; Сдвиг строки ввода/вывода на 1 разряд влево
RotateLeft PROC NEAR
           PUSH AX BX
           MOV BX,8
RSLcyc:    MOV AH,Str[BX-1]
           MOV Str[BX],AH
           DEC BX
           JNZ RSLcyc
           MOV Str[0],12
           POP BX AX
           RET
RotateLeft ENDP

; Сдвиг строки ввода/вывода на 1 разряд вправо
RotateRight PROC NEAR
           PUSH  AX BX

           XOR   BX,BX
RR_cyc:    MOV   AH,Str[BX+1]
           MOV   Str[BX],AH
           INC   BX
           CMP   BX,8
           JNE   RR_cyc
           MOV   Str[8],12
           POP   BX AX
           RET
RotateRight ENDP

; Обнуление вещественного числа;
; параметры: в di - смещение числа
FloatClear PROC  NEAR
           PUSH  BX

           XOR   BX,BX
FC_cyc:    MOV   BYTE PTR [DI+BX],0
           INC   BX                  ; все
           CMP   BX,5                ; 5 байт
           JNE   FC_cyc

           POP   BX
           RET
FloatClear ENDP

; Перевод целого числа во время
IntToTime  PROC  NEAR
           PUSH  AX BX CX DX SI
           LEA   SI,TimeCount
           
           MOV   AX,WORD PTR [SI]
           MOV   DX,WORD PTR [SI+2]
           MOV   BX,60000
           DIV   BX                              ; сколько всего минут прошло
           MOV   DL,60
           DIV   DL                              ; сколько целых часов
           MOV   DH,AH
           
           AAM
           
           MOV   DL,AH
           XOR   AH,AH
           
           MOV   CL,4
           MUL   CL
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+4],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+6],AX

           MOV   AL,Dl
           XOR   AH,AH
           
           MOV   CL,4
           MUL   CL
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+2],AX
           
           MOV   AX,0FFB7h
           MOV   WORD PTR [DI+8],AX
           
           MOV   AL,DH
           AAM

           MOV   DL,AH
           XOR   AH,AH
           
           MOV   CL,4
           MUL   CL
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+14],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+16],AX

           MOV   AL,Dl
           XOR   AH,AH
           
           MOV   CL,4
           MUL   CL
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+10],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+12],AX

           POP   SI DX CX BX AX
           RET
IntToTime  ENDP

; Перевод времени в целое число
TimeToInt  PROC  NEAR
           LEA   SI,Str
           LEA   DI,TimeCount
           
           XOR   AX,AX
           MOV   AL,[SI+4]
           MOV   AH,10
           MUL   AH
           ADD   AL,[SI+3]
           MOV   AH,60
           MUL   AH                              ; число минут в целых часах
           
           MOV   DX,AX
           XOR   AX,AX
           MOV   AL,[SI+1]
           MOV   AH,10
           MUL   AH
           ADD   AL,[SI]                         ; число целых минут
           ADD   AX,DX                           ; общее число минут
           MOV   DX,60000
           MUL   DX                              ; общее чтсло милисекунд
           
           MOV   WORD PTR [DI],AX
           MOV   WORD PTR [DI+2],DX
           RET
TimeToInt  ENDP

; Преобразование образа даты в число
DateToInt  PROC  NEAR
           LEA   SI,Str
           LEA   DI,DateCount
           MOV   CX,8
DTI_cyc:   MOV   AL,[SI]
           MOV   [DI],AL
           INC   SI
           INC   DI
           LOOP  DTI_cyc
           RET
DateToInt  ENDP           

; Получение образа даты
IntToDate  PROC NEAR
           LEA   SI,DateCount
           ;LEA   DI,CheckImg+168

           MOV   AL,[SI+7]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+2],AX
           
           MOV   AL,[SI+6]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+4],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+6],AX
           
           MOV   AX,07FFFh
           MOV   WORD PTR [DI+7],AX
           
           MOV   AL,[SI+4]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+10],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+12],AX
           
           MOV   AL,[SI+3]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+14],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+16],AX

           MOV   AX,07FFFh
           MOV   WORD PTR [DI+17],AX

           MOV   AL,[SI+1]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+20],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+22],AX
           
           MOV   AL,[SI]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+24],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+26],AX

           RET   
IntToDate  ENDP

; Округление вещественного числа до двух знаков
; после запятой
RoundFloat PROC  NEAR
           CMP   Error,0
           JNE   RF_end

           LEA   SI,Str
           
           CMP   BYTE PTR [SI+11],0FFh        ; есть ли точка
           JNZ   RF_end
           CMP   BYTE PTR [SI+1],0Ah
           JZ    RF_end
RF_cyc:    CMP   BYTE PTR [SI+2],0Ah
           JZ    RF_end
           XOR   AL,AL
           CMP   BYTE PTR [SI],5
           JB    RF_1
           ADD   BYTE PTR [SI+1],1
           CMP   BYTE PTR [SI+1],10
           JNZ   RF_1
           MOV   BYTE PTR [SI+1],0
           ADD   BYTE PTR [SI+2],1
RF_1:      CALL  RotateRight
           JMP   RF_cyc

RF_end:    RET
RoundFloat ENDP