RomSize    EQU   4096

Data  SEGMENT at 40H use16
                  ;���������� ��� ���������� ��
  F_0 DW ?                     ;��砫쭠� ����
  F_s DW ?                     ;�������쭠� ����
  F_n DW ?                     ;����᭠� ����
  A_w_Start DD ?               ;�������� �᪮७�� ࠧ����
  A_w_Brake DD ?               ;�������� �᪮७�� �ମ�����
  A_r_Start DD ?               ;ॠ�쭮� �᪮७�� ࠧ����
  A_r_Brake DD ?               ;ॠ�쭮� �᪮७�� �ମ�����
  Por_fs DW ?                  ;��ண �ய�饭��� 蠣��
  Pulse DD  ?                  ;���ᨬ��쭮� ������⢮ �����ᮢ �� �������쭮� ����
                  ;����������                           
  KbdImage DB 2 DUP (?)        ;��ࠧ ���������� ������
  Curr_Digit DB ?              ;⥪��� ������ ������ (���)    
  Button_Fl DB ?               ;�ਭ���� 2 ���祭�� Mul_Btn_Push - ��९������� ��ண� 0-����� ���� ������
  Buffer  DD ?                 ;���ﭨ� �� ��࠭� (�� ⠡�� ⥪�饣� ���࠭���� ���祭��)
  Out_AddrPort DW ?            ;��� ��楤��� �뢮�� ���祭�� (���� ���� ����襩 ����)
  Count_Push_Btn DB ?          ;��� ॣ����樨 ������ ������ � ࠡ�祬 横�� ࠡ��� ��
  Temp DD ?                    ;�६����� ��६�����
  Pulse_In_Kvant DW ?          ;⥪�饥 �᫮ �����ᮢ � ��ਮ� ����⨧�樨 
  Cur_Pulse DD ?               ;⥪�饥 ������⢮ �����ᮢ �� �������쭮� ����
  Fail_Step DB ?               ;ॣ����樨 ������ ������ ������� ���� �� �६� ࠡ��� ��
  Mode DB ?                    ;०�� ࠡ��� �� (������, ����, ���������) 
  F_n_w DD ?                   ;���祭�� ����� �������� (wished) �� 蠣� n
  F_n_r DD ?                   ;���祭�� ����� ��������� (real) �� 蠣� n
  a_w_s DD ?                   ;���祭�� F_n_w - F_n-1_w (�� ࠧ����)
  a_w_b DD ?                   ;���祭�� F_n_w - F_n-1_w (�� �ମ�����)
  a_r_s DD ?                   ;���祭�� F_n_r - F_n-1_r (�� ࠧ�.)  
  a_r_b DD ?                   ;���祭�� F_n_r - F_n-1_r (�� �ମ�����)    
  Failed_Steps DW ?            ;������⢮ �ய. 蠣��
  Type_ DB ?                   ;०�� ࠡ���  ࠧ���, 室, �ମ�.
  Push_Fail_Step DB ?          ;��� ॠ��஢���� �� ������ ����. ���� �� �⦠��
  OutReg DB ?
                  ;���������� ��� ����������� ����������� ���������� (�����. ������ ��)      
  N_Reg_Out DB ?               ;����� ��⨢���� ���� �뢮�� �� 
  SM_Cond DW ?                 ;���ﭨ� �� (��� �⮡ࠦ���� 1-�� ���. ����. �१ 5 ॠ����) 
  Reg_Out_Cond DB ?            ;���ﭨ� ��⨢���� ���� �뢮�� ��
Data       ENDS
 
Code       SEGMENT use16
Type_razgon = 00000000b            ;⨯ �������� ࠧ���
Type_hod = 00001111b               ;⨯ �������� 室 
Type_brake = 11111111b             ;⨯ �������� �ମ�����
 
Mode_Go = 11111111b                ;०�� ࠡ��� - �����
Mode_Idle = 00001111b              ;०�� ࠡ��� - ���⮩  
Mode_Stop = 00000000b              ;०�� ࠡ��� - �⮯ 
 
Pressision = 10000                 ;�筮���
Max_Pulse_In_Kvant = 500           ;���ᨬ��쭮� �᫮ �����ᮢ � ��ਮ� ����⨧�樨 
Mul_Btn_Push = 0FFh                ;���祭�� Curr_Digit - ����� ����� ����� ������
Out_Porog = Mul_Btn_Push           ;�᫨ ���祭�� ��諮 �� �।���
No_Btn_Push = 0FEh                 ;���祭�� Curr_Digit - �� ����� �� ����� ������
N_Drebezg = 50                     ;������⢮ 横��� �஢�ન �� �ॡ����

                                 ;��ண���� ���祭�� ���. ��ࠬ��஢   
Por_F_S=10000                      ;
Half_Por_F_S=500                   ;��� ��������
Por_A_Start_2=1001011010000000b    ; - ��ண��� 
Por_A_Start_1=10011000b            ; -
Por_M_tr = 1000                    ; -
Por_Por_fs = 100                   ; - ���祭��       

Por_Pulse_1= 1111b                 ; - ����� ����
Por_Pulse_2=0100001001000000b      ; - ������ ���� ��ண����� ���祭��


;;;;;;;;;;;;;;;;;�����
Port_Curr_Fraquency = 60h
Port_Failed_Steps = 50h


          ASSUME cs:Code,ds:Data,es:Data
Image  db  03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh,06Fh    ;��ࠧ� 10-����� ᨬ�����

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;���稠������ ��ࠬ��஢ ��, ०��� ࠡ���, ��ࢮ��砫��� ���祭��
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Init Near
   Mov F_0 , 0
   Mov F_s , 2500
   Mov F_n , 0
   Mov Word Ptr A_w_Start , 9000
   Mov Word Ptr A_w_Start+2 , 0
   Mov Word Ptr A_w_Brake , 9000
   Mov Word Ptr A_w_Brake+2 , 0
   Mov Word Ptr A_r_Start , 9000
   Mov Word Ptr A_r_Start+2 , 0
   Mov Word Ptr A_r_Brake , 9000
   Mov Word Ptr A_r_Brake+2 , 0
   Mov Por_fs , 100  
   Mov Word Ptr Pulse , 10011100010000b    ;10000d
   Mov Word Ptr Pulse+2 , 0   
   Mov Mode , 00001111b                    ;०�� ࠡ��� - ��ଠ���
   Mov Word Ptr Buffer , 0
   Mov Word Ptr Buffer+2 , 0
   Mov N_Reg_Out ,  51                     ;����訩 ���� �뢮��
   Mov Reg_Out_Cond , 1                   ;���� ��� ���ﭨ� = nill
   Mov SM_Cond , 0                         ;⠪�� ��� � ���ﭨ� ��   
   Ret
EndP Init

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;������� ��������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VibrDestr  PROC  NEAR
           Push BX
           Push AX
VD1:       mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
           mov   bh,0        ;���� ����稪� ����७��
VD2:       in    al,dx       ;���� ⥪�饣� ���ﭨ�
           cmp   ah,al       ;����饥 ���ﭨ�=��室����?
           jne   VD1         ;���室, �᫨ ���
           inc   bh          ;���६��� ����稪� ����७��
           cmp   bh,N_Drebezg;����� �ॡ����?
           jne   VD2         ;���室, �᫨ ���
           mov   al,ah       ;����⠭������� ���⮯�������� ������          
           Pop AX
           Pop BX          
           ret 
VibrDestr  ENDP
           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;�������� ����� ����������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
KbdInput   PROC  NEAR
           Push SI
           Push CX
           Push BX
           Push AX
           Push DX
            
           lea   si , KbdImage         ;����㧪� ����,
           mov   cx , LENGTH KbdImage  ;����稪� 横���
           mov   bl , 00000001b             ;� ����� ��室��� ��ப�
KI4:       mov   al , bl       ;�롮� ��ப�          
           out   35h , al      ;��⨢��� ��ப�
           in    al , 0h       ;���� ��ப�
           and   al , 00011111b         ;����祭�? 
           cmp   al , 0
           jz    KI1         ;���室, �᫨ ���
           mov   dx , 0h     ;��।�� ��ࠬ���
           call  VibrDestr   ;��襭�� �ॡ����
           mov   [si] , al    ;������ ��ப�
KI2:
           in    al , 0h  ;���� ��ப�
           and   al , 00011111b      ;�몫�祭�?
           cmp   al , 0
           jnz   KI2         ;���室, �᫨ ���
           call  VibrDestr   ;��襭�� �ॡ����
           jmp   SHORT KI3
KI1:
           mov   [si],al     ;������ ��ப�
KI3:       inc   si          ;����䨪��� ����
           rol   bl,1        ;� ����� ��ப�
           loop  KI4         ;�� ��ப�? ���室, �᫨ ���
           
           Pop DX
           Pop AX
           Pop BX
           Pop CX
           Pop SI
           ret
KbdInput   ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;�������� ������� ��������� ����������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetCurrentDigit PROC NEAR        
            Push BX
            Push CX
            Push AX                                                            
            Push DX
            
            Mov Curr_Digit , No_Btn_Push           ;�ਧ��� �������� ����������  0FFh             
            Lea BX,KbdImage            
            Mov DL , 0
            Mov AX , Word Ptr [BX]                 ;�����뢠�� ᫮�� ��ࠧ� �����
            Mov CX , 16 
 Mul_Bth_Push:       
            Shr AX , 1
            Adc DL , 0              
            Loop  Mul_Bth_Push                      ;��᫥ 横�� � Curr_Digit - �᫮ ��� ࠧ�冷�
            Cmp DL , 0
            Je Exit_GetCurrentDigit 
            Cmp DL , 1
            JE No_We_Push_Mul_Bth
            Mov Curr_Digit , Mul_Btn_Push           ;�ਧ��� ������ ��᪮�쪨� ������   
            Mov CX , 8
            Mov DX , 36h
            Call ClrSigns
            Call ShowError                          ;�뢮��� ᮮ�� �� �訡��
            Jmp Exit_GetCurrentDigit             
 No_We_Push_Mul_Bth:
            Mov CX , 2                              ;�᫮ ��ப              
 Study_Line: 
            Mov AL , [BX]                           ;��᫥�㥬�� ��ப�
            Cmp AL , 00000000b                      ;���祭�� 00000000b - �� ���� ������ �� �����
            Jne Line_Not_Empty                      ;���室, �᫨ �� ����� ������                           
            Inc BX                                  ;��ᬠ�ਢ��� ᫥������ ��ப� 
            Loop Study_Line       
            Jmp Exit_GetCurrentDigit                ;��ࠡ�⪠ �� ������⮩ ��������� �����祭�
 Line_Not_Empty:                                     ;[BX] - ���� ��ப� � ���ன ��-� ���� (��-� ������)                           
            Sub BX,Offset KbdImage                  ;� BX - ��ப� : 0 , 1    
            Mov AH,0                                ;����� ࠧ�鸞         
 Find_Unit:  Shr AL,1                               ;ᤢ�� 
            Jc We_Find_Unit
            Inc AH                    
            Jmp Find_Unit
 We_Find_Unit:
            Mov Curr_Digit , AH                      ;��࠭塞 ����� �⮫��  
            Mov AL , 5                               ;�᫮ �⮫�殢 (�⮫��� ���. � 0)
            Mul BL                                   ;㬭����� 5 �� ����� ��ப� (��ப� ���. � 0)
            Add Curr_Digit , AL                      ;����� ����� ����� ����� 
 Exit_GetCurrentDigit :      
 
            Pop DX   
            Pop AX
            Pop CX 
            Pop BX 
            Ret
GetCurrentDigit ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;��C��������� ���. ���. ����� (���� � �����, ���� ����������� ���������)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc DecodeCurrentDigit Near    
           Push SI
           Push DI
           Push AX                         
           Push CX
           Push BX 
                            
           Cmp Curr_Digit , 9
           JA End_DecodeCurrentDigit        ;�᫨ ����� �� ��� (0-9)
           Mov DX , Word Ptr Buffer+2 
           Mov AX , Word Ptr Buffer
           Mov DI , 10011000b               ;�����뢠�� �᫮ 9999999
           Mov SI , 1001011001111111b       
           Call CompareDD                   ;�ࠢ������ ����� � 9999999
           Cmp BX , 0                       
           Je Not_out_Por                   ;�᫨ �� �����, � �� ��諨 �� ��ண
           Jmp  End_DecodeCurrentDigit   
 Not_out_Por:           
           Mov AX , Word Ptr Buffer        
           Mov CX , 10                          
           Mul CX                          ;㬭����� ������� ���� �� 10 
           Mov Word Ptr Buffer , AX        
           Mov AX , Word Ptr Buffer+2
           Mov Word Ptr Buffer+2 , DX      ;�᫨ ������ ���� ��諠 �� ���� ����, � ��⮬ �� ��⥬           
           Mul CX                          ;㬭����� ������ ���� �� 10                        
           Add AX , Word Ptr Buffer+2      ;�᫨ �� ��७�� �� ���襩 ���
           Mov Word Ptr Buffer+2 , AX
           Mov AL , Curr_Digit
           Mov AH , 0
           Add Word Ptr Buffer , AX
           Adc Word Ptr Buffer+2 , 0                                                   
 End_DecodeCurrentDigit:   
    
            Pop BX
            Pop CX
            Pop AX  
            Pop DI
            Pop SI            
           Ret           
EndP DecodeCurrentDigit 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;����������� ��������������� ��������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Assign_Values NEAR
         
          Cmp Curr_Digit , Mul_Btn_Push           
          Jne E_2
          Jmp End_Assign_Values
  E_2:        
          Mov DX , 5         ;��।�� ��ࠬ��஢
          Call VibrDestr     ;��襭�� �ॡ����
          In AL , DX
          And AL , 00011111b ;� 5 ॣ �ᥣ� 5 ������
          Mov AH , AL
          Mov DX , 1         ;��।�� ��ࠬ��஢
          Call VibrDestr     ;��襭�� �ॡ����
          In AL , DX         ;�.� ����� AH-��ࠧ 5 ॣ. �����, AL-��ࠧ 1 ॣ. �����  
          Mov BP , AX        
          
          Mov CX , 13    
          Mov DL , 0
      Is_One_Bth_Pushe:              
          Shr AX , 1
          Adc DL , 0 
          Loop Is_One_Bth_Pushe    ;� DL - ������⢮ ������ �������                    
          Mov Count_Push_Btn ,  DL
          
          Cmp Count_Push_Btn  , 0               
          Jne E_3                   ;�᫨ �� ���� ������ �� ����� � ��室 �� ���.          
          Jmp End_Assign_Values 
       E_3:                              
                            ;��ᬮ� ����
          Shr BP , 1
          Jnc Not_Sbros            ;���室 �᫨ �� ���
          Cmp Count_Push_Btn , 1         
          Je Sbros_Ok              ;�᫨ �뫠 ���� ������ �����
       
          Mov CX , 8 
          Mov DX , 36h          
          Call ClrSigns            ;��頥� ���������  
          Call ShowError           ;�뢮��� ᮮ�� �� �訡��
          Mov Button_Fl , Mul_Btn_Push     ;�訡�� ���� ��������� ���祭�� �� ���� (� Show_All_Values )
          Jmp  Not_Sbros           ;��� ��ᬮ�� ��� ������ �� �।��� �訡��       
  Sbros_Ok:
          Mov Word Ptr Buffer, 0
          Mov Word Ptr Buffer+2 , 0 
          Mov Button_Fl, No_Btn_Push        ;�訡�� ��� ��������� ���祭�� ���� (� Show_All_Values )   
          Jmp End_Assign_Values             
  Not_Sbros:   
                                                  ;��ᬮ� F_0
          Mov Out_AddrPort , 0h
          Mov SI , Por_F_S
          Mov DI , 0      
          Mov CX , 5              
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je  No_F_0
          Mov AX, Word Ptr Temp 
          Mov F_0 , AX
  No_F_0:                                       ;��ᬮ� F_s                        
          Mov Out_AddrPort , 5h
          Mov SI , Por_F_S
          Mov DI , 0        
          Mov CX , 5            
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je  No_F_s
          Mov AX, Word Ptr Temp 
          Mov F_s , AX
  No_F_s:                                    ;��ᬮ� F_n                
          Mov Out_AddrPort , 41h
          Mov SI , Por_F_S
          Mov DI , 0          
          Mov CX , 5                    
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je  No_F_N
          Mov AX, Word Ptr Temp 
          Mov F_N , AX
  No_F_N:                                   ;��ᬮ� A_w_Start                
          Mov Out_AddrPort , 0Ah
          Mov SI , Por_A_Start_2
          Mov DI , Por_A_Start_1
          Mov CX , 8                                        
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je No_A_w_Start 
          Mov AX, Word Ptr Temp 
          Mov Word Ptr A_w_Start , AX
          Mov AX, Word Ptr Temp+2 
          Mov Word Ptr A_w_Start+2 , AX      
 No_A_w_Start:                              ;��ᬮ� A_w_Brake
          Mov Out_AddrPort , 12h
          Mov SI , Por_A_Start_2
          Mov DI , Por_A_Start_1          
          Mov CX , 8                              
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je No_A_w_Brake 
          Mov AX, Word Ptr Temp 
          Mov Word Ptr A_w_Brake , AX
          Mov AX, Word Ptr Temp+2 
          Mov Word Ptr A_w_Brake+2 , AX
 No_A_w_Brake:                             ;��ᬮ� A_r_Start 
          Mov Out_AddrPort , 1Ah
          Mov SI , Por_A_Start_2
          Mov DI , Por_A_Start_1          
          Mov CX , 8                              
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je No_A_r_Start 
          Mov AX, Word Ptr Temp 
          Mov Word Ptr A_r_Start , AX
          Mov AX, Word Ptr Temp+2 
          Mov Word Ptr A_r_Start+2 , AX
 No_A_r_Start:                             ;��ᬮ� A_r_Brake
          Mov Out_AddrPort , 22h
          Mov SI , Por_A_Start_2
          Mov DI , Por_A_Start_1          
          Mov CX , 8                    
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je  No_A_r_Brake         
          Mov AX, Word Ptr Temp 
          Mov Word Ptr A_r_Brake , AX
          Mov AX, Word Ptr Temp+2 
          Mov Word Ptr A_r_Brake+2 , AX
 No_A_r_Brake:                             ;��ᬮ� por_fs 
          Mov Out_AddrPort , 3Eh
          Mov SI , Por_Por_fs
          Mov DI , 0          
          Mov CX , 3          
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je  No_Por_fs
          Mov AX, Word Ptr Temp 
          Mov Por_fs , AX
 No_Por_fs:                               ;��ᬮ� Pulse
          Mov Out_AddrPort , 2Ah
          Mov SI , Por_pulse_2
          Mov DI , Por_Pulse_1
          Mov CX , 7          
          Call Assign_Value 
          Cmp Word Ptr Temp+2 , 0FF00h
          Je  No_Pulse         
          Mov AX, Word Ptr Temp 
          Mov Word Ptr Pulse , AX
          Mov AX, Word Ptr Temp+2 
          Mov Word Ptr Pulse+2 , AX
 No_Pulse:                                ;�஢�ઠ �� �����    
          Shr BP , 1
          Jnc End_Assign_Values
          Cmp Count_Push_Btn , 1       ;�뫮 �� ����� ��� ������
          Ja End_Assign_Values        ;�᫨ �뫠 �� ���� ������ �����       
          Mov Mode , Mode_Go           ;��⠭�������� ०�� - ࠡ�⠥� 
          Call Engine_Work         
          Mov Mode , Mode_Idle         ;��⠭�������� ०�� - ��ଠ�쭮                        
 End_Assign_Values: 
          Ret
EndP Assign_Values

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CX - �᫮ ��� DX - ���� �뢮�� ����. DI,SI - ��ண :
;�᫨ �� ���﫮�� , � Word Ptr Temp+2 = 0FF00h 
;��. ���祭�� Button_Fl -�᫨ ��諨 �� �।���
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Assign_Value Near  
          Mov Word Ptr Temp+2 , 0FF00h
          Shr BP , 1               ;BP - ���ﭨ� ॣ���஢ (� �� ��⠫��� � ����ﭭ� ᤢ�����) 
          Jnc K_1              
          Cmp Count_Push_Btn , 1   ;�뫮 �� ����� ��� ������
          Je K_2                   ;�᫨ �뫠 ���� ������ �����       
  K_3:
          Mov DX , Out_AddrPort
          Call ClrSigns            ;��頥� ���������  
          Call ShowError           ;�뢮��� ᮮ�� �� �訡��
          Mov Button_Fl, Out_Porog ;�訡�� ���� ��������� ���祭�� �� ���� (� Show_All_Values )          
          Jmp K_1                  ;��� ��ᬮ�� ��� ������ �� �।��� �訡�� 
  K_2:
          Mov AX , Word Ptr Buffer
          Mov DX , Word Ptr Buffer+2
          Call CompareDD
          Cmp BX , 11111111b
          Je  K_4                
          Mov Button_Fl, No_Btn_Push       ;�訡�� ��� ��������� ���祭�� ���� (� Show_All_Values )
          Mov AX , Word Ptr Buffer 
          Mov Word Ptr Temp , AX                     
          Mov AX , Word Ptr Buffer+2 
          Mov Word Ptr Temp +2, AX                              
          Jmp End_Assign_Values
K_4:      Mov Word Ptr Temp, 0                     
          Mov Word Ptr Temp+2, 0                              
          Jmp K_3
  K_1:    
                    
          Ret
EndP Assign_Value


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;������� ��������� Err �� ����� ������� � ����� DX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc ShowError NEAR   
     Mov AL , 6Fh  ;�뢮� r
     Out DX , AL
     Inc DX 
     Mov AL , 6Fh  ;�뢮� r
     Out DX , AL
     Inc DX  
     Mov AL , 073h  ;�뢮� E
     Out DX , AL   
     Ret
EndP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;������� CX ����������� � ����� DX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc ClrSigns Near
     Push DX    
     Mov AL , 03Fh
 Turn_Of_Signs:                                     ;��ᨬ �� ⠡��       
     Out DX , AL
     Inc DX        
     Loop Turn_Of_Signs   
     Pop DX
     Ret
EndP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;����� �� �������������� ���������� ���� ���������� ����������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Show_All_Values NEAR  
   Cmp Curr_Digit,  Mul_Btn_Push 
   Jne G_1  ;�訡�� ���� ��������� ���祭�� �� ����  (����� ��� ������)
   Jmp End_Show_All_Values
  G_1:
                ;�뢮� ���� �� �࠭
    Mov AX , Word Ptr Buffer       
    Mov DX , Word Ptr Buffer+2
    Mov SI , 10000
    Div SI  
    Mov CX , 4
    Mov Out_AddrPort , 3Ah   
    Call Out_Digits                 ;�뢮��� ��. ����
   
    Mov AX,DX    
    Mov Out_AddrPort , 36h
    Call Out_Digits                 ;�뢮��� ������� ����

    Cmp Button_Fl , Out_Porog 
    Jne G_2                          ;�訡�� ���� ��������� ���祭�� �� ���� (����� ��� ������ ��� ��ॡ��)
    Jmp End_Show_All_Values
    G_2:

                ;�뢮� �� ᥬ�ᥣ����� ��������� ���祭�� F_0 
    Mov AX , F_0       
    Mov CX , 5
    Mov Out_AddrPort , 0 
    Call Out_Digits
                ;�뢮� �� ᥬ�ᥣ����� ��������� ���祭�� F_S 
    Mov AX , F_S                
    Mov CX , 5
    Mov Out_AddrPort , 5
    Call Out_Digits
                ;�뢮� �� ᥬ�ᥣ����� ��������� ���祭�� F_N 
    Mov AX , F_N                
    Mov CX , 5
    Mov Out_AddrPort , 41h
    Call Out_Digits    
                ;�뢮� �� ᥬ�ᥣ����� ��������� ���祭�� A_w_Start 
    Mov AX , Word Ptr A_w_Start
    Mov DX , Word Ptr A_w_Start+2
    Mov SI , 10000d
    Div SI  
    Mov CX , 4
    Mov Out_AddrPort , 0Eh
    Call Out_Digits
    
    Mov AX,DX    
    Mov Out_AddrPort , 0Ah
    Call Out_Digits     
                ;�뢮� �� ᥬ�ᥣ����� ��������� ���祭�� A_w_Brake     
    Mov AX , Word Ptr A_w_Brake
    Mov DX , Word Ptr A_w_Brake+2
    Mov SI , 10000d
    Div SI  
    Mov CX , 4
    Mov Out_AddrPort , 16h
    Call Out_Digits
    
    Mov AX,DX    
    Mov Out_AddrPort , 12h
    Call Out_Digits     
                ;�뢮� �� ᥬ�ᥣ����� ��������� ���祭�� A_r_Start 
    Mov AX , Word Ptr A_r_Start
    Mov DX , Word Ptr A_r_Start+2
    Mov SI , 10000d
    Div SI  
    Mov CX , 4
    Mov Out_AddrPort , 1Eh
    Call Out_Digits
    
    Mov AX,DX    
    Mov Out_AddrPort , 1Ah
    Call Out_Digits         
                ;�뢮� �� ᥬ�ᥣ����� ��������� ���祭�� A_r_Brake     
    Mov AX , Word Ptr A_r_Brake
    Mov DX , Word Ptr A_r_Brake+2
    Mov SI , 10000d
    Div SI  
    Mov CX , 4
    Mov Out_AddrPort , 26h
    Call Out_Digits
    
    Mov AX,DX    
    Mov Out_AddrPort , 22h
    Call Out_Digits   
                ;�뢮� �� ᥬ�ᥣ����� ��������� ���祭�� Por_FailedSteps     
    Mov AX , Por_fs         
    Mov CX , 3
    Mov Out_AddrPort , 3Eh
    Call Out_Digits   
                 ;�뢮� �� ᥬ�ᥣ����� ��������� ���祭�� Pulse 
    Mov AX , Word Ptr Pulse
    Mov DX , Word Ptr Pulse+2
    Mov SI , 10000d
    Div SI  
    Mov CX , 3
    Mov Out_AddrPort , 2Eh
    Call Out_Digits
    
    Mov AX,DX    
    Mov CX , 4
    Mov Out_AddrPort , 2Ah
    Call Out_Digits     
  End_Show_All_Values:   
    Ret
EndP Show_All_Values  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;�뢮� �� ᥬ�ᥣ����� ��������� ���祭�� AX 
;�室�. ��ࠬ����
; �� - �᫮ 
; Out_WithDot - 䫠� c �窮� ��� ���  
; �� - ������⢮ ������� ��� (���� ���)
; Out_AddrPort - ���� ⥪. ���� �뢮��  (���砫� ᠬ� ����訩)
;����� ���������� ���������� = 166+��*232 ⠪⮢
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Out_Digits
     Push BX            ;(11)   
     Push DI            ;(11)   
     Push SI            ;(11)   
     Push DX            ;(11)   
     Push AX            ;(11)   
     Push CX            ;(11)   
     Push DS            ;(11)   
 
     Mov DX , Code      ;(15)  
     Mov DS , DX        ;(2)��� ���饭�� � Image �१ Xlat (Image � CS)
     Lea BX , Image     ;(8)
     Mov DX , 0         ;(4)
     Mov SI , 10d       ;(4) ����⥫�
 Out_Digits_L:          ;�뤥����� ᠬ�� ����� ���� � �뢮� �� ���������
      Div SI            ;(150) �����
      Mov DI , AX       ;(2)��࠭塞 ��⭮� 
      Mov AX , DX       ;(2)⠪� ��� �뢮��� ���⮪
      Mov DX , ES:Out_AddrPort; (15) � DX - ����� ����  
      Xlat              ;(11)�८�ࠧ��뢠�� � ���� ��� ᥬ�ᥣ���⭮�� �����     
      Out DX , AL       ;(8)�뢮���  
      Inc ES:Out_AddrPort ; (21)���室 � ᫥� �����
      Mov AX , DI       ;(2)����⮭�������� ��⭮� 
      Mov DX , 0        ;(4)��� �ࠢ ��. ����樨
   Loop Out_Digits_L
   Xlat                 ;(11)�뢮� ᠬ�� ���襩 ����

   Pop DS               ;(8)
   Pop CX               ;(8)
   Pop AX               ;(8)
   Pop DX               ;(8)
   Pop SI               ;(8)
   Pop DI               ;(8)
   Pop BX               ;(8)
   Ret                  ;(8)   
EndP Out_Digits

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ������ ���������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc  Engine_Work NEAR
      Call Init_Engine  ;���樠������ ��ࠬ��஢      
       
              ; �������� ����
L_Engine_Work:                          ;(253679 ⠪⮢)
        ; �⮡ࠦ��� ⥪���� �����
      Mov CX , 5                     ;(4)
      Mov AX ,Word Ptr F_n_w+2       ;(10) 
      Mov Out_AddrPort , Port_Curr_Fraquency ;(16) 
      Call Out_Digits                ;(881=166+232*3+19)

      Cmp Mode , Mode_Go                ;(16 = 10+6)�믮��塞 横� ���� �����⥫� ࠡ�⠥� 
      Jne L_Stop                        ;(4 - �᫨ �� ���室��, � ࠡ�⠥� �����⥫�)
      Jmp Begin_Failed_Steps            ;(15)  
    L_Stop:       
      Jmp L_Engine_Stop              

              ; ��������� �������� ����������� �����
 Begin_Failed_Steps:              ;(��  End_Failed_Steps - 208+528 ⠪⮢   )
      Mov CX , Word Ptr F_n_w+2         ;(15)
      Mov AX , Word Ptr F_n_r+2         ;(15)
      Mov Word Ptr F_n_w+2 , AX         ;(14)
      Call Determ_Count_Pulse           ;(248)��।������ �ᥣ� �����ᮢ �� ��ਮ� ����⨧�樨   
      Mov DI , AX                       ;(2)ॠ�쭮� �����. �����ᮢ � ���. ����⨧
      
      Mov Word Ptr F_n_w+2 , CX         ;(14)
      Call Determ_Count_Pulse           ;(248)
      Mov DX , AX                       ;(2)�������� �����. �����ᮢ � ��ਮ� �����.
      
      Mov DX , DI                 
      Mov DI , AX 
      Mov AX , 0                        ;(10) 
      Mov SI , 0                        ;(15 = 9+6)

      
      Mov DX , Word Ptr F_n_r+2        ;(15 = 9+6)��।�� ��ࠬ��஢
      Mov AX , Word Ptr F_n_r          ;(10) 
      Mov DI , Word Ptr F_n_w+2        ;(15 = 9+6)
      Mov SI , Word Ptr F_n_w          ;(15 = 9+6)
      Call CompareDD                   ;(79=60+19)�ࠢ����� F_n_r>F_n_w (�᫨ �� BX-255 �᫨ ��� � 0)                                   ;(��  End_Failed_Steps - 74 ⠪�  )
                                   
      Cmp Type_ , Type_Brake           ;(16 = 10 +6)�஢�ઠ �� �ମ����� 
      Jne Not_Type_Brake               ;(4)�᫨ �� �ମ�����
                                       ;(+0 - ���室� �� �뫮)        
      Mov AL , Curr_Digit              ;(10) - ��ࠢ������
      Mov AL , AL                      ;(2)  - �६� �믮������ (�ꥤ��� ���室)                                                               
      Mov DI , Word Ptr a_r_b+2
      Mov DX , Word Ptr a_w_b+2
      Cmp DX , DI                       ;(4)���� (�.�. �ମ�����), 
      JB End_2                         ;(4)�᫨ F_n_r <= F_n_w  
                                       ;(+0- ���室� �� �뫮)
      Sub DX , DI                      ;(3)���� ����塞 ࠧ�����  
      
      Add Failed_Steps , DX            ;(16)᪫���뢠�� 㦥 ��������� ࠧ���� � ⥪����        
      Jmp End_Failed_Steps             ;(15) 
  Not_Type_Brake:                      ;(+12- ���室 ��)�᫨ ⨯ - 室 ��� ࠧ��� 
      Cmp BX , 11111111b               ;(4)             
      JE End_1                         ;(4)�᫨ F_n_r>F_n_w, � ��室 �� �����  
                                       ;(+0 - ���室� �� �뫮)
      Sub DI , DX                      ;(3)���� (F_n_r<=F_n_w) ����塞 ࠧ�����               
      Add Failed_Steps , DI            ;(16)᪫���뢠�� 㦥 ��������� ࠧ���� � ⥪����        
      Jmp End_Failed_Steps             ;(15)
  End_1:                               ;(+12- ���室 ��)
      Add AL , AL                      ;(3) - ��ࠢ������
      Add Al , Curr_Digit              ;(4) - �६� �믮������ 
      Jmp End_Failed_Steps             ;(15)
  End_2:                               ;(+12- ���室 ��) 
      Add AL , AL                      ;(3) - ��ࠢ������
      Add Al , Curr_Digit              ;(4) - �६� �믮������ 
      Jmp End_Failed_Steps             ;(15)      
 End_Failed_Steps:  
    
 
             ; ��������� �� ����� Failed_Steps �� ���. ������� (Por_Por_fs) 
                                                 ;(�� All_Pulse_End - 251521 ⠪⮢ + T�ॡ����)             
      Mov DX , 5h                     ;(4) ;��।�� ��ࠬ��஢ � ��楤��� ��襭�� �ॡ����     
      Call VibrDestr                  ;( = 19+)
      In AL , 5h                      ;(10)ᬮ�ਬ ����� �� ������ �ய�� 蠣�                         
      Mov  AH , AL                    ;(2)
      And AL , 00010000b              ;(4)� AL - �ਧ��� ������ ��� ��� ������ ������� ����
             
      And AH , 00001000b              ;(4)�뤥�塞 ���ﭨ� ������ ����
      Cmp AH , 00001000b              ;(4) 
      Jne Not_Stop_Btn_Push           ;(4)
      Mov Mode , Mode_Stop            ;(-)�᫨ ������ ���� �����, � ��室
      Jmp L_Engine_Work               ;(-) 
 Not_Stop_Btn_Push:                  
                                      ;(+12) 
      Cmp AL , Push_Fail_Step         ;(16)�ࠢ��� ॣ. � ��ࠧ ॣ 
      Je Not_Push_fail_Step           ;(4)�᫨ ࠢ��, � ����� ���� ������ �� ����⨫�, ���� ������ �� ��������
                                      ;(+0)
      Cmp Al , 0                      ;(4)���� �ࠢ�. ⥪ ���ﭨ� � 0 (���ﭨ� - �������)           
      Jne L_No_Push_Fail_Step         ;(4)�᫨ ������ ������� (�.� ���饭�), � �ਡ���塞 � �㬬��. ���-�� �ய 蠣�� 1
                                      ;(+0)
      Mov Push_Fail_Step , 0          ;(16)����塞 ��ࠧ ॣ. (�.� 㦥 㢥��稫� Failed_Steps)
      Inc Failed_Steps                ;(21)�᫨ ������ ���饭�, � 㢥��稢�� �᫮ �ய 蠣��              
      Jmp Out_Digits_                  ;(15) 
 L_No_Push_Fail_Step:                 ;(+12)
      Mov Push_Fail_Step , AL         ;(10)�᫨ ⥪. ��� �����, � �����뢠�� � ��ࠧ ॣ.
      Nop                             ;(3) - ����������
      Nop                             ;(3) -
      Nop                             ;(3) - �६���
      Nop                             ;(3) -
      Nop                             ;(3) - �믮������                        
      Jmp Out_Digits_                  ;(15)                
 Not_Push_fail_Step:                  ;(+12)   
      Inc Failed_Steps                ;(21) - ���������� 
      Dec Failed_Steps                ;(21) - �६���
      Mov AX , Failed_Steps           ;(10) - �믮������
 Out_Digits_:
   
        ; �⮡ࠦ��� �᫮ �ய 蠣��
      Mov CX , 3                     ;(4)
      Mov AX , Failed_Steps          ;(10) 
      Mov Out_AddrPort , Port_Failed_Steps  ;(16) 
      Call Out_Digits                ;(881=166+232*3+19)
               
      Mov AX , Por_fs                ;(10) 
      Cmp  Failed_Steps , AX         ;��諨 �� �� ��ண �ய. 蠣��
      JA Out_Of_Porog                ;(4)
      Call Engine_Go                 ;(250435=396+500*500+20+19)����᪠�� �����⥫�        
      Jmp All_Pulse_End              ;(15)
 Out_Of_Porog:                 
      Mov Mode , Mode_Stop           ;�᫨ ��諨 �� ��ண, � ��⠭�������� �����⥫�
      Jmp L_Engine_Work              ;��室
 All_Pulse_End:      
   
      ; ���������� ����� ������� � ���� ������ ��������� (�६� �믮������  = 462 ⠪⮢)
                                        
      Cmp Type_ , Type_razgon       ;(16)�஢�ઠ �� ࠧ��� 
      Jne Type_Not_Razgon           ;(4)�᫨ �� ࠧ��� � ���室 �� ��⪥                                         
                                 ; ��� �������� - ������� (��  Type_Not_Razgon - 444=342+52(�� 室�)+50(�� �ଠ��) ⠪⮢)                           
                                    ;(+0)
                                    ;(+102- ���������� �६���)  
      Mov DX , 1                    ;(4)  -
      Call Delay                    ;(89) -
      Nop                           ;(3)  -
      Nop                           ;(3)  -
      Nop                           ;(3)  - �믮����                             
                                     
     
      Mov AX , AX                   ;(2)  -�믮�����       
                                    ;(+0)
      Call New_F_n_r_Razgon         ;(165)��室�� ����� ��������� �����
      Mov AX , F_S                  ;(10)
      Cmp Word Ptr F_n_w+2 , AX     ;(15)�᫨ ࠧ��� � �஢��塞 ���� �� ������ ⨯ �� 室 (���⨣�� ����. �����)
      JAE Chg_Type_To_Hod           ;(4)
                                    ;(+0) 
      Call New_F_n_w_Razgon         ;(133)��室�� ����� �������� �����                                                      
      Jmp L_Engine_Work             ;(15)�� ��砫� ��楤���
 Chg_Type_To_Hod:                   ;(+12) 
      Mov Type_ , Type_hod          ;(16)���塞 ⨯ �� 室      
      Mov Word Ptr F_n_w+2 , AX     ;(10)���塞 ����� �� �������
      Mov Word Ptr F_n_w , 0        ;(16) 
      And OutReg , 11000111b        ;(23)��ᨬ ���ﭨ� (ࠧ���, 室, �ମ�)      
      Or OutReg , 10000b            ;(23)�������� 室 
      Mov AL , OutReg               ;(10) 
      Out 31h , AL                  ;(10)
      Nop                           ;(3) - ���������
      Nop                           ;(3) - 
      Nop                           ;(3) - �६���
      Mov AL , 0                    ;(4) - �믮�����           
      Jmp L_Engine_Work             ;(15)�� ��砫� ��楤���                                                       
                                       
                                   ;�� Type_Not_Hod  - 394+50(�� �ଠ��) ⠪⮢  
 Type_Not_Razgon:                   ;(+12)
      Cmp Type_ , Type_hod          ;(16)�஢�ઠ �� ⨯ ���� - 室
      Jne Type_Not_Hod              ;(4)���室 �᫨ �� 室                                  
                               ; ��� �������� - ���     
                                    ;(+0)
      Push F_S                      ;(23) -��������� 
      Pop F_S                       ;(22) -
      Nop                           ;(3)  -�६���
      Mov AX , AX                   ;(2)  -�믮�����       
                                    
      Call New_F_n_r_Razgon         ;(165)��室�� ����� ��������� �����                              
      Mov DX , Word Ptr Pulse+2     ;(15)  
      Mov AX , Word Ptr Pulse       ;(10)
      Mov DI , Word Ptr Cur_Pulse+2 ;(15)
      Mov SI , Word Ptr Cur_Pulse   ;(15)
      Call CompareDD                ;(60)
      Cmp BX , 11111111b            ;(4) 
      JNE Reach_                     ;(4) 
                                    ;(+0)
                                    
      Mov AX , Pulse_In_Kvant       ;(10)㢥��稢��� �� Pulse_In_Kvant ⥪. ���. �����ᮢ
      Add Word Ptr Cur_Pulse , AX   ;(10)               
      Adc Word Ptr Cur_Pulse+2, 0 
      Jmp L_Engine_Work             ;(15)
 Reach_:                            ;(+12) 
      Mov Type_ , Type_brake        ;(16)�᫨ ���⨣�� �।���, � �ମ���     
      Mov AL , Type_                ;(15) - ���������
      Mov Type_ , AL                ;(14) - �६��� 
      Mov AX , AX                   ;(2)  - �믮�����
      Jmp L_Engine_Work             ;(15)�� ��砫� ��楤���                                                             
 Type_Not_Hod:                           
      And OutReg , 11000111b        ;(23)��ᨬ ���ﭨ� (ࠧ���, 室, �ମ�)
      Or OutReg , 100000b           ;(23)�������� �ମ� 
      Mov AL , OutReg               ;(10)
      Out 31h , AL                  ;(10)
                                       ;��� �������� - ������
      Call New_F_n_r_Brake          ;(165)
      Mov AX , F_n                  ;(10)  
      Cmp Word Ptr F_n_w+2 , AX     ;(15)  
      JLE Chg_Mode_To_Idle          ;(4)
                                    ;(+0) 
      Call New_F_n_w_Brake          ;(133)��室�� ����� �������� �����                                  
      Mov AX , 0                    ;(4) - ����������
      Mov AX , Word Ptr F_n_w+2     ;(10)- �६��� �믮������
      Jmp L_Engine_Work             ;(15)�� ��砫� ��楤���      
 Chg_Mode_To_Idle:                  ;(+12)               
      Mov Mode , Mode_Idle          ;(16)
      Mov DX , 1                    ;(4)
      Mov AX , 0                    ;(4) 
      Mov Word Ptr F_n_w+2 , AX     ;(10)
      Call Delay                    ;(89)
      Nop                           ;(3) -  ��������� 
      Nop                           ;(3) -  
      Nop                           ;(3) -  �६���
      Nop                           ;(3) -  �믮�����                  
      Jmp L_Engine_Work             ;(15)�� ��砫� ��楤���                                                                               
 L_Engine_Stop:        
      Mov AL ,  00000000b               ;��ᨬ �� �����
      Out 31h , AL    
      Cmp Mode, 00000000b               ;㧭��� �뫠 �� ����� ������ ����
      Jne L_Engine_Succeed
      Mov AL ,  00000010b               ;�᫨ ������ �� ������ �⮯,
      Mov OutReg , AL
      Out 31h , AL                      ;� ���⠭�� ��㤠筮 (�������� �����) 
      Jmp L_End_Engine_Work             
 L_Engine_Succeed:  
      Mov AL ,  00000100b               ;�᫨ �����⥫� ��ࠡ�⠫ �� ����
      Mov OutReg , AL      
      Out 31h , AL                      ;� ���⠭�� 㤠筮 (�������� �����)         
 L_End_Engine_Work:                      
      Ret
EndP  Engine_Work 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;��������� �������� ��  50+CX*20 ⠪⮢ (�� >= 1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Delay Near
     Push CX           ;(11)
     PushF             ;(10)
     Mov CX , DX       ;(2)  
   h_1:  
     Nop               ;(3)
     Loop h_1          ;(17)
                       ;(+5)
     Nop               ;(3)           
     
     PopF              ;(8)
     Pop CX            ;(8)    
     Ret               ;(8)
EndP Delay

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ����������� ���������� ���������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Init_Engine NEAR       
                        ;���樠�����㥬 ��ࠬ����
      Mov AX , F_0
      Mov Word Ptr F_n_w+2 , AX
      Mov Word Ptr F_n_r+2 , AX         ;��砫�� ����� (�������� � ॠ�쭠�)
      Mov Word Ptr F_n_w , 0
      Mov Word Ptr F_n_r , 0            ;��砫�� ����� (�������� � ॠ�쭠�)      
      Mov Word Ptr Cur_Pulse , 0
      Mov Word Ptr Cur_Pulse+2 , 0   
      Mov Type_ , Type_Razgon           ;०�� �������� �����⥫� - ࠧ���
      Mov Failed_Steps , 0              ;������⢮ �ய. 蠣�� ࠢ�� - 0
      Mov Fail_Step , 0                ;���� �� �ய�᪠�� 蠣                   
      Mov AL ,  00000001b               ;��������� ����� ��⨢����
      Mov OutReg , AL
      Or OutReg , 00001000b             ;��������  ��⨢����� � ࠧ���
      Mov AL , OutReg
      Out 31h , AL    

      Mov Push_Fail_Step , 0            ;���� ������ �ய. 蠣� �� ��������

                              ;���� A_w_start
      Mov AX , Word Ptr A_w_start
      Mov DX , Word Ptr A_w_start+2
      Mov CX , 0115d                          ;��������� � CX ��������!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
      Div CX    
      Mov Word Ptr a_w_s+2 , AX            ;��諨 楫�� ����
      Mov AX , DX
      Mov DX , 0
      Mov BX , Pressision                ;�筮��� �� 10000-���
      Mul BX
      Div CX 
      Mov Word Ptr a_w_s , AX              ;��諨 �஡��� ����  
                           ;���� A_w_Brake        
      Mov AX , Word Ptr A_w_Brake
      Mov DX , Word Ptr A_w_Brake+2
      Div CX    
      Mov Word Ptr a_w_b+2 , AX            ;��諨 楫�� ����
      Mov AX , DX                         
      Mov DX , 0
      Mul BX
      Div CX 
      Mov Word Ptr a_w_b , AX              ;��諨 �஡��� ����  (�筮��� �� 10000-���)
                                ;���� A_r_start
      Mov AX , Word Ptr A_r_start
      Mov DX , Word Ptr A_r_start+2
      Div CX    
      Mov Word Ptr a_r_s+2 , AX            ;��諨 楫�� ����
      Mov AX , DX
      Mov DX , 0
      Mul BX
      Div CX 
      Mov Word Ptr a_r_s , AX              ;��諨 �஡��� ����  
                              ;���� A_r_Brake        
      Mov AX , Word Ptr A_r_Brake
      Mov DX , Word Ptr A_r_Brake+2
      Div CX    
      Mov Word Ptr A_r_b+2 , AX            ;��諨 楫�� ����
      Mov AX , DX                         
      Mov DX , 0
      Mul BX
      Div CX 
      Mov Word Ptr A_r_b , AX              ;��諨 �஡��� ����  (�筮��� �� 10000-���)             
 End_Init_Engine: 
     Ret
EndP Init_Engine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;������� ��������� �� F_n_w ���������    t���� - 396 ; t 1-�� 横�� - 500 ⠪⮢ ; t ���室� - 20 ⠪⮢
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Engine_Go Near
     Call Determ_Count_Pulse      ;(268=248+19)� AX - �᫮ �����ᮢ 0 - Pulse_In_Kvant                                        
     Mov CX , 1                   ;(4)         
     Cmp AX , 0                   ;(4) - �᫨ �᫮ �����ᮢ = 0 
     Je Zero_Pulse                ;(4)
                                  ;(+0)
     Mov BX , AX                  ;(2)
     Mov AX , Max_Pulse_In_Kvant  ;(10)��室�� �᫮ �१ ���஥ ����⢨⥫쭮 �㦭� �뤠���� ������  
     Mov DX , 0                   ;(4)
     Div BX                       ;(150)
     Mov BX , AX                  ;(2) � �� - ��ࢠ� ᫥������� �����ᮢ       
     Mov DX , 20                  ;(4)
     Jmp Pulse_Out                ;(15)     
 Zero_Pulse:                      ;(+12)�뮫����� ("�����" ����⢨�)� ��砥 0 �����. �����ᮢ � ������

     Mov BX , 0
     Mov DX , 3                   ;(4)        - ����������
     Call Delay                   ;(89=19+70) -
     Nop                          ;(3)        - 
     Nop                          ;(3)        - �६���
     Nop                          ;(3)        -  
     Nop                          ;(3)        -
     Nop                          ;(3)        - �믮������              
     Mov DX , 20                  ;(4) - ��� ������� ����প� 
     Jmp Pulse_Out                ;(15)
 Pulse_Out:                       ;�����塞 Pulse_In_Kvant ࠧ  (⥫� 横�� - 500 ⠪⮢) 
     Cmp CX , 501                 ;(4)              
     Je I_1                       ;(4)
     Cmp CX , AX                  ;(3)ᬮ�ਬ ���� �� �뤠���� ������
     Jne Not_Rotate               ;(4) 
                                  ;(+0)
     Call Rotate_Engine           ;(467= 448+19)��뢠�� ������ �����⥫�          
     Add AX , BX                  ;(3)㢥��稢��� �� ���ࢠ�     
     Jmp E_1                      ;(15)
 Not_Rotate:                      ;(+12)
     Call Delay                   ;(469)
     Mov AL , AL                  ;(2) - ���������� 
     Mov AL , AL                  ;(2) - �믮������     
     Jmp E_1                      ;(15)        
 E_1:
     Inc CX                       ;(2)
     Jmp Pulse_Out                ;(15)
                                                                  
   I_1:                           ;(+12) 
     Ret                          ;(8)
EndP Engine_Go 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;������� ��������� �� ���� ��� (��� ��������� ��) (�६� �믮����� ����ﭭ� = 500-19 ⠪⮢)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Rotate_Engine
     Push AX                  ;(11)
     Push DX                  ;(11)     
     Mov DL , N_Reg_Out       ;(15)�����뢠�� ����      
     Mov DH , 0               ;(4)���� �뢮��  
     Mov AL , 0               ;(4)��� ��࠭�� � ��⨢���� ॣ���� �뢮��  
     Shl SM_Cond , 1          ;(21)ᤢ�����  -
     Inc SM_Cond              ;(21)- � ���६����㥬 ���ﭨ� �� 
     Cmp SM_Cond , 1111b      ;(16)�஢�ઠ �� 5 蠣�� (200 蠣�� ॠ�쭮�� �� - 40 ᢥ⮤�����) 
     Jne Not_Show_Rotate      ;(4)�᫨ ��ﭨ� �� <> 5 �����ᠬ, � ������ �� ᢥ⮤����� �� ����ࠥ���    
     Out DX , AL              ;(8)���⪠ ��⨢���� ॣ���� �뢮��
     Mov AL , Reg_out_Cond    ;(10)
     Cmp AL , 10000000b       ;(4)
     Jne Not_Next_Reg_Out     ;(4)���室 �᫨ �� �㦥�� ������ ��⨢�� ॣ���� �뢮�� 
                              ;(+0)
     Add DL , 51              ;(4)���塞 ��⨢�� ॣ���� �뢮��     
     Adc DL , 0               ;(4)���뢠�� ��७��: 255+51--> 50 � CF=1
     Add DL , 0               ;(4) - ���������� �६��� �믮����� 
     Jmp Show_Rotate          ;(15)
 Not_Next_Reg_Out:            ;(+12)
     Jmp Show_Rotate          ;(15) 
 Show_Rotate:
     Shl DH , 1               ;(2)����塞 䫠� CF
     Shl AL , 1               ;(2)ᤢ�� ���ﭨ� ��⨢���� ॣ���� �뢮�� 
     Adc AL , 0               ;(4)���뢠�� ��७��
     Mov N_Reg_Out , DL       ;(13)��࠭塞 ���祭�� ��⨢���� ॣ����(�� ��砩 �᫨ ��������)
     Mov Reg_Out_Cond , AL    ;(10)��࠭塞 ����祭�� ���ﭨ� ��⨢���� ॣ���� �뢮��
     Out DX , AL              ;(8)�뢮� ���ﭨ� ��⨢���� ॣ���� �뢮��
     Mov SM_Cond , 0b         ;(16)���㫥��� ���ﭨ� ��
     Jmp Quit                 ;(15)
 Not_Show_Rotate:             ;(+12-���室 ��) 
     Mov DX , 2               ;(4)
     Mov DX , 2               ;(4) - ���������� �६���                               
     Nop                      ;(3) - �믮������ 
     Call Delay               ;(89)
     Jmp Quit                 ;(15)
 Quit:
     Mov DX , 7               ;(4)                - ����������
     Call Delay               ;(209=19+190)       -
     Mov AL , 0               ;(4)                - �६���
     Mov AL , 0               ;(4)                - 
     Mov AL , 0               ;(4)                - �믮����� ��楤���
     Mov AL , 0               ;(4)                - �� 500-19 ⠪⮢ 
     Pop DX                   ;(8) 
     Pop AX                   ;(8) 
     Ret                      ;(8)
EndP Rotate_Engine 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;�����������  ���������� ��������� � ������ ������������� ����� � Pulse_In_Kvant(AX) �६� �믮������ = 248 ⠪⮢ 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc Determ_Count_Pulse Near
      Mov AX , Word Ptr F_n_w+2   ;(10)
      Mov DX , 0                  ;(4)
      Mov BX , 20                 ;(4)� ����. ���� 10000 � �६�= 0.05, � N���� = 500
      Div BX                      ;(150)
      Cmp DX , 10                 ;(4)   - ���㣫����
      Jb Not_inc_AX               ;(4)   
                                  ;(+0)
      Inc AX                      ;(2) 
      Nop                         ;(3)   - ����������
      Nop                         ;(3)   - �६���   
      Mov BX , 20                 ;(4)   - �믮�����
      Jmp OK_                     ;(15)
 Not_inc_AX:                      ;(+12)
      Jmp OK_                     ;(15)     
 OK_:        
      Mov Pulse_In_Kvant , AX     ;(10)
      Ret                         ;(8)
EndP Determ_Count_Pulse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;�������� �� (DX,AX > DI,SI)  ����� ���������� ��������� =  60 ������
; BX - 11111111  �� ; BX - 0 ���  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc CompareDD
     Mov BX , 0            ;(4)  
     Cmp DX , DI           ;(3) 
     Ja Yes_1              ;(4)�᫨ DX > DI
                           ;(+0- ���室� ��� )                           
     Jne No_               ;(4)�᫨ DX <>DI (�.� DX<DI)   
                           ;(+0- ���室� ���뫮)
     Cmp AX , SI           ;(3)���� (�.� DX=DI)    
     JA Yes_2              ;(4)�᫨ AX>SI      
                           ;(+0 - ���室� �� �뫮) 
     Mov  AL , Curr_Digit  ;(10)  -  ��ࠢ������� �६���                   
     Add  AL , 1           ;(4)   -  �믮������     
     Jmp End_CompareDD     ;(15)����           

  Yes_1:                     
                           ;(+12 - ���室 ��) 
     Mov BX , 11111111b    ;(4) �᫨ DX,AX > DI,SI   
     Mov  AL , 0           ;(4)  -  ��ࠢ�������
     Mov  AL , 0           ;(4)  -  �६��� 
     Nop                   ;(3)  -  �믮������
     Jmp End_CompareDD     ;(15)
 
  No_:   
                           ;(+12 - ���室 ��) 
     Mov  AL , 0           ;(4)  -  ��ࠢ�������
     Mov   AL , 0           ;(4)  -  �६��� 
     Nop                   ;(3)  -  �믮������
     Jmp End_CompareDD     ;(15)
         
  Yes_2:                   ;(+12 - ���室 ��) 
     Mov BX , 11111111b    ;(4) �᫨ DX,AX > DI,SI      
     Jmp End_CompareDD     ;(15)              

 End_CompareDD:     
     Ret                   ;(8)
EndP CompareDD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;��������� ��������� ������� �� a_r_s  (�६� �믮������ ����ﭭ� = 165 ⠪⮢)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc New_F_n_r_Razgon
      Mov AX , F_S                    ;(10)
      Cmp Word Ptr F_n_r+2 , AX       ;(16)
      Jnb C_1                         ;(4) 
                                      ;(+0 - ���室� �� �뫮)
      Mov AX , Word Ptr A_r_s         ;(10)���᫥��� ����� ����� ���������
      Add Word Ptr F_n_r , AX         ;(15)�஡��� ����
      Mov AX , Word Ptr F_n_r+2       ;(10)
      Add AX , Word Ptr A_r_s+2       ;(22)����� ����
      Cmp Word Ptr F_n_r , Pressision ;(16)
      JB C_2                          ;(4)�᫨ �� ��諮 �� �।��� �筮��
                                      ;(+0 - ���室� �� �뫮)
      Inc AX                          ;(2)���� 
      Sub Word Ptr F_n_r , Pressision ;(23)          
      Mov Word Ptr F_n_r+2 , AX       ;(10)    
      Jmp C_3                         ;(15)
 C_2:                                 ;(+12 - ���室 ��)
      Mov Word Ptr F_n_r+2 , AX       ;(10)   
      Mov AX , Word Ptr F_n_r+2       ;(10)  - ���������� �६��� 
      Inc AL                          ;(3)   - �믮������
      Jmp C_3                         ;(15)
 C_1:                                 ;(+12 - ���室 ��)
                              ;�᫨ ���������  ���� ����� 祬 ����筠�
      Mov Word Ptr F_n_r+2 , AX       ;(10) ����
      Mov Word Ptr F_n_r , 0          ;(16)
      Add AL , Curr_Digit             ;(22) - ����-
      Add AL , Curr_Digit             ;(22) - ������ 
      Add AL , Curr_Digit             ;(22) - �� -
      Inc AL                          ;(4)  - ����
      Inc AL                          ;(4)  - �믮�����      
      Jmp  C_3                        ;(15) 

 C_3:     
      Ret                             ;(8)
EndP New_F_n_r_Razgon   


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;���������� �������� ������� �� a_w_s (�६� �믮������ ����ﭭ� = 133 ⠪�a)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc New_F_n_w_Razgon  
     Mov AX , Word Ptr A_w_s      ;(10)���᫥��� ����� ����� ���������
     Add Word Ptr F_n_w , AX      ;(15)�஡��� ����
     Mov AX , Word Ptr F_n_w+2    ;(10)
     Add AX , Word Ptr A_w_s+2    ;(22)����� ����
     Cmp Word Ptr F_n_w , Pressision ;(16) 
                                   ;(+0 - ���室� �� �뫮)
     JB D_1                       ;(4)�᫨ �� ��諮 �� �।��� �筮��
     Inc AX                       ;(2)����
     Sub Word Ptr F_n_w , Pressision ;(23)      
     Jmp D_2                      ;(15) 
  D_1:                            ;(+12 - ���室 ��)
     Nop                          ;(3) - ���������� 
     Nop                          ;(3) - 
     Nop                          ;(3) - �६���
     Mov AX , AX                  ;(4) - �믮����� 
     Jmp D_2                      ;(15)
  D_2: 
     Mov Word Ptr F_n_w+2 , AX    ;(10)                     
     Ret                          ;(8) 
EndP New_F_n_w_Razgon  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;���������� ��������� ������� �� a_r_b (�६� �믮������ ����ﭭ� = 165 ⠪⮢)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc New_F_n_r_Brake
      Mov AX , F_n               ;(10) 
      Cmp Word Ptr F_n_r+2 , AX  ;(16) 
      JnG A_1                     ;(4)�᫨ ���������  ���� ����� 祬 ����筠�
                                 ;(+0)
      Mov AX , Word Ptr A_r_b    ;(10)���᫥��� ����� ����� ���������
      Sub Word Ptr F_n_r , AX    ;(15)�஡��� ����
      Mov AX , Word Ptr F_n_r+2  ;(10)
      Sub AX , Word Ptr A_r_b+2  ;(22)����� ����      
      Cmp Word Ptr F_n_r , 0     ;(16) 
      JG A_2                     ;(4)�᫨ �� ��諮 �� �।��� �筮��
                                 ;(+0)
      Dec AX                     ;(2)����
      Add Word Ptr F_n_r , Pressision ;(23)
      Mov Word Ptr F_n_r+2 , AX  ;(10)        
      Jmp A_3                    ;(15)
 A_1:                            ;(+12)
      Mov Word Ptr F_n_r+2 , AX  ;(10)����
      Mov Word Ptr F_n_r , 0     ;(16)      
      Add AL , Curr_Digit        ;(22) - ����-
      Add AL , Curr_Digit        ;(22) - ������ 
      Add AL , Curr_Digit        ;(22) - �� -
      Inc AL                     ;(4)  - ����
      Inc AL                     ;(4)  - �믮�����     
      Jmp A_3                    ;(15)
 A_2:                            ;(+12) 
      Mov Word Ptr F_n_r+2 , AX  ;(10)  
      Mov AX , Word Ptr F_n_r+2  ;(10)  - ���������� �६��� 
      Inc AL                     ;(3)   - �믮������
      Jmp A_3                    ;(15)
 A_3:  
     Ret                         ;(8)
EndP New_F_n_r_Brake

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;���������� �������� ������� �� a_w_b (�६� �믮������ ����ﭭ� = 133 ⠪�a)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc New_F_n_w_Brake
      Mov AX , Word Ptr A_w_b     ;(10)���᫥��� ����� ����� ���������
      Sub Word Ptr F_n_w , AX     ;(16)�஡��� ����
      Mov AX , Word Ptr F_n_w+2   ;(10)
      Sub AX , Word Ptr A_w_b+2   ;(22)����� ����
      Cmp Word Ptr F_n_w , 0      ;(16)
      JG B_1                      ;(4)�᫨ �� ��諮 �� �।��� �筮��
                                  ;(+0)
      Dec AX                      ;(2)����
      Add Word Ptr F_n_w , Pressision ;(23)          
      Jmp  B_2                    ;(15) 
 B_1:                             ;(+12)
      Nop                         ;(3) - ���������� 
      Nop                         ;(3) - 
      Nop                         ;(3) - �६���
      Mov AX , AX                 ;(4) - �믮����� 
      Jmp B_2                     ;(15)
 B_2:    
      Mov Word Ptr F_n_w+2 , AX   ;(10)  
      Ret                         ;(8)
EndP New_F_n_w_Brake

Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           Call  Init        
      Begin:
           Call KbdInput 
           Call GetCurrentDigit 
           Call DecodeCurrentDigit 
           Call Show_All_Values  
           Call Assign_Values
           Jmp Begin  
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
