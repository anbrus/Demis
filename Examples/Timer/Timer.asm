;Демонстрация работы с таймером ВИ54
;Используется режим 3 таймера, в котором на выходе Out формируется сигнал в форме меандра
;Частота таймера 1Гц, Коэффициент деления = 2
;На выходе Out таймер формирует меандр с периодом 2 секунды
;Длительности лог. 0 и лог. 1 будут одинаковые по 1 секунде
;Программа будет увеличивать значение счётчика по фронту и спаду
;То есть счётчик будет увеличиваться на 1 каждую секунду
;Для разрешения работы таймера нужно нажать кнопку "Пуск"

.386
;Задайте объём ПЗУ в байтах
RomSize           EQU 4096

PORT_TIMER_CW     EQU 43h    ;Порт управляющего регистра таймера
PORT_TIMER        EQU 40h    ;Порт счётчика таймера
PORT_TIMER_OUT    EQU 0      ;Порт ввода, к которому подключен выход таймера
PORT_COUNTER_LOW  EQU 0      ;Порт вывода младшей цифры счётчика
PORT_COUNTER_HIGH EQU 1      ;Порт вывода старшей цифры счётчика

Data       SEGMENT use16 AT 40h
timerval   db ?  ;Последнее значение с выхода таймера
counter    db ?  ;Двоично-десятичное значение счётчика
Data       ENDS

Stk        SEGMENT use16 AT 100h
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

Code       SEGMENT use16
;Образы цифр от 0 до 9 для 7-ми сегментного индикатора
digits     db 3Fh, 0Ch, 76h, 05Eh, 4Dh, 5Bh, 7Bh, 0Eh, 7Fh, 5Fh

           ASSUME cs:Code, ds:Data, es:Data, ss: Stk

;Процедура инициализации режима таймера
InitTimer        PROC  NEAR
           mov   al, 16h             ;Режим 3, работа с младшим байтом
           out   PORT_TIMER_CW, al
           
           mov   al, 2               ;Коэффициент деления 2
           out   PORT_TIMER, al

           ret
InitTimer        ENDP

;Процедура отображения значения счётчика
ShowCounter      PROC NEAR
           ;Отображаем младшую цифру из младших 4 бит счётчика
           mov   al, counter
           and   al, 0fh
           xlat  digits
           out   PORT_COUNTER_LOW, al

           ;Отображаем старшую цифру из старших 4 бит счётчика
           mov   al, counter
           shr   al, 4
           xlat  digits
           out   PORT_COUNTER_HIGH, al

           ret
ShowCounter      ENDP

;Процедура ожидания изменения выхода таймера
WaitTimer        PROC NEAR
WaitTimerLoop:
           in    al, PORT_TIMER_OUT       ;Чтение выхода таймера
           cmp   al, timerval             ;Проверка на изменение выхода
           jz    WaitTimerLoop            ;Крутимся в цикле, пока выход не меняется
           mov   timerval, al             ;Запоминаем новое значение выхода
           
           ret
WaitTimer        ENDP

;Процедура инкрементирования счётчика
IncCounter       PROC NEAR
           mov   al, counter
           add   al, 1
           daa                   ;У нас счётчик двоично-десятичный, делаем коррекцию
           mov   counter, al
           
           ret
IncCounter       ENDP

Start:
           mov   ax, Data
           mov   ds, ax
           mov   es, ax
           mov   ax, Stk
           mov   ss, ax
           lea   sp, StkTop
           
           ;Записываем в счётчик значение 0
           xor   ax, ax
           mov   counter, al
           
           ;После инициализации таймера на его выходе будет 1
           ;Первый отсчёт таймера будем фиксировать по переходу выхода в 0
           ;Поэтому в качестве предыдущего значения запомним 1
           inc   al
           mov   timerval, al    
           
           call  InitTimer       ;Инициализация режима работы таймера
           
MainLoop:
           call  ShowCounter     ;Обновляем индикаторы счётчика
           call  WaitTimer       ;Ждём изменения сигнала на выходе таймера
           call  IncCounter      ;Инкрементируем счётчик
           jmp   MainLoop        ;Бесконечный цикл

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END        Start
