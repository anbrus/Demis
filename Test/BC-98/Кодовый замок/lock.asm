RomSize    EQU   4096
KbdPort  = 0
IndicPort = 1

Data       SEGMENT AT 100h

           KbdImage   db 3 dup(?);Образ клавиатуры
           Mode       db ?       ;Режим
           KbdErr   db ?         ;Ошибка клавиатуры
           KbdEmp   db ?         ;Пустая клавиатура
           Digit     db ?        ;Цифра
           LockCode  db 9 dup (?)    ;Код замка
           ArrayDisp db 5 dup (?)    ;Массив для вывода на дисплей
                      
           NumDigCode dw ?           ;Код введеный пользователем
           Blocking   db ?           ;
           Buffer     db ?           ;Состояние индикаторов
           Open       db ?           ;
           Try        db ?           ;

Data       ENDS

Stk        SEGMENT AT 200h
           dw 30 dup (?)
           StkTop Label Word
Stk        ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Data

Images db 3Fh, 0Ch, 76h, 5Eh, 4Dh, 5Bh, 7Bh, 0Eh, 7Fh, 5Fh, 00h         

;*****************************************
;Модуль "Функциональная подготовка"
FuncPrep   Proc Near
           lea   DI, LockCode
           mov   CX, length LockCode
   FP1:    mov   byte ptr [DI], 0
           inc   DI
           loop  FP1
           
           mov   NumDigCode, 0
           mov   Buffer, 0
           mov   Blocking, 0
           mov   Open, 0
           mov   Try, 0           
           ret
FuncPrep   Endp
;*****************************************
;Модуль "Ввод режимов"
ModeInput  Proc Near
           mov   Mode, 0
           in    AL, KbdPort
           mov   DX, KbdPort
           call  VibrDestr
           test  AL, 80h
           je    MI1
           mov   Mode, 0FFh
   MI1:    ret
ModeInput  Endp
;******************************************
;Модуль "Ввод с клавиатуры"
KbdInput   Proc Near
           lea   DI, KbdImage
           xor   CL, CL
           
   KI2:    mov   AL, 1
           shl   AL, CL
           or    AL, Buffer
           out   KbdPort, AL
           in    AL, KbdPort
           and   AL, 0Fh
           jz    KI1
           
           mov   DX, KbdPort
           call  VibrDestr           
           mov   [DI], AL
           
   KI3:    in    AL, KbdPort
           and   AL, 0Fh
           jnz   KI3
           jmp   KI4
           
   KI1:    mov   [DI], AL
   KI4:    inc   DI
           inc   CL
           cmp   CL, length KbdImage
           jnz   KI2
           ret
KbdInput   Endp
;**************************************
VibrDestr  Proc Near
   VD1:    mov   AH, AL
           mov   BH, 0
   VD2:    in    AL, DX
           cmp   AH, AL
           jne   VD1
           inc   BH
           cmp   BH, 50
           jne   VD2
           mov   AL, AH
           ret
VibrDestr  Endp
;**************************************
;Модуль "Контроль ввода с клавиатуры"
KbdInContrl Proc Near
           lea   SI, KbdImage
           mov   CX, 3
           mov   DL, 0
   KIC2:   mov   AL, [SI]
           mov   AH, 4
   KIC1:   shr   AL, 1
           adc   DL, 0
           dec   AH
           jnz   KIC1
           inc   SI
           loop  KIC2
           
           mov   KbdErr, 0
           mov   KbdEmp, 0
           cmp   DL, 0
           jz    KIC3
           cmp   DL, 1
           jz    KIC4
           mov   KbdErr, 0FFh
           jmp   KIC4
   KIC3:   mov   KbdEmp, 0FFh
   KIC4:   ret
KbdInContrl Endp
;****************************************
;Модуль "Нахождение очередной цифры"
DigFinding Proc Near
           cmp   KbdErr, 0
           jne   DF1
           cmp   KbdEmp, 0
           jne   DF1
           
           xor   DX, DX
           lea   SI, KbdImage
           
   DF3:    mov   AL, [SI]
           and   AL, 0Fh
           cmp   AL, 0
           jnz   DF2
           inc   DL
           inc   SI
           jmp   DF3
           
   DF2:    shr   AL, 1
           jc    DF4
           inc   DH
           jmp   DF2
           
   DF4:    shl   DL, 2
           or    DH, DL     
           mov   Digit, DH
           
           cmp   DH, 10
           jb    DF1
           mov KbdEmp, 0FFh                 
   DF1:    ret
DigFinding Endp
;*****************************************
;Модуль"Формирование кода 1-ого уровня"
FormLockCode1 Proc Near
           cmp   Mode, 0
           jnz   FLC1
           
           mov   NumDigCode, 0
           mov   Buffer, 0
           mov   Blocking, 0
           mov   Open, 0
           mov   Try, 0           
           
           cmp   KbdErr, 0
           jnz   FLC1
           cmp   KbdEmp, 0
           jnz   FLC1
           
           mov   DI, 0
           mov   CX, 4
   FLC3:   mov   AL, LockCode[DI+1]
           mov   LockCode[DI], AL
           inc   DI
           loop  FLC3
           
           mov   AL, Digit
           mov   LockCode[DI], AL            
   FLC1:   ret
FormLockCode1 Endp
;******************************************
;Модуль "Формирование кода 2,3-его уровня"
FormLockCode23 Proc Near
           cmp   Mode, 0
           jz    FL1
           
           xor   AL, AL
           mov   CX, 5
           xor   SI, SI
   FL2:    add   AL, LockCode[SI]
           inc   SI
           loop  FL2
           
           mov   BL, AL
           aam
           mov   LockCode[5], AH
           mov   LockCode[6], AL
           
           sub   BL, LockCode[2]
           xchg  BL, AL
           aam
           mov   LockCode[7], AH
           mov   LockCode[8], AL                      
   FL1:    ret
FormLockCode23 Endp
;********************************************
;Модуль "Формирование массива отображения"
FormDisp Proc Near
           cmp   KbdErr, 0
           jnz   FD1
           
           cmp   Mode, 0FFh
           jne   FD4
           
           lea   DI, ArrayDisp
           mov   CX, 5
   FD2:    mov   byte ptr [DI], 10
           inc   DI
           loop  FD2
           
   FD4:    cmp   Mode, 0
           jne   FD1
           
           lea   DI, ArrayDisp
           lea   SI, LockCode
           mov   CX, 5
   FD3:    mov   AL, [SI]
           mov   [DI], AL
           inc   SI
           inc   DI
           loop  FD3                      
   FD1:    ret
FormDisp Endp
;******************************************
;Модуль "Вывод"
OutputCode Proc Near           
           cmp   KbdErr, 0
           jnz   OC1
                      
           mov   CX, 5
           mov   DX, IndicPort
           xor   DI, DI
           
   OC2:    xor   AX, AX
           mov   AL, ArrayDisp[DI]
           mov   SI, AX
           mov   AL, Images[SI]
           out   DX, AL
           
           inc   DI
           inc   DX
           loop  OC2           
   OC1:    ret
OutputCode Endp
;******************************************
;Модуль "Попытка войти"
VisiterTrying Proc Near
           cmp   KbdErr, 0
           jne   VT1
           cmp   KbdEmp, 0
           jne   VT1
           cmp   Mode, 0
           je    VT1
                
           mov   SI, NumDigCode
           mov   AL, Digit
           cmp   LockCode[SI], AL
           je    VT2
           mov   NumDigCode, 0
           mov   Buffer, 0
           inc   Try
           cmp   Try, 3
           jne   VT1
           mov   Try, 0
           mov   Blocking, 0FFh
           jmp   VT1
   VT2:    inc   NumDigCode
           cmp   NumDigCode, 5
           jb    VT1
           or    Buffer, 10h
           mov   AL, Buffer
           
           cmp   NumDigCode, 7
           jb    VT1
           or    Buffer, 20h
           mov   AL, Buffer
           
           cmp   NumDigCode, 9
           jb    VT1
           or    Buffer, 40h
           mov   Open, 0FFh
                      
   VT1:    mov   AL, Buffer
           out   KbdPort, AL
           ret
VisiterTrying Endp
;****************************************
;Модуль "Открытие замка"
OpenMe Proc Near
           cmp   Open, 0FFh
           jnz   OM1
           
           mov   AL, Buffer   
           mov   DX, 8fh      
   OM3:    mov   CX, 0FFFh    
   OM2:    out   KbdPort, AL  
           loop  OM2         
           dec   DX            
           jnz   OM3          
           
           mov   Buffer, 0
           mov   NumDigCode, 0
           mov   Open, 0           
   OM1:    ret
OpenMe Endp
;************************************
;Модуль"Блокировка"
BlockingOfLock Proc Near
           cmp   Blocking, 0FFh
           jne   BOL1
           
           mov   Buffer, 80h   
           mov   AL, Buffer    
           mov   DX, 032fh     
   BOL3:   mov   CX, 0FFFh    
   BOL2:   out   KbdPort, AL  
           loop  BOL2         
           dec   DX            
           jnz   BOL3          
           
           mov   Buffer, 0
           mov   Blocking, 0
           mov   Try, 0           
   BOL1:   ret
BlockingOfLock Endp
;********************************************
;********************************************
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop

           call  FuncPrep         ;Функциональная подготовка
   Cycle:  call  ModeInput        ;Ввод режимов   
           call  KbdInput         ;Ввод с клавиатуры
           call  KbdInContrl      ;Контроль ввода с клавиатуры
           call  DigFinding       ;Нахождение очередной цифры
           call  FormLockCode1    ;Формирование кода 1 уровня
           call  FormLockCode23   ;Формирование кода 2 и 3 уровня
           call  FormDisp         ;Формирование массива отображения
           call  OutputCode       ;Вывод
           call  VisiterTrying    ;Попытка войти
           call  OpenMe           ;Открытие замка
           call  BlockingOfLock   ;Блокировка
                      
           jmp   Cycle

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
End
