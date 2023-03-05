.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096
Predel     EQU   0D8h
zad400     EQU   0ffffh;
zad800     EQU   0ffffh; 
zad1600    EQU   0ffffh;


Data       SEGMENT AT 40h use16

MasTemp     dw    1610 dup (?)
MaxMasTemp  dw    1610 dup (?)
MaxMasTime  dw    1610 dup (?)
MinMasTemp  dw    1610 dup (?)
MinMasTime  dw    1610 dup (?) 
MaxMasCount dw    (?)
MinMasCount dw    (?)
MaxTemp     dw    (?)
MaxTime     dw    (?)
MinTemp     dw    (?)
MinTime     dw    (?)
flag        db    (?)         ;флаг кнопки сброса
Temp        dw    (?)
Temp2       dw    (?)
TempTi      dw    (?)
Tempsi      dw    (?)
TempTiEnd   dw    (?)
TempSiEnd   dw    (?)
Diskret     dw    (?)        ;время дискретизации
Zader       dw    (?)
Data       ENDS


Stk        SEGMENT AT 4fffh use16
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;Здесь размещаются описания констант

InitData   ENDS

Code       SEGMENT use16
           ASSUME cs:Code,ds:Data,es:Data
           ; образы символов "0"..-.."9"
images      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh           
images1     db    0bFh,08Ch,0f6h,0dEh,0cDh,0dBh,0fBh,08Eh,0ffh,0dFh                
           
OJIDANIE   PROC  near
           mov   Diskret,400
           mov   bx,zad400
           Mov   Zader,bx
           mov   al,4
           out   25h,al
           mov   flag,0
           mov   al,0        ;очищаем все индикаторы
           mov   dx,1
a:         out   dx,al
           inc   dx
           cmp   dx,10
           jne   a
a1:        
           in    al,51h
           cmp   al,4
           jne   az1
           mov   Diskret,400
           mov   bx,zad400
           mov   Zader,bx
           out   25h,al
az1:       cmp   al,8
           jne   az2
           mov   Diskret,800
           mov   bx,zad800
           mov   Zader,bx     
           out   25h,al      
az2:       cmp   al,16
           jne   az3
           mov   Diskret,1600
           mov   bx,zad1600
           mov   Zader,bx     
           out   25h,al      
           
az3:           
           mov   al,1        ;инициализировали АЦП(подали стартовый импульс)
           out   0,al
           dec   al
           out   0,al
           
a2:        in    al,1        ;ждём готовности устр-ва(Ready)
           cmp   al,1
           jne   a2
           
           in    al,0
           cmp   al,Predel     ;0d8h - значение температуры = 1296(почти 1300)
           jna   a1
           ret
OJIDANIE   ENDP
;--------------------------------------------------------------------
Zaderjka   proc  near
           push  cx
           mov   cx,Zader      ;число для задержки
z1:        dec   cx
           inc   cx
           dec   cx
           cmp   cx,0
           jne   z1
           pop   cx
           ret
Zaderjka   endp
;----------------------передаём значение времени в секундах через BX----------------------------------------------

lopp1      proc  near
           xor   dx,dx
           mov   ax,bx
           mov   cx,4
           div   cx          ;в АХ-результат в DX-остаток
           ret
lopp1      endp           

lopp2      proc  near
           xor   dx,dx
           mov   ax,bx
           mov   cx,2
           div   cx          ;в АХ-результат в DX-остаток
           ret
lopp2      endp        

lopp3      proc  near
           mov   di,dx
           mov   al,images[di]
           out   8,al
           mov   al,images[0]
           out   9,al
           mov   ax,bx      
           ret
lopp3      endp           


lopp4      proc  near
           mov   bx,ax
           mov   ax,dx
           xor   dx,dx
           mov   cx,10
           div   cx
           mov   di,ax
           mov   al,images[di]
           out   8,al
           mov   di,dx
           mov   al,images[di]
           out   9,al
           mov   ax,bx
           ret
lopp4      endp           
;---------------------------------------------------------------------------------------------
Time       proc  near

           push  ax
           push  di
           push  cx
           push  dx
           push  bx
           
           cmp   diskret,800
           jne   lop
           call   lopp2
           cmp   dx,1
           jne   tim3
           mov   dx,5

tim3:      mov   bx,ax 
           call  lopp3
           jmp   STRT
           
lop:       cmp   diskret,1600
           jne   tim1
           call  lopp1
           cmp   dx,1
           jne   lop1
           mov   dx,25
lop1:      cmp   dx,2
           jne   lop2
           mov   dx,50
lop2:      cmp   dx,3
           jne   lop3
           mov   dx,75
           
lop3:                      ;вывод(AX-результ  DX-остаток)
           ;надо сохранить АХ
           call  lopp4
           jmp   STRT
                     
tim1:      
           xor   di,di
           mov   al,images[di]
           out   8,al
           out   9,al
           mov   ax,bx
                      
STRT:      xor   dx,dx
           mov   di,100
           div   di
           mov   cl,al
           mov   ax,dx
           mov   dl,10
           div   dl
           mov   dx,ax       ;(cl dl dh)
           ;--------выводим текущее время---------------------
         
           xor   bx,bx
           mov   bl,cl
           mov   al,images[bx]
           out   5,al
           mov   bl,dl
           mov   al,images[bx]
           out   6,al 
           mov   bl,dh
           mov   al,images1[bx]
           out   7,al
       
          
           
           pop   bx
           pop   dx
           pop   cx
           pop   di
           pop   ax          
                 
                 
           
           ret
Time       endp
;--------------------------передаём значение температуры через AX-------------------------------
Temper     proc  near
           
           push  di
           push  dx
           push  cx
           mov    cx,1000     ;выделяем старшую цифру температуры
          xor    dx,dx
          div    cx
          mov    ch,al       ; в ch-старшая цифра (ch cl ** **)
          mov    ax,dx       ;поместили остаток в рабочий регистр
          xor    dx,dx
          mov    di,100
          div    di
          mov    cl,al       ; в cl-вторая цифра т-ры
          mov    ax,dx
          mov    dl,10
          div    dl          ;
          mov    dx,ax       ;(ch cl dl dh)
           ;-------------Выводим температуру-----------------
           push  bx
           xor   bx,bx
           mov   bl,ch
           lea   di,images
           mov   al,images[bx]
           out   1,al
           mov   bl,cl
           mov   al,images[bx]
           out   2,al
           mov   bl,dl
           mov   al,images[bx]
           out   3,al 
           mov   bl,dh
           mov   al,images[bx]
           out   4,al
           pop   bx
           pop   cx
           pop   dx
           pop   di
           ret

temper     endp
;---------------------------------dx--------------------------
timeb      proc  near
           push  di
           push  ax
           push  bx
           lea   di,images
           mov   bx,dx
           mov   al,images[bx]
           out   8,al
           pop   bx
           pop   ax
           pop   di
           ret
timeb      endp
;-------------------------
process    proc  near
           
           mov   bx,0;   
           lea   di,MasTemp;
         ;  lea   si,MasTime;
g1:        
           mov   al,1;       инициализируем АЦП(старт)
           out   0,al
           dec   al
           out   0,al
g2:        in    al,1;       ждём готовности устройства
           cmp   al,1
           jne   g2
           in    al,0;       получившийся в al код, соответствует текущей темп-ре/6...
           mov   ah,6
           mul   ah;         в АХ сформировалось значение темп-ры...(0..1530)
           
         
           
           mov   [di],Ax  ;запоминаем значение температуры
         
           

           call  temper
           call  time
           
           call  zaderjka
       
           inc   di
           inc   di
           ;---проверяем на ресет----
           in    al,2
           cmp   al,1
           jne    fl
           mov   flag,1
           ret
           
fl:                   
           inc   bx
           cmp   bx,Diskret;     (191h=401d)
           jne   g1
           ret
process    endp           

;------------------------------------------------------- 
obr1       proc  near
           mov   al,2
           out   55h,al

           lea   bx,MaxMasTime
           lea   si,MasTemp
           lea   di,MaxMasTemp
           mov   cx,0
           mov   MaxMasCount,0
           ret
obr1       endp

obr2       proc near
           mov   [di],dx     ; сохраняем точку максимума
           mov   [bx],cx
           inc   MaxMasCount
           add   si,2
           add   bx,2
           add   di,2
           inc   cx
           ret
obr2       endp

obr3       proc near
           mov   TempTiEnd,cx
           mov   TempSiEnd,si
           mov   si,TempSi
           mov   cx,TempTi
           ret
obr3       endp
;--------------------------------------------------
obrabotkaMax  proc  near
           
           push  ax
           push  bx
           push  cx
           push  dx
           push  si
           push  di
           
           call  obr1
           
om:        mov   dx,[si]  
           add   si,2         
           mov   ax,[si]
           sub   si,2
           cmp   ax,dx
           ja    om1         ;(ax > dx)
           
           inc   cx
           add   si,2
           cmp   cx,Diskret      ; выход из процедуры
           je    oend
           jmp   om
           
om1:       mov   dx,ax
           add   si,4
           inc   cx
           cmp   cx,Diskret      ; выход из процедуры
           je    oend           
           mov   ax,[si]
           sub   si,2           
           cmp   ax,dx
           ja    om1         ;(ax > dx)
           
           cmp   ax,dx
           je    om2         ;(ax = dx)
           
           call  obr2
           cmp   cx,Diskret      ; выход из процедуры 
           je    oend           
           jmp   om
           
om2:       mov   TempTi,cx
           mov   TempSI,si
           
oh1:       inc   cx
           cmp   cx,Diskret      ; выход из процедуры
           je    oend
           add   si,4
           mov   ax,[si]
           sub   si,2                      
           cmp   ax,dx
           je    oh1
           
           cmp   ax,dx
           ja    om1
           
           call  obr3
            
og1:       mov   [di],dx
           mov   [bx],cx
           cmp   cx,TempTiEnd
           je    om
           
           inc   cx
           cmp   cx,Diskret      ; выход из процедуры
           je    oend
           add   si,2
           add   di,2
           add   bx,2
           inc   MaxMasCount
           jmp   og1
           
oend:      
           pop  di
           pop  si
           pop  dx
           pop  cx
           pop  bx
           pop  ax
           ret
           
         
obrabotkaMax  endp
         
;--------------------------------------------------------
;-------------------------------------------------------  
mobr1       proc near
           mov   al,2
           out   55h,al

           lea   bx,MinMasTime
           lea   si,MasTemp
           lea   di,MinMasTemp
           mov   cx,0
           mov   MinMasCount,0
           ret
mobr1       endp

mobr2       proc near
           mov   [di],dx     ; сохраняем точку максимума
           mov   [bx],cx
           inc   MinMasCount
           add   si,2
           add   bx,2
           add   di,2
           inc   cx
           ret
mobr2       endp

mobr3       proc near
           mov   TempTiEnd,cx
           mov   TempSiEnd,si
           mov   si,TempSi
           mov   cx,TempTi
           ret
mobr3       endp
;--------------------------------------------------
obrabotkaMin     proc near

           push  ax
           push  bx
           push  cx
           push  dx
           push  si
           push  di
           
           call  mobr1
           
mom:       mov   dx,[si]  
           add   si,2         
           mov   ax,[si]
           sub   si,2
           cmp   ax,dx
           jb    mom1         ;(ax < dx)
           
           inc   cx
           add   si,2
           cmp   cx,diskret      ; выход из процедуры
           je    moend
           jmp   mom
           
mom1:      mov   dx,ax
           add   si,4
           inc   cx
           cmp   cx,diskret      ; выход из процедуры
           je    moend           
           mov   ax,[si]
           sub   si,2           
           cmp   ax,dx
           jb    mom1         ;(ax < dx)
           
           cmp   ax,dx
           je    mom2         ;(ax = dx)
           
           call  mobr2
           cmp   cx,diskret      ; выход из процедуры 
           je    moend           
           jmp   mom
           
mom2:      mov   TempTi,cx
           mov   TempSI,si
           
moh1:      inc   cx
           cmp   cx,diskret      ; выход из процедуры
           je    moend
           add   si,4
           mov   ax,[si]
           sub   si,2                      
           cmp   ax,dx
           je    moh1
           
           cmp   ax,dx
           jb    mom1
           
           call  mobr3
            
mog1:      mov   [di],dx
           mov   [bx],cx
           cmp   cx,TempTiEnd
           je    mom
           
           inc   cx
           cmp   cx,Diskret      ; выход из процедуры
           je    moend
           add   si,2
           add   di,2
           add   bx,2
           inc   MinMasCount
           jmp   mog1
           
moend:      
           pop  di
           pop  si
           pop  dx
           pop  cx
           pop  bx
           pop  ax
           ret

obrabotkaMin     endp            
;--------------------------------------------------------
obrabotkaMaxM    proc near
           push  ax
           push  si
           push  cx

           lea   si,MasTemp
           mov   cx,1
           mov   ax,[si]
           mov   MaxTemp,ax
           mov   MaxTime,0
           add   si,2
           
pl:        mov   ax,[si]
           cmp   ax,MaxTemp
           jae   pl1
           inc   cx
           cmp   cx,Diskret
           je    ple
           add   si,2
           jmp   pl
           
pl1:       mov   MaxTemp,ax         
           mov   MaxTime,cx
           inc   cx
           cmp   cx,diskret
           je    ple           
           add   si,2
           jmp   pl
ple:      
           pop   cx
           pop   si
           pop   ax
           ret           

obrabotkaMaxM    endp
;--------------------------------------------------------
obrabotkaMinM    proc near
           push  ax
           push  si
           push  cx

           lea   si,MasTemp
           mov   cx,1
           mov   ax,[si]
           mov   MinTemp,ax
           mov   MinTime,0
           add   si,2
           
mpl:       mov   ax,[si]
           cmp   ax,MinTemp
           jnae   mpl1
           inc   cx
           cmp   cx,diskret
           je    mple
           add   si,2
           jmp   mpl
           
mpl1:      mov   MinTemp,ax         
           mov   MinTime,cx
           inc   cx
           cmp   cx,diskret
           je    mple           
           add   si,2
           jmp   mpl
mple:       
           pop   cx
           pop   si
           pop   ax
           ret           

obrabotkaMinM    endp
;--------------------------------------------------------

Ver2       proc  near
           push  dx
           in    al,4
           cmp   al,2
           jne   ver1
           mov   dx,diskret
           sub   dx,11
           cmp   cx,dx
           ja    ves2
           add   cx,10
           add   si,20
           jmp   ves2
ver1:      cmp   al,1
           jne   ves2
           cmp   cx,10
           jb    ves2
           sub   cx,10
           sub   si,20
ves2:      pop   dx
           ret                      
Ver2       endp

Ver4       proc  near
           push  bx
           in    al,4
           cmp   al,2
           jne   ver14
           mov   bx,MaxMasCount
           sub   bx,11
           cmp   cx,bx
           ja    vers24
           add   cx,10
           add   si,20
           add   di,20
           jmp   vers24
ver14:     cmp   al,1
           jne   vers24
           cmp   cx,10
           jb    vers24
           sub   cx,10
           sub   si,20
           sub   di,20
vers24:    pop   bx
           ret                      
Ver4       endp

Ver3       proc  near
           push  bx
           in    al,4
           cmp   al,2
           jne   ver14
           mov   bx,MinMasCount
           sub   bx,11
           cmp   cx,bx
           ja    vers23
           add   cx,10
           add   si,20
           add   di,20
           jmp   vers23
ver13:     cmp   al,1
           jne   vers23
           cmp   cx,10
           jb    vers23
           sub   cx,10
           sub   si,20
           sub   di,20
vers23:    pop   bx
           ret                      
Ver3       endp


Vers2      proc  near
           
           cmp   temp2,0
           jne   av1
           lea   si,MasTemp
           mov   cx,0
           mov   temp2,1
av1:       mov   ax,[si]                                            
           mov   bx,cx
           call  time
           call  temper
           call  zaderjka
           in    al,51h
           cmp   al,1
           jne   av2
           cmp   cx,0
           je    av4
           sub   si,2
           dec   cx
           jmp   av4
av2:       cmp   al,2
           jne   av3
           push  bx
           mov   bx,diskret
           dec   bx
           cmp   cx,bx
           pop   bx
           je    av4
           add   si,2
           inc   cx
           jmp   av4
av3:       call  ver2
av4:       ret          

Vers2      endp

Vers4      proc  near

           cmp   temp2,0
           jne   cv1
           lea   si,MaxMasTemp
           lea   di,MaxMasTime
           mov   cx,1
           mov   temp2,1
cv1:       mov   ax,[si]           
           mov   bx,[di]
           call  time
           call  temper
           call  zaderjka
           in    al,51h
           cmp   al,1
           jne   cv2
           cmp   cx,1
           je    cv4
           sub   si,2
           dec   cx
           sub   di,2
           jmp   cv4
cv2:       cmp   al,2
           jne   cv3
           cmp   cx,MaxMasCount
           je    cv4
           add   si,2
           add   di,2
           inc   cx
           jmp   cv4
cv3:       call  ver4
           
cv4:       ret

Vers4      endp

Vers3      proc  near

           cmp   temp2,0
           jne   bv1
           lea   si,MinMasTemp
           lea   di,MinMasTime
           mov   cx,1
           mov   temp2,1
bv1:       mov   ax,[si]           
           mov   bx,[di]
           call  time
           call  temper
           call  zaderjka
           in    al,51h
           cmp   al,1
           jne   bv2
           cmp   cx,1
           je    bv4
           sub   si,2
           dec   cx
           sub   di,2
           jmp   bv4
           
bv2:       cmp   al,2
           jne   bv3
           cmp   cx,MinMasCount
           je    bv4
           add   si,2
           add   di,2
           inc   cx
           jmp   bv4
bv3:       call  ver3

bv4:       ret           

Vers3      endp
;------------------------------------------------------
outTemp    proc  near

           mov   temp2,0
           mov   temp,1
           mov   ax,temp
           out   55h,al
v:         xor   ax,ax
           in    al,50h
           cmp   al,0
           je    v1
           mov   temp,ax
           mov   temp2,0
           out   55h,al
v1:        
           in    al,2
           cmp   al,1
           jne   go
           mov   flag,1
           ret
           
 go:       cmp   temp,1
           je    v2
           cmp   temp,2
           je    v3
           cmp   temp,4
           je    v4
           cmp   temp,8
           je    v5
           cmp   temp,16
           je    v6
;+++++++++++++           
V2:        call  Vers2
           jmp   v           
;+++++++++++++
v4:        call  Vers4
           jmp   v
;++++++++++++++++++++++++++++++++++ 
v3:        call  Vers3
prom2:     jmp   v                   
;+++++++++++++++++++++++++++++
v5:        mov   ax,MaxTemp           
           mov   bx,MaxTime
           call  temper
           call  time
           jmp   prom2
           
v6:        mov   ax,MinTemp           
           mov   bx,MinTime
           call  temper
           call  time 
           jmp   prom2          
           

outTemp    endp
;--------------------------------------------------------
           
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы

m:         call  ojidanie
           call  process
           cmp   flag,1
           je    m
           call  obrabotkaMin
           call  obrabotkaMax
           call  obrabotkaMaxM
           call  obrabotkaMinM
           call  outTemp
           jmp   m
      

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
