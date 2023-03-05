;Модуль "Задержка между сообщениями"
TenSecDellay  PROC NEAR
           cmp   MicrOutFlag,0
           jne   TSDExit
           cmp   MsgTimeOutFlag,0
           jne   TSDSet
         
           jmp   TSDExit
TSDSet:           
           mov   word ptr TimePred[0],0  ;обнуляем часы
           mov   word ptr TimePred[2],0  ;обнуляем минуты
           mov   TimePred[4],1h          ;отсчет еще 10 сек. 
           mov   TimePred[5],0h 
           mov   msgTimeOutFlag,1        ;выводим сообщение "Time out"           
           mov   TENSecLeftFlag,1        ;не отображаем 10 сек задержку на индикаторах
           
TSDExit:
           ret                    
TenSecDellay  ENDP