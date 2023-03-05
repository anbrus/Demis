; �������� �����
;���ᠭ�� ����⠭�
Name MainDiaproektor

RomSize    EQU   4096
;������⢮ ������ ���뢠���� �� �c�࠭���� �ॡ���� 
NMax       EQU   50

;���� ��������୮�� ����
KbdPort    EQU   2

;���� ᥬ�ᥣ������ ��������஢
DispPort0  EQU   4
DispPort1  EQU   8
DispPort2  EQU   10h

;���� ���� �������஢ ���ﭨ�
IndPort  EQU   20h

;���� ���� 蠣����� � 祫��筮�� �����⥫�
HardPort   EQU   2h

;��ࢠ� ������
FirstPos   EQU   1

;��᫥���� ������
LastPos    EQU   50

;������ ��મ���
ParkPos    EQU   0


;��⠭����� 䫠�
Set        EQU   0FFh

;������ 䫠�
UnSet      EQU   0

;�������� 䫠� � ��஬
Change     EQU   0FFh

;����� ������
Dec1       EQU   0FFh

;����� ������ ��� ᫮��
Dec1_dw    EQU   0FFFFh

;���� ������
Inc1       EQU   1

;���� ������
Inc10      EQU   10

;����� ������
Dec10      EQU   246

;����⥫� ��饩 �㬬� �� ���᫥��� ��砩��� ����樨
NumberForDivRnd  EQU         53

;���� �訡��

;��� �訡��
NoError                      EQU    0

;����⪠ ������� ०�� ।���஢����
;�� 㦥 ����祭��� ०��� ।���஢����
;��� �� ����祭��� ��⮬���᪮� ०���
EdErrAlreadyModeUse          EQU    1    

;����⪠ ������� ��⮬���᪨� ०�� ��
;����祭��� ०��� ।���஢����(�६��� ��� ����樨)
SetAutoErrEdAlreadyModeUse   EQU    2

;��⠭���� ।�����㥬�� ����樨 ��� ���०�� �� ������祭��� ०��� ।���஢����
SetEdPosErrNoEdMode          EQU   3

;��⠭���� ०��� ��砩���� ���� �� ।��ࢮ���� ��� � ��⮬. ०���
SetRndModeInEdAutoMode       EQU   4

;��������� ����প� �� ᮮ⢥����� �ࠢ���� �����
ErrorSetTimeValueNotPossible EQU    5

;����⪠ ���室� �� ����� ������ � ०��� ।���ࢮ���� ��� ���०���
ErrorNewPosInModeAE          EQU    6

;����ୠ� ����� ������
ErrorPosNotPossible          EQU    7

;������ ��� ������ �����६����
ErrorTwoKeyPressed           EQU    8

;�����஢���� ����� ��᫥����⥫쭮��
;��� � ���०��� �� ࠡ���饬 ���०���
GenerateNewRndInAutoModeUse  EQU    9

;����� ������� ���ﭨ�
ErrorStateFlag   EQU         1    ;�訡��
AutoStateFlag    EQU         2    ;���
RndStateFlag     EQU         4    ;���砩��
EdTimeStateFlag  EQU         8    ;�������.�����.
EdPosStateFlag   EQU         16   ;�������.����樨
AutoIncStateFlag EQU         32    ;��אַ� 室 ���०
AutoDecStateFlag EQU         64    ;����� 室 ���


;����� ��⮢ ����
;������⥫쭮� ���饭�� 蠣����� �����⥫�
SetImpulseIncrement EQU         20h
UnSetImpulseIncrement        EQU    0FFh-20h

;����⥫쭮� ���饭�� 蠣����� �����⥫�
SetImpulseDecrement EQU         40h
UnSetImpulseDecrement        EQU    0FFh-40h

;��⠭����� 祫���(�������� ⥪�騩 ����)
SetShutle  EQU   10h

;������ 祫���(��祣� �� �����뢠��)
UnSetShutle EQU  0

BitOfPoint EQU   128

;���०�� ��� 蠣����� �����⥫�
DelayForStepEngine           EQU    60
;���०�� 0.048c ��� ������� ���� ����� ���ࠬ�
;� ��⮬���᪮� ०���
DelayForPauseCadr            EQU    20000
;� ����� ᥪ㭤� ����থ�
DelayInSec EQU   20

;������⢮ �����ᮢ 蠣����� �����⥫� ���
;��४��祭�� ������ ����
NumberImpulseOnStep          EQU    10

;���� ������
Key0       EQU   0
Key1       EQU   1
Key2       EQU   2
Key3       EQU   3
Key4       EQU   4
Key5       EQU   5
Key6       EQU   6
Key7       EQU   7
Key8       EQU   8
Key9       EQU   9
KeyEnd     EQU   0Ah
KeyBeg     EQU   0Bh
KeyInc1    EQU   0Ch
KeyDec1    EQU   0Dh
KeyInc10   EQU   0Eh
KeyDec10   EQU   0Fh
KeySetPos  EQU   10h
KeyEdPos   EQU   11h
KeySetTime EQU   12h
KeyEdTime  EQU   13h
KeyAutoSS  EQU   14h
KeyInc1A   EQU   15h
KeyDec1A   EQU   16h
KeyRnd     EQU   17h
KeyPark    EQU   18h
KeyPause   EQU   19h
KeyGenRnd  EQU   1Ah
KeyCancel  EQU   1Bh


EmptyKeyboard    EQU         0FFh



; ���ᠭ�� ������
Data Segment at 0BA00H
;����� ����⮩ ������
KeyCode    db    ?
;��� ����� ��⠫� �� ���� ����������
inCode     db    ?
;�室��� ���祭�� ���஥ �᪫��뢠���� �� ������� ࠧ�鸞�
ValueForEx db    ?
;���� ��⮬���᪨� ०��
ModeAuto   db    ?
;���� থ��� ��砩�� ���室 �� ��⮬���᪮� ०��
ModeRnd    db    ?
;���� ०��� ।���ࢮ���� ����樨
ModeEdPos  db    ?
;���� ०��� ।���஢���� ����প�
ModeEdTime db    ?
;���� �訡�� - ᮤ�ন� ��� �訡��
ErrorF     db    ?
;�᫮ �८�ࠧ������� �� �������஢ 
NumberFromDig    db          ? 
;����饥 ᮤ�ঠ��� �������஢
Dig0       db    ?
Dig1       db    ?
Dig2       db    ?
;䫠� ���ﭨ�, �⮡ࠦ����� �� ��������� ���ﭨ�
StateF     db    ?
;�����⥫� ���襣� ࠧ�鸞 �� ������ ����� ����樨 � ����稭� ����প�
MultiplierForGetNumberFromDig    db    ?
;������⢮ ��室�� ��। ᬥ��� ���� � ��⮬���᪮� ०���
MaxCountCycle    dw          ?    
;����    "�ॡ���� �뢥�� ����� ����樨"
NeedShowPosF     db          ?    
;����騩 ����� ����樨 ���⪨
Pos        db    ?
;����� ������ ���⪨
NewPos     db    ?
;����� ������ ���⪨ � ������� 蠣����� �����⥫�
NewPosMul10      db          ?
;������ ������ ���⪨ � ������� 蠣����� �����⥫�
PosMul10   db    ?
;���饭�� 蠣� � ������ ��������� ���⪨(+1,-1)
IncPos     dw    ?
;��� ���� ����� �㤥� ���������� �� �ࠢ����� 蠣��� �����⥫�� ��� 
;��ॢ��� �� ����� ������
SetImpulseForPosition        db    ?
;��᪠ ���� ��� ��� ��� 蠣����� �����⥫�
UnSetImpulseForPosition        db    ?
;������⢮ 横��� � ��楤�� ����প�
DelayCycles      dw          ?
;������� ��室�� ��楤��� ����প�
CycleCount dw    ?
;���� - � ��⮬���᪮� ०��� �� ����� ��������
AllCadrShow      db          ?
;����-���ࠢ����� ������ ���०��� - ��אַ�
AutoIncF   db    ?
;���饭�� �� ���०��� 0- ��אַ� FF-���⭨�
AutoInc    db    ?
;������ ������ � ०��� ���
PosInModeAuto    db          ?
;������ ��⨢��
ChActive   db    ?
;���ᨢ ᮤ�ঠ騩 ��᫥����⥫쭮��� ����� ���஢
;� ��⮬���᪮� ०���
Cadr       db 51 dup(?)
;������騩 ��砩�� ���� �� �����樨 ��᫥����⥫쭮�� ������
NextRnd    dw    ?
;��६���� �࠭�騥 ��᫥���� ���� ��砩��� ����
;�� �� �᭮�� �������� ���� ��砩�� ����
Rnd1       dW    ?
Rnd2       dW    ?
Rnd3       dW    ?
Rnd4       dW    ?
Retry      db    ?


Data EndS

; ���ᠭ�� �⥪�
Stack Segment at 0BA80H 
     dw 100 dup (?)              ; 100 ᫮� (� ����ᮬ)
     StkTop label Word           ; ���設� �⥪�
Stack EndS

; ���ᠭ�� �믮��塞�� ����⢨�
Code Segment
Assume cs:Code,ds:Data,es:Code

           ;��ࠧ� 16-����� ᨬ�����: "0", "1", ... "F"
SymImages  DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh,0,06Fh,079h,033h,07Ch,073h,063h,1,1,1,1,1,1

;�����⮢�� ��६����� � 䫠���
Prepare    PROC  NEAR
;��⠭���� ०����           
           mov   ModeAuto,UnSet
           mov   ModeEdPos,UnSet
           mov   ModeEdTime,UnSet
           mov   ModeRnd,UnSet
           mov   StateF,Set
           mov   ErrorF,NoError
           mov   al,Set
           out   IndPort,al
           mov   NewPos,ParkPos
           mov   Pos,ParkPos
           mov   NeedShowPosF,Set
           mov   MaxCountCycle,2
           mov   AutoIncF,Set
           mov   AutoInc,Inc1
           mov   AllCadrShow,UnSet
           mov   Rnd1,1
           mov   Rnd2,0
           mov   Rnd3,0
           mov   Rnd4,0
           mov   MaxCountCycle,20
           mov   ChActive,UnSet
           ret
Prepare    ENDP           

;--------------------------  VIBRDESTR--------------
;O�ࠡ�⪠ �ॡ���� ���⠪⮢ ����������
VibrDestr  PROC  NEAR
VD1:       
           in    al,KbdPort
           mov   ah,al
           mov   bh,0        ;���� ����稪� ����७��
VD2:       in    al,KbdPort  ;���� ⥪�饣� ���ﭨ�
           cmp   ah,al       ;����饥 ���ﭨ�=��室����?
           jne   VD1         ;���室, �᫨ ���
           inc   bh          ;���६��� ����稪� ����७��
           cmp   bh,NMax     ;����� �ॡ����?
           jne   VD2         ;���室, �᫨ ���
           mov   al,ah       ;����⠭������� ���⮯�������� ������
           ret
VibrDestr  ENDP

;===================         GetDigFromNumber==========
GetDigFromNumber   PROC  NEAR
;�८�ࠧ������ �室���� ���祭�� ValueForEx �� ������� ࠧ�鸞�
;� Dig2,Dig1,Dig0
;�뫮 234 �⠭�� 2,3,4
           mov   ah,0
           mov   al,ValueForEx
           mov   dx,0
           mov   cx,0Ah
           div   cx
           mov   Dig0,dl
           mov   dx,0
           div   cx
           mov   Dig1,dl
           mov   dx,0
           div   cx
           mov   Dig2,dl
           ret
GetDigFromNumber   ENDP           

;++++++++++++++++++++++++++  ConvertShow  ++++++
;�८�ࠧ������ Dig2,Dig1,Dig0
;� c���ᥣ����� ��� � �뢮� �� c���ᥣ����� ��������� � �����
ConvertShow   PROC  NEAR
           lea   bx,SymImages
           mov   cl,Dig0
           mov   ch,0
           add   bx,cx
           mov   al,es:[bx]
           Out   DispPort0,al

           lea   bx,SymImages
           mov   cl,Dig1
           mov   ch,0
           add   bx,cx
           mov   al,es:[bx]
           Out   DispPort1,al
           
           lea   bx,SymImages
           mov   cl,Dig2
           mov   ch,0
           add   bx,cx
           mov   al,es:[bx]
           and   ModeEdTime,Set
           jz    NoModeEdTimeNow1
           or    al,BitOfPoint
NoModeEdTimeNow1:
           Out   DispPort2,al
           ret
ConvertShow   ENDP


;___________________         ConvertDigEmptyToZero________________
;�८�ࠧ������ ������ �������஢ Dig0,1,2 � �㫨 DIG
;�ᯮ������ ��� �८�ࠧ������ ����襭��� �������஢ � 0.
;�᫨ �������� ����襭, ��⠥� ��� �㫥�
ConvertDigEmptyToZero       PROC NEAR
;��ன ࠧ��
           mov   bl,Dig2
           xor   bl,0Ah      ;�஢�ઠ �� ����襭� ��������(��⠥� ��� �㫥�)
           jnz   ItsnZeroOk22
           mov   Dig2,0
ItsnZeroOk22:
;���� ࠧ��
           mov   bl,Dig1
           xor   bl,0Ah      ;�஢�ઠ �� ����襭� ��������(��⠥� ��� �㫥�)
           jnz   ItsnZeroOk12
           mov   Dig1,0
ItsnZeroOk12:
;�㫥��� ࠧ��
           mov   bl,Dig0
           xor   bl,0Ah      ;�஢�ઠ �� ����襭� ��������(��⠥� ��� �㫥�)
           jnz   ItsnZeroOk02
           mov   Dig0,0
ItsnZeroOk02:
           ret
ConvertDigEmptyToZero       ENDP           


;@@@@@@@@@@@@@@@@@@@@@@@@@@  GetNumberFromDig   @@@@@@@@@@@@@@@@
;�८�ࠧ������ �� ���ࠧ�來��� ���� � �᫮
;Dig2,1,0 -> NumberFromDig
GetNumberFromDig PROC NEAR
           call  ConvertDigEmptyToZero
           mov   al,Dig2
           mov   bh,MultiplierForGetNumberFromDig
           mul   bh
           mov   cl,al
           mov   al,Dig1
           mov   bh,10
           mul   bh
           add   cl,al
           add   cl,Dig0
           mov   NumberFromDig,cl
           ret
GetNumberFromDig ENDP

;^^^^^^^^^^^^^^^^^^^^^^^^^^  KeyRead  ^^^^^^^^^^^^^^^^^^^^^^
;��ࠡ�⪠ ����������
KeyRead    PROC NEAR
           mov   bx,dec1      ;�� -1, �㦭� ��� ⮣� �⮡� ��� ������ ��稭���� � 0
Go1:       mov   KeyCode,EmptyKeyboard    ;�᫨ ����� �� ����� � �������� ���
           mov   cl,1        ;�� ���뫠�� � ���� �����
Next:      mov   al,cl           
           and   ChActive,Set
           jz    Pos0
           or    al,SetShutle
Pos0:           
           out   KbdPort,al
           in    al,KbdPort
           and   al,0FFh
           jz    NoON        ;���室 ����� �᫨ �� �뫮 ������ � �⮩ ��ப�
           jp    TwoKeyPresedNow ;� ������ ��ப� ����� ��� ������
           cmp   KeyCode,EmptyKeyboard
           je    No2KeyPressed    ;� ��㣨� ��ப�� ����� �� ���� ������
           jmp   TwoKeyPresedNow    ;���室, �뫮 ����� 2 ������
No2KeyPressed:
           mov   InCode,al   ;c��࠭塞 ���祭�� ��⠭��� �� ����
           call  VibrDestr   ;��ࠡ�⪠ �ॡ���� ���⠪⮢
Read_0:    in    al,KbdPort 
           and   al,0FFh
           jnz   Read_0      ;���� �� �� ��� ���� �� ������� �������
           call  VibrDestr   ;��ࠡ�⪠ �ॡ����
;������ ���浪��� ����� ���           
           mov   ax,1111111011111111b
           push  bx
           mov   bl,0
ShlNext:
           inc   bl
           and   InCode,ah
           jz    BitFound
           shl   ax,1
           jc    ShlNext
           jmp   BitNotFound
BitFound:           
           mov   inCode,bl
           pop   bx
BitNotFound:
Not4:      add   bl,InCode       ;cl = ����� ����⮩ ������
           mov   KeyCode,bl  ;C��࠭���;
           jmp   NoON
TwoKeyPresedNow:
           mov   KeyCode,EmptyKeyBoard;
           mov   ErrorF,ErrorTwoKeyPressed
           jmp   EndKeyRead           
NoON:      
           add   bx,7
           shl   cl,1
           and   cl,1111b
           jnz   Next
EndKeyRead:
           ret
KeyRead    ENDP

;=========================   GetNextRnd =================== 
GetNextRnd PROC  NEAR
           push  ax
           push  bx
GetNextRndAgain:
           mov   ax,Rnd1
           add   ax,Rnd2
           add   ax,Rnd3
           add   ax,Rnd4
           mov   bh,NumberForDivRnd
           div   bh
           shr   ax,8
           mov   NextRnd,ax
           
           mov   ax,Rnd2
           mov   Rnd1,ax
                      
           mov   ax,Rnd3
           mov   Rnd2,ax
                      
           mov   ax,Rnd4
           mov   Rnd3,ax
                      
           mov   ax,NextRnd
           mov   Rnd4,ax

           cmp   al,LastPos
           jnb   GetNextRndAgain
           inc   NextRnd
           pop   bx
           pop   ax
           ret
GetNextRnd ENDP


;!!!!!!!!!!!!!!!!!!!!!!!!!   InitRnd   !!!!!!!!!!!!!!!!!!!
;���樠������ ०��� ��砩���� ���室�
;� �뢠�饬 ���浪� ���� ������� ����� ��� �祥�
InitRnd1    PROC  NEAR
           mov   si,LastPos
SetNextCadr1:
           mov   Cadr[si],Unset
           dec   si
           jnz   SetNextCadr1

           mov   bh,0
           mov   bl,LastPos
GetNext1:
           call  GetNextRnd
           mov   si,LastPos+1
NextCheck:
           dec   si
           mov   ax,NextRnd
           cmp   al,Cadr[si]
           je    GetNext1
           cmp   si,bx
           jne   NextCheck
           mov   ax,NextRnd
           mov   Cadr[bx],al
           dec   bl
           jnz   GetNext1
           ret
InitRnd1    ENDP


;####################################################################
;���樠������ ०��� ��⮬���᪮�� ������
InitAuto   PROC  NEAR
           mov   CycleCount,0
           mov   AllCadrShow,UnSet
           mov   PosInModeAuto,1           
           ret
InitAuto   ENDP           

;-------------------         SetNewPos  -----------------------------------
;����祭�� ����� ᫥���饣� ���� � ��⮬���᪮� ०���
SetNewPos  PROC  NEAR
           cmp   ModeRnd,Set
           je    ItsModeRndNow
;�� ��砩�� ०��
           mov   bl,NewPos
           add   bl,AutoInc
           cmp   bl,LastPos
           jnbe  AllCadrIsShow
           mov   NewPos,bl
           jmp   EndSetNewPos
;���砩�� ०��
ItsModeRndNow:
           mov   bl,PosInModeAuto
           add   bl,AutoInc
           cmp   bl,LastPos
           jnbe  AllCadrIsShow
           mov   bh,0
           mov   al,Cadr[bx]
           mov   NewPos,al
           mov   PosInModeAuto,bl
           jmp   EndSetNewPos
AllCadrIsShow:
           mov   AllCadrShow,Set
EndSetNewPos:
           ret
SetNewPos  ENDP

;=========================   AutoProcessing  =========================
;��ॢ�� ������ �� ����� ������ �᫨ ����祭 ०�� ���
;� ����諮 �६� ᬥ�� ����
AutoProcessing   PROC        NEAR
;�஢�ઠ ०���
           mov   al,ModeAuto
           and   al,Set
           jz    NoModeAuto
;०�� ��⠭�����
;��⠭���� �६��� ����প� ��� ��楤��� ����প�
;           mov   ErrorF,UnSet
           mov   DelayCycles,DelayForPauseCadr
;�맮� ����প�
           call  Delay
;�����稬 ���稪 �맮��� ����ணࠬ�� ����প�           
           inc   CycleCount
           mov   ax,CycleCount
           cmp   ax,MaxCountCycle
;�ࠢ������ ��襤�� �᫮ ����থ� � �㦭� ������⢮�
           jb    WaitTimeForNewCadr
;�६� ����諮 ���뢠�� ���稪 �맮��� ����প�
           mov   CycleCount,UnSet
;����砥� ����� ������ � NewPos
           call  SetNewPos
;�� ����� ��������?
           and   AllCadrShow,Set
           jz    NoAllCadrShowNow
;�� ����� ��������, ��� ०��� ���           
           mov   ModeAuto,UnSet
NoAllCadrShowNow:
SetNewCadr:           
WaitTimeForNewCadr:           
NoModeAuto:
           ret
AutoProcessing   ENDP


;__________________  DELAY  ______________________________
;��楤�� ����প�
;���⮩ 横� �ࠡ��뢠�� DelayCycles ࠧ
Delay      PROC  NEAR
           push   ax
           mov   ax,DelayCycles
NextDelay:
           dec   ax
           jnz   NextDelay
           pop  ax
           ret
Delay      ENDP

;++++++++++++++++++++++        SetPosition     ++++++++++++++++
;���室 � ����� ����樨, �᫨ ⠪�� ����
SetPosition      PROC        NEAR
           mov   al,NewPos
           cmp   al,Pos
;�஢�ઠ �㦭� �� ����� ��ॢ����� 
           jz    NoMove
;����� ������ ����� ��ன?
           jb    NewLowerPos
;���
;�㤥� �ਡ������ �� �� ���⨣���� ����� ����樨
           mov   IncPos,Inc1
;������� �� ���ᮢ�� �室 蠣����� ��.
           mov   SetImpulseForPosition,SetImpulseIncrement
           jmp   IncOk
NewLowerPos:;����
;�㤥� 㡠����� �� �� ���⨣���� ����� ����樨
           mov   IncPos,Dec1_dw
;������� �� ����ᮢ�� �室 �����⥫�
           mov   SetImpulseForPosition,SetImpulseDecrement
IncOk:
;�஢�ઠ ����� ����樨 �� �ࠢ��쭮���
           cmp   al,LastPos
           jnbe  PosMore50
;����� ������ ���४⭠, ��������� �㤠 �� ���� ����
           mov   bx,IncPos
           add   Pos,bl
           mov   cl,NumberImpulseOnStep
;��⠭���� ����প� ��� ��楤��� ����প�           
           mov   DelayCycles,DelayForStepEngine
;�⪫�砥� 祫���, �� �� ����� �뫮 ������� ������           
           mov   al,UnSetShutle
           out   HardPort,al
           mov   ChActive,UnSet
BeforeNoZeroInCL:
           call  Delay
           mov   al,SetImpulseForPosition
           out   HardPort,al
           call  Delay
           mov   al,UnSet
           out   HardPort,al
           dec   cl
           jnz   BeforeNoZeroInCL
           mov   NeedShowPosF,0FFh
           jmp   EndSetPos
PosMore50:
           mov   ErrorF,ErrorPosNotPossible           ;123123
           mov   al,Pos
           mov   NewPos,al
           jmp   EndSetPos
NoMove:           
           and   Pos,0FFh
           jz    ZeroPosNow
           mov   al,SetShutle
           out   HardPort,al
           mov   ChActive,Set
ZeroPosNow:
EndSetPos:
           ret           
SetPosition      ENDP


;^^^^^^^^^^^^^^^^^^^^^^^^  DisplayP   ^^^^^^^^^^^^^^^^^^^^^^
;�⢥砥� �� �뢮����� �� �࠭
DisplayP   PROC NEAR
;�஢�ઠ �� ��� �訡��
           and   ErrorF,Set
           jz    NoErrF
;�८�ࠧ������ ���� �訡�� � ���ࠧ�來�
           mov   al,ErrorF
           mov   ValueForEx,al
           call  GetDigFromNumber
           jmp   NoErrF 
NoErrF:    
;�஢�ઠ 䫠�� ������ �뢮� ⥪�饩 ����樨 � 
;�뢮� ���饩 ����樨 �� ���������, �᫨ ����
           mov   al,NeedShowPosF
           and   al,0FFh
           jz    NoNeedShowPos    ;�� �ॡ����
           mov   al,Pos
           mov   ValueForEx,al
           mov   NeedShowPosF,0
           call  GetDigFromNumber
NoNeedShowPos:
;�८�ࠧ������ ⥪�饣� ���ᥣ���⭮������ � �뢮� �� ���������
           call  ConvertShow
;�뢮� �� ᥬ�ᥣ����� ���������
;�뢮� �� ��������� ���ﭨ�
           mov   al,ErrorF
           and   al,Set
           jz    NoErrorFSet
           mov   al,ErrorStateFlag
           jmp   SetOk
NoErrorFSet:
           mov   al,Unset
SetOk:
           mov   bl,AutoStateFlag
           and   bl,ModeAuto
           or    al,bl
           
           mov   bl,RndStateFlag
           and   bl,ModeRnd
           or    al,bl
           
           mov   bl,EdTimeStateFlag
           and   bl,ModeEdTime
           or    al,bl
           
           mov   bl,EdPosStateFlag
           and   bl,ModeEdPos
           or    al,bl
           
           mov   bl,AutoIncStateFlag
           and    bl,AutoIncF
           or    al,bl
           
           mov   bl,AutoDecStateFlag
           xor   AutoIncF,Set
           and   bl,AutoIncF
           xor   AutoIncF,Set
           or    al,bl
           
           mov   StateF,al
           out   IndPort,al           
           ret                      
DisplayP   ENDP

include    11.asm
;-----------------------------------------------------------------
;-----------------------------------------------------------------
Begin:     mov ax,Data             ; ���樠������
           mov ds,ax               ; ᥣ������
           mov ax,Code
           mov es,ax               ; ॣ���஢ �
           mov ax,Stack
           mov ss,ax
           mov sp,offset StkTop    ; 㪠��⥫� �⥪�

           call  Prepare
           
Cycle:
           call  GetNextRnd
;��ࠡ�⪠ ����������
           call  KeyRead     ;���� � ���������� � ����஫�� �����
           call  HandCOntrol ;��筮� �ࠢ����� ����⮩
           call  SetMode     ;��筠� ��⠭���� ०����
           call  SetTime     ;��⠭����� ����প� � �������஢
           call  EnterTime   ;���� ����প� 
           call  EnterPos    ;���� ����樨
           call  SetPos      ;��⠭����� ������ �� ����� ������
           call  GenRnd      ;�����஢��� ����� ��᫥����⥫쭮��� ���஢ ��� ���०���
           call  AutoProcessing ;��⠭���� ����� ����樨 �᫨ �ॡ���� � ���०���
           call  SetPosition ;��⠭���� �� ����� ������
           call  DisplayP    ;�뢮� �� ���������
           jmp Cycle




         assume cs:nothing
         org 0FF0h               ; ������� ���⮢��
   Start:jmp Far Ptr Begin       ; �窨, �ࠢ�����
                                 ; ��।����� ��
                                 ; ������� jump
Code EndS

End Start