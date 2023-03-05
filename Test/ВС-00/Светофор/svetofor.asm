RomSize    EQU   4096        ;Объём ПЗУ

Sv1        EQU   0
Sv2        EQU   1
Ind2d      EQU   2
Ind2e      EQU   3
Ind1d      EQU   4
Ind1e      EQU   5
Revers     EQU   8
Kbd        EQU   9
NMax       EQU  50 

Data Segment at 40h

d1e    db     ?
d1d    db     ?
d2e    db     ?
d2d    db     ?
N1     db     ?
N2     db     ?
T      db     ?
k      db     ?
NCol db       ?
Cikl   db     ? 
Col1   db     ?
Col2   db     ? 
Revr   db     ?
AvtR   db     ?
           
Data ENDS
           
Code SEGMENT

;Образы десятичных цифр от 0 до 9
Image      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh

ASSUME cs:Code, ds:Data, es:Code



VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;Сохранение исходного состояния
           mov   bh,0        ;Сброс счётчика повторений
VD2:       in    al,dx       ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   bh          ;Инкремент счётчика повторений
           cmp   bh,NMax     ;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных
           ret
VibrDestr  ENDP

PausCol    Proc  NEAR
           ;mov   al,T
           mov   bl,T
           mov   dl,01h
           mov   al,dl
           mul   bl
           mov   dl,al
           mov   cx,02ffh
           ret
PausCol    ENDP

InvCol     Proc  NEAR
           cmp   Col1,61h
           je    ICol1
           mov   Col1,61h
           cmp   AvtR,0
           je    ICol2
           mov   col2,88h
           jmp   ICEnd    
ICol2:     mov   col2,48h
           jmp   ICEnd
ICol1:     mov   Col1,0cH
           cmp   AvtR,0
           je    ICol3
           mov   Col2,83h
           jmp   ICEnd
ICol3:     mov   Col2,43h
ICEnd:     ret
InvCol     ENDP

Yellow     Proc  NEAR

           mov   al,92h      ;
           out   Sv1,al      ;  Горит желтый цвет
           cmp   AvtR,0h
           je    Yellow1
           mov   al,84h
           jmp   Yellow2       
Yellow1:   mov   al,44h       ;
Yellow2:   out   Sv2,al
           mov   bl,0ah
           mov   dl,01h
           mov   al,dl
           mul   bl
           mov   dl,al
           mov   cx,02ffh
           call  Pause      ; переход на задержку 10с
           ret           
Yellow    ENDP

Red        Proc  NEAR

           mov   al,Col1     ;
           out   Sv1,al      ;  Горит красный прямо
           mov   al,Col2     ;
           out   Sv2,al
           ret           
Red        ENDP

GreenN1    Proc  NEAR
           mov   al,d1d
           cmp   al,d2d
           jb   GrN11
           jmp   GrN12
GrN11:     mov   Col1,0ch
           cmp   AvtR,0
           je    GrNA1
           mov   Col2,83h
           jmp   GrN1End
GrNA1:     mov   Col2,43h
           jmp   GrN1End
GrN12:     cmp   al,d2d
           jne   GrN13
           mov   al,d1e
           cmp   al,d2e
           je    GrN1End
           cmp   al,d2e
           jb    GrN11
           ;cmp   al,d2e
           ;je    GrN1End
           jmp   GrN13
GrN13:     mov   col1,61h
           cmp   AvtR,0
           je    GrNA2
           mov   col2,88h
           jmp   GrN1End
GrNA2:     mov   col2,48h  
GrN1End:   ret
GreenN1    ENDP

FormZdr    Proc  NEAR
           mov   al,N1
           cmp   al,N2
           jne   FZ1
           cmp   N2,0
           jne   FZ5
           mov   T,028h
           jmp   FZEnd
FZ1:       cmp   N2,0
           jne   FZ5
           mov   T,028h
           jmp   FZEnd
FZ5:       mov   al,N1
           mov   ah,0
           mov   bl,N2
           div   bl
           mov   k,al
           cmp   k,05h
           jb    FZ2
           mov   T,050h
           inc   Cikl
           jmp   FZEnd
FZ2:       mov   Cikl,0
           mov   al,k
           mov   bl,0ah
           mul   bl
           mov   bl,1Eh
           add   al,bl
           mov   T,al
           
                                          
FZEnd:     ret
FormZdr    ENDP

Main1  PROC  NEAR
Stm:       cmp   AvtR,1h
           jne   Stm0
           jmp   AvtoR
Stm0:      call  N1N2
           mov   al,N1
           cmp   al,N2
           jne   Stm1   
           cmp   N2,0
           jne   Stm2
           ;call  Yellow      ;  N1=N2=0
           jmp   Stm2       

Stm1:      cmp   N2,0        ;  N1<>N2 и N2=0
           jne   Stm4                     ;
           call  GreenN1     ;
           call  Red         ;
           call  Pause       ;
           jmp   Stm         ;

Stm2:      call  Yellow      ;  N1=N2 и N2<>0
           call  InvCol      ;
           call  FormZdr     ;
           call  PausCol     ;
           call  red         ;
           Call  Pause
           ;call  Yellow
           jmp   Stm         ;
           
Stm4:      call  GreenN1     ;          
           call  N1N2        ;
           call  FormZdr
           call  PausCol
           call  Red
           call  Pause
           cmp   AvtR,1h
           je   AvtoR
           cmp   Cikl,0      ;  Проверка на k>=5
           je    Stm41
           cmp   Cikl,3
           jne   Stm
           mov   Cikl,0
Stm41:     call  Yellow
           call  InvCol
           mov   al,5ah
           sub   al,T
           mov   T,al
           call  PausCol
           call  Red
           call  Pause
           cmp   AvtR,1h
           je   AvtoR
           call  Yellow
           jmp   Stm

AvtoR:     call  Red
           mov   cx,1h
           mov   dl,1h
           call  Pause
          
AvtoR3:    in    al,Revers
           ;call  VibrDestr
           cmp   al,0ffh
           je    AvtoR
           mov   ah,al
AvtoR2:    in    al,Revers
           cmp   al,0ffh
           jne   AvtoR2
           test  ah,2h
           jne   AvtoR4
           mov   AvtR,0
           ;call  InvCol
           ;call  Yellow
           jmp   Stm
AvtoR4:    ;dec   d1e
           test  ah,1h
           je    AvtoR1
           jmp   AvtoR 
AvtoR1:    call  Yellow
           call  InvCol
           jmp   AvtoR            
           RET
Main1 ENDP

Main  PROC  NEAR
           mov   d1e,0h
           mov   d1d,0h
           mov   d2e,0h
           mov   d2d,0h
           mov   N1,0
           mov   N2,0
           mov   T,0
           mov   k,1h
           mov   Revr,0
           mov   NCol,0
           mov   Cikl,0
           mov   Col1,0h
           mov   Col2,0h
           mov   AvtR,0h  
           RET
Main  ENDP

N1N2  PROC  NEAR
           mov   al,d1d
           mov   dl,10
           mul   dl
           mov   ah,d1e
           add   al,ah
           mov   bl,al
           mov   al,d2d
           mov   dl,10
           mul   dl
           mov   ah,d2e
           add   al,ah
           cmp   al,bl
           ja    D1
           cmp   al,bl
           jb    D2
D1:        mov   N1,al
           mov   N2,bl
           jmp   D3
D2:        mov   N1,bl
           mov   N2,al
D3:        ret
N1N2  ENDP

OutDigInc  Proc  NEAR
           cmp   d1e,0ah
           jnz   ODI1
           mov   d1e,0
           inc   d1d
           cmp   d1d,0ah
           jnz   ODI1
           mov   d1d,0
ODI1:      cmp   d2e,0ah
           jnz   ODI2
           mov   d2e,0
           inc   d2d
           cmp   d2d,0ah
           jnz   ODI2
           mov   d2d,0
ODI2:      lea   bx,Image    ;
           mov   al,d1e      ;
           mov   ah,0        ;
           add   bx,ax       ;
           MOV   AL,es:[BX]  ;
           out   Ind1e,al    ;
           lea   bx,Image
           mov   al,d1d
           mov   ah,0
           add   bx,ax
           MOV   AL,es:[BX]
           out   Ind1d,al
           lea   bx,Image
           mov   al,d2e
           mov   ah,0
           add   bx,ax
           MOV   AL,es:[BX]
           out   Ind2e,al
           mov   al,d2e
           mov   ah,0
           lea   bx,Image
           mov   al,d2d
           mov   ah,0
           add   bx,ax
           MOV   AL,es:[BX]
           out   Ind2d,al
           ret
OutDigInc  EndP

OutDigDec  Proc  NEAR
           lea   bx,Image
           mov   al,d1e
           mov   ah,0
           add   bx,ax
           MOV   AL,es:[BX]
           out   Ind1e,al
           ;mov   al,d1d
           ;mov   ah,0
           lea   bx,Image
           mov   al,d1d
           mov   ah,0
           add   bx,ax
           MOV   AL,es:[BX]
           out   Ind1d,al
           lea   bx,Image
           mov   al,d2e
           mov   ah,0
           add   bx,ax
           MOV   AL,es:[BX]
           out   Ind2e,al
           lea   bx,Image
           mov   al,d2d
           mov   ah,0
           add   bx,ax
           MOV   AL,es:[BX]
           out   Ind2d,al
           ret
OutDigDec  EndP

DigInc     Proc  NEAR
           cmp   al,9h
           je    DInc1
           jmp   DInc2
DInc1:     cmp   ah,9h
           je    DIncEn
           inc   ah
           mov   al,0
           jmp   DIncEn
DInc2:     cmp   ah,9h
           je    DInc3
           jmp   DInc4
DInc3:     mov   al,0
           Inc   ah
           jmp   DIncEn
DInc4:     Inc   al
DIncEn:    ret      
DigInc     ENDP

DigDec     Proc  NEAR
           cmp   al,0
           je    DDec1
           dec   al
           jmp   EnDDec
DDec1:     cmp   ah,0
           je    EnDDec
           mov   al,9h
           dec   ah
EnDDec:    ret   
DigDec     ENDP

Pause     Proc NEAR
           cmp   AvtR,1
           je   mm
m1:        dec   cx          ; Задержка
           ;nop               ; 
           cmp   cx,0        ;
           jne   Rev1
           dec   dl
           cmp   dl,0
           jne   mm1                    
           jmp   EnSv
mm1:       mov   cx,02ffh            
Rev1:      in    al,Revers
           ;call  VibrDestr
           cmp   al,0ffh
           je    mm
           mov   ah,al
Rev:       in    al,Revers
           cmp   al,0ffh
           jne   Rev
           test  ah,2h
           jne   mm
           mov   AvtR,1h
           cmp   Col2,48h
           je    RR1
           cmp   Col2,43h
           je    RR2
           jmp   RR3
RR1:       mov   Col2,88h
           jmp   RRSt
RR2:       mov   Col2,83h
           jmp   ICEnd
RR3:       mov   Col2,84h                      
RRSt:      call  red
           jmp   EnSv
mm:        in    al,kbd
           ;call  VibrDestr
           cmp   al,0ffh
           ;mov   ah,al
           je    m1
           mov   ah,al
m3:        in    al,kbd
           cmp   al,0ffh
           jne   m3
Rev2:      test   ah,1h      ; Начало Inc
           jne    m5
           mov   al,d1e
           mov   ah,d1d
           call  DigInc
           mov   d1e,al
           mov   d1d,ah
           call  OutDigInc
           jmp   m1
m5:        test   ah,2h      
           jne    m6
           mov   al,d1e
           mov   ah,d1d
           call  DigInc
           mov   d1e,al
           mov   d1d,ah
           call OutDigInc
           jmp   m1
m6:        test   ah,4h
           jne    m7
           mov   al,d2e
           mov   ah,d2d
           call  DigInc
           mov   d2e,al
           mov   d2d,ah
           call OutDigInc
           jmp   m1
m7:        test   ah,8h
           jne    StDec
           mov   al,d2e
           mov   ah,d2d
           call  DigInc
           mov   d2e,al
           mov   d2d,ah
           call OutDigInc
           jmp   m1
StDec:     test   ah,10h     ; Начало Dec
           je    Dec5
           jmp   Dec1
Dec5:      mov   al,d1e
           mov   ah,d1d
           call  DigDec
           mov   d1e,al
           mov   d1d,ah
           call OutDigDec
           jmp   m1
Dec1:      test   ah,20h
           je    Dec6
           jmp   Dec2
Dec6:      mov   al,d1e
           mov   ah,d1d
           call  DigDec
           mov   d1e,al
           mov   d1d,ah
           call  OutDigDec
           jmp   m1
Dec2:      test  ah,40h
           je    Dec7
           jmp   Dec3
Dec7:      mov   al,d2e
           mov   ah,d2d
           call  DigDec
           mov   d2e,al
           mov   d2d,ah
           call  OutDigDec
           jmp   m1
Dec3:      test  ah,80h
           je    Dec8
           jmp   m1
Dec8:      mov   al,d2e
           mov   ah,d2d
           call  DigDec
           mov   d2e,al
           mov   d2d,ah           
           call  OutDigDec
m2:        jmp   m1
EnSv:      RET
Pause      EndP



Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,Code
           mov   es,ax
           
           call  Main
Start1:    call  Main1
           jmp   Start1
           
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
