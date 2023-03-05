           TITLE Zlodey
           JUMPS
           LOCALS @@
           .model small
           .8086
;����뢠���� ����室��� ����⠭��
; - ���⮢           
PORT_ADDR  equ   0
PORT_DATA  equ   4
PORT_FLAGS equ   6
PORT_KB    equ   7

; - 䫠���
FLAG_MODIFY      equ  0001h
FLAG_ROM         equ  0002h
FLAG_SEGM        equ  0004h
FLAG_OFFS        equ  0008h
FLAG_DKS_KS      equ  0010h
FLAG_RAM         equ  0020h
FLAG_AS          equ  0040h
FLAG_AF          equ  0080h       

FLAG_MSG         equ  0100h


; - �����ᮢ ������
KEY_END    equ   0000h
KEY_0      equ   0100h
KEY_1      equ   0101h
KEY_2      equ   0102h
KEY_3      equ   0103h
KEY_4      equ   0104h
KEY_5      equ   0105h
KEY_6      equ   0106h
KEY_7      equ   0107h
KEY_8      equ   0108h
KEY_9      equ   0109h
KEY_A      equ   010ah
KEY_B      equ   010bh
KEY_C      equ   010ch
KEY_D      equ   010dh
KEY_E      equ   010eh
KEY_F      equ   010fh

KEY_RAM    equ   0200h
KEY_ROM    equ   0201h
KEY_SEG    equ   0202h
KEY_OFF    equ   0203h
KEY_DATA   equ   0204h
KEY_INC    equ   0205h
KEY_DEC    equ   0206h
KEY_AS     equ   0207h
KEY_AF     equ   0208h
KEY_TA     equ   0210h
KEY_TD1    equ   0211h
KEY_TD2    equ   0212h
KEY_DKS    equ   0213h
KEY_KS     equ   0214h
KEY_RES    equ   0215h

KeyInfo    struc
keyindex   dw    ?           ;������ ������
col        db    ?           ;��� ��ப�(���ਬ�� ��� 2� ��ப� ���� ��� �㤥� 04h) 
row        db    ?           ;��� �⮫�� 
KeyInfo    ends

ExeInfo    struc
keyindex   dw    ?           ;������ ������
flagoff    dw    ?           ;䫠� ����� �㦭� ����
flagon     dw    ?           ;䫠� ����� �㦭� ���⠢���
exeproc    dw    ?           ;�ᯮ��塞�� �� ���������� ������� ��楤��
param0     dw    ?           ;��।������ ��ࠬ����
ExeInfo    ends


Data       SEGMENT AT 0000h
Key        dw    ?
Flags      dw    ?
Msg        dd    ?
StA        dd    ?
FnA        dd    ?
WrA        dd    ?
Dks        db    ?
Ks         db    ?
Dat        db    ?

org        2048-2
StkTop     label word
Data       ENDS


Code       SEGMENT 
           ASSUME cs:Code, ds:Data

; � ax ��।������ ��ࠬ���, �.�. ���祭�� ����⮩ ������
InsDig     proc
           test Flags, FLAG_DKS_KS    ;�᫨ FLAG_DKS_KS � ��室 �� ��楤���
           jnz  @@ret
           test Flags, FLAG_MODIFY    ;�᫨ FLAG_MODIFY � ������ � ������
           jz   @@isOff               ;������ �� �������� �����
           les  di, WrA
           shl  byte ptr es:[di], 4
           or   es:[di], al
           jmp  @@ret
@@isOff:   test Flags, FLAG_OFFS      ;�᫨ FLAG_OFFS
           jz   @@Seg              
           shl  word ptr WrA[0], 4    ;� ᤢ�� ���������� ᬥ襭��
           or   word ptr WrA[0], ax   ;� ������ � ��� ����� ����        
           jmp  @@ret                 ;��⮬ ��室   
@@Seg:     shl  word ptr WrA[2], 4    ;ᤢ�� ���������� ᥣ����
           or   word ptr WrA[2], ax   ;� ������ ����� ����                   
@@ret:     ret
InsDig     endp

; no param
Empty      proc
           ret
Empty      endp

; � ax ��।������ ��ࠬ���
ModVal     proc
           test  Flags, FLAG_DKS_KS    ;�᫨ FLAG_DKS_KS � ��室 �� ��楤���
           jnz   @@ret
           test  Flags, FLAG_MODIFY    ;�᫨ FLAG_MODIFY � ���६���஢����
           jz    @@isSeg               ;��� ���६���஢����(� ����ᨬ��� �� ��ࠬ���) 
           les   di, WrA               ;������ �� �������� �����
           add   es:[di], al
           jmp   @@ret
@@isSeg:   test  Flags, FLAG_SEGM      ;���� �� ���६���஢����  
           jz    @@Off                 ;��� ���६���஢����  
           add   word ptr WrA[2], ax   ;���������� ᥣ���� ��� 
           jmp   @@ret
@@Off:     add   word ptr WrA[0], ax   ;���������� ᬥ饭��   

@@ret:     ret
ModVal     endp           

LoadAs     proc                        ;����������� ��砫쭮�� ���� ���஢���     
           mov   ax, word ptr WrA[2]
           mov   word ptr StA[2], ax
           mov   ax, word ptr WrA[0]
           mov   word ptr StA[0], ax
           ret
LoadAs     endp

LoadAf     proc                        ;� ����筮��
           mov   ax, word ptr WrA[2]
           mov   word ptr FnA[2], ax
           mov   ax, word ptr WrA[0]
           mov   word ptr FnA[0], ax
           ret
LoadAf     endp

;��楤�� �����⮢�� � ����
;� ��� �஢������� 䫠�� � �८�ࠧ����� ���� ���஢����
;� ax ��室���� ��� ��楤��� ���஢����
TestAll    proc
           mov   cx, ax                      ;��࠭���� ax
@@CheckAs: test  Flags, FLAG_AS              ;�஢�ઠ ����� �� ��砫�� ���� ���஢����  
           jnz    @@CheckAf
           mov   ax, word ptr cs:NoAsMsg[2]  ;�᫨ ��� � ��⠢����� ᮮ⢥����饣� ᮮ�饭��  
           mov   word ptr Msg[2], ax
           mov   ax, word ptr cs:NoAsMsg[0]
           mov   word ptr Msg[0], ax
           jmp   @@ret   
@@CheckAf: test  Flags, FLAG_AF              ;�������筮 � ������ ���ᮬ  
           jnz   @@Test    
           mov   ax, word ptr cs:NoAfMsg[2]
           mov   word ptr Msg[2], ax
           mov   ax, word ptr cs:NoAfMsg[0]
           mov   word ptr Msg[0], ax
           jmp   @@ret
@@Test:                                         ;�᫨ ������ ��� ����
           mov   bp, sp
@@A1       equ   word ptr [bp-04]               ;� �뤥����� ������ � �⥪�
@@A2       equ   word ptr [bp-08]
           sub   sp, 8
           mov   ax, word ptr StA[0]            ;� �ந�������� ���室 � 䨧��᪮�� ����� ��� StA 
           mov   dx, word ptr StA[2]            ;�. ������ ���.48 
           mov   bx, dx                         
           shl   bx, 4                         
           shr   dx, 12                         
           add   ax, bx                       
           adc   dx, 0                           
           and   dx, 0000Fh                     
           mov   @@A1[0], ax                    
           mov   @@A1[2], dx                   
           mov   ax, word ptr FnA[0]           ;�������筮 ��� FnA
           mov   dx, word ptr FnA[2]
           mov   bx, dx
           shl   bx, 4
           shr   dx, 12
           add   ax, bx
           adc   dx, 0
           and   dx, 0000Fh
           mov   @@A2[0], ax
           mov   @@A2[2], dx   
           mov   ax, @@A2[0]                    ;����� �롨ࠥ��� ����� ���� �����  
           mov   dx, @@A2[2]                    ;� ����� ���� 
           sub   ax, @@A1[0]                    ; ��� ⮣� �⮡ �ࠢ��쭮 ����� ���஢���� 
           sbb   dx, @@A1[2]
           jnc   @@start                         
           mov   ax, @@A2[0]
           xchg  ax, @@A1[0]
           mov   @@A2[0], ax
           mov   ax, @@A2[2]
           xchg  ax, @@A1[2]
           mov   @@A2[2], ax 
@@start:   mov   ax, cx                        ; ���室 � �㦭�� ��楤��  
           jmp   ax           
@@ret:     ret
TestAll    endp

;���஢���� �� 設� ����
TestA      proc
           test  Flags, FLAG_RAM       
           jz    @@err
@@A1       equ   word ptr [bp-04]
@@A2       equ   word ptr [bp-08]  
@@cicle:   mov   si, @@A1[0]
           mov   ax, @@A1[2]
           shl   ax, 12
           mov   es, ax 
           mov   ax, es:[si]               ;��࠭���� �祩��
           mov   es:[si], si               ;� �祩�� �����뢠���� �� �� ����   
           mov   bx, es:[si]
           cmp   bx, si                    ;���� �祩�� �ࠢ�������� � �� ᮤ�ন�� 
           jnz   @@err                     ;�᫨ �� �ࠢ��쭮 � ��ନ஢��� ᮮ�饭�� �� �訡�� 
           mov   es:[si], ax               ;���� ����⠭����� �祩��  
           mov   ax, @@A1[0]               ;�஢���� �� ����砭�� ���  
           mov   dx, @@A1[2]
           sub   ax, @@A2[0]
           sbb   dx, @@A2[2]
           or    ax, dx
           jz    @@endtest
           add   @@A1[0], 1                ;� ������஢��� ����  
           adc   @@A1[2], 0
           jmp   @@cicle
@@endtest: mov   ax, word ptr cs:CorrMsg[2] ;����� ���� �ନ஢���� ᮮ�饭��
           mov   word ptr Msg[2], ax
           mov   ax, word ptr cs:CorrMsg[0]
           mov   word ptr Msg[0], ax
           jmp   @@ret
@@err:     mov   ax, word ptr cs:ErrA[2]
           mov   word ptr Msg[2], ax
           mov   ax, word ptr cs:ErrA[0]
           mov   word ptr Msg[0], ax
@@ret:     mov   sp, bp
           ret
TestA      endp           

;��� �� 設� ������, �. �।��� ��� � �祡���
TestD1     proc
           test  Flags, FLAG_RAM  
           jz    @@err
@@A1       equ   word ptr [bp-04]
@@A2       equ   word ptr [bp-08]
             
@@cicle:   mov   si, @@A1[0]
           mov   ax, @@A1[2]
           shl   ax, 12
           mov   es, ax 
                     
           mov   ax, es:[si]
           mov   es:[si], 5555h
           mov   bx, es:[si]
           cmp   bx, 5555h
           jnz   @@err
           
           mov   es:[si], 0AAAAh
           mov   bx, es:[si]
           cmp   bx, 0AAAAh
           jnz   @@err
           
           mov   es:[si], ax
           
           mov   ax, @@A1[0]
           mov   dx, @@A1[2]
           sub   ax, @@A2[0]
           sbb   dx, @@A2[2]
           or    ax, dx
           jz    @@endtest
           add   @@A1[0], 1
           adc   @@A1[2], 0
           jmp   @@cicle
@@endtest: mov   ax, word ptr cs:CorrMsg[2]
           mov   word ptr Msg[2], ax
           mov   ax, word ptr cs:CorrMsg[0]
           mov   word ptr Msg[0], ax
           jmp   @@ret
@@err:     mov   ax, word ptr cs:ErrD[2]
           mov   word ptr Msg[2], ax
           mov   ax, word ptr cs:ErrD[0]
           mov   word ptr Msg[0], ax
@@ret:     mov   sp, bp
           ret
TestD1     endp           


TestD2     proc
           test  Flags, FLAG_RAM  
           jz    @@err
@@A1       equ   word ptr [bp-04]
@@A2       equ   word ptr [bp-08]
             
@@cicle:   mov   si, @@A1[0]
           mov   ax, @@A1[2]
           shl   ax, 12
           mov   es, ax 
                     
           mov   ax, es:[si]
           mov   bx, 6666h
           mov   es:[si], bx
           xor   es:[si], 0FFFFh
           xor   bx, 0FFFFh
           cmp   bx, es:[si]
           jne   @@err         
           mov   bx, 9999h
           mov   es:[si], bx
           xor   es:[si], 0FFFFh
           xor   bx, 0FFFFh
           cmp   bx, es:[si]
           jne   @@err 
           
           mov   es:[si], ax
           
           mov   ax, @@A1[0]
           mov   dx, @@A1[2]
           sub   ax, @@A2[0]
           sbb   dx, @@A2[2]
           or    ax, dx
           jz    @@endtest
           add   @@A1[0], 1
           adc   @@A1[2], 0
           jmp   @@cicle
@@endtest: mov   ax, word ptr cs:CorrMsg[2]
           mov   word ptr Msg[2], ax
           mov   ax, word ptr cs:CorrMsg[0]
           mov   word ptr Msg[0], ax
           jmp   @@ret
@@err:     mov   ax, word ptr cs:ErrD[2]
           mov   word ptr Msg[2], ax
           mov   ax, word ptr cs:ErrD[0]
           mov   word ptr Msg[0], ax
@@ret:     mov   sp, bp
           ret
TestD2     endp  


; ���᫥��� ���������� �� ����஫쭮� �㬬�
TestDKS    proc
           test  Flags, FLAG_ROM
           jz   @@err
@@A1       equ   word ptr [bp-04]
@@A2       equ   word ptr [bp-08]
           
           mov   ks, 0
@@cicle:   mov   si, @@A1[0]
           mov   ax, @@A1[2]
           shl   ax, 12
           mov   es, ax 
                     
           mov   al, es:[si]          
           add   Ks, al
           
           mov   ax, @@A1[0]
           mov   dx, @@A1[2]
           sub   ax, @@A2[0]
           sbb   dx, @@A2[2]
           or    ax, dx
           jz    @@endtest
           add   @@A1[0], 1
           adc   @@A1[2], 0
           jmp   @@cicle
@@endtest: mov   al, es:[si] 
           sub   Ks, al
           mov   al, Ks
           neg   al
           mov   Dks, al
           add   Ks, al
           and   Flags, NOT FLAG_MSG
           jmp   @@ret

@@err:     mov   ax, word ptr cs:ErrMsg[2]
           mov   word ptr Msg[2], ax
           mov   ax, word ptr cs:ErrMsg[0]
           mov   word ptr Msg[0], ax
@@ret:     mov   sp, bp
           ret
TestDKS    endp           

; ���᫥��� ����஫쭮� �㬬�
TestKS     proc
           test  Flags, FLAG_ROM
           jz   @@err
@@A1       equ   word ptr [bp-04]
@@A2       equ   word ptr [bp-08]
           
           mov   ks, 0
@@cicle:   mov   si, @@A1[0]
           mov   ax, @@A1[2]
           shl   ax, 12
           mov   es, ax 
                     
           mov   al, es:[si]          
           add   Ks, al
           
           mov   ax, @@A1[0]
           mov   dx, @@A1[2]
           sub   ax, @@A2[0]
           sbb   dx, @@A2[2]
           or    ax, dx
           jz    @@endtest
           add   @@A1[0], 1
           adc   @@A1[2], 0
           jmp   @@cicle
@@endtest: mov   al, es:[si] 
           mov   Dks, al
           
           and   Flags, NOT FLAG_MSG
           jmp   @@ret

@@err:     mov   ax, word ptr cs:ErrMsg[2]
           mov   word ptr Msg[2], ax
           mov   ax, word ptr cs:ErrMsg[0]
           mov   word ptr Msg[0], ax
@@ret:     mov   sp, bp
           ret
TestKS     endp 

;��⠭���� ��砫��� ������           
Init       proc
           mov   Key, KEY_END
           mov   Flags, FLAG_RAM + FLAG_OFFS
           mov   word ptr StA[0], 0
           mov   word ptr StA[2], 0
           mov   word ptr FnA[0], 0
           mov   word ptr FnA[2], 0
           mov   word ptr WrA[0], 0
           mov   word ptr WrA[2], 0
           mov   Dks, 0
           mov   Ks, 0
           mov   Dat, 0
           ret
Init       endp            
           
;��楤�� �뢮�� ��஢�� ���祭�� �� ���������           
Show       proc
           mov   ax, Flags
           out   PORT_FLAGS, al       ;�뢮� �� ��������� 䫠��� 
           test  Flags, FLAG_MSG      ;�᫨ ���� ᮮ�饭��  
           jz    @@isOff
           mov   cx, 4
           mov   dx, PORT_ADDR
           mov   si, 0
@@cic:     mov   al, byte ptr Msg[si] � �뢮� �� �� ��������
           out   dx,al
           inc   dx
           inc   si
           loop  @@cic                  
           jmp   @@ret
@@isOff:   test  Flags, FLAG_OFFS
           jz    @@isSeg              
           mov   ax, word ptr WrA[0]  ;����㧪� � ax ᬥ饭�� 
           jmp   @@show               ;���஥ ���� �뢥�� �� ��஢� ���������  
@@isSeg:   test  Flags, FLAG_SEGM
           jz    @@dksks
           mov   ax, word ptr WrA[2]  ;����㧪� ᥣ����
           jmp   @@show
@@dksks:   mov   al, Ks               ;����㧪� ����஫쭮� �㬬�
           mov   ah, Dks              ����㧪� ���������� �� ��
@@show:    mov   dx, PORT_ADDR        
           mov   cx, 4
           push  ds
           mov   bx, seg ImageMap     ;ImageMap ���ᠭ� � Code ���⮬� �� ᥣ������
           mov   ds, bx               ;���������� ���� ����㧨�� � ds
           mov   bx, offset ImageMap
@@cicle:   push  ax                   ;��砫� 横�� ��� �뢮�� ���� �� ��������
           and   al, 0Fh              ;�뤥����� ����襩 ��ࠤ�
           xlat 
           out   dx, al               ;�뢮� ����� ����
           pop   ax
           inc   dx
           shr   ax, 4
           loop  @@cicle      
           pop   ds
           mov   es, word ptr WrA[2]  ;����� ��稭����� �뢮� �� ���������  
           mov   di, word ptr WrA[0]  ;������ �� ����� ����� �� �뢥��� ࠭��
           mov   al, es:[di]          ;����㧪� ���� �� ����� es:di (WrA)  
           mov   Dat, al
           push  ds
           mov   cx, 2
           mov   dx, PORT_DATA
           mov   bx, seg ImageMap
           mov   ds, bx
           mov   bx, offset ImageMap
@@cicle2:  push  ax                   ;���� �������祭 �।��饬�
           and   al, 0Fh
           xlat 
           out   dx, al
           pop   ax
           inc   dx
           shr   ax, 4
           loop  @@cicle2      
           pop   ds
@@ret:     ret   
Show       endp
           
;��楤�� ���� ������
;� Key �࠭���� ������ ����⮩ ������
KeyPress   proc
                             
           mov   bx, Key
@@new:     mov   Key, bx
           mov   si, 0                               
@@next:    cmp   cs:KeyMap[si].keyindex, KEY_END  ;�᫨ �� KEY_END �
           mov   bx, cs:KeyMap[si].keyindex       ;�  bx �������� ������ ������
           jz    @@new                            
           mov   al, cs:KeyMap[si].col            ;����� ���� �஢�ઠ ����� �� ��
           out   PORT_KB, al                      ;������ 
           in    al,PORT_KB
           test  al, cs:KeyMap[si].row
           jz    @@tonext                         ;���室 �᫨ ���
           cmp   bx, Key                          ;�஢�ઠ �� �⦠⨥ ������
           je    @@new                            
  
           mov   Key, bx                          ;������ � Key ������ ������  
           jmp   @@ret                            ;� ��室 �� ��楤���   
@@tonext:  add   si, size KeyInfo                 ;����䨪��� si ��� ���室� 

           jmp   @@next                           ;� ᫥���饩 ������

@@ret:     ret 
KeyPress   endp 
          
          
Main       proc
           mov   si, 0
@@cicle:   cmp   cs:ExeMap[si].keyindex, KEY_END   
           je    @@ret                            ;�᫨ �� KEY_END �
           mov   ax, Key                          ;� ᮮ⢥�ᢨ� � ����⮩ �����襩
           cmp   ax, cs:ExeMap[si].keyindex       ;(������ ���ன �࠭���� � Key)
           je    @@do                             ;�믮������� ����᫥���騥 ����⢨�   
           add   si, size ExeInfo                 ;���� ����䨪��� si � 
           jmp   @@cicle                          ;��横�������
           
@@do:      mov   ax, cs:ExeMap[si].flagoff        
           not   ax
           and   Flags, ax                        ;᭨������ ����室��� 䫠��
           mov   ax, cs:ExeMap[si].flagon
           or    Flags, ax                        ;� ���⠢������ ����
           mov   ax, cs:ExeMap[si].param0         ;� ax ����頥��� �㦭� ��ࠬ���
           
           test  Flags, FLAG_MSG+FLAG_OFFS+FLAG_SEGM+FLAG_DKS_KS  ;�᫨ �� ���� �� 䫠��� �� ��⨢��
           jnz   @@run
           or    Flags, FLAG_OFFS                  ;� �⮡ࠦ��� ᬥ饭��         
           
@@run:     call  cs:ExeMap[si].exeproc            ;� ��뢠���� �㦭�� ��楤�� 

@@ret:     ret
Main       endp
           
Start:     mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ss,ax
           lea   sp,StkTop
           call  init                    
Cicle:     call  Show
           call  KeyPress
           call  Main
           jmp   Cicle

ImageMap   db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           db    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h
       
NoAsMsg    dd    68786F5Bh
NoAfMsg    dd    68786F63h
ErrMsg     dd    00736060h 
CorrMsg    dd    33786060h
ErrA       dd    7360606Fh
ErrD       dd    7360607Ch
       
KeyMap     KeyInfo <KEY_0, 01h, 10h>
           KeyInfo <KEY_1, 01h, 08h>
           KeyInfo <KEY_2, 01h, 04h>
           KeyInfo <KEY_3, 01h, 02h>
           KeyInfo <KEY_4, 02h, 10h>
           KeyInfo <KEY_5, 02h, 08h>
           KeyInfo <KEY_6, 02h, 04h>
           KeyInfo <KEY_7, 02h, 02h>
           KeyInfo <KEY_8, 04h, 10h>
           KeyInfo <KEY_9, 04h, 08h>
           KeyInfo <KEY_A, 04h, 04h>
           KeyInfo <KEY_B, 04h, 02h>
           KeyInfo <KEY_C, 08h, 10h>
           KeyInfo <KEY_D, 08h, 08h>
           KeyInfo <KEY_E, 08h, 04h>
           KeyInfo <KEY_F, 08h, 02h>
           KeyInfo <KEY_SEG, 10h, 10h>
           KeyInfo <KEY_OFF, 10h, 08h>
           KeyInfo <KEY_DATA,10h, 04h>
           KeyInfo <KEY_RAM, 01h, 01h>
           KeyInfo <KEY_ROM, 02h, 01h>
           KeyInfo <KEY_INC, 04h, 01h>
           KeyInfo <KEY_DEC, 08h, 01h>
           KeyInfo <KEY_AS,  10h, 02h>
           KeyInfo <KEY_AF,  10h, 01h>
           KeyInfo <KEY_TA,  20h, 10h>
           KeyInfo <KEY_TD1, 20h, 08h>
           KeyInfo <KEY_TD2, 20h, 04h>
           KeyInfo <KEY_DKS, 20h, 02h>
           KeyInfo <KEY_KS,  20h, 01h>
           KeyInfo <KEY_RES, 40h, 10h>
           KeyInfo <KEY_END>

ExeMap     ExeInfo <KEY_0, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 00h> 
           ExeInfo <KEY_1, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 01h> 
           ExeInfo <KEY_2, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 02h> 
           ExeInfo <KEY_3, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 03h>
           ExeInfo <KEY_4, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 04h>
           ExeInfo <KEY_5, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 05h>
           ExeInfo <KEY_6, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 06h>
           ExeInfo <KEY_7, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 07h>
           ExeInfo <KEY_8, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 08h>
           ExeInfo <KEY_9, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 09h>
           ExeInfo <KEY_A, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 0ah>
           ExeInfo <KEY_B, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 0bh>
           ExeInfo <KEY_C, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 0ch>
           ExeInfo <KEY_D, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 0dh>
           ExeInfo <KEY_E, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 0eh>
           ExeInfo <KEY_F, FLAG_MSG+FLAG_DKS_KS, 0, InsDig, 0fh>
           ExeInfo <KEY_SEG, FLAG_MSG+FLAG_OFFS+FLAG_DKS_KS+FLAG_MODIFY, FLAG_SEGM, Empty, 0>
           ExeInfo <KEY_OFF, FLAG_MSG+FLAG_SEGM+FLAG_DKS_KS+FLAG_MODIFY, FLAG_OFFS, Empty, 0>
           ExeInfo <KEY_DATA, FLAG_MSG+FLAG_DKS_KS, FLAG_MODIFY, Empty, 0>
           ExeInfo <KEY_RAM, FLAG_MSG+FLAG_DKS_KS+FLAG_ROM, FLAG_RAM, Empty, 0>
           ExeInfo <KEY_ROM, FLAG_MSG+FLAG_RAM+FLAG_DKS_KS, FLAG_ROM, Empty, 0>
           ExeInfo <KEY_INC, FLAG_MSG, 0, ModVal, +1>
           ExeInfo <KEY_DEC, FLAG_MSG, 0, ModVal, -1>
           ExeInfo <KEY_AS, FLAG_MSG, FLAG_AS, LoadAs, 0>
           ExeInfo <KEY_AF, FLAG_MSG, FLAG_AF, LoadAf, 0>
           ExeInfo <KEY_TA, 0, FLAG_MSG, TestAll, TestA>
           ExeInfo <KEY_TD1, 0, FLAG_MSG, TestAll, TestD1>
           ExeInfo <KEY_TD2, 0, FLAG_MSG, TestAll, TestD2>
           ExeInfo <KEY_DKS, FLAG_MSG+FLAG_OFFS+FLAG_MODIFY, FLAG_MSG+FLAG_DKS_KS, TestAll, TestDKS>
           ExeInfo <KEY_KS, FLAG_MSG+FLAG_OFFS+FLAG_MODIFY, FLAG_MSG+FLAG_DKS_KS, TestAll, TestKS>
           ExeInfo <KEY_RES, FLAG_AS+FLAG_AF+FLAG_MODIFY+FLAG_DKS_KS+FLAG_ROM, FLAG_RAM, Empty, 0>
           ExeInfo <KEY_END, 0, 0, 0, 0> 
           

           org   0FF0h
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
