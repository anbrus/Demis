; � �⮬ ���㫥 ᮡ࠭� �� ��楤���
; ⠪ ��� ���� �⭮��騥�� � �⮡ࠦ���� 
; ���ଠ樨 �� �����ᨭ⥧����饬 
; ��ᯫ��

; �뢮� �� ��ᯫ�� ���
DispClear  PROC  NEAR
           PUSH  AX DI
           LEA   DI,Str

           MOV   AL,12
           MOV   CX,10
DC_cyc:    STOSB                     ; ��⠫�� �⮡ࠦ���� - �����
           LOOP  DC_cyc

           XOR   AL,AL
           STOSB                     ; ������� 0 ࠧ�冷� ��। ����⮩
           STOSB                     ; �窨 ���

           MOV   AL,0FFh
           STOSB                     ; ��ப� ���� ������� ������
           
           XOR   AL,AL
           STOSB                     ; ������� 0 ࠧ�冷� ��᫥ ����⮩
           POP   DI AX
           RET
DispClear  ENDP

; �뢮� �� ��ᯫ�� ���
DispZero   PROC  NEAR
           PUSH  AX DI
           LEA   DI,Str

           XOR   AL,AL
           STOSB                     ; ����訩 ࠧ�� - �㫥���

           MOV   AL,12
           MOV   CX,9
DZ_cyc:    STOSB                     ; ��⠫�� �⮡ࠦ���� - �����
           LOOP  DZ_cyc

           XOR   AL,AL
           STOSB                     ; ������� 0 ࠧ�冷� ��। ����⮩
           
           MOV   AL,0FFh
           STOSB                     ; ��� ������� ����� ���
           STOSB                     ; ��ப� ���� ������� ������
           
           MOV   AL,1
           STOSB                     ; ������� 1 ࠧ�� ��᫥ ����⮩
           POP   DI AX
           RET
DispZero   ENDP

; ��⠭���� �� ��ᯫ�� �㫥���� �६���
DispTimeZero PROC  NEAR
           CMP   ActButCode,Clr
           JNZ   DTZ_end
           
           PUSH  AX DI
           LEA   DI,Str

           MOV   AL,13
           STOSB                     ; ������ � �㫥
           STOSB

           MOV   AL,11
           STOSB                     ; �� ����� ����⠬� � �ᠬ�
           
           MOV   AL,13
           STOSB                     ; ��� � �㫥
           STOSB
           
           MOV   AL,12
           MOV   CX,5
DTZ_cyc:   STOSB                     ; ��⠫�� �⮡ࠦ���� - �����
           LOOP  DTZ_cyc

           XOR   AL,AL
           STOSB                     ; ������� 0 ࠧ�冷� ��। ����⮩
           STOSB                     ; �窨 ���
           STOSB                     ; ��ப� ���� ������� ������
           
           XOR   AL,AL
           STOSB                     ; ������� 0 ࠧ�冷� ��᫥ ����⮩
           POP   DI AX
DTZ_end:   RET
DispTimeZero ENDP

DispDateZero PROC  NEAR
           CMP   ActButCode,Clr
           JNZ   DDZ_end
           
           PUSH  AX DI
           LEA   DI,Str

           MOV   AL,13
           STOSB                     ; ���� � �㫥
           STOSB

           MOV   AL,11
           STOSB                     ; �� ����� ���� � ����楬
           
           MOV   AL,13
           STOSB                     ; ����� � �㫥
           STOSB
           
           MOV   AL,11
           STOSB                     ; �� ����� ����楬 � �����
           
           MOV   AL,13
           STOSB                     ; ��� � �㫥
           STOSB
           
           MOV   AL,12
           MOV   CX,2
DDZ_cyc:   STOSB                     ; ��⠫�� �⮡ࠦ���� - �����
           LOOP  DDZ_cyc

           XOR   AL,AL
           STOSB                     ; ������� 0 ࠧ�冷� ��। ����⮩
           STOSB                     ; �窨 ���
           STOSB                     ; ��ப� ���� ������� ������
           
           XOR   AL,AL
           STOSB                     ; ������� 0 ࠧ�冷� ��᫥ ����⮩
           MOV   Error,0
           POP   DI AX
DDZ_end:   RET
DispDateZero ENDP