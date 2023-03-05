;------------------------------------------------------------
; Service.asm -  служебный модуль
; (ну там всякие вспомогательные процедуры)
;------------------------------------------------------------
; ClearAll  -     Очищает все
;

ClearAll   proc  near
           push  ax di
           xor   ax,ax
           mov   Operation.Prev2,ONull    ; ничего
           mov   Operation.Prev1,ONull
           mov   Operation.Curr,ONull
           mov   KeyCode,al
           mov   NFlags.FInput,al
           mov   NFlags.FIOper,al
           mov   NFlags.FNOS,al           
           mov   NFlags.FSignum,al
           mov   NFlags.FPoint,al
           mov   NFlags.FShift,al
           mov   NFlags.FMemory,al
           mov   NFlags.FEDbZ,al
           mov   NFlags.FEOvf,al
           mov   NFlags.FEIcP,al
           mov   NFlags.FEKbd,al
           mov   NFlags.FEDtB,al
           mov   NFlags.FEAdB,al
           
           mov   Error,al
           lea   bx,DisplayStr
           call  ClearStr
           
           lea   di,Memory
           call  Clear128bit
           lea   di,Work
           call  Clear128bit           
           lea   di,Work1
           call  Clear128bit
           lea   di,Work2
           call  Clear128bit           
           lea   di,Work3
           call  Clear128bit
           lea   di,Operands.QCurr
           call  Clear128bit
           lea   di,Operands.QPrev1
           call  Clear128bit
           lea   di,Operands.QPrev2
           call  Clear128bit           
                                            
           pop   di ax           
           ret
ClearAll   endp

; ClearStr  -     очищает строку(обнуляет StrLength)
; bx        -     смещение строки
;
ClearStr   proc  near
           push  bx
           mov   byte ptr [bx],1     ;    один символ
           mov   byte ptr [bx+1],0+1   ;    код нуля
           mov   NFlags.FSignum,0
           mov   NFlags.FPoint,0
           pop   bx
           ret
ClearStr   endp

; Undo     -     реагирует на "забой"         
; формирует FPoint, FSignum
;
Undo       proc  near
           push  bx
           cmp   DisplayStr.StrLength,0
           je    Undo_end
           cmp   DisplayStr.Str11[0],11
           jne   Undo_1
           mov   NFlags.FPoint,0
  Undo_1:
           lea   bx,DisplayStr
           call  DeleteChar
           cmp   DisplayStr.StrLength,0
           jne   Undo_end
           mov   NFlags.FSignum,0
           inc   byte ptr DisplayStr.StrLength
           mov   DisplayStr.Str11[0],1   
  Undo_end:
           pop   bx
           ret
Undo       endp

; InputNumber    -  просто для уменьшения кода         
; ax             -  введенная цифра
; ///////////////////////////////////
;     if(!FInput) ClearStr
;     FInput = 1
;     if(DisplayStr.StrLength == 11) Continue_end
;     AddChar(DisplayStr, "9")
;     FShift = 0
;     FIOper = 0
; ///////////////////////////////////
InputNumber proc near
           push  ax bx
           mov   NFlags.FIOper,0
           mov   NFlags.FShift,0
           mov   NFlags.FNOS,0
           cmp   NFlags.FInput,0
           jne   InputNumber_1
           lea   bx,DisplayStr
           call  ClearStr
  InputNumber_1:
           mov   NFlags.FInput,1
           cmp   DisplayStr.StrLength,11
           je    InputNumber_end
           
           lea   bx,DisplayStr
           inc   ax
           call  AddChar
           
  InputNumber_end:
           pop   bx ax           
           ret
InputNumber endp

; InputOperation -  просто для уменьшения кода         
; al - код операции, ah - модификатор        
; ///////////////////////////////////
;     if(!FIOper)
;     {
;                 OperationShift
;                 OperandsShift                 
;     }
;     if(FInput)Operands.Curr = SrtToFloat(DisplayStr)
;     FInput = 0
;     FIOper = 1
; ///////////////////////////////////
InputOperation  proc near
           push  ax bx di si
           cmp   NFlags.FIOper,0
           jne   InputOperation_1
           ; OperationShift
           mov   bl,Operation.Prev1
           mov   Operation.Prev2,bl
           mov   bl,Operation.Curr
           mov   Operation.Prev1,bl
           
           cmp   NFlags.FNOS,0
           jne   InputOperation_1
           ; OperandsShift
           lea   di,Operands.QPrev2
           lea   si,Operands.QPrev1
           call  Copy128bit           
           lea   di,Operands.QPrev1
           lea   si,Operands.QCurr
           call  Copy128bit
  InputOperation_1:
           cmp   NFlags.FInput,0
           je    InputOperation_2
           ; Operands.Curr = SrtToFloat(DisplayStr)
           lea   bx,DisplayStr
           lea   di,Operands.QCurr
           call  StrToFloat
  InputOperation_2:
           add   al,ah
           mov   Operation.Curr,al
           mov   NFlags.FInput,0
           mov   NFlags.FIOper,1
           mov   NFlags.FNOS,0
           
           pop   si di bx ax
           ret
InputOperation  endp

; CheckError     -  формирует Error
;
CheckError proc  near
           push  ax
           mov   Error,0
           cmp   NFlags.FEDbZ,1
           jne   CheckError_1
           mov   Error,1
           jmp   CheckError_end
  CheckError_1:
           cmp   NFlags.FEOvf,1
           jne   CheckError_2
           mov   Error,2
           jmp   CheckError_end
  CheckError_2:
           cmp   NFlags.FEIcP,1
           jne   CheckError_3
           mov   Error,3
           jmp   CheckError_end
  CheckError_3:
           cmp   NFlags.FEKbd,1
           jne   CheckError_4
           mov   Error,4
           jmp   CheckError_end
  CheckError_4:
           cmp   NFlags.FEDtB,1
           jne   CheckError_5
           mov   Error,5
           jmp   CheckError_end
  CheckError_5:
           cmp   NFlags.FEAdB,1
           jne   CheckError_6
           mov   Error,6
           jmp   CheckError_end
  CheckError_6:
              
  CheckError_end:
           pop   ax
           ret
CheckError endp

; Revise   -  в общем-то делает все остальное. этакий диспетчер, если хотите
; в зависимости от ранее сформированных Operation и Operands, по значения флагов
; она вызывает процедуры арифметики, формирует(вызывает процедуру) окончательно DisplayStr(или не меняет ее)
; формирует флаги
; 
Revise     proc  near
           push  ax bx cx dx di si
           
           cmp   Operation.Curr,OEqual
           jne   Revise_1
           
           ; QPrev1 Prev1 QCurr -> QCurr
           ; Prev2 -> Prev1
           ; ONull -> Prev2
           ; QPrev2 -> QPrev1
           mov   al,Operation.Prev1
           call  SelectAction
           cmp   al,ONull
           je    Revise_0
           mov   al,Operation.Prev2
           mov   Operation.Prev1,al
           mov   Operation.Prev2,ONull
           lea   di,Operands.QCurr
           lea   si,Operands.QPrev1
           call  Copy128bit
           lea   di,Operands.QPrev1
           lea   si,Operands.QPrev2
           call  Copy128bit
       
           lea   bx,DisplayStr
           lea   di,Operands.QCurr
           call  FloatToStr
           
  Revise_0:
           cmp   Operation.Prev1,ONull
           jne   Revise_end
           mov   Operation.Curr,ONull
           

           jmp   Revise_end
  Revise_1:
           cmp   Operation.Curr,ONull
           ja    Revise_2
           je    Revise_end
           ; QCurr Curr -> QCurr
           ; Prev1 -> Curr
           ; Prev2 -> Prev1
           ; ONull -> Prev2
           mov   al,Operation.Curr
           call  SelectAction
           mov   al,Operation.Prev1
           mov   Operation.Curr,al
           mov   al,Operation.Prev2
           mov   Operation.Prev1,al
           mov   Operation.Prev2,ONull
         
           
           lea   bx,DisplayStr
           lea   di,Operands.QCurr
           call  FloatToStr           
           mov   NFlags.FNOS,1
           mov   NFlags.FIOper,0
           jmp   Revise_end
  Revise_2:
           ; P[Curr]<P[Prev1]{
           ; QPrev1 Prev1 QCurr -> QCurr
           ; Prev2 -> Prev1
           ; ONull -> Prev2
           ; QPrev2 -> QPrev1    
           ; }
           mov   al,Operation.Curr
           call  GetPriority
           mov   ah,al
           mov   al,Operation.Prev1
           call  GetPriority
           cmp   ah,al
           ja    Revise_end
           
           mov   al,Operation.Prev1
           call  SelectAction
           mov   al,Operation.Prev2
           mov   Operation.Prev1,al
           mov   Operation.Prev2,ONull
           
           lea   di,Operands.QCurr
           lea   si,Operands.QPrev1
           call  Copy128bit
           lea   di,Operands.QPrev1
           lea   si,Operands.QPrev2
           call  Copy128bit
           
           lea   bx,DisplayStr
           lea   di,Operands.QCurr
           call  FloatToStr
           
           
           jmp   Revise_end
  Revise_end:
           
           pop   si di dx cx bx ax  
           ret
Revise     endp

           ; ///////////////////////////////////
           ;     if(!FShift) {MemoryToWork; FInput = 0}
           ;     elseif(!FInput) WorkToMemory
           ;     else        DisplayToMemory;
           ;     FShift = 0
           ;     FIOper = 0
           ; ///////////////////////////////////
MemoryToWork proc near
           push  bx di si
           lea   si,Memory
           lea   di,Operands.QCurr
           call  Copy128bit
           lea   bx,DisplayStr
           call  FloatToStr
           pop   si di bx
           ret
MemoryToWork endp

WorkToMemory proc near
           push  bx di si
           mov   NFlags.FMemory,1
           lea   di,Memory
           lea   si,Operands.QCurr
           call  Copy128bit
           lea   di,Work
           lea   si,Memory
           call  Clear128bit
           call  Cmp128bit
           cmp   ax,0
           jne   WorkToMemory_end
           mov   NFlags.FMemory,0
  WorkToMemory_end:           
           pop   si di bx
           ret
WorkToMemory endp

DisplayToMemory proc near
           push  bx di si
           mov   NFlags.FMemory,1
           
           lea   bx,DisplayStr                    
           lea   di,Operands.QCurr
           call  StrToFloat
           lea   si,Memory
           xchg  di,si
           call  Copy128bit
           lea   di,Work
           lea   si,Memory
           call  Clear128bit
           call  Cmp128bit
           cmp   ax,0
           jne   DisplayToMemory_end
           mov   NFlags.FMemory,0
  DisplayToMemory_end:           
           pop   si di bx
           ret
DisplayToMemory endp

; GetPriority -  для уменьшения кода, получает коды операций, возвращает их приоритеты
; al          -  операция(0..15), приоритет(0..5)          
;
GetPriority proc near
           cmp   al,0
           ja    GetPriority_1
           mov   al,0
           jmp   GetPriority_end
  GetPriority_1:
           cmp   al,8
           ja    GetPriority_2
           mov   al,1
           jmp   GetPriority_end
  GetPriority_2:
           cmp   al,9
           ja    GetPriority_3
           mov   al,2
           jmp   GetPriority_end
  GetPriority_3:
           cmp   al,11
           ja    GetPriority_4
           mov   al,4
           jmp   GetPriority_end
  GetPriority_4:
           cmp   al,13
           ja    GetPriority_5
           mov   al,3
           jmp   GetPriority_end
  GetPriority_5:
           mov   al,0FFh
  GetPriority_end:
           ret
GetPriority endp

; SelectAction   - вызывает по переданным параметрам ар.или мат.действие
; al             - операция          
;
SelectAction proc near
           push  di si
           cmp   al,1
           ja    SelectAction_1
           ;     вызов SIN
           lea   di,Operands.QCurr
           call  Sin128bit
           jmp   SelectAction_end
  SelectAction_1:
           cmp   al,2
           ja    SelectAction_2
           ;     вызов COS
           lea   di,Operands.QCurr
           call  Cos128bit
           jmp   SelectAction_end
  SelectAction_2:
           cmp   al,3
           ja    SelectAction_3
           ;     вызов TAN           
           lea   di,Operands.QCurr           
           call  Tan128bit
           
           cmp   al,0
           jne   SelectAction_2_end
           mov   NFlags.FEIcP,1
  SelectAction_2_end:
           
           jmp   SelectAction_end
  SelectAction_3:
           cmp   al,4
           ja    SelectAction_4
           ;     вызов CTN
           lea   di,Operands.QCurr           
           call  Ctn128bit
           cmp   al,0
           jne   SelectAction_3_end
           mov   NFlags.FEIcP,1
  SelectAction_3_end:
           jmp   SelectAction_end
  SelectAction_4:
           cmp   al,5
           ja    SelectAction_5
           ;     вызов SQR
           lea   di,Operands.QCurr
           lea   si,Work1
           xchg  di,si
           call  Copy128bit
           xchg  di,si
           call  Mul128bit
           
           call  OverflowChecking
           cmp   al,0
           je    SelectAction_4_1
           mov   NFlags.FEOvf,1
  SelectAction_4_1:
           jmp   SelectAction_end
  SelectAction_5:
           cmp   al,6
           ja    SelectAction_6
           ;     вызов SQRT
           lea   di,Operands.QCurr
           call  Sqrt128bit
           cmp   al,0
           jne   SelectAction_5_end
           mov   NFlags.FEIcP,1
  SelectAction_5_end:
           jmp   SelectAction_end
  SelectAction_6:
           cmp   al,7
           ja    SelectAction_7
           ;     вызов EXP
           lea   di,Operands.QCurr
           call  Exp128bit
           
           call  OverflowChecking
           cmp   al,0
           je    SelectAction_6_1
           mov   NFlags.FEOvf,1
  SelectAction_6_1:
           jmp   SelectAction_end
  SelectAction_7:
           cmp   al,8
           ja    SelectAction_9
           ;     вызов LN
           lea   di,Operands.QCurr
           call  Ln128bit
           cmp   al,0
           jne   SelectAction_7_end
           mov   NFlags.FEIcP,1
  SelectAction_7_end:
           jmp   SelectAction_end
  SelectAction_9:
           cmp   al,9
           ja    SelectAction_8
           ;     вызов NOTHING
           jmp   SelectAction_end                    
  SelectAction_8:
           cmp   al,10
           ja    SelectAction_10
           ;     вызов MUL
           lea   si,Operands.QCurr
           lea   di,Operands.QPrev1
           call  Mul128bit
           
           call  OverflowChecking
           cmp   al,0
           je    SelectAction_8_1
           mov   NFlags.FEOvf,1
  SelectAction_8_1:
           jmp   SelectAction_end           
  SelectAction_10:
           cmp   al,11
           ja    SelectAction_11
           ;     вызов DIV
                      
           lea   si,Operands.QCurr
           lea   di,Work
           call  Clear128bit
           call  Cmp128bit
           cmp   al,0
           jne   SelectAction_10_0
           mov   NFlags.FEDbZ,1
           jmp   SelectAction_end
  SelectAction_10_0:
           lea   di,Operands.QPrev1
           call  Div128bit
           
           call  OverflowChecking
           cmp   al,0
           je    SelectAction_10_1      
           mov   NFlags.FEOvf,1
  SelectAction_10_1:           
           jmp   SelectAction_end
  SelectAction_11:
           cmp   al,12
           ja    SelectAction_12
           ;     вызов ADD
           lea   si,Operands.QCurr
           lea   di,Operands.QPrev1
           call  Add128bit
           
           call  OverflowChecking
           cmp   al,0
           je    SelectAction_11_1
           mov   NFlags.FEOvf,1
           
  SelectAction_11_1:
           jmp   SelectAction_end
  SelectAction_12:
           cmp   al,13
           ja    SelectAction_13
           ;     вызов SUB
           lea   si,Operands.QCurr
           lea   di,Operands.QPrev1
           call  Sub128bit
           
           call  OverflowChecking
           cmp   al,0
           je    SelectAction_12_1
           mov   NFlags.FEOvf,1
           
  SelectAction_12_1:
           jmp   SelectAction_end
  SelectAction_13:
                      
  SelectAction_end:
           pop   si di                      
           ret
SelectAction endp

