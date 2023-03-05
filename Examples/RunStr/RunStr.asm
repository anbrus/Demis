.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

IntTable   SEGMENT use16 AT 0 
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT use16 AT 40h
;Здесь размещаются описания переменных
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT use16 AT 100h
;Задайте необходимый размер стека
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант
InitDataStart:
Image:      
           db    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           db    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           db    080h,0BEh,0BEh,0BEh,0C1h,0FFh,0C3h,0B5h,0B5h,0B5h,0B3h,0FFh,0B3h,0B5h,0ADh,0CDh
           db    0FFh,0FBh,082h,0FFh,0E3h,05Dh,05Dh,05Dh,081h,0FFh,081h,0FBh,0FDh,0FDh,081h,0FFh
           db    0FFh,0FFh,0FFh,0FFh,0FFh,080h,0FDh,0F3h,0F3h,0FDh,080h,0FFh,0FBh,082h,0FFh,0C3h
           db    0BDh,0BDh,0BDh,0BDh,0FFh,081h,0FBh,0FDh,0FDh,0F9h,0FFh,0C3h,0BDh,0BDh,0BDh,0C3h
           db    0FFh,0B3h,0B5h,0ADh,0CDh,0FFh,0F1h,06Fh,06Fh,06Fh,081h,0FFh,0B3h,0B5h,0ADh,0CDh
           db    0FFh,0FDh,0C0h,0BDh,0BDh,0BDh,0FFh,0C3h,0B5h,0B5h,0B5h,0B3h,0FFh,081h,0FBh,0FDh
           db    081h,0FBh,0FDh,081h,0FFh,0B3h,0B5h,0ADh,0CDh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FDh
           db    0F3h,0CFh,0BFh,0CFh,0F3h,0FDh,0FFh,0BEh,0B6h,0B6h,0C9h,0FFh,09Fh,09Fh,0FFh,0BEh
           db    0B6h,0B6h,0C9h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,081h,07Eh,06Ah,05Eh,05Eh,06Ah,07Eh
           db    081h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           db    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
InitDataEnd:
InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data,es:InitData

Display    PROC  NEAR
           ;ax   Смещение от начала Image
           
           push  bx
           push  cx
           
           lea   bx,Image
           add   bx,ax
           mov   ch,1        ;Indicator Counter
OutNextInd:
           mov   al,0
           out   1,al        ;Turn off cols
           mov   al,ch
           out   2,al        ;Turn on current matrix
           mov   cl,1        ;Col Counter
OutNextCol:
           mov   al,0
           out   1,al        ;Turn off cols
           mov   al,es:[bx]
           not   al
           out   0,al        ;Set rows
           mov   al,cl
           out   1,al        ;Turn on current col
           
           shl   cl,1
           inc   bx
           jnc   OutNextCol
           shl   ch,1
           cmp   ch,16
           jnz   OutNextInd
           
           xor   al, al
           out   2, al

           pop   cx
           pop   bx
           ret
Display    ENDP

Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,InitData
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы
           mov   dx,50
InfLoop:
           mov   cx, 30
LoopDisplay:
           mov   ax, dx
           call  Display
           dec   cx
LoopDisplay1:
           jnz   LoopDisplay
           
           inc   dx
           cmp   dx,11*16
           jnz   InfLoop
           xor   dx,dx
           jmp   InfLoop
           

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
