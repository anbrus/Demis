.386

; ���ᠭ�� ����⠭�
KeysInputPort = 0      ; ����, � ���஬� ������祭� ������
NumberOfButtons = 7    ; ���-�� ������祭��� ������
LengthOfMessage = 32   ; ����� ᮮ�饭��
SimplePeriod = 0FFh    ; ������� ��ਮ� �६���
StateOutputPort = 020h ; ����, � ���஬� ������祭� ��������� ���ﭨ�
LengthOfOutString = 20 ; ���-�� ����� � ����� �������஢    
FirstMatrixPort = 0    ; ���� ���� ������ �������஢
OneTick = 01000           ; �६� ������ �����୮�� ᨣ����
OutputTime = 0A00h    ; �६�, ���� ᨬ���� � �뢮����� ��ப� ���� �� ����

;������ ���� ��� � �����
RomSize    EQU   4096

IntTable   SEGMENT AT 0 use16
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Data       SEGMENT AT 40h use16
;����� ࠧ������� ���ᠭ�� ��६�����
           ; ������
           Buttons           label    byte
           kInput            db    ? ; ����� "����"
           kRusLat           db    ? ; ����� "���/���"(0 - ���᪨�, FF - ���.)
           kState            db    ? ; ����� ������ "���/���"
           kPrevMess         db    ? ; ����� "�।��饥 ᮮ�饭��"
           kNextMess         db    ? ; ����� "������饥 ᮮ�饭��"
           kRight            db    ? ; ����� ������ "�஬���� �����"
           kLeft             db    ? ; ����� ������ "�஬���� ��ࠢ�"
           
           ; ����饭��
           Message1          db    LengthOfMessage dup(?) ; ����饭�� 1
           Message2          db    LengthOfMessage dup(?) ; ����饭�� 2
           Message3          db    LengthOfMessage dup(?) ; ����饭�� 3
           Message4          db    LengthOfMessage dup(?) ; ����饭�� 4
           
           ; �����⥫�
           pCurrentMessage    dw    ? ; ����饥 ᮮ�饭��
           pFirstOutedSimbol  dw    ? ; ���� �뢮���� ᨬ���
           
           ; �����
           EndOfReading     db    ? ; 0 - ᨬ��� �� ���⠭, FF - ᨬ��� ���⠭ 
           LastInputState   db    ? ; 0 - � ���� ࠧ ������ ���� �� �뫠 �����
           MessageLoading   db    ?; 0 - Not input, 1 - input 
           
           ; ��㣨�
           MessageCounter    db    ? ; ���稪 ᮮ�饭��
           CurrentSymbol     db    ? ; ����騩 ᨬ���
           OutputTimeCounter dw    ? ; ���稪 ⠪⮢ �뢮��
           OutputString      db    LengthOfOutString dup(?); �뢮����� ��ப�
           InputTime         dw    ? ; ���稪 �६��� ����� ������ ᨬ���� ��৥
           TickCount         db    ? ; ���-�� �������� ᨣ�����, ��襤�� �� �६� ����� ������ ᨬ����
           CurrentMorzeCode  dw    ? ; ����騩 ��� ��৥
           OutString         db    LengthOfOutString/5 dup(?)   
Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT AT 100h use16
;������ ����室��� ࠧ��� �⥪�
           dw    40 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�
InitData   ENDS

Code       SEGMENT use16

;////////////////////////////////////////////////////////////////////////////////////////////
; ����� ࠧ������� ���ᠭ�� ����⠭�
RussianAlphaBet  db 124,18,17,18,124,127,69,69,69,57,127,69,69,69,58,127,1,1,1,1,96,62,33,62,96,127,69,69,65,65,99,20,127,20,99,34,65,73,77,50,127,16,8,4,127,127,8,20,34,65,124,2,1,1,127,127,4,24,4,127,127,8,8,8,127,62,65,65,65,62,127,1,1,1,127,127,9,9,9,6,62,65,65,65,34,1,1,127,1,1,39,72,72,72,63,14,9,127,9,14,99,20,8,20,99,63,32,32,63,64,7,8,8,8,127,127,64,124,64,127,63,32,60,32,127,127,72,72,48,127,1,127,68,68,56,65,65,73,73,62,127,8,62,65,62,70,41,25,9,127
LatinAlphabet    db 124,18,17,18,124,127,73,73,78,48,31,96,24,96,31,62,65,65,81,114,127,65,65,65,62,127,73,73,73,65,31,32,64,32,31,97,81,73,69,67,0,65,127,65,0,127,12,18,33,64,127,64,64,64,96,127,6,24,6,127,127,4,8,16,127,62,65,65,65,62,127,9,9,9,6,127,9,25,41,70,38,73,73,73,50,1,1,127,1,1,31,32,64,64,127,127,9,9,9,1,127,8,8,8,127,62,65,65,65,34,61,66,66,66,61,0,0,0,0,0,30,33,124,33,30,3,68,120,68,3,99,20,8,20,99,0,0,0,0,0,62,65,64,65,126,125,18,17,18,125
Digits           db 62,81,73,69,62,0,4,2,127,0,66,97,81,73,70,33,73,77,75,49,16,24,20,18,127,71,69,69,69,57,62,69,69,69,57,1,1,1,1,127,54,73,73,73,54,38,73,73,73,62;
DotAndComma      db 0,0,64,0,0, 0,0,80,48,0, 0,0,0,0,0
MorzeSymbols     dw 1011b, 11101010b, 101111b, 111110b, 111010b, 10b, 10101011b, 11111010b, 1010b, 111011b, 10111010b, 1111b, 1110b, 111111b, 10111110b, 101110b, 101010b, 11b, 101011b, 10101110b, 10101010b, 11101110b, 11111110b, 11111111b, 11111011b, 11101111b, 11101011b, 1010111010b, 10101111b, 10111011b, 1111111111b, 1011111111b, 1010111111b, 1010101111b, 1010101011b, 1010101010b, 1110101010b, 1111101010b, 1111111010b, 1111111110b, 101010101010b, 101110111011b, 0
; � ����� �����稢����� ���ᠭ�� ����⠭�
;///////////////////////////////////////////////////////////////////////////////////////////

           ASSUME cs: Code, ds: Data, es: Data

;/////////////////////////////  ��楤���  /////////////////////////////////////////////////
; ��砫쭠� ��⠭���� ��६�����
Beginning        proc  near
                 mov         pCurrentMessage, offset Message1 ; �����⥫� �� ��ࢮ� ᮮ�饭��
                 mov         MessageCounter, 0 ; ���稪 ᮮ�饭�� = 0
                 mov         LastInputState, 0 ; ���砫� ��祣� �� ��������
                 mov         OutputTimeCounter, 0 ; ���稪 �६��� �뢮�� = 0
                 mov         pFirstOutedSimbol, offset Message1 ; ���� �뢮���� ᨬ��� - ���� ᨬ��� ᮮ�饭�� 1
                 mov         word ptr InputTime, 0 ; �६� �����  = 0
                 mov         word ptr InputTime + 2, 0
                 mov         CurrentMorzeCode, 0 ; ����騩 ᨬ��� ��৥ - 0(�஡��)
                 mov         MessageLoading, 0
                 mov         EndOfReading, 0
                 
                 ; ���������� ᮮ�饭�� �஡�����
                 mov         cx, LengthOfMessage * 4
                 mov         di, offset    Message1
             Be1:mov         byte ptr [di], 0   
                 inc         di
                 loop        Be1 
                 ret
Beginning        endp

; �⥭�� ������
ReadKeys         proc  near
           RK0:  in          al, KeysInputPort ; ��⠥� ���ﭨ� ������ �� ����
                 mov         cx, NumberOfButtons ; ����㦠�� � ���稪 �᫮ ������
                 mov         bx, offset Buttons ; ����㦠�� ���� ��ࢮ� ��६����� ������
    NextButton:  shr         al, 1 ; �������� al �� 1, � CF - �뤢����� ���
                 mov         [bx], byte ptr 0 ; � �祩��, ᮮ�. ������ ������ �����뢠�� 0
                 jnc         short RK1 ; �᫨ CF �� ࠢ�� 1, � ���室�� �� RK1
                 mov         [bx], byte ptr 0FFh ; �� CF = 1 ����㦠�� �祩�� ������ �᫮� FF
           RK1:  inc         bx                  ; ���室�� � ᫥���饩 �祩��
                 loop        short NextButton
                 
                 ; ����室��� ����প� ��� ⮣�, �⮡� ������ ����⨫ ������� ������
           RK2:  in          al, KeysInputPort
                 cmp         al, 1000b
                 jnb         RK2
                 ret
ReadKeys         endp

; ��������� �㦭�� ᢥ⮤�����
TypeOut          proc  near
                 mov         al, 1 ; 
                 and         al, kInput ; ��������� �������� "����"
                 cmp         kRusLat, 0 ; 
                 jne         TO1
                 or          al, 00000100b ; ��������� �������� "���"
                 jmp         TO2
            TO1: or          al, 00000010b ; ��������� �������� "���"
            TO2:
            ; ��砫� �⫠��筮� ᥪ樨
                 mov         ah, TickCount
                 shr         ah, 1
                 jnc         TO3
                 or          al, 10000000b
            TO3:
            ; ����� �⫠��筮� ᥪ樨
                 out         StateOutputPort, al ; �뢮� ���� ���ﭨ� � ����
                 ret
TypeOut          endp

; ������ ����⨩ ������ "����"
KeysAnalize      proc  near
                 
                 mov         al, kInput ; � �� - ���ﭨ� ������ "����"
                 ; ���砫� ����室��� �஢����, �� ��������� �� ����� ᮮ�饭��
                 cmp         LastInputState, 0
                 jne         KA0
                 cmp         kInput, 0
                 je          KA0
                 cmp         MessageLoading, 0
                 jne         KA0
                 mov         MessageLoading, 0FFh ; �᫨ ����� ᮮ�饭��, � ������� 䫠� MessageLoading
                 mov         dx, pCurrentMessage
                 sub         dx, 2
                 mov         pFirstOutedSimbol, dx
                 ; ����� � ⠩��஬
           KA0:  nop
                 cmp         MessageLoading, 0;
                 je          KA4
                 cmp         LastInputState, al ; �ࠢ����� ⥪�饣� ���ﭨ� ������ "����" 
                                                ; � ���� ���ﭨ��
                 jne         KA2 ; �᫨ �� ࠢ��, ����� �ந��襫 ����
                 mov         EndOfReading, 0
                 inc         InputTime ; ���� 㢥��稢��� �६� ������
           KA1:  cmp         InputTime , OneTick
                 jb         KA4
                 inc         TickCount
                 mov         InputTime, 0
                 jmp         KA3 ; ����ਬ, �� ��諮 �� �६� �������� ᫥�. ᨬ���� 
                 
                 ; �஢�ઠ �� ��� � ��   
           KA2:  cmp         LastInputState, 0
                 je          KA23 ; �᫨ �ந��諮 ��४��祭�� �� 0 � 1, �㦭� �஢���� ����� ����
                 ; �ந��諮 ��४��祭�� ������ �� 1 � 0, �.�. ������� �窠, ���� ��. 
                 
                 shl         CurrentMorzeCode, 2 ; �������� ��� �� 2 ��� �����, �⮡� � ����� 
                                                 ; �ਯ���� ����祭�� ���
                 cmp         TickCount, 2 ;
                 jnb         KA21 ; �᫨ TickCount > 2 � ��� �����
                 add         CurrentMorzeCode, 10b ; ������� �窠
                 mov         TickCount, 0 ; ����塞 ⨪���� � �६�
                 mov         InputTime, 0
                 jmp         KAFinal ; ��楤�� ����祭�
            KA21:add         CurrentMorzeCode, 11b ; ������� ��    
            KA23:mov         TickCount, 0 ; ����塞 ⨪���� � �६�
                 mov         InputTime, 0
                 jmp         KAFinal ; ��楤�� ����祭�

                 ; �஢�ઠ �� ����� ����� ᨬ����           
           KA3:  cmp         al, 0
                 jne         KAFinal
                 cmp         TickCount, 3; �஢��塞, ���⨣ �� ⨪���� 3
                 jne         KAFinal ; �� ���⨣ - �஢�ઠ ����祭�
                 mov         EndOfReading, 0FFh ; ���⨣ - ������ ᨬ���
                 mov         TickCount, 0 ; ����塞 ⨪���� � �६�
                 mov         InputTime, 0
                 jmp         KAFinal
                 
                 ; �஢�ઠ �� ����� ᮮ�饭��
           KA4:    
      KAFinal:   mov         LastInputState, al ; ��ᢠ����� ��諮�� ���ﭨ� "����" ⥪�饥           
                 ; Ddebug
                 ;mov         CurrentMorzeCode, 101110111011b
                 ;mov         MessageLoading, 0ffh
                 ret
KeysAnalize      endp

; ������ ���� ��৥
CodeAnalize      proc  near
                 cmp         EndOfReading, 0 ; �᫨ ᨬ��� ��䠢�� �� ���⠭, � ��祣� �� ������ 
                 je          CAFinal
                 cmp         MessageLoading, 0
                 je          CAFinal
                 mov         si, offset MorzeSymbols ; ��砫�� ���� ᨬ����� ��৥
                 xor         dh, dh ; �� = 0
                 mov         cx, 42 ; ���-�� ᨬ����� � ��䠢�� ��৥
           CA2:  mov         ax, cs: [si] ; ��⠥� ��� ��৥ �� ⠡����       
                 cmp         CurrentMorzeCode, ax ; �ࠢ������ � ����祭�� �����
                 jne         CA1 
                 mov         CurrentSymbol, dh ; �᫨ ࠢ��, � ���������� ����� ᨬ����
                 jmp         CA3 ; ��諨 ����� ᨬ���� � ��室��
           CA1:  inc         dh ; ������. ����� ᨬ����
                 add         si, size MorzeSymbols ; ��६�頥��� �� ᫥�. ��� ��৥
                 loop        CA2 ; ��横�������
                 mov         CurrentSymbol, 42 ; ������ �� ������ - �㤥� �㫥��
          
          CA3:   mov         CurrentMorzeCode, 0 ; ��諨 ���� ᨬ���� � ⠡���, ����� ���
                                                 ; ᨬ���� ��� 㦥 �� �㦥�
                 ; ����室��� �ਯ���� ᨬ��� � ������-���� ��䠢���
                 cmp         kRusLat, 0
                 je          CA4
                 add         CurrentSymbol, (offset LatinAlphabet - offset RussianAlphabet) / 5
                 jmp         CAFinal
          CA4:   cmp         CurrentSymbol, (offset LatinAlphabet - offset RussianAlphabet) / 5
                 jb          CAFinal
                 add         CurrentSymbol, (offset LatinAlphabet - offset RussianAlphabet) / 5         
       CAFinal:  inc         CurrentSymbol
                 ret
CodeAnalize      endp                

; ��४���⥫� ᮮ�饭��
MessageSwitcher  proc  near
                 ; ��ࠡ�⪠ ������ "�।. ᮮ�饭��"
                 cmp         kPrevMess, 0 ; �஢��塞 ������
                 je          MS1 ; ������ �� ����� - ��祣� �� ������
                 mov         OutputTimeCounter, 0
                 mov         ax, pCurrentMessage ; ����. � �� 㪠��⥫� �� ⥪�饥 ᮮ�饭��
                 cmp         ax, offset Message1 ; �஢��塞, �� 㪠�뢠�� �� �� ��ࢮ� ᮮ��.
                 je          MS0 ; �᫨ �� ��ࢮ� - ��४��砥��� �� 4-�
                 sub         ax, LengthOfMessage ; ���⠥� �� �� ����� ᮮ�饭��, �.�. ��⠥�
                                                 ; �� �।��饥
                 mov         pCurrentMessage, ax ; ��⠭�������� 㪠��⥫� �� �।��饥
                 mov         pFirstOutedSimbol, ax ; ���� �뢮���� ᨬ��� - ��砫� ᮮ�饭��
                 jmp         MSFinal ; �����蠥� ࠡ��� ��楤���
            MS0: mov         pCurrentMessage, offset Message4 ; ��४��砥��� �� 4-� ᮮ�饭��           
                 mov         pFirstOutedSimbol, offset Message4 ; ���� �뢮���� ᨬ��� - ��砫�
                                                                 ; 4-�� ᮮ�饭��
                 jmp         MSFinal ; �����蠥� ��楤���
                 
                 ; ��ࠡ�⪠ ������ "����. ᮮ�饭��"
            MS1: cmp         kNextMess, 0 ; �஢��塞 ������ "����. ᮮ�饭��"
                 je          MSFinal ; ����⨢�� - �����蠥� ࠡ���
                 mov         OutputTimeCounter, 0
                 mov         ax, pCurrentMessage ; ����㦠�� � �� 㪠��⥫� �� ⥪�饥 ᮮ�饭��
                 cmp         ax, offset Message4 ; �� �⢥�⮥ �� ᮮ�饭��?
                 je          MS2 ; �᫨ �⢥�⮥, � ��४��砥��� �� ��ࢮ�
                 add         ax, LengthOfMessage ; ���� ������塞 ����� ᮮ�饭��, �.�. ��४-
                                                 ; ��砥��� �� ᫥���饥
                 mov         pCurrentMessage, ax ; ����. ᮮ�饭�� �⠫� ⥪�騬
                 mov         pFirstOutedSimbol, ax ; ���� �뢮���� ᨬ��� - ��砫� ᮮ��. 
                 jmp         MSFinal ; �����蠥� ��楤���
            MS2: mov         pCurrentMessage, offset Message1 ; ⥪�饥 ᮮ��. - ��ࢮ�
                 mov         pFirstOutedSimbol, offset Message1 ; �����⥫� �� ��砫�           
        MSFinal: 
                 ret
MessageSwitcher  endp

; ���������� ���������� ᨬ���� � ��ப�
CodeConversion   proc  near
                 cmp         MessageLoading, 0 ; �஢�ઠ �� ����㦠������ ᮮ�饭��
                 je          CCFinal ; ����饭�� �� ����㦠���� - �����
                 cmp         EndOfReading, 0 ; �����祭� �� �⥭�� ᨬ����
                 je          CCFinal ; �� �����祭� - �����
                 mov         al, CurrentSymbol ; ����㦠�� � �� ����祭�� ᨬ���
                 inc         pFirstOutedSimbol ; ���頥� 㪠��⥫� �� ᫥�. ����
                 mov         bx, pFirstOutedSimbol ; ����㦠�� � �� ���� ��⠢�� � ᮮ�饭��
                 mov         [bx + 1], al ; ���࠭塞 ᨬ��� �� 㪠������� �����
                 mov         ax, pFirstOutedSimbol ; ����室��� �஢����, �� ��諨 �� �� �࠭��� 
                                                     ; ᮮ�饭��
                 sub         ax, pCurrentMessage ; ����塞 ⥪���� ����� ᮮ�饭��
                 cmp         ax, LengthOfMessage - 1; ����塞 � ���ᨬ��쭮� ������
                 jne         CCFinal ; ����� - �����
                 mov         MessageLoading, 0 ; ���� �ਥ� ����祭
                 dec         pFirstOutedSimbol
                 ;mov al, CurrentSymbol
                 ;mov Message1, al
        CCFinal: ret
CodeConversion   endp

; ����� ��६�饭�� ��ப�
ExamStringShift  proc        near
                 cmp         MessageLoading, 0
                 jne         ESSFinal
                 cmp       kState, 0
                 je        ESS1
                 ; ��⮬���᪠� �஬�⪠
                 inc       OutputTimeCounter ; ����. ���稪 �६��� �뢮��
                 cmp       OutputTimeCounter, OutputTime ; �ࠢ������ ���祭�� ���稪� � ���ᨬ����
                 jne       ESSFinal ; �᫨ �����, � ��祣� �� ������
                 inc       pFirstOutedSimbol ; ���� ��६�頥��� �� ᫥�. ᨬ���
                 mov       OutputTimeCounter, 0 ; ����塞 ���稪
                 ; ����� ����室��� �஢����, �� ��室�� �� ⥪. ᨬ��� �� �࠭��� ᮮ�饭��
                 mov       ax, pFirstOutedSimbol 
                 sub       ax, pCurrentMessage
                 cmp       ax, LengthOfMessage ; � �� - ����ﭨ� �� ��砫� ᮮ�饭�� �� ⥪. ᨬ����
                 jne       ESSFinal
                 mov       ax, pCurrentMessage ; �᫨ ᨬ��� ��襫 �� �࠭���, � ��⠥�
                                                 ; �� ��砫� ᮮ�饭��
                 mov       pFirstOutedSimbol, ax
                 jmp       ESSFinal
                 
                 ; ��筠� �஬�⪠
           ESS1: cmp       kRight, 0 ; ����� �� ������ "��ࠢ�"
                 je        ESS11 ; �� ����� - ���� �����
                 mov       ax, pCurrentMessage ; �஢��塞, �� ��室���� �� 㪠��⥫� � ��砫� ᮮ�饭��
                 cmp       ax, pFirstOutedSimbol ;
                 je        ESSFinal ;
                 dec       pFirstOutedSimbol   ; �⠢�� 㪠��⥫� �� �।��騩 ᨬ���
          ESS11: cmp       kLeft, 0 ; ����� �� ������ "�����"
                 je        ESSFinal ; �� ����� - �����蠥� ࠡ���
                 mov       ax, pCurrentMessage
                 add       ax, LengthOfMessage - LengthOfOutString/5
                 cmp       ax, pFirstOutedSimbol ; �� ��室���� �� 㪠��⥫� � ���� ᮮ�饭��
                 je        ESSFinal
                 inc       pFirstOutedSimbol ; �᫨ �� ��室����, ��६�頥��� �� ᮮ�饭��                 
        ESSFinal:      
                 ret
ExamStringShift  endp

; ������� �뢮����� ��ப�, �ਣ����� ��� �⮡ࠦ���� �� �����
CreateOutputString proc      near
            COS00: ; ����㧪� �뢮����� ��ப�
                   mov       si, pFirstOutedSimbol ; ����. � � ���� ��ࢮ�� �뢮������ ᨬ����
                   mov       di, offset OutString ; � �� - ���� ��砫� ��ப� �뢮��
                   mov       cx, LengthOfOutString/5 ; � ���稪 - ����� ��ப� �뢮��
            COS01: mov       bx, si ; � �� - ���� ⥪�饣� ᨬ����
                   sub       bx, pCurrentMessage ; ����砥� ����ﭨ� �� ��ࢮ�� ᨬ����
                                                 ; ᮮ�饭�� �� ⥪�饣� ᨬ����
                   cmp       bx, LengthOfMessage ; �஢��塞, �� ��諨 �� �� �� �࠭��� ᮮ�饭��
                   jne       COS02
                   mov       si, pCurrentMessage ; �� ��室� �� �࠭��� ��⠥� �� ��砫� ᮮ�饭��
            COS02: mov       al, [si] ; �����㥬 ᨬ��� �� ���筨��
                   mov       [di], al ; � �ਥ����
                   inc       si ; ��������� ����
                   inc       di
                   loop      COS01 ; ������, ���� �� �� ࠢ�� 0
                                       
             COS0: ; ��������� ���ᨢ �⮡ࠦ����
                   mov       si, offset OutString ; ����㧪� � �� ���� ��ࢮ�� �뢮������ ᨬ����
                   mov       di, offset OutputString ; ����㧪� ���� ��ப� �뢮��
                   xor       bx, bx ; bx = 0
                   mov       ch, 4 ; ����㧪� � ch ���-�� ������� �⮡ࠦ����
             COS1: mov       al, [si] ; � al - ᨬ��� ⥪�饣� ᮮ�饭��
                   dec       al ; �⮩ ������� ����� �� �㤥�
                   mov       ah, 5 ; ���� ᨬ��� ��⮨� �� 5 �����
                   mul       ah ; ����砥� ����, � ���஬ �࠭���� ��ࠧ ᨬ����
                   mov       bx, ax ; ��ࠢ�塞 ���� � ������ ॣ����, �⮡� ����� �뫮 ��������
                   mov       cl, 5 ; ����㧪� ���-�� ����� � ����� ᨬ����             
                 COS2: mov       al, cs: [bx] ; ����㦠�� ����� ��ࠧ� ᨬ����
                       mov       [di], al ; ��ࠢ�塞 ����� ᨬ���� � �뢮����� ��ப�
                       inc       di
                       inc       bx
                       dec       cl
                       jnz       COS2
                   inc       si
                   dec       ch    
                   jnz      COS1          
                   ret          
CreateOutputString endp          

; �⮡ࠦ���� ��ப�
StringOut        proc  near
                 lea         bx, OutputString ; ����㧪� ���� ���ᨢ� �⮡ࠦ����
                 mov         cx, LengthOfOutString ; ����㧪� ����� ���ᨢ� �⮡ࠦ����
                 mov         dx, FirstMatrixPort ; ����㧪� ���� ��ࢮ�� ���� �뢮��
            SO1: mov         al, [bx] ; � �� - ����� ���ᨢ� �⮡ࠦ����
                 out         dx, al ; �뢮� ����� � ���� ��
                 inc         bx ; ��६�饭�� �� ᫥������ ����� ���ᨢ� �⮡ࠦ����
                 inc         dx ; ��६������� �� ᫥���騩 ����
                 loop        SO1    ;  
                 ret
StringOut        endp

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
; ������� ���� �ணࠬ��
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Start:     ; ���⥬���� �����⮢��
           mov   ax, Data
           mov   ds, ax
           mov   es, ax
           mov   ax, Stk
           mov   ss, ax
           lea   sp, StkTop
           ; ����� ��⥬��� �����⮢��
           call Beginning ; �㭪樮���쭠� �����⮢��
; ��横������� �����஢��
MainCycle: 
           call ReadKeys ; �⥭�� ���ﭨ� ������
           call TypeOut ; �뢮� ���ﭨ� �� ᢥ⮤����
           call KeysAnalize ; ������ ���ﭨ� ������
           call CodeAnalize ; ������ ��������� ���� ��৥
           call CodeConversion ; �८�ࠧ������ �� ���� ��৥ � ��ଠ��� 祫����᪨� ��
           call MessageSwitcher ; ��४��祭�� ᮮ�饭��
           call ExamStringShift ; ���᫨�� ��६�饭�� ��ப�
           call CreateOutputString ; ������� �뢮����� ��ப�
           call StringOut ; �뢮� ��ப� �� ������� ������ 
           jmp MainCycle

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
