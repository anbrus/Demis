.286
; Программа тестирования компьютерных шлейфов
RomSize       EQU   4096
Port_In_0     EQU   0
Port_Out_0    EQU   0
Port_Out_1    EQU   1
Port_Out_2    EQU   2
Port_Out_3    EQU   3
Port_Out_4    EQU   4


Data          SEGMENT AT 0BA00H

Buf1          DW    ?
Buf2          DW    ?
Buf3          DW    ?
Button        DB    ?
ButtonG       DB    ?
ModeBtn       DB    ?
KolBtn        DB    ?
KolLine       DB    ?
KolPusk       DB    ?
KolPusk2      DB    ?
kolp          DB    ?
kolp2         DB    ? 
KolGoden      DB    ?
KolGoden2     DB    ?
Koll          DB    ? 
KolLine_Er    DB    ?
KLSv          DB    ?
KPSv1         DB    ?
KPSv2         DB    ? 
Mode          DB    ?
NSv           DB    ?
Pusk          DB    ?
FlagPusk      DB    ?
AloudePusk    DB    ?
NextLine      DB    ?
FlagNextLine  DB    ?
FlagP         DB    ?
FlagN         DB    ?
Shleph        DB    ?
ShlephG       DB    ?
Port_Table    DW    ?
IdealConnect_DataTable       DB    8 DUP (8 DUP (?))
RealConnect_DataTable        DB    8 DUP (8 DUP (?))
RErrorConnect_DataTable      DB    8 DUP (8 DUP (?))
ErrorConnect_DataTable       DB    8 DUP (8 DUP (?))
TrueConnect_DataTable        DB    8 DUP (8 DUP (?))
Data          ENDS

Stk        SEGMENT AT 0BD80H
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS

Code          SEGMENT  
nmax              EQU   50
n                 EQU   8
Image             DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,5Fh
IC_DataTable      DB    80h,40h,20h,10h,8h,4h,2h,1h
RErrorC_DataTable DB    80h,42h,24h,18h,10h,24h,42h,81h 
RC_DataTable      DB    80h,40h,20h,10h,8h,4h,2h,1h
              ASSUME ds:Data,es:Data,cs:Code
           
Prepare proc near  
           mov  ch,n
           xor  ax,ax
           xor  dx,dx       
      mA:  mov  cl,n
           xor  si,si             
      mB:  mov  al,0
           mov  es:[bx][si],al                                      
           mov  es:[bp][si],al 
           add  si,1
           dec  cl          
           cmp  cl,0           
           jnz  mB          
           add  bx,n 
           add  bp,n 
           dec  ch 
           cmp  ch,0
           jnz  mA   
           mov  KolLine,0 
           mov  Koll,0
           mov  KolPusk2,0 
           mov  KolPusk,0
           mov  KolGoden2,0 
           mov  KolGoden,0           
           mov  KolP,0
           mov  KolP2,0   
           mov  KPSv1,0                                                   
           mov  KPSv2,0
           mov  FlagPusk,0
           mov  FlagNextLine,0   
           mov  Pusk,0        
           mov  NextLine,0
           mov  NSv,0  
           mov  KLSv,0        
           mov  FlagN,0    
           mov  FlagP,0   
           mov  AloudePusk,0     ; Запрешение вывода на индикатор NetLine                          
           mov  Shleph,0         ; Флаг годности шлейфа : 0FFH - Не Годен
           mov  ShlephG,0 
           mov  ButtonG,0          
           mov  KolLine_Er,0                 
           ret
Prepare Endp

TablePrepare  proc near ; Перевод табл. из упакованного формата.
           mov ch,n
           xor ax,ax
           xor dx,dx       
    meto:  mov dh,80h
           mov cl,n
           xor si,si           
           mov dl,cs:[di]  
    met11: mov ah,dh
           and ah,dl
           mov al,0
           cmp ah,0
           jz  met22
           mov al,0ffh
    met22: mov es:[bx][si],al
           shr dh,1                                      
           add si,1
           dec cl          
           cmp cl,0           
           jnz met11          
           add di,1
           add bx,n 
           dec ch 
           cmp ch,0
           jnz meto   
           ret
TablePrepare  Endp ; Перевод табл. из упакованного формата.

ModeInput proc near   ; Ввод режимов
           mov  ModeBtn,0
           mov  KolBtn,0                     
           mov  Pusk,0   
           mov  NextLine,0 
           mov  Button,0
           mov  dx,Port_In_0
           in   al,dx
           call VibrDest
           mov  bh,al
           test al,1h
           jnz  mi1
           mov  ModeBtn,0ffh
      mi1: mov  al,bh
           test al,2h
           jnz  mi2
           mov  KolBtn,0ffh
      mi2: mov  al,bh
           and  al,04h      
           cmp  al,0
           jnz  mi3
           mov  FlagNextLine,0ffh                             
      mi3: mov  al,bh
           and  al,08h      
           cmp  al,0
           jz   mi4
           mov  FlagPusk,0ffh
      mi4: test FlagNextLine,0ffh
           jz   mi5
           mov  al,bh
           and  al,04h
           test al,0
           jnz  mi5                
           mov  FlagNextLine,0
           mov  NextLine,0ffh            
           mov  FlagN,0ffh                            
      mi5: test FlagPusk,0ffh
           jz   mi6
           mov  al,bh
           and  al,08h
           test al,0
           jnz  mi6
           mov  FlagPusk,0
           mov  Pusk,0ffh 
           mov  FlagP,0ffh              
      mi6: mov  al,bh
           and  al,10h              
           cmp  al,0
           jnz  mi7
           mov  Button,0ffh
      mi7: ret
ModeInput endp  ; Ввод режимов

VibrDest proc near
      vd1: mov  ah,al
           mov  bh,0
      vd2: in   al,dx
           cmp  ah,al
           jne  vd1
           inc  bh
           cmp  bh,nmax
           jne  vd2
           mov  al,ah                  
           ret
VibrDest endp

CountPusk proc near  ; Подсчет кол-ва шлейфов (нажатий  "Пуска") 
           xor  ax,ax   
           xor  bx,bx                 
           mov  al,FlagPusk
           cmp  al,0ffh
           jz   ml  ;itmo41
           mov  al,Pusk
           cmp  al,0ffh        
           jz   itmo41
           mov  al,FlagP           
           cmp  al,0
           jz   itmo41 
           jmp  bn 
      ml:  jmp  itmo41              
      bn:  mov  FlagP,0             
           mov  FlagPusk,0          
           mov  KolLine,0      
           mov  KolLine_er,0
           mov  al,button
           mov  buttonG,al
           mov  ShlephG,al                       
           mov  AloudePusk,0ffh                                                                              
           mov  cl,KolPusk         
           mov  ch,KolPusk2
           mov  KolP,cl                                   
           mov  KolP2,ch                     
           call add_kol
           mov  cl,KolP
           mov  ch,KolP2                      
           mov  KolPusk,cl
           mov  KolPusk2,ch   
           cmp  ButtonG,0  
           jnz   itmo41              
           mov  cl,KolGoden         
           mov  ch,KolGoden2
           mov  KolP,cl                                   
           mov  KolP2,ch                     
           call add_kol
           mov  cl,KolP
           mov  ch,KolP2                      
           mov  KolGoden,cl
           mov  KolGoden2,ch               
   itmo41: cmp  KolBtn,0
           jnz  itmo51   
           mov  cl,KolGoden         
           mov  ch,KolGoden2
           mov  KolP,cl                                   
           mov  KolP2,ch  
           jmp  itmo61
   itmo51: mov  cl,KolPusk         
           mov  ch,KolPusk2
           mov  KolP,cl                                   
           mov  KolP2,ch                             
   itmo61: xor  dx,dx     
           lea  bx,Image          
           mov  dl,KolP       
           add  bx,dx
           mov  al,Image[bx]          
           mov  KPSv1,al
           xor  dx,dx              
           lea  bx,Image 
           mov  dl,KolP2    
           add  bx,dx           
           mov  al,Image[bx]
           mov  KPSv2,al           
           ret    
CountPusk endp  ; Подсчет кол-ва шлейфов (нажатий  "Пуска") 

add_kol proc near           
           mov  cl,KolP 
           mov  al,cl
           add  al,1
           daa                   ; Десятичная коррекция
           mov  bl,al   
           cmp  al,10d
           jbe  itmo31          
           mov  bl,0  
           mov  ch,KolP2                                    
           mov  al,ch
           add  al,1
           daa   
           mov  bh,al      
           cmp  al,10d
           jbe  itmo312          
           mov  bh,0           
  itmo312: mov  ch,bh           
   itmo31: mov  cl,bl                  
           mov  KolP,cl
           mov  KolP2,ch    
           ret
add_kol endp

CountLine proc near ; Подсчет кол-ва Линий 
          mov  al,AloudePusk ; Разрешение вывода на индикатор NextLine 
          cmp  al,0
          jz   itmo4   
          xor  ax,ax    
          mov  al,FlagNextLine   
          cmp  al,0
          jnz  itmo4
          mov  al,NextLine
          cmp  al,0ffh        
          jz   itmo4
          mov  al,FlagN
          cmp  al,0
          jz   itmo4                                       
          mov  FlagN,0             
          mov  FlagNextLine,0 
          cmp  ModeBtn,0        ;Переход по условию режим = "Ручной"
          jnz  mlv0        
          mov  al,KolLine
          add  al,1
          daa         
          cmp  al,9d
          jb   itmo3          
          mov  al,1           
   itmo3: mov  KolLine,al
          mov  koll,al
          jmp  itmo4       
   mlv0:  mov  al,KolLine_Er
          add  al,1
          daa         
          cmp  al,9d
          jb   itd3          
          mov  al,1           
   itd3:  mov  KolLine_Er,al
   itmo4: cmp  ModeBtn,0
          jz   ito65
          cmp  SHLEPH,0 
          jz   ito45       
   ito30: mov  al,kolline_er       
          mov  koll,al
          jmp  ito61
   ito45: mov  koll,0
          jmp  ito61  
   ito65: mov  al,KolLine
          mov  koll,al                     
   ito61: xor  dx,dx     
          lea  bx,Image          
          mov  dl,Koll            
          add  bx,dx
          mov  al,Image[bx] 
          mov  KLSv,al    
          ret
CountLine endp ; Подсчет кол-ва Линий 


SearchError  proc near   ; Поиск щшибочного соединения          
           mov  SHLEPH,0
           mov  al,ButtonG
           cmp  al,0
           jz   mtff
           mov  ax,Buf2          
           mov  bx,ax  
   mtff:   push bp
           mov  bp,Buf3
           mov  ch,n
           xor  ax,ax
           xor  dx,dx       
      wmA: mov  cl,n
           xor  si,si             
      wmB: mov  al,es:[bx][si]
           mov  es:[bp][si],al                                      
           add  si,1
           dec  cl          
           cmp  cl,0           
           jnz  wmB          
           add  bx,n 
           add  bp,n 
           dec  ch 
           cmp  ch,0
           jnz  wmA 
           pop  bp
           mov  ch,n
           mov  ax,Buf3  
           mov  bx,ax                      
           xor  ax,ax
           xor  dx,dx    
    mtA:   mov  cl,n
           xor  si,si          
    mtB:   mov  al,es:[bx][si]
           mov  ah,es:[bp][si]
           cmp  al,ah
           je   mtC 
           mov  SHLEPH,0ffh
           push bx
           push cx
           push dx
           mov  bx,Buf1
           xor  ax,ax  
           mov  dh,dl
           mov  al,dl            ;bx=bx+ch*8
           mov  dl,8   
           mul  dl      
           add  bx,ax  
           mov  ax,1
           mov  es:[bx][si],ax
           pop  dx
           pop  cx
           pop  bx           
    mtC:   add si,1
           dec cl          
           cmp cl,0           
           jnz mtB          
           add bp,n
           add bx,n                                
           add dx,1
           dec ch 
           cmp ch,0
           jnz mtA   
ret
SearchError  Endp ;  Поиск щшибочного соединения

ContactNumber proc near ;  Нахождение номера соединения  
           cmp  ModeBtn,0
           jnz  gghh2   
           xor  ax,ax      ; SHLEPH = 0 ,ModeBtn = 0.
           mov  cl,8       ; Алг. Номер реального соединения 
           mov  si,0
           mov  dh,80h
           mov  al,KolLine
           cmp  al,0
           jz   tzz
           sub  al,1
           mov  dl,8
           mul  dl
           add  bx,ax  
           xor  ax,ax       
      az1: mov  dl,es:[bx][si]
           mov  ah,0
           cmp  dl,0
           jz   az2                      
           mov  ah,dh      ; 1h,2h,4h,...,80h
      az2: or   al,ah                       
           inc  si      
           shr  dh,1
           dec  cx
           cmp  cx,0
           jnz  az1          
           jmp  gghh                                                     
    gghh2: mov  al,shleph
           cmp  al,0
           jz   gghh
           xor  ax,ax     
           mov  cl,8        
           mov  si,0
           mov  dh,80h
           mov  al,KolLine_er
           cmp  al,0
           jz   tzz
           sub  al,1
           mov  dl,8
           mul  dl
           add  bp,ax  
           xor  ax,ax       
      dz1: mov  dl,es:[bp][si]
           mov  ah,0
           cmp  dl,0
           jz   dz2                      
           mov  ah,dh           ; 1h,2h,4h,...,80h
      dz2: or   al,ah                       
           inc  si      
           shr  dh,1
           dec  cx
           cmp  cx,0
           jnz  dz1          
           jmp  gghh                               
      tzz: mov  al,0            ; SHLEPH = 0 ,ModeBtn = 1.     
     gghh: mov  NSv,al                
           ret
ContactNumber endp ;  Нахождение номера соединения  


SvetodiodOut proc near
           mov  al,1h
           cmp  ModeBtn,0  ; Вывод режимов
           jne   itmo1
           mov  al,2h
    itmo1: mov  ah,al
           mov  al,4h
           cmp  KolBtn,0      ; Вывод Количества
           je   itmo2
           mov  al,8h
    itmo2: or   al,ah
           mov  dl,0
           mov  dh,aloudepusk          
           cmp  dh,0
           jz   itmo33                 
           mov  dl,10h
           cmp  SHLEPH,0      ; Вывод годности шлейфа
           je   itmo33
           mov  dl,20h
   itmo33: or   al,dl           
           mov  ah,40h
           cmp  Button,0      ; Вывод инф. с кнопки "Смена шлейфа"
           jz   itmo44
           mov  ah,80h
   itmo44: or   al,ah
           mov  dx,Port_Out_0
           out  dx,al 
           mov  al,NSv
           mov  dx,Port_Out_1            
           out  dx,al 
           mov  al,KLSv
           mov  dx,Port_Out_2
           out  dx,al               
           mov  al,KPSv1
           mov  dx,Port_out_3
           out  dx,al    
           mov  al,KPSv2           
           mov  dx,Port_out_4  
           out  dx,al               
           ret
SvetodiodOut Endp

    
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop          
           lea   bx,ErrorConnect_DataTable   
           lea   bp,TrueConnect_DataTable              
           call  Prepare                      ; Подготовка и обнуление Таблицы ErrorConnect_DataTable
           lea   di,IC_DataTable
           lea   bx,IdealConnect_DataTable 
           call  TablePrepare                 ; Перевод табл. из упакованного формата.
           lea   di,RC_DataTable
           lea   bx,RealConnect_DataTable 
           call  TablePrepare                 ; Перевод табл. из упакованного формата.                                     
           lea   di,RErrorC_DataTable
           lea   bx,RErrorConnect_DataTable 
           call  TablePrepare                 ; Перевод табл. из упакованного формата.                                     
Begin:     call  ModeInput                    ; Ввод режимов                      
           call  CountPusk                    ; Подсчет кол-ва шлейфов (нажатий  "Пуска") 
           call  CountLine                    ; Подсчет кол-ва Линий                                 
           lea   bx,RealConnect_DataTable
           lea   bp,IdealConnect_DataTable  
           lea   ax,ErrorConnect_DataTable         
           mov   Buf1,ax               
           lea   ax,RErrorConnect_DataTable         
           mov   Buf2,ax               
           lea   ax,TrueConnect_DataTable         
           mov   Buf3,ax                                              
           call  SearchError                  ; Поиск ошибочного соединения          
           lea   bx,RealConnect_DataTable     ; Загрузка масс. с реальным соединением
           lea   bp,ErrorConnect_DataTable    ; Загрузка масс. с ошибкой
           call  ContactNumber                ; Нахождение номера соединения  
           call  SvetodiodOut                 ; Вывод на светодиоды и семисегментные индикаторы                                                                   
           jmp   Begin
           org   0FF0h 
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
