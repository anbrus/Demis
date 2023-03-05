           .8086             ; Набор инструкций для 86-го процессора
           locals @@         ; Локальные метки начинаются с "@@"
           jumps             ; Автоматическое определение "дальности" переходов (SHORT/NEAR/FAR)
 

IO_MODE    equ   0000h       ; Адрес индикатора режима

C_ROOM1    equ   01h         ; Режим "Комната 1"
C_ROOM2    equ   02h         ; Режим "Комната 2"
C_ROOM3    equ   04h         ; Режим "Комната 3"
C_ROOM4    equ   08h         ; Режим "Комната 4"
C_RESERVED equ   10h         ; Не исп.
C_MINIMUM  equ   20h         ; Режим "Минимум"
C_MIDIUM   equ   40h         ; Режим "Среднее"
C_MAXIMUM  equ   80h         ; Режим "Максимум"

ADC_START  equ   0002h       ; Адрес порта запуска АЦП 
ADC_READY  equ   0002h       ; Адрес порта готовности АЦП

ADC_A      equ   01h         ; бит запуска/готовности АЦП "Комната 1"
ADC_B      equ   02h         ; бит запуска/готовности АЦП "Комната 2"
ADC_C      equ   04h         ; бит запуска/готовности АЦП "Комната 3"
ADC_D      equ   08h         ; бит запуска/готовности АЦП "Комната 4"

IND_A      equ   00A0h       ; Адрес порта индикатора "Комната 1"/порта данных АЦП "Комната 1"
IND_B      equ   00B0h       ; Адрес порта индикатора "Комната 2"/порта данных АЦП "Комната 2"
IND_C      equ   00C0h       ; Адрес порта индикатора "Комната 3"/порта данных АЦП "Комната 3"
IND_D      equ   00D0h       ; Адрес порта индикатора "Комната 4"/порта данных АЦП "Комната 4"

IND_F      equ   00F0h       ; Адрес порта индикатора данных текущего режима

IND_ROOM   equ   0100h       ; Адрес порта индикатора номера комнаты

IMG_SPACE  equ   00h         ; Изображение пробела
IMG_MINUS  equ   40h         ; Изображение минуса
IMG_POINT  equ   80h         ; Изображение точки


; Сегмент данных
Data       segment at 00000h

Room1      dw    ?           ; Температура в комнате 1
Room2      dw    ?           ; Температура в комнате 2
Room3      dw    ?           ; Температура в комнате 3
Room4      dw    ?           ; Температура в комнате 4

Minimum    dw    ?           ; Минимальная температура
Midium     dw    ?           ; Средняя температура
Maximum    dw    ?           ; Максимальная температура

RoomMin    dw    ?           ; Номер комнаты с минимальной температурой
RoomMax    dw    ?           ; Номер комнаты с максимальной температурой

Mode       dw    ?           ; Режим

           org   07FEh       ; Организация стека размером в 2 кб
StackTop   label word
Data       ends


; Сегмент кода
Code       segment 
           assume cs: Code, ds: Data, es: Data, ss: Data

; Процедуры

; Indicate
; Процедура отображения числа
; DX - порт
; AX - число (от -99.9 до +99.9) 
Indicate   proc
           ; инициализация
           push  dx
           push  cx
           push  bx
           push  ds
           push  cs
           pop   ds          
           mov   bx, offset ImageMap 
           ; "вычисление" знака
           mov   cl, IMG_SPACE
           cmp   ax, 0
           jge   @@ind
           neg   ax
           mov   cl, IMG_MINUS          
           ; индикация
@@ind:     push  cx
           ; вывод разряда после десятичной точки 
           push  dx
           mov   dx, 0
           mov   cx, 10
           div   cx
           mov   cx, ax
           mov   al, dl
           xlat
           pop   dx
           out   dx, al           
           ; вывод младшего целого разряда с точкой           
           inc   dx
           push  dx
           mov   dx, 0
           mov   ax, cx
           mov   cx, 10
           div   cx
           mov   cx, ax
           mov   al, dl
           xlat
           or    al, IMG_POINT
           pop   dx
           out   dx, al
           ; вывод старшего разряда
           inc   dx
           push  dx
           mov   dx, 0
           mov   ax, cx
           mov   cx, 10
           div   cx
           mov   cx, ax
           mov   al, dl
           cmp   al, 0
           pop   dx
           je    @@nonind
           xlat 
           out   dx, al 
           ; если старший разряд "0", то
           ; вывод знака в позиции старшего разряда
@@nonind:  cmp   al, 0
           jne   @@indsign
           pop   ax
           out   dx, al
           push  IMG_SPACE
           ; вывод знака           
@@indsign: pop   ax
           inc   dx
           out   dx, al            
           ; восстановление и выход
           pop   ds
           pop   bx
           pop   cx
           pop   dx
           ret
Indicate   endp


; TestADC
; Опрос АЦП с приведением в рамки 
; Вход:  AL - код АЦП
;        DX - порт
; Выход: AX - число (от -10.0 до +50.0) 
TestADC    proc
           ; подготовка
           push  dx
           push  bx
           ; запуск фронтом
           mov   bl, al
           mov   ax, 0
           out   ADC_START, al
           mov   al, bl
           out   ADC_START, al
           ; ожидание окончания цикла
@@test:    in    al, ADC_READY
           test  al, bl
           jz    @@test   
           ; считывание состояния (0000...FFFF) 
           inc   dx       
           in    al, dx
           mov   ah, al
           dec   dx 
           in    al, dx
           ; приведение в рамки
           mov   cx, 600
           mul   cx
           mov   cx, 0FFFFh
           div   cx
           sub   ax, 100 
           ; восстановление и выход
           pop   bx
           pop   dx
           ret
TestADC    endp


; Опрос датчиков комнат
TestRooms  proc
           ; комната 1
           mov   dx, IND_A 
           mov   ax, ADC_A
           call  TestADC
           mov   Room1, ax
           call  Indicate  
           ; комната 2
           mov   dx, IND_B
           mov   ax, ADC_B
           call  TestADC
           mov   Room2, ax
           call  Indicate  
           ; комната 3
           mov   dx, IND_C
           mov   ax, ADC_C
           call  TestADC
           mov   Room3, ax
           call  Indicate  
           ; комната 4
           mov   dx, IND_D
           mov   ax, ADC_D
           call  TestADC
           mov   Room4, ax
           call  Indicate 
           ret
TestRooms  endp


; Расчет среднего, минимума и максимума
Calculate  proc
           ; поиск среднего
           mov  ax, Room1
           add  ax, Room2
           add  ax, Room3
           add  ax, Room4
           add  ax, 400     
           mov  cx, 10
           mul  cx
           mov  cx, 4
           div  cx
           add  ax, 5
           mov  dx, 0
           mov  cx, 10
           div  cx  
           sub  ax, 100
           mov  Midium, ax
           ; поиск максимума
           mov  ax, Room1
           mov  RoomMax, 1
           cmp  ax, Room2
           jg   @@n1 
           mov  ax, Room2
           mov  RoomMax, 2     
@@n1:      cmp  ax, Room3
           jg   @@n2
           mov  ax, Room3
           mov  RoomMax, 3
@@n2:      cmp  ax, Room4
           jg   @@n3
           mov  ax, Room4
           mov  RoomMax, 4
@@n3:      mov  Maximum, ax                 
           ; поиск минимума 
           mov  ax, Room1
           mov  RoomMin, 1
           cmp  ax, Room2
           jl   @@nn1 
           mov  ax, Room2
           mov  RoomMin, 2     
@@nn1:     cmp  ax, Room3
           jl   @@nn2
           mov  ax, Room3
           mov  RoomMin, 3
@@nn2:     cmp  ax, Room4
           jl   @@nn3
           mov  ax, Room4
           mov  RoomMin, 4
@@nn3:     mov  Minimum, ax         
           ; выход     
           ret
Calculate  endp


; Опрос режима
GetMode    proc
           in    al, IO_MODE
           cmp   al, 0
           jz    @@show 
           xor   ah, ah
           mov   Mode, ax
@@show:    mov   ax, Mode 
           out   IO_MODE, al
           ret
GetMode    endp


; Отображение
Report     proc
           ; Комната 1 ?
           mov   ax, Room1
           mov   cx, 1 
           cmp   Mode, C_ROOM1
           je    @@showrep
           ; Комната 2 ?
           mov   ax, Room2
           mov   cx, 2
           cmp   Mode, C_ROOM2
           je    @@showrep
           ; Комната 3 ?
           mov   ax, Room3
           mov   cx, 3
           cmp   Mode, C_ROOM3
           je    @@showrep
           ; Комната 4 ?
           mov   ax, Room4
           mov   cx, 4
           cmp   Mode, C_ROOM4
           je    @@showrep
           ; Минимум ?
           mov   ax, Minimum
           cmp   Mode, C_MINIMUM
           mov   cx, RoomMin
           je    @@showrep
           ; Максимум ?
           mov   ax, Maximum
           cmp   Mode, C_MAXIMUM
           mov   cx, RoomMax
           je    @@showrep
           ; Среднее ?
           mov   ax, Midium
           cmp   Mode, C_MIDIUM
           mov   cx, 17
           je    @@showrep           
@@showrep: mov   dx, IND_F
           call  Indicate
           push  ds
           mov   ax, cs
           mov   ds, ax 
           mov   bx, offset ImageMap
           mov   al, cl
           xlat
           mov   dx, IND_ROOM 
           out   dx, al 
           pop   ds
           ret
Report     endp


; точка старта
@start:    mov   ax, Data
           mov   ds, ax
           mov   es, ax
           mov   ss, ax
           lea   sp, StackTop
           mov   Mode, C_ROOM1

; МАКРОУРОВЕНЬ
@cicle:    call  TestRooms   ; Опрос датчиков
           call  Calculate   ; Определение среднего, минимума, максимума
           call  GetMode     ; Определение режима
           call  Report      ; Отображение результата
           jmp   @cicle      ; Зацикливание

; карта символов
ImageMap   db    03Fh, 00Ch, 076h, 05Eh, 04Dh, 05Bh, 07Bh, 00Eh    
           db    07Fh, 05Fh, 06Fh, 079h, 033h, 07Ch, 073h, 063h, 000h    

           org   0FF0h
           assume cs: nothing
           jmp   Far Ptr @start
Code       ends

           end               ; конец кода