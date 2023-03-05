.386

; Описание констант
KeysInputPort = 0      ; Порт, к которому подключены кнопки
NumberOfButtons = 7    ; Кол-во подключенных кнопок
LengthOfMessage = 32   ; Длина сообщения
SimplePeriod = 0FFh    ; Единичный период времени
StateOutputPort = 020h ; Порт, к которому подключены индикаторы состояний
LengthOfOutString = 20 ; Кол-во линий в матрице индикаторов    
FirstMatrixPort = 0    ; Первый порт матрицы индикаторов
OneTick = 01000           ; Время одного элементарного сигнала
OutputTime = 0A00h    ; Время, пока символы в выводимой строке стоят на месте

;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

IntTable   SEGMENT AT 0 use16
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT AT 40h use16
;Здесь размещаются описания переменных
           ; Кнопки
           Buttons           label    byte
           kInput            db    ? ; Нажат "ввод"
           kRusLat           db    ? ; Нажат "Рус/Лат"(0 - русский, FF - лат.)
           kState            db    ? ; Нажата кнопка "Ручн/Авт"
           kPrevMess         db    ? ; Нажато "Предыдущее сообщение"
           kNextMess         db    ? ; Нажато "Следующее сообщение"
           kRight            db    ? ; Нажата кнопка "Промотать влево"
           kLeft             db    ? ; Нажата кнопка "Промотать вправо"
           
           ; Сообщения
           Message1          db    LengthOfMessage dup(?) ; Сообщение 1
           Message2          db    LengthOfMessage dup(?) ; Сообщение 2
           Message3          db    LengthOfMessage dup(?) ; Сообщение 3
           Message4          db    LengthOfMessage dup(?) ; Сообщение 4
           
           ; Указатели
           pCurrentMessage    dw    ? ; Текущее сообщение
           pFirstOutedSimbol  dw    ? ; Первый выводимый символ
           
           ; Флаги
           EndOfReading     db    ? ; 0 - символ не прочитан, FF - символ прочитан 
           LastInputState   db    ? ; 0 - в прошлый раз кнопка Ввод не была нажата
           MessageLoading   db    ?; 0 - Not input, 1 - input 
           
           ; Другие
           MessageCounter    db    ? ; Счетчик сообщений
           CurrentSymbol     db    ? ; Текущий символ
           OutputTimeCounter dw    ? ; Счетчик тактов вывода
           OutputString      db    LengthOfOutString dup(?); Выводимая строка
           InputTime         dw    ? ; Счетчик времени ввода одного символа Морзе
           TickCount         db    ? ; Кол-во элементарных сигналов, прошедших за время ввода одного символа
           CurrentMorzeCode  dw    ? ; Текущий код Морзе
           OutString         db    LengthOfOutString/5 dup(?)   
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 100h use16
;Задайте необходимый размер стека
           dw    40 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант
InitData   ENDS

Code       SEGMENT use16

;////////////////////////////////////////////////////////////////////////////////////////////
; Здесь размещаются описания констант
RussianAlphaBet  db 124,18,17,18,124,127,69,69,69,57,127,69,69,69,58,127,1,1,1,1,96,62,33,62,96,127,69,69,65,65,99,20,127,20,99,34,65,73,77,50,127,16,8,4,127,127,8,20,34,65,124,2,1,1,127,127,4,24,4,127,127,8,8,8,127,62,65,65,65,62,127,1,1,1,127,127,9,9,9,6,62,65,65,65,34,1,1,127,1,1,39,72,72,72,63,14,9,127,9,14,99,20,8,20,99,63,32,32,63,64,7,8,8,8,127,127,64,124,64,127,63,32,60,32,127,127,72,72,48,127,1,127,68,68,56,65,65,73,73,62,127,8,62,65,62,70,41,25,9,127
LatinAlphabet    db 124,18,17,18,124,127,73,73,78,48,31,96,24,96,31,62,65,65,81,114,127,65,65,65,62,127,73,73,73,65,31,32,64,32,31,97,81,73,69,67,0,65,127,65,0,127,12,18,33,64,127,64,64,64,96,127,6,24,6,127,127,4,8,16,127,62,65,65,65,62,127,9,9,9,6,127,9,25,41,70,38,73,73,73,50,1,1,127,1,1,31,32,64,64,127,127,9,9,9,1,127,8,8,8,127,62,65,65,65,34,61,66,66,66,61,0,0,0,0,0,30,33,124,33,30,3,68,120,68,3,99,20,8,20,99,0,0,0,0,0,62,65,64,65,126,125,18,17,18,125
Digits           db 62,81,73,69,62,0,4,2,127,0,66,97,81,73,70,33,73,77,75,49,16,24,20,18,127,71,69,69,69,57,62,69,69,69,57,1,1,1,1,127,54,73,73,73,54,38,73,73,73,62;
DotAndComma      db 0,0,64,0,0, 0,0,80,48,0, 0,0,0,0,0
MorzeSymbols     dw 1011b, 11101010b, 101111b, 111110b, 111010b, 10b, 10101011b, 11111010b, 1010b, 111011b, 10111010b, 1111b, 1110b, 111111b, 10111110b, 101110b, 101010b, 11b, 101011b, 10101110b, 10101010b, 11101110b, 11111110b, 11111111b, 11111011b, 11101111b, 11101011b, 1010111010b, 10101111b, 10111011b, 1111111111b, 1011111111b, 1010111111b, 1010101111b, 1010101011b, 1010101010b, 1110101010b, 1111101010b, 1111111010b, 1111111110b, 101010101010b, 101110111011b, 0
; А здесь заканчиваются описания констант
;///////////////////////////////////////////////////////////////////////////////////////////

           ASSUME cs: Code, ds: Data, es: Data

;/////////////////////////////  Процедуры  /////////////////////////////////////////////////
; Начальная установка переменных
Beginning        proc  near
                 mov         pCurrentMessage, offset Message1 ; Указатель на первое сообщение
                 mov         MessageCounter, 0 ; Счетчик сообщений = 0
                 mov         LastInputState, 0 ; Вначале ничего не вводится
                 mov         OutputTimeCounter, 0 ; Счетчик времени вывода = 0
                 mov         pFirstOutedSimbol, offset Message1 ; Первый выводимый символ - первый символ сообщения 1
                 mov         word ptr InputTime, 0 ; время ввода  = 0
                 mov         word ptr InputTime + 2, 0
                 mov         CurrentMorzeCode, 0 ; Текущий символ Морзе - 0(пробел)
                 mov         MessageLoading, 0
                 mov         EndOfReading, 0
                 
                 ; Заполнение сообщений пробелами
                 mov         cx, LengthOfMessage * 4
                 mov         di, offset    Message1
             Be1:mov         byte ptr [di], 0   
                 inc         di
                 loop        Be1 
                 ret
Beginning        endp

; Чтение кнопок
ReadKeys         proc  near
           RK0:  in          al, KeysInputPort ; Читаем состояния кнопок из порта
                 mov         cx, NumberOfButtons ; Загружаем в счетчик число кнопок
                 mov         bx, offset Buttons ; Загружаем адрес первой переменной кнопки
    NextButton:  shr         al, 1 ; Сдвигаем al на 1, в CF - выдвинутый бит
                 mov         [bx], byte ptr 0 ; В ячейку, соотв. данной кнопке записываем 0
                 jnc         short RK1 ; Если CF не равен 1, то переходим на RK1
                 mov         [bx], byte ptr 0FFh ; При CF = 1 загружаем ячейку кнопки числом FF
           RK1:  inc         bx                  ; переходим к следующей ячейке
                 loop        short NextButton
                 
                 ; Необходима задержка для того, чтобы оператор отпустил некоторые кнопки
           RK2:  in          al, KeysInputPort
                 cmp         al, 1000b
                 jnb         RK2
                 ret
ReadKeys         endp

; Зажигание нужных светодиодов
TypeOut          proc  near
                 mov         al, 1 ; 
                 and         al, kInput ; Зажигание индикатора "ввод"
                 cmp         kRusLat, 0 ; 
                 jne         TO1
                 or          al, 00000100b ; Зажигание индикатора "Рус"
                 jmp         TO2
            TO1: or          al, 00000010b ; Зажигание индикатора "Лат"
            TO2:
            ; Начало отладочной секции
                 mov         ah, TickCount
                 shr         ah, 1
                 jnc         TO3
                 or          al, 10000000b
            TO3:
            ; Конец отладочной секции
                 out         StateOutputPort, al ; Вывод байта состояния в порт
                 ret
TypeOut          endp

; Анализ нажатий кнопки "Ввод"
KeysAnalize      proc  near
                 
                 mov         al, kInput ; В ал - состояние кнопки "Ввод"
                 ; Вначале необходимо проверить, не вводиться ли новое сообщение
                 cmp         LastInputState, 0
                 jne         KA0
                 cmp         kInput, 0
                 je          KA0
                 cmp         MessageLoading, 0
                 jne         KA0
                 mov         MessageLoading, 0FFh ; Если новое сообщение, то включить флаг MessageLoading
                 mov         dx, pCurrentMessage
                 sub         dx, 2
                 mov         pFirstOutedSimbol, dx
                 ; Работа с таймером
           KA0:  nop
                 cmp         MessageLoading, 0;
                 je          KA4
                 cmp         LastInputState, al ; Сравнение текущего состояния кнопки "Ввод" 
                                                ; с прошлым состоянием
                 jne         KA2 ; Если не равно, значит произошел ввод
                 mov         EndOfReading, 0
                 inc         InputTime ; Иначе увеличиваем время нажатия
           KA1:  cmp         InputTime , OneTick
                 jb         KA4
                 inc         TickCount
                 mov         InputTime, 0
                 jmp         KA3 ; Смотрим, не вышло ли время ожидания след. символа 
                 
                 ; Проверка на точку и тире   
           KA2:  cmp         LastInputState, 0
                 je          KA23 ; Если произошло переключение из 0 в 1, нужно проверить длину паузы
                 ; Произошло переключение кнопки из 1 в 0, т.е. введена точка, либо тире. 
                 
                 shl         CurrentMorzeCode, 2 ; Сдвигаем код на 2 бита влево, чтобы в конец 
                                                 ; приписать полученный код
                 cmp         TickCount, 2 ;
                 jnb         KA21 ; Если TickCount > 2 то идти дальше
                 add         CurrentMorzeCode, 10b ; введена точка
                 mov         TickCount, 0 ; Обнуляем тиккаунт и время
                 mov         InputTime, 0
                 jmp         KAFinal ; Процедура окончена
            KA21:add         CurrentMorzeCode, 11b ; Введено тире    
            KA23:mov         TickCount, 0 ; Обнуляем тиккаунт и время
                 mov         InputTime, 0
                 jmp         KAFinal ; Процедура окончена

                 ; проверка на конец ввода символа           
           KA3:  cmp         al, 0
                 jne         KAFinal
                 cmp         TickCount, 3; Проверяем, достиг ли тиккаунт 3
                 jne         KAFinal ; Не достиг - проверка окончена
                 mov         EndOfReading, 0FFh ; Достиг - введен символ
                 mov         TickCount, 0 ; Обнуляем тиккаунт и время
                 mov         InputTime, 0
                 jmp         KAFinal
                 
                 ; Проверка на конец сообщения
           KA4:    
      KAFinal:   mov         LastInputState, al ; Присваиваем прошлому состоянию "Ввод" текущее           
                 ; Ddebug
                 ;mov         CurrentMorzeCode, 101110111011b
                 ;mov         MessageLoading, 0ffh
                 ret
KeysAnalize      endp

; Анализ кода Морзе
CodeAnalize      proc  near
                 cmp         EndOfReading, 0 ; Если символ алфавита не прочитан, то ничего не делаем 
                 je          CAFinal
                 cmp         MessageLoading, 0
                 je          CAFinal
                 mov         si, offset MorzeSymbols ; Начальный адрес символов Морзе
                 xor         dh, dh ; дх = 0
                 mov         cx, 42 ; Кол-во символов в алфавите Морзе
           CA2:  mov         ax, cs: [si] ; Читаем код Морзе из таблицы       
                 cmp         CurrentMorzeCode, ax ; Сравниваем с полученным кодом
                 jne         CA1 
                 mov         CurrentSymbol, dh ; Если равен, то запоминаем номер символа
                 jmp         CA3 ; Нашли номер символа и выходим
           CA1:  inc         dh ; Увелич. номер символа
                 add         si, size MorzeSymbols ; перемещаемся на след. код Морзе
                 loop        CA2 ; Зацикливание
                 mov         CurrentSymbol, 42 ; Символ не найден - будет нулевым
          
          CA3:   mov         CurrentMorzeCode, 0 ; Нашли место символа в таблице, значит код
                                                 ; символа нам уже не нужен
                 ; Необходимо приписать символ к какому-либо алфавиту
                 cmp         kRusLat, 0
                 je          CA4
                 add         CurrentSymbol, (offset LatinAlphabet - offset RussianAlphabet) / 5
                 jmp         CAFinal
          CA4:   cmp         CurrentSymbol, (offset LatinAlphabet - offset RussianAlphabet) / 5
                 jb          CAFinal
                 add         CurrentSymbol, (offset LatinAlphabet - offset RussianAlphabet) / 5         
       CAFinal:  inc         CurrentSymbol
                 ret
CodeAnalize      endp                

; Переключатель сообщений
MessageSwitcher  proc  near
                 ; Обработка кнопки "Пред. сообщение"
                 cmp         kPrevMess, 0 ; проверяем кнопку
                 je          MS1 ; кнопка не нажата - ничего не делаем
                 mov         OutputTimeCounter, 0
                 mov         ax, pCurrentMessage ; Загр. в ах указатель на текущее сообщение
                 cmp         ax, offset Message1 ; Проверяем, не указывает ли на первое сообщ.
                 je          MS0 ; Если на первое - переключаемся на 4-е
                 sub         ax, LengthOfMessage ; Вычитаем из ах длину сообщения, т.е. встаем
                                                 ; на предыдущее
                 mov         pCurrentMessage, ax ; Устанавливаем указатель на предыдущее
                 mov         pFirstOutedSimbol, ax ; Первый выводимый символ - начало сообщения
                 jmp         MSFinal ; Завершаем работу процедуры
            MS0: mov         pCurrentMessage, offset Message4 ; Переключаемся на 4-е сообщение           
                 mov         pFirstOutedSimbol, offset Message4 ; Первый выводимый символ - начало
                                                                 ; 4-го сообщения
                 jmp         MSFinal ; Завершаем процедуру
                 
                 ; Обработка кнопки "След. сообщение"
            MS1: cmp         kNextMess, 0 ; Проверяем кнопку "След. сообщение"
                 je          MSFinal ; неактивна - завершаем работу
                 mov         OutputTimeCounter, 0
                 mov         ax, pCurrentMessage ; Загружаем в ах указатель на текущее сообщение
                 cmp         ax, offset Message4 ; Не четвертое ли сообщение?
                 je          MS2 ; Если четвертое, то переключаемся на первое
                 add         ax, LengthOfMessage ; Иначе добавляем длину сообщения, т.е. перек-
                                                 ; лючаемся на следующее
                 mov         pCurrentMessage, ax ; След. сообщение стало текущим
                 mov         pFirstOutedSimbol, ax ; Первый выводимый символ - начало сообщ. 
                 jmp         MSFinal ; Завершаем процедуру
            MS2: mov         pCurrentMessage, offset Message1 ; текущее сообщ. - первое
                 mov         pFirstOutedSimbol, offset Message1 ; Указатель на начало           
        MSFinal: 
                 ret
MessageSwitcher  endp

; Добавление введенного символа в строку
CodeConversion   proc  near
                 cmp         MessageLoading, 0 ; Проверка на загружаемость сообщения
                 je          CCFinal ; Сообщение не загружается - конец
                 cmp         EndOfReading, 0 ; Закончено ли чтение символа
                 je          CCFinal ; Не закончено - конец
                 mov         al, CurrentSymbol ; Загружаем в ал полученный символ
                 inc         pFirstOutedSimbol ; Смещаем указатель на след. байт
                 mov         bx, pFirstOutedSimbol ; Загружаем в бх адрес вставки в сообщение
                 mov         [bx + 1], al ; Сохраняем символ по указанному адресу
                 mov         ax, pFirstOutedSimbol ; Необходимо проверить, не вышли ли за границу 
                                                     ; сообщения
                 sub         ax, pCurrentMessage ; Вычисляем текущую длину сообщения
                 cmp         ax, LengthOfMessage - 1; Сверяем с максимальной длиной
                 jne         CCFinal ; Меньше - конец
                 mov         MessageLoading, 0 ; Иначе прием окончен
                 dec         pFirstOutedSimbol
                 ;mov al, CurrentSymbol
                 ;mov Message1, al
        CCFinal: ret
CodeConversion   endp

; Обсчет перемещений строки
ExamStringShift  proc        near
                 cmp         MessageLoading, 0
                 jne         ESSFinal
                 cmp       kState, 0
                 je        ESS1
                 ; Автоматическая промотка
                 inc       OutputTimeCounter ; Увел. счетчик времени вывода
                 cmp       OutputTimeCounter, OutputTime ; Сравниваем значение счетчика с максимальным
                 jne       ESSFinal ; Если меньше, то ничего не делаем
                 inc       pFirstOutedSimbol ; Иначе перемещаемся на след. символ
                 mov       OutputTimeCounter, 0 ; Обнуляем счетчик
                 ; Далее необходимо проверить, не выходит ли тек. символ за границы сообщения
                 mov       ax, pFirstOutedSimbol 
                 sub       ax, pCurrentMessage
                 cmp       ax, LengthOfMessage ; В ах - расстояние от начала сообщения до тек. символа
                 jne       ESSFinal
                 mov       ax, pCurrentMessage ; Если символ вышел за границу, то встаем
                                                 ; на начало сообщения
                 mov       pFirstOutedSimbol, ax
                 jmp       ESSFinal
                 
                 ; Ручная промотка
           ESS1: cmp       kRight, 0 ; нажата ли клавиша "Вправо"
                 je        ESS11 ; Не нажата - идем дальше
                 mov       ax, pCurrentMessage ; Проверяем, не находится ли указатель в начале сообщения
                 cmp       ax, pFirstOutedSimbol ;
                 je        ESSFinal ;
                 dec       pFirstOutedSimbol   ; Ставим указатель на предыдущий символ
          ESS11: cmp       kLeft, 0 ; нажата ли кнопка "Влево"
                 je        ESSFinal ; Не нажата - завершаем работу
                 mov       ax, pCurrentMessage
                 add       ax, LengthOfMessage - LengthOfOutString/5
                 cmp       ax, pFirstOutedSimbol ; Не находится ли указатель у конца сообщения
                 je        ESSFinal
                 inc       pFirstOutedSimbol ; Если не находится, перемещаемся по сообщению                 
        ESSFinal:      
                 ret
ExamStringShift  endp

; Создать выводимую строку, пригодную для отображения на матрице
CreateOutputString proc      near
            COS00: ; Загрузка выводимой строки
                   mov       si, pFirstOutedSimbol ; Загр. в си адрес первого выводимого символа
                   mov       di, offset OutString ; В ди - адрес начала строки вывода
                   mov       cx, LengthOfOutString/5 ; В счетчик - длина строки вывода
            COS01: mov       bx, si ; В бх - адрес текущего символа
                   sub       bx, pCurrentMessage ; Получаем расстояние от первого символа
                                                 ; сообщения до текущего символа
                   cmp       bx, LengthOfMessage ; проверяем, не вышли ли мы за границу сообщения
                   jne       COS02
                   mov       si, pCurrentMessage ; При выходе за границу встаем на начало сообщения
            COS02: mov       al, [si] ; Копируем символ из источника
                   mov       [di], al ; в приемник
                   inc       si ; Увеливаем адреса
                   inc       di
                   loop      COS01 ; делаем, пока сх не равно 0
                                       
             COS0: ; Создается массив отображения
                   mov       si, offset OutString ; Загрузка в СИ адреса первого выводимого символа
                   mov       di, offset OutputString ; Загрузка адреса строки вывода
                   xor       bx, bx ; bx = 0
                   mov       ch, 4 ; Загрузка в ch кол-ва панелей отображения
             COS1: mov       al, [si] ; В al - символ текущего сообщения
                   dec       al ; Этой команды может не будет
                   mov       ah, 5 ; Один символ состоит из 5 линий
                   mul       ah ; Получаем адрес, в котором хранится образ символа
                   mov       bx, ax ; Отправляем адрес в базовый регистр, чтобы можно было обратиться
                   mov       cl, 5 ; Загрузка кол-ва линий в одном символе             
                 COS2: mov       al, cs: [bx] ; Загружаем линию образа символа
                       mov       [di], al ; Отправляем линию символа в выводимую строку
                       inc       di
                       inc       bx
                       dec       cl
                       jnz       COS2
                   inc       si
                   dec       ch    
                   jnz      COS1          
                   ret          
CreateOutputString endp          

; Отображение строки
StringOut        proc  near
                 lea         bx, OutputString ; Загрузка адреса массива отображения
                 mov         cx, LengthOfOutString ; Загрузка длины массива отображения
                 mov         dx, FirstMatrixPort ; Загрузка адреса первого порта вывода
            SO1: mov         al, [bx] ; В ал - линия массива отображения
                 out         dx, al ; Вывод линии в порт дх
                 inc         bx ; Перемещение на следующую линию массива отображения
                 inc         dx ; Переместиться на следующий порт
                 loop        SO1    ;  
                 ret
StringOut        endp

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
; Главная часть программы
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Start:     ; Системнаяя подготовка
           mov   ax, Data
           mov   ds, ax
           mov   es, ax
           mov   ax, Stk
           mov   ss, ax
           lea   sp, StkTop
           ; Конец системной подготовки
           call Beginning ; Функциональная подготовка
; Зацикливание макроуровня
MainCycle: 
           call ReadKeys ; Чтение состояний кнопок
           call TypeOut ; Вывод состояния на светодиоды
           call KeysAnalize ; Анализ состояний кнопок
           call CodeAnalize ; Анализ вводимого кода Морзе
           call CodeConversion ; Преобразование из кода Морзе в нормальный человеческий язык
           call MessageSwitcher ; переключение сообщений
           call ExamStringShift ; Вычислить перемещение строки
           call CreateOutputString ; Создать выводимую строку
           call StringOut ; Вывод строки на матричную панель 
           jmp MainCycle

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
