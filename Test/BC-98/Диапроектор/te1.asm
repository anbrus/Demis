; Головной модуль
;Описание констант
Name MainDiaproektor

RomSize    EQU   4096
;Колическтво повторный считываений при уcтранении дребезга 
NMax       EQU   50

;адрес клавиатурного порта
KbdPort    EQU   2

;адреса семисегментных индикатроров
DispPort0  EQU   4
DispPort1  EQU   8
DispPort2  EQU   10h

;Адрес порта индикаторов состояний
IndPort  EQU   20h

;Адрес порта шагового и челночного двигателя
HardPort   EQU   2h

;Первая позиция
FirstPos   EQU   1

;Последняя позиция
LastPos    EQU   50

;Позиция парковки
ParkPos    EQU   0


;Установить флаг
Set        EQU   0FFh

;Сбросить флаг
UnSet      EQU   0

;Поменять флаг с ксором
Change     EQU   0FFh

;Минус единица
Dec1       EQU   0FFh

;Минус еденица для слова
Dec1_dw    EQU   0FFFFh

;Плюс единица
Inc1       EQU   1

;Плюс десять
Inc10      EQU   10

;Минус десять
Dec10      EQU   246

;Делитель общей суммы при вычислении случайной позиции
NumberForDivRnd  EQU         53

;Коды ошибок

;Нет ошибки
NoError                      EQU    0

;Попытка включить режим редактирования
;при уже включенном режиме редактирования
;или при включенном автоматическом режиме
EdErrAlreadyModeUse          EQU    1    

;Попытка включить автоматический режми при
;включенном режиме редактирования(времени или позиции)
SetAutoErrEdAlreadyModeUse   EQU    2

;Установка редактрируемой позиции или задрежки при невключенном режиме редактирования
SetEdPosErrNoEdMode          EQU   3

;Установка режима случайного кадра при редктирвоании или в автом. режиме
SetRndModeInEdAutoMode       EQU   4

;Введенная задержка не соответствует правилам ввода
ErrorSetTimeValueNotPossible EQU    5

;Попытка перехода на новую позицию в режиме редактирвоания или авторежиме
ErrorNewPosInModeAE          EQU    6

;Неверная новая позиция
ErrorPosNotPossible          EQU    7

;Нажаты две клавиши одновременно
ErrorTwoKeyPressed           EQU    8

;генерирования новой последовательности
;для в авторежима при работающем авторежиме
GenerateNewRndInAutoModeUse  EQU    9

;Флаги Регистра состояний
ErrorStateFlag   EQU         1    ;Ошибка
AutoStateFlag    EQU         2    ;Авто
RndStateFlag     EQU         4    ;Случайный
EdTimeStateFlag  EQU         8    ;Редактир.Задерж.
EdPosStateFlag   EQU         16   ;Редактир.Позиции
AutoIncStateFlag EQU         32    ;Прямой ход автореж
AutoDecStateFlag EQU         64    ;Обратный ход авто


;Номера битов порта
;Положительное приращение шагового двигателя
SetImpulseIncrement EQU         20h
UnSetImpulseIncrement        EQU    0FFh-20h

;Отрицательное приращение шагового двигателя
SetImpulseDecrement EQU         40h
UnSetImpulseDecrement        EQU    0FFh-40h

;Установить челнок(Показать текущий кадр)
SetShutle  EQU   10h

;Сбросить челнок(Ничего не показывать)
UnSetShutle EQU  0

BitOfPoint EQU   128

;Задрежка для шагового двигателя
DelayForStepEngine           EQU    60
;задрежка 0.048c для задания паузы между кадрами
;в автоматическом режиме
DelayForPauseCadr            EQU    20000
;В одной секунде задержек
DelayInSec EQU   20

;Количество импульсов шагового двигателя для
;переключения одного кадра
NumberImpulseOnStep          EQU    10

;Коды клавиш
Key0       EQU   0
Key1       EQU   1
Key2       EQU   2
Key3       EQU   3
Key4       EQU   4
Key5       EQU   5
Key6       EQU   6
Key7       EQU   7
Key8       EQU   8
Key9       EQU   9
KeyEnd     EQU   0Ah
KeyBeg     EQU   0Bh
KeyInc1    EQU   0Ch
KeyDec1    EQU   0Dh
KeyInc10   EQU   0Eh
KeyDec10   EQU   0Fh
KeySetPos  EQU   10h
KeyEdPos   EQU   11h
KeySetTime EQU   12h
KeyEdTime  EQU   13h
KeyAutoSS  EQU   14h
KeyInc1A   EQU   15h
KeyDec1A   EQU   16h
KeyRnd     EQU   17h
KeyPark    EQU   18h
KeyPause   EQU   19h
KeyGenRnd  EQU   1Ah
KeyCancel  EQU   1Bh


EmptyKeyboard    EQU         0FFh



; Описание данных
Data Segment at 0BA00H
;Номер нажатой клавиши
KeyCode    db    ?
;Код который считали из порта клавиатуры
inCode     db    ?
;Входное значение которое раскладывается по десятичным разрядам
ValueForEx db    ?
;Флаг автоматический режим
ModeAuto   db    ?
;Флаг ржеима случайный переход при автоматическом режим
ModeRnd    db    ?
;Флаг режима редактирвоание позиции
ModeEdPos  db    ?
;Флаг режима редактирование задержки
ModeEdTime db    ?
;Флаг ошибок - содержит код ошибки
ErrorF     db    ?
;число преобразованное из индикаторов 
NumberFromDig    db          ? 
;Текущее содержание индикаторов
Dig0       db    ?
Dig1       db    ?
Dig2       db    ?
;флаг состояний, отображается на индикаторы состояний
StateF     db    ?
;Множитель старшего разряда при подсчете номера позиции и величины задержки
MultiplierForGetNumberFromDig    db    ?
;Количество проходов перед сменой кадра в автоматическом режиме
MaxCountCycle    dw          ?    
;Флаг    "Требуется вывести номер позиции"
NeedShowPosF     db          ?    
;Текущий Номер позиции каретки
Pos        db    ?
;Новая позиция каретки
NewPos     db    ?
;Новая позиция каретки в импульсах шагового двигателя
NewPosMul10      db          ?
;Текущая позиция каретки в импульсах шагового двигателя
PosMul10   db    ?
;Приращение шага к новому положению каретки(+1,-1)
IncPos     dw    ?
;Бит порта который будет взводиться при управлении шаговым двигателем для 
;перевода на новую позицию
SetImpulseForPosition        db    ?
;Маска порта для сброса бита шагового двигателя
UnSetImpulseForPosition        db    ?
;Количество циклов в процедуре задержки
DelayCycles      dw          ?
;Количесто проходов процедуры задержки
CycleCount dw    ?
;Флаг - в автоматическом режиме все кадры показаны
AllCadrShow      db          ?
;Флаг-направление показа авторежима - прямое
AutoIncF   db    ?
;Приращение при авторежиме 0- прямое FF-обратние
AutoInc    db    ?
;Позиция кассеты в режиме авто
PosInModeAuto    db          ?
;Челнок активен
ChActive   db    ?
;Массив содержащий последовательность показ кадров
;в автоматическом режиме
Cadr       db 51 dup(?)
;Следующий случайный кадр при генерации последовательности показа
NextRnd    dw    ?
;Переменные хранящие последние четыре случайных кадра
;на их основе вычислятеся пятый случайный кадр
Rnd1       dW    ?
Rnd2       dW    ?
Rnd3       dW    ?
Rnd4       dW    ?
Retry      db    ?


Data EndS

; Описание стека
Stack Segment at 0BA80H 
     dw 100 dup (?)              ; 100 слов (с запасом)
     StkTop label Word           ; вершина стека
Stack EndS

; Описание выполняемых действий
Code Segment
Assume cs:Code,ds:Data,es:Code

           ;Образы 16-тиричных символов: "0", "1", ... "F"
SymImages  DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh,0,06Fh,079h,033h,07Ch,073h,063h,1,1,1,1,1,1

;Подготовка переменных и флагов
Prepare    PROC  NEAR
;Установка режимов           
           mov   ModeAuto,UnSet
           mov   ModeEdPos,UnSet
           mov   ModeEdTime,UnSet
           mov   ModeRnd,UnSet
           mov   StateF,Set
           mov   ErrorF,NoError
           mov   al,Set
           out   IndPort,al
           mov   NewPos,ParkPos
           mov   Pos,ParkPos
           mov   NeedShowPosF,Set
           mov   MaxCountCycle,2
           mov   AutoIncF,Set
           mov   AutoInc,Inc1
           mov   AllCadrShow,UnSet
           mov   Rnd1,1
           mov   Rnd2,0
           mov   Rnd3,0
           mov   Rnd4,0
           mov   MaxCountCycle,20
           mov   ChActive,UnSet
           ret
Prepare    ENDP           

;--------------------------  VIBRDESTR--------------
;Oбработка дребезга контактов клавиатуры
VibrDestr  PROC  NEAR
VD1:       
           in    al,KbdPort
           mov   ah,al
           mov   bh,0        ;Сброс счётчика повторений
VD2:       in    al,KbdPort  ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   bh          ;Инкремент счётчика повторений
           cmp   bh,NMax     ;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных
           ret
VibrDestr  ENDP

;===================         GetDigFromNumber==========
GetDigFromNumber   PROC  NEAR
;Преобразование входного значения ValueForEx по десятичным разрядам
;в Dig2,Dig1,Dig0
;Было 234 станет 2,3,4
           mov   ah,0
           mov   al,ValueForEx
           mov   dx,0
           mov   cx,0Ah
           div   cx
           mov   Dig0,dl
           mov   dx,0
           div   cx
           mov   Dig1,dl
           mov   dx,0
           div   cx
           mov   Dig2,dl
           ret
GetDigFromNumber   ENDP           

;++++++++++++++++++++++++++  ConvertShow  ++++++
;Преобразование Dig2,Dig1,Dig0
;в cемисегментный код и вывод на cемисегментные индикаторы в порты
ConvertShow   PROC  NEAR
           lea   bx,SymImages
           mov   cl,Dig0
           mov   ch,0
           add   bx,cx
           mov   al,es:[bx]
           Out   DispPort0,al

           lea   bx,SymImages
           mov   cl,Dig1
           mov   ch,0
           add   bx,cx
           mov   al,es:[bx]
           Out   DispPort1,al
           
           lea   bx,SymImages
           mov   cl,Dig2
           mov   ch,0
           add   bx,cx
           mov   al,es:[bx]
           and   ModeEdTime,Set
           jz    NoModeEdTimeNow1
           or    al,BitOfPoint
NoModeEdTimeNow1:
           Out   DispPort2,al
           ret
ConvertShow   ENDP


;___________________         ConvertDigEmptyToZero________________
;Преобразование пустых индикаторов Dig0,1,2 в нули DIG
;Используется для преобразования погашенных индикаторов в 0.
;Если индикатор погашен, считаем его нулем
ConvertDigEmptyToZero       PROC NEAR
;Второй разряд
           mov   bl,Dig2
           xor   bl,0Ah      ;проверка на погашеный индикатор(считаем его нулем)
           jnz   ItsnZeroOk22
           mov   Dig2,0
ItsnZeroOk22:
;первый разряд
           mov   bl,Dig1
           xor   bl,0Ah      ;проверка на погашеный индикатор(считаем его нулем)
           jnz   ItsnZeroOk12
           mov   Dig1,0
ItsnZeroOk12:
;нулевой разряд
           mov   bl,Dig0
           xor   bl,0Ah      ;проверка на погашеный индикатор(считаем его нулем)
           jnz   ItsnZeroOk02
           mov   Dig0,0
ItsnZeroOk02:
           ret
ConvertDigEmptyToZero       ENDP           


;@@@@@@@@@@@@@@@@@@@@@@@@@@  GetNumberFromDig   @@@@@@@@@@@@@@@@
;Преобразование из Трехразрядного вида в число
;Dig2,1,0 -> NumberFromDig
GetNumberFromDig PROC NEAR
           call  ConvertDigEmptyToZero
           mov   al,Dig2
           mov   bh,MultiplierForGetNumberFromDig
           mul   bh
           mov   cl,al
           mov   al,Dig1
           mov   bh,10
           mul   bh
           add   cl,al
           add   cl,Dig0
           mov   NumberFromDig,cl
           ret
GetNumberFromDig ENDP

;^^^^^^^^^^^^^^^^^^^^^^^^^^  KeyRead  ^^^^^^^^^^^^^^^^^^^^^^
;Обработка клавиатуры
KeyRead    PROC NEAR
           mov   bx,dec1      ;это -1, нужна для того чтобы код клавиши начинался с 0
Go1:       mov   KeyCode,EmptyKeyboard    ;Если клава не пустая сюда запишется код
           mov   cl,1        ;что посылаем в порт клавы
Next:      mov   al,cl           
           and   ChActive,Set
           jz    Pos0
           or    al,SetShutle
Pos0:           
           out   KbdPort,al
           in    al,KbdPort
           and   al,0FFh
           jz    NoON        ;переход дальше если не было нажатия в этой строке
           jp    TwoKeyPresedNow ;В данной строке нажато две клавиши
           cmp   KeyCode,EmptyKeyboard
           je    No2KeyPressed    ;В других строках нажато еще одна клавиша
           jmp   TwoKeyPresedNow    ;Переход, было нажато 2 клавиши
No2KeyPressed:
           mov   InCode,al   ;cохраняем значение считанное из порта
           call  VibrDestr   ;обработка дребезга контактов
Read_0:    in    al,KbdPort 
           and   al,0FFh
           jnz   Read_0      ;Ждем до тех пор пока не отпустят клавишу
           call  VibrDestr   ;обработка дребезга
;Найдем порядковый номер бита           
           mov   ax,1111111011111111b
           push  bx
           mov   bl,0
ShlNext:
           inc   bl
           and   InCode,ah
           jz    BitFound
           shl   ax,1
           jc    ShlNext
           jmp   BitNotFound
BitFound:           
           mov   inCode,bl
           pop   bx
BitNotFound:
Not4:      add   bl,InCode       ;cl = номер нажатой клавиши
           mov   KeyCode,bl  ;Cохранили;
           jmp   NoON
TwoKeyPresedNow:
           mov   KeyCode,EmptyKeyBoard;
           mov   ErrorF,ErrorTwoKeyPressed
           jmp   EndKeyRead           
NoON:      
           add   bx,7
           shl   cl,1
           and   cl,1111b
           jnz   Next
EndKeyRead:
           ret
KeyRead    ENDP

;=========================   GetNextRnd =================== 
GetNextRnd PROC  NEAR
           push  ax
           push  bx
GetNextRndAgain:
           mov   ax,Rnd1
           add   ax,Rnd2
           add   ax,Rnd3
           add   ax,Rnd4
           mov   bh,NumberForDivRnd
           div   bh
           shr   ax,8
           mov   NextRnd,ax
           
           mov   ax,Rnd2
           mov   Rnd1,ax
                      
           mov   ax,Rnd3
           mov   Rnd2,ax
                      
           mov   ax,Rnd4
           mov   Rnd3,ax
                      
           mov   ax,NextRnd
           mov   Rnd4,ax

           cmp   al,LastPos
           jnb   GetNextRndAgain
           inc   NextRnd
           pop   bx
           pop   ax
           ret
GetNextRnd ENDP


;!!!!!!!!!!!!!!!!!!!!!!!!!   InitRnd   !!!!!!!!!!!!!!!!!!!
;Инициализация режима случайного перехода
;В убывающем порядке будут найдены номера всех ячеек
InitRnd1    PROC  NEAR
           mov   si,LastPos
SetNextCadr1:
           mov   Cadr[si],Unset
           dec   si
           jnz   SetNextCadr1

           mov   bh,0
           mov   bl,LastPos
GetNext1:
           call  GetNextRnd
           mov   si,LastPos+1
NextCheck:
           dec   si
           mov   ax,NextRnd
           cmp   al,Cadr[si]
           je    GetNext1
           cmp   si,bx
           jne   NextCheck
           mov   ax,NextRnd
           mov   Cadr[bx],al
           dec   bl
           jnz   GetNext1
           ret
InitRnd1    ENDP


;####################################################################
;Инициализация режима автоматического показа
InitAuto   PROC  NEAR
           mov   CycleCount,0
           mov   AllCadrShow,UnSet
           mov   PosInModeAuto,1           
           ret
InitAuto   ENDP           

;-------------------         SetNewPos  -----------------------------------
;Получение номера следующего кадра в автоматическом режиме
SetNewPos  PROC  NEAR
           cmp   ModeRnd,Set
           je    ItsModeRndNow
;Не случайный режим
           mov   bl,NewPos
           add   bl,AutoInc
           cmp   bl,LastPos
           jnbe  AllCadrIsShow
           mov   NewPos,bl
           jmp   EndSetNewPos
;Случайный режим
ItsModeRndNow:
           mov   bl,PosInModeAuto
           add   bl,AutoInc
           cmp   bl,LastPos
           jnbe  AllCadrIsShow
           mov   bh,0
           mov   al,Cadr[bx]
           mov   NewPos,al
           mov   PosInModeAuto,bl
           jmp   EndSetNewPos
AllCadrIsShow:
           mov   AllCadrShow,Set
EndSetNewPos:
           ret
SetNewPos  ENDP

;=========================   AutoProcessing  =========================
;Перевод кассеты на новую позицию если включен режим авто
;и подошло время смены кадра
AutoProcessing   PROC        NEAR
;проверка режима
           mov   al,ModeAuto
           and   al,Set
           jz    NoModeAuto
;режим установлен
;Установка времени задержки для процедуры задержки
;           mov   ErrorF,UnSet
           mov   DelayCycles,DelayForPauseCadr
;вызов задержки
           call  Delay
;Увеличим счетчик вызовов подпрограммы задержки           
           inc   CycleCount
           mov   ax,CycleCount
           cmp   ax,MaxCountCycle
;Сравниваем прошедших число задержек с нужным количеством
           jb    WaitTimeForNewCadr
;время подошло сбрасываем счетчик вызовов задержки
           mov   CycleCount,UnSet
;получаем новую позицию в NewPos
           call  SetNewPos
;все кадры показаны?
           and   AllCadrShow,Set
           jz    NoAllCadrShowNow
;все кадры показаны, сброс режима авто           
           mov   ModeAuto,UnSet
NoAllCadrShowNow:
SetNewCadr:           
WaitTimeForNewCadr:           
NoModeAuto:
           ret
AutoProcessing   ENDP


;__________________  DELAY  ______________________________
;Процедура задержки
;Пустой цикл срабатывает DelayCycles раз
Delay      PROC  NEAR
           push   ax
           mov   ax,DelayCycles
NextDelay:
           dec   ax
           jnz   NextDelay
           pop  ax
           ret
Delay      ENDP

;++++++++++++++++++++++        SetPosition     ++++++++++++++++
;Переход к новой позиции, если такая есть
SetPosition      PROC        NEAR
           mov   al,NewPos
           cmp   al,Pos
;Проверка нужно ли вообще переводить 
           jz    NoMove
;Новая позиция меньше старой?
           jb    NewLowerPos
;Выше
;Будем прибавлять что бы достигнуть новой позиции
           mov   IncPos,Inc1
;Импульсы на плюсовой вход шагового дв.
           mov   SetImpulseForPosition,SetImpulseIncrement
           jmp   IncOk
NewLowerPos:;Ниже
;Будем убавлять что бы достигнуть новой позиции
           mov   IncPos,Dec1_dw
;Импульсы на минусовой вход двигателя
           mov   SetImpulseForPosition,SetImpulseDecrement
IncOk:
;Проверка новой позиции на правильность
           cmp   al,LastPos
           jnbe  PosMore50
;Новая позиция корректна, двигаемся туда на один кадр
           mov   bx,IncPos
           add   Pos,bl
           mov   cl,NumberImpulseOnStep
;Установим задержку для процедуры задержки           
           mov   DelayCycles,DelayForStepEngine
;Отключаем челнок, что бы можно было двигать кассету           
           mov   al,UnSetShutle
           out   HardPort,al
           mov   ChActive,UnSet
BeforeNoZeroInCL:
           call  Delay
           mov   al,SetImpulseForPosition
           out   HardPort,al
           call  Delay
           mov   al,UnSet
           out   HardPort,al
           dec   cl
           jnz   BeforeNoZeroInCL
           mov   NeedShowPosF,0FFh
           jmp   EndSetPos
PosMore50:
           mov   ErrorF,ErrorPosNotPossible           ;123123
           mov   al,Pos
           mov   NewPos,al
           jmp   EndSetPos
NoMove:           
           and   Pos,0FFh
           jz    ZeroPosNow
           mov   al,SetShutle
           out   HardPort,al
           mov   ChActive,Set
ZeroPosNow:
EndSetPos:
           ret           
SetPosition      ENDP


;^^^^^^^^^^^^^^^^^^^^^^^^  DisplayP   ^^^^^^^^^^^^^^^^^^^^^^
;отвечает за выводимое на экран
DisplayP   PROC NEAR
;Проверка на код ошибки
           and   ErrorF,Set
           jz    NoErrF
;Преобразование кода ошибки в трехразрядный
           mov   al,ErrorF
           mov   ValueForEx,al
           call  GetDigFromNumber
           jmp   NoErrF 
NoErrF:    
;Проверка флага тербуется вывод текущей позиции и 
;вывод теркущей позиции на индикаторы, если надо
           mov   al,NeedShowPosF
           and   al,0FFh
           jz    NoNeedShowPos    ;не требуется
           mov   al,Pos
           mov   ValueForEx,al
           mov   NeedShowPosF,0
           call  GetDigFromNumber
NoNeedShowPos:
;Преобразование текущего трехсегментногокода и вывод на индикаторы
           call  ConvertShow
;Вывод на семисегментные индикаторы
;Вывод на индикаторы состояния
           mov   al,ErrorF
           and   al,Set
           jz    NoErrorFSet
           mov   al,ErrorStateFlag
           jmp   SetOk
NoErrorFSet:
           mov   al,Unset
SetOk:
           mov   bl,AutoStateFlag
           and   bl,ModeAuto
           or    al,bl
           
           mov   bl,RndStateFlag
           and   bl,ModeRnd
           or    al,bl
           
           mov   bl,EdTimeStateFlag
           and   bl,ModeEdTime
           or    al,bl
           
           mov   bl,EdPosStateFlag
           and   bl,ModeEdPos
           or    al,bl
           
           mov   bl,AutoIncStateFlag
           and    bl,AutoIncF
           or    al,bl
           
           mov   bl,AutoDecStateFlag
           xor   AutoIncF,Set
           and   bl,AutoIncF
           xor   AutoIncF,Set
           or    al,bl
           
           mov   StateF,al
           out   IndPort,al           
           ret                      
DisplayP   ENDP

include    11.asm
;-----------------------------------------------------------------
;-----------------------------------------------------------------
Begin:     mov ax,Data             ; инициализация
           mov ds,ax               ; сегментных
           mov ax,Code
           mov es,ax               ; регистров и
           mov ax,Stack
           mov ss,ax
           mov sp,offset StkTop    ; указателя стека

           call  Prepare
           
Cycle:
           call  GetNextRnd
;Обработка клавиатуры
           call  KeyRead     ;Ввод с клавиатуры с контролем ввода
           call  HandCOntrol ;Ручное управление кассетой
           call  SetMode     ;Ручная установка режимов
           call  SetTime     ;Установить задержку с индикаторов
           call  EnterTime   ;Ввод задержки 
           call  EnterPos    ;Ввод позиции
           call  SetPos      ;Установить кассету на новую позицию
           call  GenRnd      ;генерировать новую последовательность кадров для авторежима
           call  AutoProcessing ;установка новой позиции если требуется в авторежиме
           call  SetPosition ;Установка на новую позицию
           call  DisplayP    ;Вывод на индикаторы
           jmp Cycle




         assume cs:nothing
         org 0FF0h               ; задание стартовой
   Start:jmp Far Ptr Begin       ; точки, управление
                                 ; передается на
                                 ; команду jump
Code EndS

End Start