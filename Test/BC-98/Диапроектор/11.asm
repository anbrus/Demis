Name KeyAnalize

;���� ����� ���� � ����訩 ࠧ�� � ०��� ����� �६���   
;� �஫�஢���� �� ������ �������஢� � ���訥 
EnterTime  PROC NEAR
           cmp   KeyCode,10
           jnb   EnterValueToDigQuit
           and   ModeEdTime,Set
           jz    EnterValueToDigQuit
           mov   bl,Dig1
           mov   Dig2,bl
           mov   bl,Dig0
           mov   Dig1,bl
           mov   al,KeyCode
           mov   Dig0,al
           mov   ErrorF,NoError    ;����뢠�� 䫠� �訡��
EnterValueToDigQuit:
           ret           
EnterTime  ENDP

;���� ����� ���� � ����訩 ࠧ�� � ०��� ����� ����樨
;� �஫�஢���� �� ����襣� �������� � ���訩
EnterPos   PROC  NEAR
           cmp   KeyCode,10
           jnb   EnterPosQuit
           and   ModeEdPos,Set
           jz    EnterPosQuit
           mov   bl,Dig0
           mov   Dig1,bl
           mov   al,KeyCode
           mov   Dig0,al
           mov   ErrorF,NoError    ;����뢠�� 䫠� �訡��
EnterPosQuit:
           ret
EnterPos   ENDP

;��� � ����� ������
GoToEnd    PROC  NEAR
           cmp   KeyCode,KeyEnd
           jne   GoToEndEnd
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    NoModeEnd
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   GoToEndEnd
NoModeEnd:
           mov   NewPos,LastPos
           mov   ErrorF,NoError
GoToEndEnd:
           ret   
GotoEnd    ENDP                      

;��� � ��砫� ������
GoToBeg    PROC  NEAR
           cmp   KeyCode,KeyBeg
           jne   GoToBegQuit
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    NoModeBeg
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   GoToBegQuit
NoModeBeg:
           mov   NewPos,FirstPos
           mov   ErrorF,NoError
GotoBegQuit:
           ret
GoToBeg    ENDP

;��મ���
Park       PROC  NEAR
           cmp   KeyCode,KeyPark
           jne   ParkQuit
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    NoModePark
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   ParkQuit
NoModePark:
           mov   NewPos,ParkPos
           mov   ErrorF,NoError
ParkQuit:
           ret
Park       ENDP

;���। �� ���� ����
PosInc     PROC  NEAR
           cmp   KeyCode,KeyInc1
           jne   PosIncQuit
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    NoMode
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   PosIncQuit
NoMode:    mov   al,Pos
           inc   al
           mov   NewPos,al
           mov   ErrorF,NoError
PosIncQuit:
           ret
PosInc     ENDP

;����� �� ���� ����
PosDec     PROC  NEAR
           cmp   KeyCode,KeyDec1
           jne   PosDecQuit
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    PosDecNoMode
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   PosDecQuit           
PosDecNoMode:
           mov   al,Pos
           dec   al
           mov   NewPos,al
           mov   ErrorF,NoError
PosDecQuit:
           ret
PosDec     ENDP

;���室 �� ������ ���஢ ���।
PosInc10   PROC  NEAR
           cmp   KeyCode,KeyInc10
           jne   PosInc10Quit
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    NoModeInc10          
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   PosInc10Quit
NoModeInc10:
           mov   al,Pos
           add   al,Inc10
           mov   NewPos,al
           mov   ErrorF,NoError
PosInc10Quit:
           ret           
PosInc10   ENDP

;���室 �� ������ ���஢ �����
PosDec10   PROC  NEAR
           cmp   KeyCode,KeyDec10
           jne   PosDec10Quit
           mov   al,ModeAuto
           or    al,ModeEdPos
           or    al,ModeEdTime
           jz    NoModeDec10
           mov   ErrorF,ErrorNewPosInModeAE
           mov   ModeAuto,UnSet
           jmp   PosDec10Quit
NoModeDec10:
           mov   al,Pos
           add   al,Dec10           
           mov   NewPos,al
           mov   ErrorF,NoError
PosDec10Quit:           
           ret
PosDec10   ENDP



;��⠭�����/����� ०�� ��砩���� �롮�
InvRndMode PROC  NEAR
           cmp   KeyCode,KeyRnd
           jne   InvRndModeQuit
           mov   bl,ModeEdTime
           or    bl,ModeEdPos
           or    bl,ModeAuto
           jz    RNDOk
           mov   ErrorF,SetRndModeInEdAutoMode
           mov   ModeAuto,UnSet
           jmp   InvRndModeQuit
RndOk:     
           xor   ModeRnd,Set
           jz    UnSetRnd
           call  InitRND1
UnSetRnd:
           mov   ErrorF,NoError
InvRndModeQuit:
           ret
InvRndMode ENDP


;������஢��� �६�
EdTime     PROC  NEAR   
           cmp   KeyCode,KeyEdTime
           jne   EdTimeQuit     
           ;�஢�ઠ �� ⥪�騩 ०��
           mov   bl,ModeEdPos
           or    bl,ModeAuto
           jz    NoErrP1
           mov   ErrorF,EdErrAlreadyModeUse
           mov   ModeAuto,UnSet
           jmp   EdTimeQuit
NoErrP1:   mov   ModeEdTime,Set    ;��⠭���� 䫠�� ।���஢���� ०��� ����� �६���
           mov   Dig2,0Ah ;��襭�� ��� �������஢
           mov   Dig1,0Ah
           mov   Dig0,0Ah
           mov   ErrorF,NoError    ;����뢠�� 䫠� �訡��
EdTimeQuit:
           ret
EdTime     ENDP           



;��⠭����� �������� ����প�           
SetTime    PROC  NEAR
           cmp   KeyCode,KeySetTime
           je    SetTimeNoQuit
           jmp   SetTimeQuit
SetTimeNoQuit:           
           and   ModeEdTime,0FFh
           jnz   NoErSet
           mov   ErrorF,SetEdPosErrNoEdMode
           jmp   SetTimeQuit
NoErSet:   mov   ModeEdTime,UnSet
           call  ConvertDigEmptyToZero
           mov   al,Dig2
           add   al,Dig1
           add   al,Dig0
           jnz   NoZeroInAllDig
           mov   ErrorF,ErrorSetTimeValueNotPossible
           jmp   SetTimeQuit
NoZeroInAllDig:           
           cmp   Dig2,2
           jnbe  In2DigMore2
           je    In2Dig_2
;�� ��஬(0,1,-2-) �������� 0 ��� 1, �஢��塞 �㫥��� � ����
           cmp   Dig1,6
           jnbe  In1DigMore6
           je    In1Dig_6
;� ��ࢮ� (0,-1-,2) �������� �� ����� 5
           jmp   DigIsOk
;� ��ࢮ� �������� ����� 6
In1DigMore6:
           mov   ErrorF,6;ErrorSetTimeValueNotPossible
           jmp   SetTimeQuit
;� ��ࢮ� �������� 6
In1Dig_6:  and   Dig0,Set
           jz    DigIsOk
;� �㫥��� �������� �� 0
           mov   ErrorF,ErrorSetTimeValueNotPossible
           jmp   SetTimeQuit
In2DigMore2:
           mov   ErrorF,ErrorSetTimeValueNotPossible
           jmp   SetTimeQuit
In2Dig_2:  mov   bl,Dig0
           or    bl,Dig1
           jz    DigIsOk
           mov   ErrorF,ErrorSetTimeValueNotPossible
           jmp   SetTimeQuit
DigIsOk:           
;��������� ���祭�� �ࠢ��쭮�
;�८�ࠧ㥬 ��� � ������⢮ ��室�� ��楤��� ����প�
           mov   MultiplierForGetNumberFromDig,60
           call  GetNumberFromDig           
           mov   al,NumberFromDig
           mov   bh,DelayInSec
           mul   bh
           mov   MaxCountCycle,ax    ;����襬 ��� � ��६����� - ������⢮ ��室�� 横��
           mov   ErrorF,NoError
           mov   ModeEdTime,UnSet
           mov   NeedShowPosF,Set

SetTimeQuit:
           ret
SetTime    ENDP


;������஢��� ������
EdPos      PROC  NEAR
           cmp   KeyCode,KeyEdPos
           jne   EdPosQuit
           ;�஢�ઠ �� ⥪�騩 ०��
           mov   bl,ModeEdTime
           or    bl,ModeAuto
           jz    NoErrP2
           mov   ErrorF,EdErrAlreadyModeUse
           mov   ModeAuto,UnSet
           jmp   EdPosQuit
NoErrP2:   mov   ModeEdPos,0FFh  ;��⠭���� 䫠�� ।���஢���� ०��� ����� ����樨
           mov   Dig2,0Ah     ;��襭�� ��� �������஢
           mov   Dig1,0Ah
           mov   Dig0,0Ah
           mov   ErrorF,NoError    ;����뢠�� 䫠� �訡��
EdPosQuit:
           ret           
EdPos      ENDP


;��⠭�����/������ ��⮬���᪨� ०��
InvAutoMode      PROC        NEAR
           cmp   KeyCode,KeyAutoSS
           jne   InvAutoModeQuit
           ;�஢�ઠ �� ⥪�騩 ०��
           mov   bl,ModeEdTime
           or    bl,ModeEdPos
           jz    NoErrP3
           mov   ErrorF,SetAutoErrEdAlreadyModeUse
NoErrP3:   
           xor   ModeAuto,Change
           jz    UnSetModeAuto
;����� ����稫��
           mov   AllCadrShow,UnSet
           mov   PosInModeAuto,1
           mov   ax,MaxCountCycle
           dec   ax
           mov   CycleCount,ax
           mov   ErrorF,NoError  ;����뢠�� 䫠� �訡��  
           jmp   InvAutoModeQuit
UnSetModeAuto:           
           mov   ErrorF,NoError  ;����뢠�� 䫠� �訡��
InvAutoModeQuit:
           ret
InvAutoMode      ENDP           

;��⠭����� �� ������
SetPos     PROC  NEAR
           cmp   KeyCode,KeySetPos
           jne   SetPosQuit
           and   ModeEdPos,0FFh     ;�஢�ઠ �� ०�� ।���஢���� ����樨
           jnz   NoErrP4
           mov   ErrorF,SetEdPosErrNoEdMode
           jmp   SetPosQuit
NoErrP4:   mov   ModeEdPos,UnSet
           mov   MultiplierForGetNumberFromDig,100
           call  GetNumberFromDig    ;����稬 ��������� �᫮ � NumberFromDig
           mov   al,NumberFromDig   
           mov   NewPos,al           ;����襬 �᫮ � ����� ������ ������
           mov   ErrorF,NoError      ;����뢠�� 䫠� �訡��
SetPosQuit:
           ret
SetPos     ENDP           

;�⬥�� ०��� ।���஢���� � ���
Cancel     PROC  NEAR
           cmp   KeyCode,KeyCancel
           jne   CancelQuit
           mov   ModeAuto,UnSet
           mov   ModeEdPos,UnSet
           mov   ModeEdTime,UnSet
           mov   NeedShowPosF,Set
           mov   ErrorF,NoError
           jmp   CancelQuit
CancelQuit:
           ret
Cancel     ENDP           

;��⠭���� ���ࠢ����� ��� - ��אַ�
SetAutoInc PROC  NEAR
           cmp   KeyCode,KeyInc1A
           jne   SetAutoIncQuit
           mov   AutoInc,Inc1
           mov   AutoIncF,Set
           mov   ErrorF,NoError
SetAutoIncQuit:
           ret           
SetAutoInc ENDP

;��⠭���� ���ࠢ����� ���-���⭮�
SetAutoDec PROC  NEAR
           cmp   KeyCode,KeyDec1A
           jne   SetAutoDecQuit
           mov   AutoInc,Dec1
           mov   AutoIncF,UnSet
           mov   ErrorF,NoError
SetAutoDecQuit:
           ret
SetAutoDec ENDP

;��㧠 ���०��� - �த������ ��᫥ ����
PausePlay  PROC  NEAR
           cmp   KeyCode,KeyPause
           jne   PausePlayQuit
           mov   al,ModeEdPos
           or    al,ModeEdTime
           jz    NoEdMode
           mov   ErrorF,SetAutoErrEdAlreadyModeUse
           jmp   PausePlayQuit
NoEdMode:
           xor   ModeAuto,0FFh
           mov   ErrorF,NoError
PausePlayQuit:
           ret
PausePlay  ENDP

;�����஢��� ����� ��᫥����⥫����
GenRnd     PROC  NEAR
           cmp   KeyCode,KeyGenRnd
           jne   GenRndQuit
           and   ModeAuto,Set
           jz    NoModeAutoNow
           mov   ErrorF,GenerateNewRndInAutoModeUse
           mov   ModeAuto,UnSet
           jmp   GenRndQuit
NoModeAutoNow:
           call  InitRnd1
           mov   ErrorF,NoError
GenRndQuit:
           ret           
GenRnd     ENDP

HandControl      PROC        NEAR
           call  GoToEnd     ;��� � ����� ������
           call  GoToBeg     ;��� �� ����� ������
           call  Park        ;��મ���� ������
           call  PosInc
           call  PosDec
           call  PosInc10
           call  PosDec10
           ret
HandControl      ENDP           

SetMode    PROC  NEAR
           call  InvAutoMode ;���樠����஢���/�몫���� ���०��
           call  InvRndMode  ;�������/�몫���� ��砩��� ०��
           call  EdTime      ;������஢��� ����প�
           call  EdPos       ;������஢��� ������
           call  Cancel      ;�⬥�� ०���� ।���஢���� � ���०���
           call  SetAutoDec  ;��⠭����� ���ࠢ����� ��⮯����� �����
           call  SetAutoInc  ;��⠭����� ���ࠢ����� ��⮯����� ���।
           call  PausePlay   ;��㧠/�த������ ��⮯����
           ret
SetMode    ENDP