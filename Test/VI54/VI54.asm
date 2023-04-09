.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   16384

IntTable   SEGMENT use16 AT 0
;Здесь размещаются адреса обработчиков прерываний
           org   20h*4        ; По этому смещению находится адрес обработчика прерывания 20h
Int32HandlerPtrOffs dw ?
Int32HandlerPtrSeg  dw ?
IntTable   ENDS

Data       SEGMENT use16 AT 40h
;Здесь размещаются описания переменных
IntCounter dw ?
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT use16 AT 100h
;Задайте необходимый размер стека
           dw    100h dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
InitDataStart:
;Здесь размещается описание неизменяемых данных, которые будут храниться в ПЗУ
InitDataEnd:
InitData   ENDS

Code       SEGMENT use16
;Здесь размещается описание неизменяемых данных

           ASSUME cs:Code, ds:Data, es:Data, ss: Stk

include    utils.asm
include    mode0.asm
include    mode1.asm
include    mode2.asm
include    mode3.asm
include    mode4.asm
include    mode5.asm

Int32Handler     PROC FAR    ; Обработчик прерывания 20h
           push  ax
           push  ds
           
           mov   ax, Data
           mov   ds, ax
           inc   IntCounter
           
           pop   ds
           pop   ax
           iret
Int32Handler     ENDP

InitFlash  PROC  NEAR
           ; Программируем таймер 1: режим 2, коэффициент деления 10
           ; Режим 2 выглядит так: ----_----_----_- ...
           mov   al,  74h
           out   43h, al
           mov   al,  10
           out   41h, al
           mov   al,  0
           out   41h, al
           
           ret
InitFlash  ENDP

InitCounter      PROC  NEAR
           ; Обнуляем счётчик прерываний
           xor   ax, ax
           mov   IntCounter, ax
           
           ; Программируем таймер 2: режим 2, коэффициент деления 10
           ; Режим 2 выглядит так: ----_----_----_- ...
           mov   al,  0B4h
           out   43h, al
           mov   al,  10
           out   42h, al
           mov   al,  0
           out   42h, al
           
           ; Установка обработчика прерывания
           push  ds
           mov   ax, IntTable
           mov   ds, ax
           mov   ax, cs:Int32Handler
           mov   ds:Int32HandlerPtrOffs, ax
           mov   ax, Code
           mov   ds:Int32HandlerPtrSeg, ax
           pop   ds
           
           ret
InitCounter      ENDP

           ; Выводит содержимое счётчика прерываний в порт 20h
ShowCounter      PROC NEAR
           mov   ax,  IntCounter
           out   20h, al
           ret
ShowCounter      ENDP

Start:
           mov   ax, Data
           mov   ds, ax
           mov   es, ax
           mov   ax, Stk
           mov   ss, ax
           lea   sp, StkTop
;Здесь размещается код программы
           
           call  InitFlash   ; Инициализация таймера мигающего светодиода
           call  InitCounter ; Инициализация таймера со счётчиком прерываний
           sti
           
           ; Тесты режимов таймера согласно осциллограмм из документации
           ; Смотри 8254.pdf из папки проекта
           call  TestMode0
           call  TestMode1
           call  TestMode2
           call  TestMode3
           call  TestMode4
           call  TestMode5
      
           int   20h         ; Проверка программного вызова прерываний
MLoop:
           call  ShowCounter ; Обновление порта вывода счётчика прерываний
           hlt               ; Ждём прерывания
           jmp   MLoop       ; Бесконечный цикл

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END	   Start
