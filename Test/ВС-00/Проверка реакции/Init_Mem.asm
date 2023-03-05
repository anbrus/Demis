Choose_Name  Proc
           Cmp Power,1
           jne TT3
           Cmp Rezult,1
           jne TT3
           Cmp H_Test1,1
           jne TT1
           Cmp Col_Mas_1,0
           je TT1  
           Call KbdInput_1 
           Cmp  EmpKbd, 0FFh
           je  TT3
           Call Scan_Kb_For_Test1
           jmp TT3
TT1:
           Cmp H_Test2,1
           jne TT2
           Cmp Col_Mas_2,0
           je TT2
           Call KbdInput_1 
           Cmp  EmpKbd, 0FFh
           je  TT3
           Call Scan_Kb_For_Test2
           jmp TT3        
TT2:
           Cmp H_Sum,1
           jne TT3
           Cmp Col_Mas_3,0
           je  TT3
           Call KbdInput_1 
           Cmp  EmpKbd, 0FFh
           je  TT3
           Call Scan_Kb_For_Test3 
TT3:
           Ret
Choose_Name  EndP

Scan_Kb_For_Test1 Proc
           mov al,NextDig
           Cmp al, Col_Mas_1
           ja  TT4
           mov si,Offset Mas_1
           Call Set_Offset
           Call Print_Rez
           mov al, NextDig
           ;inc al
           mov Col_New_1, al
TT4:
           Ret
Scan_Kb_For_Test1 EndP

Scan_Kb_For_Test2 Proc
           mov al,NextDig
           Cmp al, Col_Mas_2
           ja  TT5
           mov si,Offset Mas_2
           Call Set_Offset
           Call Print_Rez
           mov al, NextDig
           ;inc al
           mov Col_New_2, al
TT5:
           Ret
Scan_Kb_For_Test2 EndP

Scan_Kb_For_Test3 Proc
           mov al,NextDig
           Cmp al, Col_Mas_3
           ja  TT6
           mov si,Offset Mas_3
           Call Set_Offset
           Call Print_Rez
           mov al, NextDig
           ;inc al
           mov Col_New_3, al
TT6:
           Ret
Scan_Kb_For_Test3 EndP

Set_Offset  Proc
           Xor ax,ax
           mov al,NextDig            ; В dh - смещение цифры в массиве Digit_S (на 1 меньше истин. места)
           dec al
           mov cl,13
           mul cl
           add si,ax
           Ret
Set_Offset  EndP

KbdInput_1 PROC  NEAR
           lea   si,KbdImage_1       ;Загрузка адреса,
           mov   bl,0EFh             ;и номера исходной строки
KIT4:      mov   al,bl       ;Выбор строки
           out   KbdPort,al  ;Активация строки
           in    al,KbdPort  ;Ввод строки
           cmp   al,0FFh
           jz    KIT1        ;Переход, если нет
           mov   dx,KbdPort  ;Передача параметра
           
           mov   [si],al     ;Запись строки
KIT2:      in    al,KbdPort  ;Ввод строки
           cmp   al,0FFh
           jnz   KIT2         ;Переход, если нет        
         
           jmp   SHORT KIT3
KIT1:      mov   [si],al     ;Запись строки
KIT3:     
           Call KbdInContr_1
           Call NxtDigTrf_1
           ret
KbdInput_1 ENDP


KbdInContr_1 PROC  NEAR
           lea   bx,KbdImage_1 ;Загрузка адреса
           mov   EmpKbd,0      ;Очистка флагов
           mov   KbdErr,0
           Xor   dx,dx         ;и накопителя
KIM2:      
           mov   al,ds:[bx]
           cmp   al,0FFh      
           jne   KIM1
           inc   dl          
           jmp   KIM0
KIM1:
           mov   Letter,al
KIM0:
           cmp   dl,1        ;Накопитель=1?
           jne    KIM4        ;Переход, если да           
           mov   EmpKbd,0FFh ;Установка флага пустой клавиатуры
KIM4:
           ret               ;если dl=0 значит всё нормально
KbdInContr_1 ENDP

NxtDigTrf_1 PROC  NEAR
           cmp   EmpKbd,0FFh  ;Пустая клавиатура?
           jz    ND1          ;Переход, если да
           lea   bx,KbdImage  ;Загрузка адреса
           Xor   dx,dx        ;Очистка накопителей кода строки и столбца           
           mov   al,Letter    ;Загрузка реального кода буквы 
           CLC
ND2:      
           Rol   al,1         ;Выделение 0, в dh - номер буквы клавиатуры 
           inc   dh           ;слева на право 1,2,3,...,32
           jc    ND2
           ;dec   dh           ;уменьшаем на 1 (0,1,2,...,31)         
            
           mov   NextDig,dh  ;Запись модифицированого кода цифры
ND1:      
           ret
NxtDigTrf_1 ENDP