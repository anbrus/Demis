;Модуль "Отсчет времени"
Timer      PROC  NEAR
           xor   ax,ax
           mov   al,Pos
           push  ax
           cmp   RunFlag,0
           jz    TJMP
           
           ;начинаем вычитать

           xor   ax,ax
           mov   Pos,6
           mov   al,6
           mov   si,ax           
           dec   si
TLoop:           
           dec   TimePred[si]
           cmp   TimePred[si],0ffh
           je    TZero           
           jmp   TExit
TZero:
           cmp   Pos,6
           je    T6
           cmp   Pos,5
           je    T5
           cmp   Pos,4
           je    T6
           cmp   Pos,3
           je    T5
           cmp   Pos,2
           je    T2
T6:           
           mov   TimePred[si],9
           dec   si
           dec   Pos
           jmp   TLoop
T5:
           mov   TimePred[si],5
           dec   si
           dec   Pos
           jmp   TLoop
TJmp:                   
           JMP   TExit ;эта метка - промежуточная, т.к. не можем долететь до выхода
T2:        
           cmp   MicrOutFlag,0
           je    TSoundOn
           
           cmp   TenSecLeftFlag,0
           jz    TSet10Delay    
           mov   msgTimeOutFlag,0
           mov   msgMicrOutFLag,1
           mov   RunFlag,0
           mov   PosFlag,0   
           jmp   TClearExit           
TSet10Delay:
           mov   word ptr TimePred[0],0  ;обнуляем часы
           mov   word ptr TimePred[2],0  ;обнуляем минуты
           mov   TimePred[4],1h          ;отсчет еще 10 сек. 
           mov   TimePred[5],0h 
           mov   msgTimeOutFlag,1        ;выводим сообщение "Time out"           
           mov   TENSecLeftFlag,1        ;не отображаем 10 сек задержку на индикаторах
           jmp   TExit
           
TSoundOn:
           mov   msgTimeOutFlag,1
           mov   RunFlag,0
           mov   PosFlag,0                    

TClearExit:                        
           mov   cx,3          ;обнуляем массивы TimePred 
           xor   ax,ax
           lea   di,TimePred
           rep   stosw                   
TExit:
           pop   ax
           mov   Pos,al
           ret           
Timer      ENDP
