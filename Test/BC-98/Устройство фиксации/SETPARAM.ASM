MulAxDx10 PROC NEAR ; выполнить операцию (Dx,Ax) := (Dx,Ax)*10
           push  bx
           push  dx
           
           mov   bx,ax
           xor   dx,dx
           sal   bx,1
           rcl   dx,1
           sal   bx,1
           rcl   dx,1
           add   ax,bx
           pop   bx
           adc   dx,bx
           shl   bx,2
           add   dx,bx
           sal   ax,1
           rcl   dx,1

           pop   bx
           ret;
MulAxDx10 ENDP;

MulAxDxToCx PROC NEAR 
           push bx;
           
           push ax;           
           mov ax, dx
           mul cx;
           mov bx, ax
           pop ax;
           mul cx
           add dx, bx;           
           
           pop bx;
           ret;
MulAxDxToCx ENDP;

ConvertDigitsArrToData PROC NEAR
;          -> bx - адрес изменяемого поля.
           push si;
           
           mov si, bx;
           lea bx, TempDigitsArr;
           add bx, 2
           xor ax, ax
           xor dx, dx
           mov cx, 3;           
ConvertDigitsArrToData_Next:
           push cx
           mov cl, [bx];
           shl cx, 4;
           shr cl, 4;
           Push cx
           Push cx
           call MulAxDx10;
           pop cx
           mov cl, ch
           xor ch, ch
           add ax, cx
           adc dx, 0
           call MulAxDx10;
           pop cx
           xor ch, ch
           add ax, cx
           adc dx, 0           
           pop cx
           dec bx
           loop ConvertDigitsArrToData_Next;
           
           mov [si], ax;
           mov [si+2], dx;

           pop si;
           ret;
ConvertDigitsArrToData ENDP;

ConvertDigitsArrToTime PROC NEAR
;          -> bx - адрес изменяемого поля.
;          -> ax - массив коэффициентов.
           push si
           push di
           
           mov di, ax;
           mov si, bx;
           lea bx, TempDigitsArr;
           add bx, 2
           xor ax, ax
           xor dx, dx
           mov cx, 3;           
ConvertDigitsArrToTime_Next:
           push cx
           mov cl, [bx];
           shl cx, 4;
           shr cl, 4;
           push ax
           push dx
           xor ax, ax
           mov al, ch
           call MulAxDx10;           
           add cl, al
           xor ch, ch;
           pop dx;
           pop ax;
           add ax, cx
           adc dx, 0;
           xor cx, cx
           mov cl, [di];
           Call MulAxDxToCx;
           pop cx;
           inc di
           dec bx;
           loop ConvertDigitsArrToTime_Next;
                      
           mov [si], ax;
           mov [si+2], dx;
           pop di;
           pop si;
           ret;
ConvertDigitsArrToTime ENDP;

AddDigit PROC NEAR
           push bx
           
           lea bx, TempDigitsArr;
           xor dx, dx
           mov ax, [bx];
           mov dl, [bx+2];
           clc
           mov cl, 4;
AddDigit_SHL:
           rcl ax, 1;
           rcl dx, 1;
           loop AddDigit_SHL;
           or al, KeyBoardData 
           mov [bx], ax;
           mov [bx+2], dl;
           
           pop bx
           ret;
AddDigit ENDP;

AddNewDigitdToCurField PROC NEAR
           push bx;
           mov al, WorkStatusesData;           
           test al, DataParamsMask 
           jz AddNewDigitdToCurField_@Exit;

           call AddDigit;           
           mov al, WorkStatusesData 
           test al, DataVisioParamN;
           jz AddNewDigitdToCurField_Next1;
           lea bx, DataVisioPointNum;
           call ConvertDigitsArrToData;                      
           jmp short AddNewDigitdToCurField_@Exit
AddNewDigitdToCurField_Next1:
           test al, DataFixedParamT
           jz AddNewDigitdToCurField_Next2
           lea bx, DataFixedTimeLn
           lea ax, TimeLenKoofArr[1]
           jmp short AddNewDigitdToCurField_Finished
AddNewDigitdToCurField_Next2:           
           test al, DataFixedParamTd
           jz AddNewDigitdToCurField_Finished;
           lea bx, DataFixedPeriod
           lea ax, PeriodKoofArr[1]     
AddNewDigitdToCurField_Finished:
           call ConvertDigitsArrToTime;
AddNewDigitdToCurField_@Exit:
           pop bx;
           ret;           
AddNewDigitdToCurField ENDP;