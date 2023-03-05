name Translator_To_Morze_Code

tire=01H
tiretire=0101H
maxdelta=400

data segment at 0BA00H

       Map db 17 dup (?)
       code db 80 dup (?)
       codelong db 16 dup (?)

       curbuffer db 500 dup (?)
       mesbuffer db 100 dup (?)
       portout db 4 dup (?)

       tecbufindex db ?
       tup dw ?
       tdown dw ?

       mode db ?
       outputenable db ?
       digit db ?
       kinew dw ?
       kiold dw ?
       opernew db ?
       operold db ?
       kbdactive db ?
       operactived db ?

       v db ?
       quant dw ?
       kdlp dw ?
       kdl1 dw ?
       dl1 dw ?
       dlp dw ?
       pause db ?
       tectime dw ?
       lasttime dw ?

data ends

steck segment at 0BA80H
  dw 50H dup (?)
  StkTop label word
steck ends

codee segment
assume cs:codee,ds:data,ss:steck

Prepare proc near
     ; Map initialization
       mov Map[0], 3FH
       mov Map[1], 0CH
       mov Map[2], 76H
       mov Map[3], 05EH
       mov Map[4], 4DH
       mov Map[5], 5BH
       mov Map[6], 7BH
       mov Map[7], 0EH
       mov Map[8], 7FH
       mov Map[9], 5FH
       mov Map[10],01101111b
       mov Map[11],01111001b
       mov Map[12],00110011b
       mov Map[13],01111100b
       mov Map[14],01110011b
       mov Map[15],01100011b
       mov map[16],0

     ; MesBuffer
       mov cx,99
pm1:   mov bx,cx
       mov mesbuffer[bx],16
       loop pm1
       mov mesbuffer[0],16

      ;CodeLong
       mov word ptr codelong,0505H
       mov word ptr codelong+2,0505H
       mov word ptr codelong+4,0505H
       mov word ptr codelong+6,0505H
       mov word ptr codelong+8,0505H
       mov word ptr codelong+10,0402H
       mov word ptr codelong+12,0304H
       mov word ptr codelong+14,0401H

      ;Code
       mov cx,79
pm2:   mov bx,cx
       mov code[bx],0
       mov code[0],0

       mov word ptr code,tiretire
       mov word ptr code+2,tiretire
       mov byte ptr code+4,tire
       mov word ptr code+6,tiretire
       mov word ptr code+8,tiretire
       mov word ptr code+12,tiretire
       mov byte ptr code+14,tire
       mov word ptr code+18,tiretire
       mov byte ptr code+24,tire
       mov byte ptr code+30,tire
       mov word ptr code+35,tiretire
       mov word ptr code+40,tiretire
       mov byte ptr code+42,tire
       mov word ptr code+45,tiretire
       mov word ptr code+47,tiretire
       mov byte ptr code+51,tire
       mov byte ptr code+55,tire
       mov byte ptr code+60,tire
       mov byte ptr code+62,tire
       mov byte ptr code+65,tire
       mov byte ptr code+77,tire

      ;Other variables
       mov mode,0
       mov outputenable,0
       mov digit,16
       mov kinew,0
       mov kbdactive,0
       mov operactived,0
       mov pause,0FFH
       mov ax,tup
       mov tdown,ax
       mov tecbufindex,0

       mov quant,2
       mov v,5
       mov kdl1,3
       mov kdlp,2
       mov al,10
       sub al,v
       mul quant
       mov bx,ax
       mul kdl1
       mov dl1,ax
       mov ax,bx
       mul kdlp
       mov dlp,ax

ret
endp; prepare

InKbd proc near
      in al,0
      mov byte ptr kinew,al
      in al,1
      mov byte ptr kinew+1,al
      in al,4
      mov opernew,al
      ret
endp; inkbd

IdentifOperations proc near

      mov kbdactive,0
      mov ax,kiold
      or ax,ax
      jnz im2
      mov ax,kinew
      or ax,ax
      jz im2
      mov kbdactive,1

     ;Digit = f(AX) = f(kinew)
      mov digit,0
im3:  inc digit
      shr ax,1
      jnz im3
      dec digit

im2:  mov ax,kinew; if keyboard is not active
      mov kiold,ax
      mov operactived,0
      mov al,operold
      or al,al
      jnz im4
      mov al,opernew
      or al,al
      jz im4
      mov operactived,1
im4:  mov al,opernew
      mov operold,al
      ret
endp; identifoperations

DoKbdOperations proc near

      ;         int 1AH    ; освежаем значение
      ;         mov tectime,dx   ;             текущего времени
      inc tectime

      mov al,kbdactive
      or al,al
      jz outdokbd

      mov al,mode
      or al,al
      jz mode0
      jmp outdokbd

mode0:
      mov al,outputenable
      or al,al
      jnz dnz1
      jmp outdokbd
dnz1: 
      mov ax,tup
      cmp ax,tdown
      jne ok
      mov al,pause
      or al,al
      jz ok ; jump, если сейчас идет передача
      mov ax,tectime ; засечь
      mov lasttime,ax       ; время, если передача сейчас не идет
      mov pause,0FFH
ok:   mov ax,tup ; далее добавляем в конец CurBuffer код для 
      mov si,ax     ; только что нажатой клавиши
      xor ax,ax
      mov al,digit
      xor cx,cx
      xor bx,bx
      mov bl,al
      mov cl,codelong[bx]
      mov bx,offset code
      mov al,digit
      mov dl,5
      mul dl
      add bx,ax
dm3:  cmp si,499
      je dm4
      inc si
      jmp dm5
dm4:  mov si,0
dm5:  mov al,[bx]
      mov curbuffer[si],al
      inc bx
      loop dm3
      mov tup,si
outdokbd:
      ret
endp; dokbdoperations

DoPultOperations proc near

      mov al,operactived
      or al,al
      jnz dnz2
      jmp outpult
dnz2: 
      mov al,opernew
      test al,1
      jz oper1

      not mode ; change mode
      cmp mode,0
      jne dm10
      mov ax,tdown ; if now mode = 0
      mov tup,ax
      mov pause,0FFH
      jmp outpult

dm10: mov ax,tdown ; if now mode = FF
      mov tup,ax
      mov pause,0FFH

      mov ax,tectime ; засечь 
      mov lasttime,ax ;     время

      mov ax,tup  ; Далее загружаем в CurBuffer код сообщения
      mov si,ax
      xor di,di
      mov al,tecbufindex
      mov dl,al
mload:xor ax,ax 
      mov al,mesbuffer[di]
      cmp al,16
      je outld
      mov al,mesbuffer[di]
      xor cx,cx
      xor bx,bx
      mov bl,al
      mov cl,codelong[bx]
      mov bx,offset code
      mov dl,5
      mul dl
      add bx,ax
dmm3: cmp si,499
      je dmm4
      inc si
      jmp dmm5
dmm4: mov si,0
dmm5: mov al,[bx]
      mov curbuffer[si],al
      inc bx
      loop dmm3
      inc di
      jmp mload
outld:mov tup,si
      jmp outpult

oper1:mov al,opernew
      test al,2
      jz oper2
      not outputenable
      mov ax,tectime
      mov lasttime,ax

oper2:mov al,opernew
      test al,4
      jz oper3
      mov al,v
      cmp al,9
      je oper3
      inc v

oper3:mov al,opernew
      test al,8
      jz oper4
      mov al,v
      cmp al,0
      je oper4
      dec v

oper4:mov al,opernew
      test al,16
      jz oper5
      mov al,tecbufindex
      cmp tecbufindex,98
      je oper5
      inc tecbufindex

oper5:mov al,opernew
      test al,32
      jz oper6
      mov al,tecbufindex
      cmp tecbufindex,0
      je oper6
      dec tecbufindex

oper6:mov al,opernew
      test al,64
      jz oper7
      mov al,digit
      xor bx,bx
      mov bl,tecbufindex
      mov mesbuffer[bx],al

oper7:mov al,opernew
      test al,128
      jz outpult
      mov digit,16
outpult:
      ret
endp; doPultoperations

PrepareOutput proc near

      mov al,v
      mov bx,offset map
      xlat
      mov portout[0],al; скорость

      ; задержки = f(v,quant,коэффициенты задержек)
      mov al,10
      sub al,v
      mul quant
      mov bx,ax
      mul kdl1
      mov dl1,ax
      mov ax,bx
      mul kdlp
      mov dlp,ax

      xor bx,bx
      mov bl,tecbufindex
      mov al,mesbuffer[bx]
      mov bx,offset map
      xlat
      mov portout[1],al ; текущая цифра сообщения
   
      xor ax,ax
      mov bx,offset map
      mov al,digit
      xlat
      mov portout[3],al; последняя нажатая

      mov dl,portout[2]
      and dl,03H
      mov al,mode
      or al,al
      jz dm11
      or dl,8 ; if mode = FF
      jmp dm12
dm11: or dl,4 ; if mode = 0
dm12: mov al,outputenable
      or al,al
      jz dm19
      or dl,16 ; if output is enable
dm19: cmp tecbufindex,0
      jne dm20
      or dl,32 ; если на начале буфера сообщений
dm20: cmp tecbufindex,98
      jne dm21
      or dl,64 ; если в конце буфера сообщений
dm21: mov ax,tup
      cmp ax,tdown
      jb dm22
      sub ax,tdown
      jmp dm23
dm22: mov ax,65535
      sub ax,tdown
      add ax,tup
dm23: cmp ax,maxdelta; maxdelta=400
      jb dm24
      or dl,128 ; если ввод намного опережает вывод
dm24:
      mov portout[2],dl
      ret
endp; prepareoutput

DoOperations proc near
      call DoKbdOperations
      call DoPultOperations
      call PrepareOutput      
      ret
endp; dooperations

RefreshScreen proc near
      mov al,portout[0]
      out 0,al
      mov al,portout[1]
      out 1,al
      mov al,portout[3]
      out 3,al
      mov al,portout[2]
      out 2,al
      ret
endp;refreshscreen

FormMorzeCode proc near

      mov al,outputenable
      or al,al
      jnz fnz1
      jmp outf
fnz1:
      and portout[2],0FCH

      mov al,pause
      or al,al
      jz mm1
      mov ax,tdown
      cmp ax,tup
      jne fnz2
      jmp outf
fnz2:
      or portout[2],2
      mov ax,lasttime
      cmp ax,tectime
      ja mm2
      mov ax,tectime
      sub ax,lasttime
     jmp mm3
mm2: mov ax,65535
     sub ax,lasttime
     add ax,tectime
mm3: cmp ax,dlp
     jb outf
     not pause
     mov ax,tectime
     mov lasttime,ax
     cmp tdown,499
     je mm4
     inc tdown
     jmp outf
mm4: mov tdown,0
     jmp outf
                      ; если сейчас не пауза:
mm1: or portout[2],3
     mov ax,lasttime
     cmp ax,tectime
     ja mm5
     mov ax,tectime
     sub ax,lasttime
     jmp mm6
mm5: mov ax,65535
     sub ax,lasttime
     add ax,tectime
mm6: mov dx,ax
     mov bx,tdown
     mov al,curbuffer[bx]
     or al,al
     jz mm7
     mov ax,dl1
     jmp mm8
mm7: mov ax,quant
mm8: cmp dx,ax
     jb outf
     not pause
     mov ax,tectime
     mov lasttime,ax
outf:
ret      
endp;formmorzecode

start: 
       mov ax,data
       mov ds,ax
       mov ax,steck
       mov ss,ax       
       mov sp,offset StkTop 
       
       call prepare

begin: call InKbd
       call IdentifOperations
       call DoOperations
       call FormMorzeCode
       call RefreshScreen
       jmp begin
       org 07F0H
       jmp start
codee ends
end start