.386
;������ ���� ��� � �����
RomSize    EQU   8192

IntTable   SEGMENT use16 AT 0
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
           org   32*4
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

Int32Handler     PROC FAR
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
           mov   al,  74h
           out   43h, al
           mov   al,  10
           out   41h, al
           mov   al,  0
           out   41h, al
           
           ret
InitFlash  ENDP

InitCounter      PROC  NEAR
           xor   ax, ax
           mov   IntCounter, ax
           
           mov   al,  0B4h
           out   43h, al
           mov   al,  10
           out   42h, al
           mov   al,  0
           out   42h, al
           
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
           
           call  InitFlash
           call  InitCounter
           sti
           
           ;call  TestMode0
           ;call  TestMode1
           ;call  TestMode2
      
           int   20h     
MLoop:
           call  ShowCounter
           hlt
           jmp   MLoop

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END		Start
