;Модуль "обработка кнопки "Отключение микрофона""
MicrOutBtn PROC  NEAR

           cmp   RunFlag,0    ;если вкл. режим "Отсчет", то выходим
           jnz   MOBExit  
           cmp   msgTimeOutFlag,1
           je    MOBExit
           in    al,KbdPort
           and   al,01000000b
           cmp   al,01000000b
           jne   MOBExit
           call  VibrDestr       
           cmp   MicrOutFlag,00h
           jz    MOBMicrOFF
           mov   MicrOutFlag,00h ;без отключения микрофона
           jmp   MOBExit
MOBMicrOFF:
           mov   MicrOutFlag,1   ;с отключеним микрофона           
MOBExit:
           ret
MicrOutBtn ENDP                           