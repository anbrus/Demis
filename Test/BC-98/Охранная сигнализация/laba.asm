.386
;������ ���� ��� � �����
RomSize    EQU   8192

kol_d=10h

PortIndP1=09h
PortIndP2=011h
PortIndV1=010h
PortIndV2=012h
zader=0FFh

Data       SEGMENT AT 3000h use16
  datv       db 16 dup (?) ; ��ࠧ ���稪�� ������
  datp       db 16 dup (?) ; ��ࠧ ���横�� �����
  obrkl      db 16 dup (?) ; ���ᨢ ����஫��㥬�� ������ 
  Flag       db 16 dup (?) ; ��ࠧ ����������
  vorr       db ?          ; ��ࠧ ������ "����஫� ������"
  pog        db ?          ; ��ࠧ ������ "����஫� �����"
  Flag_pogar db ?          ;䫠� ����� 
  Flag_vor   db ?          ;䫠� ������
  ind_p db 17 DUP(?)       ;���ᨢ ������ �ࠡ��뢠��� ���稪�� �����
  ind_v db 17 DUP(?)       ;���ᨢ ������ �ࠡ��뢠��� ���稪�� ������
  mig_p db ?
  mig_v db ?
  zader2 db ?
Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT AT 4180h use16
           dw    10 dup (?)     ;������ ����室��� ࠧ��� �⥪�
StkTop     Label Word
Stk        ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�
           ASSUME cs:Code,ds:Data,es:Data
 VOR        db 07Fh,03Fh,067h                 ; ���� ᫮�� "���"
 POGAR      db 02Fh,03Fh,06Dh,06Dh,06Fh,067h  ; ���� ᫮�� "�����"
 Cicle      db  2h                            ; �᫮ ॣ���஢ ����஫��㥬�� ������ ��������
                                              ; �� 8 (ࠧ�來���� ���⮢)
        
NullArray  PROC                 ; ��楤�� ���㫥��� ���ᨢ�� ������
           mov al,8
           mul Cicle
           mov si,ax
     nul:  mov obrkl[si-1],0h
           mov datp[si-1],0h
           mov datv[si-1],0h
           dec si
           jnz nul
           ret
NullArray  ENDP

QuizSensorsVor PROC            ; ���� ���稪�� ������ � �ନ஢���� �� ��ࠧ�
           mov cl,Cicle        ; ����㦠�� ������⢮ ���⮢, � ����� ������祭� ���稪� �
                               ; ���稪 ���譥�� 横�� 
           xor ax,ax
   next1:                      
           mov al,2            ; ����砥� �����  ���襣� ���� 
           mul cl              ;   ���稪�� ������
           mov dx,ax           ;
           dec dx              ;   
           in al,dx            ; ���뢠�� ����� � ����
           
           xor bx,bx           ; ���� ����襣� �����
           mov bl,cl           ;   ���ᨢ� ��ࠧ� ���ﭨ�
           dec bl              ;     ���稪�� ������
           shl bl,3            ;
           mov si,8h           ;
   next2:  shl al,1                   ; �ᯠ���뢮�� ����� ���� � ���祭��� ���稪��
           jnc a1                     ; �᫨ ���稪 �ࠡ�⠫, � 
           mov datv[si+bx-1],000h     ;   ��ᢠ����� ��६����� ��� ��ࠦ���� 0h,
           jmp a2                     ; 
      a1:  mov datv[si+bx-1],0FFh     ;   �᫨ ���, � - 0FFh 
      a2:  dec si                     ;   
           jnz next2   
           dec cl
           jne next1   
           ret        
QuizSensorsVor ENDP
           
QuizSensorsPog PROC                   ; ���� ���稪�� ����� � �ନ஢���� �� ��ࠧ�
           mov cl,Cicle               ; ࠡ�� ��楤��� �����⢫塞�� �������筮
           xor ax,ax                  ;  ��楤�� "���� ���稪�� ������" 
   next3:                      
           mov al,2
           mul cl
           mov dx,ax
           sub dx,2
           in al,dx
           
           xor bx,bx
           mov bl,cl
           dec bl
           shl bl,3
           mov si,8h
           
   next4:  shl al,1
           jnc a3
           mov datp[si+bx-1],000h
           jmp a4
      a3:  mov datp[si+bx-1],0FFh
      a4:  dec si
           jnz next4   
           dec cl
           jne next3   
           ret        
QuizSensorsPog ENDP

KeyControl PROC                      ; ��ନ஢���� ������ � ������� ���⠢������ �� ����஫�
                     
           mov cl,Cicle
           mov al,2
           mul cl
           mov dx,ax
           inc dx
           
   next5:  xor bx,bx
           mov bl,cl
           dec bl
           shl bl,3
           mov si,8h
           
           in al,dx
           
   next6:  shl al,1
           jnc a5
           cmp Flag[si+bx-1],0FFh
           je a6
           xor obrkl[si+bx-1],0FFh
           mov Flag[si+bx-1],0FFh
           jmp a6
      a5:  mov Flag[si+bx-1],000h
      a6:  dec si
           jnz next6  
           dec dx
           dec cl
           jnz next5
           
           add dl,Cicle 
           inc dx
           in  al,dx
           shr al,1
           jnc n1
           mov pog,0FFh
           jmp n2
      n1:  mov pog,000h 
      n2:  shr al,1
           jnc n3
           mov vorr,0FFh
           jmp n4
      n3:  mov vorr,000h 
      n4:
           ret   
KeyControl ENDP


zag_vor    proc near   ;��楤�� �뢮�� ᫮�� ��� 
           mov dx,0
           mov al,flag_vor
           test al,0FFh
           jz m11           
           lea bx,VOR
      m1:  mov ax,cs:[bx]
           out dx,ax
           inc bx
           inc dx
           cmp bx,2
           jb m1
           ret
      m11: mov al,0h
           out dx,al
           inc dx
           cmp dx,3
           jne m11                
           ret
zag_vor    endp                      

zag_pogar  proc near   ;��楤�� �뢮�� ᫮�� �����
           mov dx,3
           mov al,flag_pogar
           test al,0FFh
           jz m6           
           mov bx,offset POGAR
      m2:  mov ax,cs:[bx]
           out dx,ax
           inc bx
           inc dx
           cmp bx,8
           jb m2
           ret
      m6:  mov al,0h
           out dx,al
           inc dx
           cmp dx,9
           jne m6                
           ret
zag_pogar  endp


prov_datv  proc near ;�஢�ઠ ���稪�� ������
           mov al,vorr    ;�஢�ઠ �� ����祭�� �ᥩ ᨣ������樨
           test al,0FFh
           jnz mn7
           mov al,0
           mov flag_vor,al ;��� 䫠�� ������
           test al,0FFh
           jz m7
      mn7: xor ax,ax
           mov flag_vor,al ;��� 䫠�� ������
           xor cx,cx
           xor di,di
           mov cx,kol_d
           mov di,1
      m10: mov si,cx
           dec si
           mov al,obrkl[si] ;������ ��ࠧ� ����������
           test al,0FFh      ;�஢�ઠ ������� ������, �᫨ ᨣ�������� � ������ �⪫�祭� 
           jnz m8             ;� ���稪 ������ � �⮩ ������ �� ������������
           mov al,datv[si]    ;������ ���稪�� ������ �� ���. ᨣ������樨
           test al,0FFh      
           jnz m8
           mov al,0FFh     ;����� 䫠�� ������
           mov flag_vor,al   
           xor ax,ax
           mov ax,si
           mov ind_v[di],al
           inc di
           
       m8: loop m10
           dec di
           mov ax,di
           mov ind_v[0],al
       m7: ret  
prov_datv  endp 

prov_datp  proc near  ; �஢�ઠ ���稪�� �����
           mov al,pog
           test al,0FFh ;�஢�ઠ �� ����祭�� ����୮� ᨣ������樨
           jnz m9         ;�᫨ �� ����祭� � �ய�����
           mov al,0
           mov flag_pogar,al
           test al,0FFh
           jz m3
       m9: mov al,0
           lea bp,ind_p
           xor di,di
           mov flag_pogar,al ;��� 䫠�� �����
           mov di,1
           xor cx,cx
           mov cx,kol_d    ;����㧪� ���稪� ���訢����� ���稪�� 
       m5: mov si,cx
           dec si
           mov al,datp[si]
           test al,0FFh  ;�஢�ઠ ���稪� �� �ࠡ��뢠���
           jnz m4         ;�᫨ ���稪 � ����� ������� �����뢠���� � ���ᨢ  
           mov [bp+di],si  ;ind_p, ��稭�� � ��ࢮ� �祩�� 
           inc di          
       m4:loop m5
           dec di         ;��饥 �������⢮ ������, ��� �ࠡ�⠫� ����ୠ� ᨣ�������� 
           mov ax,di
           mov [bp+0],al ;� ���� ����� ���ᨢ� �����뢠�� ��饥 ���. ������, ��� ���� �����         
           cmp di,0
           je m3
           mov al,0FFh   ;�᫨ �ࠡ�⠫ ��� �� 1 ���稪, � 䫠� ����� ����������.
           mov flag_pogar,al   
       m3: ret
prov_datp  endp     

mig_pogara proc near         ;��楤�� ��ࠡ�⪨ �������஢ �����
           mov al,pog
           test al,0FFh
           jz m99
           mov al,flag_pogar ;�஢�ઠ 䫠�� �����
           test al,0FFh      ;�᫨ ��� �����, � ����� �� ���������
           jz m22  
           mov al,mig_p      ;�஢�ઠ 䫠�� �������
           cmp al,0          ;�᫨ 0,�
           jne m20
           mov al,mig_p
           mov al,zader       ;��⠭����� 16(10) 
           mov mig_p,al
      m20: cmp al,zader2         ;�᫨ 䫠� ������� ����� 8, � ����� �� ���������  
           ja m15            ;��ᬮ��� �� �����
           xor di,di
           mov cx,0          
           lea bp,ind_p      ;����㧪� ��砫쭮�� ���� ���ᨢ� ����஢ ������, ��� �ந��襫 
           xor ax,ax         ;�����, ���� ����� ���ᨢ� �����뢠�� ��饥 ���. ������, � �����
           mov si,1
           mov dx,[bp]
           xor dh,dh
           mov di,dx         ;��㧨� ��饥 ���. ������ � ���. �ந��襫 �����
      m18: mov dx,0Fh        ;��饥 ���. ��� ������ � ���
           sub dx,cx         ;��।��塞 ����� � ���� ���孥�� �⠦�
           mov bx,[bp+si]    ;�ࠢ������ ��� ����� � ����஬ ����饩 �������
           cmp dl,bl         ;�᫨ ࠢ��, � ��� ࠧ�� ����室��� �뤥���� 
           jne m16
           cmp di,0          ;�᫨ �� ࠢ��, �  
           je m16
           shl ax,1          ;��� �뤥����� �� ᤢ����� १���� �� 1 ����� 
           add ax,1          ;�ਡ���塞 1, �.� �����뢠�� 1 � ����訩 ࠧ��
           dec di            ;㬥��蠥� ���. ������ ������ 
           inc si            ;���室�� � ᫥���饬� �砣�
           jmp m17
      m16: shl ax,1          ;ᤢ�� १���� �� 1 �����
      m17: inc cx            ;㢥��稢��� �� 1 ���稪, �.� ���室�� � ᫥������ �������
           cmp cx,10h        ;�� �� ������� ��諨, �᫨ ��� � �����
           jne m18           
           not ax            ;�᫨ �� � �������㥬 �� ࠧ���, �.� �������� ����ࠥ��� 1   
           out 9h,al         ;�뢮��� � ���� ����訥 ࠧ��� १����
           mov al,ah
           out 11h,al        ;�뢮��� � ���� ���訥 ࠧ��� १����
           mov al,mig_p
           dec al       ;���६���஢���� ��६����� �������,�� ������� , �⮡� ���ᯥ���
           mov mig_p,al ;ࠢ����୮� �஬�������� 
           jmp m19
      m15: mov al,mig_p 
           dec al       ;���६���஢���� ��६����� �������
           mov mig_p,al
      m22: mov ax,0FFh  ;  
           out PortIndP1,al    ;����� �� ��������� �⢥��騥 �� �����
           out PortIndP2,al
           jmp m19
      m99: mov al,000h
           out PortIndP1,al    ;��ᨬ ���稪� �ਢ몫�祭�� ᨣ������樨
           out PortIndP2,al     
      m19: ret 
mig_pogara endp
 
ind_vz     proc  near       ;
           mov al,vorr
           test al,0FFh
           jz m98
           mov al,flag_vor ;�஢�ઠ 䫠�� ������
           test al,0FFh    ;�᫨ ��� ������, � ��������� ⮫쪮 �����
           jz m31
           mov al,mig_v
           cmp al,0
           jne m50
           mov al,zader
           mov mig_v,al
      m50: mov al,mig_v 
           dec al       ;���६���஢���� ��६����� �������
           mov mig_v,al
           cmp al,zader2
           ja m26   
           
      m31: xor ax,ax
           xor cx,cx
           mov cx,kol_d
           
      m29: mov si,cx
           dec si
           mov dl,obrkl[si]
           test dl,0FFh
           jnz m28
           shl ax,1
           or ax,01h
           dec cx
           cmp cx,0
           jne m29
           cmp cx,0
           je m30
      m28: shl ax,1
           dec cx
           cmp cx,0
           jne m29     
      m30: out POrtIndV1,al    ;����� �� ��������� �⢥��騥 �� �����
           mov al,ah
           out POrtIndV2,al   ;
           jmp m26
      m98: mov al,000h
           out PortIndV1,al
           out PortIndV2,al     
      m26: ret
ind_vz     endp 

mig_vor      proc near

           mov al,flag_vor ;�஢�ઠ 䫠�� ������
           test al,0FFh    ;�᫨ ��� ������, � ��室
           jz m35
           
           mov al,mig_v      ;�஢�ઠ 䫠�� �������
           cmp al,0          ;�᫨ 0,�
           jne m36
           
           mov al,mig_v
           mov al,zader       ;��⠭����� 16(10) 
           mov mig_v,al
      m36: cmp al,zader2        ;�᫨ 䫠� ������� ����� 8, � ����� �� ���������  
           jbe m35            ;��ᬮ��� �� �����
           xor ax,ax
           xor dx,dx
           xor cx,cx
           mov dl,ind_v[0]
           mov di,dx
           mov si,1 
           
      m40: mov dl,0Fh 
           sub dl,cl
           mov bx,si
           mov si,dx
           mov dh,obrkl[si]
           cmp dh,00h
           jne m37      
           
           mov si,bx
           mov dh,ind_v[si]
           cmp dh,dl
           jne m39
           
           cmp di,0
           je m39 
           inc si
           mov bx,si
           dec di
      m37: mov si,bx
           shl ax,1
           or ax,1
           jmp m38
      m39: shl ax,1
      m38: inc cx            ;㢥��稢��� �� 1 ���稪, �.� ���室�� � ᫥������ �������
           xor dh,dh     
           cmp cx,10h        ;�� �� ������� ��諨, �᫨ ��� � �����
           jne m40           
           not ax            ;�᫨ �� � �������㥬 �� ࠧ���, �.� �������� ����ࠥ��� 1   
           out PortIndV1,al  ;�뢮��� � ���� ����訥 ࠧ��� १����
           mov al,ah
           out PortIndV2,al  ;�뢮��� � ���� ���訥 ࠧ��� १����
           mov al,mig_v
           dec al            ;���६���஢���� ��६����� �������,�� ������� , �⮡� ���ᯥ���
           mov mig_v,al      ;ࠢ����୮� �஬�������� 
      m35: ret
mig_vor      endp 

init       proc near
           xor al,al
           mov mig_p,al
           mov mig_v,al
           mov al,zader
           shr al,1
           mov zader2,al
           ret
init       endp            
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           call  init
           call  NullArray
Nnn:       call  QuizSensorsVor
           call  QuizSensorsPog
           call  KeyControl
           call prov_datp
           call prov_datv
           call zag_vor
           call zag_pogar
           call ind_vz
           call mig_pogara
           call mig_vor
           jmp nnn

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
