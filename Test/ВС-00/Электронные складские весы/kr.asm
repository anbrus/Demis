.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096
NMax       EQU 50

; Адреса портов
Ind1       EQU 020h   ; Порты вывода на
Ind2       EQU 010h   ; семисегментные индикаторы
Ind3       EQU 08h    ; 
Ind4       EQU 04h    ; 
Ind5       EQU 02h    ; 
DigIndT    EQU 0Bh    ; Порт T ввода с кнопок и вывода на двоичные индикаторы
KeyIn      EQU 0h     ; Порт ввода с клавиатуры
KeyOut     EQU 0h     ; Порт вывода в клавиатуру
AcpOut     EQU 06h    ; Порт ввода в АЦП
AcpIn1     EQU 06h    ; Порт вывода первого числа из АЦП
AcpIn2     EQU 08h    ; Порт вывода второго числа из АЦП
AcpRdy     EQU 0Ah    ; Порт ожидания готовности


IntTable   SEGMENT AT 100 use16
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT AT 40h use16
;Здесь размещаются описания переменных
Mode     DB ?                      ; Режим (регистрация-ввоз/вывоз-просмотр)
Typt     DB ?                      ; Тип товара (5 типов)
NMX      DB ?                      ; Режим (ввоз-вывоз-на скаладе)
KbdImage DB 5 Dup (?)              ; Образ клавиатуры
Key      DB ?                      ; Двоичный код нажатой клавиши
Weight   DW ?                      ; Текущий вес
Real     DW ?                      ; Реальное значение АЦП
Base     DW ?                      ; Нулевое значение весов
ZerWgh   DW ?                      ; Переменная установки в ноль
Nomer    DB 5 Dup (?)              ; Накопитель номера (со сдвигом в лево)
CntNom   DB ?                      ; Счетчик введенных цифр номера
CntLet   DB ?                      ; Счетчик букв серии номера
Insk     DW 5 Dup (?)              ; Вес товаров на складе (по типам)
Imp      DW 5 Dup (?)              ; Вес товаров ввезенных на склад (по типам)
Exp      DW 5 Dup (?)              ; Вес товаров вывезенных со склада (по типам)
RegCur   DB ?                      ; Текущее число зарегестрированных машин
NomCur   DB ?                      ; Номер записи о машине в регистрационном массиве (для поиска)
WghBin   DB 5 Dup (?)              ; Массив двоичных цифр веса
RegMas   DB 100d Dup (10d Dup (?)) ; Регистрационный массив (БД склада)

;Ошибки:
EmpKbd   DB ?                      ; Пустая клавиатура
KbdErr   DB ?                      ; Нажатие более двух клавиш
WghErr   DB ?                      ; Превышение веса
CurErr   DB ?                      ; Превышение максимального числа регистрируемых машин
ExpErr   DB ?                      ; Ошибка ввоза
ImpErr   DB ?                      ; Ошибка вывоза
InsErr   DB ?                      ; Превышение веса на складе
ZerErr   DB ?                      ; Ошибка установки в ноль
  
NotReg   DB ?                      ; Машина не зарегестрирована

Hlp      DW ?                      ;Вспомогательные переменные
Hlp1     DB ?
Hlp2     DW ?
ACP1     DB ?
ACP2     DB ?
Data     ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 100h use16
;Задайте необходимый размер стека
           dw    2 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант

InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант
           ;Образы 10-тиричных символов: "0", "1", ... "9"
Digit      DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h
           ;Образы букв серии номера
Letter     DB    06Fh,079h,033h,07Ch,073h,063h,03Bh,06Dh,021h,01Ch
           DB    031h,068h,03Fh,067h,060h,05Bh,071h,038h,05Dh

           ASSUME cs:Code,ds:Data,es:Data
           
; Исполняемые модули
;-------------------------------------------------------------------------------------------
; "Функциональная подготовка"
FuncPrep PROC NEAR
         mov EmpKbd,0      ;Обнуление флагов ошибок
         mov KbdErr,0      
         mov WghErr,0      
         mov CurErr,0 
         mov ExpErr,0
         mov ImpErr,0
         mov InsErr,0
         mov NotReg,0
         mov ZerErr,0
         mov RegCur,0      ;Обнуление счетчика машин
         xor al,al
         mov NomCur,al
         mov CntNom,0      ;Обнуление счетчика цифр номера
         mov CntLet,0h     ;Обнуление счетчика букв серии номера
         mov Key,0         ;Обнуление клавиши
         mov ZerWgh,0      ;Обнуление смещения веса относительно нуля
         mov al,020h        
         mov Mode,al       ;ввод режима "Регистрация" по умолчанию
         mov NMX,al        ;ввод режима "На склад" по умолчанию
         mov al,01h
         mov Typt,al       ;ввод типа товара "1" по умолчанию
         mov al,0FFh
         mov Base,0
         mov Weight,0
         mov ACP1,al        ;АЦП активен
         mov ACP2,al        ;АЦП активен
          
         lea si,Nomer       ;Обнуление БД склада
         mov [si+0],0h 
         mov [si+1],0h 
         mov [si+2],0h 
         mov [si+3],0h 
         mov [si+4],0h 
         
         lea si,Insk
         mov word ptr[si+0],0h 
         mov word ptr[si+2],0h 
         mov word ptr[si+4],0h 
         mov word ptr[si+6],0h 
         mov word ptr[si+8],0h 
          
         lea si,Exp
         mov word ptr[si+0],0h 
         mov word ptr[si+2],0h 
         mov word ptr[si+4],0h 
         mov word ptr[si+6],0h 
         mov word ptr[si+8],0h 

         lea si,Imp
         mov word ptr[si+0],0h 
         mov word ptr[si+2],0h 
         mov word ptr[si+4],0h 
         mov word ptr[si+6],0h 
         mov word ptr[si+8],0h 
            
         ret
FuncPrep ENDP
;-------------------------------------------------------------------------------------------
; 1. Модуль вывода сообщений об ошибках
ErMesOut PROC NEAR
         cmp KbdErr,0FFh   
         je EMO1           
         cmp WghErr,0FFh   
         je EMO2           
         cmp CurErr,0FFh   
         je EMO4           
         cmp ImpErr,0FFh   
         je EMO5           
         cmp ExpErr,0FFh   
         je EMO6           
         cmp NotReg,0FFh
         je EMO7
         cmp InsErr,0FFh
         je EMO8
         jmp EMO3          
 EMO1:   mov al,03Fh        
         out 016h,al  
         jmp EMOe          
 EMO2:   mov al,0Ch        
         out 016h,al
         jmp EMOe          
 EMO4:   mov al,076h        
         out 016h,al
         jmp EMOe          
 EMO5:   mov al,05Eh        
         out 016h,al
         jmp EMOe          
 EMO6:   mov al,04Dh        
         out 016h,al
         jmp EMOe
 EMO7:   mov al,05Bh        
         out 016h,al
         jmp EMOe
 EMO8:   mov al,07Bh
         out 016h,al
         jmp EMOe
 EMO3:   xor al,al
         out 016h,al
 EMOe:   ret 
ErMesOut   ENDP
;-------------------------------------------------------------------------------------------
; 2.1. Подмодуль гашения дребезга
VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;Сохранение исходного состояния
           mov   bh,0        ;Сброс счётчика повторений
VD2:       in    al,dx       ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   bh          ;Инкремент счётчика повторений
           cmp   bh,50;NMax  ;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных
           ret
VibrDestr  ENDP
;-------------------------------------------------------------------------------------------
; 2. Модуль ввода режимов
ModInp    PROC NEAR
        mov al,Key
   mi5: cmp al,011h    ;R1
        jne mi6
        mov al,020h
        mov Mode,al
        jmp m3
   mi6: cmp al,012h    ;R2
        jne mi7
        mov al,040h
        mov Mode,al
        jmp m3
   mi7: cmp al,013h    ;R3
        jne m3
        mov al,080h
        mov Mode,al
        jmp m3
      m3: in al,DigIndT     
          ;call VibrDestr
          cmp al,01h
          jne m4
          mov Typt,al
          jmp m8
      m4: cmp al,02h
          jne m5
          mov Typt,al
          jmp m8
      m5: cmp al,04h
          jne m6
          mov TypT,al
          jmp m8
      m6: cmp al,08h
          jne m7
          mov Typt,al
          jmp m8
      m7: cmp al,010h
          jne m8
          mov Typt,al
      m8: in al,DigIndT
          ;call VibrDestr
          cmp al,020h
          jne m9
          mov NMX,al
          jmp m11
      m9: cmp al,040h
          jne m10
          mov NMX,al
          jmp m11           
     m10: cmp al,080h
          jne m11
          mov NMX,al
     m11: ret
ModInp    ENDP
;-------------------------------------------------------------------------------------------
; 3. Модуль ввода с клавиатуры 
KbdInput PROC NEAR
         lea si,KbdImage       
         mov cx,Length KbdImage
         mov bl,01h          ;вывод на индикацию в порт клавиатуры значения Mode
         mov dl,Mode
   km0:  mov al,dl
         or  al,bl          
         out KeyOut,al    
         in al,KeyIn   
         cmp al,0h            
         je km2            
         ;call VibrDestr     
         mov [si],al        
   km1:  in al,KeyIn   
         cmp al,0h         
         jne km1            
         ;call VibrDestr     
         jmp km3     
   km2:  mov [si],al        
   km3:  inc si             
         rol bl,1           
         loop km0           
         ret 
KbdInput ENDP 
;-------------------------------------------------------------------------------------------
; 4. Модуль контроля клавиатуры
KbdContr PROC NEAR
         lea bx,KbdImage    ;Загрузка адреса
         mov cx,Length KbdImage           ;и счетчика строк
         mov EmpKbd,0       ;Очистка флагов
         mov KbdErr,0
         mov dl,0           ;и накопителя 
   m13:  mov al,[bx]        ;Чтение строки
         mov ah,5;4         ;Загрузка счетчика битов 
         shl al,1
   m14:  dec ah             ;Подсчет бита
         cmp ah,0
         je m15             ;переход если все биты в строке
         shr al,1           ;Выделение бита
         cmp al,1           ;бит активен?
         jne m14            ;Переход,если нет
         inc dl             ;инкремент накопителя
         jmp m14
   m15:  inc bx             ;Модификация адреса строки
         loop m13           ;Все строки ? Переход,если нет
         cmp dl,0           ;Накопитель=0 ?
         je m16             ;Переход,если да
         cmp dl,1           ;Накопитель=1 ?
         je m17             ;Переход,если да
         mov KbdErr,0FFh    ;Установка флага ошибки
         jmp Short m17     
   m16:  mov EmpKbd,0FFh    ;Установка флага пустой клавиатуры
   m17:  ret
KbdContr ENDP 
;-------------------------------------------------------------------------------------------
; 5. Модуль преобразования очередной клавиши
KeyTrf PROC NEAR
       cmp EmpKbd,0FFh    ;Пустая клавиатура ?
       je m21             ;Переход,если да 
       cmp KbdErr,0FFh    ;Ошибка клавиатуры ?
       je m21             ;Переход,если да 
       lea bx,KbdImage    ;Загрузка адреса  
       mov dh,0           ;Подготовка накопителей кода строки(dh) 
       mov dl,3           ;и столбца(dl)
 m18:  mov al,[bx]        ;Чтение строки 
       cmp al,0h          ;Строка активна ?
       jne m19            ;Переход,если да
       inc dh             ;Инкремент номера строки
       inc bx             ;Модификация адреса
       jmp short m18
 m19:  cmp al,1
       je m20             ;Бит активен ? Переход,если да
       shr al,1           ;Выделение следующего бита строки
       dec dl             ;Инкремент кода столбца
       jmp short m19
 m20:  mov cl,2           ;Формирование двоичного
       shl dh,cl          ;кода клавиши
       or dh,dl    
       mov Key,dh     
 m21:  ret
KeyTrf ENDP
;-------------------------------------------------------------------------------------------
; 6. Модуль "Ввод из АЦП" 
ACPInp PROC NEAR
       ;установка АЦП
       cmp ACP1,0FFh
       jne Acpret
       mov WghErr,0     ;сброс флага ошибки превышения веса
       mov al,0         ;проверка АЦП
       out AcpOut,al
       mov al,1
       out AcpOut,al
 Rdy:  in  al,AcpRdy    ;ждём единичку на выходе Rdy
       cmp al,1
       jne Rdy
       in al,AcpIn2
       mov ah,al
       in al,AcpIn1
       mov bx,ax         ;исходный вес
       mov Real,bx
       cmp bx,Base
       jbe z1
       sub bx,Base       ;Real>Base
       cmp bx,040000d 
       jbe z2            ;переход если нет
       mov WghErr,0FFh   ;взвод флага ошибки превышения веса
       jmp Acpret
z2:    shr bx,2 
       mov Weight,bx
       jmp Acpret
z1:    mov Weight,0       ;Real<Base
Acpret: ret 
ACPInp ENDP
;-------------------------------------------------------------------------------------------
; 8. Модуль формирования массива отображения веса груза
WghTrf PROC NEAR
       xor al,al
       mov cx,Weight      ;подготовка счетчика
       lea si,WghBin      ;подготовка адреса таблицы цифр веса
       mov [si+0],al      ;подготовка ячеек памяти
       mov [si+1],al
       mov [si+2],al
       mov [si+3],al
       mov [si+4],al
  wtA: xor al,al
 wtA0: cmp cx,0
       je wtE
       dec cx
       inc al
       mov [si+0],al
       cmp al,0Ah       
       jne wtA0
       xor al,al
       mov [si+0],al
       mov al,[si+1]
       inc al
       mov [si+1],al
       cmp al,0Ah       
       jne wtA
       xor al,al
       mov [si+1],al
       mov al,[si+2]
       inc al
       mov [si+2],al
       cmp al,0Ah        
       jne wtA
       xor al,al
       mov [si+2],al
       mov al,[si+3]
       inc al
       mov [si+3],al
       cmp al,0Ah         
       jne wtA
       xor al,al           
       mov [si+3],al
       mov al,[si+4]
       inc al
       mov [si+4],al
       jmp wtA
  wtE: ret
WghTrf ENDP         
;-------------------------------------------------------------------------------------------
; 9. Модуль вывода значения веса на индикаторы
DispWgh PROC NEAR
        ;установка активности окна АЦП
        cmp ACP2,0FFh
        jne dw1
        xor bh,bh  
        lea di,Digit
        lea si,WghBin
        mov bl,[si+0]
        mov al,cs:[di+bx]
        out Ind1,al
        mov bl,[si+1]       
        mov al,cs:[di+bx]
        out Ind2,al
        mov bl,[si+2]       
        mov al,cs:[di+bx]
        out Ind3,al
        mov bl,[si+3]       
        mov al,cs:[di+bx]
        out Ind4,al
        mov bl,[si+4]       
        mov al,cs:[di+bx]
        out Ind5,al
   dw1: 
        ret
DispWgh ENDP       
;-------------------------------------------------------------------------------------------
; 7. Модуль формирования информации
FormInf PROC NEAR
        mov al,KbdErr      ;Есть ошибки ? 
        or al,WghErr
        or al,CurErr      
        or al,ZerErr
        cmp al,0FFh        
        je fi1             ;Переход,если да
        cmp Mode,020h      ;Режим="Регистрация" ?
        je  fi2            ;Переход,если да 
        cmp Mode,040h      ;Режим="Прием/Отгрузка товара" ?
        je  fi3            ;Переход,если да 
        call ModeView      ;Обработка режима "Просмотр состояния склада и выработки водителей" ?
        jmp fi1            
  fi2:  call ModeReg       ;Обработка режима "Регистрация"
        jmp fi1
  fi3:  call ModeNMX       ;Обработка режима "Прием/Отгрузка товара"
  fi1:  ret
FormInf ENDP
;-------------------------------------------------------------------------------------------
; 7.1. Подмодуль обработки режима "Регистрация"
ModeReg PROC 
        cmp EmpKbd,0FFh ;клавиатура пуста?
        jne mrs         ;переход если нет
        ret             ;выход из процедуры
   mrs: xor al,al
        mov ACP1,al     ;АЦП пассивен
        mov ACP2,al     ;АЦП пассивен
        mov al,Key
        cmp al,0Ah      ;нажат "Seria+"
        jne mr0np
        call SeriesAdd
        jmp mrret       ;выход из процедуры
 mr0np: mov al,Key
        cmp al,0Bh      ;нажат "Seria-"
        jne mr0ns
        call SeriesSub
        jmp mrret       ;выход из процедуры
 mr0ns: mov al,Key
        cmp al,0Ch      ;нажат "Enter"?
        jne mr1         ;переход если нет
        mov al,0FFh
        mov ACP1,al     ;АЦП активен
        mov ACP2,al     ;АЦП активен
   mre: call PersNomer  ;проверка на наличие номера в массиве 
        mov al,010d
        mul NomCur      ;NomCur - выходной праметр процедуры PersNomer (номер записи о номере)
        mov bx,ax       ;в bx находится адрес найденной записи
        add bx,06d      ;в bx находится смещение на вес в найденной записи
        lea di,RegMas   ;смещение регистрационного массива
        mov ax,Weight   ;читаем текущий вес
        mov [di+bx],ax  ;запись веса в массив
        jmp mrret       ;выход из процедуры
   mr1: mov al,Key
        cmp al,0Dh      ;нажат "Delete"?  
        jne mr2         ;переход если нет
        call PersNomer
        call Delet
        mov al,0FFh
        mov ACP1,al     ;АЦП активен
        mov ACP2,al     ;АЦП активен
        jmp mrret       ;выход из процедуры
   mr2: cmp al,0Eh      ;нажат "Reset"? 
        jne mr3         ;переход если нет
        call Resett
        mov al,0FFh
        mov ACP1,al     ;АЦП активен
        mov ACP2,al     ;АЦП активен
        jmp mrret       ;выход из процедуры
   mr3: cmp al,0Fh      ;нажат "View"
        jne mr4
        mov al,0FFh
        mov ACP2,al     ;АЦП-окно активен
        mov ACP1,al     ;АЦП активен
        jmp mrret
   mr4: cmp al,010h     ;нажат "Zero"
        jne mr5         ;перход если нет
        call Zero       ;установка в ноль весов
        mov al,0FFh
        mov ACP1,al     ;АЦП активен
        mov ACP2,al     ;АЦП активен
        jmp mrret       ;выход из процедуры
   mr5: cmp al,011h     ;R1
        jne mr6
        mov al,020h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al     ;АЦП активен
        mov ACP2,al     ;АЦП активен
        jmp mrret
   mr6: cmp al,012h     ;R2
        jne mr7
        mov al,040h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al     ;АЦП активен
        mov ACP2,al     ;АЦП активен
        jmp mrret
   mr7: cmp al,013h     ;R3
        jne mrfin
        mov al,080h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al     ;АЦП активен
        mov ACP2,al     ;АЦП активен
        jmp mrret
        ;если ничего не нажато, то записываем очередную цифру в номер:
mrfin:  mov NotReg,0    ;обнуляем флаг "машина не зарегестрирована"
        xor bh,bh
        mov bl,CntNom
        mov [Nomer+bx],al
        inc bl
        cmp bl,04h      ;счетчик цифр=4?
        jne mrc         ;переход если нет
        xor bl,bl       ;обнуление счетчика цифра 
  mrc:  mov CntNom,bl
mrret:  ret
ModeReg ENDP
;-------------------------------------------------------------------------------------------
; 7.2. Подмодуль поиска и проверки наличия введенного номера в массиве
PersNomer PROC NEAR
          mov NotReg,0      ;обнуляем флаг "машина не зарегестрирована"
          mov dl,RegCur     ;число зарегестрированных машин     
          cmp dl,0
          je pn5            ;перход если нет ни одной зарегестрированной машины
          xor dl,dl         ;обнуляем счетчик просматриваемых машин
          xor bx,bx
          xor cx,cx
          lea si,Nomer
          lea di,RegMas
     pn2: mov al,[di+bx]    ;цифра номера из массива
          push bx
          mov bx,cx
          mov ah,[si+bx]    ;цифра искомого номера
          pop bx
          cmp al,ah         ;цифры совпали
          jne pn3           ;переход если нет
          inc cx            ;следующая цифра номера
          inc bx
          cmp cx,05h        ;все цифры номера кончились?
          jne pn2           ;прерход если нет
          mov NomCur,dl     ;если все цифры совпали, сохраняем номер найденной записи
          jmp pn4           ;выход из процедуры (выходной параметр-NomCur)
     pn3: sub bx,cx         ;следующий номер в регистрационном массиве
          add bx,0Ah        ;
          xor cx,cx
          inc dl            
          cmp dl,RegCur     ;все машины?
          jne pn2           ;переход если нет
          ;дальнейшая обработка идет с учетом того что искомого номера в рег. массиве нет 
     pn5: mov al,Mode
          cmp al,020h        ;режим="Регистрация"?
          jne  pn7           ;переход если нет
          cmp Key,0Ch       ;Enter?
          je pn1            ;переход если да
     pn7: mov NotReg,0FFh   ;взвод флага "Машина не зарегестрирована"
          jmp pn4
    pn1:   ;создание новой записи
          lea si,Nomer
          lea di,RegMas
          mov al,RegCur
          cmp al,099d        ;число зарегестрированных машин = максимальному?
          je pnmax 
          mov al,010d
          mul RegCur
          mov bx,ax     ;в bx находится адрес созданной записи
          xor cx,cx     ;обнуляем счетчик цифр
     pn6: push bx
          mov bx,cx
          mov al,[si+bx] ;читаем цифру искомого номера
          pop bx
          mov [di+bx],al ;записываем ее по адресу нового номера
          inc cx
          inc bx
          cmp cx,05h     ;все цифры?
          jne pn6        ;переход если нет
          xor al,al
          mov [di+bx],al  ;обнуляем кол-во ходок
          mov cl,RegCur
          mov NomCur,cl  ;сохраняем номер записи о машине в регистрационном массиве (для поиска)
          inc RegCur
          jmp pn4
   pnmax: mov al,0FFh
          mov CurErr,al   ;взвод флага ошибки учета машин
     pn4: ret
PersNomer ENDP
;-------------------------------------------------------------------------------------------
; Подмодуль ввода серии номера "+"
SeriesAdd PROC NEAR
          mov bl,CntLet
          lea si,Letter
          cmp bl,18
          jne sa1
          mov bl,0FFh
          mov CntLet,bl
     sa1: inc bl
          mov CntLet,bl
          xor bh,bh
          mov al,cs:[si+bx]
          mov [Nomer+4],bl       ;сохраняем номер буквы серии
          mov CntLet,bl
          ret
SeriesAdd ENDP
;-------------------------------------------------------------------------------------------
; Подмодуль ввода серии номера "-"
SeriesSub PROC NEAR
          mov bl,CntLet
          lea si,Letter
          cmp bl,0
          jne ss1
          mov bl,19
          mov CntLet,bl
     ss1: dec bl
          mov CntLet,bl
          xor bh,bh
          mov al,cs:[si+bx]
          mov [Nomer+4],bl       ;сохраняем номер буквы серии
          mov CntLet,bl
          ret
SeriesSub ENDP
;-------------------------------------------------------------------------------------------
; 7.1.2. Подмодуль удаления записи о введенном номере
Delet PROC
      cmp NotReg,0FFh ;номер существует
      je drt
      lea di,RegMas
      mov al,010d
      mul NomCur      ;NomCur - выходной праметр процедуры PersNomer (номер записи о номере)
      mov bx,ax       ;в bx находится адрес удаляемой записи
      mov Hlp,bx      ;Hlp=bx
      dec RegCur
      mul RegCur
      mov bx,ax       ;в bx находится адрес последней записи
      mov dx,bx       ;dx=bx
      mov cx,05h      ;счетчик слов
 dlt: mov bx,dx
      mov ax,word ptr[di+bx]
      mov bx,Hlp
      mov word ptr [di+bx],ax  ;переписали первое слово
      inc dx
      inc dx
      inc Hlp
      inc Hlp
      loop dlt
 drt: ret
Delet ENDP
;-------------------------------------------------------------------------------------------
; 7.1.1. Подмодуль сброса
Resett PROC
       mov dl,NMX
       cmp dl,020h
       jne r1
       lea si,Imp
       jmp r3
   r1: cmp dl,040h
       jne r2
       lea si,Exp
       jmp r3
   r2: lea si,Insk
   r3: xor ax,ax
       mov word ptr[si],ax
       mov word ptr[si+2],ax
       mov word ptr[si+4],ax
       mov word ptr[si+6],ax
       mov word ptr[si+8],ax
       ret
Resett ENDP
;-------------------------------------------------------------------------------------------
; 7.1.3. Подмодуль установки весов в ноль
Zero PROC
     mov ax,Real
     mov Base,ax
     mov Weight,0
ret
Zero ENDP
;-------------------------------------------------------------------------------------------
; 7.3. Подмодуль обработки режима "Прием/Отгрузка товара"
ModeNMX PROC
        mov al,NMX
        cmp al,020h
        je skl
        cmp al,040h
        je skl
        mov al,020h
        mov NMX,al
   skl: cmp EmpKbd,0FFh ;клавиатура пуста?
        jne mns         ;переход если нет
        ret             ;выход из процедуры
   mns: xor al,al
        mov ACP1,al      ;АЦП пассивен
        mov ACP2,al      ;АЦП пассивен
        mov al,Key
        cmp al,0Ah     ;нажат "Seria+"
        jne mn0np
        call SeriesAdd
        jmp mnret       ;выход из процедуры
 mn0np: mov al,Key
        cmp al,0Bh     ;нажат "Seria-"
        jne mn0ns
        call SeriesSub
        jmp mnret       ;выход из процедуры
 mn0ns: mov al,Key
        cmp al,0Ch          ;нажат "Enter"?
        je mnm1       
        jmp mn1             ;переход если нет
  mnm1: mov al,0FFh
        mov ACP2,al        ;АЦП активен
        mov ACP1,0
        call PersNomer      ;проверка на его наличие в массиве 
        mov al,NotReg   
        cmp al,0FFh         ;машина не зарегестрирована?
        jne mreg            ;переход если зарегестрирована
        jmp mnret                 ;выход из процедуры
  mreg: mov al,010d
        mul NomCur      ;NomCur - выходной праметр процедуры PersNomer (номер записи о номере)
        mov bx,ax       ;в bx находится адрес найденной записи
        add bx,05d      ;в bx находится смещение на количество ходок в найденной записи
        lea di,RegMas
        mov Hlp2,bx      ;сохраняем смещение на число ходок в Hlp2
        inc bx
        mov dx,[di+bx]   ;чтение веса из массива
        mov Hlp,dx       ;(Hlp=вес из массива)
        mov cl,Typt 
        xor ch,ch     
   ntc: shr cl,1
        inc ch
        cmp cl,0
        jne ntc
        shl ch,1        
        mov Hlp1,ch     ;в Hlp1 находится номер типа товара*2
        mov al,NMX
        cmp al,020h      ;включен режим "На склад"?
        jne mnn1
        mov dx,Weight    ;текущий вес
        mov ax,Hlp       ;вес из массива
        sub dx,ax        ;из текущего веса вычитаем вес в массиве 
        jns plus1        ;переход если результат положительный
        mov WghErr,0FFh  ;взвод флага ошибки веса и выход из процедуры
        jmp carry       
 plus1: mov ImpErr,0h    ;обнуление флага ошибки веса
        ;mov Weight,dx    
        xor bh,bh
        mov bl,Hlp1       ;bl=номер типа товара*2 
        mov ax,[Insk+bx]  ;чтение веса товара по типу на складе 
        add ax,dx         ;прибавляем к нему вес груза
        jnc nocarry       ;переход если вес не превышает максимального
        mov InsErr,0FFh   ;взвод флага ошибки веса и выход из процедуры
        jmp carry
nocarry:mov InsErr,0h     ;обнуление флага ошибки веса
        mov [Insk+bx],ax  ;запись суммы на складе
        mov ax,[Imp+bx]   ;чтение веса ввезенного товара по типу  
        add ax,dx         ;прибавляем к нему вес груза
        jnc ncr2
        mov ImpErr,0FFh   ;взвод флага ошибки веса и выход из процедуры
        jmp carry
  ncr2: mov [Imp+bx],ax   ;запись суммы ввезенного товара  
        mov bx,Hlp2
        inc [RegMas+bx]   ;инкремент числа ходок (если небыло ошибок) 
 carry: jmp mnret        ;выход из процедуры и выход из процедуры
  mnn1: mov al,NMX
        cmp al,040h      ;включен режим "Со склада"?
        jne mnn2
        mov ax,Weight    ;текущий вес
        mov dx,Hlp       ;вес из массива
        sub ax,dx        ;вычитаем из текущего веса вес в массиве
        cmp ax,0
        ja plus2          ;переход если результат положительный
        mov InsErr,0FFh   ;взвод флага ошибки веса и выход из процедуры
        jmp mnret       
plus2:  mov WghErr,0h    ;обнуление флага ошибки веса
        ;mov Weight,ax
        mov dx,ax         ; в dx вес груза
        xor bh,bh
        mov bl,Hlp1       ;загружаем номер типа товара
        mov ax,[Insk+bx]  ;чтение веса товара по типу на складе 
        sub ax,dx         ;вычитаем из него вес из массива
        ;cmp ax,0
        jns nonegat       ;переход если вес не отрицательный
        mov ExpErr,0FFh   ;взвод флага ощибки веса и выход из процедуры
        jmp mnret
nonegat:mov InsErr,0h    ;обнуление флага ошибки веса
        mov [Insk+bx],ax  ;запись суммы на складе
        mov ax,[Exp+bx]   ;чтение веса ввезенного товара по типу  
        add ax,dx         ;прибавляем к нему вес из массива
        jnc ncr3
        mov ExpErr,0FFh   ;взвод флага ошибки веса и выход из процедуры
        jmp carry
 ncr3:  mov [Exp+bx],ax   ;запись суммы ввезенного товара      
        mov bx,Hlp2
        inc [RegMas+bx]   ;инкремент числа ходок (если небыло ошибок) 
  mnn2:                   ;включен режим "На складе"?
        jmp mnret         ;выход из процедуры
        ;нажатие остальных клавиш приводит к выходу из процедуры(кроме Enter и цифр)
   mn1: mov al,Key
        cmp al,0Dh      ;нажат "Delete"?  
        jne mn2         ;переход если нет
        mov al,0FFh
        mov ACP1,al        ;АЦП активен
        mov ACP2,al        ;АЦП активен
        jmp mnret       ;выход из процедуры
   mn2: cmp al,0Eh      ;нажат "Reset"? 
        jne mn3         ;переход если нет
        mov al,0FFh
        mov ACP1,al        ;АЦП активен
        mov ACP2,al        ;АЦП активен
        jmp mnret       ;выход из процедуры
   mn3: cmp al,0Fh      ;нажат "View"
        jne mn4         ;переход если нет
        mov al,0FFh
        mov ACP1,al        ;АЦП активен
        mov ACP2,al        ;АЦП активен
        jmp mnret       ;выход из процедуры
   mn4: cmp al,010h      ;нажат "Zero"
        jne mn5          ;перход если нет
        mov al,0FFh
        mov ACP1,al        ;АЦП активен
        mov ACP2,al        ;АЦП активен
        jmp mnret       ;выход из процедуры
  mn5:  cmp al,011h    ;R1
        jne mn6
        mov al,020h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al      ;АЦП активен
        mov ACP2,al      ;АЦП активен
        jmp mnret
   mn6: cmp al,012h    ;R2
        jne mn7
        mov al,040h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al      ;АЦП активен
        mov ACP2,al      ;АЦП активен
        jmp mnret
   mn7: cmp al,013h    ;R3
        jne mnfin
        mov al,080h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al      ;АЦП активен
        mov ACP2,al      ;АЦП активен
        jmp mnret
        ;если ничего не нажато, то записываем очередную цифру в номер:
mnfin:  xor bh,bh
        mov bl,CntNom
        mov [Nomer+bx],al
        inc bl
        cmp bl,04h     ;счетчик цифр=4?
        jne mnc        ;переход если нет
        xor bl,bl      ;обнуление счетчика цифра 
  mnc:  mov CntNom,bl
mnret:  ret
ModeNMX ENDP
;-------------------------------------------------------------------------------------------
; 7.4. Подмодуль обработки режима "Просмотр состояния склада и выработки водителей"
ModeView PROC
        cmp EmpKbd,0FFh ;клавиатура пуста?
        jne mer         ;переход если нет
        jmp mwr         ;выход из процедуры
   mer: xor al,al
        mov ACP1,al      ;АЦП пассивен
        mov ACP2,al      ;АЦП пассивен
        mov al,Key
        cmp al,0Ah     ;нажат "Seria+"
        jne me0np
        call SeriesAdd
        jmp mwr        ;выход из процедуры
 me0np: mov al,Key
        cmp al,0Bh     ;нажат "Seria-"
        jne me0ns
        call SeriesSub
        jmp mwr        ;выход из процедуры
 me0ns:  mov al,Key
         cmp al,0Ch      ;нажат "Enter"
         jne mve2        ;переход если нет
         call PersNomer
         cmp NotReg,0FFh ;эта машина найдена?
         jne reg1        ;переход если да
         jmp mwr
   reg1: xor ah,ah
         mov al,010d
         mul NomCur      ;NomCur - выходной праметр процедуры PersNomer (номер записи о номере)
         mov bx,ax       ;в bx находится адрес найденной записи
         add bx,05d      ;в bx находится смещение на количество ходок в найденной записи
         lea di,RegMas
         mov al,[di+bx]  ;читаем число ходок
         xor ah,ah
         mov Weight,ax
        mov al,0FFh
        mov ACP2,al      ;окно АЦП активен
        xor al,al
        mov ACP1,al      ;АЦП пассивен
         call WghTrf
         call DispWgh
         jmp mwr          ;выход из процедуры         
   mve2: mov al,Key
         cmp al,0Fh        ;нажат "View"?
         je  mve31  
         jmp mve3          ;переход если нет
 mve31: mov al,0FFh
        mov ACP2,al      ;окно АЦП активен
        xor al,al
        mov ACP1,al      ;АЦП пассивен
        xor ch,ch          ;вычисляем номер типа товара
        mov cl,Typt      
   mvc: shr cl,1
        inc ch
        cmp cl,0
        jne mvc
        shl ch,1        
        mov Hlp1,ch     ;в Hlp1 находится номер типа товара*2
         mov dl,NMX
         cmp dl,020h       ;NMX=на склад?
         jne mv1           ;переход если нет
         xor bh,bh
         mov bl,Hlp1       ;тип товара
         mov ax,[Imp+bx]   ;вес ввезенного товара по типу
         mov Weight,ax
         call WghTrf
         call DispWgh
         jmp mwr
    mv1: mov dl,NMX
         cmp dl,040h        ;NMX=со склада?
         jne mv2
         xor bh,bh
         mov bl,Hlp1       ;тип товара
         mov ax,[Exp+bx]   ;вес вывезенного товара по типу
         mov Weight,ax
         call WghTrf
         call DispWgh
         jmp mwr
    mv2: mov dl,NMX
         cmp dl,080h        ;NMX=на складе
         jne mve3
         xor bh,bh
         mov bl,Hlp1       ;тип товара
         mov ax,[Insk+bx]  ;вес товара на складе по типу
         mov Weight,ax
         call WghTrf
         call DispWgh
         jmp mwr

  mve3: mov al,Key
        cmp al,0Dh
        je mwr
        cmp al,0Eh
        je mwr
        cmp al,010h
        je mwr
        cmp al,011h    ;R1
        jne mv6
        mov al,020h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al      ;АЦП активен
        mov ACP2,al      ;АЦП активен
        jmp mwr
   mv6: cmp al,012h    ;R2
        jne mv7
        mov al,040h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al      ;АЦП активен
        mov ACP2,al      ;АЦП активен
        jmp mwr
   mv7: cmp al,013h    ;R3
        jne mvfin
        mov al,080h
        mov Mode,al
        mov al,0FFh
        mov ACP1,al      ;АЦП активен
        mov ACP2,al      ;АЦП активен
        jmp mwr
 mvfin: xor bh,bh       ;если ничего не нажато
        mov bl,CntNom
        mov [Nomer+bx],al
        inc bl
        cmp bl,04h     ;счетчик цифр=4?
        jne mnw        ;переход если нет
        xor bl,bl      ;обнуление счетчика цифра 
  mnw:  mov CntNom,bl
        mov al,NMX
  mwr:  ret
ModeView ENDP
;-------------------------------------------------------------------------------------------
; 10. Подмодуль вывода номера и режимов на экран
OutputNomer PROC
            ;установка активности окна АЦП
            cmp ACP2,0FFh
            je opn1
            lea si,Digit
            lea di,Nomer
            xor bh,bh
            mov bl,[Nomer+0]
            mov ax,cs:[si+bx]
            out Ind4,ax
            mov bl,[Nomer+1]
            mov ax,cs:[si+bx]
            out Ind3,ax
            mov bl,[Nomer+2]
            mov ax,cs:[si+bx]
            out Ind2,ax
            mov bl,[Nomer+3]
            mov ax,cs:[si+bx]
            out Ind1,ax
            lea si,Letter
            mov bl,[Nomer+4]
            mov ax,cs:[si+bx]
            out Ind5,ax
            
            lea si,Digit
            mov bl,RegCur
            mov al,cs:[si+bx]
            out 012h,al
            mov bl,NomCur
            mov al,cs:[si+bx]
            out 014h,al
   opn1:    
            lea si,Digit
            mov bl,RegCur
            mov al,cs:[si+bx]
            out 012h,al
            mov bl,NomCur
            mov al,cs:[si+bx]
            out 014h,al
            mov al,Typt
            mov ah,NMX
            or  al,ah
            out DigIndT,al

            ret
OutputNomer ENDP
;-------------------------------------------------------------------------------------------

START:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы
             call FuncPrep
    Start1:  call ErMesOut
             call KbdInput
             call KbdContr
             call KeyTrf
             call ModInp
             call ACPInp
             call WghTrf
             call DispWgh
             call FormInf
             call OutputNomer
            
             jmp Start1

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
