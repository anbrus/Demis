;.386
RomSize    EQU   4096
NMax       EQU   50          ; константа подавления дребезга
KbdPort    EQU   4           ; адреса портов


;--------------Сегмент данных-------------------------------------------------------

Data       SEGMENT AT 1000h 
;Здесь размещаются описания переменных
   
    up                Dw 4 dup(?)       ;  верхний порт
    down              Dw 4 dup(?)       ; нижний порт
    left              Dw 4 dup(?)       ; левый порт
    kol               Db 4 dup(?)       ; счетчик
    wr                dw ?             
    F_klaw            db ?
    F_Start           db ?
    kom               db ?                ;флаг  выбора индикатора
    Mas_Kom1          db 6 dup(?)        ; МАССИВЫ ДЛЯ ХРАНЕНИЯ НОМЕРА БУКВЫ
    Mas_Kom2          db 6 dup(?)  
    Mas_FAM1          db 6 dup(?)  
    Mas_FAM2          db 6 dup(?)  
    clock             db 2 dup(?)        ;массив времени 
    shet1             db ?
    shet2             db ?
    F_S               db ?                ;чтобы не выводить в самом начале нули
    F_zap             db ?                ;флаг вкл.-выкл.  
    sw                db ?                ;для лампочек
   
Data       ENDS
    ;---------------Сегмент кода---------------------------------------------------------
Code       SEGMENT
           ASSUME cs:Code,ds:Data
;------------------------------------------------------------------------------------
Image      db    00000000b,11111100b,00100010b,00100001b,00100001b,00100010b,11111100b,00000000b  
           db    00000000b,11111111b,10001001b,10001001b,10001001b,10001001b,11110000b,00000000b                  
           db    00000000b,11111111b,10001001b,10001001b,10001001b,10001001b,01110110b,00000000b  
           db    00000000b,11111111b,00000001b,00000001b,00000001b,00000001b,00000011b,00000000b 
           db    00000000b,11000000b,01111100b,01000010b,01000001b,01111111b,11000000b,00000000b  
           db    00000000b,11111111b,10001001b,10001001b,10001001b,10001001b,10001001b,00000000b  
           db    00000000b,11111111b,00010000b,11111111b,00010000b,11111111b,00000000b,00000000b  
           db    00000000b,01000010b,10000001b,10000001b,10001001b,10001001b,01110110b,00000000b  
           db    00000000b,11111111b,01000000b,00100000b,00010000b,00001000b,11111111b,00000000b   
           db    00000000b,11111111b,00001000b,00001000b,00010100b,00100010b,11000001b,00000000b  
           db    00000000b,11111100b,00000010b,00000001b,00000001b,00000010b,11111100b,00000000b  
           db    00000000b,11111111b,00000010b,00000100b,00000100b,00000010b,11111111b,00000000b  
           db    00000000b,11111111b,00001000b,00001000b,00001000b,00001000b,11111111b,00000000b  
           db    00000000b,01111110b,10000001b,10000001b,10000001b,10000001b,01111110b,00000000b  
           db    00000000b,11111111b,00000001b,00000001b,00000001b,00000001b,11111111b,00000000b  
           db    00000000b,11111111b,00010001b,00010001b,00010001b,00010001b,00001110b,00000000b 
           db    00000000b,01111110b,10000001b,10000001b,10000001b,10000001b,01000010b,00000000b  
           db    00000000b,00000001b,00000001b,11111111b,00000001b,00000001b,00000000b,00000000b  
           db    00000000b,10001111b,10001000b,10001000b,10001000b,10001000b,11111111b,00000000b  
           db    00000000b,00001111b,00001001b,11111111b,00001001b,00001111b,00000000b,00000000b  
           db    00000000b,11100011b,00010100b,00001000b,00001000b,00010100b,11100011b,00000000b  
           db    00000000b,01111111b,01000000b,01000000b,01000000b,01111111b,10000000b,00000000b  
           db    00000000b,00001111b,00001000b,00001000b,00001000b,00001000b,11111111b,00000000b  
           db    00000000b,11111111b,10000000b,11111111b,10000000b,11111111b,00000000b,00000000b  
           db    00000000b,11111111b,10000000b,11111111b,10000000b,11111111b,10000000b,00000000b  
           db    00000000b,00000001b,11111111b,10001000b,10001000b,10001000b,01110000b,00000000b  
           db    00000000b,11111111b,10001000b,10001000b,10001000b,01110000b,11111111b,00000000b  
           db    00000000b,11111111b,10001000b,10001000b,10001000b,01110000b,00000000b,00000000b  
           db    00000000b,10000001b,10000001b,10000001b,10001001b,10001001b,01111110b,00000000b  
           db    00000000b,11111111b,00001000b,01111110b,10000001b,10000001b,01111110b,00000000b 
           db    00000000b,11000110b,00101001b,00011001b,00001001b,00001001b,11111111b,00000000b  
           
   Image2  db    00000000b,01111110b,10000001b,10000001b,10000001b,10000001b,01111110b,00000000b  
           db    00000000b,00000000b,00000000b,10000010b,11111111b,10000000b,00000000b,00000000b 
           db    00000000b,10000010b,11000001b,10100001b,10010001b,10011110b,00000000b,00000000b  
           db    00000000b,01100010b,10000001b,10001001b,10001001b,01111110b,00000000b,00000000b  
           db    00000000b,00011100b,00010010b,00010001b,11111111b,00010000b,00000000b,00000000b  
           db    00000000b,10001111b,10001001b,10001001b,10001001b,01110001b,00000000b,00000000b  
           db    00000000b,01111100b,10001010b,10001001b,10001001b,01110000b,00000000b,00000000b  
           db    00000000b,10000001b,01000001b,00100001b,00010001b,00001111b,00000000b,00000000b  
           db    00000000b,01110110b,10001001b,10001001b,10001001b,01110110b,00000000b,00000000b  
           db    00000000b,00001110b,10010001b,01010001b,00110001b,00011110b,00000000b,00000000b  
    Im     db    03Fh ,00Ch ,076h ,05Eh,04Dh,05Bh,07Bh ,00Eh,07Fh,05Fh    
           
           ASSUME cs:Code,ds:code,es:data

 ;Здесь размещается код программы

 init  Proc  
          mov kom,1
          mov kol[0],0
          mov kol[1],0
          mov kol[2],0
          mov kol[3],0
          mov clock[0],0
          mov clock[1],0
          mov wr,0
          mov shet1,0
          mov shet2,0
          mov f_s,0
          mov F_zap,0
          mov sw,0
      
          mov F_Start,0
          mov  F_klaw,0
          lea bx, Mas_Kom1 
          mov cx,6
       e_1: mov ax,[bx]
            xor ax,ax
            mov [bx],ax
            add bx,2
            loop e_1  
           
           lea bx, Mas_Kom2 
          mov cx,6
       e_2: mov ax,[bx]
            xor ax,ax
            mov [bx],ax
            add bx,2
            loop e_2     
            
              lea bx, Mas_fam2 
          mov cx,6
       e_3: mov ax,[bx]
            xor ax,ax
            mov [bx],ax
            add bx,2
            loop e_3     
         
             lea bx, Mas_fam1 
          mov cx,6
       e_4: mov ax,[bx]
            xor ax,ax
            mov [bx],ax
            add bx,2
            loop e_4     
            ret 
              
 init  ENDP 

       
 Wwodklaw proc        ;ввод с клавиатуры
          
          mov ch,0
          mov cl,1
       t2:mov al,cl
          out 90h,al
          in al,90h       
          cmp al,0
          jne t6            ;если нет уходим кл.нажата           
          
          cmp cl,0      
          je  t4   
          shl cl,1       
          jmp t2
     t6:  push ax
     t5:  in al,90h
          or al,al
          jnz t5
          pop ax
     t1: ; mov F_klaw,0ffh      ;флаг нажатой клавы
          inc ch
          shr al,1          ;клава нажата, узнаем номер столбца
          cmp al,0
          jne t1   
          mov dh,ch 
          mov ch,0
      t3: inc ch            ;обработка строки
          shr cl,1
          cmp cl,0
          jne t3
          dec ch
          mov dl,ch         ;в dl-номер строки, в dh-номер столбца
          mov al,dl
          mov dl,8
          mul dl
          xor bx,bx
          mov bl,dh
          add ax,bx      ; ax-смещение буквы   
          cmp f_zap,0
          je t4
          CMP F_S,0
          jne t20        
                                  
          cmp kom,2      ;проверка выбранной команды
          jne t8
          call komanda_2
          jmp wwodklaw_ret
     t8:  CALL KOMANDA_1
          jmp wwodklaw_ret
          
     t20: cmp kom,1
          jne t21
          call FAMIL_1
          jmp wwodklaw_ret
     t21: call FAMIL_2     
     t4:  wwodklaw_ret:ret      
 wwodklaw ENDP  
 
 KOMANDA_1 PROC NEAR       
          cmp ax,32       ;проверка <---
          jne t9
          cmp kol[0],0      
          je t40
          dec kol[0]       
          jmp t40
     t9:  cmp kol[0],6h
          je t40
          xor si,si
          xor dh,dh
          mov dl, kol[0]
          mov si,dx
          mov Mas_kom1[si],al
          inc kol[0]   
      T40:RET
  KOMANDA_1 ENDP          
 
  KOMANDA_2 PROC NEAR           
          cmp ax,32       ;проверка <---
          jne t7
       
          cmp kol[1],0      
          je tt4
          dec kol[1]
          jmp tt4      
     t7:  cmp kol[1],6h
          je tt4
          xor si,si
          xor dh,dh
          mov dl, kol[1]
          mov si,dx
          mov Mas_kom2[si],al
          inc kol[1]   
          TT4:ret
  KOMANDA_2 ENDP    
  
  FAMIL_1 PROC NEAR
          cmp ax,32       ;проверка <---
          jne t23
         
          cmp kol[2],0      
          je t24
           dec kol[2]
          jmp t24      
     t23: cmp kol[2],6h
          je t24
          xor si,si
          xor dh,dh
          mov dl, kol[2]
          mov si,dx
          mov Mas_FAM1[si],al
          inc kol[2]   
          T24:ret
  FAMIL_1 ENDP
  
  FAMIL_2 PROC NEAR
          cmp ax,32    ;проверка <---
          jne t26
       
          cmp kol[3],0      
          je t25
            dec kol[3]
          jmp t25      
     t26: cmp kol[3],6h
          je t25
          xor si,si
          xor dh,dh
          mov dl,kol[3]
          mov si,dx
          mov Mas_FAM2[si],al
          inc kol[3]   
          T25:ret
  FAMIL_2 ENDP
        
            
 Dreb Proc                    ;устранение дребезга
 VD1:      mov   ah,al       ;Сохранение исходного состояния
           mov   bh,0        ;Сброс счётчика повторений
 VD2:      in    al,dx       ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   bh          ;Инкремент счётчика повторений
           cmp   bh,NMax     ;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных
           ret
 Dreb  ENDP
        
 WIbor proc                   ;процедура выбора  
           cmp f_zap,0
           je wibor_ret
           cmp kom,1
           je j4
           mov kom,1
           jmp wibor_ret
       j4: mov kom,2  
  wibor_ret:ret  
wibor endp        
              
WWod_Kom proc                      ;вывод названия команд
          mov di,0    ;счетчик     
          mov up[di],1
          mov left[di],31h
          mov down[di],61h   
          mov si,0         
          mov cl,kol[di]            
          xor ch,ch         
          cmp kol[0],0
          je f12         
    l_2:  push cx
          xor ax,ax
          lea bx,image
          cmp di,0
          je l_3
          mov al,  Mas_kom2[si]
          jmp l_4
  l_3:    mov al,  Mas_kom1[si]
  l_4:    dec al
          mov dx,8
          mul dx
          add bx,ax       
          mov cl,1 
          mov al,1
          mov dx,up[di]            
          out dx,al
          mov ch,7
   l_1:   mov al,[bx]
          mov dx,left[di]
          out dx,al; 
          mov al,0  
          out dx,al
          shl cl,1
          mov al,cl
          mov dx,down[di]
          out dx,al
          inc bx
          dec ch
          cmp ch,0
          jnz l_1
          inc up[di]
          inc left[di]
          inc down[di]
          inc si
          pop cx
          loop l_2
          jmp f12
     f11: jmp f1     
      f12:inc di
          cmp di,1
          jne f1
          mov up[di],11h
          mov left[di],41h
          mov down[di],71h
          mov si,0
          cmp kol[di],0
          je f1
          mov cl,kol[di] 
          xor ch,ch 
          jmp l_2                 
   f1:    ret  
  WWod_Kom endp  
  
 WWod_fam proc                      ;вывод фамилий
          mov di,2    ;счетчик     
          mov up[di],21h
          mov left[di],51h
          mov down[di],81h   
          mov si,0
          xor cx,cx
          mov cl,kol[di]  
          cmp kol[di],0
          je ff12         
ll_2:     push cx  
          xor ax,ax
          lea bx,image
          cmp di,2
          je ll_3
          mov al,  Mas_fam2[si]
          jmp ll_4
ll_3:     mov al,  Mas_fam1[si]
ll_4:     dec al
          mov dx,8
          mul dx
          add bx,ax       
          mov cl,1 
          mov al,1
          mov dx,up[di]            
          out dx,al         
          mov ch,7
ll_1:     mov al,[bx]
          mov dx,left[di]
          out dx,al; 
          mov al,0  
          out dx,al
          shl cl,1
          mov al,cl
          mov dx,down[di]
          out dx,al
          inc bx
          dec ch
          cmp ch,0
          jnz ll_1          
          inc up[di]
          inc left[di]
          inc down[di]
          inc si
          pop cx
          loop ll_2
          jmp ff12         
ff11:     jmp ff1          
ff12:     inc di
          cmp di,3
          jne ff1
          mov up[di],17h
          mov left[di],27h
          mov down[di],91h
          mov si,0
          cmp kol[di],0
          je ff1
          mov cl,kol[di] 
          xor ch,ch 
          jmp ll_2                            
ff1:      ret  
 WWod_fam endp  
            
 Prov proc     ;  вывод счета
              cmp f_zap,0
             je x3
             cmp F_S,0
             je x3
             lea bx,image2
             mov dl,1             
             xor ah,ah
             mov al,shet1
             mov dh,8
             mul dh
             add bx,ax             
             mov cx,7
      pp1:   mov al,1
             out 0Ah,al
             mov al,dl
             out 0ch,al             
             mov al,[bx]
             out 0bh,al
             mov al,0
             out 0bh,al
             shl dl,1
             inc bx
             loop pp1
             lea bx,image2
             mov dl,1             
             xor ah,ah
             mov al,shet2
             mov dh,8
             mul dh
             add bx,ax             
             mov cx,7
      pp2:   mov al,1
             out 0A1h,al
             mov al,dl
             out 0c1h,al             
             mov al,[bx]
             out 0b1h,al
             mov al,0
             out 0b1h,al
             shl dl,1
             inc bx
             loop pp2            
          x3:ret      
  Prov endp
  
  SCHET PROC NEAR
             cmp f_zap,0
             je  schet_ret
             cmp f_start,0
             je schet_ret
             cmp kom,1
             jne ss1                         
             cmp shet1,9
             je schet_ret
             mov al,shet1      
             add al,1
             mov shet1,al
             mov kol[2],0
             jmp schet_ret           
  ss1:       cmp kom,2
             jne schet_ret
             cmp shet2,9
             je schet_ret
             inc shet2
             mov kol[3],0
  schet_ret: ret                          
             
  SCHET ENDP
  
  
  OPROS PROC NEAR
             in al,91h
             cmp al,0
             je opros_ret
             push ax
op2:         in al,91h
             or al,al
             jnz op2
             pop ax  
             cmp al,2            
             jne op1
             call Schet
             jmp opros_ret
op1:         cmp al,4
             jne op3
             cmp f_zap,0
             je opros_ret
             mov f_start,0ffh    
             mov f_s,0ffh  
             jmp opros_ret
op3:         cmp al,08h
             jne op6
             call wibor
             jmp opros_ret
op6:         cmp al,10h
             jne opros_ret
             cmp F_zap,0ffh
             je op4
             mov F_zap,0ffh
             jmp opros_ret
op4:         call Init        
opros_ret:  ret         
  OPROS ENDP
           
Svet proc
             cmp f_zap,0
             je  s12
             cmp kom,1
             jne s89
             mov al,5h                                                                                                                                                                      
             out 0fh,al
             jmp s11
         s89:mov al,6h
             out 0fh,al 
             jmp s11   
         s12: mov al,0
              out 0fh,al 
          s11:  ret       
Svet endp           
      
  Wrem proc  ;процедура подсчета времени       
            cmp f_zap,0
            je  b1
            cmp F_start,0ffh
            jne b1
            inc wr
            cmp wr, 010h
            jne b1
            mov wr,0
            mov al,clock[0]
            add al,1
            daa
            mov clock[0],al
            cmp clock[0],1100000b 
            jne b1
            mov clock[0],0
            mov al,clock[1]
            add al,1
            daa
            mov clock[1],al
            cmp clock[1],1000101b
            jne b2
            mov f_start,0
       b2:  cmp clock[1],10010000b
            jnz b1
            mov f_start,0                           
       b1:  ret
 Wrem endp   
           
Clock_out proc near
            cmp f_zap,0
            je  s
            lea bx,im
            mov al,clock[0]
            mov ah,al
            and al,0fh
            xlat
            out 0d1h,al      ;вывод секунд
            shr ah,4
            mov al,ah
            xlat
            out 0d2h,al    ;вывод десятых секунд
            mov al,clock[1]
            mov ah,al
            and al,0fh
            xlat
            out 0d3h,al      ;вывод минут
            shr ah,4
            mov al,ah
            xlat
            out 0d4h,al    ;вывод десятых минут
            jmp s123
       s:   mov al,0
            out 0d1h,al
            out 0d2h,al
            out 0d3h,al
            out 0d4h,al
       s123:     ret           
clock_out endp  
      
        
   
;В следующей строке необходимо указать смещение стартовой точки
        Start:
           mov   ax,Code
           mov   ds,ax
           mov   ax,data
           mov   es,ax
           call init
     begin:
           call Prov        
           call wwodklaw 
           call opros
           call WWod_Kom
           call WWod_fam
           call Svet
           call Wrem
           call clock_out
      jmp begin
           
 org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
