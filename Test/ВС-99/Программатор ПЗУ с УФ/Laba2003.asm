RomSize    EQU   4096
NMax       EQU   50
KbdPort    EQU   0

Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

Data       SEGMENT AT 0
KbdImage   DB    4 DUP(?)
EmpKbd     DB    ?
KbdErr     DB    ?
NextDig    DB    ?

Mode       DB    ?
ModeF      DB    ?
TypeIn     DB    ?
REC_Start  DB    ?
Inc_Addr   DB    ?
Dec_Addr   DB    ?
AddrDisp   DB    2 DUP (?)
DataDisp   DB    2 DUP (?)
Addr       DB    ?
PZU_Check  DB    ?
BufData    DB    ? 
REC_Err    DB    ?

OldModif   DB    ?
PZU_Mas    DB    20h DUP(?)
TrueImage  DB    8 DUP(?)
TKbPort    DW    ?
EmpTKbd    DB    ?
KbdTErr    DB    ?
NextCell   DB    ?
PZU_Seg    DB    ?
ProgCell   DB    ?
Er_PZU     DB    ?
REC_WT     DW    ?
REC_Buff   DB    ?
End_REC    DW    ?

SymImages  DB    16 DUP(?)      
Data       ENDS

Data2      SEGMENT AT 3000h
RAMData    DW    1024 DUP(?)
Data2      ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Data2,ss:Stk
           
  ;Образы 16-тиричных символов: "0", "1", ... "F"
;SymImages  DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
;           DB    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h
           
ModeIn     PROC  NEAR
           mov   Mode,0EBh
           mov   REC_Start,0
           mov   REC_Buff,0
           mov   Inc_Addr,0
           mov   Dec_Addr,0
               
           in    al,1
           mov   dx,1
           call  VibrDestr
            cmp   al,0FEh
           je   MI11
           cmp   al,0FCh
           je   MI11
           cmp   al,0FAh
           je   MI11
           cmp   al,0F6h
           je   MI11
           cmp   al,0EEh
           je   MI11           
           cmp   al,0DEh
           je   MI11
           cmp   al,0BEh
           je   MI11
           mov   Mode,0EBh
           jmp   short MI1          
MI11:      mov   Mode,0BEh                    
           jmp   short MI1                    
MI1:                                           
           cmp   al,0F7h
           je   CN11
           cmp   al,0F6h
           jne   CN1
CN11:      mov   al,08h
CN1:       cmp   al,0EFh   
           je   CN21
           cmp   al,0EEh
           jne   CN2
CN21:      mov   al,10h
CN2:       
           cmp   Mode,0EBh
           jne   MI2
           cmp   al,0FDh
           je    MI2
           cmp   al,0FBh
           jne   MI3
           mov   TypeIn,0BEh
           jmp   short MI3
MI2:       mov   TypeIn,0EBh           
MI3:       
           cmp   al,0DFh
           jne   MI6
           mov   REC_Start,0EBh          
MI6:       cmp   al,0BFh
           jne   MI7
           mov   REC_Start,0EBh
           mov   REC_Buff,0EBh
           
MI7:       mov   ah,OldModif
           mov   OldModif,al
           xor   al,ah
           and   al,ah
           cmp   al,0F7h
           je    MI41
           cmp   al,0F6h
           jne   MI4
MI41:      mov   Inc_Addr,0EBh 
MI4:       cmp   al,0EFh
           je    MI51
           cmp   al,0EEh
           jne   MI5
MI51:      mov   Dec_Addr,0EBh 
MI5:       cmp   al,0DFh
           jne   MIE
           mov   REC_Start,0EBh 
           
  MIE:     ret
ModeIn     ENDP           

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
           lea   si,KbdImage         ;Загрузка адреса,
           mov   cx,LENGTH KbdImage  ;счётчика циклов
           mov   bl,0FEh             ;и номера исходной строки
KI4:       mov   al,bl       ;Выбор строки
           ;and   al,3Fh     ;Объединение номера с
           ;or    al,MesBuff ;сообщением "Тип ввода"
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

DataForm   PROC  NEAR
           cmp   KbdErr,0FFh ;Пустая клавиатура?
           jnz   DFC        ;Переход, если да
           jmp   DFE           
DFC:       cmp   EmpKbd,0FFh ;Ошибка клавиатуры?
           jne   DFM1        ;Переход, если да
           mov   bl,Addr
           cmp   Inc_Addr,0EBh
           jne   DFM2
           cmp   bl,1fh
           je    DFM8
           inc   bl
           jmp   short DFM3
DFM8:      mov   bl,0h           
           jmp   short DFM3
DFM2:      cmp   Dec_Addr,0EBh
           jne   DFE           
           cmp   bl,0
           jne    DFM9
           mov   bl,1fh
           jmp   short DFM10
DFM9:      dec   bl
DFM10:     mov   Dec_Addr,0
DFM3:      cmp   Mode,0EBh
           jne   DFM4
           mov   dl,BufData
           mov   ax,0
           mov   al,Addr
           mov   si,ax
           mov   es:[si],dl
           jmp   DFM4
DFM1:      cmp   TypeIn,0EBh
           jne   DFM5           
           mov   bl,Addr
           mov   cl,4
           shl   bl,cl
           or    bl,Nextdig                      
           cmp   bl,1fh
           jbe   DFM7
           mov   bl,0      
DFM7:      jmp   short DFM3           
DFM4:      mov   bh,0
           mov   dl,es:[bx]
           mov   Addr,bl
           jmp   DFM6
DFM5:      mov   dl,BufData
           mov   cl,4
           shl   dl,cl
           or    dl,NextDig
DFM6:      mov   BufData,dl   
DFE:       ret
DataForm   ENDP

OutDForm   PROC  NEAR
           cmp   KbdErr,0ffh
           jz    ODFE
           mov   ax,[bx]
ODF1:      mov   dx,ax
           and   al,0fh
           mov   [si],al
           mov   ax,dx
           mov   cl,4
           shr   ax,cl
           inc   si
           dec   ch
           jnz   ODF1         
ODFE:      ret
OutDForm   ENDP

NumInfOut  PROC  NEAR
           cmp   KbdErr,0ffh
           jz    NIO2E
           lea   bx,SymImages
NIO21:     mov   al,[si]
           xlat
           out   dx,al
           inc   si
           inc   dx
           loop  NIO21
NIO2E:     ret
NumInfOut  ENDP

Lights     PROC  NEAR
           mov   al,0h
           cmp   Mode,0EBh
           je    LS1
           add   al,10h
LS1:       cmp   TypeIn,0EBh
           je    LS2
           add   al,02h 
           jmp   short LS3
LS2:       add   al,01h
LS3:       cmp   PZU_Check,0EBh
           jne   LS4
           add   al,04h
LS4:       cmp   REC_Err,0EBh
           jne   LSE
           add   al,08h
LSE:       out   5,al
           ret
Lights     ENDP

PZUClear   PROC  NEAR
           lea   bx,PZU_Mas
           mov   cx,20h
PC1:       cmp   byte ptr[bx],0
           jne   PC2
           inc   bx
           loop  PC1
           mov   PZU_Check,0EBh                      
           jmp   short PCE
PC2:       mov   PZU_Check,0BEh
PCE:       ret
PZUClear   ENDP

TimeDelay  PROC  NEAR
           mov   di,si
TD1:       mul   bh
           dec   di
           cmp   di,0
           jne   TD1           
           dec   si
           cmp   si,0
           jne   TD1      
           ret
TimeDelay  ENDP

PZU_TrKb   PROC  NEAR
           lea   si,TrueImage         ;Загрузка адреса,           
           mov   cx,LENGTH TrueImage  ;счётчика циклов
           mov   bl,0FEh             ;и номера исходной строки
PTK4:      mov   al,bl       ;Выбор строки
           mov   dx,di
           out   dx,al  ;Активация строки
           mov   dx,TKbPort
           in    al,dx  ;Ввод строки
           ;and   al,0Fh      ;Включено?
           cmp   al,0FFh;0Fh
           jz    PTK1         ;Переход, если нет
           mov   dx,TKbPort  ;Передача параметра
           call  VibrDestr   ;Гашение дребезга
           mov   [si],al     ;Запись строки
PTK2:      mov   dx,TKbPort
           in    al,dx  ;Ввод строки
           ;and   al,0Fh      ;Выключено?
           cmp   al,0FFh;0Fh
           jnz   PTK2         ;Переход, если нет
           call  VibrDestr   ;Гашение дребезга
           jmp   SHORT PTK3
PTK1:      mov   [si],al     ;Запись строки
PTK3:      inc   si          ;Модификация адреса
           rol   bl,1        ;и номера строки
           loop  PTK4         ;Все строки? Переход, если нет
           ret
PZU_TrKb   ENDP

PZU_KInC   PROC  NEAR
           lea   bx,TrueImage ;Загрузка адреса
           mov   cx,4        ;и счётчика строк
           mov   EmpTKbd,0    ;Очистка флагов
           mov   KbdTErr,0
           mov   dl,0        ;и накопителя
PKC2:      mov   al,[bx]     ;Чтение строки
           mov   ah,4        ;Загрузка счётчика битов
PKC1:      shr   al,1        ;Выделение бита
           cmc               ;Подсчёт бита
           adc   dl,0
           dec   ah          ;Все биты в строке?
           jnz   PKC1        ;Переход, если нет
           inc   bx          ;Модификация адреса строки
           loop  PKC2        ;Все строки? Переход, если нет
           cmp   dl,0        ;Накопитель=0?
           jz    PKC3        ;Переход, если да
           cmp   dl,1        ;Накопитель=1?
           jz    PKC4        ;Переход, если да
           mov   KbdTErr,0FFh ;Установка флага ошибки
           jmp   SHORT PKC4
PKC3:      mov   EmpTKbd,0FFh ;Установка флага пустой клавиатуры
PKC4:      ret
PZU_KInC   ENDP

PZU_NxtD   PROC  NEAR
           mov   EmpTKbd,0              
           cmp   KbdTErr,0FFh ;Ошибка клавиатуры?
           jz    PNDE        ;Переход, если да
           lea   bx,TrueImage
           mov   cx,1
           mov   di,cx
           mov   si,0
PND2:      cmp   byte ptr[bx],0FFh
           je    PND3
PND5:      mov   dx,255d
           sub   dx,di
           cmp   [bx],dl
           je    PND4
           shl   di,1
           inc   si
           cmp   si,8
           jne   PND5                         
PND3:      inc   bx
           inc   cx
           cmp   cx,9
           jne   PND2
           mov   EmpKbd,0FFh           
           jmp   short PNDE
PND4:      dec   cx
           mov   bx,0
           mov   bx,si
PND8:      cmp   cx,0
           je    PND7
PND6:      add   bx,8
           dec   cx
           jmp   short PND8
PND7:      mov   NextCell,bl
PNDE:      ret
PZU_NxtD   ENDP

PZU_Write  PROC  NEAR
           push  cx
           lea   bx,PZU_Mas
           mov   ax,cx
           mov   dl,8
           div   dl           
           mov   dl,ah
           mov   ah,0
           mov   si,ax      
           mov   al,00000001b
           mov   cl,dl
           shl   al,cl     
           mov   ah,es:[si]
           and   ah,al
           add   [bx+si],ah         
           pop   cx
           ret
PZU_Write  ENDP

I_Matrix   PROC  NEAR           
           lea   bx,PZU_Mas          
           mov   ch,0       
IMX2:      mov   cl,0

           mov   al,cl
           out   8,al
           
           mov   dl,cl                             
           mov   al,00000001b
IMX1:      mov   ah,[bx]
           and   ah,al
           shl   al,1
           add   dl,ah
           inc   cl
           cmp   cl,8
           jne   IMX1
               
           mov   al,ch           
           mov   ah,0           
           mov   dh,8
           div   dh            
           push  cx             
           mov   cl,al
           mov   ch,1
           shl   ch,cl
           mov   dh,ch
           mov   cl,ah
           mov   ch,1
           shl   ch,cl
           mov   ah,ch             
           pop   cx
           
           mov   al,dl
           out   7,al
           mov   al,ah
           out   6,al
           mov   al,dh
           out   8,al                 

           inc   bx
           inc   ch
           cmp   ch,32
           jne   IMX2

           ret
I_Matrix   ENDP

PZURecord  PROC  NEAR
           ;mov   REC_Err,0
           cmp   REC_Start,0EBh
           jne   PZR7
           cmp   REC_Buff,0EBh
           je    PZR8
           jmp   short PZR6
           ;cmp   REC_Err,0EBh
PZR7:      jmp   PRE           
PZR8:      mov   ax,0
           mov   dl,8
           mov   al,Addr
           mul   dl
           mov   cx,ax           
           mov   End_REC,cx
           add   End_REC,8
           jmp   short PZR9         
           
PZR6:      mov   cx,0
           mov   End_REC,32
PZR9:      mov   REC_Err,0
           mov   ProgCell,0
           mov   Er_PZU,0
           mov   bx,0
           mov   bl,Addr
           mov   al,BufData
           mov   es:[bx],al
                  

PZR1:      mov   ax,cx
           mov   bl,8
           div   bl
           mov   dx,ax
           mov   ah,0
           mov   al,dl
           div   bl
           
           push   cx
           mov   cl,al
           mov   al,1   
           shl   al,cl
           mov   cl,ah
           mov   ah,1
           shl   ah,cl
           mov   cl,dh
           mov   dh,1
           shl   dh,cl
           pop   cx
           
           push  ax
           push  dx
           mov   al,0
           out   8,al
          
           mov   si,0Eh  
           call  TimeDelay  
           
           pop   dx
           pop   ax
           push  ax
           mov   al,dh
           out   7,al
           mov   al,ah
           out   6,al
           pop   ax
           out   8,al
                               
           mov   REC_WT,0FFh 
PZR4:      push   cx           
           mov   ax,cx
           mov   bl,64d
           div   bl
           mov   PZU_Seg,al
           mov   cx,0
           mov   cl,PZU_Seg
           add   cl,2
           mov   TKbPort,cx
           add   cx,7
           mov   di,cx
                    
           call  PZU_TrKb
           call  PZU_KInC
           call  PZU_NxtD
           
           call I_Matrix        
                                      
           pop   cx
           mov   ax,cx
           mov   bl,64;4
           div   bl 
           cmp   NextCell,ah
           je    PZR2
           dec   REC_WT
           cmp   REC_WT,0
           jne   PZR4        
                    
           inc   Er_PZU
           cmp   Er_PZU,3
           je    PZR3
           jmp   PZR1
PZR3:      mov   REC_Err,0EBh
           jmp   short PRE
PZR2:      mov   Er_PZU,0
           mov   PZU_Check,0BEh
           call  PZU_Write
           inc   cx
           cmp   cx,End_REC
           jne   PZR5
           jmp   short PRE1
PZR5:      jmp   PZR1
         
PRE1:      call  Regen_Mem     
PRE:       mov   REC_Start,0BEh
           mov   REC_Buff,0BEh
           ret
PZURecord  ENDP

Regen_Mem  PROC  NEAR
           mov   si,0        
           lea   bx,PZU_Mas       
           cmp   REC_Buff,0EBh
           je    RM2
           mov   cx,20h
RM1:       mov   ax,[bx]
           mov   es:[si],ax
           inc   bx
           inc   si
           loop  RM1
           jmp   short RM4
RM2:       mov   cx,8h
           mov   dl,Addr
           mov   dh,0
           mov   di,dx
RM3:       mov   ax,[bx+di]
           mov   es:[di],ax
           inc   bx
           inc   si
           loop  RM3          
RM4:       lea   bx,PZU_Mas
           mov   dl,Addr
           mov   dh,0
           mov   di,dx
           mov   ax,[bx+di]
           mov   es:[di],ax
           lea   si,BufData
           mov   [si],ax                                                 
           ret
Regen_Mem  ENDP

Prepare    PROC  NEAR
           mov   KbdErr,0
           mov   TypeIn,0
           mov   Addr,0
           mov   TypeIn,0EBh
           mov   Mode,0BEh 
                     
           mov   SymImages[0],03Fh
           mov   SymImages[1],00Ch
           mov   SymImages[2],076h
           mov   SymImages[3],05Eh
           mov   SymImages[4],04Dh
           mov   SymImages[5],05Bh
           mov   SymImages[6],07Bh
           mov   SymImages[7],00Eh
           mov   SymImages[8],07Fh
           mov   SymImages[9],05Fh
           mov   SymImages[10],06Fh
           mov   SymImages[11],079h
           mov   SymImages[12],033h
           mov   SymImages[13],07Ch
           mov   SymImages[14],073h
           mov   SymImages[15],063h
           
           mov   cx,20h
           lea   bx,PZU_Mas
PPR1:      mov   byte ptr[bx],0
           inc   bx
           loop  PPR1                                                     
        
           mov   al,0
           mov   BufData,al

           lea   bx,DataDisp
           lea   si,AddrDisp
           mov   cl,2
PPR2:      mov   byte ptr[bx],0
           mov   byte ptr[si],0
           dec   bx
           dec   dx
           loop  PPR2

           mov   cx,400h
           lea   bx,RAMData
PPR3:      mov   byte ptr es:[bx],0
           inc   bx
           loop  PPR3

           ;mov   PZU_Mas[0],0B9h
           ;mov   PZU_Mas[8],023h
           ;mov   PZU_Mas[24],076h



           mov   OldModif,18h           
           ret
Prepare    ENDP


Start:
           mov   ax,Data2
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           
           call  Prepare           
           
InfLoop:   call  PZUClear
           call  ModeIn
           call  KbdInput
           call  KbdInContr
           call  NxtDigTrf
           call  DataForm
                                
           lea   bx,BufData
           lea   si,DataDisp
           mov   ch,2
           call OutDForm
           lea   bx,Addr
           lea   si,AddrDisp
           mov   ch,2
           call OutDForm                 
        
           mov   si,offset DataDisp
           mov   dx,3
           mov   cx,2
           call  NumInfOut
          
           mov   si,offset AddrDisp
           mov   dx,1
           mov   cx,2
           call  NumInfOut
           call  Lights        
        
           call  PZURecord
           call  I_Matrix
          
           jmp   InfLoop
 
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END
