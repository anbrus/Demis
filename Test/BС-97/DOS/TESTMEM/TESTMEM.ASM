NAME TestMem
      adispport=0
      sdispport=4
      resdispport=6
      adport=7
      modeport=0
      klport=1
data1 segment at 0BA00h
      bltype db ?
      intype db ?
      tststart db ?
      dopstart db ?
      resclr db ?
      nextdig db ?
      olddig db ?
      empkl db ?
      addr dw ?
      sized dw ?
      size1 db ?
      addrdisp db 4 dup (?)
      datadisp db 2 dup (?)
      ramerrd db ?
      ramerra db ?
      romerrkc db ?
      ramokd db ?
      ramoka db ?
      romokkc db ?
      endramdtst db ?
      dopdef db ?
      dopkc dw ?
      endtst db ?
      ;tstres db ?
      errsize db ?
      nom db ?
      errors db ?
      bufcount dw ?		
      trftable db 16 dup (?)
      errtable db 6 dup (?)
      atstbuff dw 17 dup (?)
data1 ends
testseg segment at 0C000h          ;0B9FFh
memdata dw 32767 dup(?)
testseg ends
stk segment at 0BA80h stack
      dw 100 dup (?)
      stktop label word
stk ends
code  segment 
      assume cs:code,ds:data1,es:data1,ss:stk
      ;Описание программных модулей
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;============================================================================
      ;Модуль "Функциональная подготовка"
  funcprep proc near
           mov intype,0h
           mov empkl,0FFh
           mov nextdig,0h
           mov olddig,0ffh
           mov addr,0h
           mov sized,0h
           mov size1,0h
           mov addrdisp,0h
           mov addrdisp+1,0h
           mov addrdisp+2,0h
           mov addrdisp+3,0h
           mov datadisp,0h
           mov datadisp+1,0h
           mov ramerrd,0h
           mov ramerra,0h
           mov romerrkc,0h
           mov ramokd,0h
           mov ramoka,0h
           mov romokkc,0h
           mov endramdtst,0h
           mov dopdef,0h
           mov dopkc,0h
           mov endtst,0h
           mov errsize,0h
           mov errors,0h 
           mov trftable,3Fh
           mov trftable+1,0Ch
           mov trftable+2,76h
           mov trftable+3,5Eh
           mov trftable+4,4Dh
           mov trftable+5,5Bh
           mov trftable+6,7Bh
           mov trftable+7,0Eh
           mov trftable+8,7Fh
           mov trftable+9,5Fh
           mov trftable+10,6Fh
           mov trftable+11,79h
           mov trftable+12,33h
           mov trftable+13,7Ch
           mov trftable+14,73h
           mov trftable+15,63h
           mov errtable,73h
           mov errtable+1,60h
           mov errtable+2,60h
           mov errtable+3,80h
           mov errtable+4,80h
           mov errtable+5,7Ch
  funcprep endp
;============================================================================
  ;Модуль "Задание тестируемого сегмента"
      settestseg proc near
                 cmp ax,0ffh
                 jne st1
                 pushf 
                 mov bp,sp
                 and word ptr [bp],0FEFFh
                 popf 
                 assume es:nothing 
                 assume es:testseg
                 mov ax,testseg 
                 mov es,ax
                 jmp st2
            st1: assume es:nothing 
                 assume es:data1
                 mov ax,data1
                 mov es,ax
                 pushf 
                 mov bp,sp
                 or word ptr [bp],0100h
                 popf 
            st2: ret 
      settestseg endp         
;============================================================================
      ;Модуль "Ввод режимов"
  modeinput proc near
            in al,modeport
            mov bltype,0h
            test al,01h
            jz mi1
            mov bltype,0ffh
       mi1: test al,02h
            jz mi2
            mov intype,0h      
       mi2: test al,04h
            jz mi3
            mov intype,0ffh
       mi3: mov tststart,0h
            test al,08h
            jz mi4
            mov tststart,0ffh
       mi4: mov dopstart,0h
            test al,10h
            jz mi5
            mov dopstart,0ffh
       mi5: mov resclr,0h
            test al,20h
            jz mi6
            mov resclr,0ffh
       mi6: ret
  modeinput endp
;============================================================================
      ;Модуль "Вывод сообщения о типе ввода"
  intypeout proc near
            mov al,01h
            cmp intype,0h
            je ito1
            mov al,02h
      ito1: out adport,al
  intypeout endp
;============================================================================
      ;Модуль "Определение очередной цифры"
  nextdigform proc near
              mov empkl,0ffh
       ndf0:  mov nom,0h
              in al,klport
              cmp al,0h
              jne ndf1
              in al,klport+1
              cmp al,0h
              je ndf2
              mov nom,08h
        ndf1: mov cl,0h
        ndf3: shr al,1
              inc cl
              cmp al,0h
              jne ndf3
              dec cl
              add cl,nom
              mov nextdig,cl
              mov empkl,0h
              cmp cl,olddig
              je ndf0
              ;mov nextdig,cl
              mov olddig,cl
              ;mov empkl,0h
              jmp ndf4
        ndf2: mov olddig,0ffh          
        ndf4: ret
  nextdigform endp
;============================================================================
      ;Модуль "Формирование информации"
  infoform    proc near
              cmp bltype,0h
              jne inf1 
              cmp errors,0ffh
              je inf2
        inf1: cmp empkl,0ffh
              je inf2
              cmp intype,0 
              jne inf3
              mov ax,addr
              mov cl,4
              shl ax,cl
              or al,nextdig
              mov addr,ax
              jmp inf2
        inf3: mov al,size1
              mov dx,0h
              mov cl,4h
              shl al,cl
              or al,nextdig
              mov size1,al
              mov dl,al
              mov cl,9h
              shl dx,cl
              mov sized,dx
        inf2: ret
  infoform    endp
;============================================================================
      ;Модуль "Контроль размера блока"
  sizecontrol proc near
              cmp tststart,0ffh
              jne sc1
              mov errsize,0ffh
              cmp size1,0h
              je sc2
              cmp size1,40h
              ja sc2
              mov errsize,0h
              jmp sc2
         sc1: cmp empkl,0h
              jne sc2
              mov errsize,0h
         sc2: ret
  sizecontrol endp
;============================================================================
      ;Модуль "Формирование массивов отображения"
  massimform proc near
             ;cmp errsize,0ffh
             ;je mif1
             mov ax,[bx]
       mif2: mov dx,ax
             and al,0fh
             mov [si],al
             mov ax,dx
             mov cl,4h
             shr ax,cl
             inc si
             dec ch
             jnz mif2
             ret
             massimform endp 
;============================================================================
      ;Модуль "Вывод числовой информации"
  numinfout proc near
            cmp errsize,0ffh
            je nio1
            lea bx,trftable
      nio2: mov al,[si]
            xlat
            out dx,al
            inc si
            inc dx
            loop nio2
            mov cx,0100h
      nio3: nop
            nop
            loop nio3
      nio1: ret
  numinfout endp
;============================================================================
      ;Модуль "Вывод сообщения об ошибке"
  errmesout proc near
            cmp errsize,0ffh
            jne emo1
            mov dx,adispport+3
            mov cx,4
            lea bx,errtable
      emo2: mov al,[bx]
            out dx,al
            dec dx
            inc bx
            loop emo2
            mov dx,sdispport+1
            mov cx,2
      emo3: mov al,[bx]
            out dx,al
            dec dx
            inc bx
            loop emo3
      emo1: ret
  errmesout endp
;============================================================================
      ;Модуль "Тест ОЗУ по шине данных"
  ramtestd proc near
           cmp tststart,0ffh; пуск ?
           jne rtd6
           cmp bltype,0h;  озу ?
           jne rtd6
           cmp errsize,0ffh  
           je rtd6
           cmp endramdtst,0ffh
           je rtd6
           mov ax,0ffh
           call settestseg
           mov bx,addr
           mov cx,sized
           mov ramerrd,0h
           mov ramokd,0h
           mov ramerra,0h    
           mov ramoka,0h
           mov romerrkc,0h
           mov romokkc,0h
           mov dopdef,0h       
           mov dopkc,0h 
           mov endtst,0h
           cmp errors,0ffh
           jne rtd2
           mov ramerrd,0ffh
           add bx,2
           dec cx
           jmp rtd2
     rtd6: jmp rtd1    
     rtd2: cmp cx,0h
           je rtd3
           mov ax,es:[bx]
           mov es:[bx],5555h
           cmp es:[bx],5555h
           jne rtd5
           mov es:[bx],0AAAAh
           cmp es:[bx],0AAAAh
           jne rtd5
           mov es:[bx],ax
           add bx,2
           dec cx
           jmp rtd2
     rtd5: mov ramerrd,0ffh
           mov addr,bx
           mov sized,cx
           mov errors,0ffh
           jmp rtd10 
     rtd3: mov dl,size1
           mov dh,0h
           mov cl,9
           shl dx,cl
           mov sized,dx
           mov endramdtst,0ffh
           mov errors,0h
           cmp ramerrd,0ffh
           je rtd10
           mov ramokd,0ffh
    rtd10: mov ax,0h
           call settestseg
     rtd1: ret
  ramtestd endp
;============================================================================
      ;Модуль "Тест ОЗУ по шине адреса"
  ramtesta proc near
           cmp tststart,0ffh 
           jne rta8
           cmp bltype,0h  
           jne rta8
           cmp errsize,0ffh  
           je  rta8
           cmp endramdtst,0ffh
           jne rta8
           mov ax,0ffh
           call settestseg
           mov ramerra,0h
           mov ramoka,0h
           lea si,atstbuff
           cmp errors,0ffh
           jne rta2
           mov ramerra,0ffh 
           mov bx,bufcount
           clc
           jmp rta3
     rta2: mov bx,0h
           stc 
     rta3: mov ax,es:[bx]
           mov [si],ax
           mov dx,bx
           xor dl,dh
           mov dh,0h
           mov es:[bx],dx
           add si,2
           or bx,bx
           jnz rta11
           stc
           jmp rta001
    rta11: clc      
    rta001:rcl bx,1h
           or bx,bx
           jnz rta3
           lea si,atstbuff
           cmp errors,0ffh
           jne rta4
           mov bx,bufcount
           clc
           jmp rta5
     rta8: jmp rta1
     rta4: mov bx,0h
           stc 
     rta5: mov ax,es:[bx]
           mov ah,0h
           mov dx,bx
           xor dl,dh
           mov dh,0h
           cmp ax,dx
           jne rta6
           mov ax,[si]
           mov es:[bx],ax
           add si,2
           or bx,bx
           jnz rta9
           stc
           jmp rta002  
     rta9: clc      
   rta002: rcl bx,1h
           or bx,bx
           jnz rta5
           jmp rta7
     rta6: mov addr,bx
           mov ramerra,0ffh
           mov errors,0ffh
           or bx,bx
           jnz rta12
           stc
           jmp rta003
    rta12: clc      
  rta003:  rcl bx,1h
           mov bufcount,bx
     rta7: cmp bx,0h
           jne rta10
           mov endtst,0ffh
           mov endramdtst,0h
           mov errors,0h
           cmp ramerra,0ffh
           je rta10
           mov ramoka,0ffh 
    rta10: mov ax,0h
           call settestseg
     rta1: ret
     ramtesta endp
;============================================================================
      ;Модуль "Определение дополнения до контрольной суммы"
  dopform proc near
          cmp dopstart,0ffh
          jne dopf1
          cmp bltype,0ffh
          jne dopf1
          cmp errsize,0ffh
          je dopf1
          mov ax,0ffh
          call settestseg  
          mov ramerrd,0h
          mov ramerra,0h
          mov romerrkc,0h
          mov ramokd,0h
          mov ramoka,0h
          mov romokkc,0h
          mov dopdef,0h
          mov dopkc,0h
          mov endtst,0h
          mov bx,addr
          mov cx,sized
          mov ax,0h
   dopf2: mov dx,es:[bx]       
          add ax,dx
          inc bx
          inc bx
          loop dopf2
          mov dx,0h
          sub dx,ax				
          mov dopdef,0ffh
          mov dopkc,dx
          mov ax,0h
          call settestseg   
   dopf1: ret 
  dopform endp
;============================================================================
      ;Модуль "Тест ПЗУ по контрольной сумме"
  romtestkc proc near
          cmp tststart,0ffh
          jne rtk4
          cmp bltype,0ffh
          jne rtk1
          cmp errsize,0ffh
          je rtk1
          mov ax,0ffh
          call settestseg  
          mov ramerrd,0h
          mov ramerra,0h
          mov ramokd,0h
          mov ramoka,0h
          mov romokkc,0h
          mov romerrkc,0h
          mov endtst,0h
          mov bx,addr
          mov cx,sized
          mov ax,0h
    rtk2: mov dx,es:[bx]       
          add ax,dx
          inc bx
          inc bx
          loop rtk2
          add ax,dopkc
          cmp ax,0h
          je rtk3
          mov endtst,0ffh
          mov romerrkc,0ffh
          mov dopdef,0h
          mov dopkc,0h
          jmp rtk10
    rtk4: jmp rtk1
    rtk3: mov dopkc,0h
          mov romokkc,0ffh 
          mov endtst,0ffh
   rtk10: mov ax,0h
          call settestseg  
    rtk1: ret  
romtestkc endp      
;============================================================================
      ;Модуль "Формирование выводимых результатов теста"
  testresoutform proc near
                 mov al,0h
                 mov ah,endtst
                 and ah,01h
                 or al,ah
                 mov ah,dopdef
                 and ah,02h
                 or al,ah
                 mov ah,ramokd
                 and ah,04h
                 or al,ah
                 mov ah,ramerrd
                 and ah,08h
                 or al,ah
                 mov ah,ramoka
                 and ah,10h
                 or al,ah
                 mov ah,ramerra
                 and ah,20h
                 or al,ah
                 mov ah,romokkc
                 and ah,40h
                 or al,ah
                 mov ah,romerrkc
                 and ah,80h
                 or al,ah
                 ;mov tstres,al
                 out resdispport,al 
                 ret
  testresoutform endp
;============================================================================ 
      ;Модуль "Сброс результатов теста"
  cleartstresults proc near
                  cmp resclr,0ffh
                  jne ctr1
                  mov endtst,0h
                  mov dopdef,0h
                  mov ramokd,0h
                  mov ramerrd,0h
                  mov ramoka,0h
                  mov ramerra,0h
                  mov romokkc,0h
                  mov romerrkc,0h
                  mov dopkc,0h
                  mov errors,0h
            ctr1: ret   
  cleartstresults endp                             
;============================================================================ 
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      ;Макроуровень программы
       ;org 07F0h 
       ;jmp far ptr start    
start: mov ax,data1
       mov ds,ax
       mov es,ax
       mov ax,stk
       mov ss,ax
       lea sp,stktop
       call funcprep
begin: call modeinput
       call intypeout
       call nextdigform
       call infoform
       lea bx,addr
       lea si,addrdisp
       mov ch,4h 
       call massimform
       lea bx,size1
       lea si,datadisp
       mov ch,2h 
       call massimform
       call sizecontrol
       lea si,addrdisp
       mov dx,adispport
       mov cx,4h
       call numinfout
       lea si,datadisp
       mov dx,sdispport
       mov cx,2h
       call numinfout
       call errmesout
       call ramtestd
       call ramtesta
       call dopform
       call romtestkc
       call cleartstresults  
       call testresoutform
       jmp begin
code   ends
end    start


























