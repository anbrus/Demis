code segment
       assume cs:code

start: in al,0
       out 0,al
       jmp start
code ends
end start

        