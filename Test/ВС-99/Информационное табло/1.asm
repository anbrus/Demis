RomSize    EQU   4096
NMax       EQU   50          ; ����⠭� ���������� �ॡ����
KbdPort    EQU   99h           ; ���� ���⮢
;--------------������� �⥪�--------------------------------------------------------
Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS
;--------------������� ������-------------------------------------------------------
Data       SEGMENT AT 0
           KbdImage          DB    8 DUP(?)    ; �����筮-��⭠����. ��� ��।�. ������. ����(� �����)
           EmpKbd            DB    ?        ; ����� �����
           KbdErr            DB    ?        ; �訡�� �����
           dex               DW    ?        
           Index             DW    ?        ; ������ �-�� Memory       
           Index1            DW    ?
           IndexIndic        DW    ?
           CheckIndic        DW    ?
           Memory            DW    14 Dup(?)   
           GoTime            DW    ?            ;����� ���樠����樨
           GoTime1           Dw    ?
           TimeMassiv        DW    10 Dup(?)
           Schet             DW    4  Dup(?)
           SchetMass         DB    200 Dup(?)
           HourDelay         DW    ?
           MinuteDelay       DW    ?
           up                DW    ?    ; ���孨� ����
           down              DW    ?    ; ������ ����
           left              DW    ?    ; ���� ����   
Data       ENDS
;---------------������� ����---------------------------------------------------------
Code       SEGMENT
           ASSUME cs:Code,ds:Data,ss:Stk
;------------------------------------------------------------------------------------
Image      db    0000000b,1111100b,0010010b,0010001b,0010001b,0010010b,1111100b,0000000b  ;"�"0
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,0110000b,0000000b  ;"�"1
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,0110110b,0000000b  ;"�"2
           db    0000000b,1111111b,0000001b,0000001b,0000001b,0000001b,0000011b,0000000b  ;"�"3
           db    0000000b,1100000b,0111100b,0100010b,0100001b,0111111b,1100000b,0000000b  ;"�"4
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,1001001b,0000000b  ;"�"5
           db    0000000b,1111111b,0001000b,1111111b,0001000b,1111111b,0000000b,0000000b  ;"�"6
           db    0000000b,0100010b,1000001b,1000001b,1001001b,1001001b,0110110b,0000000b  ;"�"7
           db    0000000b,1111111b,0100000b,0010000b,0001000b,0000100b,1111111b,0000000b  ;"�"8
           db    0000000b,1111111b,0100000b,0010001b,0001001b,0000100b,1111111b,0000000b  ;"�"9
           db    0000000b,1111111b,0001000b,0001000b,0010100b,0100010b,1000001b,0000000b  ;"K"10
           db    0000000b,1111100b,0000010b,0000001b,0000001b,0000010b,1111100b,0000000b  ;"�"11
           db    0000000b,1111111b,0000010b,0000100b,0000100b,0000010b,1111111b,0000000b  ;"�"12
           db    0000000b,1111111b,0001000b,0001000b,0001000b,0001000b,1111111b,0000000b  ;"�"13
           db    0000000b,0111110b,1000001b,1000001b,1000001b,1000001b,0111110b,0000000b  ;"�"14
           db    0000000b,1111111b,0000001b,0000001b,0000001b,0000001b,1111111b,0000000b  ;"�"15
           db    0000000b,1111111b,0001001b,0001001b,0001001b,0001001b,0000110b,0000000b  ;"�"16
           db    0000000b,0111110b,1000001b,1000001b,1000001b,1000001b,0100010b,0000000b  ;"�"17
           db    0000000b,0000001b,0000001b,1111111b,0000001b,0000001b,0000000b,0000000b  ;"�"18
           db    0000000b,1001111b,1001000b,1001000b,1001000b,1001000b,1111111b,0000000b  ;"�"19
           db    0000000b,0001111b,0001001b,1111111b,0001001b,0001111b,0000000b,0000000b  ;"�"20
           db    0000000b,1100011b,0010100b,0001000b,0001000b,0010100b,1100011b,0000000b  ;"�"21
           db    0000000b,0111111b,0100000b,0100000b,0100000b,0111111b,1000000b,0000000b  ;"�"22
           db    0000000b,0001111b,0001000b,0001000b,0001000b,0001000b,1111111b,0000000b  ;"�"23
           db    0000000b,1111111b,1000000b,1111111b,1000000b,1111111b,0000000b,0000000b  ;"�"24
           db    0000000b,1111111b,1000000b,1111111b,1000000b,1111111b,1000000b,0000000b  ;"�"25
           db    0000000b,0000001b,1111111b,1001000b,1001000b,1001000b,0110000b,0000000b  ;"�"26
           db    0000000b,1111111b,1001000b,1001000b,1001000b,0110000b,1111111b,0000000b  ;"�"27
           db    0000000b,1111111b,1001000b,1001000b,1001000b,0110000b,0000000b,0000000b  ;"�"28
           db    0000000b,1000001b,1000001b,1000001b,1001001b,1001001b,0111110b,0000000b  ;"�"29
           db    0000000b,1111111b,0001000b,0111110b,1000001b,1000001b,0111110b,0000000b  ;"�"30
           db    0000000b,1000110b,0101001b,0011001b,0001001b,0001001b,1111111b,0000000b  ;"�"31
           db    0000000b,0000000b,0000000b,0000000b,0000000b,0000000b,0000000b,0000000b  ;"_"32
           db    0000000b,0000100b,0000010b,0000001b,0000100b,0000010b,0000001b,0000000b  ;" " "33
           db    0000000b,0000000b,0000000b,0110110b,0110110b,0000000b,0000000b,0000000b  ;":"34
           db    0000000b,0000000b,0000000b,1101111b,1101111b,0000000b,0000000b,0000000b  ;"!"35
           db    0000000b,0000000b,0000000b,0000000b,1000001b,0111110b,0000000b,0000000b  ;")"36
           db    0000000b,0000000b,0000000b,0000000b,0111110b,1000001b,0000000b,0000000b  ;"("37
           db    0000000b,0000000b,0000000b,1100000b,1100000b,0000000b,0000000b,0000000b  ;"."38
           db    0000000b,0001000b,0001000b,0001000b,0001000b,0001000b,0001000b,0000000b  ;"-"39
           db    0000000b,0001000b,0101010b,0011100b,1111111b,0011100b,0101010b,0001000b  ;"*"40
           db    0000000b,0000000b,1000001b,0100010b,0010100b,0001000b,0000000b,0000000b  ;">"41
           db    0000000b,0000000b,0001000b,0010100b,0100010b,1000001b,0000000b,0000000b  ;"<"42
           db    0000000b,0000000b,1000000b,0110110b,0010110b,0000000b,0000000b,0000000b  ;";"43
           db    0000000b,0000010b,0000001b,1101001b,1101001b,0001001b,0000110b,0000000b  ;"?"44
           db    0000000b,0000001b,0000010b,0000100b,0001000b,0010000b,0100000b,1000000b  ;"\"45
           db    1000000b,0100000b,0010000b,0001000b,0000100b,0000010b,0000001b,0000000b  ;"/"46
           db    0000000b,0000000b,1000000b,0110000b,0010000b,0000000b,0000000b,0000000b  ;";"47
           db    0000000b,0111110b,1010001b,1001001b,1000101b,0111110b,0000000b,0000000b  ;"0"48
           db    0000000b,0000000b,1000100b,1000010b,1111111b,1000000b,0000000b,0000000b  ;"1"49
           db    0000000b,1000010b,1100001b,1010001b,1001001b,1000110b,0000000b,0000000b  ;"2"50
           db    0000000b,0100010b,1000001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"3"51
           db    0000000b,0001100b,0001010b,0001001b,1111111b,0001000b,0000000b,0000000b  ;"4"52
           db    0000000b,1000111b,1000101b,1000101b,1000101b,0111001b,0000000b,0000000b  ;"5"53
           db    0000000b,0111100b,1000110b,1000101b,1000101b,0111000b,0000000b,0000000b  ;"6"54
           db    0000000b,1000001b,0100001b,0010001b,0001001b,0000111b,0000000b,0000000b  ;"7"55
           db    0000000b,0110110b,1001001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"8"56
           db    0000000b,0000110b,1001001b,0101001b,0011001b,0001110b,0000000b,0000000b  ;"9"57
Image1     db    111111b     ;0
           db    1100b       ;1
           db    1110110b    ;2
           db    1011110b    ;3
           db    1001101b    ;4
           db    1011011b    ;5
           db    1111011b    ;6
           db    1110b       ;7
           db    1111111b    ;8
           db    1011111b    ;9           
;-------------���樠������ ��ࠬ��஢-----------------------------------------------------------------           
Init       PROC  NEAR
           mov   GoTime,0
           mov   GoTime1,0
           mov   Index,0        
           mov   Index1,0
           mov   IndexIndic,0
           mov   CheckIndic,0
           mov   si,0 
           mov   cx,14 
I:          
           mov   Memory[si],32
           inc   si
           inc   si
           dec   cx
           jcxz  I1
           jmp   I
I1:        
           mov   si,0 
           mov   cx,210
II:          
           mov   SchetMass[si],0
           inc   si
           dec   cx
           cmp   cx,0
           je    I2
           jmp   II
I2:           
           mov   ax,1b           ;��������
           out   098h,ax
           mov   TimeMassiv[0],49
           mov   TimeMassiv[2],48
           mov   TimeMassiv[4],34
           mov   TimeMassiv[6],48
           mov   TimeMassiv[8],48
           mov   TimeMassiv[10],48
           mov   TimeMassiv[12],48
           mov   TimeMassiv[14],34
           mov   TimeMassiv[16],48
           mov   TimeMassiv[18],48
           mov   Schet[0],48
           mov   Schet[2],48
           mov   Schet[4],48
           mov   Schet[6],48
           mov   HourDelay,0
           mov   MinuteDelay,0
           ret
Init       ENDP
;-------------���࠭���� �ॡ����---------------------------------------------------------------
VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
           mov   bh,0        ;���� ����稪� ����७��
VD2:       in    al,dx       ;���� ⥪�饣� ���ﭨ�
           cmp   ah,al       ;����饥 ���ﭨ�=��室����?
           jne   VD1         ;���室, �᫨ ���
           inc   bh          ;���६��� ����稪� ����७��
           cmp   bh,NMax     ;����� �ॡ����?
           jne   VD2         ;���室, �᫨ ���
           mov   al,ah       ;����⠭������� ���⮯�������� ������
           ret
VibrDestr  ENDP           
;--------------���� � ����������----------------------------------------------------------------
KbdInput   PROC  NEAR
           lea   si,KbdImage         ;����㧪� ����,
           mov   cx,LENGTH KbdImage  ;����稪� 横���
           mov   bl,0FEh             ;� ����� ��室��� ��ப�
KI4:       mov   al,bl       ;�롮� ��ப�
           out   KbdPort,al  ;��⨢��� ��ப�
           in    al,KbdPort  ;���� ��ப�
           and   al,11111111b      ;����祭�?
           cmp   al,11111111b
           jz    KI1         ;���室, �᫨ ���
           mov   dx,KbdPort  ;��।�� ��ࠬ���
           call  VibrDestr   ;��襭�� �ॡ����
           mov   [si],al     ;������ ��ப�
KI2:       in    al,KbdPort  ;���� ��ப�
           and   al,11111111b      ;�몫�祭�?
           cmp   al,11111111b
           jnz   KI2         ;���室, �᫨ ���
           call  VibrDestr   ;��襭�� �ॡ����
           jmp   SHORT KI3
KI1:       mov   [si],al     ;������ ��ப�
KI3:       inc   si          ;����䨪��� ����
           rol   bl,1        ;� ����� ��ப�
           loop  KI4         ;�� ��ப�? ���室, �᫨ ���
           ret
KbdInput   ENDP
;-----------����஫� ����� � ����������---------------------------------------------------------
KbdInContr PROC  NEAR
           lea   bx,KbdImage ;����㧪� ����
           mov   cx,8        ;� ����稪� ��ப
           mov   EmpKbd,0    ;���⪠ 䫠���
           mov   KbdErr,0
           mov   dl,0        ;� ������⥫�
KIC2:      mov   al,[bx]     ;�⥭�� ��ப�
           mov   ah,8        ;����㧪� ����稪� ��⮢
KIC1:      shr   al,1        ;�뤥����� ���
           cmc               ;������� ���
           adc   dl,0
           dec   ah          ;�� ���� � ��ப�?
           jnz   KIC1        ;���室, �᫨ ���
           inc   bx          ;����䨪��� ���� ��ப�
           loop  KIC2        ;�� ��ப�? ���室, �᫨ ���
           cmp   dl,0        ;������⥫�=0?
           jz    KIC3        ;���室, �᫨ ��
           cmp   dl,1        ;������⥫�=1?
           jz    KIC4        ;���室, �᫨ ��
           mov   KbdErr,0FFh ;��⠭���� 䫠�� �訡��
           jmp   SHORT KIC4
KIC3:      mov   EmpKbd,0FFh ;��⠭���� 䫠�� ���⮩ ����������
KIC4:      ret
KbdInContr ENDP
;------------�८�ࠧ������ ��।��� ����-----------------------------------------------------
NxtSymBl  PROC  NEAR
           cmp   EmpKbd,0FFh ;����� ���������?
           jz    NSB5        ;���室, �᫨ ��
           cmp   KbdErr,0FFh ;�訡�� ����������?
           jz    NSB5        ;���室, �᫨ ��
           jmp   SHORT NSB6
NSB5:      ret
NSB6:      lea   bx,KbdImage ;����㧪� ����
           mov   dx,0        ;���⪠ ������⥫�� ���� ��ப� � �⮫��
NSB3:      mov   al,[bx]     ;�⥭�� ��ப�
           and   al,11111111b      ;�뤥����� ���� ����������
           cmp   al,11111111b      ;��ப� ��⨢��?
           jnz   NSB2        ;���室, �᫨ ��
           inc   dh          ;���६��� ���� ��ப�
           inc   bx          ;����䨪��� ����
           jmp   SHORT NSB3
NSB2:      shr   al,1        ;�뤥����� ��� ��ப�
           jnc   NSB4        ;��� ��⨢��? ���室, �᫨ ��
           inc   dl          ;���६��� ���� �⮫��
           jmp   SHORT NSB2
NSB4:      mov   cl,3        ;��ନ஢��� ����筮�� ���� ����
           shl   dh,cl
           or    dh,dl
           mov   dl,dh
           xor   dh,dh
           cmp   dx,40       ;������ ����
           jne   Y8
           call  GoGame
           jmp   NSB1        
Y8:        cmp   dx,62       ;������ Next
           jne   Y6
           call  Next
           jmp   NSB1
Y6:        cmp   dx,63       ;������ Previous
           jne   Y7
           call  Previous
           jmp   NSB1
Y7:        cmp   dx,58       ; ������ ����
           jne   Y1
           call  Init
           jmp   NSB1
Y1:        cmp   dx,60       ; ������ <-
           jne   Y3
           call  GameSchet1
           jmp   NSB1
Y3:        cmp   dx,59       ; ������ ->
           jne   Y4
           call  GameSchet2
           jmp   NSB1
Y4:        cmp   dx,61       ; ������ OK
           jne   Y2
           inc   GoTime
           mov   Index,14
           cmp   GoTime,2
           jne    NSB1
           mov   ax,0b           ;��������
           out   098h,ax
           jmp   NSB1
Y2:        cmp   GoTime,0
           jne   Y5
           cmp   Index,12
           ja    Y5 
           mov   si, Index       ;������ ���� �㪢� � Memory
           mov   Memory[si], dx
           inc   si
           inc   si
           mov   Index, si
Y5:        cmp   GoTime,1
           jne   NSB1
           cmp   Index1,12
           ja    NSB1 
           mov   si, Index1       ;������ ���� �㪢� � Memory
           mov   Memory[si+14], dx
           inc   si
           inc   si
           mov   Index1, si
NSB1:      ret
NxtSymBl  ENDP
;------------��ॢ�� ����� ����� ���।-------------------------------------------------------------
Next        PROC  NEAR                
            cmp   GoTime,1
            jbe   Next1 
            mov   ax,CheckIndic
            cmp   IndexIndic,ax
            je    Next1
            inc   IndexIndic
            inc   IndexIndic
            inc   IndexIndic
            inc   IndexIndic
            inc   IndexIndic
Next1:      ret
Next        ENDP
;------------��砫� ����-----------------------------------------------------------------
GoGame      PROC  NEAR                
            cmp   GoTime,1
            jbe   GoGame1
            mov   GoTime1,2
GoGame1:    ret
GoGame      ENDP
;------------��ॢ�� ����� ����� �����-------------------------------------------------------------
Previous        PROC  NEAR                
            cmp   GoTime,1
            jbe   Previous1
            cmp   IndexIndic,1
            jb    Previous1
            dec   IndexIndic
            dec   IndexIndic
            dec   IndexIndic
            dec   IndexIndic
            dec   IndexIndic
Previous1:  ret
Previous    ENDP
;------------��������� ��� 1-------------------------------------------------------------
GameSchet1        PROC  NEAR  
             cmp   GoTime1,1
             jbe   GameSch12              
             cmp   Schet[2],57
             jne   GameSch1
             inc   Schet[0]
             mov   Schet[2],47   
GameSch1:    inc   Schet[2]
             mov   ax,CheckIndic
             cmp   IndexIndic,ax
             je    GameSch13
             mov   IndexIndic,ax
GameSch13:   inc   IndexIndic
             inc   IndexIndic
             inc   IndexIndic
             inc   IndexIndic
             inc   IndexIndic
             mov   ax,IndexIndic
             mov   CheckIndic,ax
             call  GameSchetZap1
GameSch12:    ret
GameSchet1   ENDP
;------------������ ��� 1-------------------------------------------------------------
GameSchetZap1     PROC  NEAR  
             mov   si,IndexIndic
             mov   ax,TimeMassiv[18]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si+3],al
             mov   ax,TimeMassiv[16]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si+2],al
             mov   ax,TimeMassiv[12]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si+1],al
             mov   ax,TimeMassiv[10]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si],al
             mov   SchetMass[si+4],2
             ret
GameSchetZap1   ENDP
;------------��������� ��� 2-------------------------------------------------------------
GameSchet2        PROC  NEAR  
             cmp   GoTime1,1
             jbe   GameSch21              
             cmp   Schet[6],57
             jne   GameSch2
             inc   Schet[4]
             mov   Schet[6],47   
GameSch2:    inc   Schet[6]
             mov   ax,CheckIndic
             cmp   IndexIndic,ax
             je    GameSch23
             mov   IndexIndic,ax
GameSch23:   inc   IndexIndic
             inc   IndexIndic
             inc   IndexIndic
             inc   IndexIndic
             inc   IndexIndic
             mov   ax,IndexIndic
             mov   CheckIndic,ax
             call   GameSchetZap2
GameSch21:   ret
GameSchet2   ENDP
;------------������ ��� 2-------------------------------------------------------------
GameSchetZap2        PROC  NEAR  
             mov   si,IndexIndic
             mov   ax,TimeMassiv[18]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si+3],al
             mov   ax,TimeMassiv[16]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si+2],al
             mov   ax,TimeMassiv[12]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si+1],al
             mov   ax,TimeMassiv[10]
             sub   ax,48        
             push  si
             mov   si,ax
             mov   al,Image1[si]
             pop   si
             mov   SchetMass[si],al
             mov   SchetMass[si+4],1
             ret
GameSchetZap2   ENDP
;------------�뢮� ⥪��------------------------------------------------------------------------
OutSymBl     PROC  NEAR                
           mov   up,0ah            
           mov   down,06Ah
           mov   left,03Ah
           mov   dex,0
           mov   ch,1      
M2:        mov   si,dex
           add   dex,2           
           mov   dx,Memory[si]
           mov   si,dx
           mov   cl,3
           shl   si,cl   
           mov   al,ch
           mov   dx,up
           out   dx,al
           inc   up    
           mov   cl,1                  
M1:        mov   al,0
           mov   dx,down
           out   dx,al        
           mov   al,Image[si]
           mov   dx,left
           out   dx,al        
           mov   al,cl
           mov   dx,down
           out   dx,al        
           inc   si
           shl   cl,1
           jnc   M1 
           inc   down
           inc   left
           cmp   left,47h
           jbe   M2
           ret
OutSymBl     ENDP 
;------------��������� �६��� ���----------------------------------------------------------------------------
ClockTime        PROC  NEAR                
             cmp   GoTime,1
             jbe   CT
             inc   HourDelay
             cmp   HourDelay,1200
             jne   CT
             mov   HourDelay,0     
             inc   TimeMassiv[8]  
             cmp   TimeMassiv[8],58
             jne   CT
             mov   TimeMassiv[8],48
             inc   TimeMassiv[6]      
             cmp   TimeMassiv[6],54
             jne   CT
             mov   TimeMassiv[6],48
             inc   TimeMassiv[2]
             cmp   TimeMassiv[0],50
             jne   CT
             cmp   TimeMassiv[2],52
             jne   CT
             mov   TimeMassiv[2],48
             mov   TimeMassiv[0],48
             cmp   TimeMassiv[2],57
             jne   CT
             mov   TimeMassiv[2],48
             inc   TimeMassiv[0]
CT:          ret
ClockTime        ENDP
;------------��������� �६��� ����----------------------------------------------------------------------------
ClockGame    PROC  NEAR                
             cmp   GoTime1,1
             jbe   CG
             inc   MinuteDelay
             cmp   MinuteDelay,20
             jne   CG
             mov   MinuteDelay,0
             inc   TimeMassiv[18]  
             cmp   TimeMassiv[18],58
             jne   CG
             mov   TimeMassiv[18],48
             inc   TimeMassiv[16]      
             cmp   TimeMassiv[16],54
             jne   CG
             mov   TimeMassiv[16],48
             inc   TimeMassiv[12]
             cmp   TimeMassiv[12],58
             jne   CG
             mov   TimeMassiv[12],48
             inc   TimeMassiv[10]                                  
CG:          ret
ClockGame    ENDP
;------------�뢮� �६���----------------------------------------------------------------------------
ClockMain       PROC  NEAR                
           cmp   GoTime,1
           jbe  ClockMainE 
           mov   up,0h           
           mov   down,60h
           mov   left,30h
           mov   dex,0
           mov   ch,1      
ClockMain2:mov   si,dex
           add   dex,2           
           mov   dx, TimeMassiv[si]
           mov   si,dx
           mov   cl,3
           shl   si,cl   
           mov   al,ch
           mov   dx,up
           out   dx,al
           inc   up    
           mov   cl,1                  
ClockMain1:mov   al,0
           mov   dx,down
           out   dx,al        
           mov   al,Image[si]
           mov   dx,left
           out   dx,al        
           mov   al,cl
           mov   dx,down
           out   dx,al        
           inc   si
           shl   cl,1
           jnc   ClockMain1 
           inc   down
           inc   left
           cmp   left,39h
           jbe   ClockMain2
ClockMainE:     ret
ClockMain       ENDP    
;------------�뢮� ��� ����------------------------------------------------------------
GameSchet      PROC  NEAR                
           cmp   GoTime,1
           jbe   GameScheta1 
           mov   up,18h           
           mov   down,78h
           mov   left,48h
           mov   dex,0
           mov   ch,1      
GameScheta12:
           mov   si,dex
           add   dex,2           
           mov   dx, Schet[si]
           mov   si,dx
           mov   cl,3
           shl   si,cl   
           mov   al,ch
           mov   dx,up
           out   dx,al
           inc   up    
           mov   cl,1                  
GameScheta11:
           mov   al,0
           mov   dx,down
           out   dx,al        
           mov   al,Image[si]
           mov   dx,left
           out   dx,al        
           mov   al,cl
           mov   dx,down
           out   dx,al        
           inc   si
           shl   cl,1
           jnc   GameScheta11 
           inc   down
           inc   left
           cmp   left,4Bh
           jbe   GameScheta12
GameScheta1:     ret
GameSchet        ENDP    
;------------�뢮� �������஢----------------------------------------------------------------
Indic        PROC  NEAR                
           mov   dx,1Ch
           mov   si,IndexIndic
           push  si
Indic2:    mov   al,SchetMass[si]
           out   dx,al
           inc   dx
           inc   si
           cmp   dx,1Fh
           jbe   Indic2
           mov   dx,97h
           pop   si
           mov   al,SchetMass[si+4]
           out   dx,al
Indic1:    ret
Indic        ENDP
;--------------------------------------------------------------------------------------
Start:     
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;---------------My program-------------------------------------------------------------
           call  Init
Time:
           call  ClockMain
           call  GameSchet
           call  ClockTime
           call  ClockGame
           call  KbdInput
           call  KbdInContr
           call  NxtSymBl
           call  OutSymBl
           call  Indic
           jmp   Time
;--------------------------------------------------------------------------------------
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end