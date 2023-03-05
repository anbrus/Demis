data segment at 0BA00h
        Table1 DB 14 dup(?);Таблица цифр и символов выводимых на дислей

        Buffer DB 9 dup(?);Буфер для дисплея и формирования операндов

        FlagSvDiod DB ?;Индикация использования памяти

        Skancod DB ?;Номер нажатой клавиши, начиная с нуля

        Operanda DW 4 dup(?);Мантиса операнда 0
                 DB ?
        FlagSng1 DB ?;Знак операнда 0 (0FFh при знаке "-")
        Poradok1 DB ?;Порядок операнда 0 (от 0 до -7)

        Operandb DW 4 dup(?);Тоже для операнда 1
                 DB ?
        FlagSng2 DB ?
        Poradok2 DB ?

        Rez      DW 4 dup(?);Результат, получаемый при выполнении операций
        FlagSngR DB ?
        PoradokR DB ?

        MemCell  DW 4 dup(?);Операнд, хранимый в памяти
        FlagSngM DB ?
        PoradokM DB ?

        Flagtek  DB ? ;Номер текущего операнда (0-операнд 0,1-операнд 1)
        Promperm DB 5 dup(?); Промежуточные переменные
        PromperemR DB 5 dup(?)
        Prompora  DB ?
        Promperem1 DB 5 dup(?)

        Code1Oper DB ? ;Код операции однооперандной
        Code2Oper DB ? ;Код операции двухоперандной
        FlagGotov DB ? ;Готовность к запуску выполнения операции
        FlagBusy  DB ? ;Флаг занятости калькулятора
        DubleCode2 DB ? ;Код выполняемой двухоперандной операции
        CodeOper DB  ? ;Код выполняемой операции
        FlagError DB  ? ;Код фиксации ошибки или переполнения
                 DB 16 dup(?);Результат в десятичном виде
        RezD     DB 16 dup(?)
        Chastnoe  DB 8 dup(?);Дополнительная переменная для деления
        FlagVvod  DB ?;Флаг ввода
        RezGotov  DB ?;Флаг готовности результата двухоперандой операции
data ends

stek segment at 0BA80h
     DW 100 dup(?)
st   label word
stek ends

code segment
       assume cs:code,ds:data,ss:stek

SvDDriver proc        ; драйвер светодиода
        push ax
        mov al, FLagSvDiod  ; светодиод 'MEMORY' горит, если FlagSvDiod=1h
        or al, FlagBusy
        out 09, al ; высылка значения в порт светодиода
        pop ax
        ret
SvDDriver endp

BusyDriver proc   ; драйвер светодиода занятости
        push ax
        mov al, FlagBusy  ; светодиод 'BUSY' горит, если FlagBusy=2h
        or al, FlagSvDiod
        out 09, al ; высылка значения в порт светодиода
        pop ax
        ret
BusyDriver endp

Displa1 proc ; драйвер дисплея
        cmp SkanCod, 24 ; Отсутствие нажатой клавиши
        je exitD
        mov cx,9       ; Установка счетчика знакомест
        mov dx, 00h
        lea bx, Table1 ; таблица выводимых символов
        lea si, Buffer ; буфер для вывода
begin:  mov al, [si] ; считывание элемента из буфера
        push cx
        mov cl,al
        and cl,0f0h
        and al,0fh
        xlat            ; Нахождение соответствующего коду в
                        ; Buffer символа
        or al,cl
        pop cx
        out dx,al ; вывод элемента на индикатор
        inc dx
sledD:  inc si
        loop begin
exitd:  ret
Displa1 endp

OScancod proc ; формирование скэнкода в виде номера клавиши
        cmp RezGotov,0ffh  ; Пропустить процедуру, если результат
        je exitOS          ; получен, но не сформирован
        push ax
        push bx
        push dx
        push cx
        lea si, SkanCod
        mov byte ptr [si], 0
        in al,00 ; чтение данных с портов
        mov bl,al
        in al,01
        mov dl,al
        in  al,02
        mov cx,8
up:     shr bl,1 ; определение нажатой клавиши с первого порта
        jc unup
        inc byte ptr [si]
        loop up
        mov cx,8
up1:    shr dl,1 ; определение нажатой клавиши со втор. порта
        jc unup
        inc byte ptr [si]
        loop up1
        mov cx,8
up2:    shr al,1 ; определение нажатой клавиши с трет. порта
        jc unup
        inc byte ptr [si]
        loop up2
unup:   pop cx
        pop dx
        pop bx
        pop ax
exitOS: ret
OScancod endp

MNoshit proc       ; Формирование множителя (см. ниже)
        push cx
        push ax
        mov cx,5
        mov al,0
werFO3: mov [di],al ;обнуление прмежуточной переменной
        inc di
        loop werFO3
        sub di,5 ;восстановление указателя промежуточной переменной
        mov cx,4
werFO1: mov al,[si] ;умножение переданной в процедуру переменной
                    ; на сформированный множитель
        mul dl
        add [di],ax ;формирование промежуточного результата
        inc si
        inc di
        loop werFO1
        sub di,4 ;восстановление указателей
        sub si,4
        mov cx,4
werFO2: mov al,[di] ;пересылка из промеж.переменой в основную
        mov [si],al
        inc si
        inc di
        loop werFO2
        pop ax
        pop cx
        ret
MNoshit endp

FOperand proc ; формирование операндов
        cmp RezGotov,0ffh ; При готовности результата обязательный
        je sledFO         ; вход в процедуру
        cmp SkanCod, 18h  ; Отсутствие ввода
        je exit1
        cmp SkanCod, 10h  ; Введена не операция или операция
        jbe exit1         ; нетребующая операндов
        cmp FlagError, 0FFh ; Пропуск при регистрации ошибки
        je exit1
        jmp sledFO
exit1:  jmp exit0
sledFO: mov FlagBusy, 2h ; Включение флага занятости
        call BusyDriver
        mov al,0
        mov Prompora,al ; Обнуление промежуточного порядка
        lea si,Promperm ; Формирование начального значения множителя
        mov byte ptr [si],1 ; десятков
        inc si
        mov cx,3
werFO:  mov byte ptr [si],0
        inc si
        loop werFO
        lea si,Buffer  ; Установка  указателя буфера
        cmp Flagtek, 0 ; Определение текущего операнда
        jne nisFO
        mov FlagSng1, 00 ; Формирование порядка и знака первого операнда
        cmp Buffer+8, 13
        jne FOA
        mov FlagSng1, 0FFh
FOA:    lea di,Operanda
        lea bx, Poradok1
        mov byte ptr [bx],0
        mov cx,9
        mov dl,0
werFO7: mov [di],dl
        inc di
        loop werFO7
        sub di,9
        jmp nisFO1
nisFO:  mov FlagSng2, 00 ; Формирование порядка и знака второго операнда
        cmp Buffer+8, 13
        jne FOB
        mov FlagSng2, 0FFh
FOB:    lea di,Operandb
        lea bx,Poradok2
        mov byte ptr [bx],0
        mov cx,9
        mov dl,0
werFO8: mov [di],dl
        inc di
        loop werFO8
        sub di,9
                    ; Установка количества разрядов в буфере
nisFO1: mov cx,8
werFO4: mov al,[si] ; Считывание следующего разряда буфера
        cmp al,0Bh  ; Определение наличия разряда с пустотой
        je exit3
        mov dl,al
        and dl,0f0h
        cmp dl,80h  ; Определение наличия разряда с точкой
        jne nisFO2
        mov  dl,Prompora
        mov [bx],dl ; Занесение значения порядка
        and al,0fh
nisFO2: push si     ; Подготовка к формированию множителя десятков
        push di
        push cx
        cmp cx,8
        je nisFO4
        lea di,PromperemR
        lea si,Promperm
        mov dl,0ah
        call MNoshit ; Формирование множителя десятков
nisFO4: lea di,Promperem1 ; Подготовка к формированию дополнения к мантисе
        lea si,Promperm
        mov cx,4
werFO5: mov dl,[si]
        mov [di],dl
        inc si
        inc di
        loop werFO5
        lea di,PromperemR
        lea si,Promperem1
        mov dl,al
        call MNoshit  ; Формирование дополнения к мантисе
        pop cx
        pop di
        pop si
        push si       ; Добавление дополнения к мантисе
        push cx
        clc
        lea si,Promperem1
        mov cx,4
werFO6: mov al,[si]
        adc [di],al
        inc si
        inc di
        loop werFO6
        sub di,4
        pop cx
        pop si
        inc si           ; Изменение указателей
        inc Prompora     ; Изменение промежуточного порядка
        loopnz werFO4
exit3:  mov FlagBusy, 0h ; Выключение занятости
        call BusyDriver
        mov RezGotov,0h  ; Результат двухоперандной операции
                         ; сформирован в операнде 0
exit0:  ret
FOperand endp

BuffChan proc           ; Помещает цифру в Buffer в режиме
        push si         ; со сдвигом влево
        push ax
        push cx
        push dx
        lea si,Buffer
        mov dl, 0Bh     ; Такого SkanCod нет
        mov cx,8        ; Поиск в Buffer уже введенной десятичной
werBC1: mov al,[si]     ; точки
        test al, 10000000b
        jz nisBC
        mov dl,0Ah      ; Десятичная точка найдена
        mov cx,1
nisBC:  inc si
        loop werBC1
        cmp dl,SkanCod
        je exitBC       ; В SkanCod-еще одна десятичная точка
        cmp SkanCod, 0Ah ; В SkanCod-первая десятичная точка
        jne change
        lea si, Buffer
        or byte ptr [si], 10000000b
        jmp exitBC
change: lea si, Buffer
        cmp byte ptr [si+1], 0Bh ; В SkanCod-десятичная цифра
        jne rot
        cmp byte ptr [si], 00h
        jne rot
        jmp outBC
rot:    lea si,Buffer+7
        cmp byte ptr [si], 0bh
        jne exitBC      ; Buffer полностью заполнен
        mov cx,7
werBC:  mov al,[si-1]
        mov [si],al
        dec si
        loop werBC
outBC:  mov al,Skancod  ; Добавление элемента к Buffer
        mov [si],al
exitBC: pop dx
        pop cx
        pop ax
        pop si
        ret
BuffChan endp

AScancod proc
        cmp RezGotov,0ffh ; Отмена выполнения при готовности результата
        je nisASD
        mov al,Skancod ;Проверка пустой клавиши
        cmp al,24
        je nisASD
        cmp al,0Ah ;Проверка на операцию
        ja nisAS
        cmp FlagVvod,0 ; Проверка на осуществление ввода до ввода
        je nisS ; операции
        call ClrBuff ; при вводе второго операнда
        mov Flagtek,1;**
nisS:   call BuffChan ; при вводе первого операнда
        mov FlagVvod,0
nisASD: jmp exitAS
nisAS:  sub al, 0Ah ;Формирование номера операции
        cmp al, 9; Проверка на двухоперандную операцию
        jae nisAS1
        mov Code1Oper, al ; при однооперандной операции
        mov FlagGotov, 0FFh
nisS3:  mov FlagVvod,0 ;*
nisE:   jmp exitAS

nisAS1: cmp al,13;Проверка на равно
        je nisFG
        cmp FlagVvod,0 ;* Отсекание повторного ввода операции
        jne nisGH     ;* двухоперандной без операнда
        cmp DubleCode2, 0 ;Выполнение формирования двухоперандной
        mov FlagVvod,0ffh ;операции
        je nisAS2
werAS:  mov Code2Oper,al
        mov Flagtek,1
        mov FlagGotov, 0FFh
        jmp exitAS
nisAS2: mov dl, Code2Oper
        cmp dl, 0
        je nisAS3
        mov DubleCode2,dl
        jmp werAS
nisAS3: mov DubleCode2,al
        mov Flagtek,0
        jmp exitAS
nisGH:  cmp Code2Oper,0;* сделано для возможности исправления операции
        je nisOP
        mov Code2Oper,al ;* предыдущей на другую
        jmp exitAS
nisOP:  mov DubleCode2,al
        jmp exitAS
nisFG:  cmp DubleCode2,0;Обработка равно
        jne nisGY
        cmp Code2Oper,0
        je exitAS
nisGY:  mov Flagtek,1
        mov FlagGotov,0ffh
        mov FlagVvod,0ffh
        cmp DubleCode2,0
        jne exitAS
        mov al,Code2Oper
        mov DubleCode2,al
        mov Code2Oper,0h
exitAS: ret
AScancod endp

ClrBuff proc                 ; Очистка буфера
        lea si, Buffer
        mov byte ptr [si], 0 ; Вывод в буфер 0
        mov byte ptr [si+8], 10 ; Очистка места знака
                             ; Очистка остальных знакомест
        mov cx, 7
agCB:   mov byte ptr [si+1], 0bh
        inc si
        loop agCB
        ret
ClrBuff endp

Plumin   proc                ; Изменение знака операнда
         cmp Buffer,0
         jne nisPL
         cmp Buffer+1,0Bh
         jne nisPL
         jmp exitPL
nisPL:   cmp Buffer+8, 10    ; через место знака в Buffer
         je PL
         mov Buffer+8, 10
         mov Code1Oper, 0
         mov FlagGotov,0
         ret
PL:      mov Buffer+8, 13
exitPL:  mov Code1Oper, 0    ; Операция выполнена
         mov FlagGotov,0
         ret
Plumin   endp

MS       proc                ; Запись числа в память
         cmp Flagtek, 0
         je first
         mov al, FlagSng2    ; Запись второго операнда в память
         mov FlagSngM, al
         mov al, Poradok2
         mov PoradokM, al
         xor bx, bx
upMS1:   mov al, byte ptr [Operandb+bx]
         mov byte ptr [MemCell+bx], al
         inc bx
         cmp bx, 4
         jne upMS1
         jmp finMS
first:   mov al, FlagSng1   ; Запись первого операнда в память
         mov FlagSngM, al
         mov al, Poradok1
         mov PoradokM, al
         xor bx, bx
upMS2:   mov al, byte ptr [Operanda+bx]
         mov byte ptr [MemCell+bx], al
         inc bx
         cmp bx, 4
         jne upMS2
finMS:   mov FlagSvDiod, 1h ; Включение светодиода памяти
         call SvDDriver
         mov Code1Oper, 0   ; Операция выполнена
         ret
MS       endp

MR       proc               ; Вывод из памяти
         cmp FlagSvDiod, 0  ; Если в памяти 0, то пропустить
         je endMR1          ; процедуру
         mov al, FlagSngM   ; Запись числа из памяти во второй
         mov FlagSngR, al
         mov al, PoradokM
         mov PoradokR, al
         xor bx, bx
upMR1:   mov al, byte ptr [MemCell+bx]
         mov byte ptr [Rez+bx], al
         inc bx
         cmp bx, 4
         jne upMR1
         jmp endMR
endMR1:  mov CodeOper,0
endMR:   mov Code1Oper, 0
         ret
MR       endp

Mplus    proc
         mov FlagSvDiod, 01h
         call SvDDriver
         cmp FlagTek, 0
         mov al,DubleCode2
         push ax
         jne MP0
         lea si, MemCell    ;Копирование содержимого памяти
         lea di, Operandb   ;в область второго операнда
         mov cx, 4
lptMP2:  mov ax, [si]
         mov [di], ax
         add si, 2
         add di, 2
         loop lptMP2
         mov al, FlagSngM
         mov FlagSng2, al
         mov al, PoradokM
         mov Poradok2, al
         call SUM
         jmp MPit
MP0:     lea si, Operanda   ; Сохранение первого операнда
         lea di, Promperm   ; в промежуточную переменную
         mov cx, 11
         mov al, byte ptr [si]
         mov byte ptr [di], al
         inc si
         inc di
         lea si, MemCell    ;Копирование содержимого памяти
         lea di, Operanda   ;в область первого операнда
         mov cx, 4
lptMP:   mov ax, [si]
         mov [di], ax
         add si, 2
         add di, 2
         loop lptMP
         mov al, FlagSngM
         mov FlagSng1, al
         mov al, PoradokM
         mov Poradok1, al
         call SUM
         lea di, Operanda   ; Восстановление первого операнда
         lea si, Promperm   ; из промежуточной переменной
         mov cx, 11
         mov al, byte ptr [si]
         mov byte ptr [di], al
         inc si
         inc di
MPit:    lea si, Rez        ;Копирование результата
         lea di, MemCell    ;в память
         mov cx, 4
lptMP1:  mov ax, [si]
         mov [di], ax
         add si, 2
         add di, 2
         loop lptMP1
         mov al, FlagSngR
         mov FlagSngM, al
         mov al, PoradokR
         mov PoradokM, al
         mov Code1Oper, 0
         pop ax
         mov DubleCode2,al
         ret
Mplus    endp

MC       proc
         mov FlagSvDiod, 0
         mov PoradokM, 0
         mov FlagSngM, 0
         lea si, MemCell
         mov cx, 4
agMC:    mov byte ptr [si], 0
         inc si
         loop agMC
         call SvDDriver
         mov Code1Oper, 0
         ret
MC       endp

Back     proc
         lea si, Buffer
         cmp byte ptr [si+1], 0Bh
         jne goB
         mov byte ptr [si], 0
         jmp endB
goB:     mov cx, 7
         mov bx, 0
agB:     mov al, [si+bx+1]
         mov [si+bx], al
         inc bx
         loop agB
         mov byte ptr [si+7], 0Bh
endB:    mov Code1Oper, 0
         ret
Back     endp

CE       proc
         call ClrBuff
         mov Code1Oper, 0
         ret
CE       endp

ClearALL proc
         call ClrBuff
         mov cx, 134
         lea si, FlagSvDiod
agCA:    mov byte ptr [si], 0
         inc si
         loop agCA
         call SvDDriver
         mov Code1Oper, 0
         ret
ClearALL endp

SUM proc
bgn:    mov al, Poradok1 ; выравнивание порядков
        cmp al, Poradok2
        ja inc2
        je incend
        inc Poradok1
        mov cx, 0Ah
        xor bx, bx
lp1:    mov ax, [Operanda+bx]
        mul cx
        add [Rez+bx], ax
        adc [Rez+bx+2], dx
        add bx, 2
        cmp bx, 8
        jb lp1
        mov bx, 8
lp2:    mov ax, [Rez+bx-2]
        mov [Operanda+bx-2], ax
        mov [Rez+bx-2], 0
        sub bx, 2
        jnz lp2
        jmp bgn
inc2:   inc Poradok2
        mov cx, 0Ah
        xor bx, bx
lp3:    mov ax, [Operandb+bx]
        mul cx
        add [Rez+bx], ax
        adc [Rez+bx+2], dx
        add bx, 2
        cmp bx, 8
        jb lp3
        mov bx, 8
lp4:    mov ax, [Rez+bx-2]
        mov [Operandb+bx-2], ax
        mov [Rez+bx-2], 0
        sub bx, 2
        jnz lp4
        jmp bgn
incend: cmp FlagSng1, 0    ;Преобразование первого операнда
        je nxtS1           ;в дополнительный код
        lea si, Operanda
        mov cx, 4
agS1:   not word ptr [si]
        add si, 2
        loop agS1
        inc Operanda
        adc Operanda+2, 0
        adc Operanda+4, 0
        adc Operanda+6, 0
nxtS1:  cmp FlagSng2, 0    ;Преобразование второго операнда
        je nxtS2           ;в дополнительный код
        lea si, Operandb
        mov cx, 4
agS2:   not word ptr [si]
        add si, 2
        loop agS2
        inc Operandb
        adc Operandb+2, 0
        adc Operandb+4, 0
        adc Operandb+6, 0
nxtS2:  mov al, Poradok1   ;Порядок результата
        mov PoradokR, al
        mov cx, 4
        lea si, Operanda   ;Копирование первого операнда
        lea di, Rez        ;в область результата
lptS:   mov ax, [si]
        mov [di], ax
        add si, 2
        add di, 2
        loop lptS
        lea si, Operandb   ;Сложение операндов
        lea di, Rez
        mov cx, 4
        clc
lopS:   mov ax, [si]
        adc [di], ax
        inc si
        inc si
        inc di
        inc di
        loop lopS
        rol Rez+6, 1
        jnc outS1          ;Результат положителен
        ror Rez+6, 1
                           ;Перевод Rez в прямой код
        lea si, Rez
        mov cx, 4
aS:     not word ptr [si]
        add si, 2
        loop aS
        clc
        inc Rez
        adc Rez+2, 0
        adc Rez+4, 0
        adc Rez+6, 0
        mov FlagSngR, 0FFh
        jmp outS2
outS1:  ror Rez+6, 1
        mov FlagSngR, 0
outS2:  mov DubleCode2, 0
        ret
SUM     endp

MIN     proc
bgnM:   mov al, Poradok1 ; выравнивание порядков
        cmp al, Poradok2
        ja incM2
        je incendM
        inc Poradok1
        mov cx, 0Ah
        xor bx, bx
lpM1:   mov ax, [Operanda+bx]
        mul cx
        add [Rez+bx], ax
        adc [Rez+bx+2], dx
        add bx, 2
        cmp bx, 8
        jb lpM1
        mov bx, 8
lpM2:   mov ax, [Rez+bx-2]
        mov [Operanda+bx-2], ax
        mov [Rez+bx-2], 0
        sub bx, 2
        jnz lpM2
        jmp bgnM
incM2:  inc Poradok2
        mov cx, 0Ah
        xor bx, bx
lpM3:   mov ax, [Operandb+bx]
        mul cx
        add [Rez+bx], ax
        adc [Rez+bx+2], dx
        add bx, 2
        cmp bx, 8
        jb lpM3
        mov bx, 8
lpM4:   mov ax, [Rez+bx-2]
        mov [Operandb+bx-2], ax
        mov [Rez+bx-2], 0
        sub bx, 2
        jnz lpM4
        jmp bgnM
incendM: cmp FlagSng1, 0    ;Преобразование первого операнда
        je nxtM1            ;в дополнительный код
        lea si, Operanda
        mov cx, 4
agM1:   not word ptr [si]
        add si, 2
        loop agM1
        inc Operanda
        adc Operanda+2, 0
        adc Operanda+4, 0
        adc Operanda+6, 0
nxtM1:  cmp FlagSng2, 0    ;Преобразование второго операнда
        je nxtM2           ;в дополнительный код
        lea si, Operandb
        mov cx, 4
agM2:   not word ptr [si]
        add si, 2
        loop agM2
        inc Operandb
        adc Operandb+2, 0
        adc Operandb+4, 0
        adc Operandb+6, 0
nxtM2:  mov al, Poradok1   ;Порядок результата
        mov PoradokR, al
        mov cx, 4
        lea si, Operanda   ;Копирование первого операнда
        lea di, Rez        ;в область результата
lptM:   mov ax, [si]
        mov [di], ax
        add si, 2
        add di, 2
        loop lptM
        lea si, Operandb   ;Вычитание операндов
        lea di, Rez
        mov cx, 4
        clc
lopM:   mov ax, [si]
        sbb [di], ax
        inc si
        inc si
        inc di
        inc di
        loop lopM
        rol Rez+6, 1
        jnc outM1          ;Результат положителен
        ror Rez+6, 1
                           ;Перевод Rez в прямой код
        lea si, Rez
        mov cx, 4
aM:     not word ptr [si]
        add si, 2
        loop aM
        clc
        inc Rez
        adc Rez+2, 0
        adc Rez+4, 0
        adc Rez+6, 0
        mov FlagSngR, 0FFh
        jmp outM2
outM1:  ror Rez+6, 1
        mov FlagSngR, 0
outM2:  mov DubleCode2, 0
        ret
MIN     endp

MULT    proc
        mov al, Poradok1     ;Формирование порядка результата
        add al, Poradok2
        mov PoradokR, al
        xor si, si
lpML2:  mov cx, [Operandb+si] ; Формирование мантиссы
        xor bx, bx
lpML1:  mov ax, [Operanda+bx]
        mul cx
        add [Rez+bx+si], ax
        adc [Rez+bx+si+2], dx
        add bx, 2
        cmp bx, 4
        jb lpML1
        add si, 2
        cmp si, 4
        jb lpML2
        mov al, FlagSng1     ;Формированте знака результата
        xor al, FlagSng2
        mov FlagSngR, al
        mov DubleCode2, 0
        ret
MULT    endp

MU10_cx  proc ; Умножение на 10 в стпени равной значнению в CX
werDi:   push cx
         mov cx, 0Ah
         xor bx, bx
lpMi1:   mov ax, [Operanda+bx]
         mul cx
         add [Rez+bx], ax
         adc [Rez+bx+2], dx
         add bx, 2
         cmp bx, 8
         jb lpMi1
         mov bx, 8
lpMi2:    mov ax, [Rez+bx-2]
         mov [Operanda+bx-2], ax
         mov [Rez+bx-2], 0
         sub bx, 2
         jnz lpMi2
         pop cx
         loop werDi
         xor bx,bx
         mov cx,4
werMu:   mov word ptr [Rez+bx],0
         inc bx
         loop werMu
         ret
MU10_cx  endp

DIVID    proc
         mov ax,Operandb ; определение на  равенство нулю
         mov bx,Operandb+2 ; операнда 1
         or ax,bx
         cmp ax,0
         je exitDiH; выход при делении на 0
         mov al,FlagSng1 ; Определение знака результата
         xor al,FlagSng2
         mov FlagSngR,al ; Выравнивание порядков с осуществлением
         mov al,Poradok1 ; увеличения точности деления
         add al,8
         sub al,Poradok2
         mov PoradokR,al
         ;умножение первого операнда на 10 в 8-ой степени
         ;с занесением в делимое
         mov cx,8
         call MU10_cx
         mov cx,64
         mov ax,0
         mov dx,0
         ; Деление в бинарном виде с восстановлением остатка
werDiH1: jmp near ptr nisusl
         org 07F0h
NEWStart:jmp start
nisusl:  clc
         push cx
         xor bx,bx
         mov cx,4
werDiH:  rcl word ptr [Operanda+bx] ,1 ; Формирование текущей
         inc bx ; части делимого
         inc bx
         loop werDiH
         rcl ax,1
         rcl dx,1
         clc
         sbb ax,word ptr Operandb ; Действие для определения
         sbb dx,word ptr Operandb+2 ; текущего бита частного
         jnc nisDiH1 ;Действие дало положительный результат
         clc ; Действие дало отрицательный результат
         adc ax,word ptr Operandb ; Восстановление остатка
         adc dx,word ptr Operandb+2
nisDiH1: cmc ; Формирование бита частного
         mov bx,0
         mov cx,4
werDiH2: rcl word ptr [Rez+bx] ,1 ; Занесение полученного бита
         inc bx ; в частное
         inc bx
         loop werDiH2
         pop cx
         loop werDiH1
         jmp exitFull
exitDiH: mov FlagError,0ffh
exitFull:mov DubleCode2, 0
         ret
DIVID    endp

Menedger proc
        cmp FlagGotov, 0FFh
        jne exitMan
        mov al, Code1Oper
        cmp al, 0
        ja nisM
        mov al, DubleCode2
        cmp al, 0
        ja nisM
        jmp exitMan
nisM:   mov byte ptr FlagBusy, 2h
        call BusyDriver
        mov CodeOper, al
        lea di,adress
        sub di,6
        mov dl,6
        mul dl
        add di,ax
        jmp di
adress  label byte
        call Plumin
        jmp exitMan
        call Back
        jmp exitMan
        call CE
        jmp exitMan
        call ClearALL
        jmp exitMan
        call MC
        jmp exitMan
        call MR
        jmp exitMan
        call MS
        jmp exitMan
        call Mplus
        jmp exitMan
        call MULT
        jmp exitMan
        call DIVID
        jmp exitMan
        call SUM
        jmp exitMan
        call MIN
exitMan: mov FlagGotov, 0
        mov byte ptr FlagBusy, 0
        call BusyDriver
        ret
Menedger endp

FormHD   proc ; Формирование из двоичного двоично-десятичного
         push bx
         push di
         push si
         push cx
         push dx
         push ax
         lea bx,RezD
         mov cx,16
werFHD2: lea si,Rez+7
         lea di,Chastnoe+7
         xor ah,ah
         mov dl,0Ah
         push cx
         mov cx,8
werFHD:  mov al,[si]
         div dl
         mov [di],al
         dec si
         dec di
         loop werFHD
         mov [bx],ah
         inc bx
         inc si
         inc di
         mov cx,8
werFHD1: mov dl,[di]
         mov [si],dl
         inc si
         inc di
         loop werFHD1
         pop cx
         loop werFHD2
         pop ax
         pop dx
         pop cx
         pop si
         pop di
         pop bx
         ret
FormHD   endp

FormRes  proc ; Формирование результа в буффере
         cmp FlagSngR, 0FFh ; Формирование знака в буфере
         je FRSet
         mov Buffer+8, 10
         jmp FR
FRSet:   mov Buffer+8, 13 ; Формирование разрядов в буфере
FR:      lea di,RezD
         xor bh,bh
         add di,bx
         or byte ptr [di],80h ;установка точки в результате
         add cl,bl ;определяем число значимых рарядов
         mov bh,16
         sub bh,cl ;определение начала формирования буфера в результ.
         mov bl,bh
         xor bh,bh
         lea si,Buffer+7 ;запись в буфер результата
         lea di,RezD+15
         sub di,bx
         mov cl,8
werAR1:  mov dl,[di]
         mov [si],dl
         dec di
         dec si
         loop werAR1
         lea si,Buffer ; Выравнивание числа в буфере
werFR1:  lea bx,Buffer
         mov dl,[si]
         cmp dl,0
         jne exitFR
         mov cx,7
werFR:   mov ah,[bx+1]
         mov [bx],ah
         inc bx
         loop werFR
         mov byte ptr [bx],0bh
         jmp werFR1
exitFR:  and byte ptr Buffer, 0Fh ; Убирание точки из поледнего знакоместа
         cmp byte ptr Buffer+1, 0Bh ; Удаление знака из минус при выводе
         jne RETit ; нуля в буфер (операции *,/)
         cmp Buffer,0
         jne RETit
         mov byte ptr Buffer+8, 10
RETit:   ret
FormRes  endp

AnResu   proc
         cmp FlagError, 0FFh ;выход при возникновении ошибки
         je Perep
         cmp CodeOper, 6 ;выход при незадействовании в операции
         jb extAR ;*
         cmp CodeOper,7
         je extAR
         jmp AR
extAR:   jmp exitAR
AR:      mov byte ptr FlagBusy, 2h
         call BusyDriver
         call FormHD ;формирование двоично-десятичного
         mov al,16 ;определение количества знач. разрядов до зап.
         mov bl,PoradokR
         sub al,bl
         lea di,RezD+15
         xor cx,cx
         mov cl,al
werAR:   mov dl,[di]
         cmp dl,0
         jne nisAR
         dec di
         loop werAR
         inc cl
         inc di
nisAR:   cmp cl,8 ;определение переполнения
         ja Perep ;выход при переполнении в формирование переполнения
         cmp CodeOper,8h ; Отмена формирования результата при М+
         je exitAR
         call FormRes
         cmp CodeOper, 6h ; Отмена дальнейших действий при МR
         je exitAR
         mov Flagtek,0 ; Формирование флагов после выполнения
         mov byte ptr RezGotov,0ffh ; двухоперандных операций
         jmp nisAR1
Perep:   mov byte ptr FlagBusy, 2h
         call BusyDriver
         mov FlagError,0ffh ; Установка флага переполнения
         lea si,Buffer ; Формирование значения буфера
         mov byte ptr [si], 12 ; для переполнения
         inc si
         mov cx,8
werAR2:  mov byte ptr [si],0bh
         inc si
         loop werAR2
nisAR1:  lea si,Rez
         mov cx,8
werAR4:  mov byte ptr [si],0
         inc si
         loop werAR4
         lea si,RezD
         mov cx,16
werAR5:  mov byte ptr [si],0
         inc si
         loop werAR5
exitAR:  mov byte ptr FlagBusy, 0
         call BUsyDriver
         mov CodeOper, 0
         ret
AnResu   endp

start:  mov ax, data
        mov ds, ax
        mov es, ax
        mov ax,stek
        mov ss,ax
        lea sp, st
        mov [Table1],3Fh
        mov [Table1+1],0Ch
        mov [Table1+2],76h
        mov [Table1+3],5Eh
        mov [Table1+4],4Dh
        mov [Table1+5],5Bh
        mov [Table1+6],7Bh
        mov [Table1+7],0Eh
        mov [Table1+8],7Fh
        mov [Table1+9],5Fh
        mov [Table1+10],00h
        mov [Table1+11],00h
        mov [Table1+12],73h
        mov [Table1+13],40h
        call ClearALL
        call ClrBuff
        call BusyDriver
woswr:  call Displa1
        call OScancod
        call AScancod
        call FOperand
        call Menedger
        call AnResu
        jmp woswr
code ends

end newstart

