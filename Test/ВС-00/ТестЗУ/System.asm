ClearDisp PROC NEAR             ; Процедура очистки дисплея
           push  ax                   
           xor   al,al
           out   0,al
           out   1,al
           out   2,al
           out   3,al
           out   4,al                                            
           pop   ax            
           ret
ClearDisp ENDP


Drebezg  PROC  NEAR              ; Устранение дребезга
D1:        mov   ah,al
           mov   bh,0            ;Сброс счётчика повторений           
D2:        in    al,KeyInPort    ;Ввод текущего состояния
           cmp   ah,al           ;Текущее состояние=исходному?
           jne   D1              ;Переход, если нет
           inc   bh              ;Инкремент счётчика повторений

           cmp   bh,50           ;Конец дребезга?           
           jne   D2              ;Переход, если нет
           mov   al,ah
           ret
Drebezg  ENDP



Writeadress PROC NEAR            ; Процедура формирования адресов         
           push  ax di             ; границ тестируемого блока

           cmp   indicator,4
           jne   Wr0          
           mov   ah,AdrHex[di]
           shl   ah,4
           xor   al,al
           mov   regadr,ax
           jmp   Exwr
           
Wr0:       cmp   indicator,3
           jne   Wr1
           mov   ah,AdrHex[di]           
           shl   ah,4
           xor   al,al
           mov   ofsadr,ax
           jmp   Exwr
           
Wr1:       cmp   indicator,2
           jne   Wr2
           mov   ah,AdrHex[di]
           xor   al,al
           add   ofsadr,ax
           jmp   Exwr
           
Wr2:       cmp   indicator,1
           jne   Wr3
           mov   al,AdrHex[di]           
           shl   al,4
           xor   ah,ah
           add   ofsadr,ax
           jmp   Exwr
           
Wr3:       cmp   indicator,0
           jne   ExWr       
           mov   al,AdrHex[di]        
           xor   ah,ah
           add   ofsadr,ax

ExWr:      pop   ax di
           ret
Writeadress ENDP




KbInput    PROC NEAR            ; Опрос клавиатуры  
           push  ax dx
           mov   al,press
           cmp   al,0
           je    ExKb                      
           cmp   Sost,0ffh
           je    ExKb                      
           cmp   indicator,0
           je    K0
           sub   indicator,1
           jmp   K1
           
K0:        call  ClearDisp
           mov   indicator,4
           mov   al,press
           
K1:        mov   ah,0
Kb0:       cmp   al,1
           je    Kb1
           add   ah,1
           shr   al,1
           jmp   Kb0
           
Kb1:       mov   al,ah
                       
           mov   ah,NextKbLine  
                             
Kb2:       cmp   ah,1
           je    Kb3 
           shr   ah,1             
           add   al,4
           jmp   Kb2                        
Kb3:   
           xor   ah,ah
           mov   di,ax
           call  writeadress      
           mov   sost,2                
           mov   al,Obraz[di]
           mov   dx,word ptr indicator
           out   dx,al            
                      
ExKb:      pop   dx ax
           ret
KbInput    ENDP


AddDead    PROC  NEAR
           push  ax
           add   currentdead,4                      
           mov   ax,currentdead
           cmp   ax,totaldeadadr
           jb    add1
           mov   currentdead,0
Add1:      call  Mistmaches
           pop   ax
           ret
AddDead    ENDP


SubDead    PROC  NEAR
           push  ax
           cmp   currentdead,4
           jae   Sub1
           mov   ax,totaldeadadr
           mov   currentdead,ax
           
Sub1:      sub   currentdead,4  
           call  Mistmaches
           pop   ax
           ret
SubDead    ENDP
