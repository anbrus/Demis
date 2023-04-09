TestMode4  PROC NEAR
            push  cx
            mov   cx, 0
            call  Mode4_Datasheet1
            shl   ax, 0
            or    cx, ax
            mov   al, cl
            out   14h, al

            call  Mode4_Datasheet2
            shl   ax, 1
            or    cx, ax
            mov   al, cl
            out   14h, al

            call  Mode4_Datasheet3
            shl   ax, 2
            or    cx, ax
            mov   al, cl
            out   14h, al

            mov   ax, cx
            pop   cx
            ret
TestMode4  ENDP

Mode4_Datasheet1 PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 18h
            call  WriteCw
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            mov   al, 3
            call  WriteCountByte
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 3
            AssertOutHi
            AssertByteCeEq 3
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 2
            AssertOutHi
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 1
            AssertOutHi
            AssertByteCeEq 1
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 0
            AssertOutLow
            AssertByteCeEq 0
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 0ffffh
            AssertOutHi
            AssertByteCeEq 0ffh

            xor   ax, ax
            mov   cx, ax
Mode4_Datasheet1_M1:            
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            loop  Mode4_Datasheet1_M1
            
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi

            mov  ax, 1
            ret
Mode4_Datasheet1 ENDP

Mode4_Datasheet2 PROC NEAR
            call  SetGateLow

            call  SetClkHi
            mov   al, 18h
            call  WriteCw
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            mov   al, 3
            call  WriteCountByte
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 3
            AssertOutHi
            AssertByteCeEq 3
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 3
            AssertOutHi
            AssertByteCeEq 3
            call  SetClkHi
            AssertOutHi
            call  SetGateHi
            AssertOutHi
            call  SetClkLow ; ce = 3
            AssertOutHi
            AssertByteCeEq 3
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 2
            AssertOutHi
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 1
            AssertOutHi
            AssertByteCeEq 1
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 0
            AssertOutLow
            AssertByteCeEq 0
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 0ffffh
            AssertOutHi
            AssertByteCeEq 0ffh

            mov   ax, 1
            ret
Mode4_Datasheet2 ENDP

Mode4_Datasheet3 PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 18h
            call  WriteCw
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            mov   al, 3
            call  WriteCountByte
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 3
            AssertOutHi
            AssertByteCeEq 3
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 2
            AssertOutHi
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 1
            AssertOutHi
            AssertByteCeEq 1
            mov   al, 2
            call  WriteCountByte ; cr = 2
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 2
            AssertOutHi
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 1
            AssertOutHi
            AssertByteCeEq 1
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 0
            AssertOutLow
            AssertByteCeEq 0
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 0ffffh
            AssertOutHi
            AssertByteCeEq 0ffh

            mov   ax, 1
            ret
Mode4_Datasheet3 ENDP
