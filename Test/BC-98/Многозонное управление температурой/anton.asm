.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096


Data       SEGMENT AT 100h use16
;Здесь размещаются описания переменных
Preobr     db    100,95,90,85,80,75
           db    70,65,60,55,50,55,50
Preobr1    db    0,5,10,15,20,25
           db    30,35,40,45,50,55,60
  arr db 12 dup(?)     
  arrpred1 db 3 dup (?)
  arrpred2 db 3 dup (?)
  image1 db 16 dup(?)
  ind dw 4 dup(?)
  ind1 dw 2 dup(?)
  ind2 dw 2 dup(?)
  kol_sim dw ?
  maxzn  db ?
  minzn  db ?
  maska  db ?
  av_st  db ?
  maska1  db ?
  zonainput db 8 dup(?)
  zonainput1 db 8 dup(?)
  flag_n db ?
  flag_t db ?
  flag_a db ?
  flag_pr db ?
  flag_reg db ?
  flag_kbd db ?
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 3000h use16
;Задайте необходимый размер стека
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант
InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data,es:Data
;Image     db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh
Image      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           db    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h

preobr_t   proc
           xor si,si           
           mov dl,75
       pr0:mov al,preobr[si]
           cmp al,dl
           jnz pr1
           mov ah,preobr1[si]
       pr1:inc si
           cmp si,14
           jnz pr0    
           ret
preobr_t   endp

;Установка режимов
reg_in     proc
           in al,09h
           cmp al,040h
           jnz c0
           mov flag_reg,0FFh
           mov al,00000001b
           mov maska,al
           out 0Dh,al
       c0: in al,09h
           cmp al,080h
           jnz c1
           mov flag_reg,00h
           mov al,00000010b
           out 0Dh,al
           mov maska,al
        c1:                 
           ret
reg_in     endp

;Ввод с клавиатуры
obrkl      proc
;           cmp flag_reg,0FFh
;           jnz out4
;           mov al,1
;           mov si,0
;           mov cl,3
;       m4: mov ch,4
;           mov dl,al
;           out 0Eh,al
;           in  al,08h
;           shl al,4
;       m3: shl al,1
;           jnc m1
;           cmp si,9
;           ja m2
;           mov arr[si],0ffh
;           mov flag_n,0FFh
;           mov bx,kol_sim
;           mov ind[bx],si
;           add bx,2
;           cmp bx,8
;           jne g1
;           mov bx,0
;        g1:mov kol_sim,bx
;           jmp m2
;       m1: mov arr[si],0
;       m2: inc si
;           dec ch
;           jnz m3
;           mov al,dl
;           shl al,1
;           dec cl
;           jnz m4
;      out4: ret
obrkl      endp
obrkl1     proc
           cmp flag_reg,0FFh
           jnz out5
           mov al,1
           mov si,0
           mov cl,3
       m4: mov ch,4
           mov dl,al
           out 0Eh,al
           in  al,08h
           shl al,4
       m3: shl al,1
           jnc m1
           cmp si,9
           ja m2
           mov arr[si],0ffh
           mov flag_n,0FFh
           mov bx,kol_sim
           cmp flag_pr,0FFh
           jnz wr1
           mov ind1[bx],si
       wr1:    
           cmp flag_pr,00h
           jnz wr2
           mov ind2[bx],si
       wr2:    
           add bx,2
           cmp bx,4
           jne g1
           mov bx,0
        g1:mov kol_sim,bx
           jmp m2
       m1: mov arr[si],0
       m2: inc si
           dec ch
           jnz m3
           mov al,dl
           shl al,1
           dec cl
           jnz m4
      out5:ret
obrkl1     endp

predel     proc
           cmp flag_reg,0FFh
           jnz ex2
           in al,09h
           cmp al,010h
           jnz ex1
           mov flag_pr,0FFh
           mov al,00000001b
           out 0Fh,al
       ex1: 
           cmp al,020h
           jnz ex2
           mov flag_pr,00h
           mov al,00000010b
           out 0Fh,al
       ex2:    
           ret
predel     endp
;Преобразование очередной цифры и вывод её на экран
outInd     proc
           cmp flag_reg,0FFh
           jnz out1
           cmp flag_pr,0FFh
           jnz sa1
           mov dx,09h
      sa1: cmp flag_pr,00h    
           jnz sa2
           mov dx,0Bh
      sa2:     
           xor si,si
       g3: cmp flag_pr,0FFh
           jnz ds1
           mov bx,ind1[si]
       ds1:cmp flag_pr,00h
           jnz ds2
           mov bx,ind2[si]
       ds2:        
           mov al,cs:image[bx]
           out dx,al
           inc dx
           add si,2
           cmp si,4
           jne g3
      out1:     
           ret
outInd     endp

;Запись пределов из массива, полученного 
;при вводе с клавиатуры, в ячейки памяти maxzn и minzn
polznach   proc
           xor si,si
           mov ax,ind1[si+2]
           mov bx,ind1[si]
           mov dl,10
           mul dl
           add al,bl
           mov minzn,al
           mov ax,ind2[si+2]
           mov bx,ind2[si]
           mul dl
           add al,bl
           mov maxzn,al
           ret   
polznach   endp

;Процедура ввода значений с термодатчиков
input     proc
           mov cl,9
           xor ch,ch
        d3:mov al,ch
           out 0,al
           inc ch
           cmp ch,cl
           jne d3
           mov dx,0   
WaitRdy:
           in    al,1
           test  al,1
           jz    WaitRdy
            
           xor   si,si
       g5: in    al,dx
           mov   ah,al
           and   al,0Fh
           mov   zonainput[si],al
           inc   si
           mov   al,ah
           shr   al,4
           mov   zonainput[si],al
           inc   si  
           add   dx,2
           cmp   si,8
           jne   g5
           ret

input     endp

;Преобразование данных с термодатчиков к десятичному виду
preobr_10 proc
           mov si,0
       p0: mov al,zonainput[si]
           shl al,4
           mov ah,zonainput[si+1]
           shr ax,4
           xor ah,ah
           mov bl,4
           div bl
           xor ah,ah
           shl ax,4
           cmp ah,0Ah
           js p
           add ah,6
        p:   
           mov cl,0
       p3: shl ax,1
           mov dh,ah
           and dh,0Fh
           cmp dh,0Ah
           js p1
           add ah,6
           jmp p2
       p1: mov dl,ah
           and dl,00010000b
           cmp dl,00010000b
           jnz p2
           add ah,6
       p2: inc cl
           cmp cl,4
           jnz p3
           shr ax,4
           shr al,4
           mov zonainput[si],al                   
           mov zonainput[si+1],ah                   
           mov zonainput1[si],al
           mov zonainput1[si+1],ah
           add si,2
           cmp si,8
           jnz p0
           
           
           ret
preobr_10 endp
vibrdestr  proc
       vd1:mov ah,al
           mov bh,0
           mov bl,0
           mov dx,08h
           mov cl,0
       vd2:in al,dx
           cmp ah,al
           jne vd1
           inc bh
           cmp bh,255
           jne vd2
           inc bl
           cmp bl,100
           jne vd2
           mov al,ah
           ret
vibrdestr  endp


;Вывод данных на индикаторы
output     proc
           lea bx,Image1
           xor si,si
           mov dx,01h
       g6: mov al,zonainput[si]
           xlat
           out dx,al
           inc dx
           inc si
           cmp si,8
           jne g6
           ret
output     endp


;Терморегуляция
termo      proc
           mov flag_t,00h
;           xor dh,dh
;           mov maska,dh
           cmp flag_reg,0FFh
           jnz t00
           jmp out2
      t00:     
           mov cl,0
       t0: 
           mov ch,0
           mov al,minzn
           cmp cl,1
           jnz t
           mov al,maxzn
        t: shl ax,4
           mov dl,ah
           and dl,0Fh
           cmp dl,0Ah
           js t1
           add ah,6
       t1: shl ax,1
           mov dl,ah
           and dl,0Fh
           cmp dl,0Ah
           js t5
           add ah,6
           jmp t2
       t5: mov dl,ah
           and dl,00010000b
           cmp dl,00010000b
           jnz t2
           add ah,6
       t2: inc ch
           cmp ch,4
           jnz t1
           cmp cl,0
           jnz t3
           mov minzn,ah
       t3: cmp cl,1
           jnz t4
           mov maxzn,ah            
       t4: inc cl
           cmp cl,2
           jnz t0    
           xor si,si
       t6: mov al,zonainput[0]
           mov ah,zonainput[1]
           shl al,4
           shr ax,4
           cmp al,minzn
           jns t7
           mov flag_t,0FFh
           mov al,maska1
           or al,00000001b
           mov maska1,al
           out 010h,al

       t7: mov al,zonainput[0]
           mov ah,zonainput[1]
           shl al,4
           shr ax,4
           cmp al,maxzn
           jbe t8
           mov flag_t,0FFh
           mov al,maska1
           or al,00000010b
           mov maska1,al
           out 010h,al
       t8: 
           mov al,zonainput[0]
           mov ah,zonainput[1]
           shl al,4
           shr ax,4
           cmp al,minzn
           js t9
           cmp al,maxzn
           ja t9
           mov al,maska1
           and al,11111100b
           mov maska1,al
           out 010h,al
       
       t9: 
           mov al,zonainput[2]
           mov ah,zonainput[3]
           shl al,4
           shr ax,4
           cmp al,minzn
           jns t9_
           mov flag_t,0FFh
           mov al,maska1
           or al,00000100b
           mov maska1,al
           out 010h,al

      t9_: mov al,zonainput[2]
           mov ah,zonainput[3]
           shl al,4
           shr ax,4
           cmp al,maxzn
           jbe t10
           mov flag_t,0FFh
           mov al,maska1
           or al,00001000b
           mov maska1,al
           out 010h,al
       t10: 
           mov al,zonainput[2]
           mov ah,zonainput[3]
           shl al,4
           shr ax,4
           cmp al,minzn
           js t11
           cmp al,maxzn
           ja t11
           mov al,maska1
           and al,11110011b
           mov maska1,al
           out 010h,al
       t11:
           mov al,zonainput[4]
           mov ah,zonainput[5]
           shl al,4
           shr ax,4
           cmp al,minzn
           jns t12
           mov flag_t,0FFh
           mov al,maska1
           or al,00010000b
           mov maska1,al
           out 010h,al

      t12: mov al,zonainput[4]
           mov ah,zonainput[5]
           shl al,4
           shr ax,4
           cmp al,maxzn
           jbe t13
           mov flag_t,0FFh
           mov al,maska1
           or al,00100000b
           mov maska1,al
           out 010h,al
       t13: 
           mov al,zonainput[4]
           mov ah,zonainput[5]
           shl al,4
           shr ax,4
           cmp al,minzn
           js t14
           cmp al,maxzn
           ja t14
           mov al,maska1
           and al,11001111b
           mov maska1,al
           out 010h,al
       t14:
           mov al,zonainput[6]
           mov ah,zonainput[7]
           shl al,4
           shr ax,4
           cmp al,minzn
           jns t15
           mov flag_t,0FFh
           mov al,maska1
           or al,01000000b
           mov maska1,al
           out 010h,al

      t15: mov al,zonainput[6]
           mov ah,zonainput[7]
           shl al,4
           shr ax,4
           cmp al,maxzn
           jbe t16
           mov flag_t,0FFh
           mov al,maska1
           or al,10000000b
           mov maska1,al
           out 010h,al
       t16: 
           mov al,zonainput[6]
           mov ah,zonainput[7]
           shl al,4
           shr ax,4
           cmp al,minzn
           js t17
           cmp al,maxzn
           ja t17
           mov al,maska1
           and al,00111111b
           mov maska1,al
           out 010h,al
;           mov flag_t,00h
       t17:
;       add si,2
;           cmp si,8
;           jnz t6
     out2:  ret
termo      endp


;Вывод сообщения об ошибке ввода с клавиатуры
err_kbd    proc
           mov al,maxzn
           cmp al,minzn
           jns a1
           mov al,maska
           or al,00010001b
           mov maska,al
           out 0Dh,al   
       a1: 
           mov al,maxzn
           cmp al,minzn
           js a2
           cmp flag_reg,0FFh
           jnz a2
           mov flag_kbd,0FFh
           mov al,maska
           or al,01h
           mov maska,al
           out 0Dh,al
       a2:
           ret
err_kbd     endp


;Вывод сообщения о возникновении аварийной ситуации
avaria     proc
           mov flag_a,0
           xor si,si
           mov flag_a,00h
      av0: mov al,zonainput[si]
           mov ah,zonainput[si+1]
           shl al,4
           shr ax,4
           cmp flag_t,0FFh
           jnz lbl1
           inc av_st
           cmp av_st,50h
           jnz lbl1
           xor al,al
           mov av_st,al
           mov flag_a,0FFh
           mov al,maska
           or al,00100000b
           out 0Dh,al
;           mov maska,al
      lbl1:cmp flag_t,00h
           jnz lbl2
           mov flag_a,00h
           mov al,maska
;           and al,11011111b
           out 0Dh,al
;           mov maska,al
           
      lbl2:add si,2
           cmp si,8
           jnz av0     
           ret
avaria     endp


init       proc
           xor al,al
           mov av_st,al
           mov ax,0
           mov maska,0h
           mov maska1,0h
           mov flag_pr,0FFh
;           mov al,00000010b
;           out 0Fh,al
           mov Kol_sim,ax
           xor si,si
           
           lea bx,cs:Image
           mov si,16
       d6: dec si
           mov cl,cs:[bx+si]
           mov Image1[si],cl
           cmp si,0
           jne d6 
           
           xor si,si 
       g2: mov ind1[si],0
           add si,2 
           cmp si,4
           jne g2
           mov al,image1[0]
           out 09h,al
           out 0Ah,al
           out 0Bh,al
           mov al,image1[5]
           out 0Ch,al
           
           xor ax,ax
           mov al,5
           mov ind2[2],ax
           mov ax,0
           mov ind2[0],ax
           
           xor al,al
           mov maxzn,al
           mov minzn,al
           
           mov dx,01h
       g7: mov al,image1[0]
           out dx,al
           inc dx
           cmp dx,9
           jne g7
           
           mov flag_reg,0FFh
           mov al,01h
           out 0Dh,al
           ret
init       endp
Start:
           mov   ax,Data
;           mov   ax,Code
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           call preobr_t
           call init 
           
Здесь размещается код программы
        n:  
           call reg_in 
           call predel
           call obrkl1
           call vibrdestr
           call outInd
           call polznach
           call input
           call preobr_10
           call termo
           call output 
           call err_kbd          
           call avaria 
;           call predel
           jmp n
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
