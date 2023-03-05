RomSize         EQU   4096

DispInPort       EQU   0          ; ���� ��ᯫ�� 
KeyInPort        EQU   0          ; ���� ������
KeyLinePort      EQU   8          ; ���� ��⨢��� ����� ����������

Data       SEGMENT AT 2000h 
           NextKbLine   db ?
           Indicator    db ?
           ready        db ?
           totalblocks  db ?
           errorblocks  db ?

           regadr       dw ?
           ofsadr       dw ?
           segbegin     dw ?
           segend       dw ?
           offsetbegin  dw ?
           offsetend    dw ?
           
           nextgran     db ?
           csumm_dop    db ?
           csumm        db ? 
           press        db ?
           vid          db ?
           sost         db ?
           reslt        db ?
           totaldeadadr dw ?
           currentdead  dw ?           
           deadaddr     dw 512 DUP(?)                       
Data       ENDS

Stk        SEGMENT AT 1000h
           dw    10 dup (?)
StkTop     Label Word
Stk        ENDS

Code       SEGMENT
           ASSUME cs:Code,ds:Data,ss:Stk           
           Obraz db 03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh,06Fh,079h,033h,07Ch,073h,063h           
           AdrHex db 00h,01h,02h,03h,04h,05h,06h,07h,08h,09h,0Ah,0Bh,0Ch,0Dh,0Eh,0Fh
Init PROC NEAR                  ;��⠭���� ��砫��� ���祭�� ��६�����

           mov   Ready,0
           mov   NextKbLine,1
           mov   indicator,5
           mov   regadr,0
           mov   ofsadr,0           
           mov   currentdead,0           
           mov   totaldeadadr,0
           mov   segbegin,0
           mov   segend,0
           mov   offsetbegin,0
           mov   offsetend,0
           mov   vid,0
           mov   csumm_dop,0
           mov   csumm,-1
           mov   nextgran,0
           mov   reslt,-1
           mov   sost,1
           mov   al,0
           out   9,al 
           mov   cx,length deadaddr    
ini:       mov   si,cx
           mov   deadaddr[si],0
           loop  ini
           xor   si,si
           ret
Init ENDP


CheckSost  PROC NEAR             ; �⮡ࠦ���� ⥪�饣� ���ﭨ�
           push  ax           
           mov   al,Sost
           out   7,al                      
           pop   ax
           ret
CheckSost  ENDP


Statistic  PROC NEAR             ; �⮡ࠦ���� ����⨪� �஢�७���/�訡���� ������
           push  ax bx di
           
           cmp  vid,0
           je   St1
           mov  al,errorblocks
           jmp  St2
St1:       mov  al,totalblocks
St2:       AAM
           mov bx,ax
           xor ax,ax           
           mov al,bh           
           mov di,ax
           mov al,Obraz[di]
           out 6,al

           mov al,bl           
           mov di,ax
           mov al,Obraz[di]
           out 5,al         

           pop  di bx ax
           ret  
Statistic  ENDP



KeyInput  PROC NEAR               
           push  ax bx dx cx
           
           mov   al,NextKbLine
           shl   al,1
           cmp   al,10000b
           jne   Key0
           mov   al,1
           
Key0:      mov   NextKbLine,al
           out   KeyLinePort,al  
           
           in    al,0
           call  Drebezg          
           mov   press,al
              
Key1:      in    al,0
           cmp   al,0
           jne   Key1           
           mov   al,press           
                     
           cmp   al,20h            ;����� "����"
           jne   Key2              ;  
                  
           call  ClearDisp         ;  
           call  Init              ;        
           jmp   ExBl              ;
           
Key2:      cmp   al,0              ; ��室 
           je    Exit_k            ; �᫨ 
           cmp   Sost,0ffh         ; ��祣� �� �����
           je    Exit_k            ;
                      
           cmp   al,40h            ; ����� "����"
           jne   Key5              ; ec�� ��� - ��室           

           call  ClearDisp         ; ������� ⠡��                        
           cmp   nextgran,1        
           je    Key3                      
           mov   nextgran,1
           mov   ax,regadr
           mov   segbegin,ax           
           mov   ax,ofsadr
           mov   offsetbegin,ax                         
           mov   al,1              ; ���������� �����窠
           out   9,al              ; ��ࢮ� ��������� �࠭���                      
           mov   Indicator,5
Exit_k:    jmp   ExBl           
   
Key3:      push  ax
           mov   nextgran,2          
           mov   ax,regadr  
           mov   segend,ax
           mov   ax,ofsadr           
           mov   offsetend,ax     
           mov   Sost,1      
           mov   ready,1
                                   ; �஢�ઠ ���४⭮�� ��������� �࠭�� �����  
           mov   ax, segbegin
           cmp   ax, segend
           ja    Key8
           cmp   ax, segend
           jne   Key4 
           mov   ax, offsetbegin
           cmp   ax, offsetend   
           jb    Key4           
key8:      mov   Sost,0ffh           
           mov   ready,0
           
Key4:      mov   al,3              ; ���������� �����窠
           out   9,al              ; ��ன ��������� �࠭���           
           pop   ax                                      
           jmp   ExBl

Key5:      cmp   al,80h
           jne   Key6
           mov   totalblocks,0
           mov   errorblocks,0
           jmp   ExBl
           
Key6:      call  KbInput           ;������ ������ ����������                                                  
ExBl:      pop   dx cx bx ax
           ret
KeyInput ENDP



OtherInput PROC NEAR
           push  ax bx cx dx        
           in    al,KeyInPort+1
           
           mov   ah,al                      
Ot0:       in    al,KeyInPort+1   
           cmp   al,0
           jne   Ot0           
           mov   al,ah
           
           cmp   al,0
           je    ExInpTest
           cmp   Sost,0ffh
           je    ExInpTest
           
           xor   cx,cx
Ot1:       cmp   al,1
           je    Ot2
           shr   al,1
           add   cx,1
           jmp   Ot1
                
Ot2:       mov   al,11b                                
           out   9,al
           mov   ax,cx
           lea   bx,Base
           mov   cl,3
           shl   ax,cl
           add   ax,bx
           jmp   ax
           
Base:      
           call  SubDead     ;�����  "<"
           jmp   ExInpTest                            
           NOP  
           NOP  
           NOP  
           call  AddDead     ;�����  ">"
           jmp   ExInpTest              
           NOP  
           NOP                                    
           NOP  
           call  Test1          ;�����  "���� ��"
           jmp   ExInpTest                         
           NOP  
           NOP  
           NOP                                   
           call  Calc_Dop       ;�����  "������ ���. � �����. �㬬�"
           jmp   ExInpTest 
           NOP  
           NOP  
           NOP                              
           call  Test2          ;�����  "���� ��"
           jmp   ExInpTest       
           NOP  
           NOP  
           NOP                        
           call  Test3          ;�����  "���� ���"
           jmp   ExInpTest            
           NOP  
           NOP  
           NOP                                         
           mov   vid,0          ;�����  "�஢�७�"
           jmp   ExInpTest                  
           NOP  
           NOP  
           NOP                        
           mov   vid,1          ;�����  "� �訡����"
           jmp   ExInpTest                  
                                
ExInpTest: pop   dx cx bx ax
           ret
OtherInput ENDP


Mistmaches PROC NEAR
           cmp   Reslt,1
           jne   ExitMist           
           push  ax bx di si
           
           mov   di,currentdead
           mov   si,di
           
           mov   ax,deadaddr[si]           
           shr   ax,12
           mov   di,ax
           mov   al,Obraz[Di]
           out   DispInPort+4,al                                           
           
           mov   ax,deadaddr[si+2]                       
           shr   ax,8
           xor   ah,ah
           shr   ax,4
           xor   ah,ah           
           mov   di,ax
           mov   al,Obraz[di]  
           out   DispInPort+3,al                                                      

           mov   ax,deadaddr[si+2]                       
           shr   ax,4
           xor   ah,ah
           shr   ax,4
           xor   ah,ah           
           mov   di,ax
           mov   al,Obraz[di]  
           out   DispInPort+2,al                                                      

           jmp   Mis1
           
ExitMist:  jmp   ExMist
                      
Mis1:      mov   ax,deadaddr[si+2]                       
           xor   ah,ah
           shr   ax,4
           xor   ah,ah           
           mov   di,ax
           mov   al,Obraz[di]  
           out   DispInPort+1,al                                                      

           mov   ax,deadaddr[si+2]                       
           xor   ah,ah
           shl   ax,4
           xor   ah,ah           
           shr   ax,4           
           xor   ah,ah                      
           mov   di,ax
           mov   al,Obraz[di]  
           out   DispInPort,al                                                      
                      
           pop  si di bx ax
ExMist:    ret
Mistmaches ENDP


; �᭮���� �ணࠬ��
include tests.asm 
include system.asm     

Start:
           mov   ax,Data            ; ���⥬��� �����⮢��,
           mov   ds,ax              ; ���樠������ ���祭��            
           mov   es,ax              ; ᥣ������ ॣ���஢
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop                        

           mov totalblocks,0
           mov errorblocks,0           
           call  Init               ; ���樠������ ��砫��� ���祭�� ��६�����
                                 
L0:       
           call  CheckSost          ; �⮡ࠦ���� ⥪�饣� ���ﭨ�
           call  Statistic          ; �⮡ࠦ���� ����⨪� �஢�७���/�訡���� ������           
           call  KeyInput           ; ���� ������ ���������� � ������ "����", "����"
                                    ; "����� ���� �����"            
           call  OtherInput         ; ���� ������ ������ �롮� ���, "<", ">", 
                                    ; "�஢�७�", "� �訡����"                                    
           call  Mistmaches         ; ��ᬮ�� �訡��, �᫨ ��� ��, �� �����襭 � �訡����
           
           jmp   L0
                   
           ; ����� ���� ���⮢�� �窨 �ணࠬ��        
           org   RomSize-16
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
