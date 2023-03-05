;************************************************************
;** Переходит к следующему элементу массмва Mas_1. (8+4+1) **
;************************************************************
Give_offs_Rez_For_Test_1 Proc
           mov si, offset Mas_1
           Xor ax,ax
           mov al, Col_New_1                     ;Счетчик фамилий в списке "Умст. тест"
           dec al
           mov bl,13
           mul bl
           add si,ax
           Ret
Give_offs_Rez_For_Test_1 EndP

;************************************************************
;** Переходит к следующему элементу массмва Mas_2. (8+4+1) **
;************************************************************
Give_offs_Rez_For_Test_2 Proc
           mov si, offset Mas_2
           Xor ax,ax
           mov al, Col_New_2                     ;Счетчик фамилий в списке "Двиг. тест"
           dec al
           mov bl,13
           mul bl
           add si,ax
           Ret
Give_offs_Rez_For_Test_2 EndP

;************************************************************
;** Переходит к следующему элементу массмва Mas_3. (8+4+1) **
;************************************************************
Give_offs_Rez_For_Test_3 Proc
           mov si, offset Mas_3
           Xor ax,ax
           mov al, Col_New_3                     ;Счетчик фамилий в списке "Суммарно"
           dec al
           mov bl,13
           mul bl
           add si,ax
           Ret
Give_offs_Rez_For_Test_3 EndP

;*****************************************************************************
;** Переходит к следующему участнику по кнопкам навигации для "Умств теста" **
;*****************************************************************************
Scan_Button_For_Test1 Proc
           Cmp Power,1
           jne XO4
           Cmp Rezult,0
           je  XO4
           cmp H_Test1,1
           jne XO4
           cmp Col_Name,0
           je  XO4
           Cmp Col_Mas_1,0
           je  XO4
           cmp Col_New_1,0             ; Выполняет отображение рез. первого участника по умолчанию
           jne LO1
           mov si, offset Mas_1
           Call Print_Rez              
           mov Col_New_1,1
         LO1:
           in al, 00h
           cmp al, 0BFh                           ; Нажата кнопка "Вперёд"
           jne XO1
         XO6:                       
           in  al, 00h
           cmp al, 0FFh
           jne XO6
           
           inc Col_New_1                
           mov al, Col_Mas_1
           cmp Col_New_1,al
           jbe XO1
           mov Col_New_1,1
XO1: 
           Call Give_offs_Rez_For_Test_1     
           Call Print_Rez
XO2: 
           in al, 00h
           cmp al, 07Fh                           ; Нажата кнопка "Назад"
           jne XO3
          XO7:                       
           in  al, 00h
           cmp al, 0FFh
           jne XO7
            
           dec Col_New_1
           cmp Col_New_1,0
           jne XO3
           mov al,Col_Mas_1
           mov Col_New_1,al
XO3: 
           Call Give_offs_Rez_For_Test_1     
           Call Print_Rez
XO4:
           Ret 
Scan_Button_For_Test1 EndP

;*****************************************************************************
;** Переходит к следующему участнику по кнопкам навигации для "Двиг. теста" **
;*****************************************************************************
Scan_Button_For_Test2 Proc
           Cmp Power,1
           jne XQ4
           Cmp Rezult,0
           je  XQ4
           cmp H_Test2,1
           jne XQ4
           cmp Col_Name,0
           je  XQ4
           Cmp Col_Mas_2,0
           je  XQ4
           cmp Col_New_2,0
           jne LQ1
           mov si, offset Mas_2
           Call Print_Rez
           mov Col_New_2,1
         LQ1:
           in al, 00h
           cmp al, 0BFh
           jne XQ1
         XQ6:                       
           in  al, 00h
           cmp al, 0FFh
           jne XQ6
           
           inc Col_New_2
           mov al, Col_Mas_2
           cmp Col_New_2,al
           jbe XQ1
           mov Col_New_2,1
XQ1: 
           Call Give_offs_Rez_For_Test_2     
           Call Print_Rez
XQ2: 
           in al, 00h
           cmp al, 07Fh
           jne XQ3
          XQ7:                       
           in  al, 00h
           cmp al, 0FFh
           jne XQ7
            
           dec Col_New_2
           cmp Col_New_2,0
           jne XQ3
           mov al,Col_Mas_2
           mov Col_New_2,al
XQ3: 
           Call Give_offs_Rez_For_Test_2     
           Call Print_Rez
XQ4:
           Ret 
Scan_Button_For_Test2 EndP

;*******************************************************************************
;** Переходит к следующему участнику по кнопкам навигации для "Суммар. теста" **
;*******************************************************************************
Scan_Button_For_Test3 Proc
           Cmp Power,1
           jne XP4 
           Cmp Rezult,0
           je  XP4
           cmp H_Sum,1
           jne XP4
           cmp Col_Name,0
           je  XP4
           Cmp Col_Mas_3,0
           je  XP4
           cmp Col_New_3,0
           jne LP1
           mov si, offset Mas_3
           Call Print_Rez
           mov Col_New_3,1
         LP1:
           in al, 00h
           cmp al, 0BFh
           jne XP1
         XP6:                       
           in  al, 00h
           cmp al, 0FFh
           jne XP6
           
           inc Col_New_3
           mov al, Col_Mas_3
           cmp Col_New_3,al
           jbe XP1
           mov Col_New_3,1
XP1: 
           Call Give_offs_Rez_For_Test_3     
           Call Print_Rez
XP2: 
           in al, 00h
           cmp al, 07Fh
           jne XP3
          XP7:                       
           in  al, 00h
           cmp al, 0FFh
           jne XP7
            
           dec Col_New_3
           cmp Col_New_3,0
           jne XP3
           mov al,Col_Mas_3
           mov Col_New_3,al
XP3: 
           Call Give_offs_Rez_For_Test_3     
           Call Print_Rez
XP4:
           Ret 
Scan_Button_For_Test3 EndP

Init       Proc
           mov   Col,0
           mov   Col_Name,0 
           Mov   Power,0
           
           mov   dx, 18h
           Xor   ax,ax
           mov   al, Col_Name
           Call  OutPut_Digit
           
           Mov   H_Test1 ,0
           Mov   H_Test2 ,0
           Mov   StratErr,0
           Mov   End_Test,0
           Mov   Go_Test ,0
           Mov   Rezult  ,0
           Mov   No_Name ,0
           Mov   Offs_Name,0
           
           Mov   cx,50h
           mov   bx,offset Grup
aa:
           mov   al,0
           mov   [bx],al
           inc   bx        
           Loop  aa
     
           Xor   ax,ax
           add   ax, Length H_Name
           add   ax, Type   Test1
           add   ax, Type   Test2
           mov   Human_Rec,ax
                      
           mov   Time[0]   , 0 
           mov   Time[1]   , 0 
           mov   Time[2]   , 0 
           mov   Time[3]   , 0
           
           Call Set_Start_Time
           Call Clear_BuFF_Name
           Ret
Init       EndP


;****************************************************************************
;** Копирует данные( фамилию и время ) из основного списка в спомогательный** 
;***************** (si- адрес места, куда капировать) ***********************
;****************************************************************************
Copy_Data  Proc Near
        Push cx
        Push ax
        Mov  cx,Length H_Name
        Xor  di,di
HO1:
        mov  al, Grup[bx].H_Name[di]
        mov  ds:[si], al

        inc  si
        inc  di
        Loop HO1
        pop  ax
        Mov  ds:[si]  , ax
        Mov  ds:[si+2], dx
        add  si,4
        pop  cx
        Ret
Copy_Data EndP

Scan_Data_Test_2 Proc
           mov ax,word ptr Grup[bx].Test2
           mov dx,word ptr Grup[bx].Test2+2
           cmp ax,0
           je RR1
           Call Sum
           Call Copy_Data
           inc Col_Mas_3
           mov al, Col_Mas_3
           mov ds:[si],al
           inc  si
           jmp RR2
RR1:
           cmp dx,0
           je RR2
           Call Sum
           Call Copy_Data           
           inc Col_Mas_3 
           mov al, Col_Mas_3
           mov ds:[si],al
           inc  si
RR2:      
           Ret
Scan_Data_Test_2 EndP

;****************************************************************************************
;** Определяет какие данные в какой список перенести. (Вызыв. после наж. "Результаты") ** 
;****************************************************************************************
FindRez  Proc Near
           cmp Col_Name,0
           je  H4
           Mov si, offset Mas_1
           Xor cx,cx
           mov cl,Col_Name
           Xor bx,bx
           Mov Col_Mas_1,0
H1:
           mov ax,word ptr Grup[bx].Test1
           mov dx,word ptr Grup[bx].Test1+2
           cmp ax,0
           je  H2
           Call Copy_Data
           inc Col_Mas_1
           mov al, Col_Mas_1
           mov ds:[si],al 
           inc  si
           jmp H3
       H2:
           cmp dx,0
           je  H3
           Call Copy_Data
           inc Col_Mas_1
           mov al, Col_Mas_1
           mov ds:[si],al
           inc  si
       H3:
           add bx, Human_Rec
           Loop H1
H4:
           cmp Col_Name,0
           je H8
           Mov si, offset Mas_2
           Xor cx,cx
           mov cl,Col_Name
           Xor bx,bx
           Mov Col_Mas_2,0
H5:
           mov ax,word ptr Grup[bx].Test2
           mov dx,word ptr Grup[bx].Test2+2
           cmp ax,0
           je  H6
           Call Copy_Data
           inc Col_Mas_2
           mov al, Col_Mas_2
           mov ds:[si],al
           inc  si
           jmp H7
       H6:
           cmp dx,0
           je  H7
           Call Copy_Data
           inc Col_Mas_2
           mov al, Col_Mas_2
           mov ds:[si],al
           inc  si
       H7:
           add bx, Human_Rec
           Loop H5
H8:
           cmp Col_Name,0
           je H14
           Mov si, offset Mas_3
           Xor cx,cx
           mov cl,Col_Name
           Xor bx,bx
           Mov Col_Mas_3,0
H9:
           mov ax,word ptr Grup[bx].Test1
           mov dx,word ptr Grup[bx].Test1+2
           mov word ptr Time,ax
           mov word ptr Time+2,dx 
           cmp ax,0
           je  H11
           Call Scan_Data_Test_2
           jmp H13
       H11:
           Cmp dx,0
           je H13
           Call Scan_Data_Test_2
       H13:
           add bx, Human_Rec
           Loop H9 
           ; Вызов процедуры сортировки по всем тестам
H14:
           Cmp Col_Mas_1,1
           jbe H16
           Call Sort_For_Test_1
H16:           
           Cmp Col_Mas_2,1
           jbe H17
           Call Sort_For_Test_2
H17:
           Cmp Col_Mas_3,1
           jbe H15
           Call Sort_For_Test_3                
H15:
           Ret
FindRez  EndP

;*********************************
;** Выводит результаты на экран ** 
;*********************************
Print_Rez Proc
           mov bx, offset Buff_Name
           mov cx, Length H_Name
KO1:
           mov al, ds:[si]
           mov [bx], al
           inc bx
           inc si
           Loop KO1
          
           Mov cx, 4
           mov dx, 10h
KO2:      
           mov bx,offset Digit_s
           Xor ax,ax
           mov al, ds:[si]
           add ax,bx
           mov bx,ax
           mov al, [bx]
           out dx, al
           inc dx
           inc si
           Loop KO2
           
           mov  bx, offset Digit_s
           Xor  ax,ax
           mov  al,ds:[si]
           add  bx,ax
           mov  al,[bx]
           out  19h, al 
           Ret
Print_Rez EndP

Sum       Proc
           push bx cx si
           
           mov  bx,ax                    ; Складываем побайтно результаты
           ClC
           add  al, Time           
           AAA  
           mov  Time, al
           mov  al,bh
           adc  al, Time+1
           AAA
           mov  Time+1,al
           mov  ax,dx
           adc  al,Time+2
           AAA
           Mov  Time+2,al
           mov  al,dh
           adc  al,Time+3
           AAA  
           mov  Time+3,al
           mov  bl,2                     ; Далее делим побайтно
           Xor  ax,ax
           mov  al, Time+3
           div  bl
           mov  Time+3, al
           mov  al, Time+2
           AAD
           div  bl
           mov  Time+2,al
           mov  al, Time+1
           AAD
           div  bl
           Mov  Time+1,al
           Mov  al,Time
           AAD
           div bl
           Mov  Time,al
           
           mov  ax, Word ptr Time        ; Сохраняем результаты 
           mov  dx, Word ptr Time+2
           mov  cx,4
           mov  si,offset Time           ; Очищаем то, что испортили
SS1:
           Mov  byte ptr ds:[si],0
           inc  si
           Loop SS1
           pop  si cx bx           
           Ret
Sum       EndP

Give_Power  Proc 
           Cmp Power,1
           je MM1
MM:
           in al, 4h
           Test al, 4h
           jnz MM
           mov al, 4h
           out 14h, al
           Call Initilize
           Mov Power, 1
MM1:
           Ret
Give_Power  EndP

Out_Power   Proc
           in al, 4h 
           Test al, 4h
           jz CC1
           mov al,0
           out 14h, al
           out 18h, al
           out 19h, al
           out 15h, al
           mov cx,4
           mov dx,10h
CC:
           out dx,al
           inc dx          
           Loop CC
           Call Clear_Buff_Name
           mov Power,0
CC1:
           Ret
Out_Power   EndP

Clear_Name  Proc
           Cmp Power,1
           jne VV
           Cmp Rezult,0
           jne VV
           in al, 04h
           Test al, 2h
           jnz  VV
           Call Clear_Buff_Name
           Mov  Col,0
VV:
           Ret 
Clear_Name  EndP

Proc       XCHG_For_Test_1
           push cx bx dx si di 
           mov  cx,Length P_Name
           mov  bx,0
GG1:
           mov  al, byte ptr Mas_1[si].P_Name+bx
           XchG al, byte ptr Mas_1[di].P_Name+bx
           mov byte ptr Mas_1[si].P_Name+bx, al
           inc  bx                        
           Loop GG1
              
           mov  cx,Type Rez_Test
           mov  bx,0
GG2:
           mov  al, byte ptr Mas_1[si].Rez_Test+bx
           XchG al, byte ptr Mas_1[di].Rez_Test+bx
           mov byte ptr Mas_1[si].Rez_Test+bx, al
           inc  bx                        
           Loop GG2

           pop  di si dx bx cx
           Ret
XCHG_For_Test_1  EndP

Sort_For_Test_1 Proc
           Xor  di, di
           add  di, Length P_Name
           add  di, Type Rez_Test
           inc  di
           mov  dx, di                       ; В dx - смещение элементов в массиве
FF1:
           Xor  cx,cx
           Xor  di,di
           mov  si,0           
           mov  cl,Col_Mas_1                 ; Загрузка элементов в массиве
           dec  cl                           ; Число перестановок на одно меньше  
           mov  XH,0
FF2:
           push cx
           mov  cx,Type Rez_Test             ; Загрузка длинны времени
           mov  bx,cx                                ; Смешение секунд
           dec  bx                           ; bx = 3
           add  di,dx                        ; Загрузка следующего участника
FF3:           
           Mov  al, byte ptr Mas_1[si].Rez_Test+bx       
           Mov  ah, byte ptr Mas_1[di].Rez_Test+bx
           cmp  al, ah                       ; Если равны, то переходим к следующему знаку
           je   FF4
           cmp  al, ah                       ; Если меньще, то всё нармально смещ. к следующему рез-тату
           jb   FF5
           mov  XH,1                         ; Иначе обмен
           Call XCHG_For_Test_1
           jmp  FF5
FF4:
           dec  bx                       
           dec  cx
           jnz  FF3
FF5:           
           mov   si,di
           pop   cx
           Loop  FF2
           
           cmp   XH, 0
           jne   FF1                         ; Если перестановки были, то повторить всё заново
           
           Xor   cx,cx
           mov   cl, Col_Mas_1
           mov   H_Plase,0
           mov   si, 0
FF6:                 
           inc H_Plase
           mov al,H_Plase
           mov Mas_1[si].Plase,al
           add si,13
           Loop  FF6
           
           Ret
Sort_For_Test_1 EndP

Proc       XCHG_For_Test_2
           push cx bx dx si di 
           mov  cx,Length P_Name
           mov  bx,0
DD1:
           mov  al, byte ptr Mas_2[si].P_Name+bx
           XchG al, byte ptr Mas_2[di].P_Name+bx
           mov byte ptr Mas_2[si].P_Name+bx, al
           inc  bx                        
           Loop DD1
              
           mov  cx,Type Rez_Test
           mov  bx,0
DD2:
           mov  al, byte ptr Mas_2[si].Rez_Test+bx
           XchG al, byte ptr Mas_2[di].Rez_Test+bx
           mov byte ptr Mas_2[si].Rez_Test+bx, al
           inc  bx                        
           Loop DD2

           pop  di si dx bx cx
           Ret
XCHG_For_Test_2  EndP

Sort_For_Test_2 Proc
           Xor  di, di
           add  di, Length P_Name
           add  di, Type Rez_Test
           inc  di
           mov  dx, di                       ; В dx - смещение элементов в массиве
NN1:
           Xor  cx,cx
           Xor  di,di
           mov  si,0           
           mov  cl,Col_Mas_2                 ; Загрузка элементов в массиве
           dec  cl                           ; Число перестановок на одно меньше  
           mov  XH,0
NN2:
           push cx
           mov  cx,Type Rez_Test             ; Загрузка длинны времени
           mov  bx,cx                                ; Смешение секунд
           dec  bx                           ; bx = 3
           add  di,dx                        ; Загрузка следующего участника
NN3:           
           Mov  al, byte ptr Mas_2[si].Rez_Test+bx       
           Mov  ah, byte ptr Mas_2[di].Rez_Test+bx
           cmp  al, ah                       ; Если равны, то переходим к следующему знаку
           je   NN4
           cmp  al, ah                       ; Если меньще, то всё нармально смещ. к следующему рез-тату
           jb   NN5
           mov  XH,1                         ; Иначе обмен
           Call XCHG_For_Test_2
           jmp  NN5
NN4:
           dec  bx                       
           dec  cx
           jnz  NN3
NN5:           
           mov   si,di
           pop   cx
           Loop  NN2
           
           cmp   XH, 0
           jne   NN1                         ; Если перестановки были, то повторить всё заново
           
           Xor   cx,cx
           mov   cl, Col_Mas_2
           mov   H_Plase,0
           mov   si, 0
NN6:                 
           inc H_Plase
           mov al,H_Plase
           mov Mas_2[si].Plase,al
           add si,13
           Loop  NN6
           
           Ret
Sort_For_Test_2 EndP

Proc       XCHG_For_Test_3
           push cx bx dx si di 
           mov  cx,Length P_Name
           mov  bx,0
ZZ1:
           mov  al, byte ptr Mas_3[si].P_Name+bx
           XchG al, byte ptr Mas_3[di].P_Name+bx
           mov byte ptr Mas_3[si].P_Name+bx, al
           inc  bx                        
           Loop ZZ1
              
           mov  cx,Type Rez_Test
           mov  bx,0
ZZ2:
           mov  al, byte ptr Mas_3[si].Rez_Test+bx
           XchG al, byte ptr Mas_3[di].Rez_Test+bx
           mov byte ptr Mas_3[si].Rez_Test+bx, al
           inc  bx                        
           Loop ZZ2

           pop  di si dx bx cx
           Ret
XCHG_For_Test_3  EndP

Sort_For_Test_3 Proc
           Xor  di, di
           add  di, Length P_Name
           add  di, Type Rez_Test
           inc  di
           mov  dx, di                       ; В dx - смещение элементов в массиве
WW1:
           Xor  cx,cx
           Xor  di,di
           mov  si,0           
           mov  cl,Col_Mas_3                 ; Загрузка элементов в массиве
           dec  cl                           ; Число перестановок на одно меньше  
           mov  XH,0
WW2:
           push cx
           mov  cx,Type Rez_Test             ; Загрузка длинны времени
           mov  bx,cx                                ; Смешение секунд
           dec  bx                           ; bx = 3
           add  di,dx                        ; Загрузка следующего участника
WW3:           
           Mov  al, byte ptr Mas_3[si].Rez_Test+bx       
           Mov  ah, byte ptr Mas_3[di].Rez_Test+bx
           cmp  al, ah                       ; Если равны, то переходим к следующему знаку
           je   WW4
           cmp  al, ah                       ; Если меньще, то всё нармально смещ. к следующему рез-тату
           jb   WW5
           mov  XH,1                         ; Иначе обмен
           Call XCHG_For_Test_3
           jmp  WW5
WW4:
           dec  bx                       
           dec  cx
           jnz  WW3
WW5:           
           mov   si,di
           pop   cx
           Loop  WW2
           
           cmp   XH, 0
           jne   WW1                         ; Если перестановки были, то повторить всё заново
           
           Xor   cx,cx
           mov   cl, Col_Mas_3
           mov   H_Plase,0
           mov   si, 0
WW6:                 
           inc H_Plase
           mov al,H_Plase
           mov Mas_3[si].Plase,al
           add si,13
           Loop  WW6
           
           Ret
Sort_For_Test_3 EndP

;************************************************************
;** Выводит цифру на экран. (dx - номер порта, ax - цифра) **
;************************************************************
OutPut_Digit  Proc
           push bx ax
           mov bx,Offset Digit_S
           add bx, ax
           mov al, [bx]           
           out dx, al
           pop ax bx
           Ret
OutPut_Digit  EndP

Rez_Delay  proc  near
           push  cx ax dx
           mov   cx,00035h
Delay1:
           inc   cx
           dec cx
           inc   cx
           dec cx
           push  cx
           Call  L_Input        ; Перерисовываем фамилию, чтобы не было мигания 
           pop   cx
           loop  Delay1
           pop   dx ax cx
           ret
Rez_Delay  endp