RomSize    EQU   4096        ;Объём ПЗУ

Data       SEGMENT AT 0 use16
           temp1  db       ?     ;температура в холодильной камере
           temp2  db       ?     ;температура в морозильной камере
           temp3  db       ?     ;тек. температура в холод.
           temp4  db       ?     ;тек. температура в мороз.
           regim  db       ?     ;режим установка или текущ.
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
           mov   temp1,0
           mov   temp2,0
           mov   temp3,0
           mov   temp4,0
           mov   regim,055h
           mov   al,1
           out   9,al
           ret          
FuncPrep   ENDP                      

InputTemp  PROC NEAR
           push  bx
           mov   al,0
           out   8,al
           mov   al,1
           out   8,al
WaitRdy1:  Call VibrDestr                   
           in    al,2
           test  al,1
           jz    WaitRdy1
           in    al,1
           mov   bl,50
           mul   bl
           mov   bl,255
           div   bl        
           mov   temp1,al
           mov   al,0
           out   8,al
           mov   al,2h
           out   8,al
WaitRdy2:  Call  VibrDestr                   
           in    al,2
           test  al,2h
           jz    WaitRdy2
           in    al,3
           mov   bl,60
           mul   bl
           mov   bl,255
           div   bl
           sub   al,100      
           mov   temp2,al
           pop   bx
           ret
InputTemp  ENDP

InputInd   PROC NEAR
           mov ah,0 
           mov   al,temp1
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
           push  ax
           mov   al,40h
           out   3,al
           pop   ax
           neg   al
           mov   cx,8
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
           cmp   al,0Ah
           jne   Met1
           mov   al,00Ch
           out   0,al
           mov   al,0h
Met1:      lea   bx,Image
           xor   ah,ah
           add   bx,ax
           mov   al,es:[bx]
           or    al,80h
           out   4,al        ;А теперь старшую
           ret
InputInd   ENDP

Work       PROC NEAR
           in   al,0
           out  11,al
           in   al,0Ch
           out  12,al
           ret    
Work       ENDP

ProcReg    PROC  NEAR
           in    al,9
           cmp   al,01h
           jnz   nexpr
           mov   regim,055h
           mov   al,1
           out   9,al
           jmp   endpr
nexpr:     cmp   al,02h
           jnz   endpr
           mov   regim,0AAh
           mov   al,2
           out   9,al
endpr:                     
           RET
ProcReg    ENDP

Prover     PROC  NEAR
           mov   ah,temp1
           cmp   ah,temp3
           jae   PR_1               
           mov   bh,1           
           jmp   enpr1
PR_1:      mov   bh,0
           mov   dh,0
           cmp   ah,temp3
           jbe   enpr1
           in    al,0Ch
           cmp   al,1
           jz    enpr1 
           mov   bh,8
           jmp   enpr1
 enpr1:     
           mov   ah,temp2
           cmp   ah,temp4
           jae   PR_2          
           mov   al,2           
           jmp   enpr2
PR_2:      mov   al,0
           cmp   ah,temp4
           jbe   enpr2
           in    al,0Ch
           cmp   al,1
           jz    enpr3
           mov   al,4
           jmp   enpr2     
enpr3:     mov   al,0
enpr2:     add   al,bh
           out   10,al
           mov   al,0
           mov   bh,0
           mov   dh,0

           RET
Prover     ENDP

test1     PROC NEAR
           mov   al,regim
           cmp   al,055h
           jnz    M_1
           mov   ah,temp1
           mov   temp3,ah
           mov   ah,temp2
           mov   temp4,ah
M_1:       RET
test1      endp
Image      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh;Образы 10-тичных символов от 0 до 9 

Start:     mov   ax,Data      ;инициализация
           mov   ds,ax        ;сегментных
           mov   ax,Code      ;регистров
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           Call  FuncPrep     ;функциональная подготовка
Cont:      
           Call  ProcReg
           Call  InputTemp    ;считывание температур в морзильной и холодильной камерах из АЦП
           Call  InputInd     ;вывод температуры на индикаторы
           Call  test1
           Call  Prover     
           Call  Work         ;обработка и вывод на исполнительные устройства
           jmp   Cont         ;замыкания програмного кольца
           
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END
