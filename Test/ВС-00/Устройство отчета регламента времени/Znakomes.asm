;����� "��ࠡ�⪠ ������ "������""           
Znakomesto PROC  NEAR
           cmp   RunFlag,0       ;�᫨ ���. ०�� "�����", � ��室��
           jnz   ZExit    
           in    al,KbdPort
           and   al,00000100b
           cmp   al,00000100b    ;�᫨ �� ����� "������"
           jne   ZExit
           call  VibrDestr       ;���࠭塞 �ॡ���
           cmp   PosFlag,0
           jnz   ZNext
           mov   PosFlag,1          
           jmp   ZExit           
ZNext:         
           dec   Pos        
           cmp   Pos,1
           jne    ZExit
           mov   Pos,6                    
ZExit:                             
           ret
Znakomesto ENDP