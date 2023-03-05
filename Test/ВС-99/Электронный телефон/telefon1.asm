Buttons2   PROC  NEAR
           xor   cx,cx   
           in    al,40h
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,0h
           je    la0
           cmp   al,1h
           je    reset2
           cmp   al,2h
           je    MovInMem2
           cmp   al,4h
           je    la3
           cmp   al,8h
           je    la4
           cmp   al,10h
           je    la5
           cmp   al,20h
           je    la6
           cmp   al,40h
           je    la7
           cmp   al,80h
           je    la8
la3:       jmp   MemSerfL2
la4:       jmp   MemSerfR2
la5:       jmp   Input2
la6:       jmp   LoadBlSp2
la7:       jmp   ResetMem2
la8:       jmp   ResetBlsp2
la0:       jmp   EndPr3
reset2:      
lab11:     in    al,40h
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,1h
           je    lab11
           mov   Flag21,0
           mov   cx,12
           lea   bx,data12
           mov   dx,50h
           call  ResetTel
           jmp   EndPr3
           
MovInMem2:      
lab21:     in    al,40h
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,2h
           je    lab21
           lea   bx,data12
           lea   si,MemArr2
           add   si,Point21
           add   Point21,12d
           mov   ax,Point21
           mov   Pointer,ax
           call  MovMemTel
           mov   Point22,ax
           mov   Point21,ax
           jmp   EndPr3
           
MemSerfL2:      
lab31:     in    al,40h
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,4h
           je    lab31
           mov   cx,12
           cmp   Point22,0
           jnz   lab33
           mov   Point22,96
lab33:     lea   bx,data12
           lea   si,MemArr2
           sub   Point22,12
           add   si,Point22
           mov   dx,50h
lab32:     mov   al,[si]
           mov   [bx],al
           out   dx,al
           inc   bx
           inc   si
           inc   dx
           loop  lab32
           mov   Flag21,0Dh 
           jmp   EndPr3

MemSerfR2:
lab41:     in    al,40h
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,8h
           je    lab41
           cmp   Point22,84
           jne   lab43
           mov   Point22,0
           jmp   lab44
lab43:     add   Point22,12
lab44:     mov   cx,12
           lea   bx,data12
           lea   si,MemArr2
           add   si,Point22
           mov   dx,50h
lab42:     mov   al,[si]
           mov   [bx],al
           out   dx,al
           inc   bx
           inc   si
           inc   dx
           loop  lab42
           mov   Flag21,0Dh 
           jmp   EndPr3    

Input2:
lab51:     in    al,40h
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,10h
           je    lab51
           mov   al,seltel
           and   al,00000101b
           cmp   al,5
           jnz   selt2
           or    seltel,00000010b
           call  InputTel2
selt2:     jmp   EndPr3

LoadBlSp2:
lab61:     in    al,40h
           mov   ah,0FFh 
           sub   ah,al
           mov   al,ah
           cmp   al,20h
           je    lab61
           lea   bx,BlackSp2
           lea   si,data12
           add   bx,PointBl21
           add   PointBl21,12
           mov   cx,12
lab62:     mov   al,[si]
           mov   [bx],al
           inc   bx
           inc   si
           loop  lab62
           cmp   PointBl21,96d
           jne   lab63
           mov   Pointbl21,0 
lab63:     mov   ax,PointBl21
           mov   BlackNav2,ax
           jmp   EndPr3
           
ResetMem2:  
lab71:     in    al,40h
           mov   ah,0FFh 
           sub   ah,al
           mov   al,ah
           cmp   al,40h
           je    lab71
           mov   dx,0
lab72:     lea   bx,MemArr2
           add   bx,dx
           add   dx,12
           mov   cx,12
lab73:     mov   [bx],BYTE PTR 0
           inc   bx
           loop  lab73
           cmp   dx,96
           jne   lab72
           xor   dx,dx
           jmp   EndPr3
              
ResetBlSp2: 
lab81:     in    al,40h
           mov   ah,0FFh 
           sub   ah,al
           mov   al,ah
           cmp   al,80h
           je    lab81
           mov   dx,0
lab82:     lea   bx,BlackSp2
           add   bx,dx
           add   dx,12
           mov   cx,12
lab83:     mov   [bx],BYTE PTR 0
           inc   bx
           loop  lab83
           cmp   dx,96
           jne   lab82
           xor   dx,dx
           jmp   EndPr3
EndPr3:    ret  
Buttons2   ENDP

Buttons    PROC  NEAR
           xor   cx,cx   
           in    al,20h
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,0h
           je    label0
           cmp   al,1h
           je    reset
           cmp   al,2h
           je    MovInMem
           cmp   al,4h
           je    l3
           cmp   al,8h
           je    l4
           cmp   al,10h
           je    l5
           cmp   al,20h
           je    l6
           cmp   al,40h
           je    l7
           cmp   al,80h
           je    l8
l3:        jmp   MemSerfL
l4:        jmp   MemSerfR
l5:        jmp   Input
l6:        jmp   LoadBlSp
l7:        jmp   ResetMem
l8:        jmp   ResetBlsp
label0:    jmp   EndPr           
reset:      
lb11:      in    al,20h
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,1h
           je    lb11
           mov   Flag,0
           mov   cx,12
           lea   bx,data1
           mov   dx,1
           call  ResetTel             
           jmp   EndPr
           
MovInMem:      
lb21:      in    al,20h
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,2h
           je    lb21
           lea   bx,data1
           lea   si,MemArr
           add   si,Point
           add   Point,12d
           mov   ax,Point
           mov   Pointer,ax             
           call  MovMemTel
           mov   Point2,ax
           mov   Point,ax
           jmp   EndPr
           
MemSerfL:      
lb31:      in    al,20h
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,4h
           je    lb31
           mov   cx,12
           cmp   Point2,0
           jnz   lb33
           mov   Point2,96
lb33:      lea   bx,data1
           lea   si,MemArr
           sub   Point2,12
           add   si,Point2
           mov   dx,1
lb32:      mov   al,[si]
           mov   [bx],al
           out   dx,al
           inc   bx
           inc   si
           inc   dx
           loop  lb32
           mov   Flag,0Dh 
           jmp   EndPr

MemSerfR:    
lb41:      in    al,20h
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,8h
           je    lb41
           cmp   Point2,84
           jne   lb43
           mov   Point2,0
           jmp   lb44
lb43:      add   Point2,12
lb44:      mov   cx,12
           lea   bx,data1
           lea   si,MemArr
           add   si,Point2
           mov   dx,1
lb42:      mov   al,[si]
           mov   [bx],al
           out   dx,al
           inc   bx
           inc   si
           inc   dx
           loop  lb42
           mov   Flag,0Dh 
           jmp   EndPr    

Input:                      
lb51:      in    al,20h
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,10h
           je    lb51  
           mov   al,seltel
           and   al,00000101b
           cmp   al,4
           jnz   selt
           or    seltel,00000010b
           call  InputTel
selt:      jmp   EndPr

LoadBlSp:
lb61:      in    al,20h
           mov   ah,0FFh 
           sub   ah,al
           mov   al,ah
           cmp   al,20h
           je    lb61
           lea   bx,BlackSp
           lea   si,data1
           add   bx,PointBl
           add   PointBl,12
           mov   cx,12
lb62:      mov   al,[si]
           mov   [bx],al
           inc   bx
           inc   si
           loop  lb62
           cmp   PointBl,96d
           jne   lb63
           mov   PointBl,0 
lb63:      mov   ax,PointBl
           mov   BlackNav1,ax
           jmp   EndPr
           
ResetMem:  
lb71:      in    al,20h
           mov   ah,0FFh 
           sub   ah,al
           mov   al,ah
           cmp   al,40h
           je    lb71
           mov   dx,0
lb72:      lea   bx,MemArr
           add   bx,dx
           add   dx,12
           mov   cx,12
lb73:      mov   [bx],BYTE PTR 0
           inc   bx
           loop  lb73
           cmp   dx,96
           jne   lb72
           xor   dx,dx
           jmp   EndPr
              
ResetBlSp: 
lb81:      in    al,20h
           mov   ah,0FFh 
           sub   ah,al
           mov   al,ah
           cmp   al,80h
           je    lb81
           mov   dx,0
lb82:      lea   bx,BlackSp
           add   bx,dx
           add   dx,12
           mov   cx,12
lb83:      mov   [bx],BYTE PTR 0
           inc   bx
           loop  lb83
           cmp   dx,96
           jne   lb82
           xor   dx,dx
           jmp   EndPr
                                     
EndPr:     ret  
Buttons    ENDP

BlSp       PROC  NEAR  
           cmp   Black,12
           jne   bl1           
           or    ind1,00000001b
           or    indicator,00000001b
           or    ind2,00010000b
           and   ind1,11111011b
           jmp   EndPr1
bl1:       and   ind1,11011110b           
EndPr1:    
           ret 
BlSp       ENDP

BlSp2      PROC  NEAR
           cmp   Black2,12
           jne   bl2
           or    ind2,00000001b
           or    indicator,00000010b
           or    ind1,00010000b
           and   ind2,11111011b
           and   ind1,11010000b
           jmp   EndPr4
bl2:       and   ind2,11011110b           
EndPr4:    ret
BlSp2      ENDP

Recall1    PROC  NEAR
           mov   al,seltel
           and   al,00000101b
           cmp   al,4
           jnz   rec2
           in    al,41h
           cmp   al,0FBh
           jz    rec1
           jmp   rec2  
rec1:      mov   cx,12
           lea   bx,RecTel
           lea   si,data1
           mov   dx,1h
rec3:      mov   al,[bx]
           mov   [si],al
           out   dx,al
           inc   si
           inc   bx
           inc   dx
           loop  rec3   
           call  InputTel          
rec2:      ret
Recall1    ENDP

Recall2    PROC  NEAR
           mov   al,seltel
           and   al,00000101b
           cmp   al,5
           jnz   re2
           in    al,21h
           cmp   al,0FBh
           jz    re1
           jmp   re2  
re1:       mov   cx,12
           lea   bx,RecTel2
           lea   si,data12
           mov   dx,50h
re3:       mov   al,[bx]
           mov   [si],al
           out   dx,al
           inc   si
           inc   bx
           inc   dx
           loop  re3   
           call  InputTel2          
re2:       ret
Recall2    ENDP

InputTel   PROC  NEAR
           lea   bx,data1
           lea   si,telefon
           lea   di,RecTel
           mov   Black2,0
           mov   cx,12
lb52:      mov   al,[bx]
           mov   [si],al
           mov   [di],al
           inc   bx
           inc   si
           inc   di
           loop  lb52           
lb56:      lea   si,telefon
           lea   bx,BlackSp2
           add   bx,PointBl2
           add   PointBl2,12
           mov   cx,12
           mov   dx,0 
lb53:      mov   al,[bx]
           cmp   al,[si]
           jne   lb54
           inc   dx
lb54:      inc   bx
           inc   si
           loop  lb53
           cmp   PointBl2,96d
           je    lb55
           cmp   dx,12
           jne   lb56
           mov   Black2,12        
lb55:      mov   PointBl2,0
           mov   Flag,0Dh
           mov   dx,21h
           call  LineOut
           mov   dx,41h
          ;call  Beep
           lea   bx,telefon
           mov   dx,50h
           mov   cx,12
lb58:      mov   al,[bx]
           out   dx,al
           inc   dx
           inc   bx
           loop  lb58
           mov   dx,41h
           call  BlSp2
           cmp   black2,12
           jz    lb57
           call  Beep2
lb57:      call  Speak
           ret
InputTel   ENDP

InputTel2  PROC  NEAR
           lea   bx,data12
           lea   si,telefon
           lea   di,RecTel2
           mov   Black,0
           mov   cx,12
lab52:     mov   al,[bx]
           mov   [si],al
           mov   [di],al
           inc   di
           inc   bx
           inc   si
           loop  lab52           
lab56:     lea   si,telefon
           lea   bx,BlackSp
           add   bx,PointBl22
           add   PointBl22,12
           mov   cx,12
           mov   dx,0 
lab53:     mov   al,[bx]
           cmp   al,[si]
           jne   lab54
           inc   dx
lab54:     inc   bx
           inc   si
           loop  lab53
           cmp   PointBl22,96d
           je    lab55
           cmp   dx,12
           jne   lab56
           mov   Black,12
lab55:     mov   PointBl22,0
           mov   Flag21,0Dh
           mov   dx,41h
           call  LineOut
           mov   dx,21h
           ;call  Beep
           lea   bx,telefon
           mov   dx,1h
           mov   cx,12
lab58:     mov   al,[bx]
           out   dx,al
           inc   dx
           inc   bx
           loop  lab58
           mov   dx,21h
           call  BlSp
           cmp   black,12
           jz    lab57
           call  Beep2
lab57:     call  Speak
           ret
InputTel2  ENDP
           
ResetTel   PROC  NEAR
lab12:     mov   BYTE PTR[bx],00
           mov   al,[bx]
           out   dx,al
           inc   bx
           inc   dx
           loop  lab12
           ret
ResetTel   ENDP

MovMemTel  PROC  NEAR
           mov   cx,12d
lb22:      mov   al,[bx]
           mov   [si],al 
           inc   bx
           inc   si
           loop  lb22
           mov   ax,Pointer
           cmp   ax,96d
           jz    lb23
           jmp   lb24
lb23:      mov   Pointer,0
lb24:      mov   ax,Pointer
           ret
MovMemTel  ENDP

LineOut    PROC  NEAR
           mov   bx,4
lin:       mov   cx,0FFFh
           mov   al,00000000b
lin1:      out   dx,al
           loop  lin1
           mov   cx,0FFFh
           or    al,00000100b
lin2:      out   dx,al
           loop  lin2
           dec   bx
           cmp   bx,0
           jnz   lin          
           ret
LineOut    ENDP

Beep       PROC  NEAR         
bep:       mov   cx,0FFFh
           mov   al,indicator
           and   al,11111110b
           or    al,00001100b
bep1:      out   dx,al
           loop  bep1
           mov   cx,0FFFh
           and   al,11110111b
bep2:      out   dx,al
           loop  bep2
           ret           
Beep       ENDP

Beep2      PROC  NEAR
bep4:      in    al,dx
           cmp   al,0FEh
           jz    EndBeep2
           mov   indicator,3
           mov   al,seltel
           and   al,00000001b
           cmp   al,0
           jnz   bep5
           in    al,21h
           and   InOut,00001100b
           or    InOut,00000010b
           cmp   al,0FDh
           jz    bep7   
bep5:      in    al,41h
           and   InOut,00000011b
           or    InOut,00001000b
           cmp   al,0FDh
           jz   bep7
           call  beep
           jmp   bep4
EndBeep2:  mov   indicator,0h
           mov   InOut,00000101b
bep7:      and   ind1,11000000b
           and   ind2,11000000b
           or    ind1,00100100b
           or    ind2,00100100b
           ret             
Beep2      ENDP

Speak      PROC  NEAR          
sp4:       mov   al,InOut
           out   23h,al
           in    al,41h
           cmp   al,0FDh
           jz    sp1
           in    al,21h
           cmp   al,0FDh
           jz    sp2
           mov   al,ind2
           out   41h,al
           mov   al,ind1
           out   21h,al
           cmp   indicator,3
           jz    sp3
           jmp   sp4
sp2:       and   ind1,00000001b
           mov   ind2,00010000b
           or    indicator,00000001b
           mov   InOut,00001001b
           mov   cx,12
           lea   bx,data1
           mov   dx,1
           call  ResetTel
           jmp   sp4
sp1:       and   ind2,00000001b
           mov   ind1,00010000b
           or    indicator,00000010b
           mov   InOut,00000110b
           mov   cx,12
           lea   bx,data12
           mov   dx,50h
           call  ResetTel
           jmp   sp4
sp3:       mov   al,0
           out   41h,al
           out   21h,al
           mov   Flag21,0h
           mov   Flag,0h
           call  PreStart2
           ret
Speak      ENDP