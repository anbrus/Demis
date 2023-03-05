;------------------------------------------------------------
;          ���ᮢ�� �� ����������������� ��������         
;          ��㤥�� ��2-00    ���⨭ �.�.           
;          �९�����⥫�     ����஢ �.�.
;          "�������� ��������"
;          Design MicroSystems v3.3
;  ScCalc.asm - �᭮���� �����
;------------------------------------------------------------
.386                         ; ⮫쪮 ��� enter � leave (����� � �� 86, �᫨ �� ��������)
Name ScientificCaculator

include    define.asm        ; InitData, ⨯� ������, �� ����⠭��(define)
;____________________________________________________________

Data       SEGMENT AT 0h use16

NFlags     TNeedFlags <>     ; 䫠��
Operation  TOperation <>     ; �࠭�� ����樨(⥪.� ��� �।.)
Operands   TOperands  <>     ; �࠭�� ���࠭��(⥪.� ��� �।.)
Memory     TQuantity128bit <>; ������ ᮮ⢥��⢥���
Work       TQuantity128bit <>; ⨯� ⥬��, ����� � �� �ਣ������
Work1      TQuantity128bit <>
Work2      TQuantity128bit <>
Work3      TQuantity128bit <>
WorkMul    dw    14 dup(?)
modulo     dw    ?        
DisplayStr TString    <>       
KbdImage   db    5 DUP(?)    ; ��ࠧ ���������� �����筮
KeyCode    db    ?           ; �����⥫�� ᪠����
Error      db    ?           ; ��� ⥪�饩 �訡��(���� �� NFlags)               
                 
Data       ENDS
;____________________________________________________________

Stk        SEGMENT AT 160h use16
           dw    100h dup (?)          ; � ����ᮬ
StkTop     Label Word
Stk        ENDS
;____________________________________________________________


Code       SEGMENT use16
           ASSUME cs:Code, ds:Data;, es:InitData, ss:Stk

include    IO.asm                      
include    Service.asm
include    String.asm
include    math.asm

; Init     - ���樠�����㥬(NULL) �� ������쭮�
;
Init       proc  near
           push  ax
           call  ClearAll
           pop   ax           
           ret
Init       endp

Start:
           mov   ax,Data
           mov   ds,ax
           mov   ax,InitData
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           
           call  Init

  RunCycle:
           call  KbdInput
           call  KbdReview
           call  KbdReply
           call  Revise
           call  ShowDisplay
           
           jmp   RunCycle
           
           org   RomSize-16-((SIZE InitData+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END        
        
