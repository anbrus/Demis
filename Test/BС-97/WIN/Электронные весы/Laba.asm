      ;�ணࠬ�� "�����஭�� ����"

      data segment at 40H
            Map db 20 dup(?)
            masot db 15 dup(?)
            zena dw ?
            numklav db ?
            kodklav dw ?
            r db 8 dup(?)
            mas dw ?
            rez dd ?
            pozt db ?
            tara dw ?
            netto dw ?
            flag db ?
            z db 6 dup(?)
            v00 db ?
            v0 db ?
            v1 db ?
            v2 db ?
            v3 db ?
            i dw ?
      data ends

      stack segment at 0BA80H
       db 100 dup (?)
       StkTop label word
      stack ends

      code1 segment
      assume cs:code1,ds:data

      ;��楤�� ���樠����樨 ���ᨢ� ����� �뢮����� ���

      Inizmas proc near
             mov Map[0], 3FH
             mov Map[1], 0CH
             mov Map[2], 76H
             mov Map[3], 05EH
             mov Map[4], 4DH
             mov Map[5], 5BH
             mov Map[6], 7BH
             mov Map[7], 0EH
             mov Map[8], 7FH
             mov Map[9], 5FH
             mov Map[10], 0BFH
             mov Map[11], 8CH
             mov Map[12], 0F6H
             mov Map[13], 0DEH
             mov Map[14], 0CDH
             mov Map[15], 0DBH
             mov Map[16], 0FBH
             mov Map[17], 8EH
             mov Map[18], 0FFH
             mov Map[19], 0DFH
             ret
      Inizmas endp

      ; ��楤�� �����⮢�� ������ ��� ��砫쭮� ��⠭����
      ; ��楢�� ������

      Podgotov proc near
             mov al,3fh
             out 00,al
             out 01,al
             out 02,al
             out 03,al

             out 04,al
             out 05,al
             out 06,al
             out 07,al

             out 08,al
             out 09,al
             out 0ah,al
             out 0bh,al
             out 0ch,al
             out 0dh,al
             out 0eh,al
             out 0fh,al

             xor ax,ax
             mov z[0],al
             mov z[1],al
             mov z[2],al
             mov z[3],al

             mov v00,al
             mov v0,al
             mov v1,al
             mov v2,al
             mov v3,al

             mov r[0],al
             mov r[1],al
             mov r[2],al
             mov r[3],al
             mov r[4],al
             mov r[5],al
             mov r[6],al
             mov r[7],al
             mov mas,ax
             mov flag,al
             ret
      Podgotov endp
      Vibr proc
      vi1: mov ah,al
          mov bh,0
      vi2: in al,dx
          cmp ah,al
          jne vi1
          inc bh
          cmp bh,200
          jne vi2
          mov al,ah
          ret
      vibr endp     

      ; ��楤�� ���뢠��� ���� ����⮩ ������

      Schitklav proc near
            mov dx,01
            call Vibr
            in al,01
            mov ch,al
            call Vibr
            xor dx,dx
            call vibr
            in al,00
            call vibr
            mov ah,ch
            mov kodklav,ax  ;(ax)=��.��� ����⮩ ������
     
            ret
      Schitklav endp

      ; ��楤�� �८�ࠧ������ ���� � ����� ������
      Preobras proc near
            mov ax,kodklav
            cmp ax,0    ;�� ����� �� ���� �� ������
            je bo
            xor cl,cl
      b2:   shr ax,1
            inc cl
            jnc b2
            mov numklav,cl ;numklav-����� ���.��-�
      bo:   ret
      Preobras endp

      ;��楤�� ������� �������� ᫮�� �� ��.᫮��

      LongDiv Proc
              Push    Bp
              Xor     Bp,Bp
              Or      Dx,Dx
              Jns     ld1
              Inc     Bp
              Neg     Ax
              Adc     Dx,0
              Neg     Dx
      ld1:    Or      Bx,Bx
              Je      ld5
              Jns     ld2
              Inc     Bp
              Inc     Bp
              Neg     Cx
              Adc     Bx,0
              Neg     Bx
              Je      ld5
      ld2:    Push    Bp
              Mov     Si,Cx
              Mov     Di,Bx
              Xor     Bx,Bx
              Mov     Cx,Dx
              Mov     Dx,Ax
              Xor     Ax,Ax
              Mov     Bp,16
      ld3:    Shl     Ax,1
              Rcl     Dx,1
              Rcl     Cx,1
              Rcl     Bx,1
              Inc     Ax
              Sub     Cx,Si
              Sbb     Bx,Di
              Jnc     ld4
              Dec     Ax
              Add     Cx,Si
              Adc     Bx,Di
      ld4:    Dec     Bp
              Jne     ld3
              Pop     Bp
              Jmp     Short ld6
      ld5:    Xchg    Ax,Bx
              Xchg    Ax,Dx
              Div     Cx
              Xchg    Ax,Bx
              Div     Cx
              Mov     Cx,Dx
              Mov     Dx,Bx
              Xor     Bx,Bx
      ld6:    Shr     Bp,1
              Jnc     ld7
              Neg     Cx
              Adc     Bx,0
              Neg     Bx
              Inc     Bp
      ld7:    Dec     Bp
              Jne     ld8
              Neg     Ax
              Adc     Dx,0
              Neg     Dx
      ld8:    Pop     Bp
              Ret
      Endp

      ;��楤�� ��ࠡ�⪨ ������ �� ����� 業�
      ;(��।������ ���࠭��� 業�)

      Inpzena proc near
            mov al,flag  ;�஢�ઠ �ਧ���� ��饩 �訡��
            shr al,4
            jnc mk00
            jmp far ptr k
      mk00: mov cl,numklav
            cmp cl,10   ;����� �� ���
            jbe mk01
            jmp far ptr k
      mk01: and flag,11111101b
            dec cl
            mov al,z[2]  ;ᤢ�� ��� �����
            mov z[3],al
            mov al,z[1]
            mov z[2],al
            mov al,z[0]
            mov z[1],al
            mov z[0],cl  ;������ ��������� ����
            mov i,5
            mov cx,3
            mov di,3  ;��।������ ������ �窨 � 業�
      mk1:  cmp z[di],10 ;��� ⮣�, �⮡� ��୮ ��ନ஢���
            jb mk        ; ���祭�� 業�

            mov i,di
            cmp di,5
            je mk3
            push cx
            mov cx,10
      mk0:  dec z[di]
            loop mk0
            pop cx
      mk:   dec di
            loop mk1
                 ;�ନ஢���� �᫥����� ���祭�� 業�
      mk3:  mov bx,10
            mov al,z[3]
            mov ah,0
            mul bx
            clc
            add al,z[2]
            adc ah,0
            mul bx
            xor dx,dx
            mov dl,z[1]
            add ax,dx
            mul bx
            xor dx,dx
            mov dl,z[0]
            add ax,dx
            mov zena,ax

            mov di,i
            cmp di,5
            je mk4
            mov cx,10
      mk2:  inc z[di]
            loop mk2
      mk4:  mov cx,0ffffh
      delay2:nop
            loop delay2
            mov cx,0ffffh
      delay21:nop
            loop delay21
      k:    ret
      Inpzena endp


      ;��楤�� ��ࠡ�⪨ ������ �� ����⮩ ������ "."

      Inptochka proc near
            mov al,flag   ;�஢�ઠ �ਧ���� ��饩 �訡��
            shr al,4
            jc k1
            mov cl,numklav
            cmp cl,11   ;����� ������ "."
            jne k1
            mov cx,10

            mov al,z[0]; 㢥��祭�� ��६�����,
      n3:   inc al      ;�࠭�饩 ��᫥���� ���� 業�
            loop n3   ;�� 10
            mov z[0],al
            or flag,10b   ;��⠭���� �ਧ���� �訡��

            mov cx,0ffffh
     
      k1:   ret
      Inptochka endp

      ;��楤�� ��ࠡ�⪨ ������ �� ����⮩ ������ "����"
      ;(��।������ ���࠭��� �����)

      Inpves proc near
            mov al,flag  ;�஢�ઠ �ਧ���� ��饩 �訡��
            shr al,4
            jc k2
            mov cl,numklav
            cmp cl,12   ;����� ��-� "����"
            jne k2

            inc v3 ; �ନ஢���� �����
            cmp v3,10
            jne m1
            inc v2
            mov v3,0

            cmp v2,10
            jne m1
            inc v1
            mov v2,0

            cmp v1,10
            jne m1
            inc v0
            mov v1,0
            cmp v0,10
            jne m1
            inc v00
      m1:   mov bx,10 ; �ନ஢���� �᫥����� ��-��� �����
            xor ax,ax
            mov al,v0
            mul bl
            clc
            add al,v1
            adc ah,0
            mul bx
            xor dx,dx
            mov dl,v2
            add ax,dx
            mul bx
            xor dx,dx
            mov dl,v3
            add ax,dx
            mov mas,ax
      k2:   ret
      Inpves endp

      ;��楤�� ��ࠡ�⪨ ������ �� ����⮩ ������ "����"
      ;(��।������ �⮨���� �� ����騬�� 業� � ����)

      Inpent proc near
            mov al,flag  ;�஢�ઠ �ਧ���� ��饩 �訡��
            shr al,4
            jnc i00
            jmp far ptr k3
      i00:  mov cl,numklav
            cmp cl,13  ;����� ��-� "����"
            je i0
            jmp far ptr k3
      i0:   or flag,1 ; ��⠭-�� �ਧ���� �����
            mov ax,mas
            sub ax,tara
            mov netto,ax

            mov bx,offset rez
            mov word ptr[bx],0
            mov word ptr[bx+2],0
            xor dx,dx
            xor ax,ax
             clc
                        ;���᫥��� �⮨����
            mov ax,zena
            mov dx,netto
            mul dx
            mov word ptr[bx],ax
            mov word ptr[bx+2],dx
            xor bx,bx
                    ; ��ॢ�� ��-��� �⮨���� � ����,
            mov cx,10 ; 㤮����� ��� �뢮�� �� ��ᯫ��
            call LongDiv
            mov r[7],cl
            mov cx,10
            call LongDiv
            mov r[6],cl
            mov cx,10
             call LongDiv
             mov r[5],cl
             mov cx,10
             call LongDiv
             mov r[4],cl
             mov cx,10
             call LongDiv
             mov r[3],cl
             mov cx,10
             call LongDiv
             mov r[2],cl
             mov cx,10
             call LongDiv
             mov r[1],cl
             mov r[0],al
             ;��।������ ����樨 �窨 � �⮨����
            xor al,al
            cmp z[3],10
            jnb mm1
            cmp z[2],10
            jnb mm2
            cmp z[1],10
            jnb mm3
            jmp mm4
      mm1:  inc al
      mm2:  inc al
      mm3:  inc al
      mm4:  inc al
            inc al
            inc al
            mov pozt,al
             ;�ନ஢���� �⮨���� � ��⮬ �窨
            mov al,7
            sub al,pozt
            xor ah,ah
            xor di,di
            mov di,ax
            mov cx,10
      f1:   inc r[di]
            loop f1
            inc di
            inc di
      f2:   inc di
            mov r[di],0
            cmp di,7
            jb f2
            mov cx,0ffffh
      delay:nop
            loop delay
            mov cx,0ffffh
      delay0:nop
            loop delay0
      k3:   ret
      Inpent endp

      ;��楤�� ��ࠡ�⪨ ������ �� ����⮩ ������ "���=0"
      ;(���㫥��� �����)

      InpNulVes proc near
            mov al,flag ;�஢�ઠ �ਧ���� ��饩 �訡��
            shr al,4
            jc k5
      mov cl,numklav ;����� ��-� "���=0"
      cmp cl,15
      jne k5
      xor ax,ax
      mov v00,al ;���㫥��� �����
      mov v0,al
      mov v1,al
      mov v2,al
      mov v3,al
      mov mas,ax
       k5:   ret
       InpNulVes endp

       ;��楤�� ��ࠡ�⪨ ������ �� ����⮩ ������ "���"
       ;(���㫥��� �����, �������� ���� �ਭ������� �� ��� ���)

       TaraP proc near
             mov al,flag ;�஢�ઠ �ਧ���� ��饩 �訡��
             shr al,4
             jc k4
             mov cl,numklav ;����� ��-� "���"
             cmp cl,14
             jne k4
             mov ax,mas      ;������ � ��६����� tara
             mov tara,ax     ;��-��� ����饩�� �����
       k4:   ret
       TaraP endp

       ; ��楤�� ��ࠡ�⪨ 䫠��� �ணࠬ��

       FormirInf proc near
              cmp kodklav,0 ; ����� �� �����-���� ��-�
              je merr

              mov cl,numklav
              mov al,flag
              shr al,1
              jnc fi

              xor ax,ax
              and flag,11111110b ; ��� �ਧ���� �।.�����
              mov tara,ax        ;���㫥��� ���

       fi:    mov al,flag   ;�஢�ઠ �ਧ���� �।.����� �窨
              shr al,2
              jnc fi1
              cmp cl,11  ;�����"."
              je merr

       fi1:   mov al,flag  ;�஢�ઠ �ਧ���� �訡�� ����� �����
              shr al,3
              jnc fi2
              cmp cl,10  ;����� ���
              jnbe merr
              call Podgotov
              and flag,11111011b ;���㫥��� �ਧ���� �訡�� ����� �����
       fi2:   and flag,11110111b ;���㫥��� �ਧ���� ��饩 �訡��
              jmp bo0
       merr:  or flag,1000b ;��⠭���� �ਧ���� ��饩 �訡��
       bo0:    ret
       FormirInf endp

       ;��楤�� ����஫� ����� �����
       ;(��⠭�������� 䫠� �訡�� ����� �����,
       ; ����� ���� �⠭������ ����� 9.999 ��)

       Control proc near
              cmp kodklav,0  ;����� �� �����-���� ��-�
              je bo2
              cmp v00,1
              jne bo2
                      ; ��९�������
              mov al,73h
              mov masot[04],al
              xor al,al
              mov masot[05],al
              mov masot[06],al
              mov masot[07],al
              or flag,100b    ;��⠭���� 䫠�� �騡�� ����� �����
       bo2:   ret
       Control endp

       ;��楤�� �ନ஢���� ���ᨢ� ������ ���
       ;�⮡ࠦ���� �� ��ᯫ���

       FormirMasOtobr proc near
              cmp kodklav,0     ;����� �� �����-���� ��-�
              jne fm
              jmp far ptr bo3
       fm:    mov bx,offset Map
              mov al,z[3]
              xlat
              mov masot[0],al

              mov al,z[2]
              xlat
              mov masot[1],al
              mov al,z[1]
              xlat
              mov masot[2],al
              mov al,z[0]
              xlat
              mov masot[3],al
              mov al,v0
              mov cx,10
       f:     inc al
              loop f
              xlat
              mov masot[4],al
              mov al,v1
              xlat
              mov masot[5],al
              mov al,v2
              xlat
              mov masot[6],al
              mov al,v3
              xlat
              mov masot[7],al


              mov al,r[0]
              xlat
              mov masot[8],al
              mov al,r[1]
              xlat
              mov masot[9],al
              mov al,r[2]
              xlat
              mov masot[10],al
              mov al,r[3]
              xlat
              mov masot[11],al
              mov al,r[4]
              xlat
              mov masot[12],al
              mov al,r[5]
              xlat
              mov masot[13],al
              mov al,r[6]
              xlat
              mov masot[14],al
       bo3:   ret
       FormirMasOtobr endp

       ;��楤�� �뢮�� ���ᨢ� ������ �� ��ᯫ��

       OutMasOtobr proc near
              cmp kodklav,0   ; ����� �� �����-���� ��-�
              je bo4
              mov al,masot[0]
              out 00,al
              mov al,masot[1]
              out 01,al
              mov al,masot[2]
              out 02,al
              mov al,masot[3]
              out 03,al
              mov al,masot[4]
              out 04,al
              mov al,masot[5]
              out 05,al
              mov al,masot[6]
              out 06,al
              mov al,masot[7]
              out 07,al
              mov al,masot[8]
              out 08,al
              mov al,masot[9]
              out 09,al
              mov al,masot[10]
              out 0ah,al
              mov al,masot[11]
              out 0bh,al
              mov al,masot[12]
              out 0ch,al
              mov al,masot[13]
              out 0dh,al
              mov al,masot[14]
              out 0eh,al
       bo4:   ret
       OutMasOtobr endp


       begin: mov ax,data
              mov ds,ax

              mov ax,stack
              mov ss,ax
              mov sp,offset StkTop
             
              call Inizmas
              call Podgotov
       beg:   call Schitklav
              call Preobras
              call FormirInf
              call InpZena
              call InpTochka
              call InpVes
              call InpEnt
              call TaraP
              call InpNulVes
              call FormirMasOtobr
              call Control
              call OutMasOtobr
              jmp beg
              org 0ff0H
              assume cs:nothing
       start: jmp far ptr begin
       code1 ends
       end start
