;������ ���� ��� � �����
RomSize    EQU   4096

HorLinePort   EQU   0        ;16-� ���� ���� ��� ��ਧ��⠫��� ����� ������
MatrSelPort   EQU   2        ;8-� ���� ���� ��� �롮� ������
VertLinePort  EQU   4        ;8-�� ���� ���� ��� ���⨪����� ����� ������
ADCStartPort  EQU   5        ;���� �ࠢ����� ����᪮� ���
ADCStatePort  EQU   1        ;���� ���ﭨ� ���
ADCValuePort  EQU   0        ;���� ������ ���
KeyPort       EQU   2        ;���� ������
IndicPort     EQU   7        ;���� �������஢
PlusMask      EQU   1        ;��᪠ ������ +
MinusMask     EQU   2        ;��᪠ ������ -
KbdCounterMax EQU   10       ;����প� ��। ����୮� ॠ�樨 �� ������
DelayValue    EQU   50     ;����প� ��� �࣠����樨 ��ਮ�� ����⨧�樨 (2000).
                             ;������ �� ����த���⢨� ��������

IntTable   SEGMENT AT 0 use16
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Data       SEGMENT AT 40h use16
;����� ࠧ������� ���ᠭ�� ��६�����
OscImage   dw    80 dup (?)
DiscrTime  dw    ?           ;��ਮ� ����⨧�樨 � 2-10 �ଠ�
KbdCounter dw    ?           ;���稪 ����প� ���� ������
DelayCounter dw  ?           ;���稪 ����প� ����⨧�樨
NewADCVal  db  ?             ;���� ������ ���
OldADCVal  db  ?             ;�।��騩 ������ ���
Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT AT 80h use16
;������ ����室��� ࠧ��� �⥪�
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�
InitData   ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

;��ࠧ� ��� �� 0 �� 9
NumImage   db    03fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh

           ASSUME cs:Code,ds:Data,es:Data

;��楤�� �⮡ࠦ��� ⥪�騩 ��ਮ� ����⨧�樨 �� ���������
ShowDiscrTime    proc near
           xor   ah,ah
           mov   al,Byte Ptr DiscrTime
           lea   bx,NumImage
           add   bx,ax
           mov   dl,cs:[bx]      ;dl:=��ࠧ ������� ����� ᥪ㭤�
           mov   al,Byte Ptr DiscrTime+1
           lea   bx,NumImage
           add   bx,ax
           mov   dh,cs:[bx]      ;dh:=��ࠧ 楫�� ᥪ㭤
           mov   ax,dx
           or    ah,080h         ;����� ���� ��᫥ 楫�� ᥪ㭤
           out   IndicPort,ax
           
           ret
ShowDiscrTime    endp

;��楤�� �믮���� ��砫��� ���樠������ �ࠧ� ��᫥ ����祭��
Initialize proc  Near
           ;���樠������ ��ࠧ�
           lea   di,OscImage
           mov   cx,LENGTH OscImage
           mov   ax,080h
           rep   stosw
           
           ;���樠������ ��ਮ�� ����⨧�樨
           mov   DiscrTime,0001h
           call  ShowDiscrTime
           
           ;���樠�����㥬 ����稪 ���� ������
           mov   KbdCounter,0
           ;����稪 ����প� ����⨧�樨
           mov   DelayCounter,0
           
           mov   NewADCVal,8
           mov   OldADCVal,8
           
           ret
Initialize endp

;�뢮��� ��⮢� ��ࠧ �� ������ ���������
ShowOscImage     proc Near
           lea   si,OscImage     ;�����⥫� �� ⥪�騩 �⮫���
           mov   cx,80           ;����稪 �⮫�����
           mov   bl,1            ;����稪 �⮫����� ����� ����� ������
           mov   dx,1            ;����稪 �����

ShowNextCol:
           ;��ᨬ ������
           xor   ax,ax
           out   MatrSelPort,ax
           
           ;�뢮��� ⥪�騩 �⮫���
           lodsw
           out   HorLinePort,ax
           
           ;��⨢��㥬 ���⨪���� �⮫���
           mov   al,bl
           out   VertLinePort,al
           
           ;��⨢��㥬 ������
           mov   ax,dx
           out   MatrSelPort,ax
           
           ;���室�� � ᫥���饬� �⮫����
           mov   al,bl
           shl   al,1
           jnc   NoChangeMatrix
           mov   al,1
           shl   dx,1
NoChangeMatrix:
           mov   bl,al
           
           loop  ShowNextCol

           ;��ᨬ ������
           xor   ax,ax
           out   MatrSelPort,ax

           ret
ShowOscImage     endp

;������� ⥪�饥 ���祭�� ����殮��� � �����頥� ��� � al
GetADCValue      proc near
           ;�����⨫� ����७��
           mov   al,1
           out   ADCStartPort,al
           xor   al,al
           out   ADCStartPort,al
           
           ;�������, ���� ��� ���㬠��
ADCReady:
           in    al,ADCStatePort
           and   al,1
           jz    ADCReady
           
           mov   al,NewADCVal
           mov   OldADCVal,al
           ;����� ���� �����
           in    al,ADCValuePort
           ;������� �� 16, �⮡� ������ � ���� ������
           shr   al,4
           mov   NewADCVal,al
           
           ret
GetADCValue      endp

;�������� ��ࠧ ��樫���ࠬ�� � ᮮ⢥��⢨� � ���� �����⮬
UpdateOscImage   proc near
           ;���� ��ࠧ ���� ᤢ����� �� ���� �⮫��� ��ࠢ�
           std
           lea   si,OscImage+SIZE OscImage-4
           mov   di,si
           add   di,2
           mov   cx,LENGTH OscImage-1
           rep   movsw
           cld
           
           ;� ����� ���祭�� �������� � ���� �⮫���
           ;��ନ�㥬 ��ࠧ �⮫����
           mov   al,NewADCVal
           cmp   al,OldADCVal
           jz    @NewOld
           jnc   @NewBOld

           ;���� ������ ����� ��ண�
           mov   al,OldADCVal
           sub   al,NewADCVal
           mov   cl,al
           mov   bl,al
           mov   ax,8000h
           xor   ch,ch
@ShLeft:
           stc
           rcr   ax,1
           loop  @ShLeft

           mov   cl,NewADCVal
           shr   ax,cl
           jmp   @ShEnd
           
@NewBOld:
           ;���� ������ >= ����
           mov   al,NewADCVal
           sub   al,OldADCVal
           mov   cl,al
           mov   ax,1
           xor   ch,ch
@ShRight:
           stc
           rcl   ax,1
           loop  @ShRight

           mov   cl,15
           sub   cl,NewADCVal
           shl   ax,cl
           jmp   @ShEnd

@NewOld:
           ;���� ������ = ����
           mov   ax,8000h
           mov   cl,NewADCVal
           shr   ax,cl

@ShEnd:
           mov   [OscImage],ax
           
           ret
UpdateOscImage   endp

;�஢���� ���ﭨ� ������ "+" � "-" � ᮮ⢥�����騬 ��ࠧ�� �������
;��ਮ� ����⨧�樨
CheckKeys  proc  near
           ;������ �஢��塞 ⮫쪮 �१ �����஥ �६� ��᫥
           ;��ࢮ�� ������
           cmp   KbdCounter,0
           jz    KbdReady
           dec   KbdCounter
           jmp   ExitProc

KbdReady:
           in    al,KeyPort
           
           ;� ����� �� ������?
           mov   ah,PlusMask
           or    ah,MinusMask
           and   al,ah
           jz    ExitProc    ;��祣� �� ������

           ;�� �����६����� ����⨥ ��� ������ �� ॠ���㥬
           cmp   al,ah
           jz    ExitProc
           
           ;��ࠡ�⠥� ������ "+"
           test  al,PlusMask
           jz    CheckForMinus   ;������ ����� ������
           mov   ax,DiscrTime    ;� ����� �� 㢥��稢��� ��ਮ� ����⨧�樨?
           cmp   ax,00100h
           jz    ExitProc        ;����� 㢥��稢��� ��ਮ� ����⨧�樨
           add   al,1
           aaa                   ;��ਮ� � ��� � 2-10 �ଠ�, ���४��㥬
           mov   DiscrTime,ax
           ;������ �����஥ �६� �� ������ ������ �� ॠ���㥬
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;������� ���������
           jmp   ExitProc

CheckForMinus:
           ;��ࠡ�⠥� ������ "-"
           test  al,MinusMask    ;������ ����� ������
           jz    ExitProc
           mov   ax,DiscrTime
           cmp   ax,00001h       ;� ����� �� 㬥����� ��ਮ� ����⨧�樨?
           jz    ExitProc
           sub   al,1
           aas                   ;��ਮ� � ��� � 2-10 �ଠ�, ���४��㥬
           mov   DiscrTime,ax
           ;������ �����஥ �६� �� ������ ������ �� ॠ���㥬
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;������� ���������

ExitProc:           
           ret
CheckKeys  endp

;��楤�� �࣠����� ����প� ��� �ନ஢���� ��ਮ�� ����⨧�樨
DelayProc  proc  near
           mov   cx,DelayValue
DelayLoop1:
           mov   ax,100
DelayLoop2:
           dec   ax
           jnz   DelayLoop2
           loop  DelayLoop1

           ret
DelayProc  endp

DEL        proc near
           dec   DelayCounter
           ret
DEL        endp              

Count   proc  near

           ;���� DelayCounter<>0 ����� ���祭�� � ��� ���� �� �㤥�
           ;�� ��ࠧ �� ������ �㦭� ���������, ���� ��� �������
           cmp   DelayCounter,0
           jnz   DiscrEnd

           ;��⠭���� DelayCounter � ᮮ⢥��⢨� � ��ਮ��� ����⨧�樨
           mov   ax,DiscrTime
           or    ah,ah
           jz    AH0
           add   al,10
           xor   ah,ah
AH0:
           mov   DelayCounter,ax
           
           ;call  GetADCValue
           ;call  UpdateOscImage
           
           ret
Count   endp   
        
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;����� ࠧ��頥��� ��� �ணࠬ��

           call  Initialize
           
MainLoop:
           call  ShowOscImage
           
           call  Count  
           
           call  GetADCValue
           call  UpdateOscImage
DiscrEnd:
           call  DEL
           call  CheckKeys
           call  DelayProc
           
           jmp   MainLoop


;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
