RomSize    EQU   4096
NMax       EQU   50          ; константа подавления дребезга
KbdPort    EQU   4           ; адреса портов

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
           Codebut           DW    ?        ; код цифры
           Index             Dw    ?        ; индекс эл-ов Memory     
           IndexTelT         DW    ?  
           IndexTelF         DW    ?  
           IndexTelA         DW    ? 
           IndexTelFind      DW    ?          
           dex               Dw    ?   
           dexf              Dw    ?   
           Memory            Dw    100 Dup(?)    
           constant          DW    ?        
           firstelout        DW    ?
           lastend           DW    ?    ; коорд. последн. ввода (послед эл.)
           lastfirst         DW    ?    ; коорд. последн. ввода (первый эл.)
           up                DW    ?    ; верхний порт
           down              DW    ?    ; нижний порт
           left              DW    ?    ; левый порт   
           variants          DB    ?    ; определение выбранного режима
           Family            DB    160 DUP(?)
           Telefon           DB    160 DUP(?)
           Adress            DB    160 DUP(?)
           Search            DB    8 DUP(?)
           searchs           DB    ?
           findfam           dw    ?
           fams              DB    ?
           tels              DB    ?
           adrs              DB    ?
           elementhom        DW    ?
           next              DW    ?
           lastindex         DW    ?
           delindex          DW    ?
           sohrF             DW    ?
           sohrT             DW    ?
           sohrA             DW    ?
           endmemory         DW    ?
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
           db    0000000b,0000000b,0000000b,1000010b,1111111b,1000000b,0000000b,0000000b  ;"1"49
           db    0000000b,1000010b,1100001b,1010001b,1001001b,1000110b,0000000b,0000000b  ;"2"50
           db    0000000b,0100010b,1000001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"3"51
           db    0000000b,0001100b,0001010b,0001001b,1111111b,0001000b,0000000b,0000000b  ;"4"52
           db    0000000b,1000111b,1000101b,1000101b,1000101b,0111001b,0000000b,0000000b  ;"5"53
           db    0000000b,0111100b,1000110b,1000101b,1000101b,0111000b,0000000b,0000000b  ;"6"54
           db    0000000b,1000001b,0100001b,0010001b,0001001b,0000111b,0000000b,0000000b  ;"7"55
           db    0000000b,0110110b,1001001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"8"56
           db    0000000b,0000110b,1001001b,0101001b,0011001b,0001110b,0000000b,0000000b  ;"9"57
Image2     db    03Fh,00Ch,076h
;-------------Устранение дребезга---------------------------------------------------------------------
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
;-------------Инициализация параметров-----------------------------------------------------------------           
Init       PROC  NEAR
          mov    lastend,34
          mov    lastfirst,0 
          mov    constant,34
          mov    firstelout,0       
          mov    Index,0         ; инициализация Memory
          mov    si,Index 
          mov    cx,46 
I:        mov    Memory[si],32
          add    si,2
          dec    cx
          jcxz   I1
          jmp    I
I1:       ret
Init       ENDP
;----------------------------------------------------------------------------
InitFind       PROC  NEAR
          mov    searchs,0
          mov    IndexTelFind,0         ; инициализация переменных для Search
          mov    si,IndexTelFind 
          mov    cx,8
IFI1:     mov    Search[si],40        ; инициализация Search
          inc    si
          dec    cx
          jcxz   IFI
          jmp    IFI1     
IFI:                     
          ret
InitFind       ENDP
;----------------------------------------------------------------------------
InitFTA       PROC  NEAR
          mov    al,00Ch     ;вкл. режим 1
          out    038h,al
	  mov	 Codebut,32
          mov    variants,0 
          mov    fams,0
          mov    adrs,0
          mov    tels,0  
          mov    elementhom,0   
          mov    next,1
          mov    endmemory,10
          mov    IndexTelF,0         ; инициализация Family
          mov    si,IndexTelF 
          mov    cx,160 
X:        mov    Family[si],32
          inc    si
          dec    cx
          jcxz   X1
          jmp    X
X1:       mov    IndexTelT,0         ; инициализация Telefon
          mov    si,IndexTelT 
          mov    cx,160 
X2:       mov    Telefon[si],32
          inc    si
          dec    cx
          jcxz   X3
          jmp    X2
X3:       mov    IndexTelA,0         ; инициализация Adress
          mov    si,IndexTelA 
          mov    cx,160 
X4:       mov    Adress[si],32
          inc    si
          dec    cx
          jcxz   X7
          jmp    X4
X7:       ret
InitFTA       ENDP
;--------------Ввод с клавиатуры-----------------------------------------------------------------------
KbdInput   PROC  NEAR
           lea   si,KbdImage         ;Загрузка адреса,
           mov   cx,LENGTH KbdImage  ;счётчика циклов
           mov   bl,0FEh             ;и номера исходной строки
KI4:       mov   al,bl       ;Выбор строки
           ;out   KbdPort,al  ;Активация строки
           out   044h,al
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
;-----------Контроль ввода с клавиатуры---------------------------------------------------------------------------
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
;------------Считыв. кода клавиши--------------------------------------------------------------------------
ReadCod    PROC  NEAR
           lea   bx,KbdImage ;Загрузка адреса
           mov   dx,0        ;Очистка накопителей кода строки и столбца
NST3:      mov   al,[bx]     ;Чтение строки
           and   al,11111111b      ;Выделение поля клавиатуры
           cmp   al,11111111b      ;Строка активна?
           jnz   NST2        ;Переход, если да
           inc   dh          ;Инкремент кода строки
           inc   bx          ;Модификация адреса
           jmp   SHORT NST3
NST2:      shr   al,1        ;Выделение бита строки
           jnc   NST4        ;Бит активен? Переход, если да
           inc   dl          ;Инкремент кода столбца
           jmp   SHORT NST2
NST4:      mov   cl,3        ;Формировние двоичного кода цифры
           shl   dh,cl
           or    dh,dl
           mov   dl,dh
           xor   dh,dh
	   mov	 Codebut,dx
	   ret	
ReadCod    ENDP
;------------Преобразование очередного символа(В режиме БЛОКНОТ)-------------------------------------------
NxtSymBl  PROC  NEAR
           cmp   EmpKbd,0FFh ;Пустая клавиатура?
           jz    Y7          ;Переход, если да
           cmp   KbdErr,0FFh ;Ошибка клавиатуры?
           jz    Y7          ;Переход, если да
           cmp   variants,0
           je    Y7
	   call	 ReadCod
	   mov	 dx,Codebut
	   jmp	 SHORT Y8	  
Y7:        ret
Y8:        cmp   dx,61       ; кнопка HOME
           jne   Y
           call  SelfParam
           mov   constant,18
           mov   firstelout,0  
           jmp   Y6
Y:         cmp   dx,60       ; кнопка <-           
           jne   Y1
           sub   Index,2    
           cmp   firstelout,0 
           jz    Y6
           sub   constant,2
           sub   firstelout,2  
           jmp   SHORT Y6
Y1:        cmp   dx,59       ; кнопка ->           
           jne   Y2
           cmp   Index,38
           je    Y6
           add   Index,2
           add   constant,2
           add   firstelout,2  
           jmp   SHORT Y6
Y2:        cmp   dx,58       ; кнопка END
           jne   Y3
           call  OutParam
           jmp   SHORT Y6
Y3:        cmp   dx,63       ; кнопка KILL
           jne   Y4
           call  Init
           jmp   SHORT Y6
Y4:        cmp   dx,62       ; кнопка DEL
           jne   Y5
           sub   Index,2
           mov   si, Index
           mov   Memory[si],32
           cmp   firstelout,0 
           jz    Y6
           sub   constant,2
           sub   firstelout,2  
           jmp   SHORT Y6
Y5:        cmp   Index,40
           je    Y6
           mov   si, Index       ;Запись кода буквы в Memory
           mov   Memory[si], dx
           inc   si
           inc   si
           mov   Index, si
Y6:        ret
NxtSymBl  ENDP
;--------------------------------------------------------------------------------------------------
Proced1 PROC  NEAR
           mov   dx,next
           mov   ax,dx
           mov   dx,16
           mul   dx
           mov   dx,ax
           ret
Proced1 ENDP
;------------Преобразование очередного символа(В режиме ТЕЛЕФОН. СПРАВОЧНИК)------------------------
NxtSymTel  PROC  NEAR
           cmp   EmpKbd,0FFh ;Пустая клавиатура?
           jz    NST11        ;Переход, если да
           cmp   KbdErr,0FFh ;Ошибка клавиатуры?
           jz    NST11        ;Переход, если да
           cmp   variants,1
           je    NST11
	   jmp	NST22	
NST11:      ret
NST22:	   call	 ReadCod
	   mov	 dx,CodeBut
           jmp   SHORT Q
OU:        ret
Q:         cmp   dx,61       ; кнопка HOME/FAM
           jne   Q1
           mov   fams,1
           mov   ax,1
           out   048h,ax
           mov   tels,0
           mov   adrs,0           
           jmp   SHORT NST11
Q1:        cmp   dx,58       ; кнопка END/TEL
           jne   Q2
           mov   tels,1
           mov   ax,10b
           out   048h,ax
           mov   adrs,0
           mov   fams,0           
           jmp   SHORT NST11
Q2:        cmp   dx,62       ; кнопка DEL/ADR
           jne   Q8
           mov   adrs,1
           mov   ax,100b
           out   048h,ax
           mov   fams,0
           mov   tels,0           
           jmp   SHORT OU
Q8:        cmp   dx,40       ; кнопка */DEL LAST SYMBOL          
           jne   Q11
           cmp   fams,1
           jne   QQQ1
           cmp   IndexTelF,0 
           je    Q9
           dec   IndexTelF
           mov   si, IndexTelF
           mov   Family[si],32
QQQ1:      cmp   tels,1
           jne   QQQ2
           cmp   IndexTelT,0 
           je    Q9
           dec   IndexTelT
           mov   si, IndexTelT
           mov   Telefon[si],32
QQQ2:      cmp   adrs,1
           jne   QQQ3
           cmp   IndexTelA,0 
           je    Q9
           dec   IndexTelA
           mov   si, IndexTelA
           mov   Adress[si],32
QQQ3:      jmp   SHORT Q9
Q9:        ret           
Q11:       cmp   dx,44       ; ПОИСК         
           jne   PEREHOD2
           cmp   tels,1
           je    PEREHOD2
           cmp   adrs,1
           je    PEREHOD2
           not   searchs
           cmp   searchs,0
           je   S1
           jmp   SHORT Q9
S1:       ;-------------------------
          ; FIND IN THIS PLACE BEGIN
          ;-------------------------
           mov   si,0
           mov   findfam,0
FIN1:      cmp   Search[0],40
           je    PEREHOD5     
           mov   dl,Family[si]
           cmp   Search[0],dl
           jne   PEREHOD6
           cmp   Search[1],40
           je    FIN3     
           mov   dl,Family[si+1]
           cmp   Search[1],dl
           jne   PEREHOD6
           cmp   Search[2],40
           je    FIN3     
           mov   dl,Family[si+2]
           cmp   Search[2],dl
           jne   FIN2
           cmp   Search[3],40
           je    FIN3     
           mov   dl,Family[si+3]
           cmp   Search[3],dl
           jne   FIN2
           jmp   SHORT PEREHOD3
PEREHOD5:  jmp   SHORT PEREHOD1           
PEREHOD2:  jmp   SHORT Q10           
PEREHOD6:  jmp   SHORT FIN2              
PEREHOD3:  cmp   Search[4],40
           je    FIN3     
           mov   dl,Family[si+4]
           cmp   Search[4],dl
           jne   FIN2
           cmp   Search[5],40
           je    FIN3     
           mov   dl,Family[si+5]
           cmp   Search[5],dl
           jne   FIN2
           cmp   Search[6],40
           je    FIN3     
           mov   dl,Family[si+6]
           cmp   Search[6],dl
           jne   FIN2
           cmp   Search[7],40
           je    FIN3     
           mov   dl,Family[si+7]
           cmp   Search[7],dl
           jne   FIN2
           jmp   SHORT PEREHOD4
PEREHOD1:  ret
PEREHOD4:
FIN3:      mov   elementhom,si
           mov   dx,findfam
           mov   next,dx
           inc   next
           mov   IndexTelF,si
           mov   IndexTelT,si
           mov   IndexTelA,si
           jmp   SHORT FIN
FIN2:      add   si,16
           inc   findfam
           cmp   si,160
           ja    FIN
           jmp   FIN1
          ;-------------------------
          ; FIND IN THIS PLACE END
          ;-------------------------
FIN:       call  InitFind
vihod:     ret           
Q10:       cmp   dx,63       ; кнопка KILL/DEL THIS STRING          
           jne   Q6
           
           dec  next
           call Proced1
           mov  si,dx
           mov  cx,16
Ochistka:
           mov  Family[si],32
           mov  Telefon[si],32
           mov  Adress[si],32
           inc  si
           ;dec  cx
           loop Ochistka
           inc  next
           mov  IndexTelF,dx
           mov  IndexTelT,dx
           mov  IndexTelA,dx
           mov  elementhom,dx
           mov  dx,63  
           ret                    
    
Q6:        cmp   dx,59       ; кнопка ->/NEXT           
           jne   Q7
           mov   dx,endmemory
           cmp   next,dx
           je    Q13
           call  Proced1
           mov   elementhom,dx
           mov   IndexTelF,dx
           mov   IndexTelT,dx
           mov   IndexTelA,dx
           inc   next
           jmp   SHORT Q13
Q13:       ret                
Q7:        cmp   dx,60       ; кнопка <-/BACK           
           jne   Q12
           cmp   next,1
           je    Q13
           dec   next
           call  Proced1
           sub   dx,16
           mov   elementhom,dx
           mov   IndexTelF,dx
           mov   IndexTelT,dx
           mov   IndexTelA,dx
           jmp   SHORT Q13            
Q12:       cmp   searchs,0FFh
           jne   Q5   
           mov   si, IndexTelFind       ;Запись кода буквы в Search
           mov   Search[si],dl 
           inc   si
           mov   IndexTelFind, si
           jmp   SHORT Q13
Q5:        cmp   fams,1
           jne   QQ1 
           mov   sohrF,dx
           call  Proced1
           cmp   dx, IndexTelF
           je   Vostparam1
           mov   dx,sohrF
           mov   si, IndexTelF       ;Запись кода буквы в Family
           mov   Family[si],dl 
           inc   si
           mov   IndexTelF, si
           jmp   SHORT NST7
Vostparam1: mov   dx,sohrF
           ret        
QQ1:       cmp   tels,1
           jne   QQ2 
           mov   sohrT,dx
           call  Proced1
           cmp   dx, IndexTelT
           je   Vostparam2
           mov   dx,sohrT
           mov   si, IndexTelT       ;Запись кода буквы в Telefon
           mov   Telefon[si],dl 
           inc   si
           mov   IndexTelT, si
           jmp   SHORT NST7
Vostparam2: mov   dx,sohrT
           ret        
QQ2:       cmp   adrs,1
           jne   NST7    
           mov   sohrA,dx
           call  Proced1
           cmp   dx, IndexTelA
           je   Vostparam3
           mov   dx,sohrA
           mov   si, IndexTelA       ;Запись кода буквы в Adress
           mov   Adress[si],dl 
           inc   si
           mov   IndexTelA, si
           jmp   SHORT NST7
Vostparam3: mov   dx,sohrA
           ret      
NST7:      ret
NxtSymTel  ENDP
;---------------------------------------------------------------------------
SelfParam     PROC  
           mov   cx,constant    ; сохраним коорд. последн. ввода (послед эл.) 
           mov   lastend,cx         
           mov   cx,firstelout    ; сохраним коорд. последн. ввода (первый эл.)
           mov   lastfirst,cx
           ret
SelfParam     ENDP        
;---------------------------------------------------------------------------
OutParam     PROC  
           mov   cx,lastend    ; востановить коорд. последн. ввода (послед эл.) 
           mov   constant,cx   
           mov   cx,lastfirst    ; востановить коорд. последн. ввода (первый эл.)
           mov   firstelout,cx
           ret
OutParam     ENDP        
;------------Вывод текста(В режиме БЛОКНОТ)----------------------------------------------------------------------------
OutSymBl     PROC  NEAR                
           cmp   variants,0
           je    OSB1
           jmp   OSB2
OSB1:      ret
OSB2:      mov   up,0000h            ;  инициализация портов вывода   
           mov   down,0020h
           mov   left,0010h
           mov   dx,firstelout    ; 0 первый эл-нт
           mov   dex,dx
           mov   dx,constant      ; 18 последний эл-нт котор. умещается в Memory
           cmp   Index,dx         ; если еще не введено 8 символов то М3   
           jne   M3               ; иначе смещ. на 2 старт. точку   
           add   constant,2
           add   firstelout,2
           mov   dx,firstelout
           mov   dex,dx          
M3:        mov   ch,1      
M2:        mov   si,dex
           add   dex,2           
           mov   dx, Memory[si]
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
           cmp   left,0020h
           jne   M2
ON:        ret
OutSymBl     ENDP    
;------------Вывод текста(В режиме ТЕЛЕФОН. СПРАВОЧНИК)---------------------------------------------------
OutSymTel     PROC  NEAR   
           cmp   variants,1
           je   OST1
           jmp   OST2
OST1:      ret
OST2:      mov   up,0h            ;  инициализация портов вывода   
           mov   down,20h
           mov   left,10h
N3:        cmp   searchs,0FFh     ; если вкл. режим поиска......
           je   FIND1
N5:        mov   dx,elementhom    ; 0 первый эл-нт
           mov   dex,dx
           mov   ch,1      
OT2:       mov   si,dex
           add   dex,1   
           cmp   fams,1
           jne   N1    
           mov   dl, Family[si]
           jmp   SHORT OT3
N1:        cmp   tels,1
           jne   N2    
           mov   dl, Telefon[si]
           jmp   SHORT OT3
N2:        cmp   adrs,1
           jne   N    
           mov   dl, Adress[si]
           jmp   SHORT OT3
OT3:       xor   dh,dh
           mov   si,dx
           mov   cl,3
           shl   si,cl   
           mov   al,ch
           mov   dx,up
           out   dx,al
           inc   up    
           mov   cl,1                  
OT1:       mov   al,0
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
           jnc   OT1 
           inc   down
           inc   left
           cmp   left,20h
           jne   OT2
N:         ret
FIND1:     mov   dexf,0
           mov   ch,1  
OTF2:      mov   si,dexf
           add   dexf,1   
           mov   dl, Search[si]
           xor   dh,dh
           mov   si,dx
           mov   cl,3
           shl   si,cl   
           mov   al,ch
           mov   dx,up
           out   dx,al
           inc   up    
           mov   cl,1                  
OTF1:      mov   al,0
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
           jnc   OTF1 
           inc   down
           inc   left
           cmp   left,18h
           jne   OTF2  
           ret
OutSymTel  ENDP    
;----------Сброс режима работы---------------------------------------------------------
Sbros     PROC  NEAR  
           in    al,1
           cmp   al,0FDh
           jne   TT1
           mov   variants,1
           mov   al,076h
           out   038h,al
TT1:       cmp   al,0FEh
           jne   TT
           mov   variants,0
           mov   al,00Ch
           out   038h,al
TT:        ret
Sbros      ENDP
;--------------------------------------------------------------------------------------
Start:     mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;---------------My program-------------------------------------------------------------
           call  Init
           call  InitFTA
           call  InitFind
M:         call  KbdInput
           call  KbdInContr
           call  NxtSymTel
           call  OutSymTel
           call  NxtSymBl             
           call  OutSymBl
           call  Sbros
           jmp    M
;--------------------------------------------------------------------------------------
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end 
