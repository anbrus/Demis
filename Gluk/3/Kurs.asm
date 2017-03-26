.386

RomSize       EQU   4096
NMax          EQU   50
MinTime       EQU   10
CountRotate   EQU   32
OneSec        EQU   16
MaxRes        EQU   30
MinRes        EQU   0
MinNom        EQU   1
MaxNom        EQU   40
DelayValue    EQU   02FFFh
ConstR1       EQU   45752
ConstR2       EQU   54300
ConstR3       EQU   12300 
_HandR        EQU   00000001b
_AutoR        EQU   00000010b
_RandomR      EQU   00000100b
_NextPD       EQU   00001000b
_BackPD       EQU   00010000b 
_NextRes      EQU   00100000b
_BackRes      EQU   01000000b
_Start        EQU   10000000b
_NextAutoR    EQU   00000001b
_NextRandomR  EQU   00000010b
_ClearARRPV   EQU   00000000b
_DatResetRes  EQU   00000010b
_DatResetDiamag EQU  000000100b
_DatResetTol  EQU   00001000b

ButtonPort      EQU   0
ACP&IndPort     EQU   0
ACPDataPort     EQU   2
ResRotatePort   EQU   0bh
DiamagRotatePort EQU  0ch
TolRotatePort   EQU   0dh
InPort          EQU   1
OutPort         EQU   0eh
DigIndPortSelected EQU  2 
DigIndPortData   EQU  1
MatIndSelected   EQU 8
MatIndData       EQU 9
MatIndStolSelected  EQU  0Ah

Data       SEGMENT AT 40h use16
          
           FlagR         db  ?
           FlagPD        db  ?
           FlagRes&RR    db  ?
           FlagARRPV     db  ?
           DelayHEX      db  ?
           NomHEX        db  ?
           ResHEH        db  ?
           NomRandom     db  ?
           DelayBCD      db  ?
           NomBCD        db  ?
           ResBCD        db  ?
           RandomConst1  dw  ?
           RandomConst2  dw  ?
           RandomConst3  dw  ?
           ResRotate     db  ?
           DiamagRotate  db  ?
           TolRotate     db  ?
Data       ENDS


Stk        SEGMENT AT 300h use16
           dw    25 dup (?)
StkTop     Label Word
Stk        ENDS


Code       SEGMENT use16
           ASSUME cs:Code,ds:Data,es:Code
    Image  DB   03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh   
BaseImage  DB   0FFh, 03Fh, 03Fh, 03Fh, 03Fh, 00Fh, 02Fh, 02Fh,02Fh, 02Fh, 00Fh, 03Fh, 03Fh, 03Fh, 03Fh, 0FFh,0FFh, 080h, 080h, 080h, 080h, 080h, 080h, 080h,080h, 080h, 080h, 080h, 080h, 080h, 080h, 0FFh
           DB   0FFh, 0FFh, 0FFh, 03Fh, 080h, 0BEh, 0BEh, 0BEh,0BEh, 0BEh, 0BEh, 0BEh, 080h, 03Fh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 080h, 0BFh, 0BFh, 0BFh, 0B9h,0B1h, 0B9h, 0BFh, 0BFh, 0BFh, 080h, 0FFh, 0FFh
           DB   0BFh, 07Fh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 07Fh, 0BFh,0FFh, 0FFh, 0FEh, 0FDh, 01Bh, 017h, 00Fh, 01Fh,01Fh, 00Fh, 017h, 01Bh, 0FDh, 0FEh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 003h, 0FBh, 0D9h, 0D9h, 0DBh,0FBh, 0DBh, 089h, 0D9h, 0FBh, 003h, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 080h, 0BFh, 0BFh, 0BFh, 0BFh,0BFh, 0BFh, 0BFh, 0BFh, 0BFh, 080h, 0FFh, 0FFh
           DB   0FFh, 0CFh, 007h, 077h, 077h, 077h, 007h, 0CFh,0CFh, 007h, 077h, 077h, 077h, 007h, 0CFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h,000h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 081h, 099h, 0BDh, 0BDh, 080h,080h, 0BDh, 0BDh, 099h, 081h, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 007h,007h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 081h, 081h, 081h, 081h, 080h,080h, 081h, 081h, 081h, 081h, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 03Fh, 05Fh, 06Fh, 06Fh, 06Fh,06Fh, 06Fh, 06Fh, 05Fh, 03Fh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 080h, 0BFh, 0BFh, 0BFh,0BFh, 0BFh, 0BFh, 080h, 0FFh, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 003h, 0FBh, 0FBh, 0FBh,0FBh, 0FBh, 0FBh, 003h, 0DFh, 0DFh, 01Fh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 080h, 0BFh, 0BFh, 0BFh,0BFh, 0BFh, 0BFh, 080h, 0FBh, 0FBh, 0F8h, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh,0FDh, 0F9h, 0F5h, 0EDh, 0DDh, 0BDh, 0BDh, 0BDh,0BDh, 0BDh, 0BDh, 0DDh, 0EDh, 0F5h, 0F9h, 0FDh

           DB   00Fh, 03Fh, 03Fh, 03Fh, 03Fh, 03Fh, 03Fh, 03Fh,03Fh, 03Fh, 03Fh, 03Fh, 03Fh, 03Fh, 00Fh, 0FFh,0FFh, 0FEh, 0FFh, 0FEh, 0FFh, 0FEh, 0FFh, 0FEh,0FFh, 0FEh, 0FFh, 0FEh, 0FFh, 0FEh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 003h, 0FBh, 05Bh, 0FBh, 057h, 0FBh,05Bh, 0FBh, 003h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 000h, 07Fh, 055h, 07Fh, 055h, 07Fh,055h, 07Fh, 000h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh 
           DB   0FFh, 0FFh, 003h, 0FBh, 00Bh, 06Bh, 06Bh, 06Bh,008h, 0FBh, 003h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 000h, 07Fh, 055h, 07Fh, 055h, 07Fh,055h, 07Fh, 000h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 000h, 0FEh, 0FEh, 0FEh,0FEh, 0FEh, 07Eh, 0FEh, 000h, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 080h, 0BFh, 0BFh, 0BFh,0BFh, 0BFh, 0BEh, 0BFh, 080h, 0FFh, 0FFh, 0FFh
           DB   0FFh, 001h, 07Dh, 07Dh, 07Dh, 07Dh, 07Dh, 001h,07Dh, 07Dh, 07Dh, 07Dh, 07Dh, 001h, 0FFh, 0FFh,0FFh, 0C0h, 0DFh, 0DFh, 0DFh, 0DFh, 0DFh, 0DFh,0DFh, 0DFh, 0DFh, 0DFh, 0DFh, 0C0h, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0EFh, 00Fh, 0EFh, 0EFh, 0E7h,0E7h, 0EFh, 0EFh, 00Fh, 0EFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 0F7h, 0F7h, 0F7h,0F7h, 0F7h, 0F7h, 0F0h, 0FFh, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0EFh, 083h, 0BAh, 029h,029h, 0BAh, 083h, 0EFh, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 00Ch, 0E0h,0E0h, 00Ch, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h,000h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0F7h, 0E7h, 0C7h, 087h, 000h,000h, 087h, 0C7h, 0E7h, 0F7h, 0FFh, 0FFh, 0FFh
           DB   01Fh, 00Fh, 007h, 07Fh, 07Fh, 07Fh, 07Fh, 07Fh,07Fh, 07Fh, 07Fh, 07Fh, 07Fh, 07Fh, 07Fh, 0FFh,0F0h, 0F0h, 0F0h, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh,0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FFh 
           DB   0FFh, 0FFh, 0FFh, 01Fh, 01Fh, 01Fh, 07Fh, 07Fh,07Fh, 07Fh, 07Fh, 07Fh, 07Fh, 07Fh, 07Fh, 0FFh,0FBh, 0F9h, 0F8h, 0F8h, 0F8h, 0F8h, 0F8h, 0FAh,0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FFh
          
           DB   07Fh, 03Fh, 0DFh, 0EFh, 0F7h, 0FBh, 0FDh, 0FEh,0FEh, 0FDh, 0FBh, 0F7h, 0EFh, 0DFh, 03Fh, 07Fh,0FFh, 000h, 07Fh, 07Fh, 07Fh, 07Fh, 060h, 06Eh,06Eh, 060h, 07Fh, 07Fh, 07Fh, 07Fh, 000h, 0FFh
           DB   0FFh, 0DBh, 0B1h, 000h, 071h, 0BBh, 0FFh, 0FFh,0FFh, 0DBh, 0B1h, 000h, 071h, 0BBh, 0FFh, 0FFh,0FFh, 0DBh, 0B1h, 000h, 071h, 0BBh, 0FFh, 0FFh,0FFh, 0DBh, 0B1h, 000h, 071h, 0BBh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 00Eh, 0EDh, 0EBh, 0E7h,0E7h, 0EBh, 0EDh, 00Eh, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 0C7h, 0F7h, 0F7h,0F7h, 0F7h, 0C7h, 0F0h, 0FFh, 0FFh, 0FFh, 0FFh
           DB   0FFh, 001h, 0FDh, 0FDh, 07Dh, 0DDh, 0ADh, 055h,055h, 0ADh, 0DDh, 07Dh, 0FDh, 0FDh, 001h, 0FFh,0FFh, 080h, 0BFh, 0BFh, 0BFh, 09Eh, 0ADh, 0B0h,0B0h, 0ADh, 09Eh, 0BFh, 0BFh, 0BFh, 080h, 0FFh
           DB   0FFh, 0FFh, 001h, 07Dh, 07Dh, 07Dh, 07Dh, 07Dh,001h, 0FFh, 001h, 0FDh, 0FDh, 03Dh, 001h, 0FFh,0FFh, 0FFh, 0FFh, 0C2h, 0DBh, 0DBh, 0DBh, 0DAh,0DBh, 0DBh, 0C2h, 0FEh, 0FEh, 0FEh, 0FEh, 0FFh
           DB   07Fh, 0BFh, 0DFh, 0DFh, 0C7h, 0C7h, 0DFh, 0DFh,0DFh, 0DFh, 0DFh, 0DFh, 0DFh, 0DFh, 0BFh, 07Fh,0F8h, 0FBh, 0F8h, 0F6h, 0E2h, 0F6h, 0F8h, 0FBh,0FBh, 0F8h, 0F6h, 0E2h, 0F6h, 0F8h, 0FBh, 0F8h
           DB   0FFh, 0DFh, 0DFh, 01Fh, 0DFh, 0DFh, 0DFh, 0DFh,0DFh, 0DFh, 0DFh, 0DFh, 01Fh, 0DFh, 0DFh, 0FFh,0FFh, 0FFh, 0FFh, 0F0h, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 003h, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 080h, 0FEh, 0FEh, 0FEh,0FEh, 0FEh, 0FEh, 080h, 0FFh, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 07Fh, 0BFh, 0DFh,0EFh, 0EFh, 0EFh, 0EFh, 00Fh, 0FFh, 0FFh, 0FFh,0FFh, 0FEh, 0FCh, 0FAh, 0F6h, 0EFh, 0EFh, 0EFh,0EFh, 0EFh, 0EFh, 0EFh, 0EEh, 0EEh, 0E0h, 0FFh
           DB   0FFh, 001h, 0FDh, 0FDh, 0FDh, 0FDh, 07Dh, 001h,001h, 07Dh, 07Dh, 07Dh, 0FDh, 0FDh, 001h, 0FFh,0FFh, 080h, 0BFh, 0BFh, 0BFh, 0BFh, 0BEh, 0B0h,0B0h, 0BEh, 0BEh, 0BEh, 0BFh, 0BFh, 080h, 0FFh
           
           DB   0FFh, 03Fh, 03Fh, 03Fh, 03Fh, 00Fh, 02Fh, 02Fh,02Fh, 02Fh, 00Fh, 03Fh, 03Fh, 03Fh, 03Fh, 0FFh,0FFh, 080h, 080h, 080h, 080h, 080h, 080h, 080h,080h, 080h, 080h, 080h, 080h, 080h, 080h, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 07Fh, 0BFh, 0DFh,0EFh, 0EFh, 0EFh, 0EFh, 00Fh, 0FFh, 0FFh, 0FFh,0FFh, 0FEh, 0FCh, 0FAh, 0F6h, 0EFh, 0EFh, 0EFh,0EFh, 0EFh, 0EFh, 0EFh, 0EEh, 0EEh, 0E0h, 0FFh
           DB   0FFh, 001h, 0FDh, 0FDh, 07Dh, 0DDh, 0ADh, 055h,055h, 0ADh, 0DDh, 07Dh, 0FDh, 0FDh, 001h, 0FFh,0FFh, 080h, 0BFh, 0BFh, 0BFh, 09Eh, 0ADh, 0B0h,0B0h, 0ADh, 09Eh, 0BFh, 0BFh, 0BFh, 080h, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 007h,007h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 081h, 081h, 081h, 081h, 080h,080h, 081h, 081h, 081h, 081h, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0EFh, 00Fh, 0EFh, 0EFh, 0E7h,0E7h, 0EFh, 0EFh, 00Fh, 0EFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 0F7h, 0F7h, 0F7h,0F7h, 0F7h, 0F7h, 0F0h, 0FFh, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h, 0FEh, 0AAh,0FEh, 0AAh, 0FEh, 000h, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h, 07Fh, 055h,07Fh, 055h, 07Fh, 000h, 0FFh, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h, 0FEh, 0EAh,0FEh, 0EAh, 0FEh, 000h, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h, 07Fh, 07Dh,07Fh, 05Fh, 07Fh, 000h, 0FFh, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h, 0FEh, 0EAh,0FEh, 0EAh, 0FEh, 000h, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h, 07Fh, 057h,07Fh, 057h, 07Fh, 000h, 0FFh, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h, 0FEh, 0EEh,0FEh, 0EEh, 0FEh, 000h, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h, 07Fh, 055h,07Fh, 055h, 07Fh, 000h, 0FFh, 0FFh, 0FFh, 0FFh
           DB   0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h, 0FEh, 0EEh,0FEh, 0EEh, 0FEh, 000h, 0FFh, 0FFh, 0FFh, 0FFh,0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 000h, 07Fh, 077h,07Fh, 077h, 07Fh, 000h, 0FFh, 0FFh, 0FFh, 0FFh
           
   VibrDestr  PROC  NEAR
           VD1:       mov   ah,al       
                      mov   bh,0        
           VD2:       in    al,0       
                      cmp   ah,al       
                      jne   VD1         
                      inc   bh          
                      cmp   bh,NMax     
                      jne   VD2         
                      mov   al,ah       
                      ret
  VibrDestr  ENDP 
  
  ScanButton      PROC  NEAR
                      push ax
                      in   al,ButtonPort
                      cmp  al,0
                      Jz ExitScanButton 
                      call  VibrDestr
                      in   al,ButtonPort
                      Mov ah,al
                      and al,00000111b
                      cmp al,0
                      jz NextScanButton
                      mov FlagR,al 
                    ;  jmp ExitScanButton 
       NextScanButton:mov al,ah
                      and al,00011000b
                      cmp al,0
                      jz Next2ScanButton
                      mov FlagPD,al
                    ;  jmp ExitScanButton
      Next2ScanButton:mov al,ah   
                      mov FlagRes&RR,al 
       ExitScanButton:mov FlagRes&RR,al 
                      pop ax 
                      ret   
  ScanButton      ENDP
  
  ScanTime     PROC   NEAR
                       push  ax
                       push  cx
                       mov   al,FlagPD
                       or    al,FlagR
                       out   ACP&IndPort,al
                       or    al,00100000b
                       out   ACP&IndPort,al
               WaitRdy:in    al,InPort        
                       test  al,1
                       jz    WaitRdy
                       in    al,ACPDataPort 
                       mov   cl,3
                       shr   al,cl
                       add   al,MinTime
                       mov   DelayHEX,al
                       call  hex_bcd
                       mov  DelayBCD,al
                       call PortOut
                       pop cx
                       pop ax
                       ret
  ScanTime      ENDP 
  
  ClearOutPort  proc near
                    push ax
                    mov al,0
                    out OutPort,al 
                    pop ax
                    ret
  ClearOutPort  endp
  
  HEX_BCD     PROC NEAR; В cl-hex в al-bcd
                 push cx
                 xor cx,cx
                 mov cl,al
                 mov al,0
                 cmp cl,0
                 jz ExitHEX_BCD
     LoopHEX_BCD:Add al,1
                 daa
                 loop LoopHEX_BCD
     ExitHEX_BCD:pop cx
                 ret  
  HEX_BCD     ENDP 
  
  Init          PROC   NEAR
                      mov   FlagPD,_NextPD
                      mov   FlagR,_HandR 
                      mov   FlagARRPV,0; 
                ;     mov   DelayHEX,0
                ;     mov   DelayBCD,0
                      mov   NomHEX,MinNom
                      mov   NomBCD,MinNom
                      mov   ResHEH, MinRes
                      mov   ResBCD, MinRes
                      mov   ResRotate,1
                      mov   DiamagRotate,1
                      mov   TolRotate, 1
                      mov   RandomConst1,ConstR1
                      mov   RandomConst2,ConstR2
                      mov   RandomConst3,ConstR3   
   NextResRotateLeft: in al,InPort
                      test al,_DatResetRes
                      jnz NextInit1
                      call Delay
                      call Delay
                      call ResRotateLeft
                      jmp NextResRotateLeft
    NextTolRotateLeft:
            NextInit1:in al,InPort
                      test al,_DatResetTol
                      jnz nextInit2
                      call Delay
                      call tolRotateLeft
                      jmp NextTolRotateLeft
 NextDiamagRotateLeft:
            nextInit2:in al,InPort
                      test al,_DatResetDiamag
                      jnz NextInit3 
                      call Delay
                      call DiamagRotateLeft
                      jmp NextDiamagRotateLeft
             NextInit3:mov cx,CountRotate
    NexttolRotateRight:call Delay
                       call tolRotateRight
                       loop NexttolRotateRight
                       call  ClearOutPort           
                       ret
  Init          ENDP  
  
  OutDigInf     PROC   NEAR
                  push ax 
                  push bx
                  push dx
                  push si
                  push di
                  lea   bx,Image
                  mov   dl,0FEh
                  lea   di,DelayBCD
                  mov   cx, 3         
         
       NextDig:  mov al,0
                 out   DigIndPortData,al  
                 mov al,dl
                 out   DigIndPortSelected,al 
                 mov   al,[di]
                 xor   ah,ah
                 mov   dh,al       
                 and   al,0Fh
                 mov   si,ax
                 mov al,cs:[bx+si]
                 out   DigIndPortData,al  
                 mov al,0
                 out   DigIndPortData,al
                 rol dl,1 
                 mov al,dl
                 out   DigIndPortSelected,al       
                 mov   al,dh
                 shr   al,4
                 mov   si,ax
                 mov al,cs:[bx+si]
                 out   DigIndPortData,al 
                 rol dl,1 
                 inc di 
                 loop NextDig   
                 pop di
                 pop si
                 pop dx
                 pop bx
                 pop ax       
                 ret
  OutDigInf     ENDP 
  
  Res    PROC NEAR
              Push ax
              mov al, ResHEH
              test FlagRes&RR,_NextRes
              jz SubRes
              cmp al,MaxRes
              jz ExitRes
              inc al
              call ResRotateLeft 
              jmp NextRes
       SubRes:test FlagRes&RR,_BackRes 
              jz  ExitRes
              cmp al,MinRes
              jz ExitRes
              dec al
              call ResRotateRight
      NextRes:mov ResHEH,al
              call  hex_bcd
              mov ResBCD,al  
              call   Delay
              call   ScanButton
              call   ScanTime
              call  OutDigInf
             
              call  ClearOutPort
      ExitRes:pop ax
              ret
  Res    ENDP     
  
  
Delay      proc  near
           push  cx
           mov   cx,DelayValue
DelayLoop: inc   cx
           dec cx
           inc cx
           dec cx
           inc   cx
           dec cx
           loop  DelayLoop
           pop   cx
           ret
Delay      endp   

Delay1_16sec proc
           push  cx
           call   Delay
           call   ScanButton
           call   ScanTime
           call  OutDigInf
           call  res
           
           pop   cx
           ret
Delay1_16sec endp 

NomD_Pos   proc  near
               push ax
               push dx
               push cx
               xor ah,ah
               mov cl,5
               mov dx,3
               mov al,0
     NextClear:out dx,al
               inc dx
               loop NextClear
               mov al,NomHEX  
               dec al             ; т к нумерация с 1
               mov cl,3
               shr al,cl
               mov cl,al
               mov dx,ax
               mov al,NomHEX  
               dec al             ; тоже
               shl cl,3
               sub al,cl
               mov cl,al
               mov al,1
               shl al,cl
               add dx,3
               out dx,al
               pop cx
               pop dx
               pop ax
               ret
NomD_Pos   endp 

ResRotateLeft  proc near            ;К началу
                 push ax
                 mov al,1
                 out OutPort  ,al                
                 mov al,ResRotate
                 rol al,1
                 out ResRotatePort,al
                 mov ResRotate,al
                 pop ax
                 ret
ResRotateLeft  endp  

TolRotateLeft  proc near           ;К забору
                 push ax
                 mov al,4
                 out OutPort  ,al  
                 mov al,TolRotate
                 rol al,1
                 out TolRotatePort,al
                 mov TolRotate,al
                 pop ax
                 ret
TolRotateLeft  endp

TolRotateRight  proc near            ;К показу
                 push ax
                 mov al,8
                 out OutPort  ,al  
                 mov al,TolRotate
                 ror al,1
                 out TolRotatePort,al
                 mov TolRotate,al
                 pop ax
                 ret
TolRotateRight  endp 

DiamagRotateLeft  proc near            ;К началу
                 push ax
                 mov al,10h
                 out OutPort  ,al  
                 mov al,DiamagRotate
                 rol al,1
                 out DiamagRotatePort,al
                 mov DiamagRotate,al
                 pop ax
                 ret
DiamagRotateLeft  endp 

DiamagRotateRight  proc near               ; 
                 push ax
                 mov al,20h
                 out OutPort  ,al  
                 mov al,DiamagRotate
                 ror al,1
                 out DiamagRotatePort,al
                 mov DiamagRotate,al
                 pop ax
                 ret
DiamagRotateRight  endp

ResRotateRight  proc near
                 push ax
                 mov al,2
                 out OutPort  ,al 
                 mov al,ResRotate
                 ror al,1
                 out ResRotatePort,al
                 mov ResRotate,al
                 pop ax
                 ret
ResRotateRight  endp 

OutImage   proc  near
              push ax
              push cx
              push dx
              push bx
              
              xor cx,cx
              xor dh,dh
              lea bx,BaseImage
              mov dl,NomHEX
              dec dl                   ; т к с первого
              mov cl,5
              shl dx,cl
              add bx,dx
               
              mov dh,4
              mov ah,1
   NextMatInd:mov dl,1
              mov cx,8
      NextRow:mov al,cs:[bx]
              not al
              out MatIndData,al
              
              mov al,ah
              out MatIndSelected, al
              mov al,dl
              out MatIndStolSelected,al
                        
              mov al,0h
              out MatIndData,al
              out MatIndStolSelected,al
              shl dl,1
              inc bx
              loop NextRow
              shl ah,1
              dec dh
              cmp dh,0
              jnz  NextMatInd
              pop bx
              pop dx
              pop cx
              pop ax 
              ret
OutImage   endp       

TolLeft   proc near
                      push cx
                      mov cx,CountRotate
  RepeatTolRotateLeft:call Delay1_16sec
                      call tolRotateLeft
                      loop RepeatTolRotateLeft
                      call  ClearOutPort 
                      pop cx
                      ret
TolLeft  endp          

TolRight proc near
                     push cx
                     mov cx,CountRotate
RepeatTolRotateRight:call Delay1_16sec
                     call tolRotateRight
                     loop RepeatTolRotateRight
                     call  ClearOutPort   
                     pop cx
                     ret
TolRight endp    

DiamagLeft  proc near
                     Push cx
                     mov cx,OneSec
                     call DiamagRotateLeft
        Repeat1Loop :call Delay1_16sec           
                     loop Repeat1Loop 
                     call  ClearOutPort   
                     pop  cx               
                     ret 
DiamagLeft  endp
                    
DiamagRight proc near
                      push cx
                      mov cx,OneSec
                      call DiamagRotateRight
          RepeatLoop :call Delay1_16sec              
                      loop RepeatLoop 
                      call  ClearOutPort 
                      pop cx
                      ret
DiamagRight endp                                      



DemDiaposNext  proc near    ;+1
                      call TolLeft
                      call DiamagRight
                      call TolRight
                      ret
DemDiaposNext  endp

DemDiaposBack Proc near           ;-1
                     call TolLeft
                     call DiamagLeft
                     call TolRight
                   
                    ret
DemDiaposBack  endp  

PortOut proc near
                  push ax
                  mov al,DiamagRotate
                  out DiamagRotatePort,al
                  mov DiamagRotate,al
                  mov al,TolRotate
                  out TolRotatePort,al
                  mov TolRotate,al
                  mov al,ResRotate
                  out ResRotatePort,al
                  mov ResRotate,al
                  pop ax
            ret
PortOut endp              

HandR      proc  near
               test FlagR,_HandR
               jz ExitHandR
               mov  FlagARRPV,_ClearARRPV
               call NomD_Pos
               call OutImage
               call  OutDigInf
               test FlagRes&RR,_Start
               jz ExitHandR
               mov cl,NomHEX
               test FlagPD,_BackPD
               jz Add_1_Nom
               cmp cl,MinNom
               jz ExitHandR
               dec cl
               push cx
               call DemDiaposBack
               pop cx
               jmp NextHandR
     Add_1_Nom:cmp cl,MaxNom
               jz ExitHandR
               inc cl
               push cx
               call DemDiaposNext
               pop cx
    NextHandR: mov al,cl
               mov NomHEX,al
               call  hex_bcd
               mov NomBCD,al                                 
     ExitHandR:ret
HandR      endp     

AutoR     proc  near
               test FlagR,_AutoR
               jz ExitAutoR
               call OutImage
               call  OutDigInf
               
               and FlagARRPV,_NextAutoR
               test FlagARRPV,_NextAutoR
               Jnz NextAutoR 
               test FlagRes&RR,_Start
               jz ExitAutoR 
               mov FlagARRPV,_NextAutoR
               Jmp ExitAutoR
     
     NextAutoR:mov cl,NomHEX
               test FlagPD,_BackPD
               jz _Add_1_Nom
               cmp cl,MinNom
               jz ExitAutoR
               dec cl
               push cx
               call DemDiaposBack
               pop cx
               jmp NextAutoR2
    _Add_1_Nom:cmp cl,MaxNom
               jz ExitAutoR
               inc cl
               push cx
               call DemDiaposNext
               pop cx
    NextAutoR2:mov al,cl
               mov NomHEX,al
               call  hex_bcd
               mov NomBCD,al 
               call NomD_Pos
               xor cx,cx
               xor ax,ax
               mov al,DelayHEX
               mov cl,4
               shl ax,cl
               mov cx,ax
NextDelayAutoR:
               call Delay1_16sec
               test FlagR,_AutoR            ;Если выбран другой режим
               jz ExitAutoR
                push cx          
               call OutImage
               pop cx
               loop NextDelayAutoR
     ExitAutoR:ret                
AutoR     endp    

Random proc  near
             push ax
  NextRandom:mov ax,RandomConst1
             add ax,RandomConst2
             mov RandomConst1,ax
             add ax,RandomConst3
             mov RandomConst2,ax
             rcl ax,1
             xor ax,8000h
             mov RandomConst3,ax
             and al,0111111b   
             cmp al,40
             ja NextRandom   
             cmp al,0
             Jz NextRandom    
             mov NomRandom,al     
             pop ax
             ret
Random      endp 

RandomR    proc  near
                   test FlagR,_RandomR
                   jz ExitRandomR
              
                   call OutImage
                   call  OutDigInf
                   call NomD_Pos
                   and FlagARRPV,_NextRandomR
                   test FlagARRPV,_NextRandomR
                   Jnz NextRandomR 
                   test FlagRes&RR,_Start
                   jz ExitRandomR
                   mov FlagARRPV,_NextRandomR
                  Jmp ExitRandomR
              
              
                   
      NextRandomR: mov al,NomHEX
                   cmp al,NomRandom
                   jb NomHEX_Men_NomRandom         ;NomHEX<NomRandom
                   ja NomHEX_Bol_NomRandom          ;NomHEX>NomRandom
                   jmp ExitRandomR
NomHEX_Men_NomRandom:mov al,NomRandom
                   sub al,NomHEX
                   push ax  
                   mov  al,NomRandom          
                   call  hex_bcd
                   mov NomBCD,al 
                   call TolLeft
                                         
                   pop ax 
                   xor cx,cx
                   mov cl,al                          
       IncNomNext:push cx
                   call DiamagRotateRight 
                   call Delay1_16sec 
                   call Delay1_16sec
                   call  ClearOutPort   
                   inc NomHEX 
                   call NomD_Pos
                   pop cx                         
                   loop IncNomNext  
                   Jmp NextRandomR2
 NomHEX_Bol_NomRandom:mov al,NomHEX
                   sub al,NomRandom
                   push ax  
                   mov  al,NomRandom          
                   call  hex_bcd
                   mov NomBCD,al 
                   call TolLeft
                   pop ax 
                   xor cx,cx
                   mov cl,al                          
       DecNomNext :push cx
                   call DiamagRotateLeft 
                   call Delay1_16sec 
                   call Delay1_16sec
                   call  ClearOutPort   
                   Dec NomHEX 
                   call NomD_Pos
                   pop cx                         
                   loop DecNomNext   
                                        
      NextRandomR2:call TolRight
                   xor ax,ax
                   mov al,DelayHEX
                   mov cl,4
                   shl ax,cl
                   mov cx,ax
  NextDelayRandomR:call Delay1_16sec
                   test FlagR,_RandomR
                   jz ExitRandomR                  ; если выбран другой режим
                   push cx           
                   call OutImage
                   pop cx
                   loop NextDelayRandomR
       ExitRandomR:ret
RandomR         endp        

Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,Code
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           in al,40h
           call   Init
           
 startprog:call   ScanButton
           call   ScanTime 
                 
           call   Res 
           call   HandR 
           call   AutoR
           call   RandomR
           call   Random
           jmp startprog



           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
