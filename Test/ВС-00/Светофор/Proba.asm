.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

IntTable   SEGMENT AT 0 use16
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT AT 40h use16
;Здесь размещаются описания переменных
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT XXXXh use16
;Задайте необходимый размер стека
           dw    XXXX dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант
InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data,es:Data
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы
           

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
