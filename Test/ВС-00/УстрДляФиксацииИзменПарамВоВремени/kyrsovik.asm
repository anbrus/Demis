.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

IntTable   SEGMENT AT 0 use16
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT AT 40h use16
;Здесь размещаются описания переменных
                 Temp dw ?
                 TempArr dw 401 dup (?)
                 TempDisp db 4 dup (?)
                 SecDisp db 3 dup (?)
                 Sec dw ?
                 DataInput db ?
                 FunctData db ?
                 ModeInput db ?
                 Contrl db ?
                 GraphArr db 32 dup (?)
                 IndDb dw ?      
                 Index db ?
                 AdrMinMax dw ?
                 MinMax dw ?
                 Direction db ?
                 CountFlip db ?
                 Flip dw ?
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 100h use16
;Задайте необходимый размер стека
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант
InitData   ENDS

Code       SEGMENT use16
           ASSUME cs:Code,ds:Data,es:InitData
Images     DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           DB    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h

Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,InitData
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы
          
           call prep         ; подготовка
           call WaitProc     ; запуск АЦП по порогу   
Go:
           call Delay        ; задержка +1 секунда
           call NextTemp     ; текущая температура
           call SaveTemp     ; сохраненние температуры
           call InPut        ; фыбор фун-ции с подтверждением
           call Select       ; фыполнение выбранной функций
           call SecToSec     ; преобразование секунды в массив отображений
           call OutSec       ; вывод секунды на индикатор
           call TempToTemp   ; преобразование температуры в массив отображения
           call OutTemp      ; вывод температуры на индикатор
           call Graph        ; построение графика в памяти
           call GraphOut     ; вывод графика
           jmp Go

Min        proc near
MinStart:           
           in al,0
           and al,00011000b
           cmp al,00010000b
           jne Min1
           mov ah,0
           mov Direction,ah
Min111:           
           in al,0
           and al,00011000b
           cmp al,00010000b
           je Min111
           
           jmp Min2
Min1:           
           cmp al,00001000b
           jne Min2
           mov ah,0ffh
           mov Direction,ah
Min222:
           in al,0
           and al,00011000b
           cmp al,00001000b
           je Min222
Min2:      
           mov ah,direction
           cmp ah,0
           jne Min3           
           mov ax,sec
           add ax,1
           cmp ax,400
           je MinExit
           mov sec,ax
           jmp Min4
Min3:      
           cmp ah,0ffh
           jne MinExit           
           mov ax,sec
           sub ax,1
           cmp ax,1
           je MinExit
           mov sec,ax
Min4:     
           lea bx,TempArr
           cmp ax,0
           je Min5
           mov cx,ax
Min4_1:        
           add bx,2
           loop Min4_1
Min5:          
           mov ax,[bx]
           sub bx,2
           mov dx,[bx]
           cmp ax,dx
           jae MinStart
           add bx,4
           mov dx,[bx]
           cmp ax,dx
           jae MinStart
           mov ax,sec
           mov AdrMinMax,ax           
           mov ah,055h
           mov direction,ah           
MinExit:   
           mov ax,AdrMinMax
           mov sec,ax        
           ret
Min        endp


Max        proc near
MaxStart:           
           in al,0
           and al,00011000b
           cmp al,00010000b
           jne Max1
           mov ah,0
           mov Direction,ah
Max111:           
           in al,0
           and al,00011000b
           cmp al,00010000b
           je Max111
           
           jmp Max2
Max1:           
           cmp al,00001000b
           jne Max2
           mov ah,0ffh
           mov Direction,ah
Max222:
           in al,0
           and al,00011000b
           cmp al,00001000b
           je Max222
Max2:      
           mov ah,direction
           cmp ah,0
           jne Max3           
           mov ax,sec
           add ax,1
           cmp ax,400
           je MaxExit
           mov sec,ax
           jmp Max4
Max3:      
           cmp ah,0ffh
           jne MaxExit           
           mov ax,sec
           sub ax,1
           cmp ax,1
           je MaxExit
           mov sec,ax
Max4:     
           lea bx,TempArr
           cmp ax,0
           je Max5
           mov cx,ax
Max4_1:        
           add bx,2
           loop Max4_1
Max5:          
           mov ax,[bx]
           sub bx,2
           mov dx,[bx]
           cmp dx,ax
           jae MaxStart
           add bx,4
           mov dx,[bx]
           cmp dx,ax
           jae MaxStart
           mov ax,sec
           mov AdrMinMax,ax           
           mov ah,055h
           mov direction,ah           
MaxExit:   
           mov ax,AdrMinMax
           mov sec,ax        
           ret
Max        endp




Select     proc near
           push ax
           mov al,DataInput
           cmp al,0ffh
           je  SelectExit
           mov al,FunctData
           cmp al,0
           ja Sel1 
           call SeeArr
           jmp SelectExit
Sel1:      
           cmp al,1
           ja Sel2 
           mov ax,sec
           cmp ax,0
           jne Sel1_1
           mov ax,1
           mov sec,ax
           jmp SelCall1
Sel1_1:           
           cmp ax,400
           jbe SelCall1
           mov ax,399
           mov sec,ax
SelCall1:           
           call Min
           jmp SelectExit
Sel2:      
           cmp al,2
           ja Sel3 
           mov ax,sec
           cmp ax,0
           jne Sel1_2
           mov ax,1
           mov sec,ax
           jmp SelCall1
Sel1_2:    
           cmp ax,400
           jbe SelCall2
           mov ax,399
           mov sec,ax
SelCall2:  
           call Max
           jmp SelectExit
Sel3:      
           cmp al,3
           ja Sel4 
           mov ax,0
           mov AdrMinMax,ax
           call SMin
           jmp SelectExit
Sel4:      
           mov ax,0
           mov AdrMinMax,ax
           call SMax    
SelectExit:           
           pop ax
           ret
Select     endp
           
InPut      proc near         
           push  ax
           push  dx
           
           mov dl,FunctData
           lea bx,images
           cmp dl,0
           jne InPut1122
           mov al,es:[bx]    ;
           out 010h,al       ;]      
           jmp InPutStart
InPut1122:                   ;]]]
           mov dh,0          ;]]]]
           mov cx,dx         ;]]]]] выводим код функций на индикатор
InPut11022:                    ;]]]]
           add bx,1          ;]]]
           loop InPut11022     ;]]
           mov al,es:[bx]    ;]
           out 010h,al       ; 
           
InPutStart:
           mov al,DataInput
           cmp al,0ffh
           je InPutFlExit
InPut0:
           mov dl,FunctData  ;текущая функция
           in al,0
           and al,00000100b
           cmp al,00000100b
           jne InPutExit     ; функция изменена если нет то InPutExit
           
           mov ah,000h       ;иначе сбрасываем флаг подтверждения ввода
           mov ModeInput,ah
           
           add dl,1          ; меняем функцию
           cmp dl,5
           jne InPut1
           mov dl,0
InPut1:
           mov FunctData,dl  ; сохраняем код функции 
           lea bx,images
           cmp dl,0
           jne InPut11
           mov al,es:[bx]    ;
           out 010h,al       ;]      
           jmp InPut2        ;]]
InPut11:                     ;]]]
           mov dh,0          ;]]]]
           mov cx,dx         ;]]]]] выводим код функций на индикатор
InPut110:                    ;]]]]
           add bx,1          ;]]]
           loop InPut110     ;]]
           mov al,es:[bx]    ;]
           out 010h,al       ;     
InPut2:           
           in al,0
           and al,00000100b  ; отпущена ли кнопка (функция)
           cmp al,00000100b
           je InPut2
           
InPutExit: 
           in al,0
           and al,00000010b  ; подтвердили функцию кнопки выбор
           cmp al,00000010b
           jne InPutFullExit ; нет переити на проверку флага ввода
           mov al,0ffh       ; да возвести флаг ввода   
           mov ModeInput,al
InPutFullExit:           
           mov al,ModeInput  ; выполнять функцию?
           cmp al,0ffh
           jne InPut0          
InPutFlExit:
           pop dx
           pop ax
           ret
InPut      endp
           

SeeArr     proc near
           push ax
           in al,0
           and al,00011000b
           cmp al,00011000b
           jne SeeArr1
           jmp SeeArrExit
SeeArr1:
           in al,0
           and al,00010000b
           cmp al,00010000b
           jne SeeArr2
SeAr1:           
           in al,0
           and al,00010000b
           cmp al,00010000b
           je SeAr1
           
           mov ax,sec
           add ax,1
           cmp ax,401
           je  SeeArrExit
           mov sec,ax
           jmp SeeArrExit
SeeArr2:   
           in al,0
           and al,00001000b
           cmp al,00001000b
           jne SeeArrExit
SeAr2:           
           in al,0
           and al,00001000b
           cmp al,00001000b
           je SeAr2
           
           mov ax,sec
           sub ax,1
           cmp ax,0
           je  SeeArrExit
           mov sec,ax        
SeeArrExit:
           pop ax
           ret
SeeArr     endp


Smax       proc near
           push ax
           push bx
           
           mov ax,1          ; устанавливаем  начальные значения
           mov Sec,ax        ;
           mov AdrMinMax,ax  ; Максимальная температура находиться по нулевому адресу (по умолчанию)
           lea bx,TempArr    ;
           add bx,2
           mov ax,[bx]       ;
           mov MinMax,ax     ; Максимальная температура равна значению по нулевому адресу (по умолчанию)
Smax1:
           mov ax,sec
           add ax,1
           cmp ax,401
           je SmaxEnd           
           mov sec,ax
           add bx,2
           
           mov ax,[bx]
           cmp MinMax,ax
           ja Smax1         ; если MinMax>=[BX] то на Smax1
           
           mov MinMax,ax     ; иначе MinMax:=[bx] AdrMinMax:=sec
           mov ax,sec        
           mov AdrMinMax,ax
           jmp Smax1
SmaxEnd:            
           mov ax,AdrMinMax
           mov sec,ax
           
           pop bx            
           pop ax
           ret
Smax       endp

Smin       proc near
           push ax
           push bx
           
           mov ax,1          ; устанавливаем  начальные значения
           mov Sec,ax        ;
           mov AdrMinMax,ax  ; Максимальная температура находиться по нулевому адресу (по умолчанию)
           lea bx,TempArr    ;
           add bx,2
           mov ax,[bx]       ;
           mov MinMax,ax     ; Максимальная температура равна значению по нулевому адресу (по умолчанию)
Smin1:
           mov ax,sec
           add ax,1
           cmp ax,401
           je SminEnd           
           mov sec,ax
           add bx,2
           
           mov ax,[bx]
           cmp MinMax,ax
           jbe Smin1         ; если MinMax<=[BX] то на Smax1
           
           mov MinMax,ax     ; иначе MinMax:=[bx] AdrMinMax:=sec
           mov ax,sec        
           mov AdrMinMax,ax
           jmp Smin1
SminEnd:            
           mov ax,AdrMinMax
           mov sec,ax
           
           pop bx            
           pop ax
           ret
Smin       endp

WaitProc   proc near
           mov  ax,0
           mov  Temp,ax
WP1:           
           mov  dx,Temp 
           call NextTemp
           cmp  dx,temp
           jae  Wp1
           mov  ax,Temp
           sub  ax,dx
           cmp  ax,040h  
           jb   WP1
           ret
WaitProc   endp



Graph      proc near         
           push ax
           mov ah,DataInput
           cmp ah,0ffh
           je Graph0
           mov ax,sec
           
           cmp ax,8
           ja G_1
           mov ax,001h
           jmp G2
G_1:
           cmp ax,393
           jb G_2
           
           mov ax,385      
G_2:
           sub ax,8
           jmp G2                      
Graph0:        
           mov ax,sec
           
           cmp ax,010h
           ja G1
           mov ax,001h
           jmp G2   
G1:
           sub ax,010h
G2:
           mov IndDb,ax
           mov dx,1111111111111111b
           mov Flip,dx   
           call GraphBild
           pop ax
           ret
Graph      endp

GraphOut   proc near
           mov dl,00000001b
           mov al,000h
           out 009h,al
           out 00bh,al
           out 00dh,al
           out 00fh,al
           mov al,00011110b
           out 0,al
           lea si,GraphArr
           
           mov cx,8
GrO1:
           mov al,0
           out 008h,al
           mov al,[si]
           
           push dx
           mov dx,Flip
           and al,dh
           pop dx
           
           out 009h,al
           mov al,dl
           out 008h,al
           add si,1
           shl dl,1
           loop GrO1

           mov dl,00000001b
           mov cx,8
GrO2:
           mov al,0
           out 00ch,al
           mov al,[si]
           
           push dx
           mov dx,Flip
           and al,dh
           pop dx
           
           out 00dh,al
           mov al,dl
           out 00ch,al
           add si,1
           shl dl,1
           loop GrO2

           mov dl,00000001b
           mov cx,8
GrO3:
           mov al,0
           out 00ah,al
           mov al,[si]
           
           push dx
           mov dx,Flip
           and al,dl
           pop dx
           
           out 00bh,al
           mov al,dl
           out 00ah,al
           add si,1
           shl dl,1
           loop GrO3

           mov dl,00000001b
           mov cx,8
GrO4:
           mov al,0
           out 00eh,al
           mov al,[si]
           
           push dx
           mov dx,Flip
           and al,dl
           pop dx
           
           
           out 00fh,al
           mov al,dl
           out 00eh,al
           add si,1
           shl dl,1
           loop GrO4
           ret
GraphOut   endp


GraphBild  proc near
           push cx
           push bx
           push ax
           push dx
           mov ah,00000001b ;] индекс значимого бита 
           mov Index,ah     ;] 
           lea bx,GraphArr 
           mov cx,32         ;
GB1:                         ;]
           mov al,000h       ;] очистка GraphArr
           mov [bx],al       ;]            
           add bx,1          ;
           loop GB1          
            
           mov ax,IndDb      ;] загрузка (краинего левого) адреса
           lea si,TempArr
           mov cx,ax         ;
GB2:                         ;] выбираем (краинюю левую) температуру
           add si,2          ;]
           loop GB2          ;
          
           mov cx,8          ;]берем первых 8 значений
GB4:           
           lea bx,GraphArr
           mov dx,[si]       ;] анализ стоит ли отображать температуру
           cmp dx,03ach      ;]
           jb  GB3
           mov ax,05DCh      ;]
           sub ax,dx         ;]в какое поле её выводить    
           mov dl,35         ;]
           div dl                
           mov ah,0          
           push cx
           
           lea bx,GraphArr
           mov cx,ax         ;
GB5:                         ;]выбираем соответствующий адрес в массиве отображения 
           add bx,1          ;]   
           loop GB5          ;
           
           pop cx
           mov al,[bx]       ;
           mov dl,index      ;] формируем данные    
           add al,dl         ;]    
           mov [bx],al       ;
GB3:                      
           mov ah,index
           shl ah,1
           mov index,ah
           add si,2
           loop GB4

           mov ah,00000001b 
           mov Index,ah      
            
           mov ax,IndDb      
           add ax,8
           lea si,TempArr
           mov cx,ax      
GBs2:                        
           add si,2          
           loop GBs2          
          
           mov cx,8          ;]берем первых 8 значений
GBs4:           
           lea bx,GraphArr
           mov dx,[si]       ;] анализ стоит ли отображать температуру
           cmp dx,03ach      ;]
           jb  GBs3
           mov ax,05DCh      ;]
           sub ax,dx         ;]в какое поле её выводить    
           mov dl,35         ;]
           div dl                
           mov ah,0          
           add al,16
           push cx
           
           lea bx,GraphArr
           mov cx,ax         ;
GBs5:                         ;]выбираем соответствующий адрес в массиве отображения 
           add bx,1          ;]   
           loop GBs5          ;
           
           pop cx
           mov al,[bx]       ;
           mov dl,index      ;] формируем данные    
           add al,dl         ;]    
           mov [bx],al       ;
GBs3:                      
           mov ah,index
           shl ah,1
           mov index,ah
           add si,2
           loop GBs4

           pop dx
           pop ax
           pop bx
           pop cx           
           ret
GraphBild  endp


OutTemp    proc near
           lea si,TempDisp
           mov al,[si]
           add si,1
           mov dl,[si]
           add si,1
           mov dh,[si]
           add si,1
           
           lea   bx,Images
           mov   ah,0
           add   bx,ax
           mov   al,es:[bx]
           out 4,al
           
           mov   al,dl
           lea   bx,Images
           mov   ah,0
           add   bx,ax
           mov   al,es:[bx]
           out 3,al
                      
           mov   al,dh
           lea   bx,Images
           mov   ah,0
           add   bx,ax
           mov   al,es:[bx]
           out 2,al
           
           mov   al,[si]
           lea   bx,Images
           mov   ah,0
           add   bx,ax
           mov   al,es:[bx]
           out 1,al
           
           ret
OutTemp    endp


TempToTemp proc near
           push bx
           push cx
           push ax
           push dx
           
           lea bx,TempArr
           mov ax,sec
           cmp ax,0
           je TTT_1
           mov cx,sec
TTT1:
           add bx,2
           loop TTT1
TTT_1:
           mov ax,[bx]
           
           mov dl,00ah
           div dl
           lea bx,TempDisp
           mov [bx],ah
           add bx,1
           
           mov ah,0
           div dl
           mov [bx],ah
           add bx,1
           
           mov ah,0
           div dl
           mov [bx],ah
           add bx,1
           
           mov ah,0
           div dl
           mov [bx],ah
           add bx,1
            
           pop dx
           pop ax
           pop cx
           pop bx
           ret
TempToTemp endp



OutSec     proc near
           push ax
           push bx
           push dx
                   
           lea si,SecDisp
           mov al,[si]
           add si,1
           mov dl,[si]
           add si,1
           mov dh,[si]
           
           lea   bx,Images
           mov   ah,0
           add   bx,ax
           mov   al,es:[bx]
           out 7,al
           
           mov   ah,0
           mov   al,dl
           lea   bx,Images
           add   bx,ax
           mov   al,es:[bx]
           out 6,al
           
           mov   ah,0
           mov   al,dh
           lea   bx,Images
           add   bx,ax
           mov   al,es:[bx]
           out 5,al
           
           pop dx
           pop bx
           pop ax
           ret
OutSec     endp


SecToSec   proc near
           push bx
           push ax
           push dx
           mov ax,sec
           
           mov bl,10 ;преобразуем текущую секунду (единицы) 
           div bl
           mov dl,al
           mov al,ah 
           lea bx,SecDisp
           mov [bx],al
           
           mov ah,0  ;преобразуем (десятки) 
           mov al,dl
           mov bl,10
           div bl
           mov dl,al
           mov al,ah 
           lea bx,SecDisp
           add bx,1
           mov [bx],al
           
           mov al,dl         ;преобразуем(сотни) 
           lea bx,SecDisp
           add bx,2
           mov [bx],al
           
           pop dx
           pop ax
           pop bx
           ret
SecToSec   endp 


SaveTemp   proc near
           push bx
           push ax
           cmp   DataInput,000h
           je    ST2
           lea bx,TempArr
           mov cx,sec
ST1:
           add bx,2
           loop ST1           
           mov ax,Temp
           mov [bx],ax
ST2:
           pop ax
           pop bx
           ret
SaveTemp   endp 

NextTemp   proc near 
           push ax
           cmp   DataInput,000h
           je    NT1
           mov al,0
           out 0,al
           mov al,1
           out 0,al
WaitRdy:
           in al,0
           and al,1
           cmp al,1
           jne WaitRdy
           in al,1
           mov dl,al
           in al,2
           and al,00000111b
           mov ah,al
           mov al,dl
           mov Temp,ax
           cmp ax,05dcH
           jbe NT1
           mov ax,05dcH
           mov Temp,ax
NT1:
           pop ax        
           ret
NextTemp   endp

           
Delay      proc  near
           push  cx
           push  ax
           cmp   DataInput,000h
           je    DL2
           mov   cx,05fffh
DelayLoop:
           inc   cx
           dec cx
           inc   cx
           dec cx
           inc   cx
           dec cx
           inc   cx
           dec cx
           loop  DelayLoop
           mov ax,sec
           cmp ax,190H
           ja DL1
           inc ax
           mov sec,ax
           jmp DL2
DL1:       
           mov DataInput,000h 
           mov ax,1
           mov sec,ax
              
DL2:
           pop ax
           pop   cx
           ret
Delay      endp

Prep proc near
           mov direction,055h
           mov AdrMinMax,000h       
           mov DataInput,0ffh    ; разрешение ввода данных с термопары
           
           mov CountFlip,0                      
           mov cx,190h           ; обнуление массива температур
           lea bx,TempArr
           mov ax,0
CleareArr: 
           mov [bx],ax
           add bx,2
           loop CleareArr

           mov FunctData,0      ; установка функций по умолчанию(просмотр) 
           
           mov Sec,000h             ; сброс таимера
           
          mov ModeInput,0
           mov Contrl,0           
           ret
Prep endp           

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
