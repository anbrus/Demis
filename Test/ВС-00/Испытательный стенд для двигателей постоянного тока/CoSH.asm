.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

startdelay equ   15
accel      equ   1
st_step    equ   13

Data       SEGMENT AT 40h use16

q_cur      db    ?           ;текущее значение скважности

q_cur1     db    ?
p_cur      db    ?

old_q      db    ?
old_p      db    ?

mode_f     db    ?
spin_p     db    ?
;---------------------------------------------------------------
del_cur    dw    ?
mode_dv    db    ?
step       dw    ?
corr       dw    ?
stop_pr    db    ?
br_cur     db    ?
del_tst    dw    ?
start_dv   db    ?

Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 200h use16
           dw    20 dup (?)
StkTop     Label Word
Stk        ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

digit      db    3fh,0ch,76h,5eh,4dh,5bh,7bh,0eh,7fh,5fh

;образы графиков скважности (построчно для каждой панельки)
q_im       db    255,0,0,0,0,0,0,0
           db    255,0,0,0,0,0,0,0
           db    255,0,0,0,0,0,0,0
           db    255,0,0,0,0,0,0,0    ;скважность=1
           
           db    255,0,0,0,0,0,0,0
           db    255,0,0,0,0,0,0,0
           db    255,0,0,0,0,0,0,0
           db    135,132,132,132,132,132,132,252
           
           db    255,0,0,0,0,0,0,0
           db    255,0,0,0,0,0,0,0
           db    255,128,128,128,128,128,128,128
           db    128,128,128,128,128,128,128,255
           
           db    255,0,0,0,0,0,0,0
           db    255,0,0,0,0,0,0,0
           db    7,4,4,4,4,4,4,252
           db    128,128,128,128,128,128,128,255
           
           db    255,0,0,0,0,0,0,0
           db    255,128,128,128,128,128,128,128
           db    0,0,0,0,0,0,0,255
           db    128,128,128,128,128,128,128,255
           
           db    255,0,0,0,0,0,0,0
           db    7,4,4,4,4,4,4,252
           db    0,0,0,0,0,0,0,255
           db    128,128,128,128,128,128,128,255
           
           db    7,4,4,4,4,4,4,252
           db    0,0,0,0,0,0,0,255
           db    0,0,0,0,0,0,0,255
           db    128,128,128,128,128,128,128,255
           
           db    0,0,0,0,0,0,0,255
           db    0,0,0,0,0,0,0,255
           db    0,0,0,0,0,0,0,255
           db    0,0,0,0,0,0,0,255
           
n_im       db    7,56,192,0,0,0,0,0        ;образы n от P или Q
           db    7,56,192,0,0,0,0,0
           db    3,12,112,128,0,0,0,0
           db    3,12,112,128,0,0,0,0
           db    3,4,24,32,192,0,0,0
           db    3,4,8,48,64,128,0,0
           db    3,4,8,48,64,128,0,0
           db    1,2,4,8,48,64,128,0
                      
           ASSUME cs:Code,ds:Data,es:Data

init       proc  near
           xor   al,al
           mov   ah,al
           mov   q_cur,al
           
           mov   q_cur1,al
           
           mov   p_cur,al
           mov   mode_f,al
           mov   stop_pr,al
           mov   start_dv,al
           mov   step,ax
           mov   corr,ax
           
           mov   al,1
           mov   spin_p,al
           mov   mode_dv,al

           mov   ax,startdelay
           mov   del_cur,ax
           
;           mov   cx,255
;cl_port1:  mov   dx,cx
;           xor   al,al
;           out   dx,al
;           loop  cl_port1
           ret
init       endp

w_start    proc  near
           in    al,010h
           test  al,01h
           jz    w_st1
           cmp   start_dv,255
           je    w_st1
           mov   start_dv,255
           mov   cx,255
cl_port:   mov   dx,cx
           xor   al,al
           out   dx,al
           loop  cl_port
w_st1:     ret
w_start    endp

displ_q    proc  near
           mov   bl,q_cur1
           and   bl,11100000b    ;обнуляем 5 младших битов
           xor   bh,bh
           lea   si,q_im
           
           mov   dh,2
                      
d_q1:      mov   dl,1
           xor   al,al
           out   1,al
           out   0,al
           mov   al,dh
           out   2,al
                      
d_q2:      xor   al,al
           out   0,al
           mov   al,cs:[bx+si]
           out   1,al
           mov   al,dl
           out   0,al
           inc   bx
           shl   dl,1
           jnc   d_q2
           shl   dh,1
           cmp   dh,32
           jbe   d_q1
           ret
displ_q    endp

displ_n    proc  near
           cmp   start_dv,255
           jne   displ_q1
           cmp   mode_f,0
           je    displ_q1
           cmp   mode_f,1
           je    ot_q
           mov   al,p_cur
           jmp   d_ok
ot_q:      mov   al,q_cur
d_ok:      shr   al,5
           shl   al,3
           xor   ah,ah
           mov   bx,ax
           lea   si,n_im
           xor   al,al
           out   0,al
           out   1,al
           out   2,al
           mov   al,1
           out   2,al
           mov   dl,1
d_n1:      xor   al,al
           out   0,al
           out   1,al
           mov   al,cs:[bx+si]
           out   1,al
           mov   al,dl
           out   0,al
           inc   bx
           shl   dl,1
           jnc   d_n1                      
displ_q1:  ret
displ_n    endp

r_acp_q    proc  near
           mov   al,q_cur
           mov   old_q,al
           mov   al,mode_f
           cmp   al,2
           je    no_r_q
           cmp   stop_pr,255
           je    no_r_q
r_prin1:   xor   al,al
           out   2,al
           mov   al,10000000b
           out   2,al
w_q_rdy:   in    al,10h
           test  al,80h
           jz    w_q_rdy
           in    al,20h
           cmp   old_q,al
           je    no_ch_q
           mov   q_cur,al
           
           mov   q_cur1,al
           
           mov   mode_f,1
           ret
no_r_q:    cmp   start_dv,0
           je    r_prin1
no_ch_q:   ret
r_acp_q    endp

dig_p      proc  near
           mov   al,p_cur
           aam
           lea   bx,digit
           add   bl,al
           push  ax
           mov   al,cs:[bx]
           out   42h,al
           pop   ax
           mov   al,ah
           aam
           lea   bx,digit
           add   bl,al
           push  ax
           mov   al,cs:[bx]
           out   41h,al
           pop   ax
           mov   al,ah
           lea   bx,digit
           add   bl,al
           mov   al,cs:[bx]
           out   40h,al
           ret
dig_p      endp

s_p        proc  near
           mov   al,p_cur
           
           ret
s_p        endp

r_acp_p    proc  near
           call  dig_p
           call  s_p
           mov   al,p_cur
           mov   old_p,al
           mov   al,mode_f
           cmp   al,1
           je    no_r_p
           cmp   stop_pr,255
           je    no_r_p
r_prin2:   xor   al,al
           out   2,al
           mov   al,01000000b
           out   2,al
w_p_rdy:   in    al,10h
           test  al,40h
           jz    w_p_rdy
           in    al,21h
           cmp   old_p,al
           je    no_ch_p
           mov   p_cur,al
           mov   mode_f,2
           ret
no_r_p:    cmp   start_dv,0
           je   r_prin2
no_ch_p:   ret
r_acp_p    endp

disp_st    proc  near
           mov   al,mode_f
           out   4,al
           mov   al,spin_p
           out   3,al
           ret
disp_st    endp

calc_corr  proc  near
           cmp   mode_f,0
           je    corr_q
           cmp   mode_f,1
           jne   no_c_q
           mov   al,q_cur
           shr   al,5
           xor   ah,ah
           mov   corr,ax
           ret

no_c_q:    mov   al,p_cur    ;будем считать нагрузку более весомой (в 4 раза)
           shr   al,3
           xor   ah,ah
           mov   corr,ax
           ret
corr_q:    mov   corr,0
           ret
calc_corr  endp

brake_acp  proc  near
           xor   al,al
           out   2,al
           mov   al,00100000b
           out   2,al
w_b_rdy:   in    al,10h
           test  al,20h
           jz    w_b_rdy
           in    al,22h
           mov   br_cur,al
           ret
brake_acp  endp

calc_razg  proc  near
           mov   al,q_cur
           shr   al,3
           mov   ah,al
           mov   al,p_cur
           shr   al,3
           add   ah,al
           add   ah,25
           mov   al,ah
           aam
           lea   bx,digit
           add   bl,al
           push  ax
           mov   al,cs:[bx]
           out   31h,al
           pop   ax
           lea   bx,digit
           add   bl,ah
           mov   al,cs:[bx]
           out   30h,al
           ret
calc_razg  endp

spin_im    proc  near
           cmp   start_dv,255
           jne   q_spin

           ;mov   al,p_cur
           ;add   al,q_cur
           ;jnc   ok_spin
           ;mov   al,64
           ;out   30h,al
           ;out   31h,al
           ;ret
                      
ok_spin:   dec   del_cur
           cmp   del_cur,0
           jne   q_spin
           mov   ax,startdelay
           sub   ax,step
           mov   del_cur,ax
           mov   del_tst,ax           
           mov   al,mode_dv
           cmp   al,1
           jne   no_razg
           
           add   step,accel
           cmp   step,st_step
           jb    no_razg
           mov   al,2
           mov   mode_dv,al
           call  calc_razg          ;вывод времени разгона
no_razg:   cmp   stop_pr,255
           je    brake
           
           call  calc_corr       ;коррекция задержки (от Q или P)
           mov   ax,corr
           add   del_cur,ax
           jmp   no_brake
           
brake:     call  brake_acp
           mov   al,br_cur
           shr   al,6
           or    al,1
           xor   ah,ah
           add   corr,ax
           mov   ax,corr
           add   del_cur,ax
           mov   ax,del_cur
           mov   del_tst,ax
           
no_brake:  rol   spin_p,1
q_spin:    ret
spin_im    endp

w_stop     proc  near
           in    al,10h
           test  al,2
           jz    no_stop_p
           mov   stop_pr,255
           
           mov   q_cur1,255
           
no_stop_p: ret
w_stop     endp

calc_vib   proc  near
           mov   bx,73
           mov   al,br_cur
           shr   al,5
           xor   ah,ah
           sub   bx,ax
           cmp   mode_f,0
           je    alldon
           cmp   mode_f,1
           je    make_q
           mov   al,p_cur
           shr   al,2
           xor   ah,ah
           sub   bx,ax
           jmp   alldon
make_q:    mov   al,q_cur
           shr   al,3
           xor   ah,ah
           sub   bx,ax
alldon:    mov   al,bl
           aam
           lea   bx,digit
           add   bl,al
           push  ax
           mov   al,cs:[bx]
           out   33h,al
           pop   ax
           lea   bx,digit
           add   bl,ah
           mov   al,cs:[bx]
           out   32h,al
           ret
calc_vib   endp

t_stop     proc  near
           cmp   stop_pr,255
           jne   q_t_s
           cmp   del_tst,startdelay*2
           jl    q_t_s
           call  calc_vib
           call  init
q_t_s:     ret
t_stop     endp

no_m_tst   proc
           cmp   start_dv,255
           jne   no_m_q
           mov   al,q_cur
           add   al,p_cur
           jnc   no_m_q
           mov   al,64
           out   31h,al
           out   30h,al
;no_m_w1:   in    al,10h
;           test  al,80h
;           jz    no_m_w1
           call  init
no_m_q:    ret
no_m_tst   endp

Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы

           call  init
Cycle:     call  w_start
           call  r_acp_q
           call  r_acp_p
           call  displ_q
           call  displ_n
           call  disp_st

           call  t_stop
;----------------------------------
           call  no_m_tst
;----------------------------------
           call  spin_im
           call  w_stop
           jmp   cycle
           
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
