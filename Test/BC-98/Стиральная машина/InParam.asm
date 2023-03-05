
SelectTime Proc
; Выбор типа времени           
           cmp bfTime, 0FFh              ; Кнопка "ВРЕМЯ" нажата?
           jne L_STMend                  ; Переход, если нет
           inc bParam[0]
           cmp bParam[0], MAX_NUM_TIME
           jne L_STMend
           mov bParam[0], 0     
 L_STMend:      
           ret
SelectTime EndP

SelectTemp Proc
; Выбор температуры     
           cmp bfTemp, 0FFh
           jne L_STEMPend
           inc bParam[1]
           cmp bParam[1], MAX_NUM_TEMP
           jne L_STEMPend           
           mov bParam[1], 0  
 L_STEMPend:           
           ret
SelectTemp EndP

SelectSpin Proc
; Выбор отжима
           cmp bfSpin, 0FFh          ; Кнопка "ОТЖИМ" нажата?    
           jne L_SSPend              ; Переход, если нет    
           inc bParam[2]
           mov al, MAX_NUM_SPIN
           cmp bParam[3], 1
           jne L_SSPnxt
           mov al, 2
 L_SSPnxt:           
           cmp bParam[2], al
           jne L_SSPend           
           mov bParam[2], 0
 L_SSPend:     
           ret      
SelectSpin EndP

SelectMode Proc
; Выбор режима
           cmp bfMode, 0FFh
           jne L_SMend
           inc bParam[3]
           cmp bParam[3], 1          ; "Бережный" режим?
           jne L_SMnxt
           cmp bParam[2], 1
           jbe L_SMnxt          
           mov bParam[2], 1
 L_SMnxt:           
           cmp bParam[3], MAX_NUM_MODE
           jne L_SMend           
           mov bParam[3], 0
 L_SMend:          
           ret
SelectMode EndP

InParam    Proc
           lea bx, wTimeDelayInd
           mov cx, TDELIND
           call Pause
           jnz L_INPend
           cmp bError, 5
           jne L_INPbeg
           call SelectSpin
           jmp L_INPend
 L_INPbeg:           
           cmp bError, 0
           jne L_INPend           
           cmp bfWork, 0FFh             ; "РАБОТА" ?
           je  L_INPend           
           call SelectTime
           call SelectTemp
           call SelectSpin
           call SelectMode
; Изменяем время
           xor bh, bh
           mov bl, bParam[0]
           mov al, es:MAX_TIME[bx]
           mov si, length bParam-2
           mov dl, bParam[bx+si]           
           
           cmp bfIncTime, 0FFh
           jne L_MTdec
           inc dl
           cmp dl, al
           jbe L_MTdec           
           mov dl, 1           
 L_MTdec:   
           cmp bfDecTime, 0FFh
           jne L_MTend
           dec dl
           cmp dl, 1
           jae L_MTend
           mov dl, al                      
 L_MTend:
           mov bParam[bx+si], dl
           mov ax, word ptr bParam[4]
           mov bTimeWash, al
           mov bTimeSpin, ah
 L_INPend:                                                               
           ret
InParam    EndP


