; � �⮬ ���㫥 ᮡ࠭� �� ��楤���
; ⠪ ��� ���� �⭮��騥�� � ࠡ��
; � ��������ன

; ���樠������ ��ࠧ� ����������
InitOutMap PROC  NEAR
           MOV   OutputMap[0],3Fh    ; ��ࠧ� ���
           MOV   OutputMap[1],0Ch    ; �� 0 �� 9
           MOV   OutputMap[2],76h
           MOV   OutputMap[3],05Eh
           MOV   OutputMap[4],4Dh
           MOV   OutputMap[5],5Bh
           MOV   OutputMap[6],7Bh
           MOV   OutputMap[7],0Eh
           MOV   OutputMap[8],7Fh
           MOV   OutputMap[9],5Fh
           MOV   OutputMap[10],80h   ; ��ࠧ �窨
           MOV   OutputMap[11],40h   ; ��ࠧ ��
           MOV   OutputMap[12],0h    ; ��ࠧ ���⮣� ����
           MOV   OutputMap[13],10h   ; ��ࠧ '_'
           RET
InitOutMap ENDP

; �뢮� �� ��ᯫ�� ᮮ�饭�� Error
ErrOutput  PROC  NEAR
           CMP   Error,0
           JE    EMOend
           XOR   AL,AL
           OUT   8,AL
           OUT   7,AL
           OUT   6,AL
           OUT   5,AL
           MOV   AL,73h
           OUT   4,AL
           MOV   AL,60h
           OUT   3,AL
           OUT   2,AL
           OUT   0,AL
           MOV   AL,78h
           OUT   1,AL
EMOend:    RET
ErrOutput  ENDP

; �⮡ࠦ���� ��ப� �뢮��
StrOutput  PROC NEAR
           CMP   Error,0
           JNE   SOend

SOst:      XOR   DX,DX                       ; �뢮� ��ப�
           LEA   BX,OutputMap
           LEA   SI,Str
           PUSH  SI
           
SO_cyc2:   LODSB
           XLAT
           CMP   AL,80h                      ; �᫨ ⥪�騩 ���� - �窠,
           JNE   SO_1                        ; � �� ���� ��OR��� � ᫥���饬� �����
           MOV   AH,AL
           LODSB
           XLAT
           OR    AL,AH
           
SO_1:      OUT   DX,AL
           INC   DX
           CMP   DX,8
           JNE   SO_cyc2

           POP   SI                          ; ���� ��砫� ��ப�
           ADD   SI,9
SOend:     RET
StrOutput  EndP

; ���� ����������
KbdRead    PROC  NEAR
KRm1:      MOV   DX,3                ; ���� ���⮢ �����
KRCyc:     CALL  Time
           CALL  CheckSum
           DEC   DX                  ; 2-0 � ��室 �� 横��
           IN    AL,DX                ; ⮫쪮 ��᫥ ������
           CMP   AL,0                ; �����-���� ������ ��
           JNE   KRexit              ; ᮥ�������� � ���⠬�
           CMP   DX,0
           JNZ   KRCyc
           JMP   KRm1
           
KRexit:    PUSH  AX
KRm2:      IN    AL,DX                ; ���� �� �⦠�� ������
           OR    AL,AL
           JNZ   KRm2
           POP   AX                  ; ⥯��� � dl-����� ��⨢���� ����, � � al-��� ᮤ�ন���
           XOR   CL,CL               ; ��।������ ����� ��⨢���� �室� ��⨢���� ����

KRm3:      INC   CL
           SHR   AL,1                ; ������� �� �� ���, ���� 1 �� 㩤��
           JNZ   KRm3
           DEC   CL

           MOV   AL,DL               ; ���� ���� ������
           SHL   AL,3
           ADD   AL,CL
           
           MOV   ActButCode,AL
Krm_end:   RET
KbdRead    ENDP
          
; ���� ��।��� ���� �᫠
DigitInput PROC  NEAR
           CMP   Error,0
           JNE   DIend
           
           CALL  PointInput
           CALL  SelDepart
           
           CALL  ButtonClr
           CALL  ButtonClrE
           CALL  ButtonMode

           MOV   AL,ActButCode
           
           CMP   AL,0                ; �஢�ઠ, � ����⢨⥫쭮 �� ����� ��஢��
           JB    DIend               ; ��஢�� ������
           CMP   AL,9
           JA    DIend

           CMP   Str[12],0FFh        ; � ����� ���� ��ப�
           JNZ   DIm5                ; ���� ������� ������ ?
           CALL  DispZero
           MOV   Str[11],0
           MOV   Str[12],0
        
DIm5:      CMP   Str[11],0FFh        ; �᫨ ��� 㦥 �������
           JNZ   DIm1               
           CMP   Str[13],4           ; 㦥 ����� 2 ���� ��᫥ ����⮩
           JZ    DIend
           INC   Str[13]
           JMP   DIm4

DIm1:      CMP   Str[10],4           ; 㦥 ����� 4 ���� �� ����⮩
           JE    DIend               
           
DIm4:      CMP   Str[10],0           ; ��ப� ����� � ����� ������ "0"
           JNE   DIm2                ; ⮣�� ��祣� ������ �� ���� �
           CMP   AL,0                ; ᤢ����� ࠧ��� ��ப� �� ����
           JE    DIend
           JNE   DIm3
DIm2:      CALL  RotateLeft          ; ᤢ�� ࠭�� ��������� ࠧ�冷�
DIm3:      MOV   Str[0],AL           ; ������ ᨬ����-����
           INC   Str[10]             ; � ����訩 ࠧ��
DIend:     RET
DigitInput ENDP

; ���� �窨
PointInput PROC  NEAR
           CMP   Error,0
           JNE   DIend
           
           MOV   AL,ActButCode
           CMP   AL,Point            ; ����� ������ "." ?
           JNE   PIend               ; ���, ⮣�� ��室��

           CMP   Str[12],0FFh        ; � ����� ���� ��ப�
           JNE   PIm1                ; ���� ������� ������ ?
           CALL  DispZero
           MOV   Str[12],0

PIm1:      CMP   Str[11],0FFh        ; �᫨ ��� 㦥 �������, 
           JE    PIend               ; � ��� ���� �窨 ����������

           CMP   Str[10],0           ; ��ப� �����?
           JNE   PIm2                ; ���, � ���室 ��,
           INC   Str[10]             ; ⮣�� ���� ��। �窮� - �㫥���

PIm2:      CALL  RotateLeft          ; ᤢ�� ࠭�� ��������� ࠧ�冷�

           MOV   Str[0],AL           ; ������ �窨 � ����訩 ࠧ��    
           MOV   Str[11],0FFh        ; ��⠭���� 䫠�� ������ �窨 � ��ப�
PIend:     RET
PointInput ENDP

; ���� �६���
TimeInput  PROC  NEAR
           CMP   Error,0
           JNE   TIn_end

           LEA   DI,Str
           MOV   AL,ActButCode
           MOV   AH,[DI+10]
           
           CMP   AH,0                        ; ���� ��ࢮ� ����� �ᮢ
           JNZ   TIn_01
           CMP   AL,0
           JB    TIn_end
           CMP   AL,2
           JA    TIn_end
           
TIn_01:    CMP   AH,1                        ; ���� ��ன ����� �ᮢ
           JNZ   TIn_02
           MOV   DL,[DI+4]
           CMP   DL,2
           JNZ   TIn_02
           CMP   AL,0
           JB    TIn_end
           CMP   AL,3
           JA    TIn_end
          
TIn_02:    CMP   AH,2                        ; ���� ��ࢮ� ����� �����
           JNZ   TIn_03
           CMP   AL,0
           JB    TIn_end
           CMP   AL,5
           JA    TIn_end
           
TIn_03:    CMP   AL,0
           JB    TIn_end
           CMP   AL,9
           JA    TIn_end

           CMP   BYTE PTR [DI+10],5           ; 㦥 ����� �६�
           JZ    TIn_end
           
           CMP   BYTE PTR [DI+10],2           ; 㦥 ���� ���
           JNZ   TIn_1
           INC   BYTE PTR [DI+10]

TIn_1:     MOV   DX,4
           SUB   DL,[DI+10]
           ADD   DI,DX
           MOV   [DI],AL
           INC   BYTE PTR Str+10
TIn_end:   RET
TimeInput  ENDP

; ���� ����
DateInput  PROC  NEAR
           CMP   Error,0
           JNE   DIn_end

           LEA   DI,Str
           MOV   AL,ActButCode
           MOV   AH,[DI+10]
           
           CMP   AH,0                        ; ���� ��ࢮ� ����� �᫠
           JNZ   DIn_01
           CMP   AL,0
           JB    TIn_end
           CMP   AL,3
           JA    TIn_end
           
DIn_01:    CMP   AH,1                        ; ���� ��ன ����� �᫠
           JNZ   DIn_02
           MOV   DL,[DI+7]
           CMP   DL,3
           JNZ   DIn_02
           CMP   AL,0
           JB    TIn_end
           CMP   AL,1
           JA    TIn_end
           
DIn_02:    CMP   AH,2                        ; ���� ��ࢮ� ����� �����
           JNZ   DIn_03
           CMP   AL,0
           JB    TIn_end
           CMP   AL,1
           JA    TIn_end
                     
DIn_03:    CMP   AH,4                        ; ���� ��ன ����� �᫠
           JNZ   DIn_04
           MOV   DL,[DI+4]
           CMP   DL,1
           JNZ   DIn_04
           CMP   AL,0
           JB    TIn_end
           CMP   AL,2
           JA    TIn_end
                             
DIn_04:    CMP   AL,0
           JB    TIn_end
           CMP   AL,9
           JA    TIn_end

           CMP   BYTE PTR [DI+10],8           ; 㦥 ����� ����
           JZ    TIn_end
           
           CMP   BYTE PTR [DI+10],2           ; 㦥 ���� ����
           JNZ   DIn_1
           INC   BYTE PTR [DI+10]

DIn_1:     CMP   BYTE PTR [DI+10],5           ; 㦥 ���� �����
           JNZ   DIn_2
           INC   BYTE PTR [DI+10]
           
DIn_2:     MOV   DX,7
           SUB   DL,[DI+10]
           ADD   DI,DX
           MOV   [DI],AL
           INC   BYTE PTR Str+10
DIn_end:   RET
DateInput  ENDP

DateTrue   PROC
           LEA   SI,DateCount
           
           MOV   AH,[SI+1]
           MOV   AL,[SI]
           AAD
           MOV   DX,AX
           
           MOV   AH,[SI+4]
           MOV   AL,[SI+3]
           AAD
           MOV   BX,AX
           
           MOV   AH,[SI+7]
           MOV   AL,[SI+6]
           AAD
           
           CMP   BX,2
           JNZ   DT_1
           AND   DX,3
           CMP   DX,0
           JNZ   DT_2
           CMP   AX,29
           JBE   DT_end
           JMP   DT_err
DT_2:      CMP   AX,28
           JBE   DT_end
           JMP   DT_err

DT_1:      CMP   BX,4
           JNZ   DT_3
           CMP   AX,30
           JBE   DT_end
           JMP   DT_err
           
DT_3:      CMP   BX,6
           JNZ   DT_4
           CMP   AX,30
           JBE   DT_end
           JMP   DT_err
           
DT_4:      CMP   BX,9
           JNZ   DT_5
           CMP   AX,30
           JBE   DT_end
           JMP   DT_err

DT_5:      CMP   BX,11
           JNZ   DT_end
           CMP   AX,30
           JBE   DT_end
           JMP   DT_err

DT_err:    MOV   Error,0FFh
           JMP   Date_cyc

DT_end:    RET
DateTrue   ENDP

; ��������� ⮣� �� �� ��ᯫ�� � ⥬, �� �㤥� ������� �������
MulRezArg  PROC  NEAR
           CMP   Error,0
           JNE   MRA_end

           CMP   ActButCode,Multiplication
           JNE   MRA_end
           
           CMP   Operation,3         ; �᫨ ���� �������� �
           JE    MRA_end             ; ��祣� �� �ந�室��

           MOV   Operation,3         ; ��������� ������ '*'
           XOR   AX,AX
           MOV   AL,Str
           CMP   Str+1,0Ch
           JZ    MRA_1
           MOV   AH,Str+1
MRA_1:     AAD
           MOV   GoodCode,AL
           
           LEA   DI,Rez              ; ���᫥��� �⮩���� ⮢�� 
           LEA   SI,HandBook         ; �� �ࠢ�筨��
           
           MOV   AH,10
           MUL   AH
           ADD   SI,AX
           MOV   CX,5
MRA_cyc:   MOV   AL,[SI]
           MOV   [DI],AL
           INC   SI
           INC   DI
           LOOP  MRA_cyc

           LEA   SI,Rez
           CALL  FloatToStr
           CALL  StrOutput
           CALL  RoundFloat              ; ���㣫����

           MOV   Str[11],0           ; ࠧ�襭�� �������� ���
           MOV   Str[12],0FFh
           MOV   Str[13],0           

MRA_end:   RET
MulRezArg  ENDP

; �믮������ ����⢨�
Calculate  PROC  NEAR
           CMP   Error,0
           JNE   Calc_end

           CMP   ActButCode,Calculation
           JNE   Calc_end
           CMP   Operation,3
           JNZ   Calc_end

           LEA   DI,Arg              ; ����祭� ��㬥�⮢ ���
           CALL  StrToFloat          ; 㬭������
           LEA   SI,Rez
           XCHG  SI,DI
           
           CALL  ArgsSave            ; ������ ��㬥�⮢ � 祪
           
           CALL  MulFunc
           CALL  Overflow            ; ����஫� ��९�������
           
           CALL  GoodCount           ; ������ ������⢠ ⮢��           
           CALL  SubTotalSave        ; ������ �஬����筮� �㬬� � 祪
           
           LEA   SI,Rez              ; ����祭�� ��㬥�⮢ ���
           LEA   DI,ItogRez          ; ᫮����� � �⮣���� �㬬��
           CALL  AddFunc
           CALL  Overflow            ; ����஫� ��९�������

           LEA   SI,ItogRez          ; �뢮� �� ��������� �⮣���� �㬬�
           CALL  FloatToStr
                              
           CALL  RoundFloat          ; ���㣫����
                            
           MOV   Str[12],0FFh
           MOV   Str[11],0FFh
           MOV   Operation,0
Calc_end:  RET
Calculate  ENDP

GoodCount  PROC  NEAR
           PUSH  BX SI DI
           
           LEA   BX,GoodCode
           LEA   SI,Rez
           LEA   DI,HandBook+5
                      
           MOV   AL,[BX]
           MOV   AH,10
           MUL   AH
           ADD   DI,AX
           CALL  AddFunc
           CALL  Overflow
           
           POP   DI SI BX
           RET
GoodCount  ENDP           