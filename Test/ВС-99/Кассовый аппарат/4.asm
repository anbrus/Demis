RomSize    EQU   4096
NMax       EQU   50          ; константа подавления дребезга
KbdPort    EQU   7           ; адреса портов
;constperenos  EQU    8
;firstelout     EQU    0         
;--------------Сегмент стека--------------------------------------------------------
Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS
;--------------Сегмент данных-------------------------------------------------------
Data       SEGMENT AT 0
           KbdImage   DB    8 DUP(?)    ; единично-шестнадцатир. код очередн. введен. цифры(с клавы)
           EmpKbd     DB    ?        ; пустая клава
           KbdErr     DB    ?        ; ошибка клавы
           Codebut    DW    ?        ; код цифры
           Index      Dw     ?        ; индекс эл-ов Memory 
           Index1      Dw     ? 
           dex        Dw     ?
           Memory     Dw     6 Dup(?)   
           Memory1    Dw     6 Dup(?)   
           Memory2    Dw     6 Dup(?) 
           Mem DW 5 Dup(?)
           Sum1       DW ?
           Sum2       Dw 5 Dup (?)          
           Sum3       DW ?
           Sum5       Dw 5 Dup (?)
           constant   DW     ?        
           firstelout        DW    ?
           set        dw     ?    
           mask       db     ?
           mask1      db   ? 
           sec        dw ?
           sec1       dw ?
           min        dw ?
           min1       dw ?
           AS DW ?
Data       ENDS
;---------------Сегмент кода---------------------------------------------------------
Code       SEGMENT
           ASSUME cs:Code,ds:Data,ss:Stk
;------------------------------------------------------------------------------------
Im         db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh
Image      db    0000000b,0111110b,1000001b,1000001b,1000001b,0111110b,0000000b,0000000b  ;"0"48
           db    0000000b,0000000b,1000100b,1111111b,1000000b,0000000b,0000000b,0000000b  ;"1"49
           db    0000000b,1000010b,1100001b,1010001b,1001001b,1000110b,0000000b,0000000b  ;"2"50
           db    0000000b,0100010b,1000001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"3"51
           db    0000000b,0001100b,0001010b,0001001b,1111111b,0001000b,0000000b,0000000b  ;"4"52
           db    0000000b,1000111b,1000101b,1000101b,1000101b,0111001b,0000000b,0000000b  ;"5"53
           db    0000000b,0111100b,1000110b,1000101b,1000101b,0111000b,0000000b,0000000b  ;"6"54
           db    0000000b,1000001b,0100001b,0010001b,0001001b,0000111b,0000000b,0000000b  ;"7"55
           db    0000000b,0110110b,1001001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"8"56
           db    0000000b,0000110b,1001001b,0101001b,0011001b,0001110b,0000000b,0000000b  ;"9"57
           db    0000000b,0000000b,0000000b,1100000b,1100000b,0000000b,0000000b,0000000b  ;"."38
           
Inn        db    0000000b,1000001b,0100001b,0010001b,0001001b,0000111b,0000000b;
           db    0000000b,1000111b,1000101b,1000101b,1000101b,0111001b,0000000b; 
           db    0000000b,0000110b,1001001b,0101001b,0011001b,0001110b,0000000b;
           db    0000000b,0000110b,1001001b,0101001b,0011001b,0001110b,0000000b;
           db    0000000b,0000110b,1001001b,0101001b,0011001b,0001110b,0000000b;
           db    0000000b,0000000b,0000000b,1100000b,1100000b,0000000b,0000000b,0000000b  ;"."38
           
AO         db    00000000b,01111100b,00010010b,00010010b,01111110b,00000000b,00000000b;
           db    01111110b,00000100b,00001000b,00000000b,00001100b,01111110b,00000000b;
           db    00000000b,01111110b,01000010b,01000010b,01100110b,00000000b,00000000b;
;-------------Устранение дребезга---------------------------------------------------------------------
;VibrDestr  PROC  NEAR
;VD1:       mov   ah,al       ;Сохранение исходного состояния
;           mov   bh,0        ;Сброс счётчика повторений
;VD2:       in    al,dx       ;Ввод текущего состояния
;           cmp   ah,al       ;Текущее состояние=исходному?
;           jne   VD1         ;Переход, если нет
;           inc   bh          ;Инкремент счётчика повторений
;           cmp   bh,NMax     ;Конец дребезга?
;           jne   VD2         ;Переход, если нет
;           mov   al,ah       ;Восстановление местоположения данных
;           ret
;VibrDestr  ENDP           
;-------------Инициализация параметров-----------------------------------------------------------------           
Init       PROC  NEAR
          mov constant,18
          mov firstelout,0          
          mov Index,0 
          mov si,Index
          mov Index1,0
          mov cx,46 
          mov Memory[0],500
          mov Memory[2],500
          mov Memory[4],500
          mov Memory[6],500
          mov Memory[8],500
          mov Memory[10],500
          mov Memory[10],500
          mov Memory1[0],500
          mov Memory1[2],500
          mov Memory1[4],500
          mov Memory1[6],500
          mov Memory1[8],500
          mov Memory1[10],500
          mov Memory2[0],500
          mov Memory2[2],500
          mov Memory2[4],500
          mov Memory2[6],500
          mov Memory2[8],500
          mov Memory2[10],500
          mov Mem[0],0
          mov Mem[2],0
          mov Mem[4],0
          mov Mem[6],0
          mov Mem[8],0
          mov Sum2[0],0
          mov Sum2[2],0
          mov Sum2[4],0
          mov Sum2[6],0
          mov Sum5[0],0
          mov Sum5[2],0
          mov Sum5[4],0
          mov Sum5[6],0
          mov Sum5[8],0
          mov AS,0          
          ret
Init       ENDP
;--------------Ввод с клавиатуры-----------------------------------------------------------------------
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
          ; call  VibrDestr   ;Гашение дребезга
           mov   [si],al     ;Запись строки
KI2:       in    al,KbdPort  ;Ввод строки
           and   al,11111111b      ;Выключено?
           cmp   al,11111111b
           jnz   KI2         ;Переход, если нет
          ; call  VibrDestr   ;Гашение дребезга
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
;------------Преобразование очередной цифры--------------------------------------------------------------------------
NxtDigTrf  PROC  NEAR
           mov dx,0
           cmp   dx,1
           jnz   Z10
Z12:       jmp NDT1   
Z10:       cmp   EmpKbd,0FFh ;Пустая клавиатура?
           je    Z12       ;Переход, если да
           cmp   KbdErr,0FFh ;Ошибка клавиатуры?
           je    Z12       ;Переход, если да
           lea   bx,KbdImage ;Загрузка адреса
           mov   dx,0        ;Очистка накопителей кода строки и столбца
NDT3:      mov   al,[bx]     ;Чтение строки
           and   al,11111111b      ;Выделение поля клавиатуры
           cmp   al,11111111b      ;Строка активна?
           jnz   NDT2        ;Переход, если да
           inc   dh          ;Инкремент кода строки
           inc   bx          ;Модификация адреса
           jmp   SHORT NDT3
NDT2:      shr   al,1        ;Выделение бита строки
           jnc   NDT4        ;Бит активен? Переход, если да
           inc   dl          ;Инкремент кода столбца
           jmp   SHORT NDT2
NDT4:      mov   cl,3        ;Формировние двоичного кода цифры
           shl   dh,cl
           or    dh,dl
           mov   dl,dh
           xor   dh,dh
           cmp dx,11
           jnz Z59 
           jmp S4
Z59:       cmp dx,10
           jnz Z55 
           jmp S4
Z55:       cmp dx,12
           jnz Z19
           mov AS,0
           call Init
         ;  mov ax,sum1
         ;  add sum3,ax
           jmp S4
Z19:       cmp dx,13
           jnz Z11
           cmp AS,1
           je Z11
           mov ax,sec
           mov Mem[0],ax
           mov ax,sec1
           mov Mem[2],ax
           mov ax,min
           mov Mem[4],ax
           mov ax,min1
           mov Mem[6],ax
           mov AS,1
           mov ax,sum1
           add sum3,ax
                
Z11:       cmp AS,0
           jnz  S4
           cmp dx,15
           jnz Z3
           cmp Index,0
           je  S4
           dec Index
           dec Index
           mov si,Index
           cmp Index1,0
           jnz Z4
           mov   Memory[si],500
Z4:        cmp Index1,1
           jnz Z5
           mov   Memory1[si],500
Z5:        cmp Index1,2
           jnz Z7
           mov   Memory2[si],500
Z7:        jmp S4
Z3:        cmp dx,14
           jnz M1
           inc Index1 
           mov Index,0 
           jmp S4 
M1:        mov   si, Index       ;Запись кода буквы в Memory
           cmp Index1,0
           jnz M2
           mov   Memory[si],dx
M2:        cmp Index1,1
           jnz S1
           mov   Memory1[si],dx
S1:        cmp Index1,2
           jnz S5
           mov   Memory2[si],dx           
S5:        inc   si
           inc   si
           mov   Index, si
S4:        xor dx,dx
NDT1:      ret
NxtDigTrf  ENDP
;------------Вывод текста----------------------------------------------------------------------------
Outnum     PROC  NEAR                ; si,cl,ch,al,bx
;           cmp   EmpKbd,0FFh ;Пустая клавиатура?
;           jz    ON        ;Переход, если да 
          xor si,si
          mov mask,00000001b
          mov set,02h
          xor bx,bx
          xor di,di
A3:        
           mov al,mask
           mov dx,0005h
           out dx,al
           mov mask1,00000001h
A8:        
           mov al,mask1
           mov dx,0052h
           out dx,al
           shl mask1,1   
           mov al,Inn[di]  
           mov dx,0051h
           out dx,al
           mov al,AO[di]  
           mov dx,0077h
           out dx,al
           inc di            
           cmp mask1,10000000b
           jnz A8                  
           shl mask,1
           cmp mask,10000000b
           jnz A3
          
           xor si,si
           mov mask,00000001b
           mov set,07h
           xor bx,bx
M3:        
           mov al,mask
           mov dx,set
           out dx,al
           xor bx,bx
           mov mask1,00000001h
           mov di,Memory[si] 
           shl di,3
M8:        
           mov al,mask1
           mov dx,0072h
           out dx,al
           shl mask1,1
           mov di,Memory[si] 
           shl di,3 
           mov al,Image[di+bx] 
           mov dx,0071h
           out dx,al
           mov di,Memory1[si] 
           shl di,3 
           mov al,Image[di+bx] 
           mov dx,0081h
           out dx,al
           mov di,Memory2[si] 
           shl di,3 
           mov al,Image[di+bx] 
           mov dx,0091h
           out dx,al
           inc bx        
           cmp mask1,10000000b
          jnz M8           
           inc si
           inc si           
           shl mask,1
           cmp mask,00100000b
          jnz M3
           
 
ON:        ret
Outnum     ENDP        
;--------------------------------------------------------------------------------------
redactor PROC NEAR
    CMP AS,1
    je AS1
    in al,08h
    cmp al,11111110b
    jnz AS1
   
          mov Memory[0],500
          mov Memory[2],500
          mov Memory[4],500
          mov Memory[6],500
          mov Memory[8],500
          mov Memory[10],500
          mov Index1,0
          mov Index,0
AS1:     cmp AS,1
         je AS3
          cmp al,11111101b
         jnz AS2
          mov Memory1[0],500
          mov Memory1[2],500
          mov Memory1[4],500
          mov Memory1[6],500
          mov Memory1[8],500
          mov Memory1[10],500
          mov Index1,1
          mov Index,0
AS2:   cmp al,11111011b
       jnz AS3
          mov Memory2[0],500
          mov Memory2[2],500
          mov Memory2[4],500
          mov Memory2[6],500
          mov Memory2[8],500
          mov Memory2[10],500  
          mov Index1,2
          mov Index,0  
AS3:                          
ret
redactor ENDP
;--------------------------------------------------------------------------------------
SUM PROC NEAR
    mov sum1,0
    cmp Memory[0],500
    jnz P0
    jmp L0
P0: mov ax,Memory[0]
    mov bx,0
    cmp Memory[2],500
    je U21
    inc bx
    cmp Memory[4],500
    je U21
    inc bx
    cmp Memory[6],500
    je U21
    inc bx
U21: cmp bx,1
     jnz U31
     mov dx,10
     mul dx
U31: cmp bx,2
     jnz U32
     mov dx,100
     mul dx
U32: cmp bx,3
     jnz U33
     mov dx,1000
     mul dx   
U33: add sum1,ax  
cmp Memory[2],500
    je L0
    mov ax,Memory[2]
    mov bx,0
    cmp Memory[4],500
    je U22
    inc bx
    cmp Memory[6],500
    je U22
    inc bx
U22: cmp bx,1
     jnz U34
     mov dx,10
     mul dx
U34: cmp bx,2
     jnz U35
     mov dx,100
     mul dx   
U35: add sum1,ax

cmp Memory[4],500
    je L0
    mov ax,Memory[4]
    mov bx,0
    cmp Memory[6],500
    je U23
    inc bx
U23: cmp bx,1
     jnz U36
     mov dx,10
     mul dx   
U36: add sum1,ax
cmp Memory[6],500
    je L0
    mov ax,Memory[6]  
    add sum1,ax 
L0: cmp Memory1[0],500
    jnz P1
    jmp UL0
P1: mov ax,Memory1[0]
    mov bx,0
    cmp Memory1[2],500
    je U41
    inc bx
    cmp Memory1[4],500
    je U41
    inc bx
    cmp Memory1[6],500
    je U41
    inc bx
U41: cmp bx,1
     jnz U51
     mov dx,10
     mul dx
U51: cmp bx,2
     jnz U52
     mov dx,100
     mul dx
U52: cmp bx,3
     jnz U53
     mov dx,1000
     mul dx   
U53: add sum1,ax
cmp Memory1[2],500
    jnz P2
    jmp UL0
P2: mov ax,Memory1[2]
    mov bx,0
    cmp Memory1[4],500
    je U42
    inc bx
    cmp Memory1[6],500
    je U42
    inc bx
U42: cmp bx,1
     jnz U54
     mov dx,10
     mul dx
U54: cmp bx,2
     jnz U55
     mov dx,100
     mul dx   
U55: add sum1,ax
cmp Memory1[4],500
    je UL0
    mov ax,Memory1[4]
    mov bx,0
    cmp Memory1[6],500
    je U43
    inc bx
U43: cmp bx,1
     jnz U56
     mov dx,10
     mul dx   
U56: add sum1,ax
cmp Memory1[6],500
    je UL0
    mov ax,Memory1[6]  
    add sum1,ax 
UL0: 
    cmp Memory2[0],500
    jnz P3
    jmp UL1
P3: mov ax,Memory2[0]
    mov bx,0
    cmp Memory2[2],500
    je U61
    inc bx
    cmp Memory2[4],500
    je U61
    inc bx
    cmp Memory2[6],500
    je U61
    inc bx
U61: cmp bx,1
     jnz U71
     mov dx,10
     mul dx
U71: cmp bx,2
     jnz U72
     mov dx,100
     mul dx
U72: cmp bx,3
     jnz U73
     mov dx,1000
     mul dx   
U73: add sum1,ax
cmp Memory2[2],500
    jnz P5
    jmp UL1
P5: mov ax,Memory2[2]
    mov bx,0
    cmp Memory2[4],500
    je U62
    inc bx
    cmp Memory2[6],500
    je U62
    inc bx
U62: cmp bx,1
     jnz U74
     mov dx,10
     mul dx
U74: cmp bx,2
     jnz U75
     mov dx,100
     mul dx   
U75: add sum1,ax
cmp Memory2[4],500
    je UL1
    mov ax,Memory2[4]
    mov bx,0
    cmp Memory2[6],500
    je U63
    inc bx
U63: cmp bx,1
     jnz U76
     mov dx,10
     mul dx   
U76: add sum1,ax
cmp Memory2[6],500
    je UL1
    mov ax,Memory2[6]  
    add sum1,ax 
UL1:    
    xor si,si
    xor ax,ax
    mov sum5[0],0
    mov sum5[2],0
    mov sum5[4],0
    mov sum5[6],0
    mov sum5[8],0
   
    mov ax,sum1
    mov dx,0
    mov di,10
    div di
    mov Sum5[0],dx
    cmp ax,0
    je C12
    mov dx,0
    div di
    mov Sum5[2],dx
    cmp ax,0
    je C12
     mov dx,0
    div di
    mov Sum5[4],dx
    cmp ax,0
    je C12
    mov dx,0
    div di
    mov Sum5[6],dx
    cmp ax,0
    je C12
    mov dx,0
    div di
    mov Sum5[8],dx
    cmp ax,0
    je C12
C12:mov dx,0037h
    mov di,Sum5[0]
    mov al,Im[di]
    out dx,al
    mov dx,0038h
    mov di,Sum5[2]
    mov al,Im[di]
    out dx,al
    mov dx,0039h
    mov di,Sum5[4]
    mov al,Im[di]
    out dx,al
    mov dx,0035h
    mov di,Sum5[6]
    mov al,Im[di]
    out dx,al  
    mov dx,0040h
    mov di,Sum5[8]
    mov al,Im[di]
    out dx,al 
    
     cmp AS,1
           jnz M19
           xor si,si
           mov mask,00000001b
           mov set,02h
           xor bx,bx
           xor di,di
A57:        
           mov al,mask
           mov dx,0055h
           out dx,al
           mov mask1,00000001h
           xor bx,bx
A55:        
           mov al,mask1
           mov dx,0h
           out dx,al
           shl mask1,1  
           mov ax,Sum5[si]  
           mov dx,8
           mul dx
           mov di,ax 
           mov al,Image[di+bx]
           mov dx,01h
           out dx,al
           mov ax,Mem[si]  
           mov dx,8
           mul dx
           mov di,ax 
           mov al,Image[di+bx]
           mov dx,02h
           out dx,al 
           inc bx 
           cmp mask1,10000000b
           jnz A55 
           inc si   
           inc si                   
           shl mask,1
           cmp mask,10000000b
           jnz A57
M19:      
ret
SUM ENDP
;--------------------------------------------------------------------------------------
CLOK PROC NEAR
  inc sec
  cmp sec,10
  jnz V1
  mov sec,0
  inc sec1
  cmp sec1,6
  jnz V1
  mov sec1,0
  inc min
  cmp min,10
  jnz V1
  mov min,0
  inc min1
  cmp min1,6
  jnz V1
  mov min1,0
V1:   
  mov dx,012h
  mov bx,sec
  mov al,Im[bx]
  out dx,al
  mov dx,013h
  mov bx,sec1
  mov al,Im[bx]
  out dx,al
  mov dx,011h
  mov bx,min
  mov al,Im[bx]
  out dx,al
  mov dx,010h
  mov bx,min1
  mov al,Im[bx]
  out dx,al  
ret
CLOK ENDP
;--------------------------------------------------------------------------------------
Storage PROC NEAR
   xor si,si
    xor ax,ax
    mov sum2[0],0
    mov sum2[2],0
    mov sum2[4],0
    mov sum2[6],0
    mov sum2[8],0
    mov ax,sum3
    mov dx,0
    mov di,10
    div di
    mov Sum2[0],dx
    cmp ax,0
    je C19
    mov dx,0
    div di
    mov Sum2[2],dx
    cmp ax,0
    je C19
     mov dx,0
    div di
    mov Sum2[4],dx
    cmp ax,0
    je C19
    mov dx,0
    div di
    mov Sum2[6],dx
    cmp ax,0
    je C19
    mov dx,0
    div di
    mov Sum2[8],dx
    cmp ax,0
    je C19
C19:  
   in al,0036h
   mov dx,0033h
   out dx,al
   cmp al,10111100b
   jnz L1
   mov dx,0025h
   mov di,Sum2[0]
   mov al,Im[di]
   out dx,al
   mov dx,0026h
   mov di,Sum2[2]
   mov al,Im[di]
   out dx,al
   mov dx,0027h
   mov di,Sum2[4]
   mov al,Im[di]
   out dx,al
   mov dx,0029h
   mov di,Sum2[6]
   mov al,Im[di]
   out dx,al
   mov dx,0047h
   mov di,Sum2[8]
   mov al,Im[di]
   out dx,al
L1:in al,0036h
   cmp al,10111100b 
   je L2
   mov dx,0025h
   mov di,Sum2[0]
   mov al,Im[di]
   shl al,1
   shl al,1
   shl al,1
   out dx,al
   mov dx,0026h
   mov di,Sum2[2]
   mov al,Im[di]
   shl al,1
   shl al,1
   shl al,1
   shl al,1
   shl al,1
   out dx,al
   mov dx,0027h
   mov di,Sum2[4]
   mov al,Im[di]
   shl al,1
   shl al,1
   out dx,al
   mov dx,0029h
   mov di,Sum2[6]
   mov al,Im[di]
   shl al,1
   shl al,1
   shl al,1
   shl al,1
   shl al,1
   shl al,1
   shl al,1
   out dx,al
   mov dx,0047h
   mov di,Sum2[8]
   mov al,Im[di]
   shl al,1
   shl al,1
   shl al,1
   shl al,1
   shl al,1
   out dx,al
L2:     
ret
Storage ENDP
;--------------------------------------------------------------------------------------
Init1 PROC NEAR
 mov sum3,0
 mov sum1,0
 mov sec,0
 mov sec1,0
 mov min,0
 mov min1,0
ret
Init1 ENDP
;--------------------------------------------------------------------------------------
Start:     
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;---------------My program-------------------------------------------------------------
           call  Init
           call Init1
InfLoop:
           call  KbdInput
           call  KbdInContr
           call  NxtDigTrf
           call  Outnum
           call  redactor
           call  SUM
           call CLOK
           call Storage
           jmp   InfLoop 
;--------------------------------------------------------------------------------------
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end
