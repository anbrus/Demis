;����� "���뢠��� ������ ����������"           
ReadKbdKeys  PROC  NEAR
           cmp   RunFlag,0      ;�᫨ ���. ०�� "�����", � ��室��
           jnz   ITExit    
           cmp   DispMsgFlag,0  ;�᫨ �뢮����� ᮮ�饭��, � ������ �� ���뢠��
           jnz   ITExit
           in    al,KbdPort
           and   al,00000111b
           cmp   al,00000001b    ;�᫨ �� ����� "+" , � �஢��塞 ᫥����. �����.    
           je    ITPlusBtn           
           cmp   al,00000010b    ;�᫨ �� ����� "-" , � �஢��. �. ��.    
           je    ITMinusBtn          
           cmp   al,00000100b    ;�᫨ �� ����� "������", � ��室           
           je    ITChangePos           
           jmp   ITExit
ITPlusBtn:      
           cmp   PosFlag,0
           je    ITExit                
           mov   KbdFlag,1      ;����� ������ 
           call  VibrDestr
           call  IncNaschet     ;����� ������ "+"
           jmp   ITExit
ITMinusBtn:  
           cmp   PosFlag,0
           je    ITExit              
           mov   KbdFlag,1      ;����� ������ 
           call  VibrDestr
           call  DecNaschet     ;����� ������ "-"
           jmp   ITExit                
ITChangePos:
           mov   KbdFlag,1      ;����� ������ 
           call  VibrDestr
           call  ChangePos      ;����� ������ "������"
                                         
ITExit:    
           ret
ReadKbdKeys  ENDP