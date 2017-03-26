;Файл вспомогательных процедур

MakeAddress proc
        mov ax,word ptr RealAddress
        mov dx,1111000000000000b
        and dx,ax
        shl ax,4
        add al,NextDig
        dec al
        mov word ptr RealAddress,ax
        mov word ptr RealAddress[2],dx
        ret
MakeAddress endp

;================================
MakeSize proc
        mov ax,CurSize
        shl ax,4
        mov dl,NextDig
        dec dl
        add al,dl
        mov CurSize,ax
        ret
MakeSize endp

;================================
MakeAutoVars proc               ;создание переменных
                                ;для автомотического режима

        cmp IntypeA,0           ;устанавливаем адрес ?
        jne MAV
        call MakeAddress        ;собираем адрес
        jmp exit

MAV:
        cmp Byte Ptr Intype,0FFh
        jne exit
        call MakeSize

exit:
        ret
MakeAutoVars endp

;================================
MakeMemData proc
        push es
        les di,RealAddress
        mov al,es:[di]
        shl al,4
        mov ah,NextDig
        dec ah
        add al,ah
        mov es:[di],al
        pop es
        ret
MakeMemData endp

;================================
MakeManualVars proc             ;создание переменных
                                ;для ручного режима
        cmp IntypeM,0;устанавливаем адрес ?
        jne @@MMV
        call MakeAddress        ;собираем адрес
        jmp @@exit

@@MMV:
        cmp IntypeM,0FFh
        jne @@exit
        call MakeMemData

@@exit:
        ret                     ;
MakeManualVars endp

;================================
ManualMake proc
        cmp Mode,0FFh
        je @@MM
        jmp @@exit
@@MM:
        cmp AddrInc,0FFh
        jne @@M1
        add word ptr RealAddress,1
        pushf
        mov ax,word ptr RealAddress[2]
        shr ax,12
        popf
        adc ax,0
        mov dx,ax
        lahf
        and ah,00001000b
        je @@move1                        ;если есть перенос всп.
        mov word ptr RealAddress[2],0
        jmp @@exit

@@move1:                          ;нет всп. переноса
        shl dx,12
        mov word ptr RealAddress[2],dx
        jmp @@exit
;========направление назад

@@M1:                                     ;направление назад
        sub  word ptr RealAddress,1
        pushf
        mov ax,word ptr RealAddress[2]
        shr ax,12
        popf
        sbb ax,0
        jnc @@MovHighPart
        mov word ptr RealAddress[2],0F000h
        jmp @@exit
@@MovHighPart:
        shl ax,12
        mov word ptr RealAddress[2],ax
@@exit:
        ret
ManualMake endp

;================================
TestProcessRAM proc                     ;процедура тестирования ОЗУ

@@UnPressWait:                          ;ожидание отжатия клавиш
        in al,OptionPort
        cmp al,0
        jne @@UnPressWait

        mov al,0
        out LampPort,al                 ;потушить лампочки

        cmp CurSize,0                   ;проверка размера проверяемой области
        jne @@NoE                       ;если размер >0 то переход к тесту

        mov ErrFlag,SizeErr             ;иначе действия при ошибке
        mov al,SizeErr
        call DannErrorProcess
        jmp @@exit
@@NoE:
        ;непосредственно операторы теста
        ;сначала проверка на правильность записи
        ;в ячейки памяти
        mov cx,CurSize                  ;длинна проверяемой области
        les di,RealAddress              ;загрузка адреса провряемой области
        mov si,word ptr Dir
@@TestLoop:
        mov dl,es:[di]                  ;сохраняем знячение ячейки памяти
        mov es:[di],byte ptr TestNumber1;запись первого тестового числа
        mov al,es:[di]                  ;считывание числа
        cmp al,TestNumber1              ;сравнение считанного числа с эталоном
        jne @@FindError                 ;если не совпало то ???
        mov es:[di],byte ptr TestNumber2;запись второго тестового числа
        mov al,es:[di]                  ;считывание числа
        cmp al,TestNumber2              ;сравнение
        jne @@FindError                 ;если не совпало то ???
@@ContinueTest:
        mov es:[di],dl                  ;если все хорошо то восстановление ЯП
        cmp si,1
        jne @@Bc
        add di,1
        jmp @@trim
@@Bc:
        sub di,1
@@trim:
        jnc @@Loop                      ;исли переполнение в смещении то
        mov ax,si
        shl ax,12
        push bx
        mov bx,es
        add ax,bx
        pop bx
        mov es,ax
                                        ;инкремент нормализованного сегмента
@@Loop:
        loop @@TestLoop                 ;зацикливание
        jmp @@NextTest                  ;переход на следующий тест

@@FindError:                            ;обработка ошибок

        mov word ptr DispAdr,di
        mov word ptr DispAdr[2],es
        push ax                         ;сохранить ax
        push si
        push es
        push cx
        push dx
        mov al,MemDBusErr               ;тип ошибки в al
        call DannErrorProcess           ;действия пользователя при ошибке
        cmp al,ContinueKey                      ;анализ действий
        jne @@exit11
        pop dx
        pop cx
        pop es
        pop si
        pop ax
        jmp @@ContinueTest
@@exit11:
        pop dx
        pop cx
        pop ax
        pop si
        pop ax
        jmp @@exit1
@@NextTest:                                     ;тест шины адреса
        call AdrBusTest
        call WalkingBitTest
@@exit:
        call DispOkResult
        mov ErrFlag,NoErr
@@exit1:
        ret                             ;выход
TestProcessRAM endp


TestProcessROM proc                     ;процедура тестирования ПЗУ

@@UnPressWait:                          ;ожидание отжатия клавиш
        in al,OptionPort
        cmp al,0
        jne @@UnPressWait

        mov al,0
        out LampPort,al                 ;потушить лампочки

        mov ax,Word Ptr CurSize         ;проверка размера проверяемой области
        or  ax,Word Ptr CurSize+2
        jz  @@NoE                       ;если размер >0 то переход к тесту

        mov ErrFlag,SizeErr             ;иначе действия при ошибке
        mov al,SizeErr
        call DannErrorProcess
        call CRCTest
@@NoE:
        ret                             ;выход
TestProcessROM endp

;================================
StopKey=10000000b                       ;кнопка Cтоп
ContinueKey=01000000b                   ;кнопка Продолжить
ErrorPort=11

DannErrorProcess proc                   ;действия при ошибках
                                        ;показать сообщение об ошибке

                                        ;обнуление массива отображения
        push bx                         ;сохранение bx
        lea bx,DispArray                ;в bx адрес массива отображения
        mov cx,7                        ;в cx длинна массива отображения
@@ZeroDisp:                             ;цикл обнуления
        mov [bx],byte ptr 0
        inc bx
        loop @@ZeroDisp
        pop bx                          ;восстановление bx

        push ax
        mov al,Map[14]
        mov DispArray[4],al
        mov al,MAp[16]
        mov DispArray[3],al
        mov DispArray[2],al
        mov al,Map[2]
        mov DispArray[1],al
        pop ax

        cmp al,SizeErr
        jne @@1
        push ax
        mov al,Map[1]
        mov DispArray[1],al             ;дописать ошибку
        pop ax
        call OutputDispArr
@@SE:
        in al,OptionPort
        cmp al,EnterKey
        jne @@SE
@@1:
        cmp al,MemDBusErr
        jne @@2
        call MakeAdr1
        call OutputDispArr
        mov al,1
        out ErrorPort,al
@@Wp:
        in al,OptionPort
        cmp al,ContinueKey
        jne @@3
@@WUp:                                  ;ожидание отжатия клавиши
        in al,OptionPort
        cmp al,0
        jne @@WUp
        mov al,ContinueKey
        jmp @@exit
@@3:
        cmp al,EnterKey
        jne @@Wp
        mov al,1
        jmp @@exit
@@2:
@@exit:
        push ax
        mov al,0
        out ErrorPort,al
        pop ax
        ret;
DannErrorProcess endp

;=========================================

MakeAdr1 proc
        push ax
        push bx
        push si
        push di
        push cx
        lea bx,map
        lea si,DispArray
        mov dx,word ptr DispAdr
        mov cx,4
MA1:
        mov ax,0Fh
        and ax,dx
        xlat
        mov [si],al
        shr dx,4
        inc si
        loop MA1

        mov ax,word ptr DispAdr[2]
        shr ax,12
        xlat
        mov [si],al
        inc si
        les di,DispAdr
        mov dl,es:[di]
        mov cx,2
MA2:
        mov al,0fh
        and al,dl
        xlat
        mov [si],al
        inc si
        loop MA2

        pop cx
        pop di
        pop si
        pop bx
        pop ax
        ret
MakeAdr1 endp

;=========================================
DispOkResult proc
        mov al,80H
        out LampPort,al                 ;высветить индикатор конца теста

DOR:                                    ;ожидание нажатия ввода
        in al,ModePort
        mov dx,ModePort
        call VibrDestr
        cmp al,10h
        jne DOR

        ret
DispOkResult endp

AdrBusTest proc
LOCAL   PassCount:BYTE

        mov  cx,Word Ptr CurSize
        mov  dx,Word Ptr CurSize+2
        mov  PassCount,1
@@ShiftNext:
        shr  dx,1
        rcr  cx,1
        inc  PassCount
        mov  ax,cx
        or   ax,dx
        jnz  @@ShiftNext

        mov  ch,PassCount
        push es                 ;сохранение es
        mov ax,0                ;
        mov es,ax               ;обнуление сегментного регистра
        mov di,0                ;загрузка адреса ячейки влияния
        stc
        lea si,TstBuf           ;загрузка адреса буфера
        mov cl,0                ;номер текущей ячеки влияния
@@1:                            ;идет запись в ячейки влияния
        mov al,es:[di]          ;считывание ячейки влияния
        mov [si],al             ;ее сохранение
        mov es:[di],cl          ;запись в ячейку влияния ее адреса
        inc cl                  ;инкремент номера ячейки влияния
        inc si                  ;модификация адреса буфера
        dec ch
        jz  @@WriteExit
        rcl di,1                ;модификация адреса ячейки
        or di,di                ;все ячеки ?
        jnz @@1                 ;переход если нет

        mov di,0                ;обнуление смещения
        mov ax,1000H            ;загрузка адреса ячейки влияния
@@2:
        mov es,ax               ;загрузка адреса ячейки влияния
        mov dl,es:[di]          ;считывание ячейки влияния
        mov [si],dl             ;сохранение ячейки влияния
        mov es:[di],cl          ;запись своего номера в ячейку влияния
        shl ax,1                ;модификация адреса ячейки влияния
        inc cl                  ;модификация номера ячейки влияния
        inc si                  ;модификация адреса буфера
        dec ch                  ;все ячеки ?
        jnz @@2                 ;переход если нет

@@WriteExit:
        ;проверка на правильность записанных номеров ячеек влияния
        mov ch,PassCount
        mov ax,0
        mov di,0
        mov es,ax               ;запись начального адреса ячеки влияния
        lea si,TstBuf           ;загрузка адреса буфера
        stc
        mov cl,0                ;загрузка счетчика
@@4:
                ;считывание ячеки влияния
        pushf
        cmp cl,es:[di]          ;содержимое = номеру
        jne @@AdrError          ;переход если нет
        popf
        mov al,[si]             ;считывание сохраненного значения ячеки
        mov es:[di],al          ;восстановление ячейки влияния
        rcl di,1
        inc si
        inc cl
        dec ch
        jz  @@ReadExit
        or di,di
        jnz @@4

        mov ax,1000h
@@5:
        mov es,ax
        mov dl,es:[di]
        pushf
        cmp cl,es:[di]
        jne @@AdrError
        popf
        mov dl,[si]
        mov es:[di],dl
        shl ax,1
        inc si
        inc cl
        dec ch
        jnz @@5
@@ReadExit:
@@myExit:
        pop es
        call DispOkResult
        jmp @@exit

@@AdrError:
        pop ax
        mov word ptr DispAdr[2],es
        mov word ptr DispAdr,di
        pop es
        mov al,AddrBusErrorBit
        out ErrorPort,al
        call MakeAdr1
        call OutPutDispArr
@@EE1:
        in al,OptionPort
        cmp al,EnterKey
        jnz @@EE1
        mov al,0
        out ErrorPort,al
        jmp @@exit1
@@exit:
@@exit1:
        ret
AdrBusTest endp


CalcCRC  proc
         push bx
         push cx
         push dx
         push es

         mov  ax,0                     ;ax = текущее значение CRC
         mov  es,ax
         mov  bx,ax                    ;es:bx = 0000:0000
         mov  cx,Word Ptr CurSize
         mov  dx,Word Ptr CurSize+2    ;dx:cx = объём тестируемой памяти
@@NextByte:
         add  al,Byte Ptr es:[bx]
         adc  ah,0                     ;ax = ax + Byte Ptr es:[bx]
         adc  ax,0                     ;прибавляем перенос к ax, т.к. сумма циклическая
         inc  bx
         jnz  @@IncOK
         mov  bx,es                    ;переходим к следующему сегменту
         add  bx,4096
         mov  es,bx
         xor  bx,bx
@@IncOK:
         loop @@NextByte
         dec  dx
         jnz  @@NextByte

         pop  es
         pop  dx
         pop  cx
         pop  bx
         ret
CalcCRC  endp


CRCTest  proc
         push cx
         push dx

         call CalcCRC                  ;посчитать CRC
         mov  dx,ax                    ;dx = исходная CRC
         mov  cx,CRCPassCount          ;количество проходов теста
@@NextPass:
         call CalcCRC                  ;посчитать CRC
         cmp  ax,dx                    ;сравнить с исходной CRC
         jnz  @@CRCError
         loop @@NextPass

         pop  dx
         pop  cx
         ret

@@CRCError:
         lea si,DispArray
         mov cx,7
         xor al,al
@@ClearNext:
         mov [si],al                   ;обнуляем массив отображения
         inc si
         loop @@ClearNext

         mov al,CRCErrorBit
         out ErrorPort,al              ;зажигаем светодиод ошибки ПЗУ
         call OutPutDispArr            ;обновляем содержимое индикаторов
@@EE1:
         in al,OptionPort
         cmp al,EnterKey               ;ждём реакции пользователя
         jnz @@EE1
         mov al,0
         out ErrorPort,al              ;гасим светодиод ошибки ПЗУ

         pop dx
         pop cx
         ret
CRCTest  endp

WalkBit  proc
         mov  al,1
         mov  ah,es:[bx]               ;ah = предыдущее содержимое ячейки
@@NextBit:
         mov  es:[bx],al
         cmp  al,es:[bx]
         jnz  @@WBError
         shl  al,1
         jnc  @@NextBit
         mov  es:[bx],ah               ;восстанавливаем содержимое ячейки

         xor  al,al                    ;ошибок нет
         ret

@@WBError:
         mov  al,1                     ;ошибка
         ret
WalkBit  endp


WalkingBitTest proc
         push bx
         push cx
         push dx
         push es

         mov  ax,0
         mov  es,ax
         mov  bx,ax
         mov  cx,Word Ptr CurSize
         mov  dx,Word Ptr CurSize+2    ;dx:cx = длина тестируемого блока
@@NextByte:
         call WalkBit                  ;проверка ячейки с адресом es:[bx]
         or   al,al                    ;если al<>0 то ошибка
         jnz  @@WBTError
         inc  bx
         jnz  @@IncOK
         mov  bx,es                    ;переходим к следующему сегменту
         add  bx,4096
         mov  es,bx
         xor  bx,bx
@@IncOK:
         loop @@NextByte
         dec  dx
         jnz  @@NextByte
@@Exit:
         pop  es
         pop  dx
         pop  cx
         pop  bx
         ret

@@WBTError:
         mov word ptr DispAdr[2],es
         mov word ptr DispAdr,bx
         mov al,DataBusErrorBit
         out ErrorPort,al
         call MakeAdr1
         call OutPutDispArr
@@EE1:
         in al,OptionPort
         cmp al,EnterKey
         jnz @@EE1
         mov al,0
         out ErrorPort,al
         jmp @@Exit

WalkingBitTest endp
