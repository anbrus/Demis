;ОПИСАНИЕ КОНСТАНТ

RomSize   EQU   4096
NMax       EQU   50

;Адреса портов

BUTTON_INPORT1   EQU   0
BUTTON_INPORT2   EQU   1

Data       SEGMENT AT 0
           ZadachaMas DB    10 dup(10 dup (?))    ;массив с задачами   
           ImageInd   DB    7 DUP(?)              ;массив отображения для 7-сегментных индекаторов
           
           Button     DW    ?         ;изображение кнопок
           EmpButton  DB    ?         ;флаг пустой клавиатуры 
           ButtonErr  DB    ?         ;флаг ошибки клавиатуры
           ButtonCode DB    ?         ;код нажатой клавиши
           AutoCt     DB    ?         ;счётчик автоповтора  
           
           ModeProgr  DB    ?         ;флаг режима программирования
           ModeKtest  DB    ?         ;флаг режима контрольного тестирования
           ModePtest  DB    ?         ;флаг режима пробного тестирования
           
           FlagZad_Vopr    DB    ?         ;флаг номера задачи/вопроса
           FlagOtvet_Time  DB    ?         ;флаг ответа/времени
           
           FlagSignal DB    ?         ;флаг сигнала УПС
           
           Nzadacha   DB    ?         ;номер задачи
           Nvopros    DB    ?         ;номер вопроса
           
           StartTest  DB    ?         ;флаг начала теста
           EndTest    DB    ?         ;флаг конца теста
           
           Rezult     DB    ?         ;кол-во правельных ответов
           Rez        DB    ?         ;оценка
           
           TimeOld    DB    ?         ;старое время
           Time       DB    ?         ;время  
           Sec        DW    ?         ;счётчик секунды
           Min        DB    ?         ;счётчик минуты
Data       ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Code

;массив изображений для 7-сегментного индекатора
Image      DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh,0,073h,060h,06Dh,07Bh

;процедура устранения дребезга            
VibrDestr  PROC  NEAR
VD1:       mov   dx,ax                   ;Сохранение исходного состояния
           mov   bh,0                    ;Сброс счётчика повторений
VD2:       in    al,BUTTON_INPORT2       ;Ввод текущего состояния
           mov   ah,al
           in    al,BUTTON_INPORT1
           cmp   ax,dx                   ;Текущее состояние=исходному?
           jne   VD1                     ;Переход, если нет
           inc   bh                      ;Инкремент счётчика повторений
           cmp   bh,NMax                 ;Конец дребезга?
           jne   VD2                     ;Переход, если нет
           mov   ax,dx                   ;Восстановление местоположения данных
           ret
VibrDestr  ENDP

;процедура подготовки 
PREPAIR Proc near
       ;установка режимов и флагов  
       mov   ButtonErr,0
       
       mov   ModeProgr,0  
       mov   ModeKtest,0  
       mov   ModePtest,0FFh
       
       mov   FlagZad_Vopr,0FFh 
       mov   FlagOtvet_Time,0FFh  
       
       mov   StartTest,0  
       mov   EndTest,0    
       
       mov   FlagSignal,0
       
       ;инициализация переменных
       mov   Nzadacha,1
       mov   Nvopros,1
       mov   Rezult,0
       
       mov   Time,030h
       mov   TimeOld,030h
       mov   Sec,02EFh
       mov   Min,60
        
       ;инициализация массива с задачами
       mov   cl,0
       mov   si,0
RP:         
       mov   ZadachaMas[bx][si],1
       inc   si
       cmp   si,10
       jne   RP
       mov   si,0
       inc   cl
       mov   al,10
       mul   cl
       mov   bx,ax
       cmp   cl,10
       jne   RP
       
       ret
PREPAIR  EndP

;процедура опроса кнопок
BUTTON_READ  Proc near
             mov dx,BUTTON_INPORT2
             in  al,dx
             mov ah,al
             mov dx,BUTTON_INPORT1
             in  al,dx
             call VibrDestr
             cmp ax,0
             je  BR1
             cmp ax,Button
             je  BR2
             mov Button,ax
             mov EmpButton,0
             mov AutoCt,01h 
             jmp BR2 
BR1:
             mov Button,0
             mov EmpButton,0FFh              
BR2:                                                  
             ret
BUTTON_READ  EndP

;процедура контроля кнопок
BUTTON_CONTROL  Proc near
                cmp EmpButton,0FFh
                je  BCNTR3  
                  
                mov ax,Button
                xor dl,dl 
                mov cx,16               
BCNTR1: 
                shr ax,1                ;двигать до тех пор,
                adc dl,0
                loop BCNTR1                 ;пока 1 не уйдет
                
                cmp dl,1
                ja  BCNTR2
                mov ButtonErr,0
                jmp BCNTR3
BCNTR2:
                mov ButtonErr,0FFh            
BCNTR3:                
                ret
BUTTON_CONTROL  EndP

;процедура получения кода нажатой кнопки
BUTTON_CODE  Proc near
             cmp EmpButton,0FFh
             je  BC2
             cmp ButtonErr,0FFh
             je  BC2
               
             ;определение номера активного входа активного порта
             mov ax,Button
             xor cx,cx               
BC1: 
             inc cl
             shr ax,1                ;двигать до тех пор,
             jnz BC1                 ;пока 1 не уйдет
   
             mov ButtonCode,cl       
BC2:
             ret         
BUTTON_CODE  EndP

;переключение режимов
MODE         Proc near
             cmp EmpButton,0FFh
             je  MP
             cmp ButtonErr,0FFh
             je  M
             
             cmp StartTest,0FFh
             je M
             
             ;кнопки переключеня режимов?
             cmp ButtonCode,6
             jb  M
             cmp ButtonCode,8
             ja  M
             
             mov EmpButton,0FFh
             
             ;при переключении режимов:
             mov Nvopros,1
             mov Nzadacha,1
             mov EndTest,0
             mov FlagZad_Vopr,0FFh
             mov FlagOtvet_Time,0FFh
             mov FlagSignal,0
             mov al,TimeOld
             mov Time,al
             
             ;кнопка ПР
             cmp ButtonCode,6
             jne M1
             mov ModeProgr,0FFh
             mov ModeKtest,0
             mov ModePtest,0
MP:          jmp M
M1:          
             ;кнопка КТ   
             cmp ButtonCode,7
             jne M2
             mov ModeProgr,0
             mov ModeKtest,0FFh
             mov ModePtest,0
             jmp M
M2:        
             ;кнопка ПТ
             mov ModeProgr,0
             mov ModeKtest,0
             mov ModePtest,0FFh
M:     
             ret
MODE         EndP

;кнопки 1-5
BUTTONS_1_5  Proc near
             cmp EmpButton,0FFh
             je  BPP
             cmp ButtonErr,0FFh
             je  BPP
             
             ;кнопки 1-5
             cmp ButtonCode,5
             ja  BPP
             
             mov EmpButton,0FFh
             
             cmp ModeProgr,0FFh
             jne B1
             
             cmp FlagOtvet_Time,0FFh
             jne B

             xor ah,ah
             mov al,Nzadacha
             dec al
             mov dl,10
             mul dl
             mov bx,ax
             xor ah,ah
             mov al,Nvopros
             dec al
             mov si,ax
             mov al,ButtonCode
             mov ZadachaMas[bx+si],al
BPP:         jmp B
B1:
             cmp StartTest,0FFh
             jne B
             
             mov FlagSignal,0FFh
             
             xor ah,ah
             mov al,Nzadacha
             dec al
             mov dl,10
             mul dl
             mov bx,ax
             xor ah,ah
             mov al,Nvopros
             dec al
             mov si,ax
             mov al,ButtonCode
             cmp al,ZadachaMas[bx+si]
             jne B2
             add Rezult,1             
B2:             
             cmp Nvopros,10
             jne B3
             mov StartTest,0
             mov EndTest,0FFh
             jmp B
B3:             
             inc Nvopros
B:             
             ret
BUTTONS_1_5  EndP

;кнопка ТЕСТ
BUTTON_TEST  Proc near
             cmp EmpButton,0FFh
             je  BTT
             cmp ButtonErr,0FFh
             je  BTT
             
             cmp ModeProgr,0
             jne BTT
             
             ;кнопка ТЕСТ
             cmp ButtonCode,15
             jne  BTT
             
             mov EmpButton,0FFh
             
             cmp StartTest,0FFh
             je BTT
             mov StartTest,0FFh
             mov al,TimeOld
             mov Time,al
             mov EndTest,0
             mov Rezult,0
             mov Nvopros,1
             mov FlagSignal,0
BTT:                       
             ret 
BUTTON_TEST  EndP

;кнопки управления режимом программирования
BUTTON_PROG  Proc near
             cmp EmpButton,0FFh
             je  BPG
             cmp ButtonErr,0FFh
             je  BPG
             
             cmp ModeProgr,0FFh
             jne BPG
             
             ;кнопка ЗД
             cmp ButtonCode,9
             jne BPG1
             mov FlagZad_Vopr,0FFh
             mov EmpButton,0FFh
             mov Nvopros,1
             jmp BPG
BPG1:
             ;кнопка ВП
             cmp ButtonCode,10
             jne BPG2
             mov FlagZad_Vopr,0
             mov EmpButton,0FFh
             jmp BPG
BPG2:
             ;кнопка BP
             cmp ButtonCode,13
             jne BPG3
             mov FlagOtvet_Time,0
             mov EmpButton,0FFh
             jmp BPG
BPG3:          
             ;кнопка OT
             cmp ButtonCode,14
             jne BPG
             mov FlagOtvet_Time,0FFh
             mov EmpButton,0FFh
BPG:                       
             ret 
BUTTON_PROG  EndP             

;кнопки <,>
BUTTON_INC_DEC  Proc near
             cmp EmpButton,0FFh
             je  BIDP
             cmp ButtonErr,0FFh
             je  BIDP
             
             dec AutoCt
             jnz BIDP
             mov AutoCt,0FFh
             
             ;кнопка <
             cmp ButtonCode,11
             jne BID3
             cmp FlagOtvet_Time,0
             jne BID1
             cmp Time,10h
             je BID
             mov al,TimeOld
             sub al,1
             das
             mov Time,al
             mov TimeOld,al
             jmp BID
BID1:
             cmp FlagZad_Vopr,0FFh
             jne BID2
             cmp Nzadacha,1
             je BID 
             dec Nzadacha
BIDP:        jmp BID
BID2:             
             cmp Nvopros,1
             je BID
             dec Nvopros
             jmp BID
BID3:              
             ;кнопка >
             cmp ButtonCode,12
             jne BID
             cmp FlagOtvet_Time,0
             jne BID4
             cmp Time,060h
             je BID
             mov al,TimeOld
             add al,1
             daa
             mov Time,al
             mov TimeOld,al
             jmp BID
BID4:
             cmp FlagZad_Vopr,0FFh
             jne BID5
             cmp Nzadacha,10
             je BID
             inc Nzadacha
             jmp BID
BID5:             
             cmp Nvopros,10
             je  BID
             inc Nvopros
BID:                       
             ret 
BUTTON_INC_DEC  EndP 
                                     
;формирование результата
FORM_REZ     Proc near
             cmp ButtonErr,0FFh
             je  FR
             
             cmp EndTest,0FFh
             jne FR
             cmp Rezult,6
             ja  FR1
             mov Rez,2
             jmp FR
FR1:             
             cmp Rezult,7
             ja  FR2
             mov Rez,3
             jmp FR
FR2:         
             cmp Rezult,8
             ja FR3
             mov Rez,4
             jmp FR
FR3:                 
             mov Rez,5
FR:
             ret
FORM_REZ     EndP

;процедура формирования времени
FORM_TIME  Proc near
            cmp ButtonErr,0FFh
            je  FT
            
            cmp ModeKtest,0FFh
            jne FT
            cmp StartTest,0FFh
            jne FT
            
            dec Sec
            cmp Sec,0
            je  FTS
            jmp FT
FTS:            
            mov Sec,02DFh
            ;dec Min
            ;cmp Min,0
            ;je  FTM
            ;jmp FT
FTM:            
            ;mov Min,60
    
            mov al,Time
            sub al,1
            das
            mov Time,al
            cmp Time,0
            je  FT1
            jmp FT
FT1:            
            mov StartTest,0
            mov EndTest,0FFh
            cmp Nzadacha,10
FT:            
            ret
FORM_TIME   EndP
  
;процедура отображения в светодиодах 
INDIC_DIOD  Proc near
       cmp ButtonErr,0FFh
       je  ID
       
       mov   al,0
       
       cmp   ModeProgr,0FFh  
       jne   ID1
       or    al,1
ID1:       
       cmp   ModeKtest,0FFh
       jne   ID2
       or    al,2
ID2:         
       cmp   ModePtest,0FFh
       jne   ID3
       or    al,4
ID3:       
       cmp   FlagZad_Vopr,0FFh
       jne   ID4
       or    al,8
       jmp   ID5
ID4:        
       or    al,16
ID5:       
       cmp   FlagOtvet_Time,0   
       jne   ID6
       or    al,32
       jmp   ID7
ID6:       
       or    al,64
ID7:       
       cmp   StartTest,0FFh 
       jne   ID8
       or    al,128
ID8:       
       out   7,al
ID:   
       ret
INDIC_DIOD  EndP

;процедура форм. сигнала УПС
SIGNAL      Proc near
            cmp ButtonErr,0FFh
            je  s
            
            cmp FlagSignal,0FFh
            jne S
            mov al,1
            out 8,al
            
            mov cx,0FFFFh
S1:            
            dec cx
            inc cx
            dec cx
            inc cx
            loop S1
            
            mov FlagSignal,0
            mov al,0
            out 8,al
S:              
            ret
SIGNAL      EndP
            
;процедура формирования массива отображения для 7-сегментных индекаторов 
FORM_INDIC  Proc near
       cmp ButtonErr,0FFh
       je  FIP
             
       xor di,di
       
       ;номер задачи 
       xor ah,ah
       mov al,Nzadacha
       daa
       mov ah,al
       mov cl,4
       shr al,cl
       mov ImageInd[di],al
       inc di
       mov al,ah
       and al,0Fh
       mov ImageInd[di],al
       
       ;номер вопроса
       inc di
       mov al,Nvopros
       daa
       mov ah,al
       mov cl,4
       shr al,cl
       mov ImageInd[di],al
       inc di
       mov al,ah
       and al,0Fh
       mov ImageInd[di],al       
       
       ;время
       mov di,4
       mov al,FlagOtvet_Time
       not al
       and al,ModeProgr
       or  al,ModeKtest 
       cmp al,0FFh
       jne FI1
       mov al,Time 
       mov ah,al
       mov cl,4
       shr al,cl
       mov ImageInd[di],al
       inc di
       mov al,ah
       and al,0Fh
       mov ImageInd[di],al
FIP:   jmp FI2
FI1:
       mov ImageInd[di],10
       inc di
       mov ImageInd[di],10
FI2:
       ;ответ/оценка
       inc di
       cmp ModeProgr,0FFh
       jne FI3
       cmp FlagOtvet_Time,0FFh
       jne FI4
       xor ah,ah
       mov al,Nzadacha
       dec al
       mov dl,10
       mul dl
       mov bx,ax
       xor ah,ah
       mov al,Nvopros
       dec al
       mov si,ax
       mov al,ZadachaMas[bx+si]
       mov ImageInd[di],al
       jmp FI      
FI3:               
       cmp EndTest,0FFh
       jne FI4
       mov al,Rez
       mov ImageInd[di],al
       jmp FI
FI4:
       mov ImageInd[di],10 
FI:       
       ret
FORM_INDIC  EndP

;процедура формирования массива отображения для 7-сегментных индекаторов при ошибке
FORM_INDIC_ERR Proc near
       cmp ButtonErr,0
       je  FIE

       xor di,di
       
       mov ImageInd[di],11
       inc di
       mov ImageInd[di],12
       inc di
       mov ImageInd[di],10
       inc di
       mov ImageInd[di],10
       inc di
       mov ImageInd[di],13
       inc di
       mov ImageInd[di],14
       inc di
       mov ImageInd[di],10
FIE:       
       ret
FORM_INDIC_ERR  EndP            

;процедура отображения для 7-сегментных индекаторов 
INDIC  Proc near
       ;cmp ButtonErr,0FFh
       ;je  I2
             
       xor ax,ax
       mov dx,7
       mov di,7
I1:       
       dec dx
       dec di
       mov al,ImageInd[di]
       mov si,ax
       mov al,Image[si]
       out dx,al
       cmp dx,0
       jne I1      
I2:       
       ret
INDIC  EndP

Start:
           mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax

;Здесь размещается код программы
           call  PREPAIR   
Infloop:
           call  BUTTON_READ
           call  BUTTON_CONTROL
           call  BUTTON_CODE 
           call  MODE      
           call  BUTTONS_1_5
           call  BUTTON_TEST
           call  BUTTON_PROG
           call  BUTTON_INC_DEC                                           
           call  FORM_REZ
           call  FORM_TIME
           call  INDIC_DIOD
           call  SIGNAL
           call  FORM_INDIC
           call  FORM_INDIC_ERR
           call  INDIC 
                     
           jmp   Infloop

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end
