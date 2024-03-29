;�᭮���� 䠩� �ணࠬ��
LOCALS
Address=0			;⨯ ����� ����
_Size=0ffh			;⨯ ����� ࠧ���
_Data=0ffh			;⨯ ����� �����
Keyb1=1				;���� ���� ����������
Keyb2=2				;��ன ���� ����������
Auto=0;				;��⮬���窨� ०��
Manual=0ffh			;��筮� ०��
OptionPort=0			;���� ��� �ᥣ� �ᥣ�
ModeInputKey=1b                ;���� ���� ०����
Press=1				;������
UnPress=0			;�⦠��
SetupAddress=1000b
SetupSize=100b
DirPlus=10000b
DirMinus=100000b
Forward=1;
Backward=-1
NOErr=0				;��� �訡��
SizeErr=1			;�� �� ࠧ���
MemDBusErr=2			;�訡�� �� 設� ������
MemABusErr=3			;�訡�� �� 設� ����
;=============================
AutoLamp	=1
ManualLamp	=2
AddressLamp	=8
SizeLamp	=4
ForwardLamp	=16
BackWardLamp	=32
LampPort	=10
;=============================
TestKey=1000000b
;=============================

data segment at 0BA00H
	Map      db 17 dup (?)	;���� �८�ࠧ������
	NewKey      	  db ?	;��� � ���������� ����
	OldKey	    	  db ?	;��� � ���������� ����
	Address_Data  label byte;��� ����� ����/ࠧ���
	Address_Size 	  db ?	;��� ����� ����/ࠧ���
;	Address_Data  label byte;��� ����� ����/ࠧ���
	NewMode	          db ?	;���� �����
	PressMode         db ?   ;���� ०��
	Setup		  db ?	;⨯ �����
	Dir		  db ?
	DirPress	  db ?
	RealAddress       DD ?
	CurSize		  dw ?
        DispArray	  db 7 dup(?)	;��ப� ��� �८�ࠧ������ 
	ErrFlag		  db ?
	KeepFlag	  dw ?
	KeepEs		  dw ?
	DispAdr		  dd ?
data ends 

;================================================
stack segment at 0BA80H
  db 200H dup (?)
  StkTop label word
stack ends

;================================================
code segment
assume cs:code,ds:data,ss:stack
include progsm.asm

Prepare proc			;�����⮢�� ������
        			;���樠������ ����� �८�ࠧ������
	mov Map[0], 3FH
        mov Map[1], 0Ch
        mov Map[2], 76h
        mov Map[3], 5Eh
        mov Map[4], 4DH
        mov Map[5], 5BH
        mov Map[11], 79H
        mov Map[7], 0EH
        mov Map[8], 7FH
        mov Map[9], 5FH
        mov Map[10], 6FH
        mov Map[6], 7BH
        mov Map[12], 33H
        mov Map[13], 7CH
        mov Map[14], 73H
        mov Map[15], 63H
	mov Map[16],01100000b

	mov Address_Size,Address

	mov OldKey,0
	mov NewKey,0

	mov NewMode,Auto
	mov Dir,Forward

	mov word ptr RealAddress,0F000h
	mov word ptr RealAddress[2],0F000h
	mov CurSize,0;

	mov ErrFlag,NoErr

	ret			;��室
Prepare endp

;==================================
KeybInput proc			;���� � ����������
	cmp ErrFlag,NoErr	;�᫨ ��� �訡��
	je @@NoE
	jmp @@exit
@@NoE:
	in al,Keyb1		;�⥭�� �� ��ࢮ�� ���� ����������
	cmp al,0		;�ࠢ����� � �㫥� ���祭�� � �����
	je  @@1
        call GetKeyNumber 
	inc cl
	jmp @@DoIt
@@1:	
	in al,Keyb2
	cmp al,0
	je @@DoNo

	call GetKeyNumber
	add cl,9
@@DoIt:
	mov ah,NewKey
	mov OldKey,ah
	mov NewKey,cl
	jmp @@exit
@@DoNo:
	mov NewKey,0
	mov OldKey,0
	
@@exit:
	ret			;��室
KeybInput endp	

;=============================
ModeInput proc			;���� ०���� 
	cmp ErrFlag,NoErr	;�஢�ઠ �訡��
	je @@NoE
	jmp @@exit
@@Noe:
	in al,OptionPort
	cmp al,ModeInputkey	;�஢�ઠ �� ��⠭���� ०����
        jne @@exit
	cmp PressMode,Press
	je @@exit1
        not NewMode
	mov PressMode,Press
	jmp @@exit1
@@exit: 
	mov PressMode,UnPress;
@@exit1:
	ret			;��室
ModeInput endp

;=============================
SetupInput proc			;���� ⨯� ����� 
	cmp ErrFlag,NoErr	;�஢�ઠ �訡��
	je @@NoE
	jmp @@exit
@@Noe:
	in al,OptionPort
	cmp al,SetupAddress
	jne @@1
	mov Address_Size,Address
	jmp @@exit
@@1:
	cmp al,SetupSize
	jne @@exit
	mov Address_Size,_Size
@@exit:
     	ret			;��室
SetupInput endp

;=============================
DirInput proc			;���� ���ࠫ����
	cmp ErrFlag,NoErr	;�஢�ઠ �訡��
	je @@NoE
	jmp @@exit
@@Noe:

	in al,OptionPort
	cmp al,DirPlus
	jne @@1
	cmp DirPress,Press
	je @@exit1
	mov Dir,Forward
	call ManualMake
	mov DirPress,Press
	jmp @@exit1
@@1:
	cmp al,DirMinus
	jne @@exit
	cmp DirPress,Press
	je @@exit1
	mov Dir,BackWard
	mov DirPress,Press
	call ManualMake
	jmp @@exit1	
@@exit:
	mov DirPress,UnPress
@@exit1:
	ret			;��室
DirInput endp

;=============================
MakeData proc			;�����⮢�� ������
	cmp ErrFlag,NoErr	;�஢�ઠ �訡��
	je @@NoE
	jmp @@exit
@@Noe:

	cmp NewMode,Auto
	je @@AutoSetup
	jmp @@1
@@AutoSetup:
        call MakeAutoVars
	jmp @@exit;	
@@1:
	call MakeManualVars
@@exit:
	ret
MakeData endp

;=============================
MakeDispArr proc		;��ନ஢���� ���ᨢ� �⮡ࠦ����
	mov cx,Length DispArray	;� CX ������ ���ᨢ� �⮡ࠦ����
	lea si,DispArray	;� SI ����� ���ᨢ� �⮡ࠦ����
@@l1:
	mov byte ptr [si],0
	inc si
	loop @@l1		;���㫥��� ���ᨢ� �⮡ࠦ���

	mov cx,Length DispArray	;� CX ������ ���ᨢ� �⮡ࠦ����
	lea si,DispArray	;� SI ����� ���ᨢ� �⮡ࠦ����
	lea bx,Map		;� BX ���� ����� �८�ࠧ������

	cmp NewMode,Auto	;�஢�ઠ ��⠭��������� ०���
	je @@1			;�᫨ ०�� ��⮬���᪨�
	jmp @@2			;�᫨ ��筮�
@@1:
	cmp Address_Size,Address;⨯ ����� ?
	jne @@3			;������ ࠧ���
@@MAdr:				;������ ����
	mov dx,word ptr RealAddress;� DX ������� ���� ����
	mov cx,4		;����㧪� ���稪� ��� �८�ࠧ������
@@l2:				;横� �८�ࠧ������
	mov ax,1111b
	and ax,dx
	xlat
	mov [si],al
	inc si
	shr dx,4
	loop @@l2
	mov ax,word ptr RealAddress[2];� AX ������ ���� ����
	shr ax,12
	xlat
	mov [si],al			;��⠢�塞 ���ᨢ �⮡ࠦ����
					;��� ����
	jmp @@exit	
@@3:
	mov dx,CurSize			;��� ࠧ���
	mov cx,4
@@l3:
	mov ax,1111b
	and ax,dx
	xlat
	mov [si],al
	inc si
	shr dx,4
	loop @@l3

	jmp @@exit
;��筮� ०��
@@2:
	call MakeAcces
	push ds
	lds si,RealAddress
	mov dl,[si]
	pop ds
	call NoAcces

	lea si,DispArray
	lea bx,Map
	Add si,5
	mov al,0fh
	and al,dl
	xlat
	mov [si],al
	shr dl,4
	mov al,dl
	xlat
	inc si
	mov [si],al
	lea si,DispArray
	jmp @@MAdr

@@exit:
	ret
MakeDispArr endp

;=============================
OutputDispArr proc		;�뢮� ���ᨢ� �⮡ࠦ���� �� ��ᯫ��
	mov cx,Length DispArray	; � CX ������ ��ᨢ� �⮡ࠦ����
	mov dx,3		; � DX ��砫� ���⮢ ��� �뢮��
	lea si,DispArray	; � SI ���� ���ᨢ� �⮡ࠦ����
@@l1:				;横� �뢮�� � ����� �뢮��
	mov al,[si]
	out dx,al
	inc si
	inc dx
	loop @@l1

	ret			;��室
OutputDispArr endp

;=============================
LampOutput proc
	xor ax,ax
	cmp NewMode,Auto
	jne @@1
	or ax,AutoLAmp
	jmp  @@SizeDann
@@1:
	or ax,ManualLamp

@@SizeDann:
	cmp Address_Size,Address
	jne @@2
	or ax,AddressLamp
	jmp @@DirOut
@@2:
	or ax,SizeLamp
@@DirOut:	
	cmp Dir,Forward
	jne @@3
	or ax,ForwardLamp
	jmp @@exit
@@3:
	or ax,BackwardLamp
	

@@exit:	
	out LampPort,al
@@exit1:
	ret
LampOutPut endp

;===================================
TestProgress proc		;���஢����
	cmp NewMode,Auto
	je @@Noe
	jmp @@exit
@@NoE:
	in al,OptionPort
	cmp al,TestKey
	jne @@exit
	call TestProcess
@@exit:	
	ret			;��室
TestProgress endp

;===================================
begin: 
	mov ax,data
	mov ds,ax

	mov ax,stack
	mov ss,ax       
	mov sp,offset StkTop
	call Prepare
MainProgramLoop:
	;==================
	call KeybInput		;���� � ����������
	call ModeInput		;���� ०����
	call SetupInput		;���� ⨯� ����� 
	call DirInput		;���� ���ࠫ����
        ;==================
	call MakeData		;�����⮢�� ������
	call MakeDispArr	;��ନ஢���� ���ᨢ� �⮡ࠦ����
	call OutputDispArr	;�뢮� ���ᨢ� �⮡ࠦ���� �� ��ᯫ��
	call TestProgress	;��楤�� ���஢����
	call LampOutput		;��������� �����祪
	;==================
	jmp MainProgramLoop
       org 07F0H
start: jmp begin
code ends
end start
                  