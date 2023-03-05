NAME   Reglament

       MinStPort = 0
       MinMlPort = 1
       SekStPort = 2
       SekMlPort = 3
       LampPort  = 4
       RegimPort = 1
       InputPort = 0

Data segment at 00H
       Map db 0AH dup (?)
       Time  dw ?
       Clock dw ?
       UstanFlag  db ?
       NewDocFlag db ? 
       ResetFlag  db ?
       Lamp    db ?              
       FlagOts db ?
       FlagMig db ?
Data ends 

Code segment
Assume cs:code,ds:data

Delay proc near
      push cx
      mov cx,0FFFFh
 C:   nop
      loop C 
      pop cx
      ret
Delay endp
DelayMig proc near
      push cx
      mov cx,0FFFFh
 C1:  nop
      loop C1 
      pop cx
      ret
DelayMig endp

Clear proc near
      push dx
      push ax    
      xor dx,dx
      mov al,3fH
      mov cx,4
 M:   out dx,al
      inc dx
      loop M   
      mov al,0
      out LampPort,al
      mov Lamp,0
      pop ax
      pop dx
      ret
Clear endp

FuncProc proc near
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
         call Clear
         mov Clock,1
         mov Time,1
         mov FlagOts,00H
;         mov Lamp,0
         ret
FuncProc endp

Button proc near
       mov UstanFlag,00H
       mov NewDocFlag,00H
       mov ResetFlag,00H
       in al,RegimPort 
       cmp al,0
       jz R
       mov UstanFlag,0FFH
       jmp R2 
       
 R:    in al,InputPort
       cmp al,40H
       jne R1
       mov NewDocFlag,0FFH
       jmp R2

 R1:   cmp al,10H
       jne R2
       mov ResetFlag,0FFH
 R2:   ret
Button endp   

ResetProc proc near
          cmp ResetFlag,0FFH
          jne G
          call Clear
     ;     mov al,0
      ;   out LampPort,al
;          mov Lamp,0        
          mov ResetFlag,00H 
          mov FlagOts,00H
          mov FlagMig, 00H 
                
 G:       ret
ResetProc endp

Ustanovka proc near
          cmp UstanFlag,0FFH
	  je X
 	  jmp I

 X:	  mov UstanFlag,00H
   	  push ax 
   	  push dx
 S:	  call Clear
	  xor dl,dl
 E:	  mov ah,0FFH

 P:	  in al,RegimPort
	  cmp al,1
 	  je T
   
   	  cmp ah,0FFH
	  jne PP    
	  mov Clock,1
 	  mov FlagOts,00H
	  jmp E1

 PP:      mov cl,ah
   	  mov al,10
   	  mul dl
    	  add al,cl
 	  mov cl,60
  	  mul cl
  	  inc ax
  	  mov Time,ax
  	  mov Clock,ax
 	  mov FlagOts,0FFH
  	  jmp E1
   
 T: 	  in al,InputPort
 	  cmp al,0
 	  jz P
	  cmp al,4
 	  jz N   
 	  cmp al,10H
 	  jnz P   
 	  call Clear 
 	  jmp S

 N:	  inc ah     ;младший разряд минут
 	  cmp ah,10
 	  jz Q
 	  mov al,ah
 	  xlat
	  out MinMlPort,al
 	  call Delay
 	  jmp P
   
 Q:       inc dl     ;старший разряд минут
 	  mov al,dl
 	  xlat
	  out MinStPort,al
 	  cmp dl,6
 	  jnz E   
   	  jmp S
   
 E1:	  pop dx
  	  pop ax

 I:       ret
Ustanovka endp

Otschet proc near         
        cmp FlagOts,00H
        jne L
        jmp Y

 L:     dec Clock
        mov ax,Clock
        mov cl,60
        div cl
        mov cl,ah
        
        aam
        
        xlat
        out MinMlPort,al
        mov al,ah
        xlat
        out MinStPort,al

        mov al,cl
        
        aam
        
        xlat
        out SekMlPort,al
        mov al,ah
        xlat
        out SekStPort,al
        
        call Delay
        
        mov Lamp,0

        cmp Clock,600
        jne L1
        mov Lamp,1 
        jmp Y
 L1:    cmp Clock,300
        jne L2
        mov Lamp,2
        jmp Y
 L2:    cmp Clock,60
        jne L3
        mov Lamp,3
        jmp Y
 L3:    cmp Clock,0
        jne Y
        mov Lamp,4  
        mov FlagOts,00H
        
 Y:     ret
Otschet endp

LampProc proc near
         cmp Lamp,0
         jne W
         jmp WW

 W:      cmp Lamp,1
         jne W1
         mov al,1
         out LampPort,al
         jmp WW
 
 W1:     cmp Lamp,2
         jne W2
         mov al,8
         out LampPort,al
         jmp WW
          
 W2:     cmp Lamp,3
         jne W3
         mov al,64
         out LampPort,al
         jmp WW

 W3:     cmp Lamp,4
         jne WW 
         mov al,73
         out LampPort,al
         mov FlagMig,0FFH  
         jmp WW

 WW:     ret
LampProc endp

MigProc proc near
        cmp FlagMig,0FFH
        jne FF        
        mov al,73
        out LampPort,al 
        call DelayMig
        mov al,0
        out LampPort,al           
        call DelayMig
 FF:    ret    
MigProc endp

NewDocProc proc near        
           push ax       
           cmp NewDocFlag,0FFH
           jne B       
      	   mov NewDocFlag,00H
       	   cmp Time,1
       	   je B       
 	   mov al,0
     	   out LampPort,al     
    	   mov ax,Time
   	   mov Clock,ax
    	   mov FlagOts,0FFH       
 B:  	   pop ax

    	   ret
NewDocProc endp

Begin: mov ax,data
       mov ds,ax

       mov ax,stack1
       mov ss,ax       
       mov sp,offset StkTop 

       mov bx,offset Map
        
       call FuncProc
 M1:   call Button 
       call ResetProc       
       call NewDocProc             
       call Ustanovka       
       call Otschet 
       call LampProc
       call MigProc  
       jmp M1

       
        org  0FF0h
        assume cs:nothing
        jmp  Far Ptr begin
Start: 
Code ends

Stack1 segment stack at 080H
  db 200H dup (?)
  StkTop label word
Stack1 ends

End Start