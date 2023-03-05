.386
RomSize    EQU  4096

Data       SEGMENT AT 0BA00h use16
    bud1_wkl  db  ?        ;флаг включенного будильника_1
    bud2_wkl  db  ?        ;флаг включенного будильника_2
    taim_wkl  db  ?        ;флаг включенного таймера  
    chas      db  3 dup(?) ;часы
    chas_1    db  3 dup(?) ;настройка часов
    bud_1     db  3 dup(?) ;будильник_1
    bud_2     db  3 dup(?) ;будильник_2
    taim      db  3 dup(?) ;таймер
    tik_chas  dw  ?        ;тик в часах
    tik_taim  dw  ?        ;тик в таймере
    rez       db  3 dup(?) ;массив отображения
    nom       db  ?        ;номер корректируемого поля
    Fbud1     db  ?        ;флаг будильника_1
    Fbud2     db  ?        ;флаг будильника_2
    Ftaim     db  ?        ;флаг таймера
    Fchas     db  ?        ;флаг часов
    flag      db  ?        ;флаг нажатой +1 или -1
    diod      db  ?        ;работа светодиода
    b_1       db  ?        ;звонок буд_1
    b_2       db  ?        ;звонок буд_2
    t_1       db  ?        ;звонок таймера
    f_tik     db  ?        ;секунда д/мигания
    zwon_bud1 db  ?        ;для автоматического отключения буд_1
    zwon_bud2 db  ?        ;для автоматического отключения буд_2   
    zwon_taim db  ?        ;для автоматического отключения таймера
    Image   db 10 dup (?)  ;массив отображения цифр
Data       ENDS

Stk        SEGMENT AT 1000h use16
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

Code       SEGMENT use16
           ASSUME cs:Code,ds:Data,es:Data
           
obnulenie proc near  ;начальная установка
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
           mov   bud1_wkl,0
           mov   bud2_wkl,0
           mov   taim_wkl,0          
           mov   chas[0],0
           mov   chas[1],0
           mov   chas[2],0
           mov   bud_1[0],0
           mov   bud_1[1],0
           mov   bud_1[2],0
           mov   bud_2[0],0
           mov   bud_2[1],0
           mov   bud_2[2],0
           mov   taim[0],0
           mov   taim[1],0
           mov   taim[2],0
           mov   tik_chas,0
           mov   tik_taim,0
           mov   rez[0],0
           mov   rez[1],0
           mov   rez[2],0
           mov   nom,0
           mov   Fbud1,0
           mov   Fbud2,0
           mov   Ftaim,0
           mov   Fchas,0
           mov   flag,0
           mov   diod,00001111b
           mov   b_1,0
           mov   b_2,0
           mov   t_1,0
           mov   f_tik,0
           mov   zwon_bud1,0
           mov   zwon_bud2,0
obnulenie endp
           
in_port_2 proc near          ;чтение порта ввода 2   
           in    al,2
           test  al,1
           jz    k1
           mov   bud1_wkl,0ffh   
           jmp   k4
      k1:  mov   bud1_wkl,0
           mov   b_1,0
      k4:  test  al,2
           jz   k2
           mov   bud2_wkl,0ffh     
           jmp   k5
      k2:  mov   bud2_wkl,0
           mov   b_2,0
      k5:  test  al,4
           jz    k6
           mov   taim_wkl,0ffh     
           jmp   in_port_2_ret
      k6:  mov   taim_wkl,0
           mov   t_1,0
in_port_2_ret:ret
in_port_2 endp
 
dreb       proc                ;защита от дребезга
Dreb_Met1: mov   ah, al
           mov   bh, 0
Dreb_Met2: in    al, dx
           cmp   ah, al
           jne   Dreb_Met1
           inc   bh
           cmp   bh, 10
           jne   Dreb_Met2
           mov   al, ah
           ret
dreb       endp   
     
 
in_port_1  proc near           ;чтение порта ввода 1   
           in    ax,1
           cmp   ax,0
           je    ustan_ret
           
           push  ax
      u7:  in    ax,1
           or    ax,ax
           jnz   u7
           pop   ax    
          
           cmp   al,1
           jne   u1
           call  budilnik_1
           jmp   ustan_ret
      u1:  cmp   al,2
           jne   u2
           call  budilnik_2
           jmp   ustan_ret
      u2:  cmp   al,4
           jne   u3
           call  taimer
           jmp   ustan_ret
      u3:  cmp   al,8
           jne   u4
           call  clock
           jmp   ustan_ret
      u4:  cmp   al,010h
           jne   u5
           call  plus_1
           jmp   ustan_ret
      u5:  cmp   al,020h
           jne   u6
           call  minus_1
           jmp   ustan_ret
      u6:  cmp   al,040h
           jne   ustan_ret
           call  kor
  ustan_ret: ret
in_port_1 endp

budilnik_1 proc near           ;кнопка будильника_1
           not   fbud1
           mov   Fbud2,0
           mov   Ftaim,0
           mov   Fchas,0    
           mov   nom,0     
           ret   
budilnik_1 endp

budilnik_2 proc near            ;кнопка будильника_2          
           not   fbud2
           mov   Fbud1,0      
           mov   Ftaim,0
           mov   Fchas,0
           mov   nom,0
          ret
budilnik_2 endp

taimer proc near                 ;кнопка таймер
           not   ftaim
           mov   Fbud1,0
           mov   Fbud2,0                 
           mov   Fchas,0
           mov   nom,0
          ret
taimer endp

clock proc near                 ;кнопка часы
           mov   Fbud1,0
           mov   Fbud2,0
           mov   Ftaim,0
           not   fchas
           mov   al,chas[0]
           mov   chas_1[0],al
           mov   al,chas[1]
           mov   chas_1[1],al
           mov   al,chas[2]
           mov   chas_1[2],al
           mov   nom,0
           ret
clock endp

plus_1 proc near                ;кнопка  "+1"
           xor   ax,ax
           mov   al,nom
           cmp   dh,3
           je    plus_ret
           mov   flag,0ffh
           mov   si,ax
           mov   al,rez[si]
           add   al,1
           daa
           mov   dl,al
           cmp   si,0 
           je    p4
           cmp   si,1
           jnz   p5
      p4:  cmp   dl,01100000b
           jnz   p6
           mov   dl,0
           jmp   p6
      p5:  cmp   dl,00100100b
           jnz   p6
           mov   dl,0                  
      p6:  cmp   fbud1,0ffh
           jnz   p1
           mov   bud_1[si],dl
     p1:   cmp   fbud2,0ffh
           jnz   p2
           mov   bud_2[si],dl
     p2:   cmp   ftaim,0ffh
           jnz   p3
           mov   taim[si],dl
     p3:   cmp   fchas,0ffh
           jnz   plus_ret
           mov   chas_1[si],dl           
 plus_ret: ret
plus_1 endp

minus_1 proc near                ;кнопка  "-1"
           xor   ax,ax
           mov   al,nom
           cmp   dh,3
           je    minus_ret
           mov   flag,0ffh
           mov   si,ax
           mov   al,rez[si]          
           sub   al,1
           das
           mov   dl,al
           cmp   dl,10011001b
           jnz   m6
      m7:  cmp   si,0 
           je    m4
           cmp   si,1
           jnz   m5
      m4:  mov   dl,01011001b
           jmp   m6
      m5:  mov   dl,00100011b                  
      m6:  cmp   fbud1,0ffh
           jnz   m1
           mov   bud_1[si],dl
      m1:  cmp   fbud2,0ffh
           jnz   m2
           mov   bud_2[si],dl
      m2:  cmp   ftaim,0ffh
           jnz   m3
           mov   taim[si],dl
      m3:  cmp   fchas,0ffh
           jnz   minus_ret
           mov   chas_1[si],dl
  minus_ret:ret
minus_1 endp

kor proc near                     ;выбор корректируемого поля          
           cmp   fbud1,0ffh
           je    b5        
           cmp   fbud2,0ffh
           je    b5       
           cmp   ftaim,0ffh
           je    b5        
           cmp   fchas,0ffh
           jne   kor_ret
       b5: mov   al,nom
           inc   al
           cmp   al,3
           jne   b6
           mov   al,0
       b6: mov   nom,al
  kor_ret:ret
kor endp

rab_taimer proc near              ;работа таймера           
           cmp   taim_wkl,0ffh
           jnz   rab_taim_ret
           mov   ax,tik_taim
           inc   ax
           mov   tik_taim,ax
           cmp   ax,0f00h
           jne   rab_taim_ret
           mov   tik_taim,0
           mov   al,taim[0]
           dec   al
           das
           mov   taim[0],al
           cmp   taim[0],10011001b
           jnz   rab_taim_ret           
           mov   taim[0],01011001b
           mov   al,taim[1] 
           dec   al
           das  
           mov   taim[1],al 
           cmp   taim[1],10011001b
           jnz   rab_taim_ret           
           mov   taim[1],01011001b
           mov   al,taim[2] 
           dec   al
           das  
           mov   taim[2],al 
           cmp   taim[2],10011001b        
           jnz   rab_taim_ret
           mov   taim[0],0
           mov   taim[1],0
           mov   taim[2],0
           mov   t_1,0ffh
           jmp   rab_taim_ret
 rab_taim_ret: ret      
rab_taimer endp
                        
rab_chas proc near                    ;установка часов
           cmp   Fchas,0ffh
           jnz   rab_chas_ret
           cmp   flag,0ffh
           jnz   rab_chas_ret
           mov   al,chas_1[0]
           mov   chas[0],al
           mov   al,chas_1[1]
           mov   chas[1],al
           mov   al,chas_1[2]
           mov   chas[2],al
rab_chas_ret:ret          
rab_chas endp
                 
rab_budilnik_1 proc near              ;работа будильника_1
           cmp   bud1_wkl,0ffh
           jnz   rab_bud1_ret
           mov   al,bud_1[2]
           cmp   chas[2],al
           jnz   rab_bud1_ret
           mov   al,bud_1[1]
           cmp   chas[1],al
           jnz   rab_bud1_ret
           mov   al,bud_1[0]
           cmp   chas[0],al
           jnz   rab_bud1_ret
           mov   b_1,0ffh        
rab_bud1_ret:ret
rab_budilnik_1 endp

rab_budilnik_2 proc near              ;работа будильника_2
           cmp   bud2_wkl,0ffh
           jnz   rab_bud2_ret
           mov   al,bud_2[2]
           cmp   chas[2],al
           jnz   rab_bud2_ret
           mov   al,bud_2[1]
           cmp   chas[1],al
           jnz   rab_bud2_ret
           mov   al,bud_2[0]
           cmp   chas[0],al
           jnz   rab_bud2_ret
           mov   b_2,0ffh
rab_bud2_ret: ret
rab_budilnik_2 endp

Swetodiod proc near              ;вывод на двоичные индикаторы
           cmp   b_1,0ffh
           jnz   s25
           cmp   tik_chas,780h
           ja    s26
           or    diod,00010000b
           jmp   s2
      s26: and   diod,11101111b
           jmp   s2
      s25: cmp   bud1_wkl,0ffh
           jnz   s1
      s10: or    diod,00010000b
           jmp   s2
      s1:  cmp   fbud1,0ffh
           jnz   s11
           cmp   f_tik,0ffh
           je    s10
      s11: and   diod,11101111b
      
      s2:  cmp   b_2,0ffh
           jnz   s23
           cmp   tik_chas,780h
           ja    s24
           or    diod,00100000b
           jmp   s4
      s24: and   diod,11011111b
           jmp   s4
      s23: cmp   bud2_wkl,0ffh
           jnz   s12
      s13: or    diod,00100000b
           jmp   s4           
      s12: cmp   fbud2,0ffh
           jnz   s3
           cmp   f_tik,0ffh
           je    s13
      s3:  and   diod,11011111b
      
      s4:  cmp   t_1,0ffh
           jnz   s20
           cmp   tik_chas,780h
           ja    s21
           or    diod,01000000b
           jmp   s6
     s21:  and   diod,10111111b
           jmp   s6
     s20:  cmp   taim_wkl,0ffh
           jnz   s14
     s15:  or    diod,01000000b
           jmp   s6           
     s14:  cmp   ftaim,0ffh
           jnz   s5
           cmp   f_tik,0ffh
           je    s15
      s5:  and   diod,10111111b
      
      s6:  cmp   b_1,0ffh
           je    s7
           cmp   b_2,0ffh
           je    s7
           cmp   t_1,0ffh
           jnz   s9
      s7:  cmp   f_tik,0
           jnz   s9
           or    diod,10000000b
           jmp   s8
      s9:  and   diod,01111111b
      
      s8:  cmp   tik_chas,780h
           ja    s16
           or    diod,00001111b
           jmp   s17
      s16: and   diod,11110000b
      
      s17: mov   al,diod
           out   7,al
           ret
Swetodiod endp

Avt_vikl proc near                ;автоматическое выключение будильников
          cmp   b_1,0ffh
          jnz   a1
          cmp   tik_chas,0
          jnz   a1
          inc   zwon_bud1
          cmp   zwon_bud1,20
          jnz   a1
          mov   zwon_bud1,0
          mov   b_1,0
     a1:  cmp   b_2,0ffh
          jnz   avt_ret
          cmp   tik_chas,0
          jnz   avt_ret
          inc   zwon_bud2
          cmp   zwon_bud2,10
          jnz   avt_ret
          mov   zwon_bud2,0
          mov   b_2,0
  avt_ret:ret        
Avt_vikl endp
         
Tik proc near                        ;работа внутренних часов
           mov   ax,tik_chas
           inc   ax
           mov   tik_chas,ax
           cmp   ax,0f00h
           jne   tik_ret
           not   f_tik
    t_2:   mov   tik_chas,0
           mov   al,chas[0]
           inc   al
           daa
           mov   chas[0],al
           cmp   chas[0],01100000b
           jnz   tik_ret           
           mov   chas[0],0
           mov   al,chas[1] 
           inc   al
           daa  
           mov   chas[1],al 
           cmp   chas[1],01100000b
           jnz   tik_ret           
           mov   chas[1],0
           mov   al,chas[2] 
           inc   al
           daa  
           mov   chas[2],al 
           cmp   chas[2],00100100b
           jnz   tik_ret
           mov   chas[2],0       
 tik_ret:  ret      
Tik endp

form_inf proc near           ;формирование выходной информации          
           cmp   Fbud1,0ffh
           jne   v2          
           mov   dh,nom
           mov   al,bud_1[0]
           mov   rez[0],al
           mov   al,bud_1[1]
           mov   rez[1],al
           mov   al,bud_1[2]
           mov   rez[2],al
           mov   flag,0
           jmp   form_ret
      v2:  cmp   Fbud2,0ffh
           jne   v3
           mov   dh,nom
           mov   al,bud_2[0]
           mov   rez[0],al
           mov   al,bud_2[1]
           mov   rez[1],al
           mov   al,bud_2[2]
           mov   rez[2],al
           mov   flag,0
           jmp   form_ret
      v3:  cmp   ftaim,0ffh
           jne   v4
           mov   dh,nom
           mov   al,taim[0]
           mov   rez[0],al
           mov   al,taim[1]
           mov   rez[1],al
           mov   al,taim[2]
           mov   rez[2],al
           mov   flag,0
           jmp   form_ret
      v4:  cmp   fchas,0ffh
           jnz   v5
           mov   dh,nom
           mov   al,chas_1[0]
           mov   rez[0],al
           mov   al,chas_1[1]
           mov   rez[1],al
           mov   al,chas_1[2]
           mov   rez[2],al
           jmp   form_ret        
      v5:  mov   al,chas[0]
           mov   rez[0],al
           mov   al,chas[1]
           mov   rez[1],al
           mov   al,chas[2]
           mov   rez[2],al      
           mov   dh,3
           mov   flag,0      
form_ret:ret
form_inf endp

Vivod proc near                      ;вывод на дисплей
           lea   bx,image                   
           mov   al,rez[0]; вывод секунд
           mov   ah,al
           and   al,0fh
           xlat
           cmp   dh,0
           jne   v6
           add   al,080h     ;для вывода точки
      v6:  out   1,al   
           mov   al,ah
           shr   al,4
           xlat
           out   2,al          
           mov   al,rez[1]; вывод минут
           mov   ah,al
           and   al,0fh
           xlat
           cmp   dh,1
           jne   v7
           add   al,080h     ;для вывода точки
      v7:  out   3,al    
           mov   al,ah
           shr   al,4
           xlat
           out   4,al
           mov   al,rez[2]; вывод часов
           mov   ah,al
           and   al,0fh
           xlat
           cmp   dh,2
           jne   v8
           add   al,080h      ;для вывода точки
      v8:  out   5,al    
           mov   al,ah
           shr   al,4
           xlat
           out   6,al         
vivod_ret:ret
Vivod endp


Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           call  obnulenie
;Здесь размещается код программы
 begin:    call  in_port_2
           call  in_port_1          
           call  tik
           call  rab_taimer
           call  rab_chas
           call  rab_budilnik_1
           call  rab_budilnik_2
           call  swetodiod
           call  Avt_vikl
           call  form_inf
           call  vivod
           jmp   begin

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
