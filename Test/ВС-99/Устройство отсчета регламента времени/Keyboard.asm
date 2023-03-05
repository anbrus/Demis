
RomSize      EQU   4096
NMax         EQU   50          ;����⠭� ���������� �ॡ����
                               ;���� ���⮢ ���⥪���� �����\�뢮��
KbdPort      EQU   0           ;���� ����������, ����䮭�, ᢥ⮢��� � ��㪮���� ᨣ�����          
DispPort0    EQU   1           ;����� �������஢ 
DispPort1    EQU   2           ;���� �।ᥤ�⥫�
Port0        EQU   3           ;����� �������஢ 
Port1        EQU   4           ;���� ������稪�
                               ;���� �㭪樮������ ������
Ots          EQU   10          ;����� ��� �⪫�祭�� ����䮭�
OtO          EQU   11          ;����� � �⪫�祭��� ����䮭�
Vos          EQU   12          ;����⠭������� ���������� �६���
Otk          EQU   13          ;�⪫�祭�� ����䮭�
Ost          EQU   14          ;��㧠
Nac          EQU   15          ;��⠭���� ��砫��� ��ࠬ��஢

Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

Data       SEGMENT AT 0
KbdImage     DB    4 DUP(?)     ;���� ���ᨢ� ��ࠧ�� ᨬ�����
EmpKbd       DB     ?           ;���� ���⮩ ����������
KbdErr       DB     ?           ;���� �訡��
KodKey       DB     ?           ;��� ����⮩ ������
Key          DB     ?           ;���� ࠧ�襭�� ����� ���祭�� �६��� � �����
Image        DB     ?           ;��ࠧ ����襩 ���� ���祭�� �६���
Ind0         DB     ?           ;������� ��� ����������
Ind1         DB     ?           ;��� ����� �६���
Number       DB     ?           ;��᫥���� ���祭�� ���������� ��� ����� �६���
Num0         DB     ?           ;������ ��� ��⠢襣��� �६���
Num1         DB     ?           ;����� ��� ��⠢襣��� �६���
Expect       DW     ?           ;����஫� ����প�
Kl           DB     ?           ;����襭�� ᮢ���⭮� ࠡ��� ������ �� � ���
Nuh          DB     ?
Data       ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Code,ss:Stk

           ;���ᨢ ��ࠧ�� 16-����� ᨬ�����: "0", "1", ... "9"
SymImages  DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh

;��楤�� ����㧪� ��砫��� ��ࠬ��஢ 
Begin  PROC  NEAR
       cmp   KodKey, Nac         ;��砫쭠� ����㧪�?
       jnz   Bgn                 ;���室, �᫨ ���?
       mov   al,0
       out   DispPort0,al        ;��襭��
       out   DispPort1,al        ;�������஢
       out   Port0,al            ;���⮢ �।ᥤ�⥫�
       out   Port1,al            ;� ������稪�,
       out   KbdPort,al          ;����������, ᨣ����� � ����䮭�
       mov   Image,al            ;���ᯥ祭�� ��ᨬ���쭮�� �뢮�� �� ���� �।ᥤ�⥫�
       mov   Key,al              ;����襭�� �������� ���祭�� �६���
       mov   Expect,03FFh        ;������� ����প�
       mov   Kl,2                ;���⨥ 䫠��� �� � ���           
Bgn:   ret
Begin  ENDP

;��楤�� ��襭�� �ॡ����
VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
           mov   bh,0        ;���� ����稪� ����७��
VD2:       in    al,dx       ;���� ⥪�饣� ���ﭨ�
           cmp   ah,al       ;����饥 ���ﭨ�=��室����?
           jne   VD1         ;���室, �᫨ ���
           inc   bh          ;���६��� ����稪� ����७��
           cmp   bh,NMax     ;����� �ॡ����?
           jne   VD2         ;���室, �᫨ ���
           mov   al,ah       ;����⠭������� ���⮯�������� ������
           ret
VibrDestr  ENDP

;��楤�� ����஫� �� ����祭��� ����䮭�, ᢥ⮢��� � ��㪮���� ᨣ����� 
Kbd  PROC  NEAR
     cmp   Key,1
     jbe   K
     ;cmp   Nuh,0
     ;jnz   K
     cmp   KodKey,Ost          ;��㧠?
     jnz   K1                  ;���室, �᫨ ���
     cmp   Kl,1                ;����䮭 �⪫�祭?
     jz    K5                  ;���室, �᫨ ��
     mov   Kl,0                ;��⠭����� 䫠� ��⠭����
     jmp   K4                  ;���室
K1:  cmp   KodKey,Ots          ;����� �६��� ��� �⪫�祭�� ����䮭�?
     jz    K3                  ;���室, �᫨ ��
     cmp   KodKey,Otk          ;�⪫���� ����䮭?  
     jnz   K2                  ;���室, �᫨ ��
     cmp   Kl,0                ;��㧠?  
     jz    K5                  ;���室, �᫨ ��
     mov   Kl,1                ;����䮭 �⪫�祭
     jmp   K5                  
K2:  cmp   KodKey,OtO          ;����� �६��� � �⪫�祭��� ����䮭�?
     jnz   K                   ;��室 �� ��楤���, �᫨ ���
     cmp   Key,4               ;�६� ��⥪��?
     jz    K                   ;���室, �᫨ ��
K3:  mov   Kl,2                ;���⨥ 䫠��� �⪫�祭���� ����䮭� � ����
K4:  or    al,010h             ;����祭��
K5:  cmp   Num1,0              ;��⠫��� 
     jne   K                   ;1 ����� �� ���祭��
     cmp   Num0,1              ;�⢥������� �६���?
     jne   K6                  ;���室, �᫨ ���
     or    al,020h             ;������� ᢥ⮢�� ᨣ���
     jmp   K
K6:  cmp   Num0,0              ;�६� ��⥪��?
     jnz   K                   ;���室, �᫨ ���
     cmp   Expect,1             ;��᫥���� ����� �����稫���?
     jz    K7                  ;���室, �᫨ ��
     or    al,040h             ;������� ��㪮��� ᨣ���  
     jmp   K
K7:  mov   Key,4               ;�६� ��⥪��
K:   ret      
Kbd  ENDP

;��楤�� ����� � ����������
KbdInput   PROC  NEAR
           lea   si,KbdImage         ;����㧪� ����,
           mov   cx,LENGTH KbdImage  ;����稪� 横���
           mov   bl,0FEh             ;� ����� ��室��� ��ப�
KI4:       mov   al,bl               ;�롮� ��ப�
           and   al,0Fh
           call  Kbd                 ;�맮� ��楤��� Kbd
           out   KbdPort,al          ;��⨢��� ��ப�
           in    al,KbdPort          ;���� ��ப�
           and   al,0Fh              ;����祭�?
           cmp   al,0Fh
           jz    KI1                 ;���室, �᫨ ���
           mov   dx,KbdPort          ;��।�� ��ࠬ���
           call  VibrDestr           ;��襭�� �ॡ����
KI1:       mov   [si],al             ;������ ��ப�
KI2:       in    al,KbdPort          ;���� ��ப�
           and   al,0Fh              ;�몫�祭�?
           cmp   al,0Fh
           jnz   KI2                 ;���室, �᫨ ���
           call  VibrDestr           ;��襭�� �ॡ����
           inc   si                  ;����䨪��� ����
           rol   bl,1                ;� ����� ��ப�
           loop  KI4                 ;�� ��ப�? ���室, �᫨ ���
           ret
KbdInput   ENDP

;��楤�� ����஫� ����� � ����������
KbdInContr PROC  NEAR
           lea   bx,KbdImage         ;����㧪� ����
           mov   cx,4                ;� ����稪� ��ப
           mov   EmpKbd,0            ;���⪠ 䫠��� ���⮩ ����������
           mov   KbdErr,0            ;� �訡��
           mov   dl,0                ;� ������⥫�
KIC2:      mov   al,[bx]             ;�⥭�� ��ப�
           mov   ah,4                ;����㧪� ����稪� ��⮢
KIC1:      shr   al,1                ;�뤥����� ���
           cmc                       ;������� ���
           adc   dl,0
           dec   ah                  ;�� ���� � ��ப�?
           jnz   KIC1                ;���室, �᫨ ���
           inc   bx                  ;����䨪��� ���� ��ப�
           loop  KIC2                ;�� ��ப�? ���室, �᫨ ���
           cmp   dl,0                ;������⥫�=0?
           jz    KIC3                ;���室, �᫨ ��
           cmp   dl,1                ;������⥫�=1?
           jz    KIC4                ;���室, �᫨ ��
           mov   KbdErr,0FFh         ;��⠭���� 䫠�� �訡��
           jmp   SHORT KIC4
KIC3:      mov   EmpKbd,0FFh         ;��⠭���� 䫠�� ���⮩ ����������
KIC4:      ret
KbdInContr ENDP

;��楤�� �ନ஢���� ���� ����⮩ ������
KodKeyTrf  PROC  NEAR
           cmp   EmpKbd,0FFh         ;����� ���������?
           jz    KKT1                ;���室, �᫨ ��
           cmp   KbdErr,0FFh         ;�訡�� ����������?
           jz    KKT1                ;���室, �᫨ ��
           lea   bx,KbdImage         ;����㧪� ����
           mov   dx,0                ;���⪠ ������⥫�� ���� ��ப� � �⮫��
KKT3:      mov   al,[bx]             ;�⥭�� ��ப�
           and   al,0Fh              ;�뤥����� ���� ����������
           cmp   al,0Fh              ;��ப� ��⨢��?
           jnz   KKT2                ;���室, �᫨ ��
           inc   dh                  ;���६��� ���� ��ப�
           inc   bx                  ;����䨪��� ����
           jmp   SHORT KKT3
KKT2:      shr   al,1                ;�뤥����� ��� ��ப�
           jnc   KKT4                ;��� ��⨢��? ���室, �᫨ ��
           inc   dl                  ;���६��� ���� �⮫��
           jmp   SHORT KKT2
KKT4:      mov   cl,2                ;��ନ஢���  
           shl   dh,cl               ;����筮��  
           or    dh,dl               ;���� ����
           mov   KodKey,dh           ;������ ���� ����
KKT1:      ret
KodKeyTrf  ENDP

FormIm  PROC  NEAR
        xor   ah,ah
        lea   bx,SymImages        ;���᫥��� �ᯮ���⥫쭮�� ����
        add   bx,ax               ;���ᨢ� ��ࠧ�� ��� 
        mov   al,es:[bx]          ;���뢠��� ��ࠧ� ��������� ���� �� ���ᨢ�
        ret   
FormIm  ENDP

;��楤�� �뢮�� ���祭�� �६��� �� ���� �।ᥤ�⥫�
OutPut  PROC  NEAR  
        cmp   KodKey,09h          ;����� �㭪樮���쭠� ������?
        ja    OP1                 ;���室, �᫨ �� 
        cmp   KbdErr,0FFh         ;�訡�� ����� � ����������?
        jz    OP1                 ;���室, �᫨ ��
        cmp   EmpKbd,0FFh         ;����� ���������?
        jz    OP1                 ;���室, �᫨ ��
        cmp   Key,2               ;������� 2 ����?
        jae   OP1                 ;���室, �᫨ ��
        mov   al,Image            ;���࠭���� ��ࠧ� 
        out   DispPort0,al        ;�뢮� ��।��� ����⮩ ����
        mov   al,KodKey           ;��� ����⮩ ������
        cmp   Key,0               ;������ ������� ����? 
        jne   OP2                 ;���室, �᫨ ���
        mov   Ind1,al             ;��࠭塞 ������ ���襩 ����
        jmp   SHORT OP3
OP2:    mov   Ind0,al             ;��࠭塞 ������ ����襩 ����
OP3:    call  FormIm
        mov   Image,al            ;��࠭���� ��ࠧ� ����襩 ��������� ����
        out   DispPort1,al        ;�뢮� ���襩 ����
        inc   Key
OP1:    ret  
OutPut  ENDP

;��楤�� ��࠭�祭�� ��������� ��������� ���祭�� �६���
RangNum  PROC  NEAR
         cmp   Key,02h            ;���祭�� �६��� �������?         
         jne   RN                 ;���室, �᫨ ���
         cmp   Ind1,06h           ;�������� �६� ����� 1 ��?
         jne   RN1                ;���室, �᫨ ���
         cmp   Ind0,0             ;�������� �६� �� �ॢ�蠥� 1 ��?
         je    RN2                ;���室, �᫨ ��
         jmp   short RN3
RN1:     cmp   Ind1,06h           ;�������� �६� �� �ॢ�蠥� 1 ��?
         jb    RN2                ;���室,�᫨ ���
RN3:     mov   al,073h            ;�뢮� ᮮ�饭��
         out   DispPort0,al       ;�� �訡��
         out   DispPort1,al       ;���������� ���祭�� �६���
RN2:     mov   Nuh,0
RN:      ret
RangNum  ENDP

;��楤�� �ନ஢���� �᫮���� ���祭�� ���������� �६���
FormNum  PROC  NEAR
         mov   al,Ind0             ;��ନ஢����   
         mov   ah,Ind1             ;�᫮���� 
         and   al,01111b           ;���祭�� 
         mov   cl,4                ;����������
         shl   ah,cl               ;�६���
         or    al,ah  
         mov   Number,al           ;���࠭���� �᫮���� ���祭��
         ret
FormNum  ENDP

;��楤�� �ନ஢���� ��ࠧ�� ��� ��⠢襣��� �᫮���� ���祭�� �६���
FormInd  PROC  NEAR
         mov   al,Number          ;���࠭���� �᫮���� ���祭��
         and   ax,01111b          ;��ନ஢���� �����ᮢ
         mov   Num0,al            ;���࠭���� ������ ����襩 ����
         mov   al, Number
         mov   cl,4                
         shr   al,cl              ;��� ��⠢襣��� ���祭�� �६���
         mov   Num1,al            ;���࠭���� ������ ���襩 ����
         ret
FormInd  ENDP

NumOut  PROC  NEAR
        mov   al,Num0
        call  FormIm
        out   DispPort1,al        ;��⠢襣��� ���祭�� �६��� 
        out   Port0,al            ;�� ��� ����         
        mov   al,Num1
        call  FormIm
        out   DispPort0,al        ;��⠢襣��� ���祭�� �६��� 
        out   Port1,al            ;�� ��� ����
        ret
NumOut  ENDP

;��楤�� ����� 
Decrement  PROC  NEAR
           cmp   Expect,1            ;����� ���祭�� ����প�?
           jnz   Dct                ;���室, �᫨ ���
           mov   al,Number          ;�����襭��
           sub   al,01h             ;���������� ���祭�� �६���
           das                      ;�� �������
           mov   Number,al          ;���࠭���� �᫮���� ���祭�� ��⠢襣��� �६���
Dct:       ret 
Decrement  ENDP

;��楤�� ����প�
Delay  PROC  NEAR
       cmp   Expect,0              ;�६� �⮡ࠦ���� ��।���� ���祭�� ��⠢襣��� �६��� ��⥪��?   
       jnz   Dly                    ;���室, �᫨ ��� 
       mov   Expect,03FFh          ;��⠭���� ����প� ��� ᫥���饣� �⮡ࠦ����
Dly:   dec   Expect                ;�����襭�� ���祭�� ����প�
       ret
Delay  ENDP

;��楤�� ���ᯥ祭�� ࠡ��� �㭪樮������ ������ �� �����
Count  PROC  NEAR
       cmp   Nuh,0
       jnz   Cnt
       cmp   Key,1
       ja    Cnt6
       cmp   KodKey,Vos
       ja    Cnt 
Cnt6:  cmp   KodKey,Vos         ;����⠭����� ��������� �६�?          
       jz    Cnt3               ;���室, �᫨ �� 
       cmp   Key,4              ;�६� ��⥪��? 
       jz    Cnt                ;���室 �᫨ ��
       cmp   KodKey,Ots         ;������ ���,
       jz    Cnt2               ;��,
       cmp   KodKey,OtO         ;���  
       jz    Cnt2               ;��
       cmp   KodKey,Otk         ;������?
       jnz   Cnt1               ;���室, �᫨ ���
       cmp   Kl,0               ;�।���⥫쭮 �뫠 ����� ������ ���?
       jz    Cnt5               ;���室, �᫨ ��
       jmp   Cnt2
Cnt1:  cmp   KodKey,Ost         ;��㧠?
       jnz   Cnt                ;���室, �᫨ ��
       jmp   CNT5
Cnt2:  cmp   Key,3              ;��稭��� �����?
       jz    Cnt4               ;���室, �᫨ ��
Cnt3:  call  FormNum            ;��।��� ��ࠬ���� ��� ����� 
       mov   Key,3              ;��ࠬ���� ��� ����� ��।���
Cnt4:  call  Delay              ;�맮� ��楤��� ��������,
       call  FormInd
Cnt5:  call  NumOut             ;��楤��� �뢮�� ��⠢襣��� �᫮���� ���祭�� �६���
       call  Decrement          ;��楤��� 㬥��襭�� ��⠢襣��� �६��� �� �������
Cnt:   ret
Count  ENDP

Start:

   mov   ax,Code
   mov   es,ax
   mov   ax,Data
   mov   ds,ax
   mov   ax,Stk
   mov   ss,ax
   lea   sp,StkTop
    
   mov   KodKey,Nac
   mov   Nuh,0FFh
   
InfLoop:
                           ;�맮�� ��楤��
    call  Begin            ;��楤�� ����㧪� ��砫��� ��ࠬ��஢ 
    call  KbdInput         ;��楤�� ����� � ����������
    call  KbdInContr       ;��楤�� ����஫� ����� � ����������  
    call  KodKeyTrf        ;��楤�� �ନ஢���� ���� ����⮩ ������
    call  OutPut           ;��楤�� �뢮�� ���祭�� �६��� �� ���� �।ᥤ�⥫�
    call  RangNum          ;��楤�� ��࠭�祭�� ��������� ��������� ���祭�� �६���   
    call  Count            ;��楤�� �࣠����樨 ����� � �ᯮ�짮������ �㭪樮������ ������
    jmp   InfLoop                             
   
;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END

