name examinator
page ,100 
tmode equ 0;�ணࠬ��஢����(०�� �� 㬮�砭��)
tut equ 0;��� ��� �६���
tick equ 18
                ;����� �����:
ip_mut0 equ 00h ;०��,���,�६�
ip_varnznq1 equ 01h ;��ਠ���,᫥���饥 �������,�����
                 ;����� �뢮��:
op_mut2 equ 02h ;०��,���
op_var3 equ 03h ;��ਠ��
op_nz4 equ 04h ;����� �������
op_nq5 equ 05h ;����� �����
op_t10 equ 06h ;�६� 10
op_t1 equ 07h ;�६� 1
op_oz8 equ 08h ;�業��


data segment at 0BA00H
mode db ?;०��
ut db ? ;��� �६���
kbim db 2 dup (?);��ࠧ ����������
key db ?;������ ������
variant db ?;��ਠ��
nz db ?;����� �������
nq db ?;����� �����
oz db ?;�業��
tz db 2 dup (?);�६� �� �������
tost db 2 dup (?);��⠢襥�� �� ���� �६�
kbun db ?;䫠� ����� ����������
kber db ?;䫠� �訡�� ����������
zder db ?;䫠� - ������� �� ���ணࠬ��஢���
mo2x db 5 dup (?); ���ᨢ 2-� �������஢
mo8x db 5 dup (?); ���ᨢ 8-� �������஢

zdtype struc
       q0 db ?; \
       q1 db ?;  :
       q2 db ?;  :
       q3 db ?;  :
       q4 db ?;   :\ ��ਠ��� �⢥⮢
       q5 db ?;   :/ �� ������ �������
       q6 db ?;  :
       q7 db ?;  :
       q8 db ?;  :
       q9 db ?;  /

       tz1 db ? ;\ �६� �� �������
      tz10 db ? ;/
      enb db ? ;>> 䫠� ���ண�. �������
zdtype ends
maszd zdtype 0ah dup (?);<< ���ᨢ �������

map db 0BH dup (?);��� �⮡ࠦ���� �� 8-� ���-�
temp db ?  ;�ᯮ������ �� ����� ०���
temp2 db ? ;�� ����� ��� �६���
last db ? ;��� ��� �����᪠���� ������
nqprev db ?;����� �।��饣� �����
tempoz db ?;�६����� �業��
t1 dw ?  ;��� �뤥প� ᥪ㭤�
data ends

code segment
assume cs:code,ds:data
;����������������������������������������������
 init proc near ;��楤�� ���樠����樨
    mov mode,tut
    mov ut,tut
    mov word ptr kbim,0
    mov key,0
    mov variant,0
    mov nz,0
    mov nq,0ffh
    mov oz,0ffh
    mov word ptr tz,0
    mov word ptr tost,0
    mov kbun,0
    mov kber,0
    mov zder,0
    mov cx,5
    mov al,0
    lea di,mo2x
    cld
    rep stosb
    mov cx,5
    lea di,mo8x
    rep stosb
    mov cx,13*10
    lea di,maszd
    rep stosb

    mov temp,tmode
    mov last,0
    mov nqprev,0ffh
    mov tempoz,0ffh
    mov t1,0
    mov map[0], 3FH
    mov map[1], 0CH
    mov map[2], 76H
    mov map[3], 05EH
    mov map[4], 4DH
    mov map[5], 5BH
    mov map[6], 7BH
    mov map[7], 0EH
    mov map[8], 7FH
    mov map[9], 5FH
    mov map[10],6FH
    ret
 init endp
;����������������������������������������������
 inmode proc near ;��楫�� ����� ०���
	in al,ip_mut0
	cmp nq,0ffh;<<��४����� ०�� �����,�᫨ ��砫�
	jnz ext1   ;�ணࠬ��஢��� ��� �������
	cmp al,temp;��� �����᪠���
	jz ext1
	mov temp,al
	cmp al,1
	jnz mi1
	mov mode,0h
	jmp ext1
  mi1:  cmp al,2
	jnz ext1
	mov mode,0ffh
 ext1:	ret
 inmode endp
;����������������������������������������������

 inut proc near   ;��楫�� ����� ��� �६��
	cmp nq,0ffh ;<<��४����� ��� �६��� �����,�᫨
	jnz exti    ; ��砫� �������
	cmp mode,0  ;�� �ணࠬ��஢���� ��� ����,
	jz minn     ;�.�. �㦭� ������� �६� �� �������
	in al,ip_mut0
	cmp al,temp2 ;��� �����᪠���
	jz exti
	mov temp2,al
	cmp al,08h
	jnz min1
minn:  	mov ut,0ffh ;��� ����
	jmp exti
min1:   cmp al,10h
	jnz exti
	mov ut,0
  exti:	ret
 inut endp
;����������������������������������������������

 kbinput proc near  ;��楤�� ����� ��ࠧ�
	in al,ip_mut0 ; ����������
	mov kbim,al
	in al,ip_varnznq1
	mov kbim[1],al
	ret
 kbinput endp
;����������������������������������������������
 control proc near ;��楤�� ����஫� �����
                   ; � ����������
	mov al,kbim
	mov ah,kbim[1]
        mov kber,0 ;
	mov bl,0   ; ��� ������
	mov cx,15  ; ���� �
  bitr: test ax,1  ; ����� ������
	jz nb1     ;
	inc bl     ;
  nb1:	shr ax,1   ;
	loop bitr  ;
	cmp bl,1   ;
	jna noerr  ;
	mov kber,0ffh; �訡�� ����������
  noerr:
	mov al,kbim   ;
	or al,kbim[1] ;�஢�ઠ �� ���⦠⨥
	cmp al,last   ; � �� ������⨥
	jnz con1      ;
	mov kbun,0ffh ;
	jmp conext    ;
  con1:	mov last,al   ;
	mov kbun,00h  ;�� ��ଠ�쭮
	cmp al,0      ;
	jnz conext    ;
	mov kbun,0ffh ;��� ��� ����������
 conext: ret
 control endp
;����������������������������������������������
 controlzd proc near  ;��楤�� �஢�ન
	cmp mode,0  ;������� �� ���ணࠬ��஢�������
	jz cz2
        cmp nq,0
	jnz cz1
	lea si,maszd
	mov al,nz
	mov bl,13
	mul bl
	add si,ax
	mov al,[si+12]
	cmp al,0ffh   ;�஢�ઠ 䫠�� �������
	jz cz2
	mov zder,0ffh
	dec nq
  cz1:	cmp kbim[1],80h
	jz cz2
	mov zder,0
   cz2: ret
 controlzd endp
;����������������������������������������������

 ankey proc near   ;��楤�� �ᯮ��������
	mov al,kber ;����⮩ ������
	or al,kbun
	cmp al,0   ;�᫨ ���� �訡�� ���-��
	jnz anext  ;��祣� �� ������
	cmp kbim,40h
	jnz an1
	mov al,2 ;������ +1
	jmp ann
  an1:	cmp kbim,80h
	jnz an2
	mov al,3 ;������ +10
	jmp ann
  an2:  cmp kbim[1],40h
	jnz an3
	mov al,0 ;������ ᫥�. �������
	jmp ann
  an3:  cmp kbim[1],80h
	jnz an4
	mov al,1 ;������ ᫥�. �����
	jmp ann
  an4:  mov al,kbim+1
	mov cl,0
  san1:	shr al,1
	inc cl
	cmp al,0
	jnz san1
        mov al,3
	add al,cl ; ������ ��ਠ��
  ann:  mov key,al
 anext:	ret
 ankey endp
;����������������������������������������������
 variform proc near ; ��楤�� �ନ஢���� ��ਠ��
	cmp nq,0ffh ; �஢�ઠ �-� �����
	jz varext
	mov al,kber
	or al,kbun
	cmp al,0   ;��� �訡��
	jnz varext
	cmp key,4  ;����� ������ ��ਠ��
	jb varext
	mov al,key
	sub al,3
	mov variant,al ;��ਠ�� �⢥�
 varext:ret
 variform endp
;����������������������������������������������
 nzform proc near ; ��楤�� �ନ஢���� �-� �������
	cmp nq,0ffh ; �஢�ઠ �-� �����
	jnz nzext
	mov al,kber
	or al,kbun
	cmp al,0  ;��� �訡��
	jnz nzext
	cmp key,0 ;����� ������ ᫥�. �������
	jnz nzext
	inc nz
	cmp nz,0ah;�᫨ �-� ����� 9,� =0
	jnz nzext
	mov nz,0
 nzext: ret
 nzform endp
;����������������������������������������������
 nqform proc near ; ��楤�� �ନ஢���� �-� �����
	mov al,kber
	or al,kbun
	cmp al,0   ;��� �訡��
	jnz nqext
	cmp key,1 ;����� ������ ᫥�. �����
	jnz nqext
	inc nq
	cmp nq,0ah;�᫨ �-� ����� 9,� =0
	jnz nqext
	mov nq,0
 nqext:	ret
 nqform endp
;����������������������������������������������
 tzinput proc near ;��楤�� ����� �६��� �� �������
	mov al,kber
	or al,kbun
	or al,mode
	cmp al,0 ; ��� ०��� � �訡��
	jnz tzext
	cmp key,2 ;����� ������ +1
	jnz tze1
	inc tz    ;�६� + 1
	cmp tz,0ah
	jnz tze1
	mov tz,0
 tze1:	cmp key,3 ;����� ������ +10
	jnz tzext
	inc tz[1] ;�६� + 10
	cmp tz[1],0ah
	jnz tzext
	mov tz[1],0
 tzext:	ret
 tzinput endp
;����������������������������������������������
 mo8xform proc near  ; ��楤�� �ନ஢����
	mov al,kber
	or al,zder
	cmp al,0  ; �뢮���� ᮮ��. �� �訡��
	jz m81
	mov mo8x,0f0h ; �訡�� ����
	jmp m8ext
 m81:	mov al,nz  ;����� �������
	mov mo8x,al

	mov al,nq
	cmp zder,0ffh
	jnz m88   ;�᫨ �訡�� �������
	mov al,0ffh ;  ��� �-� �����
 m88:	mov mo8x[1],al ;���� ����

	cmp mode,0 ;�� �ண����஢���� �業�� ���
	jz noz
	mov al,oz
	mov mo8x[2],al ;�業��
	jmp yoz
  noz:  mov mo8x[2],0ffh ;��� �業��
  yoz:
	cmp mode,0h ;�� �ணࠬ��஢����
	jnz els     ;�⮡ࠦ��� �६� �� �������
	mov al,tz   ;�� ����������� - ��⠢襥��
	mov mo8x[3],al; �६� ,�᫨ ��� �६���
	mov al,tz[1]  ;����
	mov mo8x[4],al
	jmp m8ext
  els: 	cmp ut,0ffh
	jnz els1
	mov al,tost
	mov mo8x[3],al
	mov al,tost[1]
	mov mo8x[4],al
	jmp m8ext
 els1:	mov al,0ffh
	mov mo8x[3],al
	mov mo8x[4],al
 m8ext:	ret
 mo8xform endp
;����������������������������������������������
 mo8xout proc near ; ��楤�� �뢮�� �� 8-�
	cmp mo8x,0f0h
	jnz o83
	mov al,73h ; E - �訡��
	out op_nz4,al
	jmp oext
 o83:	lea bx,map
	mov al,mo8x  ;�뢮� �-�
 	xlat         ;�������
	out op_nz4,al

	mov al,mo8x[1]
	cmp al,0ffh ;�뢮���� �-� �����
	jz nonq
 	xlat
	out op_nq5,al ;�뢮��� �-� �����
	jmp ynq
  nonq: mov al,0
	out op_nq5,al ;���⮩ ����-�
  ynq:
	mov al,mo8x[2]
	cmp al,0ffh  ;�뢮���� �業��
	jz notoz
 	xlat
	out op_oz8,al ;�뢮��� �業��
	jmp ozext
 notoz:	mov al,0
	out op_oz8,al ;���⮩ ����-�
  ozext:

	cmp mo8x[4],0ffh ;�뢮���� �६�
	jz oe2
	mov al,mo8x[4]
 	xlat
	out op_t10,al  ;�뢮��� �६�
	mov al,mo8x[3]
 	xlat
	out op_t1,al ;�뢮��� �६�
	jmp oext
    oe2:mov al,0 ;���⮩ ����-�
	out op_t10,al
	out op_t1,al
  oext:	ret
 mo8xout endp
;����������������������������������������������
 zprogram proc near ;��楤�� �ண�-�� �������
	cmp mode,0 ;⮫쪮 �� �ணࠬ��஢����
	jnz zpext
        mov al,kbun
        or al,kber
	cmp al,0 ; ��� �訡�� ����-��
	jnz zpext
	mov al,nqprev
	cmp al,nq  ;����� ����� ���������
	jz zpext

	lea bx,maszd ;����ன�� �� ������
	mov al,nz    ;⥪�饣� �������
	mov dl,13
	mul dl
	add bx,ax
	mov al,nqprev
	mov ah,0
	mov si,ax ;�।��騩 �����
	mov al,nq
	mov ah,0
	mov di,ax ;⥪�騩 �����

	mov al,nqprev
	xor al,9
	xor al,nq
	cmp al,0 ;�� �������
	jnz zpr1
	mov al,variant  ;������ ��᫥�����
	mov [bx+si],al  ;�����
	mov nq,0ffh
	mov variant,0
	mov ax,word ptr tz
	mov [bx+10],ax
	mov byte ptr [bx+12],0ffh ;������� ����
	jmp zpr2
  zpr1: cmp nq,0
	jz zpr12
	mov al,variant
	mov [bx+si],al ;������ �।��饣� �����
 zpr12:	mov al,[bx+di] ;�⮡ࠦ��� ��訩 ��ਠ��
	mov variant,al ;�⢥� �� �����
  zpr2: mov al,nq
	mov nqprev,al
 zpext:	ret
 zprogram endp
;����������������������������������������������
 ozcount proc near   ; ��楤�� �ନ஢���� �業��
	cmp mode,0ffh
	jnz ozce

	lea bx,maszd ;����ன�� �� ������
	mov al,nz    ;⥪�饣� �������
	mov dl,13
	mul dl
	add bx,ax
	mov al,nqprev
	mov ah,0
	mov si,ax ;�।��騩 �����
	mov al,nq
	mov ah,0
	mov di,ax ;⥪�騩 �����

	cmp ut,0ffh
	jnz oztim
	mov ax,word ptr tost
	cmp ax,0        ;���뢠�� �६�,
	jnz oztim       ;�᫨ �㦭�
	mov al,nqprev
	or al,nq
	cmp al,0ffh
	jz oztim
	cmp oz,0ffh
	jz ozc20   ;�� �뢮� �業��
 oztim:
        mov al,kbun
        or al,kber
  	cmp al,0 ;��� �訡�� ���-��
	jz ozce1
 ozce:	jmp ozcext
	cmp zder,0ffh ;��� �訡�� �������
	jz ozce
 ozce1:
	mov al,oz
	cmp al,tempoz ;�᫨ �業�� �� ���-�
	jnz ozc1      ;� ����-� ��⨢��
	mov oz,0ffh   ;��ᨬ �業��
	mov tempoz,0
  ozc1:
	mov al,nqprev ;�-� ����� ���������
	cmp al,nq
	jz ozcext
	mov al,nq
	xor al,nqprev
	xor al,9
	cmp al,0 ;����� �������
	jnz ozc2

 ozc20: mov al,variant ;���뢠�� �⢥�
	cmp al,[bx+si] ;�� ��᫥�. �����
	jnz ozc31
	cmp al,0
	jz ozc31
	inc tempoz
 ozc31:	mov al,tempoz
	mov oz,al   ;�뢮��� �業��
	mov nq,0ffh
	mov tost,0
	mov tost[1],0
	jmp ozc3

  ozc2: cmp nq,0
	jz ozc3
	mov al,variant ;���뢠�� �⢥�
	cmp al,[bx+si] ;�� �।��騩 �����
	jnz ozc3
	cmp al,0
	jz ozc3
	inc tempoz
 ozc3:	mov al,nq
	mov nqprev,al
	mov variant,0
 ozcext:ret
 ozcount endp
;����������������������������������������������
 timecount proc near ;��楤�� �ନ஢���� ��� �६���
	cmp mode,0ffh ;⮫쪮 �� �����������
	jnz tmext
	cmp ut,0ffh  ;��� �㦥�
	jnz tmext
	cmp zder,0h  ;�訡�� ������� ���
	jnz tmext
	mov al,nqprev
	xor al,0ffh
	xor al,nq
	cmp al,0 ;����� ����� �����
	jnz tm1
	lea si,maszd
	mov al,nz
	mov bl,13
	mul bl
	add si,ax
	mov al,[si+10] ;����砥�
	mov tost,al    ;�६� ��
	mov al,[si+11] ; ⥪�饥 �������
	mov tost[1],al ;
  tm1:  cmp nq,0ffh
	jz tmext

	mov ah,0   ;�뤥ন����
	int 1ah    ; 1 ᥪ㭤�
	mov ax,dx  ;
        sub dx,t1
	cmp dx,tick
	jb tmext
	mov t1,ax

	cmp tost,0 ;㬥��蠥� ��⠢襥��
	jz tm2     ;�६�
	dec tost
	jmp tmext
  tm2:	cmp tost[1],0
	jz tmext
	mov tost,9
	dec tost[1]
 tmext: ret
 timecount endp
;����������������������������������������������
 mo2xform proc near  ; ��楤�� �ନ஢����
                     ; ���ᨢ� 2-� ���-��
	mov cx,9
	mov al,0
	lea di,mo2x
	cld
	rep stosb   ;���⪠ ��� �������஢

	lea di,mo2x
	mov al,mode
	cmp al,0
	jnz mm1
	not al
	mov [di],al ;���ᢥ⪠ ���� �ணࠬ��஢����
	jmp extmo
   mm1: mov [di+1],al ; ���� �����������
 extmo:
	mov al,ut
	cmp al,0  ;��� �६���
	jnz mm2
	not al
	mov [di+3],al ;���
	jmp extmo1
   mm2: mov [di+2],al ;��
extmo1:
	mov al,variant
        cmp al,0
	jz extmo2
	mov [di+4],al ;����� ��ਠ��
extmo2:	ret
 mo2xform endp
;����������������������������������������������
 mo2xout proc near ;��楤�� �뢮�� �� 2-�
	lea si,mo2x
	mov ah,0ffh
	mov al,0
	cmp ah,[si]
	jnz exm1
	or al,01h ;�⮡ࠦ��� �ணࠬ��஢����
	jmp mmo1
exm1:   or al,02h ;���� �������
mmo1:
	cmp ah,[si+2] ;�⮡ࠦ��� ��� �६���
	jnz exm2
	or al,08h ;��
	jmp mmo2
exm2:   or al,10h ;���
mmo2:   out op_mut2,al
        mov al,[si+4]
        cmp al,0
	jz mmo21
	mov cl,al
	mov al,1
	dec cl
	shl al,cl
mmo21:	out op_var3,al ;�⮡ࠦ��� ��ਠ��
      	ret
 mo2xout endp
;����������������������������������������������



begin: mov ax,data
       mov ds,ax
       mov es,ax
       mov ax,steck
       mov ss,ax       
       mov sp,offset StkTop 
       call init
m:     call inmode   
       call inut
       call kbinput
       call control	
       call ankey
       call variform
       call nzform
       call nqform
       call tzinput
       call zprogram	
       call controlzd	
       call timecount 			
       call ozcount
       call mo8xform
       call mo8xout 			
       call mo2xform
       call mo2xout
       jmp m		
       org 07F0H
start: jmp begin
code ends

steck segment stack at 0BA80H
  org 100h 
  dw 20H dup (?)
  StkTop label word
steck ends

end start