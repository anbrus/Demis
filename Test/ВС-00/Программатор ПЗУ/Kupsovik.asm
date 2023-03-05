.286
RomSize    EQU   4096

Stk        SEGMENT AT 100h
           DW    20 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

Data       SEGMENT AT 0
KbdImage   DB    4 DUP(?)
EmpKbd     DB    ?
KbdErr     DB    ?
NextDig    DB    ?
KDisp      DB    ?

TipMS      db    ?           ;Тип МС 16 x 8 или 32 x 8
TipInp     db    ?           ;Тип ввода адрес или данные
Tipwork    db    ?           ;Тип работы - просмотр или программирование
ClearMS    db    ?           ;Флаг чистоты МС
Err        db    ?           ;Флаг ошибки
Adr        db    ?           ;Адрес
Dat        db    ?           ;Данные
OutPort    dw    ?           ;На какой индикатор выводим
PZU        db    32 dup (?)  ;Образ    ПЗУ
Buffer     db    32 dup (?)  ;Буфер данных

Data       ENDS

Code       SEGMENT use16
           ASSUME cs:Code,ds:Data,es:Data,ss:Stk

SymImages  DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h           
;Процедуры

Nach       PROC  NEAR
           mov   Adr,0
           mov   Dat,0
           mov   ClearMS,0
           mov   Err,0
           mov   TipMS,02h
           mov   al,TipMS
           out   8,al
           mov   Tipwork,02h
           mov   al,Tipwork
           out   10,al
           mov   ah,0
           mov   cx,32
           lea   bx,PZU
LpN:       mov   es:[bx],ah
           inc   bx
           Loop  LpN
           mov   cx,020h
           lea   bx,Buffer
LpF_1:     mov   es:[bx],0
           inc   bx
           Loop  LpF_1
           mov   TipInp,1
           mov   al,TipInp
           out   9,al
           mov   al,03Fh
           out   4,al
           out   5,al
           out   6,al
           out   7,al
           RET
Nach       ENDP

DELAY      PROC  NEAR
           PUSH  AX
           push  bx
           MOV   BX,06666h
           MOV   AX,0000h
M2:        INC   AX
           CMP   AX,BX
           JNE   M2
           MOV   AX,0000h
M3:        INC   AX
           CMP   AX,BX
           JNE   M3
           pop   bx
           POP   AX
           RET
DELAY      ENDP

KbdInput   PROC  NEAR
           lea   si,KbdImage         ;Загрузка адреса,
           mov   cx,LENGTH KbdImage  ;счётчика циклов
           mov   bl,01h             ;и номера исходной строки
KI4:       mov   al,bl       ;Выбор строки
           ;and   al,3Fh     ;Объединение номера с
           ;or    al,MesBuff ;сообщением "Тип ввода"
           out   3,al  ;Активация строки
           in    al,3  ;Ввод строки
           not   al
           and   al,0Fh      ;Включено?
           cmp   al,0Fh
           jz    KI1         ;Переход, если нет
           mov   dx,3  ;Передача параметра
         ;  call  VibrDestr   ;Гашение дребезга
           mov   [si],al     ;Запись строки
KI2:       in    al,3  ;Ввод строки
           not   al
           and   al,0Fh      ;Выключено?
           cmp   al,0Fh
           jnz   KI2         ;Переход, если нет
        ;   call  VibrDestr   ;Гашение дребезга
           jmp   SHORT KI3
KI1:       mov   [si],al     ;Запись строки
KI3:       inc   si          ;Модификация адреса
           rol   bl,1        ;и номера строки
           loop  KI4         ;Все строки? Переход, если нет
           ret
KbdInput   ENDP

KbdInContr PROC  NEAR
           lea   bx,KbdImage ;Загрузка адреса
           mov   cx,4        ;и счётчика строк
           mov   EmpKbd,0    ;Очистка флагов
           mov   KbdErr,0
           mov   dl,0        ;и накопителя
KIC2:      mov   al,[bx]     ;Чтение строки
           mov   ah,4        ;Загрузка счётчика битов
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

NxtDigTrf  PROC  NEAR
           ;cmp   EmpKbd,0FFh ;Пустая клавиатура?
           ;jz    NDT1        ;Переход, если да
           cmp   KbdErr,0FFh ;Ошибка клавиатуры?
           jz    NDT1        ;Переход, если да
           lea   bx,KbdImage ;Загрузка адреса
           mov   dx,0        ;Очистка накопителей кода строки и столбца
NDT3:      mov   al,es:[bx]     ;Чтение строки
           and   al,0Fh      ;Выделение поля клавиатуры
           cmp   al,0Fh      ;Строка активна?
           jnz   NDT2        ;Переход, если да
           inc   dh          ;Инкремент кода строки
           inc   bx          ;Модификация адреса
           jmp   SHORT NDT3
NDT2:      shr   al,1        ;Выделение бита строки
           jnc   NDT4        ;Бит активен? Переход, если да
           inc   dl          ;Инкремент кода столбца
           jmp   SHORT NDT2
NDT4:      mov   cl,2        ;Формировние двоичного кода цифры
           shl   dh,cl
           or    dh,dl 
           mov   NextDig,dh  ;Запись кода цифры
NDT1:      ret
NxtDigTrf  ENDP           
;Временная процедура
NumOut     PROC  NEAR
           ;cmp   KbdErr,0FFh
           ;jz    NO1
           cmp   EmpKbd,0FFh
           jz    NO1
           xor   ah,ah
           mov   al,NextDig
           lea   bx,SymImages
           add   bx,ax
           mov   al,cs:[bx]
           mov   dx,outPort
           out   DX,al
NO1:       ret
NumOut     ENDP

Displ      PROC  NEAR
pusha
           lea   bx,PZU
                      
           mov   ch,1        ;Indicator Counter
OutNextInd:
           mov   al,0
           out   1,al        ;Turn off cols
           mov   al,ch
           out   0,al        ;Turn on current matrix
           mov   cl,1        ;Col Counter
OutNextCol:
           mov   al,0
           out   1,al        ;Turn off cols
           mov   al,es:[bx]
           out   2,al        ;Set rows
           mov   al,cl
           out   1,al        ;Turn on current col
           
           shl   cl,1
           inc   bx
           jnc   OutNextCol
           shl   ch,1
           cmp   ch,010h
           jnz   OutNextInd
           mov   al,0
           out   0,al
           popa
           RET
Displ      ENDP

PrFor      PROC  NEAR
           mov   al,0
           out   0Bh,al
           mov   ClearMS,0
           mov   Adr,0
           mov   Dat,0
           mov   al,03Fh
           out   4,al
           out   5,al
           out   6,al
           out   7,al
           mov   Err,0
           mov   al,0
           out   0Ch,al
           mov   cx,020h
           lea   bx,Buffer
PF_1:      mov   es:[bx],0
           inc   bx
           Loop  PF_1 
           
           mov   al,0h
           out   0Dh,al   
                  
           
           RET
PrFor      ENDP

PrTipMS    PROC  NEAR
           in    al,8
           cmp   al,01h
           jnz   PTMS_1
           mov   TipMS,1
           mov   al,TipMS
           out   8,al
           mov   ah,0FFh
           mov   cx,010h
           lea   bx,PZU
LPTMS_1:   mov   es:[bx],ah
           inc   bx
           Loop  LPTMS_1
           mov   ah,0h
           mov   cx,010h
LPTMS_12:  mov   es:[bx],ah
           inc   bx
           Loop  LPTMS_12
           Call  PrFor
PTMS_1:    cmp   al,02h
           jnz   PTMS_2
           mov   TipMS,2
           mov   al,TipMS
           out   8,al
           mov   ah,0
           mov   cx,32
           lea   bx,PZU
LPTMS_2:   mov   es:[bx],ah
           inc   bx
           Loop  LPTMS_2
           Call  PrFor       
PTMS_2:    
                      
           RET
PrTipMS    ENDP

PrTestPZU  PROC  NEAR
           in    al,0Bh
           cmp   al,01h
           jnz   ErrEnd
           mov   ah,TipMS
           cmp   ah,01h
           jnz   PTPZU_1
           mov   cx,0Fh
           lea   bx,PZU
           mov   ax,0
LPTPZU_1:  add   ax,es:[bx]
           inc   bl
           loop  LPTPZU_1
           cmp   ax,0FFF1h
           jnz   PTPZU_11
           mov   ClearMS,1
           mov   al,01h
           jmp   EPTPZU
PTPZU_11:  mov   ClearMS,0
           mov   al,02h
           jmp   EPTPZU
PTPZU_1:   cmp   ah,02h
           jnz   PTPZU_2
           mov   cx,020h
           lea   bx,PZU
           mov   ah,0
LPTPZU_2:  add   ah,es:[bx]
           inc   bl
           loop  LPTPZU_2
           cmp   ah,0h
           jnz   PTPZU_22
           mov   ClearMS,1
           mov   al,01h
           jmp   EPTPZU
PTPZU_22:  mov   ClearMS,0
           mov   al,02h
           jmp   EPTPZU
PTPZU_2:   mov   al,01h
           out   0Ch,al
           mov   Err,1
           jmp   ErrEnd
EPTPZU:    out   0Bh,al
           
ErrEnd:    
           RET
PrTestPZU  ENDP

InpKeyb    PROC  NEAR
           mov   ah,TipInp
           cmp   ah,01h
           jnz   IKB_1
           call  KbdInput
           call  KbdInContr
           cmp   EmpKbd,0FFh
           jz    EIKB_1
           call  NxtDigTrf
           mov   ah,Adr
           and   ah,0Fh
           mov   al,TipMS
           dec   al
           cmp   ah,al
           jbe   IKB_3
           mov   ah,al
IKB_3:     shl   ah,04h
           add   ah,NextDig
           mov   adr,ah
           mov   OutPort,5
           call  NumOut
           mov   ah,Adr
           shr   ah,4
           mov   NextDig,ah
           mov   OutPort,4
           Call  NumOut
IKB_1:     
           cmp   ah,02h
           jnz   IKB_2
           call  KbdInput
           call  KbdInContr
EIKB_1:    cmp   EmpKbd,0FFh
           jz    EIKB
           call  NxtDigTrf
           mov   ah,Dat
           shl   ah,04h
           add   ah,NextDig
           mov   Dat,ah
           mov   OutPort,7
           call  NumOut
           mov   ah,Dat
           shr   ah,4
           mov   NextDig,ah
           mov   OutPort,6
           Call  NumOut
IKB_2:
EIKB:
           RET
InpKeyB    ENDP

AddBuffer  PROC  NEAR
           lea   bx,Buffer
           mov   al,Adr
           dec   al
           add   bl,al
           mov   al,Dat
           mov   es:[bx],al
           RET
AddBuffer  ENDP

PrChIn     PROC  NEAR
           mov   EmpKbd,0
           in    al,9
           mov   ah,al
PRCH_0:    in    al,9
           cmp   al,0
           jnz   PRCH_0
           mov   al,ah
           cmp   al,01h
           jnz   PRCH_1
           mov   TipInp,1
           mov   al,TipInp
           out   9,al
PRCH_1:    cmp   al,02h
           jnz   PRCH_2
           mov   TipInp,2
           mov   al,TipInp
           out   9,al
PRCH_2:    cmp   al,04h
           jnz   PRCH_3
           mov   al,Adr
           cmp   al,0
           jz    PRCH_4
           dec   al
           mov   Adr,al
           and   al,0Fh
           mov   NextDig,al
           mov   OutPort,5
           call  NumOut
           mov   al,Adr
           and   al,0F0h
           shr   al,4
           mov   NextDig,al
           mov   OutPort,4
           call  NumOut
           Call  AddBuffer
PRCH_3:    cmp   al,08h
           jnz   PRCH_4
           mov   al,TipMS
           mov   dl,0Fh
           mul   dl
           mov   ah,al
           dec   ah
           add   ah,TipMS
           mov   al,Adr
           cmp   al,ah
           jz    PRCH_4
           inc   al
           mov   Adr,al
           and   al,0Fh
           mov   NextDig,al
           mov   OutPort,5
           call  NumOut
           mov   al,Adr
           and   al,0F0h
           shr   al,4
           mov   NextDig,al
           mov   OutPort,4
           call  NumOut
           Call  AddBuffer
PRCH_4:    
           RET
PrChIn     ENDP

PrTipW     PROC  NEAR
           in    al,10
           mov   ah,al
PTW_2:     in    al,10
           cmp   al,0
           jnz   PTW_2
           cmp   ah,01h
           jnz   ETW
           mov   al,Tipwork
           cmp   al,01h
           jnz   PTW_1
           mov   Tipwork,02h
           jmp   ETW
PTW_1:     mov   Tipwork,01h
ETW:       mov   al,Tipwork
           out   10,al
           RET
PrTipW     ENDP

InsByte0   PROC  NEAR
           mov   al,TipMS
           sub   al,Dat
           cmp   al,02h
           jz    EIB
           lea   bx,PZU
           mov   ah,Adr
           add   bl,Adr
           mov   cx,8
           mov   ah,080h
LIB_1:     push  cx
           mov   al,Dat
           and   al,ah
           cmp   al,0
           jz    ELIB
           mov   dh,al
           mov   cx,0Fh
LIB_2:     Push  cx
           mov   dl,es:[bx]
           add   dl,dh
           mov   es:[bx],dl
           Call  Displ
           Call  Delay
           in    al,0Ah
           push  ax
PIB_1:     in    al,0Ah
           cmp   al,0
           jnz   PIB_1
           pop   ax
           cmp   al,02
           jnz   PIB_2
           pop   cx
           jmp   ELIB
PIB_2:     
           mov   dl,es:[bx]
           sub   dl,dh
           mov   es:[bx],dl
           Call  Displ
           Call  Delay
           pop   cx
           loop  LIB_2
           mov   Err,1
           mov   al,01
           out   0Ch,al
           pop   cx
           jmp   EIB
ELIB:      pop   cx
           shr   ah,1
           loop  LIB_1
EIB:       
           RET
InsByte0   ENDP

InsByte1   PROC  NEAR
           mov   al,TipMS
           sub   al,Dat
           cmp   al,02h
           jz    EIB1
           lea   bx,PZU
           mov   ah,Adr
           add   bl,Adr
           mov   cx,8
           mov   ah,080h
LIB_11:    push  cx
           mov   al,Dat
           not   al
           and   al,ah
           cmp   al,0
           jz    ELIB1
           mov   dh,al
           mov   cx,0Fh
LIB_21:    Push  cx
           mov   dl,es:[bx]
           sub   dl,dh
           mov   es:[bx],dl
           Call  Displ
           Call  Delay
           in    al,0Ah
           push  ax
PIB_11:    in    al,0Ah
           cmp   al,0
           jnz   PIB_11
           pop   ax
           cmp   al,02
           jnz   PIB_21
           pop   cx
           jmp   ELIB1
PIB_21:   
           mov   dl,es:[bx]
           add   dl,dh
           mov   es:[bx],dl
           Call  Displ
           Call  Delay
           pop   cx
           loop  LIB_21
           mov   Err,1
           mov   al,01
           out   0Ch,al
           pop   cx
           jmp   EIB
ELIB1:     pop   cx
           shr   ah,1
           loop  LIB_11
EIB1:       
           RET
InsByte1   ENDP

OutInd     PROC  NEAR
           mov   al,Adr
           and   al,0Fh
           mov   NextDig,al
           mov   OutPort,5
           call  NumOut
           mov   al,Adr
           and   al,0F0h
           shr   al,4
           mov   NextDig,al
           mov   OutPort,4
           call  NumOut
           mov   al,Dat
           and   al,0Fh
           mov   NextDig,al
           mov   OutPort,7
           call  NumOut
           mov   al,Dat
           and   al,0F0h
           shr   al,4
           mov   NextDig,al
           mov   OutPort,6
           call  NumOut
           RET
OutInd     ENDP

InsByte    PROC  NEAR
           lea   bx,PZU
           mov   al,Adr
           add   bl,al
           mov   ah,es:[bx]
           mov   al,TipMS
           sub   ah,al
           cmp   ah,0FEh
           jnz   EndInsByte
           
           mov   EmpKbd,00h
           Call  OutInd
           
           mov   al,tipMS
           cmp   al,01
           jnz   IB
           Call  InsByte1
           jmp   EndInsByte
IB:        Call  InsByte0
EndInsByte:
           RET
InsByte    ENDP

InsBuffer  PROC  NEAR
           mov   al,Dat
           mov   ah,Adr
           push  ax
           mov   al,TipMS
           cmp   al,01h
           jnz   InBuf_1
           mov   cx,010h
           jmp   InBuf_2
InBuf_1:   mov   cx,020h
InBuf_2:
           mov   dl,0h
           lea   bx,Buffer
LInBuf1:   
           mov   al,Err
           cmp   al,01h
           je    EBuf
           
           mov   ah,es:[bx]
           inc   bl
           mov   Dat,ah
           mov   Adr,dl
           inc   dl
           pusha
           Call  InsByte
           popa
           loop  LInBuf1
           
           mov   al,01h
           out   0Dh,al
EBuf:           
           pop   ax
           mov   Dat,al
           mov   Adr,ah
           
           

           RET
InsBuffer  ENDP

PrProg     PROC  NEAR
           
           Call  PrTipMS
           Call  Displ
           Call  PrTestPZU
           cmp   Err,01h
           je    MMET_3
           Call  PrChIn
           Call  InpKeyb
           in    al,0Bh
           mov   ah,al
MMET_1:    in    al,0Bh
           cmp   al,0
           jnz   MMET_1
           cmp   ah,040h
           jnz   MMET_2
           Call  InsByte
           jmp   MMET_3
MMET_2:    cmp   ah,080h
           jnz   MMET_3
           Call  InsBuffer
MMET_3:
           RET
PrProg     ENDP

PrProsm    PROC  NEAR
           Call  Displ
           Call  PrTestPZU
           mov   EmpKbd,0h
           in    al,09h
           mov   ah,al
PP_1:      in    al,09h
           cmp   al,0
           jnz   PP_1
           
           cmp   ah,04h
           jnz   PP_2
           mov   al,Adr
           cmp   al,0
           jz    PP_2
           dec   al
           mov   Adr,al
           and   al,0Fh
           mov   NextDig,al
           mov   OutPort,5
           call  NumOut
           mov   al,Adr
           and   al,0F0h
           shr   al,4
           mov   NextDig,al
           mov   OutPort,4
           call  NumOut
           mov   al,Adr
           lea   bx,PZU      ;
           add   bl,al       ;
           mov   al,es:[bx]  ;
           push  ax          ;
           and   al,0Fh      ;
           mov   NextDig,al  ;
           mov   OutPort,7   ;
           call  NumOut      ;
           pop   ax          ;
           and   al,0F0h     ;
           shr   al,4        ;
           mov   NextDig,al  ;
           mov   OutPort,6   ;
           call  NumOut      ;
PP_2:      cmp   ah,08h
           jnz   PP_3
           mov   al,TipMS
           mov   dl,0Fh
           mul   dl
           mov   ah,al
           dec   ah
           add   ah,TipMS
           mov   al,Adr
           cmp   al,ah
           jz    PP_3
           inc   al
           mov   Adr,al
           and   al,0Fh
           mov   NextDig,al
           mov   OutPort,5
           call  NumOut
           mov   al,Adr
           and   al,0F0h
           shr   al,4
           mov   NextDig,al
           mov   OutPort,4
           call  NumOut
           mov   al,Adr      ;
           lea   bx,PZU      ;
           add   bl,al       ;
           mov   al,es:[bx]  ;
           push  ax          ;
           and   al,0Fh      ;
           mov   NextDig,al  ;
           mov   OutPort,7   ;
           call  NumOut      ;
           pop   ax          ;
           and   al,0F0h     ;
           shr   al,4        ;
           mov   NextDig,al  ;
           mov   OutPort,6   ;
           call  NumOut      ;
                 
PP_3:
           RET
PRProsm    ENDP

Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop


           Call  Nach 
InfLoop:   Call  PrTipW
           mov   al,TipWork 
           cmp   al,02h
           jnz   InfMet_1
           Call  PrProg
           jmp   InfMet_2
InfMet_1:  
           Call  PrProsm
InfMet_2:  
           JMP   InfLoop


;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
