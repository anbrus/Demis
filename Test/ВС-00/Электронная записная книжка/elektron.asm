;.386
RomSize    EQU   4096
NMax       EQU   50          ; константа подавления дребезга
KbdPort    EQU   4           ; адреса портов


;--------------Сегмент данных-------------------------------------------------------

Data       SEGMENT AT 1000h 
;Здесь размещаются описания переменных

bloknot    db    512 dup(?)
telefon    db    256 dup(?)        
familiya   db    256 dup(?)
adress     db    256 dup(?)
MAS_POISK  DB    32  DUP(?)
F_POISK    DB    ?
F_TS       DB    ?
F_BLOK     DB    ?
F_ADR      DB    ?
F_FAM      DB    ?
F_TEL      DB    ?
F_KLAV     DB    ?
KLAV       DB    ?
NIZ_PORT   DB    ?
LEW        DB    ?           ;СДВИГ ВЛЕВО
F_LEW      DB    ?
PRAW       DB    ?           ;СДВИГ ВПРАВО
F_PRAW     DB    ?
KOL_SOOB   DB    2 DUP (?)
KOL_B      DB    ?
KOL_T      DB    ?
KOL_BLOK   DB    16 DUP(?)
KOL_FAM    DB    16 DUP(?)
KOL_ADR    DB    16 DUP(?)
KOL_TEL    DB    16 DUP(?)
KOL_POISK  DB    ?
POISK_POZ  DB    ?
F_NEW      DB    ?


Data       ENDS
    ;---------------Сегмент кода---------------------------------------------------------
Code       SEGMENT
           ASSUME cs:Code,ds:Data
;------------------------------------------------------------------------------------
Image      db    00000000b,00011000b,00100100b,01000010b,01111110b,01000010b,01000010b,00000000b  ;"А"0
           db    00000000b,01111110b,00000010b,01111110b,01000010b,01000010b,01111110b,00000000b  ;"Б"1                 
           db    00000000b,00011110b,00100010b,00111110b,01000010b,01000010b,00111110b,00000000b  ;"В"2
           db    00000000b,01111110b,01000010b,00000010b,00000010b,00000010b,00000010b,00000000b  ;"Г"3
           db    00000000b,00011000b,00100100b,00100100b,00100100b,00100100b,01111110b,01000010b  ;"Д"4
           db    00000000b,01111110b,00000010b,00011110b,00000010b,00000010b,01111110b,00000000b  ;"Е"5
           db    00000000b,01011010b,00111100b,00011000b,00011000b,00111100b,01011010b,00000000b  ;"Ж"6
           db    00000000b,00111100b,01000000b,00111000b,01000000b,01000010b,00111100b,00000000b  ;"З"7
           db    00000000b,01000010b,01100010b,01010010b,01001010b,01000110b,01000010b,00000000b  ;"И"8
           db    00000000b,00100010b,00010010b,00001110b,00010010b,00100010b,01000010b,00000000b  ;"K"9
           db    00000000b,00011000b,00100100b,01000010b,01000010b,01000010b,01000010b,00000000b  ;"Л"10
           db    00000000b,01000010b,01100110b,01011010b,01000010b,01000010b,01000010b,00000000b  ;"М"11
           db    00000000b,01000010b,01000010b,01111110b,01000010b,01000010b,01000010b,00000000b  ;"Н"12
           db    00000000b,00111100b,01000010b,01000010b,01000010b,01000010b,00111100b,00000000b  ;"О"13
           db    00000000b,01111110b,01000010b,01000010b,01000010b,01000010b,01000010b,00000000b  ;"П"14
           db    00000000b,00111110b,01000010b,01000010b,00111110b,00000010b,00000010b,00000000b  ;"Р"15
           db    00000000b,00111100b,01000010b,00000010b,00000010b,01000010b,00111100b,00000000b  ;"С"16
           db    00000000b,01111110b,00011000b,00011000b,00011000b,00011000b,00011000b,00000000b  ;"Т"17
           db    00000000b,01000010b,01000010b,01000010b,01111100b,01000000b,00111110b,00000000b  ;"У"18
           db    00000000b,00111100b,01011010b,01011010b,01011010b,00111100b,00011000b,00000000b  ;"Ф"19
           db    00000000b,01000010b,00100100b,00011000b,00011000b,00100100b,01000010b,00000000b  ;"Х"20
           db    00000000b,00100010b,00100010b,00100010b,00100010b,00100010b,01111110b,01000000b  ;"Ц"21
           db    00000000b,01000010b,01000010b,01000010b,01111100b,01000000b,01000000b,00000000b  ;"Ч"22
           db    00000000b,01011010b,01011010b,01011010b,01011010b,01011010b,01111110b,00000000b  ;"Ш"23
           db    00000000b,00101010b,00101010b,00101010b,00101010b,00101010b,01111110b,01000000b  ;"Щ"24
           db    00000000b,00001110b,00001010b,00111000b,01000100b,01000100b,00111100b,00000000b  ;"Ъ"25
           db    00000000b,01000010b,01000010b,01001110b,01010010b,01010010b,01001110b,00000000b  ;"Ы"26
           db    00000000b,00000010b,00000010b,00111110b,01000010b,01000010b,00111110b,00000000b  ;"Ь"27
           db    00000000b,00111100b,01000010b,01111000b,01111000b,01000010b,00111100b,00000000b  ;"Э"28
           db    00000000b,00110010b,01001010b,01001110b,01001110b,01001010b,00110010b,00000000b  ;"Ю"29
           db    00000000b,01111000b,01000100b,01000100b,01111000b,01000100b,01000010b,00000000b  ;"Я"30
           db    00000000b,00010000b,00011000b,00010100b,00010000b,00010000b,00010000b,00000000b  ;"1"31
           db    00000000b,00011000b,00100100b,00100000b,00010000b,00001000b,00111100b,00000000b  ;"2"32
           db    00000000b,00111100b,00100000b,00011000b,00100000b,00100100b,00011000b,00000000b  ;"3"33
           db    00000000b,00100100b,00100100b,00100100b,00111100b,00100000b,00100000b,00000000b  ;"4"34
           db    00000000b,00111100b,00000100b,00011100b,00100000b,00100000b,00011100b,00000000b  ;"5"35
           db    00000000b,00111000b,00000100b,00011100b,00100100b,00100100b,00011000b,00000000b  ;"6"36
           db    00000000b,00111100b,00100000b,00100000b,00010000b,00001000b,00000100b,00000000b  ;"7"37
           db    00000000b,00011000b,00100100b,00011000b,00100100b,00100100b,00011000b,00000000b  ;"8"38
           db    00000000b,00011000b,00100100b,00100100b,00111000b,00100000b,00011100b,00000000b  ;"9"39
           db    00000000b,00011000b,00100100b,00100100b,00100100b,00100100b,00011000b,00000000b  ;"0"40  
           db    00000000b,00001000b,00001000b,00001000b,00001000b,00000000b,00001000b,00000000b  ;"!"41
           db    00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00000000b  ;пробел 46  
           
            Im     db    03Fh ,00Ch ,076h ,05Eh,04Dh,05Bh,07Bh ,00Eh,07Fh,05Fh    
           ASSUME cs:Code,ds:code,es:data

 ;Здесь размещается код программы
 
 
OBNULENIE PROC NEAR
           
           lea bx, BLOKNOT        
           mov cx,512
e_3:       mov ax,ES:[bx]
           xor ax,ax         
           mov ES:[bx],ax
           add bx,2
           loop e_3
           
           lea bx, TELEFON 
           mov cx,256
e_4:       mov ax,ES:[bx]
           xor ax,ax
           mov ES:[bx],ax
           add bx,2
           loop e_4 
           
           lea bx, FAMILIYA 
           mov cx,256
e_5:       mov ax,ES:[bx]
           xor ax,ax
           mov ES:[bx],ax
           add bx,2
           loop e_5 
           
           Lea bx, ADRESS 
           mov cx,256
e_6:       mov ax,ES:[bx]
           xor ax,ax
           mov ES:[bx],ax
           add bx,2
           loop e_6  
           
           lea bx, KOL_BLOK 
           mov cx,16
e_7:       mov ax,ES:[bx]
           xor ax,ax
           mov ES:[bx],ax
           add bx,2;
           loop e_7 
           
           lea bx, KOL_FAM
           mov cx,16
e_8:       mov ax,ES:[bx]
           xor ax,ax
           mov ES:[bx],ax
           add bx,2
           loop e_8
           
           lea   bx, KOL_ADR
           mov   cx,16
e_9:       mov   ax,ES:[bx]
           xor   ax,ax
           mov   ES:[bx],ax
           add   bx,2
           loop  e_9
           
           lea   bx, KOL_TEL
           mov   cx,16
e_10:      mov   ax,ES:[bx]
           xor   ax,ax
           mov   ES:[bx],ax
           add   bx,2
           loop  e_10 
                                 
           lea   bx,MAS_POISK
           mov   cx,32
e_11:      mov   ax,ES:[bx]
           xor   ax,ax
           mov   ES:[bx],ax
           add   bx,2
           loop  e_11
           
           MOV   KOL_SOOB[0],0
           MOV   KOL_SOOB[1],0
           MOV   KOL_POISK,0
           MOV   F_POISK,0
           MOV   F_TS,0
           MOV   F_BLOK,0
           MOV   F_ADR,0
           MOV   F_FAM,0
           MOV   F_TEL,0
           MOV   f_KLAV,0           
           MOV   F_LEW,0
           MOV   F_PRAW,0
           MOV   LEW,0
           MOV   PRAW,0
           MOV   KOL_B,0
           MOV   KOL_T,0
           MOV   POISK_POZ,0
           RET
OBNULENIE ENDP

IN_KLAV PROC NEAR     ;опрос клавиатуры    
           MOV   F_KLAV,0           
           mov   dl,1
           xor   cx,cx
k2:        mov   al,dl
           out   0h,al
           in    al,0h
           cmp   al,0
           jne   k5          
           cmp   dl,0
           je    k9
           shl   dl,1         
           jmp   k2     
                 
k5:        push  ax           
k4:        in    al,0h
           or    al,al
           jnz   k4           
           pop   ax
           MOV   F_KLAV,0FFH
k1:        inc   cl          ;номер столбца
           shr   al,1
           cmp   al,0
           jnz   k1
           dec   cl
k3:        inc   ch         
           shr   dl,1
           cmp   dl,0
           jnz   k3
           dec   ch          ;номер строки
           mov   al,ch
           mov   dl,8
           mul   dl
           add   al,cl
           mov   klav,al     ;номер кнопки
           
           CMP   F_POISK,0FFH
           JNE   K10
           CALL  K_POISK
           JMP   K9
           
K10:       CMP   F_BLOK,0FFH
           JNE   K6           
           CMP   KLAV,46
           JNE   K7           
           CMP   LEW,0
           JE    K9     
           MOV   F_LEW,0FFH      
           DEC   LEW
           INC   PRAW
K9:        JMP   KLAV_RET
K7:        CMP   KLAV,45
           JNE   K8           
           CMP   PRAW,0
           JE    KLAV_RET
           MOV   F_PRAW,0FFH
           INC   LEW
           DEC   PRAW
           JMP   KLAV_RET           
K8:        CALL  BLOK_MASS
           JMP   KLAV_RET
           
K6:        CMP   F_TS,0FFH
           JNE   klav_ret
           CMP   KLAV,46
           JE    KLAV_RET
           CMP   KLAV,45
           JE    KLAV_RET
           CALL  TS_MASS
klav_ret:  ret  
           IN_KLAV ENDP 
           
INDIKATOR PROC NEAR
           XOR   AX,AX
           CMP   F_BLOK,0FFH
           JNE   I1
           OR    AL,1
I1:        CMP   F_TS,0FFH
           JNE   I2
           OR    AL,2
I2:        CMP   F_FAM,0FFH
           JNE   I3
           OR    AL,4
I3:        CMP   F_ADR,0FFH
           JNE   I4
           OR    AL,8
I4:        CMP   F_TEL,0FFH
           JNE   I5
           OR    AL,10H
I5:        CMP   F_POISK,0FFH
           JNE   I6
           OR    AL,20H
I6:        OUT   40H,AL  
           RET
INDIKATOR ENDP 

BLOK_MASS PROC NEAR
           XOR   AX,AX
           MOV   AL,KOL_SOOB[0]
           MOV   DI,AX
                                
           CMP   KLAV,43
           JNE   B3
           CMP   KOL_SOOB[0],15
           JE    B5
           INC   KOL_SOOB[0]
           INC   KOL_B
           JMP   B2
B3:        CMP   KLAV,44
           JNE   B4
           CMP   KOL_SOOB[0],0
           JE    B2
           DEC   KOL_SOOB[0]
           JMP   B2
B4:        CMP   KLAV,47
           JNE   B1
           CMP   KOL_BLOK[DI],0
           JE    B2        
           DEC   KOL_BLOK[DI] 
B5:        JMP   B2      
B1:        CMP   KOL_BLOK[DI],32
           JE    B2
           XOR   AX,AX
           
           MOV   AL,KOL_BLOK[DI]
           INC   KOL_BLOK[DI] 
           MOV   SI,AX
           SHL   DI,5
           ADD   SI,DI
           SHR   DI,5
           MOV   AL,KLAV        
           MOV   BLOKNOT[SI],AL
           MOV   LEW,0
           MOV   PRAW,0
           MOV   AL,KOL_BLOK[DI]
           MOV   LEW,AL
           MOV   AL,16
           SUB   LEW,AL
           MOV   F_LEW,0
           MOV   F_PRAW,0       
B2:    
           RET
BLOK_MASS ENDP

TS_MASS PROC NEAR
           XOR   AX,AX
           MOV   AL,KOL_SOOB[1]
           MOV   DI,AX           
           CMP   KLAV,43
           JNE   T8
           CMP   KOL_SOOB[1],15
           JE    T10
           INC   KOL_SOOB[1]
           INC   KOL_T
           JMP   T3
T8:        CMP   KLAV,44
           JNE   T9
           CMP   KOL_SOOB[1],0
           JE    T10
           DEC   KOL_SOOB[1]
T10:       JMP   T3

T9:        CMP   F_FAM,0FFH
           JNE   T1
           CMP   KLAV,47
           JNE   T4
           CMP   KOL_FAM[DI],0
           JE    T1        
           DEC   KOL_FAM[DI] 
           JMP   T1 
T4:        CMP   KOL_FAM[DI],16
           JE    T7     
           XOR   AX,AX
           MOV   AL,KOL_FAM[DI]
           SHL   DI,4
           MOV   SI,AX      
           ADD   SI,DI
           SHR   DI,4
           MOV   AL,KLAV
           MOV   FAMILIYA[SI],AL       
           INC   KOL_FAM[DI]      
T7:        JMP   T3
                      
T1:        CMP   F_ADR,0FFH
           JNE   T2
           CMP   KLAV,47
           JNE   T5
           CMP   KOL_ADR[DI],0
           JE    T2 
                
           DEC   KOL_ADR[DI] 
           JMP   T2 
T5:        CMP   KOL_ADR[DI],16
           JE    T3      
           XOR   AX,AX
           MOV   AL,KOL_ADR[DI]
           MOV   SI,AX
           SHL   DI,4
           ADD   SI,DI
           SHR   DI,4
           MOV   AL,KLAV
           MOV   ADRESS[SI],AL
           INC   KOL_ADR[DI]       
           JMP   T3
           
T2:        CMP   F_TEL,0FFH
           JNE   T3
           CMP   KLAV,47
           JNE   T6
           CMP   KOL_TEL[DI],0
           JE    T3       
           DEC   KOL_TEL[DI] 
           JMP   T3
T6:        CMP   KOL_TEL[DI],16
           JE    T3      
           XOR   AX,AX
           MOV   AL,KOL_TEL[DI]
           MOV   SI,AX
           SHL   DI,4
           ADD   SI,DI
           SHR   DI,4
           MOV   AL,KLAV
           MOV   TELEFON[SI],AL
           INC   KOL_TEL[DI]       
T3:        RET
TS_MASS ENDP

OPROS_PORTA PROC NEAR
           IN    AL,80H
           CMP   AL,0
           JE    O11
           MOV   F_NEW,0FFH
           JMP   O1
           
O11:       IN    AL,40H
           CMP   AL,0
           JE    O1   
           
           PUSH  AX
O10:       IN    AL,40H
           OR    AL,AL
           JNZ   O10
           POP   AX
                     
           CMP   AL,1
           JNE   O2           
           CALL  K_BLOKNOT
           JMP   O1
O2:        CMP   AL,2
           JNE   O3
           CALL  K_TS
           JMP   O1
O3:        CMP   AL,4
           JNE   O4
           CALL  K_FAM
           JMP   O1
O4:        CMP   AL,8
           JNE   O5
           CALL  K_ADR
           JMP   O1
O5:        CMP   AL,10H
           JNE   O6
           CALL  K_TEL
           JMP   O1 
O6:        CMP   AL,20H
           JNE   O7
           NOT   F_POISK
           JMP   O1
O7:        CMP   AL,40H
           JNE   O8
           CALL  K_ENTER
           JMP   O1
O8:        CMP   AL,80H
           JNE   O1
           CALL  RESET
O1:        RET
OPROS_PORTA ENDP

RESET PROC NEAR
           CMP   F_POISK,0FFH
           JNE   R4
           MOV   KOL_POISK,0
           JMP   RESET_RET
           
R4:        CMP   F_BLOK,0FFH
           JNE   R1
           XOR   AX,AX
           MOV   AL,KOL_SOOB[0]
           MOV   SI,AX
           MOV   KOL_BLOK[SI],0
           JMP   RESET_RET
           
R1:        CMP   F_TS,0FFH
           JNE   RESET_RET   
           XOR   AX,AX
           MOV   AL,KOL_SOOB[1]
           MOV   SI,AX          
           
           CMP   F_FAM,0FFH
           JNE   R2
           MOV   KOL_FAM[SI],0
           
R2:        CMP   F_ADR,0FFH
           JNE   R3
           MOV   KOL_ADR[SI],0
           
R3:        CMP   F_TEL,0FFH
           JNE   RESET_RET   
           MOV   KOL_TEL[SI],0
RESET_RET: RET
RESET ENDP           

K_ENTER PROC NEAR
           XOR   BH,BH
           CMP   F_POISK,0FFH
           JNE   E10
           CMP   F_BLOK,0FFH
           JNE   E1
           LEA   SI,BLOKNOT
           MOV   DX,SI
           XOR   CX,CX
           MOV   BL,POISK_POZ
E8:        MOV   CL,KOL_POISK
           MOV   DI,0  
           SHL   BL,5
           MOV   SI,DX
           ADD   SI,BX
           SHR   BL,5         
E5:        MOV   AL,ES:[SI]
           CMP   MAS_POISK[DI],AL
           JNE   E6
           INC   DI
           INC   SI
           CMP   CL,1
           JE    E7
           DEC   CL
           JMP   E5
E6:        CMP   BL,KOL_B
           JAE   E12
           INC   BL
           JMP   E8
E7:        MOV   KOL_SOOB[0],BL
           INC   BL
           MOV   POISK_POZ,BL
           JMP   E10
E12:       MOV   POISK_POZ,0   
           MOV   AL,KOL_B
           MOV   KOL_SOOB[0],AL                   
E10:       JMP   E4             
 
E1:        CMP   F_TEL,0FFH
           JNE   E2
           LEA   SI,TELEFON
           MOV   DX,SI
           JMP   E9
E2:        CMP   F_FAM,0FFH
           JNE   E3
           LEA   SI,FAMILIYA
           MOV   DX,SI
           JMP   E9
E3:        CMP   F_ADR,0FFH
           JNE   E4
           LEA   SI,ADRESS
           MOV   DX,SI
E9:        XOR   CX,CX
           MOV   BL,POISK_POZ
EE8:       MOV   CL,KOL_POISK
           MOV   DI,0 
           SHL   BL,4
           MOV   SI,DX
           ADD   SI,BX
           SHR   BL,4          
EE5:       MOV   AL,ES:[SI]
           CMP   MAS_POISK[DI],AL
           JNE   EE6
           INC   DI
           INC   SI
           CMP   CL,1
           JE    EE7
           DEC   CL
           JMP   EE5
EE6:       CMP   BL,KOL_T
           JAE   EE9
           INC   BL
           JMP   EE8
EE7:       MOV   KOL_SOOB[1],BL          
           INC   BL
           MOV   POISK_POZ,BL
           JMP   E4
EE9:       MOV   POISK_POZ,0   
           MOV   AL,KOL_T
           MOV   KOL_SOOB[1],AL                   
E4:        MOV   F_POISK,0
           RET
K_ENTER ENDP

NEW_ZAP PROC NEAR
           CMP   F_POISK,0FFH
           JE    N1
           XOR   SI,SI
           XOR   AX,AX
           CMP   F_NEW,0FFH
           JNE   N1        
           CMP   F_BLOK,0FFH
           JNE   N2
           MOV   SI,0
N4:        CMP   KOL_BLOK[SI],0
           JE    N3
           INC   SI
           CMP   SI,15
           JNE   N4   
           MOV   KOL_SOOB[0],0
           JMP   N1
N3:        MOV   AX,SI
           MOV   KOL_SOOB[0],AL
           JMP   N1
N2:        CMP   F_TS,0FFH
           JNE   N1           
           MOV   SI,0
N7:        CMP   KOL_FAM[SI],0
           JNE   N5
           CMP   KOL_ADR[SI],0
           JNE   N5
           CMP   KOL_TEL[SI],0
           JE    N6
N5:        INC   SI
           CMP   SI,15
           JNE   N7
           MOV   KOL_SOOB[1],0
           JMP   N1
N6:        MOV   AX,SI
           MOV   KOL_SOOB[1],AL
N1:        MOV   F_NEW,0
           RET
NEW_ZAP ENDP

K_BLOKNOT PROC NEAR
           MOV   F_BLOK,0FFH
           MOV   F_TS,0
           MOV   F_FAM,0
           MOV   F_ADR,0
           MOV   F_TEL,0
           MOV   POISK_POZ,0
           RET
K_BLOKNOT   ENDP

K_TS PROC NEAR
           MOV   F_BLOK,0
           MOV   F_TS,0FFH
           RET
K_TS ENDP

K_FAM PROC NEAR
           CMP   F_TS,0FFH
           JNE   KF1
           MOV   F_FAM,0FFH
           MOV   F_ADR,0
           MOV   F_TEL,0
           MOV   POISK_POZ,0
KF1:        RET
K_FAM      ENDP   
        
K_ADR PROC NEAR
           CMP   F_TS,0FFH
           JNE   KF2
           MOV   F_FAM,0
           MOV   F_ADR,0FFH
           MOV   F_TEL,0
           MOV   POISK_POZ,0
KF2:       RET
K_ADR      ENDP           

K_TEL PROC NEAR
           CMP   F_TS,0FFH
           JNE   KF3
           MOV   F_FAM,0
           MOV   F_ADR,0
           MOV   F_TEL,0FFH
           MOV   POISK_POZ,0
KF3:       RET
K_TEL      ENDP           


K_POISK PROC NEAR
           CMP   KLAV,46
           JE    KP2
           CMP   KLAV,45
           JE    KP2
           CMP   KLAV,44
           JE    KP2
           CMP   KLAV,43
           JE    KP2
           CMP   KLAV,47
           JNE   KP1
           CMP   KOL_POISK,0
           JE    KP2        
           DEC   KOL_POISK 
           JMP   KP2      
KP1:       CMP   KOL_POISK,16
           JE    KP2

           MOV   AL,KOL_POISK
           MOV   SI,AX            
           MOV   AL,KLAV        
           MOV   MAS_POISK[SI],AL
           INC   KOL_POISK
KP2:       RET
K_POISK    ENDP 

OUT_MASS_TS PROC NEAR
           XOR   AX,AX
           MOV   AL,KOL_SOOB[1]
        
           MOV   SI,AX
           XOR   CX,CX
           XOR   AX,AX
           MOV   NIZ_PORT,1
           
           CMP   F_POISK,0FFH
           JNE   OM7
           LEA   DI,MAS_POISK
           MOV   CL,KOL_POISK    
           JMP   OM6
           
OM7:       CMP   F_FAM,0FFH
           JNE   OM1    
           LEA   DI,FAMILIYA
           MOV   CL,KOL_FAM[SI]
           JMP   OM8
OM1:       CMP   F_ADR,0FFH 
           JNE   OM3
           LEA   DI,ADRESS
           MOV   CL,KOL_ADR[SI]
           JMP   OM8
OM3:       CMP   F_TEL,0FFH
           JNE   OM4                             
           LEA   DI,TELEFON
           MOV   CL,KOL_TEL[SI]
           JMP   OM8

OM8:       MOV   AL,KOL_SOOB[1]
           SHL   AL,4
           ADD   DI,AX
OM6:       CMP   CL,0
           JE    OM4 
                      
OM2:       PUSH  CX
           LEA   BX,IMAGE                                 
           MOV   CL,1          
           MOV   AL,ES:[DI]          
           mov   dl,8
           mul   dl
           add   bx,ax
           
OM5:       MOV   AL,1
           OUT   30H,AL
           MOV   AL,CL
           OUT   20H,AL
           MOV   AL,[BX]
           XOR   DX,DX
           MOV   DL,NIZ_PORT
           OUT   DX,AL
           MOV   AL,0
           OUT   DX,AL
           SHL   CL,1
           INC   BX
           CMP   CL,0
           JNE   OM5  
           INC   NIZ_PORT
           INC   DI       
           POP   CX
           LOOP  OM2
OM4:       RET
OUT_MASS_TS ENDP

OUT_MASS_BLOK PROC
           XOR   AX,AX
           MOV   AL,KOL_SOOB[0]
           SHL   AX,5
           LEA   DI,BLOKNOT
           ADD   DI,AX
           SHR   AX,5   
           MOV   SI,AX
           XOR   CX,CX
           XOR   AX,AX
           MOV   NIZ_PORT,1
           CMP   F_POISK,0FFH
           JE    OMB7
           CMP   F_BLOK,0FFH
           JNE   OMB7  
           
           
           MOV   CL,KOL_BLOK[SI]
           CMP   CL,0
           JE    OMB7    
           CMP   CL,10H
           JBE   OMB2
           PUSH  CX
           MOV   AX,16
           SUB   CX,AX
           ADD   DI,CX
           POP   CX 
           
           CMP   F_LEW,0FFH
           JNE   OMB6                      
           MOV   AL,PRAW
           SUB   DI,AX
           JMP   OMB2
OMB7:      JMP   OMB4

OMB6:      CMP   F_PRAW,0FFH
           JNE   OMB2                     
           MOV   AL,LEW
           SUB   DI,AX                      
               
OMB2:      PUSH  CX
           LEA   BX,IMAGE                                 
           MOV   CL,1          
           MOV   AL,ES:[DI]          
           mov   dl,8
           mul   dl
           add   bx,ax
           
OMB5:      MOV   AL,1
           OUT   30H,AL
           MOV   AL,CL
           OUT   20H,AL
           MOV   AL,[BX]
           XOR   DX,DX
           MOV   DL,NIZ_PORT
           OUT   DX,AL
           MOV   AL,0
           OUT   DX,AL
           SHL   CL,1
           INC   BX
           CMP   CL,0
           JNE   OMB5  
           INC   NIZ_PORT
           INC   DI       
           POP   CX
           LOOP  OMB2
OMB4:      RET

OUT_MASS_BLOK ENDP

;В следующей строке необходимо указать смещение стартовой точки
        Start:
           mov   ax,Code
           mov   ds,ax
           mov   ax,data
           mov   Es,ax
           CALL  OBNULENIE
ST1:       CALL  IN_KLAV 
           CALL  OPROS_PORTA
           CALL  INDIKATOR
           CALL  NEW_ZAP
           CALL  OUT_MASS_TS
           CALL  OUT_MASS_BLOK
           JMP   ST1
           
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
