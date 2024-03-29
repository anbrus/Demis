;
; �P��P���� "������� �����"
; BC-2-96
; ����p�� �.�.    ����砥�� �.A.
;
; �p�������⥫� ����p�� �.�.
;
Name CodeLock
;����⠭��
        KbdPort1    =0   ; ��p� ����� 1 ��� 0..7
        KbdPort2    =1   ;            2 ��� 8,9,��P�� (001 010 100)
        Out7seg1    =2   ; 7ᥣ�. ��p� �뢮�� ���.
        Out7seg2    =3   ;  � �p��. ��p�
        OutInd      =4   ; �������� ���P��� � ����� (001 � 100)
        OutInCode   =5   ; �������� � �p���⨨ ��p ����
        TickTime    =18  ; �����.��p����� �p�����:
                         ;   18 c/⨪ ��� 1092 ���/⨪ (546 ������/⨪)
                         ;   36 2*c/⨪ ... (18.2->1c)
        TClev1      =3   ; �p������� �����.����.������ �� 1�p. - 1�
        TClevbeg2   =7   ; � ��砫� 2�� - 5�
        TClev2      =5   ; � �p��������� 2�� - 3�
        TCretry     =26  ; �p�����⮪ �� ��p����p㧪� ����⮪
                         ; TCretry>=TClev1*3+TClevbeg2+TClev2*2+1
        TClosed     =30  ; �६.����প� �� �⪠�� � ����㯥 (>=TCretry+1)
        TOpened     =30  ; �६.����প� �� ����⨥ ����    (>=TCretry+1)
        PuCo1       =00h ; �
        PuCo2       =02h ; �> ��� 1�� �p����:
        PuCo3       =03h ; �  0238 (������)
        PuCo4       =08h ; �

data segment at 0BA00h
 ;��p������:
  KbdIm      db 2 dup (?)  ;��p�� �����
  KbdLastIm  db 2 dup (?)  ;��p�� ��p�� �����
  FReset     db ?          ;�p��
  FClear     db ?          ;���⪠ ���� (��-�� ��������� ���)
  FReTry     db ?          ;��p����.��⮪
  InCode     db 5 dup (?)  ;⥪�騩 ���
  FLev       db ?          ;⥪�騩 �p�����
  FLastLev   db ?          ;�p����騩 �p�����
  FClose     db ?          ;�⪠�
  FOpen      db ?          ;��p��
  RandNum    db ?          ;���.�᫮
  TimeReTry  dw ?          ;�p��� ��� ��p���.����⮪ (c)
  TimeClick  dw ?          ;�p��� ����.������       (c)
  Digit      db ?          ;��p�
  FDigit     db ?          ;     � �� 䫠�
  Try        db ?          ;��⪨
  Code1      db 4 dup (?)  ;��� 1��� �p����
  Code2      db 3 dup (?)  ;2���
  FCorrect   db ?          ;��p�����
  FFPress    db ?          ;��p��� ����⨥
  Time       dw ?          ;⥪�饥 �p��� (�)
  Frelev     db ?          ;�p�� �p����
  DigImage db 10 dup (?)   ;����ࠦ���� ��� (��� �뢮��)
data ends


steack segment at 0BA80h
  db 200h dup (?)
  StkTop label word
steack ends ;+


code segment
  DigROM db 3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7Fh,5Fh
                                      ;����ࠦ���� ��� (��� �뢮��)
assume cs:code,ds:data,ss:steack

FormTime proc
; ��p��p������ �p����� (�� ⠩��p�)
       push ax   ;��p.p����
       push bx
       push cx
       push dx
        mov ah,0  ; �롮p �-樨 N0 �� p鸞 int1Ah
        int 1Ah   ; ����p��� � CX,DX �p��� � "⨪��" �� ��p� �����
        mov ax,dx ; ��p�� �,�� � dx
        xor dx,dx ; ��⨬ dx (��� �������)
        mov bx,TickTime ; �᫮ "⨪��" � ��.�p�����
        div bx          ; AX=AX/BX
        mov word ptr Time,ax ; ������ ��� ⥪��. �p���
       pop dx    ;�����.p����
       pop cx
       pop bx
       pop ax
   ret
FormTime endp ;+

Prepare proc
; H�砫쭠� �����⮢��
       push ax
       push si
       push di
       push cx
        mov byte ptr Code1[0],PuCo1    ; ��� 1�� �p���� = 0238
        mov byte ptr Code1[1],PuCo2    ;
        mov byte ptr Code1[2],PuCo3    ;
        mov byte ptr Code1[3],PuCo4    ;
        mov al,0
        mov byte ptr FFPress,al      ;��� ������
        mov byte ptr KbdLastIm[0],al ;����
        mov byte ptr KbdLastIm[1],al ;�� ���⥥
        mov byte ptr FLastLev,al     ;��᫥���� �p����� - ��p��
        mov byte ptr FLev,al         ;⥪�騩 �p����� - ��� � ��᫥���� - ��p��
        mov byte ptr FReset,al       ;��� �p��
        mov byte ptr FClose,al       ;�� ����p� �� �⪠�
        mov byte ptr FOpen,al        ;�� � �� ��p��
        mov byte ptr FReTry,al       ;�� ��p���⠭���. ����⪨
        mov byte ptr FClear,al       ;�� ����� ⥪��.���
        mov byte ptr FReLev,al       ;�� �p��뢠�� �p�����
        mov byte ptr FDigit,al       ;��� ��⮢�� ��p�
        mov byte ptr InCode[0],al ;�᫮ ��������� ��p = 0
        mov byte ptr FCorrect,al     ;��p����� �� ��⮢� (�� ��p����� �� ��-��p�����)
        mov al,2
        mov byte ptr Try,al          ;��� ����⪨
        mov al,0
        out 5,al             ;������塞���� ���� - ����� (=0)
        out 4,al             ;�� ��p�� �� � �� �⪠���� � ����㯥
        mov al,63h
        out 2,al             ; "F"
        mov al,31h
        out 3,al             ; "L"
        call FormTime        ;��p��p����� ⥪�饥 �p��� Time
        mov ax,word ptr Time
        mov word ptr TimeClick,ax ;
        mov word ptr TimeReTry,ax ;
                   ;����㧪� ����ࠦ���� ��� (��� �뢮��)

	mov	di,offset DigImage ;����뫪� ������ �� ��� (code segm)
	mov	si,offset DigRom   ; � ��� (data segment)
	mov	cx,10
next_di:
	mov	al,cs:[si]
	mov	ds:[di],al
	inc	di
	inc	si
	loop	next_di

       pop cx
       pop di
       pop si
       pop ax
 ret
Prepare endp ;+

KbdInput proc
; ���� � ��������p�
       push ax
       push bx
       push cx
       push dx
        in al,0          ;���� � ��p� 0
        mov dl,al        ; dl=�� ᮮ�.����樨(7,6,5,4,3,2,1,0)
        in al,1          ;���� � ��p� 1
        and al,07h
        mov dh,al        ; dh=(-,-,-,-,-,��P��,9,8)
        mov ax,dx        ;� dx ��⮢� ��p�� ��������p�
        mov bl,0
        mov cx,0Bh       ;�᫮ ��� ��p���
ki_1:   test ax,1        ;������ � bl �᫠ ������� ������
        jz ki_2          ;zf=0,�.�.��᫥���� p��p�=0
        inc bl           ;㢥����� �᫨ ���p�⨫��� 1
ki_2:   shr ax,1
        loop ki_1
        cmp bl,2
        jae ki_3          ;������ >= 2
        mov byte ptr KbdIm[0],dl  ;���.��p������� ��p���
        mov byte ptr KbdIm[1],dh
ki_3:  pop dx
       pop cx
       pop bx
       pop ax
 ret
KbdInput endp ;+

TimeSub proc
;����p�楤�p� p���� p������ �� �p�����
;��-�� � ImDecide, Pervonach � DelayDoor
;�p���� � ax ���祭�� TimeClick, TimeReTry (��� DelayDoor-�p��� ���.�����)
;Time ��p�� ᠬ�
;����p�頥� p������ � ax
       push dx
        mov dx,word ptr Time
        cmp ax,dx     ;�᫨ Time >= /��.���祭��/ � �����
        jbe ts_1       ;  ⠩��p �� ��襫 �� max � �� �������
        push ax       ;�᫨ ���㫨���: ���������� /��.���祭�e/
        mov ax,0ffffh ;�
        sub ax,dx     ;�>�饬 ����稭� ���-� �६��� (max-Time)+1
        inc ax        ;�
        pop dx        ;�ᯮ������ /��.���祭�e/
        add ax,dx ; p������ ax=(max-Time)+1+/��.���祭��/
        jmp ts_e
ts_1:   xchg ax,dx ;�᫨ �� ���㫨���
        sub ax,dx ; ax=Time-/��.���祭��/
ts_e:  pop dx
 ret
TimeSub endp ;+

ImDecide proc
; ��p���⪠ ��p��� ��������p� � ᮯ������饣�
       push ax
       push bx
       push cx
       push dx
        mov al,0
        mov FDigit,al   ;��� ��⮢�� ��p�
        mov FReset,al   ;��� �p��
        mov al,FFPress  ;��p��� ����⨥
        cmp al,0        ; ?
        jne id_1        ;  ���
        mov al,byte ptr KbdIm[0] ;  ��
        mov ah,byte ptr KbdIm[1]
        cmp ax,0        ;KbdIm=0 ? (����)
        jne id_1        ; ���
        mov al,0        ; ��
        mov FLastLev,0               ;��᫥���� �p.->����
        mov byte ptr KbdLastIm[0],al ;KbdLastIm=0
        mov byte ptr KbdLastIm[1],al
        mov ax,word ptr Time
        mov word ptr TimeClick,ax    ;TimeClick=Time
        jmp id_e        ;�� ��室
id_1:   mov al,0FFh
        mov byte ptr FFPress,al   ;��ࢮ� ����⨥ ᢥ�訫���
        mov ax,word ptr TimeClick ;���.�p��� ����. ������
        call TimeSub              ;� ax ��p����� p������� �� �p�����
        mov dl,byte ptr FLev
        cmp dl,0                  ;�p�����-?
        jne id_3                  ;�� ��ன
        cmp ax,TClev1             ;��� ��p���� �p. �������� - 1�
        jb id_4                   ;<1
id_2:     mov ax,word ptr Time    ;�p��� ��諮
          mov word ptr TimeClick,ax
          mov al,0
          mov byte ptr FLastLev,al     ;��᫥��.��.=����
          mov byte ptr FFPress,al      ;��ࢮ�� ������ �� �뫮
          dec al                       ;al=ffh
          mov byte ptr FReset,al       ;�㦥� ���
          mov al,byte ptr KbdIm[0]     ;KbdLastIm=KbdIm
          mov byte ptr KbdLastIm[0],al
          mov al,byte ptr KbdIm[1]
          mov byte ptr KbdLastIm[1],al
          jmp id_e ;�� ��室
id_3:   mov dl,byte ptr FLastLev
        cmp dl,0      ; FLastLev=0 ?
        je id_3_1     ;  ��
        cmp ax,TClev2 ;  ���, �������� - 3�
        jb id_4       ; <3
        jmp id_2      ; >=3
id_3_1: cmp ax,TClevbeg2
        jae id_2      ; >=5
id_4:   mov dl,byte ptr KbdLastIm[0] ;�p��� �� �� ��諮
        mov dh,byte ptr KbdLastIm[1] ;dx=KbdLastIm
        mov al,byte ptr KbdIm[0]
        mov ah,byte ptr KbdIm[1]     ;ax=KbdIm
        cmp ax,dx
        je id_7    ;�᫨ KbdIm=KbdLastIm
        cmp ax,0   ;
        je id_7    ;�᫨ KbdIm=0
        mov dx,ax  ;�㡫�p㥬 KbdIm � ax � dx
        test ah,4h ;�p���p�a ������ ��P�� ( 0000 0100 )
        jz id_5    ;�᫨ ��P��� ���
        mov al,0FFh
        mov byte ptr FReset,al   ;���.�.�p��
        inc al ;al=0
        mov byte ptr FLastLev,al ;��᫥���� �p����� - 1�
        jmp id_6
id_5:   mov al,0FFh              ;�᫨ �p�� ���:
        mov byte ptr FDigit,al   ;���.�.��⮢���� ��p�
        mov al,byte ptr FLev
        mov byte ptr FLastLev,al ;FLastLev=FLev
        mov ax,dx   ;ax=KbdIm
        mov cl,0    ;Digit=��p�, � cl �� ����p-���祭��
cif1:   test al,1   ;� ax ��易⥫쭮 ���� p��p� =1,
        jnz cif2    ;  ���� ��� ����-��������
        shr ax,1
        inc cl
        jmp cif1
cif2:   mov byte ptr Digit,cl        ;��p� ��⮢�
id_6:   mov ax,word ptr Time
        mov word ptr TimeClick,ax    ;TimeClick=Time
        mov ax,dx                    ;ax=dx=KbdIm
id_7:   mov byte ptr KbdLastIm[0],al ;KbdLastIm=KbdIm
        mov byte ptr KbdLastIm[1],ah
id_e:  pop dx
       pop cx
       pop bx
       pop ax
 ret
ImDecide endp ;+

Pervonach proc
; �p�������� ��p����砫쭮�� ���ﭨ�
       push ax
        mov al,0
        mov byte ptr FReTry,al ; �
        mov byte ptr FClear,al ; �
        mov byte ptr FReLev,al ; ��>���㫥���
        mov al,byte ptr FReset
        cmp al,0
        jne p_1               ;FReset <> 0 ���
        mov al,byte ptr FClose
        cmp al,0
        jne p_1               ;FClose <> 0 ���
        mov al,byte ptr FOpen
        cmp al,0
        jne p_1               ;FOpen <> 0 ,����: Ŀ
        mov al,byte ptr FCorrect  ;              <��
        cmp al,0Fh                ;
        je p_2                    ;�뫠 ����⪠ ����� ������ ��� 1�� ��.
        mov ax,word ptr TimeReTry ;
        call TimeSub ;����p.p������ ax=Time-TimeReTry
        cmp ax,TCretry ;�p��� ��p�������� ?
        jb p_e         ; <15c-���
        mov al,0FFh
        mov byte ptr FReTry,al    ;���.䫠�� ��� ��p�����⪨
p_1:    mov al,0FFh
        mov byte ptr FReLev,al    ;��.�.��⠭���� 1�� �p����
p_2:    mov al,0FFh
        mov byte ptr FClear,al    ;���.�.���⪨
        mov ax,word ptr Time
        mov word ptr TimeReTry,ax ; TimeReTry=Time
p_e:   pop ax
 ret
Pervonach endp ;+

FormCode proc
; ��p��p������ ���� (���������)
       push ax
       push bx
        mov al,byte ptr FClear
        cmp al,0
        je fc_1 ;��� ���⪨
        mov al,0
        mov byte ptr InCode[0],al ;���⪠
        jmp fc_e
fc_1:   mov al,byte ptr FLev
        cmp al,0
        je fc_2  ;�᫨ 1� �p.
        mov al,byte ptr InCode[0]
        cmp al,4
        jne fc_2 ;� ���� <4 ��p
        mov al,0 ;�᫨ 2� �p. � 4 ��p�,� ��⨬
        mov byte ptr InCode[0],al
fc_2:   mov al,byte ptr FDigit
        cmp al,0
        je fc_e   ;��p� �� ��⮢�
        mov bx,1  ;��p� ��⮢�
        add bl,byte ptr InCode[0]
        mov byte ptr InCode[0],bl ;InCode[0]=InCode[0]+1
        mov al,byte ptr Digit
        mov InCode[bx],al        ;InCode[InCode[0]+1]=��p�
fc_e:  pop bx
       pop ax
 ret
FormCode endp ;+

Comparator proc
; �p������� �����
       push ax
       push bx
       push cx
        mov al,0
        mov byte ptr FCorrect,al  ;FCorrect �����.�
        mov byte ptr FClose,al    ;�� �⪠�       �>���.���.
        mov byte ptr FOpen,al     ;�� ��p��     �
        mov al,byte ptr Try       ;al=����⪨
        cmp al,0
        je c_3                    ;�� �⪠�
        mov al,byte ptr FLev
        cmp al,0
        je c_1                    ;if �p�����=1�
        mov al,byte ptr InCode[0] ;�᫮ ��������� ��p ����
        cmp al,3
        jne c_e                   ;������p
         mov cx,3                 ;�p������� ����� 2�� �p.� ����������
         mov bx,0
c_l1:    mov al,byte ptr Code2[bx]   ;��p� ��p���� ����
         inc bx
         mov ah,byte ptr InCode[bx]  ;��p� ���������� ����
         cmp al,ah                   ;�p�������� ��
         jne c_3                     ;�� �⪠�,�.�.��� �� ᮢ���
         loop c_l1
        mov al,0FFh
        mov byte ptr FOpen,al     ;��p��
        jmp c_e                   ;�� �����
c_1:    mov al,byte ptr InCode[0] ;��� 1�� �p.
        cmp al,4                  ;�p���p�� �᫠ ��������� ��p
        jne c_e                   ;�� ��室
         mov cx,4                 ;�p������� ����� 1�� �p.� ����������
         mov bx,0
c_l2:    mov al,byte ptr Code1[bx]   ;��p� ��p���� ����
         inc bx
         mov ah,byte ptr InCode[bx]  ;��p� ���������� ����
         cmp al,ah                   ;�p�������� ��
         jne c_2                     ;������ ����p�� ��� 1�� �p.
         loop c_l2
        mov al,0F0h
        mov byte ptr FCorrect,al  ;��� ��p��!
        jmp c_e                   ;�� �����
c_2:    mov al,byte ptr Try
        cmp al,1
        jbe c_3                   ;��� �� ��p��,�� � ����⮪ �� ��⠫���...
        mov al,0Fh
        mov byte ptr FCorrect,al  ;��� ����p��,�� �� ���� 蠭� ���������
        jmp c_e                   ;�� �����
c_3:   mov al,0FFh
       mov byte ptr FClose,al ;O⪠�!
c_e:   pop cx
       pop bx
       pop ax
 ret
Comparator endp ;+

Form2LC proc
; ��p��p������ �p����쭮�� ���� 2�� �p����
       push ax
       push bx
       push cx
       push dx
        mov al,byte ptr FLev
        cmp al,0
        jne f2_e     ; E᫨ 2� �p.(㦥 �뫮 �p��p-�)
        mov al,byte ptr FCorrect
        cmp al,0F0h
        jne f2_e     ; E᫨ ����p�� ���� ��� ��� �� ��⮢
        mov ah,0     ; �롮p �-樨 0 �� p鸞 int1Ah
        int 1Ah      ; ����p��� � CX,DX �p��� � "⨪��" �� ��p� �����
        mov ax,dx    ; ��p�� �,�� � dx
        and ax,00FFh ;   ��p��� - � dl (0..255)
        mov cl,64h   ; 64h=100
        div cl       ; ����� �� 100 � ��p�� ���⮪ (�� � ah)
        mov cl,8
        shr ax,cl    ; ax=���⮪ - ���.10e �᫮ (0..99)
        mov cl,0Ah   ; 0Ah=10
        div cl       ; � al ��p�� ���.��p�,� � ah ������
        mov cl,4     ;    �� �� �� ᢮�� ������� �� BCD
        shl al,cl
        xor al,ah    ;᪫��뢠�� � ���.�᫮
        mov byte ptr RandNum,al ;P������-���.�᫮ �� 00 �� 99
        shr al,cl    ;� al � ah ��� ����: a � b
        mov dx,ax    ;���������� � p��� ��� ����p�����⢨� ���᫥���  ����Ŀ
        add al,ah    ;a+b                                                   �
        aaa          ;��pp���� ASCII, � al - ��᫥���� ��pa               �
        mov byte ptr Code2[0],al ;��p��� ��p� ���� 2�� �p. 0000**** (ASCII)�
        mov ax,dx    ;�⮡ �� ��p.� RandNum � �� ᤢ����� ��� p������ ��p<��
        mul ah       ;a*b
        aam          ;��pp���� ASCII
        mov byte ptr Code2[1],al ;��p�� ��p� ���� 2�� �p. 0000**** (ASCII)
        mov ax,dx
        cmp al,ah
        ja f2_1      ;�᫨ 㬥��蠥��� > ���⠥����
        xchg al,ah   ;  ���� ���塞 �� ���⠬�
f2_1:   sub al,ah    ;�a-b�
        aas          ;��pp���� ASCII
        mov byte ptr Code2[2],al ;3� ��pa ���� 2�� �p. 0000**** (ASCII)
f2_e:  pop dx
       pop cx
       pop bx
       pop ax
 ret
Form2LC endp ;+

LevTry proc
; ��p�������� �p���� � ����⮪
       push ax
        mov al,byte ptr FReTry
        cmp al,0
        jne lt_1
        mov al,byte ptr Try
        cmp al,0
        je lt_1
        mov al,byte ptr FClose
        cmp al,0
        jne lt_1
        mov al,byte ptr FOpen
        cmp al,0
        jne lt_1
        jmp lt_2 ;�� ��p�����⪠,�� ����⪨ �� ����
lt_1:   mov al,2 ;        ����
        mov byte ptr Try,al  ;���.����⮪
lt_2:   mov al,byte ptr FReLev
        cmp al,0             ;��p����.�p����� � 1� ?
        je lt_3              ;���
        mov al,0
        mov byte ptr FLev,al ;��,���.1� �p.
lt_3:   mov al,byte ptr FCorrect ;��� ⠬ � ��p������ ���������� ?
        cmp al,0
        je lt_e              ;�� ��p����� �p���p��� p���
        cmp al,0F0h
        je lt_4              ;��p�� ���!
        mov al,byte ptr Try
        dec al
        mov byte ptr Try,al  ;����p�� ���, Try=Try-1
        jmp lt_e             ;�� �����
lt_4:   mov al,0FFh
        mov byte ptr FLev,al ;2� �p.
        mov al,1
        mov byte ptr Try,al  ;���� ����⪠
lt_e:  pop ax
 ret
LevTry endp ;+

OutVisual proc
; �뢮� �� ����� (��������)
       push ax
       push bx
       push cx
       push dx
        mov al,byte ptr FLev
        cmp al,0
        jne ou_2                  ;��� 2�� �஢��
        xor ax,ax                 ; ���� ��� 1�� - ������.'�롮�'
        out OutInCode,al          ;���⪠ ��। �뢮��� <-------
        mov al,byte ptr InCode[0] ;�����.ᬥ饭��
        lea bx,ou_b1              ;���� ��砫� ����� ᥫ���� - ���� b1
        mov cl,3                  ;�
        shl ax,cl                 ;��> *8(�᫮ �祥� ����) = ᬥ饭��
        add ax,bx                 ;�ନ�.����筮�� ���� ���� (����+ᬥ�)
        jmp ax
ou_b1:  mov al,00h        ;2byte � �� InCode[0]=0
        out OutInCode,al  ;2b    �
        jmp ou_1          ;3b    �>8byte - 8 �祥�
        nop               ;1b    �
        mov al,40h        ;�� =1
        out OutInCode,al  ;
        jmp ou_1          ;
        nop               ;
        mov al,60h        ;�� =2
        out OutInCode,al  ;
        jmp ou_1          ;
        nop               ;
        mov al,70h        ;�� =3
        out OutInCode,al  ;
        jmp ou_1          ;
        nop               ;
        mov al,78h        ;�� =4   ����� ��᫥����� ���� �� ���.8 ����
        out OutInCode,al  ;         �.�.�� ��� ����� ���
ou_1:   mov al,63h        ; 'F'
        out Out7seg1,al    ;
        mov al,31h        ; 'L'
        out Out7seg2,al    ;
        jmp ou_4
ou_2:   xor ax,ax                 ;2� �஢��� - ������.'�롮�'
        out OutInCode,al          ;���⪠ ��। �뢮��� <-------
        mov al,byte ptr InCode[0] ;�����.ᬥ饭��
        lea bx,ou_b2              ;���� ��砫� ����� ᥫ���� - ����
        mov cl,3                  ;�
        shl ax,cl                 ;��> *8(�᫮ �祥� ����) - ᬥ饭��
        add ax,bx                 ;�ନ�.����筮�� ���� ����
        jmp ax
ou_b2:  mov al,78h        ;�� InCode[0]=0
        out OutInCode,al  ;
        jmp ou_3          ;
        nop               ;
        mov al,7Ch        ;�� =1
        out OutInCode,al  ;
        jmp ou_3          ;
        nop               ;
        mov al,7Eh        ;�� =2
        out OutInCode,al  ;
        jmp ou_3          ;
        nop               ;
        mov al,7Fh        ;�� =3
        out OutInCode,al  ;
ou_3:   mov bx,offset DigImage  ;����砥� ���� ���ᨢ� �����-� ���
        mov al,byte ptr RandNum ;�뢮� ���.�᫠
        and ax,000Fh      ;��⠢�塞 ��᫥���� ���� (2�) ��� �뢮��
        xlat              ;����砥� ᮮ�-� ��� �� �� ������-���祭��
        out Out7seg2,al   ;  � �뢮���
        mov al,byte ptr RandNum
        and ax,00F0h      ;��⠢�塞 ����� ���� (1�) ��� �뢮��
        mov cl,4
        shr al,cl         ;����� �� 10 (� BCD ����)
        xlat
        out Out7seg1,al
ou_4:   mov al,0
        out OutInd,al  ;���⪠ ��। �뢮��� <-------
        mov al,byte ptr FOpen ;�஢�ઠ �� ��������
        cmp al,0
        je ou_5        ;�� �� ������
        mov al,01h     ;�����!
        out OutInd,al
        mov al,3Bh     ;'G'
        out Out7seg1,al ;��뢠�� �᫮-�����
        mov al,3Fh     ;'O'
        out Out7seg2,al
        jmp ou_e       ;�� �����
ou_5:   mov al,byte ptr FClose ;�஢�ઠ �� �⪠�
        cmp al,0
        je ou_6        ;� ����㯥 �� �� �⪠����
        mov al,04h     ;�⪠����! ����� ��ᠤ�...
        out OutInd,al
        mov al,31h     ;'L'
        out Out7seg1,al ;��뢠�� �᫮-�����
        mov al,3Fh     ;'O'
        out Out7seg2,al
        jmp ou_e       ;�� �����
ou_6:   xor al,al      ;���㫥���
        out OutInd,al  ;�� ����� �� � �� �⪠�
ou_e:  pop dx
       pop cx
       pop bx
       pop ax
 ret
OutVisual endp ;+

DelayDoor proc
;�p������� ����p��� ��� ���p�
       push ax
       push bx
       push cx
       push dx
        mov al,byte ptr FClose
        cmp al,0
        je dd_1              ;�� �⪠�
        mov dx,word ptr Time ;�⪠�, ���������� �p��� ��砫� ����p���
dd_cc:  call FormTime        ;�p��p.⥪�饥 �p���
        mov ax,dx            ;�p��� ��砫� ����p���
        call TimeSub         ;�p�������� � ⥪�騬 �p������ (p�������)
        cmp ax,TClosed       ;
        jae dd_e             ;�p��� ����p��� ���稫���
        jmp dd_cc            ;��横������ �᫨ ���
dd_1:   mov al,byte ptr FOpen
        cmp al,0
        je dd_e              ;�� ��p��
        mov dx,word ptr Time ;��p��, ���������� �p��� ��砫� ����p���
dd_co:  call FormTime        ;�p��p.⥪�饥 �p���
        mov ax,dx            ;�p��� ��砫� ����p���
        call TimeSub         ;�p�������� � ⥪�騬 �p������ (p�������)
        cmp ax,TOpened       ;
        jb dd_co             ;��横������ �᫨ �p��� ����p��� �� ���稫���
dd_e:  pop dx
       pop cx
       pop bx
       pop ax
 ret
DelayDoor endp ;+

begin:  mov ax,steack    ;���樠������ ��. ��p�ᮢ
        mov ss,ax
        mov sp,offset StkTop
        mov ax,data
        mov ds,ax

        call Prepare    ; ��p����砫�� ��⠭���� - �����⮢��
Conti:  call KbdInput   ; ���� � ��������p�
        call ImDecide   ; ��p���⪠ ��p��� ��������p� � ᮯ������饣�
        call Pervonach  ; �p�������� ��p����砫쭮�� ���ﭨ�
        call FormCode   ; ��p��p������ ���� (���������)
        call Comparator ; �p������� �����
        call Form2LC    ; ��p��p������ �p����쭮�� ���� 2�� �p����
        call LevTry     ; ��p�������� �p���� � ����⮪
        call OutVisual  ; �뢮� �� ����� (��������)
        call DelayDoor  ; �p������� ����p��� ��� ���p�
        call FormTime   ; ��p��p������ �p����� (�� ⠩��p�)
        jmp Conti       ;

        org 07F0h
start: jmp begin
code ends

end start