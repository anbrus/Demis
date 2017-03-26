.386
;Задайте объём ПЗУ в байтах
RomSize    EQUEQU   4*1024

CGame=1
CPere=2
CPrIg=0

kbZero=0
kbSpace=0ah
kbBrSp=26h
kbClr=27h
kbAdd=28h
kbSub=29h
kbCK=2ah
kbCP=2bh
kbCD=2ch
kbStop=2fh

Data       SEGMENT  AT 0h use16
;Здесь размещаются описания переменных
Mode       db ?                      ; 1 игра, 2 перерыв, 0 предигровой отчет
Stop db ? ; 1 остановка

TimeGame   db 4 dup (?)      ; время игры
Period     db 2 dup(?)              ;номер периода
Kom1  db 4 dup (?)
Kom2  db 4 dup (?)      ;названия команд
GolKom1 db 2 dup (?)
GolKom2 db 2 dup (?) ;счет

BeginPlay label   ;динна записи 15

PlayKom1 label
Play1Fl db ?                     ;0
Play1 db 8 dup(?)                ;1
NPlay1 db 2 dup(?)               ;9
TimeGol1   db 4 dup (?)          ;11

PlayB11Fl db ?
PlayB11 db 8 dup(?)
NPlayB11 db 2 dup(?)
TimeB11 db 4 dup (?)

PlayB12Fl db ?
PlayB12 db 8 dup(?)      ;игроки отбывающие штраф
NPlayB12 db 2 dup(?)
TimeB12   db 4 dup (?)      ;время отбывания штрафа

PlayKom2 label
Play2Fl db ?
Play2 db 8 dup(?)      ;игроки забившие голы
NPlay2 db 2 dup(?)
TimeGol2   db 4 dup (?)      ;время забития гола

PlayB21Fl db ?
PlayB21 db 8 dup(?)
NPlayB21 db 2 dup(?)
TimeB21 db 4 dup (?)

PlayB22Fl db ?
PlayB22 db 8 dup(?)      ;
NPlayB22 db 2 dup(?)
TimeB22   db 4 dup (?)      ;


LenPeriod dw  ?
LenPerir dw  ?
LenPrIgr dw  ?

IncDec db ?
IncDecCmp db ?
IncDecCmp60 db ?
IncDecMov db ?
IncDecMov60 db ?

CaseKom db ?     ;первая 0, вторая 1, время игры 2, параметры игры 3       CK
CasePlay db ?    ;название 0, забивший 1, штрафной1 2, штрафной2 3, счет 4 CP   
CaseDom db ?     ;номер 0, время 1, фамилия 2                              CD  

KbdImg db 6 dup(?)
NextChar db ?
KbdPress db ?

AdrWW dw ? ;адрес области ввода
LenWW dw ? ;длинна области ввода
AdrSc dw ? ;Адрес счета
Nomber db ?; цифра 1, символы 0
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT  AT 500h use16
;Задайте необходимый размер стека
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS



Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data,es:Data
ImgNum     db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh    ;Образы 16-тиричных символов
           db    07Fh,05Fh    ;от 0 до 9          
;алфавит
ImgAlf     db 03Eh, 041h, 041h, 041h, 03Eh, 000h, 000h, 000h    ;0
           db 000h, 000h, 042h, 07Fh, 040h, 000h, 000h, 000h    ;1
           db 062h, 051h, 049h, 049h, 046h, 000h, 000h, 000h    ;2
           db 022h, 041h, 049h, 049h, 036h, 000h, 000h, 000h    ;3
           db 01Ch, 013h, 010h, 010h, 07Fh, 000h, 000h, 000h    ;4
           db 027h, 045h, 045h, 045h, 039h, 000h, 000h, 000h    ;5
           db 03Eh, 049h, 049h, 049h, 032h, 000h, 000h, 000h    ;6
           db 001h, 001h, 079h, 005h, 003h, 000h, 000h, 000h    ;7
           db 03Ah, 045h, 045h, 045h, 03Ah, 000h, 000h, 000h    ;8
           db 026h, 049h, 049h, 049h, 03Eh, 000h, 000h, 000h    ;9
           db 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h    ;Space
           db 07Eh, 011h, 011h, 011h, 07Eh, 000h, 000h, 000h ;A1
           db 07Fh, 045h, 045h, 045h, 03Ah, 000h, 000h, 000h ;B2
           db 03Eh, 041h, 041h, 041h, 022h, 000h, 000h, 000h ;C3
           db 07Fh, 041h, 041h, 041h, 03Eh, 000h, 000h, 000h ;D4
           db 07Fh, 049h, 049h, 049h, 063h, 000h, 000h, 000h ;E5
           db 07Fh, 009h, 009h, 009h, 003h, 000h, 000h, 000h ;F6
           db 03Eh, 041h, 041h, 051h, 032h, 000h, 000h, 000h ;G7
           db 07Fh, 008h, 008h, 008h, 07Fh, 000h, 000h, 000h ;H8
           db 000h, 000h, 041h, 07Fh, 041h, 000h, 000h, 000h ;I9
           db 000h, 020h, 041h, 03Fh, 001h, 000h, 000h, 000h ;J10
           db 07Fh, 008h, 004h, 00Ah, 071h, 000h, 000h, 000h ;K11
           db 07Fh, 040h, 040h, 040h, 060h, 000h, 000h, 000h ;L12
           db 07Fh, 004h, 008h, 004h, 07Fh, 000h, 000h, 000h ;M13
           db 07Fh, 004h, 008h, 010h, 07Fh, 000h, 000h, 000h ;N14
           db 03Eh, 041h, 041h, 041h, 03Eh, 000h, 000h, 000h ;O15
           db 07Fh, 009h, 009h, 009h, 006h, 000h, 000h, 000h ;P16
           db 03Eh, 041h, 041h, 061h, 03Eh, 040h, 000h, 000h ;Q17
           db 07Fh, 009h, 009h, 019h, 066h, 000h, 000h, 000h ;R18
           db 046h, 049h, 049h, 049h, 031h, 000h, 000h, 000h ;S19
           db 003h, 001h, 07Fh, 001h, 003h, 000h, 000h, 000h ;T20
           db 03Fh, 040h, 040h, 040h, 03Fh, 000h, 000h, 000h ;U21
           db 01Fh, 020h, 040h, 020h, 01Fh, 000h, 000h, 000h ;V22
           db 03Fh, 040h, 030h, 040h, 03Fh, 000h, 000h, 000h ;W23
           db 063h, 014h, 008h, 014h, 063h, 000h, 000h, 000h ;X24
           db 003h, 004h, 078h, 004h, 003h, 000h, 000h, 000h ;Y25
           db 063h, 051h, 049h, 045h, 063h, 000h, 000h, 000h ;Z26
           db 008h, 008h, 008h, 008h, 008h, 000h, 000h, 000h ;-27

VibrDestr proc   ;гашение дребезга
vd1:       mov ah,al
           mov bh,0
vd2:       in al,dx
           cmp ah,al
           jne   vd1
           inc bh
           cmp bh,50
           jne vd2
           mov al,ah
           
           ret
VibrDestr endp
KbdInput proc    ; четение образа клавиатуры
           mov dx,1013h
           lea si,KbdImg
           mov cx,length kbdimg
           mov bl,01h
ki4:       mov al,bl
           out dx,al

           in al,dx
           cmp al,0
           je ki1
           call VibrDestr
           mov [si],al
ki2:       in al,dx
           cmp al,0
           jne ki2
           call vibrdestr
           jmp ki3
ki1:       mov [si],al
ki3:       inc si
           rol bl,1
           loop ki4  
           mov al,10000000b
           out dx,al          
           ret
KbdInput endp
KbdPreob proc    ;преобразование образа в код клавиши
           mov KbdPress,0
           lea bx,kbdimg
           xor dx,dx
           mov cx,length kbdimg
KP2:       mov al,[bx]
           cmp al,0
           je KP1
           mov kbdpress,1
KP4:       test al,1
           jnz KP3
           shr al,1
           inc dl
           jmp kp4           
kp1:       inc bx
           inc dh
           loop kp2           
KP3:       shl dh,3
           or dh,dl   
           mov nextchar,dh        
           ret
KbdPreob endp
; очистка выбранного поля
ClearPole proc ;bx - куда, cx - размерность, ax - чем 
CP1:       mov [bx],al
           inc bx
           loop CP1           
           ret
ClearPole endp
; добавление символов
AddChar proc      ;bx - куда, cx - размерность, 
           dec cx       
AC1:       mov al,[bx+1]
           mov [bx],al
           inc bx
           loop AC1   
           mov al,nextchar        
           mov [bx],al
           ret
AddChar endp
; удаление символа
DelChar proc      ;bx - куда, cx - размерность, al - что
           dec cx       
           add bx,cx
DC1:       mov dl,[bx-1]
           mov [bx],dl
           dec bx
           loop DC1            
           mov [bx],al
           ret
DelChar endp
; выбор области ввода
CaseDomain proc
           
           
           cmp casedom,0
           jne NoNomer
           mov lenWW,2
           mov Nomber,1
           mov si,9
           jmp EndDom
NoNomer:   cmp casedom,1
           jne notimePl
           mov lenWW,4
           mov Nomber,1
           mov si,11
           jmp EndDom
noTimePl:  mov lenWW,8
           mov Nomber,0
           mov si,1
EndDom:    
           xor ax,ax
           mov al,caseplay
           dec al
           mov dl,15
           mul dl
           add si,ax


           cmp casekom,0
           jne NoKom1
           
           lea BX,GolKom1
           mov AdrSc,bx
           cmp caseplay,0
           jne k1noname
           lea bx,kom1
           mov AdrWW,bx
           mov LenWW,4 
           mov Nomber,0 
           jmp EndCD
k1noname:  cmp caseplay,4
           jne k1NoScet         
           lea bx,GolKom1
           mov AdrWW,bx
           mov LenWW,2 
           mov Nomber,1 
           jmp endCD
k1NoScet:    add si,offset PlayKom1
           mov adrWW,si
           jmp endCD
NoKom1:    cmp casekom,1
           jne NoKom2
           
           lea BX,GolKom2
           mov AdrSc,bx
           cmp caseplay,0
           jne k2noname
           lea bx,kom2
           mov AdrWW,bx
           mov LenWW,4 
           mov Nomber,0 
           jmp EndCD
k2noname:  cmp caseplay,4
           jne k2NoScet         
           lea bx,GolKom2
           mov AdrWW,bx
           mov LenWW,2 
           mov Nomber,1 
           jmp endCD
k2NoScet:    add si,offset PlayKom2
           mov adrWW,si
           jmp endCD

           
           jmp EndCD
NoKom2:    cmp casekom,2
           jne notime
           lea bx,timeGame           
           mov adrww,bx
           mov nomber,1
           mov lenww,4
           mov adrsc,bx
           jmp EndCD
NoTime:                                     
           
EndCD:            
           ret
CaseDomain endp

WorkKb proc      ; обработка клавиши
           cmp KbdPress,1
           jne WKBEnd
           
           call CaseDomain
           mov bx,AdrWW
           mov cx,LenWW
           mov al,kbZero
           cmp Nomber,0
           jne OkNomber
           mov al,kbSpace
OkNomber:           

           cmp nextchar,kbBrSp
           jae SpecChar
           cmp Nomber,1
           jne noNomber
           cmp nextchar,10
           jae WKBEnd
noNomber:           
           
           call AddChar
           
           jmp WKBEnd
SpecChar:  cmp nextchar,kbStop
           jne NoStop
           not stop    
           jmp WKBEnd
NoStop:    cmp nextchar,kbBrSp
           jne noBrSp
           call DelChar
           jmp WKBEnd
NoBrSp:    cmp nextchar,kbClr
           jne noClr
           call ClearPole
           jmp WKBEnd
noClr:     cmp nextchar,kbCK
           jne noCK
           inc casekom
           cmp casekom,4
           jb okCK
           mov casekom,0
okCK:      jmp WKBEnd
noCK:      cmp nextchar,kbCD
           jne noCD
           inc casedom
           cmp casedom,3
           jb okCD
           mov casedom,0
okCD:      jmp WKBEnd           
noCD:      cmp nextchar,kbCP
           jne noCP
           inc caseplay
           cmp caseplay,5
           jb okCP
           mov caseplay,0
okCP:      jmp WKBEnd           
noCP:      cmp nextchar,kbAdd
           jne noAdd
           mov bx,adrSc
           inc byte ptr [bx]
           cmp byte ptr [bx],9
           jbe okAdd
           mov byte ptr [bx],0
           inc byte ptr [bx+1]
okAdd:     jmp WKBEnd           
noAdd:     cmp nextchar,kbSub
           jne noSub
           mov bx,adrSc
           dec byte ptr [bx]
           cmp byte ptr [bx],0
           jge okSub
           mov byte ptr [bx],9
           dec byte ptr [bx+1]
           cmp word ptr [bx],0
           jge okSub
           mov word ptr[bx],0
okSub:     jmp WKBEnd           
noSub:                

WKBEnd:
           ret
WorkKb endp

CMPFlag proc     ; установка флагов
        mov al,0
        cmp word ptr NPlay1,0
        je CF1
        mov al,1
CF1:    mov Play1Fl,al           
        mov al,0
        cmp word ptr NPlay2,0
        je CF2
        mov al,1
CF2:    mov Play2Fl,al           
        mov al,0
        cmp word ptr NPlayB11,0
        je CF3
        mov al,1
CF3:    mov PlayB11Fl,al           
        mov al,0
        cmp word ptr NPlayB12,0
        je CF4
        mov al,1
CF4:    mov PlayB12Fl,al           
        mov al,0
        cmp word ptr NPlayB21,0
        je CF5
        mov al,1
CF5:    mov PlayB21Fl,al           
        mov al,0
        cmp word ptr NPlayB22,0
        je CF6
        mov al,1
CF6:    mov PlayB22Fl,al           
        
        ret              
CMPFlag endp
Clear proc ;очичтка данных
           mov al,kbSpace
           lea bx,kom1
           mov cx,8
           call ClearPole           
           lea bx,Play1
           mov cx,8
           call ClearPole           
           lea bx,Play2
           mov cx,8
           call ClearPole           

           lea bx,PlayB11
           mov cx,8
           call ClearPole           
           lea bx,PlayB12
           mov cx,8
           call ClearPole           
           lea bx,PlayB21
           mov cx,8
           call ClearPole           
           lea bx,PlayB22
           mov cx,8
           call ClearPole           

           mov ax,0
           lea bx,TimeB11
           mov cx,4
           call ClearPole           
           lea bx,TimeB12
           mov cx,4
           call ClearPole           
           lea bx,TimeB21
           mov cx,4
           call ClearPole           
           lea bx,TimeB22
           mov cx,4
           call ClearPole           

           lea bx,NPlayB11
           mov cx,2
           call ClearPole           
           lea bx,NPlayB12
           mov cx,2
           call ClearPole           
           lea bx,NPlayB21
           mov cx,2
           call ClearPole           
           lea bx,NPlayB22
           mov cx,2
           call ClearPole           

           lea bx,GolKom1
           mov cx,4
           call ClearPole           
           lea bx,TimeGame
           mov cx,4
           call ClearPole           

           mov Period,1

           xor ax,ax
           mov Play1Fl,al
           mov Play2Fl,al
           mov PlayB11Fl,al
           mov PlayB12Fl,al
           mov PlayB21Fl,al
           mov PlayB22Fl,al

           
           mov word ptr kom1,0001h
           mov word ptr kom2,0709h;

           mov play2Fl,1
           mov word ptr play2,020ah
           mov word ptr play2+2,020ah
           mov word ptr play2+4,0202h
           mov word ptr play2+6,0202h
           mov word ptr NPlay2,3
           
           mov playB12Fl,1
           mov word ptr playb12,0102h;

           mov playB22Fl,1
           mov word ptr playb22,0202h


           ret
Clear endp




OutChar macro ;SI откуда 
           local LOTNext
           push cx
           push ax
           mov cx,8
           mov ah,1
LOCNext:   mov al,cs:[si]
           mov dh,01
           out dx,al
           mov al,ah
           mov dh,2       
           out dx,al
           shl ah,1
           mov al,0
           mov dh,2
           out dx,al
           inc si
           loop LOCNext
           pop ax
           pop cx           
           
            endm
OutText proc ;BX - откуда выводить длинной 8, DX - куда выводить
           
           mov di,1
           mov cx,8
LOTNext:   mov al,[bx]        
           xor ah,ah
           shl ax,3
           lea si,ImgAlf
           add si,ax
           mov ax,di
           mov dh,0
           out dx,al
           OutChar
           shl di,1
           inc bx
           loop LOTNext
           mov al,0
           mov dh,0
           out dx,al
        
           ret
Outtext endp
IncTime proc ; Bx что

           mov al,[bx]     ;еденици секунд
           add al,IncDec
           mov [bx],al
           cmp al,IncDecCmp
           jb NEnd
           mov al,IncDecMov
           mov [bx],al
           mov al,[bx+1]     ;десятки минут
           add al,IncDec
           mov [bx+1],al
           cmp al,IncDecCmp60
           jb NEnd
           mov al,incdecMov60
           mov [bx+1],al
           mov al,[bx+2]     ;еденици минут
           add al,IncDec
           mov [bx+2],al
           cmp al,IncDecCmp
           jb NEnd
           mov al,IncDecMov
           mov [bx+2],al
           mov al,[bx+3]     ;десятки минут
           add al,IncDec
           mov [bx+3],al
           cmp al,IncDecCmp
           jb NEnd
           mov al,IncDecMov
           mov [bx+3],al
NEnd:      ret     
IncTime endp           


OutTime proc ;bx - откуда, сx - какой длинны, dx - порт активация
           add bx,cx
           dec bx
           mov di,1111111111111110b
           
NextOT:    mov ax,di
           out dx,al
           mov al,[bx]
           xor ah,ah
           mov si,ax
           mov al,imgNum[si]
           out 20h,al
           dec bx
           rol di,1
           mov al,0
           out 20h,al
           loop nextOT
           mov al,0FFh
           out dx,al
           ret
OutTime endp      
OutNum proc ;bx - откуда, сx - какой длинны, dx - порт активация,Di с какой позиции
           add bx,cx
           dec bx
           
NextON:    mov ax,di
           out dx,al
           mov al,[bx]
           xor ah,ah
           mov si,ax
           mov al,imgNum[si]
           out 20h,al
           dec bx
           rol di,1
           mov al,0
           out 20h,al
           loop nextOT
           mov al,0FFh
           out dx,al
           ret
OutNum endp  
    
OutSettings proc
           mov al,0          ;вывод стоп
           cmp stop,1
           jne OSN1
           or al,00000001b
OSN1:
           cmp casekom,0
           jne OSNoK1
           or al,00000010b
           jmp OSN2
OSNoK1:           
           cmp casekom,1
           jne OSNoK2
           or al,00000100b
           jmp OSN2
OSNoK2:           
           cmp casekom,2
           jne OSNoTime
           or al,00001000b
           jmp OSN2
OSNoTime:           
           or al,00010000b
OSN2:      
           cmp casedom,0
           jne OSNoNom
           or al,00100000b
           jmp OSN3
OSNoNom:           
           cmp casedom,1
           jne OSNoTime2
           or al,01000000b
           jmp OSN3
OSNoTime2:           
           or al,10000000b
OSN3:           
           out 12h,al     
           
           mov al,0
           cmp caseplay,0
           jne OSNoNam
           or al,00000001b
           jmp OSN4
OSNoNam:           
           cmp caseplay,1
           jne OSNoP1
           or al,00000010b
           jmp OSN4
OSNoP1:           
           cmp caseplay,2
           jne OSNoP2
           or al,00000100b
           jmp OSN4
OSNoP2:           
           cmp caseplay,3
           jne OSNoP3
           or al,00001000b
           jmp OSN4
OSNoP3:           
           or al,00010000b
OSN4:      
           out 11h,al     
                      
           
           ret
OutSettings endp
      
OutAll proc
           mov cx,4
           lea bx,timegame
           mov dx,23h
           call OutTime

           cmp Play1Fl,1
           jne LOAN1
           lea bx,Play1      
           mov dx,2
           call OutText
           mov cx,2
           lea bx,NPlay1
           mov dx,10h
           mov di,0FFFEh
           call OutNum
LOAN1:     
           cmp Play2Fl,1
           jne LOAN2
           lea bx,Play2      
           mov dx,3
           call OutText
           mov cx,2
           lea bx,NPlay2
           mov dx,10h
           mov di,0FFFBh
           call OutNum
LOAN2:     

           cmp PlayB11Fl,1
           jne LOAN3
           lea bx,PlayB11
           mov dx,4
           call OutText
           mov cx,2
           lea bx,NPlayB11
           mov dx,2fh
           mov di,0FFFEh
           call OutNum
           mov cx,4
           lea bx,timeb11
           mov dx,2bh
           call OutTime
LOAN3:     

           cmp PlayB12Fl,1
           jne LOAN4
           lea bx,PlayB12
           mov dx,5
           call OutText
           mov cx,2
           lea bx,NPlayB12
           mov dx,2fh
           mov di,0FFFBh
           call OutNum
           mov cx,4
           lea bx,timeb12
           mov dx,2ch
           call OutTime
LOAN4:     

           cmp PlayB21Fl,1
           jne LOAN5
           lea bx,PlayB21
           mov dx,6
           call OutText
           mov cx,2
           lea bx,NPlayB21
           mov dx,2fh
           mov di,0FFEFh
           call OutNum
           mov cx,4
           lea bx,timeb21
           mov dx,2dh
           call OutTime
LOAN5:     

           cmp PlayB22Fl,1
           jne LOAN6
           lea bx,PlayB22
           mov dx,7
           call OutText
           mov cx,2
           lea bx,NPlayB22
           mov dx,2fh
           mov di,0FFBFh
           call OutNum
           mov cx,4
           lea bx,timeb22
           mov dx,2eh
           call OutTime
LOAN6:     
           lea bx,Kom1
           mov dx,1
           call OutText
           mov cx,2
           lea bx,GolKom1
           mov dx,10h
           mov di,0FFEFh
           call OutNum
           mov cx,2
           lea bx,GolKom2
           mov dx,10h
           mov di,0FFBFh
           call OutNum
           
           call OutSettings
           ret
OutAll       endp

PodGot     proc
           call Clear
    
           mov LenPeriod,0200h
           mov LenPerir,0105h
           mov lenPrIgr,0600h
           mov mode,CPrIg
           mov stop,1
           mov ax,LenPrIgr
           mov word ptr TimeGame+2,ax
           mov casedom,0
           mov caseplay,0
           mov casekom,0
          mov al,0ffh
          out 2bh,al
          out 2ch,al
          out 2dh,al
          out 2eh,al
          out 10h,al
          out 2fh,al
          ret
PodGot endp       
;__________________________

Input proc
           call KbdInput
           call KbdPreob
         
          call WorkKb
           ret
Input endp

Output proc
           call CMPFlag
           call OutAll
           ret
Output endp

Timer proc
           cmp stop,1
           je endTimer
           mov IncDec,-1
           mov IncDecCmp,9
           mov IncDecCmp60,9
           mov IncDecMov,9
           mov IncDecMov60,05
           lea bx,TimeGame
           call IncTime
endTimer:
           ret
Timer endp
;__________________________
                        
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы
           call podgot

Next:      mov   al,0
           out   32h,al
           mov   al,0FFh
           out   32h,al 
           
nonext:              
           call Input
           call Timer
           call Output

           in al,32h    
           test al,1
           jz nonext
          
           jmp next
           
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
