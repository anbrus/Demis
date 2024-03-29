PAGE 60, 120
                     NAME OhranSignal
            ;���ᠭ�� ������������� ����⠭�
f_mig EQU 350  ;����⠭� ����� �������
Port_et=1      ;���� ���⮢
Port_k=2       ;���⥪����
Port_d_p=3     ;�����-�뢮��
Port_d_v=6
             ;���ᠭ�� ������
data segment at 0BA00H
       Map db 8 dup (?)
       Et  db 3 dup (?)
       Dat db 8 dup (?)
       lamp_et db 01h dup (?)
       lamp_k db 01h dup (?)
       l_mig db 01h dup (?)
       ll1 db 8 dup (?)
       ll2 db 8 dup (?)
data ends
            ;���ᠭ�� �⥪� 
stack segment at 0BA80H
  dw 50H dup (?)
  StkTop label word
stack ends
            ;���ᠭ�� �믮��塞�� ����⢨�
code segment
assume cs:code,ds:data,ss:stack
;_________________________________________________
            ;���ᠭ�� �ணࠬ���� ���㫥�
;�������� "����� �������"
delay proc
        mov  cx,f_mig
loop_:
	push 	ax
	pop	ax
	loop 	loop_
        ret 
delay endp
;________________________________________________________________________
;����� "�㭪樮���쭠� �����⮢��"
podgotovka proc
       mov Map[0], 0CH
       mov Map[1], 76H
       mov Map[2], 05EH
       mov Map[3], 4DH
       mov Map[4], 5BH
       mov Map[5], 7BH
       mov Map[6], 0EH
       mov Map[7], 7FH
       mov et[1],  0CH
       mov et[2],  76H
       mov dat[1], 00H
       mov dat[3], 2FH 
       mov dat[5], 7FH
       mov dat[7], 00H
       ret
podgotovka endp
;___________________________________________________________________
;�����, �ந�����騩 ������� �����窨 �� ��⨢���樨 ������ �� ���稪�� 
mig_lam proc 
        cmp    l_mig,03h   ;���稪 ��⨢��?
        jb     ml2         ;���室, �᫨ ���
        jmp    ml1
ml1:
        xor   al,al        
        out   dx,al
        mov   al,ah
        xor   al,dh
        out   dx,al
        call  delay        ;����প�
        mov   al,ah
        out   dx,al
        cmp   l_mig,05h
        je    ml1
ml2:            
        ret
mig_lam endp
;_______________________________________
;�����, �����⢫��騩 ��襭�� �����窨
gasch_lam proc
         in   al,4
         cmp  al,0
	 jnz  gl     ;���室, �᫨ al#0
         xor  dh,dh
         mov  al,dh
gl:
         ret 
gasch_lam endp                  
;_______________________________________________________
;�����, �����⢫��騩 �롮� �����窨 � ᮮ⢥��⢨� 
;� ��࠭��� �����⮩ ��� 1-�� �⠦� 
lamp_komn1 proc
         mov   bx,offset Map
         call  in_kbd_komn   ;���� �������
         
lk1_1:   cmp   lamp_k,00h    ;1-� ������ �������?  
         je    lk2_1         ;���室 �� l0, �᫨ �� 
         jmp   lk3_1       
lk2_1:
         mov   dh,1          
         call  gasch_lam     ;�஢�ઠ �� ��⨥ � ��࠭�
         mov   ll1[0],dh
         mov   ah,ll1[1]
         jmp   l_end1   
lk3_1:      
         cmp   lamp_k,01h
         je    lk4_1
         jmp   lk5_1

lk4_1:  
         mov   dh,1  
         shl   dh,1
         call  gasch_lam
         mov   ll1[1],dh
         jmp   l_end1 
lk5_1:      
         cmp   lamp_k,02h
         je    lk6_1
         jmp   lk7_1

lk6_1: 
         mov   dh,1 
         shl   dh,2
         call  gasch_lam
         mov   ll1[2],dh
         jmp   l_end1   
lk7_1:      
         cmp   lamp_k,03h
         je    lk8_1
         jmp   lk9_1
lk8_1: 
         mov   dh,1
         shl   dh,3
         call  gasch_lam
         mov   ll1[3],dh
         jmp   l_end1 
lk9_1:      
         cmp   lamp_k,04h
         je    lk10_1
         jmp   lk11_1
lk10_1:    
         mov   dh,1
         shl   dh,4
         call  gasch_lam 
         mov   ll1[4],dh
         jmp   l_end1 
lk11_1:      
         cmp   lamp_k,05h
         je    lk12_1
         jmp   lk13_1
lk12_1:
         mov   dh,1
         shl   dh,5 
         call  gasch_lam
         mov   ll1[5],dh
         jmp   l_end1
lk13_1:      
         cmp   lamp_k,06h
         je    lk14_1
         jmp   lk15_1
lk14_1:  
         mov   dh,1
         shl   dh,6
         call  gasch_lam 
         mov   ll1[6],dh
         jmp   l_end1  
lk15_1:      
         cmp   lamp_k,07h
         je    lk16_1
         jmp   l_end1

lk16_1: 
         mov   dh,1
         shl   dh,7
         call  gasch_lam 
         mov   ll1[7],dh
l_end1:
         mov   al,0 
         mov   ah,dh         
         call  form_gor_l1 
         mov   al,ah 
         out   dx,al 
         ret
lamp_komn1 endp  
;_______________________________________________________
;�����, �����⢫��騩 �롮� �����窨 � ᮮ⢥��⢨� 
;� ��࠭��� �����⮩ ��� 2-�� �⠦� 
lamp_komn2 proc
         mov   bx,offset Map
         call  in_kbd_komn   ;���� �������
         xor   ah,ah
lk1_2:   cmp   lamp_k,00h    ;1-� ������ �������?  
         je    lk2_2         ;���室 �� l0, �᫨ �� 
         jmp   lk3_2       
lk2_2:
         mov   dh,1          
         call  gasch_lam     ;�஢�ઠ �� ��⨥ � ��࠭�
         mov   ll2[0],dh
         jmp   l_end2
lk3_2:      
         cmp   lamp_k,01h
         je    lk4_2
         jmp   lk5_2
lk4_2:  
         mov   dh,1  
         shl   dh,1
         call  gasch_lam
         mov   ll2[1],dh
         jmp   l_end2          
lk5_2:      
         cmp   lamp_k,02h
         je    lk6_2
         jmp   lk7_2

lk6_2: 
         mov   dh,1 
         shl   dh,2
         call  gasch_lam
         mov   ll2[2],dh
         jmp   l_end2          
lk7_2:      
         cmp   lamp_k,03h
         je    lk8_2
         jmp   lk9_2
lk8_2: 
         mov   dh,1
         shl   dh,3
         call  gasch_lam
         mov   ll2[3],dh
         jmp   l_end2          
lk9_2:      
         cmp   lamp_k,04h
         je    lk10_2
         jmp   lk11_2
lk10_2:    
         mov   dh,1
         shl   dh,4
         call  gasch_lam 
         mov   ll2[4],dh
         jmp   l_end2          
lk11_2:      
         cmp   lamp_k,05h
         je    lk12_2
         jmp   lk13_2
lk12_2:
         mov   dh,1
         shl   dh,5 
         call  gasch_lam
         mov   ll2[5],dh
         jmp   l_end2          
lk13_2:      
         cmp   lamp_k,06h
         je    lk14_2
         jmp   lk15_2
lk14_2:  
         mov   dh,1
         shl   dh,6
         call  gasch_lam 
         mov   ll2[6],dh 
lk15_2:      
         cmp   lamp_k,07h
         je    lk16_2
         jmp   l_end2

lk16_2: 
         mov   dh,1
         shl   dh,7
         call  gasch_lam 
         mov   ll2[7],dh
l_end2:
         mov   al,0 
         mov   ah,dh
         call  form_gor_l2 
         mov   al,ah 
         out   dx,al 
         ret
lamp_komn2 endp  
;______________________________________
;�ନ஢���� ������ �����祪 ��� 1-�� �⠦�
form_gor_l1 proc
	 mov  si,0
         xor  ah,ah
         mov  cx,8
fgl1:   
         or   ah,ll1[si]
         inc  si
         loop fgl1
         ret
form_gor_l1 endp
;______________________________________
;�ନ஢���� ������ �����祪 ��� 2-�� �⠦�
form_gor_l2 proc
	 mov  si,0
         xor  ah,ah
         mov  cx,8
fgl2:   
         or   ah,ll2[si]
         inc  si
         loop fgl2
         ret
form_gor_l2 endp
;__________________________________________ 
;���� ����� ������� � ��᫥���騬 ��࠭����� � ��६�����
in_kbd_komn proc
        mov   dh,0
mm:     
	in    al,Port_k
        test  al,0ffh
        jz    n1
	cmp   al,0
	jne   PRESS1    
	mov   al,dh
	xlat
	out   Port_k,al
	jmp   mm
press1:
	mov   ah,al
	mov   al,-1
g1:	
	inc   al
	shr   ah,1
	cmp   ah,0
	jnz   g1       
	mov   dh,al
        mov   lamp_k,al
        xlat
        out   Port_k,al
        jmp   mm 
n1:
        ret
in_kbd_komn  endp
;______________________________________ 
;���� ����� �⠦� � ��᫥���騬 ��࠭����� ����� � ��६�����       
in_kbd_et proc
        mov   dh,0
m:     
	in    al,1
        test  al,0ffh
        jz    m1
	cmp   al,0
	jne   PRESS    
	mov   al,dh
	xlat
	out   1,al
	jmp   m
press:
	mov   ah,al
	mov   al,-1
g:	
	inc   al
	shr   ah,1
	cmp   ah,0
	jnz   g       
	mov dh,al
        mov lamp_et,al
        xlat
        out 1,al
        jmp m 
m1:
        ret
in_kbd_et  endp
;______________________________________
;����� "�롮� �⠦�"        
case_et proc
case1:
        mov    bx,offset et    ;��।�� ��ࠬ��஢ ���  
        call   in_kbd_et       ;����� � �뢮�� �⠦�
        cmp    lamp_et,01h     ;����� �⠦� ࠢ�� 1?
        je     et1             ;���室, �᫨ ��
        jmp    case2    
et1:
        mov     dx,4
        call    lamp_komn1     ;�ନ஢���� ������ �����祪          
        call    mig_lam        ;������� �����祪
case2:
        cmp     lamp_et,02h    ;����� �⠦� ࠢ�� 2? 
        je      et2            ;���室, �᫨ ��
        jmp     case3 
et2:  
        mov     dx,5
        call    lamp_komn2
        call    mig_lam 
case3: 
        ret
case_et endp
;_______________________________________
;��⨢���஢���� ���稪��
in_kbd_dat proc
        mov   dh,0
ikd1:     
	in    al,Port_d_p       ;���� ���稪��
        test  al,0ffh
        jz    ikd4
	cmp   al,0
	jne   ikd2    
	mov   al,dh
	xlat
	out   Port_d_p,al
        out   Port_d_v,al
	jmp   ikd1
ikd2:
	mov   ah,al
	mov   al,-1
ikd3:	
	inc   al
	shr   ah,1
	cmp   ah,0
	jnz   ikd3       
	mov   dh,al

        cmp   al,3          ;������ ���稪 "�����"?
        jne   ikd4          ;���室, �᫨ ���
        xlat                ;⠡��筮� �८�ࠧ������
        out   Port_d_p,al   ;�뢮� ���ﭨ� ���稪�
        mov   l_mig,al      ;����������� ���ﭨ� � ��६�����
ikd4:
        cmp   al,1          ;���?
        jne   ikd5
        xlat
        out   Port_d_p,al
        mov   l_mig,al 
ikd5:
        cmp   al,5          ;������ ���稪 "���"?
        jne   ikd6
        xlat
        out   Port_d_v,al
        mov   l_mig,al
ikd6: 
        cmp   al,7          ;���?
        jne   ikd7
        xor   al,al
        xlat
        out   Port_d_v,al
        mov   l_mig,al 
        jmp   ikd1 
ikd7:
        ret
in_kbd_dat  endp
;____________________________________________________________
                   ;�����஢��� �ணࠬ��       
begin:
       mov ax,data                ;���樠��������� ᥣ������
       mov ds,ax                  ;ॣ���஢

       mov ax,stack
       mov ss,ax       
       mov sp,offset StkTop       ;� 㪠��⥫� �⥪� 
       call podgotovka            ;�㭪樮���쭠� �����⮢��
cycle:
       mov  bx,offset Map         ;��।�� ��ࠬ��஢ ��� ����� � �뢮��
       call in_kbd_komn           ;����� �������
       call case_et               ;���� �⠦�
       mov  bx,offset dat         ;��।�� ��ࠬ��஢ ���
       call in_kbd_dat            ;��⨢���樨 ���稪��
       jmp cycle                  ;���몠��� �ணࠬ����� �����
       org 07F0H
start:
       jmp begin   
code ends
     end start
                  