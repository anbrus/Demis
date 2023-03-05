.386

RomSize    EQU   4096
NMAX       equ 125
DECCOUNT   equ 255
PCOUNT     equ 1000
INPORT     equ 0      ;порт ввода с кнопок
OUTPORT    equ 0      ;порт вывода на светодиоды и динамики 
ILHOUR     equ 1      ;для левых часов 
ILMINH     equ 2        
ILMINL     equ 3
ILSECH     equ 4
ILSECL     equ 5
IRHOUR     equ 6      ;для правых часов 
IRMINH     equ 7
IRMINL     equ 8
IRSECH     equ 9
IRSECL     equ 10
LSET       equ 4
RSET       equ 8
LMODE      equ 1
RMODE      equ 2
LSTOP      equ 16
RSTOP      equ 32
RESET      equ 64
LBEEP      equ 1
RBEEP      equ 2
LSVET      equ 4
RSVET      equ 8

Data       SEGMENT AT 0 use16

Lhour      db ?
Lminh       db ?
Lminl       db ?
Lsech       db ?
Lsecl       db ?
Rhour      db ?
Rminh       db ?
Rminl       db ?
Rsech       db ?
Rsecl       db ?
Lhour_      db ?
Lminh_       db ?
Lminl_       db ?
Lsech_       db ?
Lsecl_       db ?
Rhour_      db ?
Rminh_       db ?
Rminl_       db ?
Rsech_       db ?
Rsecl_       db ?
Count      db ?
OutPort0   db ?
endtime    db ?
Data       ENDS



Stk        SEGMENT AT 100h use16
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS


Code       SEGMENT use16
Image      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh


           ASSUME cs:Code,ds:Data,es:Data,ss:Stk

GetKey     proc near            ; процедура опроса клавиатуры
           push bx

           in al,INPORT
           cmp al,0             ; клавиша нажата?
           jz gk2
           
           mov   ah,al       ;Сохранение исходного состояния
           
vd2:       in    al,INPORT   ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jz    vd2         
           xor   bh,bh        ;Сброс счётчика повторений
vd1:       in    al,INPORT    
           cmp   al,0        ;кнопка отпущена?    
           jnz   vd2         ;Если нет, значит, был дребезг
           inc   bh          
           cmp   bh,NMax     ;Конец дребезга?
           jnz   vd1         ;Переход, если нет                   
           jmp   gk3
gk2:       mov ah,0          ;нет нажатия           
gk3:       
           pop bx
           ret
GetKey     endp
;--------------------------------
Pause      proc near          ;процедура задержки
           push cx
           mov cx,PCOUNT
      pl1: push cx
           pop cx
           push cx
           pop cx
           push cx
           pop cx
           dec cx
           jnz pl1
           pop cx
           ret
Pause      endp

;---------------------------------------
;Left half process
;---------------------------------------
LDec      proc near            ;процедура уменьшения времени и вывод на индикаторы
           and LHour,0fh
           and LMinL,0fh
           call LTest0         ;проверяем, вышло время или нет 
           cmp al,0
           jz ld1
           cmp al,1
           jnz ld0
           or OutPort0,LSVET  ;включить левую лампочку
           mov al,OutPort0
           out OUTPORT,al
      ld0: cmp Lsecl,0
           jz MLsech
           dec Lsecl
           jmp EndLDec
MLsech:    mov Lsecl,9

           cmp Lsech,0
           jz MLminl
           dec Lsech
           jmp EndLDec
MLminl:    mov LSech,5

           cmp LMinl,0
           jz MLminh
           dec LMinl
           jmp EndLDec
MLminh:    mov LMinl,9

           cmp LMinh,0
           jz MLhour
           dec LMinh
           jmp EndLDec
MLHour:    mov LMinh,5

           cmp LHour,0
           jz EndLDec
           dec LHour
           jmp EndLDec
     ld1:  or OutPort0,LBEEP   ;включение левого динамика 
           mov al,OutPort0
           out OUTPORT,al
           mov al,0
EndLDec:   or LHour,128        ; включить разделители часов и минут 
           or LMinL,128
           call LOut
           push ax
           mov al,DECCOUNT
LDecPause: inc al
           dec al
           push ax
           pop ax
           push ax
           pop ax
           dec al
           jnz LDecPause
           pop ax

           
           ret
LDec       ENDP
;----------------------------------------------------
LOut       proc near          ;вывод на индикаторы 
           push ax            ; время
           push bx
           push dx
           mov ax,ds
           push es
           pop ds
           mov es,ax
           lea bx,Image
           mov al,es:[Lhour]
           mov ah,al
           and al,0fh
           and ah,0f0h
           xlat
           or al,ah
           out ILHOUR,al
           mov al,es:[LMinH]
           mov ah,al
           and al,0fh   ;мл.биты 
           and ah,0f0h  ;ст. биты 
           xlat
           or al,ah     ;вкл.точку(если надо)
           out ILMINH,al
           mov al,es:[LMinL]
           mov ah,al
           and al,0fh
           and ah,0f0h
           xlat
           or al,ah
           out ILMINL,al
           mov al,es:[LSecH]
           mov ah,al
           and al,0fh
           and ah,0f0h
           xlat
           or al,ah
           out ILSECH,al
           mov al,es:[LSecL]
           mov ah,al
           and al,0fh
           and ah,0f0h
           xlat
           or al,ah
           out ILSECL,al
           mov ax,ds
           push es
           pop ds
           mov es,ax
           pop dx
           pop bx
           pop ax
           ret
LOut       endp
;--------------------------------------
LTest0     proc near     ;проверка времени (в AL 0-вышло
           xor ah,ah                       ;1- 1 мин. 
           mov al,LHour                    ;0ffh- много) 
           and al,0fh
           add ah,al
           mov al,LMinH
           and al,0fh
           add ah,al
           mov al,LSecH
           and al,0fh
           add ah,al
           mov al,LSecL
           and al,0fh
           add ah,al
           mov al,0ffh
           cmp ah,0
           jnz LEndTest
           mov al,1
           mov ah,LMinL
           and ah,0fh
           cmp ah,1
           jz LEndTest
           mov al,0
           cmp ah,0
           jz LEndTest
           mov al,0ffh
LEndTest:  
           ret
LTest0       endp
;-----------------------------------------------
PLmode     proc near   ;установка времени (LSET и LMODE)
           push bx
           push cx
mov al,Lhour_   ;восстановление времени
mov LHour,al
mov al,Lminh_
mov Lminh,al
mov al,Lminl_
mov Lminl,al
mov al,Lsech_
mov Lsech,al
mov al,Lsecl_
mov Lsecl,al


           lea bx,LHour
           and LHour,0fh  ; погасить
           and LMinL,0fh  ; точки
           mov al,[bx]    ;включить точку на активном инд.
           or al,128      ;
           mov [bx],al    ;

           call LOut
           mov cl,10
           xor ch,ch
     plm1: call GetKey
           cmp ah,LSET
           jz  plm2   ;если нажата LSET
           cmp ah,LMODE
           jz plm11   ;если нажата LMODE

           jmp plm1
    plm11:              ; перебор позиций и    
           mov al,[bx]  ; переключение точек
           and al,0fh   ;
           mov [bx],al  ;
           inc bx       ;
           mov al,[bx]  ;
           or al,128    ;
           mov [bx],al  ;
           call LOut    ; 

           inc ch       ;
           cmp ch,5     ;
           jz EndLmode  ;

           cmp cl,10
           jz plm3
           mov cl,10
           jmp plm1
     plm3: mov cl,6
           jmp plm1
     plm2: mov al,[bx]
           inc al
           mov [bx],al
           mov ah,al
           and ah,0f0h
           and al,0fh
           sub al,cl
           jc plm4
           xor al,al
           or al,ah
           mov [bx],al
     plm4: call LOut
           jmp plm1
 EndLmode: or LHour,128
           or LMinL,128
           call LOut
mov al,Lhour    ;сохранение времени
mov LHour_,al
mov al,Lminh
mov Lminh_,al
mov al,Lminl
mov Lminl_,al
mov al,Lsech
mov Lsech_,al
mov al,Lsecl
mov Lsecl_,al

           pop cx
           pop bx
           ret
PLmode     endp

;--------------------------------------
;Right half process
;--------------------------------------
RTest0      proc near
           xor ah,ah
           mov al,RHour
           and al,0fh
           add ah,al
           mov al,RMinH
           and al,0fh
           add ah,al
           mov al,RSecH
           and al,0fh
           add ah,al
           mov al,RSecL
           and al,0fh
           add ah,al
           mov al,0ffh
           cmp ah,0
           jnz REndTest
           mov al,1
           mov ah,RMinL
           and ah,0fh
           cmp ah,1
           jz REndTest
           mov al,0
           cmp ah,0
           jz REndTest
           mov al,0ffh
REndTest:   ret
RTest0       endp

RDec      proc near

           and RHour,0fh
           and RMinL,0fh
           call RTest0
           cmp al,0
           jz rd1
           cmp al,1
           jnz rd0
           or OutPort0,RSVET
           mov al,OutPort0
           out OUTPORT,al
     rd0:  cmp Rsecl,0
           jz MRsech
           dec Rsecl
           jmp EndRDec
MRsech:    mov Rsecl,9

           cmp Rsech,0
           jz MRminl
           dec Rsech
           jmp EndRDec
MRminl:    mov RSech,5

           cmp RMinl,0
           jz MRminh
           dec RMinl
           jmp EndRDec
MRminh:    mov RMinl,9

           cmp RMinh,0
           jz MRhour
           dec RMinh
           jmp EndRDec
MRHour:    mov RMinh,5
           cmp RHour,0
           jz EndRDec
           dec RHour
           jmp EndRDec
     rd1:  or OutPort0,RBEEP
           mov al,OutPort0
           out OUTPORT,al
           mov al,0
EndRDec:   or RHour,128
           or RMinL,128
           call ROut
           push ax
           mov al,DECCOUNT
RDecPause: inc al
           dec al
           push ax
           pop ax
           push ax
           pop ax
           dec al
           jnz RDecPause
           pop ax
           ret
RDec       ENDP

ROut       proc near
           push ax
           push bx
           push dx
           mov ax,ds
           push es
           pop ds
           mov es,ax
           lea bx,Image
           mov al,es:[Rhour]
           mov ah,al
           and al,0fh
           and ah,0f0h
           xlat
           or al,ah
           out IRHOUR,al
           mov al,es:[RMinH]
           mov ah,al
           and al,0fh
           and ah,0f0h
           xlat
           or al,ah
           out IRMINH,al
           mov al,es:[RMinL]
           mov ah,al
           and al,0fh
           and ah,0f0h
           xlat
           or al,ah
           out IRMINL,al
           mov al,es:[RSecH]
           mov ah,al
           and al,0fh
           and ah,0f0h
           xlat
           or al,ah
           out IRSECH,al
           mov al,es:[RSecL]
           mov ah,al
           and al,0fh
           and ah,0f0h
           xlat
           or al,ah
           out IRSECL,al
           mov ax,ds
           push es
           pop ds
           mov es,ax
           pop dx
           pop bx
           pop ax
           ret
ROut       endp

PRmode     proc near
           push bx
           push cx
mov al,Rhour_
mov Rhour,al
mov al,Rminh_
mov Rminh,al
mov al,Rminl_
mov Rminl,al
mov al,Rsech_
mov Rsech,al
mov al,Rsecl_
mov Rsecl,al


           lea bx,RHour
           and RHour,0fh
           and RMinL,0fh
           mov al,[bx]
           or al,128
           mov [bx],al
           call ROut

           mov cl,10
           xor ch,ch
     prm1: call GetKey
           cmp ah,RSET
           jz  prm2
           cmp ah,RMODE
           jz prm11

           jmp prm1
    prm11:
           mov al,[bx]
           and al,0fh
           mov [bx],al
           inc bx
           mov al,[bx]
           or al,128
           mov [bx],al
           call ROut

           inc ch
           cmp ch,5
           jz EndRmode

           cmp cl,10
           jz prm3
           mov cl,10
           jmp prm1
     prm3: mov cl,6
           jmp prm1
     prm2: mov al,[bx]
           inc al
           mov [bx],al
           mov ah,al
           and ah,0f0h
           and al,0fh
           sub al,cl
           jc prm4
           xor al,al
           or al,ah
           mov [bx],al
     prm4: call ROut
           jmp prm1
 EndRmode: or RHour,128
           or RMinL,128
           call ROut
mov al,Rhour
mov Rhour_,al
mov al,Rminh
mov Rminh_,al
mov al,Rminl
mov Rminl_,al
mov al,Rsech
mov Rsech_,al
mov al,Rsecl
mov Rsecl_,al

           pop cx
           pop bx
           ret
PRmode     endp
;------------------------------
Beep_      proc near
           push ax
           cmp Count,0
           jnz b11
           mov Count,0ffh
           mov al,outport0
           and al,11111100b
           out OUTPORT,al
           jmp b21
b11:        mov Count,0
           mov al,outport0
           out OUTPORT,al
b21:        pop ax                                          
           ret
Beep_      endp

;--------------------------------------

Start_     proc near   ;запуск времени
           push cx

           cmp ah,RSTOP
           jz RStart1
LStart1:   mov cl,58
Lstart:    call GetKey
           cmp ah,RSTOP
           jz Rstart1
           cmp ah,RESET
           jz send1
           call pause
           dec cl
           jnz Lstart
           mov cl,58
           call RDec
           cmp al,0
           jnz LStart
           jmp send

RStart1:   mov cl,58
RStart:    call GetKey
           cmp ah,LSTOP
           jz Lstart1
           cmp ah,RESET
           jz send1
           call pause
           dec cl
           jnz Rstart
           mov cl,58
           call LDec
           cmp al,0
           jnz Rstart
           jmp send
send1:     call Reset_
send:      mov al,0ffh           ;
           mov endtime,al        ;
           pop cx
           ret
Start_     endp

Reset_     proc near
           push ax
           mov al,Rhour_
           mov Rhour,al
           mov al,Rminh_
           mov Rminh,al
           mov al,Rminl_
           mov Rminl,al
           mov al,Rsech_
           mov Rsech,al
           mov al,Rsecl_
           mov Rsecl,al
           mov al,Lhour_
           mov LHour,al
           mov al,Lminh_
           mov Lminh,al
           mov al,Lminl_
           mov Lminl,al
           mov al,Lsech_
           mov Lsech,al
           mov al,Lsecl_
           mov Lsecl,al
           mov OutPort0,0
           mov al,0
           out OUTPORT,al
           mov endtime,al          ;
           call ROut
           Call LOut
           pop ax
           ret
Reset_     endp

Nul        proc near  
           mov Lhour_,0
           mov Lminh_,0
           mov Lminl_,0
           mov Lsech_,0
           mov Lsecl_,0
           mov Rhour_,0
           mov Rminh_,0
           mov Rminl_,0
           mov Rsech_,0
           mov Rsecl_,0
           mov OutPort0,0
           ret
nul      endp
;-----------------------------------------
Opros       proc near

opros:      cmp endtime,0
           jz mmmm1
           call Pause
           dec cl
           jnz opros
           call Beep_
           mov cl,59
           
mmmm1:     call GetKey
           cmp ah,LMODE
           jz mlm
           cmp ah,RMODE
           jz mrm
           cmp ah,LSTOP
           jz rsm
           cmp ah,RSTOP
           jz rsm
           cmp ah,RESET
           jz mres
           jmp opros
mlm:       cmp endtime,0     
           jnz opros          
           call PLMode
           jmp opros
mrm:       cmp endtime,0     
           jnz opros         
           call PRMode
           jmp opros
rsm:       cmp endtime,0     
           jnz opros         
           call Start_
           jmp opros
mres:      call Reset_
           jmp opros
           ret
Opros      endp           
;----------------------------------
Start:

           mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
          
           call Nul
           call Reset_
main:         
           call GetKey
           call Opros
           jmp main

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
