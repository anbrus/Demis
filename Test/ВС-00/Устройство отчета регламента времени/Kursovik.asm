.386
Name ReglamentTime

RomSize    EQU   4096        ;объем ПЗУ в байтах
KbdPort    =     0
IndiPort   =     13h         ;порт для индик. "Осталась одна минута"
EPort      =     20h         ;порт питания
RowsPort   =     30h         ;порт строк
ColsPort   =     40h         ;порт столбцов
NMax       =     50

;Номера портов матричных индикаторов:
;P20 - питание
;Р30-Р34 - строки
;Р40-Р44 - столбцы

Data       SEGMENT AT 00h use16
           ;------------Флаги-------------------
           msgTimeOutFlag DB ?   ;если флаг равен 0, то сообщение не выведено на индикаторы         
           msgMicrOutFlag  DB ?  ;если флаг равен 0, то микрофон не выключается
           TENSecLeftFlag DB ?   ;флаг задержки между сообщениями "TimeOut" и "SoundOff"        
           
           MicrOutFlag DB ?      ;флаг выключенного микрофона 1 - с выключением           
           MinLeftFlag DB ?      ;флаг индикатора "Осталось 1 минута"
           RunFlag  DB ?         ;флаг режима "Отсчет"/"Ввод" 0-режим "Ввод"              
           PosFlag DB ?          ;флаг нажатия кнопки "Позиция"
           ;PuskFlag DB ?         ;флаг нажатия кнопки "Пуск"
           ;FirstRunFlag DB ?     ;флаг первого запуска
           ZeroFlag DB ?          ;флаг нулей
           ;------------Переменные--------------        
           Pos DB ?                 ;номер позиции с права налево 1-старший, 6-младший разряд   
           TimePred DB 6 dup(?)     ;время у председателя
           TimeInMem  DB 6 dup(?)   ;время запоминаемое в памяти
           Digits   DB 10 dup(?)    ;массив образов цифр                                               
           MsgTimeOut DB 8*5 dup (?);сообщение "TimeOut" ;5 индикаторов по 8 строк
           MsgSoundOff DB 8*5 dup (?);сообщение "SoundOff"
           
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 500h use16 STACK
;Задайте необходимый размер стека
           dw    20 dup (?)
StkTop     Label Word
Stk        ENDS


Code       SEGMENT use16

           ASSUME cs:Code,ds:Data,es:Data,ss:Stk
;Описание программых модулей

;Модуль "Функциональная подготовка"
FuncPrep   PROC  NEAR
;сообщение "SoundOff"
;1-0B3h, 0B5h, 0ADh, 0CDh, 0FFh, 0C3h, 0BDh, 0BDh
           mov   MsgSoundOff[0],0B3h
           mov   MsgSoundOff[1],0B5h
           mov   MsgSoundOff[2],0ADh
           mov   MsgSoundOff[3],0CDh
           mov   MsgSoundOff[4],0FFh
           mov   MsgSoundOff[5],0C3h
           mov   MsgSoundOff[6],0BDh
           mov   MsgSoundOff[7],0BDh
           
;2-0C3h, 0FFh, 0C1h, 0BFh, 0BFh, 0C1h, 0FFh, 081h
           mov   MsgSoundOff[8],0C3h
           mov   MsgSoundOff[9],0FFh
           mov   MsgSoundOff[10],0C1h
           mov   MsgSoundOff[11],0BFh
           mov   MsgSoundOff[12],0BFh
           mov   MsgSoundOff[13],0C1h
           mov   MsgSoundOff[14],0FFh
           mov   MsgSoundOff[15],081h
           
;3-0F3h, 0CFh, 081h, 0FFh, 081h, 0BDh, 0BDh, 0C3h
           mov   MsgSoundOff[16],0F3h
           mov   MsgSoundOff[17],0CFh
           mov   MsgSoundOff[18],081h
           mov   MsgSoundOff[19],0FFh
           mov   MsgSoundOff[20],081h
           mov   MsgSoundOff[21],0BDh
           mov   MsgSoundOff[22],0BDh
           mov   MsgSoundOff[23],0C3h
           
;4-0FFh, 0FFh, 0C3h, 0BDh, 0BDh, 0C3h, 0FFh, 081h
           mov   MsgSoundOff[24],0FFh
           mov   MsgSoundOff[25],0FFh
           mov   MsgSoundOff[26],0C3h
           mov   MsgSoundOff[27],0BDh
           mov   MsgSoundOff[28],0BDh
           mov   MsgSoundOff[29],0C3h
           mov   MsgSoundOff[30],0FFh
           mov   MsgSoundOff[31],081h

;5-0F5h, 0F5h, 0FDh, 0FFh, 081h, 0F5h, 0F5h, 0FDh          
           mov   MsgSoundOff[32],0F5h
           mov   MsgSoundOff[33],0F5h
           mov   MsgSoundOff[34],0FDh
           mov   MsgSoundOff[35],0FFh
           mov   MsgSoundOff[36],081h
           mov   MsgSoundOff[37],0F5h
           mov   MsgSoundOff[38],0F5h
           mov   MsgSoundOff[39],0FDh
                   
;сообщение "TimeOut"
;1-0FFh, 0FDh, 0FDh, 081h, 0FDh, 0FDh, 0F7h, 085h
           mov   MsgTimeOut[0],0ffh
           mov   MsgTimeOut[1],0fdh
           mov   MsgTimeOut[2],0fdh
           mov   MsgTimeOut[3],081h
           mov   MsgTimeOut[4],0fdh
           mov   MsgTimeOut[5],0fdh
           mov   MsgTimeOut[6],0f7h
           mov   MsgTimeOut[7],085h
           
;2-0FFh, 081h, 0F7h, 0FBh, 081h, 0F7h, 0FBh, 081h
           mov   MsgTimeOut[8],0ffh
           mov   MsgTimeOut[9],081h
           mov   MsgTimeOut[10],0f7h
           mov   MsgTimeOut[11],0fbh
           mov   MsgTimeOut[12],081h
           mov   MsgTimeOut[13],0f7h
           mov   MsgTimeOut[14],0fbh
           mov   MsgTimeOut[15],081h           
           
;3-0FFh, 0C3h, 0B5h, 0B5h, 0B3h, 0FFh, 0FFh, 0FFh

           mov   MsgTimeOut[16],0ffh
           mov   MsgTimeOut[17],0c3h
           mov   MsgTimeOut[18],0b5h
           mov   MsgTimeOut[19],0b5h
           mov   MsgTimeOut[20],0b3h
           mov   MsgTimeOut[21],0ffh
           mov   MsgTimeOut[22],0ffh
           mov   MsgTimeOut[23],0ffh

;4-0FFh, 0C3h, 0BDh, 0BDh, 0C3h, 0FFh, 0C1h, 0BFh
           mov   MsgTimeOut[24],0ffh
           mov   MsgTimeOut[25],0c3h
           mov   MsgTimeOut[26],0bdh
           mov   MsgTimeOut[27],0bdh
           mov   MsgTimeOut[28],0c3h
           mov   MsgTimeOut[29],0ffh
           mov   MsgTimeOut[30],0c1h
           mov   MsgTimeOut[31],0bfh
           
;5-0BFh, 0C1h, 0BFh, 0FBh, 0C1h, 0BBh, 0BBh, 0FFh           
           mov   MsgTimeOut[32],0bfh
           mov   MsgTimeOut[33],0c1h
           mov   MsgTimeOut[34],0bfh
           mov   MsgTimeOut[35],0fbh
           mov   MsgTimeOut[36],0c1h
           mov   MsgTimeOut[37],0bbh
           mov   MsgTimeOut[38],0bbh
           mov   MsgTimeOut[39],0ffh
                     
           mov   Digits[0],03fh
           mov   Digits[1],00Ch
           mov   Digits[2],076h
           mov   Digits[3],05Eh
           mov   Digits[4],04Dh
           mov   Digits[5],05Bh
           mov   Digits[6],07Bh
           mov   Digits[7],00Eh
           mov   Digits[8],07Fh
           mov   Digits[9],05Fh

           mov   msgTimeOutFlag,0    ;флаг сообщения "Time out" 
           mov   msgMicrOutFlag,0    ;флаг сообщения "Sound off"
           mov   TENSecLeftFlag,0
          
           mov   RunFlag,0     ;устанавливаем режим "Ввода"
           mov   PosFlag,0     ;устанавливаем 0 - кнопка "Позиция" не нажата ни разу
           mov   ZeroFlag,0    ;устанавливаем 0 - кнопка "Пуск" не нажата ни разу
           xor   al,al
           out   EPort,al      ;0 на порт питание        
           mov   MicrOutFlag,0 ;0 - микрофон работает, 1 - микрофон будет отключен
           mov   MinLeftFlag,0         
           mov   Pos,6         ;начинаем ввод с младшей позиции
      
           mov   cx,6          ;обнуляем массивы TimePred и TimeInMem
           xor   ax,ax
           lea   di,TimePred
           rep   stosw

           ret
FuncPrep   ENDP

;Подмодуль "Гашение дребезга"
VibrDestr PROC NEAR
           push  dx
           push  ax 
VD1:      
           mov   ah,al       
           mov   bh,0
VD2:
           in    al,dx
           cmp   ah,al
           jne   vd1
           inc   bh
           cmp   bh,NMax
           jne   vd2
           mov   al,ah
           pop   ax
           pop   dx
           ret
VibrDestr endp 

;Модуль "Декрементирование времени"
DecNaschet PROC  NEAR
           cmp   RunFlag,0      ;если вкл. режим "Отсчет", то выходим
           jnz   DNExit    
           cmp   PosFlag,0
           je    DNExit
           in    al,KbdPort
           and   al,00000010b
           cmp   al,00000010b    ;если не нажата "-" , то проверяем следующ. кнопк.    
           jne   DNExit    
           call  VibrDestr       ;устраняем дребезг       
           mov   ZeroFlag,1
           xor   ax,ax
           xor   si,si
           mov   al,Pos
           mov   si,ax
           dec   si
           dec   TimePred[si]                     
           
           cmp   Pos,6       ;если поз. 6 - младшая часть секунд
           je    DN6
           cmp   Pos,5       ;если поз. 5 - старшая часть секунд
           je    DN5
           cmp   Pos,4       ;если поз. 4 - младшая часть минут
           je    DN6
           cmp   Pos,3       ;если поз. 3 - старшая часть минут
           je    DN5  
           cmp   Pos,2       ;если поз. 2 - младшая часть часов
           je    DN2
                             ;мин 00:00:00
           jmp   INExit
DN6:
           cmp   TimePred[si],0ffh ;если <0 то = 9
           jne   DNExit
           mov   TimePred[si],9
           jmp   INExit
DN5:       
           cmp   TimePred[si],0ffh
           jne   DNExit
           mov   TimePred[si],5
           jmp   INExit           
DN2:
           cmp   TimePred[si],0ffh
           jne   DNExit
           mov   TimePred[si],4              
                            
DNExit:           
           ret
DecNaschet ENDP   

;Модуль "Инкрементирование времени" 
IncNaschet PROC  NEAR
           cmp   RunFlag,0      ;если вкл. режим "Отсчет", то выходим
           jnz   INExit    
           cmp   PosFlag,0
           je    INExit
           in    al,KbdPort
           and   al,00000001b
           cmp   al,00000001b    ;если не нажата "+" , то проверяем следующ. кнопк.    
           jne   INExit
           call  VibrDestr       ;Устраняем дребезг           
           mov   ZeroFlag,1
           xor   ax,ax
           mov   al,Pos
           mov   si,ax
           dec   si
           inc   TimePred[si]                     
        
           cmp   Pos,6       ;если поз. 6 - младшая часть секунд
           je    IN6
           cmp   Pos,5       ;если поз. 5 - старшая часть секунд
           je    IN5
           cmp   Pos,4       ;если поз. 4 - младшая часть минут
           je    IN6
           cmp   Pos,3       ;если поз. 3 - старшая часть минут
           je    IN5  
           cmp   Pos,2       ;если поз. 2 - младшая часть часов
           je    IN2
                             ;макс 04:59:59
           jmp   INExit
IN6:
           cmp   TimePred[si],10 ;если =10, то установка на 0
           jne   INExit
           mov   TimePred[si],0
           jmp   INExit
IN5:       
           cmp   TimePred[si],6    
           jne   INExit
           mov   TimePred[si],0
           jmp   INExit
IN2:
           cmp   TimePred[si],5
           jne   INExit
           mov   TimePred[si],0              
                            
INExit:           
           ret
IncNaschet  ENDP

;Модуль "Выбор позиции"           
Znakomesto PROC  NEAR
           cmp   RunFlag,0       ;если вкл. режим "Отсчет", то выходим
           jnz   ZExit    
           cmp   MsgTimeOutFlag,1
           je    ZExit          
           in    al,KbdPort
           and   al,00000100b
           cmp   al,00000100b    ;если не нажата "Позиция"
           jne   ZExit
           call  VibrDestr       ;устраняем дребезг
           cmp   PosFlag,0
           jnz   ZNext
           mov   PosFlag,1          
           jmp   ZExit           
ZNext:         
           dec   Pos        
           cmp   Pos,1
           jne   ZExit
           mov   Pos,6                    
ZExit:                             
           ret
Znakomesto ENDP

;Модуль "Ввод кнопки "Пуск""
PuskBtn    PROC  NEAR
           cmp   RunFlag,0
           jnz   PBExit
           cmp   ZeroFlag,1
           jne   PBExit    
           in    al,KbdPort
           and   al,00010000b
           cmp   al,00010000b
           jne   PBExit
           call  VibrDestr                  
           mov   cx,3        ;мы сможем скопировать за 3 цикла
           lea   si,TimePred
           lea   di,TimeInMem
           REP   MOVSW       ;переслать слово, Rep-префикс повторения 
           mov   RunFlag,1   ;включаем режим "Отсчет"                 
PBExit:   
           ret        
PuskBtn    ENDP           

;Модуль "Восстановление исходного состояния"
SbrosBtn   PROC  NEAR           
           in    al,KbdPort
           and   al,00100000b ;выделяем клавишe "Новый докладчик"
           cmp   al,00100000b
           jne   SBExit       
           call  VibrDestr
           
           xor   dx,dx    
           xor   ax,ax           
           out   EPort,al
           mov   cx,12       ;12-число индикаторов
           mov   al,03fh
SBClearLoop:
           inc   dx
           out   dx,al           
           loop  SBClearLoop
           
           mov   msgTimeOutFlag,0    ;флаг сообщения "Time out" 
           mov   msgMicrOutFlag,0    ;флаг сообщения "Sound off"
           mov   TENSecLeftFlag,0
          
           mov   RunFlag,0     ;устанавливаем режим "Ввода"
           mov   PosFlag,0     ;устанавливаем 0 - кнопка "Позиция" не нажата ни разу
           mov   ZeroFlag,0    ;устанавливаем 0 - кнопка "Пуск" не нажата ни разу
           xor   al,al
           out   EPort,al      ;0 на порт питание           
           mov   MicrOutFlag,0 ;0 - микрофон работает, 1 - микрофон будет отключен
           mov   MinLeftFlag,0          
           mov   Pos,6         ;начинаем ввод с младшей позиции
      
           mov   cx,6          ;обнуляем массивы TimePred и TimeInMem
           xor   ax,ax
           lea   di,TimePred
           rep   stosw           
SBExit:           
           ret
SbrosBtn   ENDP   

;Модуль "Возврат к ранее установленному времени"
NewDokBtn  PROC  NEAR
           in    al,KbdPort
           and   al,00001000b ;выделяем клавиши управления
           cmp   al,00001000b 
           jne   NDExit       ;нажата кнопка "Новый докладчик"
           call  VibrDestr
            
           xor   dx,dx    
           xor   ax,ax           
           out   EPort,al
           mov   cx,12       ;12-число индикаторов
           mov   al,03fh
NDClearLoop:
           inc   dx
           out   dx,al           
           loop  NDCLearLoop

           mov   cx,3
           lea   si,TimeInMem
           lea   di,TimePred
           REP   MOVSW

           mov   Pos,6       ;выводим в Pos = 6
           mov   PosFlag,0   ;позиция не нажата ниразу
           mov   msgTimeOutFlag,0
           mov   msgMicrOutFlag,0
           mov   MicrOutFlag,0
           mov   RunFlag,0
           mov   TENSecLeftFlag,0
           mov   ZeroFlag,1
           mov   MinLeftFlag,0

NDExit:
           ret
NewDokBtn  ENDP                      

;Модуль "Задание состояния микрофона"
MicrOutBtn PROC  NEAR
           cmp   RunFlag,0    ;если вкл. режим "Отсчет", то выходим
           jnz   MOBExit  
           cmp   ZeroFlag,0
           je    MOBExit
           cmp   MsgTimeOutFlag,1
           je    MOBExit
           ;cmp   PosFlag,1
           ;jne   MOBExit
           in    al,KbdPort
           and   al,01000000b
           call  VibrDestr                      
           cmp   al,01000000b
           jne   MOBExit           
MOBLoop:            
           in    al,KbdPort
           and   al,01000000b
           call  VibrDestr
           cmp   al,01000000b           
           je    MOBLoop                  

           cmp   MicrOutFlag,00h           
           jz    MOBMicrOFF
           mov   MicrOutFlag,00h ;без отключения микрофона
           jmp   MOBExit
MOBMicrOFF:
           mov   MicrOutFlag,1   ;с отключеним микрофона                              
MOBExit:                     
           ret
MicrOutBtn ENDP                           

;Модуль "Вывод текущего времени"
DispTime PROC NEAR
           cmp   TENSecLeftFlag,0 ;если с выключением микрофона, то сообщения в дополнительные
           jnz   DTExit          ;10 секунд не выводим на индикаторы                                 
           mov   si,5
           cmp   ZeroFlag,1
           jne   DT12Indi
           cmp   RunFlag,0
           jne   DT12Indi
           mov   cx,6          
           jmp   DTDisp                      
DT12Indi: 
           mov   ZeroFlag,1 
           mov   cx,12             
DTDisp:            
           mov   al,TimePred[si]                      
           lea   bx,Digits
           xlat  TimePred    ;в al получили образ выводимой цифры        

           ;выбираем в каких случаях зажигать точку

           cmp   PosFlag,0   ;В режиме "Не нажата кн. "Позиция""
           je    ZPointOFF   ;Гасим точку
           cmp   RunFlag,1   ;В режиме "Отсчет"
           je    ZPointOFF   ;Гасим точку
           cmp   cl,Pos      ;если номер индикатора совпадает с тек. позицией,
           jne   ZpointOFF   ;то не выводим точку
           or    al,10000000b;если 1, то зажигаем точку  
           jmp   ZDispZnak                    
ZPointOff:          
           and   al,01111111b
           jmp   ZDispZnak
ZDispZnak:
           xor   dx,dx
           mov   dl,cl   ;выводим в порт №cx
           out   dx,al
           dec   si
           cmp   cx,7
           je    DTZero
           loop  DTDisp
           jmp   DTExit
DTZero:
           mov   si,5                                      
           loop  DTDisp 
DTExit:           
           ret
DispTime ENDP   

;Модуль "Отсчет времени"
Timer      PROC  NEAR
           xor   ax,ax
           mov   al,Pos
           push  ax
           cmp   RunFlag,0
           jz    TJMP
           
           ;начинаем вычитать

           xor   ax,ax
           mov   Pos,6
           mov   al,6
           mov   si,ax           
           dec   si
TLoop:           
           dec   TimePred[si]
           cmp   TimePred[si],0ffh
           je    TZero           
           jmp   TExit
TZero:
           cmp   Pos,6
           je    T6
           cmp   Pos,5
           je    T5
           cmp   Pos,4
           je    T6
           cmp   Pos,3
           je    T5
           cmp   Pos,2
           je    T2
T6:           
           mov   TimePred[si],9
           dec   si
           dec   Pos
           jmp   TLoop
T5:
           mov   TimePred[si],5
           dec   si
           dec   Pos
           jmp   TLoop
TJmp:                   
           JMP   TExit ;эта метка - промежуточная, т.к. не можем долететь до выхода
T2:        
           cmp   MicrOutFlag,0
           je    TSoundOn
           
           cmp   TenSecLeftFlag,0
           jz    TSet10Delay    
           mov   msgTimeOutFlag,0
           mov   msgMicrOutFLag,1
           mov   RunFlag,0
           mov   PosFlag,0 
           mov   ZeroFlag,0  
           jmp   TClearExit           
TSet10Delay:
           mov   word ptr TimePred[0],0  ;обнуляем часы
           mov   word ptr TimePred[2],0  ;обнуляем минуты
           mov   TimePred[4],1h          ;отсчет еще 10 сек. 
           mov   TimePred[5],0h 
           mov   msgTimeOutFlag,1        ;выводим сообщение "Time out"           
           mov   TENSecLeftFlag,1        ;не отображаем 10 сек задержку на индикаторах
           jmp   TExit
           
TSoundOn:
           mov   msgTimeOutFlag,1
           mov   RunFlag,0
           mov   PosFlag,0                    
           mov   ZeroFlag,0

TClearExit:                        
           mov   cx,3          ;обнуляем массивы TimePred 
           xor   ax,ax
           lea   di,TimePred
           rep   stosw                   
TExit:
           pop   ax
           mov   Pos,al
           ret           
Timer      ENDP

;Модуль "Вывод сообщений"
DispMessages PROC NEAR
           xor   ax,ax
           mov   al,Pos
           push  ax
           cmp   msgTimeOutFlag,0
           jz    DMOtherFl           
           lea   si,MsgTimeOut
           jmp   DMDisp
DMOtherFl:           
           cmp   msgMicrOutFlag,0
           jz    DMExit
           lea   si,MsgSoundOff
           jmp   DMDisp           
DMDisp:           
           xor   ax,ax
           mov   ch,5         ;5-число индикаторов   
           mov   DX,40h       ;столбцы        
DSOutNextInd:
           mov   cl,ch
           mov   al,10000000b
           rol   al,cl
           out   EPort,al     ;включаем питание на нужных индикаторах портах

           mov   Pos,00000001b ;эту единицу будем сдвигать (столбец)          
           mov   cl,8
                     
DSOutNextCol:    
           xor   al,al
           out   DX,al     ;выкл индикатор (все столбцы)                 
           sub   DX,10h
           mov   al,[si]   ;считываем в al маску на строку
           not   al        ;инвертируем
           out   DX,al     ;выводим на строки индикатора
           mov   al,Pos    ;зажигаем следущий столбец
           add   DX,10h
           out   DX,al     ;---||---           
           inc   si        ;получаем смещение следующего элемента
           rol   Pos,1                                       
           dec   cl
           jnz   DSOutNextCol
           
           inc   DX
           dec   ch           
           jnz   DSOutNextInd        
DMExit:    
           pop   ax
           mov   Pos,al
           ret   
DispMessages ENDP           

;Модуль "Проверка оставшегося времени"
MinLeft    PROC  NEAR           
           cmp   RunFlag,0
           jz    TLExit
           cmp   MsgTimeOutFlag,1
           je    TLExit
           mov   MinLeftFlag,0                                
TLCheck:           
           lea   si,TimePred
           cmp   word ptr [si],0 ;проверяем часы
           jne   TLExit
           cmp   word ptr [si+2],0 ;проверяем минуты           
           jne   TLExit
           cmp   word ptr [si+4],0           
           je    TLExit
           mov   MinLeftFlag,1
TLExit:               
           ret
MinLeft   ENDP 

;Модуль "Вывод на двоичные индикаторы"
DispToBin Proc   Near
           push  ax           
           cmp   MicrOutFlag,1
           jne   DTBnotd           
           mov   al,00000010b
           jmp   DTBDisp
DTBnotd:              
           xor   al,al
DTBDisp:           
           or    al,MinLeftFlag
           out   IndiPort,al                                       
DTBExit:      
           pop   ax     
           ret
DispToBin Endp

;Модуль "Задержка вывода на индикаторы"
Delay      PROC  NEAR  
           push  cx
           cmp   MicrOutFlag,0
           jnz    D1         
           cmp   MsgTimeOutFlag,0
           jnz   DExit
D1:
           cmp   MsgMicrOutFlag,0
           jnz   DExit
 
           mov   cx,0ffffh           
DLoop:           
           sub   cx,1
           add   cx,1
           sub   cx,1
           add   cx,1
           sub   cx,1
           add   cx,1
           ;sub   cx,1
           ;add   cx,1
           loop  DLoop           
           
DExit:           
           pop   cx
           ret
Delay      ENDP      


Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop          
           
           call  FuncPrep    ;Функциональная подготовка
Begin:
           call  DecNaschet 
           call  IncNaschet
           call  Znakomesto
           call  PuskBtn
           call  SbrosBtn
           call  NewDokBtn
           call  MicrOutBtn
           call  DispTime
           call  Timer   
           call  DispMessages
           call  MinLeft
           call  DispToBin
           call  Delay
           jmp   Begin          

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END