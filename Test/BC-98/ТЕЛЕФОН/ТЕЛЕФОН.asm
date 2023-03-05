.386

RomSize    EQU   4096

NumInTrubPort = 03h
NumOutTrubPort = 0Ch

max1 = 50        ;��।����� �६� ��७�� (��襭��) �������� "������"
max2 = 120       ;�� �������� ���� ��㡪� �� ⥫�䮭�

NMAX = 50        ;����⠭� ���������� �ॡ����

KolRazr = 12     ;����來���� �����

Data       SEGMENT AT 0000h use16
           
           Memory    DB 10 DUP (KolRazr DUP(?))    ;������
           BlackList DB 10 DUP (KolRazr DUP(?))    ;���� ᯨ᮪ 
           
           InTelephon  DB KolRazr DUP (?)      ;����騩 ⥫�䮭 (�⮡ࠦ����� �� ���������)
           OutTelephon DB KolRazr DUP (?)      ;����䮭,� ���. ������ � ���
           DispData    DB KolRazr DUP (?)      ;���ᨢ �⮡ࠦ����   
       
           Status DB ?        ;����饥 ���ﭨ� ⥫�䮭�
           Digit  DB ?        ;������ ��� � ����� ������   
           Index  DB ?        ;����� ⥪�饩 �祩�� ����� ��� �. ᯨ᪠
             
           InTrubPort  DB ?                   ;���� ������ ��㡮� � �������
           OutTrubPort DB ?                   ;���� ���-஢ "������","������"
                                              ;� ���ﭨ� ��㡮�
           MyTrubka DB ?                      ;����ﭨ� ��㡮� (FF-����)
           Trubka1  DB ?                      ;
           Trubka2  DB ?                      ;
           TrubkaAll DB ?                     ;   
           
           Flag   DB ?                        ;������ �� (FF)��� ��� (0)
           Zvonok DB ?                        ;���� ������(FF)
           TekPhone DB ?                      ;������ ⥫.,� ���. �ந�������� ������
           Speek  DB ?                        ;����� �������
           Mig    DB ?                        ;���� ������, �� ��㡪� �� ���
          
           Cx1 DB ?
           Cx2 DB ?
           Point DB ?
           
           KeyImg      DB 3 DUP (?)    ;��ࠧ ����������
           KeyErr      DB ?            ;�訡�� ����� ��� ����� ���������  
           NumKeyPress DB ?            ;����� ����⮩ ������
           
           BLDisp  DB KolRazr DUP (?)  ;���ᨢ �⮡ࠦ���� "0...��"  
           MemDisp DB KolRazr DUP (?)  ;���ᨢ �⮡ࠦ���� "0...0�"  
           
           Vyzov DW ?
           
           Del1  DD ?
           
Data       ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

           ASSUME cs:Code,ds:Data,es:Data

FuncPrep   PROC NEAR                          ;��砫쭠� �����⮢��         
         
           mov   OutTrubPort,0
           mov   Zvonok,0
           mov   Speek,0
           mov   Mig,0
           
           call  NulInTel                     ;���� ⥪�饣� ����� ⥫�䮭�
           
           mov   MemDisp[0],10                ;���樠������ ���. �⮡�.                 
           mov   si,1                         ;��� �����
     FP1:                  
           mov   MemDisp[si],13
           inc   si
           cmp   si,KolRazr
           jne   FP1
           
           mov   BLDisp[0],12                 ;���樠������ ���. �⮡�. 
           mov   BLDisp[1],11                 ;��� ��୮�� ᯨ᪠
           mov   si,2
     FP2:                  
           mov   BLDisp[si],13
           inc   si
           cmp   si,KolRazr
           jne   FP2
           
           mov   Status,0
           mov   Point,0
           
           call  NulM&BL                     ;���樠������ �祥� ����� � �. ᯨ᪠ 
       
           RET
FuncPrep   ENDP

NulInTel   PROC NEAR                         ;���� ⥪�饣� ����� ⥫�䮭�

           mov   cx,KolRazr                 
           lea   si,InTelephon
     NextRazr:      
           mov   byte ptr [si],13
           inc   si
           loop  NextRazr           

           RET
NulInTel   ENDP           

NulM&BL    PROC NEAR                         ;���樠������ �祥� ����� 
                                             ;� ��୮�� ᯨ᪠ 
           
           mov   dl,KolRazr                  ;���樠������ �祥� ����� 
           mov   dh,0
        MBL1:   
           mov   di,0
           mov   cx,KolRazr
           mov   al,dh
           mul   dl
           mov   bx,ax
        MBL2:   
           mov   Memory[bx][di],13
           inc   di
           loop  MBL2
           inc   dh
           cmp   dh,10
           je    exitMBL1
           jmp   MBL1
        exitMBL1:  
       
           mov   dl,KolRazr                  ;���樠������ ��୮�� ᯨ᪠ 
           mov   dh,0
        MBL3:   
           mov   di,0
           mov   cx,KolRazr
           mov   al,dh
           mul   dl
           mov   bx,ax
        MBL4:   
           mov   BlackList[bx][di],13
           inc   di
           loop  MBL4
           inc   dh
           cmp   dh,10
           je    exitMBL2
           jmp   MBL3
       exitMBL2:                
           
           RET
NulM&BL    ENDP

Trubki     PROC NEAR                          ;��।������ ���ﭨ� ��㡮�
           
           in    al,NumInTrubPort
           mov   InTrubPort,al
           and   al,01h                       ;�뤥����� ������ ��襩 ��㡪�
           cmp   al,0                         ;�᫨ �� ��� � ���室
           jz    m01 
               
           mov   MyTrubka,0FFh                ;��������� ���ﭨ� ��㡪�
           jmp   m02
           
       m01: mov   MyTrubka,0                  ;��������� ���ﭨ� ��㡪�
       
       m02: mov   al,InTrubPort    
           and   al,08h                       ;�뤥����� ������ ��㡪� �1
           cmp   al,0                         ;�᫨ �� ��� � ���室
           jz    m03
           
           mov   Trubka1,0FFh                 ;��������� ���ﭨ� ��㡪�
           jmp   m04
                    
       m03: mov   Trubka1,0                   ;��������� ���ﭨ� ��㡪�
           
       m04: mov   al,InTrubPort
           and   al,40h                       ;�뤥����� ������ ��㡪� �1
           cmp   al,0                         ;�᫨ �� ��� � ���室
           jz    m05
           
           mov   Trubka2,0FFh                 ;��������� ���ﭨ� ��㡪� 
           jmp   m06
           
       m05: mov   Trubka2,0                   ;��������� ���ﭨ� ��㡪�
           
       m06:
           mov   al,InTrubPort
           and   al,80h
           cmp   al,0
           jz    m07
           
           mov   TrubkaAll,0FFh
           jmp   m08
       m07: mov   TrubkaAll,0                    
           
       m08:    
           RET        
Trubki     ENDP

OutTrubStatus    PROC NEAR         ;�뢮� ������樨 � ���ﭨ�� ��㡮�  
           
           mov   ah,OutTrubPort
           mov   al,MyTrubka
           cmp   al,0FFh
           jnz   m11
           or    ah,01h          ;�᫨ ��� ��㡪� ���, � ������ ��������  
           jmp   m12
           
       m11: and   ah,0FEh        ;�᫨ ��� - �������
       m12: mov   al,Trubka1
           cmp   al,0FFh
           jnz   m13
           or    ah,08h          ;�᫨ ��㡪� �1 ���, � ������ ��������
           jmp   m14
           
       m13: and   ah,0F7h        ;�᫨ ��� - �������
       m14: mov   al,Trubka2
           cmp   al,0FFh
           jnz   m15
           or    ah,40h          ;�᫨ ��㡪� �2 ���, � ������ ��������
           jmp   m16
           
       m15: and   ah,0BFh        ;�᫨ ��� - �������
       
       m16:
           mov   al,TrubkaAll
           cmp   al,0FFh
           jnz   m17
           or    ah,80h
           jmp   m18
      
       m17: and   ah,7Fh
       m18:    
           mov   al,ah          
           mov   OutTrubPort,al
           out   NumOutTrubPort,al
                   
           RET      
OutTrubStatus    ENDP

Zvonki1    PROC NEAR                 ;�஢�ઠ ����㯨� �� ������

           xor   cx,cx
           cmp   Zvonok,0FFh         ;���� ������ � ����� ������?
           jz    exit1               ;�᫨ �� - ��室
           mov   cl,2                ;����㧪� ����稪� 横���
      Next1:     
           in    al,NumInTrubPort    ;����㧪� � al ���ﭨ� ������
           
           cmp   Cl,2                
           jnz   m31
           
           and   al,04h              ;�뤥����� ������ "������" ⥫�䮭� �1
           cmp   Trubka1,0           ;��㡪� ���?
           jz    m3                  ;�᫨ ��� - ���室
           jmp   m32          
       m31:    
           and   al,20h              ;�뤥����� ������ "������" ⥫�䮭� �2
           cmp   Trubka2,0           ;��㡪� ���?
           jz    m3                  ;�᫨ ��� - ���室
       m32:
           cmp   al,0                ;����� ������ "������"?
           jz    m3                  ;�᫨ ��� - ���室
           
           cmp   MyTrubka,0          ;�஢�ઠ ���ﭨ� ��㡪� �� ��襬 ⥫�䮭�
           jnz   m3                  ;�᫨ ���, � ���室
           
           mov   TekPhone,cl         ;����������� ������ ⥫., � ���. ������          
           call  WriteTel            ;����������� ����� ⥫�䮭�
           call  ProvBL              ;�஢�ઠ ��୮�� ᯨ᪠
           jmp   exit1
       m3:
           loop  next1               ;�� ⥫�䮭�?
       exit1:
           RET      
                               
Zvonki1    ENDP

WriteTel   PROC NEAR                     ;����������� ����� ⥫�䮭�
           
           mov   di,0
           mov   cx,KolRazr
           
           cmp   TekPhone,2
           jne   WT1
           lea   bx,Tel1
           jmp   WT2
       WT1:
           lea   bx,Tel2
       WT2:
           mov   al,cs:[bx][di]
           mov   OutTelephon[di],al
           inc   di
           loop  WT2    
                          
           RET
WriteTel   ENDP

ProvBL     PROC NEAR                     ;�஢�ઠ ��୮�� ᯨ᪠

           mov   dl,KolRazr              ;����㧪� � dl ࠧ�來��� �����
           mov   dh,0                    ;����㧪� ����� �祩�� ����� �. ᯨ᪠
       PBL4:    
           mov   cl,KolRazr
           mov   ch,0                    ;����㧪� �᫠ ᮢ����� ࠧ�冷�
           mov   di,0
           mov   al,dh                   ;��।������ ᬥ饭��
           mul   dl                      ;
           mov   bx,ax                   ;
       PBL2:    
           mov   al,BlackList[bx][di]
           cmp   OutTelephon[di],al
           jne   PBL1
           
           inc   ch
           cmp   ch,KolRazr              ;�� ࠧ��� ᮢ����?
           je    exit_PBL                ;�᫨ �� - ���室
           
           inc   di
           dec   cl
           cmp   cl,0                    ;�� ࠧ���?
           jne   PBL2                    ;�᫨ ��� - ���室
       PBL1:    
           inc   dh
           cmp   dh,10                   ;�� �祩��?
           je    PBL3                    ;�᫨ �� ���室
           jmp   PBL4
       PBL3:
           mov   Zvonok,0FFh             ;����㯨� ������
           mov   Flag,0                  ;�� ��� ⥫�䮭
       exit_PBL:
               
           RET
ProvBL     ENDP

OutZvStatus PROC NEAR            ;�뢮� �� ��������� "������","������"
                  
           mov   al,OutTrubPort
           cmp   Speek,0
           jnz   m41
           
           and   al,0FBh
           jmp   m42
        m41:
           or    al,04h
        m42:
           cmp   Mig,0
           jnz   m43
           
           and   al,0FDh
           jmp   m44
        m43:
           or    al,02h
        m44:
           mov   OutTrubPort,al
           out   NumOutTrubPort,al            
         
           RET            
     
OutZvStatus ENDP

Zvonki2    PROC NEAR             ;�஢�ઠ �� �������� �� ��㡪�

           cmp   Zvonok,0
           jz    exit3

           cmp   MyTrubka,0FFh   ;�������� ��㡪� �� ��襬 ⥫�䮭�?
           jz    m5              ;�᫨ ���, � ���室
           
           cmp   Flag,0FFh       ;�� ������?
           je    Sbros           ;�᫨ �� - ���室
                   
           cmp   Speek,0FFh      ;������� ࠧ�����?
           jnz   m5              ;�᫨ ��� - ���室
       Sbros:                    ;�᫨ �������� ��㡪�, � ��� ������ 
           mov   Zvonok,0
           mov   Speek,0
           mov   Mig,0
           jmp   exit3
       m5:
           xor   cx,cx           ;�������� ��㡪� �� ��㣮� ⥫�䮭�?
           mov   cl,2            ;����㧪� �᫠ ⥫�䮭��
       m51:
           cmp   cl,2
           jnz   m52
           
           mov   al,Trubka1
           jmp   m53
       m52:
           mov   al,Trubka2
       m53:
           cmp   al,0FFh         ;���� ��㡪� �� ��. ⥫�䮭�?  
           jz    mm5             ;�᫨ �� - ���室
;       mm6:    
           cmp   cl,TekPhone     ;������� ����� ⥫�䮭 ⥪�騬?
           jnz   mm5             ;��� - ���室
       mm6:    
           cmp   Flag,0          ;������ � �⮣� ⥫�䮭� ��� �� ����?
           jz    Sbros           ;�᫨ � �⮣� ⥫�䮭� - ���室
           
           cmp   Speek,0         ;������� ࠧ�����?
           jne   Sbros           ;�� - ���室
           jmp   exit3
       mm5:
           loop  m51             ;�� ⥫�䮭�?
           
           mov   al,TrubkaAll
           cmp   al,0FFh
           jz    exit3
           cmp   cl,TekPhone
           jz    mm6
;           jmp   mm6
                                    
       exit3:
           RET    

Zvonki2    ENDP

Zvonki3    PROC NEAR             ;�������� ���� ��㡪� �� ��襬 ⥫�䮭�

           cmp   Zvonok,0
           jz    exit4
           
           cmp   Flag,0FFh
           je   m62
           
           cmp   MyTrubka,0FFh
           jnz    m61
        m64:    
           mov   Speek,0FFh      
           mov   Mig,0
           jmp   exit4
        m61:
           mov   Speek,0
           Call  Miganie      
           jmp   exit4
           
        m62:
           cmp   TekPhone,2
           jnz   m63
           cmp   Trubka1,0FFh
           jnz   m61       
           jmp   m64
        m63:
           cmp   TekPhone,1
           jnz   m65;exit4;m65
           cmp   Trubka2,0FFh
           jnz   m61
           jmp   m64
        m65:
           cmp   TrubkaAll,0FFh
           jnz   m61
           jmp   m64    
              
        exit4:   
           RET   
           
Zvonki3    ENDP

Miganie    PROC NEAR             ;������� �� ������

           cmp   Mig,0
           jnz   m7
           
           inc   Cx1
           cmp   Cx1,max1
           jnz   exit5
           
           mov   Cx1,0
           not   Mig
       m7:
           inc   Cx2
           cmp   Cx2,max2
           jnz   exit5
           
           mov   Cx2,0
           not   Mig
      exit5:
           RET         

Miganie    ENDP

KeyReadContr PROC NEAR                   ;���� � ���������� � ����஫�

           xor   cx,cx
           lea   si,KeyImg           
           mov   cl,length KeyImg
           mov   dx,0                    ;⥪�騩 ���� := 0
      nextport:     
           in    al,dx                   ;���� ���ﭨ� ⥪�饣� ����
           cmp   al,0                    ;���� ������ ������?
           je    KRC1                    ;�᫨ ��� - ���室
           
           call VibrDestr                ;��襭�� �ॡ���� 
           
           mov   [si],al                 ;����������� ���ﭨ� ����
      KRC2:     
           in    al,dx                   ;�������� ���᪠��� ������
           cmp   al,0                    ;����⨫�?
           jne   KRC2                    ;��� - ���室
           
           call VibrDestr                ;��襭�� �ॡ����
           
           jmp   KRC3
      KRC1:     
           mov   [si],al                 ;����������� ���ﭨ� ����    
      KRC3:     
           inc   si
           inc   dx
           loop  nextport                ;�� �����
           
           Lea   si,KeyImg               ;����஫� ����� � ����������
           mov   dl,0                    ;����㧪� � dl �᫠ ������� ������
           mov   cl,length KeyImg
           mov   dh,1
      nextstr1:
           mov   ch,8
      nextbit1:
           mov   al,[si]
           and   al,dh
           cmp   al,0
           jz    m81
           
           inc   dl
      m81:
           rol   dh,1
           
           dec   ch
           cmp   ch,0
           jnz   nextbit1
           
           inc   si
           dec   cl
           cmp   cl,0                
           jnz   nextstr1
           
           cmp   dl,1                    ;�᫨ ����� ����� ����� ������ 
           jne   error                   ;��� �� ����� ������ ����� �뤠�� �訡��
           
           mov   KeyErr,0
           jmp   exit7
      error:
           mov   KeyErr,0FFh             ;KeyErr=FF - ���� �訡��  
      exit7:     
           RET            

KeyReadContr ENDP

NumKey     PROC NEAR                 ;��।������ ����� ����⮩ ������
           
           cmp   KeyErr,0FFh         ;case KEY do          
           jz    exit8               ;
                                     ;"0":        NumKeyPress=1
           lea   si,KeyImg           ;"1":        NumKeyPress=2
           mov   cl,length KeyImg    ;"2":        NumKeyPress=3  
           mov   dl,1                ;"3":        NumKeyPress=4
           mov   dh,1                ;"4":        NumKeyPress=5
                                     ;"5":        NumKeyPress=9
      nextstr2:                      ;"6":        NumKeyPress=10
           mov   ch,8                ;"7":        NumKeyPress=11
      nextbit2:                      ;"8":        NumKeyPress=12
           mov   al,[si]             ;"9":        NumKeyPress=13
           and   al,dh               ;"�����":    NumKeyPress=17
           cmp   al,0                ;"������":   NumKeyPress=18
           jnz   write_num           ;"������":   NumKeyPress=19
                                     ;"�����":    NumKeyPress=20
           inc   dl                  ;"�.�.":     NumKeyPress=21
           rol   dh,1                ;"���.":     NumKeyPress=22
           dec   ch                  ;
           cmp   ch,0                ;
           jnz   nextbit2            ;
                                     ;
           inc   si                  ;
           dec   cl                  ;
           cmp   cl,0                ;            
           jnz   nextstr2            ;    
      write_num:                     ;   
           mov   NumKeyPress,dl      ;����������� ����� ����⮩ ������
      exit8:
           RET
NumKey     ENDP

MainProc   PROC NEAR                 ;�믮������ ����⢨� � ����ᨬ��� ��
                                     ;����⮩ ������
           cmp   KeyErr,0FFh
           je    exit9
           
           cmp   NumKeyPress,14      ;�᫨ ����� �� ���,     
           ja    m111                ;� ���室
           call  DigitKey            ;����������� ����⮩ ����
           mov   al,0
           jmp   m112
      m111:
           mov   al,NumKeyPress
           sub   al,16    
      m112:
           mov   dl,5                ;��।������ ᬥ饭��
           mul   dl                  ;
           lea   bx,Base             ;
           add   ax,bx               ;
           jmp   ax
      Base:
           call  DigitPress          ;�맮� ��楤��� �� ����⨨ ����
           jmp   exit9          
           call  NaborPress          ;�맮� ��楤��� �� ����⨨ "�����"
           jmp   exit9
           call  MemPress            ;�맮� ��楤��� �� ����⨨ "������"
           jmp   exit9           
           call  EnterPress          ;�맮� ��楤��� �� ����⨨ "���."
           jmp   exit9           
           call  ResetPress          ;�맮� ��楤��� �� ����⨨ "�����"
           jmp   exit9
           call  BLPress             ;�맮� ��楤��� �� ����⨨ "�. ������"
           jmp   exit9           
           call  RedactPress         ;�맮� ��楤��� �� ����⨨ "���."
           
      exit9:                           
           RET
MainProc   ENDP

DigitKey   PROC NEAR                 ;����������� ����⮩ ����
           
           mov   al,NumKeyPress
           cmp   NumKeyPress,8
           jb    DK01
           
           sub   al,3
      DK01:
           dec   al
           mov   Digit,al     
           
           RET
DigitKey   ENDP

DigitPress PROC NEAR

           xor   ax,ax
           mov   al,Status
           mov   dl,5
           mul   dl
           lea   bx,Base2
           add   ax,bx
           jmp   ax
      Base2:
           call  ModifTel
           jmp   exit10
           call  OutMem
           jmp   exit10
           call  OutBL
           jmp   exit10
           call  OutMem
           jmp   exit10
           call  OutBL
           jmp   exit10
           call  ModifTel
           jmp   exit10
           call  ModifTel
           jmp   exit10
           nop                                                                       
      exit10:
           RET
DigitPress ENDP

ModifTel   PROC NEAR
           
           xor   ax,ax
           mov   al,Point
           mov   si,ax
       next_MT:    
           cmp   si,0
           jne   MT1
           
           mov   al,Digit
           jmp   MT2
       MT1:
           mov   al,InTelephon[si-1]
       MT2:
           mov   InTelephon[si],al
           cmp   si,0
           je    exit1_MT
           
           dec   si
           jmp   next_MT  
       exit1_MT:
           cmp   Point,KolRazr-1
           je    exit2_MT
           inc   Point
       exit2_MT:              

           RET
ModifTel   ENDP

OutMem     Proc NEAR

           mov   cx,KolRazr
           mov   di,0
           mov   al,Digit
           mov   dl,KolRazr
           mul   dl
           mov   bx,ax
      OM01:
           mov   al,Memory[bx][di]
           mov   InTelephon[di],al
           inc   di
           loop  OM01
           mov   Status,3
           mov   al,Digit
           mov   Index,al
                
           RET
OutMem     ENDP

OutBL      PROC NEAR

           mov   cx,KolRazr
           mov   di,0
           mov   al,Digit
           mov   dl,KolRazr
           mul   dl
           mov   bx,ax
      OBL1:
           mov   al,BlackList[bx][di]
           mov   InTelephon[di],al
           inc   di
           loop  OBL1
           mov   Status,4
           mov   al,Digit
           mov   Index,al
                
           RET
OutBL      ENDP

NaborPress PROC NEAR
           
           cmp   Status,0
           je    NP_01
           cmp   Status,3
           jne   exit_NP
      NP_01:    
           cmp   Zvonok,0FFh
           je    exit_NP
           
           cmp   MyTrubka,0
           je    exit_NP
           
           call  SigVyz
           
           mov   dl,2
      NP_4:     
           mov   ch,0
           mov   cl,KolRazr
           mov   di,0
      NP_3:     
           cmp   dl,2
           jne   NP_1
           
           lea   bx,Tel1
           mov   al,cs:[bx][di]
           jmp   NP_5
      NP_1:
           lea   bx,Tel2
           mov   al,cs:[bx][di]
      NP_5:
           cmp   InTelephon[di],al
           jne   NP_2
           
           inc   ch
           cmp   ch,KolRazr
           je    break_NP
      
           inc   di
           dec   cl
           cmp   cl,0
           jne   NP_3     
      NP_2:     
           dec   dl
           cmp   dl,0
           je    all_NP  ;exit_NP
           jmp   NP_4
           
      all_NP:
           cmp   TrubkaAll,0FFh
           je    exit_NP
           jmp   exit_NPno  
              
      break_NP:
           call  Nabor2
     
                        
      exit_NP:         
           RET
NaborPress ENDP                      

Nabor2     PROC  NEAR

           cmp   dl,2
           jne   mNP_1
           cmp   Trubka1,0FFh
           je    exit_NP2
           jmp   exit_NPno              
      mNP_1:
           cmp   Trubka2,0FFh
           je    exit_NP2
           jmp   exit_NPno 
      exit_NPno:
           mov   Zvonok,0FFh
           mov   TekPhone,dl
           mov   Flag,0FFh  
           jmp   exit_NP2 
      exit_NP2:      
           RET
Nabor2     ENDP    


MemPress   PROC NEAR

           cmp   Status,0
           je    MP02
           cmp   Status,2
           je    MP02
           cmp   Status,3
           je    MP02
           jmp   MP01
      MP02:     
           mov   Status,1
      MP01:     

           RET
MemPress   ENDP

EnterPress PROC NEAR

           cmp   Status,6
           jne   EP1
           mov   ch,2
           jmp   EP2
      EP1:
           cmp   Status,5
           jne   EP3
           mov   ch,1
           jmp   EP2
      EP3:
           jmp   exit_EP
      EP2:
           mov   cl,KolRazr
           mov   di,0
           mov   al,Index
           mov   dl,KolRazr
           mul   dl
           mov   bx,ax
      EP6:     
           mov   al,InTelephon[di]
           cmp   Status,5
           jne   EP4               
           mov   Memory[bx][di],al
           jmp   EP5
      EP4:
           mov   BlackList[bx][di],al
      EP5:
           inc   di
           dec   cl
           cmp   cl,0
           jne   EP6                    
           mov   Status,ch 
      exit_EP: 
   
           RET
EnterPress ENDP     

ResetPress PROC NEAR

           mov   Status,0
           mov   Point,0
     
           call  NulInTel                 ;InTelephon:=00...0
           
           RET
ResetPress ENDP

BLPress    PROC NEAR
           
           cmp   Status,0
           je    BL02
           cmp   Status,1
           je    BL02
           cmp   Status,4
           je    BL02
           jmp   BL01
       BL02:    
           mov   Status,2
       BL01:   
                    
           RET
BLPress    ENDP
 
RedactPress PROC NEAR

           cmp   Status,4
           je    RP1
           cmp   Status,3
           je    RP2
           jmp   exit_RP
       RP1:
           mov   Status,6
           mov   Point,0
           call  NulInTel
           jmp   exit_RP
       RP2:
           mov   Status,5
           mov   Point,0
           call  NulInTel        
       exit_RP:    

           RET
RedactPress ENDP               

DispForm   PROC NEAR

           Lea   di,DispData
           mov   cx,KolRazr
           
           cmp   Status,2
           jne   m101
           lea   si,BLDisp
           jmp   m103
       m101:
           cmp   Status,1
           jne   m102
           lea   si,MemDisp
           jmp   m103
       m102:
           lea   si,InTelephon
       m103:
           mov   al,[si]
           mov   [di],al
           inc   si
           inc   di
           loop  m103            

           RET
DispForm   ENDP

OutInf     PROC NEAR


           lea   di,DispData
           Lea   bx,XlatTabl
           mov   cx,KolRazr
           mov   dx,0
           
           mov   ax,cs
           mov   ds,ax
       OI1:    
           mov   al,es:[di]
           xlat
           out   dx,al
           inc   di
           inc   dx
           loop  OI1
           
           mov   ax,es
           mov   ds,ax
           
           RET
OutInf     ENDP

OutStatus  PROC NEAR

           mov   al,OutTrubPort
           cmp   Status,1
           je    _OS_M1
           cmp   Status,3
           je    _OS_M1
           cmp   Status,5
           je    _OS_M1
           jmp   _OS_1
      _OS_M1:
           or    al,020h
           jmp   _OS_2
      _OS_1:
           and   al,0DFh
      _OS_2:
           cmp   Status,2
           je    _OS_BL1
           cmp   Status,4
           je    _OS_BL1
           cmp   Status,6
           je    _OS_BL1
           jmp   _OS_3
      _OS_BL1:
           or    al,010h
           jmp   _OS_4
      _OS_3:
           and   al,0EFh
      _OS_4:  
           mov   OutTrubPort,al
;           out   NumOutTrubPort,al                           
           RET
OutStatus  ENDP

VibrDestr  PROC NEAR

      VD1:
           mov   ah,al
           mov   bh,0
      VD2:
           in    al,dx
           cmp   ah,al
           jne   VD1
           inc   bh
           cmp   bh,NMAX
           jne   VD2
           mov   al,ah
    
           RET
VibrDestr  ENDP

SigVyz     PROC NEAR
           
           
           mov   si,KolRazr
      SV2:  
           mov   Vyzov,0   
           mov   cl,InTelephon[si-1]
           cmp   cl,13
           je    next_SV
           
           inc   cl
           mov   dx,1
      SV1:     
           or    Vyzov,dx
           shl   dx,1
           dec   cl
           cmp   cl,0
           jne   SV1
           
           mov   al,byte ptr Vyzov
           out   0Dh,al
           mov   al,byte ptr Vyzov+1
           out   0Eh,al
           
           call  Delay
           
      next_SV:
                
           dec   si
           cmp   si,0
           jne   SV2
           
           mov   Vyzov,0
           mov   al,byte ptr Vyzov
           out   0Dh,al
           mov   al,byte ptr Vyzov+1
           out   0Eh,al   
           
           RET
SigVyz     ENDP

Delay      PROC NEAR
           
           mov   word ptr del1,0FFFFh
           mov   word ptr del1,0FFFFh
       mD:    
           mov   ax,word ptr del1
           sub   ax,1
           mov   word ptr del1,ax
           mov   ax,word ptr del1+2
           sbb   ax,0
           mov   word ptr del1+2,ax
           
           cmp   word ptr del1,0
           jne   mD
           cmp   word ptr del1,0
           jne   mD

           RET
Delay      ENDP

XlatTabl   DB  03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh,0AFh,0CDh,0B3h,0
Tel1       DB  3,7,2,1,5,5,6 DUP (13)
Tel2       DB  1,2,3,5,4,2,6 DUP (13)
   
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
                   
;����� ࠧ��頥��� ��� �ணࠬ��
           Call  FuncPrep
      n:  
           Call  Trubki
           Call  OutTrubStatus
           
           Call  Zvonki1
           Call  Zvonki2
           Call  Zvonki3
           Call  OutZvStatus
           
           Call  KeyReadContr
           Call  NumKey
           Call  MainProc
           
           Call  DispForm
           Call  OutInf
           Call  OutStatus
           jmp   n
;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
