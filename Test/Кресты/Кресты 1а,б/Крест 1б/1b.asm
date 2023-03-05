.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

Data       SEGMENT AT 40h use16
;Здесь размещаются описания переменных
Old        db    ?
FlagLamp   db    ?
Data       ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data,es:Data
Start:
;Здесь размещается код программы
           in al, 0  ;порт ввода
           mov ah, al ;сохраняем текущее значение, т.к. испортим его
           xor al, Old ;выделяем фронты
           and al, ah  ;выделяем передние фронты
           mov Old, ah ;
           jz m1       
           not FlagLamp ;инвертируем флаг
           mov al,FlagLamp
           out 0, al

m1:        jmp Start

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
