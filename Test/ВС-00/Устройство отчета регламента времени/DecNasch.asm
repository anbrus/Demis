;Модуль "Обработка кнопки "-""
DecNaschet PROC  NEAR
           cmp   RunFlag,0      ;если вкл. режим "Отсчет", то выходим
           jnz   DNExit    
           cmp   PosFlag,0
           je    INExit
           in    al,KbdPort
           and   al,00000010b
           cmp   al,00000010b    ;если не нажата "-" , то проверяем следующ. кнопк.    
           jne   DNExit    
           call  VibrDestr       ;устраняем дребезг       
           mov   PuskFlag,1
           xor   ax,ax
           xor   si,si
           mov   al,Pos
           mov   si,ax
           dec   si
           dec   TimePred[si]                     
           
           cmp   Pos,6       ;если поз. 6 - младшая часть секунд
           je    DN6
           cmp   Pos,5       ;если поз. 5 - старшая часть секунд
           je    DN5
           cmp   Pos,4       ;если поз. 4 - младшая часть минут
           je    DN6
           cmp   Pos,3       ;если поз. 3 - старшая часть минут
           je    DN5  
           cmp   Pos,2       ;если поз. 2 - младшая часть часов
           je    DN2
                             ;мин 00:00:00
           jmp   INExit
DN6:
           cmp   TimePred[si],0ffh ;если <0 то = 9
           jne   DNExit
           mov   TimePred[si],9
           jmp   INExit
DN5:       
           cmp   TimePred[si],0ffh
           jne   DNExit
           mov   TimePred[si],5
           jmp   INExit           
DN2:
           cmp   TimePred[si],0ffh
           jne   DNExit
           mov   TimePred[si],4              
                            
DNExit:           
           ret
DecNaschet ENDP  