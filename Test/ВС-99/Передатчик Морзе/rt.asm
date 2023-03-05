RomSize    EQU   4096
NMax       EQU   50
KbdPort    EQU   0
DispPort   EQU   1

IntTable   SEGMENT AT 0 use16

;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS



InitData   SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�
SymImages  db    080h,0beh,080h,0ffh,0fbh,0fdh,080h,0ffh,08ch,0b6h,0b8h,0ffh,0ddh,0B6h,0c9h,0ffh
           db    0f0h,0f7h,080h,0FFh,0b0h,0b6h,086h,0ffh,080h,0b6h,086h,0ffh,0feh,08eh,0f0h,0Ffh
           db    0c9h,0b6h,0c9h,0ffh,099h,0b6h,081h,0ffh,081h,0eeh,081h,0ffh,080h,0b6h,086h,0ffh
           db    080h,0B6h,0c9h,0ffh,080h,0feh,0feh,0FFh,086h,0b6h,080h,0ffh,080h,0b6h,0b6h,0ffh
           db    091h,000h,091h,0Ffh,0b6h,0b6h,0c9h,0FFh,080h,0dFh,080h,0FFh,080h,0ebh,09ch,0Ffh
           db    0bfh,081h,0feh,080h,080h,0FDh,080h,0ffh,080h,0f7h,080h,0FFh,0c1h,0Beh,0c1h,0Ffh
           db    080h,0Feh,080h,0ffh,080h,0f6h,0f9h,0FFh,0c1h,0Beh,0beh,0ffh,0feh,080h,0feh,0fFh
           db    0b0h,0b7h,080h,0ffh,0f1h,080h,0f1h,0FFh,088h,0f7h,088h,0ffh,080h,0bFh,000h,0ffh
           db    0f0h,0f7h,080h,0FFh,080h,087h,080h,0ffh,080h,087h,080h,03Fh,080h,0B7h,0cfh,0ffh
           db    080h,0b7h,088h,0FFh,0b6h,0b6h,0c1h,0Ffh,080h,0f7h,080h,080h,089h,0F6h,080h,0fFh
           db    0FEH,080h,0b7h,0cFh,082h,0deh,082h,0FFh,0FFh,0efh,09Fh,0FFh,0FFh,0dbh,0FFh,0FFh
           db    0FFh,0ebh,09fh,0FFh,0FFh,0b0h,0FFh,0FFh,0Fdh,0a6h,0F9h,0FFh,0FFh,0bfh,0FFh,0FFh
           db    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0ffh,0FFh,0FFh,0FFh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh

symimages1 DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h
        
KodMorze    dw   1101101101101100b  ;0
            dw   1011011011011000b  ;1
            dw   1010110110110000b  ;2
            dw   1010101101100000b  ;3
            dw   1010101011000000b  ;4
            dw   1010101010000000b  ;5
            dw   1101010101000000b  ;6
            dw   1101101010100000b  ;7
            dw   1101101101010000b  ;8
            dw   1101101101101000b  ;9
            dw   1011000000000000b  ;�
            dw   1101010100000000b  ;�
            dw   1011011000000000b  ;�
            dw   1101101000000000b  ;�
            dw   1101010000000000b  ;�
            dw   1000000000000000b  ;�
            dw   1010101100000000b  ;�
            dw   1101101010000000b  ;�
            dw   1010000000000000b  ;�
            dw   1101011000000000b  ;�
            dw   1011010100000000b  ;�
            dw   1101100000000000b  ;�
            dw   1101000000000000b  ;�
            dw   1101101100000000b  ;o
            dw   1011011010000000b  ;�
            dw   1011010000000000b  ;�
            dw   1010100000000000b  ;c
            dw   1100000000000000b  ;�
            dw   1010110000000000b  ;�
            dw   1101101101100000b  ;�
            dw   1101101011000000b  ;�
            dw   1101010110000000b  ;�
            dw   1101011011000000b  ;�
            dw   1010110101000000b  ;�
            dw   1010110110000000b  ;�
            dw   1011010110000000b  ;�
            dw   1101010110000000b  ;�
            dw   1011011011000000b  ;�
            dw   1011010110101100b  ;,
            dw   1101101101010100b  ;:
            dw   1101011010110100b  ;;
            dw   1101101010110110b  ;!
            dw   1010110110101000b  ;?
            dw   1010101010100000b  ;.
            dw   1101011010110100b  ;;
            dw   1101101010110110b  ;!
            dw   1010110110101000b  ;?
            dw   1010101010100000b  ;.


InitData   ENDS

Data       SEGMENT AT 40h use16
;ochictka   db       (?)
KbdImage   DB    7 DUP(?)
romsoob    db    1280 dup (?)
kodstring  db    128 dup (?)
pusto      db    65 Dup(?)
stringkl   db    512 DUP (?)
EmpKbd     DB    ?   ;䫠� ���⮩ ����������
KbdErr     DB    ?   ;�訡�� ����������
NextDigf   DB    ?  ;������ ��� �ନ�㥬�� ����
newsymvol  db    ?  ;䫠� ������ ������ ᨬ����
peredacha  db    ?  ;䫠� ��।�� 
newadres   dw    ?  ;���� ������ ᨬ���� � ।����㥬�� ��ப�
redaktir   db    ?   ;䫠� ।���஢����
newadrsym  dw    ?
zabo2      db    ?  ;䫠� �����
Nrom       db    ?
Nrom1      db    ?
new1       dw    ?
new        db    ?
INput      db    ?
OUTDispl   db    ?
outll      dw    ?
nagatie    db    ?
online     dw    ?
zb         db    ?
chislo     dw    ?  ;�������⢮ ᨬ����� � ᮮ�饭��
scroll     db    ?  ;䫠� �஫��
Data       ENDS
Code       SEGMENT use16

;����� ࠧ������� ���ᠭ�� ����⠭�

          ASSUME cs:Code,ds:Data,es:InitData


ochistkadispl proc near
           push ds
           push ax
           push bx
           push cx
           lea bx,kodstring
           mov   cx,LENGTH kodstring
zx1:       mov   byte ptr ds:[bx],0bfh
           inc   bx
           loop  zx1
           lea bx,pusto
           mov   cx,Length pusto
zx2:       mov   byte ptr ds:[bx],0ffh
           inc   bx
           loop   zx2
           lea   bx,romsoob
           mov   cx,length romsoob
zx3:       mov   byte ptr ds:[bx],0bfh
           inc   bx
            
           loop   zx3
           pop   cx
           pop   bx
           pop   ax
           pop   ds
           ret
ochistkadispl endp


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
           mov   bl,0FEh             ;� ����� ��室��� ��ப
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

KbdInContr PROC  NEAR
           lea   bx,KbdImage ;����㧪� ����
           mov   cx,7        ;� ����稪� ��ப
           mov   EmpKbd,0    ;���⪠ 䫠���
           mov   KbdErr,0
           mov   dl,0        ;� ������⥫�
KIC2:      mov   al,[bx]     ;�⥭�� ��ப�
           mov   ah,8       ;����㧪� ����稪� ��⮢
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
           mov   newsymvol,0ffh ;���⪠ 䫠�� ������ ᨬ����
           cmp   EmpKbd,0FFh ;����� ���������?
           jz    NDT1        ;���室, �᫨ ��
           cmp   KbdErr,0FFh ;�訡�� ����������?
           jz    NDT1        ;���室, �᫨ ��
           lea   bx,KbdImage ;����㧪� ����
           mov   dx,0        ;���⪠ ������⥫�� ���� ��ப� � �⮫��
NDT3:      mov   al,[bx]     ;�⥭�� ��ப�
           and   al,11111111b;�뤥����� ���� ����������
           cmp   al,11111111b;��ப� ��⨢��?
           jnz   NDT2        ;���室, �᫨ ��
           inc   dh          ;���६��� ���� ��ப�
           inc   bx           ;����䨪��� ����
           jmp   SHORT NDT3
NDT2:      shr   al,1        ;�뤥����� ��� ��ப�
           jnc   NDT4        ;��� ��⨢��? ���室, �᫨ ��
           inc   dl          ;���६��� ���� �⮫��
           push  ax 
           mov   al,dh
           pop   ax
           jmp   SHORT NDT2
NDT4:      mov   cl,3        ;��ନ஢��� ����筮�� ���� ����
           shl   dh,cl
           or    dh,dl
           mov   NextDigf,dh  ;������ ���� ����
          ; MOV   al,dh
          ; out   4,al
           mov   newsymvol,000h          
           cmp   nextdigf,30h
           ja    ndt1
           mov   nagatie,0ffh
NDT1:      ret
NxtDigTrf  ENDP

Delay      proc  near  ;���������
           push  cx
           mov   cx,0ffeh
DelayLoop:
           inc   cx
           dec   cx
           inc   cx
           dec   cx
           loop  DelayLoop
         
           mov   cx,0ffeh
DelayLoop1:
           inc   cx
           dec   cx
           inc   cx
           dec   cx
           loop  DelayLoop1
           mov   cx,0ffeh
DelayLoop2:
           inc   cx
           dec   cx
           inc   cx
           dec   cx
           loop  DelayLoop2
           mov   cx,0ffeh
DelayLoop3:
           inc   cx
           dec   cx
           inc   cx
           dec   cx
           loop  DelayLoop3
           pop   cx
           ret
Delay      endp  



symvol     proc near 
           mov   newadres,000h
           mov   cx,000h
nach:      lea   si,stringkl
           mov   ax,newadres
           add   si,ax
           xor   ah,ah
           lea   bx,kodstring
           add   bx,cx
           mov   al,ds:[bx]
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           mov   ds:[si],al
           inc   bx
           inc   si
           mov   al,es:[bx]
           mov   ds:[si],al
           inc   bx
           inc   si 
           mov   al,es:[bx]
           mov   ds:[si],al
           inc   bx
           inc   si
           mov   al,es:[bx]
           mov   ds:[si],al
           
           mov   ax,newadres
           add   ax,004h            
           mov   newadres,ax
           inc   cx
           cmp   cx,080h  ;20h
           jbe   nach
NO1:      
    
           ret
symvol     ENDP

Preobsym   proc near 
           cmp   KbdErr,0FFh
           jz    NO2
           cmp   EmpKbd,0FFh
           jz    NO2
           cmp   newsymvol,0FFh
           jz    NO2
           cmp   redaktir,0ffh
           jz    NO2
           cmp   chislo,1fdh  ;07d
           ja    NO2
           cmp   NextDigf,02fh
           jg    NO2
           add   chislo,004h 
          
           lea   si,kodstring
           mov   ax,new1
           add   si,ax
           xor   ah,ah
           mov   al,NextDigf
           shl   ax,2
           mov   ds:[si],al
           cmp   new1,80h      ;20h
           jge   NO2
           add   new1,001h
NO2:       ret
preobsym   ENDP




zaboi     proc   near
          push   ax
          push   bx
          cmp    redaktir,0ffh
          jz     a1
          in     al,2
          cmp    al,11111110b
          je     a2
          cmp    zb,001h  
          je     a2        
          jmp    a1
a2:       mov    zb,000h
          cmp    chislo,000h
          je     a1
          lea    bx,kodstring
          sub    new1,001h
          add    bx,new1        
          mov    byte ptr ds:[bx],0bfh
          sub    chislo,004h
          sub    newadres,004h       
a1:      
          pop    bx
          pop    ax
          ret 
zaboi     endp          

funktion  proc   near
          mov    al,nextDigf
          cmp    EmpKbd,0FFh
          jz     out1
          cmp    NextDigf,00110111b
          jb     out3
          mov    zb,001h
out3:     cmp    newsymvol,0FFh
          jz     out2
          cmp    NextDIgf,00110000b
          je     PL
          cmp    NextDigf,00110001b
          je     Mi
          jmp    out2
PL:       cmp    nrom,0
          jb     out2
          cmp    nrom,9
          je     out2
          add    nrom,1      
          jmp    out2
Mi:       cmp    nrom,9
          ja     out2
          cmp    nrom,0
          je     out2
          sub    nrom,001h
          jmp    out10
out1:     jmp    out11
out10:          
out2:     cmp    NextDigf,00110110b
          je     INPUT1
          jmp    out4
input1:   mov    online,000h
          mov    input,001h
out4:     cmp    NextDigf,00110100b
          je     output1
          jmp    out5
output1:  mov    online,000h
          mov    outdispl,001h         
out5:     cmp    NextDigf,00110101b
          je     output3
          jmp    out6
output3:  mov    online,000h
          mov    redaktir,000h
out6:     cmp    NextDigf,00110010b
          je     outline
          jmp    out7
outline:  
          mov    peredacha,0ffh
out7:     cmp    NextDigf,00110011b
          je     outline1
          jmp    out11
outline1: mov    online,0ffh    
out11:    ret
funktion  endp




recordrom   proc   near
            cmp  input,001h
            je   in1
            jmp  end1
in1:        mov  cx,length kodstring
            lea  bx,kodstring
            lea  si,romsoob
            mov  al,nrom
            mov  dl,080h
            mul  dl
            add  si,ax
repeat:     mov  al,ds:[bx]
            mov  ds:[si],al
            inc  si
            inc  bx
            loop  repeat
            mov  input,000h
end1:       ret
recordrom   endp

inputrom    proc  near
            cmp   outdispl,001h
            je    in2
            jmp   end2
in2:        mov   cx,length kodstring
            mov   new,001h
            mov   newadres,000h
            mov   chislo,000h
            mov   new1,006h
            mov   redaktir,0ffh
            mov   scroll,000h
            lea   bx,romsoob
            lea   si,kodstring
            mov   al,nrom
            mov   dl,080h
            mul   dl
            add   bx,ax
repeat1:    mov   al,ds:[bx]
            mov   ds:[si],al
            inc   bx 
            inc   si
            loop   repeat1
            mov  outdispl,000h
end2:       ret
inputrom    endp

redak      proc   near  
           push   bx
           cmp    redaktir,0ffh
           jz     end7
           mov    scroll,0ffh
           cmp    new,000h
           je     end7
           mov    new,00h
           mov    newadres,000h
           mov    chislo,000h
           
           mov    new1,000h
           mov    cx,080h    ;020hkolvo symvolov
           lea    bx,kodstring
next2:    
           mov    al,ds:[bx]
           cmp    al,0bfh
           out    4,al
           je     qw4
           add    newadres,004h
           add    chislo,004h
           add    new1,001h
qw4:      
           inc    bx
           loop   next2

end7:     
           pop   bx
           ret
redak      endp

case       proc near
           lea   bx,stringkl
           mov   dx,chislo
           add   bx,dx ;��ᢠ����� ᬥ饭�� 
           sub   bx,040h
           mov   ch,1  ;Indicator Counter ����㦠�� 1 ᬥ饭��
OutNextInd:
           mov   al,0 ; �।���⥫쭠� ���⪠
           out   8,al  ;Turn off cols ���⪠ ����
           mov   al,ch ;����㧪� 1        
           out   9,al  ;Turn on current matrix  ������ ��⨢��� 1 ������
           mov   cl,1  ;Col Counter
OutNextCol:
           mov   al,0
           out   8,al        ;Turn off cols
           mov   al,ds:[bx]
           not   al
           out   7,al        ;Set rows
           mov   al,cl
           out   8,al        ;Turn on current col
           
           shl   cl,1
           
           inc   bx
           jnc   OutNextCol
           shl   ch,1
          ; cmp   ch,16
           jnz   OutNextInd
           cmp   scroll,0ffh
           je    asd1         
           cmp   chislo,200h ;  80h���ᨬ��쭮� �᫮ ᨬ����� ������
           jg    asd2
           add   chislo,004h
           jmp   asd1
asd2:      mov   chislo,000h           
 
asd1:     

infloop:  ret
case      endp   

NumOut1    PROC  NEAR
           xor   ah,ah
           mov   al,nrom
           lea   bx,SymImages1
           add   bx,ax
           mov   al,es:[bx]
           out   DispPort,al
           ret
NumOut1    ENDP

Outlin     Proc  near
           cmp   peredacha,000h
           jz    konec
           cmp   redaktir,000h
           jz    konec          
           lea   si,kodstring
           mov   ax,outll
           out   2,al
           add   si,ax
           mov   al,ds:[si]
           lea   bx,kodmorze
           cmp   al,0bfh
           je    konec1
           xor   ah,ah
           mov   ax,outll
           shr   ax,1
          
           add   bx,ax
           mov   word ptr ax,es:[bx]
           ; out    2,al
           mov   cx,00fh
nextkod:   shl   ax,1
           push  ax
           jae   nool
           mov   al,003h
           jmp   dalee
nool:      mov   al,000h
dalee:     call  delayline
           out   3,al
         
           pop   ax
           loop  nextkod
           add   outll,001h
           jmp   konec
konec1:    mov   peredacha,000h
           mov   outll,000h
           mov   al,000h
           out   3,al
konec:     ret
outlin     endp

onlinekod  proc near
           push  ax
           push  bx
           mov   al,000h
           out   3,al
          
           cmp   online,0ffh
           jz    onmorzeline
           jmp   fined
onmorzeline: 
           cmp   nagatie,000h
           je    fined
           mov   newadres,000h
           mov   chislo,000h
           mov   new1,000h
           mov   outll,000h
           mov   outdispl,000h
           mov   redaktir,0ffh
           mov   peredacha,000h
           lea   bx,kodmorze
           xor   ah,ah
           ;cmp   nextdigf,000h
           ;je    fined
           mov   al,NextDigf
         
           shl   ax,1
           add   bx,ax
           mov   word ptr ax,es:[bx]
          ; shr   ax,8
         ;  out   2,al 
           mov   cx,00fh
nextkd2:   shl   ax,1
           push  ax
           jae   nooll2
          
           mov   al,003h
           jmp   dalee12
nooll2:    mov   al,000h
dalee12:   call  delayline
           out   3,al
           
           pop   ax
           loop  nextkd2       
           mov   nagatie,000h
fined:     pop   bx
           pop   ax
           ret
onlinekod  endp
                   
Delayline  proc  near
        
           push  ax
           push  cx                 
                             ;�८�ࠧ������ ��稭����� �� �஭�� ������
           mov   al,0
           out   5,al
           mov   al,1
           out   5,al
           
WaitRdy:
           in    al,4        ;��� ������� �� ��室� Rdy ��� - �ਧ���
                             ;�����襭�� �८�ࠧ������
           test  al,1
           jz    WaitRdy
           
           in    al,5        ;���뢠�� �� ��� �����
           shr   al,4
           add   al,001h
           out   6,al
           xor   ch,ch
           mov   cl,al
cikl:      call  delay
           loop  cikl
           pop   cx 
           pop   ax
           ret
delayline  endp



Start:

           mov   ax,Data
           mov   ds,ax
           mov   ax,InitData
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
            
           lea   sp,StkTop
;����� ࠧ��頥��� ��� �ணࠬ��
           mov   nagatie,000h
           mov   online,000h
           mov   peredacha,00h
           mov   outll,0000h
           mov   new,001h
          ; mov   NextDigf,0bfh
           mov   newadres,0
           mov   scroll,0ffh
           mov   newadrsym,000h
           mov   redaktir,000h
           mov   new1,000h
           mov   chislo,0000h
           mov   zabo2,0ffh
           mov   zb,000h
           mov   nrom,000h
           call  ochistkadispl 
tyr:       
           mov   zabo2,000h
           mov   dx,0
           call  KbdInput
           call  KbdInContr
           call  NxtDigTrf
           call  onlinekod
           call  funktion
           call  preobsym
           call  zaboi
           call  symvol
           call  inputrom
           call  recordrom
           call  redak
           call  outlin         
           call  case
           call  NumOut1
          ; call  outlin 
           ;call  onlinekod
           call  delay
           call  delay
           
         
       
           jmp   tyr           
  
;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
