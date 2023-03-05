;Модуль "Функциональная подготовка"
FuncPrep   PROC  NEAR
;сообщение "SoundOff"
;1-0B3h, 0B5h, 0ADh, 0CDh, 0FFh, 0C3h, 0BDh, 0BDh
           mov   MsgSoundOff[0],0B3h
           mov   MsgSoundOff[1],0B5h
           mov   MsgSoundOff[2],0ADh
           mov   MsgSoundOff[3],0CDh
           mov   MsgSoundOff[4],0FFh
           mov   MsgSoundOff[5],0C3h
           mov   MsgSoundOff[6],0BDh
           mov   MsgSoundOff[7],0BDh
           
;2-0C3h, 0FFh, 0C1h, 0BFh, 0BFh, 0C1h, 0FFh, 081h
           mov   MsgSoundOff[8],0C3h
           mov   MsgSoundOff[9],0FFh
           mov   MsgSoundOff[10],0C1h
           mov   MsgSoundOff[11],0BFh
           mov   MsgSoundOff[12],0BFh
           mov   MsgSoundOff[13],0C1h
           mov   MsgSoundOff[14],0FFh
           mov   MsgSoundOff[15],081h
           
;3-0F3h, 0CFh, 081h, 0FFh, 081h, 0BDh, 0BDh, 0C3h
           mov   MsgSoundOff[16],0F3h
           mov   MsgSoundOff[17],0CFh
           mov   MsgSoundOff[18],081h
           mov   MsgSoundOff[19],0FFh
           mov   MsgSoundOff[20],081h
           mov   MsgSoundOff[21],0BDh
           mov   MsgSoundOff[22],0BDh
           mov   MsgSoundOff[23],0C3h
           
;4-0FFh, 0FFh, 0C3h, 0BDh, 0BDh, 0C3h, 0FFh, 081h
           mov   MsgSoundOff[24],0FFh
           mov   MsgSoundOff[25],0FFh
           mov   MsgSoundOff[26],0C3h
           mov   MsgSoundOff[27],0BDh
           mov   MsgSoundOff[28],0BDh
           mov   MsgSoundOff[29],0C3h
           mov   MsgSoundOff[30],0FFh
           mov   MsgSoundOff[31],081h

;5-0F5h, 0F5h, 0FDh, 0FFh, 081h, 0F5h, 0F5h, 0FDh          
           mov   MsgSoundOff[32],0F5h
           mov   MsgSoundOff[33],0F5h
           mov   MsgSoundOff[34],0FDh
           mov   MsgSoundOff[35],0FFh
           mov   MsgSoundOff[36],081h
           mov   MsgSoundOff[37],0F5h
           mov   MsgSoundOff[38],0F5h
           mov   MsgSoundOff[39],0FDh
                   
;сообщение "TimeOut"
;1-0FFh, 0FDh, 0FDh, 081h, 0FDh, 0FDh, 0F7h, 085h
           mov   MsgTimeOut[0],0ffh
           mov   MsgTimeOut[1],0fdh
           mov   MsgTimeOut[2],0fdh
           mov   MsgTimeOut[3],081h
           mov   MsgTimeOut[4],0fdh
           mov   MsgTimeOut[5],0fdh
           mov   MsgTimeOut[6],0f7h
           mov   MsgTimeOut[7],085h
           
;2-0FFh, 081h, 0F7h, 0FBh, 081h, 0F7h, 0FBh, 081h
           mov   MsgTimeOut[8],0ffh
           mov   MsgTimeOut[9],081h
           mov   MsgTimeOut[10],0f7h
           mov   MsgTimeOut[11],0fbh
           mov   MsgTimeOut[12],081h
           mov   MsgTimeOut[13],0f7h
           mov   MsgTimeOut[14],0fbh
           mov   MsgTimeOut[15],081h           
           
;3-0FFh, 0C3h, 0B5h, 0B5h, 0B3h, 0FFh, 0FFh, 0FFh

           mov   MsgTimeOut[16],0ffh
           mov   MsgTimeOut[17],0c3h
           mov   MsgTimeOut[18],0b5h
           mov   MsgTimeOut[19],0b5h
           mov   MsgTimeOut[20],0b3h
           mov   MsgTimeOut[21],0ffh
           mov   MsgTimeOut[22],0ffh
           mov   MsgTimeOut[23],0ffh

;4-0FFh, 0C3h, 0BDh, 0BDh, 0C3h, 0FFh, 0C1h, 0BFh
           mov   MsgTimeOut[24],0ffh
           mov   MsgTimeOut[25],0c3h
           mov   MsgTimeOut[26],0bdh
           mov   MsgTimeOut[27],0bdh
           mov   MsgTimeOut[28],0c3h
           mov   MsgTimeOut[29],0ffh
           mov   MsgTimeOut[30],0c1h
           mov   MsgTimeOut[31],0bfh
           
;5-0BFh, 0C1h, 0BFh, 0FBh, 0C1h, 0BBh, 0BBh, 0FFh           
           mov   MsgTimeOut[32],0bfh
           mov   MsgTimeOut[33],0c1h
           mov   MsgTimeOut[34],0bfh
           mov   MsgTimeOut[35],0fbh
           mov   MsgTimeOut[36],0c1h
           mov   MsgTimeOut[37],0bbh
           mov   MsgTimeOut[38],0bbh
           mov   MsgTimeOut[39],0ffh
                     
           mov   Digits[0],03fh
           mov   Digits[1],00Ch
           mov   Digits[2],076h
           mov   Digits[3],05Eh
           mov   Digits[4],04Dh
           mov   Digits[5],05Bh
           mov   Digits[6],07Bh
           mov   Digits[7],00Eh
           mov   Digits[8],07Fh
           mov   Digits[9],05Fh

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
           mov   FirstRunFlag,0     
           mov   Pos,6         ;начинаем ввод с младшей позиции
      
           mov   cx,6          ;обнуляем массивы TimePred и TimeInMem
           xor   ax,ax
           lea   di,TimePred
           rep   stosw

           ret
FuncPrep   ENDP