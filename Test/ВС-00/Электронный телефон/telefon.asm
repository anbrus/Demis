.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   10240
;курсовая студента Хлапова Алексея
ColDig     EQU   8
BlackN     EQU   1
WhiteN     EQU   2
ColSp      equ  10   
Empty      EQU   0
Cmd        EQU   1
Dig        EQU   2
Error      EQU   3


Zdem       EQU   1
Vizov      EQU   2
Svobodno   EQU   4
Zanato     EQU   8
Otboy      EQU   16
Zvonok     EQU   32
razgovor   equ   64

CmdReset   equ   10
CmdRept    equ   11
CmdPrSP    equ   1
CmdSP      equ   2
CmdNxSP    equ   4
CmdPrBS    equ   8
CmdBS      equ   16
CmdNxBS    equ   32
CmdClSP    equ   64
CmdClBS    equ   128

PtInd1     EQU 0
Ptind2     EQU 010h

PtKbr1     equ 8
PtKbr2     equ 18h

PtCmd1     equ 9
PtCmd2     equ 19h

PtTru1     equ 0
PtTru2     equ 10h

PtDio1     equ 0ah
PtDio2     equ 1ah


MesYes     equ   0ffh
mesNo      equ   000h

PtLin1     equ   0bh
PtLin2     equ   1bh

MesUp      equ   1
MesDw      equ   0

m          equ   1
WIm        equ   40*m
Wpa        equ   60*m
Wz         equ   800*m

Data       SEGMENT AT 40h use16

KbrScan1   db 4 dup (?)
CmdScan1   db ?
TrScan1    db ?
Mode1      db ?
sosto1     db ?
abon1      db ?
oldMod1    db ?
NewDig1    db ?
NewCmd1    db ?
CurNum1    db ColDig dup (?)
CurCol1    db ?

MesCol1    db ?
WaitIm1    dw ?
MesDig1    db ?
MesSos1    db ?
MesSig1    db ?

SpNum1     db ColSP dup ( 1 + ColDig dup (?))
SpCur1     db ?

BSNum1     db ColSP dup ( 1 + ColDig dup (?))
BSCur1     db ?

Status1    db ?


KbrScan2   db 4 dup (?)
CmdScan2   db ?
TrScan2    db ?
Mode2      db ?
sosto2     db ?
abon2      db ?
oldmod2    db ?
NewDig2    db ?
NewCmd2    db ?
CurNum2    db ColDig dup (?)
CurCol2    db ?

MesCol2    db ?
WaitIm2    dw ?
MesDig2    db ?
MesSos2    db ?
MesSig2    db ?

SpNum2     db ColSP dup ( 1 + ColDig dup (?))
SpCur2     db ?

BSNum2     db ColSP dup ( 1 + ColDig dup (?))
BSCur2     db ?

Status2    db ?

OldCol1    db ?
OldNum1    db ColDig dup (?)
OldCol2    db ?
OldNum2    db ColDig dup (?)
ColZvon    dw ?

Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 1024h use16
;Задайте необходимый размер стека
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант
InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант
Image      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh    ;Образы 10-тиричных символов
tel1       db    1,2,3,4,5,6
tel2       db    6,5,4,3,2,1
           ASSUME cs:Code,ds:Data,es:Data
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           call main 
;Здесь размещается код программы
main       proc 
           call inittel1
           call inittel2
l_1main:   
           call telef1
           call telef2
           call ATS
           jmp l_1main 
           
           ret
endp           

inittel    macro CurCol,Sosto,MesCol,MesSos,Mesdig,MesSig,SP,SpCur,BS,BSCur,abon,oldCol
           local l_1init,l_2init
           mov abon,zdem
           mov CurCol,0
           mov MesCol,0
           mov sosto,zdem 
           mov MesSos,MesNo
           mov Mesdig,0
           mov MesSig,MesDw
           mov cl,(ColSp)*(1 + ColDig)
           mov bx,0
l_1init:   mov sp + bx,0
           inc bx
           loop l_1init
           
           mov cl,(ColSp)*(1 + ColDig)
           mov bx,0
l_2init:   mov BS + bx,0
           inc bx
           loop l_2init
           
           mov SpCur,255
           mov BSCur,255
           mov OldCol,0
           endm

inittel1   proc 
           inittel CurCol1,Sosto1,MesCol1,MesSos1,Mesdig1,MesSig1,SpNum1,SpCur1,BSNum1,BSCur1,abon1,OldCol1
           ret
           endp

inittel2   proc 
           inittel CurCol2,Sosto2,MesCol2,MesSos2,Mesdig2,MesSig2,SpNum2,SpCur2,BSNum2,BSCur2,abon2,OldCol2
           ret
           endp





telef1     proc ;процедура обработки телефона1
           call ScanKbr1
           call ScanCmd1
           call ChkKey1
           call line1
           call ScanTrub1
           call ObrTr1
           call ObrKey1
           call ObrKbr1 
           call ObrDig1
           call MesNum1
           call ObrCmd1   
                  
           call ObrSost1
           
           ret
           endp

telef2     proc ;процедура обработки телефона2
           call ScanKbr2
           call ScanCmd2
           call ChkKey2
           call line2
           call ScanTrub2
           call ObrTr2
           call ObrKey2
           call ObrKbr2
           call ObrDig2
           call MesNum2
           call ObrCmd2
           
           call ObrSost2
           ret
endp


ScanKbr    macro  KbrScan,PtKbr ; Сканирование клавиатуры
           local l_1ScKb
           mov bx,1
           mov cx,4
           lea si,KbrScan
           xor dx,dx
           mov dl,PtKbr
l_1ScKb:   mov al,bl
           out dx,al
           in al,dx
           mov [si],al
           inc si
           shl bl,1
           loop l_1ScKb
            
           endm
          
ScanKbr1   proc   ; Сканирование клавиатуры
           ScanKbr  KbrScan1,PtKbr1
           ret
endp  

ScanKbr2   proc
           ScanKbr  KbrScan2,PtKbr2
           ret
endp     

ScanCmd    macro PtCmd,CmdScan
           mov dl,PtCmd
           in al,dx
           mov CmdScan,al
           endm  

ScanCmd1   proc
           ScanCmd  PtCmd1,CmdScan1
           ret
endp           

ScanCmd2   proc
           ScanCmd  PtCmd2,CmdScan2
           ret
endp      

ChkKey     macro KbrScan,Mode,CmdScan
           local l_2Chk,l_1ChK,l_5ChK,l_3ChK,l_4Chk,l_6Chk,l_7Chk
          
           mov dl,0
           lea si,KbrScan
           mov bx,4
           
l_2Chk:    mov al,[si]
           mov cx,3
l_1ChK:    shr al,1
           adc dl,0
           loop  l_1ChK
           inc si
           dec bx
           jnz l_2Chk
           
           cmp dl,1
           jnz l_5ChK
           mov Mode,Dig
                               
l_5ChK:    mov bl,0
           mov al,CmdScan
           mov cl,8
l_3ChK:    shr al,1
           adc bl,0
           loop l_3ChK
           cmp bl,1
           jnz l_4Chk
           mov mode,Cmd
l_4Chk:    add dl,bl
           cmp dl,1
           jbe l_6Chk
           mov Mode,Error 
           jmp l_7Chk
l_6Chk:    cmp dl,0
           jnz l_7Chk
           mov mode,empty        
l_7Chk:   
            endm

ChkKey1    proc
           ChkKey KbrScan1,Mode1,CmdScan1       
           ret
           endp

ChkKey2    proc
           ChkKey KbrScan2,Mode2,CmdScan2       
           ret
           endp

line       macro sosto,ChkZdem,ChViz,ChkSvob,ChkRazg,ChkZvon
           local l_2li,l_3li,l_4li,l_5li,l_1li 
           
           cmp sosto,zdem
           jnz l_2li
           call  ChkZdem
           jmp l_1li
l_2li:     cmp sosto,vizov
           jnz l_3li
           call  ChViz
           jmp l_1li 
l_3li:     cmp sosto,svobodno
           jnz l_4li
           call ChkSvob
           jmp l_1li
l_4li:     cmp sosto,razgovor
           jnz l_5li
           call ChkRazg
           jmp l_1li
l_5li:     cmp sosto,zvonok
           jnz l_1li
           call ChkZvon
           jmp l_1li                                            
l_1li:    
           endm           

line1      proc
           line  sosto1,ChkZdem1,ChViz1,ChkSvob1,ChkRazg1,ChkZvon1                                         
           ret
endp           

line2      proc
           line  sosto2,ChkZdem2,ChViz2,ChkSvob2,ChkRazg2,ChkZvon2                                
           ret
endp

ChkZdem    macro abon,sosto,CurNum,CurCol,tel,Status,DispDig,SpCur,SpNum,OldCol,OldNum
           local l_1ChkZde,l_2ChkZde,l_4ObrSP,l_2ObrSP,l_3ObrSP,l_1ObrSP,l_9ChkZde,l_10ChkZde
           cmp abon,zvonok
           jnz l_1ChkZde
           mov cl,6
           mov bx,0
l_2ChkZde: mov al,tel+bx
           mov CurNum+bx,al
           inc bx
           loop l_2ChkZde
           mov CurCol,6
           mov sosto,zvonok
           
                                ;проверка на наличие такого номера в справочнике
           mov SpCur,0
           mov dx,ColSP
           xor cx,cx
           mov bx,0

l_4ObrSP:  mov cl,ColDig
           lea si,SpNum
           add si,bx
           inc si
           lea di,CurNum
l_2ObrSP:  cmps SpNum,CurNum
           jnz l_3ObrSP
           loop l_2ObrSP
           
           jmp  l_1ObrSP ;нашли такой номер
           
l_3ObrSP:  add bx,1 + ColDig
           dec dx  
           jnz  l_4ObrSP     
                         ;этого номера нет в справочнике
           mov al,CurCol
           mov OldCol,al
           xor cx,cx
           mov cl,ColDig
           mov bx,0
l_10ChkZde:mov al,tel+bx
           mov oldNum+bx,al
           inc bx
           loop l_10ChkZde
           
           mov status,WhiteN
           jmp l_9ChkZde
l_1ObrSP:  mov status,BlackN         
l_9ChkZde: call DispDig
l_1ChkZde: 

           endm


ChkZdem1   proc
           ChkZdem abon1,sosto1,CurNum1,CurCol1,tel2,Status1,DispDig1,SpCur1,BSNum1,OldCol1,OldNum1
           ret
endp 
    
ChkZdem2   proc
           ChkZdem abon2,sosto2,CurNum2,CurCol2,tel1,Status2,DispDig2,SpCur2,BSNum2,OldCol2,OldNum2
           ret
endp    
       
ChViz      macro abon,sosto,CurCol,OldCol,OldNum,tel
           local l_1ChViz,l_2ChViz,l_3ChViz,l_4ChViz 
           cmp abon,svobodno
           jnz l_1ChViz
           mov sosto,svobodno
           jmp l_3ChViz 
l_1ChViz:  cmp abon,zanato
           jnz l_2ChViz
           mov sosto,zanato 
           
l_3ChViz:  mov al,CurCol
           mov OldCol,al
           xor cx,cx
           mov cl,ColDig
           mov bx,0
l_4ChViz:  mov al,tel+bx
           mov oldNum+bx,al
           inc bx
           loop l_4ChViz
                      
l_2ChViz:  
           endm      
       
ChViz1     proc
           ChViz abon1,sosto1,CurCol1,OldCol1,OldNum1,tel2
           ret
           endp

ChViz2     proc
           ChViz abon2,sosto2,CurCol2,OldCol2,OldNum2,tel1 
           ret
           endp
      
ChkSvob    macro abon,sosto
           local l_1ChkSv
           cmp abon,razgovor
           jnz l_1ChkSv
           mov sosto,razgovor
l_1ChkSv:  
           endm        

ChkSvob1   proc
           ChkSvob abon1,sosto1
           ret
endp   

ChkSvob2   proc
           ChkSvob abon2,sosto2 
           ret
endp  

ChkRazg    macro abon,sosto
           local l_1ChkRaz
           cmp abon,otboy
           jnz l_1ChkRaz
           
           mov sosto,otboy
l_1ChkRaz: 
           endm 

ChkRazg1   proc
           ChkRazg abon1,sosto1
           ret
           endp   
      
ChkRazg2   proc
           ChkRazg abon2,sosto2
           ret
           endp

ChkZvon    macro abon,sosto,Status,reset,MesCol
           local l_1ChkZvo,l_2ChkZvo  
           cmp abon,Zdem
           jnz l_1ChkZvo
           cmp Status,WhiteN
           jz l_2ChkZvo
           call reset
l_2ChkZvo: mov MesCol,0
           mov sosto,zdem
l_1ChkZvo: 
           endm
 
ChkZvon1   proc
           ChkZvon abon1,sosto1,Status1,reset1,MesCol1
           ret
           endp      

ChkZvon2   proc
           ChkZvon abon2,sosto2,Status2,reset2,MesCol2
           ret
           endp

ScanTrub   macro PtTru,TrScan
           mov dx,PtTru
           in al,dx
           mov TrScan,al
           endm

ScanTrub1  proc
           ScanTrub PtTru1,TrScan1
           ret
endp           

ScanTrub2  proc
           ScanTrub PtTru2,TrScan2
           ret
endp

ObrSost    macro mode,oldmod,sosto,ptDio,Status,PtLin
           local l_1ObrSost,l_2ObrSost,l_3ObrSost
           mov al,mode
           mov oldmod,al
           mov al,sosto
           out ptDio,al
           cmp sosto,zvonok
           jnz l_2ObrSost 
           cmp Status,WhiteN
           jnz l_1ObrSost
           inc ColZvon
           test ColZvon,0001000000000000b
           jnz l_3ObrSost 
           mov al,2
           out PtLin,al
           jmp l_1ObrSost
l_3ObrSost:mov al,0
           out PtLin,al
           jmp  l_1ObrSost  
l_2ObrSost:cmp sosto,vizov
           jz l_1ObrSost
           mov al,0
           out PtLin,al                
l_1ObrSost:endm 

ObrSost1   proc
           ObrSost mode1,oldmod1,sosto1,ptDio1,Status1,PtLin1
           ret
endp   

ObrSost2   proc
           ObrSost mode2,oldmod2,sosto2,ptDio2,Status2,PtLin2
           ret
endp         

ObrTr      macro TrScan,sosto,Reset,Status
           local l_2ObrTr,l_3ObrTr,l_4ObrTr,l_1ObrTr,l_5ObrTr
           
           cmp TrScan,0
           jnz l_2ObrTr
           cmp sosto,zvonok
           jz l_1ObrTr
           cmp sosto,zdem
           jz l_1ObrTr
           call reset
           mov sosto,zdem
           jmp l_1ObrTr
l_5ObrTr:  cmp sosto,zdem
           jz l_1ObrTr
           call Reset
           mov sosto,zdem
           jmp l_1ObrTr
           
l_2ObrTr:  cmp sosto,zdem
           jnz l_3ObrTr
           mov sosto,vizov
           jmp l_1ObrTr 

l_3ObrTr:  cmp sosto,zvonok
           jnz l_4ObrTr
           mov sosto,razgovor
           jmp l_1ObrTr 
l_4ObrTr:                              
l_1ObrTr:           
           endm 

ObrTr1     proc
           ObrTr TrScan1,sosto1,Reset1,Status1          
           ret
endp           

ObrTr2     proc
           ObrTr TrScan2,sosto2,Reset2,Status2          
           ret
endp

reset      macro PtInd,CurCol,MesCol,MesSos,PtLi,SpCur
           local l_1res
           mov al,0
           xor dx,dx
           mov dl,PtInd
           mov cx,8
l_1res:    out dx,al
           inc dx
           loop l_1res
           mov CurCol,0
           mov MesCol,0
           mov MesSos,MesNo
           xor dx,dx
           Mov Dl,PtLi
           mov al,MesDw
           out dx,al
           
           mov SpCur,255
           endm

reset1     proc
           reset PtInd1,CurCol1,MesCol1,MesSos1,PtLin1,SpCur1
           ret
           endp     

reset2     proc
           reset PtInd2,CurCol2,MesCol2,MesSos2,PtLin2,SpCur2
           ret
           endp      


ObrKbr     macro mode,sosto,oldMod,KbrScan,NewCmd,NewDig,SPCur,BSCur
           local l_1ObrKbr,l_2ObrKbr,l_3ObrKbr,l_4ObrKbr,l_5ObrKbr,l_10ObrKbr
           cmp mode,empty

           jz l_10ObrKbr
                               
           cmp OldMod,empty
           jnz l_10ObrKbr
           cmp mode,error
           jz l_10ObrKbr
           
           mov al,sosto
           cmp al,oldMod
           jz l_10ObrKbr
           
           lea si,KbrScan
           mov al,[si+3]
           cmp al,1
           jnz l_2ObrKbr
           mov SPCur,255
           mov BSCur,255
           mov mode,cmd
           mov NewCmd,CmdRept
l_10ObrKbr:jmp l_1ObrKbr
l_2ObrKbr: cmp al,4
           jnz l_3ObrKbr
           mov SPCur,255
           mov BSCur,255
           mov mode,cmd
           mov NewCmd,CmdReset
           jmp l_1ObrKbr           
l_3ObrKbr: cmp al,2
           jnz l_4ObrKbr
           mov SPCur,255
           mov BSCur,255
           mov mode,dig
           mov NewDig,0
           jmp l_1ObrKbr  
l_4ObrKbr: xor ax,ax
           mov al,[si+2]
           shl ax,3
           or al,[si+1]
           shl ax,3
           or al,[si]
           cmp ax,0
           jz l_1ObrKbr
           mov cx,10
l_5ObrKbr: dec cx
           shr ax,1
           jnc l_5ObrKbr
           mov NewDig,cl
           mov SPCur,255
           mov BSCur,255
l_1ObrKbr:
           endm 

ObrKbr1    proc
           ObrKbr mode1,sosto1,oldMod1,KbrScan1,NewCmd1,NewDig1,SPCur1,BSCur1                      
           ret
           endp   
   
ObrKbr2    proc
           ObrKbr mode2,sosto2,oldMod2,KbrScan2,NewCmd2,NewDig2,SPCur2,BSCur2
           ret
           endp     

ObrKey     macro mode,NewCmd,CmdScan
           local l_1ObrKey 
           cmp mode,empty
           jz l_1ObrKey
           cmp mode,error
           jz l_1ObrKey
           mov al,CmdScan
           cmp al,0
           jz l_1ObrKey
           mov NewCmd,al
           mov mode,Cmd
l_1ObrKey:
           endm           

ObrKey1    proc
           ObrKey mode1,NewCmd1,CmdScan1
           ret
endp           

ObrKey2    proc
           ObrKey mode2,NewCmd2,CmdScan2
           ret
endp   

ObrDig     macro OldMod,mode,CurCol,CurNum,NewDig,DispDig,SpCur,BSCur
           local l_1ObrDi,l_2ObrDi,l_3ObrDi
           cmp OldMod,empty
           jnz l_1ObrDi
           cmp mode,dig
           jnz l_1ObrDi
           
           cmp CurCol,0
           jnz l_2ObrDi
           
           mov bx,0
           xor cx,cx
           mov cl,ColDig
l_3ObrDi:  mov CurNum + bx,0
           inc bx
           loop l_3ObrDi
l_2ObrDi:  cmp CurCol,ColDig
           jz l_1ObrDi
           lea si,CurNum
           xor bx,bx
           mov bl,CurCol
           mov al,NewDig
           mov [si+bx],al
           inc CurCol
           call DispDig
l_1ObrDi:  
           endm

ObrDig1    proc
           ObrDig OldMod1,mode1,CurCol1,CurNum1,NewDig1,DispDig1,SpCur1,BSCur1
           ret
           endp      

ObrDig2    proc
           ObrDig OldMod2,mode2,CurCol2,CurNum2,NewDig2,DispDig2,SpCur2,BSCur2
           ret
           endp       

DispDig    macro PtInd,CurCol,curNum
           local l_1DisD,l_2DisD
           xor cl,cl
           mov cl,ColDig
           mov al,0
           mov dx,PtInd
l_1DisD:   out dx,al
           inc dx
           loop l_1DisD
           
           xor ax,ax
           mov dx,PtInd
           mov cl,CurCol
           lea bx,curNum
l_2DisD:   mov al,[bx]
           mov si,ax
           mov al,image+si
           out dx,al
           inc dx
           inc bx
           loop l_2DisD
                    
           endm

DispDig1   proc
           DispDig PtInd1,CurCol1,curNum1
           
           ret
endp           

DispDig2   proc
           DispDig PtInd2,CurCol2,curNum2
                    
           ret
endp

MesNum     macro sosto,MesSig,PtLin,MesSos,WaitIm,MesCol,CurCol,MesDig,CurNum,mode
           LOCAL l_1mesNu,l_2Mes,l_3Mes,l_4Mes,l_5Mes,l_6Mes,l_7Mes,l_8Mes,l_9Mes,l_10Mes,l_11Mes,l_12Mes
           
           cmp sosto,vizov   ;проверка на состояние VIZOV
           jz l_7Mes
           jmp l_1mesNu
l_7Mes:    cmp MesSos,MesYes ;проверка на состояние посылки числа
           jnz l_9Mes
           jmp l_10Mes
l_9Mes:    jmp l_2Mes           
l_10Mes:   cmp WaitIm,0      ;проверка задержки импульса
           
           jle l_3Mes  
             
   
           cmp mode,empty
           jnz l_8Mes  
           dec WaitIm        ;обработка очередной задержки
           jmp l_1MesNu
l_8Mes:    sub WaitIm,5  
           jmp l_1MesNu
l_3Mes:    cmp MesDig,0      ;проверка на окончание посылок импульсов
           jz l_4Mes
           cmp MesSig,mesUp
           jnz l_5Mes
            
           mov WaitIm,Wpa 
           mov MesSig,mesDw
           xor dx,dx
           mov dl,PtLin
           mov al,mesSig
           out dx,al
           jmp l_1MesNu
             
l_5Mes:    dec MesDig
           mov WaitIm,WIm 
           mov MesSig,mesUp
           xor dx,dx
           mov dl,PtLin
           mov al,mesSig
           out dx,al
           jmp l_1MesNu
l_4Mes:    cmp mesSig,MesUp
           jnz l_6Mes
           
           mov WaitIm,Wz 
           mov MesSig,mesDw
           xor dx,dx
           mov dl,PtLin
           mov al,mesSig
           out dx,al
           jmp l_1MesNu  
l_6Mes:    Mov MesSos,mesNo 
           inc mesCol 
           jmp l_1MesNu                                    
l_2Mes:    mov al,MesCol
           cmp al,CurCol
           jae l_1MesNu
           mov MesSos,MesYes ;инициализация посылки цифры
           mov WaitIm,WIm
           
           xor bx,bx
           mov bl,mesCol
           mov al,CurNum+bx
           cmp al,0
           jz l_11Mes
           jmp l_12Mes
l_11Mes:   mov al,10
l_12Mes:   dec al
           mov MesDig,al
           mov MesSig,mesUp
           xor dx,dx
           mov dl,PtLin
           mov al,mesSig
           out dx,al
           
l_1MesNu:           
           endm     

MesNum1    proc
           MesNum sosto1,MesSig1,PtLin1,MesSos1,WaitIm1,MesCol1,CurCol1,MesDig1,CurNum1,mode1
           ret
           endp
           
MesNum2    proc
           MesNum sosto2,MesSig2,PtLin2,MesSos2,WaitIm2,MesCol2,CurCol2,MesDig2,CurNum2,mode2
           ret
           endp   

ObrCmd     macro OldMod,mode,NewCmd,ObrNxSP,ObrPrSP,ObrSP,ObrNxBS,ObrPrBS,ObrBS,ObrRep,ObrRes,ObrClSP,ObrClBS
           local l_1ObrCmd,l_2ObrCmd,l_3ObrCmd,l_4ObrCmd,l_5ObrCmd,l_6ObrCmd,l_7ObrCmd,l_8ObrCmd,l_9ObrCmd,l_10ObrCmd,l_11ObrCmd,l_12ObrCmd,l_13ObrCmd
           cmp OldMod,empty
           jnz l_13ObrCmd
           jmp l_12ObrCmd
l_13ObrCmd:jmp l_1ObrCmd           
l_12ObrCmd: cmp mode,Cmd
           jnz l_1ObrCmd
           cmp NewCmd,CmdNxSP
           jnz l_2ObrCmd
           call ObrNxSP
           jmp l_1ObrCmd
l_2ObrCmd: cmp NewCmd,CmdPrSP
           jnz l_3ObrCmd
           call ObrPrSP
           jmp l_1ObrCmd  
l_3ObrCmd: cmp NewCmd,CmdSP
           jnz l_4ObrCmd
           call ObrSP
           jmp l_1ObrCmd 
           
l_4ObrCmd: cmp NewCmd,CmdNxBS
           jnz l_5ObrCmd
           call ObrNxBS
           jmp l_1ObrCmd
l_5ObrCmd: cmp NewCmd,CmdPrBS
           jnz l_6ObrCmd
           call ObrPrBS
           jmp l_1ObrCmd  
l_6ObrCmd: cmp NewCmd,CmdBS
           jnz l_7ObrCmd
           call ObrBS
           jmp l_1ObrCmd 
l_7ObrCmd: cmp NewCmd,CmdReset
           jnz l_8ObrCmd
           call ObrRes
           jmp l_1ObrCmd
l_8ObrCmd: cmp NewCmd,CmdRept
           jnz l_9ObrCmd
           call ObrRep
           jmp l_1ObrCmd 
l_9ObrCmd: cmp NewCmd,CmdClSP
           jnz l_10ObrCmd
           call ObrClSP
           jmp l_1ObrCmd 
l_10ObrCmd:cmp NewCmd,CmdClBS
           jnz l_11ObrCmd
           call ObrClBS
           jmp l_1ObrCmd 
l_11ObrCmd:                                                                               
l_1ObrCmd:
           endm   
                   
ObrCmd1    proc
           ObrCmd OldMod1,mode1,NewCmd1,ObrNxSP1,ObrPrSP1,ObrSP1,ObrNxBS1,ObrPrBS1,ObrBS1,ObrRep1,ObrRes1,ObrClSP1,ObrClBS1
           ret
           endp 

ObrCmd2    proc
           ObrCmd OldMod2,mode2,NewCmd2,ObrNxSP2,ObrPrSP2,ObrSP2,ObrNxBS2,ObrPrBS2,ObrBS2,ObrRep2,ObrRes2,ObrClSP2,ObrClBS2
           ret
           endp 

ObrCl      macro SP,SPCur,reset
           local l_1ObrCl,l_2ObrCl 
           cmp SPCur,255            
           jz l_1ObrCl
           xor cx,cx
           xor bx,bx
           mov cl,1+ColDig
           mov bl,SPCur
           mov ax,1+ColDig
           mul bx
           mov bx,ax
l_2ObrCl:  mov sp + bx,0
           inc bx
           loop l_2ObrCl
           call reset
           mov SPCur,255
l_1ObrCl:           
           endm 
           
ObrClSP1   proc
           ObrCl SPNum1,SPCur1,reset1
           ret
           endp  
ObrClSP2   proc
           ObrCl SPNum2,SPCur2,reset2
           ret
           endp 
            
ObrClBS1   proc
           ObrCl BSNum1,BSCur1,reset1
           ret
           endp 
            
ObrClBS2   proc
           ObrCl BSNum2,BSCur2,reset2
           ret
           endp 
        
           
ObrRes1    proc
           call reset1
           ret
           endp
                      
ObrRes2    proc
           call reset2
           ret
           endp
           
ObrRep     macro OldNum,OldCol,CurNum,CurCol,MesCol,reset,DispDig
           local l_1ObrRep,l_2ObrRep
           cmp OldCol,0
           jz l_1ObrRep
           call reset
           mov al,OldCol
           mov curCol,al
           xor cx,cx
           mov cl,Coldig
           mov bx,0
l_2ObrRep: mov al,OldNum+bx
           mov CurNum+bx,al
           inc bx
           loop l_2ObrRep
           call DispDig
l_1ObrRep:                      
           endm   
                       
ObrRep1    proc
           ObrRep OldNum1,OldCol1,CurNum1,CurCol1,MesCol1,reset1,DispDig1
           ret
           endp

ObrRep2    proc
           ObrRep OldNum2,OldCol2,CurNum2,CurCol2,MesCol2,reset2,DispDig2
           ret
           endp

NextSp     macro SpCur,SpNum,CurCol,CurNum,DispDig,reset
           local l_1NeSp,l_2NeSp,l_3NeSp,l_4NeSp,l_5NeSp,l_9NeSp
           
           mov bl,SpCur
           call reset
           mov SpCur,bl
           
           cmp SpCur,255
           jnz l_1NeSp
           
l_1NeSp:   mov cl,0
l_4NeSp:   inc SpCur
           cmp SpCur,ColSp
           jnz l_2NeSp
           mov SpCur,0
l_2NeSp:   xor ax,ax
           xor bx,bx        
           mov al,9
           mov bl,SpCur
           mul bx
           mov bx,ax
           cmp SpNum + bx ,0
           jnz l_3NeSp
           inc cl
           cmp cl,ColSp + 1
           jnz l_4NeSp
           jmp l_5NeSp
l_3NeSp:   mov al,SpNum + bx                ;нашли следующий номер
           mov CurCol,al
           xor cx,cx
           mov cl,ColDig
           mov si,0
           xor ax,ax
           xor bx,bx        
           mov al,9
           mov bl,SpCur
           mul bx
           mov bx,ax
l_9NeSp:   
           inc bx
           mov al,SpNum + bx
           mov Curnum + si,al
           inc si
           loop l_9NeSp
           call DispDig           
l_5NeSp:                   ;ненашли
           endm
           
ObrNxSP1   proc
           NextSp SpCur1,SpNum1,CurCol1,Curnum1,DispDig1,reset1
           ret
           endp 

ObrNxSP2   proc
           NextSp SpCur2,SpNum2,CurCol2,Curnum2,DispDig2,reset2
           ret
           endp           
  
PrefSp     macro SpCur,SpNum,CurCol,CurNum,DispDig,reset
           local l_1PrSp,l_2PrSp,l_3PrSp,l_4PrSp,l_5PrSp,l_9PrSp
           mov bl,SpCur
           call reset
           mov SpCur,bl
           cmp SpCur,255
           jnz l_1PrSp
           mov SpCur,ColSp - 1
l_1PrSp:   mov cl,0
l_4PrSp:   dec SpCur
           cmp SpCur,255
           jnz l_2PrSp
           mov SpCur,ColSp - 1
l_2PrSp:   xor ax,ax
           xor bx,bx        
           mov al,9
           mov bl,SpCur
           mul bx
           mov bx,ax
           cmp SpNum + bx ,0
           jnz l_3PrSp
           inc cl
           cmp cl,ColSp + 1
           jnz l_4PrSp
           jmp l_5PrSp
l_3PrSp:   mov al,SpNum + bx                ;нашли следующий номер
           mov CurCol,al
           xor cx,cx
           mov cl,ColDig
           mov si,0
           xor ax,ax
           xor bx,bx        
           mov al,9
           mov bl,SpCur
           mul bx
           mov bx,ax
l_9PrSp:   
           inc bx
           mov al,SpNum + bx
           mov Curnum + si,al
           inc si
           loop l_9PrSp
           call DispDig           
l_5PrSp:                   ;ненашли
           endm  
           
ObrPrSP1   proc
           PrefSp SpCur1,SpNum1,CurCol1,CurNum1,DispDig1,reset1
           ret
           endp
    
ObrPrSP2   proc
           PrefSp SpCur2,SpNum2,CurCol2,CurNum2,DispDig2,reset2
           ret
           endp           
           
ObrSP      macro CurCol,SpCur,SpNum,CurNum
           local l_1ObrSP,l_2ObrSP,l_3ObrSP,l_4ObrSP,l_5ObrSP,l_6ObrSP,l_7ObrSP,l_10ObrSP,l_11ObrSP
           cmp CurCol,0 ;проверка на пустой номер
           jz l_1ObrSP
                        ;проверка на наличие такого номера в справочнике
           mov SpCur,0
           mov dx,ColSP
           xor cx,cx
           mov bx,0

l_4ObrSP:  mov cl,ColDig
           lea si,SpNum
           add si,bx
           inc si
           lea di,CurNum
l_2ObrSP:  cmps SpNum,CurNum
           jnz l_3ObrSP
           loop l_2ObrSP
           
           jmp  l_1ObrSP ;нашли такой номер
           
l_3ObrSP:  add bx,1 + ColDig
           dec dx  
           jnz  l_4ObrSP     
                         ;этого номера нет в справочнике
           mov bx,0     ;поиск свободной ячейки    
           mov SpCur,0
           mov cl,ColSP
l_6ObrSP:  cmp SpNum + bx,0              
           jz l_5ObrSP 
           add bx,1 + ColDig
           inc SpCur 
           loop l_6ObrSP
           mov al,2
           out 0bh,al
           mov cx,0ffffh
l_11ObrSP: nop
           nop
           nop
           loop l_11ObrSP
           mov al,0
           out 0bh,al
           
           jmp l_1ObrSP               
l_5ObrSP:  mov al,CurCol             ;нашли пустую ячейку 
           mov SpNum + bx,al
           mov  cl,CurCol
           mov si,0
l_7ObrSP:  mov al,CurNum + si
           mov SpNum + bx + si + 1,al
           inc si
           loop l_7ObrSP
           mov ax,0 
           jmp l_10ObrSP                                      
l_1ObrSP:  mov SpCur,255
l_10ObrSP: 
           endm  
         
ObrSP1     proc
           ObrSP CurCol1,SpCur1,SpNum1,CurNum1
           ret
           endp 
           
ObrSP2     proc
           ObrSP CurCol2,SpCur2,SpNum2,CurNum2
           ret
           endp             
           
ObrNxBS1   proc
           NextSp BSCur1,BSNum1,CurCol1,CurNum1,DispDig1,reset1
           ret
           endp 

ObrNxBS2   proc
           NextSp BSCur2,BSNum2,CurCol2,CurNum2,DispDig2,reset2
           ret
           endp 
                      
ObrPrBS1   proc
           PrefSp BSCur1,BSNum1,CurCol1,CurNum1,DispDig1,reset1
           ret
           endp
ObrPrBS2   proc
           PrefSp BSCur2,BSNum2,CurCol2,CurNum2,DispDig2,reset2
           ret
           endp           
           
ObrBS1     proc
           ObrSP CurCol1,BSCur1,BSNum1,CurNum1
           ret
           endp
           
ObrBS2     proc
           ObrSP CurCol2,BSCur2,BSNum2,CurNum2
           ret
           endp            
           
ATS        proc
           cmp sosto1,zdem
           jnz l_20ATS
           cmp sosto2,zdem
           jnz l_20ATS
           mov abon1,zdem
           mov abon2,zdem
l_20ATS:   cmp sosto1,razgovor
           jnz l_1ATS
           cmp sosto2,razgovor
           jnz l_1ATS
           mov abon1,razgovor
           mov abon2,razgovor
           jmp l_100ats
           cmp sosto1,zdem
           jnz l_1ATS
           cmp abon1,zvonok
           jz l_1ATS
           mov abon1,zdem
           jmp l_10ats
l_1ATS:    cmp sosto1,vizov
           jnz l_2ATS
           cmp MesCol1,6
           jnz l_2ATS
           mov cl,6
           mov bx,0
l_9ATS:    mov al,CurNum1+bx           
           cmp al,tel2+bx
           jnz l_2ATS
           inc bx
           loop l_9ATS
           cmp sosto2,zdem
           jnz l_3ats
           mov abon2,zvonok
           mov abon1,svobodno
           jmp l_10ats
l_3ats:    mov abon1,zanato       
           jmp l_10ats 
           
l_2ATS:    cmp sosto1,razgovor       
           jnz l_4ats
           cmp sosto2,svobodno
           jnz l_5ats
           mov abon2,razgovor
           jmp l_10ats
          
l_5ats:    cmp sosto2,razgovor
           jz l_4ats
           mov abon1,otboy
           jmp l_10ats           
l_4ats:    cmp sosto1,zvonok
           jnz l_10ats
           cmp sosto2,svobodno
           jz l_10ats
           mov abon1,zdem
           jmp l_10ats       
l_10ats:   


           cmp sosto2,zdem
           jnz l_11ATS
           cmp abon2,zvonok
           jz l_11ATS
           mov abon2,zdem
           jmp l_100ats
l_11ATS:   cmp sosto2,vizov
           jnz l_12ATS
           
           cmp MesCol2,6
           jnz l_12ATS
           mov cl,6
           mov bx,0
l_19ATS:   mov al,CurNum2+bx           
           cmp al,tel1+bx
           jnz l_12ATS
           inc bx
           loop l_19ATS
           cmp sosto1,zdem
           jnz l_13ats
           mov abon1,zvonok
           mov abon2,svobodno
           jmp l_100ats
l_13ats:   mov abon2,zanato       
           jmp l_100ats 
           
l_12ATS:   cmp sosto2,razgovor       
           jnz l_14ats
           cmp sosto1,svobodno
           jnz l_15ats
           mov abon1,razgovor
           jmp l_100ats
l_15ats:   cmp sosto1,razgovor
           jz l_14ats 
           mov abon2,otboy
           jmp l_100ats           
l_14ats:   cmp sosto2,zvonok
           jnz l_100ats
           cmp sosto1,svobodno
           jz l_100ats
           mov abon2,zdem
           jmp l_100ats   
l_100ats:
           ret
           endp                                                          
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END

