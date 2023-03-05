.386
;������ ���� ��� � �����
RomSize    EQU   4096

;������ ����室��� ���� �⥪�
Stk        SEGMENT at 100h use16
;������ ����室��� ࠧ��� �⥪�
           dw 100 dup (?)
StkTop     Label Word
Stk        ENDS


Data       SEGMENT at 200h use16
;����� ࠧ������� ���ᠭ�� ��६�����

cur_temp1  dw    ?
li_lim1    dw    ?
hi_lim1    dw    ?
cur_temp2  dw    ?
li_lim2    dw    ?
hi_lim2    dw    ?
cur_temp3  dw    ?
li_lim3    dw    ?
hi_lim3    dw    ?
cur_temp4  dw    ?
li_lim4    dw    ?
hi_lim4    dw    ?

cur_temp   dw    ?

port_in    dw    ?
port_in1   dw    ?
port_in2   dw    ? 
schet      dw    ?

Nomer      db    ?
Lampa2     db    ?
znak       db    ?
Mode       db    ?
Lampa      db    ?
OldKey     db    ?
Key        db    ?
c1         db    ?
c2         db    ?
c3         db    ?


Data       ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

           ASSUME cs:Code, ds:Data, es:Data
           
Image      DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh ;��ࠧ� �� 0 �� 9

ADC_Rdy proc near

           mov dx,port_in
l2:        in al,dx
           cmp al,1h         ;���� ᨣ���� Rdy
           je l1
           jmp l2
           
l1:        mov dx,port_in2
           in al,dx
           mov ah,al
           mov dx,port_in1
           in al,dx 
           mov cur_temp,ax   ;⥪��� ࠡ��� ⥬������
           ret
ADC_Rdy endp   

Index_temp proc near         ;�뢮� ���祭�� �� ���������

           mov ax,cur_temp
           cmp ax,8000h
           jb l5             ;���室, �᫨ <
           
           sub ax,8000h      ;���⠥� 32768
           mov znak,0h
           jmp l6
                              
l5:        mov dx,8000h      ;���⠥� �� 32768
           sub dx,ax
           mov ax,dx  
           mov znak,40h
           
l6:        shr ax,06h        ;����� �� 64 
           mov dx,ax         ;512 
           mov bl,0ah
           div bl            ;����� �� 10, � al १����
           mov ah,0
           mov c2,al
           mul bl            ;㬭����� �� 10
           sub dx,ax
           mov c1,dl
                     
           mov al,c2
           xor dx,dx
           mov ah,0
           mov dl,al
           mov bl,0ah
           div bl            ;����� �� 10, � al १����
           mov ah,0
           mov c3,al
           mul bl            ;㬭����� �� 10
           sub dx,ax
           mov c2,dl
           
           ;�뢮� ���祭�� �� ᥬ�ᥣ����� ���������
           mov al,c1
           mov ah,0
           mov bx,ax
           mov al,Image+bx
           mov dx,port_in
           out dx,al  
           
           mov al,c2
           mov ah,0
           mov bx,ax
           mov al,Image+bx
           add al,80h
           mov dx,port_in2
           out dx,al  
           
           mov al,c3
           mov ah,0
           mov bx,ax
           mov al,Image+bx
           mov dx,port_in1
           out dx,al       
           
           mov al,znak
           inc port_in1
           mov dx,port_in1
           out dx,al      
                   
l7:        ret
Index_temp endp
   
Init proc near               ;���樠������ ��६�����

           mov li_lim1,0
           mov hi_lim1,0ffffh 
           mov li_lim2,0
           mov hi_lim2,0ffffh 
           mov li_lim3,0
           mov hi_lim3,0ffffh 
           mov li_lim4,0
           mov hi_lim4,0ffffh 
           mov Nomer,4
           mov Mode,1
           mov Lampa,00001100b
           mov OldKey,0
           mov schet,64
           mov Lampa2,0
           ret
Init endp    

ADC_Start proc near
           mov al,0
           out 0,al
           
           mov al,1
           out 0,al          
           ret
ADC_Start endp

Save_Cur_temp proc near          ;�⮡ࠦ���� �� ����饭��

           mov port_in,04h          
           mov port_in1,06h
           mov port_in2,05h 
           call ADC_Rdy
           mov ax,cur_temp
           mov cur_temp1,ax           
                     
           mov port_in,08h
           mov port_in1,0ah
           mov port_in2,09h 
           call ADC_Rdy
           mov ax,cur_temp
           mov cur_temp2,ax
           
           mov port_in,10h
           mov port_in1,12h
           mov port_in2,11h 
           call ADC_Rdy
           mov ax,cur_temp
           mov cur_temp3,ax
                      
           mov port_in,20h
           mov port_in1,22h
           mov port_in2,21h 
           call ADC_Rdy  
           mov ax,cur_temp
           mov cur_temp4,ax    
           ret
Save_Cur_temp endp

Kn_Nomer proc near

           in al,55h
           test al,00111100b
           jz k3             ;�᫨ ������ � ����饭�� �� �����
           mov ah,04h
k1:        test al,ah
           jnz k4
           shl ah,1
           jmp k1
k4:        mov Nomer,ah
           mov al,Lampa
           and al,11111100b  ;����ᨬ �����窨 �� � ��
           or al,00000100b
           mov Lampa,al
k3:        mov al,Nomer
           out 55h,al        ;�������� � ����饭��   
                  
           ret
Kn_Nomer endp


Vivod_rt proc near           ;�뢮� �� ����饭��
           
           mov port_in,04h          
           mov port_in1,06h
           mov port_in2,05h 
           mov ax,cur_temp1
           mov cur_temp,ax
           call Index_temp 
                                
           mov port_in,08h
           mov port_in1,0ah
           mov port_in2,09h 
           mov ax,cur_temp2
           mov cur_temp,ax
           call Index_temp 
           
           mov port_in,10h
           mov port_in1,12h
           mov port_in2,11h 
           mov ax,cur_temp3
           mov cur_temp,ax
           call Index_temp 
                      
           mov port_in,20h
           mov port_in1,22h
           mov port_in2,21h 
           mov ax,cur_temp4
           mov cur_temp,ax
           call Index_temp   
           ret                                                                           
           
Vivod_rt endp

Vivo_Pult proc near
          
          mov al,Lampa
          test al,1
          jnz v1           
          test al,2
          jnz v2          
          test al,4
          jnz v3
          jmp v4
v1:        mov bx,4
           jmp v5       
v2:        mov bx,2
           jmp v5
v3:        mov bx,0
           jmp v5
           
v5:       mov ah,04h
           test Nomer,ah
           jnz s1
           
           shl ah,1
           test Nomer,ah
           jnz s2
           
           shl ah,1
           test Nomer,ah
           jnz s3
           
           shl ah,1
           test Nomer,ah
           jnz s4
           
           jmp s5
           
s1:        mov dx,cur_temp1+bx
           mov cur_temp,dx
           jmp s5 
           
s2:        mov dx,cur_temp2+bx
           mov cur_temp,dx
           jmp s5

s3:        mov dx,cur_temp3+bx
           mov cur_temp,dx
           jmp s5

s4:        mov dx,cur_temp4+bx
           mov cur_temp,dx 
                                                      
s5:       mov port_in,44h    
          mov port_in1,46h
          mov port_in2,45h
          call Index_temp   ;�뢮� cur_temp �� ����
v4:       ret
Vivo_Pult endp



Scan_Key proc near
           in al,1
           mov Key,al
           ret
Scan_Key endp

Graniza proc near
           
           mov al,Key
           and al,00000111b
           cmp al,0
           jz g1
           mov ah,Lampa
           and ah,11111000b
           or ah,al
           mov Lampa,ah
g1:        ret
Graniza endp

Rejim proc near          ;��ࠡ�⪠ ������ ������ ��⠭����
                             ;�������� ������ ��⠭����
           test OLdKey,01000000b
           jnz r1
           test Key,01000000b
           jz r1
           
           xor Mode,1
           test Lampa,8h
           jz r2
           and Lampa,11110111b
           jmp r1
r2:        or Lampa,8h   
           
r1:        mov al,Key
           mov OldKey,al
           ret
Rejim endp

Ustanovka proc near

           cmp Mode,1
           jne u6
           
           test Key,00011000b
           jz u8                 ;�᫨ ������ �� ������
           
           mov al,Lampa
           test al,1
           jnz uv1           
           test al,2
           jnz uv2          
           
u6:        jmp u1  
u8:        jmp u4         
           
uv1:        mov bx,4
           jmp uv5       
uv2:        mov bx,2
           jmp uv5
           
uv5:       mov ah,04h
           test Nomer,ah
           jnz us1
           
           shl ah,1
           test Nomer,ah
           jnz us2
           
           shl ah,1
           test Nomer,ah
           jnz us3
           
           shl ah,1
           test Nomer,ah
           jnz us4
           
           jmp us5
           
us1:        lea si,cur_temp1
            jmp us5 
           
us2:        lea si,cur_temp2
            jmp us5

us3:        lea si,cur_temp3
            jmp us5

us4:        lea si,cur_temp4

us5:       test Key,00010000b    ;�����?
           jnz u2
           test Key,00001000b    ;����?       
           jnz u3
           jmp u1
                       
u2:        cmp word ptr[si+bx],0ffffh          ;
           jz u1
           mov ax,schet
           add word ptr[si+bx],ax
           jnc u5
           mov word ptr[si+bx],0ffffh
u5:        add schet,16           
           jmp u1
           
           
u3:        cmp word ptr[si+bx],0              ;
           jz u1
           mov ax,schet
           sub word ptr[si+bx],ax
           jnc u7
           mov word ptr[si+bx],0
u7:        add schet,16           
           jmp  u1 
           
u4:        mov schet,64  

           
u1:        ret
Ustanovka endp

Slegenie proc near
           cmp Mode,1
           jz sl1
           lea si,cur_temp1
           mov bl,4
sl5:        mov ax,[si]
           mov dx,[si+2]
           shr ax,6
           shr dx,6
           cmp ax,dx
           jb sl2                 ;���室 �᫨ cur<li
           mov dx,[si+4]
           shr dx,6
           cmp ax,dx
           ja sl3                 ;���室 �᫨ cur>hi
           
           mov dh,11111100b       ;����塞 ��������, �᫨ ��
           mov cl,bl
           shl cl,1
           rol dh,cl
           and Lampa2,dh
           jmp sl4       
               
sl2:       mov dh,11111100b
           mov cl,bl
           shl cl,1
           rol dh,cl
           and Lampa2,dh
           mov dh,00000010b
           rol dh,cl
           or Lampa2,dh
           jmp sl4
           
sl3:       mov dh,11111100b
           mov cl,bl
           shl cl,1
           rol dh,cl
           and Lampa2,dh
           mov dh,00000001b
           rol dh,cl
           or Lampa2,dh
           jmp sl4
           
sl4:       add si,6
           dec bl
           cmp bl,0
           jnz sl5
                    
sl1:       ret
Slegenie endp

Signal proc near             ;���ﭨ� ��⥬� �� ����

           mov ah,04h
           test Nomer,ah
           jnz t1
           shl ah,1
           test Nomer,ah
           jnz t2
           shl ah,1
           test Nomer,ah
           jnz t3
           shl ah,1
           test Nomer,ah
           jnz t4
           
t1:        mov al,Lampa2             ;��� ��ࢮ�� ����饭��
           shl al,6
           and Lampa,00111111b
           or Lampa,al
           jmp t5
t2:        mov al,Lampa2             ;��� ��ண� ����饭��
           and al,11000000b
           and Lampa,00111111b
           or Lampa,al
           jmp t5
t3:        mov al,Lampa2             ;��� ���쥣� ����饭��
           shl al,2
           and al,11000000b
           and Lampa,00111111b
           or Lampa,al
           jmp t5
t4:        mov al,Lampa2             ;��� 4 ����饭��
           shl al,4
           and al,11000000b
           and Lampa,00111111b
           or Lampa,al
           jmp t5   
           
t5:        ret
Signal endp

Vivo_Lampa proc near         ;�뢮� ���ﭨ� ��⥬� � �뢮� �������஢
           mov al,Lampa
           out 1,al
           mov al,Lampa2
           out 2,al
           ret
Vivo_Lampa endp


Start:
           mov ax,Data
           mov ds,ax
           mov es,ax
           mov ax,Stk
           mov ss,ax
           lea sp,StkTop
          
;����� ࠧ��頥��� ��� �ணࠬ��

           call Init                 ;���樠������ ��६�����           
p1:        call Scan_Key             ;���뢠��� ���祭�� ������ �� ����             
           call ADC_Start            ;�⮡����騩 ᨣ��� �� ���
           call Save_Cur_temp        ;��࠭塞 ࠡ���� ⥬�������
           call Kn_Nomer             ;����砥� ����� ����饭�� ��� �⮡ࠦ����
           call Graniza              ;������ �� � �� � ��     
           call Rejim                ;����祭�� ०��� ࠡ��� ��⥬�
           call Ustanovka            ;��ࠡ�⪠ ������ ����� � ����
           call Slegenie             ;��।��塞 ���ﭨ� ��⥬�
           call Signal               ;�뢮��� ���ﭨ� ��⥬�
           call Vivod_rt          ;�뢮� �� ����饭��
           call Vivo_Pult         ;�뢮� �ᥫ �� ����   
           call Vivo_Lampa        ;�뢮� �������஢ �� ���� 
           jmp p1
           


;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
