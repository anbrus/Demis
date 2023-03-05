Point            EQU  10                 ; ������ '.'
Dep1             EQU  11                 ; ������ '1 �⤥�'
Dep2             EQU  12                 ; ������ '2 �⤥�'
Dep3             EQU  13                 ; ������ '3 �⤥�'
Multiplication   EQU  14                 ; ������ '*'
Itog             EQU  15                 ; ������ '�⮣�'
Calculation      EQU  16                 ; ������ '����'
Clr              EQU  17                 ; ������ 'C'
ClrE             EQU  18                 ; ������ 'CE'
Mode             EQU  19                 ; ������ '�����'

Data       SEGMENT AT 0B000h use16
Error      DB    ?                       ; 䫠� �訡��

DayItogRez DB    5 DUP (?)
ItogRez    DB    5 DUP (?)
Rez        DB    5 DUP (?)               ; ����⢥��� �᫠: 1-� ���� - ���冷� � ������
Arg        DB    5 DUP (?)               ; ����� 2-5 - ������ � ������

Operation  DB    ?                       ; ������
Str        DB    14 DUP (?)              ; ��ப� �����/�뢮�� ������ �� ��ᯫ��:
                                         ; 8 ࠧ�冷� �⤥������ �窮�, ����, �᫮
                                         ; �������� ࠧ�冷�, 䫠� ������ �窨,
                                         ; 䫠� ⮣�, �� ��ப� ���� ������� ������,
                                         ; �᫮ ��������� ࠧ�冷� ��᫥ ����⮩
ActButCode DB    ?                       ; ��� ����⮩ ������
OutputMap  DB    13 DUP (?)              ; ���ᨢ ��ࠧ��
MulRez     DW    4 DUP (?)               ; �ᯮ����⥫쭠� ��६�����
Department DB    ?                       ; ����� �⤥��

TimeCount  DD    ?                       ; ���稪 �६���
DateCount  DB    8 DUP (?)               ; ���稪 ����

AddrCurStr DW    ?                       ; ���� ⥪�饩 ��ப� 祪�
AddrItStr  DW    ?                       ; ���� ⥪�饩 ��ப� 祪�

CheckImg   DB    224 DUP (?)             ; ��ࠧ 祪�
Com_Field  DB    10*56 DUP (?)

ItCheckImg DB    224 DUP (?)             ; ��ࠧ 祪� �������� ����
ItComField DB    12*56 DUP (?)

HandBook   DB    100 DUP (?)             ; �ࠢ�筨� �� ⮢���
GoodCode   DB    ?                       ; ��� ⮢��

Data       ENDS

Stk        SEGMENT AT 0C000h use16
           ORG   100h
           DW    20 DUP (?)
StkTop     LABEL WORD
Stk        ENDS


Code       SEGMENT use16
           Assume cs:Code,ds:Data,es:Data

HandBookCS DB    002h,0B0h,0B3h,0FAh,000h
           DB    5 DUP (0)
           DB    004h,00Ch,0EFh,09Ah,000h
           DB    5 DUP (0)
           DB    002h,040h,0C9h,0A2h,003h
           DB    5 DUP (0)
           DB    70 DUP (0)

           
Digits     DB    007h,077h,007h,0FFh    ; "0"
           DB    0FFh,0EFh,007h,0FFh    ; "1"
           DB    037h,057h,067h,0FFh    ; "2"
           DB    077h,057h,007h,0FFh    ; "3"
           DB    0C7h,0DFh,007h,0FFh    ; "4"
           DB    047h,057h,017h,0FFh    ; "5"
           DB    007h,057h,017h,0FFh    ; "6"
           DB    0F7h,017h,0E7h,0FFh    ; "7"
           DB    007h,057h,007h,0FFh    ; "8"
           DB    047h,057h,007h,0FFh    ; "9"
           DB    0FFh,07Fh,0FFh,0FFh    ; ","
Star:      DB    05Fh,0BFh,05Fh,0FFh    ; "*"
           DB    0FFh,0FFh,0FFh,0FFh    ; " "
           
Dep_1      DB    0FFh,0FFh,0EFh,007h,0FFh,0FFh,007h,077h,007h,0FFh,0F7h,007h,0F7h,0FFh,00Bh,06Bh
           DB    003h,0FFh,07Fh,0FFh,0B7h,0FFh,0FFh,0FFh
Dep_2      DB    0FFh,037h,057h,067h,0FFh,0FFh,007h,077h,007h,0FFh,0F7h,007h,0F7h,0FFh,00Bh,06Bh
           DB    003h,0FFh,07Fh,0FFh,0B7h,0FFh,0FFh,0FFh
Dep_3      DB    0FFh,077h,057h,007h,0FFh,0FFh,007h,077h,007h,0FFh,0F7h,007h,0F7h,0FFh,00Bh,06Bh
           DB    003h,0FFh,07Fh,0FFh,0B7h,0FFh,0FFh,0FFh
           
Itogo      DB    007h,07Fh,007h,0FFh,0F7h,007h,0F7h,0FFh,007h,077h,007h,0FFh,007h,0F7h,0F7h,0FFh
           DB    007h,077h,007h,0FFh,0B7h,0FFh,0FFh,0FFh

LF_INN     DB    0FFh,0FFh,007h,07Fh,007h,0FFh,007h,0DFh,007h,0FFh,007h,0DFh,007h,0FFh,0FFh,0F7h
           DB    017h,0E7h,0FFh,007h,057h,017h,0FFh,007h,077h,007h,0FFh,007h,077h,007h,0FFh,007h
           DB    077h,007h,0FFh,007h,077h,007h,0FFh,007h,077h,007h,0FFh,007h,077h,007h,0FFh,007h
           DB    077h,007h,0FFh,0F7h,017h,0E7h,0FFh,0FFh

LF_Name    DB    0FFh,0FFh,007h,07Fh,007h,0FFh,007h,0F7h,007h,0FFh,0FFh,007h,057h,0AFh,0FFh,007h
           DB    057h,077h,0FFh,007h,0D7h,0C7h,0FFh,007h,07Fh,007h,07Fh,007h,0FFh,007h,07Fh,007h
           DB    0FFh,007h,0DFh,007h,0FFh,007h,07Fh,007h,0FFh,007h,0DFh,007h,0FFh,0FFh,007h,057h
           DB    0AFh,07Fh,0FFh,007h,057h,0AFh,07Fh,0FFh

include keyboard.asm
include convert.asm
include math.asm
include check.asm
include display.asm
        
; ���⪠ ��६�����
ButtonClr  PROC  NEAR
           CMP   ActButCode,Clr
           JNE   BC_end

           LEA   DI,ItogRez
           CALL  FloatClear
           LEA   DI,Rez
           CALL  FloatClear
           LEA   DI,Arg
           CALL  FloatClear
           MOV   Operation,0
           CALL  DispZero
           MOV   Error,0
           
           CALL  InitCheck
           
BC_end:    RET
ButtonClr  ENDP

; ���⪠ ��ப� ����� �뢮��
ButtonClrE PROC  near
           CMP   Error,0
           JNE   BCE_end

           CMP   ActButCode,ClrE
           JNE   BCE_end

           CALL  DispZero
BCE_end:   RET
ButtonClrE ENDP

InitCommon PROC  NEAR
           LEA   DI,TimeCount        ; ���樠������ ���稪� �६���
           MOV   WORD PTR [DI],0
           MOV   WORD PTR [DI+2],0
                      
           LEA   BX,ItComField       ; ���樠������ ���� �⮣����� 祪�
           MOV   AddrItStr,BX
           
           LEA   DI,DayItogRez
           CALL  FloatClear
           
           LEA   SI,HandBookCS
           LEA   DI,HandBook
           MOV   CX,100
InCom_cyc: MOV   AL,CS:[SI]
           MOV   [DI],AL
           INC   SI
           INC   DI
           LOOP  InCom_cyc
           
           RET
InitCommon ENDP

Time       PROC  NEAR
           PUSH  AX BX DX SI DI
           LEA   DI,TimeCount
           LEA   SI,DateCount
           
           MOV   AX,WORD PTR [DI]
           MOV   DX,WORD PTR [DI+2]
           ADD   AX,1
           ADC   DX,0
           
           CMP   DX,0526h
           JNZ   T_end0
           CMP   AX,5C00h
           JNZ   T_end0
                                
           MOV   AH,[SI+1]                ; ⥪�騩 ���
           MOV   AL,[SI]
           AAD
           MOV   DX,AX
           
           MOV   AH,[SI+4]                ; ⥪�騩 �����
           MOV   AL,[SI+3]
           AAD
           MOV   BX,AX
           
           MOV   AH,[SI+7]                ; ⥪�騩 ����
           MOV   AL,[SI+6]
           AAD
           
           CMP   BX,2                    ; ���� �����?
           JNZ   T_8
           AND   DX,3
           CMP   DX,0
           JNZ   T_9
           CMP   AX,29
           JNZ   T_20
           CMP   BX,12                   ; ���� ���?
           JNZ   T_40
           CMP   BX,99                   ; ���� ���?
           JNZ   T_60
           JMP   T_7
           
T_9:       CMP   AX,28
           JNZ   T_20
           CMP   BX,12                   ; ���� ���?
           JNZ   T_40
           CMP   BX,99                   ; ���� ���?
           JNZ   T_6
           JMP   T_7

T_20:      JMP   T_2
T_40:      JMP   T_4
T_60:      JMP   T_6
T_end0:    JMP   T_end

T_8:       CMP   BX,4
           JNZ   T_10
           CMP   AX,30
           JNZ   T_2
           CMP   BX,12                   ; ���� ���?
           JNZ   T_4
           CMP   BX,99                   ; ���� ���?
           JNZ   T_6
           JMP   T_7
           
T_10:      CMP   BX,6
           JNZ   T_11
           CMP   AX,30
           JNZ   T_2
           CMP   BX,12                   ; ���� ���?
           JNZ   T_4
           CMP   BX,99                   ; ���� ���?
           JNZ   T_6
           JMP   T_7
           
T_11:      CMP   BX,9
           JNZ   T_12
           CMP   AX,30
           JNZ   T_2
           CMP   BX,12                   ; ���� ���?
           JNZ   T_4
           CMP   BX,99                   ; ���� ���?
           JNZ   T_6
           JMP   T_7

T_12:      CMP   BX,11
           JNZ   T_13
           CMP   AX,30
           JNZ   T_2
           CMP   BX,12                   ; ���� ���?
           JNZ   T_4
           CMP   BX,99                   ; ���� ���?
           JNZ   T_6
           JMP   T_7
           
T_13:      CMP   AX,31
           JNZ   T_2
           CMP   BX,12                   ; ���� ���?
           JNZ   T_4
           CMP   BX,99                   ; ���� ���?
           JNZ   T_6
           JMP   T_7

T_7:       XOR   DX,DX                  ; ���� ��� ����
           JMP   T_5
T_6:       INC   DX                     ; ᫥��騩 ��� ����
T_5:       MOV   BX,1                   ; ���� ����� ����
           JMP   T_3
T_4:       INC   BX                     ; ᫥��騩 ����� ����

T_3:       MOV   AX,1                   ; ���� ���� �����
           JMP   T_1
T_2:       INC   AX                     ; ᫥��騩 ����
          
T_1:       AAM
           MOV   [SI+7],AH
           MOV   [SI+6],AL
           
           MOV   AX,BX
           AAM
           MOV   [SI+4],AH
           MOV   [SI+3],AL
           
           MOV   AX,DX
           AAM
           MOV   [SI+1],AH
           MOV   [SI],AL
           
           XOR   AX,AX                   ; ���㫥��� �६���
           XOR   DX,DX
           
T_end:     MOV   WORD PTR [DI],AX        
           MOV   WORD PTR [DI+2],DX

           POP   DI SI DX BX AX
           RET
Time       ENDP

ButtonMode PROC  NEAR
           CMP   Error,0
           JNE   BM_end

           CMP   ActButCode,Mode
           JNE   BM_end
           
BM_1:      CALL  KbdRead
           CMP   ActButCode,Clr
           JZ    BM_end
           CMP   ActButCode,1
           JNZ   BM_1
           
BM_2:      CALL  KbdRead
           CMP   ActButCode,Clr
           JZ    BM_end
           CMP   ActButCode,Itog
           JNZ   BM_1
           
           CALL  ItCheckOutput
           
BM_end:    RET
ButtonMode ENDP

CheckSum   PROC  NEAR
           PUSH  AX BX CX
           XOR   AH,AH

           XOR   SI,SI
           LEA   BX,CS_end
           MOV   CX,BX
CSum_cyc1: ADD   AH,CS:[SI]
           INC   SI
           LOOP  CSum_cyc1
           
           IN    AL,3
           CMP   AH,AL
           JZ    ChS_end
           POP   CX BX AX
           MOV   Error,0FFh
           CALL  ErrOutput
           CALL  StrOutput
           JMP   Begin
ChS_end:   POP   CX BX AX
           RET
CheckSum   ENDP           

Delay      PROC  NEAR
           PUSH  CX
           MOV   CX,32000
Del_cyc:   NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           LOOP  Del_cyc
           POP   CX
           RET
Delay      ENDP

DateMain   PROC  NEAR
           MOV   ActButCode,Clr
Date_cyc:  CALL  DispDateZero
           CALL  ErrOutput
           CALL  StrOutput
           CALL  KbdRead
           CALL  DateInput
           CMP   ActButCode,Calculation
           JNZ   Date_cyc
           CALL  DateToInt
           CALL  DateTrue
           RET
DateMain   ENDP

TimeMain   PROC  NEAR
           MOV   ActButCode,Clr
           CALL  ButtonClr
           
           MOV   ActButCode,Clr
Time_cyc:  CALL  DispTimeZero
           CALL  StrOutput
           CALL  KbdRead
           CALL  TimeInput
           CMP   ActButCode,Calculation
           JNZ   Time_cyc
           CALL  TimeToInt
           
           MOV   ActButCode,Clr
           CALL  ButtonClr

           RET
TimeMain   ENDP

; ���� ��।���� ᨬ����
SymbolInput PROC  NEAR
           
           CALL  DigitInput
           CALL  PointInput
           CALL  SelDepart
           CALL  MulRezArg
           
           CALL  ButtonClr
           CALL  ButtonClrE
           CALL  ButtonMode
           
           RET
SymbolInput ENDP

Begin:     MOV   AX,Data
           MOV   DS,AX
           MOV   ES,AX
           MOV   AX,Stk
           MOV   SS,AX
           LEA   SP,StkTop
           
           CALL  CheckSum
           
           MOV   ActButCode,Clr
           CALL  ButtonClr
           
           CALL  InitCommon
           CALL  InitOutMap
           CALL  InitCheck
           CALL  InitItCheck
                                 
           CALL  DateMain
           CALL  TimeMain

Main_cyc:  CALL  ErrOutput
           CALL  StrOutput
           CALL  KbdRead
           CALL  SymbolInput
           
           CALL  Calculate
           
           CALL  CheckOutput
           JMP   Main_cyc
CS_end:

           ASSUME CS:nothing

           ORG   0FF0h               ; ������� ���⮢�� �窨
Start:     
BeginCs:   JMP   Far Ptr Begin       ; �ࠢ����� ��।����� �� ������� jump

Code EndS
END