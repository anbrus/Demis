VibrDestroy PROC NEAR
           Push bx;
VibrDestroy_Lab1:
           mov ah, al;
           mov bh, 0
VibrDestroy_Lab2:
           in al, dx;
           cmp ah, al
           jne VibrDestroy_Lab1
           inc bh
           cmp bh, MaxLoopsForVibrDestr
           jne VibrDestroy_Lab2
           mov al, ah           
           pop bx;
           ret;
VibrDestroy ENDP

GetButtonsData PROC NEAR ; прочитать состояние кнопок
           mov dx, WorkStatusesInPort;
           in al, dx;
           test al, al
           jz GetButtonsData_DontPress; 
           Call VibrDestroy;
GetButtonsData_DontPress:          
           and al, ButtonsDataMask;
           mov ButtonsData, al;
           test al, al 
           jz GetButtonsData_exit;
           mov IsErrorFound, 00h;           
GetButtonsData_Wait:
           mov dx, WorkStatusesInPort;
           in al, dx
           test al, al 
           jnz GetButtonsData_Wait
           Call VibrDestroy;
           test al, al
           jnz GetButtonsData_Wait;
GetButtonsData_exit:
           ret
GetButtonsData ENDP;

GetKeyBoardInput PROC NEAR ; формирование образа клавиатуры.
           push si;
           push bx;
           
           lea si, KeyBoardImage
           mov cx, Length KeyBoardImage;
           mov bl, 01h;
GetKeyBoardInput_Next:         
           mov al, bl;
           out KeyBoardOutPort, al;
           in al, KeyBoardInPort;
           test al, 0Fh;
           jz GetKeyBoardInput_NotActive;
           mov dx, KeyBoardInPort;
           call VibrDestroy;         гашение дребезга.
           mov [si], al;
GetKeyBoardInput_Wait:
           in al, KeyBoardInPort;
           test al, 0Fh;
           jnz GetKeyBoardInput_Wait;
           call VibrDestroy;         гашение дребезга.
           jmp GetKeyBoardInput_Writed;
GetKeyBoardInput_NotActive:
           mov [si], al;
GetKeyBoardInput_Writed:
           inc si;
           shl bl, 1;           
           loop GetKeyBoardInput_Next;
           
           pop bx;
           pop si;
           ret;
GetKeyBoardInput ENDP

GetKeyBoardData PROC NEAR ; преобразование очередной цифры.
           push bx;
           
           Lea bx, KeyBoardImage;
           xor dx, dx;
           
GetKeyBoardData_NextRow:
           mov al, [bx]
           test al, 0Fh;
           jnz GetKeyBoardData_FoundRow
           inc dh;
           inc bx;
           cmp dh, 04h;
           je GetKeyBoardData_@Exit;
           jmp short GetKeyBoardData_NextRow;           
GetKeyBoardData_FoundRow:
           mov IsErrorFound, 00h    ; убрать сообщение об ошибке
GetKeyBoardData_NextCol:
           shr al, 1;
           jc GetKeyBoardData_FoundDigits;
           inc dl;
           jmp short GetKeyBoardData_NextCol;
GetKeyBoardData_FoundDigits:
           mov cl, 2;
           shl dh, cl;
           or dh, dl;
           mov KeyBoardData, dh;
GetKeyBoardData_@Exit:          
           pop bx;
           ret;
GetKeyBoardData ENDP;

NextWorkStatus PROC NEAR
           mov al, DataFixedFlag;
           or al, DataFixedParamTd 
           mov dl, FixedDataButsMask; установка блокировки кнопок.
           Test WorkStatusesData, DataVisioFlag
           jnz NextWorkStatus_Lab1
           mov al, DataVisioFlag 
           or al, DataVisioShowAllFlag 
           mov dl, DataVisioButsMask;
NextWorkStatus_Lab1:
           mov ButtonsDataMask, dl;
           call SetWorkStatus;
           ret;
NextWorkStatus ENDP;

NextWorkPreStatus PROC NEAR
           mov al, DataVisioFlag;
           mov dl, WorkStatusesData
           and dl, DataVisioShowMask;
           shl dl, 1
           and dl, DataVisioShowMask;
           test dl,dl 
           jnz NextWorkPreStatus_Lab1
           mov dl, DataVisioShowAllFlag 
NextWorkPreStatus_Lab1:
           or al, dl
           call SetWorkStatus;
           ret;           
NextWorkPreStatus ENDP;

SetNextPoint PROC NEAR
           mov IsPointNumUpDate, 0FFh;
           mov al, WorkStatusesData;
           test al, DataVisioShowMaxFlag 
           jz SetNextPoint_Lab1;
           call FindNextMax;
           jmp SetNextPoint_@Exit;
SetNextPoint_Lab1:           
           test al, DataVisioShowMinFlag 
           jz SetNextPoint_Lab2;
           call FindNextMin;
           jmp SetNextPoint_@Exit;
SetNextPoint_Lab2:
           mov ax, Word Ptr DataVisioPointNum 
           mov dx, Word Ptr DataVisioPointNum[2]          
           sub ax, Word Ptr MaxPointNumber    
           sbb dx, Word Ptr MaxPointNumber[2]
           jnc SetNextPoint_SetError
           mov ax, Word Ptr DataVisioPointNum 
           mov dx, Word Ptr DataVisioPointNum[2]                     
           add ax, 1
           adc dx, 0;
           jmp SetNextPoint_Finished;
SetNextPoint_SetError:
           mov IsErrorFound, 0FFh;
           mov Byte Ptr ErrorOutPort, PointNumberPort;
           mov IsPointNumUpDate, 00h;
           jmp SetNextPoint_@Exit; 
SetNextPoint_Finished:
           mov Word Ptr DataVisioPointNum, ax
           mov Word Ptr DataVisioPointNum[2], dx
SetNextPoint_@Exit:
           ret;
SetNextPoint ENDP

SetPredPoint PROC NEAR
           mov IsPointNumUpDate, 0FFh;
           mov al, WorkStatusesData;
           test al, DataVisioShowMaxFlag 
           jz SetPredPoint_Lab1;
           call FindPredMax;
           jmp SetPredPoint_@Exit;
SetPredPoint_Lab1:           
           test al, DataVisioShowMinFlag 
           jz SetPredPoint_Lab2;
           call FindPredMin;
           jmp SetPredPoint_@Exit;
SetPredPoint_Lab2:
           mov ax, Word Ptr DataVisioPointNum 
           mov dx, Word Ptr DataVisioPointNum[2]
           test ax, ax
           jz SetPredPoint_SetError 
           sub ax, 1
           sbb dx, 0
           jmp SetPredPoint_Finished;
SetPredPoint_SetError:
           mov IsErrorFound, 0FFh;
           mov Byte Ptr ErrorOutPort, PointNumberPort;
           mov IsPointNumUpDate, 00h;
           jmp SetPredPoint_@Exit; 
SetPredPoint_Finished:
           mov Word Ptr DataVisioPointNum, ax
           mov Word Ptr DataVisioPointNum[2], dx
SetPredPoint_@Exit:
           ret;
SetPredPoint ENDP;

CheckButtonsData PROC NEAR
           push bx;

           mov al, ButtonsData;
           test al, al;
           jz CheckButtonsData_@exit;

           xor cx, cx;
           mov cl, 8;
           mov dl, 80h;
CheckButtonsData_@Find:
           test dl, al
           jz CheckButtonsData_@NextStep
           dec cl;
           mov ax, cx;
           mov dl, 05h;
           mul dl;
           lea bx, CheckButtonsData_StartSelect;
           add bx, ax;
           xor ax, ax;
           Jmp bx;

CheckButtonsData_StartSelect:
           Call NextWorkStatus;
           jmp CheckButtonsData_@exit
           
           call FixedData;
           jmp CheckButtonsData_@exit
           
           call NextWorkPreStatus;
           jmp CheckButtonsData_@exit
           
           call SetNextPoint 
           jmp CheckButtonsData_@exit

           call SetPredPoint 
           jmp CheckButtonsData_@exit
           
CheckButtonsData_@NextStep:
           shr dl, 1;
           loop CheckButtonsData_@Find

CheckButtonsData_@exit:     
           mov ButtonsData, 00h;
           pop bx;
           ret;
CheckButtonsData ENDP;

CheckKeyBoardData PROC NEAR
           mov al, KeyBoardData;
           cmp KeyBoardData, 0FFh
           je CheckKeyBoardData_@Exit; 
           cmp al, 09h;
           ja CheckKeyBoardData_Upravl; цифра?
           call AddNewDigitdToCurField; добавить очередную цифру в текущее поле.
           jmp short CheckKeyBoardData_Finished;
CheckKeyBoardData_Upravl:
           cmp al, MaxButtonIndex
           ja CheckKeyBoardData_Finished
           call ClearTempDigitsArr;
           mov al, KeyBoardData;
           cmp al, EnterButtonIndex    ; нажали на "Enter"?
           jne CheckKeyBoardData_Lab1;
           mov al, WorkStatusesData 
           test al, DataVisioParamN    ; Вводим номер точки?
           jz CheckKeyBoardData_Finished;
           xor WorkStatusesData, DataVisioParamN;
           mov IsPointNumUpDate, 0FFh
           jmp short CheckKeyBoardData_Finished
CheckKeyBoardData_Lab1:
           cmp al, PointNumButIndex    ; нажали на "N" - номер точки
           jne CheckKeyBoardData_Lab2;
           or WorkStatusesData, DataVisioParamN;
           jmp short CheckKeyBoardData_Finished
CheckKeyBoardData_Lab2:           
           test WorkStatusesData, DataFixedFlag;
           jz CheckKeyBoardData_Finished;
           cmp al, TimeLenButIndex     ; нажали на "T" - отрезок времени.
           jne CheckKeyBoardData_Lab3;
           and WorkStatusesData, DestroyFixedParam
           or WorkStatusesData, DataFixedParamT
           jmp short CheckKeyBoardData_Finished
CheckKeyBoardData_Lab3:           
           cmp al, PeriodDsButIndex    ; нажали на "Td"  - период дискретизации
           jne CheckKeyBoardData_Finished
           and WorkStatusesData, DestroyFixedParam
           or WorkStatusesData, DataFixedParamTd
CheckKeyBoardData_Finished:           
           mov KeyBoardData, 0FFh
CheckKeyBoardData_@Exit:
           ret;
CheckKeyBoardData ENDP;