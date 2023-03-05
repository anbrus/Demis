;------------------------------------------------------------
; define.asm
; ну типа определения, константы вроде
;------------------------------------------------------------

;____________________________________________________________
; Общие
RomSize    EQU   8192
NMax       EQU   50          ; дребезг
;____________________________________________________________
; ERROR TYPES
ENone      EQU   0
EDbZ       EQU   1           ; Division by Zero
EOvf       EQU   2           ; Overflow Error
EIcP       EQU   3           ; Incorrect Parametr (ln(0))     
EKbd       EQU   4           ; Keyboard Error
EDtB       EQU   5           ; Data Bus Error
EAdB       EQU   6           ; Address Bus Error   
;____________________________________________________________
; PORT address Define
PKbdStateRead    EQU   0     ;
PKbdStrActivate  EQU   0     ;
PFlags           EQU   12    ; конец(самый правый)
PDisplay         EQU   1     ; начальный адрес(самый левый)
;____________________________________________________________
; Operation code
OEqual     EQU   0           ; равно - выполняется вся очередь
OSin       EQU   1
OCos       EQU   2
OTan       EQU   3
OCtn       EQU   4
OSqr       EQU   5
OSqrt      EQU   6
OExp       EQU   7
OLng       EQU   8
ONull      EQU   9           ; нет ничего(старше чем арифметика)
OMultiply  EQU   10
ODivide    EQU   11
OAddition  EQU   12
OSubstract EQU   13
;____________________________________________________________
; Data type
TNeedFlags struc
           FInput  db        ?
           FIOper  db        ?
           FNOS    db        ?                    
           FSignum db        ?
           FPoint  db        ?
           FShift  db        ?
           FMemory db        ?          
           FEDbZ   db        ?          
           FEOvf   db        ?
           FEIcP   db        ?
           FEKbd   db        ?
           FEDtB   db        ?
           FEAdB   db        ?                     
TNeedFlags ends

; просто хотелось порпобовать record
; TNeedFlags record FInput:1, FSignum:1, FPoint:1, FShift:1, FEOvf:1, FEIcP:1, FEKbd:1, FEDtB:1, FEAdB:1

TQuantity128bit   struc
           Exponent  db          ?
           Mantissa  db 14   dup(?)
           reserved  db          ?        
TQuantity128bit   ends

TOperation struc
           Prev2 db          ?
           Prev1 db          ?
           Curr  db          ?
TOperation ends

TOperands  struc
           QPrev2 TQuantity128bit <>
           QPrev1 TQuantity128bit <>
           QCurr  TQuantity128bit <>
TOperands  ends




TString   struc
          StrLength db       ?
          Str11     db 11 dup(?)               
TString   ends

;____________________________________________________________
; Init Data
InitData   SEGMENT use16
;            _b_          
;           |   |c
;          a|_g_| 
;           |   |d
;          f|_e_| .h
;
                        ;|h|g|f|e|d|c|b|a|
OutputMap:
                 db          00000000b    ; ""
                 db          00111111b    ; "0"
                 db          00001100b    ; "1"
                 db          01110110b    ; "2"
                 db          01011110b    ; "3"
                 db          01001101b    ; "4"
                 db          01011011b    ; "5"
                 db          01111011b    ; "6"                      
                 db          00001110b    ; "7"
                 db          01111111b    ; "8"
                 db          01011111b    ; "9"
                 
PointMap:
                 db          10000000b    ; "."
ShiftMap:
                 db          00010000b    ; "Shift"
SignumMap:
                 db          01000000b    ; "+/-"
MemoryMap:
                 db          00000010b    ; "Memory"
                 
ErrorStr:                    ; "E"    ; "r"     ; "r"
                 db          01110011b,01100000b,01100000b                    
InitData   ENDS
;____________________________________________________________