.286
NAME  Grate
Data  segment at 0ba00h
     activ   db ?         ;  активное знакоместо 
     flash   db ?         ;  флаг мигания
     kbdin   db ?
     sec22   db ?
     sec21   db ?
     min22   db ?
     min21   db ?
     hour1   db ? 
     sec12   db ?
     sec11   db ?
     min12   db ?
     min11   db ?
     hour2   db ?
     endgf   db ?
     Map db 0AH dup (?)
     port db ?
     num db ?
     player1 db ?          ;  флаги нажатых кнопок
     player2 db ? 
     portout db ?          ;  буфер вывода флажков
Data    ends
Stac  segment at 0ba80h
     org 110h
     dw 10 dup (?)
     StkTop LABEL WORD
Stac ends

Code  segment
     assume cs:Code,ds:Data,ss:Stac
    
    ;Описание програмных модулей
FuncPrep proc near           ;инициализация данных
     cmp endgf,0
     jz m40
     cmp flash,0h
     jz m40
     mov hour1, 0 
     mov hour2, 0
     mov min11, 0
     mov min12, 0
     mov min21, 0
     mov min22, 0
     mov sec11, 0
     mov sec12, 0
     mov sec21, 0
     mov sec22, 0 
     mov flash, 0   
     mov activ, 0 
     mov player1,0
     mov player2,0
     mov portout,0    
     mov endgf,0
     mov al,0                ; очистка порта 
     out 0ah,al              ; флажков 
m40 :ret     
FuncPrep  endp
;------------------------------------------
Delay proc near              ; процедура задержки мигания
       push bx
     Cycle:
       mov  bx,100
Wait2: dec  bx
       jnz  Wait2
       loop Cycle
       pop  bx
       ret
Delay endp
;------------------------------------------
input proc near
      mov flash,0ffh
      in  al,0                 ;ввод из порта
      mov kbdin,al
      ret
input endp
;----------------------------------------------
again proc near                ;ожидание перехода режимов
c01: mov al,portout
     and al,4
     jz m55      
     mov al,portout
     add al,2
     out 0ah,al
     mov cx,300
     call delay
     mov al,portout
     out 0ah,al
     mov cx,300
     call delay
     jmp m56 
m55: mov al,portout
     add al,64
     out 0ah,al
     mov cx,300
     call delay
     mov al,portout
     out 0ah,al
     mov cx,300
     call delay    
m56: in al,0h
     and al,1h
     jnz c01
     ret
again endp
;----------------------------------------------
pause proc near                ; Процедура секундной задержки
     cmp flash,0ffh
     jz m12
     mov endgf,0ffh
     mov cx,9b70H
   C1:nop
     loop C1
  m12:ret 
pause endp
;----------------------------------------------
endgame proc near              ; Процедура проверки конца игры
   cmp flash,0ffh
   jz  m23
   cmp hour1,0
   jnz m24
   cmp min11,0
   jnz m24
   cmp min12,0
   jnz m24
   cmp sec11,0
   jnz m24
   cmp sec12,0
   jnz m24
   add portout,4
   call again
   mov endgf,0ffh
    
m24:cmp hour2,0
    jnz m23
    cmp min21,0
   jnz m23
   cmp min22,0
   jnz m23
   cmp sec21,0
   jnz m23
   cmp sec22,0
   jnz m23
 
   call again
   mov endgf,0ffh   
m23:ret
endgame endp
;----------------------------------------------
Signal proc near    ; проверка игры на флажке
    cmp flash,0ffh  ; не выполнять 
    jz m22          ; в режиме установки
    cmp hour1,0     ; Проверка флажка
    jnz m11         ; первого игрока
    cmp min11,0
    jnz m11
    cmp min12,1
    jnz m25
    jmp m26
m25:cmp min12,0
    jnz m11
m26:mov al,portout
    and al,1
    jnz m11   
    add portout,1
    mov al,portout
    out 0ah,al

m11:cmp hour2,0        ;проверка флажка
    jnz m22            ;второго игрока  
    cmp min21,0
    jnz m22
    cmp min22,1
    jnz m27
    jmp m28
m27:cmp min22,0
    jnz m22 
m28:mov al,portout
    and al,32
    jnz m22   
    add portout,32
    mov al,portout
    out 0ah,al    

m22:cmp flash,0       ;проверка флажков 
    jz m29            ;исправленного времени
    mov al,portout   
    and al,1
    jz m30
    and portout,0feh 
    mov al,portout
    out 0ah,al
m30:mov al,portout
    and al,32h
    jz m29
    and portout,0dfh 
    mov al,portout
    out 0ah,al
m29:ret
Signal endp
;----------------------------------------------
clock1 proc near          ;часы первого игрока
    cmp flash,0
    jnz m10
    cmp player1,0ffh
    jnz m10
    cmp sec12,0
    jz m13
    dec sec12
    jmp m10
m13:cmp sec11,0
    jz m14
    dec sec11
    mov sec12,9
    jmp m10
m14:cmp min12,0
    jz m15
    dec min12
    mov sec12,9
    mov sec11,5    
    jmp m10
m15:cmp min11,0
    jz m16
    dec min11
    mov sec12,9
    mov sec11,5
    mov min12,9
    jmp m10
m16:cmp hour1,0
    jz m10
    dec hour1
    mov sec12,9
    mov sec11,5
    mov min12,9
    mov min11,5   
m10:ret    
clock1 endp
;----------------------------------------------
clock2 proc near          ;часы второго игрока
    cmp flash,0
    jnz m17
    cmp player2,0ffh
    jnz m17
    cmp sec22,0
    jz m18
    dec sec22
    jmp m17
m18:cmp sec21,0
    jz m19
    dec sec21
    mov sec22,9
    jmp m17
m19:cmp min22,0
    jz m20
    dec min22
    mov sec22,9
    mov sec21,5    
    jmp m17
m20:cmp min21,0
    jz m21
    dec min21
    mov sec22,9
    mov sec21,5
    mov min22,9
    jmp m17
m21:cmp hour2,0
    jz m17
    dec hour2
    mov sec22,9
    mov sec21,5
    mov min22,9
    mov min21,5   
    m17: ret    
clock2 endp

;----------------------------------------------
Select proc near      ;процедура обработки входной информации
    in al,0h
    ror al,1
    jnc m5
    mov flash,0h    
    in al,0h          ;определение активных часов
    rol al,1
    jnc m9
    mov player2,0ffh      ;выделение идущих часов
    mov player1,0
m9: in al,0h          
    rol al,2
    jnc m5
    mov player1,0ffh 
    mov player2,0
m5: 
    in al,0h               ;определение активного знакоместа
    and al,2h
    jz m2
    inc activ
    cmp activ,0ah
    jnz m2
    mov activ,0
m2: ret   
Select endp
;--------------------------------------
OneMode proc near           ;   прроцедура изменения времени в
    cmp activ,ah            ;   одном знакоместе
    jnz m7
    inc al
    cmp ah,1
    jz m8
    cmp ah,3
    jz m8
    cmp ah,6
    jz m8
    cmp ah,8
    jz m8
    cmp al,0ah              ; Для деситизначных индикаторов
    jnz m7
    mov al,0 
    jmp m7
m8: cmp al,06h              ; Для шестизначных индикаторов 
    jnz m7
    mov al,0 
m7: ret
OneMode endp
;--------------------------------------
Modify proc near      ;процедура изменения времени
    cmp flash,0ffh
    jnz m6
    in al,0h
    ror al,3h
    jnc m6
    mov al,sec22 ;вызов Процедур модификации 
    mov ah,0
    call OneMode
    mov sec22,al ;Запись результата  
    
    mov al,sec21
    mov ah,1
    call OneMode
    mov sec21,al   
    
    mov al,min22
    mov ah,2
    call OneMode
    mov min22,al
 
    mov al,min21
    mov ah,3
    call OneMode
    mov min21,al
    
    mov al,hour2
    mov ah,4
    call OneMode
    mov hour2,al
 
    mov al,sec12 ;вызов Процедур модификации 
    mov ah,5
    call OneMode
    mov sec12,al ;Запись результата  
    
    mov al,sec11
    mov ah,6
    call OneMode
    mov sec11,al   
    
    mov al,min12
    mov ah,7
    call OneMode
    mov min12,al
 
    mov al,min11
    mov ah,8
    call OneMode
    mov min11,al
    
    mov al,hour1
    mov ah,9
    call OneMode
    mov hour1,al
    
m6:ret
Modify endp
;--------------------------------------
InitMap proc near

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
       ret
InitMap endp
;-------------------------------------------------
Translvid proc near        ; перевод и вывод одного знакоместа
     cmp flash,0h
     jz m3
     mov al,port
     cmp al,activ
     jnz m3
     mov cx,100h
     call Delay            ; задержка мигания 
     mov al,0
     mov dl,port
     out dx,al
     mov cx,100h
     call Delay            ; задержка мигания 
 m3: mov bx, offset Map
     mov al,num
     xlat
     mov dl,port
     out dx,al
     ret 
Translvid endp
;--------------------------------------------------
Vidout proc near       ;  Вывод  текущих часов
     call InitMap
     mov al,sec22
     mov num,al
     mov port,0
     call Translvid
     mov al,sec21
     mov num,al
     mov port,1
     call Translvid
     mov al,min22 
     mov num,al
     mov port,2
     call Translvid
     mov al,min21
     mov num,al
     mov port,3
     call Translvid
     mov al,hour2
     mov num,al
     mov port,4
     call Translvid
     mov al,sec12
     mov num,al
     mov port,5
     call Translvid
     mov al,sec11
     mov num,al
     mov port,6
     call Translvid   
     mov al,min12
     mov num,al
     mov port,7
     call Translvid
     mov al,min11
     mov num,al
     mov port,8
     call Translvid
     mov al,hour1
     mov num,al
     mov port,9
     call Translvid     
     ret
Vidout endp
;--------------------------------------------------

                        ;макроуровень программы
Start:
  mov ax,Data           ;  инициализация сегментных
  mov DS,ax             ;  регистров
  mov ax,Stac
  mov SS,ax
  mov sp,offset StkTop  ;  и верхушки стека 
cont:  
  call FuncPrep         ;  обнуление часов
  call input		;  опрос управляющих клавиш
  call Select		;  выбор знакомест
  call Modify		;  изменение текущего знакоместа
  call clock1		;  ход часов первого игрока
  call clock2		;  ход часов второго игрока
  call pause		;  секундная задержка
  call Vidout		;  отображение текущего времени
  call Signal		;  вывод оповещающих сигналов
  call endgame		;  проверка окончания игры
  jmp cont

  org 0ff0h
  assume cs:nothing
  begin:jmp far ptr Start
Code   ends
  end begin