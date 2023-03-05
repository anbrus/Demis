RomSize    EQU   4096        ;é°ÍÒ¨ èáì

NMax       EQU   50
KbdPort    EQU   10h

Data       SEGMENT AT 0
kon db ?
kon2     db ?  
kon3     db ?  
floor2 db ?
nach db ?
flag1 db ?
port   db ?   
flag2 db ?
flagHum          DB    ? 
flagError          DB    ? 
flagstop        DB    ? 
flagblin        DB    ? 
flag_podbor      DB    ? 
KbdImage         DB    4 DUP(?)
EmpKbd           DB    ?
KbdErr           DB    ?
NextDig          DB    ?
res              dw    ?
Flag             DB    ?
Data1            DB    3 DUP(?) 
sum              Db    3 dup(?)
result           DW    ? 
flag3           dw    ?
flagperegruzka    dw    ?
flagves          dw    ?
flagdver     dw    ?
wr   dw       ?
Data       ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,es:Code
Image   DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh

SymImages  DB    3h,2h,1h,0h,6h,5h,4h,0h,9h,8h,7h,0h,0Ah,0h,0Ah,0h           
ImageNum   DB    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,0Eh,07Fh,05Fh,03Fh


           
include    dvig.asm

podgotovka proc  near

           mov   ax,Code
           mov   es,ax
           mov   ax,Data
           mov   ds,ax
           mov   flag2,0
           mov   flag,0
           mov   flagError,0
           mov   flagstop,0
           mov   KbdErr,0
           mov flagblin,0 
           mov   result,0 
           mov   flag3,0
           mov   res,0
           mov   flagdver,0   
           mov flagperegruzka,0
           mov wr,0
                  
           lea   si,sum 
           lea   bx,data1
           mov   cx,3
m5:        mov   BYTE PTR[si],3
           mov   BYTE PTR[bx],0
           inc   si
           inc   bx
           loop  m5
           ret         
podgotovka endp

start:     call  podgotovka
           call  pervoe
            
         
         
begin:     call  button_vn_vv
           call  HumInLft 
           call  dvig
           call sader
           call  input
           call  opros_knopok
            call  button_vn_vv2  
           call  dvig2
           jmp   begin
           
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
