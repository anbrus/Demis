RomSize    EQU   4096        ;Объём ПЗУ

Data       SEGMENT AT 0 use16
           temp1  db       ?     ;температура в холодильной камере
           temp2  db       ?     ;температура в морозильной камере
           Old    db       ?     ;
           sost1  db       ?     ;состояние исполнительных устройств
           reg    db       ?     ;температурный режим холодильной камеры
           oldreg db       ?     ;
           Count1 dw       ?     ;счётчик времени открытия холодильной камеры
           Count2 dw       ?     ;счётчик времени открытия морозильной камеры
Data       ENDS

        
Stk        SEGMENT AT 100h use16
;Задайте необходимый размер стека
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS 
           
Code       SEGMENT 
             assume cs:Code,ds:Data,es:Code,ss:Stk
             
VibrDestr  PROC  NEAR
           push  ax
           push  bx
VD1:       mov   ah,al       ;Сохранение исходного состояния
           mov   bx,0        ;Сброс счётчика повторений
VD2:       in    al,dx       ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   bx          ;Инкремент счётчика повторений
           cmp   bx,50      ;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных
           pop   bx
           pop   ax
           ret
VibrDestr  ENDP

FuncPrep   PROC NEAR
           mov   sost1,0
           mov   reg,1
           mov   Count1,0
           mov   Count2,0
           mov   old,0
           mov   oldreg,0 
           ret          
FuncPrep   ENDP                      

InputTemp  PROC NEAR
           push  bx
           mov   al,0
           out   8,al
           mov   al,1
           out   8,al
WaitRdy1:  in    al,2
           test  al,1
           jz    WaitRdy1
           in    al,1
           mov   bl,80
           mul   bl
           mov   bl,255
           div   bl        
           mov   temp1,al
           mov   al,0
           out   8,al
           mov   al,10b
           out   8,al
WaitRdy2:  in    al,2
           test  al,10b
           jz    WaitRdy2
           in    al,3
           mov   bl,20
           mul   bl
           mov   bl,255
           div   bl
           sub   al,50       
           mov   temp2,al
           pop   bx
           ret
InputTemp  ENDP

InputInd   PROC NEAR
           mov ah,0 
           mov   al,temp1
           test  temp1,080h
           jz    II6
           push  ax
           mov   al,40h
           out   0,al
           pop   ax
           neg   al
           jmp   II1
II6:       push  ax
           mov   al,00h
           out   0,al
           pop   ax
II1:       mov   cx,8
II3:       rol   ax,1
           push  bx
           mov   bl,ah
           and   bl,0Fh
           cmp   bl,10
           pop   bx
           jb    II4
           add   ah,6
           jmp   II5
II4:       test  ah,10h
           jz    II5
           add   ah,6           
II5:       dec   cx
           cmp   cx,0
           jg    II3
II2:       mov   al,ah       
           and   al,0Fh
           lea   bx,Image
           add   bl,al
           adc   bh,0
           mov   al,es:[bx]
           out   2,al        ;Выводим младшую тетраду
           mov   al,ah
           shr   al,4
           lea   bx,Image
           xor   ah,ah
           add   bx,ax
           mov   al,es:[bx]
           or    al,80h
           out   1,al        ;А теперь старшую
           mov   ah,0 
           mov   al,temp2
           test  temp2,080h
           jz    II7
           push  ax
           mov   al,40h
           out   3,al
           pop   ax
           neg   al
           jmp   II8
II7:       push  ax
           mov   al,00h
           out   3,al
           pop   ax
II8:       mov   cx,8
II9:       rol   ax,1
           push  bx
           mov   bl,ah
           and   bl,0Fh
           cmp   bl,10
           pop   bx
           jb    II10
           add   ah,6
           jmp   II11
II10:      test  ah,10h
           jz    II11
           add   ah,6           
II11:      dec   cx
           cmp   cx,0
           jg    II9
           mov   al,ah       ;Преобразуем и выводим на индикаторы
           and   al,0Fh
           lea   bx,Image
           add   bl,al
           adc   bh,0
           mov   al,es:[bx]
           out   5,al        ;Выводим младшую тетраду
           mov   al,ah
           shr   al,4
           lea   bx,Image
           xor   ah,ah
           add   bx,ax
           mov   al,es:[bx]
           or    al,80h
           out   4,al        ;А теперь старшую
           ret
InputInd   ENDP

InputReg   PROC NEAR
           in    al,0
           Call  VibrDestr       
           mov   ah,Old;
           mov   Old,al
           cmp   al,ah
           jz    IR1
           and   sost1,0FEh
           and   al,0Fh
           mov   ah,0
           mov   cx,4
IR2:       ror   al,1
           adc   ah,0
           loop  IR2
           cmp   ah,1
           jne   IR1
           shr   al,4
           mov   reg,al
IR1:       ret
InputReg   ENDP

OutReg     PROC NEAR  
           mov   al,reg
           out   6,al
           ret  
OutReg     ENDP

Work       PROC NEAR
           mov   al,reg
           cmp   al,1
           jnz   W1
           mov   al,60
           mov   ah,80
           jmp   W9
W1:        cmp   al,2
           jnz   W4
           mov   al,40
           mov   ah,60
           jmp   W9
W4:        cmp   al,4
           jnz   W5
           mov   al,20
           mov   ah,40
           jmp   W9
W5:        cmp   al,8
           jnz   W6
           mov   al,00
           mov   ah,20
           jmp   W9
W6:        jmp   W10
W9:        cmp   temp1,ah
           jl    W2
           or    sost1,1
W2:        cmp   temp1,al
           jg    W3
           and   sost1,11111110b
W3:        cmp   temp2,-30
           jl    W7
           or    sost1,10b
W7:        cmp   temp2,-50
           jg    W8
           and   sost1,11111101b
W8:        mov   al,sost1
           and   sost1,1111b  
           in    al,0    
           and   al,70h
           or    sost1,al
           mov   al,sost1
           out   7,al                  
W10:       ret    
Work       ENDP

OutSignal  PROC NEAR  
           in    al,0
           test  al,1000000b
           jnz   OS1
           mov   Count1,0
           jmp   OS2        
OS1:       test  sost1,1b
           jnz   OS3
           mov   Count1,0
           jmp   OS2 
OS3:       inc   Count1
           cmp   Count1,300
           jnz   OS2
           or    sost1,100b
OS2:       test  al,80h
           jnz   OS4
           mov   Count2,0
           jmp   OS7
OS4:       test  sost1,10b
           jnz   OS5
           mov   Count2,0
           jmp   OS7
OS5:       inc   Count2
           cmp   Count2,300
           jnz   OS7
           or   sost1,100b
OS7:       test  al,01000000b
           jnz   OS8
           mov   cl,1
OS8:       test  sost1,1b
           jnz   OS9
           mov   cl,1
OS9:       test  al,10000000b
           jnz   OS10
           or    cl,10b
OS10:      test  sost1,10b
           jnz    OS11
           or   cl,10b
OS11:      cmp  cl,11b
           jnz   OS6
           and   sost1,11111011b
OS6:       mov   al,sost1
           out   7,al
           ret    
OutSignal  ENDP

Image      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh;Образы 10-тиричных символов от 0 до 9 

Start:     mov   ax,Data      ;инициализация
           mov   ds,ax        ;сегментных
           mov   ax,Code      ;регистров
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           Call  FuncPrep     ;функциональная подготовка
Cont:      Call  InputTemp    ;считывание температур в морзильной и холодильной камерах из АЦП
           Call  InputInd     ;вывод температуры еа индикаторы 
           Call  InputReg     ;ввод температурного режима в морозильной камере
           Call  OutReg       ;вывод температурного режима на светодиоды
           Call  Work         ;обработка и вывод на исполнитеьные устройства
           Call  OutSignal    ;включение сигнализации 
           jmp   Cont         ;замыкания програмного кольца
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END
