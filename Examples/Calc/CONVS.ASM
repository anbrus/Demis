; ����� ᮤ�ন� ��楤��� �८�ࠧ������
; ��ப� �����/�뢮�� ������ �� ��ᯫ�� �
; ����⢥���� �᫮ � ᮮ⢥��⢨� � ��࠭��
; �ଠ⮬ ��ப� �����/�뢮�� � ����⢥����
; �ᥫ � ��楤��� �८�ࠧ������ ����⢥����
; �ᥫ � ��ப� �����/�뢮��

; ��������� �������� ᫮�� �� ᫮��; ��ࠬ����:
; � ॣ���� di - ᬥ饭�� dd, � � cx - ���祭�� dw
MulDDwithDW Proc near
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

; ���᫥��� ������� ����⢥����� �᫠;
; ॣ���� di ������ �祩�� �����, �
; ������ �㦭� �������� �������
CalculateMantissa Proc near
         push ax
         push bx
         push cx

         xor ah,ah
         mov cx,10

         mov bl,StrDisplay[10]          ; ᬥ饭�� ���襣� ��
                                 ; ��������� ࠧ�冷� =
                                 ; ��� ��������� ���
         cmp StrDisplay[11],0FFh        ; �᫨ ���� �窠, �
         je CMcyc                ; �᫮ ��� - 1, �᫨
         dec bl                  ; �窨 ���

   CMcyc:mov al,StrDisplay[bx]          ; ��� ��� ���������
         dec bl                  ; ���, ��稭�� �
                                 ; ���襩

         cmp al,10               ; �窠?
         jne CMm1                ; ���

         cmp bl,-1               ; �ய�� �窨
         je CMend                ; � ���� ��ப�

         jne CMcyc               ; �ய�� �窨
                                 ; � �।��� ��ப�

    CMm1:call MulDDwithDW        ; ����������
         add [di],ax             ; �������
         adc word ptr [di+2],0

         cmp bl,-1               ; ��横�������, �᫨
         jnz CMcyc               ; ��ࠡ�⠭� �� ��
                                 ; ���������� ࠧ���
   CMend:pop cx
         pop bx
         pop ax
         ret
CalculateMantissa EndP

; ����� ���浪� ����⢥����� �᫠;
; ॣ���� di ������ �祩�� �����, �
; ������ �㦭� �������� ���冷�
CalculateOrder Proc near
         push ax
         push bx
         push cx

         xor bh,bh
         mov bl,StrDisplay[10]          ; ᬥ饭�� ���襣� ��
                                 ; ��������� ࠧ�冷� =
                                 ; ��� ��������� ���,
                                 ; �᫨ ���� �窠

         cmp StrDisplay[11],0           ; �窠 ����?
         jne COm1                ; ����, � ���室
         mov [di],bl             ; �᫨ �� �窨 ���, �
         jmp COend               ; ���冷� = �᫮ ���

    COm1:xor cx,cx
         mov al,StrDisplay[bx]
         cmp al,0                ; 楫�� ��� ���?
         jne COm2                ; ����, � ���室

         dec bl                  ; �ய�� �窨

  COcyc1:dec bl                  ; ���� ����⥫�-
         dec cx                  ; ���� ���浪�
         mov al,StrDisplay[bx]

         cmp bl,-1               ; �᫨ ��ப� �����
                                 ; �� ����� ���
         je COend                ; ������ 0, � ��室

         cmp al,0
         je COcyc1

         inc cl
         mov [di],cl
         jmp COend

    COm2:dec bl                  ; ����
         inc cx                  ; ������⥫쭮��
         mov al,StrDisplay[bx]          ; ���浪�
         cmp al,10
         jne COm2
         mov [di],cl

   COend:pop cx
         pop bx
         pop ax
         ret
CalculateOrder EndP

; �८�ࠧ������ ��ப� �����/�뢮��
; � ����⢥���� �᫮; ��ࠬ����:
; � ॣ���� di - ᬥ饭�� �᫠
ConvertStringToFloat Proc near
         call FloatClear
         cmp StrDisplay[10],0           ; �᫨ ��ப� ����,
         je CSFend               ; � ����⢥����
                                 ; �᫮ - �㫥���

         inc di                  ; ���᫥���
         call CalculateMantissa  ; �������
         dec di

         call MantNorm           ; �� ��ଠ������

         call CalculateOrder     ; ���� ���浪�

         cmp StrDisplay[9],11           ; �᫨ � ��ப� ����
         jne CSFend              ; ���� "-", �
         call FloatNeg           ; ���饭�� ����� �᫠

  CSFend:ret
ConvertStringToFloat EndP

; �८�ࠧ������ �������; ��ࠬ����:
; ॣ���� si ������ �祩��, �� ���ன
; ���� ���� �������
MantissaConvert Proc near
         push ax
         push cx
         push dx

         mov cx,10
  MCMcyc:mov ax,[si+2]           ; �뤢������ DEC ���
         xor dx,dx               ; ������� �� �����,
         div cx                  ; ��稭�� � ����襩,
         mov [si+2],ax           ; ��⥬ ������� ��
         mov ax,[si]             ; �� 10
         div cx
         mov [si],ax

         call RotateStringRight  ; ᤢ�� ࠧ�冷� ��ப�
         mov StrDisplay[7],dl           ; ���������� ��ப�
         inc StrDisplay[10]

         cmp word ptr [si+2],0   ; 横� ������� ������
         jne MCMcyc              ; �� �� ���, ����
         cmp word ptr [si],0     ; ������ �� �������
         jne MCMcyc              ; {�� ���㫨���}

         pop dx
         pop cx
         pop ax
         ret
MantissaConvert EndP

; �८�ࠧ������ ���浪� {���⠭���� �窨};
; ��ࠬ����: ॣ���� si ������ �祩��, �� ���ன
; ᫥��� ����� ���冷�
OrderConvert Proc near
         push ax
         push bx
         push cx

         mov StrDisplay[11],0FFh        ; ��⠭���� 䫠��
                                 ; ������ �窨

         cmp byte ptr [si],1     ; �業�� ���浪�
         jl OCm1                 ; �᫨ ���冷� < 1
                                 ; {��� 楫�� ���}

         mov bx,7                ; ���⠭���� �窨,
         xor cx,cx               ; �᫨ ���� 楫�� ����
         add cx,[si]
 OCMcyc1:mov al,StrDisplay[bx]          ; 横� ᤢ��� �����
         mov StrDisplay[bx+1],al        ; ࠧ�冷� �����
         dec bx
         loop OCMcyc1
         mov StrDisplay[bx+1],10        ; ������ �� ����
                                 ; ����襣� �� �����
                                 ; ࠧ�冷� �窨
         jmp OCend

    OCm1:mov cx,1                ; ���⠭���� �窨
         sub cl,[si]             ; �᫨ ��� 楫�� ���
         mov StrDisplay[8],0
 OCMcyc2:call RotateStringRight
         mov StrDisplay[8],0
         loop OCMcyc2
         mov StrDisplay[7],10           ; ������ �窨

   OCend:pop cx
         pop bx
         pop ax
         ret
OrderConvert EndP

; �८�ࠧ������ ����⢥����� �᫠
; � ��ப� �����/�뢮��; ��ࠬ����:
; � ॣ���� si - ᬥ饭�� �᫠
ConvertFloatToString Proc near
         push [si+3]             ; ��࠭����
         push [si+1]             ; �������
         push [si]               ; � ���浪�
         push di

         call StrClear           ; ���⪠ ��ப� �뢮��

         cmp word ptr [si+3],0   ; �᫨ ������ �८�-
         jne CFSst               ; ࠧ㥬��� �᫠ = 0,
         cmp word ptr [si+1],0   ; � � ��ப� ����
         je CFSend

   CFSst:inc si                  ; ���室 � ��ࠡ�⪥
                                 ; �������, �� �⮬
         mov StrDisplay[9],12           ; ��⠥���, ��
                                 ; ��� ������⥫쭠

         cmp byte ptr [si+3],7Fh
         jb CFSm1
         mov StrDisplay[9],11           ; �᫨ �� ��� ��-⠪�
         mov di,si               ; ����⥫쭠�, � ��
         dec di                  ; ���� �����, � ��
         call FloatNeg           ; ᤥ���� ������⥫쭮�

   CFSm1:call MantissaConvert    ; �८�ࠧ������
         dec si                  ; �������
         call OrderConvert       ; � ���浪�

   CFSZD:cmp StrDisplay[0],0            ; 㤠����� ��������
         jne CFSPD               ; �㫥� � ���� �������
         call RotateStringRight  ; �������
         dec StrDisplay[10]
         jmp CFSZD

   CFSPD:cmp StrDisplay[0],10           ; �᫨ � ���� ��ப�
         jne CFSend              ; �窠, � �� 㤠�����
         call RotateStringRight  ; � ��� 䫠��
         mov StrDisplay[11],0           ; ������ �窨

  CFSend:pop di
         pop [si]
         pop [si+1]
         pop [si+3]
         ret
ConvertFloatToString EndP