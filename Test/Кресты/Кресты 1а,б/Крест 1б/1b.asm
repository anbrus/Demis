.386
;������ ���� ��� � �����
RomSize    EQU   4096

Data       SEGMENT AT 40h use16
;����� ࠧ������� ���ᠭ�� ��६�����
Old        db    ?
FlagLamp   db    ?
Data       ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

           ASSUME cs:Code,ds:Data,es:Data
Start:
;����� ࠧ��頥��� ��� �ணࠬ��
           in al, 0  ;���� �����
           mov ah, al ;��࠭塞 ⥪�饥 ���祭��, �.�. �ᯮ�⨬ ���
           xor al, Old ;�뤥�塞 �஭��
           and al, ah  ;�뤥�塞 ��।��� �஭��
           mov Old, ah ;
           jz m1       
           not FlagLamp ;�������㥬 䫠�
           mov al,FlagLamp
           out 0, al

m1:        jmp Start

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
