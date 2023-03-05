
;**************/��।������ ��ᡠ����\**********************
;
Balanced   Proc
           xor bh, bh           
           mov bl, bParam[2]                   ; ������� �⦨�� 
           shl bx, 1
           mov al, bStep
           mov bStep, 0
           cmp bl, 0                           ; ��� �⦨�� (�.=0)?  
           jne L_Bdef                          ; ���室, �᫨ ���  
           jmp L_BendDef
 L_Bdef:           
           mov bStep, al
           mov dx, ES:SPIN_DEF[bx]             ; ��࠭��� ᪮����
           mov DriveTmp.wSpeed, dx
           mov bfDirection, 0
           mov DriveTmp.bfTypeDir, 1
           mov bfOutDevice[0], 0FFh
           lea bx, wTimeDefB                   
           mov cx, TDEFB
           call Pause                            
           jz L_BendDef                      ; ����� ��।������ ��ᡠ����  
           cmp bError, 05
           jne L_Bend
           mov wTimeDefB, TDEFB
           jmp L_Bend
 L_BendDef:           
           call ZeroDrv
           inc al
           mov bStep, al                         ; ����. 蠣 - �����
 L_Bend:
           ret
Balanced   EndP

;********************************/�⦨�\**************************************
;
Spin       Proc
           mov al, bParam[2]
           cmp al, 0
           je L_Soff
           xor bh, bh
           mov bl, al
           mov cl, 1
           shl bl, cl    
           mov dx, ES:SPIN_DEF[bx]             ; ��࠭��� ᪮����            
           mov DriveTmp.wSpeed, dx
           mov DriveTmp.bfTypeDir, 1
           mov bfMoveDrv, 0FFh           
           mov bfDirection, 0
           lea bx, wWSMinute
           mov cx, TWSMIN
           call Pause
           jnz L_Send
           dec bTimeSpin         
           jnz L_Send
 L_Soff:           
           call Init                                    
 L_Send:          
           ret
Spin       EndP

DrvParam   Proc
; ���᫥��� ᬥ饭�� ��ࠬ��� �����⥫� � ���ᨢ� DriveParam � 
; ����ᨬ��� �� ⥪�饣� �����
;           ��室: DriveTmp
           
; ����塞 ᬥ饭�� � ���ᨢ� DriveParam
           xor bx, bx
           mov bl, bStep
           cmp ES:Program[bx], 0
           je L_DPend
           ;cmp bl, 2
           ;jne L_DRP           
           ;dec bl
 ;L_DRP:           
           dec bl
           mov al, bParam[3]             ; �����
           mov ah, length DriveParam
           mul ah                        ; ax := i*M = �����*4
           add al, bl                 ; ax := i*M+j = �����*4 + ���
           mov ah, type sDriverParam
           mul ah                        ; ax := (i*M+j)*type
           lea bx, es:DriveParam
           add bx, ax

           push es ds es ds 
           pop es                        ; ES := DS
           pop ds                        ; DS := ES
           mov si, bx
           lea di, DriveTmp
           mov cx, type sDriverParam
 rep       movsb                         ; ����뫠�� ��ࠬ��� �� ��� � ��� 
           pop ds
           pop es
 L_DPend:
           ret
DrvParam   EndP

Wash       Proc
           cmp bError, 0
           je L_Wnxt
           jmp L_Wend
 L_Wnxt:      
           mov al, bfStart     
           or bfWork, al
           cmp bfWork, 0FFh
           je L_W1
           jmp L_Wend
 L_W1:     
           mov bfDoorBlocking, 0FFh                 
           mov si, 0                     ; ��稭��� � ��
           mov cx, 5                     ; � �� ������⢮ ��. ����-�
 L_Wnext:       
           mov ax, si
           mov ah, 10
           mul ah
           add al, bStep
           lea bx, ES:Program           
           add bx, ax
           mov al, ES:[bx]
           mov bfOutDevice[si], al
           cmp al, 00                    ; Program[i,j]=0 ?
           je L_WincSI                   ; ���室, �᫨ ��
           cmp si, 0                     ; �� ?
           jne L_Wsi1                    ; ���室, �᫨ ���
           mov bfOutDevice[si], 0FFh     ; ������� ��   
 L_Wsi1:           
           cmp si, 1                     ; ��.��
           jne L_Wsi2                    ; ���室, �᫨ ���
           xor bh, bh
           mov bl, bParam[3]
           shl bl, 1
           mov dx, 1
           and dl, bfAmountLinen
           or bx, dx
           mov dl, es:Water[bx]          ; � dl ����室��� �஢��� ���� ��� ��ન
           cmp bStep, 5                  ; ����᪠���?
           jne L_Wcmp                    ; ���室, �᫨ ���
           mov dl, LEVEL_RING            ; � dl ����室��� �஢��� ���� ��� ����᪠��� 
 L_Wcmp:           
           cmp bWaterLevel, dl           ; �஢��� ���� ���⨣���? 
           jb L_Wsi2                     ; ���室, �᫨ ���
           mov bfOutDevice[si], 0        ; �몫��� ��. ��
 L_Wsi2:           
           cmp si, 2                     ; ���?
           jne L_Wsi3                    ; ���室, �᫨ ���
           mov al, bfWorkHeater
           and bfOutDevice[si], al
           xor bh, bh
           mov bl, bParam[1]
           mov dl, ES:TEMP_DEF[bx]       ; dl = �������� ⥬�-�           
           cmp bWaterTemp, dl            ; ���� ���५���?
           jb L_Wsi3                     ; ���室, �᫨ ���
           mov bfOutDevice[si], 0        ; �몫���� ���
 L_Wsi3:
           cmp si, 3
           jne  L_WincSI
           cmp bWaterLevel, 4
           ja  L_WincSI
           mov bfOutDevice[si], 0 
 L_WincSI:
           inc si                         ; ����. ��. ���ன�⢮
           dec cx
           jz L_WloopExit
           jmp L_Wnext
 L_WloopExit:           
           call DrvParam
           call NextStep                  ; ���室 � ᫥�. 蠣�
           call UpdDrvPar                 ; �������� ��ࠬ���� ��
           call MoveDrv
           call StopDrv
           call OutDrive           
 L_Wend:           
           ret
Wash       EndP

NextStep   Proc
           cmp bError, 0
           je L_NSnxt
           jmp L_NSend
 L_NSnxt:           
           cmp bStep, 0                  ; ���������?
           jne L_NS1                     ; ���室, �᫨ ���
           cmp bfWork, 0FFh              ; ������ "����" �����?
           jne $+6                       ; ���室, �᫨ ���   
           inc bStep                     ; ����. 蠣 - �����
           mov bParam[0], 0              ; �⮡ࠦ��� �६� ��ન           
           jmp L_NSend
 L_NS1:
           cmp bStep, 1                  ; �����?
           jne L_NS2                     ; ���室, �᫨ ���
           cmp bWaterLevel, LEVEL_HEAT   ; �஢��� ���. ����?
           jb $+6                        ; ���室, �᫨ ���
           inc bStep                     ; ����. 蠣 - ������
 L_NS2:           
           cmp bStep, 2                  ; ������?
           jne L_NS3                     ; ���室, �᫨ ���
           xor bh, bh                    
           mov bl, bParam[1]
           mov dl, ES:TEMP_DEF[bx]       ; dl = �������� ⥬�-�           
           cmp bfWorkHeater, 0FFh
           jne L_NS2inc
           cmp bWaterTemp, dl            ; ���� ���५���?
           jb $+6                        ; ���室, �᫨ ���
  L_NS2inc:           
           inc bStep                     ; ����. 蠣 - ������
           ;call ZeroDrv
 L_NS3:           
           cmp bStep, 3                  ; ������?
           jne L_NS4                     ; ���室, �᫨ ���
           lea bx, wWSMinute             ; ����প� 1 ���.
           mov cx, ONE_SEK*60            
           call Pause
           jnz $+12
           dec bTimeWash                 ; �����蠥� �६� ��ન
           jnz $+6                       ; ���室, �᫨ �� ����� ��ન
           inc bStep                     ; ����. 蠣 - ����
 L_NS4:           
           cmp bStep, 4                  ; ����?
           je L_NS                       ; ���室, �᫨ ��
           cmp bStep, 7
           jne L_NS5
 L_NS:           
           cmp bWaterLevel, 00           ; ���� ᫨�?
           ja $+6                        ; ���室, �᫨ ���
           inc bStep                     ; ����. 蠣 - ����� ��� ����᪠���
 L_NS5:           
           cmp bStep, 5                  ; ����� ��� ����᪠���?
           jne L_NS6                     ; ���室, �᫨ ���
           mov bParam[0], 1              ; �⮡ࠦ��� "����� ������"                      
           cmp bWaterLevel, LEVEL_RING   ; ���� �����?
           jb $+6                        ; ���室, �᫨ ���
           inc bStep                     ; ����. 蠣 - ����������
 L_NS6:           
           cmp bStep, 6                  ; ����������?
           jne L_NS8                     ; ���室, �᫨ ���
           lea bx, wTimeRing             ; �६� ����᪠��� (䨪�.)
           mov cx, 0                     
           call Pause           
           jnz $+6                       ; ���室, �᫨ �� �����
           inc bStep                     ; ����. 蠣 - ����
 L_NS8:           
           cmp bStep, 8                  ; �����. ����������?
           jne L_NS9                     ; ���室, �᫨ ���
           call Balanced                 ; 
 L_NS9:
           cmp bStep, 9                  ; �����?
           jne L_NSend                   ; ���室, �᫨ ���
           call Spin                     ;
 L_NSend:           
           ret
NextStep   EndP

;**********************/������ �� �訡�� ��⥬� ����� ����\**********************
; >DONE<
Error1     Proc
           cmp bError, 01h
           jne L_ERR1end                    
           mov bfOutDevice[ePulm], 0FFh    ; ������� ����
           cmp bWaterLevel, 3
           ja L_ERR1nxt
           mov bfOutDevice[ePulm], 0       ; �몫���� ����
 L_ERR1nxt:           
           lea bx, wTimeErr1               ; ����প� 2 ���  
           mov cx, 0
           call Pause
           jnz L_ERR1end           
           cmp bWaterLevel, 5
           jbe L_ERR1off 
 L_ERR1off:
           call Init   
 L_ERR1end:                   
           ret
Error1     EndP

;**********************/������ �� �訡�� ��⥬� ᫨�� ����\**********************
; >DONE<
Error2     Proc
           cmp bError, 02h
           jne L_ERR2end
           mov bfOutDevice[ePulm], 0FFh           
           lea bx, wTimeErr2
           mov cx, 0
           call Pause
           jz L_ERR2off
           cmp bWaterLevel, 0
           jne L_ERR2end
 L_ERR2off:                   
           call Init
 L_ERR2end:           
           ret
Error2     EndP

;************************/������ �� �訡�� ࠡ��� ����\****************************
; >DONE<
Error3     Proc
           cmp bError, 03h
           jne L_ERR3end
           mov bfOutDevice[eHeat], 00     ; �몫���� ���
           cmp bfStart, 0FFh
           jne L_ERR3end
           cmp bWaterTemp, 0E6h           ; <90C?
           ja L_ERR3end               
 ; �த������ ࠡ���           
           mov bError, 0
           mov bfWork, 0FFh
           mov bfWorkHeater, 00           ; ����� �த�������� ��� ���ॢ�              
           jmp L_ERR3end
 L_ERR3off:
           call Init
 L_ERR3end:                      
           ret
Error3     EndP

;************************/������ �� ����⮩ �����\**********************
;  >DONE<
Error4     Proc
           cmp bError, 04
           jne L_ERR4end
           lea bx, wTimeErr4
           mov cx, 0           
           call Pause               
           jz L_ERR4off
           cmp bfStart, 0FFh
           jne L_ERR4end
           cmp bfDoorLock, 0FFh
           jne L_ERR4end
           mov bError, 0
           mov bfWork, 0FFh
           jmp L_ERR4end           
 L_ERR4off:
           call Init
 L_ERR4end:                      
           ret
Error4     EndP

Error5     Proc
           cmp bError, 05
           jne L_ERR5end
           mov bfDoorBlocking, 00h        ; ���������㥬 ������
           lea bx, wTimeErr5
           mov cx, 0        
           call Pause               
           jz L_ERR5off
           cmp bfStart, 0FFh
           jne L_ERR5end
           mov bError, 0
           mov bfWork, 0FFh
           mov wTimeDefB, TDEFB
           mov bfDoorBlocking, 0FFh       ; �����஢�� ����祭�! 
           jmp L_ERR5end
 L_ERR5off:
           call Init           
 L_ERR5end:           
           ret
Error5     EndP

;****************************/����樨 �� �訡��\******************************
Reaction   Proc
           cmp bError, 0
           je L_REACend
           cmp bStep, 0
           jne L_REACexec
           cmp bfStart, 0FFh
           jne $+12
           mov bError, 0
           mov bfStart, 0         
           jmp L_REACend
 L_REACexec:           
           mov bfWork, 00
           push es           
           mov ax, Data
           mov es, ax 
           cld
           lea di, bfOutDevice
           mov cx, length bfOutDevice
           mov al, 0
 rep       stosb                         ; �몫�砥� �� ��. ����-��
           pop es
           
           call Error1
           call Error2
           call Error3
           call Error4
           call Error5

 L_REACend:           
           ret
Reaction   EndP