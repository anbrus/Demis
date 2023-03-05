PAGE 60, 120
                     NAME OhranSignal
            ;Описание поименованных констант
f_mig EQU 350  ;константа частоты мигания
Port_et=1      ;адреса портов
Port_k=2       ;архитектуры
Port_d_p=3     ;ввода-вывода
Port_d_v=6
             ;Описание данных
data segment at 0BA00H
       Map db 8 dup (?)
       Et  db 3 dup (?)
       Dat db 8 dup (?)
       lamp_et db 01h dup (?)
       lamp_k db 01h dup (?)
       l_mig db 01h dup (?)
       ll1 db 8 dup (?)
       ll2 db 8 dup (?)
data ends
            ;Описание стека 
stack segment at 0BA80H
  dw 50H dup (?)
  StkTop label word
stack ends
            ;Описание выполняемых действий
code segment
assume cs:code,ds:data,ss:stack
;_________________________________________________
            ;Описание программных модулей
;Подмодуль "Частота мигания"
delay proc
        mov  cx,f_mig
loop_:
	push 	ax
	pop	ax
	loop 	loop_
        ret 
delay endp
;________________________________________________________________________
;Модуль "Функциональная подготовка"
podgotovka proc
       mov Map[0], 0CH
       mov Map[1], 76H
       mov Map[2], 05EH
       mov Map[3], 4DH
       mov Map[4], 5BH
       mov Map[5], 7BH
       mov Map[6], 0EH
       mov Map[7], 7FH
       mov et[1],  0CH
       mov et[2],  76H
       mov dat[1], 00H
       mov dat[3], 2FH 
       mov dat[5], 7FH
       mov dat[7], 00H
       ret
podgotovka endp
;___________________________________________________________________
;модуль, производящий мигание лампочки при активизации одного из датчиков 
mig_lam proc 
        cmp    l_mig,03h   ;датчик активен?
        jb     ml2         ;переход, если нет
        jmp    ml1
ml1:
        xor   al,al        
        out   dx,al
        mov   al,ah
        xor   al,dh
        out   dx,al
        call  delay        ;задержка
        mov   al,ah
        out   dx,al
        cmp   l_mig,05h
        je    ml1
ml2:            
        ret
mig_lam endp
;_______________________________________
;модуль, осуществляющий гашение лампочки
gasch_lam proc
         in   al,4
         cmp  al,0
	 jnz  gl     ;переход, если al#0
         xor  dh,dh
         mov  al,dh
gl:
         ret 
gasch_lam endp                  
;_______________________________________________________
;модуль, осуществляющий выбор лампочки в соответствии 
;с выбранной комнатой для 1-го этажа 
lamp_komn1 proc
         mov   bx,offset Map
         call  in_kbd_komn   ;ввод комнаты
         
lk1_1:   cmp   lamp_k,00h    ;1-я комната введена?  
         je    lk2_1         ;переход на l0, если да 
         jmp   lk3_1       
lk2_1:
         mov   dh,1          
         call  gasch_lam     ;проверка на снятие с охраны
         mov   ll1[0],dh
         mov   ah,ll1[1]
         jmp   l_end1   
lk3_1:      
         cmp   lamp_k,01h
         je    lk4_1
         jmp   lk5_1

lk4_1:  
         mov   dh,1  
         shl   dh,1
         call  gasch_lam
         mov   ll1[1],dh
         jmp   l_end1 
lk5_1:      
         cmp   lamp_k,02h
         je    lk6_1
         jmp   lk7_1

lk6_1: 
         mov   dh,1 
         shl   dh,2
         call  gasch_lam
         mov   ll1[2],dh
         jmp   l_end1   
lk7_1:      
         cmp   lamp_k,03h
         je    lk8_1
         jmp   lk9_1
lk8_1: 
         mov   dh,1
         shl   dh,3
         call  gasch_lam
         mov   ll1[3],dh
         jmp   l_end1 
lk9_1:      
         cmp   lamp_k,04h
         je    lk10_1
         jmp   lk11_1
lk10_1:    
         mov   dh,1
         shl   dh,4
         call  gasch_lam 
         mov   ll1[4],dh
         jmp   l_end1 
lk11_1:      
         cmp   lamp_k,05h
         je    lk12_1
         jmp   lk13_1
lk12_1:
         mov   dh,1
         shl   dh,5 
         call  gasch_lam
         mov   ll1[5],dh
         jmp   l_end1
lk13_1:      
         cmp   lamp_k,06h
         je    lk14_1
         jmp   lk15_1
lk14_1:  
         mov   dh,1
         shl   dh,6
         call  gasch_lam 
         mov   ll1[6],dh
         jmp   l_end1  
lk15_1:      
         cmp   lamp_k,07h
         je    lk16_1
         jmp   l_end1

lk16_1: 
         mov   dh,1
         shl   dh,7
         call  gasch_lam 
         mov   ll1[7],dh
l_end1:
         mov   al,0 
         mov   ah,dh         
         call  form_gor_l1 
         mov   al,ah 
         out   dx,al 
         ret
lamp_komn1 endp  
;_______________________________________________________
;модуль, осуществляющий выбор лампочки в соответствии 
;с выбранной комнатой для 2-го этажа 
lamp_komn2 proc
         mov   bx,offset Map
         call  in_kbd_komn   ;ввод комнаты
         xor   ah,ah
lk1_2:   cmp   lamp_k,00h    ;1-я комната введена?  
         je    lk2_2         ;переход на l0, если да 
         jmp   lk3_2       
lk2_2:
         mov   dh,1          
         call  gasch_lam     ;проверка на снятие с охраны
         mov   ll2[0],dh
         jmp   l_end2
lk3_2:      
         cmp   lamp_k,01h
         je    lk4_2
         jmp   lk5_2
lk4_2:  
         mov   dh,1  
         shl   dh,1
         call  gasch_lam
         mov   ll2[1],dh
         jmp   l_end2          
lk5_2:      
         cmp   lamp_k,02h
         je    lk6_2
         jmp   lk7_2

lk6_2: 
         mov   dh,1 
         shl   dh,2
         call  gasch_lam
         mov   ll2[2],dh
         jmp   l_end2          
lk7_2:      
         cmp   lamp_k,03h
         je    lk8_2
         jmp   lk9_2
lk8_2: 
         mov   dh,1
         shl   dh,3
         call  gasch_lam
         mov   ll2[3],dh
         jmp   l_end2          
lk9_2:      
         cmp   lamp_k,04h
         je    lk10_2
         jmp   lk11_2
lk10_2:    
         mov   dh,1
         shl   dh,4
         call  gasch_lam 
         mov   ll2[4],dh
         jmp   l_end2          
lk11_2:      
         cmp   lamp_k,05h
         je    lk12_2
         jmp   lk13_2
lk12_2:
         mov   dh,1
         shl   dh,5 
         call  gasch_lam
         mov   ll2[5],dh
         jmp   l_end2          
lk13_2:      
         cmp   lamp_k,06h
         je    lk14_2
         jmp   lk15_2
lk14_2:  
         mov   dh,1
         shl   dh,6
         call  gasch_lam 
         mov   ll2[6],dh 
lk15_2:      
         cmp   lamp_k,07h
         je    lk16_2
         jmp   l_end2

lk16_2: 
         mov   dh,1
         shl   dh,7
         call  gasch_lam 
         mov   ll2[7],dh
l_end2:
         mov   al,0 
         mov   ah,dh
         call  form_gor_l2 
         mov   al,ah 
         out   dx,al 
         ret
lamp_komn2 endp  
;______________________________________
;формирование горящих лампочек для 1-го этажа
form_gor_l1 proc
	 mov  si,0
         xor  ah,ah
         mov  cx,8
fgl1:   
         or   ah,ll1[si]
         inc  si
         loop fgl1
         ret
form_gor_l1 endp
;______________________________________
;формирование горящих лампочек для 2-го этажа
form_gor_l2 proc
	 mov  si,0
         xor  ah,ah
         mov  cx,8
fgl2:   
         or   ah,ll2[si]
         inc  si
         loop fgl2
         ret
form_gor_l2 endp
;__________________________________________ 
;ввод номера комнаты с последующим сохранением в переменной
in_kbd_komn proc
        mov   dh,0
mm:     
	in    al,Port_k
        test  al,0ffh
        jz    n1
	cmp   al,0
	jne   PRESS1    
	mov   al,dh
	xlat
	out   Port_k,al
	jmp   mm
press1:
	mov   ah,al
	mov   al,-1
g1:	
	inc   al
	shr   ah,1
	cmp   ah,0
	jnz   g1       
	mov   dh,al
        mov   lamp_k,al
        xlat
        out   Port_k,al
        jmp   mm 
n1:
        ret
in_kbd_komn  endp
;______________________________________ 
;ввод номера этажа с последующим сохранением номера в переменной       
in_kbd_et proc
        mov   dh,0
m:     
	in    al,1
        test  al,0ffh
        jz    m1
	cmp   al,0
	jne   PRESS    
	mov   al,dh
	xlat
	out   1,al
	jmp   m
press:
	mov   ah,al
	mov   al,-1
g:	
	inc   al
	shr   ah,1
	cmp   ah,0
	jnz   g       
	mov dh,al
        mov lamp_et,al
        xlat
        out 1,al
        jmp m 
m1:
        ret
in_kbd_et  endp
;______________________________________
;Модуль "Выбор этажа"        
case_et proc
case1:
        mov    bx,offset et    ;передача параметров для  
        call   in_kbd_et       ;ввода и вывода этажа
        cmp    lamp_et,01h     ;номер этажа равен 1?
        je     et1             ;переход, если да
        jmp    case2    
et1:
        mov     dx,4
        call    lamp_komn1     ;формирование горящих лампочек          
        call    mig_lam        ;мигание лампочек
case2:
        cmp     lamp_et,02h    ;номер этажа равен 2? 
        je      et2            ;переход, если да
        jmp     case3 
et2:  
        mov     dx,5
        call    lamp_komn2
        call    mig_lam 
case3: 
        ret
case_et endp
;_______________________________________
;активизирование датчиков
in_kbd_dat proc
        mov   dh,0
ikd1:     
	in    al,Port_d_p       ;ввод датчиков
        test  al,0ffh
        jz    ikd4
	cmp   al,0
	jne   ikd2    
	mov   al,dh
	xlat
	out   Port_d_p,al
        out   Port_d_v,al
	jmp   ikd1
ikd2:
	mov   ah,al
	mov   al,-1
ikd3:	
	inc   al
	shr   ah,1
	cmp   ah,0
	jnz   ikd3       
	mov   dh,al

        cmp   al,3          ;введен датчик "пожар"?
        jne   ikd4          ;переход, если нет
        xlat                ;табличное преобразование
        out   Port_d_p,al   ;вывод состояния датчика
        mov   l_mig,al      ;запоминание состояния в переменной
ikd4:
        cmp   al,1          ;сброс?
        jne   ikd5
        xlat
        out   Port_d_p,al
        mov   l_mig,al 
ikd5:
        cmp   al,5          ;введен датчик "вор"?
        jne   ikd6
        xlat
        out   Port_d_v,al
        mov   l_mig,al
ikd6: 
        cmp   al,7          ;сброс?
        jne   ikd7
        xor   al,al
        xlat
        out   Port_d_v,al
        mov   l_mig,al 
        jmp   ikd1 
ikd7:
        ret
in_kbd_dat  endp
;____________________________________________________________
                   ;Макроуровень программы       
begin:
       mov ax,data                ;инициалиализация сегментных
       mov ds,ax                  ;регистров

       mov ax,stack
       mov ss,ax       
       mov sp,offset StkTop       ;и указателя стека 
       call podgotovka            ;функциональная подготовка
cycle:
       mov  bx,offset Map         ;передача параметров для ввода и вывода
       call in_kbd_komn           ;номера комнаты
       call case_et               ;ввод этажа
       mov  bx,offset dat         ;передача параметров для
       call in_kbd_dat            ;активизации датчиков
       jmp cycle                  ;замыкание программного кольца
       org 07F0H
start:
       jmp begin   
code ends
     end start
                  