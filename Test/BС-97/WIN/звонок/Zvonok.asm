PortI1      equ 0
PortI2      equ 1
PortO1      equ 2
PortO2      equ 3
PortO3      equ 4
PortO4      equ 5
PortO5      equ 6
PortO6      equ 7
PortMI      equ 10
PortOM      equ 11
PortZv      equ 12
MaxInputTime equ 15000

stak1 segment stack
  dw 5H dup (?)
  StkTop label word
stak1 ends

data segment at 00baH

     next        db ?
     prior       db ? 
     BuffAddr    dw ?
     zvonok      db ?
     ArrSign     dw 30 dup (?) 
     BuffData    dw ?
     Work        db ?
     InClock     db ?
     OldClock    db ?  
     InSign      db ?
     RealScale   db ?
     Clear       db ? 
     EmpKbd      db ?
     ErrInp      db ?
     NextDig     db ?
     TimeUY      db ? 
     Extr        db ?
     OldBuffAddr dw ? 
     NextBuffAddr dw ?
     GameOver    db ?
     BegOver     db ?
     ClearFild   db ? 
     BegTime     dw ?
;     zvonok      db ?
     DataDisp    db 4  dup (?)
     msec        db ?
     BuffAddrq   dw ?
     KbdImage    db 2 dup (?)
     DispPort    dw ?
     sec          db ? 
     min          db ? 
     hour         db ?
     Map         db 0AH dup (?)
data ends 


code segment
assume cs:code,ds:data,ss:stak1

FuncPrep Proc Near
       mov BuffAddr,0
       mov BuffAddrq,0
       mov Zvonok,00h
       mov work,00h
       mov InClock,00h
       mov InSign,0FFh
       mov RealScale,0FFH
       mov ErrInp,00h
       mov EmpKbd,00h
       mov min,00h
       mov hour,00h
       mov Next,00h
       mov Prior,00h
       mov Extr,00h 
       mov msec,26
       mov ClearFild,00h
       mov DataDisp[0],0ah
       mov DataDisp[1],0ah
       mov DataDisp[2],0ah       
       mov DataDisp[3],0ah
       mov OldClock,00h
       mov BuffData,0aaaah
       mov cx,30
       mov si,0
Fp1:   mov ArrSign[si],0aaaah
       inc si
       
       inc si
       loop FP1  
    ;   mov ArrSign[2],23h

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
       mov Map[10],40h  
       ret
funcPrep Endp

ErrInpTime Proc Near
       mov  al,73h
       Out  2,al
       mov  al,60h
       out  3,al
       out  4,al
       mov  al,00h
       out  5,al
       mov si,0ah
a1:    mov  cx,0ffffh
EIT2:  loop EIT2 
       dec si
       cmp si,0
       jnz a1 
       mov ErrInp,00h 
EIT1:  Ret
ErrINpTime endp

AllInpTime Proc Near
       mov  al,073h
       Out  2,al
       mov  al,68h
       out  3,al
       mov  al,0fch
       out  4,al
       mov  al,00h
       out  5,al
       mov si,08h
a2:    mov cx,0ffffh
AIT2:  loop AIT2
       dec si
       cmp si,0
       jnz a2
       mov GameOver,00h 
AIT1:  Ret
AllInpTime endp

begInpTime Proc Near
;       cmp  BegOver,0ffh
;       jnz  BIT1
       mov  al,07fh
       Out  2,al
       mov  al,73h
       out  3,al
       mov  al,0bbh
       out  4,al
       mov  al,00h
       out  5,al
       mov si,0ah
a3:    mov cx,1fffh
BIT2:  loop AIT2
       dec si
       cmp si,0
       jnz a3
 ;      mov BegOver,00h 
BIT1:  Ret
begInpTime endp

KeyContr Proc Near 
       mov ah,al
       mov bx,0
KC2:   in al,dx     
       cmp ah,al
       jnz Kc1
       jmp kc2
       nop 
       nop
       nop
       inc bx
       cmp bx,MaxInputTime
       jnz KC2
KC1:   mov al,ah
       ret
KeyContr Endp


InputMode Proc Near
       mov Next,00h
       mov Prior,00h 
       mov Clear,00h
       in  al,09
       and al,0ffh
       jz MI6
       mov dx,9
       call KeyContr
       test al, 01h
       jz MI1
       mov Work,0ffh
       mov InClock,00h
       mov InSign, 00h
       jmp MI6
MI1:   test al,02h
       jz MI2
       mov Work,00h
       mov InClock,0ffh
       mov OldClock,0ffh
       mov InSign,00h
       jmp MI6
MI2:   test al,04h
       jz MI3
       mov Work,00h
       mov InClock,00h
       mov InSign, 0ffh
       jmp MI6
MI3:   test al,08h
       jz MI4
       mov RealScale,0ffh
       jmp Mi6
MI4:   test al,10h
       jz MI5
       mov RealScale,00h
       jmp Mi6
MI5:   test al,20h
       jz Mi7
       mov Next,0ffh
       jmp Mi6
MI7:   test al,40h
       jz MI8    
       mov Prior,0ffh
       jmp MI6
MI8:   test al,80h
       jz MI6
       mov Clear,0ffh
Mi6:   Ret
InputMOde Endp


ModeOut Proc near
       mov al,01h
       cmp Work,0ffh
       jz  ITMO1
       mov al,02h
       cmp InClock,0ffh
       jz  ITMO1
       mov al,04h
       cmp InSign,0ffh
ITMO1: mov ah,20h 
       cmp RealScale,00h
       jz ITMO2
       mov ah,10h
ITMO2: or al,ah
       out 7,al
       ret
ModeOut  endp

KbdInput Proc near
        mov al,Work
        test al,0ffh
        jnz KI1
        lea si,KbdImage
        in  al,PortI1
        and al,1fh
        jz KI2
        mov dx,PortI1
        Call KeyContr
Ki2:    mov [si],al
        inc si
        in al,PortI2
        and al,1fh
        jz KI3
        mov dx,PortI2
        Call KeyContr        
Ki3:    mov [si],al
Ki1:    ret
KbdInput endp

KbdInContr Proc Near
        cmp Work,0ffh
        jz KIC1
        lea bx,KbdImage
        mov EmpKbd,00h
        mov al,[bx]
        inc bx
        mov ah,[bx]
        and ax,0ffffh
        jnz KIC1
KIC2:   mov EmpKbd,0ffh
KIC1: 
        ret                                      
KbdInContr endp
 
NextDigTrf Proc Near
        cmp EmpKbd,0ffh
        jz NDT1
        cmp Work,0ffh
        jz NDT1
        cmp Next,0ffh  
        jz NDT1
        cmp Prior,0ffh
        jz  NDT1
        lea si,KbdImage
        Mov cx,0
        mov al,[si] 
        and al,1fh
        jnz NDT2
        inc si
        mov cx,5
        mov al,[si]
NDT2:   shr al,1
        jc NDT3
        inc cx
        jmp NDT2
NDT3:   
        mov NextDig,cl
NDT1:   ret
NextDigTrf endp

Corect Proc near
        cmp dx,0aaaah
        jz CRQ
        cmp dh,23h
        ja Cr1 
        cmp dl,59h
        ja Cr1
        jmp Cr
CRq:    mov ClearFild,0ffh
        jmp CrO        
Cr1:    mov ErrInp,0ffh
        jmp CrO

Cr:     mov ErrInp,00h
CrO:    ret
Corect endp

preobr proc near  
       mov al,ch
       and al,0f0h
       shr al,4
       mov bx,10
       mul bx
       and ch,0fh
       add al,ch
       mov ch,al
       mov al,cl
       and al,0f0h
       shr al,4
       mul bx
       and cl,0fh
       add al,cl
       mov ah,ch
       ret
preobr  endp

Repreobr proc near
            cmp dx,0aaaah
            jz REp1
            mov al,dh
            aam
            shl ah,4
            or al,ah
            mov bh,al
            mov al,dl
            aam
            shl ah,4
            or al,ah
            mov bl,al
            jmp RePq
ReP1:       mov bx,0aaaah            
REPq:        ret      
Repreobr endp

DispInfoForm Proc Near
       cmp Work,0ffh
       jz DIF1
       mov cx,4
       mov si,0
       mov dx,BuffData
DIF3:  mov al,dl
       and al,0fh
       mov DataDisp[si],al
       shr dx,4
       inc si
       loop  DIF3
       jmp DIf1
DIF1:  ret                 
DispInfoForm endp

ExtractMas Proc Near
       cmp work,0ffh
       jnz EM6
       cmp Extr,0ffh
       jnz EM3  
       mov oldBuffAddr,2 
EM5:   mov bx,2
EM2:   cmp bx,0
       jz EM5
       cmp bx,60
       jz  EM3
       mov ax,ArrSign[bx]
       cmp ax,0aaaah
       jnz EM1
       mov bx,oldBuffAddr 
       inc bx 
       inc bx 
       mov oldBuffAddr,bx 
       jmp EM2
EM1:   mov si,bx
       dec si
       dec si 
       cmp ArrSign[si],0aaaah
       jnz EM4
       mov dx,ArrSign[bx]
       mov cx,ArrSign[si]
       mov ArrSign[si],dx
       mov Buffaddr,bx
       mov ArrSign[bx],cx
       mov bx,si
       jmp em2
EM4:   INC bx 
       INC bx 
       jmp EM2
EM3:   mov Extr,00h 
EM6:   ret
ExtractMas endp
        
InfoForm Proc Near
        cmp Clear,0ffh
        jz MC1
        cmp InSign,0ffh
        jnz  MET1 
        mov Extr,0ffh
        cmp Next,0ffh
        jz MN1
        cmp Prior,0ffh
        jz MP1
MET1:   cmp OldClock,0ffh
        jnz m1
        cmp InClock,00h
        jz  MTime
m1:     cmp Work,0ffh
        jz    ESS1
        cmp EmpKbd,0ffh
        jz    ESS1
        mov dx,BuffData
        shl dx,4
        mov al,NextDig
        And al,0fh
        or  dl,al
        mov BuffData,dx   
        jmp ESS1
MC1:    jmp MClear        
MN1:    jmp MNext
MP1:    jmp MPrior      
MTime:  mov dx,BuffData
        call Corect
        cmp ErrInp,0ffh
        jnz EEQ
        call ErrInpTime
        mov Work,00h
        mov InClock,0ffh
        mov inSign,00h
Ess1:   jmp Ess2 
EEQ:    cmp dx,0aaaah
        jz EssT
        mov cx,dx
        call preobr
        mov min,al
        mov hour,ah
EssT:   mov BuffData,0aaaah
        mov OldClock,00h
        jmp ESS2
MNext:  mov dx,BuffData
        mov ax,dx
        call Corect
        cmp ClearFild,0ffh
        jz CLF1
        cmp ErrInp,0ffh
        jnz EEq1
        call ErrInpTime
       ; mov  next,00h
        jmp Ess2
EEq1:   mov cx,BuffData
        call Preobr
CLF1:   mov si,BuffAddr
        mov ArrSign[si],ax
        cmp si,60;59d;3BH
        jz  ENE 
        mov si,Buffaddr
        mov ax,si 
        out 0,al
        inc si
        inc si 
        inc BuffAddrq  
        mov BuffAddr,si
        mov dx,ArrSign[si]
        call Repreobr
        mov BuffData,bx
        mov ClearFild,00h
        jmp ESS
ENE:   call AllInpTime
        mov Next,00h 
        mov ClearFild,00h               
Ess2:   jmp ESS 
        
MPrior: mov dx,BuffData
        mov ax,dx
        call Corect
        cmp ClearFild,0ffh
        jz CLF2
        cmp ErrInp,0ffh
        jnz EQ2
        call ErrInpTime
        mov  Prior,00h
        jmp ESS
EQ2:    mov cx,BuffData
        call Preobr
CLF2:   mov si,BuffAddr
        mov ArrSign[si],ax
        cmp si,0
        jz EPE
        mov si,BuffAddr 
        dec si
        dec si
        Dec Buffaddrq
        mov ax,SI
        out 1,al
        mov BuffAddr,si
        mov dx,ArrSign[si]
        call Repreobr              
        mov BuffData,bx
        mov ClearFild,00h
        jmp ESS
EPE:    call begInpTime

EP:     jmp ESS 
     
MClear: mov si,BuffAddr
        mov ArrSign[si],0aaaah
        mov BuffData,0aaaah
        mov Extr,0ffh
ESS:    ret        
InfoForm endp

OutNumInf Proc Near          
        cmp GameOver,0ffh
        jz ONI1
        cmp ErrInp,0ffh
        jz ONI1 
        lea si,DataDisp
        mov dx,5
        mov cx,4
        lea bx,Map
ONI2:   mov al,[si]
        xlat 
        out dx,al
        inc si
        dec dx
        loop ONI2
ONI1:   ret
OutNumInf endp

SecGone Proc Near
       cmp Work,0ffh
       jz  sg4
       cmp RealScale,00h
       jne sg5
       mov dx,01fh
       jmp sg
sg5:   mov dx,00fffh
       jmp sg  
Sg4:   cmp RealScale,00h
       jne sg2
       mov dx,01fh
       jmp sg
sg2:   mov dx,01dffh
sg:    cmp  dx,0
       je sg1  
       dec dx
       jmp sg
sg1:   ret
SecGone Endp

chek proc near
      cmp work,0ffh
      jnz Ch1   
      mov si,0
CH2:  mov ax,arrSign[si]
      mov dl,min
      mov dh,hour
      cmp dl,al
      jnz CH3
      cmp dh,ah
      jnz ch3
      mov Zvonok,0ffh
ch3:  inc si
      inc si
      cmp si,60
      jnz Ch2
ch1:  ret  
chek endp

TimefORM PROC NEAR
Tf8:  cmp msec,0 
      jz TF9 
      call SecGone
      jz TFq
Tf9:  mov msec,26
      cmp sec,59d
      je TF1
      inc sec
      jmp TFq 
TF1:  mov sec,0
      inc min
TF2:  cmp min,60d
      je Tf4   
      jmp Tf5 
Tf4:  mov min,0
      inc hour
TF5:  cmp hour,24
      je TF6
      jmp TF7
TF6:  mov hour,0
Tf7:  call Chek 
Tfq:  dec msec
      ret
TimeForm endp

Vivod Proc Near
        cmp Work,0ffh
        jnz VD1
        mov si,0
        mov al,min
        aam
        mov DataDisp[si],al
        inc si
        mov DataDisp[si],ah 
        inc si
        mov al,Hour
        aam
        mov DataDisp[si],al
        inc si
        mov DataDisp[si],ah
       
VD1:     ret
Vivod Endp

Zvonoks  Proc Near
       cmp Work,0ffh
       jnz zp
       cmp zvonok,0ffh
       jne zp1
       cmp sec,20d
       ja zp1
       mov al,0ffh
       out 8,al
       jmp zp
zp1:   mov zvonok,00h    
       mov al,0h 
       out 8,al 
zp:    ret
Zvonoks Endp

       
       
 Start:
       mov ax,data
       mov ds,ax

       mov ax,stak1
       mov ss,ax       
       mov sp,offset StkTop 

        call FuncPrep
begin:  
        call InputMode
        call ModeOut
        call KbdInput
        call KbdInContr
        call NextDigTrf
        call InfoForm
        call ExtractMas 
        call DispInfoForm
        call Vivod 
        call TimeForm
        call Zvonoks 
        call OutNumInf
        jmp begin
              

           jmp  Start

           org  0FF0h
           assume cs:nothing
           jmp  Far Ptr Start
Code       ends
end