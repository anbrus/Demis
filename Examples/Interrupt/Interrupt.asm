;���������� ࠡ��� � ���뢠��ﬨ
;�ணࠬ�� �㤥� 㢥��稢��� ���祭�� ����稪� �� ᨣ���� ���뢠��� �� ������

.386
;������ ���� ��� � �����
RomSize           EQU 4096

PORT_COUNTER_LOW  EQU 0      ;���� �뢮�� ����襩 ���� ����稪�
PORT_COUNTER_HIGH EQU 1      ;���� �뢮�� ���襩 ���� ����稪�

IntTable   SEGMENT use16 AT 0
           org   0ffh*4        ; �� �⮬� ᬥ饭�� ��室���� ���� ��ࠡ��稪� ���뢠��� 0ffh
IntFFHandlerPtrOffs dw ?       ;���饭�� ��ࠡ��稪� ���뢠���  
IntFFHandlerPtrSeg  dw ?       ;������� ��ࠡ��稪� ���뢠���
IntTable   ENDS

Data       SEGMENT use16 AT 40h
counter    db ?  ;����筮-�����筮� ���祭�� ����稪�
Data       ENDS

Stk        SEGMENT use16 AT 100h
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

Code       SEGMENT use16
;��ࠧ� ��� �� 0 �� 9 ��� 7-�� ᥣ���⭮�� ��������
digits     db 3Fh, 0Ch, 76h, 05Eh, 4Dh, 5Bh, 7Bh, 0Eh, 7Fh, 5Fh

           ASSUME cs:Code, ds:Data, es:Data, ss: Stk

IntHandler       PROC FAR
           push  ax
           push  ds
           
           mov   ax, Data
           mov   ds, ax
           
           call  IncCounter
           
           pop   ds
           pop   ax
           iret
IntHandler       ENDP

;��楤�� �⮡ࠦ���� ���祭�� ����稪�
ShowCounter      PROC NEAR
           ;�⮡ࠦ��� ������� ���� �� ������ 4 ��� ����稪�
           mov   al, counter
           and   al, 0fh
           xlat  digits
           out   PORT_COUNTER_LOW, al

           ;�⮡ࠦ��� ������ ���� �� ����� 4 ��� ����稪�
           mov   al, counter
           shr   al, 4
           xlat  digits
           out   PORT_COUNTER_HIGH, al

           ret
ShowCounter      ENDP

;��楤�� ���६���஢���� ����稪�
IncCounter       PROC NEAR
           mov   al, counter
           add   al, 1
           daa                   ;� ��� ����稪 ����筮-�������, ������ ���४��
           mov   counter, al
           
           ret
IncCounter       ENDP

Start:
           mov   ax, Data
           mov   ds, ax
           mov   es, ax
           mov   ax, Stk
           mov   ss, ax
           lea   sp, StkTop
           
           ;��⠭�������� ���� ��ࠡ��稪� ���뢠���
           push  ds
           mov   ax, IntTable
           mov   ds, ax
           mov   ax, cs:IntHandler
           mov   ds:IntFFHandlerPtrOffs, ax
           mov   ax, Code
           mov   ds:IntFFHandlerPtrSeg, ax
           pop   ds
           
           
           ;�����뢠�� � ����稪 ���祭�� 0
           xor   ax, ax
           mov   counter, al
           
           ;����蠥� ���뢠���
           sti
MainLoop:
           call  ShowCounter     ;������塞 ��������� ����稪�
           hlt                   ;��⠭�������� ������ �� ����㯫���� ���뢠���
           jmp   MainLoop        ;��᪮���� 横�

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END        Start
