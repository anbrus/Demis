RomSize    EQU   4096

Data  SEGMENT at 40H use16
                  ;ПЕРЕМЕННЫЕ ДЛЯ ПАРАМЕТРОВ ШД
  F_0 DW ?                     ;начальная частота
  F_s DW ?                     ;номинальная частота
  F_n DW ?                     ;конесная частота
  A_w_Start DD ?               ;желаемое ускорение разгона
  A_w_Brake DD ?               ;желаемое ускорение торможения
  A_r_Start DD ?               ;реальное ускорение разгона
  A_r_Brake DD ?               ;реальное ускорение торможения
  Por_fs DW ?                  ;порог пропущенных шагов
  Pulse DD  ?                  ;максимальное количество импульсов при номинальной частоте
                  ;ПЕРЕМЕННЫЕ                           
  KbdImage DB 2 DUP (?)        ;образ клавиатуры клавиш
  Curr_Digit DB ?              ;текущая клавиша нажатая (цифра)    
  Button_Fl DB ?               ;принимае 2 значения Mul_Btn_Push - переполнение порога 0-нажата одна кнопка
  Buffer  DD ?                 ;состояние на Экране (на табло текущего набранного значения)
  Out_AddrPort DW ?            ;для процедуры вывода значений (адрес порта младшей цифры)
  Count_Push_Btn DB ?          ;для регистрации нажатия клавиши в рабочем цикле работы ШД
  Temp DD ?                    ;временная переменная
  Pulse_In_Kvant DW ?          ;текущее число импульсов в период дискретизации 
  Cur_Pulse DD ?               ;текущее количество импульсов при номинальной частоте
  Fail_Step DB ?               ;регистрации нажатя кнопки ПРОПУСК ШАГА во время работы ШД
  Mode DB ?                    ;режим работы ШД (РАБОТА, СТОП, НОРМАЛЬНО) 
  F_n_w DD ?                   ;значение частоты Желаемой (wished) на шаге n
  F_n_r DD ?                   ;значение частоты Возможной (real) на шаге n
  a_w_s DD ?                   ;значение F_n_w - F_n-1_w (при разгоне)
  a_w_b DD ?                   ;значение F_n_w - F_n-1_w (при торможении)
  a_r_s DD ?                   ;значение F_n_r - F_n-1_r (при разг.)  
  a_r_b DD ?                   ;значение F_n_r - F_n-1_r (при торможении)    
  Failed_Steps DW ?            ;количество проп. шагов
  Type_ DB ?                   ;режим работы  разгон, ход, тормож.
  Push_Fail_Step DB ?          ;для реагирования на кнопку ПРОП. Шага по отжатию
  OutReg DB ?
                  ;ПЕРЕМЕННЫЕ ДЛЯ ПЕРЕМЕЩЕНИЯ СВЕТЯЩЕГОСЯ СВЕТОДИОДА (МОДЕЛ. РАБОТЫ ШД)      
  N_Reg_Out DB ?               ;номер активного порта вывода ШД 
  SM_Cond DW ?                 ;состояние ШД (для отображения 1-го имп. вирт. через 5 реальных) 
  Reg_Out_Cond DB ?            ;состояние активного порта вывода ШД
Data       ENDS
 
Code       SEGMENT use16
Type_razgon = 00000000b            ;тип движения разгон
Type_hod = 00001111b               ;тип движения ход 
Type_brake = 11111111b             ;тип движения торможение
 
Mode_Go = 11111111b                ;режим работы - запуск
Mode_Idle = 00001111b              ;режим работы - простой  
Mode_Stop = 00000000b              ;режим работы - стоп 
 
Pressision = 10000                 ;точность
Max_Pulse_In_Kvant = 500           ;максимальное число импульсов в период дискретизации 
Mul_Btn_Push = 0FFh                ;значение Curr_Digit - нажато более одной клавиши
Out_Porog = Mul_Btn_Push           ;если значение вышло за пределы
No_Btn_Push = 0FEh                 ;значение Curr_Digit - не нажато ни одной клавиши
N_Drebezg = 50                     ;количество циклов проверки при дребезге

                                 ;пороговое значение нек. параметров   
Por_F_S=10000                      ;
Half_Por_F_S=500                   ;его половина
Por_A_Start_2=1001011010000000b    ; - пороговые 
Por_A_Start_1=10011000b            ; -
Por_M_tr = 1000                    ; -
Por_Por_fs = 100                   ; - значения       

Por_Pulse_1= 1111b                 ; - старшая часть
Por_Pulse_2=0100001001000000b      ; - младшая часть порогового значения


;;;;;;;;;;;;;;;;;ПОРТЫ
Port_Curr_Fraquency = 60h
Port_Failed_Steps = 50h


          ASSUME cs:Code,ds:Data,es:Data
Image  db  03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh,06Fh    ;Образы 10-тиричных символов

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;игичиализация Параметров ШД, режима работы, первоначальных значений
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Init Near
   Mov F_0 , 0
   Mov F_s , 2500
   Mov F_n , 0
   Mov Word Ptr A_w_Start , 9000
   Mov Word Ptr A_w_Start+2 , 0
   Mov Word Ptr A_w_Brake , 9000
   Mov Word Ptr A_w_Brake+2 , 0
   Mov Word Ptr A_r_Start , 9000
   Mov Word Ptr A_r_Start+2 , 0
   Mov Word Ptr A_r_Brake , 9000
   Mov Word Ptr A_r_Brake+2 , 0
   Mov Por_fs , 100  
   Mov Word Ptr Pulse , 10011100010000b    ;10000d
   Mov Word Ptr Pulse+2 , 0   
   Mov Mode , 00001111b                    ;режим работы - нормальный
   Mov Word Ptr Buffer , 0
   Mov Word Ptr Buffer+2 , 0
   Mov N_Reg_Out ,  51                     ;младший порт вывода
   Mov Reg_Out_Cond , 1                   ;пока его состояние = nill
   Mov SM_Cond , 0                         ;также как и состояние ШД   
   Ret
EndP Init

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;ГАШЕНИЕ ДРЕБЕЗГА
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VibrDestr  PROC  NEAR
           Push BX
           Push AX
VD1:       mov   ah,al       ;Сохранение исходного состояния
           mov   bh,0        ;Сброс счётчика повторений
VD2:       in    al,dx       ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   bh          ;Инкремент счётчика повторений
           cmp   bh,N_Drebezg;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных          
           Pop AX
           Pop BX          
           ret 
VibrDestr  ENDP
           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;ПОЛУЧАЕМ ОБРАЗ КЛАВИАТУРЫ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
KbdInput   PROC  NEAR
           Push SI
           Push CX
           Push BX
           Push AX
           Push DX
            
           lea   si , KbdImage         ;Загрузка адреса,
           mov   cx , LENGTH KbdImage  ;счётчика циклов
           mov   bl , 00000001b             ;и номера исходной строки
KI4:       mov   al , bl       ;Выбор строки          
           out   35h , al      ;Активация строки
           in    al , 0h       ;Ввод строки
           and   al , 00011111b         ;Включено? 
           cmp   al , 0
           jz    KI1         ;Переход, если нет
           mov   dx , 0h     ;Передача параметра
           call  VibrDestr   ;Гашение дребезга
           mov   [si] , al    ;Запись строки
KI2:
           in    al , 0h  ;Ввод строки
           and   al , 00011111b      ;Выключено?
           cmp   al , 0
           jnz   KI2         ;Переход, если нет
           call  VibrDestr   ;Гашение дребезга
           jmp   SHORT KI3
KI1:
           mov   [si],al     ;Запись строки
KI3:       inc   si          ;Модификация адреса
           rol   bl,1        ;и номера строки
           loop  KI4         ;Все строки? Переход, если нет
           
           Pop DX
           Pop AX
           Pop BX
           Pop CX
           Pop SI
           ret
KbdInput   ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;ПОЛУЧАЕМ ТЕКУЩЕЕ СОСТОЯНИЕ КЛАВИАТУРЫ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetCurrentDigit PROC NEAR        
            Push BX
            Push CX
            Push AX                                                            
            Push DX
            
            Mov Curr_Digit , No_Btn_Push           ;признак ненажатия клавиатуры  0FFh             
            Lea BX,KbdImage            
            Mov DL , 0
            Mov AX , Word Ptr [BX]                 ;записываем слово образа клавы
            Mov CX , 16 
 Mul_Bth_Push:       
            Shr AX , 1
            Adc DL , 0              
            Loop  Mul_Bth_Push                      ;после цикла в Curr_Digit - число акт разрядов
            Cmp DL , 0
            Je Exit_GetCurrentDigit 
            Cmp DL , 1
            JE No_We_Push_Mul_Bth
            Mov Curr_Digit , Mul_Btn_Push           ;признак нажатия нескольких клавиш   
            Mov CX , 8
            Mov DX , 36h
            Call ClrSigns
            Call ShowError                          ;выводим сообщ об ошибке
            Jmp Exit_GetCurrentDigit             
 No_We_Push_Mul_Bth:
            Mov CX , 2                              ;число строк              
 Study_Line: 
            Mov AL , [BX]                           ;исследуемая строка
            Cmp AL , 00000000b                      ;значение 00000000b - ни одна клавиша не нажата
            Jne Line_Not_Empty                      ;переход, если не нажата клавиша                           
            Inc BX                                  ;рассматриваем следующую строку 
            Loop Study_Line       
            Jmp Exit_GetCurrentDigit                ;обработка при ненажатой клавиатуре закончена
 Line_Not_Empty:                                     ;[BX] - адрес строки в которой что-то есть (что-то нажали)                           
            Sub BX,Offset KbdImage                  ;в BX - строка : 0 , 1    
            Mov AH,0                                ;номер разряда         
 Find_Unit:  Shr AL,1                               ;сдвиг 
            Jc We_Find_Unit
            Inc AH                    
            Jmp Find_Unit
 We_Find_Unit:
            Mov Curr_Digit , AH                      ;сохраняем номер столбца  
            Mov AL , 5                               ;число столбцов (столбцы нач. с 0)
            Mul BL                                   ;умножаем 5 на номер строки (строки нач. с 0)
            Add Curr_Digit , AL                      ;получ номер нажат цыфры 
 Exit_GetCurrentDigit :      
 
            Pop DX   
            Pop AX
            Pop CX 
            Pop BX 
            Ret
GetCurrentDigit ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;РАCКОДИРОВКА ТЕК. НАЖ. ЦИФРЫ (ЛИБО В БУФЕР, ЛИБО ПРИСВАИВАЕМ ПАРАМЕТРУ)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc DecodeCurrentDigit Near    
           Push SI
           Push DI
           Push AX                         
           Push CX
           Push BX 
                            
           Cmp Curr_Digit , 9
           JA End_DecodeCurrentDigit        ;если нажата не цифра (0-9)
           Mov DX , Word Ptr Buffer+2 
           Mov AX , Word Ptr Buffer
           Mov DI , 10011000b               ;записываем число 9999999
           Mov SI , 1001011001111111b       
           Call CompareDD                   ;сравниваем буффер и 9999999
           Cmp BX , 0                       
           Je Not_out_Por                   ;если не больше, то не вышли за порог
           Jmp  End_DecodeCurrentDigit   
 Not_out_Por:           
           Mov AX , Word Ptr Buffer        
           Mov CX , 10                          
           Mul CX                          ;умножаем младшую часть на 10 
           Mov Word Ptr Buffer , AX        
           Mov AX , Word Ptr Buffer+2
           Mov Word Ptr Buffer+2 , DX      ;если младшая часть вышла на одну цифру, то потом её учтем           
           Mul CX                          ;умножаем старшую часть на 10                        
           Add AX , Word Ptr Buffer+2      ;если был перенос из старшей части
           Mov Word Ptr Buffer+2 , AX
           Mov AL , Curr_Digit
           Mov AH , 0
           Add Word Ptr Buffer , AX
           Adc Word Ptr Buffer+2 , 0                                                   
 End_DecodeCurrentDigit:   
    
            Pop BX
            Pop CX
            Pop AX  
            Pop DI
            Pop SI            
           Ret           
EndP DecodeCurrentDigit 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ПРИСВАИВАЕМ СООТВЕТСТВУЮЩЕЕ ЗНАЧЕНИЕ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Assign_Values NEAR
         
          Cmp Curr_Digit , Mul_Btn_Push           
          Jne E_2
          Jmp End_Assign_Values
  E_2:        
          Mov DX , 5         ;передача параметров
          Call VibrDestr     ;гашение дребезга
          In AL , DX
          And AL , 00011111b ;в 5 рег всего 5 кнопок
          Mov AH , AL
          Mov DX , 1         ;передача параметров
          Call VibrDestr     ;гашение дребезга
          In AL , DX         ;т.о имеем AH-образ 5 рег. ввода, AL-образ 1 рег. ввода  
          Mov BP , AX        
          
          Mov CX , 13    
          Mov DL , 0
      Is_One_Bth_Pushe:              
          Shr AX , 1
          Adc DL , 0 
          Loop Is_One_Bth_Pushe    ;в DL - количество кнопок нажатых                    
          Mov Count_Push_Btn ,  DL
          
          Cmp Count_Push_Btn  , 0               
          Jne E_3                   ;если ни одна кнопка не нажата то выход из проц.          
          Jmp End_Assign_Values 
       E_3:                              
                            ;просмор Сброса
          Shr BP , 1
          Jnc Not_Sbros            ;переход если не сброс
          Cmp Count_Push_Btn , 1         
          Je Sbros_Ok              ;если была одна клавиша нажата
       
          Mov CX , 8 
          Mov DX , 36h          
          Call ClrSigns            ;очищаем индикаторы  
          Call ShowError           ;выводим сообщ об ошибке
          Mov Button_Fl , Mul_Btn_Push     ;ошибка есть обновлять значения не надо (см Show_All_Values )
          Jmp  Not_Sbros           ;для просмотра ост кнопок на предмет ошибки       
  Sbros_Ok:
          Mov Word Ptr Buffer, 0
          Mov Word Ptr Buffer+2 , 0 
          Mov Button_Fl, No_Btn_Push        ;ошибка нет обновлять значения надо (см Show_All_Values )   
          Jmp End_Assign_Values             
  Not_Sbros:   
                                                  ;просмор F_0
          Mov Out_AddrPort , 0h
          Mov SI , Por_F_S
          Mov DI , 0      
          Mov CX , 5              
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je  No_F_0
          Mov AX, Word Ptr Temp 
          Mov F_0 , AX
  No_F_0:                                       ;просмор F_s                        
          Mov Out_AddrPort , 5h
          Mov SI , Por_F_S
          Mov DI , 0        
          Mov CX , 5            
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je  No_F_s
          Mov AX, Word Ptr Temp 
          Mov F_s , AX
  No_F_s:                                    ;просмор F_n                
          Mov Out_AddrPort , 41h
          Mov SI , Por_F_S
          Mov DI , 0          
          Mov CX , 5                    
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je  No_F_N
          Mov AX, Word Ptr Temp 
          Mov F_N , AX
  No_F_N:                                   ;просмор A_w_Start                
          Mov Out_AddrPort , 0Ah
          Mov SI , Por_A_Start_2
          Mov DI , Por_A_Start_1
          Mov CX , 8                                        
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je No_A_w_Start 
          Mov AX, Word Ptr Temp 
          Mov Word Ptr A_w_Start , AX
          Mov AX, Word Ptr Temp+2 
          Mov Word Ptr A_w_Start+2 , AX      
 No_A_w_Start:                              ;просмор A_w_Brake
          Mov Out_AddrPort , 12h
          Mov SI , Por_A_Start_2
          Mov DI , Por_A_Start_1          
          Mov CX , 8                              
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je No_A_w_Brake 
          Mov AX, Word Ptr Temp 
          Mov Word Ptr A_w_Brake , AX
          Mov AX, Word Ptr Temp+2 
          Mov Word Ptr A_w_Brake+2 , AX
 No_A_w_Brake:                             ;просмор A_r_Start 
          Mov Out_AddrPort , 1Ah
          Mov SI , Por_A_Start_2
          Mov DI , Por_A_Start_1          
          Mov CX , 8                              
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je No_A_r_Start 
          Mov AX, Word Ptr Temp 
          Mov Word Ptr A_r_Start , AX
          Mov AX, Word Ptr Temp+2 
          Mov Word Ptr A_r_Start+2 , AX
 No_A_r_Start:                             ;просмор A_r_Brake
          Mov Out_AddrPort , 22h
          Mov SI , Por_A_Start_2
          Mov DI , Por_A_Start_1          
          Mov CX , 8                    
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je  No_A_r_Brake         
          Mov AX, Word Ptr Temp 
          Mov Word Ptr A_r_Brake , AX
          Mov AX, Word Ptr Temp+2 
          Mov Word Ptr A_r_Brake+2 , AX
 No_A_r_Brake:                             ;просмор por_fs 
          Mov Out_AddrPort , 3Eh
          Mov SI , Por_Por_fs
          Mov DI , 0          
          Mov CX , 3          
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je  No_Por_fs
          Mov AX, Word Ptr Temp 
          Mov Por_fs , AX
 No_Por_fs:                               ;просмор Pulse
          Mov Out_AddrPort , 2Ah
          Mov SI , Por_pulse_2
          Mov DI , Por_Pulse_1
          Mov CX , 7          
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je  No_Pulse         
          Mov AX, Word Ptr Temp 
          Mov Word Ptr Pulse , AX
          Mov AX, Word Ptr Temp+2 
          Mov Word Ptr Pulse+2 , AX
 No_Pulse:                                ;проверка на СТАРТ    
          Shr BP , 1
          Jnc End_Assign_Values
          Cmp Count_Push_Btn , 1       ;было ли нажато неск кнопок
          Ja End_Assign_Values        ;если была не одна клавиша нажата       
          Mov Mode , Mode_Go           ;устанавливаем режим - работает 
          Call Engine_Work         
          Mov Mode , Mode_Idle         ;устанавливаем режим - нормально                        
 End_Assign_Values: 
          Ret
EndP Assign_Values

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CX - число цифр DX - порт вывода млад. DI,SI - порог :
;если не менялось , то Word Ptr Temp+2 = 0FF00h 
;форм. значение Button_Fl -если вышли за пределы
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Assign_Value Near  
          Mov Word Ptr Temp+2 , 0FF00h
          Shr BP , 1               ;BP - состояние регистров (то что осталось тк постоянно сдвигаем) 
          Jnc K_1              
          Cmp Count_Push_Btn , 1   ;было ли нажато неск кнопок
          Je K_2                   ;если была одна клавиша нажата       
  K_3:
          Mov DX , Out_AddrPort
          Call ClrSigns            ;очищаем индикаторы  
          Call ShowError           ;выводим сообщ об ошибке
          Mov Button_Fl, Out_Porog ;ошибка есть обновлять значения не надо (см Show_All_Values )          
          Jmp K_1                  ;для просмотра ост кнопок на предмет ошибки 
  K_2:
          Mov AX , Word Ptr Buffer
          Mov DX , Word Ptr Buffer+2
          Call CompareDD
          Cmp BX , 11111111b
          Je  K_4                
          Mov Button_Fl, No_Btn_Push       ;ошибка нет обновлять значения надо (см Show_All_Values )
          Mov AX , Word Ptr Buffer 
          Mov Word Ptr Temp , AX                     
          Mov AX , Word Ptr Buffer+2 
          Mov Word Ptr Temp +2, AX                              
          Jmp End_Assign_Values
K_4:      Mov Word Ptr Temp, 0                     
          Mov Word Ptr Temp+2, 0                              
          Jmp K_3
  K_1:    
                    
          Ret
EndP Assign_Value


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ВЫВОДИМ СООБЩЕНИЕ Err НА ЭКРАН НАЧИНАЯ С ПОРТА DX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc ShowError NEAR   
     Mov AL , 6Fh  ;вывод r
     Out DX , AL
     Inc DX 
     Mov AL , 6Fh  ;вывод r
     Out DX , AL
     Inc DX  
     Mov AL , 073h  ;вывод E
     Out DX , AL   
     Ret
EndP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ОЧИЩАЕМ CX ИНДИКАТОРОВ С ПОРТА DX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc ClrSigns Near
     Push DX    
     Mov AL , 03Fh
 Turn_Of_Signs:                                     ;гасим все табло       
     Out DX , AL
     Inc DX        
     Loop Turn_Of_Signs   
     Pop DX
     Ret
EndP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ВЫВОД НА СЕМИСЕГМЕНТНЫЕ ИНДИКАТОРЫ ВСЕХ ЗАДАВАЕМЫХ ПАРАМЕТРОВ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Show_All_Values NEAR  
   Cmp Curr_Digit,  Mul_Btn_Push 
   Jne G_1  ;ошибка есть обновлять значения не надо  (нажато неск клавиш)
   Jmp End_Show_All_Values
  G_1:
                ;Вывод буфера на экран
    Mov AX , Word Ptr Buffer       
    Mov DX , Word Ptr Buffer+2
    Mov SI , 10000
    Div SI  
    Mov CX , 4
    Mov Out_AddrPort , 3Ah   
    Call Out_Digits                 ;выводим ст. часть
   
    Mov AX,DX    
    Mov Out_AddrPort , 36h
    Call Out_Digits                 ;выводим младшую часть

    Cmp Button_Fl , Out_Porog 
    Jne G_2                          ;ошибка есть обновлять значения не надо (нажато неск кнопок или перебор)
    Jmp End_Show_All_Values
    G_2:

                ;Вывод на семисегментные индикаторы значения F_0 
    Mov AX , F_0       
    Mov CX , 5
    Mov Out_AddrPort , 0 
    Call Out_Digits
                ;Вывод на семисегментные индикаторы значения F_S 
    Mov AX , F_S                
    Mov CX , 5
    Mov Out_AddrPort , 5
    Call Out_Digits
                ;Вывод на семисегментные индикаторы значения F_N 
    Mov AX , F_N                
    Mov CX , 5
    Mov Out_AddrPort , 41h
    Call Out_Digits    
                ;Вывод на семисегментные индикаторы значения A_w_Start 
    Mov AX , Word Ptr A_w_Start
    Mov DX , Word Ptr A_w_Start+2
    Mov SI , 10000d
    Div SI  
    Mov CX , 4
    Mov Out_AddrPort , 0Eh
    Call Out_Digits
    
    Mov AX,DX    
    Mov Out_AddrPort , 0Ah
    Call Out_Digits     
                ;Вывод на семисегментные индикаторы значения A_w_Brake     
    Mov AX , Word Ptr A_w_Brake
    Mov DX , Word Ptr A_w_Brake+2
    Mov SI , 10000d
    Div SI  
    Mov CX , 4
    Mov Out_AddrPort , 16h
    Call Out_Digits
    
    Mov AX,DX    
    Mov Out_AddrPort , 12h
    Call Out_Digits     
                ;Вывод на семисегментные индикаторы значения A_r_Start 
    Mov AX , Word Ptr A_r_Start
    Mov DX , Word Ptr A_r_Start+2
    Mov SI , 10000d
    Div SI  
    Mov CX , 4
    Mov Out_AddrPort , 1Eh
    Call Out_Digits
    
    Mov AX,DX    
    Mov Out_AddrPort , 1Ah
    Call Out_Digits         
                ;Вывод на семисегментные индикаторы значения A_r_Brake     
    Mov AX , Word Ptr A_r_Brake
    Mov DX , Word Ptr A_r_Brake+2
    Mov SI , 10000d
    Div SI  
    Mov CX , 4
    Mov Out_AddrPort , 26h
    Call Out_Digits
    
    Mov AX,DX    
    Mov Out_AddrPort , 22h
    Call Out_Digits   
                ;Вывод на семисегментные индикаторы значения Por_FailedSteps     
    Mov AX , Por_fs         
    Mov CX , 3
    Mov Out_AddrPort , 3Eh
    Call Out_Digits   
                 ;Вывод на семисегментные индикаторы значения Pulse 
    Mov AX , Word Ptr Pulse
    Mov DX , Word Ptr Pulse+2
    Mov SI , 10000d
    Div SI  
    Mov CX , 3
    Mov Out_AddrPort , 2Eh
    Call Out_Digits
    
    Mov AX,DX    
    Mov CX , 4
    Mov Out_AddrPort , 2Ah
    Call Out_Digits     
  End_Show_All_Values:   
    Ret
EndP Show_All_Values  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Вывод на семисегментные индикаторы значения AX 
;входн. параметры
; АХ - число 
; Out_WithDot - флаг c точкой или нет  
; СХ - количество значящих цифр (считая точку)
; Out_AddrPort - адрес тек. порта вывода  (вначале самый младший)
;ВРЕМЯ ВЫПОЛНЕНИЯ ПОСТОЯННОЕ = 166+СХ*232 тактов
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Out_Digits
     Push BX            ;(11)   
     Push DI            ;(11)   
     Push SI            ;(11)   
     Push DX            ;(11)   
     Push AX            ;(11)   
     Push CX            ;(11)   
     Push DS            ;(11)   
 
     Mov DX , Code      ;(15)  
     Mov DS , DX        ;(2)для обращения к Image через Xlat (Image в CS)
     Lea BX , Image     ;(8)
     Mov DX , 0         ;(4)
     Mov SI , 10d       ;(4) делитель
 Out_Digits_L:          ;выделение самой левой цифры и вывод на индикаторы
      Div SI            ;(150) делим
      Mov DI , AX       ;(2)сохраняем частное 
      Mov AX , DX       ;(2)такт как выводим остаток
      Mov DX , ES:Out_AddrPort; (15) в DX - номер порт  
      Xlat              ;(11)преобразовываем в цифру для семисегментного элемента     
      Out DX , AL       ;(8)выводим  
      Inc ES:Out_AddrPort ; (21)переход к след порту
      Mov AX , DI       ;(2)восстонавливаем частное 
      Mov DX , 0        ;(4)для прав вып. операции
   Loop Out_Digits_L
   Xlat                 ;(11)вывод самой старшей цифры

   Pop DS               ;(8)
   Pop CX               ;(8)
   Pop AX               ;(8)
   Pop DX               ;(8)
   Pop SI               ;(8)
   Pop DI               ;(8)
   Pop BX               ;(8)
   Ret                  ;(8)   
EndP Out_Digits

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; РАБОТА ДВИГАТЕЛЯ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc  Engine_Work NEAR
      Call Init_Engine  ;инициализация параметров      
       
              ; ОСНОВНОЙ ЦИКЛ
L_Engine_Work:                          ;(253679 тактов)
        ; отображаем текущую частоту
      Mov CX , 5                     ;(4)
      Mov AX ,Word Ptr F_n_w+2       ;(10) 
      Mov Out_AddrPort , Port_Curr_Fraquency ;(16) 
      Call Out_Digits                ;(881=166+232*3+19)

      Cmp Mode , Mode_Go                ;(16 = 10+6)выполняем цикл пока двигатель работает 
      Jne L_Stop                        ;(4 - если не переходим, те работает двигатель)
      Jmp Begin_Failed_Steps            ;(15)  
    L_Stop:       
      Jmp L_Engine_Stop              

              ; ОБНОВЛЯЕМ ЗНАЧЕНИЕ ПРОПУЩЕННЫХ ШАГОВ
 Begin_Failed_Steps:              ;(до  End_Failed_Steps - 208+528 тактов   )
      Mov CX , Word Ptr F_n_w+2         ;(15)
      Mov AX , Word Ptr F_n_r+2         ;(15)
      Mov Word Ptr F_n_w+2 , AX         ;(14)
      Call Determ_Count_Pulse           ;(248)определение всего импульсов за период дискретизации   
      Mov DI , AX                       ;(2)реальное колич. импульсов в пер. дискретиз
      
      Mov Word Ptr F_n_w+2 , CX         ;(14)
      Call Determ_Count_Pulse           ;(248)
      Mov DX , AX                       ;(2)желаемое колич. импульсов в период дискрет.
      
      Mov DX , DI                 
      Mov DI , AX 
      Mov AX , 0                        ;(10) 
      Mov SI , 0                        ;(15 = 9+6)

      
      Mov DX , Word Ptr F_n_r+2        ;(15 = 9+6)передача параметров
      Mov AX , Word Ptr F_n_r          ;(10) 
      Mov DI , Word Ptr F_n_w+2        ;(15 = 9+6)
      Mov SI , Word Ptr F_n_w          ;(15 = 9+6)
      Call CompareDD                   ;(79=60+19)сравнение F_n_r>F_n_w (если да BX-255 если нет то 0)                                   ;(до  End_Failed_Steps - 74 такта  )
                                   
      Cmp Type_ , Type_Brake           ;(16 = 10 +6)проверка на торможение 
      Jne Not_Type_Brake               ;(4)если не торможение
                                       ;(+0 - перехода не было)        
      Mov AL , Curr_Digit              ;(10) - выравниваем
      Mov AL , AL                      ;(2)  - время выполнения (съедаем переход)                                                               
      Mov DI , Word Ptr a_r_b+2
      Mov DX , Word Ptr a_w_b+2
      Cmp DX , DI                       ;(4)иначе (т.е. торможение), 
      JB End_2                         ;(4)если F_n_r <= F_n_w  
                                       ;(+0- перехода не было)
      Sub DX , DI                      ;(3)иначе вычисляем разность  
      
      Add Failed_Steps , DX            ;(16)склавдываем уже имеющуюся разницу и текущую        
      Jmp End_Failed_Steps             ;(15) 
  Not_Type_Brake:                      ;(+12- переход был)если тип - ход или разгон 
      Cmp BX , 11111111b               ;(4)             
      JE End_1                         ;(4)если F_n_r>F_n_w, то выход из блока  
                                       ;(+0 - перехода не было)
      Sub DI , DX                      ;(3)иначе (F_n_r<=F_n_w) вычисляем разность               
      Add Failed_Steps , DI            ;(16)склавдываем уже имеющуюся разницу и текущую        
      Jmp End_Failed_Steps             ;(15)
  End_1:                               ;(+12- переход был)
      Add AL , AL                      ;(3) - выравниваем
      Add Al , Curr_Digit              ;(4) - время выполнения 
      Jmp End_Failed_Steps             ;(15)
  End_2:                               ;(+12- переход был) 
      Add AL , AL                      ;(3) - выравниваем
      Add Al , Curr_Digit              ;(4) - время выполнения 
      Jmp End_Failed_Steps             ;(15)      
 End_Failed_Steps:  
    
 
             ; ПРОВЕРЯЕМ НА ВЫХОД Failed_Steps ЗА ДОП. ГРАНИЦЫ (Por_Por_fs) 
                                                 ;(до All_Pulse_End - 251521 тактов + Tдребезга)             
      Mov DX , 5h                     ;(4) ;передача параметров в процедуру гашения дребезга     
      Call VibrDestr                  ;( = 19+)
      In AL , 5h                      ;(10)смотрим нажата ли клавиша Пропуск шага                         
      Mov  AH , AL                    ;(2)
      And AL , 00010000b              ;(4)в AL - признак нажатия или нет кнопки ПРОПУСК ШАГА
             
      And AH , 00001000b              ;(4)выделяем состояние кнопки СТОП
      Cmp AH , 00001000b              ;(4) 
      Jne Not_Stop_Btn_Push           ;(4)
      Mov Mode , Mode_Stop            ;(-)если кнопка СТОП нажата, то выход
      Jmp L_Engine_Work               ;(-) 
 Not_Stop_Btn_Push:                  
                                      ;(+12) 
      Cmp AL , Push_Fail_Step         ;(16)сравним рег. и образ рег 
      Je Not_Push_fail_Step           ;(4)если равны, то значит либо кнопку не отпустили, либо кнопку не нажимали
                                      ;(+0)
      Cmp Al , 0                      ;(4)иначе сравн. тек состояние с 0 (состояние - ненажата)           
      Jne L_No_Push_Fail_Step         ;(4)если кнопка ненажата (т.е отпущена), то прибавляем к суммарн. кол-ву проп шагов 1
                                      ;(+0)
      Mov Push_Fail_Step , 0          ;(16)обнуляем образ рег. (т.к уже увеличили Failed_Steps)
      Inc Failed_Steps                ;(21)если кнопка отпущена, то увеличивае число проп шагов              
      Jmp Out_Digits_                  ;(15) 
 L_No_Push_Fail_Step:                 ;(+12)
      Mov Push_Fail_Step , AL         ;(10)если тек. сост нажата, то записываем в образ рег.
      Nop                             ;(3) - добавление
      Nop                             ;(3) -
      Nop                             ;(3) - времени
      Nop                             ;(3) -
      Nop                             ;(3) - выполнения                        
      Jmp Out_Digits_                  ;(15)                
 Not_Push_fail_Step:                  ;(+12)   
      Inc Failed_Steps                ;(21) - дополнение 
      Dec Failed_Steps                ;(21) - времени
      Mov AX , Failed_Steps           ;(10) - выполнения
 Out_Digits_:
   
        ; отображаем число проп шагов
      Mov CX , 3                     ;(4)
      Mov AX , Failed_Steps          ;(10) 
      Mov Out_AddrPort , Port_Failed_Steps  ;(16) 
      Call Out_Digits                ;(881=166+232*3+19)
               
      Mov AX , Por_fs                ;(10) 
      Cmp  Failed_Steps , AX         ;вышли ли за порог проп. шагов
      JA Out_Of_Porog                ;(4)
      Call Engine_Go                 ;(250435=396+500*500+20+19)запускаем двигатель        
      Jmp All_Pulse_End              ;(15)
 Out_Of_Porog:                 
      Mov Mode , Mode_Stop           ;если вышли за порог, то останавливаем двигатель
      Jmp L_Engine_Work              ;выход
 All_Pulse_End:      
   
      ; ВЫЧИСЛЕНИЕ НОВОЙ ЧАСТОТЫ И ТИПА РАБОТЫ ДВИГАТЕЛЯ (время выполнения  = 462 тактов)
                                        
      Cmp Type_ , Type_razgon       ;(16)проверка на разгон 
      Jne Type_Not_Razgon           ;(4)если не разгон то переход по метке                                         
                                 ; ТИП ДВИЖЕНИЯ - РАЗГНОН (до  Type_Not_Razgon - 444=342+52(от хода)+50(от тормаза) тактов)                           
                                    ;(+0)
                                    ;(+102- дополнение времени)  
      Mov DX , 1                    ;(4)  -
      Call Delay                    ;(89) -
      Nop                           ;(3)  -
      Nop                           ;(3)  -
      Nop                           ;(3)  - выпонеия                             
                                     
     
      Mov AX , AX                   ;(2)  -выполнеия       
                                    ;(+0)
      Call New_F_n_r_Razgon         ;(165)находим новую возможную частоту
      Mov AX , F_S                  ;(10)
      Cmp Word Ptr F_n_w+2 , AX     ;(15)если разгон то проверяем надо ли менять тип на ход (достигли макс. частоты)
      JAE Chg_Type_To_Hod           ;(4)
                                    ;(+0) 
      Call New_F_n_w_Razgon         ;(133)находим новую желаемую частоту                                                      
      Jmp L_Engine_Work             ;(15)на начало процедуры
 Chg_Type_To_Hod:                   ;(+12) 
      Mov Type_ , Type_hod          ;(16)меняем тип на ход      
      Mov Word Ptr F_n_w+2 , AX     ;(10)меняем частоту на конечную
      Mov Word Ptr F_n_w , 0        ;(16) 
      And OutReg , 11000111b        ;(23)гасим состояние (разгон, ход, тормож)      
      Or OutReg , 10000b            ;(23)зажигаем ход 
      Mov AL , OutReg               ;(10) 
      Out 31h , AL                  ;(10)
      Nop                           ;(3) - дополнеие
      Nop                           ;(3) - 
      Nop                           ;(3) - времени
      Mov AL , 0                    ;(4) - выполнеия           
      Jmp L_Engine_Work             ;(15)на начало процедуры                                                       
                                       
                                   ;до Type_Not_Hod  - 394+50(от тормаза) тактов  
 Type_Not_Razgon:                   ;(+12)
      Cmp Type_ , Type_hod          ;(16)проверка на тип движ - ход
      Jne Type_Not_Hod              ;(4)переход если не ход                                  
                               ; ТИП ДВИЖЕНИЯ - ХОД     
                                    ;(+0)
      Push F_S                      ;(23) -дополнеие 
      Pop F_S                       ;(22) -
      Nop                           ;(3)  -времени
      Mov AX , AX                   ;(2)  -выполнеия       
                                    
      Call New_F_n_r_Razgon         ;(165)находим новую возможную частоту                              
      Mov DX , Word Ptr Pulse+2     ;(15)  
      Mov AX , Word Ptr Pulse       ;(10)
      Mov DI , Word Ptr Cur_Pulse+2 ;(15)
      Mov SI , Word Ptr Cur_Pulse   ;(15)
      Call CompareDD                ;(60)
      Cmp BX , 11111111b            ;(4) 
      JNE Reach_                     ;(4) 
                                    ;(+0)
                                    
      Mov AX , Pulse_In_Kvant       ;(10)увеличиваем на Pulse_In_Kvant тек. кол. импульсов
      Add Word Ptr Cur_Pulse , AX   ;(10)               
      Adc Word Ptr Cur_Pulse+2, 0 
      Jmp L_Engine_Work             ;(15)
 Reach_:                            ;(+12) 
      Mov Type_ , Type_brake        ;(16)если достигли предела, то тормозим     
      Mov AL , Type_                ;(15) - дополнеие
      Mov Type_ , AL                ;(14) - времени 
      Mov AX , AX                   ;(2)  - выполнеия
      Jmp L_Engine_Work             ;(15)на начало процедуры                                                             
 Type_Not_Hod:                           
      And OutReg , 11000111b        ;(23)гасим состояние (разгон, ход, тормож)
      Or OutReg , 100000b           ;(23)зажигаем тормоз 
      Mov AL , OutReg               ;(10)
      Out 31h , AL                  ;(10)
                                       ;ТИП ДВИЖЕНИЯ - ТОРМОЗ
      Call New_F_n_r_Brake          ;(165)
      Mov AX , F_n                  ;(10)  
      Cmp Word Ptr F_n_w+2 , AX     ;(15)  
      JLE Chg_Mode_To_Idle          ;(4)
                                    ;(+0) 
      Call New_F_n_w_Brake          ;(133)находим новую желаемую частоту                                  
      Mov AX , 0                    ;(4) - дополнение
      Mov AX , Word Ptr F_n_w+2     ;(10)- времени выполнения
      Jmp L_Engine_Work             ;(15)на начало процедуры      
 Chg_Mode_To_Idle:                  ;(+12)               
      Mov Mode , Mode_Idle          ;(16)
      Mov DX , 1                    ;(4)
      Mov AX , 0                    ;(4) 
      Mov Word Ptr F_n_w+2 , AX     ;(10)
      Call Delay                    ;(89)
      Nop                           ;(3) -  дополнеие 
      Nop                           ;(3) -  
      Nop                           ;(3) -  времени
      Nop                           ;(3) -  выполнеия                  
      Jmp L_Engine_Work             ;(15)на начало процедуры                                                                               
 L_Engine_Stop:        
      Mov AL ,  00000000b               ;гасим все лампы
      Out 31h , AL    
      Cmp Mode, 00000000b               ;узнаем была ли нажата кнопка СТОП
      Jne L_Engine_Succeed
      Mov AL ,  00000010b               ;если нажали на кнопку стоп,
      Mov OutReg , AL
      Out 31h , AL                      ;то испытание неудачно (зажигаем лампу) 
      Jmp L_End_Engine_Work             
 L_Engine_Succeed:  
      Mov AL ,  00000100b               ;если двигатель отработал до конца
      Mov OutReg , AL      
      Out 31h , AL                      ;то испытание удачно (зажигаем лампу)         
 L_End_Engine_Work:                      
      Ret
EndP  Engine_Work 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ПРОЦЕДУРА ЗАДЕРЖКИ НА  50+CX*20 тактов (СХ >= 1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Delay Near
     Push CX           ;(11)
     PushF             ;(10)
     Mov CX , DX       ;(2)  
   h_1:  
     Nop               ;(3)
     Loop h_1          ;(17)
                       ;(+5)
     Nop               ;(3)           
     
     PopF              ;(8)
     Pop CX            ;(8)    
     Ret               ;(8)
EndP Delay

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ИЦИАЛИЗАЦИЯ ПАРАМЕТРОВ ДВИГАТЕЛЯ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Init_Engine NEAR       
                        ;инициализируем параметры
      Mov AX , F_0
      Mov Word Ptr F_n_w+2 , AX
      Mov Word Ptr F_n_r+2 , AX         ;начальные частоты (желаемая и реальная)
      Mov Word Ptr F_n_w , 0
      Mov Word Ptr F_n_r , 0            ;начальные частоты (желаемая и реальная)      
      Mov Word Ptr Cur_Pulse , 0
      Mov Word Ptr Cur_Pulse+2 , 0   
      Mov Type_ , Type_Razgon           ;режим движения двигателя - разгон
      Mov Failed_Steps , 0              ;количество проп. шагов равно - 0
      Mov Fail_Step , 0                ;пока не пропускаем шаг                   
      Mov AL ,  00000001b               ;зажигаекм лампу активности
      Mov OutReg , AL
      Or OutReg , 00001000b             ;зажигаем  активность и разгон
      Mov AL , OutReg
      Out 31h , AL    

      Mov Push_Fail_Step , 0            ;пока кнопку Проп. шага не нажимали

                              ;ИЩЕМ A_w_start
      Mov AX , Word Ptr A_w_start
      Mov DX , Word Ptr A_w_start+2
      Mov CX , 0115d                          ;ПОСТАВИТЬ В CX ПАРАМЕТР!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
      Div CX    
      Mov Word Ptr a_w_s+2 , AX            ;нашли целую часть
      Mov AX , DX
      Mov DX , 0
      Mov BX , Pressision                ;точность до 10000-ной
      Mul BX
      Div CX 
      Mov Word Ptr a_w_s , AX              ;нашли дробную часть  
                           ;ИЩЕМ A_w_Brake        
      Mov AX , Word Ptr A_w_Brake
      Mov DX , Word Ptr A_w_Brake+2
      Div CX    
      Mov Word Ptr a_w_b+2 , AX            ;нашли целую часть
      Mov AX , DX                         
      Mov DX , 0
      Mul BX
      Div CX 
      Mov Word Ptr a_w_b , AX              ;нашли дробную часть  (точность до 10000-ной)
                                ;ИЩЕМ A_r_start
      Mov AX , Word Ptr A_r_start
      Mov DX , Word Ptr A_r_start+2
      Div CX    
      Mov Word Ptr a_r_s+2 , AX            ;нашли целую часть
      Mov AX , DX
      Mov DX , 0
      Mul BX
      Div CX 
      Mov Word Ptr a_r_s , AX              ;нашли дробную часть  
                              ;ИЩЕМ A_r_Brake        
      Mov AX , Word Ptr A_r_Brake
      Mov DX , Word Ptr A_r_Brake+2
      Div CX    
      Mov Word Ptr A_r_b+2 , AX            ;нашли целую часть
      Mov AX , DX                         
      Mov DX , 0
      Mul BX
      Div CX 
      Mov Word Ptr A_r_b , AX              ;нашли дробную часть  (точность до 10000-ной)             
 End_Init_Engine: 
     Ret
EndP Init_Engine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ПОВОРОТ ДВИГАТЕЛЯ НА F_n_w ИМПУЛЬСОВ    tиниц - 396 ; t 1-го цикла - 500 тактов ; t перехода - 20 тактов
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Engine_Go Near
     Call Determ_Count_Pulse      ;(268=248+19)в AX - число импульсов 0 - Pulse_In_Kvant                                        
     Mov CX , 1                   ;(4)         
     Cmp AX , 0                   ;(4) - если число импульсов = 0 
     Je Zero_Pulse                ;(4)
                                  ;(+0)
     Mov BX , AX                  ;(2)
     Mov AX , Max_Pulse_In_Kvant  ;(10)Находим число через которое действительно нужно выдавать импульс  
     Mov DX , 0                   ;(4)
     Div BX                       ;(150)
     Mov BX , AX                  ;(2) в ВХ - итервал следования импульсов       
     Mov DX , 20                  ;(4)
     Jmp Pulse_Out                ;(15)     
 Zero_Pulse:                      ;(+12)выолняется ("пустые" действия)в случае 0 колич. импульсов в дискрету

     Mov BX , 0
     Mov DX , 3                   ;(4)        - дополнение
     Call Delay                   ;(89=19+70) -
     Nop                          ;(3)        - 
     Nop                          ;(3)        - времени
     Nop                          ;(3)        -  
     Nop                          ;(3)        -
     Nop                          ;(3)        - выполнения              
     Mov DX , 20                  ;(4) - для задания задержки 
     Jmp Pulse_Out                ;(15)
 Pulse_Out:                       ;повторяем Pulse_In_Kvant раз  (тело цикла - 500 тактов) 
     Cmp CX , 501                 ;(4)              
     Je I_1                       ;(4)
     Cmp CX , AX                  ;(3)смотрим надо ли выдавать импульс
     Jne Not_Rotate               ;(4) 
                                  ;(+0)
     Call Rotate_Engine           ;(467= 448+19)вызываем поворот двигателя          
     Add AX , BX                  ;(3)увеличиваем на интервал     
     Jmp E_1                      ;(15)
 Not_Rotate:                      ;(+12)
     Call Delay                   ;(469)
     Mov AL , AL                  ;(2) - дополнение 
     Mov AL , AL                  ;(2) - выполнения     
     Jmp E_1                      ;(15)        
 E_1:
     Inc CX                       ;(2)
     Jmp Pulse_Out                ;(15)
                                                                  
   I_1:                           ;(+12) 
     Ret                          ;(8)
EndP Engine_Go 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ПОВОРОТ ДВИГАТЕЛЯ НА ОДИН ШАГ (ИСП СОСТОЯНИЕ ШД) (время выполнеия постоянно = 500-19 тактов)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Rotate_Engine
     Push AX                  ;(11)
     Push DX                  ;(11)     
     Mov DL , N_Reg_Out       ;(15)записываем адрес      
     Mov DH , 0               ;(4)порта вывода  
     Mov AL , 0               ;(4)для стирания с активного регистра вывола  
     Shl SM_Cond , 1          ;(21)сдвигаем  -
     Inc SM_Cond              ;(21)- и инкрементируем состояние ШД 
     Cmp SM_Cond , 1111b      ;(16)проверка на 5 шагов (200 шагов реального ШД - 40 светодиодов) 
     Jne Not_Show_Rotate      ;(4)Если сосояние ШД <> 5 импульсам, то импульс на светодиодах не загорается    
     Out DX , AL              ;(8)очистка активного регистра вывода
     Mov AL , Reg_out_Cond    ;(10)
     Cmp AL , 10000000b       ;(4)
     Jne Not_Next_Reg_Out     ;(4)переход если не нужено менять активный регистр вывода 
                              ;(+0)
     Add DL , 51              ;(4)меняем активный регистр вывода     
     Adc DL , 0               ;(4)учитываем перенос: 255+51--> 50 и CF=1
     Add DL , 0               ;(4) - дополнение времени выполнеия 
     Jmp Show_Rotate          ;(15)
 Not_Next_Reg_Out:            ;(+12)
     Jmp Show_Rotate          ;(15) 
 Show_Rotate:
     Shl DH , 1               ;(2)обнуляем флаг CF
     Shl AL , 1               ;(2)сдвиг состояния активного регистра вывода 
     Adc AL , 0               ;(4)учитываем перенос
     Mov N_Reg_Out , DL       ;(13)сохраняем значение активного регистра(на случай если изменили)
     Mov Reg_Out_Cond , AL    ;(10)сохраняем знасчение состояние активного регистра вывода
     Out DX , AL              ;(8)вывод состояния активного регистра вывода
     Mov SM_Cond , 0b         ;(16)обнуление состояния ШД
     Jmp Quit                 ;(15)
 Not_Show_Rotate:             ;(+12-переход был) 
     Mov DX , 2               ;(4)
     Mov DX , 2               ;(4) - дополнение времени                               
     Nop                      ;(3) - выполнения 
     Call Delay               ;(89)
     Jmp Quit                 ;(15)
 Quit:
     Mov DX , 7               ;(4)                - дополнение
     Call Delay               ;(209=19+190)       -
     Mov AL , 0               ;(4)                - времени
     Mov AL , 0               ;(4)                - 
     Mov AL , 0               ;(4)                - выполнеия процедуры
     Mov AL , 0               ;(4)                - до 500-19 тактов 
     Pop DX                   ;(8) 
     Pop AX                   ;(8) 
     Ret                      ;(8)
EndP Rotate_Engine 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ОПРЕДЕЛЕНИЕ  КОЛИЧЕСТВА ИМПУЛЬСОВ В ПЕРИОД ДИСКРЕТИЗАЦИИ ВЫХОД В Pulse_In_Kvant(AX) время выполнения = 248 тактов 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Determ_Count_Pulse Near
      Mov AX , Word Ptr F_n_w+2   ;(10)
      Mov DX , 0                  ;(4)
      Mov BX , 20                 ;(4)тк макс. частота 10000 а время= 0.05, то Nмакс = 500
      Div BX                      ;(150)
      Cmp DX , 10                 ;(4)   - округление
      Jb Not_inc_AX               ;(4)   
                                  ;(+0)
      Inc AX                      ;(2) 
      Nop                         ;(3)   - дополнение
      Nop                         ;(3)   - времени   
      Mov BX , 20                 ;(4)   - выполнеия
      Jmp OK_                     ;(15)
 Not_inc_AX:                      ;(+12)
      Jmp OK_                     ;(15)     
 OK_:        
      Mov Pulse_In_Kvant , AX     ;(10)
      Ret                         ;(8)
EndP Determ_Count_Pulse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ПРОВЕРКА НА (DX,AX > DI,SI)  ВРЕМЯ ВЫПОЛНЕНИЯ ПОСТОЯННО =  60 ТАКТОВ
; BX - 11111111  да ; BX - 0 нет  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc CompareDD
     Mov BX , 0            ;(4)  
     Cmp DX , DI           ;(3) 
     Ja Yes_1              ;(4)если DX > DI
                           ;(+0- перехода нет )                           
     Jne No_               ;(4)если DX <>DI (т.е DX<DI)   
                           ;(+0- перехода небыло)
     Cmp AX , SI           ;(3)иначе (т.е DX=DI)    
     JA Yes_2              ;(4)если AX>SI      
                           ;(+0 - перехода не было) 
     Mov  AL , Curr_Digit  ;(10)  -  выравнивание времени                   
     Add  AL , 1           ;(4)   -  выполнения     
     Jmp End_CompareDD     ;(15)иначе           

  Yes_1:                     
                           ;(+12 - переход был) 
     Mov BX , 11111111b    ;(4) если DX,AX > DI,SI   
     Mov  AL , 0           ;(4)  -  выравнивание
     Mov  AL , 0           ;(4)  -  времени 
     Nop                   ;(3)  -  выполнения
     Jmp End_CompareDD     ;(15)
 
  No_:   
                           ;(+12 - переход был) 
     Mov  AL , 0           ;(4)  -  выравнивание
     Mov   AL , 0           ;(4)  -  времени 
     Nop                   ;(3)  -  выполнения
     Jmp End_CompareDD     ;(15)
         
  Yes_2:                   ;(+12 - переход был) 
     Mov BX , 11111111b    ;(4) если DX,AX > DI,SI      
     Jmp End_CompareDD     ;(15)              

 End_CompareDD:     
     Ret                   ;(8)
EndP CompareDD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;УВЕЛИЧЕИЕ ВОЗМОЖНОЙ ЧАСТОТЫ НА a_r_s  (время выполнения постоянно = 165 тактов)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc New_F_n_r_Razgon
      Mov AX , F_S                    ;(10)
      Cmp Word Ptr F_n_r+2 , AX       ;(16)
      Jnb C_1                         ;(4) 
                                      ;(+0 - перехода не было)
      Mov AX , Word Ptr A_r_s         ;(10)вычисление новой частоты возможной
      Add Word Ptr F_n_r , AX         ;(15)дробная часть
      Mov AX , Word Ptr F_n_r+2       ;(10)
      Add AX , Word Ptr A_r_s+2       ;(22)старшая часть
      Cmp Word Ptr F_n_r , Pressision ;(16)
      JB C_2                          ;(4)если не вышло за пределы точности
                                      ;(+0 - перехода не было)
      Inc AX                          ;(2)иначе 
      Sub Word Ptr F_n_r , Pressision ;(23)          
      Mov Word Ptr F_n_r+2 , AX       ;(10)    
      Jmp C_3                         ;(15)
 C_2:                                 ;(+12 - переход был)
      Mov Word Ptr F_n_r+2 , AX       ;(10)   
      Mov AX , Word Ptr F_n_r+2       ;(10)  - дополнение времени 
      Inc AL                          ;(3)   - выполнения
      Jmp C_3                         ;(15)
 C_1:                                 ;(+12 - переход был)
                              ;если возможная  частота больше чем конечная
      Mov Word Ptr F_n_r+2 , AX       ;(10) иначе
      Mov Word Ptr F_n_r , 0          ;(16)
      Add AL , Curr_Digit             ;(22) - допо-
      Add AL , Curr_Digit             ;(22) - лнение 
      Add AL , Curr_Digit             ;(22) - вре -
      Inc AL                          ;(4)  - мени
      Inc AL                          ;(4)  - выполнеия      
      Jmp  C_3                        ;(15) 

 C_3:     
      Ret                             ;(8)
EndP New_F_n_r_Razgon   


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;УВЕЛИЧЕНИЕ ЖЕЛАЕМОЙ ЧАСТОТЫ НА a_w_s (время выполнения постоянно = 133 тактa)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc New_F_n_w_Razgon  
     Mov AX , Word Ptr A_w_s      ;(10)вычисление новой частоты возможной
     Add Word Ptr F_n_w , AX      ;(15)дробная часть
     Mov AX , Word Ptr F_n_w+2    ;(10)
     Add AX , Word Ptr A_w_s+2    ;(22)старшая часть
     Cmp Word Ptr F_n_w , Pressision ;(16) 
                                   ;(+0 - перехода не было)
     JB D_1                       ;(4)если не вышло за пределы точности
     Inc AX                       ;(2)иначе
     Sub Word Ptr F_n_w , Pressision ;(23)      
     Jmp D_2                      ;(15) 
  D_1:                            ;(+12 - переход был)
     Nop                          ;(3) - дополнение 
     Nop                          ;(3) - 
     Nop                          ;(3) - времени
     Mov AX , AX                  ;(4) - выполнеия 
     Jmp D_2                      ;(15)
  D_2: 
     Mov Word Ptr F_n_w+2 , AX    ;(10)                     
     Ret                          ;(8) 
EndP New_F_n_w_Razgon  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;УМЕНЬШЕНИЕ ВОЗМОЖНОЙ ЧАСТОТЫ на a_r_b (время выполнения постоянно = 165 тактов)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc New_F_n_r_Brake
      Mov AX , F_n               ;(10) 
      Cmp Word Ptr F_n_r+2 , AX  ;(16) 
      JnG A_1                     ;(4)если возможная  частота больше чем конечная
                                 ;(+0)
      Mov AX , Word Ptr A_r_b    ;(10)вычисление новой частоты возможной
      Sub Word Ptr F_n_r , AX    ;(15)дробная часть
      Mov AX , Word Ptr F_n_r+2  ;(10)
      Sub AX , Word Ptr A_r_b+2  ;(22)старшая часть      
      Cmp Word Ptr F_n_r , 0     ;(16) 
      JG A_2                     ;(4)если не вышло за пределы точности
                                 ;(+0)
      Dec AX                     ;(2)иначе
      Add Word Ptr F_n_r , Pressision ;(23)
      Mov Word Ptr F_n_r+2 , AX  ;(10)        
      Jmp A_3                    ;(15)
 A_1:                            ;(+12)
      Mov Word Ptr F_n_r+2 , AX  ;(10)иначе
      Mov Word Ptr F_n_r , 0     ;(16)      
      Add AL , Curr_Digit        ;(22) - допо-
      Add AL , Curr_Digit        ;(22) - лнение 
      Add AL , Curr_Digit        ;(22) - вре -
      Inc AL                     ;(4)  - мени
      Inc AL                     ;(4)  - выполнеия     
      Jmp A_3                    ;(15)
 A_2:                            ;(+12) 
      Mov Word Ptr F_n_r+2 , AX  ;(10)  
      Mov AX , Word Ptr F_n_r+2  ;(10)  - дополнение времени 
      Inc AL                     ;(3)   - выполнения
      Jmp A_3                    ;(15)
 A_3:  
     Ret                         ;(8)
EndP New_F_n_r_Brake

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;УМЕНЬШЕНИЕ ЖЕЛАЕМОЙ ЧАСТОТЫ НА a_w_b (время выполнения постоянно = 133 тактa)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc New_F_n_w_Brake
      Mov AX , Word Ptr A_w_b     ;(10)вычисление новой частоты возможной
      Sub Word Ptr F_n_w , AX     ;(16)дробная часть
      Mov AX , Word Ptr F_n_w+2   ;(10)
      Sub AX , Word Ptr A_w_b+2   ;(22)старшая часть
      Cmp Word Ptr F_n_w , 0      ;(16)
      JG B_1                      ;(4)если не вышло за пределы точности
                                  ;(+0)
      Dec AX                      ;(2)иначе
      Add Word Ptr F_n_w , Pressision ;(23)          
      Jmp  B_2                    ;(15) 
 B_1:                             ;(+12)
      Nop                         ;(3) - дополнение 
      Nop                         ;(3) - 
      Nop                         ;(3) - времени
      Mov AX , AX                 ;(4) - выполнеия 
      Jmp B_2                     ;(15)
 B_2:    
      Mov Word Ptr F_n_w+2 , AX   ;(10)  
      Ret                         ;(8)
EndP New_F_n_w_Brake

Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           Call  Init        
      Begin:
           Call KbdInput 
           Call GetCurrentDigit 
           Call DecodeCurrentDigit 
           Call Show_All_Values  
           Call Assign_Values
           Jmp Begin  
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
