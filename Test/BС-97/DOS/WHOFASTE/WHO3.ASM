data segment          ;����室��� ��� ࠡ��� �����
   Reg_Game    db ?
   Ready       db ?
   KBDerr      db ?
   CurPlayer   db ?
   Map         db 0AH dup (?)
   PosArr      db 3 dup(?)
   TimeArr     db 3 dup (?)
   AllReady    db ?
   Rand        dw 10 dup(?)
   RandCur     db ?
data ends

code segment
  assume ds:data, cs:code
  InitMap proc near
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
       mov curPlayer,1
       mov Reg_Game,1
       mov PosArr[0],0
       mov PosArr[1],0
       mov PosArr[3],0
       mov TimeArr[2],99
       mov TimeArr[1],99
       mov TimeArr[0],99
       mov allready,0
       mov Rand[0],300
       mov Rand[2],480
       mov Rand[4],219
       mov Rand[6],329
       mov Rand[8],1000
       mov Rand[10],100
       mov Rand[12],253
       mov Rand[14],425
       mov Rand[16],333
       mov Rand[18],138
       mov RandCur,255
       mov al,0
       out 0,al
       out 1,al
       out 2,al
       out 3,al
       ret
  InitMap endp
  KBD_IN proc
         mov KbdErr,0
         mov Ready,0
   kb1:  in al,0
         mov bl,al
         and al,00100000b
         test al,00100000b   ;��।������ ०��� "���" ��� "��ᬮ��"
         mov al,bl
         jnz kbd1            ;�᫨ "��ᬮ��"
         cmp AllReady,1
         jne Kb2
         mov curplayer,1
    Kb2: test al,00010111b   ;�뤥����� ����饭��� ������
         jnz InErr             ;�᫨ ����� ����饭��� ������
         test al,00001000b   ;�஢�ઠ ������ "��⮢����"
         jz kb1              ;�᫨ ��� �� �����
         cmp CurPlayer,1
         jne Kb3
         mov TimeArr[0],99
         mov TimeArr[1],99
         mov TimeArr[2],99
    KB3: mov Reg_Game,0
         mov Ready,1
         mov AllReady, 0
         ret
    kbd1:
  cv3:   mov curplayer,1
         test al,00001000b   ;�뤥����� ������ "�६�"
         jnz kbd3            ;�᫨  �����
         test al, 00010000b  ;�뤥����� "����"
         jz kbd4             ;�᫨ �� �����
         mov Reg_Game,2
         jmp kbd9
    kbd4:and al,00000111b    ;�뤥����� ������ ��� ����� ����� ��ப�
         cmp al,0            ;�஢�ઠ �� ����⨥ ��� �� ����� �� ���
         jz kb1              ;�᫨ �� ����� ���室 �� ��砫�
         cmp al,4
         jnz k
         dec al
       k:mov CurPlayer,al    ;��࠭���� ����� ��ப�
         jmp kbd9            ;�� ��室
    kbd3:mov Reg_Game,1
         ret
   InErr:mov KBDerr,1
    kbd9:ret
  KBD_IN endp


  OutData proc
          mov al,0h
          out 2,al
          out 3,al
          lea bx,Map            ;����㧪� ⠡���� ᨬ����� 0--9
          mov cx,bx
          mov al,curplayer      ;����� ��ப�
          mov dl,al
          xlat                  ;����祭�� ����� �� ��������
          out 1,al
          cmp Reg_game,0        ;�� ०��� ���� ����� ��祣� �� �⮡�.
          je ODq
          cmp Reg_Game,2        ;��ᬮ�� �����:�६� ��� �����:����
          jne OutTime
          lea bx,PosArr         ; ����祭�� ����
          mov al,dl
          dec al
          xlat
          xchg bx,cx            ;����祭�� ���� , ᮮ�. �����
          xlat
          out 3,al              ;�뤠� ���� � ���� -1 , -2 ��� -3
          mov al,01000000b
          out 2,al
          ret
 OutTime: lea bx,TimeArr        ;����祭�� �६���
          mov al,CurPlayer
          dec al
          xlat
          cbw
          aam                   ; al-������ ��� , ah-����� [00..99]
          mov bx,cx             ; �뢮� �� ��������� ����� ,
          xlat                  ; ᮮ⢥������� ��ࠬ
          out 3,al
          mov al,ah
          xlat
          out 2,al
     ODq: ret
  Outdata endp
  Errorer proc
          push cx
          push ax
          mov al,0ffh
          mov cx,115
          out 2,al
          out 3,al
  er1:    nop
          loop er1
          xor al,al
          out 2,al
          out 3,al
          mov cx,115
  Er2:    nop
          loop Er2
          pop ax
          pop cx
          ret
  Errorer endp

  Counter proc
          call Random
          mov al,1
          out 0,al
          mov cx,99
 CntLoop: in al,0
          cmp al,00010000b
          je Time
          dec cx
          jnz CntLoop
    Time:
          mov al,99
          sub al,cl
          mov cl,al
          lea si,TimeArr
          xor bh,bh
          mov bl,CurPlayer
          dec bl
          mov byte ptr [si+bx],cl
          mov al,0
          out 0,al
          ret
  Counter endp
    Arranger proc  far
          mov Posarr[0],3
          mov posarr[1],3
          mov posarr[2],3
          mov al,TimeArr[0]
          cmp al,TimeArr[1]
          ja Ar1
          je Ar2
          sub PosArr[0],1
          jmp Ar2
   Ar1:   sub PosArr[1],1
   Ar2:   cmp al,TimeArr[2]
          ja Ar3
          je Ar4
          sub PosArr[0],1
          jmp Ar4
   Ar3:   sub PosArr[2],1
   Ar4:   mov al,TimeArr[1]
          cmp al,TimeArr[2]
          ja Ar5
          je Ar6
          sub PosArr[1],1
          jmp Ar6
   Ar5:   sub PosArr[2],1

   Ar6:   ret
 Arranger endp
 Outlamp proc
         mov dx,ax
         mov al,0
         out 0,al
         cmp AllReady,1
         jne Ou1
         mov al,2
         out 0,al
    Ou1:
         mov dx,ax
         ret
 Outlamp endp
 Random proc
        cmp randcur,8
        jbe Rn1
        mov randCur,255
  Rn1:  inc byte ptr RandCur
        lea si,rand
        xor ch,ch
        mov cl,randcur
        add si,cx
        add si,cx
  Rn2:  mov cx,[si]
   Rn3: nop
        in al,0  ; ��������� ������ ��⮢����
        and al,00010000b
        jz Rn4
        call Errorer
        jmp Rn2
   Rn4: loop Rn3
        ret
 random endp
   Dispatcher proc
     Ds1:   call KBD_In
            cmp KbdErr,1
            jne Ds2
            call Errorer
            jmp Ds1
     Ds2:   cmp Reg_Game,0
            jne Ds4
            cmp ready,1
            mov al,0
            out 0,al
            call outdata
            call counter
            mov Reg_Game,1
            Call Outdata
            mov cx,100
       ss1: nop
            loop ss1
            call outlamp
            cmp curplayer,3
            jae Ds3
            inc CurPlayer
            jmp Ds1;
     Ds3:   mov AllReady,1
            call Arranger
            call OutLamp
            jmp Ds1
     Ds4:   mov allready,1
            call arranger
            call Outdata
            jmp Ds1
            ret
 Dispatcher endp

 start :
         call initmap    ;��楤�� ��砫쭮� ���樠����樨
         call dispatcher ;��楤�� ���㦨�����
         int 92h
code ends
     end start