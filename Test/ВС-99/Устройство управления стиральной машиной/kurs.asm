.386
;������ ���� ��� � �����
RomSize    EQU   4096

IntTable   SEGMENT AT 0 use16
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

UserS      STRUC
           timep   db ?
           tempp   db ?
           ratiop  dw ?
           revp    db ?    
UserS      ENDS  

Data       SEGMENT AT 40h use16
KbdImage   DB 4 DUP(?)
KbdErr     DB ?
EmpKbd     DB ?
NextDig    DB ?
UserSet    UserS 6 DUP (?)
Flag1      DB ?
Flag2      DB ?
Flag3      DB ?
FlagErP    DB ?
Flag       DB ?  ;���� ०��� ࠡ���
FlagPar    DB ?  ;���� ��ࠬ��� ࠡ���
FlagErIn   DB ?  ;���� �訡�� �� ����� ��ࠬ���
Revers     DB ?
BufData    DB 7 DUP (?)
BufDigit   DB 7 DUP (?)
BufDigit1  DB 2 DUP (?)
BufData1   DB 2 DUP (?)
FlagDur    DB ?
FlagDtm    DB ?
FlafWater  DB ?
speed      DW ?
ot         DB ?
dlit       db ?
dlit1      db ?
;dlit2      db ?
dii        DW ?
temmm      db ?

Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT AT 100h use16
;������ ����室��� ࠧ��� �⥪�
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�
InitData   ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�
           ASSUME cs:Code,ds:Data,es:Code,ss:Stk

SymImages  DB    01Bh,01Ah,05Fh,07Fh
           DB    0Eh,07bh,05Bh,04Dh
           DB    05Eh,076h,0Ch,03Fh
           
SymImage   DB    00h,00h,09h,08h
           DB    07h,06h,05h,04h
           DB    03h,02h,01h,00h
           DB    00h,00h,00h,00h
           
KbdPort    EQU   9
DispPort   EQU   0
NMax       EQU   50
         
;�롮� ०��� ࠡ��� ��設�
FuncPrep   PROC  near
           mov   Flag,0
           mov   FlagPar,0
           mov   FlagErIn,0
           mov   KbdErr,0
           mov   EmpKbd,0
           mov   Flag1,00000001b
           mov   Flag2,00000010b
           mov   Flag3,00000100b
           mov   FlagDur,0 
           mov   FlagDtm,0
           mov   revers,0
           mov   BufData,  00001011b ;2 ���� �६���
           mov   BufData+1,00001011b ;1 ���� �६���
           mov   BufData+2,00001011b ;2 ���� ⥬�������
           mov   BufData+3,00001011b ;1 ���� ⥬�������
           mov   BufData+4,00001011b ;3 ���� ᪮��� +6 +5 +4
           mov   BufData+5,00001011b ;2 ���� ᪮���  1  2  3
           mov   BufData+6,00001011b ;1 ���� ᪮���
           mov   BufDigit1,0
           mov   BufDigit1+1,0
           mov   UserSet[0].timep,10111011b
           mov   UserSet[0].tempp,10111011b
           mov   UserSet[0].ratiop,0000101110111011b
           mov   UserSet[0].revp,0
           mov   di,25
    prep:  mov   UserSet[di].timep,10111011b
           mov   UserSet[di].tempp,10111011b
           mov   UserSet[di].ratiop,0000101110111011b
           mov   UserSet[di].revp,0
           dec   di
           dec   di
           dec   di
           dec   di
           dec   di
           jnz   prep
           ret
FuncPrep   ENDP

VibrDestr  PROC  NEAR
           pusha
VD1:       mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
           mov   bh,0        ;���� ����稪� ����७��
VD2:       in    al,dx       ;���� ⥪�饣� ���ﭨ�
           cmp   ah,al       ;����饥 ���ﭨ�=��室����?
           jne   VD1         ;���室, �᫨ ���
           inc   bh          ;���६��� ����稪� ����७��
           cmp   bh,NMax     ;����� �ॡ����?
           jne   VD2         ;���室, �᫨ ���
           mov   al,ah       ;����⠭������� ���⮯�������� ������
           popa
           ret
VibrDestr  ENDP

SelReg     PROC  near
           in    al,0000
           call  VibrDestr
           cmp   al,0     
           je    nul
           cmp   al,11111110b    ;������ ०�� "��ઠ"?
           je    stirka
           cmp   al,11111101b    ;������ ०�� "�⦨�"?
           je    otzim
           cmp   al,11111011b    ;०�� ��ન "��ଠ���"?   
           je    norm         
           cmp   al,11110111b    ;०�� ��ન "���"?
           je    soft        
           cmp   al,11101111b    ;०�� ��ન "��०��"?
           je    flex     
           cmp   al,11011111b    ;०�� ��ન "���짮��⥫�᪨�"?
           je    user   
           ;cmp   al,10111111b    ;������� ०�� ��⠭���� ����. ०����?
           ;je    change  
           
           in    al,0001
           call  VibrDestr
           cmp   al,11111110b
           je    time 
           cmp   al,11111101b
           je    temp  
           cmp   al,11111011b
           je    ratio 
           cmp   al,11110111b
           je    SelRegEx
           
      nul: jmp   SelRegEx 
   stirka: mov   Flag,10000000b    ;"��ઠ"
           jmp   SHORT SelRegEx 
    otzim: mov   Flag,00000001b    ;"�⦨�"  
           jmp   SHORT SelRegEx 
     norm: mov   flag,11000000b    ;"��ଠ���"
           jmp   SHORT SelRegEx
     soft: mov   flag,10100000b    ;"���"
           jmp   SHORT SelRegEx
     flex: mov   flag,10010000b    ;"��०��"
           jmp   SHORT SelRegEx
     user: mov   flag,10001000b    ;"���짮��⥫�᪨�"
           jmp   SHORT SelRegEx 
   ;change: mov   flag,10000100b    ;��⠭���� ०���
           ;jmp   SHORT SelRegEx                   
   
     time: mov   FlagPar,00000001b    
           jmp   SHORT SelRegEx
     temp: mov   FlagPar,00000010b    
           jmp   SHORT SelRegEx
    ratio: mov   FlagPar,00000100b    
           jmp   SHORT SelRegEx     

 SelRegEx: ret
SelReg     ENDP

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

DispForm   PROC  near
           cmp   EmpKbd,0FFh ;����� ���������?
           jz    DFEx           

           cmp   nextdig,00000000b 
           jne   setrev
           mov   EmpKbd,0FFh
           cmp   REvers,00000000b
           je    setup
           mov   revers,00000000b
           jmp   setrev
    setup: mov   REvers,01000000b

   setrev: cmp   EmpKbd,0FFh ;����� ���������?
           jz    DFEx     
           
           cmp   FlagPar,00000000b
           jz    DFEx
           
           cmp   FlagPar,00000001b
           je    time1
           cmp   FlagPar,00000010b
           je    temp1
           cmp   FlagPar,00000100b
           je    ratio1
           jmp   DFEx
           
    time1: mov   dl,bufdata
           mov   bufdata+1,dl
           mov   al,nextdig
           mov   bufdata,al  
           jmp   DFEx
    temp1: mov   dl,bufdata+2
           mov   bufdata+3,dl
           mov   al,nextdig
           mov   bufdata+2,al
           jmp   DFEx
   ratio1: mov   dl,bufdata+5
           mov   bufdata+6,dl
           mov   dl,bufdata+4
           mov   bufdata+5,dl
           mov   al,nextdig
           mov   bufdata+4,al 
           jmp   DFEx     
     
     DFEx: ;mov   al,revers
           ;out   000ch,al
           ret
DispForm   ENDP

SetPolReg  proc 
           cmp   flag,10001000b
           je    polzz
           ;cmp   flag,10000100b
           ;je    SetPolz
           jmp   sel

           ;in    al,0000
           ;call  VibrDestr
           ;cmp   al,10111111b
    mov   flagpar,00h
   
    polzz: in    al,0002h
           cmp   al,11111110b
           mov   di,0
           je    klj
           cmp   al,11111101b
           mov   di,5  ;type UserSet
           je    klj
           cmp   al,11111011b
           mov   di,10
           je    klj
           cmp   al,11110111b
           mov   di,15
           je    klj
           cmp   al,11101111b
           mov   di,20
           je    klj
           cmp   al,11011111b
           mov   di,25
           je    klj
           
           in    al,0000
           call  VibrDestr
           cmp   al,10111111b
           je    save
           jmp   sel

      klj: mov   dii,di
           xor   ah,ah
           mov   al,UserSet[di].timep
           shl   ax,4
           shr   al,4
           mov   bufdata+1,ah
           mov   bufdata,al

           xor   ah,ah
           mov   al,UserSet[di].tempp
           shl   ax,4
           shr   al,4
           mov   bufdata+3,ah
           mov   bufdata+2,al

           mov   ax,UserSet[di].ratiop
           mov   bufdata+6,ah
           xor   ah,ah
           shl   ax,4
           mov   bufdata+5,ah
           shr   al,4
           mov   bufdata+4,al
          
           mov    al,UserSet[di].revp
           mov    revers,al
           
           jmp   sel

           
     
     save: mov   di,dii
           xor   ax,ax
           mov   al,bufdata+3
           shl   al,4
           or    al,bufdata+2
           mov   UserSet[di].tempp,al
           
           xor   ax,ax
           mov   al,bufdata+1
           shl   al,4
           or    al,bufdata
           mov   UserSet[di].timep,al
           
           xor   ax,ax
           mov   ah,bufdata+6
           mov   al,bufdata+5
           shl   al,4
           or    al,bufdata+4
           mov   UserSet[di].ratiop,ax

           mov   al,revers
           mov   UserSet[di].revp,al
           
           jmp   SHORT sel

  SetPolz: in    al,0002h
           cmp   al,11111110b
           mov   di,0
           je    set
           cmp   al,11111101b
           mov   di,5
           je    set
           cmp   al,11111011b
           mov   di,10
           je    set
           cmp   al,11110111b
           mov   di,15
           je    set
           cmp   al,11101111b
           mov   di,20
           je    set
           cmp   al,11011111b
           mov   di,25
           je    set
           jmp   sel
                  
    set:   xor   ax,ax
           mov   al,bufdata+3
           shl   al,4
           or    al,bufdata+2
           mov   UserSet[di].tempp,al
           
           xor   ax,ax
           mov   al,bufdata+1
           shl   al,4
           or    al,bufdata
           mov   UserSet[di].timep,al
           
           xor   ax,ax
           mov   ah,bufdata+6
           mov   al,bufdata+5
           shl   al,4
           or    al,bufdata+4
           mov   UserSet[di].ratiop,ax

           mov   al,revers
           mov   UserSet[di].revp,al
           
           jmp   SHORT sel

      sel: ret       
SetPolReg  endp

SetR       proc
           cmp   flag,11000000b    ;"��ଠ���"
           je    normm
           cmp   flag,10100000b    ;"���"
           je    softt
           cmp   flag,10010000b    ;"��०��"
           je    flexx
           cmp   Flag,00000001b
           je    ottt
           jmp   SetRex
    normm: mov   flag3,00h
           mov   bufdata+6,00001010b
           mov   bufdata+5,00000110b
           mov   bufdata+4,00001011b
           mov   revers,00000000b
           mov   ot,0
           jmp   SetRex
    softt: mov   flag3,00h
           mov   bufdata+6,00001010b
           mov   bufdata+5,00001011b
           mov   bufdata+4,00001011b
           mov   revers,01000000b
           mov   ot,0
           jmp   SetRex
    flexx: mov   flag3,00h
           mov   bufdata+6,00001011b
           mov   bufdata+5,00000110b
           mov   bufdata+4,00001011b
           mov   revers,01000000b
           mov   ot,0
           jmp   SetRex
           
     ottt: ;mov   flagpar,00000100b
           mov   ot,1
           mov   revers,0
           mov   flag1,0
           mov   flag2,0
           mov   flag3,0
           jmp   SetRex  
             
   SetRex: ret
SetR       endp

ValueCtr   PROC  near
           lea   si,Bufdata
           lea   di,Bufdigit
           mov   cl,7
  LoopDP:  mov   al,[si]        
           lea   bx,SymImage  
           add   bx,ax             
           mov   al,es:[bx]
           mov   [di],al
           inc   si
           inc   di
           loop  LoopDP
 
           cmp   FlagPar,00000001b
           jz    timeCtr
           cmp   FlagPar,00000010b
           jz    tempCtr
           cmp   FlagPar,00000100b
           jz    RatioCtr
           jmp   SHORT VCEx

  timeCtr: mov   al,bufdigit+1
           shl   al,4
           or    al,bufdigit
           cmp   al,00000001b
           jl    tEr
           cmp   al,00010101b
           jg    tEr

           mov   flag1,00000000b
           jmp   SHORT VCEx
   
      tEr: mov   flag1,00000001b
           jmp   SHORT VCEx

  tempCtr: mov   al,bufdigit+3
           shl   al,4
           or    al,bufdigit+2
           cmp   al,00110000b
           jl    tmEr
           cmp   al,01111001b
           jg    tmEr

           mov   flag2,00000000b
           jmp   SHORT VCEx
           
     tmEr: mov   flag2,00000010b
           jmp   SHORT VCEx      

 RatioCtr: mov   al,bufdigit+6
           shl   al,4
           or    al,bufdigit+5
           cmp   al,00000101b
           jl    rEr
           cmp   al,00100101b
           jg    rEr

           mov   flag3,00000000b
           jmp   SHORT VCEx
          
      rEr: mov   flag3,00000100b
           jmp   SHORT VCEx

     VCEx: xor   al,al
           or    al,flag1
           or    al,flag2
           or    al,flag3
           mov   FlagErP,al
           ;out   000Ah,al  
           ret
ValueCtr   ENDP

InfContr   PROC  near
           cmp   KbdErr,0FFh
           jz    ICEx
           cmp   EmpKbd,0FFh
           jz    ICEx

           mov   al,NextDig        
           lea   bx,SymImages  
           add   bx,ax             
           mov   al,es:[bx]
           cmp   al,01Ah
           je    clr
           jmp   SHORT ICEx

      clr: cmp   FlagPar,00000001b
           je    timeClr
           cmp   FlagPar,00000010b
           je    tempClr
           cmp   FlagPar,00000100b
           je    ratioClr            

  timeClr: mov   bufdata,00001011b
           mov   bufdata+1,00001011b
           jmp   SHORT ICEx   
  tempClr: mov   bufdata+2,00001011b
           mov   bufdata+3,00001011b
           jmp   SHORT ICEx
 ratioClr: mov   bufdata+4,00001011b
           mov   bufdata+5,00001011b
           mov   bufdata+6,00001011b
           jmp   SHORT ICEx

     ICEx: ret
InfContr   ENDP

NumOut     PROC  NEAR
           cmp   KbdErr,0FFh
           jz    NOEx

           lea   bx,SymImages
           mov   al,[si]
           add   bx,ax
           mov   al,es:[bx]
           out   dx,al

           inc   dx
           mov   al,[si+1]
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           out   dx,al

           inc   dx 
           mov   al,[si+2]
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           out   dx,al

     NOEx: ret
NumOut     ENDP

FlagOut    PROC NEAR
           mov   al,Flag
           out   dispport+7,al
           mov   al,FlagErP
           shl   al,3
           or    al,FlagPar
           or    al,revers
           out   dispport+8,al
           ret
FlagOut    ENDP

Delay      PROC NEAR
           push  cx
           mov cx,speed
           add cx,100h          
           add cx,100h  
           add cx,100h  

DelayLoop: inc cx
           dec cx
           inc cx
           dec cx
           inc cx
           dec cx
           inc cx
           dec cx
           loop DelayLoop
          
           pop   cx
           ret
Delay      ENDP

dpp        proc
           cmp   dlit1,00001111b ;00010101b
           jnz    s1
           mov   al,5bh
           mov   bl,0ch 
           jmp   s15 
       s1: cmp   dlit1,00001110b ; 00010100b
           jnz    s2
           mov   al,4dh
           mov   bl,0ch
           jmp   s15 
       s2: cmp   dlit1,00001101b ;00010011b
           jnz    s3
           mov   al,5eh
           mov   bl,0ch
           jmp   s15 
       s3: cmp   dlit1,00001100b ;00010010b
           jnz    s4
           mov   al,76h
           mov   bl,0ch 
           jmp   s15 
       s4: cmp   dlit1,00001011b  ; 00010001b
           jnz    s5
           mov   al,0ch
           mov   bl,0ch
           jmp   s15 
       s5: cmp   dlit1,00001010b    ;00010000b
           jnz    s6
           mov   al,3fh 
           mov   bl,0ch 
           jmp   s15 
       s6: cmp   dlit1,00001001b
           jnz    s7
           mov   al,5fh
           mov   bl,3fh
           jmp   s15 
       s7: cmp   dlit1,00001000b
           jnz    s8
           mov   al,7fh
           mov   bl,3fh
           jmp   s15 
       s8: cmp   dlit1,00000111b
           jnz    s9
           mov   al,0eh
           mov   bl,3fh
           jmp   s15 
       s9: cmp   dlit1,00000110b
           jnz    s10
           mov   al,7bh
           mov   bl,3fh
           jmp   s15 
      s10: cmp   dlit1,00000101b
           jnz    s11
           mov   al,5bh
           mov   bl,3fh
           jmp  s15 
      s11: cmp   dlit1,00000100b  
           jnz   s12
           mov   al,4dh
           mov   bl,3fh
           jmp   s15 
      s12: cmp   dlit1,00000011b
           jnz    s13
           mov   al,5eh
           mov   bl,3fh
           jmp   s15 
      s13: cmp   dlit1,00000010b
           jnz   s14 
           mov   al,76h
           mov   bl,3fh
           jmp   s15   
      s14: cmp   dlit1,00000001b
           jnz   s155  
           mov   al,0ch
           mov   bl,3fh
           jmp   s15 
    s155:  mov   al,3fh
           mov   bl,3fh

      s15: out   DispPort,al
           mov   al,bl
           out   DispPort+1,al
           ret
dpp        endp 


RunProc    PROC
           in    al,0001h
           call  VibrDestr
           cmp   al,11110111b
           jne   RPEx1

           and   flagerp,00000111b
           cmp   flagerp,00000000b
           jne   RPEx1
           jmp   kkk 
              
    RPEx1: jmp  far ptr RPEx

      kkk: mov   al,0
           out   000Eh,al
           out   000Fh,al
           
           mov   al,10000000b     ;�������� "����"
           out   0010h,al

           cmp   ot,1
           je    ot11
           mov   al,00000001b
           out   000Fh,al
           mov   cx,0
           jmp   lll
           
     ot11: jmp   far ptr ot2    

      lll: mov   al,0
           out   0011h,al
           mov   al,1
           out   0011h,al
           
WaitRdy:   in    al,4
           inc   cx
           cmp   cx,1900       ;wait time
           je    WaterEr
           test  al,1
           jz    WaitRdy
           
           in    al,3        ;���뢠�� �� ��� �����
           out   000Ah,al    
           cmp   al,0E0h
           jl    temper1
        
           jmp   lll       ;� ��稭��� ���� ��� ������
  
  WaterEr: mov   al,00000001b
           out   000Eh,al
           jmp   far ptr RPEx
 
 
  temper1: mov   al,bufdigit+3
           shl   al,4
           or    al,bufdigit+2
           mov   temmm,al
           
           mov   al,00000000b
           out   000Fh,al
           mov   cx,0
   temper: mov   al,0
           out   0012h,al
           mov   al,1
           out   0012h,al
           
WaitRdy1:  in    al,6
           inc   cx
           cmp   cx,1900       ;wait time
           je    TempErr
           test  al,1
           jz    WaitRdy1
           
           in    al,5
           out   000Bh,al    
           cmp   al,temmm
           jg    ot2 
                        
           
        
           jmp   temper

TempErr:   mov   al,00000010b
           out   000Eh,al
           jmp   far ptr RPEx


      GOw: mov   dl,02h
           mov   di,1
           mov   bx,1

      ot2: mov   al,bufdigit+1
           shl   al,4
           or    al,bufdigit
           mov   dlit1,al
           
           cmp   dlit1,00010101b
           jnz   h1
           mov   al,0fh
           jmp   lp
       h1: cmp   dlit1,00010100b
           jnz   h2
           mov   al,00eh
           jmp   lp
       h2: cmp   dlit1,00010011b
           jnz   h3
           mov   al,00dh
           jmp   lp 
       h3: cmp   dlit1,00010010b
           jnz   h4
           mov   al,00ch
           jmp   lp   
       h4: cmp   dlit1,00010001b
           jnz   h5
           mov   al,000bh
           jmp   lp
       h5: cmp   dlit1,00010000b
           jnz   lp
           mov   al,00ah
           jmp   lp                          
           
       lp: mov   dlit1,al
           shl   al,1
           mov   dlit,al  

      ot1: mov   dl,02h
           mov   di,1
         
           mov   ah,bufdigit+6
           shl   ah,4
           or    ah,bufdigit+5

           cmp   ah,00001001b
           jl    g22            
           cmp   ah,00010100b
           jl    g33
           cmp   ah,00011001b
           jl    g44
           cmp   ah,00100101b
           jl    g55

      g22: mov   speed,56000  
           jmp   rt1
      g33: mov   speed,40535  
           jmp   rt1     
      g44: mov   speed,35555
           jmp   rt1
      g55: mov   speed,20000
           jmp   rt1   
 
       rt1:cmp   revers,01000000b
           jne   rt2
           mov   bx,0
      
       rt: call  delay
           mov   ax,di
           out   DispPort+12,ax
           mul   dl
           mov   di,ax
           cmp   ax,100h
           jne   rt

           inc   bx           
           cmp   bx,0000000000000100b
           mov   di,1
           jne   rt  

           DEC   DLIT
           jz    ggg1
           
           dec   dlit1
           call  dpp
           
           mov   di,1
           mov   bx,1

     rear: call  delay
           mov   ax,di
           div   dl
           out   DispPort+12,ax
           mov   di,ax
           cmp   ax,00000001b
           jne   rear
           
           inc   bx
           cmp   bx,0000000000000100b
           jne   rear
           
           ;dec   dlit1
           ;call  dpp
           
           mov   bx,1
           dec   dlit
           jnz   rt
           jmp   ur1
     ;rt33: dec   dlit1
          ; call  dpp    

          ; jmp   rt

      rt2: call  delay
           mov   ax,di
           div   dl
           out   DispPort+12,ax
           mov   di,ax
           cmp   ax,00000001b
           jne   rt2
           
           dec   dlit
           jnz   rt22
           
           jmp   ur1 
           
     rt22: mov   cl,dlit
           and   cl,00000001b
           cmp   cl,00000001b
           je    outd 
           jmp   rt2
    
     outd:            
           dec   dlit1
           call  dpp             

           jmp   rt2
           
     eee:  cmp   ot,0
           jne   RPEx

     ggg1: 
           mov   FlafWater,00000010b
           mov   al,FlafWater
           out   000Fh,al


      ur1: mov   al,00000010b
           out   000Fh,al
           mov   cx,0
      
      yyy: mov   al,0
           out   0011h,al
           mov   al,1
           out   0011h,al
           
WaitRdy3:  in    al,4
           inc   cx
           cmp   cx,1900
           je    Danger1
           test  al,1
           jz    WaitRdy3
          
           in    al,3        ;���뢠�� �� ��� �����
           out   000Ah,al    
           cmp   al,00h
           jz    RPEx
        
           jmp   yyy       ;� ��稭��� ���� ��� ������

Danger1:   mov   al,00000001b
           out   000Eh,al
           jmp   far ptr RPEx

      ppp: mov   cl,11111111b
     
     tm11: mov   speed,55555
           call  delay
           mov   al,cl
           out   DispPort+11,al
           shr   al,1
           mov   cl,al
           cmp   al,00000000b
           jne   tm11
           mov   al,0
           out   DispPort+11,al
           jmp   RPEx
           
  ; Danger: mov   al,00000001b
      ;     out   000Eh,al
   
     RPEx: mov   al,0
           out   DispPort+10,al
           out   DispPort+11,al
           out   0010h,al
           ;out   000Eh,al
           out   000Fh,al
           out   000Ah,al
           ret
RunProc    ENDP

;����㧪� ��ࠬ��஢ ०���� ࠡ���
Start:     mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           call  FuncPrep
;����� ࠧ��頥��� ��� �ணࠬ��
 MainLoop: call  selreg
           call  KbdInput
           call  KbdInContr
           call  NxtDigTrf
           call  DispForm
           call  SetPolReg
           call  SetR 
           call  ValueCtr  
           call  InfContr
           call  RunProc
           call  FlagOut
            ;�⮡ࠦ���� �६��� ��ન
           lea   si,bufdata
           mov   dx,dispport
           call  NumOut
            ;�⮡ࠦ���� ⥬������� ����
           lea   si,bufdata+2
           mov   dx,dispport+2
           call  NumOut
            ;�⮡ࠦ���� ᪮��� ��饭��
           lea   si,bufdata+4
           mov   dx,dispport+4
           call  NumOut
           jmp   MainLoop
;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END