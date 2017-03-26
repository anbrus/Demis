; Головной модуль

Name ArithmeticCaculator

;Описание констант
Point          EQU  10           ; кнопка  '.'
SignChg        EQU  11           ; кнопка '+/-'

; Действие         Код
Addition       EQU  12           ; кнопка  '+'
Subtraction    EQU  13           ; кнопка  '-'
Multiplication EQU  14           ; кнопка  '*'
Division       EQU  15           ; кнопка  '/'
Calculation    EQU  16           ; кнопка  '='

Clr            EQU  17           ; кнопка  'C'
ClrE           EQU  18           ; кнопка  'CE'
Bksp           EQU  19           ; кнопка 'BKSP'
MemClr         EQU  20           ; кнопка  'MC'
MemRd          EQU  21           ; кнопка  'MR'
MemSet         EQU  22           ; кнопка 'X->M'
MemAdd         EQU  23           ; кнопка  'M+'

; Описание данных
Data Segment use16 at 0BA00H
    Rez db 5 dup (?)             ; вещественные числа:
    Arg db 5 dup (?)             ; 1-ый байт - порядок
    Mem db 5 dup (?)             ; со знаком; байты 2-5
                                 ; - мантисса со знаком

    Operation db ?               ; операция

    Error db ?                   ; флаг ошибок

    StrDisplay db 13 dup (?)            ; строка ввода/вывода
                                 ; данных на дисплей:
                                 ; 8 разрядов отделенных
                                 ; точкой, знак, число
                                 ; введеных разрядов,
                                 ; флаг наличия точки,
                                 ; флаг того, что строку
                                 ; надо вводить заново

    ActiveButtonCode db ?        ; код нажатой клавиши
    OutputMap db 13 dup (?)      ; массив образов

    MulRez dw 4 dup (?)          ; вспомогательная
                                 ; переменная
Data EndS

; Описание стека
Stack Segment use16 at 0BA80H
     dw 100 dup (?)              ; 100 слов (с запасом)
     StkTop label Word           ; вершина стека
Stack EndS

; Описание выполняемых действий
Code Segment use16
Assume cs:Code,ds:Data,es:Data

; Инициализация карты образов
InitOutputMap Proc near
         mov OutputMap[0],3Fh    ; образы цифр
         mov OutputMap[1],0Ch    ; от 0 до 9
         mov OutputMap[2],76h
         mov OutputMap[3],05Eh
         mov OutputMap[4],4Dh
         mov OutputMap[5],5Bh
         mov OutputMap[6],7Bh
         mov OutputMap[7],0Eh
         mov OutputMap[8],7Fh
         mov OutputMap[9],5Fh

         mov OutputMap[10],80h   ; образ точки
         mov OutputMap[11],40h   ; образ знака "-"
         mov OutputMap[12],0h    ; образ пустого места
         ret
InitOutputMap EndP

; Очистка строки ввода/вывода данных на дисплей
StrClear Proc near
         push ax
         push di

         lea di,StrDisplay

         xor al,al               ; младший разряд -
         stosb                   ; нулевой

         mov al,12               ; остальные
         mov cx,9                ; отображаемые
   SCcyc:stosb                   ; разряды
         loop SCcyc              ; пусты

         xor al,al
         stosb                   ; введено 0 разрядов
         stosb                   ; точки нет

         mov al,0FFh             ; строку надо вводить
         stosb                   ; заново

         pop di
         pop ax
         ret
StrClear EndP

; Обнуление вещественного числа;
; параметры: в di - смещение числа
FloatClear Proc near
         push bx

         xor bx,bx
   FCcyc:mov byte ptr [di+bx],0  ; обнулить
         inc bx                  ; все
         cmp bx,5                ; 5 байт
         jne FCcyc

         pop bx
         ret
FloatClear EndP

; Смена знака мантиссы вещественного числа,
; параметры: в регистре di - смещение числа
FloatNeg Proc near
         push ax
         push dx

         mov ax,0FFFFh
         mov dx,0FFFFh

         sub ax,[di+1]
         sub dx,[di+3]

         add ax,1
         adc dx,0

         mov [di+1],ax
         mov [di+3],dx

         pop dx
         pop ax
         ret
FloatNeg EndP

include io.asm
include convs.asm
include math.asm

   Begin:mov ax,Data             ; инициализация
         mov ds,ax               ; сегментных
         mov es,ax               ; регистров и
         mov ax,Stack
         mov ss,ax
         mov sp,offset StkTop    ; указателя стека

         mov cx,64
         mov di,0
         mov al,0
ClearData:
         stosb
         loop ClearData

         call InitOutputMap      ; инициализация мас-
                                 ; сива образов
         mov ActiveButtonCode,17
         call Clear              ; очистка переменных

         mov ActiveButtonCode,20
         call MemoryClear        ; очистка памяти

    WCyc:call ErrMsgOutput       ; вывод сообщения об
                                 ; ошибках
         call StrOutput          ; отображение строки
                                 ; ввода/вывода

         call KbdRead            ; опрос клавиатуры
         call DigInput           ; ввод цифры
         call PointInput         ; ввод точки
         call SignChange         ; смена знака

         call AddRezArg          ; ввод
         call SubRezArg          ; операции
         call MulRezArg
         call DivRezArg

         call Calculate          ; вычисление

         call Clear              ; глобальная очистка
         call CE                 ; очистка строки ввода
         call Undo               ; откат

         call MemoryClear        ; очистка памяти
         call MemoryRead         ; отображение содержи-
                                 ; мого памяти
         call MemorySet          ; запоминание в память
         call MemoryAdd          ; сложение с памятью

         jmp WCyc                ; замыкание програм-
                                 ; много кольца

         assume cs:nothing

         org 0FF0h               ; задание стартовой
   Start:jmp Far Ptr Begin       ; точки, управление
                                 ; передается на
                                 ; команду jump
Code EndS

End Start