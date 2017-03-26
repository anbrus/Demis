.686
.model    FLAT, C

.stack

.data      ;segment

;Таблица адресов подпрограмм
WordProc  DWORD AddProcW,AdcProcW,SubProcW,SbbProcW,OrProcW,AndProcW,XorProcW
          DWORD MulProcW,IMulProcW,DivProcW,IDivProcW,CmpProcW,TestProcW
ByteProc  DWORD AddProcB,AdcProcB,SubProcB,SbbProcB,OrProcB,AndProcB,XorProcB
          DWORD MulProcB,IMulProcB,DivProcB,IDivProcB,CmpProcB,TestProcB

;Таблица кодов операций
TableProc db "+#-_|&^*x/\?@"

;data      ends

.code      ;segment
          ;assume cs:code,ds:data,es:data

AsmCalc   PROC NEAR32 C USES ecx ebx edx edi Op:BYTE,a:DWORD,b:WORD,W:BYTE,pFl:DWORD
          lea ebx,ByteProc	;Выбираем 8-ми или 16-ти битные операции
          cmp W,0
          jz Switch
          lea ebx,WordProc
Switch:
          mov al,Op
          mov cl,13
          lea edi,TableProc
          repnz scasb		;Ищем адрес подпрограммы для заданной операции
          mov edx,12
          sub dl,cl
          shl edx,2
          add ebx,edx

          pushfd
          mov eax,pFl
          mov eax,[eax]		;eax=flags of 8086

          and eax,08D5h		;eax=arithmetical flags of 8086
          pushfd
          pop edx			;edx=CPU flags
          and edx,0FFFF702Ah  ;edx=CPU flags without 8086 arithmetical flags
          or eax,edx		;eax=CPU flags + flags of 8086

          push eax
          popfd
          call [ebx]
          jmp ToExit
          
;-------- Byte Procedures ---------------------

AddProcB LABEL NEAR
          mov al,Byte Ptr a
          mov ah,Byte Ptr b
          add al,ah
          retn

AdcProcB LABEL NEAR
          mov al,Byte Ptr a
          mov ah,Byte Ptr b
          adc al,ah
          retn

SubProcB LABEL NEAR
          mov al,Byte Ptr a
          mov ah,Byte Ptr b
          sub al,ah
          retn

SbbProcB LABEL NEAR
          mov al,Byte Ptr a
          mov ah,Byte Ptr b
          sbb al,ah
          retn

OrProcB LABEL NEAR
          mov al,Byte Ptr a
          mov ah,Byte Ptr b
          or al,ah
          retn

AndProcB LABEL NEAR
          mov al,Byte Ptr a
          mov ah,Byte Ptr b
          and al,ah
          retn

XorProcB LABEL NEAR
          mov al,Byte Ptr a
          mov ah,Byte Ptr b
          xor al,ah
          retn

CmpProcB LABEL NEAR
          mov al,Byte Ptr a
          mov ah,Byte Ptr b
          cmp al,ah
          retn

TestProcB LABEL NEAR
          mov al,Byte Ptr a
          mov ah,Byte Ptr b
          test al,ah
          retn

MulProcB LABEL NEAR
          mov al,Byte Ptr a
          mov ah,Byte Ptr b
          mul ah
          retn

IMulProcB LABEL NEAR
          mov al,Byte Ptr a
          mov ah,Byte Ptr b
          imul ah
          retn

DivProcB LABEL NEAR
          mov ax,Word Ptr a
          mov dl,Byte Ptr b
          div dl
          retn

IDivProcB LABEL NEAR
          mov ax,Word Ptr a
          mov dl,Byte Ptr b
          idiv dl
          retn

;-------- Word Procedures ---------------------

AddProcW LABEL NEAR
          mov ax,Word Ptr a
          mov bx,b
          add ax,bx
          retn

AdcProcW LABEL NEAR
          mov ax,Word Ptr a
          mov bx,b
          adc ax,bx
          retn

SubProcW LABEL NEAR
          mov ax,Word Ptr a
          mov bx,b
          sub ax,bx
          retn

SbbProcW LABEL NEAR
          mov ax,Word Ptr a
          mov bx,b
          sbb ax,bx
          retn

OrProcW LABEL NEAR
          mov ax,Word Ptr a
          mov bx,b
          or ax,bx
          retn

AndProcW LABEL NEAR
          mov ax,Word Ptr a
          mov bx,b
          and ax,bx
          retn

XorProcW LABEL NEAR
          mov ax,Word Ptr a
          mov bx,b
          xor ax,bx
          retn

CmpProcW LABEL NEAR
          mov ax,Word Ptr a
          mov bx,b
          cmp ax,bx
          retn

TestProcW LABEL NEAR
          mov ax,Word Ptr a
          mov bx,b
          test ax,bx
          retn

MulProcW LABEL NEAR
          mov ax,Word Ptr a
          mov dx,b
          mul dx
          pushfd
          and eax,0000FFFFh
          shl edx,16
          or eax,edx
          popfd
          retn

IMulProcW LABEL NEAR
          mov ax,Word Ptr a
          mov dx,b
          imul dx
          pushfd
          and eax,0000FFFFh
          shl edx,16
          or eax,edx
          popfd
          retn

DivProcW LABEL NEAR
          mov ax,Word Ptr a
          mov dx,Word Ptr a+2
          mov cx,b
          div cx
          pushfd
          and eax,0000FFFFh
          shl edx,16
          or eax,edx
          popfd
          retn

IDivProcW LABEL NEAR
          mov ax,Word Ptr a
          mov dx,Word Ptr a+2
          mov cx,b
          div cx
          pushfd
          and eax,0000FFFFh
          shl edx,16
          or eax,edx
          popfd
          retn
;-----------------------------------
ToExit:
          pushfd
          pop ebx			;ebx=flags
          mov edx,pFl   
          mov [edx],ebx		;*pFl=flags
          popfd

          ret
AsmCalc   endp


;code      ends
end
