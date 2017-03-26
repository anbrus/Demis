.386
RomSize    EQU   8000h


Fraza      STRUC 
           Nom               DB    ?                                   
           Prior             DB    ?                                   
           Bukvi             DW    32    dup    (16  dup (?))           
           InG               DB    ?
           InK               DB    ?
           InP               DB    ?
           InIn              DB    ?
Fraza      ENDS

BaseD      SEGMENT AT 40 use16
           Akumulator        Fraza    4      dup (<>)                   
           MassPPZU          Fraza    2      dup (4 dup (<>))     
           FrazaNaVivod      Fraza    <>                               
           FullFraza         DW       512    dup    (?)
           ObrSkreen         DW       128    dup    (?)   
           Letter            DW       16     dup    (?)
                      
           Regim             db    ?
           Registr           db    ?
           Stop              db    ?
           Type_letter       db    ?
           Nom_mess          db    ?
           Prior_mess        db    ?
           Text_mess         db    ?
           BSpace            db    ?
           Kurs              db    ?           
           KbdImage          db    8 DUP(?)
           EmpKbd            db    ?
           KbdErr            db    ?
           NextDig           db    ?
           Offset_let        dw    ?
           Frazaend          db    ?
           NomSoob           dw    ?
           i                 db    ?
           j                 db    ?
           k                 db    ?
           m                 db    ?
           
           Ukazat            dw    ?
BaseD      ENDS

Stk        SEGMENT AT 3000h use16
           dw    100 dup (?)
StkTop     Label Word
Stk        ENDS


Data       SEGMENT  use16
;--------------------------------------------------------------------------------------------------------------------------
LetterImage:  
           dw    0000h,0000h,0000h,0000h,0000h,0000h,0001h,0001h,1FFFh,0000h,0000h,0000h,0000h,0000h,0000h,0000h ;1
           dw    0000h,0000h,0000h,0000h,100Ch,1802h,1401h,1201h,1101h,1081h,1042h,103Ch,0000h,0000h,0000h,0000h ;2           
           dw    0000h,0000h,0000h,0000h,0604h,0802h,1001h,1001h,1021h,1021h,1022h,085Ch,0780h,0000h,0000h,0000h ;3
           dw    0000h,0000h,0000h,0200h,0300h,02C0h,0220h,0218h,0204h,1FFFh,0200h,0200h,0000h,0000h,0000h,0000h ;4
           dw    0000h,0000h,0000h,0000h,0400h,0838h,1017h,1011h,1011h,1011h,0821h,07C1h,0000h,0000h,0000h,0000h ;5
           dw    0000h,0000h,0000h,0000h,0780h,08E0h,1050h,104Ch,1042h,1041h,0880h,0700h,0000h,0000h,0000h,0000h ;6
           dw    0000h,0000h,0000h,0000h,0000h,1001h,0C01h,0301h,0081h,0061h,0019h,0007h,0001h,0000h,0000h,0000h ;7                                                       
           dw    0000h,0000h,0000h,0000h,0780h,084Ch,1032h,1021h,1021h,1021h,1032h,084Ch,0780h,0000h,0000h,0000h ;8
           dw    0000h,0000h,0000h,0000h,001Ch,0022h,1041h,0841h,0641h,0141h,00C2h,003Ch,0000h,0000h,0000h,0000h ;9
           dw    0000h,0000h,0000h,03F8h,0404h,0802h,1001h,1001h,1001h,0802h,0404h,0388h,0000h,0000h,0000h,0000h ;0
           dw    0000h,0000h,0000h,03C0h,0420h,0810h,1008h,1008h,1008h,1008h,0810h,0420h,1FF8h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,03F8h,0424h,0812h,1009h,1009h,1009h,1009h,0811h,0421h,03C0h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0000h,1FF8h,1088h,1088h,1088h,11C0h,0E00h,0000h,0000h,0000h,0000h,0000h ;                                                            
           dw    0000h,0000h,0000h,0000h,0000h,0000h,1FF8h,0008h,0008h,0008h,0008h,0008h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,7000h,1000h,1C00h,1380h,1070h,1008h,1070h,1380h,1C00h,1000h,7000h,0000h,0000h ;           
           dw    0000h,0000h,0000h,03C0h,04A0h,0890h,1088h,1088h,1088h,1088h,1090h,08A0h,04C0h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,03C0h,04A0h,0890h,108Bh,108Bh,1088h,108bh,1093h,08A0h,04C0h,0000h,0000h,0000h ;           
           dw    0000h,1008h,0810h,0420h,0240h,0180h,0100h,1FF8h,0100h,0180h,0240h,0420h,0810h,1008h,0000h,0000h ;                                                                             
           dw    0000h,0000h,0000h,0000h,0000h,0810h,1008h,1008h,1088h,1088h,1088h,0F70h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,1FF8h,0800h,0400h,0200h,0180h,0040h,0020h,0210h,1FF8h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,1FF8h,0800h,0401h,0202h,0182h,0042h,0022h,0011h,1FF8h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,1FF8h,0100h,0180h,0240h,0420h,0810h,0808h,1000h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,1800h,0600h,0180h,0060h,0018h,0018h,0060h,0180h,0600h,1800h,0000h,0000h,0000h ;                                            
           dw    0000h,1800h,0780h,0770h,0018h,0060h,0380h,1C00h,1C00h,0380h,0070h,0008h,00F0h,0780h,1800h,0000h ;
           dw    0000h,0000h,0000h,1FF8h,0080h,0080h,0080h,0080h,0080h,0080h,0080h,1FFFh,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,03C0h,0420h,0810h,1008h,1008h,1008h,1008h,0810h,0420h,03C0h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,1FF8h,0008h,0008h,0008h,0008h,0008h,0008h,0008h,1FF8h,0000h,0000h,0000h,0000h ;           
           dw    0000h,0000h,0000h,7FF8h,0420h,0810h,1008h,1008h,1008h,1008h,0810h,0420h,03C0h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,03C0h,0420h,0810h,1008h,1008h,1008h,1008h,1008h,0810h,0420h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0000h,0000h,0008h,0008h,1FF8h,0008h,0008h,0000h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0030h,00C0h,0300h,3C00h,0C00h,0300h,00C0h,0030h,0008h,0000h,0000h,0000h ;
           dw    0000h,0000h,03C0h,0420h,0810h,1008h,0810h,0420h,7FFFh,0420h,0810h,1008h,0810h,0420h,03C0h,0000h ;
           dw    0000h,0000h,0000h,1008h,0810h,0420h,0240h,0180h,0240h,0420h,0810h,1008h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,1FF8h,1000h,1000h,1000h,1000h,1000h,1000h,1FF8h,1000h,1000h,7000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0000h,0078h,0080h,0080h,0080h,0080h,1FF8h,0000h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0FF8h,1000h,1000h,1000h,1000h,1000h,1FF8h,1000h,1000h,1000h,1000h,1000h,1FF8h,0000h ;
           dw    0000h,0000h,1FF8h,1000h,1000h,1000h,1000h,1FF8h,1000h,1000h,1000h,1000h,1FF8h,1000h,7000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0008h,0008h,1FF8h,1080h,1080h,1080h,1080h,0F00h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,1FF8h,1080h,1080h,1080h,1080h,1080h,0F00h,0000h,0000h,1FFFh,0000h,0000h,0000h ;                                                                  
           dw    0000h,0000h,0000h,0000h,0000h,1FF8h,1080h,1080h,1080h,1080h,0F00h,0000h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0420h,0810h,1008h,1008h,1088h,1088h,1088h,0890h,04A0h,03C0h,0000h,0000h,0000h ;
           dw    0000h,0000h,1FF8h,0080h,03C0h,0420h,0810h,1008h,1008h,1080h,0810h,0420h,03C0h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0000h,1070h,0C88h,0688h,0188h,1088h,1FF8h,0000h,0000h,0000h,0000h,0000h ;ÿ 
           dw    0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h ;...
           dw    0000h,0000h,0000h,0000h,0040h,0040h,0040h,07FCh,0040h,0040h,0040h,0040h,0000h,0000h,0000h,0000h ;(+) 
           dw    0000h,0000h,0000h,4000h,4000h,0000h,4000h,4000h,4000h,4000h,4000h,4000h,4000h,0000h,0000h,0000h ;(_)
           dw    0000h,0000h,4000h,2000h,1800h,0008h,0600h,0100h,00C0h,0030h,0006h,0001h,0000h,0000h,0000h,0000h ;(\)                                
;**********************************************************************************************************************
           dw    0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,1BFFh,0000h,0000h,0000h,0000h,0000h,0000h,0000h ;(!)
           dw    0000h,001Eh,2021h,1021h,0821h,0622h,011Eh,00C2h,0F22h,1092h,108Eh,1083h,1081h,0F00h,0000h,0000h ;(%)
           dw    0000h,0000h,0000h,0000h,0000h,0000h,0000h,1800h,1800h,0000h,0000h,0000h,0000h,0000h,0000h,0000h ;(.)
           dw    0000h,0000h,0000h,0000h,0000h,0000h,0000h,4000h,3818h,0818h,0000h,0000h,0000h,0000h,0000h,0000h ;(;)
           dw    0000h,0000h,0000h,0000h,0000h,0000h,0000h,4000h,3800h,0800h,0000h,0000h,0000h,0000h,0000h,0000h ;(,)
           dw    0000h,0000h,0000h,0000h,0000h,0000h,0000h,1818h,1818h,0000h,0000h,0000h,0000h,0000h,0000h,0000h ;(:)
           dw    0000h,0000h,0000h,0000h,000Ch,01C2h,0241h,1A21h,1A21h,0211h,0211h,018Eh,0000h,0000h,0000h,0000h ;(?)                                            
           dw    0000h,0000h,0000h,0000h,0000h,0012h,000Ch,003Fh,000Ch,0021h,0000h,0000h,0000h,0000h,0000h,0000h ;(*)
           dw    0000h,0000h,0000h,0000h,0000h,0000h,0000h,1FF0h,600Eh,0001h,0000h,0000h,0000h,0000h,0000h,0000h ;(()          
           dw    0000h,0000h,0000h,0000h,0000h,0000h,0000h,0003h,7FFCh,0000h,0000h,0000h,0000h,0000h,0000h,0000h ;())           
           dw    0000h,1000h,0C00h,0300h,00E0h,0098h,0086h,0081h,0086h,0098h,00E0h,0300h,0C00h,1000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0000h,1FFFh,1041h,1041h,1041h,1041h,0881h,0700h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0000h,1FFFh,1021h,1021h,1021h,1032h,084Ch,0780h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0000h,0000h,1FFFh,0001h,0001h,0001h,0001h,0001h,0000h,0000h,0000h,0000h ;
           dw    0000h,7000h,1000h,1E00h,1180h,1070h,100Eh,1001h,100Eh,1070h,1180h,1E00h,1000h,7000h,0000h,0000h ;                                                       
           dw    0000h,0000h,0000h,0000h,0000h,1FFFh,1021h,1021h,1021h,1021h,1021h,1021h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0000h,1FFFh,1021h,1021h,1021h,1021h,1021h,1021h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,1001h,0802h,0604h,0108h,0090h,0060h,1FFFh,0060h,0090h,0108h,0604h,0802h,1001h,0000h ;
           dw    0000h,0000h,0000h,0000h,0400h,0802h,1001h,1041h,1041h,1062h,089Ch,0700h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,1FFFh,0400h,0200h,0180h,0040h,0030h,0008h,0004h,1FFFh,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,1FFFh,0400h,0201h,0181h,0041h,0031h,0009h,0004h,0FFFh,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0000h,1FFFh,0060h,0090h,0108h,0204h,0402h,0801h,1000h,0000h,0000h,0000h ;
           dw    0000h,1000h,0C00h,0300h,00E0h,0018h,0006h,0001h,0006h,0018h,00E0h,0300h,0C00h,1000h,0000h,0000h ;                                                                  
           dw    0000h,0000h,1FFCh,0003h,000Ch,0070h,0180h,0E00h,1000h,0E00h,0180h,0070h,000Ch,0003h,1FFCh,0000h ;
           dw    0000h,0000h,0000h,0000h,1FFFh,0040h,0040h,0040h,0040h,0040h,0040h,0040h,1FFFh,0000h,0000h,0000h ;
           dw    0000h,0000h,01F0h,0208h,0404h,0802h,1001h,1001h,1001h,1001h,1001h,0802h,0404h,0209h,01F0h,0000h ;
           dw    0000h,0000h,0000h,0000h,1FFFh,0001h,0001h,0001h,0001h,0001h,0001h,1FFFh,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0000h,1FFFh,0041h,0041h,0041h,0041h,0041h,0022h,001Ch,0000h,0000h,0000h ;           
           dw    0000h,0000h,01F0h,0208h,0404h,0802h,1001h,1001h,1001h,1001h,1001h,1001h,0802h,0802h,0404h,0000h ;
           dw    0000h,0000h,0000h,0000h,0000h,0001h,0001h,0001h,1FFFh,0001h,0001h,0001h,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0803h,100Ch,1030h,10C0h,0F00h,0300h,00C0h,0030h,000Ch,0003h,0000h,0000h ;                                 
           dw    0000h,0070h,0088h,0104h,0104h,0104h,0104h,1FFFh,0104h,0104h,0104h,0104h,0104h,0088h,0070h,0000h ;                                            
           dw    0000h,0000h,0000h,1001h,0C06h,0208h,0110h,00A0h,00E0h,0110h,0208h,0C06h,1001h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,1FFFh,1000h,1000h,1000h,1000h,1000h,1000h,1000h,1FFFh,1000h,7000h,0000h,0000h ;           
           dw    0000h,0000h,0000h,0000h,001Fh,0020h,0040h,0040h,0040h,0040h,0040h,1FFFh,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,1FFFh,1000h,1000h,1000h,1000h,1000h,1FFFh,1000h,1000h,1000h,1000h,1000h,1FFFh,0000h ;
           dw    0000h,1FFFh,1000h,1000h,1000h,1000h,1FFFh,1000h,1000h,1000h,1000h,1FFFh,1000h,1000h,7000h,0000h ;
           dw    0000h,0000h,0001h,0001h,0001h,1FFFh,1040h,1040h,1040h,1040h,1040h,0880h,0700h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,1FFFh,1040h,1040h,1040h,1040h,1040h,0880h,0700h,0000h,1FFFh,0000h,0000h,0000h ;                                                       
           dw    0000h,0000h,0000h,0000h,0000h,1FFFh,1040h,1040h,1040h,1040h,1040h,0880h,0700h,0000h,0000h,0000h ;
           dw    0000h,0000h,0404h,0802h,0802h,1001h,1001h,1041h,1041h,1041h,1041h,0842h,0444h,0248h,01F0h,0000h ;
           dw    0000h,1FFFh,0040h,0040h,01F0h,0208h,0404h,0802h,1001h,1001h,1001h,0802h,0404h,0208h,01F0h,0000h ;
           dw    0000h,0000h,0000h,0000h,101Ch,0822h,0441h,0341h,00C1h,0041h,0041h,1FFFh,0000h,0000h,0000h,0000h ;
           dw    0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h,0000h ;...
           dw    0000h,0000h,0000h,0110h,0110h,0110h,0110h,0110h,0110h,0110h,0110h,0110h,0110h,0000h,0000h,0000h ;(=)
           dw    0000h,0000h,0000h,0000h,0100h,0100h,0100h,0100h,0100h,0100h,0100h,0100h,0000h,0000h,0000h,0000h ;(-)            
           dw    0000h,0000h,4000h,2000h,1800h,0008h,0600h,0100h,00C0h,0030h,0006h,0001h,0000h,0000h,0000h,0000h ;(\)
Data       ENDS
;--------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------
Code       SEGMENT use16
           ASSUME cs:Code,ds:BaseD,es:Data

Start:           
           mov   ax,BaseD
           mov   ds,ax
           mov   ax,Data
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           
           call  Initialize      
Begin:     call  KbdInput        
           call  KbdInContr       
           call  KodKlav         
           call  SIndik          
           call  PodgotWork     
           call  ExecReg 
           call  Pre_OutSkr      
           call  OutScreen
  
           jmp   Begin


           
;--------------------------------------------------------------------------------------------------------------------------
Initialize PROC  NEAR
           mov   Regim,02h           
           mov   Registr,00h     
           mov   Stop,0ffh          
           mov   Type_letter,00h 
           mov   Nom_mess,0ffh      
           mov   Prior_mess,00h    
           mov   Text_mess,00h       
           mov   BSpace,00h
           mov   Kurs,0
           
           mov   Frazaend,0FFh   
           mov   NomSoob,00h    
           mov   Ukazat,0
           
           mov   Offset_let,00h
           mov   NextDig,00h
           
           call  ClenObr
           RET
Initialize ENDP
;--------------------------------------------------------------------------------------------------------------------------
ClenObr    PROC
           mov   cx,LENGTH ObrSkreen
           mov   si,0
CO1:       mov   ObrSkreen[si],0
           inc   si
           inc   si
           loop  CO1 
                     
           mov   si,0
           mov   cx,LENGTH FullFraza
CO2:       mov   FullFraza[si],0
           inc   si
           inc   si
           loop  CO2
           ret
ClenObr    ENDP
;--------------------------------------------------------------------------------------------------------------------------
VibrDestr  PROC  NEAR            
V1:        mov   ah,al       
           mov   bh,0        
V2:        in    al,0000h        
           cmp   ah,al       
           jne   V1         
           inc   bh          
           cmp   bh,50       
           jne   V2         
           ret
VibrDestr  ENDP
;--------------------------------------------------------------------------------------------------------------------------
KbdInput   PROC  NEAR
           lea   si,KbdImage         
           mov   cx,LENGTH KbdImage  
           mov   bl,0FEh             
KI1:       mov   al,bl               
           out   0005h,al            
           in    al,0000h            
           cmp   al,0FFh
           jz    KI2                 
           call  VibrDestr           
KI2:       mov   [si],al             
           inc   si                  
           rol   bl,1                
           loop  KI1                 
           ret
KbdInput   ENDP
;--------------------------------------------------------------------------------------------------------------------------
KbdInContr PROC  NEAR
           lea   bx,KbdImage         
           mov   cx,LENGTH KbdImage  
           mov   EmpKbd,0            
           mov   KbdErr,0
           mov   dl,0                
KIC2:      mov   al,[bx]             
           mov   ah,8                
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
;--------------------------------------------------------------------------------------------------------------------------
KodKlav    PROC  NEAR
           cmp   EmpKbd,0FFh     
           jz    NDT1           
           cmp   KbdErr,0FFh     
           jz    NDT1
           
           lea   bx,KbdImage     
           xor   dx,dx           
NDT3:      mov   al,[bx]         
           cmp   al,0FFh         
           jnz   NDT2            
           inc   dh              
           inc   bx              
           jmp   SHORT NDT3
NDT2:      shr   al,1            
           jnc   NDT4            
           inc   dl              
           jmp   SHORT NDT2
NDT4:      mov   cl,3            
           shl   dh,cl
           or    dh,dl
           mov   NextDig,dh
           jmp   NDT1
;NDT5:      mov   NextDig,00h
NDT1:      ret
KodKlav    ENDP
;--------------------------------------------------------------------------------------------------------------------------
PodgotWork PROC
           cmp   EmpKbd,0FFh     
           jz    EndPW             
           cmp   KbdErr,0FFh      
           jz    EndPW             
           
           cmp   NextDig,30h
           jns   EndPW
           mov   ax,Word PTR NextDig
                   
           cmp   Registr,0FFh
           jnz   NotShift
           add   ax,47
NotShift:  mov   ah,32          
Shift:     mul   ah
           mov   Offset_let,ax
           
           ;jmp   EndPW         
                  
           cmp   NextDig,32h
           jnz   PW1
           mov   Regim,01h         
           mov   Stop,00h
           jmp   PW3
           
PW1:       cmp   NextDig,31h
           jnz   PW2
           mov   Regim,02h         
           mov   Stop,0FFh
           jmp   PW3
                      
PW2:       cmp   NextDig,30h
           jnz   PW3
           mov   Regim,04h         
           mov   Stop,00h
           mov   Nomsoob,0

PW3:       cmp   NextDig,36h
           jnz   PW4
           cmp   Type_letter,08h
           jnz   InGirny
           mov   Type_letter,00h
           jmp   PW7
InGirny:   mov   Type_letter,08h   
           jmp   PW7

PW4:       cmp   NextDig,35h
           jnz   PW5
           cmp   Type_letter,04h
           jnz   InKursiv
           mov   Type_letter,00h
           jmp   PW7
InKursiv:  mov   Type_letter,04h   
           
PW5:       cmp   NextDig,34h
           jnz   PW6
           cmp   Type_letter,02h
           jnz   InPodch
           mov   Type_letter,00h
           jmp   PW7
InPodch:   mov   Type_letter,02h   
           jmp   PW7

PW6:       cmp   NextDig,33h 
           jnz   PW7
           cmp   Type_letter,01h
           jnz   InInver
           mov   Type_letter,00h
           jmp   PW7
InInver:   mov   Type_letter,01h   
           jmp   PW7

PW7:       cmp   NextDig,37h
           jnz   PW8
           mov   BSpace,0FFh       
           
PW8:       cmp   NextDig,3Dh
           jnz   PW9
           not   Registr
           mov   NextDig,0        
           
PW9:       cmp   NextDig,3Ch
           jnz   PW10
           mov   Text_mess,0FFh 
           mov   Prior_mess,00h
           mov   Nom_mess,00h
           jmp   PW12
           
PW10:      cmp   NextDig,3Bh
           jnz   PW11
           mov   Text_mess,00h
           mov   Prior_mess,0FFh   
           mov   Nom_mess,00h;
           jmp   PW12
           
PW11:      cmp   NextDig,3Ah
           jnz   PW12
           mov   Text_mess,00h
           mov   Prior_mess,00h
           mov   Stop,0FFh
           mov   Nom_mess,0FFh       
           
PW12:      cmp   NextDig,39h
           jnz   PW13
           ;call  Rastanovka
           
PW13:      cmp   NextDig,38h
           jnz   EndPW
           not   Stop            

EndPW:     ret
PodgotWork ENDP
;-------------------------------------------------------------------------------------------------------------------------
Girny      PROC
           mov   si,0
           mov   cx,15
           mov   ax,Word PTR FrazaNaVivod.Bukvi[bx][0]
           mov   Word PTR Letter[0],ax
KO1:       mov   ax,Word PTR FrazaNaVivod.Bukvi[bx][si]       
           mov   dx,Word PTR FrazaNaVivod.Bukvi[bx][si]+2
           or    dx,ax
           mov   Word PTR Letter[si]+2,dx               
           inc   si
           inc   si
           loop  KO1
           ret
Girny      ENDP
;-------------------------------------------------------------------------------------------------------------------------
Kursiv     PROC
           mov   cx,16           
           mov   si,0            
OB:        mov   Word PTR Letter[si],0
           inc   si
           inc   si
           loop  OB
         
           mov   si,1
           mov   cx,15
           mov   ax,Word PTR FrazaNaVivod.Bukvi[bx][0]
           mov   Word PTR Letter[0],ax
           mov   ax,Word PTR FrazaNaVivod.Bukvi[bx][2]
           mov   Word PTR Letter[2],ax                      
KO2:       mov   ax,Word PTR FrazaNaVivod.Bukvi[bx][si]
           mov   dx,ax
           and   dx,0F800h
           or    Word PTR Letter[si]-2,dx
           mov   dx,ax
           and   dx,07E0h
           or    Word PTR Letter[si],dx
           mov   dx,ax
           and   dx,001Fh
           or    Word PTR Letter[si]+2,dx                      
           inc   si
           inc   si
           loop  KO2
           ret
Kursiv     ENDP
;-------------------------------------------------------------------------------------------------------------------------
Podch      PROC
           mov   si,0
           mov   cx,16
KO3:       mov   ax,Word PTR FrazaNaVivod.Bukvi[bx][si]
           or    ax,8000h
           mov   Word PTR Letter[si],ax
           inc   si
           inc   si
           loop  KO3
           ret
Podch      ENDP
;-------------------------------------------------------------------------------------------------------------------------
Invers     PROC
           mov   si,0
           mov   cx,16
KO4:       mov   ax,Word PTR FrazaNaVivod.Bukvi[bx][si]
           not   ax
           mov   Word PTR Letter[si],ax
           inc   si
           inc   si
           loop  KO4
           ret
Invers     ENDP
;--------------------------------------------------------------------------------------------------------------------------
ExecReg    PROC 
           cmp   Regim,04h
           jnz   ER1
           call  ProgonMass        
           jmp   EndER
ER1:       cmp   Regim,01h
           jnz   ER2
           call  Testir            
           jmp   EndER
ER2:       call  VvodRedak          
EndER:     ret
ExecReg    ENDP
;--------------------------------------------------------------------------------------------------------------------------
SIndik     PROC  
           mov   al,Regim
           mov   ah,Type_letter
           mov   cl,3
           shl   ah,cl
           or    al,ah
           out   0006,al
          
           mov   al,00h
           cmp   Registr,0FFh
           jnz   SI1
           or    al,00010000b
SI1:       cmp   Stop,0FFh
           jnz   SI2
           or    al,00000001b
SI2:       cmp   Nom_mess,0FFh
           jnz   SI3
           or    al,00000010b
SI3:       cmp   Prior_mess,0FFh
           jnz   SI4
           or    al,00000100b
SI4:       cmp   Text_mess,0FFh
           jnz   SI5
           or    al,00001000b
SI5:       out   0007,al  
           ret
SIndik     ENDP
;--------------------------------------------------------------------------------------------------------------------------
ProgonMass PROC                  ;MassPPZU--->FrazaNaVivod
           mov   Nom_mess,0
           mov   Prior_mess,0
           mov   Text_mess,0
          
           cmp   Frazaend,0FFh    
           jnz   EndPM
           
           mov   Frazaend,00h        
           
           cmp   NomSoob,8
           jnz   PPZU
           mov   NomSoob,0
PPZU:      mov   bx,NomSoob 
           inc   NomSoob        
           
           mov   al,MassPPZU[bx].Nom
           mov   FrazaNaVivod.Nom,al
           mov   al,MassPPZU[bx].Prior
           mov   FrazaNaVivod.Prior,al
           mov   al,MassPPZU[bx].InG
           mov   FrazaNaVivod.InG,al
           mov   al,MassPPZU[bx].InK
           mov   FrazaNaVivod.InK,al
           mov   al,MassPPZU[bx].InP
           mov   FrazaNaVivod.InP,al
           mov   al,MassPPZU[bx].InIn
           mov   FrazaNaVivod.InIn,al
           
           mov   cx,LENGTH FullFraza 
           mov   si,0           
Zapis:     mov   ax,MassPPZU[bx].Bukvi[si]
           mov   Word PTR FrazaNaVivod.Bukvi[si],ax
           inc   si
           inc   si
           loop  Zapis
EndPM:     ret
ProgonMass ENDP
;--------------------------------------------------------------------------------------------------------------------------
Testir     PROC                  ;LetterImage--->FrazaNaVivod
           mov   Type_Letter,0
           mov   Nom_mess,0
           mov   Prior_mess,0
           mov   Text_mess,0
           mov   Stop,0           
           mov   FrazaNaVivod.Nom,0
           mov   FrazaNaVivod.Prior,0
           mov   FrazaNaVivod.InG,0
           mov   FrazaNaVivod.InK,0
           mov   FrazaNaVivod.InP,0
           mov   FrazaNaVivod.InIn,0
           
           mov   ax,LENGTH FullFraza
           cmp   Ukazat,ax                
           jz    Zav

           mov   cx,LENGTH FullFraza
           mov   si,0
           lea   bx,LetterImage
Tes1:      mov   ax,es:[bx][si]
           mov   FrazaNaVivod.Bukvi[si],ax
           inc   si
           inc   si
           loop  Tes1
           jmp   EnTes
Zav:       mov   Stop,0FFh
           mov   Regim,02h 
EnTes:     ret
Testir     ENDP
;--------------------------------------------------------------------------------------------------------------------------
VvodRedak  PROC
           call  ClenObr
           
           cmp   EmpKbd,0FFh     
           jz    EndVR             
           cmp   KbdErr,0FFh     
           jz    EndVR

           call  ClenObr

           cmp   Prior_mess,0h
           jnz   PriorM
           cmp   Text_mess,0h
           jnz   TextM
           mov   Nom_mess,0FFh

           mov   NomSoob,0            
           
           cmp   NextDig,4
           jns   EndVR
           
           mov   Registr,00h
      
           mov   ax,Word PTR NextDig
           mov   NomSoob,ax
           
           mov   bx,NomSoob
           mov   Word PTR Akumulator[bx].Nom,ax                 
              
           jmp   Perekahka
           
PriorM:    cmp   NextDig,4
           jns   EndVR
           
           call  ClenObr

           mov   Registr,00h
           
           mov   al,NextDig
           mov   bx,NomSoob
           mov   Akumulator[bx].Prior,al
           
           jmp   Perekahka
           
TextM:     cmp   EmpKbd,0FFh     
           jz    EndVR
           
           cmp  NextDig,47
           jnz  NotDefect
           mov  al,0FFh
           out  20h,al
           
           nop
                
NotDefect:  ;    cmp   Kurs,0
       ;    jnz   Prin    
       ;    mov   si,0
       ;    jmp   Prin1
           
           
Prin:      mov   al,Kurs
           mov   ah,0
           mov   si,ax
Prin1:     mov   cx,16
           mov   di,Offset_let
PrinLet:   lea   bx,LetterImage
           mov   ax,es:[bx][di]
           mov   bx,NomSoob
           mov   Akumulator[bx].Bukvi[si],ax
           inc   si
           inc   si
           inc   di
           inc   di
           add   Kurs,1
           loop  PrinLet
           add   Kurs,16          
                      
Perekahka: ;mov   bx,NomSoob
 
           mov   al,Akumulator[bx].Nom
           mov   FrazaNaVivod.Nom,al
          
           mov   al,Akumulator[bx].Prior
           mov   FrazaNaVivod.Prior,al
           
           mov   cx,128                
           mov   si,0
Obmen:     mov   ax,Akumulator[bx].Bukvi[si]
           mov   FrazaNaVivod.Bukvi[si],ax
           inc   si
           inc   si
           loop  Obmen    
           
           EndVR:     ret
VvodRedak  ENDP
;-------------------------------------------------------------------------------------------------------------------------
Pre_FrNaVi PROC                          
           cmp   Regim,02h               
           jnz   Other                 
           
           cmp   Nom_mess,0FFh
           jnz   Prioritet
           
           lea   bx,LetterImage
           
           mov   al,FrazaNaVivod.Nom
           mov   ah,32
           mul   ah
           add   bx,ax
           
           jmp   Zikl
           
Prioritet: cmp   Prior_mess,0FFh
           jnz   Bukvy          
           lea   bx,LetterImage
           
           mov   al,FrazaNaVivod.Prior
           mov   ah,32
           mul   ah
           add   bx,ax 
Zikl:      
           mov   si,0
           mov   cx,16
           
Perekach:  mov   ax,es:[bx][si]
           mov   FullFraza[si],ax
           inc   si
           inc   si
           loop  Perekach
           
           jmp   EndPFNV 


Bukvy:     mov   bx,0
   
PFNV1:     mov   si,0             
           mov   cx,16
PFNV4:     mov   ax,FrazaNaVivod.Bukvi[bx][si]
           mov   Letter[si],ax
           inc   si
           inc   si
           loop  PFNV4        
        
           mov   cx,16
           mov   si,0
PFNV5:     mov   ax,Letter[si]
           mov   FullFraza[bx][si],ax
           inc   si
           inc   si
           loop  PFNV5
           
           inc   bx
           cmp   bx,LENGTH FullFraza        
           jnz   PFNV1           
           
           jmp   EndPFNV 
           
Other:     mov   bx,0
           
PFNV0:     mov   si,0             
           mov   cx,16
PFNV2:     mov   ax,FrazaNaVivod.Bukvi[bx][si]
           mov   Letter[si],ax
           inc   si
           inc   si
           loop  PFNV2        
        
           mov   cx,16
           mov   si,0
PFNV3:     mov   ax,Letter[si]
           mov   FullFraza[bx][si],ax
           inc   si
           inc   si
           loop  PFNV3
           
           inc   bx
           cmp   bx,1000        
           jnz   PFNV0      
 
EndPFNV:   ret
Pre_FrNaVi ENDP

;-------------------------------------------------------------------------------------------------------------------------
Pre_OutSkr PROC
     
           call  Pre_FrNaVi          
           cmp   Regim,02h
           jnz   POS2
           
           mov   si,0
           mov   cx,128
POS1:      mov   ax,FullFraza[si]
           mov   ObrSkreen[si],ax
           inc   si
           inc   si
           loop  POS1
           
           jmp   EndPOS
           
POS2:      cmp   Stop,0FFh
           jz    EndPOS
           
           mov   bx,8
OutZikl:            
                              
           mov   cx,128
           mov   si,0
STO:       mov   ax,ObrSkreen[si]
           mov   ObrSkreen[si]-2,ax
           inc   si
           inc   si
           loop  STO
           
           mov   si,Ukazat 
           shl   si,1       
           mov   ax,FullFraza[si]       
           mov   ObrSkreen[0feh],ax
           inc   Ukazat
           dec   bx
           cmp   bx,0
           jnz   OutZikl 
EndPOS:        ret
Pre_OutSkr ENDP
;--------------------------------------------------------------------------------------------------------------------------
OutScreen  PROC  
           lea   bx,ObrSkreen
           mov   dx,0001h        
            
NextInd:
           mov   al,0
           out   0000h,al        
           mov   ax,dx
           out   0003h,al        
           mov   al,ah
           out   0004h,al                  
           mov   cl,1            
NextCol:
           mov   al,0
           out   0000h,al        
           mov   ax,ds:[bx]      
           out   0001h,al        
           mov   al,ah
           out   0002h,al              
           mov   al,cl
           out   0000h,al
           
           add   bx,2            
           shl   cl,1            
           jnc   NextCol         
           shl   dx,1      
           jnz   NextInd         
           xor   dx,dx 
           ret
OutScreen  ENDP 


;--------------------------------------------------------------------------------------------------------------------------
Rastanovka PROC
           mov   bx,0
           
           mov   al,Akumulator[0].Prior      
           mov   i,al
           mov   al,Akumulator[1].Prior
           mov   j,al
           mov   al,Akumulator[2].Prior
           mov   k,al           
           mov   al,Akumulator[3].Prior
           mov   m,al  
                     
Repeat:    cmp   i,0
           jnz   DecI
           cmp   Akumulator[0].Prior,0
           jz    SledEtap1
           
           mov   al,Akumulator[0].Nom
           mov   MassPPZU[bx].Nom,al
           
           mov   al,Akumulator[0].Prior
           mov   MassPPZU[bx].Prior,al           
           mov   i,al
           
           mov   al,Akumulator[0].InG
           mov   MassPPZU[bx].InG,al 
                      
           mov   al,Akumulator[0].InK
           mov   MassPPZU[bx].InK,al
                      
           mov   al,Akumulator[0].InP
           mov   MassPPZU[bx].InP,al
                      
           mov   al,Akumulator[0].InIn
           mov   MassPPZU[bx].InIn,al 

           mov   si,0
           mov   cx,512
TY1:       mov   ax,Akumulator.Bukvi[si]
           mov   Word PTR MassPPZU[bx].Bukvi[si],ax
           inc   si
           inc   si
           loop  TY1               

           inc   bx
           jmp   SledEtap1
DecI:      dec   i

SledEtap1: cmp   j,0
           jnz   DecJ
           cmp   Akumulator[1].Prior,0
           jz    SledEtap2
        
           mov   al,Akumulator[1].Nom
           mov   MassPPZU[bx].Nom,al

           mov   al,Akumulator[1].Prior
           mov   MassPPZU[bx].Prior,al           
           mov   j,al
           
           mov   al,Akumulator[1].InG
           mov   MassPPZU[bx].InG,al           
                      
           mov   al,Akumulator[1].InK
           mov   MassPPZU[bx].InK,al           
                      
           mov   al,Akumulator[1].InP
           mov   MassPPZU[bx].InP,al
                      
           mov   al,Akumulator[1].InIn
           mov   MassPPZU[bx].InIn,al

           mov   si,0
           mov   cx,512
TY2:       mov   ax,Akumulator[1].Bukvi[si]
           mov   Word PTR MassPPZU[bx].Bukvi[si],ax
           inc   si
           inc   si
           loop  TY2                          

           inc   bx
           jmp   SledEtap2
DecJ:      dec   j   

SledEtap2: cmp   k,0
           jnz   DecK
           cmp   Akumulator[2].Prior,0
           jz    SledEtap3

           
           mov   al,Akumulator[2].Nom
           mov   MassPPZU[bx].Nom,al

           mov   al,Akumulator[2].Prior
           mov   MassPPZU[bx].Prior,al           
           mov   k,al
           
           mov   al,Akumulator[2].InG
           mov   MassPPZU[bx].InG,al
                      
           mov   al,Akumulator[2].InK
           mov   MassPPZU[bx].InK,al
              
           mov   al,Akumulator[2].InP
           mov   MassPPZU[bx].InP,al
                      
           mov   al,Akumulator[2].InIn
           mov   MassPPZU[bx].InIn,al

           mov   si,0
           mov   cx,512
TY3:       mov   ax,Akumulator[2].Bukvi[si]
           mov   Word PTR MassPPZU[bx].Bukvi[si],ax
           inc   si
           inc   si
           loop  TY3                                             
           
           inc   bx
           jmp   SledEtap3
DecK:       dec   k   
           
SledEtap3: cmp   m,0
           jnz   DecM
           cmp   Akumulator[3].Prior,0
           jz    Povtor
           
           mov   al,Akumulator[3].Nom
           mov   MassPPZU[bx].Nom,al

           mov   al,Akumulator[3].Prior
           mov   MassPPZU[bx].Prior,al           
           mov   m,al
           
           mov   al,Akumulator[3].InG
           mov   MassPPZU[bx].InG,al
                      
           mov   al,Akumulator[3].InK
           mov   MassPPZU[bx].InK,al
                      
           mov   al,Akumulator[3].InP
           mov   MassPPZU[bx].InP,al
                      
           mov   al,Akumulator[3].InIn
           mov   MassPPZU[bx].InIn,al

           mov   si,0
           mov   cx,512
TY4:       mov   ax,Akumulator[3].Bukvi[si]
           mov   Word PTR MassPPZU[bx].Bukvi[si],ax
           inc   si
           inc   si
           loop  TY4                       
           
           inc   bx
           jmp   Povtor
DecM:       dec   m           
Povtor:    cmp   bx,8
           jnz   Repeat
           ret
Rastanovka ENDP
;--------------------------------------------------------------------------------------------------------------------------
           org   RomSize-16-((SIZE Data+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
