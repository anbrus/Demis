.386

RomSize    EQU   4096

Code       segment use16
           assume cs:Code,ds:Code,es:Code

Image      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh    ;Образы 16-тиричных символов
           db    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h    ;от 0 до F

Start:
           mov   ax,Code
           mov   ds,ax
           mov   es,ax
;Здесь размещается код программы

           lea   bx,Image

StartADC:                    ;Запускаем преобразование импульсом \_/
                             ;Преобразование начинается по фронту импульса
           mov   al,0
           out   0,al
           mov   al,1
           out   0,al
           
WaitRdy:
           in    al,1        ;Ждём единичку на выходе Rdy АЦП - признак
                             ;завершения преобразования
           test  al,1
           jz    WaitRdy
           
           in    al,0        ;Считываем из АЦП данные
           
           mov   ah,al       ;Преобразуем и выводим на индикаторы
           and   al,0Fh
           xlat
           out   1,al        ;Выводим младшую тетраду
           mov   al,ah
           shr   al,4
           xlat
           out   2,al        ;А теперь старшую
           
           jmp   StartADC    ;И начинаем опрос АЦП заново

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end
