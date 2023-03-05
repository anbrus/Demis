.386
RomSize    EQU   4096

Code       SEGMENT use16
           ASSUME cs:Code,ds:Code,es:Code

Numbers    db 3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh

Start:     mov   ax,Code
           mov   ds,ax
           mov   es,ax
           ;call  Lab2a
           call  Lab2b
           jmp   Start
           
           
Lab2a:     in    al,0
           xor   al,0 
           jz    exita
           mov   cl,al
           xor   al,al           
counta:    inc   al
           shr   cl,1
           jnc   counta
           dec   al             
           lea   bx,Numbers
           xlat
           out   0,al
exita:     RET

Lab2b:     in    al,0
           xor   al,0
           jz    exitb
           lea   bx,base
           mov   cl,al
           xor   ax,ax
countb:    inc   al
           shr   cl,1
           jnc   countb  
           dec   al
           shl   ax,2
           add   ax,bx
           jmp   ax                  
base:      mov   al,3Fh
           jmp   exit
           mov   al,0Ch
           jmp   exit
           mov   al,76h
           jmp   exit
           mov   al,5Eh
           jmp   exit
           mov   al,4Dh
           jmp   exit
           mov   al,5Bh
           jmp   exit
           mov   al,7Bh
           jmp   exit
           mov   al,0Eh
exit:      out   0,al
exitb:     RET

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
