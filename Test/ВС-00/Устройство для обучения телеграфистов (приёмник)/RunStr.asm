.386
;� � (c)� (r)��� ��" � � (c)� �
RomSize      EQU 4096
Point        EQU 15
MaxLenght    EQU 80  
MaxMessCount EQU 5
Input        EQU 0
      
IntTable   SEGMENT AT 0 use16
;����� � ���� ����  ���  (r)�� �(r)�稪(r)� ���� ��(c)
IntTable   ENDS

Data       SEGMENT AT 40h use16
;����� � ���� ���� (r)��� ��� ��६�����
 ArrMess    db MaxMessCount dup(MaxLenght dup(?)) ;� �ᨢ �(r)(r)�饭�(c) 
 CurDisp    db 8 dup(?)         ;� �ᨢ (r)�(r)�� ����� 
 BtnDown    db ?    ;�"��"�(r)��� � � ��/ 
 BtnUp      db ?    ;                     ��� � �� ��(r)��� 
 CurChar    dw ?    ;⥪��(c)  ᨬ�(r)"   
 Mode       db ?    ;�(r)���(r)� ��� (0 - ��(r)�, 1 - �� ��)
 CharNum    db ?    ;�(r)��� ᨬ�(r)"  � �(r)(r)�饭��
 MessNum    db ?    ;�(r)��� ⥪�饣(r) �(r)(r)�饭��
 BtnState   db ?    ;�(r)��(r)ﭨ� ��(r)�(r)�   
 LenghtMess db ?    ;�"���  ⥪�饣(r) �(r)(r)�饭��  
 temp       db ?
 time       dw ?
 Chr        dw ?
 BeginMess  db ?   
Data       ENDS

;� � (c)� ��(r)��(r)����(c)  ��� �⥪ 
Stk        SEGMENT AT 100h use16
;� � (c)� ��(r)��(r)����(c) � ���� �⥪ 
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
;����� � ���� ���� (r)��� ��� �(r)��� ��
Image:     
           db  000h, 0F0h, 028h, 024h, 022h, 022h, 0FCh, 000h   ;a 0      ; ��� �� ��� ᨬ�(r)"(r)� �"� (r)�(r)�� ����� �  � ��"�
           db  000h, 0FEh, 092h, 092h, 092h, 092h, 062h, 000h   ;� 1
           db  000h, 0FEh, 092h, 092h, 092h, 092h, 06Ch, 000h   ;� 2
           db  000h, 0FEh, 002h, 002h, 002h, 002h, 002h, 000h   ;� 3
           db  000h, 0C0h, 07Ch, 042h, 042h, 07Eh, 0C0h, 000h   ;� 4
           db  000h, 0FEh, 092h, 092h, 092h, 092h, 082h, 000h   ;� 5
           db  000h, 0C6h, 028h, 010h, 0FEh, 010h, 028h, 0C6h   ;� 6
           db  000h, 044h, 082h, 082h, 092h, 092h, 06Ch, 000h   ;� 7
           db  000h, 0FEh, 040h, 020h, 010h, 008h, 0FEh, 000h   ;� 8
           db  000h, 0FEh, 040h, 021h, 011h, 008h, 0FEh, 000h   ;(c) 9
           db  000h, 0FEh, 020h, 010h, 028h, 044h, 082h, 000h   ;k 10
           db  000h, 0F0h, 008h, 004h, 002h, 002h, 0FCh, 000h   ;" 11
           db  000h, 0FEh, 004h, 008h, 010h, 008h, 004h, 0FEh   ;� 12
           db  000h, 0FEh, 010h, 010h, 010h, 010h, 0FEh, 000h   ;� 13
           db  000h, 07Ch, 082h, 082h, 082h, 082h, 07Ch, 000h   ;(r) 14
           db  000h, 0FEh, 002h, 002h, 002h, 002h, 0FEh, 000h   ;� 15
           db  000h, 0FEh, 012h, 012h, 012h, 012h, 00Ch, 000h   ;� 16
           db  000h, 07Ch, 082h, 082h, 082h, 082h, 044h, 000h   ;� 17 
           db  000h, 002h, 002h, 002h, 0FEh, 002h, 002h, 002h   ;� 18
           db  000h, 00Eh, 090h, 090h, 090h, 090h, 07Eh, 000h   ;� 19
           db  000h, 00Ch, 012h, 012h, 0FEh, 012h, 012h, 00Ch   ;� 20 
           db  000h, 082h, 044h, 028h, 010h, 028h, 044h, 082h   ;� 21
           db  000h, 07Eh, 040h, 040h, 040h, 07Eh, 0C0h, 000h   ;� 22
           db  000h, 00Eh, 010h, 010h, 010h, 010h, 0FEh, 000h   ;� 23
           db  000h, 0FEh, 080h, 080h, 0FCh, 080h, 080h, 0FEh   ;� 24
           db  000h, 07Eh, 040h, 07Eh, 040h, 07Eh, 0C0h, 000h   ;� 25
           db  000h, 0FEh, 090h, 090h, 090h, 090h, 060h, 000h   ;� 26
           db  000h, 0FEh, 090h, 090h, 060h, 000h, 0FEh, 000h   ;� 27
           db  000h, 082h, 082h, 092h, 092h, 092h, 07Ch, 000h   ;� 28
           db  000h, 0FEh, 010h, 07Ch, 082h, 082h, 07Ch, 000h   ;� 29
           db  000h, 08Ch, 052h, 032h, 012h, 012h, 0FEh, 000h   ;� 30
           db  000h, 010h, 088h, 084h, 0FEh, 080h, 080h, 000h   ;1 31
           db  000h, 0C4h, 0A2h, 0A2h, 092h, 092h, 08Ch, 000h   ;2 32
           db  000h, 082h, 092h, 092h, 092h, 092h, 06Ch, 000h   ;3 33
           db  000h, 01Eh, 010h, 010h, 010h, 010h, 0FEh, 000h   ;4 34
           db  000h, 05Eh, 092h, 092h, 092h, 092h, 062h, 000h   ;5 35
           db  000h, 07Ch, 092h, 092h, 092h, 092h, 064h, 000h   ;6 36
           db  000h, 002h, 002h, 0C2h, 022h, 012h, 00Eh, 000h   ;7 37
           db  000h, 06Ch, 092h, 092h, 092h, 092h, 06Ch, 000h   ;8 38
           db  000h, 04Ch, 092h, 092h, 092h, 092h, 07Ch, 000h   ;9 39
           db  000h, 07Ch, 0C2h, 0A2h, 092h, 08Ah, 07Ch, 000h   ;0 40
           db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h   ;_ 41 
           db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h   ;_ 42
           
Morze:     dw  00000110b, 10010101b, 00011010b, 101001b, 100101b         ;����  "� ��� � �(r)�� �(r)৥
           dw  1b, 01010110b, 10100101b, 0101b, 01101010b, 100110b
           dw  01100101b, 1010b, 1001b, 101010b, 01101001b, 011001b
           dw  010101b, 10b, 010110b, 01011001b, 01010101b, 10011001b
           dw  10101001b, 10101010b, 10100110b, 10010110b, 10011010b
           dw  0101100101b, 01011010b, 01100110b, 0110101010b
           dw  0101101010b, 0101011010b, 0101010110b, 0101010101b
           dw  1001010101b, 1010010101b, 1010100101b, 1010101001b, 1010101010b
           dw  0b, 0110101001b
            
           
InitData   ENDS

Code       SEGMENT use16
;����� � ���� ���� (r)��� ��� �(r)��� ��

           ASSUME cs:Code,ds:Data,es:InitData
Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,InitData
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
;����� � ���� ���� �(r)� ��(r)�� ���
           
           call  VarInit 
strt:      call  StartCode
           call  BtnClick
           call  StopCode
           call  PrevNextMess
           call  ViewMess 
           call  DispMess 
           jmp   strt

PrevNextMess   proc  near
           
           in    al,Input                  ;०�� ��(r)� (0 - Stop, 1 - Start) 
           test  al, 100000b
           jz    ExitPNM
           

           test al, 1000b              
           jz   PNM1 
           test BtnState,1000b
           jnz  ExitPNM
           cmp  MessNum, 0            
           jne  PNM2
           mov  MessNum, MaxMessCount   
PNM2:      dec  MessNum   
           mov  CharNum,0             
           call ClearMess
           call ClearDisp          
           mov  BtnState,al
          jmp  ExitPNM 

PNM1:      test al,10000b              
           jz   PNM4 
           test BtnState,10000b
           jnz  ExitPNM
           cmp  MessNum, MaxMessCount-1            
           jne  PNM5
           mov  MessNum, 0ffh         
PNM5:      inc  MessNum   
           mov  CharNum,0            
           call ClearMess
           call ClearDisp          
           mov  BtnState,al
           jmp  ExitPNM

PNM4:      mov   BtnState,0                       
ExitPNM:             
           ret
           endp




StopCode   proc  near
           in    al,Input                  ;०�� ��(r)� (0 - Stop, 1 - Start) 
           test  al, 100000b
           jnz   stpc4
           mov   al,1000000b
           out   3,al  
           in    al,Input
           test  al,100b
           jz    stpc1
           call  ClearDisp
stpc1:     mov   BeginMess,0
           cmp   Mode,1
           jne   stpc2
           cmp   CharNum,8
           jb    stpc3
           sub   CharNum,8   
           jmp   stpc2    
stpc3:     mov   CharNum,0
stpc2:     mov   Mode,0 
stpc4:     ret
StopCode   endp  
           
StartCode  proc near
           in    al,Input                  ;०�� ��(r)� (0 - Stop, 1 - Start) 
           test  al, 100000b
           jz    sc3
           mov   al,10000000b
           out   3,al 
           cmp   Mode,0                
           jne   sc2
           in    al,Input
           test  al,100b
           jnz   sc1
           call  ClearMess
sc1:       call  ClearDisp
           mov   BtnDown,0
           mov   BtnUp,1
           mov   CurChar,0
sc2:       mov   Mode,1
sc3:       ret
StartCode  endp  
           
           
ViewMess   proc near
           push ax
           push bx
           push di
           push si
           push dx
           
           in    al,Input                  ;०�� ��(r)� (0 - Stop, 1 - Start) 
           test  al, 100000b
           jnz   my2
           
           in   al,0

           test al,1b                 ;��(r)�(r)�� �(r)(r)�饭�� �"��(r)   
           jz   m68 
           cmp  CharNum, 0            ;��(r)���  �  � � "(r) ���(r)��
           je   my2                   ;��"� � � "(r) ���(r)�� �(r) �"��(r) �(r)"�� �� ��(r)� �ਢ ��  
           test BtnState,1b
           jnz  my2
           dec  CharNum    
           mov  BtnState,al
           jmp  my 
           
m68:       test al,10b                ;��(r)�(r)�� �(r)(r)�饭�� ��� �(r)   
           jz   m66 
           call MessLenght
           mov  ah, LenghtMess
           sub  ah, CharNum
           cmp  ah, 8           ;��(r)���  �  � � "(r) ���(r)��
           jbe  my2                   ;��"� �(r)��� ���(r)�� �(r) ��� �(r) �(r)"�� �� ��(r)� �ਢ ��  
           test BtnState,10b
           jnz  my2
           inc  CharNum
           mov  BtnState,al
           jmp  my
 
          
m66:       test al, 1000b             ;��(r)�(r)�� �।��饣(r) �(r)(r)�饭��    
           jz   m67 
           test BtnState,1000b
           jnz  m64
           cmp  MessNum, 0            ;...�"� �(r)(r)�饭�� ���(r)�
           jne  m62
           mov  MessNum, MaxMessCount ;�(r) �।��騬 �㤥� �(r)�"�����  
m62:       dec  MessNum   
           mov  CharNum,0             ;����(r)��� �  � � "(r) �(r)�(r)(c) ���(r)��           
           mov  BtnState,al
my:        jmp  m61 
my2:       jmp  m64 

m67:       test al,10000b              ;��(r)�(r)�� c"����饣(r) �(r)(r)�饭��    
           jz   m60 
           test BtnState,10000b
           jnz  m64
           cmp  MessNum, MaxMessCount-1            ;...�"� �(r)(r)�饭�� �(r)�"�����
           jne  m63
           mov  MessNum, 0ffh         ;�(r) �"����騬 �㤥� ���(r)�  
m63:       inc  MessNum   
           mov  CharNum,0             ;����(r)��� �  � � "(r) �(r)�(r)(c) ���(r)��           
           mov  BtnState,al
           jmp  m61 
     
m60:       mov   BtnState,0                       
m61:       
                                   ;� � ��ᨬ(r)�� (r)� �(r)"�祭��� �(r)���  ᨬ�(r)"  � �(r)���  ���(r)��
           lea   bx, ArrMess         ;� ��� �� � � �ᨢ (r)�(r)�� ����� �㦭�(c) ���(r)� ���(r)�� 
           lea   si, ArrMess 
           mov   ah, 0
           mov   al, CharNum    
           add   si, ax
           mov   al, MaxLenght
           mul   MessNum
           add   bx, ax
           lea   di, CurDisp
           
           mov   cx, 8
m65:       mov   dl, ArrMess[bx][si]
           mov   [di],dl 
           inc   di 
           inc   si  
           loop  m65
           
m64:       pop   dx
           pop   si
           pop   di
           pop   bx
           pop   ax 
           ret
           endp

ClearMess  proc near
           push  ax                ;(r)���  ⥪�饣(r) �(r)(r)�饭��           
           push  bx
           push  cx
           push  si
           lea   bx, ArrMess
           lea   si, ArrMess 

           mov   al, MaxLenght
           mul   MessNum
           add   bx, ax
           mov   cx, MaxLenght
clear1:           
           mov   ArrMess[bx][si], 41
           inc   si
           loop  clear1
           
           mov  CharNum, 0 
           pop  si
           pop  cx
           pop  bx
           pop  ax           
           ret
           endp
           
ClearDisp  proc near      
           push bx
           push cx     
           lea  bx, CurDisp 
           mov  cx, 8
clear2:    mov  [bx],41 
           inc  bx
           loop clear2
           pop cx
           pop bx
           ret           
           endp

Delay      proc near
           push  ax
           push  cx
           mov  cx,time
D1:        mov  al,temp
           out  3, al
           loop D1
           pop  cx
           pop  ax
           ret
           endp 

MessLenght proc near
           push ax
           push bx
           push si
           push di
           
           mov   LenghtMess, MaxLenght
           lea   bx, ArrMess
           lea   si, ArrMess 
           add   si, MaxLenght-1 
           mov   al, MaxLenght
           mul   MessNum
           add   bx, ax
ML1:           
           cmp   ArrMess[bx][si], 41
           jne   MLExit
           dec   si
           dec   LenghtMess
           cmp   Lenghtmess,0
           je    MLExit  
           jmp   ML1 
MLExit:    
           pop di
           pop si
           pop bx
           pop ax        
           ret
           endp           
                        


  
VarInit    proc  near             ;���� "�� �� ��� ��६�����
          
           lea   bx, ArrMess
           lea   si, ArrMess  
           mov   dl,0
           mov   dh,0
           mov   cx, MaxLenght*MaxMessCount
m01:       mov   ArrMess[bx][si], 41
           inc   si
           inc   dl
          
           cmp   dl, MaxLenght
           jne   m02
           mov   dl,0
           add   bx, MaxLenght
           lea   si, ArrMess
m02:       loop  m01
           
           lea   bx, CurDisp
           mov   cx,8
m0:        mov   [bx],41
           inc   bx             
           loop  m0
           mov   BtnDown, 0
           mov   BtnUp, 0
           mov   CurChar, 0
           mov   CharNum, 0
           mov   MessNum, 0
           mov   BtnState,0
           mov   Mode,0
           mov   BeginMess,0
           ret
           endp
           
           
BtnClick   proc  near            ;��� �(r)�稪 � � ��/��� � �� �"�� 
           push  ax
           push  dx
           push  bx
           in    al,0                 ;०�� ��(r)� (0 - Stop, 1 - Start) 
           test  al, 100000b
           jnz   m18
           jmp   m16
m18:          
           mov   dl, BtnDown
           mov   dh, BtnUp
           
           in    al,0
     
           test  al,80h
           jz    m11 
           mov   BeginMess,1   
           mov   dh,0
           inc   dl                ;""��"�(r)��� � � �� ��(r)���
           jmp   m12   

m11:       inc   dh                ;""��"�(r)��� ��� � �� ��(r)���
           cmp   dh,50             
           jb    m12
           cmp   BeginMess,0
           je    m17  
           call  AddChar
m17:       mov   dh,2
            
m12:       cmp   dh,1              
           jne   m14               ;��"� ��(r)��  �� � � � 
           cmp   dl,0
           je    m14
                                    ;'(r)�  �"� ��?  
           cmp   dl, Point              
           jb    m13
           mov   dl,0               ;(r)���"塞 �"��"�(r)��� � � ��
           mov   ax,CurChar         
           shl   ax,2
           add   ax,10b                  ;��
           mov   CurChar,ax
           jmp   m14
              
m13:                                ;�(r)� 
           mov   dl,0               ;(r)���"塞 �"��"�(r)��� � � ��
           mov   ax,CurChar
           shl   ax,2
           add   ax, 01b 
           mov   CurChar,ax

m14:       in    al,0
           test  al,100b              ;��(r)���  ��� ��(r)�(r) ०�� (0 - (r)�"(r)�����(c), 1 - ���(r)�।�⢥���(c))
           jz    m15
           out   3,al  
m15:
           mov   BtnUp,   dh
           mov   BtnDown, dl
m16:
           pop   bx  
           pop   dx
           pop   ax   
           ret
BtnClick   endp
           
AddChar    proc  near            ;"(r)� �"���� (r)�।�(r)�(r) ᨬ�(r)"  � ⥪�饬� �(r)(r)�饭��
           push  bx
           push  ax  
           push  dx 
           push  cx
           push  si
           push  di
           
           mov   dl,0
           mov   ax, Curchar
           lea   bx, Morze  

m23:       inc   dl
           cmp   dl,44
           je    m22
           cmp   ax,es:[bx] 
           jne   m21
           dec   dl 

           cmp   dl, 41
           je    m25

           lea   bx, CurDisp
        
           mov   cx, 7 
m24:       mov   al,[bx+1] 
           mov   [bx], al
           inc   bx
           loop  m24
           mov   CurDisp[7], dl 

 
           in    al,0
           test  al,100b              ;��(r)���  ��� ��(r)�(r) ०�� ( 0 - (r)�"(r)�����(c), 1 - ���(r)�।�⢥���(c))
           jnz   m25
           lea   bx, ArrMess
           lea   si, ArrMess 
           mov   ah, 0
           mov   al, CharNum  
           add   si, ax
           mov   al, MaxLenght
           mul   MessNum
           add   bx, ax
           mov   ArrMess[bx][si], dl
           cmp   CharNum, MaxLenght
           jnb   m25 
           inc   CharNum 
           
m25:           
          
           jmp   m22
m21:              
           add   bx,2   
           jmp   m23

m22:       mov   CurChar, 0
           pop   di
           pop   si
           pop   cx
           pop   dx
           pop   ax
           pop   bx
           ret              
AddChar    endp   
           
DispMess   proc  near                  ;�(r)� � �� ⥪�饥 �(r)(r)�饭��
           push  ax
           push  bx
           push  cx
           push  dx          
           lea   bx,Image 
           mov   dl,10000000b 
           mov   ch,0

m2:        push  bx 
           lea   bx, CurDisp
           mov   ah,0
           mov   al,ch
           add   bx,ax
           mov   al,[bx]
           mov   ah,8
           mul   ah 
           pop   bx
           push  bx
           add   bx, ax    
           mov   al, 0
           out   0, al 
           mov   al,10000000b
           out   2, al
          
           inc   ch
           mov   cl,1
           mov   al,dl
           out   1,al
m1:        
           mov   al, 0
           out   0, al 
           mov   al,cl
           out   2, al
           mov   al,es:[bx]
           out   0, al
           inc   bx 
           shl   cl,1                 
           cmp   cl,0      
           jne   m1
           shr   dl,1
           pop   bx
           cmp   dl,0
           jne   m2
           pop   dx
           pop   cx
           pop   bx
           pop   ax          
           ret
DispMess   endp  

           call  VarInit 
strt:      call  StartCode
           call  BtnClick
           call  StopCode
           call  PrevNextMess
           call  ViewMess 
           call  DispMess 
           jmp   strt

        

;� �"�����(c) ���(r)�� ��(r)��(r)���(r) � � �� ᬥ饭�� �� ��(r)�(r)(c) �(r)窨
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
