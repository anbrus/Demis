;����� "�뢮� ⥪�饣� �६��� �� ��������� "�।ᥤ�⥫�" � "������稪�""
DispTime PROC NEAR
           cmp   TENSecLeftFlag,0 ;�᫨ � �몫�祭��� ����䮭�, � ᮮ�饭�� � �������⥫��
           jnz   DRTExit          ;10 ᥪ㭤 �� �뢮��� �� ���������                                 
           mov   si,5
           cmp   FirstRunFlag,1
           jne   DRT12Indi
           cmp   RunFlag,0
           jne   DRT12Indi
           mov   cx,6          
           jmp   DRTDisp                      
DRT12Indi: 
           mov   FirstRunFlag,1 
           mov   cx,12             
DRTDisp:            

           mov   al,TimePred[si]                      
           lea   bx,Digits
           xlat  TimePred    ;� al ����稫� ��ࠧ �뢮����� ����        

           ;�롨ࠥ� � ����� ����� �������� ���

           cmp   PosFlag,0   ;� ०��� "�� ����� ��. "������""
           je    ZPointOFF   ;��ᨬ ���
           cmp   RunFlag,1   ;� ०��� "�����"
           je    ZPointOff   ;��ᨬ ���
           cmp   cl,Pos      ;�᫨ ����� �������� ᮢ������ � ⥪. ����樥�,
           jne   ZpointOFF   ;� �뢮���� ���
           or    al,10000000b;�᫨ 1, � �������� ���  
           jmp   ZDispZnak                    
ZPointOff:          
           and   al,01111111b
           jmp   ZDispZnak

ZDispZnak:
           xor   dx,dx
           mov   dl,cl   ;�뢮��� � ���� �cx
           out   dx,al
           dec   si
           jz    DRTZero
           loop  DRTDisp
           jmp   DRTExit
DRTZero:
           mov   si,6                                       
           loop  DRTDisp 
DRTExit:           
           ret
DispTime ENDP            