page 30,255
; Программа работы кодового замка

            Name CodeLockProgram

; Константы адресов портов ввода/ввода
InputPort1 = 0      ; адреса портов
InputPort2 = 1      ; ввода

OutputPort1 = 1     ; адреса  
OutputPort2 = 2     ; портов
OutputPort3 = 3     ; вывода
OutputPort4 = 4     ; вводимой информации

ClockPort1 = 5      ; адреса портов
ClockPort2 = 6      ; вывода времени

IndiPort = 7        ; Адрес порта с индикаторами
NumberPort = 8      ; Адрес порта вывода номера уровня защиты

NTime = 0FFFFH      ; Длительность цикла задержки 

TimeLevel12 = 60    ; Время работы 1 и 2 уровней защиты
TimeLevel3  = 10    ; Время работы 3-го уровня защиты
TimeLevel7  = 15    ; Время работы сигнализации (7-го уровня)

; Описание данных
Data Segment at 0H
       Mas db 129 dup (?)       ; массив для перевода считанного из порта 0
                                ; кода в десятичное значение

       Mas1 db 129 dup (?)      ; массив для перевода считанного из порта 1
                                ; кода в десятичное значение
 
       Mas_Kod db 11 dup (?)    ; массив значений для вывода цифр на табло

       Mas_DigitKod db 4 dup (?); массив введенных цифр      

       Password db 4 dup (?)    ; пароль для открытия замка на первом уровне 
       
       Clock db ?               ; время работы текущего уровня (с)

       FirstPress db ?          ; флаг первого нажатия на текущем уровне 

       FlagMistake db ?         ; флаг совершения ошибки при вводе пароля

       LevelNumber db ?         ; номер текущего уровня программы

       MistakeCount db ?        ; количество совершенных ошибок 

       RandomVar db ?           ; генератор случайных цифр (0..99)

       FirstVisit db ?          ; флаг начала уровня 
             
       InputFlag db ?           ; флаг ввода
   
       EmptyFlag db ?           ; флаг пустой клавиатуры 

       KeyTrue db ?             ; флаг наличия нужного 
                                ; ключа на 3-ем уровне защиты 
Data Ends 

StackS Segment Stack at 100H
  db 200H dup (?)
  StkTop label word
StackS Ends

Code Segment
assume cs:Code,ds:Data,ss:StackS 
;----------------------------------------------------------------------------
InitProc proc near
; Начальная инициализация всех используемых в программе
; массивов. Вызывается только один раз за все время выполнения программы

       mov Mas_Kod[0], 3FH  ; цифра 0
       mov Mas_Kod[1], 0CH  ; цифра 1
       mov Mas_Kod[2], 76H  ; цифра 2
       mov Mas_Kod[3], 5EH  ; цифра 3
       mov Mas_Kod[4], 4DH  ; цифра 4
       mov Mas_Kod[5], 5BH  ; цифра 5
       mov Mas_Kod[6], 7BH  ; цифра 6
       mov Mas_Kod[7], 0EH  ; цифра 7           
       mov Mas_Kod[8], 7FH  ; цифра 8
       mov Mas_Kod[9], 5FH  ; цифра 9
       mov Mas_Kod[10],00H  ; пусто

       mov Mas_DigitKod[0],10                              
       mov Mas_DigitKod[1],10                              
       mov Mas_DigitKod[2],10                              
       mov Mas_DigitKod[3],10 

       mov Mas[1],   0H  ; цифра 0
       mov Mas[2],   1H  ; цифра 1
       mov Mas[4],   2H  ; цифра 2
       mov Mas[8],   3H  ; цифра 3
       mov Mas[16],  4H  ; цифра 4
       mov Mas[32],  5H  ; цифра 5
       mov Mas[64],  6H  ; цифра 6
       mov Mas[128], 7H  ; цифра 7
       
       mov Mas1[1],   8H    ; цифра 8
       mov Mas1[2],   9H    ; цифра 9
       mov Mas1[4],   0AH        
       mov Mas1[8],   0FFH  ; кнопка "Ввод"
       mov Mas1[16],  0EEH  ; кнопка "Замена"
       mov Mas1[32],  0DDH  ; кнопка "Ключ"
       mov Mas1[64],  0CCH  ; кнопка "Ключ-1"
       mov Mas1[128], 0BBH  ; кнопка "Вошел"
              
       mov LevelNumber,1    ; начинать с первого уровня
       mov FirstVisit,0FFH  ; установка флага первого посещения

       mov Password[0],4    ;
       mov Password[1],3    ; пароль - 1234
       mov Password[2],2    ;
       mov Password[3],1    ;

       mov RandomVar,0      ; установка случайного значения в 0             
        
       ret
InitProc endp
;----------------------------------------------------------------------------
Timer proc near
; Процедура, отчечающая за вывод на индикаторы времени
; оставшееся время работы текущего уровня защиты программы
; Входные параметры:
;    Clock - время для отсчета в с (не более 99 с)            
; Выходные параметры:
;    Clock - уменьшает на 1
       
       cmp Clock,0
       je H1       

       mov al, clock
         
       aam                        ; представляем полученное время в
                                  ; коде ASCII
       lea bx, Mas_Kod            ; 

       xlat                       ; вывод на индикатор
       out ClockPort2,al          ; младшей части времени
       mov al,ah                  ;
       xlat                       ; вывод на индикатор
       out ClockPort1,al          ; старшей части времени

       mov cx,NTime
H:     nop
       nop
       nop
       nop
       loop H

       dec Clock

       cmp Clock,0
       jne H1
       mov FirstVisit,0FFH       
       cmp LevelNumber,7         ; уровень сигнализации?
       jne H2                    ; нет - переход
       mov LevelNumber,1         ; да - переход на первый уровень
       
       jmp H1
     
H2:    mov LevelNumber,7         ; включение сигнализации       

H1:    ret
Timer endp
;----------------------------------------------------------------------------
DoMas proc near	
; Процедура формирования массива отображения
; Входные параметры:
;   al - код десятичной цифры (0..9)
;   dl - номер порта вывода с индикатором (1..4) до которого будет
;        производиться бесконечный ввод 
; Выходные параметры:     
;   Mas_DigitKod - массив набранных цифр,
;                  причем Mas_DigitKod[0] - младшая цифра (правая) 

       cmp EmptyFlag,0FFH           ; ничего не нажато?
       je M4                        ; да - выход  
       
       cmp dl,1                     ; выводить одну цифру?
       je  M1                       ; да - переход

       xor cx,cx                    ; обнуление сх

       mov cl,dl                    ;                
       dec cl                       ; переписывание или сдвиг
       mov si,cx                    ; хранящихся в Mas_DigitKod
M:     mov ah,Mas_DigitKod[si-1]    ; значений выведенных на 
       mov Mas_DigitKod[si],ah      ; индикаторы цифр на одну
       dec si                       ; цифру влево (т.е. затирание
       loop M                       ; старшей цифры младшей)

M1:    mov Mas_DigitKod[0],al       ; запись новой младшей цифры 
    
M4:    ret
DoMas endp
;----------------------------------------------------------------------------
OutDigit proc near
; Процедура вывода на экран нажатой цифры в режиме бесконечной   
; бегущей строки справа налево в пределах указанных индикаторов.
; Входные параметры:
;   dl - номер порта вывода с индикатором (1..4) до которого будет
;        производиться бесконечный ввод 
;   Mas_DigitKod - массив набранных цифр
       
       cmp EmptyFlag,0FFH
       je M3
              
       lea bx,Mas_Kod              

       mov cl,dl                    ;
       mov dx,OutputPort1           ;
       mov si,0                     ; 
M2:    mov al,Mas_DigitKod[si]      ; вывод на индикаторы значения,
       xlat                         ; содержащиеся в Mas_DigitKod
       out dx,al                    ;
       inc(si)                      ;
       inc(dx)                      ;
       Loop M2                      ;
       
M3:    ret    
OutDigit endp
;----------------------------------------------------------------------------
ButtonPress proc near
; Процедура считывания нажатой кнопки с повторением 
; Выходные параметры
;    AL - код нажатой кнопки или 10 в противном случае

       cmp LevelNumber,4     ; если текущим режимом
       jne N6                ; является один из подуровней
       je N7                 ; режима замены, то
N6:    cmp LevelNumber,5     ; генерируем дополнительную
       jne N                 ; задержку, так как
                             ; в других уровнях роль задержки играет
N7:    mov cx,NTime          ; задержка таймера
N8:    nop
       nop
       nop
       nop 
       loop N8               ;


N:     in al,Inputport1      ; ввод из порта 0

       cmp al, 0             ; ввода нет?
       je N1                 ; да - переход

       lea bx,Mas            ; получаем код
       xlat                  ; нажатой кнопки
       jmp N5                ; переход на выход из процедуры
 
N1:    in al,InputPort2      ; ввод из порта 1

       cmp al,0              ; ввода нет?
       je N3                 ; да - переход
       
       lea bx,Mas1           ; получаем код
       xlat                  ; нажатой кнопки       
       jmp N5                ; переход на выход из процедуры

N3:    mov al,10             ; ввод отсутствует

N5:    ret
ButtonPress endp
;----------------------------------------------------------------------------
CheckPress proc near
; Процедура анализа нажатой клавиши
; Входные параметры:
;    al - код нажатой клавиши
; Выходные параметры:
;    dl - кол-во используемых табло вывода
;    EmptyFlag 
;    InputFlag
;    KeyTrue 

       mov EmptyFlag,0FFH
       mov InputFlag,00H
       
       cmp al,10
       jne J
       jmp JEnd      
     
J:     cmp LevelNumber,1
       jne J1
       cmp al,10
       jb J_1
       ja J_2

J_1:   mov EmptyFlag,00H
       mov dl,4
       jmp JEnd 

J_2:   cmp al,0FFH
       jne J_3
       mov InputFlag,0FFH
       jmp JEnd
        
J_3:   cmp al,0EEH
       je J_4
       jmp JEnd

J_4:   mov LevelNumber,4
       mov FirstVisit,0FFH
       jmp JEnd
 
J1:    cmp LevelNumber,2
       jne J2
       cmp al,10
       jb J1_1
       ja J1_2

J1_1:  mov EmptyFlag,00H
       mov dl,2
       jmp JEnd 

J1_2:  cmp al,0FFH
       jne JJ
       mov InputFlag,0FFH
JJ:    jmp JEnd
       
J2:    cmp LevelNumber,3
       jne J3
    
       cmp al,10
       jb JEnd
       cmp al,0DDH
       jne J2_1
       mov KeyTrue,0FFH
       mov InputFlag,0FFH
       jmp JEnd

J2_1:  cmp al,0CCH
       jne JEnd
       mov KeyTrue,00H
       mov InputFlag,0FFH
       jmp JEnd
 
J3:    cmp LevelNumber,4
       jne j4
       
J4_1:  cmp al,10
       jb J3_1
       ja J3_2

J3_1:  mov EmptyFlag,00H
       mov dl,4
       jmp JEnd

J3_2:  cmp al,0FFH
       jne JEnd
       mov InputFlag,0FFH
       jmp JEnd
 
J4:    cmp LevelNumber,5
       jne J5
       je J4_1

J5:    cmp LevelNumber,6
       jne JEnd
       
       cmp al, 0BBH
       jne JEnd
       mov InputFlag,0FFH
       
JEnd:  ret
CheckPress endp
;----------------------------------------------------------------------------
DoInput proc near
; процедура анализа выполнения действий 
; при нажатии на "Ввод".
; Проверяет флаги 
;     FirstPress и
;     FlagMistake и если они установлены, то 
; блокирует действия на "Ввод".
   
       cmp InputFlag,0FFH
       jne YEnd
       
       cmp LevelNumber,2
       jbe Y
       jmp YEnd

Y:     cmp FirstPress,0FFH
       jne Y1
       je Y2
Y1:    cmp FlagMistake,0FFH
       jne YEnd     

Y2:    mov InputFlag,00H

YEnd:  ret
DoInput endp
;----------------------------------------------------------------------------
OnInput proc near       
; Процедура выполнения действий
; по нажатии на основные функциональные клавиши.

       cmp InputFlag,0FFH
       je X
       jmp XEnd
         
X:     cmp LevelNumber,1
       jne X1
              
       mov ax,Word Ptr Mas_DigitKod
       sub ax,Word Ptr Password
       mov dx,Word Ptr Mas_DigitKod+2
       sub dx,Word Ptr Password+2
       or ax,dx  
       cmp ax,0                       ; введенный пароль равен заданному?
       jne XX
       mov LevelNumber,2              ; да - переход на следующий уровень
       mov FirstVisit,0FFH
       jmp XEnd

XX:    mov FlagMistake,0FFH           ; установка флага ошибки 
       mov al,4                       ; высвечивание индикатора
       out IndiPort,al                ; ошибки

       inc MistakeCount               ; увеличение счетчика ошибок
       cmp MistakeCount,3             ; сделано 3 ошибки?
       jne XP

XX1:   mov LevelNumber,7
       mov FirstVisit,0FFH
       jmp XEnd

XP:    jmp XEnd                    ; промежуточная метка

X1:    cmp LevelNumber,2
       jne X2

       mov al,Byte Ptr Mas_DigitKod
       sub al,Byte Ptr Mas_DigitKod+3
       mov ah,Byte Ptr Mas_DigitKod+1
       sub ah,Byte Ptr Mas_DigitKod+2
       or al,ah  
       cmp al,0                       ; введенный пароль равен заданному?
       jne XX

       mov LevelNumber,3              ; да - переход на следующий уровень
       mov FirstVisit,0FFH
       jmp XEnd

X2:    cmp LevelNumber,3
       jne X3
    
       cmp KeyTrue,0FFH
       jne XX1
       mov LevelNumber,6
       mov FirstVisit,0FFH
       jmp XEnd
          
X3:    cmp LevelNumber,4
       jne X4

       mov ax,Word Ptr Mas_DigitKod
       sub ax,Word Ptr Password
       mov dx,Word Ptr Mas_DigitKod+2
       sub dx,Word Ptr Password+2
       or ax,dx  
       cmp ax,0                       ; введенный пароль равен заданному?
       je X3_1
       
       mov LevelNumber,1
       mov FirstVisit,00H
       mov FlagMistake,0FFH
       mov FirstPress,00H
       call BeginLevel       
       mov ax,di
       mov Clock,al
       jmp XEnd

X3_1:  mov LevelNumber,5
       mov FirstVisit,0FFH
       jmp XEnd

X4:    cmp LevelNumber,5
       jne X5

       mov ax,word ptr Mas_DigitKod       
       mov word ptr password,ax 
       mov ax,word ptr Mas_DigitKod+2       
       mov word ptr password+2,ax
X6:    mov LevelNumber,1
       mov FirstVisit,0FFH 
       jmp XEnd

X5:    cmp LevelNumber,6
       jne XEnd
       jmp X6       

XEnd:  ret  
OnInput endp
;----------------------------------------------------------------------------
FirstPressProc proc near
; Процедура, реализующая действия,
; связанные с первым нажатием клавиши клавиатуры
; на 1-2 уронях

       push ax

       cmp FirstPress,0FFH
       jne DEnd
       
       cmp EmptyFlag,0FFH
       je DEnd

       mov FirstPress,00H 
       cmp LevelNumber,1
       jne D1
       
       mov Clock,TimeLevel12;
       jmp DEnd

D1:    cmp LevelNumber,2
       jne DEnd
       mov al,0
       out IndiPort,al

DEnd:  pop ax
       ret    
FirstPressProc endp
;----------------------------------------------------------------------------
OnMistake proc near
; процедура, реализующая действия,
; связанные с новым набором пароля после ошибки

       push ax      
 
       cmp FlagMistake,0FFH
       jne UEnd
       
       cmp EmptyFlag,0FFH
       je UEnd
        
       mov FlagMistake,00H
       cmp LevelNumber,1
       jne U1

       call BeginLevel       
       jmp UEnd

U1:    cmp LevelNumber,2
       jne UEnd
       
       mov al,0             ; подготовка индикаторов к работе                     
       out IndiPort,al
       out OutputPort1,al
       out OutputPort2,al
       mov Byte Ptr Mas_DigitKod[0],10
       mov Byte ptr Mas_DigitKod[1],10       
                    
UEnd:  pop ax
       ret             
OnMistake endp
;----------------------------------------------------------------------------
InitLevel proc near
; Процедура инициализации уровней работы программы
; перед их использованием

       cmp FirstVisit,0FFH
       je R
       jmp REnd

R:     mov al,clock               ; Сохранение текущего времени
       mov di,ax                  ; (используется для режима замены)
       
       mov FirstVisit,00H
       call BeginLevel
       call TimeClear
       mov FirstPress,0FFH
       mov FlagMistake,00H
       mov MistakeCount,0

       cmp LevelNumber,1
       jne R1                                
       
       mov al,0CH               
       out NumberPort,al        
       
       jmp REnd        
              
R1:    cmp LevelNumber,2
       jne R2

       mov Clock,TimeLevel12       ; установка таймера на 60 с       

       mov al,76H                  ; включение номера текущего уровня
       out NumberPort,al           ; защиты (2-го уровня)   

       mov al,RandomVar            ; получаем случайное значение         

       aam                             ;
       lea bx,Mas_Kod                  ;        
       mov Byte ptr Mas_DigitKod[2],al ; установка первых
       xlat                            ; двух цифр табло
       out OutputPort3,al              ; 
       mov al,ah                       ; 
       mov Byte ptr Mas_DigitKod[3],al ;
       xlat                            ;
       out OutputPort4,al              ;
      
       jmp REnd        

R2:    cmp LevelNumber,3
       jne R3

       mov Clock,TimeLevel3 ; установка таймера на 10 с 

       mov al,5EH                  ; включение номера текущего уровня
       out NumberPort,al           ; защиты (3-го уровня)   
      
       jmp REnd        

R3:    cmp LevelNumber,4    
       jne R4
       
       mov al,40H           ; индикатор режима
       out IndiPort,al      ; замены кода
       
       mov ax,di  
       cmp al,0
       jne RR1
       mov al,60
       jmp RR1

RR1:   mov di,ax            ; сохранение текущего времени
      
       jmp REnd        

R4:    cmp LevelNumber,5
       jne R5
       
       mov al,40H           ; индикатор режима
       out IndiPort,al      ; замены кода       

       mov al,3FH           ;   
       out OutputPort1,al   ; заносим 
       out OutputPort2,al   ; четыре нуля
       out OutputPort3,al   ; 
       out OutputPort4,al   ;
       mov Mas_DigitKod[0],0
       mov Mas_DigitKod[1],0
       mov Mas_DigitKod[2],0
       mov Mas_DigitKod[3],0 
       jmp REnd        
 
R5:    cmp LevelNumber,6
       jne R6

       mov al,10H           ; включение индикатора
       out IndiPort,al      ; открытия замка             
      
       jmp REnd        

R6:    cmp LevelNumber,7
       jne REnd

       mov al,1             ; индикация
       out IndiPort,al      ; сигнализации
       
       mov al,0H            ; выключение номера текущего уровня
       out NumberPort,al    ; защиты (2-го уровня)   


       mov clock,TimeLevel7 ; задание времени работы сигнализации             
        
REnd:  ret
InitLevel endp
;----------------------------------------------------------------------------
Random proc near
; Процедура генерации случайного числа от 0 до 99

       inc RandomVar
       cmp RandomVar,100
       jne Quit
       mov RandomVar,0
Quit:  ret
Random endp
;----------------------------------------------------------------------------
TimeClear proc Near
; процедура очистки индикаторов таймера

       mov Clock,0          ;
       mov al,0             ;
       out ClockPort2,al    ;
       out ClockPort1,al    ;        
       ret
TimeClear endp
;----------------------------------------------------------------------------
BeginLevel proc Near
; процедура инициализации начала работы уровня защиты.

       push ax
      
       mov al,0             ; выкючение всех 
       out IndiPort,al      ; лампочек-индикаторов

       mov Mas_DigitKod[0],10   ;
       mov Mas_DigitKod[1],10   ;
       mov Mas_DigitKod[2],10   ;
       mov Mas_DigitKod[3],10   ; очистка индикаторов вывода 
       out OutputPort1,al       ;
       out OutputPort2,al       ;
       out OutputPort3,al       ;
       out OutputPort4,al       ;

       pop ax
       
       ret                      
BeginLevel endp
;----------------------------------------------------------------------------       
Begin: mov ax,Data
       mov ds,ax
       
       mov ax,StackS
       mov ss,ax       
       mov sp,offset StkTop   
       
       call InitProc             ; Функциональная подготовка

NewB:  call Random               ; Генерация произвольного значения
       
       call InitLevel            ; Функциональная подготовка уровня к работе 

       call Timer                ; Таймер             

       call ButtonPress          ; Ввод с клавиатуры
 
       call CheckPress           ; Анализ ввода с клавиатуры

       call FirstPressProc       ; Действия по первому нажатию на уровне

       call OnMistake            ; Действия при наличии ошибки набора пароля 

       call DoMas                ; Формирование массива отображения

       call OutDigit             ; Вывод информации на дисплей

       call DoInput              ; Контроль на возможность выполнения ввода

       call OnInput              ; Ввод информации и обработка

       jmp NewB
     
Start: org  0FF0h
       assume cs:nothing
       jmp  Far Ptr Begin
        
Code Ends

End Start                  