;Модуль "Обработка кнопки "Позиция""           
Znakomesto PROC  NEAR
           cmp   RunFlag,0       ;если вкл. режим "Отсчет", то выходим
           jnz   ZExit    
           in    al,KbdPort
           and   al,00000100b
           cmp   al,00000100b    ;если не нажата "Позиция"
           jne   ZExit
           call  VibrDestr       ;устраняем дребезг
           cmp   PosFlag,0
           jnz   ZNext
           mov   PosFlag,1          
           jmp   ZExit           
ZNext:         
           dec   Pos        
           cmp   Pos,1
           jne    ZExit
           mov   Pos,6                    
ZExit:                             
           ret
Znakomesto ENDP