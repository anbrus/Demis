page 50,120

      ;�ணࠬ�� ࠡ��� ���ன�⢠ �ࠢ����� ����஥��஬

                        NAME diaproektor

      ;���ᠭ�� ������
Data1 segment at 0ba00h

       ;���ᠭ�� �ᯮ��㥬�� ��६�����

       FirstDig  db 31 dup(?)
       SecondDig db 31 dup(?)
       SlideMas  db 20 dup(?)       
       Delay     db        ?
       MasLength db        ? 

       ;���ᠭ�� 䫠��� 

       StepShow   db ?
       AutoShow   db ?
       SetMode    db ?
       ShowMode   db ? 
       ForwMove   db ?
       BackMove   db ?
       PrepData   db ?
       NomSet     db ?
       DelSet     db ? 
       DelReady   db ?
       SlMasReady db ?
       AutoReady  db ?
       StepReady  db ?
       Return     db ?
Data1 ends

      ;���ᠭ�� �⥪�

Stack1 segment at 0ba80h
               db 512 dup (?)
      stktop   label word
Stack1 ends

      ;���ᠭ�� �믮��塞�� ����⢨�

Code1 segment
      assume cs:Code1,ds:Data1,ss:Stack1

      ;���ᠭ�� �ணࠬ���� ���㫥�

;1.��楤�� �����⮢�� ������
PrepareProc proc near

       mov al,0;3fh   ;�뢮� �� ��஢�� ⠡�� "01"
       out 4,al
       mov al,0;3Fh
       out 3,al

       mov al,11h   ;��⨢��� ������� �������஢
       out 2,al     ;"����ன��" � "�몫�祭" 

       mov si,0     ;��⠭���� ���稪��
       mov bx,1
       mov di,1
       mov bp,31

       mov SetMode,1;��⠭���� ०��� ����ன�� �� ����祭�� ��-��

       mov delay,1  ;��砫쭠� ��⠭���� ����প� � "1" 
       
    ;�ନ஢���� ���ᨢ�� ����襣� � ���襣� ࠧ�冷�
         ;��� �뢮�� �� ��஢�� ⠡��

       mov firstdig[0],3fh   ;0
       mov firstdig[1],0ch   ;1
       mov firstdig[2],76h   ;2
       mov firstdig[3],5eh   ;3
       mov firstdig[4],4dh   ;4
       mov firstdig[5],5bh   ;5
       mov firstdig[6],7bh   ;6
       mov firstdig[7],0eh   ;7
       mov firstdig[8],7fh   ;8
       mov firstdig[9],5fh   ;9
       mov firstdig[10],3fh  ;0
       mov firstdig[11],0ch  ;1
       mov firstdig[12],76h  ;2
       mov firstdig[13],5eh  ;3
       mov firstdig[14],4dh  ;4
       mov firstdig[15],5bh  ;5
       mov firstdig[16],7bh  ;6
       mov firstdig[17],0eh  ;7
       mov firstdig[18],7fh  ;8
       mov firstdig[19],5fh  ;9
       mov firstdig[20],3fh  ;0
       mov firstdig[21],0ch  ;1
       mov firstdig[22],76h  ;2
       mov firstdig[23],5eh  ;3
       mov firstdig[24],4dh  ;4
       mov firstdig[25],5bh  ;5
       mov firstdig[26],7bh  ;6
       mov firstdig[27],0eh  ;7
       mov firstdig[28],7fh  ;8
       mov firstdig[29],5fh  ;9
       mov firstdig[30],3fh  ;0
     
       mov seconddig[0],3fh  ;0   
       mov seconddig[1],3fh  ;0   
       mov seconddig[2],3fh  ;0   
       mov seconddig[3],3fh  ;0   
       mov seconddig[4],3fh  ;0   
       mov seconddig[5],3fh  ;0   
       mov seconddig[6],3fh  ;0   
       mov seconddig[7],3fh  ;0   
       mov seconddig[8],3fh  ;0   
       mov seconddig[9],3fh  ;0   
       mov seconddig[10],0ch; 1
       mov seconddig[11],0ch; 1
       mov seconddig[12],0ch; 1
       mov seconddig[13],0ch; 1
       mov seconddig[14],0ch; 1
       mov seconddig[15],0ch; 1
       mov seconddig[16],0ch; 1
       mov seconddig[17],0ch; 1
       mov seconddig[18],0ch; 1
       mov seconddig[19],0ch; 1
       mov seconddig[20],76h; 2
       mov seconddig[21],76h; 2
       mov seconddig[22],76h; 2
       mov seconddig[23],76h; 2
       mov seconddig[24],76h; 2
       mov seconddig[25],76h; 2
       mov seconddig[26],76h; 2
       mov seconddig[27],76h; 2
       mov seconddig[28],76h; 2
       mov seconddig[29],76h; 2
       mov seconddig[30],5eh; 3
       
       mov al,0ffh
       out 5,al
       mov al,0
       out 5,al

       mov prepdata,1   ; �ନ஢���� �ਧ���� ��⮢���� ������
       ret
EndP PrepareProc


;2. ����� ����ன��
SetModeProc proc near
       cmp prepdata,1    
       jnz smp1
       cmp return,1
       jnz smp1
       in al,0         ;��ࠡ�⪠ �����
       cmp al,1
       jnz smp1
       mov bx,1        ;०��  ����ன��
       mov si,0
       mov ShowMode,0  ;��� ��� �ਧ�����
       mov StepShow,0
       mov AutoShow,0
       mov ForwMove,0
       mov BackMove,0
       mov NomSet,0
       mov DelSet,0
       mov DelReady,0
       mov SlMasReady,0
       mov AutoReady,0
       mov StepReady,0
       mov SetMode,1
       mov Return,0

       mov delay,1     ;��⠭���� �����প� � ��砫쭮� ���ﭨ�

       mov al,11h
       out 2,al

       mov al,0h
       out 5,al

       mov al,0;3fh   ;�뢮� �� ��஢�� ⠡�� "0"
       out 4,al
       mov al,0;3Fh
       out 3,al

  smp1:ret
EndP SetModeProc


;3. ����� ������
ShowModeProc proc near
       cmp SetMode,1
       jnz shmp1 
       in al,0         ;��ࠡ�⪠ �����
       cmp al,2
       jnz shmp1
       mov ShowMode,1  ;०�� ������
       mov al,0ch   ;�뢮� �� ��஢�� ⠡�� "01"
       out 4,al
       mov al,3Fh
       out 3,al
       mov al,12h
       out 2,al 
       mov bx,0
       mov SetMode,0   ;��� �ਧ���� ����ன��
 shmp1:ret
EndP ShowModeProc


;4. �롮� 蠣����� ������ ᫠����
StepShowProc proc near
        cmp SetMode,1
        jnz ssp1
        cmp AutoShow,1
        jz  ssp1 
        in al,0          ;������ �����
        cmp al,4
        jnz ssp1
        mov StepShow,1   ; �롮� 蠣����� ������
        mov StepReady,1
        mov al,0;3fh   ;�뢮� �� ��஢�� ⠡�� "01"
        out 4,al
        mov al,0;3Fh
        out 3,al
        
       cmp forwmove,1
       jnz ssp3
       mov al,5
       out 5, al
       jmp ssp1 
  ssp3:cmp backmove,1
       jnz ssp4
       mov al,9h
       out 5,al
       jmp ssp1
  ssp4:cmp NomSet,1
       jnz  ssp5
       mov al,11h
       out 5,al
       jmp ssp1 
  ssp5:mov al,1 
       out 5,al 
   ssp1:ret
EndP StepShowProc


;5. �롮� ��⮬���᪮�� ������ ᫠����
AutoShowProc proc near
       cmp SetMode,1
       jnz asp2
       cmp StepShow,1
       jz  asp1  
       in al,0         ;������ �����
       cmp al,8
       jnz asp1
       mov AutoShow,1  ;�롮� ��⮬���᪮�� ������
       mov al,0;3fh   ;�뢮� �� ��஢�� ⠡�� "01"
       out 4,al
       mov al,0;3Fh
       out 3,al
       cmp forwmove,1
       jnz asp3
       mov al,6
       out 5, al
       jmp asp2 
  asp3:cmp backmove,1
       jnz asp4
       mov al,0ah
       out 5,al
       jmp asp2
  asp4:cmp NomSet,1
       jnz asp5
       mov al,12h
       out 5,al
       jmp asp2
  asp5:mov al,2
       out 5,al 
  asp2:cmp showmode,1
       jnz asp1
       in al,1
       cmp al,20h
       jnz asp1
       mov autoready,1       
  asp1:ret
EndP AutoShowProc


;6. ��⠭���� ���ࠢ����� �������� ������ � ᫠����� ���।
ForwMoveProc proc near
       cmp SetMode,1
       jnz fmp1
       cmp NomSet,1
       jz  fmp1
       cmp BackMove,1
       jz  fmp1
       in al,0         ;������ �����
       cmp al,10h
       jnz fmp1
       mov al,0;3fh   ;�뢮� �� ��஢�� ⠡�� "01"
       out 4,al
       mov al,0;3Fh
       out 3,al
       mov ForwMove,1 ;�롮� ���ࠢ����� �������� ���।
       cmp StepShow,1
       jnz fmp2  
       mov al,5
       out 5,al
       jmp fmp1
  fmp2:cmp AutoShow,1
       jnz fmp3
       cmp DelReady,1
       jnz fmp4
       mov al,26h
       out 5,al
       jmp fmp1
  fmp4:mov al,6
       out 5,al  
       jmp fmp1
  fmp3:mov al,4
       out 5,al
  fmp1:ret
EndP ForwMoveProc


;7. ��⠭���� ���ࠢ����� �������� ������ � ᫠����� �����
BackMoveProc proc near
       cmp SetMode,1
       jnz  bmp1
       cmp NomSet,1
       jz bmp1
       cmp ForwMove,1
       jz  bmp1
       in al,0           ;������ �����
       cmp al,20h
       jnz bmp1
       mov al,0;3fh   ;�뢮� �� ��஢�� ⠡�� "01"
       out 4,al
       mov al,0;3Fh
       out 3,al
       mov BackMove,1    ;�롮� ���ࠢ����� �������� �����
       cmp stepshow,1
       jnz bmp2
       mov al,9
       out 5,al
       jmp bmp1
  bmp2:cmp AutoShow,1
       jnz bmp3
       cmp DelReady,1
       jnz  bmp4
       mov al,2Ah
       out 5,al
       jmp bmp1
  bmp4:mov al,0ah
       out 5,al       
       jmp bmp1
  bmp3:mov al,8
       out 5,al
  bmp1:ret
EndP BackMoveProc


;8. ��ନ஢���� �ਧ���� �ணࠬ����� ������
SetSlideNom proc near
       cmp SetMode,1
       jnz ssn1
       cmp forwmove,1
       jz  ssn1
       cmp backmove,1
       jz  ssn1
       in al,0          ;������ �����
       cmp al,40h
       jnz ssn1
       mov forwmove,0
       mov backmove,0
       mov NomSet,1     ;�ନ஢���� �ਧ���� �ணࠬ����� ������
       mov al,0ch   ;�뢮� �� ��஢�� ⠡�� "01"
       out 4,al
       mov al,3Fh
       out 3,al
       cmp stepshow,1
       jnz ssn2
       mov al,11h
       out 5,al
       jmp ssn1
  ssn2:cmp autoshow,1
       jnz ssn3
       cmp delready,1
       jnz  ssn4
       mov al,32h
       out 5,al
       jmp ssn1
  ssn4:mov al,12h
       out 5,al
       jmp ssn1
  ssn3:mov al,10h
       out 5,al 
  ssn1:ret
EndP SetSlideNom


;9. ��ନ஢���� �ਧ���� ��⠭���� ����প�
SetDelay proc near
       cmp SetMode,1
       jnz sd1
       cmp AutoShow,1
       jnz sd1 
       in al,0
       cmp al,80h       ;������ �����
       jnz sd1
       mov DelSet,1     ;�ନ஢���� �ਧ���� ��⠭���� ����প� 
       mov al,0ch   ;�뢮� �� ��஢�� ⠡�� "01"
       out 4,al
       mov al,3Fh
       out 3,al
       cmp forwmove,1
       jnz sd2
       mov al,26h
       out 5,al
       jmp sd1
   sd2:cmp backmove,1
       jnz sd3
       mov al,2ah
       out 5,al
       jmp sd1 
   sd3:cmp NomSet,1
       jnz sd4
       mov al,32h
       out 5,al
       jmp sd1
   sd4:mov al,22h
       out 5,al
   sd1:ret
EndP SetDelay


;10. ���६���஢���� �᫠
IncProc proc near
       cmp SetMode,1     ;�᫨ ��࠭ ०�� ����ன��
       jnz ip1
       cmp DelSet,1      ;�᫨ ��⠭����� 䫠� ����প� 
       jnz ip3
       in al,1
       cmp al,1          ;������ �����
       jnz ip1           ;�᫨ ����� ������ "+1"
       cmp bl,11         ;�᫨ ���稪 �� ����� 10 
       jnl  ip1
       inc bl            ;���६���஢���� ���稪�
       mov al,seconddig[bx] 
       out 3,al           ;�뢮� �᫠ �� ��஢�� ⠡��
       mov al,firstdig[bx]
       out 4,al
       mov cx,400h
   ip5:loop ip5    
       jmp ip1
   ip3:cmp NomSet,1        ;�᫨ ��⠭����� 䫠� �ணࠬ����� ������ 
       jnz ip1
       in al,1              
       cmp al,1            ;������ �����
       jnz ip1             ;�᫨ ����� ������ "+1"
       cmp bl,31      
       jnl  ip1            ;�᫨ ���稪 �� ����� 30
       inc bl              ; ���६���஢���� ���稪�
       mov al,seconddig[bx]
       out 3,al            ;�뢮� �᫠ �� ��஢�� ⠡�� 
       mov al,firstdig[bx]
       out 4,al
       mov cx,400h
   ip6:loop ip6    
       jmp ip1
   ip2:mov bl,31
       jmp ip1
   ip1:ret
EndP IncProc


;11. ���६���஢���� �᫠
DecProc proc near
       cmp SetMode,1     ;�᫨ ��࠭ ०�� ����ன��
       jnz dp1
       cmp NomSet,1      ;�᫨ ��⠭����� 䫠� �ணࠬ����� ������
       jnz dp3
   dp4:in al,1           ;������ �����
       cmp al,2          
       jnz dp1           ;�᫨ ����� ������ "-1"
       dec bl            ;���६���஢���� ���稪�
       cmp bl,0
       jle dp2           ;�᫨ �� ��᫥���� ����
       mov al,seconddig[bx]
       out 3,al            ;� �뢮� �᫠ �� ��஢�� ⠡��
       mov al,firstdig[bx]
       out 4,al 
       mov cx,400h
   dp5:loop dp5    
       jmp dp1
   dp2:mov bl,1
       jmp dp1
   dp3:cmp DelSet,1        ;�᫨ 䫠� ��⠭���� ����প� ࠢ�� 1
       jnz dp1             ;� ��室 �� ���� dp4
       jz  dp4 
   dp1:ret
EndP DecProc


;12. ������ ����প� ��� ����� ᫠��� 
AddDelNom proc near
       cmp SetMode,1        ;�᫨ ��࠭ ०�� ����ன��
       jnz adn1
       in al,1              ;������ �����
       cmp al,4
       jnz adn1             ;�᫨ ����� ������ "��������"
       cmp DelSet,1
       jnz adn2             ;�᫨ �ਧ��� ����প� ࠢ�� 1
       mov delay,bl         ;� � Delay �����뢠�� ����稭� ����প�
       mov DelReady,1       ;�ନ�㥬 �ਧ��� ��⮢���� ����প�
       mov DelSet,0         ;����뢠�� �ਧ��� ��⠭���� ����প�
       mov cx,600h
  adn3:loop adn3     
       jmp adn1
  adn2:cmp NomSet,1         ;�᫨ �ਧ��� �ணࠬ����� ������ =1
       jnz adn1
       inc si               ;� ���६����㥬 ���稪 �������� �� ���ᨢ�   
                            ;� ����ࠬ� ᫠����
       cmp si,21           
       jnl adn1             ;�᫨ �� ��᫥���� ᫠�� � ���ᨢ�
       mov SlideMas[si],bl  ;� ������塞 ����� ᫠��� � ���ᨢ
       mov ax,si
       mov MasLength,al     ;�����뢠�� ������ ���ᨢ�
       mov SlMasReady,1     ;���㥬 �ਧ��� ��⮢���� ��ᨨ��
       mov cx,600h
  adn4:loop adn4
  adn1:ret
EndP AddDelNom


;13. ������ ����� ᫠���� � ���ࠢ����ﬨ ���। � �����
StepShowing proc near
       cmp SlMasReady,1  ;�᫨ ���ᨢ � ����ࠬ� ᫠���� �� ��⮢
       jz  as1 
       cmp StepReady,1   ;�᫨ ��࠭ 蠣��� �����
       jnz as1
       cmp ShowMode,1    ;�᫨ ����祭 ०�� ��ᬮ��
       jnz as1 
       cmp ForwMove,1    ;�᫨ ��࠭� ���ࠢ����� �������� ���। 
       jnz as3
       in al,1
       cmp al,20h        ;������ �����
       jnz as1           ;�᫨ ����� ������ "���\�. ᫠��"
       mov al,6          ;����祭�� �����⥫�
       out 2,al
       mov al,5
       out 5,al
       mov cx,1024h
   as7:loop as7
       mov al,12h
       out 2,al         ;�몫�祭�� �����⥫�
       inc di           ;���६���஢���� ���稪�
       cmp di,31        ;�᫨ �� ��������� ����
       jnl as5
       mov al,seconddig[di]
       out 3,al             ;� �뢮� �� ��஢�� ⠡�� ����� �����뢠�����
       mov al,firstdig[di]  ;᫠���
       out 4,al
       jmp as1
   as3:cmp BackMove,1       ;�᫨ �������� ����� 
       jnz as1
       in al,1              ;������ �����
       cmp al,20h
       jnz as1              ;�᫨ ����� ������ "���\��. ᫠��"
       dec bp               ;���६���஢���� ���稪�
       cmp bp,0            
       jle as5              ;�᫨ �� ��᫥���� ����
       mov al,6             ;� ����祭�� �����⥫�
       out 2,al
       mov al,9h
       out 5,al
       mov cx,1024h
   as6:loop as6
       mov al,12h
       out 2,al            ;�몫�祭�� �����⥫�
       mov al,seconddig[bp]
       out 3,al             ;�뢮� ����� ᫠��� �� ��஢�� ⠡��
       mov al,firstdig[bp]
       out 4,al
       jmp as1
   as5:mov StepReady,0      ;��� �ਧ���� 蠣����� ������
       mov aL,0
       out 5,al
   as1:ret
EndP StepShowing 


;14. ������ �ணࠬ��� �����
StepProgShow proc near
       cmp StepReady,1      ;�᫨ ��࠭ 蠣��� �����
       jnz sps1
       cmp ShowMode,1       ;�᫨ ����祭 ०�� ��ᬮ��
       jnz sps1
       cmp SlMasReady,1     ;�᫨ ��⮢ ���ᨢ � ����ࠬ� ᫠����
       jnz sps1
       in al,1              ;������ �����
       cmp al,20h
       jnz sps1             ;�᫨ ����� ������ "���\��. ᫠��"
       mov al,6             ;� ����祭�� �����⥫�
       out 2,al
       mov al,11h
       out 5,al  
       mov ax,512h
       mul word ptr SlideMas[bx+1] ;��।������� ������ � ᫠�����
       mov cx,ax
  sps2:loop sps2
       mov al,12h
       out 2,al              ;�⪫�祭�� �����⥫�
       inc bx                ; ���६���஢���� ���稪�
       push bx
       mov bl,SlideMas[bx]   
       mov al,seconddig[bx]
       out 3,al             ;�뢮� ����� �����뢠����� ᫠���
       mov al,firstdig[bx]  ;�� ��஢�� ⠡�� 
       out 4,al 
       pop bx
       cmp MasLength,bl     
       jnz sps1             ;�᫨ ��᫥���� ᫠��
       mov StepReady,0      ;� ��� �ਧ���� 蠣����� ������  
       mov bx,1             ;��� ���稪�
       mov al,0
       out 5,al
  sps1:ret
EndP StepProgShow


;15. ��⮬���᪨� ����� ᫠���� � ���ࠢ����ﬨ ���। � �����
AutoShowing proc near
       cmp ShowMode,1       ;�᫨ ����祭 ०�� ������
       jnz aus10     
       cmp AutoReady,1      ;�᫨ ��࠭ ०�� ��⮬���ᮣ� ������
 aus10:jnz aus11
       cmp SLMasReady,1     ;�᫨ �� �ண࠭�� �����
       jz  aus12
       cmp StepShow,1
       jz  aus11
       cmp ForwMove,1       ;�᫨ ��࠭� �������� ���।
       jnz aus3  
       mov al,6             ;����祭�� �����⥫�
       out 2,al
       mov al,26h
       out 5,al
       mov cx,1024h
       jmp aus7
 aus11:jmp aus1
 aus7:loop aus7
       mov al,12h
       out 2,al             ;�몫�祭�� �����⥫�
       mov al,seconddig[di]
       out 3,al             ;�뢮� ����� �����뢠����� ᫠��� 
       mov al,firstdig[di]  ;�� ��஢�� ⠡��
       out 4,al
       inc di               ;���६���஢���� ���稪�
       cmp di,31            ;�᫨ �� ��᫥���� ����
       jnl aus5
       mov ax,500h
       imul word ptr delay  ;� ����প� ����� ᬥ��� ᫠����
       mov cx,ax
  aus2:in al,1
       cmp al,40h
 aus12:jz  aus1
       loop aus2
       jmp aus1
  aus3:cmp BackMove,1       ;�᫨ �������� �����
       jnz aus1
       mov al,6            ;����祭�� �����⥫�
       out 2,al
       mov al,2ah
       out 5,al
       mov cx,1024h
  aus6:loop aus6
       mov al,12h
       out 2,al             ;�몫�祭�� �����⥫�
       dec bp               ;���६���஢���� ���稪�
       cmp bp,0
       jle aus5             ;�᫨ �� ��᫥���� ����       
       mov al,seconddig[bp]
       out 3,al             ;� �뮤 �� ��஢�� ⠡��
       mov al,firstdig[bp]  ;����� �����뢠����� ᫠���
       out 4,al
       mov ax,500h
       mul word ptr delay   ;����প� ����� ᬥ��� ᫠����
       mov cx,ax
  aus4:in al,1
       cmp al,40h
       jz  aus1
       loop aus4      
       jmp aus1
  aus5:mov AutoReady,0      ;��� �ਧ���� ��⮬���᪮�� ������ 
       mov al,0
       out 5,al
  aus1:ret
EndP AutoShowing


;16. ��⮬���᪨� �ணࠬ��� �����
AutoProgShow proc near
       cmp StepShow,1       ;�᫨ ����প� ��⠭������  
       jz aps1
       cmp AutoReady,1      ;�᫨ ��࠭ ०�� ��⮬���᪮�� ������
       jnz aps1
       cmp ShowMode,1       ;�᫨ ����祭 ०�� ������
       jnz aps1
       cmp SlMasReady,1     ;�᫨ ���ᨢ � ����ࠬ� ᫠���� ��⮢
       jnz aps1
       mov al,32h
       out 5,al
       mov al,6
       out 2,al             ;����祭�� �����⥫�
       mov ax,500h
       mul word ptr SlideMas[bx+1]
       mov cx,ax
  aps3:loop aps3
       mov al,12h
       out 2,al              ;�몫�祭�� �����⥫�
       inc bx                ;���६���஢���� ���稪�
       push bx
       mov bl,SlideMas[bx]
       mov al,seconddig[bx]
       out 3,al             ;�뢮� �� ��஢�� ⠡�� ����� 
       mov al,firstdig[bx]  ;�����뢠����� ᫠���
       out 4,al 
       mov ax,500h
       mul word ptr delay   ;����প� ����� ᬥ��� ᫠����
       mov cx,ax
  aps2:in al,1
       cmp al,40h
       jz  aps1
       loop aps2   
       pop bx
       cmp MasLength,bl    
       jnz aps1             ;�᫨ ��᫥���� ������� � ���ᨢ�
       mov AutoReady,0      ;� ��� �ਧ���� ��⮬���᪮�� ������
       mov bx,1             ;��� ��稪
       mov al,0 
       out 5,al 
  aps1:ret
EndP AutoProgShow


;17. ��⠭���� ��⮬���᪨� �������
StopShowing proc near
       in al,1         ;������ �����
       cmp al,40h     
       jnz ss1         ;�᫨ ����� ������ "�⮯"
       cmp ShowMode,1  ;�᫨ ��࠭ ०�� ������
       jnz ss1
   ss3:mov AutoShow,0  ;� ���
       mov NomSet,0    ;�ਧ����� 
       mov DelSet,0    ;��⮬���᪮�� 
       mov DelReady,0  ;������
       mov SlMasReady,0
       mov AutoReady,0
   ss1:ret
EndP StopShowing 


;18. ������ ������ � ᫠����� � ��室��� ���ﭨ�
ReturnProc proc near
       cmp return,0     ;�᫨ ������ �� �� �뫮
       jnz rp1
       cmp showmode,1
       jnz rp1          ;�᫨ ����祭 ०�� ������
       in al,1
       cmp al,80h       ;������ �����
       jnz rp1          ;�᫨ ����� ������ "������"
       cmp ForwMove,1   ;�᫨ �������� ���।
       jnz rp3
       mov ax,256h      ;� �����⮢�� ��६�⪨ 
       mul di           ;� ��砥 �롮� ���ࠢ����� 
       mov cx,ax        ;�������� ���।
       jmp rp4
   rp3:cmp BackMove,1   ;�᫨ �������� �����
       jnz rp5
       mov ax,256h      ;� �����⮢�� ��६�⪨
       mul bp           ;� ��砥 �롮� ���ࠢ����� �������� �����
       mov cx,ax
       jmp rp4
   rp5:mov ax,256h                 ;�����⮢��
       mul word ptr slidemas[bx-1] ;��६�⪨
       mov cx,ax                   ;� ��砥 �ணࠬ����� ������ 
   rp4:mov al,6              
       out 2,al                    ;����祭�� �����⥫�
   rp2:loop rp2                    ;�६�⪠
       mov al,12h                  ;�몫�祭�� �����⥫�
       out 2,al  
       mov al,seconddig[1]
       out 3,al                  ;�뢮� �� ��஢�� ⠡�� "01"
       mov al,firstdig[1]    
       out 4,al
       mov bp,31
       mov di,1
       mov bx,1
       mov ForwMove,0
       mov BackMove,0 
       mov return,1
       
       mov al,0
       out 5,al 
   rp1:ret
EndP ReturnProc


          ;�����஢��� �ணࠬ��

begin1:                  ;���⥬��� �����⮢��
       mov ax,data1      ;���樠������
       mov ds,ax         ;ᥣ������
       mov ax,stack1     ;ॣ���஢
       mov ss,ax
       lea sp,StkTop     ;� 㪠��⥫� �⥪�

       call PrepareProc  ;�����⮢�� ������ 
begin2:call SetModeProc  ;���室 � ०�� ����ன��
       call ShowModeProc ;���室 � ०�� ������ 
       call StepShowProc ;�롮� 蠣����� ������
       call AutoShowProc ;�롮� ��⮬���᪮�� ������
       call ForwMoveProc ;��⠭���� ���ࠢ����� �������� ���।
       call BackMoveProc ;��⠭���� ���ࠢ����� �������� �����
       call SetSlideNom  ;�ନ஢���� 䫠�� �ணࠬ����� ������
       call SetDelay     ;�ନ஢���� 䫠�� ��⠭���� ����প�
       call IncProc      ;���६���஢���� �᫠
       call DecProc      ;���६���஢���� �᫠
       call AddDelNom    ;������ ����প� ��� ����� ᫠���
       call StepShowing  ;蠣��� ����� � ࠧ���묨 ���ࠢ����ﬨ
       call StepProgShow ;蠣��� �ணࠬ��� �����
       call AutoShowing  ;��⮬���᪨� ����� � ࠧ���묨 ���ࠢ����ﬨ
       call AutoProgShow ;��⮬���᪨� �ணࠬ��� �����
       call StopShowing  ;��⠭���� ��⮬���᪮�� ������
       call ReturnProc   ;������ ������ � ᫠����� � ��室��� ���������
       jmp begin2        ; ���몠��� �ணࠬ����� �����
       
       org 7f0h          ;���ᯥ祭�� ��砫쭮�� ����᪠
start: jmp begin1        ;�ணࠬ�� �� ����祭�� ���ன�⢠

code1 ends
      end start