
InADC            Proc 
                 cmp bfConvert, 0FFh
                 jne L_NOT_CNV
                 mov al, 01h
                 out 5, al
                 out 6, al 
                 mov al, 00h
                 out 5, al
                 out 6, al
                 mov bfConvert, 00h
 L_NOT_CNV:                 
                 in al, 4                    ;pREADY_IN
                 test al, 01h
                 jz L_NOT_RDY_WL                                  
                 in al, pWLEVEL_IN
                 mov bWaterLevel, al
                 mov bfConvert, 0FFh
 L_NOT_RDY_WL:   
                 mov dl, 00h              
                 in al, 5;pREADY_IN
                 test al, 01h
                 jz L_NOT_RDY_TEMP
                 in al, pTEMP_IN
                 mov bWaterTemp, al                 
                 mov dl, 0FFh                                  
 L_NOT_RDY_TEMP:  
                 and bfConvert, dl                 
                 ret                 
InADC            EndP

InBinaryGauge    Proc
                 mov bfUnBalance, 00h      ; Отбалансировано
                 mov bfDoorLock, 00h       ; Дверца открыта          
                 mov bfAmountLinen, 00h    ; Мало белья
                 
                 in al, pMODE_IN
                 mov dx, pMODE_IN
                 call VibrDestr
                 test al, 80h
                 jz L_BG1
                 mov bfDoorLock, 0FFh      ; Дверца закрыта
 L_BG1:                 
                 in al, 1    
                 mov dx, pGAUGE_IN
                 ;call VibrDestr    
                 test al, 01h
                 jz L_BG2
                 mov bfAmountLinen, 0FFh   ; Много белья                                   
 L_BG2:                 
                 test al, 02h
                 jz L_BGend
 L_BG:                 
                 in al, 1
                 test al, 02h
                 jnz L_BG
                 mov bfUnBalance, 0FFh     ; Дисбаланс
                 mov al, 10h
                 out 4, al
 L_BGend:                 
                 ret
InBinaryGauge    EndP
