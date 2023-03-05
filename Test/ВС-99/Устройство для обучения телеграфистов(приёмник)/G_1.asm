obnul_port proc  near
           mov   OutPort1,0
           mov   al,0                ;Обнуление сигналов выходных портов 
           out   1,al
           mov   OutPort2,0
           out   2,al
           and   OutPort3,0F8h
           mov   OutPort2_5,0
           mov   al,OutPort3
           out   3,al                           
           ret
obnul_port endp  

Tochca     proc  near         
           mov   bx,01h 
           cmp   CountDiod,0
           je    sdv_tka1
           mov   cl,CountDiod
sdv_tka:   shl   bx,1        ;Сдвигаем полосу индикации на 1 диод вправо  
           rcl   dx,1        ;с добавлением "слева" нуля - пустого диода  
           
           loop  sdv_tka           ;Цыкл: пока сх<>0 
sdv_tka1:           
           add   CountDiod,2        ;Два диода заняты под точку(1 точка + 1 пробел)
           mov   fp,1               ;Предотвращает повторный вывод точки и тире 
           mov   BuffOut,01h                     ;только после сигнала с ключа 
           ret
Tochca     endp    

Tyre       proc   near
           mov   bx,07h
           cmp   CountDiod,0  
           je    sdv_tire1     ;Если это тире первое в полосе, то его сдвигать не надо   
           mov   cl,CountDiod  ;Смещаем выводимое тире на количество уже заженых диодов 
sdv_tire:  shl   bx,1         ;Сдвигаем введенный элемент на 4 диода вправо  
           rcl   dx,1         ;с добавлением "слева" нулей  
           loop  sdv_tire            ;Цыкл: пока сх<>0 
sdv_tire1:           
           add   CountDiod,4         ;Четыре диода заняты под тире(3 тире + 1 пробел)Обнул в др проц          
           mov   fp,1            
           mov   BuffOut,07h       
           ret
Tyre       endp
           
delay      proc  near           
           mov   cx,DelayUnits    ;Организуем зажержку
DelayOut:  push  cx               ;числом циклов равным 25000*DelayUnits
           mov   cx,061A8h
DelayIn:   
           loop  DelayIn
           pop   cx
           loop  DelayOut
           ret
delay      endp
           
VibrDestr  PROC
           push  ax
           push  bx
VD1:       mov   ah,al       ;Сохранение исходного состояния
           mov   bh,0        ;Сброс счётчика повторений
VD2:       in    al,dx       ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   bh          ;Инкремент счётчика повторений
           cmp   bh,NMax     ;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных 
           pop   bx
           pop   ax
           ret
VibrDestr  ENDP
;--------------------------Запись буквы------------------------------------------------------------  
RecBukva   proc near             
           mov   al,OutPort1    
           mov   BYTE PTR Bukva,al
           mov   al,OutPort2   
           mov   BYTE PTR Bukva+1,al
           mov   al,OutPort2_5    
           mov   BYTE PTR Bukva+2,al
           mov   BYTE PTR Bukva+3,0
           mov   Flag_Rec,1          ;Разрешаем сравнивать букву      
           ret
RecBukva   endp
;---------------------------Конец записи буквы-----------------------------------------------------
str_mod    proc  near
           push  si
           push  ax
           push  bx
           cmp   Flag_rr,0
           je    rec11
           mov   bl,no           ;Заносим номер буквы в таблице
           mov   ah,0
           mov   al,S_count     ;Порядковый номер буквы в сообщении   
           mov   si,ax
           mov   soobcenye[si],bl 
           add   S_count,1     
rec11:           
           cmp   ind_buk,8
           jb    mode2
           mov   si,0
mode:      
           mov   ah,stroka[si+1]
           mov   stroka[si],ah
           inc   si
           cmp   si,7
           jne   mode
           mov   ah,no
           mov   stroka[7],ah
       
           mov   up,06h            ;  инициализация портов вывода    
           mov   cx,8                     ;Нумерация в строке начинается с 1    
           mov   al,0h
           mov   dx,06h
mm:        out   dx,al  
           inc   up
           loop  mm
           mov   DelayUnits,045h    ;Процедура задержки 
           call  delay 
           
mode2:     mov   si,ind_buk
           mov   ah,no
           mov   stroka[si],ah 
           inc   ind_buk 
           
           pop   bx
           pop   ax
           pop   si
           ret
str_mod    endp

str_out    proc  near 
           push  di
           push  si
         
           
           mov   up,06h            ;  инициализация портов вывода   
           mov   left,014h  
           mov   down,022h
           mov   di,0                      ;Нумерация в строке начинается с 1    
           
           
beg_out:          
           mov   al,stroka[di]
           mul   vosem
           mov   si,ax
           mov   al,01h
           mov   dx,up
           out   dx,al                
           mov   cl,01h 
          
M11:      
           mov   al,0                    ;Вывод буквы 
           mov   dx,down
           out   dx,al   
           mov   al,Image[si]
           mov   dx,left
           out   dx,al        
           mov   al,cl
           mov   dx,down
           out   dx,al       
           inc   si
           shl   cl,1
           jnc   M11
             
           inc   di
           inc   up 
           inc   down
           inc   left 
           
           cmp   di,8
           jne   beg_out
           pop   si
           pop   di     
           ret
str_out   endp
FuncPrep   proc  near             ;Функциональная подготовка
           push  si
           mov   BuffOUT1,0
           mov   ind_buk,0
           mov   OutPort1,0       ;Обнуление сигналов выходных портов 
           mov   OutPort2,0
           mov   OutPort2_5,0
           mov   OutPort3,0 
           mov   OutPort0,0
           mov   InPort1,0      
           mov   Flag1,0          ;Разрешение нажатия   
           mov   Flag2,0          ;кнопок "+1" и "-1"   
           mov   AddrSoob,1       ;Номер сообщения изначально равен 1   
           mov   al,0             ;Вывод еденичного адреса на   
           out   4,al             ;семисегментные 
           mov   al,SymImages[1]  
           out   5,al             ;индикаторы
           mov   ah,Tochka1   
           mov   Scorost,ah      ;Подготовка: скорость - первая
           mov   CountPauza,0     ;Обнуление счетчика длительности паузы 
           mov   CountSygnal,0    ;Обнуление счетчика длительности сигнала 
           mov   FlagSygn,0       ;Флаг начала работы ключа - был ли сигнал до    
                                  ;подсчета длительности паузы 
           mov   FlagProh,0              ;Флаг запрещяющий повторное вычисления паузы                
           mov   CountDiod,0      ;Количество занятых диодов равно 0 
           mov   bx,0FFh          ;Сначала, пока буква не введена ее сравнивать с таблицей не надо 
           mov   Flag_Rec,0      ;Флаг разрешения сравнения и модификации(0 - запрет)
           
           mov   si,0
vvv:       mov   stroka[si],31        ;В строку надо будет занести пробелы
           inc   si 
           cmp   si,8
           jne   vvv
           
           mov   si,0
nnn:       mov   soobcenye[si],31
           inc   si
           cmp   si,64
           jne   nnn
           mov   S_count,0
           
           ;mov   Flag_Read,1  ;1 - Можно пройти подготовку в Чтении
           mov   Fl_razr_read,0 ;0 - Запрет прохождения процедуры Чтения
           mov   testing,0
          
           
           mov   si,1
z2:        mov   bx,0
z1:        mov   mass_soob[si+bx],31   ;Массив всех сообщений 
           inc   bx
           cmp   bx,65
           jne   z1
           mov   Ind_zanyat[si],0  ;Все ячейки свободны
           inc   si
           cmp   si,12
           jne   z2
           mov   si,0
sss:       mov   S_count_mass[si],0
           inc   si
           cmp   si,64
           jne   sss
           mov   Flag_err,0
           mov   Proh_err,0
           
           pop   si
           ret                    
FuncPrep   endp

vvod_reg   proc  near            ;процедура опроса режимов
           push  ax
           push  dx
           push  cx
                
           mov   AddrInc,0       ;Сброс флагов модификации
           mov   AddrDec,0       ;адресов
           in    al,1            ;Ввод переключателей
           mov   dx,1            ;Передача параметров
           call  VibrDestr       ;Гашение дребезга
           mov   InPort1,al
           test  al,20h          ;Если нажата кнопка первая скорость
           jz    scor1
           mov   ah,tochka1
           mov   Scorost,ah      ;Действие, если нажата первая скорость
scor1:     test  al,40h          ;Если вторая
           jz    scor2
           mov   ah,tochka2
           mov   Scorost,ah     ;Действие, если нажата вторая скорость
scor2:     test  al,80h          ;Если третья
           jz    scor3
           mov   ah,tochka3
           mov   Scorost,ah     ;Действие, если нажата третья скорость 
scor3:     
           test  al,01h          ;метки, содержащие символ m относятся к формированию
           jz    m1              ;номера сообщения семисегментных индикаторов                       
           mov   AddrInc,0FFh    ;Проверка, нажата ли клавиша "+1", если да - установка флага AddrInc
           jmp   m2              ;Если это клавиша ""+1" - переход на конец проверки 
m1:        mov   Flag1,0         ;Разрешение нажатия клавиши "+1", если нажата клавиша "-1" 
                                 ;или эти клавишы не нажаты вообще
           test  al,02h          ;Проверка, нажата ли клавиша "+1"
           jz    m2              ;Переход, если она не ражата
           mov   AddrDec,0FFh    ;Если нажата - установка флага AddrDec
           jmp   m3  
m2:        mov   Flag2,0         ;Разрешение нажатия клавиши "-1", если нажата клавиша "+1" 
                                 ;или эти клавишы не нажаты вообще   
m3:        pop   cx
           pop   dx
           pop   ax
           ret
vvod_reg   endp      

vivod_reg  proc  near            ;Процедура отображения установленных режимов
           push  ax
           push  bx
           push  cx
           push  di
           and   OutPort3,0C7h   ;Очистка диодов скорости, если выбрана другая 
           mov   ah,tochka1   
           cmp   Scorost,ah     ;Если скорость равна определенному значению
           je    sv1             ;то переход на (*)
           mov   ah,tochka2
           cmp   Scorost,ah
           je    sv2
           mov   ah,tochka3
           cmp   Scorost,ah
           je    sv3
           jmp   sv_end          ;Если скорость не соответствует установленным значениям,
                                 ;то индикатор не зажгется (OutPort3обнуляется каждый такт)
sv1:       or    OutPort3,08h    ;(*) формирование сигнала выходного порта 3
           jmp   sv_end          ;Переход на вывод сигнала
sv2:       or    OutPort3,10h
           jmp   sv_end
sv3:       or    OutPort3,20h
sv_end:    mov   al,OutPort3
           out   3,al
            
           cmp   AddrInc,0FFh    ;Инкремент адреса?
           jne   outm            ;Переход, если нет
           cmp   AddrSoob,10     ;Номер сообщения равен 10?
           je    outm            ;Переход если да
           cmp   Flag1,0         ;Клавиша "+1" не была нажата в предыдущий такт?
           jne   outm            ;Переход если нет, если да - можно инкрементировать AddrSoob
           mov   Flag1,1         ;Установка флага - была нажата "+1"
           add   AddrSoob,1      ;Этого сложения не будет, усли в предыдущий такт не была    
                                 ;нажата клавиша "-1" или эти клавиши не нажимались вообще
           jmp   m_end
            
outm:      cmp   AddrDec,0FFh    ;Декремент адреса?
           jne   m_end           ;Переход, если нет
           cmp   AddrSoob,1      ;Номер сообщения равен 1?
           je    m_end           ;Переход если да
           cmp   Flag2,0         ;Клавиша "-1" не была нажата в предыдущий такт?
           jne   m_end           ;Переход если нет, если да - можно декрементировать AddrSoob
           mov   Flag2,1         ;Установка флага - была нажата "-1"
           sub   AddrSoob,1      ;Этого вычитания не будет, усли в предыдущий такт не была    
                                 ;нажата клавиша "+1" или эти клавиши не нажимались вообще
m_end:     cmp   AddrSoob,10     ;Если AddrSoob состотит из двух цифр 
           je    viv10           ;то переход на спец. вывод
           mov   bx,AddrSoob     ;Если из одной,
           mov   al,SymImages[bx];то AddrSoob выводится
           out   5,al            ;на младший семисегментный индикатор
           mov   al,0            ;Старший - не подключен
           out   4,al
           jmp   end_viv         ;Переход на конец вывода
viv10:     mov   al,SymImages[1] ;Если AddrSoob равно 10 то в старший семисег. инд. выводим "1"   
           out   4,al 
           mov   al,SymImages[0] ;в младший - "0"   
           out   5,al   
end_viv:   
           mov   di,AddrSoob
           cmp   Ind_zanyat[di],0FFh
           jne   end_pr_viv
           or    OutPort3,40h
           mov   al,OutPort3
           out   3,al
           jmp   end_pr
end_pr_viv:and   OutPort3,0BFh 
           mov   al,OutPort3
           out   3,al 
end_pr:                    
           pop   di
           pop   cx        
           pop   bx
           pop   ax
           ret          
vivod_reg  endp             

vvod_key   proc  near            ;Процедура чтения сигналов Морзе с ключа
           push  ax
           push  bx
           push  cx
           push  dx
           cmp   Fl_razr_read,0
           jne   end_read111
           je    end_read222
end_read111: jmp   end_key  
end_read222: 
           in    al,2
           mov   dx,1 
           call  VibrDestr
           mov   InPort2,al
           test  al,01h          ;Есть сигнал с ключа
           jz    pauza           ;Переход если сигнала нет
           mov   Fl_razr_read,0   ;Запрещение прохождения  процедуры Read 
                                  ;Разрешение только после нажатия кнапки чтения
           or    OutPort0,01h     ;Включить звонок
           mov   al,OutPort0
           out   0,al                       
           mov   CountPauza,0    ;Идет сигнал, значит паузы нет - 
                                 ;счетчик длительности паузы обнуляем                
           mov   fp,0                       
           add   CountSygnal,1   ;Счетчик длительности сигнала увеличиваем на 1
           mov   FlagProh,0      ;Флаг запрещяющий повторное вычисления паузы 
           mov   FlagSygn,1      ;Сигнал был, теперь можно высчитывать паузу
           mov   Fl_pr,0
           jmp   end_key 
                     
pauza:     cmp   Flag_err,1      При ошибке не отключать звонок
           je    end_zvon
           and   OutPort0,0FEh   ;Выключить звонок
           mov   al,OutPort0
           out   0,al 
end_zvon:  
           cmp   FlagSygn,0       ;Сигнал определяется после его окончания. Если сначала   
           je    end2             ;сигнала не было, то пауза не высчитывается   
           jne   end1
end2:      jmp   end_key          ;Переход на конец только с помощью jmp т.к. это дальний переход
end1:                             ;Переход на  FlagSygn:=0 т.к.требуется еще 3 или 5 проходов
                                   ;проц-ры на проверку выдержанной паузы 
                                 
           mov   dx,0
           mov   bx,0
          
           mov   al,Scorost                        
           cmp   CountSygnal,al   ;20 = точка 
           ja    tire             ;Усли сигнал больше, то это тире, если меньше - точка 
           cmp   fp,0             ;Усли точка уже была выведена, то переход на    
           jne   ftl              ;конец вывода точки/тире  
           call  Tochca
           jmp   vivod
tire:      cmp   fp,0             ;Усли тире уже было выведено, то переход на    
           jne   ftl              ;конец вывода точки/тире  
           call  Tyre
vivod:     
           or    OutPort1,bl         ;Обеденим только что введенный символ (точка или тире)
           or    OutPort2,bh         ;с ранее ввенденными на полосу индикации
           or    OutPort2_5,dl 
           cmp   CountDiod,21        ;Если вся полоса индикации занято сигналами, то принудительный 
           ja    End_Key
           mov   al,OutPort1         ;Вывод точек и тире на полосу индикации
           out   1,al
           mov   al,OutPort2
           out   2,al
           mov   al,OutPort2_5
           or    OutPort3,al         ;Порт 3 еще занимают индикаторы скорости, по этому надо
           mov   al,OutPort3         ;добавить к сигналу OutPort3 принатый с ключа сигнал
           out   3,al                     
ftl:      
           mov   CountSygnal,0       ;Обнуление счетчика длительности сигнала
           add   CountPauza,1        ;Увеличение счетчика паузы   
           cmp   FlagProh,1 
           je    srav5pauz
           mov   al,Scorost
           mul   try
           cmp   CountPauza,al       ;""Блок сравнения паузы в 3 точки""
           jb    end_key 
           mov   FlagProh,1     
           call  RecBukva            ;Процедура записи буквы(выполнить до обнуления сигналов портов) 
           mov   CountDiod,0 
           call  obnul_port           
srav5pauz: 
           mov   al,Scorost
           mul   pyat
           cmp   CountPauza,al           ;""Блок сравнения паузы в 5 точки""
           jb    end_key
           mov   FlagProh5,0             ;Флаг запрещяющий повторное вычисления паузы
           mov   WORD PTR Bukva,0
           mov   WORD PTR Bukva+2,0
           mov   Flag_Rec,1              ;Разрешаем сравнивать букву
           mov   FlagSygn,0                    
end_key:         
           pop   dx         
           pop   cx                                     
           pop   bx
           pop   ax
           ret
vvod_key   endp