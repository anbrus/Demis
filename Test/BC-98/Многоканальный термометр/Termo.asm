.8086
;������ ���� ��� � �����
RomSize    EQU   4096

; ����⠭� ���������� �ॡ����
nmax       EQU   60

; ���� ��� ������
PORT_KEYS          equ 8  ;    

; ���� ��� �������� � ������
PORT_CHANEL      equ 7  ;

; ����� ᥬ�ᥣ������ �������஢ ⥬�������
PORT_TEMPL       equ 6  ; ��. ࠧ��    
PORT_TEMPH       equ 5  ; ��. ࠧ��
PORT_TEMPS       equ 4  ; ����

; ��᪨ �ࠢ����� ��� 
ADC_START        equ 1  ; �����     
ADC_READY        equ 1  ; ��⮢�����

; ����ࠦ���� ����� "�����"
Image_Min  equ 40h

Data       SEGMENT AT 0
; ����� ���
PORT_ADCSTART    db          ?; ���� ����᪠
PORT_ADCDATA     db          ?; ���� ������ 
PORT_ADCREADY    db          ?; ���� ��⮢����    
Num_Chanel       db          ?; � ������
Temp         db      ?          ; ��������� (-50..+50)
Image        db      10 dup(?)  ; � ᪮������� ImageMap ��� xlat
org        2048-2
StkTop     Label Word         ; �⥪��� �����誠
Data       ENDS

Code       SEGMENT use16

           ASSUME cs:Code,ds:Data,es:Data

; ���樠������
init       proc near
           ;�����⮢��
           mov al,03Fh         ;
           out PORT_TEMPH,  al ;
           out PORT_TEMPL,  al ;
           out PORT_CHANEL, al ;
           ; ����஢���� ��ࠧ�� ��� �� ���(cs) � ���(ds) ��� xlat
           mov cx, 10          ;
           mov si, 0           ;
ciclecopy: mov al, cs:ImageMap[si]
           mov Image[si], al   ;
           inc si              ;
           loop ciclecopy      ;
           lea bx, ds:Image    ;
           mov Num_Chanel, 0   ;
           ret
init       endp

; ��楤�� �⥭�� ������
ReadKey proc near
           ; ��� ������ ������
      k0:  in  al, PORT_KEYS
           cmp al, 0         ; ������ ����� ?
           jnz k1            ;
           cmp Num_Chanel, 0 ; ����� ����� ?
           jz  k0            ;
           cmp al, 0         ; ����� ������ ��
           jz  Next          ; �������� ������ ?

; ���᫥��� ���⮢ ��⨢���樨 � �⥭�� ������
      k1:  mov cl, 80h       ;
           xor ch, ch        ;
           mov ah, 1         ;
      k2:    
           inc ch            ; ��⠥� � ������
           cmp ch, 5         ; ��࠭�祭�� �� � ������
           jz k1
           cmp cl, 80h       ; ��⠥� � ���� 
           jz k3             ; ��� ���뢠���
           add ah, 2         ; ��⮢���� ���
      k3:
           rol cl, 1         ; �஢��塞 
             ; ����⨥ �����
           cmp al, cl        ; �� 4-� ������
           jnz k2
; ���᫥��� ���⮢ ��⨢���樨 � �⥭�� ������
           mov Num_Chanel, ch;
           dec ch            
           mov PORT_ADCSTART, ch ; ���� ��� ����᪠ ���
           mov PORT_ADCREADY, ah ; ���� ��⮢���� ���
           dec ah                ;
           mov PORT_ADCDATA, ah  ; ���� ����� ������
; �뢮� � ������ �� ��������
           mov al, Num_Chanel;
           xlat              ;
           out PORT_CHANEL, al;
     Next: ret
ReadKey endp

;�⥭�� ������ � ��� � �� �८�ࠧ������
ReadADC proc near
           xor dx, dx        ;
           ; ������ Start �� �������� ���
           mov dl, PORT_ADCSTART ;
           mov al, 1         ;
           out dx, al        ; 
           mov al, 0         ; 
           out dx, al        ;
           ; ��� ��⮢���� ������ �� ���
           mov dl, PORT_ADCREADY        ;
     k4:   in al, dx         ;
           cmp al, 1         ;
           jnz k4            ;
           ; ���뢠�� ����� � ���
           mov dl, PORT_ADCDATA; 
           in al, dx         ;
;   �८�ࠧ������ ��������� 0..255 � �������� -50..+50
;   T = (X * 100)/255 - 50
                             ; ax = X
           mov cl, 100       ; cl = 100
           mov ch, 255       ; ch = 255
           mul cl            ; ax = al * cl
           div ch            ; al = ax / ch
           sub al, 50        ; al = al - 50
           mov Temp, al
           ret
ReadADC endp

;�뢮� ���祭�� ⥬�������
ShowTemp proc near
           mov al, Temp      ; �஢�ઠ ��
           test al, 80h      ; ���� ���祭�� ⥬�������
           jz  Plus          ; ���室 �� ����� ⥬�������
           neg Temp          ;
           mov al, Image_Min ; �뢮��� �����
           jmp k6
       Plus:    
           mov al, 0         ; �뢮��� ����
       k6:
           out PORT_TEMPS, al;
           ; ��������� �᫠ �� ������� � ����⪨
           xor ah, ah
           mov al, Temp      ;
       k7:
           mov dx, ax
           sub al, 10
           js k8
           inc ah
           jmp k7
       k8:    
           mov ax, dx
           ; �뢮� �᫠
           xlat              ; �뢮��� ������ 
           out PORT_TEMPL, al; ���� �᫠

           mov al, ah        ; �뢮���
           xlat              ; ������� ����
           out PORT_TEMPH, al; �᫠
           ret
ShowTemp endp

Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ss,ax
           lea   sp,StkTop
;    �����஢���

           call init         ; ���樠������
begin:
           call ReadKey      ;��� ������ ������
           call ReadADC      ;�⥭�� ������ � ��� � �� �८�ࠧ������
           call ShowTemp     ;�뢮� ���祭�� ⥬�������
           jmp begin

; ���� ��� ��� �������஢
  ImageMap         db    03Fh,00Ch,076h,05Eh,04Dh,05Bh,07Bh,00Eh,07Fh,05Fh

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16      
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END
