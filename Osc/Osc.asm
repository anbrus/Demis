;������ ���� ��� � �����
RomSize    EQU   4096

Reg0           EQU   0001h   ;���� ������
Reg1           EQU   0002h   ;����訩 ���� ������ ���
Reg2           EQU   0004h   ;���訩 ���� ������ ���
IndHPort1      EQU   0008h   ;���� ��� ��ਧ��⠫��� ����� ������
IndVPort1      EQU   0010h   ;���� ��� ���⨪����� ����� ������
DispPort1      EQU   0020h   ;���� ��� �롮� ������
IndHPort       EQU   0040h   ;���� ��� ��ਧ��⠫��� ����� ������
IndVPort       EQU   0080h   ;���� ��� ���⨪����� ����� ������
DispPort       EQU   0100h   ;���� ��� �롮� ������
NumMPort3      EQU   0200h
NumMPort2      EQU   0400h
NumMPort1      EQU   0800h
NumMPort       EQU   1000h
IndHPort2      EQU   2000h   ;���� ��� ��ਧ��⠫��� ����� ������
IndVPort2      EQU   4000h   ;���� ��� ���⨪����� ����� ������
DispPort2      EQU   8000h   ;���� ��� �롮� ������

ADCStartPort   EQU   0       ;���� ����᪠ ���

DiscrPlusMask  EQU   1        ;��᪠ ������ + ��ਮ�� ����⨧�樨
DiscrMinusMask EQU   2        ;��᪠ ������ - ��ਮ�� ����⨧�樨
StorePlusMask  EQU   4        ;��᪠ ������ + ��ਮ�� �������
StoreMinusMask EQU   8        ;��᪠ ������ - ��ਮ�� �������
RecMask        EQU   16       ;��᪠ ������ Rec
PlayMask       EQU   32       ;��᪠ ������ Play
KbdCounterMax  EQU   5        ;����প� ��। ����୮� ॠ�樨 �� ������
DelayValue     EQU   2000     ;����প� ��� �࣠����樨 ��ਮ�� ����⨧�樨.
                              ;������ �� ����த���⢨� ��������
RecDelayValue  EQU   30       ;����প� �����.
                              ;������ �� ����த���⢨� ��������

IntTable   SEGMENT AT 0 use16
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Data       SEGMENT AT 40h use16
;����� ࠧ������� ���ᠭ�� ��६�����
OscImage   dw    80 dup (?)
DiscrTime  dw    ?           ;��ਮ� ����⨧�樨 � 2-10 �ଠ� 㬭������ �� 10
StoreTime  dw    ?           ;��ਮ� ������� � 2-10 �ଠ�
KbdCounter dw    ?           ;���稪 ����প� ���� ������
DelayCounter dw  ?           ;���稪 ����প� ����⨧�樨
NewADCVal  db    ?           ;���� ������ ���
OldADCVal  db    ?           ;�।��騩 ������ ���
Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT AT 80h use16
;������ ����室��� ࠧ��� �⥪�
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

RecBuf     SEGMENT AT 100h use16
RecBuf     ENDS

InitData   SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�
InitData   ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

;��ࠧ� ��� �� 0 �� 9
NumImage   db    03fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh

           ASSUME cs:Code,ds:Data,es:Data

;��楤�� �⮡ࠦ��� ⥪�騩 ��ਮ� ����⨧�樨 �� ���������
ShowDiscrTime    proc near
           xor   ah,ah
           mov   al,Byte Ptr StoreTime
           lea   bx,NumImage
           add   bx,ax
           mov   dl,cs:[bx]      ;dl:=��ࠧ ������� ����� ᥪ㭤�
           mov   al,Byte Ptr StoreTime+1
           lea   bx,NumImage
           add   bx,ax
           mov   dh,cs:[bx]      ;dh:=��ࠧ ᥪ㭤
           mov   ax,dx
           or    ah,080h         ;����� ���� ��᫥ 楫�� ᥪ㭤
           mov   dx,NumMPort1
           out   dx,al
           mov   al,ah
           mov   dx,NumMPort
           out   dx,al

           xor   ah,ah
           mov   al,Byte Ptr DiscrTime
           lea   bx,NumImage
           add   bx,ax
           mov   dl,cs:[bx]      ;dl:=��ࠧ ������� ����� ᥪ㭤�
           mov   al,Byte Ptr DiscrTime+1
           lea   bx,NumImage
           add   bx,ax
           mov   dh,cs:[bx]      ;dh:=��ࠧ ᥪ㭤
           mov   ax,dx
           mov   dx,NumMPort2
           out   dx,al
           mov   dx,NumMPort3
           mov   al,ah
           out   dx,al
           
           ret
ShowDiscrTime    endp

;��楤�� �믮���� ��砫��� ���樠������ �ࠧ� ��᫥ ����祭��
Initialize proc  Near
           ;���樠������ ��ࠧ�
           lea   di,OscImage
           mov   cx,LENGTH OscImage
           mov   ax,080h
           rep   stosw
           
           ;���樠������ ��ਮ�� ����⨧�樨
           mov   DiscrTime,0002h
           mov   StoreTime,0001h
           call  ShowDiscrTime
           
           ;���樠�����㥬 ����稪 ���� ������
           mov   KbdCounter,0
           ;����稪 ����প� ����⨧�樨
           mov   DelayCounter,0
           
           mov   NewADCVal,8
           mov   OldADCVal,8
           
           ret
Initialize endp

;�뢮��� ��⮢� ��ࠧ �� ������ ���������
ShowOscImage     proc Near
           lea   si,OscImage     ;�����⥫� �� ⥪�騩 �⮫���
           mov   cx,80           ;����稪 �⮫�����
           mov   bl,1            ;����稪 �⮫����� ����� ����� ������
           mov   dx,1            ;����稪 �����

SOIShowNextCol:
           cmp   dx,0100h
           jnc   SOIDispMatrix3
           
           ;��ᨬ ������
           xor   al,al
           push  dx
           mov   dx,DispPort
           out   dx,al
           mov   dx,DispPort1
           out   dx,al
           pop   dx
           
           ;�뢮��� ⥪�騩 �⮫���
           lodsb
           out   IndHPort,al
           lodsb
           out   IndHPort1,al
  
           ;��⨢��㥬 ���⨪���� �⮫���
           mov   al,bl
           out   IndVPort,al
           out   IndVPort1,al
           
           ;��⨢��㥬 ������
           mov   ax,dx
           push  dx
           mov   dx,DispPort
           out   dx,al
           mov   dx,DispPort1
           out   dx,al
           pop   dx
           
           ;���室�� � ᫥���饬� �⮫����
           mov   al,bl
           shl   al,1
           jnc   SOINoChangeMatrix12
           mov   al,1
           shl   dx,1
SOINoChangeMatrix12:
           mov   bl,al
           
           loop  SOIShowNextCol

SOIDispMatrix3:
           ;��ᨬ ������
           xor   al,al
           push  dx
           mov   dx,DispPort
           out   dx,al
           mov   dx,DispPort1
           out   dx,al
           mov   dx,DispPort2
           out   dx,al
           pop   dx
           
           ;�뢮��� ⥪�騩 �⮫���
           lodsb
           push  dx
           mov   dx,IndHPort2
           out   dx,al
           pop   dx
  
           ;��⨢��㥬 ���⨪���� �⮫���
           mov   al,bl
           push  dx
           mov   dx,IndVPort2
           out   dx,al
           pop   dx
           
           ;��⨢��㥬 ������
           mov   ax,dx
           push  dx
           mov   dx,DispPort2
           mov   al,ah
           out   dx,al
           pop   dx
           
           ;��ᨬ ������
           xor   al,al
           push  dx
           mov   dx,DispPort2
           out   dx,al
           pop   dx

           ;�뢮��� ⥪�騩 �⮫���
           lodsb
           push  dx
           mov   dx,IndHPort2
           out   dx,al
           pop   dx
  
           ;��⨢��㥬 ���⨪���� �⮫���
           mov   al,bl
           push  dx
           mov   dx,IndVPort2
           out   dx,al
           pop   dx
           
           ;��⨢��㥬 ������
           mov   ax,dx
           push  dx
           mov   dx,DispPort2
           mov   al,ah
           shl   al,1
           out   dx,al
           pop   dx

           ;���室�� � ᫥���饬� �⮫����
           mov   al,bl
           shl   al,1
           jnc   SOINoChangeMatrix3
           mov   al,1
           shl   dx,2
SOINoChangeMatrix3:
           mov   bl,al
           
           dec   cx
           jz    SOIExitLoop
           jmp   SOIShowNextCol

SOIExitLoop:
           ;��ᨬ ������
           xor   al,al
           mov   dx,DispPort
           out   dx,al
           mov   dx,DispPort1
           out   dx,al
           mov   dx,DispPort2
           out   dx,al

           ret
ShowOscImage     endp

;������� ⥪�饥 ���祭�� ����殮��� � �����頥� ��� � al
GetADCValue      proc near
           xor   al,al
           out   ADCStartPort,al
           mov   al,1
           out   ADCStartPort,al
           
           mov   al,NewADCVal
           mov   OldADCVal,al
           ;����� ���� �����
           in    al,Reg2
           ;�뤥��� ���訥 ���� �⮡� ������ � ���� ������
           and   al,0Fh
           mov   NewADCVal,al
           
           ret
GetADCValue      endp

;�������� ��ࠧ ��樫���ࠬ�� � ᮮ⢥��⢨� � ���� �����⮬
UpdateOscImage   proc near
           ;���� ��ࠧ ���� ᤢ����� �� ���� �⮫��� ��ࠢ�
           std
           lea   si,OscImage+SIZE OscImage-4
           mov   di,si
           add   di,2
           mov   cx,LENGTH OscImage-1
           rep   movsw
           cld
           
           ;� ����� ���祭�� �������� � ���� �⮫���
           ;��ନ�㥬 ��ࠧ �⮫����
           mov   al,NewADCVal
           cmp   al,OldADCVal
           jz    @NewOld
           jnc   @NewBOld

           ;���� ������ ����� ��ண�
           mov   al,OldADCVal
           sub   al,NewADCVal
           mov   cl,al
           mov   bl,al
           mov   ax,8000h
           xor   ch,ch
@ShLeft:
           stc
           rcr   ax,1
           loop  @ShLeft

           mov   cl,NewADCVal
           shr   ax,cl
           jmp   @ShEnd
           
@NewBOld:
           ;���� ������ >= ����
           mov   al,NewADCVal
           sub   al,OldADCVal
           mov   cl,al
           mov   ax,1
           xor   ch,ch
@ShRight:
           stc
           rcl   ax,1
           loop  @ShRight

           mov   cl,15
           sub   cl,NewADCVal
           shl   ax,cl
           jmp   @ShEnd

@NewOld:
           ;���� ������ = ����
           mov   ax,8000h
           mov   cl,NewADCVal
           shr   ax,cl

@ShEnd:
           mov   [OscImage],ax
           
           ret
UpdateOscImage   endp

;������뢠�� ������⢮ �����⮢ ��� �����/���ந�������� ᨣ����
;�����頥� ������⢮ � dx:cx
;������ ������ ⮫쪮 ��� ����, ����� ��ਮ� ����⨧�樨=20 ���
;��� ��㣨� ���祭�� �㤥� ������뢠�� �� �६� �뢮�� �� ��ᯫ��.
GetSampleCount   proc near
           mov   al,Byte Ptr StoreTime+1
           mov   ah,10
           mul   ah
           add   al,Byte Ptr StoreTime
           adc   ah,0                    ;ax=StoreTime � ����筮� ����
           
           ;mov   bx,5000
           mov   bx,5
           mul   bx
           mov   cx,ax       ;dx:cx=StoreTime/20 - ������⢮ �롮ப ��� �����
           
           ret
GetSampleCount   endp

RecordSignal Proc  near
           call  GetSampleCount
           
           mov   ax,RecBuf
           mov   es,ax
           
           mov   bx,0        ;���饭�� ���� ⥪�饣� ������ � ����
           
RSStartSampling:
           xor   al,al
           out   ADCStartPort,al
           mov   al,1
           out   ADCStartPort,al
           
           in    al,Reg2
           and   al,0Fh
           mov   es:[bx],al
           
           mov   si,RecDelayValue
RSWaitLoop1:
           mov   ax,10000
RSWaitLoop2:
           dec   ax
           jnz   RSWaitLoop2
           dec   si
           jnz   RSWaitLoop1
           
           sub   cx,1
           sbb   dx,0
           jc    RSExitProc
           
           add   bx,1
           jnc   RSStartSampling
           mov   ax,es
           add   ax,4096
           mov   es,ax
           jmp   RSStartSampling

RSExitProc:           
           mov   ax,Data
           mov   es,ax
           ret
RecordSignal endp

PlaySignal Proc  near
           sub   sp,2
           mov   bp,sp

           mov   al,Byte Ptr DiscrTime+1
           mov   ah,10
           mul   ah
           add   al,Byte Ptr DiscrTime
           adc   ah,0
           shr   ax,1
           mov   [bp],ax

           mov   ax,RecBuf
           mov   es,ax
           
           call  GetSampleCount
           mov   bx,0        ;���饭�� ���� ⥪�饣� ������ � ����
           
PSShowNextSample:
           mov   al,NewADCVal
           mov   OldADCVal,al
           
           push  cx
           push  dx
           
           mov   cx,[bp]
           xor   ax,ax
PSIntegrateNextSample:
           add   al,es:[bx]
           adc   ah,0
           dec   cx
           jnz   PSIntegrateNextSample
           
           div   Word Ptr [bp]
           
           mov   NewADCVal,al
           push  es
           push  bx
           mov   ax,Data
           mov   es,ax
           call  UpdateOscImage
           call  ShowOscImage
           pop   bx
           pop   es
           
           pop   dx
           pop   cx
           
           sub   cx,[bp]
           sbb   dx,0
           jc    PSExitProc
           
           add   bx,[bp]
           jnc   PSShowNextSample
           mov   ax,es
           add   ax,4096
           mov   es,ax
           jmp   PSShowNextSample

PSExitProc:           
           mov   ax,Data
           mov   es,ax
           add   sp,2
           ret
PlaySignal endp

;�஢���� ���ﭨ� ������ "+" � "-" � ᮮ⢥�����騬 ��ࠧ�� �������
;��ਮ� ����⨧�樨
CheckKeys  proc  near
           ;������ �஢��塞 ⮫쪮 �१ �����஥ �६� ��᫥
           ;��ࢮ�� ������
           cmp   KbdCounter,0
           jz    KbdReady
           dec   KbdCounter
           jmp   CKExitProc

KbdReady:
           in    al,Reg0
           
           ;� ����� �� ������?
           mov   ah,DiscrPlusMask
           or    ah,DiscrMinusMask
           or    ah,StorePlusMask
           or    ah,StoreMinusMask
           or    ah,RecMask
           or    ah,PlayMask
           and   al,ah
           jnz   CKCheckForDiscrPlus
           jmp   CKExitProc

CKCheckForDiscrPlus:
           ;��ࠡ�⠥� ������ "+" ��ਮ�� ����⨧�樨
           test  al,DiscrPlusMask
           jz    CKCheckForDiscrMinus ;������ ����� ������
           mov   ax,DiscrTime    ;� ����� �� 㢥��稢��� ��ਮ� ����⨧�樨?
           cmp   ax,00200h
           jz    CKInvalidDiscrTime ;����� 㢥��稢��� ��ਮ� ����⨧�樨
           add   al,2
           aaa                   ;��ਮ� � ��� � 2-10 �ଠ�, ���४��㥬
           mov   DiscrTime,ax
           ;������ �����஥ �६� �� ������ ������ �� ॠ���㥬
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;������� ���������
           jmp   CKExitProc

CKCheckForDiscrMinus:
           ;��ࠡ�⠥� ������ "-" ��ਮ�� ����⨧�樨
           test  al,DiscrMinusMask ;������ ����� ������
           jz    CKCheckForStorePlus
           mov   ax,DiscrTime
           cmp   ax,00002h       ;� ����� �� 㬥����� ��ਮ� ����⨧�樨?
           jz    CKInvalidDiscrTime
           sub   al,2
           aas                   ;��ਮ� � ��� � 2-10 �ଠ�, ���४��㥬
           mov   DiscrTime,ax
           ;������ �����஥ �६� �� ������ ������ �� ॠ���㥬
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;������� ���������
           jmp   CKExitProc
           
CKInvalidDiscrTime:
           jmp   CKExitProc

CKCheckForStorePlus:
           ;��ࠡ�⠥� ������ "+" ��ਮ�� �������
           test  al,StorePlusMask
           jz    CKCheckForStoreMinus ;������ ����� ������
           mov   ax,StoreTime    ;� ����� �� 㢥��稢��� ��ਮ� ����⨧�樨?
           cmp   ax,00100h
           jz    CKExitProc       ;����� 㢥��稢��� ��ਮ� ����⨧�樨
           add   al,1
           aaa                   ;��ਮ� � ��� � 2-10 �ଠ�, ���४��㥬
           mov   StoreTime,ax
           ;������ �����஥ �६� �� ������ ������ �� ॠ���㥬
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;������� ���������
           jmp   CKExitProc

CKCheckForStoreMinus:
           ;��ࠡ�⠥� ������ "-" ��ਮ�� �������
           test  al,StoreMinusMask ;������ ����� ������
           jz    CKCheckForRec
           mov   ax,StoreTime
           cmp   ax,00001h       ;� ����� �� 㬥����� ��ਮ� ����⨧�樨?
           jz    CKExitProc
           sub   al,1
           aas                   ;��ਮ� � ��� � 2-10 �ଠ�, ���४��㥬
           mov   StoreTime,ax
           ;������ �����஥ �६� �� ������ ������ �� ॠ���㥬
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;������� ���������
           jmp   CKExitProc

CKCheckForRec:
           ;��ࠡ�⠥� ������ Rec
           test  al,RecMask ;������ ����� ������
           jz    CKCheckForPlay
           call  RecordSignal

           ;������ �����஥ �६� �� ������ ������ �� ॠ���㥬
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;������� ���������
           jmp   CKExitProc

CKCheckForPlay:
           ;��ࠡ�⠥� ������ Play
           test  al,PlayMask ;������ ����� ������
           jz    CKExitProc
           call  PlaySignal
           
           ;������ �����஥ �६� �� ������ ������ �� ॠ���㥬
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;������� ���������
           jmp   CKExitProc

CKExitProc:           
           ret
CheckKeys  endp

;��楤�� �࣠����� ����প� ��� �ନ஢���� ��ਮ�� ����⨧�樨
DelayProc  proc  near
           mov   cx,DelayValue
DelayLoop1:
           mov   ax,100
DelayLoop2:
           dec   ax
           jnz   DelayLoop2
           loop  DelayLoop1

           ret
DelayProc  endp

Discretization proc near
           ;���� DelayCounter<>0 ����� ���祭�� � ��� ���� �� �㤥�
           ;�� ��ࠧ �� ������ �㦭� ���������, ���� ��� �������
           cmp   DelayCounter,0
           jnz   DDiscrEnd

           ;��⠭���� DelayCounter � ᮮ⢥��⢨� � ��ਮ��� ����⨧�樨
           mov   ax,DiscrTime
           or    ah,ah
           jz    DAH0
           add   al,10
           xor   ah,ah
DAH0:
           mov   DelayCounter,ax
           
           call  GetADCValue
           call  UpdateOscImage
           
DDiscrEnd:
           dec   DelayCounter

           ret
Discretization endp

Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;����� ࠧ��頥��� ��� �ணࠬ��

           call  Initialize
           
MainLoop:
           call  ShowOscImage
           call  Discretization
           call  CheckKeys
           call  DelayProc
           
           jmp   MainLoop


;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
