MulDDwithDW Proc near ; � ॣ���� di ᬥ饭�� dd, � � cx - ���祭�� dw
         push ax
         push dx

         mov ax,[di+2]
         mul cx
         mov [di+2],ax
         mov ax,[di]
         mul cx
         mov [di],ax
         add [di+2],dx

         pop dx
         pop ax
         ret
MulDDwithDW EndP

CalculateMantissa Proc near  ; di ������ �祩�� �㤠 �������� �������
         push ax
         push bx
         push cx

         xor ah,ah
         mov cx,10

         mov bl,Str[10]      ; �᫮ ����⢨⥫��� ��� {ᬥ饭�� ���襣�
                             ; ࠧ�鸞} �᫨ ���� �窠
         cmp Str[11],0FFh    ; �窠 ����?
         je CMMcyc           ; ��, � ���室
         dec bl

; ��� ��� ��� �᫠ ��稭�� � ���襩
  CMMcyc:mov al,Str[bx]
         dec bl

         cmp al,10           ; �窠?
         jne CMm1            ; ���
         cmp bl,-1           ; � ���� ��ப�?
         je CMMend
         jne CMMcyc

    CMm1:call MulDDwithDW

; ᫮����� dd c ��ࠡ��뢠���� ��ன
         add [di],ax
         adc word ptr [di+2],0

         cmp bl,-1           ; ������ ࠧ��� ���稫���?
         jnz CMMcyc

  CMMend:nop

; ��ࠡ�⪠ ��������� ࠧ�冷�, �᫨ ��� ����
         mov al,8

         cmp byte ptr [di-1],0
         jg CMm2
         sub al,[di-1]
         inc al            ; 0-�� 楫�� ���� ��⠫��� ࠧ�冷�

    CMm2:sub al,Str[10]
         jz CMend          ; ����

    CMm3:call MulDDwithDW
         dec al
         jnz CMm3

   CMend:pop cx
         pop bx
         pop ax
         ret
CalculateMantissa EndP

CalculateOrder Proc near     ; di ������ �祩�� �㤠 �������� ���冷�
         push ax
         push bx
         push cx

         xor bh,bh
         mov bl,Str[10]      ; �᫮ ����⢨⥫��� ��� {ᬥ饭�� ���襣�
                             ; ࠧ�鸞} �᫨ ���� �窠
         cmp Str[11],0       ; �窨 ���?
         jne COm1            ; ����, � ���室
         mov [di],bl         ; ���冷� ࠢ�� �᫮ �����. ���
         jmp COend

    COm1:xor cx,cx
         mov al,Str[bx]
         cmp al,0            ; 楫�� ��� ���?
         jne COm2            ; ����, � ���室

; ���� ����⥫쭮�� ���浪�
         dec bl              ; �ய�� �窨
  COcyc1:dec bl
         dec cx
         mov al,Str[bx]

         cmp bl,-1 ; � ����� ���� ��ப� �����
                   ; �� ����� ��� ����� 0
         je COend

         cmp al,0
         je COcyc1

         inc cl
         mov [di],cl
         jmp COend

; ���� ������⥫쭮�� ���浪�
    COm2:dec bl
         inc cx
         mov al,Str[bx]
         cmp al,10
         jne COm2
         mov [di],cl

   COend:pop cx
         pop bx
         pop ax
         ret
CalculateOrder EndP

ConvertStringToFloat Proc near ; � ॣ���� di ᬥ饭�� ����⢥����� �᫠
         call FloatClear
         cmp Str[10],0       ; ��ப� �����?
         je CSFend

         call CalculateOrder ; ��।������ ���浪�

; ��।������ �������
         inc di
         call CalculateMantissa
         dec di

; ᬥ�� �����
         cmp Str[9],11       ; �᫮ ����⥫쭮�?
         jne CSFend          ; ���, � ���室
         call FloatNeg       ; ��, � ���饭�� ����� �᫠

  CSFend:ret
ConvertStringToFloat EndP

MantissaConvert Proc near ; � si ��㤠 ���� �������
         push ax
         push cx
         push dx

; �뤢������ DEC ��� �᫠ �� �����, ��稭�� � ����襩
         mov cx,10
  MCMcyc:mov ax,[si+2]
         xor dx,dx
         div cx
         mov [si+2],ax
         mov ax,[si]
         div cx
         mov [si],ax

         call RotateStringRight ; ᤢ�� ࠧ�冷� ��ப�
         mov Str[7],dl ; ������ ���⪠

         cmp word ptr [si+2],0
         jne MCMcyc
         cmp word ptr [si],0
         jne MCMcyc

         mov Str[10],8

         pop dx
         pop cx
         pop ax
         ret
MantissaConvert EndP

OrderConvert Proc near ; � si ��㤠 ���� ���冷�
         push ax
         push bx
         push cx

         cmp byte ptr [si],1 ; �業�� ���浪�
         jl OCm1 ; ���冷� ����� 1 {��� 楫�� ���}, � ���室

; ���⠭���� �窨, �᫨ ���� 楫�� ����
         mov bx,7
         xor cx,cx
         add cx,[si]
 OCMcyc1:mov al,Str[bx] ; ᤢ�� �����
         mov Str[bx+1],al ; ࠧ�冷� �����
         dec bx
         loop OCMcyc1
         mov Str[bx+1],10 ; ������ �� ���� ����襣�
                          ; �� ����� ࠧ�冷� �窨
         mov Str[11],0FFh ; ��⠭���� 䫠�� ������ �窨
         jmp OCend

; ���⠭���� �窨 �᫨ ��� 楫�� ���
    OCm1:mov cx,1
         sub cl,[si]
         mov Str[8],0
 OCMcyc2:call RotateStringRight
         mov Str[8],0
         loop OCMcyc2
         mov Str[7],10 ; ������ �窨
         mov Str[11],0FFh ; ��⠭���� 䫠�� ������ �窨

   OCend:pop cx
         pop bx
         pop ax
         ret
OrderConvert EndP

ConvertFloatToString Proc near ; � ॣ���� si ᬥ饭�� �᫠
         push [si+3]
         push [si+1]
         push [si]
         push di

         call StrClear

         cmp word ptr [si+3],0
         jne CFSst
         cmp word ptr [si+1],0
         je CFSend

   CFSst:inc si ; ���室 � ��ࠡ�⪥ �������
         mov Str[9],12 ; ��⠥���, �� �᫮ ������⥫쭮
         cmp byte ptr [si+3],7Fh ; ����⥫쭮� �᫮?
         jb CFSm1 ; ���, ������⥫쭮�

         mov Str[9],11       ; ��, ����⥫쭮�,
         mov di,si           ; ⮣�� ����� ��, �
         dec di              ; �᫮ ᤥ����
         call FloatNeg       ; ������⥫��

   CFSm1:call MantissaConvert

         dec si
         call OrderConvert ; ��� ���浪�

; 㤠����� �������� �㫥� � ���� �������
   CFSZD:cmp Str[0],0
         jne CFSPD
         call RotateStringRight
         dec Str[10]
         jmp CFSZD

; 㤠����� �窨 � ����
   CFSPD:cmp Str[0],10
         jne CFSend
         call RotateStringRight
         mov Str[11],0 ; ��� 䫠�� ������ �窨

  CFSend:pop di
         pop [si]
         pop [si+1]
         pop [si+3]
         ret
ConvertFloatToString EndP
