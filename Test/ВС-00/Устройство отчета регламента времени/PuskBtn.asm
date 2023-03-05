;Модуль "Обработка кнопки "Пуск""
PuskBtn    PROC  NEAR
           cmp   RunFlag,0
           jnz   PBExit
           cmp   PuskFlag,1
           jne   PBExit    
           in    al,KbdPort
           and   al,00010000b
           cmp   al,00010000b
           jne   PBExit
           call  VibrDestr                  
           mov   cx,3        ;мы сможем скопировать за 3 цикла
           lea   si,TimePred
           lea   di,TimeInMem
           REP   MOVSW       ;переслать слово, Rep-префикс повторения 
           mov   RunFlag,1   ;включаем режим "Отсчет"                 
PBExit:   
           ret        
PuskBtn    ENDP           