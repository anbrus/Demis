RomSize EQU 4096
Kbd_Port = 0
ADC_Port = 1
Price_Port = 0Bh
Mass_Port = 7
Value_Port = 1

Data Segment at 40h
           Kbd_Image db 3 dup (?)
           Kbd_Err db ?
           Kbd_Emp db ?
           Next_Digit db ?
           Error db 5 dup (?)
           Price_in_ASCII_Format db 5 dup (?)
           
           Mass_in_Binary_Format dw ?
           Zero_Mass_in_Binary_Format dw ?
           Effective_Mass_in_Binary_Format db 2 dup (?)
           
           Mass_in_ASCII_Format db 5 dup (?)
           Number_of_Digits_in_Mass db ?
           Value_in_ASCII_Format db 9 dup (?)
           
           Money_Heap db 15 dup (?)
           Equel db ?
           Err_Mass db ?
           Jump_to_Zero db ?
           Show_Me_the_Money db ?
           Add_to_Money_Heap db ?
           Clear_Price_&_Value db ?
           
           Old_Buttons db ?
Data Ends

Stk Segment at 50h
           dw 20 dup (?)
           StkTop Label Word
Stk Ends

Code Segment
           assume CS:Code, DS:Data, ES:Data
;===========================================================================           
Func_Prepare Proc Near
           mov CX, 5
           xor SI, SI
      FP1: mov Price_in_ASCII_Format[SI], 0
           inc SI
           loop FP1
           
           mov CX, 6
           xor SI, SI
      FP2: mov Mass_in_ASCII_Format[SI], 0
           inc SI
           loop FP2
           
           mov CX, 9
           xor SI, SI
      FP3: mov Value_in_ASCII_Format[SI], 0
           inc SI
           loop FP3
           
           mov word ptr Zero_Mass_in_Binary_Format, 0
           
           mov CX, 15
           xor SI, SI
      FP4: mov Money_Heap[SI], 0
           inc SI
           loop FP4

           mov Old_Buttons, 0
                      
           ret
Func_Prepare Endp           
;=============================================================================
Finded_Errors Proc Near
           cmp Err_Mass, 0
           jz FE1
           cmp Show_me_the_Money,0
           jnz FE1
           
           mov AL, 60h
           out Mass_Port, AL
           out Mass_Port + 1, AL
           mov AL, 73h
           out Mass_Port + 2, AL
           mov AL, 00h
           out Mass_Port + 3, AL
                      
      FE1:    
           ret
Finded_Errors Endp
;==========================================================================           
Mode_Input Proc Near
           mov Show_Me_the_Money, 0
           mov Add_to_Money_Heap, 0
           mov Clear_Price_&_Value, 0

           in AL, Kbd_Port
           mov DX, Kbd_Port
           call Vibr_Destr
                      
           test AL, 20h                          
           jz MI1
           mov Show_Me_the_Money, 0FFh
           
      MI1: mov AH, Old_Buttons
           mov Old_Buttons, AL
           not AH
           and AL, AH
                               
           test AL, 10h
           jz MI2
           mov Add_to_Money_Heap, 0FFh

      MI2: test AL, 40h
           jz MI3
           mov Clear_Price_&_Value, 0FFh
      
      MI3: ret
Mode_Input Endp           
;===========================================================================           
Kbd_Input Proc Near
           lea DI, Kbd_Image
           xor CL, CL
           
      KI2: mov AL, 1
           shl AL, CL
           out Kbd_Port, AL
           in AL, Kbd_Port
           test AL, 0Fh
           jz KI1
           
           mov DX, Kbd_Port
           call Vibr_Destr
           mov [DI], AL
      KI3: in AL, Kbd_Port
           and AL, 0Fh
           jnz KI3           
           jmp KI4

      KI1: mov [DI], AL
      KI4: inc DI
           inc CL
           cmp CL, length Kbd_Image
           jnz KI2
           
           ret
Kbd_Input Endp
;==========================================================================
Kbd_Control Proc Near
           lea DI, Kbd_Image
           mov CH, length Kbd_Image
           xor DL, DL
           
      KC2: mov AL, [DI]
           mov CL, 4
      KC1: shr AL, 1
           adc DL, 0
           
           dec CL
           cmp CL, 0
           jnz KC1
           
           inc DI
           dec CH
           cmp CH, 0
           jnz KC2
           
           mov Kbd_Emp, 0
           mov Kbd_Err, 0
           cmp DL, 0
           jz KC3
           cmp DL, 1
           jz KC4
           mov Kbd_Err, 0FFh
           jmp KC4
      KC3: mov Kbd_Emp, 0FFh      
           
      KC4: ret
Kbd_Control Endp
;============================================================================
Vibr_Destr Proc Near
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
;==========================================================================
Get_Next_Digit Proc Near
           mov Equel, 0
           mov Jump_to_Zero, 0

           cmp Kbd_Err, 0
           jne GND1
           cmp Kbd_Emp, 0
           jne GND1
           
           lea DI, Kbd_Image
           xor DX, DX           
           
     GND3: mov AL, [DI]
           and AL, 0Fh           
           jnz GND2
           
           inc DI
           inc DH
           jmp GND3
           
     GND2: shr AL, 1
           jc GND4
           inc DL
           jmp GND2
           
     GND4: shl DH, 2
           or DH, DL
           mov Next_Digit, DH                    
           
           cmp Next_Digit, 9
           jna GND5
           mov Kbd_Emp, 0FFh
                               
     GND5: cmp Next_Digit, 10
           jne GND6
           mov Equel, 0FFh
           
     GND6: cmp Next_Digit, 11
           jne GND1
           mov Jump_to_Zero, 0FFh
           
     GND1: ret
Get_Next_Digit Endp
;===========================================================================
Price_Form Proc Near
           cmp Kbd_Err, 0
           jne MIF1
           cmp Kbd_Emp, 0
           jne MIF1
           
           mov CX, 5 - 1
           lea SI, Price_in_ASCII_Format + 4
     MIF2: mov AL, [SI-1]
           mov [SI], AL
           dec SI
           loop MIF2
           
           mov AL, Next_Digit
           mov [SI], AL

     MIF1: ret
Price_Form Endp
;==========================================================================
Clearing_Price&Value Proc Near
           cmp Clear_Price_&_Value, 0
           jz CPV1
           
           mov CX, 5
           xor SI, SI
     CPV2: mov Price_in_ASCII_Format[SI], 0
           inc SI
           loop CPV2
           
           mov CX, 9
           xor SI, SI
     CPV3: mov Value_in_ASCII_Format[SI], 0
           inc SI
           loop CPV3
           
     CPV1: ret
Clearing_Price&Value Endp
;==========================================================================
Get_Mass_in_Binary Proc Near
           mov AL, 0
           out 0, AL
           mov AL, 80h
           out 0, AL
           
     GMB2: in AL, 0        
           test AL, 80h
           jz GMB2           
           
           in AL, ADC_Port
           mov BL, AL
           in AL, ADC_Port+1
           mov BH, AL
           
           cmp Jump_to_Zero, 0
           je GMB1
           mov Zero_Mass_in_Binary_Format, BX      
     GMB1: mov Mass_in_Binary_Format, BX
     
           ret
Get_Mass_in_Binary Endp
;==========================================================================
Mass_Control Proc Near
           mov Err_Mass, 0
           
           cmp Mass_in_Binary_Format, 9999
           jna MC2
           mov Err_Mass, 0FFh
           jmp MC1
           
      MC2: mov AX, Mass_in_Binary_Format
           cmp AX, Zero_Mass_in_Binary_Format
           jnb MC1
           mov Err_Mass, 0FFh
     
      MC1: ret
Mass_Control Endp
;==========================================================================
Finding_of_Effective_Mass Proc Near
           cmp Err_Mass, 0
           jnz FEM1
           
           mov AX, Mass_in_Binary_Format
           sub AX, Zero_Mass_in_Binary_Format
           mov word ptr Effective_Mass_in_Binary_Format, AX

     FEM1: ret
Finding_of_Effective_Mass Endp
;===========================================================================
Convert_Mass_from_Binary_to_ASCII Proc Near
           cmp Err_Mass, 0
           jnz CMB5
           
           mov CX, 6
           xor SI, SI
     CMB4: mov Mass_in_ASCII_Format[SI], 0
           inc SI
           loop CMB4

           xor DI, DI
           mov BL, 10

     CMB3: xor AH, AH
           mov SI, length Effective_Mass_in_Binary_Format - 1
           mov CX, length Effective_Mass_in_Binary_Format
           xor BH, BH

     CMB2: mov AL, Effective_Mass_in_Binary_Format[SI]
           div BL
           mov Effective_Mass_in_Binary_Format[SI], AL
           cmp AL, 0
           je CMB1
           inc BH
     CMB1: dec SI

           loop CMB2

           mov Mass_in_ASCII_Format[DI], AH
           inc DI
           cmp BH, 0
           jnz CMB3

           dec DI
           mov Number_of_Digits_in_Mass, AL

     CMB5: ret
Convert_Mass_from_Binary_to_ASCII Endp
;===========================================================================
Define_of_Value Proc Near
           cmp Err_Mass, 0
           jnz DV6
           cmp Equel, 0
           jz DV6

           mov CX, length Value_in_ASCII_Format
           xor SI, SI
      DV3: mov Value_in_ASCII_Format[SI], 0
           inc SI
           loop DV3

           xor BX, BX
           xor CH, CH
           xor DI, DI
      DV2: xor CL, CL
           xor SI, SI
	 
      DV1: mov BL, CL
           mov AL, Price_in_ASCII_Format[SI]
           mul Mass_in_ASCII_Format[DI]
           aam	 
           add AL, Value_in_ASCII_Format[BX+DI]
           aaa
           mov Value_in_ASCII_Format[BX+DI], AL
      DV5: inc BX
           cmp AH, 0
           jz DV4
           mov AL, AH
           xor AH, AH
           add AL, Value_in_ASCII_Format[BX+DI]
           aaa
           mov Value_in_ASCII_Format[BX+DI], AL
           jmp DV5

      DV4: inc SI
           inc CL
           cmp CL, 5
           jnz DV1
	 
           inc DI
           inc CH
           cmp CH, 4
           jnz DV2

      DV6: ret
Define_of_Value Endp
;===========================================================================
Addition_to_Money_Heap Proc Near
           cmp Add_to_Money_Heap, 0
           jz AMH1
           
           mov CX, 6
           xor DI, DI           
           CLC
     AMH2: mov AL, Money_Heap[DI]
           adc AL, Value_in_ASCII_Format[DI+3]
           aaa
           mov Money_Heap[DI], AL
           inc DI
           loop AMH2   
           
           mov CX, 9          
     AMH3: mov AL, Money_Heap[DI]
           adc AL, 0
           aaa
           mov Money_Heap[DI], AL
           inc DI
           loop AMH3

     AMH1: ret
Addition_to_Money_Heap Endp
;===========================================================================
Output Proc Near                      
           cmp Show_Me_the_Money, 0
           jnz OM2

           mov DX, Price_Port
           lea SI, Price_in_ASCII_Format
           mov CX, 5
           mov BL, 3
           call Disp_Out
          
           cmp Err_Mass, 0
           jnz OM1
           
           mov DX, Mass_Port
           lea SI, Mass_in_ASCII_Format          
           mov CX, 4
           mov BL, 1
           call Disp_Out
           
      OM1: mov DX, Value_Port
           lea SI, Value_in_ASCII_Format + 3
           mov CX, 6
           mov BL, 4
           call Disp_Out          
           jmp OM3
           
      OM2: mov DX, Value_Port
           lea SI, Money_Heap
           mov CX, 15
           mov BL, 13           
           call Disp_Out
           
      OM3: ret
Output Endp
;==========================================================================
Disp_Out Proc Near           ;Входные параметры
                             ;DX - адрес порта вывода
                             ;DI - адрес выводимых данных
                             ;CX - число портов для вывода
                             ;BL - номер знакоместа с точкой
      DO1: xor AX, AX
           mov AL, [SI]
           mov DI, AX
           mov AL, Image[DI]
           cmp CL, BL
           jnz DO2
           or AL, 80h
      DO2: out DX, AL
           
           inc SI
           inc DX
           loop DO1

           ret
Disp_Out Endp
;===========================================================================
           Image db 3Fh, 0Ch, 76h, 5Eh, 4Dh, 5Bh, 7Bh, 0Eh, 7Fh, 5Fh
           
Start:     
           mov AX, Data
           mov DS, AX
           mov AX, Stk
           mov SS, AX
           lea SP, StkTop

           call Func_Prepare
           
    Cycle: call Finded_Errors
           call Mode_Input
           call Kbd_Input
           call Kbd_Control
           call Get_Next_Digit
           call Price_Form
           call Clearing_Price&Value
           call Get_Mass_in_Binary
           call Mass_Control
           call Finding_of_Effective_Mass
           call Convert_Mass_from_Binary_to_ASCII
           call Define_of_Value
           call Addition_to_Money_Heap
           call Output
                                 
           jmp Cycle

           org RomSize-16
           assume CS:Nothing
           jmp Far Ptr Start
Code Ends
end
