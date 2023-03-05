VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;Сохранение исходного состояния
           mov   bh,0        ;Сброс счётчика повторений
VD2:       in    al,dx       ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   bh          ;Инкремент счётчика повторений
           cmp   bh,NMax     ;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных
           ret
VibrDestr  ENDP

KbdInput   PROC  NEAR
           lea   si,KbdImage         ;Загрузка адреса,
           mov   cx,LENGTH KbdImage  ;счётчика циклов
           mov   bl,0FEh             ;и номера исходной строки
KI4:       mov   al,bl       ;Выбор строки
           ;and   al,3Fh     ;Объединение номера с
           ;or    al,MesBuff ;сообщением "Тип ввода"
           out   KbdPort,al  ;Активация строки
           in    al,KbdPort  ;Ввод строки
           and   al,0Fh      ;Включено?
           cmp   al,0Fh
           jz    KI1         ;Переход, если нет
           mov   dx,KbdPort  ;Передача параметра
           call  VibrDestr   ;Гашение дребезга
           mov   [si],al     ;Запись строки
KI2:       in    al,KbdPort  ;Ввод строки
           and   al,0Fh      ;Выключено?
           cmp   al,0Fh
           jnz   KI2         ;Переход, если нет
           call  VibrDestr   ;Гашение дребезга
           jmp   SHORT KI3
KI1:       mov   [si],al     ;Запись строки
KI3:       inc   si          ;Модификация адреса
           rol   bl,1        ;и номера строки
           loop  KI4         ;Все строки? Переход, если нет
           ret
KbdInput   ENDP

KbdInContr PROC  NEAR
           lea   bx,KbdImage ;Загрузка адреса
           mov   cx,4        ;и счётчика строк
           mov   EmpKbd,0    ;Очистка флагов
           mov   KbdErr,0
           mov   dl,0        ;и накопителя
KIC2:      mov   al,[bx]     ;Чтение строки
           mov   ah,4        ;Загрузка счётчика битов
KIC1:      shr   al,1        ;Выделение бита
           cmc               ;Подсчёт бита
           adc   dl,0
           dec   ah          ;Все биты в строке?
           jnz   KIC1        ;Переход, если нет
           inc   bx          ;Модификация адреса строки
           loop  KIC2        ;Все строки? Переход, если нет
           cmp   dl,0        ;Накопитель=0?
           jz    KIC3        ;Переход, если да
           cmp   dl,1        ;Накопитель=1?
           jz    KIC4        ;Переход, если да
           mov   KbdErr,0FFh ;Установка флага ошибки
           jmp   SHORT KIC4
KIC3:      mov   EmpKbd,0FFh ;Установка флага пустой клавиатуры
KIC4:      ret
KbdInContr ENDP

NxtDigTrf  PROC  NEAR
           cmp   EmpKbd,0FFh ;Пустая клавиатура?
           jz    NDT1        ;Переход, если да
           cmp   KbdErr,0FFh ;Ошибка клавиатуры?
           jz    NDT1        ;Переход, если да
           lea   bx,KbdImage ;Загрузка адреса
           mov   dx,0        ;Очистка накопителей кода строки и столбца
NDT3:      mov   al,[bx]     ;Чтение строки
           and   al,0Fh      ;Выделение поля клавиатуры
           cmp   al,0Fh      ;Строка активна?
           jnz   NDT2        ;Переход, если да
           inc   dh          ;Инкремент кода строки
           inc   bx          ;Модификация адреса
           jmp   SHORT NDT3
NDT2:      shr   al,1        ;Выделение бита строки
           jnc   NDT4        ;Бит активен? Переход, если да
           inc   dl          ;Инкремент кода столбца
           jmp   SHORT NDT2
NDT4:      mov   cl,2        ;Формировние двоичного кода цифры
           shl   dh,cl
           or    dh,dl
           mov   NextDig,dh  ;Запись кода цифры
NDT1:      ret
NxtDigTrf  ENDP



indi proc near

           push ax
           mov al,nach
           xor cx,cx

indi1:     shr al,1
           inc cl
           jc indi2
           jmp indi1
           
indi2:     lea si,image
           add si,cx
           mov al,es:[si]
           mov floor2,al
           out 1,al
           out 2,al
           out 3,al
           out 4,al
           out 5,al
           out 6,al
           out 7,al
           out 8,al
           out 9,al
           pop ax
           
           ret
indi       endp
 
Delay      proc  near
           push  cx
           mov   cx,30000
DelayLoop:
           inc   cx
           dec   cx
           inc   cx
           dec   cx
           loop  DelayLoop
           pop   cx
           ret
Delay      endp  

pervoe     proc near

perv:      
           in    al,0
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah           
           cmp   al,0
           je    perv
           out 0,al
           mov nach,al    

            xor cx,cx
lab1:       shr al,1
            inc cl
            jc lab2
            jmp lab1
lab2:      lea si,image
           add si,cx
           mov al,es:[si]
           mov floor2,al
           out 1,al
           out 2,al
           out 3,al
           out 4,al
           out 5,al
           out 6,al
           out 7,al
           out 8,al
           out 9,al
           jmp p
           
p:           ret

pervoe     endp

button_vn_vv     proc near
 cmp    flagHum,1
 je        endd
           in al,1
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp al,0
           jnz but
           
           in al,2
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp al,0
           jnz but
           
           
           jmp endd
but:       mov kon,al
           mov   flag1,1
           mov flagdver,1
endd:      
           ret

button_vn_vv     endp

dvig       proc near


           cmp    flagHum,1
           jnz   star
           jmp   enddd
           cmp flag1,0
           jne star
           jmp enddd
           
star:      in al,1h

           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           
           cmp   al,kon
           jne  dd1  
         
          
dd1:           cmp al,0h
           jne op1
           
          
           in al,2h
           
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           
           
            cmp   al,kon
           jne  dd2  
         
           
dd2:           cmp al,0h
           jne op1
           
           
           jmp enddd 
          
          
op1:       mov kon,al
           cmp nach,al
           jne nnn
           jmp dv4
nnn:       mov al,nach
           ja dvNiz
           jmp   dvVerh

dvNiz:      mov al,00000000b
           out 11h,al


n2:call error2
cmp flagstop,0
je n1
mov al,00000001b
out 11h,al
out 12h,al
call delay
mov al,00000000b
out 12h,al
call delay
call delay
call delay
call delay
call delay
mov al,00000000b
out 11h,al
mov al,00000001b
out 12h,al
call delay
mov al,00000000b
out 12h,al
call delay
jmp n2
n1:           mov al,00000001b
           out 13h,al
           
           
           
           
           in    al,2


           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           
           cmp    al,0
           je    d2 
           cmp   al,nach
           ja    d2
           mov   kon,al
                     
d2:        mov   al,nach
           
           call  error
           cmp   flagerror,0
           je    err1
           jmp   dv4   
err1:       out   0,al
           call delay
           call delay
           call delay
           call delay
           call delay
           call delay
           shr   al,1
           cmp   al,kon
           jne    dv444
           jmp dv4
  dv444:         mov   nach,al
           call  indi

           jmp dvNiz

dvVerh:    mov al,00000000b
           out 11h,al 
v2:call error2
cmp flagstop,0
je v1
mov al,00000001b
out 11h,al
out 12h,al
call delay
mov al,00000000b
out 12h,al
call delay
call delay
call delay
call delay
call delay
mov al,00000000b
out 11h,al
mov al,00000001b
out 12h,al
call delay
mov al,00000000b
out 12h,al
call delay
jmp v2           

v1:            mov al,00000001b
           out 13h,al
          in    al,1

           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           
           cmp   al,0
           je    d22 
           cmp   al,nach
           jb    d22
           mov   kon,al 
           
d22 :      mov   al,nach

           call  error
           cmp   flagerror,0
           je    err2
           jmp   dv4   
                
err2:           out 0,al
           call delay
           call delay
           call delay
           call delay
           call delay
           call delay
           shl al,1
           cmp al,kon
           je dv4
           mov nach,al
           call indi

           jmp dvVerh
           
dv4:       out 0,al
           
           mov nach,al
           call indi
;call       open           
           mov al,00000000b
           out 13h,al
           cmp   flagerror,0
            jne enddd
 mov al,00000001b
           out 11h,al           
       out 12h,al
       call delay
      mov al,00000000b
         out 12h,al
      
          
enddd:  mov flagdver,0 
    ret

dvig       endp

opros_knopok     proc near
 cmp    flagHum,0
 je        fin
           in al,3
           
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           
          cmp al,0
           jne op_kn
       
        mov al,kon
           cmp al,nach
           jne op_kn
           jmp fin
           
op_kn:  
           mov kon,al
           mov kon3,al
           cmp nach,al
           mov al,nach
           jb vverh
          mov flag2,0
          
          jmp fin
          
vverh:     mov flag2,1      
           
fin:  mov flagdver,1      
ret
           
opros_knopok     endp

dvig2      proc near


           cmp   flagperegruzka,1
           jne   ddv
           jmp fin2
ddv:       cmp    flagstop,1
           jne    dv0
           jmp   fin2
dv0:       cmp    flagHum,1
           jz    dv1
           jmp   fin2
           cmp flag2,0
           jne dv1
           jmp fin2
           ;jmp   dvV
dv1:      
           in al,3
           
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           
           cmp al,0
           je fin
           cmp al,nach
           je fin
           mov kon,al
           mov kon3,al
           cmp nach,al
           mov al,nach
           ja dvn
           jmp dvV
dvN:     in    al,2
mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           
           cmp    al,0
           je    ddv1 
           cmp   al,nach
           ja    ddv1
           mov   kon,al
           ddv1:       mov al,00000000b
           out 11h,al 
vv2:call error2
cmp flagstop,0
je vv1
mov al,00000001b
out 11h,al
out 12h,al
call delay
mov al,00000000b
out 12h,al
call delay
call delay
call delay
call delay
call delay
mov al,00000000b
out 11h,al
mov al,00000001b
out 12h,al
call delay
mov al,00000000b
out 12h,al
call delay
jmp vv2           
          


vv1:cmp flagblin,1
jne kkk1
cmp flag_podbor,0
je  not1
jmp      kk1

not1:cmp port,0
jne kk1
mov al,kon2
mov kon,al

jmp        kkk1
            
kk1:

;mov al,kon3
;mov kon,al

kkk1:mov flagblin,0
;mov flag_podbor,1
mov al,00000001b
           out 13h,al
           mov   al,nach  
           out   0,al
           call  error
           cmp   flagerror,0
           je    er4
           jmp   dv44
er4:       call delay
           call delay
           call delay
           call delay
           call delay
           call delay
           shr   al,1
           cmp   al,kon          ;vgxdfvxfvxvx
           jne    dv4444
           jmp dv44
dv4444:           mov   nach,al
           call  indi

           jmp dvN

dvv:        in    al,1

           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           
           cmp   al,0
           je    ddv2 
           cmp   al,nach
           jb    ddv2
           mov   kon,al
                
ddv2 :      mov al,00000000b
           out 11h,al
nn2:call error2
cmp flagstop,0
je nn1
mov al,00000001b
out 11h,al
out 12h,al
call delay
mov al,00000000b
out 12h,al
call delay
call delay
call delay
call delay
call delay
mov al,00000000b
out 11h,al
mov al,00000001b
out 12h,al
call delay
mov al,00000000b
out 12h,al
call delay
jmp nn2           
            


nn1:cmp flagblin,1
jne kkk2
cmp flag_podbor,1
je not2
jmp       kk2
not2:cmp port,1
jne kk2
mov al,kon2
mov kon,al  

jmp        kkk2

                 
kk2:

;mov al,kon3
;mov kon,al

kkk2:mov flagblin,0
;mov flag_podbor,0
mov al,00000001b
           out 13h,al
            mov   al,nach
                            
           out 0,al
           
              
           call  error
           cmp   flagerror,0
           je er6
           jmp dv44
er6:           call delay
           call delay
           call delay
           call delay
           call delay
           call delay
           shl al,1
           cmp al,kon
           je dv44
           mov nach,al
           call indi

           jmp dvV
           
dv44:      out 0,al
           mov nach,al
           call indi
           mov al,00000000b
           out 13h,al
            cmp   flagerror,0
            jne fin2
            mov al,00000001b
           out 11h,al 
  out 12h,al
       call delay
      mov al,00000000b
         out 12h,al

       
          
           
fin2: mov flagdver,0      
ret
           

          
           
dvig2      endp

HumInLft   proc near
      
           cmp   res,0
           jz    NoHum
     
           mov   flagHum,1
           jmp   endHum
NoHum:     mov   flagHum,0
endHum:    ret
HumInLft   endp

open       proc  near

           push  ax
           mov   al,00000001b
           out   11h,al
           out   12h,al
           mov   al,00000000b
           call  delay
           out   12h,al
           pop   ax
           
           ret
           
open       endp

cloze      proc  near

           push  ax
           mov   al,00000000b
           out   11h,al
           mov   al,00000001b
           out   12h,al
           mov   al,00000000b
           call  delay
           out   12h,al
           pop   ax
           
           ret
           
cloze      endp


NumOut     PROC  NEAR
           cmp   KbdErr,0FFh
           jz    NO1
           cmp   EmpKbd,0FFh
           jz    NO1            
           add   Flag,1
           cmp   Flag,04h
           jae    NO1
           xor   ax,ax           
           mov   al,NextDig
           
         
           lea   bx,sum
           mov   dl,[bx+1]
           mov   [bx+2],dl
           mov   dl,[bx]
           mov   [bx+1],dl
           ;cmp   al,0
           ;jnz   num2
           ;mov   al,0
num2:      mov   [bx],al
               
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           lea   bx,ImageNum
           lea   si,data1
           add   bx,ax
           mov   al,es:[bx]
           mov   cx,3
           add   si,1
m1:        mov   dl,[si]
           mov   BYTE PTR[si+1],dl
           dec   si
           loop  m1
           
           mov   data1,al
           mov   cx,3
           mov   dx,20h
           lea   bx,data1
m2:        mov   al,[bx]
           out   dx,al
           inc   bx
           inc   dx
           loop  m2          
NO1:       ret

NumOut     ENDP




nado       proc  near

lb11:      in    al,30h
           cmp   al,0FEh
           jnz   reset
           mov   Flag,0
           mov   cx,3
           lea   bx,data1
           mov   dx,20h
lab12:     mov   BYTE PTR[bx],00
           mov   al,[bx]
           out   dx,al
          
           inc   bx
           inc   dx
           loop  lab12
                        
reset:     ret
           
nado       endp 

Summa      PROC  NEAR

           in    al,30h
           cmp   al,0FDh
           jz    ll1
           jmp   NoSum
           
ll1:       in    al,30h
           cmp   al,0FDh
           jz    ll1
           
           xor   ax,ax
           mov   dl,100d 
           mov   al,[sum+2]
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           mul   dl
           add   res,ax
           xor   ax,ax
           mov   dl,10d 
           mov   al,[sum+1]
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           mul   dl   
           add   res,ax
           xor   ax,ax
           mov   al,sum
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           add   res,ax
           
           mov   cx,3
           lea   bx,sum
           
s1:        mov   [bx],word ptr 3
           inc   bx
           loop  s1
           
           mov   ax,res
           mov   cl,10d
           div   cl
           mov   dx,ax
           lea   bx,ImageNum
           add   bl,ah
           mov   al,es:[bx]
           out   52h,al
           mov   ax,dx
           mov   ah,0
           div   cl
           mov   dx,ax
           lea   bx,ImageNum
           add   bl,ah
           mov   al,es:[bx]
           out   51h,al
           mov   ax,dx
           mov   ah,0           
           div   cl
           lea   bx,ImageNum
           add   bl,ah
           mov   al,es:[bx]
           out   50h,al
           mov   Flag,0
           mov   cx,3
           lea   bx,data1
           mov   dx,20h
lab13:     mov   BYTE PTR[bx],00
           mov   al,[bx]
           out   dx,al
           inc   bx
           inc   dx
           loop  lab13
NoSum:     ret
Summa      ENDP

Minus      PROC  NEAR
           in    al,30h
           cmp   al,0FBh
           jz    ll2
           jmp   NoMinus
           
ll2:       in    al,30h
           cmp   al,0FBh
           jz    ll2
           
           xor   ax,ax
           mov   dl,100d 
           mov   al,[sum+2]
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           mul   dl
           sub   res,ax
           xor   ax,ax
           mov   dl,10d 
           mov   al,[sum+1]
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           mul   dl   
           sub   res,ax
           xor   ax,ax
           mov   al,sum
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           sub   res,ax
           
           mov   cx,3
           lea   bx,sum
           
r1:        mov   [bx],word ptr 3
           inc   bx
           loop  r1
           
           mov   ax,res
           mov   cl,10d
           div   cl
           mov   dx,ax
           lea   bx,ImageNum
           add   bl,ah
           mov   al,es:[bx]
           out   52h,al
           mov   ax,dx
           mov   ah,0
           div   cl
           mov   dx,ax
           lea   bx,ImageNum
           add   bl,ah
           mov   al,es:[bx]
           out   51h,al
           mov   ax,dx
           mov   ah,0           
           div   cl
           lea   bx,ImageNum
           add   bl,ah
           mov   al,es:[bx]
           out   50h,al
           mov   Flag,0
           mov   cx,3
           lea   bx,data1
           mov   dx,20h
lab14:     mov   BYTE PTR[bx],00
           mov   al,[bx]
           out   dx,al
           inc   bx
           inc   dx
           loop  lab14
           
NoMinus:   ret

Minus      ENDP

input      proc  near
           cmp   flagError,1
           je    inp
           
           call  KbdInput
           call  KbdInContr
           call  NxtDigTrf
           call  NumOut
          
           call  nado
           call  summa
           call  minus
           call load
inp:       ret
           
input      endp 

error      proc  near

push ax
           in     al,4h
           
           mov    ah,0FFh
           sub    ah,al
           mov    al,ah
           
           cmp    al,10000000b
           
     
           jne    errorend
         
pr:        mov   flagError,1
           mov al,00000001b
           out   17h,al
           jmp   pr2
errorend:  mov al,00000000b
           out   17h,al
           mov   flagerror,0
pr2:      pop ax           
      ret

error      endp 

error2     proc  near
push ax
           in al,5h
           
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp   al,00000001b
pop ax           
           jne   errorend2
           mov   flagstop,1
           jmp   errorend3
errorend2: mov   flagstop,0
errorend3: ret

error2     endp 

load       proc  near
      
           cmp   res,401
           jb    peregr
           mov   al,10000000b
           out   19h,al
           mov   flagperegruzka,1
           jmp   load1
peregr:    mov   al,00000000b    
           out   19h,al
           mov   flagperegruzka,0
load1:     ret
load       endp


button_vn_vv2     proc near

            in al,2
            
            
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp al,0
           jnz but2
           
           in al,1
           
           
           mov   ah,0FFh
           sub   ah,al
           mov   al,ah
           cmp al,0
           jnz but3
           
          
           
           
           jmp endddd
but2:  mov port,0 
jmp  pricol 

but3:      mov port,1
jmp  pricol

pricol:mov flagblin,1  
mov kon2,al      
mov al,nach
cmp kon2,al
jb         metka_vniz
mov flag_podbor,1
jmp endddd

metka_vniz:mov flag_podbor,0


          
endddd:      
           ret

button_vn_vv2     endp

