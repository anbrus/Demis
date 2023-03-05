
RomSize      EQU   4096
NMax         EQU   50          ;Константа подавления дребезга
                               ;Адреса портов архитектуры ввода\вывода
KbdPort      EQU   0           ;Порт клавиатуры, микрофона, светового и звукового сигналов          
DispPort0    EQU   1           ;Порты индикаторов 
DispPort1    EQU   2           ;пульта председателя
Port0        EQU   3           ;Порты индикаторов 
Port1        EQU   4           ;пульта докладчика
                               ;Коды функциональных клавиш
Ots          EQU   10          ;Отсчет без отключения микрофона
OtO          EQU   11          ;Отсчет с отключением микрофона
Vos          EQU   12          ;Восстановление введенного времени
Otk          EQU   13          ;Отключение микрофона
Ost          EQU   14          ;Пауза
Nac          EQU   15          ;Установка начальных параметров

Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

Data       SEGMENT AT 0
KbdImage     DB    4 DUP(?)     ;Адрес массива образов символов
EmpKbd       DB     ?           ;Флаг пустой клавиатуры
KbdErr       DB     ?           ;Флаг ошибки
KodKey       DB     ?           ;Код нажатой клавиши
Key          DB     ?           ;Ключ разрешения ввода значения времени и отсчета
Image        DB     ?           ;Образ младшей цифры значения времени
Ind0         DB     ?           ;Индексы цифр введенного
Ind1         DB     ?           ;для отсчета времени
Number       DB     ?           ;Численное значение введенного для отсчета времени
Num0         DB     ?           ;Младшая цифра оставшегося времени
Num1         DB     ?           ;Старшая цифра оставшегося времени
Expect       DW     ?           ;Контроль задержки
Kl           DB     ?           ;Разрешение совместной работы клавиш Отк и Ост
Nuh          DB     ?
Data       ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Code,ss:Stk

           ;Массив образов 16-тиричных символов: "0", "1", ... "9"
SymImages  DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh

;Процедура загрузки начальных параметров 
Begin  PROC  NEAR
       cmp   KodKey, Nac         ;Начальная загрузка?
       jnz   Bgn                 ;Переход, если нет?
       mov   al,0
       out   DispPort0,al        ;Гашение
       out   DispPort1,al        ;индикаторов
       out   Port0,al            ;пультов председателя
       out   Port1,al            ;и докладчика,
       out   KbdPort,al          ;клавиатуры, сигналов и микрофона
       mov   Image,al            ;обеспечение посимвольного вывода на пульт председателя
       mov   Key,al              ;Разрешение введения значения времени
       mov   Expect,03FFh        ;Задание задержки
       mov   Kl,2                ;Снятие флагов Отк и Ост           
Bgn:   ret
Begin  ENDP

;Процедура гашения дребезга
VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;Сохранение исходного состояния
           mov   bh,0        ;Сброс счётчика повторений
VD2:       in    al,dx       ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   bh          ;Инкремент счётчика повторений
           cmp   bh,NMax     ;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных
           ret
VibrDestr  ENDP

;Процедура контроля за включением микрофона, светового и звукового сигналов 
Kbd  PROC  NEAR
     cmp   Key,1
     jbe   K
     ;cmp   Nuh,0
     ;jnz   K
     cmp   KodKey,Ost          ;Пауза?
     jnz   K1                  ;Переход, если нет
     cmp   Kl,1                ;Микрофон отключен?
     jz    K5                  ;Переход, если да
     mov   Kl,0                ;Установить флаг остановки
     jmp   K4                  ;Переход
K1:  cmp   KodKey,Ots          ;Отсчет времени без отключения микрофона?
     jz    K3                  ;Переход, если да
     cmp   KodKey,Otk          ;Отключить микрофон?  
     jnz   K2                  ;Переход, если да
     cmp   Kl,0                ;Пауза?  
     jz    K5                  ;Переход, если да
     mov   Kl,1                ;Микрофон отключен
     jmp   K5                  
K2:  cmp   KodKey,OtO          ;Отсчет времени с отключением микрофона?
     jnz   K                   ;Выход из процедуры, если нет
     cmp   Key,4               ;Время истекло?
     jz    K                   ;Переход, если да
K3:  mov   Kl,2                ;Снятие флагов отключенного микрофона и паузы
K4:  or    al,010h             ;Включение
K5:  cmp   Num1,0              ;Осталась 
     jne   K                   ;1 минута до истечения
     cmp   Num0,1              ;отведенного времени?
     jne   K6                  ;Переход, если нет
     or    al,020h             ;Включить световой сигнал
     jmp   K
K6:  cmp   Num0,0              ;Время истекло?
     jnz   K                   ;Переход, если нет
     cmp   Expect,1             ;Последняя минута закончилась?
     jz    K7                  ;Переход, если да
     or    al,040h             ;Включить звуковой сигнал  
     jmp   K
K7:  mov   Key,4               ;Время истекло
K:   ret      
Kbd  ENDP

;Процедура ввода с клавиатуры
KbdInput   PROC  NEAR
           lea   si,KbdImage         ;Загрузка адреса,
           mov   cx,LENGTH KbdImage  ;счётчика циклов
           mov   bl,0FEh             ;и номера исходной строки
KI4:       mov   al,bl               ;Выбор строки
           and   al,0Fh
           call  Kbd                 ;Вызов процедуры Kbd
           out   KbdPort,al          ;Активация строки
           in    al,KbdPort          ;Ввод строки
           and   al,0Fh              ;Включено?
           cmp   al,0Fh
           jz    KI1                 ;Переход, если нет
           mov   dx,KbdPort          ;Передача параметра
           call  VibrDestr           ;Гашение дребезга
KI1:       mov   [si],al             ;Запись строки
KI2:       in    al,KbdPort          ;Ввод строки
           and   al,0Fh              ;Выключено?
           cmp   al,0Fh
           jnz   KI2                 ;Переход, если нет
           call  VibrDestr           ;Гашение дребезга
           inc   si                  ;Модификация адреса
           rol   bl,1                ;и номера строки
           loop  KI4                 ;Все строки? Переход, если нет
           ret
KbdInput   ENDP

;Процедура контроля ввода с клавиатуры
KbdInContr PROC  NEAR
           lea   bx,KbdImage         ;Загрузка адреса
           mov   cx,4                ;и счётчика строк
           mov   EmpKbd,0            ;Очистка флагов пустой клавиатуры
           mov   KbdErr,0            ;и ошибки
           mov   dl,0                ;и накопителя
KIC2:      mov   al,[bx]             ;Чтение строки
           mov   ah,4                ;Загрузка счётчика битов
KIC1:      shr   al,1                ;Выделение бита
           cmc                       ;Подсчёт бита
           adc   dl,0
           dec   ah                  ;Все биты в строке?
           jnz   KIC1                ;Переход, если нет
           inc   bx                  ;Модификация адреса строки
           loop  KIC2                ;Все строки? Переход, если нет
           cmp   dl,0                ;Накопитель=0?
           jz    KIC3                ;Переход, если да
           cmp   dl,1                ;Накопитель=1?
           jz    KIC4                ;Переход, если да
           mov   KbdErr,0FFh         ;Установка флага ошибки
           jmp   SHORT KIC4
KIC3:      mov   EmpKbd,0FFh         ;Установка флага пустой клавиатуры
KIC4:      ret
KbdInContr ENDP

;Процедура формирования кода нажатой клавиши
KodKeyTrf  PROC  NEAR
           cmp   EmpKbd,0FFh         ;Пустая клавиатура?
           jz    KKT1                ;Переход, если да
           cmp   KbdErr,0FFh         ;Ошибка клавиатуры?
           jz    KKT1                ;Переход, если да
           lea   bx,KbdImage         ;Загрузка адреса
           mov   dx,0                ;Очистка накопителей кода строки и столбца
KKT3:      mov   al,[bx]             ;Чтение строки
           and   al,0Fh              ;Выделение поля клавиатуры
           cmp   al,0Fh              ;Строка активна?
           jnz   KKT2                ;Переход, если да
           inc   dh                  ;Инкремент кода строки
           inc   bx                  ;Модификация адреса
           jmp   SHORT KKT3
KKT2:      shr   al,1                ;Выделение бита строки
           jnc   KKT4                ;Бит активен? Переход, если да
           inc   dl                  ;Инкремент кода столбца
           jmp   SHORT KKT2
KKT4:      mov   cl,2                ;Формировние  
           shl   dh,cl               ;двоичного  
           or    dh,dl               ;кода цифры
           mov   KodKey,dh           ;Запись кода цифры
KKT1:      ret
KodKeyTrf  ENDP

FormIm  PROC  NEAR
        xor   ah,ah
        lea   bx,SymImages        ;вычисление исполнительного адреса
        add   bx,ax               ;массива образов цифр 
        mov   al,es:[bx]          ;считывание образа введенной цифры из массива
        ret   
FormIm  ENDP

;Процедура вывода значения времени на пульт председателя
OutPut  PROC  NEAR  
        cmp   KodKey,09h          ;Нажата функциональная клавиша?
        ja    OP1                 ;Переход, если да 
        cmp   KbdErr,0FFh         ;Ошибка ввода с клавиатуры?
        jz    OP1                 ;Переход, если да
        cmp   EmpKbd,0FFh         ;Пустая клавиатура?
        jz    OP1                 ;Переход, если да
        cmp   Key,2               ;введены 2 цифры?
        jae   OP1                 ;Переход, если да
        mov   al,Image            ;Сохранение образа 
        out   DispPort0,al        ;вывод очередной нажатой цифры
        mov   al,KodKey           ;код нажатой клавиши
        cmp   Key,0               ;вводим младшую цифру? 
        jne   OP2                 ;переход, если нет
        mov   Ind1,al             ;сохраняем индекс старшей цифры
        jmp   SHORT OP3
OP2:    mov   Ind0,al             ;сохраняем индекс младшей цифры
OP3:    call  FormIm
        mov   Image,al            ;сохранение образа младшей введенной цифры
        out   DispPort1,al        ;вывод старшей цифры
        inc   Key
OP1:    ret  
OutPut  ENDP

;Процедура ограничения диапазона вводимого значения времени
RangNum  PROC  NEAR
         cmp   Key,02h            ;Значение времени введено?         
         jne   RN                 ;Переход, если нет
         cmp   Ind1,06h           ;Вводимое время меньше 1 часа?
         jne   RN1                ;Переход, если нет
         cmp   Ind0,0             ;Вводимое время не превышает 1 час?
         je    RN2                ;Переход, если да
         jmp   short RN3
RN1:     cmp   Ind1,06h           ;Вводимое время не превышает 1 час?
         jb    RN2                ;Переход,если нет
RN3:     mov   al,073h            ;Вывод сообщения
         out   DispPort0,al       ;об щшибке
         out   DispPort1,al       ;введенного значения времени
RN2:     mov   Nuh,0
RN:      ret
RangNum  ENDP

;Процедура формирования числового значения введенного времени
FormNum  PROC  NEAR
         mov   al,Ind0             ;Формирование   
         mov   ah,Ind1             ;числового 
         and   al,01111b           ;значения 
         mov   cl,4                ;введенного
         shl   ah,cl               ;времени
         or    al,ah  
         mov   Number,al           ;Сохранение числового значения
         ret
FormNum  ENDP

;Процедура формирования образов цифр оставшегося числового значения времени
FormInd  PROC  NEAR
         mov   al,Number          ;Сохранение числового значения
         and   ax,01111b          ;Формирование индексов
         mov   Num0,al            ;Сохранение индекса младшей цифры
         mov   al, Number
         mov   cl,4                
         shr   al,cl              ;цифр оставшегося значения времени
         mov   Num1,al            ;Сохранение индекса старшей цифры
         ret
FormInd  ENDP

NumOut  PROC  NEAR
        mov   al,Num0
        call  FormIm
        out   DispPort1,al        ;оставшегося значения времени 
        out   Port0,al            ;на оба пульта         
        mov   al,Num1
        call  FormIm
        out   DispPort0,al        ;оставшегося значения времени 
        out   Port1,al            ;на оба пульта
        ret
NumOut  ENDP

;Процедура отсчета 
Decrement  PROC  NEAR
           cmp   Expect,1            ;Новое значение задержки?
           jnz   Dct                ;Переход, если нет
           mov   al,Number          ;Уменьшение
           sub   al,01h             ;введенного значения времени
           das                      ;на единицу
           mov   Number,al          ;Сохранение числового значения оставшегося времени
Dct:       ret 
Decrement  ENDP

;Процедура задержки
Delay  PROC  NEAR
       cmp   Expect,0              ;Время отображения очередного значения оставшегося времени истекло?   
       jnz   Dly                    ;Переход, если нет 
       mov   Expect,03FFh          ;Установка задержки для следующего отображения
Dly:   dec   Expect                ;Уменьшение значения задержки
       ret
Delay  ENDP

;Процедура обеспечения работы функциональных клавиш при отсчете
Count  PROC  NEAR
       cmp   Nuh,0
       jnz   Cnt
       cmp   Key,1
       ja    Cnt6
       cmp   KodKey,Vos
       ja    Cnt 
Cnt6:  cmp   KodKey,Vos         ;Восстановить введенное время?          
       jz    Cnt3               ;Переход, если да 
       cmp   Key,4              ;Время истекло? 
       jz    Cnt                ;Переход если да
       cmp   KodKey,Ots         ;Клавиши Отс,
       jz    Cnt2               ;ОтО,
       cmp   KodKey,OtO         ;или  
       jz    Cnt2               ;Отк
       cmp   KodKey,Otk         ;нажаты?
       jnz   Cnt1               ;Переход, если нет
       cmp   Kl,0               ;Предварительно была нажата клавиша Ост?
       jz    Cnt5               ;Переход, если да
       jmp   Cnt2
Cnt1:  cmp   KodKey,Ost         ;Пауза?
       jnz   Cnt                ;Переход, если да
       jmp   CNT5
Cnt2:  cmp   Key,3              ;Начинать отсчет?
       jz    Cnt4               ;Переход, если да
Cnt3:  call  FormNum            ;Передать параметры для отсчета 
       mov   Key,3              ;Параметры для отсчета переданы
Cnt4:  call  Delay              ;Вызов процедуры задеожки,
       call  FormInd
Cnt5:  call  NumOut             ;процедуры вывода оставшегося числового значения времени
       call  Decrement          ;процедуры уменьшения оставшегося времени на единицу
Cnt:   ret
Count  ENDP

Start:

   mov   ax,Code
   mov   es,ax
   mov   ax,Data
   mov   ds,ax
   mov   ax,Stk
   mov   ss,ax
   lea   sp,StkTop
    
   mov   KodKey,Nac
   mov   Nuh,0FFh
   
InfLoop:
                           ;Вызовы процедур
    call  Begin            ;Процедура загрузки начальных параметров 
    call  KbdInput         ;Процедура ввода с клавиатуры
    call  KbdInContr       ;Процедура контроля ввода с клавиатуры  
    call  KodKeyTrf        ;Процедура формирования кода нажатой клавиши
    call  OutPut           ;Процедура вывода значения времени на пульт председателя
    call  RangNum          ;Процедура ограничения диапазона вводимого значения времени   
    call  Count            ;Процедура организации отсчета с использованием функциональных клавиш
    jmp   InfLoop                             
   
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END

