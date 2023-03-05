name examinator
page ,100 
tmode equ 0;программирование(режим по умолчанию)
tut equ 0;нет учета времени
tick equ 18
                ;порты ввода:
ip_mut0 equ 00h ;режим,учет,время
ip_varnznq1 equ 01h ;варианты,следующее задание,вопрос
                 ;порты вывода:
op_mut2 equ 02h ;режим,учет
op_var3 equ 03h ;вариант
op_nz4 equ 04h ;номер задания
op_nq5 equ 05h ;номер вопроса
op_t10 equ 06h ;время 10
op_t1 equ 07h ;время 1
op_oz8 equ 08h ;оценка


data segment at 0BA00H
mode db ?;режим
ut db ? ;учет времени
kbim db 2 dup (?);образ клавиатуры
key db ?;нажатая клавиша
variant db ?;вариант
nz db ?;номер задания
nq db ?;номер вопроса
oz db ?;оценка
tz db 2 dup (?);время на задание
tost db 2 dup (?);оставшееся до конца время
kbun db ?;флаг неучета клавиатуры
kber db ?;флаг ошибки клавиатуры
zder db ?;флаг - задание не запрограммировано
mo2x db 5 dup (?); массив 2-х индикаторов
mo8x db 5 dup (?); массив 8-х индикаторов

zdtype struc
       q0 db ?; \
       q1 db ?;  :
       q2 db ?;  :
       q3 db ?;  :
       q4 db ?;   :\ варианты ответов
       q5 db ?;   :/ на вопросы задания
       q6 db ?;  :
       q7 db ?;  :
       q8 db ?;  :
       q9 db ?;  /

       tz1 db ? ;\ время на задание
      tz10 db ? ;/
      enb db ? ;>> флаг запрогр. задания
zdtype ends
maszd zdtype 0ah dup (?);<< массив заданий

map db 0BH dup (?);для отображения на 8-х инд-х
temp db ?  ;используется при вводе режима
temp2 db ? ;при вводе учета времени
last db ? ;для учета неотпускаемой клавиши
nqprev db ?;номер предыдущего вопроса
tempoz db ?;временная оценка
t1 dw ?  ;для выдержки секунды
data ends

code segment
assume cs:code,ds:data
;──────────────────────────────────────────────
 init proc near ;процедура инициализации
    mov mode,tut
    mov ut,tut
    mov word ptr kbim,0
    mov key,0
    mov variant,0
    mov nz,0
    mov nq,0ffh
    mov oz,0ffh
    mov word ptr tz,0
    mov word ptr tost,0
    mov kbun,0
    mov kber,0
    mov zder,0
    mov cx,5
    mov al,0
    lea di,mo2x
    cld
    rep stosb
    mov cx,5
    lea di,mo8x
    rep stosb
    mov cx,13*10
    lea di,maszd
    rep stosb

    mov temp,tmode
    mov last,0
    mov nqprev,0ffh
    mov tempoz,0ffh
    mov t1,0
    mov map[0], 3FH
    mov map[1], 0CH
    mov map[2], 76H
    mov map[3], 05EH
    mov map[4], 4DH
    mov map[5], 5BH
    mov map[6], 7BH
    mov map[7], 0EH
    mov map[8], 7FH
    mov map[9], 5FH
    mov map[10],6FH
    ret
 init endp
;──────────────────────────────────────────────
 inmode proc near ;процелура ввода режима
	in al,ip_mut0
	cmp nq,0ffh;<<переключать режим нельзя,если начали
	jnz ext1   ;программировать или экзамен
	cmp al,temp;учет неотпускания
	jz ext1
	mov temp,al
	cmp al,1
	jnz mi1
	mov mode,0h
	jmp ext1
  mi1:  cmp al,2
	jnz ext1
	mov mode,0ffh
 ext1:	ret
 inmode endp
;──────────────────────────────────────────────

 inut proc near   ;процелура ввода учета времни
	cmp nq,0ffh ;<<переключать учет времени нельзя,если
	jnz exti    ; начали экзамен
	cmp mode,0  ;при программировании учет есть,
	jz minn     ;т.к. нужно вводить время на задание
	in al,ip_mut0
	cmp al,temp2 ;учет неотпускания
	jz exti
	mov temp2,al
	cmp al,08h
	jnz min1
minn:  	mov ut,0ffh ;учет есть
	jmp exti
min1:   cmp al,10h
	jnz exti
	mov ut,0
  exti:	ret
 inut endp
;──────────────────────────────────────────────

 kbinput proc near  ;процедура ввода образа
	in al,ip_mut0 ; клавиатуры
	mov kbim,al
	in al,ip_varnznq1
	mov kbim[1],al
	ret
 kbinput endp
;──────────────────────────────────────────────
 control proc near ;поцедура контроля ввода
                   ; с клавиатуры
	mov al,kbim
	mov ah,kbim[1]
        mov kber,0 ;
	mov bl,0   ; учет нажатия
	mov cx,15  ; двух и
  bitr: test ax,1  ; более клавиш
	jz nb1     ;
	inc bl     ;
  nb1:	shr ax,1   ;
	loop bitr  ;
	cmp bl,1   ;
	jna noerr  ;
	mov kber,0ffh; ошибка клавиатуры
  noerr:
	mov al,kbim   ;
	or al,kbim[1] ;проверка на неотжатие
	cmp al,last   ; и на ненажатие
	jnz con1      ;
	mov kbun,0ffh ;
	jmp conext    ;
  con1:	mov last,al   ;
	mov kbun,00h  ;все нормально
	cmp al,0      ;
	jnz conext    ;
	mov kbun,0ffh ;нет учета клавиатуры
 conext: ret
 control endp
;──────────────────────────────────────────────
 controlzd proc near  ;процедура проверки
	cmp mode,0  ;задание на запрограммированность
	jz cz2
        cmp nq,0
	jnz cz1
	lea si,maszd
	mov al,nz
	mov bl,13
	mul bl
	add si,ax
	mov al,[si+12]
	cmp al,0ffh   ;проверка флага задания
	jz cz2
	mov zder,0ffh
	dec nq
  cz1:	cmp kbim[1],80h
	jz cz2
	mov zder,0
   cz2: ret
 controlzd endp
;──────────────────────────────────────────────

 ankey proc near   ;процедура распознования
	mov al,kber ;нажатой клавиши
	or al,kbun
	cmp al,0   ;если есть ошибки кла-ры
	jnz anext  ;ничего не делаем
	cmp kbim,40h
	jnz an1
	mov al,2 ;клавиша +1
	jmp ann
  an1:	cmp kbim,80h
	jnz an2
	mov al,3 ;клавиша +10
	jmp ann
  an2:  cmp kbim[1],40h
	jnz an3
	mov al,0 ;клавиша след. задание
	jmp ann
  an3:  cmp kbim[1],80h
	jnz an4
	mov al,1 ;клавиша след. вопрос
	jmp ann
  an4:  mov al,kbim+1
	mov cl,0
  san1:	shr al,1
	inc cl
	cmp al,0
	jnz san1
        mov al,3
	add al,cl ; клавиша варианта
  ann:  mov key,al
 anext:	ret
 ankey endp
;──────────────────────────────────────────────
 variform proc near ; процедура формирования варианта
	cmp nq,0ffh ; проверка н-ра вопроса
	jz varext
	mov al,kber
	or al,kbun
	cmp al,0   ;учет ошибок
	jnz varext
	cmp key,4  ;нажата клавиша варианта
	jb varext
	mov al,key
	sub al,3
	mov variant,al ;вариант ответа
 varext:ret
 variform endp
;──────────────────────────────────────────────
 nzform proc near ; процедура формирования н-ра задания
	cmp nq,0ffh ; проверка н-ра вопроса
	jnz nzext
	mov al,kber
	or al,kbun
	cmp al,0  ;учет ошибок
	jnz nzext
	cmp key,0 ;нажата клавиша след. задание
	jnz nzext
	inc nz
	cmp nz,0ah;если н-р больше 9,то =0
	jnz nzext
	mov nz,0
 nzext: ret
 nzform endp
;──────────────────────────────────────────────
 nqform proc near ; процедура формирования н-ра вопроса
	mov al,kber
	or al,kbun
	cmp al,0   ;учет ошибок
	jnz nqext
	cmp key,1 ;нажата клавиша след. вопрос
	jnz nqext
	inc nq
	cmp nq,0ah;если н-р больше 9,то =0
	jnz nqext
	mov nq,0
 nqext:	ret
 nqform endp
;──────────────────────────────────────────────
 tzinput proc near ;процедура ввода времени на задание
	mov al,kber
	or al,kbun
	or al,mode
	cmp al,0 ; учет режима и ошибок
	jnz tzext
	cmp key,2 ;нажата клавиша +1
	jnz tze1
	inc tz    ;время + 1
	cmp tz,0ah
	jnz tze1
	mov tz,0
 tze1:	cmp key,3 ;нажата клавиша +10
	jnz tzext
	inc tz[1] ;время + 10
	cmp tz[1],0ah
	jnz tzext
	mov tz[1],0
 tzext:	ret
 tzinput endp
;──────────────────────────────────────────────
 mo8xform proc near  ; процедура формирования
	mov al,kber
	or al,zder
	cmp al,0  ; выводить сообщ. об ошибке
	jz m81
	mov mo8x,0f0h ; ошибка есть
	jmp m8ext
 m81:	mov al,nz  ;номер задания
	mov mo8x,al

	mov al,nq
	cmp zder,0ffh
	jnz m88   ;если ошибка задания
	mov al,0ffh ;  нет н-ра вопроса
 m88:	mov mo8x[1],al ;иначе есть

	cmp mode,0 ;при прогаммировании оценки нет
	jz noz
	mov al,oz
	mov mo8x[2],al ;оценка
	jmp yoz
  noz:  mov mo8x[2],0ffh ;нет оценки
  yoz:
	cmp mode,0h ;при программировании
	jnz els     ;отображаем время на задание
	mov al,tz   ;при экзаменовке - оставшееся
	mov mo8x[3],al; время ,если учет времени
	mov al,tz[1]  ;есть
	mov mo8x[4],al
	jmp m8ext
  els: 	cmp ut,0ffh
	jnz els1
	mov al,tost
	mov mo8x[3],al
	mov al,tost[1]
	mov mo8x[4],al
	jmp m8ext
 els1:	mov al,0ffh
	mov mo8x[3],al
	mov mo8x[4],al
 m8ext:	ret
 mo8xform endp
;──────────────────────────────────────────────
 mo8xout proc near ; процедура вывода на 8-е
	cmp mo8x,0f0h
	jnz o83
	mov al,73h ; E - ошибка
	out op_nz4,al
	jmp oext
 o83:	lea bx,map
	mov al,mo8x  ;вывод н-ра
 	xlat         ;задания
	out op_nz4,al

	mov al,mo8x[1]
	cmp al,0ffh ;выводить н-р вопроса
	jz nonq
 	xlat
	out op_nq5,al ;выводим н-р вопроса
	jmp ynq
  nonq: mov al,0
	out op_nq5,al ;пустой инди-р
  ynq:
	mov al,mo8x[2]
	cmp al,0ffh  ;выводить оценку
	jz notoz
 	xlat
	out op_oz8,al ;выводим оценку
	jmp ozext
 notoz:	mov al,0
	out op_oz8,al ;пустой инди-р
  ozext:

	cmp mo8x[4],0ffh ;выводить время
	jz oe2
	mov al,mo8x[4]
 	xlat
	out op_t10,al  ;выводим время
	mov al,mo8x[3]
 	xlat
	out op_t1,al ;выводим время
	jmp oext
    oe2:mov al,0 ;пустой инди-р
	out op_t10,al
	out op_t1,al
  oext:	ret
 mo8xout endp
;──────────────────────────────────────────────
 zprogram proc near ;процедура прогр-ия задания
	cmp mode,0 ;только при программировании
	jnz zpext
        mov al,kbun
        or al,kber
	cmp al,0 ; учет ошибок клав-ры
	jnz zpext
	mov al,nqprev
	cmp al,nq  ;номер вопроса изменился
	jz zpext

	lea bx,maszd ;настройка на запись
	mov al,nz    ;текущего задания
	mov dl,13
	mul dl
	add bx,ax
	mov al,nqprev
	mov ah,0
	mov si,ax ;предыдущий вопрос
	mov al,nq
	mov ah,0
	mov di,ax ;текущий вопрос

	mov al,nqprev
	xor al,9
	xor al,nq
	cmp al,0 ;все задание
	jnz zpr1
	mov al,variant  ;запись последнего
	mov [bx+si],al  ;вопроса
	mov nq,0ffh
	mov variant,0
	mov ax,word ptr tz
	mov [bx+10],ax
	mov byte ptr [bx+12],0ffh ;задание есть
	jmp zpr2
  zpr1: cmp nq,0
	jz zpr12
	mov al,variant
	mov [bx+si],al ;запись предыдущего вопроса
 zpr12:	mov al,[bx+di] ;отображаем бывший вариант
	mov variant,al ;ответа на вопрос
  zpr2: mov al,nq
	mov nqprev,al
 zpext:	ret
 zprogram endp
;──────────────────────────────────────────────
 ozcount proc near   ; процедура формирования оценки
	cmp mode,0ffh
	jnz ozce

	lea bx,maszd ;настройка на запись
	mov al,nz    ;текущего задания
	mov dl,13
	mul dl
	add bx,ax
	mov al,nqprev
	mov ah,0
	mov si,ax ;предыдущий вопрос
	mov al,nq
	mov ah,0
	mov di,ax ;текущий вопрос

	cmp ut,0ffh
	jnz oztim
	mov ax,word ptr tost
	cmp ax,0        ;учитываем время,
	jnz oztim       ;если нужно
	mov al,nqprev
	or al,nq
	cmp al,0ffh
	jz oztim
	cmp oz,0ffh
	jz ozc20   ;на вывод оценки
 oztim:
        mov al,kbun
        or al,kber
  	cmp al,0 ;учет ошибок кла-ры
	jz ozce1
 ozce:	jmp ozcext
	cmp zder,0ffh ;учет ошибки задания
	jz ozce
 ozce1:
	mov al,oz
	cmp al,tempoz ;если оценка на инд-ре
	jnz ozc1      ;и клав-ра активна
	mov oz,0ffh   ;гасим оценку
	mov tempoz,0
  ozc1:
	mov al,nqprev ;н-р вопроса изменился
	cmp al,nq
	jz ozcext
	mov al,nq
	xor al,nqprev
	xor al,9
	cmp al,0 ;конец задания
	jnz ozc2

 ozc20: mov al,variant ;учитываем ответ
	cmp al,[bx+si] ;на послед. вопрос
	jnz ozc31
	cmp al,0
	jz ozc31
	inc tempoz
 ozc31:	mov al,tempoz
	mov oz,al   ;выводим оценку
	mov nq,0ffh
	mov tost,0
	mov tost[1],0
	jmp ozc3

  ozc2: cmp nq,0
	jz ozc3
	mov al,variant ;учитываем ответ
	cmp al,[bx+si] ;на предыдущий вопрос
	jnz ozc3
	cmp al,0
	jz ozc3
	inc tempoz
 ozc3:	mov al,nq
	mov nqprev,al
	mov variant,0
 ozcext:ret
 ozcount endp
;──────────────────────────────────────────────
 timecount proc near ;процедура формирования учета времени
	cmp mode,0ffh ;только при экзаменовке
	jnz tmext
	cmp ut,0ffh  ;учет нужен
	jnz tmext
	cmp zder,0h  ;ошибки задания нет
	jnz tmext
	mov al,nqprev
	xor al,0ffh
	xor al,nq
	cmp al,0 ;можно начать отсчет
	jnz tm1
	lea si,maszd
	mov al,nz
	mov bl,13
	mul bl
	add si,ax
	mov al,[si+10] ;получаем
	mov tost,al    ;время на
	mov al,[si+11] ; текущее задание
	mov tost[1],al ;
  tm1:  cmp nq,0ffh
	jz tmext

	mov ah,0   ;выдерживаем
	int 1ah    ; 1 секунду
	mov ax,dx  ;
        sub dx,t1
	cmp dx,tick
	jb tmext
	mov t1,ax

	cmp tost,0 ;уменьшаем оставшееся
	jz tm2     ;время
	dec tost
	jmp tmext
  tm2:	cmp tost[1],0
	jz tmext
	mov tost,9
	dec tost[1]
 tmext: ret
 timecount endp
;──────────────────────────────────────────────
 mo2xform proc near  ; процедура формирования
                     ; массива 2-х инд-ов
	mov cx,9
	mov al,0
	lea di,mo2x
	cld
	rep stosb   ;очистка всех индикаторов

	lea di,mo2x
	mov al,mode
	cmp al,0
	jnz mm1
	not al
	mov [di],al ;подсветка либо программирования
	jmp extmo
   mm1: mov [di+1],al ; либо экзаменовки
 extmo:
	mov al,ut
	cmp al,0  ;учет времени
	jnz mm2
	not al
	mov [di+3],al ;нет
	jmp extmo1
   mm2: mov [di+2],al ;да
extmo1:
	mov al,variant
        cmp al,0
	jz extmo2
	mov [di+4],al ;номер варианта
extmo2:	ret
 mo2xform endp
;──────────────────────────────────────────────
 mo2xout proc near ;процедура вывода на 2-е
	lea si,mo2x
	mov ah,0ffh
	mov al,0
	cmp ah,[si]
	jnz exm1
	or al,01h ;отображаем программирование
	jmp mmo1
exm1:   or al,02h ;иначе экзамен
mmo1:
	cmp ah,[si+2] ;отображаем учет времени
	jnz exm2
	or al,08h ;да
	jmp mmo2
exm2:   or al,10h ;нет
mmo2:   out op_mut2,al
        mov al,[si+4]
        cmp al,0
	jz mmo21
	mov cl,al
	mov al,1
	dec cl
	shl al,cl
mmo21:	out op_var3,al ;отображаем вариант
      	ret
 mo2xout endp
;──────────────────────────────────────────────



begin: mov ax,data
       mov ds,ax
       mov es,ax
       mov ax,steck
       mov ss,ax       
       mov sp,offset StkTop 
       call init
m:     call inmode   
       call inut
       call kbinput
       call control	
       call ankey
       call variform
       call nzform
       call nqform
       call tzinput
       call zprogram	
       call controlzd	
       call timecount 			
       call ozcount
       call mo8xform
       call mo8xout 			
       call mo2xform
       call mo2xout
       jmp m		
       org 07F0H
start: jmp begin
code ends

steck segment stack at 0BA80H
  org 100h 
  dw 20H dup (?)
  StkTop label word
steck ends

end start