;����� "��ࠡ�⪠ ������ "-""
DecNaschet PROC  NEAR
           cmp   RunFlag,0      ;�᫨ ���. ०�� "�����", � ��室��
           jnz   DNExit    
           cmp   PosFlag,0
           je    INExit
           in    al,KbdPort
           and   al,00000010b
           cmp   al,00000010b    ;�᫨ �� ����� "-" , � �஢��塞 ᫥����. �����.    
           jne   DNExit    
           call  VibrDestr       ;���࠭塞 �ॡ���       
           mov   PuskFlag,1
           xor   ax,ax
           xor   si,si
           mov   al,Pos
           mov   si,ax
           dec   si
           dec   TimePred[si]                     
           
           cmp   Pos,6       ;�᫨ ���. 6 - ������ ���� ᥪ㭤
           je    DN6
           cmp   Pos,5       ;�᫨ ���. 5 - ����� ���� ᥪ㭤
           je    DN5
           cmp   Pos,4       ;�᫨ ���. 4 - ������ ���� �����
           je    DN6
           cmp   Pos,3       ;�᫨ ���. 3 - ����� ���� �����
           je    DN5  
           cmp   Pos,2       ;�᫨ ���. 2 - ������ ���� �ᮢ
           je    DN2
                             ;��� 00:00:00
           jmp   INExit
DN6:
           cmp   TimePred[si],0ffh ;�᫨ <0 � = 9
           jne   DNExit
           mov   TimePred[si],9
           jmp   INExit
DN5:       
           cmp   TimePred[si],0ffh
           jne   DNExit
           mov   TimePred[si],5
           jmp   INExit           
DN2:
           cmp   TimePred[si],0ffh
           jne   DNExit
           mov   TimePred[si],4              
                            
DNExit:           
           ret
DecNaschet ENDP  