.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

IntTable   SEGMENT AT 0 use16
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT AT 40h use16
;Здесь размещаются описания переменных
   
    mody    db ? 
    num  db ?
    sum  db ?
    j  db ? 
    one  db ?
    ten  db ?
    hour db ?
    minit db ?
    sec db ?
    hour_1 db ?
    minit_1 db ?
    sec_1 db ?
    hour_2 db ?
    minit_2 db ?
    sec_2 db ?
    NumPlay db ?
    KeyDec db ?
    KeyInc db ?
    KeyChUn db ?
    KeyChPlay db ?
    Num_Field db ?
    Mode db ?
    Push_1 db ?
    Push_2 db ?
    number db ?
    unit_time db ?
    NP db ?
    NF db ?
    fin db ?
    Port1 db ?
    Port2 db ?
    msec dw ?
    temp db ?
    num_push db ?
    Pause db ?
    Unset db ?
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT Stack 'para' use16  ; AT 60h use16
;Задайте необходимый размер стека
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
nach dw 99
symbols    db  3fh,0ch,76h,5eh,  4dh,5bh,7bh,0eh,  7fh,5fh;,6fh,79h,  33h,7ch,73h,63h

;Здесь размещаются описания констант
InitData   ENDS

Code       SEGMENT use16

           ASSUME cs:Code,ds:InitData,es:Data
           
VibrDestr proc
VD1 : mov ah,al
      mov bh,0
Vd2 : in al,0
      cmp ah,al
      jne Vd1
      inc bh
      cmp bh,50
      jne VD2
      mov al,ah
      ret
VibrDestr EndP                       
ModiFy  Proc
          lea bx,symbols
          mov   al,mody
          and   al,0Fh
          xlat 
          mov ah,al       
          mov   al,mody
          shr   al,4
          xlat  
          xchg al,ah
          mov one,al
          mov ten,ah 
          ret
Modify endp          
Summa proc
           cmp KeyInc,1
           jne exit_sum
           add   sum,1
           mov al,sum
           daa
           mov sum,al
           mov KeyInc,0
 exit_sum:          
ret
summa   Endp 
Difference proc       
           cmp KeyDec,1
           jne exit_dif
           sub sum,1
           mov al,sum
           das
           mov sum,al
           mov KeyDec,0
exit_dif:           
           ret
Difference  EndP         
Indicate_number macro Port1,port2,number,NP,NF 
        local indic  
        mov al,number
        mov mody,al
        call modify   
        cmp mode,0ffH
        je Indic 
        cmp NumPlay,NP
        jne Indic
        cmp Num_Field,NF
        jne Indic
        or one,128
        or ten,128
    Indic:
        mov al,one    
        out Port1,al 
        mov al,ten
        out Port2,al
   EndM
 Indicate proc     
      Indicate_number 2,3,sec_1,0,0                
      Indicate_number 4,5h,minit_1,0,1
      Indicate_number 6h,14h,hour_1,0,2
      Indicate_number  11h,13h,Hour_2,0ffh,2
      Indicate_number 9,10h,minit_2,0FFh,1
      Indicate_number 7,8,sec_2,0FFh,0     
      Indicate_number 20h,21h,num_push,1,1
      call The_End
   ret
  Indicate endP  
ReadKey proc 
    in al,0
    call VibrDestr  
    test al,1
    jnz Key_inc        
    test al,2
    jnz key_dec
    test al,4
    jnz Ch_Play
    test al,8
    jnz Key_Unit    
    test al,16
    jnz Key_Push_1
    test al,32
    jnz Key_Push_2
    test al,64
    jnz Key_Pause
    test al,128
    jnz Key_Unset
    jmp getout
   Key_inc:   mov KeyInc,1
              jmp getout
   Key_dec:   mov KeyDec,1
              jmp getout
  Key_Unit:   mov KeyChUn,1
              jmp getout 
   Ch_Play:   mov KeyChPlay,1
              jmp getout 
Key_Push_1:   mov Push_1,1   
              call Install_Flag_Mode
              jmp getout
Key_Push_2 :  mov Push_2,1
              jmp getout 
  Key_Pause:  not Pause 
              jmp getout
  Key_Unset:  mov unset,0FFh
     getout:
 ret
Readkey endP          

Install_Flag_Mode proc
;cmp Push_1,1
;jne ex_IM
 mov al,0h  
 mov ah,0h
 or al,sec_1
 or ah,sec_2
 or al,minit_1
 or ah,minit_2
 or al,hour_1
 or ah,hour_2
 and al,ah
 cmp al,0
 jz  ex_IM
 mov mode,0FFh
 ex_IM:
 ret
Install_Flag_Mode EndP 
Save_Time proc
   cmp NumPlay,0FFh
   je Time_2   
       mov al,sec
       mov sec_1,al
       mov al,minit
       mov minit_1,al
       mov al,hour
       mov hour_1,al
       jmp exit_st
Time_2:mov al,sec
       mov sec_2,al
       mov al,minit
       mov minit_2,al
       mov al,hour
       mov hour_2,al
exit_St:
ret
Save_Time EndP

Establish proc          
 call summa
 call difference
 ret
Establish EndP
Test_Port Proc 
   WaitBtnDown:
        in    al,0
        test  al,num
        jnz   WaitBtnDown         
   ret
Test_Port endP
Change_Field proc
       cmp KeyChUn,1
       jne exit_cf
       inc Num_field
       cmp Num_field,3
       jne exit_CF
       mov Num_field,0
exit_CF:
       mov KeyChUn,0
       ret
Change_field endP     
Change_Play proc
     cmp KeyChPlay,1
     jne exit_CP
     not NumPlay
 exit_Cp:
     mov KeyChPlay,0
     ret
 Change_Play EndP
 Install_Play proc
    cmp NumPlay,0FFh
    je PlaY_2  
    mov al,sec_1
    mov sec,al
    mov al,minit_1
    mov minit,al
    mov al,Hour_1
    mov hour,al
    jmp Exit_TP
 play_2: mov al,sec_2
         mov sec,al
         mov al,minit_2
         mov minit,al
         mov al,Hour_2
         mov hour,al
Exit_TP:
ret
Install_Play EndP
Install_Time macro Unit_time
  mov al,unit_time
  mov sum,al
  call establish
  mov al,sum
  mov unit_Time,al
 endM
Select_UnitT proc
   cmp Num_field,0
   je set_s
   cmp Num_field,1
   je Set_m
   cmp Num_field,2
   je Set_h   
set_s:mov al,sec
      mov Unit_time,al
      jmp exit_SU
set_m:mov al,minit
      mov unit_time,al
      jmp  exit_SU
set_H : mov al,hour
       mov unit_time,al
exit_SU:
 ret
 Select_unitT endP                       
 Save_Unit proc
   cmp Num_field,0
   je save_s
   cmp Num_field,1
   je Save_m
   cmp Num_field,2
   je Save_h
Save_s:mov al,Unit_time
       mov sec,al
       jmp exit_u
Save_m:mov al,Unit_time
       mov minit,al
       jmp exit_u
save_h: mov al,Unit_time
        mov hour,al                 
exit_u:
 ret
 Save_Unit EndP     
 Control_Data proc 
      mov al,hour
      cmp al,4
      jz Min_H     
      cmp al,99h
      jz Max_h
      mov al,minit
      cmp al,60h    
      jz Min_M
      cmp al,99h
      jz Max_M         
      mov al,sec
      cmp al,60h
      jz Min_S
      cmp al,99h
      jz Max_S
      jmp Exit_CD
min_H :mov hour,0 
        jmp Exit_CD 
min_M :mov minit,0
        jmp Exit_CD
min_S :mov sec,0  
       jmp exit_CD
Max_H: mov hour,3  
       jmp Exit_CD
Max_M :mov minit,59h
       jmp Exit_CD
Max_S: mov sec,59h
Exit_CD:
  ret
Control_Data EndP     
   Status proc
   cmp unset,0FFh
   jne exit_STatus
   mov hour_1,0
   mov minit_1,0
   mov sec_1,0
   mov mode,0
   mov hour_2,0
   mov minit_2,0
   mov sec_2,0   
   mov msec,0
   mov sum,0
   mov unset,0
   mov num_push,0
   mov temp,0
   mov fin,0
   mov al,0
   out 1,al
   mov j,0
   mov numPlay,0
   mov num_Field,0
   mov pause,0
 exit_STatus:  
   ret
status EndP    
Test_Down proc      
        cmp msec,1000
        jne exit_TD
        mov msec,0
        mov al,sec
        sub al,1
        das
        mov sec,al 
        cmp sec,99h    
        jne exit_TD
        mov al,minit
        sub al,1
        das
        mov minit,al
        cmp minit,99H
        jne exit_TD
 dec_H: cmp hour,0
        je finish 
        mov al,hour
        sub al,1
        das 
        mov hour,al
        jmp exit_td
finish: 
        mov fin,0ffh
        mov minit,0
        mov sec,0
exit_td:
    ret               
test_down EndP 
The_End proc
     cmp fin,0ffh
     jne exit_Te
     cmp numPlay,0
     jne END_2
     mov al,64
     out 1,al
     jmp exit_Te
end_2:mov al,128
      out 1,al   
exit_Te:
 ret
The_End EndP 
Inc_push proc
   cmp push_1,1
   jne p2   
   cmp temp,0
   jne T_p
   mov numPlay,0ffh
   jmp jamp    
T_p :cmp numPlay,0h
     jne e_P
     Jmp jamp
 P2:cmp push_2,1
    jne e_p
    cmp numPlay,0FFh
    jne e_p  
  jamp: not numPlay
   mov al,temp 
   adc al,1
   daa
   mov temp,al
   cmp temp,0
   je e_p
   mov al,temp
   dec al 
   mov num_push,al
 e_P : 
    mov push_1,0
    mov push_2,0
    ret
Inc_Push  endP   
Count_Down proc
   cmp mode,0FFh
   jne exit_TT        
   cmp Pause,0FFh
   je exit_TT  
   cmp fin,0ffh
   je exit_TT     
   call inc_push
   call install_play
   add msec,1
   call Test_down      
   call Control_data 
 exit_TT:
   ret 
Count_down EndP      
Input_Time proc 
   cmp mode,0FFh
   je exit_InT
   call Change_play 
   call Install_play
   call Change_field     
   call Select_UnitT      
   Install_Time Unit_time
   call Save_Unit
   Call Control_Data
exit_InT:
 ret
 Input_Time endP
Start:
           mov   ax,data
           mov   es,ax
           mov   ax,InitData
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы    
       mov unset,0FFh
        mov num,255
       s: call status
        call readkey
        Call Test_port    
        ;call install_Flag_Mode
        call Input_Time
        call Count_Down    
        call Save_Time 
        call indicate 
   jmp s
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)

           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
