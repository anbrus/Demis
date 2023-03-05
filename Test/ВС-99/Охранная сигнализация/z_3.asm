RomSize    EQU   4096
NMax       EQU   50
KbdPort    EQU   0
DispPort   EQU   1
DispPort2  EQU   2
Stk        SEGMENT AT 100h
           DW    10 DUP    (?)
StkTop     LABEL WORD
Stk        ENDS
Date       STRUC
           Poj   db         ?
           Pro   db         ?
           Sig   db         ? 
Date       ENDS
Data       SEGMENT AT 0
           KbdImage   DW    2 DUP(?)
           EmpKbd     DB    ?
           KbdErr     DB    ?
           DigCode    DB    ?
           Home       DB    ?       
           Flag       DB    ?
           Rez        DB    ?
           tyr        DB    ?    
           buf        DB    ?  
;********************************************************************
           MS         Date  16 dup(<>)        
           svet1      dw    ?        
           svet2      dw    ?                           
;********************************************************************           
Data       ENDS
Code       SEGMENT
           ASSUME cs:Code,ds:Data,ss:Stk
SymImages  db    3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7fh,05fh
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
KbdInput   PROC  NEAR
           lea   si,KbdImage         ;����㧪� ����,
           mov   cx,LENGTH KbdImage  ;����稪� 横���
           mov   bl,0eh             ;� ����� ��室��� ��ப�
           or    buf,bl
KI4:       mov   al,buf       ;�롮� ��ப�
           out   KbdPort,al  ;��⨢��� ��ப�
           in    al,KbdPort  ;���� ��ப�
           and   al,0ffh      ;����祭�?
           cmp   al,0ffh
           jz    KI1         ;���室, �᫨ ���
           mov   dx,KbdPort  ;��।�� ��ࠬ���
           call  VibrDestr   ;��襭�� �ॡ����
           mov   [si],al     ;������ ��ப�
KI2:       in    al,KbdPort  ;���� ��ப�
           and   al,0ffh      ;�몫�祭�?
           cmp   al,0ffh
           jnz   KI2         ;���室, �᫨ ���
           call  VibrDestr   ;��襭�� �ॡ����
           jmp   SHORT KI3
KI1:       mov   [si],al     ;������ ��ப�
KI3:       inc   si          ;����䨪��� ����
           sub   buf,2        ;� ����� ��ப�
           loop  KI4         ;�� ��ப�? ���室, �᫨ ���
           ret
KbdInput   ENDP
KbdInContr PROC  NEAR
           lea   bx,KbdImage ;����㧪� ����
           mov   cx,2        ;� ����稪� ��ப
           mov   EmpKbd,0    ;���⪠ 䫠���
           mov   KbdErr,0
           mov   dl,0        ;� ������⥫�
KIC2:      mov   al,[bx]     ;�⥭�� ��ப�
           mov   ah,8        ;����㧪� ����稪� ��⮢
KIC1:      shr   al,1        ;�뤥����� ���
           cmc               ;������� ���
           adc   dl,0
           dec   ah          ;�� ���� � ��ப�?
           jnz   KIC1        ;���室, �᫨ ���
           inc   bx          ;����䨪��� ���� ��ப�
           loop  KIC2        ;�� ��ப�? ���室, �᫨ ���
           cmp   dl,0        ;������⥫�=0?
           jz    KIC3        ;���室, �᫨ ��
           cmp   dl,1        ;������⥫�=1?
           jz    KIC4        ;���室, �᫨ ��
           mov   KbdErr,0FFh ;��⠭���� 䫠�� �訡��
           jmp   SHORT KIC4
KIC3:      mov   EmpKbd,0FFh ;��⠭���� 䫠�� ���⮩ ����������
KIC4:      ret
KbdInContr ENDP
NxtDigTrf  PROC  NEAR
           cmp   EmpKbd,0FFh ;����� ���������?
           jz    NDT1        ;���室, �᫨ ��
           cmp   KbdErr,0FFh ;�訡�� ����������?
           jz    NDT1        ;���室, �᫨ ��
           lea   bx,KbdImage ;����㧪� ����
           mov   dx,0        ;���⪠ ������⥫�� ���� ��ப� � �⮫��
NDT3:      mov   al,[bx]     ;�⥭�� ��ப�
           and   al,0ffh      ;�뤥����� ���� ����������
           cmp   al,0ffh      ;��ப� ��⨢��?
           jnz   NDT2        ;���室, �᫨ ��
           inc   dh          ;���६��� ���� ��ப�
           inc   bx          ;����䨪��� ����
           jmp   SHORT NDT3
NDT2:      shr   al,1        ;�뤥����� ��� ��ப�
           jnc   NDT4        ;��� ��⨢��? ���室, �᫨ ��
           inc   dl          ;���६��� ���� �⮫��
           jmp   SHORT NDT2
NDT4:      mov   cl,3        ;��ନ஢��� ����筮�� ���� ����
           shl   dh,cl
           or    dh,dl
           mov   DigCode,dh  ;������ ���� ����
NDT1:      ret
NxtDigTrf  ENDP
NumOut     PROC  NEAR
           cmp   DigCode,7h
           ja    Nord
           mov   Rez,11   
           jmp   West
     Nord: mov   Rez,19 
     West: xor   ah,ah
           mov   al,DigCode
           add   al,Rez
           daa
           mov   Rez,al
           xor   ah,ah
           and   al,0Fh           
           mov   si,ax 
           mov   al,SymImages[si]
           out   DispPort2,al
           mov   al,Rez          
           shr   al,4
           mov   si,ax 
           mov   al,SymImages[si]
           out   DispPort,al                      
           ret
NumOut     ENDP
Datchik    PROC  NEAR
           in    al,dx
           mov   ah,al
           dec   dx
           in    al,dx
           not   ax
           cmp   ax,0
           je    m111
           mov   cl,-1
     m211: shr   ax,1
           inc   cl
           cmp   ax,0
           jne   m211
           mov   al,3
           mul   cl
           mov   si,ax
           mov   al,0ffh
           cmp   Home,1
           jne   frg
           cmp   MS[si].Sig,0ffh
           jne   m111
           mov   MS[si].Pro,al 
           jmp   gdr
     frg:  mov   MS[si].Poj,al
     gdr:  call  Vyvodpolesvet
     m111: ret     
Datchik    ENDP
Pojar      PROC  NEAR
           mov   Home,0                      
           mov   dx,2h
           call  Datchik
           ret
Pojar      ENDP
Pronic     PROC  NEAR
           mov   Home,1                      
           mov   dx,4h
           call  Datchik
           ret
Pronic     ENDP
Knopkasig  PROC  NEAR
           in    al,5h
           cmp   al,ah
           jne   m12
           mov   al,3
           mov   cl,DigCode
           mul   cl
           mov   si,ax
           cmp   MS[si].Poj,0ffh                     
           je    m12
           cmp   MS[si].Pro,0ffh
           je    m12   
           mov   al,ch                  
           mov   MS[si].Sig,al
           call  Vyvodpolesvet                    
      m12: ret 
Knopkasig  ENDP
Ustanovka  PROC  NEAR
           mov   ah,0feh
           mov   ch,0ffh
           call  Knopkasig
           ret
Ustanovka  ENDP
Snjatie    PROC  NEAR
           mov   ah,0fdh
           mov   ch,0h
           call  Knopkasig
           ret
Snjatie    ENDP
Avarsit    PROC  NEAR
           mov   si,0
           in    al,5h
           cmp   al,0fbh
           jne   m33
           mov   cx,LENGTH MS
   next3:  cmp   MS[si].Poj,0ffh
           je    m13
           cmp   MS[si].Pro,0ffh
           jne   m23
     m13:  mov   al,0
           mov   MS[si].Poj,al
           mov   MS[si].Pro,al
           mov   MS[si].Sig,al
     m23:  add   si,TYPE MS
           loop  next3
     m33:  call  Vyvodpolesvet
           ret   
Avarsit    ENDP
Vyvodpolesvet  PROC  NEAR
           mov   si,0                      
           mov   ax,8000h
           mov   cx,LENGTH MS
    next4: rol   ax,1    
           cmp   MS[si].Poj,0
           jne   m14
           cmp   MS[si].Pro,0
           je    m24
      m14: or    svet1,ax
           not   ax
           and   svet2,ax
           not   ax           
           jmp   m34
      m24: cmp   MS[si].Sig,0
           jne   m44
           not   ax
           and   svet1,ax
           and   svet2,ax
           not   ax
           jmp   m34           
      m44: or    svet1,ax
           or    svet2,ax
      m34: add   si,TYPE MS
           loop  next4    
           ret
Vyvodpolesvet  ENDP
Vyvod      PROC  NEAR
           mov   si,0
           xor   dx,dx
           mov   al,3
           mov   cl,DigCode
           mul   cl
           mov   si,ax
           mov   ax,40h
           cmp   MS[si].Poj,0ffh
           jne   c1
           or    buf,al    
           jmp   c3
       c1: not   al
           and   buf,al
           not   al
       c3: rol   al,1
           cmp   MS[si].Pro,0ffh
           jne   c2
           or    buf,al          
           jmp   c4
       c2: not   al
           and   buf,al
           not   al
       c4: mov   al,buf
           out   0h,al           
           inc   di
           cmp   di,0ffffh
           jne   a1
           inc   tyr
           cmp   tyr,5
           jne    a4
           not   bp
           mov   tyr,0
       a4: mov   di,0
       a1: cmp   bp,0
           jne   a2
           mov   al,byte ptr Svet1
           out   3h,al
           mov   al,byte ptr Svet1+1
           out   4h,al
           jmp   a3
     a2:   mov   al,byte ptr Svet2
           out   3h,al
           mov   al,byte ptr Svet2+1
           out   4h,al
     a3:   ret
Vyvod      ENDP
Funcproc   PROC  NEAR
           mov   Svet1,0
           mov   Svet2,0
           mov   DigCode,0
           mov   Home,0
           mov   KbdErr,0
           mov   Flag,0
           mov   Rez,0
           mov   bx,0
           mov   tyr,0
           mov   buf,0
           mov   si,0
           mov   cx,LENGTH MS
      s1:  mov   MS[si].Poj,0
           mov   MS[si].Pro,0
           mov   MS[si].Sig,0
           add   si,TYPE MS
           loop  s1
           mov   di,1
           mov   al,SymImages[di]
           out   DispPort2,al
           out   DispPort,al
           xor   al,al
           xor   di,di
           ret
Funcproc   ENDP
Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           call  Funcproc          
InfLoop:   
           call  Vyvod
           call  Pojar
           call  Pronic
           call  Ustanovka
           call  Snjatie
           call  Avarsit
           call  KbdInput
           call  KbdInContr
           call  NxtDigTrf
           call  NumOut
           jmp   InfLoop
;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END
