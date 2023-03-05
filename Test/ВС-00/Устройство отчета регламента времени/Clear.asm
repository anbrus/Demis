;Подмодуль "Очистка экрана"            
Clear      PROC  NEAR
           push  dx
           push  ax 

           
           xor   dx,dx    
           xor   ax,ax
           out   IndiPort,al ;в порт двоичных индикаторов устанавливаем 0
           out   EPort,al
           mov   cx,12       ;12-число индикаторов
           mov   al,03fh
CLoop:
           inc   dx
           out   dx,al           
           loop  CLoop
           
           pop   ax
           pop   dx
           ret   
Clear      ENDP
