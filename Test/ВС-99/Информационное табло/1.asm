RomSize    EQU   4096
NMax       EQU   50          ; константа подавления дребезга
KbdPort    EQU   99h           ; адреса портов
;--------------Сегмент стека--------------------------------------------------------
Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS
;--------------Сегмент данных-------------------------------------------------------
Data       SEGMENT AT 0
           KbdImage          DB    8 DUP(?)    ; единично-шестнадцатир. код очередн. введен. цифры(с клавы)
           EmpKbd            DB    ?        ; пустая клава
           KbdErr            DB    ?        ; ошибка клавы
           dex               DW    ?        
           Index             DW    ?        ; индекс эл-ов Memory       
           Index1            DW    ?
           IndexIndic        DW    ?
           CheckIndic        DW    ?
           Memory            DW    14 Dup(?)   
           GoTime            DW    ?            ;конец инициализации
           GoTime1           Dw    ?
           TimeMassiv        DW    10 Dup(?)
           Schet             DW    4  Dup(?)
           SchetMass         DB    200 Dup(?)
           HourDelay         DW    ?
           MinuteDelay       DW    ?
           up                DW    ?    ; верхний порт
           down              DW    ?    ; нижний порт
           left              DW    ?    ; левый порт   
Data       ENDS
;---------------Сегмент кода---------------------------------------------------------
Code       SEGMENT
           ASSUME cs:Code,ds:Data,ss:Stk
;------------------------------------------------------------------------------------
Image      db    0000000b,1111100b,0010010b,0010001b,0010001b,0010010b,1111100b,0000000b  ;"А"0
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,0110000b,0000000b  ;"Б"1
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,0110110b,0000000b  ;"В"2
           db    0000000b,1111111b,0000001b,0000001b,0000001b,0000001b,0000011b,0000000b  ;"Г"3
           db    0000000b,1100000b,0111100b,0100010b,0100001b,0111111b,1100000b,0000000b  ;"Д"4
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,1001001b,0000000b  ;"Е"5
           db    0000000b,1111111b,0001000b,1111111b,0001000b,1111111b,0000000b,0000000b  ;"Ж"6
           db    0000000b,0100010b,1000001b,1000001b,1001001b,1001001b,0110110b,0000000b  ;"З"7
           db    0000000b,1111111b,0100000b,0010000b,0001000b,0000100b,1111111b,0000000b  ;"И"8
           db    0000000b,1111111b,0100000b,0010001b,0001001b,0000100b,1111111b,0000000b  ;"Й"9
           db    0000000b,1111111b,0001000b,0001000b,0010100b,0100010b,1000001b,0000000b  ;"K"10
           db    0000000b,1111100b,0000010b,0000001b,0000001b,0000010b,1111100b,0000000b  ;"Л"11
           db    0000000b,1111111b,0000010b,0000100b,0000100b,0000010b,1111111b,0000000b  ;"М"12
           db    0000000b,1111111b,0001000b,0001000b,0001000b,0001000b,1111111b,0000000b  ;"Н"13
           db    0000000b,0111110b,1000001b,1000001b,1000001b,1000001b,0111110b,0000000b  ;"О"14
           db    0000000b,1111111b,0000001b,0000001b,0000001b,0000001b,1111111b,0000000b  ;"П"15
           db    0000000b,1111111b,0001001b,0001001b,0001001b,0001001b,0000110b,0000000b  ;"Р"16
           db    0000000b,0111110b,1000001b,1000001b,1000001b,1000001b,0100010b,0000000b  ;"С"17
           db    0000000b,0000001b,0000001b,1111111b,0000001b,0000001b,0000000b,0000000b  ;"Т"18
           db    0000000b,1001111b,1001000b,1001000b,1001000b,1001000b,1111111b,0000000b  ;"У"19
           db    0000000b,0001111b,0001001b,1111111b,0001001b,0001111b,0000000b,0000000b  ;"Ф"20
           db    0000000b,1100011b,0010100b,0001000b,0001000b,0010100b,1100011b,0000000b  ;"Х"21
           db    0000000b,0111111b,0100000b,0100000b,0100000b,0111111b,1000000b,0000000b  ;"Ц"22
           db    0000000b,0001111b,0001000b,0001000b,0001000b,0001000b,1111111b,0000000b  ;"Ч"23
           db    0000000b,1111111b,1000000b,1111111b,1000000b,1111111b,0000000b,0000000b  ;"Ш"24
           db    0000000b,1111111b,1000000b,1111111b,1000000b,1111111b,1000000b,0000000b  ;"Щ"25
           db    0000000b,0000001b,1111111b,1001000b,1001000b,1001000b,0110000b,0000000b  ;"Ъ"26
           db    0000000b,1111111b,1001000b,1001000b,1001000b,0110000b,1111111b,0000000b  ;"Ы"27
           db    0000000b,1111111b,1001000b,1001000b,1001000b,0110000b,0000000b,0000000b  ;"Ь"28
           db    0000000b,1000001b,1000001b,1000001b,1001001b,1001001b,0111110b,0000000b  ;"Э"29
           db    0000000b,1111111b,0001000b,0111110b,1000001b,1000001b,0111110b,0000000b  ;"Ю"30
           db    0000000b,1000110b,0101001b,0011001b,0001001b,0001001b,1111111b,0000000b  ;"Я"31
           db    0000000b,0000000b,0000000b,0000000b,0000000b,0000000b,0000000b,0000000b  ;"_"32
           db    0000000b,0000100b,0000010b,0000001b,0000100b,0000010b,0000001b,0000000b  ;" " "33
           db    0000000b,0000000b,0000000b,0110110b,0110110b,0000000b,0000000b,0000000b  ;":"34
           db    0000000b,0000000b,0000000b,1101111b,1101111b,0000000b,0000000b,0000000b  ;"!"35
           db    0000000b,0000000b,0000000b,0000000b,1000001b,0111110b,0000000b,0000000b  ;")"36
           db    0000000b,0000000b,0000000b,0000000b,0111110b,1000001b,0000000b,0000000b  ;"("37
           db    0000000b,0000000b,0000000b,1100000b,1100000b,0000000b,0000000b,0000000b  ;"."38
           db    0000000b,0001000b,0001000b,0001000b,0001000b,0001000b,0001000b,0000000b  ;"-"39
           db    0000000b,0001000b,0101010b,0011100b,1111111b,0011100b,0101010b,0001000b  ;"*"40
           db    0000000b,0000000b,1000001b,0100010b,0010100b,0001000b,0000000b,0000000b  ;">"41
           db    0000000b,0000000b,0001000b,0010100b,0100010b,1000001b,0000000b,0000000b  ;"<"42
           db    0000000b,0000000b,1000000b,0110110b,0010110b,0000000b,0000000b,0000000b  ;";"43
           db    0000000b,0000010b,0000001b,1101001b,1101001b,0001001b,0000110b,0000000b  ;"?"44
           db    0000000b,0000001b,0000010b,0000100b,0001000b,0010000b,0100000b,1000000b  ;"\"45
           db    1000000b,0100000b,0010000b,0001000b,0000100b,0000010b,0000001b,0000000b  ;"/"46
           db    0000000b,0000000b,1000000b,0110000b,0010000b,0000000b,0000000b,0000000b  ;";"47
           db    0000000b,0111110b,1010001b,1001001b,1000101b,0111110b,0000000b,0000000b  ;"0"48
           db    0000000b,0000000b,1000100b,1000010b,1111111b,1000000b,0000000b,0000000b  ;"1"49
           db    0000000b,1000010b,1100001b,1010001b,1001001b,1000110b,0000000b,0000000b  ;"2"50
           db    0000000b,0100010b,1000001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"3"51
           db    0000000b,0001100b,0001010b,0001001b,1111111b,0001000b,0000000b,0000000b  ;"4"52
           db    0000000b,1000111b,1000101b,1000101b,1000101b,0111001b,0000000b,0000000b  ;"5"53
           db    0000000b,0111100b,1000110b,1000101b,1000101b,0111000b,0000000b,0000000b  ;"6"54
           db    0000000b,1000001b,0100001b,0010001b,0001001b,0000111b,0000000b,0000000b  ;"7"55
           db    0000000b,0110110b,1001001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"8"56
           db    0000000b,0000110b,1001001b,0101001b,0011001b,0001110b,0000000b,0000000b  ;"9"57
Image1     db    111111b     ;0
           db    1100b       ;1
           db    1110110b    ;2
           db    1011110b    ;3
           db    1001101b    ;4
           db    1011011b    ;5
           db    1111011b    ;6
           db    1110b       ;7
           db    1111111b    ;8
           db    1011111b    ;9           
;-------------Инициализация параметров-----------------------------------------------------------------           
Init       PROC  NEAR
           mov   GoTime,0
           mov   GoTime1,0
           mov   Index,0        
           mov   Index1,0
           mov   IndexIndic,0
           mov   CheckIndic,0
           mov   si,0 
           mov   cx,14 
I:          
           mov   Memory[si],32
           inc   si
           inc   si
           dec   cx
           jcxz  I1
           jmp   I
I1:        
           mov   si,0 
           mov   cx,210
II:          
           mov   SchetMass[si],0
           inc   si
           dec   cx
           cmp   cx,0
           je    I2
           jmp   II
I2:           
           mov   ax,1b           ;индикатор
           out   098h,ax
           mov   TimeMassiv[0],49
           mov   TimeMassiv[2],48
           mov   TimeMassiv[4],34
           mov   TimeMassiv[6],48
           mov   TimeMassiv[8],48
           mov   TimeMassiv[10],48
           mov   TimeMassiv[12],48
           mov   TimeMassiv[14],34
           mov   TimeMassiv[16],48
           mov   TimeMassiv[18],48
           mov   Schet[0],48
           mov   Schet[2],48
           mov   Schet[4],48
           mov   Schet[6],48
           mov   HourDelay,0
           mov   MinuteDelay,0
           ret
Init       ENDP
;-------------Устранение дребезга---------------------------------------------------------------
VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;Сохранение исходного состояния
           mov   bh,0        ;Сброс счётчика повторений
VD2:       in    al,dx       ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   bh          ;Инкремент счётчика повторений
           cmp   bh,NMax     ;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных
           ret
VibrDestr  ENDP           
;--------------Ввод с клавиатуры----------------------------------------------------------------
KbdInput   PROC  NEAR
           lea   si,KbdImage         ;Загрузка адреса,
           mov   cx,LENGTH KbdImage  ;счётчика циклов
           mov   bl,0FEh             ;и номера исходной строки
KI4:       mov   al,bl       ;Выбор строки
           out   KbdPort,al  ;Активация строки
           in    al,KbdPort  ;Ввод строки
           and   al,11111111b      ;Включено?
           cmp   al,11111111b
           jz    KI1         ;Переход, если нет
           mov   dx,KbdPort  ;Передача параметра
           call  VibrDestr   ;Гашение дребезга
           mov   [si],al     ;Запись строки
KI2:       in    al,KbdPort  ;Ввод строки
           and   al,11111111b      ;Выключено?
           cmp   al,11111111b
           jnz   KI2         ;Переход, если нет
           call  VibrDestr   ;Гашение дребезга
           jmp   SHORT KI3
KI1:       mov   [si],al     ;Запись строки
KI3:       inc   si          ;Модификация адреса
           rol   bl,1        ;и номера строки
           loop  KI4         ;Все строки? Переход, если нет
           ret
KbdInput   ENDP
;-----------Контроль ввода с клавиатуры---------------------------------------------------------
KbdInContr PROC  NEAR
           lea   bx,KbdImage ;Загрузка адреса
           mov   cx,8        ;и счётчика строк
           mov   EmpKbd,0    ;Очистка флагов
           mov   KbdErr,0
           mov   dl,0        ;и накопителя
KIC2:      mov   al,[bx]     ;Чтение строки
           mov   ah,8        ;Загрузка счётчика битов
KIC1:      shr   al,1        ;Выделение бита
           cmc               ;Подсчёт бита
           adc   dl,0
           dec   ah          ;Все биты в строке?
           jnz   KIC1        ;Переход, если нет
           inc   bx          ;Модификация адреса строки
           loop  KIC2        ;Все строки? Переход, если нет
           cmp   dl,0        ;Накопитель=0?
           jz    KIC3        ;Переход, если да
           cmp   dl,1        ;Накопитель=1?
           jz    KIC4        ;Переход, если да
           mov   KbdErr,0FFh ;Установка флага ошибки
           jmp   SHORT KIC4
KIC3:      mov   EmpKbd,0FFh ;Установка флага пустой клавиатуры
KIC4:      ret
KbdInContr ENDP
;------------Преобразование очередной цифры-----------------------------------------------------
NxtSymBl  PROC  NEAR
           cmp   EmpKbd,0FFh ;Пустая клавиатура?
           jz    NSB5        ;Переход, если да
           cmp   KbdErr,0FFh ;Ошибка клавиатуры?
           jz    NSB5        ;Переход, если да
           jmp   SHORT NSB6
NSB5:      ret
NSB6:      lea   bx,KbdImage ;Загрузка адреса
           mov   dx,0        ;Очистка накопителей кода строки и столбца
NSB3:      mov   al,[bx]     ;Чтение строки
           and   al,11111111b      ;Выделение поля клавиатуры
           cmp   al,11111111b      ;Строка активна?
           jnz   NSB2        ;Переход, если да
           inc   dh          ;Инкремент кода строки
           inc   bx          ;Модификация адреса
           jmp   SHORT NSB3
NSB2:      shr   al,1        ;Выделение бита строки
           jnc   NSB4        ;Бит активен? Переход, если да
           inc   dl          ;Инкремент кода столбца
           jmp   SHORT NSB2
NSB4:      mov   cl,3        ;Формировние двоичного кода цифры
           shl   dh,cl
           or    dh,dl
           mov   dl,dh
           xor   dh,dh
           cmp   dx,40       ;кнопка Старт
           jne   Y8
           call  GoGame
           jmp   NSB1        
Y8:        cmp   dx,62       ;кнопка Next
           jne   Y6
           call  Next
           jmp   NSB1
Y6:        cmp   dx,63       ;кнопка Previous
           jne   Y7
           call  Previous
           jmp   NSB1
Y7:        cmp   dx,58       ; кнопка Сброс
           jne   Y1
           call  Init
           jmp   NSB1
Y1:        cmp   dx,60       ; кнопка <-
           jne   Y3
           call  GameSchet1
           jmp   NSB1
Y3:        cmp   dx,59       ; кнопка ->
           jne   Y4
           call  GameSchet2
           jmp   NSB1
Y4:        cmp   dx,61       ; кнопка OK
           jne   Y2
           inc   GoTime
           mov   Index,14
           cmp   GoTime,2
           jne    NSB1
           mov   ax,0b           ;индикатор
           out   098h,ax
           jmp   NSB1
Y2:        cmp   GoTime,0
           jne   Y5
           cmp   Index,12
           ja    Y5 
           mov   si, Index       ;Запись кода буквы в Memory
           mov   Memory[si], dx
           inc   si
           inc   si
           mov   Index, si
Y5:        cmp   GoTime,1
           jne   NSB1
           cmp   Index1,12
           ja    NSB1 
           mov   si, Index1       ;Запись кода буквы в Memory
           mov   Memory[si+14], dx
           inc   si
           inc   si
           mov   Index1, si
NSB1:      ret
NxtSymBl  ENDP
;------------Перевод памяти голов вперед-------------------------------------------------------------
Next        PROC  NEAR                
            cmp   GoTime,1
            jbe   Next1 
            mov   ax,CheckIndic
            cmp   IndexIndic,ax
            je    Next1
            inc   IndexIndic
            inc   IndexIndic
            inc   IndexIndic
            inc   IndexIndic
            inc   IndexIndic
Next1:      ret
Next        ENDP
;------------Начало игры-----------------------------------------------------------------
GoGame      PROC  NEAR                
            cmp   GoTime,1
            jbe   GoGame1
            mov   GoTime1,2
GoGame1:    ret
GoGame      ENDP
;------------Перевод памяти голов назад-------------------------------------------------------------
Previous        PROC  NEAR                
            cmp   GoTime,1
            jbe   Previous1
            cmp   IndexIndic,1
            jb    Previous1
            dec   IndexIndic
            dec   IndexIndic
            dec   IndexIndic
            dec   IndexIndic
            dec   IndexIndic
Previous1:  ret
Previous    ENDP
;------------Изменение счета 1-------------------------------------------------------------
GameSchet1        PROC  NEAR  
             cmp   GoTime1,1
             jbe   GameSch12              
             cmp   Schet[2],57
             jne   GameSch1
             inc   Schet[0]
             mov   Schet[2],47   
GameSch1:    inc   Schet[2]
             mov   ax,CheckIndic
             cmp   IndexIndic,ax
             je    GameSch13
             mov   IndexIndic,ax
GameSch13:   inc   IndexIndic
             inc   IndexIndic
             inc   IndexIndic
             inc   IndexIndic
             inc   IndexIndic
             mov   ax,IndexIndic
             mov   CheckIndic,ax
             call  GameSchetZap1
GameSch12:    ret
GameSchet1   ENDP
;------------Запись счета 1-------------------------------------------------------------
GameSchetZap1     PROC  NEAR  
             mov   si,IndexIndic
             mov   ax,TimeMassiv[18]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si+3],al
             mov   ax,TimeMassiv[16]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si+2],al
             mov   ax,TimeMassiv[12]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si+1],al
             mov   ax,TimeMassiv[10]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si],al
             mov   SchetMass[si+4],2
             ret
GameSchetZap1   ENDP
;------------Изменение счета 2-------------------------------------------------------------
GameSchet2        PROC  NEAR  
             cmp   GoTime1,1
             jbe   GameSch21              
             cmp   Schet[6],57
             jne   GameSch2
             inc   Schet[4]
             mov   Schet[6],47   
GameSch2:    inc   Schet[6]
             mov   ax,CheckIndic
             cmp   IndexIndic,ax
             je    GameSch23
             mov   IndexIndic,ax
GameSch23:   inc   IndexIndic
             inc   IndexIndic
             inc   IndexIndic
             inc   IndexIndic
             inc   IndexIndic
             mov   ax,IndexIndic
             mov   CheckIndic,ax
             call   GameSchetZap2
GameSch21:   ret
GameSchet2   ENDP
;------------Запись счета 2-------------------------------------------------------------
GameSchetZap2        PROC  NEAR  
             mov   si,IndexIndic
             mov   ax,TimeMassiv[18]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si+3],al
             mov   ax,TimeMassiv[16]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si+2],al
             mov   ax,TimeMassiv[12]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si+1],al
             mov   ax,TimeMassiv[10]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si],al
             mov   SchetMass[si+4],1
             ret
GameSchetZap2   ENDP
;------------Вывод текста------------------------------------------------------------------------
OutSymBl     PROC  NEAR                
           mov   up,0ah            
           mov   down,06Ah
           mov   left,03Ah
           mov   dex,0
           mov   ch,1      
M2:        mov   si,dex
           add   dex,2           
           mov   dx,Memory[si]
           mov   si,dx
           mov   cl,3
           shl   si,cl   
           mov   al,ch
           mov   dx,up
           out   dx,al
           inc   up    
           mov   cl,1                  
M1:        mov   al,0
           mov   dx,down
           out   dx,al        
           mov   al,Image[si]
           mov   dx,left
           out   dx,al        
           mov   al,cl
           mov   dx,down
           out   dx,al        
           inc   si
           shl   cl,1
           jnc   M1 
           inc   down
           inc   left
           cmp   left,47h
           jbe   M2
           ret
OutSymBl     ENDP 
;------------Изменение времени дня----------------------------------------------------------------------------
ClockTime        PROC  NEAR                
             cmp   GoTime,1
             jbe   CT
             inc   HourDelay
             cmp   HourDelay,1200
             jne   CT
             mov   HourDelay,0     
             inc   TimeMassiv[8]  
             cmp   TimeMassiv[8],58
             jne   CT
             mov   TimeMassiv[8],48
             inc   TimeMassiv[6]      
             cmp   TimeMassiv[6],54
             jne   CT
             mov   TimeMassiv[6],48
             inc   TimeMassiv[2]
             cmp   TimeMassiv[0],50
             jne   CT
             cmp   TimeMassiv[2],52
             jne   CT
             mov   TimeMassiv[2],48
             mov   TimeMassiv[0],48
             cmp   TimeMassiv[2],57
             jne   CT
             mov   TimeMassiv[2],48
             inc   TimeMassiv[0]
CT:          ret
ClockTime        ENDP
;------------Изменение времени игры----------------------------------------------------------------------------
ClockGame    PROC  NEAR                
             cmp   GoTime1,1
             jbe   CG
             inc   MinuteDelay
             cmp   MinuteDelay,20
             jne   CG
             mov   MinuteDelay,0
             inc   TimeMassiv[18]  
             cmp   TimeMassiv[18],58
             jne   CG
             mov   TimeMassiv[18],48
             inc   TimeMassiv[16]      
             cmp   TimeMassiv[16],54
             jne   CG
             mov   TimeMassiv[16],48
             inc   TimeMassiv[12]
             cmp   TimeMassiv[12],58
             jne   CG
             mov   TimeMassiv[12],48
             inc   TimeMassiv[10]                                  
CG:          ret
ClockGame    ENDP
;------------Вывод времени----------------------------------------------------------------------------
ClockMain       PROC  NEAR                
           cmp   GoTime,1
           jbe  ClockMainE 
           mov   up,0h           
           mov   down,60h
           mov   left,30h
           mov   dex,0
           mov   ch,1      
ClockMain2:mov   si,dex
           add   dex,2           
           mov   dx, TimeMassiv[si]
           mov   si,dx
           mov   cl,3
           shl   si,cl   
           mov   al,ch
           mov   dx,up
           out   dx,al
           inc   up    
           mov   cl,1                  
ClockMain1:mov   al,0
           mov   dx,down
           out   dx,al        
           mov   al,Image[si]
           mov   dx,left
           out   dx,al        
           mov   al,cl
           mov   dx,down
           out   dx,al        
           inc   si
           shl   cl,1
           jnc   ClockMain1 
           inc   down
           inc   left
           cmp   left,39h
           jbe   ClockMain2
ClockMainE:     ret
ClockMain       ENDP    
;------------Вывод счета игры------------------------------------------------------------
GameSchet      PROC  NEAR                
           cmp   GoTime,1
           jbe   GameScheta1 
           mov   up,18h           
           mov   down,78h
           mov   left,48h
           mov   dex,0
           mov   ch,1      
GameScheta12:
           mov   si,dex
           add   dex,2           
           mov   dx, Schet[si]
           mov   si,dx
           mov   cl,3
           shl   si,cl   
           mov   al,ch
           mov   dx,up
           out   dx,al
           inc   up    
           mov   cl,1                  
GameScheta11:
           mov   al,0
           mov   dx,down
           out   dx,al        
           mov   al,Image[si]
           mov   dx,left
           out   dx,al        
           mov   al,cl
           mov   dx,down
           out   dx,al        
           inc   si
           shl   cl,1
           jnc   GameScheta11 
           inc   down
           inc   left
           cmp   left,4Bh
           jbe   GameScheta12
GameScheta1:     ret
GameSchet        ENDP    
;------------Вывод индикаторов----------------------------------------------------------------
Indic        PROC  NEAR                
           mov   dx,1Ch
           mov   si,IndexIndic
           push  si
Indic2:    mov   al,SchetMass[si]
           out   dx,al
           inc   dx
           inc   si
           cmp   dx,1Fh
           jbe   Indic2
           mov   dx,97h
           pop   si
           mov   al,SchetMass[si+4]
           out   dx,al
Indic1:    ret
Indic        ENDP
;--------------------------------------------------------------------------------------
Start:     
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;---------------My program-------------------------------------------------------------
           call  Init
Time:
           call  ClockMain
           call  GameSchet
           call  ClockTime
           call  ClockGame
           call  KbdInput
           call  KbdInContr
           call  NxtSymBl
           call  OutSymBl
           call  Indic
           jmp   Time
;--------------------------------------------------------------------------------------
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end