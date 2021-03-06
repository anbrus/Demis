;���� �ᯮ����⥫��� ��楤��

MakeAddress proc
        mov ax,word ptr RealAddress
        mov dx,1111000000000000b
        and dx,ax
        shl ax,4
        add al,NextDig
        dec al
        mov word ptr RealAddress,ax
        mov word ptr RealAddress[2],dx
        ret
MakeAddress endp

;================================
MakeSize proc
        mov ax,CurSize
        shl ax,4
        mov dl,NextDig
        dec dl
        add al,dl
        mov CurSize,ax
        ret
MakeSize endp

;================================
MakeAutoVars proc               ;ᮧ����� ��६�����
                                ;��� ��⮬���᪮�� ०���

        cmp IntypeA,0           ;��⠭�������� ���� ?
        jne MAV
        call MakeAddress        ;ᮡ�ࠥ� ����
        jmp exit

MAV:
        cmp Byte Ptr Intype,0FFh
        jne exit
        call MakeSize

exit:
        ret
MakeAutoVars endp

;================================
MakeMemData proc
        push es
        les di,RealAddress
        mov al,es:[di]
        shl al,4
        mov ah,NextDig
        dec ah
        add al,ah
        mov es:[di],al
        pop es
        ret
MakeMemData endp

;================================
MakeManualVars proc             ;ᮧ����� ��६�����
                                ;��� ��筮�� ०���
        cmp IntypeM,0;��⠭�������� ���� ?
        jne @@MMV
        call MakeAddress        ;ᮡ�ࠥ� ����
        jmp @@exit

@@MMV:
        cmp IntypeM,0FFh
        jne @@exit
        call MakeMemData

@@exit:
        ret                     ;
MakeManualVars endp

;================================
ManualMake proc
        cmp Mode,0FFh
        je @@MM
        jmp @@exit
@@MM:
        cmp AddrInc,0FFh
        jne @@M1
        add word ptr RealAddress,1
        pushf
        mov ax,word ptr RealAddress[2]
        shr ax,12
        popf
        adc ax,0
        mov dx,ax
        lahf
        and ah,00001000b
        je @@move1                        ;�᫨ ���� ��७�� ��.
        mov word ptr RealAddress[2],0
        jmp @@exit

@@move1:                          ;��� ��. ��७��
        shl dx,12
        mov word ptr RealAddress[2],dx
        jmp @@exit
;========���ࠢ����� �����

@@M1:                                     ;���ࠢ����� �����
        sub  word ptr RealAddress,1
        pushf
        mov ax,word ptr RealAddress[2]
        shr ax,12
        popf
        sbb ax,0
        jnc @@MovHighPart
        mov word ptr RealAddress[2],0F000h
        jmp @@exit
@@MovHighPart:
        shl ax,12
        mov word ptr RealAddress[2],ax
@@exit:
        ret
ManualMake endp

;================================
TestProcessRAM proc                     ;��楤�� ���஢���� ���

@@UnPressWait:                          ;�������� �⦠�� ������
        in al,OptionPort
        cmp al,0
        jne @@UnPressWait

        mov al,0
        out LampPort,al                 ;������� �����窨

        cmp CurSize,0                   ;�஢�ઠ ࠧ��� �஢��塞�� ������
        jne @@NoE                       ;�᫨ ࠧ��� >0 � ���室 � ����

        mov ErrFlag,SizeErr             ;���� ����⢨� �� �訡��
        mov al,SizeErr
        call DannErrorProcess
        jmp @@exit
@@NoE:
        ;�����।�⢥��� ������� ���
        ;᭠砫� �஢�ઠ �� �ࠢ��쭮��� �����
        ;� �祩�� �����
        mov cx,CurSize                  ;������ �஢��塞�� ������
        les di,RealAddress              ;����㧪� ���� �஢�塞�� ������
        mov si,word ptr Dir
@@TestLoop:
        mov dl,es:[di]                  ;��࠭塞 ���祭�� �祩�� �����
        mov es:[di],byte ptr TestNumber1;������ ��ࢮ�� ��⮢��� �᫠
        mov al,es:[di]                  ;���뢠��� �᫠
        cmp al,TestNumber1              ;�ࠢ����� ��⠭���� �᫠ � �⠫����
        jne @@FindError                 ;�᫨ �� ᮢ���� � ???
        mov es:[di],byte ptr TestNumber2;������ ��ண� ��⮢��� �᫠
        mov al,es:[di]                  ;���뢠��� �᫠
        cmp al,TestNumber2              ;�ࠢ�����
        jne @@FindError                 ;�᫨ �� ᮢ���� � ???
@@ContinueTest:
        mov es:[di],dl                  ;�᫨ �� ��� � ����⠭������� ��
        cmp si,1
        jne @@Bc
        add di,1
        jmp @@trim
@@Bc:
        sub di,1
@@trim:
        jnc @@Loop                      ;�᫨ ��९������� � ᬥ饭�� �
        mov ax,si
        shl ax,12
        push bx
        mov bx,es
        add ax,bx
        pop bx
        mov es,ax
                                        ;���६��� ��ଠ����������� ᥣ����
@@Loop:
        loop @@TestLoop                 ;��横�������
        jmp @@NextTest                  ;���室 �� ᫥���騩 ���

@@FindError:                            ;��ࠡ�⪠ �訡��

        mov word ptr DispAdr,di
        mov word ptr DispAdr[2],es
        push ax                         ;��࠭��� ax
        push si
        push es
        push cx
        push dx
        mov al,MemDBusErr               ;⨯ �訡�� � al
        call DannErrorProcess           ;����⢨� ���짮��⥫� �� �訡��
        cmp al,ContinueKey                      ;������ ����⢨�
        jne @@exit11
        pop dx
        pop cx
        pop es
        pop si
        pop ax
        jmp @@ContinueTest
@@exit11:
        pop dx
        pop cx
        pop ax
        pop si
        pop ax
        jmp @@exit1
@@NextTest:                                     ;��� 設� ����
        call AdrBusTest
        call WalkingBitTest
@@exit:
        call DispOkResult
        mov ErrFlag,NoErr
@@exit1:
        ret                             ;��室
TestProcessRAM endp


TestProcessROM proc                     ;��楤�� ���஢���� ���

@@UnPressWait:                          ;�������� �⦠�� ������
        in al,OptionPort
        cmp al,0
        jne @@UnPressWait

        mov al,0
        out LampPort,al                 ;������� �����窨

        mov ax,Word Ptr CurSize         ;�஢�ઠ ࠧ��� �஢��塞�� ������
        or  ax,Word Ptr CurSize+2
        jz  @@NoE                       ;�᫨ ࠧ��� >0 � ���室 � ����

        mov ErrFlag,SizeErr             ;���� ����⢨� �� �訡��
        mov al,SizeErr
        call DannErrorProcess
        call CRCTest
@@NoE:
        ret                             ;��室
TestProcessROM endp

;================================
StopKey=10000000b                       ;������ C⮯
ContinueKey=01000000b                   ;������ �த������
ErrorPort=11

DannErrorProcess proc                   ;����⢨� �� �訡���
                                        ;�������� ᮮ�饭�� �� �訡��

                                        ;���㫥��� ���ᨢ� �⮡ࠦ����
        push bx                         ;��࠭���� bx
        lea bx,DispArray                ;� bx ���� ���ᨢ� �⮡ࠦ����
        mov cx,7                        ;� cx ������ ���ᨢ� �⮡ࠦ����
@@ZeroDisp:                             ;横� ���㫥���
        mov [bx],byte ptr 0
        inc bx
        loop @@ZeroDisp
        pop bx                          ;����⠭������� bx

        push ax
        mov al,Map[14]
        mov DispArray[4],al
        mov al,MAp[16]
        mov DispArray[3],al
        mov DispArray[2],al
        mov al,Map[2]
        mov DispArray[1],al
        pop ax

        cmp al,SizeErr
        jne @@1
        push ax
        mov al,Map[1]
        mov DispArray[1],al             ;������� �訡��
        pop ax
        call OutputDispArr
@@SE:
        in al,OptionPort
        cmp al,EnterKey
        jne @@SE
@@1:
        cmp al,MemDBusErr
        jne @@2
        call MakeAdr1
        call OutputDispArr
        mov al,1
        out ErrorPort,al
@@Wp:
        in al,OptionPort
        cmp al,ContinueKey
        jne @@3
@@WUp:                                  ;�������� �⦠�� ������
        in al,OptionPort
        cmp al,0
        jne @@WUp
        mov al,ContinueKey
        jmp @@exit
@@3:
        cmp al,EnterKey
        jne @@Wp
        mov al,1
        jmp @@exit
@@2:
@@exit:
        push ax
        mov al,0
        out ErrorPort,al
        pop ax
        ret;
DannErrorProcess endp

;=========================================

MakeAdr1 proc
        push ax
        push bx
        push si
        push di
        push cx
        lea bx,map
        lea si,DispArray
        mov dx,word ptr DispAdr
        mov cx,4
MA1:
        mov ax,0Fh
        and ax,dx
        xlat
        mov [si],al
        shr dx,4
        inc si
        loop MA1

        mov ax,word ptr DispAdr[2]
        shr ax,12
        xlat
        mov [si],al
        inc si
        les di,DispAdr
        mov dl,es:[di]
        mov cx,2
MA2:
        mov al,0fh
        and al,dl
        xlat
        mov [si],al
        inc si
        loop MA2

        pop cx
        pop di
        pop si
        pop bx
        pop ax
        ret
MakeAdr1 endp

;=========================================
DispOkResult proc
        mov al,80H
        out LampPort,al                 ;��ᢥ��� �������� ���� ���

DOR:                                    ;�������� ������ �����
        in al,ModePort
        mov dx,ModePort
        call VibrDestr
        cmp al,10h
        jne DOR

        ret
DispOkResult endp

AdrBusTest proc
LOCAL   PassCount:BYTE

        mov  cx,Word Ptr CurSize
        mov  dx,Word Ptr CurSize+2
        mov  PassCount,1
@@ShiftNext:
        shr  dx,1
        rcr  cx,1
        inc  PassCount
        mov  ax,cx
        or   ax,dx
        jnz  @@ShiftNext

        mov  ch,PassCount
        push es                 ;��࠭���� es
        mov ax,0                ;
        mov es,ax               ;���㫥��� ᥣ���⭮�� ॣ����
        mov di,0                ;����㧪� ���� �祩�� ���ﭨ�
        stc
        lea si,TstBuf           ;����㧪� ���� ����
        mov cl,0                ;����� ⥪�饩 �祪� ���ﭨ�
@@1:                            ;���� ������ � �祩�� ���ﭨ�
        mov al,es:[di]          ;���뢠��� �祩�� ���ﭨ�
        mov [si],al             ;�� ��࠭����
        mov es:[di],cl          ;������ � �祩�� ���ﭨ� �� ����
        inc cl                  ;���६��� ����� �祩�� ���ﭨ�
        inc si                  ;����䨪��� ���� ����
        dec ch
        jz  @@WriteExit
        rcl di,1                ;����䨪��� ���� �祩��
        or di,di                ;�� �祪� ?
        jnz @@1                 ;���室 �᫨ ���

        mov di,0                ;���㫥��� ᬥ饭��
        mov ax,1000H            ;����㧪� ���� �祩�� ���ﭨ�
@@2:
        mov es,ax               ;����㧪� ���� �祩�� ���ﭨ�
        mov dl,es:[di]          ;���뢠��� �祩�� ���ﭨ�
        mov [si],dl             ;��࠭���� �祩�� ���ﭨ�
        mov es:[di],cl          ;������ ᢮��� ����� � �祩�� ���ﭨ�
        shl ax,1                ;����䨪��� ���� �祩�� ���ﭨ�
        inc cl                  ;����䨪��� ����� �祩�� ���ﭨ�
        inc si                  ;����䨪��� ���� ����
        dec ch                  ;�� �祪� ?
        jnz @@2                 ;���室 �᫨ ���

@@WriteExit:
        ;�஢�ઠ �� �ࠢ��쭮��� ����ᠭ��� ����஢ �祥� ���ﭨ�
        mov ch,PassCount
        mov ax,0
        mov di,0
        mov es,ax               ;������ ��砫쭮�� ���� �祪� ���ﭨ�
        lea si,TstBuf           ;����㧪� ���� ����
        stc
        mov cl,0                ;����㧪� ���稪�
@@4:
                ;���뢠��� �祪� ���ﭨ�
        pushf
        cmp cl,es:[di]          ;ᮤ�ন��� = ������
        jne @@AdrError          ;���室 �᫨ ���
        popf
        mov al,[si]             ;���뢠��� ��࠭������ ���祭�� �祪�
        mov es:[di],al          ;����⠭������� �祩�� ���ﭨ�
        rcl di,1
        inc si
        inc cl
        dec ch
        jz  @@ReadExit
        or di,di
        jnz @@4

        mov ax,1000h
@@5:
        mov es,ax
        mov dl,es:[di]
        pushf
        cmp cl,es:[di]
        jne @@AdrError
        popf
        mov dl,[si]
        mov es:[di],dl
        shl ax,1
        inc si
        inc cl
        dec ch
        jnz @@5
@@ReadExit:
@@myExit:
        pop es
        call DispOkResult
        jmp @@exit

@@AdrError:
        pop ax
        mov word ptr DispAdr[2],es
        mov word ptr DispAdr,di
        pop es
        mov al,AddrBusErrorBit
        out ErrorPort,al
        call MakeAdr1
        call OutPutDispArr
@@EE1:
        in al,OptionPort
        cmp al,EnterKey
        jnz @@EE1
        mov al,0
        out ErrorPort,al
        jmp @@exit1
@@exit:
@@exit1:
        ret
AdrBusTest endp


CalcCRC  proc
         push bx
         push cx
         push dx
         push es

         mov  ax,0                     ;ax = ⥪�饥 ���祭�� CRC
         mov  es,ax
         mov  bx,ax                    ;es:bx = 0000:0000
         mov  cx,Word Ptr CurSize
         mov  dx,Word Ptr CurSize+2    ;dx:cx = ���� ����㥬�� �����
@@NextByte:
         add  al,Byte Ptr es:[bx]
         adc  ah,0                     ;ax = ax + Byte Ptr es:[bx]
         adc  ax,0                     ;�ਡ���塞 ��७�� � ax, �.�. �㬬� 横���᪠�
         inc  bx
         jnz  @@IncOK
         mov  bx,es                    ;���室�� � ᫥���饬� ᥣ�����
         add  bx,4096
         mov  es,bx
         xor  bx,bx
@@IncOK:
         loop @@NextByte
         dec  dx
         jnz  @@NextByte

         pop  es
         pop  dx
         pop  cx
         pop  bx
         ret
CalcCRC  endp


CRCTest  proc
         push cx
         push dx

         call CalcCRC                  ;������� CRC
         mov  dx,ax                    ;dx = ��室��� CRC
         mov  cx,CRCPassCount          ;������⢮ ��室�� ���
@@NextPass:
         call CalcCRC                  ;������� CRC
         cmp  ax,dx                    ;�ࠢ���� � ��室��� CRC
         jnz  @@CRCError
         loop @@NextPass

         pop  dx
         pop  cx
         ret

@@CRCError:
         lea si,DispArray
         mov cx,7
         xor al,al
@@ClearNext:
         mov [si],al                   ;����塞 ���ᨢ �⮡ࠦ����
         inc si
         loop @@ClearNext

         mov al,CRCErrorBit
         out ErrorPort,al              ;�������� ᢥ⮤��� �訡�� ���
         call OutPutDispArr            ;������塞 ᮤ�ন��� �������஢
@@EE1:
         in al,OptionPort
         cmp al,EnterKey               ;��� ॠ�樨 ���짮��⥫�
         jnz @@EE1
         mov al,0
         out ErrorPort,al              ;��ᨬ ᢥ⮤��� �訡�� ���

         pop dx
         pop cx
         ret
CRCTest  endp

WalkBit  proc
         mov  al,1
         mov  ah,es:[bx]               ;ah = �।��饥 ᮤ�ন��� �祩��
@@NextBit:
         mov  es:[bx],al
         cmp  al,es:[bx]
         jnz  @@WBError
         shl  al,1
         jnc  @@NextBit
         mov  es:[bx],ah               ;����⠭�������� ᮤ�ন��� �祩��

         xor  al,al                    ;�訡�� ���
         ret

@@WBError:
         mov  al,1                     ;�訡��
         ret
WalkBit  endp


WalkingBitTest proc
         push bx
         push cx
         push dx
         push es

         mov  ax,0
         mov  es,ax
         mov  bx,ax
         mov  cx,Word Ptr CurSize
         mov  dx,Word Ptr CurSize+2    ;dx:cx = ����� ����㥬��� �����
@@NextByte:
         call WalkBit                  ;�஢�ઠ �祩�� � ���ᮬ es:[bx]
         or   al,al                    ;�᫨ al<>0 � �訡��
         jnz  @@WBTError
         inc  bx
         jnz  @@IncOK
         mov  bx,es                    ;���室�� � ᫥���饬� ᥣ�����
         add  bx,4096
         mov  es,bx
         xor  bx,bx
@@IncOK:
         loop @@NextByte
         dec  dx
         jnz  @@NextByte
@@Exit:
         pop  es
         pop  dx
         pop  cx
         pop  bx
         ret

@@WBTError:
         mov word ptr DispAdr[2],es
         mov word ptr DispAdr,bx
         mov al,DataBusErrorBit
         out ErrorPort,al
         call MakeAdr1
         call OutPutDispArr
@@EE1:
         in al,OptionPort
         cmp al,EnterKey
         jnz @@EE1
         mov al,0
         out ErrorPort,al
         jmp @@Exit

WalkingBitTest endp
