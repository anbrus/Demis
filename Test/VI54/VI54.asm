.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   8192

IntTable   SEGMENT use16 AT 0
;Здесь размещаются адреса обработчиков прерываний
           org   32*4
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

Int32Handler     PROC FAR
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
           mov   al,  74h
           out   43h, al
           mov   al,  10
           out   41h, al
           mov   al,  0
           out   41h, al
           
           ret
InitFlash  ENDP

InitCounter      PROC  NEAR
           xor   ax, ax
           mov   IntCounter, ax
           
           mov   al,  0B4h
           out   43h, al
           mov   al,  10
           out   42h, al
           mov   al,  0
           out   42h, al
           
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
           
           call  InitFlash
           call  InitCounter
           sti
           
           ;call  TestMode0
           ;call  TestMode1
           ;call  TestMode2
      
           int   20h     
MLoop:
           call  ShowCounter
           hlt
           jmp   MLoop

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END		Start
