.386
RomSize    EQU   4096
FirstButt  EQU   1
Clockwise  EQU   1

Data       SEGMENT use16 AT 1000h
           Way        db    ?
           Old        db    ?
           Speed      db    ?
           SpeedCX    db    ?
           Current    db    ?
Data       ENDS

Code       SEGMENT use16 
           ASSUME cs:Code,ds:Data,es:Code

Start:     xor   al,al           ;���㫥��� 
           mov   Old,al          ;��६�����
           mov   Way,al    
           mov   Speed,al    
           inc   al
           mov   SpeedCX,al
           mov   Current,al
InfLoop:   in    al,0            ;���뢠��� �� ���� [0000h]
           mov   ah,al           ;��࠭塞 ��⠭��� ���祭��
           xor   al,Old          ;�뤥�塞 �஭� �����
           and   al,ah           ;��।��� �஭�
           mov   Old,ah          ;��᫥���� ���祭�� �⠭������ ����
           jz    m1          
           test  al,FirstButt    ;����� ��ࢠ� ������?
           jz    m3          
           not   Way             ;������� ��६����� ���ࠢ�����
           jmp   m1          
m3:        mov   SpeedCX,al      ;��������� ��६����� ᪮���
           mov   Speed,al
m1:        xor   cx,cx
m5:        nop
           loop  m5
           dec   SpeedCX
           jnz   InfLoop           
           mov   al,Speed        ;����⠭��������
           mov   SpeedCX,al      ;���稪 SpeedCX
           mov   al,current      
           test  Way,Clockwise   ;��饭�� �� / ��⨢ �ᮢ��
           jz    m4
           rol   al,1            ;��⨢ �ᮢ�� ��५��
           jmp   m2
m4:        ror   al,1            ;�� �ᮢ�� ��५��
m2:        mov   current,al
           out   0,al            ;�뢮� � ���� [0000h]
           jmp   InfLoop

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS

Stk        SEGMENT use16 STACK
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

END

