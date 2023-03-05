;------------------------------------------------------------
;          курсовая по МИКРОПРОЦЕССОРНЫМ СИСТЕМАМ         
;          студент ВС2-00    Крутин А.В.           
;          преподаватель     Комаров В.М.
;          "Инженерный калькулятор"
;          Design MicroSystems v3.3
;  ScCalc.asm - основной модуль
;------------------------------------------------------------
.386                         ; только для enter и leave (можно и на 86, если их заменить)
Name ScientificCaculator

include    define.asm        ; InitData, типы данных, все константы(define)
;____________________________________________________________

Data       SEGMENT AT 0h use16

NFlags     TNeedFlags <>     ; флаги
Operation  TOperation <>     ; хранит операции(тек.и две пред.)
Operands   TOperands  <>     ; хранит операнды(тек.и два пред.)
Memory     TQuantity128bit <>; память соответственно
Work       TQuantity128bit <>; типа темпа, может и не пригодится
Work1      TQuantity128bit <>
Work2      TQuantity128bit <>
Work3      TQuantity128bit <>
WorkMul    dw    14 dup(?)
modulo     dw    ?        
DisplayStr TString    <>       
KbdImage   db    5 DUP(?)    ; образ клавиатуры построчно
KeyCode    db    ?           ; окончательный сканкод
Error      db    ?           ; код текущей ошибки(первый из NFlags)               
                 
Data       ENDS
;____________________________________________________________

Stk        SEGMENT AT 160h use16
           dw    100h dup (?)          ; с запасом
StkTop     Label Word
Stk        ENDS
;____________________________________________________________


Code       SEGMENT use16
           ASSUME cs:Code, ds:Data;, es:InitData, ss:Stk

include    IO.asm                      
include    Service.asm
include    String.asm
include    math.asm

; Init     - инициализируем(NULL) все глобальное
;
Init       proc  near
           push  ax
           call  ClearAll
           pop   ax           
           ret
Init       endp

Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,InitData
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           
           call  Init

  RunCycle:
           call  KbdInput
           call  KbdReview
           call  KbdReply
           call  Revise
           call  ShowDisplay
           
           jmp   RunCycle
           
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END        
        
