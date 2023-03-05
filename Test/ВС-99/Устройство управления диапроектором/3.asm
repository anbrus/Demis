RomSize    EQU   4096
NMax       EQU   50          ; ����⠭� ���������� �ॡ����
KbdPort    EQU   0           ; ���� ���⮢
N1i        EQU   1
N2i        EQU   2
N3i        EQU   3
N4i        EQU   4
Nkn        EQU   1
Nsv        EQU   8
N1m        EQU   6
N2m        EQU   5
N3m        EQU   7

Data       SEGMENT AT 0
           KbdImage   DB    3 DUP()     
           EmpKbd     DB    ?        ; 䫠� ���⮩ ����������
           KbdErr     DB    ?        ; 䫠� �訡��
           Button     DB    ?        ; ��� ������
           avt        db    ?
           buffer     db    ?
           del1       dw    ? 
           del2       dw    ? 
           del3       dw    ?                       
           vvr        db    ?
           slima      db    ?
           slimr      db    ?  
           rand       db    3 DUP()
           lcd        db    2 DUP()  
           Time       dw    ?    
           off        dw    ?      
           rez        db    ?                
Data       ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data    

           Image  db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh
           
           kadr   db    0ffh,0,0,0,0,0,0,0ffh
                  db    0,0ffh,0,0,0,0,0ffh,0
                  db    0,0,0ffh,0,0,0ffh,0,0
                  db    0,0,0,0ffh,0ffh,0,0,0   
                  
                  db    01,01,01,01,01,01,01,01   
                  db    02,02,02,02,02,02,02,02   
                  db    03,03,03,03,03,03,03,03   
                  db    04,04,04,04,04,04,04,04   
                  db    05,05,05,05,05,05,05,05   
                  db    06,06,06,06,06,06,06,06   
                  db    07,07,07,07,07,07,07,07   
                  db    08,08,08,08,08,08,08,08                                
                  
                  db    01,0,0,0,0,0,0,0
                  db    0,01,0,0,0,0,0,0
                  db    0,0,01,0,0,0,0,0
                  db    0,0,0,01,0,0,0,0
                  db    0,0,0,0,01,0,0,0
                  db    0,0,0,0,0,01,0,0
                  db    0,0,0,0,0,0,01,0
                  db    0,0,0,0,0,0,0,01
                  
                  db    01,01,0,0,0,0,0,0
                  db    0,01,01,0,0,0,0,0
                  db    0,0,01,01,0,0,0,0
                  db    0,0,0,01,01,0,0,0
                  db    0,0,0,0,01,01,0,0
                  db    0,0,0,0,0,01,01,0
                  db    0,0,0,0,0,0,01,01
                  db    01,0,0,0,0,0,0,01
                        
                  db    0ffh,0,0,0,0,0,0,0
                  db    0,0ffh,0,0,0,0,0,0
                  db    0,0,0ffh,0,0,0,0,0
                  db    0,0,0,0ffh,0,0,0,0
                  db    0,0,0,0,0ffh,0,0,0
                  db    0,0,0,0,0,0ffh,0,0
                  db    0,0,0,0,0,0,0ffh,0
                  db    0,0,0,0,0,0,0,0ffh
                                
                  db    0,0,1,0,0,1,0,0
                  db    0,0,0,1,1,0,0,0
                  db    0,1,0,0,0,0,1,0
                  db    1,0,0,0,0,0,0,1
                                   

Init       PROC  NEAR
           mov   KbdErr,0
           mov   rez,0
           mov   al,3Fh
           out   N1i,al
           out   N2i,al
           xor   di,di
           xor   al,al
           mov   off,0ff0h
           mov   time,10
           
           ret
Init       ENDP 

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


; " ���� � ���������� "
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

;" �������� ����� � ���������� "
KbdInContr PROC  NEAR        
           lea   bx,KbdImage ;����㧪� ����
           mov   cx,3        ;� ����稪� ��ப
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

; " �������������� ��������� ����� "
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
           mov   Button,dh  ;������ ���� ����
NDT1:      ret
NxtDigTrf  ENDP

; " ����� �������� ���������� "
NumOut     PROC  FAR        
           cmp   EmpKbd,0FFh  ;����� ���������?
           jnz    N2           ;���室, �᫨ ��
           jmp   NO
      N2:  cmp   KbdErr,0FFh  ;�訡�� ����������?
           jz    NO           ;���室, �᫨ ��   
           cmp   avt,0
           jne   N1
           cmp   Button,10
           jz    NO
           cmp   Button,11
           jz    NO     
           mov   al,Button
           mov   ah,lcd[0]
           mov   lcd[1],ah
           mov   lcd[0],al           
           xor   ax,ax
           mov   al,lcd[1]
           mov   si,ax 
           mov   al,Image[si]
           out   N1i,al           
           mov   al,lcd[0]
           mov   si,ax 
           mov   al,Image[si]
           out   N2i,al           
      N1:  cmp   avt,0ffh
           jne    NO
           cmp   Button,0
           je    NO
           cmp   Button,6
           ja    NO                                
           mov   al,Button
           mov   lcd[1],al           
           xor   ax,ax
           mov   al,lcd[1]
           mov   si,ax 
           mov   al,Image[si]
           out   N1i,al           
           mov   al,lcd[0]
           mov   si,ax 
           mov   al,Image[si]
           out   N2i,al
           mov   al,10
           mul   button
           mov   time,ax                 
NO:        
           ret
NumOut     ENDP

Nomer     PROC  NEAR
           shr   di, 3
           inc   di
           mov   ax, di
           mov   cl, 10
           div   cl
           mov   ah, 0
           mov   si, ax
           mov   al, Image[si]
           out   N3i, al
           mov   ax, si
           mul   cl
           mov   bx, di
           sub   bx, ax
           mov   si, bx
           mov   al, Image[si]
           out   N4i, al
           dec   di
           shl   di, 3                 
Mz:        ret
Nomer     ENDP

;********************************************************************************************************************
avto	proc	near
	in	al, Nkn
        not     al    
	cmp	al, 04h
	jne	Ak
	cmp	slima, 0
	jne	Ak
	inc	slima
	mov	slimr, 0
	mov	avt, 0ffh
	mov	vvr, 0
	mov	del3, 0
	mov	lcd[0], 0
	mov	lcd[1], 1
	or	buffer, 04h
	and	buffer, 0fch
	mov	al, buffer
	out	Nsv, al
	mov	al, Image[0]
	out	N2i, al
	mov	al, Image[1]
	out	N1i, al
Ak:	ret
avto	endp

stop    proc near
        in       al,1
        not      al   
        cmp      al,80h
        jne      Stk   
        cmp      avt,0ffh
        jne      Stk   
        mov      vvr,0                      
    Stk: ret   
stop    endp     
 
west	proc	near
	in	al, Nkn
        not     al    
        mov     ah,al
    H1: in	al, Nkn
        not     al       
        test    al,8h
        jne     H1           
        mov     al,ah         
	cmp	al, 08h
	jne	Wk
	cmp	avt, 0
	jne	Wr
	cmp	di, 312
	je	Wk
        call    dvig    
	add	di, 8
	jmp	Wk
Wr:	cmp	avt, 0ffh
	jne	Wk
	mov	vvr, 0fh
Wk:	ret
west	endp

ost	proc	near
	in	al, Nkn
        not     al    
        mov     ah,al
    H2: in	al, Nkn
        not     al       
        test    al,10h
        jne     H2           
        mov     al,ah         
	cmp	al, 10h
	jne	Wk1        
	cmp	avt, 0
	jne	Wr1
	cmp	di, 0
	je	Wk1
        call    dvig       
	sub	di, 8
	jmp	Wk1
Wr1:	cmp	avt, 0ffh
	jne	Wk1
	mov vvr, 0f0h
Wk1:	ret
ost	endp


vyvod	proc	near
	cmp	avt, 0ffh
	jne	Vk
	inc	del1
	cmp	del1, 0ffffh
	jne	V1
	not	del2
	mov	del1, 0
	cmp	vvr, 0
	jne	Vn
	jmp	V1
Vn:	inc	del3
V1:	cmp	del2, 0
	jne	V2
	mov	al, buffer
	or	al, 01h
	out	Nsv, al
	jmp	V3
V2:	mov	al, buffer
	and	al, 0feh
	out	Nsv, al
V3:	mov	bx, time
	cmp	del3, bx
	jl	Vk
	mov	del3, 0
	cmp	vvr, 0fh
	jne	V4
	cmp	di, 312
	je	Vk
        call    dvig       
	add	DI, 8
	jmp	Vk
V4:	cmp	vvr, 0f0h
	jne	V5
	cmp	di, 0
	je	Vk
        call    dvig       
	sub	di, 8
	jmp	Vk
V5:	cmp	vvr, 0ffh
	jne	Vk
        call    dvig       
	call	randomi
Vk:	cmp	avt, 0fh
	je	V
	call	matrix
        call    Nomer     
V:	ret
vyvod endp

matrix	proc	near
	mov	al, 01h
	out	N3m, al
	mov	bl, 01h
	mov	cx, 8
M:	mov	al, bl
	out	N2m, al
	mov	al, kadr[di]
	out	N1m, al
	mov	al, 0
	out	N1m, al
	inc	di
	rol	bl,1
	loop	M
	sub	di, 8
	ret
matrix	endp

nachalo	proc	near
	in	al, Nkn
        not     al    
	cmp	al, 01h
	jne	Kk
	mov	di,0
        mov     vvr,0   
	or	buffer, 01h	
	mov	al, buffer
	out	Nsv, al
        mov     ax, 03fh    
        out	N2i, ax   
        mov     al, 03fh
        out	N1i, al
        call    dvig    
Kk:	ret
nachalo	endp

ruch	proc	near
	in	al, Nkn
        not     al    
	cmp	al, 02h
	jne	Rk
	cmp	slimr, 0
	jne	Rk
	inc	slimr
	mov	slima, 0
	mov	avt, 0
	mov	buffer, 03h
	mov	al, buffer
	out	Nsv, al
	mov	lcd[0], 1
	mov	lcd[1], 0
	mov	al, image[1]
	out	N2i, al
	mov	al, image[0]
	out	N1i, al
Rk:	ret
ruch	endp

klava1	proc	near
	call    KbdInput   
        call    KbdInContr 
        call    NxtDigTrf 
        call    NumOut   
KL1:	ret
klava1  endp

slaid	proc	near
	in	al, Nkn
        not     al    
	cmp	avt, 0
	jne	Sk
	cmp	al, 20h
	jne	Sk
	mov	al, lcd[1]
	mov	bl, 10
	mul	bl
	xor	bh, bh
	mov	bl, lcd[0]
	add	ax, bx
	cmp	ax, 0
	je	S1
	cmp	ax, 40
	jg	S1
	shl	ax, 3
	mov	di, ax
	sub	di, 8
        call    dvig       
        jmp     Sk    
  S1:   or      buffer,8h
        mov     al,buffer   
        out     Nsv,al           
        mov     cx,2 
  S3:   mov     dx,0ffffh  
  S2:   dec     dx
        cmp     dx,0 
        jne     S2    
        loop    S3       
     	mov	lcd[0], 1
	mov	lcd[1], 0
	mov	al, image[1]
	;out	N2i, al
	mov	al, image[0]
	;out	N1i, al
        and     buffer,0f7h    
        mov     al,buffer   
        ;out     Nsv,al        
Sk:	ret
slaid	endp

randomi	proc	near
        mov     bx,off
        mov     ax,[bx]
        shr     ax,2 
        inc     off      
RA11:	cmp	ax, 39
	jna	RA31
	sub	ax, 40
	jmp	RA11
RA31:	mov     di,ax
        shl     di,3        
        ret
randomi	endp

randomar	proc	near
		in	al, Nkn
                not     al                    
                mov     ah,al
           H6:  in	al, Nkn
                not     al                           
                test    al,40h
                jne     H6                   
                mov     al,ah                        
		cmp	avt, 0
		jne	RARr
		cmp	al, 40h
		jne	RARk
                call    dvig     
		call	randomi	
		jmp	RARk
RARr:		cmp	avt, 0ffh
		jne	RARk
		cmp	al, 40h
		jne	RARk
		mov	vvr, 0ffh
RARk:	ret
randomar	endp

dvig            proc    near     
                or           buffer,10h          
                mov          al,buffer
                out          Nsv,al
                mov          cx,2 
       Sd3:     mov          dx,0ffffh  
       Sd2:     dec          dx
                cmp          dx,0 
                jne          Sd2    
                loop         Sd3       
                and          buffer,0efh    
                mov          al,buffer   
                out          Nsv,al           
                ret           
dvig            endp 

funcprep	proc	near
	mov	di,0
	mov	slima, 0
	mov	slimr, 0
	mov	del1, 0
	mov	del2, 0
	mov	del3, 0
	mov	buffer, 01h
	mov	al, buffer
	out	Nsv, al
	mov	lcd[0], 1
	mov	lcd[1], 0
	mov	al, image[1]
	out	N2i, al
	mov	al, image[0]
	out	N1i, al
	ret
funcprep	endp


;********************************************************************************************************************

Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,Code
           mov   es,ax           
           call  Init            
           call  funcprep
NACHAL:   
           call	nachalo
           call	ruch
           call	klava1
           call	avto
           call	stop
           call	west
           call	ost
           call	slaid
           call	randomar
           call	vyvod           
           jmp   NACHAL
           org   RomSize-16 
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
