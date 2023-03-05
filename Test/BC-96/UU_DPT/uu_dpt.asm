	NAME	uudpt
KbdPort0=0
ModePort1=1
SOutPort0=0
FOutPort1=1
FOutPort2=2
FOutPort3=3
FOutPort4=4
PROutPort=5
SOutPort6=6
TOutPort7=7
TOutPort8=8
TOutPort9=9
TOutPort10=10
TOutPort11=11
TOutPort12=12
MOutPort13=13
KOutPort14=14
KOutPort15=15
Data	SEGMENT AT 0BA00H
	FreqTable DW 100 DUP (?)
	DelTable DW 100 DUP (?)
	KeyTable DB 100 DUP (?)
	TrfTable1 DB 10 DUP (?)
	TrfTable2 DW 17 DUP (?)
	Mode DB ?
	State DB ?
	RotDir DB ?
	InType DB ?
	KbdImage DW ?
	NextDig DB ?
	Frequenc DB 2 DUP (?)
	Turn DB 3 DUP (?)
	CodPosRot DB ?
	PCodPosRot DB ?
	Keyhol_BCD DB ?
	FreqDisp DB 4 DUP (?)
	TurnDisp DB 6 DUP (?)
	KeyDisp DB 2 DUP (?)
	EmpKbd DB ?
Data	ENDS
Stack	SEGMENT AT 0BA80H
	DW 100 DUP (?)
StkTop	LABEL WORD		
Stack	ENDS
Code	SEGMENT
	ASSUME	CS:Code,DS:Data,SS:Stack

;����� "�㭪樮���쭠� �����⮢��"
FuncPrep PROC NEAR
	;���� �ନ஢���� ⠡���� ����
	LEA BX,FreqTable                ;����㧪� �������� ���� �����
	MOV AX,0050H     		;�������� �������쭮� �����
	MOV [BX],AX			;������ �����
	INC BX				;����䨪��� 
	INC BX				;����
	MOV CL,1			;���稪 横��=1
FP1:	CMP CL,LENGTH FreqTable		;�� ������ ?
	JE  FP2	 			;���室,�᫨ ��
	XCHG AH,AL	 		;�����祭��
	ADD AL,01H	 		;
	DAA	 	 		;
	XCHG AH,AL	 		;����� �� ���� 蠣
	MOV [BX],AX			;������ �����	
	INC BX				;����䨪��� 
	INC BX				;����
	INC CL				;� ���稪� 横��
	JMP FP1
	;���� �ନ஢���� ⠡���� ����থ�			
FP2:	LEA BX,DelTable 		;����㧪� �������� ���� ⠡����
					;����থ�
	MOV AX,1000			;�������� ���ᨬ��쭮� ����প�
	MOV CX,LENGTH DelTable		;���稪 横��=��� ����⮢
					;⠡���� ����থ�
FP3:	MOV [BX],AX			;������ ����প�
	SUB AX,10			;�����襭�� ����প� �� ���� 蠣
	INC BX				;����䨪��� 
	INC BX				;����
	LOOP FP3			;�� ������ ? ���室,�᫨ ���
	;���� �ନ஢���� ⠡���� ᪢�����⥩	
FP4:	LEA BX,KeyTable 		;����㧪� �������� ���� ⠡����
					;᪢�����⥩
	MOV AL,99H     			;�������� ���ᨬ��쭮�� ���祭��
					;᪢������
	MOV [BX],AL			;������ ᪢������
	INC BX				;����䨪��� ����
	MOV CL,1			;���稪 横��=1
FP5:	CMP CL,LENGTH KeyTable		;�� ������ ?
	JE FP6				;���室,�᫨ ��
	MOV [BX],AL			;������ ᪢������
	SUB AL,1			;�����襭�� ᪢������ �� ���� 蠣
	DAS				;���४��
	INC BX				;����䨪��� ���� 
	INC CL				;� ���稪� 横��
	JMP FP5
FP6:	;��ନ஢���� ⠡���� �८�ࠧ������
	;��� �뢮�� �᫮��� ���ଠ樨
	MOV BYTE PTR TrfTable1,3FH
	MOV BYTE PTR TrfTable1+1,0CH
	MOV BYTE PTR TrfTable1+2,76H
	MOV BYTE PTR TrfTable1+3,5EH
	MOV BYTE PTR TrfTable1+4,4DH
	MOV BYTE PTR TrfTable1+5,5BH
	MOV BYTE PTR TrfTable1+6,7BH
	MOV BYTE PTR TrfTable1+7,0EH
	MOV BYTE PTR TrfTable1+8,7FH
	MOV BYTE PTR TrfTable1+9,5FH
	;��ନ஢���� ⠡���� �८�ࠧ������ 
	;��� �뢮�� ���-ᨣ����
	MOV WORD PTR TrfTable2,0000H
	MOV WORD PTR TrfTable2+2,0FFFFH
	MOV WORD PTR TrfTable2+4,5555H
	MOV WORD PTR TrfTable2+6,9249H
	MOV WORD PTR TrfTable2+8,1111H
	MOV WORD PTR TrfTable2+10,8421H
	MOV WORD PTR TrfTable2+12,1041H
	MOV WORD PTR TrfTable2+14,4081H
	MOV WORD PTR TrfTable2+16,0101H
	MOV WORD PTR TrfTable2+18,0201H
	MOV WORD PTR TrfTable2+20,0401H
	MOV WORD PTR TrfTable2+22,0801H
	MOV WORD PTR TrfTable2+24,1001H
	MOV WORD PTR TrfTable2+26,2001H
	MOV WORD PTR TrfTable2+28,4001H
	MOV WORD PTR TrfTable2+30,8001H
	MOV WORD PTR TrfTable2+32,0001H
	;���樠������ ����᪨� ������
	MOV State,00H			;����ﭨ�="���ᨢ���"
	MOV RotDir,00H			;���ࠢ����� ��饭��="�����"
	MOV InType,00H			;��� �����="�����"
	MOV Frequenc,0000H		;�����=0
	LEA BX,Turn			;���-
	MOV CX,Length Turn		;�-
FP7:	MOV BYTE PTR [BX],00H		;��
	INC BX				;=
	LOOP FP7			;0
	MOV Keyhol_BCD,00H		;����������=0
	MOV CodPosRot,01H		;������ ���=ᥣ���� A
	MOV PCodPosRot,01H		;�।���� ������=⮬� ��
	RET
FuncPrep ENDP

;����� "���� ०����"
ModeInput PROC NEAR
	MOV State,00H   ;����ﭨ�="���ᨢ���"
	IN AL,ModePort1	;���� ��४���⥫��
	TEST AL,04H	;����ﭨ�="��⨢���" ?
	JZ MI0		;���室,�᫨ ���
	MOV State,0FFH	;����ﭨ�="��⨢���"
	JMP SHORT MI4	
MI0:	TEST AL,08H	;���ࠢ����� ��饭��="�����" ?
	JZ MI1		;���室,�᫨ ���
	MOV RotDir,00H	;���ࠢ����� ��饭��="�����" 
	JMP SHORT MI4	;
MI1:	TEST AL,10H	;���ࠢ����� ��饭��="��ࠢ�" ?
	JZ MI2		;���室,�᫨ ���
	MOV RotDir,0FFH	;���ࠢ����� ��饭��="��ࠢ�" 
	JMP SHORT MI4	
MI2:	TEST AL,20H	;��� �����="�����" ?
	JZ MI3		;���室,�᫨ ���
	MOV InType,00H	;��� �����="�����" 
	JMP SHORT MI4	
MI3:	TEST AL,40H	;��� �����="������" ?
	JZ MI4		;���室,�᫨ ���
	MOV InType,0FFH	;��� �����="������" 
MI4:	RET
ModeInput ENDP

;����� "�뢮� ᮮ�饭�� � ���ࠢ����� ��饭�� � ⨯� �����"
RtDrInTpMesOut PROC NEAR
	MOV AL,01H	;����饭�� "���ࠢ����� ��饭��"="�����"
	CMP RotDir,00H	;"���ࠢ����� ��饭��"="�����"?
	JE RDITMO1	;���室,�᫨ ��
	MOV AL,02H	;����饭�� "���ࠢ����� ��饭��"="��ࠢ�"
RDITMO1:CMP InType,00H	;"��� �����"="�����"?
	JNE RDITMO2	;���室,�᫨ ���
	OR AL,04H	;����饭�� "���ࠢ����� ��饭��" � 
                        ;"��� �����"="�����"
	JMP RDITMO3
RDITMO2:OR AL,08H	;����饭�� "���ࠢ����� ��饭��" � 
                        ;"��� �����"="������"		
RDITMO3:OUT MOutPort13,AL;�뢮� ᮮ�饭��
	RET
RtDrInTpMesOut ENDP

;�����	"���� � ����������"
KbdInput PROC NEAR
	CMP State,00H   ;����ﭨ�="���ᨢ���" ?
	JNE KI3		;���室,�᫨ ���
	IN AL,ModePort1	;����
	MOV AH,AL	;
	IN AL,KbdPort0	;	
	AND AH,03H	;����������	
	CMP AX,0	;��������� ��⨢�஢��� ?
	JE KI2		;���室,�᫨ ���
	MOV KbdImage,AX	;������ ��ࠧ� ����������
KI1:	IN AL,ModePort1	;����	
	MOV AH,AL	;
	IN AL,KbdPort0	;	
	AND AH,03H	;����������	
	CMP AX,0	;��������� ��⨢�஢��� ?	
	JNE KI1		;���室,�᫨ ��
	JMP SHORT KI3	
KI2:	MOV KbdImage,AX	;������ ��ࠧ� ����������
KI3:	RET
KbdInput ENDP

;����� "����஫� ����� � ����������"
KbdInContr PROC NEAR
	MOV EmpKbd,00H  ;���⪠ 䫠�� ���⮩ ����������
	CMP KbdImage,0	;��ࠧ ���������� ���� ?
	JNE KIC1	;���室,�᫨ ���
	MOV EmpKbd,0FFH	;��⠭���� 䫠�� ���⮩ ����������
KIC1:	RET
KbdInContr ENDP

;����� "�८�ࠧ������ ��।��� ����"
NxtDigTrf PROC NEAR
	CMP EmpKbd,0FFH	;����� ���������?
	JE NDT3		;���室,�᫨ ��
	MOV AX,KbdImage	;�⥭�� ����������
	MOV CL,0	;���⪠ ������⥫� ���� ����
NDT1:	SHR AX,1	;�뤥����� ��� ����������
	JC NDT2		;��� ��⨢��?���室,�᫨ ��
	INC CL		;���६��� ���� ����
	JMP SHORT NDT1
NDT2:	MOV NextDig,CL	;������ ���� ����
NDT3:	RET
NxtDigTrf ENDP

;����� "��ନ஢���� ���ଠ樨 � ���ᨢ��� ���ﭨ�"
PsvStInfoForm PROC NEAR
	CMP State,00H           ;����ﭨ�=���ᨢ��� ?
	JNE PSIF5	        ;���室,�᫨ ���
	CMP EmpKbd,00H	        ;�� ����� ��������� ?
	JNE PSIF3               ;���室,�᫨ ���
	CMP InType,00H          ;��� �����="�����" ?
	JNE PSIF1               ;���室,�᫨ ���
	LEA BX,Frequenc		;��।�� ��ࠬ��஢ 
	MOV CH,LENGTH Frequenc	;��� ᤢ��� �����
	CALL SHL_4		;����� �� ��ࠤ� �����
	MOV AL,Frequenc         ;�⥭�� ����襣� ���� ᤢ���⮩ �����
	OR AL,NextDig           ;����祭�� ��।��� ���� � �����
	MOV Frequenc,AL         ;������ ����� �����
	JMP PSIF3               ;
PSIF1:	LEA BX,Turn             ;��।�� ��ࠬ��஢
	MOV CH,LENGTH Turn	;��� ᤢ��� ����⮢
	CALL SHL_4		;����� �� ��ࠤ� �����
	MOV AL,Turn		;�⥭�� ����襣� ���� ᤢ������ ����⮢
	OR AL,NextDig           ;����祭�� ��।��� ���� � ������
	MOV Turn,AL             ;������ ����� ����⮢
PSIF3:	MOV Keyhol_BCD,00H      ;����������=0
	MOV AL,CodPosRot        ;���࠭���� 
	MOV PCodPosRot,AL       ;����樨 ���
	MOV Mode,00H            ;�����="����� 1"
	CMP BYTE PTR Turn,00H   ;������=0 ?
	JNE PSIF4               ;
	CMP BYTE PTR Turn+1,00H ;
	JNE PSIF4               ;
	CMP BYTE PTR Turn+2,00H ;
	JNE PSIF4               ;
	JMP PSIF5               ;���室,�᫨ ��
PSIF4:	MOV Mode,0FFH           ;�����="����� 2"
PSIF5:	RET                     
PsvStInfoForm ENDP

;����� "����� ���ᨢ� ���� ����� �� ��ࠤ�"
SHL_4 PROC NEAR
;�室�� ��ࠬ����:
;       BX-������ ���� ᤢ�������� ���ᨢ�
;       CH-�᫮ ���� � ���ᨢ�
	XOR AH,AH   ;������ AH
	XOR DL,DL   ;������ DL
	MOV CL,4    ;���稪 ᤢ����=4
S1:	MOV AL,[BX] ;�⥭�� ��।���� ����
	SHL AX,CL   ;����� �� ��ࠤ� �����
	OR AL,DL    ;����祭�� ���襩 ��ࠤ� �।��饣� ����
	MOV [BX],AL ;������ ����
	MOV DL,AH   ;���࠭���� ���襩 ��ࠤ�
	XOR AH,AH   ;�ਥ���� �뤢������� ��ࠤ�=0
	INC BX      ;����䨪��� ����
	DEC CH      ;���६��� �᫠ ����
	JNZ S1      ;���室,�᫨ �� �� �����
        RET 
SHL_4 ENDP

;����� "��ନ஢���� ���ଠ樨 � ०��� 1"
Md1InfoForm PROC NEAR
	CMP State,0FFH              ;����ﭨ�="��⨢���" ?
	JNE M1IF2		    ;���室,�᫨ ���
	CMP Mode,00H		    ;�����="����� 1" ?
	JNE M1IF2		    ;���室,�᫨ ���
	CMP WORD PTR Frequenc,0000H ;�����=0 ?
	JNE M1IF1		    ;���室,�᫨ ���
	MOV Keyhol_BCD,00H	    ;����������=0
	JMP SHORT M1IF2             ;
M1IF1:	MOV AH,Frequenc+1	    ;��।�� ��ࠬ��஢
				    ;��� �८�ࠧ������ ���襣� ���� 
				    ;����� �� BCD-�ଠ� � ������
	CALL BCDTrans		    ;�८�ࠧ������ BCD-�ଠ� � ������
	MOV BL,AL		    ;��ନ஢���� ������ � ⠡��� 
	XOR BH,BH		    ;᪢�����⥩ � � ⠡��� ����থ�
	LEA SI,KeyTable		    ;����㧪� �������� ���� ⠡���� 
				    ;ᢠ����⥩
	MOV AL,[SI][BX]		    ;�롮ઠ ⥪�饩 ᪢������ �� ⠡����
	MOV Keyhol_BCD,AL	    ;������ ⥪�饩 ᪢������
	MOV AL,BL      	            ;��ନ஢���� 
	MOV DL,TYPE DelTable        ;ᬥ饭�� �����
	MUL DL		            ;�⭮�⥫쭮 �������� ����
	MOV BX,AX	            ;⠡���� ����থ�
	LEA SI,DelTable             ;����㧪� �������� ���� ⠡����
                                    ;����থ�
	MOV CX,[SI][BX]             ;�롮ઠ ⥪�饩 ����প� �� ⠡����=
                                    ;��।�� ��ࠬ��஢ ��� ������ 
				    ;�����⥫�
	CALL RotModul	            ;������ �����⥫�
M1IF2:  RET
Md1InfoForm ENDP

;����� "�८�ࠧ������ BCD-�ଠ� � ������"
BCDTrans PROC NEAR
;�室��� ��ࠬ���:
;	AH-���� � BCD-�ଠ�
;��室��� ��ࠬ���:
;	AL-������ ���� (१���� �८�ࠧ������)
	XOR AL,AL    ;������ ������⥫� १���� 
	MOV CX,8     ;���稪 横��=8
BT1:	SHR AX,1     ;����� �� ࠧ�� ��ࠢ�
	TEST AH,08H  ;���४�� �㦭� ?
	JZ BT2       ;���室,�᫨ ���
	MOV DL,AH    ;�뤥����� � DL
	AND DL,0F0H  ;���襩 ��ࠤ�
	AND AH,0FH   ;�뤥����� � AH ����襩 ��ࠤ�
	SUB AH,3     ;���४��
	OR AH,DL     ;��ꥤ������ � AH ���襩 
                     ;� ᪮�४�஢����� ����襩 ��ࠤ
BT2:	LOOP BT1     ;�� ࠧ��� ? ���室,�᫨ ���
	RET
BCDTrans ENDP

;����� "������ �����⥫�"
RotModul PROC NEAR
;�室��� ��ࠬ���:
;	CX-⥪��� ����প�
RM1:	LOOP RM1	  ;���� ����প�
	CMP RotDir,00H    ;��饭�� �����⥫�="�����" ?
	JNE RM3		  ;���室,�᫨ ���
	CMP CodPosRot,01H ;������ ���=ᥣ���� A ?
	JNE RM2		  ;���室,�᫨ ���
	MOV CodPosRot,20H ;������ ���=ᥣ���� F
	JMP SHORT RM5		  
RM2:	SHR CodPosRot,1   ;������ �� ���� ᥣ���� �����
	JMP SHORT RM5		  
RM3:  	CMP CodPosRot,20H ;������ ���=ᥣ���� F ?
	JNE RM4		  ;���室,�᫨ ���
	MOV CodPosRot,01H ;������ ���=ᥣ���� A
	JMP SHORT RM5 	  ;
RM4:	SHL CodPosRot,1   ;������ �� ���� ᥣ���� �����
	JMP SHORT RM5     ;
RM5:	RET
RotModul ENDP

;����� "��ନ஢���� ���ଠ樨 � ०��� 2"
Md2InfoForm PROC NEAR
	CMP State,0FFH		    ;����ﭨ�="��⨢���" ?
	JNE M2IF0		    ;���室,�᫨ ���
	CMP Mode,0FFH		    ;�����="����� 2" ?
	JNE M2IF2		    ;���室,�᫨ ���
	CMP BYTE PTR Turn,00H       ;��᫮ ����⮢=0 ?
	JNE M2IF1		    ;
	CMP BYTE PTR Turn+1,00H     ;	
	JNE M2IF1		    ;
	CMP BYTE PTR Turn+2,00H     ;
	JNE M2IF1		    ;���室,�᫨ ���
	MOV WORD PTR Frequenc,0000H ;�����=0
	MOV Keyhol_BCD,00H	    ;����������=0
M2IF0:	JMP SHORT M2IF2		    
M2IF1:	MOV AH,Turn+2 	         ;��।�� ��ࠬ��஢
				 ;��� �८�ࠧ������ ���襣� ���� ����⮢
				 ;�� BCD-�ଠ� � ������
	CALL BCDTrans		 ;�८�ࠧ������ BCD-�ଠ� � ������
	LEA SI,FreqTable	 ;����㧪� �������� ���� ⠡���� ����
	MOV DL,TYPE FreqTable    ;��ନ஢���� ᬥ饭�� �����
	MUL DL		         ;�⭮�⥫쭮 �������� ����
	MOV BX,AX	         ;⠡���� ����
	MOV AX,[SI][BX]		 ;�롮ઠ ⥪�饩 ����� �� ⠡����=
				 ;��।�� ��ࠬ��஢ ��� �८�ࠧ������
				 ;���襣� ���� ����� �� BCD-�ଠ� �
				 ;������
	MOV WORD PTR Frequenc,AX ;������ ⥪�饩 �����
	CALL BCDTrans		 ;�८�ࠧ������ BCD-�ଠ� � ������
	MOV BL,AL		 ;��ନ஢���� ������ � ⠡���
	XOR BH,BH		 ;᪢�����⥩ � � ⠡��� ����থ�
	LEA SI,KeyTable		 ;����㧪� �������� ���� ⠡���� 
				 ;᪢�����⥩
	MOV AL,[SI][BX]		 ;�롮ઠ ⥪�饩 ᪢������ �� ⠡����
	MOV Keyhol_BCD,AL	 ;������ ⥪�饩 ᪢������
	MOV AL,BL      	         ;��ନ஢���� 
	MOV DL,TYPE DelTable     ;ᬥ饭�� �����
	MUL DL		         ;�⭮�⥫쭮 �������� ����
	MOV BX,AX	         ;⠡���� ����থ�
	LEA SI,DelTable          ;����㧪� �������� ���� ⠡����
                                 ;����থ�
	MOV CX,[SI][BX]          ;�롮ઠ ⥪�饩 ����প� �� ⠡����=
                                 ;��।�� ��ࠬ��஢ ��� ������ 
				 ;�����⥫�
	CALL RotModul		 ;������ �����⥫�
	MOV AL,CodPosRot	 ;�⥭�� ���� ����樨 ���
	CMP PCodPosRot,AL	 ;�।��饥 ���祭��=�����饬� ?
	JNE M2IF2		 ;���室,�᫨ ���
                                 ;���६��� �᫠ ����⮢
	MOV AL,Turn		 
	SUB AL,1		 
	DAS		 	 
	MOV Turn,AL		 
	MOV AL,Turn+1		 
	SBB AL,0		 
	DAS			 
	MOV Turn+1,Al		 
	MOV AL,Turn+2		 
	SBB AL,0		 
	DAS		 	 
	MOV Turn+2,Al		 
M2IF2:  RET
Md2InfoForm ENDP

;����� "��ନ஢���� ���ᨢ� �⮡ࠦ����"
DispForm PROC NEAR
;�室�� ��ࠬ����:
;	SI-���� �室��� ������
;	DI-���� ��室��� ������
;	CH-�᫮ �室��� ����
	MOV CL,4    ;���稪 ᤢ����=4
DF1:	MOV AL,[SI] ;�⥭�� ������
	MOV AH,AL   ;����஢���� ������
	AND AL,0FH  ;�뤥����� ����襩 ��ࠤ�
	MOV [DI],AL ;������ � ������
	INC DI      ;���६��� ����
	SHR AH,CL   ;����� ����� ������ �� ��ࠤ�
	MOV [DI],AH ;������ � ������
	INC DI      ;���६��� ����
	INC SI      ;�� ��
	DEC CH      ;�� ����� ?
	JNZ DF1     ;���室,�᫨ ���
	RET
DispForm ENDP

;����� "�뢮� ����樨 ���"
PosRotOut PROC NEAR
	MOV     AL,CodPosRot   ;�⥭�� ���� ����� ���
	OUT     PROutPort,AL   ;�뢮� � ����
	RET
PosRotOut ENDP

;����� "�뢮� �᫮��� ���ଠ樨"
NumInfOut PROC NEAR
;�室�� ��ࠬ����:
;	SI-���� �室���� ���ᨢ� �⮡ࠦ����
;	DX-����� ����襣� ���� ��ᯫ��
;	CX-������⢮ �뢮����� ������
	LEA BX,TrfTable1 ;����㧪� ���� ⠡���� �८�ࠧ������
NIO1:	MOV AL,[SI]	 ;�⥭�� ����
	XLAT		 ;�८�ࠧ������ ����
	OUT DX,AL	 ;�뢮� ���� � ����
	INC SI		 ;����䨪��� ����
	INC DX		 ;� ����� ����
	LOOP NIO1	 ;�� ���� ? ���室,�᫨ ���
	RET
NumInfOut ENDP

;����� "�뢮� ���-ᨣ����"
SIMOut PROC NEAR
	MOV AH,Keyhol_BCD                  ;�⥭�� ᪢������
	CALL BCDTrans			   ;�८�ࠧ������ BCD-�ଠ�
					   ;� ������
	CMP AL,16			   ;����������=>16
	JNBE SO1			   ;���室,�᫨ ��
	MOV DL,TYPE TrfTable2              ;��ନ஢���� ᬥ饭�� �����
	MUL DL		     		   ;�⭮�⥫쭮 �������� ����
	MOV BX,AX	     	           ;���-⠡���� 
	LEA SI,TrfTable2		   ;����㧪� �������� ����  
					   ;���-⠡����
	MOV AX,[SI][BX]			   ;�롮ઠ ⥪�饣� ���-ᨣ����
	JMP SHORT SO2			   
SO1:	MOV AX,TrfTable2+16*TYPE TrfTable2 ;�⥭�� ��᫥����� ���-ᨣ����
SO2:	OUT SOutPort0,AL			   ;�뢮�
	MOV AL,AH 			   ;
	OUT SOutPort6,AL			   ;���-ᨣ����
	RET
SIMOut ENDP

Begin:			       ;���⥬��� �����⮢��	
	MOV 	AX,Data        ;���樠������ ᥣ������ ॣ���஢	
	MOV	DS,AX
	MOV	AX,Stack
	MOV	SS,AX
	LEA	SP,StkTop      ;� 㪠��⥫� �⥪�
	CALL	FuncPrep       ;�㭪樮���쭠� �����⮢��
Count:  
	CALL	ModeInput      ;���� ०����
	CALL    RtDrInTpMesOut ;�뢮� ᮮ�饭�� � ���ࠢ����� ��饭��
			       ;� ⨯� �����
	CALL	KbdInput       ;���� � ����������
	CALL 	KbdInContr     ;����஫� ����� � ����������
	CALL	NxtDigTrf      ;�८�ࠧ������ ��।��� ����
	CALL	PsvStInfoForm  ;��ନ஢���� ���ଠ樨 � ���ᨢ��� ���ﭨ�
	CALL	Md1InfoForm    ;��ନ஢���� ���ଠ樨 � ०��� 1
	CALL	Md2InfoForm    ;��ନ஢���� ���ଠ樨 � ०��� 2
	LEA 	SI, Frequenc   ;��।�� ��ࠬ��஢
	LEA	DI, FreqDisp   ;��� �ନ஢���� ���ᨢ� �⮡ࠦ����
	MOV	CH,2           ;�����
	CALL	DispForm       ;��ନ஢���� ���ᨢ� �⮡ࠦ����
	LEA 	SI,Turn        ;��।�� ��ࠬ��஢ 
	LEA	DI,TurnDisp    ;��� �ନ஢���� ���ᨢ� �⮡ࠦ���� 
	MOV	CH,3           ;����⮢
	CALL	DispForm       ;��ନ஢���� ���ᨢ� �⮡ࠦ����
	LEA 	SI,Keyhol_BCD  ;��।�� ��ࠬ��஢ 
	LEA	DI,KeyDisp     ;��� �ନ஢���� ���ᨢ� �⮡ࠦ����
	MOV	CH,1           ;᪢������
	CALL	DispForm       ;��ନ஢���� ���ᨢ� �⮡ࠦ����
	CALL	PosRotOut
	LEA  	SI,FreqDisp    ;��।�� ��ࠬ��஢
	MOV 	DX,FOutPort1   ;��� �뢮�� ���ଠ樨
	MOV	CX,4           ;�� ��ᯫ�� "�����"
	CALL	NumInfOut      ;�뢮� �᫮��� ���ଠ樨
	LEA  	SI,TurnDisp    ;��।�� ��ࠬ��஢ 
	MOV 	DX,TOutPort7   ;��� �뢮�� ���ଠ樨
	MOV	CX,6           ;�� ��ᯫ�� "������"
	CALL	NumInfOut      ;�뢮� �᫮��� ���ଠ樨
	LEA  	SI,KeyDisp     ;��।�� ��ࠬ��஢
	MOV 	DX,KOutPort14  ;��� �뢮�� ���ଠ樨
	MOV	CX,2           ;�� ��ᯫ�� "����������"
	CALL	NumInfOut      ;�뢮� �᫮��� ���ଠ樨
	CALL	SIMOut         ;�뢮� ���-ᨣ����
	JMP	Count          ;
	ORG	07F0H          ;
Start:	JMP     Begin          ;
Code	ENDS
        END     Start