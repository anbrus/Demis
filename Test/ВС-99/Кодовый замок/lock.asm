RomSize    EQU  4096
NMax       EQU  50
KbdPort    EQU  0
IndicPort  EQU  1

Data       SEGMENT AT 100h

           KbdImage    db 3 dup(?)
           Mode        db ?          
           KbdErr      db ?       
           EmpKbd      db ?       
           NextDig     db ?       
           LockCode    db 9 dup(?)
           ArrayDisp   db 4 dup(?)
           LCD         db 9 dup(?)
           NumDigCode  db ?
           NumDigCode2 db ?
           Buffer      db ?
           Buffer1     db ?
           Block       db ?           
           Open        db ?
           Popitka     db ?
           Delay       dw ?
           Delay1      dw ?
           OldNextDig  db ?
           Tyr         dw ?
           Tyr1        dw ? 
           frg         db ?        
           frg1        db ?        
           frg2        db ?    
           gdr         db ?     
                         
Data       ENDS

Stk        SEGMENT AT 200h
           dw 30 dup (?)
           StkTop Label Word
Stk        ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Data

Images db 3Fh, 0Ch, 76h, 5Eh, 4Dh, 5Bh, 7Bh, 0Eh, 7Fh, 5Fh, 00h

;Модуль 'Функциональная подготовка'
FuncPrep Proc Near
           lea  DI, LockCode
           mov  CX, length LockCode
      FP1: mov  byte ptr [DI], 0
           inc  DI
           loop FP1
           
           mov  Popitka, 0
           mov  Buffer, 0
           mov  Buffer1, 0           
           mov  Open, 0
           mov  Block, 0
           mov  NumDigCode, 0
           mov  NumDigCode2, 0
           mov  Delay, 0
           mov  Delay1, 0
           mov  Tyr, 0
           mov  Tyr1, 3
           mov  frg, 0
           mov  frg1, 0
           mov  frg2, 0
           mov  gdr, 0
           ret
FuncPrep Endp

;Модуль 'Ввод режима'
LockModIn Proc Near
           mov  Mode, 0       ;Режим='Воспроизведение'   
           in   AL, KbdPort
           mov  DX, KbdPort
           call VibrDestr
           test AL, 80h
           jne  LMI1
           mov  Mode, 0FFh    ;Режим='Установка'
     LMI1: ret
LockModIn Endp

;Модуль 'Гашение дребезга'
VibrDestr Proc Near
      VD1: mov  AH, AL
           mov  BH, 0
      VD2: in   AL, DX
           cmp  AH, AL
           jne  VD1
           inc  BH
           cmp  BH, NMax
           jne  VD2
           mov  AL, AH
           ret
VibrDestr Endp

;Модуль 'Ввод с клавиатуры'
KbdInput Proc Near
          lea DI, KbdImage
          xor CL, CL
           
     KI2: mov AL, 1
          shl AL, CL
          or  AL, Buffer
          out KbdPort, AL
          in  AL, KbdPort
          and AL, 0Fh
          jz KI1
          
          mov DX, KbdPort
          call VibrDestr           
          mov [DI], AL
          
     KI3: in AL, KbdPort
          cmp  gdr,1
          jne  KI5     
          inc  Delay1  
          cmp  Delay1,0FFFFh
          jne  KI5
          mov  Delay1,0
          inc  Delay      
     KI5: and AL, 0Fh
          jnz KI3
          jmp KI4
          
     KI1: mov [DI], AL
     KI4: inc DI
          inc CL
          cmp CL, length KbdImage
          jnz KI2
          
          ret
KbdInput Endp

;Модуль 'Контроль ввода с клавиатуры'
KbdInContr Proc Near
           lea SI, KbdImage
           mov CX, 3
           mov DL, 0
     KIC2: mov AL, [SI]
           mov AH, 4
     KIC1: shr AL, 1
           adc DL, 0
           dec AH
           jnz KIC1
           inc SI
           loop KIC2
           
           mov KbdErr, 0
           mov EmpKbd, 0
           cmp DL, 0
           jz KIC3
           cmp DL, 1
           jz KIC4
           mov KbdErr, 0FFh
           jmp KIC4
     KIC3: mov EmpKbd, 0FFh

     KIC4: ret
KbdInContr Endp

;Модуль 'Преобразование очередной цифры'
NxtDigTrf Proc Near
           cmp KbdErr, 0
           jne NDF1
           cmp EmpKbd, 0
           jne NDF1
           
           xor DX, DX
           lea SI, KbdImage
           
     NDF3: mov AL, [SI]
           and AL, 0Fh
           cmp AL, 0
           jnz NDF2
           inc DL
           inc SI
           jmp NDF3
           
     NDF2: shr AL, 1
           jc  NDF4
           inc DH
           jmp NDF2
           
     NDF4: shl DL, 1
           shl DL, 1
           or  DH, DL     
           mov NextDig, DH
           
           cmp frg2,1
           jne H1
           dec frg2
              
       H1: cmp DH, 11
           jb  NDF1
           mov EmpKbd, 0FFh 
                   
     NDF1: ret
NxtDigTrf Endp

;Модуль 'Установка кода 1 уровня'
FormLockCode1 Proc Near
           cmp NumDigCode, 0
           jnz FLC1
           
           cmp Mode, 0
           jnz FLC1
                     
           cmp NumDigCode2, 0
           jnz FLC1
       
           mov  Buffer1, 0
           mov  Open, 0
           mov  Block, 0
           mov  Popitka, 0
           
           or  Buffer, 08h
           mov AL, Buffer
           out KbdPort, AL
                      
           cmp KbdErr, 0
           jne FLC1
           cmp EmpKbd, 0
           jne FLC1
                    
           cmp NextDig,10
           je  FLC4           

           mov DI, 0
           mov CX, 3
     FLC3: mov AL, LockCode[DI+1]
           mov LockCode[DI], AL
           inc DI
           loop FLC3
           
           mov AL, NextDig
           mov LockCode[DI], AL
           jmp FLC1
           
     FLC4: inc NumDigCode2
           inc frg
           inc frg1
           mov NextDig,0
     FLC1: ret
FormLockCode1 Endp

;Модуль 'Установка кода 2 уровня'
FormLockCode2 Proc Near
           cmp NumDigCode, 1
           jnz F1 
           
           cmp Mode, 0
           jz F1
           
           xor AL, AL
           mov AL, LockCode[0]
           cmp LockCode[3],AL
           jg  F2
           sub AL, LockCode[3]
           jmp F3
      F2:  sub AL, LockCode[3]
           neg AL  
      F3:  mov DL, AL
           and DL, 00001000b
           shr DL, 1
           shr DL, 1
           shr DL, 1
           mov LockCode[4], DL
           mov DL, AL
           and DL, 00000100b
           shr DL,1
           shr DL,1
           mov LockCode[5], DL
           mov DL, AL
           and DL, 00000010b
           shr DL,1
           mov LockCode[6], DL
           mov DL, AL
           and DL, 00000001b
           mov LockCode[7], DL
          
       F1: ret
FormLockCode2 Endp

;Модуль 'Установка кода 3 уровня'
FormLockCode3 Proc Near
           cmp NumDigCode, 0
           jnz FL1
           
           cmp Mode, 0
           jnz FL1
                     
           cmp NumDigCode2, 1
           jnz FL1
           
           mov  Buffer, 0
           mov  Buffer1,1
           mov  Open, 0
           mov  Block, 0
           mov  Popitka, 0
                      
           cmp KbdErr, 0
           jne FL1
           cmp EmpKbd, 0
           jne FL1
           
           cmp NextDig,10
           je  FL1
           
           cmp frg1,0         
           je  FL5
           dec frg1
           jmp FL1                       
      FL5: mov AL, NextDig
           mov LockCode[8], AL
                      
     FL1:  ret
FormLockCode3 Endp

;Модуль 'Формирование массива отображения 1 уровня'
FormDisp1 Proc Near
           cmp KbdErr, 0
           jnz FD1
           
           cmp NumDigCode, 0
           jnz FD1
           
           cmp NumDigCode2, 0
           jnz FD1
           
           or  Buffer, 08h
           mov AL, Buffer
           out KbdPort, AL
           
           cmp Mode, 0FFh
           jne FD4
           
           mov  Buffer1, 0
           lea DI, ArrayDisp
           mov CX, 4
      FD2: mov byte ptr [DI], 10
           inc DI
           loop FD2
           
      FD4: cmp Mode, 0
           jne FD1
           
           lea DI, ArrayDisp
           lea SI, LockCode
           mov CX, 4
      FD3: mov AL, [SI]
           mov [DI], AL
           inc SI
           inc DI
           loop FD3
                      
      FD1: ret
FormDisp1 Endp

;Модуль 'Формирование массива отображения 3 уровня'
FormDisp3 Proc Near
           cmp KbdErr, 0
           jnz FF1
           
           cmp NumDigCode, 0
           jnz FF1
           
           cmp NumDigCode2, 1
           jnz FF1   
           
           cmp Mode, 0FFh
           jne FF4
           
           or  Buffer, 08h
           mov AL, Buffer
           out KbdPort, AL
                     
           mov Buffer1, 0           
           lea DI, ArrayDisp
           mov CX, 4
      FF2: mov byte ptr [DI], 10
           inc DI
           loop FF2
           
      FF4: cmp Mode, 0
           jne FF1
           
           cmp NextDig,10
           je FF6  
           mov AL, LockCode[8]
           mov ArrayDisp[0], 10
           mov ArrayDisp[1], 10
           mov ArrayDisp[2], 10
           mov ArrayDisp[3], AL
           jmp FF1
           
     
      FF6: lea DI, ArrayDisp
           lea SI, LockCode
           mov CX, 4
      FF5: mov AL, [SI]
           mov [DI], AL
           inc SI
           inc DI
           loop FF5     
           mov NumDigCode2, 0
                
      FF1: ret
FormDisp3 Endp

;Модуль 'Вывод кода'
OutputCode Proc Near           
           cmp KbdErr, 0
           jnz OC1
                      
           mov CX, 4
           mov DX, IndicPort
           xor DI, DI
           
      OC2: xor AX, AX
           mov AL, ArrayDisp[DI]
           mov SI, AX
           mov AL, Images[SI]
           cmp DX, 4
           jne OC3
           shl AL, 1
           or  Buffer1, AL  
           mov AL, Buffer1  
                    
      OC3: out DX, AL
           inc DI
           inc DX
           loop OC2
      OC1: ret
OutputCode Endp

;Модуль 'Сравнение кода 1 уровня'
CmpCode1 Proc Near
         cmp NumDigCode, 0
         je  BB1
         jmp CC2
BB1:     cmp KbdErr, 0
         je  BB2
         jmp CC2
BB2:     cmp EmpKbd, 0
         je  BB3
         jmp CC2                  
BB3:     cmp Mode, 0
         jne  BB4
         jmp CC2
                       
BB4:     cmp NextDig, 10
         jb  CC0
         mov EmpKbd, 0FFh 
         jmp CC2
             
CC0:     mov Buffer, 0
         mov Buffer, 08h 
         mov DI, Tyr
         mov AL, NextDig
         mov LCD[DI], AL
         inc Tyr  
         cmp Tyr, 4
         je  CC4
         jmp CC2

CC3:     or  Buffer, 20h 
         mov Tyr, 0
         inc Popitka
         jmp CC1   

CC4:     mov DI, 0
         mov CX, 4
CC5:     mov AL, LCD[DI]
         cmp AL, LockCode[DI]   
         jne CC3
         inc DI
         loop CC5
                   
         or  Buffer, 10h
         inc NumDigCode
         mov Popitka, 0
         mov Tyr, 0
               
CC1:     mov AL, Buffer
         mov DX, 10
CC7:     mov CX, 0FFFh
CC6:     out KbdPort, AL
         loop CC6
         dec DX
         jnz CC7
        
         cmp Popitka, 3
         jne CC2
         mov Block, 0FFh  
       
CC2:     ret
CmpCode1 Endp

;Модуль 'Сравнение кода 2 уровня'
CmpCode2 Proc Near
        cmp NumDigCode, 1
        je  B1
        jmp C2
B1:     cmp KbdErr, 0
        je  B2
        jmp C2
B2:     cmp EmpKbd, 0
        je  B3
        jmp C2                  
B3:     cmp Mode, 0
        jne B4
        jmp C2
        
B4:     cmp NextDig, 10
        jb  C0
        mov EmpKbd, 0FFh
        jmp C2 
        
C0:     mov Buffer, 0
        mov DI, Tyr1
        mov AL, NextDig
        mov LCD[DI], AL
        inc Tyr1  
        cmp Tyr1,8
        je  C4
        jmp C1
            
C3:     or  Buffer,20h  
        mov Tyr1, 4
        inc Popitka
        jmp C1   

C4:     mov DI, 4
        mov CX, 4
C5:     mov AL, LCD[DI]
        cmp AL, LockCode[DI]   
        jne C3
        inc DI
        loop C5
                  
        or  Buffer, 10h
        mov Tyr1, 3
        mov Popitka, 0
        inc NumDigCode
                
C1:     mov AL, Buffer
        mov DX, 10
C7:     mov CX, 0FFFh
C6:     out KbdPort, AL
        loop C6
        dec DX
        jnz C7
        inc frg2   
        
        cmp Popitka, 3
        jne C2
        mov Block, 0FFh  
        
C2:    ret
CmpCode2 Endp

;Модуль 'Сравнение кода 3 уровня'
CmpCode3 Proc Near
        cmp NumDigCode, 2
        je V2
        jmp S2
        
V2:     mov AL, 01h
        or Buffer1, AL
        mov AL, Buffer1
        out 4, AL
        mov Buffer, 0       
        
        cmp KbdErr, 0
        je V3
        jmp S2
V3:     cmp EmpKbd, 0
        je V4
        jmp S2   
V4:     cmp Mode, 0
        je  S2
                   
        mov gdr, 1          
        cmp frg2, 0
        jne S2
        
        cmp NextDig, 10
        jb S5
        mov EmpKbd, 0FFh
        jmp S2

S5:     mov AL, NextDig
        cmp AL, LockCode[8]
        jne S3
        cmp Delay,500     ;время удержания клавиши
        jb  S3            
        jmp S4 
        
S3:     or  Buffer,20h  
        inc Popitka
        mov Delay, 0
        mov Delay1, 0
        jmp S1   

S4:     or  Buffer, 10h
        mov Open, 0FFh
        mov Popitka, 0
        
S1:     mov AL, Buffer
        mov DX, 20
Q7:     mov CX, 0FFFh
Q6:     out KbdPort, AL
        loop Q6
        dec DX
        jnz Q7
              
        cmp Popitka, 3
        jne S2
        mov Block, 0FFh
                    
S2:    ret
CmpCode3 Endp

;Модуль 'Открытие замка'
OpenDoor Proc Near
           cmp Open, 0FFh
           jnz OD1
            
           mov AL, 0
           out 4, AL
           
           mov Buffer, 40h
           mov AL, Buffer
           mov DX, 4         ;С помощью регистров CX и DX необходимо
      OD5: mov CX, 0FFFFh    ;подобрать время задержки 5 секунд
      OD4: out KbdPort, AL   
           loop OD4         
           dec DX            
           jnz OD5          
          
           mov Buffer, 0
           mov Open, 0
           mov NumDigCode, 0
           mov Delay,0
           mov Delay1,0
           mov gdr,0  
           
      OD1: ret
OpenDoor Endp

;Модуль 'Блокировка замка'
BlockingOfLock Proc Near
           cmp Block, 0FFh
           jne BOL1
           
           mov DX, 1
     BOL3: mov CX, 0FFFFh    
     BOL2: out KbdPort, AL   
           loop BOL2         
           dec DX            
           jnz BOL3         
           
           mov Buffer, 80h
           mov AL, Buffer    
           mov DX, 10        ;С помощью регистров CX и DX необходимо
     BOL5: mov CX, 0FFFFh    ;подобрать время задержки 64 секунды
     BOL4: out KbdPort, AL   
           loop BOL4         
           dec DX            
           jnz BOL5          
           
           mov Buffer, 0
           mov Block, 0                     
           mov Popitka, 0
           mov Delay,0
           mov Delay1,0

     BOL1: ret
BlockingOfLock Endp
           
Start:
           mov ax,Data
           mov ds,ax
           mov es,ax
           mov ax,Stk
           mov ss,ax
           lea sp,StkTop
                      
           call FuncPrep         ;Подготовка
    Cycle: call LockModIn        ;Ввод режимов   
           call KbdInput         ;Ввод с клавиатуры
           call KbdInContr       ;Проверка ввода с клавиатуры
           call NxtDigTrf        ;Преобразование очередной цифры
           call FormLockCode1    ;Установка кода 1 уровня
           call FormLockCode2    ;Установка кода 2 уровня
           call FormLockCode3    ;Установка кода 3 уровня
           call FormDisp1        ;Формирование массива отображения 1 уровня
           call FormDisp3        ;Формирование массива отображения 3 уровня
           call OutputCode       ;Вывод
           call CmpCode1         ;Проверка набранного кода 1 уровня
           call CmpCode2         ;Проверка набранного кода 2 уровня   
           call CmpCode3         ;Проверка набранного кода 3 уровня  
           call OpenDoor         ;Открытие замка
           call BlockingOfLock   ;Блокировка замка
           jmp Cycle

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
End
