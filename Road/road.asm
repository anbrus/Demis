.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096


Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:code,es:code
         
a db ? 
b db       01h,02h,04h,08h,10h,20h,40h,80h

Start:
           mov   ax,code
           mov   ds,ax
           mov   es,ax
       
;Здесь размещается код программы
           mov bp,0FFF0h
a2:    
           mov  cl,8

a1:   
 
           in al,0
           test al,10
           jz a9
           sub bp,0F00h
a9:        

           in al,0
           test al,1
           jz a10
           add bp,0F00h
a10:        
           jnc a11
           mov bp,0FFFFh 
a11:           

           cmp bp,0FFFh
           jae a12
           mov bp,0FFFh 
           
a12:          
                    
           cmp bp,0FFFh
           jne  a7
           mov al,2
           mov dh,2
           add al,dl
           out 1,al
           jmp a6
a7:
           mov al,dl
           mov dh,0
           out 1,al  
               
           cmp bp,0FFFFh
           jne  a6
           mov al,1
           mov dh,1
           add al,dl
           out 1,al   
           
a6:
          
           push cx
           mov cx,bp
delay:     dec cx
           jnz delay
           pop cx  

           in    al,0
           test  al,100
           jz a3   
           mov al,4
           mov dl,4
           add al,dh
           out 1,al
           jmp a4     
a3:
           mov al,0
           mov dl,0
           add al,dh
           out 1,al
           mov  al,cl
           dec  cl
           xlat          
           out  0,al
           cmp al,0
           jnz a1
           jmp a2
a4:        
           cmp cl,7
           jng  a5
           xor cl,cl
           jmp a1
a5:
           inc cl
           mov al,cl
           xlat
           out 0,al
           cmp cl,8
           jne a1
           mov cl,0
           jmp a1  
                         


;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
