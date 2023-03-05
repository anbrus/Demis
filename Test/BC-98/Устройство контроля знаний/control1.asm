
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

Data Segment at 040h 
;Здесь размещаются описания переменных
           regim      db     ?;содержит данные о режиме работы
           outdiod    db     ?;ответ пользователя
           OutMas     db 10 dup (?);общее количество вопросов
                                   ;количество вопросов в варианте 
                                   ;номер вопроса
                                   ;секунды времени
                                   ;минуты времени
           ;в 2/10 форме           ;секунды начального времени
                                   ;минуты начального времени
                                   ;правильные ответы
                                   ;оценка %
                                   ;номер варианта
           DigMas db  4  dup (?)     ;кол-во вопросов в варианте
                                     ;Общее количество вопросов 
                                     ;номер вопроса
                                     ;номер варианта
           DigMasV db   ?       ;номер вопроса в варианте 
                                                                 
           VoprMas    db 100 dup (?);массив вопросов               
           VarMas     dw 101 dup (100 dup (?));массив вариантов               
           TimeSwitch db     ?;Вкл/выкл времени 
           Time       dw     ?;Время(мин.,сек.)
           StartR     db     ?;Тест идет
           TestEnd    db     ?;Тест закончен        
Data ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант
       Image      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
                  db    07Fh,05Fh,078h
       kick       db    (5)
       TypeVM     db    (2)
        NumVM     db    (100)
          ASSUME cs:Code,ds:Data,es:Data
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
;инициализация переменных
           call  Inicializ
StartC:          
;Здесь размещается код программы
           call  timer
           call  outing
           in    al,0
           cmp   al,0
           jz    RGIN2
           call  BSFprog
           mul   kick
           add   ax,offset RGIN1
           jmp   ax
RGIN1:                 
           call  Progr
           jmp   StartC
           call  Obuch
           jmp   StartC
           call  Ekzam
           jmp   StartC
           call  BotStart
           jmp   StartC
           call  BotVopr
           jmp   StartC
           call  BotDuwn1
           jmp   StartC
           call  BotUp1
           jmp   StartC
           call  TimeSW
           jmp   StartC
RGIN2:     
           in    al,1
           cmp   al,0
           jz    RGIN3
           call  BSFprog
           mul   kick
           add   ax,offset RGIN22
           jmp   ax
RGIN22:    call  BotUp2
           jmp   StartC
           call  BotDown2
           jmp   StartC
           call  Input
           jmp   StartC
           call  Bot1
           jmp   StartC
           call  Bot2
           jmp   StartC
           call  Bot3
           jmp   StartC
           call  Bot4
           jmp   StartC
           call  Bot5
           jmp   StartC
 RGIN3:    
           in    al,2
           cmp   al,0
           jz    RGIN333
           call  BSFprog
           mul   kick
           add   ax,offset RGIN33
           jmp   ax
 RGIN33:   call  InputVop
           jmp   RGIN333
           
           call  BotUp3
           jmp   RGIN333
           
           call  BotDown3
           jmp   RGIN333
           call  Reset
RGIN333:   jmp   StartC
;Здесь описываются подпрограммы
BSFprog    proc
           mov   ah,0
           xchg  ah,al
      m1:  cmp   ah,1
           je    return
           inc   al
           shr   ah,1
           jmp   m1     
  return:  xor   ah,ah
           ret      
BSFprog    endp

Progr      proc
           and   regim,11111000b
           add   regim,00000001b
           mov   al,regim
           out   0,al
           
           mov   outmas[7],0
           mov   outmas[8],0
           mov   al,0
           out   0ch,al
           out   0dh,al
           
           mov   OutDiod,0
           
           mov   startR,0
           mov   TestEnd,0
           mov   DigMasV,0
           
           mov   si,5
           mov   dx,4
           call  Indication
           mov   si,6
           mov   dx,6
           call  Indication
           ret
Progr      endp

Obuch      proc
           mov   regim,00100010b
           mov   al,regim
           out   0,al
           
           mov   dx,word ptr Outmas[5]
           mov   word ptr Outmas[3],dx
           
           mov   OutDiod,0
           
           mov   outmas[7],0
           mov   outmas[8],0
           mov   al,0
           out   0ch,al
           out   0dh,al
           
           mov   TimeSwitch,1
           mov   startR,0
           mov   TestEnd,0
           Mov   DigMasV,0
           
           xor   ah,ah
           mov   al,digmas[3]
           mul   NumVM
           mov   bx,ax
           mov   si,0
           mov   dx,VarMas[bx][si]
           mov   digmas[2],dh
           mov   outMas[2],dl
           call  OutIni
           ret
Obuch      endp 

Ekzam      proc
           Mov   regim,00100100b
           mov   al,regim
           out   0,al
           
           mov   dx,word ptr Outmas[5]
           mov   word ptr Outmas[3],dx
           
           mov   OutDiod,0
           
           mov   outmas[7],0
           mov   outmas[8],0
           mov   al,0
           out   0ch,al
           out   0dh,al
           
           mov   TimeSwitch,1
           mov   StartR,0
           mov   TestEnd,0
           mov   DigmasV,0
           
           ;установка вопроса заданного варианта
           xor   ah,ah
           mov   al,digmas[3]
           mul   NumVM
           mov   bx,ax
           mov   si,0
           mov   dx,VarMas[bx][si]
           mov   digmas[2],dh
           mov   outMas[2],dl
           
           call  OutIni
           ret
Ekzam      endp

OutIni     proc
           mov   si,2
           mov   dx,2
           call  Indication
           
           mov   si,5
           mov   dx,4
           call  Indication
           mov   si,6
           mov   dx,6
           call  Indication
           
           mov   si,7
           mov   dx,0ah
           call  Indication
                      
           mov   si,0
           mov   dx,8
           call  Indication
           ret
OutIni     endp

BotStart   proc
           test  regim,1
           jnz   noSt
           test  timeswitch,1
           jz    NoSt
           mov   StartR,1
           
   noSt:   in    al,0
           test  al,00001000b
           jnz   noSt
           ret
BotStart   endp 

BotVopr    proc
           test  regim,00000001b
           jz    me
           mov   al,regim
           and   regim,11000111b
           and   al,00111000b
           shl   al,1
           test  al,01000000b
           jz    m2
           mov   al,00001000b
       m2: 
           or    al,regim
       ;индикация светодиодом      
           mov   regim,al
           out   0,al
       ;индикация семисегментным индикатором
           mov   al,regim ;передача параметров
           shr   al,3     ;в подпрограмму Ind.
           and   ax,0007h
           call  BSFprog
           mov   si,ax
           mov   dx,2
           call  Indication 
       me: in    al,0
           test  al,00010000b
           jnz   me   
           ret
BotVopr    endp 

BotUp1     proc
           test  regim,00000110b
           jnz   NoBU1e 
           mov   al,regim
           shr   al,3
           and   ax,0007h
           call  BSFprog
           mov   si,ax
           mov   al,OutMas[si]
           inc   al
           daa
           inc   DigMas[si]
           mov   OutMas[si],al
           
           cmp   si,2    ;просмотр вопросов
           jnz   NoSI2
           mov   al,DigMas[2]
           cmp   al,DigMas[1]
           jb   SI2
           mov   DigMas[si],0
           mov   OutMas[si],0  
  SI2:     xor   bh,bh
           mov   bl,DigMas[si]
           
           mov   al,VoprMas[bx]
           mov   outdiod,al                      
           out   1,al
  NoSI2:   
           
           cmp   si,0  ;ввод кол-ва вопросов в варианте
           jnz   NoSI0
           mov   al,DigMas[1]
           cmp   DigMas[si],al
           jbe   NoSI0
           mov   DigMas[si],1 
           mov   OutMas[si],1
           jmp   NoBU1e   
    NoSI0: 
           cmp   si,1  ;ввод общ. кол-ва вопросов
           jnz   NoSI1 
           cmp   DigMas[si],064h
           jne   NoSI1
           mov   DigMas[si],1
           mov   OutMas[si],1  
           jmp   NoBU1e
    NoSI1: 
           
           mov   dx,2           
           call  Indication
                      
   NoBU1e: in    al,0
           test  al,1000000b
           jnz   NoBU1e
  BU1end:  ret
BotUp1     endp
BotDuwn1   proc
           test  regim,00000110b
           jnz   NoBD1e
           
           mov   al,regim
           shr   al,3
           and   ax,0007h
           call  BSFprog
           mov   si,ax
           mov   al,OutMas[si]
           dec   al
           das
           mov   OutMas[si],al
           dec   DigMas[si]

           cmp   si,2    ;просмотр вопросов
           jnz   dNoSI2
        ;   mov   al,Digmas[2]
           cmp   DigMas[2],064h
           jbe   dSI2
           mov   al,digmas[1]
           dec   al
           mov   DigMas[2],al;063h
           mov   al,outMas[1]
           dec   al
           das
           mov   OutMas[2],al;99h
 dSI2:     xor   bh,bh
           mov   bl,DigMas[2]
           
           mov   al,VoprMas[bx]
           mov   outdiod,al                      
           out   1,al
  dNoSI2:   
           
           cmp   si,0    ;ввод кол-ва вопросов в варианте
           jnz   dNoSI0
           cmp   DigMas[0],0
           jne   dNoSI0
           mov   al,DigMas[1]
           mov   DigMas[0],al
           mov   al,OutMas[1] 
           mov   OutMas[0],al
           jmp   NoBd1e   
    dNoSI0: 
           cmp   si,1  ;ввод общ. кол-ва вопросов
           jnz   dNoSI1 
           cmp   DigMas[si],0ffh
           jne   dNoSI1
           mov   DigMas[si],063h
         ;  mov   OutMas[si],063h 
           jmp   NoBd1e
    dNoSI1: 
           mov   dx,2           
           call  Indication
                                
  NoBD1e:  in    al,0
           test  al,100000b
           jnz   NoBD1e
           ret
BotDuwn1   endp


Indication proc
          
           mov   bx,offset Image
           mov   al,OutMas[si];вывод младшей цифры
           and   ax,000fh
           add   bx,ax
           mov   al,Image[bx]
           out   dx,al
           mov   al,Outmas[si] ;вывод старшей цифры
           and   ax,00f0h
           shr   al,4
           mov   bx,ax
           mov   al,Image[bx]
           inc   dx
           out   dx,al
           ret
Indication endp

TimeSW     proc
           test  Regim,10b
           jz    met
           test  StartR,1
           jnz   met
          
           mov   al,TimeSwitch
           inc   al
           mov   TimeSwitch,al
           test  al,1
           jz    mt
           mov   dx,word ptr OutMas[5]
           mov   word ptr OutMas[3],dx
           mov   si,3
           mov   dx,4
           call  Indication
           mov   si,4
           mov   dx,6
           call  Indication  
           jmp   met
     mt:   mov   ax,0
           mov   word ptr OutMas[3],ax
           out   4,al
           out   5,al
           out   6,al
           out   7,al
    
      met: in    al,0
           test  al,10000000b
           jnz   met   
           
  TSWend:  ret
TimeSW     endp 

BotUp2     proc
           test  regim,1
           jz    BU2end
           mov   si,6
           mov   al,OutMas[si]
           inc   al
           daa
           mov   OutMas[si],al
           mov   dx,6
           ;вывод на индикаторы
           call  Indication
           
   BU2end: in    al,1
           test  al,1b
           jnz   BU2End
           
           ret
BotUp2     endp

BotDown2   proc
           test  regim,1
           jz    Bd2end
           mov   si,6
           mov   al,OutMas[si]
           dec   al
           das
           mov   OutMas[si],al
           mov   dx,6
           ;вывод на индикаторы
           call  Indication
           
   BD2End: in    al,1
           test  al,10b
           jnz   BD2End
           ret
BotDown2   endp 

Input      proc
           cmp   regim,100001b
           jnz    regObEz
           ;режим программирования
           
           mov   al,DigMas[1]
           cmp   digMas[2],al
           jae    regobEz
           
           mov   al,outdiod
           test  al,0ffh
           jz    NoIn
           
           add   al,80h

  NoIn:    xor   bh,bh
           mov   bl,DigMas[2]
           mov   VoprMas[bx],al ;запись в ячейку пам.
           mov   al,OutMas[2]
           inc   al
           daa
           mov   Outmas[2],al 
           
           inc   bl
           cmp   bl,DigMas[1] ;64h
           jb    NoZero
           mov   bx,0
           mov   OutMas[2],0
   NoZero: mov   digmas[2],bl
           ;индикация
           mov   al,VoprMas[bx]          
           mov   outdiod,al
           out   1,al
           mov   si,2
           mov   dx,2
           call  Indication
           jmp   mIn
 
           ;режим Экзамена, обучения
  regObEz: test  regim,110b
           jz    mIn
           test  TimeSwitch,1b
           jz    regOb
           test  StartR,1
           jnz   regOb
           jmp   mIn
    regOb: 
           cmp   testEnd,1
           jz   mIn 
                     
           mov   bl,DigMas[2]
           xor   bh,bh
           mov   al,VoprMas[bx]
           and   al,07fh
           test  al,outdiod
           jz    ZagrVopr;mIn ;
           
           mov   al,outmas[7]
           inc   al
           daa
           mov   outmas[7],al
           
 ZagrVopr: ;загрузка следующего вопроса
           mov   ax,word ptr DigMas[3]
           and   ax,00ffh
           mul   NumVM
           mov   si,ax
          
           mov   bl,DigMasv
           add   bl,2        ;прибавить тип varmas
                      
           mov   dx,VarMas[si][bx]
           cmp   dx,0aaaah
           jne   NoRes         ;обработка результатов 
           call  Result
           jmp   mIn
  noRes:   mov   digmasv,bl
           mov   Digmas[2],dh
           mov   Outmas[2],dl
           
                    
     mIn:  in    al,1
           test  al,100b
           jnz   mIn
           ret
Input      endp

Result     proc
           mov   StartR,0
           mov   TestEnd,1
           
           mov   dl,outmas[7]
           and   dl,0fh
           mov   dh,outmas[7]
           shr   dh,4
           mov   al,outmas[0]
           and   al,0fh
           mov   ah,outmas[0]
           shr   ah,4
           aad
           xchg  ax,dx
           aad
           xor   ah,ah
           mov   dh,100
           mul   dh
           div   dl
           ;преобразование в ASCII
           aam
           cmp   ah,10
           jnz   No100
           mov   ah,0
    No100: ;вывод на индикаторы
           mov   bx,Offset Image
           add   bl,al
           mov   al,Image[bx]
           out   0ch,al
           mov   bx,Offset Image
           xchg  al,ah
           add   bl,al
           mov   al,Image[bx]
           out   0dh,al
           
           ret
Result     endp

Bot1       proc
           mov   al,1
           mov   outdiod,al
;           out   1,al 
           ret
Bot1       endp
Bot2       proc
           mov   al,2
           mov   outdiod,al
;           out   1,al
           ret
Bot2       endp
Bot3       proc
           mov   al,4
           mov   outdiod,al
;           out   1,al
           ret
Bot3       endp
Bot4       proc
           mov   al,8
           mov   outdiod,al      
;           out   1,al
           ret
Bot4       endp
Bot5       proc
           mov   al,10h
           mov   outdiod,al
;           out   1,al
           ret
Bot5       endp

InputVop   proc
           cmp   regim,00100001b
           jnz   IV3
           
           xor   ah,ah
           mov   al,DigMas[3]
           mul   NumVM 
           mov   bx,ax    
           mov   si,word ptr DigMasV
           and   si,0ffh
           
           mov   al,OutMas[2]
           mov   ah,DigMas[2]
           mov   VarMas[bx][si],ax
           
           add   digmasV,2
           
           xor   ah,ah
           mov   al,DigMas[0]
           mul   typeVM
           cmp   DigmasV,al
           jne   IV3
           mov   al,OutMas[9]
           inc   al
           daa
           mov   OutMas[9],al
           inc   DigMas[3]
           cmp   digMas[3],064h
           jnz   IV33
           mov   DigMas[3],0
    IV33:  mov   DigMasv,0          
           mov   VarMas[bx][si+2],0aaaah
 IV3:      in    al,2
           test  al,1
           jnz    IV3
           
           mov   si,9
           mov   dx,0eh
           call  indication
           ret
InputVop   endp

BotUp3     proc
           test  StartR,1b
           jnz   BU3
           
           mov   al,OutMas[9]
           inc   al
           daa
           mov   OutMas[9],al
           inc   DigMas[3]
           cmp   DigMas[3],064h
           jnz   BU33
           mov   DigMas[3],0
   BU33:    
           mov   al,DigMas[3]
           xor   ah,ah
           mul   NumVm
           mov   bx,ax
           cmp   VarMas[bx][0],0aaaah
           jnz   NoPusto
           mov   al,0
           out   2,al
           out   3,al
  NoPusto: mov   dx,VarMas[bx][0]
           mov   OutMas[2],dl
           mov   DigMas[2],dh
           
           call  Outing
               
    BU3:   in    al,2
           test  al,10b
           jnz    BU3
           
           ret
BotUp3     endp

BotDown3   proc
           test  StartR,1
           jnz   BD3

           mov   al,OutMas[9]
           dec   al
           das
           mov   OutMas[9],al
           dec   DigMas[3]
           cmp   DigMas[3],0ffh
           jnz   Bd33
           mov   DigMas[3],063h
           
 BD33:     mov   al,DigMas[3]
           xor   ah,ah
           mul   NumVm
           mov   bx,ax
           cmp   VarMas[bx][0],0aaaah
           jnz   NoPustod
           mov   al,0
           out   2,al
           out   3,al
 NoPustod: mov   dx,VarMas[bx][0]
           mov   OutMas[2],dl
           mov   DigMas[2],dh
   BD3:    
           call  Outing 
              
           in    al,2
           test  al,100b
           jnz    BD3
           
           ret
BotDown3   endp

Reset      proc
                      
           mov   al,0
           mov   outdiod,al
           out   1,al
           
 R3:       in    al,2
           test  al,1000b
           jnz    R3
           ret
Reset      endp

Timer      proc
           test  timeswitch,1
           jz    mTime
           test  StartR,1
           jz    mTime
           
           inc   time
           cmp   time,0dffh
           jnz   mtimeq
           
           mov   time,0
           mov   al,Outmas[3]
           dec   al
           das
           mov   outmas[3],al
           
           cmp   outmas[3],099h
           jnz   time1
           mov   outmas[3],59h
           mov   al,Outmas[4]
           dec   al
           das
           mov   outmas[4],al
    time1:       
           mov   si,3
           mov   dx,4
           call  indication
           
           mov   si,4
           mov   dx,6
           call  indication  
  mTimeq:  cmp   outmas[4],0
           jnz   mtime
           cmp   outmas[3],0
           jnz   mtime
           mov   timeswitch,0
           ;по окончанию времени выдача результата
           call  result
           
    mtime: 
                
           ret
Timer      endp
Outing     proc

           xor   ah,ah
           mov   al,regim
           shr   al,4
           
    Oi1:   mov   si,ax
           mov   dx,2
           call  Indication

           mov   si,7
           mov   dx,0ah
           call  Indication
           
           mov   al,outdiod
           out   1,al
           
           mov   si,9
           mov   dx,0eh
           call  Indication
         
           ret
Outing     endp 

Drebezg0   proc
VD01:      mov   cx,50
           mov   ah,al
VD02:      in    al,0
           cmp   ah,al
           jne   VD02
           loop  VD01  
           ret
drebezg0   endp
       
Inicializ  proc
           ;инициализация массива вопросов
           mov   cx,100
           mov   bx,0
   InVMas: mov   VoprMas[bx],0h
           inc   bx
           loop  InVMas
           
           ;инициализация массива вариантов
           mov   cx,100
           mov   bx,0
           mov   dx,101
  InVar:   mov   ax,cx
           mov   si,0
           mov   cx,dx
  InVVar:  mov   VarMas[bx][si],0aaaah
           add   si,2        
           loop  InVVar
           add   bx,100
           mov   cx,ax
           loop  InVar
         
           mov   regim,00100000b  
           mov   OutMas[0],0100b ;NumVopr
           mov   DigMas[0],04h
           mov   OutMas[1],00101b
           mov   DigMas[1],5h
           mov   OutMas[2],000100b
           mov   DigMas[2],04h 
           
           mov   TimeSwitch,0
           mov   Time,0
           mov   word ptr OutMas[3],2000h  ;Time     
           mov   word ptr OutMas[5],2000h 
           mov   OutMas[7],0h              ;prav otvet     
           mov   OutMas[8],0h              ;otcenka      
           mov   OutMas[9],0               ;variant 
           mov   DigMas[3],0
           mov   digmasv,0
           
           mov   Outdiod,0
           
           mov   VoprMas[0],10000001b
           mov   VoprMas[1],10000010b
           mov   VoprMas[2],10000100b
           mov   VoprMas[3],10001000b
           mov   VoprMas[4],10010000b
           
           mov   varMas[0][0],0404h
           mov   varMas[0][2],0202h
           mov   varMas[0][4],0101h
           mov   varMas[0][6],0404h
           mov   varMas[0][8],0aaaah
;           mov   varmas[0][000ah],0fh
           
           call  OutIni
           mov   StartR,0  
           mov   TestEnd,0         
     ;      mov   al,regim
     ;      out   0,al        

           ret                
Inicializ  endp
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
