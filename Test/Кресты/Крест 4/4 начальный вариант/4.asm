.386
RomSize    EQU   4096
KeybPort   EQU   0h
DisplPort1 EQU   1h
DrebMax    EQU   50

Data       SEGMENT use16 AT 100h
KeybImage  db    3 dup(?)
KeybNthng  db    ?	;Keyboard Nothing (��祣� �� �����)
KeybError  db    ?
Summ       dw    ?
LastWrite  db    ?
Data       ENDS

Code       SEGMENT use16
           ASSUME cs:Code,ds:Data,es:Code,ss:Stk
ImageNum   db    3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7Fh,5Fh

Dreb       PROC  NEAR
DrebM1:    mov   bh,DrebMax	;᪮�쪮 ࠧ ����� �㦭� ������ ���� � � �� �᫮ ��⨢ �ॡ����
           mov   ah,al          ;���. ���.���.
DrebM2:    xor   al,ah          ;��⨬ al
           in    al,dx          ;������ � al �, �� � dx (����� ���� KeybPort) 
           jnz   short DrebM1	;���室 �� ����, �᫨ ��᫥����⥫쭮��� ��ࢠ����
           dec   bh 		;��᫥����⥫쭮��� ᮪�頥����
           jnz   short DrebM2
           ret
Dreb       ENDP

KeyRead    PROC  NEAR
           mov   cx,length KeybImage ;���稪 横���
           lea   si,KeybImage        ;���� ��ࠧ� ����������
           mov   bl,11111110b   ;��筥� � 1 �鸞 ������ (3|2|1|0)(��������� ��ﬨ)
KeyReadM1: mov   al,bl          ;�롮� ��ப�
           out   KeybPort,al    ;��⨢��� ��ப�
           in    al,KeybPort    ;���� ��ப�
           mov   dx,KeybPort	;��।��� ����� ���� �१ ॣ���� dx (��� 㭨���ᠫ쭮�� ��⨤ॡ����)
           call  Dreb
           not   al		;�뫮, ᪠���, 11111101, �⠫� 00000010, �.�. ��ன ��
           mov   [si],al        ;������ ��ப�
           inc   si             ;����䨪��� ����
           rol   bl,1		;᫥���騩 �� (横�.ᤢ�� �����)
           loop  KeyReadM1      ;�� ��ப� ��諨?
           RET
KeyRead    ENDP

KeybCntr   PROC  NEAR
           xor   bl,bl
           mov   KeybNthng,bl
           mov   KeybError,bl
           mov   cx,length KeybImage  
           lea   si,KeybImage
KeybCntrM2:mov   al,[si]         ;��ॡ�ࠥ� ��� � ��������
KeybCntrM1:adc   bl,0            ;������ ��⠭�������� ��� (᪫��뢠��)
           shr   al,1            ;������ ��⠭�������� ���
           jnz   KeybCntrM1      ;������ ��⠭�������� ���
           adc   bl,0            ;������ ��⠭�������� ���
           inc   si
           loop  KeybCntrM2
           or    bl,bl
           jnz   short KeybCntrM3 ;��祣� �� �����?
           not   KeybNthng
           mov   LastWrite,cl
           jmp   short KeybCntrM4
KeybCntrM3:shr   bl,1            ;�᫨ ⠬ �뫠 �����窠 - ��᫥ ᤢ��� ��९�룭�� �訡��
           jz    short KeybCntrM4
           not   KeybError
KeybCntrM4:RET
KeybCntr   ENDP

Summa      PROC  NEAR
           xor   ax,ax           
           or    KeybNthng,al    
           jnz   short SummaM3   
           or    KeybError,al    ;�஢�ઠ
           jnz   short SummaM3   ;��
           or    LastWrite,al    ;����室������
           jnz   short SummaM3   ;�㬬�஢���
           lea   si,KeybImage
SummaM1:   inc   ah
           mov   bl,[si]
           inc   si
           or    bl,bl           ;�饬 ���㫥��� ��ப�
           jz    short SummaM1
           dec   ah
           shl   ah,2            ;���訥 2 ��� ����襩 ��ࠤ�
SummaM2:   inc   al
           shr   bl,1
           jnz   short SummaM2
           dec   al
           or    al,ah           ;���ᮧ���� ������� ��ࠤ�
           cmp   al,10           ;����� ������ �� ����� 10-�� �����? (�.�. ���� 9)
           jnb   short SummaM3
           xor   ah,ah
           add   ax,Summ         ;�㬬��㥬
           mov   Summ,ax
           not   LastWrite       ;䫠� � ⮬, �� �� ����ᠫ�, �⮡� 100 ࠧ ����� �� �������
SummaM3:   RET
Summa      ENDP

Out7LED    MACRO Port            
           lea   bx,ImageNum
           div   dl              ;����� �� 10 (Hex->Dec)
           mov   dh,al           ;��࠭塞 楫�� ���� �� �������, ��� ��� �ਣ������
           shr   ax,8            ;���⮪ �� ������� (����� � ah) ��७�ᨬ � al
           add   bx,ax           ;����塞 ���� ��ࠧ� �㦭�� ����
           mov   al,es:[bx]
           out   Port,al         ;�뢮� � ���� ��ࠧ ����祭��� ����
           mov   al,dh           ;�����頥� 楫�� ���� �� �������
           ENDM

OutLED     PROC  NEAR
           mov   ax,Summ
           mov   dl,10 
           Out7LED 4             ;�㤥� ������ �� 10 (Hex->Dec)
           Out7LED 3             ;��뢠�� ���ப������ ��� 3 ����
           Out7LED 2             ;                      ��� 2 ����
           Out7LED 1             ;                      ��� 1 ����
           RET
OutLED     ENDP

Start:     mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           xor   ax,ax
           mov   Summ,ax
           mov   LastWrite,al
InfLoop:   call  KeyRead         ;�⠥� ����������
           call  KeybCntr        ;������ ���४⭮�� ����⨩ ������
           call  Summa           ;�㬬�
           call  OutLED          ;�뢮� �㬬�
           jmp   short InfLoop

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS

Stk        SEGMENT use16 STACK
           org 10h 
           dw  5 dup(?)
StkTop     LABEL
Stk        ENDS

END
