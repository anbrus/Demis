RomSize    EQU   4096
KbdPort    EQU   0
NMAX       EQU   50

Stk        SEGMENT at 100h
           dw    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS
                     

Data       SEGMENT at 0h
  KbdImage   DB    2 DUP(?)
  NextDig    DB    ?
  EmpKbd     DB    ?
  KbdErr     DB    ? 
  Load2      DB    ?
  DsPlay     DD    ?  
  KodLoad1   DD    ?
  KodLoad2   DD    ?
  KodLoad3   DD    ?  
  Uroven     DB    ?  
  Popitka    DB    ? 
  Block      DB    ? 
  CopyDsPl   DD    ?
  Set        DB    ? 
  Open       DB    ?
  Error      DB    ?
  Kod1Bin    DD    ?
  KodBin     DD    ? 
  Load2Dec   DB    ?      
  
Data       ENDS 

Code       SEGMENT 

           ASSUME cs:Code,ds:Data,es:Code,ss:Stk
  SymImages  DB   03Fh, 00Ch, 076h, 05Eh, 04Dh, 05Bh, 07Bh, 00Eh, 07Fh, 05Fh
  Empty_Row  DB  00011111b  ;пустая строка
  Multiplier DB  5          ;множитель для нахождения текущей цифры, нажат. на клавиатуре 
  
  Alphavit   DB    0FFh,0FFh,0FFh,0FFh,081h,0DEh,0DEh,081h ; "A" = 1
             DB    0FFh,0FFh,0FFh,0FFh,081h,0B5h,0B5h,081h ; "B" = 2
             DB    0FFh,0FFh,0FFh,0FFh,081h,0BDh,0BDh,099h ; "C" = 3
             DB    0FFh,0FFh,0FFh,0FFh,081h,0BDh,0BDh,081h ; "D" = 4
             DB    0FFh,0FFh,0FFh,0FFh,081h,0B5h,0B5h,0BDh ; "E" = 5 
             DB    0FFh,0FFh,0FFh,0FFh,081h,0F5h,0F5h,0FDh ; "F" = 6
             DB    0FFh,0FFh,0FFh,0FFh,081h,0BDh,0ADh,08Dh ; "G" = 7
             DB    0FFh,0FFh,0FFh,0FFh,081h,0F7h,0F7h,081h ; "H" = 8
             DB    0FFh,0FFh,0FFh,0FFh,0BDh,081h,081h,0BDh ; "I" = 9                
             DB    0FFh,0FFh,0FFh,0FFh,0FDh,0BDh,0BDh,0C1h ; "J" = 10 
             DB    0FFh,0FFh,0FFh,0FFh,081h,0F7h,076h,09Fh ; "K" = 11 
             DB    0FFh,0FFh,0FFh,0FFh,081h,0BFh,0BFh,09Fh ; "L" = 12   
             DB    0FFh,0FFh,0FFh,081h,0FBh,0F7h,0FBh,081h ; "M" = 13 
             DB    0FFh,0FFh,0FFh,0FFh,081h,0F7h,0EFh,081h ; "N" = 14 
             DB    0FFh,0FFh,0FFh,0FFh,081h,0BDh,0BDh,081h ; "O" = 15
             DB    0FFh,0FFh,0FFh,0FFh,081h,0EDh,0EDh,0E1h ; "P" = 16
             DB    0FFh,0FFh,0FFh,081h,0BDh,0BDh,081h,0BFh ; "Q" = 17
             DB    0FFh,0FFh,0FFh,0FFh,081h,0CDh,0ADh,0E1h ; "R" = 18
             DB    0FFh,0FFh,0FFh,0FFh,0B1h,0B5h,0B5h,085h ; "S" = 19  
             DB    0FFh,0FFh,0FFh,0FDh,0FDh,081h,0FDh,0FDh ; "T" = 20
             DB    0FFh,0FFh,0FFh,0FFh,081h,0BFh,0BFh,081h ; "U" = 21
             DB    0FFh,0FFh,0FFh,0FFh,0C1h,0BFh,0BFh,0C1h ; "V" = 22 
             DB    0FFh,0FFh,0FFh,0C1h,0BFh,0DFh,0BFh,0C1h ; "W" = 23
             DB    0FFh,0FFh,0FFh,0BDh,0DBh,0E7h,0DBh,0BDh ; "X" = 24
             DB    0FFh,0FFh,0FFh,0FDh,0FBh,087h,0FBh,0FDh ; "Y" = 25 
             DB    0FFh,0FFh,0FFh,0FFh,09Bh,0ADh,0B5h,0B9h ; "Z" = 26 
             DB    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh ; пустая строка  
             
  Image:      
           db    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           db    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           db    0C3h,0BDh,0BDh,0BDh,0C3h,0FFh,081h,0EDh,0EDh,0E1h,0FFh,0C3h,0B5h,0B5h,0B5h,0B3h
           db    0FFh,081h,0FBh,0FDh,0FDh,081h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           db    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           db    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           
  Image1:      
           db    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           db    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           db    0FFh,081h,0B5h,0B5h,0BDh,0FFh,081h,0CDh,0ADh,0E1h,0FFh,081h,0CDh,0ADh,0E1h,0FFh
           db    081h,0BDh,0BDh,081h,0FFh,081h,0CDh,0ADh,0E1h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           db    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
           db    0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh                    

; Сдвиг цифр на дисплее справа налево  
DispSdvig  PROC  NEAR
           lea   si,CopydsPl
           mov   al,[di+2]
           mov   byte ptr [di+3],al
           mov   byte ptr [si+3],al
           mov   al,[di+1]
           mov   byte ptr [di+2],al
           mov   byte ptr [si+2],al
           mov   al,[di]
           mov   byte ptr [di+1],al
           mov   byte ptr [si+1],al
           mov   al,byte ptr [di+3]
           out   01h,al
           mov   al,byte ptr [di+2]
           out   02h,al
           mov   al,byte ptr [di+1]
           out   03h,al
           
           ret
DispSdvig  ENDP            

; Гашение дребезга
VibrDestr  PROC NEAR
VD1:       mov   ah,al
           mov   bh,0
VD2:       in    al,dx
           cmp   ah,al
           jne   VD1
           inc   bh
           cmp   bh,NMax
           jne   VD2
           mov   al,ah
           ret                       
VibrDestr  ENDP

;Ввод цифр с клавиатуры
KbdInput   PROC  NEAR
           lea   SI,KbdImage               
           Mov   CX,LENGTH KbdImage     
           Mov   BL,00000010b           
KI4:       Mov   AL,BL                  
           Out   KbdPort,AL             
           In    AL,KbdPort             
           And   AL,Empty_Row
           Cmp   al,Empty_Row
           jz    KI1
           mov   dx,KbdPort
           call  VibrDestr
           mov   [si],al
KI2:       in    al,KbdPort
           and   al,Empty_Row
           cmp   al,Empty_Row
           jnz   KI2
           call  VibrDestr
           jmp   SHORT KI3                
KI1:       mov   [si],al                   
KI3:       Inc   SI                     
           shr   BL,1                    
           Loop  KI4     
           Ret
KbdInput   ENDP

;Проверка введённых цифр
KbdInContr PROC NEAR
           lea  bx,KbdImage
           mov  cx,Length KbdImage
           mov  EmpKbd,0
           mov  KbdErr,0
           mov  dl,0
        
KIC2:      mov   al,[bx]
           mov   ah,Multiplier
KIC1:      shr   al,1
           cmc
           adc   dl,0
           dec   ah
           jnz   KIC1
           inc   bx
           loop  KIC2
           cmp   dl,0
           jz    KIC3
           cmp   dl,1
           jz    KIC4
           mov   KbdErr,0FFh
           jmp   SHORT KIC4
KIC3:      mov   EmpKbd,0FFh
KIC4:      ret                                 
KbdInContr ENDP

; Ввод следующей цифры
NxtDig PROC NEAR 
            cmp EmpKbd,0FFh
            jz  Exit_
            cmp KbdErr,0FFh
            jz  Exit_
                     
            Lea BX,KbdImage            
            Mov CX,Length KbdImage                  
Study_Line: Mov AL,[BX]                             
            Cmp AL,[ES]:Empty_Row                   
            Jne Line_Not_Empty                                                             
            Inc BX                                  
            Loop Study_Line       
            Mov NextDig,0FFh                     
            Jmp Exit_                               
Line_Not_Empty:                                                                
            Sub BX,Offset KbdImage                  
            Mov AH,0                                         
Find_Zero:  Shr AL,1                                 
            Jnc We_Find_Zero                            
            Inc AH                    
            Jmp Find_Zero 
We_Find_Zero:
            Mov NextDig,AH
            Mov AX,BX                               
            Mul [ES]:Multiplier  
            Add NextDig,al                             
Exit_:      Ret
NxtDig      ENDP

; Вывод цифры на дисплей
OutDigit   PROC NEAR 
           cmp   EmpKbd,0FFh
           jz    OD
           cmp   KbdErr,0FFh
           jz    OD
           xor   ah,ah
           mov   al,NextDig
           
           push  ax
           lea   bx,Kod1Bin
           mov   al,[bx+2]
           mov   [bx+3],al
           mov   al,[bx+1]
           mov   [bx+2],al
           mov   al,[bx]
           mov   [bx+1],al
           pop   ax
           mov   [bx],al
          
           
           lea   bx,SymImages
           lea   si,CopydsPl
           add   bx,ax
           mov   al,es:[bx]
           mov   bl,al
           call  DispSdvig
           mov   al,bl
           mov   byte ptr [di],al
           mov   byte ptr [si],al
           out   04h,al

OD:      ret         
OutDigit ENDP 

; Установка кода первого уровня
Ustanov1   PROC  NEAR
           in    al,00h
           and   al,01100000b
           cmp   al,00100000b
           jne   U
           mov   set,0
           lea   si,KodLoad1
           lea   bx,CopyDsPl
           mov   al,[bx+3]
           mov   byte ptr [si+3],al
           mov   al,[bx+2]
           mov   byte ptr [si+2],al
           mov   al,[bx+1]
           mov   byte ptr [si+1],al
           mov   al,[bx]
           mov   byte ptr [si],al
           mov   Load2Dec,al
           
           lea   si,Kod1Bin
           lea   bx,KodBin
           mov   al,[si]
           mov   [bx],al
           mov   al,[si+1]
           mov   [bx+1],al
           mov   al,[si+2]
           mov   [bx+2],al
           mov   al,[si+3]
           mov   [bx+3],al
           
           mov   cx,00FFFh
Z:         mov   al,00000100b
           out   08h,al
           lea   si,KodLoad1
           mov   al,[si+3]
           out   01h,al                      
           mov   al,[si+2]
           out   02h,al 
           mov   al,[si+1]
           out   03h,al 
           mov   al,[si]
           out   04h,al  
           loop  Z
           Call  Ustanov2
           Call  Ustanov3 
U:         ret           
Ustanov1   ENDP

Ustanov2   PROC  NEAR
           Call  FormKod2
           mov   cx,00FFFh
Z2:        mov   al,00001000b
           out   08h,al 
           lea   si,KodLoad2
           mov   al,[si+3]
           out   01h,al                      
           mov   al,[si+2]
           out   02h,al 
           mov   al,[si+1]
           out   03h,al 
           mov   al,[si]
           out   04h,al 
           loop  Z2          
U2:        ret
Ustanov2   ENDP

FormKod2   PROC  NEAR
           xor   ax,ax
           xor   dx,dx
           lea   si,KodBin
           lea   bx,KodLoad2
           mov   al,[si]
           mov   Load2,al
           mov   dl,Load2
           mov   cl,10
           
           add   ax,dx
           div   cl
           mov   al,ah
           push  bx
           lea   bx,SymImages
           xor   ah,ah
           add   bx,ax
           mov   al,es:[bx]
           pop   bx
           mov   [bx],al
           
           xor   ax,ax
           mov   al,[si+1]
           add   ax,dx
           div   cl
           mov   al,ah
           push  bx
           lea   bx,SymImages
           xor   ah,ah
           add   bx,ax
           mov   al,es:[bx]
           pop   bx
           mov   [bx+1],al
           
           xor   ax,ax
           mov   al,[si+2]
           add   ax,dx
           div   cl
           mov   al,ah
           push  bx
           lea   bx,SymImages
           xor   ah,ah
           add   bx,ax
           mov   al,es:[bx]
           pop   bx
           mov   [bx+2],al
           
           xor   ax,ax
           mov   al,[si+3]
           add   ax,dx
           div   cl
           mov   al,ah
           push  bx
           lea   bx,SymImages
           xor   ah,ah
           add   bx,ax
           mov   al,es:[bx]
           pop   bx
           mov   [bx+3],al
           ret           
FormKod2   ENDP 

; Установка кода третьего уровня
Ustanov3   PROC  NEAR
           Call  FormKod3
           mov   cx,00FFFh
Z3:        mov   al,00010000b
           out   08h,al 
           lea   si,KodLoad3
           mov   al,[si+3]
           out   01h,al                      
           mov   al,[si+2]
           out   02h,al 
           mov   al,[si+1]
           out   03h,al 
           mov   al,[si]
           out   04h,al 
           loop  Z3  
           mov   al,00h
           out   01h,al
           out   02h,al
           out   03h,al
           out   04h,al
           Call  DestDspl
                    
U31:       ret           
Ustanov3   ENDP

FormKod3   PROC  NEAR
           lea   bx,KodLoad3
           lea   si,KodBin
           mov   al,03Fh
           mov   byte ptr [bx+3],al
           mov   byte ptr [bx+2],al
           
           
           mov   al,[si]
           cmp   al,0
           jne   U39
           mov   al,1
U39:       mov   set,al
           add   set,al
           add   set,al
           
           mov   al,[si+1]
           cmp   al,7
           ja    U32
U36:       cmp   al,4
           ja    U33
           jmp   U34
U32:       sub   set,3
           jmp   U35
U33:       sub   set,2
           jmp   U35
U34:       sub   set,1
U35:       mov   al,set

           xor   ah,ah
           mov   cl,10
           div   cl
           
           cmp   al,0
           jne   U37
           mov   al,ah
           push  bx
           xor   ah,ah
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           pop   bx
           mov   ah,03Fh
           mov   byte ptr [bx+1],ah
           mov   byte ptr [bx],al
           jmp   U38
           
U37:       mov   dh,ah
           push  bx
           xor   ah,ah
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           pop   bx
           mov   byte ptr [bx+1],al
           
           mov   al,dh
           push  bx
           xor   ah,ah
           lea   bx,SymImages
           add   bx,ax
           mov   al,es:[bx]
           pop   bx
           mov   byte ptr [bx],al          
U38:       ret
FormKod3   ENDP 

; Обнуление дисплея после установки кодов уровней              
DestDspl   PROC  NEAR
           mov   bl,00h
           mov   byte ptr [di],bl
           mov   byte ptr [di+1],bl 
           mov   byte ptr [di+2],bl
           mov   byte ptr [di+3],bl
           mov   al,00h
           out   08h,al
           ret        
DestDspl   ENDP 

; Проверка кода первого уровня
Proverka1  PROC  NEAR
           cmp   Uroven,0
           jne   P1
           in    al,00h
           and   al,01100000b
           cmp   al,01000000b
           jne   P1
           lea   si,KodLoad1
           mov   al,byte ptr [si]
           cmp   byte ptr [di],al
           jne   P2
           mov   al,byte ptr [si+1]
           cmp   byte ptr [di+1],al
           jne   P2
           mov   al,byte ptr [si+2]
           cmp   byte ptr [di+2],al
           Jne   P2
           mov   al,byte ptr [si+3]
           cmp   byte ptr [di+3],al
           jne   P2
           mov   Uroven,1
           Call  LampaU1
           Call  DestDspl1
           mov   Popitka,0
           jmp   P1
P2:        inc   Popitka
           Call  Delay1 
           Call  LampaP123
P1:        ret              
Proverka1  ENDP


LampaU1    PROC  NEAR      
           mov   al,0
           out   08h,al
           mov   al,00000100b
           out   08h,al
           ret           
LampaU1    ENDP 

LampaP123  PROC  NEAR
           cmp   Popitka,1
           jne   LP2
           mov   al,00100000b
           out   08h,al
           jmp   LP3
LP2:       cmp   Popitka,2
           jne   LP1
           mov   al,01000000b
           out   08h,al
           jmp   LP3
LP1:       cmp   Popitka,3
           jne   LP3
           mov   al,10000000b
           out   08h,al
           mov   Error,0FFh
           mov   Block,0FFh
LP3:       ret
LampaP123  ENDP

; Блокировка системы 
Blokirovka PROC  NEAR
           cmp   Block,0FFh
           jne   B
           mov   dx,22
B1:        mov   cx,00FFFh
B2:        mov   al,00h
           out   01h,al
           out   02h,al
           out   03h,al
           out   04h,al 
           loop  B2
           dec   dx
           jnz   B1
           call  Prepare           
B:         ret
Blokirovka ENDP  

; Формирование цифры на дисплеи, учавствующей в формирование кода второго уровня 
DestDspl1  PROC  NEAR
           cmp   Uroven,1
           jne   DD11
           
           mov   dx,5
DD13:      mov   cx,00FFFh
DD12:      mov   al,Load2Dec
           out   04h,al
           mov   al,00h
           out   03h,al
           out   02h,al
           out   01h,al
           loop  DD12
           dec   dx
           jnz   DD13
           mov   al,00h
           out   01h,al
           out   02h,al
           out   03h,al
           out   04h,al
           mov   ax,0000h
           mov   word ptr [di],ax
           mov   word ptr [di+2],ax
DD11:      ret           
DestDspl1   ENDP

; Проверка кода второго уровня
Proverka2  PROC  NEAR
           cmp   Uroven,1
           jne   P21
           in    al,00h
           and   al,01100000b
           cmp   al,01000000b
           jne   P21
           lea   bx,KodLoad2
           mov   al,[bx]
           cmp   al,byte ptr [di]
           jne   P23
           mov   al,[bx+1]
           cmp   al,byte ptr [di+1]
           jne   P23
           mov   al,[bx+2]
           cmp   al,byte ptr [di+2]
           jne   P23
           mov   al,[bx+3]
           cmp   al,byte ptr [di+3]
           jne   P23
           Call  LampaU2
           mov   Uroven,2
           Call  DestDspl2
           mov   Popitka,0
           jmp   P21
P23:       inc   Popitka
           Call  Delay1
           Call  LampaP123
P21:       ret           
Proverka2  ENDP

LampaU2    PROC  NEAR
           mov   al,0
           out   08h,al
           mov   al,00001000b
           out   08h,al
           ret         
LampaU2    ENDP

DestDspl2  PROC  NEAR
           mov   dx,2
DD22:      mov   cx,000FFh
DD23:      lea   si,Alphavit
           
           mov   bh,4
DD24:      mov   al,0
           out   07h,al
           mov   al,bh
           out   05h,al
           mov   bl,1
DD25:      mov   al,0
           out   07h,al
           ;mov   al,es:[si] 
           Call  Smechenie
           not   al
           out   06h,al
           mov   al,bl
           out   07h,al
           shl   bl,1
           inc   si
           jnc   DD25
           shl   bh,1
           cmp   bh,8
           jnz   DD24
           loop  DD23
           dec   dx
           jnz   DD22
           
           mov   bh,4
DD26:      mov   al,0
           out   07h,al
           mov   al,bh
           out   05h,al
           mov   bl,1
DD27:      mov   al,0
           out   07h,al
           mov   al,es:[si+8*26]
           not   al
           out   06h,al
           mov   al,bl
           out   07h,al
           shl   bl,1
           inc   si
           jnc   DD27
           shl   bh,1
           cmp   bh,8
           jnz   DD26
           
           mov   al,00h
           out   01h,al
           out   02h,al
           out   03h,al
           out   04h,al
           mov   ax,0000h
           mov   word ptr [di],ax
           mov   word ptr [di+2],ax     
DD21:      ret           
DestDspl2   ENDP

Smechenie  PROC  NEAR
           cmp   set,00001110b
           jne   S2
           mov   al,es:[si+8*13]
           jmp   S1
S2:        cmp   set,00011000b
           jne   S3
           mov   al,es:[si+8*23]
           jmp   S1
S3:        cmp   set,00000000b
           jne   S4
           mov   al,es:[si]
           jmp   S1
S4:        cmp   set,00000001b
           jne   S5
           mov   al,es:[si]
           jmp   S1
S5:        cmp   set,00000010b
           jne   S6
           mov   al,es:[si+8*1]
           jmp   S1
S6:        cmp   set,00000011b
           jne   S7
           mov   al,es:[si+8*2]
           jmp   S1
S7:        cmp   set,00000100b
           jne   S8
           mov   al,es:[si+8*3]
           jmp   S1 
S8:        cmp   set,00000101b
           jne   S9
           mov   al,es:[si+8*4]
           jmp   S1
S9:        cmp   set,00000110b
           jne   S10
           mov   al,es:[si+8*5]
           jmp   S1
S10:       cmp   set,00000111b
           jne   S11
           mov   al,es:[si+8*6]
           jmp   S1 
S11:       cmp   set,00001000b
           jne   S12
           mov   al,es:[si+8*7]
           jmp   S1
S12:       cmp   set,00001001b
           jne   S13
           mov   al,es:[si+8*8]
           jmp   S1
S13:       cmp   set,00001010b
           jne   S14
           mov   al,es:[si+8*9]
           jmp   S1 
S14:       cmp   set,00001011b
           jne   S15
           mov   al,es:[si+8*10]
           jmp   S1
S15:       cmp   set,00001100b
           jne   S16
           mov   al,es:[si+8*11]
           jmp   S1 
S16:       cmp   set,00001101b
           jne   S17
           mov   al,es:[si+8*12]
           jmp   S1            
S17:       cmp   set,00001111b
           jne   S18
           mov   al,es:[si+8*14]
           jmp   S1
S18:       cmp   set,00010000b
           jne   S19
           mov   al,es:[si+8*15]
           jmp   S1 
S19:       cmp   set,00010001b
           jne   S20
           mov   al,es:[si+8*16]
           jmp   S1
S20:       cmp   set,00010010b
           jne   S21
           mov   al,es:[si+8*17]
           jmp   S1 
S21:       cmp   set,00010011b
           jne   S22
           mov   al,es:[si+8*18]
           jmp   S1
S22:       cmp   set,00010100b
           jne   S23
           mov   al,es:[si+8*19]
           jmp   S1            
S23:       cmp   set,00010101b
           jne   S24
           mov   al,es:[si+8*20]
           jmp   S1
S24:       cmp   set,00010110b
           jne   S25
           mov   al,es:[si+8*21]
           jmp   S1
S25:       cmp   set,00010111b
           jne   S26
           mov   al,es:[si+8*22]
           jmp   S1
S26:       cmp   set,00011001b
           jne   S27
           mov   al,es:[si+8*24]
           jmp   S1            
S27:       cmp   set,00011010b
           jne   S1
           mov   al,es:[si+8*25]
S1:        ret
Smechenie  ENDP


Proverka3  PROC  NEAR
           cmp   Uroven,2
           jne   P31
           in    al,00h
           and   al,01100000b
           cmp   al,01000000b
           jne   P31
           lea   si,KodLoad3
           mov   al,byte ptr [si]
           cmp   byte ptr [di],al
           Jne   P32
           mov   al,byte ptr [si+1]
           cmp   byte ptr [di+1],al
           jne   P32
           mov   al,byte ptr [si+2]
           cmp   byte ptr [di+2],al
           Jne   P32
           mov   al,byte ptr [si+3]
           cmp   byte ptr [di+3],al
           jne   P32
           Call  LampaU3
           mov   Open,0FFh
           jmp   P31
P32:       inc   Popitka
           Call  Delay1
           Call  LampaP123           
P31:       ret              
Proverka3  ENDP

LampaU3    PROC  NEAR
           mov   al,0
           out   08h,al
           mov   al,00010000b
           out   08h,al
           ret         
LampaU3    ENDP

OpenDoor   PROC  NEAR
           cmp   Open,0FFh
           jne   OD1
            
           mov   dx,0
InfLoop:   Call  Delay
           lea   bx,Image
           add   bx,dx
           mov   ch,1
OutNextInd:
           mov   al,0
           out   07h,al
           mov   al,ch
           out   05h,al
           mov   cl,1
OutNextCol:
           mov    al,0
           out   07h,al
           mov   al,es:[bx]
           not   al
           out   06h,al
           mov   al,cl
           out   07h,al
           shl   cl,1
           inc   bx
           jnc   OutNextCol
           shl   ch,1
           cmp   ch,16
           jnz   OutNextInd
           inc   dx
           cmp   dx,4*16
           jnz   InfLoop
           Call  Prepare 
OD1:       ret                                           
OpenDoor   ENDP

ErrorDs   PROC  NEAR
           cmp   Error,0FFh
           jne   ED4 
            
           mov   dx,0
ED1:       Call  Delay
           lea   bx,Image1
           add   bx,dx
           mov   ch,1
ED2:
           mov   al,0
           out   07h,al
           mov   al,ch
           out   05h,al
           mov   cl,1
ED3:
           mov    al,0
           out   07h,al
           mov   al,es:[bx]
           not   al
           out   06h,al
           mov   al,cl
           out   07h,al
           shl   cl,1
           inc   bx
           jnc   ED3
           shl   ch,1
           cmp   ch,16
           jnz   ED2
           inc   dx
           cmp   dx,4*16
           jnz   ED1
           
ED4:       ret                                            
ErrorDs   ENDP

Delay      PROC  NEAR
           push  cx
           mov   cx,65000
DelayLoop: inc   cx
           dec   cx
           inc   cx
           dec   cx
           loop  DelayLoop
           pop   cx
           ret           
Delay      ENDP

Delay1      PROC  NEAR
           push  cx
           mov   cx,65000
DelayLoop1: inc   cx
           dec   cx
           inc   cx
           dec   cx
           inc   cx
           dec   cx
           
           loop  DelayLoop1
           pop   cx
           ret           
Delay1      ENDP

; Подготовительный этап
Prepare    PROC  NEAR
           mov   al,00h
           out   08h,al
           out   04h,al
           out   03h,al
           out   02h,al
           out   01h,al
           mov   KbdErr,0
           mov   Popitka,0
           mov   Uroven,0
           mov   Block,0
           mov   Error,0
           mov   Open,0
           lea   di,CopyDsPl
           mov   ax,0
           mov   word ptr [di],ax
           mov   word ptr [di+2],ax
           lea   di,Kod1Bin
           mov   ax,0
           mov   word ptr [di],ax
           mov   word ptr [di+2],ax
           lea   di,DsPlay
           mov   ax,0
           mov   word ptr [di],ax
           mov   word ptr [di+2],ax
           ret
Prepare    ENDP


Start:     mov   ax,Data
           mov   ds,ax
           mov   ax,Code
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
                     
           Call  Prepare
           
Beg_Loop:
           Call  KbdInput         
           Call  KbdInContr
           Call  NxtDig 
           Call  OutDigit
           Call  Ustanov1
           
           Call  Proverka1
           Call  Proverka2
           Call  Proverka3
           Call  ErrorDs 
           Call  Blokirovka
           Call  OpenDoor
           Jmp Beg_Loop           
      
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END