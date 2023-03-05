datchik struc;��������� ����������� ����� 2 ������(+/-)+2 ����������
           in_port   db ?;
	   out_port1 db ?;
	   out_port2 db ?;
	   cur_value db ?;
	   max_value db ?;
           old db ?;
datchik ends

; ��������� ������ ��� ����������
device struc
       in_data_off   dw ?                    ;�������� �� ������ ����������
                                             ;������� �����������
       timer         db ?                    ;������
       type_device   db ?                    ;�������
device ends

data segment at 40H
       up_dat      datchik ?;
       down_dat    datchik ?;
       temperature datchik ?;
       delta_temp  datchik ? 		
       Map         db 10 dup (?)
       up_device   device ?    ;��������� ��� ������� �������
       down_device device ?    ;��������� ��� ������� �������
       tick	   dw ?	
data ends

stck segment at 0ba80h
     dw 512 dup(?)
     stck_top label word
stck ends     

code segment
assume cs:code,ds:data,ss:stck

;��������� ��������� ��������� ��������
setup proc
	   mov up_dat.in_port,0
	   mov up_dat.out_port1,0
	   mov up_dat.out_port2,1
	   mov up_dat.cur_value,25
	   mov up_dat.max_value,99
           mov up_dat.old,0

	   mov down_dat.in_port,1
	   mov down_dat.out_port1,2
	   mov down_dat.out_port2,3
	   mov down_dat.cur_value,25
	   mov down_dat.max_value,99
           mov down_dat.old,0

	   mov temperature.in_port,3
	   mov temperature.out_port1,4
	   mov temperature.out_port2,5
	   mov temperature.cur_value,25
	   mov temperature.max_value,99
           mov temperature.old,0

	   mov delta_temp.in_port,4
	   mov delta_temp.out_port1,10
	   mov delta_temp.out_port2,6
	   mov delta_temp.cur_value,5
	   mov delta_temp.max_value,9
           mov delta_temp.old,0

           mov Map[0], 3FH
           mov Map[1], 0CH
           mov Map[2], 76H
           mov Map[3], 05EH
           mov Map[4], 4DH
           mov Map[5], 5BH
           mov Map[6], 7BH
           mov Map[7], 0EH
           mov Map[8], 7FH
	   mov Map[9], 5fh

           mov up_device.in_data_off,offset up_dat.cur_value
           mov up_device.timer,0
           mov up_device.type_device,0

           mov down_device.in_data_off,offset down_dat.cur_value
           mov down_device.timer,0
           mov down_device.type_device,0

           mov tick,2000	
	   mov al,0
	   out 8,al
	   ret
setup endp
control proc
           push dx
           push ax
           push cx
	   xor dx,dx
           mov dl,[bx]
           in  al,DX
	   cmp al,0
	   jnz press
	   mov [bx+5],al
	   jmp nochange
press:     mov ah,[bx+5]
           mov [bx+5],al
           xor al,ah
           cmp al,0
           jz  nochange
           mov al,[bx+5]
           cmp al,1
           jz  ppressed
	   mov al,0
           cmp [bx+3],al
           jz  nochange
           dec byte ptr[bx+3]
           jmp nochange
ppressed:  mov al,[bx+3]
           cmp al,[bx+4]
           jz  nochange
           inc byte ptr[bx+3]
nochange:  xor ax,ax
           mov al,[bx+3]
	   mov cl,10
           div cl
           mov dl,[bx+1]
           push bx
           mov bx,offset Map
           xlat
           out dx,al
           mov al,ah
           pop bx
           mov dl,[bx+2]
           mov bx,offset Map
           xlat
           out dx,al
           pop cx
           pop ax
           pop dx
           ret
control endp

; �������� ������� ��������� ����������
main_process proc
           locals  @@                        ;��������� ��������� �����
           push ax
           push bx
           push cx
           push dx                             ;��������� ��������
           xor   ax,ax
           mov   bx,[si].in_data_off         ;�������� ������� ������
           mov   al,[bx]                     ;���� ������� ������
           mov   dh,temperature.cur_value    ;������� �����������
           mov   dl,dh
           add   dh,delta_temp.cur_value     ;������� �����������
           sub   dl,delta_temp.cur_value     ;������ �����������
           cmp   [bx],dl
           jb    @@set_hot                   ;������� ���� ������� �����������
                                             ;���� ���������� (���������
                                             ;������������)
           cmp   [bx],dh
           ja    @@set_cool                  ;������� ���� ������� �����������
                                             ;���� ���������� (���������
                                             ;�����������)
           xor   al,al
           mov   [si].timer,al               ;�������� ������
           mov   [si].type_device,al         ;������� �� ����������
                                             ;���������

           jmp   @@return                    ;���  Ok

@@set_hot:
           mov  [si].type_device,2           ;������� ���������
                                             ;���������� �������
           inc  [si].timer                   ;������� �����
           jmp  @@exit

@@set_cool:
           mov  [si].type_device,1           ;������� ���������
                                             ;���������� ����������
           inc  [si].timer                   ;������� �����
           jmp  @@exit

@@exit:
           mov  bl,[si].timer                ;��������� ������� �������
           cmp  bl,10                        ;���������� � ������������
                                             ;���������� ���������
           jb   @@return                     ;���� ��� �� �� �� �����
           mov  al,[si].type_device          ;��� ����������
           mov  bl,4                         ;������� ����. ��������
           or   al,bl                        ;������� ����������� ��������
                                             ;������� ����������
           mov  [si].type_device,al
@@return:
           pop dx
           pop cx
           pop bx
           pop ax                             ;��������� ��������

                                         ;��������������� ��������
           ret                               ;�����
main_process endp
main proc
   	   cmp   tick,0
	   jnz   continue
           lea   si,down_device              ;��������� ��� ������� �������
           call  main_process                ;�������� �������
           mov   al,down_device.type_device
           
           shl   al,1
           shl   al,1
           shl   al,1
           
           lea   si,up_device                ;��������� ��� ������� �������
           call  main_process                ;�������� �������
           or    al,up_device.type_device
           out   8,al
	   mov   tick,2000
continue:  dec tick
	   ret
main endp
;���������



Start:
           mov  ax,Data
           mov  ds,ax
           mov  ax,stck
           mov  ss,ax
           lea  sp,stck_top
           call setup           
InfLoop:
           lea bx,up_dat
           call control
           lea bx,down_dat
           call control
           lea bx,temperature
           call control
           lea bx,delta_temp
           call control
           call main
           jmp  InfLoop
           org  0ff0h
           assume cs:nothing
           jmp  Far Ptr Start
Code       EndS
End start


;start:     
;           mov ax,data
;       	   mov ds,ax
;           mov ax,stck
;           mov ss,ax
;           lea sp,stck_top
;           call setup
;next:   
;   lea bx,up_dat
;           call control
;           lea bx,down_dat
;           call control
;           lea bx,temperature
;           call control
;           lea bx,delta_temp
;           call control
;           
;           call main
;           mov  al,0ffh
;           out  0,al
;           jmp next

;           org 0ff0h
;code ends

;end start


;Data       Segment at 40h
;OldVal     db   ?
;Counter    db   ?
;Data       EndS
;Code       Segment
;           Assume cs:Code,ds:Data
          
;IndVal     db   3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7Fh,5Fh
;Start:
;           mov  ax,Data
;           mov  ds,ax
;           mov  OldVal,0
     
;InfLoop:
;           mov  al,0ffh
;           out  0,al
;           jmp  InfLoop
;           org  0FF0h
;Code       EndS
;End start
