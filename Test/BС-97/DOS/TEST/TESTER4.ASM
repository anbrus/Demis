TremorFade   equ 1            ;константа гашения дребезга
MaxTimeCount equ 4            ;            
MaxBilet     equ 3            ;
MaxVopros    equ 5            ;

DataSegm segment ;at 0ba00h

;            0   1    2   3   4   5   6   7   8   9   a   b  c   d   e   f

tablcode db 3fh,0ch,76h,5eh,4dh,5bh,7bh,0eh,7fh,5fh,00h,0ffh,00h,00h,00h,40h


KbdImg          dw      ?       ;образ клавиатуры


KeyCode         db      ?       ;код нажатой клавиши

FlagT1          db      ?       ;флаг положения тумблера

FlagT2          db      ?       ;флаг положения тумблера

IndImg          db     7  dup(?)  ;образ индикаторов

Mode            db      ?       ;режим функционирования устройства

Task            db      ?       ;номер задания-вопроса

Anser           db      ?       ;код ответа

AllTask         db      ?       ;счетчик общего кол-ва заданных вопросов

OkTask          db      ?       ;счетчик кол-ва правильных ответов

EndTest         db      ?       ;флаг сигнализирующий об окончании теста

Mark            db      ?       ;выставленная оценка

Time            dw      ?       ;время тестирования (мин.)

TimeCounter     dw      ?       ;счетчик времени

MaxTime         dw      ?       ;максимальное время тестирования  (мин.)

MaxTask         db      ?       ;максимальный вопрос теста

ArrTask         db  9*9  dup(?) ;массив правильных ответов

OldKbdImg       dw      0       ;старый образ клавиатуры

LastTask        db      0       ;


DataSegm ends

CodeSegm segment
assume cs:CodeSegm, ds:DataSegm ,es:DataSegm

TimeCount proc          ;подсчет времени по немаскируемому прерыванию

                push ax    ;
                push bx    ;запрещать прерывания бессмысленно
                push cx    ;так как они немаскируемые
                push dx

                cmp Mode,1
                jnz EndTC                     ; если режим тестирования

                dec TimeCounter               ; то считаем время
                jnz EndTC

                inc Time                      ;прошла минута
                mov TimeCounter,MaxTimeCount  ;начинается следующая минута

         EndTC: pop dx
                pop cx
                pop bx
                pop ax

                ret
TimeCount endp


GetKbd proc                        ;помещает в DX образ клавиатуры
                                   ;в формате KbdImg

                push ax
                push bx
                push cx

                mov dx,0FFFFh      ;начальное значение

                in al,00h
                mov dl,al
                in al,01h
                mov dh,al
                and dx,00fffh

                pop cx
                pop bx
                pop ax

                ret
GetKbd endp

GetTumb proc                       ;помещает в Dh образ тумблеров
                                   ;Dh0..Dh4 - установлены в 1
                                   ;Dh5 - "Тест/Прогр"
                                   ;       0 - тестирование
                                   ;       1 - программирование
                                   ;Dh6 - "Тест/Прогр"
                                   ;       0 - тестирование
                                   ;       1 - программирование
                                   ;Dh7 - установлен в 1
                push ax
                in al,01h
                and al,01100000b
                mov dh,al
                pop ax

                ret
GetTumb endp

                                ;**********************************
                                ;*  некоторые полезные продцедуры *
                                ;**********************************

ZeroCount proc                 ;подсчитывает количество нулевых битов в AX
                push cx        ;результат - в BX
                push ax
                mov cx,16      ;остальные регистры - без изменения
                mov bx,0       ;

      LoopZC:   ror ax,1       ;
                adc bx,0       ;
                loop LoopZC    ;
                pop ax
                pop cx
                ret
ZeroCount endp

FirstZero proc                 ;определяет номер первого сброшенного бита
                               ;исходное слово - в AX,результат - в BX
                               ;остальные регистры - без изменения

                push cx
                push ax

                mov cx,16      ;не более 16 раз
                mov bx,-1      ;начнем с -1
       LoopFC:  inc bx         ;
                ror ax,1       ;сдвинем
                test ax,0000111111111111b    ;проверим
                loopnz LoopFc

;               mov si,bx
;               mov al,byte ptr tablcode[si]
;               out 06,al

                pop ax
                pop cx
                ret
FirstZero endp

                                ;************************************
                                ;* основные программные исполнители *
                                ;************************************

Prepare proc                    ;подготовка
                mov cx,9*9      ;обнуление ArrTask
                mov al,0
                cld
                lea di,ArrTask
          rep   stos ArrTask

                mov Mark,0      ;переход в режим ожидания
                mov Task,0
                mov Time,0
                mov Mode,0

                ret
Prepare endp

ReadKbd proc                          ;чтение клавиатуры
                                      ;с гашением дребезга

;                mov cx,TremorFade     ;сколько раз должно совпасть

        LoopRC: call GetKbd           ;опрос клавиатуры
                cmp dx,KbdImg         ;проверяем
                je NextRC

;                mov cx,TremorFade     ;не совпало - начинаем подсчет
                mov KbdImg,dx         ;   совпадений сначала

        NextRC:; loop LoopRC           ;проверяем еще раз

                ret
ReadKbd endp

DecodKbd proc                         ;дешифровка клавиатуры

                mov KeyCode,0fh       ;наиболее частый случай

                mov ax,KbdImg

                call ZeroCount        ;сколько клавиш нажато ?
                cmp bx,2              ;если две или больше, то все
                jns EndDK

                cmp ax,OldKbdImg      ;если состояние клавиатуры
                jz EndDK              ;не изменилось, то все.

                mov OldKbdImg,ax      ;запоминаем новое состояние клавиатуры

                cmp bx,0              ;а может клавиша и вовсе не нажата
                jz EndDK              ; а отпущена. если да, то все

                call FirstZero        ;если нажата одна клавиша и
                mov KeyCode,bl        ;раньше она была отпущена
                                      ;то вычисляем ее код.
        EndDK: ret

DecodKbd endp

DecodTumb proc                        ;дешифровка тумблеров
                call GetTumb
                mov FlagT1,00h
                test dh,00100000b
                jz EndT1DT
                mov FlagT1,0FFh

       EndT1DT: mov FlagT2,0FFh
                test dh,01000000b
                jz EndT2DT
                mov FlagT2,00h

       EndT2DT: ret
DecodTumb endp

ModeSwitch proc                      ;переключение режимов
                cmp Mode,2
                jz MS1               ;если режим не программирование
                cmp Mode,3           ;и не ввод времени
                jz MS1

                cmp FlagT1,0         ;и если тумблер в положении
                jz EndMS             ;программирование

                mov MaxTask,-1
                mov Task,0           ;то установить первый вопрос
                mov ah,ArrTask[0]    ;и переключится в режим
                mov Anser,ah         ;программирования вопросов
                mov Mode,2
                mov AllTask,0
                jmp EndMS

           MS1: cmp FlagT1,0         ;если режим программирование или ввод
                jnz EndMS            ;времени, а тумблер в положении
                                     ;тестирование,

                mov Time,0           ;то сбросить необходимые переменные
                mov Task,0           ;и перейти в режим ожидания
                mov Anser,0
                mov Mode,0

         EndMS: ret

ModeSwitch endp

ProgMode proc                        ;РЕЖИМ программирования ответов
                cmp Mode,2
                jnz NotPM
                mov ah,KeyCode

                cmp ah,11            ;РЕАКЦИЯ на клавишу "старт"
                jnz PM1
                mov Mode,3           ;    переход в режим ввода времени
                jmp EndPM

           PM1: cmp ah,10            ;РЕАКЦИЯ на клавишу "ввод"
                jnz PM2
                mov al,Anser
                cmp Anser,0
                jz PM15
                inc AllTask 
      PM15: 

                mov bl,Task          ;    фиксация ответа
                mov bh,0
                mov al,Anser
                mov ArrTask[bx],al
                mov MaxTask,bl
                cmp bl,MaxVopros*MaxBilet-2       ;    если счетчик вопросов можно увеличить
                ja EndPM
                inc bl             ;    то переход к следующему вопросу
                mov Task,bl
                mov al,ArrTask[bx]
                mov Anser,al
                jmp EndPM

           PM2: cmp ah,9            ;РЕАКЦИЯ на цифровые клавиши
                ja EndPM
                mov Anser,ah        ;   ввести новый код ответа

         EndPM: mov KeyCode,0fh
         NotPM: ret
ProgMode endp

TimeMode proc                       ;РЕЖИМ ввода времени
                cmp Mode,3
                jnz NotTM
                mov ah,KeyCode

                cmp ah,10           ;РЕАКЦИЯ на клавишу "ввод"
                jnz TM1
                mov Mode,2          ;   переход в режим прогр. ответов
                jmp EndTM

           TM1: cmp KeyCode,9       ;РЕАКЦИЯ на цифровые клавиши
                ja EndTM


                mov ax,MaxTime        ;   ввести новый код ответа
                mov dx,0
                mov bx,10
                mul bx
                mov bx,1000
                div bx
                mov cx,0
                add cl,KeyCode 
                add dx,cx
                mov MaxTime,dx

         EndTM: mov KeyCode,0Fh
         NotTM: ret
TimeMode endp

WaitMode proc
                cmp Mode,0           ;РЕЖИМ ожидания
                jnz NotTM
                mov ah,KeyCode

                cmp ah,11            ;РЕАКЦИЯ на клавишу "старт"
                jnz EndWM
                mov Time,0
                mov TimeCounter,MaxTimeCount
                mov Task,-1

    WMLoop:     inc Task            ;    найти в массиве следующий вопрос
                mov bl,Task         ;    с ненулевым ответом
                mov bh,0
                mov al,ArrTask[bx]

                cmp al,0
                jnz WM1

                cmp Task,MaxVopros*MaxBilet-1;
                jg  WM1
 
                jmp WMLoop
                
                
       WM1:     mov Anser,0
                mov OkTask,0         ;      установить переменные в
                                     ;      исходное состояние
                mov Mode,1           ;      и начать тестирование

         EndWM: mov KeyCode,0fh
         NotWM: ret
WaitMode endp




TestMode proc                       ;РЕЖИМ тестирования
                cmp Mode,1
                jnz NotTsM
                mov ah,KeyCode

                cmp ah,11                    ;реакция на клавишу "старт"
                jnz TSM0
                mov Time,0
                mov TimeCounter,MaxTimeCount
                mov Anser,0
                mov OkTask,0         ;      установить переменные в
                                     ;      исходное состояние
                mov Mode,1           ;      и начать тестирование
                jmp EndTsM

         TSM0:  cmp ah,10           ;РЕАКЦИЯ на клавишу "ввод"
                jnz TsM1
              
                mov al,Task
                mov LastTask,al  
                mov bl,Task
                mov bh,0
                mov al,ArrTask[bx]
                cmp al,Anser        ;    если нужно,
                mov Anser,0         ;
                jnz LoopTsM         ;
                inc OkTask          ;    увеличить счетчик правильных
                                    ;    ответов

                
       LoopTsM: inc Task   ;    найти в массиве следующий вопрос
                mov bl,Task         ;    с ненулевым ответом
                mov bh,0
                mov al,ArrTask[bx]

                cmp al,0
                jnz EndTsM

                cmp Task,MaxVopros*MaxBilet-1;
                jg  EndTsM
 
                jmp LoopTsM


          TsM1: cmp ah,9             ;РЕАКЦИЯ на цифровые клавиши
                ja EndTsM
                mov Anser,ah         ;     поменять код ответа

        EndTsM: mov KeyCode,0Fh
        NotTsM: ret
TestMode endp

EndControl proc                      ;контроль окончания теста
                mov EndTest,0        ;сбросить флаг окончания
                cmp mode,1
                jnz EndEC

                cmp FlagT2,0         ;установить флаг окончания
                jnz EC1               ;если включен контроль времени и
                mov ax,MaxTime       ;кончилось время
                cmp ax,Time
                ja EC1
                mov EndTest,0FFh

           EC1:
                mov al,Task          ;установить флаг окончания, если
                cmp al,MaxTask           ;номер вопроса стал больше,
                jle EndEC             ;чем максимальный
                mov EndTest,0FFh

         EndEC: ret
EndControl endp

MarkCount proc                     ;выставление оценки

                cmp EndTest,0      ;если тест завершился, то
                jz NotMC

                mov Mark,0         ;если общее количество вопросов - 0
                mov bl,AllTask     ;то и оценка - 0
                cmp bl,0
                jz EndMC

                mov al,OkTask      ;иначе находим рейтинг в %
                mov bh,100
                mul bh
                div bl
                
                mov Mark,2 

                cmp al,60          ;двойка
                jb EndMC

                mov Mark,3
                cmp al,75          ;тройка
                jb EndMC

                mov Mark,4
                cmp al,90          ;четверка
                jb EndMC

                mov Mark,5

       EndMC:   mov EndTest,0      ;пятерка
                mov Mode,0
                mov Task,0

       NotMC:   ret
MarkCount endp


MakeImage proc
                cld                ;для начала - очищаем образ
                mov al,0fh
                lea di,IndImg
                mov cx,7
          rep   stos IndImg

                cmp Mode,2         ;отображение текущего времени
                jz M1   
                cmp Mode,3         ;отображение текущего времени
                jz M1   
                          ;в режиме тестирования
                cmp FlagT2,0       ;и ожидания
                jnz M1             ;(при включеннном контроле времени)



                mov ax,Time
                mov dx,0
                mov bx,10
                div bx 
                mov IndImg[6],dl
                mov dx,0
                div bx
                mov IndImg[1],dl
                mov dx,0
                div bx
                mov IndImg[0],dl

            M1: cmp Mode,3        ;отображение максимального времени
                jnz M2            ;в режиме ввода времени


                mov ax,MaxTime
                mov dx,0
                mov bx,10
                div bx 
                mov IndImg[6],dl
                mov dx,0
                div bx
                mov IndImg[1],dl
                mov dx,0
                div bx
                mov IndImg[0],dl


            M2: cmp Mode,0       ;отображение номера задания и вопроса
                jz M25       
                cmp Mode,3
                jz M25       
                                 ;в режимах программирования, тестирования
                mov al,Task      
                mov ah,0
                mov bl,MaxVopros
                div bl
                inc al
                inc ah
                mov IndImg[2],ah
                mov IndImg[3],al

            M25: cmp Mode,0       ;отображение номера задания и вопроса
                jnz M3            ;в режимах программирования, тестирования
                mov al,LastTask     ;и ожидания
                mov ah,0
                mov bl,MaxVopros
                div bl
                inc al
                inc ah
                mov IndImg[2],ah
                mov IndImg[3],al

            M3: cmp Mode,3       ;отображение ответа в режимах
                jz M4            ;тестирования и  программирования
                cmp Mode,0
                jz M4
                mov al,Anser
                mov IndImg[4],al

            M4: cmp Mode,0       ;отображение оценки в режиме ожидания
                jnz EndMI
                mov al,Mark
                mov IndImg[5],al

         EndMI:

                ret
MakeImage endp
MyMake proc
    mov al,AllTask
    mov IndImg[0],al 
    mov al,OkTask
    mov IndImg[1],al 
mret:   ret
MyMake endp

 OutInd proc                     ;вывод образа на индикатор
                push ax
                push bx

                lea bx,tablcode

                mov al,IndImg[0]
                xlat
                out 02,al

                mov al,IndImg[1]
                xlat
                out 03,al

                mov al,IndImg[2]
                xlat
                out 04,al

                mov al,IndImg[3]
                xlat
                out 05,al

                mov al,IndImg[4]
                xlat
                out 06,al

                mov al,IndImg[5]
                xlat
                out 07,al

                mov al,IndImg[6]
                xlat
                out 08,al

                pop bx
                pop ax

                ret
OutInd endp

Start:
                mov ax,DataSegm     ;***********************
                mov ds,ax           ;*    Макроуровень     *
                mov es,ax           ;***********************

                call Prepare        ;подготовка

MainLoop:
                 call TimeCount      ;
                 call ReadKbd        ;чтение клавиатуры
                 call DecodKbd       ;расшифровка клавиатуры
                 call DecodTumb      ;опрос и расшифровка тумблеров
                 call ModeSwitch     ;переключение режимов
                 call WaitMode       ;режим ожидания
                 call ProgMode       ;РЕЖИМ прогр. ответов
                 call TimeMode       ;режим ввода времени
                 call TestMode       ;режим тестирования
                 call EndControl     ;контроль окончания теста
                 call MarkCount      ;выставление оценки
                 call MakeImage      ;формирование образа
;                 call MyMake         ;
                 call OutInd         ;вывод на индикаторы
                jmp MainLoop


CodeSegm ends

end Start

comment {               lea di,indimg
                mov cx,6

        pc:     mov al,byte ptr [di]
                mov ah,0
                mov si,ax
                mov al,byte ptr tablcode[si]
                mov byte ptr [di],al
                inc di
                loop pc
Next proc
                push bx
                push ax                

       LoopTsM: inc Task            ;    найти в массиве следующий вопрос
                mov bl,Task         ;    с ненулевым ответом
                mov bh,0
                mov al,ArrTask[bx]

                cmp al,0
                jnz EndN

                cmp Task,MaxVopros*MaxBilet-1;
                ja  EndN
 
                jmp LoopTsM

 EndN:          pop ax
                pop bx
              
                 ret
Next endp

}       


                mov ax,Time1
                mov dx,0
                mov bx,10
                div bx 
                mov IndImg[2],dl
                mov dx,0
                div bx
                mov IndImg[1],dl
                mov dx,0
                div bx
                mov IndImg[0],dl

                mov ax,Time1        ;   ввести новый код ответа
                mov dx,0
                mov bx,10
                mul bx
                mov bx,1000
                div bx
                mov cx,0
                add cl,KeyCode 
                add dx,cx
                mov Time1,dx

