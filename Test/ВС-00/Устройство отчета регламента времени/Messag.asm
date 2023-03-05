;в этом модуле процедуры для формирования разл. сообщений
;Модуль "Вывод сообщения "TimeOut" и "SoundOff""
DispMessages PROC NEAR
           xor   ax,ax
           mov   al,Pos
           push  ax
           cmp   msgTimeOutFlag,0
           jz    DMOtherFl           
           lea   si,MsgTimeOut
           jmp   DMDisp
DMOtherFl:           
           cmp   msgMicrOutFlag,0
           jz    DMExit
           lea   si,MsgSoundOff
           jmp   DMDisp           
DMDisp:           
           xor   ax,ax
           mov   ch,5         ;5-число индикаторов   
           mov   DX,40h       ;столбцы        
DSOutNextInd:
           mov   cl,ch
           mov   al,10000000b
           rol   al,cl
           out   EPort,al     ;включаем питание на нужных индикаторах портах

           mov   Pos,00000001b ;эту единицу будем сдвигать (столбец)          
           mov   cl,8
                     
DSOutNextCol:    
           xor   al,al
           out   DX,al     ;выкл индикатор (все столбцы)                 
           sub   DX,10h
           mov   al,[si]   ;считываем в al маску на строку
           not   al        ;инвертируем
           out   DX,al     ;выводим на строки индикатора
           mov   al,Pos    ;зажигаем следущий столбец
           add   DX,10h
           out   DX,al     ;---||---           
           inc   si        ;получаем смещение следующего элемента
           rol   Pos,1                                       
           dec   cl
           jnz   DSOutNextCol
           
           inc   DX
           dec   ch           
           jnz   DSOutNextInd        
DMExit:    
           pop   ax
           mov   Pos,al
           ret   
DispMessages ENDP           

;Модуль "Осталось 1 минута"
MinLeft    PROC  NEAR
           push  ax
           xor   ax,ax
           cmp   RunFlag,0
           jz    TLM1
           cmp   MinLeftFlag,0 ;если осталось <= 1 минута, то начинает мигать лампочка
           jz    TLCheck           
           cmp   MsgTimeOutFlag,1
           jne   TLOut
TLM1:
           mov   MinLeftFlag,0
TLOut:
           mov   al,MinLeftFlag
           out   IndiPort,al           
           jmp   TLExit
TLCheck:           
           lea   si,TimePred
           cmp   word ptr [si],0 ;проверяем часы
           jne   TLExit
           cmp   word ptr [si+2],0 ;проверяем минуты           
           jne   TLExit
           cmp   word ptr [si+4],0
           mov   MinLeftFlag,0
           jz    TLOut
           mov   MinLeftFlag,1
TLExit:    
           pop   ax
           ret
MinLeft   ENDP 
