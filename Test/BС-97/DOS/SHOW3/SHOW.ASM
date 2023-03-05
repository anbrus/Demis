        PULT = 0
        LENSTR = 40
        LENCON = 10
        RUNDELAY = 1000
        SHOWDELAY = 5000
        SCRDELAY = 1000

sstack segment AT 0BA80H
        dw 20H dup (?)
Stk_Top label word
sstack ends

_Data segment AT 0BA00H
        TopStr dw ?
        EndStr dw ?
        SetDelay dw ?
        EndScroll dw ?
        StScroll dw ?
        Scroll dw 5 dup(?)
BottomScroll label word
        CopyPult db ?
_Data ends

_Code segment
        assume cs:_Code,ds:_Code,es:_Data,ss:sstack

        Str1 db ' this is  the house that jack   build   '
        Str2 db ' this is  the corn   that lay   in the  '
        Char db 6fh,79h,33h,7ch,73h,63h,5fh,6dh,21h,1ch,40h,31h,40h
             db 68h,3fh,67h,4fh,60h,5bh,71h,3dh,40h,40h,40h,4dh,76h

Delay proc
        push cx
        mov cx,SetDelay
d:      nop
        loop d
        pop cx
        ret
Delay endp

Show proc
        push ax
        push bx
        push dx
        push si
        lea bx,Char
        mov SetDelay,SHOWDELAY
s1:     mov si,TopStr
s2:     mov dx,LENCON-1
s3:     mov al,[si]
        sub al,'a'
        jnl s4
        mov al,0
        jmp s6
s4:     xlat
s6:     inc si
        out dx,al
        dec dx
        jns s3
        call Delay
        in al,PULT
        cmp al,CopyPult
        jnz s5
        mov ax,TopStr
        add ax,LENSTR
        cmp ax,si
        ja s2
        jmp s1
s5:     mov CopyPult,al
        pop si
        pop dx
        pop bx
        pop ax
        ret
Show endp

Running proc
        push ax
        push bx
        push cx
        push dx
        push si
        lea bx,Char
        mov ax,TopStr
        add ax,LENSTR
        mov EndStr,ax
        mov SetDelay,RUNDELAY
r1:     mov cx,TopStr
        sub cx,LENCON-1
r2:     mov si,cx
        inc cx
        mov dx,LENCON-1
r3:     mov al,[si]
        sub al,'a'
        jl r6
        cmp si,TopStr
        jl r6
        cmp si,EndStr
        ja r6
        xlat
r7:     inc si
        out dx,al
        dec dx
        jns r3
        call Delay
        in al,PULT
        cmp al,CopyPult
        jnz r5
        mov ax,LENSTR-1
        add ax,TopStr
        add ax,LENCON
        cmp ax,si
        jz r1
        jmp r2
r5:     mov CopyPult,al
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
r6:     mov al,0
        jmp r7
Running endp

Down proc
        push ax
        push bx
        push di
        push dx
        push si
        lea bx,Char
        mov SetDelay,SCRDELAY
d1:     mov si,TopStr
d7:     mov di,StScroll
d2:     mov dx,LENCON-1
d3:     mov al,[si]
        sub al,'a'
        jnl d4
        mov al,0
        jmp d6
d4:     xlat
d6:     inc si
        call es:[di]
        out dx,al
        dec dx
        jns d3
        call Delay
        in al,PULT
        cmp al,CopyPult
        jnz d5
        sub si,LENCON
        inc di
        inc di
        cmp di,EndScroll
        jna d2
        add si,LENCON
        mov ax,TopStr
        add ax,LENSTR
        cmp ax,si
        ja d7
        jmp d1
d5:     mov CopyPult,al
        pop si
        pop dx
        pop di
        pop bx
        pop ax
        ret
Down endp

Up proc
        push ax
        push bx
        push di
        push dx
        push si
        lea bx,Char
        mov SetDelay,SCRDELAY
u1:     mov si,TopStr
u7:     mov di,EndScroll
u2:     mov dx,LENCON-1
u3:     mov al,[si]
        sub al,'a'
        jnl u4
        mov al,0
        jmp u6
u4:     xlat
u6:     inc si
        call es:[di]
        out dx,al
        dec dx
        jns u3
        call Delay
        in al,PULT
        cmp al,CopyPult
        jnz u5
        sub si,LENCON
        dec di
        dec di
        cmp di,StScroll
        jnl u2
        add si,LENCON
        mov ax,TopStr
        add ax,LENSTR
        cmp ax,si
        ja u7
        jmp u1
u5:     mov CopyPult,al
        pop si
        pop dx
        pop di
        pop bx
        pop ax
        ret
Up endp

P2 proc
        mov ah,0
        test al,00001000b
        jz u11
        or ah,00000100b
u11:    test al,00010000b
        jz u12
        or ah,01000000b
u12:    test al,00100000b
        jz u13
        or ah,00000001b
u13:    test al,01000000b
        jz u14
        or ah,00000010b
u14:    mov al,ah
        ret
P2 endp

P1 proc
        mov ah,0
        test al,00010000b
        jz u21
        or ah,00000010b
u21:    mov al,ah
        ret
P1 endp

P4 proc
        mov ah,0
        test al,00000001b
        jz d11
        or ah,00100000b
d11:    test al,00000010b
        jz d12
        or ah,01000000b
d12:    test al,00000100b
        jz d13
        or ah,00001000b
d13:    test al,01000000b
        jz d14
        or ah,00010000b
d14:    mov al,ah
        ret
P4 endp

P5 proc
        mov ah,0
        test al,00000010b
        jz d21
        or ah,00010000b
d21:    mov al,ah
        ret
P5 endp

P3 proc
        ret
P3 endp

start:
        mov ax,_Data
        mov es,ax
        mov ax,sstack
        mov ss,ax
        lea sp,Stk_Top
        push cs
        pop ds
        lea ax,P1
        mov Scroll,ax
        lea ax,P2
        mov Scroll+2,ax
        lea ax,P3
        mov Scroll+4,ax
        lea ax,P4
        mov Scroll+6,ax
        lea ax,P5
        mov Scroll+8,ax
        lea ax,BottomScroll
        dec ax
        dec ax
        mov EndScroll,ax
        lea ax,Scroll
        mov StScroll,ax
m0:     in al,Pult
        mov CopyPult,al
m10:    lea bx,Str1
        mov TopStr,bx
        shr al,1
        jnc m1
        lea bx,Str2
        mov TopStr,bx
m1:     shr al,1
        jnc m0
        shr al,1
        jc m2
        shr al,1
        jc m3
        call Show
        jmp m10
m3:     call Running
        jmp m10
m2:     shr al,1
        jc m4
        call Down
        jmp m10
m4:     call Up
        jmp m10

_Code ends
end START