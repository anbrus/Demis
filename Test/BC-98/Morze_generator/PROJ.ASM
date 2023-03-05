RomSize EQU 4096
Length_of_Message = 32
Num_of_Mes = 4
Kbd_Port = 0
Mode_Port = 1
Indicator_Port = 1
Num_of_Message_Port = 4
Num_of_Symbols_Port = 5

Point = 60
Tire = 3*Point
Pause_between_Morze_Symbols = Point/2
Pause_between_Letters = 3*Point
Pause_between_Words = 6*Point

Data Segment at 40h
           Mode db ?                 ;режим передачи
           RusLat db ?               ;режим Рус/Лат
           LeftScroll db ?           ;скроллинг сообщения влево
           RightScroll db ?          ;скроллинг сообщения вправо
           Number_of_Message db ?    ;номер сообщения
           Inc_Number_of_Message db ?;
           Dec_Number_of_Message db ?;
           Erase_of_Message db ?     ;стирание сообщения
           Delete db ?               ;удаление символа сообщения
           Transfer db ?             ;пуск сообщения
           Kbd_Image db 8 dup (?)    ;образ клавы
           Old_Kbd_Image db 8 dup (?)
           Key_Code db ?             ;код нажатой клавиши
           Next_Symbol db ?          ;код введенного символа
           Kbd_Empty db ?            ;флаг пустой клавы
           Kbd_Error db ?            ;флаг ошибки клавы

           Message db Num_of_Mes dup (Length_of_Message dup (?))
           Quantity_of_Symbols dw Num_of_Mes dup (?)
           Symbol_Pointer dw Num_of_Mes dup (?)

           Disp_Data db 4 dup (?)    ;массив отображения
           
           Buffer_of_RusLat db ?
           Buffer_of_Morze_Indicator db ?
Data Ends

Stk Segment at 50h
           dw 40 dup (?)
           StkTop Label Word
Stk Ends

Code Segment
           Assume CS:Code, DS:Data

Init_of_Critical_Data Proc Near
           mov Kbd_Error, 0
           mov Number_of_Message, 0
           mov RusLat, 0
           mov Buffer_of_Morze_Indicator, 0
                      
           mov CX, Num_of_Mes
           xor SI, SI          
     ICD1: mov Quantity_of_Symbols[SI], 0
           mov Symbol_Pointer[SI], 0          
           add SI, 2          
           loop ICD1
           
           mov CX, 4
           xor DI, DI
     ICD2: mov Disp_Data[DI], 75
           inc DI
           loop ICD2
           
           mov CX, length Kbd_Image
           xor SI, SI
     ICD3: mov Old_Kbd_Image[SI], 0
           inc SI
           loop ICD3
      
           ret
Init_of_Critical_Data Endp
           
Mode_Input Proc Near
           mov Mode, 0
                              
           in AL, Kbd_Port
           mov DX, Kbd_Port
           call Vibration_Destroyer
           test AL, 80h              
           jz MI1           
           mov Mode, 0FFh            ;режим:=отложенный
                      
      MI1: ret
Mode_Input Endp

Mode_Info_Output Proc Near
           xor AX, AX
           cmp Mode, 0
           jz MIO1
           mov AL, Number_of_Message
           add AL, 2
     MIO1: mov SI, AX
           mov AL, Image[SI]
           out Num_of_Message_Port, AL
           
           xor AX, AX
           xor DX, DX
           cmp Mode, 0
           jz MIO2
           mov AL, Number_of_Message
           shl AX, 1
           mov SI, AX
           mov AX, Quantity_of_Symbols[SI]
           aam
           inc AL
           inc AH
           mov DL, AH
           xor AH, AH
     MIO2: mov SI, AX
           mov AL, Image[SI]
           out Num_of_Symbols_Port, AL
           mov SI, DX
           mov AL, Image[SI]
           out Num_of_Symbols_Port + 1, AL
                      
           mov AL, 0
           cmp RusLat, 0
           jz MIO3
           mov AL, 80h
     MIO3: mov Buffer_of_RusLat, AL
           out Indicator_Port + 1, AL
     
           ret
           Image db 00h, 3Fh, 0Ch, 76h, 5Eh, 4Dh, 5Bh, 7Bh, 0Eh, 7Fh, 5Fh
Mode_Info_Output Endp

Fixed_Error_Message_Output Proc Near
           cmp Kbd_Error, 0
           je FEMO

           mov Disp_Data[3], 51 ;код "E"
           mov Disp_Data[2], 62 ;код "R"           
           mov Disp_Data[1], 62 ;код "R"
           mov Disp_Data[0], 75
           
           lea DI, Disp_Data
           call Display_Output
           
     FEMO: ret
Fixed_Error_Message_Output Endp
           
Kbd_Input Proc Near
           lea DI, Kbd_Image
           xor CL, CL
      KI1: mov AL, 1
           shl AL, CL           
           out Kbd_Port, AL
           in AL, Kbd_Port           
           mov DX, Kbd_Port
           call Vibration_Destroyer
           and AL, 7Fh
           mov [DI], AL     
           inc DI
           inc CL
           cmp CL, length Kbd_Image
           jnz KI1
            
           ret
Kbd_Input Endp

Vibration_Destroyer Proc Near ;параметры DX - порт, AL - данные
      VD1: mov AH, AL            
           mov BH, 0
      VD2: in AL, DX
           cmp AH, AL
           jnz VD1
           inc BH
           cmp BH, 50
           jnz VD2
           mov AL, AH

           ret
Vibration_Destroyer Endp

Kbd_Control Proc Near
           mov CH, length Kbd_Image
           xor BX, BX        ;BH - число клавиш с передним фронтом
                             ;BL - число нажатых клавиш
           xor SI, SI
           
      KC2: mov CL, 7
           mov AH, Old_Kbd_Image[SI]
           mov AL, Kbd_Image[SI]
           mov DL, AL        ;в DL текущая строка образа клавы
           mov Old_Kbd_Image[SI], AL
           xor AH, 7Fh
           and AL, AH        ;выделяем передние фронты
           
      KC1: shr AL, 1  
           adc BH, 0  ;подсчитываем ПФ
           shr DL, 1
           adc BL, 0  ;подсчитываем число нажатых клавиш
           dec CL           
           jnz KC1
           
           inc SI
           dec CH           
           jnz KC2
           
           mov Kbd_Empty, 0
           mov Kbd_Error, 0
           cmp BH, 0
           jne KC3
           mov Kbd_Empty, 0FFh
      KC3: cmp BL, 2
           jb KC4
           mov Kbd_Error, 0FFh
                      
      KC4: ret
Kbd_Control Endp

Define_of_Key_Code Proc Near
           cmp Kbd_Empty, 0
           jnz DK4
           cmp Kbd_Error, 0
           jnz DK4

           lea DI, Kbd_Image
           xor BX, BX
      DK2: mov AL, [DI]
           and AL, 7Fh           
           cmp AL, 0
           jnz DK1
           inc BH
           inc DI
           jmp DK2
           
      DK1: shr AL, 1
           jc DK3
           inc BL
           jmp DK1
           
      DK3: mov AL, BH
           shl BH, 3           
           sub BH, AL
           add BH, BL
           
           mov Key_Code, BH
           
      DK4: ret
Define_of_Key_Code Endp

Define_of_Mode_Keys_State Proc Near
           mov LeftScroll, 0
           mov RightScroll, 0           
           mov Erase_of_Message, 0
           mov Delete, 0
           mov Transfer, 0
           mov Inc_Number_of_Message, 0
           mov Dec_Number_of_Message, 0
           
           cmp Kbd_Empty, 0
           jnz DMK1
           cmp Kbd_Error, 0
           jnz DMK1
           cmp Key_Code, 46
           jb DMK1
           
           mov Kbd_Empty, 0FFh                      
           mov AL, Key_Code
                                 
           cmp AL, 46
           jnz DMK2
           not RusLat
           
     DMK2: cmp AL, 47
           jnz DMK3
           mov RightScroll, 0FFh
           
     DMK3: cmp AL, 48
           jnz DMK4
           mov LeftScroll, 0FFh
           
     DMK4: cmp AL, 49
           jnz DMK5
           mov Inc_Number_of_Message, 0FFh
           
     DMK5: cmp AL, 50
           jnz DMK6
           mov Dec_Number_of_Message, 0FFh
           
     DMK6: cmp AL, 51
           jnz DMK7
           mov Delete, 0FFh
 
     DMK7: cmp AL, 52
           jnz DMK8
           mov Erase_of_Message, 0FFh
           
     DMK8: cmp AL, 53
           jnz DMK1
           mov Transfer, 0FFh
                      
     DMK1: ret
Define_of_Mode_Keys_State Endp

Define_of_Next_Symbol Proc Near
           cmp Kbd_Empty, 0
           jnz DN1
           cmp Kbd_Error, 0
           jnz DN1
           
           mov AL, Key_Code
           mov Next_Symbol, AL
           cmp RusLat, 0FFh
           jne DN1
           
           cmp Key_Code, 19
           je DN2           
           cmp Key_Code, 38
           je DN2
           cmp Key_Code, 40
           je DN2
           cmp Key_Code, 43
           jne DN3
      DN2: mov Kbd_Empty, 0FFh
           jmp DN1
           
      DN3: cmp Key_Code, 12
           jna DN1
           add Next_Symbol, 33
           cmp Key_Code, 19
           jna DN1
           dec Next_Symbol
           cmp Key_Code, 38
           jna DN1
           dec Next_Symbol
           cmp Key_Code, 40
           jna DN1
           dec Next_Symbol
           cmp Key_Code, 43
           jna DN1
           dec Next_Symbol

      DN1: ret
Define_of_Next_Symbol Endp

Form_of_Info Proc Near
           cmp Mode, 0
           jz FI1
           cmp Kbd_Error, 0
           jnz FI1           
           cmp Kbd_Empty, 0
           jnz FI2
           ;;;;;;;;;;;;;;;;;;;;;;;;;;;; редактирование сообщения
           call Kbd_Processing
           jmp FI1
      FI2: call Keys_Processing
           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      FI1: ret
Form_of_Info Endp

Kbd_Processing Proc Near     ;редактирование сообщений клавишами клавиатуры
           xor AX, AX
           mov AL, Number_of_Message
           shl AX, 1
           mov SI, AX
           
           mov AL, Length_of_Message
           mul Number_of_Message
           mov BX, AX        ;базовый адрес сообщения
           
           mov CX, Quantity_of_Symbols[SI]
           sub CX, Symbol_Pointer[SI]
           mov DI, Quantity_of_Symbols[SI]
           xor BP, BP        ; BP=0, если Quantity<>32
           cmp Quantity_of_Symbols[SI], word ptr Length_of_Message
           jnz KbdP1
           inc BP            ; BP=1, иначе
           
    KbdP1: jcxz KbdP2
           cmp BP, 0
           jz KbdP3
           dec DI
           cmp CX, 1
           jz KbdP6
           dec CX
    KbdP3: mov AL, Message[BX+DI-1]
           mov Message[BX+DI], AL
           dec DI
           loop KbdP3
           
    KbdP6: inc Symbol_Pointer[SI]
           cmp BP, 0
           jnz KbdP4           
           inc Quantity_of_Symbols[SI]          
    KbdP4: mov AL, Next_Symbol
           mov Message[BX+DI], AL
           jmp KbdP5

    KbdP2: cmp BP, 0
           jz KbdP6
           dec DI
           jmp KbdP4
   
    KbdP5: ret
Kbd_Processing Endp

Keys_Processing Proc Near    ;редактирование сообщений управляющими клавишами
           xor AX, AX
           mov AL, Number_of_Message
           shl AX, 1
           mov SI, AX
      
           cmp LeftScroll, 0
           jz KP2
           mov AX, Quantity_of_Symbols[SI]
           cmp AX, Symbol_Pointer[SI]
           je KP9
           inc Symbol_Pointer[SI]
      KP9: jmp KP1
           
      KP2: cmp RightScroll, 0
           jz KP3
           cmp Symbol_Pointer[SI], 0
           jna KP10
           dec Symbol_Pointer[SI]
     KP10: jmp KP1
           
      KP3: cmp Erase_of_Message, 0
           jz KP4
           mov Symbol_Pointer[SI], 0
           mov Quantity_of_Symbols[SI], 0
           jmp KP1
           
      KP4: cmp Delete, 0
           jz KP7
           cmp Quantity_of_Symbols[SI], 0
           jz KP1
           cmp Symbol_Pointer[SI], 0
           jz KP1
           mov AL, Length_of_Message
           mul Number_of_Message
           mov BX, AX        ;базовый адрес сообщения
           
           mov CX, Quantity_of_Symbols[SI]
           sub CX, Symbol_Pointer[SI]
           jcxz KP5
           mov DI, Symbol_Pointer[SI]
      KP6: mov AL, Message[BX+DI]
           mov Message[BX+DI-1], AL
           inc DI
           loop KP6           
      KP5: dec Symbol_Pointer[SI]
           dec Quantity_of_Symbols[SI]
           jmp KP1
           
      KP7: cmp Inc_Number_of_Message, 0
           jz KP8
           inc Number_of_Message
           cmp Number_of_Message, Num_of_Mes-1
           jna KP1
           mov Number_of_Message, 0
           jmp KP1
           
      KP8: cmp Dec_Number_of_Message, 0
           jz KP1
           dec Number_of_Message
           cmp Number_of_Message, 0
           jnl KP1
           mov Number_of_Message, Num_of_Mes-1                
      
      KP1: ret
Keys_Processing Endp

Form_of_Disp Proc Near       ;Формирование массивов отображения
           cmp Kbd_Error, 0
           jnz FD1
           
           cmp Mode, 0
           jnz FD3
           
           mov CX, 4
           xor SI, SI
      FD7: mov Disp_Data[SI], 75
           inc SI
           loop FD7           
           
           cmp Kbd_Empty, 0
           jnz FD1

           mov SI, 1
           mov CX, 3
      FD2: mov Disp_Data[SI], 75 ;если нет - ничего
           inc SI
           loop FD2
           mov AL, Next_Symbol
           mov Disp_Data[0], AL
           jmp FD1
           
           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
      FD3: mov AL, Length_of_Message    ;базовый адрес сообщения
           mul Number_of_Message
           mov BX, AX
           
           xor AX, AX
           mov AL, Number_of_Message
           shl AX, 1
           mov SI, AX
           mov SI, Symbol_Pointer[SI]
           dec SI
                      
           mov CX, 4
           xor DI, DI           
      FD4: mov AL, 75 ; ничего (пустые индикаторы)
           cmp SI, 0
           jl FD6
           mov AL, Message[BX+SI]
      FD6: mov Disp_Data[DI], AL
           dec SI
           inc DI
           loop FD4
           
           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
           
      FD1: ret
Form_of_Disp Endp

Output_of_Text Proc Near         ;вывод текстовой информации
           cmp Kbd_Error, 0
           jnz OT1                 
           
           lea DI, Disp_Data
           call Display_Output
      
      OT1: ret
Output_of_Text Endp

Display_Output Proc Near     ;вывод на индикаторы
           push CX           ;DI - адрес массива отображения
                             ;номер индикатора                                    
           mov CH, 1
                                                      
      DO2: mov AL, 0
           or AL, Buffer_of_RusLat
           out Indicator_Port+1, AL  ;Turn off cols           
           mov CL, 1        ;Col Counter
           mov AL, CH
           out Indicator_Port+2, AL  ;Turn on current matrix
           
           xor AX, AX       ;
           mov AL, [DI]     ;
           mov SI, AX       ;получаем
           shl SI, 2        ;изображение
           add SI, AX       ;символа
                     
      DO1: mov AL, 0
           or AL, Buffer_of_RusLat      
           out Indicator_Port+1, AL  ;Turn off cols
           mov AL, OutPut_Mask[SI]
           or AL, Buffer_of_Morze_Indicator
           out Indicator_Port, AL    ;Set rows
           mov AL, CL
           or AL, Buffer_of_RusLat
           out Indicator_Port+1, AL  ;Turn on current col
           
           inc SI
           shl CL, 1
           cmp CL, 20h
           jnz DO1
           
           inc DI
           shl CH, 1
           cmp CH, 10h
           jnz DO2

           pop CX
           ret
Display_Output Endp

Output_of_Morze_Code Proc Near
           cmp Kbd_Error, 0
           jnz MCO1

           cmp Mode, 0
           jne MCO2
           cmp Kbd_Empty, 0           
           jnz MCO1
           
           lea BP, Next_Symbol
           mov CX, 1
           call Morze_Indicator_Output
                
     MCO2: cmp Transfer, 0
           je MCO1

           xor AX, AX
           mov AL, Number_of_Message
           shl AX, 1
           mov SI, AX
           mov CX, Quantity_of_Symbols[SI]
           jcxz MCO1
           
           mov AL, Length_of_Message
           mul Number_of_Message
           lea BP, Message
           add BP, AX         ;адрес сообщения
           call Morze_Indicator_Output
          
     MCO1: ret
Output_of_Morze_Code Endp

Morze_Indicator_Output Proc Near      ;CX - число символов
     NMS4: xor AX, AX                 ;DS:BP - адрес
           mov AL, DS:[BP]           
           shl AL, 1
           mov SI, AX
           mov BL, Morze_Table[SI]    ;точки и тире
           mov BH, Morze_Table[SI+1]  ;число точек и тире
           
           cmp BH, 9
           jne NMS3
           mov DX, Pause_between_Words
           jmp NMS6

     NMS3: mov DX, Point
           mov Buffer_of_Morze_Indicator, 80h
           shl BL, 1
           jnc NMS1
           mov DX, Tire
           
     NMS1: lea DI, Disp_Data
           call Display_Output
           
           dec DX           
           jnz NMS1
           
           cmp BH, 1
           je NMS7  
           
           mov DX, Pause_between_Morze_Symbols
           mov Buffer_of_Morze_Indicator, 0
           
     NMS2: lea DI, Disp_Data
           call Display_Output
           
           dec DX           
           jnz NMS2
                               
           dec BH
           jmp NMS3

     NMS7: cmp CX, 1
           je NMS8
     
           mov DX, Pause_between_Letters
     NMS6: mov Buffer_of_Morze_Indicator, 0
           
     NMS5: lea DI, Disp_Data
           call Display_Output
           
           dec DX
           cmp DX, 0
           jnz NMS5
           
           inc BP
           loop NMS4
           
     NMS8: mov Buffer_of_Morze_Indicator, 0
           lea DI, Disp_Data
           call Display_Output
           ret
Morze_Indicator_Output Endp

           OutPut_Mask db 3Eh, 51h, 49h, 45h, 3Eh ;0
                       db 44h, 42h, 7Fh, 40h, 40h ;1
                       db 42h, 61h, 51h, 49h, 46h ;2
                       db 22h, 41h, 49h, 49h, 36h ;3
                       db 18h, 14h, 12h, 7Fh, 10h ;4
                       db 27h, 49h, 49h, 49h, 31h ;5
                       db 3Eh, 49h, 49h, 49h, 32h ;6
                       db 01h, 01h, 79h, 05h, 03h ;7
                       db 36h, 49h, 49h, 49h, 36h ;8
                       db 26h, 49h, 49h, 49h, 3Eh ;9

                       db 00h, 00h, 58h, 38h, 00h ;,
                       db 00h, 00h, 60h, 60h, 00h ;.
                       db 40h, 40h, 40h, 40h, 40h ;пробел

                       db 7Ch, 12h, 11h, 11h, 7Fh ;а
                       db 7Fh, 49h, 49h, 49h, 31h ;б
                       db 7Fh, 49h, 49h, 49h, 36h ;в
                       db 7Fh, 01h, 01h, 01h, 01h ;г
                       db 60h, 3Ch, 22h, 3Fh, 60h ;д
                       db 7Fh, 49h, 49h, 41h, 41h ;е
                       db 7Ch, 55h, 54h, 45h, 44h ;ё
                       db 63h, 14h, 7Fh, 14h, 63h ;ж
                       db 22h, 41h, 49h, 55h, 22h ;з
                       db 7Fh, 20h, 10h, 08h, 7Fh ;и
                       db 7Ch, 21h, 11h, 09h, 7Ch ;й
                       db 7Fh, 08h, 14h, 22h, 41h ;к
                       db 7Ch, 02h, 01h, 01h, 7Fh ;л
                       db 7Fh, 02h, 04h, 02h, 7Fh ;м
                       db 7Fh, 08h, 08h, 08h, 7Fh ;н
                       db 3Eh, 41h, 41h, 41h, 3Eh ;о
                       db 7Fh, 01h, 01h, 01h, 7Fh ;п
                       db 7Fh, 09h, 09h, 09h, 06h ;р
                       db 3Eh, 41h, 41h, 41h, 22h ;с
                       db 01h, 01h, 7Fh, 01h, 01h ;т
                       db 27h, 48h, 48h, 48h, 3Fh ;у
                       db 0Eh, 11h, 7Fh, 11h, 0Eh ;ф
                       db 63h, 14h, 08h, 14h, 63h ;х
                       db 3Fh, 20h, 20h, 3Fh, 60h ;ц
                       db 07h, 08h, 08h, 08h, 7Fh ;ч
                       db 7Fh, 40h, 7Fh, 40h, 7Fh ;ш
                       db 3Fh, 20h, 3Fh, 20h, 7Fh ;щ
                       db 01h, 7Fh, 48h, 48h, 30h ;ъ
                       db 7Fh, 48h, 48h, 30h, 07h ;ы
                       db 7Fh, 48h, 48h, 48h, 30h ;ь
                       db 22h, 41h, 49h, 49h, 3Eh ;э
                       db 7Fh, 08h, 3Eh, 41h, 3Eh ;ю
                       db 46h, 29h, 19h, 09h, 7Fh ;я

                       db 7Ch, 12h, 11h, 11h, 7Fh ;a
                       db 7Fh, 49h, 49h, 49h, 36h ;b
                       db 3Fh, 40h, 38h, 40h, 3Fh ;w
                       db 3Eh, 41h, 51h, 31h, 72h ;g
                       db 7Fh, 41h, 41h, 22h, 1Ch ;d
                       db 7Fh, 49h, 49h, 41h, 41h ;e
                       db 0Fh, 30h, 40h, 30h, 0Fh ;v
                       db 61h, 51h, 49h, 45h, 43h ;z
                       db 41h, 41h, 7Fh, 41h, 41h ;i
                       db 21h, 41h, 41h, 3Fh, 01h ;j
                       db 7Fh, 08h, 14h, 22h, 41h ;k
                       db 7Fh, 40h, 40h, 40h, 40h ;l
                       db 7Fh, 02h, 04h, 02h, 7Fh ;m
                       db 7Fh, 04h, 08h, 10h, 7Fh ;n
                       db 3Eh, 41h, 41h, 41h, 3Eh ;o
                       db 7Fh, 09h, 09h, 09h, 06h ;p
                       db 7Fh, 09h, 19h, 29h, 46h ;r
                       db 26h, 49h, 49h, 49h, 32h ;s
                       db 01h, 01h, 7Fh, 01h, 01h ;t
                       db 3Fh, 40h, 40h, 40h, 3Fh ;u
                       db 7Fh, 09h, 09h, 09h, 01h ;f
                       db 7Fh, 08h, 08h, 08h, 7Fh ;h
                       db 3Eh, 41h, 41h, 41h, 22h ;c
                       db 38h, 45h, 44h, 45h, 38h ;o..
                       db 0Eh, 11h, 79h, 51h, 4Eh ;q
                       db 03h, 0Ch, 70h, 0Ch, 03h ;y
                       db 63h, 14h, 08h, 14h, 63h ;x
                       db 3Ch, 41h, 40h, 41h, 3Ch ;u..
                       db 70h, 28h, 25h, 24h, 7Dh ;a..

                       db 00h, 00h, 00h, 00h, 00h ;ничего

           Morze_Table db 0F8h, 5,  078h, 5,  038h, 5
                          ;  0         1         2
                       db 018h, 5,  008h, 5,  000h, 5
                          ;  3         4         5
                       db 080h, 5,  0C0h, 5,  0E0h, 5
                          ;  6         7         8
                       db 0F0h, 5,  054h, 6,  000h, 6
                          ;  9         ,         .
                       db 000h, 9,  040h, 2,  080h, 4
                          ;  _         A         Б
                       db 060h, 3,  0C0h, 3,  080h, 3
                          ;  В         Г         Д
                       db 000h, 1,  000h, 1,  010h, 4
                          ;  Е         Ё         Ж
                       db 0C0h, 4,  000h, 2,  000h, 2
                          ;  З         И         Й
                       db 0A0h, 3,  040h, 4,  0C0h, 2
                          ;  K         Л         M
                       db 080h, 2,  0E0h, 3,  060h, 4
                          ;  Н         O         П
                       db 040h, 3,  000h, 3,  080h, 1   
                          ;  Р         С         Т
                       db 020h, 3,  020h, 4,  000h, 4
                          ;  У         Ф         X
                       db 0A0h, 4,  0E0h, 4,  0F0h, 4
                          ;  Ц         Ч         Ш
                       db 0D0h, 4,  090h, 4,  0B0h, 4
                          ;  Щ         Ъ         Ы
                       db 090h, 4,  020h, 5,  030h, 4
                          ;  Ь         Э         Ю
                       db 050h, 4
                          ;  Я
                          
                       db 040h, 2,  080h, 4,  060h, 3   
                          ;  A         В         W
                       db 0C0h, 3,  080h, 3,  000h, 1
                          ;  G         D         Е
                       db 010h, 4,  0C0h, 4,  000h, 2
                          ;  V         Z         I
                       db 000h, 2,  0A0h, 3,  040h, 4
                          ;  J         K        L
                       db 0C0h, 2,  080h, 2,  0E0h, 3
                          ;  M         N        O
                       db 060h, 4,  040h, 3,  000h, 3
                          ;  Р         R        S
                       db 080h, 1,  020h, 3,  020h, 4
                          ;  Т         U        F
                       db 000h, 4,  0A0h, 4,  0E0h, 4
                          ;  H         С        О*
                       db 0D0h, 4,  0B0h, 4,  090h, 4
                          ;  Q         Y         Х
                       db 030h, 4, 050h, 4
                          ;  U*        A*

Start:
           mov AX, Data
           mov DS, AX
           mov AX, Stk
           mov SS, AX
           lea SP, StkTop

           call Init_of_Critical_Data

     BORZ: call Fixed_Error_Message_Output
           call Mode_Input
           call Mode_Info_Output
           call Kbd_Input
           call Kbd_Control
           call Define_of_Key_Code
           call Define_of_Mode_Keys_State
           call Define_of_Next_Symbol
           call Form_of_Info
           call Form_of_Disp
           call Output_of_Text
           call Output_of_Morze_Code

           jmp BORZ

           org RomSize-16
           Assume CS:Nothing
           jmp Far Ptr Start
Code Ends
End