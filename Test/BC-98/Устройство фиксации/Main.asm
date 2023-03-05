.386
;������ ���� ��� � �����

           RomSize    EQU   4096
           
           MaxLoopsForVibrDestr EQU 10h;
           
           ErrorMessgaeLength   EQU 06h; ����� ᮮ�饭�� �� �訡��. 
           DataFixedParamsLen   EQU 06h; ����� ���� ��ࠬ��஢. 
           PointNumLen          EQU 06h; ����� ���� ����� �窨.  
           DataValueLen         EQU 03h; ����� ���� ������, ��ࢮ� � ��ன �ந��.
           
           MaxFixedValue        EQU 4FFFh; ����. �᫮ 䨪��㥬�� ���祭��.
           
                                   ; � ���� 15h
           DataFixedFlag EQU 01h    ; -> �������� "������ ������"
           DataVisioFlag EQU 02h    ; -> �������� "��ᬮ�� ������"
                     
                                   ; ��� "���०�� ࠡ���"  
           DataVisioShowMask    EQU 1Ch;
           DataVisioShowAllFlag EQU 04h; -> �������� "��ᬮ�� ��� ������".
           DataVisioShowMaxFlag EQU 08h; -> �������� "��ᬮ�� ���ᨬ.".
           DataVisioShowMinFlag EQU 10h; -> �������� "��ᬮ�� �����.".
           
           DataParamsMask   EQU 0E0h; ��᪠ �뤥����� ᫥�. ��ࠬ��஢.
           DestroyFixedParam EQU 9Fh; ��᪠ 㤠����� ��ࠬ��஢ 䨪�樨
           DataFixedParamTd EQU 20h; -> �������� "��ਮ� ����⨧�樨".
           DataFixedParamT  EQU 40h; -> �������� "��१�� �६���".
           DataVisioParamN  EQU 80h; -> �������� ����� �窨 
           
           WorkStatusesOutPort EQU 15h; ���� ���� ��� ��������� 
           WorkStatusesInPort  EQU 00h;
           
           KeyBoardOutPort     EQU 16h; ���� ���� ���������� 
           KeyBoardInPort      EQU 01h;
           
           DataFixedParamPort  EQU 00h;
           DataVisioPort       EQU 06h;
           DataVisioFirstPort  EQU 09h;
           DataVisioSecondPort EQU 0Ch;
           PointNumberPort     EQU 0Fh;  
           
           ADCOutPort          EQU 17h
           ADCInPortStatus     EQU 02h
           ADCInPortData       EQU 03h;
           
           DefaultButsDataMask EQU 0FFh;
           FixedDataButsMask   EQU 03h; ����� ������ ⮫쪮 "����." � "����"
           DataVisioButsMask   EQU 0FDh; ����� ������ ��, �஬� "����" 
           
           EnterButtonIndex    EQU 0Ch;
           PointNumButIndex    EQU 0Dh;
           TimeLenButIndex     EQU 0Eh;
           PeriodDsButIndex    EQU 0Fh;
           MaxButtonIndex      EQU 0Fh; 
           
IntTable   SEGMENT AT 0 use16  ;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Data       SEGMENT AT 0A000h use16  ;����� ࠧ������� ���ᠭ�� ��६�����

           WorkStatusesData db ?    ;���. � ०��� � ���०��� ࠡ���. 
           DigitsImages db 10 dup (?); �⮡ࠦ���� �������� ���

           ButtonsData  db ?;    ���ﭨ� ������. ( 00 - ����� ���������� )
           ButtonsDataMask db ?; ��᪠ ���ﭨ� ������, �ᯮ������ ��� �業��
                               ; ࠧ�襭�� ��ࠡ�⪨ 
           
           KeyBoardImage db 4 dup (?); ��ࠧ ����������
           KeyBoardData db ?         ; ��।��� ���. ( FF - ����� ���������� )
           
           IsErrorFound db ?   ; 䫠���� ���� �訡��.
           ErrorOutPort db ?   ; ���� ��� �뢮�� �訡��.
           
           IsDataFixedNow db ? ; 䫠���� ���� 䨪�樨 ������.
           DataFixedPeriod dd ?; ��ਮ� ����⨧�樨
           DataFixedTimeLn dd ?; ��१�� �६��� ��� 䨪�樨 ������.
           DataVisioPointNum dd ?; ����� �窨
           MaxPointNumber    dd ?; ���ᨬ��쭮� �᫮ �祪.
           IsPointNumUpDate  db ?; ��������� �� ����� �窨 ( 0 - False ).

           TempDigitsArr     db 3 dup (?); ���ᨢ �६������ �࠭���� ���祭��.
           PeriodKoofArr     db 4 dup (?); ���ᨢ ����樥�⮢.
           TimeLenKoofArr    db 4 dup (?); ���ᨢ ����樥�⮢.
           PointNumKoofArr   db 4 dup (?);
           
           DataValue         dw ?; ���祭�� ��. ��ࠬ��� ��� DataVisioPointNum.
           FirstValue        dw ?; ���祭�� 1-�� �ந������� � �窥 DataVisioPointNum
           IsFOtr            db ?;
           SecondValue       dw ?;
           IsSOtr            db ?;

;          ����� ���� ���ᠭ�� ���ᨢ�� �⮡ࠦ���� 
           UnVisibleData db 6 dup (?); ��� ��襭�� ����ࠦ����.
           
           PeriodDataObr db 6 dup (?); ��� ��ਮ�� ����⨧�樨
           TimeLnDataObr db 6 dup (?); ��� ��१�� �६��� ��� 䨪�樨 ������.
           
           PointNumberObr db 6 dup (?); ��� ����� �窨
           
           DataObr        db 4 dup (?); ��� ���� ������.
           FirstProizvObr db 4 dup (?); ��� ���� ��ࢮ� �ந�������.
           SecondProizvObr db 4 dup (?); ��� ��ன ��ࢮ� �ந�������.

; 
           DataFixedValue dw MaxFixedValue dup (?); ���ᨢ ��䨪�஢����� ���祭��.
                    
Data       ENDS

InitData   SEGMENT use16
           DigitsImagesCns db 03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh;

           ErrorImage db 060h, 078h, 060h, 060h, 073h, 00h;
           
           
InitData   ENDS

Steck        SEGMENT AT 0B000h use16 
           dw    200 dup (?)
StkTop     Label Word
Steck        ENDS

Code       SEGMENT use16    
           
           ASSUME cs:Code,ds:Data,es:Data,ss:Steck;

include InitData.asm;
include IOProc.asm
include KeyBoard.asm
include FixedDt.asm;
include SetParam.asm;
include DataProc.Asm;
          
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Steck
           mov   ss,ax
           lea   sp,StkTop

           CALL WorkInit          ; ���樠������ ࠡ���.

Program_StartPoint : 
           
           Call GetButtonsData;
           Call CheckButtonsData;
           Call GetKeyBoardInput;
           Call GetKeyBoardData;
           Call CheckKeyBoardData;
           
           mov al, IsPointNumUpDate
           test al, al
           jz Program_DataNotUnDate
           call UpDateDataFields 
                      
Program_DataNotUnDate:                      
           Call CreateObrazArrays; ��ନ஢��� ���ᨢ� �⮡ࠦ����.
           Call UpdateOutdevices; �������� ���ﭨ� ���⮢ �뢮��.
          
           jmp Program_StartPoint;

           
;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-(( SIZE InitData + 15 ) and 0FFF0h )
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
