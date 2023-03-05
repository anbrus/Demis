;------------------------------------------------------------
;
; String.asm - модуль обработки строк(может и не пригодится)
;
;------------------------------------------------------------

; AddChar  -     добавляет к строке символ
; ax       -     символ
; bx       -     смещение строки
;
AddChar    proc  near

           push  ax bx cx dx
           cmp   byte ptr [bx],11
           je    AddChar_end
           
           cmp   byte ptr [bx],1
           ja    AddChar_0
           cmp   byte ptr [bx+1],0+1
           jne   AddChar_0
           cmp   ax,11
           je    AddChar_0
           call  DeleteChar
  AddChar_0:           
           xor   cx,cx
           mov   cl,[bx]
           inc   byte ptr [bx]
           
           add   bx,cx
           cmp   cx,0
           jne    AddChar_1
           mov   [bx+1],al
           jmp   AddChar_end                      
  AddChar_1:           
           mov   dl,[bx]
           mov   [bx+1],dl
           dec   bx
           loop  AddChar_1
           mov   [bx+1],al
           
  AddChar_end:
           pop   dx cx bx ax
           ret
AddChar    endp

; DeleteChar     -     удаляет символ
; bx             -     смещение строки
;
DeleteChar proc  near
           push  bx cx dx
           cmp   byte ptr [bx],0
           je    DeleteChar_end
           xor   cx,cx
           mov   cl,[bx]
           dec   byte ptr [bx]
  DeleteChar_1:           
           mov   dl,[bx+2]
           mov   [bx+1],dl
           inc   bx
           loop  DeleteChar_1

  DeleteChar_end:           
           pop   dx cx bx           
           ret
DeleteChar endp

; InsertChar     -     вставляет символ в строку на указанную позицию
; bx             -     смещение строки
; ax             -     символ      
; dx             -     позиция      
;
InsertChar proc  near
InsertChar_baseStr  EQU [bp-2]
InsertChar_Char     EQU [bp-4]
InsertChar_Position EQU [bp-6]
           push  ax bx cx dx di         
           enter 6,0
           
           mov   di,dx
           mov   InsertChar_baseStr,bx
           mov   InsertChar_Position,di
           mov   InsertChar_Char,ax
           
           cmp   byte ptr [bx],11
           je    InsertChar_end
           
           xor   cx,cx
           mov   cl,[bx]
           add   bx,cx
           sub   cx,di
           
  InsertChar_2:
           cmp   cx,0
           je    InsertChar_1
           dec   cx
           mov   al,[bx]
           mov   [bx+1],al
           dec   bx
           jmp   InsertChar_2
  InsertChar_1:
           
           mov   bx,InsertChar_baseStr
           mov   ax,InsertChar_Char
           mov   [bx+di+1],al
           inc   byte ptr [bx]           
  InsertChar_end:
           leave      
           pop   di dx cx bx ax
           ret
InsertChar endp

; CalculateMantissa - Вычисление мантиссы вещественного числа;
; di                - задает ячейку памяти, в которую нужно положить мантиссу
; bx                - база строки по котороя считаем мантиссу                  
;
CalculateMantissa proc near
           push  ax bx cx dx si
           
           xor   ax,ax
           xor   dx,dx
           mov   cx,10
           xor   dx,dx
           mov   dl,[bx]
           mov   si,dx

  CalculateMantissa_0:   
           mov   al,[bx+si]
           dec   si
           
           cmp   al,11
           je    CalculateMantissa_0
           dec   al
                     
           call  Mul128bitToDW
           add   [di],ax
           adc   word ptr [di+2],0

           cmp   si,0               
           jnz   CalculateMantissa_0
 
  CalculateMantissa_end:
           pop   si dx cx bx ax
           ret
CalculateMantissa endp

; CalculateOrder - Расчет порядка вещественного числа;
; di             - задает ячейку памяти, в которую нужно положить порядок
; bx             - база строки         
;
CalculateOrder   proc near
CalculateOrder_PointPos EQU [bp-2]
CalculateOrder_NumPos   EQU [bp-4]

           push  ax bx cx si
           enter 4,0
           xor   ax,ax
           mov   al,[bx]
           cmp   NFlags.FPoint,0 
           jne   CalculateOrder_1 
           mov   [di],al            
           jmp   CalculateOrder_end    

  CalculateOrder_1:
           mov   si,ax
           inc   si
  CalculateOrder_2:
           dec   si
           cmp   si,0
           je    CalculateOrder_3
           
           cmp   byte ptr [bx+si],1
           je    CalculateOrder_2
           cmp   byte ptr [bx+si],11
           je    CalculateOrder_2
           mov   CalculateOrder_NumPos,si
           
           mov   si,ax
           inc   si
  CalculateOrder_4:
           dec   si
           cmp   byte ptr [bx+si],11
           jne   CalculateOrder_4
           mov   CalculateOrder_PointPos,si
           
           mov   ax,CalculateOrder_NumPos
           mov   cx,CalculateOrder_PointPos
           cmp   al,cl
           ja    CalculateOrder_5
           inc   al
  CalculateOrder_5:           
           sub   al,cl
           
           mov   [di],al                                            
           jmp   CalculateOrder_end           
  CalculateOrder_3:
           mov   byte ptr [di],0           
  CalculateOrder_end:
           leave
           pop si cx bx ax
           ret
CalculateOrder   endp



; StrToFloat -   переводит строку в TQuantity128bit
; bx - смещение строки
; di - смещение числа
;
StrToFloat proc  near
           push  ax
           xor   ax,ax
           call  Clear128bit

           cmp   byte ptr [bx],0     ; если строка пуста,
           je    StrToFloat_end      ; то вещественное
                                     ; число - нулевое

           inc   di                  ; вычисление
           call  CalculateMantissa   ; мантиссы
           dec   di

           call  Mant128bitNorm      ; ее нормализация

           call  CalculateOrder      ; расчет порядка

           cmp   NFlags.FSignum,1    ; если в строке есть
           jne   StrToFloat_end      ; знак "-", то
           call  Neg128bit           ; обращение знака числа
           
  StrToFloat_end:         
           pop   ax
           ret
StrToFloat endp

; MantissaConvert - Преобразование мантиссы; параметры:
; si              - задает смещение числа
; bx              - база строки
;
MantissaConvert proc near
           push  ax cx dx di si
           
           xor   dx,dx
           lea   di,Work
           call  Clear128bit           
           
           mov   cx,10
  MantissaConvert_1:
           xchg  di,si
           inc   di
           call  Div128bitToDW
           dec   di
           xchg  di,si           
           
           cmp   byte ptr [bx],11
           jne   MantissaConvert_1_2 
           call  DeleteChar
  MantissaConvert_1_2:
  
           mov   ax,modulo
           inc   ax
           mov   dl,[bx]
           call  InsertChar
           call  Cmp128bit
           cmp   ax,0
           jne   MantissaConvert_1
           
  MantissaConvert_2:
           cmp   byte ptr [bx+1],0+1
           jne   MantissaConvert_end
           call  DeleteChar
           jmp   MantissaConvert_2
  MantissaConvert_end:
           pop   si di dx cx ax
           ret
MantissaConvert endp

; OrderConvert   - Преобразование порядка {расстановка точки};
; si             - задает ячейку, из которой следует взять порядок
; bx             - база строки
;
OrderConvert proc near
OrderConvert_Exp EQU [bp-2]
           push  ax bx cx
           enter 2,0
           xor   ax,ax
           mov   al,byte ptr [si]
           mov   OrderConvert_Exp,ax
           cmp   al,10
           jng   OrderConvert_0_1
           jmp   OrderConvert_FP
  OrderConvert_0_1:
           cmp   al,-8
           jnl   OrderConvert_0_2
           jmp   OrderConvert_FP
  OrderConvert_0_2:         
           cmp   al,0
           jle   OrderConvert_LNull
           
           cmp   al,[bx]
           jg    OrderConvert_AddNull
           jne   OrderConvert_AddPoint_1
           jmp   OrderConvert_end       
           
           
  OrderConvert_AddPoint_1:
           xor   dx,dx
           cmp   byte ptr [bx],11
           jne   OrderConvert_AddPoint
           call  DeleteChar
  OrderConvert_AddPoint:
           mov   dl,[bx]           
           sub   dl,al
           mov   ax,11
           call  InsertChar
           jmp   OrderConvert_end
           
  OrderConvert_AddNull:
           mov   cx,ax
           sub   cl,[bx]
           mov   ax,1
  OrderConvert_AddNull_1:
           call  AddChar
           loop  OrderConvert_AddNull_1
           jmp   OrderConvert_end
           
  OrderConvert_LNull:
           not   al
           inc   al
  OrderConvert_LNull_0:
           cmp   al,0
           je    OrderConvert_LNull_1
                      
           cmp   byte ptr [bx],11
           jne   OrderConvert_LNull_1_1
           call  DeleteChar
           
  OrderConvert_LNull_1_1:
           
           dec   al
           push  ax
           xor   dx,dx
           mov   ax,1
           mov   dl,[bx]
           call  InsertChar
           pop   ax
           jmp   OrderConvert_LNull_0           
           
  OrderConvert_LNull_1:
           cmp   byte ptr [bx],11
           jne   OrderConvert_LNull_2
           
           call  DeleteChar           
  OrderConvert_LNull_2:
           mov   ax,11
           xor   dx,dx
           mov   dl,[bx]
           call  InsertChar
           cmp   byte ptr [bx],11
           jne   OrderConvert_LNull_3
           
           call  DeleteChar           
  OrderConvert_LNull_3:
           mov   ax,1
           xor   dx,dx
           mov   dl,[bx]
           call  InsertChar
           
           jmp   OrderConvert_end
           
  OrderConvert_FP:
           ; реализуем FP вывод
           cmp   byte ptr [bx],6
           jbe   OrderConvert_FP_1
           call  DeleteChar
           jmp   OrderConvert_FP
           
  OrderConvert_FP_1:
           mov   ax,11
           xor   dx,dx
           mov   dl,[bx]
           call  InsertChar
           mov   ax,1
           xor   dx,dx
           mov   dl,[bx]
           call  InsertChar
           
           mov   ax,0
           call  AddChar
           call  AddChar
           call  AddChar
           mov   ax,OrderConvert_Exp
           cmp   al,0
           jg    OrderConvert_FP_2
           not   al
           inc   al
           mov   byte ptr [bx+3],13
  OrderConvert_FP_2:
           mov   cl,10
           div   cl
           inc   ah
           mov   byte ptr [bx+1],ah
           inc   al
           mov   byte ptr [bx+2],al           
  OrderConvert_end:  
           leave
           pop   cx bx ax
           ret
OrderConvert endp

; FloatToStr -   переводит TQuantity128bit в строку(TString), взводит(если необходимо) флаги 
; отображает(если необходимо) строку в FP представлении
; di - адрес числа
; bx - адрес строки
;
FloatToStr proc  near
FloatToStr_baseStr  EQU [bp-2]
FloatToStr_baseQ    EQU [bp-4]
           push  ax bx di
           enter 4,0
           xor   ax,ax
           mov   FloatToStr_baseStr,bx
           mov   FloatToStr_baseQ,di
           
           call  ClearStr
           mov   NFlags.FSignum,0
           
           lea   si,Work
           xchg  di,si
           call  Clear128bit
           xchg  di,si
           call  Cmp128bit
           cmp   ax,0
           je    FloatToStr_end
           
           
           mov   ax,[di+13]
           shr   ax,15           
           jz    FloatToStr_NNeg
           xor   ax,ax
           call  Neg128bit
           mov   al,0FFh
           push  ax
           
  FloatToStr_NNeg:
             
           mov   si,di
           push  word ptr [si]
           push  word ptr [si+2]
           push  word ptr [si+4]
           push  word ptr [si+6]
           push  word ptr [si+8]
           push  word ptr [si+10]
           push  word ptr [si+12]
           push  word ptr [si+14]
           
           call  MantissaConvert
           call  OrderConvert 
           
           pop   word ptr [si+14]
           pop   word ptr [si+12]
           pop   word ptr [si+10]
           pop   word ptr [si+8]
           pop   word ptr [si+6]
           pop   word ptr [si+4]
           pop   word ptr [si+2]
           pop   word ptr [si]
           
           pop   ax
           cmp   al,0FFh
           jne    FloatToStr_end
           call  Neg128bit
           mov   NFlags.FSignum,1
           
  FloatToStr_end:         
           leave
           pop   di bx ax
           ret
FloatToStr endp