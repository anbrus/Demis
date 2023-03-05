.386
RomSize    EQU   4096
KeybPort   EQU   0h
DisplPort1 EQU   1h
DrebMax    EQU   50

Data       SEGMENT use16 AT 100h
KeybImage  db    3 dup(?)
KeybNthng  db    ?	;Keyboard Nothing (ничего не нажато)
KeybError  db    ?
Summ       dw    ?
LastWrite  db    ?
Data       ENDS

Code       SEGMENT use16
           ASSUME cs:Code,ds:Data,es:Code,ss:Stk
ImageNum   db    3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7Fh,5Fh

Dreb       PROC  NEAR
DrebM1:    mov   bh,DrebMax	;сколько раз подряд нужно прочитать одно и то же число против дребезга
           mov   ah,al          ;сохр. исх.сост.
DrebM2:    xor   al,ah          ;чистим al
           in    al,dx          ;кладем в al то, что в dx (номер порта KeybPort) 
           jnz   short DrebM1	;переход на метку, если последовательность прервалась
           dec   bh 		;последовательность сокращается 
           jnz   short DrebM2
           ret
Dreb       ENDP

KeyRead    PROC  NEAR
           mov   cx,length KeybImage ;счетчик циклов
           lea   si,KeybImage        ;адрес образа клавиатуры
           mov   bl,11111110b   ;начнем с 1 ряда кнопок (3|2|1|0)(зажигание нулями)
KeyReadM1: mov   al,bl          ;выбор строки
           out   KeybPort,al    ;активация строки
           in    al,KeybPort    ;ввод строки
           mov   dx,KeybPort	;передаем номер порта через регистр dx (для универсальности антидребезга)
           call  Dreb
           not   al		;было, скажем, 11111101, стало 00000010, т.е. второй ряд
           mov   [si],al        ;запись строки
           inc   si             ;модификация адреса
           rol   bl,1		;следующий ряд (цикл.сдвиг влево)
           loop  KeyReadM1      ;все строки прошли?
           RET
KeyRead    ENDP

KeybCntr   PROC  NEAR
           xor   bl,bl
           mov   KeybNthng,bl
           mov   KeybError,bl
           mov   cx,length KeybImage  
           lea   si,KeybImage
KeybCntrM2:mov   al,[si]         ;перебираем ряды с кнопками
KeybCntrM1:adc   bl,0            ;подсчет установленных бит (складываем)
           shr   al,1            ;подсчет установленных бит
           jnz   KeybCntrM1      ;подсчет установленных бит
           adc   bl,0            ;подсчет установленных бит
           inc   si
           loop  KeybCntrM2
           or    bl,bl
           jnz   short KeybCntrM3 ;ничего не нажато?
           not   KeybNthng
           mov   LastWrite,cl
           jmp   short KeybCntrM4
KeybCntrM3:shr   bl,1            ;если там была единичка - после сдвига перепрыгнем ошибку
           jz    short KeybCntrM4
           not   KeybError
KeybCntrM4:RET
KeybCntr   ENDP

Summa      PROC  NEAR
           xor   ax,ax           
           or    KeybNthng,al    
           jnz   short SummaM3   
           or    KeybError,al    ;проверка
           jnz   short SummaM3   ;на
           or    LastWrite,al    ;необходимость
           jnz   short SummaM3   ;суммировать
           lea   si,KeybImage
SummaM1:   inc   ah
           mov   bl,[si]
           inc   si
           or    bl,bl           ;ищем ненулевую строку
           jz    short SummaM1
           dec   ah
           shl   ah,2            ;старшие 2 бита младшей тетрады
SummaM2:   inc   al
           shr   bl,1
           jnz   short SummaM2
           dec   al
           or    al,ah           ;воссоздаем младшую тетраду
           cmp   al,10           ;номер кнопки не больше 10-го номера? (т.е. цифры 9)
           jnb   short SummaM3
           xor   ah,ah
           add   ax,Summ         ;суммируем
           mov   Summ,ax
           not   LastWrite       ;флаг о том, что мы записали, чтобы 100 раз подряд не записать
SummaM3:   RET
Summa      ENDP

Out7LED    MACRO Port            
           lea   bx,ImageNum
           div   dl              ;делим на 10 (Hex->Dec)
           mov   dh,al           ;сохраняем целую часть от деления, она ещё пригодится
           shr   ax,8            ;остаток от деления (который в ah) переносим в al
           add   bx,ax           ;вычисляем адрес образа нужной цифры
           mov   al,es:[bx]
           out   Port,al         ;вывод в порт образ полученной цифры
           mov   al,dh           ;возвращаем целую часть от деления
           ENDM

OutLED     PROC  NEAR
           mov   ax,Summ
           mov   dl,10 
           Out7LED 4             ;будем делить на 10 (Hex->Dec)
           Out7LED 3             ;вызываем макрокоманду для 3 порта
           Out7LED 2             ;                      для 2 порта
           Out7LED 1             ;                      для 1 порта
           RET
OutLED     ENDP

Start:     mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           xor   ax,ax
           mov   Summ,ax
           mov   LastWrite,al
InfLoop:   call  KeyRead         ;читаем клавиатуру
           call  KeybCntr        ;анализ корректности нажатий клавиш
           call  Summa           ;сумма
           call  OutLED          ;вывод суммы
           jmp   short InfLoop

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS

Stk        SEGMENT use16 STACK
           org 10h 
           dw  5 dup(?)
StkTop     LABEL
Stk        ENDS

END
