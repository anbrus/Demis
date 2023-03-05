;Модуль "Вывод текущего времени на индикаторах "Председателя" и "Докладчика""
DispTime PROC NEAR
           cmp   TENSecLeftFlag,0 ;если с выключением микрофона, то сообщения в дополнительные
           jnz   DRTExit          ;10 секунд не выводим на индикаторы                                 
           mov   si,5
           cmp   FirstRunFlag,1
           jne   DRT12Indi
           cmp   RunFlag,0
           jne   DRT12Indi
           mov   cx,6          
           jmp   DRTDisp                      
DRT12Indi: 
           mov   FirstRunFlag,1 
           mov   cx,12             
DRTDisp:            

           mov   al,TimePred[si]                      
           lea   bx,Digits
           xlat  TimePred    ;в al получили образ выводимой цифры        

           ;выбираем в каких случаях зажигать точку

           cmp   PosFlag,0   ;В режиме "Не нажата кн. "Позиция""
           je    ZPointOFF   ;Гасим точку
           cmp   RunFlag,1   ;В режиме "Отсчет"
           je    ZPointOff   ;Гасим точку
           cmp   cl,Pos      ;если номер индикатора совпадает с тек. позицией,
           jne   ZpointOFF   ;то выводлим точку
           or    al,10000000b;если 1, то зажигаем точку  
           jmp   ZDispZnak                    
ZPointOff:          
           and   al,01111111b
           jmp   ZDispZnak

ZDispZnak:
           xor   dx,dx
           mov   dl,cl   ;выводим в порт №cx
           out   dx,al
           dec   si
           jz    DRTZero
           loop  DRTDisp
           jmp   DRTExit
DRTZero:
           mov   si,6                                       
           loop  DRTDisp 
DRTExit:           
           ret
DispTime ENDP            