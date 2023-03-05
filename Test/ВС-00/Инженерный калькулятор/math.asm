;------------------------------------------------------------
; math.asm
; ��� ��⥬�⨪� � TQuantity128bit
;------------------------------------------------------------
;

; Clear128bit    - ��頥�(������) �᫮ TQuantity128bit
; di - ���� �᫠
;
Clear128bit proc near
           push  ax cx di
           xor   ax,ax
           mov   cx,8
  Clear128bit_1:
           mov  [di],ax
           add   di,1*2
           loop Clear128bit_1
           pop   di cx ax
           ret
Clear128bit endp

; Move_1_128bit    - �����뢠�� "1" TQuantity128bit
; di - ���� �᫠
;
Move_1_128bit proc near
           push  di
           call  Clear128bit
           mov   word ptr [di+1],1
           call  Mant128bitNorm
           mov   byte ptr [di],1
           pop   di
           ret
Move_1_128bit endp

; Move_cx_128bit    - �����뢠�� cx TQuantity128bit
; di - ���� �᫠
; cx - �� ��⠢�塞
;
Move_cx_128bit proc near
           push  ax bx cx dx di
           call  Clear128bit
           mov   word ptr [di+1],cx
           call  Mant128bitNorm
           
           mov   al,byte ptr [di]
           add   al,29
           mov   byte ptr [di],al
           
           pop   di dx cx bx ax
           ret
Move_cx_128bit endp

; Move_cx_128bit    - �����뢠�� Pi TQuantity128bit, �筮��� 64bit
; di - ���� �᫠
;
Move_Pi_128bit proc near
           push  ax bx cx dx di
           call  Clear128bit
           
           mov   word ptr [di+1],049D6h
           mov   word ptr [di+3],0A232h
           mov   word ptr [di+5],02DDFh
           mov   word ptr [di+7],02B99h
           call  Mant128bitNorm
           
           mov   byte ptr [di],1           
           pop   di dx cx bx ax
           ret
Move_Pi_128bit endp
  


; Copy128bit     - �������  TQuantity128bit
; di             - ���� �ਥ�����
; si             - ���� ���筨��
;
Copy128bit proc near
           push  ax di si
           mov   cx,8
  Copy128bit_1:
           mov   ax,[si]
           mov   [di],ax
           add   di,1*2
           add   si,1*2
           loop  Copy128bit_1
           pop   si di ax
           ret
Copy128bit endp

; Cmp128bit      - �ࠢ������ ��� ������� TQuantity128bit �᫠
; di             - ���� ������          
; si             - ���� �ࠢ���
; ax             - १���� {-1} di < si, {0} di == si, {1} di > si
; 
Cmp128bit  proc near           
           mov   ax,[di+13]
           cmp   ax,[si+13]
           jg    Cmp128bit_greater
           jl    Cmp128bit_less
           mov   ax,[di+11]
           cmp   ax,[si+11]
           jg    Cmp128bit_greater
           jl    Cmp128bit_less
           mov   ax,[di+9]
           cmp   ax,[si+9]
           jg    Cmp128bit_greater
           jl    Cmp128bit_less
           mov   ax,[di+7]
           cmp   ax,[si+7]
           jg    Cmp128bit_greater
           jl    Cmp128bit_less
           mov   ax,[di+5]
           cmp   ax,[si+5]
           jg    Cmp128bit_greater
           jl    Cmp128bit_less
           mov   ax,[di+3]
           cmp   ax,[si+3]
           jg    Cmp128bit_greater
           jl    Cmp128bit_less
           mov   ax,[di+1]
           cmp   ax,[si+1]
           jg    Cmp128bit_greater
           jl    Cmp128bit_less           
  Cmp128bit_equal:
           mov   ax,0
           jmp   Cmp128bit_end
  Cmp128bit_greater:           
           mov   ax,1
           jmp   Cmp128bit_end
  Cmp128bit_less:  
           mov   ax,-1
           jmp   Cmp128bit_end
  Cmp128bit_end: 
           ret
Cmp128bit  endp

; Neg128bit -    ���頥� ���� �᫠
; di        -    ᬥ饭�� �᫠
;
Neg128bit  proc  near
           push  ax
           
           not   word ptr [di+1]
           not   word ptr [di+3]
           not   word ptr [di+5]
           not   word ptr [di+7]
           not   word ptr [di+9]
           not   word ptr [di+11]
           not   word ptr [di+13]
           
           add   word ptr [di+1],1
           adc   word ptr [di+3],0
           adc   word ptr [di+5],0
           adc   word ptr [di+7],0
           adc   word ptr [di+9],0
           adc   word ptr [di+11],0
           adc   word ptr [di+13],0
           
           pop   ax
           ret
Neg128bit  endp

; DivWorkMul - ������� WorkMul �� 10E28 � 㬥��襭���[di]
;
DivWorkMul proc near
           push  ax bx cx si
           
           
           mov   si,0
           
                      
  DivWorkMul_0:           
           mov   cx,10
           mov   bx,2*14
           xor   dx,dx
  DivWorkMul_0_1:  
           dec   bx                  
           dec   bx                  
           mov   ax,WorkMul[bx]   
           div   cx
           mov   WorkMul[bx],ax

           cmp   bx,0
           jne   DivWorkMul_0_1
           
           inc   si
           cmp   si,28
           jne   DivWorkMul_0
           dec   byte ptr [di]
           
           mov   bx,0
           mov   cx,7           
           push  di
  DivWorkMul_2:
           mov   ax,WorkMul[bx]
           mov   [di+1],ax
           add   bx,2
           add   di,2
           loop  DivWorkMul_2
           pop   di
           
           
           pop   si cx bx ax
           ret
DivWorkMul endp

; Div128bitToDW - ������� ������� TQuantity128bit(14byte) �� ᫮��; � ॣ���� di -
; ᬥ饭�� �������, � � cx - ���祭�� dw; ��⭮�
; ����頥��� �� ���� ��������, ���⮪ � modulo
;
Div128bitToDW proc near
           push  ax dx
   
           xor   dx,dx               
           mov   ax,[di+13-1]        
           div   cx         
           mov   [di+13-1],ax
         
           mov   ax,[di+11-1]        
           div   cx                           
           mov   [di+11-1],ax
         
           mov   ax,[di+9-1]        
           div   cx                  
           mov   [di+9-1],ax
         
         
           mov   ax,[di+7-1]        
           div   cx                  
           mov   [di+7-1],ax
         
           mov   ax,[di+5-1]        
           div   cx                  
           mov   [di+5-1],ax
         
           mov   ax,[di+3-1]        
           div   cx                  
           mov   [di+3-1],ax
         
           mov   ax,[di+1-1]        
           div   cx                  
           mov   [di+1-1],ax

           mov   modulo,dx
           
           pop   dx ax
           ret
Div128bitToDW endp

; Mul128bitToDW  - ��������� ������� TQuantity128bit(14byte) �� ᫮��; ��ࠬ����:
; di             - ᬥ饭�� �������,
; cx             - ���祭�� dw
;
Mul128bitToDW    proc near
           push  ax bx dx

           mov   ax,[di+1-1]
           mul   cx
           mov   [di+1-1],ax
           mov   bx,dx
           
           mov   ax,[di+3-1]
           mul   cx
           mov   [di+3-1],ax
           add   word ptr [di+3-1],bx
           adc   dx,0
           mov   bx,dx
           
           mov   ax,[di+5-1]
           mul   cx
           mov   [di+5-1],ax
           add   word ptr [di+5-1],bx
           adc   dx,0
           mov   bx,dx
           
           
           mov   ax,[di+7-1]
           mul   cx
           mov   [di+7-1],ax
           add   word ptr [di+7-1],bx
           adc   dx,0
           mov   bx,dx
           
           
           mov   ax,[di+9-1]
           mul   cx
           mov   [di+9-1],ax
           add   word ptr [di+9-1],bx
           adc   dx,0
           mov   bx,dx
           
           
           mov   ax,[di+11-1]
           mul   cx
           mov   [di+11-1],ax
           add   word ptr [di+11-1],bx
           adc   dx,0
           mov   bx,dx
           
           
           mov   ax,[di+13-1]
           mul   cx
           mov   [di+13-1],ax
           add   word ptr [di+13-1],bx
           
           
           pop   dx bx ax
           ret
Mul128bitToDW    endp

; �஢�ઠ ��९������� � ��⨯�९������
; ����⢥����� �᫠; ��ࠬ����:
; � di ᬥ饭�� ����⢥����� �᫠,
; � ॣ���� al �����頥��� 䫠� ��९�������:
; al = 0 - �� ��ଠ�쭮, al = FFh - ��९�������
;
OverflowChecking proc near
           mov   al,0
           cmp   byte ptr [di],29     ; �஢�ઠ
           jl    OverflowChecking_1   ; ��९�������
           mov   al,0FFh
           jmp   OverflowChecking_end

  OverflowChecking_1:
           cmp   byte ptr [di],-29    ; �஢�ઠ
           jg    OverflowChecking_end ; ��⨯�९�������
           call  Clear128bit          ; ������ ��設����
                                      ; ���
  OverflowChecking_end:
           ret
OverflowChecking endp


; Add128bit -    �������� ���� ����⢥���� �ᥫ; ��ࠬ����:
; di        -    ᬥ饭�� 1-��� ᫠������� � �㬬�,
; si        -    ᬥ饭�� 2-��� ��㬥��
;
Add128bit  proc near
           push  ax cx dx di si

           mov   al,[di]             ; �ࠢ�����
           cmp   al,[si]             ; ���浪��
           je    Add128bit_Eequal
           jl    Add128bit_Eless
           xchg  di,si

  Add128bit_Eless:
           xor   ch,ch               ; ��ࠢ�������
           mov   cl,[si]             ; ���浪��
           sub   cl,[di]
           call  Mant128bitDeNorm

  Add128bit_Eequal:  
           pop   si di

           mov   ax,[di+1]
           add   ax,[si+1]
           mov   [di+1],ax
           
           mov   ax,[di+3]
           adc   ax,[si+3]
           mov   [di+3],ax
           
           mov   ax,[di+5]
           adc   ax,[si+5]
           mov   [di+5],ax
           
           mov   ax,[di+7]
           adc   ax,[si+7]
           mov   [di+7],ax
           
           mov   ax,[di+9]
           adc   ax,[si+9]
           mov   [di+9],ax
           
           mov   ax,[di+11]
           adc   ax,[si+11]
           mov   [di+11],ax
           
           mov   ax,[di+13]
           adc   ax,[si+13]
           mov   [di+13],ax

           call  Mant128bitNorm    ; ��ଠ������
                                   ; �������
           pop   dx cx ax
           ret
Add128bit  endp

; Sub128bit -    ���⠭�� ���� ����⢥���� �ᥫ; ��ࠬ����:
; di        -    ᬥ饭�� 㬥��蠥���� � ࠧ����,
; si        -    ᬥ饭�� ���⠥����
;
Sub128bit  proc near
           push ax cx dx di si

           mov   al,[di]             ; �ࠢ�����
           cmp   al,[si]             ; ���浪��
           je    Sub128bit_Eequal
           jl    Sub128bit_Eless
           xchg  di,si

  Sub128bit_Eless:   
           xor   ch,ch               ; ��ࠢ�������
           mov   cl,[si]             ; ���浪��
           sub   cl,[di]
           call  Mant128bitDeNorm

  Sub128bit_Eequal:
           pop   si di

           mov   ax,[di+1]
           sub   ax,[si+1]
           mov   [di+1],ax
           
           mov   ax,[di+3]
           sbb   ax,[si+3]
           mov   [di+3],ax
           
           mov   ax,[di+5]
           sbb   ax,[si+5]
           mov   [di+5],ax
           
           mov   ax,[di+7]
           sbb   ax,[si+7]
           mov   [di+7],ax
           
           mov   ax,[di+9]
           sbb   ax,[si+9]
           mov   [di+9],ax
           
           mov   ax,[di+11]
           sbb   ax,[si+11]
           mov   [di+11],ax
           
           mov   ax,[di+13]
           sbb   ax,[si+13]
           mov   [di+13],ax           

           call  Mant128bitNorm      ; ��ଠ������
                                     ; �������
           pop   dx cx ax
           ret
Sub128bit  endp

; Mul128bit -    㬭������ ���� ����⢥���� �ᥫ; ��ࠬ����:
; di        -    ᬥ饭�� ��ࢮ�� � �ந��������,
; si        -    ᬥ饭�� ��ண�
;
Mul128bit  proc  near
Mul128bit_i      EQU [bp-2]
Mul128bit_j      EQU [bp-4]
Mul128bit_carry  EQU [bp-6]        

           push  ax bx cx dx
           enter 6,0
           mov   bl,[di+14]
           shr   bl,7
           jz    Mul128bit_NNeg1
           call  Neg128bit
  Mul128bit_NNeg1:
           mov   bh,[si+14]
           shr   bh,7
           jz    Mul128bit_NNeg2
           xchg  di,si
           call  Neg128bit
           xchg  di,si
  Mul128bit_NNeg2:
           push  bx
                      
           mov   al,[di]
           add   al,[si]
           mov   [di],al
           
           lea   bx,WorkMul
           mov   cx,14
  Mul128bit_MulClear:
           mov   word ptr [bx],0
           add   bx,2
           loop  Mul128bit_MulClear           
           ; ⥪�� 㬭������
           mov   Mul128bit_i,0           
           
  Mul128bit_1_begin:
           cmp   Mul128bit_i,7
           je    Mul128bit_1_end
           
           mov   Mul128bit_carry,0
           mov   Mul128bit_j,0
  Mul128bit_1_1_begin:
           cmp   Mul128bit_j,7
           je    Mul128bit_1_1_end
           mov   bx,Mul128bit_i
           shl   bx,1
           mov   ax,[di+bx+1]
           mov   bx,Mul128bit_j
           shl   bx,1           
           mul   word ptr [si+bx+1]
           
           mov   bx,Mul128bit_i
           add   bx,Mul128bit_j
           shl   bx,1
           add   WorkMul[bx],ax
           adc   dx,Mul128bit_carry
           mov   Mul128bit_carry,0
           adc   WorkMul[bx+2],dx
           adc   Mul128bit_carry,0   
           
           inc   Mul128bit_j
           jmp   Mul128bit_1_1_begin
  Mul128bit_1_1_end:
           inc   Mul128bit_i
           jmp   Mul128bit_1_begin
  Mul128bit_1_end:
           ; ⥪�� 㬭������
           ; �८�ࠧ������ WorkMul � [di]
           call  DivWorkMul 
           call  Mant128bitNorm
           
           pop   bx
           cmp   bh,0
           je    Mul128bit_2
           xchg  di,si
           call  Neg128bit
           xchg  di,si
  Mul128bit_2:
           xor   bh,bl
           cmp   bh,0
           je    Mul128bit_end
           call  Neg128bit
  Mul128bit_end:
           leave
           pop   dx cx bx ax
           ret
Mul128bit  endp

; Div128bit -    ������� ���� ����⢥���� �ᥫ; ��ࠬ����:
; di        -    ᬥ饭�� �������� � १����,
; si        -    ᬥ饭�� ����⥫�
;
Div128bit  proc  near
           push  ax bx cx dx
           mov   bl,[di+14]
           shr   bl,7
           jz    Div128bit_NNeg1
           call  Neg128bit
  Div128bit_NNeg1:
           mov   bh,[si+14]
           shr   bh,7
           jz    Div128bit_NNeg2
           xchg  di,si
           call  Neg128bit
           xchg  di,si
  Div128bit_NNeg2:
           push  bx
                      
           mov   al,[di]
           sub   al,[si]
           mov   [di],al
           
           lea   bx,WorkMul
           mov   cx,14
  Div128bit_MulClear:
           mov   word ptr [bx],0
           add   bx,2
           loop  Div128bit_MulClear
           
           ; ������� [di] � ����訥 7 word WorkMul � ��������� ��� �� 10 E29
           mov   ax,[di+1]
           mov   WorkMul[0],ax
           mov   ax,[di+3]
           mov   WorkMul[2],ax
           mov   ax,[di+5]
           mov   WorkMul[4],ax
           mov   ax,[di+7]
           mov   WorkMul[6],ax
           mov   ax,[di+9]
           mov   WorkMul[8],ax
           mov   ax,[di+11]
           mov   WorkMul[10],ax
           mov   ax,[di+13]
           mov   WorkMul[12],ax
           
           push  di si
           mov   cx,10
           mov   si,29
           mov   di,0
           xor   dx,dx
           xor   bx,bx
  Div128bit_0:           
           mov   ax,WorkMul[di]
           mul   cx
           mov   WorkMul[di],ax
           add   WorkMul[di],bx
           adc   dx,0
           mov   bx,dx
           inc   di
           inc   di
           cmp   di,26
           jne   Div128bit_0
           
           mov   di,0
           xor   bx,bx
           xor   dx,dx
           
           dec   si
           cmp   si,0           
           jne   Div128bit_0 
           pop   si di
           
           ; ⥪�� �������
           
           mov   cx,112               ; ������� ������ ��
                                 ; ������� � �����-
                                 ; �������� ���⪠
                                 
  Div128bit_1_begin:  
           shl   word ptr WorkMul,1   ; ᤢ�� ����� ��⭮��
           rcl   word ptr WorkMul+2,1 ; � ���⪠
           rcl   word ptr WorkMul+4,1
           rcl   word ptr WorkMul+6,1
           rcl   word ptr WorkMul+8,1
           rcl   word ptr WorkMul+10,1
           rcl   word ptr WorkMul+12,1
           rcl   word ptr WorkMul+14,1
           rcl   word ptr WorkMul+16,1
           rcl   word ptr WorkMul+18,1
           rcl   word ptr WorkMul+20,1
           rcl   word ptr WorkMul+22,1
           rcl   word ptr WorkMul+24,1
           rcl   word ptr WorkMul+26,1
           pushf                   ; ��࠭���� ��७��
           
           call  SubRemainder           

           jc    Div128bit_1_2                 ; �᫨ ࠧ����� < 0
           popf

  Div128bit_1_1:  
           add   word ptr WorkMul,1   ; ࠧ��
           adc   word ptr WorkMul+2,0 ; ��⭮�� = 1
           adc   word ptr WorkMul+4,0
           adc   word ptr WorkMul+6,0
           adc   word ptr WorkMul+8,0
           adc   word ptr WorkMul+10,0
           adc   word ptr WorkMul+12,0
           jmp   Div128bit_1_end

  Div128bit_1_2:  
           popf
           jc   Div128bit_1_1                 ; �஢�ઠ ��७�� ��
                                 ; ᤢ��� ���⪠
           call  RecoveryRemainder                      
           
   Div128bit_1_end:  
           loop  Div128bit_1_begin
           
           ; ⥪�� �������
           ; ������ [di] ����訥 7 word WorkMul
           mov   ax,WorkMul[0]
           mov   [di+1],ax
           mov   ax,WorkMul[2]
           mov   [di+3],ax
           mov   ax,WorkMul[4]
           mov   [di+5],ax
           mov   ax,WorkMul[6]
           mov   [di+7],ax
           mov   ax,WorkMul[8]
           mov   [di+9],ax
           mov   ax,WorkMul[10]
           mov   [di+11],ax
           mov   ax,WorkMul[12]
           mov   [di+13],ax
               
           call  Mant128bitNorm
           
           pop   bx           
           cmp   bh,0
           je    Div128bit_2
           xchg  di,si
           call  Neg128bit
           xchg  di,si
  Div128bit_2:
           xor   bh,bl
           cmp   bh,0
           je    Div128bit_end
           call  Neg128bit
  Div128bit_end:           
           pop   dx cx bx ax
           ret
Div128bit  endp

; SubRemainder - ���⠭�� �� ���⪠ ����⥫�
;
SubRemainder     proc near
           mov   ax,WorkMul+14         ; ���⠭�� �� 
           sub   ax,[si+1]             ; ���⪠ ����⥫�
           mov   WorkMul+14,ax
           
           mov   ax,WorkMul+16
           sbb   ax,[si+2+1]
           mov   WorkMul+16,ax
           
           mov   ax,WorkMul+18
           sbb   ax,[si+4+1]
           mov   WorkMul+18,ax
           
           mov   ax,WorkMul+20
           sbb   ax,[si+6+1]
           mov   WorkMul+20,ax
           
           mov   ax,WorkMul+22
           sbb   ax,[si+8+1]
           mov   WorkMul+22,ax
           
           mov   ax,WorkMul+24
           sbb   ax,[si+10+1]
           mov   WorkMul+24,ax
           
           mov   ax,WorkMul+26
           sbb   ax,[si+12+1]
           mov   WorkMul+26,ax
           ret
SubRemainder     endp

; RecoveryRemainder - ����⠭������� ���⪠ ���㬥��襭�� ����
;
RecoveryRemainder proc near
           mov   ax,WorkMul+14         
           add   ax,[si+1]             
           mov   WorkMul+14,ax
           
           mov   ax,WorkMul+16
           adc   ax,[si+2+1]
           mov   WorkMul+16,ax
           
           mov   ax,WorkMul+18
           adc   ax,[si+4+1]
           mov   WorkMul+18,ax
           
           mov   ax,WorkMul+20
           adc   ax,[si+6+1]
           mov   WorkMul+20,ax
           
           mov   ax,WorkMul+22
           adc   ax,[si+8+1]
           mov   WorkMul+22,ax
           
           mov   ax,WorkMul+24
           adc   ax,[si+10+1]
           mov   WorkMul+24,ax
           
           mov   ax,WorkMul+26
           adc   ax,[si+12+1]
           mov   WorkMul+26,ax
           ret
RecoveryRemainder endp

; Mant128bitDeNorm - ����ଠ������ �������, ��ࠬ����:
; di               - ᬥ饭�� ����⢥����� �᫠,
; cx               - ࠧ����� ���浪��
;
Mant128bitDeNorm proc near
           push  ax

           mov   ax,[di+13]
           shr   ax,15           
           jz    Mant128bitDeNorm_NNeg
           xor   ax,ax
           call  Neg128bit
           mov   al,0FFh           

 Mant128bitDeNorm_NNeg:  
           push  ax
           inc   di                  ; ���室 � ������
 Mant128bitDeNorm_1:  
           push  cx

           mov   cx,10               ; 横� ������� �������
           call  Div128bitToDW       ; �� 10 � 㢥��祭��
           inc   byte ptr [di-1]     ; ���浪� �� 1

           pop   cx
           loop  Mant128bitDeNorm_1
           dec   di

           pop   ax
           cmp   al,0FFh             ; �᫨ ������ ����-
           jne   Mant128bitDeNorm_end; 砫쭮 �뫠 ����-
           call  Neg128bit           ; ⥫쭠, � ��� �
                                     ; ��᫥ ����ଠ����樨
                                     ; ������ ���� ����-
                                     ; ⥫쭠
  Mant128bitDeNorm_end:  
           pop   ax
           ret
Mant128bitDeNorm endp

; Mant128bitNorm - ��ଠ������ �������, ��ࠬ����:
; di             - ᬥ饭�� ����⢥����� �᫠
;
Mant128bitNorm   proc near
           push  ax cx dx di si 

           mov   ax,[di+13]
           shr   ax,15           
           jz    Mant128bitNorm_NNeg
           xor   ax,ax
           call  Neg128bit
           mov   al,0FFh                             

 Mant128bitNorm_NNeg:
           push  ax
           inc   di                  ; ���室 � ������
                                     ; �� ��࠭����
           push  word ptr [di]
           push  word ptr [di+2]
           push  word ptr [di+4]
           push  word ptr [di+6]
           push  word ptr [di+8]
           push  word ptr [di+10]
           push  word ptr [di+12]    
          
           
           lea   si,Work             ; ���樠�����㥬 0 ��� �ࠢ�����
           xchg  di,si
           call  Clear128bit
           xchg  di,si
           
           mov   cx,10
   Mant128bitNorm_0:
           call  Div128bitToDW       ; ������ �᫠
           inc   ah                  ; �������� ���
           push  ax                  
           
           dec   di
           call  Cmp128bit
           inc   di
           
           cmp   ax,0
           pop   ax                  
           jne   Mant128bitNorm_0
           
           ; ����⠭�������
           ; �������
           pop   word ptr [di+12]
           pop   word ptr [di+10]
           pop   word ptr [di+8]
           pop   word ptr [di+6]
           pop   word ptr [di+4]
           pop   word ptr [di+2]
           pop   word ptr [di]                   

           cmp   ah,29               ; ��ଠ����������
           je    Mant128bitNorm_3    ; ������ ᮤ�ন�
           jb    Mant128bitNorm_2    ; 29 DEC ���

 Mant128bitNorm_1:  
           call  Div128bitToDW       ; �᫨ ������ ᮤ��-
           inc   byte ptr [di-1]     ; ��� ����� DEC ���,
           dec   ah                  ; � �� ���� ������ ��
           cmp   ah,29               ; 10 � ���६���஢���
           jne   Mant128bitNorm_1    ; ���冷�
           jmp   Mant128bitNorm_3

 Mant128bitNorm_2:
           call  Mul128bitToDW       ; �᫨ �� ������ �-
           dec   byte ptr [di-1]     ; ��ন� ����� DEC
           inc   ah                  ; ��� 祬 29, � ��
           cmp   ah,29               ; ���� ������� �� 10 �
           jne   Mant128bitNorm_2    ; ���६����� ���冷�

 Mant128bitNorm_3:
           dec   di
           pop   ax         
           cmp   al,0FFh             ; �᫨ ������ ����-
           jne   Mant128bitNorm_end  ; 砫쭮 �뫠 ����-
           call  Neg128bit           ; ⥫쭠, � ��� �
                                     ; ��᫥ ��ଠ����樨
                                     ; ������ ���� ����-
                                     ; ⥫쭮�
   Mant128bitNorm_end:
           pop   si di dx cx ax
           ret
Mant128bitNorm   endp


; Exp128bit      - ��⠥� e(x)
; di             - ���� ���筨�� � �ਥ�����         
;
Exp128bit  proc  near
Exp128bit_baseQ  EQU [bp-2]
           push  di
           enter 2,0
           mov   Exp128bit_baseQ,di
           
           lea   di,Work2
           call  Move_1_128bit
           
           lea   di,Work1
           call  Move_1_128bit
           
           mov   cx,0
  Exp128bit_1:
           inc   cx           
           lea   di,Work2
           mov   si,Exp128bit_baseQ
           call  Mul128bit

           lea   si,Work
           xchg  di,si
           call  Move_cx_128bit
           xchg  di,si
           call  Div128bit           
           
           lea   di,Work1
           lea   si,Work2
           call  Add128bit
           
           cmp   cx,100
           jne   Exp128bit_1
           
           
           mov   di,Exp128bit_baseQ
           lea   si,Work1
           call  Copy128bit
             
           leave
           pop   di
           ret
Exp128bit  endp

; Sin128bit      - ��⠥� sin(x)
; di             - ���� ���筨�� � �ਥ�����         
;
Sin128bit  proc  near
Sin128bit_baseQ  EQU [bp-2]
           push  cx dx di si
           enter 2,0
           mov   Sin128bit_baseQ,di
           
           lea   di,Work1
           call  Clear128bit
           
           mov   di,Sin128bit_baseQ
           call  GradToRad
           
           lea   di,Work2
           mov   si,Sin128bit_baseQ
           call  Copy128bit           
           
           mov   dx,1                      
           mov   cx,0
  Sin128bit_1:
           inc   cx
           push  cx
           lea   di,Work1
           lea   si,Work2
           call  Add128bit
           
           lea   di,Work2
           mov   si,Sin128bit_baseQ
           call  Mul128bit
           call  Mul128bit
           call  Neg128bit
           
           inc   dx
           lea   si,Work
           xchg  di,si
           mov   cx,dx
           call  Move_cx_128bit
           xchg  di,si
           call  Div128bit
           inc   dx
           lea   si,Work
           xchg  di,si
           mov   cx,dx
           call  Move_cx_128bit
           xchg  di,si
           call  Div128bit           
                      
           pop   cx
           cmp   cx,100
           jne   Sin128bit_1
           
           
           mov   di,Sin128bit_baseQ
           lea   si,Work1
           call  Copy128bit
             
           leave
           pop   si di dx cx
           ret
Sin128bit  endp

; Cos128bit      - ��⠥� cos(x)
; di             - ���� ���筨�� � �ਥ�����         
;
Cos128bit  proc  near
Cos128bit_baseQ  EQU [bp-2]
           push  cx dx di si
           enter 2,0
           mov   Cos128bit_baseQ,di
           
           lea   di,Work1
           call  Move_1_128bit
           
           mov   di,Cos128bit_baseQ
           call  GradToRad
           
           lea   di,Work2
           call  Move_1_128bit           
           
           mov   dx,0
           mov   cx,0
  Cos128bit_1:
           inc   cx
           push  cx
           
           lea   di,Work2
           mov   si,Cos128bit_baseQ
           call  Mul128bit
           call  Mul128bit
           call  Neg128bit
           
           inc   dx
           lea   si,Work
           xchg  di,si
           mov   cx,dx
           call  Move_cx_128bit
           xchg  di,si
           call  Div128bit
           inc   dx
           lea   si,Work
           xchg  di,si
           mov   cx,dx
           call  Move_cx_128bit
           xchg  di,si
           call  Div128bit
           
           lea   di,Work1
           lea   si,Work2
           call  Add128bit
                      
           pop   cx   
           cmp   cx,100
           jne   Cos128bit_1
           
           
           mov   di,Cos128bit_baseQ
           lea   si,Work1
           call  Copy128bit
             
           leave
           pop   si di dx cx
           ret
Cos128bit  endp

; Tan128bit      - ��⠥� tan(x)
; di             - ���� ���筨�� � �ਥ�����
; al             - �����頥� 0 �᫨ �訡��                   
;
Tan128bit  proc  near
Tan128bit_baseQ  EQU [bp-2]
           push  di si
           enter 2,0
           mov   Tan128bit_baseQ,di
           
           lea   di,Work3
           mov   si,Tan128bit_baseQ
           call  Copy128bit
           
           mov   di,Tan128bit_baseQ      
           call  Sin128bit
           
           lea   di,Work3
           call  Cos128bit
           
           lea   di,Work
           call  Clear128bit
           
           lea   di,Work3
           lea   si,Work
           call  Cmp128bit
           cmp   ax,0
           je    Tan128bit_end
           
           mov   di,Tan128bit_baseQ
           lea   si,Work3
           call  Div128bit
           mov   al,1
  Tan128bit_end:  
           leave
           pop   si di
           ret
Tan128bit  endp

; Ctn128bit      - ��⠥� ctn(x)
; di             - ���� ���筨�� � �ਥ�����
; al             - �����頥� 0 �᫨ �訡��          
;
Ctn128bit  proc  near
Ctn128bit_baseQ  EQU [bp-2]
           push  di si
           enter 2,0
           mov   Ctn128bit_baseQ,di
           
           lea   di,Work3
           mov   si,Ctn128bit_baseQ
           call  Copy128bit
           
           mov   di,Ctn128bit_baseQ      
           call  Cos128bit
           
           lea   di,Work3
           call  Sin128bit           
           
           lea   di,Work
           call  Clear128bit
           
           lea   di,Work3
           lea   si,Work
           call  Cmp128bit
           cmp   ax,0
           je    Ctn128bit_end
           
           
           mov   di,Ctn128bit_baseQ
           lea   si,Work3
           call  Div128bit
           mov   al,1
  Ctn128bit_end:           
           leave
           pop   si di
           ret
Ctn128bit  endp

; Ln128bit     - ��⠥� ln(x)
; di             - ���� ���筨�� � �ਥ�����
; al             - �����頥� 0 �᫨ �訡��                   
;
Ln128bit   proc  near
Ln128bit_baseQ   EQU [bp-2]
           push  di
           enter 2,0
           mov   Ln128bit_baseQ,di
           mov   al,[di+13]
           shr   al,7
           jz    Ln128bit_CE1
           mov   al,0
           jmp   Ln128bit_end
  Ln128bit_CE1:                      
           lea   di,Work
           call  Clear128bit
           mov   si,Ln128bit_baseQ
           call  Cmp128bit
           cmp   ax,0
           jnz   Ln128bit_CE2
           mov   al,0           
           jmp   Ln128bit_end
  Ln128bit_CE2:
           mov   di,Ln128bit_baseQ
           
           mov   si,Ln128bit_baseQ
           lea   di,Work1
           call  Copy128bit           
           lea   di,Work2
           mov   cx,5
           call  Move_cx_128bit
           mov   byte ptr [di],0
           lea   si,Work1
           call  Sub128bit
           mov   al,[di+13]
           shr   al,7
           jnz   Ln128bit_G
           mov   di,Ln128bit_baseQ
           call  LnL128bit
           jmp   Ln128bit_L
  Ln128bit_G:
           mov   di,Ln128bit_baseQ
           call  LnG128bit
  Ln128bit_L:                  
           mov   di,Ln128bit_baseQ
           lea   si,Work1
           call  Copy128bit
           
           mov   al,1
  Ln128bit_end:             
           leave
           pop   di
           ret
Ln128bit   endp

; LnG128bit - �㦥����. ��⠥� ln(x) �� x>0.5
; di        - �室 
;
LnG128bit  proc  near
LnG128bit_baseQ  EQU [bp-2]
           enter 2,0
           ; ��� z > 1/2
           mov   LnG128bit_baseQ,di           
           lea   di,Work1
           call  Move_1_128bit
           
           lea   di,Work3
           mov   si,LnG128bit_baseQ
           call  Copy128bit
           
           mov   di,LnG128bit_baseQ
           lea   si,Work1
           call  Sub128bit
           lea   si,Work3
           call  Div128bit
           
           lea   di,Work1
           call  Clear128bit           
           
           lea   di,Work2
           mov   si,LnG128bit_baseQ
           call  Copy128bit
           
           
           mov   dx,1
           mov   cx,0
  LnG128bit_1:
           inc   cx
           push  cx
           lea   di,Work1
           lea   si,Work2           
           call  Add128bit
           
           mov   cx,dx
           lea   di,Work3
           call  Move_cx_128bit
           lea   di,Work2
           lea   si,Work3
           call  Mul128bit
           inc   dx
           mov   cx,dx
           lea   di,Work3
           call  Move_cx_128bit
           lea   di,Work2
           lea   si,Work3
           call  Div128bit
           mov   si,LnG128bit_baseQ
           call  Mul128bit           
           pop   cx   
           cmp   cx,2000
           jne   LnG128bit_1
           leave
           ret
LnG128bit  endp

; LnL128bit - �㦥����. ��⠥� ln(x) �� x<=0.5
; di        - �室 
;
LnL128bit  proc  near
LnL128bit_baseQ  EQU [bp-2]
           enter 2,0
           ; ��� z <= 1/2
           mov   LnL128bit_baseQ,di           
           lea   di,Work1
           call  Move_1_128bit
           
           mov   di,LnL128bit_baseQ
           lea   si,Work1
           call  Sub128bit
                      
           lea   di,Work1
           call  Clear128bit           
           
           lea   di,Work2
           mov   si,LnL128bit_baseQ
           call  Copy128bit
           
           
           mov   dx,1
           mov   cx,0
  LnL128bit_1:
           inc   cx
           push  cx
           lea   di,Work1
           lea   si,Work2           
           call  Add128bit
           
           mov   cx,dx
           lea   di,Work3
           call  Move_cx_128bit
           lea   di,Work2
           lea   si,Work3
           call  Mul128bit
           inc   dx
           mov   cx,dx
           lea   di,Work3
           call  Move_cx_128bit
           lea   di,Work2
           lea   si,Work3
           call  Div128bit
           mov   si,LnL128bit_baseQ
           call  Mul128bit
           call  Neg128bit
                      
           pop   cx   
           cmp   cx,2000
           jne   LnL128bit_1
           leave
           ret
LnL128bit  endp

; Sqrt128bit     - ��⠥� sqrt(x)
; di             - ���� ���筨�� � �ਥ�����
; al             - �����頥� 0 �᫨ �訡��                   
;
Sqrt128bit proc  near
Sqrt128bit_baseQ EQU [bp-2]
           push  di
           enter 2,0
           mov   Sqrt128bit_baseQ,di
           mov   al,[di+13]
           shr   al,7
           jz    Sqrt128bit_CE1
           mov   al,0
           jmp   Ln128bit_end
  Sqrt128bit_CE1:                      
           lea   di,Work
           call  Clear128bit
           mov   si,Sqrt128bit_baseQ
           call  Cmp128bit
           cmp   ax,0
           jnz   Sqrt128bit_CE2
           mov   di,Sqrt128bit_baseQ
           call  Clear128bit
           jmp   Sqrt128bit_end
  Sqrt128bit_CE2:
           
           mov   di,Sqrt128bit_baseQ
           call  Ln128bit
           lea   di,Work1
           mov   cx,5
           call  Move_cx_128bit
           mov   byte ptr [di],0
           mov   di,Sqrt128bit_baseQ
           lea   si,Work1
           call  Mul128bit
           call  Exp128bit           
  Sqrt128bit_end:             
           leave
           pop   di
           ret
Sqrt128bit endp

; GradToRad      - ��ॢ���� �ࠤ��� � ࠤ����         
; di             - ���� ���筨��
;
GradToRad  proc  near
GradToRad_baseQ  EQU [bp-2]
           push  ax cx dx di si
           enter 2,0
           mov   GradToRad_baseQ,di
           mov   al,[di+13]
           shr   al,7
           jz    GradToRad_NNeg
           call  Neg128bit
  GradToRad_NNeg:
           push  ax
           
           lea   di,Work2
           mov   cx,360
           call  Move_cx_128bit
           
           lea   si,Work2
           mov   di,GradToRad_baseQ           
  GradToRad_0:
           call  Sub128bit
           mov   al,[di+13]
           shr   al,7
           je    GradToRad_0
           call  Add128bit
           
           lea   si,Work2           
           mov   cx,180               
           xchg  di,si
           call  Move_cx_128bit
           xchg  di,si
           call  Div128bit
           
           lea   di,Work2           
           call  Move_Pi_128bit
           
           lea   si,Work2
           mov   di,GradToRad_baseQ
           call  Mul128bit           
           
           pop   ax
           cmp   al,0
           jz    GradToRad_end
           call  Neg128bit
  GradToRad_end:
           leave
           pop   si di dx cx ax
           ret
GradToRad  endp