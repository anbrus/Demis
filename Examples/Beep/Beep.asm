.386
;������ ���� ��� � �����
RomSize    EQU   4096

Code       SEGMENT use16
           ASSUME cs:Code,ds:Code,es:Code
Start:
InfLoop:
           in    al,0
           out   0,al
           
           jmp   InfLoop

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
