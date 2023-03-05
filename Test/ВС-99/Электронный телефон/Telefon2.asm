RomSize    EQU   4096
NMax       EQU   50
KbdPort    EQU   0
KbdPort2   EQU   25h

Stk        SEGMENT AT 100h
           DW    30 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

Data       SEGMENT AT 0
InOut      DB    ?
indicator  DB    ?
seltel     DB    ?
select     DB    ?
ind1       DB    ?
Ind2       DB    ?
Pointer    DW    ?
KbdImage   DB    4 DUP(?)
EmpKbd     DB    ?
KbdErr     DB    ?
NextDig    DB    ?
DispPort   DW    ?
RecTel     DB    12 DUP(?)
Data1      DB    12 DUP(?) 
telefon    DB    12 DUP(?)
Flag       DB    ?
Point      DW    ?
Point2     DW    ?
PointBl    DW    ?
PointBl2   DW    ?
Black      DB    ?
BlackNav1  DW    ?

EmpKbd2    DB    ?
KbdImage2  DB    4 DUP(?)
KbdErr2    DB    ?
NextDig2   DB    ?
Data12     DB    12 DUP(?)
DispPort2  DW    ?
RecTel2    DB    12 DUP(?)
telefon2   DB    12 DUP(?)
Flag21     DB    ?
Point21    DW    ?
Point22    DW    ?
PointBl21  DW    ?
PointBl22  DW    ?
Black2     DB    ?
BlackNav2  DW    ?

MemArr     DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)           
MemArr2    DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)           
BlackSp    DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)           
BlackSp2   DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
           DB    12 DUP(?)
Data       ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Code,ss:Stk
          
SymImages  DB    3h,2h,1h,0h,6h,5h,4h,0h,9h,8h,7h,0h,0Ah,0h,0Ah,0h           
ImageNum   DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,0Eh,07Fh,05Fh,03Fh

SelectTel  PROC  NEAR
           in    al,23h
           mov   ah,al
           mov   cl,select
           cmp   al,0FFh
           jz    sel2
sel3:      in    al,23h
           cmp   al,ah
           jz    sel3
           mov   al,seltel
           and   al,00000010b
           cmp   al,2
           jz    sel2
           not   cl
           mov   select,cl
sel2:      cmp   cl,0h
           jnz   sel1
           mov   al,2h
           or    seltel,00000001b
           jmp   sel
sel1:      mov   al,1h
           and   seltel,11111110b
sel:       out   22h,al
           mov   al,ind1
           out   21h,al
           mov   al,ind2
           out   41h,al
           mov   al,InOut
           out   23h,al
           ret
SelectTel  ENDP

Open       PROC  NEAR
           in    al,21h
           cmp   al,0FEh
           jnz   op3
           or    seltel,00000100b
           and   InOut,00000011b
           or    InOut,00000100b
           jmp   op2
op3:       in    al,21h
           cmp   al,0FDh
           jnz   op1
           and   seltel,00000011b
           and   InOut,00000011b
           or    InOut,00001000b
           jmp   op1
op1:       in    al,41h
           cmp   al,0FEh
           jnz   op4
           or    seltel,00000100b
           and   InOut,00001100b
           or    InOut,00000001b
           jmp   op2
op4:       in    al,41h
           cmp   al,0FDh
           jnz   op2
           and   seltel,00000011b
           and   InOut,00001100b
           or    InOut,00000010b
op2:       ret           
Open       ENDP

BlackSerf  PROC  NEAR
           in    al,21h
           cmp   al,0EFh
           jz    bsL1
           cmp   al,0DFh
           jz    bsR1
           cmp   al,0BFh
           jz    bsL22
           cmp   al,07Fh
           jz    bsR2
           jmp   Endbs          
bsL22:     jmp   bsL2
bsL1:      in    al,21h
           cmp   al,0EFh
           jz    bsL1
           mov   cx,12
           cmp   BlackNav1,0
           jnz   bs1
           mov   BlackNav1,96
bs1:       lea   bx,data1
           lea   si,BlackSp
           sub   BlackNav1,12
           add   si,BlackNav1
           mov   dx,1h
bs2:       mov   al,[si]
           mov   [bx],al
           out   dx,al
           inc   dx
           inc   bx
           inc   si
           loop  bs2
           mov   Flag,0Dh
           jmp   Endbs
           
bsR1:      in    al,21h
           cmp   al,0DFh
           jz    bsR1
           cmp   BlackNav1,84
           jne   bs3
           mov   BlackNav1,0
           jmp   bs4
bs3:       add   BlackNav1,12
bs4:       mov   cx,12
           lea   bx,data1
           lea   si,Blacksp
           add   si,BlackNav1
           mov   dx,1
bs5:       mov   al,[si]
           mov   [bx],al
           out   dx,al
           inc   dx
           inc   bx
           inc   si
           loop  bs5
           mov   Flag,0Dh
           jmp   Endbs   
bsR2:      in    al,21h
           cmp   al,07Fh
           jz    bsR2
           cmp   BlackNav2,84
           jne   bs32
           mov   BlackNav2,0
           jmp   bs42
bs32:      add   BlackNav2,12
bs42:      mov   cx,12
           lea   bx,data12
           lea   si,Blacksp2
           add   si,BlackNav2
           mov   dx,50h
bs52:      mov   al,[si]
           mov   [bx],al
           out   dx,al
           inc   dx
           inc   bx
           inc   si
           loop  bs5
           mov   Flag21,0Dh
           jmp   Endbs              
bsL2:      in    al,21h
           cmp   al,0BFh
           jz    bsL2
           mov   cx,12
           cmp   BlackNav2,0
           jnz   bs12
           mov   BlackNav2,96
bs12:      lea   bx,data1
           lea   si,BlackSp2
           sub   BlackNav2,12
           add   si,BlackNav2
           mov   dx,50h
bs22:      mov   al,[si]
           mov   [bx],al
           out   dx,al
           inc   dx
           inc   bx
           inc   si
           loop  bs22
           mov   Flag21,0Dh
           jmp   Endbs
Endbs:     ret
BlackSerf  ENDP

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
           out   KbdPort,al  ;��⨢��� ��ப�
           in    al,KbdPort  ;���� ��ப�
           and   al,0Fh      ;����祭�?
           cmp   al,0Fh
           jz    KI1         ;���室, �᫨ ���
           mov   dx,KbdPort  ;��।�� ��ࠬ���
           call  VibrDestr   ;��襭�� �ॡ����
           mov   [si],al     ;������ ��ப�
KI2:       in    al,KbdPort  ;���� ��ப�
           and   al,0Fh      ;�몫�祭�?
           cmp   al,0Fh
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
           mov   cx,4        ;� ����稪� ��ப
           mov   EmpKbd,0    ;���⪠ 䫠���
           mov   KbdErr,0
           mov   dl,0        ;� ������⥫�
KIC2:      mov   al,[bx]     ;�⥭�� ��ப�
           mov   ah,4        ;����㧪� ����稪� ��⮢
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

NxtDigTrf  PROC  NEAR
           cmp   EmpKbd,0FFh ;����� ���������?
           jz    NDT1        ;���室, �᫨ ��
           cmp   KbdErr,0FFh ;�訡�� ����������?
           jz    NDT1        ;���室, �᫨ ��
           lea   bx,KbdImage ;����㧪� ����
           mov   dx,0        ;���⪠ ������⥫�� ���� ��ப� � �⮫��
NDT3:      mov   al,[bx]     ;�⥭�� ��ப�
           and   al,0Fh      ;�뤥����� ���� ����������
           cmp   al,0Fh      ;��ப� ��⨢��?
           jnz   NDT2        ;���室, �᫨ ��
           inc   dh          ;���६��� ���� ��ப�
           inc   bx          ;����䨪��� ����
           jmp   SHORT NDT3
NDT2:      shr   al,1        ;�뤥����� ��� ��ப�
           jnc   NDT4        ;��� ��⨢��? ���室, �᫨ ��
           inc   dl          ;���६��� ���� �⮫��
           jmp   SHORT NDT2
NDT4:      mov   cl,2        ;��ନ஢��� ����筮�� ���� ����
           shl   dh,cl
           or    dh,dl
           mov   NextDig,dh  ;������ ���� ����
NDT1:      ret
NxtDigTrf  ENDP

NumOut     PROC  NEAR
           cmp   KbdErr,0FFh
           jz    NO1
           cmp   EmpKbd,0FFh
           jz    NO1 
           add   Flag,1
           cmp   Flag,0Dh
           jae   NO1
           xor   ax,ax
           mov   al,NextDig 
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           lea   bx,ImageNum
           lea   si,data1
           add   bx,ax
           mov   al,es:[bx]
           mov   cx,11
           add   si,10
m1:        mov   dl,[si]
           mov   BYTE PTR[si+1],dl
           dec   si
           loop  m1
           mov   data1,al
           mov   cx,12
           mov   dx,1
           lea   bx,data1
m2:        mov   al,[bx]
           out   dx,al
           inc   bx
           inc   dx
           loop  m2
           
NO1:       ret
NumOut     ENDP

KbdInpt   PROC  NEAR
           lea   si,KbdImage2         ;����㧪� ����,
           mov   cx,LENGTH KbdImage2  ;����稪� 横���
           mov   bl,0FEh             ;� ����� ��室��� ��ப�
KIn4:      mov   al,bl       ;�롮� ��ப�
           out   KbdPort2,al  ;��⨢��� ��ப�
           in    al,KbdPort2  ;���� ��ப�
           and   al,0Fh      ;����祭�?
           cmp   al,0Fh
           jz    KIn1         ;���室, �᫨ ���
           mov   dx,KbdPort2  ;��।�� ��ࠬ���
           call  VibrDestr   ;��襭�� �ॡ����
           mov   [si],al     ;������ ��ப�
KIn2:      in    al,KbdPort2 ;���� ��ப�
           and   al,0Fh      ;�몫�祭�?
           cmp   al,0Fh
           jnz   KIn2         ;���室, �᫨ ���
           call  VibrDestr   ;��襭�� �ॡ����
           jmp   SHORT KIn3
KIn1:      mov   [si],al     ;������ ��ப�
KIn3:      inc   si          ;����䨪��� ����
           rol   bl,1        ;� ����� ��ப�
           loop  KIn4         ;�� ��ப�? ���室, �᫨ ���
           ret
KbdInpt   ENDP

KbdInCtrl  PROC  NEAR
           lea   bx,KbdImage2 ;����㧪� ����
           mov   cx,4        ;� ����稪� ��ப
           mov   EmpKbd2,0    ;���⪠ 䫠���
           mov   KbdErr2,0
           mov   dl,0        ;� ������⥫�
KICo2:     mov   al,[bx]     ;�⥭�� ��ப�
           mov   ah,4        ;����㧪� ����稪� ��⮢
KICo1:     shr   al,1        ;�뤥����� ���
           cmc               ;������� ���
           adc   dl,0
           dec   ah          ;�� ���� � ��ப�?
           jnz   KICo1        ;���室, �᫨ ���
           inc   bx          ;����䨪��� ���� ��ப�
           loop  KICo2        ;�� ��ப�? ���室, �᫨ ���
           cmp   dl,0        ;������⥫�=0?
           jz    KICo3        ;���室, �᫨ ��
           cmp   dl,1        ;������⥫�=1?
           jz    KICo4        ;���室, �᫨ ��
           mov   KbdErr2,0FFh ;��⠭���� 䫠�� �訡��
           jmp   SHORT KICo4
KICo3:     mov   EmpKbd2,0FFh ;��⠭���� 䫠�� ���⮩ ����������
KICo4:     ret
KbdInCtrl  ENDP

NxtDigit  PROC  NEAR
           cmp   EmpKbd2,0FFh ;����� ���������?
           jz    ND1        ;���室, �᫨ ��
           cmp   KbdErr2,0FFh ;�訡�� ����������?
           jz    ND1        ;���室, �᫨ ��
           lea   bx,KbdImage2 ;����㧪� ����
           mov   dx,0        ;���⪠ ������⥫�� ���� ��ப� � �⮫��
ND3:       mov   al,[bx]     ;�⥭�� ��ப�
           and   al,0Fh      ;�뤥����� ���� ����������
           cmp   al,0Fh      ;��ப� ��⨢��?
           jnz   ND2        ;���室, �᫨ ��
           inc   dh          ;���६��� ���� ��ப�
           inc   bx          ;����䨪��� ����
           jmp   SHORT ND3
ND2:       shr   al,1        ;�뤥����� ��� ��ப�
           jnc   ND4         ;��� ��⨢��? ���室, �᫨ ��
           inc   dl          ;���६��� ���� �⮫��
           jmp   SHORT ND2
ND4:       mov   cl,2        ;��ନ஢��� ����筮�� ���� ����
           shl   dh,cl
           or    dh,dl
           mov   NextDig2,dh  ;������ ���� ����
ND1:      ret
NxtDigit ENDP

NumOutO   PROC  NEAR
           cmp   KbdErr2,0FFh
           jz    NOO1
           cmp   EmpKbd2,0FFh
           jz    NOO1            
           add   Flag21,1
           cmp   Flag21,0Dh 
           jae   NOO1
           xor   ax,ax
           mov   al,NextDig2 
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           lea   bx,ImageNum
           lea   si,data12
           add   bx,ax
           mov   al,es:[bx]
           mov   cx,11
           add   si,10
mm1:       mov   dl,[si]
           mov   BYTE PTR[si+1],dl
           dec   si
           loop  mm1           
           mov   data12,al
           mov   cx,12
           mov   dx,50h
           lea   bx,data12
mm2:       mov   al,[bx]
           out   dx,al
           inc   bx
           inc   dx
           loop  mm2
           
NOO1:      ret
NumOutO    ENDP

PreStart   PROC  NEAR
           mov   DispPort,1
           mov   BlackNav1,0
           mov   BlackNav2,0
           lea   bx,MemArr
           lea   di,BlackSp
           lea   si,BlackSp2
           mov   cx,96
m3:        mov   [bx],BYTE PTR 0h
           mov   BYTE PTR[di],0h
           mov   BYTE PTR[si],0h
           inc   di
           inc   bx
           inc   si
           loop  m3
           mov   Flag,0
           mov   Black,0
           mov   Point,0
           mov   Point2,0
           mov   PointBl,0
           mov   PointBl2,0
           mov   KbdErr,0
           mov   cx,12
           xor   ax,ax
           lea   bx,data1
           lea   si,telefon           
m4:        mov   BYTE PTR[bx],0          
           mov   BYTE PTR[si],0
           inc   bx
           inc   si
           loop  m4
           mov   cx,12
           lea   bx,RecTel
           lea   si,RecTel2
mm6:       mov   BYTE PTR[bx],0
           mov   BYTE PTR[si],0
           inc   si
           inc   bx
           loop  mm6           
           mov   select,BYTE PTR 0FFh
           mov   DispPort2,1
           lea   bx,MemArr2
           mov   cx,96
mm3:       mov   [bx],BYTE PTR 0h
           inc   bx
           loop  mm3
           mov   Flag21,0
           mov   Black2,0
           mov   Point21,0
           mov   Point22,0
           mov   PointBl21,0
           mov   PointBl22,0
           mov   KbdErr2,0
           mov   cx,12
           xor   ax,ax
           lea   bx,data12
           lea   si,telefon2
           lea   di,BlackSp2
mm4:       mov   BYTE PTR[bx],0
           mov   BYTE PTR[di],0h
           mov   BYTE PTR[si],0
           inc   bx
           inc   si
           loop  mm4
           mov   Pointer,0
           ret
PreStart   ENDP 

PreStart2  PROC  NEAR
           mov   seltel,0
           mov   indicator,0
           mov   ind1,00000000b
           mov   ind2,00000000b
           mov   InOut,00001010b
           ret
PreStart2  ENDP

Main       PROC  NEAR
           call  SelectTel
           call  Open
           call  KbdInput
           call  KbdInpt
           call  KbdInCtrl
           call  KbdInContr
           call  NxtDigit
           call  NxtDigTrf
           call  Recall2
           call  Recall1
           call  BlackSerf
           call  Buttons
           call  Buttons2
           call  NumOutO
           call  NumOut
Main       ENDP

include    Telefon1.asm
Start:     mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           call  PreStart
           call  PreStart2
InfLoop:   call  Main
           jmp   InfLoop

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END