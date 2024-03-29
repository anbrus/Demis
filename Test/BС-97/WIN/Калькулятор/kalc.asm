
data segment at 040H
  Digits  db 10 dup (?)        ;����
  Error   db ?,?,?             ;�訡�� - rrE
  Sign    db ?,?               ;��������� - �����, ������ �����

  ProcAdres1 dw 7 dup (?)      ; ���� �.�ணࠬ�, �⪫��������
  ProcAdres2 dw 7 dup (?)      ; �� ����⨥ ᮮ⢥�����饩 ������
  ProcAdres3 dw 7 dup (?)

  Xnum db 9 dup (?)           ;��६����� ��� �����
  Ynum db 9 dup (?)           ;��६����� ��� �६������ �࠭����
  MemNum db 9 dup (?)         ;�祩�� �����

  ForScreen db 9 dup (?)      ;��ࠧ ��࠭�

  LastKeyInput db ?           ;��� �������樨 "�ॡ����"

  Operation    db ?           ;�믮��塞�� � ���. ������ ������ (����஢��)
  Errr         db ?           ;䫠� - �訡�� (��९�������)
  MemPresent   db ?           ;䫠� - ������ �����
data ends

;-----------------------------------------------------------
  stack segment at 080H
       dw 100h dup (?)
       StkTop label word
  stack ends
;-----------------------------------------------------------
;-----------------------------------------------------------
  code segment
   assume cs:code,ds:data
;-----------------------------------------------------------
  InitDigits proc
   ; ����㧪� ����ࠦ���� ���
         mov Digits[0],byte ptr 3Fh      ;0
         mov Digits[1],byte ptr 0Ch      ;1
         mov Digits[2],byte ptr 76h      ;2
         mov Digits[3],byte ptr 5Eh      ;3
         mov Digits[4],byte ptr 4Dh      ;4
         mov Digits[5],byte ptr 5Bh      ;5
         mov Digits[6],byte ptr 7Bh      ;6
         mov Digits[7],byte ptr 0Eh      ;7
         mov Digits[8],byte ptr 7Fh      ;8
         mov Digits[9],byte ptr 5Fh      ;9

         mov Error[0],byte ptr 60h       ; ����饭�� �� �訡�� Err
         mov Error[1],byte ptr 60h
         mov Error[2],byte ptr 73h

         mov Sign[0],byte ptr 40h        ; �������� '-'
         mov Sign[1],byte ptr 07h        ; �������� '����� ������'
      ret
  InitDigits endp
;-----------------------------------------------------------
  InitAdress proc
         mov ProcAdres1[0],Offset PresButton10  ; ����㧪� ���ᮢ �.�ணࠬ�,
         mov ProcAdres1[2],Offset PresButton11  ; ����� ��뢠���� �� ����⨨
         mov ProcAdres1[4],Offset PresButton12  ; ᮮ⢥�����饩 ������
         mov ProcAdres1[6],Offset PresButton13
         mov ProcAdres1[8],Offset PresButton14
         mov ProcAdres1[10],Offset PresButton15
         mov ProcAdres1[12],Offset PresButton16
         mov ProcAdres2[0],Offset PresButton20
         mov ProcAdres2[2],Offset PresButton21
         mov ProcAdres2[4],Offset PresButton22
         mov ProcAdres2[6],Offset PresButton23
         mov ProcAdres2[8],Offset PresButton24
         mov ProcAdres2[10],Offset PresButton25
         mov ProcAdres2[12],Offset PresButton26
         mov ProcAdres3[0],Offset PresButton30
         mov ProcAdres3[2],Offset PresButton31
         mov ProcAdres3[4],Offset PresButton32
         mov ProcAdres3[6],Offset PresButton33
         mov ProcAdres3[8],Offset PresButton34
         mov ProcAdres3[10],Offset PresButton35
         mov ProcAdres3[12],Offset PresButton36
         mov LastKeyInput,byte ptr 0    ;࠭�� ������ �� ��������
      ret
  InitAdress endp
;-----------------------------------------------------------
  Summirovanie proc    ; [bx]:=[si]+[di] ��� ��� ����� (���㫨)
         push ax
         push si       ;��࠭���� ॣ���஢ � �⥪�
         push di
         push bx

         add si,7
         add di,7
         add bx,7      ;��稭��� � ���� �᫠

         mov al,[si]   ;� al-��ࢮ� ᫠������
         and al,0f0h
         mov dl,[di]   ;� dl-��஥ ᫠������
         and dl,0f0h
         add al,dl
         daa           ;���४�� BCD-᫮�����
         pushf         ;��࠭塞 �������� ��७��
         mov dl,[si]
         mov dh,[di]
         and dl,0fh    ;���뢠�� ��������� ��宦����� �����筮� �窨
         and dh,0fh
         or  dl,dh
         or  al,dl
         mov [bx],al

         mov cx,7       ;� 横�� ᪫��뢠�� ��⠢訥�� ����
sm1:     dec si
         dec di
         dec bx
         mov al,[si]
         mov dl,[di]
         popf
         adc al,dl
         daa
         mov [bx],al
         pushf
         loop sm1
         popf
         jnc sm8         ;�� ������������� ��७�� �� ���襣� ࠧ�鸞
         mov errr,byte ptr 1       ;��९�������

sm8:     pop bx
         pop di
         pop si      ;����⠭�������� ��࠭���� ���祭�� ॣ���஢ �� �⥪�
         pop ax
      ret
  Summirovanie endp
;-----------------------------------------------------------
  Vichitanie proc ;[bx]:=[si]-[di]
         push ax
         push bx
         push si
         push di

         add si,7
         add di,7
         add bx,7   ;��稭��� � ���� �᫠

         mov al,[si]
         and al,0f0h
         mov dl,[di]
         and dl,0f0h
         sub al,dl
         das          ;���४�� BCD-���⠭��
         pushf
         mov dl,[si]
         mov dh,[di]
         and dl,0fh
         and dh,0fh   ;���뢠�� ����������� �����筮� �窨
         or  dl,dh
         or  al,dl
         mov [bx],al

         mov cx,7      ;���⠥� � 横�� ��⠢��� ���� � ��⮬ �����
vc3:     dec si
         dec di
         dec bx
         mov al,[si]
         mov dl,[di]
         popf
         sbb al,dl
         das
         mov [bx],al
         pushf
         loop vc3
         popf
         jnc vc4     ;�� ������������� ����� �� ���襣� ࠧ�鸞 
         mov errr,1   ;��९�������
         
vc4:     pop di
         pop si
         pop bx
         pop ax
      ret
  Vichitanie endp
;-----------------------------------------------------------
  Normalization proc   ;��ଠ������ �᫠ � [bx]
         push ax
         push bx

         mov si,bx
         mov di,bx
         mov cx,8
nr1:     mov al,[bx]      ;������뢠�� �᫮ ������ ��� 楫�� ���
         and al,0f0h
         jnz nr2
         dec cx
         mov al,[bx]
         and al,0fh
         jnz nr2
         inc bx
         loop nr1

nr2:     mov dl,cl    ; � dl-�᫮ ���

         add si,7
         mov cx,7
         jmp nr5       ;������뢠�� �᫮ ������ ��� � �஡��� ���
nr4:     mov al,[si]
         and al,0fh
         jnz nr6
         dec cx
nr5:     mov al,[si]
         and al,0f0h
         jnz nr6
         dec si
         loop nr4      ;१���� - � cl

nr6:     cmp cl,0  
         je nr7
         cmp dl,0
         jne nr7      ;�᫨ � �஡��� ��� �᫠ ����, � � 楫�� - ���,
         inc dl       ;⮣�� ���� 楫�� ��� ��⠥� �� ����

nr7:     add dl,cl
         mov [di+8],dl ;�����뢠�� ������⢮ ������� ���

         cmp dl,0
         jne nr8
         mov [di+7],byte ptr 0   ;㡨ࠥ� ����, �᫨ �᫮ ࠢ�� 0

nr8:     pop bx
         pop ax
      ret
  Normalization endp
;-----------------------------------------------------------
  BolsheMenshe proc  ; ��� �᫠ [SI],[DI]  ������� [SI]>[DI]
                       ; al=0 -�� ���﫨  al=1 - ���﫨
         push SI
         push DI

         mov cx,15

bm2:     mov al,[si]
         mov ah,[di]
         and al,0f0h     ;�ࠢ������ ����, ���� ���� �� �㤥� ����� ��㣮�
         and ah,0f0h
         cmp al,ah
         jne bm1
         dec cx
         mov al,[si]
         mov ah,[di]
         and al,0fh
         and ah,0fh
         cmp al,ah
         jne bm1
         inc si
         inc di
         loop bm2
         jmp bme

bm1: ;�᫨ ���� �� ࠢ��
         ja bme
         pop si  ;��஥ �᫮ ����� ��ࢮ��, ���塞 ���⠬� �������
         pop di  
         mov al,1
         ret
bme: ;��ࢮ� �᫮ ����� ��ண�
         pop DI
         pop SI
         mov al,0
      ret
  BolsheMenshe endp
;-----------------------------------------------------------
  Sum proc     ; [BX]:=[SI]+[DI]
         mov al,[si+7]  ;�஢��塞 ���� ��ࢮ�� �᫠
         and al,01h
         jz s1

       ;�᫨ ��ࢮ� ᫠������ ����⥫쭮�
         mov al,[di+7]  ;�஢��塞 ���� ��ண� �᫠
         and al,01h
         jz s3

       ;��ࢮ� ����⥫쭮�, ��஥ ����⥫쭮�
         Call Summirovanie
         or  [bx+7],byte ptr 1   ;���� -
         Call Normalization
      ret

s3: ;��ࢮ� ����⥫쭮�, ��஥ ������⥫쭮�
         Call BolsheMenshe
         Call Vichitanie
         cmp al,1
         jne ss1
         and [bx+7],byte ptr 0feh   ;�᫨ ���﫨 ���⠬� �᫠
         Call Normalization
      ret
ss1:          ;�᫨ �� ���﫨 ���⠬� �᫠
         or [bx+7],byte ptr 1
         Call Normalization
      ret

       ;��ࢮ� ᫠������ ������⥫쭮�
s1:      mov al,[di+7]
         and al,01h
         jz s2

       ;��ࢮ� ������⥫쭮�, ��஥ ����⥫쭮�
         Call BolsheMenshe
         Call Vichitanie
         cmp al,1
         jne ss2
         or [bx+7],byte ptr 1   ;�᫨ ���﫨 ���⠬� �᫠
         Call Normalization
      ret
ss2:   ;�᫨ �� ���﫨 ���⠬� �᫠
         and [bx+7],byte ptr 0feh
         Call Normalization
      ret

s2:;��� ᫠������ ������⥫��
         Call Summirovanie
         and [bx+7],byte ptr 0feh    ;���� +
         Call Normalization
      ret
  Sum endp
;-----------------------------------------------------------
  Minus proc   ;  [BX]:=[SI]-[DI]
         mov al,[si+7]  ;�஢��塞 ���� 㬥��蠥����
         and al,01h
         jz m1

       ;�᫨ ��ࢮ� - ����⥫쭮�
         mov al,[di+7]
         and al,01h
         jz m3

       ;��ࢮ� ����⥫쭮�, ��஥ ����⥫쭮�
         Call BolsheMenshe
         Call Vichitanie
         cmp al,1
         jne mm1
         and [bx+7],byte ptr 0feh   ;�᫨ ���﫨 ���⠬� �᫠
         Call Normalization
      ret
mm1:    ;�᫨ �� ���﫨 ���⠬� �᫠
         or [bx+7],byte ptr 1
      ret

m3: ;��ࢮ� ����⥫쭮�, ��஥ ������⥫쭮�
         Call Summirovanie
         or  [bx+7],byte ptr 1   ;���� -
         Call Normalization
      ret
      
m1: ;��ࢮ� ������⥫쭮�
         mov al,[di+7]
         and al,01h
         jz m2

  ;��ࢮ� ������⥫쭮�, ��஥ ����⥫쭮�
         Call Summirovanie
         and [bx+7],byte ptr 0feh    ;���� +
         Call Normalization
      ret

m2: ;��� ������⥫��
         Call BolsheMenshe
         Call Vichitanie
         cmp al,1
         jne mm2
         or [bx+7],byte ptr 1   ;�᫨ ���﫨 ���⠬� �᫠
         Call Normalization
      ret
mm2:     and [bx+7],byte ptr 0feh
         Call Normalization
      ret
  Minus endp
;-----------------------------------------------------------
  AddDigitXnum proc  ;���������� �᫠ �� al � ����� �᫠ Xnum
         xor si,si
         mov dl,Xnum[8]   ;�᫮ ��������� ��� � dl
         cmp dl,0
         jne adx1

         mov Xnum[3],al  ;ᠬ�� ��ࢠ� ��� �᫠
         jmp adx2

adx1:    ;�᫨ 㦥 ������� ��᪮�쪮 ���
         cmp dl,8
         jne adx0  ;�᫨ ����� ���㤠
      ret
adx0:    mov bl,Xnum[7]
         and bl,2        ;�஢��塞, �뫠 �� ������� �����筠� �窠
         jz  adx4

       ;���� ᫥���饣� ����
         xor si,si
         mov dh,8
adxnxt1:
         mov bl,Xnum[si]
         and bl,0f0h
         jnz adx3
         dec dh
         mov bl,Xnum[si]
         and bl,0fh
         jnz adx3
         inc si
         dec dh
         jnz adxnxt1
         inc dh
adx3: ;� dh - �᫮ ��� 楫�� ��� �᫠
         mov dl,Xnum[8]
         sub dl,dh         ;������塞 �஡��� ���� �᫠
         inc dl          ;� dl - ����� ᢮������ ���� � �஡��� ��� �᫠
         mov cl,dl
         dec cl
         shr cl,1
         xor ch,ch
         mov si,4
         add si,cx
         shr dl,1
         jc adx5
         mov dl,Xnum[si]
         and dl,0f0h
         or dl,al
         mov Xnum[si],dl
         jmp adx2
adx5:
         shl al,4
         mov Xnum[si],al
         jmp adx2

adx4: ;������塞 楫�� ���� �᫠
         mov cx,4
         mov si,3
adx6:    mov dl,Xnum[si]
         mov dh,dl
         shr dh,4
         shl dl,4
         or  dl,al
         mov Xnum[si],dl
         mov al,dh
         dec si
         loop adx6
adx2:
         inc byte ptr Xnum[8]
      ret
  AddDigitXnum endp
;-----------------------------------------------------------
  PressDigit proc   ;� dl- ���, ������ ������
         mov al,Operation     ;������ ���� �믮��塞�� ����樨
         shr al,1
         jc pb1              ;�᫨ ��᫥ + ��� -

         mov al,Operation
         and al,8
         jz pb4

         xor si,si            ;���㫥��� �᫠
         mov ax,si
         mov cx,9
pb5:     mov Xnum[si],al
         inc si
         loop pb5
         mov Operation,byte ptr 0

pb4:     mov al,dl            ;���� ��।��� ���� �᫠
         Call AddDigitXnum
         jmp pbe

pb1:     mov cx,9       ;���⪠ �᫠ Xnum
         xor si,si
         mov ax,si
pb3:     mov Xnum[si],al
         inc si
         loop pb3

         mov al,dl      ;���� ��।��� ���� �᫠
         Call AddDigitXnum

         mov al,Operation    ;��������� ���� �믮��塞� ����樨
         and al,02h
         or  al,04h
         mov Operation,al
pbe:  ret
 PressDigit endp
;-----------------------------------------------------------
; ॠ�樨 �� ����⨥ ᮮ⢥������� ������
  PresButton10 proc       ; � - ����
         mov cx,9
         xor si,si
         mov ax,si
n1:      mov Xnum[si],al       ;���㫥��� �ᯮ��㥬�� ��६�����
         mov ForScreen[si],al
         mov Ynum[si],al
         mov Memnum[si],al
         inc si
         loop n1

         mov Errr, al           ;�訡�� ���
         mov MemPresent, al    ;������ ᢮�����
         mov Operation, al     ;������ � ����� '0'
      ret
  PresButton10 endp
;-----------------------------------------------------------
  PresButton11 proc      ; �� - �맮� �����
         mov cx,9
         xor si,si
pb111:   mov al,Memnum[si]   ;����뫪� Memnum � Xnum
         mov Xnum[si],al
         inc si
         loop pb111

         mov al,Operation   ;��������� ���� ����樨
         and al,0Ah
         or  al,08h
         mov Operation,al
      ret
  PresButton11 endp
;-----------------------------------------------------------
  PresButton12 proc      ; +/- - ����� ����� �᫠
         mov al,Xnum[7]
         mov dl,al
         not al
         and al,01h
         and dl,0FEh
         or  al,dl
         mov Xnum[7],al
      ret
  PresButton12 endp
;-----------------------------------------------------------
  PresButton13 proc      ;  7
         mov dl,7
         Call PressDigit
         ret
  PresButton13 endp
;-----------------------------------------------------------
  PresButton14 proc      ;  4
         mov dl,4
         Call PressDigit
         ret
  PresButton14 endp
;-----------------------------------------------------------
  PresButton15 proc      ;  1
         mov dl,1
         Call PressDigit
         ret
  PresButton15 endp
;-----------------------------------------------------------
  PresButton16 proc      ;  0
         mov al,Operation     ;������ ���� �믮��塞�� ����樨
         shr al,1
         jc  pb161

         mov al,Operation
         and al,8
         jz pb165

         xor si,si            ;���㫥��� �᫠
         mov ax,si
         mov cx,9
pb166:   mov Xnum[si],al
         inc si
         loop pb166
         mov Operation,0

pb165:   mov al,Xnum[8]
         cmp al,0
         jne pb
         mov Xnum[8],1    ;���� ࠧ ������ 0
      ret
pb:      cmp al,1
         je pb162
pb164:   xor al,al
         Call AddDigitXnum
      ret
pb162:   ;�᫨ ������� ���� ���
         mov al,Xnum[7]
         and al,2
         jnz pb164     ;�஢�ઠ ������� �� �窠

         mov al,Xnum[3]
         and al,0fh
         jnz pb164
      ret
pb161:    ;��᫥ ������ + ��� -
         mov cx,9       ;���⪠ �᫠ Xnum
         xor si,si
         mov ax,si
pb163:   mov Xnum[si],al
         inc si
         loop pb163

         mov Xnum[8],byte ptr 1
         mov al,Operation    ;��������� ���� �믮��塞�� ����樨
         and al,02h
         or  al,04h
         mov Operation,al
      ret
  PresButton16 endp
;-----------------------------------------------------------
  PresButton20 proc      ;  �� - ���� ᮤ�ন���� ��࠭�
         mov cx,9
         xor si,si
         mov ax,si
bp201:   mov Xnum[si],al     ;���㫥��� Xnum
         inc si
         loop bp201
      ret
  PresButton20 endp
;-----------------------------------------------------------
  PresButton21 proc      ;  �-  - ������ �� ����� ᮤ�ন��� ��࠭�
         mov si,offset Memnum
         mov di,offset Xnum
         mov bx,offset Memnum
         Call minus
         or  Operation,byte ptr 8
         xor si,si
         mov cx,8
pb211:   mov al,Memnum[si]
         cmp al,0
         jne pb212
         inc si
         loop pb211
         mov MemPresent,byte ptr 0
         mov Memnum[7],byte ptr 0
      ret
pb212:   mov MemPresent,1
      ret
  PresButton21 endp
;-----------------------------------------------------------
  PresButton22 proc      ;  - -������ ���⠭��
         mov al,Operation
         shr al,1
         jc pb221            ;�᫨ �� �� ������� ��ண� ���࠭��

         shr al,1
         shr al,1
         jnc pb222
      ;�᫨ ������ �� ���� ࠧ ��᫥ �����
         mov al,Operation
         shr al,1
         shr al,1
         jc pb224
              ;��᫥ ����樨 +
         mov si,offset xnum
         mov di,offset ynum
         mov bx,offset xnum
         call sum
         mov Operation,8  ;䫠� - ���㫨�� �� ����� ᫥���饣� �᫠
         jmp pb222

pb224:    ;��᫥ ����樨 -
         mov si,offset ynum
         mov di,offset xnum
         mov bx,offset xnum
         call minus
         mov Operation,8  ;䫠� - ���㫨�� �� ����� ᫥���饣� �᫠

pb222:    ;���� ࠧ ������ -
         xor si,si
         mov cx,9
pb223:   mov al,Xnum[si]    ;����뫪� Xnum � Ynum
         mov Ynum[si],al
         inc si
         loop pb223
         
pb221:   mov al,Operation
         and al,8
         or al,11
         mov Operation,al    ;����� 䫠�� - �믮������ ����樨 -
      ret
  PresButton22 endp
;-----------------------------------------------------------
  PresButton23 proc      ;  8
         mov dl,8
         Call PressDigit
      ret
  PresButton23 endp
;-----------------------------------------------------------
  PresButton24 proc      ;  5
         mov dl,5
         Call PressDigit
      ret
  PresButton24 endp
;-----------------------------------------------------------
  PresButton25 proc      ;  2
         mov dl,2
         Call PressDigit
      ret
  PresButton25 endp
;-----------------------------------------------------------
  PresButton26 proc      ;  .  - �����筠� �窠
         mov al,Operation     ;������ ���� �믮��塞�� ����樨
         shr al,1
         jc  pb261

         mov al,Operation
         and al,8
         jz pb264

         xor si,si            ;���㫥��� �᫠
         mov ax,si
         mov cx,9
pb265:   mov Xnum[si],al
         inc si
         loop pb265
         mov Operation,0

pb264:   mov al,Xnum[7]
         and al,2
         jnz pb262
         or  Xnum[7],byte ptr 2     ;�⠢�� ���
         mov al,Xnum[8]    ;������⢮ ��������� ���
         cmp al,0
         jne pb262
         mov Xnum[8],byte ptr 1
pb262:   ret

pb261: ;�᫨ ��᫥ + ��� -
         mov cx,9       ;���⪠ �᫠ Xnum
         xor si,si
         mov ax,si
pb263:   mov Xnum[si],al
         inc si
         loop pb263

         or Xnum[7],byte ptr 02h    ;�⠢�� ���
         mov Xnum[8],byte ptr 1

         mov al,Operation    ;��������� ���� �믮��塞�� ����樨
         and al,02h
         or  al,04h
         mov Operation,al
      ret
  PresButton26 endp
;-----------------------------------------------------------
  PresButton30 proc      ;  �� - ���� ᮤ�ন���� �����
         mov cx,9
         xor si,si
         mov ax,si
bp301:   mov Memnum[si],al     ;���㫥��� Memnum
         inc si
         loop bp301
         mov MemPresent,al
      ret
  PresButton30 endp
;-----------------------------------------------------------
  PresButton31 proc      ;  �+  - ������� � ������� ᮤ�ন��� ��࠭�
         mov si,offset Memnum
         mov di,offset Xnum
         mov bx,offset Memnum
         Call sum
         or  Operation,byte ptr 8
         xor si,si
         mov cx,8
pb311:   mov al,Memnum[si]
         cmp al,ch
         jne pb312
         inc si
         loop pb311
         mov MemPresent,0
         mov Memnum[8],byte ptr 0
      ret
pb312:   mov MemPresent,1
      ret
  PresButton31 endp
;-----------------------------------------------------------
  PresButton32 proc      ;  +  -������ ᫮�����
         mov al,Operation
         shr al,1
         jc pb321            ;�᫨ �� �� ������� ��ண� ���࠭��

         shr al,2
         jnc pb322
                  ;�᫨ ������ �� ���� ࠧ ��᫥ �����
         mov al,Operation
         shr al,2
         jc pb324
              ;��᫥ ����樨 +
         mov si,offset xnum
         mov di,offset ynum
         mov bx,offset xnum
         call sum
         mov Operation,8  ;䫠� - ���㫨�� �� ����� ᫥���饣� �᫠
         jmp pb322

pb324:    ;��᫥ ����樨 -
         mov si,offset ynum
         mov di,offset xnum
         mov bx,offset xnum
         call minus
         mov Operation,8  ;䫠� - ���㫨�� �� ����� ᫥���饣� �᫠

pb322:  ;���� ࠧ ������ +
         xor si,si
         mov cx,9
pb323:   mov al,Xnum[si]    ;����뫪� Xnum � Ynum
         mov Ynum[si],al
         inc si
         loop pb323
pb321:   mov al,Operation
         and al,8
         or al,01
         mov Operation,al    ;����� 䫠�� - �믮������ ����樨 +
      ret
  PresButton32 endp
;-----------------------------------------------------------
  PresButton33 proc      ;  9
         mov dl,9
         Call PressDigit
      ret
  PresButton33 endp
;-----------------------------------------------------------
  PresButton34 proc      ;  6
         mov dl,6
         Call PressDigit
      ret
  PresButton34 endp
;-----------------------------------------------------------
  PresButton35 proc      ;  3
         mov dl,3
         Call PressDigit
      ret
  PresButton35 endp
;-----------------------------------------------------------
  PresButton36 proc      ;  =
         mov al,Operation
         shr al,1
         jnc pb361
         
pb365:   shr al,1
         jc pb362
       ;᫮�����
         mov si,offset Xnum
         mov di,offset Ynum

         mov bx,offset Xnum
         call sum
         jmp pb363
pb362: ;���⠭��
         mov si,offset Ynum
         mov di,offset Xnum
         mov bx,offset Xnum
         Call minus
pb363:   mov al,08h
         mov Operation,al
pb361:   shr al,2
         jnc pb364

         mov al,Operation
         shr al,1
         jmp pb365

pb364:   mov Operation,08h
      ret
  PresButton36 endp
;-----------------------------------------------------------
  ReadKey proc  ;�⥭�� ����⮩ ������, १���� � AH,AL
rep1:    xor ah,ah        ;����塞
         in al,00         ; ���� �㫥���� �⮫��
         cmp al,00
         je RK1              ;�᫨ ��祣� �� �����
         cmp al,LastKeyInput ;
         jne RKE             ;�᫨ ������ ����� �������
         jmp rep1            ;�᫨ �� �� ����� � �� ������

RK1:     inc ah              ;᫥���騩 �⮫���
         in al,01
         cmp al,00
         je RK2
         cmp al,LastKeyInput
         jne RKE
         jmp rep1

RK2:     inc ah              ;᫥���騩 �⮫���
         in al,02
         cmp al,00
         je RK3
         cmp al,LastKeyInput
         jne RKE
         jmp rep1

RK3:     mov LastKeyInput,byte ptr 00   ;�᫨ ��祣� �� �����
         jmp rep1
RKE:     mov LastKeyInput,al
      ret
  ReadKey endp
;-----------------------------------------------------------
;��।������ ����� ������ � bin-���� ����� ����樮�����
;१���� - � SI (㬭���� �� 2)
  DefineNumButton proc
         xor cx,cx
DNB1:    inc cl
         shr al,1
         jnc DNB1
         dec cl
         shl cl,1
         mov si,cx
      ret
  DefineNumButton endp
;-----------------------------------------------------------
  DefineAddress proc     ;��室�� - AH,SI, १���� - AX
         cmp ah,02h
         jne DA1
         mov bx,Offset ProcAdres3
         mov ax,[bx+si]
      ret
DA1:     cmp ah,01h
         jne DA0
         mov bx,Offset ProcAdres2
         mov ax,[bx+si]
      ret
DA0:     mov bx,Offset ProcAdres1
         mov ax,[bx+si]
      ret
  DefineAddress endp
;-----------------------------------------------------------
  Zatalk proc   ;�ᯮ����⥫쭠� ��楤�� � FormScreen
      ; '��⠫�������' �� al � ForScreen � ᤢ���� ᮤ�ন����
         push dx
         push cx
         push si
         mov cx,8
         mov si,0
Zat1:    mov dl,ForScreen[si]
         mov ForScreen[si],al
         mov al,dl
         inc si
         loop Zat1
         pop si
         pop cx
         pop dx
      ret
  Zatalk endp
;-----------------------------------------------------------
  FormScreen proc  ;�ନ஢���� ForScreen �� �᭮�� Xnum
         cmp errr,0
         je fsb       ; �᫨ ��� �訡�� - �� ��ࠡ��� �᫠

         xor si,si
         mov cx,3
fs1:     mov al,Error[si]          ;������ ᮮ�饭�� Err
         mov ForScreen[si],al
         inc si
         loop fs1
         mov cx,6
         xor al,al               ;���������� ���ﬨ ��⠫쭮��
fs2:     mov ForScreen[si],al
         inc si
         loop fs2
         jmp fsm                ;�� �஢��� ������ �����

fsb:   ;��ࠡ�⪠ �᫠
         mov cx,9
         xor ax,ax
         mov si,ax
fs3:     mov ForScreen[si],al    ;�।���⥫쭠� ���⪠ ForScreen
         inc si
         loop fs3

         mov dl,Xnum[8]        ;� dl - ᪮�쪮 ��� ������� � �᫥
         cmp dl,0
         jne fs0

         mov al,Digits[0]
         or  al,80h
         mov ForScreen[0],al   ;������ 0.
         jmp fszn

fs0: ;��ࠡ�⪠ 楫�� ��� �᫠
         xor si,si
         mov cx,8

fsnxt1:  mov al,Xnum[si] ; ��ࠡ�⪠ ���襩 ����-BCD ��।���� ����
         shr al,4
         jnz fs4
         dec cx
               ;�ய�᪠�� ���� ����
         mov al,Xnum[si] ; ��ࠡ�⪠ ����襩 ����-BCD ��।���� ����
         and al,0fh
         jnz fs5
         inc si  ;�ய�᪠�� ���� ����
         loop fsnxt1

         mov al,Digits[0]     ;楫�� ���� �᫠ ࠢ�� 0
         or  al,80h
         mov ForScreen[0],al
         mov cx,9
         dec dl
         jz fszn

fs4:     mov al,Xnum[si]
         shr al,4
         xor ah,ah
         mov di,ax
         mov al,Digits[di]
         Call Zatalk   ;����� ��� ��।���� ���� BCD
         dec cx
         dec dl
         jz fszn

fs5:     mov al,Xnum[si]
         and al,0fh
         xor ah,ah
         mov di,ax
         mov al,Digits[di]
         Call Zatalk   ;������ ��� ��।���� ���� BCD
         dec cx
         jnz fs6

         mov al,ForScreen[0]  ;������塞 ���
         or  al,80h
         mov ForScreen[0],al

fs6:     dec dl
         jz fszn
         inc si
         jmp fs4

fszn:    mov al,Xnum[7]       ;��ࠡ�⪠ ����� �᫠
         and al,01h
         jz fsm
         mov al,Sign[0]
         mov ForScreen[8],al

fsm:     cmp MemPresent,0            ;�஢�ઠ ������ �����
         mov al,Sign[1]
         je fs7
         or ForScreen[8],al
      ret
fs7:  ;������ �� �����
         not al
         and ForScreen[8],al
      ret
  FormScreen endp
;-----------------------------------------------------------
  OutOnScreen proc   ;�뢮� �� ��࠭ ᮤ�ন���� ��ப� ForScreen
         xor dx,dx
         mov si,dx
oos1:    mov al,ForScreen[si]
         out dx,al
         inc dx
         inc si
         cmp dx,9
         jne oos1
      ret
  OutOnScreen endp
;-----------------------------------------------------------
;�����஢���
begin:
         mov ax,data               ;����㧪� ᥣ������ ॣ���஢
         mov ds,ax
         mov ax,stack
         mov ss,ax
         mov sp,offset StkTop
         Call InitDigits          ;�����⮢��
         Call InitAdress
         Call PresButton10        ; "���"
         Call FormScreen
         Call OutOnScreen

Repeat:
         
         Call ReadKey             ;���� ������ ������ (१-� � AH,AL)
         Call DefineNumButton     ;��।������ ����� ����⮩ ������ (१-� � AH,SI)
         Call DefineAddress       ;�ନ஢���� ���� ��楤��� ��ࠡ�⪨
         Call ax                  ;��ࠡ�⪠ ����⮩ ������ �  PresButton##

         Call FormScreen          ;�ନ஢���� ��ࠧ� ��࠭� �� �᭮�� Xnum
         Call OutOnScreen         ;�뢮� �� ��������

         jmp Repeat

         org 0ff0h
         assume cs:nothing
         
start:   jmp far ptr begin

code ends
end start