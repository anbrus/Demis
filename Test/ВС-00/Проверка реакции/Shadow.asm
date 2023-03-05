
;Задайте объём ПЗУ в байтах
RomSize         EQU   4096
KbdPort         EQU    16h 
StrategyPort    EQU     0h
ActionPort      EQU     1h 
TimePort_sot_1  EQU    10h 
TimePort_sot_2  EQU    11h 
TimePort_sec_1  EQU    12h 
  

Human_1     STRUC
    H_Name   db 8  dup  (?)
    Test1    dd     (?)
    Test2    dd     (?)
Human_1     EndS

Human     STRUC
    P_Name   db 8  dup  (?)
    Rez_Test dd         (?)
    Plase    db         (?)
Human     EndS

IntTable   SEGMENT AT 0 use16
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT AT 40h use16

Letters      db   4*9*7 dup (?)
Col          db              ?   ; Текущая длинна фамилии (постояно изменяется)
Col_Name     db              ?   ; Количество фамилий 
Grup       Human_1  5    dup (?)
KbdImage     DB     4    DUP (?)
Error        DB     4    DUP (?)  ; Хранит образ слова "Err"
Time         DB     4    DUP (?)  ; Хранит время теста
Digit_s      DB     10   DUP (?)  ; Хранит время теста
BuFF_Name    DB     8    DUP (?)  ; Хранит имя участника теста в Rial Time
Mas_1      Human    5    dup (?)
Mas_2      Human    5    dup (?)
Mas_3      Human    5    dup (?)
Col_Mas_1    DB             ?
Col_Mas_2    DB             ?
Col_Mas_3    DB             ?
Col_New_1    DB             ?
Col_New_2    DB             ?
Col_New_3    DB             ?
Letter       DB             ?
EmpKbd       DB             ?
KbdErr       DB             ?
KbdUnc       DB             ?
NextDig      DB             ?
Base         DW             ?
H_Test1      DB             ?  ; Режим проверки механической реакции
H_Test2      DB             ?  ; Режим проверки умственной   реакции
H_Sum        DB             ?  ; Режим проверки умственной   реакции
StratErr     DB             ?  ; Флаг, отсутствия выбора теста  
End_Test     DB             ?  ; Флаг конца теста
Go_Test      DB             ?  ; Флаг начала теста
No_Name      DB             ?  ; Флаг отсутствия фамилии участника теста
Randoom      DW     7   DUP (?)  ;
offs         DW             ?  ; 
Right_Dig    DB             ?  ; Правильный код кнопки, которую нужно нажать (Тест №2)
Kol          DB             ?  ; Счётчик, нужен для изображения времени 
Rezult       DB             ?  ; Режим просмотра результатов
My_Test      DB             ?  ; Режим тестирования 
Human_Rec    dw             ?  ; Длинна элемента массива Grup
Offs_Name    dw             ?  ; Смещение фамилии в списке
XH           db             ?
H_Plase      db             ?
KbdImage_1   db             ?
Power        db             ? 
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 500h use16
;Задайте необходимый размер стека
           dw    15 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант
InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data,es:Data

Clear_BuFF_Name Proc
           mov Cx,Length BuFF_Name
           mov si,offset BuFF_Name
X1:
           mov byte ptr ds:[si],224
           inc  si
           Loop X1
           Ret
Clear_BuFF_Name EndP

Delay      proc  near
           push  cx ax dx
           mov   cx,5;000Ah
DelayLoop:
           inc   cx
           dec cx
           inc   cx
           dec cx
           push  cx
           Call  L_Input        ; Перерисовываем фамилию, чтобы не было мигания 
           pop   cx
           loop  DelayLoop
           pop   dx ax cx
           ret
Delay      endp

Set_Start_Time Proc Near
           Mov   cx,Length Time
           Lea   si,Time
           mov   al,0
A0:
           mov  ds:[si],al
           inc si
           Loop  A0
           Mov   cx,Length Time
           Lea   si,Time
           Lea   bx,Digit_s
           mov   dx,10h
A1:
           Xor   ax,ax
           mov   al, ds:[si]
           mov   di, ax        
           mov   al, ds:[bx+di]
           out   dx, al
           inc   dx
           inc   si
           Loop A1
           Ret  
Set_Start_Time EndP


KbdInput   PROC  NEAR
           Cmp Power,1
           jne KI5
           Cmp Rezult,0
           jne KI5
           lea   si,KbdImage         ;Загрузка адреса,
           mov   cx,LENGTH KbdImage  ;счётчика циклов
           mov   bl,0FEh             ;и номера исходной строки
KI4:       mov   al,bl       ;Выбор строки
           out   KbdPort,al  ;Активация строки
           in    al,KbdPort  ;Ввод строки
           cmp   al,0FFh
           jz    KI1         ;Переход, если нет
           mov   dx,KbdPort  ;Передача параметра
           
           mov   [si],al     ;Запись строки
KI2:       in    al,KbdPort  ;Ввод строки
           cmp   al,0FFh
           ;push  cx
           ;pop   cx
           jnz   KI2         ;Переход, если нет        
         
           jmp   SHORT KI3
KI1:       mov   [si],al     ;Запись строки
KI3:       inc   si          ;Модификация адреса
           rol   bl,1        ;и номера строки
           loop  KI4         ;Все строки? Переход, если нет
KI5:
           ret
KbdInput   ENDP

KbdInContr PROC  NEAR
           Cmp Power,1
           jne KIC4
           Cmp Rezult,0
           jne KIC4 
           lea   bx,KbdImage ;Загрузка адреса
           mov   cx,LENGTH KbdImage  ;счётчика циклов
           mov   EmpKbd,0    ;Очистка флагов
           mov   KbdErr,0
           Xor   dx,dx       ;и накопителя
KIC2:      
           mov   al,ds:[bx]
           cmp   al,0FFh      
           jne   KIC1
           inc   dl          
           jmp   KIC0
KIC1:
           mov   Letter,al
           mov   ax,bx
           sub   ax, OFFSET KbdImage
           mov   base,ax     ;Запоминаем номер строки (0,1,2,3) 
KIC0:
           inc   bx          ;Модификация адреса строки
           loop  KIC2        ;Все строки? Переход, если нет

           cmp   dl,4        ;Накопитель=4?
           je    KIC3        ;Переход, если да
           cmp   dl,3        ;Накопитель=3?
           je    KIC4        ;Переход, если да
           mov   KbdErr,0FFh ;Установка флага ошибки
           jmp   SHORT KIC4
KIC3:      mov   EmpKbd,0FFh ;Установка флага пустой клавиатуры
KIC4:
           ret               ;если dl=3 значит всё нормально
KbdInContr ENDP

NxtDigTrf  PROC  NEAR
           Cmp Power,1
           jne NDT1
           Cmp Rezult,0
           jne NDT1
           cmp   EmpKbd,0FFh  ;Пустая клавиатура?
           jz    NDT1         ;Переход, если да
           cmp   KbdErr,0FFh  ;Ошибка клавиатуры?
           jz    NDT1         ;Переход, если да
           lea   bx,KbdImage  ;Загрузка адреса
           Xor   dx,dx        ;Очистка накопителей кода строки и столбца           
           mov   al,Letter    ;Загрузка реального кода буквы 
           CLC
NDT2:      
           Rol   al,1         ;Выделение 0, в dh - номер буквы клавиатуры 
           inc   dh           ;слева на право 1,2,3,...,32
           jc    NDT2
           dec   dh           ;уменьшаем на 1 (0,1,2,...,31)         
            
           mov   NextDig,dh  ;Запись модифицированого кода цифры
NDT1:      
           ret
NxtDigTrf  ENDP

Print      Proc  Near
           Cmp Power,1
           jne NO1
           Cmp Rezult,0
           jne NO1 
           cmp   KbdErr,0FFh
           jz    NO1
           cmp   EmpKbd,0FFh
           jz    NO1
           xor   ah,ah
           mov   al,NextDig
           mov   bx,base    ; В BASE- смещение строки "линейки" клавиатуры (0,1,2,3)
           mov   cl,7        
           mul   cl         ; получение смещения буквы в строке (каждая кодируется 7 байтами)
           mov   dx,ax
           mov   ax,bx
           mov   cl,56
           mul   cl         ; получение смещения строки в массиве образов (в строке 8 букв - 8*7=56 байтов)
           add   ax,dx      ; окончательный адрес буквы в массиве
           Xor   bx,bx
           cmp   Col,7      ; если больше чем 8 букв (нумерация с 0!!!!!!)
           jne   NO2
           mov   Col,0
NO2:           
           Cmp   Col,0
           jne   NO3
           Call  Clear_BuFF_Name
NO3:
           mov   bl,Col     ; В bl - смещение очередной буквы фамилии
           mov   si,bx
           Mov   BuFF_Name[si], al ; заносим коды букв фамилии последовательно
           inc   Col
NO1:           
           Ret
Print      EndP

L_Input    Proc
           Push  si
           Cmp Power,1
           jne M11 
           ;cmp   Col,0
           ;je    M11
           Call  In_Letter
M11:
           pop   si
           Ret
L_Input    EndP

;***************************************************
;** Читает буфер с фамилией и выводит её на экран **
;***************************************************
In_Letter  Proc  Near              
           mov   dx,1              ; Первый порт =1
           mov   al,1
           
           mov   cx,7              ; Активизация матриц (1..7)
M0:
           out   dx,al
           inc   dx
           Shl   al,1             
           Loop  M0
           
           mov   dx,8              ; Вывод букв фамилии в цикле на индикаторы(в dx - номер первого порта столбцов)
           Xor   cx,cx
           mov   cl, 8;Col            ; Загрузка счётчика букв (внешний цикл)
           mov   si,0              ; Встаём на первую букву фамилии
M1:           
           Xor   ax,ax
           mov   al,BuFF_Name[si]
           mov   bx,ax             ; Смещение буквы в массиве образов
           push  cx                ; Вывод одной буквы в цикле на индикаторы, запоминаем старое значение счётчика
           mov   cx,7              ; Загрузка счётчика строк матрицы (внутренний цикл)
           mov   al,1
M2:
           out   0,al
           shl   al,1              ; Пробегаем последовательно все строки
           push  ax                ; Запоминаем состояние строки  
           mov   al,ds:[bx]        ; Активизируем нужные столбцы
           out   dx,al
          
           mov   al,0              ; Стераем код столбцов 
           out   dx,al
           pop   ax                ; Восстанавливаем код строки
           inc   bx                ; Переход к следующему байту буквы (всего 7)
           Loop  M2
           inc   si                ; Следующая буква фамилии
           pop   cx                ; Восстанавливаем счетчик букв фамилии
           inc   dx                ; Переходим к следующей матрице
           Loop  M1
            
           Ret
In_Letter  EndP                    

;****************************************** Новые процедуры ********************************

StrError   Proc   Near             ; Вывод сообщения об ошибке( для всех видов ошибок)
           mov   cx,Length Error
           mov   bx,offset Error
           mov   dx,13h            ; В dx - номер первого порта вывода
S1:
           mov   al,ds:[bx]
           out   dx,al
           dec   dx
           inc   bx
           Loop  S1
           
           ;*********
           Mov  al,0
           out  15h,al
           ;***********
           Ret
StrError   EndP

;*********************************************************************************
;** Определяет тестировался ли человек по умст. тесту.(Вызыв. при наж. "Старт") **
;*********************************************************************************
Scan_Test1 Proc 
           mov bx, Offs_Name
           mov ax, word ptr Grup[bx].Test1
           mov dx, word ptr Grup[bx].Test1+2
           cmp ax,0
           jne LA 
           cmp dx,0
           jne LA
           Call Set_Start_Time 
           Mov H_Test1,1 
           Mov H_Test2,0        
           Call  Strategy_1
           jmp E1
LA:
           Mov Go_test,0
E1:
           Ret
Scan_Test1 Endp

;*********************************************************************************
;** Определяет тестировался ли человек по двиг. тесту.(Вызыв. при наж. "Старт") **
;*********************************************************************************
Scan_Test2 Proc            
           mov bx, Offs_Name
           mov ax, word ptr Grup[bx].Test2
           mov dx, word ptr Grup[bx].Test2+2
           cmp ax,0
           jne LA1 
           cmp dx,0
           jne LA1
           Mov H_Test2,1          
           Mov H_Test1,0
           Call Set_Start_Time 
           Call  Strategy_2
           jmp E2
LA1:
           Mov Go_test,0
E2:
           Ret
Scan_Test2 Endp

Set_Flag_For_Test1 Proc
           mov H_Test1,1
           mov H_Test2,0
           mov H_Sum  ,0
           Ret
Set_Flag_For_Test1 endP

Set_Flag_For_Test2 Proc
           mov H_Test2,1
           mov H_Test1,0
           mov H_Sum  ,0
           Ret
Set_Flag_For_Test2 endP

Set_Flag_For_RezSum Proc
           mov H_Sum  ,1
           mov H_Test2,0
           mov H_Test1,0           
           ;mov al,90h
           ;out 14h,al
           Ret
Set_Flag_For_RezSum endP

;********************************************************
;** Определяет какой из тестов выбран.(Вызыв постояно) **
;********************************************************
Choose_Strategy  Proc  Near
           Cmp Power,1
           jne L12
           Cmp My_Test,1               ; Режим "Теста" включен
           jne L1
           in  al,StrategyPort
           cmp al, 0FBh                ; Выбран умственный тест
           jne L2
           Call Set_Start_Time
           Call Set_Flag_For_Test1
           mov al,64h
           out 14h,al
           jmp L5
   L2:
           Cmp al, 0F7h                ; Выбран двигательный тест
           jne L5
           Call Set_Start_Time
           Call Set_Flag_For_Test2
           mov al,0A4h
           out 14h,al
           jmp L5
L12:
           jmp L5
L1:
           Cmp Rezult,1                ; Режим "Просмотра результатов" включен
           jne L5
           cmp al, 0FBh                ; Выбран режим просмотра "Умственный тест"
           jne L3
           Call Set_Flag_For_Test1
           mov al,54h
           out 14h,al                      
           ; Вызов процедуры сортировки для "Умственный тест", а затем обработчика кнопок навигации 
           Call Set_Start_Time
           Cmp Col_Mas_1,0
           jne L5
           Call Clear_Buff_Name 
           mov al,0
           out 19h,al
           jmp L5
   L3:
           Cmp al, 0F7h                ; Выбран режим просмотра "Двигательный тест"
           jne L4
           Call Set_Flag_For_Test2
           mov al,94h
           out 14h,al
           ; Вызов процедуры сортировки для "Двигательный тест", а затем обработчика кнопок навигации
           Call Set_Start_Time
           Cmp Col_Mas_2,0
           jne L5
           Call Clear_Buff_Name 
           mov al,0
           out 19h,al
           jmp L5
   L4:
           Cmp al, 0EFh                ; Выбран режим просмотра общего результата
           jne L5
           mov al ,1Ch
           out 14h,al
           Call Set_Flag_For_RezSum
           Call Set_Start_Time
           Cmp Col_Mas_3,0
           jne L5
           Call Clear_Buff_Name 
           mov al,0
           out 19h,al
           ; Вызов процедуры сортировки для Суммарного результата, а затем обработчика кнопок навигации
L5:
           Ret 
Choose_Strategy  EndP

;***************************************************************************
;** Определяет работу умственного теста.(Вызов. в обработчике Scan_Test1) **
;***************************************************************************
Strategy_1   Proc  Near
           mov  al,  1
           mov  cx  ,4
R1:           
           Out 17h, al
           shl  al, 1
           push ax cx
           Call Delay            
           pop  cx ax
           Loop R1
           mov  al,  0   ; Гасим все лампочки
           Out  17h, al
           mov  Right_Dig, 0FDh          ; Запоминаем условие выхода (Пригодится если участник тормоз)
;R2:
;           ;Вызов процедуры подсчёта времени
;           Call  L_Input
;           in   al, OperationPort        
;           Cmp  al, 0FDh                 ; Нажата кнопка "Стоп"           
;           jne R2
           Call Set_Time
           
           mov bx,Offs_Name
           mov al,Time[0]
           mov byte ptr Grup[bx].Test1+0,al
           mov al,Time[1]
           mov byte ptr Grup[bx].Test1+1,al
           mov al,Time[2]
           mov byte ptr Grup[bx].Test1+2,al
           mov al,Time[3]
           mov byte ptr Grup[bx].Test1+3,al
           
           ; Запись времени
           ; Инициализация начальных значений            
           Mov Go_Test,0
           ; Запись времени
           ; Инициализация начальных значений  
           mov cx,4
           mov bx, offset Time
R2:
           mov byte ptr ds:[bx],0
           inc bx
           Loop R2
           Call Rez_Delay 
           Call Set_Start_Time       
           Ret   
Strategy_1   EndP       

;****************************************************************************
;** Производит подсчёт времени.(Вызов. постояно в обработчике кажд. теста) **
;****************************************************************************
Set_Time     Proc  Near
;------------------ Внимание!!!!!! Далее идёт подсчёт времени  ------------------------ ; 
T2:                                                       
           Call  L_Input                 ; Прорисовка имени, к сожелению это нужно делать
           
           ; *********************
           mov  bx, offset Digit_s
           mov  si, offset Time
           mov  dx, 10h                  ; Адрес порта для изображения сотых
           mov  Kol,0
   T3:           
           mov  al, ds:[si]
           inc  al
           AAA 
           Xor  ah,ah
           mov  di, ax
           mov  al, ds:[bx+di]
           out  dx, al
           mov  ax,di          
           mov  ds:[si], al
           cmp  kol,3
           jne  T5
           mov  al, Right_Dig            ; Код правильной кнопки. Делаем это за вас хе,хе,хе
           jmp  T6
   T5:       
           cmp  al, 0
           jne  T4
           inc  dx
           inc  si
           inc  Kol
           jmp  T3  
T4:                      
           ; ********************           
           in   al, ActionPort        
T6:
           Cmp  al, Right_Dig            ; Проверка нажатия соответствующей кнопки  
           jne T2             
           Ret 
Set_Time     EndP

;*****************************************************************************
;** Определяет работу двигательного теста.(Вызов. в обработчике Scan_Test2) **
;*****************************************************************************
Strategy_2   Proc  Near  
           mov  si,offs
           mov  al,ds:[si]
           and  al,3Fh
           
           Xor  cx,cx
           mov  cl,al
           mov  ax,offs                    ; Используем этот остаток 
T1:           
           mov  bx,343
           mul  bx
           mov  bx,55634
           div  bx
           mov  ax,dx
           push  ax cx
           Call  L_Input            
           pop   cx ax 
           Loop T1
           mov  offs,ax
           Xor  dx,dx
           mov  bx,5
           div  bx

                     
           Lea  bx, Digit_s              ; Загрузка начального адреса массива образов цифр
           add  bx,dx
           inc  bx                       ; Чтобы не выводить "0" 
           Mov  al, ds:[bx]              ; Выводим это число
           Out  15h,al 
           
           mov  al,0FBh
           mov  cx,dx
           Rol  al,cl
           mov  Right_Dig,al
           
           Call Set_Time
           
           mov  al,0
           Out  15h,al        
           Mov Go_Test,0
           ; Запись времени
           
           mov bx,Offs_Name
           mov al,Time[0]
           mov byte ptr Grup[bx].Test2+0,al
           mov al,Time[1]
           mov byte ptr Grup[bx].Test2+1,al
           mov al,Time[2]
           mov byte ptr Grup[bx].Test2+2,al
           mov al,Time[3]
           mov byte ptr Grup[bx].Test2+3,al
           
           ; Инициализация начальных значений  
           Mov Go_Test,0
           
           mov cx,4
           mov bx, offset Time
T7:
           mov byte ptr ds:[bx],0
           inc bx
           Loop T7       
           Call Rez_Delay 
           Call Set_Start_Time  
           
           Ret   
Strategy_2   EndP

;*********************************************************************************
;** Переписывает фамилию из буфера в список.(Вызов. после проц. Scan_Name) **
;*********************************************************************************
Mov_Name     Proc
             mov cx, Length H_Name
             mov bx, offs_Name
             mov di, 0
             mov si, offset Buff_Name
B1:
             mov al, ds:[si]         
             mov Grup[bx].H_Name[di],al
             inc di
             inc si
             Loop B1
             Ret
Mov_Name     EndP

;***************************************************************************************
;** Производит проверку на ранее введёную фамилию.(Вызов. после нажат кнопки "Старт") **
;***************************************************************************************
Scan_Name    Proc
             Cmp Col_Name,0             ; Если фамилий в списке нет, то не нужно искать дубля
             je  M7
             Xor cx,cx
             Xor bx,bx
             Mov cl,Col_Name            ; Иначе просматриваем весь список
M3:
             mov  di, offset Buff_Name
             push cx
             Xor  si,si
             mov  cx, Length H_Name
M4:
             mov  al, ds:[di]
             cmp  al, Grup[bx].H_Name[si]
             jne  M5
             inc  si
             inc  di
             dec  cx
             jnz  M4
             Mov  Offs_Name,bx
             pop  cx                    ; Незабываем удалять из стека то что положили  
             jmp  M6
M5:
             add  bx, Human_Rec
             pop  cx
             Loop M3
M7:
             Cmp  Col_Name,5
             je   M9
             Xor  ax,ax
             mov  al, Col_Name
             mov  bx, Human_Rec
             mul  bl
             mov  Offs_Name,ax
             Call Mov_Name
             inc  Col_Name                          
M6:          
             mov  dx, 18h                 ; Выводим кол-во участников на экран 
             Xor  ax, ax
             mov  al, Col_Name
             Call OutPut_Digit
             
             Cmp  H_Test1,1
             jne  M8
             Call Scan_Test1
             jmp  M9
M8:
             Cmp  H_Test2,1
             jne  M9
             Call Scan_Test2
M9:    
             Ret
Scan_Name    Endp

;**************************************************************
;** Производит проверку какой режим выбран.(Вызов. постояно) **
;**************************************************************
Scan_Action Proc Near
           Cmp Power,1
           jne C2 
           in  al,StrategyPort 
           cmp  al, 0FEh         ; Нажата кнопка " Результаты "
           jne  C1
           mov  al,14h           ; Зажигаем светодиод 
           out  14h,al 
           mov  Rezult ,1        ; Фиксируем флаги              
           mov  My_Test,0
           mov  H_Test1,0
           mov  H_Test2,0
           mov  H_Sum  ,0
           Call Set_Start_Time
           Call Clear_BuFF_Name
           Mov  Col_New_1,0
           Mov  Col_New_2,0
           Mov  Col_New_3,0
           Mov  Col_Mas_1,0
           Mov  Col_Mas_2,0
           Mov  Col_Mas_3,0
           Call FindRez
           jmp  C2
C1:        
           cmp al, 0FDh          ; Нажата кнопка "Тест"
           jne C2 
           mov al,24h  
           out 14h, al             
           mov Col,0
           mov al, 0
           out 19h, al
           Call Set_Start_Time
           Call Clear_BuFF_Name
           mov  My_Test,1        ; Фиксируем флаги              
           mov  Rezult ,0
           mov  H_Test1,0
           mov  H_Test2,0
           ;Mov  Col_New_1,0
           ;Mov  Col_New_2,0
           ;Mov  Col_New_3,0
C2:
           Ret
Scan_Action EndP

;*************************************************************************
;** Производит проверку на нажатие кнопки "Старт".(Вызывается постояно) **
;*************************************************************************
include anove.asm
include Init_Mem.asm
include My_Init.asm

Start_Test  Proc
           Cmp Power,1
           jne G2
           Cmp My_Test,1
           jne G2
           Cmp H_Test1,1
           jne G1
           in  al,ActionPort
           cmp al,0FEh
           jne G2
           cmp col,0
           je  G2
           Call Scan_Name
           ;Call Scan_Test1           
           jmp G2
G1:
           Cmp H_Test2,1
           jne G2
           in  al,ActionPort
           cmp al,0FEh
           jne G2
           cmp col,0
           je  G2
           ;Cmp Col_Name,5
           ;je  G2
           Call Scan_Name
           ;Call Scan_Test2           
G2:
           Ret            
Start_Test  EndP

Scan_Power Proc
           in al,04h
           Test al, 4h 
           jnz  XX2 
           mov Power,0 
XX2:
           Ret 
Scan_Power EndP

Begin:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы          
My_Begin: 
           Call  Give_Power
           Call Out_Power        
           Call  Scan_Action     ; Определяется какой выбран режим: "Рез." или "Тест"
           Call  Choose_Strategy ; Проверка выбора теста. Работает умно только, когда My_Test=1 или Rezult=1    
           Call  Start_Test      ; Проверка нажатия кнопки "Старт"
           Call  Scan_Button_For_Test1
           Call  Scan_Button_For_Test2 
           Call  Scan_Button_For_Test3
           Call  Choose_Name
 
           Call  Clear_Name
           call  KbdInput        ; Получение массива KbdImage (образов)
           call  KbdInContr      ; Формирование флагов ошибки ввода и пустой клавиатуры
           call  NxtDigTrf       ; Получение кода буквы (0...31) - который является промежуточным
           Call  Print           ; Заполнение списка фамилий, окончательное получение кода нажатой клавиши клавиатуры           

           Call  L_Input         ; Вывод фамилии на индикаторы, срабатывает если COL > 0 (есть хотя бы одна буква)                        
           jmp   My_Begin
           

;В следующей строке необходимо указать смещение стартовой точки
           ;org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           ;jmp   Far Ptr Start
           org 17F0h               ; задание стартовой
Start:jmp Far Ptr Begin            ; точки, управление
                                   ; передается на
                                   ; команду jmp

Code       ENDS
END Start
