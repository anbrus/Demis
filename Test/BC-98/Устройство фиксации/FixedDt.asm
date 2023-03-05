CheckFixedDataParams PROC NEAR
           xor cl, cl;
           
           mov ax, word ptr DataFixedPeriod;
           or ax, word ptr DataFixedPeriod[2];
           jnz CheckFixedDataParams_NextParam;
           mov cl, 0FFh;
           jmp CheckFixedDataParams_@exit;
CheckFixedDataParams_NextParam:
           
           mov ax, word ptr DataFixedTimeLn
           or ax, word ptr DataFixedTimeLn[2]
           jnz CheckFixedDataParams_@exit;
           mov cl, 0FFh;
           
CheckFixedDataParams_@exit:
           mov al, cl;           
           ret;
CheckFixedDataParams ENDP;

DivTimeLnToPeriod PROC NEAR
           mov ax, Word Ptr DataFixedTimeLn
           mov dx, Word Ptr DataFixedTimeLn[2]
           mov cx, Word Ptr DataFixedPeriod 
           div cx           
           mov Word Ptr MaxPointNumber, ax
           mov Word Ptr MaxPointNumber[2], 00h
           ret;
DivTimeLnToPeriod ENDP;

DelayONEInterv PROC NEAR ; задержка на 0.01 сек.
           mov cx, 21000;
DelayONEInterv_Next:
           nop
           loop DelayONEInterv_Next;           
           ret;
DelayONEInterv ENDP;

GetADCData PROC NEAR
;          <- ax - просчитанное значение.

           mov dx, ADCOutPort
           xor al, al
           out dx, al
           mov al, 01h;
           out dx, al           
           mov dx, ADCInPortStatus
GetADCData_WaitADCReady:
           in al, dx
           test al, 01h;
           jz GetADCData_WaitADCReady
           mov dx, ADCInPortData
           in al, dx;
           mov ah, al
           inc dx;
           in al, dx;
           xchg al, ah
           shr ax, 06h;                      
           cmp ax, 1000
           jna GetADCData_@Exit
           mov ax, 999;
GetADCData_@Exit:       
           ret;
GetADCData ENDP;

FixedData PROC NEAR
           push bx;
           push si;
           
           call CheckFixedDataParams;            
           test al, al;
           jz FixedData_CorrectParam;
           mov Byte Ptr IsErrorFound, 0FFh;
           mov Byte Ptr ErrorOutPort, DataFixedParamPort;
           jmp  FixedData_@exit;
FixedData_CorrectParam:
;           mov ax, Word Ptr DataFixedTimeLn
;           mov dx, Word Ptr DataFixedTimeLn[2]           
;           Call MulAxDx10 
;           Call MulAxDx10 
;           mov Word Ptr DataFixedTimeLn, ax
;           mov Word Ptr DataFixedTimeLn[2], dx
           Call DivTimeLnToPeriod;

           xor si, si
           lea bx, DataFixedValue;
          
           mov ax, Word Ptr MaxPointNumber;
FixedData_NextGetData:
           push ax
           call GetADCData
           mov [bx+si], ax;
           
           mov ax, Word Ptr DataFixedPeriod
           dec ax
           jz FixedData_NoDelay;

FixedData_NextFixDelay:
           push ax;
           call DelayONEInterv;
           pop ax;
           dec ax;
           jnz FixedData_NextFixDelay;
FixedData_NoDelay:
           inc si;
           inc si;
           pop ax
           dec ax
           jnz FixedData_NextGetData;
           
           mov WorkStatusesData, DataVisioFlag 
           or WorkStatusesData, DataVisioShowAllFlag           
           mov Word Ptr DataVisioPointNum, 00h;
           mov Word Ptr DataVisioPointNum[2], 00h;
           mov Word Ptr DataFixedTimeLn, 00h;
           mov Word Ptr DataFixedTimeLn[2], 00h;
           mov Byte Ptr ButtonsDataMask, DataVisioButsMask
           mov IsPointNumUpDate, 0FFh;
FixedData_@exit:
           pop si;
           pop bx;
           ret;
FixedData ENDP;