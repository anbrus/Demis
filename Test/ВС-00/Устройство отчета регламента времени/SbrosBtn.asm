;����� "��ࠡ�⪠ ������ "���� ������稪""
SbrosBtn   PROC  NEAR
           
           in    al,KbdPort
           and   al,00100000b ;�뤥�塞 ������ �ࠢ�����
           cmp   al,00100000b
           jne   SBExit       
           call  VibrDestr
           
           xor   dx,dx    
           xor   ax,ax           
           out   EPort,al
           mov   cx,12       ;12-�᫮ �������஢
           mov   al,03fh
SBClearLoop:
           inc   dx
           out   dx,al           
           loop  SBCLearLoop
           
           mov   msgTimeOutFlag,0    ;䫠� ᮮ�饭�� "Time out" 
           mov   msgMicrOutFlag,0    ;䫠� ᮮ�饭�� "Sound off"
           mov   TENSecLeftFlag,0
          
           mov   RunFlag,0     ;��⠭�������� ०�� "�����"
           mov   PosFlag,0     ;��⠭�������� 0 - ������ "������" �� ����� �� ࠧ�
           mov   PuskFlag,0    ;��⠭�������� 0 - ������ "���" �� ����� �� ࠧ�
           xor   al,al
           out   EPort,al      ;0 �� ���� ��⠭��           
           mov   MicrOutFlag,0 ;0 - ����䮭 ࠡ�⠥�, 1 - ����䮭 �㤥� �⪫�祭
           mov   MinLeftFlag,0          
           mov   Pos,6         ;��稭��� ���� � ����襩 ����樨
      
           mov   cx,6          ;����塞 ���ᨢ� TimePred � TimeInMem
           xor   ax,ax
           lea   di,TimePred
           rep   stosw           
SBExit:           
           ret
SbrosBtn   ENDP          