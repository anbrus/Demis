.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

IntTable   SEGMENT use16 AT 0
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT use16 AT 40h
;Здесь размещаются описания переменных
 DigCode    DB   ?; 
 DigCodeT    DB   ?
 DigCodeP    DB   ?
 Amplitude    DB    ?
 Image1   DB    0ffaah DUP(?);
           
 flag   DB    ?
 period   DW    ?
 maxtime  db ?
 maxfreq  db ?
 zoom db ?
 total dw ?
 move dw ?
 corp db ?
 once_p db ?
 once_t db ?
 mode db ?
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT use16 AT 100h
;Задайте необходимый размер стека
           dw    16 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант

InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант
Image      db    0ffh,0ffh,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h;
SymImages  db    3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7fh,05fh 
;Cell_num   db    14h,0ah,7h,5h,4h,3h,3h,2h,2h;   
Cell_num   db    64h,032h,21h,19h,14h,10h,0eh,0ch,0bh;   
;limit_freq db    7h,5h,4h,3h,3h,2h,2h,2h,1h 
;limit_time db    9h,8h,5h,2h,2h,1h,1h,1h 
limit_freq db    9h,6h,4h,3h,3h,2h,2h,2h,1h 
limit_time db    9h,8h,5h,3h,2h,1h,1h,1h,1h 
;arr db   9h,6h,4h,3h,2h,2h,2h,2h,1h 

timetwo    db    0Ch,0Ch,76h,76h,5Eh,5Eh,4Dh,4Dh,5Bh      
           ASSUME cs:Code,ds:Data,es:stk
           ;--------------------------------
VibrDestr  PROC  NEAR
           pusha
VD1:       mov   ah,al       ;Сохранение исходного состояния
           mov   bx,0        ;Сброс счётчика повторений
VD2:       in    al,dx       ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   bx          ;Инкремент счётчика повторений
           cmp   bx,04ffh       ;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных
           popa
           ret
VibrDestr  ENDP   
;------------------------------
num_out proc near
         push di                           ;сохраняем регистры
         push ax
         push bx
         push si
         xor di,di                         ;номер в массиве на ноль
         mov ah,DigCode                    ;цифра амплитуды(порт по умолчанию)
         cmp dx,7h                         ;если длительность(7порт вывода)
         jnz nt
         ;---------------------
         mov al,0bfh             ;длительность:пишем первый ноль с точкой 
         out 7, al
         mov al,DigCodeT          ;проверяем четность бывшей переменной         
         xor ah,ah                ;если четно то пишем на конце 5
         mov bl,02h              ;если нет то ноль
         div bl
         cmp ah,0
         jz  kol
         mov al,SymImages[0]
         jmp outim
    kol: mov al,SymImages[5]
    outim: out 0bh,al 
         mov bl,DigCodeT        ;среднюю цифру берём из массива
         xor si,si   
   dfr:  inc si
         dec bl
         jnz dfr
         mov al,timetwo[si-1]
         out 0ah,al
         jmp  hhh         
         ;--------------------
    nt:  cmp dx,8h                         ;если длительность(7порт вывода)
         jnz increm_di
         mov ah,DigCodeP                   ;цифра длительности 
 increm_di:  
         inc di                            ;увеличим индекс
         dec ah                            ;убавим цифру
         jnz increm_di                     ;пока цифра не кончится   
         mov al,SymImages[di]              ;элемент по индексу на вывод
         out dx, al
  hhh:   pop si
         pop bx
         pop ax                            ;восстанавливаем регистры
         pop di
         ret
num_out endp
;-------------------------------------------------
amplitude_modify proc near
          cmp mode,0
          jz no_pr1
          in al,0                          ;читаем 0 регистр
          call VibrDestr                   ; гасим дребезг
          
          cmp al,0feh                      ;нажата первая кнопка
          jnz next1
          mov ah,DigCode                   ;читаем текущее состояние
          cmp ah,7h                        ;если 7 то не надо увеличивать,это максимум
          jz exit
          inc ah                           ;а если не 7 то увеличим на 1
          mov DigCode,ah                   ; и сохраним как текущее
    next1: cmp al,0fdh                     ;нажата вторая кнопка
           jnz exit
           mov ah,DigCode                  ;читаем текущее состояние
           cmp ah,1h                       ;если 1 то не надо уменьшать,это минимум
           jz exit
           dec ah                          ;а если не 1 то уменьшим на 1
           mov DigCode,ah                  ; и сохраним как текущее
    exit:  mov dx,6h                       ;номер порта передаём в процедуру
           call num_out
    no_pr1: nop  
            ret     
amplitude_modify endp
;-------------------------------------------------
time_modify proc near
         
          in al,0                          ;читаем 0 регистр
          call VibrDestr                   ; гасим дребезг
          ;cmp mode,0
          ;jz no_in
          ;------------------------
          cmp al,0fbh                      ;нажата третяя кнопка
          jnz nxt2
          mov bl,1
          mov once_p,bl
          mov ah,DigCodeT                  ;читаем текущее состояние
          cmp ah,limit_time[si-1];           ;не надо увеличивать,это максимум
          jz tz2;exit2; new techtask 
          inc ah                           ;а если не максимум то увеличим на 1
          mov DigCodeT,ah                   ; и сохраним как текущее
          cmp ah,03h
          jnz tpp1
          cmp digcodep,06h
          jnz tpp1 
          mov al,04h
          mov digcodep,al
          jmp exit2
      tpp1: 
    nxt2: cmp al,0f7h                     ;нажата четвёртая кнопка
           jnz exit2
           mov bl,1
           mov once_p,bl
           mov ah,DigCodeT                  ;читаем текущее состояние
           cmp ah,1h                       ;если 1 то не надо уменьшать,это минимум
           jz exit2
           dec ah
                                 ;а если не 1 то уменьшим на 1
           mov DigCodeT,ah                  ; и сохраним как текущее
            cmp ah,03h
            jnz tpp
            cmp digcodep,06h
            jnz tpp 
            mov al,04h
            mov digcodep,al
            jmp exit2
      tpp:  
            jmp exit2 
    tz2:     ;а это ТЗ №2
           ;cmp ah,08h
           ;jz exit2
           mov al,digcodep
           cmp al,01h
           jz exit2
           dec al
           mov digcodep,al
         ;-----------------  
    anov1: ; cmp ah,09h
           ;jz exit3
           cmp al,6
           jz beg_t
           cmp al,4
           jz beg_t
           cmp al,3
           jz beg_t1
           cmp al,2
           jz beg_t1
           cmp al,1
           jz beg_t1
           mov bl,1
           mov once_t,bl
           jmp exit2
 beg_t:    cmp once_t,0
           jz exit2
 beg_t1:    xor bl,bl
           mov once_t,bl
           inc ah
          
           mov DigCodet,ah   
           
                     
         ;-----------------
    exit2: mov dx,7h                       ;номер порта передаём в процедуру
           call num_out
   no_in: ;nop 
           ret     
time_modify endp
;-------------------------------------------------
period_modify proc near
         
          in al,0                          ;читаем 0 регистр
          call VibrDestr                   ; гасим дребезг
          ;--------------------------
          cmp mode,0
          jz no_pr3
          cmp al,0efh                      ;нажата пятая кнопка
          jnz nxt3
           mov bl,1
           mov once_t,bl
          mov ah,DigCodeP                  ;читаем текущее состояние
          
          cmp ah,limit_freq[di-1];         ; не надо увеличивать,это максимум
          jz tz2p;exit3
          inc ah                           ;а если не максимум то увеличим на 1
          mov DigCodeP,ah                   ; и сохраним как текущее
    nxt3: cmp al,0dfh                      ;нажата шестая кнопка
           jnz exit3
            mov bl,1
           mov once_t,bl
           mov ah,DigCodeP                  ;читаем текущее состояние
           cmp ah,01h                       ;если 1 то не надо уменьшать,это минимум
           jz exit3
           dec ah                          ;а если не 1 то уменьшим на 1
           mov DigCodeP,ah                  ; и сохраним как текущее
           jmp exit3
 tz2p:     ;а это ТЗ №2
           mov al,digcodet
           cmp al,01h
           jz anov;exit3
           dec al
           mov digcodet,al
    anov:  cmp ah,09h
           jz exit3
           cmp al,8
           jz beg_p
           cmp al,5
           jz beg_p
           cmp al,3
           jz beg_p
           cmp al,2
           jz beg_p1
           cmp al,1
           jz beg_p1
           mov bl,1
           mov once_p,bl
           jmp exit3
 beg_p:    cmp once_p,0
           jz exit3
          
           ;jmp exit3
            ;cmp ah,1
            ;jnz exit3
 beg_p1:    xor bl,bl
           mov once_p,bl
          ; cmp ah,09h
          ; jz exit3
           inc ah
          
           mov DigCodeP,ah   
          ; mov ah,DigCodeP
          ; cmp ah,arr[di-1]; 
          ; jz exit3
          ; 
          ; inc ah 
          ; mov DigCodeP,ah 
          
         ;----
    exit3:
          mov dx,8h                       ;номер порта передаём в процедуру
           call num_out
    no_pr3:  nop
           ret     
period_modify endp
;-------------------------------------------------
math_array PROC  NEAR                      ; мат обработка массива(пока только амплитуда)
      pusha                                ;сохраняем регистры
      mov al,1                             ;признак второй планки нет
      mov flag,al
      ;---------------------------------
      xor si,si                                       ;определяем сколько
      mov al,DigCodeP                                 ;клеток массива нужно брать
     
repeat1:
      inc si
      dec al
      jnz repeat1
      mov al,cell_num[si-1]
      xor ah,ah
      cmp zoom,1
      jnz normal1
                      ;если кнопка нажата, масштабируем период в 2 раза
      dec ax
      dec ax 
      shr ax,1h
      inc ax
      ;inc ax
     
normal1: 
      mov period,ax
      mov dx,ax
      ;--------------------------------------
 ; ghs:mov ax,dx;это загруз кол-ва элементов массива для вывода 
 ;     shl ax,1;массивами периодами путем их удваивания до значения превыщающего 32
 ;     mov dx,ax
 ;     and ax,0e0h
 ;     jz ghs
      mov total,dx
      ;----------------------------
      xor si,si                            ;обнуляем индекс
      xor di,di
      mov ah,DigCode                       ;грузим номер цифры
      mov cx,01fffh;0e2bh
in_rep: mov dx,0ffh;0affh;448h                           ;грузим счетчик на 32 элемента
  n:  mov al,image[si]                     ;читаем образец
 ;-----------------------;это регулирует длительностьи импульса
      cmp al,0ffh        ;проверяем боковую стойку импульса
      jnz n5             ;если не она то не нужно ничего вставлять
      push dx
      cmp flag,0         ; узнаем попалась ли нам первая стойка или вторая
      jz n7              ;если вторая то вставляем планку между перегородками(длит имп)
      mov dl,0           ;если первая то ставим метку что следующая будет второй
      mov flag,dl
      jmp n8
  n7: mov dl,DigCodeT   ;читаем длительность
     ; dec dl             ;если 1 то ничего вставлять не надо
     ; jz n8
      push ax
      mov al,5
      inc dl
      mul dl
      mov dl,al
      dec dl
      dec dl
      ;надо умножить dl на 5
      pop ax
      cmp zoom,1
      jnz norm
      dec dl
      cmp dl,2
      jz n8
 norm: mov dh,image1[0]  ;ищем на какой высоте вставлять
      shl dh,1
      xor dh,image1[0]
  n6: mov image1[di],dh ;вставляем планку длиной длительность-1
      cmp zoom,1
      jnz normal
                       ;если кнопка нажата, масштабируем планку в 2 раза
      dec dl
      jz dr
normal:
      inc di
      inc si             ;чтобы не раздвигало а съедало полоску
      dec dl
      jnz n6 
  dr: mov dl,1          ;после того как вставили ждём следующей первой планки
      mov flag,dl   
  n8: pop dx
 ;----------------------     это заканчивается длительность и начинается амплитуда
  n5: cmp al,080h                          ;нижнюю полосочку не убираем
      jz n3
      mov bl,7                             ;вычитаем из 7 цифру с индикатора
      sub bl,ah                            ;чтобы получить колличество сдвигов
      jz n3                                ;если не надо сдвигать(амплитуда равна эталонной)
  n1: shl al,1                             ;сдвигаем
      dec bl
      jnz n1
  n3: 
      mov image1[di],al                    ;записываем то что сдвинули или не сдвинули, в новый массив, который и будем выводить
                                           ;чтобы получить колличество сдвигов
      
      inc di                              ; а это разные счетчики.      
      inc si
      
      cmp si,period; из первого массива берём начало импульса с частотой указанной на индикаторе
      jnz n4
      xor si,si
   n4:   
      dec dx
      jnz n
      dec cx
      jnz in_rep    
      popa
       ret
math_array endp
;-------------------------------------------------
bin_out PROC  NEAR
          mov bl,DigCodep
          xor si,si                     ;узнаем максимум в зависимости от другого параметра
     tt:  inc si
          dec bl
          jnz tt
          mov bl,limit_time[si-1];
          mov maxtime,bl               ;запоминаем максимум(в зависиммости от числа берём количество клеток из массива)
          ;-------------------------
          cmp maxfreq,9h;7h               ;проверяем равен ли текущий максимум абсолютному для параметра
          jz off                       ;еслм равен то надо гасить
        
          mov ch,02h;а если не равет то зажигаем
          mov al,cl
          or al,02h;
          out 9,al
        
          jmp ff
     off:               ;гасим
          mov ch,0h
          mov al,cl
          and al, 0fdh
          out 9,al  
             
     ff:  mov bl,DigCodet ;см выше
          xor di,di                        ;узнаём максимум в зависимости от другого параметра
     tt1:  inc di
          dec bl
          jnz tt1
          mov bl,limit_freq[di-1];
          mov maxfreq,bl
          ;---------------------------------
          cmp maxtime,09h
          jz off2
          
          mov cl,01h
          mov al,ch
          or al,01h
          out 9,al
          
          jmp ff2
     off2: 
          mov cl,0h
          mov al,ch
          and al, 0feh
          out 9,al 
              
     ff2: cmp zoom,1;это индикаторы масштаба
          jnz ex
          or al,4h
          and al,7h
          out 9,al
          jmp exi
     ex:  or al,8h
          and al,0fbh
          out 9,al
     exi:
          ret
bin_out endp
;-------------------------------------------------
horiz_time PROC  NEAR ; здесь только отлавливаются ситуации в которых масштабирование реально
          xor al,al
          mov zoom,al
          in al,1
          ;;call vibrdestr
          cmp al,0feh
          jnz return
          cmp DigCodep,09h
          jz return 
          cmp DigCodep,08h
          jz return
          cmp DigCodep,06h
          jz return 
          cmp DigCodep,04h
          jz return 
          cmp DigCodep,03h
          jz return 


          ;------------
          mov al,DigCodet
          and al,01h
          cmp al,0
          jz return
          mov al,1h
          mov zoom,al;значит можно масштабировать
          ;------------
   return: 
          ret
horiz_time endp
;-------------------------------------------------
move_arr  PROC  NEAR
          ; pusha 
           cmp digcodep,1h
           jnz nxt_1
           cmp move,064h
           jz zer
      nxt_1:cmp digcodep,2h
           jnz nxt_2
           cmp move,032h
           jz zer
     nxt_2:cmp digcodep,3h
           jnz nxt_3
           cmp move,021h
           jz zer
     nxt_3:cmp digcodep,4h
           jnz nxt_4
           cmp move,019h
           jz zer
     nxt_4:cmp digcodep,5h
           jnz nxt_5
           cmp move,014h
           jz zer
     nxt_5:cmp digcodep,6h
           jnz nxt_6
           cmp move,010h
           jz zer
     nxt_6:cmp digcodep,7h
           jnz nxt_7
           cmp move,0eh
           jz zer
     nxt_7:cmp digcodep,8h
           jnz nxt_8
           cmp move,0ch
           jz zer
     nxt_8:cmp digcodep,9h
           jnz nxt_9
           cmp move,0bh
           jz zer
     nxt_9:cmp move,0aaaah
           jnz increm
       zer:    xor ax,ax
            mov move,ax
           jmp rty
     increm: inc move
               
     rty:  mov cx,0ffffh
       del:nop
           nop
           loop del 
          ; popa
           ret
move_arr  ENDP   
;----------------------------------------------------
choose_mode proc near
       in al,0                          ;читаем 0 регистр
       call VibrDestr                   ; гасим дребезг
       cmp al,0bfh                      ;нажата 7 кнопка 7f
       jnz sec_mode
       mov ah,01h
       mov mode,ah
       xor ax,ax
       mov move,ax
       jmp out_pr
  sec_mode: cmp al,07fh
        jnz out_pr
        xor ah,ah
        mov mode,ah
  out_pr: nop
        ret    

choose_mode endp
;-------------------------------------------------
out_image  PROC  NEAR
           pusha
           mov    al,1             ;включаем питание
           out   0,al              ;
          ; mov si,0h                ;счетчик массива
           mov si,move
           mov dl,1h               ;выводимый столбец
           mov dh,8h               ;колличество столбцов
 out_start: 
           mov al,dl               ;активируем столбец
           out 2, al               ;
           mov al,image1[si]        ;здесь должен выводиться элемент массива в матрицу 1
           out 1,al                ;
           mov al,image1[si+8h]    ;здесь должен выводиться элемент массива в матрицу 2
           out 3,al                ;
           mov al,image1[si+10h]   ;здесь должен выводиться элемент массива в матрицу 3
           out 4,al                ;
           mov al,image1[si+18h]   ;здесь должен выводиться элемент массива в матрицу 4
           out 5,al                ;
           mov al,image1[si+20h]   ;здесь должен выводиться элемент массива в матрицу 4
           out 0ch,al                ;
           mov al,image1[si+28h]   ;здесь должен выводиться элемент массива в матрицу 4
           out 0dh,al                ;
           mov al,image1[si+30h]   ;здесь должен выводиться элемент массива в матрицу 4
           out 0eh,al                ;
           mov al,image1[si+38h]   ;здесь должен выводиться элемент массива в матрицу 4
           out 0fh,al                ;
           mov al,image1[si+40h]   ;здесь должен выводиться элемент массива в матрицу 4
           out 010h,al                ;
           mov al,image1[si+48h]   ;здесь должен выводиться элемент массива в матрицу 4
           out 011h,al                ;
           mov al,image1[si+50h]   ;здесь должен выводиться элемент массива в матрицу 4
           out 012h,al                ;
           mov al,image1[si+58h]   ;здесь должен выводиться элемент массива в матрицу 4
           out 013h,al     
            mov al,image1[si+60h]   ;здесь должен выводиться элемент массива в матрицу 4
           out 014h,al    
           mov al,image1[si+68h]   ;здесь должен выводиться элемент массива в матрицу 4
           out 015h,al    
          ; mov al,image1[si+70h]   ;здесь должен выводиться элемент массива в матрицу 4
          ; out 016h,al    
           ;mov al,image1[si+78h]   ;здесь должен выводиться элемент массива в матрицу 4
          ; out 017h,al    
           xor al,al               ;гасим столбец
           out 1,al
           out 3,al
           out 4,al
           out 5,al
           out 0ch,al
           out 0dh,al
           out 0eh,al
           out 0fh,al
           out 010h,al
           out 011h,al
            out 012h,al
            out 013h,al
             out 014h,al
            out 015h,al
            ;  out 016h,al
           ; out 017h,al
           inc si                  ;счетчик на следующий элемент
           rol dl,1                ;указатель активной столбца на следующий
           dec dh                  ;модификация счетцика массива
           jnz out_start  
           cmp mode,0
           jnz no_move
           call move_arr
    no_move:       popa  
           ret
out_image  ENDP   
init proc near
           mov al,1
           mov DigCode,al 
           mov DigCodeT,al
           mov once_p,al
           mov mode,al
           ;mov al,1
           mov DigCodeP,al
           xor ax,ax
           mov move, ax
           mov al,09h
           mov maxtime,al
           dec al
           mov maxfreq,al
           ret
init endp
Start:
           
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы
           
          call init
   InfLoop:   
            call bin_out
           ;-------------------
           call amplitude_modify
           cmp mode,0
           jz no_t
           call time_modify
           no_t:
           call period_modify
           call horiz_time
           call math_array 
           call choose_mode
           call out_image
           jmp   InfLoop

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END