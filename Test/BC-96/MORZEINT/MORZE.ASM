Name Interpretater_of_the_code_Morze


PortInp EQU 0Fh ; ��p� �����
PortVel EQU 0Fh ; ��p� �뢮��
PortSym EQU 0Fh ; ������⢮ ��p⮢ �뢮�� � �����ᨭ⥧�p��饬 ����,
                ; ��稭�� � �㫥����

InStart EQU 1h  ; ���祭�� � ����p� ��p� ����᪠
VelInc  EQU 2h  ; ���祭�� � ����p� ��p� 㢥��祭�� ᪮p���
VelDec  EQU 4h  ; ���祭�� � ����p� ��p� 㬥��襭�� ᪮p���
InpPoin EQU 10h ; ���祭�� � ����p� ��p� ����� �窨
InpDash EQU 20h ; ���祭�� � ����p� ��p� ����� �p�
KeyGear EQU 80h ; ���祭�� � ����p� ��p� ���� ��p����

BegVel  EQU 5h  ; ���祭�� ��砫쭮� ᪮p���
VelMin  EQU 1h  ; ���祭�� �������쭮� ᪮p���
VelMax  EQU 9h  ; ���祭�� ���ᨬ��쭮� ᪮p���
None    EQU 0h  ; ���祭�� ������⢨� ᨣ���� � ��p�� �����, �p�� 祣�-����
BegG    EQU 80h ; ���祭�� ��⮢���� ��� ��砫� ��p����
PortRdy EQU 1h  ; ���祭�� ��p� ��⮢����
ClrVel  EQU 0FCh; ���祭�� ��� ���⪨ ���p�� ������ p��p冷� Flag
RatProp EQU 2h  ; �����樥�� �p���p樮���쭮�� ��� ��宦����� ⨪��
RatVel  EQU 0Ah ; �����樥�� �p���p樮���쭮�� ��� ��宦����� ᪮p���
RatAddr EQU 5h  ; �����樥�� �p���p樮���쭮�� ��� ��宦����� ��p��
TimeSym EQU 3h  ; ���祭�� �p����� ����� ᨬ������ � ᫮��,
                ; p���� �p� - 3 ������� �p�����
TimeWor EQU 5h  ; ���祭�� �p����� ����� ᫮����
                ; ���祭�� �p����� ����� ᨣ������ � ᨬ���� ��p�������� ���
                ; �窠 - 1 ������ �p�����
SymbErr EQU 3Fh ; ���祭�� ᨬ���� �訡��
SymbCor EQU 1Fh ; ���祭�� ���ᨬ��쭮�� ���� �p����쭮�� ᨬ����
SymbAcc EQU 1h  ; ��� Symbol �� ᤢ�� ��� ���������� ���� �窨 ��� �p�
SymbGap EQU 5h  ; P����p �����ᨭ⥧�p��饩 ���p��� ᨬ���� �� ��p����⠫�
BetSGap EQU 1h  ; ������⢮ �p������ ����� ᨬ������ � ᫮��
BetWGap EQU 3h  ; ������⢮ �p������ ����� ᫮����
SLenMax EQU 5h  ; ���ᨬ��쭠� ����� ����p�������� ᨬ���� (� ����)
AddrErr EQU 40  ; ��p�� ᨬ���� �訡��

BitVelI EQU 1h  ; ��p�� ��� N0 � Flag
BitVelD EQU 2h  ; ��p�� ��� N1 � Flag
BitBegG EQU 10h ; ��p�� ��� N4 � Flag  Begin Gear
BitGap  EQU 20h ; ��p�� ��� N5 � Flag
BitStop EQU 40h ; ��p�� ��� N6 � Flag
BitLevL EQU 80h ; ��p�� ��� N7 � Flag  Level Last

Regim00 EQU 0h  ; P���� 0-0     Regime - p����
Regim01 EQU 1h  ; P���� 0-1
Regim10 EQU 2h  ; P���� 1-0
Regim11 EQU 3h  ; P���� 1-1


Data    SEGMENT AT 0BA00h
        Flag     DB ?

;       Flag
; ���������������Ŀ
; �����������������
;  � � � �     � � �����祭�� ᪮p���
;  � � � �     � �����襭�� ᪮p���
;  � � � �
;  � � � �
;  � � � � P��㫨p���� ��砫� ��p����
;  � � � ����������� �p�����
;  � � ��⠭����
;  � ��᫥���� �p����� �室���� ᨣ���� �� ���� ��p����

        TimeBeg  DW ?           ; H�砫쭮� �p���
        AmoTicks DB ?           ; ������⢮ ⨪��
        Symbol   DB ?           ; ����p������ ᨬ���
        SymbLeng DB ?           ; ����� ����p�������� ᨬ����
        Velocity DB ?           ; ������ ᪮p����
        Input    DB ?		; �������� ���祭�� � ���� �ࠢ�����
        RegimeU  DB ?		; ����� �஢��
        RegimeD  DB ?		; ����� ���⥫쭮��
        Addr     DB ?		; ���� ���ᨢ� ᮢ���襣� ᨬ����
        Ready    DB ?		; ����� ��⮢���� ��।��

        TablAddr DB 6 DUP (?)   ; ������ ��砫��� ��p�ᮢ � ᨬ����� �� ABC
        Matrix   DB 16 DUP (?)  ; ���p�� �뢮��
        Morze    DB 41 DUP (5 DUP(?))
				; P��������� ᨬ���� ��� �⮡p������
                                ; ���p�� ᨬ���� p����p�� 5x7
Data    ENDS


Steck   SEGMENT AT 0BA80h
        DW  42 DUP(?)
        StkTop LABEL WORD
Steck   ENDS


Code    SEGMENT
        ASSUME CS:Code,DS:Data,ES:Data,SS:Steck

        ; ���ᨢ ����� ᨬ�����
        SCode   DB 1 DUP (0h,1h,0h,1h,2h,3h,0h,1h,2h,3h,4h,5h,6h,7h,0h,1h,2h,3h,4h,5h,6h,8h,9h,0Ah,0Bh,0Ch,0Dh,0Eh,0Fh,0h,1h,3h,4h,7h,0Fh,10h,18h,1Ch,1Eh,1Fh,3Fh)
        ; ���ᨢ ������祭�� ᪮p��⥩
        VelArr  DB 1 DUP (0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7Fh,5Fh)


InitTablVel PROC NEAR
        MOV TablAddr[0],0	; ���樠������ ⠡���� ���ᮢ
        MOV TablAddr[1],2	; ����� ᨬ�����
        MOV TablAddr[2],6
        MOV TablAddr[3],14
        MOV TablAddr[4],29
        MOV TablAddr[5],40

        MOV  Velocity,BegVel	; ���樠������ ��砫쭮� ᪮���
        RET
InitTablVel ENDP


InitABC PROC NEAR       ; ABC - ��䠢��
        MOV  Morze[0][0],49h ; �
        MOV  Morze[0][1],49h	; ���樠������ ��䠢�� � �������� ���,
        MOV  Morze[0][2],49h	; �.�. ���ᨢ� ������祭�� ᨬ�����
        MOV  Morze[0][3],49h
        MOV  Morze[0][4],7Fh

        MOV  Morze[5][0],1h ; �
        MOV  Morze[5][1],1h
        MOV  Morze[5][2],7Fh
        MOV  Morze[5][3],1h
        MOV  Morze[5][4],1h

        MOV  Morze[10][0],7Fh ; �,�
        MOV  Morze[10][1],4h
        MOV  Morze[10][2],8h
        MOV  Morze[10][3],10h
        MOV  Morze[10][4],7Fh

        MOV  Morze[15][0],7Eh ; �
        MOV  Morze[15][1],9h
        MOV  Morze[15][2],9h
        MOV  Morze[15][3],9h
        MOV  Morze[15][4],7Eh

        MOV  Morze[20][0],7Fh ; H
        MOV  Morze[20][1],8h
        MOV  Morze[20][2],8h
        MOV  Morze[20][3],8h
        MOV  Morze[20][4],7Fh

        MOV  Morze[25][0],7Fh ; �
        MOV  Morze[25][1],2h
        MOV  Morze[25][2],4h
        MOV  Morze[25][3],2h
        MOV  Morze[25][4],7Fh

        MOV  Morze[30][0],22h ; �
        MOV  Morze[30][1],41h
        MOV  Morze[30][2],41h
        MOV  Morze[30][3],41h
        MOV  Morze[30][4],3Eh

        MOV  Morze[35][0],7Fh ; �
        MOV  Morze[35][1],48h
        MOV  Morze[35][2],48h
        MOV  Morze[35][3],48h
        MOV  Morze[35][4],4Fh

        MOV  Morze[40][0],6h ; P
        MOV  Morze[40][1],9h
        MOV  Morze[40][2],9h
        MOV  Morze[40][3],9h
        MOV  Morze[40][4],7Fh

        MOV  Morze[45][0],36h ; �
        MOV  Morze[45][1],49h
        MOV  Morze[45][2],49h
        MOV  Morze[45][3],49h
        MOV  Morze[45][4],7Fh

        MOV  Morze[50][0],60h ; �
        MOV  Morze[50][1],3Fh
        MOV  Morze[50][2],21h
        MOV  Morze[50][3],3Fh
        MOV  Morze[50][4],60h

        MOV  Morze[55][0],41h ; �
        MOV  Morze[55][1],22h
        MOV  Morze[55][2],14h
        MOV  Morze[55][3],8h
        MOV  Morze[55][4],7Fh

        MOV  Morze[60][0],1h ; �
        MOV  Morze[60][1],1h
        MOV  Morze[60][2],1h
        MOV  Morze[60][3],1h
        MOV  Morze[60][4],7Fh

        MOV  Morze[65][0],7Fh ; �
        MOV  Morze[65][1],41h
        MOV  Morze[65][2],41h
        MOV  Morze[65][3],41h
        MOV  Morze[65][4],7Fh

        MOV  Morze[70][0],63h ; �
        MOV  Morze[70][1],14h
        MOV  Morze[70][2],8h
        MOV  Morze[70][3],14h
        MOV  Morze[70][4],63h

        MOV  Morze[75][0],77h ; �
        MOV  Morze[75][1],8h
        MOV  Morze[75][2],7Fh
        MOV  Morze[75][3],8h
        MOV  Morze[75][4],77h

        MOV  Morze[80][0],0Fh ; �
        MOV  Morze[80][1],9h
        MOV  Morze[80][2],7Fh
        MOV  Morze[80][3],9h
        MOV  Morze[80][4],0Fh

        MOV  Morze[85][0],7Fh ; �
        MOV  Morze[85][1],41h
        MOV  Morze[85][2],7Fh
        MOV  Morze[85][3],8h
        MOV  Morze[85][4],7Fh

        MOV  Morze[90][0],7Fh ; �
        MOV  Morze[90][1],1h
        MOV  Morze[90][2],1h
        MOV  Morze[90][3],1h
        MOV  Morze[90][4],7Eh

        MOV  Morze[95][0],7Fh ; �
        MOV  Morze[95][1],9h
        MOV  Morze[95][2],19h
        MOV  Morze[95][3],29h
        MOV  Morze[95][4],46h

        MOV  Morze[100][0],7Fh ; �
        MOV  Morze[100][1],1h
        MOV  Morze[100][2],1h
        MOV  Morze[100][3],1h
        MOV  Morze[100][4],7Fh

        MOV  Morze[105][0],30h ; �
        MOV  Morze[105][1],49h
        MOV  Morze[105][2],49h
        MOV  Morze[105][3],49h
        MOV  Morze[105][4],7Fh

        MOV  Morze[110][0],30h ; �,�
        MOV  Morze[110][1],48h
        MOV  Morze[110][2],48h
        MOV  Morze[110][3],48h
        MOV  Morze[110][4],7Fh

        MOV  Morze[115][0],60h ; �
        MOV  Morze[115][1],3Fh
        MOV  Morze[115][2],20h
        MOV  Morze[115][3],20h
        MOV  Morze[115][4],3Fh

        MOV  Morze[120][0],7Fh ; �
        MOV  Morze[120][1],0h
        MOV  Morze[120][2],78h
        MOV  Morze[120][3],48h
        MOV  Morze[120][4],7Fh

        MOV  Morze[125][0],36h ; � (�㪢�)
        MOV  Morze[125][1],49h
        MOV  Morze[125][2],49h
        MOV  Morze[125][3],49h
        MOV  Morze[125][4],22h

        MOV  Morze[130][0],7Fh ; �
        MOV  Morze[130][1],20h
        MOV  Morze[130][2],3Fh
        MOV  Morze[130][3],20h
        MOV  Morze[130][4],3Fh

        MOV  Morze[135][0],7Fh ; �
        MOV  Morze[135][1],8h
        MOV  Morze[135][2],8h
        MOV  Morze[135][3],8h
        MOV  Morze[135][4],0Fh

        MOV  Morze[140][0],7Fh ; �
        MOV  Morze[140][1],40h
        MOV  Morze[140][2],7Fh
        MOV  Morze[140][3],40h
        MOV  Morze[140][4],7Fh

        MOV  Morze[145][0],31h ; 5
        MOV  Morze[145][1],49h
        MOV  Morze[145][2],49h
        MOV  Morze[145][3],49h
        MOV  Morze[145][4],4Fh

        MOV  Morze[150][0],7Fh ; 4
        MOV  Morze[150][1],8h
        MOV  Morze[150][2],9h
        MOV  Morze[150][3],0Ah
        MOV  Morze[150][4],0Ch

        MOV  Morze[155][0],33h ; 3 (��p�)
        MOV  Morze[155][1],4Dh
        MOV  Morze[155][2],49h
        MOV  Morze[155][3],49h
        MOV  Morze[155][4],21h

        MOV  Morze[160][0],3Eh ; �
        MOV  Morze[160][1],49h
        MOV  Morze[160][2],49h
        MOV  Morze[160][3],41h
        MOV  Morze[160][4],22h

        MOV  Morze[165][0],42h ; 2
        MOV  Morze[165][1],45h
        MOV  Morze[165][2],49h
        MOV  Morze[165][3],51h
        MOV  Morze[165][4],62h

        MOV  Morze[170][0],40h ; 1
        MOV  Morze[170][1],40h
        MOV  Morze[170][2],7Fh
        MOV  Morze[170][3],42h
        MOV  Morze[170][4],44h

        MOV  Morze[175][0],32h ; 6
        MOV  Morze[175][1],49h
        MOV  Morze[175][2],49h
        MOV  Morze[175][3],49h
        MOV  Morze[175][4],3Eh

        MOV  Morze[180][0],7h ; 7
        MOV  Morze[180][1],9h
        MOV  Morze[180][2],11h
        MOV  Morze[180][3],21h
        MOV  Morze[180][4],41h

        MOV  Morze[185][0],36h ; 8
        MOV  Morze[185][1],49h
        MOV  Morze[185][2],49h
        MOV  Morze[185][3],49h
        MOV  Morze[185][4],36h

        MOV  Morze[190][0],3Eh ; 9
        MOV  Morze[190][1],49h
        MOV  Morze[190][2],49h
        MOV  Morze[190][3],49h
        MOV  Morze[190][4],26h

        MOV  Morze[195][0],3Eh ; 0
        MOV  Morze[195][1],41h
        MOV  Morze[195][2],41h
        MOV  Morze[195][3],41h
        MOV  Morze[195][4],3Eh

        MOV  Morze[200][0],6h ; ?
        MOV  Morze[200][1],9h
        MOV  Morze[200][2],51h
        MOV  Morze[200][3],1h
        MOV  Morze[200][4],2h
	OR   Flag,BitStop
        RET
InitABC ENDP


Prepare PROC NEAR       ; Prepare - �����⮢��
        TEST Flag,BitStop
        JZ   PEnd
        XOR  AX,AX
        MOV  Flag,AH		; ���⪠ ��� ��६�����
        MOV  TimeBeg,AX
        MOV  AmoTicks,AH
        MOV  Symbol,AH
        MOV  SymbLeng,AH
        MOV  Input,AH
        MOV  RegimeU,AH
        MOV  RegimeD,AH
        MOV  Addr,AH
        MOV  Ready,AH
	MOV  AL,BitStop
	NOT  AL
	AND  Flag,AL
        MOV  AL,Matrix[PortRdy] ; �뢮� ᨣ���� "����������", �᫨ ⠪����
        OUT  PortRdy,AL		; �������
PEnd:
        RET
Prepare ENDP


InputKbd PROC NEAR
        IN   AL,PortInp		; ���� � ���� �ࠢ�����
        MOV  Input,AL		; ������ ���祭�� � Input
        RET
InputKbd ENDP


StartVel PROC NEAR
        CMP  Ready,Regim00
        JNE  SVEnd
        CMP  Input,InStart
        JNE  SV2
        XOR  CH,CH		; �᫨ ����� ������ "������ ��������",
        XOR  AL,AL		; � ���⪠ �����ᨭ⥧����饩 ������
        XOR  BH,BH		; ��� ���ᨢ� Matrix, ⠪ � ��࠭�
        MOV  CL,PortSym
SV1:
        MOV  DX,CX
        DEC  DL
        MOV  BL,DL
        MOV  Matrix[BX],AL
        OUT  DX,AL
        LOOP SV1
        MOV  AL,BegG
        OUT  PortRdy,AL
        MOV  Ready,Regim01	; ��⠭���� ०��� ��⮢����
        JMP  SVEnd

SV2:
        CMP  Input,VelInc	; �᫨ ����� ������ "�������� +1",
        JNE  SV3		; � 㢥��祭�� ᪮��� �� �������
        TEST Flag,BitVelI
        JNZ  SVEnd
        CMP  Velocity,VelMax	; �ࠢ����� ᪮��� � ���ᨬ��쭮�
        JE   SVEnd		; �᫨ ࠢ��, � 㢥��祭�� �� �ந�室��
        INC  Velocity
        OR   Flag,BitVelI
        JMP  SVEnd

SV3:
        CMP  Input,VelDec	; �᫨ ����� ������ "�������� -1",
        JNE  SVEnd		; � 㬥��襭�� ᪮��� �� �������
        TEST Flag,BitVelD
        JNZ  SVEnd
        CMP  Velocity,VelMin	; �ࠢ����� ᪮��� � �������쭮�
        JE   SVEnd		; �᫨ ࠢ��, � 㬥��襭�� �� �ந�室��
        DEC  Velocity
        OR   Flag,BitVelD

SVEnd:
        RET
StartVel ENDP


VelOut PROC NEAR
        MOV  BL,Velocity	; �⮡ࠦ���� ⥪�饩 ᪮���
        XOR  BH,BH
        MOV  AL,VelArr[BX-1]
        OUT  PortVel,AL
        RET
VelOut ENDP


KeyPress PROC NEAR
        CMP  Ready,Regim01
        JNE  KPEnd
        CMP  Input,KeyGear	; �᫨ ����� ������ "���� ��������",
        JNE  KP3		; � �롮� ०���� �஢��
        TEST Flag,BitLevL	; Regim01 ��� Regim11
        JNZ  KP1		; � ����ᨬ��� �� �।��饣� �஢��
        OR   Flag,BitLevL
        MOV  RegimeU,Regim01
        JMP  KP2
KP1:
        CMP  Symbol,SymbErr
        JE   KP2
        MOV  RegimeU,Regim11
KP2:
        OR   Flag,BitBegG

KP3:
        TEST Flag,BitBegG
        JZ   KPEnd
        CMP  Input,None		; �᫨ �� ����� ������ "���� ��������",
        JNE  KPEnd		; � �롮� ०���� �஢��
        TEST Flag,BitStop	; Regim00 ��� Regim10
        JNZ  KPEnd		; � ����ᨬ��� �� �।��饣� �஢��
        TEST Flag,BitLevL
        JZ   KP4
        MOV  AL,BitLevL
        NOT  AL
        AND  Flag,AL
        MOV  RegimeU,Regim10
        JMP  KPEnd
KP4:
        MOV  RegimeU,Regim00

KPEnd:
        RET
KeyPress ENDP


Ctrl    PROC NEAR
        CMP  Ready,Regim01
        JNE  CEnd
        TEST Flag,BitBegG
        JZ   CEnd
        CMP  RegimeU,Regim01	; �ࠢ����� ⥪�饣� ०��� �஢�� 
        JE   C1			; � ���室 � ����ᨬ��� �� ��� ���祭��
        CMP  RegimeU,Regim10
        JE   C2
        CMP  RegimeU,Regim11
        JE   C3
			; �㫥��� ०�� �஢��
        CMP  RegimeD,Regim11	; �᫨ ०�� ���⥫쭮�� = ���쥬�,
        JNE  CEnd		; � ��⠭���������� ��� ��⠭���� � Flag
        OR   Flag,BitStop
        JMP  CEnd
C1:			; ���� ०�� �஢��
        CMP  RegimeD,Regim00
        JE   C1_1
        CMP  RegimeD,Regim10
        JNE  C1_1		; �᫨ ०�� ���⥫쭮�� 2-��,
        OR   Flag,BitGap	; � ��⠭���� ��� ����������� �஡���
        CMP  RegimeD,Regim11	; �᫨ ०�� ���⥫쭮�� 3-��,
        JNE  C1_1		; � ��⠭���� ��� ��⠭����
        OR   Flag,BitStop
C1_1:
        MOV  AmoTicks,None	; ���㫥��� ������⢠ ⨪��
        JMP  CEnd		; �� ��� ०���� ���⥫쭮��
C2:			; ��ன ०�� �஢��
        MOV  AmoTicks,None	; ���㫥��� ������⢠ ⨪��
        CMP  RegimeD,Regim01	; �� ��� ०���� ���⥫쭮��
        JA   C2_1
        JMP  CEnd
C2_1:
        MOV  Symbol,SymbErr	; ������ � Symbol ᨬ���� �訡��,
        JMP  CEnd		; �᫨ ०�� ���⥫쭮�� 2-�� ��� 3-��
C3:			; ��⨩ ०�� �஢��
        CMP  RegimeD,Regim01	; ������ � Symbol ᨬ���� �訡��,
        JA   C2_1		; �᫨ ०�� ���⥫쭮�� 3-��
CEnd:
        RET
Ctrl    ENDP


TimeTicks PROC NEAR
        CMP  Ready,Regim01
        JNE  TTEnd
        TEST Flag,BitBegG
        JZ   TTEnd
        MOV  AX,2C00h
        INT  21h		; DOS ���뢠���� ��६ ⥪�饥 �६�
        CMP  DX,TimeBeg		; � �ࠢ������ ��� � ��砫�� �६����
        JE   TT1
        INC  AmoTicks		; �᫨ ��� �⫨�� ��� �� ��㣠,
        MOV  TimeBeg,DX		; � ���६�������� ������⢮ ⨪��
TT1:

        MOV  AL,RatVel		; �� �������� ⨪�� � ⥪�饩 ᪮���        
        SUB  AL,Velocity	; �� ��㫥 ��।������ ०�� ���⥫쭮��
        MOV  AH,RatProp
        MUL  AH
        CMP  AmoTicks,AL
        JA   TT2
        MOV  RegimeD,Regim00
        JMP  TTEnd
TT2:
        MOV  BL,AL
        MOV  AH,TimeSym
        MUL  AH
        CMP  AmoTicks,AL
        JA   TT3
        MOV  RegimeD,Regim01
        JMP  TTEnd
TT3:
        MOV  AL,BL
        MOV  AH,TimeWor
        MUL  AH
        CMP  AmoTicks,AL
        JA   TT4
        MOV  RegimeD,Regim10
        JMP  TTEnd
TT4:
        MOV  RegimeD,Regim11
TTEnd:
        RET
TimeTicks ENDP


ShlErr  PROC NEAR
        CMP  Ready,Regim01
        JNE  SEEnd
        TEST Flag,BitBegG
        JZ   SEEnd
        CMP  Symbol,SymbErr	; ��ନ஢���� Symbol � ����ᨬ���
        JE   SEEnd		; �� ��।�������� ०��� �஢��
        CMP  RegimeU,Regim10	; � ��।�������� ०��� ���⥫쭮��
        JNE  SEEnd
        CMP  RegimeD,Regim01
        JA   SEEnd
        INC  SymbLeng		; ��ନ஢����:
        CMP  SymbLeng,SLenMax	; ���६���஢���� �����,
        JA   SE1		; ������ � ����訩 ��� Symbol 0-�窨
        SHL  Symbol,SymbAcc	; ��� 1-��
        MOV  AL,RegimeD
        ADD  Symbol,AL		; �ࠧ� �ந�室�� ����஫� �訡�� �����:
        CMP  Symbol,SymbCor	; ����஫� �� ������ ᨬ����
        JBE  SEEnd		; � ����஫� �� ���祭��� ᨬ����,
SE1:				; �.�. ᫥����� �� ��� ���४⭮����
        MOV  Symbol,SymbErr
SEEnd:
        RET
ShlErr  ENDP


ErrOut  PROC NEAR		; ����஫� �訡�� ����� � �뢮� ᨬ����
        CMP  Ready,Regim01
        JNE  Err0
        TEST Flag,BitBegG
        JZ   Err0
        CMP  RegimeU,Regim00	; � ����ᨬ��� �� ��।�������� ०��� �஢��
        JE   Err0_0		; � ��।�������� ०��� ���⥫쭮��
        CMP  RegimeU,Regim01
        JE   Err0_1
Err0:
        LEA  AX,EOEnd
        JMP  AX
Err0_0:
        CMP  RegimeD,Regim11
        JE   Err1
        JMP  Err0
Err0_1:
        CMP  RegimeD,Regim00
        JE   Err0
Err1:
        CMP  Symbol,SymbErr	; �᫨ ᨬ��� ���� ᨬ����� �訡��,
        JE   Err5		; � ���室 �� ���� ����� ����
        CMP  SymbLeng,SLenMax	; ᨬ���� �訡��
        JA   Err5
Err2:
        LEA  BX,TablAddr	; ��।������ �࠭�� ���᪠
        MOV  AL,SymbLeng	; ��ନ஢������ ᨬ���� 
        XLAT			; �.�. ������� � ���孥�� ����
        MOV  CL,AL
        MOV  AL,SymbLeng
        DEC  AL
        XLAT
        MOV  BL,AL
Err3:
        CMP  CL,BL		; ���� ᨬ����, ��⥬ ��宦����� ��� ����
        JE   Err5		; � ���ᨢ� ����� ᨬ�����, 
        MOV  AL,SCode[BX]	; ��稭�� � ������� ����
        CMP  AL,Symbol          ; �p������� ᨬ�����
        JE   Err4
        INC  BL
        JMP  Err3
Err4:
        MOV  Addr,BL		; ������ ���� �� ᮢ������� ����� ᨬ�����,
        JMP  Out1
Err5:
        MOV  Addr,AddrErr 	; ���� ������ ��p�� ᨬ��� �訡�� "?"

Out1:
        TEST Flag,BitGap	; ��।������ ���� ����� ᨬ������
        JZ   Out2
        MOV  AH,BetWGap
        JMP  Out3
Out2:
        MOV  AH,BetSGap
Out3:
        ADD  AH,SymbGap
        MOV  CX,PortSym
        SUB  CL,AH
        XOR  DH,DH
Out4:
        MOV  DL,CL
        DEC  DL
        MOV  BX,DX
        MOV  AL,Matrix[BX]	; ��������� "����饩 ��ப�"
        ADD  DL,AH
        MOV  BX,DX
        MOV  Matrix[BX],AL
        OUT  DX,AL
        LOOP Out4
        MOV  CL,AH
        SUB  CL,SymbGap
        XOR  AL,AL
Out5:
        MOV  DL,CL
        ADD  DL,SymbGap
        DEC  DL
        MOV  BX,DX
        MOV  Matrix[BX],AL
        OUT  DX,AL
        LOOP Out5
        MOV  CL,SymbGap
        MOV  BL,Addr
        MOV  AL,BL
        MOV  AH,RatAddr		; ��।������ ���� ���ᨢ� �⮡ࠦ����
        MUL  AH			; ᨬ����� �� ����� ���ᨢ� ����� ᨬ�����
        MOV  BX,AX
        PUSH SI
Out6:
        MOV  DL,CL
        DEC  DL
        MOV  SI,DX
        MOV  AL,Morze[BX][SI]
        PUSH BX
        MOV  BX,DX
        MOV  Matrix[BX],AL	; �뢮� ᨬ���� �� ��࠭ � � ���ᨢ Matrix
        POP  BX
        OUT  DX,AL
        LOOP Out6
        POP  SI
        MOV  AL,Matrix[PortRdy]
        ADD  AL,BegG
        OUT  PortRdy,AL
        MOV  SymbLeng,None
        MOV  Symbol,NoNe
EOEnd:
        MOV  AL,BitGap		; ���⨥ ��� ����������� �஡���
        NOT  AL
        AND  Flag,AL
        RET
ErrOut  ENDP


Clear PROC NEAR
        CMP  Input,None	 ; �᫨ �� ���� �� ������ ���� ����� �� �뫠 
        JNE  ClrEnd	 ; �����, � �ந�室��
        AND  Flag,ClrVel ; ���⪠ ���� ������ p��p冷� � Flag
ClrEnd:
        RET
Clear ENDP


Begin:
        MOV  AX,Data            ; ���⥬���
        MOV  DS,AX              ; �����⮢��
        MOV  AX,Steck
        MOV  SS,AX
        LEA  SP,StkTop

        CALL InitTablVel        ; ���樠������ ⠡���� ᪮p��⥩ � ᪮p���
        CALL InitABC            ; ���樠������ ��䠢��
B1:
        CALL Prepare            ; �����⮢��, ���㫥��� ��� ��p�������
        CALL InputKbd           ; ���� � ��������p�
        CALL StartVel           ; �������� �� ��砫�� ��p����
        CALL VelOut             ; � p��㫨p������� ᪮p���
        CALL KeyPress           ; �������� �� ���箬 ��p����
        CALL ShlErr             ; ����� � ����p��� �� Symbol
        CALL TimeTicks          ; ������ ⨪��
        CALL Ctrl               ; ����p��� p������
        CALL ErrOut             ; ����p��� �訡�� �����, � �뢮� Symbol
        CALL Clear              ; ���⪠ ��p������� ��⮢ Flag
        JMP  B1

        ORG  07F0h		; �����饭�� ���⮢�� �窨

Start:
        JMP  Begin

Code    ENDS
        END  Start
