DelMax	equ	55 ;���ᨬ��쭠� ����稭� ����প�.
DelMin	equ	1  ;�������쭠� ����稭� ����প�.
dV	equ	3  ;��� ��������� ᪮��� ��饭��.

DATA	segment at 0B940h
KbdImg	db	? ;����ﭨ� ��䨪� ��.
Indic	db  4 dup(?) ;��ࠧ ��࠭� 7-ᥣ������ �������஢.
TypeDir db	? ;���ࠢ����� ��饭��: 00h - �� �� ��५��, 0FFh - ��⨢.
Delay	db	? ;����稭� ����প�.
DelCnt	db	? ;���稪 ����প�.
FixK	db	?
DATA	ends

;bit 0 - Speed Up
;bit 1 - Speed Down
;bit 2 - Inv Dir

CODE	segment
	assume cs:CODE, ds:DATA

   ;����ணࠬ�� ��ࠡ�⪨ ����� (��䨪� ��).
InProc	PROC	;AL - ��� � ����⨨ ��䨪� ��.
	mov	dl,Delay
	shr	al,1
	jnc	L1m1
	sub	dl,dV ;�᫨ ����� Speed Up, � 㬥��� ����প�.
L1m1:	shr	al,1
	jnc	L1m2
	add	dl,dV ;�᫨ ����� Speed Down, � 㢥��� ����প�.
L1m2:	mov	bl,al ;�६���� ��࠭塞 ��� ��䨪� �� � bl.
	cmp	dl,DelMin ;�஢�ઠ ����稭� ����প�.
	jg	Cmpmax
	mov	dl,DelMin   ;�᫨ ��� ᫨誮� ����, � ��⠭ min ���
	jmp	short Errsp ;����প� � ������ "����� ᪮����".
Cmpmax: cmp	dl,DelMax
	jb	Cmpok ;�᫨ ��� ��ଠ�쭠�, � ���室.
	mov	dl,DelMax ;�᫨ ��� ᫨誮� ������, � ��⠭ ���� ���
Errsp:	mov	al,1      ;����প� � ������ "����� ᪮����".
	out	4,al
	jmp	short Tstdir
Cmpok:	xor	al,al  ;��襭�� "����� ᪮����".
	out	4,al
Tstdir:	mov	dh,dl    ;���४��
	cmp	dl,Delay ;���稪�
	je	Tstd2	 ;����প�
	sub	dl,Delay ;���
	add	dl,DelCnt;�����
	jnle	Tstd1	 ;����稭�
	mov	dl,1	 ;����প�.
Tstd1:	mov	DelCnt,dl
Tstd2:	mov	Delay,dh ;����������� ����稭� ����প�.
	mov	al,bl ;����⠭ ��� ��䨪� �� �� bl.
	shr	al,1
	jnc	IPon
	not	TypeDir ;�᫨ ����� InvDir, � �������� ���ࠢ� ��饭��.
IPon:	shr	al,1
	jnc	IPexit
	mov	FixK,bh
IPexit:	ret
InProc	ENDP

   ;����ணࠬ�� ������樨.
Disp	PROC	
	mov	al,Delay  ;����������
	mov	DelCnt,al ;���稪� ����প�.
	mov	bx,4	;���� 墮�� ��ࠧ� ��࠭� � ���稪 �������஢.
	mov	ah,FixK	;�⥭�� ��� 䨪� �� � AH.
   ;���� �� �������ࠬ.
DLoop1: shl	ah,1   ;�᫨ 䨪� �� ⥪�饣� �������� �����,
	jc	Disp1  ;� ���室 �� ��饭��.
	xor	al,al  ;���� - ��襭��
	jmp	Outscr ;⥪�饣� ��������.
Disp1:	mov	al,[bx] ;������ ��� �� ⥪�饬 ��������.
	cmp	TypeDir,0 ;���� - ��頥� ᥣ�����.
	je	Cw   ;�᫨ TypeDir=0, � ���室 �� ��饭�� �� �� ��५��.
	shr	al,1 ;���� - ��饭�� ��⨢ �� ��५��.
;	cmp	al,00000000b
	jnz	cwok
	mov	al,00100000b
	jmp	short cwok
Cw:	shl	al,1
	cmp	al,01000000b
	jb	Cwok
	mov	al,00000001b
Cwok:	mov	[bx],al
Outscr: dec	bx	;���� ᫥���� �������� � ��ࠧ� � �����.	{<-}
	mov	dx,bx	;���� ᫥���� ���� �������� � ���� ���� 横��.
	out	dx,al	;�뤠� ������ �� ⥪�騩 ��������.
	jnz	DLoop1	;���室 � ��ࠡ�⪥ ᫥���饣� ��������.
	ret
Disp	ENDP

;� � � � � � � � � � � �
   ;�����⮢��
start:	mov	ax,DATA
	mov	ds,ax
	mov	ax,10 ;����稭� ����প� ��� ᪮��� �ਡ��� 1��.
	mov	Delay,al
	mov	DelCnt,al
	mov	TypeDir,ah ;���ࠢ����� ��饭�� - �� �� ��५��.
	mov	KbdImg,ah
	mov	FixK,ah
	mov	al,1
	mov	Indic[0],al
	mov	Indic[1],al
	mov	Indic[2],al
	mov	Indic[3],al

   ;�⥭�� ����������
Mloop:	in	al,[0]
	mov	bh,al	  ;���������� ���ﭨ� 䨪� ������ � bh.

   ;�����஢�� ����������
	xor	al,KbdImg ;�᫨ ��� ��䨪� �� ����������, ᮮ� ��� = 1.
	and	al,bh	  ;�᫨ ��䨪� �� �⠫� ����⮩, ᮮ� ��� = 1.
	mov	KbdImg,bh ;���������� ���ﭨ� ��䨪� ������.

   ;��ࠡ�⪠ ����� (��䨪� ��)
	jz	mDisp
	call	InProc

   ;�⮡ࠦ����
mDisp:	dec	DelCnt	;�᫨ ���稪 ����প� �� ���㫨���,
	jnz	Mloop	;� ���室 �� ��砫� 横��,
	call	Disp	;���� �������� � �⮡ࠧ��� ᥣ�����.
	jmp	Mloop

CODE	ends
	end start