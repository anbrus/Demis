           .8086             ; ����� ������権 ��� 86-�� ������
           locals @@         ; ������� ��⪨ ��稭����� � "@@"
           jumps             ; ��⮬���᪮� ��।������ "���쭮��" ���室�� (SHORT/NEAR/FAR)
 

IO_MODE    equ   0000h       ; ���� �������� ०���

C_ROOM1    equ   01h         ; ����� "������ 1"
C_ROOM2    equ   02h         ; ����� "������ 2"
C_ROOM3    equ   04h         ; ����� "������ 3"
C_ROOM4    equ   08h         ; ����� "������ 4"
C_RESERVED equ   10h         ; �� ��.
C_MINIMUM  equ   20h         ; ����� "������"
C_MIDIUM   equ   40h         ; ����� "�।���"
C_MAXIMUM  equ   80h         ; ����� "���ᨬ�"

ADC_START  equ   0002h       ; ���� ���� ����᪠ ��� 
ADC_READY  equ   0002h       ; ���� ���� ��⮢���� ���

ADC_A      equ   01h         ; ��� ����᪠/��⮢���� ��� "������ 1"
ADC_B      equ   02h         ; ��� ����᪠/��⮢���� ��� "������ 2"
ADC_C      equ   04h         ; ��� ����᪠/��⮢���� ��� "������ 3"
ADC_D      equ   08h         ; ��� ����᪠/��⮢���� ��� "������ 4"

IND_A      equ   00A0h       ; ���� ���� �������� "������ 1"/���� ������ ��� "������ 1"
IND_B      equ   00B0h       ; ���� ���� �������� "������ 2"/���� ������ ��� "������ 2"
IND_C      equ   00C0h       ; ���� ���� �������� "������ 3"/���� ������ ��� "������ 3"
IND_D      equ   00D0h       ; ���� ���� �������� "������ 4"/���� ������ ��� "������ 4"

IND_F      equ   00F0h       ; ���� ���� �������� ������ ⥪�饣� ०���

IND_ROOM   equ   0100h       ; ���� ���� �������� ����� �������

IMG_SPACE  equ   00h         ; ����ࠦ���� �஡���
IMG_MINUS  equ   40h         ; ����ࠦ���� �����
IMG_POINT  equ   80h         ; ����ࠦ���� �窨


; ������� ������
Data       segment at 00000h

Room1      dw    ?           ; ��������� � ������ 1
Room2      dw    ?           ; ��������� � ������ 2
Room3      dw    ?           ; ��������� � ������ 3
Room4      dw    ?           ; ��������� � ������ 4

Minimum    dw    ?           ; �������쭠� ⥬������
Midium     dw    ?           ; �।��� ⥬������
Maximum    dw    ?           ; ���ᨬ��쭠� ⥬������

RoomMin    dw    ?           ; ����� ������� � �������쭮� ⥬�����ன
RoomMax    dw    ?           ; ����� ������� � ���ᨬ��쭮� ⥬�����ன

Mode       dw    ?           ; �����

           org   07FEh       ; �࣠������ �⥪� ࠧ��஬ � 2 ��
StackTop   label word
Data       ends


; ������� ����
Code       segment 
           assume cs: Code, ds: Data, es: Data, ss: Data

; ��楤���

; Indicate
; ��楤�� �⮡ࠦ���� �᫠
; DX - ����
; AX - �᫮ (�� -99.9 �� +99.9) 
Indicate   proc
           ; ���樠������
           push  dx
           push  cx
           push  bx
           push  ds
           push  cs
           pop   ds          
           mov   bx, offset ImageMap 
           ; "���᫥���" �����
           mov   cl, IMG_SPACE
           cmp   ax, 0
           jge   @@ind
           neg   ax
           mov   cl, IMG_MINUS          
           ; ��������
@@ind:     push  cx
           ; �뢮� ࠧ�鸞 ��᫥ �����筮� �窨 
           push  dx
           mov   dx, 0
           mov   cx, 10
           div   cx
           mov   cx, ax
           mov   al, dl
           xlat
           pop   dx
           out   dx, al           
           ; �뢮� ����襣� 楫��� ࠧ�鸞 � �窮�           
           inc   dx
           push  dx
           mov   dx, 0
           mov   ax, cx
           mov   cx, 10
           div   cx
           mov   cx, ax
           mov   al, dl
           xlat
           or    al, IMG_POINT
           pop   dx
           out   dx, al
           ; �뢮� ���襣� ࠧ�鸞
           inc   dx
           push  dx
           mov   dx, 0
           mov   ax, cx
           mov   cx, 10
           div   cx
           mov   cx, ax
           mov   al, dl
           cmp   al, 0
           pop   dx
           je    @@nonind
           xlat 
           out   dx, al 
           ; �᫨ ���訩 ࠧ�� "0", �
           ; �뢮� ����� � ����樨 ���襣� ࠧ�鸞
@@nonind:  cmp   al, 0
           jne   @@indsign
           pop   ax
           out   dx, al
           push  IMG_SPACE
           ; �뢮� �����           
@@indsign: pop   ax
           inc   dx
           out   dx, al            
           ; ����⠭������� � ��室
           pop   ds
           pop   bx
           pop   cx
           pop   dx
           ret
Indicate   endp


; TestADC
; ���� ��� � �ਢ������� � ࠬ�� 
; �室:  AL - ��� ���
;        DX - ����
; ��室: AX - �᫮ (�� -10.0 �� +50.0) 
TestADC    proc
           ; �����⮢��
           push  dx
           push  bx
           ; ����� �஭⮬
           mov   bl, al
           mov   ax, 0
           out   ADC_START, al
           mov   al, bl
           out   ADC_START, al
           ; �������� ����砭�� 横��
@@test:    in    al, ADC_READY
           test  al, bl
           jz    @@test   
           ; ���뢠��� ���ﭨ� (0000...FFFF) 
           inc   dx       
           in    al, dx
           mov   ah, al
           dec   dx 
           in    al, dx
           ; �ਢ������ � ࠬ��
           mov   cx, 600
           mul   cx
           mov   cx, 0FFFFh
           div   cx
           sub   ax, 100 
           ; ����⠭������� � ��室
           pop   bx
           pop   dx
           ret
TestADC    endp


; ���� ���稪�� ������
TestRooms  proc
           ; ������ 1
           mov   dx, IND_A 
           mov   ax, ADC_A
           call  TestADC
           mov   Room1, ax
           call  Indicate  
           ; ������ 2
           mov   dx, IND_B
           mov   ax, ADC_B
           call  TestADC
           mov   Room2, ax
           call  Indicate  
           ; ������ 3
           mov   dx, IND_C
           mov   ax, ADC_C
           call  TestADC
           mov   Room3, ax
           call  Indicate  
           ; ������ 4
           mov   dx, IND_D
           mov   ax, ADC_D
           call  TestADC
           mov   Room4, ax
           call  Indicate 
           ret
TestRooms  endp


; ����� �।����, �����㬠 � ���ᨬ㬠
Calculate  proc
           ; ���� �।����
           mov  ax, Room1
           add  ax, Room2
           add  ax, Room3
           add  ax, Room4
           add  ax, 400     
           mov  cx, 10
           mul  cx
           mov  cx, 4
           div  cx
           add  ax, 5
           mov  dx, 0
           mov  cx, 10
           div  cx  
           sub  ax, 100
           mov  Midium, ax
           ; ���� ���ᨬ㬠
           mov  ax, Room1
           mov  RoomMax, 1
           cmp  ax, Room2
           jg   @@n1 
           mov  ax, Room2
           mov  RoomMax, 2     
@@n1:      cmp  ax, Room3
           jg   @@n2
           mov  ax, Room3
           mov  RoomMax, 3
@@n2:      cmp  ax, Room4
           jg   @@n3
           mov  ax, Room4
           mov  RoomMax, 4
@@n3:      mov  Maximum, ax                 
           ; ���� �����㬠 
           mov  ax, Room1
           mov  RoomMin, 1
           cmp  ax, Room2
           jl   @@nn1 
           mov  ax, Room2
           mov  RoomMin, 2     
@@nn1:     cmp  ax, Room3
           jl   @@nn2
           mov  ax, Room3
           mov  RoomMin, 3
@@nn2:     cmp  ax, Room4
           jl   @@nn3
           mov  ax, Room4
           mov  RoomMin, 4
@@nn3:     mov  Minimum, ax         
           ; ��室     
           ret
Calculate  endp


; ���� ०���
GetMode    proc
           in    al, IO_MODE
           cmp   al, 0
           jz    @@show 
           xor   ah, ah
           mov   Mode, ax
@@show:    mov   ax, Mode 
           out   IO_MODE, al
           ret
GetMode    endp


; �⮡ࠦ����
Report     proc
           ; ������ 1 ?
           mov   ax, Room1
           mov   cx, 1 
           cmp   Mode, C_ROOM1
           je    @@showrep
           ; ������ 2 ?
           mov   ax, Room2
           mov   cx, 2
           cmp   Mode, C_ROOM2
           je    @@showrep
           ; ������ 3 ?
           mov   ax, Room3
           mov   cx, 3
           cmp   Mode, C_ROOM3
           je    @@showrep
           ; ������ 4 ?
           mov   ax, Room4
           mov   cx, 4
           cmp   Mode, C_ROOM4
           je    @@showrep
           ; ������ ?
           mov   ax, Minimum
           cmp   Mode, C_MINIMUM
           mov   cx, RoomMin
           je    @@showrep
           ; ���ᨬ� ?
           mov   ax, Maximum
           cmp   Mode, C_MAXIMUM
           mov   cx, RoomMax
           je    @@showrep
           ; �।��� ?
           mov   ax, Midium
           cmp   Mode, C_MIDIUM
           mov   cx, 17
           je    @@showrep           
@@showrep: mov   dx, IND_F
           call  Indicate
           push  ds
           mov   ax, cs
           mov   ds, ax 
           mov   bx, offset ImageMap
           mov   al, cl
           xlat
           mov   dx, IND_ROOM 
           out   dx, al 
           pop   ds
           ret
Report     endp


; �窠 ����
@start:    mov   ax, Data
           mov   ds, ax
           mov   es, ax
           mov   ss, ax
           lea   sp, StackTop
           mov   Mode, C_ROOM1

; ������������
@cicle:    call  TestRooms   ; ���� ���稪��
           call  Calculate   ; ��।������ �।����, �����㬠, ���ᨬ㬠
           call  GetMode     ; ��।������ ०���
           call  Report      ; �⮡ࠦ���� १����
           jmp   @cicle      ; ��横�������

; ���� ᨬ�����
ImageMap   db    03Fh, 00Ch, 076h, 05Eh, 04Dh, 05Bh, 07Bh, 00Eh    
           db    07Fh, 05Fh, 06Fh, 079h, 033h, 07Ch, 073h, 063h, 000h    

           org   0FF0h
           assume cs: nothing
           jmp   Far Ptr @start
Code       ends

           end               ; ����� ����