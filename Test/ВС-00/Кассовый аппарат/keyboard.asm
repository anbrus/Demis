; В этом модуле собраны все процедуры
; так или иначе относящиеся к работе
; с клавиатурой

; Инициализация образа клавиатуры
InitOutMap PROC  NEAR
           MOV   OutputMap[0],3Fh    ; образы цифр
           MOV   OutputMap[1],0Ch    ; от 0 до 9
           MOV   OutputMap[2],76h
           MOV   OutputMap[3],05Eh
           MOV   OutputMap[4],4Dh
           MOV   OutputMap[5],5Bh
           MOV   OutputMap[6],7Bh
           MOV   OutputMap[7],0Eh
           MOV   OutputMap[8],7Fh
           MOV   OutputMap[9],5Fh
           MOV   OutputMap[10],80h   ; образ точки
           MOV   OutputMap[11],40h   ; образ тере
           MOV   OutputMap[12],0h    ; образ пустого места
           MOV   OutputMap[13],10h   ; образ '_'
           RET
InitOutMap ENDP

; Вывод на дисплей сообщения Error
ErrOutput  PROC  NEAR
           CMP   Error,0
           JE    EMOend
           XOR   AL,AL
           OUT   8,AL
           OUT   7,AL
           OUT   6,AL
           OUT   5,AL
           MOV   AL,73h
           OUT   4,AL
           MOV   AL,60h
           OUT   3,AL
           OUT   2,AL
           OUT   0,AL
           MOV   AL,78h
           OUT   1,AL
EMOend:    RET
ErrOutput  ENDP

; Отображение строки вывода
StrOutput  PROC NEAR
           CMP   Error,0
           JNE   SOend

SOst:      XOR   DX,DX                       ; вывод строки
           LEA   BX,OutputMap
           LEA   SI,Str
           PUSH  SI
           
SO_cyc2:   LODSB
           XLAT
           CMP   AL,80h                      ; если текущий байт - точка,
           JNE   SO_1                        ; то ее надо приORить к следующему байту
           MOV   AH,AL
           LODSB
           XLAT
           OR    AL,AH
           
SO_1:      OUT   DX,AL
           INC   DX
           CMP   DX,8
           JNE   SO_cyc2

           POP   SI                          ; адрес начала строки
           ADD   SI,9
SOend:     RET
StrOutput  EndP

; Опрос клавиатуры
KbdRead    PROC  NEAR
KRm1:      MOV   DX,3                ; опрос портов ввода
KRCyc:     CALL  Time
           CALL  CheckSum
           DEC   DX                  ; 2-0 и выход из цикла
           IN    AL,DX                ; только после нажатия
           CMP   AL,0                ; какой-либо кнопки из
           JNE   KRexit              ; соединенных с портами
           CMP   DX,0
           JNZ   KRCyc
           JMP   KRm1
           
KRexit:    PUSH  AX
KRm2:      IN    AL,DX                ; ввод по отжатию клавиши
           OR    AL,AL
           JNZ   KRm2
           POP   AX                  ; теперь в dl-номер активного порта, а в al-его содержимое
           XOR   CL,CL               ; определение номера активного входа активного порта

KRm3:      INC   CL
           SHR   AL,1                ; двигать до тех пор, пока 1 не уйдет
           JNZ   KRm3
           DEC   CL

           MOV   AL,DL               ; расчет кода клавиши
           SHL   AL,3
           ADD   AL,CL
           
           MOV   ActButCode,AL
Krm_end:   RET
KbdRead    ENDP
          
; Ввод очередной цифры числа
DigitInput PROC  NEAR
           CMP   Error,0
           JNE   DIend
           
           CALL  PointInput
           CALL  SelDepart
           
           CALL  ButtonClr
           CALL  ButtonClrE
           CALL  ButtonMode

           MOV   AL,ActButCode
           
           CMP   AL,0                ; проверка, а действительно ли нажата цифровая
           JB    DIend               ; цифровая клавиша
           CMP   AL,9
           JA    DIend

           CMP   Str[12],0FFh        ; а может быть строку
           JNZ   DIm5                ; надо вводить заново ?
           CALL  DispZero
           MOV   Str[11],0
           MOV   Str[12],0
        
DIm5:      CMP   Str[11],0FFh        ; если точку уже вводили
           JNZ   DIm1               
           CMP   Str[13],4           ; уже ввели 2 цифры после запятой
           JZ    DIend
           INC   Str[13]
           JMP   DIm4

DIm1:      CMP   Str[10],4           ; уже ввели 4 цифры до запятой
           JE    DIend               
           
DIm4:      CMP   Str[10],0           ; строка пустая и нажата кнопка "0"
           JNE   DIm2                ; тогда ничего вводть не надо и
           CMP   AL,0                ; сдвигать разряды строки не надо
           JE    DIend
           JNE   DIm3
DIm2:      CALL  RotateLeft          ; сдвиг ранее введенных разрядов
DIm3:      MOV   Str[0],AL           ; запись символа-цифры
           INC   Str[10]             ; в младший разряд
DIend:     RET
DigitInput ENDP

; Ввод точки
PointInput PROC  NEAR
           CMP   Error,0
           JNE   DIend
           
           MOV   AL,ActButCode
           CMP   AL,Point            ; нажата клавиша "." ?
           JNE   PIend               ; нет, тогда выходим

           CMP   Str[12],0FFh        ; а может быть строку
           JNE   PIm1                ; надо вводить заново ?
           CALL  DispZero
           MOV   Str[12],0

PIm1:      CMP   Str[11],0FFh        ; если точку уже вводили, 
           JE    PIend               ; то этот ввод точки игнорируется

           CMP   Str[10],0           ; строка пустая?
           JNE   PIm2                ; нет, и переход да,
           INC   Str[10]             ; тогда байт перед точкой - нулевой

PIm2:      CALL  RotateLeft          ; сдвиг ранее введенных разрядов

           MOV   Str[0],AL           ; запись точки в младший разряд    
           MOV   Str[11],0FFh        ; установка флага наличия точки в строке
PIend:     RET
PointInput ENDP

; Ввод времени
TimeInput  PROC  NEAR
           CMP   Error,0
           JNE   TIn_end

           LEA   DI,Str
           MOV   AL,ActButCode
           MOV   AH,[DI+10]
           
           CMP   AH,0                        ; ввод первой цыфры часов
           JNZ   TIn_01
           CMP   AL,0
           JB    TIn_end
           CMP   AL,2
           JA    TIn_end
           
TIn_01:    CMP   AH,1                        ; ввод второй цыфры часов
           JNZ   TIn_02
           MOV   DL,[DI+4]
           CMP   DL,2
           JNZ   TIn_02
           CMP   AL,0
           JB    TIn_end
           CMP   AL,3
           JA    TIn_end
          
TIn_02:    CMP   AH,2                        ; ввод первой цыфры минут
           JNZ   TIn_03
           CMP   AL,0
           JB    TIn_end
           CMP   AL,5
           JA    TIn_end
           
TIn_03:    CMP   AL,0
           JB    TIn_end
           CMP   AL,9
           JA    TIn_end

           CMP   BYTE PTR [DI+10],5           ; уже ввели время
           JZ    TIn_end
           
           CMP   BYTE PTR [DI+10],2           ; уже вели часы
           JNZ   TIn_1
           INC   BYTE PTR [DI+10]

TIn_1:     MOV   DX,4
           SUB   DL,[DI+10]
           ADD   DI,DX
           MOV   [DI],AL
           INC   BYTE PTR Str+10
TIn_end:   RET
TimeInput  ENDP

; Ввод даты
DateInput  PROC  NEAR
           CMP   Error,0
           JNE   DIn_end

           LEA   DI,Str
           MOV   AL,ActButCode
           MOV   AH,[DI+10]
           
           CMP   AH,0                        ; ввод первой цыфры числа
           JNZ   DIn_01
           CMP   AL,0
           JB    TIn_end
           CMP   AL,3
           JA    TIn_end
           
DIn_01:    CMP   AH,1                        ; ввод второй цыфры числа
           JNZ   DIn_02
           MOV   DL,[DI+7]
           CMP   DL,3
           JNZ   DIn_02
           CMP   AL,0
           JB    TIn_end
           CMP   AL,1
           JA    TIn_end
           
DIn_02:    CMP   AH,2                        ; ввод первой цыфры месяца
           JNZ   DIn_03
           CMP   AL,0
           JB    TIn_end
           CMP   AL,1
           JA    TIn_end
                     
DIn_03:    CMP   AH,4                        ; ввод второй цыфры числа
           JNZ   DIn_04
           MOV   DL,[DI+4]
           CMP   DL,1
           JNZ   DIn_04
           CMP   AL,0
           JB    TIn_end
           CMP   AL,2
           JA    TIn_end
                             
DIn_04:    CMP   AL,0
           JB    TIn_end
           CMP   AL,9
           JA    TIn_end

           CMP   BYTE PTR [DI+10],8           ; уже ввели дату
           JZ    TIn_end
           
           CMP   BYTE PTR [DI+10],2           ; уже вели день
           JNZ   DIn_1
           INC   BYTE PTR [DI+10]

DIn_1:     CMP   BYTE PTR [DI+10],5           ; уже вели месяц
           JNZ   DIn_2
           INC   BYTE PTR [DI+10]
           
DIn_2:     MOV   DX,7
           SUB   DL,[DI+10]
           ADD   DI,DX
           MOV   [DI],AL
           INC   BYTE PTR Str+10
DIn_end:   RET
DateInput  ENDP

DateTrue   PROC
           LEA   SI,DateCount
           
           MOV   AH,[SI+1]
           MOV   AL,[SI]
           AAD
           MOV   DX,AX
           
           MOV   AH,[SI+4]
           MOV   AL,[SI+3]
           AAD
           MOV   BX,AX
           
           MOV   AH,[SI+7]
           MOV   AL,[SI+6]
           AAD
           
           CMP   BX,2
           JNZ   DT_1
           AND   DX,3
           CMP   DX,0
           JNZ   DT_2
           CMP   AX,29
           JBE   DT_end
           JMP   DT_err
DT_2:      CMP   AX,28
           JBE   DT_end
           JMP   DT_err

DT_1:      CMP   BX,4
           JNZ   DT_3
           CMP   AX,30
           JBE   DT_end
           JMP   DT_err
           
DT_3:      CMP   BX,6
           JNZ   DT_4
           CMP   AX,30
           JBE   DT_end
           JMP   DT_err
           
DT_4:      CMP   BX,9
           JNZ   DT_5
           CMP   AX,30
           JBE   DT_end
           JMP   DT_err

DT_5:      CMP   BX,11
           JNZ   DT_end
           CMP   AX,30
           JBE   DT_end
           JMP   DT_err

DT_err:    MOV   Error,0FFh
           JMP   Date_cyc

DT_end:    RET
DateTrue   ENDP

; Умножение того что на дисплее с тем, что будет введено позднее
MulRezArg  PROC  NEAR
           CMP   Error,0
           JNE   MRA_end

           CMP   ActButCode,Multiplication
           JNE   MRA_end
           
           CMP   Operation,3         ; если просто нажимать то
           JE    MRA_end             ; ничего не происходит

           MOV   Operation,3         ; запомнить операцию '*'
           XOR   AX,AX
           MOV   AL,Str
           CMP   Str+1,0Ch
           JZ    MRA_1
           MOV   AH,Str+1
MRA_1:     AAD
           MOV   GoodCode,AL
           
           LEA   DI,Rez              ; вычисление стоймости товара 
           LEA   SI,HandBook         ; по справочнику
           
           MOV   AH,10
           MUL   AH
           ADD   SI,AX
           MOV   CX,5
MRA_cyc:   MOV   AL,[SI]
           MOV   [DI],AL
           INC   SI
           INC   DI
           LOOP  MRA_cyc

           LEA   SI,Rez
           CALL  FloatToStr
           CALL  StrOutput
           CALL  RoundFloat              ; округление

           MOV   Str[11],0           ; разрешение ввовдить точку
           MOV   Str[12],0FFh
           MOV   Str[13],0           

MRA_end:   RET
MulRezArg  ENDP

; Выполнение действий
Calculate  PROC  NEAR
           CMP   Error,0
           JNE   Calc_end

           CMP   ActButCode,Calculation
           JNE   Calc_end
           CMP   Operation,3
           JNZ   Calc_end

           LEA   DI,Arg              ; получени аргументов для
           CALL  StrToFloat          ; умножения
           LEA   SI,Rez
           XCHG  SI,DI
           
           CALL  ArgsSave            ; запись аргументов в чек
           
           CALL  MulFunc
           CALL  Overflow            ; контроль переполнения
           
           CALL  GoodCount           ; подсчет количества товара           
           CALL  SubTotalSave        ; запись промежуточной суммы в чек
           
           LEA   SI,Rez              ; получение аргументов для
           LEA   DI,ItogRez          ; сложения с итоговой суммой
           CALL  AddFunc
           CALL  Overflow            ; контроль переполнения

           LEA   SI,ItogRez          ; вывод на индикаторы итоговой суммы
           CALL  FloatToStr
                              
           CALL  RoundFloat          ; округление
                            
           MOV   Str[12],0FFh
           MOV   Str[11],0FFh
           MOV   Operation,0
Calc_end:  RET
Calculate  ENDP

GoodCount  PROC  NEAR
           PUSH  BX SI DI
           
           LEA   BX,GoodCode
           LEA   SI,Rez
           LEA   DI,HandBook+5
                      
           MOV   AL,[BX]
           MOV   AH,10
           MUL   AH
           ADD   DI,AX
           CALL  AddFunc
           CALL  Overflow
           
           POP   DI SI BX
           RET
GoodCount  ENDP           