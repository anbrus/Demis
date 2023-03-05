.386
RomSize    EQU   4096
NMatrix    EQU   2           ;���� �롮� ����筮�� �������� 
NStolb     EQU   1           ;���� �롮� �⮫��
NImage     EQU   0           ;���� �롮� ����ࠦ���� � �⮫���
NumMatrix  EQU   3           ;������⢮ ������� �������஢
ACPRdy     EQU   0           ;���� ��� ���� Rdy
ACPOut     EQU   1           ;���� ��� ���� Out
ACPStart   EQU   2           ;���� ��� ���� Start
Keyboard   EQU   0           ;���� ������ (�,�,�)
Mercanie   EQU   30h         ;"���栭��" - ������⢮ ������ 横��� �� 65535 ࠧ, �⮡� �㪢� �� ��������

Data       SEGMENT use16 AT 100h
Vyvod      db    32 dup(?)   ;�ਤ�⨤��� ���� ���ᨢ, ����� ����ﭭ� �뢮����� �� ��ᯫ��
OffstVyvod db    ?           ;��६����� ��� ⮣�, �⮡� ������ �� ���ᨢ� Vyvod
SpeedCX    db    ?           ;����稪 ᪮��� (�������), ���������塞� �� ��६����� Speed
Speed      db    ?           ;����稪 ᪮��� (�� �������)
CurrNum    db    ?           ;����騩 ����� �㪮���, ����� ������ �� ��ᯫ�� (0,1,2) � ����� �㤥� ��१���ᠭ� �������
Old        db    ?           ;��६����� ��� �뤥����� ��।���� �஭� �����
Data       ENDS

Code       SEGMENT use16
           ASSUME cs:Code,ds:Data,es:Code,ss:Stk
Image      db    00000000b,11111111b,00000001b,00000001b,00000001b,00000001b,11111111b,00000000b    ;�
           db    00000000b,11111111b,00010001b,00010001b,00010001b,00010001b,00001110b,00000000b    ;�
           db    00000000b,01111110b,10000001b,10000001b,10000001b,10000001b,10000001b,00000000b    ;�

Clear      MACRO Port        ;��楤�� ���⪨ �������஢. �뢥���� ��� 㤮����� � ����來���
           xor   al,al
           out   Port,al
           ENDM

Prepare    PROC  NEAR        ;�����⮢��
           xor   ax,ax
           lea   si,Vyvod
           mov   cx,size Vyvod
PodgotM1:  mov   al,0        ;����塞 ���ᨢ Vyvod, �.�. ��� ���ᨢ - ����᪨� �����
           mov   [si],al
           inc   si
           loop  PodgotM1
           mov   CurrNum,al
           mov   OffstVyvod,al
           mov   CurrNum,al
           mov   Old,al
           mov   al,0111b    ;0111b - � ��� ⠪�� ���祭�� ����砫쭮 ���⠢���� �� ��� (0.00).
                 
                 ;        1) ���뢠�� � ���� � al, ����砥� 00000000b
                 ;        2) ������ ������ not al, ����砥� 11111111b
                 ;        3) ����� ������ shr al,5 ����砥� 00000111b
           mov   Speed,al
           mov   SpeedCX,al
           RET
Prepare    ENDP

Displ      PROC  NEAR
           mov   dl,00000001b    ;���� ������ ��������
           mov   cx,NumMatrix
           lea   si,Vyvod
           xor   bh,bh
           mov   bl,OffstVyvod
DisplM1:   Clear NStolb
           mov   al,dl
           out   NMatrix,al
           push  cx
           mov   cx,8
DisplM2:   Clear NStolb
           mov   al,[si+bx]
           out   NImage,al
           xor   al,al
           stc                   ;��������� 䫠� CF=1 (���� ��७��)
           rcr   al,cl           ;ᤢ�� ��ࠢ�, ����砥� ����� �⮫��, � ����� �㤥� �뢮���� ����ࠦ����
           out   NStolb,al
           inc   bl              ;�⮡ �� 㯮��� �� 32 ���� ���ᨢ� vyvod, �� ��९������� ᤢ������� ���砫�
           cmp   bl,size Vyvod - 1
           jne   DisplM3
           xor   bl,bl
DisplM3:   loop  DisplM2
           rol   dl,1            ;᫥���騩 ������ ��������
           pop   cx
           loop  DisplM1
           Clear NStolb
           RET
Displ      ENDP

Delay      PROC  NEAR
           xor   cx,cx
DelayM1:   loop  DelayM1
           dec   SpeedCX
           jnz   DelayM2
           mov   al,Speed
           mov   SpeedCX,al
           mov   cx,Mercanie
DelayM4:   push  cx
           xor   cx,cx
DelayM3:   loop  DelayM3
           pop   cx
           loop  DelayM4
           inc   OffstVyvod
           cmp   OffstVyvod,size Vyvod - 1
           jne   DelayM2
           mov   OffstVyvod,ch
DelayM2:   RET
Delay      ENDP

ACP        PROC  NEAR
           mov   al,00001000b    ;4-� ���� ������祭� � Start � ���
           out   ACPStart,al
ACPM1:     in    al,ACPRdy
           test  al,1
           jz    ACPM1
           xor   al,al
           out   ACPStart,al
           in    al,ACPOut
           not   al
           shr   al,5
           or    al,1
           mov   Speed,al
           RET
ACP        ENDP

KeyRead    PROC  NEAR
           in    al,Keyboard
           not   al
           shr   al,5
           mov   ah,al
           xor   al,Old
           and   al,ah
           mov   Old,ah
           RET
KeyRead    ENDP

Print      PROC  NEAR
           or    al,al
           jz    PrintM3
           xor   ah,ah
PrintM1:   inc   ah
           shr   al,1      ;�� 㭨�୮�� � ������ ����樮���
           jnz   PrintM1
           dec   ah
           shr   ax,5         ; shr ax,8 - ��७�ᨬ �� ah � ax, ��⨬ ah, shl al, 3 - 㬭����� al �� 8
           lea   bx,Image
           add   bx,ax
           lea   si,Vyvod
           mov   al,CurrNum  ; 0,1,2. ����� �㪮���
           xor   ah,ah
           shl   ax,3
           add   si,ax
           inc   CurrNum
           cmp   CurrNum,3
           jne   PrintM4   ;�᫨ �� ࠢ�� 3
           mov   CurrNum,0
PrintM4:   mov   cx,8
PrintM2:   mov   al,es:[bx]
           mov   [si],al
           inc   bx
           inc   si
           loop  PrintM2
PrintM3:   RET
Print      ENDP

Start:     mov   ax,Data
           mov   ds,ax
           mov   ax,Code
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           call  Prepare
InfLoop:   call  KeyRead
           call  Print
           call  Displ
           call  Delay
           call  ACP
           jmp   InfLoop

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS

Stk        SEGMENT use16 STACK
           org 10h 
           dw  5 dup(?)
StkTop     LABEL Word
Stk        ENDS

END