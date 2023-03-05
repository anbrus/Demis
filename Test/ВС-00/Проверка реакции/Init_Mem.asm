Choose_Name  Proc
           Cmp Power,1
           jne TT3
           Cmp Rezult,1
           jne TT3
           Cmp H_Test1,1
           jne TT1
           Cmp Col_Mas_1,0
           je TT1  
           Call KbdInput_1 
           Cmp  EmpKbd, 0FFh
           je  TT3
           Call Scan_Kb_For_Test1
           jmp TT3
TT1:
           Cmp H_Test2,1
           jne TT2
           Cmp Col_Mas_2,0
           je TT2
           Call KbdInput_1 
           Cmp  EmpKbd, 0FFh
           je  TT3
           Call Scan_Kb_For_Test2
           jmp TT3        
TT2:
           Cmp H_Sum,1
           jne TT3
           Cmp Col_Mas_3,0
           je  TT3
           Call KbdInput_1 
           Cmp  EmpKbd, 0FFh
           je  TT3
           Call Scan_Kb_For_Test3 
TT3:
           Ret
Choose_Name  EndP

Scan_Kb_For_Test1 Proc
           mov al,NextDig
           Cmp al, Col_Mas_1
           ja  TT4
           mov si,Offset Mas_1
           Call Set_Offset
           Call Print_Rez
           mov al, NextDig
           ;inc al
           mov Col_New_1, al
TT4:
           Ret
Scan_Kb_For_Test1 EndP

Scan_Kb_For_Test2 Proc
           mov al,NextDig
           Cmp al, Col_Mas_2
           ja  TT5
           mov si,Offset Mas_2
           Call Set_Offset
           Call Print_Rez
           mov al, NextDig
           ;inc al
           mov Col_New_2, al
TT5:
           Ret
Scan_Kb_For_Test2 EndP

Scan_Kb_For_Test3 Proc
           mov al,NextDig
           Cmp al, Col_Mas_3
           ja  TT6
           mov si,Offset Mas_3
           Call Set_Offset
           Call Print_Rez
           mov al, NextDig
           ;inc al
           mov Col_New_3, al
TT6:
           Ret
Scan_Kb_For_Test3 EndP

Set_Offset  Proc
           Xor ax,ax
           mov al,NextDig            ; � dh - ᬥ饭�� ���� � ���ᨢ� Digit_S (�� 1 ����� ��⨭. ����)
           dec al
           mov cl,13
           mul cl
           add si,ax
           Ret
Set_Offset  EndP

KbdInput_1 PROC  NEAR
           lea   si,KbdImage_1       ;����㧪� ����,
           mov   bl,0EFh             ;� ����� ��室��� ��ப�
KIT4:      mov   al,bl       ;�롮� ��ப�
           out   KbdPort,al  ;��⨢��� ��ப�
           in    al,KbdPort  ;���� ��ப�
           cmp   al,0FFh
           jz    KIT1        ;���室, �᫨ ���
           mov   dx,KbdPort  ;��।�� ��ࠬ���
           
           mov   [si],al     ;������ ��ப�
KIT2:      in    al,KbdPort  ;���� ��ப�
           cmp   al,0FFh
           jnz   KIT2         ;���室, �᫨ ���        
         
           jmp   SHORT KIT3
KIT1:      mov   [si],al     ;������ ��ப�
KIT3:     
           Call KbdInContr_1
           Call NxtDigTrf_1
           ret
KbdInput_1 ENDP


KbdInContr_1 PROC  NEAR
           lea   bx,KbdImage_1 ;����㧪� ����
           mov   EmpKbd,0      ;���⪠ 䫠���
           mov   KbdErr,0
           Xor   dx,dx         ;� ������⥫�
KIM2:      
           mov   al,ds:[bx]
           cmp   al,0FFh      
           jne   KIM1
           inc   dl          
           jmp   KIM0
KIM1:
           mov   Letter,al
KIM0:
           cmp   dl,1        ;������⥫�=1?
           jne    KIM4        ;���室, �᫨ ��           
           mov   EmpKbd,0FFh ;��⠭���� 䫠�� ���⮩ ����������
KIM4:
           ret               ;�᫨ dl=0 ����� ��� ��ଠ�쭮
KbdInContr_1 ENDP

NxtDigTrf_1 PROC  NEAR
           cmp   EmpKbd,0FFh  ;����� ���������?
           jz    ND1          ;���室, �᫨ ��
           lea   bx,KbdImage  ;����㧪� ����
           Xor   dx,dx        ;���⪠ ������⥫�� ���� ��ப� � �⮫��           
           mov   al,Letter    ;����㧪� ॠ�쭮�� ���� �㪢� 
           CLC
ND2:      
           Rol   al,1         ;�뤥����� 0, � dh - ����� �㪢� ���������� 
           inc   dh           ;᫥�� �� �ࠢ� 1,2,3,...,32
           jc    ND2
           ;dec   dh           ;㬥��蠥� �� 1 (0,1,2,...,31)         
            
           mov   NextDig,dh  ;������ ������஢����� ���� ����
ND1:      
           ret
NxtDigTrf_1 ENDP