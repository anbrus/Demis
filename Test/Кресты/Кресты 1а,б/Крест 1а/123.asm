.386
RomSize    EQU   256

Data       SEGMENT AT 40h use16
Data       ENDS

Code       SEGMENT use16
           ASSUME cs:Code,ds:Data,es:Data
Start:
           in al, 0
           out 0, al

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
