.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

Data       SEGMENT AT 40h use16
           vvs1 db ?
           vvs2 db ?
           vzlom1 db ?
           vzlom2 db ?
           pojar1 db ?
           pojar2 db ?
           tst db ?
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT AT 100h use16
;Задайте необходимый размер стека
           dw    20 dup (?)
StkTop     Label Word
Stk        ENDS


Code       SEGMENT use16
           ASSUME cs:Code,ds:Data,es:Data
           
init proc near
           mov vvs1,0
           mov vvs2,0
           mov vzlom1,0 
           mov vzlom2,0
           mov pojar1,0
           mov pojar2,0
           mov tst,0
           ret
init endp           
           
Wwodklaw proc        ;ввод с клавы
          
          mov ch,0
          mov cl,1
       t2:mov al,cl
          out 00h,al
          in al,00h
         
          cmp al,0
          jne t6            ;если нет уходим кл.нажата           
          
          cmp cl,2          
          je  t4   
          shl cl,1
          jmp t2
          
     t6:  push ax
     t5:  in al,0h
          or al,al
          jnz t5
          pop ax
          
     t1: cmp cl,1
         jne t3  
         xor vvs1,al
         test vvs1,al
         jnz t4
         not al
         and vzlom1,al
         jmp t4
     t3: xor vvs2,al
         test vvs2,al
         jnz t4
         not al
         and vzlom2,al  
     t4:ret      
 wwodklaw ENDP  
prout  proc near
          
           mov cx,0ffffh
 zd1:      nop
           nop
           nop
           nop
           nop
           nop
           loop zd1           
           mov al,vvs1                    
           out 01h,al
           mov al,vvs2
           out 02h,al
           mov al,0h
           out 03h,al
           out 04h,al
           
           
           mov cx,0ffffh
 zd:       nop
           nop
           nop
           nop
           nop
           nop
           loop zd
 
           mov al,vvs2
           xor al,vzlom2
           out 02h,al
           mov al,vvs1
           xor al,vzlom1
           out 01h,al
           
           mov al,pojar1
           out 03h,al
           mov al,pojar2
           out 04h,al
           
           ret
prout endp 
prvzlom proc near  ;чтение датчиков взлома
           in al,01h
           cmp al,0                      
           je vz1
           
           push ax
     t55:  in al,01h
           or al,al
           jnz t55
           pop ax 
           
           test vzlom1,al ; проверка на двойное нажатие
           jnz vz2
                     
           test al,vvs1
           jz vz2          
           xor vzlom1,al         
                 
           jmp vz2

              
vz1:       in al,02h
           cmp al,0
           je vz2
           push ax
     tt5:  in al,02h
           or al,al
           jnz tt5
           pop ax
           
           test vzlom2,al ; проверка на двойное нажатие
           jnz vz2
           
           test al,vvs2
           jz vz2
           xor vzlom2,al
           jmp vz2
vz2:       ret
prvzlom endp

prpojar proc near ;  чтение датчиков пожара
           in al,03h
           cmp al,0                      
           je pj1
           
           push ax
     pj2:  in al,03h
           or al,al
           jnz pj2
           pop ax
           xor pojar1,al
           jmp pjr
      pj1: in al,04h
           cmp al,0                      
           je pjr
           
            push ax
     pj3:  in al,04h
           or al,al
           jnz pj3
           pop ax
           xor pojar2,al
    pjr:   ret 
prpojar endp 
przvuk proc near ; пищалка
           cmp vzlom1,0
           jne zv1
           cmp vzlom2,0       
           jne zv1
           cmp pojar1,0
           jne zv1
           cmp pojar2,0
           je zv2
zv1:       mov al,01h
           out 06h,al
           jmp zv0
zv2:       
           mov al,0
           out 06h,al
zv0:       ret
przvuk endp  
prspeckn proc near ; спец кнопки
           in al,05h
           cmp al,01h
           jne st1
           call init
           mov al,0
           out 05h,al
           jmp st0
 st1:      cmp al,02h
           jne st0
           mov vvs1,0ffh          
           mov vvs2,0ffh
 st0:      ret
prspeckn endp  

prdvl proc near
           mov al,02h
           out 05h,al
           cmp vvs1,0h
           jne a1
           cmp vvs2,0h
           je a2
a1:        mov al,03h
           out 05h,al
           mov tst,03h
a2:        ret  
prdvl endp                                                 
 
Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;Здесь размещается код программы
           call init                      
a0:        call wwodklaw 
           call prout
           call prvzlom
           call prpojar
           call przvuk
           call prspeckn
           call prdvl
           jmp a0
           

;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
