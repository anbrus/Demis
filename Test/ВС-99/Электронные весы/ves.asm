.386

RomSize    EQU   4096

ADC0       equ  0            ;��� ����襥
ADC1       equ  1            ;��� ���襥
ADCRDY     equ  2            ;
ADCSTART   equ  10h          ;
KEY0       equ 3             ;���������
KEY1       equ 4             ;���������
NMAX       equ 5             ;����প� ����������
CENAINDICATOR equ 4          ;
VESINDICATOR equ 3           ;
ITOGINDICATOR equ 14         ;

Data       SEGMENT AT 0 use16
adcnull    dw ?              ;
adcnew     dw ?              ;
adcnew1     dw ?             ;
adcwork    dw ?              ;
adcwork1   dw ?              ;
minus      db ?              ;
strpos     db ?              ;
CenaStr    db 10 dup (?)     ;
VesStr     db 10 dup (?)     ;
ItogStr    db 10 dup (?)     ;
AllStr     db 10 dup (?)     ;
cena       dw 2 dup (?)      ;
all        dw 2 dup (?)      ;
itog       dw 2 dup (?)      ;
allflag    db ?              ;
pokupka    db ?              ;
perebor    db ?              ;
HEX_NUM    dw 2 dup (?)      ;���� ��६�����
Data       ENDS  



Stk        SEGMENT AT 100h use16
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS


Code       SEGMENT use16
Image      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh


           ASSUME cs:Code,ds:Data,es:Data,ss:Stk

DivD     Proc near           ;[di]/CX=[di]
         push dx 

         xor dx,dx               ; ���७�� ���襣�
         mov ax,[di+2]           ; ᫮�� dd � ���
         div cx                  ; ������� �� dw
         mov [di+2],ax
         mov ax,[di]             ; ������� ����襣�
         div cx                  ; ᫮�� dd � ��⠪�
                                 ; �� ������� ���襣�
                                 ; ᫮�� �� dw
         mov [di],ax
         mov al,dl
         mov ah,0ffh
         mov dx,[di]
         add dx,[di+2]
         cmp dx,0
         jnz divEnd
         xor ah,ah
divEnd:           
         pop dx
         ret
DivD     EndP

MulD     proc near     ;� CX ����⥫� [di] �������
         push ax       ;� [si] १����      
         push dx       ;[di]*CX=[si]
         mov ax,[di+2]
         mul cx
         mov [si+2],ax
         xor dx,dx
         mov ax,[di]
         mul cx
         mov [si],ax
         add [si+2],dx  
         pop dx
         pop ax
         ret
MulD     endp

HexToBCD   proc  near            ;�८�ࠧ������ HEX � BCD
           push dx           ;[di]-HEX     [si]-BCD
           push ax
           push cx
           push di
           push si           
           mov cx,[di]
           mov HEX_NUM,cx
           mov cx,[di+2]
           mov HEX_NUM+2,cx
           mov cx,10
           mov ah,00h
    hb2:   mov [si],ah
           inc si
           dec cx
           jnz hb2
           pop si
           push si
           mov cx,10
    hb1:   call DivD
           mov [si],al
           inc si
           cmp ah,0ffh
           jz hb1         
           mov cx,HEX_NUM
           mov [di],cx
           mov cx,HEX_NUM+2
           mov [di+2],cx
           pop si           
           pop di
           pop cx
           pop ax
           pop dx
           ret
HexToBCD   endp

DSum       proc near      ;[di]+AX_DX=[di]
           push cx
           push ax
           mov cx,[di+2]
           add cx,dx
           mov [di+2],cx
           mov cx,[di]
           add cx,ax
           jnc endd
           mov ax,[di+2]
           inc ax
           mov [di+2],ax
endd:      mov [di],cx           
           pop ax
           pop cx
           ret
DSum       endp

BcdToHEX   proc near                 ;[di]-HEX
           push bx dx ax cx si di    ;[si]-BCD ��稭�� � ���襣� ���祭��
           xor ax,ax
           xor dx,dx
           mov [di],ax
           mov [di+2],dx          
           mov al,[si]
           mov cx,10000
           mul cx
           mov [di],ax
           mov [di+2],dx
           mov cx,1000
           xor dx,dx
           xor ax,ax
           inc si
           mov al,[si]
           mul cx
           call DSum
           mov cx,100
           xor dx,dx
           xor ax,ax
           inc si
           mov al,[si]
           mul cx
           call DSum
           mov cx,10
           xor dx,dx
           xor ax,ax
           inc si
           mov al,[si]
           mul cx
           call DSum
           xor ax,ax
           xor dx,dx
           inc si
           mov al,[si]
           mov cx,1
           mul cx
           call DSum
           pop  di si cx ax dx bx         
           ret
BcdToHEX   endp

KeyRead     proc near     ;�⥭�� ���������� � ���࠭����� �ॡ����
           push bx           ;� DX ����� ���� � AL-१����
           xor ax,ax
           in al,dx
           cmp al,0
           jz gk2
           
           mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
           
VD2:       in    al,dx   ;���� ⥪�饣� ���ﭨ�
           cmp   ah,al       ;����饥 ���ﭨ�=��室����?
           jz    vd2         ;�᫨ �� � ������
           xor   bh,bh        ;���� ����稪� ����७��
vd1:       in    al,dx    
           cmp   al,0        ;������ ���饭�?    
           jnz   vd2         ;�᫨ ��� ����� �� �ॡ���
           inc   bh          ;���६��� ����稪� ����७��
           cmp   bh,NMax     ;����� �ॡ����?
           jnz   vd1         ;���室, �᫨ ���                   
           jmp   gk3
gk2:       mov al,0           
gk3:       mov al,ah      
           pop bx
           ret
KeyRead     endp
;--------------------------------------------------------------------
PortRead   proc near       
           push bx dx        
                             ;����᪠�� �८�ࠧ������ �����ᮬ \_/
                             ;�८�ࠧ������ ��稭����� �� �஭�� ������
           mov   al,0
           out   ADCSTART,al
           mov   al,1
           out   ADCSTART,al
           
WaitRdy:
           in    al,ADCRDY        ;��� ������� �� ��室� Rdy ��� - �ਧ���
                             ;�����襭�� �८�ࠧ������
           test  al,1
           jz WaitRdy
           in al,ADC1       ;��楤�� �⥭�� ��� � ����������
           mov ah,al        ;AH=0 - ��� ��������� ���
           in al,ADC0        ;AH=FF - ��� ���������
           shr ax,2          ;perebor=0 ��� ��誠�������, FF ����.
           mov bx,ax         ;adcwork-���᫥���� ��祭�� ���
           mov dx,ax         ;adcnew-⥪�饥 ����. ���
           mov ax,0          ;minus=FF ��� ����⥫��
           mov adcwork,ax
           mov ah,0h
           cmp perebor,0
           jnz pr1
           mov ah,0ffh
        
     pr1:  mov al,0ffh
           mov perebor,al
           cmp bx,10000
           ja adcno
           xor ah,ah
           mov perebor,ah
           mov ax,dx
           mov bx,adcnew
           mov adcnew,ax           
           mov dx,ax
           push bx
           mov bx,adcnull
           mov minus,0
           sub ax,bx
           cmp dx,bx
           jae wr1
           mov minus,0ffh
           mov ax,adcnew
           sub bx,ax
           mov ax,bx
     wr1:  mov adcwork,ax
           pop bx
           xor ax,ax
           cmp bx,dx                     
           jz adcno      ;��� ��������� ���
           mov ah,0ffh
           
adcno:     mov al,0          ;���� ������ AL-१����
           push ax           ;���祭�� 1-10 ������ �� 0 �� 9
           mov dx,KEY0       ;11 - ��� 業�
           call KeyRead      ;12 - ��
           cmp al,0          ;13 - ����窠
           jnz key0_         ;14 - ���㯪�
           mov dx,KEY1
           call KeyRead
           cmp al,0
           jnz key1_
           pop ax
           jmp endkey                     
key0_:     mov bl,0
     k0:   inc bl
           shr al,1
           jnc k0              
           jmp endkey1
key1_:     mov bl,8
     k1:   inc bl
           shr al,1
           jnc k1
endkey1:   pop ax                        
           mov al,bl
endkey:    pop dx bx       
           ret
PortRead   endp
;-----------------------------------------------------------------
NumEnter   proc near      ;���� ᨬ���� � ��ப� ����� CenaStr
           push si bx        ;�� ����� ��।���� ᨬ���� strpos
           lea si,cenaStr    ;㢥��稢����� �� 1
           add si,5          ;�� strpos>5 ���� �४�頥��� ��
           mov bl,strpos     ;������ ���
           mov bh,bl         
           sub bh,5
           jnc endenter
           xor bh,bh
           add si,bx
           inc bl
           mov strpos,bl
           mov [si],al
endenter:  pop bx si       
           ret
NumEnter   endp
;------------------------------------------------------
ClrCena    proc near     ;���⪠ cenastr
           push si cx
           mov cl,0
           mov strpos,0
           mov cl,10
           lea si,CenaStr
           mov ch,0
    cl1:   mov [si],ch
           inc si
           dec cl
           jnz cl1          
           pop cx si
           ret
ClrCena    endp
;----------------------------------------------------------------------------------------

OutVes     proc near         ;�뢮� �� ��������� ���
           cmp perebor,0     
           jnz ovm0          
           push si di
           lea di,adcwork
           lea si,vesStr
           Call HexToBCD
           pop di si
           push bx si dx ax        
           mov al,minus
           cmp al,0
           jz ov1
           mov al,64
    ov1:   out 0fh,al
           lea si,vesstr
           lea bx,Image
           mov dx,VESINDICATOR
           inc dx
           xor ch,ch
     om1:  mov cl,[si]
           add bx,cx
           mov al,cs:[bx]
           sub bx,cx
           inc si
           dec dx
           cmp dx,VESINDICATOR-3
           jnz om2
           or al,128        
      om2: out dx,al                 
           cmp dx,0
           jnz om1
           pop ax dx si bx
   ovm0:              
           push dx ax
           mov dx,VESINDICATOR+1
           mov al,0
           cmp perebor,al
           jz ovm2
   ovm1:  
          dec dx 
          out dx,al
          cmp dx,0
          jnz ovm1
          mov al,73h  
          out 0fh,al
          mov al,60h
          out 0,al
          out 1,al
          mov al,78h
          out 2,al
          mov al,60h
          out 3,al 
   ovm2:   
            pop ax dx     
           
           ret
OutVes     endp
;------------------------------------------------------------------
OutCena    proc near   ;�뢮� �� ��������� 業�
           push bx dx si cx
           lea bx,Image
           mov dx,CENAINDICATOR
           lea si,CenaStr
           xor ax,ax
           mov al,strpos
           xor ch,ch
           add si,ax
   cm1:    mov cl,[si]
           add bx,cx
           mov al,cs:[bx]
           sub bx,cx
           cmp dx,CENAINDICATOR+2
           jnz cm2
           or al,128        
    cm2:   out dx,al
           inc si
           inc dx
           cmp dx,9     ;end of cena ind.
           jnz cm1        
           pop cx si dx bx
           ret
OutCena    endp
;--------------------------------------------------------------------
OutItog    proc near            ;�뢮� �� ��������� �⮨����
           push bx dx si cx ax
           lea bx,Image
           mov dx,ITOGINDICATOR
           lea si,itogstr
           xor cx,cx
    im1:   mov cl,[si]
           add bx,cx
           mov al,cs:[bx]
           cmp dx,ITOGINDICATOR-2
           jnz im2
           or al,128
    im2:   sub bx,cx
           out dx,al
           inc si
           dec dx
           cmp dx,8
           jnz im1
           pop ax cx si dx bx       
           ret
OutItog    endp
;-----------------------------------------------------------------------
CalcItog   proc near          ;���᫥��� �⮨����
           push cx si di     ;itog=cena*adcwork
           xor cx,cx
           mov cl,strpos
           lea si,cenastr
           add si,cx
           lea di,cena
           call BCDToHex
           mov cx,0
           cmp minus,0
           jnz scalc
           mov cx,adcwork
scalc:     lea di,cena
           lea si,itog
           call MulD
           lea di,itog
           mov cx,1000
           call DivD
           lea di,itog
           lea si,itogstr
           call HEXToBcd
           pop di si cx                      
endcalc:           
           ret
CalcItog   endp           
;------------------------------------------------------------------------
CalcAll    proc near             ;���᫥��� ����窨
           push  bx ax dx di     ;all=all+itog
           lea di,all
           lea bx,itog
           mov ax,[bx]
           mov dx,[bx+2]
           call DSum
           lea di,All
           lea si,AllStr
           call HEXToBcd       
           pop di dx ax bx                     
           ret
CalcAll   endp
;-------------------------------------------------------------------------
ClrAll     proc near       ;��� ����窨 �� ����⨨ ������ �����
           push ax cx        ;�� �६� ������樨 ����窨
           mov cl,10
           lea si,AllStr
           mov ch,0
    ca1:   mov [si],ch
           inc si
           dec cl
           jnz ca1
           mov ax,0
           mov all,ax
           mov all+2,ax
           pop cx ax
           ret
ClrAll     endp
;---------------------------------------------------------------------
OutAll     proc near             ;�뢮� �� ��������� ����窨 �� ����
           push bx dx si cx ax
           mov al,0
           mov dx,4
     oa11:  dec dx
           out dx,al
           jnz oa11           

           lea bx,Image
           mov dx,ITOGINDICATOR
           lea si,allstr
           xor cx,cx
    oa1:   mov cl,[si]
           add bx,cx
           mov al,cs:[bx]
           cmp dx,ITOGINDICATOR-2
           jnz oa2
           or al,128
    oa2:   sub bx,cx
           out dx,al
           inc si
           dec dx
           cmp dx,5
           jnz oa1
           mov al,allflag
           out 0fh,al
           pop ax cx si dx bx                  
           ret
OutAll     endp 
;------------------------------------------------------------  
Opros      proc near
   main:   call PortRead     ;��砫� �������� 横��
           cmp ax,0
           jz main           ;�᫨ ��� ���譨� ᮡ�⨩ � �� ��砫�
           cmp ah,0          ;�᫨ ��� ��������� ��� � �⮡ࠦ���� 
           jz keypress       ;����� ���祭�� ���, ���, �⮨����
                    
           jmp vesm 
keypress:  dec al            ;��砫� ��ࠡ�⪨ ����⮩ ������
           sub al,10
           jnc nodigit       ;����>10 ����� ����� �� ���
           add al,10         ;���� ���� 業� ��� ������ �� �⮡ࠦ���� ����窨
           cmp allflag,0
           jnz kp1
           call NumEnter
   kp1:    push ax
           mov al,0
           mov allflag,al
           pop ax
           jmp vesm
 nodigit:  add al,10
           cmp al,10 ;�᫨ ����� ������ ����� � ��� 業� ��� ����窨
           jnz nd1         
           call ClrCena
           cmp allflag,0
           jz vesm
           call ClrAll
           jmp vesm
     nd1:  cmp al,11  ;�᫨ ��� ��ॡ�� � ��⠭���� ⥪�饣�
           jnz nd2           ;��� �� 0
           cmp perebor,0
           jnz nd2
           cmp allflag,0
           jnz nd11
           push ax
           mov ax,adcnew
           mov adcnull,ax
           mov ax,0
           mov adcwork,ax
           mov minus,al
           pop ax
   nd11:   push ax
           mov al,0
           mov allflag,al
           pop ax        
           jmp vesm
     nd2:  cmp al,12  ;�᫨ ����� '����窠' � ���室 � ०�� �⮡ࠦ���� 
           jnz nd3           ;����窨
           xor allflag,01000111b
           jmp vesm
     nd3:  cmp al,13  ;�᫨ ����� '���㯪�' � ᫮����� ⥪�饩 業�
           jnz vesm          ;� ����窮�, ����ୠ� ���㯪� ��������
           cmp perebor,0     ;⮫쪮 ��᫥ ������ �� ������, ��� ��������
           jnz vesm          ;���, �஬� ᠬ�� ������ '���㯪�'
           cmp allflag,0   
           jnz nd33
           cmp pokupka,0
           jnz nd33
           cmp minus,0
           jnz vesm1
           call CalcAll
    nd33:  mov pokupka,01101000b  
           jmp vesm1
 vesm:     mov al,0
           mov pokupka,al
 vesm1:    cmp allflag,0  ;�⮡ࠦ���� ��� 業� �⮨���� ��� ����窨
           jnz vir           ;� ����ᨬ��� �� ०��� �⮡ࠦ����
           call OutVes
           call CalcItog
           Call OutCena
           call OutItog          
           cmp pokupka,0
           jz vm1
           push ax
           mov al,pokupka
           out 0fh,al          
           pop ax                     
   vm1:    jmp main
 vir:      call OutAll
           jmp main
           ret
 opros     endp   
;------------------------------------------------------------
  Obnul    proc near
  
  mm:      mov al,0
           mov minus,al          
           
           mov ax,0
           mov adcwork1,ax
           mov adcnew1,ax
           mov adcnew,ax
           mov adcnull,ax
           mov adcwork,ax
           mov allflag,al
           mov pokupka,al
           mov perebor,al 
           ret
  obnul    endp
;---------------------------------------------------------------------------
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;����� ࠧ��頥��� ��� �ணࠬ��
;���㫥��� ��६����� �� ��ࢮ� ����
           call Obnul     ;���㫥��� ��ࠨ��஢
           call ClrCena   ;���⪠ ���ᨢ�
           call OutVes    ;�뢮� ��� �� ���������
           call ClrAll    ;���� ����窨 �� ����⨨ ����� "���" �� �६� ������樨 ����窨
           call CalcItog  ;���᫥��� �⮨����
           call CalcAll   ;���᫥��� ����窨
           Call OutCena   ;�뢮� 業� �� ���������
           call OutItog   ;�뢮� �㬬� �� ���������
           call Opros     ;���� ������ � ���

     ;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
