;� �⮬ ���㫥 ��楤��� ��� �ନ஢���� ࠧ�. ᮮ�饭��
;����� "�뢮� ᮮ�饭�� "TimeOut" � "SoundOff""
DispMessages PROC NEAR
           xor   ax,ax
           mov   al,Pos
           push  ax
           cmp   msgTimeOutFlag,0
           jz    DMOtherFl           
           lea   si,MsgTimeOut
           jmp   DMDisp
DMOtherFl:           
           cmp   msgMicrOutFlag,0
           jz    DMExit
           lea   si,MsgSoundOff
           jmp   DMDisp           
DMDisp:           
           xor   ax,ax
           mov   ch,5         ;5-�᫮ �������஢   
           mov   DX,40h       ;�⮫���        
DSOutNextInd:
           mov   cl,ch
           mov   al,10000000b
           rol   al,cl
           out   EPort,al     ;����砥� ��⠭�� �� �㦭�� ��������� �����

           mov   Pos,00000001b ;��� ������� �㤥� ᤢ����� (�⮫���)          
           mov   cl,8
                     
DSOutNextCol:    
           xor   al,al
           out   DX,al     ;�몫 �������� (�� �⮫���)                 
           sub   DX,10h
           mov   al,[si]   ;���뢠�� � al ���� �� ��ப�
           not   al        ;�������㥬
           out   DX,al     ;�뢮��� �� ��ப� ��������
           mov   al,Pos    ;�������� ᫥��騩 �⮫���
           add   DX,10h
           out   DX,al     ;---||---           
           inc   si        ;����砥� ᬥ饭�� ᫥���饣� �����
           rol   Pos,1                                       
           dec   cl
           jnz   DSOutNextCol
           
           inc   DX
           dec   ch           
           jnz   DSOutNextInd        
DMExit:    
           pop   ax
           mov   Pos,al
           ret   
DispMessages ENDP           

;����� "��⠫��� 1 �����"
MinLeft    PROC  NEAR
           push  ax
           xor   ax,ax
           cmp   RunFlag,0
           jz    TLM1
           cmp   MinLeftFlag,0 ;�᫨ ��⠫��� <= 1 �����, � ��稭��� ������ �����窠
           jz    TLCheck           
           cmp   MsgTimeOutFlag,1
           jne   TLOut
TLM1:
           mov   MinLeftFlag,0
TLOut:
           mov   al,MinLeftFlag
           out   IndiPort,al           
           jmp   TLExit
TLCheck:           
           lea   si,TimePred
           cmp   word ptr [si],0 ;�஢��塞 ���
           jne   TLExit
           cmp   word ptr [si+2],0 ;�஢��塞 ������           
           jne   TLExit
           cmp   word ptr [si+4],0
           mov   MinLeftFlag,0
           jz    TLOut
           mov   MinLeftFlag,1
TLExit:    
           pop   ax
           ret
MinLeft   ENDP 
