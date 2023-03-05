On=0ffh
Off=00h

Data segment 
	ArTime db  10 dup (0) ;Массив времени
	dig    db 10 dup (?)  ;Массив отображения
	Table_dig db 3fh,0ch,76h,5eh,4dh  ;Таблица перекодировки
                  db 5bh,7bh,0eh,7fh,5fh
	SetFixator db Off    ;
	ModeFixator db Off   ;
	k dw ?               ;
        a db 0               ;
	xx db 5 dup (?)      ;Массив времени одного игрока 
	n dw 01h             ;Признак формирования массива
   			     ;времени одного игрока
	l db 0               ;Признак окончания игры
	Play1Fixator db Off  ;
	Play2Fixator db Off  ;
Data ends
Stack segment para stack 
	dw 128 dup (?)
	stk label word
Stack ends
Code segment 
	assume cs:code,ds:data,es:data,ss:stack
;       Задержка на время t 
Delay   macro t                      
	local td
	mov cx,t
td:	nop
	loop td
	endm

;       Процедура формирования массива
;        отображения из массива времени
Kodir   proc                        
	push si                     
	lea si,artime
	lea di,dig
	lea bx,table_dig
	mov cx,10
dg1:	mov al,[si]
	xlat
	mov [di],al
	inc si
	inc di
	loop dg1
	pop si
	ret
Kodir   endp
;       Процедура вывода времени на семисегментные индикаторы
Out_time proc
	push si
	lea si,dig
	xor dx,dx
	mov cx,10
Outing: mov al,[si]
	out dx,al
	inc si
	inc dx
	loop Outing
	pop si
	ret
Out_time endp
;       Процедура уставонки режима
Mode    proc
	mov si,0
Md:	in al,0
	and al,00000001b
	jnz Md1
	mov ModeFixator,Off
	jmp Md
md1:	cmp ModeFixator,On
	je Md
	mov ModeFixator,On
md2:	push si
        LEA SI,ARTIME
	LEA DI,DIG
	CALL KODIR
	pop si
	lea bx,dig
	add byte ptr [bx+si],80h
	call Out_Time
	sub byte ptr [bx+si],80h
	mov k,si
	call Set
	add si,1
	cmp si,11
	jb Md2
        ret
Mode    endp		
;       Процедура установки времени
Set     proc
	mov si,k
st0:	in al,0
	and al,00000001b
	jnz st1
	mov ModeFixator,Off
	jmp   st3
st1:	cmp ModeFixator,On
	je st3
	mov ModeFixator,On
	jmp st9
st3:	in al,0
	and al,00000010b
	jnz st4
	mov SetFixator,Off
	jmp st0
st4:	cmp SetFixator,On
	je st0
	mov SetFixator,On
	lea bx,artime
	add byte ptr [bx+si],1
        cmp si,4
        ja st6
	clc
        push si
        shr si,1
        pop si
	jnc st7
st5:	cmp byte ptr[bx+si],6
        jnz st7
        mov byte ptr [bx+si],0
        jmp st7
st6:    push si
        shr si,1
        pop si
	jnc st5
st7:	cmp  byte ptr [bx+si],10
	jnz st8
	mov byte ptr [bx+si],0
st8:	push si
	call Kodir
	pop si
	push bx
	lea bx,dig
	add  byte ptr [bx+si],80h
	pop bx
	call Out_time
	jmp st0
st9:	ret
Set     endp
;       Процедура формирования массива времени 
;          одного игрока из массива времени
Zam     proc
	mov cx,5
z1:	mov al,[si]
	mov [di],al
	inc si
	inc di
	loop z1
	ret
Zam     endp
;       Процедура отсчет времени
Count   proc
m1:	in al,0 
  	and al,00000001b
	jnz m2
	mov ModeFixator,Off
	jmp   m3
m2:	cmp ModeFixator,On        
	je m3
	mov ModeFixator,On
	jmp m22
m3:	cmp l,0      
	jnz m4
        jmp m5
m4:	jmp m19
m5:	in al,0               
	and al,00001000b
	jnz m6
	mov Play2Fixator,Off
	jmp   m7
m6:	cmp Play2Fixator,On
	je m7
	mov Play2Fixator,On
	mov n,0
m7:	in al,0                   
	and al,00000100b
	jnz m8
	mov Play1Fixator,Off
	jmp   m9
m8:	cmp Play1Fixator,On
	je m9
	mov Play1Fixator,On
	mov n,5
m9:	cmp n,1
	jz m1
	lea di,xx
	lea si,artime
        add si,n
	call Zam
	lea di,xx
	mov cx,2
m10: 	sub  byte ptr [di],1		
	cmp byte ptr [di],-1
	jnz m11
	mov byte ptr [di],9
	inc di
	sub  byte ptr [di],1		
	cmp byte ptr [di],-1
	jnz m11
	mov byte ptr [di],5
	inc di
	loop m10
	sub  byte ptr [di],1		
	cmp byte ptr [di],-1
	jnz m11
        mov l,0ffh
        jmp m19
m11:	lea di,xx
	mov cx,2
m12:	cmp byte ptr [di+4],0
	jnz m15
	dec di
	loop m12
	cmp byte ptr [di+4],2
	jae m15
	cmp n,0
	jnz m13
	or a,01h
	jmp m14
m13:	or a,02h
m14:	mov al,a
	out 10,al
m15:	lea di,xx
	mov cx,5
m16:	cmp byte ptr [di],0
	jnz m17
	inc di
	loop m16
	mov l,0ffh
	jmp m18
m17: 	mov l,00h
m18:	lea si,xx
	lea di,artime
        add di,n
	call Zam
	call Kodir
	call Out_time
	Delay 132
m19:	cmp l,0
	jz m20
        jmp m21 
m20:	jmp m1
m21:	mov al,04h
	out 10,al
	Delay 100
	mov al,08h
	out 10,al
	Delay 100
	jmp m1
m22:	mov al,0
	out 10,al
	ret
Count   endp
				
		
Start:  mov ax,Data
	mov ds,ax
	mov es,ax
	mov ax,Stack
	mov ss,ax
	lea sp,stk
begin: 
	mov a,0
	mov n,01
	mov l,0
	lea di,dig
	call Kodir
	call Out_time
	call Mode
	call Count
	jmp begin
Code ends
End start