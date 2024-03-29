;                     旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;                     � 뤲�｀젹쵟 "뒕� 걵몤릣� ?"     �
;                     � 꺺承캙:   굫2-96              �
;                     � 묅蝨��瞬: 뜢��Л玎Ł �.�.     �
;                     �           뇿�逸ギ�   �.�.     �
;                     �           뜥え兒昔�  �.�.     �
;                     읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;
;
;-----------------------------------------------------------------------------
;                               럮닊�뜄� 뭹룑�
;-----------------------------------------------------------------------------

Player STRUC
       Number dw ?
       Time1  dw ?
       Time2  dw ?
Player ENDS


;-----------------------------------------------------------------------------
;                        럮닊�뜄� 룑닃뀓럟�뜊썢 뒑뜎��뜏
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
;                              럮닊�뜄� ��뜊썢
;-----------------------------------------------------------------------------

DATA SEGMENT at 0ba00h

     List      Player  7   dup  (<>)
     digits      db   128  dup  (?)

     Free_mode_flag   db  ?  ;눑좂��⑨: 2-誓┬� ぎ�循�ワ,
                             ;1- 誓┬� �濡��� 葉笹� ��レ�-ゥ�, 0-誓┬�
                             ;�昔細�循� 誓㎯レ�졻�� �젩�瞬 Л�．��レ�.誓┬쵟.
     OneUser_flag     db  ?  ;뵭젫 �젩�瞬 � �ㄽ���レ�.誓┬Д ˇ´ㄵ� �黍 =4.
     MultyUser_flag   db  ?  ;뵭젫 �젩�瞬 � Л�．��レ�.誓┬Д ˇ´ㄵ� �黍 =8.
     Pl_Min_us_flag   db  ?  ;뵭젫 瑟��./僧��. 葉笹� ��レ㎜쥯收ゥ� ��誓쩆β
                             ;1-�ヮ� Œ� 0-Ж�信 � �昔璵ㅳ說 UserSelect.
     Passive_kbd_flag db  ?  ;뵭젫 �쪧もÐ��� か-贍.

     Cur_user_offset  dw  ?  ;뫊ι��⑨ � 쵟遜Ð� List 收ゃ耀． � 笹ⅳ申ⅲ�
     Next_user_offset dw  ?  ;��レ㎜쥯收ゥ�.
     Cur_user_time  dd  ?    ;눑좂��⑨ Time1 & Time2 收ゃ耀． � 笹ⅳ申ⅲ�
     Next_user_time dd  ?    ;��レ㎜쥯收ゥ�.
     Cur_sort_numb  dw  ?    ;눑좂��⑨ Number 收ゃ耀． � 笹ⅳ申ⅲ�
     Next_sort_numb dw  ?    ;��レ㎜쥯收ゥ�.
     Num_for_sort   dw  ?    ;눑좂���� ��Д�� 收ゃ耀． 貰設ⓣ濕М． ��レ�-ワ.
     Kol_users      dw  ?    ;뒶�-¡ ��レ�-ゥ� ��誓쩆쥯�М� � Sort_List.
     Cur_sort_user  dw  ?    ;뜮Д�� � 쵟遜Ð� ㄲ愼 蓀젪�Ð젰щ�
     Next_sort_user dw  ?    ;��レ㎜쥯β�ゥ�.
     Keys           db  0    ;뺖젺ⓥ 飡졷�� ㎛좂���� 췅쬊瞬� か젪②(��設� ⇔�쩆).
     Ind_s          db  ?    ;룯誓쩆β 1-"꺇獸�",3-"꺇獸�"&"넭�" � Out_to_ind.
     Users          dw  ?    ;룯誓쩆β 葉笹� 0..9 � Display_User(ㄻ� �獸□. � "뜮Д� ��レ㎜쥯β�ワ").
     Numb_of_users  dw  ?    ;뫌ㄵ逝ⓥ 葉笹� ��レ�-ゥ� 1-� �ㄽ�.誓�. � 2..7 - � Л／�レ�.誓�.
     Cur_user_numb  dw  ?    ;뫌ㄵ逝ⓥ ��Д� 收ゃ�. ��レ㎜쥯收ワ.

     MaxTime        db  ?    ;뫌ㄵ逝ⓥ 쵟めº젷彛� ㄾ�信殊М� №�э 誓젶與�
     PressTime      dw  ?    ;뫌ㄵ逝ⓥ 쵟めº젷彛� ㄾ�信殊М� 稅�薛ⅹ殊昔쥯���� №�э 誓젶與�
     CurTime        db  ?    ;뫌ㄵ逝ⓥ 收ゃ耀� №�э (ㄾエ 醒ゃ��)
     Key_Press_     db  ?    ;뙛稅� 췅쬊殊� き��え "Press"
     Errors         db  ?    ;뵭젫 �鼇―� �젷藺�졷�� 0-"葉飡硫 飡졷�",2-�젷藺�졷� 兒席ⓣ濕恂� � Delay.

     binary1        dw  ?    ;뫌ㄵ逝졻 貰�手β飡´��� 璵ギ� � ㅰ�∼�� ㎛좂��⑨
     binary2        dw  ?    ;琠ワ正� �音�ㄽ臾� ��誓Д��臾� Count.
     binary         dw  ?    ;룯誓쩆β ㄲ�①��� 葉笹� � BinToBcd
     bin_dec        dw  ?    ;뫌ㄵ逝ⓥ ㄲ.-ㄵ�. 葉笹� - �音�ㄽ좑 ��誓�-좑 BinToBcd

DATA ENDS

;-----------------------------------------------------------------------------
;       			 럮닊�뜄� 몤뀏�
;-----------------------------------------------------------------------------

STACK SEGMENT at 0ba80h

        dw 32h dup (?)
        stktop label word

STACK ENDS

;-----------------------------------------------------------------------------
;			럮닊�뜄� 궀룑땷웷뙖� 꼨뎾뭳닀
;-----------------------------------------------------------------------------
CODE SEGMENT
       assume ds:data,cs:code,ss:stack


CODE segment
assume cs:CODE,ds:DATA

;-----------------------------------------------------------------------------
;			럮닊�뜄� 룓럠��뙆뜘� 뙉꼻땯�
;-----------------------------------------------------------------------------

Cor1 PROC NEAR

;ぎ薛ⅹ與� 1-�� 收循젮� (Й젮蜈�)
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

;ぎ薛ⅹ與� 2-�� 收循젮�
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

;ぎ薛ⅹ與� 3-ⅸ 收循젮�
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

;ぎ薛ⅹ與� 4-�� 收循젮� (飡졷蜈�)
     mov ax,bin_dec
     and ax,0f000h
     shr ax,12
     cmp ax,9
     jng cc1
     add bin_dec,6000h

cc1: ret

Cor4 ENDP

;--------------------------------------------------
;�誓�□젳�쥯��� ㄲ�①��． 葉笹� � ㄲ�①��-ㄵ碎殊嶺��
;Д獸ㄾ� 誠˘짛 � ぎ薛ⅹ與�
BinToBcd PROC NEAR

         mov bin_dec,0
         mov cx,16

         ;誠˘�
btb1:    shl bin_dec,1
         shl binary,1
         jnc btb0
         or bin_dec,1

btb0:    call Cor1 ;ぎ薛ⅹ與� 1-�� 收循젮� (Й젮蜈�)

         call Cor2 ;ぎ薛ⅹ與� 2-�� 收循젮�

         call Cor3 ;ぎ薛ⅹ與� 3-ⅸ 收循젮�

         call Cor4 ;ぎ薛ⅹ與� 4-�� 收循젮� (飡졷蜈�)

         loop btb1 ;��™�涉筍 ��첓 �� 誠˘�乘� ㏇� 葉笹�

         ret

BinToBcd ENDP

;--------------------------------------------------

GetTime PROC NEAR
;ˇ汀� 收ゃ耀� №�э
        mov ah,2ch
        int 21h

        ret

GetTime ENDP

;--------------------------------------------------

TicTime PROC NEAR
;쭬ㄵ逝첓 췅 1 "殊�" 歲飡�Л�． �젵Д��
tt1:    call GetTime
        cmp CurTime,dl
        jz tt1

        ret

TicTime ENDP

;--------------------------------------------------

ConvToDisp PROC NEAR
           ;ぎ薛ⅹ與� №�Д�� 誓젶與� (�"殊첓�") - ㄻ� 貰魚젺��⑨ 獸嶺�飡�
           mov al,10
           mul MaxTime
           sub PressTime,ax

           ;�誓�□젳�쥯��� №�Д�� 誓젶與� � 醒ゃ�ㅻ � ㄾエ 醒ゃ��
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
                  call Create_offset   ;뇿��Лº 細ι��⑨ � 쵟遜Ð� List ㄲ愼
                                       ;蓀젪�Ð젰щ� ㎛좂��Ł №�Д��.
                  call Create_duplicate ;뫌魚젺º � ��誓Д��音 졻循Æ呻�� 蓀젪-
                                        ;�Ð젰щ� ��レ㎜쥯收ゥ�
                  mov ax,word ptr Cur_user_time+2 ;"룯舒硫" ��レ㎜쥯收レ � �鼇―��?
                  cmp ax,09h
                  jnz csl_lab2

                  call Exchange  ;�＼��汀� Д飡젹� ��レ㎜쥯收ゥ� � 쵟遜Ð�

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
          call Create_offset ;뇿��Лº 細ι��⑨ � 쵟遜Ð� List ㄲ愼
                             ;蓀젪�Ð젰щ� ㎛좂��Ł №�Д��.

          call Create_duplicate ;뫌魚젺º � ��誓Д��音 졻循Æ呻�� 蓀젪-
                                        ;�Ð젰щ� ��レ㎜쥯收ゥ�.

          mov ax,word ptr Cur_user_time+2
          cmp ax,word ptr Next_user_time+2
          jb sl_lab2
          ja sl_lab1
          mov ax,word ptr Cur_user_time
          cmp ax,word ptr Next_user_time
          jbe sl_lab2             ; 끷エ ㅰ��.�졹筍1 <= ㅰ��.�졹殊2

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

      ;��ㄳ�獸˚�
      mov MaxTime,91
      mov PressTime,910
      mov Errors,0
      mov Key_Press_,2

      ;�飡젺�˚� №�Д��,αエ 췅쬊�� き��첓 "Press"
c2:   in al,0h
      cmp Key_Press_,al
      jz c1

      ;1 "殊�" �졹��
      call GetTime
      mov CurTime,dl
      call TicTime

      dec MaxTime          ;�飡젷�刷 №�Д��
      jnz c2               ;αエ �飡젷�刷 №�э 췅 췅쬊殊�

      mov Errors,1h

c1:   call ConvToDisp ;�誓�□젳�쥯��� №�Д�� 誓젶與�

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
;뇿ㄵ逝첓 3 醒ゃ�ㅻ � �昔´夕� �젷藺�졷��

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
           add al,OneUser_flag            ;귣´飡� ㎛좂���� �ㄽ���レ�. 誓�.
           add al,MultyUser_flag          ;귣´飡� ㎛좂���� Л�．��レ�. 誓�.
           cmp Free_mode_flag,Ctrl_mode
           jnz Oti_lab
           add al,40h                     ;귣´飡� ㎛좂���� 誓�. ぎ�循�ワ
           jmp Oti_lab2
Oti_lab:   cmp Free_mode_flag,Choose_mode
           jnz Oti_lab1
           add al,20h                     ;귣´飡� ㎛좂���� 誓�.�濡���
           jmp Oti_lab2
Oti_lab1:  add al,10h                     ;귣´飡� ㎛좂���� 誓�.�昔細�循�
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
               call Display_user             ; 귣´飡� 收ゃ耀． ��レ㎜쥯收ワ
               mov al,Clear_Disp             ; � �葉飡ⓥ� �젩ギ
               out 1,al
               out 2,al
               out 3,al
               out 4,al

               mov Ind_s,One_Ind_s
               call Out_to_Ind
               call Delay          ; 뇿ㄵ逝첓 3 醒ゃ�ㅻ � �昔´夕� �젷藺�졷��

               ret

Next_User_Init ENDP

;--------------------------------------------------

MakeDigit PROC NEAR

;댂ⓩ쯄エ쭬與� 姉-獸� 쵟遜Ð� Digits ぎ쩆Ж 與菴 貰�手β飡㏂迹ⓨ ��Д說 姉-�� 

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

          in al,0      ;궒汀�� ぎ쩆 か젪②� 췅쬊獸� ��笹ⅳ�ⅸ

          mov passive_kbd_flag,Active_kbd
          cmp Keys,al
          je kc_lab1          ;αエ ��誓ㄽŁ 菴��� ι� �� 聖昔蜈�
          cmp al,Active_kbd
          je kc_lab           ;き��첓 �琇申�췅 ��將�с 聖昔歲� ��誓ㄽŁ 菴���
          mov Keys,al         ;貰魚젺���� 貰飡�輾⑨ き����

          cmp Free_mode_flag,Ctrl_mode ;닧춐p.췅�.き���� � 誓┬Д ぎ�循�ワ
          jz kc_lab6                   ;む�Д き��え "꺇獸�".

          cmp al,OneUser_Btn       ;αエ 〓쳽 췅쬊�� き��첓"렎Þ ��レ㎜쥯收レ"
          jnz kc_lab5
          call One_user_prepare
          jmp kc_lab6

kc_lab5:  cmp al,MultyUser_Btn   ;αエ 〓쳽 췅쬊�� き��첓"뙪�． ��レ㎜쥯收ゥ�"
          jnz kc_lab3
          call Multy_user_prepare
          jmp kc_lab6

kc_lab3:  cmp al,Up_btn               ;αエ 〓쳽 췅쬊�� き��첓"궋�齧"
          jnz kc_lab4
          call Up_press
          jmp kc_lab6

kc_lab4:  cmp al,Down_btn            ;αエ 〓쳽 췅쬊�� き��첓"궘��"
          jnz kc_lab10
          call Down_press
          jmp kc_lab6

kc_lab10: cmp al,Best_btn            ;αエ 〓쳽 췅쬊�� き��첓"뗣預Ł"
          jnz kc_lab11
          call Best_press
          jmp kc_lab6

kc_lab11: cmp al,Bad_btn            ;αエ 〓쳽 췅쬊�� き��첓"뺛ㅸŁ"
          jnz kc_lab6
          call Bad_press

kc_lab:   mov Keys,00h              ;αエ か-�� �쪧もÐ췅 (��設 � �乘�)
kc_lab1:  mov Passive_kbd_flag,Passive_kbd ;ˇ´ㄵ� 氏젫 �쪧も.か-贍
          mov al,Ready_btn

kc_lab6:  cmp al,Ready_btn          ;αエ 〓쳽 췅쬊�� き��첓"꺇獸�"
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
                       mov Free_mode_flag,Ctrl_mode  ;볚�젺�˚� ぎ�循.誓┬쵟
fmfp_lab1:
                       mov bx,Cur_User_Numb
                       mov Users,bx
                       call Display_user       ;귣´飡� 收ゃ耀． ��レ㎜쥯收ワ
                       mov al,Clear_Disp       ;� �葉飡ⓥ� �젩ギ
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
                 call Delay      ; 쭬ㄵ逝첓 3 醒ゃ�ㅻ � �昔´夕� �젷藺�졷��

                 cmp Errors,00h
                 jz pp_lab          ;끷エ �젷藺�졷�� �� 〓ギ.
                 mov Ind_s,Zero_Ind_s
                 call Out_to_Ind
                 call Input_to_list
                 call Err_disp      ;귣´飡� 췅 �젩ギ E.r.r.. .
                 jmp pp_lab1

pp_lab:          mov Ind_s,Three_Ind_s
                 call Out_to_Ind

                 call Count     ;뇿ㄵ逝첓 5 醒ゃ�� � �昔´夕� 췅쬊殊� 췅 "넭�"

                 mov Ind_s,Zero_Ind_s
                 call Out_to_Ind

                 call Input_to_list     ;뇿�α�� ㎛좂���� №�Д�� � 召ⓤ��.

                 call Display_to        ; 롡�□젳ⓥ� ㅰ�∼莘 �졹筍 №�Д��.
                 call Display_integer   ; 롡�□젳ⓥ� 璵ャ� �졹筍 №�Д��.

pp_lab1:         ret

Press_processing ENDP

;--------------------------------------------------

Check_for_last_user PROC NEAR

                    cmp Passive_kbd_flag,Passive_kbd
                    je cflu_lab

                    mov ax,Cur_User_numb
                    cmp Numb_of_users,ax      ; 앪� ��笹ⅳ�Ł �昔´涉�щ�
                    jne cflu_lab2             ; ��レ㎜쥯收レ?

                    mov Free_mode_flag,Free_mode ;앪� ��笹ⅳ�Ł ��レ㎜쥯收レ!!
                    mov Cur_User_Numb,00h

                    cmp MultyUser_flag,00h
                    je cflu_lab2
                    mov cx,Numb_of_users
                    mov Kol_users,cx
                    call Sort_List          ; 뫌設ⓣ濕� ��ャ葉�鼇⒰� 召ⓤ��.
                    call Correct_sort_list  ; 뒶薛ⅹ殊說�� �恂�設ⓣ�쥯��硫
                                            ; 召ⓤ�� ㎛좂��⑨Ж �鼇‘�.
cflu_lab2:          inc Cur_User_Numb       ; 겈誓� 笹ⅳ莘耀． ��レ㎜쥯收ワ.

cflu_lab:           ret

Check_for_last_user ENDP


;-----------------------------------------------------------------------------
                           ��뒓럳릮굝뜙 룓럠��뙆�
;-----------------------------------------------------------------------------

begin: mov ax,data
       mov ds,ax
       mov ax,stack
       mov ss,ax
       mov sp,offset StkTop

       call MakeDigit               ;룼ㄳ�獸˚� 쵟遜Ð� � ぎ쩆Ж 與菴

       call Basic_prepare           ;룼ㄳ�獸˚� ��誓Д��音 � 氏젫��

       call Display_user            ;귣¡� ⓤ若ㄽ�． ��Д�� ��レ㎜쥯收ワ

       call Display_numb_users      ;귣¡� ⓤ若ㄽ�． 葉笹� ��レ㎜쥯收ゥ�

       call Out_to_Ind              ;귣¡� ⓤ若ㄽ�． 貰飡�輾⑨ 氏젫�� � 誓┬쵟

macro_lab:

       call Key_check               ; 렊�젩�洙� 췅쬊殊� 췅 き��え

       call Free_mode_flag_prepare  ; 귣´飡� 캙�젹β贍 笹ⅳ申ⅲ� ��レ㎜쥯收ワ
                                    ; � �葉飡ⓥ� �젩ギ

       call Press_processing        ; 렊�젩�洙� 誓㎯レ�졻�� 쭬ㄵ逝え � 췅쬊殊�
                                    ; 췅 き��ゃ "넭�"

       call Check_for_last_user     ; 뤲�´夕� ぎ��� 誓┬쵟 �昔´夕�

       jmp macro_lab

       org 07F0H
start: jmp begin

CODE ENDS
END start
