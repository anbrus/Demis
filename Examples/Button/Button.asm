.386

RomSize    EQU   4096

Code       segment use16
           assume cs:Code,ds:Code,es:Code

           ;��ࠧ� �������� ��� �� 0 �� 9
Image      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh

Start:
           mov   ax,Code
           mov   ds,ax
           mov   es,ax
;����� ࠧ��頥��� ��� �ணࠬ��

           xor   cl,cl       ;cl - ����稪 �᫠ ����⨩ � �ଠ� BCD
           lea   bx,Image    ;bx - 㪠��⥫� �� ���ᨢ ��ࠧ��
           mov   al,[bx]     ;�뢮��� �㫨 �� ���������
           out   0,al
           out   1,al
           
WaitBtnDown:
           in    al,0        ;��� ������ ������
           test  al,1
           jnz   WaitBtnDown
WaitBtnUp:
           in    al,0        ;��� ���᪠��� ������
           test  al,1
           jz    WaitBtnUp
           
           mov   al,cl       ;���६����㥬 ����稪 �᫠ ����⨩
           add   al,1
           daa               ;��⠥� � ����筮-�����筮� ����!
           mov   cl,al
           
           mov   ah,al       ;������ �뢮��� �᫮ ����⨩ �� ���������
           and   al,0Fh
           xlat
           out   0,al
           mov   al,ah
           shr   al,4
           xlat
           out   1,al
           
           jmp   WaitBtnDown ;� ��稭��� ��� ������

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end
