;����� "��ࠡ�⪠ ������ "+"" 
IncNaschet PROC  NEAR
           cmp   RunFlag,0      ;�᫨ ���. ०�� "�����", � ��室��
           jnz   INExit    
           cmp   PosFlag,0
           je    INExit
           in    al,KbdPort
           and   al,00000001b
           cmp   al,00000001b    ;�᫨ �� ����� "+" , � �஢��塞 ᫥����. �����.    
           jne   INExit
           call  VibrDestr       ;���࠭塞 �ॡ���           
           mov   PuskFlag,1
           xor   ax,ax
           mov   al,Pos
           mov   si,ax
           dec   si
           inc   TimePred[si]                     
           
           cmp   Pos,6       ;�᫨ ���. 6 - ������ ���� ᥪ㭤
           je    IN6
           cmp   Pos,5       ;�᫨ ���. 5 - ����� ���� ᥪ㭤
           je    IN5
           cmp   Pos,4       ;�᫨ ���. 4 - ������ ���� �����
           je    IN6
           cmp   Pos,3       ;�᫨ ���. 3 - ����� ���� �����
           je    IN5  
           cmp   Pos,2       ;�᫨ ���. 2 - ������ ���� �ᮢ
           je    IN2
                             ;���� 04:59:59
           jmp   INExit
IN6:
           cmp   TimePred[si],10 ;�᫨ =10, � ��⠭���� �� 0
           jne   INExit
           mov   TimePred[si],0
           jmp   INExit
IN5:       
           cmp   TimePred[si],6    
           jne   INExit
           mov   TimePred[si],0
           jmp   INExit
IN2:
           cmp   TimePred[si],5
           jne   INExit
           mov   TimePred[si],0              
                            
INExit:           
           ret
IncNaschet  ENDP
