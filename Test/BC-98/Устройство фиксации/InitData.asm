FillArraybyZero PROC NEAR
;          -> ax - адрес массива
;          -> dl - начальное значение
;          -> cx - количество элементов массива.
           push bx;
           
           mov bx, ax;           
FillArraybyZero_Next:
           mov [bx], dl;
           inc bx;          
           loop FillArraybyZero_Next;
           
           pop bx;
           ret;
FillArraybyZero ENDP;

ClearTempDigitsArr PROC NEAR
           lea ax, TempDigitsArr;
           xor dl, dl
           mov cx, LENGTH TempDigitsArr;
           call FillArraybyZero;
           ret;
ClearTempDigitsArr ENDP

WorkInit PROC NEAR;
           push bx
           push si;
           push di;
           
           push ds;          Копирую массив отображения десятичных цифр.
           mov ax, InitData;
           mov ds, ax;
           mov cx, 0Ah;
           lea si, DigitsImagesCns;
           lea di, DigitsImages;
           Repe Movsb;
           pop ds;
 
           mov ButtonsData, 00h;
           mov ButtonsDataMask, DataVisioButsMask
           
           xor ax, ax;
           mov IsErrorFound, al
           mov ErrorOutPort, al
           mov IsSOtr, al
           mov IsFOtr, al
           
           mov IsDataFixedNow, al
           mov Word Ptr DataFixedPeriod, ax
           mov Word Ptr DataFixedPeriod[2], ax
           mov Word Ptr DataFixedTimeLn, ax
           mov Word Ptr DataFixedTimeLn[2], ax
           mov Word Ptr DataVisioPointNum, ax
           mov Word Ptr DataVisioPointNum[2], ax
           mov IsPointNumUpDate, al
           
           mov DataValue, ax
           mov FirstValue, ax
           mov SecondValue, ax
 
           mov Byte Ptr PeriodKoofArr[0], 60;
           mov Byte Ptr PeriodKoofArr[1], 60;
           mov Byte Ptr PeriodKoofArr[2], 100
           mov Byte Ptr PeriodKoofArr[3], 1
           mov Byte Ptr TimeLenKoofArr[0], 60;
           mov Byte Ptr TimeLenKoofArr[1], 60;
           mov Byte Ptr TimeLenKoofArr[2], 100;
           mov Byte Ptr TimeLenKoofArr[3], 1
           mov Byte Ptr PointNumKoofArr[0], 100;
           mov Byte Ptr PointNumKoofArr[1], 100;
           mov Byte Ptr PointNumKoofArr[2], 100;
           mov Byte Ptr PointNumKoofArr[3], 1           
 
           mov al, DataVisioFlag;
           or al, DataVisioShowAllFlag;
           call SetWorkStatus                     
           
           lea ax, UnVisibleData
           xor dl, dl;
           mov cx, Length UnVisibleData;
           call FillArraybyZero;
           
           lea ax, DataFixedValue 
           xor dl, dl;
           mov cx, Length DataFixedValue;
           call FillArraybyZero;
           
           Call ClearTempDigitsArr;
           
           pop di;
           pop si;
           pop bx;
           ret;
WorkInit ENDP;
