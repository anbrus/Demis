;Подмодуль "Гашение дребезга"
VibrDestr PROC NEAR
           push  dx
           push  ax 
VD1:      
           mov   ah,al       
           mov   bh,0
VD2:
           in    al,dx
           cmp   ah,al
           jne   vd1
           inc   bh
           cmp   bh,NMax
           jne   vd2
           mov   al,ah
           pop   ax
           pop   dx
           ret
VibrDestr endp 