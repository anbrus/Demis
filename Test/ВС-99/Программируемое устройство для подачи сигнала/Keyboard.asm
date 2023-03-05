RomSize    EQU   4096
NMax       EQU   50
KbdPort    EQU   0


Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

Data       SEGMENT AT 0
ValDiv     DB    ?
ValDiv1    DW    ?
DetVi      DB    ?
DetBel     DB    ?
ValDe      DB    ?
CountD     DB    ?
CountS     DB    ?
Count      DB    ?
KbdImage   DB    4 DUP(?)
EmpKbd     DB    ?
KbdErr     DB    ?
NextDig    DB    ?
FunDig     DB    ?
DispPort   db    ?
DChas      db    ?
DMin       db    ?
MasChas    DB    20 DUP(?)
MasMin     DB    20 DUP(?)
Data       ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Code,ss:Stk

           ;��ࠧ� 16-����� ᨬ�����: "0", "1", ... "F"
SymImages  DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh;,06Fh,079h,033h,07Ch,073h,063h

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
           xor   dx,dx
           cmp   KbdErr,0FFh
           jz    NO1
           cmp   EmpKbd,0FFh
           jz    NO1
           xor   ah,ah
           cmp   NextDig,9
           ja    NO1
           mov   al,NextDig
           mov   FunDig,al
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           add   DispPort,01h           
           mov   dl,DispPort
           out   dx,al
           ;cmp   DispPort,04h
           ;jna   No1
           ;mov   DispPort,00h
           
NO1:       ret
NumOut     ENDP

VvodP      Proc Near

Mu4:       cmp   DispPort,1
           jnz   MU1
           mov   al,FunDig
           shl   al,4
           mov   DChas,al
           jz    MV
MU1:       cmp   DispPort,2
           jnz   MU2
           mov   al,FunDig
           or    DChas,al
           jz    MV
Mu2:       cmp   DispPort,3
           jnz   MU3
           mov   al,FunDig
           shl   al,4
           mov   DMin,al
           jz    MV
Mu3:       cmp   DispPort,4
           jnz   MV
           mov   al,FunDig
           or    DMin,al
           mov   DispPort,00h
           
           



MV:        ret
VvodP      endp

Zero       PROC NEAR
           
           mov   al,0
           out   7,al
           mov   al,0
           out   5,al
           mov   CountS,0
           mov   Count,0
           mov   cx,20          
cle1:      lea   bx,MasChas
           mov   al,0
           mov   [bx],al
           inc   bx
           loop  cle1   
           
           mov   Count,0
           mov   cx,20          
cle11:     lea   bx,MasMin
           mov   al,0
           mov   [bx],al
           inc   bx
           loop  cle11              
           
           
           mov   ValDiv,0
           mov   DetBel,0           
           mov   DChas,0
           mov   DMin,0
           
           mov  al,03fh
           out  1,al
           mov  al,03fh
           out  2,al
           mov  al,03fh
           out  3,al
           mov  al,03fh
           out  4,al
           ret
Zero       ENDP

DetVal     PROC NEAR
           mov   al,NextDig
           cmp   al,15
           jnz   DV           
           mov   NextDig,17
           inc   ValDiv
           cmp   ValDiv,2
           mov   al,ValDiv
           out   6,al
           jna   Dv
           mov   ValDiv,0 
DV:        ret
DetVal     ENDP           


ValDelay   PROC NEAR
           
                     
MV3:       cmp   ValDiv,0
           jz    Md
           cmp   ValDiv,1
           jz    Mv1
           cmp   ValDiv,2
           jz    Mv2
           mov   ValDiv,0
           jmp   Mv3

Md:        mov   ValDiv1,100       
           jmp   MVE

MV1:       mov   ValDiv1,10
           jmp   MVE

MV2:       mov   ValDiv1,1   



MVE:       ret
ValDelay   ENDP



Delay      Proc Near


           push  ax
           push  bx
           xor   ax,ax
           xor   bx,bx
           
M1:        inc   ax           
           cmp   ax,0fffh
           jnz   M1
           xor   ax,ax
           inc   bx
           mov   dx,48h
           cmp   bx,dx           
           jnz   M1
           pop   ax
           pop   bx
           
           
           ret
Delay      Endp

Clear      PROC NEAR
           mov   al,NextDig
           cmp   al,12
           jnz   MC                      
           mov   cx,20
           mov   Count,0                      
           mov   CountS,0
           
           mov   al,03fh
           out   1,al
           out   2,al
           out   3,al
           out   4,al
           lea   bx,MasChas
cle:       mov   al,0
           mov   [bx],al
           inc   bx
           loop  cle          

           mov   cx,20
                      
           lea   bx,MasMin
cleM:      mov   al,0
           mov   [bx],al
           inc   bx
           loop  cleM          

MC:        ret
Clear      Endp

Delete     PROC NEAR
           mov   al,NextDig
           cmp   al,14
           jnz   De           
           mov   NextDig,17

           dec   CountS
           lea   bx,MasMin
           add   bl,CountS
           mov   cl,CountS
           
           
Che:       mov   al,[bx+1]
           mov   [bx],al
           inc   bx           
           inc   cx
           cmp   cl,Count
           jnz   Che
           




           lea   bx,MasChas
           add   bl,CountS
           mov   cl,CountS
           
           
Che1:      mov   al,[bx+1]
           mov   [bx],al
           inc   bx           
           inc   cx
           cmp   cl,Count
           jnz   Che1
           
           dec   Count
           
           mov   CountS,0


De:        ret
Delete     Endp





Save       PROC NEAR
           mov   al,NextDig
           cmp   al,11
           jnz   MT           
           mov   NextDig,17
           
           mov   al,DChas
           lea   bx,MasChas
           add   bl,Count
           mov   [bx],al
           
           mov   al,DMin     
           lea   bx,MasMin
           add   bl,Count
           mov   [bx],al
           inc   Count




MT:         ret
Save       Endp




Show       Proc near
           
           
           mov   al,NextDig
           cmp   al,13
           jnz   sh101          
           mov   NextDig,17           
                  
           mov   bl,Count      
           cmp   bl,CountS
           jz    sh
           
           mov   al,CountS
           out   6,al
           
           lea   bx,MasMin
           add   bl,CountS
           mov   al,[bx]
           jmp   sh67
sh101:     jmp   sh111           


sh67:      lea   bx,SymImages
           and   al,0fh
           add   bl,al
           mov   al,es:[bx]
           out   4,al
           
           lea   bx,MasMin
           add   bl,CountS
           mov   ah,[bx]
           
           
           lea   bx,SymImages
           and   ah,0f0h
           shr   ah,4
           add   bl,ah
           mov   al,es:[bx]
           out   3,al
           jmp   sh66
sh:        jmp   sh88   
           
           
           
           
sh66:      lea   bx,MasChas
           add   bl,CountS
           mov   al,[bx]
           
                      
           lea   bx,SymImages
           and   al,0fh
           add   bl,al
           mov   al,es:[bx]
           out   2,al
           
           lea   bx,MasChas
           add   bl,CountS
           mov   ah,[bx]
           
           
           lea   bx,SymImages
           and   ah,0f0h
           shr   ah,4
           add   bl,ah
           mov   al,es:[bx]
           out   1,al
           
           
           inc   CountS
           jmp   sh111
           
sh88:      mov   CountS,0     
sh111:     ret
Show       Endp

DelayMD    PROC NEAR

           push  ax
           push  bx
           xor   ax,ax
           xor   bx,bx
           
DMD:       inc   ax           
           cmp   ax,0fffh
           jnz   DMD
           xor   ax,ax
           inc   bx
           cmp   bx,48h           
           jnz   DMD
           pop   ax
           pop   bx
           

           ret
DelayMD    ENDP

ErrorM     PROC NEAR
           mov   al,NextDig
           cmp   al,11
           jnz   Em
           
           mov   bh,DChas
           and   bh,0fh
           mov   bl,DChas
           and   bl,0f0h
           or    bh,bl
           cmp   bh,23h
           jna   Em1

           mov   al,1
           out   5,al
           
           call DelayMD
           
           mov   al,0
           out   5,al

           mov   al,03fh           
           
           out   1,al
           out   2,al
           
           mov   DChas,0
           
           
Em1:       mov   bh,DMin
           and   bh,0fh
           mov   bl,DMin
           and   bl,0f0h
           or    bh,bl
           cmp   bh,59h
           jna   Em

           mov   al,1
           out   5,al
 
           call DelayMD

           mov   al,0
           out   5,al

           mov   al,03fh           
           
           out   3,al
           out   4,al
           mov   DMin,0
           
Em:        ret
ErrorM     Endp





ErrorD     PROC NEAR
           
           mov   al,NextDig
           cmp   al,10
           jnz   En
           
           
En2:       mov   bh,DChas
           and   bh,0fh
           mov   bl,DChas
           and   bl,0f0h
           or    bh,bl
           cmp   bh,23h
           jna   En1

           mov   al,1
           out   5,al
           
           call DelayMD
           
           mov   al,0
           out   5,al

           mov   al,03fh           
           
           out   1,al
           out   2,al
           
           
           mov   DChas,0
           
           
En1:       mov   bh,DMin
           and   bh,0fh
           mov   bl,DMin
           and   bl,0f0h
           or    bh,bl
           cmp   bh,59h
           jna   En

           mov   al,1
           out   5,al
 
           call DelayMD
           call DelayMD
           call DelayMD

           mov   al,0
           out   5,al

           mov   al,03fh           
           
           
           out   3,al
           out   4,al
           mov   DMin,0

                                         
           
En:        ret
ErrorD     Endp

RunTime    PROC NEAR
           
           xor   dx,dx
           cmp   KbdErr,0FFh
           jz    M3
           cmp   EmpKbd,0FFh
           jz    M3
           mov   al,NextDig
           cmp   al,10
           jnz   M3
          
           call  ErrorD
M21:       call  Detect
           
           call  ValDelay
           mov   cx,ValDiv1
MDV:       call  DetZv
           call  DetPr
           call  Bell
           in    al,2
           cmp   al,0FEh
           jz    m3
           
           call  Delay           
           loop  MDV
           mov   ah,DMin
           inc   ah
           mov   DMin,ah
           lea   bx,SymImages
           and   ah,0fh
           add   bl,ah
           mov   al,es:[bx]
           cmp   ah,9
           ja    M9
           out   4,al
           jna   M22
           jmp   M88

M22:       jmp   M21
           
M88:

           call  ValDelay
           mov   cx,ValDiv1
MDV1:      call  Delay           
           loop  MDV1
m9:        mov   al,03fh
           
           out   4,al           
           shr   DMin,4
           inc   DMin
           jmp   M77
M3:        jmp   M31           
           
M77:           
           mov   ah,DMin
           lea   bx,SymImages
           add   bl,ah
           mov   al,es:[bx]
           shl   DMin,4
           cmp   ah,6
           jz    M4
           out   3,al           
           jnz   M2
           call  ValDelay
           mov   cx,ValDiv1
MDV2:      call  Delay           
           loop  MDV2

M4:        mov   al,03fh

           out   4,al
           out   3,al
           mov   DMin,0
           
          ; call  Delay           
   
           mov   ah,DChas
           inc   ah
           mov   DChas,ah
           lea   bx,SymImages
           and   ah,0fh
           add   bl,ah
           mov   al,es:[bx]
           mov   bh,DChas
           and   bh,0fh
           mov   bl,DChas
           and   bl,0f0h
           or    bh,bl
           cmp   bh,23h
           ja    M6
           cmp   ah,9
           ja    M5
           out   2,al
           jna   M2
           jmp   M66

M2:        jmp   M21
           
M66:

M5:        mov   al,03fh
           
           out   4,al
           out   3,al
           out   2,al


           shr   DChas,4
           inc   DChas
           mov   ah,DChas
           lea   bx,SymImages
           shl   DChas,4
           add   bl,ah
           mov   al,es:[bx]
           cmp   ah,2
           ja    M6
           out   1,al
           jna   M2

M6:        mov   al,03fh
                 
           out   4,al
           out   3,al
           out   2,al
           out   1,al
           mov   DChas,0
           jmp   M2

M31:        ret





RunTime    ENDP




Bell       PROC NEAR
           push  Dx
           cmp   Count,0
           jz    Bee
           cmp   DetBel,1
           jb    Bee1
           ja    Bee2
Bee3:      cmp   ValDe,16           
           jz    BeE1
           mov   al,1
           call  Vibor
           xor   dx,dx
           mov   dl,DetVi
           out   dx,al
           inc   ValDe
           jmp   BeE
Bee2:      mov   ValDe,0      
           mov   DetBel,1
           jmp   Bee3
           
BeE1:      mov   DetBel,0 
           mov   ValDe,0
           mov   al,0
           call  Vibor
           xor   dx,dx
           mov   dl,DetVi
           out   dx,al
BeE:       pop   dx
           ret
Bell       ENDP           

Vibor      PROC NEAR
           push  ax
           in    al,1
           cmp   al,0FFh
           jnz   MEV
           mov   DetVi,7
           jmp   MEV1
MEV:       mov   DetVi,9
MEV1:      pop   ax
           ret
Vibor      ENDP




Detect     PROC NEAR

           push  ax
           push  bx
           push  cx
           push  dx
           
                     
           mov   CountD,0
Det1:      mov   cl,DMin
           mov   ch,DChas
           

           lea   bx,MasMin
           add   bl,CountD
           cmp   [bx],cl
           jnz   Det
           
           lea   bx,MasChas
           add   bl,CountD
           cmp   [bx],ch           
           jnz   Det          
           inc   DetBel
           
Det:       inc   CountD
           mov   al,CountD
           cmp   al,Count
           jnz   Det1
           

Dee:       pop   ax
           pop   bx
           pop   cx
           pop   dx
           ret
Detect     Endp

DetPr      PROC NEAR
           in    al,3
           cmp   al,0Feh
           jnz   DER           
           mov   al,1
           out   010h,al
           jmp   DER1
DER:       mov   al,0
           out   010h,al
DER1:      ret
DetPr      ENDP

DetZv      PROC NEAR
           in    al,1
           cmp   al,0Feh
           jnz   DEz           
           mov   al,1
           out   011h,al
           jmp   DEz1
DEz:       mov   al,0
           out   011h,al
DEz1:      ret
DetZv      ENDP

Regim      PROC NEAR
           push  ax
           in    al,3
           cmp   al,0Feh
           pop   ax
           jnz    IL

           mov   al,NextDig
           cmp   al,11
           jz    IL1
           mov   al,NextDig
           cmp   al,12
           jz    IL1           
           mov   al,NextDig
           cmp   al,13
           jz    IL1
           mov   al,NextDig
           cmp   al,14
           jnz   IL
IL1:       mov   NextDig,17

IL:        ret
Regim      ENDP






Start:
           mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           mov   KbdErr,0
           mov   DispPort,0h


           call  Zero

InfLoop:   call  KbdInput
           call  KbdInContr
           call  NxtDigTrf
           call  NumOut
           call  Regim
           call  DetVal
           call  VvodP
           call  ErrorD
           call  ErrorM
           call  Save
           call  Clear
           call  Show           
           call  Delete           
           call  DetZv
           call  DetPr
           call  RunTime
           
           jmp   InfLoop
           

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END
