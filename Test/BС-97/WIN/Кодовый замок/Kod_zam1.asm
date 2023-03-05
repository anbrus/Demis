page 30,255
; �ணࠬ�� ࠡ��� �������� �����

            Name CodeLockProgram

; ����⠭�� ���ᮢ ���⮢ �����/�����
InputPort1 = 0      ; ���� ���⮢
InputPort2 = 1      ; �����

OutputPort1 = 1     ; ����  
OutputPort2 = 2     ; ���⮢
OutputPort3 = 3     ; �뢮��
OutputPort4 = 4     ; �������� ���ଠ樨

ClockPort1 = 5      ; ���� ���⮢
ClockPort2 = 6      ; �뢮�� �६���

IndiPort = 7        ; ���� ���� � �������ࠬ�
NumberPort = 8      ; ���� ���� �뢮�� ����� �஢�� �����

NTime = 0FFFFH      ; ���⥫쭮��� 横�� ����প� 

TimeLevel12 = 60    ; �६� ࠡ��� 1 � 2 �஢��� �����
TimeLevel3  = 10    ; �६� ࠡ��� 3-�� �஢�� �����
TimeLevel7  = 15    ; �६� ࠡ��� ᨣ������樨 (7-�� �஢��)

; ���ᠭ�� ������
Data Segment at 0H
       Mas db 129 dup (?)       ; ���ᨢ ��� ��ॢ��� ��⠭���� �� ���� 0
                                ; ���� � �����筮� ���祭��

       Mas1 db 129 dup (?)      ; ���ᨢ ��� ��ॢ��� ��⠭���� �� ���� 1
                                ; ���� � �����筮� ���祭��
 
       Mas_Kod db 11 dup (?)    ; ���ᨢ ���祭�� ��� �뢮�� ��� �� ⠡��

       Mas_DigitKod db 4 dup (?); ���ᨢ ��������� ���      

       Password db 4 dup (?)    ; ��஫� ��� ������ ����� �� ��ࢮ� �஢�� 
       
       Clock db ?               ; �६� ࠡ��� ⥪�饣� �஢�� (�)

       FirstPress db ?          ; 䫠� ��ࢮ�� ������ �� ⥪�饬 �஢�� 

       FlagMistake db ?         ; 䫠� ᮢ��襭�� �訡�� �� ����� ��஫�

       LevelNumber db ?         ; ����� ⥪�饣� �஢�� �ணࠬ��

       MistakeCount db ?        ; ������⢮ ᮢ��襭��� �訡�� 

       RandomVar db ?           ; ������� ��砩��� ��� (0..99)

       FirstVisit db ?          ; 䫠� ��砫� �஢�� 
             
       InputFlag db ?           ; 䫠� �����
   
       EmptyFlag db ?           ; 䫠� ���⮩ ���������� 

       KeyTrue db ?             ; 䫠� ������ �㦭��� 
                                ; ���� �� 3-�� �஢�� ����� 
Data Ends 

StackS Segment Stack at 100H
  db 200H dup (?)
  StkTop label word
StackS Ends

Code Segment
assume cs:Code,ds:Data,ss:StackS 
;----------------------------------------------------------------------------
InitProc proc near
; ��砫쭠� ���樠������ ��� �ᯮ��㥬�� � �ணࠬ��
; ���ᨢ��. ��뢠���� ⮫쪮 ���� ࠧ �� �� �६� �믮������ �ணࠬ��

       mov Mas_Kod[0], 3FH  ; ��� 0
       mov Mas_Kod[1], 0CH  ; ��� 1
       mov Mas_Kod[2], 76H  ; ��� 2
       mov Mas_Kod[3], 5EH  ; ��� 3
       mov Mas_Kod[4], 4DH  ; ��� 4
       mov Mas_Kod[5], 5BH  ; ��� 5
       mov Mas_Kod[6], 7BH  ; ��� 6
       mov Mas_Kod[7], 0EH  ; ��� 7           
       mov Mas_Kod[8], 7FH  ; ��� 8
       mov Mas_Kod[9], 5FH  ; ��� 9
       mov Mas_Kod[10],00H  ; ����

       mov Mas_DigitKod[0],10                              
       mov Mas_DigitKod[1],10                              
       mov Mas_DigitKod[2],10                              
       mov Mas_DigitKod[3],10 

       mov Mas[1],   0H  ; ��� 0
       mov Mas[2],   1H  ; ��� 1
       mov Mas[4],   2H  ; ��� 2
       mov Mas[8],   3H  ; ��� 3
       mov Mas[16],  4H  ; ��� 4
       mov Mas[32],  5H  ; ��� 5
       mov Mas[64],  6H  ; ��� 6
       mov Mas[128], 7H  ; ��� 7
       
       mov Mas1[1],   8H    ; ��� 8
       mov Mas1[2],   9H    ; ��� 9
       mov Mas1[4],   0AH        
       mov Mas1[8],   0FFH  ; ������ "����"
       mov Mas1[16],  0EEH  ; ������ "������"
       mov Mas1[32],  0DDH  ; ������ "����"
       mov Mas1[64],  0CCH  ; ������ "����-1"
       mov Mas1[128], 0BBH  ; ������ "��襫"
              
       mov LevelNumber,1    ; ��稭��� � ��ࢮ�� �஢��
       mov FirstVisit,0FFH  ; ��⠭���� 䫠�� ��ࢮ�� ���饭��

       mov Password[0],4    ;
       mov Password[1],3    ; ��஫� - 1234
       mov Password[2],2    ;
       mov Password[3],1    ;

       mov RandomVar,0      ; ��⠭���� ��砩���� ���祭�� � 0             
        
       ret
InitProc endp
;----------------------------------------------------------------------------
Timer proc near
; ��楤��, ������� �� �뢮� �� ��������� �६���
; ��⠢襥�� �६� ࠡ��� ⥪�饣� �஢�� ����� �ணࠬ��
; �室�� ��ࠬ����:
;    Clock - �६� ��� ����� � � (�� ����� 99 �)            
; ��室�� ��ࠬ����:
;    Clock - 㬥��蠥� �� 1
       
       cmp Clock,0
       je H1       

       mov al, clock
         
       aam                        ; �।�⠢�塞 ����祭��� �६� �
                                  ; ���� ASCII
       lea bx, Mas_Kod            ; 

       xlat                       ; �뢮� �� ��������
       out ClockPort2,al          ; ����襩 ��� �६���
       mov al,ah                  ;
       xlat                       ; �뢮� �� ��������
       out ClockPort1,al          ; ���襩 ��� �६���

       mov cx,NTime
H:     nop
       nop
       nop
       nop
       loop H

       dec Clock

       cmp Clock,0
       jne H1
       mov FirstVisit,0FFH       
       cmp LevelNumber,7         ; �஢��� ᨣ������樨?
       jne H2                    ; ��� - ���室
       mov LevelNumber,1         ; �� - ���室 �� ���� �஢���
       
       jmp H1
     
H2:    mov LevelNumber,7         ; ����祭�� ᨣ������樨       

H1:    ret
Timer endp
;----------------------------------------------------------------------------
DoMas proc near	
; ��楤�� �ନ஢���� ���ᨢ� �⮡ࠦ����
; �室�� ��ࠬ����:
;   al - ��� �����筮� ���� (0..9)
;   dl - ����� ���� �뢮�� � �������஬ (1..4) �� ���ண� �㤥�
;        �ந��������� ��᪮���� ���� 
; ��室�� ��ࠬ����:     
;   Mas_DigitKod - ���ᨢ ���࠭��� ���,
;                  ��祬 Mas_DigitKod[0] - ������ ��� (�ࠢ��) 

       cmp EmptyFlag,0FFH           ; ��祣� �� �����?
       je M4                        ; �� - ��室  
       
       cmp dl,1                     ; �뢮���� ���� ����?
       je  M1                       ; �� - ���室

       xor cx,cx                    ; ���㫥��� ��

       mov cl,dl                    ;                
       dec cl                       ; ��९��뢠��� ��� ᤢ��
       mov si,cx                    ; �࠭����� � Mas_DigitKod
M:     mov ah,Mas_DigitKod[si-1]    ; ���祭�� �뢥������ �� 
       mov Mas_DigitKod[si],ah      ; ��������� ��� �� ����
       dec si                       ; ���� ����� (�.�. ���࠭��
       loop M                       ; ���襩 ���� ����襩)

M1:    mov Mas_DigitKod[0],al       ; ������ ����� ����襩 ���� 
    
M4:    ret
DoMas endp
;----------------------------------------------------------------------------
OutDigit proc near
; ��楤�� �뢮�� �� �࠭ ����⮩ ���� � ०��� ��᪮��筮�   
; ����饩 ��ப� �ࠢ� ������ � �।���� 㪠������ �������஢.
; �室�� ��ࠬ����:
;   dl - ����� ���� �뢮�� � �������஬ (1..4) �� ���ண� �㤥�
;        �ந��������� ��᪮���� ���� 
;   Mas_DigitKod - ���ᨢ ���࠭��� ���
       
       cmp EmptyFlag,0FFH
       je M3
              
       lea bx,Mas_Kod              

       mov cl,dl                    ;
       mov dx,OutputPort1           ;
       mov si,0                     ; 
M2:    mov al,Mas_DigitKod[si]      ; �뢮� �� ��������� ���祭��,
       xlat                         ; ᮤ�ঠ騥�� � Mas_DigitKod
       out dx,al                    ;
       inc(si)                      ;
       inc(dx)                      ;
       Loop M2                      ;
       
M3:    ret    
OutDigit endp
;----------------------------------------------------------------------------
ButtonPress proc near
; ��楤�� ���뢠��� ����⮩ ������ � ����७��� 
; ��室�� ��ࠬ����
;    AL - ��� ����⮩ ������ ��� 10 � ��⨢��� ��砥

       cmp LevelNumber,4     ; �᫨ ⥪�騬 ०����
       jne N6                ; ���� ���� �� ����஢���
       je N7                 ; ०��� ������, �
N6:    cmp LevelNumber,5     ; ������㥬 �������⥫���
       jne N                 ; ����প�, ⠪ ���
                             ; � ��㣨� �஢��� ஫� ����প� ��ࠥ�
N7:    mov cx,NTime          ; ����প� ⠩���
N8:    nop
       nop
       nop
       nop 
       loop N8               ;


N:     in al,Inputport1      ; ���� �� ���� 0

       cmp al, 0             ; ����� ���?
       je N1                 ; �� - ���室

       lea bx,Mas            ; ����砥� ���
       xlat                  ; ����⮩ ������
       jmp N5                ; ���室 �� ��室 �� ��楤���
 
N1:    in al,InputPort2      ; ���� �� ���� 1

       cmp al,0              ; ����� ���?
       je N3                 ; �� - ���室
       
       lea bx,Mas1           ; ����砥� ���
       xlat                  ; ����⮩ ������       
       jmp N5                ; ���室 �� ��室 �� ��楤���

N3:    mov al,10             ; ���� ���������

N5:    ret
ButtonPress endp
;----------------------------------------------------------------------------
CheckPress proc near
; ��楤�� ������� ����⮩ ������
; �室�� ��ࠬ����:
;    al - ��� ����⮩ ������
; ��室�� ��ࠬ����:
;    dl - ���-�� �ᯮ��㥬�� ⠡�� �뢮��
;    EmptyFlag 
;    InputFlag
;    KeyTrue 

       mov EmptyFlag,0FFH
       mov InputFlag,00H
       
       cmp al,10
       jne J
       jmp JEnd      
     
J:     cmp LevelNumber,1
       jne J1
       cmp al,10
       jb J_1
       ja J_2

J_1:   mov EmptyFlag,00H
       mov dl,4
       jmp JEnd 

J_2:   cmp al,0FFH
       jne J_3
       mov InputFlag,0FFH
       jmp JEnd
        
J_3:   cmp al,0EEH
       je J_4
       jmp JEnd

J_4:   mov LevelNumber,4
       mov FirstVisit,0FFH
       jmp JEnd
 
J1:    cmp LevelNumber,2
       jne J2
       cmp al,10
       jb J1_1
       ja J1_2

J1_1:  mov EmptyFlag,00H
       mov dl,2
       jmp JEnd 

J1_2:  cmp al,0FFH
       jne JJ
       mov InputFlag,0FFH
JJ:    jmp JEnd
       
J2:    cmp LevelNumber,3
       jne J3
    
       cmp al,10
       jb JEnd
       cmp al,0DDH
       jne J2_1
       mov KeyTrue,0FFH
       mov InputFlag,0FFH
       jmp JEnd

J2_1:  cmp al,0CCH
       jne JEnd
       mov KeyTrue,00H
       mov InputFlag,0FFH
       jmp JEnd
 
J3:    cmp LevelNumber,4
       jne j4
       
J4_1:  cmp al,10
       jb J3_1
       ja J3_2

J3_1:  mov EmptyFlag,00H
       mov dl,4
       jmp JEnd

J3_2:  cmp al,0FFH
       jne JEnd
       mov InputFlag,0FFH
       jmp JEnd
 
J4:    cmp LevelNumber,5
       jne J5
       je J4_1

J5:    cmp LevelNumber,6
       jne JEnd
       
       cmp al, 0BBH
       jne JEnd
       mov InputFlag,0FFH
       
JEnd:  ret
CheckPress endp
;----------------------------------------------------------------------------
DoInput proc near
; ��楤�� ������� �믮������ ����⢨� 
; �� ����⨨ �� "����".
; �஢���� 䫠�� 
;     FirstPress �
;     FlagMistake � �᫨ ��� ��⠭������, � 
; �������� ����⢨� �� "����".
   
       cmp InputFlag,0FFH
       jne YEnd
       
       cmp LevelNumber,2
       jbe Y
       jmp YEnd

Y:     cmp FirstPress,0FFH
       jne Y1
       je Y2
Y1:    cmp FlagMistake,0FFH
       jne YEnd     

Y2:    mov InputFlag,00H

YEnd:  ret
DoInput endp
;----------------------------------------------------------------------------
OnInput proc near       
; ��楤�� �믮������ ����⢨�
; �� ����⨨ �� �᭮��� �㭪樮����� ������.

       cmp InputFlag,0FFH
       je X
       jmp XEnd
         
X:     cmp LevelNumber,1
       jne X1
              
       mov ax,Word Ptr Mas_DigitKod
       sub ax,Word Ptr Password
       mov dx,Word Ptr Mas_DigitKod+2
       sub dx,Word Ptr Password+2
       or ax,dx  
       cmp ax,0                       ; �������� ��஫� ࠢ�� ���������?
       jne XX
       mov LevelNumber,2              ; �� - ���室 �� ᫥���騩 �஢���
       mov FirstVisit,0FFH
       jmp XEnd

XX:    mov FlagMistake,0FFH           ; ��⠭���� 䫠�� �訡�� 
       mov al,4                       ; ��ᢥ稢���� ��������
       out IndiPort,al                ; �訡��

       inc MistakeCount               ; 㢥��祭�� ���稪� �訡��
       cmp MistakeCount,3             ; ᤥ���� 3 �訡��?
       jne XP

XX1:   mov LevelNumber,7
       mov FirstVisit,0FFH
       jmp XEnd

XP:    jmp XEnd                    ; �஬����筠� ��⪠

X1:    cmp LevelNumber,2
       jne X2

       mov al,Byte Ptr Mas_DigitKod
       sub al,Byte Ptr Mas_DigitKod+3
       mov ah,Byte Ptr Mas_DigitKod+1
       sub ah,Byte Ptr Mas_DigitKod+2
       or al,ah  
       cmp al,0                       ; �������� ��஫� ࠢ�� ���������?
       jne XX

       mov LevelNumber,3              ; �� - ���室 �� ᫥���騩 �஢���
       mov FirstVisit,0FFH
       jmp XEnd

X2:    cmp LevelNumber,3
       jne X3
    
       cmp KeyTrue,0FFH
       jne XX1
       mov LevelNumber,6
       mov FirstVisit,0FFH
       jmp XEnd
          
X3:    cmp LevelNumber,4
       jne X4

       mov ax,Word Ptr Mas_DigitKod
       sub ax,Word Ptr Password
       mov dx,Word Ptr Mas_DigitKod+2
       sub dx,Word Ptr Password+2
       or ax,dx  
       cmp ax,0                       ; �������� ��஫� ࠢ�� ���������?
       je X3_1
       
       mov LevelNumber,1
       mov FirstVisit,00H
       mov FlagMistake,0FFH
       mov FirstPress,00H
       call BeginLevel       
       mov ax,di
       mov Clock,al
       jmp XEnd

X3_1:  mov LevelNumber,5
       mov FirstVisit,0FFH
       jmp XEnd

X4:    cmp LevelNumber,5
       jne X5

       mov ax,word ptr Mas_DigitKod       
       mov word ptr password,ax 
       mov ax,word ptr Mas_DigitKod+2       
       mov word ptr password+2,ax
X6:    mov LevelNumber,1
       mov FirstVisit,0FFH 
       jmp XEnd

X5:    cmp LevelNumber,6
       jne XEnd
       jmp X6       

XEnd:  ret  
OnInput endp
;----------------------------------------------------------------------------
FirstPressProc proc near
; ��楤��, ॠ������� ����⢨�,
; �易��� � ���� ����⨥� ������ ����������
; �� 1-2 �஭��

       push ax

       cmp FirstPress,0FFH
       jne DEnd
       
       cmp EmptyFlag,0FFH
       je DEnd

       mov FirstPress,00H 
       cmp LevelNumber,1
       jne D1
       
       mov Clock,TimeLevel12;
       jmp DEnd

D1:    cmp LevelNumber,2
       jne DEnd
       mov al,0
       out IndiPort,al

DEnd:  pop ax
       ret    
FirstPressProc endp
;----------------------------------------------------------------------------
OnMistake proc near
; ��楤��, ॠ������� ����⢨�,
; �易��� � ���� ����஬ ��஫� ��᫥ �訡��

       push ax      
 
       cmp FlagMistake,0FFH
       jne UEnd
       
       cmp EmptyFlag,0FFH
       je UEnd
        
       mov FlagMistake,00H
       cmp LevelNumber,1
       jne U1

       call BeginLevel       
       jmp UEnd

U1:    cmp LevelNumber,2
       jne UEnd
       
       mov al,0             ; �����⮢�� �������஢ � ࠡ��                     
       out IndiPort,al
       out OutputPort1,al
       out OutputPort2,al
       mov Byte Ptr Mas_DigitKod[0],10
       mov Byte ptr Mas_DigitKod[1],10       
                    
UEnd:  pop ax
       ret             
OnMistake endp
;----------------------------------------------------------------------------
InitLevel proc near
; ��楤�� ���樠����樨 �஢��� ࠡ��� �ணࠬ��
; ��। �� �ᯮ�짮������

       cmp FirstVisit,0FFH
       je R
       jmp REnd

R:     mov al,clock               ; ���࠭���� ⥪�饣� �६���
       mov di,ax                  ; (�ᯮ������ ��� ०��� ������)
       
       mov FirstVisit,00H
       call BeginLevel
       call TimeClear
       mov FirstPress,0FFH
       mov FlagMistake,00H
       mov MistakeCount,0

       cmp LevelNumber,1
       jne R1                                
       
       mov al,0CH               
       out NumberPort,al        
       
       jmp REnd        
              
R1:    cmp LevelNumber,2
       jne R2

       mov Clock,TimeLevel12       ; ��⠭���� ⠩��� �� 60 �       

       mov al,76H                  ; ����祭�� ����� ⥪�饣� �஢��
       out NumberPort,al           ; ����� (2-�� �஢��)   

       mov al,RandomVar            ; ����砥� ��砩��� ���祭��         

       aam                             ;
       lea bx,Mas_Kod                  ;        
       mov Byte ptr Mas_DigitKod[2],al ; ��⠭���� �����
       xlat                            ; ���� ��� ⠡��
       out OutputPort3,al              ; 
       mov al,ah                       ; 
       mov Byte ptr Mas_DigitKod[3],al ;
       xlat                            ;
       out OutputPort4,al              ;
      
       jmp REnd        

R2:    cmp LevelNumber,3
       jne R3

       mov Clock,TimeLevel3 ; ��⠭���� ⠩��� �� 10 � 

       mov al,5EH                  ; ����祭�� ����� ⥪�饣� �஢��
       out NumberPort,al           ; ����� (3-�� �஢��)   
      
       jmp REnd        

R3:    cmp LevelNumber,4    
       jne R4
       
       mov al,40H           ; �������� ०���
       out IndiPort,al      ; ������ ����
       
       mov ax,di  
       cmp al,0
       jne RR1
       mov al,60
       jmp RR1

RR1:   mov di,ax            ; ��࠭���� ⥪�饣� �६���
      
       jmp REnd        

R4:    cmp LevelNumber,5
       jne R5
       
       mov al,40H           ; �������� ०���
       out IndiPort,al      ; ������ ����       

       mov al,3FH           ;   
       out OutputPort1,al   ; ����ᨬ 
       out OutputPort2,al   ; ���� ���
       out OutputPort3,al   ; 
       out OutputPort4,al   ;
       mov Mas_DigitKod[0],0
       mov Mas_DigitKod[1],0
       mov Mas_DigitKod[2],0
       mov Mas_DigitKod[3],0 
       jmp REnd        
 
R5:    cmp LevelNumber,6
       jne R6

       mov al,10H           ; ����祭�� ��������
       out IndiPort,al      ; ������ �����             
      
       jmp REnd        

R6:    cmp LevelNumber,7
       jne REnd

       mov al,1             ; ��������
       out IndiPort,al      ; ᨣ������樨
       
       mov al,0H            ; �몫�祭�� ����� ⥪�饣� �஢��
       out NumberPort,al    ; ����� (2-�� �஢��)   


       mov clock,TimeLevel7 ; ������� �६��� ࠡ��� ᨣ������樨             
        
REnd:  ret
InitLevel endp
;----------------------------------------------------------------------------
Random proc near
; ��楤�� �����樨 ��砩���� �᫠ �� 0 �� 99

       inc RandomVar
       cmp RandomVar,100
       jne Quit
       mov RandomVar,0
Quit:  ret
Random endp
;----------------------------------------------------------------------------
TimeClear proc Near
; ��楤�� ���⪨ �������஢ ⠩���

       mov Clock,0          ;
       mov al,0             ;
       out ClockPort2,al    ;
       out ClockPort1,al    ;        
       ret
TimeClear endp
;----------------------------------------------------------------------------
BeginLevel proc Near
; ��楤�� ���樠����樨 ��砫� ࠡ��� �஢�� �����.

       push ax
      
       mov al,0             ; ���祭�� ��� 
       out IndiPort,al      ; �����祪-�������஢

       mov Mas_DigitKod[0],10   ;
       mov Mas_DigitKod[1],10   ;
       mov Mas_DigitKod[2],10   ;
       mov Mas_DigitKod[3],10   ; ���⪠ �������஢ �뢮�� 
       out OutputPort1,al       ;
       out OutputPort2,al       ;
       out OutputPort3,al       ;
       out OutputPort4,al       ;

       pop ax
       
       ret                      
BeginLevel endp
;----------------------------------------------------------------------------       
Begin: mov ax,Data
       mov ds,ax
       
       mov ax,StackS
       mov ss,ax       
       mov sp,offset StkTop   
       
       call InitProc             ; �㭪樮���쭠� �����⮢��

NewB:  call Random               ; ������� �ந����쭮�� ���祭��
       
       call InitLevel            ; �㭪樮���쭠� �����⮢�� �஢�� � ࠡ�� 

       call Timer                ; ������             

       call ButtonPress          ; ���� � ����������
 
       call CheckPress           ; ������ ����� � ����������

       call FirstPressProc       ; ����⢨� �� ��ࢮ�� ������ �� �஢��

       call OnMistake            ; ����⢨� �� ����稨 �訡�� ����� ��஫� 

       call DoMas                ; ��ନ஢���� ���ᨢ� �⮡ࠦ����

       call OutDigit             ; �뢮� ���ଠ樨 �� ��ᯫ��

       call DoInput              ; ����஫� �� ����������� �믮������ �����

       call OnInput              ; ���� ���ଠ樨 � ��ࠡ�⪠

       jmp NewB
     
Start: org  0FF0h
       assume cs:nothing
       jmp  Far Ptr Begin
        
Code Ends

End Start                  