;------------------------------------------------------------
; IO.asm
; input-output
;------------------------------------------------------------
;
; для оптимизации можно заменить cmp на test
;

; VibrDestr -    убирает дребезг
; получает NMax равных(постоянных) состояний

VibrDestr  proc  near
  VD_1:
           mov   ah,al       ; Сохранение исходного состояния
           mov   bh,0        ; Сброс счётчика повторений
  VD2:     
           in    al,dx       ; Ввод текущего состояния
           cmp   ah,al       ; Текущее состояние=исходному?
           jne   VD_1        ; Переход, если нет
           inc   bh          ; Инкремент счётчика повторений
           cmp   bh,NMax     ; Конец дребезга?
           jne   VD2         ; Переход, если нет
           mov   al,ah       ; Восстановление местоположения данных
           ret
VibrDestr  endp

; KbdInput  -     опрашивает клавиатуру
; Выход:    заполняет KbdImage
; KbdImage  -     массив, описывать с DUP       
; размерность KbdImage - строчная размерность клавиатуры

KbdInput   proc  near  
           push  ax bx cx dx
           
           mov   cx,length KbdImage    ; получаем размерность
           lea   bx,KbdImage                      
           add   bx,cx          
           dec   bx
           
           mov   dl,0FEh
           rol   dl,cl
           ror   dl,1           
  KI:      
           mov   al,dl
           out   PKbdStrActivate,al
           in    al,PKbdStateRead
           not   al
           mov   [bx],al
  KbdInput_2:         
           cmp   al,0FFh               ; ждем пока отпустят
           je    KbdInput_1           
           in    al,PKbdStateRead
           jmp   KbdInput_2
  KbdInput_1:           
           ror   dl,1
           dec   bx
           loop  KI             
           
           
           pop   dx cx bx ax
           ret                                 
KbdInput   endp

; KbdReview -    формирует KeyCode(DB).
; анализирует KbdImage(описан с DUP): проверяет на нажатие нескольких клавиш
; нумерация клавиш - сверху-вниз, слева направо(т.о. работает при любом кол.столбцов)
; -------------------------
; |(m-1)*n+1   ... n+1  1 |
; |(m-1)*n+2   ... n+2  2 |
; |   ...      ... ... ...|
; |   m*n      ... 2*n  n |
; -------------------------
; n - размерность строчная
; m - размерность по столбцам
; при правильности образа мы имеем: X - элемент KbdImage
;  i - строчный индекс элемента, j - подсчитанный индекс столбца(for(int j=0; X != 0 ; j++, X= X shr 1))// или X/= 2
; считаем код по формуле (j-1)*n+i, i=0=KeyCode (X=0)           
; KeyCode in {0,1,2..m*n}, KeyCode=0 - ничего не нажато         
        
   
KbdReview  proc  near

KbdReview_i      EQU   [bp-2]        ; локальные переменные
KbdReview_j      EQU   [bp-4]
KbdReview_X      EQU   [bp-6]
KbdReview_n      EQU   [bp-8]
           push  ax bx cx
           
           enter 8,0
           xor   ax,ax
           mov   KbdReview_X,ax
           mov   KbdReview_i,ax
           mov   KbdReview_j,ax
           mov   KeyCode,al
           mov   word ptr KbdReview_n,length KbdImage           
           
           mov   cx,KbdReview_n    ; проверяем нажатие в разных строках и(или) получаем X, i
           mov   bx,cx
           dec   bx
  KbdReview_1:
           cmp   KbdImage[bx],0
           je    KbdReview_1_end
           
           mov   ax,KbdReview_X
           cmp   ax,0
           jne   KbdReview_end
           
           mov   al,KbdImage[bx]
           mov   KbdReview_X,ax
           mov   KbdReview_i,cx           
  KbdReview_1_end:
           dec   bx
           dec   cx
           jnz   KbdReview_1
           
           mov   cx,KbdReview_X    ; проверяем нажатие в строке и(или) получаем j
           xor   ax,ax
  KbdReview_2:
           inc   ax
           shr   cx,1
           jnz   KbdReview_2
           mov   KbdReview_j,ax
           
           dec   ax                  ; проверяем корректность Х
           mov   cl,al
           mov   ax,00000001b
           shl   ax,cl
           cmp   ax,KbdReview_X
           jne   KbdReview_end
           
           mov   ax,KbdReview_j           ; подсчет KeyCode
           dec   ax
           mov   bx,KbdReview_n
           mul   bl
           add   ax,KbdReview_i
           mov   KeyCode,al
                                                                                       
  KbdReview_end:
           leave        
           pop  cx bx ax
           ret
KbdReview  endp

; KbdReply  -     в соответствии с KeyCode делает что-нибудь нужное...     
; формирует -     переменные: Operation, DisplayImage
;                 флаги: FSignum, FPoint, FShift
;
KbdReply   proc  near
           ;push  reg
           
           xor   bx,bx
           mov   bl,KeyCode
           shl   bx,1
           
           jmp   cs:KbdReply_CaseTable[bx]

; SWITH    TABLE
           
KbdReply_CaseTable  dw KbdReply_Case0 
                    dw KbdReply_Case1, KbdReply_Case2, KbdReply_Case3, KbdReply_Case4, KbdReply_Case5
                    dw KbdReply_Case6, KbdReply_Case7, KbdReply_Case8, KbdReply_Case9, KbdReply_Case10
                    dw KbdReply_Case11, KbdReply_Case12, KbdReply_Case13, KbdReply_Case14, KbdReply_Case15
                    dw KbdReply_Case16, KbdReply_Case17, KbdReply_Case18, KbdReply_Case19, KbdReply_Case20
                    dw KbdReply_Case21, KbdReply_Case22, KbdReply_Case23, KbdReply_Case24, KbdReply_Case25
; BEGIN    SWITH

  KbdReply_Case0:                    ; "None"
           jmp   KbdReply_end
  KbdReply_Case1:                    ; "exp(x) || ln(x)"
           ; ///////////////////////////////////
           ;     if(!FIOper)
           ;     {
           ;                 OperationShift
           ;                 OperandsShift                 
           ;     }
           ;     if(FInput)Operands.QCurr = SrtToFloat(DisplayStr)
           ;     Operation.Curr = GetCode(exp(x))
           ;     Operation.Curr += FShift        // предполагаем, что коды рядом
           ;     FShift = 0
           ;     FInput = 0
           ;     FIOper = 1
           ; ///////////////////////////////////
           mov   al,OExp
           mov   ah,NFlags.FShift
           call  InputOperation
           mov   NFlags.FShift,0
           jmp   KbdReply_end
  KbdReply_Case2:                    ; "MR || x->M"
           ; ///////////////////////////////////
           ;     if(!FShift) {MemoryToWork; FInput = 0}
           ;     elseif(!FInput) WorkToMemory
           ;     else        DisplayToMemory;
           ;     FShift = 0
           ;     FIOper = 0
           ; ///////////////////////////////////
           
           mov   ah,NFlags.FIOper
           mov   NFlags.FIOper,0
           mov   al,NFlags.FShift
           mov   NFlags.FShift,0
           cmp   al,0
           jne   KbdReply_Case2_elseif
           
           cmp   ah,0
           je    KbdReply_Case2_then_1 
           lea   di,Operands.QPrev2
           lea   si,Operands.QPrev1
           call  Copy128bit           
           lea   di,Operands.QPrev1
           lea   si,Operands.QCurr
           call  Copy128bit
           mov   NFlags.FNOS,1
  KbdReply_Case2_then_1:           
           call  MemoryToWork
           mov   NFlags.FInput,0
           jmp   KbdReply_end           
  KbdReply_Case2_elseif:
           cmp   NFlags.FInput,0
           jne   KbdReply_Case2_else
           call  WorkToMemory
           jmp   KbdReply_end
  KbdReply_Case2_else:
           call  DisplayToMemory 
           jmp   KbdReply_end
  KbdReply_Case3:                    ; "/"
           ; ///////////////////////////////////
           ;     if(!FIOper)
           ;     {
           ;                 OperationShift
           ;                 OperandsShift                 
           ;     }
           ;     if(FInput)Operands.QCurr = SrtToFloat(DisplayStr)
           ;     Operation.Curr = GetCode(/)
           ;     FShift = 0
           ;     FInput = 0
           ;     FIOper = 1
           ; ///////////////////////////////////
           mov   NFlags.FShift,0
           mov   al,ODivide
           mov   ah,NFlags.FShift
           call  InputOperation
           jmp   KbdReply_end
  KbdReply_Case4:                    ; "-"
           mov   NFlags.FShift,0
           mov   al,OSubstract
           mov   ah,NFlags.FShift
           call  InputOperation
           jmp   KbdReply_end
  KbdReply_Case5:                    ; "CE || C"
           ; ///////////////////////////////////
           ;     if(!FShift) ClearStr
           ;     else        ClearAll
           ;     FShift = 0
           ; ///////////////////////////////////
           mov   al,NFlags.FShift
           mov   NFlags.FShift,0
           cmp   al,0
           jne   KbdReply_Case5_else
           lea   bx,DisplayStr
           call  ClearStr
           mov   NFlags.FShift,0
           mov   NFlags.FSignum,0
           mov   NFlags.FPoint,0
           mov   NFlags.FInput,1
           jmp   KbdReply_end           
  KbdReply_Case5_else:
           call  ClearAll                         
           jmp   KbdReply_end
  KbdReply_Case6:                    ; "x^2 || x^(0.5)"           
           mov   al,OSqr
           mov   ah,NFlags.FShift
           call  InputOperation
           mov   NFlags.FShift,0
           jmp   KbdReply_end
  KbdReply_Case7:                    ; "M+"
           ; ///////////////////////////////////
           ;     if(FInput) DisplayToWork
           ;     AddWorkToMemory
           ;     FInput = 0
           ;     FShift = 0
           ;     FIOper = 0
           ; ///////////////////////////////////
           mov   NFlags.FMemory,1
           cmp   NFlags.FInput,0
           je    KbdReply_Case7_1
           ; DisplayToWork
           lea   di,Work1
           lea   bx,DisplayStr
           call  StrToFloat
           jmp   KbdReply_Case7_3
  KbdReply_Case7_1:
           ; AddWorkToMemory
           lea   di,Work1
           lea   si,Operands.QCurr
           call  Copy128bit
  KbdReply_Case7_3:
           lea   di,Memory
           lea   si,Work1
           call  Add128bit
           
           xchg  di,si
           call  Clear128bit
           xchg  di,si
           call  Cmp128bit
           cmp   ax,0
           jne   KbdReply_Case7_2
           mov   NFlags.FMemory,0
  KbdReply_Case7_2:
           mov   NFlags.FShift,0
           mov   NFlags.FIOper,0
           jmp   KbdReply_end
  KbdReply_Case8:                    ; "*"
           mov   NFlags.FShift,0
           mov   al,OMultiply
           mov   ah,NFlags.FShift
           call  InputOperation
           jmp   KbdReply_end
  KbdReply_Case9:                    ; "+"
           mov   NFlags.FShift,0
           mov   al,OAddition
           mov   ah,NFlags.FShift
           call  InputOperation
           jmp   KbdReply_end
  KbdReply_Case10:                   ; "= || <-"
           ; ///////////////////////////////////
           ;     if(!FShift) Operation.Curr = Code(Equall)
           ;     else        Undo
           ;     FShift = 0
           ; ///////////////////////////////////
           mov   al,NFlags.FShift
           mov   NFlags.FShift,0
           cmp   al,0
           jne   KbdReply_Case10_else
           
           mov   NFlags.FShift,0
           mov   al,OEqual
           mov   ah,NFlags.FShift
           call  InputOperation
           jmp   KbdReply_end
           
  KbdReply_Case10_else:
           cmp   NFlags.FInput,0
           jne   KbdReply_Case10_else_1
           jmp   KbdReply_end
  KbdReply_Case10_else_1:
           call  Undo           
           jmp   KbdReply_end
           
  KbdReply_Case11:                   ; "tan(x) || ctan(x)"
           mov   al,OTan
           mov   ah,NFlags.FShift
           call  InputOperation
           mov   NFlags.FShift,0
           jmp   KbdReply_end
  KbdReply_Case12:                   ; "9"
           mov   ax,9
           call  InputNumber
           jmp   KbdReply_end
  KbdReply_Case13:                   ; "6"
           mov   ax,6
           call  InputNumber
           jmp   KbdReply_end
  KbdReply_Case14:                   ; "3"
           mov   ax,3
           call  InputNumber
           jmp   KbdReply_end
  KbdReply_Case15:                   ; "+/-"
           ; ///////////////////////////////////
           ;     FSignum = !FSignum 
           ;     FShift = 0
           ;     FIOper = 0
           ; ///////////////////////////////////
           mov   NFlags.FShift,0
           mov   NFlags.FIOper,0
           
           cmp   NFlags.FInput,0
           jne   KbdReply_Case15_1
           lea   bx,DisplayStr
           call  ClearStr
  KbdReply_Case15_1:
           mov   ax,1
           sub   al,NFlags.FSignum
           mov   NFlags.FSignum,al
           mov   NFlags.FInput,1
           jmp   KbdReply_end         
  KbdReply_Case16:                   ; "sin(x) || cos(x)"
           mov   al,OSin
           mov   ah,NFlags.FShift
           call  InputOperation
           mov   NFlags.FShift,0  
           jmp   KbdReply_end
  KbdReply_Case17:                   ; "8"
           mov   ax,8
           call  InputNumber
           jmp   KbdReply_end
  KbdReply_Case18:                   ; "5"
           mov   ax,5
           call  InputNumber
           jmp   KbdReply_end
  KbdReply_Case19:                   ; "2"
           mov   ax,2
           call  InputNumber
           jmp   KbdReply_end
  KbdReply_Case20:                   ; "."
           ; ///////////////////////////////////
           ;     if(!FInput) ClearStr
           ;     FInput = 1
           ;     if(DisplayStr.StrLength == 11) Continue_end
           ;     if(DisplayStr.Str11[0] == 11){ Undo; Continue_end}
           ;     if(!FPoint){ FPoint = 1; AddChar(DisplayStr, ".")}
           ;     FShift = 0
           ;     FIOper = 0
           ; ///////////////////////////////////
           mov   NFlags.FShift,0
           mov   NFlags.FIOper,0
           cmp   NFlags.FInput,0
           jne   KbdReply_Case20_1
           lea   bx,DisplayStr
           call  ClearStr
  KbdReply_Case20_1:
           mov   NFlags.FInput,1
           cmp   DisplayStr.StrLength,11
           je    KbdReply_end
           
           cmp   DisplayStr.Str11[0],11
           jne   KbdReply_Case20_2
           call  Undo
           jmp   KbdReply_end
  KbdReply_Case20_2:
           cmp   NFlags.FPoint,0
           jne   KbdReply_end
           
           mov   NFlags.FPoint,1      
           lea   bx,DisplayStr
           mov   ax,10+1
           call  AddChar
           jmp   KbdReply_end
  KbdReply_Case21:                   ; "Shift"
           ; ///////////////////////////////////
           ;     FShift = !FShift
           ; ///////////////////////////////////
           mov   al,1
           sub   al,NFlags.FShift
           mov   NFlags.FShift,al
           jmp   KbdReply_end
  KbdReply_Case22:                   ; "7"
           mov   ax,7
           call  InputNumber
           jmp   KbdReply_end
  KbdReply_Case23:                   ; "4"
           mov   ax,4
           call  InputNumber
           jmp   KbdReply_end
  KbdReply_Case24:                   ; "1"
           mov   ax,1
           call  InputNumber
           jmp   KbdReply_end
  KbdReply_Case25:                   ; "0"
           ; ///////////////////////////////////
           ;     if(!FInput) ClearStr
           ;     FInput = 1
           ;     if(DisplayStr.StrLength == 11) Continue_end
           ;     if(DisplayStr.StrLength > 1 || DisplayStr.Str11[0] != 1) AddChar(DisplayStr, "0")
           ;     FShift = 0
           ;     FIOper = 0
           ; ///////////////////////////////////
           mov   ax,0
           call  InputNumber           
           jmp   KbdReply_end
           
; END    SWITH
  KbdReply_end_1:          
  KbdReply_end:
           ;pop   reg
           ret
KbdReply   endp

; ShowDisplay    -   показывает дисплей 
; выводит иначе сообщение обшибке или DisplayStr
;
ShowDisplay proc near
ShowDisplay_temp EQU   [bp-2]
           push  ax
           enter 2,0           
           
                    
           xor   ax,ax
           cmp   NFlags.FShift,0
           je    ShowDisplay_6
           lea   bx,ShiftMap
           mov   dl,es:[bx]
           or    al,dl
  ShowDisplay_6:
           cmp   NFlags.FSignum,0
           je    ShowDisplay_7
           lea   bx,SignumMap
           mov   dl,es:[bx]
           or    al,dl
  ShowDisplay_7:
           cmp   NFlags.FMemory,0
           je    ShowDisplay_8
           lea   bx,MemoryMap
           mov   dl,es:[bx]
           or    al,dl
  ShowDisplay_8:
           out   PFlags,al
            
           xor   dx,dx
           call  CheckError
           cmp   Error,0
           je    ShowDisplay_1
           call  ShowError
           jmp   ShowDisplay_end
  ShowDisplay_1:
           mov   dl,PDisplay
           lea   bx,OutputMap
           xor   cx,cx
           mov   cl,DisplayStr.StrLength
           mov   di,0
           mov   ShowDisplay_temp,0000h
           xor   ax,ax
  ShowDisplay_2:           
           cmp   DisplayStr.Str11[di],11
           jne   ShowDisplay_2_1
           mov   ShowDisplay_temp,10000000b
           dec   cx
           inc   di
  ShowDisplay_2_1: 
           mov   al,DisplayStr.Str11[di]
           lea   bx,OutputMap
           add   bx,ax
           mov   al,es:[bx]
           or    ax,ShowDisplay_temp
           out   dx,al
           mov   ShowDisplay_temp,0000h
           inc   dx
           inc   di
           loop  ShowDisplay_2
           
           xor   al,al
  ShowDisplay_4:         
           cmp   dx,PFlags
           je    ShowDisplay_3
           out   dx,al
           inc   dx
           jmp   ShowDisplay_4
  ShowDisplay_3:
  
  ShowDisplay_end:
           leave
           pop   ax
           ret
ShowDisplay endp

; ShowError      -  показывает сообщение об ошибке
;
ShowError  proc near
           push  ax bx cx dx

           xor   dx,dx
           xor   ax,ax
           lea   bx,OutputMap
           mov   dl,PDisplay+5           
           mov   cx,6
  ShowError_1:
           mov   al,es:[bx]
           out   dx,al
           inc   dx
           loop  ShowError_1
           lea   bx,ErrorStr
           
           mov   al,es:[bx]
           out   PDisplay+4,al
           mov   al,es:[bx+1]
           out   PDisplay+3,al
           mov   al,es:[bx+2]
           out   PDisplay+2,al
           mov   al,00000000b
           out   PDisplay+1,al    
           mov   al,Error
           lea   bx,OutputMap
           add   bx,ax
           inc   bx
           mov   al,es:[bx]
           out   PDisplay,al           
              
           pop   dx cx bx ax
           ret
ShowError  endp