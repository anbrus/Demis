.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

Data       SEGMENT AT 40h use16
Mode       db ?            ;0<->1
Image      db 10 dup(?)
KbdImage   db ? 
EntTime    db 6 dup (?)
BufTime    db 6 dup (?)
EntTDisp   db 6 dup (?)
BufTDisp   db 6 dup (?)
ActTC      dw ?           ;1..6   
FTime      db ?           ;0<->1   
FMig       db ?              ;0<->1
Time1      db ?              ;0<->1
fSec       db ?              ;0<->ff
fOneSec    db ?              ;0<->ff
fEndTime   db ?              ;0<->ff
OneDec     db ?              ;0..10
Sec        db ?              ;0..10
Period     db ?              ;0..10
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 1000h use16
;Задайте необходимый размер стека
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

Code segment use16      
 ASSUME cs:Code,ds:Data,es:Data

FuncPrep proc                ;функциональная подготовка
           mov ah,03fh
           mov Image[0],ah           
           mov ah,00ch
           mov Image[1],ah           
           mov ah,076h
           mov Image[2],ah           
           mov ah,05eh
           mov Image[3],ah           
           mov ah,04dh
           mov Image[4],ah           
           mov ah,05bh
           mov Image[5],ah           
           mov ah,07bh
           mov Image[6],ah           
           mov ah,00eh
           mov Image[7],ah           
           mov ah,07fh
           mov Image[8],ah           
           mov ah,05fh
           mov Image[9],ah           
           mov ah,0
           mov Mode,ah
           mov KbdImage,ah
           mov FTime,ah
           mov FMig,ah
           mov time1,0
           mov OneDec,0
           mov FSec,0
           mov Sec,0
           mov FEndTime,0
           mov Period,10
           lea si,EntTime
           mov cx,length EntTime
      m1:  mov byte ptr[si],0
           inc si
           loop m1
           lea si,BufTime
           mov cx,length BufTime
      m2:  mov byte ptr[si],0
           inc si
           loop m2
           mov ActTC,6
           ret  
FuncPrep endp
VibrDestr   proc             ;гашение дребезга
vd1:        mov ah,al
            mov bh,0
vd2:        in al,0
            cmp ah,al
            jne vd1
            inc bh
            cmp bh,50
            jne vd2
            mov al,ah
            ret
VibrDestr   endp  
           ;ВВОД РЕЖИМА MODEINPUT
ModeInput proc
           cmp FTime,0
           jne  ex
    M_INp: in al,0
           call VibrDestr     
           test al,1
           jz ex   
     M_INof:
           in al,0
           test al,1
           jnz M_INof
           mov ah,Mode
           not ah
           mov Mode,ah
       ex: ret  
ModeInput endp
ModeInfo proc
           mov al,FEndTime
           cmp al,0
           jne MI_ex
           mov ah,Mode         
           mov al,1
           cmp ah,0
           je MI1            
           mov al,2
     MI1:
           out 0,al
     MI_ex:      
           ret  
ModeInfo endp
;ВВОД С КЛАВИАТУРЫ
KbdInput  proc
          in al,0
          call VibrDestr
          cmp al,1
          jbe KB_ex
          mov KbdImage,al
       KB1:   
          in al,0
          call VibrDestr
          cmp al,1
          ja KB1
       KB_ex:
          ret   
KbdInput  endp
;ФОРМИРОВАНИЕ ИНФОРМАЦИИ
FormInfo1 proc
         mov al,Mode 
         cmp al,0
         jne FI_ex  
         mov al,KbdImage
         cmp al,1
         jbe FI_ex
         lea si,EntTime           
         mov ax,ActTC        ;выбор изменяемого поля
         mov di,ax
         add si,ax   
         dec si
         mov al,KbdImage
         and al,1eh
         cmp ActTC,1
         je  FI2    
         cmp al,2        ;+1
         jne FI1
         mov bl,al           ;Сохранение KbdImage
         mov al,9
         test di,1
         jz FI_1
         mov al,5
    FI_1:               
         mov ah,byte ptr[si]
         cmp ah,al
         jne FI_2
         mov ah,0ffh
    FI_2:
         inc ah     
         mov byte ptr[si],ah
         mov al,bl
   FI1:
         cmp al,4         ;-1   
         jne FI2
         mov ah,byte ptr[si]
         cmp ah,0
         jne FI1_1
         mov ah,6
         test ActTC,1
         jnz FI1_1
         mov ah,10
     FI1_1:    
         dec ah
         mov byte ptr[si],ah
      FI2:
          cmp al,16         ;  
          jne FI3
          cmp di,6
          je FI3
          inc di
          mov ActTC,di
      FI3:                   
          cmp al,8        ;  
          jne FI_ex
          cmp di,0
          je FI_ex
          dec di 
          mov ActTC,di
          mov al,0
          mov KbdImage,al       
      FI_ex:              
          ret  
FormInfo1 endp
AnaliseTime proc
           cmp FTime,1
           jne m_ex
           cmp FMig,1
           je m_ex   
           cmp FOneSec,0
           je m_ex      
           mov FEndTime,0ffh
           lea di,BufTime               
           cmp word ptr[di+4],0
           jne m_dec2
           cmp word ptr[di+2],0
           jne m_dec1
           cmp word ptr [di],0         
           je m_ex
            mov al,byte ptr[di+1]
            mov ah,byte ptr[di]
            dec al
            aas
            mov byte ptr[di],ah
            mov byte ptr[di+1],al                    
            mov byte ptr[di+2],6
            mov byte ptr[di+3],0           
  m_dec1:             
            mov byte ptr[di+4],6
            mov byte ptr[di+5],0           
            mov al,byte ptr[di+3]
            mov ah,byte ptr[di+2]
            dec al
            aas
            mov byte ptr[di+2],ah
            mov byte ptr[di+3],al                    
  m_dec2:          
            mov al,byte ptr[di+5]
            mov ah,byte ptr[di+4]
            dec al
            aas
            mov byte ptr[di+4],ah
            mov byte ptr[di+5],al                    
            mov FEndTime,0 
            call Delay
            call Delay         
            m_ex:
            ret
AnaliseTime endp
FormInfo2 proc
         mov al,Mode
         cmp al,0ffh
         jne FI2_ex
         mov al,KbdImage
         cmp al,1
         jbe FI2_ex    
         lea di,BufTime           
         mov al,KbdImage
         and al,0e0h
         cmp al,10000000b         ;начать
         jne FI_M2
         mov Period,10
         mov Sec,0
         lea si,EntTime              
         mov cx,length EntTime
        FI_M11:     
         mov  ah,byte ptr[si]
         mov byte ptr[di],ah   
         inc si
         inc di
         loop FI_M11
         mov ah,1
         mov FTime,ah
         mov ah,0
         mov FMig,ah
        FI_M2:
         cmp al,00100000b
         jne FI_M3
         mov ah,0            ;Остановить
         mov FTime,ah
         mov FMig,ah
         mov FEndTime,0
       FI_M3:
         cmp al,01000000b    ;Продолжить
         jne FI2_ex     
         mov ah,1
         mov FTime,ah
         cmp FEndTime,0
         je FI2_ex        
         mov FMig,1
       FI2_ex:
         mov al,0
         mov KbdImage,al       
         ret  
FormInfo2 endp

;ФОРМИРОВАНИЕ МАССИВОВ ОТОБРАЖЕНИЯ
FormDisp proc
           lea si,EntTime
           lea di,EntTDisp
           mov cx,length EntTime
       FD1:
           mov al,byte ptr[si]
           mov byte ptr[di],al
           inc si
           inc di
           loop FD1
           lea si,BufTime
           lea di,BufTDisp
           mov cx,length BufTime
        FD2:   
           mov al,byte ptr[si]
           mov byte ptr[di],al
           inc si
           inc di
           loop FD2
           ret
FormDisp endp
;ВЫВОД МАССИВОВ ОТОБРАЖЕНИЯ
TimeDisp proc
         Push bp
         mov bp,sp  
         lea bx,Image 
         lea si,EntTDisp
         mov cx,length EntTime
         mov dx,1
     TD1:
         mov al,byte ptr[si]
         xlat
         test dx,1
         jnz TD1_1
         or al,128
     TD1_1:
         cmp dx,ActTC
         jne TD1_3
         cmp Mode,0
         jne TD1_3
         cmp fSec,0
         jne TD1_3  
     TD1_2:   
         and al,128
     TD1_3:    
         out dx,al
         inc dx
         inc si
         inc di
         loop TD1
         lea si,BufTDisp
         mov cx,length BufTime
         mov dx,7
     TD2:
         mov al,byte ptr[si]  
         xlat
         test dx,1
         jnz TD2_1
         or al,128
     TD2_1:    
         out dx,al
         inc dx
         inc si
         loop TD2                  
         pop bp
         ret  
TimeDisp endp
;Вывод сообщения завершения отсчёта
EndTimeOut proc
           cmp Mode,0
           je ETO_ex           
           mov al,2
           cmp FEndTime,0
           je ETO1
           mov al,6        
           cmp FMig,0
           je ETO1
           mov bh,OneDec
           mov ah,Period
           cmp bh,ah
           jne ETO1
           mov OneDec,0
           mov al,2
           out 0,al
           call Delay
           mov ah,period
           cmp ah,2
           je ETO1
           dec ah           
           mov Period,ah
     ETO1:   
           out 0,al
                
        ETO_ex:   
           ret
EndTimeOut endp
Timer proc
           mov FOneSec,0
           mov al,OneDec
           call Delay
           call Delay
           call Delay
           call Delay
           call Delay             
           inc al
           mov OneDec,al
           cmp al,11
           jb T2
           mov OneDec,0          
           cmp FEndTime,0
           je TNext
           mov al,Sec
           inc al
           mov Sec,al     
           cmp al,10
           jne TNext
           mov fmig,1
           mov Sec,0
        TNext:   
           mov al,FSec
           not al
           mov fsec,al
           mov FOneSec,0ffh
        T2:   
           ret
Timer endp
Delay proc
           mov cx,0ffffh
           T1:loop T1
           ret
Delay endp
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,stk
           mov   ss,ax
           lea   sp,stktop
           call FuncPrep   ;ПОДГОТОВКА      
     M_In: call ModeInput  ;ВВОД РЕЖИМА 
           call ModeInfo   ;ВЫВОД СООБЩЕНИЯ О РЕЖИМЕ MODEINFO
           call KbdInput   ;  
           call AnaliseTime;           
           call FormInfo1  
           call FormInfo2
           call FormDisp
           call Timer
           call TimeDisp
           call EndTimeOut
           jmp M_In    

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
