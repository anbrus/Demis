.386

RomSize    EQU   4096

Code       segment use16
           assume cs:Code,ds:Code,es:Code

Image      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh    ;��ࠧ� 16-����� ᨬ�����
           db    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h    ;�� 0 �� F

Start:
           mov   ax,Code
           mov   ds,ax
           mov   es,ax
;����� ࠧ��頥��� ��� �ணࠬ��

           lea   bx,Image

StartADC:                    ;����᪠�� �८�ࠧ������ �����ᮬ \_/
                             ;�८�ࠧ������ ��稭����� �� �஭�� ������
           mov   al,0
           out   0,al
           mov   al,1
           out   0,al
           
WaitRdy:
           in    al,1        ;��� ������� �� ��室� Rdy ��� - �ਧ���
                             ;�����襭�� �८�ࠧ������
           test  al,1
           jz    WaitRdy
           
           in    al,0        ;���뢠�� �� ��� �����
           
           mov   ah,al       ;�८�ࠧ㥬 � �뢮��� �� ���������
           and   al,0Fh
           xlat
           out   1,al        ;�뢮��� ������� ��ࠤ�
           mov   al,ah
           shr   al,4
           xlat
           out   2,al        ;� ⥯��� ������
           
           jmp   StartADC    ;� ��稭��� ���� ��� ������

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end
