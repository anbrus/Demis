.386
;Задайте объём ПЗУ в байтах
RomSize          EQU   4096
KbdOutPort       EQU   0
KbdInPort        EQU   0
InPortControl    EQU   3
PricePortArr     EQU   4
WeightPortArr    EQU   9
CostPortArr      EQU   0Eh      
ADCPortOut       EQU   14h
ADCPortData1     EQU   15h
ADCPortData2     EQU   16h
ADCPortIn        EQU   17h      
BufPort          EQU   30h
MaxDreb          EQU   50
MaxWeight        EQU   2710h

IntTable   SEGMENT AT 0 use16
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT AT 40h use16
;Здесь размещаются описания переменных
BaseW      dw    ?
RealADC    dw    ?
PriceArr   db    5           dup(?)
WeightArr  db    5           dup(?)
CostArr    db    11          dup(?)
SumArr     db    8           dup(?)
KbdImage   db    4           dup(?)
CurDigit   db    ?
Weight     dw    ?    
CurSys     db    ?
PreSum     db    ?
NullFlag   db    ?

Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 200h use16
;Задайте необходимый размер стека
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант
InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data,es:Data
Obraz      DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h
ErrorW      db    115,96,96,03fh,00Ch
ErrorK      db    115,96,96,03fh,076h
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы
;//////////////////начало
           call  Podgotovka
st1:       call  KbdInput    ;опрос клавиатуры
           call  InChislo    ;получение по образу клавиатуры введенного числа
           call  InNextPrice ;модификация цены с учетом вновь введенной цифры
           call  InADCData   ;опрос АЦП - ввод веса товара
           call  InControl   ;контрольный процесс
           call  CtrlAction  ;действие на входное слово
           call  OutData
           mov   al,NullFlag
           out   BufPort,al
           jmp   st1
;//////////////////конец
MulCost PROC NEAR                    ;//подпрограмма умножает цену на вес и получает стоимость
           pusha
           mov   al,0
           mov   CostArr[0],al
           mov   CostArr[1],al
           mov   CostArr[2],al
           mov   CostArr[3],al
           mov   CostArr[4],al
           mov   CostArr[5],al
           mov   CostArr[6],al
           mov   CostArr[7],al
           mov   CostArr[8],al
           mov   CostArr[9],al
           mov   CostArr[10],al
           mov   bx,0ffffh
        m0:inc   bx
           mov   si,0
        m1:mov   al,WeightArr[bx]
           mov   dl,PriceArr[si]
           mul   dl
           aam
           add   si,bx
           add   CostArr[si],al
           adc   CostArr[si+1],ah
           xor   ah,ah
           adc   CostArr[si+2],ah
           adc   CostArr[si+3],ah
           adc   CostArr[si+4],ah
           sub   si,bx
           ;/////////////////коррекция
           push  si bx
           mov   si,0
        m7:mov   al,CostArr[si]
           aam
           mov   CostArr[si],al
           add   CostArr[si+1],ah
           mov   bx,si
        m6:inc   bx
           xor   ah,ah
           adc   CostArr[bx],ah
           cmp   bx,10
           jne   m6
           inc   si
           cmp   si,10
           jne   m7
           pop   bx si
           ;////////////////
           inc   si
           cmp   si,5
           jne   m1
           cmp   bx,4
           jne   m0
           mov   al,11110111b
           and   CurSys,al
           mov   al,Cursys
           and   al,100b  
           jz    m3
           call  SumSum
        m3:popa
           ret
MulCost ENDP

SumSum PROC NEAR                 ;//подпрограмма суммирующая выручку
           pusha
           ;суммирование
           mov   al,CostArr[3]
           add   SumArr[0],al
           mov   al,CostArr[4]
           adc   SumArr[1],al
           mov   al,CostArr[5]
           adc   SumArr[2],al
           mov   al,CostArr[6]
           adc   SumArr[3],al
           mov   al,CostArr[7]
           adc   SumArr[4],al        
           mov   al,CostArr[8]
          adc   SumArr[5],al                                     
           mov   al,CostArr[9]
           adc   SumArr[6],al 
           mov   al,CostArr[10]
           adc   SumArr[7],al          
           ;/////////////////коррекция
           mov   si,0
        m8:mov   al,SumArr[si]
           aam
           mov   SumArr[si],al
           add   SumArr[si+1],ah
           mov   bx,si
        m9:inc   bx
           xor   ah,ah
           adc   SumArr[bx],ah
           cmp   bx,8
           jne   m9
           inc   si
           cmp   si,8
           jne   m8
           ;////////////////
           and   CurSys,11111011b
           popa
           ret
SumSum ENDP

DrebEzg    PROC  NEAR        ;//защита от дребезга, в регистре Dx храниться адрес порта, Al- значение прочитанное из порта
       md1:mov   ah,al
           mov   bh,0
       md2:in    al,dx
           cmp   ah,al
           jne   md1
           inc   bh
           cmp   bh,MaxDreb
           jne   md2
           mov   al,ah
           ret
DrebEzg    ENDP

KbdInput   PROC  NEAR           
           mov   dx,KbdOutPort  
           lea   si,KbdImage
           mov   bl,1
       mp8:mov   al,bl
           out   dx,al
           in    al,dx
           cmp   al,0
           je    mp3
           call  dreBezg
           mov   [si],al
       mp2:in    al,dx
           cmp   al,0
           jne   mp2
           jmp   mp4
       mp3:mov   [si],al
       mp4:inc   si
           shl   bl,1
           cmp   bl,8
           jne   mp8
           ret
KbdInput   ENDP

InChislo   PROC  NEAR        ;процедура вычисления числа по образу клавиатуры
           mov   si,0
           mov   cx,0ffh
           xor   ch,ch
           xor   dx,dx
      mch0:mov   ah,KbdImage[si]
           shl   ah,4
           xor   al,al
           or    dx,ax
           shr   dx,4
           inc   si
           cmp   si,3
           jne   mch0
           cmp   dx,0
           je    mch4
       mch3:inc   cl         ;считаем введенное значение                
           shr   dx,1
           jnc    mch2
           inc   ch          
       mch2:cmp   dx,0
           jne   mch3
           ;////////////////////////////////////////////
           mov   al,10111111b
           and    CurSys,al
           cmp   ch,1        ;проверка на двойное нажатие
           ja   mch1
           mov   CurDigit,cl
           ret
      mch1:mov   al,64
           or    CurSys,al
      mch4:ret
InChislo   ENDP

InADCData  PROC  NEAR
           mov   al,0
           mov   WeightArr[0],al
           mov   WeightArr[1],al
           mov   WeightArr[2],al
           mov   WeightArr[3],al
           mov   WeightArr[4],al
           out   ADCPortOut,al
           mov   al,1
           out   ADCPortOut,al
WaitRdy:   in    al,ADCPortIn        ;Ждём единичку на вы   ходе Rdy АЦП - признак; завершения преобразования
           cmp   al,1
           jne   WaitRdy
           in    al,ADCPortData2        ;Считываем из АЦП данные
           mov   ah,al
           in    al,ADCPortData1        ;В АХ находится считанное с АЦП слово
           
           mov   RealADC,ax              ;Сохраняем текущее состояние АЦП
           cmp   ax,BaseW                ;Сравниваем с 0
           jb    ma2
           sub   ax,BaseW
           mov   Weight,ax   ;//сохраняем прочитанное значение преобразуем в формат удобный для вывода
           ;///////////////////
           xor   cx,cx
           mov   si,0
           mov   cl,10
       ma0:xor   dx,dx      
           div   cx
           mov   WeightArr[si],dl
           inc   si
           cmp   ax,0
           jne   ma0
           ;///////////////////
           mov   al,11011111b
           and   CurSys,al
           mov   ax,Weight
           cmp   ax,MaxWeight            ;проверка перевеса
           jbe   ma4
           mov   al,00100000b
           or    CurSys,al
       ma4:ret
       ma2:mov   ax,0
           mov   Weight,0
           ret
InADCData  ENDP

InControl  PROC NEAR
           in    al,InPortControl
           cmp   al,0
           je    mcn1
           mov   dx,InPortControl
           call  dreBezg    
                  
           push  ax; ожидаем пока кнопки будут отжаты
      mic0:in    al,InPortControl
           and   al,11111011b
           cmp   al,0
           jne   mic0
           in    al,InPortControl
           mov   dx,InPortControl
           call  dreBezg
           pop   ax   
           and   al,00001111b
           mov   dl,CurSys
           and   dl,11110000b
           or    dl,al
           mov   CurSys,dl
           ;///////////////////////////////////реализация программного переключателя отслеживающего состояние кнопки счет выручки
           
           mov   al,CurSys   ;состояние в текущий момент
           and   al,00000100b
           mov   dl,PreSum   ;состояние в предыдущий момент
           and   dl,00000100b
           cmp   al,0
           jne   mcn3
           cmp   dl,0
           je    mcn3
           and   CurSys,11101011b   ; не производить счет
           or    CurSys,00010000b    ;производить вывод
           mov   al,CurSys
           mov   PreSum,al
           mov   al,03fh
           out   0,al
           ret
              
      mcn3:mov   al,CurSys   ;состояние в текущий момент
           and   al,00000100b
           mov   dl,PreSum   ;состояние в предыдущий момент
           and   dl,00000100b
           cmp   al,0
           je    mcn4
           cmp   dl,0
           jne   mcn4
           and   CurSys,11101011b   ;не производить вывод
           or    CurSys,00000100b    ;производить счет
           mov   al,CurSys
           mov   PreSum,al
           mov   al,0
           out   0,al
      mcn4:mov   al,CurSys
           mov   PreSum,al
           ret
      mcn1:and  CurSys,11110000b
           and   PreSum,11110000b
           ret
InControl  ENDP

OutPrice   PROC  NEAR        ;//вывод на индикаторы цены товара
           pusha
           lea   si,Obraz
           mov   bl,5
           xor   bh,bh
           mov   dx,PricePortArr
       mp0:dec   bl
           mov   cl,PriceArr[bx]
           mov   bp,cx
           mov   al,cs:[si+bp]
           cmp   bl,2
           jne   mp1
           or    al,10000000b
       mp1:out   dx,al
           inc   dx
           cmp   bl,0
           jne   mp0
           popa
           ret
OutPrice   ENDP

OutWeight  PROC  NEAR        ;//вывод на индикаторы цены товара
           pusha
           lea   si,Obraz
           mov   bl,5
           xor   bh,bh
           mov   dx,WeightPortArr
       mw0:dec   bl
           mov   cl,WeightArr[bx]
           mov   bp,cx
           mov   al,cs:[si+bp]
           cmp   bl,3
           jne   mw1
           or    al,10000000b
       mw1:out   dx,al
           inc   dx
           cmp   bl,0
           jne   mw0
           popa
           ret
OutWeight  ENDP

OutCost  PROC  NEAR        ;//вывод на индикаторы цены товара
           pusha
           lea   si,Obraz
           mov   bl,6
           xor   bh,bh
           mov   dx,CostPortArr
       mc0:dec   bl
           mov   cl,CostArr[bx+3]
           mov   bp,cx
           mov   al,cs:[si+bp]
           cmp   bl,2
           jne   mc1
           or    al,10000000b
       mc1:out   dx,al
           inc   dx
           cmp   bl,0
           jne   mc0
           popa
           ret
OutCost  ENDP

Podgotovka PROC  NEAR        ;//подготовка инициализация переменных
           pusha
           mov   ax,0
           mov   BaseW,ax
           mov   RealADC,ax
           mov   ax,0
           mov   PriceArr[0],al
           mov   PriceArr[1],al
           mov   PriceArr[2],al
           mov   PriceArr[3],al
           mov   PriceArr[4],al
           mov   WeightArr[0],al
           mov   WeightArr[1],al
           mov   WeightArr[2],al
           mov   WeightArr[3],al
           mov   WeightArr[4],al
           mov   KbdImage[0],al
           mov   KbdImage[1],al
           mov   KbdImage[2],al
           mov   KbdImage[3],al   
           mov   SumArr[0],al                              
           mov   SumArr[1],al                              
           mov   SumArr[2],al                              
           mov   SumArr[3],al                              
           mov   SumArr[4],al                                                    
           mov   SumArr[5],al                                                    
           mov   SumArr[6],al                                                    
           mov   SumArr[7],al                                                    
           mov   CostArr[0],al
           mov   CostArr[1],al
           mov   CostArr[2],al
           mov   CostArr[3],al
           mov   CostArr[4],al
           mov   CostArr[5],al
           mov   CostArr[6],al
           mov   CostArr[7],al
           mov   CostArr[8],al
           mov   CostArr[9],al
           mov   CostArr[10],al
           mov   CurSys,0
           mov   PreSum,0
           mov   NullFlag,0
           mov   al,0ffh
           mov   CurDigit,al
           popa
           ret
Podgotovka ENDP

SdvigPrice PROC NEAR
         mov     si,4
     mn0:dec     si
         mov     al,PriceArr[si]
         mov     PriceArr[si+1],al
         cmp     si,0
         jne     mn0
         mov     al,CurDigit
         mov     PriceArr[0],al
         ret
SdvigPrice ENDP

InNextPrice    PROC  NEAR    ;//организация бегущей строки для индикаторов цена
         cmp   CurDigit,0ffh
         je    mn1
         mov     cl,CurDigit
         cmp     cl,10
         jb      mn2
         mov     al,0
         mov     CurDigit,al
         cmp     cl,10
         je      mn3
         call    SdvigPrice            
     mn3:call    SdvigPrice            
     mn2:call    SdvigPrice            
         mov   al,0ffh
         mov   CurDigit,al
       mn1:ret
InNextPrice    ENDP

CtrlAction PROC  NEAR
           mov   dl,CurSys
           mov   al,dl
           and   al,1
           jz    mct0
           call  SetPrice
       mct0:mov   al,dl
           and   al,10b  
           jz    mct1
           call  SetWeight
       mct1:mov   al,dl
           and   al,1000b  
           jz    mct2
           call  MulCost
       mct2:mov   al,dl
 ;          and   al,100b  
  ;         jz    mct3
   ;        call  SumSum
      mct3: mov   al,dl
           and   al,10000b  
           jz    mct4
           call  OutSum

      mct4:mov   al,dl
           and   al,100000b  
           jz    mct5
           call  OutWeightErr
      mct5:mov   al,dl
           and   al,1000000b  
           jz    mct6
           call  OutKbdErr
      mct6:ret
CtrlAction ENDP

SetWeight  PROC NEAR
           pusha
           mov   al,0
           mov   WeightArr[0],al
           mov   WeightArr[1],al
           mov   WeightArr[2],al
           mov   WeightArr[3],al
           mov   WeightArr[4],al
           mov   al,11111101b
           and   CurSys,al
          
           mov   ax,RealADC
           mov   BaseW,ax
           mov   ax,0
           mov   Weight,ax
           mov   Weight,ax
           popa
           ret
SetWeight  ENDP

SetPrice   PROC  NEAR
           mov   al,0
           mov   PriceArr[0],al
           mov   PriceArr[1],al
           mov   PriceArr[2],al
           mov   PriceArr[3],al
           mov   PriceArr[4],al
           mov   al,11111110b
           and   CurSys,al
           ret
SetPrice   ENDP

OutSum     PROC  NEAR
           pusha 
           mov   al,0
           mov   NullFlag,al 
           mov   CostArr[0],al
           mov   CostArr[1],al
           mov   CostArr[2],al
           mov   CostArr[3],al
           mov   CostArr[4],al
           mov   CostArr[5],al
           mov   CostArr[6],al
           mov   CostArr[7],al
           mov   CostArr[8],al
           mov   CostArr[9],al
           mov   CostArr[10],al
           mov   si,0
      mst0:mov   al,SumArr[si]
           mov   CostArr[si+3],al
           inc   si
           cmp   si,6
           jne   mst0
           and   CurSys,11101011b
           mov   al,0
           mov   SumArr[0],al                              
           mov   SumArr[1],al                              
           mov   SumArr[2],al                              
           mov   SumArr[3],al                              
           mov   SumArr[4],al                                                    
           mov   SumArr[5],al                                                    
           mov   SumArr[6],al                                                    
           mov   SumArr[7],al   
           popa
           ret
OutSum     ENDP    

OutWeightErr     PROC        NEAR
           pusha
           mov   dx,PricePortArr    ;вывод на индикаторы надписи Err01-ошибка перевеса
           mov   cl,0
           lea   si,ErrorW
      mwr0:mov   al,cs:[si]
           out   dx,al
           inc   dx
           inc   si
           inc   cl
           cmp   cl,5
           jne   mwr0
           ;/////////блокируем индикаторы стоимости
           mov   dx,CostPortArr
           mov   cl,0
           mov   al,01000000b
      mwr1:out   dx,al
           inc   dx
           inc   cl
           cmp   cl,7
           jne  mwr1
           popa
           ret
OutWeightErr     ENDP

OutKbdErr  PROC  NEAR
           pusha
           mov   dx,PricePortArr
           mov   cl,0
           lea   si,ErrorK
      mkr0:mov  al,cs:[si]
           out   dx,al
           inc   dx
           inc  si
           inc  cl
           cmp   cl,5
           jne  mkr0
           ;/////////блокируем индикаторы стоимости
           mov   dx,CostPortArr
           mov   cl,0
           mov   al,01000000b
      mkr1:out   dx,al
           inc   dx
           inc  cl
           cmp   cl,7
           jne  mkr1
           popa
           ret
OutKbdErr  ENDP

OutData    PROC  NEAR
           mov   al,CurSys
           shr   al,5
           cmp   al,0
           jne   mgp0
           call  OutPrice    ;вывод цены
           call  OutWeight   ;вывод веса
           call  OutCost     ;вывод стоимости
      mgp0:ret
OutData    ENDP
           
;//////////////////подпрограммы

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
