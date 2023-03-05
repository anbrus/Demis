.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

data segment at 0BA00h use16
  sek_cl  db ?                   ;тик в часах        
  sek_tm  db ?                   ;тик в таймере
  Image   db 10 dup (?)          ;массив отображения цифр
  Fclock  db ?                   ;флаг редактирования часов 
  Fbyd    db ?                   ;флаг редактирования будильника  
  Fteim   db ?                    ;флаг редактирования таймера
  V_byd   db ?                   ;срабатывание будильника 
  V_teim  db ?                   ;срабатывание таймера 
  time    db 3 dup (?)           ;часы
  bydil   db 3 dup (?)           ;будильник
  byf_in  db ?                   ;содержимое порта ввода  
  temp    db 3 dup (?)           ;массив редактирования
  rez     db 3 dup (?)           ;массив вывода  
  timer   db 3 dup (?)           ;таймер 
  A_byd   db ?              ;режим отключения будильника(при 0-автоматическое) 
  A_timer db ?              ;режим отключения таймера(при 0-автоматическое) 
  Vkl_byd db ?              ;включение будильника
  Vkl_timer db ?            ;включение таймера
  t_min   dw ?              ;счетчик времени для авт. откл. таймера
       
data ends


;Задайте необходимый адрес стека
Stk        SEGMENT AT 1000h use16
;Задайте необходимый размер стека
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS
Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data,es:Data
;============================================================================
   inic       proc                                 ; начальная установка
           mov   Image[0],03Fh                     ;цифра "0"
           mov   Image[1],00Ch                     ;цифра "1" 
           mov   Image[2],076h                     ;цифра "2" 
           mov   Image[3],05Eh                     ;цифра "3" 
           mov   Image[4],04Dh                     ;цифра "4" 
           mov   Image[5],05Bh                     ;цифра "5" 
           mov   Image[6],07Bh                     ;цифра "6" 
           mov   Image[7],00Eh                     ;цифра "7"
           mov   Image[8],07Fh                     ;цифра "8" 
           mov   Image[9],05Fh                     ;цифра "9" 
           mov   time[0],0                          
           mov   time[1],0
           mov   time[2],0
           mov   bydil[0],0     
           mov   bydil[1],0
           mov   bydil[2],0 
           mov   temp[0],0          
           mov   temp[1],0          
           mov   temp[2],0
           mov   rez[0],0
           mov   rez[1],0
           mov   rez[2],0
           mov   sek_cl,0
           mov   sek_tm,0
           mov   byf_in,0
           mov   Fclock,0
           mov   Fbyd,0
           mov   Fteim,0
           mov   V_byd,0
           mov   V_teim,0
           mov   A_byd,0
           mov   A_timer,0
           mov   Vkl_byd,0
           mov   Vkl_timer,0
           mov   t_min,0       
           ret
inic       endp
;======================================================================
but_st     proc                   ; чтение порта ввода        
           in    al,0
           test  al,al
           jz    but_ret
           xor dx, dx
           call  dreb
but_ret:   mov   byf_in, al
           ret
but_st  endp           
;======================================================================

vivod     proc                         ;вывод на индикаторы
           lea bx, Image               ;инициализация массива отображения             
           mov   al,rez[0]        
           and   al,00001111b           
           xlat
           cmp   Fclock,0ffh           ;вывод точки в режиме редактирования
           jz    v_met2
           cmp   Fteim,0ffh
           jnz   v_met1
v_met2:    cmp   si,0
           jnz   v_met1
           or    al,10000000b
v_met1:    out   0,al                 ;вывод младшей цифры(6)
           mov   al,rez[0]
           shr   al,4 
           xlat
           out   1,al                  ;вывод 5 цифры 
           mov   al,rez[1]        
           and   al,00001111b 
           xlat
           cmp   Fclock,0ffh          ;вывод точки в режиме редактирования
           jz    v_met3
           cmp   Fteim,0ffh
           jz    v_met3
           cmp   Fbyd,0ffh
           jnz   v_met4           
v_met3:    cmp   si,1
           jnz   v_met4
           or    al,10000000b
v_met4:   
           out   2,al                 ;вывод 4 цифры 
           mov   al,rez[1]
           shr   al,4 
           xlat
           out   3,al                  ;вывод 3 цифры  
           mov   al,rez[2]        
           and   al,00001111b 
           xlat
           cmp   Fclock,0ffh              ;вывод точки в режиме редактирования
           jz    v_met5
           cmp   Fbyd,0ffh
           jnz   v_met6           
v_met5:    cmp   si,2
           jnz   v_met6
           or    al,10000000b
v_met6:   
           out   4,al                    ;вывод 2 цифры 
           mov   al,rez[2]
           shr   al,4 
           xlat
           out   5,al                    ;вывод старшей цифры(1) 
            
           mov   al,0                    ;вывод  флагов 
           cmp   Fclock,0ffh
           jnz   viv_m1
           or   al,1
viv_m1:    cmp   Fbyd,0ffh
           jnz   viv_m2
           or   al,2      
viv_m2:    cmp   Fteim,0ffh
           jnz   viv_m3
           or   al,4
viv_m3:    cmp   V_byd,0ffh
           jnz   viv_m4
           cmp   bydil[0],5            ;мигание при срабатывании будильника
           jle   viv_m4
           or   al,8h                                                     
viv_m4:    cmp   V_teim,0ffh
           jnz   viv_m5
           cmp   timer[2],5              ;мигание при срабатывании таймера
           jle   viv_m5           
           or   al,10h
viv_m5:    cmp   A_byd,0ffh
           jnz   viv_m6
           or   al,20h
viv_m6:    cmp   A_timer,0ffh
           jnz   viv_m7
           or   al,40h
viv_m7:    cmp   Vkl_byd,0ffh
           jnz   viv_m8
           or   al,80h                        
viv_m8:    out   6,al 
                      
           xor   al,al
           cmp   Vkl_timer,0ffh
           jnz   viv_m9
           mov   al,1 
viv_m9:    or    al,11110b             
           out   7,al
           ret
vivod     endp 
;==========================================================================
dreb       proc                          ;защита от дребезга
Dreb_Met1: mov ah, al
           mov bh, 0
Dreb_Met2: in al, dx
           cmp ah, al
           jne Dreb_Met1
           inc bh
           cmp bh, 10
           jne Dreb_Met2
           mov al, ah
           ret
dreb       endp        
;====================================================================
sost_but   proc                        ;обработка кнопок

           test  byf_in, 00000001b
           jz    sost_m1   
           call  but_01 
           jmp   sost_ret          
sost_m1:    test  byf_in,00000010b
           jz    sost_m2
           call   but_02
           jmp   sost_ret 
sost_m2:    test  byf_in,00000100b
           jz     sost_m3  
           call   but_03 
           jmp   sost_ret 
sost_m3:    test  byf_in,00001000b
           jz    sost_m4
           call   but_04
           jmp   sost_ret            
sost_m4:    test  byf_in,00010000b
           jz    sost_m5
           call   but_05
           jmp   sost_ret         
sost_m5:    test  byf_in,00100000b
           jz    sost_m6
           call   but_06
           jmp   sost_ret
sost_m6:    test  byf_in,01000000b
           jz    sost_m7
           call   but_07
           jmp   sost_ret                             
sost_m7:    test  byf_in,10000000b
           jz    sost_ret
           call   but_08
                 
sost_ret:  ret

sost_but   endp           
;================================================================== 
but_01     proc                   ;кнопка "+1"
           xor cl, cl
           cmp   Fclock,0ffh      
           jz  but01_m1  
           cmp   Fbyd,0ffh
           jz  but01_m1
           cmp   Fteim,0ffh
           jnz  but_01ret   
but01_m1:  mov cl, 0FFh
           mov   al,temp[si]
           inc   al
           daa
           mov   temp[si],al
           cmp   si,0
           jnz   inc_m1
           cmp   temp[si],01100000b
           jnz   but_01ret
           mov   temp[si],0
inc_m1:    cmp   si,1
           jnz   inc_m3
           cmp   temp[si],01100000b
           jnz    but_01ret
           mov   temp[si],0
inc_m3:    cmp   si,2
           jnz    but_01ret
           cmp   temp[si],00100100b
           jnz    but_01ret
           mov   temp[si],0          

but_01ret: test cl, cl
           jz _Exit 
           xor dx, dx

_Wait:     in al, dx
           test al, 01h
           jnz _Wait
           call  dreb
           test al, 01h
           jnz _Wait

_exit:     ret
but_01     endp           
;==================================================================       
;================================================================== 
but_02     proc         ;кнопка "-1"
           xor cl, cl
           cmp   Fclock,0ffh
           jz  but02_m1  
           cmp   Fbyd,0ffh
           jz  but02_m1
           cmp   Fteim,0ffh
           jnz   but_02ret         
but02_m1:  mov cl, 0FFh
           mov   al,temp[si]
           dec   al
           das
           mov   temp[si],al
           cmp  temp[si],0
           jz   dec_m0
           cmp   temp[si],10011001b
           jnz   but_02ret 
dec_m0:    cmp   si,0
           jnz   dec_m2
           mov   temp[si],01011001b
dec_m2:    cmp   si,1
           jnz   dec_m3
           mov   temp[si],01011001b
dec_m3:    cmp   si,2
           jnz    but_02ret
           mov   temp[si],00100011b

but_02ret: test cl, cl
           jz _Exit02 
           xor dx, dx

_Wait02:   in al, dx
           test al, 02h
           jnz _Wait02
           call  dreb
           test al, 02h
           jnz _Wait02

_exit02:   ret
but_02     endp           
;==================================================================   
;================================================================== 
but_03     proc              ;кнопка "<--"
           
           xor   cl,cl
           cmp   Fclock,0ffh
           jnz  but03_m1 
           mov cl, 0FFh
           inc   si 
           cmp   si,3
           jne   but_03ret
           mov   si,0
       
but03_m1:  cmp   Fbyd,0ffh
           jnz   but03_m2
           mov cl, 0FFh
           inc   si
           cmp   si,3
           jnz   but03_m2
           mov   si,1
but03_m2:  cmp   Fteim,0ffh
           jnz   but_03ret
           mov cl, 0FFh
           inc   si 
           cmp   si,2
           jnz   but_03ret
           mov   si,0
         
but_03ret: test cl, cl
           jz _Exit03 
           xor dx, dx
_Wait03:   in al, dx
           test al, 04h
           jnz _Wait03
           call  dreb
           test al, 04h
           jnz _Wait03

_exit03:   ret
but_03     endp           
;==================================================================   
;================================================================== 
but_04     proc             ;кнопка "Часы"
           xor  cl,cl
           cmp   Fbyd,0ffh
           jz  but_04ret
           cmp   Fteim,0ffh
           jz   but_04ret         
;but04_m1:
           mov  al,Fclock
           not  al
           mov  Fclock,al 
           mov cl, 0FFh
           cmp  Fclock,0ffh
           jnz  but04_m2 
           mov  al,time[0]
           mov  temp[0],al
           mov  al,time[1]
           mov  temp[1],al
           mov  al,time[2]           
           mov  temp[2],al    
           mov  si,0       
but04_m2:  mov  al,temp[0]
           mov  time[0],al      
           mov  al,temp[1]
           mov  time[1],al
           mov  al,temp[2]
           mov  time[2],al      
                
                    
but_04ret:  test cl, cl
           jz _Exit04 
            xor dx, dx
_Wait04:     in al, dx
           test al, 08h
           jnz _Wait04
           call  dreb
           test al, 08h
           jnz _Wait04
_exit04:      
           ret
but_04     endp           
;==================================================================   
;================================================================== 
but_05     proc           ;кнопка "Будильник"
           xor  cl,cl
           cmp   Fclock,0ffh
           jz  but_05ret 
           cmp   Fteim,0ffh
           jz   but_05ret         

           mov  al,Fbyd
           not  al
           mov  Fbyd,al 
           mov cl, 0FFh
           cmp   Fbyd,0
           jz   but_05ret
           mov   al,0
           mov   temp[0],al          
           mov   temp[1],al
           mov   temp[2],al
           mov   si,1
           mov   A_byd,al
           mov   V_byd,al
           mov   Vkl_byd,al                      

but_05ret: test cl, cl
           jz _Exit05 
           xor dx, dx

_Wait05:   in al, dx
           test al, 10h
           jnz _Wait05
           call  dreb
           test al, 10h
           jnz _Wait05

_exit05:   ret
but_05     endp           
;==================================================================   
;================================================================== 
but_06     proc                  ;кнопка "Таймер"
           xor  cl,cl
           cmp   Fclock,0ffh
           jz  but_06ret 
           cmp   Fbyd,0ffh
           jz   but_06ret         

           mov  al,Fteim
           not  al
           mov  Fteim,al 
           mov cl, 0FFh
           cmp   Fteim,0
           jz   but_06ret
           mov   al,0
           mov   temp[0],al
           mov   temp[1],al
           mov   temp[2],al
           mov   si,0                       
           mov   t_min,0
           mov   timer[2],0
but_06ret: test cl, cl
           jz _Exit06 
           xor dx, dx
_Wait06:   in al, dx
           test al, 20h
           jnz _Wait06
           call  dreb
           test al, 20h
           jnz _Wait06
_exit06:   ret
but_06     endp           
;==================================================================   
;================================================================== 
but_07     proc        ;кнопка "Руч/авт"
           xor  cl,cl
           cmp   Fbyd,0ffh
           jnz  but07_m1
           mov  al,A_byd
           not  al
           mov  A_byd,al
           mov   cl,0ffh           
but07_m1:  cmp   Fteim,0ffh
           jnz   but_07ret    
           mov  al,A_timer
           not  al
           mov  A_timer,al
           mov   cl,0ffh
but_07ret: test cl, cl
           jz _Exit07 
           xor dx, dx
_Wait07:   in al, dx
           test al, 40h
           jnz _Wait07
           call  dreb
           test al, 40h
           jnz _Wait07
_exit07:   ret
but_07     endp           
;==================================================================   
;================================================================== 
but_08     proc             ;кнопка "Вкл/выкл"
           xor  cl,cl
           cmp   Fbyd,0
           jz  but08_m1
           mov   cl,0ffh
           mov  al,Vkl_byd
           not  al
           mov  Vkl_byd,al
           cmp   Vkl_byd,0ffh
           jnz   but08_m1           
           
           mov   al,temp[1]
           mov   bydil[1],al             
           mov   al,temp[2]
           mov   bydil[2],al
but08_m1:  cmp   Fteim,0ffh
           jnz   but08_m2    
           mov  al,Vkl_timer
           not  al
           mov  Vkl_timer,al
           mov   cl,0ffh
           mov   al,temp[0]
           mov   timer[0],al
           mov   al,temp[1]
           mov   timer[1],al             
            
but08_m2:  cmp   V_byd,0
           jz    but08_m3
           cmp   A_byd,0ffh
           jnz   but08_m3
           cmp   Fbyd,0
           jnz   but08_m3
           mov   V_byd,0
           mov   Vkl_byd,0
           mov   A_byd,0   
           mov   cl,0ffh
but08_m3:  cmp   V_teim,0
           jz    but_08ret
           cmp   A_timer,0ffh
           jnz   but_08ret
           cmp   Fteim,0
           jnz    but_08ret  
           mov   V_teim,0
           mov   A_timer,0 
           mov   Vkl_timer,0
           mov   cl,0ffh
                            
but_08ret: test cl, cl
           jz _Exit08 
           xor dx, dx
_Wait08:   in al, dx
           test al, 80h
           jnz _Wait08
           call  dreb
           test al, 80h
           jnz _Wait08
_exit08:   ret
but_08     endp           
;==================================================================
clock_timer proc                        ;анализ содержимого флагов
           call  clock           
           cmp  Fclock,0ffh
           jz  cl_tm_m1
           cmp   Fbyd,0ffh
           jz    cl_tm_m1
           cmp   Fteim,0ffh
           jnz   cl_tm_m2
                     
cl_tm_m1:  mov   al,temp[0]
           mov   rez[0],al
           mov   al,temp[1]
           mov   rez[1],al
           mov   al,temp[2]
           mov   rez[2],al
           jmp   cl_tm_m4 
                   
cl_tm_m2:  cmp   Vkl_timer,0ffh
           jnz   cl_tm_m3
           cmp   Fteim,0
           jnz    cl_tm_m3
           call  teimer
           mov   al,timer[0]
           mov   rez[0],al                       
           mov   al,timer[1]
           mov   rez[1],al
           cmp   V_teim,0ffh
           jnz   cl_tm_m4
           inc   timer[2] 
           cmp   timer[2],10
           jnz   cl_tm_m40
           mov   timer[2],0

cl_tm_m40: cmp   A_timer,0
           jnz   cl_tm_m4
           inc   t_min
           cmp   t_min,590
           jnz   cl_tm_m4
           mov   V_teim,0
           mov   Vkl_timer,0                                              
           jmp   cl_tm_m4
           
cl_tm_m3:  mov   al,time[0]
           mov   rez[0],al             
           mov   al,time[1]
           mov   rez[1],al
           mov   al,time[2]
           mov   rez[2],al             
                                         
cl_tm_m4:  cmp   Vkl_byd,0ffh
           jnz   cl_tm_ret
           mov   al,time[2]
           cmp   al,bydil[2]
           jnz   cl_tm_m50
           mov   al,time[1]
           cmp   al,bydil[1]
           jnz   cl_tm_m50
           mov   V_byd,0ffh

cl_tm_m50: inc   bydil[0]
           cmp   bydil[0],10
           jnz   cl_tm_m5
           mov   bydil[0],0
          
cl_tm_m5:  cmp   A_byd,0ffh
           jz    cl_tm_ret
           mov   al,bydil[1]
           inc   al
           cmp   al,time[1]
           jnz   cl_tm_ret
           mov   V_byd,0
           mov   Vkl_byd,0             

cl_tm_ret: ret
clock_timer      endp              
;==================================================================
clock      proc              ;работа часов 
           mov   cx,0h  
 
 _pauza:   dec   cx
           jnz   _pauza   
 
           inc   sek_cl
           cmp   sek_cl,10
           jnz   clock_ret
           mov   sek_cl,0              
           mov   al,time[0]
           inc    al
           daa
           mov   time[0],al
           cmp  time[0],01100000b
           jnz  clock_ret
           
           mov  time[0],0
           mov  al,time[1] 
           inc  al
           daa  
           mov  time[1],al 
           cmp  time[1],01100000b
           jnz  clock_ret
           
           mov  time[1],0
           mov  al,time[2] 
           inc  al
           daa  
           mov  time[2],al 
           cmp  time[2],00100100b
           jnz  clock_ret
           mov  time[2],0 
clock_ret: ret
clock      endp
           
;==================================================================
teimer     proc                              ;работа таймера
           inc   sek_tm
           cmp   sek_tm,10
           jnz   teimer_ret
           mov   sek_tm,0              
           cmp   timer[0],0
           jz    teimer_m0
           mov   al,timer[0]
           dec   al
           das
           mov   timer[0],al
           jmp   teimer_ret          
teimer_m0: cmp   timer[1],0
           jz    teimer_m1
           mov   timer[0],01011001b
           mov   al,timer[1]
           dec   al
           das
           mov   timer[1],al
           jmp   teimer_ret 
                       
teimer_m1: mov   V_teim,0ffh
teimer_ret:ret
teimer      endp           
;=================================================================
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop

           call  inic
begin:     call  but_st
           call  sost_but 
           call  clock_timer
           call  vivod
           jmp   begin           

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
