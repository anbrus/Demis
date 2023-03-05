; ����ଠ������ �������, ��ࠬ����:
; � di - ᬥ饭�� ����⢥����� �᫠,
; � cx - ࠧ����� ���浪��
DenormMant PROC  NEAR
           PUSH  AX
           INC   DI                  ; ���室 � ������

DN_cyc:    PUSH  CX
           MOV   CX,10               ; 横� ������� �������
           CALL  Div_DD_DW          ; �� 10 � 㢥��祭��
           INC   BYTE PTR [DI-1]     ; ���浪� �� 1
           POP   CX
           LOOP  DN_cyc

           DEC   DI
           POP   ax
           RET
DenormMant ENDP

; ��ଠ������ �������, ��ࠬ����:
; � di - ᬥ饭�� ����⢥����� �᫠
NormMant   PROC  NEAR
           PUSH  AX CX
           
           XOR   AX,AX
           INC   DI                  ; ���室 � ������
           PUSH  [DI+2]              ; �� ��࠭����
           PUSH  [DI]

           MOV   CX,10
NM_cyc:    CALL  Div_DD_DW           ; ������ �᫠
           INC   AH                  ; �������� ���
           CMP   WORD PTR [DI+2],0   ; � ������ ��⥬
           JNE   NM_cyc              ; ������� �� �� 10
           CMP   WORD PTR [DI],0     ; �� �� ���, ����
           JNE   NM_cyc              ; ��� �� ���㫨���

           POP   [DI]                ; ����⠭�������
           POP   [DI+2]              ; �������

           CMP   AH,8                ; ��ଠ����������
           JE    NM_3                ; ������ ᮤ�ন�
           JB    NM_2                ; 8 DEC ���

NM_4:      CALL  Div_DD_DW           ; �᫨ ������ ᮤ��-
           INC   BYTE PTR [DI-1]     ; ��� ����� DEC ���,
           DEC   AH                  ; � �� ���� ������ ��
           CMP   AH,8                ; 10 � ���६���஢���
           JNE   NM_4                ; ���冷�
           JMP   NM_3

NM_2:      CALL  Mul_DD_DW           ; �᫨ �� ������ �-
           DEC   BYTE PTR [DI-1]     ; ��ন� ����� DEC
           INC   AH                  ; ��� 祬 8, � ��
           CMP   AH,8                ; ���� ������� �� 10 �
           JNE   NM_2                ; ���६����� ���冷�

NM_3:      DEC   DI
NM_end:    POP   CX AX
           RET
NormMant   ENDP

; �஢�ઠ ��९������� � ��⨯�९������ ����⢥����� �᫠, ��ࠬ����:
; � di - ᬥ饭�� ����⢥����� �᫠,
; � al - 䫠� ��९������� (0 - �� ��ଠ�쭮, FFh - ��९�������)
Overflow   PROC NEAR
           CMP BYTE PTR [DI],9     ; �஢�ઠ ��९�������
           JL    O_1
           MOV   AL,0FFh
           JMP   O_end

O_1:       CMP BYTE PTR [DI],-7    ; �஢�ઠ ��⨯�९�������
           JG    O_end
           CALL  FloatClear
O_end:     RET
Overflow   ENDP

; �������� ���� ����⢥���� �ᥫ, ��ࠬ����:
; � di - ᬥ饭�� 1-��� ᫠������� � �㬬�,
; � si - ᬥ饭�� 2-��� ��㬥��
AddFunc    PROC  NEAR
           PUSH  AX CX DX DI SI

           MOV   AL,[DI]             ; �ࠢ�����
           CMP   AL,[SI]             ; ���浪��
           JE    A_1
           JL    A_cyc
           XCHG  DI,SI

A_cyc:     XOR   CH,CH               ; ��ࠢ�������
           MOV   CL,[SI]             ; ���浪��
           SUB   CL,[DI]
           CALL  DenormMant

A_1:       POP   SI DI

           MOV   AX,DI[1]            ; ��᫮����
           MOV   DX,DI[3]            ; ᫮�����
           ADD   AX,SI[1]            ; ������
           ADC   DX,SI[3]
           MOV   DI[1],AX
           MOV   DI[3],DX

           CALL  NormMant
           POP   DX CX AX
           RET
AddFunc    ENDP

; ��������� �������� ᫮�� �� �������� ᫮��; ��ࠬ����: 
; � di - ᬥ饭�� ��㬥��1, 
; � si - ᬥ饭�� ��㬥��2, 
; � ��६����� MulRez - १����
Mul_DD_DD  PROC  NEAR
           PUSH  AX DX

           MOV   WORD PTR [MulRez],0
           MOV   WORD PTR [MulRez+2],0
           MOV   WORD PTR [MulRez+4],0
           MOV   WORD PTR [MulRez+6],0

           MOV   AX,[DI]
           MUL   WORD PTR [SI]
           MOV   MulRez,AX
           MOV   MulRez+2,DX

           MOV   AX,[DI]
           MUL   WORD PTR [SI+2]
           ADD   MulRez+2,AX
           ADC   MulRez+4,DX

           MOV   AX,[DI+2]
           MUL   WORD PTR [si]
           ADD   MulRez+2,AX
           ADC   MulRez+4,DX

           MOV   AX,[DI+2]
           MUL   WORD PTR [si+2]
           ADD   MulRez+4,AX
           ADC   MulRez+6,DX

           POP   DX AX
           RET
Mul_DD_DD  ENDP

; ��������� �������� ᫮�� �� ᫮��; ��ࠬ����:
; � di - ᬥ饭�� dd, 
; � cx - ���祭�� dw
Mul_DD_DW  PROC  NEAR
           PUSH  AX DX

           MOV   AX,[DI+2]
           MUL   CX
           MOV   [DI+2],AX
           MOV   AX,[DI]
           MUL   CX
           MOV   [DI],AX
           ADD   [DI+2],DX

           POP   DX AX
           RET
Mul_DD_DW  EndP

; ������� �����᫮�� �� ᫮��; ��ࠬ����:
; � di - ᬥ饭�� dq, 
; � cx - ���祭�� dw
Div_DQ_DW  PROC  NEAR
           PUSH  AX BX DX

           XOR   DX,DX
           MOV   BX,8

D_cyc:     DEC   BX
           DEC   BX

           MOV   AX,[DI+BX]
           DIV   CX
           MOV   [DI+BX],AX

           CMP   BX,0
           JNE   D_cyc

           POP   DX BX AX
           RET
Div_DQ_DW  ENDP

; ������� �������� ᫮�� �� ᫮��; ��ࠬ����:
; � di - ᬥ饭�� dd, 
; � cx - ���祭�� dw, 
; ��⭮� ����頥��� �� ���� ��������, ���⮪ ������
Div_DD_DW  PROC  NEAR
           PUSH  AX DX

           XOR   DX,DX               ; ���७�� ���襣�
           MOV   AX,[DI+2]           ; ᫮�� dd � ���
           DIV   CX                  ; ������� �� dw
           MOV   [DI+2],AX
           MOV   AX,[DI]             ; ������� ����襣� ᫮�� dd � ��⠪�
           DIV   CX                  ; �� ������� ���襣� ᫮�� �� dw

           MOV   [DI],AX
           POP   DX AX
           RET
Div_DD_DW  ENDP

; ��������� ���� ����⢥���� �ᥫ; ��ࠬ����:
; � di - ᬥ饭�� 1-��� �����⥫� � �ந��������,
; � si - ᬥ饭�� 2-��� �����⥫�
MulFunc    PROC  NEAR
           PUSH  AX BX CX

           MOV   AL,[DI]             ; ᫮�����
           ADD   AL,[SI]             ; ���浪��
           MOV   [DI],AL

           INC   SI                  ; ���室 �
           INC   DI                  ; �����ᠬ
           CALL  Mul_DD_DD

           PUSH  DI                  ; ���४�� �ந�����-
           MOV   CX,10000            ; ��� ������ ��⥬
           LEA   DI,MulRez           ; ������� �� �� 10�7,
           CALL  Div_DQ_DW           ; � �.�. ������ ����
           MOV   CX,1000             ; �뫮 �� 10�8, �
           CALL  Div_DQ_DW           ; ���६��� ���浪�
           POP   DI                  ; ����祭���� �����-
           DEC   BYTE PTR [DI-1]     ; ������� �᫠

           MOV   AX,MulRez           ; ��᫮����
           MOV   [DI],AX             ; �����������
           MOV   AX,MulRez+2         ; १����
           MOV   [DI+2],AX

           DEC   SI
           DEC   DI
           CALL  NormMant            ; ��ଠ������ �������

MF_end:    POP   CX BX AX
           RET
MulFunc    ENDP