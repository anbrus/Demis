SetDataToUIndicators PROC NEAR
           push si;
           push ds;
           
           mov si, bx;
           mov ds, ax;
           
SetDataToUIndicators_NextSymb:
           mov al, [si]
           out dx, al
           inc dx
           inc si
           loop SetDataToUIndicators_NextSymb;
           
           pop ds;
           pop si;
           ret;
SetDataToUIndicators ENDP;

SetWorkStatus PROC NEAR
           ; -> al - новое значение WorkStatusesData
           
           mov WorkStatusesData, al;
           mov dx, WorkStatusesOutPort
           out dx, al;

           ret;                      
SetWorkStatus ENDP

ConvertDataToObraz PROC NEAR ; преобразовывает данные в массив отображения.
;          -> ( ax, dx ) - dword
;          -> bx - адрес массива приемника.
;          -> di - адрес массива коэффициентов.
;          -> cx - число элементов.

           push si;           
           
           mov si, bx;
           lea bx, DigitsImages;
           shr cx, 1
ConvertDataToObraz_NextDig:
           push cx;
           xor cx, cx
           mov cl, [di];
           div cx;
           push ax;
           mov ax, dx;
           xor dx, dx
           mov cx, 0Ah;
           div cx;
           xchg ax, dx
           xlat;
           mov [si], al;
           xchg ax, dx
           xlat;
           mov [si+1], al;
           pop ax;
           pop cx;
           inc si;
           inc si;
           dec di;
           xor dx, dx
           loop ConvertDataToObraz_NextDig
                      
           pop si;
           ret;
ConvertDataToObraz ENDP;

CreateObrazArrays PROC NEAR
           push bx;
           push di;
           
           mov ax, word ptr DataFixedPeriod;
           mov dx, word ptr DataFixedPeriod[2];
           mov cx, Length PeriodDataObr
           lea bx, PeriodDataObr
           lea di, PeriodKoofArr[2]
           call ConvertDataToObraz;
           or PeriodDataObr[02], 80h;
           
           mov ax, word ptr DataFixedTimeLn 
           mov dx, word ptr DataFixedTimeLn[2]
           mov cx, Length TimeLnDataObr
           lea bx, TimeLnDataObr 
           lea di, TimeLenKoofArr[2]
           call ConvertDataToObraz;
           or TimeLnDataObr[02], 80h;
           
           mov ax, word ptr DataVisioPointNum 
           mov dx, word ptr DataVisioPointNum[2]
           mov cx, Length PointNumberObr
           lea bx, PointNumberObr 
           lea di, PointNumKoofArr[2]
           call ConvertDataToObraz;
           
           mov ax, DataValue
           xor dx, dx
           mov cx, Length DataObr
           lea bx, DataObr
           lea di, PointNumKoofArr[2]
           call ConvertDataToObraz;
           
           mov ax, FirstValue
           xor dx, dx
           mov cx, Length FirstProizvObr
           lea bx, FirstProizvObr
           lea di, PointNumKoofArr[2]
           call ConvertDataToObraz;

           mov ax, SecondValue
           xor dx, dx
           mov cx, Length SecondProizvObr
           lea bx, SecondProizvObr
           lea di, PointNumKoofArr[2]
           call ConvertDataToObraz;           
           
           pop di
           pop bx;           
           ret;
CreateObrazArrays ENDP;

UpdateOutdevices PROC NEAR   ; Обновить состояние портов вывода.
           push bx;
           
           mov al, WorkStatusesData;
           mov dx, WorkStatusesOutPort
           out dx, al;

           mov al, IsErrorFound;    проверка на наличие ошибки
           test al, al
           jz UpdateOutdevices_NotError;
           mov ax, SEG ErrorImage;
           lea bx, ErrorImage; 
           mov cx, ErrorMessgaeLength;
           xor dx, dx;
           mov dl, ErrorOutPort;
           call SetDataToUIndicators;  вывод сообщения об ошибке
           
           Jmp UpdateOutdevices_@Exit;
UpdateOutdevices_NotError:
           lea bx, UnVisibleData;
           test WorkStatusesData, DataFixedFlag    ; Режим фиксации?
           jz UpdateOutdevices_Lab2                ; Если нет -> погасить порты 0..5
           test WorkStatusesData, DataFixedParamTd ; "Период дискретизации"?
           jz UpdateOutdevices_Lab1                ; Если нет -> проверить на "Отрезок времени"
           lea bx, PeriodDataObr                   ; загружем массив отображения для "Период дискретизации"
           jmp UpdateOutdevices_Lab2;
UpdateOutdevices_Lab1:
           test WorkStatusesData, DataFixedParamT  ; "Отрезок времени"?
           jz UpdateOutdevices_Lab2                ; Если нет -> погасить порты 0..5
           lea bx, TimeLnDataObr 
UpdateOutdevices_Lab2:
           mov cx, DataFixedParamsLen;
           xor dx, dx;
           mov ax, SEG TimeLnDataObr; 
           call SetDataToUIndicators;           

           test WorkStatusesData, DataVisioFlag; режим просмотра данных
           jnz UpdateOutdevices_Lab3           ;   
           lea bx, UnVisibleData;              ; Нет. Погасить индикаторы.

           mov cx, DataValueLen                
           mov dx, DataVisioPort       
           mov ax, SEG TimeLnDataObr; 
           call SetDataToUIndicators           ; гасим поле данных

           mov cx, DataValueLen
           mov dx, DataVisioFirstPort  
           mov ax, SEG TimeLnDataObr; 
           call SetDataToUIndicators           ; гасим поле первой произв.

           mov cx, DataValueLen
           mov dx, DataVisioSecondPort         
           mov ax, SEG TimeLnDataObr; 
           call SetDataToUIndicators           ; гасим поле второй произв.

           mov cx, PointNumLen          
           mov dx, PointNumberPort     
           mov ax, SEG TimeLnDataObr; 
           call SetDataToUIndicators           ; гасим поле номера точки.

           xor ax, ax
           out 17h, al;
           jmp UpdateOutdevices_@Exit

UpdateOutdevices_Lab3:
           lea bx, DataObr
           mov cx, DataValueLen                
           mov dx, DataVisioPort       
           mov ax, SEG TimeLnDataObr; 
           call SetDataToUIndicators        

           lea bx, FirstProizvObr
           mov cx, DataValueLen
           mov dx, DataVisioFirstPort  
           mov ax, SEG TimeLnDataObr; 
           call SetDataToUIndicators          

           lea bx, SecondProizvObr
           mov cx, DataValueLen
           mov dx, DataVisioSecondPort         
           mov ax, SEG TimeLnDataObr; 
           call SetDataToUIndicators   
           
           lea bx, PointNumberObr
           mov cx, PointNumLen          
           mov dx, PointNumberPort     
           mov ax, SEG TimeLnDataObr; 
           call SetDataToUIndicators           
           
           xor al, al
           test IsFOtr, 0FFh;
           jz UpdateOutdevices_Lab4
           or al, 40h
UpdateOutdevices_Lab4:           
           test IsSOtr, 0FFh;
           jz UpdateOutdevices_Lab5
           or al, 80h
UpdateOutdevices_Lab5:
           out 17h, al;
UpdateOutdevices_@Exit:
           pop bx;          
           ret;
UpdateOutdevices ENDP;
