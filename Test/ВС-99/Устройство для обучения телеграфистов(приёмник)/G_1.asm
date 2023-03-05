obnul_port proc  near
           mov   OutPort1,0
           mov   al,0                ;���㫥��� ᨣ����� ��室��� ���⮢ 
           out   1,al
           mov   OutPort2,0
           out   2,al
           and   OutPort3,0F8h
           mov   OutPort2_5,0
           mov   al,OutPort3
           out   3,al                           
           ret
obnul_port endp  

Tochca     proc  near         
           mov   bx,01h 
           cmp   CountDiod,0
           je    sdv_tka1
           mov   cl,CountDiod
sdv_tka:   shl   bx,1        ;�������� ������ ������樨 �� 1 ���� ��ࠢ�  
           rcl   dx,1        ;� ����������� "᫥��" ��� - ���⮣� �����  
           
           loop  sdv_tka           ;�몫: ���� ��<>0 
sdv_tka1:           
           add   CountDiod,2        ;��� ����� ������ ��� ���(1 �窠 + 1 �஡��)
           mov   fp,1               ;�।���頥� ������ �뢮� �窨 � �� 
           mov   BuffOut,01h                     ;⮫쪮 ��᫥ ᨣ���� � ���� 
           ret
Tochca     endp    

Tyre       proc   near
           mov   bx,07h
           cmp   CountDiod,0  
           je    sdv_tire1     ;�᫨ �� �� ��ࢮ� � �����, � ��� ᤢ����� �� ����   
           mov   cl,CountDiod  ;���頥� �뢮����� �� �� ������⢮ 㦥 ������� ������ 
sdv_tire:  shl   bx,1         ;�������� �������� ����� �� 4 ����� ��ࠢ�  
           rcl   dx,1         ;� ����������� "᫥��" �㫥�  
           loop  sdv_tire            ;�몫: ���� ��<>0 
sdv_tire1:           
           add   CountDiod,4         ;����� ����� ������ ��� ��(3 �� + 1 �஡��)���� � �� ���          
           mov   fp,1            
           mov   BuffOut,07h       
           ret
Tyre       endp
           
delay      proc  near           
           mov   cx,DelayUnits    ;�࣠���㥬 ����প�
DelayOut:  push  cx               ;�᫮� 横��� ࠢ�� 25000*DelayUnits
           mov   cx,061A8h
DelayIn:   
           loop  DelayIn
           pop   cx
           loop  DelayOut
           ret
delay      endp
           
VibrDestr  PROC
           push  ax
           push  bx
VD1:       mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
           mov   bh,0        ;���� ����稪� ����७��
VD2:       in    al,dx       ;���� ⥪�饣� ���ﭨ�
           cmp   ah,al       ;����饥 ���ﭨ�=��室����?
           jne   VD1         ;���室, �᫨ ���
           inc   bh          ;���६��� ����稪� ����७��
           cmp   bh,NMax     ;����� �ॡ����?
           jne   VD2         ;���室, �᫨ ���
           mov   al,ah       ;����⠭������� ���⮯�������� ������ 
           pop   bx
           pop   ax
           ret
VibrDestr  ENDP
;--------------------------������ �㪢�------------------------------------------------------------  
RecBukva   proc near             
           mov   al,OutPort1    
           mov   BYTE PTR Bukva,al
           mov   al,OutPort2   
           mov   BYTE PTR Bukva+1,al
           mov   al,OutPort2_5    
           mov   BYTE PTR Bukva+2,al
           mov   BYTE PTR Bukva+3,0
           mov   Flag_Rec,1          ;����蠥� �ࠢ������ �㪢�      
           ret
RecBukva   endp
;---------------------------����� ����� �㪢�-----------------------------------------------------
str_mod    proc  near
           push  si
           push  ax
           push  bx
           cmp   Flag_rr,0
           je    rec11
           mov   bl,no           ;����ᨬ ����� �㪢� � ⠡���
           mov   ah,0
           mov   al,S_count     ;���浪��� ����� �㪢� � ᮮ�饭��   
           mov   si,ax
           mov   soobcenye[si],bl 
           add   S_count,1     
rec11:           
           cmp   ind_buk,8
           jb    mode2
           mov   si,0
mode:      
           mov   ah,stroka[si+1]
           mov   stroka[si],ah
           inc   si
           cmp   si,7
           jne   mode
           mov   ah,no
           mov   stroka[7],ah
       
           mov   up,06h            ;  ���樠������ ���⮢ �뢮��    
           mov   cx,8                     ;�㬥��� � ��ப� ��稭����� � 1    
           mov   al,0h
           mov   dx,06h
mm:        out   dx,al  
           inc   up
           loop  mm
           mov   DelayUnits,045h    ;��楤�� ����প� 
           call  delay 
           
mode2:     mov   si,ind_buk
           mov   ah,no
           mov   stroka[si],ah 
           inc   ind_buk 
           
           pop   bx
           pop   ax
           pop   si
           ret
str_mod    endp

str_out    proc  near 
           push  di
           push  si
         
           
           mov   up,06h            ;  ���樠������ ���⮢ �뢮��   
           mov   left,014h  
           mov   down,022h
           mov   di,0                      ;�㬥��� � ��ப� ��稭����� � 1    
           
           
beg_out:          
           mov   al,stroka[di]
           mul   vosem
           mov   si,ax
           mov   al,01h
           mov   dx,up
           out   dx,al                
           mov   cl,01h 
          
M11:      
           mov   al,0                    ;�뢮� �㪢� 
           mov   dx,down
           out   dx,al   
           mov   al,Image[si]
           mov   dx,left
           out   dx,al        
           mov   al,cl
           mov   dx,down
           out   dx,al       
           inc   si
           shl   cl,1
           jnc   M11
             
           inc   di
           inc   up 
           inc   down
           inc   left 
           
           cmp   di,8
           jne   beg_out
           pop   si
           pop   di     
           ret
str_out   endp
FuncPrep   proc  near             ;�㭪樮���쭠� �����⮢��
           push  si
           mov   BuffOUT1,0
           mov   ind_buk,0
           mov   OutPort1,0       ;���㫥��� ᨣ����� ��室��� ���⮢ 
           mov   OutPort2,0
           mov   OutPort2_5,0
           mov   OutPort3,0 
           mov   OutPort0,0
           mov   InPort1,0      
           mov   Flag1,0          ;����襭�� ������   
           mov   Flag2,0          ;������ "+1" � "-1"   
           mov   AddrSoob,1       ;����� ᮮ�饭�� ����砫쭮 ࠢ�� 1   
           mov   al,0             ;�뢮� �����筮�� ���� ��   
           out   4,al             ;ᥬ�ᥣ����� 
           mov   al,SymImages[1]  
           out   5,al             ;���������
           mov   ah,Tochka1   
           mov   Scorost,ah      ;�����⮢��: ᪮���� - ��ࢠ�
           mov   CountPauza,0     ;���㫥��� ���稪� ���⥫쭮�� ���� 
           mov   CountSygnal,0    ;���㫥��� ���稪� ���⥫쭮�� ᨣ���� 
           mov   FlagSygn,0       ;���� ��砫� ࠡ��� ���� - �� �� ᨣ��� ��    
                                  ;������ ���⥫쭮�� ���� 
           mov   FlagProh,0              ;���� �������騩 ����୮� ���᫥��� ����                
           mov   CountDiod,0      ;������⢮ ������� ������ ࠢ�� 0 
           mov   bx,0FFh          ;���砫�, ���� �㪢� �� ������� �� �ࠢ������ � ⠡��楩 �� ���� 
           mov   Flag_Rec,0      ;���� ࠧ�襭�� �ࠢ����� � ����䨪�樨(0 - �����)
           
           mov   si,0
vvv:       mov   stroka[si],31        ;� ��ப� ���� �㤥� ������ �஡���
           inc   si 
           cmp   si,8
           jne   vvv
           
           mov   si,0
nnn:       mov   soobcenye[si],31
           inc   si
           cmp   si,64
           jne   nnn
           mov   S_count,0
           
           ;mov   Flag_Read,1  ;1 - ����� �ன� �����⮢�� � �⥭��
           mov   Fl_razr_read,0 ;0 - ����� ��宦����� ��楤��� �⥭��
           mov   testing,0
          
           
           mov   si,1
z2:        mov   bx,0
z1:        mov   mass_soob[si+bx],31   ;���ᨢ ��� ᮮ�饭�� 
           inc   bx
           cmp   bx,65
           jne   z1
           mov   Ind_zanyat[si],0  ;�� �祩�� ᢮�����
           inc   si
           cmp   si,12
           jne   z2
           mov   si,0
sss:       mov   S_count_mass[si],0
           inc   si
           cmp   si,64
           jne   sss
           mov   Flag_err,0
           mov   Proh_err,0
           
           pop   si
           ret                    
FuncPrep   endp

vvod_reg   proc  near            ;��楤�� ���� ०����
           push  ax
           push  dx
           push  cx
                
           mov   AddrInc,0       ;���� 䫠��� ����䨪�樨
           mov   AddrDec,0       ;���ᮢ
           in    al,1            ;���� ��४���⥫��
           mov   dx,1            ;��।�� ��ࠬ��஢
           call  VibrDestr       ;��襭�� �ॡ����
           mov   InPort1,al
           test  al,20h          ;�᫨ ����� ������ ��ࢠ� ᪮����
           jz    scor1
           mov   ah,tochka1
           mov   Scorost,ah      ;����⢨�, �᫨ ����� ��ࢠ� ᪮����
scor1:     test  al,40h          ;�᫨ ����
           jz    scor2
           mov   ah,tochka2
           mov   Scorost,ah     ;����⢨�, �᫨ ����� ���� ᪮����
scor2:     test  al,80h          ;�᫨ �����
           jz    scor3
           mov   ah,tochka3
           mov   Scorost,ah     ;����⢨�, �᫨ ����� ����� ᪮���� 
scor3:     
           test  al,01h          ;��⪨, ᮤ�ঠ騥 ᨬ��� m �⭮����� � �ନ஢����
           jz    m1              ;����� ᮮ�饭�� ᥬ�ᥣ������ �������஢                       
           mov   AddrInc,0FFh    ;�஢�ઠ, ����� �� ������ "+1", �᫨ �� - ��⠭���� 䫠�� AddrInc
           jmp   m2              ;�᫨ �� ������ ""+1" - ���室 �� ����� �஢�ન 
m1:        mov   Flag1,0         ;����襭�� ������ ������ "+1", �᫨ ����� ������ "-1" 
                                 ;��� �� ������� �� ������ �����
           test  al,02h          ;�஢�ઠ, ����� �� ������ "+1"
           jz    m2              ;���室, �᫨ ��� �� ࠦ��
           mov   AddrDec,0FFh    ;�᫨ ����� - ��⠭���� 䫠�� AddrDec
           jmp   m3  
m2:        mov   Flag2,0         ;����襭�� ������ ������ "-1", �᫨ ����� ������ "+1" 
                                 ;��� �� ������� �� ������ �����   
m3:        pop   cx
           pop   dx
           pop   ax
           ret
vvod_reg   endp      

vivod_reg  proc  near            ;��楤�� �⮡ࠦ���� ��⠭�������� ०����
           push  ax
           push  bx
           push  cx
           push  di
           and   OutPort3,0C7h   ;���⪠ ������ ᪮���, �᫨ ��࠭� ��㣠� 
           mov   ah,tochka1   
           cmp   Scorost,ah     ;�᫨ ᪮���� ࠢ�� ��।�������� ���祭��
           je    sv1             ;� ���室 �� (*)
           mov   ah,tochka2
           cmp   Scorost,ah
           je    sv2
           mov   ah,tochka3
           cmp   Scorost,ah
           je    sv3
           jmp   sv_end          ;�᫨ ᪮���� �� ᮮ⢥����� ��⠭������� ���祭��,
                                 ;� �������� �� �������� (OutPort3�������� ����� ⠪�)
sv1:       or    OutPort3,08h    ;(*) �ନ஢���� ᨣ���� ��室���� ���� 3
           jmp   sv_end          ;���室 �� �뢮� ᨣ����
sv2:       or    OutPort3,10h
           jmp   sv_end
sv3:       or    OutPort3,20h
sv_end:    mov   al,OutPort3
           out   3,al
            
           cmp   AddrInc,0FFh    ;���६��� ����?
           jne   outm            ;���室, �᫨ ���
           cmp   AddrSoob,10     ;����� ᮮ�饭�� ࠢ�� 10?
           je    outm            ;���室 �᫨ ��
           cmp   Flag1,0         ;������ "+1" �� �뫠 ����� � �।��騩 ⠪�?
           jne   outm            ;���室 �᫨ ���, �᫨ �� - ����� ���६���஢��� AddrSoob
           mov   Flag1,1         ;��⠭���� 䫠�� - �뫠 ����� "+1"
           add   AddrSoob,1      ;�⮣� ᫮����� �� �㤥�, �᫨ � �।��騩 ⠪� �� �뫠    
                                 ;����� ������ "-1" ��� �� ������ �� ���������� �����
           jmp   m_end
            
outm:      cmp   AddrDec,0FFh    ;���६��� ����?
           jne   m_end           ;���室, �᫨ ���
           cmp   AddrSoob,1      ;����� ᮮ�饭�� ࠢ�� 1?
           je    m_end           ;���室 �᫨ ��
           cmp   Flag2,0         ;������ "-1" �� �뫠 ����� � �।��騩 ⠪�?
           jne   m_end           ;���室 �᫨ ���, �᫨ �� - ����� ���६���஢��� AddrSoob
           mov   Flag2,1         ;��⠭���� 䫠�� - �뫠 ����� "-1"
           sub   AddrSoob,1      ;�⮣� ���⠭�� �� �㤥�, �᫨ � �।��騩 ⠪� �� �뫠    
                                 ;����� ������ "+1" ��� �� ������ �� ���������� �����
m_end:     cmp   AddrSoob,10     ;�᫨ AddrSoob ����� �� ���� ��� 
           je    viv10           ;� ���室 �� ᯥ�. �뢮�
           mov   bx,AddrSoob     ;�᫨ �� �����,
           mov   al,SymImages[bx];� AddrSoob �뢮�����
           out   5,al            ;�� ����訩 ᥬ�ᥣ����� ��������
           mov   al,0            ;���訩 - �� ������祭
           out   4,al
           jmp   end_viv         ;���室 �� ����� �뢮��
viv10:     mov   al,SymImages[1] ;�᫨ AddrSoob ࠢ�� 10 � � ���訩 ᥬ�ᥣ. ���. �뢮��� "1"   
           out   4,al 
           mov   al,SymImages[0] ;� ����訩 - "0"   
           out   5,al   
end_viv:   
           mov   di,AddrSoob
           cmp   Ind_zanyat[di],0FFh
           jne   end_pr_viv
           or    OutPort3,40h
           mov   al,OutPort3
           out   3,al
           jmp   end_pr
end_pr_viv:and   OutPort3,0BFh 
           mov   al,OutPort3
           out   3,al 
end_pr:                    
           pop   di
           pop   cx        
           pop   bx
           pop   ax
           ret          
vivod_reg  endp             

vvod_key   proc  near            ;��楤�� �⥭�� ᨣ����� ��৥ � ����
           push  ax
           push  bx
           push  cx
           push  dx
           cmp   Fl_razr_read,0
           jne   end_read111
           je    end_read222
end_read111: jmp   end_key  
end_read222: 
           in    al,2
           mov   dx,1 
           call  VibrDestr
           mov   InPort2,al
           test  al,01h          ;���� ᨣ��� � ����
           jz    pauza           ;���室 �᫨ ᨣ���� ���
           mov   Fl_razr_read,0   ;����饭�� ��宦�����  ��楤��� Read 
                                  ;����襭�� ⮫쪮 ��᫥ ������ ������ �⥭��
           or    OutPort0,01h     ;������� ������
           mov   al,OutPort0
           out   0,al                       
           mov   CountPauza,0    ;���� ᨣ���, ����� ���� ��� - 
                                 ;���稪 ���⥫쭮�� ���� ����塞                
           mov   fp,0                       
           add   CountSygnal,1   ;���稪 ���⥫쭮�� ᨣ���� 㢥��稢��� �� 1
           mov   FlagProh,0      ;���� �������騩 ����୮� ���᫥��� ���� 
           mov   FlagSygn,1      ;������ ��, ⥯��� ����� �����뢠�� ����
           mov   Fl_pr,0
           jmp   end_key 
                     
pauza:     cmp   Flag_err,1      �� �訡�� �� �⪫���� ������
           je    end_zvon
           and   OutPort0,0FEh   ;�몫���� ������
           mov   al,OutPort0
           out   0,al 
end_zvon:  
           cmp   FlagSygn,0       ;������ ��।������ ��᫥ ��� ����砭��. �᫨ ᭠砫�   
           je    end2             ;ᨣ���� �� �뫮, � ��㧠 �� �����뢠����   
           jne   end1
end2:      jmp   end_key          ;���室 �� ����� ⮫쪮 � ������� jmp �.�. �� ���쭨� ���室
end1:                             ;���室 ��  FlagSygn:=0 �.�.�ॡ���� �� 3 ��� 5 ��室��
                                   ;���-�� �� �஢��� �뤥ঠ���� ���� 
                                 
           mov   dx,0
           mov   bx,0
          
           mov   al,Scorost                        
           cmp   CountSygnal,al   ;20 = �窠 
           ja    tire             ;�᫨ ᨣ��� �����, � �� ��, �᫨ ����� - �窠 
           cmp   fp,0             ;�᫨ �窠 㦥 �뫠 �뢥����, � ���室 ��    
           jne   ftl              ;����� �뢮�� �窨/��  
           call  Tochca
           jmp   vivod
tire:      cmp   fp,0             ;�᫨ �� 㦥 �뫮 �뢥����, � ���室 ��    
           jne   ftl              ;����� �뢮�� �窨/��  
           call  Tyre
vivod:     
           or    OutPort1,bl         ;�������� ⮫쪮 �� �������� ᨬ��� (�窠 ��� ��)
           or    OutPort2,bh         ;� ࠭�� ��������묨 �� ������ ������樨
           or    OutPort2_5,dl 
           cmp   CountDiod,21        ;�᫨ ��� ����� ������樨 ����� ᨣ������, � �ਭ㤨⥫�� 
           ja    End_Key
           mov   al,OutPort1         ;�뢮� �祪 � �� �� ������ ������樨
           out   1,al
           mov   al,OutPort2
           out   2,al
           mov   al,OutPort2_5
           or    OutPort3,al         ;���� 3 �� �������� ��������� ᪮���, �� �⮬� ����
           mov   al,OutPort3         ;�������� � ᨣ���� OutPort3 �ਭ��� � ���� ᨣ���
           out   3,al                     
ftl:      
           mov   CountSygnal,0       ;���㫥��� ���稪� ���⥫쭮�� ᨣ����
           add   CountPauza,1        ;�����祭�� ���稪� ����   
           cmp   FlagProh,1 
           je    srav5pauz
           mov   al,Scorost
           mul   try
           cmp   CountPauza,al       ;""���� �ࠢ����� ���� � 3 �窨""
           jb    end_key 
           mov   FlagProh,1     
           call  RecBukva            ;��楤�� ����� �㪢�(�믮����� �� ���㫥��� ᨣ����� ���⮢) 
           mov   CountDiod,0 
           call  obnul_port           
srav5pauz: 
           mov   al,Scorost
           mul   pyat
           cmp   CountPauza,al           ;""���� �ࠢ����� ���� � 5 �窨""
           jb    end_key
           mov   FlagProh5,0             ;���� �������騩 ����୮� ���᫥��� ����
           mov   WORD PTR Bukva,0
           mov   WORD PTR Bukva+2,0
           mov   Flag_Rec,1              ;����蠥� �ࠢ������ �㪢�
           mov   FlagSygn,0                    
end_key:         
           pop   dx         
           pop   cx                                     
           pop   bx
           pop   ax
           ret
vvod_key   endp