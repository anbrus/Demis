;����� "��ࠡ�⪠ ������ "���""
PuskBtn    PROC  NEAR
           cmp   RunFlag,0
           jnz   PBExit
           cmp   PuskFlag,1
           jne   PBExit    
           in    al,KbdPort
           and   al,00010000b
           cmp   al,00010000b
           jne   PBExit
           call  VibrDestr                  
           mov   cx,3        ;�� ᬮ��� ᪮��஢��� �� 3 横��
           lea   si,TimePred
           lea   di,TimeInMem
           REP   MOVSW       ;���᫠�� ᫮��, Rep-��䨪� ����७�� 
           mov   RunFlag,1   ;����砥� ०�� "�����"                 
PBExit:   
           ret        
PuskBtn    ENDP           