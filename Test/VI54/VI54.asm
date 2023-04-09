.386
;������ ���� ��� � �����
RomSize    EQU   16384

IntTable   SEGMENT use16 AT 0
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
           org   20h*4        ; �� �⮬� ᬥ饭�� ��室���� ���� ��ࠡ��稪� ���뢠��� 20h
Int32HandlerPtrOffs dw ?
Int32HandlerPtrSeg  dw ?
IntTable   ENDS

Data       SEGMENT use16 AT 40h
;����� ࠧ������� ���ᠭ�� ��६�����
IntCounter dw ?
Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT use16 AT 100h
;������ ����室��� ࠧ��� �⥪�
           dw    100h dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
InitDataStart:
;����� ࠧ��頥��� ���ᠭ�� �������塞�� ������, ����� ���� �࠭����� � ���
InitDataEnd:
InitData   ENDS

Code       SEGMENT use16
;����� ࠧ��頥��� ���ᠭ�� �������塞�� ������

           ASSUME cs:Code, ds:Data, es:Data, ss: Stk

include    utils.asm
include    mode0.asm
include    mode1.asm
include    mode2.asm
include    mode3.asm
include    mode4.asm
include    mode5.asm

Int32Handler     PROC FAR    ; ��ࠡ��稪 ���뢠��� 20h
           push  ax
           push  ds
           
           mov   ax, Data
           mov   ds, ax
           inc   IntCounter
           
           pop   ds
           pop   ax
           iret
Int32Handler     ENDP

InitFlash  PROC  NEAR
           ; �ணࠬ���㥬 ⠩��� 1: ०�� 2, �����樥�� ������� 10
           ; ����� 2 �룫廊� ⠪: ----_----_----_- ...
           mov   al,  74h
           out   43h, al
           mov   al,  10
           out   41h, al
           mov   al,  0
           out   41h, al
           
           ret
InitFlash  ENDP

InitCounter      PROC  NEAR
           ; ����塞 ����稪 ���뢠���
           xor   ax, ax
           mov   IntCounter, ax
           
           ; �ணࠬ���㥬 ⠩��� 2: ०�� 2, �����樥�� ������� 10
           ; ����� 2 �룫廊� ⠪: ----_----_----_- ...
           mov   al,  0B4h
           out   43h, al
           mov   al,  10
           out   42h, al
           mov   al,  0
           out   42h, al
           
           ; ��⠭���� ��ࠡ��稪� ���뢠���
           push  ds
           mov   ax, IntTable
           mov   ds, ax
           mov   ax, cs:Int32Handler
           mov   ds:Int32HandlerPtrOffs, ax
           mov   ax, Code
           mov   ds:Int32HandlerPtrSeg, ax
           pop   ds
           
           ret
InitCounter      ENDP

           ; �뢮��� ᮤ�ন��� ����稪� ���뢠��� � ���� 20h
ShowCounter      PROC NEAR
           mov   ax,  IntCounter
           out   20h, al
           ret
ShowCounter      ENDP

Start:
           mov   ax, Data
           mov   ds, ax
           mov   es, ax
           mov   ax, Stk
           mov   ss, ax
           lea   sp, StkTop
;����� ࠧ��頥��� ��� �ணࠬ��
           
           call  InitFlash   ; ���樠������ ⠩��� �����饣� ᢥ⮤����
           call  InitCounter ; ���樠������ ⠩��� � ����稪�� ���뢠���
           sti
           
           ; ����� ०���� ⠩��� ᮣ��᭮ ��樫���ࠬ� �� ���㬥��樨
           ; ����� 8254.pdf �� ����� �஥��
           call  TestMode0
           call  TestMode1
           call  TestMode2
           call  TestMode3
           call  TestMode4
           call  TestMode5
      
           int   20h         ; �஢�ઠ �ணࠬ����� �맮�� ���뢠���
MLoop:
           call  ShowCounter ; ���������� ���� �뢮�� ����稪� ���뢠���
           hlt               ; ��� ���뢠���
           jmp   MLoop       ; ��᪮���� 横�

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END	   Start
