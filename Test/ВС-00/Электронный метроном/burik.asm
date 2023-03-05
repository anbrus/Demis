RomSize    EQU   4096
NMax       EQU   50          ; ����⠭� ���������� �ॡ����
KbdPort    EQU   99h           ; ���� ���⮢

MaxLoopInProc   EQU         100    ; ���ᨬ��쭮� ������⢮ 横��� � ��楤��
StartTempo      EQU         100    ; ���⮢� ⥬� � ��. ०.
StartTact       EQU         10     ; ������⢮ ⠪⮢ � ��. ०.

;--------------������� �⥪�--------------------------------------------------------
Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS
;--------------������� ������-------------------------------------------------------
Data       SEGMENT AT 0
      ;------------------------------- �㦥��� �����
           KbdImage          DB    8 DUP(?)     ; �����筮-��⭠����. ��� ��।�. ������. ����(� �����)
           EmpKbd            DB    ?            ; ����� �����
           KbdErr            DB    ?            ; �訡�� �����
           dex               DW    ?     
           up                DW    ?    ; ���孨� ����
           down              DW    ?    ; ������ ����
           left              DW    ?    ; ���� ����   

       ;----------------------------- ��騥 ��६����
           ProgramMode       DB    ?            ; ⥪�騩 ०�� �ணࠬ��஢����(1 - �ண�., 0 - ���ண�.)
           InitMode          DB    ?            ; ⥪�騩 ०�� ���樠����樨(1 - ���樠������, 0 - ���)
           IsStarted         DB    ?            ; ࠡ�⠥� ��� ���
           TickIndicator     DB    ?            ; ��᪠ ��������
           CurrentTempo      DW    ?            ; ⥪�騩 ⥬� 
           DigitsTempo       DB    3 DUP(?)     ; ⥪�騩 ⥬� (�⮡ࠦ���� ����)
           NameTempo         DW    3 Dup(?)     ; �������� ⥪�饣� ⥬��
       ;----------------------------- ��६���� ���ண�. ०.
           LoopInTickNPM     DW    ?            ; ������⢮ 横��� � ⨪� � ���ண�. ०���
           LoopCounterNPM    DW    ?            ; ⥪�饥 ������⢮ 横��� � ���ண�. ०��� 
           Tempo             DW    ?            ; ⥬� � ���ண�. ०.
       ;----------------------------- �६���� �ண�. ०.
           EditTact          DB    ?            ; ।����㥬 ⠪� ��� ���
           LastPart          DW    ?            ; ��᫥���� ����
           CurrentPart       DW    ?            ; ⥪��� ����
           CurrentTick       DW    ?            ; ⥪�饥 ������⢮ ⨪�� � ⥪�饩 ���
           LoopInTickPM      DW    ?            ; ������⢮ 横��� � ⨪� � �ண�. ०���
           LoopCounterPM     DW    ?            ; ⥪�饥 ������⢮ 横��� � �ண�. ०��� 
           DigitsPart        DB    2 DUP(?)     ; ⥪��� ���� (�⮡ࠦ���� ����)
           DigitsTact        DB    3 DUP(?)     ; ������⢮ ⠪⮢ � ⥪�饩 ��� (�⮡ࠦ���� ����)
           TactPart          DW    99 DUP(?)    ; ⠪⮢ � ������ ���
           TempoPart         DW    99 DUP(?)    ; ⥬�� � ������ ���
           
Data       ENDS
;---------------������� ����---------------------------------------------------------
Code       SEGMENT
           ASSUME cs:Code,ds:Data,ss:Stk
;------------------------------------------------------------------------------------
Image      db    0000000b,1111100b,0010010b,0010001b,0010001b,0010010b,1111100b,0000000b  ;"�"0
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,0110000b,0000000b  ;"�"1
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,0110110b,0000000b  ;"�"2
           db    0000000b,1111111b,0000001b,0000001b,0000001b,0000001b,0000011b,0000000b  ;"�"3
           db    0000000b,1100000b,0111100b,0100010b,0100001b,0111111b,1100000b,0000000b  ;"�"4
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,1001001b,0000000b  ;"�"5
           db    0000000b,1111111b,0001000b,1111111b,0001000b,1111111b,0000000b,0000000b  ;"�"6
           db    0000000b,0100010b,1000001b,1000001b,1001001b,1001001b,0110110b,0000000b  ;"�"7
           db    0000000b,1111111b,0100000b,0010000b,0001000b,0000100b,1111111b,0000000b  ;"�"8
           db    0000000b,1111111b,0100000b,0010001b,0001001b,0000100b,1111111b,0000000b  ;"�"9
           db    0000000b,1111111b,0001000b,0001000b,0010100b,0100010b,1000001b,0000000b  ;"K"10
           db    0000000b,1111100b,0000010b,0000001b,0000001b,0000010b,1111100b,0000000b  ;"�"11
           db    0000000b,1111111b,0000010b,0000100b,0000100b,0000010b,1111111b,0000000b  ;"�"12
           db    0000000b,1111111b,0001000b,0001000b,0001000b,0001000b,1111111b,0000000b  ;"�"13
           db    0000000b,0111110b,1000001b,1000001b,1000001b,1000001b,0111110b,0000000b  ;"�"14
           db    0000000b,1111111b,0000001b,0000001b,0000001b,0000001b,1111111b,0000000b  ;"�"15
           db    0000000b,1111111b,0001001b,0001001b,0001001b,0001001b,0000110b,0000000b  ;"�"16
           db    0000000b,0111110b,1000001b,1000001b,1000001b,1000001b,0100010b,0000000b  ;"�"17
           db    0000000b,0000001b,0000001b,1111111b,0000001b,0000001b,0000000b,0000000b  ;"�"18
           db    0000000b,1001111b,1001000b,1001000b,1001000b,1001000b,1111111b,0000000b  ;"�"19
           db    0000000b,0001111b,0001001b,1111111b,0001001b,0001111b,0000000b,0000000b  ;"�"20
           db    0000000b,1100011b,0010100b,0001000b,0001000b,0010100b,1100011b,0000000b  ;"�"21
           db    0000000b,0111111b,0100000b,0100000b,0100000b,0111111b,1000000b,0000000b  ;"�"22
           db    0000000b,0001111b,0001000b,0001000b,0001000b,0001000b,1111111b,0000000b  ;"�"23
           db    0000000b,1111111b,1000000b,1111111b,1000000b,1111111b,0000000b,0000000b  ;"�"24
           db    0000000b,1111111b,1000000b,1111111b,1000000b,1111111b,1000000b,0000000b  ;"�"25
           db    0000000b,0000001b,1111111b,1001000b,1001000b,1001000b,0110000b,0000000b  ;"�"26
           db    0000000b,1111111b,1001000b,1001000b,1001000b,0110000b,1111111b,0000000b  ;"�"27
           db    0000000b,1111111b,1001000b,1001000b,1001000b,0110000b,0000000b,0000000b  ;"�"28
           db    0000000b,1000001b,1000001b,1000001b,1001001b,1001001b,0111110b,0000000b  ;"�"29
           db    0000000b,1111111b,0001000b,0111110b,1000001b,1000001b,0111110b,0000000b  ;"�"30
           db    0000000b,1000110b,0101001b,0011001b,0001001b,0001001b,1111111b,0000000b  ;"�"31
           db    0000000b,0000000b,0000000b,0000000b,0000000b,0000000b,0000000b,0000000b  ;"_"32
           db    0000000b,0000100b,0000010b,0000001b,0000100b,0000010b,0000001b,0000000b  ;" " "33
           db    0000000b,0000000b,0000000b,0110110b,0110110b,0000000b,0000000b,0000000b  ;":"34
           db    0000000b,0000000b,0000000b,1101111b,1101111b,0000000b,0000000b,0000000b  ;"!"35
           db    0000000b,0000000b,0000000b,0000000b,1000001b,0111110b,0000000b,0000000b  ;")"36
           db    0000000b,0000000b,0000000b,0000000b,0111110b,1000001b,0000000b,0000000b  ;"("37
           db    0000000b,0000000b,0000000b,1100000b,1100000b,0000000b,0000000b,0000000b  ;"."38
           db    0000000b,0001000b,0001000b,0001000b,0001000b,0001000b,0001000b,0000000b  ;"-"39
           db    0000000b,0001000b,0101010b,0011100b,1111111b,0011100b,0101010b,0001000b  ;"*"40
           db    0000000b,0000000b,1000001b,0100010b,0010100b,0001000b,0000000b,0000000b  ;">"41
           db    0000000b,0000000b,0001000b,0010100b,0100010b,1000001b,0000000b,0000000b  ;"<"42
           db    0000000b,0000000b,1000000b,0110110b,0010110b,0000000b,0000000b,0000000b  ;";"43
           db    0000000b,0000010b,0000001b,1101001b,1101001b,0001001b,0000110b,0000000b  ;"?"44
           db    0000000b,0000001b,0000010b,0000100b,0001000b,0010000b,0100000b,1000000b  ;"\"45
           db    1000000b,0100000b,0010000b,0001000b,0000100b,0000010b,0000001b,0000000b  ;"/"46
           db    0000000b,0000000b,1000000b,0110000b,0010000b,0000000b,0000000b,0000000b  ;";"47
           db    0000000b,0111110b,1010001b,1001001b,1000101b,0111110b,0000000b,0000000b  ;"0"48
           db    0000000b,0000000b,1000100b,1000010b,1111111b,1000000b,0000000b,0000000b  ;"1"49
           db    0000000b,1000010b,1100001b,1010001b,1001001b,1000110b,0000000b,0000000b  ;"2"50
           db    0000000b,0100010b,1000001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"3"51
           db    0000000b,0001100b,0001010b,0001001b,1111111b,0001000b,0000000b,0000000b  ;"4"52
           db    0000000b,1000111b,1000101b,1000101b,1000101b,0111001b,0000000b,0000000b  ;"5"53
           db    0000000b,0111100b,1000110b,1000101b,1000101b,0111000b,0000000b,0000000b  ;"6"54
           db    0000000b,1000001b,0100001b,0010001b,0001001b,0000111b,0000000b,0000000b  ;"7"55
           db    0000000b,0110110b,1001001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"8"56
           db    0000000b,0000110b,1001001b,0101001b,0011001b,0001110b,0000000b,0000000b  ;"9"57
Image1     db    111111b     ;0
           db    1100b       ;1
           db    1110110b    ;2
           db    1011110b    ;3
           db    1001101b    ;4
           db    1011011b    ;5
           db    1111011b    ;6
           db    1110b       ;7
           db    1111111b    ;8
           db    1011111b    ;9           

;-------------���樠������ ��ࠬ��஢-----------------------------------------------------------------           
Init       PROC  NEAR
           
           ; ��ᨬ ��������� 
           mov   al,0
           out   51h,al
           
           ; ��� ��६�����
           mov   IsStarted,0           
           mov   InitMode,1
           mov   Tempo,150
           mov   CurrentTempo,150
           mov   ProgramMode,0
           mov   TickIndicator,0
           mov   LoopCounterNPM,0
           mov   LoopCounterPM,0
           mov   LastPart,1
           mov   CurrentPart,1
           mov   CurrentTick,0
           mov   EditTact,0

           ; ������塞 ���ᨢ ⠪⮢ � ��. ०. ���. ���祭�ﬨ
           mov   ax,StartTact
           mov   cx,99
           lea   di, TactPart
           cld
rep        stosw   

           ; ������塞 ���ᨢ ⥬��� � ��. ०. ���. ���祭�ﬨ
           mov   ax,StartTempo
           mov   cx,99
           lea   di, TempoPart
           cld
rep        stosw   

           ; ��⠥� ������⢮ 横��� � ⥬�� � ��. ०.
           mov   ax,StartTempo
           call  CalcLoopInTick  
           mov   LoopInTickPM,ax
           
           ; ��⠥� ������⢮ 横��� � ⥬�� � ����. ०.
           mov   ax,Tempo
           call  CalcLoopInTick  
           mov   LoopInTickNPM,ax
           
           ; ��⮢�� ⥪�⮢�� �।�⠢����� ⥬��
           call  MakeNameTempo              
           
           ;��⠢��� �᫮��� �।�⠢����� ⥬�� � �������� ⥬�
           mov   di,3
           mov   ax,CurrentTempo
           lea   bx, DigitsTempo
           call  MakeDigits
           call  ShowDigitsTempo
           
           ;��⠢��� �᫮��� �।�⠢����� ���
           mov   di,2
           mov   ax,LastPart
           lea   bx, DigitsPart
           call  MakeDigits
           
           ;��⠢��� �᫮��� �।�⠢����� ⠪�
           mov   di,3
           mov   ax,StartTact
           lea   bx,DigitsTact
           call  MakeDigits

           ; �⮡ࠦ��� ⥪�騥 ०��� ����., �ண�., ।���஢����, ����, ⠪�
           call  ShowInitMode           
           call  ShowProgramMode
           call  ShowEditMode
           call  ShowPart           
           call  ShowTact
                      
           ret
Init       ENDP

;------------- ������� �������஬  -------------------------------------------------------------
Blink      PROC  NEAR
           
           push  ax
           push  cx
            
           ; �롨ࠥ� ��������, ����� �㤥� ᢥ�����
           cmp   TickIndicator,01
           je    another_ind
           mov   TickIndicator,01
           jmp   b_ex
another_ind:           
           mov   TickIndicator,02
b_ex:     
           ; �������� ��������
           mov   al,TickIndicator
           out   51h,al
          
           ; ���!
           mov   al,1
           mov   cx,100
           out   53h,al
           call  Delay
           mov   al,0
           out   53h,al            
           
           pop   cx
           pop   ax
           
           ret
Blink      ENDP

;------------- ����প�  -------------------------------------------------------------
Delay      PROC  NEAR
           ; IN  �x - ������⢮ 横���

           ; ����প� �� ������⢮ 横���, 㪠������ � CX
EmptyCycle:
           nop
           nop
           nop
           loop  EmptyCycle
           
           ret
Delay      ENDP

;------------- �����뢠�� ⨪�  -------------------------------------------------------------
DoTicks    PROC  NEAR
           cmp   IsStarted,1
           jne   p1
           push  cx
           push  ax
           push  bx
           
           
           cmp  ProgramMode,1
           je   do_pm
         
           ; ����������������� �����
check_blink:           
           ; �஢��塞, ���� �� ������ � �⮬ �맮��
           cmp   LoopCounterNPM,MaxLoopInProc
           jle   dt_blink
           ; �� ���� ������, ������ ����প� 
           mov   cx,MaxLoopInProc
           sub   LoopCounterNPM,cx
           call  Delay           
           jmp   dt_ex
dt_blink:
           ; ���� ������, ������ ����প� � ������
           mov   cx,LoopCounterNPM
           mov   ax, LoopInTickNPM
           mov   LoopCounterNPM, ax
           sub   LoopCounterNPM, cx
           call  Delay   
           call  Blink                            
           jmp   check_blink
p1:        jmp   p2 
           ; ��������������� �����
do_pm:           
           cmp   LoopCounterPM,MaxLoopInProc        ; �ࠢ������ ���稪_������_�� � ����_������⢮_������_�_��楤��
           jle   dt_blinkpm                         ; �᫨ ���稪_������_����� <= ����_������⢮_������_�_��楤��, � ��� �������
           mov   cx,MaxLoopInProc
           sub   LoopCounterPM,cx                   ; ���稪_������_����� -= ����_������⢮_������_�_��楤��
           call  Delay                              ; ����প� �� ����_������⢮_������_�_��楤��
           jmp   dt_ex                              ; ���� �� ��室
dt_blinkpm:                                         ; �㤥� ������
           mov   cx,LoopCounterPM                   ; cx = ���稪_������_�����
           mov   ax, LoopInTickPM
           mov   LoopCounterPM, ax                  ; ���稪_������_����� = ������_�_⨪�_�����
           sub   LoopCounterPM, cx                  ; ���稪_������_����� -= cx 
           call  Delay                              ; ����প� �� cx
           call  Blink                              ; ������
           inc   CurrentTick                        ; ᤥ��� �� ���� ⨪

           ; �⮡ࠦ��� ⥪�騩 ⠪�
           mov  ax,CurrentTick
           mov  di,3
           lea  bx,DigitsTact
           call MakeDigits
           call ShowTact

           mov   bx,CurrentPart
           sal   bx,1
           mov   ax,TactPart[bx]                    ; ax = ������⢮_⨪��_�_⥪�饩_���
           cmp   CurrentTick,ax                     ; ������⢮_⨪��_�_⥪�饩_��� � ����饥_������⢮_⨪��
           jl    do_pm                              ; �᫨ ����饥_������⢮_⨪�� < ������⢮_⨪��_�_⥪�饩_���, � �஢��塞, �� ��� �� �������
           inc   CurrentPart                        ; ���� ���室�� � ᫥�. ���
           mov   ax,LastPart
           cmp   CurrentPart,ax                     ; �����_����� � ��᫥����_�����
           jle   next_part                          ; �᫨ �����_����� <= ��᫥����_�����, � ��ࠡ�⪠����� ���
           call  StartButton                        ; ���� ��⠭������ 
           mov   CurrentPart,1                      ; ⥪��_���� = 1
           mov   CurrentTick,0                      ; ����騩_��� = 0
           mov   LoopCounterPM,0                    ; ���稪_������_����� = 0
           mov   ax,TempoPart[2]
           call  CalcLoopInTick
           mov   LoopInTickPM,ax                    ; ������_�_⨪�_����� � ��⮬ ⥬�� ��ࢮ� ���
           jmp   dt_ex
next_part:                                          ; ��ࠡ�⪠ ᫥�. ���
           mov   CurrentTick,0                      ; ����騩_��� = 0

           ; �⮡ࠦ��� ⥪���� ����
           mov  ax,CurrentPart
           mov  di,2
           lea  bx,DigitsPart
           call MakeDigits
           call ShowPart
           ; �⮡ࠦ��� ⥪�騩 ⠪�
           mov  ax,CurrentTick
           mov  di,3
           lea  bx,DigitsTact
           call MakeDigits
           call ShowTact
           ; �⮡ࠦ��� ⥪�騩 ⥬�
           mov  bx,CurrentPart
           sal  bx,1
           mov  ax,TempoPart[bx]
           mov  CurrentTempo,ax
           mov  di,3
           lea  bx,DigitsTempo
           call MakeDigits
           call ShowDigitsTempo
           call MakeNameTempo
           
           mov   bx,CurrentPart
           sal   bx,1
           mov   ax,TempoPart[bx]
           call  CalcLoopInTick
           mov   LoopInTickPM,ax                    ; ������_�_⨪�_����� � ��⮬ ⥬�� ⥪�饩 ���
           jmp   do_pm

dt_ex:           
           pop   bx
           pop   ax
           pop   cx
p2:        
           jmp   Time

           ret
DoTicks    ENDP

;------------- ������� ������⢮ 横��� � ⨪�  -----------------------------------------------                      
CalcLoopInTick   PROC  NEAR
           ; IN  ax - ⥬�
           ; OUT ax - ������⢮ 横���
           
           push  dx
           push  cx
           
           mov   cx,ax
           mov   dx,3
           mov   ax,0FFFFh
           div   cx
           
           pop   cx
           pop   dx
           
           ret
           
CalcLoopInTick   ENDP

;------------- �⮡ࠧ��� ०�� ।���஢���� --------------------           
ShowEditMode   PROC  NEAR
           ; ०�� ।���஢���� - 0 - �몫, 1 - ।����㥬 ⥬�, 2 - ।����㥬 ⠪�

           push ax

           cmp  IsStarted,1
           jne  dis
           cmp  ProgramMode, 1
           jne  mode_1
           mov  al,0
           jmp  sem_ex
mode_1:
           mov  al,1
           jmp  sem_ex
mode_2:
           mov  al,2
           jmp  sem_ex

dis:
           cmp  ProgramMode,1
           jne  mode_1
           cmp  EditTact,1
           je   mode_2
           jne  mode_1           
           
sem_ex:
           out  70h,al
           
           pop  ax
           
           ret           
           
ShowEditMode   ENDP

;------------- �⮡ࠧ��� ⥪�騩 ०�� �ணࠬ��஢���� --------------------           
ShowProgramMode   PROC  NEAR
           
           push ax
           push cx
           
           mov  al,1
           mov  cl,ProgramMode
           sal  al,cl
           out  52h,al
       
           pop  cx
           pop  ax

           ret           
           
ShowProgramMode   ENDP

;------------- �⮡ࠧ��� ���� ---------------------------------------------------------------------           
ShowPart       PROC  NEAR

           push ax
      
           cmp  ProgramMode,1
           jne  hide_part
           mov  al,DigitsPart[0]
           out  65h,al
           mov  al,DigitsPart[1]
           out  66h,al
           jmp  sp_exit    
hide_part:   
           mov  al,0
           out  65h,al
           out  66h,al
sp_exit:
           pop  ax
           
           ret
           
ShowPart       ENDP

;------------- �⮡ࠧ��� ⠪� ---------------------------------------------------------------------           
ShowTact       PROC  NEAR

           push ax
      
           cmp  ProgramMode,1
           jne  hide_t
           mov  al,DigitsTact[0]
           out  67h,al
           mov  al,DigitsTact[1]
           out  68h,al
           mov  al,DigitsTact[2]
           out  69h,al
           jmp  st_ex    
hide_t:   
           mov  al,0
           out  67h,al
           out  68h,al
           out  69h,al
st_ex:
           pop  ax
           
           ret
           
ShowTact       ENDP

;------------- �⮡ࠧ��� ⥪�騩 ०�� ���樠����樨 -----------------------------------------------           
ShowInitMode   PROC  NEAR
           
           push ax
           
           mov  al,InitMode
           out  50h,al
           
           pop  ax
           
           ret           
           
ShowInitMode   ENDP

;------------- �롮� ����� ⥬��-----------------------------------------------------------------           
MakeNameTempo   PROC  NEAR

           cmp   CurrentTempo, 60
           jg    middle
           mov   NameTempo[0],12
           mov   NameTempo[2],05
           mov   NameTempo[4],04
           jmp   mnt_ex
middle:           
           cmp   CurrentTempo, 100
           jg    quick
           mov   NameTempo[0],17
           mov   NameTempo[2],16
           mov   NameTempo[4],4
           jmp   mnt_ex
quick:
           cmp   CurrentTempo, 200
           jg    vquick
           mov   NameTempo[0],01
           mov   NameTempo[2],27
           mov   NameTempo[4],17
           jmp   mnt_ex
vquick:
           mov   NameTempo[0],14
           mov   NameTempo[2],23
           mov   NameTempo[4],01
mnt_ex:       
           ret
MakeNameTempo   ENDP

;------------- ������� ��஢�� �।�⠢����� �᫠ -----------------------------------------------------------------           
MakeDigits   PROC  NEAR
           ; ax - �᫮
           ; bx - ���ᨢ
           ; di - ������⢮ ���
           
           push   cx
           push   si
           push   dx
                                 
           ; zero all digits
           push   di
           mov    cx,di
           mov    dl, Image1[0]           
zero_cycle:
           dec    di           
           mov    bx[di],dl
           loop   zero_cycle
           pop    di

           ;make digits
           push   di
           push   ax
           mov    dl,10
           mov    cx,di
           
next_digit:           
           dec    di
           div    dl
           xchg   al,ah
           mov    si,ax
           and    si,000Fh
           mov    dh,Image1[si]
           mov    bx[di],dh                     
           and    ah,ah
           je     md_ex
           dec    cx
           cmp    cx,1
           je     last_digit
           xor    al,al
           xchg   al,ah
           jmp    next_digit
           
last_digit:
           xchg   al,ah
           mov    si,ax
           and    si,000Fh
           mov    dh,Image1[si]
           mov    [bx],dh                     
           
md_ex:
           pop    ax
           pop    di
           pop    dx
           pop    si                                 
           pop    cx
           
           ret
MakeDigits   ENDP

;------------�뢮� �������� ⥬��----------------------------------------------------------------------------
ShowNameTempo  PROC  NEAR                
           mov   up,0h           
           mov   down,20h
           mov   left,10h
           mov   dex,0
           mov   ch,1      
ClockMain2:mov   si,dex
           add   dex,2           
           mov   dx, NameTempo[si]
           mov   si,dx
           mov   cl,3
           shl   si,cl   
           mov   al,ch
           mov   dx,up
           out   dx,al
           inc   up    
           mov   cl,1                  
ClockMain1:mov   al,0
           mov   dx,down
           out   dx,al        
           mov   al,Image[si]
           mov   dx,left
           out   dx,al        
           mov   al,cl
           mov   dx,down
           out   dx,al        
           inc   si
           shl   cl,1
           jnc   ClockMain1 
           inc   down
           inc   left
           cmp   left,18h
           jbe   ClockMain2
ClockMainE:     ret
ShowNameTempo       ENDP    

;------------�뢮� ��� ⥬��----------------------------------------------------------------------------
ShowDigitsTempo     PROC   NEAR
           
           push    ax
           mov     al, DigitsTempo[0]
           out     60h, al
           mov     al, DigitsTempo[1]
           out     61h, al
           mov     al, DigitsTempo[2]
           out     62h, al
           pop     ax
           
           ret           
ShowDigitsTempo     ENDP

;-------------���࠭���� �ॡ����---------------------------------------------------------------
VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
           mov   bh,0        ;���� ����稪� ����७��
VD2:       in    al,dx       ;���� ⥪�饣� ���ﭨ�
           cmp   ah,al       ;����饥 ���ﭨ�=��室����?
           jne   VD1         ;���室, �᫨ ���
           inc   bh          ;���६��� ����稪� ����७��
           cmp   bh,NMax     ;����� �ॡ����?
           jne   VD2         ;���室, �᫨ ���
           mov   al,ah       ;����⠭������� ���⮯�������� ������
           ret
VibrDestr  ENDP           
;--------------���� � ����������----------------------------------------------------------------
KbdInput   PROC  NEAR
           lea   si,KbdImage         ;����㧪� ����,
           mov   cx,LENGTH KbdImage  ;����稪� 横���
           mov   bl,0FEh             ;� ����� ��室��� ��ப�
KI4:       mov   al,bl       ;�롮� ��ப�
           out   KbdPort,al  ;��⨢��� ��ப�
           in    al,KbdPort  ;���� ��ப�
           and   al,11111111b      ;����祭�?
           cmp   al,11111111b
           jz    KI1         ;���室, �᫨ ���
           mov   dx,KbdPort  ;��।�� ��ࠬ���
           call  VibrDestr   ;��襭�� �ॡ����
           mov   [si],al     ;������ ��ப�
KI2:       in    al,KbdPort  ;���� ��ப�
           and   al,11111111b      ;�몫�祭�?
           cmp   al,11111111b
           jnz   KI2         ;���室, �᫨ ���
           call  VibrDestr   ;��襭�� �ॡ����
           jmp   SHORT KI3
KI1:       mov   [si],al     ;������ ��ப�
KI3:       inc   si          ;����䨪��� ����
           rol   bl,1        ;� ����� ��ப�
           loop  KI4         ;�� ��ப�? ���室, �᫨ ���
           ret
KbdInput   ENDP
;-----------����஫� ����� � ����������---------------------------------------------------------
KbdInContr PROC  NEAR
           lea   bx,KbdImage ;����㧪� ����
           mov   cx,8        ;� ����稪� ��ப
           mov   EmpKbd,0    ;���⪠ 䫠���
           mov   KbdErr,0
           mov   dl,0        ;� ������⥫�
KIC2:      mov   al,[bx]     ;�⥭�� ��ப�
           mov   ah,8        ;����㧪� ����稪� ��⮢
KIC1:      shr   al,1        ;�뤥����� ���
           cmc               ;������� ���
           adc   dl,0
           dec   ah          ;�� ���� � ��ப�?
           jnz   KIC1        ;���室, �᫨ ���
           inc   bx          ;����䨪��� ���� ��ப�
           loop  KIC2        ;�� ��ப�? ���室, �᫨ ���
           cmp   dl,0        ;������⥫�=0?
           jz    KIC3        ;���室, �᫨ ��
           cmp   dl,1        ;������⥫�=1?
           jz    KIC4        ;���室, �᫨ ��
           mov   KbdErr,0FFh ;��⠭���� 䫠�� �訡��
           jmp   SHORT KIC4
KIC3:      mov   EmpKbd,0FFh ;��⠭���� 䫠�� ���⮩ ����������
KIC4:      ret
KbdInContr ENDP
;------------�८�ࠧ������ ��।��� ����-----------------------------------------------------
NxtSymBl  PROC  NEAR
           cmp   EmpKbd,0FFh ;����� ���������?
           jz    NSB5        ;���室, �᫨ ��
           cmp   KbdErr,0FFh ;�訡�� ����������?
           jz    NSB5        ;���室, �᫨ ��
           jmp   SHORT NSB6
NSB5:      ret
NSB6:      lea   bx,KbdImage ;����㧪� ����
           mov   dx,0        ;���⪠ ������⥫�� ���� ��ப� � �⮫��
NSB3:      mov   al,[bx]     ;�⥭�� ��ப�
           and   al,11111111b      ;�뤥����� ���� ����������
           cmp   al,11111111b      ;��ப� ��⨢��?
           jnz   NSB2        ;���室, �᫨ ��
           inc   dh          ;���६��� ���� ��ப�
           inc   bx          ;����䨪��� ����
           jmp   SHORT NSB3
NSB2:      shr   al,1        ;�뤥����� ��� ��ப�
           jnc   NSB4        ;��� ��⨢��? ���室, �᫨ ��
           inc   dl          ;���६��� ���� �⮫��
           jmp   SHORT NSB2
NSB4:      mov   cl,3        ;��ନ஢��� ����筮�� ���� ����
           shl   dh,cl
           or    dh,dl
           mov   dl,dh
           xor   dh,dh
           
           cmp   dx,0       ;������ �
           jne   Y1
           
           call  Init
           jmp   NSB1        
           
y1:        cmp   dx,8       ;������ ����
           jne   Y2
           
           call  StartButton
           jmp   NSB1
           
y2:        cmp   dx,1       ;������ +1
           jne   Y3
           
           mov   bl,1
           mov   bh,1
           call  Calculate
           jmp   NSB1
           
y3:        cmp   dx,2       ;������ +10
           jne   Y4
           
           mov   bl,10
           mov   bh,1
           call  Calculate
           jmp   NSB1

y4:        cmp   dx,3       ;������ rejim
           jne   Y5
           
           call  ChangeProgramMode
           jmp   NSB1
           
y5:        cmp   dx,9       ;������ -1
           jne   Y6
           
           mov   bl,1
           mov   bh,0
           call  Calculate
           jmp   NSB1
           
y6:        cmp   dx,10       ;������ -10
           jne   Y7

           mov   bl,10
           mov   bh,0
           call  Calculate
           jmp   NSB1
           
y7:        cmp   dx,11       ;������ temp
           jne   Y8
           
           call  ChangeTempoEdit           
           jmp   NSB1
           
y8:        cmp   dx,16       ;������ takt
           jne   Y9
           
           call  ChangeTactEdit           
           jmp   NSB1
           
y9:        cmp   dx,17       ;������ ����+1
           jne   nsb1
           
           call  NextPart
           jmp   NSB1
           
NSB1:      ret
NxtSymBl  ENDP

;------------ ���� - �⮯ -------------------------------------------------------------
StartButton PROC  NEAR
           
           cmp  IsStarted,1
           jne  enable
           mov  IsStarted,0
           mov  InitMode,1                
           cmp  ProgramMode,1
           je   sb_last
           jmp  sb_ex
           
enable:    
           ; �������
           mov  IsStarted,1     
           mov  InitMode,0
           cmp  ProgramMode,1
           jne  sb_ex
           ; �⮡ࠧ��� ⥪���� ����
           mov  ax,CurrentPart
           mov  di,2
           lea  bx,DigitsPart
           call MakeDigits
           call ShowPart
           ; �⮡ࠧ��� ⥪�騩 ⠪�
           mov  ax,CurrentTick
           mov  di,3
           lea  bx,DigitsTact
           call MakeDigits
           call ShowTact
           ; �⮡ࠧ��� ⥪�騩 ⥬�
           mov  bx,CurrentPart
           sal  bx,1
           mov  ax,TempoPart[bx]
           mov  CurrentTempo,ax           
           mov  di,3
           lea  bx,DigitsTempo
           call MakeDigits
           call ShowDigitsTempo
           call MakeNameTempo
           jmp  sb_ex
sb_last:
           ; �⮡ࠧ��� ���. ����
           mov  ax,LastPart
           mov  di,2
           lea  bx,DigitsPart
           call MakeDigits
           call ShowPart
           ; �⮡ࠧ��� ������⢮ ⠪⮢ � ���. ���
           mov  bx,LastPart
           sal  bx,1
           mov  ax,TactPart[bx]
           mov  di,3
           lea  bx,DigitsTact
           call MakeDigits
           call ShowTact
           ; �⮡ࠧ��� ⥬� � ���. ���
           mov  bx,LastPart
           sal  bx,1
           mov  ax,TempoPart[bx]
           mov  CurrentTempo,ax           
           mov  di,3
           lea  bx,DigitsTempo
           call MakeDigits
           call ShowDigitsTempo
           call MakeNameTempo                      
sb_ex:
           ; �⮡ࠧ��� ०�� ।���஢���� � ����.
           call ShowInitMode
           call ShowEditMode
           
           ret       
StartButton ENDP

;------------ ������ ������ �᫠ -------------------------------------------------------------
Calculate      PROC  NEAR
           ;IN
           ;    bl - �᫮, ���஥ ���� �ਡ����� ��� ������           
           ;    bh - 1 +, 0 -
           
           cmp  IsStarted,1
           jne  d1_notrunning           
           cmp  ProgramMode,1
           jne  ed_tempo
           ret
ed_tempo:  
           ; ������ ��� ⥬��� � ����. ०.         
           mov  ax,Tempo
           mov  dx,300
           cmp  bh,1
           je   op_tempo_1
           mov  dx,10
op_tempo_1:           
           call CheckRange
           mov  Tempo,ax
           mov  CurrentTempo,ax
           push ax
           call CalcLoopInTick  
           mov  LoopInTickNPM,ax
           pop  ax
           jmp  d1_showtempo
                                  
d1_notrunning:           
           cmp  ProgramMode,1
           je   d1_notrunning_1
           jmp  ed_tempo
d1_notrunning_1:
           cmp  EditTact,1
           je   d1_edittact
           ; ������ ��� ⥬��� � ��. ०.         
           mov  cx,bx
           mov  bx,LastPart
           sal  bx,1
           mov  ax,TempoPart[bx]
           push bx
           mov  bx,cx
           mov  dx,300
           cmp  bh,1
           je   op_tempo_2
           mov  dx,10
op_tempo_2:           
           call CheckRange
           pop  bx
           mov  TempoPart[bx],ax
           mov  CurrentTempo,ax

           mov   dx,LastPart
           cmp   CurrentPart,dx
           jne   d1_showtempo
           push  ax
           call  CalcLoopInTick  
           mov   LoopInTickPM,ax
           mov   LoopCounterPM,0
           pop   ax
           jmp   d1_showtempo
           
d1_edittact:
           ; ������ ��� ⠪⮬ � ��. ०.         
           mov  cx,bx
           mov  bx,LastPart
           sal  bx,1
           mov  ax,TactPart[bx]
           push bx
           mov  bx,cx
           mov  dx,999
           cmp  bh,1
           je   op_tact_1
           mov  dx,10
op_tact_1:           
           call CheckRange
           pop  bx
           mov  TactPart[bx],ax
           ; ᤥ���� ⠪� � �⮡ࠧ��� 
           lea  bx,DigitsTact
           mov  di,3
           call MakeDigits
           call ShowTact           
           jmp  d1_ex
                
d1_showtempo:           
           ; ᤥ���� ⥬� � �⮡ࠧ��� 
           lea   bx,DigitsTempo
           mov   di,3
           call  MakeDigits
           call  ShowDigitsTempo
           call  MakeNameTempo                                
d1_ex:
           ret       
Calculate      ENDP

;------------ ������ ��� �᫠�� -----------------------------------------------------------
CheckRange   PROC  NEAR
           ; IN: ax - �᫮
           ;     bl - ��஥ �᫮
           ;     bh - 1 - ��������, 0 - ������
           ;     dx - �࠭��
           ; OUT: ax - ����� �᫮, �᫨ �� ��室�� �� �࠭���, ���� ��஥ �᫮ 
           
           push  cx
           mov   cx,ax
           
           cmp   bh,1
           jne   cr_sub
           xor   bh,bh
           add   ax,bx
           cmp   ax,dx
           jle   cr_ex
           mov   ax,cx
           jmp   cr_ex 
cr_sub:
           xor   bh,bh
           sub   ax,bx
           cmp   ax,dx
           jge   cr_ex
           mov   ax,cx
           jmp   cr_ex 

cr_ex:
           pop   cx
           ret           
           
CheckRange   ENDP

;------------ ���塞 ०�� �ணࠬ��஢���� --------------------------------------------------------
ChangeProgramMode  PROC NEAR
           cmp  IsStarted,1
           je   cpm_ex
           mov  dx,0
           mov  ax,Tempo
           cmp  ProgramMode,1
           je   dis_pm
           mov  dl,1
           mov  bx,LastPart
           sal  bx,1
           mov  ax,TempoPart[bx]
dis_pm:
           mov  ProgramMode,dl
           ; �⮡ࠧ��� ०. �ண�., ०. ।���., ����, ⠪�
           call ShowProgramMode
           call ShowEditMode
           call ShowPart
           call ShowTact
           ; ᤥ���� ⥬� � �⮡ࠧ��� 
           mov  CurrentTempo,ax
           lea  bx,DigitsTempo
           mov  di,3
           call MakeDigits
           call ShowDigitsTempo
           call MakeNameTempo
cpm_ex:
           ret       
ChangeProgramMode  ENDP

;------------ ���塞 ०�� ।���஢���� ⠪� --------------------------------------------------------
ChangeTactEdit  PROC NEAR
           cmp  IsStarted,1
           je   cte_ex
           cmp  ProgramMode,0
           je   cte_ex
           cmp  EditTact,1
           je   cte_ex
           mov  EditTact,1
           call ShowEditMode
cte_ex:
           ret       
ChangeTactEdit  ENDP

;------------ ���塞 ०�� ।���஢���� ⥬�� --------------------------------------------------------
ChangeTempoEdit  PROC NEAR
           cmp  IsStarted,1
           je   ctoe_ex
           cmp  ProgramMode,0
           je   ctoe_ex
           cmp  EditTact,0
           je   cte_ex
           mov  EditTact,0
           call ShowEditMode
ctoe_ex:
           ret       
ChangeTempoEdit  ENDP

;------------ ���室 � ᫥�. ��� --------------------------------------------------------
NextPart  PROC NEAR
           cmp  IsStarted,1
           je   np_ex
           cmp  ProgramMode,0
           je   np_ex
           cmp  LastPart,99
           je   np_ex
           inc  LastPart
           ; ᤥ���� ���� � �⮡ࠧ��� 
           mov  ax,LastPart
           lea  bx,DigitsPart
           mov  di,2
           call MakeDigits
           call ShowPart
           ; ᤥ���� ⠪� � �⮡ࠧ��� 
           mov  ax,StartTact
           lea  bx,DigitsTact
           mov  di,3
           call MakeDigits
           call ShowTact
           ; ᤥ���� ⥬� � �⮡ࠧ��� 
           mov  ax,StartTempo
           mov  CurrentTempo,ax
           lea  bx,DigitsTempo
           mov  di,3
           call MakeDigits
           call ShowDigitsTempo
           call MakeNameTempo
np_ex:
           ret       
NextPart  ENDP

;--------------------------------------------------------------------------------------
Start:     
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;--------------- ������ 横� -------------------------------------------------------------
           call  Init
Time:
           call  ShowNameTempo
           call  KbdInput
           call  KbdInContr
           call  NxtSymBl
           call  DoTicks
;--------------------------------------------------------------------------------------
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end