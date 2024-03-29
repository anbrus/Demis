TremorFade   equ 1            ;����⠭� ��襭�� �ॡ����
MaxTimeCount equ 4            ;            
MaxBilet     equ 3            ;
MaxVopros    equ 5            ;

DataSegm segment ;at 0ba00h

;            0   1    2   3   4   5   6   7   8   9   a   b  c   d   e   f

tablcode db 3fh,0ch,76h,5eh,4dh,5bh,7bh,0eh,7fh,5fh,00h,0ffh,00h,00h,00h,40h


KbdImg          dw      ?       ;��ࠧ ����������


KeyCode         db      ?       ;��� ����⮩ ������

FlagT1          db      ?       ;䫠� ��������� �㬡���

FlagT2          db      ?       ;䫠� ��������� �㬡���

IndImg          db     7  dup(?)  ;��ࠧ �������஢

Mode            db      ?       ;०�� �㭪樮��஢���� ���ன�⢠

Task            db      ?       ;����� �������-�����

Anser           db      ?       ;��� �⢥�

AllTask         db      ?       ;���稪 ��饣� ���-�� �������� ����ᮢ

OkTask          db      ?       ;���稪 ���-�� �ࠢ����� �⢥⮢

EndTest         db      ?       ;䫠� ᨣ���������騩 �� ����砭�� ���

Mark            db      ?       ;���⠢������ �業��

Time            dw      ?       ;�६� ���஢���� (���.)

TimeCounter     dw      ?       ;���稪 �६���

MaxTime         dw      ?       ;���ᨬ��쭮� �६� ���஢����  (���.)

MaxTask         db      ?       ;���ᨬ���� ����� ���

ArrTask         db  9*9  dup(?) ;���ᨢ �ࠢ����� �⢥⮢

OldKbdImg       dw      0       ;���� ��ࠧ ����������

LastTask        db      0       ;


DataSegm ends

CodeSegm segment
assume cs:CodeSegm, ds:DataSegm ,es:DataSegm

TimeCount proc          ;������ �६��� �� ����᪨�㥬��� ���뢠���

                push ax    ;
                push bx    ;������� ���뢠��� �����᫥���
                push cx    ;⠪ ��� ��� ����᪨�㥬�
                push dx

                cmp Mode,1
                jnz EndTC                     ; �᫨ ०�� ���஢����

                dec TimeCounter               ; � ��⠥� �६�
                jnz EndTC

                inc Time                      ;��諠 �����
                mov TimeCounter,MaxTimeCount  ;��稭����� ᫥����� �����

         EndTC: pop dx
                pop cx
                pop bx
                pop ax

                ret
TimeCount endp


GetKbd proc                        ;����頥� � DX ��ࠧ ����������
                                   ;� �ଠ� KbdImg

                push ax
                push bx
                push cx

                mov dx,0FFFFh      ;��砫쭮� ���祭��

                in al,00h
                mov dl,al
                in al,01h
                mov dh,al
                and dx,00fffh

                pop cx
                pop bx
                pop ax

                ret
GetKbd endp

GetTumb proc                       ;����頥� � Dh ��ࠧ �㬡��஢
                                   ;Dh0..Dh4 - ��⠭������ � 1
                                   ;Dh5 - "����/�ண�"
                                   ;       0 - ���஢����
                                   ;       1 - �ணࠬ��஢����
                                   ;Dh6 - "����/�ண�"
                                   ;       0 - ���஢����
                                   ;       1 - �ணࠬ��஢����
                                   ;Dh7 - ��⠭����� � 1
                push ax
                in al,01h
                and al,01100000b
                mov dh,al
                pop ax

                ret
GetTumb endp

                                ;**********************************
                                ;*  ������� ������� �த楤��� *
                                ;**********************************

ZeroCount proc                 ;������뢠�� ������⢮ �㫥��� ��⮢ � AX
                push cx        ;१���� - � BX
                push ax
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
                ror ax,1       ;ᤢ����
                test ax,0000111111111111b    ;�஢�ਬ
                loopnz LoopFc

;               mov si,bx
;               mov al,byte ptr tablcode[si]
;               out 06,al

                pop ax
                pop cx
                ret
FirstZero endp

                                ;************************************
                                ;* �᭮��� �ணࠬ��� �ᯮ���⥫� *
                                ;************************************

Prepare proc                    ;�����⮢��
                mov cx,9*9      ;���㫥��� ArrTask
                mov al,0
                cld
                lea di,ArrTask
          rep   stos ArrTask

                mov Mark,0      ;���室 � ०�� ��������
                mov Task,0
                mov Time,0
                mov Mode,0

                ret
Prepare endp

ReadKbd proc                          ;�⥭�� ����������
                                      ;� ��襭��� �ॡ����

;                mov cx,TremorFade     ;᪮�쪮 ࠧ ������ ᮢ�����

        LoopRC: call GetKbd           ;���� ����������
                cmp dx,KbdImg         ;�஢��塞
                je NextRC

;                mov cx,TremorFade     ;�� ᮢ���� - ��稭��� ������
                mov KbdImg,dx         ;   ᮢ������� ᭠砫�

        NextRC:; loop LoopRC           ;�஢��塞 �� ࠧ

                ret
ReadKbd endp

DecodKbd proc                         ;����஢�� ����������

                mov KeyCode,0fh       ;�������� ���� ��砩

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

DecodTumb proc                        ;����஢�� �㬡��஢
                call GetTumb
                mov FlagT1,00h
                test dh,00100000b
                jz EndT1DT
                mov FlagT1,0FFh

       EndT1DT: mov FlagT2,0FFh
                test dh,01000000b
                jz EndT2DT
                mov FlagT2,00h

       EndT2DT: ret
DecodTumb endp

ModeSwitch proc                      ;��४��祭�� ०����
                cmp Mode,2
                jz MS1               ;�᫨ ०�� �� �ணࠬ��஢����
                cmp Mode,3           ;� �� ���� �६���
                jz MS1

                cmp FlagT1,0         ;� �᫨ �㬡��� � ���������
                jz EndMS             ;�ணࠬ��஢����

                mov MaxTask,-1
                mov Task,0           ;� ��⠭����� ���� �����
                mov ah,ArrTask[0]    ;� ��४������ � ०��
                mov Anser,ah         ;�ணࠬ��஢���� ����ᮢ
                mov Mode,2
                mov AllTask,0
                jmp EndMS

           MS1: cmp FlagT1,0         ;�᫨ ०�� �ணࠬ��஢���� ��� ����
                jnz EndMS            ;�६���, � �㬡��� � ���������
                                     ;���஢����,

                mov Time,0           ;� ����� ����室��� ��६����
                mov Task,0           ;� ��३� � ०�� ��������
                mov Anser,0
                mov Mode,0

         EndMS: ret

ModeSwitch endp

ProgMode proc                        ;����� �ணࠬ��஢���� �⢥⮢
                cmp Mode,2
                jnz NotPM
                mov ah,KeyCode

                cmp ah,11            ;������� �� ������� "����"
                jnz PM1
                mov Mode,3           ;    ���室 � ०�� ����� �६���
                jmp EndPM

           PM1: cmp ah,10            ;������� �� ������� "����"
                jnz PM2
                mov al,Anser
                cmp Anser,0
                jz PM15
                inc AllTask 
      PM15: 

                mov bl,Task          ;    䨪��� �⢥�
                mov bh,0
                mov al,Anser
                mov ArrTask[bx],al
                mov MaxTask,bl
                cmp bl,MaxVopros*MaxBilet-2       ;    �᫨ ���稪 ����ᮢ ����� 㢥�����
                ja EndPM
                inc bl             ;    � ���室 � ᫥���饬� ������
                mov Task,bl
                mov al,ArrTask[bx]
                mov Anser,al
                jmp EndPM

           PM2: cmp ah,9            ;������� �� ��஢� ������
                ja EndPM
                mov Anser,ah        ;   ����� ���� ��� �⢥�

         EndPM: mov KeyCode,0fh
         NotPM: ret
ProgMode endp

TimeMode proc                       ;����� ����� �६���
                cmp Mode,3
                jnz NotTM
                mov ah,KeyCode

                cmp ah,10           ;������� �� ������� "����"
                jnz TM1
                mov Mode,2          ;   ���室 � ०�� �ண�. �⢥⮢
                jmp EndTM

           TM1: cmp KeyCode,9       ;������� �� ��஢� ������
                ja EndTM


                mov ax,MaxTime        ;   ����� ���� ��� �⢥�
                mov dx,0
                mov bx,10
                mul bx
                mov bx,1000
                div bx
                mov cx,0
                add cl,KeyCode 
                add dx,cx
                mov MaxTime,dx

         EndTM: mov KeyCode,0Fh
         NotTM: ret
TimeMode endp

WaitMode proc
                cmp Mode,0           ;����� ��������
                jnz NotTM
                mov ah,KeyCode

                cmp ah,11            ;������� �� ������� "����"
                jnz EndWM
                mov Time,0
                mov TimeCounter,MaxTimeCount
                mov Task,-1

    WMLoop:     inc Task            ;    ���� � ���ᨢ� ᫥���騩 �����
                mov bl,Task         ;    � ���㫥�� �⢥⮬
                mov bh,0
                mov al,ArrTask[bx]

                cmp al,0
                jnz WM1

                cmp Task,MaxVopros*MaxBilet-1;
                jg  WM1
 
                jmp WMLoop
                
                
       WM1:     mov Anser,0
                mov OkTask,0         ;      ��⠭����� ��६���� �
                                     ;      ��室��� ���ﭨ�
                mov Mode,1           ;      � ����� ���஢����

         EndWM: mov KeyCode,0fh
         NotWM: ret
WaitMode endp




TestMode proc                       ;����� ���஢����
                cmp Mode,1
                jnz NotTsM
                mov ah,KeyCode

                cmp ah,11                    ;ॠ��� �� ������� "����"
                jnz TSM0
                mov Time,0
                mov TimeCounter,MaxTimeCount
                mov Anser,0
                mov OkTask,0         ;      ��⠭����� ��६���� �
                                     ;      ��室��� ���ﭨ�
                mov Mode,1           ;      � ����� ���஢����
                jmp EndTsM

         TSM0:  cmp ah,10           ;������� �� ������� "����"
                jnz TsM1
              
                mov al,Task
                mov LastTask,al  
                mov bl,Task
                mov bh,0
                mov al,ArrTask[bx]
                cmp al,Anser        ;    �᫨ �㦭�,
                mov Anser,0         ;
                jnz LoopTsM         ;
                inc OkTask          ;    㢥����� ���稪 �ࠢ�����
                                    ;    �⢥⮢

                
       LoopTsM: inc Task   ;    ���� � ���ᨢ� ᫥���騩 �����
                mov bl,Task         ;    � ���㫥�� �⢥⮬
                mov bh,0
                mov al,ArrTask[bx]

                cmp al,0
                jnz EndTsM

                cmp Task,MaxVopros*MaxBilet-1;
                jg  EndTsM
 
                jmp LoopTsM


          TsM1: cmp ah,9             ;������� �� ��஢� ������
                ja EndTsM
                mov Anser,ah         ;     �������� ��� �⢥�

        EndTsM: mov KeyCode,0Fh
        NotTsM: ret
TestMode endp

EndControl proc                      ;����஫� ����砭�� ���
                mov EndTest,0        ;����� 䫠� ����砭��
                cmp mode,1
                jnz EndEC

                cmp FlagT2,0         ;��⠭����� 䫠� ����砭��
                jnz EC1               ;�᫨ ����祭 ����஫� �६��� �
                mov ax,MaxTime       ;���稫��� �६�
                cmp ax,Time
                ja EC1
                mov EndTest,0FFh

           EC1:
                mov al,Task          ;��⠭����� 䫠� ����砭��, �᫨
                cmp al,MaxTask           ;����� ����� �⠫ �����,
                jle EndEC             ;祬 ���ᨬ����
                mov EndTest,0FFh

         EndEC: ret
EndControl endp

MarkCount proc                     ;���⠢����� �業��

                cmp EndTest,0      ;�᫨ ��� �����訫��, �
                jz NotMC

                mov Mark,0         ;�᫨ ��饥 ������⢮ ����ᮢ - 0
                mov bl,AllTask     ;� � �業�� - 0
                cmp bl,0
                jz EndMC

                mov al,OkTask      ;���� ��室�� ३⨭� � %
                mov bh,100
                mul bh
                div bl
                
                mov Mark,2 

                cmp al,60          ;������
                jb EndMC

                mov Mark,3
                cmp al,75          ;�ன��
                jb EndMC

                mov Mark,4
                cmp al,90          ;�⢥ઠ
                jb EndMC

                mov Mark,5

       EndMC:   mov EndTest,0      ;���ઠ
                mov Mode,0
                mov Task,0

       NotMC:   ret
MarkCount endp


MakeImage proc
                cld                ;��� ��砫� - ��頥� ��ࠧ
                mov al,0fh
                lea di,IndImg
                mov cx,7
          rep   stos IndImg

                cmp Mode,2         ;�⮡ࠦ���� ⥪�饣� �६���
                jz M1   
                cmp Mode,3         ;�⮡ࠦ���� ⥪�饣� �६���
                jz M1   
                          ;� ०��� ���஢����
                cmp FlagT2,0       ;� ��������
                jnz M1             ;(�� ����祭���� ����஫� �६���)



                mov ax,Time
                mov dx,0
                mov bx,10
                div bx 
                mov IndImg[6],dl
                mov dx,0
                div bx
                mov IndImg[1],dl
                mov dx,0
                div bx
                mov IndImg[0],dl

            M1: cmp Mode,3        ;�⮡ࠦ���� ���ᨬ��쭮�� �६���
                jnz M2            ;� ०��� ����� �६���


                mov ax,MaxTime
                mov dx,0
                mov bx,10
                div bx 
                mov IndImg[6],dl
                mov dx,0
                div bx
                mov IndImg[1],dl
                mov dx,0
                div bx
                mov IndImg[0],dl


            M2: cmp Mode,0       ;�⮡ࠦ���� ����� ������� � �����
                jz M25       
                cmp Mode,3
                jz M25       
                                 ;� ०���� �ணࠬ��஢����, ���஢����
                mov al,Task      
                mov ah,0
                mov bl,MaxVopros
                div bl
                inc al
                inc ah
                mov IndImg[2],ah
                mov IndImg[3],al

            M25: cmp Mode,0       ;�⮡ࠦ���� ����� ������� � �����
                jnz M3            ;� ०���� �ணࠬ��஢����, ���஢����
                mov al,LastTask     ;� ��������
                mov ah,0
                mov bl,MaxVopros
                div bl
                inc al
                inc ah
                mov IndImg[2],ah
                mov IndImg[3],al

            M3: cmp Mode,3       ;�⮡ࠦ���� �⢥� � ०����
                jz M4            ;���஢���� �  �ணࠬ��஢����
                cmp Mode,0
                jz M4
                mov al,Anser
                mov IndImg[4],al

            M4: cmp Mode,0       ;�⮡ࠦ���� �業�� � ०��� ��������
                jnz EndMI
                mov al,Mark
                mov IndImg[5],al

         EndMI:

                ret
MakeImage endp
MyMake proc
    mov al,AllTask
    mov IndImg[0],al 
    mov al,OkTask
    mov IndImg[1],al 
mret:   ret
MyMake endp

 OutInd proc                     ;�뢮� ��ࠧ� �� ��������
                push ax
                push bx

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

                mov al,IndImg[6]
                xlat
                out 08,al

                pop bx
                pop ax

                ret
OutInd endp

Start:
                mov ax,DataSegm     ;***********************
                mov ds,ax           ;*    �����஢���     *
                mov es,ax           ;***********************

                call Prepare        ;�����⮢��

MainLoop:
                 call TimeCount      ;
                 call ReadKbd        ;�⥭�� ����������
                 call DecodKbd       ;����஢�� ����������
                 call DecodTumb      ;���� � ����஢�� �㬡��஢
                 call ModeSwitch     ;��४��祭�� ०����
                 call WaitMode       ;०�� ��������
                 call ProgMode       ;����� �ண�. �⢥⮢
                 call TimeMode       ;०�� ����� �६���
                 call TestMode       ;०�� ���஢����
                 call EndControl     ;����஫� ����砭�� ���
                 call MarkCount      ;���⠢����� �業��
                 call MakeImage      ;�ନ஢���� ��ࠧ�
;                 call MyMake         ;
                 call OutInd         ;�뢮� �� ���������
                jmp MainLoop


CodeSegm ends

end Start

comment {               lea di,indimg
                mov cx,6

        pc:     mov al,byte ptr [di]
                mov ah,0
                mov si,ax
                mov al,byte ptr tablcode[si]
                mov byte ptr [di],al
                inc di
                loop pc
Next proc
                push bx
                push ax                

       LoopTsM: inc Task            ;    ���� � ���ᨢ� ᫥���騩 �����
                mov bl,Task         ;    � ���㫥�� �⢥⮬
                mov bh,0
                mov al,ArrTask[bx]

                cmp al,0
                jnz EndN

                cmp Task,MaxVopros*MaxBilet-1;
                ja  EndN
 
                jmp LoopTsM

 EndN:          pop ax
                pop bx
              
                 ret
Next endp

}       


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

                mov ax,Time1        ;   ����� ���� ��� �⢥�
                mov dx,0
                mov bx,10
                mul bx
                mov bx,1000
                div bx
                mov cx,0
                add cl,KeyCode 
                add dx,cx
                mov Time1,dx

