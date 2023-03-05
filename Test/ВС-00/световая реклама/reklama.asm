;.386
RomSize    EQU   4096
NMax       EQU   50          ; константа подавления дребезга
KbdPort    EQU   4           ; адреса портов


;--------------Сегмент данных-------------------------------------------------------

Data       SEGMENT AT 1000h 
;Здесь размещаются описания переменных
           klav           db ?                    ;номер нажатой кнопки
           kol            db 4 dup(?)             ;количество нажатых букв
           mas_bukva1     db  17 dup(?)           ;массив нажатых букв
           mas_bukva2     db  17 dup(?)           ;массив нажатых букв
           mas_bukva3     db  17 dup(?)           ;массив нажатых букв
           F_klav         db ?                    ;флаг нажатой клавы (в первый раз)
           f_vvod         db ?                    ;флаг нажатой кнопки "Ввод"   
           f_zapic        db ?                    ;флаг нажатой кнопки "Запись"
           f_prioritet    db ?                    ;флаг нажатой кнопки "Приоритет"
           f_pram         db ?                    ;флаг нажатой кнопки "Прямая форма"
           f_konez        db ?                    ;флаг конца собщения
           buffer         db  10 dup(10 dup (?))  ;буфер вывода
           nomer_vivod    db ?
           prior_vivod    db ?
           diod           db ?
           f_k            db ?                    ;флаг нажатой клавы
           nomer          db ?                    ;номер сообщения
           up             dw ?                    ;верхний порт
           left           dw ?                    ;левый порт
           down           dw ?                    ;нижний порт
           f_start        db ?                    ;флаг нажатой кнопки "Пуск" 
           prior          db 4 dup(?)             ;массив приоритетов
           n              db ?                    ;номер текущего выводимого символа
           sdvigi         db ?                    ;количество сдвигов
           
           
Data       ENDS
    ;---------------Сегмент кода---------------------------------------------------------
Code       SEGMENT
           ASSUME cs:Code,ds:Data
;------------------------------------------------------------------------------------
Image      db    00000000b,00011000b,00100100b,01000010b,01111110b,01000010b,01000010b,00000000b  ;"А"0
           db    00000000b,01111110b,00000010b,01111110b,01000010b,01000010b,01111110b,00000000b  ;"Б"1                 
           db    00000000b,00011110b,00100010b,00111110b,01000010b,01000010b,00111110b,00000000b  ;"В"2
           db    00000000b,01111110b,01000010b,00000010b,00000010b,00000010b,00000010b,00000000b  ;"Г"3
           db    00000000b,00011000b,00100100b,00100100b,00100100b,00100100b,01111110b,01000010b  ;"Д"4
           db    00000000b,01111110b,00000010b,00011110b,00000010b,00000010b,01111110b,00000000b  ;"Е"5
           db    00000000b,01011010b,00111100b,00011000b,00011000b,00111100b,01011010b,00000000b  ;"Ж"6
           db    00000000b,00111100b,01000000b,00111000b,01000000b,01000010b,00111100b,00000000b  ;"З"7
           db    00000000b,01000010b,01100010b,01010010b,01001010b,01000110b,01000010b,00000000b  ;"И"8
           db    00000000b,00100010b,00010010b,00001110b,00010010b,00100010b,01000010b,00000000b  ;"K"9
           db    00000000b,00011000b,00100100b,01000010b,01000010b,01000010b,01000010b,00000000b  ;"Л"10
           db    00000000b,01000010b,01100110b,01011010b,01000010b,01000010b,01000010b,00000000b  ;"М"11
           db    00000000b,01000010b,01000010b,01111110b,01000010b,01000010b,01000010b,00000000b  ;"Н"12
           db    00000000b,00111100b,01000010b,01000010b,01000010b,01000010b,00111100b,00000000b  ;"О"13
           db    00000000b,01111110b,01000010b,01000010b,01000010b,01000010b,01000010b,00000000b  ;"П"14
           db    00000000b,00111110b,01000010b,01000010b,00111110b,00000010b,00000010b,00000000b  ;"Р"15
           db    00000000b,00111100b,01000010b,00000010b,00000010b,01000010b,00111100b,00000000b  ;"С"16
           db    00000000b,01111110b,00011000b,00011000b,00011000b,00011000b,00011000b,00000000b  ;"Т"17
           db    00000000b,01000010b,01000010b,01000010b,01111100b,01000000b,00111110b,00000000b  ;"У"18
           db    00000000b,00111100b,01011010b,01011010b,01011010b,00111100b,00011000b,00000000b  ;"Ф"19
           db    00000000b,01000010b,00100100b,00011000b,00011000b,00100100b,01000010b,00000000b  ;"Х"20
           db    00000000b,00100010b,00100010b,00100010b,00100010b,00100010b,01111110b,01000000b  ;"Ц"21
           db    00000000b,01000010b,01000010b,01000010b,01111100b,01000000b,01000000b,00000000b  ;"Ч"22
           db    00000000b,01011010b,01011010b,01011010b,01011010b,01011010b,01111110b,00000000b  ;"Ш"23
           db    00000000b,00101010b,00101010b,00101010b,00101010b,00101010b,01111110b,01000000b  ;"Щ"24
           db    00000000b,00001110b,00001010b,00111000b,01000100b,01000100b,00111100b,00000000b  ;"Ъ"25
           db    00000000b,01000010b,01000010b,01001110b,01010010b,01010010b,01001110b,00000000b  ;"Ы"26
           db    00000000b,00000010b,00000010b,00111110b,01000010b,01000010b,00111110b,00000000b  ;"Ь"27
           db    00000000b,00111100b,01000010b,01111000b,01111000b,01000010b,00111100b,00000000b  ;"Э"28
           db    00000000b,00110010b,01001010b,01001110b,01001110b,01001010b,00110010b,00000000b  ;"Ю"29
           db    00000000b,01111000b,01000100b,01000100b,01111000b,01000100b,01000010b,00000000b  ;"Я"30
           db    00000000b,00010000b,00011000b,00010100b,00010000b,00010000b,00010000b,00000000b  ;"1"31
           db    00000000b,00011000b,00100100b,00100000b,00010000b,00001000b,00111100b,00000000b  ;"2"32
           db    00000000b,00111100b,00100000b,00011000b,00100000b,00100100b,00011000b,00000000b  ;"3"33
           db    00000000b,00100100b,00100100b,00100100b,00111100b,00100000b,00100000b,00000000b  ;"4"34
           db    00000000b,00111100b,00000100b,00011100b,00100000b,00100000b,00011100b,00000000b  ;"5"35
           db    00000000b,00111000b,00000100b,00011100b,00100100b,00100100b,00011000b,00000000b  ;"6"36
           db    00000000b,00111100b,00100000b,00100000b,00010000b,00001000b,00000100b,00000000b  ;"7"37
           db    00000000b,00011000b,00100100b,00011000b,00100100b,00100100b,00011000b,00000000b  ;"8"38
           db    00000000b,00011000b,00100100b,00100100b,00111000b,00100000b,00011100b,00000000b  ;"9"39
           db    00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00011000b,00010000b  ;","40
           db    00000000b,00001000b,00001000b,00001000b,00001000b,00000000b,00001000b,00000000b  ;"!"41
           db    00000000b,00011000b,00100100b,00100000b,00010000b,00000000b,00010000b,00000000b  ;"?"42
           db    00000000b,00000000b,00000000b,00111100b,00111100b,00000000b,00000000b,00000000b  ;"-"43
           db    00000000b,00000010b,00000100b,00000100b,00000100b,00000100b,00000010b,00000000b  ;")"44
           db    00000000b,01000000b,00100000b,00100000b,00100000b,00100000b,01000000b,00000000b  ;"("45
           db    00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00000000b  ;пробел 46  
           
           
Im         db    03Fh ,00Ch ,076h ,05Eh,04Dh,05Bh,07Bh ,00Eh,07Fh,05Fh    
       
           ASSUME cs:Code,ds:code,es:data

 
INIT PROC NEAR                      ;обнуление переменных
           mov f_klav,0
           mov kol[1],0
           mov kol[2],0
           mov kol[3],0
           mov klav,0
           mov n,0
           mov f_k,0
           mov up,8h
           mov left,18h
           mov down,28h        
           mov f_start,0   
           mov f_zapic,0   
           mov f_prioritet,0   
           mov f_vvod,0
           mov f_pram,1
           mov f_konez,0
           mov nomer_vivod,0
           mov prior_vivod,0
           mov diod,0
           mov nomer,1
           mov prior[1],1
           mov prior[2],1
           mov prior[3],1
           
           mov bx,0               ;заполнение массивов нажатых букв пробелами  
           mov cx,17
e_2:       mov ax,46
           mov Mas_bukva1 + bx,al
           add bx,1
           loop e_2         
           
           mov bx, 0 
           mov cx,17
e_3:       mov ax,46
           mov Mas_bukva2 + bx,al
           add bx,1
           loop e_3 
           
           mov bx, 0 
           mov cx,17
e_4:       mov ax,46
           mov Mas_bukva3 + bx,al
           add bx,1
           loop e_4  
            
           mov al,0ch
           out 33h,al                             
           RET
INIT ENDP 

IN_KLAV PROC NEAR              ;опрос клавиатуры
           cmp f_vvod,1
           jne klav_ret
           mov dl,1
           xor cx,cx
k2:        mov al,dl
           out 30h,al
           in  al,30h
           cmp al,0
           jne k5          
           cmp dl,0
           je  klav_ret
           shl dl,1         
           jmp k2     
               
k5:        push ax           
k4:        in  al,30h
           or  al,al
           jnz k4           
           pop ax
           mov f_klav,1
           mov f_k,1
k1:        inc cl          ;номер столбца
           shr al,1
           cmp al,0
           jnz k1
           dec cl
k3:        inc ch         
           shr dl,1
           cmp dl,0
           jnz k3
           dec ch          ;номер строки
           mov al,ch
           mov dl,8
           mul dl
           add al,cl
           mov klav,al     ;номер кнопки
klav_ret:  ret 
IN_KLAV ENDP
           
OPROS PROC               ;опрос порта ввода 0, где все кнопки размещены
           in  al,0
           cmp al,0
           je  o9
           push ax
o1:        in  al,0
           or  al,al
           jnz o1
           pop ax
           
           cmp al,1      ;кнопка пуск
           jne o2
           mov f_start,1 
           jmp opros_ret
o2:        cmp al,2      ;кнопка ввод
           jne o3
           call KVvod
           jmp opros_ret
o3:        cmp al,4      ;кнопка запись
           jne o4
           mov f_zapic,1
           mov f_vvod,0
           mov f_prioritet,0 
           inc nomer
           cmp nomer,4
           jne o10
           mov nomer,1
o10:       lea bx,Im
           mov al,nomer
           xlat
           out 32h, al
o9:        jmp opros_ret
o4:        cmp al,8      ;кнопка стоп
           jne o5
           mov f_start,0
           jmp opros_ret
o5:        cmp al,10h    ;кнопка сброс
           jne o6
           call Init
           jmp opros_ret
o6:        cmp al,20h    ;кнопка приоритет
           jne o7
           mov f_prioritet,1 
           jmp opros_ret    
o7:        cmp al,40h    ;кнопка прямой код
           jne o8
           mov f_pram,1
           jmp opros_ret
o8:        cmp al,80h    ;кнопка инверсный код
           jne opros_ret
           mov f_pram,0  
           jmp opros_ret                      
opros_ret: ret           
OPROS ENDP
                     
           
KStart PROC                   ;обработка кнопки "Пуск"
           mov n,0
           cmp f_start,1
           jne st9
           mov f_vvod,0
           mov al,00000111b
           and diod,al
           mov al,diod
           out 31h,al
           
           mov al,0
           out 32h,al 
           out 33h,al
           mov cx,9*8
           xor bx,bx
st1:       mov buffer + bx,0
           inc bx
           loop st1
           mov si,1
           cmp kol[si],0
           jne st2
           inc si
           cmp kol[si],0
           jne st2
           inc si
           cmp kol[si],0
           je start_ret1
           
st2:       mov ax,si
           mov nomer_vivod,al          
           mov al, prior[si]
           mov prior_vivod,al
           
           cmp si,1
           jne st3
           lea di,Mas_bukva1
           jmp st5
start_ret1:jmp start_ret            
st3:       cmp si,2
           jne st4
           lea di,Mas_bukva2
           jmp st5
st9:       jmp start_ret                   ;дальний переход
st4:       cmp si,3
           jne st5     
           lea di,Mas_bukva3
                            
st12:      mov n,0
st5:       inc n
           xor bx,bx
           mov bl,n
           xor ax,ax
           mov al,es:[di+bx] 
           shl ax,3                         ;умножение на 8          
           xor si,si
           mov bx,ax
           mov cx,8
st6:       mov al,Image+bx           ;помещаем имедж одного символа в буфер
           mov buffer+9+si,al
           inc bx
           add si,9
           loop st6
           
           mov sdvigi,8
st10:      mov si,9                  ;сдвиг одной строчки
           mov bl,8
st8:       mov cx,9
                    
st7:       rcr buffer+si,1
           dec si
           loop st7
           
           add si,18
           dec bl
           cmp bl,0
           jne st8
           
           call Vivod   
           call waitV
           
           in  al,0
           cmp al,8
           je start_ret1
           
           cmp al,40h              ;кнопка прямой код
           jne st16
           mov f_pram,1
           mov al,00000001b          ;горит прямой
           or  diod,al 
           mov al,11111101b
           and diod,al
           mov al,diod
           out 31h,al           
           jmp st17
st16:      cmp al,80h
           jne st17
           mov f_pram,0 
           mov al,00000010b          ;горит инверсный
           or  diod,al 
           mov al,11111110b
           and diod,al 
           mov al,diod
           out 31h,al
           jmp st17     
st25:      jmp st5           
                      
st17:      dec sdvigi
           cmp sdvigi,0
           jnz st10
           
           xor ax,ax
           mov al,nomer_vivod
           mov si,ax
           mov al,kol[si]
           inc al
           cmp al,n
           ja  st25
           dec prior_vivod
           cmp prior_vivod,0
           jnz st14
           jmp st13
st14:      jmp st12
st13:      
           inc nomer_vivod
           cmp nomer_vivod,4
           jb  st15
           mov nomer_vivod,1
st15:      xor bx,bx
           mov bl,nomer_vivod     
           cmp kol[bx],0
           je  st13
           mov si,bx
           mov n,0
           jmp st2
           
start_ret: mov f_start,0           
           ret            
KStart ENDP 


WaitV      proc              ;задержка
           mov cx,0ffffh
w1:                
           nop
           nop
           nop
           nop
           loop w1
           ret
WaitV ENDP


Vivod PROC                 ;вывод бегущей строки
           mov bh,8
           mov si,1
           mov bl,1
v2:        mov cx,8
           mov al,0
           out 1,al
           mov dx,21h
           mov al,bl
           out 11h,al
          
v1:        mov al,buffer + si
           cmp f_pram,0
           jnz v3
           not ax 
v3:        out dx,al
           inc dx
           inc si
           loop  v1  
           mov al,1
           out 1,al
           dec bh
           inc si
           shl bl,1
           cmp bh,0
           jnz v2
           mov al,0
           out 1,al
           ret
Vivod ENDP
 
          
KVvod PROC                  ;обработка кнопки "Ввод"
           mov f_vvod,1 
           xor ax,ax
           mov al,nomer
           mov si,ax
           cmp kol[si],0
           jne vvod_ret
           mov f_klav,0
vvod_ret: ret           
KVvod ENDP


SDiod PROC                      ;обработка порта вывода 31h  -  светодиоды
           cmp f_vvod,1
           jne d1
           mov al,00001000b
           or  diod,al
           jmp d2
d1:        mov al,00000111b
           and diod,al
d2:        cmp f_pram,1
           jne d3
           mov al,00000001b    ;горит прямой
           or  diod,al 
           mov al,11111101b
           and diod,al
           jmp d4
d3:        mov al,00000010b    ;горит инверсный
           or  diod,al 
           mov al,11111110b
           and diod,al     
            
d4:        xor ax,ax
           mov al,nomer
           mov si,ax
           cmp kol[si],16
           jae d5          ; >=
           mov f_konez,0
           mov al,00001011b
           and diod,al
           jmp d6
d5:        mov f_konez,1
           mov al,00000100b
           or  diod,al  
d6:        mov al,diod
           out 31h,al 
            
           cmp f_start,1
           je  d7  
           lea bx,Im
           mov al,nomer
           xlat
           out 32h, al
         
           xor dx,dx
           mov dl,nomer
           mov si,dx
           mov al,prior[si]
           lea bx,Im
           xlat
           out 33h,al
d7:        ret
SDiod ENDP

 
Prioritet PROC NEAP                    ;обработка кнопки "Приоритет"
          cmp f_prioritet,1
          jne prioritet_ret
          cmp f_k,1
          jne pr1
          
          mov al,klav
          cmp al,31
          jb  pr1
          cmp al,39
          ja  pr1
          mov dl,30
          sub al,dl
          xor dx,dx
          mov dl,nomer
          mov si,dx
          mov prior[si],al
         
pr1:      mov f_k,0
prioritet_ret: ret                   
Prioritet ENDP           
 
                       
PROVERKA PROC NEAR           ;запись нужного в нужные переменные                
          cmp f_k,0
          je  c6
          cmp f_prioritet,1
          je  c6
          mov f_zapic,0
          xor ax,ax
          mov al,nomer
          mov si,ax
                
          mov al,klav     ;кнопка del
          cmp al,47
          jne c4
          cmp kol[si],1
          jbe c5
          dec kol[si]
          jmp c3   
c5:       mov kol[si],0 
          mov f_klav,0
          jmp c3  
c6:       jmp proverka_ret          
c4:     
          cmp f_konez,1
          je proverka_ret
          inc kol[si]
          xor ax,ax
          mov al,kol[si]
          mov si,ax
          mov al,klav
          cmp nomer,1
          jne c1
          mov Mas_bukva1[si],al
          jmp c3
c1:       cmp nomer,2
          jne c2
          mov Mas_bukva2[si],al
          jmp c3
c2:       cmp nomer,3
          jne c3     
          mov Mas_bukva3[si],al                 
c3:       mov f_k,0
            
proverka_ret:
          ret           
PROVERKA ENDP           
           
MAS_OUT PROC NEAR            ;процедура вывода букв
                     
           mov up,1h
           mov left,11h
           mov down,28h
        
           xor ax,ax
           mov al,nomer
           mov si,ax
                   
           xor cx,cx
           mov cl,kol[si]
           dec cl
           mov ax,down
           sub ax,cx
           mov down,ax
          
           mov cl,kol[si]
           xor si,si
           mov si,1
           
           cmp f_klav,0
           je  out_ret
           cmp f_vvod,0
           je out_ret
           
m1:        push  cx
           lea bx,Image
m7:        mov ch,8           
           xor ax,ax          
           cmp nomer,1
           jne m3
           mov al,Mas_bukva1[si]
           jmp m5
m3:        cmp nomer,2
           jne m4
           mov al, Mas_bukva2[si]
           jmp m5
m4:        cmp nomer,3
           jne out_ret    
           mov al,Mas_bukva3[si]         
          
m5:        mov dl,8
           mul dl
           add bx,ax
           mov cl,1
           
m2:        mov dx,up
           mov al,1
           out dx,al
           mov al,cl
           mov dx,left
           out dx,al
           mov ax,[bx]
           cmp f_pram,1
           je  m6
           not ax           ;инверсный код
           
m6:        mov dx,down     
           out dx,al
           mov ax,0
           out dx,ax
           shl cl,1
           inc bx  
           dec ch
           cmp ch,0
           jnz m2        
           inc si
           inc down
           pop cx
           loop m1                 
out_ret:   ret
MAS_OUT ENDP           
   
Start:
           mov ax,Code
           mov ds,ax
           mov ax,data
           mov es,ax
           
           call init
begin:     call in_klav
           call opros
           call proverka
           call mas_out     
           call Prioritet  
           call SDiod
           call KStart
           jmp begin
           
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
