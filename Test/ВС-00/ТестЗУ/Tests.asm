Calc_Len_Block  PROC  NEAR         ;Вычисление длины заданного блока памяти в CX и DX
	    mov   ax,segbegin
            mov   bx,offsetbegin
            mov   cx,segend
            mov   dx,offsetend
            
            sub   dx,bx
            sbb   cx,0
            sub   cx,ax                        
            shr   cx,12                         
            ret  
Calc_Len_Block  ENDP


Result PROC NEAR                   ;Отображение результата проведенного теста
           push  ax bx
           add   totalblocks,1
           cmp   totalblocks,100
           jb    Res1
           mov   totalblocks,0
           mov   errorblocks,0
           
Res1:      cmp   reslt,1
           jne   Re1
           add   errorblocks,1   
           mov   al,111b
           out   DispInPort + 9,al
           mov   Sost,1000000b  
           cmp   totaldeadadr,0
           je    Re2                    
           jmp   ExResult
                              
Re1:       mov   al,1011b
           out   DispInPort + 9,al
Re2:       mov   Sost,1
ExResult:  
           pop  bx ax
           ret
Result ENDP



Calc_sumPZU PROC NEAR                ;Вычисление контрольной суммы ПЗУ
            call  Calc_Len_Block                                   
            mov   csumm,0
            mov   es,ax
nextbyte:   
            mov   ax,es:[bx]           
            add   csumm,ah            
            sub   dx,1
            jnc   newbyte
            sub   cx,1
            jnc   newbyte
            jmp   ExSumPZU
            
newbyte:    add   bx,1            
            jnc   nextbyte            
            mov   ax,es
            add   ax,1000h
            mov   es,ax            
            jmp   nextbyte                        
ExSumPZU:   ret             
Calc_sumPZU ENDP

Calc_Dop    PROC NEAR                ;Вычисление дополнения к контрольной сумме ПЗУ
            cmp   ready,1
            jne   ExCalc_Dop                       
            
            push  ax bx cx dx            
            mov   Sost,100000b
            call  CheckSost            
            call  Calc_sumPZU                        
            mov   al,0
            sub   al,csumm
            mov   csumm_dop,al                       
            mov   Sost,1                        
            pop   dx cx bx ax
ExCalc_Dop: ret 
Calc_Dop    ENDP


Test1 PROC NEAR                      ;Тест блока памяти по ША
            cmp   Ready,1
            jne   Exit1
            
            push  ax bx cx dx 
            mov   Sost,100b
            call  CheckSost             
            mov   reslt,0
            mov   totaldeadadr,0
            call  Calc_Len_Block           
                      
            mov   si,0
            mov   es,ax
nxtcheck:   
            mov   di, es:[bx]            
            mov   es:[bx],bx                                               
            mov   ax,es:[bx]            
            mov   es:[bx],di
            cmp   ax,bx
            jz    byte_ok
                             
            mov   reslt,1    
            cmp   totaldeadadr,511
            jae   ExTest1
            mov   si,totaldeadadr
            mov   deadaddr[si],es      ;запись адреса поврежденной
            mov   deadaddr[si+2],bx    ;ячейки памяти в массив        
            add   totaldeadadr,4
            
byte_ok:    sub   dx,1            
            jnc   newchk
            sub   cx,1
            jnc   newchk
            jmp   Extest1
            
newchk:     add   bx,1
            jnc   nxtcheck
            mov   ax,es
            add   ax,1000h
            mov   es,ax
            jmp   nxtcheck            
 
Extest1:    call  Result
            pop  dx cx bx ax
Exit1:      ret
Test1 ENDP


Test2 PROC NEAR                          ;Тест блока памяти по ШД            
            push  ax bx cx dx
            cmp   Ready,1
            jne   Exit2
            
            mov   Sost,1000b
            mov   reslt,0
            mov   totaldeadadr,0            
            
            call  CheckSost                         
            call  Calc_Len_Block           

            mov   si,0
            mov   es,ax
            
nextcheck:  
            mov   ax,5555h             
            mov   di,es:[bx] 
            mov   es:[bx],ax
            mov   ax,es:[bx]
            cmp   ax,5555h
            jne   error
            mov   ax,0aaaah
            mov   es:[bx],ax
            mov   ax,es:[bx]                        
            cmp   ax,es:[bx]
            jne   error
            jmp   OK
            
error:      mov   es:[bx],di
            mov   reslt,1
            cmp   totaldeadadr,511
            jae   ExTest2            
            mov   si,totaldeadadr
            mov   deadaddr[si],es      ;запись адреса поврежденной
            mov   deadaddr[si+2],bx    ;ячейки памяти в массив        
            add   totaldeadadr,4            
            
OK:         mov   es:[bx],di
            sub   dx,1            
            jnc   newcheck
            sub   cx,1
            jnc   newcheck
            jmp   Extest2
            
newcheck:   
            add   bx,1
            jnc   nextcheck
            mov   ax,es
            add   ax,1000h
            mov   es,ax            
            jmp   nextcheck            
 
Extest2:    call  Result
Exit2:      pop   dx cx bx ax
            ret
Test2 ENDP


Test3 PROC NEAR                          ;Тест блока ПЗУ по контрольной сумме
            cmp   Ready,1
            jne   Exit3
                        
            push  ax bx cx dx
            mov   reslt,0                        
            mov   Sost,10000b

            call  CheckSost             
            call  Calc_sumPZU                                    

            mov   al,csumm
            add   al,csumm_dop
            cmp   al,0
            je    ExTest3
            mov   reslt,1
            mov   totaldeadadr,0
ExTest3:    call  Result
            pop   dx cx bx ax
Exit3:      ret
Test3 ENDP
