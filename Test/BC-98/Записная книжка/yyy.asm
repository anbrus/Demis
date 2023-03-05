.386

RomSize    EQU   4096
MaxSize    EQU   32
SizeInd    EQU   6
CentrInd   EQU   3           ; SizeInd div 2
MaxStr     EQU   20

rM_1        EQU   48
rM_2        EQU   49        
rM_3        EQU   50
rM_4        EQU   51        
rM_5        EQU   52        
rMRL        EQU   56

r_Up        EQU   46
r_Dn        EQU   62
r_Lft       EQU   53
r_Rgt       EQU   55

rEntr       EQU   54
rBackS      EQU   60

M_1        EQU   100
M_2        EQU   101       
M_3        EQU   102
M_4        EQU   103       
M_5        EQU   104       
MRL        EQU   105

_Up        EQU   106
_Dn        EQU   107
_Lft       EQU   108
_Rgt       EQU   109

Entr       EQU   110
BackS      EQU   111


IntTable   SEGMENT at 0 use16
IntTable   ENDS

Data       SEGMENT at 0 use16

 string db SizeInd dup (0)
 qr        db 0
 pk        db 0
 ps        db 0
 key       db 0
 result    db 0
 mode      db 0
 modeSt    db 1
 r_l       db 1
 direct    db ?                  ; направление при поиске 1 - вниз, 255 - вверх.   
 num       db ?
 char      db ?
 len       db ?
 helper    dw ?

 st        db MaxSize+1 dup (0)
 st2       db MaxSize+1 dup (0)
           
 arr       db MaxStr*MaxSize dup (?)
           
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT at 1000 use16
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

Image:



















    
     db    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ;' '
     db    000h, 008h, 018h, 008h, 008h, 008h, 03eh, 000h ;'1'
     db    000h, 03ch, 042h, 002h, 03ch, 040h, 07eh, 000h ;'2'
     db    000h, 03ch, 042h, 00ch, 002h, 042h, 03ch, 000h ;'3'
     db    000h, 004h, 00ch, 014h, 024h, 07eh, 004h, 000h ;'4'
     db    000h, 07eh, 040h, 07ch, 002h, 042h, 03ch, 000h ;'5'
     db    000h, 03ch, 040h, 07ch, 042h, 042h, 03ch, 000h ;'6'
     db    000h, 07eh, 002h, 004h, 008h, 010h, 010h, 000h ;'7'
     db    000h, 03ch, 042h, 03ch, 042h, 042h, 03ch, 000h ;'8'
     db    000h, 03ch, 042h, 042h, 03eh, 002h, 03ch, 000h ;'9'
     db    000h, 03ch, 046h, 04ah, 052h, 062h, 03ch, 000h ;'0'
     db    000h, 03ch, 042h, 042h, 07eh, 042h, 042h, 000h ;'A'
     db    000h, 07ch, 042h, 07ch, 042h, 042h, 07ch, 000h ;'B'
     db    000h, 03ch, 042h, 040h, 040h, 042h, 03ch, 000h ;'C'
     db    000h, 078h, 044h, 042h, 042h, 044h, 078h, 000h ;'D'
     db    000h, 07eh, 040h, 07ch, 040h, 040h, 07eh, 000h ;'E'
     db    000h, 07eh, 040h, 040h, 07ch, 040h, 040h, 000h ;'F'
     db    000h, 03ch, 042h, 040h, 04eh, 042h, 03ch, 000h ;'G'
     db    000h, 042h, 042h, 07eh, 042h, 042h, 042h, 000h ;'H'
     db    000h, 03eh, 008h, 008h, 008h, 008h, 03eh, 000h ;'I'
     db    000h, 002h, 002h, 002h, 002h, 042h, 03ch, 000h ;'J'
     db    000h, 044h, 048h, 070h, 048h, 044h, 042h, 000h ;'K'
     db    000h, 040h, 040h, 040h, 040h, 040h, 07eh, 000h ;'L'
     db    000h, 042h, 066h, 05ah, 042h, 042h, 042h, 000h ;'M'
     db    000h, 042h, 062h, 052h, 04ah, 046h, 042h, 000h ;'N'
     db    000h, 03ch, 042h, 042h, 042h, 042h, 03ch, 000h ;'O'
     db    000h, 07ch, 042h, 042h, 07ch, 040h, 040h, 000h ;'P'
     db    000h, 03ch, 042h, 042h, 052h, 04ah, 03ch, 000h ;'Q'
     db    000h, 07ch, 042h, 042h, 07ch, 044h, 042h, 000h ;'R'
     db    000h, 03ch, 040h, 03ch, 002h, 042h, 03ch, 000h ;'S'
     db    000h, 07fh, 008h, 008h, 008h, 008h, 008h, 000h ;'T'
     db    000h, 042h, 042h, 042h, 042h, 042h, 03ch, 000h ;'U'
     db    000h, 042h, 042h, 042h, 042h, 024h, 018h, 000h ;'V'
     db    000h, 042h, 042h, 042h, 042h, 05ah, 024h, 000h ;'W'
     db    000h, 042h, 024h, 018h, 018h, 024h, 042h, 000h ;'X'
     db    000h, 041h, 022h, 014h, 008h, 008h, 008h, 000h ;'Y'
     db    000h, 07eh, 004h, 008h, 010h, 020h, 07eh, 000h ;'Z'
     db    000h, 000h, 000h, 000h, 000h, 030h, 030h, 000h ;'.'
     db    000h, 000h, 000h, 000h, 000h, 030h, 030h, 060h ;','
     db    000h, 018h, 018h, 000h, 000h, 018h, 018h, 000h ;':'
     db    000h, 018h, 018h, 000h, 000h, 018h, 018h, 030h ;';'
     db    000h, 000h, 000h, 07eh, 000h, 000h, 000h, 000h ;'-'
     db    000h, 024h, 024h, 000h, 000h, 000h, 000h, 000h ;'"'
     db    000h, 010h, 010h, 010h, 010h, 000h, 010h, 000h ;'!'
     db    000h, 03ch, 042h, 00ch, 010h, 000h, 010h, 000h ;'?'
     db    000h, 03ch, 042h, 042h, 07eh, 042h, 042h, 000h ;'а'
     db    000h, 07ch, 040h, 07ch, 042h, 042h, 07ch, 000h ;'б'
     db    000h, 07ch, 042h, 07ch, 042h, 042h, 07ch, 000h ;'в'
     db    000h, 07eh, 040h, 040h, 040h, 040h, 040h, 000h ;'г'
     db    000h, 01eh, 022h, 022h, 022h, 022h, 07fh, 000h ;'д'
     db    000h, 07eh, 040h, 07ch, 040h, 040h, 07eh, 000h ;'е'
     db    014h, 07eh, 040h, 07ch, 040h, 040h, 07eh, 000h ;'ё'
     db    000h, 049h, 049h, 03eh, 049h, 049h, 049h, 000h ;'ж'
     db    000h, 03ch, 042h, 00ch, 002h, 042h, 03ch, 000h ;'з'
     db    000h, 042h, 046h, 04ah, 052h, 062h, 042h, 000h ;'и'
     db    018h, 042h, 046h, 04ah, 052h, 062h, 042h, 000h ;'й'
     db    000h, 044h, 048h, 070h, 048h, 044h, 042h, 000h ;'к'
     db    000h, 01eh, 022h, 022h, 022h, 022h, 042h, 000h ;'л'
     db    000h, 042h, 066h, 05ah, 042h, 042h, 042h, 000h ;'м'
     db    000h, 042h, 042h, 07eh, 042h, 042h, 042h, 000h ;'н'
     db    000h, 03ch, 042h, 042h, 042h, 042h, 03ch, 000h ;'о'
     db    000h, 07eh, 042h, 042h, 042h, 042h, 042h, 000h ;'п'
     db    000h, 07ch, 042h, 042h, 07ch, 040h, 040h, 000h ;'р'
     db    000h, 03ch, 042h, 040h, 040h, 042h, 03ch, 000h ;'с'
     db    000h, 07fh, 008h, 008h, 008h, 008h, 008h, 000h ;'т'
     db    000h, 042h, 042h, 042h, 03eh, 002h, 03ch, 000h ;'у'
     db    000h, 03eh, 049h, 049h, 03eh, 008h, 008h, 000h ;'ф'
     db    000h, 042h, 024h, 018h, 018h, 024h, 042h, 000h ;'х'
     db    000h, 044h, 044h, 044h, 044h, 044h, 07eh, 002h ;'ц'
     db    000h, 042h, 042h, 042h, 03eh, 002h, 002h, 000h ;'ч'
     db    000h, 041h, 049h, 049h, 049h, 049h, 07fh, 000h ;'ш'
     db    000h, 041h, 049h, 049h, 049h, 049h, 07fh, 001h ;'щ'
     db    000h, 060h, 020h, 03ch, 022h, 022h, 03ch, 000h ;'ъ'
     db    000h, 042h, 042h, 072h, 04ah, 04ah, 072h, 000h ;'ы'
     db    000h, 040h, 040h, 07ch, 042h, 042h, 07ch, 000h ;'ь'
     db    000h, 03ch, 042h, 01eh, 002h, 042h, 03ch, 000h ;'э'
     db    000h, 04eh, 051h, 071h, 051h, 051h, 04eh, 000h ;'ю'
     db    000h, 03eh, 042h, 042h, 03eh, 022h, 042h, 000h ;'я'
                      
TabLet:
           db    45, 46, 68, 49, 50, 66, 48, 67, 54, 55, 56, 57, 58 
           db    59, 60, 61, 77, 62, 63, 64, 65, 52, 47, 74, 73, 53 
           db    75, 72, 70, 71, 41, 51, 69, 76        
      
TabFnc:
           db    255, 106, 255, 100, 101, 102, 103, 104, 108, 110, 109
           db    105, 255, 255, 255, 111, 255, 107, 255      
           
Start:
           ASSUME cs:Code,ds:Data,es:Data
           mov   ax,Data
           mov   ds,ax
           mov   ax,Code
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы
           
           mov   qr, 0
           mov   pk, 0
           mov   ps, 0
           mov   r_l, 1
           mov   mode, 1
Begin:     
           mov   string[0], 0
           mov   string[1], 0
           mov   string[2], 0
           mov   string[3], 0
           mov   string[4], 0
           mov   string[5], 0
           
           Call  GetKey
Begin2:           
           Call  Condit
           mov   al, key
           
           cmp   al, M_1
           jnz   b1
           mov   mode, 1
           jmp   Begin3
b1:           
           cmp   al, M_2
           jnz   b2
           mov   mode, 2
           jmp   Begin3
b2:           
           cmp   al, M_3
           jnz   b3
           mov   mode, 3
           jmp   Begin3
b3:           
           cmp   al, M_4
           jnz   b4
           mov   mode, 4
           jmp   Begin3
b4:           
           cmp   al, M_5
           jnz   Begin3
           mov   mode, 5
Begin3:               
           Call  Condit
           cmp   mode, 1
           jnz   b3_1
           jmp   BegM1
b3_1:           
           cmp   mode, 2
           jnz   b3_2
           jmp   BegM2
b3_2:           
           cmp   mode, 3
           jnz   b3_3
           jmp   BegM3
b3_3:           
           cmp   mode, 4
           jnz   b3_4
           jmp   BegM4
b3_4:           
           cmp   mode, 5
           jnz   b3_5
           jmp   BegM5
b3_5:           
           jmp   Begin
           
BegM1:     
                                 ; ОСНОВНОЙ АЛГОРИТМ *ВВОДА СТРОКИ*
           mov   al, qr          ; если больше нет свободной памяти
           cmp   al, MaxStr      ;
           jnz   BM1_2
           jmp   Begin           ; не включать режим *ВВОДА СТРОКИ*
BM1_2:                
           Call  SubPr1          ; вызов подпрограммы 1 (ВВОД СТРОКИ)
           
           Call  OutSP
           cmp   result, 1
           jnz   BM1_1
           jmp   Begin2
BM1_1:                
           jmp   Begin
           
BegM2:     
                                 ; ОСНОВНОЙ АЛГОРИТМ *ПРОСМОТРА*
           cmp   qr, 0           ; Если нечего просматривать,
           jz    BM2_1           ; то режим меняем на ввод строки
           jmp   BM2_2           
BM2_1:           
           mov   mode, 1
           jmp   Begin
BM2_2:           
           Call  SubPr2          ; вызов подпрограммы 2
           
           Call  OutSP
           cmp   result, 1
           jnz   BM2_2_2
           jmp   Begin2
BM2_2_2:           
           jmp   Begin
           
BegM3:     
                                 ; ОСНОВНОЙ АЛГОРИТМ *ПОИСКА ПО БУКВЕ*
           cmp   qr, 0           ; если нечего искать
           jz    BM3_1           
           jmp   BM3_2
BM3_1:     
           mov   mode, 1         ; то включаем режим ввода
           jmp   Begin           ; и переходим к опросу клавы
BM3_2:                
           Call  SubPr3
           Call  OutSP
           cmp   result, 1
           jz    BM3_2_1
           jmp   Begin
BM3_2_1:           
           jmp   Begin2

BegM4:
                                 ; ОСНОВНОЙ АЛГОРИТМ *ПОИСКА ПО БУКВЕ*
           cmp   qr, 0           ; если нечего искать
           jz    BM4_1           
           jmp   BM4_2
BM4_1:     
           mov   mode, 1         ; то включаем режим ввода
           jmp   Begin           ; и переходим к опросу клавы
BM4_2:                
           Call  SubPr4
           Call  OutSP
           cmp   result, 1
           jz    BM4_2_1
           jmp   Begin
BM4_2_1:           
           jmp   Begin2

BegM5:     
                                 ; ОСНОВНОЙ АЛГОРИТМ *УДАЛЕНИЯ*
           cmp   qr, 0           ; Если нечего удалять,
           jz    BM5_1           ; то режим меняем на ввод строки
           jmp   BM5_2           
BM5_1:           
           mov   mode, 1
           jmp   Begin
BM5_2:           
           Call  SubPr5          ; вызов подпрограммы 5
           
           Call  OutSP
           cmp   result, 1
           jnz   BM5_2_2
           jmp   Begin2
BM5_2_2:           
           jmp   Begin


SubPr1     proc
                                 ; ОСНОВНОЙ АЛГОРИТМ *ВВОДА СТРОКИ*
           Call  InpStr          ; непосредственно ввод строки
           
           Call  OutSP           ; Если надо выйти - выходим
           cmp   result, 1
           jz    SPr1_End
           
           Call  InMem
Spr1_End:           
           ret
           
SubPr1     endp
           
           
SubPr2     proc
                                 ; ОСНОВНОЙ АЛГОРИТМ *ПРОСМОТРА*           
           mov   dh, 0           ; номер строки на вывод
           Push  dx
SPr2_2:      
           pop   bx
           push  dx
           
           Call  Brouse          ; просмотр строки
           
           Call  OutSP           ; Если надо выйти - выходим
           cmp   result, 1
           jz    SPr2_End
           
           pop   dx
           push  dx
           
           mov   al, key         ; выбираем направление перемещения по списку
           cmp   al, _Up         ; подразумевается, что на данном этапе 
           jnz   SPr2_1          ; программы в key либо   Up   либо   Down
           dec   dh
           cmp   dh, 255
           jnz   SPr2_2
           mov   dh, qr
           dec   dh
           jmp   SPr2_2
SPr2_1:      
           inc   dh
           cmp   dh, qr
           jnz   SPr2_2
           mov   dh, 0
           jmp   SPr2_2
Spr2_End:  
           nop
           pop   dx         
           ret
           
SubPr2     endp
           
           
SubPr3     proc
                                 ; ОСНОВНОЙ АЛГОРИТМ *ПОИСКА ПО БУКВЕ*
           Call  InpStr          ; Ввод строки (буквы)
           mov   bx, offset st   ; первая буква введённой строки 
           mov   al, [bx]        ; будет буквой, по которой будет идти выборка
           mov   char, al         ; для этой цели будем использовать   char  
           
           Call  IsStrL          ; Проверка на наличие нужных строк
           cmp   result, 1       ; если таковых нет, то
           jz    SP3_2
SP3_1:     
;      *В Ы В О Д   О Ш И Б К И*
           mov   key, M_1        ; сымитировать переход на *ВВОД СТРОКИ*
           jmp   SP3_End         ; и выйти из процедуры
SP3_2:     
           mov   direct, 1
           mov   Num, 0
SP3_3:     
           Call  MapLett             ; соответствует ли строка условию
           cmp   result, 1
           jnz   SP3_5
           
           mov   dh, num             ; dh - номер выводимой строки
           Call  Brouse
           
           Call  OutSP               ; Если надо выйти - выходим
           cmp   result, 1
           jz    SP3_End
           
           Call  SelDir              ; выбрать направление
           mov   direct, al          ; результат процедура возвр в   al
           
SP3_5:           
           mov   al, direct          ; выбрать строку
           add   num, al
           cmp   num, 255
           jnz   SP3_4
           mov   al, qr
           dec   al
           mov   num, al
           jmp   SP3_3
SP3_4:     
           mov   al, qr
           cmp   num, al
           jnz   SP3_3
           mov   num, 0
           jmp   SP3_3
SP3_End:           
           ret   
           
SubPr3     endp
                             
           
SubPr4     proc
                                 ; ОСНОВНОЙ АЛГОРИТМ *ПОИСКА ПО ФРАГМЕНТУ*
           Call  InpStr          ; Ввод строки (фрагмента)
           
           mov   si, offset st   ; перегоняем st в st2
           mov   di, offset st2
           mov   ch, MaxSize
SP4_Z:           
           mov   al, [si]
           mov   [di], al
           inc   si
           inc   di
           dec   ch
           jnz   SP4_Z
           
           Call  IsStrF          ; Проверка на наличие нужных строк
           cmp   result, 1       ; если таковых нет, то
           jz    SP4_2
SP4_1:     
;      *В Ы В О Д   О Ш И Б К И*
           mov   key, M_1        ; сымитировать переход на *ВВОД СТРОКИ*
           jmp   SP4_End         ; и выйти из процедуры
SP4_2:     
           mov   direct, 1
           mov   Num, 0
SP4_3:     
           Call  MapFrag             ; соответствует ли строка условию
           cmp   result, 1
           jnz   SP4_5
           
           mov   dh, num             ; dh - номер выводимой строки
           Call  Brouse
           
           Call  OutSP               ; Если надо выйти - выходим
           cmp   result, 1
           jz    SP4_End
           
           Call  SelDir              ; выбрать направление
           mov   direct, al          ; результат процедура возвр в   al
           
SP4_5:           
           mov   al, direct          ; выбрать строку
           add   num, al
           cmp   num, 255
           jnz   SP4_4
           mov   al, qr
           dec   al
           mov   num, al
           jmp   SP4_3
SP4_4:     
           mov   al, qr
           cmp   num, al
           jnz   SP4_3
           mov   num, 0
           jmp   SP4_3
SP4_End:           
           ret   
           
SubPr4     endp
           
           
           
SubPr5     proc
                                 ; ОСНОВНОЙ АЛГОРИТМ *ПРОСМОТРА*           
           mov   dh, 0           ; номер строки на вывод
           Push  dx
SPr5_2:      
           pop   bx
           push  dx
           
           cmp   qr, 0           ; если записей больше нет
           jnz   SPr5_6          
           mov   key, M_1        ; то сымитировать переход на *ВВОД СТРОКИ*
           jmp   SPr5_End        ; и вывалиться из процедуры
SPr5_6:           
           pop   dx
           push  dx
           Call  _Brouse         ; просмотр строки
           
           Call  OutSP           ; Если надо выйти - выходим
           cmp   result, 1
           jz    SPr5_End
SPr5_5:     
           cmp   key, BackS      ; не нажата ли клавиша удаления
           jnz   SPr5_4          ; если нет, то ладно
           pop   dx
           push  dx
           Call  DelStr          ; иначе удаляем текущую строку
           pop   dx
           push  dx
           jmp   SPr5_3          ; устранить посл-я, если она была последней
SPr5_4:           
           pop   dx
           push  dx
           
           mov   al, key         ; выбираем направление перемещения по списку
           cmp   al, _Up         ; подразумевается, что на данном этапе 
           jnz   SPr5_1          ; программы в key либо   Up   либо   Down
           dec   dh
           cmp   dh, 255
           jnz   SPr5_2           
           mov   dh, qr
           dec   dh
           jmp   SPr5_2
SPr5_1:      
           inc   dh
SPr5_3:           
           cmp   dh, qr
           jnz   SPr5_2
           mov   dh, 0
           jmp   SPr5_2
Spr5_End:  
           nop
           pop   dx         
           ret
           
SubPr5     endp

           

DelStr     proc
                                     ; УДАЛЕНИЕ СТРОКИ С НОМЕРОМ dh
                                     
           mov   al, dh
           inc   al
           cmp   al, qr
           jz    DelS2
                                     
           mov   al, dh              ; di = dh*MaxSize + addr_arr
           mov   bl, MaxSize
           mul   bl
           mov   di, offset arr
           add   ax, di                                     
           mov   di, ax
           
           mov   si, MaxSize         ; si = di + MaxSize
           add   ax, si
           mov   si, ax
           
           mov   al, qr              ; Top = addr_arr + qr*MaxSize
           mov   bl, MaxSize
           mul   bl
           mov   bx, offset arr
           add   ax, bx
           mov   bx, ax
DelS1:     
           mov   al, [si]            ; [di] = [si]
           mov   [di], al

           inc   di
           inc   si
           
           cmp   bx, si              ; если финал
           jnz   DelS1               ; то выйти
DelS2:           
           dec   qr                  ; - счетчик количества строк
           
DelStr     endp
           
           
SelDir     proc
                                     ; ВЫБРАТЬ НАПРАВЛЕНИЕ ПЕРЕМЕЩЕНИЯ
                                     ; ПРИ ПОИСКЕ
                                     ; результат процедура возвр в   al
                                     ; подразумевается, что в    key
                                     ; уже есть код нажатой клавиши
           cmp   key, _Dn
           jnz   SelDir1
           mov   al, 1
           jmp   SelDir_e
SelDir1:           
           mov   al, 255
           
SelDir_e:  
           ret           
           
SelDir     endp           
           
           
           
IsStrF     proc
                                 ; ПРОВЕРКА НА НАЛИЧИЕ СТРОК 
                                 ; ДЛЯ ПОИСКА ПО БУКВЕ
           mov   dl, 0           ; результат
           mov   dh, 0           ; номер текущей строки
IsSF_1:           
           mov   num, dh
           
           push  dx              ; проверка на то
           Call  MapFrag         ; соответствует ли строка    num
           pop   dx              ; заданному условию (букве)
           
           cmp   result, 1       ; если соответствует - dh=1 и выход
           jz    IsSF_2          
           mov   al, qr          ; если нет - проверка на то не
           cmp   dh, al          ; последнюю ли строку мы сейчас смотрели
           jz    IsSF_End        ; если да - выход, иначе
           inc   dh              ; + номер строки
           jmp   IsSF_1          ; и заново...
IsSF_2:               
           mov   dh, 1           
IsSF_End:           
           mov   al, dh
           mov   result, al
           ret
           
IsStrF     endp
           
           
MapFrag    proc
                                     ; ПРОВЕРКА НА СООТВЕТСТВИЕ ФРАГМЕНТУ
                                     ; ФРАГМЕНТ В st. ЕГО ДЛИНА - В len
                                     ; НОМЕР СТРОКИ, С КОТОРОЙ СРАВНИВАЕМ - В num
           mov   si, offset st2       ; в si адрес фрагмента
           mov   al, num
           mov   bl, MaxSize
           mul   bl
           mov   bx, offset arr
           add   ax, bx
           mov   di, ax              ; в di адр сравн-мой строки
           
           mov   dh, 0
           mov   dl, 0
MF1:           
           mov   ch, dh
MF2:           
           mov   al, dl              ; fr[dl] = st[ch]
           mov   ah, 0               ; fr[dl]
           mov   bx, si
           add   ax, bx
           mov   bx, ax
           mov   cl, [bx]
           
           mov   al, ch              ; st[ch]
           mov   ah, 0
           mov   bx, di
           add   ax, bx
           mov   bx, ax
           mov   al, [bx]
           
           cmp   al, cl
           
           jnz   MF3
           
           inc   ch
           inc   dl
           
           mov   al, dl              ; dl = len
           cmp   len, al
           
           jnz   MF2
           
           mov   result, 1
           jmp   MF_End
MF3:           
           inc   dh
           mov   dl, 0
           
           mov   al, MaxSize
           sub   al, len
           cmp   al, dh
           
           jnc   MF1
           mov   result, 0
MF_End:           
           ret
                      
MapFrag    endp
           
           
IsStrL     proc
                                 ; ПРОВЕРКА НА НАЛИЧИЕ СТРОК 
                                 ; ДЛЯ ПОИСКА ПО БУКВЕ
           mov   dl, 0           ; результат
           mov   dh, 0           ; номер текущей строки
IsSL_1:           
           mov   num, dh
           
           push  dx              ; проверка на то
           Call  MapLett         ; соответствует ли строка    num
           pop   dx              ; заданному условию (букве)
           
           cmp   result, 1       ; если соответствует - dh=1 и выход
           jz    IsSL_2          
           mov   al, qr          ; если нет - проверка на то не
           cmp   dh, al          ; последнюю ли строку мы сейчас смотрели
           jz    IsSL_End        ; если да - выход, иначе
           inc   dh              ; + номер строки
           jmp   IsSL_1          ; и заново...
IsSL_2:               
           mov   dh, 1           
IsSL_End:           
           mov   al, dh
           mov   result, al
           ret
           
IsStrL     endp
           
           
MapLett    proc
                                 ; НАЧИНАЕТСЯ ЛИ СТРОКА В НУЖНОЙ
                                 ; БУКВЫ (char) для поиска по букве
                                 ; номер строки в массиве    num
           mov   al, MaxSize
           mov   bl, num
           mul   bl
           mov   bx, offset arr
           add   ax, bx
           mov   bx, ax
           mov   al, [bx]

           mov   result, 0
           cmp   char, al
           jnz   MapL_End
           mov   result, 1
MapL_End:           
           ret
             
MapLett    endp           
           
           
OutSP      proc
                                 ; ПРОВЕРКА НА ФАКТ НАЖАТИЯ КЛАВИШ
                                 ; ПЕРЕХОДА В ДРУГИЕ СОСТОЯНИЯ
                                 ; ЕСЛИ НАЖАТЫ - resuilt = 1
                                 ; ИНАЧЕ - 0
           mov   ah, 0
           mov   al, key
           cmp   al, M_5+1
           jnc   OSP_End
           cmp   al, M_1
           jc    OSP_End
           mov   ah, 1
OSP_End:   
           mov   result, ah
           ret                      
           
OutSP      endp
           
           
Brouse     proc
                                 ; ПРОСМОТР СТРОКИ С НОМЕРОМ dh

           mov   ps, 0
           
                                     ; st = arr[dh]
           mov   al, dh              ; Вычисляем адрес (dh)
           mov   bl, MaxSize
           mul   bl
           mov   bx, ax
           mov   ax, offset arr
           add   ax, bx
           
           mov   si, ax
           mov   di, offset st
           
           mov   ch, MaxSize         ; Непосредственно пересылка
Brou1:                  
           mov   al, [si]
           mov   [di], al
           
           inc   si
           inc   di
           dec   ch
           jnz   Brou1
Brou2:           
           Call  S_to_S              ; перегонка 6-ти символов в string
           Call  Pr_Str               ; Отображение string'а
           Call  GetKey              ; Опрос клавы
           
           Call  OutSP               ; Если нажаты клавиши ПДС
           mov   al, result          ; выйти
           cmp   al, 1
           jz    Brou_End            
           
           mov   al, key             ; если нажаты клавиши ВВЕРХ или ВНИЗ
           cmp   al, _Up             ; тоже выйти
           jz    Brou_End
           cmp   al, _Dn
           jz    Brou_End
           
           cmp   al, _Rgt            ; Если нажата клавиша ВПРАВО    
           jz    Brou_Rgt            
           cmp   al, _Lft
           jz    Brou_Lft
           Jmp   Brou2
Brou_Lft:  
           cmp   ps,0                ; проверить на минимум
           jz    Brou2               ; если всё ОК
           dec   ps                  ; - сдвинуть влево
           jmp   Brou2
Brou_Rgt:                            ; проверить ps на максимальное значение
           mov   al, MaxSize         ; если всё ОК - 
           sub   al, SizeInd
           cmp   al, ps
           jz    Brou2
           inc   ps                  ; - инкрементировать, т.е. 
           jmp   Brou2               ; сдвинуть вправо
Brou_End:  
           ret           
           
Brouse     endp



_Brouse     proc
                                 ; ПРОСМОТР СТРОКИ С НОМЕРОМ dh
           mov   ps, 0
                                     ; st = arr[dh]
           mov   al, dh              ; Вычисляем адрес (dh)
           mov   bl, MaxSize
           mul   bl
           mov   bx, ax
           mov   ax, offset arr
           add   ax, bx
           
           mov   si, ax
           mov   di, offset st
           
           mov   ch, MaxSize         ; Непосредственно пересылка
_Brou1:                  
           mov   al, [si]
           mov   [di], al
           
           inc   si
           inc   di
           dec   ch
           jnz   _Brou1
_Brou2:           
           Call  S_to_S              ; перегонка 6-ти символов в string
           Call  Pr_Str              ; Отображение string'а
           Call  GetKey              ; Опрос клавы
           
           Call  OutSP               ; Если нажаты клавиши ПДС
           mov   al, result          ; выйти
           cmp   al, 1
           jz    _Brou_End            
           
           cmp   key, BackS
           jz    _Brou_End
           
           mov   al, key             ; если нажаты клавиши ВВЕРХ или ВНИЗ
           cmp   al, _Up             ; тоже выйти
           jz    _Brou_End
           cmp   al, _Dn
           jz    _Brou_End
           
           cmp   al, _Rgt            ; Если нажата клавиша ВПРАВО    
           jz    _Brou_Rgt            
           cmp   al, _Lft
           jz    _Brou_Lft
           Jmp   _Brou2
_Brou_Lft:  
           cmp   ps,0                ; проверить на минимум
           jz    _Brou2              ; если всё ОК
           dec   ps                  ; - сдвинуть влево
           jmp   _Brou2
_Brou_Rgt:                           ; проверить ps на максимальное значение
           mov   al, MaxSize         ; если всё ОК - 
           sub   al, SizeInd
           cmp   al, ps
           jz    _Brou2
           inc   ps                  ; - инкрементировать, т.е. 
           jmp   _Brou2              ; сдвинуть вправо
_Brou_End:  
           ret           
           
_Brouse     endp



           
Condit     proc
                                 ; ОПРЕДЕЛЕНИЕ СОСТОЯНИЯ СВЕТОДИОДОВ
                                 ; ОТРАЖАЮЩИХ СОСОТОЯНИЕ УСТРОЙСТВА
           mov   bl, 0
           mov   ch, mode
           mov   al, 128
Cond1:           
           rol   al, 1
           dec   ch
           jnz   Cond1
           mov   dh, al
           
           mov   al, r_l
           cmp   al, 1
           jnz   Cond2
           mov   dl, 32
           jmp   Cond3
Cond2:           
           mov   dl, 64
Cond3:     
           mov   al, dh
           add   al, dl
           mov   modeSt, al
           out   20h, al
           
           ret
                      
Condit     endp


Pr_Str     proc          
                                      ;ОТОБРАЗИТЬ СТРОКУ
           mov   bx, offset string    ; адрес первого символа
           mov   ch, 6                ; счетчик символов
           mov   dh, 1                ; байт активизации знакомест
p_s1:           
           push  cx
           push  bx
           mov   al, dh              ; активизируем нужное знакоместо
           out   2, al               
                                     ; поиск адреса нужного символа
           mov   al, [bx]            ; извлеч номер символа
           mov   bl, 8               ; умножить на 8
           mul   bl
           mov   bx, ax              ; сложить с адресом нулевого символа
           mov   ax, offset Image    
           add   ax, bx 
           mov   bx, ax             
                                     ; отобразить символ
           mov   cl, 8               ; счетчик строк
           mov   dl, 1               ; байт активизации строк
p_s2:                        
           mov   al, dl              ; активизация нужной строки
           out   0, al
                                 
           mov   al, es:[bx]         ; отображение нужного фрагмента символа
           out   1, al
           mov   al, 0
           out   1, al
                      
           rol   dl, 1               ; свёртка байта активизации строки
           inc   bx                  ; + адреса изображения символа
           dec   cl                  ; - счетчика строк
           jnz   p_s2                ; переход
                      
           pop   bx
           pop   cx
           rol   dh, 1               ; смещение байта активизации знакоместа
           inc   bx                  ; следующий символ
           dec   ch                  ; - счетчика символов
           jnz   p_s1

           ret
Pr_Str     endp
           

Pr_Str_C   proc          
                                      ;ОТОБРАЗИТЬ СТРОКУ С КУРСОРОМ
           mov   ah, pk               ; в ah загружаем позицию курсора
           mov   al, ps               ; в al - позицию строки
           sub   ah, al               ; позиция курсора в строке
           mov   al, 6                ; 6 - ah
           sub   al, ah               ; для удобства сравнения (al)

           mov   bx, offset string    ; адрес первого символа
           mov   ch, 6                ; счетчик символов
           mov   dh, 1                ; байт активизации знакомест
p_s_c1:           
           push  cx
           push  bx
           push  ax
           
           pop   ax
           push  ax
           
           cmp   ch, al              ; если идёт вывод символа с курсором
           jnz   p_s_c3
           call  Pr_C                ; - выполнить подпрогу для вывода с курсором
           jmp   p_s_c4
p_s_c3:           
           mov   al, dh              ; активизируем нужное знакоместо
           out   2, al               
                                     ; поиск адреса нужного символа
           mov   al, [bx]            ; извлеч номер символа
           mov   bl, 8               ; умножить на 8
           mul   bl
           mov   bx, ax              ; сложить с адресом нулевого символа
           mov   ax, offset Image    
           add   ax, bx 
           mov   bx, ax             
                                     ; отобразить символ
           mov   cl, 8               ; счетчик строк
           mov   dl, 1               ; байт активизации строк
p_s_c2:                        
           mov   al, dl              ; активизация нужной строки
           out   0, al
                                 
           mov   al, es:[bx]         ; отображение нужного фрагмента символа
           out   1, al
           mov   al, 0
           out   1, al
                      
           rol   dl, 1               ; свёртка байта активизации строки
           inc   bx                  ; + адреса изображения символа
           dec   cl                  ; - счетчика строк
           jnz   p_s_c2              ; переход
p_s_c4:                      
           pop   ax
           pop   bx
           pop   cx
           rol   dh, 1               ; смещение байта активизации знакоместа
           inc   bx                  ; следующий символ
           dec   ch                  ; - счетчика символов
           jnz   p_s_c1

           ret
Pr_Str_C   endp

Pr_C       proc
                                     ; ОТОБРАЗИТЬ СИМВОЛ С КУРСОРОМ
           mov   al, dh              ; активизируем нужное знакоместо
           out   2, al               
                                     ; поиск адреса нужного символа
;           mov   bx, offset string
           mov   al, [bx]            ; извлеч номер символа
           mov   bl, 8               ; умножить на 8
           mul   bl
           mov   bx, ax              ; сложить с адресом нулевого символа
           mov   ax, offset Image    
           add   ax, bx 
           mov   bx, ax             
                                     ; отобразить символ
           mov   cl, 7               ; счетчик строк
           mov   dl, 1               ; байт активизации строк
p_c2:                        
           mov   al, dl              ; активизация нужной строки
           out   0, al
                                 
           mov   al, es:[bx]         ; отображение нужного фрагмента символа
           out   1, al
           mov   al, 0
           out   1, al
                      
           rol   dl, 1               ; свёртка байта активизации строки
           inc   bx                  ; + адреса изображения символа
           dec   cl                  ; - счетчика строк
           jnz   p_c2                ; переход

           mov   al, dl              ; активизация нужной строки
           out   0, al

           mov   al, 255             ; отображение курсора
           out   1, al
           mov   al, 0
           out   1, al

           ret

Pr_C       endp
           
           
           
GetKey     proc
                             ; ЧТЕНИЕ КЛАВИАТУРЫ (ДОДЕЛАТЬ!!!)
           mov   key, 255    ; По умолчанию вых значение - 255

           mov   dh, 1       ; Байт активизации рядов клавиатуры
           mov   ch, 8       ; Счётчик рядов
Gk1:           
           mov   al, dh      ; Активизация ряда
           out   10h, al     ; 
           in    al, 10h     ; Чтение столбцов
           
           cmp   al, 0       ; Если не ноль
           jnz   Gk2         ; Выход из цикла
           
           rol   dh, 1       ; Смещение байта активизации рядов
           dec   ch          ; Декремент счетчика
           cmp   ch, 0       ; Если не конец
           jnz   Gk1         ; Продолжить цикл
           jmp   Gk4         ; Иначе - выйти из процедуры
Gk2:       
           mov   cl, 255     ; Счетчик для определения столбца
Gk3:           
           inc   cl          ; Инкремент счетчика
           shl   al, 1       ; Сворачиваем состояние столбцов
           jnz   Gk3         ; Если al не ноль - продолжение цикла
           
           mov   al, 8       ; Переворачиваем ch для удобства счета
           sub   al, ch      ; Типа, 7 - ch
           mov   bl, 8       ; Умножаем на 8
           mul   bl          ;
           add   al, cl      ; Прибавляем cl. В al номер клавиши.
               
           mov   key, al     ; то что получилось записываем в key
           
Gk4:       
           cmp   key, 45     ; преобразование кодов функциональных клавиш
           jc    Gk6
           cmp   key, 255
           jz    Gk6
           mov   al, key
           sub   al, 45
           lea   bx, TabFnc
           mov   ah, 0
           add   ax, bx
           mov   bx, ax
           mov   al, es:[bx]
           mov   key, al
           jmp   Gk_End
Gk6:           
           cmp   r_l, 1
           jnz   Gk_End
           cmp   key, 11
           jc    Gk_End
           cmp   key, 45         
           jnc   Gk_End
           mov   al, key
           sub   al, 11
           lea   bx, TabLet
           mov   ah, 0
           add   ax, bx
           mov   bx, ax
           mov   al, es:[bx]
           mov   key, al
Gk_End:               
           
           in    al, 10h     ; тормозня пока удерживается клавиша
           cmp   al, 0
           jnz   Gk_End

           ret
           
GetKey     endp           



InpStr     proc
                             ; ВВОД СТРОКИ 
                             
           mov   string[0], 0    ; Очистка индикатора
           mov   string[1], 0
           mov   string[2], 0
           mov   string[3], 0
           mov   string[4], 0
           mov   string[5], 0
                             
                                  ; Очистка строки
           mov   ch, MaxSize      ; Счетчик символов
           inc   ch               ; (так надо)
           mov   bx, offset st    ; Адрес строки
Is1:           
           mov   [bx], 0         ; Заполнение каждой из позиций пробелами
           
           inc   bx              ; Следующий символ
           dec   ch              ; Декремент счетчика
           jnz   Is1             ; Продолжить, если не ноль

           mov   ps, 0           ; Обнуление позиций курсора и строки
           mov   pk, 0
Is2:       
           Call  Pr_Str_C        ; Отобразить состояние индикатора
           
           Call  GetKey          ; Опрос клавы

           Call  OutSP           ; Если нажаты клавиши ПДР
           cmp   result, 1       ; - выйти
           jz    Is_End

           mov   al, key         ; 
           

           
           cmp   al, Entr        ; Если нажали Enter - выход
           jz    Is_End
           
           cmp   al, BackS       ; Если Delete - удалить символ
           jz    Is_Del
           
           cmp   al, MRL
           jz    Is_Mrl
           
           cmp   al, 255          ; Если нажата буква - напечатать
           jz    IS3
           cmp   al, 100
           jc    Is_Char
IS3:           
           jmp   Is2
           
Is_Del:                          ; Вызов процедуры удаления
           Call  Delet
           Call  S_to_S
           jmp   Is2
           
Is_Char:                         ; Вызов процедуры печати символа        
           Call  AddChSt
           Call  S_to_S
           jmp   Is2

Is_Mrl:    
           mov   al, 1
           mov   bl, r_l
           sub   al, bl
           mov   r_l, al
           Call  condit
           jmp   Is2

Is_End:                      
           mov   al, pk          ; занесение длины строки в
           mov   len, al         ; переменную    len
           
           ret
           
InpStr     endp

           


Delet      proc
           
           mov   al, pk          ; Если pk=0 (т. е. пусто)  - выход 
           cmp   al, 0
           jz    D_End
           
           mov   al, pk          ; if pk-ps = CentrInd
           sub   al, ps
           cmp   al, CentrInd   
           jnz   D1
           
           mov   al, ps          ; if ps <> 0
           cmp   al, 0
           jz    D1
           
           dec   ps    
D1:                      
           dec   pk
           
           mov   bl, pk          ; st[pk] = ' '
           mov   bh, 0
           mov   ax, offset st
           add   ax, bx
           mov   bx, ax
           mov   [bx], 0
D_End:
           ret
           
Delet      endp



S_to_S     proc
                                 ; КОПИРОВАНИЕ ИЗ st В string
                                 ; SizeInd байт

           mov   ch, SizeInd     ; Счетчик
           mov   bx, offset st    ; Адрес of st
           mov   dx, offset string    ; Адрес of string
           mov   ah, 0           ; Увеличиваем bx на ps
           mov   al, ps      
           add   ax, bx
           mov   bx, ax          
sts1:           
           mov   al, [bx]        ; Переносим инфу из string в st
           push  bx
           mov   bx, dx
           mov   [bx], al
           pop   bx
           
           inc   bx              ; Следующий символ
           inc   dx              ; Следующая ячейка
           dec   ch              ; Декремент счетчика
           jnz   sts1            ; Переход, если конец

           ret
                                 
S_to_S     endp



AddChSt    proc
                                 ; ВНЕСЕНИЕ СИМВОЛА В st
           mov   al, MaxSize+1   ; Если pk = MaxSize + 1
           mov   bl, pk          ; То вываливаемся из подпроги
           cmp   al, bl      
           jz    Acs_End
           
           mov   al, pk          ; Если pk-ps = SizeInd - 1
           mov   bl, ps          ; то...
           sub   al, bl
           mov   bl, SizeInd-1
           cmp   al, bl
           jnz   Acs1
           
           mov   al, ps          ; ... увеличиваем ps на 1
           inc   al
           mov   ps, al
           
Acs1:                 
           mov   ax, offset st    ; st[pk] = key
           mov   bl, pk
           mov   bh, 0
           add   ax, bx
           mov   bx, ax
           mov   al, key
           mov   [bx], al
           
           mov   al, pk          ; inc(pk)
           inc   al
           mov   pk, al
Acs_End:
           ret

AddChSt    endp




InMem      proc
                                     ; ЗАНЕСНЕИЕ st В arr 
                                     ; В ОТСОРТИРОВАННОМ ВИДЕ
           
           mov   dh, 0

           mov   al, qr              ; Если пусто, то вставка без проверки.
           cmp   al, 0
           jz    im3

im4:           
                                     ; st2 = arr[a]
           mov   al, dh              ; Вычисляем адрес (а)
           mov   bl, MaxSize
           mul   bl
           mov   bx, ax
           mov   ax, offset arr
           add   ax, bx
           
           mov   si, ax
           mov   di, offset st2
           
           mov   ch, MaxSize         ; Непосредственно пересылка
im1:                  
           mov   al, [si]
           mov   [di], al
           
           inc   si
           inc   di
           dec   ch
           jnz   im1
           
           Call  CmpStr                ; if st < st2
           mov   al, result
           cmp   al, 1
           jnz   im2  
           
           Call  StrsUp
           jmp   im3
           
im2:           
           inc   dh                  ; inc a
           
           mov   al, qr
           cmp   al, dh
           jnz   im4
im3:                    
           Call  InsStr
           inc   qr
           
           ret           
InMem      endp



CmpStr     proc
           
           mov   al, 1               ; result = 1
           mov   result, al
           mov   ch, 0               ; z = 0
           
           mov   di, offset st        ; Установка адресов
           mov   si, offset st2
cs2:                  
           mov   al, [di]
           mov   bl, [si]
           
           cmp   al, bl              ; if st1[z] < st2[z]
           jc    cs_End
           
           cmp   bl, al              ; if st1[z] > st2[z]
           jnc   cs1
           
           mov   al, 0               ; result = 0
           mov   result, al
           jmp   cs_End
Cs1:           
           inc   di
           inc   si
           inc   ch                  ; inc z
           
           cmp   ch, MaxSize         ; if z = MaxSimb
           jnz   cs2       
Cs_End:           
           ret
           
CmpStr     endp

StrsUp     proc
                                     ; ПЕРЕМЕСТИТЬ ВВЕРХ ВСЕ СТРОКИ 
                                     ; НАЧИНАЯ С ПОЗИЦИИ а
                                     
                                     ; a = dh
                                     
           mov   al, qr              ; si = addr_arr + (qr * MaxSimb) - 1
           mov   bl, MaxSize
           mul   bl
           mov   bx, offset arr
           add   ax, bx
           dec   ax
           mov   si, ax
           
           mov   di, MaxSize         ; di = si + MaxSimb
;           mov   ax, si
           add   ax, di
           mov   di, ax

           mov   al, dh              ; bx = addr_arr + (a  * MaxSimb) - 1
           mov   bl, MaxSize
           mul   bl
           mov   bx, offset arr
           add   ax, bx
           dec   ax
           mov   bx, ax
su1:           
           mov   al, [si]            ; [si] = [di]
           mov   [di], al
           
           dec   di
           dec   si
           
           cmp   si, bx              ; проверка на окончание цикла
           jnz   Su1           
           
StrsUp     endp



InsStr     proc
                                     ; ВСТАВИТЬ СТРОКУ В ПОЗИЦИЮ а
                                     ; a = dh
           
           mov   al, dh              ; si = addr_arr + a*MaxSize
           mov   bl, MaxSize
           mul   bl
           mov   bx, offset arr
           add   ax, bx
           mov   si, ax
           
           mov   di, offset st        ; addr_st
           
           mov   ch, 1
i_str1:           
           mov   al, [di]
           mov   [si], al
           
           inc   di
           inc   si
           inc   ch
           
           mov   al, MaxSize+1
           cmp   ch, al
           jnz   i_str1
           
           ret
           
InsStr     endp

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
