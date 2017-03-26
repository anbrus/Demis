.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

Code       SEGMENT use16
           ASSUME cs:Code,ds:Code,es:Code
Start:
InfLoop:
           in    al,0
           out   0,al
           
           jmp   InfLoop

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
