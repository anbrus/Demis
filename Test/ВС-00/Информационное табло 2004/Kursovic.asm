.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

Data       SEGMENT AT 40h use16
;Здесь размещаются описания переменных
cek        db    ?
MUH        db    ?
O4ACbl     DB    ?
ADPEC      DW    ?
UDEHT      DB    ?
BEPX       DB    ?
FlMuHyC    db    ?
Gpadyc     dd    ?
C4ET4UK    DB    ?
Flnepekjl  db    ?
BPC4       db    ?
flag3      db    ?
flag5      db    ?
nojle      db    ?
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 40h use16
;Задайте необходимый размер стека
           org   20h
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data
dreb       proc       ;защита от дребезга
Dreb_Met1: mov   ah, al
           mov   bh, 0
Dreb_Met2: in    al, dx
           cmp   ah, al
           jne   Dreb_Met1
           inc   bh
           cmp   bh, 50
           jne   Dreb_Met2
           mov   al, ah
           ret
dreb       endp 

CYMMA      PROC
           mov   ah,al
           SHR   AH,4
           add   aL,1
           aaa
           SHL   AH,4
           ADD   AL,AH           
           RET
CYMMA      ENDP

PA3HOCTb   PROC
           mov   ah,al
           SHR   AH,4
           sub   aL,1
           aas
           SHL   AH,4
           ADD   AL,AH           
           RET
PA3HOCTb   ENDP

nEPEXOD    PROC
           AND   DL,0FH
           SHL   DL,2
           XOR   DH,DH
           MOV   ADPEC,dX
           RET
nEPEXOD    ENDP

BblBOD     PROC
           call  COCTKH
           MOV   UDEHT,4
           MOV   SI,ADPEC
           MOV   AL,BEPX
           OUT   0,AL
a1:        
           MOV   AL,UDEHT
           SHL   UDEHT,1
           OUT   2,AL
           
           MOV   AL,O6PA3A[SI]
           OUT   1,AL
           
           XOR   AL,AL
           OUT   1,AL
           
           INC   SI
           CMP   UDEHT,64
           JNZ   A1
           RET
BblBOD     ENDP

BPEM9l     proc  
           mov   al,cek
           mov   ah,al
           SHR   AH,4
           add   aL,1
           aaa
           SHL   AH,4
           ADD   AL,AH
           MOV   CEK,AL
           cmp   aL,60h
           jnz   exit
           mov   cek,0
           mov   al,MUH
           mov   ah,al
           SHR   AH,4
           add   aL,1
           aaa
           SHL   AH,4
           ADD   AL,AH
           MOV   MUH,AL
           cmp   aL,60h
           jnz   exit
           mov   MUH,0
           mov   al,O4ACbl
           mov   ah,al
           SHR   AH,4
           add   aL,1
           aaa
           SHL   AH,4
           ADD   AL,AH
           MOV   O4ACbl,AL
           cmp   aL,24h
           jnz   exit
           mov   O4ACbl,0
EXIT:      ret
BPEM9l     endp

Out_Clock  proc  
           MOV   DL,CEK
           CALL  nEPEXOD
           MOV   BEPX,1
           CALL  BblBOD
           MOV   DL,CEK
           SHR   DL,4
           CALL  nEPEXOD
           SHL   BEPX,1
           CALL  BblBOD
           xor   al,al
           out   2,al
           mov   al,22h
           out   1,al
           mov   al,1b
           out   2,al
           xor   al,al
           out   1,al
           MOV   DL,MUH
           CALL  nEPEXOD
           SHL   BEPX,1
           CALL  BblBOD
           xor   al,al
           out   2,al
           mov   al,22h
           out   1,al
           mov   al,10000000b
           out   2,al
           xor   al,al
           out   1,al
           MOV   DL,MUH
           SHR   DL,4
           CALL  nEPEXOD
           SHL   BEPX,1
           CALL  BblBOD
           xor   al,al
           out   2,al
           mov   al,22h
           out   1,al
           mov   al,1b
           out   2,al
           xor   al,al
           out   1,al
           MOV   DL,O4ACbl
           CALL  nEPEXOD
           SHL   BEPX,1
           CALL  BblBOD
           xor   al,al
           out   2,al
           mov   al,22h
           out   1,al
           mov   al,10000000b
           out   2,al
           xor   al,al
           out   1,al
           MOV   DL,O4ACbl
           SHR   DL,4
           CALL  nEPEXOD
           SHL   BEPX,1
           CALL  BblBOD
           ret
Out_Clock  endp

O6pa6_ALLn proc  
           mov   al,40h
           out   0,al
qw:        in    al,3
           test  ax,1
           jz    qw
           in    al,1
           mov   ah,al
           in    al,0
           mov   cx,800
           mul   cx
           mov   cx,0ffffh
           div   cx
           sub   ax,400
           cmp   ax,0
           jge   wert
           mov   flMuHyC,0ffh
           neg   ax
wert:      
           xor   dx,dx
           mov   cx,10
           div   cx
           mov   byte ptr Gpadyc,dL
           xor   dx,dx
           div   cx
           MOV   byte ptr Gpadyc+1,dl
           xor   dx,dx
           div   cx
           MOV   byte ptr Gpadyc+2,dL
           ret
O6pa6_ALLn endp

Out_ALLn   proc
           MOV   ADPEC,40
           MOV   BEPX,1
           CALL  BblBOD
           MOV   ADPEC,44
           SHL   BEPX,1
           CALL  BblBOD
           MOV   DL,byte ptr Gpadyc
           CALL  nEPEXOD
           SHL   BEPX,1
           CALL  BblBOD
           xor   al,al
           out   2,al
           mov   al,40h
           out   1,al
           mov   al,1
           out   2,al
           xor   al,al
           out   1,al
           MOV   DL,byte ptr Gpadyc+1
           CALL  nEPEXOD
           SHL   BEPX,1
           CALL  BblBOD
           MOV   DL,byte ptr Gpadyc+2
           CALL  nEPEXOD
           SHL   BEPX,1
           CALL  BblBOD
           cmp   FlMuHyC,0ffh
           jnZ   exi
           MOV   ADPEC,48
           SHL   BEPX,1
           CALL  BblBOD
exi:       mov   flMuHyC,0
           ret
Out_ALLn   endp

KHOnKA1    PROC  FAR
           cmp   flag3,0ffh
           jnz   Kf1
           jmp   K1_4acbl
kf1:       cmp   flag5,0ffh
           jnz   k1_ret
           mov   al,BPC4
           CALL  CYMMA
           MOV   BPC4,AL
           cmp   aL,61h
           jnz   k1_ret
           mov   BPC4,1
           jmp   k1_ret
K1_4acbl:  cmp   nojle,1
           jnz   k1_1
           mov   al,cek
           CALL  CYMMA
           MOV   CEK,AL
           cmp   aL,60h
           jnz   k1_ret
           mov   cek,0
           jmp   k1_ret
k1_1:      cmp   nojle,2
           jnz   k1_2
           mov   al,MUH
           CALL  CYMMA
           MOV   MUH,AL
           cmp   aL,60h
           jnz   k1_ret
           mov   MUH,0
           jmp   k1_ret
k1_2:      cmp   nojle,3
           jnz   k1_ret
           mov   al,O4ACbl
           CALL  CYMMA
           MOV   O4ACbl,AL
           cmp   aL,24h
           jnz   k1_ret
           mov   O4ACbl,0
k1_ret:    in    al, 2
           test  al, 01h
           jnz   K1_ret
           call  dreb
           test  al, 01h
           jnz   K1_ret
           RET
KHOnKA1    ENDP

KHOnKA2    PROC  FAR
           cmp   flag3,0ffh
           jnz   Kf2
           jmp   K2_4acbl
kf2:       cmp   flag5,0ffh
           jnz   k2_ret
           mov   al,BPC4
           CALL  PA3HOCTb
           MOV   BPC4,AL
           cmp   aL,0h
           jnz   k2_ret
           mov   BPC4,60H
           jmp   k2_ret
K2_4acbl:  cmp   nojle,1
           jnz   k2_1
           mov   al,cek
           CALL  PA3HOCTb
           MOV   CEK,AL
           cmp   ah,0f0h
           jnz   k2_ret
           mov   cek,59h
           jmp   k2_ret
k2_1:      cmp   nojle,2
           jnz   k2_2
           mov   al,MUH
           CALL  PA3HOCTb
           MOV   MUH,AL
           cmp   ah,0f0h
           jnz   k2_ret
           mov   MUH,59h
           jmp   k2_ret
k2_2:      cmp   nojle,3
           jnz   k2_ret
           mov   al,O4ACbl
           CALL  PA3HOCTb
           MOV   O4ACbl,AL
           cmp   ah,0f0h
           jnz   k2_ret
           mov   O4ACbl,23h
k2_ret:    in    al,2
           test  al, 2h
           jnz   K2_ret
           call  dreb
           test  al,2h
           jnz   K2_ret
           RET
KHOnKA2    ENDP

KHOnKA3    PROC  
           not   flag3
           mov   flag5,0
           cmp   flag3,0ffh
           jnz   k3_ret
           mov   nojle,1
           mov   al,1
           out   3,al
k3_ret:    cmp   Flag3,0h
           jnz    k3_ret1
           xor   al,al
           out   3,al
k3_ret1:   in    al, 2
           test  al, 04h
           jnz   K3_ret1
           call  dreb
           test  al, 04h
           jnz   K3_ret1
           RET
KHOnKA3    ENDP

KHOnKA4    PROC  FAR
           CMP   flag5,0ffh
           jnz    K4_fl
k5_fl:     mov   al,0
           out   3,al
           jmp   k4_ret1
k4_fl:     cmp   flag3,0ffh
           jnz   k5_fl
           inc   nojle
           cmp   nojle,4
           jnz   K4_ret
           mov   nojle,1
K4_ret:    cmp   nojle,1
           jnz   K4_1
           mov   al,1
           out   3,al
K4_1:      cmp   nojle,2
           jnz   K4_2
           mov   al,2
           out   3,al
K4_2:      cmp   nojle,3
           jnz   K4_ret1
           mov   al,4
           out   3,al
K4_ret1:   in    al, 2
           test  al, 08h
           jnz   K4_ret1
           call  dreb
           test  al, 08h
           jnz   K4_ret1
           RET
KHOnKA4    ENDP

KHOnKA5    PROC  NEAR
           not   flag5
           mov   flag3,0
           xor   al,al
           out   3,al
k5_ret:    
           cmp   Flag5,0
           jnz   k5_ret1
           xor   al,al
           out   3,al
k5_ret1:   in    al, 2
           test  al,10h
           jnz   K5_ret1
           call  dreb
           test  al,10h
           jnz   K5_ret1
           RET
KHOnKA5    ENDP

COCTKH     PROC  
           IN    AL,2
           TEST  AL,1B
           JZ    KH_1
           CALL  KHOnKA1
           JMP   KH_RET
KH_1:      TEST  AL,10B
           JZ    KH_2
           CALL  KHOnKA2
           JMP   KH_RET
KH_2:      TEST  AL,100B
           JZ    KH_3
           CALL  KHOnKA3
           JMP   KH_RET
KH_3:      TEST  AL,1000B
           JZ    KH_4
           CALL  KHOnKA4
           JMP   KH_RET
KH_4:      TEST  AL,10000B
           JZ    KH_RET
           CALL  KHOnKA5
           JMP   KH_RET
KH_RET:    RET
COCTKH     ENDP

nepek      proc  
           MOV   dL,BPC4
           mov   C4ET4UK,dl
           CALL  nEPEXOD
           MOV   BEPX,1
           CALL  BblBOD
           MOV   dL,BPC4
           SHR   dL,4
           CALL  nEPEXOD
           SHL   BEPX,1
           CALL  BblBOD
           ret
nepek      endp

UHUC       PROC 
           MOV   CEK,0
           MOV   MUH,0
           MOV   O4ACbl,0
           mov   FLnepekjl,0
           MOV   FLAG3,0
           MOV   FLAG5,0
           mov   BPC4,5
           MOV   AL,BPC4
           mov   C4ET4UK,al
           RET
UHUC       ENDP

Del        proc  
           mov   cx,2fh
cukjl:     pusha
           call  O6pa6_ALLn
           popa
           push  cx
           cmp   flag5,0ffh
           jnz   BblX2
           call  nepek
           jmp   Del_ret
BblX2:     cmp   flag3,0ffh
           jnz   BblX1
           call  Out_Clock
           jmp   Del_ret
BblX1:     cmp   FLnepekjl,0ffh
           je    Am
           call  Out_Clock
           jmp   BblX
Am:        call  Out_ALLn
BblX:      pop  cx
           loop  cukjl
           CALL  BPEM9l
           mov   al,C4ET4UK
           call  PA3HOCTb
           mov   C4ET4UK,al
           Cmp   C4ET4UK,0
           jnz    Del_ret
           NOT   FLnepekjl
           MOV   AL,BPC4
           MOV   C4ET4UK,AL
Del_ret:   ret
Del        endp
O6PA3A     db    3eh,41h,41h,3eh;0
           db    44h,42h,7fh,40h;1
           db    72h,49h,49h,66h;2
           db    22h,49h,49h,36h;3
           db    18h,14h,12h,79h;4
           db    27h,49h,49h,33h;5
           db    3eh,49h,49h,32h;6
           db    03h,61h,19h,07h;7
           db    36h,49h,49h,36h;8
           db    26h,49h,49h,3eh;9
           db    3eh,41h,41h,26h;C
           db    06h,09h,09h,06h;#
           db    08h,08h,08h,08h;-
Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы
           call  UHUC
METKA:     call  del
           jmp   METKA
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
