;Модуль "Обработка кнопки "+"" 
IncNaschet PROC  NEAR
           cmp   RunFlag,0      ;если вкл. режим "Отсчет", то выходим
           jnz   INExit    
           cmp   PosFlag,0
           je    INExit
           in    al,KbdPort
           and   al,00000001b
           cmp   al,00000001b    ;если не нажата "+" , то проверяем следующ. кнопк.    
           jne   INExit
           call  VibrDestr       ;Устраняем дребезг           
           mov   PuskFlag,1
           xor   ax,ax
           mov   al,Pos
           mov   si,ax
           dec   si
           inc   TimePred[si]                     
           
           cmp   Pos,6       ;если поз. 6 - младшая часть секунд
           je    IN6
           cmp   Pos,5       ;если поз. 5 - старшая часть секунд
           je    IN5
           cmp   Pos,4       ;если поз. 4 - младшая часть минут
           je    IN6
           cmp   Pos,3       ;если поз. 3 - старшая часть минут
           je    IN5  
           cmp   Pos,2       ;если поз. 2 - младшая часть часов
           je    IN2
                             ;макс 04:59:59
           jmp   INExit
IN6:
           cmp   TimePred[si],10 ;если =10, то установка на 0
           jne   INExit
           mov   TimePred[si],0
           jmp   INExit
IN5:       
           cmp   TimePred[si],6    
           jne   INExit
           mov   TimePred[si],0
           jmp   INExit
IN2:
           cmp   TimePred[si],5
           jne   INExit
           mov   TimePred[si],0              
                            
INExit:           
           ret
IncNaschet  ENDP
