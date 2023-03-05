.386
;������ ���� ��� � �����
RomSize    EQU   4096

IntTable   SEGMENT AT 0 use16
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

sDriverParam     Struc
           wSpeed            dw     ?    ; ������� �����⥫� (����প�)
           wWork             dw     ?    ; �६� ࠡ��� 
           wPause            dw     ?    ; � ����
           bfTypeDir         db     ?    ; ��� ��饭�� (� ��� = 00h ��� � ���� = FFh ��஭�)
sDriverParam     EndS

Data       SEGMENT AT 40h use16
;����� ࠧ������� ���ᠭ�� ��६�����
         ; ������� ����� (���� � ��४���⥫��):
           bfTime            db     ?    ; ������ "�����"
           bfTemp            db     ?    ; ������ "����-��"
           bfSpin            db     ?    ; ������ "�����"
           bfMode            db     ?    ; ������ "�����"  
           bfIncTime         db     ?    ; ������ "+"
           bfDecTime         db     ?    ; ������ "-"
           bfStart           db     ?    ; ������ "����"
           bfWork            db     ?    ;     
           bfWorkHeater      db     ?
           bfUnBalance       db     ?
           bfDoorLock        db     ?  
           bfDoorBlocking    db     ?  
           bfAmountLinen     db     ?    ; ����㧪� �����
           bfDirection       db     ?    ; ���ࠢ����� ��饭��           
           bfMoveDrv         db     ?    ; ���� ࠡ��� �����⥫�          
           bfPauseDrv        db     ?    ; ���� ���� �����⥫�
           bfShow            db     ?
           bfConvert         db     ?
                      
         ; ����� ��. ����-�:  
           bfOutDevice       db 5 dup(?) ;  
                                         ; 0 - ��
                                         ; 1 - ��. ��
                                         ; 2 - ���
                                         ; 3 - ����
                                         ; 4 - �����஢��
           bStep             db ?        ; ����� 蠣�:                                  
                                         ;     0 - �⮯
                                         ;   1,5 - �����
                                         ;     2 - ���ॢ
                                         ;     3 - ��ઠ
                                         ;   4,7 - ����
                                         ;     5 - ����᪠���
                                         ;     8 - ������஢��
                                         ;     9 - �⦨�                      
         ; ����� �訡��:  
           bError            db     ?    ; 00 - ��� �訡��
                                         ; 01 - �訡�� "�1"                                            
                                         ; 02 - �訡�� "�2"
                                         ; 03 - �訡�� "�3"
                                         ; 04 - �訡�� "�4"
                                         ; 05 - �訡�� "�5"    
                      
           bWaterLevel       db     ?    ; �஢��� ����
           bWaterTemp        db     ?    ; ����-� ����                     
           
           bParam            db 6 dup(?) ; ��ࠬ���� ��ન + �㦥���� ���.
           bTimeWash         db     ?
           bTimeSpin         db     ?           

           Drive       sDriverParam ?    ; ��ࠬ���� ࠡ��� �����⥫�
                                         ; ��� ����ᮢ:
                                         ;  "�����"
                                         ;  "������"        
                                         ;  "������"
                                         ;  "����"
                                         ;  "������."
           DriveTmp    sDriverParam ?
           
           bTemp             db     ?    ; ��६����� ��� �࠭���� ���祭�� ⥬�-��
           bfTmp             db     ?    ; �ᯮ���. ��६����� ��� TstHeater
           bValuePort3       db     ?
           bDriver           db     ?           
           bOld              db     ?
           bSpeed            db     ?
           bCounterUB        db     ?    ; 
           
           wTimeDelayInd     dw     ?    ; ����প� ��� ������樨
           wWSMinute         dw     ?    ; 
           wTimeTstFill      dw     ?    ; ����஫쭮� �६� ������
           wTimeTstPulm      dw     ?    ; ����஫쭮� �६� ᫨��
           wTimeTstHeated    dw     ?    ; ����஫쭮� �६� ���ॢ�
           wTimeSekDrv       dw     ?
           wTimeRing         dw     ?    ; �६� ����᪠��� (䨪�.)
           wTimeDefB         dw     ?    ; �६� ��।������ ��ᡠ����           
           wTimeBalanced     dw     ?
           wTimeErr1         dw     ?    ; �६� ॠ�樨 �� �訡�� �1
           wTimeErr2         dw     ?    ; �६� ॠ�樨 �� �訡�� �2
           wTimeErr4         dw     ?    ; �६� ॠ�樨 �� �訡�� �4
           wTimeErr5         dw     ?    ; �६� ॠ�樨 �� �訡�� �5
           wTimeDelBlink     dw     ?
           
           Map               db  10 dup(?)       
Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT AT 50h use16
;������ ����室��� ࠧ��� �⥪�
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�
           eDrv              EQU      0
           eFill             EQU      1
           eHeat             EQU      2    
           ePulm             EQU      3
           eBlock            EQU      4
           
           pMODE_IN          EQU      0
           pGAUGE_IN         EQU      1
           pTEMP_IN          EQU      2
           pWLEVEL_IN        EQU      3
           pREADY_IN         EQU      4                
           p2IND_OUT1        EQU      2
           p3IND_OUT2        EQU      3
           p7IND_OUT1        EQU      0
           p7IND_OUT2        EQU      1    
           pADC_OUT          EQU      4 
           pDRIVER_OUT       EQU      7     
           
           NMAX              EQU      1
           
           MAX_NUM_TIME      EQU      2
           MAX_NUM_TEMP      EQU      4
           MAX_NUM_SPIN      EQU      4
           MAX_NUM_MODE      EQU      2   
           TWASHst           EQU     10  
           TSPINst           EQU      5                        
           LEVEL_RING        EQU      0C0h
           LEVEL_HEAT        EQU      0Dh
           
           ONE_SEK           EQU      20        
           TWSMIN            EQU      ONE_SEK*60*1
           TTSTHP            EQU      ONE_SEK*60*3
           TTSTF             EQU      ONE_SEK*60*2
           TDEFB             EQU      ONE_SEK*60*4
           TIME_B            EQU      ONE_SEK*60*1
           TPB5              EQU      ONE_SEK*60*1 
           TDELIND           EQU      ONE_SEK*2
           TDELBL            EQU      ONE_SEK*10
           
           MAX_ERR_UB        EQU      3  
           ERR_HEAT          EQU      3
                            
           MAX_TIME          db   40, 10
           TEMP_DEF          db   4Ch, 65h, 99h, 0E6h    ;30, 40, 60, 90
           SPIN_DEF          dw    0, 8, 4, 2
           MODE_DEF          db    1,  2
           BEGIN_BIT         db   0, 2, 6, 10           
                             ;     ��    �    �    �   C�    �    �   ��    �    �
           Program           db    00h, 01h, 01h, 02h, 00h, 01h, 03h, 00h, 04h, 05h ; ��
                             db    00h,0FFh,0FFh,0FFh, 00h,0FFh,0FFh, 00h, 00h, 00h ; ��. ��
                             db    00h, 00h,0FFh,0FFh, 00h, 00h, 00h, 00h, 00h, 00h ; ���
                             db    00h, 00h, 00h, 00h,0FFh, 00h, 00h,0FFh,0FFh,0FFh ; ����
                             db    00h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh ; ��
  
                                      ;      �����,������                   ������          ������.      ������. 
           DriveParam    sDriverParam  5 dup(<10,600,200,0>,<10,600,200,0>,<8,600,200,0>,<10,600,300,0>,<8,100,200,0>); ����.
                         sDriverParam  5 dup(<15,600,200,0>,<15,600,200,0>,<12,600,200,0>,<15,600,300,0>,<8,100,200,0>)  ; �����.
           Water             db    81h, 0A5h;3Dh, 078h
                             db    0C4h, 0E0h;0B4h, 0EAh                            
InitData   ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

           ASSUME cs:Code,ds:Data,es:InitData

MainInit   Proc
           mov bParam[0], 0          ; 
           mov bParam[1], 0          ; ����-�
           mov bParam[2], 0          ; �⦨�
           mov bParam[3], 0          ; �����
           mov bParam[4], TWASHst    ; �६� ��ન
           mov bParam[5], TSPINst    ; �६� �⦨��
           
           mov bDriver, 1
           mov bError, 00
           
           mov Map[0],3Fh    ; ��ࠧ� ���
           mov Map[1],0Ch    ; �� 0 �� 9
           mov Map[2],76h
           mov Map[3],05Eh
           mov Map[4],4Dh
           mov Map[5],5Bh
           mov Map[6],7Bh
           mov Map[7],0Eh
           mov Map[8],7Fh
           mov Map[9],5Fh 
           mov Map[10],73h   ; �㪢� "�"   
           
           call Init                              
           ret
MainInit   EndP

Init       Proc 
           mov ax, word ptr bParam[4]
           mov bTimeWash, al
           mov bTimeSpin, ah
                    
           mov Drive.wSpeed, 0
           mov Drive.wWork, 0
           mov Drive.wPause, 0
           mov Drive.bfTypeDir, 0       
           mov bfDirection, 00                               
           
           mov bfWork, 00h  
           mov bfWorkHeater, 0FFh
           mov bfConvert, 0FFh
           mov bfDoorBlocking, 00h            ; ����� ࠧ�����஢���
           mov bfTmp, 00
           mov bfShow, 0FFh
                      
           mov wTimeDelayInd, TDELIND
           mov wWSMinute, TWSMIN      
           mov wTimeTstFill, TTSTF     
           mov wTimeTstPulm, TTSTHP  
           mov wTimeTstHeated, TTSTHP
           mov wTimeDefB, TDEFB
           mov wTimeRing, ONE_SEK*150        ; 15s
           mov wTimeBalanced, TIME_B
           mov wTimeErr1, ONE_SEK*60*5
           mov wTimeErr2, ONE_SEK*60*5
           mov wTimeErr4, ONE_SEK*60*5
           mov wTimeErr5, ONE_SEK*60*5
           mov wTimeDelBlink, TDELBL
            
           mov bOld, 0
           mov bStep, 0
           mov bCounterUB, 0

           push es           
           mov ax, Data
           mov es, ax 
           cld
           lea di, bfOutDevice
           mov cx, length bfOutDevice
           mov al, 0
 rep       stosb
           pop es           
                       
           ret
Init       EndP

InputInf   Proc
           mov bfTime, 00h
           mov bfTemp, 00h
           mov bfSpin, 00h
           mov bfMode, 00h
           mov bfIncTime, 00h
           mov bfDecTime, 00h
           mov bfStart, 00h
 L_IN:           
           in al, pMODE_IN    ;           
           mov dx, pMODE_IN   ;
          ; call VibrDestr        ;           
           test al, 01h          ;"�����"?
           jz L_MI1              ;
           mov bfTime, 0FFh           
L_MI1:           
           test al, 02h          ;"����-��"?
           jz L_MI2              ;
           mov bfTemp, 0FFh
L_MI2:           
           test al, 04h          ;������ "�����" �����?
           jz L_MI3
           mov bfSpin, 0FFh
L_MI3:           
           test al, 08h          ;������ "�����" �����?
           jz L_MI4
           mov bfMode, 0FFh           
L_MI4:
           test al, 10h          ;������ "-" �����?
           jz L_MI5
           mov bfDecTime, 0FFh     
L_MI5:           
           test al, 20h          ;������ "+" �����?
           jz L_MI6
           mov bfIncTime, 0FFh                      
L_MI6:        
           mov ah, bOld
           mov bOld ,al   
           xor al, ah
           and al ,ah
           test al, 40h          ;"����" ?
           jz L_MI7              ;
           mov bfStart, 0FFh
           ;mov bfWork, 0FFh 
L_MI7:
           ret             
InputInf   EndP

VibrDestr  Proc
 L_VD1:
           mov ah, al
           mov bh, 00h
 L_VD2:           
           in al, dx
           cmp ah, al
           jne L_VD1
           inc bh
           cmp bh, NMAX
           jne L_VD2
           mov al, ah
           ret
VibrDestr  EndP



OutDispParam Proc
           mov si, 0
           mov dx, 0
           mov cx, length bParam - 2
 L_ODI:        
           push cx   
           xor ch, ch
           mov cl, bParam[si]
           add cl, es:BEGIN_BIT[si]
           mov ax, 1
           shl ax, cl
           or dx, ax           
           inc si
           pop cx
           loop L_ODI           
           mov ax, dx
           out p2IND_OUT1, al
           mov al, ah
           mov bValuePort3, al
           out p3IND_OUT2, al           
           ret
OutDispParam EndP

OutDispTime Proc
           cmp bError, 0
           jne L_ODTend
           mov ax, word ptr bParam[4]
           push ax
           mov al, bTimeWash
           mov ah, bTimeSpin
           mov word ptr bParam[4], ax           
           mov di, 0
           mov si, length bParam - 2
           lea bx, Map
           cmp bParam[0], 0              ; �⮡ࠦ��� �६� ��ન?
           je L_FDtwash                  ; ���室, �᫨ ��
           inc si                        ; �ய����� �६� ��ન
 L_FDtwash:
           xor ah, ah
           mov al, bParam[si]
           mov dl, 10
           div dl
           xchg ah, al
           ;mov Disp[di], ax
           xlat           
           out p7IND_OUT1, al
           xchg ah, al
           xlat
           out p7IND_OUT2, al 
           pop ax
           mov word ptr bParam[4], ax           
 L_ODTend:           
           ret
OutDispTime EndP

OutDispError Proc
           cmp bError, 0
           je L_ODEend
           cmp bStep, 0
           je L_ODEshow           
           lea bx, wTimeDelBlink
           mov cx, TDELBL
           call Pause
           jnz L_ODEshow
           not bfShow
 L_ODEshow:           
           mov al, Map[10]
           and al, bfShow
           out p7IND_OUT2, al
           lea bx, Map           
           mov al, bError         
           xlat
           and al, bfShow
           out p7IND_OUT1, al           
 L_ODEend:           
           ret
OutDispError EndP

OutDispCond  Proc
           mov si, 0
           mov al, 0           
           cmp bfOutDevice[si], 00
           jne L_ODCnxt
           out pDRIVER_OUT, al
 L_ODCnxt:           
           mov al, 0
           mov dx, p3IND_OUT2
           mov si, 1           
           mov cx, length bfOutDevice - 1
 L_ODCnext:           
           cmp bfOutDevice[si], 0FFh
           jne L_ODCloop
           mov ah, 10h
           push cx
           mov cx, si
           dec cl
           shl ah, cl
           or al, ah           
           pop cx
 L_ODCloop:           
           inc si
           loop L_ODCnext
           and al, 0F0h
           or al, bValuePort3
           out p3IND_OUT2, al 
           mov al, 0         
           mov ah, bStep
           cmp ah, 3
           jne $+4
           mov al, 1           
           cmp ah, 6
           jne $+4
           mov al, 2           
           cmp ah, 8
           jne $+4
           mov al, 4           
           cmp ah, 9
           jne $+4
           mov al, 8   
           out 4, al 
 L_ODCend:                       
           ret
OutDispCond  EndP

Pause      Proc
           cmp word ptr [bx], 0
           je L_Pzero
           dec word ptr [bx]
           jnz L_Pend
 L_Pzero:           
           mov [bx], cx
 L_Pend:            
           ret
Pause      EndP



include InParam.asm
include InGauge.asm
include Control.asm
include Washing.asm
include Driver.asm
                      
Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,InitData
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;����� ࠧ��頥��� ��� �ணࠬ��

           call MainInit
L_NEXT:           
           call InputInf
           call InParam        
           call InADC
           call InBinaryGauge      ; ���� � ������� ���稪�� (������)           
           call TstSysFill 
           call TstSysPulm    
           call TstHeater 
           call TstLock
           call TstBalance
           call Reaction     
           call Wash
           call OutDispParam
           call OutDispTime
           call OutDispError
           call OutDispCond
           jmp L_NEXT           
;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
