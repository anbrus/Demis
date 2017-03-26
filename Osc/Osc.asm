;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

Reg0           EQU   0001h   ;Порт кнопок
Reg1           EQU   0002h   ;Младший порт данных АЦП
Reg2           EQU   0004h   ;Старший порт данных АЦП
IndHPort1      EQU   0008h   ;Порт для горизонтальных линий матрицы
IndVPort1      EQU   0010h   ;Порт для вертикальных линий матрицы
DispPort1      EQU   0020h   ;Порт для выбора матрицы
IndHPort       EQU   0040h   ;Порт для горизонтальных линий матрицы
IndVPort       EQU   0080h   ;Порт для вертикальных линий матрицы
DispPort       EQU   0100h   ;Порт для выбора матрицы
NumMPort3      EQU   0200h
NumMPort2      EQU   0400h
NumMPort1      EQU   0800h
NumMPort       EQU   1000h
IndHPort2      EQU   2000h   ;Порт для горизонтальных линий матрицы
IndVPort2      EQU   4000h   ;Порт для вертикальных линий матрицы
DispPort2      EQU   8000h   ;Порт для выбора матрицы

ADCStartPort   EQU   0       ;Порт запуска АЦП

DiscrPlusMask  EQU   1        ;Маска клавиши + периода дискретизации
DiscrMinusMask EQU   2        ;Маска клавиши - периода дискретизации
StorePlusMask  EQU   4        ;Маска клавиши + периода наблюдения
StoreMinusMask EQU   8        ;Маска клавиши - периода наблюдения
RecMask        EQU   16       ;Маска клавиши Rec
PlayMask       EQU   32       ;Маска клавиши Play
KbdCounterMax  EQU   5        ;Задержка перед повторной реакции на кнопки
DelayValue     EQU   2000     ;Задержка для организации периода дискретизации.
                              ;Зависит от быстродействия компьютера
RecDelayValue  EQU   30       ;Задержка записи.
                              ;Зависит от быстродействия компьютера

IntTable   SEGMENT AT 0 use16
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT AT 40h use16
;Здесь размещаются описания переменных
OscImage   dw    80 dup (?)
DiscrTime  dw    ?           ;Период дискретизации в 2-10 формате умноженный на 10
StoreTime  dw    ?           ;Период наблюдения в 2-10 формате
KbdCounter dw    ?           ;Счетчик задержки опроса кнопок
DelayCounter dw  ?           ;Счетчик задержки дискретизации
NewADCVal  db    ?           ;Новый отсчёт АЦП
OldADCVal  db    ?           ;Предыдущий отсчёт АЦП
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 80h use16
;Задайте необходимый размер стека
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

RecBuf     SEGMENT AT 100h use16
RecBuf     ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант
InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

;Образы цифр от 0 до 9
NumImage   db    03fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh

           ASSUME cs:Code,ds:Data,es:Data

;Процедура отображает текущий период дискретизации на индикаторах
ShowDiscrTime    proc near
           xor   ah,ah
           mov   al,Byte Ptr StoreTime
           lea   bx,NumImage
           add   bx,ax
           mov   dl,cs:[bx]      ;dl:=образ десятых долей секунды
           mov   al,Byte Ptr StoreTime+1
           lea   bx,NumImage
           add   bx,ax
           mov   dh,cs:[bx]      ;dh:=образ секунд
           mov   ax,dx
           or    ah,080h         ;Зажгём точечку после целых секунд
           mov   dx,NumMPort1
           out   dx,al
           mov   al,ah
           mov   dx,NumMPort
           out   dx,al

           xor   ah,ah
           mov   al,Byte Ptr DiscrTime
           lea   bx,NumImage
           add   bx,ax
           mov   dl,cs:[bx]      ;dl:=образ десятых долей секунды
           mov   al,Byte Ptr DiscrTime+1
           lea   bx,NumImage
           add   bx,ax
           mov   dh,cs:[bx]      ;dh:=образ секунд
           mov   ax,dx
           mov   dx,NumMPort2
           out   dx,al
           mov   dx,NumMPort3
           mov   al,ah
           out   dx,al
           
           ret
ShowDiscrTime    endp

;Процедура выполняет начальную инициализацию сразу после включения
Initialize proc  Near
           ;Инициализация образа
           lea   di,OscImage
           mov   cx,LENGTH OscImage
           mov   ax,080h
           rep   stosw
           
           ;Инициализация периода дискретизации
           mov   DiscrTime,0002h
           mov   StoreTime,0001h
           call  ShowDiscrTime
           
           ;Инициализируем счётчик опроса кнопок
           mov   KbdCounter,0
           ;счётчик задержки дискретизации
           mov   DelayCounter,0
           
           mov   NewADCVal,8
           mov   OldADCVal,8
           
           ret
Initialize endp

;Выводит готовый образ на матричные индикаторы
ShowOscImage     proc Near
           lea   si,OscImage     ;Указатель на текущий столбик
           mov   cx,80           ;Счётчик столбиков
           mov   bl,1            ;Счётчик столбиков внутри одной матрицы
           mov   dx,1            ;Счётчик матриц

SOIShowNextCol:
           cmp   dx,0100h
           jnc   SOIDispMatrix3
           
           ;Гасим матрицы
           xor   al,al
           push  dx
           mov   dx,DispPort
           out   dx,al
           mov   dx,DispPort1
           out   dx,al
           pop   dx
           
           ;Выводим текущий столбик
           lodsb
           out   IndHPort,al
           lodsb
           out   IndHPort1,al
  
           ;Активируем вертикальный столбик
           mov   al,bl
           out   IndVPort,al
           out   IndVPort1,al
           
           ;Активируем матрицу
           mov   ax,dx
           push  dx
           mov   dx,DispPort
           out   dx,al
           mov   dx,DispPort1
           out   dx,al
           pop   dx
           
           ;Переходим к следующему столбику
           mov   al,bl
           shl   al,1
           jnc   SOINoChangeMatrix12
           mov   al,1
           shl   dx,1
SOINoChangeMatrix12:
           mov   bl,al
           
           loop  SOIShowNextCol

SOIDispMatrix3:
           ;Гасим матрицы
           xor   al,al
           push  dx
           mov   dx,DispPort
           out   dx,al
           mov   dx,DispPort1
           out   dx,al
           mov   dx,DispPort2
           out   dx,al
           pop   dx
           
           ;Выводим текущий столбик
           lodsb
           push  dx
           mov   dx,IndHPort2
           out   dx,al
           pop   dx
  
           ;Активируем вертикальный столбик
           mov   al,bl
           push  dx
           mov   dx,IndVPort2
           out   dx,al
           pop   dx
           
           ;Активируем матрицу
           mov   ax,dx
           push  dx
           mov   dx,DispPort2
           mov   al,ah
           out   dx,al
           pop   dx
           
           ;Гасим матрицы
           xor   al,al
           push  dx
           mov   dx,DispPort2
           out   dx,al
           pop   dx

           ;Выводим текущий столбик
           lodsb
           push  dx
           mov   dx,IndHPort2
           out   dx,al
           pop   dx
  
           ;Активируем вертикальный столбик
           mov   al,bl
           push  dx
           mov   dx,IndVPort2
           out   dx,al
           pop   dx
           
           ;Активируем матрицу
           mov   ax,dx
           push  dx
           mov   dx,DispPort2
           mov   al,ah
           shl   al,1
           out   dx,al
           pop   dx

           ;Переходим к следующему столбику
           mov   al,bl
           shl   al,1
           jnc   SOINoChangeMatrix3
           mov   al,1
           shl   dx,2
SOINoChangeMatrix3:
           mov   bl,al
           
           dec   cx
           jz    SOIExitLoop
           jmp   SOIShowNextCol

SOIExitLoop:
           ;Гасим матрицы
           xor   al,al
           mov   dx,DispPort
           out   dx,al
           mov   dx,DispPort1
           out   dx,al
           mov   dx,DispPort2
           out   dx,al

           ret
ShowOscImage     endp

;Измеряет текущее значение напряжения и возвращает его в al
GetADCValue      proc near
           xor   al,al
           out   ADCStartPort,al
           mov   al,1
           out   ADCStartPort,al
           
           mov   al,NewADCVal
           mov   OldADCVal,al
           ;Можно читать данные
           in    al,Reg2
           ;Выделим старшие биты чтобы влезть в нашу матрицу
           and   al,0Fh
           mov   NewADCVal,al
           
           ret
GetADCValue      endp

;Обновляет образ осциллограммы в соответствии с новым отсчётом
UpdateOscImage   proc near
           ;Весь образ надо сдвинуть на один столбик вправо
           std
           lea   si,OscImage+SIZE OscImage-4
           mov   di,si
           add   di,2
           mov   cx,LENGTH OscImage-1
           rep   movsw
           cld
           
           ;А новое значение поместить в первый столбик
           ;Сформируем образ столбика
           mov   al,NewADCVal
           cmp   al,OldADCVal
           jz    @NewOld
           jnc   @NewBOld

           ;Новый отсчёт меньше старого
           mov   al,OldADCVal
           sub   al,NewADCVal
           mov   cl,al
           mov   bl,al
           mov   ax,8000h
           xor   ch,ch
@ShLeft:
           stc
           rcr   ax,1
           loop  @ShLeft

           mov   cl,NewADCVal
           shr   ax,cl
           jmp   @ShEnd
           
@NewBOld:
           ;Новый отсчёт >= старый
           mov   al,NewADCVal
           sub   al,OldADCVal
           mov   cl,al
           mov   ax,1
           xor   ch,ch
@ShRight:
           stc
           rcl   ax,1
           loop  @ShRight

           mov   cl,15
           sub   cl,NewADCVal
           shl   ax,cl
           jmp   @ShEnd

@NewOld:
           ;Новый отсчёт = старый
           mov   ax,8000h
           mov   cl,NewADCVal
           shr   ax,cl

@ShEnd:
           mov   [OscImage],ax
           
           ret
UpdateOscImage   endp

;Рассчитывает количество отсчётов для записи/воспроизведения сигнала
;Возвращает количество в dx:cx
;Расчёт делаем только для случая, когда период дискретизации=20 мкс
;Для других значений будем пересчитывать во время вывода на дисплей.
GetSampleCount   proc near
           mov   al,Byte Ptr StoreTime+1
           mov   ah,10
           mul   ah
           add   al,Byte Ptr StoreTime
           adc   ah,0                    ;ax=StoreTime в двоичном виде
           
           ;mov   bx,5000
           mov   bx,5
           mul   bx
           mov   cx,ax       ;dx:cx=StoreTime/20 - количество выборок для записи
           
           ret
GetSampleCount   endp

RecordSignal Proc  near
           call  GetSampleCount
           
           mov   ax,RecBuf
           mov   es,ax
           
           mov   bx,0        ;Смещение адреса текущего отсчёта в буфере
           
RSStartSampling:
           xor   al,al
           out   ADCStartPort,al
           mov   al,1
           out   ADCStartPort,al
           
           in    al,Reg2
           and   al,0Fh
           mov   es:[bx],al
           
           mov   si,RecDelayValue
RSWaitLoop1:
           mov   ax,10000
RSWaitLoop2:
           dec   ax
           jnz   RSWaitLoop2
           dec   si
           jnz   RSWaitLoop1
           
           sub   cx,1
           sbb   dx,0
           jc    RSExitProc
           
           add   bx,1
           jnc   RSStartSampling
           mov   ax,es
           add   ax,4096
           mov   es,ax
           jmp   RSStartSampling

RSExitProc:           
           mov   ax,Data
           mov   es,ax
           ret
RecordSignal endp

PlaySignal Proc  near
           sub   sp,2
           mov   bp,sp

           mov   al,Byte Ptr DiscrTime+1
           mov   ah,10
           mul   ah
           add   al,Byte Ptr DiscrTime
           adc   ah,0
           shr   ax,1
           mov   [bp],ax

           mov   ax,RecBuf
           mov   es,ax
           
           call  GetSampleCount
           mov   bx,0        ;Смещение адреса текущего отсчёта в буфере
           
PSShowNextSample:
           mov   al,NewADCVal
           mov   OldADCVal,al
           
           push  cx
           push  dx
           
           mov   cx,[bp]
           xor   ax,ax
PSIntegrateNextSample:
           add   al,es:[bx]
           adc   ah,0
           dec   cx
           jnz   PSIntegrateNextSample
           
           div   Word Ptr [bp]
           
           mov   NewADCVal,al
           push  es
           push  bx
           mov   ax,Data
           mov   es,ax
           call  UpdateOscImage
           call  ShowOscImage
           pop   bx
           pop   es
           
           pop   dx
           pop   cx
           
           sub   cx,[bp]
           sbb   dx,0
           jc    PSExitProc
           
           add   bx,[bp]
           jnc   PSShowNextSample
           mov   ax,es
           add   ax,4096
           mov   es,ax
           jmp   PSShowNextSample

PSExitProc:           
           mov   ax,Data
           mov   es,ax
           add   sp,2
           ret
PlaySignal endp

;Проверяет состояние кнопок "+" и "-" и соответствующим образом изменяет
;период дискретизации
CheckKeys  proc  near
           ;Кнопки проверяем только через некоторое время после
           ;первого нажатия
           cmp   KbdCounter,0
           jz    KbdReady
           dec   KbdCounter
           jmp   CKExitProc

KbdReady:
           in    al,Reg0
           
           ;А нажата ли кнопка?
           mov   ah,DiscrPlusMask
           or    ah,DiscrMinusMask
           or    ah,StorePlusMask
           or    ah,StoreMinusMask
           or    ah,RecMask
           or    ah,PlayMask
           and   al,ah
           jnz   CKCheckForDiscrPlus
           jmp   CKExitProc

CKCheckForDiscrPlus:
           ;Обработаем кнопку "+" периода дискретизации
           test  al,DiscrPlusMask
           jz    CKCheckForDiscrMinus ;Нажали другую кнопку
           mov   ax,DiscrTime    ;А можно ли увеличивать период дискретизации?
           cmp   ax,00200h
           jz    CKInvalidDiscrTime ;Нельзя увеличивать период дискретизации
           add   al,2
           aaa                   ;Период у нас в 2-10 формате, корректируем
           mov   DiscrTime,ax
           ;Теперь некоторое время на нажатия кнопок не реагируем
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;Обновим индикаторы
           jmp   CKExitProc

CKCheckForDiscrMinus:
           ;Обработаем кнопку "-" периода дискретизации
           test  al,DiscrMinusMask ;Нажали другую кнопку
           jz    CKCheckForStorePlus
           mov   ax,DiscrTime
           cmp   ax,00002h       ;А можно ли уменьшать период дискретизации?
           jz    CKInvalidDiscrTime
           sub   al,2
           aas                   ;Период у нас в 2-10 формате, корректируем
           mov   DiscrTime,ax
           ;Теперь некоторое время на нажатия кнопок не реагируем
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;Обновим индикаторы
           jmp   CKExitProc
           
CKInvalidDiscrTime:
           jmp   CKExitProc

CKCheckForStorePlus:
           ;Обработаем кнопку "+" периода наблюдения
           test  al,StorePlusMask
           jz    CKCheckForStoreMinus ;Нажали другую кнопку
           mov   ax,StoreTime    ;А можно ли увеличивать период дискретизации?
           cmp   ax,00100h
           jz    CKExitProc       ;Нельзя увеличивать период дискретизации
           add   al,1
           aaa                   ;Период у нас в 2-10 формате, корректируем
           mov   StoreTime,ax
           ;Теперь некоторое время на нажатия кнопок не реагируем
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;Обновим индикаторы
           jmp   CKExitProc

CKCheckForStoreMinus:
           ;Обработаем кнопку "-" периода наблюдения
           test  al,StoreMinusMask ;Нажали другую кнопку
           jz    CKCheckForRec
           mov   ax,StoreTime
           cmp   ax,00001h       ;А можно ли уменьшать период дискретизации?
           jz    CKExitProc
           sub   al,1
           aas                   ;Период у нас в 2-10 формате, корректируем
           mov   StoreTime,ax
           ;Теперь некоторое время на нажатия кнопок не реагируем
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;Обновим индикаторы
           jmp   CKExitProc

CKCheckForRec:
           ;Обработаем кнопку Rec
           test  al,RecMask ;Нажали другую кнопку
           jz    CKCheckForPlay
           call  RecordSignal

           ;Теперь некоторое время на нажатия кнопок не реагируем
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;Обновим индикаторы
           jmp   CKExitProc

CKCheckForPlay:
           ;Обработаем кнопку Play
           test  al,PlayMask ;Нажали другую кнопку
           jz    CKExitProc
           call  PlaySignal
           
           ;Теперь некоторое время на нажатия кнопок не реагируем
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;Обновим индикаторы
           jmp   CKExitProc

CKExitProc:           
           ret
CheckKeys  endp

;Процедура организует задержку для формирования периода дискретизации
DelayProc  proc  near
           mov   cx,DelayValue
DelayLoop1:
           mov   ax,100
DelayLoop2:
           dec   ax
           jnz   DelayLoop2
           loop  DelayLoop1

           ret
DelayProc  endp

Discretization proc near
           ;Пока DelayCounter<>0 новое значение с АЦП читать не будем
           ;Но образ на матрицах нужно обновлять, иначе они погаснут
           cmp   DelayCounter,0
           jnz   DDiscrEnd

           ;Установим DelayCounter в соответствие с периодом дискретизации
           mov   ax,DiscrTime
           or    ah,ah
           jz    DAH0
           add   al,10
           xor   ah,ah
DAH0:
           mov   DelayCounter,ax
           
           call  GetADCValue
           call  UpdateOscImage
           
DDiscrEnd:
           dec   DelayCounter

           ret
Discretization endp

Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы

           call  Initialize
           
MainLoop:
           call  ShowOscImage
           call  Discretization
           call  CheckKeys
           call  DelayProc
           
           jmp   MainLoop


;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
