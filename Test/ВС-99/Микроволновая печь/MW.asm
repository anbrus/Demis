.386
RomSize    EQU   4096

data segment at 0BA00h use16

 Numbers    db    10 dup(?);массив цифр
 Regime     db    10 dup(?)
 RegimeBCD  db    10 dup(?)
 PrButton   db    ?
 TimeOut    db    ?
 StopHook   db    ?
 Focus      dw    ?
 PlateX     db    ?
 PlateY     db    ?      
data ends
Stk        SEGMENT AT 1000h use16
           dw    100 dup (?)
StkTop     Label Word 
Stk        ENDS
Code       SEGMENT use16
           ASSUME cs:Code,ds:Data,es:Data
Inicial    Proc              ;процедура инициализация
           mov   Numbers[0],03Fh
           mov   Numbers[1],00Ch
           mov   Numbers[2],076h
           mov   Numbers[3],05Eh
           mov   Numbers[4],04Dh
           mov   Numbers[5],05Bh
           mov   Numbers[6],07Bh
           mov   Numbers[7],00Eh
           mov   Numbers[8],07Fh
           mov   Numbers[9],05Fh
           mov   PlateX,1b
           mov   PlateY,1b
           mov   Focus,0
           mov   TimeOut,0
           mov   StopHook,0            
           mov   bx,0 
             
           xor   di,di           ;запись нулей в элементы BDC массива
           mov   cx,10d
SetReg0:   mov   dl,0
           mov   RegimeBCD[di],dl
           inc   di
           Loop  SetReg0
           call  OutNumbers
           call  FocusIndicator
           ret 
Inicial    EndP                                 

OutNumbers Proc           
           xor   di,di
           xor   dx,dx
           mov   cx,10d
OutNum0:   mov   dl,RegimeBCD[di]
           mov   si,dx
           mov   dl,Numbers[si]
           mov   Regime[di],dl
           inc   di
           Loop  OutNum0
                      
           mov   cx,10d 
           xor   dx,dx
           xor   si,si
OutNum1:   mov   al,Regime[si]
           out   dx,al
           inc   dx
           inc   si
           loop  OutNum1                  
           ret
OutNumbers EndP

 
Pause      Proc
           mov   cx,0FFFFh
M0:        in    al,0
           cmp   al,1b
           jnz   P1
           mov   cx,1
           mov   StopHook,1
P1:        loop  M0           
           ret
Pause      EndP
 
Hook       Proc                      
           mov   dl,10000000b
m2:        rol   dl,1
           mov   al,dl            
           out   000Fh,al
           in    al,0
           mov   dh,al
           cmp   dh,0                      
           jz    m2
m3:        in    al,0 
           cmp   al,0
           jnz   m3                      
           mov   cx,4
           mov   al,0
PerMet0:   shr   dh,1
           jc    PerMet1
           inc   al
           loop  PerMet0
PerMet1:   mov   dh,al           
           mov   cx,4
           mov   al,0
Per2Met0:  shr   dl,1
           jc    Per2Met1
           inc   al
           loop  Per2Met0
Per2Met1:  mov   dl,al                      
           mov   ax,4
           mul   dl
           add   al,dh           
           mov   PrButton,al    ;номер кнопки нажатой на клавиатуре           
           ret                  ;записываетс в переменную PrButton
Hook       EndP
 
ProcSel    Proc
           xor   ax,ax
           mov   al,PrButton
           mov   dx,10d
           sub   ax,dx
           jns   PS1
           call  NumOut    
PS1:       mov   al,PrButton
           cmp   al,10d
           jnz   PS2
           call  FocusInc
PS2:       cmp   al,11d
           jnz   PS3
           call  FocusDec
PS3:       cmp   al,15d
           jnz   PS4
           call  FocusPT               
PS4:       cmp   al,13d
           jnz   PS5
           call  RangeMinCheck           
PS5:       cmp   al,14d
           jnz   PS6
           call  PrRegime    
PS6:       ret
ProcSel    EndP

PrRegime   Proc
           mov   al,100000b
           out   11h,al
           xor   di,di
           mov   cx,10d
PR:        mov   dl,0
           mov   RegimeBCD[di],dl
           inc   di
           Loop  PR
           call  Hook
           mov   al,0
           out   11h,al
           xor   ax,ax
           xor   dx,dx
           mov   al,PrButton
           cmp   PrButton,0
           jnz   PR1
           mov   RegimeBCD[1],1
           mov   RegimeBCD[6],1
           jmp   prend
           
PR1:       cmp   PrButton,1
           jnz   PR2
           mov   RegimeBCD[1],101b
           mov   RegimeBCD[6],1
           jmp   PRend 
              
PR2:       cmp   PrButton,2
           jnz   PR3
           mov   RegimeBCD[0],1b
           mov   RegimeBCD[6],1b
           jmp   PRend    
pr3:       cmp   PrButton,3
           jnz   PR4
           mov   RegimeBCD[1],1b
           mov   RegimeBCD[6],11b
           jmp   PRend

pr4:       cmp   PrButton,4
           jnz   PR5
           mov   RegimeBCD[1],101b
           mov   RegimeBCD[6],11b
           jmp   PRend           

pr5:       cmp   PrButton,5
           jnz   PR6
           mov   RegimeBCD[1],111b
           mov   RegimeBCD[2],101b
           mov   RegimeBCD[6],11b
           jmp   PRend           
pr6:       cmp   PrButton,6
           jnz   PR7
           mov   RegimeBCD[1],1b           
           mov   RegimeBCD[5],1b
           jmp   PRend
pr7:       cmp   PrButton,7
           jnz   PRend
           mov   RegimeBCD[1],101b
           mov   RegimeBCD[5],1b
 
           jmp   PRend          
PRend:     call  OutNumbers                     
           ret
PrRegime   EndP
 
FocusInc   Proc
           mov   dx,1001b
           cmp   dx,focus
           jnz   FI1
           mov   focus,0
           jmp   FI2                                            
FI1:       inc   Focus
FI2:       ret
FocusInc   EndP

FocusDec   Proc
           cmp   Focus,0
           jnz   FD1
           mov   focus,9d
           jmp   FD2                                            
FD1:       dec   Focus
FD2:       ret           
FocusDec   EndP

FocusPT    Proc
           xor   ax,ax
           mov   ax,Focus
           mov   dx,4d
           sub   ax,dx
           jns   FPT1
           mov   focus,4
           jmp   FPT2
FPT1:      mov   focus,0          
FPT2:      ret
FocusPT    EndP

FocusIndicator   Proc           
           call  OutNumbers
           xor   ax,ax          
           mov   si,Focus
           mov   al,RegimeBCD[si]
           mov   si,ax
           xor   ax,ax
           mov   al,Numbers[si]
           mov   dx,10000000b
           add   al,dl
           mov   dx,focus
           out   dx,al
           mov   al,0
           out   11h,al          
           ret
FocusIndicator   EndP

NumOut     Proc
           xor   ax,ax
           mov   al,PrButton
           mov   dx,focus
           mov   di,focus
           mov   RegimeBCD[di],al
           mov   si,ax
           mov   al,numbers[si]
           mov   Regime[di],al
           out   dx,al
           
           call  FocusInc
           ret
NumOut     EndP

OutRangeTime1     Proc
           xor   ax,ax
           mov   al,RegimeBCD[4]
           mov   cl,4
           shl   ax,cl
           xor   dx,dx
           mov   dl,RegimeBCD[5]
           add   ax,dx
            
           xor   dx,dx
           mov   dl,00010011b
           sub   ax,dx
           js    ORT11
           mov   al,10000000b
           mov   cx,0fffh
ORT1Signal: out   11h,al
           loop  ORT1Signal
           mov   di,focus
           dec   di
           mov   RegimeBCD[di],0
           call  OutNumbers
           dec   focus
           call  FocusIndicator                                                        
ORT11:     ret
OutRangeTime1     EndP


OutRangeTime2     Proc
           xor   ax,ax
           mov   al,RegimeBCD[6]
           mov   cl,4
           shl   ax,cl
           xor   dx,dx
           mov   dl,RegimeBCD[7]
           add   ax,dx
            
           xor   dx,dx
           mov   dl,01011010b
           sub   ax,dx
           js    ORT21
           mov   al,10000000b
           mov   cx,0fffh
ORT2Signal: out   11h,al
           loop  ORT2Signal
           mov   di,focus
           dec   di
           mov   RegimeBCD[di],0
           call  OutNumbers
           dec   focus
           call  FocusIndicator                                                        
ORT21:     ret
OutRangeTime2     EndP

OutRangeTime3     Proc
           xor   ax,ax
           mov   al,RegimeBCD[8]
           mov   cl,4
           shl   ax,cl
           xor   dx,dx
           mov   dl,RegimeBCD[9]
           add   ax,dx
            
           xor   dx,dx
           mov   dl,01011010b
           sub   ax,dx
           js    ORT31
           mov   al,10000000b
           mov   cx,0fffh
ORT3Signal: out   11h,al
           loop  ORT3Signal
           mov   di,focus
           dec   di
           mov   RegimeBCD[di],0
           call  OutNumbers
           dec   focus
           call  FocusIndicator                                                        
ORT31:      ret
OutRangeTime3     EndP


OutRangePow   Proc
           xor   ax,ax
           mov   al,RegimeBCD[0]
           
           mov   ch,3
           mov   di,1
ORPcicl:   mov   cl,4
           shl   ax,cl
           xor   dx,dx
           mov   dl,RegimeBCD[di]
           add   ax,dx
           inc   di
           dec   ch
           jnz   ORPcicl                      
           
           mov   dx,0001000000000001b
           sub   ax,dx
           js    ORP1
           mov   al,10000000b
           mov   cx,0fffh
ORPSignal: out   11h,al
           loop  ORPSignal
           mov   di,focus
           dec   di
           mov   RegimeBCD[di],0
           call  OutNumbers
           dec   focus
           call  FocusIndicator                       
orp1:      ret
OutRangePow   EndP

TimeOutCheck     Proc
           mov   al,RegimeBCD[4]
           cmp   al,0
           jnz   TOC1
           mov   al,RegimeBCD[5]
           cmp   al,0
           jnz   TOC1
           mov   al,RegimeBCD[6]
           cmp   al,0
           jnz   TOC1
           mov   al,RegimeBCD[7]
           cmp   al,0
           jnz   TOC1
           mov   al,RegimeBCD[8]
           cmp   al,0
           jnz   TOC1
           mov   al,RegimeBCD[9]
           cmp   al,0
           jnz   TOC1                      
TOC2:      
           mov   al,10000000b
           mov   cx,0ffffh
TOCSignal: out   11h,al
           loop  TOCSignal
           mov   timeOut,1               
TOC1:      ret           
TimeOutCheck     EndP

RangeMinCheck    Proc
           mov   al,RegimeBCD[0]
           cmp   al,0
           jnz   RMC1
           mov   al,RegimeBCD[1]
           cmp   al,0
           jnz   RMC1
           
           xor   ax,ax
           mov   al,RegimeBCD[2]
           mov   cl,4
           shl   ax,cl
           xor   dx,dx
           mov   dl,RegimeBCD[3]
           add   ax,dx
            
           xor   dx,dx
           mov   dl,01010000b
           sub   ax,dx
           jns   RMC1
           mov   al,10000000b
           mov   cx,0fffh
RMCSignal: out   11h,al
           loop  RMCSignal
           jmp   RMCend
           
           
                                                                   
RMC1:      mov   al,RegimeBCD[4]
           cmp   al,0
           jnz   RMC2
           mov   al,RegimeBCD[5]
           cmp   al,0
           jnz   RMC2
           mov   al,RegimeBCD[6]
           cmp   al,0
           jnz   RMC2
           mov   al,RegimeBCD[7]
           cmp   al,0
           jnz   RMC2
           
           xor   ax,ax
           mov   al,RegimeBCD[8]
           mov   cl,4
           shl   ax,cl
           xor   dx,dx
           mov   dl,RegimeBCD[9]
           add   ax,dx
           
           xor   dx,dx
           mov   dl,00010000b
           sub   ax,dx
           jns   RMC2
           mov   al,10000000b
           mov   cx,0fffh
RMCSignal2: out   11h,al
           loop  RMCSignal2
           jmp   RMCend
           
           
RMC2:      call  timer
RMCend:    ret           
RangeMinCheck    EndP

Timer      Proc           
           mov   al,1000000b
           out   11h,al
T0:        mov   al,RegimeBCD[9]
           cmp   al,0
           jz    T1
           dec   al
           jmp   T2
T1:        mov   al,9
T2:        mov   RegimeBCD[9],al           
           cmp   al,9
           jnz   Tend
           
           mov   al,RegimeBCD[8]
           cmp   al,0
           jz    T3
           dec   al
           jmp   T4
T3:        mov   al,5
T4:        mov   RegimeBCD[8],al
           cmp   al,5
           jnz   Tend

           mov   al,RegimeBCD[7]
           cmp   al,0
           jz    T5
           dec   al
           jmp   T6
T5:        mov   al,9
T6:        mov   RegimeBCD[7],al
           cmp   al,9
           jnz   Tend
           
           mov   al,RegimeBCD[6]
           cmp   al,0
           jz    T7
           dec   al
           jmp   T8
T7:        mov   al,5
T8:        mov   RegimeBCD[6],al
           cmp   al,5
           jnz   Tend
           
           mov   al,RegimeBCD[5]
           cmp   al,0
           jz    T9
           dec   al
           jmp   T10
T9:        mov   al,9
T10:       mov   RegimeBCD[5],al
           cmp   al,9
           jnz   Tend           
            
           mov   al,RegimeBCD[4]
           cmp   al,0
           jz    T11
           dec   al
           jmp   T12
T11:       mov   al,2
T12:       mov   RegimeBCD[4],al            
            
Tend:      call  pause
           call  PlateSpin
           
           cmp   StopHook,1
           jz    Tret                                                     
           call  OutNumbers
           call  TimeOutCheck
           cmp   TimeOut,0            
           jnz   Tret
           jmp   T0
Tret:      mov   TimeOut,0
           mov   StopHook,0
           mov   al,0
           out   11h,al
           ret
Timer      EndP
  
PlateSpin  Proc
           cmp   PlateX,10000000b           
           jz    PSpin1
           cmp   PlateY,10000000b
           jz    PSpin2
           cmp   PlateX,1b
           jz    PSpin3          
           
           mov   al,11111111b
           out   12h,al
           
PSpin0:    mov   al,PlateY
           out   14h,al
           mov   al,PlateX
           out   13h,al
           rol   PlateX,1
           jmp   PSpinEnd
PSpin1:    cmp   PlateY,10000000b
           jz    PSpin2
           mov   al,PlateX
           out   13h,al
           mov   al,PlateY
           out   14h,al
           rol   PlateY,1
           jmp   PSpinEnd
                      
PSpin2:    cmp   PlateX,1b
           jz    PSpin3
           mov   al,PlateY
           out   14h,al
           mov   al,PlateX
           out   13h,al
           ror   PlateX,1
           jmp   PSpinEnd

PSpin3:    cmp   PlateY,1b
           jz    PSpin0
           mov   al,PlateX
           out   13h,al
           mov   al,PlateY
           out   14h,al
           ror   PlateY,1
           jmp   PSpinEnd
                  
PSpinEnd:  ret
PlateSpin  EndP
;***********************************
Start:     mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop            
           call  Inicial           
begin:     call  Hook
           call  ProcSel
           call  OutRangePow
           call  OutRangeTime1           
           call  OutRangeTime2
           call  OutRangeTime3            
           call  FocusIndicator
           jmp   begin
;***********************************                      
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
