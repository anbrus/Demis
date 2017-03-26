RomSize    equ  4096

IntTable   Segment at 00000h
IntTable   EndS

Code       Segment
           assume cs:Code
Start:
           mov  ax,IntTable
           mov  ds,ax
           mov  ds:[8*4+0],Offset Int8Handler
           mov  ds:[8*4+2],cs
InfLoop:
           jmp  InfLoop

Int8Handler:
           mov  al,0FFh
           out  0,al
           iret
           
           org  RomSize-10h
           assume cs:Nothing
           
           jmp  Far Ptr Start
           
Code       EndS
End