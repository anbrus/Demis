DivDDtoDW Proc near ; � ॣ���� di ᬥ饭�� dd, � � cx - ���祭�� dw
         push ax
         push dx

         mov ax,[di+2]
         xor dx,dx
         div cx
         mov [di+2],ax
         mov ax,[di]
         div cx
         mov [di],ax

         pop dx
         pop ax
         ret
DivDDtoDW EndP

DDDeNorm Proc near ; � di ���� float, � � cx ࠧ����� ���浪��
         push ax

         xor al,al
         cmp byte ptr [di+4],7Fh
         jb DeNst
         call FloatNeg
         mov al,0FFh

   DeNst:inc di ; ���室 � ������
   DDDeNcyc: ; ������� ������� dd �� 10
         push cx

         mov cx,10
         call DivDDtoDW
         inc byte ptr [di-1] ; 㢥��祭�� �� 1 ���浪�

         pop cx
         loop DDDeNcyc
         dec di

         cmp al,0FFh
         jne DeNend
         call FloatNeg

  DeNend:pop ax
         ret
DDDeNorm EndP

DDNorm Proc near ; � di ���� float
         push ax
         push cx

         xor al,al
         cmp byte ptr [di+4],7Fh
         jb DDNst
         call FloatNeg
         mov al,0FFh

   DDNst:push [di+3] ; ��࠭����
         push [di+1] ; �������

         inc di ; ���室 � ������
         xor ah,ah
         mov cx,10
  DDNcyc:call DivDDtoDW
         inc ah
         cmp word ptr [di+2],0
         jne DDNcyc
         cmp word ptr [di],0
         jne DDNcyc

         pop [di]
         pop [di+2]

         cmp ah,8
         je DDNm3
         jb DDNm2

   DDNm1:call DivDDtoDW
         inc byte ptr [di-1]
         dec ah
         cmp ah,8
         jne DDNm1
         jmp DDNm3

   DDNm2:call MulDDwithDW
         dec byte ptr [di-1]
         inc ah
         cmp ah,8
         jne DDNm2

   DDNm3:dec di
         cmp al,0FFh
         jne DDNend
         call FloatNeg

  DDNend:pop cx
         pop ax
         ret
DDNorm EndP

; � di float, �����  �஢������,
; �����頥� � al 䫠� ��९�������
OverflowChecking Proc near
; �஢�ઠ �� ��९�������
         cmp byte ptr [di],9
         jl OvChm1
         mov al,0FFh
         jmp OvChend

; �஢�ઠ �� ��⨯�९�������
  OvChm1:cmp byte ptr [di],-7
         jg OvChend
         call FloatClear

 OvChend:ret
OverflowChecking EndP

AddFunc Proc near ; � di ��㬥��1 � १����, � � si - ��㬥��2
         push ax
         push cx
         push dx
         push di
         push si

         mov cx,10
; ��ࠢ������� ���浪�� �� ����襣�
         mov al,[di]
         cmp al,[si]
         je Ast
         jl ADcyc
         xchg di,si

   ADcyc:xor ch,ch
         mov cl,[si]
         sub cl,[di]
         call DDDeNorm

; ᮡ�⢥��� ᫮�����
     Ast:pop si
         pop di

         mov ax,di[1]
         mov dx,di[3]
         add ax,si[1]
         adc dx,si[3]
         mov di[1],ax
         mov di[3],dx

         call DDNorm ; ��ଠ������ �������, �᫨ ����室���

         pop dx
         pop cx
         pop ax
         ret
AddFunc EndP

SubFunc Proc near ; � di ��㬥��1 � १����, � � si - ��㬥��2
         push ax
         push cx
         push dx
         push di
         push si

         mov cx,10
; ��ࠢ������� ���浪�� �� ����襣�
         mov al,[di]
         cmp al,[si]
         je Sst
         jl SDcyc
         xchg di,si

   SDcyc:xor ch,ch
         mov cl,[si]
         sub cl,[di]
         call DDDeNorm

; ᮡ�⢥��� ���⠭��
     Sst:pop si
         pop di

         mov ax,di[1]
         mov dx,di[3]
         sub ax,si[1]
         sbb dx,si[3]
         mov di[1],ax
         mov di[3],dx

         call DDNorm ; ��ଠ������ �������, �᫨ ����室���

         pop dx
         pop cx
         pop ax
         ret
SubFunc EndP

DivDQToDW Proc near ; � ॣ���� di ᬥ饭�� dq, � � cx - ���祭�� dw
         push ax bx dx

         xor dx,dx
         mov bx,8

    Dcyc:dec bx
         dec bx

         mov ax,[di+bx]
         div cx
         mov [di+bx],ax

         cmp bx,0
         jne Dcyc

         pop  dx bx ax
         ret
DivDQToDW EndP

; � di ��㬥��1, � si - ��㬥��2, १���� � ��६����� MulRez
MulDDWithDD Proc near
         push ax dx

         mov word ptr [MulRez],0     
         mov word ptr [MulRez+2],0     
         mov word ptr [MulRez+4],0     
         mov word ptr [MulRez+6],0     
    
         mov ax,[di]       ; 㬭������
         mul word ptr [si] ; ������ ᫮�
         mov MulRez,ax
         mov MulRez+2,dx

         mov ax,[di]
         mul word ptr [si+2]
         add MulRez+2,ax
         adc MulRez+4,dx

         mov ax,[di+2]
         mul word ptr [si]
         add MulRez+2,ax
         adc MulRez+4,dx

         mov ax,[di+2]       ; 㬭������
         mul word ptr [si+2] ; ����� ᫮�
         add MulRez+4,ax
         adc MulRez+6,dx

         pop dx ax
         ret
MulDDWithDD EndP

MulFunc Proc near ; � di ��㬥��1 � १����, � � si - ��㬥��2
         push ax bx cx

         xor bx,bx

         cmp byte ptr [di+4],7Fh
         jb MFm1
         call FloatNeg
         mov bl,1

    MFm1:cmp byte ptr [si+4],7Fh
         jb MFst
         xchg si,di
         call FloatNeg
         xchg si,di
         mov bh,1

    MFst:mov al,[di] ; ᫮�����
         add al,[si] ; ���浪��
         mov [di],al

         inc si ; ���室 �
         inc di ; �����ᠬ

         call MulDDWithDD ; ᮡ�⢥��� 㬭������

; ���४�� १���� ��⥬ ������� �� 10�7
         push di
         mov cx,10000
         lea di,MulRez
         call DivDQToDW
         mov cx,1000
         call DivDQToDW
         pop di
         dec byte ptr [di-1]

         mov ax,MulRez
         mov [di],ax
         mov ax,MulRez+2
         mov [di+2],ax

         dec si
         dec di

         call DDNorm ; ��ଠ������ �������, �᫨ ����室���

         add bl,bh
         cmp bl,1
         jne MFend
         call FloatNeg

   MFend:pop cx bx ax
         ret
MulFunc EndP

DivFunc Proc near ; � di ��㬥��1 � १����, � � si - ��㬥��2
         push ax bx cx

         xor bx,bx

         cmp byte ptr [di+4],7Fh
         jb DFnextS
         call FloatNeg
         mov bl,1

 DFnextS:cmp byte ptr [si+4],7Fh
         jb DFst
         xchg si,di
         call FloatNeg
         xchg si,di
         mov bh,1

    DFst:mov al,[di] ; ���⠭��
         sub al,[si] ; ���浪��
         mov [di],al

         inc si ; ���室 �
         inc di ; �����ᠬ

         push [si]
         push [si+2]
         mov [si+2],05F5h
         mov [si],0E100h
         call MulDDWithDD ; ���४�� �������� 㬭������� �� 10�8
         pop [si+2]
         pop [si]

; ᮡ�⢥��� �������
         mov cx,32
  DFDcyc: ; ᤢ�� ����� ���⪠ � ��⭮��
         shl word ptr MulRez,1
         rcl word ptr MulRez+2,1
         rcl word ptr MulRez+4,1
         rcl word ptr MulRez+6,1
         pushf ; ��࠭���� ��७��

; ���⠭�� �� ���⪠ ����⥫�
         mov ax,MulRez+4
         sub ax,[si]
         mov MulRez+4,ax
         mov ax,MulRez+6
         sbb ax,[si+2]
         mov MulRez+6,ax

; �஢�ઠ ����� ࠧ����
         jc DFm2 ; �᫨ ࠧ����� ����� 0
         popf

    DFm1: ; ࠧ�� ��⭮��=1
         add word ptr MulRez,1
         adc word ptr MulRez+2,0
         jmp Dloop

    DFm2:popf
         jc DFm1 ; �஢�ઠ ��७�� �� ᤢ��� ���⪠

; ����⠭������� ���⪠
         mov ax,MulRez+4
         add ax,[si]
         mov MulRez+4,ax
         mov ax,MulRez+6
         adc ax,[si+2]
         mov MulRez+6,ax

   Dloop:loop DFDcyc

         mov ax,MulRez
         mov [di],ax
         mov ax,MulRez+2
         mov [di+2],ax

         dec si
         dec di

         call DDNorm ; ��ଠ������ �������, �᫨ ����室���

         add bl,bh
         cmp bl,1
         jne DFend
         call FloatNeg

   DFend:pop cx bx ax
         ret
DivFunc EndP
