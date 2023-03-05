RomSize    EQU   4096
Delay      EQU   000ffh


Data       SEGMENT AT 0
current    db    ?     
tochka     db    ?
del_cur    DW    ? 
port0      dw    ?
port1      dw    ?
port2      dw    ?
acp        db    ?
mode       db    ?
nos        db    ?

Data       ENDS

Code       segment 
           assume cs:Code,ds:Data

Im:      
           db 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh   ;образы временных диаграмм 
           db 0feh,0feh,0feh,0feh,0feh,0feh,0feh,000h
           db 000h,0feh,0feh,0feh,0feh,0feh,0feh,000h   
           db 07fh,000h,0feh,0feh,0feh,0feh,0feh,000h
           db 07fh,000h,0feh,0feh,0feh,0feh,0feh,000h
           db 07fh,07fh,000h,0feh,0feh,0feh,0feh,000h
           db 07fh,07fh,000h,0feh,0feh,0feh,0feh,000h
           db 07fh,07fh,07fh,000h,0feh,0feh,0feh,000h
           db 07fh,07fh,07fh,000h,0feh,0feh,0feh,000h
           db 07fh,07fh,07fh,07fh,000h,0feh,0feh,000h
           db 07fh,07fh,07fh,07fh,000h,0feh,0feh,000h
           db 07fh,07fh,07fh,07fh,07fh,000h,0feh,000h
           db 07fh,07fh,07fh,07fh,07fh,07fh,0000,000h
           db 07fh,07fh,07fh,07fh,07fh,07fh,07fh,000h
           db 07fh,07fh,07fh,07fh,07fh,07fh,07fh,07fh
           db 07fh,07fh,07fh,07fh,07fh,07fh,07fh,07fh
Im2:       
          ; db 00fh,0f1h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh   ;образы графиков
           db 01fh,0e3h,0fdh,0feh,0feh,0feh,0feh,0feh
           db 01fh,0e7h,0fbh,0fdh,0fdh,0fdh,0fdh,0fdh
           db 03fh,0cfh,0f7h,0fbh,0fbh,0fbh,0fbh,0fbh
           db 03fh,0dfh,0efh,0f7h,0f7h,0f7h,0f7h,0f7h
           db 07fh,0bfh,0dfh,0dfh,0efh,0efh,0efh,0efh
           db 07fh,0bfh,0bfh,0bfh,0dfh,0dfh,0dfh,0dfh
           db 07fh,07fh,07fh,07fh,0bfh,0bfh,0bfh,0bfh
           db 07fh,07fh,07fh,07fh,07fh,07fh,07fh,07fh

im3:       db 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh
           db 0feh,0feh,0fdh,0fdh,0fdh,0fdh,0fdh,0fdh
           db 0feh,0feh,0fdh,0fbh,0fbh,0fbh,0fbh,0fbh
           db 0feh,0feh,0f9h,0f7h,0f7h,0f7h,0f7h,0f7h
           db 0feh,0feh,0f9h,0f7h,0efh,0efh,0efh,0efh
           db 0feh,0feh,0f9h,0e7h,0dfh,0dfh,0dfh,0dfh
           db 0feh,0feh,0f1h,0cfh,0bfh,0bfh,0bfh,0bfh
           db 0feh,0feh,0f1h,0cfh,0bfh,07fh,07fh,07fh
         ; db 0feh,0feh,0f1h,0cfh,0bfh,07fh,0ffh,0ffh

vub:       db 05fh,05eh
           db 07fh,05bh
           db 00eh,076h
           db 07bh,05bh
           db 05bh,00ch
           db 04dh,03fh
           db 076h,05eh
           db 00ch,05bh   
erase:     db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh                 

disp proc near
 
           mov   ch,1        ;Indicator Counter
OutNextInd:
           mov   al,0
           mov   dx,port1
           out   dx ,al        ;Turn off cols
           mov   al,ch
           mov   dx,port2          
           out   dx,al        ;Turn on current matrix
           mov   cl,1        ;Col Counter
          
OutNextCol:
           mov   ah,0
           mov   al,0
           mov   dx,port1
           out   dx,al        ;Turn off cols
           mov   al,es:[bx]
           not   al
           mov   dx,port0
           out   dx,al        ;Set rows
           mov   al,cl
           mov   dx,port1
           out   dx,al        ;Turn on current col
           shl   cl,1
           inc   bx
           jnc   OutNextCol
           ret
disp endp                 

init proc near 
           mov   tochka,00000001b
           mov   cx,delay
           mov   del_cur,cx     
           mov   mode,00h 
           mov   nos,00h
           ret
init endp


time_erase proc near
           lea bx,erase      ;стирание графика временных диаграмм
           mov ax,0
           add bx,ax
           mov port0,00h
           mov port1,01h
           mov port2,02h
           call disp
           ret
time_erase endp

time_delay proc near
    n77:   dec   cx          ; реализация задержки
           cmp   cx,0        
           jnz   n77   
           mov cx,del_cur
    nn:    dec   cx
           cmp   cx,0        
           jnz   nn  
           mov cx,del_cur
           ret
time_delay endp

spinning   proc near
           ror  tochka,1     ;движение точки
           mov al,tochka 
           out 04h,al
           ret
spinning endp

strob1  proc near
           cmp mode,00h
           jnz ss2
           mov al,0          ;стробирование АЦП
           out 010h,al
           mov al,1
           out 010h,al  
           in al,1 
ss2:       ret
strob1 endp

time_build proc near
           mov acp,al        ;построение временных диаграмм
           shr al,4
           shl al,3 
           mov ah,0                     
           lea bx,im         
           add bx,ax
           mov port0,00h
           mov port1,01h
           mov port2,02h
           call disp
           ret
time_build endp

ind_razgon proc near
           cmp mode,00h
           jnz ss0
           mov al,00eh       ; индикация переходного процесса
           out 08h,al
           mov al,05bh
           out 09h,al
ss0:        ret
ind_razgon endp

pusk proc near 
n0:        in al,0           ;ожидание ПУСК
           cmp al,01h
           jnz n0        
           ret
pusk endp

spin_change proc near
           mov ah,acp        ;регулирование скорости вращения точки
           mov al,0
           shr ah,5
           shl ah,5
           mov dx,delay
           add dx,ax
           mov del_cur,dx
           ret

spin_change endp

NotT_build proc near
           cmp mode,00h
           jnz ss3
           mov al,acp        ; построение графика N(t) для каждого Q
           lea bx,im2
           shr al,5
           shl al,3
           mov ah,0
           add bx,ax
           mov port0,06h
           mov port1,07h
           mov port2,05h
           call disp
ss3:       ret
NotT_build endp

graf2_erase proc near
           lea bx,erase      ;стирание графика
           mov ax,0
           add bx,ax
           mov port0,020h
           mov port1,021h
           mov port2,022h
           call disp
           ret
graf2_erase endp

graf1_erase proc near
           lea bx,erase     ; стирание графика 
           mov ax,0
           add bx,ax
           mov port0,06h
           mov port1,07h
           mov port2,05h
           call disp
           ret
graf1_erase endp
 
strob2 proc near
           cmp mode,0ffh
           jnz gg
           mov al,0          ;стробирует АЦП
           out 023h,al
           mov al,1
           out 023h,al     
           in al,023h
           mov acp,al
gg:        ret
strob2 endp

NotT2 proc near
           cmp mode,0ffh
           jnz gg2
           mov acp,al          ;график N(t) для каждого М
           shr al,5
           shl al,3 
           mov ah,0                     
           lea bx,im3
           add bx,ax
           mov port0,020h
           mov port1,021h
           mov port2,022h
           call disp 
gg2:       ret
NotT2 endp

ind_time_vub proc near
           cmp nos,0ffh
           jnz aa
           mov al,acp        ;индикация времени выбега
           shr al,5
           shl al,1
           mov ah,0
           lea bx,vub
           add bx,ax
           mov al,es:[bx]
           out 025h,al
           mov al,es:[bx]+1
           out 026h,al
           call graf2_erase
           call time_erase
           call pusk
aa:        mov nos,00h
           ret
ind_time_vub endp

mode_choose proc near
           in al,030h
           cmp al,01h
           jnz ww
           mov mode,0ffh
ww:        call graf1_erase
           ret
           
mode_choose endp

mode_choose2 proc near
           in al,030h
           cmp al,00h
           jnz ww2
           mov mode,000h
ww2:       call graf2_erase
           ret
           
mode_choose2 endp

No_Signal proc near
           cmp mode,0ffh
           jnz qq
           in al,00h
           cmp al,04h
           jnz qq 
           mov nos,0ffh
qq:        ret
No_signal endp

Start:
           mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           
           call init 
           call pusk
new:       call time_erase
           call time_delay
           call spinning
           call spin_change
           call strob1
           call time_build
           call mode_choose
           call strob1
           call ind_razgon
           call NotT_build
           call strob2
           call NotT2
           call mode_choose2
           call No_Signal
           call Ind_time_vub
     
      jmp new
           
           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end
