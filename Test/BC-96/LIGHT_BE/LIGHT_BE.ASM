name Light_Bell

;------------------------------
Nmax=50
Kbport=4

s1 STRUC			;������� ������
	hour	db 	?	;���
    	min 	db 	?	;������
	dlit 	db	?	;���⥫쭮���
	VidSig	db	?	;��� ᨣ����
s1  ends

data segment at 0BA00H
        Map             db      10 dup (?)

	Mode   	        db      ?	;०��(�⮡ࠦ�����/�ணࠬ��஢����)
	TypeSig		db	?	;⨯ ᨣ����(�� ���/ ���)
	InType	        db      ?	;⨯ �����(���⥫쭮���/�६�)
	IncInput	db	?	;᫥���騩 ����		
	DecInput	db	?	;�।��騩 ����
	EmpKb		db	?	;䫠� ����������(����/�� ����)
	yscor		db	?	;�᪮७�� �६���
	FlagTime	db	?	;䫠� �६���
	KbImage		db	2 dup(?);��ࠧ ����������
	NextDig		db	?	;��� ����⮩ ������
	BufData		s1	32 dup(?);����� � �����
	MesBuf		s1	?	;����
	KontKb		db	?	;����஫� ����������(�ॡ���)
	ErrInput	db	?	;�訡�� �����
	NomInput	db	?	;����� ᨣ����
	FlagSave	db	?	;䫠� �����
data ends 
;///////////////////////////

sta segment at 0BA80H
  dw 100H dup (?)
  StkTop label word
sta ends

;\\\\\\\\\\\\\\\
code segment
assume cs:code,ds:data,ss:sta
;-----------------------------------------------------
Times proc
	mov FlagTime,1
	mov ax,2c00h
	int 21h
        mov al,ch
	mov MesBuf.hour,ch
	mov al,cl
	mov MesBuf.min,cl
	ret
Times   endp
 ;-------------------------------------------
 TimeProg proc
	mov cl,MesBuf.min
	mov ch,MesBuf.hour
	mov dh,MesBuf.dlit
        cmp cl,60        ;�᫨ ������=60 �
        je tp2           ;���室 �� ���� tp1
        cmp ch,24        ;�᫨ ���=24 �
        je tp3           ;���室 �� ���� tp2
        cmp dh,60        ;�᫨ ᥪ㭤�=60 �
        je tp1           ; ���室 �� ���� tp3
	mov dl,yscor
	mov al,dl
	cmp dl,1
	je tp4
	mov ax,4256
	call delay
	jmp tp5
tp1:
        inc cl       ;�ਡ���塞 ������
        mov dh,0     ;����塞 ᥪ㭤�
	push cx
;	call HourDisp
	call srav
	pop  cx
        jmp tp5
tp2:
        inc ch       ;�ਡ���塞 ��
        mov cl,0     ;����塞 ������
        jmp tp5
tp3:
        mov ch,0     ;����塞 ���
        jmp tp5
tp4:	mov ax,1
	call delay
tp5:	mov MesBuf.min,cl
	mov MesBuf.hour,ch
	mov MesBuf.dlit,dh
	ret	
	
TimeProg endp
;------------------------------------------------
ErrDisp	proc
	mov al,73h
	out 0,al
	mov al,60h
	out 1,al
	out 2,al
	mov al,0
	out 3,al
	ret
ErrDisp endp
;------------------------------------------------
delay proc near
        push cx
        mov cx,ax
point:    
        loop point 
        inc dh
        pop cx
        ret
delay   endp
;-------------------------------------------------
KbInput proc
	push cx
	push dx
	push ax 
	push bx
	mov EmpKb,0
	mov KbImage,0
	lea  si,KbImage
	mov  cx,2
        mov  dx,Kbport
kl4:	in   al,dx
	mov [si],al
	cmp dx,5
	je kl5
	mov EmpKb,1
	jmp kl3
kl5:	mov al,KbImage[1]
	cmp al,80h
	je kl41
	cmp al,40h
	je kl41
	cmp al,0c0h
	je kl41
	mov EmpKb,1
	jmp kl3
kl41:	
        mov al,EmpKb
	cmp al,1
	je kl3
	mov EmpKb,0

kl3:	inc  si
        inc  dx
	loop kl4
	pop  ax
	pop  bx
	pop  cx
	pop  dx

	ret
KbInput	endp	
;-------------------------------------------------
 NxDig 	proc
	push ax
	push bx
	push dx
	mov NextDig,55
	lea  si,KbImage
	mov  dx,0
	
nd1:	mov al,[si]	;����㦠�� ��ࠧ ����������
	cmp al,0	;�஢��塞 ����⨥ ������
	jne nd2		;�᫨ ������ � �� ���� nd2
	inc dh		;�� ᫥������ ��ப� ����������
	inc si
	cmp dh,2	;�᫨ ��� ��ப� �஢�७� � ��室	
	je  nd5
	jmp short nd1
nd2:    
        shr  al,1
        jc   nd3
	inc  dl
	cmp  dl,9	
	je   nd3

	jmp  short nd2
nd4:	add dl,8
	mov al,dl
	mov dh,3
nd3:	cmp dh,1
	je nd4
	cmp dl,15
	je nd5
	cmp dl,14
	je nd5
	mov  NextDig,dl
nd5:
	pop  ax
	pop  bx
	pop  dx
	ret
Nxdig	endp	
;-------------------------------------------------
TypeInput proc
	mov Mode,0
	mov InType,0
	mov TypeSig,0
	mov IncInput,0
	mov DecInput,0
	mov yscor,0
	mov bl,KbImage[1]
	cmp bl,0
	je  ti7
	mov al,bl
	and al,80h
	cmp al,80h
  	je  ti1
	mov al,NextDig
	cmp al,10
	je  ti6
	jmp ti7
ti1:    mov Mode,1
	mov al,NextDig
	cmp al,11
	je  ti3
	cmp al,12
	je  ti4
	cmp al,13
	je  ti5
	mov al,bl
	and al,0c0h
	cmp al,0c0h
	je  ti2	
	jmp ti7
ti2:	mov InType,1
	jmp ti7
ti3:	mov TypeSig,1
	mov al,bl
	and al,0c0h
	cmp al,0c0h
	je  ti2	
	jmp ti7
ti4:	mov IncInput,1
	jmp ti7
ti5:	mov DecInput,1
	jmp ti7
ti6:	mov yscor,1
ti7:	ret
TypeInput endp

;--------------------------------------------------
 KbKontrol proc
	mov al,EmpKb
	cmp al,0
	je kk1
	mov al,NextDig
	cmp al,KontKb
	je kk2
	mov KontKb,al
	mov al,1
	jmp kk3
kk1:	mov KontKb,33
kk2:	mov al,0
kk3:	ret
KbKontrol endp	
;-------------------------------------------------
MesForm proc
	call KbKontrol
	cmp al,0
	je mf4
	mov al,NextDig
	cmp al,9
	jg mf4			;�᫨ ����� � �����
	mov  al,MesBuf.hour
	aam  
	mov  bh,ah
	mov  bl,al	
	mov al,InType
	cmp al,1
	je mf2
	mov  al,MesBuf.min
mf0:	aam
	mov bh,bl
	mov bl,ah
	mov ah,al
	mov al,NextDig
	mov ch,bh
	mov cl,3
	shl bh,cl
	add bh,ch
	add bh,ch
	add bh,bl
	mov ch,ah
	shl ah,cl
	add ah,ch
	add ah,ch
	add ah,al
	mov al,InType
	cmp al,1
	je mf3
	mov MesBuf.hour,bh
	mov MesBuf.min,ah
	jmp mf4
mf2:    mov al,MesBuf.dlit
	jmp mf0
mf3:	mov MesBuf.dlit,ah
mf4:	ret
MesForm endp
;------------------------------------------------------
DispForm macro
	mov bx,offset Map
	aam
	xlat
	out dx,al	
	mov al,ah
	xlat
	dec dx
	out dx,al
        endm
;----------------------------------------------------
HourDisp proc
	mov dx,1
	mov al,MesBuf.hour
	DispForm
	mov dx,3
	mov al,MesBuf.min
        DispForm
	ret
HourDisp endp
;----------------------------------------------------		
SaveInf  proc
	mov al,MesBuf.hour
	mov ah,MesBuf.min
	mov bh,MesBuf.dlit
	mov bl,MesBuf.VidSig
	mov BufData[si].hour,al
	mov BufData[si].min,ah
	mov BufData[si].dlit,bh
	mov BufData[si].VidSig,bl
SaveInf endp
;------------------------------------------------------
LoadInf proc
	mov al,BufData[si].hour
	mov ah,BufData[si].min
	mov bh,BufData[si].dlit
	mov bl,BufData[si].VidSig
	mov MesBuf.hour,al
	mov MesBuf.min,ah
	mov MesBuf.dlit,bh
	mov MesBuf.VidSig,bl
	ret
LoadInf endp
;----------------------------------------------------
NomMas proc
	mov si,0
	mov bx,offset BufData
	mov cl,NomInput
nm:	add si,type BufData
	dec cx
	jnz nm
	ret
NomMas	endp
;-------------------------------------------------------
ProvInf proc
	push ax
	mov al,MesBuf.hour
	cmp al,23
	jg pi1
	mov al,MesBuf.min
	cmp al,59
	jg pi1
	mov al,MesBuf.dlit
	cmp al,59
	jg pi1
	cmp al,0
	je pi1
	jmp pi2
pi1:	call ErrDisp
	mov ErrInput,1
	jmp pi3
pi2:	mov ErrInput,0
pi3:	pop ax
	ret
ProvInf endp
;----------------------------------------------------
Signal  proc
	mov al,7
	out 8,al
	out 9,al
	out 0ah,al
	mov al,TypeSig
	cmp al,0
	je sig1
	mov ax,1300
	call delay 
	mov al,0
	out 8,al
	out 9,al
	out 0ah,al
sig1:	ret
Signal  endp
;-------------------------------------------
Srav    proc
	mov dl,0
si0:	call NomMas
	mov al,BufData[si].min
	mov bl,MesBuf.min
;	dec bl
	cmp al,bl
	jne si1
	mov al,BufData[si].hour
	mov bl,MesBuf.hour
	cmp al,bl
	jne si1
	mov al,BufData[si].dlit
	mov MesBuf.dlit,al
	mov bl,BufData[si].VidSig
	mov dh,BufData[si].dlit
	mov MesBuf.dlit,dh
si3:	mov TypeSig,bl
	call Signal
	mov ax,6200
	call delay
	mov al,BufData[si].dlit
        dec al
	mov BufData[si].dlit,al
	cmp al,0
	je si2
	mov BufData[si].min,0
	mov BufData[si].hour,0
	jmp si3
si1:	inc dl
	mov NomInput,dl
	cmp dl,30
	je si2
	jmp si0
si2:	mov NomInput,1
	ret
Srav endp

;------------------------------------------------------
PressButton  proc
	mov al,FlagSave
	cmp al,0
	je pb4
pb5:	mov al,TypeSig
	cmp al,1
	je pb1
	mov al,MesBuf.VidSig
	mov TypeSig,al
	call Signal
	mov al,IncInput		;�஢�ઠ ������ ᫥�.����
	cmp al,1
	je pb2
	mov al,DecInput		;�஢�ઠ ������ �।.����
	cmp al,1
	je pb2
	mov al,NomInput		;�뢮� ����� ����� �� ���������
	mov dx,7
	DispForm
	mov al,InType		;��४��祭�� ०��� �����
	cmp al,1
	je pb0
	mov FlagTime,0 		;ࠧ�蠥� ����� �६� �� ⠩���
	call MesForm		;�ନ�㥬 ���ᨢ �⮡ࠦ����
	call HourDisp		;�뢮��� ���ᨢ �� ���������
	jmp pb3
pb0:	call MasDlit
	jmp pb3
pb1:	call TypeSignal
	jmp pb3
pb2:	call PressInput
	jmp pb3
pb4:	call NomMas		;��।������ ������ ���ᨢ� ������� 
	call LoadInf		;�뢮� ���ଠ樨 �� �����
	mov FlagSave,1	
	jmp pb5
pb3:	ret
PressButton  endp 
;----------------------------------------------------
TypeSignal   proc
	call KbKontrol
	cmp al,0
	je ts2
	mov al,MesBuf.VidSig
	cmp al,1
	je ts1
	mov MesBuf.VidSig,1
	jmp ts2
ts1:	mov MesBuf.VidSig,0
ts2:	ret
TypeSignal   endp
;---------------------------------------------------------
PressInput  proc
   	call KbKontrol		;�஢�ઠ ������ ������
	cmp al,0		;�᫨ ����� ����ﭭ� ���� � ⠦�
	je pri0			;� ��室
        call provinf		;�஢�ઠ ���४⭮�� ���������
	mov al,ErrInput		;���ଠ樨,�᫨ �� ���४⭮ �
	cmp al,1		;��室
	je pri0
	call NomMas		;��।������ ������ ���ᨢ� �������
	call SaveInf		; ������ ��������� ���ଠ樨
	mov FlagSave,1
	mov al,NomInput
	mov bl,DecInput		;�஢�ઠ ������ ������
	cmp bl,1		;�।��騩 ���� �᫨ ����� 
	je pri1			;� �� ���� fi7
	inc al			;���६���஢���� ����� �����
pri2:	mov NomInput,al
	call ProvPress
	call NomMas		;��।������ ������ ���ᨢ� ������� 
	call LoadInf		;�뢮� ���ଠ樨 �� �����
	jmp pri0
pri1:	dec al
	jmp pri2
pri0:	ret
PressInput  endp
;-------------------------------------------------------
ProvPress proc
	mov al,NomInput		;�஢�ઠ ����� �����
	cmp al,31
	je pp2
	cmp al,0
	je pp1
	jmp pp3
pp1:    mov al,1
	mov NomInput,1
	jmp pp3
pp2:	mov al,30
	mov NomInput,al
	jmp pp3
pp3:	
	ret
ProvPress endp
;---------------------------------------------------------
MasDlit  proc
        call MesForm		;�ନ஢���� ���ᨢ� �⮡ࠦ����
	mov dx,3		;��� ���⥫쭮�� ᨣ����
	mov al,0
	out 0,al
	out 1,al
	mov al,MesBuf.dlit
	DispForm		;�뢮� ���⥫쭮�� �� ���������
	ret
MasDlit  endp
;------------------------------------------------------------
FormInf proc
	mov al,Mode		;�஢�ઠ ०���
	cmp al,1
	je fi1                 ;�᫨ ���ࠬ�஢���� � �� fi1
	mov al,FlagSave
	cmp al,1
	je fi4
fi5:	mov NomInput,1		;��⠭�������� ����� ����� 1
	mov al,0
	out 7,al		;��ᨬ ��������� ����� ����� 
	out 6,al		;���ଠ樨
	out 8,al
	out 9,al
	out 0ah,al
	mov al,FlagTime		;�஢��塞 ����砫��� �� �६� �� ⠩���
	cmp al,1		
	jne fi2			;�᫨ ��� � ����砥�
fi0:	
	call TimeProg		;����᪠�� �ணࠬ���� �६�
	call HourDisp		;�뢮��� �६� �� ���������
	jmp fi3			;��
fi1:	
	call PressButton
	jmp fi3
fi2: 	call Times
	jmp fi0
fi4:	call provInf
	mov al,ErrInput
	cmp al,1
	je fi3
	call NomMas
	call SaveInf
	mov FlagSave,0
	jmp fi5
fi3:	ret
FormInf endp		
;---------------------------------------------------------
Setup	proc
        mov ax,data
	mov ds,ax
        mov ax,sta
        mov ss,ax       
	mov sp,offset stkTop
        mov bx,offset Map
        mov Map[0], 3FH
        mov Map[1], 0CH
        mov Map[2], 76H
        mov Map[3], 05EH
        mov Map[4], 4DH
        mov Map[5], 5BH
        mov Map[6], 7BH
        mov Map[7], 0EH
        mov Map[8], 7FH
        mov Map[9], 5FH
	mov FlagTime,0
	mov FlagSave,0
	mov NomInput,1 
	ret
Setup	endp
;---------------------------------------------------------
begin:  call setup
m:	 
        call KbInput
 	call NxDig
	call TypeInput
	call FormInf
jmp m
	org 07f0h
start: jmp begin
code ends

end start
                  