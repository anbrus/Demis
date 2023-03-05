Data Segment at 0BA00H
         Rez db 5 dup (?)
         Arg db 5 dup (?)
         Mem db 5 dup (?)
         Operation db ?

         Error db ?

         ; строка ввода/вывода данных на дисплей
         Str db 13 dup (?) ; 8 разрядов отделенных точкой, знак, число
                           ; введеных разрядов, флаг наличия точки, флаг
                           ; того что строку надо вводить заново
         ActiveButtonCode db ?
         OutputMap db 13 dup (?) ; массив образов

         MulRez dw 4 dup (?)
Data EndS

Code Segment
Assume cs:Code,ds:Data,es:Data

InitOutputMap Proc near ; образы цифр
         mov OutputMap[0],3Fh
         mov OutputMap[1],0Ch
         mov OutputMap[2],76h
         mov OutputMap[3],05Eh
         mov OutputMap[4],4Dh
         mov OutputMap[5],5Bh
         mov OutputMap[6],7Bh
         mov OutputMap[7],0Eh
         mov OutputMap[8],7Fh
         mov OutputMap[9],5Fh
         mov OutputMap[10],80h
         mov OutputMap[11],40h
         mov OutputMap[12],0h
         ret
InitOutputMap EndP

DispClear Proc near
         push ax
         push dx

         xor dx,dx

; погасить все индикаторы
   DCcyc:mov al,0
         out dx,al
         inc dx
         cmp dx,10
         jne DCcyc

         mov al,3Fh ; вывести в младший
         out 0,al   ; индикатор "0"

         pop dx
         pop ax
         ret
DispClear EndP

StrClear Proc near
         push ax
         push di

         lea di,Str
         mov al,12
         mov cx,10
   SCcyc:stosb
         loop SCcyc

         mov al,0
         stosb
         stosb

         mov al,0FFh
         stosb

         pop di
         pop ax
         ret
StrClear EndP

FloatClear Proc near ; в регистре di смещение вещественного числа
         push ax
         push bx
         push cx

         xor bx,bx
         mov cx,5
   FCcyc:mov al,[di+bx]
         xor al,al
         mov [di+bx],al
         inc bx
         loop FCcyc

         pop cx
         pop bx
         pop ax
         ret
FloatClear EndP

FloatNeg Proc near ; в di адрес вещественного числа
         push ax
         push dx

         mov ax,0FFFFh
         mov dx,0FFFFh

         sub ax,[di+1]
         sub dx,[di+3]

         add ax,1
         adc dx,0

         mov [di+1],ax
         mov [di+3],dx

         pop dx
         pop ax
         ret
FloatNeg EndP

ErrMsgOut Proc near
         push ax

         call DispClear

         mov al,73h ; очертания символа E
         out 4,al
         mov al,60h ; очертания символа r
         out 3,al
         out 2,al
         out 0,al
         mov al,78h ; очертания символа o
         out 1,al

         pop ax
         ret
ErrMsgOut EndP

include io.asm
include convs.asm
include math.asm

   Begin:mov ax,Data
         mov ds,ax
         mov es,ax

         mov ax,Stack
         mov ss,ax
         mov sp,offset StkTop

         call InitOutputMap

         mov ActiveButtonCode,17
         call Clear

         mov ActiveButtonCode,20
         call MemoryClear

         call DispClear

    WCyc:call KbdRead
         call DigInput
         call PointInput
         call SignChange

         call Calculate

         call AddRezArg
         call SubRezArg
         call MulRezArg
         call DivRezArg

         call Clear
         call CE
         call Undo

         call MemoryClear
         call MemoryRead
         call MemorySet
         call MemoryAdd

         call StrOutput
         jmp WCyc

         org 0FF0h
   Start:jmp Begin
Code EndS

Stack Segment at 0BA80H
     dw 100 dup (?)
     StkTop label Word
Stack EndS

  End Start