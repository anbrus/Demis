;Основной файл программы
LOCALS
PAGE 80,132

KbdPort=0FFh-1                         ;Адреса портов
ModePort=0FFh-2                        ;архитектуры
LampPort=0FFh-4                        ;ввода/вывода
OptionPort=ModePort
SegPort=0FFh-8                         ;сегментов
IndPort=0FFh-16                        ;индикаторов
NMAX=50                                ;Константа подавления дребезга
CRCPassCount=4                         ;число проходов теста CRC
DataBusErrorBit=2                      ;бит, отвечающий за светодиод ошибки по ШД
CRCErrorBit=1                          ;бит, отвечающий за светодиод ошибки CRC
AddrBusErrorBit=4                      ;бит, отвечающий за светодиод ошибки по ША
NoErr=0                                ;нет ошибки
SizeErr=1                              ;ошибка размера
MemDBusErr=2                           ;ошибка по ШД
TestNumber1=55h                        ;тестовое число: 01010101
TestNumber2=0AAh                       ;тестовое число: 10101010
EnterKey=16                            ;код клавиши выхода из состояния ошибки

;==============================
data segment at 08000H
        Map               db 17 dup (?) ;Карта преобразования
        InTypeA           db ?
        InTypeM           db ?
        Mode              db ?  ;Режим
        Setup             db ?  ;Тип ввода
        AddrInc           db ?
        AddrDec           db ?
        Dir               db ?
        RealAddress       DD ?
        CurSize           dw ?
        DispArray         db 7 dup(?) ;строка для преобразования
        ErrFlag           db ?
        KeepFlag          dw ?
        KeepEs            dw ?
        DispAdr           dd ?
        TstBuf            db 20 dup(?)  ;массив хранения ячеек влияния
        KbdErr            db ?
        EmpKbd            db ?
        Memory            db ?
        MesBuf            db ?
        NextDig           db ?
        KbdImage          db 4 dup (?)
        InType            db ?
data ends

;=========================
stk segment at 08100H
  dw 100H dup (?)
  StkTop label word
stk ends

;==============================
code segment
assume cs:code,ds:data,ss:stk
include progsl.asm

;================================
Prepare proc                    ;Подготовка данных
                                ;Инициализация карты преобразования
        mov Map[0], 03H
        mov Map[1], 9Fh
        mov Map[2], 25h
        mov Map[3], 0Dh
        mov Map[4], 99H
        mov Map[5], 49H
        mov Map[6], 41H
        mov Map[7], 1FH
        mov Map[8], 01H
        mov Map[9], 09H
        mov Map[10], 11H
        mov Map[11], 0C1H
        mov Map[12], 63H
        mov Map[13], 85H
        mov Map[14], 61H
        mov Map[15], 71H


        mov Mode,0              ;режим автоматический
        mov IntypeA,0           ;тип ввода начальный адрес
        mov IntypeM,0           ;тип ввода адрес
        mov memory,0            ;тестируется ОЗУ
        mov word ptr RealAddress,00000h
        mov word ptr RealAddress[2],00000h
        mov CurSize,10
        mov al,AddrInc
        mov Dir,al
        mov ErrFlag,0
        mov KbdErr,0

        ret                     ;выход
Prepare endp

;=============================
ModeInput proc                  ;ввод режимов
        cmp ErrFlag,0           ;проверка ошибок
        je @@NoE
        jmp @@exit
@@Noe:
        in al,ModePort
        mov dx,ModePort
        call VibrDestr
        test al,01h             ;проверка на установку режимов
        jne @@exit
        mov Mode,0FFh
@@exit:
        ret                     ;выход
ModeInput endp

;============================
SetupInput proc                 ;ввод типа ввода
        cmp ErrFlag,0           ;проверка ошибок
        je @@NoE
        jmp @@exit
@@Noe:
        in al,KbdPort
        mov dx,KbdPort
        call VibrDestr
        test al,40h              ;тип ввода - начальный адрес
        jne @@SI1
        mov IntypeA,0
        jmp @@exit
@@SI1:
        test al,20h              ;тип ввода - размер
        jne @@SI2
        mov IntypeA,0FFh
        jmp @@exit
@@SI2:
        test al,80h              ;тип ввода  - адрес
        jne @@SI3
        mov IntypeM,0

@@SI3:
        test al,10h              ;тип ввода - данные
        mov IntypeM,0FFh
@@exit:
        ret                     ;выход
SetupInput endp

;=============================
DirInput proc                   ;ввод напраления
        cmp ErrFlag,0           ;проверка ошибок
        je @@NoE
        jmp @@exit
@@Noe:

        in al,ModePort
        mov dx,ModePort
        call VibrDestr
        test al,02h
        jne @@DI1
        mov AddrInc,0FFh
        call ManualMake
        jmp @@exit
@@DI1:
        test al,04h
        jne @@exit
        mov AddrDec,0FFh
        call ManualMake
@@exit:
        ret                     ;выход
DirInput endp
;=============================
VibrDestr Proc
VD1:    mov ah,al       ;сохранение исходного состояния
        mov bh,0        ;сброс счетчика повторений
VD2:    in al,dx        ;ввод текущего состояния
        cmp ah,al       ;текущее состояние = исходному
        jne VD1         ;переход, если нет
        inc bh          ;инкремент счетчика повторений
        cmp bh,NMAX     ;конец дребезга
        jne VD2         ;переход, если нет
        mov al,ah       ;восстановление местоположения данных
        ret
VibrDestr endp
;=============================
KbdInput Proc Near               ;ввод с клавиатуры
         lea si,KbdImage         ;загрузка адреса,
         mov cx,length KbdImage  ;счетчика циклов и
         mov bl,0FEh             ;номера исходной строки
KI4:     mov al,bl               ;выбор строки
         and al,3Fh              ;объединение номера с
         or  al,MesBuf           ;сообщением "Тип ввода"
         out KbdPort,al          ;активация строки
         in  al,KbdPort          ;ввод строки
         and al,0Fh              ;включено ?
         cmp al,0Fh
         jz  KI1                 ;переход, если нет
         mov dx,KbdPort          ;передача параметров
         call VibrDestr          ;гашение дребезга
         mov [si],al             ;запись строки
KI2:     in  al,KbdPort          ;ввод строки
         and al,0Fh              ;выключено ?
         cmp al,0Fh
         jnz KI2                 ;переход, если нет
         call VibrDestr          ;гашение дребезга
         jmp Short KI3
KI1:     mov [si],al             ;запись строки
KI3:     inc si                  ;модификация адреса
         rol bl,1                ;и номера строки
         loop KI4                ;все строки? Переход,если нет
         ret
KbdInput endp
;============================
KbdInContr proc near             ;контроль ввода с клавиатуры

         lea bx,KbdImage         ;загрузка адресов и
         mov cx,4                ;счетчика строк
         mov EmpKbd,0
         mov KbdErr,0
         mov dl,0
KIC2:    mov al,[bx]             ;чтение строки
         mov ah,4
KIC1:    shr al,1                ;выделение бита
         cmc
         adc dl,0
         dec ah                  ;все биты в строке?
         jnz KIC1
         inc bx
         loop KIC2
         cmp dl,0
         jz  KIC4
         mov KbdErr,0FFh
         jmp short KIC4
KIC3:    mov EmpKbd, 0FFh
KIC4:    ret
KbdInContr endp
;=========================
NxtDigTrf proc near              ;преобразование очередной цифры
         cmp EmpKbd,0ffH
         jz  NDT1
         cmp KbdErr,0FFh
         jz  NDT1
         lea bx,KbdImage         ;загрузка адреса
         mov dx,0                ;очистка накопителей кода строки и столбца
NDT3:    mov al,[bx]             ;чтение строки
         and al,0Fh
         cmp al,0Fh
         jnz NDT2
         inc dh
         inc bh
         jmp short NDT3
NDT2:    shr al,1                ;выделение бита строки
         jnc NDT4
         inc dl
         jmp short NDT2
NDT4:    mov cl,2                ;формирование двоичного
         shl dh,cl               ;кода строки
         or  dh,dl
         mov NextDig,dh
NDT1:    ret
NxtDigTrf endp
;=============================
MakeData proc                   ;Подготовка данных
        mov al,KbdErr
        or ErrFlag,0    ;проверка ошибок
        jnz @@exit
        cmp EmpKbd,0FFh
        jne @@AutoSetup
        cmp AddrInc,0FFh
        jne @@MD1
        add Word Ptr RealAddress,1
        adc Word Ptr RealAddress+2,0
        jmp @@Noe
@@MD1:  cmp AddrDec,0FFh
        jne @@exit
        sub Word Ptr RealAddress,1
        sbb Word Ptr RealAddress+2,0
@@Noe:
        cmp Mode,0
        je @@AutoSetup
        jmp @@MD2
@@AutoSetup:
        call MakeAutoVars
        jmp @@exit
@@MD2:
        call MakeManualVars
@@exit:
        ret
MakeData endp

;=============================
MakeDispArr proc                ;Формирование массива отображения
        mov cx,Length DispArray ;в CX длинну массива отображения
        lea si,DispArray        ;в SI адресс массива отображения
@@l1:
        mov byte ptr [si],0
        inc si
        loop @@l1               ;обнуление массива отображеия

        mov cx,Length DispArray ;в CX длинну массива отображения
        lea si,DispArray        ;в SI адресс массива отображения
        lea bx,Map              ;в BX адрес карты преобразования

        cmp Mode,0      ;проверка установленного режима
        je MDA1         ;если режим автоматический
        jmp MDA2        ;если ручной
MDA1:
        cmp Byte Ptr Intype,0    ;тип ввода - адрес ?
        jne MDA3        ;вводим размер
MAdr:                           ;вводим адрес
        mov dx,word ptr RealAddress;в DX младшую часть адреса
        mov cx,4                ;загрузка счетчика для преобразования
MDAl2:                          ;цикл преобразования
        mov ax,1111b
        and ax,dx
        xlat
        mov [si],al
        inc si
        shr dx,4
        loop MDAl2
        mov ax,word ptr RealAddress[2];в AX старшую часть адреса
        shr ax,12
        xlat
        mov [si],al                     ;составляем массив отображения
                                        ;для адреса
        jmp exit
MDA3:
        mov dx,CurSize                  ;для размера
        mov cx,4
MDAl3:
        mov ax,1111b
        and ax,dx
        xlat
        mov [si],al
        inc si
        shr dx,4
        loop MDAl3

        jmp exit
;ручной режим
MDA2:
        push ds
        lds si,RealAddress
        mov dl,[si]
        pop ds

        lea si,DispArray
        lea bx,Map
        Add si,5
        mov al,0fh
        and al,dl
        xlat
        mov [si],al
        shr dl,4
        mov al,dl
        xlat
        inc si
        mov [si],al
        lea si,DispArray
        jmp MAdr

@@exit:
        ret
MakeDispArr endp

;=============================
OutputDispArr proc              ;Вывод массива отображения на дисплей
        mov al,KbdErr
        or  al,al
        jnz @@exit
        mov cx,Length DispArray ; в CX длинну масива лтображения
        lea si,DispArray        ; в SI адрес массива отображения
        mov al,11111110b
ODA1:
                        ;цикл вывода в порты вывода
        mov al,[si]
        out IndPort,al
        xchg ah,al
        out SegPort,al
        xchg ah,al
        rcl si,1
        inc si
        loop ODA1
@@exit:
        ret                     ;выход
OutputDispArr endp

;=============================
LampOutput proc               ;зажигание лампочек
        mov al,20h
        cmp Mode,0
        jne LO1
        or  al,0Fh
        out LampPort,al
        jmp SizeAddr
LO1:
        mov al,10h
        or al,0Fh
        out LampPort,al
        jmp DanAddr
SizeAddr:
        mov al,40h
        cmp InTypeA,0
        je  KbdOut
        mov al,20h
        jmp KbdOut
DanAddr:
        mov al,80h
        cmp InTypeM,0
        je  KbdOut
        mov al,10h
KbdOut:
        mov MesBuf,al
        or al,0FFh
        out KbdPort,al
        ret
LampOutPut endp

;===================================
TestProgress proc               ;тестирование
        cmp Mode,0
        je  @@Noe
        jmp @@exit
@@NoE:
        in al,ModePort
        mov dx,ModePort
        call VibrDestr
        test al,20h
        jnz @@TP1
        mov memory,0FFh
        call TestProcessROM
        jne @@exit
@@TP1:  call TestProcessRAM
@@exit:
        ret                     ;выход
TestProgress endp

;===================================
begin:
        mov ax,data
        mov ds,ax

        mov ax,stk
        mov ss,ax
        mov sp,offset StkTop
        call Prepare
MainProgramLoop:
        ;==================
        call ModeInput          ;ввод режимов
        call SetupInput         ;ввод типа ввода
        call DirInput           ;ввод напраления
        ;==================
        call KbdInput           ;ввод с клавиатуры
        call KbdInContr         ;контроль ввода с клавиатуры
        call NxtDigTrf          ;преобразование очередной цифры
        call MakeData           ;подготовка данных
        call MakeDispArr        ;формирование массива отображения
        call OutputDispArr      ;вывод массива отображения на дисплей
        call TestProgress       ;процедура тестирования
        call LampOutput         ;зажигание лампочек
        ;==================
        jmp MainProgramLoop
       org 07F0H
start: jmp begin
code ends
end start


