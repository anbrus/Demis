                   title    Calculator 2.0 Beta (C) A.V. Ivanov
                   page     80, 160
                   jumps
                   locals   @@
                   .model   small
                   .8086

CONFIG_EXPLEN      equ      4; // must be 4
CONFIG_FRQLEN      equ      14; // must be 14

PRT_DGT            equ      00
PRT_FLG            equ      14
PRT_KB             equ      15

FLG_SIGN           equ      0001h
FLG_OVRF           equ      0004h
FLG_MEM1           equ      0008h
FLG_MEM2           equ      0010h
FLG_FTX0           equ      0020h
FLG_FTX2           equ      0040h
FLG_FTX5           equ      0080h
FLG_ASTR           equ      0100h
FLG_AOP1           equ      0200h
FLG_AOP2           equ      0400h

FMT_XX             equ      2*CONFIG_FRQLEN
FMT_X0             equ      0
FMT_X2             equ      2
FMT_X5             equ      5

KEY_END            equ      0000
KEY_0              equ      0100
KEY_1              equ      0101
KEY_2              equ      0102
KEY_3              equ      0103
KEY_4              equ      0104
KEY_5              equ      0105
KEY_6              equ      0106
KEY_7              equ      0107
KEY_8              equ      0108
KEY_9              equ      0109
KEY_PNT            equ      0110
KEY_DEL            equ      0111
KEY_CLR            equ      0112
KEY_SGN            equ      0113
KEY_EQU            equ      0200
KEY_ADD            equ      0201
KEY_SUB            equ      0202
KEY_MUL            equ      0203
KEY_DIV            equ      0204
KEY_POW            equ      0205
KEY_SIN            equ      0300
KEY_COS            equ      0301
KEY_TAN            equ      0302
KEY_COT            equ      0303
KEY_EXP            equ      0304
KEY_LOG            equ      0305
KEY_ASN            equ      0306
KEY_ACS            equ      0307
KEY_ATG            equ      0308
KEY_ACT            equ      0309
KEY_FAC            equ      0310
KEY_FXX            equ      0400
KEY_FX0            equ      0401
KEY_FX2            equ      0402
KEY_FX5            equ      0403
KEY_M1             equ      0500
KEY_M2             equ      0501
KEY_MC             equ      0502
KEY_MS             equ      0503
KEY_MP             equ      0504
KEY_MR             equ      0505
KEY_CE             equ      0600

@Non               equ      0
@AcA               equ      1
@AcF               equ      2
@AcE               equ      3
@Op1               equ      4
@Op2               equ      5
@Mem               equ      6
@Img               equ      7

@EXPLEN            equ      CONFIG_EXPLEN+01
@FRQLEN            equ      CONFIG_FRQLEN+01

real               struc
exponent           db       @EXPLEN dup(?)
frequent           db       @FRQLEN dup(?)
real               ends

keyinfo            struc
keycode            dw       ?
outmask            db       ?
testmask           db       ?
keyinfo            ends

exeinfo            struc
keycode            dw       ?
opcount            dw       ?
flgoff1            dw       ?
flgon1             dw       ?
flgoff2            dw       ?
flgon2             dw       ?
execproc           dd       ?
addr1              dw       ?
addr2              dw       ?
param1             dw       ?
param2             dw       ?
value              dw       ?
exeinfo            ends

Data               segment  at 00000h
Key                dw       ?
Flags              dw       ?
Format             dw       ?
Last2Op            dw       ?
Op1                real     <?>
Op2                real     <?>
Mem1               real     <?>
Mem2               real     <?>
StrBuf             db       @FRQLEN+2 dup(?)
org 2048-2
StkTop             label    word
Data               ends

Code               segment
                   assume   cs:Code, ds:Data, es:Data, ss:Data


setxproc           proc
                   pushf
                   push     ax cx bp di ds
                   mov      bp, sp
@@disp             equ      2+05*2+04
@@Op0Addr          equ      [bp+@@disp+00]
@@OpLen            equ      [bp+@@disp+04]
@@Filler           equ      [bp+@@disp+06]
                   mov      cx, @@OpLen
                   mov      al, @@Filler
                   lds      di, @@Op0Addr
@@c:               mov      [di], al
                   inc      di
                   loop     @@c
                   pop      ds di bp cx ax
                   popf
                   retf     8
setxproc           endp

setx               macro    Op0Addr, OpLen, Filler
                   push     Filler
                   push     OpLen
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr setxproc
                   endm


movxproc           proc
                   pushf
                   push     ax cx bp di si ds es
                   mov      bp, sp
@@disp             equ      02+07*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@OpLen            equ      [bp+@@disp+08]
                   mov      cx, @@OpLen
                   lds      di, @@Op0Addr
                   les      si, @@Op1Addr
@@c:               mov      al, es:[si]
                   mov      [di], al
                   inc      si
                   inc      di
                   loop     @@c
                   pop      es ds si di bp cx ax
                   popf
                   retf     10
movxproc           endp

movx               macro    Op0Addr, Op1Addr, OpLen
                   push     OpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr movxproc
                   endm


sarxproc           proc
                   pushf
                   push     ax cx bp di ds
                   mov      bp, sp
@@disp             equ      02+05*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@OpLen            equ      [bp+@@disp+04]
                   mov      ah, 0
                   mov      cx, @@OpLen
                   sub      cx, 2
                   lds      di, @@Op0Addr
@@c:               mov      al, [di+1]
                   mov      [di], al
                   or       ah, al
                   inc      di
                   loop     @@c
                   mov      byte ptr [di], 0
                   cmp      ah, 0
                   jne      @@e
                   mov      byte ptr [di+1], 0
@@e:               pop      ds di bp cx ax
                   popf
                   retf     6
sarxproc           endp

sarx               macro    Op0Addr, OpLen
                   push     OpLen
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr sarxproc
                   endm


salxproc           proc
                   pushf
                   push     ax cx bp di ds
                   mov      bp, sp
@@disp             equ      02+05*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@OpLen            equ      [bp+@@disp+04]
                   mov      ah, 0
                   mov      cx, @@OpLen
                   sub      cx, 2
                   lds      di, @@Op0Addr
                   add      di, cx
@@c:               mov      al, [di-1]
                   mov      [di], al
                   or       ah, al
                   dec      di
                   loop     @@c
                   mov      byte ptr [di], 0
                   cmp      ah, 0
                   jne      @@e
                   add      di, @@OpLen
                   dec      di
                   mov      byte ptr [di], 0
@@e:               pop      ds di bp cx ax
                   popf
                   retf     6
salxproc           endp

salx               macro    Op0Addr, OpLen
                   push     OpLen
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr salxproc
                   endm


frmxproc           proc
                   pushf
                   push     ax cx bp di ds
                   mov      bp, sp
@@disp             equ      02+05*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@OpLen            equ      [bp+@@disp+04]
                   mov      cx, @@OpLen
                   dec      cx
                   lds      di, @@Op0Addr
                   add      di, cx
                   cmp      byte ptr [di], 0
                   je       @@e
                   sub      di, cx
                   clc
@@c:               mov      al, 0
                   sbb      al, [di]
                   pushf
                   jnc      @@n
                   add      al, 10
@@n:               mov      [di], al
                   inc      di
                   popf
                   loop     @@c
@@e:               pop      ds di bp cx ax
                   popf
                   retf     6
frmxproc           endp

frmx               macro    Op0Addr, OpLen
                   push     OpLen
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr frmxproc
                   endm


incxproc           proc
                   pushf
                   push     ax cx bp di ds
                   mov      bp, sp
@@disp             equ      02+05*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@OpLen            equ      [bp+@@disp+04]
                   frmx     @@Op0Addr, @@OpLen
                   mov      cx, @@OpLen
                   lds      di, @@Op0Addr
                   mov      ah, 9
                   stc
@@c:               mov      al, [di]
                   adc      al, 0
                   cmp      ah, al
                   pushf
                   jnc      @@n
                   add      al, 6
                   and      al, 0Fh
@@n:               mov      [di], al
                   inc      di
                   popf
                   loop     @@c
                   frmx     @@Op0Addr, @@OpLen
                   pop      ds di bp cx ax
                   popf
                   retf     6
incxproc           endp

incx               macro    Op0Addr, OpLen
                   push     OpLen
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr incxproc
                   endm


decxproc           proc
                   pushf
                   push     ax cx bp di ds
                   mov      bp, sp
@@disp             equ      02+05*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@OpLen            equ      [bp+@@disp+04]
                   frmx     @@Op0Addr, @@OpLen
                   mov      cx, @@OpLen
                   lds      di, @@Op0Addr
                   stc
@@c:               mov      al, [di]
                   sbb      al, 0
                   pushf
                   jnc      @@n
                   add      al, 10
@@n:               mov      [di], al
                   inc      di
                   popf
                   loop     @@c
                   frmx     @@Op0Addr, @@OpLen
                   pop      ds di bp cx ax
                   popf
                   retf     6
decxproc           endp

decx               macro    Op0Addr, OpLen
                   push     OpLen
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr decxproc
                   endm

addxproc           proc
                   pushf
                   push     ax cx bp si di
                   mov      bp, sp
@@disp             equ      02+05*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@OpLen            equ      [bp+@@disp+08]
                   sub      sp, 08
@@Op0CopyA         equ      [bp-08]
@@Op1CopyA         equ      [bp-04]
                   sub      sp, @@OpLen
                   mov      @@Op0CopyA[0], sp
                   mov      @@Op0CopyA[2], ss
                   movx     @@Op0CopyA, @@Op0Addr, @@OpLen
                   frmx     @@Op0CopyA, @@OpLen
                   sub      sp, @@OpLen
                   mov      @@Op1CopyA[0], sp
                   mov      @@Op1CopyA[2], ss
                   movx     @@Op1CopyA, @@Op1Addr, @@OpLen
                   frmx     @@Op1CopyA, @@OpLen
                   mov      cx, @@OpLen
                   mov      si, @@Op1CopyA[0]
                   mov      di, @@Op0CopyA[0]
                   mov      ah, 9
                   clc
@@c:               mov      al, ss:[di]
                   adc      al, ss:[si]
                   cmp      ah, al
                   pushf
                   jnc      @@n
                   add      al, 6
                   and      al, 0Fh
@@n:               mov      ss:[di], al
                   inc      di
                   inc      si
                   popf
                   loop     @@c
                   frmx     @@Op0CopyA, @@OpLen
                   movx     @@Op0Addr, @@Op0CopyA, @@OpLen
                   mov      sp, bp
                   pop      di si bp cx ax
                   popf
                   retf     10
addxproc           endp

addx               macro    Op0Addr, Op1Addr, OpLen
                   push     OpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr addxproc
                   endm


subxproc           proc
                   pushf
                   push     ax cx bp si di
                   mov      bp, sp
@@disp             equ      02+05*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@OpLen            equ      [bp+@@disp+08]
                   sub      sp, 08
@@Op0CopyA         equ      [bp-08]
@@Op1CopyA         equ      [bp-04]
                   sub      sp, @@OpLen
                   mov      @@Op0CopyA[0], sp
                   mov      @@Op0CopyA[2], ss
                   movx     @@Op0CopyA, @@Op0Addr, @@OpLen
                   frmx     @@Op0CopyA, @@OpLen
                   sub      sp, @@OpLen
                   mov      @@Op1CopyA[0], sp
                   mov      @@Op1CopyA[2], ss
                   movx     @@Op1CopyA, @@Op1Addr, @@OpLen
                   frmx     @@Op1CopyA, @@OpLen
                   mov      cx, @@OpLen
                   mov      si, @@Op1CopyA[0]
                   mov      di, @@Op0CopyA[0]
                   clc
@@c:               mov      al, ss:[di]
                   sbb      al, ss:[si]
                   pushf
                   jnc      @@n
                   add      al, 10
@@n:               mov      ss:[di], al
                   inc           di
                   inc      si
                   popf
                   loop     @@c
                   frmx     @@Op0CopyA, @@OpLen
                   movx     @@Op0Addr, @@Op0CopyA, @@OpLen
                   mov      sp, bp
                   pop      di si bp cx ax
                   popf
                   retf     10
subxproc           endp

subx               macro    Op0Addr, Op1Addr, OpLen
                   push     OpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr subxproc
                   endm


flgxproc           proc
                   push     ax cx bp di ds
                   mov      bp, sp
@@disp             equ      05*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@OpLen            equ      [bp+@@disp+04]
                   mov      cx, @@OpLen
                   lds      di, @@Op0Addr
                   mov      al, 0
@@c:               or       al, [di]
                   inc      di
                   loop     @@c
                   dec      di
                   cmp      al, 0
                   je       @@retZ
                   cmp      byte ptr [di], 0
                   jne      @@retC
                   mov      al, 1
                   add      al, al
                   jmp      @@e
@@retZ:            mov      al, 1
                   sub      al, al
                   jmp      @@e
@@retC:            mov      al, 130
                   add      al, 130
@@e:               pop      ds di bp cx ax
                   retf     6
flgxproc           endp

flgx               macro    Op0Addr, OpLen
                   push     OpLen
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr flgxproc
                   endm


mulxproc           proc
                   pushf
                   push     ax cx bp si di
                   mov      bp, sp
@@disp             equ      02+05*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@OpLen            equ      [bp+@@disp+08]
                   sub      sp, 12
@@ResCopyA         equ      [bp-12]
@@Op0CopyA         equ      [bp-08]
@@Op1CopyA         equ      [bp-04]
                   sub      sp, @@OpLen
                   mov      @@ResCopyA[0], sp
                   mov      @@ResCopyA[2], ss
                   setx     @@ResCopyA, @@OpLen, 0
                   sub      sp, @@OpLen
                   mov      @@Op0CopyA[0], sp
                   mov      @@Op0CopyA[2], ss
                   movx     @@Op0CopyA, @@Op0Addr, @@OpLen
                   sub      sp, @@OpLen
                   mov      @@Op1CopyA[0], sp
                   mov      @@Op1CopyA[2], ss
                   movx     @@Op1CopyA, @@Op1Addr, @@OpLen
                   mov      cx, @@OpLen
                   dec      cx
                   mov      di, @@Op0CopyA[0]
                   add      di, cx
                   mov      si, @@Op1CopyA[0]
                   add      si, cx
                   mov      ax, 0
                   xchg     al, ss:[di]
                   xchg     ah, ss:[si]
                   push     ax
                   mov      cx, @@OpLen
                   shr      cx, 1
                   dec      di
@@c:               cmp      byte ptr ss:[di], 0
                   je       @@n
                   dec      byte ptr ss:[di]
                   addx     @@ResCopyA, @@Op1CopyA, @@OpLen
                   jmp      @@c
@@n:               sarx     @@Op1CopyA, @@OpLen
                   dec      di
                   loop     @@c
                   pop      ax
                   flgx     @@ResCopyA, @@OpLen
                   jz       @@z
                   xor      al, ah
                   mov      di, @@ResCopyA[0]
                   add      di, @@OpLen
                   dec      di
                   mov      ss:[di], al
@@z:               movx     @@Op0Addr, @@ResCopyA, @@OpLen
                   mov      sp, bp
                   pop      di si bp cx ax
                   popf
                   retf     10
mulxproc           endp

mulx               macro    Op0Addr, Op1Addr, OpLen
                   push     OpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr mulxproc
                   endm


divxproc           proc
                   pushf
                   push     ax cx bp si di
                   mov      bp, sp
@@disp             equ      02+05*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@OpLen            equ      [bp+@@disp+08]
                   sub      sp, 12
@@ResCopyA         equ      [bp-12]
@@Op0CopyA         equ      [bp-08]
@@Op1CopyA         equ      [bp-04]
                   sub      sp, @@OpLen
                   mov      @@ResCopyA[0], sp
                   mov      @@ResCopyA[2], ss
                   setx     @@ResCopyA, @@OpLen, 0
                   sub      sp, @@OpLen
                   mov      @@Op0CopyA[0], sp
                   mov      @@Op0CopyA[2], ss
                   movx     @@Op0CopyA, @@Op0Addr, @@OpLen
                   sub      sp, @@OpLen
                   mov      @@Op1CopyA[0], sp
                   mov      @@Op1CopyA[2], ss
                   movx     @@Op1CopyA, @@Op1Addr, @@OpLen
                   mov      cx, @@OpLen
                   dec      cx
                   mov      di, @@Op0CopyA[0]
                   add      di, cx
                   mov      si, @@Op1CopyA[0]
                   add      si, cx
                   mov      ax, 0
                   xchg     al, ss:[di]
                   xchg     ah, ss:[si]
                   push     ax
                   mov      di, @@ResCopyA[0]
                   mov      si, @@Op0CopyA[0]
                   mov      cx, @@OpLen
                   add      di, cx
                   add      si, cx
                   shr      cx, 1
                   dec      si
                   sub      di, 2
@@c:               cmp      byte ptr [di], 10
                   je       @@ovf
                   inc      byte ptr [di]
                   subx     @@Op0CopyA, @@Op1CopyA, @@OpLen
                   cmp      byte ptr [si], 0
                   je       @@c
                   dec      byte ptr [di]
                   addx     @@Op0CopyA, @@Op1CopyA, @@OpLen
                   dec      di
                   sarx     @@Op1CopyA, @@OpLen
                   loop     @@c
                   jmp      @@flg
@@ovf:             setx     @@ResCopyA, @@OpLen, 9
@@flg:             pop      ax
                   flgx     @@ResCopyA, @@OpLen
                   jz       @@z
                   xor      al, ah
                   mov      di, @@ResCopyA[0]
                   add      di, @@OpLen
                   dec      di
                   mov      ss:[di], al
@@z:               movx     @@Op0Addr, @@ResCopyA, @@OpLen
                   mov      sp, bp
                   pop      di si bp cx ax
                   popf
                   retf     10
divxproc           endp

divx               macro    Op0Addr, Op1Addr, OpLen
                   push     OpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr divxproc
                   endm


movfproc           proc
                   pushf
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02+02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   movx     @@Op0Addr, @@Op1Addr, ax
                   pop      bp ax
                   popf
                   retf     12
movfproc           endp

movf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr movfproc
                   endm


extfproc           proc
                   pushf
                   push     ax cx bp si di ds es
                   mov      bp, sp
@@disp             equ      02+07*02+04
@@OpAddr           equ      [bp+@@disp+00]
@@OpExpA           equ      [bp+@@disp+04]
@@OpFrqA           equ      [bp+@@disp+08]
@@ExpLen           equ      [bp+@@disp+12]
@@FrqLen           equ      [bp+@@disp+14]
                   les      si, @@OpAddr
                   lds      di, @@OpExpA
                   mov      cx, @@ExpLen
                   dec      cx
@@c1:              mov      al, es:[si]
                   mov      [di], al
                   inc      si
                   inc      di
                   loop     @@c1
                   mov      byte ptr [di], 0
                   inc      di
                   mov      al, es:[si]
                   mov      [di], al
                   mov      cx, @@FrqLen
                   dec      cx
                   lds      di, @@OpFrqA
@@c2:              mov      byte ptr [di], 0
                   inc      di
                   loop     @@c2
                   inc      si
                   mov      cx, @@FrqLen
                   dec      cx
@@c3:              mov      al, es:[si]
                   mov      [di], al
                   inc      si
                   inc      di
                   loop     @@c3
                   mov      byte ptr [di], 0
                   inc      di
                   mov      al, es:[si]
                   mov      [di], al
                   pop      es ds di si bp cx ax
                   popf
                   retf     16
extfproc           endp

extf               macro    OpAddr, OpExpA, OpFrqA, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr OpFrqA[2]
                   push     word ptr OpFrqA[0]
                   push     word ptr OpExpA[2]
                   push     word ptr OpExpA[0]
                   push     word ptr OpAddr[2]
                   push     word ptr OpAddr[0]
                   call     far ptr extfproc
                   endm


intfproc           proc
                   pushf
                   push     ax cx bp si di ds es
                   mov      bp, sp
@@disp             equ      02+07*02+04
@@OpAddr           equ      [bp+@@disp+00]
@@OpExpA           equ      [bp+@@disp+04]
@@OpFrqA           equ      [bp+@@disp+08]
@@ExpLen           equ      [bp+@@disp+12]
@@FrqLen           equ      [bp+@@disp+14]
                   les      si, @@OpAddr
                   lds      di, @@OpExpA
                   mov      cx, @@ExpLen
                   dec      cx
@@c1:              mov      al, [di]
                   mov      es:[si], al
                   inc      si
                   inc      di
                   loop     @@c1
                   inc      di
                   mov      al, [di]
                   mov      es:[si], al
                   inc      si
                   lds      di, @@OpFrqA
                   mov      cx, @@FrqLen
                   dec      cx
                   add      di, cx
@@c2:              mov      al, [di]
                   mov      es:[si], al
                   inc      si
                   inc      di
                   loop     @@c2
                   inc      di
                   mov      al, [di]
                   mov      es:[si], al
                   pop      es ds di si bp cx ax
                   popf
                   retf     16
intfproc           endp

intf               macro    OpAddr, OpExpA, OpFrqA, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr OpFrqA[2]
                   push     word ptr OpFrqA[0]
                   push     word ptr OpExpA[2]
                   push     word ptr OpExpA[0]
                   push     word ptr OpAddr[2]
                   push     word ptr OpAddr[0]
                   call     far ptr intfproc
                   endm


addfproc           proc
                   push     ax bp di
                   mov      bp, sp
@@disp             equ      03*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 32
@@ExpLenX          equ      [bp-32]
@@FrqLenX          equ      [bp-28]
@@ResExpA          equ      [bp-24]
@@Op0ExpA          equ      [bp-20]
@@Op1ExpA          equ      [bp-16]
@@ResFrqA          equ      [bp-12]
@@Op0FrqA          equ      [bp-08]
@@Op1FrqA          equ      [bp-04]
                   mov      ax, @@ExpLen
                   inc      ax
                   mov      @@ExpLenX, ax
                   mov      ax, @@FrqLen
                   shl      ax, 1
                   mov      @@FrqLenX, ax
                   sub      sp, @@ExpLenX
                   mov      @@ResExpA[0], sp
                   mov      @@ResExpA[2], ss
                   sub      sp, @@FrqLenX
                   mov      @@ResFrqA[0], sp
                   mov      @@ResFrqA[2], ss
                   sub      sp, @@ExpLenX
                   mov      @@Op0ExpA[0], sp
                   mov      @@Op0ExpA[2], ss
                   sub      sp, @@FrqLenX
                   mov      @@Op0FrqA[0], sp
                   mov      @@Op0FrqA[2], ss
                   extf     @@Op0Addr, @@Op0ExpA, @@Op0FrqA, @@ExpLen, @@FrqLen
                   sub      sp, @@ExpLenX
                   mov      @@Op1ExpA[0], sp
                   mov      @@Op1ExpA[2], ss
                   sub      sp, @@FrqLenX
                   mov      @@Op1FrqA[0], sp
                   mov      @@Op1FrqA[2], ss
                   extf     @@Op1Addr, @@Op1ExpA, @@Op1FrqA, @@ExpLen, @@FrqLen
@@shift:           movx     @@ResExpA, @@Op0ExpA, @@ExpLenX
                   subx     @@ResExpA, @@Op1ExpA, @@ExpLenX
                   flgx     @@ResExpA, @@ExpLenX
                   jz       @@do
                   jc       @@modOp0
                   sarx     @@Op1FrqA, @@FrqLenX
                   incx     @@Op1ExpA, @@ExpLenX
                   jmp      @@shift
@@modOp0:          sarx     @@Op0FrqA, @@FrqLenX
                   incx     @@Op0ExpA, @@ExpLenX
                   jmp      @@shift
@@do:              movx     @@ResExpA, @@Op0ExpA, @@ExpLenX
                   movx     @@ResFrqA, @@Op0FrqA, @@FrqLenX
                   addx     @@ResFrqA, @@Op1FrqA, @@FrqLenX
                   flgx     @@ResFrqA, @@FrqLenX
                   jz       @@retZ
                   mov      di, @@ResFrqA[0]
                   add      di, @@FrqLenX
                   sub      di, 2
                   cmp      byte ptr ss:[di], 0
                   je       @@norm
                   sarx     @@ResFrqA, @@FrqLenX
                   incx     @@ResExpA, @@ExpLenX
@@norm:            dec      di
@@nc:              cmp      byte ptr ss:[di], 0
                   jne      @@check
                   salx     @@ResFrqA, @@FrqLenX
                   decx     @@ResExpA, @@ExpLenX
                   jmp      @@nc
@@check:           mov      di, @@ResExpA[0]
                   add      di, @@ExpLenX
                   sub      di, 2
                   mov      ax, ss:[di]
                   cmp      ax, 0901h
                   je       @@retZ
                   cmp      ax, 0001h
                   je       @@retC
                   mov      al, 1
                   add      al, al
                   pushf
                   jmp      @@e
@@retC:            mov      al, 130
                   add      al, al
                   pushf
                   jmp      @@ret
@@retZ:            setx     @@ResExpA, @@ExpLenX, 0
                   setx     @@ResFrqA, @@FrqLenX, 0
                   mov      al, 1
                   sub      al, al
                   pushf
@@e:               intf     @@Op0Addr, @@ResExpA, @@ResFrqA, @@ExpLen, @@FrqLen
@@ret:             popf
                   mov      sp, bp
                   pop      di bp ax
                   retf     12
addfproc           endp

addf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr addfproc
                   endm


subfproc           proc
                   push     ax bp di
                   mov      bp, sp
@@disp             equ      03*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 32
@@ExpLenX          equ      [bp-32]
@@FrqLenX          equ      [bp-28]
@@ResExpA          equ      [bp-24]
@@Op0ExpA          equ      [bp-20]
@@Op1ExpA          equ      [bp-16]
@@ResFrqA          equ      [bp-12]
@@Op0FrqA          equ      [bp-08]
@@Op1FrqA          equ      [bp-04]
                   mov      ax, @@ExpLen
                   inc      ax
                   mov      @@ExpLenX, ax
                   mov      ax, @@FrqLen
                   shl      ax, 1
                   mov      @@FrqLenX, ax
                   sub      sp, @@ExpLenX
                   mov      @@ResExpA[0], sp
                   mov      @@ResExpA[2], ss
                   sub      sp, @@FrqLenX
                   mov      @@ResFrqA[0], sp
                   mov      @@ResFrqA[2], ss
                   sub      sp, @@ExpLenX
                   mov      @@Op0ExpA[0], sp
                   mov      @@Op0ExpA[2], ss
                   sub      sp, @@FrqLenX
                   mov      @@Op0FrqA[0], sp
                   mov      @@Op0FrqA[2], ss
                   extf     @@Op0Addr, @@Op0ExpA, @@Op0FrqA, @@ExpLen, @@FrqLen
                   sub      sp, @@ExpLenX
                   mov      @@Op1ExpA[0], sp
                   mov      @@Op1ExpA[2], ss
                   sub      sp, @@FrqLenX
                   mov      @@Op1FrqA[0], sp
                   mov      @@Op1FrqA[2], ss
                   extf     @@Op1Addr, @@Op1ExpA, @@Op1FrqA, @@ExpLen, @@FrqLen
@@shift:           movx     @@ResExpA, @@Op0ExpA, @@ExpLenX
                   subx     @@ResExpA, @@Op1ExpA, @@ExpLenX
                   flgx     @@ResExpA, @@ExpLenX
                   jz       @@do
                   jc       @@modOp0
                   sarx     @@Op1FrqA, @@FrqLenX
                   incx     @@Op1ExpA, @@ExpLenX
                   jmp      @@shift
@@modOp0:          sarx     @@Op0FrqA, @@FrqLenX
                   incx     @@Op0ExpA, @@ExpLenX
                   jmp      @@shift
@@do:              movx     @@ResExpA, @@Op0ExpA, @@ExpLenX
                   movx     @@ResFrqA, @@Op0FrqA, @@FrqLenX
                   subx     @@ResFrqA, @@Op1FrqA, @@FrqLenX
                   flgx     @@ResFrqA, @@FrqLenX
                   jz       @@retZ
                   mov      di, @@ResFrqA[0]
                   add      di, @@FrqLenX
                   sub      di, 2
                   cmp      byte ptr ss:[di], 0
                   je       @@norm
                   sarx     @@ResFrqA, @@FrqLenX
                   incx     @@ResExpA, @@ExpLenX
@@norm:            dec      di
@@nc:              cmp      byte ptr ss:[di], 0
                   jne      @@check
                   salx     @@ResFrqA, @@FrqLenX
                   decx     @@ResExpA, @@ExpLenX
                   jmp      @@nc
@@check:           mov      di, @@ResExpA[0]
                   add      di, @@ExpLenX
                   sub      di, 2
                   mov      ax, ss:[di]
                   cmp      ax, 0901h
                   je       @@retZ
                   cmp      ax, 0001h
                   je       @@retC
                   mov      al, 1
                   add      al, al
                   pushf
                   jmp      @@e
@@retC:            mov      al, 130
                   add      al, al
                   pushf
                   jmp      @@ret
@@retZ:            setx     @@ResExpA, @@ExpLenX, 0
                   setx     @@ResFrqA, @@FrqLenX, 0
                   mov      al, 1
                   sub      al, al
                   pushf
@@e:               intf     @@Op0Addr, @@ResExpA, @@ResFrqA, @@ExpLen, @@FrqLen
@@ret:             popf
                   mov      sp, bp
                   pop      di bp ax
                   retf     12
subfproc           endp

subf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr subfproc
                   endm


mulfproc           proc
                   push     ax bp di
                   mov      bp, sp
@@disp             equ      03*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 32
@@ExpLenX          equ      [bp-32]
@@FrqLenX          equ      [bp-28]
@@ResExpA          equ      [bp-24]
@@Op0ExpA          equ      [bp-20]
@@Op1ExpA          equ      [bp-16]
@@ResFrqA          equ      [bp-12]
@@Op0FrqA          equ      [bp-08]
@@Op1FrqA          equ      [bp-04]
                   mov      ax, @@ExpLen
                   inc      ax
                   mov      @@ExpLenX, ax
                   mov      ax, @@FrqLen
                   shl      ax, 1
                   mov      @@FrqLenX, ax
                   sub      sp, @@ExpLenX
                   mov      @@ResExpA[0], sp
                   mov      @@ResExpA[2], ss
                   sub      sp, @@FrqLenX
                   mov      @@ResFrqA[0], sp
                   mov      @@ResFrqA[2], ss
                   sub      sp, @@ExpLenX
                   mov      @@Op0ExpA[0], sp
                   mov      @@Op0ExpA[2], ss
                   sub      sp, @@FrqLenX
                   mov      @@Op0FrqA[0], sp
                   mov      @@Op0FrqA[2], ss
                   extf     @@Op0Addr, @@Op0ExpA, @@Op0FrqA, @@ExpLen, @@FrqLen
                   sub      sp, @@ExpLenX
                   mov      @@Op1ExpA[0], sp
                   mov      @@Op1ExpA[2], ss
                   sub      sp, @@FrqLenX
                   mov      @@Op1FrqA[0], sp
                   mov      @@Op1FrqA[2], ss
                   extf     @@Op1Addr, @@Op1ExpA, @@Op1FrqA, @@ExpLen, @@FrqLen
                   movx     @@ResExpA, @@Op0ExpA, @@ExpLenX
                   addx     @@ResExpA, @@Op1ExpA, @@ExpLenX
                   movx     @@ResFrqA, @@Op0FrqA, @@FrqLenX
                   mulx     @@ResFrqA, @@Op1FrqA, @@FrqLenX
                   flgx     @@ResFrqA, @@FrqLenX
                   jz       @@retZ
                   mov      di, @@ResFrqA[0]
                   add      di, @@FrqLenX
                   sub      di, 2
                   cmp      byte ptr ss:[di], 0
                   je       @@norm
                   sarx     @@ResFrqA, @@FrqLenX
                   incx     @@ResExpA, @@ExpLenX
@@norm:            dec      di
@@nc:              cmp      byte ptr ss:[di], 0
                   jne      @@check
                   salx     @@ResFrqA, @@FrqLenX
                   decx     @@ResExpA, @@ExpLenX
                   jmp      @@nc
@@check:           mov      di, @@ResExpA[0]
                   add      di, @@ExpLenX
                   sub      di, 2
                   mov      ax, ss:[di]
                   cmp      ax, 0901h
                   je       @@retZ
                   cmp      ax, 0001h
                   je       @@retC
                   mov      al, 1
                   add      al, al
                   pushf
                   jmp      @@e
@@retC:            mov      al, 130
                   add      al, al
                   pushf
                   jmp      @@ret
@@retZ:            setx     @@ResExpA, @@ExpLenX, 0
                   setx     @@ResFrqA, @@FrqLenX, 0
                   mov      al, 1
                   sub      al, al
                   pushf
@@e:               intf     @@Op0Addr, @@ResExpA, @@ResFrqA, @@ExpLen, @@FrqLen
@@ret:             popf
                   mov      sp, bp
                   pop      di bp ax
                   retf     12
mulfproc           endp

mulf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr mulfproc
                   endm


divfproc           proc
                   push     ax bp di
                   mov      bp, sp
@@disp             equ      03*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 32
@@ExpLenX          equ      [bp-32]
@@FrqLenX          equ      [bp-28]
@@ResExpA          equ      [bp-24]
@@Op0ExpA          equ      [bp-20]
@@Op1ExpA          equ      [bp-16]
@@ResFrqA          equ      [bp-12]
@@Op0FrqA          equ      [bp-08]
@@Op1FrqA          equ      [bp-04]
                   mov      ax, @@ExpLen
                   inc      ax
                   mov      @@ExpLenX, ax
                   mov      ax, @@FrqLen
                   shl      ax, 1
                   mov      @@FrqLenX, ax
                   sub      sp, @@ExpLenX
                   mov      @@ResExpA[0], sp
                   mov      @@ResExpA[2], ss
                   sub      sp, @@FrqLenX
                   mov      @@ResFrqA[0], sp
                   mov      @@ResFrqA[2], ss
                   sub      sp, @@ExpLenX
                   mov      @@Op0ExpA[0], sp
                   mov      @@Op0ExpA[2], ss
                   sub      sp, @@FrqLenX
                   mov      @@Op0FrqA[0], sp
                   mov      @@Op0FrqA[2], ss
                   extf     @@Op0Addr, @@Op0ExpA, @@Op0FrqA, @@ExpLen, @@FrqLen
                   sub      sp, @@ExpLenX
                   mov      @@Op1ExpA[0], sp
                   mov      @@Op1ExpA[2], ss
                   sub      sp, @@FrqLenX
                   mov      @@Op1FrqA[0], sp
                   mov      @@Op1FrqA[2], ss
                   extf     @@Op1Addr, @@Op1ExpA, @@Op1FrqA, @@ExpLen, @@FrqLen
                   sarx     @@Op0FrqA, @@FrqLenX
                   incx     @@Op0ExpA, @@ExpLenX
                   movx     @@ResExpA, @@Op0ExpA, @@ExpLenX
                   subx     @@ResExpA, @@Op1ExpA, @@ExpLenX
                   movx     @@ResFrqA, @@Op0FrqA, @@FrqLenX
                   divx     @@ResFrqA, @@Op1FrqA, @@FrqLenX
                   mov      di, @@ResFrqA[0]
                   add      di, @@FrqLenX
                   sub      di, 2
                   cmp      byte ptr ss:[di], 9
                   je       @@retC
                   flgx     @@ResFrqA, @@FrqLenX
                   jz       @@retZ
                   mov      di, @@ResFrqA[0]
                   add      di, @@FrqLenX
                   sub      di, 2
                   cmp      byte ptr ss:[di], 0
                   je       @@norm
                   sarx     @@ResFrqA, @@FrqLenX
                   incx     @@ResExpA, @@ExpLenX
@@norm:            dec      di
@@nc:              cmp      byte ptr ss:[di], 0
                   jne      @@check
                   salx     @@ResFrqA, @@FrqLenX
                   decx     @@ResExpA, @@ExpLenX
                   jmp      @@nc
@@check:           mov      di, @@ResExpA[0]
                   add      di, @@ExpLenX
                   sub      di, 2
                   mov      ax, ss:[di]
                   cmp      ax, 0901h
                   je       @@retZ
                   cmp      ax, 0001h
                   je       @@retC
                   mov      al, 1
                   add      al, al
                   pushf
                   jmp      @@e
@@retC:            mov      al, 130
                   add      al, al
                   pushf
                   jmp      @@ret
@@retZ:            setx     @@ResExpA, @@ExpLenX, 0
                   setx     @@ResFrqA, @@FrqLenX, 0
                   mov      al, 1
                   sub      al, al
                   pushf
@@e:               intf     @@Op0Addr, @@ResExpA, @@ResFrqA, @@ExpLen, @@FrqLen
@@ret:             popf
                   mov      sp, bp
                   pop      di bp ax
                   retf     12
divfproc           endp

divf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr divfproc
                   endm


ftosproc           proc
                   pushf
                   push     ax bx cx bp di si ds es
                   mov      bp, sp
@@disp             equ      02+08*02+04
@@StrA             equ      [bp+@@disp+00]
@@ImgMapA          equ      [bp+@@disp+04]
@@OpAddr           equ      [bp+@@disp+08]
@@ExpLen           equ      [bp+@@disp+12]
@@FrqLen           equ      [bp+@@disp+14]
                   sub      sp, 12
@@DigCount         equ      [bp-12]
@@PointPos         equ      [bp-10]
@@FrqA             equ      [bp-08]
@@ExpCopyA         equ      [bp-04]
                   mov      ax, @@OpAddr[2]
                   mov      @@FrqA[2], ax
                   mov      ax, @@OpAddr[0]
                   add      ax, @@ExpLen
                   mov      @@FrqA[0], ax
                   sub      sp, @@ExpLen
                   mov      @@ExpCopyA[0], sp
                   mov      @@ExpCopyA[2], ss
                   movx     @@ExpCopyA, @@OpAddr, @@ExpLen
                   movx     @@StrA, @@FrqA, @@FrqLen
                   mov      ax, @@FrqLen
                   mov      @@PointPos, ax
                   mov      @@DigCount, ax
                   flgx     @@ExpCopyA, @@ExpLen
                   jz       @@e0
                   jc       @@em
                   dec      word ptr @@DigCount
@@epc:             mov      ax, 1
                   cmp      ax, @@PointPos
                   jz       @@epexp
                   dec      word ptr @@PointPos
                   decx     @@ExpCopyA, @@ExpLen
                   flgx     @@ExpCopyA, @@ExpLen
                   jz       @@image
                   jmp      @@epc
@@epexp:           mov      ax, @@FrqLen
                   dec      ax
                   mov      @@PointPos, ax
                   movx     @@StrA, @@OpAddr, @@ExpLen
                   decx     @@StrA, @@ExpLen
                   lds      di, @@StrA
                   add      di, @@ExpLen
                   mov      byte ptr [di], 13
                   mov      byte ptr [di-01], 12
                   jmp      @@image
@@em:              dec      word ptr @@PointPos
                   dec      word ptr @@DigCount
@@emc:             dec      word ptr @@DigCount
                   jz       @@mcexp
                   flgx     @@ExpCopyA, @@ExpLen
                   jnc      @@image
                   incx     @@ExpCopyA, @@ExpLen
                   jmp      @@emc
@@mcexp:           mov      ax, @@FrqLen
                   dec      ax
                   mov      word ptr @@DigCount, ax
                   sarx     @@StrA, @@FrqLen
                   movx     @@StrA, @@OpAddr, @@ExpLen
                   lds      di, @@StrA
                   add      di, @@ExpLen
                   mov      byte ptr [di+01], 13
                   mov      byte ptr [di], 12
                   mov      byte ptr [di-01], 11
                   jmp      @@image
@@e0:              sub      word ptr @@DigCount, 2
                   dec      word ptr @@PointPos
                   jmp      @@image
@@image:           mov      cx, @@FrqLen
                   sub      cx, @@DigCount
@@iec:             dec      cx
                   jz       @@img
                   sarx     @@StrA, @@FrqLen
                   jmp      @@iec
@@img:             lds      bx, @@ImgMapA
                   les      di, @@StrA
                   mov      ax, @@FrqLen
                   sub      ax, @@PointPos
                   mov      @@PointPos, ax
                   mov      cx, @@FrqLen
                   dec      cx
@@imagec:          mov      al, es:[di]
                   xlat
                   mov      es:[di], al
                   cmp      cx, @@PointPos
                   jne      @@imagen
                   mov      al, 10
                   xlat
                   or       ss:[di], al
@@imagen:          inc      di
                   loop     @@imagec
                   mov      sp, bp
                   pop      es ds si di bp bx cx ax
                   popf
                   retf     16
ftosproc           endp

ftos               macro    StrA, ImgMapA, OpAddr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr OpAddr[2]
                   push     word ptr OpAddr[0]
                   push     word ptr ImgMapA[2]
                   push     word ptr ImgMapA[0]
                   push     word ptr StrA[2]
                   push     word ptr StrA[0]
                   call     far ptr ftosproc
                   endm


fmtsproc           proc
                   pushf
                   push     ax bx cx dx bp di ds es
                   mov      bp, sp
@@disp             equ      02+08*02+04
@@StrA             equ      [bp+@@disp+00]
@@ImgMapA          equ      [bp+@@disp+04]
@@FrqLen           equ      [bp+@@disp+08]
@@Format           equ      [bp+@@disp+10]
                   lds      bx, @@ImgMapA
                   mov      al, 12
                   xlat
                   mov      cx, @@FrqLen
                   les      di, @@StrA
@@chc:             mov      ah, es:[di]
                   cmp      ah, al
                   je       @@e
                   inc      di
                   loop     @@chc
                   mov      al, 10
                   xlat
                   mov      cx, @@FrqLen
                   les      di, @@StrA
                   mov      dx, 0
@@cp:              mov      ah, es:[di]
                   and      ah, al
                   jnz      @@shift
                   inc      dx
                   inc      di
                   loop     @@cp
                   jmp      @@e
@@shift:           mov      ax, @@FrqLen
                   sub      ax, 2
                   cmp      ax, @@Format
                   jc       @@delnulls
                   cmp      dx, @@Format
                   jc       @@e
                   les      si, @@StrA
                   add      si, @@FrqLen
                   sub      si, 2
                   mov      al, 13
                   xlat
@@shc:             cmp      dx, @@Format
                   je       @@e
                   dec      dx
                   sarx     @@StrA, @@FrqLen
                   mov      es:[si], al
                   jmp      @@shc
@@delnulls:        les      si, @@StrA
                   mov      al, 0
                   xlat
                   mov      ah, al
                   mov      al, 13
                   xlat
                   mov      bx, si
                   add      bx, @@FrqLen
                   sub      bx, 2
@@delc:            cmp      es:[si], ah
                   jne      @@e
                   sarx     @@StrA, @@FrqLen
                   mov      es:[bx], al
                   jmp      @@delc
@@e:               pop      es ds di bp dx cx bx ax
                   popf
                   retf     12
fmtsproc           endp

fmts               macro    StrA, ImgMapA, FrqLen, Format
                   push     Format
                   push     FrqLen
                   push     word ptr ImgMapA[2]
                   push     word ptr ImgMapA[0]
                   push     word ptr StrA[2]
                   push     word ptr StrA[0]
                   call     far ptr fmtsproc
                   endm


cepfproc           proc
                   pushf
                   push     ax cx bp ds di
                   mov      bp, sp
@@disp             equ      02+05*02+04
@@OpAddr           equ      [bp+@@disp+00]
@@ExpLen           equ      [bp+@@disp+04]
@@FrqLen           equ      [bp+@@disp+06]
@@Frq              equ      [bp+@@disp+08]
@@Sign             equ      [bp+@@disp+10]
@@Exp              equ      [bp+@@disp+12]
                   mov      cx, @@ExpLen
                   lds      di, @@OpAddr
                   mov      al, @@Exp
                   mov      [di], al
                   mov      al, 0
                   dec      cx
@@ce:              inc      di
                   mov      [di], al
                   loop     @@ce
                   mov      cx, @@FrqLen
                   sub      cx, 2
@@cf:              inc      di
                   mov      [di], al
                   loop     @@cf
                   mov      al, @@Frq
                   mov      [di+01], al
                   mov      al, @@Sign
                   mov      [di+02], al
                   pop      di ds bp cx ax
                   popf
                   retf     14
cepfproc           endp

cepf               macro    OpAddr, ExpLen, FrqLen, Frq, Sign, Exp
                   push     Exp
                   push     Sign
                   push     Frq
                   push     FrqLen
                   push     ExpLen
                   push     word ptr OpAddr[2]
                   push     word ptr OpAddr[0]
                   call     far ptr cepfproc
                   endm

czrf               macro    OpAddr, ExpLen, FrqLen
                   cepf     OpAddr, ExpLen, FrqLen, 0, 0, 0
                   endm


cp1f               macro    OpAddr, ExpLen, FrqLen
                   cepf     OpAddr, ExpLen, FrqLen, 1, 0, 1
                   endm

cm1f               macro    OpAddr, ExpLen, FrqLen
                   cepf     OpAddr, ExpLen, FrqLen, 1, 9, 1
                   endm

cp2f               macro    OpAddr, ExpLen, FrqLen
                   cepf     OpAddr, ExpLen, FrqLen, 2, 0, 1
                   endm

cp3f               macro    OpAddr, ExpLen, FrqLen
                   cepf     OpAddr, ExpLen, FrqLen, 3, 0, 1
                   endm

c10f               macro    OpAddr, ExpLen, FrqLen
                   cepf     OpAddr, ExpLen, FrqLen, 1, 0, 2
                   endm


cosfproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 24
@@GammaA           equ      [bp-24]
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   sub      sp, ax
                   mov      @@GammaA[0], sp
                   mov      @@GammaA[2], ss
                   czrf     @@ResA, @@ExpLen, @@FrqLen
                   czrf     @@BetaA, @@ExpLen, @@FrqLen
                   movf     @@AlphaA, @@p1A, @@ExpLen, @@FrqLen
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
@@c:               movf     @@GammaA, @@ResA, @@ExpLen, @@FrqLen
                   addf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   subf     @@GammaA, @@ResA, @@ExpLen, @@FrqLen
                   flgx     @@GammaA, ax
                   jz       @@r
                   mulf     @@AlphaA, @@m1A, @@ExpLen, @@FrqLen
                   addf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   divf     @@AlphaA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   addf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   divf     @@AlphaA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   jmp      @@c
@@r:               movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
@@retC:            mov      sp, bp
                   pop      bp ax
                   retf     12
cosfproc           endp

cosf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr cosfproc
                   endm


sinfproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 24
@@GammaA           equ      [bp-24]
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   sub      sp, ax
                   mov      @@GammaA[0], sp
                   mov      @@GammaA[2], ss
                   czrf     @@ResA, @@ExpLen, @@FrqLen
                   movf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   movf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
@@c:               movf     @@GammaA, @@ResA, @@ExpLen, @@FrqLen
                   addf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   subf     @@GammaA, @@ResA, @@ExpLen, @@FrqLen
                   flgx     @@GammaA, ax
                   jz       @@r
                   mulf     @@AlphaA, @@m1A, @@ExpLen, @@FrqLen
                   addf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   divf     @@AlphaA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   addf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   divf     @@AlphaA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   jmp      @@c
@@r:               movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
@@retC:            mov      sp, bp
                   pop      bp ax
                   retf     12
sinfproc           endp

sinf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr sinfproc
                   endm


tanfproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 20
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   sinf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   cosf     @@BetaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   movf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   divf     @@ResA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
@@retC:            mov      sp, bp
                   pop      bp ax
                   retf     12
tanfproc           endp

tanf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr tanfproc
                   endm


cotfproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 20
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   sinf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   cosf     @@BetaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   movf     @@ResA, @@BetaA, @@ExpLen, @@FrqLen
                   divf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
@@retC:            mov      sp, bp
                   pop      bp ax
                   retf     12
cotfproc           endp

cotf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr cotfproc
                   endm


expfproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 24
@@GammaA           equ      [bp-24]
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   sub      sp, ax
                   mov      @@GammaA[0], sp
                   mov      @@GammaA[2], ss
                   mov      ax, 0
                   push     ax
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   flgx     @@Op1Addr, ax
                   jnc      @@st
                   pop      ax
                   mov      ax, 1
                   push     ax
@@st:              czrf     @@ResA, @@ExpLen, @@FrqLen
                   czrf     @@BetaA, @@ExpLen, @@FrqLen
                   movf     @@AlphaA, @@p1A, @@ExpLen, @@FrqLen
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
@@c:               movf     @@GammaA, @@ResA, @@ExpLen, @@FrqLen
                   addf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   subf     @@GammaA, @@ResA, @@ExpLen, @@FrqLen
                   flgx     @@GammaA, ax
                   jz       @@r
                   addf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   divf     @@AlphaA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   jmp      @@c
@@r:               flgx     @@ResA, ax
                   jc       @@retC
                   movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
                   jmp      @@ret
@@retC:            pop      ax
                   cmp      ax, 0
                   je       @@carry
                   czrf     @@Op0Addr, @@ExpLen, @@FrqLen
                   mov      al, 1
                   add      al, al
                   jmp      @@ret
@@carry:           mov      al, 130
                   add      al, al
@@ret:             mov      sp, bp
                   pop      bp ax
                   retf     12
expfproc           endp

expf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr expfproc
                   endm


etofproc           proc
                   pushf
                   push     ax cx bp ds di
                   mov      bp, sp
@@disp             equ      02+05*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 04
@@Op0FrqA          equ      [bp-04]
                   lds      ax, @@Op0Addr
                   add      ax, @@FrqLen
                   mov      @@Op0FrqA[0], ax
                   mov      @@Op0FrqA[2], ds
                   czrf     @@Op0Addr, @@ExpLen, @@FrqLen
                   movx     @@Op0FrqA, @@Op1Addr, @@ExpLen
                   flgx     @@Op0FrqA, @@ExpLen
                   jz       @@e
                   mov      cx, @@ExpLen
                   dec      cx
@@ci:              incx     @@Op0Addr, @@ExpLen
                   loop     @@ci
                   lds      di, @@Op0FrqA
                   add      di, @@ExpLen
                   sub      di, 2
@@csh:             cmp      byte ptr [di], 0
                   jne      @@e
                   salx     @@Op0FrqA, @@ExpLen
                   decx     @@Op0Addr, @@ExpLen
                   jmp      @@csh
@@e:               mov      sp, bp
                   pop      di ds bp cx ax
                   popf
                   retf     12
etofproc           endp

etof               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr etofproc
                   endm


mtofproc           proc
                   pushf
                   push     bp
                   mov      bp, sp
@@disp             equ      02+01*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   movf     @@Op0Addr, @@Op1Addr, @@ExpLen, @@FrqLen
                   setx     @@Op0Addr, @@ExpLen, 0
                   pop      bp
                   popf
                   retf     12
mtofproc           endp

mtof               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr mtofproc
                   endm


lgefproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 28
@@GammaA           equ      [bp-28]
@@DeltaA           equ      [bp-24]
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   sub      sp, ax
                   mov      @@GammaA[0], sp
                   mov      @@GammaA[2], ss
                   sub      sp, ax
                   mov      @@DeltaA[0], sp
                   mov      @@DeltaA[2], ss
                   movf     @@DeltaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   subf     @@DeltaA, @@p1A, @@ExpLen, @@FrqLen
                   mov      ax, @@FrqLen
                   add      ax, @@ExpLen
                   flgx     @@Op1Addr, ax
                   jc       @@retC
                   jnz      @@do
                   mov      al, 130
                   add      al, al
                   jmp      @@retC
@@do:              czrf     @@ResA, @@ExpLen, @@FrqLen
                   movf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   movf     @@AlphaA, @@DeltaA, @@ExpLen, @@FrqLen
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
@@c:               movf     @@GammaA, @@ResA, @@ExpLen, @@FrqLen
                   addf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   subf     @@GammaA, @@ResA, @@ExpLen, @@FrqLen
                   flgx     @@GammaA, ax
                   jz       @@r
                   mulf     @@AlphaA, @@m1A, @@ExpLen, @@FrqLen
                   mulf     @@AlphaA, @@BetaA, @@ExpLen, @@FrqLen
                   addf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   divf     @@AlphaA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@DeltaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   jmp      @@c
@@r:               movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
@@retC:            mov      sp, bp
                   pop      bp ax
                   retf     12
lgefproc           endp

lgef               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr lgefproc
                   endm


logfproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 24
@@DeltaA           equ      [bp-24]
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@DeltaA[0], sp
                   mov      @@DeltaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   movf     @@ResA, @@Op1Addr, @@ExpLen, @@FrqLen
                   subf     @@ResA, @@p1A, @@ExpLen, @@FrqLen
                   mov      ax, @@ExpLen
                   add      ax , @@FrqLen
                   flgx     @@ResA, ax
                   jz       @@r
                   mtof     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   lgef     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   expf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   c10f     @@DeltaA, @@ExpLen, @@FrqLen
                   divf     @@DeltaA, @@BetaA, @@ExpLen, @@FrqLen
                   divf     @@DeltaA, @@BetaA, @@ExpLen, @@FrqLen
                   divf     @@DeltaA, @@BetaA, @@ExpLen, @@FrqLen
                   lgef     @@DeltaA, @@DeltaA, @@ExpLen, @@FrqLen
                   cp3f     @@BetaA, @@ExpLen, @@FrqLen
                   addf     @@BetaA, @@DeltaA, @@ExpLen, @@FrqLen
                   etof     @@DeltaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   mulf     @@DeltaA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   addf     @@ResA, @@DeltaA, @@ExpLen, @@FrqLen
                   jc       @@retC
@@r:               movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
@@retC:            mov      sp, bp
                   pop      bp ax
                   retf     12
logfproc           endp

logf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr logfproc
                   endm


parfproc           proc
                   push     ax cx bp di ds
                   mov      bp, sp
@@disp             equ      02*05+04
@@Op0Addr          equ      [bp+@@disp+00]
@@ExpLen           equ      [bp+@@disp+04]
@@FrqLen           equ      [bp+@@disp+06]
                   sub      sp, 12
@@p1A              equ      [bp-12]
@@ExpA             equ      [bp-08]
@@FrqA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@ExpA[0], sp
                   mov      @@ExpA[2], ss
                   sub      sp, ax
                   mov      @@FrqA[0], sp
                   mov      @@FrqA[2], ss
                   etof     @@ExpA, @@Op0Addr, @@ExpLen, @@FrqLen
                   mtof     @@FrqA, @@Op0Addr, @@ExpLen, @@FrqLen
                   flgx     @@Op0Addr, ax
                   jz       @@parity
                   lds      di, @@FrqA
                   add      di, @@ExpLen
                   mov      cx, @@FrqLen
                   dec      cx
@@c1:              cmp      byte ptr [di], 0
                   jne      @@c2
                   inc      di
                   loop     @@c1
@@c2:              subf     @@ExpA, @@p1A, @@ExpLen, @@FrqLen
                   loop     @@c2
                   flgx     @@ExpA, ax
                   jz       @@gh
                   jnc      @@parity
@@gh:              mov      al, [di]
                   and      al, 001h
                   jz       @@parity
@@nonpar:          mov      al, 1
                   add      al, al
                   jmp      @@r
@@parity:          mov      al, 1
                   sub      al, al
@@r:               mov      sp, bp
                   pop      ds di bp cx ax
                   retf     8
parfproc           endp

parf               macro    Op0Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr parfproc
                   endm


hnffproc           proc
                   push     ax cx bp di ds
                   mov      bp, sp
@@disp             equ      02*05+04
@@Op0Addr          equ      [bp+@@disp+00]
@@ExpLen           equ      [bp+@@disp+04]
@@FrqLen           equ      [bp+@@disp+06]
                   sub      sp, 12
@@p1A              equ      [bp-12]
@@ExpA             equ      [bp-08]
@@FrqA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@ExpA[0], sp
                   mov      @@ExpA[2], ss
                   sub      sp, ax
                   mov      @@FrqA[0], sp
                   mov      @@FrqA[2], ss
                   flgx     @@Op0Addr, ax
                   jz       @@int
                   etof     @@ExpA, @@Op0Addr, @@ExpLen, @@FrqLen
                   mtof     @@FrqA, @@Op0Addr, @@ExpLen, @@FrqLen
                   flgx     @@ExpA, ax
                   jz       @@nonint
                   jc       @@nonint
                   mov      cx, @@FrqLen
                   dec      cx
                   lds      di, @@FrqA
                   add      di, @@ExpLen
@@c1:              cmp      byte ptr [di], 0
                   jne      @@c2
                   inc      di
                   loop     @@c1
@@c2:              subf     @@ExpA, @@p1A, @@ExpLen, @@FrqLen
                   loop     @@c2
                   flgx     @@ExpA, ax
                   jc       @@nonint
                   jmp      @@int
@@nonint:          mov      al, 1
                   add      al, al
                   jmp      @@r
@@int:             mov      al, 1
                   sub      al, al
@@r:               mov      sp, bp
                   pop      ds di bp cx ax
                   retf     8
hnffproc           endp

hnff               macro    Op0Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr hnffproc
                   endm


powfproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 24
@@DeltaA           equ      [bp-24]
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@DeltaA[0], sp
                   mov      @@DeltaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   czrf     @@ResA, @@ExpLen, @@FrqLen
                   flgx     @@Op0Addr, @@ExpLen, @@FrqLen
                   jz       @@r
                   etof     @@BetaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   mtof     @@DeltaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   movf     @@BetaA, @@Op0Addr, @@ExpLen, @@FrqLen
                   movf     @@DeltaA, @@p1A, @@ExpLen, @@FrqLen
                   flgx     @@BetaA, ax
                   jnc      @@do
                   movf     @@DeltaA, @@m1A, @@ExpLen, @@FrqLen
@@do:              mulf     @@BetaA, @@DeltaA, @@ExpLen, @@FrqLen
                   logf     @@AlphaA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   expf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   flgx     @@DeltaA, ax
                   jnc      @@r
                   hnff     @@Op1Addr, @@ExpLen, @@FrqLen
                   jnz      @@retC
                   parf     @@Op1Addr, @@ExpLen, @@FrqLen
                   jnz      @@r
                   mulf     @@DeltaA, @@DeltaA, @@ExpLen, @@FrqLen
@@r:               mulf     @@ResA, @@DeltaA, @@ExpLen, @@FrqLen
                   movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
                   mov      al, 1
                   add      al, al
                   jmp      @@ret
@@retC:            mov      al, 130
                   add      al, al
@@ret:             mov      sp, bp
                   pop      bp ax
                   retf     12
powfproc           endp

powf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr powfproc
                   endm


atffproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 28
@@GammaA           equ      [bp-28]
@@DeltaA           equ      [bp-24]
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   sub      sp, ax
                   mov      @@GammaA[0], sp
                   mov      @@GammaA[2], ss
                   sub      sp, ax
                   mov      @@DeltaA[0], sp
                   mov      @@DeltaA[2], ss
                   czrf     @@ResA, @@ExpLen, @@FrqLen
                   movf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   movf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
@@c:               movf     @@GammaA, @@ResA, @@ExpLen, @@FrqLen
                   addf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   subf     @@GammaA, @@ResA, @@ExpLen, @@FrqLen
                   flgx     @@GammaA, ax
                   jz       @@r
                   addf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   addf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   divf     @@AlphaA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@m1A, @@ExpLen, @@FrqLen
                   jmp      @@c
@@r:               movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
@@retC:            mov      sp, bp
                   pop      bp ax
                   retf     12
atffproc           endp

atff               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr atffproc
                   endm


atgfproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 28
@@GammaA           equ      [bp-28]
@@DeltaA           equ      [bp-24]
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   sub      sp, ax
                   mov      @@GammaA[0], sp
                   mov      @@GammaA[2], ss
                   sub      sp, ax
                   mov      @@DeltaA[0], sp
                   mov      @@DeltaA[2], ss
                   movf     @@DeltaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   movf     @@AlphaA, @@p1A, @@ExpLen, @@FrqLen
                   flgx     @@DeltaA, ax
                   jnc      @@do
                   movf     @@AlphaA, @@m1A, @@ExpLen, @@FrqLen
                   mulf     @@DeltaA, @@AlphaA, @@ExpLen, @@FrqLen
@@do:              movf     @@GammaA, @@DeltaA, @@ExpLen, @@FrqLen
                   subf     @@GammaA, @@p1A, @@ExpLen, @@FrqLen
                   flgx     @@GammaA, ax
                   jc       @@direct
                   jz       @@direct
                   atff     @@ResA, @@p1A, @@ExpLen, @@FrqLen
                   addf     @@ResA, @@ResA, @@ExpLen, @@FrqLen
                   movf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   divf     @@BetaA, @@DeltaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   atff     @@BetaA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   subf     @@ResA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jmp      @@r
@@direct:          atff     @@ResA, @@DeltaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
@@r:               movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
@@retC:            mov      sp, bp
                   pop      bp ax
                   retf     12
atgfproc           endp

atgf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr atgfproc
                   endm


actfproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 16
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   atff     @@ResA, @@p1A, @@ExpLen, @@FrqLen
                   addf     @@ResA, @@ResA, @@ExpLen, @@FrqLen
                   atgf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   subf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
@@r:               movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
@@retC:            mov      sp, bp
                   pop      bp ax
                   retf     12
actfproc           endp

actf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr actfproc
                   endm


asnfproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 28
@@GammaA           equ      [bp-28]
@@DeltaA           equ      [bp-24]
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   sub      sp, ax
                   mov      @@GammaA[0], sp
                   mov      @@GammaA[2], ss
                   sub      sp, ax
                   mov      @@DeltaA[0], sp
                   mov      @@DeltaA[2], ss
                   movf     @@GammaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   subf     @@GammaA, @@p1A, @@ExpLen, @@FrqLen
                   flgx     @@GammaA, ax
                   jnz      @@ism1
                   atff     @@ResA, @@p1A, @@ExpLen, @@FrqLen
                   addf     @@ResA, @@ResA, @@ExpLen, @@FrqLen
                   jmp      @@r
@@ism1:            movf     @@GammaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   subf     @@GammaA, @@m1A, @@ExpLen, @@FrqLen
                   flgx     @@GammaA, ax
                   jnz      @@do
                   atff     @@ResA, @@m1A, @@ExpLen, @@FrqLen
                   addf     @@ResA, @@ResA, @@ExpLen, @@FrqLen
                   jmp      @@r
@@do:              movf     @@ResA, @@Op1Addr, @@ExpLen, @@FrqLen
                   movf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   mulf     @@AlphaA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@m1A, @@ExpLen, @@FrqLen
                   addf     @@AlphaA, @@p1A, @@ExpLen, @@FrqLen
                   cp2f     @@GammaA, @@ExpLen, @@FrqLen
                   logf     @@AlphaA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   divf     @@AlphaA, @@GammaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   expf     @@AlphaA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   divf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   atgf     @@ResA, @@ResA, @@ExpLen, @@FrqLen
                   jc       @@retC
@@r:               movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
@@retC:            mov      sp, bp
                   pop      bp ax
                   retf     12
asnfproc           endp

asnf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr asnfproc
                   endm


acsfproc           proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 28
@@GammaA           equ      [bp-28]
@@DeltaA           equ      [bp-24]
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   sub      sp, ax
                   mov      @@GammaA[0], sp
                   mov      @@GammaA[2], ss
                   sub      sp, ax
                   mov      @@DeltaA[0], sp
                   mov      @@DeltaA[2], ss
                   movf     @@GammaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   subf     @@GammaA, @@p1A, @@ExpLen, @@FrqLen
                   flgx     @@GammaA, ax
                   jnz      @@ism1
                   czrf     @@ResA, @@ExpLen, @@FrqLen
                   jmp      @@r
@@ism1:            movf     @@GammaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   subf     @@GammaA, @@m1A, @@ExpLen, @@FrqLen
                   flgx     @@GammaA, ax
                   jnz      @@do
                   czrf     @@ResA, @@ExpLen, @@FrqLen
                   jmp      @@r
@@do:              movf     @@ResA, @@Op1Addr, @@ExpLen, @@FrqLen
                   movf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   mulf     @@AlphaA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@m1A, @@ExpLen, @@FrqLen
                   addf     @@AlphaA, @@p1A, @@ExpLen, @@FrqLen
                   cp2f     @@GammaA, @@ExpLen, @@FrqLen
                   logf     @@AlphaA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   divf     @@AlphaA, @@GammaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   expf     @@AlphaA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   divf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   actf     @@ResA, @@ResA, @@ExpLen, @@FrqLen
                   jc       @@retC
@@r:               movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
@@retC:            mov      sp, bp
                   pop      bp ax
                   retf     12
acsfproc           endp

acsf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr acsfproc
                   endm


facfproc           proc
                   push     cx ax bp
                   mov      bp, sp
@@disp             equ      03*02+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   sub      sp, 28
@@GammaA           equ      [bp-28]
@@DeltaA           equ      [bp-24]
@@BetaA            equ      [bp-20]
@@AlphaA           equ      [bp-16]
@@p1A              equ      [bp-12]
@@m1A              equ      [bp-08]
@@ResA             equ      [bp-04]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   sub      sp, ax
                   mov      @@p1A[0], sp
                   mov      @@p1A[2], ss
                   cp1f     @@p1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@m1A[0], sp
                   mov      @@m1A[2], ss
                   cm1f     @@m1A, @@ExpLen, @@FrqLen
                   sub      sp, ax
                   mov      @@BetaA[0], sp
                   mov      @@BetaA[2], ss
                   sub      sp, ax
                   mov      @@AlphaA[0], sp
                   mov      @@AlphaA[2], ss
                   sub      sp, ax
                   mov      @@ResA[0], sp
                   mov      @@ResA[2], ss
                   sub      sp, ax
                   mov      @@GammaA[0], sp
                   mov      @@GammaA[2], ss
                   sub      sp, ax
                   mov      @@DeltaA[0], sp
                   mov      @@DeltaA[2], ss
                   movf     @@ResA, @@p1A, @@ExpLen, @@FrqLen
                   flgx     @@Op1Addr, ax
                   jc       @@retC
                   jz       @@r
                   etof     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   mov      cx, @@FrqLen
                   dec      cx
@@c1:              subf     @@AlphaA, @@p1A, @@ExpLen, @@FrqLen
                   loop     @@c1
                   flgx     @@AlphaA, ax
                   jc       @@direct
                   movf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   cp2f     @@GammaA, @@ExpLen, @@FrqLen
                   divf     @@BetaA, @@GammaA, @@ExpLen, @@FrqLen
                   atff     @@AlphaA, @@p1A, @@ExpLen, @@FrqLen
                   addf     @@AlphaA, @@AlphaA, @@ExpLen, @@FrqLen
                   addf     @@AlphaA, @@AlphaA, @@ExpLen, @@FrqLen
                   addf     @@AlphaA, @@AlphaA, @@ExpLen, @@FrqLen
                   logf     @@AlphaA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@AlphaA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   subf     @@AlphaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   addf     @@BetaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   logf     @@ResA, @@Op1Addr, @@ExpLen, @@FrqLen
                   jc       @@retC
                   mulf     @@ResA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   addf     @@ResA, @@AlphaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   jmp      @@r
@@direct:          movf     @@ResA, @@p1A, @@ExpLen, @@FrqLen
                   movf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   movf     @@GammaA, @@Op1Addr, @@ExpLen, @@FrqLen
                   subf     @@GammaA, @@p1A, @@ExpLen, @@FrqLen
                   flgx     @@GammaA, ax
                   jc       @@ret
@@directc:         addf     @@BetaA, @@p1A, @@ExpLen, @@FrqLen
                   subf     @@GammaA, @@p1A, @@ExpLen, @@FrqLen
                   flgx     @@GammaA, ax
                   jc       @@ret
                   mulf     @@ResA, @@BetaA, @@ExpLen, @@FrqLen
                   jc       @@retC
                   jmp      @@directc
@@ret:             clc
@@r:               movf     @@Op0Addr, @@ResA, @@ExpLen, @@FrqLen
@@retC:            mov      sp, bp
                   pop      bp ax cx
                   retf     12
facfproc           endp

facf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr facfproc
                   endm


clrsproc           proc
                   pushf
                   push     ax bx bp ds
                   mov      bp, sp
@@disp             equ      02+04*02+04
@@StrA             equ      [bp+@@disp+00]
@@ImgMapA          equ      [bp+@@disp+04]
@@FrqLen           equ      [bp+@@disp+08]
                   mov      ax, @@FrqLen
                   add      ax, 2
                   setx     @@StrA, ax, 0
                   lds      bx, @@ImgMapA
                   mov      al, 13
                   xlat
                   xor      ah, ah
                   setx     @@StrA, @@FrqLen, ax
                   mov      ax, 0
                   xlat
                   or       ah, al
                   mov      al, 10
                   xlat
                   or       ah, al
                   lds      bx, @@StrA
                   mov      [bx], ah
                   pop      ds bp bx ax
                   popf
                   retf     10
clrsproc           endp

clrs               macro    StrA, ImgMapA, FrqLen
                   push     FrqLen
                   push     word ptr ImgMapA[2]
                   push     word ptr ImgMapA[0]
                   push     word ptr StrA[2]
                   push     word ptr StrA[0]
                   call     far ptr clrsproc
                   endm


inssproc           proc
                   pushf
                   push     ax bx bp ds
                   mov      bp, sp
@@disp             equ      02+04*02+04
@@StrA             equ      [bp+@@disp+00]
@@ImgMapA          equ      [bp+@@disp+04]
@@FrqLen           equ      [bp+@@disp+08]
@@Digit            equ      [bp+@@disp+10]
                   lds      bx, @@StrA
                   add      bx, @@FrqLen
                   cmp      byte ptr [bx+01], 0
                   jne      @@nonull
                   cmp      byte ptr @@Digit, 0
                   je       @@r
                   inc      byte ptr [bx+01]
                   lds      bx, @@ImgMapA
                   mov      al, @@Digit
                   xlat
                   mov      ah, al
                   mov      al, 10
                   xlat
                   or       ah, al
                   lds      bx, @@StrA
                   mov      [bx], ah
                   jmp      @@r
@@nonull:          mov      ax, @@FrqLen
                   dec      ax
                   cmp      al, [bx+01]
                   je       @@r
                   inc      byte ptr [bx+01]
                   cmp      byte ptr [bx], 0
                   jne      @@haspoint
                   lds      bx, @@ImgMapA
                   mov      al, 10
                   xlat
                   mov      ah, al
                   mov      al, @@Digit
                   xlat
                   or       al, ah
                   xor      ah, 0FFh
                   lds      bx, @@StrA
                   and      [bx], ah
                   salx     @@StrA, @@FrqLen
                   mov      [bx], al
                   jmp      @@r
@@haspoint:        inc      byte ptr [bx]
                   mov      al, [bx]
                   sub      al, 2
                   mov      ah, 0
                   lds      bx, @@StrA
                   add      bx, ax
                   mov      ah, [bx]
                   push     ds bx
                   lds      bx, @@ImgMapA
                   mov      al, 10
                   xlat
                   xor      al, 0FFh
                   and      ah, al
                   pop      bx ds
                   mov      [bx], ah
                   inc      bx
                   push     ds bx
                   salx     @@StrA, @@FrqLen
                   lds      bx, @@ImgMapA
                   mov      al, 10
                   xlat
                   mov      ah, al
                   mov      al, @@Digit
                   xlat
                   lds      bx, @@StrA
                   mov      [bx], al
                   pop      bx ds
                   or       [bx], ah
@@r:               pop      ds bp bx ax
                   popf
                   retf     12
inssproc           endp

inss               macro    StrA, ImgMapA, FrqLen, Digit
                   push     Digit
                   push     FrqLen
                   push     word ptr ImgMapA[2]
                   push     word ptr ImgMapA[0]
                   push     word ptr StrA[2]
                   push     word ptr StrA[0]
                   call     far ptr inssproc
                   endm


pntsproc           proc
                   pushf
                   push     ax bx bp ds
                   mov      bp, sp
@@disp             equ      02+04*02+04
@@StrA             equ      [bp+@@disp+00]
@@ImgMapA          equ      [bp+@@disp+04]
@@FrqLen           equ      [bp+@@disp+08]
                   lds      bx, @@StrA
                   add      bx, @@FrqLen
                   cmp      byte ptr [bx], 0
                   jne      @@r
                   inc      byte ptr [bx]
                   cmp      byte ptr [bx+01], 0
                   jne      @@r
                   inc      byte ptr [bx+01]
@@r:               pop      ds bp bx ax
                   popf
                   retf     10
pntsproc           endp

pnts               macro    StrA, ImgMapA, FrqLen
                   push     FrqLen
                   push     word ptr ImgMapA[2]
                   push     word ptr ImgMapA[0]
                   push     word ptr StrA[2]
                   push     word ptr StrA[0]
                   call     far ptr pntsproc
                   endm


delsproc           proc
                   pushf
                   push     ax bx bp ds
                   mov      bp, sp
@@disp             equ      02+04*02+04
@@StrA             equ      [bp+@@disp+00]
@@ImgMapA          equ      [bp+@@disp+04]
@@FrqLen           equ      [bp+@@disp+08]
                   lds      bx, @@StrA
                   add      bx, @@FrqLen
                   cmp      byte ptr [bx+01], 0
                   je       @@r
                   cmp      byte ptr [bx+01], 1
                   jne      @@shft
                   clrs     @@StrA, @@ImgMapA, @@FrqLen
                   jmp      @@r
@@shft:            dec      byte ptr [bx+01]
                   sarx     @@StrA, @@FrqLen
                   lds      bx, @@ImgMapA
                   mov      al, 10
                   xlat
                   mov      ah, al
                   mov      al, 13
                   xlat
                   lds      bx, @@StrA
                   add      bx, @@FrqLen
                   mov      [bx-01], al
                   mov      al, 0
                   cmp      al, [bx]
                   je       @@setpnt
                   dec      byte ptr [bx]
                   jmp      @@r
@@setpnt:          lds      bx, @@StrA
                   or       [bx], ah
@@r:               pop      ds bp bx ax
                   popf
                   retf     10
delsproc           endp

dels               macro    StrA, ImgMapA, FrqLen
                   push     FrqLen
                   push     word ptr ImgMapA[2]
                   push     word ptr ImgMapA[0]
                   push     word ptr StrA[2]
                   push     word ptr StrA[0]
                   call     far ptr delsproc
                   endm


invfproc           proc
                   pushf
                   push     ax bp ds di
                   mov      bp, sp
@@disp             equ      02+02*04+04
@@Op0Addr          equ      [bp+@@disp+00]
@@Op1Addr          equ      [bp+@@disp+04]
@@ExpLen           equ      [bp+@@disp+08]
@@FrqLen           equ      [bp+@@disp+10]
                   mov      ax, @@ExpLen
                   add      ax, @@FrqLen
                   movf     @@Op0Addr, @@Op1Addr, @@ExpLen, @@FrqLen
                   flgx     @@Op0Addr, ax
                   jz       @@r
                   lds      di, @@Op0Addr
                   add      di, ax
                   cmp      byte ptr [di-01], 0
                   je       @@setMinus
                   mov      byte ptr [di-01], 0
                   jmp      @@r
@@setMinus:        mov      byte ptr [di-01], 9
@@r:               pop      di ds bp ax
                   popf
                   retf     12
invfproc           endp

invf               macro    Op0Addr, Op1Addr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr Op1Addr[2]
                   push     word ptr Op1Addr[0]
                   push     word ptr Op0Addr[2]
                   push     word ptr Op0Addr[0]
                   call     far ptr invfproc
                   endm


stofproc           proc
                   pushf
                   push     ax bx cx bp ds di es
                   mov      bp, sp
@@disp             equ      02+07*02+04
@@StrA             equ      [bp+@@disp+00]
@@ImgMapA          equ      [bp+@@disp+04]
@@OpAddr           equ      [bp+@@disp+08]
@@ExpLen           equ      [bp+@@disp+12]
@@FrqLen           equ      [bp+@@disp+14]
                   sub      sp, 04
@@FrqA             equ      [bp-04]
                   lds      di, @@OpAddr
                   add      di, @@ExpLen
                   mov      @@FrqA[0], di
                   mov      @@FrqA[2], ds
                   czrf     @@OpAddr, @@ExpLen, @@FrqLen
                   les      si, @@StrA
                   add      si, @@FrqLen
                   cmp      word ptr es:[si], 0
                   je       @@r
                   pnts     @@StrA, @@ImgMapA, @@FrqLen
                   mov      cx, @@FrqLen
@@c1:              inss     @@StrA, @@ImgMapA, @@FrqLen, 0
                   loop     @@c1
                   lds      bx, @@ImgMapA
                   mov      al, 10
                   xlat
                   xor      al, 0FFh
                   mov      cx, @@FrqLen
                   dec      cx
                   les      si, @@StrA
@@c2:              and      es:[si], al
                   inc      si
                   loop     @@c2
                   mov      cx, @@FrqLen
                   dec      cx
                   les      si, @@StrA
@@c3:              push     cx
                   mov      ah, 0
                   mov      cx, 10
@@c3sub:           mov      al, ah
                   xlat
                   cmp      al, es:[si]
                   je       @@cont3
                   inc      ah
                   loop     @@c3sub
@@cont3:           mov      es:[si], ah
                   pop      cx
                   inc      si
                   loop     @@c3
                   mov      ax, @@FrqLen
                   dec      ax
                   flgx     @@StrA, ax
                   jz       @@r
                   movx     @@FrqA, @@StrA, @@FrqLen
                   les      si, @@StrA
                   add      si, @@FrqLen
                   mov      al, es:[si+01]
                   sub      al, es:[si]
                   xor      ah, ah
                   mov      cx, ax
                   inc      cx
@@c4:              incx     @@OpAddr, @@ExpLen
                   loop     @@c4
                   les      si, @@FrqA
                   add      si, @@FrqLen
                   sub      si, 2
@@norm:            cmp      byte ptr es:[si], 0
                   jne      @@r
                   salx     @@FrqA, @@FrqLen
                   decx     @@OpAddr, @@ExpLen
                   jmp      @@norm
@@r:               mov      sp, bp
                   pop      es di ds bp cx bx ax
                   popf
                   retf     16
stofproc           endp


stof               macro    StrA, ImgMapA, OpAddr, ExpLen, FrqLen
                   push     FrqLen
                   push     ExpLen
                   push     word ptr OpAddr[2]
                   push     word ptr OpAddr[0]
                   push     word ptr ImgMapA[2]
                   push     word ptr ImgMapA[0]
                   push     word ptr StrA[2]
                   push     word ptr StrA[0]
                   call     far ptr stofproc
                   endm


initproc           proc
                   mov      Key, KEY_END
                   mov      Last2Op, KEY_EQU
                   mov      Flags, FLG_AOP1+FLG_MEM1
                   mov      Format, FMT_XX
                   czrf     cs:Op1A, @EXPLEN, @FRQLEN
                   czrf     cs:Op2A, @EXPLEN, @FRQLEN
                   czrf     cs:Mem1A, @EXPLEN, @FRQLEN
                   czrf     cs:Mem2A, @EXPLEN, @FRQLEN
                   clrs     cs:StrA, cs:ImgMapA, @FRQLEN
                   retf
initproc           endp

init               macro
                   call     far ptr initproc
                   endm


visualizeproc      proc
                   push     ax bx ds di
                   mov      ax, Flags
                   and      ax, not FLG_SIGN
                   mov      Flags, ax
                   test     ax, FLG_OVRF
                   jz       @@show
                   clrs     cs:StrA, cs:ImgMapA, @FRQLEN
                   lds      bx, cs:ImgMapA
                   mov      al, 12
                   xlat
                   lds      di, cs:StrA
                   mov      [di], al
                   jmp      @@r
@@show:            test     ax, FLG_ASTR
                   jz       @@showOp1
@@ifs:             lds      di, cs:StrA
                   add      di, @FRQLEN
                   cmp      byte ptr [di-01], 0
                   jne      @@setsign
                   jmp      @@r
@@showOp1:         test     ax, FLG_AOP1
                   jz       @@showOp2
                   ftos     cs:StrA, cs:ImgMapA, cs:Op1A, @EXPLEN, @FRQLEN
                   fmts     cs:StrA, cs:ImgMapA, @FRQLEN, Format
                   jmp      @@ifs
@@showOp2:         ftos     cs:StrA, cs:ImgMapA, cs:Op2A, @EXPLEN, @FRQLEN
                   fmts     cs:StrA, cs:ImgMapA, @FRQLEN, Format
                   jmp      @@ifs
@@setsign:         or       ax, FLG_SIGN
                   mov      Flags, ax
@@r:               pop      di ds bx ax
                   retf
visualizeproc      endp

visualize          macro
                   call     far ptr visualizeproc
                   endm


showproc           proc
                   pushf
                   push     ax cx dx es si
                   mov      ax, Flags
                   out      PRT_FLG, al
                   les      si, cs:StrA
                   mov      cx, @FRQLEN
                   dec      cx
                   mov      dx, PRT_DGT
@@c:               mov      al, es:[si]
                   out      dx, al
                   inc      dx
                   inc      si
                   loop     @@c
                   pop      si es dx cx ax
                   popf
                   retf
showproc           endp

show               macro
                   call     far ptr showproc
                   endm


waitkeyproc        proc
                   push     ax bx
                   mov      bx, Key
@@newcicle:        mov      di, 0
                   mov      Key, bx
@@next:            mov      bx, cs:KeyMap.keycode[di]
                   show
                   cmp      cs:KeyMap.keycode[di], KEY_END
                   je       @@newcicle
                   mov      al, cs:KeyMap.outmask[di]
                   out      PRT_KB, al
                   in       al, PRT_KB
                   test     al, cs:KeyMap.testmask[di]
                   jz       @@prepnext
                   cmp      bx, Key
                   je       @@newcicle
                   mov      Key, bx
                   jmp      @@r
@@prepnext:        add      di, size keyinfo
                   jmp      @@next
@@r:               pop      bx ax
                   retf
waitkeyproc        endp

waitkey            macro
                   call     far ptr waitkeyproc
                   endm


findexeproc        proc
                   pushf
                   push     ax bp di
                   mov      bp, sp
@@disp             equ      02+03*02+04
@@KeyCode          equ      [bp+@@disp+00]
@@OffReg           equ      [bp+@@disp+00]
                   mov      ax, @@KeyCode
                   mov      di, 0
@@c:               cmp      cs:ExeMap[di].keycode, KEY_END
                   je       @@e
                   cmp      cs:ExeMap[di].keycode, ax
                   je       @@e
                   add      di, size exeinfo
                   jmp      @@c
@@e:               mov      @@OffReg, di
                   pop      di bp ax
                   popf
                   retf
findexeproc        endp

findexe            macro    KeyCode, OffReg
                   push     KeyCode
                   call     far ptr findexeproc
                   pop      OffReg
                   endm


pushparproc        proc
                   pushf
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02+02*02+04
@@ParCode          equ      [bp+@@disp+00]
@@LoWord           equ      [bp+@@disp+00]
@@HiWord           equ      [bp+@@disp+02]
                   cmp      word ptr @@ParCode, @Non
                   je       @@retEMPTY
                   cmp      word ptr @@ParCode, @AcA
                   jne      @@ifAcF
@@1:               test     Flags, FLG_ASTR
                   jz       @@2
                   mov      ax, word ptr cs:StrA[0]
                   mov      @@LoWord, ax
                   mov      ax, word ptr cs:StrA[2]
                   mov      @@HiWord, ax
                   jmp      @@retDWORD
@@2:               test     Flags, FLG_AOP1
                   jz       @@3
                   mov      ax, word ptr cs:Op1A[0]
                   mov      @@LoWord, ax
                   mov      ax, word ptr cs:Op1A[2]
                   mov      @@HiWord, ax
                   jmp      @@retDWORD
@@3:               test     Flags, FLG_AOP2
                   jz       @@retEMPTY
                   mov      ax, word ptr cs:Op2A[0]
                   mov      @@LoWord, ax
                   mov      ax, word ptr cs:Op2A[2]
                   mov      @@HiWord, ax
                   jmp      @@retDWORD
@@ifAcF:           cmp      word ptr @@ParCode, @AcF
                   jne      @@ifAcE
                   mov      word ptr @@HiWord, @FRQLEN
                   jmp      @@retWORD
@@ifAcE:           cmp      word ptr @@ParCode, @AcE
                   jne      @@ifOp1
                   test     Flags, FLG_ASTR
                   jz       @@4
                   jmp      @@retEMPTY
@@4:               mov      word ptr @@HiWord, @EXPLEN
                   jmp      @@retWORD
@@ifOp1:           cmp      word ptr @@ParCode, @Op1
                   jne      @@ifOp2
                   mov      ax, word ptr cs:Op1A[0]
                   mov      @@LoWord, ax
                   mov      ax, word ptr cs:Op1A[2]
                   mov      @@HiWord, ax
                   jmp      @@retDWORD
@@ifOp2:           cmp      word ptr @@ParCode, @Op2
                   jne      @@ifMem
                   mov      ax, word ptr cs:Op2A[0]
                   mov      @@LoWord, ax
                   mov      ax, word ptr cs:Op2A[2]
                   mov      @@HiWord, ax
                   jmp      @@retDWORD
@@ifMem:           cmp      word ptr @@ParCode, @Mem
                   jne      @@ifImg
                   test     Flags, FLG_MEM1
                   jz       @@5
                   mov      ax, word ptr cs:Mem1A[0]
                   mov      @@LoWord, ax
                   mov      ax, word ptr cs:Mem1A[2]
                   mov      @@HiWord, ax
                   jmp      @@retDWORD
@@5:               mov      ax, word ptr cs:Mem2A[0]
                   mov      @@LoWord, ax
                   mov      ax, word ptr cs:Mem2A[2]
                   mov      @@HiWord, ax
                   jmp      @@retDWORD
@@ifImg:           cmp      word ptr @@ParCode, @Img
                   jne      @@retEMPTY
                   mov      ax, word ptr cs:ImgMapA[0]
                   mov      @@LoWord, ax
                   mov      ax, word ptr cs:ImgMapA[2]
                   mov      @@HiWord, ax
                   jmp      @@retDWORD
@@retEMPTY:        pop      bp ax
                   popf
                   retf     4
@@retWORD:         pop      bp ax
                   popf
                   retf     2
@@retDWORD:        pop      bp ax
                   popf
                   retf     0
pushparproc        endp

pushpar            macro    ParCode
                   push     ParCode
                   push     ParCode
                   call     far ptr pushparproc
                   endm


frontproc          proc
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02*02+04
@@OldState         equ      [bp+@@disp+00]
@@State            equ      [bp+@@disp+02]
@@BitMask          equ      [bp+@@disp+04]
                   mov      ax, @@OldState
                   not      ax
                   and      ax, @@State
                   and      ax, @@BitMask
                   pop      bp ax
                   retf     6
frontproc          endp

front              macro    OldState, State, BitMask
                   push     BitMask
                   push     State
                   push     OldState
                   call     far ptr frontproc
                   endm


chgfproc           proc
                   pushf
                   push     ax bp
                   mov      bp, sp
@@disp             equ      02+02*02+04
@@NewFormat        equ      [bp+@@disp+00]
                   mov      ax, @@NewFormat
                   mov      Format, ax
                   pop      bp ax
                   popf
                   retf
chgfproc           endp

chgf               macro    NewFormat
                   push     NewFormat
                   call     far ptr chgfproc
                   endm


clrmproc           proc
                   pushf
                   push     ax
                   mov      ax, Flags
                   test     ax, FLG_MEM1
                   jz       @@m2
                   setx     cs:Mem1A, <@EXPLEN+@FRQLEN>, 0
                   jmp      @@r
@@m2:              setx     cs:Mem2A, <@EXPLEN+@FRQLEN>, 0
@@r:               pop      ax
                   popf
                   retf
clrmproc           endp

clrm               macro
                   call     far ptr clrmproc
                   endm


executeproc        proc
                   push     ax bp di
                   mov      bp, sp
                   findexe  Key, di
                   cmp      cs:ExeMap[di].keycode, KEY_END
                   je       @@e
                   mov      ax, cs:ExeMap[di].flgoff1
                   not      ax
                   and      ax, Flags
                   test     ax, FLG_OVRF
                   jnz      @@e
                   cmp      cs:ExeMap[di].opcount, 2
                   jne      @@run
                   findexe  Last2Op, di
                   mov      ax, Key
                   mov      Last2Op, ax
@@run:             mov      ax, cs:ExeMap[di].flgoff1
                   not      ax
                   and      ax, Flags
                   xchg     ax, Flags
                   front    Flags, ax, FLG_ASTR
                   jz       @@up2
                   stof     cs:StrA, cs:ImgMapA, cs:Op2A, @EXPLEN, @FRQLEN
@@up2:             front    Flags, ax, FLG_OVRF
                   jz       @@up
                   clrs     cs:StrA, cs:ImgMapA, @FRQLEN
@@up:              mov      ax, Flags
                   or       ax, cs:ExeMap[di].flgon1
                   xchg     ax, Flags
                   front    ax, Flags, FLG_ASTR
                   jz       @@exec
                   clrs     cs:StrA, cs:ImgMapA, @FRQLEN
@@exec:            push     cs:ExeMap[di].value
                   pushpar  cs:ExeMap[di].param2
                   pushpar  cs:ExeMap[di].param1
                   pushpar  cs:ExeMap[di].addr2
                   pushpar  cs:ExeMap[di].addr1
                   or       Flags, FLG_OVRF
                   clc
                   call     cs:ExeMap[di].execproc
                   jc       @@e
                   mov      ax, not FLG_OVRF
                   and      Flags, ax
                   mov      ax, cs:ExeMap[di].flgoff2
                   not      ax
                   and      Flags, ax
                   mov      ax, cs:ExeMap[di].flgon2
                   or       Flags, ax
@@e:               mov      sp, bp
                   pop      di bp ax
                   retf
executeproc        endp

execute            macro
                   call     far ptr executeproc
                   endm


Start:             mov      ax, Data
                   mov      ds, ax
                   mov      es, ax
                   mov      ss, ax
                   lea      sp, StkTop

                   init
WorkCicle:         visualize
                   waitkey
                   execute
                   jmp      WorkCicle


ImageMap           db       3Fh, 0Ch, 76h, 5Eh, 4Dh, 5Bh, 7Bh, 0Eh, 7Fh, 5Fh
                   db       80h, 40h, 73h, 00h; '.', '-', 'E', ' '

Op1A               dd       Op1
Op2A               dd       Op2
Mem1A              dd       Mem1
Mem2A              dd       Mem2
StrA               dd       StrBuf
ImgMapA            dd       ImageMap

KeyMap             label
keyinfo  <KEY_0  , 20h, 08h>
keyinfo  <KEY_1  , 04h, 08h>
keyinfo  <KEY_2  , 04h, 04h>
keyinfo  <KEY_3  , 04h, 02h>
keyinfo  <KEY_4  , 08h, 08h>
keyinfo  <KEY_5  , 08h, 04h>
keyinfo  <KEY_6  , 08h, 02h>
keyinfo  <KEY_7  , 10h, 08h>
keyinfo  <KEY_8  , 10h, 04h>
keyinfo  <KEY_9  , 10h, 02h>
keyinfo  <KEY_PNT, 20h, 04h>
keyinfo  <KEY_DEL, 10h, 10h>
keyinfo  <KEY_CLR, 08h, 10h>
keyinfo  <KEY_SGN, 20h, 10h>
keyinfo  <KEY_EQU, 20h, 02h>
keyinfo  <KEY_ADD, 04h, 01h>
keyinfo  <KEY_SUB, 08h, 01h>
keyinfo  <KEY_MUL, 10h, 01h>
keyinfo  <KEY_DIV, 20h, 01h>
keyinfo  <KEY_POW, 01h, 01h>
keyinfo  <KEY_SIN, 01h, 20h>
keyinfo  <KEY_COS, 01h, 10h>
keyinfo  <KEY_TAN, 01h, 08h>
keyinfo  <KEY_COT, 01h, 04h>
keyinfo  <KEY_EXP, 01h, 02h>
keyinfo  <KEY_LOG, 02h, 02h>
keyinfo  <KEY_ASN, 02h, 20h>
keyinfo  <KEY_ACS, 02h, 10h>
keyinfo  <KEY_ATG, 02h, 08h>
keyinfo  <KEY_ACT, 02h, 04h>
keyinfo  <KEY_FAC, 02h, 01h>
keyinfo  <KEY_FXX, 04h, 20h>
keyinfo  <KEY_FX5, 08h, 20h>
keyinfo  <KEY_FX2, 10h, 20h>
keyinfo  <KEY_FX0, 20h, 20h>
keyinfo  <KEY_M1 , 01h, 40h>
keyinfo  <KEY_M2 , 02h, 40h>
keyinfo  <KEY_MC , 04h, 40h>
keyinfo  <KEY_MS , 08h, 40h>
keyinfo  <KEY_MP , 10h, 40h>
keyinfo  <KEY_MR , 20h, 40h>
keyinfo  <KEY_CE , 04h, 10h>
keyinfo  <KEY_END, 0, 0>

ExeMap             label
exeinfo  <KEY_CE, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, Start, 0, 0, 0, 0, 0>
exeinfo  <KEY_0, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, inssproc, @AcA, @Img, @AcE, @AcF, 0>
exeinfo  <KEY_1, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, inssproc, @AcA, @Img, @AcE, @AcF, 1>
exeinfo  <KEY_2, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, inssproc, @AcA, @Img, @AcE, @AcF, 2>
exeinfo  <KEY_3, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, inssproc, @AcA, @Img, @Non, @AcF, 3>
exeinfo  <KEY_4, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, inssproc, @AcA, @Img, @AcE, @AcF, 4>
exeinfo  <KEY_5, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, inssproc, @AcA, @Img, @AcE, @AcF, 5>
exeinfo  <KEY_6, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, inssproc, @AcA, @Img, @AcE, @AcF, 6>
exeinfo  <KEY_7, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, inssproc, @AcA, @Img, @AcE, @AcF, 7>
exeinfo  <KEY_8, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, inssproc, @AcA, @Img, @AcE, @AcF, 8>
exeinfo  <KEY_9, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, inssproc, @AcA, @Img, @AcE, @AcF, 9>
exeinfo  <KEY_PNT, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, pntsproc, @AcA, @Img, @AcE, @AcF, 0>
exeinfo  <KEY_DEL, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, delsproc, @AcA, @Img, @AcE, @AcF, 0>
exeinfo  <KEY_CLR, 1, FLG_OVRF+FLG_AOP1, FLG_AOP2+FLG_ASTR, 0, 0, clrsproc, @AcA, @Img, @AcE, @AcF, 0>
exeinfo  <KEY_SGN, 1, 0, 0, 0, 0, invfproc, @AcA, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_EQU, 2, FLG_ASTR, 0, FLG_AOP2, FLG_AOP1, movfproc, @Op1, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_ADD, 2, FLG_ASTR, 0, FLG_AOP2, FLG_AOP1, addfproc, @Op1, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_SUB, 2, FLG_ASTR, 0, FLG_AOP2, FLG_AOP1, subfproc, @Op1, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_MUL, 2, FLG_ASTR, 0, FLG_AOP2, FLG_AOP1, mulfproc, @Op1, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_DIV, 2, FLG_ASTR, 0, FLG_AOP2, FLG_AOP1, divfproc, @Op1, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_POW, 2, FLG_ASTR, 0, FLG_AOP2, FLG_AOP1, powfproc, @Op1, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_SIN, 1, FLG_ASTR, 0, 0, 0, sinfproc, @AcA, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_COS, 1, FLG_ASTR, 0, 0, 0, cosfproc, @AcA, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_TAN, 1, FLG_ASTR, 0, 0, 0, tanfproc, @AcA, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_COT, 1, FLG_ASTR, 0, 0, 0, cotfproc, @AcA, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_EXP, 1, FLG_ASTR, 0, 0, 0, expfproc, @AcA, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_LOG, 1, FLG_ASTR, 0, 0, 0, logfproc, @AcA, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_ASN, 1, FLG_ASTR, 0, 0, 0, asnfproc, @AcA, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_ACS, 1, FLG_ASTR, 0, 0, 0, acsfproc, @AcA, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_ATG, 1, FLG_ASTR, 0, 0, 0, atgfproc, @AcA, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_ACT, 1, FLG_ASTR, 0, 0, 0, actfproc, @AcA, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_FAC, 1, FLG_ASTR, 0, 0, 0, facfproc, @AcA, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_FXX, 1, FLG_ASTR+FLG_FTX0+FLG_FTX2+FLG_FTX5, 0, 0, 0, chgfproc, @Non, @Non, @Non, @Non, FMT_XX>
exeinfo  <KEY_FX5, 1, FLG_ASTR+FLG_FTX0+FLG_FTX2, FLG_FTX5, 0, 0, chgfproc, @Non, @Non, @Non, @Non, FMT_X5>
exeinfo  <KEY_FX2, 1, FLG_ASTR+FLG_FTX0+FLG_FTX5, FLG_FTX2, 0, 0, chgfproc, @Non, @Non, @Non, @Non, FMT_X2>
exeinfo  <KEY_FX0, 1, FLG_ASTR+FLG_FTX5+FLG_FTX2, FLG_FTX0, 0, 0, chgfproc, @Non, @Non, @Non, @Non, FMT_X0>
exeinfo  <KEY_M1, 1, FLG_MEM2, FLG_MEM1, 0, 0, movfproc, @Mem, @Mem, @AcE, @AcF, 0>
exeinfo  <KEY_M2, 1, FLG_MEM1, FLG_MEM2, 0, 0, movfproc, @Mem, @Mem, @AcE, @AcF, 0>
exeinfo  <KEY_MC, 1, 0, 0, 0, 0, clrmproc, @Non, @Non, @Non, @Non, 0>
exeinfo  <KEY_MS, 1, FLG_ASTR, 0, 0, 0, movfproc, @Mem, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_MP, 1, FLG_ASTR, 0, 0, 0, addfproc, @Mem, @AcA, @AcE, @AcF, 0>
exeinfo  <KEY_MR, 1, FLG_ASTR+FLG_AOP1, FLG_AOP2, 0, 0, movfproc, @AcA, @Mem, @AcE, @AcF, 0>
exeinfo  <KEY_END, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>


                   org      03FF0h
                   assume   cs:nothing
                   jmp      far ptr Start
Code               ends
                   end