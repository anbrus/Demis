;ОПИСАНИЕ КОНСТАНТ
RomSize   EQU   4096
NMax       EQU   50

;Адреса портов 

BUTINP1   EQU   0
BUTINP2   EQU   1

Data       SEGMENT AT 0
                      
           But               DW    ?         ;изображение кнопок
           ButCode           DB    ?         ;код нажатой клавиши
           ACt               DB    ?         ;счётчик автоповтора  
           EmpBut            DB    ?         ;флаг пустой клавиатуры 
           ButErr            DB    ?         ;флаг ошибки клавиатуры
           
           ModeProgr         DB    ?         ;флаг режима программирования
           ModeKtest         DB    ?         ;флаг режима контрольного тестирования
                   
           FlagZad_Vopr      DB    ?         ;флаг номера задачи/вопроса
           FlagOtvet         DB    ?         ;флаг ответа
           
           FlagSignal        DB    ?         ;флаг сигнала УПС
           
           Nzadacha          DB    ?         ;номер варианта
           Nvopros           DB    ?         ;номер вопроса
           KolVopr           DB    ?         ;кол-во вопросов
           
           StartTest         DB    ?         ;флаг начала теста
           EndTest           DB    ?         ;флаг конца теста
           
           Rezult            DB    ?         ;кол-во правельных ответов
           Rez               DB    ?         
           
           TimeOld           DB    ?         ;старое время
           Time              DB    ?         ;время  
           Sec               DW    ?         ;счётчик секунды
          
           
           Vremia_Vkl        DB    ?         ;время вкл\выкл
           OldBut            DB    ?         ;кнопка отжата
           
           ZadachaMas DB    10 dup(10 dup (?))    ;массив с задачами   
           ImageInd   DB    7 DUP(?)              ;массив отображения для 7-сегментных индекаторов

            sart      db  9 dup   (?)
           
Data       ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Code

;массив изображений для 7-сегментного индекатора
Image      DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh,0,073h,060h,06Dh,07Bh

;процедура устранения дребезга            
VibrDestr  PROC  NEAR
VD1:       mov   dx,ax                   ;Сохранение исходного состояния
           mov   bh,0                    ;Сброс счётчика повторений
VD2:       in    al,BUTINP2              ;Ввод текущего состояния
           mov   ah,al
           in    al,BUTINP1
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
       mov   ButErr,0
       mov   ModeProgr,0  
       mov   ModeKtest,0  
       mov   FlagZad_Vopr,0FFh 
       mov   FlagOtvet,0FFh  
       mov   StartTest,0  
       mov   EndTest,0    
       mov   FlagSignal,0
     
      push bx
        lea  bx ,sart
        mov si,0   
       mov cx,9
       mov al,0
p1:     mov [bx+si],al
       inc si   
       loop p1
       pop bx
     
;инициализация переменных
       mov   Nzadacha,1
       mov   Nvopros,1
       mov   KolVopr,1 
       mov   Rezult,0
       
       mov   Time,01h
       mov   TimeOld,01h
       mov   Sec,02EFh
      
       mov Vremia_Vkl,0ffh 
       mov  OldBut,0
       ;инициализация массива с задачами
       mov   cl,0
       mov   si,0
RP:         
       mov   ZadachaMas[bx][si],0
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
BUT_RD  Proc near
             mov dx,BUTINP2 
             in  al,dx
             mov ah,al
             mov dx,BUTINP1
             in  al,dx
             call VibrDestr
             cmp ax,0
             je  BR1
             cmp ax,But
             je  BR2
             mov But,ax
             mov EmpBut,0
             mov ACt,01h 
             jmp BR2 
BR1:
             mov But,0
             mov EmpBut,0FFh 
             mov OldBut,0             
BR2:                                                  
             ret
BUT_RD  EndP

;процедура контроля кнопок
BUT_CL  Proc near
                cmp EmpBut,0FFh
                je  BCNTR3  
                  
                mov ax,But
                xor dl,dl 
                mov cx,16               
BCNTR1: 
                shr ax,1                ;двигать до тех пор,
                adc dl,0
                loop BCNTR1                 ;пока 1 не уйдет
                
                cmp dl,1
                ja  BCNTR2
                mov ButErr,0
                jmp BCNTR3
BCNTR2:
                mov ButErr,0FFh            
BCNTR3:                
                ret
BUT_CL  EndP

;процедура получения кода нажатой кнопки
BUT_CODE  Proc near
             cmp EmpBut,0FFh
             je  BC2
             cmp ButErr,0FFh
             je  BC2
               
             ;определение номера активного входа активного порта
             mov ax,But
             xor cx,cx               
BC1: 
             inc cl
             shr ax,1                ;двигать до тех пор,
             jnz BC1                 ;пока 1 не уйдет
   
             mov ButCode,cl       
BC2:
             ret         
BUT_CODE  EndP

;переключение режимов
MODE       Proc near
             cmp EmpBut,0FFh   ;сравнение пусто клва
             je  M4
             cmp ButErr,0FFh   ;сравнение с ошибкой ввода
             je  M4
             cmp StartTest,0FFh   ;сравнение с началом теста
             je M4
        ;кнопки переключеня режимов?
             jmp m6
m4:          jmp m5              
         ;кнопка ПР
m6:          cmp ButCode,6
             jne M1
             
             mov Nvopros,1
             mov Nzadacha,1
             mov EndTest,0
             mov FlagZad_Vopr,0FFh
             mov FlagOtvet,0FFh
             mov FlagSignal,0
             mov al,TimeOld
             mov Time,al
             
             mov ModeProgr,0FFh
             mov ModeKtest,0
             
             mov Vremia_Vkl,0ffh
             jmp m
M1:          
          ;кнопка КТ____________________________   
             cmp ButCode,7
             jne M2
             
             mov Nvopros,1
             mov Nzadacha,1
             mov EndTest,0
             mov FlagZad_Vopr,0FFh
             mov FlagOtvet,0FFh
             mov FlagSignal,0
             mov al,TimeOld
             mov Time,al
             
             mov ModeProgr,0
             mov ModeKtest,0FFh
             mov Vremia_Vkl,0FFh
             
             jmp M

M2:          cmp ButCode,8
             jne M
             cmp ModeKtest,0ffh
             jne M
             cmp ModeProgr,0ffh
             je m
             cmp OldBut,8
             jz m
             cmp Vremia_Vkl,0
             je M3
             mov Vremia_Vkl,0
             jmp M
M3:             
           mov Vremia_Vkl,0ffh
M:         mov al,ButCode
           mov OldBut,al
m5:          ret
MODE         EndP

;кнопки 1-5
BUTS_1_5  Proc near
             cmp EmpBut,0FFh
             je  Bpp
             cmp ButErr,0FFh
             je  Bpp
             
         ;кнопки 1-5
             cmp ButCode,5
             ja  BPP ; выше
             mov EmpBut,0FFh
             cmp ModeProgr,0FFh
             jne B1
             
             cmp FlagOtvet,0FFh
             jne Bpp
             xor ah,ah
             mov al,Nzadacha
             dec al
             mov dl,9
             mul dl
             mov bx,ax
             xor ah,ah
             mov al,Nvopros
             dec al
             mov si,ax
             mov al,ButCode
             mov ZadachaMas[bx+si],al
             
BPP:         jmp B
B1:
             cmp StartTest,0FFh
             jne B
             
             mov FlagSignal,0FFh
             
             xor ah,ah
             mov al,Nzadacha
             dec al
             mov dl,9
             mul dl
             mov bx,ax
             xor ah,ah
             mov al,Nvopros
             dec al
             mov si,ax
          
            mov al,ButCode
            cmp sart[si],al
             je b           
                    
            cmp al,ZadachaMas[bx+si]
            jne b33
            inc rezult   
            jmp b22
b33:                  
             
            mov al, sart[si]
            cmp al,ZadachaMas[bx+si]
            jne b22    
            cmp rezult,0
             jbe b22
             dec rezult
               
         b22:  
               mov al,ButCode
              mov sart[si],al 
B2:           
              mov al,KolVopr
              cmp Nvopros,al  
             jne B3       
             jmp B
B3:             
             inc Nvopros         
B:             
             ret
BUTS_1_5  EndP

;кнопка ТЕСТ
BUT_TEST  Proc near
             cmp EmpBut,0FFh
             je  BTT
             cmp ButErr,0FFh
             je  BTT
             
             cmp ModeProgr,0
             jne BTT
             
           ;кнопка ТЕСТ
             cmp ButCode,15
             jne  BTT
             
             mov EmpBut,0FFh
             cmp StartTest,0FFh
             je BTT
             mov al,0
             out 8,al
             out 9,al
             out 10,al
             
             
             mov StartTest,0ffh
             mov FlagZad_Vopr,0
             mov al,TimeOld
             mov Time,al
             mov EndTest,0
             mov Rezult,0
             mov Nvopros,1
             mov FlagSignal,0
         
      push bx
        lea  bx ,sart
        mov si,0   
       mov cx,9
       mov al,0
p55:     mov [bx+si],al
       inc si   
       loop p55
       pop bx
       
BTT:                       
             ret 
BUT_TEST  EndP

BUT_ETE Proc Near
        cmp ButCode,16
         jne  BE
           mov StartTest,0
           mov FlagZad_Vopr,0ffh
           mov EndTest,0ffh
BE:
 ret          
BUT_ETE Endp

;кнопки управления режимом программирования
BUT_PROG  Proc near
             cmp EmpBut,0FFh
             je  BPG
             cmp ButErr,0FFh
             je  BPG
             cmp ModeProgr,0FFh
             jne BPG
             
          ;кнопка ВТ
             cmp ButCode,9
             jne BPG1
             mov FlagZad_Vopr,0FFh
             mov EmpBut,0FFh
             mov Nvopros,1
             jmp BPG
BPG1:
           ;кнопка ВС
             cmp ButCode,10
             jne BPG2
             mov FlagZad_Vopr,0
             mov EmpBut,0FFh
             jmp BPG
BPG2:
           ;кнопка BP
             cmp ButCode,13
             jne BPG3
             mov FlagOtvet,0
             mov EmpBut,0FFh
             jmp BPG
BPG3:          
           ;кнопка OT
             cmp ButCode,14
             jne BPG
             mov FlagOtvet,0FFh
             mov EmpBut,0FFh
BPG:                       
             ret 
BUT_PROG  EndP             

;кнопки <,>
BUT_I_D  Proc near
             cmp EmpBut,0FFh
             je  BIDP
             cmp ButErr,0FFh
             je  BIDP
             dec ACt  ; еденичное значение Дреб
             jnz BIDP
             mov ACt,0FFh
             
              cmp ModeProgr,0ffh      ;----------------------------1
              jne BID7                ;---------------------------------------1
           ;кнопка <
             cmp ButCode,11
             jne BID3
             cmp FlagOtvet,0
             jne BID1
             cmp Time,01h ; значение мин времени
             je BIDP
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
             je BIDP 
             dec Nzadacha
BID7:        jmp BID6            
BIDP:        jmp BID
BID2:             
             cmp Nvopros,1
             je BIDp
             dec Nvopros
             mov al,Nvopros ;--------------
             mov KolVopr,al 
                      
             mov ch,0
             mov cl,al
             stc
                       
             jmp BID
BID3:              
           ;кнопка >
             cmp ButCode,12
             jne BIDG
             cmp FlagOtvet,0
             jne BID4
             cmp Time,09h
             je BIDG
             mov al,TimeOld
             add al,1
             daa
             mov Time,al
             mov TimeOld,al
             jmp BID
BID4:
             cmp FlagZad_Vopr,0FFh
             jne BID5
             cmp Nzadacha,9 ; максим число вариантов
             je BIDG
             inc Nzadacha
             jmp BID
BIDG:         jmp BID
BID5:             
             cmp Nvopros,9 ; макс число вопросов
             je  BIDG
             inc Nvopros
             mov al,Nvopros         ;--------------
             mov KolVopr,al         ;--------------
BID6:      
           
           
             cmp ModeKtest,0ffh     ;--------------------1    
             jne BIDP                ;--------------------1
             ;----------------------------------------------1   
             ;кнопка (<)-----------       MAZA  ----------------
             
             cmp ButCode,11
             jne BID8 
                         
             cmp FlagZad_Vopr,0FFh
             jne BIDF
             cmp Nzadacha,1
             je BID 
             dec Nzadacha
             jmp BID
               
 BIDF:                    
             cmp FlagZad_Vopr,0
             jne BID8
  ;--------ВО ...  ------------------------------      
             cmp Nvopros,1
             jbe bid
              mov al,1
             out 11,al
                   mov cx,0FFFFh
BID9:            
            dec cx
            inc cx
            dec cx
            inc cx
            loop BID9
            
             cmp FlagZad_Vopr,0ffh
             je BID8
             mov al,0
             out 11,al 
             
             
             dec Nvopros
 
            jmp BID  
bid8:             
             ; кнопка (>)-----------       MAZA2  --------------
             cmp ButCode,12
             jne BID
             
             cmp FlagZad_Vopr,0FFh
             jne BIDS
             cmp Nzadacha,9 ; максим число вариантов
             je BID
             inc Nzadacha
             jmp BID
BIDS:             
             mov FlagSignal,0 ;-------------ВОТ ЗДЕСЬ-----
            
              mov al,kolvopr
             
             cmp al,Nvopros
             jbe bid
             
             inc Nvopros
              mov FlagSignal,0ffh
BID:                       
             ret 
BUT_I_D  EndP 
                                     
;формирование результата
FORM_REZ     Proc 
             cmp ButErr,0FFh
             je  FR8
             
             cmp EndTest,0FFh
             jne FR8
             
             mov al,10
             mov imageind + 6,al
             
             xor  ax,ax
             mov al,Rezult
             cmp al,0
             je FR7
             mov bx,100
             mul bx
             xor bx,bx
             mov bl,KolVopr
             xor dx,dx
             div bx
             
FR7:         cmp ax,0
             jne FR1
             mov al,0
             mov dx,0
             jmp FR2
FR8:         jmp FR
FR1:
             mov bx,10
             xor dx,dx
             div bx           ;---------младшая часть--------------------------wew
FR2:         mov di,ax
             mov si,dx
             mov al,Image[si]
             out 10,al
             mov ax,di
             
             cmp ax,0
             jne FR3
             mov al,0
             mov dx,0
             jmp FR4
FR3:
             mov bx,10
             xor dx,dx
             div bx           ;-----------------------------------wew
FR4:         mov di,ax
             mov si,dx
             mov al,Image[si]
             out 9,al
             mov ax,di
             
             cmp ax,0
             jne FR5
             mov al,0
             mov dx,0
             jmp FR6
FR5:
             mov bx,10
             xor dx,dx
             div bx           ;----------------старшая часть-------------------wew
FR6:         mov di,ax
             mov si,dx
             mov al,Image[si]
             out 8,al
             mov ax,di
             
FR:
             ret
FORM_REZ     EndP

;процедура формирования времени  {ЗДЕСЬ}
FORM_TIME  Proc near
           cmp Vremia_Vkl,0ffh
            jne FT
            cmp ButErr,0FFh
            je  FT
            
            cmp ModeKtest,0FFh
            jne FT
            cmp StartTest,0FFh
            jne FT
            
            dec sec
            cmp sec,0
            je  FTS
            jmp FT
FTS:            
            mov sec,08ffh   ;----------------------------------------------------------------------время
            mov al,Time
            sub al,1
            das
            mov Time,al
            cmp Time,0
            je  FT1
            jmp FT
FT1:            
            mov StartTest,0
            mov FlagZad_Vopr,0ffh
            mov EndTest,0FFh
            cmp Nzadacha,9
FT:            
            ret
FORM_TIME   EndP
  
;процедура отображения в светодиодах 
INDIC_DIOD  Proc near
       cmp  ButErr,0FFh
       je   ID
       mov  al,0
       cmp  ModeProgr,0FFh  
       jne  ID1
       or   al,1
ID1:       
       cmp  ModeKtest,0FFh
       jne  ID3
       or   al,2
ID3:       
       cmp   FlagZad_Vopr,0FFh
       jne   ID4
       or    al,4
       jmp   ID5
ID4:        
       or    al,8
ID5:       
       cmp   FlagOtvet,0   
       jne   ID6
       or    al,16
       jmp   ID7
ID6:       
       or    al,32
ID7:       
       cmp   StartTest,0FFh 
       jne   ID8
       or    al,64
ID8:       
       out   7,al
ID:   
       ret
INDIC_DIOD  EndP                    

;процедура форм. сигнала УПС
SIGNAL      Proc near
            cmp ButErr,0FFh
            je  s
            cmp FlagSignal,0FFh
            jne S
            cmp StartTest,0ffh
            je S3
             
              mov al,01100110b                ;----------НУ И .....----------------
          
           
            
S3:       
               
         
                
            or al,10000000b
            out 7,al
         
            mov cx,0FFFFh
S1:            
            dec cx
            inc cx
            dec cx
            inc cx
            loop S1
            
            mov FlagSignal,0
            and al,11111110b
            jmp S2
S2:
            out 7,al
S:              
            ret
SIGNAL      EndP

            
;процедура формирования массива отображения для 7-сегментных индекаторов 
FORM_INDIC  Proc near
       cmp ButErr,0FFh
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
       mov al,Nvopros            ;----------------------
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
       mov al,FlagOtvet
       not al
       and al,ModeProgr
       or  al,ModeKtest 
       cmp al,0FFh
       jne FI1
       cmp Vremia_Vkl,0ffh
       je FI5
       mov al,10
       jmp FI6
FI5:   mov al,Time
FI6:   mov ah,al
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
;ответ
       inc di
       cmp ModeProgr,0FFh
       jne FI3
       cmp FlagOtvet,0FFh
       jne FI4
       xor ah,ah
       mov al,Nzadacha
       dec al
       mov dl,9
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
       mov al,Rezult              ;---------------------------------------------
       mov ImageInd[di],al
       jmp FI
FI4:
       mov ImageInd[di],10 
FI:       
       ret
FORM_INDIC  EndP

;процедура формирования массива отображения для 7-сегментных индекаторов при ошибке
FORM_INDIC_ERR Proc near
       cmp ButErr,0
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
           call  BUT_RD
           call  BUT_CL
           call  BUT_CODE 
           call  MODE      
           call  BUTS_1_5
           call  BUT_TEST
           call  BUT_ETE
           call  BUT_PROG
           call  BUT_I_D                                           
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
