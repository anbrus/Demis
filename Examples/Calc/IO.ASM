; �����, ᮤ�ঠ騩 �� ����室���
; ��楤��� ��� ����䥩᭮� ���

; ����� ��ப� �����/�뢮�� �� 1 ࠧ�� ��ࠢ�
RotateStringRight Proc near
         push ax
         push bx

         xor bx,bx
  RSRcyc:mov ah,StrDisplay[bx+1]
         mov StrDisplay[bx],ah
         inc bx
         cmp bx,8
         jne RSRcyc
         mov StrDisplay[8],12

         pop bx
         pop ax
         ret
RotateStringRight EndP

; ����� ��ப� �����/�뢮�� �� 1 ࠧ�� �����
RotateStringLeft Proc near
         push ax
         push bx

         mov bx,8
  RSLcyc:mov ah,StrDisplay[bx-1]
         mov StrDisplay[bx],ah
         dec bx
         jnz RSLcyc
         mov StrDisplay[0],12

         pop bx
         pop ax
         ret
RotateStringLeft EndP

; ����������� �����������

; ���� ����������
KbdRead Proc near
    KRm1:mov dx,3                ; ���� ���⮢ �����
   KRCyc:dec dl                  ; 2-0 � ��室 �� 横��
         in al,dx                ; ⮫쪮 ��᫥ ������
         cmp al,0                ; �����-���� ������ ��
         jne KRexit              ; ᮥ�������� � ���⠬�
         cmp dl,0
         jnz KRCyc
         jmp KRm1
  KRexit:push ax

    KRm2:in al,dx                ; ���� �� �⦠��
         or al,al                ; ������
         jnz KRm2

         pop ax                  ; ⥯��� � dl-�����
                                 ; ��⨢���� ����, �
                                 ; � al-��� ᮤ�ন���

                                 ; ��।������ �����
                                 ; ��⨢���� �室�
         xor cl,cl               ; ��⨢���� ����
    KRm3:inc cl
         shr al,1                ; ������� �� �� ���,
         jnz KRm3                ; ���� 1 �� 㩤��
         dec cl

         mov al,dl               ; ���� ����
         shl al,1                ; ������
         shl al,1
         shl al,1
         add al,cl

         mov ActiveButtonCode,al

         ret
KbdRead EndP

; ���� ��।��� ���� �᫠
DigInput Proc near
         cmp Error,0
         jne DIend

         mov al,ActiveButtonCode

         cmp al,0                ; �஢�ઠ, �
         jb DIend                ; ����⢨⥫쭮 ��
         cmp al,9                ; ����� ��஢��
         ja DIend                ; ������

         cmp StrDisplay[12],0FFh        ; � ����� ���� ��ப�
         jne DIm1                ; ���� ������� ������ ?
         call StrClear
         mov StrDisplay[12],0

    DIm1:cmp StrDisplay[10],8           ; 㦥 ����� 8 ���
         je  DIend               ; {����� ���㤠}

         cmp StrDisplay[10],0           ; ��ப� �����?
         jne DIm2
         cmp al,0                ; � ����� ������ "0" ?
         je DIend                ; ��, � ��祣� �������
                                 ; �� ����
         jne DIm3                ; ���, � ᤢ����� ࠧ-
                                 ; ��� ��ப� �� ����

    DIm2:call RotateStringLeft   ; ᤢ�� ࠭�� ���������
                                 ; ࠧ�冷�

    DIm3:mov StrDisplay[0],al           ; ������ ᨬ����-����
         inc StrDisplay[10]             ; � ����訩 ࠧ��

   DIend:ret
DigInput EndP

; ���� �窨
PointInput Proc near
         cmp Error,0
         jne PIend

         mov al,ActiveButtonCode

         cmp al,Point            ; ����� ������ "." ?
         jne PIend               ; ���, ⮣�� ��室��

         cmp StrDisplay[12],0FFh        ; � ����� ���� ��ப�
         jne PIm1                ; ���� ������� ������ ?
         call StrClear
         mov StrDisplay[12],0

    PIm1:cmp StrDisplay[11],0FFh        ; �᫨ ��� 㦥 �����-
         je PIend                ; ��, � ��� ���� �窨
                                 ; ����������

         cmp StrDisplay[10],0           ; ��ப� �����?
         jne PIm2                ; ���, � ���室
         inc StrDisplay[10]             ; ��, ⮣�� ���� ��।
                                 ; �窮� - �㫥���

    PIm2:call RotateStringLeft   ; ᤢ�� ࠭�� ���������
                                 ; ࠧ�冷�

         mov StrDisplay[0],al           ; ������ �窨 �
                                 ; ����訩 ࠧ��
         mov StrDisplay[11],0FFh        ; ��⠭���� 䫠�� ��-
                                 ; ���� �窨 � ��ப�
   PIend:ret
PointInput EndP

; ����� �����
SignChange Proc near
         cmp Error,0
         jne SCend

         cmp ActiveButtonCode,SignChg
         jne SCend

         cmp StrDisplay[9],12           ; ᬥ�� �����
         jne SCSP
         mov StrDisplay[9],11           ; ���� "-"
         jmp SCend
    SCSP:mov StrDisplay[9],12           ; ���� "+"

   SCend:ret
SignChange EndP

; �������� ⮣� �� �� ��ᯫ�� � ⥬,
; �� �㤥� ������� �������
AddRezArg Proc near
         cmp Error,0
         jne ARAend

         cmp ActiveButtonCode,Addition
         jne ARAend

         mov Operation,1         ; ��������� ������ '+'

         lea di,Rez              ; ��࠭��� ��ப�
                                 ; �����/�뢮�� �
                                 ; ��६����� Rez -
                                 ; 1-�� ᫠������

         call ConvertStringToFloat
         mov StrDisplay[12],0FFh

  ARAend:ret
AddRezArg EndP

; ���⠭�� �� ⮣� �� �� ��ᯫ�� ⮣�,
; �� �㤥� ������� �������
SubRezArg Proc near
         cmp Error,0
         jne SRAend

         cmp ActiveButtonCode,Subtraction
         jne SRAend

         mov Operation,2         ; ��������� ������ '-'

         lea di,Rez              ; ��࠭��� ��ப�
                                 ; �����/�뢮�� �
                                 ; ��६����� Rez -
                                 ; 㬥��蠥���

         call ConvertStringToFloat
         mov StrDisplay[12],0FFh

  SRAend:ret
SubRezArg EndP

; ��������� ⮣� �� �� ��ᯫ�� � ⥬,
; �� �㤥� ������� �������
MulRezArg Proc near
         cmp Error,0
         jne MRAend

         cmp ActiveButtonCode,Multiplication
         jne MRAend

         mov Operation,3         ; ��������� ������ '*'

         lea di,Rez              ; ��࠭��� ��ப�
                                 ; �����/�뢮�� �
                                 ; ��६����� Rez -
                                 ; 1-� �����⥫�

         call ConvertStringToFloat
         mov StrDisplay[12],0FFh

  MRAend:ret
MulRezArg EndP

; ������� ⮣� �� �� ��ᯫ�� �� �,
; �� �㤥� ������� �������
DivRezArg Proc near
         cmp Error,0
         jne DRAend

         cmp ActiveButtonCode,Division
         jne DRAend

         mov Operation,4         ; ��������� ������ '/'

         lea di,Rez              ; ��࠭��� ��ப�
                                 ; �����/�뢮�� �
                                 ; ��६����� Rez -
                                 ; �������

         call ConvertStringToFloat
         mov StrDisplay[12],0FFh

  DRAend:ret
DivRezArg EndP

; �믮������ ����⢨�
Calculate Proc near
         cmp Error,0
         jne Calcend

         cmp ActiveButtonCode,Calculation
         jne Calcend

         cmp Operation,0         ; �᫨ ���� ��������
         je Calcend              ; '=', � ��祣� ��
                                 ; �㤥�

         lea di,Arg              ; 2-�� ��㬥�� ����樨

         call ConvertStringToFloat
         lea si,Rez
         xchg di,si

         cmp Operation,1
         jne Calcm1

         call AddFunc            ; ᫮�����
         jmp Calcm4

  Calcm1:cmp Operation,2
         jne Calcm2

         call SubFunc            ; ���⠭��
         jmp Calcm4

  Calcm2:cmp Operation,3
         jne Calcm3

         call MulFunc            ; 㬭������
         jmp Calcm4

  Calcm3:cmp Operation,4
         jne Calcend

         cmp StrDisplay[10],0           ; �᫨ ��ப� �����
         je CalcEr               ; ����, � �������
                                 ; �� ���

         call DivFunc            ; �������

  Calcm4:call OverflowChecking   ; ����஫� ��९�������
         cmp al,0FFh
         jne Calcm5

  Calcer:mov Error,0Fh           ; �訡��
         jmp Calcend

  Calcm5:lea si,Rez              ; �८�ࠧ������ ����-
                                 ; 祭���� १����
                                 ; ��� ���쭥�襣�
                                 ; �⮡ࠦ����

         call ConvertFloatToString
         mov StrDisplay[12],0FFh

         mov Operation,0

 Calcend:ret
Calculate EndP

; ���⪠ ��६�����
Clear Proc near
         cmp ActiveButtonCode,Clr
         jne Cend

         lea di,Rez              ; ���㫥��� 1-���
         call FloatClear         ; ��㬥��
         lea di,Arg              ; ���㫥��� 2-���
         call FloatClear         ; ���㬥��

         mov Operation,0         ; ����樨 ���

         call StrClear           ; ���⪠ ��ப�
                                 ; �����/�뢮��

         cmp Error,0Fh           ; �᫨ �� �� �訡��
         jne Cend                ; �����, � �
         mov Error,0             ; �訡�� ����� ���

    Cend:ret
Clear EndP

; ���⪠ ��ப� ����� �뢮��
CE Proc near
         cmp Error,0
         jne CEend

         cmp ActiveButtonCode,ClrE
         jne CEend

         call StrClear           ; ���⪠ ��ப�
   CEend:ret
CE EndP

; �⪠�
Undo Proc near
         cmp Error,0
         jne Uend

         cmp ActiveButtonCode,Bksp
         jne Uend

         cmp StrDisplay[10],0           ; �᫨ ��ப� ����,
         je Uend                 ; � �⬥���� ��祣�

         mov cx,1
         cmp StrDisplay[0],10           ; �᫨ � ����襬 ����
                                 ; �� �窠, �
         jne Um1 ;               ; 横� 㤠����� ����襣�
                                 ; ����,
         mov cx,2                ; ���� 横� 㤠�����
         mov StrDisplay[11],0           ; �窨 � ᫥���饣�
                                 ; �� ��� ����

     Um1:call RotateStringRight  ; 横� 㤠����� ����
         loop Um1
         dec StrDisplay[10]

         cmp StrDisplay[10],0           ; �᫨ �� ��ᯫ�� 㦥
         jne Uend                ; ��祣� �� ��⠫���,
         call StrClear           ; � ��ப� �����/�뢮��
                                 ; ���� �������

    Uend:ret
Undo EndP

; ���⪠ �����
MemoryClear Proc near
         cmp ActiveButtonCode,MemClr
         jne MCend

         lea di,Mem
         call FloatClear

         cmp Error,0F0h
         jne MCend               ; ��९������� �����
         mov Error,0             ; ��᫥ �� ���⪨ ���

   MCend:ret
MemoryClear EndP

; �뢮� ᮤ�ন���� ����� �� ��ᯫ��
MemoryRead Proc near
         cmp Error,0
         jne MRend

         cmp ActiveButtonCode,MemRd
         jne MRend

         lea si,Mem              ; �८�ࠧ������ ᮤ��-
                                 ; ������ ����� ���
                                 ; ���쭥�襣� �⮡ࠦ����

         call ConvertFloatToString
         mov StrDisplay[12],0FFh

   MRend:ret
MemoryRead EndP

; ���࠭���� � �����
MemorySet Proc near
         cmp Error,0
         jne MSend

         cmp ActiveButtonCode,MemSet
         jne MSend

         lea di,Mem              ; �஡ࠧ������ ��ப�
                                 ; �����/�뢮��, �⮡�-
                                 ; ������ �� ��ᯫ�� ��
                                 ; ����७��� �ଠ�
                                 ; ��� �࠭���� � �����

         call ConvertStringToFloat
         mov StrDisplay[12],0FFh

   MSend:ret
MemorySet EndP

; �������� � �������
MemoryAdd Proc near
         cmp Error,0
         jne MAend

         cmp ActiveButtonCode,MemAdd
         jne MAend

         lea di,Arg              ; ��஥ ᫠������
         call ConvertStringToFloat
         lea si,Mem              ; 1-�� ᫠������ -
         xchg di,si              ; ������

         call AddFunc            ; ᫮����� � �������
         call OverflowChecking   ; ����஫� ��९�������
         cmp al,0FFh
         jne MAend
         mov Error,0F0h          ; ��⠭���� 䫠��
                                 ; ��९������� �����
   MAend:ret
MemoryAdd EndP

; �뢮� �� ��ᯫ�� ᮮ�饭�� Error
ErrMsgOutput Proc near
         cmp Error,0
         je EMOend

         xor al,al
         out 8,al                ; �������
         out 7,al                ; ���������
         out 6,al                ; � ����ࠬ� 8-5
         out 5,al

         mov al,73h              ; ���⠭�� ᨬ���� E
         out 4,al                ; � ���� �뢮�� �4
         mov al,60h              ; ���⠭�� ᨬ���� r
         out 3,al                ; � ����� �뢮�� �3,
         out 2,al                ; �2
         out 0,al                ; �0
         mov al,78h              ; ���⠭�� ᨬ���� o
         out 1,al                ; � ���� �1

  EMOend:ret
ErrMsgOutput EndP

; �⮡ࠦ���� ��ப� �뢮��
StrOutput Proc near
         cmp Error,0
         jne SOend

    SOst:xor dx,dx               ; �뢮� ��ப�
         mov bx,offset OutputMap
         lea si,StrDisplay
         push si
   SOCyc:lodsb
         xlat
         cmp al,80h              ; �᫨ ⥪�騩 ���� -
         jne SOm1                ; �窠, � �� ����
         mov ah,al               ; ��OR��� � ᫥���-
         lodsb                   ; 饬� �����
         xlat
         or al,ah
    SOm1:out dx,al
         inc dx
         cmp dx,8
         jne SOCyc

         pop si                  ; ���� ��砫� ��ப�
         add si,9                ; ���� �����
         lodsb
         xlat                    ; �८�ࠧ������
         out dx,al               ; �뢮� �����

   SOend:ret
StrOutput EndP