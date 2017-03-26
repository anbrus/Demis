; ����� ᮤ�ন� �᭮��� � �ᯮ��-
; ��⥫�� ��⥬���᪨� ��楤���

; ������� �������� ᫮�� �� ᫮��; � ॣ���� di -
; ᬥ饭�� dd, � � cx - ���祭�� dw; ��⭮�
; ����頥��� �� ���� ��������, ���⮪ ������
DivDDtoDW Proc near
         push ax
         push dx

         xor dx,dx               ; ���७�� ���襣�
         mov ax,[di+2]           ; ᫮�� dd � ���
         div cx                  ; ������� �� dw
         mov [di+2],ax
         mov ax,[di]             ; ������� ����襣�
         div cx                  ; ᫮�� dd � ��⠪�
                                 ; �� ������� ���襣�
                                 ; ᫮�� �� dw
         mov [di],ax

         pop dx
         pop ax
         ret
DivDDtoDW EndP

; ����ଠ������ �������, ��ࠬ����:
; � di ᬥ饭�� ����⢥����� �᫠,
; � � cx - ࠧ����� ���浪��
MDeNorm Proc near
         push ax

         xor al,al
         cmp byte ptr [di+4],7Fh ; ࠡ��� ⮫쪮 �
         jb DeNst                ; ������⥫�묨
         call FloatNeg           ; �����ᠬ�
         mov al,0FFh

   DeNst:inc di                  ; ���室 � ������
 MDeNcyc:push cx

         mov cx,10               ; 横� ������� �������
         call DivDDtoDW          ; �� 10 � 㢥��祭��
         inc byte ptr [di-1]     ; ���浪� �� 1

         pop cx
         loop MDeNcyc
         dec di

         cmp al,0FFh             ; �᫨ ������ ����-
         jne DeNend              ; 砫쭮 �뫠 ����-
         call FloatNeg           ; ⥫쭠, � ��� �
                                 ; ��᫥ ����ଠ����樨
                                 ; ������ ���� ����-
                                 ; ⥫쭠
  DeNend:pop ax
         ret
MDeNorm EndP

; ��ଠ������ �������, ��ࠬ����:
; � di ᬥ饭�� ����⢥����� �᫠
MantNorm Proc near
         push ax
         push cx

         xor ax,ax
         cmp byte ptr [di+4],7Fh ; ࠡ��� ⮫쪮 �
         jb MantNst              ; ������⥫�묨
         call FloatNeg           ; �����ᠬ�
         mov al,0FFh

 MantNst:inc di                  ; ���室 � ������
         push [di+2]             ; �� ��࠭����
         push [di]

         mov cx,10
   MNcyc:call DivDDtoDW          ; ������ �᫠
         inc ah                  ; �������� ���
         cmp word ptr [di+2],0   ; � ������ ��⥬
         jne MNcyc               ; ������� �� �� 10
         cmp word ptr [di],0     ; �� �� ���, ����
         jne MNcyc               ; ��� �� ���㫨���

         pop [di]                ; ����⠭�������
         pop [di+2]              ; �������

         cmp ah,8                ; ��ଠ����������
         je MantNm3              ; ������ ᮤ�ন�
         jb MantNm2              ; 8 DEC ���

 MantNm1:call DivDDtoDW          ; �᫨ ������ ᮤ��-
         inc byte ptr [di-1]     ; ��� ����� DEC ���,
         dec ah                  ; � �� ���� ������ ��
         cmp ah,8                ; 10 � ���६���஢���
         jne MantNm1             ; ���冷�
         jmp MantNm3

 MantNm2:call MulDDwithDW        ; �᫨ �� ������ �-
         dec byte ptr [di-1]     ; ��ন� ����� DEC
         inc ah                  ; ��� 祬 8, � ��
         cmp ah,8                ; ���� ������� �� 10 �
         jne MantNm2             ; ���६����� ���冷�

 MantNm3:dec di
         cmp al,0FFh             ; �᫨ ������ ����-
         jne MNend               ; 砫쭮 �뫠 ����-
         call FloatNeg           ; ⥫쭠, � ��� �
                                 ; ��᫥ ��ଠ����樨
                                 ; ������ ���� ����-
                                 ; ⥫쭮�
   MNend:pop cx
         pop ax
         ret
MantNorm EndP

; �஢�ઠ ��९������� � ��⨯�९������
; ����⢥����� �᫠; ��ࠬ����:
; � di ᬥ饭�� ����⢥����� �᫠,
; � ॣ���� al �����頥��� 䫠� ��९�������:
; al = 0 - �� ��ଠ�쭮, al = FFh - ��९�������
OverflowChecking Proc near
         cmp byte ptr [di],9     ; �஢�ઠ
         jl OvChm1               ; ��९�������
         mov al,0FFh
         jmp OvChend

  OvChm1:cmp byte ptr [di],-7    ; �஢�ઠ
         jg OvChend              ; ��⨯�९�������
         call FloatClear         ; ������ ��設����
                                 ; ���
 OvChend:ret
OverflowChecking EndP

; �������� ���� ����⢥���� �ᥫ; ��ࠬ����:
; � di - ᬥ饭�� 1-��� ᫠������� � �㬬�,
; � � si - ᬥ饭�� 2-��� ��㬥��
AddFunc Proc near
         push ax
         push cx
         push dx
         push di
         push si

         mov al,[di]             ; �ࠢ�����
         cmp al,[si]             ; ���浪��
         je Ast
         jl ADcyc
         xchg di,si

   ADcyc:xor ch,ch               ; ��ࠢ�������
         mov cl,[si]             ; ���浪��
         sub cl,[di]
         call MDeNorm

     Ast:pop si
         pop di

         mov ax,[di+1]            ; ��᫮����
         mov dx,[di+3]            ; ᫮�����
         add ax,[si+1]            ; ������
         adc dx,[si+3]
         mov [di+1],ax
         mov [di+3],dx

         call MantNorm           ; ��ଠ������
                                 ; �������
         pop dx
         pop cx
         pop ax
         ret
AddFunc EndP

; ���⠭�� ���� ����⢥���� �ᥫ; ��ࠬ����:
; � di - ᬥ饭�� 㬥��蠥���� � ࠧ����,
; � � si - ᬥ饭�� ���⠥����
SubFunc Proc near
         push ax
         push cx
         push dx
         push di
         push si

         mov al,[di]             ; �ࠢ�����
         cmp al,[si]             ; ���浪��
         je Sst
         jl SDcyc
         xchg di,si

   SDcyc:xor ch,ch               ; ��ࠢ�������
         mov cl,[si]             ; ���浪��
         sub cl,[di]
         call MDeNorm

     Sst:pop si
         pop di

         mov ax,[di+1]            ; ��᫮����
         mov dx,[di+3]            ; ���⠭��
         sub ax,[si+1]            ; ������
         sbb dx,[si+3]
         mov [di+1],ax
         mov [di+3],dx

         call MantNorm           ; ��ଠ������
                                 ; �������
         pop dx
         pop cx
         pop ax
         ret
SubFunc EndP

; ������� �����᫮�� �� ᫮��; ��ࠬ����:
; � ॣ���� - di ᬥ饭�� dq, � � cx - ���祭�� dw
DivDQToDW Proc near
         push ax
         push bx
         push dx

         xor dx,dx
         mov bx,8

    Dcyc:dec bx                  ; �� ��������
         dec bx                  ; �������筮
                                 ; ��楤��
         mov ax,[di+bx]          ; DivDDToDw
         div cx
         mov [di+bx],ax

         cmp bx,0
         jne Dcyc

         pop dx
         pop bx
         pop ax
         ret
DivDQToDW EndP

; ��������� �������� ᫮�� �� �������� ᫮��;
; ��ࠬ����: � di - ᬥ饭�� ��㬥��1,
; � si - ��㬥��2; १���� � ��६����� MulRez
MulDDWithDD Proc near
         push ax
         push dx

         mov word ptr [MulRez],0
         mov word ptr [MulRez+2],0
         mov word ptr [MulRez+4],0
         mov word ptr [MulRez+6],0

         mov ax,[di]             ; 㬭������
         mul word ptr [si]       ; ������ ᫮�
         mov MulRez,ax
         mov MulRez+2,dx

         mov ax,[di]             ; 㬭������
         mul word ptr [si+2]     ; �।���
         add MulRez+2,ax         ; ᫮�
         adc MulRez+4,dx

         mov ax,[di+2]
         mul word ptr [si]
         add MulRez+2,ax
         adc MulRez+4,dx

         mov ax,[di+2]           ; 㬭������
         mul word ptr [si+2]     ; ����� ᫮�
         add MulRez+4,ax
         adc MulRez+6,dx

         pop dx
         pop ax
         ret
MulDDWithDD EndP

; ��������� ���� ����⢥���� �ᥫ; ��ࠬ����:
; � di - ᬥ饭�� 1-��� �����⥫� � �ந��������,
; � � si - ᬥ饭�� 2-��� �����⥫�
MulFunc Proc near
         push ax
         push bx
         push cx

         xor bx,bx

         cmp byte ptr [di+4],7Fh ; ࠡ���
         jb MFm1                 ; ⮫쪮 �
         call FloatNeg           ; ������⥫�묨
         mov bl,1                ; �����ᠬ�

    MFm1:cmp byte ptr [si+4],7Fh
         jb MFst
         xchg si,di
         call FloatNeg
         xchg si,di
         mov bh,1

    MFst:mov al,[di]             ; ᫮�����
         add al,[si]             ; ���浪��
         mov [di],al

         inc si                  ; ���室 �
         inc di                  ; �����ᠬ

         call MulDDWithDD        ; ᮡ�⢥��� 㬭������

         push di                 ; ���४�� �ந�����-
         mov cx,10000            ; ��� ������ ��⥬
         lea di,MulRez           ; ������� �� �� 10�7,
         call DivDQToDW          ; � �.�. ������ ����
         mov cx,1000             ; �뫮 �� 10�8, �
         call DivDQToDW          ; ���६��� ���浪�
         pop di                  ; ����祭���� �����-
         dec byte ptr [di-1]     ; ������� �᫠

         mov ax,MulRez           ; ��᫮����
         mov [di],ax             ; �����������
         mov ax,MulRez+2         ; १����
         mov [di+2],ax

         dec si
         dec di

         call MantNorm           ; ��ଠ������ �������

         add bl,bh               ; ��।������ �����
         cmp bl,1                ; �ந��������
         jne MFend               ; ����⢥����
         call FloatNeg           ; �ᥫ

   MFend:pop cx
         pop bx
         pop ax
         ret
MulFunc EndP

; ������� ���� ����⢥���� �ᥫ; ��ࠬ����:
; � di - ᬥ饭�� �������� � ��⭮��,
; � � si - ᬥ饭�� ����⥫�
DivFunc Proc near
         push ax
         push bx
         push cx

         xor bx,bx

         cmp byte ptr [di+4],7Fh ; ࠡ���
         jb DFnextS              ; ⮫쪮 �
         call FloatNeg           ; ������⥫�묨
         mov bl,1                ; �����ᠬ�

 DFnextS:cmp byte ptr [si+4],7Fh
         jb DFst
         xchg si,di
         call FloatNeg
         xchg si,di
         mov bh,1

    DFst:mov al,[di]             ; ���⠭��
         sub al,[si]             ; ���浪��
         mov [di],al

         inc si                  ; ���室 �
         inc di                  ; �����ᠬ

         push [si]
         push [si+2]
         push ax
         mov ax, 05F5h
         mov [si+2],ax           ; ���४�� �������
         mov ax, 0E100h
         mov [si],ax             ; �������� ��⥬
         pop ax
         call MulDDWithDD        ; 㬭������ �� �� 10�8
         pop [si+2]
         pop [si]

         mov cx,32               ; ������� ������ ��
                                 ; ������� � �����-
                                 ; �������� ���⪠
                                 
  DFDcyc:shl word ptr MulRez,1   ; ᤢ�� ����� ��⭮��
         rcl word ptr MulRez+2,1 ; � ���⪠
         rcl word ptr MulRez+4,1
         rcl word ptr MulRez+6,1
         pushf                   ; ��࠭���� ��७��

         mov ax,MulRez+4         ; ���⠭�� �� 
         sub ax,[si]             ; ���⪠ ����⥫�
         mov MulRez+4,ax
         mov ax,MulRez+6
         sbb ax,[si+2]
         mov MulRez+6,ax

         jc DFm2                 ; �᫨ ࠧ����� < 0
         popf

    DFm1:add word ptr MulRez,1   ; ࠧ��
         adc word ptr MulRez+2,0 ; ��⭮�� = 1
         jmp Dloop

    DFm2:popf
         jc DFm1                 ; �஢�ઠ ��७�� ��
                                 ; ᤢ��� ���⪠

         mov ax,MulRez+4         ; ����⠭�������
         add ax,[si]             ; ���⪠
         mov MulRez+4,ax
         mov ax,MulRez+6
         adc ax,[si+2]
         mov MulRez+6,ax

   Dloop:loop DFDcyc

         mov ax,MulRez           ; ��᫮����
         mov [di],ax             ; �����������
         mov ax,MulRez+2         ; १����
         mov [di+2],ax

         dec si
         dec di

         call MantNorm           ; ��ଠ������ �������

         add bl,bh               ; ��।������ �����
         cmp bl,1                ; ��⭮�� ����
         jne DFend               ; ����⢥����
         call FloatNeg           ; �ᥫ

   DFend:pop cx
         pop bx
         pop ax
         ret
DivFunc EndP