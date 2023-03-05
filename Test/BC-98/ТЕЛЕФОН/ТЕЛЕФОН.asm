.386

RomSize    EQU   4096

NumInTrubPort = 03h
NumOutTrubPort = 0Ch

max1 = 50        ;Определяют время горения (гашения) индикатора "ЗВОНОК"
max2 = 120       ;при ожидании снятия трубки на телефоне

NMAX = 50        ;Константа подавления дребезга

KolRazr = 12     ;Разрядность номера

Data       SEGMENT AT 0000h use16
           
           Memory    DB 10 DUP (KolRazr DUP(?))    ;Память
           BlackList DB 10 DUP (KolRazr DUP(?))    ;Чёрный список 
           
           InTelephon  DB KolRazr DUP (?)      ;Текущий телефон (отображается на индикаторах)
           OutTelephon DB KolRazr DUP (?)      ;Телефон,с кот. звонят к нам
           DispData    DB KolRazr DUP (?)      ;Массив отображения   
       
           Status DB ?        ;Текущее состояние телефона
           Digit  DB ?        ;Нажатая цифра в данный момент   
           Index  DB ?        ;Номер текущей ячейки памяти или ч. списка
             
           InTrubPort  DB ?                   ;Порт кнопок трубок и звонков
           OutTrubPort DB ?                   ;Порт инд-ров "Звонок","Говорите"
                                              ;и состояний трубок
           MyTrubka DB ?                      ;Состояния трубок (FF-сняты)
           Trubka1  DB ?                      ;
           Trubka2  DB ?                      ;
           TrubkaAll DB ?                     ;   
           
           Flag   DB ?                        ;Звоним мы (FF)или нам (0)
           Zvonok DB ?                        ;Есть звонок(FF)
           TekPhone DB ?                      ;Индекс тел.,с кот. производится звонок
           Speek  DB ?                        ;Можно говорить
           Mig    DB ?                        ;Есть звонок, но трубка не снята
          
           Cx1 DB ?
           Cx2 DB ?
           Point DB ?
           
           KeyImg      DB 3 DUP (?)    ;Образ клавиатуры
           KeyErr      DB ?            ;Ошибка ввода или пустая клавиатура  
           NumKeyPress DB ?            ;Номер нажатой клавиши
           
           BLDisp  DB KolRazr DUP (?)  ;Массив отображения "0...ЧС"  
           MemDisp DB KolRazr DUP (?)  ;Массив отображения "0...0П"  
           
           Vyzov DW ?
           
           Del1  DD ?
           
Data       ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data,es:Data

FuncPrep   PROC NEAR                          ;Начальная подготовка         
         
           mov   OutTrubPort,0
           mov   Zvonok,0
           mov   Speek,0
           mov   Mig,0
           
           call  NulInTel                     ;Сброс текущего номера телефона
           
           mov   MemDisp[0],10                ;Инициализация мас. отобр.                 
           mov   si,1                         ;для памяти
     FP1:                  
           mov   MemDisp[si],13
           inc   si
           cmp   si,KolRazr
           jne   FP1
           
           mov   BLDisp[0],12                 ;Инициализация мас. отобр. 
           mov   BLDisp[1],11                 ;для чёрного списка
           mov   si,2
     FP2:                  
           mov   BLDisp[si],13
           inc   si
           cmp   si,KolRazr
           jne   FP2
           
           mov   Status,0
           mov   Point,0
           
           call  NulM&BL                     ;Инициализация ячеек памяти и ч. списка 
       
           RET
FuncPrep   ENDP

NulInTel   PROC NEAR                         ;Сброс текущего номера телефона

           mov   cx,KolRazr                 
           lea   si,InTelephon
     NextRazr:      
           mov   byte ptr [si],13
           inc   si
           loop  NextRazr           

           RET
NulInTel   ENDP           

NulM&BL    PROC NEAR                         ;Инициализация ячеек памяти 
                                             ;и чёрного списка 
           
           mov   dl,KolRazr                  ;Инициализация ячеек памяти 
           mov   dh,0
        MBL1:   
           mov   di,0
           mov   cx,KolRazr
           mov   al,dh
           mul   dl
           mov   bx,ax
        MBL2:   
           mov   Memory[bx][di],13
           inc   di
           loop  MBL2
           inc   dh
           cmp   dh,10
           je    exitMBL1
           jmp   MBL1
        exitMBL1:  
       
           mov   dl,KolRazr                  ;Инициализация чёрного списка 
           mov   dh,0
        MBL3:   
           mov   di,0
           mov   cx,KolRazr
           mov   al,dh
           mul   dl
           mov   bx,ax
        MBL4:   
           mov   BlackList[bx][di],13
           inc   di
           loop  MBL4
           inc   dh
           cmp   dh,10
           je    exitMBL2
           jmp   MBL3
       exitMBL2:                
           
           RET
NulM&BL    ENDP

Trubki     PROC NEAR                          ;Определение состояний трубок
           
           in    al,NumInTrubPort
           mov   InTrubPort,al
           and   al,01h                       ;Выделение кнопки нашей трубки
           cmp   al,0                         ;Если не снята то переход
           jz    m01 
               
           mov   MyTrubka,0FFh                ;Изменение состояния трубки
           jmp   m02
           
       m01: mov   MyTrubka,0                  ;Изменение состояния трубки
       
       m02: mov   al,InTrubPort    
           and   al,08h                       ;Выделение кнопки трубки №1
           cmp   al,0                         ;Если не снята то переход
           jz    m03
           
           mov   Trubka1,0FFh                 ;Изменение состояния трубки
           jmp   m04
                    
       m03: mov   Trubka1,0                   ;Изменение состояния трубки
           
       m04: mov   al,InTrubPort
           and   al,40h                       ;Выделение кнопки трубки №1
           cmp   al,0                         ;Если не снята то переход
           jz    m05
           
           mov   Trubka2,0FFh                 ;Изменение состояния трубки 
           jmp   m06
           
       m05: mov   Trubka2,0                   ;Изменение состояния трубки
           
       m06:
           mov   al,InTrubPort
           and   al,80h
           cmp   al,0
           jz    m07
           
           mov   TrubkaAll,0FFh
           jmp   m08
       m07: mov   TrubkaAll,0                    
           
       m08:    
           RET        
Trubki     ENDP

OutTrubStatus    PROC NEAR         ;Вывод индикации о состояниях трубок  
           
           mov   ah,OutTrubPort
           mov   al,MyTrubka
           cmp   al,0FFh
           jnz   m11
           or    ah,01h          ;Если наша трубка снята, то зажечь индикатор  
           jmp   m12
           
       m11: and   ah,0FEh        ;Если нет - погасить
       m12: mov   al,Trubka1
           cmp   al,0FFh
           jnz   m13
           or    ah,08h          ;Если трубка №1 снята, то зажечь индикатор
           jmp   m14
           
       m13: and   ah,0F7h        ;Если нет - погасить
       m14: mov   al,Trubka2
           cmp   al,0FFh
           jnz   m15
           or    ah,40h          ;Если трубка №2 снята, то зажечь индикатор
           jmp   m16
           
       m15: and   ah,0BFh        ;Если нет - погасить
       
       m16:
           mov   al,TrubkaAll
           cmp   al,0FFh
           jnz   m17
           or    ah,80h
           jmp   m18
      
       m17: and   ah,7Fh
       m18:    
           mov   al,ah          
           mov   OutTrubPort,al
           out   NumOutTrubPort,al
                   
           RET      
OutTrubStatus    ENDP

Zvonki1    PROC NEAR                 ;Проверка поступил ли звонок

           xor   cx,cx
           cmp   Zvonok,0FFh         ;Есть звонок в данный момент?
           jz    exit1               ;Если да - выход
           mov   cl,2                ;Загрузка счётчика циклов
      Next1:     
           in    al,NumInTrubPort    ;Загрузка в al состояния кнопок
           
           cmp   Cl,2                
           jnz   m31
           
           and   al,04h              ;Выделение кнопки "ЗВОНОК" телефона №1
           cmp   Trubka1,0           ;Трубка снята?
           jz    m3                  ;Если нет - переход
           jmp   m32          
       m31:    
           and   al,20h              ;Выделение кнопки "ЗВОНОК" телефона №2
           cmp   Trubka2,0           ;Трубка снята?
           jz    m3                  ;Если нет - переход
       m32:
           cmp   al,0                ;Нажата кнопка "ЗВОНОК"?
           jz    m3                  ;Если нет - переход
           
           cmp   MyTrubka,0          ;Проверка состояния трубки на нашем телефоне
           jnz   m3                  ;Если снята, то переход
           
           mov   TekPhone,cl         ;Запоминание индекса тел., с кот. звонят          
           call  WriteTel            ;Запоминание номера телефона
           call  ProvBL              ;Проверка чёрного списка
           jmp   exit1
       m3:
           loop  next1               ;Все телефоны?
       exit1:
           RET      
                               
Zvonki1    ENDP

WriteTel   PROC NEAR                     ;Запоминание номера телефона
           
           mov   di,0
           mov   cx,KolRazr
           
           cmp   TekPhone,2
           jne   WT1
           lea   bx,Tel1
           jmp   WT2
       WT1:
           lea   bx,Tel2
       WT2:
           mov   al,cs:[bx][di]
           mov   OutTelephon[di],al
           inc   di
           loop  WT2    
                          
           RET
WriteTel   ENDP

ProvBL     PROC NEAR                     ;Проверка чёрного списка

           mov   dl,KolRazr              ;Загрузка в dl разрядности номера
           mov   dh,0                    ;Загрузка номера ячейки памяти ч. списка
       PBL4:    
           mov   cl,KolRazr
           mov   ch,0                    ;Загрузка числа совпавших разрядов
           mov   di,0
           mov   al,dh                   ;Определение смещения
           mul   dl                      ;
           mov   bx,ax                   ;
       PBL2:    
           mov   al,BlackList[bx][di]
           cmp   OutTelephon[di],al
           jne   PBL1
           
           inc   ch
           cmp   ch,KolRazr              ;Все разряды совпали?
           je    exit_PBL                ;Если да - переход
           
           inc   di
           dec   cl
           cmp   cl,0                    ;Все разряды?
           jne   PBL2                    ;Если нет - переход
       PBL1:    
           inc   dh
           cmp   dh,10                   ;Все ячейки?
           je    PBL3                    ;Если да переход
           jmp   PBL4
       PBL3:
           mov   Zvonok,0FFh             ;Поступил звонок
           mov   Flag,0                  ;на наш телефон
       exit_PBL:
               
           RET
ProvBL     ENDP

OutZvStatus PROC NEAR            ;Вывод на индикаторы "Звонок","Говорите"
                  
           mov   al,OutTrubPort
           cmp   Speek,0
           jnz   m41
           
           and   al,0FBh
           jmp   m42
        m41:
           or    al,04h
        m42:
           cmp   Mig,0
           jnz   m43
           
           and   al,0FDh
           jmp   m44
        m43:
           or    al,02h
        m44:
           mov   OutTrubPort,al
           out   NumOutTrubPort,al            
         
           RET            
     
OutZvStatus ENDP

Zvonki2    PROC NEAR             ;Проверка не положили ли трубку

           cmp   Zvonok,0
           jz    exit3

           cmp   MyTrubka,0FFh   ;Положили трубку на нашем телефоне?
           jz    m5              ;Если нет, то переход
           
           cmp   Flag,0FFh       ;Мы звоним?
           je    Sbros           ;Если да - переход
                   
           cmp   Speek,0FFh      ;Ведётся разговор?
           jnz   m5              ;Если нет - переход
       Sbros:                    ;Если положили трубку, то сброс звонка 
           mov   Zvonok,0
           mov   Speek,0
           mov   Mig,0
           jmp   exit3
       m5:
           xor   cx,cx           ;Положили трубку на другом телефоне?
           mov   cl,2            ;Загрузка числа телефонов
       m51:
           cmp   cl,2
           jnz   m52
           
           mov   al,Trubka1
           jmp   m53
       m52:
           mov   al,Trubka2
       m53:
           cmp   al,0FFh         ;Снята трубка на др. телефоне?  
           jz    mm5             ;Если да - переход
;       mm6:    
           cmp   cl,TekPhone     ;Является данный телефон текущим?
           jnz   mm5             ;Нет - переход
       mm6:    
           cmp   Flag,0          ;Звонок с этого телефона или на него?
           jz    Sbros           ;Если с этого телефона - переход
           
           cmp   Speek,0         ;Ведётся разговор?
           jne   Sbros           ;Да - переход
           jmp   exit3
       mm5:
           loop  m51             ;Все телефоны?
           
           mov   al,TrubkaAll
           cmp   al,0FFh
           jz    exit3
           cmp   cl,TekPhone
           jz    mm6
;           jmp   mm6
                                    
       exit3:
           RET    

Zvonki2    ENDP

Zvonki3    PROC NEAR             ;Ожидание снятия трубки на нашем телефоне

           cmp   Zvonok,0
           jz    exit4
           
           cmp   Flag,0FFh
           je   m62
           
           cmp   MyTrubka,0FFh
           jnz    m61
        m64:    
           mov   Speek,0FFh      
           mov   Mig,0
           jmp   exit4
        m61:
           mov   Speek,0
           Call  Miganie      
           jmp   exit4
           
        m62:
           cmp   TekPhone,2
           jnz   m63
           cmp   Trubka1,0FFh
           jnz   m61       
           jmp   m64
        m63:
           cmp   TekPhone,1
           jnz   m65;exit4;m65
           cmp   Trubka2,0FFh
           jnz   m61
           jmp   m64
        m65:
           cmp   TrubkaAll,0FFh
           jnz   m61
           jmp   m64    
              
        exit4:   
           RET   
           
Zvonki3    ENDP

Miganie    PROC NEAR             ;Мигание при звонке

           cmp   Mig,0
           jnz   m7
           
           inc   Cx1
           cmp   Cx1,max1
           jnz   exit5
           
           mov   Cx1,0
           not   Mig
       m7:
           inc   Cx2
           cmp   Cx2,max2
           jnz   exit5
           
           mov   Cx2,0
           not   Mig
      exit5:
           RET         

Miganie    ENDP

KeyReadContr PROC NEAR                   ;ввод с клавиатуры и контроль

           xor   cx,cx
           lea   si,KeyImg           
           mov   cl,length KeyImg
           mov   dx,0                    ;текущий порт := 0
      nextport:     
           in    al,dx                   ;ввод состояния текущего порта
           cmp   al,0                    ;есть нажатые клавиши?
           je    KRC1                    ;если нет - переход
           
           call VibrDestr                ;гашение дребезга 
           
           mov   [si],al                 ;запоминание состояния порта
      KRC2:     
           in    al,dx                   ;ожидание отпускания клавиши
           cmp   al,0                    ;отпустили?
           jne   KRC2                    ;нет - переход
           
           call VibrDestr                ;гашение дребезга
           
           jmp   KRC3
      KRC1:     
           mov   [si],al                 ;запоминание состояния порта    
      KRC3:     
           inc   si
           inc   dx
           loop  nextport                ;все порты
           
           Lea   si,KeyImg               ;контроль ввода с клавиатуры
           mov   dl,0                    ;загрузка в dl числа нажатых клавиш
           mov   cl,length KeyImg
           mov   dh,1
      nextstr1:
           mov   ch,8
      nextbit1:
           mov   al,[si]
           and   al,dh
           cmp   al,0
           jz    m81
           
           inc   dl
      m81:
           rol   dh,1
           
           dec   ch
           cmp   ch,0
           jnz   nextbit1
           
           inc   si
           dec   cl
           cmp   cl,0                
           jnz   nextstr1
           
           cmp   dl,1                    ;если нажато более одной клавиши 
           jne   error                   ;или не нажато клавиш вообще выдать ошибку
           
           mov   KeyErr,0
           jmp   exit7
      error:
           mov   KeyErr,0FFh             ;KeyErr=FF - есть ошибка  
      exit7:     
           RET            

KeyReadContr ENDP

NumKey     PROC NEAR                 ;Определение номера нажатой клавиши
           
           cmp   KeyErr,0FFh         ;case KEY do          
           jz    exit8               ;
                                     ;"0":        NumKeyPress=1
           lea   si,KeyImg           ;"1":        NumKeyPress=2
           mov   cl,length KeyImg    ;"2":        NumKeyPress=3  
           mov   dl,1                ;"3":        NumKeyPress=4
           mov   dh,1                ;"4":        NumKeyPress=5
                                     ;"5":        NumKeyPress=9
      nextstr2:                      ;"6":        NumKeyPress=10
           mov   ch,8                ;"7":        NumKeyPress=11
      nextbit2:                      ;"8":        NumKeyPress=12
           mov   al,[si]             ;"9":        NumKeyPress=13
           and   al,dh               ;"НАБОР":    NumKeyPress=17
           cmp   al,0                ;"ПАМЯТЬ":   NumKeyPress=18
           jnz   write_num           ;"ЗАПИСЬ":   NumKeyPress=19
                                     ;"СБРОС":    NumKeyPress=20
           inc   dl                  ;"Ч.С.":     NumKeyPress=21
           rol   dh,1                ;"РЕД.":     NumKeyPress=22
           dec   ch                  ;
           cmp   ch,0                ;
           jnz   nextbit2            ;
                                     ;
           inc   si                  ;
           dec   cl                  ;
           cmp   cl,0                ;            
           jnz   nextstr2            ;    
      write_num:                     ;   
           mov   NumKeyPress,dl      ;Запоминание номера нажатой клавиши
      exit8:
           RET
NumKey     ENDP

MainProc   PROC NEAR                 ;Выполнение действий в зависимости от
                                     ;нажатой клавиши
           cmp   KeyErr,0FFh
           je    exit9
           
           cmp   NumKeyPress,14      ;Если нажата не цифра,     
           ja    m111                ;то переход
           call  DigitKey            ;запоминание нажатой цифры
           mov   al,0
           jmp   m112
      m111:
           mov   al,NumKeyPress
           sub   al,16    
      m112:
           mov   dl,5                ;Определение смещения
           mul   dl                  ;
           lea   bx,Base             ;
           add   ax,bx               ;
           jmp   ax
      Base:
           call  DigitPress          ;Вызов процедуры при нажатии цифры
           jmp   exit9          
           call  NaborPress          ;Вызов процедуры при нажатии "НАБОР"
           jmp   exit9
           call  MemPress            ;Вызов процедуры при нажатии "ПАМЯТЬ"
           jmp   exit9           
           call  EnterPress          ;Вызов процедуры при нажатии "ЗАП."
           jmp   exit9           
           call  ResetPress          ;Вызов процедуры при нажатии "СБРОС"
           jmp   exit9
           call  BLPress             ;Вызов процедуры при нажатии "Ч. СПИСОК"
           jmp   exit9           
           call  RedactPress         ;Вызов процедуры при нажатии "РЕД."
           
      exit9:                           
           RET
MainProc   ENDP

DigitKey   PROC NEAR                 ;запоминание нажатой цифры
           
           mov   al,NumKeyPress
           cmp   NumKeyPress,8
           jb    DK01
           
           sub   al,3
      DK01:
           dec   al
           mov   Digit,al     
           
           RET
DigitKey   ENDP

DigitPress PROC NEAR

           xor   ax,ax
           mov   al,Status
           mov   dl,5
           mul   dl
           lea   bx,Base2
           add   ax,bx
           jmp   ax
      Base2:
           call  ModifTel
           jmp   exit10
           call  OutMem
           jmp   exit10
           call  OutBL
           jmp   exit10
           call  OutMem
           jmp   exit10
           call  OutBL
           jmp   exit10
           call  ModifTel
           jmp   exit10
           call  ModifTel
           jmp   exit10
           nop                                                                       
      exit10:
           RET
DigitPress ENDP

ModifTel   PROC NEAR
           
           xor   ax,ax
           mov   al,Point
           mov   si,ax
       next_MT:    
           cmp   si,0
           jne   MT1
           
           mov   al,Digit
           jmp   MT2
       MT1:
           mov   al,InTelephon[si-1]
       MT2:
           mov   InTelephon[si],al
           cmp   si,0
           je    exit1_MT
           
           dec   si
           jmp   next_MT  
       exit1_MT:
           cmp   Point,KolRazr-1
           je    exit2_MT
           inc   Point
       exit2_MT:              

           RET
ModifTel   ENDP

OutMem     Proc NEAR

           mov   cx,KolRazr
           mov   di,0
           mov   al,Digit
           mov   dl,KolRazr
           mul   dl
           mov   bx,ax
      OM01:
           mov   al,Memory[bx][di]
           mov   InTelephon[di],al
           inc   di
           loop  OM01
           mov   Status,3
           mov   al,Digit
           mov   Index,al
                
           RET
OutMem     ENDP

OutBL      PROC NEAR

           mov   cx,KolRazr
           mov   di,0
           mov   al,Digit
           mov   dl,KolRazr
           mul   dl
           mov   bx,ax
      OBL1:
           mov   al,BlackList[bx][di]
           mov   InTelephon[di],al
           inc   di
           loop  OBL1
           mov   Status,4
           mov   al,Digit
           mov   Index,al
                
           RET
OutBL      ENDP

NaborPress PROC NEAR
           
           cmp   Status,0
           je    NP_01
           cmp   Status,3
           jne   exit_NP
      NP_01:    
           cmp   Zvonok,0FFh
           je    exit_NP
           
           cmp   MyTrubka,0
           je    exit_NP
           
           call  SigVyz
           
           mov   dl,2
      NP_4:     
           mov   ch,0
           mov   cl,KolRazr
           mov   di,0
      NP_3:     
           cmp   dl,2
           jne   NP_1
           
           lea   bx,Tel1
           mov   al,cs:[bx][di]
           jmp   NP_5
      NP_1:
           lea   bx,Tel2
           mov   al,cs:[bx][di]
      NP_5:
           cmp   InTelephon[di],al
           jne   NP_2
           
           inc   ch
           cmp   ch,KolRazr
           je    break_NP
      
           inc   di
           dec   cl
           cmp   cl,0
           jne   NP_3     
      NP_2:     
           dec   dl
           cmp   dl,0
           je    all_NP  ;exit_NP
           jmp   NP_4
           
      all_NP:
           cmp   TrubkaAll,0FFh
           je    exit_NP
           jmp   exit_NPno  
              
      break_NP:
           call  Nabor2
     
                        
      exit_NP:         
           RET
NaborPress ENDP                      

Nabor2     PROC  NEAR

           cmp   dl,2
           jne   mNP_1
           cmp   Trubka1,0FFh
           je    exit_NP2
           jmp   exit_NPno              
      mNP_1:
           cmp   Trubka2,0FFh
           je    exit_NP2
           jmp   exit_NPno 
      exit_NPno:
           mov   Zvonok,0FFh
           mov   TekPhone,dl
           mov   Flag,0FFh  
           jmp   exit_NP2 
      exit_NP2:      
           RET
Nabor2     ENDP    


MemPress   PROC NEAR

           cmp   Status,0
           je    MP02
           cmp   Status,2
           je    MP02
           cmp   Status,3
           je    MP02
           jmp   MP01
      MP02:     
           mov   Status,1
      MP01:     

           RET
MemPress   ENDP

EnterPress PROC NEAR

           cmp   Status,6
           jne   EP1
           mov   ch,2
           jmp   EP2
      EP1:
           cmp   Status,5
           jne   EP3
           mov   ch,1
           jmp   EP2
      EP3:
           jmp   exit_EP
      EP2:
           mov   cl,KolRazr
           mov   di,0
           mov   al,Index
           mov   dl,KolRazr
           mul   dl
           mov   bx,ax
      EP6:     
           mov   al,InTelephon[di]
           cmp   Status,5
           jne   EP4               
           mov   Memory[bx][di],al
           jmp   EP5
      EP4:
           mov   BlackList[bx][di],al
      EP5:
           inc   di
           dec   cl
           cmp   cl,0
           jne   EP6                    
           mov   Status,ch 
      exit_EP: 
   
           RET
EnterPress ENDP     

ResetPress PROC NEAR

           mov   Status,0
           mov   Point,0
     
           call  NulInTel                 ;InTelephon:=00...0
           
           RET
ResetPress ENDP

BLPress    PROC NEAR
           
           cmp   Status,0
           je    BL02
           cmp   Status,1
           je    BL02
           cmp   Status,4
           je    BL02
           jmp   BL01
       BL02:    
           mov   Status,2
       BL01:   
                    
           RET
BLPress    ENDP
 
RedactPress PROC NEAR

           cmp   Status,4
           je    RP1
           cmp   Status,3
           je    RP2
           jmp   exit_RP
       RP1:
           mov   Status,6
           mov   Point,0
           call  NulInTel
           jmp   exit_RP
       RP2:
           mov   Status,5
           mov   Point,0
           call  NulInTel        
       exit_RP:    

           RET
RedactPress ENDP               

DispForm   PROC NEAR

           Lea   di,DispData
           mov   cx,KolRazr
           
           cmp   Status,2
           jne   m101
           lea   si,BLDisp
           jmp   m103
       m101:
           cmp   Status,1
           jne   m102
           lea   si,MemDisp
           jmp   m103
       m102:
           lea   si,InTelephon
       m103:
           mov   al,[si]
           mov   [di],al
           inc   si
           inc   di
           loop  m103            

           RET
DispForm   ENDP

OutInf     PROC NEAR


           lea   di,DispData
           Lea   bx,XlatTabl
           mov   cx,KolRazr
           mov   dx,0
           
           mov   ax,cs
           mov   ds,ax
       OI1:    
           mov   al,es:[di]
           xlat
           out   dx,al
           inc   di
           inc   dx
           loop  OI1
           
           mov   ax,es
           mov   ds,ax
           
           RET
OutInf     ENDP

OutStatus  PROC NEAR

           mov   al,OutTrubPort
           cmp   Status,1
           je    _OS_M1
           cmp   Status,3
           je    _OS_M1
           cmp   Status,5
           je    _OS_M1
           jmp   _OS_1
      _OS_M1:
           or    al,020h
           jmp   _OS_2
      _OS_1:
           and   al,0DFh
      _OS_2:
           cmp   Status,2
           je    _OS_BL1
           cmp   Status,4
           je    _OS_BL1
           cmp   Status,6
           je    _OS_BL1
           jmp   _OS_3
      _OS_BL1:
           or    al,010h
           jmp   _OS_4
      _OS_3:
           and   al,0EFh
      _OS_4:  
           mov   OutTrubPort,al
;           out   NumOutTrubPort,al                           
           RET
OutStatus  ENDP

VibrDestr  PROC NEAR

      VD1:
           mov   ah,al
           mov   bh,0
      VD2:
           in    al,dx
           cmp   ah,al
           jne   VD1
           inc   bh
           cmp   bh,NMAX
           jne   VD2
           mov   al,ah
    
           RET
VibrDestr  ENDP

SigVyz     PROC NEAR
           
           
           mov   si,KolRazr
      SV2:  
           mov   Vyzov,0   
           mov   cl,InTelephon[si-1]
           cmp   cl,13
           je    next_SV
           
           inc   cl
           mov   dx,1
      SV1:     
           or    Vyzov,dx
           shl   dx,1
           dec   cl
           cmp   cl,0
           jne   SV1
           
           mov   al,byte ptr Vyzov
           out   0Dh,al
           mov   al,byte ptr Vyzov+1
           out   0Eh,al
           
           call  Delay
           
      next_SV:
                
           dec   si
           cmp   si,0
           jne   SV2
           
           mov   Vyzov,0
           mov   al,byte ptr Vyzov
           out   0Dh,al
           mov   al,byte ptr Vyzov+1
           out   0Eh,al   
           
           RET
SigVyz     ENDP

Delay      PROC NEAR
           
           mov   word ptr del1,0FFFFh
           mov   word ptr del1,0FFFFh
       mD:    
           mov   ax,word ptr del1
           sub   ax,1
           mov   word ptr del1,ax
           mov   ax,word ptr del1+2
           sbb   ax,0
           mov   word ptr del1+2,ax
           
           cmp   word ptr del1,0
           jne   mD
           cmp   word ptr del1,0
           jne   mD

           RET
Delay      ENDP

XlatTabl   DB  03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh,0AFh,0CDh,0B3h,0
Tel1       DB  3,7,2,1,5,5,6 DUP (13)
Tel2       DB  1,2,3,5,4,2,6 DUP (13)
   
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
                   
;Здесь размещается код программы
           Call  FuncPrep
      n:  
           Call  Trubki
           Call  OutTrubStatus
           
           Call  Zvonki1
           Call  Zvonki2
           Call  Zvonki3
           Call  OutZvStatus
           
           Call  KeyReadContr
           Call  NumKey
           Call  MainProc
           
           Call  DispForm
           Call  OutInf
           Call  OutStatus
           jmp   n
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
