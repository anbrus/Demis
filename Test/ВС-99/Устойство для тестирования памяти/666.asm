.386
RomSize    EQU   4096
IntTable   SEGMENT AT 0 use16
IntTable   ENDS
Data      SEGMENT AT 40h use16
AdBuf1     dw  34  dup(?)
Select  db ?      ; 1-шина. 2-тип. 3-режим
Adress  dw ?
SizeMod db ?
KSumma  db ?
DKSumma db ?
ErrMod  db ?
EndMod  db ?
BadBite db ?     
OutInd  db ?
godPZU  dw ?
godOZU  dw ?
ngodPZU  dw ?
ngodOZU  dw ?
errb    dw ?
next    db ?
oldkey1 db ?
oldkey2 db ?
key     db ? 
sdvig   db ?
vibor   dw ?
counter db  ?

AdBuf   dw  34  dup(?)
Data    ENDS
Stk        SEGMENT AT 1024h use16
           dw    64 dup (?)
StkTop     Label Word
Stk        ENDS
InitData   SEGMENT use16
InitData   ENDS
Code       SEGMENT use16
SymImages  DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h
SizeMass   db    01h,02h,04h,08h,16h,32h,64h
           ASSUME cs:Code,ds:Data,es:Data

Podgotovka  Proc near

           mov   SizeMod,1
           mov   Select,1110b
           mov   Adress,0h
           mov   godPZU,000h  
           mov   godOZU,000h  
           mov   ngodPZU,000h  
           mov   ngodOZU,000h  
           mov   OutInd,0 
           mov   EndMod,0
           mov   errmod,0
           mov   errb,0
           mov   oldkey1,0
           mov   oldkey2,0           
           mov   key,0
           mov  ax,Adress
           mov  dx,11h
           call OutIndic
           mov  al,Sizemod
           mov  dx,13h
           call OutIndic
ret
Podgotovka  endp

Scankeys  proc near
           xor   ax,ax
           in    al,1h
           mov   oldkey1,al
           mov   key,0
           cmp   al,0
           je    key1
           cmp   al,oldkey2
           je    key1
           mov   oldkey2,al
           mov   key,al
           ret
    key1:  mov  al,oldkey1
           mov  oldkey2,al
ret
scankeys  endp

Scankeyboard Proc near
           mov  al,select
           and   al,1000b
           cmp al,0
           je  NoKeyPressed  
           lea   bx,SymImages
ScanBegin: xor   dx,dx
ScanNextLine:  mov   cl,dl
           mov   al,1
           shl   al,cl
           out   0,al
           in    al,0
           or    al,al
           jz    ZeroScan
           mov   dh,1
           xor   cx,cx
           bsf   cx,ax
           add   dh,cl
           mov   al,dl
           shl   al,2
           add   dh,al
ZeroScan:  inc   dl
           cmp   dl,4
           jnz   ScanNextLine
           or    dh,dh
           jz    NoKeyPressed
           call reset
           mov   al,16
           sub   al,dh
           xor   cx,cx
           mov   cl,al 
           xor   ah,ah
           mov   ax,Adress
           shl   ax,4
           or    ax,cx 
           mov   Adress,ax
           mov   dx,11h
           call OutIndic
           mov   EndMod,0
           mov   ErrMod,0           
           and   OutInd,0111111b
           mov   cx,50000
      b1:  xor  ax,ax
           xor  ax,ax      
           xor  ax,ax
           xor  ax,ax
           loop  b1
NoKeyPressed: ;mov  al,oldkey1
           ;mov  oldkey2,al
ret
scankeyboard endp

Reshim Proc Near
           mov  al,key
           and  al,111b
           cmp  al,0
           jne   l611 
           jmp  endResh
    l611:  cmp  al,1
           jne  l612
           xor   Select,1000b
           jmp  l614
    l612:  cmp  al,10b
           jne  l613
           mov  al,select
           xor   Select,100b
           jmp  l614          
    l613:  xor   Select,10b
    l614:  call reset
           mov  al,select
           and  al,1000b
           cmp  al,0
           jz   s3           
           jmp  testm
s3:        jmp   statm
    testm: mov  ax,Adress
           mov  dx,11h
           call OutIndic
           mov  al,0
           out  1ah,al
           out  1bh,al
           out  19h,al
           out  18h,al
           mov  al,select
           and  al,1100b
           cmp  al,1000b
           jne  endresh
           and  select,1100b
     jmp  endResh
    statm: mov  al,select
           and  al,100b
           cmp  al,0
           jnz   s1
           jmp  s2
 s1:       jmp   OZU
s2:        mov  ax,godPZU
           mov  dx,11h
           call OutIndic
           mov  ax,ngodPZU
           mov  dx,18h
           call OutIndic
           jmp  endResh
    OZU:   mov  ax,godOZU
           mov  dx,11h
           call OutIndic
           mov  ax,ngodOZU
           mov  dx,18h
           call OutIndic
endResh:   call  OutReshim
ret
Reshim Endp

ChangeSize Proc Near
           mov   al,key
           and   al,110000b
           cmp   al,0
           je    l715 
           cmp   al,100000b
           jne   l712
           cmp   SizeMod,1
           je    l715
           Shr   SizeMod,1                 
           jmp   l713
    l712:  cmp   SizeMod,64
           je    l715
           Shl   SizeMod,1      
     l713: call reset
           mov   ax,0
           mov   cx,0
           mov   al,SizeMod
     l10:  inc   cl
           shr   al,1
           jnc   l10
           dec   cl
           mov   di,cx
           mov   al,SizeMass[di]
           mov   cl,al
           and   al,0Fh
           mov   di,ax 
           mov   al,SymImages[di]
           out   16h,al
           mov   al,cl          
           shr   al,4
           mov   di,ax 
           mov   al,SymImages[di]
           out   15h,al
l715:      ret
ChangeSize Endp

Dopol Proc Near
            mov  al,key
            cmp  al,1000b
            jne  DopEnd
            mov  al,select
            and  al,1100b
            cmp  al,1000b
            je   begin
            ret
begin:      call  reset
            mov  bx,0
            mov  ax,Adress
            mov  es,ax
            mov  ax,0
            mov  cx,0
            mov  cl,SizeMod
            Shl  cx,10
            dec  cx
            mov  al,es:[bx]
    D1:     inc  bx
            xor  al,es:[bx]       
            loop  D1
            mov  KSumma,al
            mov  ah,0
            sub  ah,al         
            mov  DKSumma,ah            
            or   Select,1
   Dopend:  ret
Dopol Endp

ResetOzu  Proc near
           cmp  key,1000000b
           je   l411
           ret
   l411:   mov  al,select
           and  al,1100b
           cmp  al,0100b
           je   l412
           ret
  l412:    mov  godOZU,0
           mov  ngodOZU,0
           mov  ax,godOZU
           mov  dx,11h
           call OutIndic
           mov  ax,ngodOZU
           mov  dx,18h
           call OutIndic            
ret
resetozu endp

ResetPzu  Proc near
           cmp  key,1000000b
           je   l511
           ret
   l511:   mov  al,select
           and  al,1100b
           cmp  al,0000b
           je   l512
           ret
   l512:    mov  godPZU,0
            mov  ngodPZU,0
            mov  ax,godPZU
            mov  dx,11h
           call OutIndic
            mov  ax,ngodPZU
            mov  dx,18h
           call OutIndic
ret
resetPzu endp

TestOzuA  Proc near
           cmp  key,1000000b
           je   l111
           ret
   l111:   mov  al,select
           cmp  al,1110b
           je   l112
           ret
  l112:    cmp   EndMod,10b
           jne   l113
           ret
  l113:    mov  bx,0
           mov  ax,Adress
           mov  es,ax
           mov  dx,0
           mov  dl,SizeMod
           Shl  dx,9
           stc
           lea  si,AdBuf
           cmp  errmod,1
           jne  OA1
           mov  bx,errb
           cmp  bx,0
           jne  r1 
           mov  bx,1
           jmp  OAEr
    r1:    clc
           rcl  bx,1
           jmp  OAEr
    OA1:    mov  al,es:[bx]
            mov  [si],al
            mov  byte ptr es:[bx],bl
            rcl  bx,1
            add  si,1
            cmp  bx,dx
            clc
            jnz  OA1
            mov  bx,0
            lea  si,AdBuf
            mov  cx,1
    OA2:    mov  al,es:[bx]
            cmp  al,bl
            jne  OAEr
            mov  al,[si]
            mov  es:[bx],al
            cmp  cx,1
            jne  OA666
            stc 
            mov  cx,0
            jmp OA555
    OA666:  clc
    OA555:  rcl  bx,1
            add  si,1
            cmp  bx,dx
            clc
            jnz  OA2
            mov  dx,godOZU
            Call ADDDec
            mov  godOZU,dx
            mov  EndMod,10b
            ret
    OAEr:   cmp  bx,dx
            jne  ff1
            mov  endmod,10b
ff1:        cmp  ErrMod,1
            je   sa
            mov  dx,ngodOZU
            Call ADDDec
            mov  ngodOZU,dx
            mov  errMod,1
    sa:     mov  errb,bx
            mov  ax,bx
            mov  dx,18h
           call OutIndic
ret
TestOzuA  endp

TestOzuD  Proc near
           cmp  key,1000000b
           je   l211
           ret
   l211:   mov  al,select
           cmp  al,1100b
           je   l212
           ret
    l212:  cmp   EndMod,10b
            jne   l213
            ret
    l213:   mov  bx,0
            mov  ax,Adress
            mov  es,ax
            mov  cx,0
            mov  cl,SizeMod
            Shl  cx,10
            dec  cx
            cmp  errmod,1
            jne  OD
            mov  bx,errb
            inc  bx           
     OD:    mov  al,es:[bx]
            mov  byte ptr es:[bx],55h
            cmp  byte ptr es:[bx],55h
            jne  ODEr
            mov  byte ptr es:[bx],0AAh
            cmp  byte ptr es:[bx],0AAh
            jne  ODEr
            mov  es:[bx],al
            mov  ax,bx
            mov  dx,18h
           inc  bx
            loop  OD
            mov  EndMod,10b
            mov  dx,godOZU
            Call ADDDec
            mov  godOZU,dx
            ret
   ODEr:    mov  ax,bx
            mov  dx,18h
           call OutIndic
            mov  al,1b
            out  21h,al
            mov  ErrB,bx
            cmp  ErrMod,1
            je   s
            mov  ErrMod,1
            mov  dx,ngodOZU
            Call ADDDec
            mov  ngodOZU,dx
     s:     ret
TestOzuD endp

TestPZU  Proc near
           cmp  key,1000000b
           je   l311
           ret
   l311:   mov  al,select
           and  al,1100b
           cmp  al,1000b
           je   l312
           ret
   l312:   cmp   EndMod,10b
           jne   l313
           ret
   l313:    mov  bx,0
            mov  ax,Adress
            mov  es,ax
            mov  ax,0
            mov  cx,0
            mov  cl,SizeMod
            Shl  cx,10
            dec  cx
            mov  al,es:[bx]
    P1:     inc  bx
            xor  al,es:[bx]       
            loop  P1
            Add  al,DKSumma
            cmp  al,0
            jnz  TPErr
            mov  EndMod,10b
            mov  dx,godPZU
            Call ADDDec
            mov  godPZU,dx
            ret
   TPErr:   mov  EndMod,10b
            mov  ErrMod,1            
            mov  dx,ngodPZU
            Call ADDDec
            mov  ngodPZU,dx
ret
TestPZU Endp

Ok Proc   Near
           mov   al,key
           and   al,10000000b
           cmp   al,0
           je    OkEnd
           call  reset
   OkEnd:   Ret
Ok EndP

ADDDec  Proc  Near
           mov  al,dl
           add  al,1
           daa
           mov  cl,al
           mov  al,dh
           adc  al,0 
           daa
           mov  dh,al
           mov  dl,cl
ret
ADDDec  Endp

Reset  Proc  Near
           mov   EndMod,0
           mov   ErrMod,0           
           and select,1110b
           mov DKSumma,0
           mov  al,0
;           mov  dx,18h
;           call OutIndic
           out  1ah,al
           out  1bh,al
           out  19h,al
           out  18h,al
ret
reset  endp

OutReshim Proc Near
           mov   al,0
           or    al,Endmod
           or    al,Errmod
           out   21h,al

           mov   al,0
           mov   outind,al
           mov   al,select
           and   al,1000b
           jz    k1
           or    OutInd,10000b
           jmp   k2
   k1:     or    OutInd,100000b
   k2:     mov   al,select
           and   al,100b
           jz    k3
           or    OutInd,100b
           jmp   k4
   k3:     or    OutInd,1000b
   k4:     mov   al,select
           and   al,10b
           jz    k5
           or    OutInd,1b
           jmp   k6
   k5:     or    OutInd,10b
           mov  al,select
           and  al,1
           cmp  al,0
           je   k6
           or   Outind,1000000b
   k6:     mov  al,OutInd
           out  1,al
ret
OutReshim Endp

OutIndic  Proc Near
           mov  bx,ax
           mov  vibor,0f000h
           mov  counter,4
           mov  cl,12
m666:      and  ax,vibor
           shr  ax,cl
           mov  di,ax 
           mov  al,SymImages[di]
           out  dx,al
           mov  ax,bx
           inc  dx
           sub  cl,4
           Shr  vibor,4
           dec  counter
           cmp   counter,0
           jnz  m666
ret  
OutIndic  Endp

Start: 
           mov   ax,data
           mov   ds,ax
           mov   es,ax
           call  Podgotovka
lll:       
           call  scankeys
           call  scankeyboard
           call  Reshim
           call  ChangeSize
           call  Dopol
           call  ResetOzu
           call  ResetPzu
           call  TestOzuA 
           call  TestOzuD
           call  TestPZU 
           call  Ok
           jmp  lll
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
