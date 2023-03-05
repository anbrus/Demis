RomSize    EQU   4096
NMax       EQU   50
KbdPort    EQU   0
DispPort   EQU   1

Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

Data       SEGMENT AT 0
ProgramM   DB    50 DUP (4 DUP (0FFh))
ActivePE   DB    4  DUP (?)
TempPE     DB    4  DUP (?)
RegimFlag  DB    ?
EditFlag   DB    ?
PressEditF DB    ?
PressFlag  DB    ?
PressFlag1 DB    ?
KbdImage   DB    2 DUP(?)
EmpKbd     DB    ?
KbdErr     DB    ?
NextDig    DB    ?
PrevH      DB    ?
RightB     DB    ?
LeftB      DB    ?
ActiveDec  DB    ?
ActivePEN  DB    ?
DecPort    DB    ?
PressRegimF DB   ?
Addr       DW    ?
Temp       DB    ?
Flag       DB    ?
ErrInpF    DB    ?
CurrTime   DB    4 DUP(?)
Delay      DB    ?
Signal     DB    ?
Data       ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Code,ss:Stk

           ;��ࠧ� 16-����� ᨬ�����: "0", "1", ... "F"
SymImages  DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h
           DB    11100000b,0

OutPE      PROC  NEAR
           test RegimFlag,0FFh
           jz OPE1
           test EditFlag,0FFh
           jnz OPE1
           mov al,4
           mov dl,ActivePEN
           mul dl
           mov Addr,ax
           mov dl,10           
           mov cx,4
           mov di,cx
           mov ActiveDec,8
OPE2:      mov ah,0
           mov bx,Addr      
           mov al,BYTE PTR ProgramM[bx][di]
           mov dl,10
           div dl
           mov NextDig,ah    
           mov PrevH,al
           call NumOutN
           sub ActiveDec,2
           dec di
           loop OPE2
OPE1:      ret     
OutPE      ENDP

RegimB     PROC NEAR   
           in al,10h
           mov bl,al
           xor bl,11111111b
           jz R1
           test PressRegimF,11111111b
           jz R2
           mov PressRegimF,0
           cmp al,01111111b
           jnz R2
           cmp RegimFlag,0FFh
           je R4 
           test EditFlag,0FFh
           jnz R2
R4:        cmp RegimFlag,0FFh
           jne R3
           call KontrInp 
           test ErrInpF,0FFh
           jnz R2           
           mov al,00000010b
           out 11h,al
           mov EditFlag,0
           jmp R5                  
R3:        mov al,00000100b
           out 11h,al
           jmp R5
R1:        mov PressregimF,1
           jmp R2
R5:        not RegimFlag
R2:        ret           
RegimB     ENDP

EditK      PROC NEAR
           cmp RegimFlag,0FFh
           jne EK2
           cmp EditFlag,0FFh
           jne EK4                            ;���
           mov al,4                           ;������ TempPE
           mov dl,ActivePEN
           mul dl
           mov Addr,ax
           mov dl,10           
           mov cx,4
           mov di,cx
EK5:       mov ah,0
           mov bx,Addr   
           mov si,cx   
           mov al,BYTE PTR TempPE[si-1]
           cmp al,0FFh
           jz EK6
           mov BYTE PTR ProgramM[bx][si],al         
EK6:       mov BYTE PTR TempPE[si-1],0FFh
           loop EK5          
EK4:       call NewEdit
           ;not EditFlag
           jz EK3 
           mov ActiveDec,2
           ;mov cl,0FFh
           ;call ActNum           
           jmp EK2
EK3:       ;mov ActiveDec,12h
           jmp E2
EK2:       ret              
EditK      ENDP

EditB      PROC  NEAR
           cmp RegimFlag,0FFh
           je E2
           in al,10h
           mov bl,al
           xor bl,11111111b
           jz E1
           test PressEditF,11111111b        ;���. �뫠 �����? 
           jz E2
           mov PressEditF,0 
           cmp al,10111111b
           jnz E2
           test EditFlag,0FFh               ;������஢�����?
           jz E4
           call KontrInp 
           test ErrInpF,0FFh
           jnz E2                           
           test RegimFlag,0FFh
           jz E4                            ;���
           mov al,4                         ;������ TempPE
           mov dl,ActivePEN
           mul dl
           mov Addr,ax
           mov dl,10           
           mov cx,4
           mov di,cx
E5:        mov ah,0
           mov bx,Addr   
           mov si,cx   
           mov al,BYTE PTR TempPE[si-1]
           cmp al,0FFh
           jz E6
           mov BYTE PTR ProgramM[bx][si],al         
E6:        mov BYTE PTR TempPE[si-1],0FFh
           loop E5          
E4:        call NewEdit
           not EditFlag
           jz E3 
           mov ActiveDec,2
           mov cl,0FFh
           call ActNum           
           jmp E2
E3:        ;mov ActiveDec,12h
           jmp E2           
E1:        mov PressEditF,1
E2:        ret                                 
EditB      ENDP

SelectB    PROC  NEAR
           in al,10h
           mov bl,al
           xor bl,0FFh           ;����� ������?
           jz SB4 
           cmp RegimFlag,0FFh
           je  SB7               ;��
           test EditFlag,0FFh
           jz SB2
SB7:       test PressFlag,0FFh   ;���. �뫠 �����? 
           jz SB2
           mov PressFlag,0
           cmp al,11011111b      ;�����
           jz SB1
           cmp al,11101111b      ;�����
           jnz SB2
           ;call KontrInp 
           ;test ErrInpF,0FFh
           ;jnz SB2
           mov EditFlag,0FFh           
           mov cl,0
           call ActNum            
           cmp ActiveDec,2
           jz SB5
           sub ActiveDec,2       ;��砫�?
           jmp SB6 
SB1:       ;call KontrInp 
           ;test ErrInpF,0FFh
           ;jnz SB2
           mov EditFlag,0FFh
           mov cl,0
           call ActNum 
           cmp ActiveDec,6       ;�����?
           jz SB3
           add ActiveDec,2
           jmp SB6                       
SB3:       mov ActiveDec,2
           jmp SB6
SB5:       mov ActiveDec,6
           jmp SB6        
SB6:       mov cl,0FFh
           call ActNum
           jmp SB2                  
SB4:       mov PressFlag,1            
SB2:       ret
SelectB    ENDP

Select     PROC  NEAR
           in al,10h
           mov bl,al
           xor bl,0FFh               ;����� ������?
           jz S4                     ;��
           test RegimFlag,0FFh
           jz S2
           ;test EditFlag,0FFh
           ;jnz S2
           test PressFlag1,0FFh      ;���. �뫠 �����? 
           jz S2
           mov PressFlag1,0
           cmp al,11111011b          ;�����
           jz S1
           cmp al,11110111b          ;�����
           jnz S2
           call KontrInp 
           test ErrInpF,0FFh
           jnz S2
           mov EditFlag,0                      
           cmp ActivePEN,0
           jz S5
           dec ActivePEN
           jmp S2            
S1:        call KontrInp 
           test ErrInpF,0FFh
           jnz S2
           mov EditFlag,0           
           cmp ActivePEN,49
           jz S3
           inc ActivePEN
           jmp S2
S3:        mov ActivePEN,0
           jmp S2
S5:        mov ActivePEN,49
           jmp S2
S4:        mov PressFlag1,1                                          
S2:        ret
Select     ENDP

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

KbdInput   PROC  NEAR
           lea   si,KbdImage         ;����㧪� ����,
           mov   cx,LENGTH KbdImage  ;����稪� 横���
           mov   bl,0FEh             ;� ����� ��室��� ��ப�
KI4:       mov   al,bl       ;�롮� ��ப�
           ;and   al,3Fh     ;��ꥤ������ ����� �
           ;or    al,MesBuff ;ᮮ�饭��� "��� �����"
           out   KbdPort,al  ;��⨢��� ��ப�
           in    al,KbdPort  ;���� ��ப�
           and   al,00011111b      ;����祭�?
           cmp   al,00011111b
           jz    KI1         ;���室, �᫨ ���
           mov   dx,KbdPort  ;��।�� ��ࠬ���
           call  VibrDestr   ;��襭�� �ॡ����
           mov   [si],al     ;������ ��ப�
KI2:       in    al,KbdPort  ;���� ��ப�
           and   al,00011111b      ;�몫�祭�?
           cmp   al,00011111b
           jnz   KI2         ;���室, �᫨ ���
           call  VibrDestr   ;��襭�� �ॡ����
           jmp   SHORT KI3
KI1:       mov   [si],al     ;������ ��ப�
KI3:       inc   si          ;����䨪��� ����
           rol   bl,1        ;� ����� ��ப�
           loop  KI4         ;�� ��ப�? ���室, �᫨ ���
           ret
KbdInput   ENDP

KbdInContr PROC  NEAR
           lea   bx,KbdImage ;����㧪� ����
           mov   cx,2        ;� ����稪� ��ப
           mov   EmpKbd,0    ;���⪠ 䫠���
           mov   KbdErr,0
           mov   dl,0        ;� ������⥫�
KIC2:      mov   al,[bx]     ;�⥭�� ��ப�
           mov   ah,5        ;����㧪� ����稪� ��⮢
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
           jz    KIC5        ;���室, �᫨ ��
           mov   KbdErr,0FFh ;��⠭���� 䫠�� �訡��
           jmp   SHORT KIC4
KIC3:      mov   EmpKbd,0FFh ;��⠭���� 䫠�� ���⮩ ����������
           ;mov   EditFlag,0h
           jmp   KIC4
KIC5:      mov   EditFlag,0FFh
KIC4:      ret
KbdInContr ENDP

NxtDigTrf  PROC  NEAR
           cmp   EmpKbd,0FFh ;����� ���������?
           jz    NDT1        ;���室, �᫨ ��
           cmp   KbdErr,0FFh ;�訡�� ����������?
           jz    NDT1        ;���室, �᫨ ��
           lea   bx,KbdImage ;����㧪� ����
           mov   dx,0        ;���⪠ ������⥫�� ���� ��ப� � �⮫��
NDT3:      mov   al,[bx]     ;�⥭�� ��ப�
           and   al,00011111b      ;�뤥����� ���� ����������
           cmp   al,00011111b      ;��ப� ��⨢��?
           jnz   NDT2        ;���室, �᫨ ��
           inc   dh          ;���६��� ���� ��ப�
           inc   bx          ;����䨪��� ����
           jmp   SHORT NDT3
NDT2:      shr   al,1        ;�뤥����� ��� ��ப�
           jnc   NDT4        ;��� ��⨢��? ���室, �᫨ ��
           inc   dl          ;���६��� ���� �⮫��
           jmp   SHORT NDT2
NDT4:      mov   al,5        ;��ନ஢��� ����筮�� ���� ����
           mul   dh
           add   al,dl
           mov   NextDig,al  ;������ ���� ����
NDT1:      ret
NxtDigTrf  ENDP

NumOut     PROC  NEAR
           cmp   KbdErr,0FFh
           jz    NO1
           cmp   EmpKbd,0FFh
           jz    NO1
           ;test RegimFlag,0FFh
           ;jz NO1
           xor   ah,ah
           mov   dx,0
           mov   al,PrevH
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           or    al,10000000b
           mov   dl,ActiveDec
           out   dx,al
           xor   ah,ah
           mov   al,NextDig
           mov   PrevH,al           
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           or    al,10000000b
           dec   ActiveDec
           mov   dl,ActiveDec
           inc   ActiveDec           
           out   dx,al
NO1:       ret
NumOut     ENDP

NumSave    PROC NEAR
           mov   cl,PrevH
           cmp   KbdErr,0FFh
           jz    NS1
           cmp   EmpKbd,0FFh
           jz    NS1
           test EditFlag,0FFh
           jz NS1           
           xor   ah,ah                   ;��࠭���� PrevH
           mov   al,PrevH                
           mov   dl,10                   ;����祭�� ���襣� 
           mul   dl                      ;ࠧ�鸞
           mov   di,ax
           xor   ah,ah
           mov   al,BYTE PTR NextDig
           add   di,ax
           xor   ah,ah
           dec   ActiveDec
           dec   ActiveDec
           mov   al,ActiveDec
           shr   al,1
           mov   si,ax
           inc   ActiveDec
           inc   ActiveDec           
           mov   ax,di
           test  RegimFlag,0FFh
           jz NS2
           mov   TempPE[si],BYTE PTR al
           jmp NS1 
NS2:       mov   CurrTime[si],BYTE PTR al           
           mov   TempPE[si],BYTE PTR al
NS1:       mov   PrevH,cl
           ret          
NumSave    ENDP

NumOutN     PROC  NEAR
           ;test RegimFlag,0FFh
           ;jz NON1
           mov   al,PrevH
           mov   dx,0
           mov   dl,ActiveDec
           xor   ah,ah
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           test  Flag,0FFh
           jz NON2
           or    al,10000000b
NON2:      out   dx,al
           xor   ah,ah
           mov   al,NextDig
           mov   PrevH,al
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           dec   ActiveDec
           mov   dl,ActiveDec
           inc   ActiveDec
           test  Flag,0FFh
           jz NON3
           or    al,10000000b
NON3:      out   dx,al
NON1:       ret
NumOutN     ENDP

TimeInp    PROC NEAR
           cmp RegimFlag,0FFh
           je TI1
           cmp EditFlag,0FFh
           je TI1
           mov cx,3
TI2:       mov bx,cx
           mov al,BYTE PTR CurrTime[bx]
           mov BYTE PTR TempPE[bx],al                      
           loop TI2
TI1:       ret            
TimeInp    ENDP

ActNum     PROC NEAR
           mov Temp,al
           xor ah,ah
           dec ActiveDec
           dec ActiveDec
           mov al,ActiveDec
           shr al,1
           mov si,ax
           inc ActiveDec
           inc ActiveDec           
           mov al,BYTE PTR TempPE[si]
           mov dl,10
           div dl
           test cl,0FFh
           jnz AN1
           mov Flag,0
           jmp AN2           
AN1:       mov Flag,0FFh
AN2:       mov NextDig,ah    
           mov PrevH,al
           call NumOutN 
           mov al,Temp
           mov Flag,0
           ret          
ActNum     ENDP

NewEdit    PROC NEAR
           ;test EditFlag,0FFh
           ;jz NE3
           test RegimFlag,0FFh
           jz NE2
           mov al,4                         ;������ TempPE
           mov dl,ActivePEN
           mul dl
           mov Addr,ax
           mov dl,10           
           mov cx,4
           mov di,cx
           mov ah,0
NE1:       mov bx,Addr   
           mov si,cx   
           mov al,BYTE PTR TempPE[si-1]
           cmp al,0FFh
           mov al,BYTE PTR ProgramM[bx][si]         
           mov BYTE PTR TempPE[si-1],al
           loop NE1
           jmp NE3
NE2:       mov cx,4
NE4:       mov si,cx
           mov al,BYTE PTR CurrTime[si-1]
           mov BYTE PTR TempPE[si-1],al
           loop NE4           
NE3:       ret                           
NewEdit    ENDP

KontrInp   PROC NEAR
           mov dl,PrevH
           mov ErrInpF,0
           mov al,BYTE PTR TempPE
           cmp al,24
           jb KIP4
           mov cl,ActiveDec
           mov PrevH,0Eh
           mov NextDig,16
           mov ActiveDec,8
           call NumOutN
           mov ActiveDec,cl
           mov ErrInpF,0FFh                       
KIP4:      mov al,BYTE PTR TempPE[1]
           cmp al,60
           jb KIP1
           mov cl,ActiveDec
           mov PrevH,0Eh
           mov NextDig,16
           mov ActiveDec,8
           call NumOutN
           mov ActiveDec,cl
           mov ErrInpF,0FFh
KIP1:      mov al,BYTE PTR TempPE[2]
           cmp al,60
           jb KIP5
           mov cl,ActiveDec
           mov PrevH,0Eh
           mov NextDig,16
           mov ActiveDec,8
           call NumOutN
           mov ActiveDec,cl
           mov ErrInpF,0FFh
KIP5:      mov PrevH,dl
           ret           
KontrInp   ENDP

Time       PROC NEAR
           test EditFlag,0FFh
           jz T3
           test RegimFlag,0FFh
           jz T2
T3:        mov dx,1h
KIP3:      mov cx,0FFFFh
KIP2:      mov si,44
           loop KIP2
           dec dx
           jnz KIP3
           inc CurrTime[3]
           cmp CurrTime[3],21h
           jne T1
           mov CurrTime[3],0
           inc CurrTime[2]
           cmp CurrTime[2],60
           jne T1
           mov CurrTime[2],0
           inc CurrTime[1]
           cmp CurrTime[1],60
           jne T1
           mov CurrTime[1],0
           inc CurrTime
           cmp CurrTime,24
           jne T1
           mov CurrTime,0
T1:        mov al,CurrTime[2]
           out 9h,al           
T2:        ret           
Time       ENDP

KontrTime  PROC NEAR
           cmp RegimFlag,0FFh
           je KT2
           mov cl,50
KT1:       mov al,4
           mov dl,cl
           mul dl
           mov bx,ax
           mov Addr,ax
           mov al,ProgramM[bx-3]
           cmp al,BYTE PTR CurrTime           
           jne KT3
           mov bx,Addr
           mov al,ProgramM[bx-2]
           cmp al,BYTE PTR CurrTime[1]
           jne KT3           
           cmp BYTE PTR CurrTime[2],0
           jne KT3           
           mov al,ProgramM[bx-1]
           mov Delay,al
KT3:       loop KT1
           cmp Delay,0
           je KT2
           or Signal,00001001b
           mov al,Signal
           out 11h,al           
           cmp CurrTime[3],20h
           jne KT2
           dec Delay
           cmp Delay,0
           jne KT2
           and Signal,11110110b
           mov al,Signal
           out 11h,al           
KT2:       ret           
KontrTime  ENDP

TimeOut    PROC NEAR
           cmp RegimFlag,0FFh
           je TO1
           cmp EditFlag,0FFh
           je TO1
           mov dl,10           
           mov cx,4
           mov di,cx
           mov ActiveDec,6
TO2:       mov ah,0  
           mov al,BYTE PTR CurrTime[di-2]
           mov dl,10
           div dl
           mov NextDig,ah    
           mov PrevH,al
           call NumOutN
           sub ActiveDec,2
           dec di
           loop TO2
           mov ActiveDec,8           
           mov NextDig,17    
           mov PrevH,17
           call NumOutN
TO1:       ret           
TimeOut    ENDP

InitP      PROC
           mov BYTE PTR CurrTime,0
           mov BYTE PTR CurrTime[1],0
           mov WORD PTR CurrTime[2],0
           mov cx,50
           mov bx,200
M1:        mov ProgramM[bx],cl
           dec bx
           mov ProgramM[bx],0
           dec bx
           mov ProgramM[bx],0
           dec bx
           mov ProgramM[bx],0
           dec bx
           loop M1
           mov cx,4
           mov bx,3
M2:        mov TempPE[bx],0FFh                      
           dec bx
           loop M2
           mov Delay,0
           mov KbdErr,0
           mov PrevH,0
           mov PressFlag,0
           mov PressFlag1,0
           mov ActiveDec,12h
           mov PressEditF,0
           mov EditFlag,0
           mov ActivePEN,0
           mov RegimFlag,0
           mov PressRegimF,0
           mov Flag,0 
           mov ErrInpF,0 
           mov Signal,00000010b
           mov al,Signal
           out 11h,al
           ret       
InitP      ENDP

Start:
           mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
   
           call InitP
InfLoop:   
           call TimeOut
           call TimeInp
           call Time
           call KontrTime
           call RegimB
           call Select           
           call OutPE
           call EditK
           call EditB
           call SelectB
           call KbdInput
           call KbdInContr
           call NxtDigTrf
           call NumSave           
           call NumOut
           jmp  InfLoop
           
;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END
