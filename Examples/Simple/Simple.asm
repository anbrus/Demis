RomSize    EQU   4096        ;���� ���

Code       SEGMENT
           ASSUME cs:Code
Start:
           in   al,0         ;��⠥� ���ﭨ� ������
           out  0,al         ;� �뢮��� �� ᢥ⮤����
           jmp  Start


           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
