RomSize    EQU   4096
Klav_Port = 0
Matrix_Port = 1

Data       SEGMENT AT 100h
           Klav_Image db 3 dup (?)
           Klav_Emp db ?
           Klav_Err db ?
           Next_Dig db ?
           Mode db ?           
           Takt db 2 dup (?)
           Fract db ?           
           Disp_Image db 4 dup (?)
           Error_Value db ?
           Effective_Takt dw ?
           
           Signal_Byte db ?
           
           Tic dw ?
Data       ENDS

Stk        SEGMENT AT 200h
           dw 20 dup (?)
           StkTop Label Word
Stk        ENDS

Code       segment
           assume cs:Code, ds:Data

Func_Prep Proc Near            ;функциональная подготовка
           mov word ptr Takt, 0
           mov Fract, 0           
           mov Signal_Byte, 8
           mov Error_Value, 0
           
           mov CX, 4
           xor SI, SI
      FP1: mov Disp_Image[SI], 11
           inc SI
           loop FP1
           
           ret
Func_Prep Endp

Keys_Input Proc Near    ; ввод кнопки
           mov Mode, 0
           in AL, Klav_Port
           mov DX, Klav_Port
           test AL, 10h
           jz KI
           mov Mode, 0FFh

       KI: ret
Keys_Input Endp

Klav_Input Proc Near    ;ввод  с клавы
           cmp Mode, 0
           jne KI5

           lea DI, Klav_Image
           xor CL, CL
           
      KI2: mov AL, 1
           shl AL, CL           
           out Klav_Port, AL
           in AL, Klav_Port
           and AL, 0Fh
           jz KI1
           
           mov DX, Klav_Port
           call Vibr_Destr           
           mov [DI], AL
           
      KI3: in AL, Klav_Port
           and AL, 0Fh
           jnz KI3
           jmp KI4
           
      KI1: mov [DI], AL
      KI4: inc DI
           inc CL
           cmp CL, length Klav_Image
           jnz KI2
           
      KI5: ret
Klav_Input Endp
      
Vibr_Destr Proc Near     ;гашение дребезга
      VD1: mov AH, AL
           mov BH, 0
      VD2: in AL, DX
           cmp AH, AL
           jne VD1
           inc BH
           cmp BH, 50
           jne VD2
           mov AL, AH
           
           ret
Vibr_Destr Endp

Klav_In_Control Proc Near  ;контроль ввода с клавы
           cmp Mode, 0
           jne KLC4

           lea SI, Klav_Image
           mov CX, 3
           mov DL, 0
     KLC2: mov AL, [SI]
           mov AH, 4
     KLC1: shr AL, 1
           adc DL, 0
           dec AH
           jnz KLC1
           inc SI
           loop KLC2
           
           mov Klav_Err, 0
           mov Klav_Emp, 0
           cmp DL, 0
           jz KLC3
           cmp DL, 1
           jz KLC4
           mov Klav_Err, 0FFh
           jmp KLC4
     KLC3: mov Klav_Emp, 0FFh

     KLC4: ret
Klav_In_Control Endp

Current_Dig_Transformer Proc Near  ; получение очередной  цифры
           cmp Mode, 0
           jne CDT1
           cmp Klav_Err, 0
           jne CDT1
           cmp Klav_Emp, 0
           jne CDT1
           
           xor DX, DX
           lea SI, Klav_Image
           
     CDT3: mov AL, [SI]
           and AL, 0Fh
           cmp AL, 0
           jnz CDT2
           inc DL
           inc SI
           jmp CDT3
           
     CDT2: shr AL, 1
           jc CDT4
           inc DH
           jmp CDT2
           
     CDT4: shl DL, 2
           or DH, DL     
           mov Next_Dig, DH
           
           cmp DH, 10
           jb CDT1
           mov Klav_Emp, 0FFh
           
           cmp DH, 10
           jne CDT1
           not Fract
                      
     CDT1: ret
Current_Dig_Transformer Endp

Inf_Former Proc Near    ;  формирование такта
           cmp Mode, 0
           jne InF1
           mov Tic, 0
           cmp Klav_Err, 0
           jne InF1
           cmp Klav_Emp, 0
           jne InF1

           mov AL, Takt[0]
           mov Takt[1], AL
           mov AL, Next_Dig
           mov Takt[0], AL
           
     InF1: ret
Inf_Former Endp

Disp_Former Proc Near    ; формирование массива отображения
           cmp Mode, 0
           jne DF1
           cmp Klav_Err, 0
           jne DF1         
          
           lea SI, Disp_Image
           
           mov AL, Takt[0]
           mov [SI], AL
           mov AL, Takt[1]
           mov [SI+1], AL  
           
           mov AL, 10
           mov AH, 1
           cmp Fract, 0
           jne DF2
           mov AL, 11
           mov AH, 11
      DF2: mov [SI+2], AL
           mov [SI+3], AH           
           
      DF1: ret
Disp_Former Endp

Outputing Proc Near       ;   вывод на индикаторы   
           mov CX, 4
           xor SI, SI
           mov DL, 1    

      OP2: mov AL, 0
           out Matrix_Port+1, AL
           mov AL, DL
           out Matrix_Port, AL
           
           xor AX,AX     
           mov AL, Disp_Image[SI]
           mov BL, 5           
           mul BL           
           mov DI, AX          

           mov DH, 1           
      OP1: mov AL, 0
           out Matrix_Port+1, AL       

           mov AL, Digits[DI]
           out Matrix_Port+2, AL

           mov AL, DH
           out Matrix_Port+1, AL

           inc DI
           shl DH, 1
           cmp DH, 20h
           jnz OP1
           
           shl DL, 1
           inc SI
           loop OP2
           
           mov AL, 0
           out Matrix_Port, AL
           
           ret
Outputing Endp

Defining_Takt Proc Near       ;   получение эффективного такта  
           cmp Mode, 0           
           je DT1
           cmp Klav_Err, 0
           jne DT1
                      
           mov Error_Value, 0      
                   
           cmp word ptr Takt, 302h
           ja DT2
           cmp word ptr Takt, 1
           jb DT2           
                
           xor AX, AX
           mov AL, Takt[1]
           mul Ten
           add AL, Takt[0]
           mov DL, AL
           
           sub AX, 1         ;проверяем число на принадлежность множеству
           mov BX, AX
           shr BX, 3
           and AL, 7
           xchg CL, AL       ;в CL номер бита, в BX номер байта
           
           mov AL, Set_of_Values[BX]
           shr AL, CL
           test AL, 1
           jz DT2
           
           xor SI, SI
           mov AL, DL
      DT3: inc SI
           shr AL, 1
           jnc DT3
           cmp Fract, 0
           jne DT4
           add SI, 4
           jmp DT5
      DT4: mov BX, 6
           sub BX, SI
           xchg SI, BX
      DT5: shl SI, 1
           mov AX, Values[SI]
           mov Effective_Takt, AX
           
           jmp DT1
      
      DT2: mov Error_Value, 0FFh
      DT1: ret
           Ten db 10
Defining_Takt Endp

Errors_Output Proc Near  ;    ошибка ввода
           cmp Mode, 0
           je EO1
           cmp Error_Value, 0
           je EO1
           mov AL, 14
           mov Disp_Image[0], AL
           mov AL, 13
           mov Disp_Image[1], AL
           mov AL, 13
           mov Disp_Image[2], AL
           mov AL, 12
           mov Disp_Image[3], AL
           
           call Outputing
           
      EO1: ret
Errors_Output Endp

Takting Proc Near    ;  вывод на лампочку
           cmp Mode, 0
           je TT1
           cmp Error_Value, 0
           jne TT1
           
           
           mov AL, Signal_Byte
           out Klav_Port, AL
           inc Tic
           mov Signal_Byte, 0
           cmp Tic, 7
           ja TT2
           mov Signal_Byte, 8
      TT2: mov AX, Tic
           cmp AX, Effective_Takt
           jne TT1
           mov Tic, 0
           ;xor Signal_Byte, 8          
           
      TT1: ret
Takting Endp

Digits     db    3Eh, 41h, 41h, 41h, 3Eh
           db    44h, 42h, 7Fh, 40h, 40h
           db    66h, 51h, 51h, 51h, 4Eh
           db    22h, 49h, 49h, 49h, 36h
           db    0Fh, 08h, 08h, 08h, 7Fh
           db    4Fh, 49h, 49h, 49h, 31h
           db    3Eh, 49h, 49h, 49h, 32h
           db    01h, 71h, 09h, 05h, 03h
           db    36h, 49h, 49h, 49h, 36h
           db    26h, 49h, 49h, 49h, 3Eh
           db    60h, 10h, 08h, 04h, 03h
           db    00h, 00h, 00h, 00h, 00h
           db    7Fh, 49h, 49h, 49h, 49h
           db    78h, 08h, 08h, 08h, 10h
           db    00h, 00h, 5Fh, 00h, 00h

Set_of_Values db 8Bh, 80h, 00h, 80h

Values dw  8,   16,   32,   64,   128,   256,   512,  1024, 2048, 4096, 8192

Start:     mov AX, Data
           mov DS, AX
           mov AX, Stk
           mov SS, AX
           lea SP, StkTop

           call Func_Prep           
    Cycle: call Keys_Input
           call Klav_Input
           call Klav_In_Control
           call Current_Dig_Transformer
           call Inf_Former           
           call Disp_Former
           call Outputing
           call Defining_Takt
           call Errors_Output
           call Takting
           jmp Cycle

           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end
