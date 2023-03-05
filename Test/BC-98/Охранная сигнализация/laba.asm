.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   8192

kol_d=10h

PortIndP1=09h
PortIndP2=011h
PortIndV1=010h
PortIndV2=012h
zader=0FFh

Data       SEGMENT AT 3000h use16
  datv       db 16 dup (?) ; образ датчиков взлома
  datp       db 16 dup (?) ; образ датциков пожара
  obrkl      db 16 dup (?) ; массив контролируемых комнат 
  Flag       db 16 dup (?) ; образ клавиатуры
  vorr       db ?          ; образ клавиши "Контроль взлома"
  pog        db ?          ; образ клавиши "Контроль пожара"
  Flag_pogar db ?          ;флаг пожара 
  Flag_vor   db ?          ;флаг взлома
  ind_p db 17 DUP(?)       ;массив комнат срабатывания датчиков пожара
  ind_v db 17 DUP(?)       ;массив комнат срабатывания датчиков взлома
  mig_p db ?
  mig_v db ?
  zader2 db ?
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 4180h use16
           dw    10 dup (?)     ;Задайте необходимый размер стека
StkTop     Label Word
Stk        ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант
           ASSUME cs:Code,ds:Data,es:Data
 VOR        db 07Fh,03Fh,067h                 ; коды слова "ВОР"
 POGAR      db 02Fh,03Fh,06Dh,06Dh,06Fh,067h  ; коды слова "ПОЖАР"
 Cicle      db  2h                            ; число регистров контролируемых комнат деленное
                                              ; на 8 (разрядность портов)
        
NullArray  PROC                 ; процедура обнуления массивов данных
           mov al,8
           mul Cicle
           mov si,ax
     nul:  mov obrkl[si-1],0h
           mov datp[si-1],0h
           mov datv[si-1],0h
           dec si
           jnz nul
           ret
NullArray  ENDP

QuizSensorsVor PROC            ; опрос датчиков взлома и формирование их образа
           mov cl,Cicle        ; загружаем количество портов, к которым подключены датчики в
                               ; счетчик внешнего цикла 
           xor ax,ax
   next1:                      
           mov al,2            ; получаем номер  старшего порта 
           mul cl              ;   датчиков взлома
           mov dx,ax           ;
           dec dx              ;   
           in al,dx            ; считываем данные с порта
           
           xor bx,bx           ; адрес страршего элемента
           mov bl,cl           ;   массива образа состояний
           dec bl              ;     датчиков взлома
           shl bl,3            ;
           mov si,8h           ;
   next2:  shl al,1                   ; распаковывоем данные порта о занчениях датчиков
           jnc a1                     ; если датчик сработал, то 
           mov datv[si+bx-1],000h     ;   присваеваем переменной его отражение 0h,
           jmp a2                     ; 
      a1:  mov datv[si+bx-1],0FFh     ;   если нет, то - 0FFh 
      a2:  dec si                     ;   
           jnz next2   
           dec cl
           jne next1   
           ret        
QuizSensorsVor ENDP
           
QuizSensorsPog PROC                   ; Опрос датчиков пожара и формирование их образа
           mov cl,Cicle               ; работа процедуры осуществляемся аналогично
           xor ax,ax                  ;  процедуре "Опрос датчиков взлома" 
   next3:                      
           mov al,2
           mul cl
           mov dx,ax
           sub dx,2
           in al,dx
           
           xor bx,bx
           mov bl,cl
           dec bl
           shl bl,3
           mov si,8h
           
   next4:  shl al,1
           jnc a3
           mov datp[si+bx-1],000h
           jmp a4
      a3:  mov datp[si+bx-1],0FFh
      a4:  dec si
           jnz next4   
           dec cl
           jne next3   
           ret        
QuizSensorsPog ENDP

KeyControl PROC                      ; Формирование данных о комнатах поставленных на контроль
                     
           mov cl,Cicle
           mov al,2
           mul cl
           mov dx,ax
           inc dx
           
   next5:  xor bx,bx
           mov bl,cl
           dec bl
           shl bl,3
           mov si,8h
           
           in al,dx
           
   next6:  shl al,1
           jnc a5
           cmp Flag[si+bx-1],0FFh
           je a6
           xor obrkl[si+bx-1],0FFh
           mov Flag[si+bx-1],0FFh
           jmp a6
      a5:  mov Flag[si+bx-1],000h
      a6:  dec si
           jnz next6  
           dec dx
           dec cl
           jnz next5
           
           add dl,Cicle 
           inc dx
           in  al,dx
           shr al,1
           jnc n1
           mov pog,0FFh
           jmp n2
      n1:  mov pog,000h 
      n2:  shr al,1
           jnc n3
           mov vorr,0FFh
           jmp n4
      n3:  mov vorr,000h 
      n4:
           ret   
KeyControl ENDP


zag_vor    proc near   ;процедура вывода слова ВОР 
           mov dx,0
           mov al,flag_vor
           test al,0FFh
           jz m11           
           lea bx,VOR
      m1:  mov ax,cs:[bx]
           out dx,ax
           inc bx
           inc dx
           cmp bx,2
           jb m1
           ret
      m11: mov al,0h
           out dx,al
           inc dx
           cmp dx,3
           jne m11                
           ret
zag_vor    endp                      

zag_pogar  proc near   ;Процедура вывода слова ПОЖАР
           mov dx,3
           mov al,flag_pogar
           test al,0FFh
           jz m6           
           mov bx,offset POGAR
      m2:  mov ax,cs:[bx]
           out dx,ax
           inc bx
           inc dx
           cmp bx,8
           jb m2
           ret
      m6:  mov al,0h
           out dx,al
           inc dx
           cmp dx,9
           jne m6                
           ret
zag_pogar  endp


prov_datv  proc near ;проверка датчиков взлома
           mov al,vorr    ;проверка на включение всей сигнализации
           test al,0FFh
           jnz mn7
           mov al,0
           mov flag_vor,al ;сброс флага взлома
           test al,0FFh
           jz m7
      mn7: xor ax,ax
           mov flag_vor,al ;сброс флага взлома
           xor cx,cx
           xor di,di
           mov cx,kol_d
           mov di,1
      m10: mov si,cx
           dec si
           mov al,obrkl[si] ;анализ образа клавиатуры
           test al,0FFh      ;проверка нажатых клавиш, если сигнализация в комнате отключена 
           jnz m8             ;то датчик взлома в этой комнате не анализируется
           mov al,datv[si]    ;анализ датчиков взлома при вкл. сигнализации
           test al,0FFh      
           jnz m8
           mov al,0FFh     ;взвод флага взлома
           mov flag_vor,al   
           xor ax,ax
           mov ax,si
           mov ind_v[di],al
           inc di
           
       m8: loop m10
           dec di
           mov ax,di
           mov ind_v[0],al
       m7: ret  
prov_datv  endp 

prov_datp  proc near  ; проверка датчиков пожара
           mov al,pog
           test al,0FFh ;проверка на включение пожарной сигнализации
           jnz m9         ;если не включена то пропустить
           mov al,0
           mov flag_pogar,al
           test al,0FFh
           jz m3
       m9: mov al,0
           lea bp,ind_p
           xor di,di
           mov flag_pogar,al ;сброс флага пожара
           mov di,1
           xor cx,cx
           mov cx,kol_d    ;загрузка счетчика опрашиваемых датчиков 
       m5: mov si,cx
           dec si
           mov al,datp[si]
           test al,0FFh  ;проверка датчика на срабатывание
           jnz m4         ;если датчик то номер комнаты записывается в массив  
           mov [bp+di],si  ;ind_p, начиная с первой ячейки 
           inc di          
       m4:loop m5
           dec di         ;общее колличество комнат, где сработала пожарная сигнализация 
           mov ax,di
           mov [bp+0],al ;в первый элемент массива записываем общее кол. комнат, где есть пожар         
           cmp di,0
           je m3
           mov al,0FFh   ;если сработал хотя бы 1 датчик, то флаг пожар взводиться.
           mov flag_pogar,al   
       m3: ret
prov_datp  endp     

mig_pogara proc near         ;процедура обработки индикаторов пожара
           mov al,pog
           test al,0FFh
           jz m99
           mov al,flag_pogar ;проверка флага пожара
           test al,0FFh      ;если нет пожара, то горят все индикаторы
           jz m22  
           mov al,mig_p      ;проверка флага мигания
           cmp al,0          ;если 0,то
           jne m20
           mov al,mig_p
           mov al,zader       ;установить 16(10) 
           mov mig_p,al
      m20: cmp al,zader2         ;если флаг мигания больше 8, то горят все индикаторы  
           ja m15            ;несмотря на пожар
           xor di,di
           mov cx,0          
           lea bp,ind_p      ;загрузка начального адреса массива номеров комнат, где произошел 
           xor ax,ax         ;пожар, первый элемент массива показывает общее кол. комнат, с огнем
           mov si,1
           mov dx,[bp]
           xor dh,dh
           mov di,dx         ;грузим общее кол. комнат в кот. произошел пожар
      m18: mov dx,0Fh        ;общее кол. всех комнат в офисе
           sub dx,cx         ;определяем номер с конца верхнего этажа
           mov bx,[bp+si]    ;сравниваем этот номер с номером горящей комнаты
           cmp dl,bl         ;если равны, то этот разряд необходимо выделить 
           jne m16
           cmp di,0          ;если не равны, то  
           je m16
           shl ax,1          ;для выделения мы сдвигаем результат на 1 влево 
           add ax,1          ;прибавляем 1, т.е записываем 1 в младший разряд
           dec di            ;уменьшаем кол. горящих комнат 
           inc si            ;переходим к следующему очагу
           jmp m17
      m16: shl ax,1          ;сдвиг результата не 1 влево
      m17: inc cx            ;увеличиваем на 1 счетчик, т.е переходим в следующую комнату
           cmp cx,10h        ;все ли комнаты прошли, если нет то вверх
           jne m18           
           not ax            ;если все то инвертируем все разряды, т.к индикатор загорается 1   
           out 9h,al         ;выводим в порт младшие разряды результата
           mov al,ah
           out 11h,al        ;выводим в порт старшие разряды результата
           mov al,mig_p
           dec al       ;декрементирование переменной мигания,это деляется , чтобы обеспечить
           mov mig_p,al ;равномерное промигивание 
           jmp m19
      m15: mov al,mig_p 
           dec al       ;декрементирование переменной мигания
           mov mig_p,al
      m22: mov ax,0FFh  ;  
           out PortIndP1,al    ;горят все индикаторы отвечающие за пожар
           out PortIndP2,al
           jmp m19
      m99: mov al,000h
           out PortIndP1,al    ;гасим датчики привыключении сигнализации
           out PortIndP2,al     
      m19: ret 
mig_pogara endp
 
ind_vz     proc  near       ;
           mov al,vorr
           test al,0FFh
           jz m98
           mov al,flag_vor ;проверка флага взлома
           test al,0FFh    ;если нет взлома, то индикаторы только горят
           jz m31
           mov al,mig_v
           cmp al,0
           jne m50
           mov al,zader
           mov mig_v,al
      m50: mov al,mig_v 
           dec al       ;декрементирование переменной мигания
           mov mig_v,al
           cmp al,zader2
           ja m26   
           
      m31: xor ax,ax
           xor cx,cx
           mov cx,kol_d
           
      m29: mov si,cx
           dec si
           mov dl,obrkl[si]
           test dl,0FFh
           jnz m28
           shl ax,1
           or ax,01h
           dec cx
           cmp cx,0
           jne m29
           cmp cx,0
           je m30
      m28: shl ax,1
           dec cx
           cmp cx,0
           jne m29     
      m30: out POrtIndV1,al    ;горят все индикаторы отвечающие за взлом
           mov al,ah
           out POrtIndV2,al   ;
           jmp m26
      m98: mov al,000h
           out PortIndV1,al
           out PortIndV2,al     
      m26: ret
ind_vz     endp 

mig_vor      proc near

           mov al,flag_vor ;проверка флага взлома
           test al,0FFh    ;если нет взлома, то выход
           jz m35
           
           mov al,mig_v      ;проверка флага мигания
           cmp al,0          ;если 0,то
           jne m36
           
           mov al,mig_v
           mov al,zader       ;установить 16(10) 
           mov mig_v,al
      m36: cmp al,zader2        ;если флаг мигания больше 8, то горят все индикаторы  
           jbe m35            ;несмотря на взлом
           xor ax,ax
           xor dx,dx
           xor cx,cx
           mov dl,ind_v[0]
           mov di,dx
           mov si,1 
           
      m40: mov dl,0Fh 
           sub dl,cl
           mov bx,si
           mov si,dx
           mov dh,obrkl[si]
           cmp dh,00h
           jne m37      
           
           mov si,bx
           mov dh,ind_v[si]
           cmp dh,dl
           jne m39
           
           cmp di,0
           je m39 
           inc si
           mov bx,si
           dec di
      m37: mov si,bx
           shl ax,1
           or ax,1
           jmp m38
      m39: shl ax,1
      m38: inc cx            ;увеличиваем на 1 счетчик, т.е переходим в следующую комнату
           xor dh,dh     
           cmp cx,10h        ;все ли комнаты прошли, если нет то вверх
           jne m40           
           not ax            ;если все то инвертируем все разряды, т.к индикатор загорается 1   
           out PortIndV1,al  ;выводим в порт младшие разряды результата
           mov al,ah
           out PortIndV2,al  ;выводим в порт старшие разряды результата
           mov al,mig_v
           dec al            ;декрементирование переменной мигания,это деляется , чтобы обеспечить
           mov mig_v,al      ;равномерное промигивание 
      m35: ret
mig_vor      endp 

init       proc near
           xor al,al
           mov mig_p,al
           mov mig_v,al
           mov al,zader
           shr al,1
           mov zader2,al
           ret
init       endp            
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           call  init
           call  NullArray
Nnn:       call  QuizSensorsVor
           call  QuizSensorsPog
           call  KeyControl
           call prov_datp
           call prov_datv
           call zag_vor
           call zag_pogar
           call ind_vz
           call mig_pogara
           call mig_vor
           jmp nnn

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
