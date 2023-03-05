;Модуль "Считывание клавиш управления"
ReadCtrlKeys PROC NEAR
           in    al,KbdPort
           and   al,01111000b ;выделяем клавиши управления
           cmp   al,00001000b 
           je    RKNewDok     ;нажата кнопка "Новый докладчик"
           cmp   al,00010000b 
           je    RKPusk       ;--||----||-- "Пуск"
           cmp   al,00100000b
           je    RKSbros      ;--||----||-- "Сброс"
           cmp   al,01000000b
           je    RKMicrOut    ;--||----||-- "С отключением микрофона"
           jmp   RKExit
;обрабатываем "Новый докладчик"
RKNewDok:
           call  VibrDestr           
           call  NewDokBtn          
           jmp   RKExit           
;обрабатываем "Пуск"
RKPusk:
           cmp   DispMsgFlag,0 ;если выводится сообщение, то не считываем клавиши           
           jnz   RKExit
           cmp   RunFlag,0     ;если вкл. режим "Отсчет", то выходим
           jnz   RKExit    
           call  VibrDestr
           ;call  PuskBtn
           cmp   PuskFlag,1
           jne   RKPExit           
           ;call  SaveTimePredToRAM
           push  cx
           mov   cx,3        ;мы сможем скопировать за 3 цикла
           lea   si,TimePred
           lea   di,TimeInMem
           REP   MOVSW       ;переслать слово, Rep-префикс повторения 
           pop   cx
           mov   RunFlag,1    ;включаем режим "Отсчет"
RKPExit:           
           jmp   RKExit           
;обрабатываем "Сброс"
RKSbros:
           call  VibrDestr
           call  FuncPrep 
           jmp   RKExit           
;обрабатываем "Microphone out"
RKMicrOut:
           cmp   DispMsgFlag,0 ;если выводится сообщение, то не считываем клавиши
           jnz   RKExit
           cmp   RunFlag,0    ;если вкл. режим "Отсчет", то выходим
           jnz   RKExit    
           call  VibrDestr
           ;call  MicrOutBtn
RKMOLoop:           
           in    al,KbdPort
           and   al,01000000b ;выделяем только кнопку микрофона
           cmp   al,01000000b ;если кнопка отжата, то выходим
           je    RKMOLoop           
           
           cmp   MicrOutFlag,00h
           jz    RKMicrOFF
           mov   MicrOutFlag,00h ;без отключения микрофона
           jmp   RKExit
RKMicrOFF:
           mov   MicrOutFlag,1   ;с отключеним микрофона           
;          jmp   RKExit                      
RKExit:
           ret
ReadCtrlKeys ENDP


;Подмодуль "Кнопка "Отключение микрофона""
;MicrOutBtn PROC  NEAR
;MOBLoop:
;           in    al,KbdPort
;           and   al,01000000b ;выделяем только кнопку микрофона
;           cmp   al,01000000b ;если кнопка отжата, то выходим
;           je    MOBLoop           
;           
;           cmp   MicrOutFlag,00h
;           jz    MicrOFF
;           mov   MicrOutFlag,00h ;без отключения микрофона
;           jmp   MOExit
;MicrOFF:
;           mov   MicrOutFlag,1   ;с отключеним микрофона           
;MOExit:
;           ret
;MicrOutBtn ENDP           

;Подмодуль "Кнопка "Сброс""
;SbrosBtn   PROC  NEAR
;           call  FuncPrep        
;           ret
;SbrosBtn   ENDP

;Подмодуль "Сохранение времени председателя в ОЗУ"
;SaveTimePredToRAM PROC NEAR
;           push  cx
;           mov   cx,3        ;мы сможем скопировать за 3 цикла
;           lea   si,TimePred
;           lea   di,TimeInMem
;           REP   MOVSW       ;переслать слово, Rep-префикс повторения 
;           pop   cx
;           ret
;SaveTimePredToRam ENDP           

;Подмодуль "Кнопка "Новый докладчик""
NewDokBtn  PROC  NEAR                 
           call  Clear       ;очищаем все
           mov   cx,3
           lea   si,TimeInMem
           lea   di,TimePred
           REP   MOVSW
           mov   cx,6

           mov   Pos,6       ;выводим в Pos = 6
           mov   PosFlag,0   ;позиция не нажата ниразу
           xor   al,al
           out   EPort,al    ;гасим свет
           mov   msgTimeOutFlag,0
           mov   msgMicrOutFlag,0
           mov   MicrOutFlag,0
           mov   RunFlag,0
           mov   TENSecLeftFlag,0
           mov   DispMsgFlag,0
           mov   PuskFlag,1
           mov   MinLeftFlag,0
NDLoop:              
           push  0000                 
           push  cx
           push  cx
           call  Znakomesto
           loop  NDLoop         
           ret
NewDokBtn  ENDP  