tikhour=64800   ; ���-�� ⨪�� � ��
tikmin=1080     ; ���-�� ⨪�� � ������
tiksec=18       ; ���-�� ⨪�� � ᥪ
tikdsec=18      ; ���-�� ⨪�� � ���. ���� ᥪ *10

;--------------------------------------------- 

name timer
data segment at 0BA00H
       Map db 0AH dup (?)
       dlit1 db 5 dup (?) ;��;��;�;���;�; 
       dlit2 db 5 dup (?)
       n_k1 dd 2 dup (?)
       n_k2 dd 2 dup (?)
       kol_vo1 dw (?)
       kol_vo2 dw (?)
       sost1 db (?)
       sost2 db (?)
       zadergka dd ?
       prov dd ?  ; ����஫쭮� �᫮ ��� �஢�ન 
                  ;  ��� 63720
                  ;  �� ml56490  st98 

data ends 

stack segment at 0BA80H
    org 200h
    dw 20h dup (?)
    StkTop label Word
stack ends

code segment

Assume cs:code,ds:data;ss:stack

;��楤�� ��⠭�������� ��砫�� ���祭�� ��ࠬ��஢
Initalizate proc near
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
mov di,offset dlit1
mov Si,offset dlit2
mov cx,5
cikl:mov [di],0
     mov [si],0
     inc di
     inc si
     loop cikl 
in al,1
mov sost1,al
in al,6
mov sost2,al
ret
Initalizate endp
;=========================================
;��楤�� �믮���� ����প� = (1/18.2) ᥪ.
Zader proc near
;��⨥ 䫠�� ��蠣����� ०���
 push ax
 push cx
 push dx
 pushf 
 pop ax
 and ax,0feffh
 push ax
 popf

;�믮������ ����প� = 0,05ᥪ.
 mov AH,0
 int 1Ah
 add Dx,word ptr prov
 mov word ptr zadergka,Dx ; ��. ᫮��
 adc Cx,word ptr [prov+2]
 mov word ptr [zadergka+2],CX ; ��. ᫮��

;��⠭���� 䫠�� ��蠣����� ०���
 pushf
 pop ax
 or ax,100h
 push ax
 popf
 pop dx
 pop cx
 pop ax
 dec cx 
 ret
Zader endp
;====================================

;��楤�� �८�ࠧ�� ���-�� ⨪���� � �./���./ᥪ./�.ᥪ./��.ᥪ
;��।����� ᬥ饭�� ���ᨢ� �६��� �१ ॣ���� Bx
;� ���-�� ⨪�� �१ ॣ����� DX-��. ᫮�� � AX-��. ᫮��.
PREOBR PROC NEAR
mov cx,tikhour
div cx
mov cl,100
div cl
mov byte ptr [bx+4],ah 
mov ax,dx
mov dx,0
mov cx,tikmin
div cx
mov byte ptr [bx+3],al
mov ax,dx
mov cl,tiksec
div cl
mov byte ptr [bx+2],al
mov al,ah
mov ah,10
mul ah
mov cl,tikdsec
div cl
mov byte ptr [bx+1],al
cmp ah,8
js rrr
mov byte ptr [bx],5
jmp rrr1
rrr:
mov byte ptr [bx],0
rrr1:ret
ENDP PREOBR
;---------------------
;��楤�� �믮���� �८�ࠧ������ �६������ ���ࢠ��
;��� ������1
PREOBR_VR1 PROC NEAR
mov Ax,word ptr [n_k1+4]
mov Dx,word ptr [n_k1+6]
sub Ax,word ptr [n_k1]
sbb Dx,word ptr [n_k1+2]
mov Bx,offset dlit1
call preobr
ret
ENDP PREOBR_VR1
;-------------------------
;��楤�� �믮���� �८�ࠧ������ �६������ ���ࢠ��
;��� ������2
PREOBR_VR2 PROC NEAR
mov Ax,word ptr [n_k2+4]
mov Dx,word ptr [n_k2+6]
sub Ax,word ptr [n_k2]
sbb Dx,word ptr [n_k2+2]
mov Bx,offset dlit2
call preobr
ret
ENDP PREOBR_VR2
;===========================
;��楤�� �믮���� �८�ࠧ������ ��ਮ��
;��� ������1
PREOBR_PR1 PROC NEAR
mov cx,kol_vo1
cmp cx,0
jz www
mov Ax,word ptr [n_k1+4]
mov Dx,word ptr [n_k1+6]
sub Ax,word ptr [n_k1]
sbb Dx,word ptr [n_k1+2]
mov cx,kol_vo1
div cx
mov dx,0
push Ax
push Dx
mov ax,kol_vo1
inc Ax
mov dx,0
mov cx,2
div cx
mov cx,ax
pop dx
pop ax
cmp cx,dx
js notokrug
inc Ax
notokrug:mov dx,0
mov Bx,offset dlit1
call preobr
www:ret
ENDP PREOBR_PR1
;----------------------------------------
;��楤�� �믮���� �८�ࠧ������ ��ਮ��
;��� ������2
PREOBR_PR2 PROC NEAR
mov cx,kol_vo2
cmp cx,0
jz www2
mov Ax,word ptr [n_k2+4]
mov Dx,word ptr [n_k2+6]
sub Ax,word ptr [n_k2]
sbb Dx,word ptr [n_k2+2]
mov cx,kol_vo2
div cx
mov dx,0
push Ax
push Dx
mov ax,kol_vo2
inc Ax
mov dx,0
mov cx,2
div cx
mov cx,ax
pop dx
pop ax
cmp cx,dx
js notokrug2
inc Ax
notokrug2:mov dx,0
mov Bx,offset dlit2
call preobr
www2:ret
ENDP PREOBR_PR2
;==============================================
;��楤�� �뢮��� �� ��������� ���祭�� ��. ���ࢠ��
;��� ��ਮ�� ������1
izobr1 proc near
mov bx,offset Map
mov al,dlit1[4]
or al,0
jnz hr1
mov al,dlit1[3]
or al,0
jnz mn1
 mov al,1 ; ��. ᥪ.
 out 0bh,al
 mov al,dlit1[2]
 mov ah,0
 mov dl,10
 div dl
 xlat
 out 2,al
 mov al,ah
 xlat
 or al,80h   ; �⮡� ��५� �窠
 out 3,al
 mov al,dlit1[1]
 xlat
 out 4,al
 mov al,dlit1[0]
 xlat
 out 5,al
jmp dal
mn1:mov al,2 ; ᥪ.
    out 0bh,al
    mov al,dlit1[3]
    mov ah,0
    mov dl,10
    div dl
    xlat
    out 2,al
    mov al,ah
    xlat
    or al,80h   ; �⮡� ��५� �窠
    out 3,al
    mov al,dlit1[2]
    mov ah,0
    mov dl,10
    div dl
    xlat
    out 4,al
    mov al,ah
    xlat
;    or al,80h   ; �⮡� ��५� �窠
    out 5,al
    jmp dal
hr1:
   mov al,4 ; ���
   out 0bh,al
   mov al,dlit1[4]
   mov ah,0
   mov dl,10
   div dl
   xlat
   out 2,al
   mov al,ah
   xlat
   or al,80h   ; �⮡� ��५� �窠
   out 3,al
   mov al,dlit1[3]
   mov ah,0
   mov dl,10
   div dl
   xlat
   out 4,al
   mov al,ah
   xlat
;   or al,80h   ; �⮡� ��५� �窠
   out 5,al
   jmp dal
dal:ret
endp izobr1
;------------------------------------
;��楤�� �뢮��� �� ��������� ���祭�� ��. ���ࢠ��
;��� ��ਮ�� ������2
izobr2 proc near
mov bx,offset Map
mov al,dlit2[4]
or al,0
jnz hr2
mov al,dlit2[3]
or al,0
jnz mn2
 mov al,1 ; ��. ᥪ.
 out 0Ch,al
 mov al,dlit2[2]
 mov ah,0
 mov dl,10
 div dl
 xlat
 out 7,al
 mov al,ah
 xlat
 or al,80h   ; �⮡� ��५� �窠
 out 8,al
 mov al,dlit2[1]
 xlat
 out 9,al
 mov al,dlit2[0]
 xlat
 out 10,al
jmp brr
mn2:
    mov al,2 ; ᥪ.
    out 0Ch,al
    mov al,dlit2[3]
    mov ah,0
    mov dl,10
    div dl
    xlat
    out 7,al
    mov al,ah
    xlat
    or al,80h   ; �⮡� ��५� �窠
    out 8,al
    mov al,dlit2[2]
    mov ah,0
    mov dl,10
    div dl
    xlat
    out 9,al
    mov al,ah
    xlat
;    or al,80h   ; �⮡� ��५� �窠
    out 10,al
    jmp brr
hr2:
   mov al,4 ; ���.
   out 0Ch,al
   mov al,dlit2[4]
   mov ah,0
   mov dl,10
   div dl
   xlat
   out 7,al
   mov al,ah
   xlat
   or al,80h   ; �⮡� ��५� �窠
   out 8,al
   mov al,dlit2[3]
   mov ah,0
   mov dl,10
   div dl
   xlat
   out 9,al
   mov al,ah
   xlat
   or al,80h   ; �⮡� ��५� �窠
   out 10,al
   jmp brr
brr:nop
ret 
endp izobr2
;=============================================================
;� ��楤��� ��।����� ᬥ饭�� ���ᨢ� ��砫�-����� �����
;�१ ॣ���� Bx.��楤�� ��⠭�������� ࠢ���⢮ �����
;��砫�� � ������ ���祭��� ����� �६������ ���ࢠ��
SETUP_N_K PROC NEAR
mov word ptr prov,0; ��� �஢�ન ࠡ��� �ணࠬ��
mov word ptr [prov+2],0; ��� �஢�ન ࠡ��� �ணࠬ��
call Zader
mov ax,word ptr zadergka
mov word ptr [bx],ax
mov word ptr [bx+4],ax
mov ax,word ptr [zadergka+2]
mov word ptr [bx+2],ax
mov word ptr [bx+6],ax
ret
ENDP SETUP_N_K
;------------------------
;��楤�� ��ᢠ����� ��砫쭮�� ���祭�� ⨪�� ����筮�,
;��� ������1   
SETUP_N_K1 PROC NEAR
mov kol_vo1,0
mov bx,offset n_k1
call setup_n_k
ret
ENDP SETUP_N_K1
;-------------------------
;��楤�� ��ᢠ����� ��砫쭮�� ���祭�� ⨪�� ����筮�,
;��� ������2   
SETUP_N_K2 PROC NEAR
mov kol_vo2,0
mov bx,offset n_k2
call setup_n_k
ret
ENDP SETUP_N_K2
;======================================================
;� ��楤��� ��।����� ᬥ饭�� ���ᨢ� ��砫�-����� �����
;�१ ॣ���� Bx.��楤�� ����筮�� ��� ⨪�� 
;��ᢠ����� ⥪�饥 �᫮ ⨪��.
IZMEN PROC NEAR
mov word ptr [prov+2],0;98 ��� �஢�ન ࠡ��� �ணࠬ��
mov word ptr prov,0;56490 ��� �஢�ન ࠡ��� �ணࠬ�� ������ �����
call Zader
mov ax,word ptr zadergka
mov word ptr [Bx+4],AX
mov ax,word ptr [zadergka+2]
mov word ptr [Bx+6],AX
ret
ENDP IZMEN
;---------------------
;��楤�� ����筮�� ��� ⨪�� ��ᢠ�����
;⥪�饥 �᫮ ⨪��, ��� ������1.
IZMEN1 PROC NEAR
mov bx,offset n_k1
call izmen
ret
ENDP IZMEN1
;-----------------------
;��楤�� ����筮�� ��� ⨪�� ��ᢠ�����
;⥪�饥 �᫮ ⨪��, ��� ������2.
IZMEN2 PROC NEAR
mov bx,offset n_k2
call izmen
ret
ENDP IZMEN2
;==========================================================
;��楤�� �믮���� ��� ��� ������1
SBROS1 PROC NEAR
 call Setup_n_k1
 call preobr_vr1
 call izobr1
 ret
ENDP SBROS1
;---------------------------------------------
;��楤�� �믮���� ��� ��� ������2
SBROS2 PROC NEAR
 call Setup_n_k2
 call preobr_vr2
 call izobr2
 ret
ENDP SBROS2
;===========================
KANAL1 PROC NEAR
mov al,sost1
test al,1
jz start_kanal1
jmp izmer_kanal1 
start_kanal1:in al,1         ;�⠥� �� ���� ����� ������1
             test al,1       
             jz vyxod1         
             in al,1         
             mov sost1,al    
             call sbros1      
izmer_kanal1:mov al,sost1    
             test al,4       
             jnz period_kanal1
         ;��. ���ࢠ�
             vremy:call izmen1;�����塞 ���祭�� ��. ���ࢠ��
             call preobr_vr1
             call izobr1
             jmp end_kanal1
period_kanal1:in al,1 
              test al,2 
              jz end_kanal1 
      drebezg:in al,1 
              test al,2
             jnz drebezg;---
             inc kol_vo1 
             call izmen1 
             call preobr_pr1
             call izobr1
end_kanal1:  in al,1
             test al,1
             jnz vyxod1
             mov sost1,0 
vyxod1:ret
ENDP KANAL1
;----------------------------------------
KANAL2 PROC NEAR
mov al,sost2
test al,1
jz start_kanal2
jmp izmer_kanal2 
start_kanal2:in al,6         ;�⠥� �� ���� ����� ������1
             test al,1       
             jz vyxod2        
             in al,6         
             mov sost2,al    
             call sbros2      
izmer_kanal2:mov al,sost2     
             test al,4        
             jnz period_kanal2
         ;��. ���ࢠ�
             call izmen2
             call preobr_vr2
             call izobr2
             jmp end_kanal2
period_kanal2:in al,6 
             test al,2
             jz end_kanal2 
     drebezg2:in al,6 
             test al,2
             jnz drebezg2;---
             inc kol_vo2 
             call izmen2 
             call preobr_pr2
             call izobr2
end_kanal2:  in al,6
             test al,1
             jnz vyxod2
             mov sost2,0 
vyxod2:ret
ENDP KANAL2
;===========================
begin: 
mov ax,data
mov ds,ax
mov ax,stack
mov ss,ax
mov sp,offset StkTop
call Initalizate
call Setup_n_k1
call izobr1
call Setup_n_k2
call izobr2
nachalo:call kanal1
        call kanal2
jmp nachalo
org 07F0H
start:jmp begin 
code ends
end start
