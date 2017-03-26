
data segment
     db 32768 dup(?)
     db 32768 dup(?)
data ends

code segment
     assume cs:code,ds:data

start:
     mov bx,0FFFFh
     mov Byte Ptr [bx],34h
     mov Byte Ptr ds:[0],12h
     mov ax,[bx]
     mov ax,4C00h
     int 21h
code ends
end start