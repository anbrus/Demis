;����� "���뢠��� ������ �ࠢ�����"
ReadCtrlKeys PROC NEAR
           in    al,KbdPort
           and   al,01111000b ;�뤥�塞 ������ �ࠢ�����
           cmp   al,00001000b 
           je    RKNewDok     ;����� ������ "���� ������稪"
           cmp   al,00010000b 
           je    RKPusk       ;--||----||-- "���"
           cmp   al,00100000b
           je    RKSbros      ;--||----||-- "����"
           cmp   al,01000000b
           je    RKMicrOut    ;--||----||-- "� �⪫�祭��� ����䮭�"
           jmp   RKExit
;��ࠡ��뢠�� "���� ������稪"
RKNewDok:
           call  VibrDestr           
           call  NewDokBtn          
           jmp   RKExit           
;��ࠡ��뢠�� "���"
RKPusk:
           cmp   DispMsgFlag,0 ;�᫨ �뢮����� ᮮ�饭��, � �� ���뢠�� ������           
           jnz   RKExit
           cmp   RunFlag,0     ;�᫨ ���. ०�� "�����", � ��室��
           jnz   RKExit    
           call  VibrDestr
           ;call  PuskBtn
           cmp   PuskFlag,1
           jne   RKPExit           
           ;call  SaveTimePredToRAM
           push  cx
           mov   cx,3        ;�� ᬮ��� ᪮��஢��� �� 3 横��
           lea   si,TimePred
           lea   di,TimeInMem
           REP   MOVSW       ;���᫠�� ᫮��, Rep-��䨪� ����७�� 
           pop   cx
           mov   RunFlag,1    ;����砥� ०�� "�����"
RKPExit:           
           jmp   RKExit           
;��ࠡ��뢠�� "����"
RKSbros:
           call  VibrDestr
           call  FuncPrep 
           jmp   RKExit           
;��ࠡ��뢠�� "Microphone out"
RKMicrOut:
           cmp   DispMsgFlag,0 ;�᫨ �뢮����� ᮮ�饭��, � �� ���뢠�� ������
           jnz   RKExit
           cmp   RunFlag,0    ;�᫨ ���. ०�� "�����", � ��室��
           jnz   RKExit    
           call  VibrDestr
           ;call  MicrOutBtn
RKMOLoop:           
           in    al,KbdPort
           and   al,01000000b ;�뤥�塞 ⮫쪮 ������ ����䮭�
           cmp   al,01000000b ;�᫨ ������ �⦠�, � ��室��
           je    RKMOLoop           
           
           cmp   MicrOutFlag,00h
           jz    RKMicrOFF
           mov   MicrOutFlag,00h ;��� �⪫�祭�� ����䮭�
           jmp   RKExit
RKMicrOFF:
           mov   MicrOutFlag,1   ;� �⪫�祭�� ����䮭�           
;          jmp   RKExit                      
RKExit:
           ret
ReadCtrlKeys ENDP


;�������� "������ "�⪫�祭�� ����䮭�""
;MicrOutBtn PROC  NEAR
;MOBLoop:
;           in    al,KbdPort
;           and   al,01000000b ;�뤥�塞 ⮫쪮 ������ ����䮭�
;           cmp   al,01000000b ;�᫨ ������ �⦠�, � ��室��
;           je    MOBLoop           
;           
;           cmp   MicrOutFlag,00h
;           jz    MicrOFF
;           mov   MicrOutFlag,00h ;��� �⪫�祭�� ����䮭�
;           jmp   MOExit
;MicrOFF:
;           mov   MicrOutFlag,1   ;� �⪫�祭�� ����䮭�           
;MOExit:
;           ret
;MicrOutBtn ENDP           

;�������� "������ "����""
;SbrosBtn   PROC  NEAR
;           call  FuncPrep        
;           ret
;SbrosBtn   ENDP

;�������� "���࠭���� �६��� �।ᥤ�⥫� � ���"
;SaveTimePredToRAM PROC NEAR
;           push  cx
;           mov   cx,3        ;�� ᬮ��� ᪮��஢��� �� 3 横��
;           lea   si,TimePred
;           lea   di,TimeInMem
;           REP   MOVSW       ;���᫠�� ᫮��, Rep-��䨪� ����७�� 
;           pop   cx
;           ret
;SaveTimePredToRam ENDP           

;�������� "������ "���� ������稪""
NewDokBtn  PROC  NEAR                 
           call  Clear       ;��頥� ��
           mov   cx,3
           lea   si,TimeInMem
           lea   di,TimePred
           REP   MOVSW
           mov   cx,6

           mov   Pos,6       ;�뢮��� � Pos = 6
           mov   PosFlag,0   ;������ �� ����� ��ࠧ�
           xor   al,al
           out   EPort,al    ;��ᨬ ᢥ�
           mov   msgTimeOutFlag,0
           mov   msgMicrOutFlag,0
           mov   MicrOutFlag,0
           mov   RunFlag,0
           mov   TENSecLeftFlag,0
           mov   DispMsgFlag,0
           mov   PuskFlag,1
           mov   MinLeftFlag,0
NDLoop:              
           push  0000                 
           push  cx
           push  cx
           call  Znakomesto
           loop  NDLoop         
           ret
NewDokBtn  ENDP  