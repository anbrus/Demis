name    interval
zz=1	
data    segment
        time1        db 12 dup(0)
        time2        db 12 dup(0)
        out1         db 7 dup(?)
        out2         db 7 dup(?)
        digt db 3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7Fh,5Fh
data    ends

code   segment
       assume cs:code,ds:data,es:data

;��楤��
dig proc
  push ax
  push di
  push si
  lea bx,digt
  mov cx,7
d1:mov al,[si]
  xlat
  mov [di],al
  inc si
  inc di
  loop d1
  pop si
  pop di
  pop ax
  ret
dig endp

; ��楤�� ������ �६���.
cock proc
      mov byte ptr [si+11],2
      mov bl,al             
      and al,00000001b    
      cmp al,0
      clc
      jz  mk1_1
      shr bl,1
      mov al,bl
      and al,00000001b
      cmp al,[si+7]
      clc
      jg mp1
      mov [si+7],al
      mov al,[si+8]
      jmp mpb1
mp1:  mov [si+7],al
      add byte ptr [si+8],1
      and byte ptr [si+8],00000001b
      mov al,byte ptr [si+8]
      jmp mpb1
mk1_1:shr bl,1
      mov al,bl
      jmp mpb1
mpb1: and al,00000001b
      mul byte ptr [si+11]
      add al,[si]  
      mov [si],al
      cmp byte ptr [si],10    
      clc
      jnz mk1                 
      stc                     
      mov byte ptr [si],0

mk1:   mov al,[si+1]
      adc al,0
      mov [si+1],al
      cmp byte ptr [si+1],10
      clc
      jnz mk2
      stc
      mov byte ptr [si+1],0

mk2:   mov al,[si+2]
      adc al,0
      mov [si+2],al
      cmp byte ptr [si+2],6
      clc
      jnz mk3
      stc
      mov byte ptr [si+2],0

mk3:   mov al,[si+3]
      adc al,0
      mov [si+3],al
      cmp byte ptr [si+3],10
      clc
      jnz mk4
      stc
      mov byte ptr [si+3],0

mk4:   mov al,[si+4]
      adc al,0
      mov [si+4],al
      cmp byte ptr [si+4],6
      clc
      jnz mk5
      stc
      mov byte ptr [si+4],0

mk5:   mov al,[si+5]
      adc al,0
      mov [si+5],al
      cmp byte ptr [si+5],10
      clc
      jnz mk6
      stc
      mov byte ptr [si+5],0

mk6:   mov al,[si+6]
      adc al,0
      mov [si+6],al
      cmp byte ptr [si+6],10
      clc
      jnz mk7
      stc
      mov byte ptr [si+6],0
mk7:   shr bl,1
      mov al,bl
      and al,00000001b
      cmp al,1                
      jz ns

      mov byte ptr [si],0     
      mov byte ptr [si+1],0   
      mov byte ptr [si+2],0   
      mov byte ptr [si+3],0   
      mov byte ptr [si+4],0   
      mov byte ptr [si+5],0   
      mov byte ptr [si+6],0   

ns:    shr bl,1           
       mov al,bl
      ret

cock endp
start:
       mov ax,data
       mov ds,ax
       mov es,ax
begin: in al,0
       xor al,00100100b
       lea si,time1
       call cock
       lea si,time2
        call cock
       cmp al,00000001b
       jz mkok1
       lea si,time1
       lea di,out1
       call dig
       jmp x
mkok1:  lea si,time2
       lea di,out2
       call dig
x:     mov al,[di]
       out 1,al
       mov al,[di+1]
        out 2,al
       mov al,[di+2]
        out 3,al
       mov al,[di+3]
        out 4,al
       mov al,[di+4]
        out 5,al
       mov al,[di+5]
        out 6,al
       mov al,[di+6]
        out 7,al

       mov  cx,zz
ww:    nop
       loop ww
 
     jmp begin

code ends
end start
                A *.FRM                                        *.MAC                                                           <�         A *.FRM  �������������������� 