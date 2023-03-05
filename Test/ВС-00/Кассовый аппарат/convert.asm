; ����� ᮤ�ন� ��楤��� �८�ࠧ������
; ��ப� �����/�뢮�� ������ �� ��ᯫ�� �
; ����⢥���� �᫮ � ᮮ⢥��⢨� � ��࠭��
; �ଠ⮬ ��ப� �����/�뢮�� � ����⢥����
; �ᥫ � ��楤��� �८�ࠧ������ ����⢥����
; �ᥫ � ��ப� �����/�뢮��

; ���᫥��� ������� ����⢥����� �᫠;
; ॣ���� di ������ �祩�� �����, �
; ������ �㦭� �������� �������
CalcMant   PROC NEAR
         push ax bx cx

         xor ah,ah
         mov cx,10

         mov bl,Str[10]          ; ᬥ饭�� ���襣� ��
                                 ; ��������� ࠧ�冷� =
                                 ; ��� ��������� ���
         cmp Str[11],0FFh        ; �᫨ ���� �窠, �
         je CMcyc                ; �᫮ ��� - 1, �᫨
         dec bl                  ; �窨 ���

   CMcyc:mov al,Str[bx]          ; ��� ��� ���������
         dec bl                  ; ���, ��稭�� �
                                 ; ���襩

         cmp al,10               ; �窠?
         jne CMm1                ; ���

         cmp bl,-1               ; �ய�� �窨
         je CMend                ; � ���� ��ப�

         jne CMcyc               ; �ய�� �窨
                                 ; � �।��� ��ப�

    CMm1:call Mul_DD_DW        ; ����������
         add [di],ax             ; �������
         adc word ptr [di+2],0

         cmp bl,-1               ; ��横�������, �᫨
         jnz CMcyc               ; ��ࠡ�⠭� �� ��
                                 ; ���������� ࠧ���
   CMend:pop cx bx ax
           RET
CalcMant   ENDP

; ����� ���浪� ����⢥����� �᫠;
; ॣ���� di ������ �祩�� �����, �
; ������ �㦭� �������� ���冷�
CalcOrder  PROC  NEAR
           PUSH  AX BX CX

           XOR   BH,BH
           MOV   BL,Str[10]          ; ᬥ饭�� ���襣� �� ��������� ࠧ�冷� =
                                     ; ��� ��������� ���, �᫨ ���� �窠

           CMP   Str[11],0           ; �窠 ����?
           JNE   CO_1                ; ����, � ���室
           MOV   [DI],BL             ; �᫨ �� �窨 ���, �
           JMP   CO_end               ; ���冷� = �᫮ ���

CO_1:      XOR   CX,CX
           MOV   AL,Str[BX]
           CMP   AL,0                ; 楫�� ��� ���?
           JNE   CO_2                ; ����, � ���室

           DEC   BL                  ; �ய�� �窨

CO_cyc:    DEC   BL                  ; ���� ����⥫�-
           DEC   CX                  ; ���� ���浪�
           MOV   AL,Str[BX]

           CMP   BL,-1                ; �᫨ ��ப� ����� �� ����� ���
           JE    CO_end               ; ������ 0, � ��室

           CMP   AL,0
           JE    CO_cyc

           INC   CL
           MOV   [DI],CL
           JMP   CO_end

CO_2:      DEC   BL                  ; ����
           INC   CX                  ; ������⥫쭮��
           MOV   AL,Str[BX]          ; ���浪�
           CMP   AL,10
           JNE   CO_2
           MOV   [DI],CL

CO_end:    POP   CX BX AX
           RET
CalcOrder  ENDP

; �८�ࠧ������ �������; ��ࠬ����:
; ॣ���� si ������ �祩��, �� ���ன
; ���� ���� �������
ConvMant   PROC  NEAR
           PUSH  AX CX DX

           MOV   CX,10
CM_cyc:    MOV   AX,[SI+2]           ; �뤢������ DEC ���
           XOR   DX,DX               ; ������� �� �����,
           DIV   CX                  ; ��稭�� � ����襩,
           MOV   [SI+2],AX           ; ��⥬ ������� ��
           MOV   AX,[SI]             ; �� 10
           DIV   CX
           MOV   [SI],AX

           CALL  RotateRight         ; ᤢ�� ࠧ�冷� ��ப�
           MOV   Str[7],DL           ; ���������� ��ப�
           INC   Str[10]

           CMP   WORD PTR [SI+2],0   ; 横� ������� ������
           JNE   CM_cyc              ; �� �� ���, ����
           CMP   WORD PTR [SI],0     ; ������ �� �������
           JNE   CM_cyc              ; {�� ���㫨���}

           POP DX CX AX
           RET
ConvMant   ENDP

; �८�ࠧ������ ���浪� {���⠭���� �窨};
; ��ࠬ����: ॣ���� si ������ �祩��, �� ���ன
; ᫥��� ����� ���冷�
ConvOrder  PROC  NEAR
           push  AX BX CX

           MOV   Str[11],0FFh        ; ��⠭���� 䫠�� ������ �窨

           CMP   BYTE PTR [SI],1     ; �業�� ���浪�
           JL    COr_1               ; �᫨ ���冷� < 1 {��� 楫�� ���}

           MOV   BX,7                ; ���⠭���� �窨,
           XOR   CX,CX               ; �᫨ ���� 楫�� ����
           ADD   CX,[SI]
COr_cyc1:  MOV   AL,Str[BX]          ; 横� ᤢ��� �����
           MOV   Str[BX+1],AL        ; ࠧ�冷� �����
           DEC   BX
           LOOP  COr_cyc1
           MOV   Str[BX+1],10        ; ������ �� ���� ����襣� �� �����
                                     ; ࠧ�冷� �窨
           JMP   COr_end

COr_1:     MOV   CX,1                ; ���⠭���� �窨
           SUB   CL,[SI]             ; �᫨ ��� 楫�� ���
           MOV   Str[8],0
COr_cyc2:  CALL  RotateRight
           MOV   Str[8],0
           LOOP  COr_cyc2
           MOV   Str[7],10           ; ������ �窨

COr_end:   POP   CX BX AX
           RET
ConvOrder  ENDP

; �८�ࠧ������ ��ப� �����/�뢮�� � ����⢥���� �᫮;
; ��ࠬ����: � ॣ���� di - ᬥ饭�� �᫠
StrToFloat PROC  NEAR
           CALL  FloatClear
           CMP   Str[10],0               ; �᫨ ��ப� ����,
           JE    STF_end                 ; � ����⢥���� �᫮ - �㫥���

           INC   DI                      ; ���᫥���
           CALL  CalcMant                ; �������
           DEC   DI

           CALL  NormMant                ; �� ��ଠ������
           CALL  CalcOrder               ; ���� ���浪�
STF_end:   RET
StrToFloat ENDP

; �८�ࠧ������ ����⢥����� �᫠
; � ��ப� �����/�뢮��; ��ࠬ����:
; � ॣ���� si - ᬥ饭�� �᫠
FloatToStr PROC  NEAR
           PUSH  [SI+3]                 ; ��࠭����
           PUSH  [SI+1]                 ; �������
           PUSH  [SI]                   ; � ���浪�
           PUSH  DI
           
           CALL  DispZero               ; ���⪠ ��ப� �뢮��

           CMP   WORD PTR [SI+3],0      ; �᫨ ������ �८�-
           JNE   FTS_1                  ; ࠧ㥬��� �᫠ = 0,
           CMP   WORD PTR [SI+1],0      ; � � ��ப� ����
           JE    FTS_end

FTS_1:     INC   SI                     ; ���室 � ��ࠡ�⪥ �������, �� �⮬
           MOV   Str[9],12              ; ��⠥���, �� ��� ������⥫쭠

           CALL  ConvMant              ; �८�ࠧ������
           DEC   SI                    ; �������
           CALL  ConvOrder             ; � ���浪�

FTS_4:     CMP   Str[0],0              ; 㤠����� ��������
           JNE   FTS_3                 ; �㫥� � ���� �������
           CALL  RotateRight           ; �������
           DEC   Str[10]
           JMP   FTS_4

FTS_3:     CMP   Str[0],10             ; �᫨ � ���� ��ப�
           JNE   FTS_end               ; �窠, � �� 㤠�����
           CALL  RotateRight           ; � ��� 䫠��
           MOV   Str[11],0             ; ������ �窨

FTS_end:   POP   DI
           POP   [SI]
           POP   [SI+1]
           POP   [SI+3]
           RET
FloatToStr ENDP

; ����� ��ப� �����/�뢮�� �� 1 ࠧ�� �����
RotateLeft PROC NEAR
           PUSH AX BX
           MOV BX,8
RSLcyc:    MOV AH,Str[BX-1]
           MOV Str[BX],AH
           DEC BX
           JNZ RSLcyc
           MOV Str[0],12
           POP BX AX
           RET
RotateLeft ENDP

; ����� ��ப� �����/�뢮�� �� 1 ࠧ�� ��ࠢ�
RotateRight PROC NEAR
           PUSH  AX BX

           XOR   BX,BX
RR_cyc:    MOV   AH,Str[BX+1]
           MOV   Str[BX],AH
           INC   BX
           CMP   BX,8
           JNE   RR_cyc
           MOV   Str[8],12
           POP   BX AX
           RET
RotateRight ENDP

; ���㫥��� ����⢥����� �᫠;
; ��ࠬ����: � di - ᬥ饭�� �᫠
FloatClear PROC  NEAR
           PUSH  BX

           XOR   BX,BX
FC_cyc:    MOV   BYTE PTR [DI+BX],0
           INC   BX                  ; ��
           CMP   BX,5                ; 5 ����
           JNE   FC_cyc

           POP   BX
           RET
FloatClear ENDP

; ��ॢ�� 楫��� �᫠ �� �६�
IntToTime  PROC  NEAR
           PUSH  AX BX CX DX SI
           LEA   SI,TimeCount
           
           MOV   AX,WORD PTR [SI]
           MOV   DX,WORD PTR [SI+2]
           MOV   BX,60000
           DIV   BX                              ; ᪮�쪮 �ᥣ� ����� ��諮
           MOV   DL,60
           DIV   DL                              ; ᪮�쪮 楫�� �ᮢ
           MOV   DH,AH
           
           AAM
           
           MOV   DL,AH
           XOR   AH,AH
           
           MOV   CL,4
           MUL   CL
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+4],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+6],AX

           MOV   AL,Dl
           XOR   AH,AH
           
           MOV   CL,4
           MUL   CL
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+2],AX
           
           MOV   AX,0FFB7h
           MOV   WORD PTR [DI+8],AX
           
           MOV   AL,DH
           AAM

           MOV   DL,AH
           XOR   AH,AH
           
           MOV   CL,4
           MUL   CL
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+14],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+16],AX

           MOV   AL,Dl
           XOR   AH,AH
           
           MOV   CL,4
           MUL   CL
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+10],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+12],AX

           POP   SI DX CX BX AX
           RET
IntToTime  ENDP

; ��ॢ�� �६��� � 楫�� �᫮
TimeToInt  PROC  NEAR
           LEA   SI,Str
           LEA   DI,TimeCount
           
           XOR   AX,AX
           MOV   AL,[SI+4]
           MOV   AH,10
           MUL   AH
           ADD   AL,[SI+3]
           MOV   AH,60
           MUL   AH                              ; �᫮ ����� � 楫�� ���
           
           MOV   DX,AX
           XOR   AX,AX
           MOV   AL,[SI+1]
           MOV   AH,10
           MUL   AH
           ADD   AL,[SI]                         ; �᫮ 楫�� �����
           ADD   AX,DX                           ; ��饥 �᫮ �����
           MOV   DX,60000
           MUL   DX                              ; ��饥 ��᫮ ����ᥪ㭤
           
           MOV   WORD PTR [DI],AX
           MOV   WORD PTR [DI+2],DX
           RET
TimeToInt  ENDP

; �८�ࠧ������ ��ࠧ� ���� � �᫮
DateToInt  PROC  NEAR
           LEA   SI,Str
           LEA   DI,DateCount
           MOV   CX,8
DTI_cyc:   MOV   AL,[SI]
           MOV   [DI],AL
           INC   SI
           INC   DI
           LOOP  DTI_cyc
           RET
DateToInt  ENDP           

; ����祭�� ��ࠧ� ����
IntToDate  PROC NEAR
           LEA   SI,DateCount
           ;LEA   DI,CheckImg+168

           MOV   AL,[SI+7]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+2],AX
           
           MOV   AL,[SI+6]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+4],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+6],AX
           
           MOV   AX,07FFFh
           MOV   WORD PTR [DI+7],AX
           
           MOV   AL,[SI+4]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+10],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+12],AX
           
           MOV   AL,[SI+3]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+14],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+16],AX

           MOV   AX,07FFFh
           MOV   WORD PTR [DI+17],AX

           MOV   AL,[SI+1]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+20],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+22],AX
           
           MOV   AL,[SI]
           MOV   AH,4
           MUL   AH
           LEA   BX,Digits
           ADD   BX,AX

           MOV   AX,WORD PTR CS:[BX]
           MOV   WORD PTR [DI+24],AX
           MOV   AX,WORD PTR CS:[BX+2]
           MOV   WORD PTR [DI+26],AX

           RET   
IntToDate  ENDP

; ���㣫���� ����⢥����� �᫠ �� ���� ������
; ��᫥ ����⮩
RoundFloat PROC  NEAR
           CMP   Error,0
           JNE   RF_end

           LEA   SI,Str
           
           CMP   BYTE PTR [SI+11],0FFh        ; ���� �� �窠
           JNZ   RF_end
           CMP   BYTE PTR [SI+1],0Ah
           JZ    RF_end
RF_cyc:    CMP   BYTE PTR [SI+2],0Ah
           JZ    RF_end
           XOR   AL,AL
           CMP   BYTE PTR [SI],5
           JB    RF_1
           ADD   BYTE PTR [SI+1],1
           CMP   BYTE PTR [SI+1],10
           JNZ   RF_1
           MOV   BYTE PTR [SI+1],0
           ADD   BYTE PTR [SI+2],1
RF_1:      CALL  RotateRight
           JMP   RF_cyc

RF_end:    RET
RoundFloat ENDP