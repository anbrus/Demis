.386
;Задайте объём ПЗУ в байтах

           RomSize    EQU   4096
           
           MaxLoopsForVibrDestr EQU 10h;
           
           ErrorMessgaeLength   EQU 06h; длина сообщения об ошибке. 
           DataFixedParamsLen   EQU 06h; длина поля параметров. 
           PointNumLen          EQU 06h; длина поля номера точки.  
           DataValueLen         EQU 03h; длина поля данных, первой и второй произв.
           
           MaxFixedValue        EQU 4FFFh; макс. число фиксируемых значений.
           
                                   ; В порт 15h
           DataFixedFlag EQU 01h    ; -> загарится "Фиксация данных"
           DataVisioFlag EQU 02h    ; -> загарится "Просмотр данных"
                     
                                   ; для "Подрежим работы"  
           DataVisioShowMask    EQU 1Ch;
           DataVisioShowAllFlag EQU 04h; -> загарится "Просмотр всех данных".
           DataVisioShowMaxFlag EQU 08h; -> загарится "Просмотр максим.".
           DataVisioShowMinFlag EQU 10h; -> загарится "Просмотр миним.".
           
           DataParamsMask   EQU 0E0h; маска выделения след. параметров.
           DestroyFixedParam EQU 9Fh; маска удаления параметров фиксации
           DataFixedParamTd EQU 20h; -> загарится "Период дискретизации".
           DataFixedParamT  EQU 40h; -> загарится "Отрезок времени".
           DataVisioParamN  EQU 80h; -> задается номер точки 
           
           WorkStatusesOutPort EQU 15h; адрес порта для зажигания 
           WorkStatusesInPort  EQU 00h;
           
           KeyBoardOutPort     EQU 16h; адрес порта клавиатуры 
           KeyBoardInPort      EQU 01h;
           
           DataFixedParamPort  EQU 00h;
           DataVisioPort       EQU 06h;
           DataVisioFirstPort  EQU 09h;
           DataVisioSecondPort EQU 0Ch;
           PointNumberPort     EQU 0Fh;  
           
           ADCOutPort          EQU 17h
           ADCInPortStatus     EQU 02h
           ADCInPortData       EQU 03h;
           
           DefaultButsDataMask EQU 0FFh;
           FixedDataButsMask   EQU 03h; можно нажать только "След." и "Старт"
           DataVisioButsMask   EQU 0FDh; можно нажать все, кроме "Старт" 
           
           EnterButtonIndex    EQU 0Ch;
           PointNumButIndex    EQU 0Dh;
           TimeLenButIndex     EQU 0Eh;
           PeriodDsButIndex    EQU 0Fh;
           MaxButtonIndex      EQU 0Fh; 
           
IntTable   SEGMENT AT 0 use16  ;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT AT 0A000h use16  ;Здесь размещаются описания переменных

           WorkStatusesData db ?    ;Инф. о режиме и подрежиме работы. 
           DigitsImages db 10 dup (?); отображение десятичных цифр

           ButtonsData  db ?;    состояние кнопок. ( 00 - данные отсутствуют )
           ButtonsDataMask db ?; маска состояния кнопок, используется для оценки
                               ; разрешения обработки 
           
           KeyBoardImage db 4 dup (?); образ клавиатуры
           KeyBoardData db ?         ; очередная цифра. ( FF - данные отсутствуют )
           
           IsErrorFound db ?   ; флаговый байт ошибки.
           ErrorOutPort db ?   ; порт для вывода ошибки.
           
           IsDataFixedNow db ? ; флаговый байт фиксации данных.
           DataFixedPeriod dd ?; период дискретизации
           DataFixedTimeLn dd ?; Отрезок времени для фиксации данных.
           DataVisioPointNum dd ?; Номер точки
           MaxPointNumber    dd ?; Максимальное число точек.
           IsPointNumUpDate  db ?; изменился ли номер точки ( 0 - False ).

           TempDigitsArr     db 3 dup (?); массив временного хранения значения.
           PeriodKoofArr     db 4 dup (?); массив коэфициентов.
           TimeLenKoofArr    db 4 dup (?); массив коэфициентов.
           PointNumKoofArr   db 4 dup (?);
           
           DataValue         dw ?; значение вх. параметра для DataVisioPointNum.
           FirstValue        dw ?; значение 1-ой производной в точке DataVisioPointNum
           IsFOtr            db ?;
           SecondValue       dw ?;
           IsSOtr            db ?;

;          Далее идет описание массивов отображения 
           UnVisibleData db 6 dup (?); для гашения изображения.
           
           PeriodDataObr db 6 dup (?); для периода дискретизации
           TimeLnDataObr db 6 dup (?); для отрезка времени для фиксации данных.
           
           PointNumberObr db 6 dup (?); для номера точки
           
           DataObr        db 4 dup (?); для поля данных.
           FirstProizvObr db 4 dup (?); для поля первой производной.
           SecondProizvObr db 4 dup (?); для второй первой производной.

; 
           DataFixedValue dw MaxFixedValue dup (?); массив зафиксированных значений.
                    
Data       ENDS

InitData   SEGMENT use16
           DigitsImagesCns db 03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh;

           ErrorImage db 060h, 078h, 060h, 060h, 073h, 00h;
           
           
InitData   ENDS

Steck        SEGMENT AT 0B000h use16 
           dw    200 dup (?)
StkTop     Label Word
Steck        ENDS

Code       SEGMENT use16    
           
           ASSUME cs:Code,ds:Data,es:Data,ss:Steck;

include InitData.asm;
include IOProc.asm
include KeyBoard.asm
include FixedDt.asm;
include SetParam.asm;
include DataProc.Asm;
          
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Steck
           mov   ss,ax
           lea   sp,StkTop

           CALL WorkInit          ; Инициализация работы.

Program_StartPoint : 
           
           Call GetButtonsData;
           Call CheckButtonsData;
           Call GetKeyBoardInput;
           Call GetKeyBoardData;
           Call CheckKeyBoardData;
           
           mov al, IsPointNumUpDate
           test al, al
           jz Program_DataNotUnDate
           call UpDateDataFields 
                      
Program_DataNotUnDate:                      
           Call CreateObrazArrays; Сформировать массивы отображения.
           Call UpdateOutdevices; Обновить состояние портов вывода.
          
           jmp Program_StartPoint;

           
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-(( SIZE InitData + 15 ) and 0FFF0h )
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
