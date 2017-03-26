.386

RomSize    EQU   4096

Code       segment use16
           assume cs:Code,ds:Code,es:Code

           ;Образы десятичных цифр от 0 до 9
Image      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh

Start:
           mov   ax,Code
           mov   ds,ax
           mov   es,ax
;Здесь размещается код программы

           xor   cl,cl       ;cl - счётчик числа нажатий в формате BCD
           lea   bx,Image    ;bx - указатель на массив образов
           mov   al,[bx]     ;Выводим нули на индикаторы
           out   0,al
           out   1,al
           
WaitBtnDown:
           in    al,0        ;Ждём нажатия кнопки
           test  al,1
           jnz   WaitBtnDown
WaitBtnUp:
           in    al,0        ;Ждём отпускания кнопки
           test  al,1
           jz    WaitBtnUp
           
           mov   al,cl       ;Инкрементируем счётчик числа нажатий
           add   al,1
           daa               ;Считаем в двоично-десятичном коде!
           mov   cl,al
           
           mov   ah,al       ;Теперь выводим число нажатий на индикаторы
           and   al,0Fh
           xlat
           out   0,al
           mov   al,ah
           shr   al,4
           xlat
           out   1,al
           
           jmp   WaitBtnDown ;И начинаем всё заново

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end
