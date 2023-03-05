
RomSize    EQU   4096
;--------------‘¥£¬¥­β αβ¥ª --------------------------------------------------------
Stk        SEGMENT AT 100h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

;--------------‘¥£¬¥­β ¤ ­­λε-------------------------------------------------------
Data       SEGMENT AT 0
                                      ;δ« £¨|   Άΰ¥¬ο     |
device     DB    4           DUP(?)    ;0000 0000 0000 0000    
           DB    4           DUP(?)    ;0000 0000 0000 0000    
           DB    4           DUP(?)    ;0000 0000 0000 0000      
LINE       DB    ?
TEMP       DW    5           DUP(?) 
TEMP2      DW    ?

Data       ENDS

;---------------‘¥£¬¥­β ª®¤ ---------------------------------------------------------
Code       SEGMENT
           ASSUME cs:Code,ds:Data,ss:Stk
IMAGE      DB   03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,0Eh,07Fh,05Fh          
;---------------­¨ζ¨ «¨§ ζ¨ο ¬ αα¨Ά®Ά----------------------------------------------
INIT       PROC  NEAR 
                 
           mov   word ptr device,0
           mov   word ptr device+2,0h           
           mov   word ptr device+4,0
           mov   word ptr device+6,0h           
           mov   word ptr device+8,0
           mov   word ptr device+10,0h           

           MOV   device+11,28H
           MOV   device+7,28H
           MOV   device+3,28H
           MOV   LINE,0 
           RET          
           
INIT       ENDP           

;---------------΅ΰ ΅®βª  ­ ¦ β¨© ª­®―®ª--------------------------------------------           
SButtons_Scan     PROC        NEAR
           MOV   AL,BH
           MOV   AH,10H
           MUL   AH
           MOV   DX,AX       ;DX-’ ‚‚„€ „‹ ‘’‚…’‘’‚“™…ƒ €€‹€           
           IN    AL,DX       ;AL - ‘‘’… ’€ ‚‚„€
           
           CMP   AL,0
           JE    BEND
           CMP   AL,16
           JE    BEND
           CMP   AL,8
           JE    BNEXT3

           MOV   BL,AL
           MOV   AL,BH       ;‚ ‚ - … €€‹€
           MOV   AH,4
           MUL   AH          ;‹“—€… €‰’ ‘ δ‹€ƒ€ €€‹€       
           ADD   AX,3
           MOV   SI,AX
           MOV   AL,DEVICE[SI]
           AND   DEVICE[SI],7    ;“‹… ’› ”‹€ƒ€ €€‹€, ’‚…—€™… ‡€ …† ‡……

           MOV   AL,BL
           MOV   AH,BL

           AND   AL,1
           CMP   AL,1
           JNE   BNEXT1
           ADD   DEVICE[SI],28H    ;‘‘ - ”’-”’, ‡€‘›‚€… ‚ ”‹€ƒ €€‹€ 1010    
           
BNEXT1:    MOV   AL,AH
           AND   AL,2
           CMP   AL,2
           JNE   BNEXT2
           ADD   DEVICE[SI],30H    ;‘‘ - ”’-‘€„, ‡€‘›‚€… ‚ ”‹€ƒ €€‹€ 1001    
           
BNEXT2:    MOV   AL,AH
           AND   AL,4
           CMP   AL,4
           JNE   BNEXT4
           ADD   DEVICE[SI],48H    ;‘‘ - ‘€„-”’, ‡€‘›‚€… ‚ ”‹€ƒ €€‹€ 0110
           JMP   BNEXT4
           
BNEXT3:
           MOV   AL,BH       ;‚ ‚ - … €€‹€
           MOV   AH,4
           MUL   AH          ;‹“—€… €‰’ ‘ δ‹€ƒ€ €€‹€       
           ADD   AX,3
           MOV   SI,AX
           XOR   DEVICE[SI],2    ;‘‘ - ‘ €‹…… 
           

BNEXT4:    MOV   AL,BH
           MOV   AH,10H
           MUL   AH
           MOV   DX,AX       ;DX-’ ‚‚„€ „‹ ‘’‚…’‘’‚“™…ƒ €€‹€           
           IN    AL,DX
           CMP   AL,0
           JNE   BNEXT4
                          
BEND:      RET                                                       
SButtons_Scan     ENDP    

;---------‚›‚„ € „€’›---------------------------------------------------------------------------                       
DISPLAY_    PROC  NEAR
           MOV   BL,0        ;€‰’ „‹ ‚›‚„€
           MOV   AL,BH       ;‚ ‚ - … €€‹€
           MOV   AH,4
           MUL   AH          ;‹“—€… €‰’ ‘ δ‹€ƒ€ €€‹€ 
       
           ADD   AX,3
           MOV   SI,AX
           MOV   AL,DEVICE[SI]
           MOV   AH,AL       ;AH - €‰’ ‘ ”‹€ƒ€ €€‹€
           AND   AL,78H

           CMP   AL,28H
           JNE   DNEXT1       ;‘‘ - … ”’-”’
           ADD   BL,1        ;‘‘ - ”’-”’, ‡€‘›‚€… ‚ €‰’ ‚›‚„€ 1

DNEXT1:    CMP   AL,30H
           JNE   DNEXT2       ;‘‘ - … ”’-‘€„
           ADD   BL,2        ;‘‘ - ”’-‘€„, ‡€‘›‚€… ‚ €‰’ ‚›‚„€ 2   

DNEXT2:    CMP   AL,48H
           JNE   DNEXT3       ;‘‘ - … ‘€„-”’
           ADD   BL,4        ;‘‘ - ‘€„-”’, ‡€‘›‚€… ‚ €‰’ ‚›‚„€ 2   

DNEXT3:    AND   AH,2
           CMP   AH,2
           JNE   DNEXT4
           ADD   BL,8

DNEXT4:
           MOV   AL,BH
           MOV   AH,10H
           MUL   AH
           MOV   DX,AX       ;DX-’ ‚›‚„€ „‹ ‘’‚…’‘’‚“™…ƒ €€‹€
           MOV   AL,BL
           OUT   DX,AL
           
           MOV   DX,1111H
           MOV   AL,LINE
           OUT   DX,AL  
           
           ;------------------------------------------------- 
           
           MOV   AL,DEVICE[DI+2]
           MOV   AH,DEVICE[DI+1]
           
           MOV   DH,0
           MOV   DL,DEVICE[DI]
           MOV   CX,3E8H         ;„…‹ €  1000
           DIV   CX
           
           MOV   TEMP+3,DX       ;‹“—‹ ‹—…‘’‚ ‹‹‘…“„
           
           XOR   CX,CX
           MOV   CL,3CH          ;„…‹ €  60
           DIV   CL
          
           MOV   CH,AH
           MOV   AH,0
           MOV   TEMP+4,AX     ;‘•€‹ ‹-‚ “’
           
           MOV   AL,CH
           MOV   AH,0
           MOV   TEMP+1,AX   ;‘•€‹ ‹-‚ ‘…“„
           
           ;‚›‚„ € „€’›-----------------------------------------------------
           ;‹‹‘…“„›
           MOV   AX,TEMP+3
           MOV   CH,64H
           DIV   CH          ;‹“—‹ ‚ AL - ‘’€‰ €‡„ ‹‹‘…“„
           MOV   TEMP2,AX
           
           MOV   AH,0
           MOV   SI,AX
           MOV   AL,IMAGE[SI]

           MOV   BL,AL
           MOV   AL,BH
           MOV   AH,10H
           MUL   AH
           ADD   AX,5H
           MOV   DX,AX
           XOR   AX,AX
           MOV   AL,BL
           
           OUT   DX,AL
           
           MOV   AX,TEMP2
           MOV   AL,AH
           MOV   AH,0
           MOV   CH,10
           DIV   CH          ;‚ AL-2 €‡„ ‹‹‘…“„, ‚ AH -‹€„‰ €‡„
           MOV   TEMP2,AX
           
           MOV   AH,0
           MOV   SI,AX
           MOV   AL,IMAGE[SI]

           MOV   BL,AL
           MOV   AL,BH
           MOV   AH,10H
           MUL   AH
           ADD   AX,6H
           MOV   DX,AX
           XOR   AX,AX
           MOV   AL,BL
           
           OUT   DX,AL 
           
           MOV   AX,TEMP2
           MOV   AL,AH
           
           MOV   AH,0
           MOV   SI,AX
           MOV   AL,IMAGE[SI]

           MOV   BL,AL
           MOV   AL,BH
           MOV   AH,10H
           MUL   AH
           ADD   AX,7H
           MOV   DX,AX
           XOR   AX,AX
           MOV   AL,BL

           OUT   DX,AL 
           
           ;‘…“„›     
           
           MOV   AX,TEMP+1
           MOV   CH,10
           DIV   CH          ;‚ AL-2 €‡„ ‹‹‘…“„, ‚ AH -‹€„‰ €‡„
           MOV   TEMP2,AX
           
           MOV   AH,0
           MOV   SI,AX
           MOV   AL,IMAGE[SI]

           MOV   BL,AL
           MOV   AL,BH
           MOV   AH,10H
           MUL   AH
           ADD   AX,3H
           MOV   DX,AX
           XOR   AX,AX
           MOV   AL,BL

           OUT   DX,AL 
           
           MOV   AX,TEMP2
           MOV   AL,AH
           
           MOV   AH,0
           MOV   SI,AX
           MOV   AL,IMAGE[SI]
           
           MOV   BL,AL
           MOV   AL,BH
           MOV   AH,10H
           MUL   AH
           ADD   AX,4H
           MOV   DX,AX
           XOR   AX,AX
           MOV   AL,BL

           OUT   DX,AL                  
                     
           ;“’›     
           
           MOV   AX,TEMP+4
           MOV   CH,10
           DIV   CH          ;‚ AL-2 €‡„ “’, ‚ AH -‹€„‰ €‡„
           MOV   TEMP2,AX
           
           MOV   AH,0
           MOV   SI,AX
           MOV   AL,IMAGE[SI]
           
           MOV   BL,AL
           MOV   AL,BH
           MOV   AH,10H
           MUL   AH
           ADD   AX,1H
           MOV   DX,AX
           XOR   AX,AX
           MOV   AL,BL

           OUT   DX,AL 
           
           MOV   AX,TEMP2
           MOV   AL,AH
           
           MOV   AH,0
           MOV   SI,AX
           MOV   AL,IMAGE[SI]
           
           MOV   BL,AL
           MOV   AL,BH
           MOV   AH,10H
           MUL   AH
           ADD   AX,2H
           MOV   DX,AX
           XOR   AX,AX
           MOV   AL,BL
           
           OUT   DX,AL                  
           
           
                                               
           RET
DISPLAY_    ENDP           
;------------------------------------------------------------------------------------           
STARTBUTTON      PROC        NEAR
   
           MOV   AL,BH
           MOV   AH,10H
           MUL   AH
           MOV   DX,AX       ;DX-’ ‚‚„€ „‹ ‘’‚…’‘’‚“™…ƒ €€‹€           
           IN    AL,DX       ;AL - ‘‘’… ’€ ‚‚„€
           MOV   CH,AL
           

           MOV   AL,BH       ;‘‡„€… €‘“ ’…“™…ƒ ‘‘’ „€ƒ €€‹€       
           MOV   AH,2
           MUL   AH
           MOV   AH,3
           MOV   CL,AL
           SHL   AH,CL       
           MOV   DL,AH       ;DL - €‘€ ‘‘’
           
           
           MOV   AL,LINE     ;‚›„…‹… ’…“™…… ‘‘’… €€‹€
           AND   AL,DL
           MOV   DH,AL       ;‘•€‹ …ƒ ‚ DH 
           
           
           MOV   AL,CH
           AND   AL,16
           CMP   AL,16
           JNE   SNEXT2
           
        
           

           CMP   DH,0        ;‘‘’…=00?
           JNE   SNEXT1
           
            
           MOV   AL,BH
           MOV   AH,2
           MUL   AH
           MOV   AH,1
           MOV   CL,AL
                    
           SHL   AH,CL       ;AH-01 - ‚… ‘‘’… „‹ „€ƒ €€‹€
           MOV   AL,DL
           NOT   AL
           AND   LINE,AL     ;“‹… ‘‘’… €€‹€
           ADD   LINE,AH     ;‡€‘›‚€… ‚… - 01
           JMP   SEND
           
SNEXT1:    MOV   AL,BH
           MOV   AH,2
           MUL   AH
           MOV   AH,1
           MOV   CL,AL           
           SHL   AH,CL
           
           CMP   DH,AH       ;‘‘’…=01?
           JNE   SEND
     
           MOV   AL,DL
           NOT   AL
           AND   LINE,AL     ;“‹… ‘‘’… €€‹€
           ADD   LINE,DL     ;‡€‘›‚€… ‚… - 11  
           JMP   SEND

SNEXT2:               
           CMP   DH,DL       ;‘‘’…=11?
           JNE   SNEXT3

           MOV   AL,BH
           MOV   AH,2
           MUL   AH
           MOV   AH,2
           MOV   CL,AL           
           SHL   AH,CL       ;AH-10 - ‚… ‘‘’… „‹ „€ƒ €€‹€
           
           MOV   AL,DL
           NOT   AL
           AND   LINE,AL     ;“‹… ‘‘’… €€‹€
           ADD   LINE,AH     ;‡€‘›‚€… ‚… - 10
        
           JMP   SEND
           
SNEXT3:    MOV   AL,BH
           MOV   AH,2
           MUL   AH
           MOV   AH,2
           MOV   CL,AL           
           SHL   AH,CL
           
           CMP   DH,AH       ;‘‘’…=10?
           JNE   SEND
          
           MOV   AL,DL
           NOT   AL          ;“‹… ‘‘’… €€‹€
           AND   LINE,AL     ;‡€‘›‚€… ‚… - 00    
           
           
SEND:      RET
STARTBUTTON      ENDP
;------------------------------------------------------------------------------------           
DOTIME     PROC  NEAR
           MOV   AL,BH       ;‚ ‚ - … €€‹€
           MOV   AH,4
           MUL   AH          ;‹“—€… €‰’ ‘ δ‹€ƒ€ €€‹€       
           ADD   AX,3
           MOV   SI,AX

           MOV   AL,DEVICE[SI]
           MOV   CH,AL

           AND   AL,4
           CMP   AL,4        ;’€ ‘—…’€=1?
           JE   DONEXT1
           
           
   
           
         
           MOV   AL,CH
           AND   AL,60H      
           MOV   BL,AL       ;BL-‚›„…‹…›‰ ’…“™‰ …† ‡……, ’€=0
           MOV   CL,5
           SHR   BL,CL

           MOV   AL,BH       ;‘‡„€… €‘“ ’…“™…ƒ ‘‘’ „€ƒ €€‹€       
           MOV   AH,2
           MUL   AH
           MOV   AH,3
           MOV   CL,AL
           SHL   AH,CL       
           MOV   DL,AH       ;DL - €‘€ ‘‘’


     
           MOV   AL,LINE
           AND   AL,DL
           MOV   DL,AL       ;DL-‚›„…‹…… ’…“™…… ‘‘’… €€‹€
           
           MOV   AL,BH
           MOV   AH,2
           MUL   AH
           MOV   CL,AL
    
           SHR   DL,CL       ;DL - ‘„‚“‹ „ €—€‹€      

           CMP   DL,BL       ;’…“™…… ‘‘’… ‘‚€„€…’ ‘ 0 ’€ …’„€ ‡……?
           JNE   DOEND
           
           ADD   DEVICE[SI],5

                     ;=============================
           MOV   AL,BH       ;‚ ‚ - … €€‹€
           MOV   AH,4
           MUL   AH          ;‹“—€… €‰’ ‘ δ‹€ƒ€ €€‹€       
           ADD   AX,3
           MOV   SI,AX
           
           MOV   AL,BH       ;‚ ‚ - … €€‹€
           MOV   AH,4
           MUL   AH          ;‹“—€… ‘…™…… „‹ €‡…™… ‚……       
           MOV   DI,AX           
          
        
           MOV   AL,DEVICE[SI]
           AND   AL,2
           CMP   AL,2        ;…† €‹… ‚‹—…?
           
           
           JE   GSUM
           MOV   DEVICE[DI],0
           MOV   DEVICE[DI+1],0           
           MOV   DEVICE[DI+2],0      
GSUM:                
           ;================================ 
           
           JMP   DOEND

DONEXT1:   MOV   AL,CH
           AND   AL,18H      
           MOV   BL,AL       ;BL-‚›„…‹…›‰ ’…“™‰ …† ‡……, ’€=1
           MOV   CL,3
           SHR   BL,CL
           
           MOV   AL,BH       ;‘‡„€… €‘“ ’…“™…ƒ ‘‘’ „€ƒ €€‹€       
           MOV   AH,2
           MUL   AH
           MOV   AH,3
           MOV   CL,AL
           SHL   AH,CL       
           MOV   DL,AH       ;DL - €‘€ ‘‘’
           
      
           MOV   AL,LINE
           AND   AL,DL
           MOV   DL,AL       ;DL-‚›„…‹…… ’…“™…… ‘‘’… €€‹€

           
           MOV   AL,BH
           MOV   AH,2
           MUL   AH
           MOV   CL,AL
           SHR   DL,CL       ;DL - ‘„‚“‹ „ €—€‹€
           
           CMP   DL,BL       ;’…“™…… ‘‘’… ‘‚€„€…’ ‘ 0 ’€ …’„€ ‡……?

           JNE   DOEND

           AND   DEVICE[SI],7AH
           
            
DOEND:
           MOV   AL,BH       ;‚ ‚ - … €€‹€
           MOV   AH,4
           MUL   AH          ;‹“—€… ‘…™…… „‹ €‡…™… ‚……       
           MOV   DI,AX
           
           MOV   AL,DEVICE[SI]
           MOV   BL,AL
           AND   AL,1
           CMP   AL,1        ;…† ‘—…’€ ‚‹—…?
           
           JNE   DOEND2           
                
           INC   DEVICE[DI+2]
           CMP   DEVICE[DI+2],0FFH
           JNE   DOEND2
           INC   DEVICE[DI+1]
           CMP   DEVICE[DI+1],0FFH
           JNE   DOEND2
           INC   DEVICE[DI]           


DOEND2:    
RET
DOTIME     ENDP


;------------------------------------------------------------------------------------           
DELAY      PROC  NEAR
           MOV   CX,0FFH

           MOV   DX,1
DENEXT1:   
           MOV   AX,BX
           MOV   BX,AX
           LOOP  DENEXT1

           DEC   DX
           CMP   DX,0
           JNE   DENEXT1

           RET
DELAY      ENDP                     

;------------------------------------------------------------------------------------           

Start:     
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           CALL  INIT
;------------------------------------------------------------------------------------      
MYSTART:   ;BH-… €€‹€ ‡……
           MOV   BH,0
           CALL  SButtons_Scan
           CALL  STARTBUTTON
           CALL  DOTIME
           CALL  DISPLAY_


            
           MOV   BH,1
           CALL  SButtons_Scan
           CALL  STARTBUTTON
           CALL  DOTIME           
           CALL  DISPLAY_

           MOV   BH,2
           CALL  SButtons_Scan
           CALL  STARTBUTTON
           CALL  DOTIME           
           CALL  DISPLAY_
           
           CALL  DELAY
           
           JMP   MYSTART

           org   RomSize-16
           assume cs:nothing
           jmp   Far Ptr Start
Code       ends
end

