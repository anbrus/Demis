
;********************/Тестирование системы подачи воды\*************************
TstSysFill Proc
; Ошибка фиксируется, если вода не залита 
; до уровня вкл. ТЭНа как минимум за 4 минуты.
; Также фиксируется перелив, когда вода превышает верхний уровень (20 л.)

           cmp bfOutDevice[eFill], 0FFh        ; Вх. ЭК включен?
           jne L_TSGover
           cmp bWaterLevel, 32h          ; >= 4л. ?
           jae L_TSGover
           lea bx, wTimeTstFill
           mov cx, TTSTF
           call Pause
           jnz L_TSGover                 ; Переход, если не прошло 4 мин.
           mov bError, 01h
 L_TSGover:            
           cmp bWaterLevel, 0FAh         ; >= 20л. ?
           jb L_TSGend    
           mov bError, 01h
 L_TSGend:           
           ret
TstSysFill EndP

; *********************/Тестирование системы слива воды\**********************
TstSysPulm Proc
; Ошибка фиксируется, если вода не слита
; как минимум за 5 минут

           cmp bfOutDevice[ePulm], 0FFh
           jne L_TSPend
           cmp bWaterLevel, 0Ch
           jb L_TSPend
           lea bx, wTimeTstPulm
           mov cx, TTSTHP           
           call Pause
           jnz L_TSPend
           mov bError, 02h
           mov wTimeTstPulm, 0           
 L_TSPend:           
           ret
TstSysPulm EndP

; ********************
TstHeater  Proc
; Неисправность фиксируется, если темп-ра воды >95C, либо 
; после включения ТЭНа темп-ра воды в течение 10 мин 
; меняется меньше чем на 3С.
           
           cmp bfOutDevice[eHeat], 0FFh
           je L_THtst
           cmp bWaterTemp, 0F3h        ; Больше 95С?
           ja L_THerr                
           jmp L_THend
 L_THtst:           
           cmp bfTmp, 0FFh
           je L_THpause
           mov al, bWaterTemp
           mov bTemp, al
           mov bfTmp, 0FFh
 L_THpause:            
           lea bx, wTimeTstHeated
           mov cx, TTSTHP               ; 10 минут
           call Pause
           jnz L_THend    
           mov bfTmp, 00       
           mov al, bWaterTemp
           sub al, bTemp
           cmp al, 07h                   ; Изменение меньше 3С?
           ja L_THend                    ; Переход, если нет
 L_THerr:           
           mov bError, 03h
           jmp L_THend                   
 L_THend:            
           ret           
TstHeater  EndP

TstLock    Proc
           cmp bfWork, 0FFh
           jne L_TLend
           cmp bfDoorLock, 0FFh
           je L_TLend
           mov bError, 04h
 L_TLend:           
           ret
TstLock    EndP

TstBalance Proc
           cmp bStep, 8
           jne L_TUBend
           cmp bfUnBalance, 0FFh
           jne L_TUBend
           inc bCounterUB
           cmp bCounterUB, MAX_ERR_UB
           jne L_TUBend
           mov bCounterUB, 0
           mov bError, 05h           
 L_TUBend:           
           ret
TstBalance EndP          
