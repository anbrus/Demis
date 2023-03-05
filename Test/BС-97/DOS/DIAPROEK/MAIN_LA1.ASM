page 50,120

      ;Программа работы устройства управления диапроектором

                        NAME diaproektor

      ;Описание данных
Data1 segment at 0ba00h

       ;Описание используемых переменных

       FirstDig  db 31 dup(?)
       SecondDig db 31 dup(?)
       SlideMas  db 20 dup(?)       
       Delay     db        ?
       MasLength db        ? 

       ;Описание флагов 

       StepShow   db ?
       AutoShow   db ?
       SetMode    db ?
       ShowMode   db ? 
       ForwMove   db ?
       BackMove   db ?
       PrepData   db ?
       NomSet     db ?
       DelSet     db ? 
       DelReady   db ?
       SlMasReady db ?
       AutoReady  db ?
       StepReady  db ?
       Return     db ?
Data1 ends

      ;Описание стека

Stack1 segment at 0ba80h
               db 512 dup (?)
      stktop   label word
Stack1 ends

      ;Описание выполняемых действий

Code1 segment
      assume cs:Code1,ds:Data1,ss:Stack1

      ;Описание программных модулей

;1.Процедура подготовки данных
PrepareProc proc near

       mov al,0;3fh   ;вывод на цифровое табло "01"
       out 4,al
       mov al,0;3Fh
       out 3,al

       mov al,11h   ;активация двоичных инликаторов
       out 2,al     ;"настройка" и "выключен" 

       mov si,0     ;установка счетчиков
       mov bx,1
       mov di,1
       mov bp,31

       mov SetMode,1;установка режима настройки при включении ус-ва

       mov delay,1  ;начальная установка задержки в "1" 
       
    ;формирование массивов младшего и старшего разрядов
         ;для вывода на цифровое табло

       mov firstdig[0],3fh   ;0
       mov firstdig[1],0ch   ;1
       mov firstdig[2],76h   ;2
       mov firstdig[3],5eh   ;3
       mov firstdig[4],4dh   ;4
       mov firstdig[5],5bh   ;5
       mov firstdig[6],7bh   ;6
       mov firstdig[7],0eh   ;7
       mov firstdig[8],7fh   ;8
       mov firstdig[9],5fh   ;9
       mov firstdig[10],3fh  ;0
       mov firstdig[11],0ch  ;1
       mov firstdig[12],76h  ;2
       mov firstdig[13],5eh  ;3
       mov firstdig[14],4dh  ;4
       mov firstdig[15],5bh  ;5
       mov firstdig[16],7bh  ;6
       mov firstdig[17],0eh  ;7
       mov firstdig[18],7fh  ;8
       mov firstdig[19],5fh  ;9
       mov firstdig[20],3fh  ;0
       mov firstdig[21],0ch  ;1
       mov firstdig[22],76h  ;2
       mov firstdig[23],5eh  ;3
       mov firstdig[24],4dh  ;4
       mov firstdig[25],5bh  ;5
       mov firstdig[26],7bh  ;6
       mov firstdig[27],0eh  ;7
       mov firstdig[28],7fh  ;8
       mov firstdig[29],5fh  ;9
       mov firstdig[30],3fh  ;0
     
       mov seconddig[0],3fh  ;0   
       mov seconddig[1],3fh  ;0   
       mov seconddig[2],3fh  ;0   
       mov seconddig[3],3fh  ;0   
       mov seconddig[4],3fh  ;0   
       mov seconddig[5],3fh  ;0   
       mov seconddig[6],3fh  ;0   
       mov seconddig[7],3fh  ;0   
       mov seconddig[8],3fh  ;0   
       mov seconddig[9],3fh  ;0   
       mov seconddig[10],0ch; 1
       mov seconddig[11],0ch; 1
       mov seconddig[12],0ch; 1
       mov seconddig[13],0ch; 1
       mov seconddig[14],0ch; 1
       mov seconddig[15],0ch; 1
       mov seconddig[16],0ch; 1
       mov seconddig[17],0ch; 1
       mov seconddig[18],0ch; 1
       mov seconddig[19],0ch; 1
       mov seconddig[20],76h; 2
       mov seconddig[21],76h; 2
       mov seconddig[22],76h; 2
       mov seconddig[23],76h; 2
       mov seconddig[24],76h; 2
       mov seconddig[25],76h; 2
       mov seconddig[26],76h; 2
       mov seconddig[27],76h; 2
       mov seconddig[28],76h; 2
       mov seconddig[29],76h; 2
       mov seconddig[30],5eh; 3
       
       mov al,0ffh
       out 5,al
       mov al,0
       out 5,al

       mov prepdata,1   ; формирование признака готовности данных
       ret
EndP PrepareProc


;2. Режим настройки
SetModeProc proc near
       cmp prepdata,1    
       jnz smp1
       cmp return,1
       jnz smp1
       in al,0         ;обработка ввода
       cmp al,1
       jnz smp1
       mov bx,1        ;режим  настройки
       mov si,0
       mov ShowMode,0  ;сброс всех признаков
       mov StepShow,0
       mov AutoShow,0
       mov ForwMove,0
       mov BackMove,0
       mov NomSet,0
       mov DelSet,0
       mov DelReady,0
       mov SlMasReady,0
       mov AutoReady,0
       mov StepReady,0
       mov SetMode,1
       mov Return,0

       mov delay,1     ;установка заддержки в начальное состояние

       mov al,11h
       out 2,al

       mov al,0h
       out 5,al

       mov al,0;3fh   ;вывод на цифровое табло "0"
       out 4,al
       mov al,0;3Fh
       out 3,al

  smp1:ret
EndP SetModeProc


;3. Режим показа
ShowModeProc proc near
       cmp SetMode,1
       jnz shmp1 
       in al,0         ;обработка ввода
       cmp al,2
       jnz shmp1
       mov ShowMode,1  ;режим показа
       mov al,0ch   ;вывод на цифровое табло "01"
       out 4,al
       mov al,3Fh
       out 3,al
       mov al,12h
       out 2,al 
       mov bx,0
       mov SetMode,0   ;сброс признака настройки
 shmp1:ret
EndP ShowModeProc


;4. Выбор шагового показа слайдов
StepShowProc proc near
        cmp SetMode,1
        jnz ssp1
        cmp AutoShow,1
        jz  ssp1 
        in al,0          ;анализ ввода
        cmp al,4
        jnz ssp1
        mov StepShow,1   ; выбор шагового показа
        mov StepReady,1
        mov al,0;3fh   ;вывод на цифровое табло "01"
        out 4,al
        mov al,0;3Fh
        out 3,al
        
       cmp forwmove,1
       jnz ssp3
       mov al,5
       out 5, al
       jmp ssp1 
  ssp3:cmp backmove,1
       jnz ssp4
       mov al,9h
       out 5,al
       jmp ssp1
  ssp4:cmp NomSet,1
       jnz  ssp5
       mov al,11h
       out 5,al
       jmp ssp1 
  ssp5:mov al,1 
       out 5,al 
   ssp1:ret
EndP StepShowProc


;5. Выбор автоматического показа слайдов
AutoShowProc proc near
       cmp SetMode,1
       jnz asp2
       cmp StepShow,1
       jz  asp1  
       in al,0         ;анализ ввода
       cmp al,8
       jnz asp1
       mov AutoShow,1  ;выбор автоматического показа
       mov al,0;3fh   ;вывод на цифровое табло "01"
       out 4,al
       mov al,0;3Fh
       out 3,al
       cmp forwmove,1
       jnz asp3
       mov al,6
       out 5, al
       jmp asp2 
  asp3:cmp backmove,1
       jnz asp4
       mov al,0ah
       out 5,al
       jmp asp2
  asp4:cmp NomSet,1
       jnz asp5
       mov al,12h
       out 5,al
       jmp asp2
  asp5:mov al,2
       out 5,al 
  asp2:cmp showmode,1
       jnz asp1
       in al,1
       cmp al,20h
       jnz asp1
       mov autoready,1       
  asp1:ret
EndP AutoShowProc


;6. Установка направления движения кассеты со слайдами вперед
ForwMoveProc proc near
       cmp SetMode,1
       jnz fmp1
       cmp NomSet,1
       jz  fmp1
       cmp BackMove,1
       jz  fmp1
       in al,0         ;анализ ввода
       cmp al,10h
       jnz fmp1
       mov al,0;3fh   ;вывод на цифровое табло "01"
       out 4,al
       mov al,0;3Fh
       out 3,al
       mov ForwMove,1 ;выбор направления движения вперед
       cmp StepShow,1
       jnz fmp2  
       mov al,5
       out 5,al
       jmp fmp1
  fmp2:cmp AutoShow,1
       jnz fmp3
       cmp DelReady,1
       jnz fmp4
       mov al,26h
       out 5,al
       jmp fmp1
  fmp4:mov al,6
       out 5,al  
       jmp fmp1
  fmp3:mov al,4
       out 5,al
  fmp1:ret
EndP ForwMoveProc


;7. Установка направления движения кассеты со слайдами назад
BackMoveProc proc near
       cmp SetMode,1
       jnz  bmp1
       cmp NomSet,1
       jz bmp1
       cmp ForwMove,1
       jz  bmp1
       in al,0           ;анализ ввода
       cmp al,20h
       jnz bmp1
       mov al,0;3fh   ;вывод на цифровое табло "01"
       out 4,al
       mov al,0;3Fh
       out 3,al
       mov BackMove,1    ;выбор направления движения назад
       cmp stepshow,1
       jnz bmp2
       mov al,9
       out 5,al
       jmp bmp1
  bmp2:cmp AutoShow,1
       jnz bmp3
       cmp DelReady,1
       jnz  bmp4
       mov al,2Ah
       out 5,al
       jmp bmp1
  bmp4:mov al,0ah
       out 5,al       
       jmp bmp1
  bmp3:mov al,8
       out 5,al
  bmp1:ret
EndP BackMoveProc


;8. Формирование признака программного показа
SetSlideNom proc near
       cmp SetMode,1
       jnz ssn1
       cmp forwmove,1
       jz  ssn1
       cmp backmove,1
       jz  ssn1
       in al,0          ;анализ ввода
       cmp al,40h
       jnz ssn1
       mov forwmove,0
       mov backmove,0
       mov NomSet,1     ;формирование признака программного показа
       mov al,0ch   ;вывод на цифровое табло "01"
       out 4,al
       mov al,3Fh
       out 3,al
       cmp stepshow,1
       jnz ssn2
       mov al,11h
       out 5,al
       jmp ssn1
  ssn2:cmp autoshow,1
       jnz ssn3
       cmp delready,1
       jnz  ssn4
       mov al,32h
       out 5,al
       jmp ssn1
  ssn4:mov al,12h
       out 5,al
       jmp ssn1
  ssn3:mov al,10h
       out 5,al 
  ssn1:ret
EndP SetSlideNom


;9. Формирование признака установки задержки
SetDelay proc near
       cmp SetMode,1
       jnz sd1
       cmp AutoShow,1
       jnz sd1 
       in al,0
       cmp al,80h       ;анализ ввода
       jnz sd1
       mov DelSet,1     ;формирование признака установки задержки 
       mov al,0ch   ;вывод на цифровое табло "01"
       out 4,al
       mov al,3Fh
       out 3,al
       cmp forwmove,1
       jnz sd2
       mov al,26h
       out 5,al
       jmp sd1
   sd2:cmp backmove,1
       jnz sd3
       mov al,2ah
       out 5,al
       jmp sd1 
   sd3:cmp NomSet,1
       jnz sd4
       mov al,32h
       out 5,al
       jmp sd1
   sd4:mov al,22h
       out 5,al
   sd1:ret
EndP SetDelay


;10. Инкрементирование числа
IncProc proc near
       cmp SetMode,1     ;если выбран режим настройки
       jnz ip1
       cmp DelSet,1      ;если установлен флаг задержки 
       jnz ip3
       in al,1
       cmp al,1          ;анализ ввода
       jnz ip1           ;если нажата кнопка "+1"
       cmp bl,11         ;если счетчик не больше 10 
       jnl  ip1
       inc bl            ;инкрементирование счетчика
       mov al,seconddig[bx] 
       out 3,al           ;вывод числа на цифровое табло
       mov al,firstdig[bx]
       out 4,al
       mov cx,400h
   ip5:loop ip5    
       jmp ip1
   ip3:cmp NomSet,1        ;если установлен флаг программного показа 
       jnz ip1
       in al,1              
       cmp al,1            ;анализ ввода
       jnz ip1             ;если нажата кнопка "+1"
       cmp bl,31      
       jnl  ip1            ;если счетчик не больше 30
       inc bl              ; инкрементирование счетчика
       mov al,seconddig[bx]
       out 3,al            ;вывод числа на цифровое табло 
       mov al,firstdig[bx]
       out 4,al
       mov cx,400h
   ip6:loop ip6    
       jmp ip1
   ip2:mov bl,31
       jmp ip1
   ip1:ret
EndP IncProc


;11. Декрементирование числа
DecProc proc near
       cmp SetMode,1     ;если выбран режим настройки
       jnz dp1
       cmp NomSet,1      ;если установлен флаг программного показа
       jnz dp3
   dp4:in al,1           ;анализ ввода
       cmp al,2          
       jnz dp1           ;если нажата кнопка "-1"
       dec bl            ;декрементирование счетчика
       cmp bl,0
       jle dp2           ;если не последний кадр
       mov al,seconddig[bx]
       out 3,al            ;то вывод числа на цифровое табло
       mov al,firstdig[bx]
       out 4,al 
       mov cx,400h
   dp5:loop dp5    
       jmp dp1
   dp2:mov bl,1
       jmp dp1
   dp3:cmp DelSet,1        ;если флаг установки задержки равен 1
       jnz dp1             ;то преход на метку dp4
       jz  dp4 
   dp1:ret
EndP DecProc


;12. Запись задержки или номера слайда 
AddDelNom proc near
       cmp SetMode,1        ;если выбран режим настройки
       jnz adn1
       in al,1              ;анализ ввода
       cmp al,4
       jnz adn1             ;если нажата кнопка "добавить"
       cmp DelSet,1
       jnz adn2             ;если признак задержки равен 1
       mov delay,bl         ;то в Delay записываем величину задержки
       mov DelReady,1       ;формируем признак готовности задержки
       mov DelSet,0         ;збрасываем признак установки задержки
       mov cx,600h
  adn3:loop adn3     
       jmp adn1
  adn2:cmp NomSet,1         ;если признак программного показа =1
       jnz adn1
       inc si               ;то инкрементируем счетчик движения по массиву   
                            ;с номерами слайдов
       cmp si,21           
       jnl adn1             ;если не последний слайд в массиве
       mov SlideMas[si],bl  ;то добавляем номер слайда в массив
       mov ax,si
       mov MasLength,al     ;записываем длинну массива
       mov SlMasReady,1     ;форируем признак готовности масиива
       mov cx,600h
  adn4:loop adn4
  adn1:ret
EndP AddDelNom


;13. Шаговый показ слайдов с направлениями вперед и назад
StepShowing proc near
       cmp SlMasReady,1  ;если массив с номерами слайдов не готов
       jz  as1 
       cmp StepReady,1   ;если выбран шаговый показ
       jnz as1
       cmp ShowMode,1    ;если включен режим просмотра
       jnz as1 
       cmp ForwMove,1    ;если выбрано направление движения вперед 
       jnz as3
       in al,1
       cmp al,20h        ;анализ ввода
       jnz as1           ;если нажата кнопка "пуск\сл. слайд"
       mov al,6          ;включение двигателя
       out 2,al
       mov al,5
       out 5,al
       mov cx,1024h
   as7:loop as7
       mov al,12h
       out 2,al         ;выключение двигателя
       inc di           ;инкрементирование счетчика
       cmp di,31        ;если не помледний кадр
       jnl as5
       mov al,seconddig[di]
       out 3,al             ;то вывод на цифровое табло номера показываемого
       mov al,firstdig[di]  ;слайда
       out 4,al
       jmp as1
   as3:cmp BackMove,1       ;если движение назад 
       jnz as1
       in al,1              ;анализ ввода
       cmp al,20h
       jnz as1              ;если нажата кнопка "Пуск\Сл. слайд"
       dec bp               ;декрементирование счетчика
       cmp bp,0            
       jle as5              ;если не последний кадр
       mov al,6             ;то включение двигателя
       out 2,al
       mov al,9h
       out 5,al
       mov cx,1024h
   as6:loop as6
       mov al,12h
       out 2,al            ;выключение двигателя
       mov al,seconddig[bp]
       out 3,al             ;вывод номера слайда на цифровое табло
       mov al,firstdig[bp]
       out 4,al
       jmp as1
   as5:mov StepReady,0      ;сброс признака шагового показа
       mov aL,0
       out 5,al
   as1:ret
EndP StepShowing 


;14. Шаговый программный показ
StepProgShow proc near
       cmp StepReady,1      ;если выбран шаговый показ
       jnz sps1
       cmp ShowMode,1       ;если включен режим просмотра
       jnz sps1
       cmp SlMasReady,1     ;если готов массив с номерами слайдов
       jnz sps1
       in al,1              ;анализ ввода
       cmp al,20h
       jnz sps1             ;если нажата кнопка "Пуск\Сл. слайд"
       mov al,6             ;то включение двигателя
       out 2,al
       mov al,11h
       out 5,al  
       mov ax,512h
       mul word ptr SlideMas[bx+1] ;передвижение кассеты со слайдами
       mov cx,ax
  sps2:loop sps2
       mov al,12h
       out 2,al              ;отключение двигателя
       inc bx                ; инкрементирование счетчика
       push bx
       mov bl,SlideMas[bx]   
       mov al,seconddig[bx]
       out 3,al             ;вывод номера показываемого слайда
       mov al,firstdig[bx]  ;на цифровое табло 
       out 4,al 
       pop bx
       cmp MasLength,bl     
       jnz sps1             ;если последний слайд
       mov StepReady,0      ;то сброс признака шагового показа  
       mov bx,1             ;сброс счетчика
       mov al,0
       out 5,al
  sps1:ret
EndP StepProgShow


;15. Автоматический показ слайдов с направлениями вперед и назад
AutoShowing proc near
       cmp ShowMode,1       ;если включен режим показа
       jnz aus10     
       cmp AutoReady,1      ;если выбран режим автоматичесого показа
 aus10:jnz aus11
       cmp SLMasReady,1     ;если не програнный показ
       jz  aus12
       cmp StepShow,1
       jz  aus11
       cmp ForwMove,1       ;если выбрано движение вперед
       jnz aus3  
       mov al,6             ;включение двигателя
       out 2,al
       mov al,26h
       out 5,al
       mov cx,1024h
       jmp aus7
 aus11:jmp aus1
 aus7:loop aus7
       mov al,12h
       out 2,al             ;выключение двигателя
       mov al,seconddig[di]
       out 3,al             ;вывод номера показываемого слайда 
       mov al,firstdig[di]  ;на цифровое табло
       out 4,al
       inc di               ;инкрементирование счетчика
       cmp di,31            ;если не послединй кадр
       jnl aus5
       mov ax,500h
       imul word ptr delay  ;то задержка между сменой слайдов
       mov cx,ax
  aus2:in al,1
       cmp al,40h
 aus12:jz  aus1
       loop aus2
       jmp aus1
  aus3:cmp BackMove,1       ;если движение назад
       jnz aus1
       mov al,6            ;включение двигателя
       out 2,al
       mov al,2ah
       out 5,al
       mov cx,1024h
  aus6:loop aus6
       mov al,12h
       out 2,al             ;выключение двигателя
       dec bp               ;декрементирование счетчика
       cmp bp,0
       jle aus5             ;если не последний кадр       
       mov al,seconddig[bp]
       out 3,al             ;то выод на цифровое табло
       mov al,firstdig[bp]  ;номер показываемого слайда
       out 4,al
       mov ax,500h
       mul word ptr delay   ;задержка между сменой слайдов
       mov cx,ax
  aus4:in al,1
       cmp al,40h
       jz  aus1
       loop aus4      
       jmp aus1
  aus5:mov AutoReady,0      ;сброс признака автоматического показа 
       mov al,0
       out 5,al
  aus1:ret
EndP AutoShowing


;16. Автоматический программный показ
AutoProgShow proc near
       cmp StepShow,1       ;если задержка установлена  
       jz aps1
       cmp AutoReady,1      ;если выбран режим автоматического показа
       jnz aps1
       cmp ShowMode,1       ;если включен режим показа
       jnz aps1
       cmp SlMasReady,1     ;если массив с номерами слайдов готов
       jnz aps1
       mov al,32h
       out 5,al
       mov al,6
       out 2,al             ;включение двигателя
       mov ax,500h
       mul word ptr SlideMas[bx+1]
       mov cx,ax
  aps3:loop aps3
       mov al,12h
       out 2,al              ;выключение двигателя
       inc bx                ;инкрементирование счетчика
       push bx
       mov bl,SlideMas[bx]
       mov al,seconddig[bx]
       out 3,al             ;вывод на цифровое табло номера 
       mov al,firstdig[bx]  ;показываемого слайда
       out 4,al 
       mov ax,500h
       mul word ptr delay   ;задержка между сменой слайдов
       mov cx,ax
  aps2:in al,1
       cmp al,40h
       jz  aps1
       loop aps2   
       pop bx
       cmp MasLength,bl    
       jnz aps1             ;если последний элемент в массиве
       mov AutoReady,0      ;то сброс признака автоматического показа
       mov bx,1             ;сброс четчик
       mov al,0 
       out 5,al 
  aps1:ret
EndP AutoProgShow


;17. Остановка автоматических показов
StopShowing proc near
       in al,1         ;анализ ввода
       cmp al,40h     
       jnz ss1         ;если нажата кнопка "Стоп"
       cmp ShowMode,1  ;если выбран режим показа
       jnz ss1
   ss3:mov AutoShow,0  ;то сброс
       mov NomSet,0    ;признаков 
       mov DelSet,0    ;автоматического 
       mov DelReady,0  ;показа
       mov SlMasReady,0
       mov AutoReady,0
   ss1:ret
EndP StopShowing 


;18. Возврат кассеты со слайдами в исходное состояние
ReturnProc proc near
       cmp return,0     ;если возврата еще не было
       jnz rp1
       cmp showmode,1
       jnz rp1          ;если включен режим показа
       in al,1
       cmp al,80h       ;анализ ввода
       jnz rp1          ;если нажата кнопка "возврат"
       cmp ForwMove,1   ;если движение вперед
       jnz rp3
       mov ax,256h      ;то подготовка перемотки 
       mul di           ;в случае выбора направления 
       mov cx,ax        ;движения вперед
       jmp rp4
   rp3:cmp BackMove,1   ;если движение назад
       jnz rp5
       mov ax,256h      ;то подготовка перемотки
       mul bp           ;в случае выбора направления движения нажад
       mov cx,ax
       jmp rp4
   rp5:mov ax,256h                 ;подготовка
       mul word ptr slidemas[bx-1] ;перемотки
       mov cx,ax                   ;в случае программного показа 
   rp4:mov al,6              
       out 2,al                    ;включение двигателя
   rp2:loop rp2                    ;премотка
       mov al,12h                  ;выключение двигателя
       out 2,al  
       mov al,seconddig[1]
       out 3,al                  ;вывод на цифровое табло "01"
       mov al,firstdig[1]    
       out 4,al
       mov bp,31
       mov di,1
       mov bx,1
       mov ForwMove,0
       mov BackMove,0 
       mov return,1
       
       mov al,0
       out 5,al 
   rp1:ret
EndP ReturnProc


          ;Макроуровень программы

begin1:                  ;Системная подготовка
       mov ax,data1      ;Инициализация
       mov ds,ax         ;сегментных
       mov ax,stack1     ;регистров
       mov ss,ax
       lea sp,StkTop     ;и указателя стека

       call PrepareProc  ;подготовка данных 
begin2:call SetModeProc  ;переход в режим настройки
       call ShowModeProc ;переход в режим показа 
       call StepShowProc ;выбор шагового показа
       call AutoShowProc ;выбор автоматического показа
       call ForwMoveProc ;установка направления движения вперед
       call BackMoveProc ;установка направления движения назад
       call SetSlideNom  ;формирование флага программного показа
       call SetDelay     ;формирование флага установки задержки
       call IncProc      ;инкрементирование числа
       call DecProc      ;декрементирование числа
       call AddDelNom    ;запись задержки или номера слайда
       call StepShowing  ;шаговый показ с различными направлениями
       call StepProgShow ;шаговый программный показ
       call AutoShowing  ;автоматический показ с различными направлениями
       call AutoProgShow ;автоматический программный показ
       call StopShowing  ;остановка автоматического показа
       call ReturnProc   ;возврат кассеты со слайдами в исходное положение
       jmp begin2        ; замыкание программного кольца
       
       org 7f0h          ;Обеспечение начального запуска
start: jmp begin1        ;программы при включении устройства

code1 ends
      end start