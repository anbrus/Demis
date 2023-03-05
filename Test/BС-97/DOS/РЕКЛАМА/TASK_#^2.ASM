%NOLIST
%CREFALL
PAGE 64,70
.286
;###############################  СТРУКТУРЫ  ################################
;################################################# структура позиции очереди
;***************  номер, скорость, оформление
SParamMsg STRUC
          Num       db        0         ; 0-7
          Speed     db        0         ; 0/1
          Effect    db        0         ; 0-5
          Reserv1   db        0
ENDS
;################################################ запись состояния клавиатуры
;************  кнопки эффектов, скорости, ввода, управления, сообщений
RKeyboard RECORD {
          Reserv2:13=0
          EditKeys:2=0
          ProgrKey:1=0
          SpeedKeys:2=0
          EffectKeys:6=0
          MsgKeys:8=0
}
; 31 30 28  26  24  22  20  18  16  14  12  10 9 8 7 6 5 4 3 2 1 0
; ┌╧┬╧┬─┬╧┬─┬╧┬─┬╧┬─┬╧┬─┬╧┬─┬╧┬─┬╧╫─┬╧┬─┬╧┬─┬╧┬╧┬╧┬╧┬╧┬╧┬╧┬╧┬╧┬╧┬╧┐
; │0│0│0│0│0│0│0│0│0│0│0│0│0│2│1│1║2│1│6│5│4│3│2│1│8│7│6│5│4│3│2│1│
; └─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┼─┴─┼─╫─┴─┼─┴─┴─┴─┴─┴─┼─┴─┴─┴─┴─┴─┴─┴─┤
;                           Edit┴P╨Spd┴   Effect  ┴     Message   ┘
;############################################################################
;###############################  КОНСТАНТЫ  ################################
          TurnPosCount   =    15        ; количество позиций в очереди
          ShotsCount     =    20        ; количество кадров заставки
          SizeMatrix     =    16        ; размер образа экрана
          SlowSpeed      =    8         ; медленная скорость
          FastSpeed      =    1         ; быстрая скорость
;############################################################################
data segment at 0BA00H
          StartData      =    $         ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;################################################# очередь сообщений
          Turn      SParamMsg TurnPosCount dup (<>)

          NumMsgs   dw        0         ; количество сообщений в очереди
          CurTurnPos dw       0         ; текущая позиция в очереди
          CurMsg    dw        0         ; текущее сообщение:
                                        ;         0 - не выбрано
                                        ;         1..8 - сообщения
          CurSpeed  db        0         ; текущая скорость
                                        ;         0 - не выбрана
                                        ;         1..2 - скорость
          CurEffect db        0         ; текущий эффект
                                        ;         0 - не выбран
                                        ;         1..6 - эффект
          CurPos    dw        0         ; позиция в сообщении
          LastPos   dw        0         ; последняя позиция в сообщении

          CurShot   dw        0         ; позиция в заставке
;################################################# образ экрана
          Matrix    db        SizeMatrix dup (?)
          MatrixMask db       0         ; Маска эффекта сообшения
          DinamicFill dw      0FF00h    ; Маска динамической заливки
          DinCount  db        0         ; задержка динамической заливки

          Ticks     dw        0         ; величина задержки
          Regime    db        0         ; режим работы
;################################################# образ клавиатуры
          Keyboard  RKeyboard <?>
          KbdError  db        ?         ; 0 - можно использовать образ
;###########################################################################
          EndData        =    $         ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
ends

stack segment at 0BA80H
                    db        200H dup (?)
          StkTop    label     word
ends

code segment
assume cs:code,ds:data
;#################################  ДАННЫЕ  #################################
;################################################# Числа 1..F
          Num_Zero  dd        000000000h     ; пустота
                    dd        00080FE84h     ; Num_1
                    dd        0009CA2C4h     ; Num_2
                    dd        0006C9244h     ; Num_3
                    dd        000F8203Eh     ; Num_4
                    dd        000728A5Eh     ; Num_5
                    dd        00064927Ch     ; Num_6
                    dd        0001EE202h     ; Num_7
                    dd        0006C926Ch     ; Num_8
                    dd        0007C924Ch     ; Num_9
                    dd        000FC22FCh     ; Num_A
                    dd        0006C92FEh     ; Num_B
                    dd        00044827Ch     ; Num_C
                    dd        0007C82FEh     ; Num_D
                    dd        0008292FEh     ; Num_E
                    dd        0000212FEh     ; Num_F
;################################################# Добро пожаловать!
          LengthM0  dw        Message1 - Message0 - 2
          Message0  label     byte
                    db        0C0h,078h,046h,041h,07Fh,0C0h,000h,038h
                    db        044h,044h,038h,000h,03Ch,04Ah,04Ah,031h
                    db        000h,0FCh,024h,024h,018h,000h,038h,044h
                    db        044h,038h,000h,000h,000h,000h,07Ch,004h
                    db        004h,07Ch,000h,038h,044h,044h,038h,000h
                    db        044h,028h,07Ch,028h,044h,000h,020h,054h
                    db        054h,028h,040h,000h,040h,038h,004h,07Ch
                    db        000h,038h,044h,044h,038h,000h,03Ch,05Ah
                    db        054h,020h,000h,020h,054h,054h,038h,040h
                    db        000h,004h,07Ch,004h,000h,07Ch,050h,020h
                    db        000h,05Eh
;################################################# Hello! How your money?
          LengthM1  dw        Message2 - Message1 - 2
          Message1  label     byte
                    db        07Fh,008h,008h,008h,07Fh,000h,038h,054h
                    db        054h,058h,000h,07Fh,000h,07Fh,000h,038h
                    db        044h,044h,038h,000h,05Fh,000h,000h,000h
                    db        000h,07Fh,008h,008h,008h,07Fh,000h,038h
                    db        044h,044h,038h,000h,03Ch,040h,030h,040h
                    db        03Ch,000h,000h,000h,000h,01Ch,0A0h,0A0h
                    db        07Ch,000h,038h,044h,044h,038h,000h,03Ch
                    db        040h,040h,03Ch,000h,07Ch,008h,004h,004h
                    db        000h,000h,000h,000h,07Ch,004h,078h,004h
                    db        078h,000h,038h,044h,044h,038h,000h,07Ch
                    db        004h,004h,078h,000h,038h,054h,054h,058h
                    db        000h,01Ch,0A0h,0A0h,07Ch,000h,002h,051h
                    db        009h,006h
;################################################# Заходите, не пожалеете!
          LengthM2  dw        Message3 - Message2 - 2
          Message2  label     byte
                    db        022h,041h,041h,049h,036h,000h,020h,054h
                    db        054h,038h,040h,000h,06Ch,010h,06Ch,000h
                    db        038h,044h,044h,038h,000h,0C0h,078h,044h
                    db        07Ch,0C0h,000h,07Ch,020h,010h,07Ch,000h
                    db        004h,07Ch,004h,000h,038h,054h,054h,058h
                    db        000h,080h,040h,000h,000h,000h,07Ch,010h
                    db        010h,07Ch,000h,038h,054h,054h,058h,000h
                    db        000h,000h,000h,07Ch,004h,004h,07Ch,000h
                    db        038h,044h,044h,038h,000h,044h,028h,07Ch
                    db        028h,044h,000h,020h,054h,054h,038h,040h
                    db        000h,040h,038h,004h,07Ch,000h,038h,054h
                    db        054h,058h,000h,038h,054h,054h,058h,000h
                    db        004h,07Ch,004h,000h,038h,054h,054h,058h
                    db        000h,05Fh
;################################################# У нас вы найдёте всё!
          LengthM3  dw        Message4 - Message3 - 2
          Message3  label     byte
                    db        007h,048h,048h,048h,03Fh,000h,000h,000h
                    db        000h,07Ch,010h,010h,07Ch,000h,020h,054h
                    db        054h,038h,040h,000h,038h,044h,044h,028h
                    db        000h,000h,000h,000h,03Ch,05Ah,054h,020h
                    db        000h,07Ch,050h,020h,000h,07Ch,000h,000h
                    db        000h,000h,07Ch,010h,010h,07Ch,000h,020h
                    db        054h,054h,038h,040h,000h,07Ch,021h,011h
                    db        07Ch,000h,0C0h,078h,044h,07Ch,0C0h,000h
                    db        039h,054h,054h,059h,000h,004h,07Ch,004h
                    db        000h,038h,054h,054h,058h,000h,000h,000h
                    db        000h,03Ch,05Ah,054h,020h,000h,038h,044h
                    db        044h,028h,000h,039h,054h,054h,059h,000h
                    db        05Fh
;################################################# Распродажа!
          LengthM4  dw        Message5 - Message4 - 2
          Message4  label     byte
                    db        07Fh,009h,009h,009h,006h,000h,020h,054h
                    db        054h,038h,040h,000h,038h,044h,044h,028h
                    db        000h,07Ch,004h,004h,07Ch,000h,0FCh,024h
                    db        024h,018h,000h,038h,044h,044h,038h,000h
                    db        0C0h,078h,044h,07Ch,0C0h,000h,020h,054h
                    db        054h,038h,040h,000h,044h,028h,07Ch,028h
                    db        044h,000h,020h,054h,054h,038h,040h,000h
                    db        05Fh
;################################################# Всё для вашего удовольствия.
          LengthM5  dw        Message6 - Message5 - 2
          Message5  label     byte
                    db        07Fh,049h,049h,049h,036h,000h,038h,044h
                    db        044h,028h,000h,039h,054h,054h,059h,000h
                    db        000h,000h,000h,0C0h,078h,044h,07Ch,0C0h
                    db        000h,040h,038h,004h,07Ch,000h,068h,014h
                    db        014h,07Ch,000h,000h,000h,000h,03Ch,05Ah
                    db        054h,020h,000h,020h,054h,054h,038h,040h
                    db        000h,07Ch,040h,070h,040h,07Ch,000h,038h
                    db        054h,054h,058h,000h,07Ch,004h,004h,000h
                    db        038h,044h,044h,038h,000h,000h,000h,000h
                    db        01Ch,0A0h,0A0h,07Ch,000h,0C0h,078h,044h
                    db        07Ch,0C0h,000h,038h,044h,044h,038h,000h
                    db        03Ch,05Ah,054h,020h,000h,038h,044h,044h
                    db        038h,000h,040h,038h,004h,07Ch,000h,07Ch
                    db        050h,020h,000h,038h,044h,044h,028h,000h
                    db        004h,07Ch,004h,000h,03Ch,05Ah,054h,020h
                    db        000h,07Ch,020h,010h,07Ch,000h,068h,014h
                    db        014h,07Ch,000h,040h
;################################################# Скидки !!!
          LengthM6  dw        Message7 - Message6 - 2
          Message6  label     byte
                    db        03Eh,041h,041h,041h,022h,000h,07Ch,010h
                    db        028h,044h,000h,07Ch,020h,010h,07Ch,000h
                    db        0C0h,078h,044h,07Ch,0C0h,000h,07Ch,010h
                    db        028h,044h,000h,07Ch,020h,010h,07Ch,000h
                    db        000h,000h,05Fh,000h,05Fh,000h,05Fh
;################################################# До свидания!
          LengthM7  dw        MsgArray - Message7
          Message7  label     byte
                    db        0C0h,078h,046h,041h,07Fh,0C0h,000h,038h
                    db        044h,044h,038h,000h,000h,000h,000h,038h
                    db        044h,044h,028h,000h,03Ch,05Ah,054h,020h
                    db        000h,07Ch,020h,010h,07Ch,000h,0C0h,078h
                    db        044h,07Ch,0C0h,000h,020h,054h,054h,038h
                    db        040h,000h,07Ch,010h,010h,07Ch,000h,07Ch
                    db        020h,010h,07Ch,000h,068h,014h,014h,07Ch
                    db        000h,05Fh

          MsgArray  dw        Message0, Message1, Message2, Message3
                    dw        Message4, Message5, Message6, Message7
;################################################# >> Заставка <<
          Shot01    db        000h,000h,081h,000h,000h,000h,000h,000h
                    db        000h,000h,000h,081h,0C3h,081h,000h,000h
                    db        000h,000h,000h,000h,042h,0E7h,042h,000h
                    db        000h,000h,000h,000h,000h,024h,07Eh,024h
                    db        000h,000h,000h,000h,000h,000h,018h,03Ch
                    db        000h,000h,000h,000h,000h,000h,000h,018h
                    db        000h,000h,000h,000h,000h,000h,018h,024h
                    db        000h,000h,000h,000h,000h,03Ch,042h,05Ah
                    db        000h,000h,000h,000h,03Ch,042h,099h,0A5h
                    db        000h,000h,000h,07Eh,081h,03Ch,042h,05Ah
                    db        000h,000h,07Eh,081h,03Ch,042h,099h,0A5h
                    db        000h,0FFh,000h,07Eh,081h,03Ch,042h,05Ah
                    db        0FFh,000h,07Eh,081h,03Ch,042h,099h,0A5h
                    db        000h,0FFh,000h,07Eh,081h,03Ch,042h,042h
                    db        0FFh,000h,07Eh,081h,03Ch,042h,081h,081h
                    db        000h,0FFh,000h,07Eh,081h,000h,000h,000h
                    db        0FFh,000h,07Eh,081h,000h,000h,000h,000h
                    db        000h,0FFh,000h,000h,000h,000h,000h,000h
                    db        0FFh,000h,000h,000h,000h,000h,000h,000h
                    db        000h,000h,000h,000h,000h,000h,000h,000h
;################################################# сообщение о конце очереди
          EndTurn   db        07Fh,049h,049h,049h,036h,000h,038h,044h
                    db        044h,028h,000h,039h,054h,054h,059h,000h
;#####################################################################
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;###############################  ПРОЦЕДУРЫ  ###############################
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\ Взятие образа клавиатуры /\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
TakeKeys PROC
          push AX
          push CX
          push DX

          in AL,0                       ; port 0 -> ProgrKey
          and AL,1
          mov AH,AL                     ;           AH: bit 0
          in AL,1                       ; port 1 -> EditKeys
          and AL,3
          shl AL,EditKeys - 16
          or AL,AH                      ;           AH: bits 1,2
          and AX,0007h
          mov word ptr Keyboard+2,AX
          in AL,3                       ; port 3 -> EffectKeys & SpeedKeys
          ror AL,2                      ;           AX: bits 8..15
          mov AH,AL
          in AL,2                       ; port 2 -> MsgKeys
                                        ;           AX: bits 0..7
          mov word ptr Keyboard,AX

          mov CX,16                     ; подсчет количества нажатых клавиш
          xor DL,DL
TK_Next1: shr AX,1
          adc DL,0
          loop TK_Next1
          mov CX,3
          mov AX,word ptr Keyboard+2
TK_Next2: shr AX,1
          adc DL,0
          loop TK_Next2

          and DL,11111110b
          mov KbdError,DL

          pop DX
          pop CX
          pop AX
          ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\ Процедура создания очереди /\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
MakeTurn PROC
          cmp KbdError,0
          jnz $+10                      ; если ести ошибки в клавиатуре
          test word ptr Keyboard+2,1    ; клавиша "Прогр./Исп."?
          jz MT_Progr                   ; не нажата (режим программирования)
          ret

MT_Progr: cmp Regime,0
          je MT_NFst
          mov CurMsg,0
          mov CurSpeed,0
          mov CurEffect,0
          mov Regime,0
MT_NFst:  push AX
          push CX
          push BX
          push SI
          push DI

          mov AX,word ptr Keyboard
          and AX,MASK MsgKeys           ; проверка клавиш сообщений
          or AX,AX
          jz MT_Next1                   ; не нажаты
MT_Cycl1: shr AL,1
          inc AH
          jnc MT_Cycl1
          mov byte ptr CurMsg,AH
          jmp MT_Out

MT_Next1: mov AX,word ptr Keyboard
          and AX,MASK EffectKeys        ; проверка клавиш эффектов
          or AX,AX
          jz MT_Next2                   ; не нажаты
          xchg AL,AH
MT_Cycl2: shr AL,1
          inc AH
          jnc MT_Cycl2
          mov CurEffect,AH
          jmp MT_Out

MT_Next2: mov AX,word ptr Keyboard
          and AX,MASK SpeedKeys         ; проверка клавиш скоростей
          or AX,AX
          jz MT_Next3                   ; не нажаты
          rol AX,2
          shr AL,1
          inc AL
          mov CurSpeed,AL
          jmp MT_Out

MT_Next3: test word ptr Keyboard+2,2    ; проверка клавиши "Дальше"
          jz MT_Next4                   ; не нажата

          cmp CurMsg,0                  ; проверка выбранных параметров
          jz MT_Out                     ; если не выбрано сообщение
          cmp CurSpeed,0
          jz MT_Out                     ; если не выбрана скорость
          cmp CurEffect,0
          jz MT_Out                     ; если не выбран эффект

          cmp NumMsgs,TurnPosCount      ; проверка заполненности очереди
          jae MT_Out
          mov BX,NumMsgs
          shl BX,2
          mov AL,byte ptr CurMsg
          dec AL
          mov [BX+offset Turn].Num,AL
          mov AL,CurSpeed
          dec AL
          mov [BX+offset Turn].Speed,AL
          mov AL,CurEffect
          dec AL
          mov [BX+offset Turn].Effect,AL
          inc NumMsgs
          mov CurMsg,0
          mov CurSpeed,0
          mov CurEffect,0
          jmp MT_Out

MT_Next4: test word ptr Keyboard+2,4    ; проверка клавиши "С начала"
          jz MT_Out                     ; не нажата
          mov NumMsgs,0
          mov CurMsg,0
          mov CurSpeed,0
          mov CurEffect,0

MT_Out:   cmp NumMsgs,TurnPosCount      ; проверка заполненности очереди
          jae MT_Full                   ; если заполнена
          mov SI,offset Matrix          ; иначе

          mov BX,NumMsgs                ; отображения номера в очереди
          inc BX
          shl BX,2
          mov AX,word ptr CS:[BX+offset Num_Zero]
          mov [SI],AX
          mov AX,word ptr CS:[BX+offset Num_Zero+2]
          mov [SI+2],AX

          mov BX,CurMsg                 ; отображение номера сообщения
          shl BX,2
          mov AX,word ptr CS:[BX+offset Num_Zero]
          mov [SI+4],AX
          mov AX,word ptr CS:[BX+offset Num_Zero+2]
          mov [SI+6],AX

          mov BL,CurSpeed               ; отображение скорости
          xor BH,BH
          shl BX,2
          mov AX,word ptr CS:[BX+offset Num_Zero]
          mov [SI+8],AX
          mov AX,word ptr CS:[BX+offset Num_Zero+2]
          mov [SI+10],AX

          mov BL,CurEffect              ; отображение эффекта
          xor BH,BH
          shl BX,2
          mov AX,word ptr CS:[BX+offset Num_Zero]
          mov [SI+12],AX
          mov AX,word ptr CS:[BX+offset Num_Zero+2]
          mov [SI+14],AX
          jmp MT_Exit

MT_Full:  mov SI,offset EndTurn         ; вывод "Всё"
          mov DI,offset Matrix
          mov CX,16
MT_Next5: mov AL,CS:[SI]
          mov [DI],AL
          inc SI
          inc DI
          loop MT_Next5

MT_Exit:  mov MatrixMask,0
          mov Ticks,0

          pop DI
          pop SI
          pop BX
          pop CX
          pop AX
          ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\  Вывод части сообщения /\/\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
PutMessage PROC
          push AX
          push CX
          push BX
          push SI
          push DI

          xor AL,AL
          mov CX,SizeMatrix
          mov DI,offset Matrix
      rep stosb

          xor SI,SI
          mov BX,CurMsg
          shl BX,1
          mov BX,CS:[BX+offset MsgArray]
          mov DI,CurPos
          cmp DI,0
          jge PM_Next1
          neg DI
          add SI,DI
          xor DI,DI
PM_Next1: cmp SI,16
          je PM_Out
          cmp DI,LastPos
          je PM_Out
          mov AL,CS:[BX+DI]
          mov [SI+offset Matrix],AL
          inc SI
          inc DI
          jmp PM_Next1
PM_Out:   pop DI
          pop SI
          pop BX
          pop CX
          pop AX
          ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\ Создание маски эффекта /\/\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
PutEffect PROC
          push AX
          cmp CurEffect,0
          jne PE_Next1
          mov MatrixMask,000h           ; черным по белому
          jmp PE_Exit
PE_Next1: cmp CurEffect,1
          jne PE_Next2
          mov MatrixMask,0FFh           ; белым по черному
          jmp PE_Exit
PE_Next2: cmp CurEffect,2
          jne PE_Next3
          mov MatrixMask,0F0h           ; черный верх, белый низ
          jmp PE_Exit
PE_Next3: cmp CurEffect,3
          jne PE_Next4
          mov MatrixMask,00Fh           ; белый верх, черный низ
          jmp PE_Exit
PE_Next4: cmp CurEffect,4
          jne PE_Next5
          mov AL,byte ptr DinamicFill   ; динамическая заливка с верху в низ
          mov MatrixMask,AL
          inc DinCount
          and DinCount,003h
          jne PE_Pass1
          rol DinamicFill,1
PE_Pass1: jmp PE_Exit
PE_Next5: cmp CurEffect,5
          jne PE_Exit
          mov AL,byte ptr DinamicFill   ; динамическая заливка с низу в верх
          mov MatrixMask,AL
          inc DinCount
          and DinCount,003h
          cmp DinCount,0
          jne PE_Exit
          ror DinamicFill,1
PE_Exit:  pop AX
          ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\ Процедура вывода очереди /\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
OutTurn PROC
          test word ptr Keyboard+2,1    ; клавиша "Прогр./Исп."?
          jz OT_Quit                    ; не нажата (режим программирования)
          cmp Ticks,0                   ; действует задержка?
          je OT_View
OT_Quit:  ret

OT_View:  cmp Regime,1
          je OT_NFst
          mov CurTurnPos,-1
          mov CurShot,0
          mov Regime,1
OT_NFst:  push AX
          push BX
          push CX
          push SI
          push DI

          mov BX,CurTurnPos
          cmp BX,NumMsgs                ; закончилась очередь?
          jae OT_Film                   ; да
          mov BX,CurPos
          cmp BX,LastPos                ; закончилось сообщение?
          jge OT_Film                   ; да
          jmp OT_Next1

OT_Film:  cmp CurShot,ShotsCount        ; закончились кадры?
          jae OT_Pass0                  ; да
          jmp OT_NxSht

OT_Pass0: mov BX,CurTurnPos
          cmp BX,NumMsgs                ; закончилась очередь?
          jb OT_Pass1                   ; нет
          mov CurTurnPos,-1
          mov CurPos,32767
OT_Pass1: mov BX,CurPos
          cmp BX,LastPos                ; закончилось сообщение?
          jl OT_Next1                   ; нет
          inc CurTurnPos
          mov BX,CurTurnPos
          shl BX,2
          mov AX,[BX+offset Turn].Num
          mov byte ptr CurMsg,AL
          mov CurSpeed,AH
          mov AL,[BX+offset Turn].Effect
          mov CurEffect,AL
          mov BX,CurMsg
          shl BX,1
          mov BX,CS:[BX+offset MsgArray]
          mov AX,CS:[BX-2]
          mov LastPos,AX

          mov CurPos,-15
          mov CurShot,0
          mov DinamicFill,0FF00h
          mov DinCount,0

OT_Next1: call PutEffect
          call PutMessage
          inc CurPos
          cmp CurSpeed,0
          je OT_Pass3
          mov Ticks,FastSpeed
          jmp OT_Exit
OT_Pass3: mov Ticks,SlowSpeed
          jmp OT_Exit

OT_NxSht: mov MatrixMask,0              ; вывод фильма
          mov BX,CurShot
          shl BX,3
          mov SI,offset Matrix
          mov DI,offset Matrix+15
          mov CX,8
OT_NxByte:mov AL,CS:[BX+offset Shot01]
          mov [SI],AL                   ;┐ Симметричный
          mov [DI],AL                   ;┘  вывод кадра
          inc SI
          dec DI
          inc BX
          loop OT_NxByte
          inc CurShot

OT_Exit:  pop DI
          pop SI
          pop CX
          pop BX
          pop AX
          ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\/\/\/\/\ Задержка /\/\/\/\/\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
Pause PROC
          cmp Ticks,0
          je P_Exit
          dec Ticks
P_Exit:   ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\/\  Вывод образа экрана /\/\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
OutMatrix PROC
          push AX
          push CX
          push DX
          push SI

          mov SI,offset Matrix
          xor DX,DX
          mov CX,SizeMatrix
OM_Next:  mov AL,[SI]
          xor AL,MatrixMask
          out DX,AL
          inc SI
          inc DX
          loop OM_Next

          pop SI
          pop DX
          pop CX
          pop AX
          ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\ Инициализация переменных /\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
Init PROC
          push AX
          push CX
          push DI

          xor AL,AL
          mov CX,EndData-StartData
          mov DI,offset Matrix
      rep stosb

          mov DinamicFill,0FF00h

          pop DI
          pop CX
          pop AX
          ret
ENDP
;############################################################################
;############################ Основная программа ############################
begin:    mov AX,data
          mov DS,AX
          mov ES,AX
          mov AX,stack
          mov SS,AX
          mov SP,offset StkTop

          call Init
Cycle1:   call TakeKeys
          call MakeTurn
          call OutTurn
          call Pause
          call OutMatrix
          jmp Cycle1

          org 07F0H
start:    jmp begin

ends

end start
;########################### That's all folks !!! ###########################