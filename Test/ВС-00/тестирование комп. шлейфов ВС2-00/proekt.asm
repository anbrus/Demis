;курсовая работа студентя группы ВС200 Красильникова О.В.
RomSize    EQU   4096

Stk        SEGMENT  AT 100h use16
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

Data       SEGMENT use16
           
            inm    dw 16 dup (?)     ;образ клавиотуры
            atm    dw 16 dup (?)     ;образ эталонного шлейфа
            merr   dw 16 dup  (?)     ;Образ ошибок 
            kolispr   db (?)      ; кол-во исправных и не исправных шлейфов
            kolheispr  db (?)
            flagat     db (?)  ; флаг ошобки при сравнивании с пустым эталонным образом 
            reg db (?) 
            error    dw (?)   ;номера не исправнвых линий, 1-неисправна 
            ww   db (?)
Data       ENDS
          
Code       SEGMENT use16
           ASSUME cs:Code,DS:Data,ss:Stk
Imge  DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07fh,05fh  

inic proc near
           mov kolispr,0
           mov kolheispr,0
           mov flagat,11111111b
           mov error,0
           lea  bx,merr
           mov  si,0
           mov  cx,10h
           xor ax,ax
i1:        mov  [bx+si],ax 
           inc si
           inc si
           loop i1   
           mov al,03fh
           out 7h,al
           out 8h,al
           out 9h,al
           out 0ah,al
           mov al,11
           mov ww,al
ret
inic endp

readkbd proc near
       
       cmp reg,00000011b
       je rm2
       cmp reg,00000111b
       je rm2
       cmp reg,0
       je rm2  
       cmp reg,00000001b
       jne r55     
       mov al,0
       out 4h,al
       out 5h,al             
r55:       
       lea bx,inm
       mov si,0
       mov dh,1
       mov cx,8h 
        mov al,0 
       out 1,al 
rm1:   mov al,dh
       out 0,al
       in  al,0h
       mov [bx+si],al            
       mov al,dh;
       inc  si
       out 0,al
       in  al,1h
       mov [bx+SI],al       
       inc si
       rol dh,1       
       loop rm1   
       mov al,0 
       out 0,al  
       mov cx,8h 
rm3:   mov al,dh
       out 1h,al
       in  al,0h
       mov [bx+si],al
       mov al,dh
       inc  si
       out 1h,al
       in  al,1h
       mov [bx+SI],al
       inc si
       shl dh,1 
       loop rm3   
rm2:      
      ret    
readkbd endp

outreadkbd proc near
           
           
           cmp reg,00000001b
           jne om2
           
           in al,2h        ;чтение кнопок
           cmp al,0
           je   om6
           lea bx,inm
         
           mov cx,0

om3:       inc cl
           shr al,1       ;вывод на индикатроы развязки
           jnc om3
           dec cl
           mov si,cx
           shl si,1
           mov al,[bx+si]
           out 2h,al
           mov al,[bx+si+1]
           out 3h,al
           jmp om2
                     ;вывод на светодиоды нижней части клав.
om6:       in al,3h        ;чтение кнопок
           cmp al,0
           je   om1
           lea bx,inm
           mov cx,0

om5:       inc cl
           shr al,1       ;вывод на индикатроы развязки
           jnc om5
           dec cl
           
           mov si,cx
           shl si,1
           mov al,[bx+si+16]
           out 2h,al
           mov al,[bx+si+17]
           out 3h,al
           jmp om2
 
om1:       mov al,0
           out 2,al
           out 3,al  

om2:       
ret
outreadkbd endp
writ proc near
     
     
     cmp reg,00000101b
     jne wm2
     lea bx,inm 
     mov cx,16
     mov si,0
wm1: mov ax,[bx+si]
     mov [bx+si+32],ax
     inc si
     inc si 
     loop wm1   
     mov flagat,0        
     mov kolispr,0       ;обнуление кол-ва испрюи неиспр. шлейфов
     mov kolheispr,0      
     mov al,03fh
     out 7h,al
     out 8h,al
     out 9h,al
     out 0ah,al
     mov al,0
     out 6h,al
wm2:     
     ret
writ endp
errorp proc near
           mov al,11111111b
           out 2,al
           out 3,al   
           mov cx,99        
em4:       inc cx
           dec cx       
           loop em4
           mov al,0
           out 2,al
           out 3,al
       ;   jmp em1

ret
errorp endp
testt proc near
    
     cmp ww,0
     je tm2   
     cmp reg,00000110b
     jne tm2
     cmp flagat,0
     je tm3
     call errorp         ;ошибка при не задании этал.шл 
     jmp tm2
tm3: lea bx,inm   
     mov cx,16
     mov si,0
tm1: mov ax,[bx+si]
     xor ax,[bx+si+32]
     mov [bx+si+64],ax 
     inc si
     inc si 
     loop tm1     
tm2:
ret
testt endp
wrerr proc near
      cmp reg,00000110b
      jne wr5
      cmp flagat,0
      jne wr5
      lea bx,merr
      mov dl,1
      mov cx,8
      mov si,0
      mov ax,0
wr1:
      push ax   
      mov ax,[bx+si]
      cmp ax,0
      pop ax 
      je wr2
      add al,dl
wr2:
      rol dl,1
      inc si
      inc si
      loop wr1           
      mov cx,8    
wr3:
      push ax   
      mov ax,[bx+si]
      cmp ax,0
      pop ax 
      je wr4
      add ah,dl
wr4:
 
     rol dl,1
     inc si
     inc si
     loop wr3   
     mov error,ax  
     out 4,al
     mov al,ah
     out 5,al 
     cmp ww,0
     je wr5    
     mov ww,0
     cmp error ,0
     jne wr6    
     
     mov al,kolispr  
     add  al,1   
     daa
     mov kolispr,al
     mov al,00000001b         ;индикатор  годнеости
     out 6h ,al
     jmp wr5    
wr6: 
     mov al,kolheispr 
     add al,1
     daa
     mov kolheispr,al
     mov al,00000010b          
     out 6h,al            ;индикатор не годнеости
wr5:            
            
ret
wrerr endp
kol proc near
        
         mov ah,0       
         mov al,dh        ;вывод чисел div 10
         push dx
         mov dh,0
         and al,0fh
         mov si,ax
         mov al,imge[si]
         out dx,al
         pop dx
         
         inc dl            ;вывод  десятков
         mov al,dh
         push dx
         mov dh,0
         shr al,4
         mov si,ax
         mov al,imge[si]
         out dx,al
         pop dx
         
ret 
kol endp

razv proc near
      cmp reg,00000010b
      jne r4
      lea bx,merr
      mov si,0
      in al,2h
      cmp al,0
      je r1
r2:   shr al,1
      inc si
      jnc r2
      dec si
      shl si,1
      mov ax,[bx+si]
      out 2h,al
      mov al,ah
      out 3h,al
      jmp r4

r1:   in al,3h
      cmp al,0
      je r5
r3:   shr al,1
      inc si
      jnc r3
      dec si
      shl si,1
      mov ax,[bx+si+10h]
      out 2h,al
      mov al,ah
      out 3h,al
      jmp r4
r5:   mov al,0
      out 2h,al
      out 3h,al  
      
r4:
ret

razv endp
regim proc near
re1:          
           in al,6h
           cmp al,0
           je re1
           cmp al,00000011b
           jne re6
           call errorp ;процедура ощшибки
           
re6:       mov reg,al
rr2:       in al,6h   
           and al,00000100b
           cmp al,0
           jne rr2 
           mov al,reg
           and al,00001000b
           cmp al,0
           je rr3
           mov ww,al
           mov al,0
           out 4h,al
           out 5h,al
rr3:                     
ret
regim endp

Start:     MOV   ax,0000h
           MOV   ds,ax
           MOV   ax,0FF00h
           MOV   ES,ax
           MOV   ax,Stk
           MOV   SS,AX
           LEA   SP,StkTop
           call  inic
start2:
           call   regim             
           call   readkbd        ;работа в режиме задания шлейфа
           call   outreadkbd     ;отображени развязки каждой линии           
           call   writ  ;запись в память матрицы эталонного шлейфа       
           call   razv     ;вывод неисправных жил каждой линии
          
           
          ; call readkbd       ;чтение матрицы клавиотуры
           call testt         ; тестирование и запись матрицы ошибок
           call wrerr         ; ВЫВОД НА ИНДИКАТОРЫ НЕИСПРАВНЫХ ЛИНИЙ          
           mov dh,kolispr
           mov dl,7h
           call kol              ;вывод на индикаторы кол-ва испр. шл
           mov dh,kolheispr
           mov dl,9h
           call kol               ;вывод на индикаторы кол-ва неиспр. шл
           jmp start2
           
           ORG   RomSize-16-((SIZE Data+15) AND 0FFF0h)    
           ASSUME cs:NOTHING
           JMP   Far Ptr Start
Code       ENDS
END

