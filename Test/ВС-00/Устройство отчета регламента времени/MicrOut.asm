;����� "��ࠡ�⪠ ������ "�⪫�祭�� ����䮭�""
MicrOutBtn PROC  NEAR

           cmp   RunFlag,0    ;�᫨ ���. ०�� "�����", � ��室��
           jnz   MOBExit  
           cmp   msgTimeOutFlag,1
           je    MOBExit
           in    al,KbdPort
           and   al,01000000b
           cmp   al,01000000b
           jne   MOBExit
           call  VibrDestr       
           cmp   MicrOutFlag,00h
           jz    MOBMicrOFF
           mov   MicrOutFlag,00h ;��� �⪫�祭�� ����䮭�
           jmp   MOBExit
MOBMicrOFF:
           mov   MicrOutFlag,1   ;� �⪫�祭�� ����䮭�           
MOBExit:
           ret
MicrOutBtn ENDP                           