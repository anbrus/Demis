.8086
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

; Константа подавления дребезга
nmax       EQU   60

; Порт для кнопок
PORT_KEYS          equ 8  ;    

; Порт для индикатора № канала
PORT_CHANEL      equ 7  ;

; Порты семисегментных индикаторов температуры
PORT_TEMPL       equ 6  ; мл. разряд    
PORT_TEMPH       equ 5  ; ст. разряд
PORT_TEMPS       equ 4  ; знак

; Маски управления АЦП 
ADC_START        equ 1  ; запуск     
ADC_READY        equ 1  ; готовность

; Изображение знака "минус"
Image_Min  equ 40h

Data       SEGMENT AT 0
; Порты АЦП
PORT_ADCSTART    db          ?; порт запуска
PORT_ADCDATA     db          ?; порт данных 
PORT_ADCREADY    db          ?; порт готовности    
Num_Chanel       db          ?; № канала
Temp         db      ?          ; Температура (-50..+50)
Image        db      10 dup(?)  ; Сюда скопируется ImageMap для xlat
org        2048-2
StkTop     Label Word         ; стекова верхушка
Data       ENDS

Code       SEGMENT use16

           ASSUME cs:Code,ds:Data,es:Data

; Инициализация
init       proc near
           ;Подготовка
           mov al,03Fh         ;
           out PORT_TEMPH,  al ;
           out PORT_TEMPL,  al ;
           out PORT_CHANEL, al ;
           ; копирование образов цифр из ПЗУ(cs) в ОЗУ(ds) для xlat
           mov cx, 10          ;
           mov si, 0           ;
ciclecopy: mov al, cs:ImageMap[si]
           mov Image[si], al   ;
           inc si              ;
           loop ciclecopy      ;
           lea bx, ds:Image    ;
           mov Num_Chanel, 0   ;
           ret
init       endp

; Процедура чтения клавиш
ReadKey proc near
           ; Ждём нажатия кнопки
      k0:  in  al, PORT_KEYS
           cmp al, 0         ; Кнопка нажата ?
           jnz k1            ;
           cmp Num_Chanel, 0 ; Канал задан ?
           jz  k0            ;
           cmp al, 0         ; Нажата кнопка при
           jz  Next          ; заданном канале ?

; Вычисление портов активизации и чтения канала
      k1:  mov cl, 80h       ;
           xor ch, ch        ;
           mov ah, 1         ;
      k2:    
           inc ch            ; Считаем № кнопки
           cmp ch, 5         ; Ограничение на № кнопки
           jz k1
           cmp cl, 80h       ; Считаем № порта 
           jz k3             ; для считывания
           add ah, 2         ; готовности АЦП
      k3:
           rol cl, 1         ; Проверяем 
             ; нажатие одной
           cmp al, cl        ; из 4-х кнопок
           jnz k2
; Вычисление портов активизации и чтения канала
           mov Num_Chanel, ch;
           dec ch            
           mov PORT_ADCSTART, ch ; Порт для запуска АЦП
           mov PORT_ADCREADY, ah ; Порт готовности АЦП
           dec ah                ;
           mov PORT_ADCDATA, ah  ; Порт ввода данных
; Вывод № канала на индикатор
           mov al, Num_Chanel;
           xlat              ;
           out PORT_CHANEL, al;
     Next: ret
ReadKey endp

;Чтение данных с АЦП и их преобразование
ReadADC proc near
           xor dx, dx        ;
           ; Импульс Start на заданное АЦП
           mov dl, PORT_ADCSTART ;
           mov al, 1         ;
           out dx, al        ; 
           mov al, 0         ; 
           out dx, al        ;
           ; Ждём готовности данных на АЦП
           mov dl, PORT_ADCREADY        ;
     k4:   in al, dx         ;
           cmp al, 1         ;
           jnz k4            ;
           ; Считываем данные с АЦП
           mov dl, PORT_ADCDATA; 
           in al, dx         ;
;   Преобразование диапазона 0..255 в диапазон -50..+50
;   T = (X * 100)/255 - 50
                             ; ax = X
           mov cl, 100       ; cl = 100
           mov ch, 255       ; ch = 255
           mul cl            ; ax = al * cl
           div ch            ; al = ax / ch
           sub al, 50        ; al = al - 50
           mov Temp, al
           ret
ReadADC endp

;Вывод значения температуры
ShowTemp proc near
           mov al, Temp      ; Проверка на
           test al, 80h      ; знак значения температуры
           jz  Plus          ; Переход по знаку температуры
           neg Temp          ;
           mov al, Image_Min ; Выводим минус
           jmp k6
       Plus:    
           mov al, 0         ; Выводим пусто
       k6:
           out PORT_TEMPS, al;
           ; Разбиение числа на единицы и десятки
           xor ah, ah
           mov al, Temp      ;
       k7:
           mov dx, ax
           sub al, 10
           js k8
           inc ah
           jmp k7
       k8:    
           mov ax, dx
           ; Вывод числа
           xlat              ; Выводим старшую 
           out PORT_TEMPL, al; цифру числа

           mov al, ah        ; Выводим
           xlat              ; младшую цифру
           out PORT_TEMPH, al; числа
           ret
ShowTemp endp

Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ss,ax
           lea   sp,StkTop
;    Макроуровень

           call init         ; инициализация
begin:
           call ReadKey      ;Ждём нажатия кнопки
           call ReadADC      ;Чтение данных с АЦП и их преобразование
           call ShowTemp     ;Вывод значения температуры
           jmp begin

; Коды цифр для индикаторов
  ImageMap         db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16      
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
