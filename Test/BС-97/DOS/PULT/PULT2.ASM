; *************************************************************

; ����ன�� 1-��� ������
MinTime1      equ 10           ;�������쭮� �६� ����᪠ (� ᥪ)  
MaxTime1      equ 600  	      ;���ᨬ��쭮� �६� ����᪠ (� ᥪ) 	
FlashTime1    equ 4            ;�६� ����� ࠪ��� (� ᥪ)            

; ����ன�� 2-��� ������
MinTime2      equ 10           ;�������쭮� �६� ����᪠ (� ᥪ) 
MaxTime2      equ 600  	      ;���ᨬ��쭮� �६� ����᪠ (� ᥪ) 	
FlashTime2    equ 4            ;�६� ����� ࠪ��� (� ᥪ)            


TremorFade   equ 1            ;����⠭� ������� ���뢠��� ��� 
                              ;��襭�� �ॡ����

MaxTimeCount equ 2            ;����⠭� ᥪ㭤��� ����প�


Flash        equ 1            ;����⠭� ������� ᢥ⮤�����
; ************************************************************


Empty        equ 20;

DataSegm segment

;            0   1    2   3   4   5   6   7   8   9   a   b  c   d   e   f

tablcode db 3fh,0ch,76h,5eh,4dh,5bh,7bh,0eh,7fh,5fh,00h,0ffh,00h,00h,00h,40h


KbdImg          dw      ?       ;��ࠧ ����������
KeyCode         db      ?       ;��� ����⮩ ������
IndImg          db      8 dup(1);��ࠧ �������஢
Mode1           db      ?       ;०�� �㭪樮��஢���� ���ன�⢠
Mode2           db      ?       ;०�� �㭪樮��஢���� ���ன�⢠

Flag            db      ?       ; 00 - ���� � 1 

TimeCounter1    dw      ?       ;���稪 �६���
TimeCounter2    dw      ?       ;���稪 �६���
TimeCounter11   dw      ?       ;���稪 �६���
TimeCounter22   dw      ?       ;���稪 �६���
Time1    	dw      ?       
Time2    	dw      ?       
Time11    	dw      ?       
Time22          dw      ?       
OldKbdImg       dw      0       ;���� ��ࠧ ����������

DataSegm ends

CodeSegm segment
assume cs:CodeSegm, ds:DataSegm ,es:DataSegm

TimeCount proc            ; bx - ���� TimeCounter
                          ; dx - ���� Time
                push ax    
                push bx    
                push cx    
                push dx

                dec word ptr [bx]                      ;  ��⠥� �६�
                jnz EndTC

                mov word ptr [bx],MaxTimeCount  ;��稭����� ᫥����� �����
                
                mov bx,dx
                cmp word ptr [bx],0
                jz TC1
                dec word ptr [bx]                     ;��諠 �����
          TC1:   

         EndTC: pop dx
                pop cx
                pop bx
                pop ax

                ret
TimeCount endp

SuperTimeCount proc

                cmp Mode1,1
         	jnz STC1

		lea bx,TimeCounter1
		lea dx,Time1
                call TimeCount 

     STC1:	cmp Mode2,1
         	jnz STC2
                 
           	lea bx,TimeCounter2
		lea dx,Time2
                call TimeCount  

     STC2:	lea bx,TimeCounter11
		lea dx,Time11
                call TimeCount 
   
		lea bx,TimeCounter22
		lea dx,Time22
                call TimeCount 

		ret                	 

SuperTimeCount endp

GetKbd proc                        ;����頥� � DX ��ࠧ ����������
                                   ;� �ଠ� KbdImg

                push ax
                push bx
                push cx

                in al,00h
                mov dl,al
                in al,01h
                mov dh,al
                not dx

                pop cx
                pop bx
                pop ax

                ret
GetKbd endp



ZeroCount proc                 ;������뢠�� ������⢮ �㫥��� ��⮢ � AX
                push cx        ;१���� - � BX
                push ax
                not ax
                mov cx,16      ;��⠫�� ॣ����� - ��� ���������
                mov bx,0       ;

      LoopZC:   ror ax,1       ;
                adc bx,0       ;
                loop LoopZC    ;
                pop ax
                pop cx
                ret
ZeroCount endp

FirstZero proc                 ;��।���� ����� ��ࢮ�� ��襭���� ���
                               ;��室��� ᫮�� - � AX,१���� - � BX
                               ;��⠫�� ॣ����� - ��� ���������

                push cx
                push ax

                mov cx,16      ;�� ����� 16 ࠧ
                mov bx,-1      ;��筥� � -1
       LoopFC:  inc bx         ;
                test ax,1    ;�஢�ਬ
                ror ax,1       ;ᤢ����
                loopnz LoopFc

                pop ax
                pop cx
                ret
FirstZero endp

                                ;************************************
                                ;************************************

Prepare proc                    ;�����⮢��
                mov TimeCounter1,MaxTimeCount    
                mov TimeCounter2,MaxTimeCount    
                mov TimeCounter11,MaxTimeCount    
                mov TimeCounter22,MaxTimeCount    
                mov Time1,0
                mov Time2,0
                mov Time11,0
                mov Time22,0
                mov Mode1,0
                mov Mode2,0
                mov Flag,0
                ret
Prepare endp

ReadKbd proc                          ;�⥭�� ����������
                                      ;� ��襭��� �ॡ����

                mov cx,TremorFade     ;᪮�쪮 ࠧ ������ ᮢ�����

        LoopRC: call GetKbd           ;���� ����������
                cmp dx,KbdImg         ;�஢��塞
                je NextRC

                mov cx,TremorFade     ;�� ᮢ���� - ��稭��� ������
                mov KbdImg,dx         ;   ᮢ������� ᭠砫�

        NextRC: loop LoopRC           ;�஢��塞 �� ࠧ

                ret
ReadKbd endp

DecodKbd proc                         ;����஢�� ����������

                mov KeyCode,Empty       ;�������� ���� ��砩

                mov ax,KbdImg

                call ZeroCount        ;᪮�쪮 ������ ����� ?
                cmp bx,2              ;�᫨ ��� ��� �����, � ��
                jns EndDK

                cmp ax,OldKbdImg      ;�᫨ ���ﭨ� ����������
                jz EndDK              ;�� ����������, � ��.

                mov OldKbdImg,ax      ;���������� ����� ���ﭨ� ����������

                cmp bx,0              ;� ����� ������ � ���� �� �����
                jz EndDK              ; � ���饭�. �᫨ ��, � ��

                call FirstZero        ;�᫨ ����� ���� ������ �
                mov KeyCode,bl        ;࠭�� ��� �뫠 ���饭�
                                      ;� ����塞 �� ���.
        EndDK: ret

DecodKbd endp

WaitMode1 proc
		
                cmp Mode1,0
                jnz NotWM1
                mov ah,KeyCode

                cmp ah,12            ;������� �� ������� "��� 1"
                jnz WM1_1
                mov TimeCounter1,MaxTimeCount
                mov Mode1,1

                cmp Time1,MinTime1
                ja  WM1_00
                mov Time1,MinTime1                 
    WM1_00: 
                cmp Time1,MaxTime1
                jb  WM1_0
                mov Time1,MaxTime1                 
    WM1_0: 

                jmp EndWM1

          WM1_1:  cmp ah,13            ;������� �� ������� "��⠭�� 1"
                jnz WM1_2
                mov Flag,0           
                jmp EndWM1

           WM1_2: cmp ah,9            ;������� �� ��஢� ������
                ja NotWM1
                cmp Flag,0
                jnz NotWM1

                mov ax,Time1        ;   ����� ����� �६� ����� ���
                mov dx,0            ;       ��ࢮ� ࠪ���
                mov bx,10
                mul bx
                mov bx,1000
                div bx
                mov cx,0
                add cl,KeyCode 
                add dx,cx
                mov Time1,dx

         EndWM1: mov KeyCode,Empty
         NotWM1: ret 
WaitMode1 endp

WaitMode2 proc
		
                cmp Mode2,0
                jnz NotWM2
                mov ah,KeyCode

                cmp ah,14            ;������� �� ������� "��� 2"
                jnz WM2_1
                mov TimeCounter2,MaxTimeCount
                mov Mode2,1

                cmp Time2,MinTime2
                ja  WM2_00
                mov Time2,MinTime2                 
    WM2_00: 
                cmp Time2,MaxTime2
                jb  WM2_0
                mov Time2,MaxTime2                 
    WM2_0: 

                jmp EndWM2

          WM2_1:  cmp ah,15            ;������� �� ������� "��⠭�� 2"
                jnz WM2_2
                mov Flag,1           
                jmp EndWM2

           WM2_2: cmp ah,9            ;������� �� ��஢� ������
                ja NotWM2
                cmp Flag,0
                jz NotWM2

                mov ax,Time2        ;   ����� ����� �६� 
                mov dx,0            ;   ����� ��� ��ன ࠪ���
                mov bx,10
                mul bx
                mov bx,1000
                div bx
                mov cx,0
                add cl,KeyCode 
                add dx,cx
                mov Time2,dx

         EndWM2: mov KeyCode,Empty
         NotWM2: ret 
WaitMode2 endp

BackMode1 proc
                cmp Mode1,1
                jnz NotBM1
                mov ah,KeyCode

        BM1_1:  cmp ah,13            ;������� �� ������� "��⠭�� 1"
                jnz BM1_2
                mov Mode1,0
                jmp EndBM1
        
        BM1_2:  cmp Time1,0
                jnz NotBM1
                mov Time11,FlashTime1
                mov TimeCounter11,MaxTimeCount
                mov Mode1,0 
                jmp NotBM1

        EndBM1: mov KeyCode,Empty
        NotBM1: ret 

BackMode1 endp

BackMode2 proc
                cmp Mode2,1
                jnz NotBM2
                mov ah,KeyCode

        BM2_1:  cmp ah,15            ;������� �� ������� "��⠭�� 2"
                jnz BM2_2
                mov Mode2,0
                jmp EndBM2
        
        BM2_2:  cmp Time2,0
                jnz NotBM2
                mov Time22,FlashTime2
                mov TimeCounter22,MaxTimeCount
                mov Mode2,0 
                jmp NotBM2

        EndBM2: mov KeyCode,Empty
        NotBM2: ret 

BackMode2 endp

FlagControl proc              

      cmp Mode1,0
      jnz FC1
      cmp Mode2,0
      jz FC1
      mov Flag,0
      jmp EndFC

FC1:  cmp Mode1,0
      jz EndFC
      cmp Mode2,0   
      jnz EndFC
      mov Flag,1 

      EndFC: ret
FlagControl endp

MakeImage proc
                cld                ;��頥� ��ࠧ
                mov al,0fh
                lea di,IndImg
                mov cx,7
          rep   stos IndImg
                
                mov ax,Time1
                mov dx,0
                mov bx,10
                div bx 
                mov IndImg[2],dl
                mov dx,0
                div bx
                mov IndImg[1],dl
                mov dx,0
                div bx
                mov IndImg[0],dl

                mov ax,Time2
                mov dx,0
                mov bx,10
                div bx 
                mov IndImg[5],dl
                mov dx,0
                div bx
                mov IndImg[4],dl
                mov dx,0
                div bx
                mov IndImg[3],dl

                mov ax,Time11
                or al,ah
                mov IndImg[6],al
                mov ax,Time22
                or al,ah
                mov IndImg[7],al
                

                ret
MakeImage endp


OutInd proc                     ;�뢮� ��ࠧ� �� ��������

                lea bx,tablcode

                mov al,IndImg[0]
                xlat
                out 02,al

                mov al,IndImg[1]
                xlat
                out 03,al

                mov al,IndImg[2]
                xlat
                out 04,al

                mov al,IndImg[3]
                xlat
                out 05,al

                mov al,IndImg[4]
                xlat
                out 06,al

                mov al,IndImg[5]
                xlat
                out 07,al


                mov dl,0

                cmp IndImg[6],0
                jz OI1  

                mov ax,TimeCounter11
                mov bl,Flash
                idiv bl
                test al,1
                jz OI00 
                or dl,00000010B
          	jmp OI01
     OI00:      or dl,00000001B
     OI01:	

     OI1:       cmp IndImg[7],0
                jz OI2  

                mov ax,TimeCounter22
                mov bl,Flash
                idiv bl
                test al,1
                jz OI12 
                or dl,00100000B
          	jmp OI13
     OI12:      or dl,00010000B
     OI13:	
                  
     OI2:       mov al,dl
                out 8,al

     OIEnd:     ret

OutInd endp
;**********************************
;**********************************
;�����஢���
Start:
                mov ax,DataSegm     
                mov ds,ax           
                mov es,ax 
          
                call Prepare        ;�����⮢��

MainLoop:
                 call SuperTimeCount      ;
                 call ReadKbd        ;�⥭�� ����������
                 call DecodKbd       ;����஢�� ����������
                 call WaitMode2       
                 call WaitMode1       
                 call BackMode1
                 call BackMode2 
                 call FlagControl

                 call MakeImage      ;�ନ஢���� ��ࠧ�

                 call OutInd         ;�뢮� �� ���������
                 jmp MainLoop


CodeSegm ends

end Start

