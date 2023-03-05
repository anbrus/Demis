.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

VPortKL  = 0
VxPortKl = 2
VxPortYpr = 0
VxPortYpr1= 1 
VPortInd = 1
VPortInd1 = 2
KonstSlM = 343 ;константа для случайного числа
KonstSlD = 17  ;константа для случайного числа
TimerSl  = 100  ;Задержка для случайного числа
;ZaderT   = 1  ;задержка таймера

Data   SEGMENT AT 10h use16

; obrkl  db 16 dup(?)
 perVs  dw  ?
 NomKl  db  ?   ;номер нажатой кнопки
 kolIgr  db ?   ;Кол-во игроков
 KolRaz  db ?   ;сложность (кол-во разрядности)
 StartKl db ?   ;флаг начала работы
 Prosm  db  ?   ;флаг просмотра
 Gotov  Db  ?   ;флаг готовности
 Pl1    db  ?   ;флаг перехода на 1 кадр просмотра
 NachSl db  ?   ;флаг начального условия для формирования случайного числа
 sluc   db  ?   ;случайное число
 sl     dw  ?   ;переменная для случайного числа 
 TimerSL1 db ?  ;переменная для задержки формирования случайного числа
 FlagSl   db ?  ;флаг формирования случайного числа 
 zadSl   db  ?  ;задержка
 zadT    dw  ?  ;переменная задержки таймера
 nazKL   db ?   ;флаг нажатия клавиши
 OtpKL   db  ?  ;флаг отпускания кнопки   
 errk   db  ?  ;флаг ошибки ввода с клавиатуры
 nachErr db ?  ;флаг работы после ошибки
 ArrChislaSl  db 3 Dup(?); массив случайного числа
 ArrChislaKl  db 3 Dup(?); массив числа набранного с клавиатуры
 ysp          db ? ;флаг успешного завершения операции
 TimerP       dw ? ;переменная таймера 
 FlagT        db ? ;флаг таймера
 chislo       db 3 dup(?) ;
 nomInd       db ? ;номер индикатора который загорается
 NachR        db ? ;начало работы цикла
 NachP        db ? ;начало просмотра
 Flagperep    db ? ;флаг переполнения
 ArrRez       dw 5 dup(?) ;массив результата
 ArrRez1      dw 5 dup(?) ;массив результата
 nommin       dw ? ;номер минимального числа
 vs           dw ? ;вспомогательная константа
 OtsRez       dw 5 dup(?) ;отсортированный массив результата по времени 
 OtsRezN      db 10 dup(?) ;отсортированный массив результата по номеру игрока
 FlagPer      db ? ;флаг перехода
 FlagNPer     db ? ;флаг нажатия кнопки перехода
 NMkol        db ? ;множитель на число для случайного числа 
  
 nachpros     db ? ;флаг начало просмотра
 vrem         dw ? ;время просмотра
 mesto        db ? ;место
 kadr         db ? ;номер кадра просмотра
 
 kol          db ?
 zaderT       dw ?
 zad          dw ?

 
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 200h use16
;Задайте необходимый размер стека
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант
InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data,es:Data
 
 Image     db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh
           db    07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h
           
 Image1    db    0bFh,08Ch,0F6h,0DEh,0CDh,0DBh,0FBh,08Eh
           db    0FFh,0DFh,0EFh,0F9h,0B3h,0FCh,0F3h,0E3h
           
 ImageKl   db    06Fh,073h,073h

 Sbros     proc near   ;процедура обнуления индикаторов
           mov dx,2
           mov cx,3
           mov al,03Fh
       s2: out dx,al
           inc dx
           loop s2
           ret
 Sbros     endp
 
 SbrosInd  proc near     ;сброс индикаторов
           Test StartKl,0FFh
           jz sbr1
           Test KolRaz,0FFh
           jz sbr3
           mov al,0
           mov dx,4
           cmp KolRaz,1
           jne sbr2
           mov cx,2
      sbr4:out dx,al
           dec dx
           loop sbr4
           jmp sbr1
      sbr2:cmp KolRaz,2
           jne sbr1       
           out dx,al
           jmp sbr1
      sbr3:mov cx,3
      sbr5:out dx,al
           dec dx
           loop sbr5     
      sbr1:ret
 SbrosInd  endp
 
 Init      proc near   ;процедура начальной инициaлизации параметров
           mov vrem,0
           mov startkl,0
           mov OtpKL,0FFh
           mov koligr,0
           mov NachP,0
           mov NachSl,0
           mov TimerSL1,0
           mov TimerP,0   
           mov ysp,0
           mov nazKL,0 
           mov NachR,0
           mov FlagNPer,0
           mov nacherr,0
           mov NMkol,1
;           mov TimerP1,0
           mov nomInd,1
           mov nachpros,0
           mov kadr,1
           
           mov zaderT,9
           mov ax,zaderT
           mov zadT,ax
           
           mov FlagPer,0FFh
           mov FlagPerep,0h
           mov FlagSl,0
           mov cx,3
           xor si,si
       i2: mov ArrChislaKl[si],0
           mov ArrChislasl[si],0
           inc si
           loop i2
           mov cx,5
           xor si,si
       i3: mov ArrRez[si],0
           inc si
           loop i3  
           RET
 Init      endp

 ObKL      proc near   ;Процедура получения образа клавиатуры
           xor si,si
           xor dx,dx
           mov nazKL,0h
           mov dl,8
           xor bx,bx
           mov cx,4
       o2: mov al,dl
           out VPortKL,al
           in al,VxPortKl
           test al,0FFh
           jz o1
           test OtpKL,0FFh
           jz o33
           mov OtpKL,0
           shl al,4
           push cx
           mov cx,4
        o5:shl al,1
           jc o4
           inc dh
           loop o5
           jmp o1
        o4:;mov cx,perVs
           pop cx
           mov NomKl,dh
           push di
           push si
           push cx
           call ObrKLN 
           pop cx
           pop si
           pop di
           jmp o33 
       o1: add dh,4
           shr dl,1
           loop o2    
           mov OtpKL,0FFh    
       o33:ret
 ObKL      endp
 
 ObrKLN    proc near   ;процедура сдвига нажатых клавиш
           test StartKL,0FFh
           jz ob3
           Test FlagSl,0FFh
           jz ob3 
           test ysp,0FFh
           jnz ob3
           mov cx,2
           mov di,2
           mov si,1
      ob7: mov al,ArrChislaKl[si]
           mov ArrChislaKl[di],al
           dec si
           dec di
           loop ob7
           mov nazKL,0FFh
           inc si
           mov al,NomKL
           mov ArrChislaKl[si],al
           mov nomkl,0
           jmp ob3
       ob3:ret
 ObrKLN    endp
 
 yprkl    proc near    ;процедура обработки управляющих кнопок
          xor ax,ax
          in al,VxPortYpr 
          test al,0FFh
          jz oo14
          
          mov cx,4
          mov KolIgr,0
          mov dl,1
      oo3:shr al,1
          jnc oo2
          mov KolIgr,dl
      oo2:inc dl
          loop oo3   
          
          mov cx,3
          mov KolRaz,0
          mov dl,1
      oo4:shr al,1
          jnc oo6
          mov KolRaz,dl
      oo6:inc dl
          loop oo4   
          shr al,1
          jnc oo5
          mov StartKl,0FFh
          mov nachpros,0
          jmp oo16
          
      oo5:mov StartKl,0
          jmp oo27
     oo14:mov kolIgr,0
          mov kolraz,0
     oo16:mov Prosm,0
     oo27:ret 
 yprkl    endp
 
 sbrarr   proc near
          mov cx,3
          xor si,si
      sb1:mov ArrChislaKL[si],0
          mov ArrChislaSL[si],0
          inc si 
          loop sb1
          ret
 sbrarr   endp
 
 perNkadr proc near
          test Startkl,0FFh
          jnz per1
          test Koligr,0FFh
          jz per1
          test FlagNPer,0FFh
          jnz per1
          mov Pl1,0FFh
          mov FlagNPer,0FFh
          mov al,kadr
          test NachP,0FFh
          jz per21
          inc al
          cmp al,koligr
          jbe per21
          mov al,1
    per21:mov kadr,al
          mov FlagPer,0FFh
     per1:ret 
 perNkadr endp
 
 yprkll   proc     ;процедура обработки управляющих кнопок
 
          xor ax,ax
          in al,VxPortYpr1
          test al,0FFh
          jz oo7
          
          shr al,1
          jnc oo8
          mov vs,ax
          mov Gotov,0FFh
          mov ysp,0
          mov FlagSl,0
          mov TimerP,0
          mov ax,zadert
          mov zadt,ax
          call SbrosInd
          call sbrarr
          mov ax,vs
          jmp oo12
      oo8:mov Gotov,0h 
      
     oo12:shr al,1
          jnc oo9
          mov vs,ax 
          call perNkadr
          mov ax,vs
          jmp oo13
     oo9: mov PL1,0
          mov FlagnPer,0
     oo13:shl al,2
          mov cx,2
          mov dl,1
     oo11:shl al,1
          jnc oo10
          mov Prosm,dl
          jmp oo15
     oo10:inc dl
          loop oo11       
          jmp oo15
       oo7:mov Prosm,0        
           mov gotov,0
           mov PL1,0
      oo15:RET       
 yprkll   endp
 
 
 Sluch     Proc near       ;Формирование случайного числа
           test StartKl,0FFh
           jz s10
           test NachSl,0FFh
           jnz s3
           mov sl,9
           mov NachSl,0FFh
       s3: mov al,NMkol
           inc al
           cmp al,255
           je s99
           jmp s98
       s99:mov al,1
       s98:mov NMkol,al    
           xor ah,ah       ;Xk=Xk-1*343/13 
           mov dx,KonstSlM
           mov ax,sl
           mul dx
           mov bx,KonstSlD
           Idiv bx
           cmp dx,0
           jz s4
           mov sl,dx
           and dx,0Fh
           mov sluc,dl
           jmp s10
      s4:  inc dx      
      s10: ret
 Sluch     endp 
 

 VSluch   proc near          ;процедура вывода на индикаторы
           test StartKl,0FFh
           jz v1
           Test Gotov,0FFh
           jz v1
           Test KolRaz,0FFh
           jz v1
           mov al,timerSl
           mov zadsl,al
           xor di,di
        v3:push cx
           push dx
           push di
           call Sluch
           pop di
           pop dx
           pop cx
           xor ah,ah
           mov al,sluc
           mov dl,NMkol
           mul dl
           call PerHc
           mov cl,KolRaz           
           mov dx,2
           xor si,si
           xor di,di
           xor bx,bx
       v13:
           mov bl,chislo[si]
           mov ArrchislaSl[si],bl
           mov di,bx
           mov al,cs:Image[di]
           out dx,al
           inc dx
           inc si
           inc di
           dec cl
           test cl,0FFh
           jnz v13
           mov al,zadsl
           dec al
           jz v1
           mov zadsl,al
           xor di,di
           mov FlagSl,0FFh
           jmp v3
        v1:ret
 VSluch   endp

 ErrKl     proc near         ;обработка ошибки с клавиш
           mov errk,0
           Test StartKl,0FFh
           jz e7
           xor cl,cl
           in al,VxPortYpr 
           test al,07Fh
           jz e7
           mov ch,4
        e3:shr al,1
           jnc e2
           inc cl
        e2:dec ch
           jnz e3
           cmp cl,1
           jbe e4
           mov errk,0FFh
           mov nachErr,0FFh
           jmp e7
        e4:mov errk,0
           mov ch,3
           xor cl,cl      
        e6:shr al,1
           jnc e5
           inc cl
        e5:dec ch
           jnz e6 
           cmp cl,1  
           jbe e7
           mov errk,0FFh
           mov nomInd,1
           mov nachErr,0FFh
           
        e7:in al,VxPortYpr1
           test al,0FFh
           jz e1
           mov cx,2
           xor bl,bl
        e9:shl al,1
           jnc e8
           inc bl
        e8:loop e9
           cmp bl,2
           jne e1
           mov errk,0FFh
           mov nomInd,1
           mov nachErr,0FFh
        e1:ret
 ErrKl     endp

 VErrkl    proc near          ;вывод ошибки на индикаторы
           Test nachErr,0FFh
           jz ve4
           Test Errk,0FFh
           jz ve1
           mov FlagSl,0h
           mov ysp,0
           mov dx,2
           mov cx,3
           mov si,0
       ve2:mov al,cs:imageKL[si]
           out dx,al
           inc dx
           inc si
           loop ve2
           jmp ve4
        ve1:call sbros
            mov nachErr,0
            mov nomInd,1
        ve4:RET       
 VErrkl    endp
 
 Osncmp    proc near          ;сравнение данных
           Test StartKl,0FFh
           jz zs1
           Test FlagSl,0FFh
           jz zs1
           test nazKL,0FFh
           jz zs1
           test ysp,0FFh
           jnz zs1
           xor si,si
           mov cl,KolRaz
       zs3:mov al,ArrchislaSl[si]
           cmp al,ArrchislaKL[si]
           jne zs2
           mov ysp,0FFh
           inc si
           inc di
           dec cl
           jnz zs3
           jmp zs1
       zs2:mov ysp,0    
       zs1:mov nazKl,0
           ret
 Osncmp    endp 
 
 TimerS   proc near           ;подсчет времени
          Test StartKl,0FFh
          jz t1 
          Test FlagSl,0FFh
          jz t1
          mov ax,zadT
          dec ax
          jnz t4
          mov ax,zaderT
          mov zadT,ax
          jmp t5
      t4: mov zadT,ax
          jmp t3
      t5: mov ax,TimerP
          inc ax
          mov TimerP,ax
          cmp timerP,3E7h
          jne t1 
          mov FlagT,0FFh
          jmp t3
      t1: mov FlagT,0
      t3: ret
 TimerS   endp
 
 PerCh   proc near  ;процедура перевода из 16-10
          cmp ax,99
          ja p4 
          mov cx,2
          mov chislo[2],0
          jmp p5
      p4: mov cx,3
      p5: xor si,si 
      p3: cmp ax,10
          jae p1
          mov chislo[si],al
          jmp p2
      p1: mov dl,10
          div dl
          mov chislo[si],ah    
          xor ah,ah 
          inc si
          loop p3
      p2: ret 
 PerCh    endp
 
 PerHc    proc near
          mov cl,kolRaz
          xor si,si
          mov dl,0
          mov bx,ax
      ph1:mov al,4
          mul dl
          push cx
          mov cl,al
          mov ax,bx
          shr ax,cl
          pop cx
          and al,0Fh
          mov chislo[si],al
          inc si
          inc dl
          mov ax,bx
          dec cl
          test cl,0FFh
          jnz ph1
          ret 
 PerHc    endp
 
; UvRazT   proc near          ;процедура корректировки времени
;          test FlagT,0FFh
;          jnz u1 
;          mov ax,TimerP
;          shl ax,1
;          mov TimerP,ax
;       u1:ret
; UvRazT   endp

 VTimer   proc near          ;процедура вывода таймера на индикаторы
          test FlagT,0FFh
          jnz vt1 
          Test Ysp,0FFh
          jz vt2
;          call UvRazT
          mov ax,TimerP
          call PerCh
          mov FlagPerep,0
          mov dx,2
          xor si,si
          xor di,di
          mov cx,2
          xor bx,bx
      vt3:mov bl,chislo[si]
          mov di,bx
          mov al,cs:Image[di]
          out dx,al
          inc dx
          inc si
          loop vt3
          mov bl,chislo[si]
          mov di,bx
          mov al,cs:Image1[di]
          out dx,al
          jmp vt2
      vt1:mov FlagPerep,0FFh
          mov al,05Fh
          mov cx,3
          mov dx,2
      vt4:out dx,al
          inc dx
          loop vt4
      vt2:ret
 VTimer   endp
 
 KolIgrR  proc near
          Test startkl,0FFh
          jz kr1
          test koligr,0FFh
          jz kr1 
          test ysp,0FFh
          jnz kr2
          test FlagPerep,0FFh
          jz kr1
      kr2:mov al,nomind
          cmp al,kolIgr
          jae kr3
          inc al
          mov nomind,al
          mov NachP,0
          jmp kr1
      kr3:mov nomind,1
          mov NachP,0FFh
      kr1:ret
 KolIgrR  endp 
 
 Vkoligr  proc near
          Test startkl,0FFh
          jz vkr1
          test koligr,0FFh
          jz vkr1 
          mov ysp,0
          mov FlagPerep,0
     vkr4:mov al,1                     
          xor cx,cx
          mov cl,nomind
          cmp cl,1
          jbe vkr3
          dec cl
     vkr2:shl al,1
          loop vkr2
     vkr3:out VPortInd,al
          jmp vkr5
     vkr1:test nachpros,0FFh
          jnz vkr5
          mov al,0
          out VPortInd,al
     vkr5:ret
 Vkoligr  endp
 
 soxrrez  proc near  ;процедура сохранения результата
          Test StartKl,0FFh
          jz so1 
          test koligr,0FFh
          jz so1
          Test Ysp,0FFh
          jz so10
          xor ax,ax
          mov al,nomind
          dec al
          shl al,1
          mov si,ax
          mov bx,TimerP
          mov arrrez[si],bx
          mov ArrRez1[si],bx
          mov FlagSl,0
          mov TimerP,0
          mov cx,3
          xor si,si
       r4:mov ArrChislaSl[si],0
          inc si
          loop r4
          xor cx,cx
     so10:test FlagPerep,0FFH
          jz so1
          xor ax,ax
          mov al,nomind
          dec al
          shl al,1
          mov si,ax
          mov bx,3E7h
          mov arrrez[si],bx
          mov ArrRez1[si],bx
          mov FlagSl,0
          mov cx,3
          xor si,si
       r5:mov ArrChislaSl[si],0
          inc si
          loop r5
      so1:ret
 soxrrez  endp
 
 prIgr    proc near
          test koligr,0FFh 
          jz gr1
          test NachP,0FFh
          jz gr1 
          jmp gr2
      gr1:mov nachpros,0FFh
          mov kol,0
      gr2:ret
 prIgr    endp
 
 sort     proc near         ;сортировка результата
          test startkl,0FFh
          jnz ss1
          test nachpros,0FFh
          jnz ss1
          mov nachpros,0FFh
     ss5: mov cl,koligr
          dec cl
          test cl,0FFh
          jz ss9
          mov bh,kol
          inc bh
          mov kol,bh
          mov nommin,0
          mov ax,arrrez[0]
          mov si,2
     ss4: cmp ax,arrrez[si]
          jbe ss2
          mov ax,arrrez[si]
          mov nommin,si
     ss2: add si,2     
          loop ss4
          mov si,nommin
          mov Arrrez[si],0FFFh
          xor bx,bx
          mov bl,kol
          dec bl
          shl bl,1
          mov si,bx
          mov otsrez[si],ax
          mov cx,nommin
          shr cx,1
          inc cx
          mov al,0
      ss8:add al,1
          loop ss8
     ss7: mov otsrezn[si],al
          mov bl,kol
          cmp bl,koligr
          jne ss5
          jmp ss1
     ss9: call mmm
     ss1: ret
 sort     endp
 
 mmm      proc near
          mov ax,ArrRez[0]
          mov OtsRez[0],ax
          mov otsrezn[0],1              
          ret 
 mmm      endp
 
prosmotr1 proc near          ;основная процедура сортировки данных для просмотра и подготовка к выводу
          Test Startkl,0Ffh
          jnz pr3
          test Koligr,0FFh
          jz pr3
          test prosm,0FFh
          jnz pr2
          call sbros
          mov nomind,1
          jmp pr3
      pr2:cmp prosm,1
          jne pr3
          test NachP,0FFh
          jz pr3
          xor bx,bx
          mov bl,kadr
          dec bl
          shl bl,1
          mov si,bx
          mov al,otsrezn[si]
          mov nomind,al
          mov ax,otsrez[si]
          mov vrem,ax
          mov al,kadr
          mov mesto,al
      pr3:ret
prosmotr1 endp

prosmotr2 proc near          

          Test Startkl,0Ffh
          jnz pp1
          test Koligr,0FFh
          jz pp1
          cmp prosm,2
          jne pp1
          test NachP,0FFh
          jz pp1
          xor bx,bx
          mov bl,Kadr
          mov si,bx
          mov nomind,bl
          ;получение места по номеру игрока
          xor cx,cx
          mov bh,0
          mov cl,koligr
          xor si,si
      pp8:inc bh
          cmp bl,otsrezn[si]
          jne pp4
          xor ax,ax
          mov mesto,bh
          mov ax,otsrez[si]
          mov vrem,ax
          jmp pp1
      pp4:add si,2
          loop pp8    
      pp1:ret 
      
prosmotr2 endp
 
 vProsm   proc near          ;процедура вывода на семисегментные индикаторы и двоичные индикаторы 
 
          test Startkl,0FFh  ;параметров просмотра
          jnz vp1 
          test Koligr,0FFh
          jz vp1
          test NachP,0FFh
          jz vp1
          test Flagper,0FFh
          jz vp1
          mov FlagPer,0h
          mov ax,vrem
          call PerCh
          mov dx,2
          xor si,si
          xor di,di
          mov cx,2
          xor bx,bx
      vp3:mov bl,chislo[si]
          mov di,bx
          mov al,cs:Image[di]
          out dx,al
          inc dx
          inc si
          loop vp3
          mov bl,chislo[si]
          mov di,bx
          mov al,cs:Image1[di]
          out dx,al
          mov al,1
          xor cx,cx
          mov cl,nomind
          dec cl
          test cl,0FFh
          jz vp4
      vp5:shl al,1
          loop vp5
      vp4:mov bl,al
          mov al,16
          mov cl,mesto
          dec cl
          test cl,0FFh
          jz vp6
      vp7:shl al,1
          loop vp7
      vp6:or al,bl
          out VPortInd,al
      vp1:ret
vProsm   endp
 
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           call  Init
       St1:call  ObKL          
           call  yprkl
           call  yprkll
           call  Sluch
           call  VSluch
           call  ErrKl
           call  VErrkl
           call  TimerS
           call  Osncmp
           call  VTimer
           call  soxrrez
           call  KolIgrR
           call  Vkoligr
           call  prIgr
           call  sort
           call  prosmotr1
           call  prosmotr2
           call  vProsm
           jmp st1
           ;Здесь размещается код программы


;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
