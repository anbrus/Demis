
MoveDrv    Proc
           cmp bfOutDevice[0], 0FFh
           jne L_MDend
           cmp bfPauseDrv, 0FFh
           je L_MDend
           lea bx, Drive.wWork
           mov cx, 0
           call Pause
           jnz L_MDend
           cmp Drive.bfTypeDir, 1
           je L_MDend
           mov bfPauseDrv, 0FFh                   
 L_MDend:                      
           ret
MoveDrv    EndP

StopDrv    Proc
           cmp bfOutDevice[0], 0FFh
           jne L_MDend
           cmp bfPauseDrv, 0FFh            ; Пауза?
           jne L_SDend                     ; Переход, если нет 
           lea bx, Drive.wPause
           mov cx, 0
           call Pause
           jnz L_SDend 
           mov bfPauseDrv, 00h             ; Прервать паузу  
           not bfDirection                 ; Поменять направление  
 L_SDend:           
           ret
StopDrv    EndP 

OutDrive   Proc  
           cmp bfPauseDrv, 0FFh
           je L_ODend           
           lea bx, Drive.wSpeed 
           mov cx, 0
           call Pause
           jnz L_ODout           
           cmp bfDirection, 0FFh
           jne L_ODleft
           ror bDriver, 1
           jmp L_ODout
 L_ODleft:           
           rol bDriver, 1           
 L_ODout:
           mov al, bDriver
           and al, bfOutDevice[0]
           out pDRIVER_OUT, al           
 L_ODend:           
           ret
OutDrive   EndP   

UpdDrvPar  Proc
           push ax es
           cmp bfOutDevice[0], 0FFh
           jne L_UDPend
           cmp Drive.wWork, 00
           jne L_UDPstop
           mov ax, DriveTmp.wWork           
           mov Drive.wWork, ax
 L_UDPstop:           
           cmp Drive.wPause, 0
           jne L_UDPspeed
           mov ax, DriveTmp.wPause
           mov Drive.wPause, ax          
 L_UDPspeed:
           cmp Drive.wSpeed, 0
           jne L_UDPtype
           mov ax, DriveTmp.wSpeed
           mov Drive.wSpeed, ax            
 L_UDPtype:       
           mov al, DriveTmp.bfTypeDir          
           mov Drive.bfTypeDir, al
 L_UDPend:
           pop es ax
           ret 
UpdDrvPar  EndP

ZeroDrv    Proc
           mov Drive.wSpeed, 0000
           mov Drive.wWork, 0000
           mov Drive.wPause, 0000
           ret
ZeroDrv    EndP