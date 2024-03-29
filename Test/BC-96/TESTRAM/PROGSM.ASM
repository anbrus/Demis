;���� �ᯮ����⥫��� ��楤��

TestNumber1	=0AAh
TestNumber2	=055h
TestOkLamp	=1000000b
EnterKey	=10000000b
;===================================
GetKeyNumber proc
	mov ah,0
@@1:
	shr al,1
	cmp al,0
	je @@exit
	inc ah
	jmp @@1
@@exit:
	mov cl,ah
	ret
GetKeyNumber endp

;================================
MakeAddress proc
	mov ax,word ptr RealAddress
	mov dx,1111000000000000b
	and dx,ax
	shl ax,4
	add al,NewKey
	dec al
	mov word ptr RealAddress,ax
	mov word ptr RealAddress[2],dx
	ret
MakeAddress endp

;================================
MakeSize proc
	mov ax,CurSize
	shl ax,4
	mov dl,NewKey
	dec dl
	add al,dl
	mov CurSize,ax
	ret
MakeSize endp

;================================
MakeAutoVars proc		;ᮧ����� ��६����� 
				;��� ��⮬���᪮�� ०���
	cmp NewKey,0		;��⠭�������� 䠪� ������
	jne @@1
	jmp @@exit
@@1:
	mov al,OLdKey
	cmp al,NewKey		;䠪� ������⭮�� ������
	jne @@2
	jmp @@exit

@@2:
	cmp Address_Size,Address;��⠭�������� ���� ?
	jne @@3
	call MakeAddress	;ᮡ�ࠥ� ����
	jmp @@exit

@@3:
	cmp Address_Size,_Size
	jne @@exit
	call MakeSize
	 
@@exit:
	ret			;
MakeAutoVars endp

;================================
MakeMemData proc
	call MakeAcces
	push es
	les di,RealAddress
	mov al,es:[di]
	shl al,4
	mov ah,NewKey
	dec ah
	add al,ah
	mov es:[di],al
	pop es
	call NoAcces
	ret
MakeMemData endp

;================================
MakeManualVars proc		;ᮧ����� ��६����� 
				;��� ��⮬���᪮�� ०���
	cmp NewKey,0		;��⠭�������� 䠪� ������
	jne @@1
	jmp @@exit
@@1:
	mov al,OLdKey
	cmp al,NewKey		;䠪� ������⭮�� ������
	jne @@2
	jmp @@exit

@@2:
	cmp Address_Data,Address;��⠭�������� ���� ?
	jne @@3
	call MakeAddress	;ᮡ�ࠥ� ����
	jmp @@exit

@@3:
	cmp Address_Data,_Data
	jne @@exit
	call MakeMemData
	 
@@exit:
	ret			;
MakeManualVars endp

;================================
ManualMake proc
	cmp NewMode,Manual
	je @@111
	jmp @@exit
@@111:
	cmp Dir,Forward
	jne @@1
	add word ptr RealAddress,1
	pushf
	mov ax,word ptr RealAddress[2]
	shr ax,12
	popf
	adc ax,0
	mov dx,ax
	lahf
	and ah,00001000b
	je @@move1			;�᫨ ���� ��७�� ��.
	mov word ptr RealAddress[2],0
	jmp @@exit

@@move1:				;��� ��. ��७��
	shl dx,12
	mov word ptr RealAddress[2],dx	
	jmp @@exit
;========���ࠢ����� �����

@@1:					;���ࠢ����� �����
	sub  word ptr RealAddress,1
	pushf
	mov ax,word ptr RealAddress[2]
	shr ax,12
	popf
	sbb ax,0
	jnc @@MovHighPart
	mov word ptr RealAddress[2],0F000h
	jmp @@exit
@@MovHighPart:
	shl ax,12
	mov word ptr RealAddress[2],ax
@@exit:
	ret
ManualMake endp

;================================
TestProcess proc			;��楤�� ���஢����

@@UnPressWait:				;�������� �⦠�� ������
	in al,OptionPort
	cmp al,0
	jne @@UnPressWait

	mov al,0
	out LampPort,al			;������� �����窨

	cmp CurSize,0			;�஢�ઠ ࠧ��� �஢��塞�� ������
	jne @@NoE			;�᫨ ࠧ��� >0 � ���室 � ����

	mov ErrFlag,SizeErr		;���� ����⢨� �� �訡��
	mov al,SizeErr
	call DannErrorProcess
	jmp @@exit
@@NoE:
	;�����।�⢥��� ������� ���
	;᭠砫� �஢�ઠ �� �ࠢ��쭮��� �����
	;� �祩�� �����
	call MakeAcces
	mov cx,CurSize			;������ �஢��塞�� ������
	les di,RealAddress		;����㧪� ���� �஢�塞�� ������
	mov si,word ptr Dir
@@TestLoop:
	mov dl,es:[di]			;��࠭塞 ���祭�� �祩�� �����
	mov es:[di],byte ptr TestNumber1;������ ��ࢮ�� ��⮢��� �᫠
	mov al,es:[di]			;���뢠��� �᫠
	cmp al,TestNumber1		;�ࠢ����� ��⠭���� �᫠ � �⠫����
	jne @@FindError			;�᫨ �� ᮢ���� � ???
	mov es:[di],byte ptr TestNumber2;������ ��ண� ��⮢��� �᫠
	mov al,es:[di]			;���뢠��� �᫠
	cmp al,TestNumber2		;�ࠢ�����
	jne @@FindError			;�᫨ �� ᮢ���� � ???
@@ContinueTest:
	mov es:[di],dl			;�᫨ �� ��� � ����⠭������� ��
	cmp si,Forward
	jne @@Bc
	add di,1
	jmp @@trim
@@Bc:
	sub di,1
@@trim:
	jnc @@Loop			;�᫨ ��९������� � ᬥ饭�� �
	mov ax,si
	shl ax,12
	push bx
	mov bx,es
	add ax,bx
	pop bx
	mov es,ax
					;���६��� ��ଠ����������� ᥣ����
@@Loop:
	loop @@TestLoop			;��横�������
	call NoAcces
	jmp @@NextTest			;���室 �� ᫥���騩 ���

@@FindError:				;��ࠡ�⪠ �訡��

	mov word ptr DispAdr,di
	mov word ptr DispAdr[2],es
	push ax				;��࠭��� ax
	push si
	push es
	push cx
	push dx
	mov al,MemDBusErr		;⨯ �訡�� � al
	call NoAcces		
	call DannErrorProcess		;����⢨� ���짮��⥫� �� �訡��
	cmp al,ContinueKey			;������ ����⢨�
	jne @@exit11
	call MAkeAcces
	pop dx
	pop cx
	pop es
	pop si
	pop ax
	jmp @@ContinueTest
@@exit11:
	pop dx
	pop cx
	pop ax
	pop si
	pop ax
	jmp @@exit1
@@NextTest:	
@@exit:
	call DispOkResult
	mov ErrFlag,NoErr
@@exit1:
	ret				;��室
TestProcess endp

;================================
StopKey=10000000b			;������ C⮯
ContinueKey=01000000b			;������ �த������
ErrorPort=11

DannErrorProcess proc			;����⢨� �� �訡���
					;�������� ᮮ�饭�� �� �訡��
	
					;���㫥��� ���ᨢ� �⮡ࠦ����
	push bx				;��࠭���� bx
	lea bx,DispArray		;� bx ���� ���ᨢ� �⮡ࠦ����
	mov cx,7			;� cx ������ ���ᨢ� �⮡ࠦ����
@@ZeroDisp:				;横� ���㫥���
	mov [bx],byte ptr 0
	inc bx
	loop @@ZeroDisp
	pop bx				;����⠭������� bx

	push ax
	mov al,Map[14]
	mov DispArray[4],al
	mov al,MAp[16]
	mov DispArray[3],al
	mov DispArray[2],al
	mov al,Map[2]
	mov DispArray[1],al
	pop ax

	cmp al,SizeErr
	jne @@1
	push ax
	mov al,Map[1]
	mov DispArray[1],al		;������� �訡��
	pop ax
	call OutputDispArr
@@SE:
	in al,OptionPort
	cmp al,EnterKey
	jne @@SE
@@1:	
	cmp al,MemDBusErr
	jne @@2
	call MakeAdr1
	call OutputDispArr
	mov al,1
	out ErrorPort,al
@@Wp:
	in al,OptionPort
	cmp al,ContinueKey
	jne @@3
@@WUp:					;�������� �⦠�� ������
	in al,OptionPort
	cmp al,0
	jne @@WUp
	mov al,ContinueKey
	jmp @@exit	
@@3:	
	cmp al,EnterKey
	jne @@Wp
	mov al,1
	jmp @@exit
@@2:
@@exit:	
	push ax
	mov al,0
	out ErrorPort,al
	pop ax
	ret;
DannErrorProcess endp

;=========================================
MakeAcces proc				;�᢮�������� �� ��蠣����� ०���
	push ax

	mov ax,es
	mov KeepEs,ax
					;��࠭���� ॣ���஢
	pushf				;�����祭�� 䫠���
	pop ax				;����饭�� 䫠��� � ��������
	mov KeepFlag,ax			;��࠭���� 䫠���
	and ax,1111111011111111b	;��⨥ 䫠��
	push ax				;���� 䫠��  � �⥪
	popf				;���� 䫠�� � ॣ���� 䫠���
	pop ax				;����⠭������� ॣ���஢
	ret
MakeAcces endp

;=========================================
NoAcces proc
	push ax
	mov ax,KeepEs
	mov es,ax

	mov ax,KeepFlag			;� ax��࠭���� ॣ���� 䫠���
	push ax				;��࠭���� 䫠�� � �⥪
	popf				;����⠭������� ॣ���� 䫠���
	pop ax
	ret
NoAcces endp

;=========================================
MakeAdr1 proc
	push ax
	push bx
	push si
	push di
	push cx
	lea bx,map
	lea si,DispArray	
	mov dx,word ptr DispAdr
	mov cx,4
@@1:
	mov ax,0Fh
	and ax,dx
	xlat
	mov [si],al
	shr dx,4
	inc si
	loop @@1	
	
	mov ax,word ptr DispAdr[2]
	shr ax,12
	xlat
	mov [si],al
	inc si	
	call MakeAcces
	les di,DispAdr
	mov dl,es:[di]
	call NoAcces
	mov cx,2
@@2:
	mov al,0fh
	and al,dl
	xlat 
	mov [si],al
	inc si
	loop @@2

	pop cx
	pop di
	pop si
	pop bx
	pop ax
	ret
MakeAdr1 endp
;=========================================
DispOkResult proc
	mov al,TestOkLamp
	out LampPort,al			;��ᢥ��� �������� ���� ���

@@1:					;�������� ������ �����
	in al,OptionPort	
	cmp al,EnterKey
	jne @@1
	
	ret
DispOkResult endp