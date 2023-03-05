RomSize    EQU   4096
NMax       EQU   50
KbdPort    EQU   0
DispPort   EQU   1
k1         equ   1

Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

Data        SEGMENT AT 0
KbdImage    DB    4   DUP(?)
Array_inf   DB   10000 dup(?)
Sklad       DB   10   dup(?)
Res         DB   10   dup(?)
zero_1      db   1000 dup(?)
num_u       db    ?
EmpKbd      DB    ?
KbdErr      DB    ?
NextDig     DB    ?
NextDig1    DB    ?
NextDig2    DB    ?
NextDig3    DB    ?
priznak     db    ?
Mass_in_Binary_Format        db 2 dup (?)	;масса в двоичной форме
Mass_in_ASCII_Format         db 5 dup (?)	;масса в десятичной форме
Data       ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Code,ss:Stk

           ;Образы 16-тиричных символов: "0", "1", ... "F"
SymImages  DB  07Fh,05Fh,06Fh,079h,04Dh,05Bh,07Bh,00Eh
           DB  03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           





VibrDestr  PROC  NEAR
VD1:       mov   ah,al       
           mov   bh,0        
VD2:       in    al,dx       
           cmp   ah,al       
           jne   VD1         
           inc   bh          
           cmp   bh,NMax     
           jne   VD2         
           mov   al,ah       
           ret
VibrDestr  ENDP

KbdInput   PROC  NEAR
           lea   si,KbdImage         
           mov   cx,LENGTH KbdImage  
           mov   bl,0FEh             
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
           jmp    KI3
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
           cmp   KbdErr,0FFh ;Ошибка клавиатуры?                            100
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
NDT4:      
           mov   al,NextDig2
           mov   NextDig3,al
           mov   al,NextDig1
           mov   NextDig2,al
           mov   al,NextDig 
           mov   NextDig1,al
           mov   cl,2        ;Формировние двоичного кода цифры
           shl   dh,cl
           or    dh,dl
           mov   NextDig,dh  ;Запись кода цифры
           cmp   NextDig,3
           jne   NDT5
           call  Clean_Number         
NDT5:      cmp   NextDig,2
           jne   NDT1
           call  Clean_memory
           call  Clean_Number
NDT1:      ret
NxtDigTrf  ENDP

NumOut     PROC  NEAR
           cmp   KbdErr,0FFh
           jz    NO1
           
           cmp   EmpKbd,0FFh
           jz    NO1
           
           xor   ah,ah
           mov   al,NextDig
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           out   1,al
           
           mov   al,NextDig1
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           out   2,al
           
           mov   al,NextDig2
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           out   3,al
           
             
           mov   al,NextDig3
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           out   4,al
           
NO1:       ret
NumOut     ENDP

Clean_Number proc Near
           mov   NextDig,8
           mov   NextDig1,8
           mov   NextDig2,8
           mov   NextDig3,8
           ret
Clean_Number Endp
;===========================================================================================
acp proc near
           mov   al,0
           out   10h,al       
           mov   al,1
           out   10h,al
                      
WaitRdy:
           in    al,12h        ;Ждём единичку на выходе Rdy АЦП - признак
                             ;завершения преобразования
           test  al,1
           jz    WaitRdy
           
           xor si,si
           in al,10h
           mov Mass_in_Binary_Format[si],al
           inc si
           in al,11h
           mov Mass_in_Binary_Format[si],al
           
           
           mov CX, 6
           xor SI, SI
     CMB4: mov Mass_in_ASCII_Format[SI], 0
           inc SI
           loop CMB4
 
           xor DI, DI
           mov BL, 10

     CMB3: xor AH, AH
           mov SI, length Mass_in_Binary_Format - 1
           mov CX, length Mass_in_Binary_Format
           xor BH, BH                                            ;200

     CMB2: mov AL, Mass_in_Binary_Format[SI]
           div BL
           mov Mass_in_Binary_Format[SI], AL
           cmp AL, 0
           je CMB1
           inc BH
     CMB1: dec SI

           loop CMB2
           
           mov Mass_in_ASCII_Format[DI], Ah
           inc DI
           cmp BH, 0
           jnz CMB3

           dec DI
          
ret
ACP endp

compare proc near
; процедура преобразования массы для вывода
           cmp al,0
           jne X1
           mov al,00111111b
                
       X1: cmp al,1
           jne X2
           mov al,00001100b
      
       X2: cmp al,2
           jne X3
           mov al,01110110b
       
       X3: cmp al,3
           jne X4
           mov al,01011110b
    
       X4: cmp al,4
           jne X5
           mov al,01001101b

       X5: cmp al,5
           jne X6
           mov al,01011011b
 
       X6: cmp al,6
           jne X7
           mov al,01111011b

       X7: cmp al,0111b
           jne X8
           mov al,00001110b

       X8: cmp al,8
           jne X9
           mov al,01111111b

       X9: cmp al,9
           jne X10
           mov al,01011111b

       X10: ret

compare endp



Out_Mass proc near
; процедура вывода массы на индикаторы
           xor si,si
           mov al,Mass_in_ASCII_Format[si]
           call compare
           out 11h,al
           inc si
           
           mov al,Mass_in_ASCII_Format[si]
           call compare
           out 12h,al
           inc si
           
           mov al,Mass_in_ASCII_Format[si]
           call compare
           out 13h,al
           inc si
           
           mov al,Mass_in_ASCII_Format[si]
           call compare
           out 14h,al
           inc si
           
           mov al,Mass_in_ASCII_Format[si]
           call compare
           out 15h,al
           
out_Mass endp

Max proc near                            
;процедура определения максимального значения АЦП 
           mov bl,6          
           mov ah,0
           mov al,Mass_in_ASCII_Format[4]
           div bl
           mov Mass_in_ASCII_Format[4],al
           
           mov al,Mass_in_ASCII_Format[3]
           aad
           div bl
           mov Mass_in_ASCII_Format[3],al
           
           mov al,Mass_in_ASCII_Format[2]
           aad
           div bl
           mov Mass_in_ASCII_Format[2],al
           
           mov al,Mass_in_ASCII_Format[1]
           aad
           div bl
           mov Mass_in_ASCII_Format[1],al
           
           mov al,Mass_in_ASCII_Format[0]
           aad
           div bl
           mov Mass_in_ASCII_Format[0],al
          
           mov al,Mass_in_ASCII_Format[4]
           cmp al,0                                                          ;300
           je m1
           mov al,0
           mov Mass_in_ASCII_Format[0],al
           mov Mass_in_ASCII_Format[1],al
           mov Mass_in_ASCII_Format[2],al
           mov Mass_in_ASCII_Format[3],al
           mov al,1
           mov Mass_in_ASCII_Format[4],al
 
     M1:   ret            
   
Max endp

;=========================================================================================
;=========================================================================================
Input_in_Mass proc near
           
           in al,1
           test al,00000010b
           jne IM1
           
     im11: in al,1
           test al,00000010b
           jz im11
  
           mov al,Mass_in_ASCII_Format[0]
           add al,Sklad[0]
           aaa
           mov Sklad[0],al

           mov al,Mass_in_ASCII_Format[1]
           adc al,Sklad[1]
           aaa
           mov Sklad[1],al
           
           mov al,Mass_in_ASCII_Format[2]
           adc al,Sklad[2]
           aaa
           mov Sklad[2],al
           
           mov al,Mass_in_ASCII_Format[3]
           adc al,Sklad[3]
           aaa
           mov Sklad[3],al
           
           mov al,Mass_in_ASCII_Format[4]
           adc al,Sklad[4]
           aaa
           mov Sklad[4],al
           
           mov al,Mass_in_ASCII_Format[5]
           adc al,Sklad[5]
           aaa
           mov Sklad[5],al
          
           call addd
           
    IM1:   in al,1
           test al,00001000b
           jne IM2
           
     im12: in al,1
           test al,00001000b
           jz im12
   
    y1:    mov al,Sklad[0]
           sub al,Mass_in_ASCII_Format[0]
           aas
           mov Sklad[0],al
           
           mov al,Sklad[1]
           sbb al,Mass_in_ASCII_Format[1]
           aas
           mov Sklad[1],al
           
           mov al,Sklad[2]
           sbb al,Mass_in_ASCII_Format[2]
           aas
           mov Sklad[2],al
           
           mov al,Sklad[3]
           sbb al,Mass_in_ASCII_Format[3]
           aas
           mov Sklad[3],al
           
           mov al,Sklad[4]
           sbb al,Mass_in_ASCII_Format[4]
           aas
           mov Sklad[4],al
           
           mov al,Sklad[5]
           sbb al,Mass_in_ASCII_Format[5]
           aas
           mov Sklad[5],al
           jnc IM3
           
           call Err_message
           jmp im2
           
    im3:   ;call reserv
           call addd       
  
    IM2:   ret 
Input_in_Mass endp

addd proc near
           mov al,nextdig
           mov ah,nextdig1
           mov bl,10
           mul bl
           mov si,ax
           
           mov al,Mass_in_ASCII_Format[0]
           add al,array_inf[si]
           aaa
           mov array_inf[si],al
           mov al,Mass_in_ASCII_Format[1]
           adc al,array_inf[si+1]
           aaa
           mov array_inf[si+1],al
           mov al,Mass_in_ASCII_Format[2]
           adc al,array_inf[si+2]
           aaa
           mov array_inf[si+2],al
           mov al,Mass_in_ASCII_Format[3]
           adc al,array_inf[si+3]
           aaa
           mov array_inf[si+3],al
           mov al,Mass_in_ASCII_Format[4]
           adc al,array_inf[si+4]
           aaa
           mov array_inf[si+4],al
           
           mov al,0
           adc al,array_inf[si+5]
           aaa
           mov array_inf[si+5],al
           ret
addd endp

Err_message proc near
           mov al,0
           mov sklad[7],al
           mov sklad[6],al
           mov sklad[5],al
           mov al,01110011b
           mov sklad[4],al
           mov al,01100000b
           mov sklad[3],al
           mov al,01100000b
           mov sklad[2],al
           mov al,01111000b
           mov sklad[1],al
           mov al,01100000b
           mov sklad[0],al
           mov al,1
           mov priznak,al
           ret
Err_message endp

OUTput_in_Mass proc near
           xor si,si
           mov al,nextdig
           mov ah,nextdig1
           mov bl,10
           mul bl
           mov si,ax
           mov al,zero_1[si]
           call compare
           out 21h,al
           mov al,zero_1[si+1]
           call compare
           out 22h,al
           mov al,zero_1[si+2]
           call compare
           out 23h,al
           mov al,zero_1[si+3]
           call compare
           out 24h,al
           mov al,zero_1[si+4]
           call compare
           out 25h,al
      
          
           xor si,si
           mov al,Sklad[0]
           call compare
           out 31h,al
           mov al,Sklad[1]
           call compare
           out 32h,al
           mov al,Sklad[2]
           call compare
           out 33h,al
           mov al,Sklad[3]
           call compare
           out 34h,al
           mov al,Sklad[4]
           call compare
           out 35h,al
           mov al,Sklad[5]
           call compare
           out 36h,al
           mov al,Sklad[6]
           call compare
           out 37h,al
           mov al,Sklad[7]
           call compare
           out 38h,al
           mov al,Sklad[8]
           call compare
           out 39h,al
 
    oM1:   ret 
OUTput_in_Mass endp
                                                                         ;400
Clean_Array_inf proc near
           xor cx,cx
           xor si,si
           mov al,0
           mov cx,10
   CA1:    mov res[si],al
           inc si
           loop CA1
           
           xor cx,cx
           xor si,si
           mov al,0
           mov cx,10
    sk1:   mov Sklad[si],al
           inc si
           loop sk1
           
           xor cx,cx
           xor si,si
           mov al,0
           mov cx,1000
    sk2:   mov zero_1[si],al
           inc si
           loop sk2  
           
           xor cx,cx
           xor si,si
           mov al,0
           mov cx,1000
    sk3:   mov array_inf[si],0
           inc si
           loop sk3             
 
 
 
ret
Clean_Array_inf endp

Zero proc near
           in al,1
           test al,00000001b
           jne z1
           
     z2:   in al,1
           test al,00000001b
           jz z2
           
           xor di,di
           mov al,nextdig
           mov ah,nextdig1
           mov bl,10
           mul bl
           mov si,ax
     z3:   mov al,Mass_in_ASCII_Format[di]
           mov zero_1[si],al
           inc si
           inc di
           cmp di,5
           jne z3
           
                      
 z1:       ret
zero endp

zero2 proc near
           xor si,si
           mov al,nextdig
           mov ah,nextdig1
           mov bl,10
           mul bl
           mov si,ax
           clc
           mov al,Mass_in_ASCII_Format[0]
           sub al,zero_1[si]
           aas
           mov Mass_in_ASCII_Format[0],al
           
           mov al,Mass_in_ASCII_Format[1]
           sbb al,zero_1[si+1]
           aas
           mov Mass_in_ASCII_Format[1],al
           
           mov al,Mass_in_ASCII_Format[2]
           sbb al,zero_1[si+2]
           aas
           mov Mass_in_ASCII_Format[2],al
           
           mov al,Mass_in_ASCII_Format[3]
           sbb al,zero_1[si+3]
           aas
           mov Mass_in_ASCII_Format[3],al
           
           mov al,Mass_in_ASCII_Format[4]
           sbb al,zero_1[si+4]
           aas
           mov Mass_in_ASCII_Format[4],al
           jnc zzz1
           
           xor si,si
           mov al,0
   zzz2:   mov Mass_in_ASCII_Format[si],al
           inc si
           cmp si,5
           jne zzz2
           
    zzz1:  ret
zero2 endp 


Clean_memory proc near
                 mov si,0
                 mov cx,11111111b
                 mov al,0
           cm1:  mov array_inf[si],al
                 inc si
                 loop cm1                
                 ret
Clean_memory     endp

out_number_of_car proc near

           mov al,nextdig
           mov ah,nextdig1
           mov bl,10
           mul bl
           mov si,ax
           mov al,array_inf[si]
           call compare
           out 41h,al
           mov al,array_inf[si+1]
           call compare
           out 42h,al
           mov al,array_inf[si+2]
           call compare
           out 43h,al
           mov al,array_inf[si+3]
           call compare
           out 44h,al
           mov al,array_inf[si+4]
           call compare
           out 45h,al
           mov al,array_inf[si+5]
           call compare
           out 46h,al
           mov al,array_inf[si+6]
           call compare
           out 47h,al
          



           ret
out_number_of_car endp
;_______________________________________________________________________________________________
;____________________________________________________
;--------------------------------------------------------
Start:
           mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           
           mov   KbdErr,0
           mov   NextDig,8
           mov   NextDig1,8
           mov   NextDig2,8
           mov   NextDig3,8
           call  Clean_Array_inf
           
InfLoop:   
           in al,1
           test al,00000100b
           jne zz1
           mov al,01100111b
           out 99h,al
           call  NumOut
           call  KbdInput
           call  KbdInContr
           call  NxtDigTrf
           call  NumOut
           
           call  acp
           call  Max
           call  zero2
           call  zero
           call  out_Mass
           call  OUTput_in_Mass
           jmp   InfLoop

  zz1:     mov al,01011101b
           out 99h,al

           call  NumOut
           call  KbdInput
           call  KbdInContr
           call  NxtDigTrf
           call  NumOut
           
           call  acp
           call  Max
           call  zero2         
           
           mov al,nextdig
           mov ah,nextdig1
           mov bl,10
           mul bl
           mov si,ax
           xor di,di
     zzz3: mov al,zero_1[si]
           cmp al,0
           jne next1
           inc si
           inc di
           cmp di,5
           jne zzz3
           mov al,1
           out 77h,al
           jmp next2
          
  next1:   call  Input_in_Mass
           mov al,0
           out 77h,al
  next2:   call  OUTput_in_Mass
           call  out_Mass
           call  out_number_of_car
           jmp   InfLoop
           
           

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END
