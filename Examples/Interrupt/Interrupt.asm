;Демонстрация работы с прерываниями
;Программа будет увеличивать значение счётчика по сигналу прерывания от кнопки

.386
;Задайте объём ПЗУ в байтах
RomSize           EQU 4096

PORT_COUNTER_LOW  EQU 0      ;Порт вывода младшей цифры счётчика
PORT_COUNTER_HIGH EQU 1      ;Порт вывода старшей цифры счётчика

IntTable   SEGMENT use16 AT 0
           org   0ffh*4        ; По этому смещению находится адрес обработчика прерывания 0ffh
IntFFHandlerPtrOffs dw ?       ;Смещение обработчика прерывания  
IntFFHandlerPtrSeg  dw ?       ;Сегмент обработчика прерывания
IntTable   ENDS

Data       SEGMENT use16 AT 40h
counter    db ?  ;Двоично-десятичное значение счётчика
Data       ENDS

Stk        SEGMENT use16 AT 100h
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

Code       SEGMENT use16
;Образы цифр от 0 до 9 для 7-ми сегментного индикатора
digits     db 3Fh, 0Ch, 76h, 05Eh, 4Dh, 5Bh, 7Bh, 0Eh, 7Fh, 5Fh

           ASSUME cs:Code, ds:Data, es:Data, ss: Stk

IntHandler       PROC FAR
           push  ax
           push  ds
           
           mov   ax, Data
           mov   ds, ax
           
           call  IncCounter
           
           pop   ds
           pop   ax
           iret
IntHandler       ENDP

;Процедура отображения значения счётчика
ShowCounter      PROC NEAR
           ;Отображаем младшую цифру из младших 4 бит счётчика
           mov   al, counter
           and   al, 0fh
           xlat  digits
           out   PORT_COUNTER_LOW, al

           ;Отображаем старшую цифру из старших 4 бит счётчика
           mov   al, counter
           shr   al, 4
           xlat  digits
           out   PORT_COUNTER_HIGH, al

           ret
ShowCounter      ENDP

;Процедура инкрементирования счётчика
IncCounter       PROC NEAR
           mov   al, counter
           add   al, 1
           daa                   ;У нас счётчик двоично-десятичный, делаем коррекцию
           mov   counter, al
           
           ret
IncCounter       ENDP

Start:
           mov   ax, Data
           mov   ds, ax
           mov   es, ax
           mov   ax, Stk
           mov   ss, ax
           lea   sp, StkTop
           
           ;Устанавливаем адрес обработчика прерывания
           push  ds
           mov   ax, IntTable
           mov   ds, ax
           mov   ax, cs:IntHandler
           mov   ds:IntFFHandlerPtrOffs, ax
           mov   ax, Code
           mov   ds:IntFFHandlerPtrSeg, ax
           pop   ds
           
           
           ;Записываем в счётчик значение 0
           xor   ax, ax
           mov   counter, al
           
           ;Разрешаем прерывания
           sti
MainLoop:
           call  ShowCounter     ;Обновляем индикаторы счётчика
           hlt                   ;Останавливаем процессор до поступления прерывания
           jmp   MainLoop        ;Бесконечный цикл

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END        Start
