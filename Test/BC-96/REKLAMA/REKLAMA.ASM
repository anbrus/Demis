page 50,120

      ;�ணࠬ�� ࠡ��� ���ன�⢠ �ࠢ����� ᢥ⮢�� ४�����

                        NAME LigthReklama

      ;���ᠭ�� ������
Data1 segment at 0ba00h

      ;���ᠭ�� �㦥���� ������
      codes    db  14 dup (?)
      addrr&p  dw  ?
      datakbd  db  ?
      olddata0 db  ?
      olddata1 db  ?
      oldtype  db  ?

      ;���ᠭ�� 䫠���
      clean    db  ?
      endin    db  ?
      endr     db  ?
      follr    db  ?
      loading  db  ?
      mode     db  ?
      nokbd    db  ?
      ok       db  ?
      switch   db  ?
      typectrl db  ?
      typed    db  ?
      typers   db  ?

      ;���ᠭ�� ���稪��
      cnt      dw  ?
      cntdp    dw  ?
      cntp     dw  ?
      cntr     db  ?
      cntrek   dw  ?

      ;���ᠭ�� �������஢����� ������
      report1  db  20 dup (?)
      report2  db  20 dup (?)
      report3  db  20 dup (?)
      decprice db  6 dup (?)
      price1   db  2 dup (?)
      price2   db  2 dup (?)
      price3   db  2 dup (?)
      amount   db  3 dup (?)
      reklama  db  252 dup (?)
Data1 ends

      ;���ᠭ�� �⥪�
Stack1 segment at 0ba80h
               db 512 dup (?)
      stktop   label word
Stack1 ends

      ;���ᠭ�� �믮��塞�� ����⢨�
Code1 segment
      assume cs:Code1,ds:Data1,ss:Stack1

      ;���ᠭ�� �ணࠬ���� ���㫥�

;����� "���樠������ ⠡���� �����"
InitCodes proc near
       mov codes[0],3fh  ;"0"
       mov codes[1],0ch  ;"1"
       mov codes[2],76h  ;"2"
       mov codes[3],5eh  ;"3"
       mov codes[4],4dh  ;"4"
       mov codes[5],5bh  ;"5"
       mov codes[6],7bh  ;"6"
       mov codes[7],0eh  ;"7"
       mov codes[8],7fh  ;"8"
       mov codes[9],5fh  ;"9"
       mov codes[10],73h ;"E"
       mov codes[11],67h ;"P"
       mov codes[12],6fh ;"R"
       mov codes[13],60h ;"r"
       mov ok,1
       ret
InitCodes endp

;����� "�����⮢�� � �����"
GetStart proc near
       cmp ok,1
       jnz gs1
       mov al,0ch
       out 1,al
       mov si,0eh
       mov cx,0b8h
gs2:   mov word ptr [si],0
       add si,2
       loop gs2
       mov nokbd,1
       mov cntr,1
       mov cntrek,1
gs1:   ret
GetStart endp

;1. ����� "���� ०����"
InputMode proc near
       in al,1
       cmp al,4      ;��ࠡ�⪠
       jnz im1       ;�����
       mov mode,0    ;०���
       mov ok,1      ;"����"
       mov clean,1
       mov endin,0
       jmp im2
im1:   cmp al,32     ;��ࠡ�⪠
       jnz im2       ;�����
       mov mode,1    ;०���
       mov loading,1 ;"�뢮�"
im2:   ret
InputMode endp

;2. ����� "���� ⨯� ������"
InputType proc near
       cmp mode,0
       jnz it1
       cmp endin,0
       jnz it1
       in al,1
       cmp al,oldtype ;����
       jz it1         ;�� ����୮��
       mov oldtype,al ;������
       cmp al,8       ;��ࠡ�⪠
       jnz it2        ;�����
       mov typed,1    ;⨯� ������
       mov typectrl,1 ;"����"
       jmp it3
it2:   cmp al,10h     ;��ࠡ�⪠
       jnz it1        ;�����
       mov typed,0    ;⨯� ������
       mov follr,1    ;"����饭��"
it3:   mov endr,0
       mov clean,1
it1:   ret
InputType endp

;3. ����� "����஫� �� ������� ᮮ�饭���"
CtrlReport proc near
       cmp mode,0
       jnz cre1
       cmp endin,0
       jnz cre1
       cmp typectrl,0 ;�஢�ઠ
       jnz cre3       ;"����� ᮮ�饭��?"
       cmp cnt,14h
       jnz cre1
       mov endr,1
cre3:  mov typectrl,0
       mov cnt,0
       mov al,3       ;�।�०�����
       out 0,al       ;� ���� ᮮ�饭��
       mov cx,2ffh    ;�� ����筮�
cre2:  nop            ;��������
       loop cre2
       mov al,1
       out 0,al
cre1:  ret
CtrlReport endp

;4. ����� "����஫� �� �������� 業��"
CtrlPrice proc near
       cmp mode,0
       jnz cp1
       cmp endin,0
       jnz cp1
       cmp cntp,2  ;�஢�ઠ
       jnz cp1     ;"����� ����� 業�?"
       mov endr,1
       mov cntp,0
cp1:   ret
CtrlPrice endp

;5. ����� "���⪠ ��ᯫ��"
Cleaning proc near
       cmp clean,1
       jnz c2
       mov al,0    ;���⪠
       mov dx,2    ;�����ࠧ�來���
       mov cx,10   ;�����ᨭ⥧����饣�
c1:    out dx,al   ;��ᯫ��
       inc dx
       loop c1
       cmp mode,1  ;�᫨ ०�� "�뢮�",� ���⪠
       jnz c3      ;ᥬ�ᥣ���⭮�� �����ᨭ⥧����饣�
       out 1,al    ;�������� "����� ᮮ�饭��"
c3:    mov clean,0
c2:    ret
Cleaning endp

;6. ����� "���� ᮮ�饭�� � 業�"
InputR&P proc near
       cmp mode,0
       jnz erc7
       cmp endin,0
       jnz erc7
       cmp endr,0
       jnz erc7
       mov cl,0ffh
       in al,0
       cmp al,olddata0 ;����
       jz erc2         ;�� ����୮��
       mov olddata0,al ;������
       cmp al,0        ;��ࠡ�⪠
       jz erc2         ;����
erc1:  inc cl          ;�����
       shr al,1        ;� ����஬ 0
       jnc erc1
       mov al,cl
       jmp erc4
erc2:  in al,1
       cmp al,olddata1 ;����
       jz erc5         ;�� ����୮��
       mov olddata1,al ;������
       cmp al,1        ;��ࠡ�⪠
       jnz erc3        ;����
       mov al,8        ;�����
       jmp erc4        ;� ����஬ 1
erc3:  cmp al,2
       jnz erc5
       mov al,9
erc4:  mov datakbd,al
       mov nokbd,0
       cmp typed,1
       jnz erc7
       lea si,decprice
       add si,cntdp
       mov [si],al
       inc cntdp
       jmp erc7
erc5:  mov nokbd,1
erc7:  ret
InputR&P endp

;7. ����� "��ନ஢���� ᮮ�饭�� � 業�"
ShapingR&P proc near
       cmp mode,0
       jnz srp3
       cmp endin,0
       jnz srp3
       cmp endr,0
       jnz srp3
       cmp nokbd,0
       jnz srp3
       cmp typed,0    ;����㧪�
       jnz srp4       ;����室����
       lea si,report1 ;��ࠬ��஢,
       lea di,cnt     ;� ����ᨬ���
       mov dx,14h     ;�� ⨯� ������
srp4:  cmp typed,1
       jnz srp5
       lea si,price1
       lea di,cntp
       mov dx,2
srp5:  cmp cntr,2     ;�஢�ઠ
       jnz srp1       ;�����
       add si,dx      ;ᮮ�饭��
       jmp srp2       ;� ���४�஢��
srp1:  cmp cntr,3     ;��ࠬ��஢
       jnz srp2
       add dx,dx
       add si,dx
srp2:  mov addrr&p,si ;���࠭���� ���� ���ᨢ�
       mov al,datakbd ;��ନ஢����
       mov cx,[di]    ;���ᨢ�
       xlat           ;�⮡ࠦ����
       add si,cx
       mov [si],al
       inc cx
       mov [di],cx
srp3:  ret
ShapingR&P endp

;8. ����� "�뢮� ᮮ�饭�� ErrP"
OutNoPrice proc near
       cmp mode,0
       jnz onp1
       cmp endin,0
       jnz onp1
       cmp follr,1
       jnz onp1
       mov si,addrr&p
       cmp si,offset price1
       jnb onp1
       mov typed,1
       mov follr,0
       mov al,codes[10] ;�뢮�
       out 5,al         ;ᮮ�饭��
       mov al,codes[13] ;ErrP
       out 4,al
       mov al,codes[13]
       out 3,al
       mov al,codes[11]
       out 2,al
       mov cx,0affh
onp2:  nop
       loop onp2
       mov clean,1
onp1:  ret
OutNoPrice endp

;9. ����� "�뢮� ����� ��������� ᮮ�饭��"
OutNumR proc near
       cmp mode,0
       jnz onr1
       cmp endin,0
       jnz onr1
       cmp follr,1
       jnz onr1
       mov follr,0
       inc cntr
       cmp cntr,4
       jnz onr2
       dec cntr
       mov endin,1
       jmp onr1
onr2:  lea bx,codes ;�뢮�
       mov al,cntr  ;�����
       xlat         ;���������
       out 1,al     ;ᮮ�饭��
onr1:  ret
OutNumR endp

;10. ����� "�뢮� ᮮ�饭�� � 業�"
OutR&P proc near
       cmp mode,0
       jnz orp2
       cmp endin,0
       jnz orp2
       cmp endr,0
       jnz orp2
       cmp nokbd,0
       jnz orp2
       cmp typed,0 ;�஢�ઠ
       jnz orp3    ;⨯�
       mov cx,cnt  ;������
       add si,cx   ;� ᮮ⢥������
orp3:  cmp typed,1 ;�����⮢��
       jnz orp4    ;��ࠬ��஢
       mov cx,cntp
       add si,cx
orp4:  dec si
orp1:  mov al,[si] ;�뢮�
       out dx,al   ;ᮮ�饭�� ��� 業�,
       inc dx      ;� ����ᨬ��� ��
       dec si      ;⨯� ������
       loop orp1
orp2:  ret
OutR&P endp

;11. ����� "�뢮� ᮮ�饭�� ErrR"
OutNoOut proc near
       cmp mode,1
       jnz ono1
       cmp loading,1
       jnz ono1
       cmp endin,0
       jnz ono1
       mov mode,0
       mov al,codes[10] ;�뢮�
       out 5,al         ;ᮮ�饭��
       mov al,codes[13] ;ErrR
       out 4,al
       mov al,codes[13]
       out 3,al
       mov al,codes[12]
       out 2,al
       mov cx,0affh
ono2:  nop
       loop ono2
       mov clean,1
ono1:  ret
OutNoOut endp

;12. ����� "����஢���� 業 ��������� ᮮ�饭��"
TestPrice proc near
       cmp mode,1
       jnz tp1
       cmp loading,1
       jnz tp1
       lea si,decprice
       lea bx,amount
       mov cx,3
tp6:   mov dx,word ptr [si] ;�८�ࠧ������
       mov ah,dl            ;業�
       mov al,dh
       shl ah,4
       or al,ah
       cmp al,76h           ;����஢����
       jb tp2               ;業�
       mov byte ptr [bx],4  ;� �ନ஢����
       jmp tp5              ;�����
tp2:   cmp al,51h           ;�뢮��
       jb tp3               ;��� �������
       mov byte ptr [bx],3  ;ᮮ�饭��
       jmp tp5
tp3:   cmp al,26h
       jb tp4
       mov byte ptr [bx],2
       jmp tp5
tp4:   cmp al,1
       jb tp5
       mov byte ptr [bx],1
tp5:   add si,2
       inc bx
       loop tp6
       mov ax,15h           ;���᫥���
       mov bl,amount[0]     ;������⢠
       add bl,amount[1]     ;ᨬ�����
       add bl,amount[2]     ;� ���ᨢ�
       mul bl               ;ᢥ⮢��
       inc ax               ;४����
       mov cnt,ax
tp1:   ret
TestPrice endp

;13. ����� "��ନ஢���� ᢥ⮢�� ४����"
ShapingRek proc near
       cmp mode,1
       jnz shr1
       cmp loading,1
       jnz shr1
       mov cx,4
       lea di,reklama      ;����㧪�
shr5:  lea si,report1      ;����室����
       lea bx,amount       ;��ࠬ��஢
shr4:  mov dx,0
       cmp byte ptr [bx],0 ;��ନ஢����
       ja shr3             ;���ᨢ�
       add si,20           ;�⮡ࠦ����
       jmp shr2            ;"���⮢�� ४����"
shr3:  mov al,[si]
       mov [di],al
       inc si
       inc di
       inc dx
       cmp dx,20
       jnz shr3
       mov byte ptr [di],0
       inc di
       dec byte ptr [bx]
shr2:  inc bx
       cmp bx,offset reklama
       jb shr4
       loop shr5
       mov clean,1
       mov loading,0
shr1:  ret
ShapingRek endp

;14. ����� "���/�⮯ ᢥ⮢�� ४����"
SwitchOn_Off proc near
       cmp mode,1
       jnz is1
       in al,1
       cmp al,40h   ;��ࠡ�⪠
       jnz is2      ;������ ������
       mov switch,1 ;"���"
is2:   cmp al,80h   ;��ࠡ�⪠
       jnz is1      ;������ ������
       mov switch,0 ;"�⮯"
is1:   ret
SwitchOn_Off endp

;15. ����� "���� ⨯� ����饩 ��ப�"
InputTypeRS proc near
       cmp mode,1
       jnz itrs1
       in al,2      ;��ࠡ�⪠
       cmp al,0     ;����� ⨯�
       je itrs1     ;����饩 ��ப�
       cmp al,1
       jnz itrs2
       mov typers,0 ;���筠� ��
       mov al,0
itrs2: cmp al,2
       jnz itrs3
       mov typers,1 ;���筠� �� � ��������
       mov al,0
itrs3: cmp al,4
       jnz itrs5
       mov typers,2 ;�����᭠� ��
       mov al,7fh
itrs5: mov cx,10    ;�����⮢��
       mov dx,2     ;�����ࠧ�來���
itrs4: out dx,al    ;�����ᨭ⥧����饣�
       inc dx       ;��ᯫ��
       loop itrs4   ;� �뢮��
itrs1: ret
InputTypeRS endp

;16. ����� "�뢮� �� � �ଥ ���筮� ��"
OutDirectRS proc near
       cmp mode,1
       jnz odrs1
       cmp switch,1
       jnz odrs1
       cmp typers,0
       jnz odrs1
       cmp bx,cntrek ;�����⮢��
       ja odrs4      ;����室����
       mov cntrek,1  ;��ࠬ��஢
odrs4: mov cx,cntrek
       add si,cx
       dec si
odrs2: mov al,[si]   ;�뢮�
       out dx,al     ;ᢥ⮢�� ४����
       inc dx        ;� �ଥ
       dec si        ;���筮�
       loop odrs2    ;����饩 ��ப�
       mov bx,1ffh
odrs3: dec bx
       cmp bx,0
       jnz odrs3
       inc cntrek
odrs1: ret
OutDirectRS endp

;17. ����� "�뢮� �� � �ଥ ���筮� �� � ��������"
OutFlickRS proc near
       cmp mode,1
       jnz ofrs1
       cmp switch,1
       jnz ofrs1
       cmp typers,1
       jnz ofrs1
       cmp bx,cntrek ;�����⮢��
       ja ofrs4      ;����室����
       mov cntrek,1  ;��ࠬ��஢
ofrs4: mov cx,cntrek
       add si,cx
       dec si
ofrs2: mov al,[si]   ;�뢮�
       out dx,al     ;ᢥ⮢�� ४����
       inc dx        ;� �ଥ
       dec si        ;���筮�
       loop ofrs2    ;����饩 ��ப�
       mov bx,0ffh   ;� ��������
ofrs3: dec bx
       cmp bx,0
       jnz ofrs3
       mov dx,2
       mov cx,cntrek
ofrs5: mov al,0
       out dx,al
       inc dx
       loop ofrs5
       mov bx,0ffh
ofrs6: dec bx
       cmp bx,0
       jnz ofrs6
       inc cntrek
ofrs1: ret
OutFlickRS endp

;18. ����� "�뢮� �� � �ଥ �����᭮� ��"
OutInversRS proc near
       cmp mode,1
       jnz oirs1
       cmp switch,1
       jnz oirs1
       cmp typers,2
       jnz oirs1
       cmp bx,cntrek ;�����⮢��
       ja oirs4      ;����室����
       mov cntrek,1  ;��ࠬ��஢
oirs4: mov cx,cntrek
       add si,cx
       dec si
oirs2: mov al,[si]   ;�뢮�
       not al        ;ᢥ⮢�� ४����
       out dx,al     ;� �ଥ
       inc dx        ;�����᭮�
       dec si        ;����饩 ��ப�
       loop oirs2
       mov bx,1ffh
oirs3: dec bx
       cmp bx,0
       jnz oirs3
       inc cntrek
oirs1: ret
OutInversRS endp

;19. ����� "�������� ०����"
IndicModes proc near
       cmp mode,0 ;����� "����"?
       jnz inm1
       mov al,1   ;��
       jmp inm2
inm1:  mov al,4   ;���
inm2:  out 0,al   ;����祭�� ����室�����
                  ;����筮�� ��������
       ret
IndicModes endp

      ;�����஢��� �ணࠬ��

begin1:                  ;���⥬��� �����⮢��
       mov ax,data1      ;���樠������
       mov ds,ax         ;ᥣ������
       mov ax,stack1     ;ॣ���஢
       mov ss,ax
       lea sp,StkTop     ;� 㪠��⥫� �⥪�
       call InitCodes    ;���樠������ ⠡���� �����
begin2:call GetStart     ;�����⮢�� � �����
       call InputMode    ;���� ०����
       call InputType    ;���� ⨯� ������
       call CtrlReport   ;����஫� �� ������� ᮮ�饭���
       call CtrlPrice    ;����஫� �� �������� 業��
       call Cleaning     ;���⪠ ��ᯫ��
       call InputR&P     ;���� ᮮ�饭�� � 業�
       lea bx,codes      ;����㧪� ⠡���� �����
       call ShapingR&P   ;��ନ஢���� ᮮ�饭�� � 業�
       call OutNoPrice   ;�뢮� ᮮ�饭�� ErrP
       call OutNumR      ;�뢮� ����� ��������� ᮮ�饭��
       mov si,addrr&p    ;��।�� ��ࠬ��஢ ��� �뢮��
       mov dx,2          ;ᮮ�饭�� � 業�
       call OutR&P       ;�뢮� ᮮ�饭�� � 業�
       call OutNoOut     ;�뢮� ᮮ�饭�� ErrR
       call TestPrice    ;����஢���� 業 ��������� ᮮ�饭��
       call ShapingRek   ;��ନ஢���� ᢥ⮢�� ४����
       call SwitchOn_Off ;���/�⮯ ᢥ⮢�� ४����
       call InputTypeRS  ;���� ⨯� ����饩 ��ப�
       mov bx,cnt        ;��।�� ��ࠬ��஢
       lea si,reklama    ;��� �뢮��
       mov dx,2          ;ᢥ⮢�� ४����
       call OutDirectRS  ;�뢮� �� � �ଥ ���筮� ��
       call OutFlickRS   ;�뢮� �� � �ଥ ���筮� �� � ��������
       call OutInversRS  ;�뢮� �� � �ଥ �����᭮� ��
       call IndicModes   ;�������� ०����
       jmp begin2        ;���몠��� �ணࠬ����� �����
       org 7f0h          ;���ᯥ祭�� ��砫쭮�� ����᪠
start: jmp begin1        ;�ணࠬ�� �� ����祭�� ���ன�⢠
code1 ends
      end start