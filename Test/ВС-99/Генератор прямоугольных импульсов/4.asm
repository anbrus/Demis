.386
;������ ���� ��� � �����
RomSize    EQU   4096

IntTable   SEGMENT use16 AT 0
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Data       SEGMENT use16 AT 40h
;����� ࠧ������� ���ᠭ�� ��६�����
 DigCode    DB   ?; 
 DigCodeT    DB   ?
 DigCodeP    DB   ?
 Amplitude    DB    ?
 Image1   DB    0ffaah DUP(?);
           
 flag   DB    ?
 period   DW    ?
 maxtime  db ?
 maxfreq  db ?
 zoom db ?
 total dw ?
 move dw ?
 corp db ?
 once_p db ?
 once_t db ?
 mode db ?
Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT use16 AT 100h
;������ ����室��� ࠧ��� �⥪�
           dw    16 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

InitData   ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�
Image      db    0ffh,0ffh,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h,080h,080h,080h,080h  ;
           db    080h,080h,080h,080h;
SymImages  db    3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7fh,05fh 
;Cell_num   db    14h,0ah,7h,5h,4h,3h,3h,2h,2h;   
Cell_num   db    64h,032h,21h,19h,14h,10h,0eh,0ch,0bh;   
;limit_freq db    7h,5h,4h,3h,3h,2h,2h,2h,1h 
;limit_time db    9h,8h,5h,2h,2h,1h,1h,1h 
limit_freq db    9h,6h,4h,3h,3h,2h,2h,2h,1h 
limit_time db    9h,8h,5h,3h,2h,1h,1h,1h,1h 
;arr db   9h,6h,4h,3h,2h,2h,2h,2h,1h 

timetwo    db    0Ch,0Ch,76h,76h,5Eh,5Eh,4Dh,4Dh,5Bh      
           ASSUME cs:Code,ds:Data,es:stk
           ;--------------------------------
VibrDestr  PROC  NEAR
           pusha
VD1:       mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
           mov   bx,0        ;���� ����稪� ����७��
VD2:       in    al,dx       ;���� ⥪�饣� ���ﭨ�
           cmp   ah,al       ;����饥 ���ﭨ�=��室����?
           jne   VD1         ;���室, �᫨ ���
           inc   bx          ;���६��� ����稪� ����७��
           cmp   bx,04ffh       ;����� �ॡ����?
           jne   VD2         ;���室, �᫨ ���
           mov   al,ah       ;����⠭������� ���⮯�������� ������
           popa
           ret
VibrDestr  ENDP   
;------------------------------
num_out proc near
         push di                           ;��࠭塞 ॣ�����
         push ax
         push bx
         push si
         xor di,di                         ;����� � ���ᨢ� �� ����
         mov ah,DigCode                    ;��� ��������(���� �� 㬮�砭��)
         cmp dx,7h                         ;�᫨ ���⥫쭮���(7���� �뢮��)
         jnz nt
         ;---------------------
         mov al,0bfh             ;���⥫쭮���:��襬 ���� ���� � �窮� 
         out 7, al
         mov al,DigCodeT          ;�஢��塞 �⭮��� ��襩 ��६�����         
         xor ah,ah                ;�᫨ �⭮ � ��襬 �� ���� 5
         mov bl,02h              ;�᫨ ��� � ����
         div bl
         cmp ah,0
         jz  kol
         mov al,SymImages[0]
         jmp outim
    kol: mov al,SymImages[5]
    outim: out 0bh,al 
         mov bl,DigCodeT        ;�।��� ���� ���� �� ���ᨢ�
         xor si,si   
   dfr:  inc si
         dec bl
         jnz dfr
         mov al,timetwo[si-1]
         out 0ah,al
         jmp  hhh         
         ;--------------------
    nt:  cmp dx,8h                         ;�᫨ ���⥫쭮���(7���� �뢮��)
         jnz increm_di
         mov ah,DigCodeP                   ;��� ���⥫쭮�� 
 increm_di:  
         inc di                            ;㢥��稬 ������
         dec ah                            ;㡠��� ����
         jnz increm_di                     ;���� ��� �� �������   
         mov al,SymImages[di]              ;����� �� ������� �� �뢮�
         out dx, al
  hhh:   pop si
         pop bx
         pop ax                            ;����⠭�������� ॣ�����
         pop di
         ret
num_out endp
;-------------------------------------------------
amplitude_modify proc near
          cmp mode,0
          jz no_pr1
          in al,0                          ;�⠥� 0 ॣ����
          call VibrDestr                   ; ��ᨬ �ॡ���
          
          cmp al,0feh                      ;����� ��ࢠ� ������
          jnz next1
          mov ah,DigCode                   ;�⠥� ⥪�饥 ���ﭨ�
          cmp ah,7h                        ;�᫨ 7 � �� ���� 㢥��稢���,�� ���ᨬ�
          jz exit
          inc ah                           ;� �᫨ �� 7 � 㢥��稬 �� 1
          mov DigCode,ah                   ; � ��࠭�� ��� ⥪�饥
    next1: cmp al,0fdh                     ;����� ���� ������
           jnz exit
           mov ah,DigCode                  ;�⠥� ⥪�饥 ���ﭨ�
           cmp ah,1h                       ;�᫨ 1 � �� ���� 㬥�����,�� ������
           jz exit
           dec ah                          ;� �᫨ �� 1 � 㬥��訬 �� 1
           mov DigCode,ah                  ; � ��࠭�� ��� ⥪�饥
    exit:  mov dx,6h                       ;����� ���� ��।�� � ��楤���
           call num_out
    no_pr1: nop  
            ret     
amplitude_modify endp
;-------------------------------------------------
time_modify proc near
         
          in al,0                          ;�⠥� 0 ॣ����
          call VibrDestr                   ; ��ᨬ �ॡ���
          ;cmp mode,0
          ;jz no_in
          ;------------------------
          cmp al,0fbh                      ;����� ����� ������
          jnz nxt2
          mov bl,1
          mov once_p,bl
          mov ah,DigCodeT                  ;�⠥� ⥪�饥 ���ﭨ�
          cmp ah,limit_time[si-1];           ;�� ���� 㢥��稢���,�� ���ᨬ�
          jz tz2;exit2; new techtask 
          inc ah                           ;� �᫨ �� ���ᨬ� � 㢥��稬 �� 1
          mov DigCodeT,ah                   ; � ��࠭�� ��� ⥪�饥
          cmp ah,03h
          jnz tpp1
          cmp digcodep,06h
          jnz tpp1 
          mov al,04h
          mov digcodep,al
          jmp exit2
      tpp1: 
    nxt2: cmp al,0f7h                     ;����� ������ ������
           jnz exit2
           mov bl,1
           mov once_p,bl
           mov ah,DigCodeT                  ;�⠥� ⥪�饥 ���ﭨ�
           cmp ah,1h                       ;�᫨ 1 � �� ���� 㬥�����,�� ������
           jz exit2
           dec ah
                                 ;� �᫨ �� 1 � 㬥��訬 �� 1
           mov DigCodeT,ah                  ; � ��࠭�� ��� ⥪�饥
            cmp ah,03h
            jnz tpp
            cmp digcodep,06h
            jnz tpp 
            mov al,04h
            mov digcodep,al
            jmp exit2
      tpp:  
            jmp exit2 
    tz2:     ;� �� �� �2
           ;cmp ah,08h
           ;jz exit2
           mov al,digcodep
           cmp al,01h
           jz exit2
           dec al
           mov digcodep,al
         ;-----------------  
    anov1: ; cmp ah,09h
           ;jz exit3
           cmp al,6
           jz beg_t
           cmp al,4
           jz beg_t
           cmp al,3
           jz beg_t1
           cmp al,2
           jz beg_t1
           cmp al,1
           jz beg_t1
           mov bl,1
           mov once_t,bl
           jmp exit2
 beg_t:    cmp once_t,0
           jz exit2
 beg_t1:    xor bl,bl
           mov once_t,bl
           inc ah
          
           mov DigCodet,ah   
           
                     
         ;-----------------
    exit2: mov dx,7h                       ;����� ���� ��।�� � ��楤���
           call num_out
   no_in: ;nop 
           ret     
time_modify endp
;-------------------------------------------------
period_modify proc near
         
          in al,0                          ;�⠥� 0 ॣ����
          call VibrDestr                   ; ��ᨬ �ॡ���
          ;--------------------------
          cmp mode,0
          jz no_pr3
          cmp al,0efh                      ;����� ���� ������
          jnz nxt3
           mov bl,1
           mov once_t,bl
          mov ah,DigCodeP                  ;�⠥� ⥪�饥 ���ﭨ�
          
          cmp ah,limit_freq[di-1];         ; �� ���� 㢥��稢���,�� ���ᨬ�
          jz tz2p;exit3
          inc ah                           ;� �᫨ �� ���ᨬ� � 㢥��稬 �� 1
          mov DigCodeP,ah                   ; � ��࠭�� ��� ⥪�饥
    nxt3: cmp al,0dfh                      ;����� ���� ������
           jnz exit3
            mov bl,1
           mov once_t,bl
           mov ah,DigCodeP                  ;�⠥� ⥪�饥 ���ﭨ�
           cmp ah,01h                       ;�᫨ 1 � �� ���� 㬥�����,�� ������
           jz exit3
           dec ah                          ;� �᫨ �� 1 � 㬥��訬 �� 1
           mov DigCodeP,ah                  ; � ��࠭�� ��� ⥪�饥
           jmp exit3
 tz2p:     ;� �� �� �2
           mov al,digcodet
           cmp al,01h
           jz anov;exit3
           dec al
           mov digcodet,al
    anov:  cmp ah,09h
           jz exit3
           cmp al,8
           jz beg_p
           cmp al,5
           jz beg_p
           cmp al,3
           jz beg_p
           cmp al,2
           jz beg_p1
           cmp al,1
           jz beg_p1
           mov bl,1
           mov once_p,bl
           jmp exit3
 beg_p:    cmp once_p,0
           jz exit3
          
           ;jmp exit3
            ;cmp ah,1
            ;jnz exit3
 beg_p1:    xor bl,bl
           mov once_p,bl
          ; cmp ah,09h
          ; jz exit3
           inc ah
          
           mov DigCodeP,ah   
          ; mov ah,DigCodeP
          ; cmp ah,arr[di-1]; 
          ; jz exit3
          ; 
          ; inc ah 
          ; mov DigCodeP,ah 
          
         ;----
    exit3:
          mov dx,8h                       ;����� ���� ��।�� � ��楤���
           call num_out
    no_pr3:  nop
           ret     
period_modify endp
;-------------------------------------------------
math_array PROC  NEAR                      ; ��� ��ࠡ�⪠ ���ᨢ�(���� ⮫쪮 ������㤠)
      pusha                                ;��࠭塞 ॣ�����
      mov al,1                             ;�ਧ��� ��ன ������ ���
      mov flag,al
      ;---------------------------------
      xor si,si                                       ;��।��塞 ᪮�쪮
      mov al,DigCodeP                                 ;���⮪ ���ᨢ� �㦭� ����
     
repeat1:
      inc si
      dec al
      jnz repeat1
      mov al,cell_num[si-1]
      xor ah,ah
      cmp zoom,1
      jnz normal1
                      ;�᫨ ������ �����, ����⠡��㥬 ��ਮ� � 2 ࠧ�
      dec ax
      dec ax 
      shr ax,1h
      inc ax
      ;inc ax
     
normal1: 
      mov period,ax
      mov dx,ax
      ;--------------------------------------
 ; ghs:mov ax,dx;�� ����� ���-�� ����⮢ ���ᨢ� ��� �뢮�� 
 ;     shl ax,1;���ᨢ��� ��ਮ���� ��⥬ �� 㤢������� �� ���祭�� �ॢ���饣� 32
 ;     mov dx,ax
 ;     and ax,0e0h
 ;     jz ghs
      mov total,dx
      ;----------------------------
      xor si,si                            ;����塞 ������
      xor di,di
      mov ah,DigCode                       ;��㧨� ����� ����
      mov cx,01fffh;0e2bh
in_rep: mov dx,0ffh;0affh;448h                           ;��㧨� ���稪 �� 32 �����
  n:  mov al,image[si]                     ;�⠥� ��ࠧ��
 ;-----------------------;�� ॣ㫨��� ���⥫쭮��� ������
      cmp al,0ffh        ;�஢��塞 ������� �⮩�� ������
      jnz n5             ;�᫨ �� ��� � �� �㦭� ��祣� ��⠢����
      push dx
      cmp flag,0         ; 㧭��� �������� �� ��� ��ࢠ� �⮩�� ��� ����
      jz n7              ;�᫨ ���� � ��⠢�塞 ������ ����� ��ॣ�த����(���� ���)
      mov dl,0           ;�᫨ ��ࢠ� � �⠢�� ���� �� ᫥����� �㤥� ��ன
      mov flag,dl
      jmp n8
  n7: mov dl,DigCodeT   ;�⠥� ���⥫쭮���
     ; dec dl             ;�᫨ 1 � ��祣� ��⠢���� �� ����
     ; jz n8
      push ax
      mov al,5
      inc dl
      mul dl
      mov dl,al
      dec dl
      dec dl
      ;���� 㬭����� dl �� 5
      pop ax
      cmp zoom,1
      jnz norm
      dec dl
      cmp dl,2
      jz n8
 norm: mov dh,image1[0]  ;�饬 �� ����� ���� ��⠢����
      shl dh,1
      xor dh,image1[0]
  n6: mov image1[di],dh ;��⠢�塞 ������ ������ ���⥫쭮���-1
      cmp zoom,1
      jnz normal
                       ;�᫨ ������ �����, ����⠡��㥬 ������ � 2 ࠧ�
      dec dl
      jz dr
normal:
      inc di
      inc si             ;�⮡� �� ࠧ������� � �ꥤ��� ������
      dec dl
      jnz n6 
  dr: mov dl,1          ;��᫥ ⮣� ��� ��⠢��� ��� ᫥���饩 ��ࢮ� ������
      mov flag,dl   
  n8: pop dx
 ;----------------------     �� �����稢����� ���⥫쭮��� � ��稭����� ������㤠
  n5: cmp al,080h                          ;������ ������� �� 㡨ࠥ�
      jz n3
      mov bl,7                             ;���⠥� �� 7 ���� � ��������
      sub bl,ah                            ;�⮡� ������� �������⢮ ᤢ����
      jz n3                                ;�᫨ �� ���� ᤢ�����(������㤠 ࠢ�� �⠫�����)
  n1: shl al,1                             ;ᤢ�����
      dec bl
      jnz n1
  n3: 
      mov image1[di],al                    ;�����뢠�� � �� ᤢ��㫨 ��� �� ᤢ��㫨, � ���� ���ᨢ, ����� � �㤥� �뢮����
                                           ;�⮡� ������� �������⢮ ᤢ����
      
      inc di                              ; � �� ࠧ�� ���稪�.      
      inc si
      
      cmp si,period; �� ��ࢮ�� ���ᨢ� ���� ��砫� ������ � ���⮩ 㪠������ �� ��������
      jnz n4
      xor si,si
   n4:   
      dec dx
      jnz n
      dec cx
      jnz in_rep    
      popa
       ret
math_array endp
;-------------------------------------------------
bin_out PROC  NEAR
          mov bl,DigCodep
          xor si,si                     ;㧭��� ���ᨬ� � ����ᨬ��� �� ��㣮�� ��ࠬ���
     tt:  inc si
          dec bl
          jnz tt
          mov bl,limit_time[si-1];
          mov maxtime,bl               ;���������� ���ᨬ�(� ����ᨬ���� �� �᫠ ���� ������⢮ ���⮪ �� ���ᨢ�)
          ;-------------------------
          cmp maxfreq,9h;7h               ;�஢��塞 ࠢ�� �� ⥪�騩 ���ᨬ� ��᮫�⭮�� ��� ��ࠬ���
          jz off                       ;�᫬ ࠢ�� � ���� �����
        
          mov ch,02h;� �᫨ �� ࠢ�� � ��������
          mov al,cl
          or al,02h;
          out 9,al
        
          jmp ff
     off:               ;��ᨬ
          mov ch,0h
          mov al,cl
          and al, 0fdh
          out 9,al  
             
     ff:  mov bl,DigCodet ;� ���
          xor di,di                        ;㧭�� ���ᨬ� � ����ᨬ��� �� ��㣮�� ��ࠬ���
     tt1:  inc di
          dec bl
          jnz tt1
          mov bl,limit_freq[di-1];
          mov maxfreq,bl
          ;---------------------------------
          cmp maxtime,09h
          jz off2
          
          mov cl,01h
          mov al,ch
          or al,01h
          out 9,al
          
          jmp ff2
     off2: 
          mov cl,0h
          mov al,ch
          and al, 0feh
          out 9,al 
              
     ff2: cmp zoom,1;�� ��������� ����⠡�
          jnz ex
          or al,4h
          and al,7h
          out 9,al
          jmp exi
     ex:  or al,8h
          and al,0fbh
          out 9,al
     exi:
          ret
bin_out endp
;-------------------------------------------------
horiz_time PROC  NEAR ; ����� ⮫쪮 �⫠��������� ���樨 � ������ ����⠡�஢���� ॠ�쭮
          xor al,al
          mov zoom,al
          in al,1
          ;;call vibrdestr
          cmp al,0feh
          jnz return
          cmp DigCodep,09h
          jz return 
          cmp DigCodep,08h
          jz return
          cmp DigCodep,06h
          jz return 
          cmp DigCodep,04h
          jz return 
          cmp DigCodep,03h
          jz return 


          ;------------
          mov al,DigCodet
          and al,01h
          cmp al,0
          jz return
          mov al,1h
          mov zoom,al;����� ����� ����⠡�஢���
          ;------------
   return: 
          ret
horiz_time endp
;-------------------------------------------------
move_arr  PROC  NEAR
          ; pusha 
           cmp digcodep,1h
           jnz nxt_1
           cmp move,064h
           jz zer
      nxt_1:cmp digcodep,2h
           jnz nxt_2
           cmp move,032h
           jz zer
     nxt_2:cmp digcodep,3h
           jnz nxt_3
           cmp move,021h
           jz zer
     nxt_3:cmp digcodep,4h
           jnz nxt_4
           cmp move,019h
           jz zer
     nxt_4:cmp digcodep,5h
           jnz nxt_5
           cmp move,014h
           jz zer
     nxt_5:cmp digcodep,6h
           jnz nxt_6
           cmp move,010h
           jz zer
     nxt_6:cmp digcodep,7h
           jnz nxt_7
           cmp move,0eh
           jz zer
     nxt_7:cmp digcodep,8h
           jnz nxt_8
           cmp move,0ch
           jz zer
     nxt_8:cmp digcodep,9h
           jnz nxt_9
           cmp move,0bh
           jz zer
     nxt_9:cmp move,0aaaah
           jnz increm
       zer:    xor ax,ax
            mov move,ax
           jmp rty
     increm: inc move
               
     rty:  mov cx,0ffffh
       del:nop
           nop
           loop del 
          ; popa
           ret
move_arr  ENDP   
;----------------------------------------------------
choose_mode proc near
       in al,0                          ;�⠥� 0 ॣ����
       call VibrDestr                   ; ��ᨬ �ॡ���
       cmp al,0bfh                      ;����� 7 ������ 7f
       jnz sec_mode
       mov ah,01h
       mov mode,ah
       xor ax,ax
       mov move,ax
       jmp out_pr
  sec_mode: cmp al,07fh
        jnz out_pr
        xor ah,ah
        mov mode,ah
  out_pr: nop
        ret    

choose_mode endp
;-------------------------------------------------
out_image  PROC  NEAR
           pusha
           mov    al,1             ;����砥� ��⠭��
           out   0,al              ;
          ; mov si,0h                ;���稪 ���ᨢ�
           mov si,move
           mov dl,1h               ;�뢮���� �⮫���
           mov dh,8h               ;�������⢮ �⮫�殢
 out_start: 
           mov al,dl               ;��⨢��㥬 �⮫���
           out 2, al               ;
           mov al,image1[si]        ;����� ������ �뢮������ ����� ���ᨢ� � ������ 1
           out 1,al                ;
           mov al,image1[si+8h]    ;����� ������ �뢮������ ����� ���ᨢ� � ������ 2
           out 3,al                ;
           mov al,image1[si+10h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 3
           out 4,al                ;
           mov al,image1[si+18h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
           out 5,al                ;
           mov al,image1[si+20h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
           out 0ch,al                ;
           mov al,image1[si+28h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
           out 0dh,al                ;
           mov al,image1[si+30h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
           out 0eh,al                ;
           mov al,image1[si+38h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
           out 0fh,al                ;
           mov al,image1[si+40h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
           out 010h,al                ;
           mov al,image1[si+48h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
           out 011h,al                ;
           mov al,image1[si+50h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
           out 012h,al                ;
           mov al,image1[si+58h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
           out 013h,al     
            mov al,image1[si+60h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
           out 014h,al    
           mov al,image1[si+68h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
           out 015h,al    
          ; mov al,image1[si+70h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
          ; out 016h,al    
           ;mov al,image1[si+78h]   ;����� ������ �뢮������ ����� ���ᨢ� � ������ 4
          ; out 017h,al    
           xor al,al               ;��ᨬ �⮫���
           out 1,al
           out 3,al
           out 4,al
           out 5,al
           out 0ch,al
           out 0dh,al
           out 0eh,al
           out 0fh,al
           out 010h,al
           out 011h,al
            out 012h,al
            out 013h,al
             out 014h,al
            out 015h,al
            ;  out 016h,al
           ; out 017h,al
           inc si                  ;���稪 �� ᫥���騩 �����
           rol dl,1                ;㪠��⥫� ��⨢��� �⮫�� �� ᫥���騩
           dec dh                  ;����䨪��� ���横� ���ᨢ�
           jnz out_start  
           cmp mode,0
           jnz no_move
           call move_arr
    no_move:       popa  
           ret
out_image  ENDP   
init proc near
           mov al,1
           mov DigCode,al 
           mov DigCodeT,al
           mov once_p,al
           mov mode,al
           ;mov al,1
           mov DigCodeP,al
           xor ax,ax
           mov move, ax
           mov al,09h
           mov maxtime,al
           dec al
           mov maxfreq,al
           ret
init endp
Start:
           
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;����� ࠧ��頥��� ��� �ணࠬ��
           
          call init
   InfLoop:   
            call bin_out
           ;-------------------
           call amplitude_modify
           cmp mode,0
           jz no_t
           call time_modify
           no_t:
           call period_modify
           call horiz_time
           call math_array 
           call choose_mode
           call out_image
           jmp   InfLoop

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END