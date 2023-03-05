.386
;������ ���� ��� � �����
RomSize    EQU   4096


IntTable   SEGMENT AT 0 use16
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Data       SEGMENT AT 40h use16
;����� ࠧ������� ���ᠭ�� ��६�����
           image             db    10 dup (?)
           ARRW              db    3  dup (?)       ;���ᨢ ��� �६��� �ࠢ��� ��ப�  �� ����
           HOD1              db    ?                ;����⨥ �� ������ 1 ��ப��
           ARRB              db    3  dup (?)       ;�६� ������ ��ப�  
           HOD2              db    ?                ;����⨥ �� ������ 2 ��ப��
           kolvo             db    ?                ;�᫮ ��⠢���� 室��
           chc               db    ?                ;�ᯮ����⥫쭠� ��६�����
           flagnach          db    ?                ;�ᯮ����⥫쭠� ��६����� ��� ��।������ ��砫� ����
           FFASTGAME         db    ?                ;䫠� ०�� ����ன ����
           FGONG             db    ?                ;䫠� ०�� ����
           FDEF1             db    ?                ;䫠� - ��⠭���� � 1 ��ப�
           FDEF2             db    ?                ;䫠� - ��⠭���� � 2 ��ப�
           FDEF              db    ?                ;䫠� - ��� �� ०��� ��⠭����
           per               dw    ?                ;��� ��� ������⢠ 横��� �ணࠬ�� � 1
           per2              dw    ?                ;��� ��� 横��� �ணࠬ�� � 2 ��ப�
           t1                db    ?                ;䫠� ����砭�� �६��� � 1 ��ப�
           t2                db    ?                ;䫠� ����砭�� �६��� � 2 ��ப�
           del               dw    ?                ;᪮�쪮 横��� � ᥪ㭤�, 
                                                     ;�ᯮ������ � ����⠡�஢����
           mult10            dw    ?
           mult50            dw    ?
           norm              dw    ?                                                    
Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT AT 0100h use16
;������ ����室��� ࠧ��� �⥪�
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�
InitData   ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�


           ASSUME cs:Code,ds:Data,es:Data;ss:Stk
INITPROC   proc near
           mov   Image[0],03Fh                     ;��� "0"
           mov   Image[1],00Ch                     ;��� "1" 
           mov   Image[2],076h                     ;��� "2" 
           mov   Image[3],05Eh                     ;��� "3" 
           mov   Image[4],04Dh                     ;��� "4" 
           mov   Image[5],05Bh                     ;��� "5" 
           mov   Image[6],07Bh                     ;��� "6" 
           mov   Image[7],00Eh                     ;��� "7"
           mov   Image[8],07Fh                     ;��� "8" 
           mov   Image[9],05Fh                     ;��� "9" 
           mov   FGONG,0
           mov   FFASTGAME,0
           mov   FDEF1,0
           mov   FDEF2,0
           mov   arrw[0],0
           mov   arrw[1],0
           mov   arrw[2],0
           mov   arrb[0],0
           mov   arrb[1],0
           mov   arrb[2],0
           mov   kolvo,0
           mov   hod1,0
           mov   hod2,0
           mov   per,0
           mov   per2,0
           mov   t1,0
           mov   t2,0
           mov   chc,0
           mov   flagnach,0
           mov   mult10,0AAh
           mov   norm,0AAAh
           mov   mult50,0Ah
           mov   ax,norm
           mov   del,ax
           ret
           INITPROC endp
;-----------------------------------------------------------------------------------------------           
Kolvogong  proc  near
;           cmp   FGONG,1
;           jne   t22
           cmp   chc,1
           ;�᫨ 1 ��ப �����⨫ ����
           jne   t11
           cmp   hod1,1
           jne   t11
           jmp   plus1    
t11:       cmp   chc,2
           ;�᫨ ��ன ��ப �����⨫ ����
           jne   t22
           cmp   hod2,1
           jne   t22
plus1:     mov   al,kolvo
           xor   ah,ah
           add   al,1
           daa
           mov   kolvo,al
           jmp   t22
t22:         ret
           kolvogong         endp      
;-------------------------------------------------------------------------------------------------
KOLVOFASTGAME   proc near

           cmp   chc,1
           jne   d11
           cmp   hod1,1
           jne   d11
           jmp   minus1
d11:       cmp   chc,2
           jne   d22
           cmp   hod2,1
           jne   d22
           
minus1:    cmp   flagnach,0
           je    OK1
           mov   flagnach,0
           jmp   d22           
           
OK1:       mov   al,kolvo
           xor   ah,ah
           sub   al,1
           das
           mov   kolvo,al                       
 
           
   
d22:           
           cmp   kolvo,0
           jne   exkol
           ;�᫨ ������⢮ 室�� = 0
           ;1. ��⠭���� 䫠�� ����ன ���� - ���� ���� ����ன ����

           mov   ffastgame,2
           
           inc   ARRB[0]
           inc   ARRw[0]
           
           cmp   chc,1
           jne   ff1
           mov   chc,2
           jmp   exkol
ff1:       cmp   chc,2
           jne   exkol
           mov   chc,1           

exkol:     ret           
           KOLVOFASTGAME     endp
;-------------------------------------------------------------------------------------------------
indicacia  proc  near
   cmp   hod1,1
           jne   vr5
           mov   al,01h
           out   0,al
           jmp   exit0
           
vr5:       cmp   hod2,1
           jne   exindic
           mov   al,02h
           out   0,al    
           
exindic:   ret
           indicacia         endp
;-------------------------------------------------------------------------------------------------
scale      proc  near

           cmp   al,20h
           ;����� ������ *10
           jne   in50
           mov   ax,del
           cmp   ax,mult10
           ;�᫨ ��� 㦥 ��⠭������
           je    notm
           ;�᫨ - ���
           mov   ax,mult10
           jmp   ust
in50:      cmp   al,40h
           ;����� ������ *50
           jne   exscale
           mov   ax,del
           cmp   ax,mult50
           je    notm
           mov   ax,mult50   
ust:       mov   del,ax
           sub   ax,1
       ;��������� ⥪��� ���祭�� ���稪�� 横��
           mov   per,ax
           mov   per2,ax
           jmp   exscale                                  
notm:      mov   ax,norm
           mov   del,ax 
exscale:   ret
           scale endp
;-------------------------------------------------------------------------------------------------           
kolvohodov proc near
           cmp   FFASTGAME,1
           jne   vr6
           call  KOLVOFASTGAME
           jmp   vr10
vr6:       cmp   FFASTGAME,2
           je   vr8
           cmp   FGONG,1
           jne   vr7
           je    vr8
           
vr7:       cmp   FDEF,1
           jne   exopros0
           je    exit0
vr8:       ;�᫨ ⥪��� ��� - ����
           call  KOLVOGONG
vr10:           ret
           kolvohodov        endp
;-------------------------------------------------------------------------------------------------           
nowgame    proc near
           cmp   FFASTGAME,1
           je    exnow
           cmp   FGONG,1
           je    exnow
           jmp   exno
exnow:     mov   bl,1        
exno:      ret
           nowgame           endp
;-------------------------------------------------------------------------------------------------           
opr        proc near
vr3:       in    al,0
           cmp   al,0
           je    exopr
           mov   dl,al
vr4:       in    al,0
           cmp   al,0
           jne   vr4
           mov   al,dl          
exopr:     ret
           opr endp
;-------------------------------------------------------------------------------------------------           
STEPFG     PROC  near

           cmp   al,08h          ;�᫨ 1 ��ப ᤥ��� 室
           
           jne   bhod
           cmp   chc,0           ;���� 室 � ���
           jz    ar
           cmp   hod1,0          ;�� ���� ࠧ ᤥ��� 室
           je    exopros0
 ar:       mov   hod2,1
           mov   hod1,0
           cmp   chc,0
           jne   lab
           ;1 ��ப �����⨫ ����
           mov   chc,2
           mov   flagnach,1
           jmp   lab
           
bhod:      cmp   al,10h          ;�᫨ 2 ��ப ᤥ��� 室
           jne   exit0           
           cmp   chc,0
           jz    ar2
           cmp   hod2,0          ;�� ���� ࠧ ᤥ��� 室
           je    exopros0           
ar2:       mov   hod2,0
           mov   hod1,1   
           cmp   chc,0
           jne   lab
           ;2 ��ப �����⨫ ����
           mov   chc,1
           mov    flagnach,1           
           jmp   lab           

           
lab:       ;��宦� � ⮫쪮 �᫨ ���� �� ��ப�� ᤥ��� 室
           
           ;�뢮� ������⢠ 室��
           call  kolvohodov
exopros0:                      
           ;�뢮� ������� - ��⨢���� ��ப�
           call  indicacia    
           
exit0:

           ret
           STEPFG endp

;-------------------------------------------------------------------------------------------------           
STEPGONG   PROC  NEAR

           cmp   al,08h          ;�᫨ 1 ��ப ᤥ��� 室
           
           jne   black
           cmp   chc,0           ;���� 室 � ���
           jz    ar1
           cmp   hod1,0          ;�� ���� ࠧ ᤥ��� 室
           je    exit01
 ar1:       mov   hod2,1
           mov   hod1,0
           mov   ARRB[0], 0
           mov   ARRB[1], 0
           mov   ARRB[2], 20h          
           
           cmp   chc,0
           jne   lab1
           ;1 ��ப �����⨫ ����
           mov   chc,2
           mov   flagnach,1
           

 
           jmp   lab1
           
black:     cmp   al,10h          ;�᫨ 2 ��ப ᤥ��� 室       
           jne   exit01
           cmp   chc,0
           jz    ar21
           cmp   hod2,0          ;�� ���� ࠧ ᤥ��� 室
           je    exstepg           
ar21:       mov   hod2,0
           mov   hod1,1
          mov   ARRW[0], 0
           mov   ARRW[1], 0
           mov   ARRW[2], 20h              
              
           cmp   chc,0
           jne   lab1
           ;2 ��ப �����⨫ ����
           mov   chc,1
           mov    flagnach,1    
                
           jmp   lab1

           
lab1:       ;��宦� � ⮫쪮 �᫨ ���� �� ��ப�� ᤥ��� 室
           
           ;�뢮� ������⢠ 室��
           call  kolvohodov

exstepg:                      
           ;�뢮� ������� - ��⨢���� ��ப�
           call  indicacia    
           
exit01:

           RET
           STEPGONG      ENDP  

;-------------------------------------------------------------------------------------------------           
PLUSODIN   proc  near
           cmp   FDEF1,1
           je    pw1
           cmp   FDEF2,1
           je    pw2
           jmp   ExPOdin
           
pw1:       cmp   FDEF,1
           je    pps
           cmp   FDEF,2
           je    ppm
           cmp   FDEF,3
           je    pph   
           jmp   expodin        
           
pps:       mov   al,ARRw[2]
           add   al,1
           daa
           mov   ARRw[2],al
           cmp   ARRW[2],01100000b
           jne   expodin
           mov   ARRW[2],0 
           jmp   expodin
           
ppm:       mov   al,ARRw[1]
           add   al,1
           daa
           mov   ARRw[1],al
           cmp   ARRW[1],01100000b
           jne   expodin
           mov   ARRW[1],0 
           jmp   expodin               

pph:       mov   al,ARRw[0]
           add   al,1
           daa
           mov   ARRw[0],al
           and   ARRW[0],00001111b
           cmp   ARRW[0],00001010b
           jne   expodin
           mov   ARRW[0],0 
           jmp   expodin

expodin:   jmp   expodin1

pw2:       cmp   FDEF,1
           je    ppsb
           cmp   FDEF,2
           je    ppmb
           cmp   FDEF,3
           je    pphb           
           jmp   expodin
           
ppsb:      mov   al,ARRb[2]
           add   al,1
           daa
           mov   ARRb[2],al
           cmp   ARRb[2],01100000b
           jne   expodin
           mov   ARRb[2],0 
           jmp   expodin
           
ppmb:      mov   al,ARRb[1]
           add   al,1
           daa
           mov   ARRb[1],al           
           cmp   ARRb[1],01100000b
           jne   expodin
           mov   ARRb[1],0 
           jmp   expodin               

pphb:      mov   al,ARRb[0]
           add   al,1
           daa
           mov   ARRb[0],al           
           and   ARRb[0],00001111b
           cmp   ARRb[0],00001010b
           jne   expodin
           mov   ARRb[0],0 
           jmp   expodin
   
expodin1:   ret
           PLUSODIN          endp
;-------------------------------------------------------------------------------------------------    
MINUSODIN   proc  near

           cmp   FDEF1,1
           je    mpw1
           cmp   FDEF2,1
           je    mpw2
           jmp   mExPOdin
           
mpw1:       cmp   FDEF,1
           je    mpps
           cmp   FDEF,2
           je    mppm
           cmp   FDEF,3
           je    mpph   
           jmp   mexpodin        
           
mpps:       mov   al,ARRw[2]
           sub   al,1
           das
           mov   ARRw[2],al
           cmp   ARRW[2],10011001b
           jne   mexpodin
           mov   ARRW[2],01011001b
           jmp   mexpodin
           
mppm:       mov   al,ARRw[1]
           sub   al,1
           das
           mov   ARRw[1],al
           cmp   ARRW[1],10011001b
           jne   mexpodin
           mov   ARRW[1],01011001b 
           jmp   mexpodin               

mpph:       mov   al,ARRw[0]
           sub   al,1
           das
           mov   ARRw[0],al
           and   ARRW[0],00001111b
           cmp   ARRW[0],00001001b
           jne   mexpodin
           mov   ARRW[0],00001001b 
           jmp   mexpodin

mexpodin:   jmp   mexpodin1

mpw2:       cmp   FDEF,1
           je    mppsb
           cmp   FDEF,2
           je    mppmb
           cmp   FDEF,3
           je    mpphb           
           jmp   mexpodin
           
mppsb:      mov   al,ARRb[2]
           sub   al,1
           das
           mov   ARRb[2],al
           cmp   ARRb[2],10011001b
           jne   mexpodin
           mov   ARRb[2],01011001b 
           jmp   mexpodin
           
mppmb:      mov   al,ARRb[1]
           sub   al,1
           das
           mov   ARRb[1],al           
           cmp   ARRb[1],10011001b
           jne   mexpodin
           mov   ARRb[1],01011001b 
           jmp   mexpodin               

mpphb:      mov   al,ARRb[0]
           sub   al,1
           das
           mov   ARRb[0],al           
           and   ARRb[0],00001111b
           cmp   ARRb[0],00001001b
           jne   mexpodin
           mov   ARRb[0],00001001b
           jmp   mexpodin
   
mexpodin1:   ret
           MINUSODIN          endp
;-------------------------------------------------------------------------------------------------             
CHOICE   proc  near
           cmp   FDEF1,1
           je    qw1
           cmp   FDEF2,1
           je    qw1
           jmp   exchoice
qw1:       inc   FDEF           
           cmp   FDEF,4
           jne   exchoice
           mov   FDEF,1
                             
exchoice:  ret
           CHOICE          endp
;-------------------------------------------------------------------------------------------------               
DEFGAME    proc  near
           mov   FDEF1,0
           mov   FDEF2,0
           mov   FDEF,0
           
           cmp   al,08h      ;1
           je    et1
           cmp   al,10h
           je    et2
           jmp   exdefg
           
et1:       cmp   arrw[0],0
           jne   dp1
           cmp   arrw[1],0
           jne   dp1
           cmp   arrw[2],0
           jne   dp1
           jmp   exdefg
           

 dp1:      cmp   arrb[0],0
           jne   dp2
           cmp   arrb[1],0
           jne   dp2
           cmp   arrb[2],0
           jne   dp2
           jmp   exdefg
           

dp2:

           mov   hod1,0
           mov   hod2,1
           mov   chc,2           
           mov   FFASTGAME,2
           add   kolvo,1
           mov   al,0
           out   0,al
           jmp   exdefg
           
et2:        cmp   arrw[0],0
           jne   dp12
           cmp   arrw[1],0
           jne   dp12
           cmp   arrw[2],0
           jne   dp12
           jmp   exdefg
           

 dp12:      cmp   arrb[0],0
           jne   dp22
           cmp   arrb[1],0
           jne   dp22
           cmp   arrb[2],0
           jne   dp22
           jmp   exdefg
           

dp22:



           mov   hod1,1
           mov   hod2,0
           mov   chc,1
           mov   FFASTGAME,2
           add   kolvo,1
           mov   al,0
           out   0,al
           
           
exdefg:    ret
           DEFGAME           endp

;-------------------------------------------------------------------------------------------------               
OPROS0     proc near
           call  opr
           cmp   al,08h
           je    sw1
           cmp   al,10h
           je    sw1
           cmp   al,20h
           je    tw1
           cmp   al,40h
           je    tw1
           cmp   al,01h      ;+1
           je    sw2
           cmp   al,02h      ;-1
           je    sw3
           cmp   al,04h
           je    sw4
           
           jmp   exopr01
             
sw1:       cmp   FDEF1,1
           je    dop1
           cmp   FDEF2,1
           je    dop1
           jmp   dop3
           
dop1:      
           call  DEFGAME
           jmp   exopr01
    
    
                      
dop3:      cmp   FFASTGAME,0
           je    met2
           call  STEPFG
           jmp   exopr01
           
met2:      cmp   FGONG,1
           jne   exopr01
           call  STEPGONG     
           jmp   exopr01
           
tw1:       call  scale           
           jmp   exopr01
           
sw2:       call  plusodin
           jmp   exopr01
           
sw3:       call  minusodin
           jmp   exopr01      
           
sw4:       call  choice
           jmp   exopr01                           

exopr01:                 
  ret
           opros0 endp
;-------------------------------------------------------------------------------------------------
OPROS1     proc near
           in    al,1
           cmp   al,01
           jne   m1
           call  PRESSFASTGAME
           jmp   KOn
           
m1:        cmp   al,02
           jne   m2
           call  PRESSGONG
           jmp   Kon
m2:        cmp   al,04
           jne   m3
           call  PRESSDEF1           
           jmp   Kon
m3:        cmp   al,08
           jne   Kon
           call  PRESSDEF2           
KOn:       ret
           opros1 endp           
;-------------------------------------------------------------------------------------------------           
PRESSFASTGAME    proc near
           mov   ARRW[0], 2h
           mov   ARRW[1], 0
           mov   ARRW[2], 0
           mov   ARRB[0], 2h
           mov   ARRB[1], 0
           mov   ARRB[2], 0
           mov   FFASTGAME, 1
           mov   FGONG, 0
           mov   FDEF1, 0
           mov   FDEF2, 0
           mov   al,40h
           mov   kolvo,al
           mov   hod1,0
           mov   hod2,0
           mov   t1,0
           mov   t2,0
           mov   chc,0
           mov   al,0
           out   0,al
           mov   flagnach,0  
           ret   
           PRESSFASTGAME endp           
;-------------------------------------------------------------------------------------------------
PRESSGONG  proc near
           mov   ARRW[0], 0
           mov   ARRW[1], 0
           mov   ARRW[2], 20h
           mov   ARRB[0], 0
           mov   ARRB[1], 0
           mov   ARRB[2], 20h
           mov   FFASTGAME, 0
           mov   FGONG, 1
           mov   FDEF1, 0
           mov   FDEF2, 0
           mov   kolvo,0 
           mov   hod1,0
           mov   hod2,0
           mov   t1,0
           mov   t2,0
           mov   chc,0
           mov   al,0
           out   0,al
           mov   flagnach,0
ret
PRESSGONG endp
;-------------------------------------------------------------------------------------------------           
PRESSDEF1 proc near

           mov   ARRw[0], 0
           mov   ARRw[1], 0
           mov   ARRw[2], 0
           mov   kolvo,0
           
           mov   FFASTGAME,0
           mov   FGONG,0
           mov   t1,0
           mov   t2,0
           mov   hod1,0
           mov   hod2,0
           mov   chc,0

           mov   FDEF1,1
           mov   FDEF2,0

           mov   al,0
           out   0,al
           
           mov   FDEF,1      ;��⠭���� ᥪ㭤
           
ret
pressdef1 endp
;-------------------------------------------------------------------------------------------------           
PRESSDEF2 proc near
           mov   ARRb[0], 0
           mov   ARRb[1], 0
           mov   ARRb[2], 0
           mov   kolvo,0
           
           mov   FFASTGAME,0
           mov   FGONG,0
           mov   t1,0
           mov   t2,0
           mov   hod1,0
           mov   hod2,0
           mov   chc,0

           mov   FDEF1,0
           mov   FDEF2,1
           mov   al,0
           out   0,al

           
           mov   FDEF,1      ;��⠭���� ᥪ㭤
ret
pressdef2 endp
;-------------------------------------------------------------------------------------------------           
TODISPLAY  proc  near
        ;   cmp   FFASTGAME,1
        ;   jne   extod
           lea   bx, Image
           mov   al,arrw[0]
           xor   ah,ah
           and   al,00001111b
           xlat
           cmp   FDEF1,1
           jne   q1
           cmp   FDEF,3
           jne   q1   
           or    al,10000000b
q1:        out   1,al        ;�뢮� ������⢠ �ᮢ �� �࠭ ��� �ࠢ��� ��ப�
           
           mov   al,arrb[0]
           xor   ah,ah
           and   al,00001111b
           xlat
           cmp   FDEF2,1
           jne   q2
           cmp   FDEF,3
           jne   q2   
           or    al,10000000b           
q2:        out   6,al        ;�뢮� ������⢠ �ᮢ �� �࠭ ��� ������ ��ப�
           
           
           mov   al,arrw[1]  ; ������ ��� �e��� �ࠢ��� ��ப�
           xor   ah,ah
           mov   ah,al
           and   al,00001111b
           xlat
           cmp   FDEF1,1
           jne   q3
           cmp   FDEF,2
           jne   q3 
                      or    al,10000000b                
q3:        out   3,al
           shr   ah,4
           mov   al,ah
           xlat
           

           out   2,al           

           mov   al,arrb[1]
           xor   ah,ah
           mov   ah,al
           and   al,00001111b
           xlat
           cmp   FDEF2,1
           jne   q4
           cmp   FDEF,2
           jne   q4   
                      or    al,10000000b                                      
q4:            
           out   8,al
           shr   ah,4
           mov   al,ah
           xlat
           out   7,al           
           
           mov   al,arrw[2]      ;ᥪ㭤� ��� �����
           xor   ah,ah
           mov   ah,al
           and   al,00001111b
           xlat
           cmp   FDEF1,1
           jne   q5
           cmp   FDEF,1
           jne   q5              
           or    al,128
           
q5:            
           out   5,al
           shr   ah,4
           mov   al,ah
           xlat
           out   4,al           

           mov   al,arrb[2]      
           xor   ah,ah
           mov   ah,al
           and   al,00001111b
           xlat
           cmp   FDEF2,1
           jne   q6
           cmp   FDEF,1
           jne   q6         
                                 or    al,10000000b                     
q6:            
           
           out   0Ah,al
           shr   ah,4
           mov   al,ah
           xlat
           out   9,al           
           
           mov   al,kolvo    ;�뢮� ������⢠ 室��
           xor   ah,ah
           mov   ah,al
           and   al,00001111b
           xlat
           out   0Ch,al
           shr   ah,4
           mov   al,ah
           xlat
           out   0Bh,al
           
           
extod:     ret
           TODISPLAY         endp      
;-------------------------------------------------------------------------------------------------           
DECR  proc  near
;�� ��⨢��?
           cmp   hod1,1
           je    n1   
           cmp   hod2,1
           jne    exdec
           
           mov   ax, per
           inc   ax
           mov   per,ax
           mov   ax,del           
           cmp   per,ax
           jne   exdec
           ;�᫨ ࠢ�� - ᥪ㭤� �����稫���
           mov   per,0
           mov   al,arrb[2]  ;����ᠫ� ᥪ㭤� ��ண� ��ப�
           sub   al,1
           das
           mov   arrb[2],al
           cmp   al,10011001b                ; �᫨ ⥪�饥 ���ﭨ� - 0
           jne   exdec
           mov   arrb[2],01011001b            ; �����뢠�� 59
           mov   al,arrb[1]
           sub   al,1
           das
           mov   arrb[1],al
           cmp   al,10011001b
           jne   exdec
           mov   arrb[1],1011001b
           mov   al,arrb[0]
           sub   al,1
           das   
           mov   arrb[0],al
           and   al,00001111b           
           cmp   al,00001001b
           jne   exdec
           mov   al,00000000b
           mov   arrb[0],al           
           mov   arrb[1],al
           mov   arrb[2],al
           ;mov   hod1,0
           ;mov   hod2,0
           mov   t2,1        ;�ந���� ��ண� ��ப�
           jmp   exdec
           
exdec:     jmp   r1          
           
n1:
           mov   ax, per2
           inc   ax
           mov   per2,ax
           mov   ax,del           
           cmp   ax,per2
           jne   exdec
           ;�᫨ ࠢ�� - ᥪ㭤� �����稫���
           mov   per2,0
           mov   al,arrw[2]  ;����ᠫ� ᥪ㭤� ��ண� ��ப�
           sub   al,1
           das
           mov   arrw[2],al
           cmp   al,10011001b
           jne   exdec
           mov   arrw[2],01011001b
           mov   al,arrw[1]
           sub   al,1
           das
           mov   arrw[1],al
           cmp   al,10011001b
           jne   exdec
           mov   arrw[1],1011001b
           mov   al,arrw[0]
           sub   al,1
           das   
           mov   arrw[0],al
           and   al,00001111b
           cmp   al,00001001b
           jne   exdec
           mov   al,0
           mov   arrw[0],al           
           mov   arrw[1],al
           mov   arrw[2],al
           mov   hod1,0
           mov   hod2,0
           mov   t1,1        ;�ந���� ��ࢮ�� ��ப�
           jmp   exdec           

r1:   
           ret
decr endp           
;-------------------------------------------------------------------------------------------------           
OBRFASTGAME      proc near
;��ࠡ�⪠ �����⮢ ��।���� 室� ����ன ����
           cmp   t1,1        ;�᫨ �ந�ࠫ ���� ��ப
           jne   e1
           mov   hod1,0
           mov   hod2,0
           mov   chc,0
           mov   FFASTGAME,0
           mov   FGONG,0
           mov   t1,0
           mov   t2,0

           mov   al,06h       ;�먣��� ��ண�
           out   0,al
           
           jmp   exobrf
           
e1:        cmp   t2,1
           jne   e22
           mov   hod1,0
           mov   hod2,0
           mov   chc,0
           mov   FFASTGAME,0
           mov   FGONG,0     
           mov   t2,0
           mov   t1,0               
           mov   al,05h
           out   0,al
e22:        
                                         
exobrf:    ret
           OBRFASTGAME      endp
;-------------------------------------------------------------------------------------------------           
obrabotka  proc  near
           cmp   FDEF1,1
           je   let1
           cmp   FDEF2,1
           je    let2
           call  OBRFASTGAME           
           jmp   obrkon                   
           
let1:      
           call  SETUP1
           jmp   obrkon
let2:      
           call  SETUP2
           jmp   obrkon
obrkon:
           ret
           obrabotka endp
   
;-------------------------------------------------------------------------------------------------           
SETUP1   proc    near
ret
endp        
   
;-------------------------------------------------------------------------------------------------              
   

SETUP2   proc    near
ret
endp        
   
;-------------------------------------------------------------------------------------------------              
   
                
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;����� ࠧ��頥��� ��� �ணࠬ��

           call  INITPROC
l1:           
           call  OPROS1  
           call  OPROS0
           call  TODISPLAY  
           call  decr 
           call  obrabotka
           
                 
           jmp   l1
;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
