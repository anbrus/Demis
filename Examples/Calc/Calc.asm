; �������� �����

Name ArithmeticCaculator

;���ᠭ�� ����⠭�
Point          EQU  10           ; ������  '.'
SignChg        EQU  11           ; ������ '+/-'

; ����⢨�         ���
Addition       EQU  12           ; ������  '+'
Subtraction    EQU  13           ; ������  '-'
Multiplication EQU  14           ; ������  '*'
Division       EQU  15           ; ������  '/'
Calculation    EQU  16           ; ������  '='

Clr            EQU  17           ; ������  'C'
ClrE           EQU  18           ; ������  'CE'
Bksp           EQU  19           ; ������ 'BKSP'
MemClr         EQU  20           ; ������  'MC'
MemRd          EQU  21           ; ������  'MR'
MemSet         EQU  22           ; ������ 'X->M'
MemAdd         EQU  23           ; ������  'M+'

; ���ᠭ�� ������
Data Segment use16 at 0BA00H
    Rez db 5 dup (?)             ; ����⢥��� �᫠:
    Arg db 5 dup (?)             ; 1-� ���� - ���冷�
    Mem db 5 dup (?)             ; � ������; ����� 2-5
                                 ; - ������ � ������

    Operation db ?               ; ������

    Error db ?                   ; 䫠� �訡��

    StrDisplay db 13 dup (?)            ; ��ப� �����/�뢮��
                                 ; ������ �� ��ᯫ��:
                                 ; 8 ࠧ�冷� �⤥������
                                 ; �窮�, ����, �᫮
                                 ; �������� ࠧ�冷�,
                                 ; 䫠� ������ �窨,
                                 ; 䫠� ⮣�, �� ��ப�
                                 ; ���� ������� ������

    ActiveButtonCode db ?        ; ��� ����⮩ ������
    OutputMap db 13 dup (?)      ; ���ᨢ ��ࠧ��

    MulRez dw 4 dup (?)          ; �ᯮ����⥫쭠�
                                 ; ��६�����
Data EndS

; ���ᠭ�� �⥪�
Stack Segment use16 at 0BA80H
     dw 100 dup (?)              ; 100 ᫮� (� ����ᮬ)
     StkTop label Word           ; ���設� �⥪�
Stack EndS

; ���ᠭ�� �믮��塞�� ����⢨�
Code Segment use16
Assume cs:Code,ds:Data,es:Data

; ���樠������ ����� ��ࠧ��
InitOutputMap Proc near
         mov OutputMap[0],3Fh    ; ��ࠧ� ���
         mov OutputMap[1],0Ch    ; �� 0 �� 9
         mov OutputMap[2],76h
         mov OutputMap[3],05Eh
         mov OutputMap[4],4Dh
         mov OutputMap[5],5Bh
         mov OutputMap[6],7Bh
         mov OutputMap[7],0Eh
         mov OutputMap[8],7Fh
         mov OutputMap[9],5Fh

         mov OutputMap[10],80h   ; ��ࠧ �窨
         mov OutputMap[11],40h   ; ��ࠧ ����� "-"
         mov OutputMap[12],0h    ; ��ࠧ ���⮣� ����
         ret
InitOutputMap EndP

; ���⪠ ��ப� �����/�뢮�� ������ �� ��ᯫ��
StrClear Proc near
         push ax
         push di

         lea di,StrDisplay

         xor al,al               ; ����訩 ࠧ�� -
         stosb                   ; �㫥���

         mov al,12               ; ��⠫��
         mov cx,9                ; �⮡ࠦ����
   SCcyc:stosb                   ; ࠧ���
         loop SCcyc              ; �����

         xor al,al
         stosb                   ; ������� 0 ࠧ�冷�
         stosb                   ; �窨 ���

         mov al,0FFh             ; ��ப� ���� �������
         stosb                   ; ������

         pop di
         pop ax
         ret
StrClear EndP

; ���㫥��� ����⢥����� �᫠;
; ��ࠬ����: � di - ᬥ饭�� �᫠
FloatClear Proc near
         push bx

         xor bx,bx
   FCcyc:mov byte ptr [di+bx],0  ; ���㫨��
         inc bx                  ; ��
         cmp bx,5                ; 5 ����
         jne FCcyc

         pop bx
         ret
FloatClear EndP

; ����� ����� ������� ����⢥����� �᫠,
; ��ࠬ����: � ॣ���� di - ᬥ饭�� �᫠
FloatNeg Proc near
         push ax
         push dx

         mov ax,0FFFFh
         mov dx,0FFFFh

         sub ax,[di+1]
         sub dx,[di+3]

         add ax,1
         adc dx,0

         mov [di+1],ax
         mov [di+3],dx

         pop dx
         pop ax
         ret
FloatNeg EndP

include io.asm
include convs.asm
include math.asm

   Begin:mov ax,Data             ; ���樠������
         mov ds,ax               ; ᥣ������
         mov es,ax               ; ॣ���஢ �
         mov ax,Stack
         mov ss,ax
         mov sp,offset StkTop    ; 㪠��⥫� �⥪�

         mov cx,64
         mov di,0
         mov al,0
ClearData:
         stosb
         loop ClearData

         call InitOutputMap      ; ���樠������ ���-
                                 ; ᨢ� ��ࠧ��
         mov ActiveButtonCode,17
         call Clear              ; ���⪠ ��६�����

         mov ActiveButtonCode,20
         call MemoryClear        ; ���⪠ �����

    WCyc:call ErrMsgOutput       ; �뢮� ᮮ�饭�� ��
                                 ; �訡���
         call StrOutput          ; �⮡ࠦ���� ��ப�
                                 ; �����/�뢮��

         call KbdRead            ; ���� ����������
         call DigInput           ; ���� ����
         call PointInput         ; ���� �窨
         call SignChange         ; ᬥ�� �����

         call AddRezArg          ; ����
         call SubRezArg          ; ����樨
         call MulRezArg
         call DivRezArg

         call Calculate          ; ���᫥���

         call Clear              ; ������쭠� ���⪠
         call CE                 ; ���⪠ ��ப� �����
         call Undo               ; �⪠�

         call MemoryClear        ; ���⪠ �����
         call MemoryRead         ; �⮡ࠦ���� ᮤ�ন-
                                 ; ���� �����
         call MemorySet          ; ����������� � ������
         call MemoryAdd          ; ᫮����� � �������

         jmp WCyc                ; ���몠��� �ணࠬ-
                                 ; ����� �����

         assume cs:nothing

         org 0FF0h               ; ������� ���⮢��
   Start:jmp Far Ptr Begin       ; �窨, �ࠢ�����
                                 ; ��।����� ��
                                 ; ������� jump
Code EndS

End Start