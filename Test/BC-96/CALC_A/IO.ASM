RotateStringRight Proc near
         push ax
         push bx

         xor bx,bx
  RSRcyc:mov ah,Str[bx+1]
         mov Str[bx],ah
         inc bx
         cmp bx,8
         jne RSRcyc
         mov Str[8],12

         pop bx
         pop ax
         ret
RotateStringRight EndP

RotateStringLeft Proc near
         push ax
         push bx

         mov bx,8
  RSLcyc:mov ah,Str[bx-1]
         mov Str[bx],ah
         dec bx
         jnz RSLcyc
         mov Str[0],12

         pop bx
         pop ax
         ret
RotateStringLeft EndP

KbdRead Proc near
         push ax
         push cx
         push dx

; ���� ���⮢ ����� 2-0 � ��室 ⮫쪮 ��᫥
; ������ �����-���� ������ �� ᮥ�������� � ���⠬�
    KRm1:mov dx,3
   KRCyc:dec dl
         in al,dx
         cmp al,0
         jne KRexit
         cmp dl,0
         jnz KRCyc
         jmp KRm1
  KRexit:push ax

; ���� �� �⦠�� ������
    KRm2:in al,dx
         or al,al
         jnz KRm2

         pop ax ; ⥯��� � dl-����� ��⨢���� ����, � � al-��� ᮤ�ন���

; ��।������ ����� ��⨢���� �室� ��⨢���� ����
         xor cl,cl
    KRm3:inc cl
         shr al,1
         jnz KRm3 ; ������� �� �� ���, ���� 1 �� 㩤��
         dec cl

; ����� ���� ������
         mov al,dl
         shl al,3
         add al,cl

         mov ActiveButtonCode,al

         pop dx
         pop cx
         pop ax
         ret
KbdRead EndP

; ���� ��।��� ���� �᫠
DigInput Proc near
         push ax

         cmp Error,0
         jne DIend

         mov al,ActiveButtonCode

; �஢�ઠ, � ����⢨⥫쭮 �� ����� ��஢�� ������
         cmp al,0
         jb DIend
         cmp al,9
         ja DIend

; � ����� ���� ��ப� ���� ������� ������ ?
         cmp Str[12],0FFh
         jne DIm1
         call StrClear
         mov Str[12],0

    DIm1:cmp Str[10],8
         je  DIend ; 㦥 ����� 8 ��� {����� ���㤠}

         cmp Str[10],0 ; ��ப� �����?
         jne DIm2
         cmp al,0 ; � ����� ������ "0"
         jne DIm2
         call DispClear ; �뢥�� � ����訩 ࠧ�� '0'
         jmp DIend

    DIm2:call RotateStringLeft ; ᤢ�� ࠭�� ��������� ࠧ�冷�

; ������ ᨬ����-���� � ����訩 ࠧ��
         mov Str[0],al
         inc Str[10]

   DIend:pop ax
         ret
DigInput EndP

PointInput Proc near
         push ax

         cmp Error,0
         jne PIend

         mov al,ActiveButtonCode

         cmp al,10 ; ����� ������ "." ?
         jne PIend ; ���, ⮣�� ��室�� �� ��楤���

; � ����� ���� ��ப� ���� ������� ������ ?
         cmp Str[12],0FFh
         jne PIm1
         call StrClear
         mov Str[12],0

    PIm1:cmp Str[11],0FFh ; � ����� ���� ��� 㦥 �������?
         je PIend ; ��, � ��� ���� �窨 ����������

         cmp Str[10],0 ; ��ப� �����?
         jne PIm2 ; ��� � ���室
         mov Str[0],0  ; ��, ⮣�� ᠬ� ���訩
         inc Str[10] ; ���� ������ ���� �㫥��

    PIm2:call RotateStringLeft ; ᤢ�� ࠭�� ��������� ࠧ�冷�

; ������ �窨 � ����訩 ࠧ�� � ��⠭����
; 䫠�� ������ �窨 � ��ப�
         mov Str[0],al
         mov Str[11],0FFh

   PIend:pop ax
         ret
PointInput EndP

SignChange Proc near
         cmp Error,0
         jne SCend

         cmp ActiveButtonCode,11 ; ����� ������ "+/-" ?
         jne SCend ; ���, ⮣�� ��室�� �� ��楤���

; ᬥ�� �����
         cmp Str[9],12
         jne SCSP
         mov Str[9],11 ; ���� "-"
         jmp SCend
    SCSP:mov Str[9],12 ; ���� "+"

   SCend:ret
SignChange EndP

Calculate Proc near
         push ax

         cmp Error,0
         jne Calcend

         cmp ActiveButtonCode,12
         jne Calcend

         cmp Operation,0
         je Calcend

         lea di,Arg
         call ConvertStringToFloat
         lea si,Rez
         xchg di,si

         cmp Operation,1
         jne Calcm1

         call AddFunc
         jmp Calcm4

  Calcm1:cmp Operation,2
         jne Calcm2

         call SubFunc
         jmp Calcm4

  Calcm2:cmp Operation,3
         jne Calcm3

         call MulFunc
         jmp Calcm4

  Calcm3:cmp Operation,4
         jne Calcend

         cmp Str[10],0 ; ��ப� ����� ���� � �����
         je CalcEr

         call DivFunc

  Calcm4:call OverflowChecking
         cmp al,0FFh
         jne Calcm5
  Calcer:mov Error,0Fh
         jmp Calcend

  Calcm5:lea si,Rez
         call ConvertFloatToString
         mov Str[12],0FFh

         mov Operation,0

 Calcend:pop ax
         ret
Calculate EndP

AddRezArg Proc near
         cmp Error,0
         jne ARAend

         cmp ActiveButtonCode,13
         jne ARAend

; ��࠭��� ��ப� �����/�뢮�� � ��६����� Rez � ��������� ������ +
         mov Operation,1
         lea di,Rez
         call ConvertStringToFloat
         mov Str[12],0FFh

  ARAend:ret
AddRezArg EndP

SubRezArg Proc near
         cmp Error,0
         jne SRAend

         cmp ActiveButtonCode,14
         jne SRAend

; ��࠭��� ��ப� �����/�뢮�� � ��६����� Rez � ��������� ������ -
         mov Operation,2
         lea di,Rez
         call ConvertStringToFloat
         mov Str[12],0FFh

  SRAend:ret
SubRezArg EndP

MulRezArg Proc near
         cmp Error,0
         jne MRAend

         cmp ActiveButtonCode,15
         jne MRAend

; ��࠭��� ��ப� �����/�뢮�� � ��६����� Rez � ��������� ������ *
         mov Operation,3
         lea di,Rez
         call ConvertStringToFloat
         mov Str[12],0FFh

  MRAend:ret
MulRezArg EndP

DivRezArg Proc near
         cmp Error,0
         jne DRAend

         cmp ActiveButtonCode,16
         jne DRAend

; ��࠭��� ��ப� �����/�뢮�� � ��६����� Rez � ��������� ������ /
         mov Operation,4
         lea di,Rez
         call ConvertStringToFloat
         mov Str[12],0FFh

  DRAend:ret
DivRezArg EndP

Clear Proc near
         push di

         cmp ActiveButtonCode,17 ; ����� ������ "C" ?
         jne Cend ; ���, ⮣�� ��室�� �� ��楤���

         lea di,Rez
         call FloatClear
         lea di,Arg
         call FloatClear

         mov Operation,0

         call StrClear

         cmp Error,0Fh
         jne Cend
         mov Error,0

    Cend:pop di
         ret
Clear EndP

CE Proc near
         cmp Error,0
         jne CEend

         cmp ActiveButtonCode,18 ; ����� ������ "CE" ?
         jne CEend ; ���, ⮣�� ��室�� �� ��楤���

         call StrClear  ; ���⪠ ��ப� �����/�뢮��
   CEend:ret
CE EndP

Undo Proc near
         push cx

         cmp Error,0
         jne Uend

         cmp ActiveButtonCode,19 ; ����� ������ "BKSP" ?
         jne Uend  ; ���, ⮣�� ��室�� �� ��楤���

         cmp Str[10],0 ; ��ப� �����?
         je Uend ; ��, � �⬥���� ��祣�

         mov cx,1
         cmp Str[0],10 ; � ����襬 ���� �窠?
         jne Um1 ; ���, ⮣�� 1 横� 㤠����� ����襣� ����
         mov cx,2
     Um1:call RotateStringRight
         loop Um1
         dec Str[10]

         cmp Str[10],0 ; � ����� �� ��ᯫ�� 㦥 ��祣� �� ��⠫���?
         jne Uend
         call StrClear  ; ���⪠ ��ப� �����/�뢮��

    Uend:pop cx
         ret
Undo EndP

MemoryClear Proc near
         push di

         cmp ActiveButtonCode,20 ; ����� ������ "MC" ?
         jne MCend

         lea di,Mem
         call FloatClear

         cmp Error,0F0h
         jne MCend
         mov Error,0

   MCend:pop di
         ret
MemoryClear EndP

MemoryRead Proc near
         push si

         cmp Error,0
         jne MRend

         cmp ActiveButtonCode,21 ; ����� ������ "MR" ?
         jne MRend

         lea si,Mem
         call ConvertFloatToString
         mov Str[12],0FFh

   MRend:pop si
         ret
MemoryRead EndP

MemorySet Proc near
         push di

         cmp Error,0
         jne MSend

         cmp ActiveButtonCode,22 ; ����� ������ "X->M" ?
         jne MSend

         lea di,Mem
         call ConvertStringToFloat
         mov Str[12],0FFh

   MSend:pop di
         ret
MemorySet EndP

MemoryAdd Proc near
         push ax
         push si
         push di

         cmp Error,0
         jne MAend

         cmp ActiveButtonCode,23 ; ����� ������ "M+" ?
         jne MAend

         lea di,Arg
         call ConvertStringToFloat
         lea si,Mem
         xchg di,si

         call AddFunc
         call OverflowChecking
         cmp al,0FFh
         jne MAend
         mov Error,0F0h

   MAend:pop di
         pop si
         pop ax
         ret
MemoryAdd EndP

StrOutput Proc near
         push ax
         push bx
         push dx
         push si

         cmp Error,0
         je SOm1
         call ErrMsgOut
         jmp SOend

    SOm1:cmp Str[10],0 ; ��ப� �����?
         jne SOst
         call DispClear ; ��, � �㦭� ������ ��ᯫ��
         jmp SOend

; �뢮� ��ப�
    SOst:xor dx,dx
         mov bx,offset OutputMap
         lea si,Str
         push si
   SOCyc:lodsb
         xlat
         cmp al,80h
         jne SOm2
         mov ah,al
         lodsb
         xlat
         or al,ah
    SOm2:out dx,al
         inc dx
         cmp dx,8
         jne SOCyc

; �뢮� �����
         pop si
         add si,9
         lodsb
         xlat
         out dx,al

   SOend:pop si
         pop dx
         pop bx
         pop ax
         ret
StrOutput EndP
