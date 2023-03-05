data segment at 0BA00H
       Map db 11 dup (?)
       portm db 6 dup (?)
       indic db (?)
       time dw (?)
       blacklist db 24 dup (?)
       perebor db (?)
       namber db (?)
data ends 
stac segment at 0BA80H
  dw 200H dup (?)
  StkTop label word
stac ends
code segment
assume cs:code,ds:data,es:data,ss:stac
delay  macro time 
       local me
       push cx
       mov cx,time
       push ax 
me:    in al,1
       and al,01111111b
       cmp al,32
       je sto          
       loop me
       pop ax
       pop cx
endm
delay1 macro time 
       local me
       push cx
       mov cx,time
       push ax 
me:    in al,1
       and al,01111111b
       cmp al,32
       je stm          
       loop me
       pop ax
       pop cx
endm

delay2 macro time 
       local mi
       push cx
       mov cx,time
       push ax 
mi:    loop mi
       pop ax
       pop cx
endm

setupdata proc
       mov ax,data
       mov ds,ax
       mov ax,data
       mov es,ax
       mov ax,stac
       mov ss,ax       
       mov sp,offset StkTop      
       mov namber,0
       mov bx,offset Map
       mov Map[0], 0H
       mov Map[1], 3FH
       mov Map[2], 0CH
       mov Map[3], 76H
       mov Map[4], 5EH
       mov Map[5], 4DH
       mov Map[6], 5BH
       mov Map[7], 7BH
       mov Map[8], 0EH
       mov Map[9], 7FH
       mov Map[10], 5FH
       mov bx,offset blacklist
       mov si,24
res2:  dec si
       mov [bx][si],0
       cmp si,0
       jne res2
       mov bx,offset portm
       mov portm[0],0
       mov portm[1],0
       mov portm[2],0
       mov portm[3],0
       mov portm[4],0
       mov portm[5],0

       ret
setupdata endp

portread proc
         in al,0
         mov cl,al
         in al,1
         mov ah,al
         mov al,cl
         ret
portread endp

digit proc
       push ax
ot:    in al,0
       mov cl,al
       in al,1
       mov ah,al
       mov al,cl
       and ax,1023
       cmp ax,0
       jnz  ot
       pop ax
       mov cx,0
nextbit:
       inc cx
       shr ax,1
       cmp ax,0
       jnz nextbit
       mov ax,cx
       push ax
       mov si,5
m3:    mov bx,offset portm
       mov al,[bx-1][si]
       mov [bx][si],al
       mov bx,offset Map
       xlat
       mov dx,si
       out dx,al
       dec si
       cmp si,0
       ja m3
       mov bx,offset portm
       pop ax
       mov [bx],al
       mov bx,offset Map
       xlat
       out 0,al      
       ret
digit endp
 
reset proc
      mov si,6
      mov al,0
m5:   mov bx,offset portm
      dec si
      mov dx,si
      mov [bx][si],al
      out dx,al
      cmp si,0
      ja m5
      ret
reset endp

mode proc
     push ax
     and ax,8000h
     cmp ax,0
     jnz m1
     or indic,16
     and indic,20
     jmp m2
m1:  or indic,32
     and indic,36
m2:  mov al,indic
     out 6,al
     pop ax
     and ax,7fffh
     ret
mode endp

enterout proc        
        mov bx,offset portm
        mov si,6
        mov al,indic 
s3:     dec si
        mov cl,[bx][si]
        cmp cl,0
        jz s5
        dec cl 
        cmp cl,0
        jnz s1
        mov cl,10
s1:     or al,0001b
        out 6,al
        delay 200
        and al,11111110b
        out 6,al
        delay 200
        loop s1      
        delay 1000
s5:     cmp si,0
        jnz s3
ss1:    or al,010b
        out 6,al
        delay 1000
        and al,11111101b
        out 6,al
        delay 1000
        jmp ss1 
sto:    pop ax
        pop cx
sta:    ret
enterout endp

enterin1 proc
	 mov al,indic
 	 or al,8
	 out 6,al
	 delay2 7000
         ret	
enterin1 endp

enterin proc 
        mov bx,offset portm
        cmp [bx],0
        jz ste
        mov di,4 
        xor ax,ax
        xor cx,cx
s33:    mov perebor,0
        dec di
        mov si,6
s34:    dec si
        mov bx,offset portm
        mov al,[bx][si]
        mov bx,offset blacklist
        push ax      
        mov ax,6
        mov cx,di
        mul di
        mov di,ax
        add di,si     
        mov dl,[bx][di]
        mov dh,0
        pop ax
        mov ah,0
        mov di,cx
        cmp al,dl
        jne s35
        inc perebor
s35:    cmp si,0
        jnz s34
        cmp perebor,6 
        je ste
        cmp di,0
        jnz s33
        mov al,indic
s23:    or al,10b
        out 6,al
        delay1 1000
        and al,11111101b
        out 6,al
        delay1 1000
        jmp s23
stm:    pop ax  
        pop cx
ste:    cmp perebor,6
        jne stf
        call enterin1
stf:    ret
enterin endp

blklst proc
b3:    in al,1
       and al,7fh
       cmp al,0
       jne b3
       cmp namber,4
       jne b1
       or indic,100b
       mov namber,0
b1:    mov si,6
       xor cx,cx
       xor ax,ax
       mov cl,namber
b2:    dec si
       mov bx,offset portm
       mov dl,[bx][si]
       mov bx,offset blacklist
       mov al,6
       mul cl
       push si
       add si,ax
       mov [bx][si],dl
       pop si
       cmp si,0
       jne b2
       inc namber
       mov bx,offset portm
       ret
blklst endp

resetblklst proc
       mov namber,0
       and indic,11111011b
       mov bx,offset blacklist
       mov si,24
res1:  dec si
       mov [bx][si],0
       cmp si,0
       jne res1
       ret
resetblklst endp

vyborfunc proc
       cmp ax,0
       jz str2
       cmp ax,1023
       ja p1
       call digit
       jmp str2
p1:    cmp ax,4000h	
       jne p2	
       call reset
       jmp str2
p2:    cmp ax,400h
       jne p3
       cmp indic,32
       jb ps
       call enterout
       jmp str2
ps:    call enterin
       jmp str2
p3:    cmp ax,1000h
       jne P4
       call blklst
P4:    cmp ax,800h
       jne str2
call   resetblklst
str2:  ret
vyborfunc endp

org 7f0h
start: jmp begin
begin: call setupdata 
str1:  call portread
       call mode
       call  vyborfunc
       jmp str1
code ends
end start 