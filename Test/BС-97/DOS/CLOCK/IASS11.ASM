data  segment at 0B940H
       dig     db 0Ah dup (?)
       hour    db ?               ;часы
       min     db ?               ;минуты
       sec     db ?               ;секунды
       bhour   db ?               ;часы будильника
       bmin    db ?               ;минуты будильника
       tsec    db ?               ;для проверки секунд на увеличение
       i_hour  db ?               ;"видеопамять" для часов
       i_min   db ?               ;минут     (FF-код гашения,FE-код "b")
       i_sec   db ?               ;секунд
       button  db ?               ;00000001-режим, 00000010-установ. 00000100-вкл.
       regim   db ?               ;00000001-часы  00000010-будильник
       ring    db ?               ;флаг работающего звонка 01-звонит
       rbyte   db ?               ;байт звонка
       ringon  db ?               ;флаг включения звонка 01-включен
data ends

code segment
assume cs:code,ds:data



;-----------------------------------------
      CHANGE proc                     ;процедура смены времени
;----------------------------------------
       push  ax
       push  dx
       cmp   tsec,10
       jb    m1                ;если секунда не накопилась то на конец
       mov   tsec,00
       inc   sec
       cmp   sec,60
       jb    m4                ;если sec<60 -> m2
       mov   sec,00
       inc   min
m2:    cmp   min,60
       jb    m3
       mov   min,00
       inc   hour
       cmp   hour,24
       jb    m3
       mov   hour,00
m3:    cmp   ringon,01
       jne   m4
       mov   al,hour
       mov   ah,min
       cmp   al,bhour
       jne   m1
       cmp   ah,bmin
       jne   m5
       mov   ring,01
       jmp   m4 
m5:    mov   ring,00
m4:    test  regim,00000001b  ;в режиме часов ?
       jz    m1                ;нет- не делать индикацию
       mov   al,sec
       mov   i_sec,al
       mov   al,min
       mov   i_min,al
       mov   al,hour
       mov   i_hour,al
       call  SHOW
m1:    pop   dx
       pop   ax
       ret
CHANGE endp
;--------------------------------------------
; процедура задержки на 0.1 сек.
;--------------------------------------------
 DELAY proc
       push  cx
       mov   cx,1
d1:    loop  d1
       inc   tsec
       pop   cx
       ret
 DELAY endp
;--------------------------------------------
; процедура сканирования кнопок
;--------------------------------------------
 INKEY proc
       push  ax
       in    al,00
       call  DELAY           ;задержка здесь
       call  CHANGE
       mov   button,al
       cmp   ring,01
       je    in1
       mov   al,00
       out   06,al
       jmp   in2
in1:   ror   rbyte,01        ;была 1 - стал 0 и наоборот
       mov   al,rbyte
       out   06,al           ;на индикацию
in2:   pop   ax
       ret
 INKEY endp
;------------------------------------------
; процедура установки режима
;------------------------------------------
 MODE  proc
       push  ax
       shl   regim,1
       cmp   regim,00000100b
       jnz   mo1
       mov   regim,01
 mo1:  test  regim,00000001b        ;часы ?
       jz    mo2
       mov   al,sec
       mov   i_sec,al
       mov   al,min
       mov   i_min,al
       mov   al,hour
       mov   i_hour,al
       jmp   mo3
mo2:   mov   i_sec,0FEh
       mov   al,bmin
       mov   i_min,al
       mov   al,bhour
       mov   i_hour,al
mo3:   call  SHOW
       pop   ax
       ret
 MODE  endp
;-----------------------------------------
; процедура установки
;-----------------------------------------
SET    proc
       push   ax
       test   regim,00000001b         ;в часах ?
       jnz     se17
       jmp    se7                     ;нет - то на будильник
se17:  mov    regim,00                ;обнуляем флаг режимов
       mov    i_min,0FFh              ;код гашения FFh
       mov    i_sec,0FFh              ;
       call   SHOW                    ;гасим минуты и секунды
se3:   call   INKEY                   ;опрашиваем клаву
       cmp    button,00000010b        ;"Установка" нажата ?
       je     se1                     ;если да, то на se1
       cmp    button,00000100b        ;Вкл ?
       jne    se2
       inc    hour                    ;да- увел. часы
       cmp    hour,24                 ;конец суток ?
       jb     se15                    ;если нет, то нормально
       mov    hour,00                 ;если да, то обнуляем часы
       jmp    se15
se2:   cmp    button,00000001b
       jne    se3
       dec    hour                    ;уменьш. часы
       cmp    hour,00
       jge    se15                    ;часы > или = 00 ?
       mov    hour,23                 ;нет засылаем 23
se15:  mov    al,hour
       mov    i_hour,al
       call   SHOW                    ;индицируем часы
       jmp    se3                     ;на опрос клавы
se1:   mov    i_hour,0FFh
       mov    al,min
       mov    i_min,al
       call   SHOW                    ;гасим часы, показ. минуты
se6:   call   INKEY
       cmp    button,00000010b        ;"Установка" ?
       je     se4
       cmp    button,00000100b
       jne    se16
       inc    min
       cmp    min,60
       jb     se5
       mov    min,00
       jmp    se5
se16:  cmp    button,00000001b
       jne    se6
       dec    min
       cmp    min,00
       jge    se5
       mov    min,59
se5:   mov    al,min
       mov    i_min,al
       call   SHOW                    ;показать минуты
       jmp    se6
se4:   mov    al,hour
       mov    i_hour,al
       mov    sec,00
       mov    i_sec,00
       call   SHOW                    ;обнуляем секунды и показ. время
       mov    regim,01                ;восстанавливаем режим
       jmp    se8                     ;на конец
se7:   mov    i_min,0FFh
       mov    i_sec,0FEh
       mov    ringon,01               ;включаем будильник
       mov    al,bhour
       mov    i_hour,al
       call   SHOW                    ;показываем будильник
se11:  call   INKEY
       cmp    button,00000010b        ;"Установка" ?
       je     se9                     ;если да, то на se9
       cmp    button,00000100b
       jne    se18
       inc    bhour
       cmp    bhour,24                ;конец суток ?
       jb     se10                    ;если нет, то нормально
       mov    bhour,00                ;если да, то обнуляем часы
       jmp    se10
se18:  cmp    button,00000001b
       jne    se11
       dec    bhour
       cmp    bhour,00
       jge    se10
       mov    bhour,23
se10:  mov    al,bhour
       mov    i_hour,al
       call   SHOW                    ;индицируем часы
       jmp    se11                    ;на опрос клавы
se9:   mov    i_hour,0FFh
       mov    al,bmin
       mov    i_min,al
       call   SHOW                    ;гасим часы, показ. минуты
se14:  call   INKEY
       cmp    button,00000010b        ;"Установка" ?
       je     se12
       cmp    button,00000100b
       jne    se19
       inc    bmin
       cmp    bmin,60
       jb     se13
       mov    bmin,00
       jmp    se13
se19:  cmp    button,00000001b
       jne    se14
       dec    bmin
       cmp    bmin,00
       jge    se13
       mov    bmin,59
se13:  mov    al,bmin
       mov    i_min,al
       call   SHOW                    ;показать минуты
       jmp    se14
se12:  mov    al,bhour
       mov    i_hour,al
       call   SHOW
se8:   pop    ax
       ret
SET    endp

;-----------------------------------------
;Процедура индикации
;-----------------------------------------
SHOW   proc
       push   ax
       push   bx
       mov    bx,offset dig               ;в BX нач. адрес таблицы
       cmp    i_sec,0FFh                  ;гасить ?
       jne    sh1
       mov    al,00
       out    00,al
       out    01,al
       jmp    sh3
sh1:   cmp    i_sec,0FEh                  ;показать "b" ("ob",если вкл.)?
       jne    sh2
       mov    al,01111001b
       out    00,al                       ;показываем
       mov    al,00
       cmp    ringon,01
       jne    sh8
       mov    al,01111000b
sh8:   out    01,al
       jmp    sh3
sh2:   mov    al,i_sec                    ;разбивка и
       aam                                ;индикация
       xlat                               ;числа секунд
       out    00,al
       mov    al,ah
       xlat
       out    01,al
sh3:   cmp    i_min,0FFh                  ;гасить минуты ?
       jne    sh4
       mov    al,00
       out    02,al
       out    03,al
       jmp    sh5
sh4:   mov    al,i_min                    ;показываем минуты
       aam
       xlat
       out    02,al
       mov    al,ah
       xlat
       out    03,al
sh5:   cmp    i_hour,0FFh                 ;гасить часы ?
       jne    sh6
       mov    al,00
       out    04,al
       out    05,al
       jmp    sh7
sh6:   mov    al,i_hour
       aam
       xlat
       out    04,al
       mov    al,ah
       xlat
       out    05,al
sh7:   pop    bx
       pop    ax
       ret
SHOW   endp

;-----------------------------------------
;Вкл./Выкл. будильник
;-----------------------------------------
VKL    proc
       test   regim,00000010b
       jz     vk1
       cmp    ringon,00
       jne    vk2
       mov    ringon,01
       jmp    vk1
vk2:   mov    ringon,00
vk1:   call   SHOW
       ret
VKL    endp

;-----------------------------------------
; МАКРОУРОВЕНЬ
;-----------------------------------------
start: mov ax,data
       mov ds,ax

       mov dig[0], 3FH
       mov dig[1], 0CH
       mov dig[2], 76H
       mov dig[3], 5EH
       mov dig[4], 4DH
       mov dig[5], 5BH
       mov dig[6], 7BH
       mov dig[7], 0EH
       mov dig[8], 7FH
       mov dig[9], 5FH
       mov hour,00
       mov min,00
       mov sec,00
       mov bhour,00
       mov bmin,00
       mov tsec,00
       mov i_hour,00
       mov i_min,00
       mov i_sec,00
       mov button,00
       mov regim,01
       mov ring,00
       mov rbyte,01010101b
       mov ringon,00

ma4:   call  INKEY
       cmp   button,00000001b       ;Режим ?
       jne   ma1
       mov   ring,00
       call  MODE
ma1:   cmp   button,00000010b       ;Установ ?
       jne   ma2
       mov   ring,00
       call  SET
ma2:   cmp   button,00000100b       ;Вкл ?
       jne   ma3
       mov   ring,00
       call  VKL
ma3:   jmp   ma4
code ends
end start
