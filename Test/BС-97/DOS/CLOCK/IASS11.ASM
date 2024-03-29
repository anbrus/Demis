data  segment at 0B940H
       dig     db 0Ah dup (?)
       hour    db ?               ;���
       min     db ?               ;������
       sec     db ?               ;ᥪ㭤�
       bhour   db ?               ;��� �㤨�쭨��
       bmin    db ?               ;������ �㤨�쭨��
       tsec    db ?               ;��� �஢�ન ᥪ㭤 �� 㢥��祭��
       i_hour  db ?               ;"�����������" ��� �ᮢ
       i_min   db ?               ;�����     (FF-��� ��襭��,FE-��� "b")
       i_sec   db ?               ;ᥪ㭤
       button  db ?               ;00000001-०��, 00000010-��⠭��. 00000100-���.
       regim   db ?               ;00000001-���  00000010-�㤨�쭨�
       ring    db ?               ;䫠� ࠡ���饣� ������ 01-������
       rbyte   db ?               ;���� ������
       ringon  db ?               ;䫠� ����祭�� ������ 01-����祭
data ends

code segment
assume cs:code,ds:data



;-----------------------------------------
      CHANGE proc                     ;��楤�� ᬥ�� �६���
;----------------------------------------
       push  ax
       push  dx
       cmp   tsec,10
       jb    m1                ;�᫨ ᥪ㭤� �� ���������� � �� �����
       mov   tsec,00
       inc   sec
       cmp   sec,60
       jb    m4                ;�᫨ sec<60 -> m2
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
m4:    test  regim,00000001b  ;� ०��� �ᮢ ?
       jz    m1                ;���- �� ������ ��������
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
; ��楤�� ����প� �� 0.1 ᥪ.
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
; ��楤�� ᪠��஢���� ������
;--------------------------------------------
 INKEY proc
       push  ax
       in    al,00
       call  DELAY           ;����প� �����
       call  CHANGE
       mov   button,al
       cmp   ring,01
       je    in1
       mov   al,00
       out   06,al
       jmp   in2
in1:   ror   rbyte,01        ;�뫠 1 - �⠫ 0 � �������
       mov   al,rbyte
       out   06,al           ;�� ��������
in2:   pop   ax
       ret
 INKEY endp
;------------------------------------------
; ��楤�� ��⠭���� ०���
;------------------------------------------
 MODE  proc
       push  ax
       shl   regim,1
       cmp   regim,00000100b
       jnz   mo1
       mov   regim,01
 mo1:  test  regim,00000001b        ;��� ?
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
; ��楤�� ��⠭����
;-----------------------------------------
SET    proc
       push   ax
       test   regim,00000001b         ;� ��� ?
       jnz     se17
       jmp    se7                     ;��� - � �� �㤨�쭨�
se17:  mov    regim,00                ;����塞 䫠� ०����
       mov    i_min,0FFh              ;��� ��襭�� FFh
       mov    i_sec,0FFh              ;
       call   SHOW                    ;��ᨬ ������ � ᥪ㭤�
se3:   call   INKEY                   ;���訢��� �����
       cmp    button,00000010b        ;"��⠭����" ����� ?
       je     se1                     ;�᫨ ��, � �� se1
       cmp    button,00000100b        ;��� ?
       jne    se2
       inc    hour                    ;��- 㢥�. ���
       cmp    hour,24                 ;����� ��⮪ ?
       jb     se15                    ;�᫨ ���, � ��ଠ�쭮
       mov    hour,00                 ;�᫨ ��, � ����塞 ���
       jmp    se15
se2:   cmp    button,00000001b
       jne    se3
       dec    hour                    ;㬥���. ���
       cmp    hour,00
       jge    se15                    ;��� > ��� = 00 ?
       mov    hour,23                 ;��� ���뫠�� 23
se15:  mov    al,hour
       mov    i_hour,al
       call   SHOW                    ;������㥬 ���
       jmp    se3                     ;�� ���� �����
se1:   mov    i_hour,0FFh
       mov    al,min
       mov    i_min,al
       call   SHOW                    ;��ᨬ ���, �����. ������
se6:   call   INKEY
       cmp    button,00000010b        ;"��⠭����" ?
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
       call   SHOW                    ;�������� ������
       jmp    se6
se4:   mov    al,hour
       mov    i_hour,al
       mov    sec,00
       mov    i_sec,00
       call   SHOW                    ;����塞 ᥪ㭤� � �����. �६�
       mov    regim,01                ;����⠭�������� ०��
       jmp    se8                     ;�� �����
se7:   mov    i_min,0FFh
       mov    i_sec,0FEh
       mov    ringon,01               ;����砥� �㤨�쭨�
       mov    al,bhour
       mov    i_hour,al
       call   SHOW                    ;�����뢠�� �㤨�쭨�
se11:  call   INKEY
       cmp    button,00000010b        ;"��⠭����" ?
       je     se9                     ;�᫨ ��, � �� se9
       cmp    button,00000100b
       jne    se18
       inc    bhour
       cmp    bhour,24                ;����� ��⮪ ?
       jb     se10                    ;�᫨ ���, � ��ଠ�쭮
       mov    bhour,00                ;�᫨ ��, � ����塞 ���
       jmp    se10
se18:  cmp    button,00000001b
       jne    se11
       dec    bhour
       cmp    bhour,00
       jge    se10
       mov    bhour,23
se10:  mov    al,bhour
       mov    i_hour,al
       call   SHOW                    ;������㥬 ���
       jmp    se11                    ;�� ���� �����
se9:   mov    i_hour,0FFh
       mov    al,bmin
       mov    i_min,al
       call   SHOW                    ;��ᨬ ���, �����. ������
se14:  call   INKEY
       cmp    button,00000010b        ;"��⠭����" ?
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
       call   SHOW                    ;�������� ������
       jmp    se14
se12:  mov    al,bhour
       mov    i_hour,al
       call   SHOW
se8:   pop    ax
       ret
SET    endp

;-----------------------------------------
;��楤�� ������樨
;-----------------------------------------
SHOW   proc
       push   ax
       push   bx
       mov    bx,offset dig               ;� BX ���. ���� ⠡����
       cmp    i_sec,0FFh                  ;����� ?
       jne    sh1
       mov    al,00
       out    00,al
       out    01,al
       jmp    sh3
sh1:   cmp    i_sec,0FEh                  ;�������� "b" ("ob",�᫨ ���.)?
       jne    sh2
       mov    al,01111001b
       out    00,al                       ;�����뢠��
       mov    al,00
       cmp    ringon,01
       jne    sh8
       mov    al,01111000b
sh8:   out    01,al
       jmp    sh3
sh2:   mov    al,i_sec                    ;ࠧ����� �
       aam                                ;��������
       xlat                               ;�᫠ ᥪ㭤
       out    00,al
       mov    al,ah
       xlat
       out    01,al
sh3:   cmp    i_min,0FFh                  ;����� ������ ?
       jne    sh4
       mov    al,00
       out    02,al
       out    03,al
       jmp    sh5
sh4:   mov    al,i_min                    ;�����뢠�� ������
       aam
       xlat
       out    02,al
       mov    al,ah
       xlat
       out    03,al
sh5:   cmp    i_hour,0FFh                 ;����� ��� ?
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
;���./�몫. �㤨�쭨�
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
; ������������
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
       cmp   button,00000001b       ;����� ?
       jne   ma1
       mov   ring,00
       call  MODE
ma1:   cmp   button,00000010b       ;��⠭�� ?
       jne   ma2
       mov   ring,00
       call  SET
ma2:   cmp   button,00000100b       ;��� ?
       jne   ma3
       mov   ring,00
       call  VKL
ma3:   jmp   ma4
code ends
end start
