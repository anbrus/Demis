;����� "��ࠡ�⪠ ������ "���� ������稪""
NewDokBtn  PROC  NEAR

           in    al,KbdPort
           and   al,00001000b ;�뤥�塞 ������ �ࠢ�����
           cmp   al,00001000b 
           jne   NDExit       ;����� ������ "���� ������稪"
           call  VibrDestr
            
           xor   dx,dx    
           xor   ax,ax           
           out   EPort,al
           mov   cx,12       ;12-�᫮ �������஢
           mov   al,03fh
NDClearLoop:
           inc   dx
           out   dx,al           
           loop  NDCLearLoop

           mov   cx,3
           lea   si,TimeInMem
           lea   di,TimePred
           REP   MOVSW

           mov   Pos,6       ;�뢮��� � Pos = 6
           mov   PosFlag,0   ;������ �� ����� ��ࠧ�
           mov   msgTimeOutFlag,0
           mov   msgMicrOutFlag,0
           mov   MicrOutFlag,0
           mov   RunFlag,0
           mov   TENSecLeftFlag,0
           mov   PuskFlag,1
           mov   MinLeftFlag,0

NDExit:
           ret
NewDokBtn  ENDP                      