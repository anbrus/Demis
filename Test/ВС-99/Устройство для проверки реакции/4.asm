RomSize    EQU   4096
NMax       EQU   50          ; константа подавления дребезга
KbdPort    EQU   0           ; адреса портов
dele       EQU   43
zv         EQU   43
;--------------Сегмент стека--------------------------------------------------------
Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

InitData   SEGMENT use16
           net               db    14,6,19,0,0,0,0,0
           proveren          db    16,17,15,3,6,17,6,14
           vce               db    3,18,6,0,0,0,0,0
           null              db    0,0,0,0,0,0,0,0

Image      db    0000000b,0000000b,0000000b,0000000b,0000000b,0000000b,0000000b,0000000b  ; 0
           db    0000000b,1111100b,0010010b,0010001b,0010001b,0010010b,1111100b,0000000b  ;"А"1
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,0110000b,0000000b  ;"Б"2
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,0110110b,0000000b  ;"В"3
           db    0000000b,1111111b,0000001b,0000001b,0000001b,0000001b,0000011b,0000000b  ;"Г"4
           db    0000000b,1100000b,0111100b,0100010b,0100001b,0111111b,1100000b,0000000b  ;"Д"5
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,1001001b,0000000b  ;"Е"6
           db    0000000b,1111111b,0001000b,1111111b,0001000b,1111111b,0000000b,0000000b  ;"Ж"7
           db    0000000b,0100010b,1000001b,1000001b,1001001b,1001001b,0110110b,0000000b  ;"З"8
           db    0000000b,1111111b,0100000b,0010000b,0001000b,0000100b,1111111b,0000000b  ;"И"9
           db    0000000b,1111111b,0100000b,0010001b,0001001b,0000100b,1111111b,0000000b  ;"Й"10
           db    0000000b,1111111b,0001000b,0001000b,0010100b,0100010b,1000001b,0000000b  ;"K"11
           db    0000000b,1111100b,0000010b,0000001b,0000001b,0000010b,1111100b,0000000b  ;"Л"12
           db    0000000b,1111111b,0000010b,0000100b,0000100b,0000010b,1111111b,0000000b  ;"М"13
           db    0000000b,1111111b,0001000b,0001000b,0001000b,0001000b,1111111b,0000000b  ;"Н"14
           db    0000000b,0111110b,1000001b,1000001b,1000001b,1000001b,0111110b,0000000b  ;"О"15
           db    0000000b,1111111b,0000001b,0000001b,0000001b,0000001b,1111111b,0000000b  ;"П"16
           db    0000000b,1111111b,0001001b,0001001b,0001001b,0001001b,0000110b,0000000b  ;"Р"17
           db    0000000b,0111110b,1000001b,1000001b,1000001b,1000001b,0100010b,0000000b  ;"С"18
           db    0000000b,0000001b,0000001b,1111111b,0000001b,0000001b,0000000b,0000000b  ;"Т"19
           db    0000000b,1001111b,1001000b,1001000b,1001000b,1001000b,1111111b,0000000b  ;"У"20
           db    0000000b,0001111b,0001001b,1111111b,0001001b,0001111b,0000000b,0000000b  ;"Ф"21
           db    0000000b,1100011b,0010100b,0001000b,0001000b,0010100b,1100011b,0000000b  ;"Х"22
           db    0000000b,0111111b,0100000b,0100000b,0100000b,0111111b,1000000b,0000000b  ;"Ц"23
           db    0000000b,0001111b,0001000b,0001000b,0001000b,0001000b,1111111b,0000000b  ;"Ч"24
           db    1111111b,1000000b,1000000b,1111111b,1000000b,1000000b,1111111b,0000000b  ;"Ш"25
           db    0000000b,1111111b,1000000b,1111111b,1000000b,1111111b,1000000b,0000000b  ;"Щ"26
           db    0000000b,0000001b,1111111b,1001000b,1001000b,1001000b,0110000b,0000000b  ;"Ъ"27
           db    0000000b,1111111b,1001000b,1001000b,1001000b,0110000b,1111111b,0000000b  ;"Ы"28
           db    0000000b,1111111b,1001000b,1001000b,1001000b,0110000b,0000000b,0000000b  ;"Ь"29
           db    0000000b,1000001b,1000001b,1000001b,1001001b,1001001b,0111110b,0000000b  ;"Э"30
           db    0000000b,1111111b,0001000b,0111110b,1000001b,1000001b,0111110b,0000000b  ;"Ю"31
           db    0000000b,1000110b,0101001b,0011001b,0001001b,0001001b,1111111b,0000000b  ;"Я"32
           db    0000000b,0111110b,1010001b,1001001b,1000101b,0111110b,0000000b,0000000b  ;"0"33
           db    0000000b,0000000b,1000100b,1111110b,1111111b,1000000b,0000000b,0000000b  ;"1"34
           db    0000000b,1000010b,1100001b,1010001b,1001001b,1000110b,0000000b,0000000b  ;"2"35
           db    0000000b,0100010b,1000001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"3"36
           db    0000000b,0001100b,0001010b,0001001b,1111111b,0001000b,0000000b,0000000b  ;"4"37
           db    0000000b,1000111b,1000101b,1000101b,1000101b,0111001b,0000000b,0000000b  ;"5"38
           db    0000000b,0111100b,1000110b,1000101b,1000101b,0111000b,0000000b,0000000b  ;"6"39
           db    0000000b,1000001b,0100001b,0010001b,0001001b,0000111b,0000000b,0000000b  ;"7"40
           db    0000000b,0110110b,1001001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"8"41
           db    0000000b,0000110b,1001001b,0101001b,0011001b,0001110b,0000000b,0000000b  ;"9"42
           db    81h,42h,24h,18h,18h,24h,42h,81h                                          ;*  44    
InitData   ENDS

;--------------Сегмент данных-------------------------------------------------------
Data       SEGMENT AT 0
           KbdImage          DB    6 DUP(?) ; единично-шестнадцатир. код очередн. введен. цифры(с клавы)
           EmpKbd            DB    ?        ; пустая клава
           KbdErr            DB    ?        ; ошибка клавы
           Digcode           DB    ?        ; код цифры
           slpd              db    ?
           slpr              db    ?
           slvv              db    ?
           mode              db    ?
           ind               db    ?
           kon               db    ?
           indv              db    ?  
           indp              db    ?                  
           dan               db    ?             
           poisk             db    ?
           poisk1            db    ?
           gotov             db    ?
           buf               db    ?
           zrdv              db    ?
           offs              dw    ?
           del1              dw    ?
           del2              dw    ?
           popi              db    ?
           adr               db    ?
           nom               db    16 dup(?)
           pos               db    8  dup(?)
           res               dq    8  dup(?)
           famf              db    8  dup(8  dup(?))    
           fam               db    8  dup(8  dup(?))    
           pk                db    8  dup(?)
           mas               db    8  dup(?)
           slov              dw    ?
           slov1             dw    ?
           kol               db    ?
           ime               db    ?    
           lcd               db    7  dup(?)      
Data       ENDS
        ;Сегмент кода
Code       SEGMENT
           ASSUME cs:Code,ds:Data,ss:Stk,es:Initdata
           
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
           mov   bl,0feh             ;и номера исходной строки
KI4:       mov   al,bl       ;Выбор строки
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
           rol   bl,1        ;и номера строки
           loop  KI4         ;Все строки? Переход, если нет
           ret
KbdInput   ENDP

KbdInContr PROC  NEAR
           lea   bx,KbdImage ;Загрузка адреса
           mov   cx,6        ;и счётчика строк
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
           cmp   EmpKbd,0FFh ;Пустая клавиатура?
           jnz   I1k          ;Переход, если да
      I2k: jmp   Ik
      I1k: cmp   KbdErr,0FFh ;Ошибка клавиатуры?
           jz    I2k          ;Переход, если да
           inc   DigCode
           cmp   mode,0f0h
           je    I1m
           jmp   I1
      I1m: xor   ah,ah
           mov   al,ind
           mov   si,ax
           shl   si,1
           cmp   nom[si+1],0ffh
           jne   I2
           mov   nom[si+1],0
           shl   si,2
           mov   bx,si
           mov   si,0
           mov   cx,8
       I3: mov   famf[bx+si],0
           inc   si
           loop  I3
           cmp   DigCode,dele  
           je    I2k
           mov   dl,DigCode
           mov   si,0
           mov   famf[bx+si],dl
           jmp   Ik
       I2: cmp   DigCode,dele  
           jne   I4
           shl   si,2
           mov   bx,si
           mov   si,0
       I7: cmp   famf[bx+si],0
           jne   I5
           cmp   si,0
           je    I2k
       I8: dec   si
           mov   famf[bx+si],0
           jmp   Ik
       I5: inc   si
           cmp   si,8
           jne   I7
           jmp   I8
       I4: shl   si,2
           mov   bx,si
           mov   si,0
      I10: cmp   famf[bx+si],0
           jne   I9
           mov   dl,DigCode                   
           mov   famf[bx+si],dl
           jmp   Ik
       I9: inc   si
           cmp   si,8
           jne   I10
           jmp   Ik
       I1: cmp   poisk,0ffh
           je    I3k
           jmp   Ik
      I3k: cmp   DigCode,dele
           jne   I11
           cmp   poisk1,1
           jne   I12
           mov   pk[0],zv 
           jmp   Ik
      I12: cmp   poisk1,2
           jne   I13
           mov   pk[0],zv
           jmp   Ik
      I13: cmp   poisk1,3
           jne   Ik
           mov   si,0
      I15: cmp   pk[si],zv
           je    I14
           inc   si
           cmp   si,8
           jne   I15
      I16: dec   si   
           mov   pk[si],zv
           jmp   Ik
      I14: cmp   si,0
           je    Ik
           jmp   I16
      I11: cmp   DigCode,33
           jnae  I17
           cmp   DigCode,42
           ja    I17
           cmp   poisk1,3
           je    I17
           mov   dl,DigCode
           mov   pk[0],dl
           jmp   Ik
      I17: cmp   poisk1,3
           jne   Ik
           mov   si,0
      I19: cmp   pk[si],zv
           je    I18
           inc   si
           cmp   si,8
           jne   I19
           jmp   Ik
      I18: mov   dl,DigCode
           mov   pk[si],dl
      Ik:  ret
NumOut     ENDP

mes        proc near
           mov   del1,0
           mov   al,0
           out   3,al
           out   5,al
           mov   al,1
           out   6,al
           
      ZT1: mov   si,0
           mov   dx,9  
           mov   bl,0
           mov   ah,0  
      ZT2: mov   cl,8
           mov   ch,1
           mov   al,mas[si]
           mov   di,ax
           shl   di,3             
      ZT3: mov   al,ch
           out   7,al
           mov   al,Image[di]            
           out   dx,al
           mov   al,0
           out   dx,al
           rol   ch,1
           inc   di
           dec   cl
           cmp   cl,0
           jne   ZT3
           inc   si
           inc   dx
           inc   bl
           cmp   bl,8
           jne   ZT2
           
           inc   del1
           cmp   del1,02fh
           jne   ZT1
           ret
mes        endp

rejimpoiska proc near
           in    al,1
           not   al
           
           mov   ah,al
      U11: in    al,1
           not   al
           cmp   al,80h
           je    U11
           mov   al,ah

           cmp   al,80h
           je    H1k
           jmp   Hk
       H1k:cmp   mode,0fh
           je    H2k
           jmp   Hk
       H2k:cmp   poisk,0ffh
           je    H1
           not   poisk
           mov   poisk1,1
           mov   cx,8
           mov   si,0
       H2: mov   pk[si],zv
           inc   si
           loop  H2
           or    buf,20h
           mov   al,buf
           out   1,al
           jmp   Hk
       H1: not   poisk
           mov   buf,4
           mov   al,buf
           out   1,al
           cmp   poisk1,1
           jne   H3
           mov   si,0
           mov   cx,8
           mov   al,pk[0]
           sub   al,33
           cmp   al,0
           je    H5_0
           
       H5: cmp   al,pos[si]
           je    H4
           inc   si
           loop  H5
     H5_0: mov   si,0
     H5_1: mov   al,net[si]
           mov   mas[si],al
           inc   si
           cmp   si,8
           jne   H5_1
           call  mes
           
           jmp   Hk
       H4: mov   indv,al
           jmp   Hk    
       H3: cmp   poisk1,2
           jne   H6
           mov   al,pk[0]
           sub   al,33
           xor   ah,ah
           cmp   al,0
           je    H7
           mov   si,ax
           
           dec   si
           shl   si,1
           cmp   nom[si+1],0ffh
           jne   H7
           shr   si,1
           mov   al,pos[si]
           mov   indv,al
           jmp   Hk
           
       H7: 
           mov   si,0
     H7_1: mov   al,net[si]
           mov   mas[si],al
           inc   si
           cmp   si,8
           jne   H7_1
           call  mes
           
           jmp   Hk
       H6: cmp   poisk1,3
           jne   Hk
           
           mov   si,0
      H13: cmp   pk[si],zv
           jne   H12
           mov   pk[si],0
      H12: inc   si
           cmp   si,8
           jne   H13     
           
           cmp   pk[0],0
           je   H14
           
           
           mov   bx,0
           mov   cx,8
           mov   si,0
       H10:mov   al,pk[si]
           cmp   al,fam[bx+si]
           jne   H8
           inc   si
           cmp   si,8
           je    H9
           jmp   H10
       H8: add   bx,8
           mov   si,0
           loop  H10
      H14: 
           mov   si,0
    H14_1: mov   al,net[si]
           mov   mas[si],al
           inc   si
           cmp   si,8
           jne   H14_1
           call  mes
           jmp   Hk
           
       H9: shr   bx,3
           mov   al,pos[bx]
           mov   indv,al
       Hk: ret                        
rejimpoiska endp     

gotoff     proc  near
           in    al,1
           not   al
           cmp   al,40h
           jne   Fk
           cmp   mode,0ffh
           jne   Fk
           cmp   gotov,0
           jne   Fk
           mov   gotov,1
           mov   ime,2
       Fk: ret     
gotoff     endp

memory     proc  near
           in    al,1
           not   al
           cmp   al,8h
           jne   Dk
           cmp   mode,0f0h
           jne   Dk
           mov   al,ind
           xor   ah,ah
           mov   bx,ax
           shl   bx,3
           mov   si,0
           cmp   famf[bx+si],0
           je    Dk
           shr   bx,2
           mov   nom[bx+1],0ffh
       Dk: ret     
memory     endp

ost        proc  near
           in    al,1
           not   al
           mov   ah,al
       U1: in    al,1
           not   al
           cmp   al,10h
           je   U1
           mov   al,ah
           cmp   al,10h
           jne   Ek
           cmp   mode,0f0h
           jne   E1
           cmp   ind,0
           je    E1
           dec   ind
           jmp   Ek
       E1: cmp   poisk,0ffh
           jne   E2
           cmp   poisk1,1
           je    Ek
           dec   poisk1
           mov   cx,8
           mov   si,0
       E3: mov   pk[si],zv
           inc   si
           loop  E3
           jmp   Ek
       E2: cmp   mode,0fh
           jne   Ek
           cmp   indv,1
           je    Ek
           dec   indv
       Ek: ret                                                                                                                    

ost        endp

west       proc  near
           in    al,1
           not   al
           mov   ah,al
       U2: in    al,1
           not   al
           cmp   al,20h
           je   U2
           mov   al,ah
           cmp   al,20h
           jne   Gk
           cmp   mode,0f0h
           jne   G1
           cmp   ind,7
           je    G1
           inc   ind
           jmp   Gk
       G1: cmp   poisk,0ffh
           jne   G2
           cmp   poisk1,3
           je    Gk
           inc   poisk1
           mov   cx,8
           mov   si,0
       G3: mov   pk[si],zv
           inc   si
           loop  G3
           jmp   Gk
       G2: cmp   mode,0fh
           jne   Gk
           inc   indv
           mov   al,indv
           mov   cx,8
           mov   si,0
       G4: cmp   pos[si],al
           je    Gk
           inc   SI
           loop  G4
           dec   indv
       Gk: ret                                                                                                                    

west        endp

podgotovka proc  near
           in    al,1
           not   al
           cmp   al,1h
           je    A1k
           jmp   Ak
      A1k: ;cmp   kon,0ffh
           cmp   ime,2
           jne   Ak_1
           jmp   Ak
      Ak_1:cmp   slpd,0h
           je    Ak_2
           jmp   Ak
      Ak_2:mov   mode,0f0h
           mov   slpd,1                      
           mov   slpr,0                      
           mov   slvv,0                      
           mov   ind,0
           mov   dan,0
           cmp   ime,1
           je    A50
           mov   bx,0
       M1: mov   si,0
           mov   cx,8
       M:  mov   famf[bx+si],0
           mov   fam[bx+si],0       
           inc   si
           loop  M
           add   bx,8
           cmp   bx,64
           jne   M1
           jmp   A52
      A50: mov   bx,0
           mov   si,0
           mov   cx,8
      A53: mov   al,fam[bx+si]
           mov   famf[bx+si],al
           inc   si
           cmp   si,8
           jne   A53      
           add   bx,8
           mov   si,0
           loop  A53
           
      A52: cmp   ime,1
           je    A51
           mov   si,0
           mov   dl,1
        A3:mov   nom[si],dl
           mov   nom[si+1],0 
           add   si,2
           inc   dl
           cmp   si,16
           jne   A3
      A51: mov   buf,1
           mov   al,buf
           out   1,al             
        Ak:ret   
podgotovka endp

proverka proc  near
           in    al,1
           not   al
           cmp   al,2h
           je    B1k
           jmp   Bk
      B1k: cmp   slpr,0h
           je    B2k
           jmp   Bk
           
      B2k: mov   si,-2
       B1: add   si,2
           cmp   si,16
           jne   B3k
           jmp   Bk
      B3k: cmp   nom[si+1],0ffh
           jne   B1             
           mov   mode,0ffh
           mov   slpd,0                      
           mov   slpr,1                      
           mov   slvv,0                      
           mov   dan,0ffh
           mov   kon,0ffh
           mov   zrdv,0
           mov   popi,0
           mov   kol,1  
           mov   ime,1       
           
           mov   si,0
        A2:mov   word ptr res[si],0           
           mov   word ptr res[si+2],0
           mov   word ptr res[si+4],0
           mov   word ptr res[si+6],0
           add   si,8
           cmp   si,64
           jne   A2
           
           mov   si,0
      B11: mov   pos[si],0
           inc   si   
           cmp   si,8
           jne   B11
           
           mov   bx,0
           mov   si,0
           mov   di,0
           mov   ah,0
       B3: cmp   nom[si+1],0ffh
           je    B2_1
       B5: add   si,2
           add   bx,8
           mov   di,0
           cmp   si,16
           je    B4
           jmp   B3
     B2_1: inc   kol
           cmp   ah,1
           je    B2_2
           mov   al,nom[si]
           mov   indp,al
           dec   indp
           inc   ah
     B2_2: mov   al,famf[bx+di]     
           mov   fam[bx+di],al
           inc   di
           cmp   di,8
           jne   B2_2
           jmp   B5     
           
       B4: mov   buf,0ah
           mov   al,buf
           out   1,al             
        Bk:ret   
proverka endp

vyvod proc  near
           in    al,1
           not   al
           cmp   al,4h
           je    C1k
           jmp   Ck
      C1k: cmp   slvv,0h
           je    C2k
           jmp   Ck
      C2k: cmp   kon,0ffh
           jne   C3k
           jmp   Ck
      C3k: cmp   dan,0ffh
           je    C4k
           jmp   Ck
      C4k: mov   mode,0fh
           mov   slpd,0                      
           mov   slpr,0                      
           mov   slvv,1                      
           mov   ime,0       
           
           mov   si,0
           mov   di,0
           mov   cx,8
           mov   indv,1
       P2: cmp   si,di    
           je    P1
           
     ;      shr   di,1
     ;      cmp   nom[di+1],0
     ;      jne    Hex   
     ;      shl   di,1
     ;      jmp   P1
     ;  Hex:shl   di,1    
       
           mov   ax,word ptr res[di]
           cmp   word ptr res[si],ax
           ja    P1
           jb    P3
           mov   ax,word ptr res[di+2]
           cmp   word ptr res[si+2],ax
           ja    P1
           jb    P3
           mov   ax,word ptr res[di+4]
           cmp   word ptr res[si+4],ax
           ja    P1
           jb    P3
           mov   ax,word ptr res[di+6]
           cmp   word ptr res[si+6],ax
           ja    P1
       P3: inc   indv
       P1: add   di,8
           cmp   di,64
           jne   P2    
           shr   si,3
           mov   al,kol
           sub   al,indv
           mov   pos[si],al
           shl   si,3
     Hex1: mov   indv,1
           add   si,8
           mov   di,0
           loop  P2
           
           mov   indv,1
           mov   si,0
           mov   di,0
           mov   cx,8
      C11: cmp   nom[si+1],0
           jne   C10
           mov   pos[di],0
      C10: add   si,2
           inc   di
           loop  C11        
           
           mov   buf,4
           mov   al,buf
           out   1,al             
        Ck:ret   
vyvod endp

matrix     proc  near
           cmp   mode,0f0h
           je    O1k
           jmp   Ok           
       O1k:mov   al,0
           out   3,al
           mov   al,1
           out   5,al
           out   6,al
           
           mov   dx,8 
           xor   ah,ah
           mov   al,ind 
           shl   ax,1
           mov   si,ax
           mov   cx,8
           mov   ah,1
           mov   bx,0
           mov   bl,nom[si]
           add   bx,33
           shl   bx,3
       O1: mov   al,ah
           out   7,al
           mov   al,Image[bx]            
           out   dx,al
           mov   al,0
           out   dx,al
           rol   ah,1
           inc   bx
           loop  O1
           
           mov   dx,9
           mov   ah,0  
           mov   al,ind
           shl   ax,3  
           mov   bx,ax
           mov   si,0
           mov   ah,0
       O3: mov   cl,8
           mov   ch,1
           mov   al,famf[bx+si]
           mov   di,ax
           shl   di,3             
       O2: mov   al,ch
           out   7,al
           mov   al,Image[di]            
           out   dx,al
           mov   al,0
           out   dx,al
           rol   ch,1
           inc   di
           dec   cl
           cmp   cl,0
           jne   O2
           inc   si
           inc   dx
           cmp   si,8
           jne   O3
       Ok: ret    
matrix     endp

matrix1    proc  near
           cmp   mode,0ffh
           je    O1k_1
           jmp   Ok_1           
    O1k_1: cmp   kon,0
           jne   O1y
           
           mov   si,0
           mov   dx,9  
           mov   bl,0
           mov   ah,0  
      ZP2: mov   cl,8
           mov   ch,1
           mov   al,vce[si]
           mov   di,ax
           shl   di,3             
      ZP3: mov   al,ch
           out   7,al
           mov   al,Image[di]            
           out   dx,al
           mov   al,0
           out   dx,al
           rol   ch,1
           inc   di
           dec   cl
           cmp   cl,0
           jne   ZP3
           inc   si
           inc   dx
           inc   bl
           cmp   bl,8
           jne   ZP2
           jmp   Ok_1
           
    O1y:   mov   al,0
           out   3,al
           out   6,al
           mov   al,1
           out   5,al
           
           mov   dx,8 
           xor   ah,ah
           mov   al,indp 
           shl   ax,1
           mov   si,ax
           mov   cx,8
           mov   ah,1
           mov   bx,0
           mov   bl,nom[si]
           add   bx,33
           shl   bx,3
     O1_1: mov   al,ah
           out   7,al
           mov   al,Image[bx]            
           out   dx,al
           mov   al,0
           out   dx,al
           rol   ah,1
           inc   bx
           loop  O1_1
     Ok_1: ret    
matrix1     endp

matrix2     proc  near
           cmp   mode,0fh
           je    O1k_2
           jmp   Ok_2           
    O1k_2: cmp   poisk,0
           je    Ok_p
           jmp   Ok_2           
     Ok_p: mov   al,1
           out   3,al
           out   5,al
           out   6,al
                     
           mov   al,indv 
           mov   si,0
       Q2: cmp   pos[si],al         
           je    Q1
           inc   si
           cmp   si,8
           jne   Q2
           
       Q1: call  result
       
           mov   dx,4 
           mov   cx,8
           mov   ah,1
           mov   bx,0
           mov   bl,pos[si]
           add   bx,33
           shl   bx,3
     O1_21: mov   al,ah
           out   7,al
           mov   al,Image[bx]            
           out   dx,al
           mov   al,0
           out   dx,al
           rol   ah,1
           inc   bx
           loop  O1_21
          
           mov   dx,8 
           shl   si,1
           mov   cx,8
           mov   ah,1
           mov   bx,0
           mov   bl,nom[si]
           add   bx,33
           shl   bx,3
     O1_22: mov   al,ah
           out   7,al
           mov   al,Image[bx]            
           out   dx,al
           mov   al,0
           out   dx,al
           rol   ah,1
           inc   bx
           loop  O1_22
           
           mov   dx,9
           mov   ah,0  
           mov   bx,si
           shl   bx,2
           mov   si,0
           mov   ah,0
     O3_2: mov   cl,8
           mov   ch,1
           mov   al,fam[bx+si]
           mov   di,ax
           shl   di,3             
     O2_2: mov   al,ch
           out   7,al
           mov   al,Image[di]            
           out   dx,al
           mov   al,0
           out   dx,al
           rol   ch,1
           inc   di
           dec   cl
           cmp   cl,0
           jne   O2_2
           inc   si
           inc   dx
           cmp   si,8
           jne   O3_2
     Ok_2: ret    
matrix2     endp

matrix3     proc  near
           cmp   mode,0fh
           je    W1
           jmp   Wk           
    W1:    cmp   poisk,0ffh
           je    W1_1
           jmp   Wk           
    w1_1:  cmp   poisk1,1
           jne   W2
           
           mov   al,1
           out   3,al
           mov   al,0
           out   5,al
           out   6,al
           
           mov   dx,4 
           mov   si,0
           mov   cx,8
           mov   ah,1
           mov   bx,0
           mov   bl,pk[si]
           shl   bx,3
     W3:   mov   al,ah
           out   7,al
           mov   al,Image[bx]            
           out   dx,al
           mov   al,0
           out   dx,al
           rol   ah,1
           inc   bx
           loop  W3
           jmp   Wk
           
       W2: cmp   poisk1,2
           jne   W4
           
           mov   al,1
           out   5,al
           mov   al,0
           out   3,al
           out   6,al
           
           mov   dx,8 
           mov   si,0
           mov   cx,8
           mov   ah,1
           mov   bx,0
           mov   bl,pk[si]
           shl   bx,3
     W5:   mov   al,ah
           out   7,al
           mov   al,Image[bx]            
           out   dx,al
           mov   al,0
           out   dx,al
           rol   ah,1
           inc   bx
           loop  W5
           jmp   Wk

       W4: cmp   poisk1,3
           jne   Wk

           mov   al,0
           out   3,al
           out   5,al
           mov   al,1
           out   6,al

           
           mov   dx,9
           mov   ah,0  
           mov   si,0
           mov   ah,0
       W7: mov   cl,8
           mov   ch,1
           mov   al,pk[si]
           mov   di,ax
           shl   di,3             
       W6: mov   al,ch
           out   7,al
           mov   al,Image[di]            
           out   dx,al
           mov   al,0
           out   dx,al
           rol   ch,1
           inc   di
           dec   cl
           cmp   cl,0
           jne   W6
           inc   si
           inc   dx
           cmp   si,8
           jne   W7
     Wk:   ret    
matrix3     endp

func       proc  near
           mov   ime,0
           mov   mode,0f0h
           mov   slpd,1                      
           mov   slpr,0                      
           mov   slvv,0                      
           mov   ind,0
           mov   kon,0
           mov   dan,0
           mov   gotov,0
           mov   offs,0ff00h
           mov   poisk,0
           mov   bx,0
      M11: mov   si,0
           mov    cx,8
      M0:  mov   famf[bx+si],0
           mov   fam[bx+si],0       
           inc   si
           loop  M0
           add   bx,8
           cmp   bx,64
           jne   M11
           mov   si,0
        A21:mov   word ptr res[si],0           
           mov   word ptr res[si+2],0
           add   si,4
           cmp   si,32
           jne   A21
           mov   si,0
           mov   dl,1
        A31:mov   nom[si],dl
           mov   nom[si+1],0 
           add   si,2
           inc   dl
           cmp   si,16
           jne   A31
           mov   buf,1
           mov   al,buf
           out   1,al             
           mov   KbdErr,0
           ret
func       endp

action1    proc  near
           cmp   mode,0ffh
           je    X1_k    
           jmp   Xk           
    X1_k:  cmp   kon,0ffh
           je    X2_k           
           jmp   Xk           
     X2_k: cmp   gotov,1
           je    X3_k           
           jmp   Xk           
     X3_k: cmp   zrdv,0
           je    X4_k  
           jmp   Xk 
           mov   popi,0
           
     X4_k: mov   buf,4ah
           mov   al,buf
           out   1,al
           mov   ah,0
           mov   al,indp
           mov   si,ax
           shl   si,3
      X3:  
           mov   ah,0
           mov   al,indp
           mov   si,ax
           shl   si,3
           
           inc   word ptr res[si+6]
           cmp   word ptr res[si+6],0ffffh              
           jne   X2
           mov   word ptr res[si+6],0
           inc   word ptr res[si+4]
           cmp   word ptr res[si+4],0ffffh              
           jne   X2
           mov   word ptr res[si+4],0
           inc   word ptr res[si+2]
           cmp   word ptr res[si+2],0ffffh              
           jne   X2
           mov   word ptr res[si+2],0
           inc   word ptr res[si]
       X2: call  matrix1
           in    al,3
           not   al
           cmp   al,1   
           jne   X3    
              
           mov   buf,0ah
           mov   al,buf
           out   1,al
           
           mov   bp,0afh
       Xz: dec   bp
           call  matrix1
           cmp   bp,0
           jnz   Xz
           
           inc   popi
           cmp   popi,8
           je    X40_k
           jmp   X4_k
           
    X40_k: mov   popi,0
           mov   gotov,0
           mov   zrdv,1
           mov   buf,12h
           mov   al,buf
           out   1,al     
      Xk:  ret
action1    endp

action2    proc  near
           cmp   mode,0ffh
           je    Y1_k   
           jmp   Yk                  
     Y1_k: cmp   kon,0ffh
           je    Y2_k           
           jmp   Yk                  
     Y2_k: cmp   gotov,1
           je    Y3_k           
           jmp   Yk                  
     Y3_k: cmp   zrdv,1
           je    Y4_k    
           jmp   Yk                  
     Y4_k: mov   buf,12h
           mov   al,buf
           out   1,al
           
           mov   bx,offs
           mov   ax,[bx]
       Y3: cmp   ah,7
           jna   Y2
       Y1: sub   ah,8
           jmp   Y3
               
       Y2: mov   al,1
           mov   cl,ah
           rol   al,cl
           out   2,al
           mov   adr,al
           add   offs,0fh
           mov   ah,0
           mov   al,indp
           mov   si,ax
           shl   si,3
     Y4:   
           mov   ah,0
           mov   al,indp
           mov   si,ax
           shl   si,3
           inc   word ptr res[si+6]
           cmp   word ptr res[si+6],0ffffh              
           jne   Y5
           mov   word ptr res[si+6],0
           inc   word ptr res[si+4]
           cmp   word ptr res[si+4],0ffffh              
           jne   Y5
           mov   word ptr res[si+4],0
           inc   word ptr res[si+2]
           cmp   word ptr res[si+2],0ffffh              
           jne   Y5
           mov   word ptr res[si+2],0
           inc   word ptr res[si]
       Y5: call  matrix1
           in    al,2
           not   al
           cmp   al,adr   
           jne   Y4
           mov   al,0
           out   2,al
           
           mov   bp,0afh
       Xy: dec   bp
           call  matrix1
           cmp   bp,0
           jnz   Xy
           
           inc   popi
           cmp   popi,8
           je    Y40_k
           jmp   Y4_k
    Y40_k: mov   gotov,0
           mov   zrdv,0
           mov   buf,0ah
           mov   al,buf
           out   1,al

           mov   si,0
     Y5_1: mov   al,proveren[si]
           mov   mas[si],al
           inc   si
           cmp   si,8
           jne   Y5_1
           call  mes
           
           mov   ah,0
           mov   al,indp
           mov   si,ax
           inc   si
           shl   si,1
           cmp   si,16
           je    Y8
       Y7: cmp   nom[si+1],0ffh
           je    Y6
           add   si,2
           cmp   si,16
           je    Y8
           jmp   Y7
       Y6: mov   al,nom[si]        
           mov   indp,al
           dec   indp
           mov   popi,0
           jmp   Yk
       Y8: mov   slpr,0
           mov   kon,0
           mov   popi,0   
           mov   ime,0      
      Yk:  ret
      
action2    endp

result     proc  near
           
           shl   si,3   
           mov   ax,word ptr res[si+6]
           mov   slov,ax
           mov   ax,word ptr res[si+4]
           mov   slov1,ax
           shr   si,3   
           
           mov   ax,slov
           xor   dx,dx
           mov   cx,10000
           div   cx
           mov   lcd[2],al
           mul   cx
           sub   slov,ax
           mov   ax,slov
           xor   dx,dx
           mov   cx,1000
           div   cx
           mov   lcd[3],al
           mul   cx
           sub   slov,ax
           mov   ax,slov
           xor   dx,dx
           mov   cx,100
           div   cx
           mov   lcd[4],al
           mul   cx
           sub   slov,ax
           mov   ax,slov
           mov   cx,10
           xor   dx,dx
           div   cx
           mov   lcd[5],al
           mul   cx
           sub   slov,ax
           mov   ax,slov
           mov   lcd[6],al

           mov   ax,slov1
           xor   dx,dx
           mov   cx,10000
           div   cx
           mul   cx
           sub   slov1,ax
           mov   ax,slov1
           xor   dx,dx
           mov   cx,1000
           div   cx
           mul   cx
           sub   slov1,ax
           mov   ax,slov1
           xor   dx,dx
           mov   cx,100
           div   cx
           mul   cx
           sub   slov1,ax
           mov   ax,slov1
           mov   cx,10
           xor   dx,dx
           div   cx
           mov   lcd[0],al
           mul   cx
           sub   slov1,ax
           mov   ax,slov1
           mov   lcd[1],al
           mov   al,1
           mov   dx,0fffh
           out   dx,al
           mov   dx,0f9h           
           call  vr
           ret
result     endp

vr         proc  near
           mov   bx,0
    Or3_2: mov   cl,8
           mov   ch,1
           mov   ah,0
           mov   al,lcd[bx]
           mov   di,ax
           add   di,33
           shl   di,3   
    Or2_2: mov   al,ch
           out   7,al
           mov   al,Image[di]            
           out   dx,al
           mov   al,0
           out   dx,al
           rol   ch,1
           inc   di
           dec   cl
           cmp   cl,0
           jne   Or2_2
           inc   dx
           inc   bx
           cmp   bx,7
           jne   Or3_2
           ret
vr         endp

Start:
           mov   ax,Initdata
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           
           call  func
InfLoop:   
           call   KbdInput
           call   KbdInContr
           call   NxtDigTrf
           call   NumOut
           
           call   podgotovka
           call   proverka
           call   gotoff
           call   action1          
           call   action2                       
           call   vyvod
           call   matrix
           call   matrix1
           call   matrix2
           call   matrix3
           call   west           
           call   ost    
           call   memory   
           call   rejimpoiska
           jmp    InfLoop
           
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           assume cs:nothing
           jmp   Far Ptr Start
Code       ENDS
END
