.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code

Delay      proc  near
           push  cx
           mov   cx,800
DLoop1:
           mov   ax,100
DLoop2:
           dec   ax
           jnz   DLoop2
           loop  DLoop1
           pop   cx
           
           ret
Delay      endp

Start:
;Здесь размещается код программы
           mov   bh,0
           mov   bl,0FFh
           
InfLoop:
           ;in    al,0
           ;out   0,al
           ;in    al,1
           ;out   1,al
           ;jmp   InfLoop
           
           mov   al,0
           out   3,al
           
           mov   al,bh
           out   2,al
           mov   al,1
           out   3,al
           call  Delay
           mov   al,0
           out   3,al

           mov   al,bl
           out   2,al
           mov   al,2
           out   3,al
           call  Delay
           mov   al,0
           out   3,al
           
           in    al,0
           cmp   al,dl
           jz    InfLoop
           
           mov   dl,al

           inc   bh
           dec   bl
           
           jmp   InfLoop

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
