;Модуль "Обработка кнопки "Новый докладчик""
SbrosBtn   PROC  NEAR
           
           in    al,KbdPort
           and   al,00100000b ;выделяем клавиши управления
           cmp   al,00100000b
           jne   SBExit       
           call  VibrDestr
           
           xor   dx,dx    
           xor   ax,ax           
           out   EPort,al
           mov   cx,12       ;12-число индикаторов
           mov   al,03fh
SBClearLoop:
           inc   dx
           out   dx,al           
           loop  SBCLearLoop
           
           mov   msgTimeOutFlag,0    ;флаг сообщения "Time out" 
           mov   msgMicrOutFlag,0    ;флаг сообщения "Sound off"
           mov   TENSecLeftFlag,0
          
           mov   RunFlag,0     ;устанавливаем режим "Ввода"
           mov   PosFlag,0     ;устанавливаем 0 - кнопка "Позиция" не нажата ни разу
           mov   PuskFlag,0    ;устанавливаем 0 - кнопка "Пуск" не нажата ни разу
           xor   al,al
           out   EPort,al      ;0 на порт питание           
           mov   MicrOutFlag,0 ;0 - микрофон работает, 1 - микрофон будет отключен
           mov   MinLeftFlag,0          
           mov   Pos,6         ;начинаем ввод с младшей позиции
      
           mov   cx,6          ;обнуляем массивы TimePred и TimeInMem
           xor   ax,ax
           lea   di,TimePred
           rep   stosw           
SBExit:           
           ret
SbrosBtn   ENDP          