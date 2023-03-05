.386
RomSize    EQU   4096
FirstButt  EQU   1
Clockwise  EQU   1

Data       SEGMENT use16 AT 1000h
           Way        db    ?
           Old        db    ?
           Speed      db    ?
           SpeedCX    db    ?
           Current    db    ?
Data       ENDS

Code       SEGMENT use16 
           ASSUME cs:Code,ds:Data,es:Code

Start:     xor   al,al           ;обнуление 
           mov   Old,al          ;переменных
           mov   Way,al    
           mov   Speed,al    
           inc   al
           mov   SpeedCX,al
           mov   Current,al
InfLoop:   in    al,0            ;считывание из порта [0000h]
           mov   ah,al           ;сохраняем считанное значение
           xor   al,Old          ;выделяем фронт волны
           and   al,ah           ;передний фронт
           mov   Old,ah          ;последнее значение становится старым
           jz    m1          
           test  al,FirstButt    ;нажата первая кнопка?
           jz    m3          
           not   Way             ;инверсия переменной направления
           jmp   m1          
m3:        mov   SpeedCX,al      ;изменение переменной скорости
           mov   Speed,al
m1:        xor   cx,cx
m5:        nop
           loop  m5
           dec   SpeedCX
           jnz   InfLoop           
           mov   al,Speed        ;восстанавливаем
           mov   SpeedCX,al      ;счетчик SpeedCX
           mov   al,current      
           test  Way,Clockwise   ;вращение по / против часовой
           jz    m4
           rol   al,1            ;против часовой стрелки
           jmp   m2
m4:        ror   al,1            ;по часовой стрелке
m2:        mov   current,al
           out   0,al            ;вывод в порт [0000h]
           jmp   InfLoop

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS

Stk        SEGMENT use16 STACK
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

END

