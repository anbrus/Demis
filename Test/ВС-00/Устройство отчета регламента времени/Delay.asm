;Модуль "Задержка вывода на индикаторы"
Delay      PROC  NEAR  
           push  cx
           cmp   MicrOutFlag,0
           jnz    D1         
           cmp   MsgTimeOutFlag,0
           jnz   DExit
D1:
           cmp   MsgMicrOutFlag,0
           jnz   DExit
 
           mov   cx,0ffffh           
DLoop:           
           sub   cx,1
           add   cx,1
           sub   cx,1
           add   cx,1
           ;sub   cx,1
           ;add   cx,1
           ;sub   cx,1
           ;add   cx,1
           loop  DLoop           
           
DExit:           
           pop   cx
           ret
Delay      ENDP      
