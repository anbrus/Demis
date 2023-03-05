RomSize         EQU   4096

DispInPort       EQU   0          ; порт дисплея 
KeyInPort        EQU   0          ; порт кнопок
KeyLinePort      EQU   8          ; порт активной линии клавиатуры

Data       SEGMENT AT 2000h 
           NextKbLine   db ?
           Indicator    db ?
           ready        db ?
           totalblocks  db ?
           errorblocks  db ?

           regadr       dw ?
           ofsadr       dw ?
           segbegin     dw ?
           segend       dw ?
           offsetbegin  dw ?
           offsetend    dw ?
           
           nextgran     db ?
           csumm_dop    db ?
           csumm        db ? 
           press        db ?
           vid          db ?
           sost         db ?
           reslt        db ?
           totaldeadadr dw ?
           currentdead  dw ?           
           deadaddr     dw 512 DUP(?)                       
Data       ENDS

Stk        SEGMENT AT 1000h
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,ss:Stk           
           Obraz db 03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h           
           AdrHex db 00h,01h,02h,03h,04h,05h,06h,07h,08h,09h,0Ah,0Bh,0Ch,0Dh,0Eh,0Fh
Init PROC NEAR                  ;Установка начальных значений переменных

           mov   Ready,0
           mov   NextKbLine,1
           mov   indicator,5
           mov   regadr,0
           mov   ofsadr,0           
           mov   currentdead,0           
           mov   totaldeadadr,0
           mov   segbegin,0
           mov   segend,0
           mov   offsetbegin,0
           mov   offsetend,0
           mov   vid,0
           mov   csumm_dop,0
           mov   csumm,-1
           mov   nextgran,0
           mov   reslt,-1
           mov   sost,1
           mov   al,0
           out   9,al 
           mov   cx,length deadaddr    
ini:       mov   si,cx
           mov   deadaddr[si],0
           loop  ini
           xor   si,si
           ret
Init ENDP


CheckSost  PROC NEAR             ; Отображение текущего состояния
           push  ax           
           mov   al,Sost
           out   7,al                      
           pop   ax
           ret
CheckSost  ENDP


Statistic  PROC NEAR             ; Отображение статистики проверенных/ошибочных блоков
           push  ax bx di
           
           cmp  vid,0
           je   St1
           mov  al,errorblocks
           jmp  St2
St1:       mov  al,totalblocks
St2:       AAM
           mov bx,ax
           xor ax,ax           
           mov al,bh           
           mov di,ax
           mov al,Obraz[di]
           out 6,al

           mov al,bl           
           mov di,ax
           mov al,Obraz[di]
           out 5,al         

           pop  di bx ax
           ret  
Statistic  ENDP



KeyInput  PROC NEAR               
           push  ax bx dx cx
           
           mov   al,NextKbLine
           shl   al,1
           cmp   al,10000b
           jne   Key0
           mov   al,1
           
Key0:      mov   NextKbLine,al
           out   KeyLinePort,al  
           
           in    al,0
           call  Drebezg          
           mov   press,al
              
Key1:      in    al,0
           cmp   al,0
           jne   Key1           
           mov   al,press           
                     
           cmp   al,20h            ;нажата "Сброс"
           jne   Key2              ;  
                  
           call  ClearDisp         ;  
           call  Init              ;        
           jmp   ExBl              ;
           
Key2:      cmp   al,0              ; выход 
           je    Exit_k            ; если 
           cmp   Sost,0ffh         ; ничего не нажато
           je    Exit_k            ;
                      
           cmp   al,40h            ; нажата "Ввод"
           jne   Key5              ; ecли нет - выход           

           call  ClearDisp         ; погасить табло                        
           cmp   nextgran,1        
           je    Key3                      
           mov   nextgran,1
           mov   ax,regadr
           mov   segbegin,ax           
           mov   ax,ofsadr
           mov   offsetbegin,ax                         
           mov   al,1              ; зажигается лампочка
           out   9,al              ; первой введенной границы                      
           mov   Indicator,5
Exit_k:    jmp   ExBl           
   
Key3:      push  ax
           mov   nextgran,2          
           mov   ax,regadr  
           mov   segend,ax
           mov   ax,ofsadr           
           mov   offsetend,ax     
           mov   Sost,1      
           mov   ready,1
                                   ; проверка корректности введенных границ блока  
           mov   ax, segbegin
           cmp   ax, segend
           ja    Key8
           cmp   ax, segend
           jne   Key4 
           mov   ax, offsetbegin
           cmp   ax, offsetend   
           jb    Key4           
key8:      mov   Sost,0ffh           
           mov   ready,0
           
Key4:      mov   al,3              ; зажигается лампочка
           out   9,al              ; второй введенной границы           
           pop   ax                                      
           jmp   ExBl

Key5:      cmp   al,80h
           jne   Key6
           mov   totalblocks,0
           mov   errorblocks,0
           jmp   ExBl
           
Key6:      call  KbInput           ;нажаты клавиши клавиатуры                                                  
ExBl:      pop   dx cx bx ax
           ret
KeyInput ENDP



OtherInput PROC NEAR
           push  ax bx cx dx        
           in    al,KeyInPort+1
           
           mov   ah,al                      
Ot0:       in    al,KeyInPort+1   
           cmp   al,0
           jne   Ot0           
           mov   al,ah
           
           cmp   al,0
           je    ExInpTest
           cmp   Sost,0ffh
           je    ExInpTest
           
           xor   cx,cx
Ot1:       cmp   al,1
           je    Ot2
           shr   al,1
           add   cx,1
           jmp   Ot1
                
Ot2:       mov   al,11b                                
           out   9,al
           mov   ax,cx
           lea   bx,Base
           mov   cl,3
           shl   ax,cl
           add   ax,bx
           jmp   ax
           
Base:      
           call  SubDead     ;нажата  "<"
           jmp   ExInpTest                            
           NOP  
           NOP  
           NOP  
           call  AddDead     ;нажата  ">"
           jmp   ExInpTest              
           NOP  
           NOP                                    
           NOP  
           call  Test1          ;нажата  "Тест ША"
           jmp   ExInpTest                         
           NOP  
           NOP  
           NOP                                   
           call  Calc_Dop       ;нажата  "Рассчет доп. к контр. сумме"
           jmp   ExInpTest 
           NOP  
           NOP  
           NOP                              
           call  Test2          ;нажата  "Тест ШД"
           jmp   ExInpTest       
           NOP  
           NOP  
           NOP                        
           call  Test3          ;нажата  "Тест ПЗУ"
           jmp   ExInpTest            
           NOP  
           NOP  
           NOP                                         
           mov   vid,0          ;нажата  "Проверено"
           jmp   ExInpTest                  
           NOP  
           NOP  
           NOP                        
           mov   vid,1          ;нажата  "С ошибками"
           jmp   ExInpTest                  
                                
ExInpTest: pop   dx cx bx ax
           ret
OtherInput ENDP


Mistmaches PROC NEAR
           cmp   Reslt,1
           jne   ExitMist           
           push  ax bx di si
           
           mov   di,currentdead
           mov   si,di
           
           mov   ax,deadaddr[si]           
           shr   ax,12
           mov   di,ax
           mov   al,Obraz[Di]
           out   DispInPort+4,al                                           
           
           mov   ax,deadaddr[si+2]                       
           shr   ax,8
           xor   ah,ah
           shr   ax,4
           xor   ah,ah           
           mov   di,ax
           mov   al,Obraz[di]  
           out   DispInPort+3,al                                                      

           mov   ax,deadaddr[si+2]                       
           shr   ax,4
           xor   ah,ah
           shr   ax,4
           xor   ah,ah           
           mov   di,ax
           mov   al,Obraz[di]  
           out   DispInPort+2,al                                                      

           jmp   Mis1
           
ExitMist:  jmp   ExMist
                      
Mis1:      mov   ax,deadaddr[si+2]                       
           xor   ah,ah
           shr   ax,4
           xor   ah,ah           
           mov   di,ax
           mov   al,Obraz[di]  
           out   DispInPort+1,al                                                      

           mov   ax,deadaddr[si+2]                       
           xor   ah,ah
           shl   ax,4
           xor   ah,ah           
           shr   ax,4           
           xor   ah,ah                      
           mov   di,ax
           mov   al,Obraz[di]  
           out   DispInPort,al                                                      
                      
           pop  si di bx ax
ExMist:    ret
Mistmaches ENDP


; Основная программа
include tests.asm 
include system.asm     

Start:
           mov   ax,Data            ; Системная подготовка,
           mov   ds,ax              ; инициализация значений            
           mov   es,ax              ; сегментных регистров
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop                        

           mov totalblocks,0
           mov errorblocks,0           
           call  Init               ; Инициализация начальных значений переменных
                                 
L0:       
           call  CheckSost          ; Отображение текущего состояния
           call  Statistic          ; Отображение статистики проверенных/ошибочных блоков           
           call  KeyInput           ; Опрос клавиш клавиатуры и кнопок "Сброс", "Ввод"
                                    ; "Начать новый отсчет"            
           call  OtherInput         ; Опрос нажатия кнопок выбора теста, "<", ">", 
                                    ; "Проверено", "С ошибками"                                    
           call  Mistmaches         ; просмотр ошибок, если тест ША, ШД завершен с ошибками
           
           jmp   L0
                   
           ; рассчет адреса стартовой точки программы        
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
