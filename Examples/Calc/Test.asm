; �������� ������

Name ArithmeticCaculator

;�������� ��������
Point          EQU  10           ; ������  '.'
SignChg        EQU  11           ; ������ '+/-'

; ��������         ���
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

; �������� ������
Data Segment at 0BA00H
    Rez db 5 dup (?)             ; ������������ �����:
    Arg db 5 dup (?)             ; 1-�� ���� - �������
    Mem db 5 dup (?)             ; �� ������; ����� 2-5
                                 ; - �������� �� ������

    Operation db ?               ; ��������

    Error db ?                   ; ���� ������

    Str db 13 dup (?)            ; ������ �����/������
                                 ; ������ �� �������:
                                 ; 8 �������� ����������
                                 ; ������, ����, �����
                                 ; �������� ��������,
                                 ; ���� ������� �����,
                                 ; ���� ����, ��� ������
                                 ; ���� ������� ������

    ActiveButtonCode db ?        ; ��� ������� �������
    OutputMap db 13 dup (?)      ; ������ �������

    MulRez dw 4 dup (?)          ; ���������������
                                 ; ����������
Data EndS

; �������� �����
Stack Segment at 0BA80H
     dw 100 dup (?)              ; 100 ���� (� �������)
     StkTop label Word           ; ������� �����
Stack EndS

; �������� ����������� ��������
Code Segment
Assume cs:Code,ds:Data,es:Data

; ������������� ����� �������
InitOutputMap Proc near
         mov OutputMap[0],3Fh    ; ������ ����
         mov OutputMap[1],0Ch    ; �� 0 �� 9
         mov OutputMap[2],76h
         mov OutputMap[3],05Eh
         mov OutputMap[4],4Dh
         mov OutputMap[5],5Bh
         mov OutputMap[6],7Bh
         mov OutputMap[7],0Eh
         mov OutputMap[8],7Fh
         mov OutputMap[9],5Fh

         mov OutputMap[10],80h   ; ����� �����
         mov OutputMap[11],40h   ; ����� ����� "-"
         mov OutputMap[12],0h    ; ����� ������� �����
         ret
InitOutputMap EndP

; ������� ������ �����/������ ������ �� �������
StrClear Proc near
         push ax di

         lea di,Str

         xor al,al               ; ������� ������ -
         stosb                   ; �������

         mov al,12               ; ���������
         mov cx,9                ; ������������
   SCcyc:stosb                   ; �������
         loop SCcyc              ; �����

         xor al,al
         stosb                   ; ������� 0 ��������
         stosb                   ; ����� ���

         mov al,0FFh             ; ������ ���� �������
         stosb                   ; ������

         pop di ax
         ret
StrClear EndP

; ��������� ������������� �����;
; ���������: � di - �������� �����
FloatClear Proc near
         push bx

         xor bx,bx
   FCcyc:mov byte ptr [di+bx],0  ; ��������
         inc bx                  ; ���
         cmp bx,5                ; 5 ����
         jne FCcyc

         pop bx
         ret
FloatClear EndP

; ����� ����� �������� ������������� �����,
; ���������: � �������� di - �������� �����
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

   Begin:
         mov ax,Data             ; �������������
         mov ds,ax               ; ����������
         mov es,ax               ; ��������� �
         mov ax,Stack
         mov ss,ax
         mov sp,offset StkTop    ; ��������� �����

         mov cx,64
         mov di,0
         mov al,0
ClearData:
         stosb
         loop ClearData

         call InitOutputMap      ; ������������� ���-
                                 ; ���� �������
         mov ActiveButtonCode,17
         call Clear              ; ������� ����������

         mov ActiveButtonCode,20
         call MemoryClear        ; ������� ������

    WCyc:call ErrMsgOutput       ; ����� ��������� ��
                                 ; �������
         call StrOutput          ; ����������� ������
                                 ; �����/������

         call KbdRead            ; ����� ����������
         call DigInput           ; ���� �����
         call PointInput         ; ���� �����
         call SignChange         ; ����� �����

         call AddRezArg          ; ����
         call SubRezArg          ; ��������
         call MulRezArg
         call DivRezArg

         call Calculate          ; ����������

         call Clear              ; ���������� �������
         call CE                 ; ������� ������ �����
         call Undo               ; �����

         call MemoryClear        ; ������� ������
         call MemoryRead         ; ����������� �������-
                                 ; ���� ������
         call MemorySet          ; ����������� � ������
         call MemoryAdd          ; �������� � �������

         jmp WCyc                ; ��������� �������-
                                 ; ����� ������

         assume cs:nothing

         org 0FF0h               ; ������� ���������
   Start:jmp Far Ptr Begin       ; �����, ����������
                                 ; ���������� ��
                                 ; ������� jump
Code EndS

  End Start