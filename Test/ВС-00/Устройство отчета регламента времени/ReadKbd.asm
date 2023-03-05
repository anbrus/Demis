;Модуль "Считывание кнопок клавиатуры"           
ReadKbdKeys  PROC  NEAR
           cmp   RunFlag,0      ;если вкл. режим "Отсчет", то выходим
           jnz   ITExit    
           cmp   DispMsgFlag,0  ;если выводится сообщение, то клавиши не считываем
           jnz   ITExit
           in    al,KbdPort
           and   al,00000111b
           cmp   al,00000001b    ;если не нажата "+" , то проверяем следующ. кнопк.    
           je    ITPlusBtn           
           cmp   al,00000010b    ;если не нажата "-" , то провер. сл. кн.    
           je    ITMinusBtn          
           cmp   al,00000100b    ;если не нажата "позиция", то выход           
           je    ITChangePos           
           jmp   ITExit
ITPlusBtn:      
           cmp   PosFlag,0
           je    ITExit                
           mov   KbdFlag,1      ;нажата клавиша 
           call  VibrDestr
           call  IncNaschet     ;нажата кнопка "+"
           jmp   ITExit
ITMinusBtn:  
           cmp   PosFlag,0
           je    ITExit              
           mov   KbdFlag,1      ;нажата клавиша 
           call  VibrDestr
           call  DecNaschet     ;нажата кнопка "-"
           jmp   ITExit                
ITChangePos:
           mov   KbdFlag,1      ;нажата клавиша 
           call  VibrDestr
           call  ChangePos      ;нажата кнопка "Позиция"
                                         
ITExit:    
           ret
ReadKbdKeys  ENDP