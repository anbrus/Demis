SetGateHi  PROC  NEAR
           mov   al, 80h
           out   0, al
           ret
SetGateHi  ENDP

SetGateLow PROC  NEAR
           mov   al, 0h
           out   0, al
           ret
SetGateLow ENDP

SetClkHi   PROC  NEAR
           mov   al, 1h
           out   1, al
           ret
SetClkHi   ENDP

SetClkLow  PROC  NEAR
           mov   al, 0h
           out   1, al
           ret
SetClkLow  ENDP

GetOut     PROC  NEAR
           xor   ah, ah
           in    al, 0
           ret
GetOut     ENDP

GetCeByte  PROC  NEAR
           in    al, 40h
           xor   ah, ah
           ret
GetCeByte  ENDP

WriteCw    PROC  NEAR
           out   43h, al
           ret
WriteCw    ENDP

WriteCountByte   PROC  NEAR
           out   40h, al
           ret
WriteCountByte   ENDP

WriteCountWord   PROC  NEAR
           out   40h, al
           xchg  al, ah
           out   40h, al
           ret
WriteCountWord   ENDP

AssertOutHi      MACRO
           LOCAL AssertOutHiOk
           
           in    al, 0
           or    al, al
           jnz   AssertOutHiOk
           xor   ax, ax
           ret
AssertOutHiOk:
           ENDM

AssertOutLow     MACRO
           LOCAL AssertOutLowOk

           in    al, 0
           or    al, al
           jz    AssertOutLowOk
           xor   ax, ax
           ret
AssertOutLowOk:           
           ENDM

AssertByteEq     MACRO value: REQ
           LOCAL AssertEqOk
           
           cmp   al, value
           jz    AssertEqOk
           xor   ax, ax
           ret
AssertEqOk:
           ENDM
           
AssertByteCeEq   MACRO value: REQ
           LOCAL AssertByteCeEqOk
           
           in    al, 40h
           cmp   al, value
           jz    AssertByteCeEqOk
           xor   ax, ax
           ret
AssertByteCeEqOk:
           ENDM
           
AssertWordCeEq   MACRO value: REQ
           LOCAL AssertWordCeEqOk
           
           in    al, 40h
           xchg  al, ah
           in    al, 40h
           xchg  al, ah
           cmp   ax, value
           jz    AssertWordCeEqOk
           xor   ax, ax
           ret
AssertWordCeEqOk:
           ENDM