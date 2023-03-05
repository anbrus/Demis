;                     ┌───────────────────────────────┐
;                     │ Программа "КТО БЫСТРЕЕ ?"     │
;                     │ Группа:   ВС2-96              │
;                     │ Студенты: Непомнящий А.С.     │
;                     │           Завьялов   С.В.     │
;                     │           Никифоров  Р.А.     │
;                     └───────────────────────────────┘
;
;
;-----------------------------------------------------------------------------
;                               ОПИСАНИЕ ТИПОВ
;-----------------------------------------------------------------------------

Player STRUC
       Number dw ?
       Time1  dw ?
       Time2  dw ?
Player ENDS


;-----------------------------------------------------------------------------
;                        ОПИСАНИЕ ПОИМЕНОВАННЫХ КОНСТАНТ
;-----------------------------------------------------------------------------

Zero_Ind_s     EQU  00h
One_Ind_s      EQU  01h
Three_Ind_s    EQU  03h
Clear_Disp     EQU  00h

Free_mode      EQU  00h
Choose_mode    EQU  01h
Ctrl_mode      EQU  02h

Passive_kbd    EQU  01h
Active_kbd     EQU  00h

OneUser_Btn    EQU  04h
MultyUser_Btn  EQU  08h
Up_btn         EQU  10h
Down_btn       EQU  20h
Best_btn       EQU  40h
Bad_btn        EQU  80h
Ready_btn      EQU  01h

E_letter       EQU  0f3h
r_letter       EQU  0e0h
Dot_letter     EQU  80h

;-----------------------------------------------------------------------------
;                              ОПИСАНИЕ ДАННЫХ
;-----------------------------------------------------------------------------

DATA SEGMENT at 0ba00h

     List      Player  7   dup  (<>)
     digits      db   128  dup  (?)

     Free_mode_flag   db  ?  ;Значения: 2-режим контроля,
                             ;1- режим выбора числа польз-лей, 0-режим
                             ;просмотра результатов работы многопольз.режима.
     OneUser_flag     db  ?  ;Флаг работы в однопольз.режиме взведен при =4.
     MultyUser_flag   db  ?  ;Флаг работы в многопольз.режиме взведен при =8.
     Pl_Min_us_flag   db  ?  ;Флаг увел./умен. числа пользователей передает
                             ;1-плюс или 0-минус в процедуру UserSelect.
     Passive_kbd_flag db  ?  ;Флаг неактивной кл-ры.

     Cur_user_offset  dw  ?  ;Смещения в массиве List текущего и следущего
     Next_user_offset dw  ?  ;пользователей.
     Cur_user_time  dd  ?    ;Значения Time1 & Time2 текущего и следущего
     Next_user_time dd  ?    ;пользователей.
     Cur_sort_numb  dw  ?    ;Значения Number текущего и следущего
     Next_sort_numb dw  ?    ;пользователей.
     Num_for_sort   dw  ?    ;Значение номера текущего сортируемого польз-ля.
     Kol_users      dw  ?    ;Кол-во польз-лей передаваемое в Sort_List.
     Cur_sort_user  dw  ?    ;Номера в массиве двух сравниваемых
     Next_sort_user dw  ?    ;пользоваетелей.
     Keys           db  0    ;Хранит старое значение нажатых клавиш(порта ввода).
     Ind_s          db  ?    ;Передает 1-"Готов",3-"Готов"&"Жми" в Out_to_ind.
     Users          dw  ?    ;Передает число 0..9 в Display_User(для отобр. в "Номер пользоваетеля").
     Numb_of_users  dw  ?    ;Содержит число польз-лей 1-в однп.реж. и 2..7 - в мнгпольз.реж.
     Cur_user_numb  dw  ?    ;Содержит номер текущ. пользователя.

     MaxTime        db  ?    ;Содержит максимально допустимое время реакции
     PressTime      dw  ?    ;Содержит максимально допустимое скорректированное время реакции
     CurTime        db  ?    ;Содержит текущее время (доли секунд)
     Key_Press_     db  ?    ;Маска нажатия кнопки "Press"
     Errors         db  ?    ;Флаг ошибки фальстарта 0-"чистый старт",2-фальстарт формируется в Delay.

     binary1        dw  ?    ;Содержат соответственно целое и дробное значения
     binary2        dw  ?    ;являясь выходными переменными Count.
     binary         dw  ?    ;Передает двоичное число в BinToBcd
     bin_dec        dw  ?    ;Содержит дв.-дес. число - выходная перем-ая BinToBcd

DATA ENDS

;-----------------------------------------------------------------------------
;       			 ОПИСАНИЕ СТЕКА
;-----------------------------------------------------------------------------

STACK SEGMENT at 0ba80h

        dw 32h dup (?)
        stktop label word

STACK ENDS

;-----------------------------------------------------------------------------
;			ОПИСАНИЕ ВЫПОЛНЯЕМЫХ ДЕЙСТВИЙ
;-----------------------------------------------------------------------------
CODE SEGMENT
       assume ds:data,cs:code,ss:stack


CODE segment
assume cs:CODE,ds:DATA

;-----------------------------------------------------------------------------
;			ОПИСАНИЕ ПРОГРАММНЫХ МОДУЛЕЙ
;-----------------------------------------------------------------------------

Cor1 PROC NEAR

;коррекция 1-ой тетрады (младшей)
     mov ax,bin_dec
     and ax,0fh
     cmp ax,9
     jng c11
     add bin_dec,6h
     jmp c12
c11: mov ax,bin_dec
     and ax,010h
     cmp ax,0
     jz c12
     add bin_dec,6h

c12: ret

Cor1 ENDP

;--------------------------------------------------

Cor2 PROC NEAR

;коррекция 2-ой тетрады
     mov ax,bin_dec
     and ax,0f0h
     shr ax,4
     cmp ax,9
     jng c21
     add bin_dec,60h
     jmp c22
c21: mov ax,bin_dec
     and ax,0100h
     cmp ax,0
     jz c22
     add bin_dec,60h

c22: ret

Cor2 ENDP

;--------------------------------------------------

Cor3 PROC NEAR

;коррекция 3-ей тетрады
     mov ax,bin_dec
     and ax,0f00h
     shr ax,8
     cmp ax,9
     jng c31
     add bin_dec,600h
     jmp c32
c31: mov ax,bin_dec
     and ax,1000h
     cmp ax,0
     jz c32
     add bin_dec,600h

c32: ret

Cor3 ENDP

;--------------------------------------------------

Cor4 PROC NEAR

;коррекция 4-ой тетрады (старшей)
     mov ax,bin_dec
     and ax,0f000h
     shr ax,12
     cmp ax,9
     jng cc1
     add bin_dec,6000h

cc1: ret

Cor4 ENDP

;--------------------------------------------------
;преобразование двоичного числа в двоично-десятичное
;методом сдвига и коррекции
BinToBcd PROC NEAR

         mov bin_dec,0
         mov cx,16

         ;сдвиг
btb1:    shl bin_dec,1
         shl binary,1
         jnc btb0
         or bin_dec,1

btb0:    call Cor1 ;коррекция 1-ой тетрады (младшей)

         call Cor2 ;коррекция 2-ой тетрады

         call Cor3 ;коррекция 3-ей тетрады

         call Cor4 ;коррекция 4-ой тетрады (старшей)

         loop btb1 ;повторять пока не сдвинули все число

         ret

BinToBcd ENDP

;--------------------------------------------------

GetTime PROC NEAR
;взять текущее время
        mov ah,2ch
        int 21h

        ret

GetTime ENDP

;--------------------------------------------------

TicTime PROC NEAR
;задержка на 1 "тик" системного таймера
tt1:    call GetTime
        cmp CurTime,dl
        jz tt1

        ret

TicTime ENDP

;--------------------------------------------------

ConvToDisp PROC NEAR
           ;коррекция времени реакции (в"тиках") - для сохранения точности
           mov al,10
           mul MaxTime
           sub PressTime,ax

           ;преобразование времени реакции в секунды и доли секунд
           mov cx,0ffh
ctd1:      inc cx
           sub PressTime,182
           jns ctd1
           add PressTime,182

           mov binary1,cx
           mov ax,PressTime
           mov binary2,ax

           ret

ConvToDisp ENDP

;--------------------------------------------------

Correct_Sort_List PROC NEAR

                  mov Cur_sort_user,01h
                  mov Next_sort_user,02h

csl_lab:
                  call Create_offset   ;Запомним смещения в массиве List двух
                                       ;сравниваемых значений времени.
                  call Create_duplicate ;Сохраним в переменных аттрибутов срав-
                                        ;ниваемых пользователей
                  mov ax,word ptr Cur_user_time+2 ;"Первый" пользователь с ошибкой?
                  cmp ax,09h
                  jnz csl_lab2

                  call Exchange  ;обменять местами пользователей в массиве

csl_lab2:         mov ax,Next_sort_user
                  cmp Kol_users,ax
                  je csl_lab3
                  inc Next_sort_user
                  jmp csl_lab

csl_lab3:         mov ax,Cur_sort_user
                  inc ax
                  cmp Kol_users,ax
                  je csl_lab4

                  mov Cur_sort_user,ax
                  inc ax
                  mov Next_sort_user,ax
                  jmp csl_lab

csl_lab4:         ret

Correct_Sort_List ENDP

;--------------------------------------------------

Sort_List PROC NEAR

          mov Cur_sort_user,01h
          mov Next_sort_user,02h

sl_lab:
          call Create_offset ;Запомним смещения в массиве List двух
                             ;сравниваемых значений времени.

          call Create_duplicate ;Сохраним в переменных аттрибутов срав-
                                        ;ниваемых пользователей.

          mov ax,word ptr Cur_user_time+2
          cmp ax,word ptr Next_user_time+2
          jb sl_lab2
          ja sl_lab1
          mov ax,word ptr Cur_user_time
          cmp ax,word ptr Next_user_time
          jbe sl_lab2             ; Если дроб.часть1 <= дроб.части2

sl_lab1:  call Exchange

sl_lab2:  mov ax,Next_sort_user
          cmp Kol_users,ax
          je sl_lab3
          inc Next_sort_user
          jmp sl_lab

sl_lab3:  mov ax,Cur_sort_user
          inc ax
          cmp Kol_users,ax
          je sl_lab4

          mov Cur_sort_user,ax
          inc ax
          mov Next_sort_user,ax
          jmp sl_lab

sl_lab4:  ret

Sort_List ENDP

;--------------------------------------------------

Create_duplicate PROC NEAR

                 mov si,Cur_user_offset
                 mov ax,List[si].Time2
                 mov word ptr Cur_user_time,ax
                 mov ax,List[si].Time1
                 mov word ptr Cur_user_time+2,ax
                 mov ax,List[si].Number
                 mov Cur_sort_numb,ax

                 mov si,Next_user_offset
                 mov ax,List[si].Time2
                 mov word ptr Next_user_time,ax
                 mov ax,List[si].Time1
                 mov word ptr Next_user_time+2,ax
                 mov ax,List[si].Number
                 mov Next_sort_numb,ax

                 ret

Create_duplicate ENDP

;--------------------------------------------------

Create_offset PROC NEAR

              mov si,offset[List]
              mov ax,Cur_sort_user
              dec ax
              mov bx,type List
              mul bx
              add si,ax
              mov Cur_user_offset,si

              mov si,offset[List]
              mov ax,Next_sort_user
              dec ax
              mov bx,type List
              mul bx
              add si,ax
              mov Next_user_offset,si

              ret

Create_offset ENDP

;--------------------------------------------------

Exchange PROC NEAR

         mov si,Next_user_offset
         mov ax,word ptr [Cur_user_time]
         mov List[si].Time2,ax
         mov ax,word ptr [Cur_user_time+2]
         mov List[si].Time1,ax
         mov ax,Cur_sort_numb
         mov List[si].Number,ax

         mov si,Cur_user_offset
         mov ax,word ptr [Next_user_time]
         mov List[si].Time2,ax
         mov ax,word ptr [Next_user_time+2]
         mov List[si].Time1,ax
         mov ax,Next_sort_numb
         mov List[si].Number,ax

         ret

Exchange ENDP

;--------------------------------------------------

Count PROC NEAR

      ;подготовка
      mov MaxTime,91
      mov PressTime,910
      mov Errors,0
      mov Key_Press_,2

      ;остановка времени,если нажата кнопка "Press"
c2:   in al,0h
      cmp Key_Press_,al
      jz c1

      ;1 "тик" часов
      call GetTime
      mov CurTime,dl
      call TicTime

      dec MaxTime          ;осталось времени
      jnz c2               ;если осталось время на нажатие

      mov Errors,1h

c1:   call ConvToDisp ;преобразование времени реакции

      ret

Count ENDP

;--------------------------------------------------

Input_to_list PROC NEAR

              mov si,offset List

              mov ax,Cur_User_numb
              dec ax

              mov bx,type List
              mul bx

              add si,ax

              mov ax,Cur_User_numb
              mov List[si].Number,ax

              mov ax,binary1
              mov List[si].Time1,ax

              mov ax,binary2
              mov List[si].Time2,ax

              ret

Input_to_list ENDP

;--------------------------------------------------

Output_from_list PROC NEAR

                 mov si,offset List

                 mov ax,Cur_User_numb
                 dec ax

                 mov bx,type List
                 mul bx

                 mov si,ax

                 mov ax,List[si].Number
                 mov Users,ax

                 mov ax,List[si].Time1
                 mov binary1,ax

                 mov ax,List[si].Time2
                 mov binary2,ax

                 ret

Output_from_list ENDP

;--------------------------------------------------

Delay PROC NEAR
;Задержка 3 секунды и проверка фальстарта

          mov MaxTime,56
          mov Errors,0
          mov Key_Press_,2

          or Errors,2h
d2:       in al,0h
          cmp Key_Press_,al
          jz d1
          call GetTime
          mov CurTime,dl
          call TicTime
          dec MaxTime
          jnz d2
          and Errors,0fch

d1:       mov binary1,9
          mov binary2,999

          ret

Delay ENDP

;--------------------------------------------------

Out_to_ind PROC NEAR

           mov al,Ind_s
           add al,OneUser_flag            ;Вывести значение однопольз. реж.
           add al,MultyUser_flag          ;Вывести значение многопольз. реж.
           cmp Free_mode_flag,Ctrl_mode
           jnz Oti_lab
           add al,40h                     ;Вывести значение реж. контроля
           jmp Oti_lab2
Oti_lab:   cmp Free_mode_flag,Choose_mode
           jnz Oti_lab1
           add al,20h                     ;Вывести значение реж.выбора
           jmp Oti_lab2
Oti_lab1:  add al,10h                     ;Вывести значение реж.просмотра
Oti_lab2:  out 0,al

           ret

Out_to_ind ENDP

;--------------------------------------------------

Display_integer PROC NEAR

                mov bx,offset digits
                mov ax,binary1
                cmp ax,09h
                jne di_lab
                call Err_disp
                jmp di_lab1

di_lab:         xlat
                add al,80h
                out 4,al

di_lab1:        ret

Display_integer ENDP

;--------------------------------------------------

Display_user PROC NEAR

             mov bx,offset digits
             mov ax,Users
             xlat
             out 5,al

             ret

Display_user ENDP

;--------------------------------------------------

Display_numb_users PROC NEAR

             push ax
             push bx
             mov bx,offset digits
             mov ax,Numb_of_users
             xlat
             out 6,al
             pop bx
             pop ax

             ret

Display_numb_users ENDP


;--------------------------------------------------

Display_to PROC NEAR

           mov bx,binary1
           cmp bx,9
           je Disp_lab4

           mov ax,binary2
           mov binary,ax
           call BinToBCD

           mov bx,offset digits
           call MakeDigit
           mov dx,bin_dec
           shl dx,4
           mov cx,4
           mov al,0
Disp_lab1: shl dx,1
           rcl al,1
           loop Disp_lab1
           xlat
           out 3,al
           mov cx,4
           mov al,0
Disp_lab2: shl dx,1
           rcl al,1
           loop Disp_lab2
           xlat
           out 2,al
           mov cx,4
           mov al,0
Disp_lab3: shl dx,1
           rcl al,1
           loop Disp_lab3
           xlat
           out 1,al

Disp_lab4:

           ret

Display_to ENDP

;--------------------------------------------------

User_select PROC NEAR

            cmp Pl_Min_Us_flag,01h
            jne U_s_lab1
            cmp Numb_of_users,07h
            je U_s_lab2
            inc Numb_of_users
            jmp U_s_lab3
U_s_lab1:   cmp Pl_Min_Us_flag,02h
            jne U_s_lab2
            cmp Numb_of_users,02h
            je U_s_lab2
            dec Numb_of_users
U_s_lab3:   mov bx,Numb_of_users
            mov Users,bx
	    call Display_numb_users

U_s_lab2:   ret

User_select ENDP

;--------------------------------------------------

Err_disp PROC NEAR

         push ax
         mov al,E_letter
         out 4,al
         mov al,r_letter
         out 3,al
         out 2,al
         mov al,Dot_letter
         out 1,al
         pop ax

         ret

Err_disp ENDP

;--------------------------------------------------

One_user_prepare PROC NEAR

                 mov Free_mode_flag,Choose_mode
                 mov OneUser_flag,04h
                 mov MultyUser_flag,00h
                 mov Numb_of_users,01h
                 mov Cur_user_numb,01h
                 mov cx,Cur_user_numb
                 mov Users,cx
                 call Display_user
                 call Display_numb_users
                 mov al,Clear_Disp
                 out 1,al
                 out 2,al
                 out 3,al
                 out 4,al

                 ret

One_user_prepare ENDP

;--------------------------------------------------

Multy_user_prepare PROC NEAR

                   mov Free_mode_flag,Choose_mode
                   mov OneUser_flag,00h
                   mov MultyUser_flag,08h
                   mov Numb_of_users,02h
                   mov Cur_user_numb,01h
                   mov cx,Cur_user_numb
                   mov Users,cx
                   call Display_user
		   call Display_numb_users
                   mov al,Clear_Disp
                   out 1,al
                   out 2,al
                   out 3,al
                   out 4,al

                   ret

Multy_user_prepare ENDP

;--------------------------------------------------

Up_press PROC NEAR

         cmp Free_mode_flag,Choose_mode
         jne Up_lab2
         cmp MultyUser_flag,00h
         je Up_lab
         mov Pl_Min_Us_flag,01h
         call User_select
         jmp Up_lab

Up_lab2: cmp MultyUser_flag,00h
         je Up_lab

         cmp Cur_user_numb,01h
         jz Up_lab1
         dec Cur_user_numb
Up_lab1: call Output_from_list
         call Display_integer
         call Display_to
         call Display_user

Up_lab:  ret

Up_press ENDP

;--------------------------------------------------

Down_press PROC NEAR

           cmp Free_mode_flag,Choose_mode
           jnz Dwn_lab2
           cmp MultyUser_flag,00h
           jz Dwn_lab2
           mov Pl_Min_Us_flag,02h
           call User_select
           jmp Dwn_lab

Dwn_lab2:  cmp MultyUser_flag,00h
           jz Dwn_lab

           mov bx,Numb_of_users
           cmp bx,Cur_user_numb
           jz Dwn_lab1
           inc Cur_user_numb
Dwn_lab1:  call Output_from_list
           call Display_integer
           call Display_to
           call Display_user

Dwn_lab:   ret

Down_press ENDP

;--------------------------------------------------

Best_Press PROC NEAR

           cmp Free_mode_flag,Choose_mode
           jz Best_lab

           cmp MultyUser_flag,00h
           jz Best_lab

           mov Cur_user_numb,01h
           call Output_from_list
           call Display_integer
           call Display_to
           call Display_user

Best_lab:  ret

Best_Press ENDP

;--------------------------------------------------

Bad_Press PROC NEAR

           cmp Free_mode_flag,Choose_mode
           jz Bad_lab

           cmp MultyUser_flag,00h
           jz Bad_lab

           mov cx,Numb_of_users
           mov Cur_User_numb,cx

           call Output_from_list
           call Display_integer
           call Display_to
           call Display_user

Bad_lab:  ret

Bad_Press ENDP

;--------------------------------------------------

Next_User_Init PROC NEAR

               mov bx,Cur_User_Numb
               mov Users,bx
               call Display_user             ; Вывести текущего пользователя
               mov al,Clear_Disp             ; и очистить табло
               out 1,al
               out 2,al
               out 3,al
               out 4,al

               mov Ind_s,One_Ind_s
               call Out_to_Ind
               call Delay          ; Задержка 3 секунды и проверка фальстарта

               ret

Next_User_Init ENDP

;--------------------------------------------------

MakeDigit PROC NEAR

;Инициализация эл-тов массива Digits кодами цифр соответствующих номеру эл-та 

       mov digits[0],3fh
       mov digits[1],0ch
       mov digits[2],76h
       mov digits[3],5eh
       mov digits[4],4dh
       mov digits[5],5bh
       mov digits[6],7bh
       mov digits[7],0eh
       mov digits[8],7fh
       mov digits[9],5fh

       ret

MakeDigit ENDP

;--------------------------------------------------

Basic_prepare PROC NEAR

              mov Free_mode_flag,Choose_mode
              mov MultyUser_flag,00h
              mov OneUser_flag,04h
              mov Numb_of_users,01h
              mov Users,01h
              mov Ind_s,Zero_Ind_s
              mov Keys,00h

              ret
Basic_prepare ENDP

;--------------------------------------------------

Key_check PROC NEAR

kc_lab2:  call Out_to_ind

          in al,0      ;Взятие кода клавиши нажатой последней

          mov passive_kbd_flag,Active_kbd
          cmp Keys,al
          je kc_lab1          ;если передний фронт еще не сброшен
          cmp al,Active_kbd
          je kc_lab           ;кнопка отпущена поэтому сбросим передний фронт
          mov Keys,al         ;сохранение состояния кнопок

          cmp Free_mode_flag,Ctrl_mode ;Игнop.наж.кнопок в режиме контроля
          jz kc_lab6                   ;кроме кнопки "Готов".

          cmp al,OneUser_Btn       ;если была нажата кнопка"Один пользователь"
          jnz kc_lab5
          call One_user_prepare
          jmp kc_lab6

kc_lab5:  cmp al,MultyUser_Btn   ;если была нажата кнопка"Много пользователей"
          jnz kc_lab3
          call Multy_user_prepare
          jmp kc_lab6

kc_lab3:  cmp al,Up_btn               ;если была нажата кнопка"Вверх"
          jnz kc_lab4
          call Up_press
          jmp kc_lab6

kc_lab4:  cmp al,Down_btn            ;если была нажата кнопка"Вниз"
          jnz kc_lab10
          call Down_press
          jmp kc_lab6

kc_lab10: cmp al,Best_btn            ;если была нажата кнопка"Лучший"
          jnz kc_lab11
          call Best_press
          jmp kc_lab6

kc_lab11: cmp al,Bad_btn            ;если была нажата кнопка"Худший"
          jnz kc_lab6
          call Bad_press

kc_lab:   mov Keys,00h              ;если кл-ра неактивна (порт в нуле)
kc_lab1:  mov Passive_kbd_flag,Passive_kbd ;взведем флаг неакт.кл-ры
          mov al,Ready_btn

kc_lab6:  cmp al,Ready_btn          ;если была нажата кнопка"Готов"
          jne kc_lab2

kc_ret_lab: ret

Key_check ENDP

;-----------------------------------------------------------------------------

Free_mode_flag_prepare PROC NEAR

                       cmp Passive_kbd_flag,Passive_kbd
                       je fmfp_lab

                       cmp Free_mode_flag,Ctrl_mode
                       je fmfp_lab1
                       mov Cur_User_Numb,01h
                       mov Free_mode_flag,Ctrl_mode  ;Установка контр.режима
fmfp_lab1:
                       mov bx,Cur_User_Numb
                       mov Users,bx
                       call Display_user       ;Вывести текущего пользователя
                       mov al,Clear_Disp       ;и очистить табло
                       out 1,al
                       out 2,al
                       out 3,al
                       out 4,al

fmfp_lab:              ret

Free_mode_flag_prepare ENDP

;--------------------------------------------------

Press_processing PROC NEAR

                 cmp Passive_kbd_flag,Active_kbd
                 jne pp_lab1

                 mov Ind_s,One_Ind_s
                 call Out_to_Ind
                 call Delay      ; задержка 3 секунды и проверка фальстарта

                 cmp Errors,00h
                 jz pp_lab          ;Если фальстарта не было.
                 mov Ind_s,Zero_Ind_s
                 call Out_to_Ind
                 call Input_to_list
                 call Err_disp      ;Вывести на табло E.r.r.. .
                 jmp pp_lab1

pp_lab:          mov Ind_s,Three_Ind_s
                 call Out_to_Ind

                 call Count     ;Задержка 5 секунд и проверка нажатия на "Жму"

                 mov Ind_s,Zero_Ind_s
                 call Out_to_Ind

                 call Input_to_list     ;Занесем значение времени в список.

                 call Display_to        ; Отобразить дробную часть времени.
                 call Display_integer   ; Отобразить целую часть времени.

pp_lab1:         ret

Press_processing ENDP

;--------------------------------------------------

Check_for_last_user PROC NEAR

                    cmp Passive_kbd_flag,Passive_kbd
                    je cflu_lab

                    mov ax,Cur_User_numb
                    cmp Numb_of_users,ax      ; Это последний проверяемый
                    jne cflu_lab2             ; пользователь?

                    mov Free_mode_flag,Free_mode ;Это последний пользователь!!
                    mov Cur_User_Numb,00h

                    cmp MultyUser_flag,00h
                    je cflu_lab2
                    mov cx,Numb_of_users
                    mov Kol_users,cx
                    call Sort_List          ; Сортируем получившийся список.
                    call Correct_sort_list  ; Корректируем отсортированный
                                            ; список значениями ошибок.
cflu_lab2:          inc Cur_User_Numb       ; Берем следующего пользователя.

cflu_lab:           ret

Check_for_last_user ENDP


;-----------------------------------------------------------------------------
                           МАКРОУРОВЕНЬ ПРОГРАММЫ
;-----------------------------------------------------------------------------

begin: mov ax,data
       mov ds,ax
       mov ax,stack
       mov ss,ax
       mov sp,offset StkTop

       call MakeDigit               ;Подготовка массива с кодами цифр

       call Basic_prepare           ;Подготовка переменных и флагов

       call Display_user            ;Вывод исходного номера пользователя

       call Display_numb_users      ;Вывод исходного числа пользователей

       call Out_to_Ind              ;Вывод исходного состояния флагов и режима

macro_lab:

       call Key_check               ; Обработка нажатий на кнопки

       call Free_mode_flag_prepare  ; Вывести параметры следущего пользователя
                                    ; и очистить табло

       call Press_processing        ; Обработка результатов задержки и нажатия
                                    ; на кнопку "Жму"

       call Check_for_last_user     ; Проверка конца режима проверки

       jmp macro_lab

       org 07F0H
start: jmp begin

CODE ENDS
END start
