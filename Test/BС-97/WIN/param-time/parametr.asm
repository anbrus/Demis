NMax = 50
data    segment at 40H
        Map     db 0AH dup (?) ; ������ ���
	Tochki  dw 100 dup (?) ; ���ᨢ �祪
	Schet db ?
	Discr dw ?
	Chisclo dw ?
	NumTochki dw ?
	ZnachInc1 db ?
	ZnachDec1 db ?
	ZnachInc2 db ?
	ZnachDec2 db ?
	PerDiscr db ?
	KlStop db ?
	KlStart db ?
	Incr1 db ? 
	Decr1 db ?	
	PerZap db ?
	ProvP db ?
	MaxMaxKl db ?
	MinKl db ?
	MaxKl db ?
	MinMinKl db ?
	Ntochki dw ?
	MaxToch dw ?
	ZnMaxMin dw ?
	KolToch dw ?
	ZnMax dw ?
	Menshe db ?
	ZnMin dw ?
	Bolshe db ?
data    ends 

stack segment at 0C0H
	dw 200H dup (?)
	StkTop label Word
stack ends

code    segment
	assume 	cs:code,ds:data,ss:stack
Delay   MACRO Time              ; ���ப������
	LOCAL C                 ; ����প�
        push cx
        mov cx,Time
      C:loop C
        pop cx
	ENDM
PrintValue MACRO Port           ; �뢮� ���� 
	xlat                    ; � ����
	out Port,al
	ENDM
InitMap proc near
       mov Map[0], 3FH
       mov Map[1], 0CH
       mov Map[2], 76H
       mov Map[3], 5EH
       mov Map[4], 4DH
       mov Map[5], 5BH
       mov Map[6], 7BH
       mov Map[7], 0EH
       mov Map[8], 7FH
       mov Map[9], 5FH
       ret
InitMap endp

VibrDestr PROC
        push bx
        push dx   
vd1:    mov ah,al
        mov bh,0
vd2:    in  al,dx
        cmp ah,al
        jne vd1
        inc bh
        cmp bh,NMax
        jne vd2
        mov al,ah
        pop dx
        pop bx
        ret
VibrDestr ENDP

Nachalo proc near           ; ����㧪� ��砫���
	mov al,3FH          ; ���祭�� � ����� �뢮��
        out 0,al
	out 1,al
	out 2,al
	out 4,al
	out 5,al
	out 6,al
	out 7,al
	mov al,0
	out 8,al
	out 9,al
	mov al,0CH
	out 3,al
	mov Discr,20H
	mov Schet,1
	mov Chisclo,0
	mov NumTochki,0
	mov PerZap,0
	mov ProvP,0
        mov KlStop,0h
        mov KlStart,0  
	ret
Nachalo endp
;**************************************************************************
ObrabotkaKl1 proc near     ; ��楤�� ��ࠡ��뢠��
	mov ZnachInc1,0    ; ����⨥ ������ � ���-
	mov ZnachDec1,0    ; ��������� ᮮ⢥�����騩 
	mov PerDiscr,0     ; 䫠�
	cmp KlStop,0FFH
	je konobr
	cmp KlStart,0FFH
	je konobr
        mov dx,0   
obrab:	in al,0
        call VibrDestr
	cmp al,1
	je obrab1
	cmp al,2
	je obrab2
	cmp al,4
	je obrab3
        cmp al,8
	jne obrab
	mov KlStart,0FFH
	jmp konobr
obrab1:
	;call VibrDestr
        mov ZnachInc1,0FFH
	jmp konobr
obrab2: 
        ;call VibrDestr   
	mov ZnachDec1,0FFH
	jmp konobr
obrab3:
	mov PerDiscr,0FFH
	jmp konobr
konobr:
	ret
ObrabotkaKl1 endp
;**************************************************************************
Pribavlenie proc near       
	cmp ZnachInc1,0FFH   
	je prib             
	jmp konprib         
prib:	
	mov dl,10
	inc Chisclo 	    ; ��楤�� �ࠢ�����    
	cmp Chisclo,1000
	jne prib1
	mov Chisclo,0
prib1:	mov ax,Chisclo
	div dl
	mov al,ah
	PrintValue 0
	mov ax,Chisclo
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
	mov cx,5000H
prib2:	in al,0
	cmp al,0
	je konprib
	loop prib2
prib3:	in al,0             
	cmp al,1            
	jne konprib 
	inc Chisclo 	        
	cmp Chisclo,1000
	jne prib4
	mov Chisclo,0
prib4:	mov ax,Chisclo
	div dl
	mov al,ah
	PrintValue 0
	mov ax,Chisclo
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
	Delay 5000H 
	jmp prib3
konprib:
	ret
Pribavlenie endp
;*************************************************************************
Vichitanie proc near       ; ��楤�� �஢����
	cmp ZnachDec1,0FFH ; �뫠 ������� ᮮ⢥�������
	je vich            ; ������, �᫨ ��, � �ந���-
	jmp konvich        ; ����� 㬥��襭�� ��ࠬ��� �� 1.
vich:	
	mov dl,10              
	cmp Chisclo,0
	jne vich1
	mov Chisclo,1000
vich1:	dec Chisclo
	mov ax,Chisclo
	div dl
	mov al,ah
	PrintValue 0
	mov ax,Chisclo
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1       
	mov cx,5000H
vich2:	in al,0
	cmp al,0
	je konprib
	loop vich2
vich3:	in al,0         
	cmp al,2
	jne konvich
	cmp Chisclo,0
	jne vich4
	mov Chisclo,1000
vich4:	dec Chisclo
	mov ax,Chisclo
	div dl
	mov al,ah
	PrintValue 0
	mov ax,Chisclo
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
	Delay 5000H
	jmp vich3
konvich:
	ret   
Vichitanie endp
;************************************************************************
Discret proc near         ; ��楤�� �஢���� �뫠  
	cmp PerDiscr,0FFH ; �� ����� ᮮ⢥�������
	je dis            ; ������. �᫨ ��, � �ந�-
	jmp kondiscr      ; ������� ��������� ��ਮ�� 
dis:	cmp Schet,1       ; ����⨧�樨 �� 横����-
	je dis1	          ; ���� ������
	cmp Schet,2
	je dis2
	cmp Schet,3
	je dis3
	jmp kondiscr 
dis1:
	inc Schet
	mov Discr,40H
	jmp dis4
dis2:
	inc Schet
	mov Discr,60H
	jmp dis4
dis3:
	mov Schet,1
	mov Discr,20H
dis4:
	mov al,Schet
	PrintValue 3
dis5:	in al,0
	cmp al,0
	jne dis5
kondiscr:
	ret
Discret endp	
;*************************************************************************
Zapic proc near
	cmp KlStart,0FFH
	je z1
	jmp konzap
z1:	cmp KlStop,0FFH
	jne z2
	jmp konzap
z2:	mov al,8
	out 8,al
	lea si,Tochki-2
	mov cx,length Tochki
zap:
	cmp Incr1,2 
	jne zap00   
	jmp zap0
	cmp Decr1,2
	jne zap00
zap0:	mov Incr1,0 
	mov Decr1,0	
zap00:	inc si
	inc si
	mov ax,Chisclo
	mov [si], word ptr ax
	push cx
	mov cx,Discr
        mov dx,0
z3:	in al,0
        call VibrDestr
	cmp al,16
	je zap1
	cmp al,32
	je zap2
	cmp al,64
	jne z4
	pop cx
	jmp zap4
z4:	jmp zap3
zap1:
	inc Incr1
	cmp Incr1,2
	je zap12      
	jmp zap13
zap12:	jmp zap3
zap13:	mov dl,10
	inc Chisclo 	      
	cmp Chisclo,1000
	jne zap11
	mov Chisclo,0
zap11:	mov ax,Chisclo
	div dl
	mov al,ah
	PrintValue 0
	mov ax,Chisclo
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
	push cx
	mov cx,100H
zap111:	in al,0
	cmp al,0
	jne zap1111
	mov Incr1,0	
zap1111:
	loop zap111	
	pop cx
	jmp zap5
zap2:
	inc Decr1
	cmp Decr1,2
	je zap3
	mov dl,10     
	cmp Chisclo,0
	jne zap22
	mov Chisclo,1000
zap22:	dec Chisclo
	mov ax,Chisclo
	div dl
	mov al,ah
	PrintValue 0
	mov ax,Chisclo
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1 
	push cx
	mov cx,100H
zap222:	in al,0
	cmp al,0
	jne zap2222
	mov Decr1,0	
zap2222:
	loop zap222	
	pop cx
	jmp zap5
zap3:
	mov Incr1,0 
	mov Decr1,0
	push cx
	mov cx,100H
zap33:	in al,0
	cmp al,0
	jne zap333
	mov Decr1,0	
zap333:	loop zap33
	pop cx
	jmp zap5
zap4:
	mov KolToch,100
	sub KolToch,cx
	mov KlStop,0FFH
	mov al,0
	out 8,al
	mov al,64
	out 8,al
	jmp konzap
zap5:
	inc PerZap
	cmp PerZap,2
	je zap55
	jmp z3
zap55:
	mov PerZap,0
	dec cx
	cmp cx,0
	je zap555
	jmp z3
zap555:	
	pop cx
	dec cx
	cmp cx,0
	je zap4
	jmp zap
konzap:
	ret
Zapic endp
;**************************************************************************
Prepear proc near        ; ��楤�� ��⠭��������
	cmp KlStop,0FFH  ; ����� 1-� �窨 � �뢮��� 
	jne konprep      ; ᮮ⢥�����饥 ��
	cmp KlStart,0FFH ; ���祭�� ��ࠬ���
	jne konprep
	cmp ProvP,0FFH
	je konprep
	mov ProvP,0FFH
	lea si,Tochki	
	mov ax,word ptr [si]
	mov dl,10
	div dl
	mov al,ah
	PrintValue 0
	mov ax,word ptr [si]
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
	mov NumTochki,0
	mov ProvP,0FFH
konprep:
	ret
Prepear endp
;*****************************************************************************
ProsmotrInc proc near      ; ��楤�� �஢����
	cmp ZnachInc2,0FFH ; �뫠 �� ����� ᮮ⢥�������
	je pri             ; ������, �᫨ ��, � �믮������
	jmp konpinc	   ; ���६���஢���� ����� �窨
pri:	inc NumTochki
	cmp NumTochki,100
	jne pri1
	lea si,Tochki-2	
	mov NumTochki,0
pri1:	mov ax,NumTochki
	mov dl,10
	div dl
	PrintValue 5
	mov al,ah
	PrintValue 4
	inc si
	inc si
	mov ax,word ptr [si]
	div dl
	mov al,ah
	PrintValue 0
	mov ax,word ptr [si]
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
	mov cx,5000H
pri2:	in al,1
	cmp al,0
	je konpinc
	loop pri2
pri3:	in al,1    
	cmp al,1
	jne konpinc
	inc NumTochki
	cmp NumTochki,100
	jne pri4
	lea si,Tochki-2	
	mov NumTochki,0
pri4:	mov ax,NumTochki
	mov dl,10
	div dl
	PrintValue 5
	mov al,ah
	PrintValue 4
	inc si
	inc si
	mov ax,word ptr [si]
	div dl
	mov al,ah
	PrintValue 0
	mov ax,word ptr [si]
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
	Delay 5000H
	jmp pri3
konpinc:
	ret
ProsmotrInc endp
;*****************************************************************************
ProsmotrDec proc near      ; ��楤�� �஢���� �뫠
	cmp ZnachDec2,0FFH ; �� ����� ᮮ⢥�������
	je prd             ; ������, �᫨ ��, � �ந�������� 
	jmp konpdec        ; ���६���஢���� ����� �窨
prd:	cmp NumTochki,0
	jne prd1
	lea si,Tochki+200
	mov NumTochki,100
prd1:	dec NumTochki
	mov ax,NumTochki
	mov dl,10
	div dl
	PrintValue 5
	mov al,ah
	PrintValue 4
	dec si
	dec si
	mov ax,word ptr [si]
	div dl
	mov al,ah
	PrintValue 0
	mov ax,word ptr [si]
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
	mov cx,5000H
prd2:	in al,1
	cmp al,0
	je konpdec
	loop prd2
prd3:	in al,1    
	cmp al,2
	jne konpdec
	cmp NumTochki,0
	jne prd4
	lea si,Tochki+200
	mov NumTochki,100
prd4:	dec NumTochki
	mov ax,NumTochki
	mov dl,10
	div dl
	PrintValue 5
	mov al,ah
	PrintValue 4
	dec si
	dec si
	mov ax,word ptr [si]
	div dl
	mov al,ah
	PrintValue 0
	mov ax,word ptr [si]
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
	Delay 5000H
	jmp prd3 
konpdec:
	ret
ProsmotrDec endp
;*****************************************************************************
MaxMax proc near               ; ��楤�� ��室��
	cmp MaxMaxKl,0FFH      ; ���ᨬ� ���ᨬ��� 
	je m                   ; � ���ᨢ� ��ࠬ��஢
	jmp konmax
m:	lea di,Tochki-2
	mov ZnMaxMin,0
	mov MaxToch,0
	mov Ntochki,0
maxm:	
	inc di
	inc di
	mov ax, word ptr [di] 
	cmp ax,ZnMaxMin
	jb m1         
	xchg ax,ZnMaxMin
	mov ax,Ntochki
	mov MaxToch,ax
m1:	inc Ntochki
	cmp Ntochki,100
	jne maxm
	mov ax,MaxToch
	mov dl,10
	div dl
	PrintValue 5
	mov al,ah
	PrintValue 4
	mov ax,ZnMaxMin
	div dl
	mov al,ah
	PrintValue 0
	mov ax,ZnMaxMin
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
konmax:
	ret
MaxMax endp
;*****************************************************************************
MinMin proc near               ; ��楤�� ��室��
	cmp MinMinKl,0FFH      ; ������ �������� 
	je mm                  ; � ���ᨢ� ��ࠬ��஢
	jmp konmin
mm:	lea di,Tochki-2
	mov ax,word ptr [di+2]
	mov ZnMaxMin,ax
	mov MaxToch,0
	mov Ntochki,0
minm:	
	inc di
	inc di
	mov ax, word ptr [di] 
	cmp ax,ZnMaxMin
	ja mm1         
	xchg ax,ZnMaxMin
	mov ax,Ntochki
	mov MaxToch,ax
mm1:	mov ax,Ntochki
	inc Ntochki
	cmp KolToch,ax
	jne minm
	mov ax,MaxToch
	mov dl,10
	div dl
	PrintValue 5
	mov al,ah
	PrintValue 4
	mov ax,ZnMaxMin
	div dl
	mov al,ah
	PrintValue 0
	mov ax,ZnMaxMin
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
konmin:
	ret
MinMin endp
;*****************************************************************************
ObrabotkaKl2 proc near     ; ��楤�� ��ࠡ��뢠��
	mov ZnachInc2,0    ; ����⨥ ������ � ���-
	mov ZnachDec2,0    ; ��������� ᮮ⢥�����騩 
	mov MinMinKl,0     ; 䫠� ��᫥ ����砭��
	mov MinKl,0        ; ����� 䨪�஢����
	mov MaxKl,0
	mov MaxMaxKl,0
	cmp KlStop,0FFH
	jne konobrab
        mov dx,1
obr:	in al,1
	call VibrDestr
        cmp al,1
	je obr1
	cmp al,2
	je obr2
	cmp al,4
	je obr3
	cmp al,8
	je obr4
	cmp al,16
	je obr5
	cmp al,32
	jne obr 
	mov MaxMaxKl,0FFH
	jmp konobrab
obr1:
	mov ZnachInc2,0FFH
	jmp konobrab
obr2: 
	mov ZnachDec2,0FFH
	jmp konobrab
obr3:
	mov MinMinKl,0FFH
	jmp konobrab
obr4:
	mov MaxKl,0FFH
	jmp konobrab
obr5:
	mov MinKl,0FFH
	jmp konobrab
konobrab:
	ret
ObrabotkaKl2 endp
;*****************************************************************************
Max proc near
	cmp MaxKl,0FFH 
	je mx            
	jmp konm
mx:	lea di,Tochki
	mov al,0
	out 9,al 
	mov MaxToch,0
	mov Ntochki,0
	mov Menshe,1
mx1:	mov ax,word ptr [di]
	mov ZnMax,ax
	inc di
	inc di
	inc Ntochki
	cmp Ntochki,100
	je konm1
	mov ax,word ptr [di]
	cmp ax,ZnMax	
	jb mx2       
	mov Menshe,1
	jmp mx1
mx2:	cmp Menshe,1
	jne mx1
	dec Ntochki	
	mov ax,Ntochki
	mov dl,10
	div dl
	PrintValue 5
	mov al,ah
	PrintValue 4
	inc MaxToch	
	mov ax,MaxToch
	div dl
	PrintValue 7
	mov al,ah
	PrintValue 6
	mov ax,ZnMax
	div dl
	mov al,ah
	PrintValue 0
	mov ax,ZnMax
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
	mov Menshe,0	
	inc Ntochki
        mov dx,1
mx3:	in al,1
        call VibrDestr
	cmp al,0
	jne mx3
mx4:	in al,1
        call VibrDestr
	cmp al,8
	jne mx4
	jmp mx1
konm1:	
        mov al,8
	out 9,al
	Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
	mov al,0
	out 9,al
konm:
	ret
Max endp
;***************************************************************************
Min proc near
	cmp MinKl,0FFH 
	je mix            
	jmp konmi
mix:	lea di,Tochki
	mov al,0
	out 9,al 
	mov MaxToch,0
	mov Ntochki,0
	mov Bolshe,1
mix1:	mov ax,word ptr [di]
	mov ZnMin,ax
	inc di
	inc di
	inc Ntochki
	mov ax,Ntochki
	cmp KolToch,ax
	je konmi1
	mov ax,word ptr [di]
	cmp ax,ZnMin	
	jae mix2        
	mov Bolshe,1
	jmp mix1
mix2:	cmp Bolshe,1
	jne mix1
	dec Ntochki	
	mov ax,Ntochki
	mov dl,10
	div dl
	PrintValue 5
	mov al,ah
	PrintValue 4
	inc MaxToch	
	mov ax,MaxToch
	div dl
	PrintValue 7
	mov al,ah
	PrintValue 6
	mov ax,ZnMin
	div dl
	mov al,ah
	PrintValue 0
	mov ax,ZnMin
	div dl
	mov ah,0
	div dl
	PrintValue 2
	mov al,ah
	PrintValue 1
	mov Bolshe,0	
	inc Ntochki
        mov dx,1
mix3:	in al,1
        call VibrDestr
        cmp al,0
	jne mix3
mix4:	in al,1
        call VibrDestr
	cmp al,16
	jne mix4
	jmp mix1
konmi1:	
	mov al,16
	out 9,al 
	Delay 5000H
	Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        Delay 5000H
        mov al,0
	out 9,al 
konmi:
	ret
Min endp
;*****************************************************************************
start: 
       	mov ax,data
        mov ds,ax
	mov ax,Stack
	mov ss,ax
        mov sp,offset StkTop  

	mov bx,offset Map
	Call InitMap
	Call Nachalo 
begin:
	Call ObrabotkaKl1
	Call Pribavlenie
	Call Vichitanie
	Call Discret
	Call Zapic
	Call Prepear
	Call ObrabotkaKl2
	Call ProsmotrInc
	Call ProsmotrDec
	Call MaxMax
	Call MinMin
	Call Max
	Call Min
	jmp begin	

        org  0FF0h
        assume cs:nothing
        jmp  Far Ptr Start
code 	ends
end 	start