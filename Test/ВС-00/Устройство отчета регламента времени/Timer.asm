;����� "����� �६���"
Timer      PROC  NEAR
           xor   ax,ax
           mov   al,Pos
           push  ax
           cmp   RunFlag,0
           jz    TJMP
           
           ;��稭��� ������

           xor   ax,ax
           mov   Pos,6
           mov   al,6
           mov   si,ax           
           dec   si
TLoop:           
           dec   TimePred[si]
           cmp   TimePred[si],0ffh
           je    TZero           
           jmp   TExit
TZero:
           cmp   Pos,6
           je    T6
           cmp   Pos,5
           je    T5
           cmp   Pos,4
           je    T6
           cmp   Pos,3
           je    T5
           cmp   Pos,2
           je    T2
T6:           
           mov   TimePred[si],9
           dec   si
           dec   Pos
           jmp   TLoop
T5:
           mov   TimePred[si],5
           dec   si
           dec   Pos
           jmp   TLoop
TJmp:                   
           JMP   TExit ;�� ��⪠ - �஬����筠�, �.�. �� ����� ������� �� ��室�
T2:        
           cmp   MicrOutFlag,0
           je    TSoundOn
           
           cmp   TenSecLeftFlag,0
           jz    TSet10Delay    
           mov   msgTimeOutFlag,0
           mov   msgMicrOutFLag,1
           mov   RunFlag,0
           mov   PosFlag,0   
           jmp   TClearExit           
TSet10Delay:
           mov   word ptr TimePred[0],0  ;����塞 ���
           mov   word ptr TimePred[2],0  ;����塞 ������
           mov   TimePred[4],1h          ;����� �� 10 ᥪ. 
           mov   TimePred[5],0h 
           mov   msgTimeOutFlag,1        ;�뢮��� ᮮ�饭�� "Time out"           
           mov   TENSecLeftFlag,1        ;�� �⮡ࠦ��� 10 ᥪ ����প� �� ���������
           jmp   TExit
           
TSoundOn:
           mov   msgTimeOutFlag,1
           mov   RunFlag,0
           mov   PosFlag,0                    

TClearExit:                        
           mov   cx,3          ;����塞 ���ᨢ� TimePred 
           xor   ax,ax
           lea   di,TimePred
           rep   stosw                   
TExit:
           pop   ax
           mov   Pos,al
           ret           
Timer      ENDP
