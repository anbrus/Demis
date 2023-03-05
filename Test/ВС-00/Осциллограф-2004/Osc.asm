;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

HorLinePort   EQU   0        ;16-ти битный порт для горизонтальных линий матрицы
MatrSelPort   EQU   2        ;8-ти битный порт для выбора матрицы
VertLinePort  EQU   4        ;8-ми битный порт для вертикальных линий матрицы
ADCStartPort  EQU   5        ;Порт управления запуском АЦП
ADCStatePort  EQU   1        ;Порт состояния АЦП
ADCValuePort  EQU   0        ;Порт данных АЦП
KeyPort       EQU   2        ;Порт кнопок
IndicPort     EQU   7        ;Порт индикаторов
PlusMask      EQU   1        ;Маска клавиши +
MinusMask     EQU   2        ;Маска клавиши -
KbdCounterMax EQU   10       ;Задержка перед повторной реакции на кнопки
DelayValue    EQU   50     ;Задержка для организации периода дискретизации (2000).
                             ;Зависит от быстродействия компьютера

IntTable   SEGMENT AT 0 use16
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT AT 40h use16
;Здесь размещаются описания переменных
OscImage   dw    80 dup (?)
DiscrTime  dw    ?           ;Период дискретизации в 2-10 формате
KbdCounter dw    ?           ;Счетчик задержки опроса кнопок
DelayCounter dw  ?           ;Счетчик задержки дискретизации
NewADCVal  db  ?             ;Новый отсчёт АЦП
OldADCVal  db  ?             ;Предыдущий отсчёт АЦП
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 80h use16
;Задайте необходимый размер стека
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

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
           mov   al,Byte Ptr DiscrTime
           lea   bx,NumImage
           add   bx,ax
           mov   dl,cs:[bx]      ;dl:=образ десятых долей секунды
           mov   al,Byte Ptr DiscrTime+1
           lea   bx,NumImage
           add   bx,ax
           mov   dh,cs:[bx]      ;dh:=образ целых секунд
           mov   ax,dx
           or    ah,080h         ;Зажгём точечку после целых секунд
           out   IndicPort,ax
           
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
           mov   DiscrTime,0001h
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

ShowNextCol:
           ;Гасим матрицы
           xor   ax,ax
           out   MatrSelPort,ax
           
           ;Выводим текущий столбик
           lodsw
           out   HorLinePort,ax
           
           ;Активируем вертикальный столбик
           mov   al,bl
           out   VertLinePort,al
           
           ;Активируем матрицу
           mov   ax,dx
           out   MatrSelPort,ax
           
           ;Переходим к следующему столбику
           mov   al,bl
           shl   al,1
           jnc   NoChangeMatrix
           mov   al,1
           shl   dx,1
NoChangeMatrix:
           mov   bl,al
           
           loop  ShowNextCol

           ;Гасим матрицы
           xor   ax,ax
           out   MatrSelPort,ax

           ret
ShowOscImage     endp

;Измеряет текущее значение напряжения и возвращает его в al
GetADCValue      proc near
           ;Запустили измерение
           mov   al,1
           out   ADCStartPort,al
           xor   al,al
           out   ADCStartPort,al
           
           ;Подождём, пока АЦП подумает
ADCReady:
           in    al,ADCStatePort
           and   al,1
           jz    ADCReady
           
           mov   al,NewADCVal
           mov   OldADCVal,al
           ;Можно читать данные
           in    al,ADCValuePort
           ;Поделим на 16, чтобы влезть в нашу матрицу
           shr   al,4
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

;Проверяет состояние кнопок "+" и "-" и соответствующим образом изменяет
;период дискретизации
CheckKeys  proc  near
           ;Кнопки проверяем только через некоторое время после
           ;первого нажатия
           cmp   KbdCounter,0
           jz    KbdReady
           dec   KbdCounter
           jmp   ExitProc

KbdReady:
           in    al,KeyPort
           
           ;А нажата ли кнопка?
           mov   ah,PlusMask
           or    ah,MinusMask
           and   al,ah
           jz    ExitProc    ;Ничего не нажали

           ;На одновременное нажатие всех кнопок не реагируем
           cmp   al,ah
           jz    ExitProc
           
           ;Обработаем кнопку "+"
           test  al,PlusMask
           jz    CheckForMinus   ;Нажали другую кнопку
           mov   ax,DiscrTime    ;А можно ли увеличивать период дискретизации?
           cmp   ax,00100h
           jz    ExitProc        ;Нельзя увеличивать период дискретизации
           add   al,1
           aaa                   ;Период у нас в 2-10 формате, корректируем
           mov   DiscrTime,ax
           ;Теперь некоторое время на нажатия кнопок не реагируем
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;Обновим индикаторы
           jmp   ExitProc

CheckForMinus:
           ;Обработаем кнопку "-"
           test  al,MinusMask    ;Нажали другую кнопку
           jz    ExitProc
           mov   ax,DiscrTime
           cmp   ax,00001h       ;А можно ли уменьшать период дискретизации?
           jz    ExitProc
           sub   al,1
           aas                   ;Период у нас в 2-10 формате, корректируем
           mov   DiscrTime,ax
           ;Теперь некоторое время на нажатия кнопок не реагируем
           mov   KbdCounter,KbdCounterMax
           call  ShowDiscrTime    ;Обновим индикаторы

ExitProc:           
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

DEL        proc near
           dec   DelayCounter
           ret
DEL        endp              

Count   proc  near

           ;Пока DelayCounter<>0 новое значение с АЦП читать не будем
           ;Но образ на матрицах нужно обновлять, иначе они погаснут
           cmp   DelayCounter,0
           jnz   DiscrEnd

           ;Установим DelayCounter в соответствие с периодом дискретизации
           mov   ax,DiscrTime
           or    ah,ah
           jz    AH0
           add   al,10
           xor   ah,ah
AH0:
           mov   DelayCounter,ax
           
           ;call  GetADCValue
           ;call  UpdateOscImage
           
           ret
Count   endp   
        
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
           
           call  Count  
           
           call  GetADCValue
           call  UpdateOscImage
DiscrEnd:
           call  DEL
           call  CheckKeys
           call  DelayProc
           
           jmp   MainLoop


;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
