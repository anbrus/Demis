data    segment word public at 0BA00H
        Map     db 0AH dup (?) ; Таблица цифр
	Tochki  dw 100 dup (?) ; Массив точек
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

stack segment at 0BA80H
	dw 200H dup (?)
	StkTop label Word
stack ends

code    segment
	assume 	cs:code,ds:data,ss:stack
Delay   MACRO Time              ; Макрокоманда
	LOCAL C                 ; задержки
        push cx
        mov cx,Time
      C:loop C
        pop cx
	ENDM
PrintValue MACRO Port           ; Вывод цифры 
	xlat                    ; в порт
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
Nachalo proc near           ; Загрузка начальных
	mov al,3FH          ; значений в порты вывода
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
	mov Discr,2H
	mov Schet,1
	mov Chisclo,0
	mov NumTochki,0
	mov PerZap,0
	mov ProvP,0  
	ret
Nachalo endp
;**************************************************************************
ObrabotkaKl1 proc near     ; Процедура обрабатывает
	mov ZnachInc1,0    ; нажатие клавиш и уста-
	mov ZnachDec1,0    ; навливает соответствующий 
	mov PerDiscr,0     ; флаг
	cmp KlStop,0FFH
	je konobr
	cmp KlStart,0FFH
	je konobr
obrab:	in al,0
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
	mov ZnachInc1,0FFH
	jmp konobr
obrab2: 
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
	inc Chisclo 	    ; Процедура сравнения    
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
	mov cx,500H
prib2:	in al,0
	cmp al,0
	je konprib
	loop prib2
prib3:	in al,0             ; то выполняется функция 
	cmp al,1            ; автоповтора
	jne konprib 
	inc Chisclo 	    ; Процедура сравнения    
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
	Delay 100H 
	jmp prib3
konprib:
	ret
Pribavlenie endp
;*************************************************************************
Vichitanie proc near       ; Процедура проверяет
	cmp ZnachDec1,0FFH ; была ли нажата соответствующая
	je vich            ; клавиша, если да, то произво-
	jmp konvich        ; дится уменьшение параметра на 1.
vich:	
	mov dl,10              ; Процедура сравнения    
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
	PrintValue 1       ; Если клавиша не была отпущена
	mov cx,500H
vich2:	in al,0
	cmp al,0
	je konprib
	loop vich2
vich3:	in al,0            ; автоповтора
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
	Delay 100H
	jmp vich3
konvich:
	ret   
Vichitanie endp
;************************************************************************
Discret proc near         ; Процедура проверяет была  
	cmp PerDiscr,0FFH ; ли нажата соответствующая
	je dis            ; клавиша. Если да, то произ-
	jmp kondiscr      ; водится изменение периода 
dis:	cmp Schet,1       ; дискретизации по цикличес-
	je dis1	          ; кому закону
	cmp Schet,2
	je dis2
	cmp Schet,3
	je dis3
	jmp kondiscr 
dis1:
	inc Schet
	mov Discr,4H
	jmp dis4
dis2:
	inc Schet
	mov Discr,6H
	jmp dis4
dis3:
	mov Schet,1
	mov Discr,2H
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
	jne zap00   ; если ниже или равно
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
z3:	in al,0
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
	je zap12       ; выше или равно
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
	mov cx,90H
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
	mov cx,90H
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
	mov cx,90H
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
Prepear proc near        ; Процедура устанавливает
	cmp KlStop,0FFH  ; номер 1-й точки и выводит 
	jne konprep      ; соответствующее ей
	cmp KlStart,0FFH ; значение параметра
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
ObrabotkaKl2 proc near     ; Процедура обрабатывает
	mov ZnachInc2,0    ; нажатие клавиш и уста-
	mov ZnachDec2,0    ; навливает соответствующий 
	mov MaxMaxKl,0     ; флаг после окончания
	mov MinKl,0        ; процесса фиксирования
	mov MaxKl,0
	mov MinMinKl,0
	cmp KlStop,0FFH
	jne konobrab   
obr:	in al,1
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
ProsmotrInc proc near      ; Процедура проверяет
	cmp ZnachInc2,0FFH ; была ли нажата соответствующая
	je pri             ; клавиша, если да, то выполняется
	jmp konpinc
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
	mov cx,500H
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
	Delay 100H
	jmp pri3
konpinc:
	ret
ProsmotrInc endp
;*****************************************************************************
ProsmotrDec proc near      ; Процедура проверяет была
	cmp ZnachDec2,0FFH ; ли нажата соответствующая
	je prd
	jmp konpdec        ; клавиша, если да, то произ-  
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
	mov cx,500H
prd2:	in al,1
	cmp al,0
	je konpinc
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
	Delay 100H
	jmp prd3 
konpdec:
	ret
ProsmotrDec endp
;*****************************************************************************
MaxMax proc near               ; Процедура находит
	cmp MaxMaxKl,0FFH      ; максимум максиморум 
	je m                   ; в массиве параметров
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
	jb m1         ; если ниже 
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
MinMin proc near               ; Процедура находит
	cmp MinMinKl,0FFH      ; минимум миниморум 
	je mm                  ; в массиве параметров
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
	ja mm1         ; выше 
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
	jnae mx2        ; не выше и не равно
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
mx3:	in al,1
	cmp al,0
	jne mx3
mx4:	in al,1
	cmp al,8
	jne mx4
	jmp mx1
konm1:	
	mov al,8
	out 9,al
	Delay 2000H
	mov al,0
	out 9,al
konm:
	ret
Max endp
;*****************************************************************************
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
	jae mix2        ; выше или равно
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
mix3:	in al,1
	cmp al,0
	jne mix3
mix4:	in al,1
	cmp al,16
	jne mix4
	jmp mix1
konmi1:	
	mov al,16
	out 9,al 
	Delay 2000H
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
next:
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
	jmp next	
code 	ends
end 	start