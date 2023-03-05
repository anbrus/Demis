.386
RomSize    EQU   4096
NMatrix    EQU   2           ;Порт выбора матричного индикатора 
NStolb     EQU   1           ;Порт выбора столбца
NImage     EQU   0           ;Порт выбора изображения в столбец
NumMatrix  EQU   3           ;Количество матричных индикаторов
ACPRdy     EQU   0           ;Порт АЦП лапы Rdy
ACPOut     EQU   1           ;Порт АЦП лапы Out
ACPStart   EQU   2           ;Порт АЦП лапы Start
Keyboard   EQU   0           ;Порт кнопок (П,Р,С)
Mercanie   EQU   30h         ;"Мерцание" - количество пустых циклов по 65535 раз, чтобы буквы не двоились

Data       SEGMENT use16 AT 100h
Vyvod      db    32 dup(?)   ;Тридцатидвух битный массив, который постоянно выводится на дисплей
OffstVyvod db    ?           ;Переменная для того, чтобы лазать по массиву Vyvod
SpeedCX    db    ?           ;Счётчик скорости (портится), возобновляемый из переменной Speed
Speed      db    ?           ;Счётчик скорости (не портится)
CurrNum    db    ?           ;Текущий номер буковки, которая бегает на дисплее (0,1,2) и которая будет перезаписана кнопкой
Old        db    ?           ;Переменная для выделения переднего фронта волны
Data       ENDS

Code       SEGMENT use16
           ASSUME cs:Code,ds:Data,es:Code,ss:Stk
Image      db    00000000b,11111111b,00000001b,00000001b,00000001b,00000001b,11111111b,00000000b    ;П
           db    00000000b,11111111b,00010001b,00010001b,00010001b,00010001b,00001110b,00000000b    ;Р
           db    00000000b,01111110b,10000001b,10000001b,10000001b,10000001b,10000001b,00000000b    ;С

Clear      MACRO Port        ;Процедура очистки индикаторов. Выведена для удобности и наглядности
           xor   al,al
           out   Port,al
           ENDM

Prepare    PROC  NEAR        ;Подготовка
           xor   ax,ax
           lea   si,Vyvod
           mov   cx,size Vyvod
PodgotM1:  mov   al,0        ;Обнуляем массив Vyvod, т.к. этот массив - критические данные
           mov   [si],al
           inc   si
           loop  PodgotM1
           mov   CurrNum,al
           mov   OffstVyvod,al
           mov   CurrNum,al
           mov   Old,al
           mov   al,0111b    ;0111b - у нас такое значение изначально выставлено на АЦП (0.00).
                 
                 ;        1) Считываем с порта в al, получаем 00000000b
                 ;        2) Делаем операцию not al, получаем 11111111b
                 ;        3) Далее операция shr al,5 получаем 00000111b
           mov   Speed,al
           mov   SpeedCX,al
           RET
Prepare    ENDP

Displ      PROC  NEAR
           mov   dl,00000001b    ;первый мартичный индикатор
           mov   cx,NumMatrix
           lea   si,Vyvod
           xor   bh,bh
           mov   bl,OffstVyvod
DisplM1:   Clear NStolb
           mov   al,dl
           out   NMatrix,al
           push  cx
           mov   cx,8
DisplM2:   Clear NStolb
           mov   al,[si+bx]
           out   NImage,al
           xor   al,al
           stc                   ;поднимаем флаг CF=1 (есть перенос)
           rcr   al,cl           ;сдвиг вправо, получаем номер столбца, в который будем выводить изображение
           out   NStolb,al
           inc   bl              ;чтоб не уползти за 32 байта массива vyvod, при переполнении сдвигаемся вначало
           cmp   bl,size Vyvod - 1
           jne   DisplM3
           xor   bl,bl
DisplM3:   loop  DisplM2
           rol   dl,1            ;следующий матричный индикатор
           pop   cx
           loop  DisplM1
           Clear NStolb
           RET
Displ      ENDP

Delay      PROC  NEAR
           xor   cx,cx
DelayM1:   loop  DelayM1
           dec   SpeedCX
           jnz   DelayM2
           mov   al,Speed
           mov   SpeedCX,al
           mov   cx,Mercanie
DelayM4:   push  cx
           xor   cx,cx
DelayM3:   loop  DelayM3
           pop   cx
           loop  DelayM4
           inc   OffstVyvod
           cmp   OffstVyvod,size Vyvod - 1
           jne   DelayM2
           mov   OffstVyvod,ch
DelayM2:   RET
Delay      ENDP

ACP        PROC  NEAR
           mov   al,00001000b    ;4-я лапа подключена к Start у АЦП
           out   ACPStart,al
ACPM1:     in    al,ACPRdy
           test  al,1
           jz    ACPM1
           xor   al,al
           out   ACPStart,al
           in    al,ACPOut
           not   al
           shr   al,5
           or    al,1
           mov   Speed,al
           RET
ACP        ENDP

KeyRead    PROC  NEAR
           in    al,Keyboard
           not   al
           shr   al,5
           mov   ah,al
           xor   al,Old
           and   al,ah
           mov   Old,ah
           RET
KeyRead    ENDP

Print      PROC  NEAR
           or    al,al
           jz    PrintM3
           xor   ah,ah
PrintM1:   inc   ah
           shr   al,1      ;из унитарного в двоичный позиционный
           jnz   PrintM1
           dec   ah
           shr   ax,5         ; shr ax,8 - переносим из ah в ax, чистим ah, shl al, 3 - умножаем al на 8
           lea   bx,Image
           add   bx,ax
           lea   si,Vyvod
           mov   al,CurrNum  ; 0,1,2. Номер буковки
           xor   ah,ah
           shl   ax,3
           add   si,ax
           inc   CurrNum
           cmp   CurrNum,3
           jne   PrintM4   ;если не равно 3
           mov   CurrNum,0
PrintM4:   mov   cx,8
PrintM2:   mov   al,es:[bx]
           mov   [si],al
           inc   bx
           inc   si
           loop  PrintM2
PrintM3:   RET
Print      ENDP

Start:     mov   ax,Data
           mov   ds,ax
           mov   ax,Code
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           call  Prepare
InfLoop:   call  KeyRead
           call  Print
           call  Displ
           call  Delay
           call  ACP
           jmp   InfLoop

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS

Stk        SEGMENT use16 STACK
           org 10h 
           dw  5 dup(?)
StkTop     LABEL Word
Stk        ENDS

END