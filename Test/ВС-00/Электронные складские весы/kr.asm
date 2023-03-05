.386
;������ ���� ��� � �����
RomSize    EQU   4096
NMax       EQU 50

; ���� ���⮢
Ind1       EQU 020h   ; ����� �뢮�� ��
Ind2       EQU 010h   ; ᥬ�ᥣ����� ���������
Ind3       EQU 08h    ; 
Ind4       EQU 04h    ; 
Ind5       EQU 02h    ; 
DigIndT    EQU 0Bh    ; ���� T ����� � ������ � �뢮�� �� ������ ���������
KeyIn      EQU 0h     ; ���� ����� � ����������
KeyOut     EQU 0h     ; ���� �뢮�� � ����������
AcpOut     EQU 06h    ; ���� ����� � ���
AcpIn1     EQU 06h    ; ���� �뢮�� ��ࢮ�� �᫠ �� ���
AcpIn2     EQU 08h    ; ���� �뢮�� ��ண� �᫠ �� ���
AcpRdy     EQU 0Ah    ; ���� �������� ��⮢����


IntTable   SEGMENT AT 100 use16
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Data       SEGMENT AT 40h use16
;����� ࠧ������� ���ᠭ�� ��६�����
Mode     DB ?                      ; ����� (ॣ������-����/�뢮�-��ᬮ��)
Typt     DB ?                      ; ��� ⮢�� (5 ⨯��)
NMX      DB ?                      ; ����� (����-�뢮�-�� ᪠����)
KbdImage DB 5 Dup (?)              ; ��ࠧ ����������
Key      DB ?                      ; ������ ��� ����⮩ ������
Weight   DW ?                      ; ����騩 ���
Real     DW ?                      ; ����쭮� ���祭�� ���
Base     DW ?                      ; �㫥��� ���祭�� ��ᮢ
ZerWgh   DW ?                      ; ��६����� ��⠭���� � ����
Nomer    DB 5 Dup (?)              ; ������⥫� ����� (� ᤢ���� � ����)
CntNom   DB ?                      ; ���稪 ��������� ��� �����
CntLet   DB ?                      ; ���稪 �㪢 �ਨ �����
Insk     DW 5 Dup (?)              ; ��� ⮢�஢ �� ᪫��� (�� ⨯��)
Imp      DW 5 Dup (?)              ; ��� ⮢�஢ ��������� �� ᪫�� (�� ⨯��)
Exp      DW 5 Dup (?)              ; ��� ⮢�஢ �뢥������ � ᪫��� (�� ⨯��)
RegCur   DB ?                      ; ����饥 �᫮ ��ॣ����஢����� ��設
NomCur   DB ?                      ; ����� ����� � ��設� � ॣ����樮���� ���ᨢ� (��� ���᪠)
WghBin   DB 5 Dup (?)              ; ���ᨢ ������� ��� ���
RegMas   DB 100d Dup (10d Dup (?)) ; �������樮��� ���ᨢ (�� ᪫���)

;�訡��:
EmpKbd   DB ?                      ; ����� ���������
KbdErr   DB ?                      ; ����⨥ ����� ���� ������
WghErr   DB ?                      ; �ॢ�襭�� ���
CurErr   DB ?                      ; �ॢ�襭�� ���ᨬ��쭮�� �᫠ ॣ�����㥬�� ��設
ExpErr   DB ?                      ; �訡�� �����
ImpErr   DB ?                      ; �訡�� �뢮��
InsErr   DB ?                      ; �ॢ�襭�� ��� �� ᪫���
ZerErr   DB ?                      ; �訡�� ��⠭���� � ����
  
NotReg   DB ?                      ; ��設� �� ��ॣ����஢���

Hlp      DW ?                      ;�ᯮ����⥫�� ��६����
Hlp1     DB ?
Hlp2     DW ?
ACP1     DB ?
ACP2     DB ?
Data     ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT AT 100h use16
;������ ����室��� ࠧ��� �⥪�
           dw    2 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

InitData   ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�
           ;��ࠧ� 10-����� ᨬ�����: "0", "1", ... "9"
Digit      DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h
           ;��ࠧ� �㪢 �ਨ �����
Letter     DB    06Fh,079h,033h,07Ch,073h,063h,03Bh,06Dh,021h,01Ch
           DB    031h,068h,03Fh,067h,060h,05Bh,071h,038h,05Dh

           ASSUME cs:Code,ds:Data,es:Data
           
; �ᯮ��塞� ���㫨
;-------------------------------------------------------------------------------------------
; "�㭪樮���쭠� �����⮢��"
FuncPrep PROC NEAR
         mov EmpKbd,0      ;���㫥��� 䫠��� �訡��
         mov KbdErr,0      
         mov WghErr,0      
         mov CurErr,0 
         mov ExpErr,0
         mov ImpErr,0
         mov InsErr,0
         mov NotReg,0
         mov ZerErr,0
         mov RegCur,0      ;���㫥��� ���稪� ��設
         xor al,al
         mov NomCur,al
         mov CntNom,0      ;���㫥��� ���稪� ��� �����
         mov CntLet,0h     ;���㫥��� ���稪� �㪢 �ਨ �����
         mov Key,0         ;���㫥��� ������
         mov ZerWgh,0      ;���㫥��� ᬥ饭�� ��� �⭮�⥫쭮 ���
         mov al,020h        
         mov Mode,al       ;���� ०��� "���������" �� 㬮�砭��
         mov NMX,al        ;���� ०��� "�� ᪫��" �� 㬮�砭��
         mov al,01h
         mov Typt,al       ;���� ⨯� ⮢�� "1" �� 㬮�砭��
         mov al,0FFh
         mov Base,0
         mov Weight,0
         mov ACP1,al        ;��� ��⨢��
         mov ACP2,al        ;��� ��⨢��
          
         lea si,Nomer       ;���㫥��� �� ᪫���
         mov [si+0],0h 
         mov [si+1],0h 
         mov [si+2],0h 
         mov [si+3],0h 
         mov [si+4],0h 
         
         lea si,Insk
         mov word ptr[si+0],0h 
         mov word ptr[si+2],0h 
         mov word ptr[si+4],0h 
         mov word ptr[si+6],0h 
         mov word ptr[si+8],0h 
          
         lea si,Exp
         mov word ptr[si+0],0h 
         mov word ptr[si+2],0h 
         mov word ptr[si+4],0h 
         mov word ptr[si+6],0h 
         mov word ptr[si+8],0h 

         lea si,Imp
         mov word ptr[si+0],0h 
         mov word ptr[si+2],0h 
         mov word ptr[si+4],0h 
         mov word ptr[si+6],0h 
         mov word ptr[si+8],0h 
            
         ret
FuncPrep ENDP
;-------------------------------------------------------------------------------------------
; 1. ����� �뢮�� ᮮ�饭�� �� �訡���
ErMesOut PROC NEAR
         cmp KbdErr,0FFh   
         je EMO1           
         cmp WghErr,0FFh   
         je EMO2           
         cmp CurErr,0FFh   
         je EMO4           
         cmp ImpErr,0FFh   
         je EMO5           
         cmp ExpErr,0FFh   
         je EMO6           
         cmp NotReg,0FFh
         je EMO7
         cmp InsErr,0FFh
         je EMO8
         jmp EMO3          
 EMO1:   mov al,03Fh        
         out 016h,al  
         jmp EMOe          
 EMO2:   mov al,0Ch        
         out 016h,al
         jmp EMOe          
 EMO4:   mov al,076h        
         out 016h,al
         jmp EMOe          
 EMO5:   mov al,05Eh        
         out 016h,al
         jmp EMOe          
 EMO6:   mov al,04Dh        
         out 016h,al
         jmp EMOe
 EMO7:   mov al,05Bh        
         out 016h,al
         jmp EMOe
 EMO8:   mov al,07Bh
         out 016h,al
         jmp EMOe
 EMO3:   xor al,al
         out 016h,al
 EMOe:   ret 
ErMesOut   ENDP
;-------------------------------------------------------------------------------------------
; 2.1. �������� ��襭�� �ॡ����
VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
           mov   bh,0        ;���� ����稪� ����७��
VD2:       in    al,dx       ;���� ⥪�饣� ���ﭨ�
           cmp   ah,al       ;����饥 ���ﭨ�=��室����?
           jne   VD1         ;���室, �᫨ ���
           inc   bh          ;���६��� ����稪� ����७��
           cmp   bh,50;NMax  ;����� �ॡ����?
           jne   VD2         ;���室, �᫨ ���
           mov   al,ah       ;����⠭������� ���⮯�������� ������
           ret
VibrDestr  ENDP
;-------------------------------------------------------------------------------------------
; 2. ����� ����� ०����
ModInp    PROC NEAR
        mov al,Key
   mi5: cmp al,011h    ;R1
        jne mi6
        mov al,020h
        mov Mode,al
        jmp m3
   mi6: cmp al,012h    ;R2
        jne mi7
        mov al,040h
        mov Mode,al
        jmp m3
   mi7: cmp al,013h    ;R3
        jne m3
        mov al,080h
        mov Mode,al
        jmp m3
      m3: in al,DigIndT     
          ;call VibrDestr
          cmp al,01h
          jne m4
          mov Typt,al
          jmp m8
      m4: cmp al,02h
          jne m5
          mov Typt,al
          jmp m8
      m5: cmp al,04h
          jne m6
          mov TypT,al
          jmp m8
      m6: cmp al,08h
          jne m7
          mov Typt,al
          jmp m8
      m7: cmp al,010h
          jne m8
          mov Typt,al
      m8: in al,DigIndT
          ;call VibrDestr
          cmp al,020h
          jne m9
          mov NMX,al
          jmp m11
      m9: cmp al,040h
          jne m10
          mov NMX,al
          jmp m11           
     m10: cmp al,080h
          jne m11
          mov NMX,al
     m11: ret
ModInp    ENDP
;-------------------------------------------------------------------------------------------
; 3. ����� ����� � ���������� 
KbdInput PROC NEAR
         lea si,KbdImage       
         mov cx,Length KbdImage
         mov bl,01h          ;�뢮� �� �������� � ���� ���������� ���祭�� Mode
         mov dl,Mode
   km0:  mov al,dl
         or  al,bl          
         out KeyOut,al    
         in al,KeyIn   
         cmp al,0h            
         je km2            
         ;call VibrDestr     
         mov [si],al        
   km1:  in al,KeyIn   
         cmp al,0h         
         jne km1            
         ;call VibrDestr     
         jmp km3     
   km2:  mov [si],al        
   km3:  inc si             
         rol bl,1           
         loop km0           
         ret 
KbdInput ENDP 
;-------------------------------------------------------------------------------------------
; 4. ����� ����஫� ����������
KbdContr PROC NEAR
         lea bx,KbdImage    ;����㧪� ����
         mov cx,Length KbdImage           ;� ���稪� ��ப
         mov EmpKbd,0       ;���⪠ 䫠���
         mov KbdErr,0
         mov dl,0           ;� ������⥫� 
   m13:  mov al,[bx]        ;�⥭�� ��ப�
         mov ah,5;4         ;����㧪� ���稪� ��⮢ 
         shl al,1
   m14:  dec ah             ;������ ���
         cmp ah,0
         je m15             ;���室 �᫨ �� ���� � ��ப�
         shr al,1           ;�뤥����� ���
         cmp al,1           ;��� ��⨢��?
         jne m14            ;���室,�᫨ ���
         inc dl             ;���६��� ������⥫�
         jmp m14
   m15:  inc bx             ;����䨪��� ���� ��ப�
         loop m13           ;�� ��ப� ? ���室,�᫨ ���
         cmp dl,0           ;������⥫�=0 ?
         je m16             ;���室,�᫨ ��
         cmp dl,1           ;������⥫�=1 ?
         je m17             ;���室,�᫨ ��
         mov KbdErr,0FFh    ;��⠭���� 䫠�� �訡��
         jmp Short m17     
   m16:  mov EmpKbd,0FFh    ;��⠭���� 䫠�� ���⮩ ����������
   m17:  ret
KbdContr ENDP 
;-------------------------------------------------------------------------------------------
; 5. ����� �८�ࠧ������ ��।��� ������
KeyTrf PROC NEAR
       cmp EmpKbd,0FFh    ;����� ��������� ?
       je m21             ;���室,�᫨ �� 
       cmp KbdErr,0FFh    ;�訡�� ���������� ?
       je m21             ;���室,�᫨ �� 
       lea bx,KbdImage    ;����㧪� ����  
       mov dh,0           ;�����⮢�� ������⥫�� ���� ��ப�(dh) 
       mov dl,3           ;� �⮫��(dl)
 m18:  mov al,[bx]        ;�⥭�� ��ப� 
       cmp al,0h          ;��ப� ��⨢�� ?
       jne m19            ;���室,�᫨ ��
       inc dh             ;���६��� ����� ��ப�
       inc bx             ;����䨪��� ����
       jmp short m18
 m19:  cmp al,1
       je m20             ;��� ��⨢�� ? ���室,�᫨ ��
       shr al,1           ;�뤥����� ᫥���饣� ��� ��ப�
       dec dl             ;���६��� ���� �⮫��
       jmp short m19
 m20:  mov cl,2           ;��ନ஢���� ����筮��
       shl dh,cl          ;���� ������
       or dh,dl    
       mov Key,dh     
 m21:  ret
KeyTrf ENDP
;-------------------------------------------------------------------------------------------
; 6. ����� "���� �� ���" 
ACPInp PROC NEAR
       ;��⠭���� ���
       cmp ACP1,0FFh
       jne Acpret
       mov WghErr,0     ;��� 䫠�� �訡�� �ॢ�襭�� ���
       mov al,0         ;�஢�ઠ ���
       out AcpOut,al
       mov al,1
       out AcpOut,al
 Rdy:  in  al,AcpRdy    ;��� ������� �� ��室� Rdy
       cmp al,1
       jne Rdy
       in al,AcpIn2
       mov ah,al
       in al,AcpIn1
       mov bx,ax         ;��室�� ���
       mov Real,bx
       cmp bx,Base
       jbe z1
       sub bx,Base       ;Real>Base
       cmp bx,040000d 
       jbe z2            ;���室 �᫨ ���
       mov WghErr,0FFh   ;����� 䫠�� �訡�� �ॢ�襭�� ���
       jmp Acpret
z2:    shr bx,2 
       mov Weight,bx
       jmp Acpret
z1:    mov Weight,0       ;Real<Base
Acpret: ret 
ACPInp ENDP
;-------------------------------------------------------------------------------------------
; 8. ����� �ନ஢���� ���ᨢ� �⮡ࠦ���� ��� ��㧠
WghTrf PROC NEAR
       xor al,al
       mov cx,Weight      ;�����⮢�� ���稪�
       lea si,WghBin      ;�����⮢�� ���� ⠡���� ��� ���
       mov [si+0],al      ;�����⮢�� �祥� �����
       mov [si+1],al
       mov [si+2],al
       mov [si+3],al
       mov [si+4],al
  wtA: xor al,al
 wtA0: cmp cx,0
       je wtE
       dec cx
       inc al
       mov [si+0],al
       cmp al,0Ah       
       jne wtA0
       xor al,al
       mov [si+0],al
       mov al,[si+1]
       inc al
       mov [si+1],al
       cmp al,0Ah       
       jne wtA
       xor al,al
       mov [si+1],al
       mov al,[si+2]
       inc al
       mov [si+2],al
       cmp al,0Ah        
       jne wtA
       xor al,al
       mov [si+2],al
       mov al,[si+3]
       inc al
       mov [si+3],al
       cmp al,0Ah         
       jne wtA
       xor al,al           
       mov [si+3],al
       mov al,[si+4]
       inc al
       mov [si+4],al
       jmp wtA
  wtE: ret
WghTrf ENDP         
;-------------------------------------------------------------------------------------------
; 9. ����� �뢮�� ���祭�� ��� �� ���������
DispWgh PROC NEAR
        ;��⠭���� ��⨢���� ���� ���
        cmp ACP2,0FFh
        jne dw1
        xor bh,bh  
        lea di,Digit
        lea si,WghBin
        mov bl,[si+0]
        mov al,cs:[di+bx]
        out Ind1,al
        mov bl,[si+1]       
        mov al,cs:[di+bx]
        out Ind2,al
        mov bl,[si+2]       
        mov al,cs:[di+bx]
        out Ind3,al
        mov bl,[si+3]       
        mov al,cs:[di+bx]
        out Ind4,al
        mov bl,[si+4]       
        mov al,cs:[di+bx]
        out Ind5,al
   dw1: 
        ret
DispWgh ENDP       
;-------------------------------------------------------------------------------------------
; 7. ����� �ନ஢���� ���ଠ樨
FormInf PROC NEAR
        mov al,KbdErr      ;���� �訡�� ? 
        or al,WghErr
        or al,CurErr      
        or al,ZerErr
        cmp al,0FFh        
        je fi1             ;���室,�᫨ ��
        cmp Mode,020h      ;�����="���������" ?
        je  fi2            ;���室,�᫨ �� 
        cmp Mode,040h      ;�����="�ਥ�/���㧪� ⮢��" ?
        je  fi3            ;���室,�᫨ �� 
        call ModeView      ;��ࠡ�⪠ ०��� "��ᬮ�� ���ﭨ� ᪫��� � ��ࠡ�⪨ ����⥫��" ?
        jmp fi1            
  fi2:  call ModeReg       ;��ࠡ�⪠ ०��� "���������"
        jmp fi1
  fi3:  call ModeNMX       ;��ࠡ�⪠ ०��� "�ਥ�/���㧪� ⮢��"
  fi1:  ret
FormInf ENDP
;-------------------------------------------------------------------------------------------
; 7.1. �������� ��ࠡ�⪨ ०��� "���������"
ModeReg PROC 
        cmp EmpKbd,0FFh ;��������� ����?
        jne mrs         ;���室 �᫨ ���
        ret             ;��室 �� ��楤���
   mrs: xor al,al
        mov ACP1,al     ;��� ���ᨢ��
        mov ACP2,al     ;��� ���ᨢ��
        mov al,Key
        cmp al,0Ah      ;����� "Seria+"
        jne mr0np
        call SeriesAdd
        jmp mrret       ;��室 �� ��楤���
 mr0np: mov al,Key
        cmp al,0Bh      ;����� "Seria-"
        jne mr0ns
        call SeriesSub
        jmp mrret       ;��室 �� ��楤���
 mr0ns: mov al,Key
        cmp al,0Ch      ;����� "Enter"?
        jne mr1         ;���室 �᫨ ���
        mov al,0FFh
        mov ACP1,al     ;��� ��⨢��
        mov ACP2,al     ;��� ��⨢��
   mre: call PersNomer  ;�஢�ઠ �� ����稥 ����� � ���ᨢ� 
        mov al,010d
        mul NomCur      ;NomCur - ��室��� �ࠬ��� ��楤��� PersNomer (����� ����� � �����)
        mov bx,ax       ;� bx ��室���� ���� ��������� �����
        add bx,06d      ;� bx ��室���� ᬥ饭�� �� ��� � ��������� �����
        lea di,RegMas   ;ᬥ饭�� ॣ����樮����� ���ᨢ�
        mov ax,Weight   ;�⠥� ⥪�騩 ���
        mov [di+bx],ax  ;������ ��� � ���ᨢ
        jmp mrret       ;��室 �� ��楤���
   mr1: mov al,Key
        cmp al,0Dh      ;����� "Delete"?  
        jne mr2         ;���室 �᫨ ���
        call PersNomer
        call Delet
        mov al,0FFh
        mov ACP1,al     ;��� ��⨢��
        mov ACP2,al     ;��� ��⨢��
        jmp mrret       ;��室 �� ��楤���
   mr2: cmp al,0Eh      ;����� "Reset"? 
        jne mr3         ;���室 �᫨ ���
        call Resett
        mov al,0FFh
        mov ACP1,al     ;��� ��⨢��
        mov ACP2,al     ;��� ��⨢��
        jmp mrret       ;��室 �� ��楤���
   mr3: cmp al,0Fh      ;����� "View"
        jne mr4
        mov al,0FFh
        mov ACP2,al     ;���-���� ��⨢��
        mov ACP1,al     ;��� ��⨢��
        jmp mrret
   mr4: cmp al,010h     ;����� "Zero"
        jne mr5         ;���室 �᫨ ���
        call Zero       ;��⠭���� � ���� ��ᮢ
        mov al,0FFh
        mov ACP1,al     ;��� ��⨢��
        mov ACP2,al     ;��� ��⨢��
        jmp mrret       ;��室 �� ��楤���
   mr5: cmp al,011h     ;R1
        jne mr6
        mov al,020h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al     ;��� ��⨢��
        mov ACP2,al     ;��� ��⨢��
        jmp mrret
   mr6: cmp al,012h     ;R2
        jne mr7
        mov al,040h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al     ;��� ��⨢��
        mov ACP2,al     ;��� ��⨢��
        jmp mrret
   mr7: cmp al,013h     ;R3
        jne mrfin
        mov al,080h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al     ;��� ��⨢��
        mov ACP2,al     ;��� ��⨢��
        jmp mrret
        ;�᫨ ��祣� �� �����, � �����뢠�� ��।��� ���� � �����:
mrfin:  mov NotReg,0    ;����塞 䫠� "��設� �� ��ॣ����஢���"
        xor bh,bh
        mov bl,CntNom
        mov [Nomer+bx],al
        inc bl
        cmp bl,04h      ;���稪 ���=4?
        jne mrc         ;���室 �᫨ ���
        xor bl,bl       ;���㫥��� ���稪� ��� 
  mrc:  mov CntNom,bl
mrret:  ret
ModeReg ENDP
;-------------------------------------------------------------------------------------------
; 7.2. �������� ���᪠ � �஢�ન ������ ���������� ����� � ���ᨢ�
PersNomer PROC NEAR
          mov NotReg,0      ;����塞 䫠� "��設� �� ��ॣ����஢���"
          mov dl,RegCur     ;�᫮ ��ॣ����஢����� ��設     
          cmp dl,0
          je pn5            ;���室 �᫨ ��� �� ����� ��ॣ����஢����� ��設�
          xor dl,dl         ;����塞 ���稪 ��ᬠ�ਢ����� ��設
          xor bx,bx
          xor cx,cx
          lea si,Nomer
          lea di,RegMas
     pn2: mov al,[di+bx]    ;��� ����� �� ���ᨢ�
          push bx
          mov bx,cx
          mov ah,[si+bx]    ;��� �᪮���� �����
          pop bx
          cmp al,ah         ;���� ᮢ����
          jne pn3           ;���室 �᫨ ���
          inc cx            ;᫥����� ��� �����
          inc bx
          cmp cx,05h        ;�� ���� ����� ���稫���?
          jne pn2           ;���室 �᫨ ���
          mov NomCur,dl     ;�᫨ �� ���� ᮢ����, ��࠭塞 ����� ��������� �����
          jmp pn4           ;��室 �� ��楤��� (��室��� ��ࠬ���-NomCur)
     pn3: sub bx,cx         ;᫥���騩 ����� � ॣ����樮���� ���ᨢ�
          add bx,0Ah        ;
          xor cx,cx
          inc dl            
          cmp dl,RegCur     ;�� ��設�?
          jne pn2           ;���室 �᫨ ���
          ;���쭥��� ��ࠡ�⪠ ���� � ��⮬ ⮣� �� �᪮���� ����� � ॣ. ���ᨢ� ��� 
     pn5: mov al,Mode
          cmp al,020h        ;०��="���������"?
          jne  pn7           ;���室 �᫨ ���
          cmp Key,0Ch       ;Enter?
          je pn1            ;���室 �᫨ ��
     pn7: mov NotReg,0FFh   ;����� 䫠�� "��設� �� ��ॣ����஢���"
          jmp pn4
    pn1:   ;ᮧ����� ����� �����
          lea si,Nomer
          lea di,RegMas
          mov al,RegCur
          cmp al,099d        ;�᫮ ��ॣ����஢����� ��設 = ���ᨬ��쭮��?
          je pnmax 
          mov al,010d
          mul RegCur
          mov bx,ax     ;� bx ��室���� ���� ᮧ������ �����
          xor cx,cx     ;����塞 ���稪 ���
     pn6: push bx
          mov bx,cx
          mov al,[si+bx] ;�⠥� ���� �᪮���� �����
          pop bx
          mov [di+bx],al ;�����뢠�� �� �� ����� ������ �����
          inc cx
          inc bx
          cmp cx,05h     ;�� ����?
          jne pn6        ;���室 �᫨ ���
          xor al,al
          mov [di+bx],al  ;����塞 ���-�� 室��
          mov cl,RegCur
          mov NomCur,cl  ;��࠭塞 ����� ����� � ��設� � ॣ����樮���� ���ᨢ� (��� ���᪠)
          inc RegCur
          jmp pn4
   pnmax: mov al,0FFh
          mov CurErr,al   ;����� 䫠�� �訡�� ��� ��設
     pn4: ret
PersNomer ENDP
;-------------------------------------------------------------------------------------------
; �������� ����� �ਨ ����� "+"
SeriesAdd PROC NEAR
          mov bl,CntLet
          lea si,Letter
          cmp bl,18
          jne sa1
          mov bl,0FFh
          mov CntLet,bl
     sa1: inc bl
          mov CntLet,bl
          xor bh,bh
          mov al,cs:[si+bx]
          mov [Nomer+4],bl       ;��࠭塞 ����� �㪢� �ਨ
          mov CntLet,bl
          ret
SeriesAdd ENDP
;-------------------------------------------------------------------------------------------
; �������� ����� �ਨ ����� "-"
SeriesSub PROC NEAR
          mov bl,CntLet
          lea si,Letter
          cmp bl,0
          jne ss1
          mov bl,19
          mov CntLet,bl
     ss1: dec bl
          mov CntLet,bl
          xor bh,bh
          mov al,cs:[si+bx]
          mov [Nomer+4],bl       ;��࠭塞 ����� �㪢� �ਨ
          mov CntLet,bl
          ret
SeriesSub ENDP
;-------------------------------------------------------------------------------------------
; 7.1.2. �������� 㤠����� ����� � ��������� �����
Delet PROC
      cmp NotReg,0FFh ;����� �������
      je drt
      lea di,RegMas
      mov al,010d
      mul NomCur      ;NomCur - ��室��� �ࠬ��� ��楤��� PersNomer (����� ����� � �����)
      mov bx,ax       ;� bx ��室���� ���� 㤠�塞�� �����
      mov Hlp,bx      ;Hlp=bx
      dec RegCur
      mul RegCur
      mov bx,ax       ;� bx ��室���� ���� ��᫥���� �����
      mov dx,bx       ;dx=bx
      mov cx,05h      ;���稪 ᫮�
 dlt: mov bx,dx
      mov ax,word ptr[di+bx]
      mov bx,Hlp
      mov word ptr [di+bx],ax  ;��९�ᠫ� ��ࢮ� ᫮��
      inc dx
      inc dx
      inc Hlp
      inc Hlp
      loop dlt
 drt: ret
Delet ENDP
;-------------------------------------------------------------------------------------------
; 7.1.1. �������� ���
Resett PROC
       mov dl,NMX
       cmp dl,020h
       jne r1
       lea si,Imp
       jmp r3
   r1: cmp dl,040h
       jne r2
       lea si,Exp
       jmp r3
   r2: lea si,Insk
   r3: xor ax,ax
       mov word ptr[si],ax
       mov word ptr[si+2],ax
       mov word ptr[si+4],ax
       mov word ptr[si+6],ax
       mov word ptr[si+8],ax
       ret
Resett ENDP
;-------------------------------------------------------------------------------------------
; 7.1.3. �������� ��⠭���� ��ᮢ � ����
Zero PROC
     mov ax,Real
     mov Base,ax
     mov Weight,0
ret
Zero ENDP
;-------------------------------------------------------------------------------------------
; 7.3. �������� ��ࠡ�⪨ ०��� "�ਥ�/���㧪� ⮢��"
ModeNMX PROC
        mov al,NMX
        cmp al,020h
        je skl
        cmp al,040h
        je skl
        mov al,020h
        mov NMX,al
   skl: cmp EmpKbd,0FFh ;��������� ����?
        jne mns         ;���室 �᫨ ���
        ret             ;��室 �� ��楤���
   mns: xor al,al
        mov ACP1,al      ;��� ���ᨢ��
        mov ACP2,al      ;��� ���ᨢ��
        mov al,Key
        cmp al,0Ah     ;����� "Seria+"
        jne mn0np
        call SeriesAdd
        jmp mnret       ;��室 �� ��楤���
 mn0np: mov al,Key
        cmp al,0Bh     ;����� "Seria-"
        jne mn0ns
        call SeriesSub
        jmp mnret       ;��室 �� ��楤���
 mn0ns: mov al,Key
        cmp al,0Ch          ;����� "Enter"?
        je mnm1       
        jmp mn1             ;���室 �᫨ ���
  mnm1: mov al,0FFh
        mov ACP2,al        ;��� ��⨢��
        mov ACP1,0
        call PersNomer      ;�஢�ઠ �� ��� ����稥 � ���ᨢ� 
        mov al,NotReg   
        cmp al,0FFh         ;��設� �� ��ॣ����஢���?
        jne mreg            ;���室 �᫨ ��ॣ����஢���
        jmp mnret                 ;��室 �� ��楤���
  mreg: mov al,010d
        mul NomCur      ;NomCur - ��室��� �ࠬ��� ��楤��� PersNomer (����� ����� � �����)
        mov bx,ax       ;� bx ��室���� ���� ��������� �����
        add bx,05d      ;� bx ��室���� ᬥ饭�� �� ������⢮ 室�� � ��������� �����
        lea di,RegMas
        mov Hlp2,bx      ;��࠭塞 ᬥ饭�� �� �᫮ 室�� � Hlp2
        inc bx
        mov dx,[di+bx]   ;�⥭�� ��� �� ���ᨢ�
        mov Hlp,dx       ;(Hlp=��� �� ���ᨢ�)
        mov cl,Typt 
        xor ch,ch     
   ntc: shr cl,1
        inc ch
        cmp cl,0
        jne ntc
        shl ch,1        
        mov Hlp1,ch     ;� Hlp1 ��室���� ����� ⨯� ⮢��*2
        mov al,NMX
        cmp al,020h      ;����祭 ०�� "�� ᪫��"?
        jne mnn1
        mov dx,Weight    ;⥪�騩 ���
        mov ax,Hlp       ;��� �� ���ᨢ�
        sub dx,ax        ;�� ⥪�饣� ��� ���⠥� ��� � ���ᨢ� 
        jns plus1        ;���室 �᫨ १���� ������⥫��
        mov WghErr,0FFh  ;����� 䫠�� �訡�� ��� � ��室 �� ��楤���
        jmp carry       
 plus1: mov ImpErr,0h    ;���㫥��� 䫠�� �訡�� ���
        ;mov Weight,dx    
        xor bh,bh
        mov bl,Hlp1       ;bl=����� ⨯� ⮢��*2 
        mov ax,[Insk+bx]  ;�⥭�� ��� ⮢�� �� ⨯� �� ᪫��� 
        add ax,dx         ;�ਡ���塞 � ���� ��� ��㧠
        jnc nocarry       ;���室 �᫨ ��� �� �ॢ�蠥� ���ᨬ��쭮��
        mov InsErr,0FFh   ;����� 䫠�� �訡�� ��� � ��室 �� ��楤���
        jmp carry
nocarry:mov InsErr,0h     ;���㫥��� 䫠�� �訡�� ���
        mov [Insk+bx],ax  ;������ �㬬� �� ᪫���
        mov ax,[Imp+bx]   ;�⥭�� ��� ���������� ⮢�� �� ⨯�  
        add ax,dx         ;�ਡ���塞 � ���� ��� ��㧠
        jnc ncr2
        mov ImpErr,0FFh   ;����� 䫠�� �訡�� ��� � ��室 �� ��楤���
        jmp carry
  ncr2: mov [Imp+bx],ax   ;������ �㬬� ���������� ⮢��  
        mov bx,Hlp2
        inc [RegMas+bx]   ;���६��� �᫠ 室�� (�᫨ ���뫮 �訡��) 
 carry: jmp mnret        ;��室 �� ��楤��� � ��室 �� ��楤���
  mnn1: mov al,NMX
        cmp al,040h      ;����祭 ०�� "�� ᪫���"?
        jne mnn2
        mov ax,Weight    ;⥪�騩 ���
        mov dx,Hlp       ;��� �� ���ᨢ�
        sub ax,dx        ;���⠥� �� ⥪�饣� ��� ��� � ���ᨢ�
        cmp ax,0
        ja plus2          ;���室 �᫨ १���� ������⥫��
        mov InsErr,0FFh   ;����� 䫠�� �訡�� ��� � ��室 �� ��楤���
        jmp mnret       
plus2:  mov WghErr,0h    ;���㫥��� 䫠�� �訡�� ���
        ;mov Weight,ax
        mov dx,ax         ; � dx ��� ��㧠
        xor bh,bh
        mov bl,Hlp1       ;����㦠�� ����� ⨯� ⮢��
        mov ax,[Insk+bx]  ;�⥭�� ��� ⮢�� �� ⨯� �� ᪫��� 
        sub ax,dx         ;���⠥� �� ���� ��� �� ���ᨢ�
        ;cmp ax,0
        jns nonegat       ;���室 �᫨ ��� �� ����⥫��
        mov ExpErr,0FFh   ;����� 䫠�� �騡�� ��� � ��室 �� ��楤���
        jmp mnret
nonegat:mov InsErr,0h    ;���㫥��� 䫠�� �訡�� ���
        mov [Insk+bx],ax  ;������ �㬬� �� ᪫���
        mov ax,[Exp+bx]   ;�⥭�� ��� ���������� ⮢�� �� ⨯�  
        add ax,dx         ;�ਡ���塞 � ���� ��� �� ���ᨢ�
        jnc ncr3
        mov ExpErr,0FFh   ;����� 䫠�� �訡�� ��� � ��室 �� ��楤���
        jmp carry
 ncr3:  mov [Exp+bx],ax   ;������ �㬬� ���������� ⮢��      
        mov bx,Hlp2
        inc [RegMas+bx]   ;���६��� �᫠ 室�� (�᫨ ���뫮 �訡��) 
  mnn2:                   ;����祭 ०�� "�� ᪫���"?
        jmp mnret         ;��室 �� ��楤���
        ;����⨥ ��⠫��� ������ �ਢ���� � ��室� �� ��楤���(�஬� Enter � ���)
   mn1: mov al,Key
        cmp al,0Dh      ;����� "Delete"?  
        jne mn2         ;���室 �᫨ ���
        mov al,0FFh
        mov ACP1,al        ;��� ��⨢��
        mov ACP2,al        ;��� ��⨢��
        jmp mnret       ;��室 �� ��楤���
   mn2: cmp al,0Eh      ;����� "Reset"? 
        jne mn3         ;���室 �᫨ ���
        mov al,0FFh
        mov ACP1,al        ;��� ��⨢��
        mov ACP2,al        ;��� ��⨢��
        jmp mnret       ;��室 �� ��楤���
   mn3: cmp al,0Fh      ;����� "View"
        jne mn4         ;���室 �᫨ ���
        mov al,0FFh
        mov ACP1,al        ;��� ��⨢��
        mov ACP2,al        ;��� ��⨢��
        jmp mnret       ;��室 �� ��楤���
   mn4: cmp al,010h      ;����� "Zero"
        jne mn5          ;���室 �᫨ ���
        mov al,0FFh
        mov ACP1,al        ;��� ��⨢��
        mov ACP2,al        ;��� ��⨢��
        jmp mnret       ;��室 �� ��楤���
  mn5:  cmp al,011h    ;R1
        jne mn6
        mov al,020h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al      ;��� ��⨢��
        mov ACP2,al      ;��� ��⨢��
        jmp mnret
   mn6: cmp al,012h    ;R2
        jne mn7
        mov al,040h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al      ;��� ��⨢��
        mov ACP2,al      ;��� ��⨢��
        jmp mnret
   mn7: cmp al,013h    ;R3
        jne mnfin
        mov al,080h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al      ;��� ��⨢��
        mov ACP2,al      ;��� ��⨢��
        jmp mnret
        ;�᫨ ��祣� �� �����, � �����뢠�� ��।��� ���� � �����:
mnfin:  xor bh,bh
        mov bl,CntNom
        mov [Nomer+bx],al
        inc bl
        cmp bl,04h     ;���稪 ���=4?
        jne mnc        ;���室 �᫨ ���
        xor bl,bl      ;���㫥��� ���稪� ��� 
  mnc:  mov CntNom,bl
mnret:  ret
ModeNMX ENDP
;-------------------------------------------------------------------------------------------
; 7.4. �������� ��ࠡ�⪨ ०��� "��ᬮ�� ���ﭨ� ᪫��� � ��ࠡ�⪨ ����⥫��"
ModeView PROC
        cmp EmpKbd,0FFh ;��������� ����?
        jne mer         ;���室 �᫨ ���
        jmp mwr         ;��室 �� ��楤���
   mer: xor al,al
        mov ACP1,al      ;��� ���ᨢ��
        mov ACP2,al      ;��� ���ᨢ��
        mov al,Key
        cmp al,0Ah     ;����� "Seria+"
        jne me0np
        call SeriesAdd
        jmp mwr        ;��室 �� ��楤���
 me0np: mov al,Key
        cmp al,0Bh     ;����� "Seria-"
        jne me0ns
        call SeriesSub
        jmp mwr        ;��室 �� ��楤���
 me0ns:  mov al,Key
         cmp al,0Ch      ;����� "Enter"
         jne mve2        ;���室 �᫨ ���
         call PersNomer
         cmp NotReg,0FFh ;�� ��設� �������?
         jne reg1        ;���室 �᫨ ��
         jmp mwr
   reg1: xor ah,ah
         mov al,010d
         mul NomCur      ;NomCur - ��室��� �ࠬ��� ��楤��� PersNomer (����� ����� � �����)
         mov bx,ax       ;� bx ��室���� ���� ��������� �����
         add bx,05d      ;� bx ��室���� ᬥ饭�� �� ������⢮ 室�� � ��������� �����
         lea di,RegMas
         mov al,[di+bx]  ;�⠥� �᫮ 室��
         xor ah,ah
         mov Weight,ax
        mov al,0FFh
        mov ACP2,al      ;���� ��� ��⨢��
        xor al,al
        mov ACP1,al      ;��� ���ᨢ��
         call WghTrf
         call DispWgh
         jmp mwr          ;��室 �� ��楤���         
   mve2: mov al,Key
         cmp al,0Fh        ;����� "View"?
         je  mve31  
         jmp mve3          ;���室 �᫨ ���
 mve31: mov al,0FFh
        mov ACP2,al      ;���� ��� ��⨢��
        xor al,al
        mov ACP1,al      ;��� ���ᨢ��
        xor ch,ch          ;����塞 ����� ⨯� ⮢��
        mov cl,Typt      
   mvc: shr cl,1
        inc ch
        cmp cl,0
        jne mvc
        shl ch,1        
        mov Hlp1,ch     ;� Hlp1 ��室���� ����� ⨯� ⮢��*2
         mov dl,NMX
         cmp dl,020h       ;NMX=�� ᪫��?
         jne mv1           ;���室 �᫨ ���
         xor bh,bh
         mov bl,Hlp1       ;⨯ ⮢��
         mov ax,[Imp+bx]   ;��� ���������� ⮢�� �� ⨯�
         mov Weight,ax
         call WghTrf
         call DispWgh
         jmp mwr
    mv1: mov dl,NMX
         cmp dl,040h        ;NMX=� ᪫���?
         jne mv2
         xor bh,bh
         mov bl,Hlp1       ;⨯ ⮢��
         mov ax,[Exp+bx]   ;��� �뢥������� ⮢�� �� ⨯�
         mov Weight,ax
         call WghTrf
         call DispWgh
         jmp mwr
    mv2: mov dl,NMX
         cmp dl,080h        ;NMX=�� ᪫���
         jne mve3
         xor bh,bh
         mov bl,Hlp1       ;⨯ ⮢��
         mov ax,[Insk+bx]  ;��� ⮢�� �� ᪫��� �� ⨯�
         mov Weight,ax
         call WghTrf
         call DispWgh
         jmp mwr

  mve3: mov al,Key
        cmp al,0Dh
        je mwr
        cmp al,0Eh
        je mwr
        cmp al,010h
        je mwr
        cmp al,011h    ;R1
        jne mv6
        mov al,020h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al      ;��� ��⨢��
        mov ACP2,al      ;��� ��⨢��
        jmp mwr
   mv6: cmp al,012h    ;R2
        jne mv7
        mov al,040h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al      ;��� ��⨢��
        mov ACP2,al      ;��� ��⨢��
        jmp mwr
   mv7: cmp al,013h    ;R3
        jne mvfin
        mov al,080h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al      ;��� ��⨢��
        mov ACP2,al      ;��� ��⨢��
        jmp mwr
 mvfin: xor bh,bh       ;�᫨ ��祣� �� �����
        mov bl,CntNom
        mov [Nomer+bx],al
        inc bl
        cmp bl,04h     ;���稪 ���=4?
        jne mnw        ;���室 �᫨ ���
        xor bl,bl      ;���㫥��� ���稪� ��� 
  mnw:  mov CntNom,bl
        mov al,NMX
  mwr:  ret
ModeView ENDP
;-------------------------------------------------------------------------------------------
; 10. �������� �뢮�� ����� � ०���� �� �࠭
OutputNomer PROC
            ;��⠭���� ��⨢���� ���� ���
            cmp ACP2,0FFh
            je opn1
            lea si,Digit
            lea di,Nomer
            xor bh,bh
            mov bl,[Nomer+0]
            mov ax,cs:[si+bx]
            out Ind4,ax
            mov bl,[Nomer+1]
            mov ax,cs:[si+bx]
            out Ind3,ax
            mov bl,[Nomer+2]
            mov ax,cs:[si+bx]
            out Ind2,ax
            mov bl,[Nomer+3]
            mov ax,cs:[si+bx]
            out Ind1,ax
            lea si,Letter
            mov bl,[Nomer+4]
            mov ax,cs:[si+bx]
            out Ind5,ax
            
            lea si,Digit
            mov bl,RegCur
            mov al,cs:[si+bx]
            out 012h,al
            mov bl,NomCur
            mov al,cs:[si+bx]
            out 014h,al
   opn1:    
            lea si,Digit
            mov bl,RegCur
            mov al,cs:[si+bx]
            out 012h,al
            mov bl,NomCur
            mov al,cs:[si+bx]
            out 014h,al
            mov al,Typt
            mov ah,NMX
            or  al,ah
            out DigIndT,al

            ret
OutputNomer ENDP
;-------------------------------------------------------------------------------------------

START:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;����� ࠧ��頥��� ��� �ணࠬ��
             call FuncPrep
    Start1:  call ErMesOut
             call KbdInput
             call KbdContr
             call KeyTrf
             call ModInp
             call ACPInp
             call WghTrf
             call DispWgh
             call FormInf
             call OutputNomer
            
             jmp Start1

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
