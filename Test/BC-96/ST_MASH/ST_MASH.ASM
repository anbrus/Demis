Name ST_MASH
data segment at 0BA00H
 Led_nagrev     db (?)       ;Байт управления индикатором "Нагрев"
 Led_left       db (?)       ;Байт управления индикатором "Лево"
 Led_right      db (?)       ;Байт управления индикатором "Право"
 F_temperat     db (?)       ;Флаг тумблера  "Температура"
 F_time         db (?)       ;Флаг тумблера  "Время"
 F_mode         db (?)       ;Флаг тумблера  "Режим"
 F_pusk         db (?)       ;Флаг тумблера  "Пуск"
 No_kbd         db (?)       ;Флаг неактивной клавиатуры 
 Doub_klic      db (?)       ;Флаг двойного нажатия
 Ob_kl_1        db (?)       ;Образ порта 1
 Ob_kl_2        db (?)       ;Образ порта 2
 Chislo         dw (?)       ;Число считанное из порта
 Chisl_dec      db (?)       ;Десятичное число
 Cifra          db (?)       ;Цифра считанная из порта
 Ready          db (?)       ;Готовность к работе двигателя
 Out_arr        db 3 dup (?) ;Массив: (время,темрература,режим)
 a              dw (?)       ;Переменная для хранения нажатой клавиши(процесс
                             ;устранения дребезга)  
 sch_temp       db (?)       ;Накопитель двадцати процентного охлаждения
 tec_temp       db (?)       ;Переменная для температура с учетом остывания
 pause1         db (?)       ;;
 left           db (?)       ;;
 pause2         db (?)       ;;Переменные для управления индикаторами 
 right          db (?)       ;;вращения двигателя
 time           db (?)       ;;


data ends

;Описание стека
stack segment at 0BA80H
  dw 50H dup (?)
  StkTop label word
stack ends

code segment
assume cs:code,ds:data,ss:stack

;                     ОПИСАНИЕ ПРОГРАММНЫХ МОДУЛЕЙ

;Модуль "Ввод с клавиатуры и формирования флагов клавиатуры"
KbdInput  PROC NEAR
  mov    bx,0h
  mov    bx,0h
  mov    No_Kbd,0                   ;Взведение флагов
  mov    Doub_klic,0

  cmp    F_pusk,0  
  jne    k5  
  
  in     al,0h                      ;Чтение клавиш из портов
  mov    ob_kl_1,al
  in     al,1h
  mov    ob_kl_2,al

  mov    bh,ob_kl_2
  and    bh,00000011b
  mov    bl,ob_kl_1                 ;В BX образ портов 00h и 01h (клавиатуры)

  cmp    bx,a
  je     k4
  cmp    bx,0
  je     k3

  mov    a,bx
  xor    al,al
  mov    cx,11
k1:
  shr    bx,1h
  jc     k2
  inc    al
  loop   k1
k2:
  mov    cifra,al                        ;Запись теккущей цифры

  cmp    bx,0
  je     k5
  mov    byte ptr doub_klic,0ffh         ;Фиксация двойного нажатия
  jmp    k4

k3:
  mov  a,0h
k4:
  mov  no_kbd,0ffh
k5:

  RET
KbdInput  ENDP

;Moдуль "Ввод с тумблеров"
TumbInput PROC NEAR

  in     al,1h
  cmp    al,8
  jne    t1
  mov    f_pusk,0ffh                   ;Тумблер "Cтарт" нажат
  mov    Ready,0h
t1:

  cmp    al,32
  jne    t2
  mov    F_time,0ffh                   ;Тумблер "Время" нажат
t2:

  cmp    al,64
  jne    t3
  mov    F_temperat,0ffh               ;Тумблер "Температура" нажат

t3:

  cmp    al,128
  jne    t4
  mov    F_mode,0ffh                   ;Тумблер "Режим" нажат

t4:

  RET
TumbInput ENDP

;Модуль "Сборка числа"
MadeChislo PROC NEAR

  cmp    no_kbd,0h
  jne    m1
  cmp    doub_klic,0h
  jne    m1

  mov    ax,chislo                ;Преобразование в число для вывода на экран
  mov    ah,al
  mov    al,cifra
  mov    chislo,ax



  mov    bx,chislo                ;Преобразование для записи в массиве
  mov    al,bh
  mov    ah,0aH
  mul    ah
  add    al,bl
  mov    Chisl_dec,al             ;Запись числа

m1:
  RET
MadeChislo ENDP

;Модуль "Формирование массива Out_Arr"
FormArr PROC NEAR
  cmp    Doub_Klic,0ffh
  je     f3
  cmp    No_Kbd,0h
  je     f3

  cmp    F_temperat,0ffh    ;Запись числа в ячейку температура
  jne    f1
  mov    al,chisl_dec  
;  cmp    al,60
  
  cmp    al,20
  jb     f0

  cmp    al,60
  ja     f0
   
  sub    al,20
  mov    out_arr[1],al
  mov    F_temperat,0
  jmp    f1

f0:
  mov    doub_klic,0ffh
  mov    F_temperat,0
  


f1:

  cmp    F_time,0ffh        ;Запись числа в ячейку время
  jne    f2
  mov    al,chisl_dec
  mov    out_arr[0],al
  mov    F_time,0

f2:

  cmp    F_mode,0ffh        ;Запись числа в ячейку режим работы
  jne    f3
  mov    al,chisl_dec
  dec    al
  cmp    al,2              ;Проверка соответствия введенного режима
  jbe    f5                ;существующим
  mov    doub_klic,0ffh
  mov    F_mode,0
  jmp    f3
f5:
  mov    out_arr[2],al
  mov    F_mode,0
f3:

  RET
FormArr ENDP


;Модуль "Управления нагревом"
NagrevControl PROC NEAR
  cmp    f_pusk,0ffh
  jne    n10

  cmp    out_arr[0],0
  je     n10

  mov    al,out_arr[1]
  mov    ah,20
  mul    ah
  mov    bx,100
  div    bx
  cmp    sch_temp,al               ;сделать больше или равно
  jb     n1
  sub    tec_temp,al

n1:

  mov    al,tec_temp
  cmp    al,out_arr[1]
  jb     n2

  mov    Led_nagrev,0h            ;Нагрев не идет
  inc    sch_temp
  mov    Ready,0ffh
  jmp    n11

n2:

  inc    tec_temp
  mov    Led_nagrev,0ffh          ;Нагрев идет
  mov    sch_temp,0h
  jmp    n11

n10:
  mov   sch_temp,0h
  mov   tec_temp,0h
  mov   f_pusk,0h
n11:

  RET
NagrevControl ENDP

;Модуль "Управления двигателем"
Dvigatel PROC NEAR
jmp d0
 reg_arr db 0,0,99,1, 30,10,30,10, 15,5,15,5
d0:
 cmp f_pusk,0ffh
 jne d15_5
 cmp Ready,0h
 je d15_5
 cmp byte ptr time,0
 je d14_4

 dec byte ptr time           ;Уменьшение времени на 1

 cmp pause2,0h
 je d1

 cmp left,0h                 ;Время вращения влево истекло ?
 jne d2
 cmp pause1,0h
 jne d5
 cmp right,0h                ;Время вращения вправо истекло ?
 jne d4
 cmp pause2,0h               ;Время паузы истекло ?
 jne d3

d2:
 mov led_left,0ffh
 mov led_right,0h
 dec byte ptr left
 jmp d_exit
d3:
 mov led_left,0h
 mov led_right,0h
 dec byte ptr pause2
 jmp d_exit
d4:
 mov led_left,0h
 mov led_right,0ffh
 dec byte ptr right
 jmp d_exit
d14_4:
 jmp d14
d15_5:
 jmp d15
d5:
 mov led_left,0h
 mov led_right,0h
 dec byte ptr pause1
 jmp d_exit

d1:
 mov al,4h
 mov ah,byte ptr out_arr[2]
 mul ah
 mov di,ax

 mov al,reg_arr[di][0]           ;Cчитывание параметров режима работы
 mov left,al
 mov al,reg_arr[di][1]
 mov pause1,al
 mov al,reg_arr[di][2]
 mov right,al
 mov al,reg_arr[di][3]
 mov pause2,al

 jmp d_exit

d14:
 mov led_left,0h                 ;Cброс всех флагов (т.к. время раб. истекло)
 mov led_right,0h
 mov f_pusk,0h
 mov led_nagrev,0h
 mov ready,0h
 mov pause2,0h
 mov al,out_arr[0]
 mov time,al
 jmp d_exit

d15:
 mov pause2,0
 mov pause2,0
 mov al,out_arr[0]
 mov time,al
 jmp d_exit

d_exit:

  RET
Dvigatel ENDP


;Модуль "Вывод информации"
InfoOut  PROC NEAR

jmp i1
 tabl    db 3fh,0ch,76h,5eh,4dh,5bh,79h,0eh,7fh,5fh
 tabl_er db 60h,73h               ;"Er"
i1:

 cmp doub_klic,0ffh
 je i5
 cmp F_pusk,0h
 jne i8 
 mov bx,chislo
 xor bh,bh
 mov di,offset tabl
 mov al,byte ptr cs:[di+bx]
 out 3h,al                       ;Вывод старшей цифры

 mov bx,chislo
 mov bl,bh
 xor bh,bh
 mov di,offset tabl
 mov al,byte ptr cs:[di+bx]
 out 2h,al                       ;Вывод младшей цифры
i8: 
 xor al,al

 cmp F_pusk,0ffh
 jne i2
 mov bl,Led_nagrev
 cmp bl,0h
 je i2
 or al,1b
i2:

 mov bl,Led_left
 cmp bl,0h
 je  i3
 or  al,10b
i3:

 mov bl,Led_right
 cmp bl,0h
 je  i4
 or  al,100b
i4:
 out 4h,al                        ;Отображение (Нагрев,Лево,Право)
 jmp i6

i5:
 
 mov al,byte ptr tabl_er[0]
 out 3h,al
 mov al,byte ptr tabl_er[1]
 out 2h,al
 
i6:


  RET
InfoOut  ENDP

;Модуль "Задержка"

Pause    PROC  near
  cmp    f_pusk,0ffh
  jne    p1
  mov    cx,1055h

P0:
  loop   P0
p1:
  ret
Pause    ENDP

;                          МАКРОУРОВЕНЬ ПРОГРАММЫ
begin:

  mov    ax,data
  mov    ds,ax
  mov    ax,stack
  mov    ss,ax

  call   KbdInput        ;Ввод с клавиатуры
  call   TumbInput       ;Вод с тумблеров
  call   MadeChislo      ;Сборка числа
  call   FormArr         ;Формировани массива Out_Arr
  call   NagrevControl   ;Управление нагревом воды
  call   Dvigatel        ;Управление двигателем
  call   InfoOut         ;Вывод информации
  call   Pause           ;Задержка


  org    07f0h
 
start: 
 jmp begin
code ends
end start
