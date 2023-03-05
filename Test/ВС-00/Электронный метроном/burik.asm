RomSize    EQU   4096
NMax       EQU   50          ; константа подавления дребезга
KbdPort    EQU   99h           ; адреса портов

MaxLoopInProc   EQU         100    ; максимальное количество циклов в процедуре
StartTempo      EQU         100    ; стартовый темп в пр. реж.
StartTact       EQU         10     ; количество тактов в пр. реж.

;--------------Сегмент стека--------------------------------------------------------
Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS
;--------------Сегмент данных-------------------------------------------------------
Data       SEGMENT AT 0
      ;------------------------------- служебные данные
           KbdImage          DB    8 DUP(?)     ; единично-шестнадцатир. код очередн. введен. цифры(с клавы)
           EmpKbd            DB    ?            ; пустая клава
           KbdErr            DB    ?            ; ошибка клавы
           dex               DW    ?     
           up                DW    ?    ; верхний порт
           down              DW    ?    ; нижний порт
           left              DW    ?    ; левый порт   

       ;----------------------------- общие переменные
           ProgramMode       DB    ?            ; текущий режим программирования(1 - прогр., 0 - непрогр.)
           InitMode          DB    ?            ; текущий режим инициализации(1 - инициализация, 0 - нет)
           IsStarted         DB    ?            ; работаем или нет
           TickIndicator     DB    ?            ; маска индикатора
           CurrentTempo      DW    ?            ; текущий темп 
           DigitsTempo       DB    3 DUP(?)     ; текущий темп (отображаемые цифры)
           NameTempo         DW    3 Dup(?)     ; название текущего темпа
       ;----------------------------- переменные непрогр. реж.
           LoopInTickNPM     DW    ?            ; количество циклов в тике в непрогр. режиме
           LoopCounterNPM    DW    ?            ; текущее количество циклов в непрогр. режиме 
           Tempo             DW    ?            ; темп в непрогр. реж.
       ;----------------------------- пременные прогр. реж.
           EditTact          DB    ?            ; редактируем такт или нет
           LastPart          DW    ?            ; последняя часть
           CurrentPart       DW    ?            ; текущая часть
           CurrentTick       DW    ?            ; текущее количество тиков в текущей части
           LoopInTickPM      DW    ?            ; количество циклов в тике в прогр. режиме
           LoopCounterPM     DW    ?            ; текущее количество циклов в прогр. режиме 
           DigitsPart        DB    2 DUP(?)     ; текущая часть (отображаемые цифры)
           DigitsTact        DB    3 DUP(?)     ; количество тактов в текущей части (отображаемые цифры)
           TactPart          DW    99 DUP(?)    ; тактов в каждой части
           TempoPart         DW    99 DUP(?)    ; темпы в каждой части
           
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
           
           ; гасим индикаторы 
           mov   al,0
           out   51h,al
           
           ; сброс переменных
           mov   IsStarted,0           
           mov   InitMode,1
           mov   Tempo,150
           mov   CurrentTempo,150
           mov   ProgramMode,0
           mov   TickIndicator,0
           mov   LoopCounterNPM,0
           mov   LoopCounterPM,0
           mov   LastPart,1
           mov   CurrentPart,1
           mov   CurrentTick,0
           mov   EditTact,0

           ; заполняем массив тактов в пр. реж. нач. значениями
           mov   ax,StartTact
           mov   cx,99
           lea   di, TactPart
           cld
rep        stosw   

           ; заполняем массив темпов в пр. реж. нач. значениями
           mov   ax,StartTempo
           mov   cx,99
           lea   di, TempoPart
           cld
rep        stosw   

           ; считаем количество циклов в темпе в пр. реж.
           mov   ax,StartTempo
           call  CalcLoopInTick  
           mov   LoopInTickPM,ax
           
           ; считаем количество циклов в темпе в непр. реж.
           mov   ax,Tempo
           call  CalcLoopInTick  
           mov   LoopInTickNPM,ax
           
           ; готовим текстовое представление темпа
           call  MakeNameTempo              
           
           ;составить числовое представление темпа и показать темп
           mov   di,3
           mov   ax,CurrentTempo
           lea   bx, DigitsTempo
           call  MakeDigits
           call  ShowDigitsTempo
           
           ;составить числовое представление части
           mov   di,2
           mov   ax,LastPart
           lea   bx, DigitsPart
           call  MakeDigits
           
           ;составить числовое представление такта
           mov   di,3
           mov   ax,StartTact
           lea   bx,DigitsTact
           call  MakeDigits

           ; отображаем текущие режимы иниц., прогр., редактирования, часть, такт
           call  ShowInitMode           
           call  ShowProgramMode
           call  ShowEditMode
           call  ShowPart           
           call  ShowTact
                      
           ret
Init       ENDP

;------------- Мигнуть индикатором  -------------------------------------------------------------
Blink      PROC  NEAR
           
           push  ax
           push  cx
            
           ; выбираем индикатор, который будет светиться
           cmp   TickIndicator,01
           je    another_ind
           mov   TickIndicator,01
           jmp   b_ex
another_ind:           
           mov   TickIndicator,02
b_ex:     
           ; зажигаем индикатор
           mov   al,TickIndicator
           out   51h,al
          
           ; писк!
           mov   al,1
           mov   cx,100
           out   53h,al
           call  Delay
           mov   al,0
           out   53h,al            
           
           pop   cx
           pop   ax
           
           ret
Blink      ENDP

;------------- Задержка  -------------------------------------------------------------
Delay      PROC  NEAR
           ; IN  сx - количество циклов

           ; задержка на количество циклов, указанное в CX
EmptyCycle:
           nop
           nop
           nop
           loop  EmptyCycle
           
           ret
Delay      ENDP

;------------- Отсчитываем тики  -------------------------------------------------------------
DoTicks    PROC  NEAR
           cmp   IsStarted,1
           jne   p1
           push  cx
           push  ax
           push  bx
           
           
           cmp  ProgramMode,1
           je   do_pm
         
           ; НЕПРОГРАММИРУЕМЫЙ РЕЖИМ
check_blink:           
           ; проверяем, надо ли мигать в этом вызове
           cmp   LoopCounterNPM,MaxLoopInProc
           jle   dt_blink
           ; не надо мигать, делаем задержку 
           mov   cx,MaxLoopInProc
           sub   LoopCounterNPM,cx
           call  Delay           
           jmp   dt_ex
dt_blink:
           ; надо мигать, делаем задержку и мигаем
           mov   cx,LoopCounterNPM
           mov   ax, LoopInTickNPM
           mov   LoopCounterNPM, ax
           sub   LoopCounterNPM, cx
           call  Delay   
           call  Blink                            
           jmp   check_blink
p1:        jmp   p2 
           ; ПРОГРАММИРУЕМЫЙ РЕЖИМ
do_pm:           
           cmp   LoopCounterPM,MaxLoopInProc        ; сравниваем Счетчик_Циклов_ПМ и Макс_Количество_Циклов_В_Процедуре
           jle   dt_blinkpm                         ; если Счетчик_Циклов_ПрРеж <= Макс_Количество_Циклов_В_Процедуре, то пора мигнуть
           mov   cx,MaxLoopInProc
           sub   LoopCounterPM,cx                   ; Счетчик_Циклов_ПрРеж -= Макс_Количество_Циклов_В_Процедуре
           call  Delay                              ; задержка на Макс_Количество_Циклов_В_Процедуре
           jmp   dt_ex                              ; идем на выход
dt_blinkpm:                                         ; будем мигать
           mov   cx,LoopCounterPM                   ; cx = Счетчик_Циклов_ПрРеж
           mov   ax, LoopInTickPM
           mov   LoopCounterPM, ax                  ; Счетчик_Циклов_ПрРеж = Циклов_в_тике_ПрРеж
           sub   LoopCounterPM, cx                  ; Счетчик_Циклов_ПрРеж -= cx 
           call  Delay                              ; задержка на cx
           call  Blink                              ; мигнем
           inc   CurrentTick                        ; сделан еще один тик

           ; отображаем текущий такт
           mov  ax,CurrentTick
           mov  di,3
           lea  bx,DigitsTact
           call MakeDigits
           call ShowTact

           mov   bx,CurrentPart
           sal   bx,1
           mov   ax,TactPart[bx]                    ; ax = Количество_тиков_в_текущей_части
           cmp   CurrentTick,ax                     ; Количество_тиков_в_текущей_части и Текущее_количество_тиков
           jl    do_pm                              ; если Текущее_количество_тиков < Количество_тиков_в_текущей_части, то проверяем, не пора ли мигнуть
           inc   CurrentPart                        ; иначе переходим к след. части
           mov   ax,LastPart
           cmp   CurrentPart,ax                     ; Новая_Часть и Последняя_Часть
           jle   next_part                          ; если Новая_Часть <= Последняя_Часть, то обработкановой части
           call  StartButton                        ; иначе остановимся 
           mov   CurrentPart,1                      ; текщая_часть = 1
           mov   CurrentTick,0                      ; Текущий_Тик = 0
           mov   LoopCounterPM,0                    ; Счетчик_Циклов_ПрРеж = 0
           mov   ax,TempoPart[2]
           call  CalcLoopInTick
           mov   LoopInTickPM,ax                    ; Циклов_в_тике_ПрРеж с учетом темпа первой части
           jmp   dt_ex
next_part:                                          ; обработка след. части
           mov   CurrentTick,0                      ; Текущий_Тик = 0

           ; отображаем текущую часть
           mov  ax,CurrentPart
           mov  di,2
           lea  bx,DigitsPart
           call MakeDigits
           call ShowPart
           ; отображаем текущий такт
           mov  ax,CurrentTick
           mov  di,3
           lea  bx,DigitsTact
           call MakeDigits
           call ShowTact
           ; отображаем текущий темп
           mov  bx,CurrentPart
           sal  bx,1
           mov  ax,TempoPart[bx]
           mov  CurrentTempo,ax
           mov  di,3
           lea  bx,DigitsTempo
           call MakeDigits
           call ShowDigitsTempo
           call MakeNameTempo
           
           mov   bx,CurrentPart
           sal   bx,1
           mov   ax,TempoPart[bx]
           call  CalcLoopInTick
           mov   LoopInTickPM,ax                    ; Циклов_в_тике_ПрРеж с учетом темпа текущей части
           jmp   do_pm

dt_ex:           
           pop   bx
           pop   ax
           pop   cx
p2:        
           jmp   Time

           ret
DoTicks    ENDP

;------------- Посчитать количество циклов в тике  -----------------------------------------------                      
CalcLoopInTick   PROC  NEAR
           ; IN  ax - темп
           ; OUT ax - количество циклов
           
           push  dx
           push  cx
           
           mov   cx,ax
           mov   dx,3
           mov   ax,0FFFFh
           div   cx
           
           pop   cx
           pop   dx
           
           ret
           
CalcLoopInTick   ENDP

;------------- Отобразить режим редактирования --------------------           
ShowEditMode   PROC  NEAR
           ; режим редактирования - 0 - выкл, 1 - редактируем темп, 2 - редактируем такт

           push ax

           cmp  IsStarted,1
           jne  dis
           cmp  ProgramMode, 1
           jne  mode_1
           mov  al,0
           jmp  sem_ex
mode_1:
           mov  al,1
           jmp  sem_ex
mode_2:
           mov  al,2
           jmp  sem_ex

dis:
           cmp  ProgramMode,1
           jne  mode_1
           cmp  EditTact,1
           je   mode_2
           jne  mode_1           
           
sem_ex:
           out  70h,al
           
           pop  ax
           
           ret           
           
ShowEditMode   ENDP

;------------- Отобразить текущий режим программирования --------------------           
ShowProgramMode   PROC  NEAR
           
           push ax
           push cx
           
           mov  al,1
           mov  cl,ProgramMode
           sal  al,cl
           out  52h,al
       
           pop  cx
           pop  ax

           ret           
           
ShowProgramMode   ENDP

;------------- Отобразить часть ---------------------------------------------------------------------           
ShowPart       PROC  NEAR

           push ax
      
           cmp  ProgramMode,1
           jne  hide_part
           mov  al,DigitsPart[0]
           out  65h,al
           mov  al,DigitsPart[1]
           out  66h,al
           jmp  sp_exit    
hide_part:   
           mov  al,0
           out  65h,al
           out  66h,al
sp_exit:
           pop  ax
           
           ret
           
ShowPart       ENDP

;------------- Отобразить такт ---------------------------------------------------------------------           
ShowTact       PROC  NEAR

           push ax
      
           cmp  ProgramMode,1
           jne  hide_t
           mov  al,DigitsTact[0]
           out  67h,al
           mov  al,DigitsTact[1]
           out  68h,al
           mov  al,DigitsTact[2]
           out  69h,al
           jmp  st_ex    
hide_t:   
           mov  al,0
           out  67h,al
           out  68h,al
           out  69h,al
st_ex:
           pop  ax
           
           ret
           
ShowTact       ENDP

;------------- Отобразить текущий режим инициализации -----------------------------------------------           
ShowInitMode   PROC  NEAR
           
           push ax
           
           mov  al,InitMode
           out  50h,al
           
           pop  ax
           
           ret           
           
ShowInitMode   ENDP

;------------- Выбор имени темпа-----------------------------------------------------------------           
MakeNameTempo   PROC  NEAR

           cmp   CurrentTempo, 60
           jg    middle
           mov   NameTempo[0],12
           mov   NameTempo[2],05
           mov   NameTempo[4],04
           jmp   mnt_ex
middle:           
           cmp   CurrentTempo, 100
           jg    quick
           mov   NameTempo[0],17
           mov   NameTempo[2],16
           mov   NameTempo[4],4
           jmp   mnt_ex
quick:
           cmp   CurrentTempo, 200
           jg    vquick
           mov   NameTempo[0],01
           mov   NameTempo[2],27
           mov   NameTempo[4],17
           jmp   mnt_ex
vquick:
           mov   NameTempo[0],14
           mov   NameTempo[2],23
           mov   NameTempo[4],01
mnt_ex:       
           ret
MakeNameTempo   ENDP

;------------- Сделать цифровое представление числа -----------------------------------------------------------------           
MakeDigits   PROC  NEAR
           ; ax - число
           ; bx - массив
           ; di - количество цифр
           
           push   cx
           push   si
           push   dx
                                 
           ; zero all digits
           push   di
           mov    cx,di
           mov    dl, Image1[0]           
zero_cycle:
           dec    di           
           mov    bx[di],dl
           loop   zero_cycle
           pop    di

           ;make digits
           push   di
           push   ax
           mov    dl,10
           mov    cx,di
           
next_digit:           
           dec    di
           div    dl
           xchg   al,ah
           mov    si,ax
           and    si,000Fh
           mov    dh,Image1[si]
           mov    bx[di],dh                     
           and    ah,ah
           je     md_ex
           dec    cx
           cmp    cx,1
           je     last_digit
           xor    al,al
           xchg   al,ah
           jmp    next_digit
           
last_digit:
           xchg   al,ah
           mov    si,ax
           and    si,000Fh
           mov    dh,Image1[si]
           mov    [bx],dh                     
           
md_ex:
           pop    ax
           pop    di
           pop    dx
           pop    si                                 
           pop    cx
           
           ret
MakeDigits   ENDP

;------------Вывод названия темпа----------------------------------------------------------------------------
ShowNameTempo  PROC  NEAR                
           mov   up,0h           
           mov   down,20h
           mov   left,10h
           mov   dex,0
           mov   ch,1      
ClockMain2:mov   si,dex
           add   dex,2           
           mov   dx, NameTempo[si]
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
           cmp   left,18h
           jbe   ClockMain2
ClockMainE:     ret
ShowNameTempo       ENDP    

;------------Вывод цифр темпа----------------------------------------------------------------------------
ShowDigitsTempo     PROC   NEAR
           
           push    ax
           mov     al, DigitsTempo[0]
           out     60h, al
           mov     al, DigitsTempo[1]
           out     61h, al
           mov     al, DigitsTempo[2]
           out     62h, al
           pop     ax
           
           ret           
ShowDigitsTempo     ENDP

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
           
           cmp   dx,0       ;кнопка С
           jne   Y1
           
           call  Init
           jmp   NSB1        
           
y1:        cmp   dx,8       ;кнопка Старт
           jne   Y2
           
           call  StartButton
           jmp   NSB1
           
y2:        cmp   dx,1       ;кнопка +1
           jne   Y3
           
           mov   bl,1
           mov   bh,1
           call  Calculate
           jmp   NSB1
           
y3:        cmp   dx,2       ;кнопка +10
           jne   Y4
           
           mov   bl,10
           mov   bh,1
           call  Calculate
           jmp   NSB1

y4:        cmp   dx,3       ;кнопка rejim
           jne   Y5
           
           call  ChangeProgramMode
           jmp   NSB1
           
y5:        cmp   dx,9       ;кнопка -1
           jne   Y6
           
           mov   bl,1
           mov   bh,0
           call  Calculate
           jmp   NSB1
           
y6:        cmp   dx,10       ;кнопка -10
           jne   Y7

           mov   bl,10
           mov   bh,0
           call  Calculate
           jmp   NSB1
           
y7:        cmp   dx,11       ;кнопка temp
           jne   Y8
           
           call  ChangeTempoEdit           
           jmp   NSB1
           
y8:        cmp   dx,16       ;кнопка takt
           jne   Y9
           
           call  ChangeTactEdit           
           jmp   NSB1
           
y9:        cmp   dx,17       ;кнопка часть+1
           jne   nsb1
           
           call  NextPart
           jmp   NSB1
           
NSB1:      ret
NxtSymBl  ENDP

;------------ Старт - стоп -------------------------------------------------------------
StartButton PROC  NEAR
           
           cmp  IsStarted,1
           jne  enable
           mov  IsStarted,0
           mov  InitMode,1                
           cmp  ProgramMode,1
           je   sb_last
           jmp  sb_ex
           
enable:    
           ; включить
           mov  IsStarted,1     
           mov  InitMode,0
           cmp  ProgramMode,1
           jne  sb_ex
           ; отобразить текущую часть
           mov  ax,CurrentPart
           mov  di,2
           lea  bx,DigitsPart
           call MakeDigits
           call ShowPart
           ; отобразить текущий такт
           mov  ax,CurrentTick
           mov  di,3
           lea  bx,DigitsTact
           call MakeDigits
           call ShowTact
           ; отобразить текущий темп
           mov  bx,CurrentPart
           sal  bx,1
           mov  ax,TempoPart[bx]
           mov  CurrentTempo,ax           
           mov  di,3
           lea  bx,DigitsTempo
           call MakeDigits
           call ShowDigitsTempo
           call MakeNameTempo
           jmp  sb_ex
sb_last:
           ; отобразить посл. часть
           mov  ax,LastPart
           mov  di,2
           lea  bx,DigitsPart
           call MakeDigits
           call ShowPart
           ; отобразить количество тактов в посл. части
           mov  bx,LastPart
           sal  bx,1
           mov  ax,TactPart[bx]
           mov  di,3
           lea  bx,DigitsTact
           call MakeDigits
           call ShowTact
           ; отобразить темп в посл. части
           mov  bx,LastPart
           sal  bx,1
           mov  ax,TempoPart[bx]
           mov  CurrentTempo,ax           
           mov  di,3
           lea  bx,DigitsTempo
           call MakeDigits
           call ShowDigitsTempo
           call MakeNameTempo                      
sb_ex:
           ; отобразить режим редактирования и иниц.
           call ShowInitMode
           call ShowEditMode
           
           ret       
StartButton ENDP

;------------ Подсчет нового числа -------------------------------------------------------------
Calculate      PROC  NEAR
           ;IN
           ;    bl - число, которое надо прибавить или вычесть           
           ;    bh - 1 +, 0 -
           
           cmp  IsStarted,1
           jne  d1_notrunning           
           cmp  ProgramMode,1
           jne  ed_tempo
           ret
ed_tempo:  
           ; операция над темпом в непр. реж.         
           mov  ax,Tempo
           mov  dx,300
           cmp  bh,1
           je   op_tempo_1
           mov  dx,10
op_tempo_1:           
           call CheckRange
           mov  Tempo,ax
           mov  CurrentTempo,ax
           push ax
           call CalcLoopInTick  
           mov  LoopInTickNPM,ax
           pop  ax
           jmp  d1_showtempo
                                  
d1_notrunning:           
           cmp  ProgramMode,1
           je   d1_notrunning_1
           jmp  ed_tempo
d1_notrunning_1:
           cmp  EditTact,1
           je   d1_edittact
           ; операция над темпом в пр. реж.         
           mov  cx,bx
           mov  bx,LastPart
           sal  bx,1
           mov  ax,TempoPart[bx]
           push bx
           mov  bx,cx
           mov  dx,300
           cmp  bh,1
           je   op_tempo_2
           mov  dx,10
op_tempo_2:           
           call CheckRange
           pop  bx
           mov  TempoPart[bx],ax
           mov  CurrentTempo,ax

           mov   dx,LastPart
           cmp   CurrentPart,dx
           jne   d1_showtempo
           push  ax
           call  CalcLoopInTick  
           mov   LoopInTickPM,ax
           mov   LoopCounterPM,0
           pop   ax
           jmp   d1_showtempo
           
d1_edittact:
           ; операция над тактом в пр. реж.         
           mov  cx,bx
           mov  bx,LastPart
           sal  bx,1
           mov  ax,TactPart[bx]
           push bx
           mov  bx,cx
           mov  dx,999
           cmp  bh,1
           je   op_tact_1
           mov  dx,10
op_tact_1:           
           call CheckRange
           pop  bx
           mov  TactPart[bx],ax
           ; сделать такт и отобразить 
           lea  bx,DigitsTact
           mov  di,3
           call MakeDigits
           call ShowTact           
           jmp  d1_ex
                
d1_showtempo:           
           ; сделать темп и отобразить 
           lea   bx,DigitsTempo
           mov   di,3
           call  MakeDigits
           call  ShowDigitsTempo
           call  MakeNameTempo                                
d1_ex:
           ret       
Calculate      ENDP

;------------ Операция над числами -----------------------------------------------------------
CheckRange   PROC  NEAR
           ; IN: ax - число
           ;     bl - второе число
           ;     bh - 1 - добавить, 0 - вычесть
           ;     dx - граница
           ; OUT: ax - новое число, если не выходит за границу, иначе старое число 
           
           push  cx
           mov   cx,ax
           
           cmp   bh,1
           jne   cr_sub
           xor   bh,bh
           add   ax,bx
           cmp   ax,dx
           jle   cr_ex
           mov   ax,cx
           jmp   cr_ex 
cr_sub:
           xor   bh,bh
           sub   ax,bx
           cmp   ax,dx
           jge   cr_ex
           mov   ax,cx
           jmp   cr_ex 

cr_ex:
           pop   cx
           ret           
           
CheckRange   ENDP

;------------ Меняем режим программирования --------------------------------------------------------
ChangeProgramMode  PROC NEAR
           cmp  IsStarted,1
           je   cpm_ex
           mov  dx,0
           mov  ax,Tempo
           cmp  ProgramMode,1
           je   dis_pm
           mov  dl,1
           mov  bx,LastPart
           sal  bx,1
           mov  ax,TempoPart[bx]
dis_pm:
           mov  ProgramMode,dl
           ; отобразить реж. прогр., реж. редакт., часть, такт
           call ShowProgramMode
           call ShowEditMode
           call ShowPart
           call ShowTact
           ; сделать темп и отобразить 
           mov  CurrentTempo,ax
           lea  bx,DigitsTempo
           mov  di,3
           call MakeDigits
           call ShowDigitsTempo
           call MakeNameTempo
cpm_ex:
           ret       
ChangeProgramMode  ENDP

;------------ Меняем режим редактирования такта --------------------------------------------------------
ChangeTactEdit  PROC NEAR
           cmp  IsStarted,1
           je   cte_ex
           cmp  ProgramMode,0
           je   cte_ex
           cmp  EditTact,1
           je   cte_ex
           mov  EditTact,1
           call ShowEditMode
cte_ex:
           ret       
ChangeTactEdit  ENDP

;------------ Меняем режим редактирования темпа --------------------------------------------------------
ChangeTempoEdit  PROC NEAR
           cmp  IsStarted,1
           je   ctoe_ex
           cmp  ProgramMode,0
           je   ctoe_ex
           cmp  EditTact,0
           je   cte_ex
           mov  EditTact,0
           call ShowEditMode
ctoe_ex:
           ret       
ChangeTempoEdit  ENDP

;------------ Переход к след. части --------------------------------------------------------
NextPart  PROC NEAR
           cmp  IsStarted,1
           je   np_ex
           cmp  ProgramMode,0
           je   np_ex
           cmp  LastPart,99
           je   np_ex
           inc  LastPart
           ; сделать часть и отобразить 
           mov  ax,LastPart
           lea  bx,DigitsPart
           mov  di,2
           call MakeDigits
           call ShowPart
           ; сделать такт и отобразить 
           mov  ax,StartTact
           lea  bx,DigitsTact
           mov  di,3
           call MakeDigits
           call ShowTact
           ; сделать темп и отобразить 
           mov  ax,StartTempo
           mov  CurrentTempo,ax
           lea  bx,DigitsTempo
           mov  di,3
           call MakeDigits
           call ShowDigitsTempo
           call MakeNameTempo
np_ex:
           ret       
NextPart  ENDP

;--------------------------------------------------------------------------------------
Start:     
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;--------------- главный цикл -------------------------------------------------------------
           call  Init
Time:
           call  ShowNameTempo
           call  KbdInput
           call  KbdInContr
           call  NxtSymBl
           call  DoTicks
;--------------------------------------------------------------------------------------
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end