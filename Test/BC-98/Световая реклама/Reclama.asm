.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

IndCount   EQU   8
ColCount   EQU   6
MaxLen     EQU   32
SpaceLen   EQU   8
PriceLen   EQU   2
MaxMsg     EQU   4
TimeLen    EQU   4
KeyPause   EQU   30
DownKeyP   EQU   8

IntTable   SEGMENT AT 0 use16
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT AT 40h use16
;Здесь размещаются описания переменных
KeyP       db    ?
DwnKeyP    db    ?
NullPrc    db    ?
PriceB1    db    ?
PriceB2    db    ?
PriceB3    db    ?
PriceB4    db    ?
Blink      db    ?
CurrEff    db    ?
SumPrice   db    3 dup (?)
Mode       db    ?
MsgItem    db    ?
TxtPrice   db    ?
StrtStp    db    ?
CapsLock   db    ?
RusLat     db    ?
Shift      db    ?
KbdImage   db    8 dup (?)
Msg1       db    MaxLen+1 dup (?)
Price1     db    PriceLen+1 dup (?)
Msg2       db    MaxLen+1 dup (?)
Price2     db    PriceLen+1 dup (?)
Msg3       db    MaxLen+1 dup (?)
Price3     db    PriceLen+1 dup (?)
Msg4       db    MaxLen+1 dup (?)
Price4     db    PriceLen+1 dup (?)
TimeShow   db    TimeLen+1 dup (?)    
ShowOrg    dw    ?
CursorPos  db    ?
BlinkFlag  db    ?
NumMode    db    ?
CurrAddr   dw    ?
CurrPos    dw    ?
CurrLen    dw    ?
KeyPress   db    ?
CurrKey    db    ?
OldKey     db    ?
MsgShown   dw    ?
RandNumber dw    ?
Multiplier dw    ?
Multi2     dw    ?
Count      dw    ?
CurrMsg    db    ?
MsgForOut  db    ColCount*IndCount dup (?)
MsgForPrep db    ColCount*MaxLen dup (?)
Space      db    ColCount*IndCount dup (?)
CurrLength dw    ?
TimeShow1  db    TimeLen+1 dup (?)
TimeShow2  db    TimeLen+1 dup (?)
TimeShow3  db    TimeLen+1 dup (?)
TimeShow4  db    TimeLen+1 dup (?)
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 500h use16
;Задайте необходимый размер стека
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант
Symbols:   db    000h, 000h, 000h, 000h, 000h, 000h    ; 
           db    03Eh, 051h, 049h, 045h, 03Eh, 000h    ;0
           db    044h, 042h, 07Fh, 041h, 040h, 000h    ;1
           db    042h, 061h, 051h, 049h, 046h, 000h    ;2
           db    021h, 049h, 04Dh, 04Bh, 031h, 000h    ;3
           db    038h, 024h, 022h, 07Fh, 020h, 000h    ;4
           db    04Fh, 049h, 049h, 049h, 031h, 000h    ;5
           db    03Eh, 049h, 049h, 049h, 032h, 000h    ;6
           db    001h, 061h, 011h, 009h, 007h, 000h    ;7
           db    036h, 049h, 049h, 049h, 036h, 000h    ;8
           db    026h, 049h, 049h, 049h, 03Eh, 000h    ;9
           db    03Ch, 042h, 042h, 03Eh, 040h, 000h    ;а
           db    03Ch, 04Ah, 04Ah, 031h, 000h, 000h    ;б
           db    07Eh, 04Ah, 04Ah, 034h, 000h, 000h    ;в
           db    024h, 052h, 04Ah, 024h, 000h, 000h    ;г
           db    0C0h, 07Ch, 042h, 07Eh, 0C0h, 000h    ;д
           db    03Ch, 052h, 052h, 052h, 05Ch, 000h    ;е
           db    07Eh, 008h, 07Eh, 008h, 07Eh, 000h    ;ж
           db    024h, 042h, 052h, 052h, 02Ch, 000h    ;з
           db    07Eh, 020h, 010h, 008h, 07Eh, 000h    ;и
           db    07Ch, 021h, 011h, 009h, 07Ch, 000h    ;й
           db    07Eh, 010h, 018h, 024h, 042h, 000h    ;к
           db    078h, 004h, 002h, 002h, 07Eh, 000h    ;л
           db    07Eh, 004h, 018h, 004h, 07Eh, 000h    ;м
           db    07Eh, 010h, 010h, 010h, 07Eh, 000h    ;н
           db    03Ch, 042h, 042h, 042h, 03Ch, 000h    ;о
           db    07Eh, 002h, 002h, 002h, 07Eh, 000h    ;п
           db    0FEh, 022h, 022h, 022h, 01Ch, 000h    ;р
           db    03Ch, 042h, 042h, 042h, 024h, 000h    ;с
           db    07Eh, 002h, 07Eh, 002h, 07Ch, 000h    ;т
           db    026h, 048h, 048h, 048h, 03Eh, 000h    ;у
           db    01Ch, 022h, 0FEh, 022h, 01Ch, 000h    ;ф
           db    042h, 024h, 018h, 024h, 042h, 000h    ;х
           db    07Eh, 040h, 040h, 07Eh, 0C0h, 000h    ;ц
           db    00Eh, 010h, 010h, 010h, 07Eh, 000h    ;ч
           db    07Eh, 040h, 07Eh, 040h, 07Eh, 000h    ;ш
           db    07Eh, 040h, 07Eh, 040h, 07Eh, 0C0h    ;щ
           db    002h, 07Eh, 048h, 048h, 030h, 000h    ;ъ
           db    07Eh, 048h, 030h, 000h, 07Eh, 000h    ;ы
           db    000h, 07Eh, 048h, 048h, 030h, 000h    ;ь
           db    024h, 042h, 052h, 052h, 03Ch, 000h    ;э
           db    07Eh, 010h, 03Eh, 042h, 07Ch, 000h    ;ю
           db    00Ch, 052h, 032h, 012h, 07Eh, 000h    ;я
           db    000h, 040h, 000h, 000h, 000h, 000h    ;.
           db    000h, 080h, 040h, 000h, 000h, 000h    ;,
           db    000h, 080h, 048h, 000h, 000h, 000h    ;;
           db    000h, 000h, 048h, 000h, 000h, 000h    ;:
           db    000h, 003h, 000h, 000h, 000h, 000h    ;'
           db    000h, 003h, 000h, 003h, 000h, 000h    ;"
           db    000h, 000h, 000h, 03Eh, 041h, 000h    ;(
           db    000h, 041h, 03Eh, 000h, 000h, 000h    ;)
           db    000h, 008h, 01Ch, 008h, 000h, 000h    ;+
           db    000h, 028h, 028h, 028h, 028h, 000h    ;=
           db    000h, 000h, 05Fh, 000h, 000h, 000h    ;!
           db    002h, 001h, 051h, 009h, 006h, 000h    ;?
           db    000h, 008h, 014h, 022h, 000h, 000h    ;<
           db    000h, 022h, 014h, 008h, 000h, 000h    ;>
           db    026h, 049h, 07Fh, 049h, 032h, 000h    ;$
           db    000h, 000h, 000h, 000h, 000h, 000h    ;
           db    07Eh, 011h, 011h, 011h, 07Eh, 000h    ;A
           db    07Fh, 049h, 049h, 049h, 031h, 000h    ;Б
           db    07Fh, 049h, 049h, 049h, 036h, 000h    ;В
           db    07Fh, 001h, 001h, 001h, 001h, 000h    ;Г
           db    0C0h, 07Eh, 041h, 041h, 07Fh, 0C0h    ;Д
           db    07Fh, 049h, 049h, 049h, 041h, 000h    ;Е
           db    07Fh, 008h, 07Fh, 008h, 07Fh, 000h    ;Ж
           db    022h, 041h, 049h, 049h, 036h, 000h    ;З
           db    07Fh, 020h, 010h, 008h, 07Fh, 000h    ;И
           db    07Eh, 020h, 013h, 008h, 07Eh, 000h    ;Й
           db    07Fh, 008h, 008h, 014h, 063h, 000h    ;К
           db    07Ch, 002h, 001h, 001h, 07Fh, 000h    ;Л
           db    07Fh, 002h, 00Ch, 002h, 07Fh, 000h    ;М
           db    07Fh, 008h, 008h, 008h, 07Fh, 000h    ;Н
           db    03Eh, 041h, 041h, 041h, 03Eh, 000h    ;О
           db    07Fh, 001h, 001h, 001h, 07Fh, 000h    ;П
           db    07Fh, 011h, 011h, 011h, 00Eh, 000h    ;Р
           db    03Eh, 041h, 041h, 041h, 022h, 000h    ;С
           db    001h, 001h, 07Fh, 001h, 001h, 000h    ;Т
           db    027h, 048h, 048h, 048h, 03Fh, 000h    ;У
           db    01Eh, 021h, 07Fh, 021h, 01Eh, 000h    ;Ф
           db    063h, 014h, 008h, 014h, 063h, 000h    ;Х
           db    07Fh, 040h, 040h, 040h, 07Fh, 0C0h    ;Ц
           db    00Fh, 010h, 010h, 010h, 07Fh, 000h    ;Ч
           db    07Fh, 040h, 07Fh, 040h, 07Fh, 000h    ;Ш
           db    07Fh, 040h, 07Fh, 040h, 07Fh, 0C0h    ;Щ
           db    001h, 07Fh, 048h, 048h, 030h, 000h    ;Ъ
           db    07Fh, 048h, 048h, 030h, 07Fh, 000h    ;Ы
           db    07Fh, 048h, 048h, 048h, 030h, 000h    ;Ь
           db    022h, 041h, 049h, 049h, 03Eh, 000h    ;Э
           db    07Fh, 008h, 03Fh, 041h, 07Eh, 000h    ;Ю
           db    00Eh, 051h, 031h, 011h, 07Fh, 000h    ;Я
           db    000h, 010h, 010h, 010h, 010h, 000h    ;-
           db    022h, 015h, 02Ah, 054h, 022h, 000h    ;%
           db    036h, 049h, 059h, 026h, 050h, 000h    ;&
           db    080h, 080h, 080h, 080h, 080h, 000h    ;_
           db    000h, 00Ah, 004h, 00Ah, 000h, 000h    ;*
           db    000h, 002h, 004h, 000h, 000h, 000h    ;`
           db    000h, 000h, 000h, 07Fh, 041h, 000h    ;[
           db    000h, 041h, 07Fh, 000h, 000h, 000h    ;]
           db    024h, 07Eh, 024h, 07Eh, 024h, 000h    ;#
           db    004h, 002h, 001h, 002h, 004h, 000h    ;^
           db    002h, 004h, 008h, 010h, 020h, 040h    ;\
           db    004h, 002h, 002h, 004h, 004h, 002h    ;~
           db    000h, 000h, 008h, 036h, 041h, 000h    ;{
           db    000h, 041h, 036h, 008h, 000h, 000h    ;}
           db    040h, 020h, 010h, 008h, 004h, 002h    ;/
           db    03Ch, 042h, 042h, 03Eh, 040h, 000h    ;a
           db    07Eh, 04Ah, 04Ah, 04Ah, 034h, 000h    ;b
           db    03Ch, 042h, 042h, 042h, 024h, 000h    ;c
           db    038h, 044h, 044h, 048h, 07Eh, 000h    ;d
           db    03Ch, 052h, 052h, 052h, 04Ch, 000h    ;e
           db    020h, 0FCh, 022h, 002h, 004h, 000h    ;f
           db    01Ch, 0A2h, 0A2h, 0A2h, 07Ch, 000h    ;g
           db    07Eh, 008h, 004h, 004h, 078h, 000h    ;h
           db    000h, 044h, 07Dh, 040h, 000h, 000h    ;i
           db    000h, 042h, 082h, 082h, 07Eh, 000h    ;j
           db    07Fh, 010h, 028h, 044h, 000h, 000h    ;k
           db    000h, 041h, 07Fh, 040h, 000h, 000h    ;l
           db    07Eh, 002h, 07Eh, 002h, 07Ch, 000h    ;m
           db    07Eh, 004h, 002h, 002h, 07Ch, 000h    ;n
           db    03Ch, 042h, 042h, 042h, 03Ch, 000h    ;o
           db    0FEh, 042h, 042h, 042h, 03Ch, 000h    ;p
           db    03Ch, 042h, 042h, 024h, 0FEh, 000h    ;q
           db    07Eh, 004h, 002h, 002h, 00Ch, 000h    ;r
           db    024h, 04Ah, 04Ah, 052h, 024h, 000h    ;s
           db    004h, 03Eh, 044h, 044h, 020h, 000h    ;t
           db    03Eh, 040h, 040h, 020h, 07Eh, 000h    ;u
           db    01Eh, 020h, 040h, 020h, 01Eh, 000h    ;v
           db    03Eh, 040h, 03Eh, 040h, 03Eh, 000h    ;w
           db    042h, 024h, 018h, 024h, 042h, 000h    ;x
           db    01Eh, 0A0h, 0A0h, 0A0h, 07Eh, 000h    ;y
           db    042h, 062h, 052h, 04Ah, 046h, 000h    ;z
           db    07Eh, 011h, 011h, 011h, 07Eh, 000h    ;A
           db    07Fh, 049h, 049h, 049h, 036h, 000h    ;B
           db    03Eh, 041h, 041h, 041h, 022h, 000h    ;C
           db    07Fh, 041h, 041h, 041h, 03Eh, 000h    ;D
           db    07Fh, 049h, 049h, 049h, 041h, 000h    ;E
           db    07Fh, 009h, 009h, 009h, 001h, 000h    ;F
           db    03Eh, 041h, 049h, 049h, 03Ah, 000h    ;G
           db    07Fh, 008h, 008h, 008h, 07Fh, 000h    ;H
           db    000h, 041h, 07Fh, 041h, 000h, 000h    ;I
           db    023h, 041h, 041h, 041h, 03Fh, 000h    ;J
           db    07Fh, 008h, 008h, 014h, 063h, 000h    ;K
           db    07Fh, 040h, 040h, 040h, 040h, 000h    ;L
           db    07Fh, 002h, 00Ch, 002h, 07Fh, 000h    ;M
           db    07Fh, 002h, 004h, 008h, 07Fh, 000h    ;N
           db    03Eh, 041h, 041h, 041h, 03Eh, 000h    ;O
           db    07Fh, 011h, 011h, 011h, 00Eh, 000h    ;P
           db    07Fh, 011h, 011h, 011h, 00Eh, 000h    ;Q
           db    07Fh, 011h, 031h, 051h, 00Eh, 000h    ;R
           db    026h, 049h, 049h, 049h, 032h, 000h    ;S
           db    001h, 001h, 07Fh, 001h, 001h, 000h    ;T
           db    03Fh, 040h, 040h, 040h, 03Fh, 000h    ;U
           db    01Fh, 020h, 040h, 020h, 01Fh, 000h    ;V
           db    03Fh, 040h, 03Fh, 040h, 03Fh, 000h    ;W
           db    063h, 014h, 008h, 014h, 063h, 000h    ;X
           db    007h, 008h, 070h, 008h, 007h, 000h    ;Y
           db    061h, 051h, 049h, 045h, 043h, 000h    ;Z
InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data,es:Data
Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,InitData
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop

;Здесь размещается код программы
           call  Initialize
Ring:      
           call  ReadState
           call  CheckInd
           and   al,Mode
           jnz   Show
           call  GetCurrAddr
           call  ReadKeyb
           call  FormKey
           call  KeyControl
           call  BuildData
           call  PaintEdit
           jmp   Finish                  
Show:      mov   al,StrtStp
           or    al,al
           jnz   StartShow
           xor   al,al
           out   2,al
           jmp   Finish
StartShow: call  ShowMsg
Finish:    jmp   Ring


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrepareMsg proc  near
           xor   dx,dx
           lea   di,MsgForPrep
           mov   ah,CurrMsg
           lea   bx,Msg1
           or    ah,ah
NxtMsg1:   
           jz    EndOfCalc
           add   bx,MaxLen+1+PriceLen+1
           dec   ah           
           jmp   NxtMsg1
EndOfCalc: 
           mov   al,[bx]
           or    al,al
           jz    Exit10
           lea   si,Symbols
           xor   ah,ah
           mov   dx,ax
           shl   ax,2
           add   ax,dx
           add   ax,dx
           add   si,ax
           mov   cx,3
Nxt:       
           mov   ax,es:[si]
           mov   [di],ax
           add   di,2
           add   si,2
           loop  Nxt
           inc   bx
           jmp   EndOfCalc
Exit10:    
           mov   cx,ColCount*IndCount
           xor   al,al
Nxt12:     
           mov   [di],al
           inc   di
           loop  Nxt12
           lea   dx,MsgForPrep
           sub   di,dx
           mov   CurrLength,di
           ret           
PrepareMsg endp

PreparePrc proc  near
           lea   di,PriceB1
           lea   bx,Price1
           mov   ch,4
NxtPrice:  xor   al,al
           mov   [di],al
           mov   ax,[bx]
           cmp   ah,0
           je    OneDgt
           dec   al
           mov   cl,al
           shl   al,3
           add   al,cl
           add   al,cl
           dec   ah
           add   al,ah
           mov   [di],al
           jmp   PP1
OneDgt:    cmp   al,0
           je    PP1
           dec   al
           mov   [di],al
PP1:       add   bx,PriceLen+1+MaxLen+1
           inc   di
           dec   ch
           jnz   NxtPrice
           ret
PreparePrc endp

RunStr     proc  near
InfLoop:
           push  cx
           mov   cx,20000
           call  Delay
           pop   cx
           lea   bx,MsgForOut
           add   bx,di
           inc   Blink
           cmp   Blink,16
           jb    RS4
           mov   Blink,0
RS4:       mov   ch,1
OutNextInd:
           mov   al,0
           out   1,al
           mov   al,ch
           out   2,al 
           mov   cl,1
OutNextCol:
           mov   al,0
           out   1,al
           mov   al,[bx]
           cmp   CurrEff,1
           jne   RS3
           not   al
           jmp   RSOut
RS3:       cmp   CurrEff,2
           jne   RSOut
           cmp   Blink,8
           jb    RSOut
           xor   al,al
RSOut:     out   0,al
           mov   al,cl
           out   1,al
           shl   cl,1
           inc   bx
           cmp   cl,64
           jb    OutNextCol 
           shl   ch,1
           jnc   OutNextInd          
           call  ReadState
           mov   al,Mode
           or    al,al
           jz    RSExit
           mov   al,StrtStp
           or    al,al
           jz    RSExit
           inc   di
           cmp   di,CurrLength
           jnz   InfLoop
RSExit:    ret
RunStr     endp

;;;;;;;;;;;;;;;;;;;;;;;;;;

ShowMsg    proc  near      
NxtLoop:   mov   CurrMsg,0
           mov   CurrEff,0
           mov   NullPrc,0
           call  PreparePrc
NxtM:      lea   bx,PriceB1
           add   bl,CurrMsg
           adc   bh,0
           mov   al,[bx]
           or    al,al
           jnz   SM2
           mov   al,1
           mov   cl,CurrMsg
           shl   al,cl
           or    NullPrc,al
           cmp   NullPrc,00001111b
           jne   EndIter
           jmp   NxtLoop
SM2:       dec   al
           mov   [bx],al
           call  PrepareMsg
           call  Random
           xor   di,di
           call  RunStr
EndIter:   xor   di,di
          ; inc   CurrEff
          ; cmp   CurrEff,3
          ; jb    SM1
          ; mov   CurrEff,0
           call  ReadState
           mov   al,Mode
           or    al,al
           jz    Exit11
           mov   al,StrtStp
           or    al,al
           jz    Exit11
SM1:       inc   CurrMsg
           cmp   CurrMsg,4
           jb    NxtM
           mov   CurrMsg,0
           jmp   NxtM
Exit11:    
           ret
ShowMsg    endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;
           
Delay      proc  near
DelayLoop:
           inc   cx
           dec   cx
           inc   cx
           dec   cx
           loop  DelayLoop
           ret
Delay      endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;

Random     proc  near
           mov   ax,Multiplier
           mul   Multi2
           mov   Multiplier,ax
           and   ah,00000011b
           cmp   ah,3
           jb    RNDExit
           xor   ah,ah
RNDExit:   mov   CurrEff,ah
           ret
Random     endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


KeyControl proc  near
           mov   al,CurrKey
           mov   ah,MsgItem
           and   ah,010h
           mov   bl,TxtPrice
           and   bl,010h
           or    ah,bl
           jz    Exit4
           cmp   al,11
           jb    Exit4
           cmp   al,58
           ja    Exit4
           xor   al,al
           mov   CurrKey,al
Exit4:     ret
KeyControl endp

SysKeys    proc  near
           cmp   al,62
           jne   Nxt1
           not   RusLat
           ret
Nxt1:      cmp   al,63
           jne   Nxt2
           not   Shift
           ret
Nxt2:      cmp   al,64
           jne   Exit1
           not   CapsLock
Exit1:     ret
SysKeys    endp

DecCurPos  proc  near
           or    bx,bx
           jz    Exit2
           test  CursorPos,002h
           jz    DecPos
           cmp   ShowOrg,2
           jb    EndStr
           sub   ShowOrg,2
           shl   CursorPos,1
           dec   bx
           ret
EndStr:    cmp   ShowOrg,0
           je    DecPos
           shl   CursorPos,1
           dec   ShowOrg
           jnz   EndStr
DecPos:    shr   CursorPos,1
           dec   bx
Exit2:     ret   
DecCurPos  endp

IncCurPos  proc  near
           cmp   bx,dx
           jnb   Exit5
           add   si,bx
           mov   al,[si]
           or    al,al
           jz    Exit5
           test  CursorPos,080h
           jz    IncrPos
           inc   ShowOrg
           shr   CursorPos,1
           ret
IncrPos:   shl   CursorPos,1
           inc   bx
Exit5:     ret
IncCurPos  endp

BackSpace  proc  near
           or    bx,bx
           jz    Exit6
           add   si,bx
           dec   si
NxtSym:    mov   al,[si+1]
           mov   [si],al
           inc   si
           or    al,al
           jnz   NxtSym
           inc   si
           call  DecCurPos
Exit6:     ret   
BackSpace  endp

CharKey    proc  near
           mov   di,bx          
CK2:       cmp   bx,dx
           jnb   Exit3
           cmp   BYTE PTR [si+bx],0
           je    CK1
           inc   bx
           jmp   CK2
CK1:       add   si,di
           mov   ah,al
           cmp   al,57
           ja    Write
           cmp   al,10
           jbe   Write
           cmp   al,42
           ja    Sym
           mov   bl,CapsLock
           xor   bl,Shift
           jz    RL
           add   ah,48
RL:        cmp   RusLat,0
           jne   Write
           cmp   al,36
           ja    Exit3
           or    bl,bl
           jz    RL2
           sub   ah,22
RL2:       add   ah,95
           jmp   Write
Sym:       cmp   Shift,0
           je    Write
           add   ah,48           
Write:     mov   al,[si]
           mov   [si],ah
           mov   ah,al
           inc   si
           or    al,al
           jnz   Write
           mov   Shift,0
           test  CursorPos,080h
           jz    IncPos
           inc   ShowOrg
           ret
IncPos:    shl   CursorPos,1
Exit3:     ret
CharKey    endp

BuildData  proc  near
           mov   al,CurrKey
           or    al,al
           jz    Exit
           cmp   al,OldKey
           je    OldK    
           mov   KeyP,-1
           mov   DwnKeyP,-1
OldK:      inc   KeyP
           cmp   KeyP,0
           je    Form
           cmp   KeyP,KeyPause
           jb    Exit
           mov   KeyP,KeyPause
           inc   DwnKeyP
           cmp   DwnKeyP,0
           je    Form
           cmp   DwnKeyP,DownKeyP
           jb    Exit
           mov   DwnKeyP,-1
Form:      cmp   al,61
           jbe   NotSysKey
           call  SysKeys
           ret
NotSysKey: mov   si,CurrAddr
           mov   dx,CurrLen
           mov   bh,CursorPos
           mov   bl,0FFh
NxtDigt:   inc   bl
           sar   bh,1   
           jnc   NxtDigt
           xor   bh,bh
           add   bx,ShowOrg
           cmp   al,61
           jne   NotBack
           call  BackSpace
           ret
NotBack:   cmp   al,59
           jne   NotLeft
           call  DecCurPos
           ret
NotLeft:   cmp   al,60
           jne   NotRight
           call  IncCurPos
           ret
NotRight:  call  CharKey
Exit:      ret
BuildData  endp

FormKey    proc  near
           xor   al,al
           mov   cx,8
           lea   bx,KbdImage
NxtLine:   mov   dl,[bx]
           or    dl,dl
           jz    EndLoop
           xor   ah,ah
          ; mov   ah,0FFh
NxtDgt:    inc   ah
           sal   dl,1
           jnc   NxtDgt
           add   al,ah
           jmp   KeyExist
EndLoop:   add   al,8
           inc   bx
           loop  NxtLine
           cmp   al,64
           jne   KeyExist
           xor   al,al
KeyExist:  mov   ah,CurrKey
           mov   OldKey,ah
           mov   CurrKey,al
           ret
FormKey    endp

GetCurrAddr proc  near
           mov   ah,MsgItem
           test  ah,010h
           jnz   TmShow
           lea   si,Msg1
NxtMsg:    shr   ah,1
           jc    CurMsg
           add   si,MaxLen+1+PriceLen+1
           jmp   NxtMsg
CurMsg:    cmp   TxtPrice,0
           jne   Price
           mov   CurrLen,MaxLen
           mov   CurrAddr,si
           ret
Price:     mov   CurrLen,PriceLen
           add   si,MaxLen+1
           mov   CurrAddr,si
           ret
TmShow:    lea   si,TimeShow
           mov   CurrAddr,si
           mov   CurrLen,TimeLen
           ret
GetCurrAddr endp

PaintEdit  proc  near
           push  di
           mov   si,CurrAddr
           mov   dx,CurrLen
           mov   di,ShowOrg
           sub   dx,di
           inc   dx
           add   si,di
           mov   ch,1
NxtInd:    xor   ah,ah
           lea   bx,Symbols
           mov   al,[si]
           or    al,al
           jz    Output
           inc   si
           mov   di,ax
           shl   ax,2
           add   ax,di
           add   ax,di
           add   bx,ax
Output:    call  OutSymAt
           shl   ch,1
           jnc   NxtInd
Quit:      pop   di
           ret
PaintEdit  endp

ReadKeyb   proc  near
           xor   dx,dx        ;Передача параметра
           lea   si,KbdImage         ;Загрузка адреса,
           mov   cx,LENGTH KbdImage  ;счётчика циклов
           mov   bl,001h             ;и номера исходной строки
KI4:       mov   al,bl       ;Выбор строки
           out   3,al        ;Активация строки
           in    al,0        ;Ввод строки
           and   al,0FFh     ;Включено?
           jz    KI1         ;Переход, если нет
           call  KillVibr    ;Гашение дребезга
          ; mov   [si],al     ;Запись строки
          ; cmp   KeyPress,0
          ; jne   KI6
          ; mov   KeyPress,al
          ; mov   di,KeyPause
          ; jmp   KI5
KI6:      ; cmp   KeyPress,al
          ; jne   KI2
          ; mov   di,DownKeyP
KI5:      ; call  PaintEdit
          ; dec   di
          ; jnz   KI5
          ; ret
KI1:       mov   [si],al     ;Запись строки
KI3:       inc   si          ;Модификация адреса
           rol   bl,1        ;и номера строки
           loop  KI4         ;Все строки? Переход, если нет
KI2:      ; xor   al,al
          ; mov   KeyPress,al
           ret
ReadKeyb   endp

CheckInd   proc  near
           mov   al,MsgItem
           mov   cl,020h
           and   ch,TxtPrice
           jz    Txt
           shl   cl,1
Txt:       or    al,cl
           out   4,al
           mov   al,1
           mov   cl,Mode
           or    cl,cl
           jz    OutInd
           shl   al,1
           mov   cl,StrtStp
           or    cl,cl
           jz    OutInd
           shl   al,1
OutInd:    mov   cl,CapsLock
           and   cl,080h
           or    al,cl
           mov   cl,RusLat
           and   cl,040h
           or    al,cl
           out   5,al
           ret
CheckInd   endp

ClearPos   proc  near
           xor   dh,dh
           mov   BYTE PTR ShowOrg,dh
           mov   BYTE PTR ShowOrg+1,dh
           inc   dh
           mov   CursorPos,dh
           ret
ClearPos   endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReadState  proc  near
           xor   al,al
           mov   Mode,al
           mov   dx,1
           in    al,dx
           call  KillVibr
           mov   ch,0FFh
           mov   dl,Mode
           test  al,040h
           jz    NotMode
          ; mov   CurrMsg,0
           mov   Mode,ch
NotMode:   mov   cl,Mode
           cmp   dl,Mode
           je    RS1
           call  ClearPos
RS1:       or    cl,cl
           jnz   RSShow
           test  al,020h
           mov   dl,TxtPrice
           mov   TxtPrice,cl
           jz    NotTxtPrc
           mov   TxtPrice,ch
NotTxtPrc: cmp   dl,TxtPrice
           je    RS2
           call  ClearPos
RS2:       test  al,01Fh
           jz    NotItem
           and   al,01Fh
           mov   dl,MsgItem
           mov   MsgItem,al
           cmp   dl,MsgItem
           je    NotItem
           call  ClearPos
NotItem:   ret           
RSShow:    test  al,080h
           mov   StrtStp,ch
           jnz   NotStrtStp
           xor   cl,cl
           mov   StrtStp,cl
NotStrtStp:ret
ReadState  endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OutSymAt   proc  near
           push  cx
           xor   al,al
           out   1,al
           mov   al,ch
           out   2,al
           mov   cl,1
           cmp   ch,001h
           jne   OtherPos
           cmp   ch,CursorPos
           jne   OtherPos
           mov   al,es:[bx]
           add   BlinkFlag,7
           cmp   BlinkFlag,080h
           jb    NotBlink2
           not   al
NotBlink2: out   0,al
           mov   al,cl
           out   1,al
           inc   bx
           shl   cl,1
OtherPos:  shl   ch,1
NxtCol:    xor   al,al
           out   1,al
           mov   al,es:[bx]
           cmp   ch,CursorPos
           jne   NotBlink
           cmp   cl,020h
           jne   NotBlink
           add   BlinkFlag,8
           cmp   BlinkFlag,080h
           jb    NotBlink
           not   al
NotBlink:  out   0,al
           mov   al,cl
           out   1,al
           inc   bx
           shl   cl,1
           cmp   cl,64
           jb    NxtCol
          ; jnc   NxtCol
           pop   cx
           ret
OutSymAt   endp

Initialize proc  near
           xor   ax,ax
           mov   Mode,al
           mov   StrtStp,al
           mov   TxtPrice,al
           mov   CapsLock,al
           mov   RusLat,al
           not   RusLat
           mov   ShowOrg,ax
           mov   Shift,al
           mov   BlinkFlag,al
           mov   cx,(MaxLen+1+PriceLen+1)*MaxMsg+TimeLen+1
           lea   bx,Msg1
I1:        mov   [bx],al
           inc   bx
           loop  I1
           mov   CurrAddr,ax
           mov   CurrPos,ax
           mov   CurrLen,ax
           mov   KeyPress,al
           mov   al,01h
           mov   MsgItem,al
           mov   CursorPos,al
           mov   cx,ColCount*IndCount
           lea   bx,MsgForOut
           xor   al,al
Nxt11:     mov   [bx],al
           inc   bx
           loop  Nxt11
           mov   ax,40
           mov   MsgShown,ax
           xor   ax,ax
           mov   RandNumber,ax
           mov   Count,0
           mov   CurrMsg,0
           mov   Multi2,13
           ret           
Initialize endp

NMax       EQU   0FFh
KillVibr   proc  near
           push  cx
NotEqual:  mov   ah,al
           mov   cx,NMax
NextIn:    in    al,dx
           cmp   ah,al
           jne   NotEqual
           loop  NextIn
           mov   al,ah
           pop   cx
           ret
KillVibr   endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
