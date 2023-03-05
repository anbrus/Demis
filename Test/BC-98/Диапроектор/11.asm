Name KeyAnalize

;Ввод новой цифры в младший разряд в режиме ввода времени   
;и скролирование из младших индикаторова в старшие 
EnterTime  PROC NEAR
           cmp   KeyCode,10
           jnb   EnterValueToDigQuit
           and   ModeEdTime,Set
           jz    EnterValueToDigQuit
           mov   bl,Dig1
           mov   Dig2,bl
           mov   bl,Dig0
           mov   Dig1,bl
           mov   al,KeyCode
           mov   Dig0,al
           mov   ErrorF,NoError    ;Сбрасываем флаг ошибки
EnterValueToDigQuit:
           ret           
EnterTime  ENDP

;Ввод новой цифры в младший разряд в режиме ввода позиции
;и скролирование из младшего индикатора в старший
EnterPos   PROC  NEAR
           cmp   KeyCode,10
           jnb   EnterPosQuit
           and   ModeEdPos,Set
           jz    EnterPosQuit
           mov   bl,Dig0
           mov   Dig1,bl
           mov   al,KeyCode
           mov   Dig0,al
           mov   ErrorF,NoError    ;Сбрасываем флаг ошибки
EnterPosQuit:
           ret
EnterPos   ENDP

;Идти в конец кассеты
GoToEnd    PROC  NEAR
           cmp   KeyCode,KeyEnd
           jne   GoToEndEnd
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    NoModeEnd
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   GoToEndEnd
NoModeEnd:
           mov   NewPos,LastPos
           mov   ErrorF,NoError
GoToEndEnd:
           ret   
GotoEnd    ENDP                      

;Идти в начало кассеты
GoToBeg    PROC  NEAR
           cmp   KeyCode,KeyBeg
           jne   GoToBegQuit
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    NoModeBeg
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   GoToBegQuit
NoModeBeg:
           mov   NewPos,FirstPos
           mov   ErrorF,NoError
GotoBegQuit:
           ret
GoToBeg    ENDP

;Парковка
Park       PROC  NEAR
           cmp   KeyCode,KeyPark
           jne   ParkQuit
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    NoModePark
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   ParkQuit
NoModePark:
           mov   NewPos,ParkPos
           mov   ErrorF,NoError
ParkQuit:
           ret
Park       ENDP

;Вперед на один кадр
PosInc     PROC  NEAR
           cmp   KeyCode,KeyInc1
           jne   PosIncQuit
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    NoMode
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   PosIncQuit
NoMode:    mov   al,Pos
           inc   al
           mov   NewPos,al
           mov   ErrorF,NoError
PosIncQuit:
           ret
PosInc     ENDP

;Назад на один кадр
PosDec     PROC  NEAR
           cmp   KeyCode,KeyDec1
           jne   PosDecQuit
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    PosDecNoMode
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   PosDecQuit           
PosDecNoMode:
           mov   al,Pos
           dec   al
           mov   NewPos,al
           mov   ErrorF,NoError
PosDecQuit:
           ret
PosDec     ENDP

;Переход на десять кадров вперед
PosInc10   PROC  NEAR
           cmp   KeyCode,KeyInc10
           jne   PosInc10Quit
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    NoModeInc10          
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   PosInc10Quit
NoModeInc10:
           mov   al,Pos
           add   al,Inc10
           mov   NewPos,al
           mov   ErrorF,NoError
PosInc10Quit:
           ret           
PosInc10   ENDP

;Переход на десять кадров назад
PosDec10   PROC  NEAR
           cmp   KeyCode,KeyDec10
           jne   PosDec10Quit
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    NoModeDec10
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   PosDec10Quit
NoModeDec10:
           mov   al,Pos
           add   al,Dec10           
           mov   NewPos,al
           mov   ErrorF,NoError
PosDec10Quit:           
           ret
PosDec10   ENDP



;Установить/сбросить режим случайного выбора
InvRndMode PROC  NEAR
           cmp   KeyCode,KeyRnd
           jne   InvRndModeQuit
           mov   bl,ModeEdTime
           or    bl,ModeEdPos
           or    bl,ModeAuto
           jz    RNDOk
           mov   ErrorF,SetRndModeInEdAutoMode
           mov   ModeAuto,UnSet
           jmp   InvRndModeQuit
RndOk:     
           xor   ModeRnd,Set
           jz    UnSetRnd
           call  InitRND1
UnSetRnd:
           mov   ErrorF,NoError
InvRndModeQuit:
           ret
InvRndMode ENDP


;Редактировать время
EdTime     PROC  NEAR   
           cmp   KeyCode,KeyEdTime
           jne   EdTimeQuit     
           ;Проверка на текущий режим
           mov   bl,ModeEdPos
           or    bl,ModeAuto
           jz    NoErrP1
           mov   ErrorF,EdErrAlreadyModeUse
           mov   ModeAuto,UnSet
           jmp   EdTimeQuit
NoErrP1:   mov   ModeEdTime,Set    ;установка флага редактирования режима ввода времени
           mov   Dig2,0Ah ;гашение всех индикаторов
           mov   Dig1,0Ah
           mov   Dig0,0Ah
           mov   ErrorF,NoError    ;Сбрасываем флаг ошибки
EdTimeQuit:
           ret
EdTime     ENDP           



;Установить введеную задержку           
SetTime    PROC  NEAR
           cmp   KeyCode,KeySetTime
           je    SetTimeNoQuit
           jmp   SetTimeQuit
SetTimeNoQuit:           
           and   ModeEdTime,0FFh
           jnz   NoErSet
           mov   ErrorF,SetEdPosErrNoEdMode
           jmp   SetTimeQuit
NoErSet:   mov   ModeEdTime,UnSet
           call  ConvertDigEmptyToZero
           mov   al,Dig2
           add   al,Dig1
           add   al,Dig0
           jnz   NoZeroInAllDig
           mov   ErrorF,ErrorSetTimeValueNotPossible
           jmp   SetTimeQuit
NoZeroInAllDig:           
           cmp   Dig2,2
           jnbe  In2DigMore2
           je    In2Dig_2
;Во втором(0,1,-2-) индикаторе 0 или 1, проверяем нулевой и первый
           cmp   Dig1,6
           jnbe  In1DigMore6
           je    In1Dig_6
;В первом (0,-1-,2) индикаторе не больше 5
           jmp   DigIsOk
;В первом индикаторе больше 6
In1DigMore6:
           mov   ErrorF,6;ErrorSetTimeValueNotPossible
           jmp   SetTimeQuit
;В первом индикаторе 6
In1Dig_6:  and   Dig0,Set
           jz    DigIsOk
;В нулевом индикаторе не 0
           mov   ErrorF,ErrorSetTimeValueNotPossible
           jmp   SetTimeQuit
In2DigMore2:
           mov   ErrorF,ErrorSetTimeValueNotPossible
           jmp   SetTimeQuit
In2Dig_2:  mov   bl,Dig0
           or    bl,Dig1
           jz    DigIsOk
           mov   ErrorF,ErrorSetTimeValueNotPossible
           jmp   SetTimeQuit
DigIsOk:           
;Введенное значение правильное
;Преобразуем его в количество проходов процедуры задержки
           mov   MultiplierForGetNumberFromDig,60
           call  GetNumberFromDig           
           mov   al,NumberFromDig
           mov   bh,DelayInSec
           mul   bh
           mov   MaxCountCycle,ax    ;Запишем его в переменную - количество проходов цикла
           mov   ErrorF,NoError
           mov   ModeEdTime,UnSet
           mov   NeedShowPosF,Set

SetTimeQuit:
           ret
SetTime    ENDP


;Редактировать позицию
EdPos      PROC  NEAR
           cmp   KeyCode,KeyEdPos
           jne   EdPosQuit
           ;Проверка на текущий режим
           mov   bl,ModeEdTime
           or    bl,ModeAuto
           jz    NoErrP2
           mov   ErrorF,EdErrAlreadyModeUse
           mov   ModeAuto,UnSet
           jmp   EdPosQuit
NoErrP2:   mov   ModeEdPos,0FFh  ;установка флага редактирования режима ввода позиции
           mov   Dig2,0Ah     ;гашение всех индикаторов
           mov   Dig1,0Ah
           mov   Dig0,0Ah
           mov   ErrorF,NoError    ;Сбрасываем флаг ошибки
EdPosQuit:
           ret           
EdPos      ENDP


;Установить/Сбросить автоматический режим
InvAutoMode      PROC        NEAR
           cmp   KeyCode,KeyAutoSS
           jne   InvAutoModeQuit
           ;Проверка на текущий режим
           mov   bl,ModeEdTime
           or    bl,ModeEdPos
           jz    NoErrP3
           mov   ErrorF,SetAutoErrEdAlreadyModeUse
NoErrP3:   
           xor   ModeAuto,Change
           jz    UnSetModeAuto
;Режим включился
           mov   AllCadrShow,UnSet
           mov   PosInModeAuto,1
           mov   ax,MaxCountCycle
           dec   ax
           mov   CycleCount,ax
           mov   ErrorF,NoError  ;Сбрасываем флаг ошибки  
           jmp   InvAutoModeQuit
UnSetModeAuto:           
           mov   ErrorF,NoError  ;Сбрасываем флаг ошибки
InvAutoModeQuit:
           ret
InvAutoMode      ENDP           

;Установить на позицию
SetPos     PROC  NEAR
           cmp   KeyCode,KeySetPos
           jne   SetPosQuit
           and   ModeEdPos,0FFh     ;проверка на режим редактирования позиции
           jnz   NoErrP4
           mov   ErrorF,SetEdPosErrNoEdMode
           jmp   SetPosQuit
NoErrP4:   mov   ModeEdPos,UnSet
           mov   MultiplierForGetNumberFromDig,100
           call  GetNumberFromDig    ;Получим введенное число в NumberFromDig
           mov   al,NumberFromDig   
           mov   NewPos,al           ;Запишем число в новую позицию кассеты
           mov   ErrorF,NoError      ;Сбрасываем флаг ошибки
SetPosQuit:
           ret
SetPos     ENDP           

;Отмена режима редактирования и авто
Cancel     PROC  NEAR
           cmp   KeyCode,KeyCancel
           jne   CancelQuit
           mov   ModeAuto,UnSet
           mov   ModeEdPos,UnSet
           mov   ModeEdTime,UnSet
           mov   NeedShowPosF,Set
           mov   ErrorF,NoError
           jmp   CancelQuit
CancelQuit:
           ret
Cancel     ENDP           

;Установка направления авто - прямое
SetAutoInc PROC  NEAR
           cmp   KeyCode,KeyInc1A
           jne   SetAutoIncQuit
           mov   AutoInc,Inc1
           mov   AutoIncF,Set
           mov   ErrorF,NoError
SetAutoIncQuit:
           ret           
SetAutoInc ENDP

;Установка направления авто-обратное
SetAutoDec PROC  NEAR
           cmp   KeyCode,KeyDec1A
           jne   SetAutoDecQuit
           mov   AutoInc,Dec1
           mov   AutoIncF,UnSet
           mov   ErrorF,NoError
SetAutoDecQuit:
           ret
SetAutoDec ENDP

;Пауза авторежима - продолжить после паузы
PausePlay  PROC  NEAR
           cmp   KeyCode,KeyPause
           jne   PausePlayQuit
           mov   al,ModeEdPos
           or    al,ModeEdTime
           jz    NoEdMode
           mov   ErrorF,SetAutoErrEdAlreadyModeUse
           jmp   PausePlayQuit
NoEdMode:
           xor   ModeAuto,0FFh
           mov   ErrorF,NoError
PausePlayQuit:
           ret
PausePlay  ENDP

;Генерировать новую последовательнсть
GenRnd     PROC  NEAR
           cmp   KeyCode,KeyGenRnd
           jne   GenRndQuit
           and   ModeAuto,Set
           jz    NoModeAutoNow
           mov   ErrorF,GenerateNewRndInAutoModeUse
           mov   ModeAuto,UnSet
           jmp   GenRndQuit
NoModeAutoNow:
           call  InitRnd1
           mov   ErrorF,NoError
GenRndQuit:
           ret           
GenRnd     ENDP

HandControl      PROC        NEAR
           call  GoToEnd     ;Идти в конец кассеты
           call  GoToBeg     ;Идти на первую позицию
           call  Park        ;Парковать кассету
           call  PosInc
           call  PosDec
           call  PosInc10
           call  PosDec10
           ret
HandControl      ENDP           

SetMode    PROC  NEAR
           call  InvAutoMode ;Инициализировать/выключить авторежим
           call  InvRndMode  ;Включить/выключть случайных режим
           call  EdTime      ;Редактировать задержку
           call  EdPos       ;Редактировать позицию
           call  Cancel      ;Отмена режимов редактирования и авторежима
           call  SetAutoDec  ;Установить направление автопоказа назад
           call  SetAutoInc  ;Установить направление автопоказа вперед
           call  PausePlay   ;Пауза/продолжить автопоказ
           ret
SetMode    ENDP