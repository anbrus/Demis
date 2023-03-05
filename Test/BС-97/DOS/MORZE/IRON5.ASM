name CodeM
ConstDelay=15

MaxTimeOff=100
MaxTimeOn=127

MinPoint=15
MaxPoint=35
PointDefis=45
MinDefis=60
MaxDefis=90
DefisNo=100

MinInPause=15
MaxInPause=35
InInter=45
MinInterPause=60
MaxInterPause=90

FastIn=1
NormalIn=2
SlowIn=3
FastInter=4
NormalInter=5
SlowInter=6

FastPoint=1
NormalPoint=2
SlowPoint=3
FastDefis=4
NormalDefis=5
SlowDefis=6
VeryLongOn=7


DATA SEGMENT
TimeOff         db      ?
TimeON          db      ?
EmptyKey        db      ?
OnErr           db      ?
OffErr          db      ?
ErrImg          db      ?
CoM             db      ?
CoMI            db      ?

Cod             db      ?
Count           db      ?
CoMITabl DB 5 DUP (?)
DATA ENDS

STACK1 SEGMENT
         dw 15 dup (?)
stk_top  label word
STACK1 ENDS

code segment
       assume cs:code,ds:data,ss:stack1
;               0    1     2    3   4    5    6    7    8    9     a   °     £   •    ≠   Æ   Ø  ‡    ·   „   Á    Ì
Tabl       DB  0BFH,0BCH,0B8H,0B0H,0A0H,0A1H,0A3H,0A7H,0AFH,0BEH, 42H, 81H, 63H, 20H,41H,67H,86H,62H,60H,64H,087h,0A4H
ImageTabl  DB   3FH, 0CH, 76H, 5EH, 4DH, 5DH, 7BH, 0EH, 7EH, 5FH, 6FH, 7BH, 23H, 73H,6DH,3FH,2FH,67H,33H,5BH, 4DH,5EH,0H

Delay PROC
        pushf
        push cx
        mov cx,ConstDelay
d:      nop
        nop
        loop d
        pop cx
        popf
        ret
Delay ENDP

; ******************************
Roll proc
        mov bx,4
r1:     mov al,CoMITabl[bx]-1
        mov CoMITabl[bx],al
        dec bx
        jnz r1
        mov al,CoMI
        mov CoMITabl,al
        ret
Roll endp

ImageForm PROC
       lea SI,Tabl
       lea DI,ImageTabl
       mov cx,22
       mov al,CoM
iif1:  cmp al,cs:[SI]
       jz  iif2
       inc DI
       inc SI
       loop iif1
iif2:  mov al,cs:[DI]
       mov CoMI,al
       ret
ImageForm ENDP

DecodChar proc
        mov al,Count
        mov cl,5
        shl al,cl
        and al,11100000B
        mov cl,8
        sub cl,Count
        shr Cod,cl
        and Cod,00011111B
        or al,Cod
        mov CoM,al
        call ImageForm
        call Roll
        ret
DecodChar endp

NextChar proc
        cmp Count,0
        jz ncend
        call DecodChar
        mov Count,0
        mov Cod,0
ncend:  ret
NextChar endp

InputPoint PROC
        cmp Count,5
        ja ipend
        clc
        rcr Cod,1
        inc Count
ipend:  ret
InputPoint ENDP

InputDefis PROC
        cmp Count,5
        ja idend
        stc
        rcr Cod,1
        inc Count
idend:  ret
InputDefis ENDP

; *******************************************
GetKey proc
        mov EmptyKey,0
        mov TimeOff,0
        mov TimeOn,0
k1:     call Delay
        cmp TimeOff,MaxTimeOff
        jae kempty
        inc TimeOff
        in al,0
        and al,al
        jz k1
k4:     call Delay
        cmp TimeOn,MaxTimeOn
        jae k5
        inc TimeOn
k5:     in al,0
        and al,al
        jnz k4
        jmp kend
kempty: mov EmptyKey,1
kend:   ret
GetKey endp

DecodKey proc
        cmp EmptyKey,0
        jz d0
        call NextChar
        jmp dend2
d0:     cmp TimeOff,MinInPause
        jnb d1
        mov OffErr,FastIn
        jmp dend1
d1:     cmp TimeOff,MaxInPause
        jnb d2
        mov OffErr,NormalIn
        jmp dend1
d2:     cmp TimeOff,InInter
        jnb d3
        mov OffErr,SlowIn
        jmp dend1
d3:     cmp TimeOff,MinInterPause
        jnb d4
        mov OffErr,FastInter
        call NextChar
        jmp dend1
d4:     cmp TimeOff,MaxInterPause
        jnb d5
        mov OffErr,NormalInter
        call NextChar
        jmp dend1
d5:     mov OffErr,SlowInter
        call NextChar

dend1:  cmp TimeOn,MinPoint
        jnb d6
        mov OnErr,FastPoint
        call InputPoint
        jmp dend2
d6:     cmp TimeOn,MaxPoint
        jnb d7
        mov OnErr,NormalPoint
        call InputPoint
        jmp dend2
d7:     cmp TimeOn,PointDefis
        jnb d8
        mov OnErr,SlowPoint
        call InputPoint
        jmp dend2
d8:     cmp TimeOn,MinDefis
        jnb d9
        mov OnErr,FastDefis
        call InputDefis
        jmp dend2
d9:     cmp TimeOn,MaxDefis
        jnb d10
        mov OnErr,NormalDefis
        call InputDefis
        jmp dend2
d10:    cmp TimeOn,DefisNo
        jnb d11
        mov OnErr,SlowDefis
        call InputDefis
        jmp dend2
d11:    mov OnErr,VeryLongOn
dend2:  ret
DecodKey endp

OutImage proc
        mov al,CoMITabl[0]
        out 5,al
        mov al,CoMITabl[1]
        out 4,al
        mov al,CoMITabl[2]
        out 3,al
        mov al,CoMITabl[3]
        out 2,al
        mov al,CoMITabl[4]
        out 1,al
        ret
OutImage endp

OutErr proc
        mov al,0
        cmp OffErr,FastIn
        jnz oe1
        or al,00000001B
oe1:    cmp OffErr,FastInter
        jnz oe2
        or al,00000010B
oe2:    cmp OnErr,FastPoint
        jnz oe3
        or al,00000100B
oe3:    cmp OnErr,FastDefis
        jnz oe4
        or al,00001000B
oe4:    cmp OffErr,SlowIn
        jnz oe5
        or al,00010000B
oe5:    cmp OffErr,SlowInter
        jnz oe6
        or al,00100000B
oe6:    cmp OnErr,SlowPoint
        jnz oe7
        or al,01000000B
oe7:    cmp OnErr,SlowDefis
        jnz oe8
        or al,10000000B
oe8:    out 6,al
        ret
OutErr endp

start:  mov ax,data
        mov ds,ax
        mov ax,stack1
        mov ss,ax
        mov sp,stk_top
        mov al,4
        out 5,al
MLoop:
        call GetKey
        call DecodKey
        call OutImage
        call OutErr

        jmp MLoop

code ends
end start


comment {
  Ä            010 00010B                 42H
  Å            100 00001B                 81H
  É            011 00011B                 63H
  Ö            001 00000B                 20H
  ç            010 00001B                 41H
  é            011 00111B                 67H
  è            100 00110B                 86H
  ê            011 00010B                 62H
  ë            011 00000B                 60H
  ì            011 00100B                 64H
  ù            101 00100B                0A4H
  1            101 11110B                0BEH
  2            101 11100B                0BCH
  3            101 11000B                0B8H
  4            101 10000B                0B0H
  5            101 00000B                0A0H
  6            101 00001B                0A1H
  7            101 00011B                0A3H
  8            101 00111B                0A7H
  9            101 01111B                0AFH
  0            101 11111B                0BFH





        mov al,Cod
        mov ah,Count
        shl ah,1
        shl ah,1
        shl ah,1
        shl ah,1
        shl ah,1
        and al,ah
        mov CoM,al
        ret

InputPoint proc
        or ErrImg,00000001B
        ret
InputPoint endp

InputDefis proc
        or ErrImg,00000010B
        ret
InputDefis endp

NextChar proc
        or ErrImg,00010000B
        ret
NextChar endp

                  {