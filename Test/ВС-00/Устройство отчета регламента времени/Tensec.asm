;����� "����প� ����� ᮮ�饭�ﬨ"
TenSecDellay  PROC NEAR
           cmp   MicrOutFlag,0
           jne   TSDExit
           cmp   MsgTimeOutFlag,0
           jne   TSDSet
         
           jmp   TSDExit
TSDSet:           
           mov   word ptr TimePred[0],0  ;����塞 ���
           mov   word ptr TimePred[2],0  ;����塞 ������
           mov   TimePred[4],1h          ;����� �� 10 ᥪ. 
           mov   TimePred[5],0h 
           mov   msgTimeOutFlag,1        ;�뢮��� ᮮ�饭�� "Time out"           
           mov   TENSecLeftFlag,1        ;�� �⮡ࠦ��� 10 ᥪ ����প� �� ���������
           
TSDExit:
           ret                    
TenSecDellay  ENDP