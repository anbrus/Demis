.286
data segment at 0BA00H
  Digits  db 10 dup (?)        ;цифры
  Error   db ?,?,?             ;ошибка - rrE
  Sign    db ?,?               ;индикаторы - минус, память занята

  ProcAdres1 dw 7 dup (?)      ; Адреса п.программ, откликающихся
  ProcAdres2 dw 7 dup (?)      ; на нажатие соответствующей клавиши
  ProcAdres3 dw 7 dup (?)

  Xnum db 9 dup (?)           ;переменная для ввода
  Ynum db 9 dup (?)           ;переменная для временного хранения
  MemNum db 9 dup (?)         ;ячейка памяти

  ForScreen db 9 dup (?)      ;образ экрана

  LastKeyInput db ?           ;для ликвидации "дребезга"

  Operation    db ?           ;выполняемая в дан. момент операция (кодирован)
  Errr         db ?           ;флаг - ошибка (переполнение)
  MemPresent   db ?           ;флаг - память занята
data ends

;-----------------------------------------------------------
  stack segment at 0BA80H
       dw 200h dup (?)
       StkTop label word
  stack ends
;-----------------------------------------------------------
;-----------------------------------------------------------
  code segment
   assume cs:code,ds:data
;-----------------------------------------------------------
  InitDigits proc
   ; Загрузка изображений цифр
         mov Digits[0],byte ptr 3Fh      ;0
         mov Digits[1],byte ptr 0Ch      ;1
         mov Digits[2],byte ptr 76h      ;2
         mov Digits[3],byte ptr 5Eh      ;3
         mov Digits[4],byte ptr 4Dh      ;4
         mov Digits[5],byte ptr 5Bh      ;5
         mov Digits[6],byte ptr 7Bh      ;6
         mov Digits[7],byte ptr 0Eh      ;7
         mov Digits[8],byte ptr 7Fh      ;8
         mov Digits[9],byte ptr 5Fh      ;9

         mov Error[0],byte ptr 60h       ; Сообщение об ошибке Err
         mov Error[1],byte ptr 60h
         mov Error[2],byte ptr 73h

         mov Sign[0],byte ptr 40h        ; Индикатор '-'
         mov Sign[1],byte ptr 07h        ; Индикатор 'Занята память'
      ret
  InitDigits endp
;-----------------------------------------------------------
  InitAdress proc
         mov ProcAdres1[0],Offset PresButton10  ; загрузка адресов п.программ,
         mov ProcAdres1[2],Offset PresButton11  ; которые вызываются при нажатии
         mov ProcAdres1[4],Offset PresButton12  ; соответствующей клавиши
         mov ProcAdres1[6],Offset PresButton13
         mov ProcAdres1[8],Offset PresButton14
         mov ProcAdres1[10],Offset PresButton15
         mov ProcAdres1[12],Offset PresButton16
         mov ProcAdres2[0],Offset PresButton20
         mov ProcAdres2[2],Offset PresButton21
         mov ProcAdres2[4],Offset PresButton22
         mov ProcAdres2[6],Offset PresButton23
         mov ProcAdres2[8],Offset PresButton24
         mov ProcAdres2[10],Offset PresButton25
         mov ProcAdres2[12],Offset PresButton26
         mov ProcAdres3[0],Offset PresButton30
         mov ProcAdres3[2],Offset PresButton31
         mov ProcAdres3[4],Offset PresButton32
         mov ProcAdres3[6],Offset PresButton33
         mov ProcAdres3[8],Offset PresButton34
         mov ProcAdres3[10],Offset PresButton35
         mov ProcAdres3[12],Offset PresButton36
         mov LastKeyInput,byte ptr 0    ;ранее кнопок не нажимали
      ret
  InitAdress endp
;-----------------------------------------------------------
  Summirovanie proc    ; [bx]:=[si]+[di] без учета знака (модули)
         push ax
         push si       ;сохранение регистров в стеке
         push di
         push bx

         add si,7
         add di,7
         add bx,7      ;начинаем с конца числа

         mov al,[si]   ;в al-первое слагаемое
         and al,0f0h
         mov dl,[di]   ;в dl-второе слагаемое
         and dl,0f0h
         add al,dl
         daa           ;коррекция BCD-сложения
         pushf         ;сохраняем возможный перенос
         mov dl,[si]
         mov dh,[di]
         and dl,0fh    ;учитываем возможное нахождение десятичной точки
         and dh,0fh
         or  dl,dh
         or  al,dl
         mov [bx],al

         mov cx,7       ;в цикле складываем оставшиеся цифры
sm1:     dec si
         dec di
         dec bx
         mov al,[si]
         mov dl,[di]
         popf
         adc al,dl
         daa
         mov [bx],al
         pushf
         loop sm1
         popf
         jnc sm8         ;при возникновении переноса из старшего разряда
         mov errr,byte ptr 1       ;переполнение

sm8:     pop bx
         pop di
         pop si      ;восстанавливаем сохраненные значения регистров из стека
         pop ax
      ret
  Summirovanie endp
;-----------------------------------------------------------
  Vichitanie proc ;[bx]:=[si]-[di]
         push ax
         push bx
         push si
         push di

         add si,7
         add di,7
         add bx,7   ;начинаем с конца числа

         mov al,[si]
         and al,0f0h
         mov dl,[di]
         and dl,0f0h
         sub al,dl
         das          ;коррекция BCD-вычитания
         pushf
         mov dl,[si]
         mov dh,[di]
         and dl,0fh
         and dh,0fh   ;учитываем возможность десятичной точки
         or  dl,dh
         or  al,dl
         mov [bx],al

         mov cx,7      ;вычитаем в цикле оставшися цифры с учетом заема
vc3:     dec si
         dec di
         dec bx
         mov al,[si]
         mov dl,[di]
         popf
         sbb al,dl
         das
         mov [bx],al
         pushf
         loop vc3
         popf
         jnc vc4     ;при возникновении заема из старшего разряда 
         mov errr,1   ;переполнение
         
vc4:     pop di
         pop si
         pop bx
         pop ax
      ret
  Vichitanie endp
;-----------------------------------------------------------
  Normalization proc   ;нормализация числа в [bx]
         push ax
         push bx

         mov si,bx
         mov di,bx
         mov cx,8
nr1:     mov al,[bx]      ;подсчитываем число значащих цифр целой части
         and al,0f0h
         jnz nr2
         dec cx
         mov al,[bx]
         and al,0fh
         jnz nr2
         inc bx
         loop nr1

nr2:     mov dl,cl    ; в dl-число цифр

         add si,7
         mov cx,7
         jmp nr5       ;подсчитываем число значащих цифр в дробной части
nr4:     mov al,[si]
         and al,0fh
         jnz nr6
         dec cx
nr5:     mov al,[si]
         and al,0f0h
         jnz nr6
         dec si
         loop nr4      ;результат - в cl

nr6:     cmp cl,0  
         je nr7
         cmp dl,0
         jne nr7      ;если в дробной части числа есть, а в целой - нет,
         inc dl       ;тогда ноль целой части считаем за цифру

nr7:     add dl,cl
         mov [di+8],dl ;записываем количество значящих цифр

         cmp dl,0
         jne nr8
         mov [di+7],byte ptr 0   ;убираем знак, если число равно 0

nr8:     pop bx
         pop ax
      ret
  Normalization endp
;-----------------------------------------------------------
  BolsheMenshe proc  ; Два числа [SI],[DI]  Возвратит [SI]>[DI]
                       ; al=0 -не меняли  al=1 - меняли
         push SI
         push DI

         mov cx,15

bm2:     mov al,[si]
         mov ah,[di]
         and al,0f0h     ;сравниваем цифры, пока одна не будет больше другой
         and ah,0f0h
         cmp al,ah
         jne bm1
         dec cx
         mov al,[si]
         mov ah,[di]
         and al,0fh
         and ah,0fh
         cmp al,ah
         jne bm1
         inc si
         inc di
         loop bm2
         jmp bme

bm1: ;если цифры не равны
         ja bme
         pop si  ;второе число больше первого, меняем местами индексы
         pop di  
         mov al,1
         ret
bme: ;первое число больше второго
         pop DI
         pop SI
         mov al,0
      ret
  BolsheMenshe endp
;-----------------------------------------------------------
  Sum proc     ; [BX]:=[SI]+[DI]
         mov al,[si+7]  ;проверяем знак первого числа
         and al,01h
         jz s1

       ;если первое слагаемое отрицательное
         mov al,[di+7]  ;проверяем знак второго числа
         and al,01h
         jz s3

       ;первое отрицательное, второе отрицательное
         Call Summirovanie
         or  [bx+7],byte ptr 1   ;знак -
         Call Normalization
      ret

s3: ;первое отрицательное, второе положительное
         Call BolsheMenshe
         Call Vichitanie
         cmp al,1
         jne ss1
         and [bx+7],byte ptr 0feh   ;если меняли местами числа
         Call Normalization
      ret
ss1:          ;если не меняли местами числа
         or [bx+7],byte ptr 1
         Call Normalization
      ret

       ;первое слагаемое положительное
s1:      mov al,[di+7]
         and al,01h
         jz s2

       ;первое положительное, второе отрицательное
         Call BolsheMenshe
         Call Vichitanie
         cmp al,1
         jne ss2
         or [bx+7],byte ptr 1   ;если меняли местами числа
         Call Normalization
      ret
ss2:   ;если не меняли местами числа
         and [bx+7],byte ptr 0feh
         Call Normalization
      ret

s2:;оба слагаемых положительные
         Call Summirovanie
         and [bx+7],byte ptr 0feh    ;знак +
         Call Normalization
      ret
  Sum endp
;-----------------------------------------------------------
  Minus proc   ;  [BX]:=[SI]-[DI]
         mov al,[si+7]  ;проверяем знак уменьшаемого
         and al,01h
         jz m1

       ;если первое - отрицательное
         mov al,[di+7]
         and al,01h
         jz m3

       ;первое отрицательное, второе отрицательное
         Call BolsheMenshe
         Call Vichitanie
         cmp al,1
         jne mm1
         and [bx+7],byte ptr 0feh   ;если меняли местами числа
         Call Normalization
      ret
mm1:    ;если не меняли местами числа
         or [bx+7],byte ptr 1
      ret

m3: ;первое отрицательное, второе положительное
         Call Summirovanie
         or  [bx+7],byte ptr 1   ;знак -
         Call Normalization
      ret
      
m1: ;первое положительное
         mov al,[di+7]
         and al,01h
         jz m2

  ;первое положительное, второе отрицательное
         Call Summirovanie
         and [bx+7],byte ptr 0feh    ;знак +
         Call Normalization
      ret

m2: ;оба положительные
         Call BolsheMenshe
         Call Vichitanie
         cmp al,1
         jne mm2
         or [bx+7],byte ptr 1   ;если меняли местами числа
         Call Normalization
      ret
mm2:     and [bx+7],byte ptr 0feh
         Call Normalization
      ret
  Minus endp
;-----------------------------------------------------------
  AddDigitXnum proc  ;добавление числа из al в конец числа Xnum
         xor si,si
         mov dl,Xnum[8]   ;число введенных цифр в dl
         cmp dl,0
         jne adx1

         mov Xnum[3],al  ;самая первая цифра числа
         jmp adx2

adx1:    ;если уже введено несколько цифр
         cmp dl,8
         jne adx0  ;если больше некуда
      ret
adx0:    mov bl,Xnum[7]
         and bl,2        ;проверяем, была ли введена десятичная точка
         jz  adx4

       ;поиск следующего места
         xor si,si
         mov dh,8
adxnxt1:
         mov bl,Xnum[si]
         and bl,0f0h
         jnz adx3
         dec dh
         mov bl,Xnum[si]
         and bl,0fh
         jnz adx3
         inc si
         dec dh
         jnz adxnxt1
         inc dh
adx3: ;в dh - число цифр целой части числа
         mov dl,Xnum[8]
         sub dl,dh         ;дополняем дробную часть числа
         inc dl          ;в dl - номер свободной цифры в дробной части числа
         mov cl,dl
         dec cl
         shr cl,1
         xor ch,ch
         mov si,4
         add si,cx
         shr dl,1
         jc adx5
         mov dl,Xnum[si]
         and dl,0f0h
         or dl,al
         mov Xnum[si],dl
         jmp adx2
adx5:
         shl al,4
         mov Xnum[si],al
         jmp adx2

adx4: ;дополняем целую часть числа
         mov cx,4
         mov si,3
adx6:    mov dl,Xnum[si]
         mov dh,dl
         shr dh,4
         shl dl,4
         or  dl,al
         mov Xnum[si],dl
         mov al,dh
         dec si
         loop adx6
adx2:
         inc byte ptr Xnum[8]
      ret
  AddDigitXnum endp
;-----------------------------------------------------------
  PressDigit proc   ;в dl- цифра, которую нажали
         mov al,Operation     ;анализ кода выполняемой операции
         shr al,1
         jc pb1              ;если после + или -

         mov al,Operation
         and al,8
         jz pb4

         xor si,si            ;обнуление числа
         mov ax,si
         mov cx,9
pb5:     mov Xnum[si],al
         inc si
         loop pb5
         mov Operation,byte ptr 0

pb4:     mov al,dl            ;ввод очередной цифры числа
         Call AddDigitXnum
         jmp pbe

pb1:     mov cx,9       ;очистка числа Xnum
         xor si,si
         mov ax,si
pb3:     mov Xnum[si],al
         inc si
         loop pb3

         mov al,dl      ;ввод очередной цифры числа
         Call AddDigitXnum

         mov al,Operation    ;изменение кода выполняемо операции
         and al,02h
         or  al,04h
         mov Operation,al
pbe:  ret
 PressDigit endp
;-----------------------------------------------------------
; реакции на нажатие соответствующих клавиш
  PresButton10 proc       ; С - Сброс
         mov cx,9
         xor si,si
         mov ax,si
n1:      mov Xnum[si],al       ;обнуление используемых переменных
         mov ForScreen[si],al
         mov Ynum[si],al
         mov Memnum[si],al
         inc si
         loop n1

         mov Errr, al           ;ошибки нет
         mov MemPresent, al    ;память свободна
         mov Operation, al     ;операция с кодом '0'
      ret
  PresButton10 endp
;-----------------------------------------------------------
  PresButton11 proc      ; ВП - Вызов Памяти
         mov cx,9
         xor si,si
pb111:   mov al,Memnum[si]   ;пересылка Memnum в Xnum
         mov Xnum[si],al
         inc si
         loop pb111

         mov al,Operation   ;изменение кода операции
         and al,0Ah
         or  al,08h
         mov Operation,al
      ret
  PresButton11 endp
;-----------------------------------------------------------
  PresButton12 proc      ; +/- - Смена знака числа
         mov al,Xnum[7]
         mov dl,al
         not al
         and al,01h
         and dl,0FEh
         or  al,dl
         mov Xnum[7],al
      ret
  PresButton12 endp
;-----------------------------------------------------------
  PresButton13 proc      ;  7
         mov dl,7
         Call PressDigit
         ret
  PresButton13 endp
;-----------------------------------------------------------
  PresButton14 proc      ;  4
         mov dl,4
         Call PressDigit
         ret
  PresButton14 endp
;-----------------------------------------------------------
  PresButton15 proc      ;  1
         mov dl,1
         Call PressDigit
         ret
  PresButton15 endp
;-----------------------------------------------------------
  PresButton16 proc      ;  0
         mov al,Operation     ;анализ кода выполняемой операции
         shr al,1
         jc  pb161

         mov al,Operation
         and al,8
         jz pb165

         xor si,si            ;обнуление числа
         mov ax,si
         mov cx,9
pb166:   mov Xnum[si],al
         inc si
         loop pb166
         mov Operation,0

pb165:   mov al,Xnum[8]
         cmp al,0
         jne pb
         mov Xnum[8],1    ;первый раз нажали 0
      ret
pb:      cmp al,1
         je pb162
pb164:   xor al,al
         Call AddDigitXnum
      ret
pb162:   ;если введена одна цифра
         mov al,Xnum[7]
         and al,2
         jnz pb164     ;проверка введена ли точка

         mov al,Xnum[3]
         and al,0fh
         jnz pb164
      ret
pb161:    ;после нажатия + или -
         mov cx,9       ;очистка числа Xnum
         xor si,si
         mov ax,si
pb163:   mov Xnum[si],al
         inc si
         loop pb163

         mov Xnum[8],byte ptr 1
         mov al,Operation    ;изменение кода выполняемой операции
         and al,02h
         or  al,04h
         mov Operation,al
      ret
  PresButton16 endp
;-----------------------------------------------------------
  PresButton20 proc      ;  СЭ - Сброс содержимого Экрана
         mov cx,9
         xor si,si
         mov ax,si
bp201:   mov Xnum[si],al     ;обнуление Xnum
         inc si
         loop bp201
      ret
  PresButton20 endp
;-----------------------------------------------------------
  PresButton21 proc      ;  П-  - Вычесть из памяти содержимое экрана
         mov si,offset Memnum
         mov di,offset Xnum
         mov bx,offset Memnum
         Call minus
         or  Operation,byte ptr 8
         xor si,si
         mov cx,8
pb211:   mov al,Memnum[si]
         cmp al,0
         jne pb212
         inc si
         loop pb211
         mov MemPresent,byte ptr 0
         mov Memnum[7],byte ptr 0
      ret
pb212:   mov MemPresent,1
      ret
  PresButton21 endp
;-----------------------------------------------------------
  PresButton22 proc      ;  - -операция вычитания
         mov al,Operation
         shr al,1
         jc pb221            ;если еще не вводили второго операнда

         shr al,1
         shr al,1
         jnc pb222
      ;если нажали не первый раз после ввода
         mov al,Operation
         shr al,1
         shr al,1
         jc pb224
              ;после операции +
         mov si,offset xnum
         mov di,offset ynum
         mov bx,offset xnum
         call sum
         mov Operation,8  ;флаг - обнулить при вводе следующего числа
         jmp pb222

pb224:    ;после операции -
         mov si,offset ynum
         mov di,offset xnum
         mov bx,offset xnum
         call minus
         mov Operation,8  ;флаг - обнулить при вводе следующего числа

pb222:    ;первый раз нажали -
         xor si,si
         mov cx,9
pb223:   mov al,Xnum[si]    ;пересылка Xnum в Ynum
         mov Ynum[si],al
         inc si
         loop pb223
         
pb221:   mov al,Operation
         and al,8
         or al,11
         mov Operation,al    ;взвод флага - выполнение операции -
      ret
  PresButton22 endp
;-----------------------------------------------------------
  PresButton23 proc      ;  8
         mov dl,8
         Call PressDigit
      ret
  PresButton23 endp
;-----------------------------------------------------------
  PresButton24 proc      ;  5
         mov dl,5
         Call PressDigit
      ret
  PresButton24 endp
;-----------------------------------------------------------
  PresButton25 proc      ;  2
         mov dl,2
         Call PressDigit
      ret
  PresButton25 endp
;-----------------------------------------------------------
  PresButton26 proc      ;  .  - десятичная точка
         mov al,Operation     ;анализ кода выполняемой операции
         shr al,1
         jc  pb261

         mov al,Operation
         and al,8
         jz pb264

         xor si,si            ;обнуление числа
         mov ax,si
         mov cx,9
pb265:   mov Xnum[si],al
         inc si
         loop pb265
         mov Operation,0

pb264:   mov al,Xnum[7]
         and al,2
         jnz pb262
         or  Xnum[7],byte ptr 2     ;ставим точку
         mov al,Xnum[8]    ;количество введенных цифр
         cmp al,0
         jne pb262
         mov Xnum[8],byte ptr 1
pb262:   ret

pb261: ;если после + или -
         mov cx,9       ;очистка числа Xnum
         xor si,si
         mov ax,si
pb263:   mov Xnum[si],al
         inc si
         loop pb263

         or Xnum[7],byte ptr 02h    ;ставим точку
         mov Xnum[8],byte ptr 1

         mov al,Operation    ;изменение кода выполняемой операции
         and al,02h
         or  al,04h
         mov Operation,al
      ret
  PresButton26 endp
;-----------------------------------------------------------
  PresButton30 proc      ;  СП - Сброс содержимого Памяти
         mov cx,9
         xor si,si
         mov ax,si
bp301:   mov Memnum[si],al     ;обнуление Memnum
         inc si
         loop bp301
         mov MemPresent,al
      ret
  PresButton30 endp
;-----------------------------------------------------------
  PresButton31 proc      ;  П+  - Сложить с Памятью содержимое экрана
         mov si,offset Memnum
         mov di,offset Xnum
         mov bx,offset Memnum
         Call sum
         or  Operation,byte ptr 8
         xor si,si
         mov cx,8
pb311:   mov al,Memnum[si]
         cmp al,ch
         jne pb312
         inc si
         loop pb311
         mov MemPresent,0
         mov Memnum[8],byte ptr 0
      ret
pb312:   mov MemPresent,1
      ret
  PresButton31 endp
;-----------------------------------------------------------
  PresButton32 proc      ;  +  -операция сложения
         mov al,Operation
         shr al,1
         jc pb321            ;если еще не вводили второго операнда

         shr al,2
         jnc pb322
                  ;если нажали не первый раз после ввода
         mov al,Operation
         shr al,2
         jc pb324
              ;после операции +
         mov si,offset xnum
         mov di,offset ynum
         mov bx,offset xnum
         call sum
         mov Operation,8  ;флаг - обнулить при вводе следующего числа
         jmp pb322

pb324:    ;после операции -
         mov si,offset ynum
         mov di,offset xnum
         mov bx,offset xnum
         call minus
         mov Operation,8  ;флаг - обнулить при вводе следующего числа

pb322:  ;первый раз нажали +
         xor si,si
         mov cx,9
pb323:   mov al,Xnum[si]    ;пересылка Xnum в Ynum
         mov Ynum[si],al
         inc si
         loop pb323
pb321:   mov al,Operation
         and al,8
         or al,01
         mov Operation,al    ;взвод флага - выполнение операции +
      ret
  PresButton32 endp
;-----------------------------------------------------------
  PresButton33 proc      ;  9
         mov dl,9
         Call PressDigit
      ret
  PresButton33 endp
;-----------------------------------------------------------
  PresButton34 proc      ;  6
         mov dl,6
         Call PressDigit
      ret
  PresButton34 endp
;-----------------------------------------------------------
  PresButton35 proc      ;  3
         mov dl,3
         Call PressDigit
      ret
  PresButton35 endp
;-----------------------------------------------------------
  PresButton36 proc      ;  =
         mov al,Operation
         shr al,1
         jnc pb361
         
pb365:   shr al,1
         jc pb362
       ;сложение
         mov si,offset Xnum
         mov di,offset Ynum

         mov bx,offset Xnum
         call sum
         jmp pb363
pb362: ;вычитание
         mov si,offset Ynum
         mov di,offset Xnum
         mov bx,offset Xnum
         Call minus
pb363:   mov al,08h
         mov Operation,al
pb361:   shr al,2
         jnc pb364

         mov al,Operation
         shr al,1
         jmp pb365

pb364:   mov Operation,08h
      ret
  PresButton36 endp
;-----------------------------------------------------------
  ReadKey proc  ;чтение нажатой клавиши, результат в AH,AL
rep1:    xor ah,ah        ;обнуляем
         in al,00         ; опрос нулевого столбца
         cmp al,00
         je RK1              ;если ничего не ввели
         cmp al,LastKeyInput ;
         jne RKE             ;если нажали новую клавишу
         jmp rep1            ;если все еще нажата та же клавиша

RK1:     inc ah              ;следующий столбец
         in al,01
         cmp al,00
         je RK2
         cmp al,LastKeyInput
         jne RKE
         jmp rep1

RK2:     inc ah              ;следующий столбец
         in al,02
         cmp al,00
         je RK3
         cmp al,LastKeyInput
         jne RKE
         jmp rep1

RK3:     mov LastKeyInput,byte ptr 00   ;если ничего не нажато
         jmp rep1
RKE:     mov LastKeyInput,al
      ret
  ReadKey endp
;-----------------------------------------------------------
;Определение номера клавиши в bin-коде вместо позиционного
;результат - в SI (умножен на 2)
  DefineNumButton proc
         xor cx,cx
DNB1:    inc cl
         shr al,1
         jnc DNB1
         dec cl
         shl cl,1
         mov si,cx
      ret
  DefineNumButton endp
;-----------------------------------------------------------
  DefineAddress proc     ;исходные - AH,SI, результат - AX
         cmp ah,02h
         jne DA1
         mov bx,Offset ProcAdres3
         mov ax,[bx+si]
      ret
DA1:     cmp ah,01h
         jne DA0
         mov bx,Offset ProcAdres2
         mov ax,[bx+si]
      ret
DA0:     mov bx,Offset ProcAdres1
         mov ax,[bx+si]
      ret
  DefineAddress endp
;-----------------------------------------------------------
  Zatalk proc   ;вспомогательная процедура к FormScreen
      ; 'заталкивание' из al в ForScreen со сдвигом содержимого
         push dx
         push cx
         push si
         mov cx,8
         mov si,0
Zat1:    mov dl,ForScreen[si]
         mov ForScreen[si],al
         mov al,dl
         inc si
         loop Zat1
         pop si
         pop cx
         pop dx
      ret
  Zatalk endp
;-----------------------------------------------------------
  FormScreen proc  ;формирование ForScreen на основе Xnum
         cmp errr,0
         je fsb       ; если нет ошибки - на обработку числа

         xor si,si
         mov cx,3
fs1:     mov al,Error[si]          ;запись сообщения Err
         mov ForScreen[si],al
         inc si
         loop fs1
         mov cx,6
         xor al,al               ;заполнение нолями остального
fs2:     mov ForScreen[si],al
         inc si
         loop fs2
         jmp fsm                ;на проверку наличия памяти

fsb:   ;обработка числа
         mov cx,9
         xor ax,ax
         mov si,ax
fs3:     mov ForScreen[si],al    ;предварительная очистка ForScreen
         inc si
         loop fs3

         mov dl,Xnum[8]        ;в dl - сколько цифр введено в числе
         cmp dl,0
         jne fs0

         mov al,Digits[0]
         or  al,80h
         mov ForScreen[0],al   ;запись 0.
         jmp fszn

fs0: ;обработка целой части числа
         xor si,si
         mov cx,8

fsnxt1:  mov al,Xnum[si] ; обработка старшей цифры-BCD очередного байта
         shr al,4
         jnz fs4
         dec cx
               ;пропускаем первый ноль
         mov al,Xnum[si] ; обработка младшей цифры-BCD очередного байта
         and al,0fh
         jnz fs5
         inc si  ;пропускаем первый ноль
         loop fsnxt1

         mov al,Digits[0]     ;целая часть числа равна 0
         or  al,80h
         mov ForScreen[0],al
         mov cx,9
         dec dl
         jz fszn

fs4:     mov al,Xnum[si]
         shr al,4
         xor ah,ah
         mov di,ax
         mov al,Digits[di]
         Call Zatalk   ;старшая цифра очередного байта BCD
         dec cx
         dec dl
         jz fszn

fs5:     mov al,Xnum[si]
         and al,0fh
         xor ah,ah
         mov di,ax
         mov al,Digits[di]
         Call Zatalk   ;младшая цифра очередного байта BCD
         dec cx
         jnz fs6

         mov al,ForScreen[0]  ;добавляем точку
         or  al,80h
         mov ForScreen[0],al

fs6:     dec dl
         jz fszn
         inc si
         jmp fs4

fszn:    mov al,Xnum[7]       ;обработка знака числа
         and al,01h
         jz fsm
         mov al,Sign[0]
         mov ForScreen[8],al

fsm:     cmp MemPresent,0            ;проверка наличия памяти
         mov al,Sign[1]
         je fs7
         or ForScreen[8],al
      ret
fs7:  ;память не занята
         not al
         and ForScreen[8],al
      ret
  FormScreen endp
;-----------------------------------------------------------
  OutOnScreen proc   ;вывод на экран содержимого строки ForScreen
         xor dx,dx
         mov si,dx
oos1:    mov al,ForScreen[si]
         out dx,al
         inc dx
         inc si
         cmp dx,9
         jne oos1
      ret
  OutOnScreen endp
;-----------------------------------------------------------
;Макроуровень
begin:
         mov ax,data               ;загрузка сегментных регистров
         mov ds,ax
         mov ax,stack
         mov ss,ax
         mov sp,offset StkTop

         Call InitDigits          ;подготовка
         Call InitAdress
         Call PresButton10        ; "сброс"
         Call FormScreen
         Call OutOnScreen

Repeat:
         Call ReadKey             ;ждем нажатия клавиши (рез-т в AH,AL)
         Call DefineNumButton     ;определение номера нажатой клавиши (рез-т в AH,SI)
         Call DefineAddress       ;формирование адреса процедуры обработки
         Call ax                  ;обработка нажатой клавиши в  PresButton##

         Call FormScreen          ;формирование образа экрана на основе Xnum
         Call OutOnScreen         ;вывод на индикацию

         jmp Repeat

         org 07F0H
start:   jmp begin

code ends
end start