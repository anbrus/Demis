RomSize    EQU   4096
NMax       EQU   50
KbdPort    EQU   0
DispPort   EQU   1
DispPort2  EQU   2
Stk        SEGMENT AT 100h
           DW    10 DUP    (?)
StkTop     LABEL WORD
Stk        ENDS
Date       STRUC
           Poj   db         ?
           Pro   db         ?
           Sig   db         ? 
Date       ENDS
Data       SEGMENT AT 0
           KbdImage   DW    2 DUP(?)
           EmpKbd     DB    ?
           KbdErr     DB    ?
           DigCode    DB    ?
           Home       DB    ?       
           Flag       DB    ?
           Rez        DB    ?
           tyr        DB    ?    
           buf        DB    ?  
;********************************************************************
           MS         Date  16 dup(<>)        
           svet1      dw    ?        
           svet2      dw    ?                           
;********************************************************************           
Data       ENDS
Code       SEGMENT
           ASSUME cs:Code,ds:Data,ss:Stk
SymImages  db    3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7fh,05fh
VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;Сохранение исходного состояния
           mov   bh,0        ;Сброс счётчика повторений
VD2:       in    al,dx       ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   bh          ;Инкремент счётчика повторений
           cmp   bh,NMax     ;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных
           ret
VibrDestr  ENDP
KbdInput   PROC  NEAR
           lea   si,KbdImage         ;Загрузка адреса,
           mov   cx,LENGTH KbdImage  ;счётчика циклов
           mov   bl,0eh             ;и номера исходной строки
           or    buf,bl
KI4:       mov   al,buf       ;Выбор строки
           out   KbdPort,al  ;Активация строки
           in    al,KbdPort  ;Ввод строки
           and   al,0ffh      ;Включено?
           cmp   al,0ffh
           jz    KI1         ;Переход, если нет
           mov   dx,KbdPort  ;Передача параметра
           call  VibrDestr   ;Гашение дребезга
           mov   [si],al     ;Запись строки
KI2:       in    al,KbdPort  ;Ввод строки
           and   al,0ffh      ;Выключено?
           cmp   al,0ffh
           jnz   KI2         ;Переход, если нет
           call  VibrDestr   ;Гашение дребезга
           jmp   SHORT KI3
KI1:       mov   [si],al     ;Запись строки
KI3:       inc   si          ;Модификация адреса
           sub   buf,2        ;и номера строки
           loop  KI4         ;Все строки? Переход, если нет
           ret
KbdInput   ENDP
KbdInContr PROC  NEAR
           lea   bx,KbdImage ;Загрузка адреса
           mov   cx,2        ;и счётчика строк
           mov   EmpKbd,0    ;Очистка флагов
           mov   KbdErr,0
           mov   dl,0        ;и накопителя
KIC2:      mov   al,[bx]     ;Чтение строки
           mov   ah,8        ;Загрузка счётчика битов
KIC1:      shr   al,1        ;Выделение бита
           cmc               ;Подсчёт бита
           adc   dl,0
           dec   ah          ;Все биты в строке?
           jnz   KIC1        ;Переход, если нет
           inc   bx          ;Модификация адреса строки
           loop  KIC2        ;Все строки? Переход, если нет
           cmp   dl,0        ;Накопитель=0?
           jz    KIC3        ;Переход, если да
           cmp   dl,1        ;Накопитель=1?
           jz    KIC4        ;Переход, если да
           mov   KbdErr,0FFh ;Установка флага ошибки
           jmp   SHORT KIC4
KIC3:      mov   EmpKbd,0FFh ;Установка флага пустой клавиатуры
KIC4:      ret
KbdInContr ENDP
NxtDigTrf  PROC  NEAR
           cmp   EmpKbd,0FFh ;Пустая клавиатура?
           jz    NDT1        ;Переход, если да
           cmp   KbdErr,0FFh ;Ошибка клавиатуры?
           jz    NDT1        ;Переход, если да
           lea   bx,KbdImage ;Загрузка адреса
           mov   dx,0        ;Очистка накопителей кода строки и столбца
NDT3:      mov   al,[bx]     ;Чтение строки
           and   al,0ffh      ;Выделение поля клавиатуры
           cmp   al,0ffh      ;Строка активна?
           jnz   NDT2        ;Переход, если да
           inc   dh          ;Инкремент кода строки
           inc   bx          ;Модификация адреса
           jmp   SHORT NDT3
NDT2:      shr   al,1        ;Выделение бита строки
           jnc   NDT4        ;Бит активен? Переход, если да
           inc   dl          ;Инкремент кода столбца
           jmp   SHORT NDT2
NDT4:      mov   cl,3        ;Формировние двоичного кода цифры
           shl   dh,cl
           or    dh,dl
           mov   DigCode,dh  ;Запись кода цифры
NDT1:      ret
NxtDigTrf  ENDP
NumOut     PROC  NEAR
           cmp   DigCode,7h
           ja    Nord
           mov   Rez,11   
           jmp   West
     Nord: mov   Rez,19 
     West: xor   ah,ah
           mov   al,DigCode
           add   al,Rez
           daa
           mov   Rez,al
           xor   ah,ah
           and   al,0Fh           
           mov   si,ax 
           mov   al,SymImages[si]
           out   DispPort2,al
           mov   al,Rez          
           shr   al,4
           mov   si,ax 
           mov   al,SymImages[si]
           out   DispPort,al                      
           ret
NumOut     ENDP
Datchik    PROC  NEAR
           in    al,dx
           mov   ah,al
           dec   dx
           in    al,dx
           not   ax
           cmp   ax,0
           je    m111
           mov   cl,-1
     m211: shr   ax,1
           inc   cl
           cmp   ax,0
           jne   m211
           mov   al,3
           mul   cl
           mov   si,ax
           mov   al,0ffh
           cmp   Home,1
           jne   frg
           cmp   MS[si].Sig,0ffh
           jne   m111
           mov   MS[si].Pro,al 
           jmp   gdr
     frg:  mov   MS[si].Poj,al
     gdr:  call  Vyvodpolesvet
     m111: ret     
Datchik    ENDP
Pojar      PROC  NEAR
           mov   Home,0                      
           mov   dx,2h
           call  Datchik
           ret
Pojar      ENDP
Pronic     PROC  NEAR
           mov   Home,1                      
           mov   dx,4h
           call  Datchik
           ret
Pronic     ENDP
Knopkasig  PROC  NEAR
           in    al,5h
           cmp   al,ah
           jne   m12
           mov   al,3
           mov   cl,DigCode
           mul   cl
           mov   si,ax
           cmp   MS[si].Poj,0ffh                     
           je    m12
           cmp   MS[si].Pro,0ffh
           je    m12   
           mov   al,ch                  
           mov   MS[si].Sig,al
           call  Vyvodpolesvet                    
      m12: ret 
Knopkasig  ENDP
Ustanovka  PROC  NEAR
           mov   ah,0feh
           mov   ch,0ffh
           call  Knopkasig
           ret
Ustanovka  ENDP
Snjatie    PROC  NEAR
           mov   ah,0fdh
           mov   ch,0h
           call  Knopkasig
           ret
Snjatie    ENDP
Avarsit    PROC  NEAR
           mov   si,0
           in    al,5h
           cmp   al,0fbh
           jne   m33
           mov   cx,LENGTH MS
   next3:  cmp   MS[si].Poj,0ffh
           je    m13
           cmp   MS[si].Pro,0ffh
           jne   m23
     m13:  mov   al,0
           mov   MS[si].Poj,al
           mov   MS[si].Pro,al
           mov   MS[si].Sig,al
     m23:  add   si,TYPE MS
           loop  next3
     m33:  call  Vyvodpolesvet
           ret   
Avarsit    ENDP
Vyvodpolesvet  PROC  NEAR
           mov   si,0                      
           mov   ax,8000h
           mov   cx,LENGTH MS
    next4: rol   ax,1    
           cmp   MS[si].Poj,0
           jne   m14
           cmp   MS[si].Pro,0
           je    m24
      m14: or    svet1,ax
           not   ax
           and   svet2,ax
           not   ax           
           jmp   m34
      m24: cmp   MS[si].Sig,0
           jne   m44
           not   ax
           and   svet1,ax
           and   svet2,ax
           not   ax
           jmp   m34           
      m44: or    svet1,ax
           or    svet2,ax
      m34: add   si,TYPE MS
           loop  next4    
           ret
Vyvodpolesvet  ENDP
Vyvod      PROC  NEAR
           mov   si,0
           xor   dx,dx
           mov   al,3
           mov   cl,DigCode
           mul   cl
           mov   si,ax
           mov   ax,40h
           cmp   MS[si].Poj,0ffh
           jne   c1
           or    buf,al    
           jmp   c3
       c1: not   al
           and   buf,al
           not   al
       c3: rol   al,1
           cmp   MS[si].Pro,0ffh
           jne   c2
           or    buf,al          
           jmp   c4
       c2: not   al
           and   buf,al
           not   al
       c4: mov   al,buf
           out   0h,al           
           inc   di
           cmp   di,0ffffh
           jne   a1
           inc   tyr
           cmp   tyr,5
           jne    a4
           not   bp
           mov   tyr,0
       a4: mov   di,0
       a1: cmp   bp,0
           jne   a2
           mov   al,byte ptr Svet1
           out   3h,al
           mov   al,byte ptr Svet1+1
           out   4h,al
           jmp   a3
     a2:   mov   al,byte ptr Svet2
           out   3h,al
           mov   al,byte ptr Svet2+1
           out   4h,al
     a3:   ret
Vyvod      ENDP
Funcproc   PROC  NEAR
           mov   Svet1,0
           mov   Svet2,0
           mov   DigCode,0
           mov   Home,0
           mov   KbdErr,0
           mov   Flag,0
           mov   Rez,0
           mov   bx,0
           mov   tyr,0
           mov   buf,0
           mov   si,0
           mov   cx,LENGTH MS
      s1:  mov   MS[si].Poj,0
           mov   MS[si].Pro,0
           mov   MS[si].Sig,0
           add   si,TYPE MS
           loop  s1
           mov   di,1
           mov   al,SymImages[di]
           out   DispPort2,al
           out   DispPort,al
           xor   al,al
           xor   di,di
           ret
Funcproc   ENDP
Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           call  Funcproc          
InfLoop:   
           call  Vyvod
           call  Pojar
           call  Pronic
           call  Ustanovka
           call  Snjatie
           call  Avarsit
           call  KbdInput
           call  KbdInContr
           call  NxtDigTrf
           call  NumOut
           jmp   InfLoop
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END
