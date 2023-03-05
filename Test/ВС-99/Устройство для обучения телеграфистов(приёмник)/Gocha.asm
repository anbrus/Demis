                                                             
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096                                                                
                                

IntTable   SEGMENT AT 0 use16
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS
  
Data       SEGMENT AT 1F40h use16
;Здесь размещаются описания переменных
           soobcenye  db    64  dup (?);Одно сообщение (64 символа включая прпобелы)
           ;mass_soob  db  10 dup (64 dup (?))   ;Массив всех сообщений
           BuffOut    db    ? 
           BuffOUT1   db    ?      ;Вычисление последнего сигнала, введенного в полосу         
                                                               
           S_count    db    ?      ;Номер буквы в сообщении       
           Scorost    DB    ?      ;Значение скорости                 
          ; Read_Rec   db    ?                                  
           AddrInc    db    ?      ;Флаг нажатия кнопки "+1" 
           AddrDec    db    ?      ;Флаг нажатия кнопки "-1"
           OutPort1   db    ?      ;Сигнал на порт 1  
           OutPort2   db    ?      ;Сигнал на порт 2  
           OutPort2_5 db    ?      ;Промежуточная переменная перед записью данных в порт 3  
           OutPort3   db    ?      ;Сигнал идет на порт 3   
           OutPort0   db    ? 
           mass_soob  db  11 dup (64 dup (?))   ;Массив всех сообщений
           InPort1    db    ? 
           InPort2    db    ? 
           AddrSoob   dw    ?      ;Номер сообщения
           AddrSoob1  dw    ?   
           Flag1      db    ?      ;Флаг, запрещающий повторное снятие сигнала с кнопки "+1",
                                   ;если кнопка нажата несколько тактов программы  
           Flag2      db    ?      ;Флаг, запрещающий повторное снятие сигнала с кнопки "-1", 
                                   ;если кнопка нажата несколько тактов программы 
           CountPauza   db  ?      ;Счетчик длительности паузы 
           CountSygnal  db  ?      ;Счетчик длительности сигнала  
           FlagKey1   db    ?   
           FlagKey2   db    ?    
           FlagSygn   db    ?      ;Флаг: был ли сигнал? Если нет - процедура vvod_key пропускается
           DelayUnits dw    ? 
           fp         db    ?      ;Флаг предотвращает повторное снятие точки с замкнутого ключа  
           CountDiod  db    ?      ;В полосе индикации возможно зажигание только  до 19 диодов  
           Bukva      dd    ?      ;Одна буква 
           Bukva1     dd    ?
           FlagProh   db    ?      ;Флаг разрешающий прохождение через участок подсчета пауз в 3 и 5 точек       
                                   ;и запрещающий это прохождение если вычислена пауза в 5 точек
           up         dw     ?     ;Инициализация портов вывода матричных индикаторов  
           down       dw     ?
           left       dw     ? 
           no         db     ?       ;Номер буквы в массиве отображений Image2
           no1        db     ?
           Flag_Rec   db     ?       ;Флаг предотвращает повторный вывод буквы на матр. диспл.
           Fl_pr      db     ?       ;Флаг предотвращает повторную запись сигналов в букву
           ind_buk    dw     ?
           stroka     db  8 dup(?)   ;Номера букв, содержащихся в строке (изначально-пробелы)
             
           S_count_mass  db  64 dup (?)        ;Количество букв в каждом сообщении
           Ind_zanyat  db  11 dup (?)
           Flag_Read   db    ?       ;От повторного прохождения подготовки в Чтении 
           Fl_razr_read  db  ?       ;Разрешает работу процедуры Read
           Fl_razr_read1  db  ?       ;Разрешает работу процедуры Read
           CountSygnal1  db  ?
           CountPauza1   db  ?
           CountDiod1    db  ?
           toch_tyr      db  ?         ;Точка или тире выведена в последний раз
           testing       dw  ?
           Flag_time     db  ?
           timing        dw  ?      Задержка между выводом сигналов
           scor_dec      db  ?
           Flag_dec      db  ?
           S_count1      db  ?
           S_count2      db  ?  ;счетчики количества букв в сообщении S_count1 инкрементируется до
                                ;S_count2 и сравнивается с ним 
           Flag_rr       db  ?  ;Букву надо занести в строку
           Flag_reset    db  ? 
           Flag_err      db  ?
           Proh_err      db  ? 
           delay_err     db  ?   
           Flag_probel   db  ? 
           Fl_pos_prob   db  ?
           FlagProh5     db  ?
           Dlit_zvonka   dw  ?
           Flag_zad_proh db  ?
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 100h use16
;Задайте необходимый размер стека
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант
InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант
NMax       db      50           
SymImages  db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh
 vosem     db     8
 dva       db     2
 try       db     3
 trdva     db     4
 p1        db     6
 pyat      db     9   ;5 точек - длинный пробел
 DlitSoob  db     64
 Tochka1   db     20 
 Tochka2   db     10
 Tochka3   db     5
           ASSUME cs:Code,ds:Data,es:Data

;------------------------------------------------------------------------------------
Image      db    0000000b,1111100b,0010010b,0010001b,0010001b,0010010b,1111100b,0000000b  ;"А"0
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,0110000b,0000000b  ;"Б"1
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,0110110b,0000000b  ;"В"2
           db    0000000b,1111111b,0000001b,0000001b,0000001b,0000001b,0000011b,0000000b  ;"Г"3
           db    0000000b,1100000b,0111100b,0100010b,0100001b,0111111b,1100000b,0000000b  ;"Д"4
           db    0000000b,1111111b,1001001b,1001001b,1001001b,1001001b,1001001b,0000000b  ;"Е"5
           db    0000000b,1111111b,0001000b,1111111b,0001000b,1111111b,0000000b,0000000b  ;"Ж"6
           db    0000000b,0100010b,1000001b,1000001b,1001001b,1001001b,0110110b,0000000b  ;"З"7
           db    0000000b,1111111b,0100000b,0010000b,0001000b,0000100b,1111111b,0000000b  ;"И"8
           db    0000000b,1111111b,0100000b,0010001b,0001001b,0000100b,1111111b,0000000b  ;"Й"9
           db    0000000b,1111111b,0001000b,0001000b,0010100b,0100010b,1000001b,0000000b  ;"K"10
           db    0000000b,1111100b,0000010b,0000001b,0000001b,0000010b,1111100b,0000000b  ;"Л"11
           db    0000000b,1111111b,0000010b,0000100b,0000100b,0000010b,1111111b,0000000b  ;"М"12
           db    0000000b,1111111b,0001000b,0001000b,0001000b,0001000b,1111111b,0000000b  ;"Н"13
           db    0000000b,0111110b,1000001b,1000001b,1000001b,1000001b,0111110b,0000000b  ;"О"14
           db    0000000b,1111111b,0000001b,0000001b,0000001b,0000001b,1111111b,0000000b  ;"П"15
           db    0000000b,1111111b,0001001b,0001001b,0001001b,0001001b,0000110b,0000000b  ;"Р"16
           db    0000000b,0111110b,1000001b,1000001b,1000001b,1000001b,0100010b,0000000b  ;"С"17
           db    0000000b,0000001b,0000001b,1111111b,0000001b,0000001b,0000000b,0000000b  ;"Т"18
           db    0000000b,1001111b,1001000b,1001000b,1001000b,1001000b,1111111b,0000000b  ;"У"19
           db    0000000b,0001111b,0001001b,1111111b,0001001b,0001111b,0000000b,0000000b  ;"Ф"20
           db    0000000b,1100011b,0010100b,0001000b,0001000b,0010100b,1100011b,0000000b  ;"Х"21
           db    0000000b,0111111b,0100000b,0100000b,0100000b,0111111b,1000000b,0000000b  ;"Ц"22
           db    0000000b,0001111b,0001000b,0001000b,0001000b,0001000b,1111111b,0000000b  ;"Ч"23
           db    0000000b,1111111b,1000000b,1111111b,1000000b,1111111b,0000000b,0000000b  ;"Ш"24
           db    0000000b,1111111b,1000000b,1111111b,1000000b,1111111b,1000000b,0000000b  ;"Щ"25
              ;db    0000000b,0000001b,1111111b,1001000b,1001000b,1001000b,0110000b,0000000b  ;"Ъ"26
           db    0000000b,1111111b,1001000b,1001000b,1001000b,0110000b,1111111b,0000000b  ;"Ы"26
           db    0000000b,1111111b,1001000b,1001000b,1001000b,0110000b,0000000b,0000000b  ;"Ь"27
           db    0000000b,1000001b,1000001b,1000001b,1001001b,1001001b,0111110b,0000000b  ;"Э"28
           db    0000000b,1111111b,0001000b,0111110b,1000001b,1000001b,0111110b,0000000b  ;"Ю"29
           db    0000000b,1000110b,0101001b,0011001b,0001001b,0001001b,1111111b,0000000b  ;"Я"30
           db    0000000b,0000000b,0000000b,0000000b,0000000b,0000000b,0000000b,0000000b  ;"_"31(Пробел)
           db    0000000b,0000100b,0000010b,0000001b,0000100b,0000010b,0000001b,0000000b  ;" " "32
           db    0000000b,0000000b,0000000b,0110110b,0110110b,0000000b,0000000b,0000000b  ;":"33
           db    0000000b,0000000b,0000000b,1101111b,1101111b,0000000b,0000000b,0000000b  ;"!"34
              ;db    0000000b,0000000b,0000000b,0000000b,1000001b,0111110b,0000000b,0000000b  ;")"
              ;db    0000000b,0000000b,0000000b,0000000b,0111110b,1000001b,0000000b,0000000b  ;"("
           db    0000000b,0000000b,0000000b,1100000b,1100000b,0000000b,0000000b,0000000b  ;"."35
           db    0000000b,0001000b,0001000b,0001000b,0001000b,0001000b,0001000b,0000000b  ;"-"36
              ;db    0000000b,0001000b,0101010b,0011100b,1111111b,0011100b,0101010b,0001000b  ;"*"
              ;db    0000000b,0000000b,1000001b,0100010b,0010100b,0001000b,0000000b,0000000b  ;">"
              ;db    0000000b,0000000b,0001000b,0010100b,0100010b,1000001b,0000000b,0000000b  ;"<"
           db    0000000b,0000000b,1000000b,0110110b,0010110b,0000000b,0000000b,0000000b  ;";"37
           db    0000000b,0000010b,0000001b,1101001b,1101001b,0001001b,0000110b,0000000b  ;"?"38
           db    0000001b,0000010b,0000100b,0001000b,0010000b,0100000b,1000000b,0000000b  ;"\"39(Скобки)
           db    1000000b,0100000b,0010000b,0001000b,0000100b,0000010b,0000001b,0000000b  ;"/"40(Дробная черта)
           db    0000000b,0000000b,1000000b,0110000b,0010000b,0000000b,0000000b,0000000b  ;","41
           db    0000000b,0111110b,1010001b,1001001b,1000101b,0111110b,0000000b,0000000b  ;"0"42
           db    0000000b,0000000b,1000010b,1111111b,1000000b,0000000b,0000000b,0000000b  ;"1"43
           db    0000000b,1000010b,1100001b,1010001b,1001001b,1000110b,0000000b,0000000b  ;"2"44
           db    0000000b,0100010b,1000001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"3"45
           db    0000000b,0001100b,0001010b,0001001b,1111111b,0001000b,0000000b,0000000b  ;"4"46
           db    0000000b,1000111b,1000101b,1000101b,1000101b,0111001b,0000000b,0000000b  ;"5"47
           db    0000000b,0111100b,1000110b,1000101b,1000101b,0111000b,0000000b,0000000b  ;"6"48
           db    0000000b,1000001b,0100001b,0010001b,0001001b,0000111b,0000000b,0000000b  ;"7"49
           db    0000000b,0110110b,1001001b,1001001b,1001001b,0110110b,0000000b,0000000b  ;"8"50
           db    0000000b,0000110b,1001001b,0101001b,0011001b,0001110b,0000000b,0000000b  ;"9"51
           
Image2     dd       00000000000000000000000000011101b  ;А 0
           dd       00000000000000000000000101010111b  ;Б 1
           dd       00000000000000000000000111011101b  ;В 2
           dd       00000000000000000000000101110111b  ;Г 3
           dd               01010111b  ;Д 4
           dd                     01b  ;Е 5
           dd             0111010101b  ;Ж 6
           dd           010101110111b  ;З 7
           dd                   0101b  ;И 8
           dd         01110111011101b  ;Й 9  
           dd             0111010111b  ;К 10
           dd             0101011101b  ;Л 11
           dd               01110111b  ;М 12
           dd                 010111b  ;Н 13
           dd           011101110111b  ;О 14
           dd           010111011101b  ;П 15
           dd               01011101b  ;Р 16
           dd                 010101b  ;С 17
           dd                   0111b  ;Т 18
           dd               01110101b  ;У 19
           dd             0101110101b  ;Ф 20
           dd               01010101b  ;Х 21
           dd           010111010111b  ;Ц 22
           dd         01011101110111b  ;Ч 23
           dd       0111011101110111b  ;Ш 24
           dd         01110101110111b  ;Щ 25
           dd         01110111010111b  ;Ы 26 
           dd           011101010111b  ;Ь 27
           dd           010101110101b  ;Э 28
           dd           011101110101b  ;Ю 29
           dd           011101011101b  ;Я 30
           dd                      0b  ; _ 31 (Пробел)                  
           dd       0101110101011101b  ; " 32   
           dd     010101011101110111b  ; : 33   
           dd   01110111010101110111b  ; ! 34  
           dd           010101010101b  ; . 35
           dd       0111010101010111b  ; - 36
           dd       0101110111010111b  ; ; 37
           dd       0101011101110101b  ; ? 38           
           dd   01110101110111010111b  ; \ 39 (Скобки)          
           dd         01011101010111b  ; / 40 (Дробная черта)      
           dd     011101011101011101b  ; , 41
           dd   01110111011101110111b  ; 0 42
           dd     011101110111011101b  ; 1 43
           dd       0111011101110101b  ; 2 44
           dd         01110111010101b  ; 3 45
           dd           011101010101b  ; 4 46
           dd             0101010101b  ; 5 47  
           dd           010101010111b  ; 6 48
           dd         01010101110111b  ; 7 49       
           dd       0101011101110111b  ; 8 50
           dd     010111011101110111b  ; 9 51
           
;------------------------------------------------------------------------------------------------          


Sravnenie  proc  near
           push  ax
           push  cx
           push  bx
           push  dx
           push  si
           cmp   Flag_Rec,0
           je    end_s
           mov   bx,WORD PTR Bukva
           mov   dx,WORD PTR Bukva+2
srav_tab1: mov   si,0
           mov   cl,0               ;Цыкл выполняется 51 раз(кол-во элементов в таблице)   
srav_tab:  cmp   bx,WORD PTR Image2[si]        
           jne   end_srav
           cmp   dx,WORD PTR Image2[si+2]        
           jne   end_srav
           jmp   end_s1
end_srav:  add   si,4
           inc   cl
           cmp   cl,52
           jne   srav_tab
           mov   Flag_err,1         ;Если данной буквы нет в таблице, то сообщение об ошибке
end_s1:    mov   Flag_Rec,0
           cmp   Flag_err,1
           je    end_s
           mov   no,cl
           mov   Flag_rr,1          ;Букву надо занести в строку
           call  str_mod            ;Процедура модификации выводимой строки(в сх лежит номер буквы
end_s:                
           pop   si
           pop   dx
           pop   bx
           pop   cx
           pop   ax
           ret
Sravnenie  endp

Reset      proc  near
           push  si
           
           test  InPort1,04h
           jz    end_res11
           jnz   end_res12
 end_res11:jmp    end_res1
 end_res12:           
           mov   si,AddrSoob
           cmp   Ind_zanyat[si],0
           jne   ddd
           mov   si,0
nnn44:     mov   soobcenye[si],31
           inc   si
           cmp   si,64
           jne   nnn44
           mov   S_count,0
ddd:           
           mov   FlagSygn,0
           mov   si,0
vvv4:      cmp   stroka[si],31        ;В строку надо будет занести пробелы
           jne   vvv5
           inc   si 
           cmp   si,8
           jne   vvv4 
           cmp   Flag_reset,0
           je    end_res
           mov   si,AddrSoob
           mov   S_count_mass[si],0
           mov   Ind_zanyat[si],0
           mov   si,0
nnn4:      mov   soobcenye[si],31
           mov   mass_soob[si],31
           inc   si
           cmp   si,64
           jne   nnn4
           mov   S_count,0
           
vvv5:      mov   Flag_reset,0
           mov   si,0    
res_str:   mov   stroka[si],31        ;В строку надо занести пробелы
           inc   si 
           cmp   si,8
           jne   res_str
           mov   ind_buk,0
           call  obnul_port
           mov   Fl_razr_read,0   ;Запрещение прохождения  процедуры Read 
           jmp   end_res          ;Разрешение только после нажатия кнапки чтения      
end_res1:  mov   Flag_reset,1                       
end_res:   
           pop   si
           ret
Reset      endp

Recorde    proc  near
           test  InPort1,08h
           jz    end_rcrd1
           jnz   end_rcrd2
end_rcrd1: jmp   end_rcrd            
end_rcrd2:           
           mov   si,0
vvv_rec:   cmp   stroka[si],31        ;Пробелы записывать не надо
           jne   vvv_rec_beg
           inc   si 
           cmp   si,8
           jne   vvv_rec 
          jmp   end_rcrd
vvv_rec_beg:mov  FlagSygn,0           
           push  si
           push  di            ;Номер сообщения
           push  bx            ;Номер буквы в сообщении 
           push  cx            ;Всего было введено букв в сообщение
           mov   si,0

           mov   si,0
vvv3:      mov   stroka[si],31        ;В строку надо будет занести пробелы
           inc   si 
           cmp   si,8
           jne   vvv3          
           
           mov   cl,S_count
         
           mov   di,AddrSoob
           mov   S_count_mass[di],cl
           mov   Ind_zanyat[di],0FFh
           mov   ax,di
           mov   ah,0
           mul   DlitSoob
           mov   di,ax
           mov   bx,0  
beg_rec:   cmp   cl,0
           je    end_rec
           mov   al,soobcenye[bx]
           ;cmp   cl,1            ;Если последний - пробел, то его записывать не надо
           ;jne   cms
           ;cmp   al,31
           ;jne    cms
           ;dec   S_count ;
           ;dec   S_count_mass[di]
           ;jmp    cms1
           
cms:       mov   mass_soob[di+bx],al
           
           
cms1:     
           inc   bx
           dec   cl
           jmp   beg_rec                         
end_rec:   mov   Ind_buk,0 
           mov   bx,0
nach_stir: mov   soobcenye[bx],31
           inc   bx
           cmp   bx,64
           jne   nach_stir
           mov   S_count,0     
           pop   cx
           pop   bx
           pop   di
           pop   si   
end_rcrd:            
            ret
Recorde     endp

podschet_pauza  proc  near
          
           cmp   CountSygnal1,1
           jne   sign_tire
           
           push  cx
           push  bx
           push  dx
           mov   dx,0
           mov   bx,01h
           cmp   CountDiod1,0
           je    tka2
           mov   ch,0
           mov   cl,CountDiod1
tka1:      shl   bx,1        ;Сдвигаем полосу индикации на 1 диод вправо  
           rcl   dx,1        ;с добавлением "слева" нуля - пустого диода  
           loop  tka1           ;Цыкл: пока сх<>0 
tka2:      mov   toch_tyr,0
           jmp   viv_polosa
           
sign_tire: push  cx
           push  bx
           push  dx
           mov   dx,0
           mov   bx,07h
           cmp   CountDiod1,0
           je    m_tire2
           mov   ch,0
           mov   cl,CountDiod1
m_tire1:   shl   bx,1        ;Сдвигаем полосу индикации на 1 диод вправо  
           rcl   dx,1        ;с добавлением "слева" нуля - пустого диода  
           loop  m_tire1           ;Цыкл: пока сх<>0 
m_tire2:   mov   toch_tyr,1 
viv_polosa:
           or    OutPort1,bl         ;Обеденим только что введенный символ (точка или тире)
           or    OutPort2,bh         ;с ранее ввенденными на полосу индикации
           or    OutPort2_5,dl
           call  Out_Port_zader
          
           pop   dx                                                                             
           pop   bx
           pop   cx
           mov   ah,0
           mov   al,Scorost
           mov   Dlit_zvonka,ax
           cmp   toch_tyr,0          ;если тире, то
           jne   met_zader1
           mul   dva
           jmp   met_zader2
met_zader1:add   Dlit_zvonka,ax
           add   Dlit_zvonka,ax
           mul   trdva  
met_zader2:  
           mov   Scor_dec,al 
           mov   Flag_zad_proh,1
           ret
podschet_pauza  endp

zader      proc  near               ;проц-ра должна формировать флаг2 прох. Read 
           cmp   Flag_probel,1
           je    vycl_zvon2
           cmp   Flag_zad_proh,0
           je    vycl_zvon
           or    OutPort0,01h            ;Включить звонок
           mov   al,OutPort0
           out   0,al  
           dec   Dlit_zvonka
           mov   Flag_zad_proh,0
vycl_zvon: 
           cmp   Dlit_zvonka,0
           jne   vycl_zvon1
           and   OutPort0,0FEh           ;Выключить звонок
           mov   al,OutPort0
           out   0,al
           ;mov   Flag_probel,1    
vycl_zvon1:dec   Dlit_zvonka                 
vycl_zvon2:                           
           dec   Scor_dec      
           cmp   Scor_dec,0
           je    metka2
           mov   Flag_dec,0
           jmp   metka3
metka2:     
           mov   Flag_dec,1
           mov   Flag_zad_proh,1
metka3:        
           ret
zader      endp   

Out_Port_zader  proc  near 
           mov   al,OutPort1         ;Вывод точек и тире на полосу индикации
           out   1,al
           mov   al,OutPort2
           out   2,al
           mov   al,OutPort2_5
           or    OutPort3,al         ;Порт 3 еще занимают индикаторы скорости, по этому надо
           mov   al,OutPort3         ;добавить к сигналу OutPort3 принатый с ключа сигнал
           out   3,al  
           ret
Out_Port_zader endp   
Podgotovka  proc  near
           mov   Flag_Read,0
           mov   CountSygnal1,0 
           mov   CountPauza1,0
           mov   CountDiod1,0 
           cmp   S_count2,0
           je    end_read1
           jne   end_read3
end_read1: mov   Fl_razr_read,0   ;Запрещение прохождения этой процедуры
           jmp   end_read
end_read3: mov   di,AddrSoob1
           mov   ax,di
           mov   ah,0
           mul   DlitSoob
           mov   di,ax
           mov   bh,0
           mov   bl,S_count1;    -------------------------------
           mov   al,mass_soob[di+bx];;;;;
           dec   S_count2            ;Уменьшаем количество всех букв в сообщении(массив кол-ва букв)
           cmp   S_count2,0
           jne   posled_ne
           mov   Fl_pos_prob,1      ;Если последний символ - прорбел, то его выводить не надо
           jmp   posled_ne1
posled_ne: mov   Fl_pos_prob,0  
posled_ne1:        
           inc   S_count1            ;Одновременно перебираем все буквы от первой до последней                                                  
           mov   no,al
           cmp   no,31              ;Если надо вывести пробел, то установка соответствующего флага
           jne   noy_probel
           mov   Flag_probel,1
           jmp   noy_probel1
noy_probel:mov   Flag_probel,0
;noy_probel1:
           mul   trdva            ;*4
           mov   si,ax               ;Номер буквы
           
           mov   dx,WORD PTR Image2[si]        
           mov   WORD PTR Bukva1,dx
           mov   dx,WORD PTR Image2[si+2]        
           mov   WORD PTR Bukva1+2,dx  
           mov   testing,01h
           ret
Podgotovka endp                            
;---------------------------------------------------Чтение-----------------------------------------
Read       proc  near
          
           test  InPort1,10h 
           jz    begin  
           mov   bx,0
nach_stir1:mov   soobcenye[bx],31
           inc   bx
           cmp   bx,64
           jne   nach_stir1
           mov   S_count,0 
           mov   Fl_razr_read,1   ;Разрешение прохождения этой процедуры
           mov   Flag_zad_proh,0
           mov   ind_buk,0
           mov   ax,AddrSoob
           mov   AddrSoob1,ax 
           mov   si,0
vvv1:      mov   stroka[si],31        ;В строку надо будет занести пробелы
           inc   si 
           cmp   si,8
           jne   vvv1
           mov   Flag_dec,1
           mov   Flag_Read,1
           mov   di,AddrSoob
           mov   cl,S_count_mass[di]
           mov   S_count2,cl     ;Количество букв в сообщении;;;;;;;;;;;;;
           mov   S_count1,0;--------------------------
           
begin:     cmp   Fl_razr_read,1
           jne   end_read11
           je    end_read22
end_read11: jmp   end_read  
end_read22: 
           

        
           cmp   Flag_dec,1
           jne   proc_zad1         ;На процудуру отвечающую за флаг задержки
           je    proc_zad2
proc_zad1: jmp   proc_zad 
proc_zad2:          
           cmp   Flag_Read,1
           jne   proc_read    ;На процедуру отвечающую за флаг прохождения подготовки
 ;-------------------------------------Подготовка---------------------------------------------- 
           call  Podgotovka
proc_read: mov   cx,testing 
sign:      test  WORD PTR Bukva1,cx      ;Сравниваем побайтно букву
           jz    pauz
           inc   CountSygnal1
           mov   CountPauza1,0   
           shl   cx,1
           jmp   sign
pauz:      shl   cx,1
           cmp   CountSygnal1,0
           je    Dve_pz
           call  podschet_pauza
           cmp   cx,0
           jne   nedlinbukv
           mov   cx,01h
           mov   ax,WORD PTR Bukva1+2
           mov   WORD PTR Bukva1,ax
nedlinbukv:mov   testing,cx
                          
Dve_pz:    
           inc   CountPauza1 
           mov   ah,CountSygnal1
           inc   ah
           add   CountDiod1,ah 
           mov   CountSygnal1,0  
           cmp   CountPauza1,1  
           je    end_pauza 
           mov   Flag_rr,0         ;Запись в сообщение произхводить не надо
           jmp   str_mod_met             
noy_probel1:cmp  Fl_pos_prob,1
           jne   str_mod_met
           mov   Fl_razr_read,0   ;Запрещение прохождения этой процедуры
           jmp   end_read
str_mod_met:
           mov   Flag_rr,1
           call  str_mod  
           call  obnul_port                                                                                                       
           mov   Flag_Read,1 
           cmp   Flag_probel,1
           mov   al,Scorost
           jne   dalee_re
           mul   p1
           jmp   dalee_scor                         ;-----------------------------???????????/??///
dalee_re:  mul   try 
dalee_scor:mov   scor_dec,al
           mov   Flag_probel,1
end_pauza:                 
proc_zad:  call  zader         
end_read:                    
           ret
Read       endp

Eerr       proc  near
           cmp   Flag_err,0
           je    end_err
           cmp   Proh_err,1
           je    begin_err
           mov   Proh_err,1
           mov   flagSygn,0
           mov   delay_err,02Fh
begin_err: cmp   delay_err,0
           je    err_diod
           or    OutPort3,80h
           mov   al,OutPort3
           out   3,al
           or    OutPort0,01h
           mov   al,OutPort0
           out   0,al
           dec   delay_err
           jmp   end_err
err_diod:  mov   Flag_err,0 
           and   OutPort3,07Fh 
           mov   al,OutPort3
           out   3,al
          ; test  InPort2,01h   ;Не выключать звук если нажат ключ!!!!!!!
          ; jz    err_dalee
           and   OutPort0,0FEh
           mov   al,OutPort0
           out   0,al
err_dalee: mov   Flag_err,0 
           mov   Proh_err,0    
end_err:           
           ret
Eerr       endp           
Include    G_1.asm                                                          
Start:
           mov   ax,Data
           mov   ds,ax                                
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы
           xor   ax,ax
           call  FuncPrep        ;Функциональная подготовка      
Cont:      call  vvod_reg 
           call  vivod_reg
           call  vvod_key
           call  Sravnenie                                                                       
           call  Reset
           call  Recorde
           call  Read
           call  Eerr
           call  str_out                ;Вывод строки
           mov   DelayUnits,3            ;Процедура задержки 
           call  delay 
           jmp Cont
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
