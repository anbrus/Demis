RomSize    EQU   4096
Delay      EQU   0e000h
Data       SEGMENT AT 0
      

rt         db    ? 
low_lim    db    ?
hi_lim     db    ?
low_lim1   db    ?
hi_lim1    db    ?
low_lim2   db    ?
hi_lim2    db    ?
low_lim3   db    ?
hi_lim3    db    ?
cur_temp   db    ?
cur_temp1  db    ?
cur_temp2  db    ?
cur_temp3  db    ?
portin     dw    ?
portoutl   dw    ?
portouth   dw    ?
tochka     db    ?
delay_cur  DW    ? 
zona       db    ?
mode       db    ?

Data       ENDS

Code       segment 
           assume cs:Code,ds:Data
Image  DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh

ACP proc near           
           mov dx,portin
           in al,dx
           mov ah,0
           mov dl,10
           div dl 
           mov ah,0
              
           lea bx,Image
           add al,5
           mov cl,al           ;return temperature-> low_lim & hi_lim & cur_temp
           cmp al,09h
           js k1
           jz k1
           cmp al,013h
           js k2
           jz k2
           cmp al,01dh
           js k3
           jz k3
           cmp al,01eh
           jz k4
           
   k1:     add bx,ax
           mov al,es:[bx]
           mov dx,portoutl
           out dx,al
           mov al,03fh
           mov dx,portouth
           out dx,al    
           jmp  y

   k2:     add al,06h
           shl al,4
           shr al,4  
           add bx,ax
           mov al,es:[bx]
           mov dx,portoutl
           out dx,al
           mov al,00ch
           mov dx,portouth
           out dx,al
           jmp y
    k3:    add al,0ch
           shl al,4
           shr al,4
           add bx,ax
           mov al,es:[bx]
           mov dx,portoutl
           out dx,al
           mov al,076h
           mov dx,portouth
           out dx,al
           jmp y
    k4:    mov al,03fh
           mov dx,portoutl
           out dx,al
           mov al,05eh
           mov dx,portouth
           out dx,al
 y:        ret          
ACP  endp           

disp proc near
           lea bx,Image
           mov ah,0
           cmp al,09h
           js dk1
           jz dk1
           cmp al,013h
           js dk2
           jz dk2
           cmp al,01dh
           js dk3
           jz dk3
           cmp al,01eh
           jz dk4
           
   dk1:    add bx,ax
           mov al,es:[bx]
           mov dx,portoutl
           out dx,al
           mov al,03fh
           mov dx,portouth
           out dx,al    
           jmp  dy

   dk2:    add al,06h
           shl al,4
           shr al,4  
           add bx,ax
           mov al,es:[bx]
           mov dx,portoutl
           out dx,al
           mov al,00ch
           mov dx,portouth
           out dx,al
           jmp dy
    dk3:   add al,0ch
           shl al,4
           shr al,4
           add bx,ax
           mov al,es:[bx]
           mov dx,portoutl
           out dx,al
           mov al,076h
           mov dx,portouth
           out dx,al
           jmp dy
    dk4:   mov al,03fh
           mov dx,portoutl
           out dx,al
           mov al,05eh
           mov dx,portouth
           out dx,al
 dy:        ret          
disp endp

working  proc near

           mov cx,delay_cur 
           mov dl,cur_temp
           sub dl,low_lim
           mov rt,0ffh
           js n10
          
           mov dl,cur_temp
           cmp dl,hi_lim
           jz n9
           js n9 
           
           mov dl,cur_temp
           sub dl,30
           mov dh,dl 
           mov rt,0
           js n11
 
 n6:       dec   cx              ;задержка
           cmp   cx,0            ;для 
           jnz   n6              ;вентилятора
           
           cmp rt,0ffh
           jnz n8
           mov al,tochka 
           ror  tochka,1
           out 0,al
           mov al,00001111b
           out 1,al
n8:        cmp rt,0ffh
           jz n7
           mov al,tochka
           rol tochka,1         
           out 0,al
           mov al,11110000b
           out 1,al
   
  n7:      call strob
           
           jmp en  
           
n9:       
           mov al,0
           out 01h,al
           jmp n7

n10:       mov dl,low_lim
           sub dl,cur_temp
           shl dl,3
           mov dh,dl
           mov dl,0
           mov ax,delay
           mov delay_cur,ax
           sub delay_cur,dx
      
           jmp n6

n11:       mov dl,cur_temp
           sub dl,hi_lim
           shl dl,3
           mov dh,dl
           mov dl,0
           mov ax,delay
           mov delay_cur,ax
           sub delay_cur,dx

           jmp n6
              
en:        ret

working endp

strob proc near
           mov al,0
           out 02h,al
           out 05h,al
           out 06h,al
           out 022h,al
           out 032h,al
           mov al,1
           out 02h,al
           out 05h,al
           out 06h,al
           out 022h,al
           out 032h,al
           ret
strob endp
init proc near
           mov cx,delay
           mov delay_cur,cx
           mov tochka,1
           mov low_lim,0
           mov hi_lim,0 
           mov cur_temp,0 
           mov low_lim1,5
           mov hi_lim1,5 
           mov cur_temp1,0 
           mov low_lim2,5
           mov hi_lim2,5 
           mov cur_temp2,0 
           mov low_lim3,5
           mov hi_lim3,5 
           mov cur_temp3,0 
           mov zona,01h
           mov mode,01h
           ret
init endp

Current_temp proc near
           mov portin,00h
           mov portoutl,04h
           mov portouth,03h 
           call ACP
           mov cur_temp1,cl
           mov cx,0
           
           mov portin,022h
           mov portoutl,020h
           mov portouth,021h 
           call ACP
           mov cur_temp2,cl
           mov cx,0

           mov portin,032h
           mov portoutl,030h
           mov portouth,031h 
           call ACP
           mov cur_temp3,cl
           mov cx,0
           ret
Current_temp endp

zona1 proc near
           cmp zona,00h
           jnz aq1
           cmp mode,00h
           jnz aq1
           mov portin,01h
           mov portoutl,010h
           mov portouth,011h 
           call ACP
           mov low_lim1,cl
           mov cx,0
           
           mov portin,02h
           mov portoutl,012h
           mov portouth,013h 
           call ACP
           mov hi_lim1,cl
           mov cx,0 
           
           mov portin,00h
           mov portoutl,040h
           mov portouth,041h 
           call ACP
           mov al,00h
           out 01h,al
aq1:       ret
zona1 endp

zona2 proc near
           cmp zona,0fh
           jnz aq2
           cmp mode,00h
           jnz aq2
           mov portin,01h
           mov portoutl,010h
           mov portouth,011h 
           call ACP
           mov low_lim2,cl
           mov cx,0
           
           mov portin,02h
           mov portoutl,012h
           mov portouth,013h 
           call ACP
           mov hi_lim2,cl
           mov cx,0 
           
           mov portin,022h
           mov portoutl,040h
           mov portouth,041h 
           call ACP
           mov al,00h
           out 01h,al
aq2:       ret
zona2 endp 

zona3 proc near
           cmp zona,0ffh
           jnz aq3
           cmp mode,00h
           jnz aq3
           mov portin,01h
           mov portoutl,010h
           mov portouth,011h 
           call ACP
           mov low_lim3,cl
           mov cx,0
           
           mov portin,02h
           mov portoutl,012h
           mov portouth,013h 
           call ACP
           mov hi_lim3,cl
           mov cx,0 
           
           mov portin,032h
           mov portoutl,040h
           mov portouth,041h 
           call ACP
           mov al,00h
           out 01h,al
 aq3:      ret
zona3 endp

prep1 proc near
           mov al,cur_temp1
           mov cur_temp,al
           mov al,low_lim1   
           mov low_lim,al
           mov al,hi_lim1
           mov hi_lim,al
           ret
prep1   endp


prep2 proc near
           mov al,cur_temp2
           mov cur_temp,al
           mov al,low_lim2
           mov low_lim,al
           mov al,hi_lim2
           mov hi_lim,al
           ret
prep2  endp

prep3  proc near
           mov al,cur_temp3
           mov cur_temp,al
           mov al,low_lim3
           mov low_lim,al
           mov al,hi_lim3
           mov hi_lim,al
           ret
prep3 endp

global_work1 proc near
           cmp zona,00h
           jnz aw1
           cmp mode,0ffh
           jnz aw1
           call prep1
           call working
           mov portin,00h
           mov portoutl,040h
           mov portouth,041h 
           call ACP
           mov al,low_lim1
           mov portoutl,010h
           mov portouth,011h
           call disp
           mov al,hi_lim1
           mov portoutl,012h
           mov portouth,013h
           call disp
aw1:       ret
global_work1 endp

global_work2 proc near
           cmp zona,0fh
           jnz aw2
           cmp mode,0ffh
           jnz aw2
           call prep2
           call working
           mov portin,022h
           mov portoutl,040h
           mov portouth,041h 
           call ACP
           mov al,low_lim2
           mov portoutl,010h
           mov portouth,011h
           call disp
           mov al,hi_lim2
           mov portoutl,012h
           mov portouth,013h
           call disp
aw2:       ret
global_work2 endp

global_work3 proc near
           cmp zona,0ffh
           jnz aw3
           cmp mode,0ffh
           jnz aw3
           call prep3
           call working
           mov portin,032h
           mov portoutl,040h
           mov portouth,041h 
           call ACP
           mov al,low_lim3
           mov portoutl,010h
           mov portouth,011h
           call disp
           mov al,hi_lim3
           mov portoutl,012h
           mov portouth,013h
           call disp
aw3:       ret
global_work3 endp

select proc near
 q:        mov al,00h
           out 051h,al
           in al,050h
           cmp al,01h
           jnz w1        
           mov zona,00h
           jmp qq
           
  w1:      in al,050h   
           cmp al,02h
           jnz w2
           mov zona,0fh
           jmp qq
           
  w2:      in al,050h
           cmp al,04h
           jnz next
           mov zona,0ffh
           jmp qq          
  next:  
           mov al,0fh
           out 051h,al
           in al,050h        
           cmp al,01h
           jz q
           cmp al,02h
           jz q
           cmp al,04h
           jz q
           jnz next
 
qq:        in al,052h
           cmp al,01h
           jnz qw
           mov mode,0ffh
           jmp qu

qw:        mov mode,00h
qu:        ret
select endp


Start:
           mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
     
           call init
n5:        call strob
           call Current_temp
           call select
           call zona1
           call global_work1
           call zona2
           call global_work2
           call zona3
           call global_work3
    
           jmp n5 

           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end
