
;********************/����஢���� ��⥬� ����� ����\*************************
TstSysFill Proc
; �訡�� 䨪������, �᫨ ���� �� ����� 
; �� �஢�� ���. ���� ��� ������ �� 4 ������.
; ����� 䨪������ ��५��, ����� ���� �ॢ�蠥� ���孨� �஢��� (20 �.)

           cmp bfOutDevice[eFill], 0FFh        ; ��. �� ����祭?
           jne L_TSGover
           cmp bWaterLevel, 32h          ; >= 4�. ?
           jae L_TSGover
           lea bx, wTimeTstFill
           mov cx, TTSTF
           call Pause
           jnz L_TSGover                 ; ���室, �᫨ �� ��諮 4 ���.
           mov bError, 01h
 L_TSGover:            
           cmp bWaterLevel, 0FAh         ; >= 20�. ?
           jb L_TSGend    
           mov bError, 01h
 L_TSGend:           
           ret
TstSysFill EndP

; *********************/����஢���� ��⥬� ᫨�� ����\**********************
TstSysPulm Proc
; �訡�� 䨪������, �᫨ ���� �� ᫨�
; ��� ������ �� 5 �����

           cmp bfOutDevice[ePulm], 0FFh
           jne L_TSPend
           cmp bWaterLevel, 0Ch
           jb L_TSPend
           lea bx, wTimeTstPulm
           mov cx, TTSTHP           
           call Pause
           jnz L_TSPend
           mov bError, 02h
           mov wTimeTstPulm, 0           
 L_TSPend:           
           ret
TstSysPulm EndP

; ********************
TstHeater  Proc
; ����ࠢ����� 䨪������, �᫨ ⥬�-� ���� >95C, ���� 
; ��᫥ ����祭�� ���� ⥬�-� ���� � �祭�� 10 ��� 
; ������� ����� 祬 �� 3�.
           
           cmp bfOutDevice[eHeat], 0FFh
           je L_THtst
           cmp bWaterTemp, 0F3h        ; ����� 95�?
           ja L_THerr                
           jmp L_THend
 L_THtst:           
           cmp bfTmp, 0FFh
           je L_THpause
           mov al, bWaterTemp
           mov bTemp, al
           mov bfTmp, 0FFh
 L_THpause:            
           lea bx, wTimeTstHeated
           mov cx, TTSTHP               ; 10 �����
           call Pause
           jnz L_THend    
           mov bfTmp, 00       
           mov al, bWaterTemp
           sub al, bTemp
           cmp al, 07h                   ; ��������� ����� 3�?
           ja L_THend                    ; ���室, �᫨ ���
 L_THerr:           
           mov bError, 03h
           jmp L_THend                   
 L_THend:            
           ret           
TstHeater  EndP

TstLock    Proc
           cmp bfWork, 0FFh
           jne L_TLend
           cmp bfDoorLock, 0FFh
           je L_TLend
           mov bError, 04h
 L_TLend:           
           ret
TstLock    EndP

TstBalance Proc
           cmp bStep, 8
           jne L_TUBend
           cmp bfUnBalance, 0FFh
           jne L_TUBend
           inc bCounterUB
           cmp bCounterUB, MAX_ERR_UB
           jne L_TUBend
           mov bCounterUB, 0
           mov bError, 05h           
 L_TUBend:           
           ret
TstBalance EndP          
