; � �⮬ ���㫥 ᮡ࠭� �� ��楤���
; ⠪ ��� ���� �⭮��騥�� � �ନ஢����
; ���ᨢ�� �⮡ࠦ���� 祪�

; ���樠������ 祪� 祪�
InitCheck  PROC  NEAR
           CMP   Error,0
           JNE   ICh_end
           
           LEA   DI,CheckImg
           MOV   CX,(SIZE CheckImg + SIZE Com_Field)
ICh_cyc1:  MOV   BYTE PTR [DI],0FFh
           INC   DI
           LOOP  ICh_cyc1
           
           LEA   SI,LF_INN
           LEA   DI,CheckImg + 56
           MOV   CX,112
ICh_cyc2:  MOV   AL,CS:[SI]
           MOV   [DI],AL
           INC   DI
           INC   SI
           LOOP  ICh_cyc2
                      
           LEA   BX,Com_Field
           MOV   AddrCurStr,BX
           
           MOV   Department,21    ; 1-� �⤥�
           
ICh_end:   RET
InitCheck  ENDP

; ���樠������ �������� 祪�
InitItCheck PROC  NEAR
           CMP   Error,0
           JNE   IICh_end
           
           LEA   DI,ItCheckImg
           MOV   CX,(SIZE ItCheckImg + SIZE ItComField)
IICh_cyc1: MOV   BYTE PTR [DI],0FFh
           INC   DI
           LOOP  IICh_cyc1
           
           LEA   SI,LF_INN
           LEA   DI,ItCheckImg + 56
           MOV   CX,112
IICh_cyc2: MOV   AL,CS:[SI]
           MOV   [DI],AL
           INC   DI
           INC   SI
           LOOP  IICh_cyc2
           
           LEA   BX,ItComField
           MOV   AddrItStr,BX
           
IICh_end:  RET
InitItCheck ENDP

; �뢮� 祪�
CheckOutput PROC  NEAR
           CMP   Error,0
           JNE   ChO_end
           
           CMP   ActButCode,Itog
           JNE   ChO_end

           LEA   SI,ItogRez
           LEA   DI,DayItogRez
           CALL  AddFunc
           CALL  Overflow
           
           LEA   DI,CheckImg+168
           CALL  IntToDate           ; ᠯ��� � 祪 ����

           LEA   DI,CheckImg+202
           CALL  IntToTime           ; ᠯ��� � 祪 ⥪�饣� �६���
           
           LEA   BX,AddrCurStr
           CALL  TotalSave           ; ������ �⮣���� �㬬� � 祪
           
           LEA   DI,AddrCurStr
           LEA   BX,CheckImg
           CALL  Check
           
           LEA   DI,ItogRez
           CALL  FloatClear
           LEA   DI,Rez
           CALL  FloatClear
           LEA   DI,Arg
           CALL  FloatClear
           MOV   Operation,0
           
           CALL  InitCheck
           
ChO_end:   RET
CheckOutput ENDP

; �뢮� �⮣����� 祪�
ItCheckOutput PROC  NEAR
           CMP   Error,0
           JNE   ChO_end

           LEA   DI,ItCheckImg+168
           CALL  IntToDate           ; ᠯ��� � 祪 ����

           LEA   DI,ItCheckImg+202
           CALL  IntToTime           ; ᠯ��� � 祪 ⥪�饣� �६���

           MOV   DI,AddrItStr        ; ������ 
           MOV   CX,10
           LEA   SI,HandBook+5
           LEA   BX,GoodCode
           MOV   BYTE PTR [BX],0
ICO_cyc1:  CMP   BYTE PTR [SI],0
           JNZ   ICO_0
           CMP   BYTE PTR [SI+1],0
           JNZ   ICO_0
           CMP   BYTE PTR [SI+2],0
           JNZ   ICO_0
           CMP   BYTE PTR [SI+3],0
           JNZ   ICO_0
           CMP   BYTE PTR [SI+4],0
           JZ    ICO_1
ICO_0:     XCHG  BX,SI
           CALL  CodeToCheck
           XCHG  SI,BX
           PUSH  CX
           CALL  FloatToStr
           POP   CX
           CALL  NumToCheck           
ICO_1:     INC   BYTE PTR [BX]
           ADD   SI,10
           LOOP  ICO_cyc1           
           MOV   AddrItStr,DI

           LEA   BX,AddrItStr
           
           LEA   SI,DayItogRez          ; �뢮� �� ��������� �⮣���� �㬬�
           CALL  FloatToStr
           CALL  TotalSave              ; ������ �⮣���� �㬬� � 祪
           
           LEA   DI,AddrItStr
           LEA   BX,ItCheckImg
           CALL  Check
                      
           LEA   DI,DayItogRez
           CALL  FloatClear
           LEA   DI,ItogRez
           CALL  FloatClear
           LEA   DI,Rez
           CALL  FloatClear
           LEA   DI,Arg
           CALL  FloatClear
           MOV   Operation,0

IChO_end:  RET
ItCheckOutput ENDP

; �뢮� 祪� �� ��������; ��ࠬ����:
; bx - ���� ��砫� 祪�;
; di - ���� ���� 祪�;
Check      PROC  NEAR
           CMP   Error,0
           JNE   Ch_end
           
           PUSH  AX CX DX SI
NextRow:   XOR   SI,SI
           MOV   CH,1h
           
NextInd:   MOV   AL,CH
           OUT   0Ah,AL

           MOV   CL,1h
NextCol:   MOV   AL,0h
           OUT   9,AL        

           MOV   AL,[BX+SI]
           NOT   AL
           
           CMP   DX,0h
           JZ    OutCol
           PUSH  CX
           MOV   AH,[BX+SI+56]
           NOT   AH
           MOV   CL,8h
           SUB   CL,DL
           SHL   AH,CL           
           MOV   CX,DX           
           SHR   AL,CL
           OR    AL,AH
           POP   CX
                      
OutCol:    OUT   8,AL
           MOV   AL,CL
           OUT   9,AL
           
           INC   SI
           ROL   CL,1
           JNC   NextCol
           
           SHL   CH,1
           CMP   CH,80h
           JNZ   NextInd
           
           INC   DX
           CMP   DX,8h
           CALL  Delay
           JNZ   NextRow
           ADD   BX,38h
           XOR   DX,DX
           MOV   AX,[DI]
           CMP   AX,BX
           JA    NextRow
           POP   SI DX CX AX
Ch_end:    RET
Check      ENDP

; ����������� �⤥��
SelDepart  PROC  NEAR
           CMP   Error,0
           JNE   SD_end           
           
           MOV   AL,ActButCode
           
           CMP   AL,11
           JB    SD_end
           CMP   AL,13
           JA    SD_end

           MOV   Department,AL
           
SD_end:    RET
SelDepart  ENDP

; ������ ����� �⤥�� � 祪; ��ࠬ����:
; di - ���� � 祪� �㤠 �㦭� �����뢠�� ����� �⤥��;
DepToCheck PROC  NEAR
           CMP   Error,0
           JNE   DCT_end
           
           MOV   AL,Department
           CMP   AL,13
           JNE   DTC_2
           LEA   BX,Dep_3
           JMP   DTC_3
DTC_2:     CMP   AL,12
           JNE   DTC_1
           LEA   BX,Dep_2
           JMP   DTC_3
DTC_1:     LEA   BX,Dep_1
         
DTC_3:     MOV   CX,24                   ; ����� ��ப� �⤥��

DTC_cyc:   MOV   AL,CS:[BX]
           MOV   [DI],AL
           INC   DI
           INC   BX
           LOOP  DTC_cyc
           
DCT_end:   RET
DepToCheck ENDP

; ������ �᫠ � 祪; ��ࠬ����:
; di - ���� � 祪� �㤠 �㦭� �����뢠�� �᫮;
NumToCheck PROC  NEAR
           PUSH  BX CX SI
           
           CALL  RoundFloat              ; ���㣫����
           LEA   SI,Str+7
           MOV   CX,8

NTC_cyc1:  XOR   AX,AX                   ; ����祭�� ��ࠧ� �����
           MOV   AL,[SI]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]     ; ����஢��� ��ࠧ� �����
           MOV   WORD PTR [DI],AX        ; � 祪
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+2],AX

           ADD   DI,4
           DEC   SI
           LOOP  NTC_cyc1
           
           POP   SI CX BX
           RET
NumToCheck ENDP

; ������ �᫠ � 祪; ��ࠬ����:
; di - ���� � 祪� �㤠 �㦭� �����뢠�� �᫮;
; si - ��� ⮢��
CodeToCheck PROC  NEAR
           PUSH  BX DX
           ADD   DI,2
           MOV   AL,[SI]
           AAM
           XCHG  AH,AL
           MOV   DL,AH
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX
                      
           MOV   AX,WORD PTR CS:[BX]     ; ����஢��� ��ࠧ� �����
           MOV   WORD PTR [DI],AX        ; � 祪
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+2],AX
           ADD   DI,4

           MOV   AL,DL
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]     ; ����஢��� ��ࠧ� �����
           MOV   WORD PTR [DI],AX        ; � 祪
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+2],AX
           ADD   DI,18
           
           POP   DX BX
           RET
CodeToCheck ENDP

; ������ ��㬥�⮢ � 祪
ArgsSave   PROC  NEAR
           CMP   Error,0
           JNE   AS_end
           
           PUSH  SI DI
           MOV   DI,AddrCurStr        
           
           LEA   SI,GoodCode
           CALL  CodeToCheck         ; ������ ���� ⮢��
           
           LEA   SI,Rez              ; ������ 業� ⮢��
           CALL  FloatToStr
           CALL  NumToCheck
                                 
           ADD   DI,20
           LEA   SI,Star             ; ������ ����� 㬭������
           MOV   CX,4
AS_cyc:    MOV   AL,CS:[SI]
           MOV   [DI],AL
           INC   SI
           INC   DI
           LOOP  AS_cyc

           LEA   SI,Arg              ; ������ ���-�� ⮢��
           CALL  FloatToStr
           CALL  NumToCheck

           MOV   AddrCurStr,DI
           POP   DI SI
           
AS_end:    RET
ArgsSave   ENDP

; ������ �஬����筮� �㬬� � 祪
SubTotalSave PROC  NEAR
           CMP   Error,0
           JNE   STS_end
           
           PUSH  SI DI
           MOV   DI,AddrCurStr
           
           CALL  DepToCheck           
           LEA   SI,Rez
           CALL  FloatToStr
           CALL  NumToCheck

           MOV   AddrCurStr,DI
           POP   DI SI

STS_end:   RET
SubTotalSave ENDP

; ������ �⮣���� �㬬� � 祪; ��ࠬ����:
; bx - ���� ���� 祪�
TotalSave  PROC  NEAR
           CMP   Error,0
           JNE   TS_end
           
           MOV   DI,[BX]
           LEA   SI,Itogo
           MOV   CX,24
TS_cyc:    MOV   AL,CS:[SI]
           MOV   [DI],AL
           INC   SI
           INC   DI
           LOOP  TS_cyc
           
           CALL  NumToCheck
           MOV   [BX],DI
           
TS_end:    RET
TotalSave  ENDP