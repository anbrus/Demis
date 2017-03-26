RomSize    EQU   4096        ;Объём ПЗУ

Code       SEGMENT
           ASSUME cs:Code
Start:
           in   al,0         ;Читаем состояние клавиш
           out  0,al         ;И выводим на светодиоды
           jmp  Start


           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
