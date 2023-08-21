;���������� ࠡ��� � ⠩��஬ ��54
;�ᯮ������ ०�� 3 ⠩���, � ���஬ �� ��室� Out �ନ����� ᨣ��� � �ଥ ������
;����� ⠩��� 1��, �����樥�� ������� = 2
;�� ��室� Out ⠩��� �ନ��� ������ � ��ਮ��� 2 ᥪ㭤�
;���⥫쭮�� ���. 0 � ���. 1 ���� ��������� �� 1 ᥪ㭤�
;�ணࠬ�� �㤥� 㢥��稢��� ���祭�� ����稪� �� �஭�� � ᯠ��
;�� ���� ����稪 �㤥� 㢥��稢����� �� 1 ������ ᥪ㭤�
;��� ࠧ�襭�� ࠡ��� ⠩��� �㦭� ������ ������ "���"

.386
;������ ���� ��� � �����
RomSize           EQU 4096

PORT_TIMER_CW     EQU 43h    ;���� �ࠢ���饣� ॣ���� ⠩���
PORT_TIMER        EQU 40h    ;���� ����稪� ⠩���
PORT_TIMER_OUT    EQU 0      ;���� �����, � ���஬� ������祭 ��室 ⠩���
PORT_COUNTER_LOW  EQU 0      ;���� �뢮�� ����襩 ���� ����稪�
PORT_COUNTER_HIGH EQU 1      ;���� �뢮�� ���襩 ���� ����稪�

Data       SEGMENT use16 AT 40h
timerval   db ?  ;��᫥���� ���祭�� � ��室� ⠩���
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

;��楤�� ���樠����樨 ०��� ⠩���
InitTimer        PROC  NEAR
           mov   al, 16h             ;����� 3, ࠡ�� � ����訬 ���⮬
           out   PORT_TIMER_CW, al
           
           mov   al, 2               ;�����樥�� ������� 2
           out   PORT_TIMER, al

           ret
InitTimer        ENDP

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

;��楤�� �������� ��������� ��室� ⠩���
WaitTimer        PROC NEAR
WaitTimerLoop:
           in    al, PORT_TIMER_OUT       ;�⥭�� ��室� ⠩���
           cmp   al, timerval             ;�஢�ઠ �� ��������� ��室�
           jz    WaitTimerLoop            ;���⨬�� � 横��, ���� ��室 �� �������
           mov   timerval, al             ;���������� ����� ���祭�� ��室�
           
           ret
WaitTimer        ENDP

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
           
           ;�����뢠�� � ����稪 ���祭�� 0
           xor   ax, ax
           mov   counter, al
           
           ;��᫥ ���樠����樨 ⠩��� �� ��� ��室� �㤥� 1
           ;���� ������ ⠩��� �㤥� 䨪�஢��� �� ���室� ��室� � 0
           ;���⮬� � ����⢥ �।��饣� ���祭�� �������� 1
           inc   al
           mov   timerval, al    
           
           call  InitTimer       ;���樠������ ०��� ࠡ��� ⠩���
           
MainLoop:
           call  ShowCounter     ;������塞 ��������� ����稪�
           call  WaitTimer       ;��� ��������� ᨣ���� �� ��室� ⠩���
           call  IncCounter      ;���६����㥬 ����稪
           jmp   MainLoop        ;��᪮���� 横�

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END        Start
