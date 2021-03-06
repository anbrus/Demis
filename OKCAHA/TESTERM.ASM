;�᭮���� 䠩� �ணࠬ��
LOCALS
PAGE 80,132

KbdPort=0FFh-1                         ;���� ���⮢
ModePort=0FFh-2                        ;���⥪����
LampPort=0FFh-4                        ;�����/�뢮��
OptionPort=ModePort
SegPort=0FFh-8                         ;ᥣ���⮢
IndPort=0FFh-16                        ;�������஢
NMAX=50                                ;����⠭� ���������� �ॡ����
CRCPassCount=4                         ;�᫮ ��室�� ��� CRC
DataBusErrorBit=2                      ;���, �⢥��騩 �� ᢥ⮤��� �訡�� �� ��
CRCErrorBit=1                          ;���, �⢥��騩 �� ᢥ⮤��� �訡�� CRC
AddrBusErrorBit=4                      ;���, �⢥��騩 �� ᢥ⮤��� �訡�� �� ��
NoErr=0                                ;��� �訡��
SizeErr=1                              ;�訡�� ࠧ���
MemDBusErr=2                           ;�訡�� �� ��
TestNumber1=55h                        ;��⮢�� �᫮: 01010101
TestNumber2=0AAh                       ;��⮢�� �᫮: 10101010
EnterKey=16                            ;��� ������ ��室� �� ���ﭨ� �訡��

;==============================
data segment at 08000H
        Map               db 17 dup (?) ;���� �८�ࠧ������
        InTypeA           db ?
        InTypeM           db ?
        Mode              db ?  ;�����
        Setup             db ?  ;��� �����
        AddrInc           db ?
        AddrDec           db ?
        Dir               db ?
        RealAddress       DD ?
        CurSize           dw ?
        DispArray         db 7 dup(?) ;��ப� ��� �८�ࠧ������
        ErrFlag           db ?
        KeepFlag          dw ?
        KeepEs            dw ?
        DispAdr           dd ?
        TstBuf            db 20 dup(?)  ;���ᨢ �࠭���� �祥� ���ﭨ�
        KbdErr            db ?
        EmpKbd            db ?
        Memory            db ?
        MesBuf            db ?
        NextDig           db ?
        KbdImage          db 4 dup (?)
        InType            db ?
data ends

;=========================
stk segment at 08100H
  dw 100H dup (?)
  StkTop label word
stk ends

;==============================
code segment
assume cs:code,ds:data,ss:stk
include progsl.asm

;================================
Prepare proc                    ;�����⮢�� ������
                                ;���樠������ ����� �८�ࠧ������
        mov Map[0], 03H
        mov Map[1], 9Fh
        mov Map[2], 25h
        mov Map[3], 0Dh
        mov Map[4], 99H
        mov Map[5], 49H
        mov Map[6], 41H
        mov Map[7], 1FH
        mov Map[8], 01H
        mov Map[9], 09H
        mov Map[10], 11H
        mov Map[11], 0C1H
        mov Map[12], 63H
        mov Map[13], 85H
        mov Map[14], 61H
        mov Map[15], 71H


        mov Mode,0              ;०�� ��⮬���᪨�
        mov IntypeA,0           ;⨯ ����� ��砫�� ����
        mov IntypeM,0           ;⨯ ����� ����
        mov memory,0            ;�������� ���
        mov word ptr RealAddress,00000h
        mov word ptr RealAddress[2],00000h
        mov CurSize,10
        mov al,AddrInc
        mov Dir,al
        mov ErrFlag,0
        mov KbdErr,0

        ret                     ;��室
Prepare endp

;=============================
ModeInput proc                  ;���� ०����
        cmp ErrFlag,0           ;�஢�ઠ �訡��
        je @@NoE
        jmp @@exit
@@Noe:
        in al,ModePort
        mov dx,ModePort
        call VibrDestr
        test al,01h             ;�஢�ઠ �� ��⠭���� ०����
        jne @@exit
        mov Mode,0FFh
@@exit:
        ret                     ;��室
ModeInput endp

;============================
SetupInput proc                 ;���� ⨯� �����
        cmp ErrFlag,0           ;�஢�ઠ �訡��
        je @@NoE
        jmp @@exit
@@Noe:
        in al,KbdPort
        mov dx,KbdPort
        call VibrDestr
        test al,40h              ;⨯ ����� - ��砫�� ����
        jne @@SI1
        mov IntypeA,0
        jmp @@exit
@@SI1:
        test al,20h              ;⨯ ����� - ࠧ���
        jne @@SI2
        mov IntypeA,0FFh
        jmp @@exit
@@SI2:
        test al,80h              ;⨯ �����  - ����
        jne @@SI3
        mov IntypeM,0

@@SI3:
        test al,10h              ;⨯ ����� - �����
        mov IntypeM,0FFh
@@exit:
        ret                     ;��室
SetupInput endp

;=============================
DirInput proc                   ;���� ���ࠫ����
        cmp ErrFlag,0           ;�஢�ઠ �訡��
        je @@NoE
        jmp @@exit
@@Noe:

        in al,ModePort
        mov dx,ModePort
        call VibrDestr
        test al,02h
        jne @@DI1
        mov AddrInc,0FFh
        call ManualMake
        jmp @@exit
@@DI1:
        test al,04h
        jne @@exit
        mov AddrDec,0FFh
        call ManualMake
@@exit:
        ret                     ;��室
DirInput endp
;=============================
VibrDestr Proc
VD1:    mov ah,al       ;��࠭���� ��室���� ���ﭨ�
        mov bh,0        ;��� ���稪� ����७��
VD2:    in al,dx        ;���� ⥪�饣� ���ﭨ�
        cmp ah,al       ;⥪�饥 ���ﭨ� = ��室����
        jne VD1         ;���室, �᫨ ���
        inc bh          ;���६��� ���稪� ����७��
        cmp bh,NMAX     ;����� �ॡ����
        jne VD2         ;���室, �᫨ ���
        mov al,ah       ;����⠭������� ���⮯�������� ������
        ret
VibrDestr endp
;=============================
KbdInput Proc Near               ;���� � ����������
         lea si,KbdImage         ;����㧪� ����,
         mov cx,length KbdImage  ;���稪� 横��� �
         mov bl,0FEh             ;����� ��室��� ��ப�
KI4:     mov al,bl               ;�롮� ��ப�
         and al,3Fh              ;��ꥤ������ ����� �
         or  al,MesBuf           ;ᮮ�饭��� "��� �����"
         out KbdPort,al          ;��⨢��� ��ப�
         in  al,KbdPort          ;���� ��ப�
         and al,0Fh              ;����祭� ?
         cmp al,0Fh
         jz  KI1                 ;���室, �᫨ ���
         mov dx,KbdPort          ;��।�� ��ࠬ��஢
         call VibrDestr          ;��襭�� �ॡ����
         mov [si],al             ;������ ��ப�
KI2:     in  al,KbdPort          ;���� ��ப�
         and al,0Fh              ;�몫�祭� ?
         cmp al,0Fh
         jnz KI2                 ;���室, �᫨ ���
         call VibrDestr          ;��襭�� �ॡ����
         jmp Short KI3
KI1:     mov [si],al             ;������ ��ப�
KI3:     inc si                  ;����䨪��� ����
         rol bl,1                ;� ����� ��ப�
         loop KI4                ;�� ��ப�? ���室,�᫨ ���
         ret
KbdInput endp
;============================
KbdInContr proc near             ;����஫� ����� � ����������

         lea bx,KbdImage         ;����㧪� ���ᮢ �
         mov cx,4                ;���稪� ��ப
         mov EmpKbd,0
         mov KbdErr,0
         mov dl,0
KIC2:    mov al,[bx]             ;�⥭�� ��ப�
         mov ah,4
KIC1:    shr al,1                ;�뤥����� ���
         cmc
         adc dl,0
         dec ah                  ;�� ���� � ��ப�?
         jnz KIC1
         inc bx
         loop KIC2
         cmp dl,0
         jz  KIC4
         mov KbdErr,0FFh
         jmp short KIC4
KIC3:    mov EmpKbd, 0FFh
KIC4:    ret
KbdInContr endp
;=========================
NxtDigTrf proc near              ;�८�ࠧ������ ��।��� ����
         cmp EmpKbd,0ffH
         jz  NDT1
         cmp KbdErr,0FFh
         jz  NDT1
         lea bx,KbdImage         ;����㧪� ����
         mov dx,0                ;���⪠ ������⥫�� ���� ��ப� � �⮫��
NDT3:    mov al,[bx]             ;�⥭�� ��ப�
         and al,0Fh
         cmp al,0Fh
         jnz NDT2
         inc dh
         inc bh
         jmp short NDT3
NDT2:    shr al,1                ;�뤥����� ��� ��ப�
         jnc NDT4
         inc dl
         jmp short NDT2
NDT4:    mov cl,2                ;�ନ஢���� ����筮��
         shl dh,cl               ;���� ��ப�
         or  dh,dl
         mov NextDig,dh
NDT1:    ret
NxtDigTrf endp
;=============================
MakeData proc                   ;�����⮢�� ������
        mov al,KbdErr
        or ErrFlag,0    ;�஢�ઠ �訡��
        jnz @@exit
        cmp EmpKbd,0FFh
        jne @@AutoSetup
        cmp AddrInc,0FFh
        jne @@MD1
        add Word Ptr RealAddress,1
        adc Word Ptr RealAddress+2,0
        jmp @@Noe
@@MD1:  cmp AddrDec,0FFh
        jne @@exit
        sub Word Ptr RealAddress,1
        sbb Word Ptr RealAddress+2,0
@@Noe:
        cmp Mode,0
        je @@AutoSetup
        jmp @@MD2
@@AutoSetup:
        call MakeAutoVars
        jmp @@exit
@@MD2:
        call MakeManualVars
@@exit:
        ret
MakeData endp

;=============================
MakeDispArr proc                ;��ନ஢���� ���ᨢ� �⮡ࠦ����
        mov cx,Length DispArray ;� CX ������ ���ᨢ� �⮡ࠦ����
        lea si,DispArray        ;� SI ����� ���ᨢ� �⮡ࠦ����
@@l1:
        mov byte ptr [si],0
        inc si
        loop @@l1               ;���㫥��� ���ᨢ� �⮡ࠦ���

        mov cx,Length DispArray ;� CX ������ ���ᨢ� �⮡ࠦ����
        lea si,DispArray        ;� SI ����� ���ᨢ� �⮡ࠦ����
        lea bx,Map              ;� BX ���� ����� �८�ࠧ������

        cmp Mode,0      ;�஢�ઠ ��⠭��������� ०���
        je MDA1         ;�᫨ ०�� ��⮬���᪨�
        jmp MDA2        ;�᫨ ��筮�
MDA1:
        cmp Byte Ptr Intype,0    ;⨯ ����� - ���� ?
        jne MDA3        ;������ ࠧ���
MAdr:                           ;������ ����
        mov dx,word ptr RealAddress;� DX ������� ���� ����
        mov cx,4                ;����㧪� ���稪� ��� �८�ࠧ������
MDAl2:                          ;横� �८�ࠧ������
        mov ax,1111b
        and ax,dx
        xlat
        mov [si],al
        inc si
        shr dx,4
        loop MDAl2
        mov ax,word ptr RealAddress[2];� AX ������ ���� ����
        shr ax,12
        xlat
        mov [si],al                     ;��⠢�塞 ���ᨢ �⮡ࠦ����
                                        ;��� ����
        jmp exit
MDA3:
        mov dx,CurSize                  ;��� ࠧ���
        mov cx,4
MDAl3:
        mov ax,1111b
        and ax,dx
        xlat
        mov [si],al
        inc si
        shr dx,4
        loop MDAl3

        jmp exit
;��筮� ०��
MDA2:
        push ds
        lds si,RealAddress
        mov dl,[si]
        pop ds

        lea si,DispArray
        lea bx,Map
        Add si,5
        mov al,0fh
        and al,dl
        xlat
        mov [si],al
        shr dl,4
        mov al,dl
        xlat
        inc si
        mov [si],al
        lea si,DispArray
        jmp MAdr

@@exit:
        ret
MakeDispArr endp

;=============================
OutputDispArr proc              ;�뢮� ���ᨢ� �⮡ࠦ���� �� ��ᯫ��
        mov al,KbdErr
        or  al,al
        jnz @@exit
        mov cx,Length DispArray ; � CX ������ ��ᨢ� �⮡ࠦ����
        lea si,DispArray        ; � SI ���� ���ᨢ� �⮡ࠦ����
        mov al,11111110b
ODA1:
                        ;横� �뢮�� � ����� �뢮��
        mov al,[si]
        out IndPort,al
        xchg ah,al
        out SegPort,al
        xchg ah,al
        rcl si,1
        inc si
        loop ODA1
@@exit:
        ret                     ;��室
OutputDispArr endp

;=============================
LampOutput proc               ;��������� �����祪
        mov al,20h
        cmp Mode,0
        jne LO1
        or  al,0Fh
        out LampPort,al
        jmp SizeAddr
LO1:
        mov al,10h
        or al,0Fh
        out LampPort,al
        jmp DanAddr
SizeAddr:
        mov al,40h
        cmp InTypeA,0
        je  KbdOut
        mov al,20h
        jmp KbdOut
DanAddr:
        mov al,80h
        cmp InTypeM,0
        je  KbdOut
        mov al,10h
KbdOut:
        mov MesBuf,al
        or al,0FFh
        out KbdPort,al
        ret
LampOutPut endp

;===================================
TestProgress proc               ;���஢����
        cmp Mode,0
        je  @@Noe
        jmp @@exit
@@NoE:
        in al,ModePort
        mov dx,ModePort
        call VibrDestr
        test al,20h
        jnz @@TP1
        mov memory,0FFh
        call TestProcessROM
        jne @@exit
@@TP1:  call TestProcessRAM
@@exit:
        ret                     ;��室
TestProgress endp

;===================================
begin:
        mov ax,data
        mov ds,ax

        mov ax,stk
        mov ss,ax
        mov sp,offset StkTop
        call Prepare
MainProgramLoop:
        ;==================
        call ModeInput          ;���� ०����
        call SetupInput         ;���� ⨯� �����
        call DirInput           ;���� ���ࠫ����
        ;==================
        call KbdInput           ;���� � ����������
        call KbdInContr         ;����஫� ����� � ����������
        call NxtDigTrf          ;�८�ࠧ������ ��।��� ����
        call MakeData           ;�����⮢�� ������
        call MakeDispArr        ;�ନ஢���� ���ᨢ� �⮡ࠦ����
        call OutputDispArr      ;�뢮� ���ᨢ� �⮡ࠦ���� �� ��ᯫ��
        call TestProgress       ;��楤�� ���஢����
        call LampOutput         ;��������� �����祪
        ;==================
        jmp MainProgramLoop
       org 07F0H
start: jmp begin
code ends
end start


