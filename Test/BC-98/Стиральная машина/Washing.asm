
;**************/Определение дисбаланса\**********************
;
Balanced   Proc
           xor bh, bh           
           mov bl, bParam[2]                   ; Скорость отжима 
           shl bx, 1
           mov al, bStep
           mov bStep, 0
           cmp bl, 0                           ; Без отжима (ск.=0)?  
           jne L_Bdef                          ; Переход, если нет  
           jmp L_BendDef
 L_Bdef:           
           mov bStep, al
           mov dx, ES:SPIN_DEF[bx]             ; Выбранная скорость
           mov DriveTmp.wSpeed, dx
           mov bfDirection, 0
           mov DriveTmp.bfTypeDir, 1
           mov bfOutDevice[0], 0FFh
           lea bx, wTimeDefB                   
           mov cx, TDEFB
           call Pause                            
           jz L_BendDef                      ; Конец определения дисбаланса  
           cmp bError, 05
           jne L_Bend
           mov wTimeDefB, TDEFB
           jmp L_Bend
 L_BendDef:           
           call ZeroDrv
           inc al
           mov bStep, al                         ; След. шаг - ОТЖИМ
 L_Bend:
           ret
Balanced   EndP

;********************************/Отжим\**************************************
;
Spin       Proc
           mov al, bParam[2]
           cmp al, 0
           je L_Soff
           xor bh, bh
           mov bl, al
           mov cl, 1
           shl bl, cl    
           mov dx, ES:SPIN_DEF[bx]             ; Выбранная скорость            
           mov DriveTmp.wSpeed, dx
           mov DriveTmp.bfTypeDir, 1
           mov bfMoveDrv, 0FFh           
           mov bfDirection, 0
           lea bx, wWSMinute
           mov cx, TWSMIN
           call Pause
           jnz L_Send
           dec bTimeSpin         
           jnz L_Send
 L_Soff:           
           call Init                                    
 L_Send:          
           ret
Spin       EndP

DrvParam   Proc
; Вычисление смещения параметра двигателя в массиве DriveParam в 
; зависимости от текущего процесса
;           Выход: DriveTmp
           
; Вычисляем смещение в массиве DriveParam
           xor bx, bx
           mov bl, bStep
           cmp ES:Program[bx], 0
           je L_DPend
           ;cmp bl, 2
           ;jne L_DRP           
           ;dec bl
 ;L_DRP:           
           dec bl
           mov al, bParam[3]             ; Режим
           mov ah, length DriveParam
           mul ah                        ; ax := i*M = Режим*4
           add al, bl                 ; ax := i*M+j = Режим*4 + Шаг
           mov ah, type sDriverParam
           mul ah                        ; ax := (i*M+j)*type
           lea bx, es:DriveParam
           add bx, ax

           push es ds es ds 
           pop es                        ; ES := DS
           pop ds                        ; DS := ES
           mov si, bx
           lea di, DriveTmp
           mov cx, type sDriverParam
 rep       movsb                         ; Пересылаем параметр из ПЗУ в ОЗУ 
           pop ds
           pop es
 L_DPend:
           ret
DrvParam   EndP

Wash       Proc
           cmp bError, 0
           je L_Wnxt
           jmp L_Wend
 L_Wnxt:      
           mov al, bfStart     
           or bfWork, al
           cmp bfWork, 0FFh
           je L_W1
           jmp L_Wend
 L_W1:     
           mov bfDoorBlocking, 0FFh                 
           mov si, 0                     ; Начинаем с ЭД
           mov cx, 5                     ; В сх количество исп. устр-в
 L_Wnext:       
           mov ax, si
           mov ah, 10
           mul ah
           add al, bStep
           lea bx, ES:Program           
           add bx, ax
           mov al, ES:[bx]
           mov bfOutDevice[si], al
           cmp al, 00                    ; Program[i,j]=0 ?
           je L_WincSI                   ; Переход, если да
           cmp si, 0                     ; ЭД ?
           jne L_Wsi1                    ; Переход, если нет
           mov bfOutDevice[si], 0FFh     ; Включить ЭД   
 L_Wsi1:           
           cmp si, 1                     ; Вх.ЭК
           jne L_Wsi2                    ; Переход, если нет
           xor bh, bh
           mov bl, bParam[3]
           shl bl, 1
           mov dx, 1
           and dl, bfAmountLinen
           or bx, dx
           mov dl, es:Water[bx]          ; В dl необходимый уровень воды для стирки
           cmp bStep, 5                  ; Полоскание?
           jne L_Wcmp                    ; Переход, если нет
           mov dl, LEVEL_RING            ; В dl необходимый уровень воды для полоскания 
 L_Wcmp:           
           cmp bWaterLevel, dl           ; Уровень воды достигнут? 
           jb L_Wsi2                     ; Переход, если нет
           mov bfOutDevice[si], 0        ; Выклюить Вх. ЭК
 L_Wsi2:           
           cmp si, 2                     ; ТЭН?
           jne L_Wsi3                    ; Переход, если нет
           mov al, bfWorkHeater
           and bfOutDevice[si], al
           xor bh, bh
           mov bl, bParam[1]
           mov dl, ES:TEMP_DEF[bx]       ; dl = заданной темп-ре           
           cmp bWaterTemp, dl            ; Вода нагрелась?
           jb L_Wsi3                     ; Переход, если нет
           mov bfOutDevice[si], 0        ; Выключить ТЭН
 L_Wsi3:
           cmp si, 3
           jne  L_WincSI
           cmp bWaterLevel, 4
           ja  L_WincSI
           mov bfOutDevice[si], 0 
 L_WincSI:
           inc si                         ; След. исп. устройство
           dec cx
           jz L_WloopExit
           jmp L_Wnext
 L_WloopExit:           
           call DrvParam
           call NextStep                  ; Переход к след. шагу
           call UpdDrvPar                 ; Обновить параметры ЭД
           call MoveDrv
           call StopDrv
           call OutDrive           
 L_Wend:           
           ret
Wash       EndP

NextStep   Proc
           cmp bError, 0
           je L_NSnxt
           jmp L_NSend
 L_NSnxt:           
           cmp bStep, 0                  ; ОСТАНОВКА?
           jne L_NS1                     ; Переход, если нет
           cmp bfWork, 0FFh              ; Кнопка "ПУСК" нажата?
           jne $+6                       ; Переход, если нет   
           inc bStep                     ; След. шаг - ЗАЛИВ
           mov bParam[0], 0              ; Отображать время стирки           
           jmp L_NSend
 L_NS1:
           cmp bStep, 1                  ; ЗАЛИВ?
           jne L_NS2                     ; Переход, если нет
           cmp bWaterLevel, LEVEL_HEAT   ; Уровень вкл. ТЭНа?
           jb $+6                        ; Переход, если нет
           inc bStep                     ; След. шаг - НАГРЕВ
 L_NS2:           
           cmp bStep, 2                  ; НАГРЕВ?
           jne L_NS3                     ; Переход, если нет
           xor bh, bh                    
           mov bl, bParam[1]
           mov dl, ES:TEMP_DEF[bx]       ; dl = заданной темп-ре           
           cmp bfWorkHeater, 0FFh
           jne L_NS2inc
           cmp bWaterTemp, dl            ; Вода нагрелась?
           jb $+6                        ; Переход, если нет
  L_NS2inc:           
           inc bStep                     ; След. шаг - СТИРКА
           ;call ZeroDrv
 L_NS3:           
           cmp bStep, 3                  ; СТИРКА?
           jne L_NS4                     ; Переход, если нет
           lea bx, wWSMinute             ; Задержка 1 мин.
           mov cx, ONE_SEK*60            
           call Pause
           jnz $+12
           dec bTimeWash                 ; Уменьшаем время стирки
           jnz $+6                       ; Переход, если не конец стирки
           inc bStep                     ; След. шаг - СЛИВ
 L_NS4:           
           cmp bStep, 4                  ; СЛИВ?
           je L_NS                       ; Переход, если да
           cmp bStep, 7
           jne L_NS5
 L_NS:           
           cmp bWaterLevel, 00           ; Вода слита?
           ja $+6                        ; Переход, если нет
           inc bStep                     ; След. шаг - ЗАЛИВ для полоскания
 L_NS5:           
           cmp bStep, 5                  ; ЗАЛИВ для полоскания?
           jne L_NS6                     ; Переход, если нет
           mov bParam[0], 1              ; Отображать "ВРЕМЯ ОТЖИМА"                      
           cmp bWaterLevel, LEVEL_RING   ; Вода залита?
           jb $+6                        ; Переход, если нет
           inc bStep                     ; След. шаг - ПОЛОСКАНИЕ
 L_NS6:           
           cmp bStep, 6                  ; ПОЛОСКАНИЕ?
           jne L_NS8                     ; Переход, если нет
           lea bx, wTimeRing             ; Время полоскание (фикс.)
           mov cx, 0                     
           call Pause           
           jnz $+6                       ; Переход, если не конец
           inc bStep                     ; След. шаг - СЛИВ
 L_NS8:           
           cmp bStep, 8                  ; ОПРЕД. ДИСБАЛАНСА?
           jne L_NS9                     ; Переход, если нет
           call Balanced                 ; 
 L_NS9:
           cmp bStep, 9                  ; ОТЖИМ?
           jne L_NSend                   ; Переход, если нет
           call Spin                     ;
 L_NSend:           
           ret
NextStep   EndP

;**********************/Реакция на ошибку системы подачи воды\**********************
; >DONE<
Error1     Proc
           cmp bError, 01h
           jne L_ERR1end                    
           mov bfOutDevice[ePulm], 0FFh    ; Включить насос
           cmp bWaterLevel, 3
           ja L_ERR1nxt
           mov bfOutDevice[ePulm], 0       ; Выключить насос
 L_ERR1nxt:           
           lea bx, wTimeErr1               ; Задержка 2 мин  
           mov cx, 0
           call Pause
           jnz L_ERR1end           
           cmp bWaterLevel, 5
           jbe L_ERR1off 
 L_ERR1off:
           call Init   
 L_ERR1end:                   
           ret
Error1     EndP

;**********************/Реакция на ошибку системы слива воды\**********************
; >DONE<
Error2     Proc
           cmp bError, 02h
           jne L_ERR2end
           mov bfOutDevice[ePulm], 0FFh           
           lea bx, wTimeErr2
           mov cx, 0
           call Pause
           jz L_ERR2off
           cmp bWaterLevel, 0
           jne L_ERR2end
 L_ERR2off:                   
           call Init
 L_ERR2end:           
           ret
Error2     EndP

;************************/Реакция на ошибку работы ТЭНа\****************************
; >DONE<
Error3     Proc
           cmp bError, 03h
           jne L_ERR3end
           mov bfOutDevice[eHeat], 00     ; Выключить ТЭН
           cmp bfStart, 0FFh
           jne L_ERR3end
           cmp bWaterTemp, 0E6h           ; <90C?
           ja L_ERR3end               
 ; Продолжаем работу           
           mov bError, 0
           mov bfWork, 0FFh
           mov bfWorkHeater, 00           ; Работа продолжается без нагрева              
           jmp L_ERR3end
 L_ERR3off:
           call Init
 L_ERR3end:                      
           ret
Error3     EndP

;************************/Реакция при открытой дверце\**********************
;  >DONE<
Error4     Proc
           cmp bError, 04
           jne L_ERR4end
           lea bx, wTimeErr4
           mov cx, 0           
           call Pause               
           jz L_ERR4off
           cmp bfStart, 0FFh
           jne L_ERR4end
           cmp bfDoorLock, 0FFh
           jne L_ERR4end
           mov bError, 0
           mov bfWork, 0FFh
           jmp L_ERR4end           
 L_ERR4off:
           call Init
 L_ERR4end:                      
           ret
Error4     EndP

Error5     Proc
           cmp bError, 05
           jne L_ERR5end
           mov bfDoorBlocking, 00h        ; Разблокируем дверцу
           lea bx, wTimeErr5
           mov cx, 0        
           call Pause               
           jz L_ERR5off
           cmp bfStart, 0FFh
           jne L_ERR5end
           mov bError, 0
           mov bfWork, 0FFh
           mov wTimeDefB, TDEFB
           mov bfDoorBlocking, 0FFh       ; Блокировка включена! 
           jmp L_ERR5end
 L_ERR5off:
           call Init           
 L_ERR5end:           
           ret
Error5     EndP

;****************************/Реакции на ошибки\******************************
Reaction   Proc
           cmp bError, 0
           je L_REACend
           cmp bStep, 0
           jne L_REACexec
           cmp bfStart, 0FFh
           jne $+12
           mov bError, 0
           mov bfStart, 0         
           jmp L_REACend
 L_REACexec:           
           mov bfWork, 00
           push es           
           mov ax, Data
           mov es, ax 
           cld
           lea di, bfOutDevice
           mov cx, length bfOutDevice
           mov al, 0
 rep       stosb                         ; Выключаем все исп. устр-ва
           pop es
           
           call Error1
           call Error2
           call Error3
           call Error4
           call Error5

 L_REACend:           
           ret
Reaction   EndP