RomSize    EQU   4096
NMax       EQU   50

Stk        SEGMENT AT 200h
           DW    10 DUP (?)
StkTop     LABEL WORD
Stk        ENDS

Data       SEGMENT AT 0h use16
Ampl       DB    ?
AmpMn      DB    ?
Sdvig      DB    ?
SdvigM     DB    ?
Period     DB    ?
PeriodM    DB    ?
Dlit       DB    ?
DlitM      DB    ?
Rejim      DB    ?
Invert     DB    ?
Flag       DB    ?
Image      DB    260 DUP (?)
Data       ENDS

Code       SEGMENT use16
chisl      dw    0000h,0001h,0002h,0003h,0004h,0005h,0006h,0007h,0008h,0009h,0010h,0011h,0012h,0013h,0014h,0015h,0016h,0017h,0018h,0019h
           dw    0020h,0021h,0022h,0023h,0024h,0025h,0026h,0027h,0028h,0029h,0030h,0031h,0032h,0033h,0034h,0035h,0036h,0037h,0038h,0039h
           dw    0040h,0041h,0042h,0043h,0044h,0045h,0046h,0047h,0048h,0049h,0050h,0051h,0052h,0053h,0054h,0055h,0056h,0057h,0058h,0059h
           dw    0060h,0061h,0062h,0063h,0064h,0065h,0066h,0067h,0068h,0069h,0070h,0071h,0072h,0073h,0074h,0075h,0076h,0077h,0078h,0079h
           dw    0080h,0081h,0082h,0083h,0084h,0085h,0086h,0087h,0088h,0089h,0090h,0091h,0092h,0093h,0094h,0095h,0096h,0097h,0098h,0099h
           dw    0100h,0101h,0102h,0103h,0104h,0105h,0106h,0107h,0108h,0109h,0110h,0111h,0112h,0113h,0114h,0115h,0116h,0117h,0118h,0119h
           dw    0120h,0121h,0122h,0123h,0124h,0125h,0126h,0127h,0128h,0129h,0130h,0131h,0132h,0133h,0134h,0135h,0136h,0137h,0138h,0139h
           dw    0140h,0141h,0142h,0143h,0144h,0145h,0146h,0147h,0148h,0149h,0150h,0151h,0152h,0153h,0154h,0155h,0156h,0157h,0158h,0159h
           dw    0160h,0161h,0162h,0163h,0164h,0165h,0166h,0167h,0168h,0169h,0170h,0171h,0172h,0173h,0174h,0175h,0176h,0177h,0178h,0179h
           dw    0180h,0181h,0182h,0183h,0184h,0185h,0186h,0187h,0188h,0189h,0190h,0191h,0192h,0193h,0194h,0195h,0196h,0197h,0198h,0199h
           dw    0200h,0201h,0202h,0203h,0204h,0205h,0206h,0207h,0208h,0209h,0210h,0211h,0212h,0213h,0214h,0215h,0216h,0217h,0218h,0219h
           dw    0220h,0221h,0222h,0223h,0224h,0225h,0226h,0227h,0228h,0229h,0230h,0231h,0232h,0233h,0234h,0235h,0236h,0237h,0238h,0239h
           dw    0240h,0241h,0242h,0243h,0244h,0245h,0246h,0247h,0248h,0249h,0250h,0251h,0252h,0253h,0254h,0255h,0256h,0257h,0258h,0259h
Digit      db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh    ;Образы 10-тиричных символов
           db    07Fh,05Fh
Zader      DW    6666h
FRONT      DB    0C0h,0E0h,0F0h,0F8h,0FCh,0FEh,0FFh
imp        DB    40h,20h,10h,8h,4h,2h,1h           
           ASSUME cs:Code,ds:Data,es:Data;,ss:Stk
;Процедуры

DELAY      PROC  NEAR
           PUSH  AX
           push  bx
           MOV   BX,ZADER
           MOV   AX,0000h
M2:        INC   AX
           CMP   AX,BX
           JNE   M2
           MOV   AX,0000h
M3:        INC   AX
           CMP   AX,BX
           JNE   M3
           pop   bx
           POP   AX
           RET
DELAY      ENDP

Displ      PROC  NEAR
           lea   bx,Image
                      
           mov   ch,1        ;Indicator Counter
OutNextInd:
           mov   al,0
           out   2,al        ;Turn off cols
           mov   al,ch
           out   0,al        ;Turn on current matrix
           mov   cl,1        ;Col Counter
OutNextCol:
           mov   al,0
           out   2,al        ;Turn off cols
           mov   al,es:[bx]
           out   1,al        ;Set rows
           mov   al,cl
           out   2,al        ;Turn on current col
           
           shl   cl,1
           inc   bx
           jnc   OutNextCol
           shl   ch,1
           cmp   ch,0h
           jnz   OutNextInd
           mov   al,0
           out   0,al
           RET
Displ      ENDP

FormIm     PROC  NEAR
           mov   al,periodm
           cmp   al,04h
           ja    L_N1
           mov   al,04h
           mov   periodm,al
L_N1:      mov   al,dlitm
           cmp   al,03h
           ja    L_N2
           mov   al,03h
           mov   dlitm,al
L_N2:      
           mov   al,periodm
           mov   ah,dlitm
           sub   al,ah
           cmp   al,0h
           ja    L_N3
           mov   ah,periodm
           inc   ah
           mov   periodm,ah
L_N3:     
           lea   bx,Image
           xor   ch,ch
           mov   cl,sdvigM
           cmp   cl,0
           jz    L_3
           mov   al,0AAh
           mov   flag,al
           mov   al,80h
L_2:       mov   es:[bx],al
           inc   bx
           loop  L_2           
           
L_3:       push  bx
           lea   bx,front
           mov   al,ampl
           dec   al
           add   bl,al
           mov   dh,cs:[bx]
           
           lea   bx,imp
           mov   al,ampl
           dec   al
           add   bl,al
           mov   dl,cs:[bx]
           pop   bx
                              
           mov   cx,0FFh
           mov   al,sdvigM
           xor   ah,ah
           sub   cx,ax
           
           mov   ax,cx
           div   periodM
           xor   ah,ah
           inc   ax
           mov   cx,ax
           
           
L_1:       mov   al,flag
           cmp   al,055h
           jne   LV_11
           mov   es:[bx],dl
           mov   al,0AAh
           mov   flag,al
           jmp   LV_21
LV_11:           mov   es:[bx],dh
LV_21:
           push  cx
           inc   bx
           mov   cl,dlitM
           dec   cx
           dec   cx
           
LV_1:      mov   es:[bx],dl
           inc   bx
           loop  LV_1
           mov   es:[bx],dh
           inc   bx
           mov   cl,periodM
           sub   cl,dlitM
LV_2:      mov   es:[bx],80h
           inc   bx
           loop  LV_2           
           
           pop   cx           
           loop  L_1                     
           mov   al,055h
           mov   flag,al
           RET
FormIm     ENDP

FormImin   PROC  NEAR
           mov   al,periodm
           cmp   al,04h
           ja    IL_N1
           mov   al,04h
           mov   periodm,al
IL_N1:      mov   al,dlitm
           cmp   al,03h
           ja    IL_N2
           mov   al,03h
           mov   dlitm,al
IL_N2:      
           mov   al,periodm
           mov   ah,dlitm
           sub   al,ah
           cmp   al,0h
           ja    IL_N3
           mov   ah,periodm
           inc   ah
           mov   periodm,ah
           
IL_N3:     lea   bx,Image
           xor   ch,ch
           mov   cl,sdvigM
           cmp   cl,0
           jz    IL_3
           mov   al,0AAh
           mov   flag,al
           
           lea   bx,imp
           mov   al,ampl
           dec   al
           add   bl,al
           mov   al,cs:[bx]
           mov   dh,al
           
           lea   bx,Image
IL_2:      mov   es:[bx],al
           inc   bx
           loop  IL_2           
           
IL_3:      push  bx
           lea   bx,front
           mov   al,ampl
           dec   al
           add   bl,al
           mov   al,cs:[bx]
           mov   dh,al
           
           lea   bx,imp
           mov   al,ampl
           dec   al
           add   bl,al
           mov   dl,cs:[bx]
           pop   bx
                     
           mov   cx,0FFh
           mov   al,sdvigM
           xor   ah,ah
           sub   cx,ax
           
           mov   ax,cx
           div   periodM
           xor   ah,ah
           inc   ax
           mov   cx,ax
           
IL_1:       
           mov   al,flag
           cmp   al,055h
           jne   ILV_11
           mov   es:[bx],80h
           mov   al,0AAh
           mov   flag,al
           jmp   ILV_21
ILV_11:           mov   es:[bx],dh
ILV_21:

           push  cx
           
           inc   bx
           mov   cl,dlitM
           dec   cx
           dec   cx
           
ILV_1:      mov   es:[bx],80h
           inc   bx
           loop  ILV_1
           mov   es:[bx],dh
           inc   bx
           mov   cl,periodM
           sub   cl,dlitM
ILV_2:      mov   es:[bx],dl
           inc   bx
           loop  ILV_2           
           
           pop   cx           
           loop  IL_1                    
           mov   al,055h
           mov   flag,al
           RET
FormImin   ENDP

UstAmpl    PROC  NEAR
           in    al,0
           cmp   al,0
           je    endM
           
           mov   ah,al
MAR:       in    al,0
           cmp   al,0
           jne   MAR           
           
           mov   al,ah
           
           cmp   al,01h
           jnz   MA_1
           mov   ah,ampl
           cmp   ah,01h
           jz    endM
           dec   ah
           mov   ampl,ah
MA_1:      cmp   al,02h
           jnz   MA_2
           mov   ah,ampl
           cmp   ah,07h
           jz    endM
           inc   ah
           mov   ampl,ah
MA_2:      cmp   al,04h
           jnz   MA_3
           mov   al,0Ah
           mov   ampmn,al
           mov   al,01h
           out   5,al          
MA_3:      cmp   al,08h
           jnz   MA_4
           mov   al,05h
           mov   ampmn,al
           mov   al,02h
           out   5,al          
MA_4:      cmp   al,010h
           jnz   endm
           mov   al,01h
           mov   ampmn,al
           mov   al,04h
           out   5,al         
endM:
           mov   al,ampl
           mul   ampmn
           aam
           lea   bx,Digit
           add   bl,al
           mov   al,cs:[bx]
           out   4,al
           mov   al,ah
           lea   bx,Digit
           add   bl,al
           mov   al,cs:[bx]
           add   al,80h
           out   3,al  
           RET
UstAmpl    ENDP

UstPer     PROC  NEAR
           in    al,1
           cmp   al,01h
           jne   UP_1
           mov   al,period
           mov   ah,dlit
           add   ah,sdvig
           inc   ah
           cmp   al,ah
           je    UP_2
           dec   al
           mov   period,al
           jmp   UP_2
UP_1:      cmp   al,02h
           jne   UP_2
           mov   al,period
           cmp   al,0FFh
           je    UP_2
           inc   al
           mov   period,al
UP_2:      
           mov   al,period
           xor   ah,ah   
           lea   bx,chisl
           add   bx,ax
           add   bx,ax
           
           mov   ax,cs:[bx]
           lea   bx,Digit
           mov   cl,al
           and   al,0Fh
           add   bl,al
           mov   al,cs:[bx]
           out   9,al
           mov   al,cl
           and   al,0F0h
           shr   al,4
           lea   bx,digit
           add   bl,al
           mov   al,cs:[bx]
           out   8,al
           
           mov   al,ah
           and   al,0Fh
           lea   bx,digit
           add   bl,al
           mov   al,cs:[bx]
           add   al,80h
           out   7,al
ENP:           
           RET
UstPer     ENDP

UstDlit    PROC  NEAR
           in    al,3
           cmp   al,01h
           jne   UD_1
           mov   al,dlit
           cmp   al,3h
           je    UD_2
           dec   al
           mov   Dlit,al
           jmp   UD_2
UD_1:      cmp   al,02h
           jne   UD_2
           mov   al,dlit
           mov   ah,period
           dec   ah
           cmp   al,ah
           je    UD_2
           inc   al
           mov   dlit,al
UD_2:      
           mov   al,Dlit
           xor   ah,ah   
           lea   bx,chisl
           add   bx,ax
           add   bx,ax
           mov   ax,cs:[bx]
           lea   bx,Digit
           mov   cl,al
           and   al,0Fh
           add   bl,al
           mov   al,cs:[bx]
           out   13,al
           mov   al,cl
           and   al,0F0h
           shr   al,4
           lea   bx,digit
           add   bl,al
           mov   al,cs:[bx]
           out   12,al
           
           mov   al,ah
           and   al,0Fh
           lea   bx,digit
           add   bl,al
           mov   al,cs:[bx]
           add   al,80h
           out   11,al
           
           RET
UstDlit    ENDP

PMassh     PROC  NEAR
           in    al,5
           cmp   al,0
           jne   PMN
           in    al,6
PMN:                  
           cmp   al,01h
           jnz   PM1
           mov   al,1h
           out   0Eh,al
           mov   ah,sdvig
           shl   ah,1
           mov   sdvigM,ah
           mov   ah,period
           shl   ah,1
           mov   periodM,ah
           mov   ah,dlit
           shl   ah,1
           mov   dlitM,ah
PM1:           
           cmp   al,02h
           jnz   PM2
           mov   al,2h
           out   0Eh,al
           mov   ah,sdvig
           mov   sdvigM,ah
           mov   ah,period
           mov   periodM,ah
           mov   ah,dlit
           mov   dlitM,ah
PM2:       
           cmp   al,04h
           jnz   PM3
           mov   al,4h
           out   0Eh,al
           mov   ah,sdvig
           shr   ah,1
           mov   sdvigM,ah
           mov   ah,period
           shr   ah,1
           mov   periodM,ah
           mov   ah,dlit
           shr   ah,1
           mov   dlitM,ah
PM3:
           cmp   al,08h
           jnz   ENM
           mov   al,8h
           out   0Eh,al
           mov   ah,sdvig
           shr   ah,2
           mov   sdvigM,ah
           mov   ah,period
           shr   ah,2
           mov   periodM,ah
           mov   ah,dlit
           shr   ah,2
           mov   dlitM,ah 
ENM:                
           RET
PMassh     ENDP

UstSdv     PROC  NEAR
           in    al,7
           
           cmp   al,01h
           jne   SD_1
           mov   al,sdvig
           cmp   al,0h
           je    SD_2
           dec   al
           mov   sdvig,al
           jmp   SD_2
SD_1:      cmp   al,02h
           jne   SD_2
           mov   al,sdvig
           mov   ah,period
           sub   ah,dlit
           cmp   al,ah
           je    SD_2
           inc   al
           mov   sdvig,al
SD_2:      
           mov   al,sdvig
           xor   ah,ah   
           lea   bx,chisl
           add   bx,ax
           add   bx,ax
           mov   ax,cs:[bx]
           lea   bx,Digit
           mov   cl,al
           and   al,0Fh
           add   bl,al
           mov   al,cs:[bx]
           out   12h,al
           mov   al,cl
           and   al,0F0h
           shr   al,4
           lea   bx,digit
           add   bl,al
           mov   al,cs:[bx]
           out   11h,al
           
           mov   al,ah
           and   al,0Fh
           lea   bx,digit
           add   bl,al
           mov   al,cs:[bx]
           add   al,80h
           out   10h,al                
           RET
UstSdv     ENDP

Init       PROC  NEAR
           mov   al,04h
           mov   ampl,al
           mov   al,0Ah
           mov   ampmn,al
           mov   al,01h
           out   5,al
           mov   al,0h
           mov   sdvig,al
           mov   sdvigm,al
           mov   al,03h
           mov   dlit,al
           mov   al,04h
           mov   period,al
           mov   al,0AAh
           mov   rejim,al              
           mov   al,2h
           out   0Eh,al
           
           mov   al,055h
           mov   flag,al 
           
           RET
Init       ENDP

Main       PROC  NEAR
           InfLoop:   in    al,5
           cmp   al,10h
           jne   Main1
           mov   al,0AAh
           mov   rejim,al
Main1:     cmp   al,20h
           jne   Main2
           mov   al,055h
           mov   rejim,al
Main2:                 
           mov   al,rejim
           cmp   al,0AAh
           je    Ust
           cmp   al,055h
           je    Gen
           jmp   InfLoop
Ust:       mov   al,1h
           out   0Fh,al    
           Call  UstAmpl
           Call  UstPer
           Call  UstDlit
           Call  UstSdv
           Call  PMassh
           Call  Delay
           
           in    al,2
           cmp   al,1
           jne   Invers
           mov   al,1h
           mov   invert,al
           jmp   InfLoop
invers:    mov   al,0h
           mov   invert,al
           jmp   InfLoop
Gen:       mov   al,2h
           out   0Fh,al
           mov   al,invert
           cmp   al,0
           je    inv1
           Call  FormImIn
           jmp   inv2
inv1:      Call  FormIm           
inv2:      Call  Displ
           jmp   InfLoop
           RET
Main       ENDP

Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop        

           Call  Init          
           Call  Main           
           

           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END