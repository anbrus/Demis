%NOLIST
%CREFALL
PAGE 64,70
.286
;###############################  ���������  ################################
;################################################# ������� ����樨 ��।�
;***************  �����, ᪮����, ��ଫ����
SParamMsg STRUC
          Num       db        0         ; 0-7
          Speed     db        0         ; 0/1
          Effect    db        0         ; 0-5
          Reserv1   db        0
ENDS
;################################################ ������ ���ﭨ� ����������
;************  ������ ��䥪⮢, ᪮���, �����, �ࠢ�����, ᮮ�饭��
RKeyboard RECORD {
          Reserv2:13=0
          EditKeys:2=0
          ProgrKey:1=0
          SpeedKeys:2=0
          EffectKeys:6=0
          MsgKeys:8=0
}
; 31 30 28  26  24  22  20  18  16  14  12  10 9 8 7 6 5 4 3 2 1 0
; ���������������������������������������������������������������Ͽ
; �0�0�0�0�0�0�0�0�0�0�0�0�0�2�1�1�2�1�6�5�4�3�2�1�8�7�6�5�4�3�2�1�
; ���������������������������������������������������������������Ĵ
;                           Edit�P�Spd�   Effect  �     Message   �
;############################################################################
;###############################  ���������  ################################
          TurnPosCount   =    15        ; ������⢮ ����権 � ��।�
          ShotsCount     =    20        ; ������⢮ ���஢ ���⠢��
          SizeMatrix     =    16        ; ࠧ��� ��ࠧ� ��࠭�
          SlowSpeed      =    8         ; ��������� ᪮����
          FastSpeed      =    1         ; ������ ᪮����
;############################################################################
data segment at 0BA00H
          StartData      =    $         ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;################################################# ��।� ᮮ�饭��
          Turn      SParamMsg TurnPosCount dup (<>)

          NumMsgs   dw        0         ; ������⢮ ᮮ�饭�� � ��।�
          CurTurnPos dw       0         ; ⥪��� ������ � ��।�
          CurMsg    dw        0         ; ⥪�饥 ᮮ�饭��:
                                        ;         0 - �� ��࠭�
                                        ;         1..8 - ᮮ�饭��
          CurSpeed  db        0         ; ⥪��� ᪮����
                                        ;         0 - �� ��࠭�
                                        ;         1..2 - ᪮����
          CurEffect db        0         ; ⥪�騩 ��䥪�
                                        ;         0 - �� ��࠭
                                        ;         1..6 - ��䥪�
          CurPos    dw        0         ; ������ � ᮮ�饭��
          LastPos   dw        0         ; ��᫥���� ������ � ᮮ�饭��

          CurShot   dw        0         ; ������ � ���⠢��
;################################################# ��ࠧ ��࠭�
          Matrix    db        SizeMatrix dup (?)
          MatrixMask db       0         ; ��᪠ ��䥪� ᮮ�襭��
          DinamicFill dw      0FF00h    ; ��᪠ �������᪮� �������
          DinCount  db        0         ; ����প� �������᪮� �������

          Ticks     dw        0         ; ����稭� ����প�
          Regime    db        0         ; ०�� ࠡ���
;################################################# ��ࠧ ����������
          Keyboard  RKeyboard <?>
          KbdError  db        ?         ; 0 - ����� �ᯮ�짮���� ��ࠧ
;###########################################################################
          EndData        =    $         ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
ends

stack segment at 0BA80H
                    db        200H dup (?)
          StkTop    label     word
ends

code segment
assume cs:code,ds:data
;#################################  ������  #################################
;################################################# ��᫠ 1..F
          Num_Zero  dd        000000000h     ; �����
                    dd        00080FE84h     ; Num_1
                    dd        0009CA2C4h     ; Num_2
                    dd        0006C9244h     ; Num_3
                    dd        000F8203Eh     ; Num_4
                    dd        000728A5Eh     ; Num_5
                    dd        00064927Ch     ; Num_6
                    dd        0001EE202h     ; Num_7
                    dd        0006C926Ch     ; Num_8
                    dd        0007C924Ch     ; Num_9
                    dd        000FC22FCh     ; Num_A
                    dd        0006C92FEh     ; Num_B
                    dd        00044827Ch     ; Num_C
                    dd        0007C82FEh     ; Num_D
                    dd        0008292FEh     ; Num_E
                    dd        0000212FEh     ; Num_F
;################################################# ���� ����������!
          LengthM0  dw        Message1 - Message0 - 2
          Message0  label     byte
                    db        0C0h,078h,046h,041h,07Fh,0C0h,000h,038h
                    db        044h,044h,038h,000h,03Ch,04Ah,04Ah,031h
                    db        000h,0FCh,024h,024h,018h,000h,038h,044h
                    db        044h,038h,000h,000h,000h,000h,07Ch,004h
                    db        004h,07Ch,000h,038h,044h,044h,038h,000h
                    db        044h,028h,07Ch,028h,044h,000h,020h,054h
                    db        054h,028h,040h,000h,040h,038h,004h,07Ch
                    db        000h,038h,044h,044h,038h,000h,03Ch,05Ah
                    db        054h,020h,000h,020h,054h,054h,038h,040h
                    db        000h,004h,07Ch,004h,000h,07Ch,050h,020h
                    db        000h,05Eh
;################################################# Hello! How your money?
          LengthM1  dw        Message2 - Message1 - 2
          Message1  label     byte
                    db        07Fh,008h,008h,008h,07Fh,000h,038h,054h
                    db        054h,058h,000h,07Fh,000h,07Fh,000h,038h
                    db        044h,044h,038h,000h,05Fh,000h,000h,000h
                    db        000h,07Fh,008h,008h,008h,07Fh,000h,038h
                    db        044h,044h,038h,000h,03Ch,040h,030h,040h
                    db        03Ch,000h,000h,000h,000h,01Ch,0A0h,0A0h
                    db        07Ch,000h,038h,044h,044h,038h,000h,03Ch
                    db        040h,040h,03Ch,000h,07Ch,008h,004h,004h
                    db        000h,000h,000h,000h,07Ch,004h,078h,004h
                    db        078h,000h,038h,044h,044h,038h,000h,07Ch
                    db        004h,004h,078h,000h,038h,054h,054h,058h
                    db        000h,01Ch,0A0h,0A0h,07Ch,000h,002h,051h
                    db        009h,006h
;################################################# ��室��, �� ��������!
          LengthM2  dw        Message3 - Message2 - 2
          Message2  label     byte
                    db        022h,041h,041h,049h,036h,000h,020h,054h
                    db        054h,038h,040h,000h,06Ch,010h,06Ch,000h
                    db        038h,044h,044h,038h,000h,0C0h,078h,044h
                    db        07Ch,0C0h,000h,07Ch,020h,010h,07Ch,000h
                    db        004h,07Ch,004h,000h,038h,054h,054h,058h
                    db        000h,080h,040h,000h,000h,000h,07Ch,010h
                    db        010h,07Ch,000h,038h,054h,054h,058h,000h
                    db        000h,000h,000h,07Ch,004h,004h,07Ch,000h
                    db        038h,044h,044h,038h,000h,044h,028h,07Ch
                    db        028h,044h,000h,020h,054h,054h,038h,040h
                    db        000h,040h,038h,004h,07Ch,000h,038h,054h
                    db        054h,058h,000h,038h,054h,054h,058h,000h
                    db        004h,07Ch,004h,000h,038h,054h,054h,058h
                    db        000h,05Fh
;################################################# � ��� �� ������ ���!
          LengthM3  dw        Message4 - Message3 - 2
          Message3  label     byte
                    db        007h,048h,048h,048h,03Fh,000h,000h,000h
                    db        000h,07Ch,010h,010h,07Ch,000h,020h,054h
                    db        054h,038h,040h,000h,038h,044h,044h,028h
                    db        000h,000h,000h,000h,03Ch,05Ah,054h,020h
                    db        000h,07Ch,050h,020h,000h,07Ch,000h,000h
                    db        000h,000h,07Ch,010h,010h,07Ch,000h,020h
                    db        054h,054h,038h,040h,000h,07Ch,021h,011h
                    db        07Ch,000h,0C0h,078h,044h,07Ch,0C0h,000h
                    db        039h,054h,054h,059h,000h,004h,07Ch,004h
                    db        000h,038h,054h,054h,058h,000h,000h,000h
                    db        000h,03Ch,05Ah,054h,020h,000h,038h,044h
                    db        044h,028h,000h,039h,054h,054h,059h,000h
                    db        05Fh
;################################################# ���த���!
          LengthM4  dw        Message5 - Message4 - 2
          Message4  label     byte
                    db        07Fh,009h,009h,009h,006h,000h,020h,054h
                    db        054h,038h,040h,000h,038h,044h,044h,028h
                    db        000h,07Ch,004h,004h,07Ch,000h,0FCh,024h
                    db        024h,018h,000h,038h,044h,044h,038h,000h
                    db        0C0h,078h,044h,07Ch,0C0h,000h,020h,054h
                    db        054h,038h,040h,000h,044h,028h,07Ch,028h
                    db        044h,000h,020h,054h,054h,038h,040h,000h
                    db        05Fh
;################################################# ��� ��� ��襣� 㤮�����⢨�.
          LengthM5  dw        Message6 - Message5 - 2
          Message5  label     byte
                    db        07Fh,049h,049h,049h,036h,000h,038h,044h
                    db        044h,028h,000h,039h,054h,054h,059h,000h
                    db        000h,000h,000h,0C0h,078h,044h,07Ch,0C0h
                    db        000h,040h,038h,004h,07Ch,000h,068h,014h
                    db        014h,07Ch,000h,000h,000h,000h,03Ch,05Ah
                    db        054h,020h,000h,020h,054h,054h,038h,040h
                    db        000h,07Ch,040h,070h,040h,07Ch,000h,038h
                    db        054h,054h,058h,000h,07Ch,004h,004h,000h
                    db        038h,044h,044h,038h,000h,000h,000h,000h
                    db        01Ch,0A0h,0A0h,07Ch,000h,0C0h,078h,044h
                    db        07Ch,0C0h,000h,038h,044h,044h,038h,000h
                    db        03Ch,05Ah,054h,020h,000h,038h,044h,044h
                    db        038h,000h,040h,038h,004h,07Ch,000h,07Ch
                    db        050h,020h,000h,038h,044h,044h,028h,000h
                    db        004h,07Ch,004h,000h,03Ch,05Ah,054h,020h
                    db        000h,07Ch,020h,010h,07Ch,000h,068h,014h
                    db        014h,07Ch,000h,040h
;################################################# ������ !!!
          LengthM6  dw        Message7 - Message6 - 2
          Message6  label     byte
                    db        03Eh,041h,041h,041h,022h,000h,07Ch,010h
                    db        028h,044h,000h,07Ch,020h,010h,07Ch,000h
                    db        0C0h,078h,044h,07Ch,0C0h,000h,07Ch,010h
                    db        028h,044h,000h,07Ch,020h,010h,07Ch,000h
                    db        000h,000h,05Fh,000h,05Fh,000h,05Fh
;################################################# �� ᢨ�����!
          LengthM7  dw        MsgArray - Message7
          Message7  label     byte
                    db        0C0h,078h,046h,041h,07Fh,0C0h,000h,038h
                    db        044h,044h,038h,000h,000h,000h,000h,038h
                    db        044h,044h,028h,000h,03Ch,05Ah,054h,020h
                    db        000h,07Ch,020h,010h,07Ch,000h,0C0h,078h
                    db        044h,07Ch,0C0h,000h,020h,054h,054h,038h
                    db        040h,000h,07Ch,010h,010h,07Ch,000h,07Ch
                    db        020h,010h,07Ch,000h,068h,014h,014h,07Ch
                    db        000h,05Fh

          MsgArray  dw        Message0, Message1, Message2, Message3
                    dw        Message4, Message5, Message6, Message7
;################################################# >> ���⠢�� <<
          Shot01    db        000h,000h,081h,000h,000h,000h,000h,000h
                    db        000h,000h,000h,081h,0C3h,081h,000h,000h
                    db        000h,000h,000h,000h,042h,0E7h,042h,000h
                    db        000h,000h,000h,000h,000h,024h,07Eh,024h
                    db        000h,000h,000h,000h,000h,000h,018h,03Ch
                    db        000h,000h,000h,000h,000h,000h,000h,018h
                    db        000h,000h,000h,000h,000h,000h,018h,024h
                    db        000h,000h,000h,000h,000h,03Ch,042h,05Ah
                    db        000h,000h,000h,000h,03Ch,042h,099h,0A5h
                    db        000h,000h,000h,07Eh,081h,03Ch,042h,05Ah
                    db        000h,000h,07Eh,081h,03Ch,042h,099h,0A5h
                    db        000h,0FFh,000h,07Eh,081h,03Ch,042h,05Ah
                    db        0FFh,000h,07Eh,081h,03Ch,042h,099h,0A5h
                    db        000h,0FFh,000h,07Eh,081h,03Ch,042h,042h
                    db        0FFh,000h,07Eh,081h,03Ch,042h,081h,081h
                    db        000h,0FFh,000h,07Eh,081h,000h,000h,000h
                    db        0FFh,000h,07Eh,081h,000h,000h,000h,000h
                    db        000h,0FFh,000h,000h,000h,000h,000h,000h
                    db        0FFh,000h,000h,000h,000h,000h,000h,000h
                    db        000h,000h,000h,000h,000h,000h,000h,000h
;################################################# ᮮ�饭�� � ���� ��।�
          EndTurn   db        07Fh,049h,049h,049h,036h,000h,038h,044h
                    db        044h,028h,000h,039h,054h,054h,059h,000h
;#####################################################################
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;###############################  ���������  ###############################
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\ ���⨥ ��ࠧ� ���������� /\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
TakeKeys PROC
          push AX
          push CX
          push DX

          in AL,0                       ; port 0 -> ProgrKey
          and AL,1
          mov AH,AL                     ;           AH: bit 0
          in AL,1                       ; port 1 -> EditKeys
          and AL,3
          shl AL,EditKeys - 16
          or AL,AH                      ;           AH: bits 1,2
          and AX,0007h
          mov word ptr Keyboard+2,AX
          in AL,3                       ; port 3 -> EffectKeys & SpeedKeys
          ror AL,2                      ;           AX: bits 8..15
          mov AH,AL
          in AL,2                       ; port 2 -> MsgKeys
                                        ;           AX: bits 0..7
          mov word ptr Keyboard,AX

          mov CX,16                     ; ������ ������⢠ ������� ������
          xor DL,DL
TK_Next1: shr AX,1
          adc DL,0
          loop TK_Next1
          mov CX,3
          mov AX,word ptr Keyboard+2
TK_Next2: shr AX,1
          adc DL,0
          loop TK_Next2

          and DL,11111110b
          mov KbdError,DL

          pop DX
          pop CX
          pop AX
          ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\ ��楤�� ᮧ����� ��।� /\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
MakeTurn PROC
          cmp KbdError,0
          jnz $+10                      ; �᫨ ��� �訡�� � ���������
          test word ptr Keyboard+2,1    ; ������ "�ண�./��."?
          jz MT_Progr                   ; �� ����� (०�� �ணࠬ��஢����)
          ret

MT_Progr: cmp Regime,0
          je MT_NFst
          mov CurMsg,0
          mov CurSpeed,0
          mov CurEffect,0
          mov Regime,0
MT_NFst:  push AX
          push CX
          push BX
          push SI
          push DI

          mov AX,word ptr Keyboard
          and AX,MASK MsgKeys           ; �஢�ઠ ������ ᮮ�饭��
          or AX,AX
          jz MT_Next1                   ; �� ������
MT_Cycl1: shr AL,1
          inc AH
          jnc MT_Cycl1
          mov byte ptr CurMsg,AH
          jmp MT_Out

MT_Next1: mov AX,word ptr Keyboard
          and AX,MASK EffectKeys        ; �஢�ઠ ������ ��䥪⮢
          or AX,AX
          jz MT_Next2                   ; �� ������
          xchg AL,AH
MT_Cycl2: shr AL,1
          inc AH
          jnc MT_Cycl2
          mov CurEffect,AH
          jmp MT_Out

MT_Next2: mov AX,word ptr Keyboard
          and AX,MASK SpeedKeys         ; �஢�ઠ ������ ᪮��⥩
          or AX,AX
          jz MT_Next3                   ; �� ������
          rol AX,2
          shr AL,1
          inc AL
          mov CurSpeed,AL
          jmp MT_Out

MT_Next3: test word ptr Keyboard+2,2    ; �஢�ઠ ������ "�����"
          jz MT_Next4                   ; �� �����

          cmp CurMsg,0                  ; �஢�ઠ ��࠭��� ��ࠬ��஢
          jz MT_Out                     ; �᫨ �� ��࠭� ᮮ�饭��
          cmp CurSpeed,0
          jz MT_Out                     ; �᫨ �� ��࠭� ᪮����
          cmp CurEffect,0
          jz MT_Out                     ; �᫨ �� ��࠭ ��䥪�

          cmp NumMsgs,TurnPosCount      ; �஢�ઠ ������������ ��।�
          jae MT_Out
          mov BX,NumMsgs
          shl BX,2
          mov AL,byte ptr CurMsg
          dec AL
          mov [BX+offset Turn].Num,AL
          mov AL,CurSpeed
          dec AL
          mov [BX+offset Turn].Speed,AL
          mov AL,CurEffect
          dec AL
          mov [BX+offset Turn].Effect,AL
          inc NumMsgs
          mov CurMsg,0
          mov CurSpeed,0
          mov CurEffect,0
          jmp MT_Out

MT_Next4: test word ptr Keyboard+2,4    ; �஢�ઠ ������ "� ��砫�"
          jz MT_Out                     ; �� �����
          mov NumMsgs,0
          mov CurMsg,0
          mov CurSpeed,0
          mov CurEffect,0

MT_Out:   cmp NumMsgs,TurnPosCount      ; �஢�ઠ ������������ ��।�
          jae MT_Full                   ; �᫨ ���������
          mov SI,offset Matrix          ; ����

          mov BX,NumMsgs                ; �⮡ࠦ���� ����� � ��।�
          inc BX
          shl BX,2
          mov AX,word ptr CS:[BX+offset Num_Zero]
          mov [SI],AX
          mov AX,word ptr CS:[BX+offset Num_Zero+2]
          mov [SI+2],AX

          mov BX,CurMsg                 ; �⮡ࠦ���� ����� ᮮ�饭��
          shl BX,2
          mov AX,word ptr CS:[BX+offset Num_Zero]
          mov [SI+4],AX
          mov AX,word ptr CS:[BX+offset Num_Zero+2]
          mov [SI+6],AX

          mov BL,CurSpeed               ; �⮡ࠦ���� ᪮���
          xor BH,BH
          shl BX,2
          mov AX,word ptr CS:[BX+offset Num_Zero]
          mov [SI+8],AX
          mov AX,word ptr CS:[BX+offset Num_Zero+2]
          mov [SI+10],AX

          mov BL,CurEffect              ; �⮡ࠦ���� ��䥪�
          xor BH,BH
          shl BX,2
          mov AX,word ptr CS:[BX+offset Num_Zero]
          mov [SI+12],AX
          mov AX,word ptr CS:[BX+offset Num_Zero+2]
          mov [SI+14],AX
          jmp MT_Exit

MT_Full:  mov SI,offset EndTurn         ; �뢮� "���"
          mov DI,offset Matrix
          mov CX,16
MT_Next5: mov AL,CS:[SI]
          mov [DI],AL
          inc SI
          inc DI
          loop MT_Next5

MT_Exit:  mov MatrixMask,0
          mov Ticks,0

          pop DI
          pop SI
          pop BX
          pop CX
          pop AX
          ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\  �뢮� ��� ᮮ�饭�� /\/\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
PutMessage PROC
          push AX
          push CX
          push BX
          push SI
          push DI

          xor AL,AL
          mov CX,SizeMatrix
          mov DI,offset Matrix
      rep stosb

          xor SI,SI
          mov BX,CurMsg
          shl BX,1
          mov BX,CS:[BX+offset MsgArray]
          mov DI,CurPos
          cmp DI,0
          jge PM_Next1
          neg DI
          add SI,DI
          xor DI,DI
PM_Next1: cmp SI,16
          je PM_Out
          cmp DI,LastPos
          je PM_Out
          mov AL,CS:[BX+DI]
          mov [SI+offset Matrix],AL
          inc SI
          inc DI
          jmp PM_Next1
PM_Out:   pop DI
          pop SI
          pop BX
          pop CX
          pop AX
          ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\ �������� ��᪨ ��䥪� /\/\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
PutEffect PROC
          push AX
          cmp CurEffect,0
          jne PE_Next1
          mov MatrixMask,000h           ; ��� �� ������
          jmp PE_Exit
PE_Next1: cmp CurEffect,1
          jne PE_Next2
          mov MatrixMask,0FFh           ; ���� �� �୮��
          jmp PE_Exit
PE_Next2: cmp CurEffect,2
          jne PE_Next3
          mov MatrixMask,0F0h           ; ��� ����, ���� ���
          jmp PE_Exit
PE_Next3: cmp CurEffect,3
          jne PE_Next4
          mov MatrixMask,00Fh           ; ���� ����, ��� ���
          jmp PE_Exit
PE_Next4: cmp CurEffect,4
          jne PE_Next5
          mov AL,byte ptr DinamicFill   ; �������᪠� ������� � ����� � ���
          mov MatrixMask,AL
          inc DinCount
          and DinCount,003h
          jne PE_Pass1
          rol DinamicFill,1
PE_Pass1: jmp PE_Exit
PE_Next5: cmp CurEffect,5
          jne PE_Exit
          mov AL,byte ptr DinamicFill   ; �������᪠� ������� � ���� � ����
          mov MatrixMask,AL
          inc DinCount
          and DinCount,003h
          cmp DinCount,0
          jne PE_Exit
          ror DinamicFill,1
PE_Exit:  pop AX
          ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\ ��楤�� �뢮�� ��।� /\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
OutTurn PROC
          test word ptr Keyboard+2,1    ; ������ "�ண�./��."?
          jz OT_Quit                    ; �� ����� (०�� �ணࠬ��஢����)
          cmp Ticks,0                   ; ������� ����প�?
          je OT_View
OT_Quit:  ret

OT_View:  cmp Regime,1
          je OT_NFst
          mov CurTurnPos,-1
          mov CurShot,0
          mov Regime,1
OT_NFst:  push AX
          push BX
          push CX
          push SI
          push DI

          mov BX,CurTurnPos
          cmp BX,NumMsgs                ; �����稫��� ��।�?
          jae OT_Film                   ; ��
          mov BX,CurPos
          cmp BX,LastPos                ; �����稫��� ᮮ�饭��?
          jge OT_Film                   ; ��
          jmp OT_Next1

OT_Film:  cmp CurShot,ShotsCount        ; �����稫��� �����?
          jae OT_Pass0                  ; ��
          jmp OT_NxSht

OT_Pass0: mov BX,CurTurnPos
          cmp BX,NumMsgs                ; �����稫��� ��।�?
          jb OT_Pass1                   ; ���
          mov CurTurnPos,-1
          mov CurPos,32767
OT_Pass1: mov BX,CurPos
          cmp BX,LastPos                ; �����稫��� ᮮ�饭��?
          jl OT_Next1                   ; ���
          inc CurTurnPos
          mov BX,CurTurnPos
          shl BX,2
          mov AX,[BX+offset Turn].Num
          mov byte ptr CurMsg,AL
          mov CurSpeed,AH
          mov AL,[BX+offset Turn].Effect
          mov CurEffect,AL
          mov BX,CurMsg
          shl BX,1
          mov BX,CS:[BX+offset MsgArray]
          mov AX,CS:[BX-2]
          mov LastPos,AX

          mov CurPos,-15
          mov CurShot,0
          mov DinamicFill,0FF00h
          mov DinCount,0

OT_Next1: call PutEffect
          call PutMessage
          inc CurPos
          cmp CurSpeed,0
          je OT_Pass3
          mov Ticks,FastSpeed
          jmp OT_Exit
OT_Pass3: mov Ticks,SlowSpeed
          jmp OT_Exit

OT_NxSht: mov MatrixMask,0              ; �뢮� 䨫쬠
          mov BX,CurShot
          shl BX,3
          mov SI,offset Matrix
          mov DI,offset Matrix+15
          mov CX,8
OT_NxByte:mov AL,CS:[BX+offset Shot01]
          mov [SI],AL                   ;� ���������
          mov [DI],AL                   ;�  �뢮� ����
          inc SI
          dec DI
          inc BX
          loop OT_NxByte
          inc CurShot

OT_Exit:  pop DI
          pop SI
          pop CX
          pop BX
          pop AX
          ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\/\/\/\/\ ����প� /\/\/\/\/\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
Pause PROC
          cmp Ticks,0
          je P_Exit
          dec Ticks
P_Exit:   ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\/\  �뢮� ��ࠧ� ��࠭� /\/\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
OutMatrix PROC
          push AX
          push CX
          push DX
          push SI

          mov SI,offset Matrix
          xor DX,DX
          mov CX,SizeMatrix
OM_Next:  mov AL,[SI]
          xor AL,MatrixMask
          out DX,AL
          inc SI
          inc DX
          loop OM_Next

          pop SI
          pop DX
          pop CX
          pop AX
          ret
ENDP
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;/\/\/\/\/\/\/\/\ ���樠������ ��६����� /\/\/\/\/\/\/\/\
;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
Init PROC
          push AX
          push CX
          push DI

          xor AL,AL
          mov CX,EndData-StartData
          mov DI,offset Matrix
      rep stosb

          mov DinamicFill,0FF00h

          pop DI
          pop CX
          pop AX
          ret
ENDP
;############################################################################
;############################ �᭮���� �ணࠬ�� ############################
begin:    mov AX,data
          mov DS,AX
          mov ES,AX
          mov AX,stack
          mov SS,AX
          mov SP,offset StkTop

          call Init
Cycle1:   call TakeKeys
          call MakeTurn
          call OutTurn
          call Pause
          call OutMatrix
          jmp Cycle1

          org 07F0H
start:    jmp begin

ends

end start
;########################### That's all folks !!! ###########################