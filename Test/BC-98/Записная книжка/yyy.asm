.386

RomSize    EQU   4096
MaxSize    EQU   32
SizeInd    EQU   6
CentrInd   EQU   3           ; SizeInd div 2
MaxStr     EQU   20

rM_1        EQU   48
rM_2        EQU   49        
rM_3        EQU   50
rM_4        EQU   51        
rM_5        EQU   52        
rMRL        EQU   56

r_Up        EQU   46
r_Dn        EQU   62
r_Lft       EQU   53
r_Rgt       EQU   55

rEntr       EQU   54
rBackS      EQU   60

M_1        EQU   100
M_2        EQU   101       
M_3        EQU   102
M_4        EQU   103       
M_5        EQU   104       
MRL        EQU   105

_Up        EQU   106
_Dn        EQU   107
_Lft       EQU   108
_Rgt       EQU   109

Entr       EQU   110
BackS      EQU   111


IntTable   SEGMENT at 0 use16
IntTable   ENDS

Data       SEGMENT at 0 use16

 string db SizeInd dup (0)
 qr        db 0
 pk        db 0
 ps        db 0
 key       db 0
 result    db 0
 mode      db 0
 modeSt    db 1
 r_l       db 1
 direct    db ?                  ; ���ࠢ����� �� ���᪥ 1 - ����, 255 - �����.   
 num       db ?
 char      db ?
 len       db ?
 helper    dw ?

 st        db MaxSize+1 dup (0)
 st2       db MaxSize+1 dup (0)
           
 arr       db MaxStr*MaxSize dup (?)
           
Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT at 1000 use16
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
InitData   ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

Image:



















    
     db    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ;' '
     db    000h, 008h, 018h, 008h, 008h, 008h, 03eh, 000h ;'1'
     db    000h, 03ch, 042h, 002h, 03ch, 040h, 07eh, 000h ;'2'
     db    000h, 03ch, 042h, 00ch, 002h, 042h, 03ch, 000h ;'3'
     db    000h, 004h, 00ch, 014h, 024h, 07eh, 004h, 000h ;'4'
     db    000h, 07eh, 040h, 07ch, 002h, 042h, 03ch, 000h ;'5'
     db    000h, 03ch, 040h, 07ch, 042h, 042h, 03ch, 000h ;'6'
     db    000h, 07eh, 002h, 004h, 008h, 010h, 010h, 000h ;'7'
     db    000h, 03ch, 042h, 03ch, 042h, 042h, 03ch, 000h ;'8'
     db    000h, 03ch, 042h, 042h, 03eh, 002h, 03ch, 000h ;'9'
     db    000h, 03ch, 046h, 04ah, 052h, 062h, 03ch, 000h ;'0'
     db    000h, 03ch, 042h, 042h, 07eh, 042h, 042h, 000h ;'A'
     db    000h, 07ch, 042h, 07ch, 042h, 042h, 07ch, 000h ;'B'
     db    000h, 03ch, 042h, 040h, 040h, 042h, 03ch, 000h ;'C'
     db    000h, 078h, 044h, 042h, 042h, 044h, 078h, 000h ;'D'
     db    000h, 07eh, 040h, 07ch, 040h, 040h, 07eh, 000h ;'E'
     db    000h, 07eh, 040h, 040h, 07ch, 040h, 040h, 000h ;'F'
     db    000h, 03ch, 042h, 040h, 04eh, 042h, 03ch, 000h ;'G'
     db    000h, 042h, 042h, 07eh, 042h, 042h, 042h, 000h ;'H'
     db    000h, 03eh, 008h, 008h, 008h, 008h, 03eh, 000h ;'I'
     db    000h, 002h, 002h, 002h, 002h, 042h, 03ch, 000h ;'J'
     db    000h, 044h, 048h, 070h, 048h, 044h, 042h, 000h ;'K'
     db    000h, 040h, 040h, 040h, 040h, 040h, 07eh, 000h ;'L'
     db    000h, 042h, 066h, 05ah, 042h, 042h, 042h, 000h ;'M'
     db    000h, 042h, 062h, 052h, 04ah, 046h, 042h, 000h ;'N'
     db    000h, 03ch, 042h, 042h, 042h, 042h, 03ch, 000h ;'O'
     db    000h, 07ch, 042h, 042h, 07ch, 040h, 040h, 000h ;'P'
     db    000h, 03ch, 042h, 042h, 052h, 04ah, 03ch, 000h ;'Q'
     db    000h, 07ch, 042h, 042h, 07ch, 044h, 042h, 000h ;'R'
     db    000h, 03ch, 040h, 03ch, 002h, 042h, 03ch, 000h ;'S'
     db    000h, 07fh, 008h, 008h, 008h, 008h, 008h, 000h ;'T'
     db    000h, 042h, 042h, 042h, 042h, 042h, 03ch, 000h ;'U'
     db    000h, 042h, 042h, 042h, 042h, 024h, 018h, 000h ;'V'
     db    000h, 042h, 042h, 042h, 042h, 05ah, 024h, 000h ;'W'
     db    000h, 042h, 024h, 018h, 018h, 024h, 042h, 000h ;'X'
     db    000h, 041h, 022h, 014h, 008h, 008h, 008h, 000h ;'Y'
     db    000h, 07eh, 004h, 008h, 010h, 020h, 07eh, 000h ;'Z'
     db    000h, 000h, 000h, 000h, 000h, 030h, 030h, 000h ;'.'
     db    000h, 000h, 000h, 000h, 000h, 030h, 030h, 060h ;','
     db    000h, 018h, 018h, 000h, 000h, 018h, 018h, 000h ;':'
     db    000h, 018h, 018h, 000h, 000h, 018h, 018h, 030h ;';'
     db    000h, 000h, 000h, 07eh, 000h, 000h, 000h, 000h ;'-'
     db    000h, 024h, 024h, 000h, 000h, 000h, 000h, 000h ;'"'
     db    000h, 010h, 010h, 010h, 010h, 000h, 010h, 000h ;'!'
     db    000h, 03ch, 042h, 00ch, 010h, 000h, 010h, 000h ;'?'
     db    000h, 03ch, 042h, 042h, 07eh, 042h, 042h, 000h ;'�'
     db    000h, 07ch, 040h, 07ch, 042h, 042h, 07ch, 000h ;'�'
     db    000h, 07ch, 042h, 07ch, 042h, 042h, 07ch, 000h ;'�'
     db    000h, 07eh, 040h, 040h, 040h, 040h, 040h, 000h ;'�'
     db    000h, 01eh, 022h, 022h, 022h, 022h, 07fh, 000h ;'�'
     db    000h, 07eh, 040h, 07ch, 040h, 040h, 07eh, 000h ;'�'
     db    014h, 07eh, 040h, 07ch, 040h, 040h, 07eh, 000h ;'�'
     db    000h, 049h, 049h, 03eh, 049h, 049h, 049h, 000h ;'�'
     db    000h, 03ch, 042h, 00ch, 002h, 042h, 03ch, 000h ;'�'
     db    000h, 042h, 046h, 04ah, 052h, 062h, 042h, 000h ;'�'
     db    018h, 042h, 046h, 04ah, 052h, 062h, 042h, 000h ;'�'
     db    000h, 044h, 048h, 070h, 048h, 044h, 042h, 000h ;'�'
     db    000h, 01eh, 022h, 022h, 022h, 022h, 042h, 000h ;'�'
     db    000h, 042h, 066h, 05ah, 042h, 042h, 042h, 000h ;'�'
     db    000h, 042h, 042h, 07eh, 042h, 042h, 042h, 000h ;'�'
     db    000h, 03ch, 042h, 042h, 042h, 042h, 03ch, 000h ;'�'
     db    000h, 07eh, 042h, 042h, 042h, 042h, 042h, 000h ;'�'
     db    000h, 07ch, 042h, 042h, 07ch, 040h, 040h, 000h ;'�'
     db    000h, 03ch, 042h, 040h, 040h, 042h, 03ch, 000h ;'�'
     db    000h, 07fh, 008h, 008h, 008h, 008h, 008h, 000h ;'�'
     db    000h, 042h, 042h, 042h, 03eh, 002h, 03ch, 000h ;'�'
     db    000h, 03eh, 049h, 049h, 03eh, 008h, 008h, 000h ;'�'
     db    000h, 042h, 024h, 018h, 018h, 024h, 042h, 000h ;'�'
     db    000h, 044h, 044h, 044h, 044h, 044h, 07eh, 002h ;'�'
     db    000h, 042h, 042h, 042h, 03eh, 002h, 002h, 000h ;'�'
     db    000h, 041h, 049h, 049h, 049h, 049h, 07fh, 000h ;'�'
     db    000h, 041h, 049h, 049h, 049h, 049h, 07fh, 001h ;'�'
     db    000h, 060h, 020h, 03ch, 022h, 022h, 03ch, 000h ;'�'
     db    000h, 042h, 042h, 072h, 04ah, 04ah, 072h, 000h ;'�'
     db    000h, 040h, 040h, 07ch, 042h, 042h, 07ch, 000h ;'�'
     db    000h, 03ch, 042h, 01eh, 002h, 042h, 03ch, 000h ;'�'
     db    000h, 04eh, 051h, 071h, 051h, 051h, 04eh, 000h ;'�'
     db    000h, 03eh, 042h, 042h, 03eh, 022h, 042h, 000h ;'�'
                      
TabLet:
           db    45, 46, 68, 49, 50, 66, 48, 67, 54, 55, 56, 57, 58 
           db    59, 60, 61, 77, 62, 63, 64, 65, 52, 47, 74, 73, 53 
           db    75, 72, 70, 71, 41, 51, 69, 76        
      
TabFnc:
           db    255, 106, 255, 100, 101, 102, 103, 104, 108, 110, 109
           db    105, 255, 255, 255, 111, 255, 107, 255      
           
Start:
           ASSUME cs:Code,ds:Data,es:Data
           mov   ax,Data
           mov   ds,ax
           mov   ax,Code
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;����� ࠧ��頥��� ��� �ணࠬ��
           
           mov   qr, 0
           mov   pk, 0
           mov   ps, 0
           mov   r_l, 1
           mov   mode, 1
Begin:     
           mov   string[0], 0
           mov   string[1], 0
           mov   string[2], 0
           mov   string[3], 0
           mov   string[4], 0
           mov   string[5], 0
           
           Call  GetKey
Begin2:           
           Call  Condit
           mov   al, key
           
           cmp   al, M_1
           jnz   b1
           mov   mode, 1
           jmp   Begin3
b1:           
           cmp   al, M_2
           jnz   b2
           mov   mode, 2
           jmp   Begin3
b2:           
           cmp   al, M_3
           jnz   b3
           mov   mode, 3
           jmp   Begin3
b3:           
           cmp   al, M_4
           jnz   b4
           mov   mode, 4
           jmp   Begin3
b4:           
           cmp   al, M_5
           jnz   Begin3
           mov   mode, 5
Begin3:               
           Call  Condit
           cmp   mode, 1
           jnz   b3_1
           jmp   BegM1
b3_1:           
           cmp   mode, 2
           jnz   b3_2
           jmp   BegM2
b3_2:           
           cmp   mode, 3
           jnz   b3_3
           jmp   BegM3
b3_3:           
           cmp   mode, 4
           jnz   b3_4
           jmp   BegM4
b3_4:           
           cmp   mode, 5
           jnz   b3_5
           jmp   BegM5
b3_5:           
           jmp   Begin
           
BegM1:     
                                 ; �������� �������� *����� ������*
           mov   al, qr          ; �᫨ ����� ��� ᢮������ �����
           cmp   al, MaxStr      ;
           jnz   BM1_2
           jmp   Begin           ; �� ������� ०�� *����� ������*
BM1_2:                
           Call  SubPr1          ; �맮� ����ணࠬ�� 1 (���� ������)
           
           Call  OutSP
           cmp   result, 1
           jnz   BM1_1
           jmp   Begin2
BM1_1:                
           jmp   Begin
           
BegM2:     
                                 ; �������� �������� *���������*
           cmp   qr, 0           ; �᫨ ��祣� ��ᬠ�ਢ���,
           jz    BM2_1           ; � ०�� ���塞 �� ���� ��ப�
           jmp   BM2_2           
BM2_1:           
           mov   mode, 1
           jmp   Begin
BM2_2:           
           Call  SubPr2          ; �맮� ����ணࠬ�� 2
           
           Call  OutSP
           cmp   result, 1
           jnz   BM2_2_2
           jmp   Begin2
BM2_2_2:           
           jmp   Begin
           
BegM3:     
                                 ; �������� �������� *������ �� �����*
           cmp   qr, 0           ; �᫨ ��祣� �᪠��
           jz    BM3_1           
           jmp   BM3_2
BM3_1:     
           mov   mode, 1         ; � ����砥� ०�� �����
           jmp   Begin           ; � ���室�� � ����� �����
BM3_2:                
           Call  SubPr3
           Call  OutSP
           cmp   result, 1
           jz    BM3_2_1
           jmp   Begin
BM3_2_1:           
           jmp   Begin2

BegM4:
                                 ; �������� �������� *������ �� �����*
           cmp   qr, 0           ; �᫨ ��祣� �᪠��
           jz    BM4_1           
           jmp   BM4_2
BM4_1:     
           mov   mode, 1         ; � ����砥� ०�� �����
           jmp   Begin           ; � ���室�� � ����� �����
BM4_2:                
           Call  SubPr4
           Call  OutSP
           cmp   result, 1
           jz    BM4_2_1
           jmp   Begin
BM4_2_1:           
           jmp   Begin2

BegM5:     
                                 ; �������� �������� *��������*
           cmp   qr, 0           ; �᫨ ��祣� 㤠����,
           jz    BM5_1           ; � ०�� ���塞 �� ���� ��ப�
           jmp   BM5_2           
BM5_1:           
           mov   mode, 1
           jmp   Begin
BM5_2:           
           Call  SubPr5          ; �맮� ����ணࠬ�� 5
           
           Call  OutSP
           cmp   result, 1
           jnz   BM5_2_2
           jmp   Begin2
BM5_2_2:           
           jmp   Begin


SubPr1     proc
                                 ; �������� �������� *����� ������*
           Call  InpStr          ; �����।�⢥��� ���� ��ப�
           
           Call  OutSP           ; �᫨ ���� ��� - ��室��
           cmp   result, 1
           jz    SPr1_End
           
           Call  InMem
Spr1_End:           
           ret
           
SubPr1     endp
           
           
SubPr2     proc
                                 ; �������� �������� *���������*           
           mov   dh, 0           ; ����� ��ப� �� �뢮�
           Push  dx
SPr2_2:      
           pop   bx
           push  dx
           
           Call  Brouse          ; ��ᬮ�� ��ப�
           
           Call  OutSP           ; �᫨ ���� ��� - ��室��
           cmp   result, 1
           jz    SPr2_End
           
           pop   dx
           push  dx
           
           mov   al, key         ; �롨ࠥ� ���ࠢ����� ��६�饭�� �� ᯨ��
           cmp   al, _Up         ; ���ࠧ㬥������, �� �� ������ �⠯� 
           jnz   SPr2_1          ; �ணࠬ�� � key ����   Up   ����   Down
           dec   dh
           cmp   dh, 255
           jnz   SPr2_2
           mov   dh, qr
           dec   dh
           jmp   SPr2_2
SPr2_1:      
           inc   dh
           cmp   dh, qr
           jnz   SPr2_2
           mov   dh, 0
           jmp   SPr2_2
Spr2_End:  
           nop
           pop   dx         
           ret
           
SubPr2     endp
           
           
SubPr3     proc
                                 ; �������� �������� *������ �� �����*
           Call  InpStr          ; ���� ��ப� (�㪢�)
           mov   bx, offset st   ; ��ࢠ� �㪢� ����񭭮� ��ப� 
           mov   al, [bx]        ; �㤥� �㪢��, �� ���ன �㤥� ��� �롮ઠ
           mov   char, al         ; ��� �⮩ 楫� �㤥� �ᯮ�짮����   char  
           
           Call  IsStrL          ; �஢�ઠ �� ����稥 �㦭�� ��ப
           cmp   result, 1       ; �᫨ ⠪���� ���, �
           jz    SP3_2
SP3_1:     
;      *� � � � �   � � � � � �*
           mov   key, M_1        ; �묨�஢��� ���室 �� *���� ������*
           jmp   SP3_End         ; � ��� �� ��楤���
SP3_2:     
           mov   direct, 1
           mov   Num, 0
SP3_3:     
           Call  MapLett             ; ᮮ⢥����� �� ��ப� �᫮���
           cmp   result, 1
           jnz   SP3_5
           
           mov   dh, num             ; dh - ����� �뢮����� ��ப�
           Call  Brouse
           
           Call  OutSP               ; �᫨ ���� ��� - ��室��
           cmp   result, 1
           jz    SP3_End
           
           Call  SelDir              ; ����� ���ࠢ�����
           mov   direct, al          ; १���� ��楤�� ����� �   al
           
SP3_5:           
           mov   al, direct          ; ����� ��ப�
           add   num, al
           cmp   num, 255
           jnz   SP3_4
           mov   al, qr
           dec   al
           mov   num, al
           jmp   SP3_3
SP3_4:     
           mov   al, qr
           cmp   num, al
           jnz   SP3_3
           mov   num, 0
           jmp   SP3_3
SP3_End:           
           ret   
           
SubPr3     endp
                             
           
SubPr4     proc
                                 ; �������� �������� *������ �� ���������*
           Call  InpStr          ; ���� ��ப� (�ࠣ����)
           
           mov   si, offset st   ; ��ॣ��塞 st � st2
           mov   di, offset st2
           mov   ch, MaxSize
SP4_Z:           
           mov   al, [si]
           mov   [di], al
           inc   si
           inc   di
           dec   ch
           jnz   SP4_Z
           
           Call  IsStrF          ; �஢�ઠ �� ����稥 �㦭�� ��ப
           cmp   result, 1       ; �᫨ ⠪���� ���, �
           jz    SP4_2
SP4_1:     
;      *� � � � �   � � � � � �*
           mov   key, M_1        ; �묨�஢��� ���室 �� *���� ������*
           jmp   SP4_End         ; � ��� �� ��楤���
SP4_2:     
           mov   direct, 1
           mov   Num, 0
SP4_3:     
           Call  MapFrag             ; ᮮ⢥����� �� ��ப� �᫮���
           cmp   result, 1
           jnz   SP4_5
           
           mov   dh, num             ; dh - ����� �뢮����� ��ப�
           Call  Brouse
           
           Call  OutSP               ; �᫨ ���� ��� - ��室��
           cmp   result, 1
           jz    SP4_End
           
           Call  SelDir              ; ����� ���ࠢ�����
           mov   direct, al          ; १���� ��楤�� ����� �   al
           
SP4_5:           
           mov   al, direct          ; ����� ��ப�
           add   num, al
           cmp   num, 255
           jnz   SP4_4
           mov   al, qr
           dec   al
           mov   num, al
           jmp   SP4_3
SP4_4:     
           mov   al, qr
           cmp   num, al
           jnz   SP4_3
           mov   num, 0
           jmp   SP4_3
SP4_End:           
           ret   
           
SubPr4     endp
           
           
           
SubPr5     proc
                                 ; �������� �������� *���������*           
           mov   dh, 0           ; ����� ��ப� �� �뢮�
           Push  dx
SPr5_2:      
           pop   bx
           push  dx
           
           cmp   qr, 0           ; �᫨ ����ᥩ ����� ���
           jnz   SPr5_6          
           mov   key, M_1        ; � �묨�஢��� ���室 �� *���� ������*
           jmp   SPr5_End        ; � �뢠������ �� ��楤���
SPr5_6:           
           pop   dx
           push  dx
           Call  _Brouse         ; ��ᬮ�� ��ப�
           
           Call  OutSP           ; �᫨ ���� ��� - ��室��
           cmp   result, 1
           jz    SPr5_End
SPr5_5:     
           cmp   key, BackS      ; �� ����� �� ������ 㤠�����
           jnz   SPr5_4          ; �᫨ ���, � �����
           pop   dx
           push  dx
           Call  DelStr          ; ���� 㤠�塞 ⥪���� ��ப�
           pop   dx
           push  dx
           jmp   SPr5_3          ; ���࠭��� ���-�, �᫨ ��� �뫠 ��᫥����
SPr5_4:           
           pop   dx
           push  dx
           
           mov   al, key         ; �롨ࠥ� ���ࠢ����� ��६�饭�� �� ᯨ��
           cmp   al, _Up         ; ���ࠧ㬥������, �� �� ������ �⠯� 
           jnz   SPr5_1          ; �ணࠬ�� � key ����   Up   ����   Down
           dec   dh
           cmp   dh, 255
           jnz   SPr5_2           
           mov   dh, qr
           dec   dh
           jmp   SPr5_2
SPr5_1:      
           inc   dh
SPr5_3:           
           cmp   dh, qr
           jnz   SPr5_2
           mov   dh, 0
           jmp   SPr5_2
Spr5_End:  
           nop
           pop   dx         
           ret
           
SubPr5     endp

           

DelStr     proc
                                     ; �������� ������ � ������� dh
                                     
           mov   al, dh
           inc   al
           cmp   al, qr
           jz    DelS2
                                     
           mov   al, dh              ; di = dh*MaxSize + addr_arr
           mov   bl, MaxSize
           mul   bl
           mov   di, offset arr
           add   ax, di                                     
           mov   di, ax
           
           mov   si, MaxSize         ; si = di + MaxSize
           add   ax, si
           mov   si, ax
           
           mov   al, qr              ; Top = addr_arr + qr*MaxSize
           mov   bl, MaxSize
           mul   bl
           mov   bx, offset arr
           add   ax, bx
           mov   bx, ax
DelS1:     
           mov   al, [si]            ; [di] = [si]
           mov   [di], al

           inc   di
           inc   si
           
           cmp   bx, si              ; �᫨ 䨭��
           jnz   DelS1               ; � ���
DelS2:           
           dec   qr                  ; - ���稪 ������⢠ ��ப
           
DelStr     endp
           
           
SelDir     proc
                                     ; ������� ����������� �����������
                                     ; ��� ������
                                     ; १���� ��楤�� ����� �   al
                                     ; ���ࠧ㬥������, �� �    key
                                     ; 㦥 ���� ��� ����⮩ ������
           cmp   key, _Dn
           jnz   SelDir1
           mov   al, 1
           jmp   SelDir_e
SelDir1:           
           mov   al, 255
           
SelDir_e:  
           ret           
           
SelDir     endp           
           
           
           
IsStrF     proc
                                 ; �������� �� ������� ����� 
                                 ; ��� ������ �� �����
           mov   dl, 0           ; १����
           mov   dh, 0           ; ����� ⥪�饩 ��ப�
IsSF_1:           
           mov   num, dh
           
           push  dx              ; �஢�ઠ �� �
           Call  MapFrag         ; ᮮ⢥����� �� ��ப�    num
           pop   dx              ; ��������� �᫮��� (�㪢�)
           
           cmp   result, 1       ; �᫨ ᮮ⢥����� - dh=1 � ��室
           jz    IsSF_2          
           mov   al, qr          ; �᫨ ��� - �஢�ઠ �� � ��
           cmp   dh, al          ; ��᫥���� �� ��ப� �� ᥩ�� ᬮ�५�
           jz    IsSF_End        ; �᫨ �� - ��室, ����
           inc   dh              ; + ����� ��ப�
           jmp   IsSF_1          ; � ������...
IsSF_2:               
           mov   dh, 1           
IsSF_End:           
           mov   al, dh
           mov   result, al
           ret
           
IsStrF     endp
           
           
MapFrag    proc
                                     ; �������� �� ������������ ���������
                                     ; �������� � st. ��� ����� - � len
                                     ; ����� ������, � ������� ���������� - � num
           mov   si, offset st2       ; � si ���� �ࠣ����
           mov   al, num
           mov   bl, MaxSize
           mul   bl
           mov   bx, offset arr
           add   ax, bx
           mov   di, ax              ; � di ��� �ࠢ�-��� ��ப�
           
           mov   dh, 0
           mov   dl, 0
MF1:           
           mov   ch, dh
MF2:           
           mov   al, dl              ; fr[dl] = st[ch]
           mov   ah, 0               ; fr[dl]
           mov   bx, si
           add   ax, bx
           mov   bx, ax
           mov   cl, [bx]
           
           mov   al, ch              ; st[ch]
           mov   ah, 0
           mov   bx, di
           add   ax, bx
           mov   bx, ax
           mov   al, [bx]
           
           cmp   al, cl
           
           jnz   MF3
           
           inc   ch
           inc   dl
           
           mov   al, dl              ; dl = len
           cmp   len, al
           
           jnz   MF2
           
           mov   result, 1
           jmp   MF_End
MF3:           
           inc   dh
           mov   dl, 0
           
           mov   al, MaxSize
           sub   al, len
           cmp   al, dh
           
           jnc   MF1
           mov   result, 0
MF_End:           
           ret
                      
MapFrag    endp
           
           
IsStrL     proc
                                 ; �������� �� ������� ����� 
                                 ; ��� ������ �� �����
           mov   dl, 0           ; १����
           mov   dh, 0           ; ����� ⥪�饩 ��ப�
IsSL_1:           
           mov   num, dh
           
           push  dx              ; �஢�ઠ �� �
           Call  MapLett         ; ᮮ⢥����� �� ��ப�    num
           pop   dx              ; ��������� �᫮��� (�㪢�)
           
           cmp   result, 1       ; �᫨ ᮮ⢥����� - dh=1 � ��室
           jz    IsSL_2          
           mov   al, qr          ; �᫨ ��� - �஢�ઠ �� � ��
           cmp   dh, al          ; ��᫥���� �� ��ப� �� ᥩ�� ᬮ�५�
           jz    IsSL_End        ; �᫨ �� - ��室, ����
           inc   dh              ; + ����� ��ப�
           jmp   IsSL_1          ; � ������...
IsSL_2:               
           mov   dh, 1           
IsSL_End:           
           mov   al, dh
           mov   result, al
           ret
           
IsStrL     endp
           
           
MapLett    proc
                                 ; ���������� �� ������ � ������
                                 ; ����� (char) ��� ���᪠ �� �㪢�
                                 ; ����� ��ப� � ���ᨢ�    num
           mov   al, MaxSize
           mov   bl, num
           mul   bl
           mov   bx, offset arr
           add   ax, bx
           mov   bx, ax
           mov   al, [bx]

           mov   result, 0
           cmp   char, al
           jnz   MapL_End
           mov   result, 1
MapL_End:           
           ret
             
MapLett    endp           
           
           
OutSP      proc
                                 ; �������� �� ���� ������� ������
                                 ; �������� � ������ ���������
                                 ; ���� ������ - resuilt = 1
                                 ; ����� - 0
           mov   ah, 0
           mov   al, key
           cmp   al, M_5+1
           jnc   OSP_End
           cmp   al, M_1
           jc    OSP_End
           mov   ah, 1
OSP_End:   
           mov   result, ah
           ret                      
           
OutSP      endp
           
           
Brouse     proc
                                 ; �������� ������ � ������� dh

           mov   ps, 0
           
                                     ; st = arr[dh]
           mov   al, dh              ; ����塞 ���� (dh)
           mov   bl, MaxSize
           mul   bl
           mov   bx, ax
           mov   ax, offset arr
           add   ax, bx
           
           mov   si, ax
           mov   di, offset st
           
           mov   ch, MaxSize         ; �����।�⢥��� ����뫪�
Brou1:                  
           mov   al, [si]
           mov   [di], al
           
           inc   si
           inc   di
           dec   ch
           jnz   Brou1
Brou2:           
           Call  S_to_S              ; ��ॣ���� 6-� ᨬ����� � string
           Call  Pr_Str               ; �⮡ࠦ���� string'�
           Call  GetKey              ; ���� �����
           
           Call  OutSP               ; �᫨ ������ ������ ���
           mov   al, result          ; ���
           cmp   al, 1
           jz    Brou_End            
           
           mov   al, key             ; �᫨ ������ ������ ����� ��� ����
           cmp   al, _Up             ; ⮦� ���
           jz    Brou_End
           cmp   al, _Dn
           jz    Brou_End
           
           cmp   al, _Rgt            ; �᫨ ����� ������ ������    
           jz    Brou_Rgt            
           cmp   al, _Lft
           jz    Brou_Lft
           Jmp   Brou2
Brou_Lft:  
           cmp   ps,0                ; �஢���� �� ������
           jz    Brou2               ; �᫨ ��� ��
           dec   ps                  ; - ᤢ����� �����
           jmp   Brou2
Brou_Rgt:                            ; �஢���� ps �� ���ᨬ��쭮� ���祭��
           mov   al, MaxSize         ; �᫨ ��� �� - 
           sub   al, SizeInd
           cmp   al, ps
           jz    Brou2
           inc   ps                  ; - ���६���஢���, �.�. 
           jmp   Brou2               ; ᤢ����� ��ࠢ�
Brou_End:  
           ret           
           
Brouse     endp



_Brouse     proc
                                 ; �������� ������ � ������� dh
           mov   ps, 0
                                     ; st = arr[dh]
           mov   al, dh              ; ����塞 ���� (dh)
           mov   bl, MaxSize
           mul   bl
           mov   bx, ax
           mov   ax, offset arr
           add   ax, bx
           
           mov   si, ax
           mov   di, offset st
           
           mov   ch, MaxSize         ; �����।�⢥��� ����뫪�
_Brou1:                  
           mov   al, [si]
           mov   [di], al
           
           inc   si
           inc   di
           dec   ch
           jnz   _Brou1
_Brou2:           
           Call  S_to_S              ; ��ॣ���� 6-� ᨬ����� � string
           Call  Pr_Str              ; �⮡ࠦ���� string'�
           Call  GetKey              ; ���� �����
           
           Call  OutSP               ; �᫨ ������ ������ ���
           mov   al, result          ; ���
           cmp   al, 1
           jz    _Brou_End            
           
           cmp   key, BackS
           jz    _Brou_End
           
           mov   al, key             ; �᫨ ������ ������ ����� ��� ����
           cmp   al, _Up             ; ⮦� ���
           jz    _Brou_End
           cmp   al, _Dn
           jz    _Brou_End
           
           cmp   al, _Rgt            ; �᫨ ����� ������ ������    
           jz    _Brou_Rgt            
           cmp   al, _Lft
           jz    _Brou_Lft
           Jmp   _Brou2
_Brou_Lft:  
           cmp   ps,0                ; �஢���� �� ������
           jz    _Brou2              ; �᫨ ��� ��
           dec   ps                  ; - ᤢ����� �����
           jmp   _Brou2
_Brou_Rgt:                           ; �஢���� ps �� ���ᨬ��쭮� ���祭��
           mov   al, MaxSize         ; �᫨ ��� �� - 
           sub   al, SizeInd
           cmp   al, ps
           jz    _Brou2
           inc   ps                  ; - ���६���஢���, �.�. 
           jmp   _Brou2              ; ᤢ����� ��ࠢ�
_Brou_End:  
           ret           
           
_Brouse     endp



           
Condit     proc
                                 ; ����������� ��������� �����������
                                 ; ���������� ���������� ����������
           mov   bl, 0
           mov   ch, mode
           mov   al, 128
Cond1:           
           rol   al, 1
           dec   ch
           jnz   Cond1
           mov   dh, al
           
           mov   al, r_l
           cmp   al, 1
           jnz   Cond2
           mov   dl, 32
           jmp   Cond3
Cond2:           
           mov   dl, 64
Cond3:     
           mov   al, dh
           add   al, dl
           mov   modeSt, al
           out   20h, al
           
           ret
                      
Condit     endp


Pr_Str     proc          
                                      ;���������� ������
           mov   bx, offset string    ; ���� ��ࢮ�� ᨬ����
           mov   ch, 6                ; ���稪 ᨬ�����
           mov   dh, 1                ; ���� ��⨢���樨 ���������
p_s1:           
           push  cx
           push  bx
           mov   al, dh              ; ��⨢����㥬 �㦭�� ���������
           out   2, al               
                                     ; ���� ���� �㦭��� ᨬ����
           mov   al, [bx]            ; ������ ����� ᨬ����
           mov   bl, 8               ; 㬭����� �� 8
           mul   bl
           mov   bx, ax              ; ᫮���� � ���ᮬ �㫥���� ᨬ����
           mov   ax, offset Image    
           add   ax, bx 
           mov   bx, ax             
                                     ; �⮡ࠧ��� ᨬ���
           mov   cl, 8               ; ���稪 ��ப
           mov   dl, 1               ; ���� ��⨢���樨 ��ப
p_s2:                        
           mov   al, dl              ; ��⨢����� �㦭�� ��ப�
           out   0, al
                                 
           mov   al, es:[bx]         ; �⮡ࠦ���� �㦭��� �ࠣ���� ᨬ����
           out   1, al
           mov   al, 0
           out   1, al
                      
           rol   dl, 1               ; ���⪠ ���� ��⨢���樨 ��ப�
           inc   bx                  ; + ���� ����ࠦ���� ᨬ����
           dec   cl                  ; - ���稪� ��ப
           jnz   p_s2                ; ���室
                      
           pop   bx
           pop   cx
           rol   dh, 1               ; ᬥ饭�� ���� ��⨢���樨 ���������
           inc   bx                  ; ᫥���騩 ᨬ���
           dec   ch                  ; - ���稪� ᨬ�����
           jnz   p_s1

           ret
Pr_Str     endp
           

Pr_Str_C   proc          
                                      ;���������� ������ � ��������
           mov   ah, pk               ; � ah ����㦠�� ������ �����
           mov   al, ps               ; � al - ������ ��ப�
           sub   ah, al               ; ������ ����� � ��ப�
           mov   al, 6                ; 6 - ah
           sub   al, ah               ; ��� 㤮��⢠ �ࠢ����� (al)

           mov   bx, offset string    ; ���� ��ࢮ�� ᨬ����
           mov   ch, 6                ; ���稪 ᨬ�����
           mov   dh, 1                ; ���� ��⨢���樨 ���������
p_s_c1:           
           push  cx
           push  bx
           push  ax
           
           pop   ax
           push  ax
           
           cmp   ch, al              ; �᫨ ���� �뢮� ᨬ���� � ����஬
           jnz   p_s_c3
           call  Pr_C                ; - �믮����� ����ண� ��� �뢮�� � ����஬
           jmp   p_s_c4
p_s_c3:           
           mov   al, dh              ; ��⨢����㥬 �㦭�� ���������
           out   2, al               
                                     ; ���� ���� �㦭��� ᨬ����
           mov   al, [bx]            ; ������ ����� ᨬ����
           mov   bl, 8               ; 㬭����� �� 8
           mul   bl
           mov   bx, ax              ; ᫮���� � ���ᮬ �㫥���� ᨬ����
           mov   ax, offset Image    
           add   ax, bx 
           mov   bx, ax             
                                     ; �⮡ࠧ��� ᨬ���
           mov   cl, 8               ; ���稪 ��ப
           mov   dl, 1               ; ���� ��⨢���樨 ��ப
p_s_c2:                        
           mov   al, dl              ; ��⨢����� �㦭�� ��ப�
           out   0, al
                                 
           mov   al, es:[bx]         ; �⮡ࠦ���� �㦭��� �ࠣ���� ᨬ����
           out   1, al
           mov   al, 0
           out   1, al
                      
           rol   dl, 1               ; ���⪠ ���� ��⨢���樨 ��ப�
           inc   bx                  ; + ���� ����ࠦ���� ᨬ����
           dec   cl                  ; - ���稪� ��ப
           jnz   p_s_c2              ; ���室
p_s_c4:                      
           pop   ax
           pop   bx
           pop   cx
           rol   dh, 1               ; ᬥ饭�� ���� ��⨢���樨 ���������
           inc   bx                  ; ᫥���騩 ᨬ���
           dec   ch                  ; - ���稪� ᨬ�����
           jnz   p_s_c1

           ret
Pr_Str_C   endp

Pr_C       proc
                                     ; ���������� ������ � ��������
           mov   al, dh              ; ��⨢����㥬 �㦭�� ���������
           out   2, al               
                                     ; ���� ���� �㦭��� ᨬ����
;           mov   bx, offset string
           mov   al, [bx]            ; ������ ����� ᨬ����
           mov   bl, 8               ; 㬭����� �� 8
           mul   bl
           mov   bx, ax              ; ᫮���� � ���ᮬ �㫥���� ᨬ����
           mov   ax, offset Image    
           add   ax, bx 
           mov   bx, ax             
                                     ; �⮡ࠧ��� ᨬ���
           mov   cl, 7               ; ���稪 ��ப
           mov   dl, 1               ; ���� ��⨢���樨 ��ப
p_c2:                        
           mov   al, dl              ; ��⨢����� �㦭�� ��ப�
           out   0, al
                                 
           mov   al, es:[bx]         ; �⮡ࠦ���� �㦭��� �ࠣ���� ᨬ����
           out   1, al
           mov   al, 0
           out   1, al
                      
           rol   dl, 1               ; ���⪠ ���� ��⨢���樨 ��ப�
           inc   bx                  ; + ���� ����ࠦ���� ᨬ����
           dec   cl                  ; - ���稪� ��ப
           jnz   p_c2                ; ���室

           mov   al, dl              ; ��⨢����� �㦭�� ��ப�
           out   0, al

           mov   al, 255             ; �⮡ࠦ���� �����
           out   1, al
           mov   al, 0
           out   1, al

           ret

Pr_C       endp
           
           
           
GetKey     proc
                             ; ������ ���������� (��������!!!)
           mov   key, 255    ; �� 㬮�砭�� ��� ���祭�� - 255

           mov   dh, 1       ; ���� ��⨢���樨 �冷� ����������
           mov   ch, 8       ; ����稪 �冷�
Gk1:           
           mov   al, dh      ; ��⨢����� �鸞
           out   10h, al     ; 
           in    al, 10h     ; �⥭�� �⮫�殢
           
           cmp   al, 0       ; �᫨ �� ����
           jnz   Gk2         ; ��室 �� 横��
           
           rol   dh, 1       ; ���饭�� ���� ��⨢���樨 �冷�
           dec   ch          ; ���६��� ���稪�
           cmp   ch, 0       ; �᫨ �� �����
           jnz   Gk1         ; �த������ 横�
           jmp   Gk4         ; ���� - ��� �� ��楤���
Gk2:       
           mov   cl, 255     ; ���稪 ��� ��।������ �⮫��
Gk3:           
           inc   cl          ; ���६��� ���稪�
           shl   al, 1       ; ����稢��� ���ﭨ� �⮫�殢
           jnz   Gk3         ; �᫨ al �� ���� - �த������� 横��
           
           mov   al, 8       ; ��ॢ��稢��� ch ��� 㤮��⢠ ���
           sub   al, ch      ; ����, 7 - ch
           mov   bl, 8       ; �������� �� 8
           mul   bl          ;
           add   al, cl      ; �ਡ���塞 cl. � al ����� ������.
               
           mov   key, al     ; � �� ����稫��� �����뢠�� � key
           
Gk4:       
           cmp   key, 45     ; �८�ࠧ������ ����� �㭪樮������ ������
           jc    Gk6
           cmp   key, 255
           jz    Gk6
           mov   al, key
           sub   al, 45
           lea   bx, TabFnc
           mov   ah, 0
           add   ax, bx
           mov   bx, ax
           mov   al, es:[bx]
           mov   key, al
           jmp   Gk_End
Gk6:           
           cmp   r_l, 1
           jnz   Gk_End
           cmp   key, 11
           jc    Gk_End
           cmp   key, 45         
           jnc   Gk_End
           mov   al, key
           sub   al, 11
           lea   bx, TabLet
           mov   ah, 0
           add   ax, bx
           mov   bx, ax
           mov   al, es:[bx]
           mov   key, al
Gk_End:               
           
           in    al, 10h     ; �ମ��� ���� 㤥ন������ ������
           cmp   al, 0
           jnz   Gk_End

           ret
           
GetKey     endp           



InpStr     proc
                             ; ���� ������ 
                             
           mov   string[0], 0    ; ���⪠ ��������
           mov   string[1], 0
           mov   string[2], 0
           mov   string[3], 0
           mov   string[4], 0
           mov   string[5], 0
                             
                                  ; ���⪠ ��ப�
           mov   ch, MaxSize      ; ���稪 ᨬ�����
           inc   ch               ; (⠪ ����)
           mov   bx, offset st    ; ���� ��ப�
Is1:           
           mov   [bx], 0         ; ���������� ������ �� ����権 �஡�����
           
           inc   bx              ; ������騩 ᨬ���
           dec   ch              ; ���६��� ���稪�
           jnz   Is1             ; �த������, �᫨ �� ����

           mov   ps, 0           ; ���㫥��� ����権 ����� � ��ப�
           mov   pk, 0
Is2:       
           Call  Pr_Str_C        ; �⮡ࠧ��� ���ﭨ� ��������
           
           Call  GetKey          ; ���� �����

           Call  OutSP           ; �᫨ ������ ������ ���
           cmp   result, 1       ; - ���
           jz    Is_End

           mov   al, key         ; 
           

           
           cmp   al, Entr        ; �᫨ ������ Enter - ��室
           jz    Is_End
           
           cmp   al, BackS       ; �᫨ Delete - 㤠���� ᨬ���
           jz    Is_Del
           
           cmp   al, MRL
           jz    Is_Mrl
           
           cmp   al, 255          ; �᫨ ����� �㪢� - ��������
           jz    IS3
           cmp   al, 100
           jc    Is_Char
IS3:           
           jmp   Is2
           
Is_Del:                          ; �맮� ��楤��� 㤠�����
           Call  Delet
           Call  S_to_S
           jmp   Is2
           
Is_Char:                         ; �맮� ��楤��� ���� ᨬ����        
           Call  AddChSt
           Call  S_to_S
           jmp   Is2

Is_Mrl:    
           mov   al, 1
           mov   bl, r_l
           sub   al, bl
           mov   r_l, al
           Call  condit
           jmp   Is2

Is_End:                      
           mov   al, pk          ; ����ᥭ�� ����� ��ப� �
           mov   len, al         ; ��६�����    len
           
           ret
           
InpStr     endp

           


Delet      proc
           
           mov   al, pk          ; �᫨ pk=0 (�. �. ����)  - ��室 
           cmp   al, 0
           jz    D_End
           
           mov   al, pk          ; if pk-ps = CentrInd
           sub   al, ps
           cmp   al, CentrInd   
           jnz   D1
           
           mov   al, ps          ; if ps <> 0
           cmp   al, 0
           jz    D1
           
           dec   ps    
D1:                      
           dec   pk
           
           mov   bl, pk          ; st[pk] = ' '
           mov   bh, 0
           mov   ax, offset st
           add   ax, bx
           mov   bx, ax
           mov   [bx], 0
D_End:
           ret
           
Delet      endp



S_to_S     proc
                                 ; ����������� �� st � string
                                 ; SizeInd ����

           mov   ch, SizeInd     ; ���稪
           mov   bx, offset st    ; ���� of st
           mov   dx, offset string    ; ���� of string
           mov   ah, 0           ; �����稢��� bx �� ps
           mov   al, ps      
           add   ax, bx
           mov   bx, ax          
sts1:           
           mov   al, [bx]        ; ��७�ᨬ ���� �� string � st
           push  bx
           mov   bx, dx
           mov   [bx], al
           pop   bx
           
           inc   bx              ; ������騩 ᨬ���
           inc   dx              ; �������� �祩��
           dec   ch              ; ���६��� ���稪�
           jnz   sts1            ; ���室, �᫨ �����

           ret
                                 
S_to_S     endp



AddChSt    proc
                                 ; �������� ������� � st
           mov   al, MaxSize+1   ; �᫨ pk = MaxSize + 1
           mov   bl, pk          ; �� �뢠�������� �� ����ண�
           cmp   al, bl      
           jz    Acs_End
           
           mov   al, pk          ; �᫨ pk-ps = SizeInd - 1
           mov   bl, ps          ; �...
           sub   al, bl
           mov   bl, SizeInd-1
           cmp   al, bl
           jnz   Acs1
           
           mov   al, ps          ; ... 㢥��稢��� ps �� 1
           inc   al
           mov   ps, al
           
Acs1:                 
           mov   ax, offset st    ; st[pk] = key
           mov   bl, pk
           mov   bh, 0
           add   ax, bx
           mov   bx, ax
           mov   al, key
           mov   [bx], al
           
           mov   al, pk          ; inc(pk)
           inc   al
           mov   pk, al
Acs_End:
           ret

AddChSt    endp




InMem      proc
                                     ; ��������� st � arr 
                                     ; � ��������������� ����
           
           mov   dh, 0

           mov   al, qr              ; �᫨ ����, � ��⠢�� ��� �஢�ન.
           cmp   al, 0
           jz    im3

im4:           
                                     ; st2 = arr[a]
           mov   al, dh              ; ����塞 ���� (�)
           mov   bl, MaxSize
           mul   bl
           mov   bx, ax
           mov   ax, offset arr
           add   ax, bx
           
           mov   si, ax
           mov   di, offset st2
           
           mov   ch, MaxSize         ; �����।�⢥��� ����뫪�
im1:                  
           mov   al, [si]
           mov   [di], al
           
           inc   si
           inc   di
           dec   ch
           jnz   im1
           
           Call  CmpStr                ; if st < st2
           mov   al, result
           cmp   al, 1
           jnz   im2  
           
           Call  StrsUp
           jmp   im3
           
im2:           
           inc   dh                  ; inc a
           
           mov   al, qr
           cmp   al, dh
           jnz   im4
im3:                    
           Call  InsStr
           inc   qr
           
           ret           
InMem      endp



CmpStr     proc
           
           mov   al, 1               ; result = 1
           mov   result, al
           mov   ch, 0               ; z = 0
           
           mov   di, offset st        ; ��⠭���� ���ᮢ
           mov   si, offset st2
cs2:                  
           mov   al, [di]
           mov   bl, [si]
           
           cmp   al, bl              ; if st1[z] < st2[z]
           jc    cs_End
           
           cmp   bl, al              ; if st1[z] > st2[z]
           jnc   cs1
           
           mov   al, 0               ; result = 0
           mov   result, al
           jmp   cs_End
Cs1:           
           inc   di
           inc   si
           inc   ch                  ; inc z
           
           cmp   ch, MaxSize         ; if z = MaxSimb
           jnz   cs2       
Cs_End:           
           ret
           
CmpStr     endp

StrsUp     proc
                                     ; ����������� ����� ��� ������ 
                                     ; ������� � ������� �
                                     
                                     ; a = dh
                                     
           mov   al, qr              ; si = addr_arr + (qr * MaxSimb) - 1
           mov   bl, MaxSize
           mul   bl
           mov   bx, offset arr
           add   ax, bx
           dec   ax
           mov   si, ax
           
           mov   di, MaxSize         ; di = si + MaxSimb
;           mov   ax, si
           add   ax, di
           mov   di, ax

           mov   al, dh              ; bx = addr_arr + (a  * MaxSimb) - 1
           mov   bl, MaxSize
           mul   bl
           mov   bx, offset arr
           add   ax, bx
           dec   ax
           mov   bx, ax
su1:           
           mov   al, [si]            ; [si] = [di]
           mov   [di], al
           
           dec   di
           dec   si
           
           cmp   si, bx              ; �஢�ઠ �� ����砭�� 横��
           jnz   Su1           
           
StrsUp     endp



InsStr     proc
                                     ; �������� ������ � ������� �
                                     ; a = dh
           
           mov   al, dh              ; si = addr_arr + a*MaxSize
           mov   bl, MaxSize
           mul   bl
           mov   bx, offset arr
           add   ax, bx
           mov   si, ax
           
           mov   di, offset st        ; addr_st
           
           mov   ch, 1
i_str1:           
           mov   al, [di]
           mov   [si], al
           
           inc   di
           inc   si
           inc   ch
           
           mov   al, MaxSize+1
           cmp   ch, al
           jnz   i_str1
           
           ret
           
InsStr     endp

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
