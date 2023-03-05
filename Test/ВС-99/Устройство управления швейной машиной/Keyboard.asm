RomSize    EQU   4096
NMax       EQU   50
KbdPort    EQU   0

Stk        SEGMENT AT 100h
           DW    100 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

Data       SEGMENT AT 0
KbdImage   DB    3 DUP(?)
EmpKbd     DB    ?
KbdErr     DB    ?
NextDig    DB    ?
ShiftDiag  DB    ?
ShiftVert  DW    ?
KolPut     DW    ?
KolPut1    DB    ?
AdrPol     DW    ?
RomPicStr  DB    384 DUP (?)
Pointer    DB    ?
AddrMas    DW    ?
KodShva    DB    48 DUP  (?)
PolPr      DB    ?
Data       ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Code,ss:Stk

           ;Образы 16-тиричных символов: "0", "1", ... "F"
SymImages  DB    10h,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h
;рисунки
Cvetok     DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,030h,036h,01eh,078h,07ch,01ch,020h,040h,044h,028h,011h,0ah,034h,04h,00h
Zaec       DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,066h,066h,066h,066h,066h,066h,066h,07eh,042h,081h,0a5h,081h,099h,042h,03ch
Heart      DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,044h,0eeh,0bah,092h,0c6h,06ch,038h,010h,044h,0eeh,0bah,092h,0c6h,06ch,038h,010h
Gribi      DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0ch,01eh,03fh,03fh,0ch,0ch,0ch,02ch,07ch,02ch,02ch,00h
;Оригинальные швы
Or1        DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,01h,02h,04h,08h,010h,020h,040h,080h,080h,040h,020h,010h,08h,04h,02h,01h
Or2        DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,04h,08h,010h,020h,020h,010h,08h,04h,04h,08h,010h,020h,020h,010h,08h,04h
Or3        DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,02h,014h,028h,014h,02h,04h,08h,04h,02h,014h,028h,014h,02h,04h,08h,04h
Or4        DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,07h,025h,017h,08h,070h,052h,074h,08h,07h,025h,017h,08h,070h,052h,074h,08h
Or5        DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,08h,014h,022h,022h,022h,014h,08h,010h,08h,014h,022h,022h,022h,014h,08h,04h
;Декоративные швы
Dec1       DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,018h,018h,024h,042h,081h,042h,024h,018h,018h,018h,024h,042h,081h,042h,024h,018h
Dec2       DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,024h,024h,042h,099h,099h,042h,024h,024h,024h,024h,042h,099h,099h,042h,024h,024h
Dec3       DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,032h,04ah,086h,080h,086h,04ah,032h,02h,032h,04ah,086h,080h,086h,04ah,032h,02h
Dec4       DB    00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,040h,020h,018h,04h,062h,092h,0a2h,09ch,040h,020h,018h,04h,062h,092h,0a2h,09ch

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

KbdInput   PROC  NEAR
           cmp   PolPr,0FFh
           jz    K1
           lea   si,KbdImage         ;Загрузка адреса,
           mov   cx,LENGTH KbdImage  ;счётчика циклов
           mov   bl,0FEh             ;и номера исходной строки
KI4:       mov   al,bl       ;Выбор строки           
           out   KbdPort,al  ;Активация строки
           in    al,KbdPort  ;Ввод строки
           and   al,0Fh      ;Включено?
           cmp   al,0Fh
           jz    KI1         ;Переход, если нет
           mov   dx,KbdPort  ;Передача параметра
           call  VibrDestr   ;Гашение дребезга
           mov   [si],al     ;Запись строки
KI2:       in    al,KbdPort  ;Ввод строки
           and   al,0Fh      ;Выключено?
           cmp   al,0Fh
           jnz   KI2         ;Переход, если нет
           call  VibrDestr   ;Гашение дребезга
           jmp   SHORT KI3
KI1:       mov   [si],al     ;Запись строки
KI3:       inc   si          ;Модификация адреса
           rol   bl,1        ;и номера строки
           loop  KI4         ;Все строки? Переход, если нет
K1:        ret
KbdInput   ENDP

KbdInContr PROC  NEAR
           cmp   PolPr,0FFh
           jz    KIC4
           lea   bx,KbdImage ;Загрузка адреса
           mov   cx,3        ;и счётчика строк
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
           cmp   PolPr,0FFh
           jz    NDT1
           cmp   EmpKbd,0FFh ;Пустая клавиатура?
           jz    NDT1        ;Переход, если да
           cmp   KbdErr,0FFh ;Ошибка клавиатуры?
           jz    NDT1        ;Переход, если да
           lea   bx,KbdImage ;Загрузка адреса
           mov   dx,0        ;Очистка накопителей кода строки и столбца
NDT3:      mov   al,[bx]     ;Чтение строки
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

NumOut     PROC  NEAR
           cmp   PolPr,0FFh
           jz    NO2
           cmp   KbdErr,0FFh
           jz    NO2
           cmp   EmpKbd,0FFh
           jz    NO2
           xor   ah,ah
           xor   dx,dx
           mov   al,NextDig
           mov   dl,byte ptr [ShiftVert+1]
           cmp   al,4
           jz    l1
           cmp   al,6
           jz    l2
           cmp   al,9
           jz    l3
           cmp   al,1
           jz    l4
           jmp   NO2
l1:        mov   al,0
           out   5,al
           mov   al,ShiftDiag
           rol   al,1
           cmp   dl,0h
           jnz   l1_1   
           out   3,al
           mov   ShiftDiag,al
           jmp   NO2
l1_1:      out   5,al
           mov   ShiftDiag,al                    
           jmp   NO2           
NO2:       jmp   NO1
l2:        mov   al,0           
           out   5,al
           mov   al,ShiftDiag
           ror   al,1
           cmp   dl,0h
           jnz   l2_2   
           out   3,al
           mov   ShiftDiag,al
           jmp   NO1
l2_2:      out   5,al                    
           mov   ShiftDiag,al
           jmp   NO1
l3:        mov   ax,ShiftVert
           rol   ax,1
           out   2,al
           mov   ShiftVert,ax
           mov   ax,ShiftVert
           mov   al,ah
           out   4,al
           mov   al,ShiftDiag
           out   5,al
           out   3,al
           jmp   NO1
l4:        mov   ax,ShiftVert
           ror   ax,1
           out   2,al
           mov   ShiftVert,ax
           mov   ax,ShiftVert
           mov   al,ah
           out   4,al
           mov   al,ShiftDiag
           out   5,al
           out   3,al
           jmp   NO1
NO1:       ret
NumOut     ENDP

RisPic    PROC NEAR
           cmp   PolPr,0FFh
           jz    RP
           cmp   KbdErr,0FFh
           jz    RP
           cmp   EmpKbd,0FFh
           jz    RP
           xor   ah,ah
           xor   dx,dx
           xor   cx,cx
           mov   al,NextDig
           cmp   al,5
           jnz   RP
           mov   bx,AddrMas
           mov   cl,Pointer
           inc   cl
           mov   al,ShiftDiag
           mov   [bx],al  
           inc   bx
           mov   al,byte ptr [ShiftVert]
           mov   [bx],al
           inc   bx
           mov   al,byte ptr [ShiftVert+1]
           mov   [bx],al
           inc   bx
           mov   AddrMas,bx           
           mov   Pointer,cl           
RP:        ret
RisPic    ENDP

Delay      PROC  NEAR
           xor   si,si
           xor   di,di
D:         inc   si
           cmp   si,0ffffh
           jnz   D
           inc   di
           cmp   di,03h
           jnz   D           
           ret
Delay      ENDP

ProsmRom   PROC  NEAR
           cmp   PolPr,0FFh
           jz    PR
           cmp   KbdErr,0FFh
           jz    PR
           cmp   EmpKbd,0FFh
           jz    PR
           xor   ah,ah
           xor   dx,dx
           xor   cx,cx
           mov   al,NextDig
           cmp   al,0
           jnz   PR
           mov   ax,0fffh
           mov   cl,Pointer
           cmp   cl,0h
           jz    PR
           div   cx
           mov   dx,ax          
PR2:       mov   cl,Pointer
           lea   bx,RomPicStr           
PR1:       mov   al,0h
           out   2,al
           out   3,al
           out   4,al
           out   5,al
           mov   al,[bx+1]
           cmp   al,0h
           jz    PR3
           out   2,al
           mov   al,[bx]
           out   3,al
           jmp   PR4
PR3:       mov   al,[bx+2]
           out   4,al
           mov   al,[bx]
           out   5,al                  
PR4:       inc   bx
           inc   bx
           inc   bx
           loop   PR1
           dec   dx
           jnz   PR2
           mov   al,0h
           out   2,al
           out   3,al
           out   4,al
           out   5,al
           mov  al,ShiftDiag
           out  3,al
           out  5,al
           mov  al,byte ptr [ShiftVert]
           out  2,al
           mov  al,byte ptr [ShiftVert+1]
           out  4,al
PR:        ret           
ProsmRom   ENDP

DelMem     PROC  NEAR
           cmp   PolPr,0FFh
           jz    DM
           cmp   KbdErr,0FFh
           jz    DM
           cmp   EmpKbd,0FFh
           jz    DM
           xor   ah,ah
           xor   cx,cx
           mov   al,NextDig
           cmp   al,2
           jnz    DM           
           lea   bx,RomPicStr
           mov   cl,Pointer
DM2:       mov   al,[bx]
           cmp   al,ShiftDiag
           jnz   DM1           
           mov   al,[bx+1]
           cmp   al,byte ptr [ShiftVert]
           jnz   DM1           
           mov   al,[bx+2]
           cmp   al,byte ptr [ShiftVert+1]
           jnz   DM1
           mov   al,0h
           mov   [bx],al
           mov   [bx+1],al
           mov   [bx+2],al
           jmp   DM
DM1:       inc   bx
           inc   bx
           inc   bx
           loop  DM2           
DM:        ret
DelMem     ENDP

OutRis     PROC  NEAR
           cmp   PolPr,0FFh
           jz    ORis9
           cmp   KbdErr,0FFh
           jz    ORis9
           cmp   EmpKbd,0FFh
           jz    ORis9
           xor   ah,ah
           xor   cx,cx
           xor   dx,dx
           xor   si,si
           mov   al,NextDig           
           cmp   al,8
           jnz   ORis9
           mov  al,05h
           out  09h,al             
           lea   di,KodShva
           mov   cx,length KodShva                               
ORis4:     mov   al,0h
           mov   [di],al
           inc   di           
           loop  ORis4            
           lea   di,KodShva
           add   di,16           
           mov   dx,0001h           
ORis3:     lea   bx,RomPicStr           
           mov   cl,Pointer
           cmp   cl,0h
           jz    ORis      
ORis2:     mov   al,[bx+1]
           mov   ah,[bx+2]           
           cmp   ax,dx                                      
           jnz   ORis1
           mov   al,[bx]
           or    [di],al       
ORis1:     inc   bx
           inc   bx
           inc   bx           
           dec   cl         
           jnz   ORis2           
           inc   di
           shl   dx,1
           jnc   ORis3
           jmp   ORis8
ORis9:     jmp   ORis 
ORis8:     mov   dx,0h                      
ORis7:     mov   ah,01h           
           lea   bx,KodShva
           add   bx,dx
ORis6:     mov   al,ah
           out   6,al
           mov   dh,01h           
ORis5:     mov   al,[bx]
           out   8,al
           mov   al,dh
           out   7,al
           inc   bx
           shl   dh,1
           mov   al,0h
           out   8,al
           out   7,al
           jnc   ORis5          
           out   8,al
           out   7,al           
           shl   ah,1
           cmp   ah,4
           jnz   ORis6 
           inc   dx
           cmp   dx,32           
           mov   al,0h
           out   8,al
           out   7,al
           jz    ORis8                      
           call  Delay
           in   al,1
           cmp  al,0FEh 
           jnz  ORis7
           mov  al,0h
           out  09h,al  
           jmp   ORis                                                    
ORis:      ret
OutRis     ENDP

PromPis    PROC  NEAR
           cmp   PolPr,0FFh
           jz    PP4           
           push  ax
           push  bx
           push  dx
PP3:       mov  al,0h
           out  2,al
           out  3,al
           out  4,al
           out  5,al                             
           mov   bx,AdrPol
           add   bx,16
           mov dx,01h                   
PP1:       cmp  dl,0h
           jz   PP2 
           mov al,dl
           out  2,al           
           mov al,es:[bx]
           add bx,1
           out 3,al                      
           shl dx,1           
           mov  al,0h
           out  2,al
           out  3,al                    
           jmp  PP1
PP2:       mov  al,0h
           out  2,al
           out  3,al
           mov al,dh
           out  4,al           
           mov al,es:[bx]
           add bx,1
           out 5,al                      
           shl dx,1                    
           mov  al,0h
           out  4,al
           out  5,al
           cmp  dh,0h
           jnz   PP2           
           pop   dx
           pop   bx
           pop   ax
PP4:       ret
PromPis    ENDP


OutRisCop  PROC  NEAR
           cmp   PolPr,0h
           jz    ORisCop
           in   al,01h
           cmp  al,0F5h 
           jnz  ORisCop                      
ORisCop8:  mov   dx,0h                      
           mov  al,06h
           out  09h,al 
ORisCop7:  mov   ah,01h           
           mov   bx,AdrPol             
           add   bx,dx
ORisCop6:  mov   al,ah
           out   6,al
           mov   dh,01h           
ORisCop5:  mov   al,es:[bx]
           out   8,al
           mov   al,dh
           out   7,al
           inc   bx
           shl   dh,1
           mov   al,0h
           out   8,al
           out   7,al                  
           jnc   ORisCop5       
           out   8,al
           out   7,al           
           shl   ah,1           
           cmp   ah,4                       
           jnz   ORisCop6 
           call  PromPis
           inc   dx
           cmp   dx,32           
           mov   al,0h
           out   8,al
           out   7,al                 
           jz    ORisCop8                      
           call  Delay
ORisCop1:  in   al,01h
           cmp  al,0Fdh 
           jnz  ORisCop7
           mov  al,02h
           out  09h,al  
           jmp   ORisCop
ORisCop:   ret
OutRisCop  ENDP


Bech       PROC  NEAR
           mov   ax,0
           mov   Pointer,al           
           mov   KbdErr,0
           mov   KolPut,ax
           mov   KolPut1,al
           xor   ax,ax
           mov   al,01h
           out   2,al
           out   3,al                 
           mov   ShiftDiag,al
           mov   ShiftVert,ax           
           ret
Bech       ENDP
  

ProsmRis   PROC  NEAR
           cmp   PolPr,0h
           jz    PrR9           
           push  AddrMas
           xor   ax,ax
           mov   al,Pointer
           push  ax             
PrR3:      mov  al,0h
           out  2,al
           out  3,al
           out  4,al
           out  5,al                               
           mov   bx,AdrPol
           add   bx,16
           mov dx,01h                   
PrR1:      cmp  dl,0h
           jz   PrR2 
           mov al,dl
           out  2,al           
           mov al,es:[bx]
           add bx,1
           out 3,al                      
           shl dx,1           
           mov  al,0h
           out  2,al
           out  3,al                    
           jmp  PrR1
PrR7:      jmp  PrR3
PrR2:      mov  al,0h
           out  2,al
           out  3,al
           mov al,dh
           out  4,al           
           mov al,es:[bx]
           add bx,1
           out 5,al                      
           shl dx,1                    
           mov  al,0h
           out  4,al
           out  5,al
           cmp  dh,0h
           jnz   PrR2
           in    al,01h
           cmp   al,0f9h
           jnz   PrR4
           mov  al,0h
           out  2,al
           out  3,al
           out  4,al
           out  5,al
           inc  KolPut1
           jmp  PrR10
PrR9:      jmp  PrR8     
PrR10:     mov  al,12           
           cmp   KolPut1,al
           jz    PrR6 
           xor   ax,ax           
           mov   al,32
           add   AdrPol,ax           
           call  Delay
           jmp   PrR3
PrR6:      lea   bx,Cvetok           
           mov   AdrPol,bx
           xor   ax,ax
           mov   KolPut1,al
           call  Delay               
           jmp   PrR3
PrR4:      call  OutRisCop  
           in   al,01h
           cmp  al,0FFh 
           jnz   PrR7                                      
           pop   ax
           mov   Pointer,al
           pop   AddrMas
           mov  al,ShiftDiag
           out  3,al
           out  5,al
           mov  al,byte ptr [ShiftVert]
           out  2,al
           mov  al,byte ptr [ShiftVert+1]
           out  4,al
PrR8:      ret
ProsmRis   ENDP

Obnul      PROC NEAR           
           mov   al,03h           
           out   1,al           
           ret
Obnul      ENDP

DelAll    PROC  NEAR
           cmp   PolPr,0FFh
           jz    DA
           cmp   KbdErr,0FFh
           jz    DA
           cmp   EmpKbd,0FFh
           jz    DA           
           mov   al,NextDig           
           cmp   al,10
           jnz   DA
           xor   al,al
           mov   Pointer,al
           lea   ax,RomPicStr           
           mov   AddrMas,ax
           mov   ax,0h
           out   3,al
           out   2,al
           mov   al,ah
           out   4,al
           mov   ax,01h
           mov   ShiftDiag,al
           mov   ShiftVert,ax
           out   3,al
           out   2,al
           mov   al,ah
           out   4,al                                            
DA:        ret
DelAll     ENDP

Prov       PROC  NEAR
           in    al,01h
           cmp   al,0fdh
           jnz   P
           mov   PolPr,0ffh
           mov   al,02h  
           out   09h,al
           jmp   P1 
P:         mov   PolPr,0h
           mov   al,01h
           out   09h,al
P1:        ret
Prov       ENDP

Start:
           mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           call  Bech           
           lea   ax,RomPicStr           
           mov   AddrMas,ax        
InfLoop:   call  Prov           
           call  KbdInput
           call  KbdInContr
           call  NxtDigTrf
           call  NumOut
           mov   cl,Pointer
           call  RisPic           
           call  ProsmRom
           call  DelMem           
           call  OutRis
           call  DelAll
           call  Obnul            
           lea   bx,Cvetok
           mov   AdrPol,bx
           call  ProsmRis          
           jmp   InfLoop 
           
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END


;Рисунки: 
;Заяц:00h,066h,066h,066h,066h,066h,066h,066h,07eh,042h,081h,0a5h,081h,099h,042h,03ch

;Цветок:00h,030h,036h,01eh,078h,07ch,01ch,020h,040h,044h,028h,011h,0ah,034h,04h,00h

;Сердечки:044h,0eeh,0bah,092h,0c6h,06ch,038h,010h,044h,0eeh,0bah,092h,0c6h,06ch,038h,010h

;Грибы:00h,00h,00h,00h,0ch,01eh,03fh,03fh,0ch,0ch,0ch,02ch,07ch,02ch,02ch,00h

;Оригинальные швы:

;1:01h,02h,04h,08h,010h,020h,040h,080h,080h,040h,020h,010h,08h,04h,02h,01h

;2:04h,08h,010h,020h,020h,010h,08h,04h,04h,08h,010h,020h,020h,010h,08h,04h

;3:02h,014h,028h,014h,02h,04h,08h,04h,02h,014h,028h,014h,02h,04h,08h,04h

;4:07h,025h,017h,08h,070h,052h,074h,08h,07h,025h,017h,08h,070h,052h,074h,08h

;5:08h,014h,022h,022h,022h,014h,08h,010h,08h,014h,022h,022h,022h,014h,08h,04h

;Декоративные швы:

;1:018h,018h,024h,042h,081h,042h,024h,018h,018h,018h,024h,042h,081h,042h,024h,018h

;2:024h,024h,042h,099h,099h,042h,024h,024h,024h,024h,042h,099h,099h,042h,024h,024h

;3:032h,04ah,086h,080h,086h,04ah,032h,02h,032h,04ah,086h,080h,086h,04ah,032h,02h

;4:040h,020h,018h,04h,062h,092h,0a2h,09ch,040h,020h,018h,04h,062h,092h,0a2h,09ch

;00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h

