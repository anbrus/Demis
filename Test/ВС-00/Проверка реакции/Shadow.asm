
;������ ���� ��� � �����
RomSize         EQU   4096
KbdPort         EQU    16h 
StrategyPort    EQU     0h
ActionPort      EQU     1h 
TimePort_sot_1  EQU    10h 
TimePort_sot_2  EQU    11h 
TimePort_sec_1  EQU    12h 
  

Human_1     STRUC
    H_Name   db 8  dup  (?)
    Test1    dd     (?)
    Test2    dd     (?)
Human_1     EndS

Human     STRUC
    P_Name   db 8  dup  (?)
    Rez_Test dd         (?)
    Plase    db         (?)
Human     EndS

IntTable   SEGMENT AT 0 use16
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Data       SEGMENT AT 40h use16

Letters      db   4*9*7 dup (?)
Col          db              ?   ; ������ ������ 䠬���� (����ﭮ ���������)
Col_Name     db              ?   ; ������⢮ 䠬���� 
Grup       Human_1  5    dup (?)
KbdImage     DB     4    DUP (?)
Error        DB     4    DUP (?)  ; �࠭�� ��ࠧ ᫮�� "Err"
Time         DB     4    DUP (?)  ; �࠭�� �६� ���
Digit_s      DB     10   DUP (?)  ; �࠭�� �६� ���
BuFF_Name    DB     8    DUP (?)  ; �࠭�� ��� ���⭨�� ��� � Rial Time
Mas_1      Human    5    dup (?)
Mas_2      Human    5    dup (?)
Mas_3      Human    5    dup (?)
Col_Mas_1    DB             ?
Col_Mas_2    DB             ?
Col_Mas_3    DB             ?
Col_New_1    DB             ?
Col_New_2    DB             ?
Col_New_3    DB             ?
Letter       DB             ?
EmpKbd       DB             ?
KbdErr       DB             ?
KbdUnc       DB             ?
NextDig      DB             ?
Base         DW             ?
H_Test1      DB             ?  ; ����� �஢�ન ��堭��᪮� ॠ�樨
H_Test2      DB             ?  ; ����� �஢�ન ��⢥����   ॠ�樨
H_Sum        DB             ?  ; ����� �஢�ન ��⢥����   ॠ�樨
StratErr     DB             ?  ; ����, ������⢨� �롮� ���  
End_Test     DB             ?  ; ���� ���� ���
Go_Test      DB             ?  ; ���� ��砫� ���
No_Name      DB             ?  ; ���� ������⢨� 䠬���� ���⭨�� ���
Randoom      DW     7   DUP (?)  ;
offs         DW             ?  ; 
Right_Dig    DB             ?  ; �ࠢ���� ��� ������, ������ �㦭� ������ (���� �2)
Kol          DB             ?  ; ����稪, �㦥� ��� ����ࠦ���� �६��� 
Rezult       DB             ?  ; ����� ��ᬮ�� १���⮢
My_Test      DB             ?  ; ����� ���஢���� 
Human_Rec    dw             ?  ; ������ ����� ���ᨢ� Grup
Offs_Name    dw             ?  ; ���饭�� 䠬���� � ᯨ᪥
XH           db             ?
H_Plase      db             ?
KbdImage_1   db             ?
Power        db             ? 
Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT AT 500h use16
;������ ����室��� ࠧ��� �⥪�
           dw    15 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�
InitData   ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

           ASSUME cs:Code,ds:Data,es:Data

Clear_BuFF_Name Proc
           mov Cx,Length BuFF_Name
           mov si,offset BuFF_Name
X1:
           mov byte ptr ds:[si],224
           inc  si
           Loop X1
           Ret
Clear_BuFF_Name EndP

Delay      proc  near
           push  cx ax dx
           mov   cx,5;000Ah
DelayLoop:
           inc   cx
           dec cx
           inc   cx
           dec cx
           push  cx
           Call  L_Input        ; ����ᮢ뢠�� 䠬����, �⮡� �� �뫮 ������� 
           pop   cx
           loop  DelayLoop
           pop   dx ax cx
           ret
Delay      endp

Set_Start_Time Proc Near
           Mov   cx,Length Time
           Lea   si,Time
           mov   al,0
A0:
           mov  ds:[si],al
           inc si
           Loop  A0
           Mov   cx,Length Time
           Lea   si,Time
           Lea   bx,Digit_s
           mov   dx,10h
A1:
           Xor   ax,ax
           mov   al, ds:[si]
           mov   di, ax        
           mov   al, ds:[bx+di]
           out   dx, al
           inc   dx
           inc   si
           Loop A1
           Ret  
Set_Start_Time EndP


KbdInput   PROC  NEAR
           Cmp Power,1
           jne KI5
           Cmp Rezult,0
           jne KI5
           lea   si,KbdImage         ;����㧪� ����,
           mov   cx,LENGTH KbdImage  ;����稪� 横���
           mov   bl,0FEh             ;� ����� ��室��� ��ப�
KI4:       mov   al,bl       ;�롮� ��ப�
           out   KbdPort,al  ;��⨢��� ��ப�
           in    al,KbdPort  ;���� ��ப�
           cmp   al,0FFh
           jz    KI1         ;���室, �᫨ ���
           mov   dx,KbdPort  ;��।�� ��ࠬ���
           
           mov   [si],al     ;������ ��ப�
KI2:       in    al,KbdPort  ;���� ��ப�
           cmp   al,0FFh
           ;push  cx
           ;pop   cx
           jnz   KI2         ;���室, �᫨ ���        
         
           jmp   SHORT KI3
KI1:       mov   [si],al     ;������ ��ப�
KI3:       inc   si          ;����䨪��� ����
           rol   bl,1        ;� ����� ��ப�
           loop  KI4         ;�� ��ப�? ���室, �᫨ ���
KI5:
           ret
KbdInput   ENDP

KbdInContr PROC  NEAR
           Cmp Power,1
           jne KIC4
           Cmp Rezult,0
           jne KIC4 
           lea   bx,KbdImage ;����㧪� ����
           mov   cx,LENGTH KbdImage  ;����稪� 横���
           mov   EmpKbd,0    ;���⪠ 䫠���
           mov   KbdErr,0
           Xor   dx,dx       ;� ������⥫�
KIC2:      
           mov   al,ds:[bx]
           cmp   al,0FFh      
           jne   KIC1
           inc   dl          
           jmp   KIC0
KIC1:
           mov   Letter,al
           mov   ax,bx
           sub   ax, OFFSET KbdImage
           mov   base,ax     ;���������� ����� ��ப� (0,1,2,3) 
KIC0:
           inc   bx          ;����䨪��� ���� ��ப�
           loop  KIC2        ;�� ��ப�? ���室, �᫨ ���

           cmp   dl,4        ;������⥫�=4?
           je    KIC3        ;���室, �᫨ ��
           cmp   dl,3        ;������⥫�=3?
           je    KIC4        ;���室, �᫨ ��
           mov   KbdErr,0FFh ;��⠭���� 䫠�� �訡��
           jmp   SHORT KIC4
KIC3:      mov   EmpKbd,0FFh ;��⠭���� 䫠�� ���⮩ ����������
KIC4:
           ret               ;�᫨ dl=3 ����� ��� ��ଠ�쭮
KbdInContr ENDP

NxtDigTrf  PROC  NEAR
           Cmp Power,1
           jne NDT1
           Cmp Rezult,0
           jne NDT1
           cmp   EmpKbd,0FFh  ;����� ���������?
           jz    NDT1         ;���室, �᫨ ��
           cmp   KbdErr,0FFh  ;�訡�� ����������?
           jz    NDT1         ;���室, �᫨ ��
           lea   bx,KbdImage  ;����㧪� ����
           Xor   dx,dx        ;���⪠ ������⥫�� ���� ��ப� � �⮫��           
           mov   al,Letter    ;����㧪� ॠ�쭮�� ���� �㪢� 
           CLC
NDT2:      
           Rol   al,1         ;�뤥����� 0, � dh - ����� �㪢� ���������� 
           inc   dh           ;᫥�� �� �ࠢ� 1,2,3,...,32
           jc    NDT2
           dec   dh           ;㬥��蠥� �� 1 (0,1,2,...,31)         
            
           mov   NextDig,dh  ;������ ������஢����� ���� ����
NDT1:      
           ret
NxtDigTrf  ENDP

Print      Proc  Near
           Cmp Power,1
           jne NO1
           Cmp Rezult,0
           jne NO1 
           cmp   KbdErr,0FFh
           jz    NO1
           cmp   EmpKbd,0FFh
           jz    NO1
           xor   ah,ah
           mov   al,NextDig
           mov   bx,base    ; � BASE- ᬥ饭�� ��ப� "�������" ���������� (0,1,2,3)
           mov   cl,7        
           mul   cl         ; ����祭�� ᬥ饭�� �㪢� � ��ப� (������ ��������� 7 ���⠬�)
           mov   dx,ax
           mov   ax,bx
           mov   cl,56
           mul   cl         ; ����祭�� ᬥ饭�� ��ப� � ���ᨢ� ��ࠧ�� (� ��ப� 8 �㪢 - 8*7=56 ���⮢)
           add   ax,dx      ; �����⥫�� ���� �㪢� � ���ᨢ�
           Xor   bx,bx
           cmp   Col,7      ; �᫨ ����� 祬 8 �㪢 (�㬥��� � 0!!!!!!)
           jne   NO2
           mov   Col,0
NO2:           
           Cmp   Col,0
           jne   NO3
           Call  Clear_BuFF_Name
NO3:
           mov   bl,Col     ; � bl - ᬥ饭�� ��।��� �㪢� 䠬����
           mov   si,bx
           Mov   BuFF_Name[si], al ; ����ᨬ ���� �㪢 䠬���� ��᫥����⥫쭮
           inc   Col
NO1:           
           Ret
Print      EndP

L_Input    Proc
           Push  si
           Cmp Power,1
           jne M11 
           ;cmp   Col,0
           ;je    M11
           Call  In_Letter
M11:
           pop   si
           Ret
L_Input    EndP

;***************************************************
;** ��⠥� ���� � 䠬����� � �뢮��� �� �� �࠭ **
;***************************************************
In_Letter  Proc  Near              
           mov   dx,1              ; ���� ���� =1
           mov   al,1
           
           mov   cx,7              ; ��⨢����� ����� (1..7)
M0:
           out   dx,al
           inc   dx
           Shl   al,1             
           Loop  M0
           
           mov   dx,8              ; �뢮� �㪢 䠬���� � 横�� �� ���������(� dx - ����� ��ࢮ�� ���� �⮫�殢)
           Xor   cx,cx
           mov   cl, 8;Col            ; ����㧪� ����稪� �㪢 (���譨� 横�)
           mov   si,0              ; ���� �� ����� �㪢� 䠬����
M1:           
           Xor   ax,ax
           mov   al,BuFF_Name[si]
           mov   bx,ax             ; ���饭�� �㪢� � ���ᨢ� ��ࠧ��
           push  cx                ; �뢮� ����� �㪢� � 横�� �� ���������, ���������� ��஥ ���祭�� ����稪�
           mov   cx,7              ; ����㧪� ����稪� ��ப ������ (����७��� 横�)
           mov   al,1
M2:
           out   0,al
           shl   al,1              ; �஡����� ��᫥����⥫쭮 �� ��ப�
           push  ax                ; ���������� ���ﭨ� ��ப�  
           mov   al,ds:[bx]        ; ��⨢����㥬 �㦭� �⮫���
           out   dx,al
          
           mov   al,0              ; ��ࠥ� ��� �⮫�殢 
           out   dx,al
           pop   ax                ; ����⠭�������� ��� ��ப�
           inc   bx                ; ���室 � ᫥���饬� ����� �㪢� (�ᥣ� 7)
           Loop  M2
           inc   si                ; �������� �㪢� 䠬����
           pop   cx                ; ����⠭�������� ���稪 �㪢 䠬����
           inc   dx                ; ���室�� � ᫥���饩 �����
           Loop  M1
            
           Ret
In_Letter  EndP                    

;****************************************** ���� ��楤��� ********************************

StrError   Proc   Near             ; �뢮� ᮮ�饭�� �� �訡��( ��� ��� ����� �訡��)
           mov   cx,Length Error
           mov   bx,offset Error
           mov   dx,13h            ; � dx - ����� ��ࢮ�� ���� �뢮��
S1:
           mov   al,ds:[bx]
           out   dx,al
           dec   dx
           inc   bx
           Loop  S1
           
           ;*********
           Mov  al,0
           out  15h,al
           ;***********
           Ret
StrError   EndP

;*********************************************************************************
;** ��।���� ���஢���� �� 祫���� �� ���. ����.(���. �� ���. "����") **
;*********************************************************************************
Scan_Test1 Proc 
           mov bx, Offs_Name
           mov ax, word ptr Grup[bx].Test1
           mov dx, word ptr Grup[bx].Test1+2
           cmp ax,0
           jne LA 
           cmp dx,0
           jne LA
           Call Set_Start_Time 
           Mov H_Test1,1 
           Mov H_Test2,0        
           Call  Strategy_1
           jmp E1
LA:
           Mov Go_test,0
E1:
           Ret
Scan_Test1 Endp

;*********************************************************************************
;** ��।���� ���஢���� �� 祫���� �� ����. ����.(���. �� ���. "����") **
;*********************************************************************************
Scan_Test2 Proc            
           mov bx, Offs_Name
           mov ax, word ptr Grup[bx].Test2
           mov dx, word ptr Grup[bx].Test2+2
           cmp ax,0
           jne LA1 
           cmp dx,0
           jne LA1
           Mov H_Test2,1          
           Mov H_Test1,0
           Call Set_Start_Time 
           Call  Strategy_2
           jmp E2
LA1:
           Mov Go_test,0
E2:
           Ret
Scan_Test2 Endp

Set_Flag_For_Test1 Proc
           mov H_Test1,1
           mov H_Test2,0
           mov H_Sum  ,0
           Ret
Set_Flag_For_Test1 endP

Set_Flag_For_Test2 Proc
           mov H_Test2,1
           mov H_Test1,0
           mov H_Sum  ,0
           Ret
Set_Flag_For_Test2 endP

Set_Flag_For_RezSum Proc
           mov H_Sum  ,1
           mov H_Test2,0
           mov H_Test1,0           
           ;mov al,90h
           ;out 14h,al
           Ret
Set_Flag_For_RezSum endP

;********************************************************
;** ��।���� ����� �� ��⮢ ��࠭.(��� ����ﭮ) **
;********************************************************
Choose_Strategy  Proc  Near
           Cmp Power,1
           jne L12
           Cmp My_Test,1               ; ����� "����" ����祭
           jne L1
           in  al,StrategyPort
           cmp al, 0FBh                ; ��࠭ ��⢥��� ���
           jne L2
           Call Set_Start_Time
           Call Set_Flag_For_Test1
           mov al,64h
           out 14h,al
           jmp L5
   L2:
           Cmp al, 0F7h                ; ��࠭ �����⥫�� ���
           jne L5
           Call Set_Start_Time
           Call Set_Flag_For_Test2
           mov al,0A4h
           out 14h,al
           jmp L5
L12:
           jmp L5
L1:
           Cmp Rezult,1                ; ����� "��ᬮ�� १���⮢" ����祭
           jne L5
           cmp al, 0FBh                ; ��࠭ ०�� ��ᬮ�� "���⢥��� ���"
           jne L3
           Call Set_Flag_For_Test1
           mov al,54h
           out 14h,al                      
           ; �맮� ��楤��� ���஢�� ��� "���⢥��� ���", � ��⥬ ��ࠡ��稪� ������ ������樨 
           Call Set_Start_Time
           Cmp Col_Mas_1,0
           jne L5
           Call Clear_Buff_Name 
           mov al,0
           out 19h,al
           jmp L5
   L3:
           Cmp al, 0F7h                ; ��࠭ ०�� ��ᬮ�� "�����⥫�� ���"
           jne L4
           Call Set_Flag_For_Test2
           mov al,94h
           out 14h,al
           ; �맮� ��楤��� ���஢�� ��� "�����⥫�� ���", � ��⥬ ��ࠡ��稪� ������ ������樨
           Call Set_Start_Time
           Cmp Col_Mas_2,0
           jne L5
           Call Clear_Buff_Name 
           mov al,0
           out 19h,al
           jmp L5
   L4:
           Cmp al, 0EFh                ; ��࠭ ०�� ��ᬮ�� ��饣� १����
           jne L5
           mov al ,1Ch
           out 14h,al
           Call Set_Flag_For_RezSum
           Call Set_Start_Time
           Cmp Col_Mas_3,0
           jne L5
           Call Clear_Buff_Name 
           mov al,0
           out 19h,al
           ; �맮� ��楤��� ���஢�� ��� �㬬�୮�� १����, � ��⥬ ��ࠡ��稪� ������ ������樨
L5:
           Ret 
Choose_Strategy  EndP

;***************************************************************************
;** ��।���� ࠡ��� ��⢥����� ���.(�맮�. � ��ࠡ��稪� Scan_Test1) **
;***************************************************************************
Strategy_1   Proc  Near
           mov  al,  1
           mov  cx  ,4
R1:           
           Out 17h, al
           shl  al, 1
           push ax cx
           Call Delay            
           pop  cx ax
           Loop R1
           mov  al,  0   ; ��ᨬ �� �����窨
           Out  17h, al
           mov  Right_Dig, 0FDh          ; ���������� �᫮��� ��室� (�ਣ������ �᫨ ���⭨� �ମ�)
;R2:
;           ;�맮� ��楤��� ������� �६���
;           Call  L_Input
;           in   al, OperationPort        
;           Cmp  al, 0FDh                 ; ����� ������ "�⮯"           
;           jne R2
           Call Set_Time
           
           mov bx,Offs_Name
           mov al,Time[0]
           mov byte ptr Grup[bx].Test1+0,al
           mov al,Time[1]
           mov byte ptr Grup[bx].Test1+1,al
           mov al,Time[2]
           mov byte ptr Grup[bx].Test1+2,al
           mov al,Time[3]
           mov byte ptr Grup[bx].Test1+3,al
           
           ; ������ �६���
           ; ���樠������ ��砫��� ���祭��            
           Mov Go_Test,0
           ; ������ �६���
           ; ���樠������ ��砫��� ���祭��  
           mov cx,4
           mov bx, offset Time
R2:
           mov byte ptr ds:[bx],0
           inc bx
           Loop R2
           Call Rez_Delay 
           Call Set_Start_Time       
           Ret   
Strategy_1   EndP       

;****************************************************************************
;** �ந������ ������� �६���.(�맮�. ����ﭮ � ��ࠡ��稪� ����. ���) **
;****************************************************************************
Set_Time     Proc  Near
;------------------ ��������!!!!!! ����� ���� ������� �६���  ------------------------ ; 
T2:                                                       
           Call  L_Input                 ; ���ᮢ�� �����, � ᮦ������ �� �㦭� ������
           
           ; *********************
           mov  bx, offset Digit_s
           mov  si, offset Time
           mov  dx, 10h                  ; ���� ���� ��� ����ࠦ���� ����
           mov  Kol,0
   T3:           
           mov  al, ds:[si]
           inc  al
           AAA 
           Xor  ah,ah
           mov  di, ax
           mov  al, ds:[bx+di]
           out  dx, al
           mov  ax,di          
           mov  ds:[si], al
           cmp  kol,3
           jne  T5
           mov  al, Right_Dig            ; ��� �ࠢ��쭮� ������. ������ �� �� ��� �,�,�
           jmp  T6
   T5:       
           cmp  al, 0
           jne  T4
           inc  dx
           inc  si
           inc  Kol
           jmp  T3  
T4:                      
           ; ********************           
           in   al, ActionPort        
T6:
           Cmp  al, Right_Dig            ; �஢�ઠ ������ ᮮ⢥�����饩 ������  
           jne T2             
           Ret 
Set_Time     EndP

;*****************************************************************************
;** ��।���� ࠡ��� �����⥫쭮�� ���.(�맮�. � ��ࠡ��稪� Scan_Test2) **
;*****************************************************************************
Strategy_2   Proc  Near  
           mov  si,offs
           mov  al,ds:[si]
           and  al,3Fh
           
           Xor  cx,cx
           mov  cl,al
           mov  ax,offs                    ; �ᯮ��㥬 ��� ���⮪ 
T1:           
           mov  bx,343
           mul  bx
           mov  bx,55634
           div  bx
           mov  ax,dx
           push  ax cx
           Call  L_Input            
           pop   cx ax 
           Loop T1
           mov  offs,ax
           Xor  dx,dx
           mov  bx,5
           div  bx

                     
           Lea  bx, Digit_s              ; ����㧪� ��砫쭮�� ���� ���ᨢ� ��ࠧ�� ���
           add  bx,dx
           inc  bx                       ; �⮡� �� �뢮���� "0" 
           Mov  al, ds:[bx]              ; �뢮��� �� �᫮
           Out  15h,al 
           
           mov  al,0FBh
           mov  cx,dx
           Rol  al,cl
           mov  Right_Dig,al
           
           Call Set_Time
           
           mov  al,0
           Out  15h,al        
           Mov Go_Test,0
           ; ������ �६���
           
           mov bx,Offs_Name
           mov al,Time[0]
           mov byte ptr Grup[bx].Test2+0,al
           mov al,Time[1]
           mov byte ptr Grup[bx].Test2+1,al
           mov al,Time[2]
           mov byte ptr Grup[bx].Test2+2,al
           mov al,Time[3]
           mov byte ptr Grup[bx].Test2+3,al
           
           ; ���樠������ ��砫��� ���祭��  
           Mov Go_Test,0
           
           mov cx,4
           mov bx, offset Time
T7:
           mov byte ptr ds:[bx],0
           inc bx
           Loop T7       
           Call Rez_Delay 
           Call Set_Start_Time  
           
           Ret   
Strategy_2   EndP

;*********************************************************************************
;** ��९��뢠�� 䠬���� �� ���� � ᯨ᮪.(�맮�. ��᫥ ���. Scan_Name) **
;*********************************************************************************
Mov_Name     Proc
             mov cx, Length H_Name
             mov bx, offs_Name
             mov di, 0
             mov si, offset Buff_Name
B1:
             mov al, ds:[si]         
             mov Grup[bx].H_Name[di],al
             inc di
             inc si
             Loop B1
             Ret
Mov_Name     EndP

;***************************************************************************************
;** �ந������ �஢��� �� ࠭�� ������� 䠬����.(�맮�. ��᫥ ����� ������ "����") **
;***************************************************************************************
Scan_Name    Proc
             Cmp Col_Name,0             ; �᫨ 䠬���� � ᯨ᪥ ���, � �� �㦭� �᪠�� �㡫�
             je  M7
             Xor cx,cx
             Xor bx,bx
             Mov cl,Col_Name            ; ���� ��ᬠ�ਢ��� ���� ᯨ᮪
M3:
             mov  di, offset Buff_Name
             push cx
             Xor  si,si
             mov  cx, Length H_Name
M4:
             mov  al, ds:[di]
             cmp  al, Grup[bx].H_Name[si]
             jne  M5
             inc  si
             inc  di
             dec  cx
             jnz  M4
             Mov  Offs_Name,bx
             pop  cx                    ; �����뢠�� 㤠���� �� �⥪� � �� ��������  
             jmp  M6
M5:
             add  bx, Human_Rec
             pop  cx
             Loop M3
M7:
             Cmp  Col_Name,5
             je   M9
             Xor  ax,ax
             mov  al, Col_Name
             mov  bx, Human_Rec
             mul  bl
             mov  Offs_Name,ax
             Call Mov_Name
             inc  Col_Name                          
M6:          
             mov  dx, 18h                 ; �뢮��� ���-�� ���⭨��� �� �࠭ 
             Xor  ax, ax
             mov  al, Col_Name
             Call OutPut_Digit
             
             Cmp  H_Test1,1
             jne  M8
             Call Scan_Test1
             jmp  M9
M8:
             Cmp  H_Test2,1
             jne  M9
             Call Scan_Test2
M9:    
             Ret
Scan_Name    Endp

;**************************************************************
;** �ந������ �஢��� ����� ०�� ��࠭.(�맮�. ����ﭮ) **
;**************************************************************
Scan_Action Proc Near
           Cmp Power,1
           jne C2 
           in  al,StrategyPort 
           cmp  al, 0FEh         ; ����� ������ " �������� "
           jne  C1
           mov  al,14h           ; �������� ᢥ⮤��� 
           out  14h,al 
           mov  Rezult ,1        ; �����㥬 䫠��              
           mov  My_Test,0
           mov  H_Test1,0
           mov  H_Test2,0
           mov  H_Sum  ,0
           Call Set_Start_Time
           Call Clear_BuFF_Name
           Mov  Col_New_1,0
           Mov  Col_New_2,0
           Mov  Col_New_3,0
           Mov  Col_Mas_1,0
           Mov  Col_Mas_2,0
           Mov  Col_Mas_3,0
           Call FindRez
           jmp  C2
C1:        
           cmp al, 0FDh          ; ����� ������ "����"
           jne C2 
           mov al,24h  
           out 14h, al             
           mov Col,0
           mov al, 0
           out 19h, al
           Call Set_Start_Time
           Call Clear_BuFF_Name
           mov  My_Test,1        ; �����㥬 䫠��              
           mov  Rezult ,0
           mov  H_Test1,0
           mov  H_Test2,0
           ;Mov  Col_New_1,0
           ;Mov  Col_New_2,0
           ;Mov  Col_New_3,0
C2:
           Ret
Scan_Action EndP

;*************************************************************************
;** �ந������ �஢��� �� ����⨥ ������ "����".(��뢠���� ����ﭮ) **
;*************************************************************************
include anove.asm
include Init_Mem.asm
include My_Init.asm

Start_Test  Proc
           Cmp Power,1
           jne G2
           Cmp My_Test,1
           jne G2
           Cmp H_Test1,1
           jne G1
           in  al,ActionPort
           cmp al,0FEh
           jne G2
           cmp col,0
           je  G2
           Call Scan_Name
           ;Call Scan_Test1           
           jmp G2
G1:
           Cmp H_Test2,1
           jne G2
           in  al,ActionPort
           cmp al,0FEh
           jne G2
           cmp col,0
           je  G2
           ;Cmp Col_Name,5
           ;je  G2
           Call Scan_Name
           ;Call Scan_Test2           
G2:
           Ret            
Start_Test  EndP

Scan_Power Proc
           in al,04h
           Test al, 4h 
           jnz  XX2 
           mov Power,0 
XX2:
           Ret 
Scan_Power EndP

Begin:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;����� ࠧ��頥��� ��� �ணࠬ��          
My_Begin: 
           Call  Give_Power
           Call Out_Power        
           Call  Scan_Action     ; ��।������ ����� ��࠭ ०��: "���." ��� "����"
           Call  Choose_Strategy ; �஢�ઠ �롮� ���. ����⠥� 㬭� ⮫쪮, ����� My_Test=1 ��� Rezult=1    
           Call  Start_Test      ; �஢�ઠ ������ ������ "����"
           Call  Scan_Button_For_Test1
           Call  Scan_Button_For_Test2 
           Call  Scan_Button_For_Test3
           Call  Choose_Name
 
           Call  Clear_Name
           call  KbdInput        ; ����祭�� ���ᨢ� KbdImage (��ࠧ��)
           call  KbdInContr      ; ��ନ஢���� 䫠��� �訡�� ����� � ���⮩ ����������
           call  NxtDigTrf       ; ����祭�� ���� �㪢� (0...31) - ����� ���� �஬������
           Call  Print           ; ���������� ᯨ᪠ 䠬����, �����⥫쭮� ����祭�� ���� ����⮩ ������ ����������           

           Call  L_Input         ; �뢮� 䠬���� �� ���������, �ࠡ��뢠�� �᫨ COL > 0 (���� ��� �� ���� �㪢�)                        
           jmp   My_Begin
           

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           ;org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           ;jmp   Far Ptr Start
           org 17F0h               ; ������� ���⮢��
Start:jmp Far Ptr Begin            ; �窨, �ࠢ�����
                                   ; ��।����� ��
                                   ; ������� jmp

Code       ENDS
END Start
