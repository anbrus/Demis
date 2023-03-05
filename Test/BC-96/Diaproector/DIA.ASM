;====== CONST =================================================================

DiaPort         EQU     0       ; input ports
LedPort         EQU     1
DispPortHi      EQU     2
DispPortLo      EQU     3

KeyPort         EQU     1	; output ports
KbdPort1        EQU     2
KbdPort2        EQU     3

MaxSlide	EQU	50	; Last slide number

KeyDelay	EQU	100	; Delay after keypress
TimeQuant	EQU	100	; 1 unit of time delay when slide showing
pulse		EQU	30	; Delay of diaproector "mechanics"

;====== DATA =================================================================
data    SEGMENT at 0BA00H

	NextDig		db	?	; Next number

	InpData		db	?	; Entered number

	TaskTime	db	?	; Defined exposure delay 
	TaskNum		db	?	; Defined number of slide to show

	RandNum		db	?	; Random number
	CurrNum		db	?	; Current slide

	FEmpKbd		db	?	; No keystrokes
	FError		db	?	; Error occurs
	FEnter		db	?	; Enter pressed
	FShowInp	db	?	; Show input
	FInpTime	db	?	; Time entering mode
	FInpNum		db	?	; Slide entering mode
	FShowRand	db	?	; Random slide mode
	FShowCurr	db	?	; Current slide showing

	FStop		db 	?	; Stop sign while moving
	FAutoMove	db	?	; Automatic cartridge move
	FNumMove	db	?	; Moving to specified number
	MoveMode	db	?	; Auto move direction
	
	DataDisp	dw 	?  	; Displayed slide num
	
	KbdImage	dw	?	; Keyboard state

;--------- System data ------------
	digimap		db 	10 dup (?)	; Numbers for 7-seg indicators

	dia_inport	db	?	; We cannot handle diaproector
	dia_outport	db	?	; as an outer device, so the i/o
					; ports emulated by memory cells
	cartr_pos	db	?	; Diaproector's internal data	
	cartr_mvdir	db	?
	slide 		db	?

	random_addr	dw 	?
	rand_seed	dw	?

data 	ENDS


;====== STACK ================================================================
stk   SEGMENT at 0BA80H       
        dw      50H dup (?)    
        StkTop  label   word    
stk   ENDS                    
                                


;====== CODE =================================================================
code    SEGMENT
        ASSUME cs:code, ds:data, ss:stk


diaproector PROC
	push ax
	mov al, cartr_mvdir	; Is diaproector already working?
	cmp al, 0		; Stay
	je testinput

	mov ah, cartr_pos	; Diaproector is working
	cmp ah, pulse		; Is slide reached?
	jb move_cartr

	mov cartr_pos, 0 	; if yes, take next slide
	add slide, al
	mov cartr_mvdir, 0
	mov al, 01h		; Slide ready
	jmp Dout

move_cartr: inc cartr_pos	; if no, shift cartridge more
	mov al, 00h		; No events
	jmp Dout

testinput: mov al,dia_inport	; Get input. We cannot handle proector
				; as outer device, so i/o port emulated by
				; memory cell.	
Dright:	test al,01h
	jz Dleft		
	
	mov al, slide
	cmp al, MaxSlide	; Check for end of cartridge
	jb Ddo_right

	mov al, 01h		; End of cartridge
	jmp Dout

Ddo_right: mov cartr_mvdir, 01h	; Move cartridge right
	mov al, 00h	
 	jmp Dout

Dleft:	test al,02h		; Left key
	mov al, 01h
	jz Dout

	mov al, slide
	cmp al, 0
	ja Ddo_left

	mov al, 01h
	jmp Dout

Ddo_left: mov cartr_mvdir, 0FFh	; Move cartridge left
	mov al, 00h
	jmp Dout

Dout:	mov ah, dia_inport
	shl ah, 6
	or al, ah 		; Incoming signals

	mov ah, slide
	cmp ah, 0
	je eoc
chk_max: cmp ah, MaxSlide
	jne dia_out
eoc:	mov ah, cartr_mvdir
	cmp ah, 00h
	jne dia_out
	or al, 02h		; End of cartridge

dia_out: mov dia_outport,al
	out DiaPort,al
	pop ax
	ret
diaproector ENDP


;------ Show slide number or Er -----------------------------------------------------
VarInit PROC
       	mov bx,offset digimap	; Initialize map for 7-segs
       	mov digimap[0], 3FH
       	mov digimap[1], 0CH
       	mov digimap[2], 76H
       	mov digimap[3], 05EH
       	mov digimap[4], 4DH
       	mov digimap[5], 5BH
       	mov digimap[6], 7BH
       	mov digimap[7], 0EH
       	mov digimap[8], 7FH
       	mov digimap[9], 5FH

	mov al, 0FFh		; Clear output signals
	out LedPort, al
	mov al, 00h
	out LedPort, al

	mov DataDisp, 00h	; Program variables
	mov FError, 00h
	mov FShowCurr, 0FFh
	mov FStop, 0h
	mov dia_outport, 00h
	mov dia_inport, 00h
	mov MoveMode, 0
	call diaproector
	mov TaskTime, 5
VarInit ENDP


;------ Show End of cartridge sign ------------------------------------------------
IndEndCas PROC
	mov al, dia_outport
	test al, 02h
	jz indoff

	mov al, 01h
	out LedPort, al
	ret

indoff:	mov al, 00h
	out LedPort, al
	ret
IndEndCas ENDP


;------ Move cartridge left until EOC occurs ---------------------------------------------
ChangeCas PROC
	in al, KeyPort
	test al, 01h		; Reset key
	jz change_end

	  mov dia_inport, 02h	; Move left
change_loop:	call diaproector
	mov al, dia_outport
	test al, 02h		; EOC
	jz change_loop
      	  mov dia_inport, 00h	; Stay
      	  call diaproector
	mov CurrNum, 0

change_end: ret
ChangeCas ENDP


;------ Move cartridge left and right by keys ---------------------------------------------
HandShow PROC
	in al, KeyPort
	test al, 20h		; Auto switch
	jnz hand_end
	
	test al, 02h		; Right
	jz hand_left
	mov MoveMode, 1		; Move right
	jmp hand_start

hand_left: test al, 04h		; Left
	jz hand_stay
	mov MoveMode, 2		; Move left
	jmp hand_start

hand_start: mov FAutoMove, 0h
	mov FShowCurr, 0FFh
	mov FInpTime, 0h
	mov FInpNum, 0h
	ret

hand_stay: mov MoveMode, 0
hand_end: ret
HandShow ENDP


;------ Automatic cartridge move ---------------------------------------------
AutoShow PROC
	in al, KeyPort
	test al, 20h		; Auto switch
	jz auto_end

auto_right: test al, 02h	; Right
	jz auto_left
	mov MoveMode, 1		; move direction now "right"
	jmp auto_start

auto_left: test al, 04h
	jz auto_end
	mov MoveMode, 2

auto_start: mov FAutoMove, 0FFh
	mov FShowCurr, 0FFh
	mov FInpTime, 0h
	mov FInpNum, 0h

auto_end: ret		
AutoShow ENDP


;------ Automatic cartridge move ---------------------------------------------
random  PROC
	push bx
	push cx
	mov bx,random_addr
	mov cx,rand_seed
get_rnd: mov ax,cs:[bx]
	add bx,0010h
	xor bx,ax
 	xor bx,cx
	inc cx
	and bx,00FFh
	mov random_addr,bx
	mov ax,bx
	cmp al,MaxSlide
	ja get_rnd
	cmp al,CurrNum
	je get_rnd
	mov rand_seed,cx
	pop cx
	pop bx
	ret
random ENDP

Randomize PROC
	in al, KeyPort
	test al, 10h
	jz rnd_end

	call random
	mov RandNum, al
	mov FShowRand, 0FFh
rnd_end: ret
Randomize ENDP

;------ Read keyboard and return image ---------------------------------------
KbdInp PROC
	in al, KbdPort2		; Form image in ax
	mov ah, al
	in al, KbdPort1

	mov KbdImage, ax
	ret
KbdInp ENDP

;------ Analyse Kbd image and form flags -------------------------------------
ContrKbdInp PROC
	mov FEmpKbd, 0		; Preset defaults
	mov FError, 0

	mov ax, KbdImage
	test ax, 07FFh		; Check 11 bits
	jnz tst_err
	mov FEmpKbd, 0FFh
	ret

tst_err: mov cx, KeyDelay	; Key pressed, so make pause
tst_pause: loop tst_pause 
	
	mov bx, 0001h		; Key mask
	mov cx, 11		; Amount of keys
	mov dx, 0		; Pressed counter
tst_loop: test ax, bx		; Check key
	jz tst_lcont
	inc dx			; Count pressed
tst_lcont: shl bx, 1		; Next key
	loop tst_loop
	cmp dx,1		; One key must be pressed at same time
	jna tst_end
	mov FError, 0FFh
tst_end: ret
ContrKbdInp ENDP


;------ Look for pressed keys and their meaning ------------------------------
NxtDigTrf PROC
	mov FEnter, 0		; Preset defaults
	mov NextDig, 0

	cmp FEmpKbd, 0		; No actions if no keypresses
	jne ndt_end
	cmp FError, 0		; And if errors
	jne ndt_end

	mov ax, KbdImage
	test ax, 400h
	jz keys
	mov FEnter, 0FFh
	ret

keys:	mov bx, 01h		; Mask
	mov cl, 0		; Key value
k_loop: test ax, bx
	jnz k_found
	shl bx, 1
	inc cl
	cmp cl, 10
	jna k_loop
k_found: mov NextDig, cl

ndt_end: ret
NxtDigTrf ENDP

;------ Make input data for displaying ---------------------------------------
DataForm PROC
	cmp FEmpKbd, 0		; Return if no keys queued
	jne df_end
	cmp FError, 0
	jne df_end
	cmp FEnter, 0
	jne df_end
	
	mov FShowInp, 0		; Predefine flag

	mov ax, DataDisp	; Shift displayed data left
	mov ah, al
	mov al, NextDig		; And add new digit
	aad
	mov InpData, al
	mov FShowInp, 0FFh

df_end:	ret
DataForm ENDP

;----- Control number of slide to stay in bounds -----------------------------
ContrNumSlide PROC
	cmp FEnter, 0		; Control when Ent pressed
	je cn_end
	cmp FInpNum, 0		; And user enters number
	je cn_end

	mov FError, 0		; Predefine flag
	cmp InpData, MaxSlide	; Error if number above MaxSlide
	jna cn_end
	mov FError, 0FFh
		
cn_end:	ret
ContrNumSlide ENDP

;------ Summarize and rechannel keyboard input -------------------------------
DataFix PROC
	cmp FError, 0		; No actions if error
	je dfx_cont
	ret
	
dfx_cont: in al, KeyPort
	test al, 40h		; entering delay
	jz dfx_num
	mov FShowInp, 0FFh
	mov FShowCurr, 0h
	mov FInpTime, 0FFh
	mov al, TaskTime 	; Recall stored delay
	mov InpData, al
	mov FInpNum, 0
	ret

dfx_num: test al, 80h
	jz dfx_ent
	mov FShowInp, 0FFh	; entering number
	mov FShowCurr, 0h
	mov FInpNum, 0FFh
	mov al, TaskNum
	mov InpData, al		; Default number - 0
	mov FInpTime, 0
	ret 

dfx_ent: cmp FEnter, 0
	je dfx_end
	cmp FInpTime, 0
	je ent_num
	mov al, InpData		; Entering time ended
	mov TaskTime, al
	mov FInpTime, 0		
	mov FShowInp, 0		; Restore normal display mode
	mov FShowCurr, 0FFh
	ret

ent_num: mov al, InpData	; Entering number ended
	mov TaskNum, al		; Remember new number
	mov FShowInp, 0
	mov FShowCurr, 0FFh
	mov FNumMove, 0FFh
	
dfx_end: ret
DataFix ENDP


;------ Show specified data on display ---------------------------------------------
FormDDisp PROC
dd_curr: cmp FShowCurr, 0
	je dd_inp
	mov al, CurrNum
	aam
	mov DataDisp, ax
	ret

dd_inp:	cmp FShowInp, 0
	je dd_end
	mov al, InpData
	aam
	mov DataDisp, ax

dd_end:	ret
FormDDisp ENDP

;------ Show slide number or Er -----------------------------------------------------
OutDDisp PROC
	mov al, FError		; If FError, show "Er"
	cmp al, 00h
	je shownumbers	
	
	mov al, 73h		; E
	out DispPortHi, al
	mov al, 60h		; r
	out DispPortLo, al
	ret

shownumbers:	mov ax, DataDisp	; else, show DataDisp
	mov bx, offset digimap
	xlat
	out DispPortLo, al
	mov al,ah
	xlat
	out DispPortHi, al
        ret
OutDDisp ENDP


;------ Move to specified slide ----------------------------------------------
ShowSlide PROC
	cmp FError, 0		; No actions if error
	je ss_do
	mov FNumMove, 0
	ret

ss_do:	cmp FShowRand, 0	; Show random slide?
	je ss_num

	cmp FStop, 0		; Stopped?
	je ss_rnd
	mov FStop, 0
	mov MoveMode,0
	mov FShowRand,0
	ret

ss_rnd:	mov al, CurrNum		; Move to random slide
	cmp al, RandNum
	jne ss_right
	mov FShowRand, 0
	mov MoveMode, 0
	ret

ss_num: cmp FNumMove, 0		; If movint towards number 
	je ss_end
	
	mov al, CurrNum		; Move to specified slide
	cmp al, TaskNum
	jne ss_right
	mov FNumMove, 0
	mov MoveMode, 0
	ret

ss_right: ja ss_left
	mov MoveMode,1
	jmp ss_end
ss_left: mov MoveMode,2
	jmp ss_end

ss_end:	ret
ShowSlide ENDP


;------ Move according to current mode ---------------------------------------
Mode PROC
	mov al, MoveMode
	cmp al, 1
	jne doleft
	mov dia_inport, 01h
	cmp CurrNum, MaxSlide
	jnb move
	inc CurrNum
	jmp move

doleft:	cmp al, 2
	jne mode_end
	mov dia_inport, 02h
	cmp CurrNum, 0
	jna move
	dec CurrNum

move: 	mov FStop, 0
mv_loop: call diaproector
	in al, KeyPort		; Check for Stop key while moving
	test al, 08h
	jz contmove
	mov FStop, 0FFh		; Store keypress in buffer
contmove: test dia_outport,01h
	jz mv_loop
	mov dia_inport, 00h
	call diaproector

	cmp FStop, 0		; Stay mode if stopped
	je do_delay
	mov MoveMode, 0
	mov FAutoMove, 0
	mov FNumMove, 0

do_delay: cmp FAutoMove, 0	; Daly to show slide
	je mode_end

	mov cl, TaskTime	; make delay
	mov ch, 0
mv_m1:	mov dx, TimeQuant
mv_m2:  dec dx
	in al, KeyPort		; Check for Stop key while moving
	test al, 08h
	jz mv_cont
	mov FStop, 0FFh		; Store keypress in buffer
	mov MoveMode, 0
	mov FAutoMove, 0
	ret
mv_cont: cmp dx, 0
	ja mv_m2
	cmp cx, 0
	je mode_end
	dec cx
	jmp mv_m1

mode_end: ret
Mode ENDP



;------ main -----------------------------------------------------------------
begin:
        mov ax,data             ; Segs initialisation
        mov ds,ax               
        mov ax,stk
        mov ss,ax               
        mov sp,offset StkTop    
	mov al,0
	out 1,al

	call VarInit
mainloop:
	call ChangeCas
	call HandShow
	call AutoShow
	call Randomize
	call KbdInp
	call ContrKbdInp
	call NxtDigTrf
	call DataForm
	call DataFix
	call ContrNumSlide
	call FormDDisp
	call OutDDisp
	call ShowSlide
	call Mode
	call IndEndCas
        jmp mainloop		; Start cycle again

       org 07F0H                
start: jmp begin                

code    ENDS                    ; there is no more code segment...

        END     start           
                                
