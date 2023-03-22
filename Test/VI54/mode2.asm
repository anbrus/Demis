TestMode2  PROC NEAR
           push  cx
           mov   cx, 0
           call  Mode2_Datasheet1
           shl   ax, 0
           or    cx, ax
           mov   al, cl
           out   12h, al

           call  Mode2_Datasheet2
           shl   ax, 1
           or    cx, ax
           mov   al, cl
           out   12h, al

           call  Mode2_Datasheet3
           shl   ax, 2
           or    cx, ax
           mov   al, cl
           out   12h, al

           mov   ax, cx
           pop   cx
           ret
TestMode2  ENDP

Mode2_Datasheet1 PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 14h
            call  WriteCw
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            mov   al, 3
            call WriteCountByte
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
            AssertByteCeEq 1
            AssertOutLow
            call  SetClkHi
            AssertOutLow
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
            AssertByteCeEq 1
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = cr = 3
            AssertOutHi
            AssertByteCeEq 3

            mov   ax, 1
            ret
Mode2_Datasheet1 ENDP

Mode2_Datasheet2 PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 14h
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
            call  SetGateLow
            AssertOutHi
            call  SetClkLow ; ce = 2
            AssertOutHi
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 2
            AssertOutHi
            AssertByteCeEq 2
            call  SetGateHi
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
            AssertOutLow
            AssertByteCeEq 1
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = cr = 3
            AssertOutHi
            AssertByteCeEq 3
            call  SetClkHi
            AssertOutHi

            mov   ax, 1
            ret
Mode2_Datasheet2 ENDP

Mode2_Datasheet3 PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 14h
            call  WriteCw
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            mov   al, 4
            call  WriteCountByte
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 4
            AssertOutHi
            AssertByteCeEq 4
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 3
            AssertOutHi
            AssertByteCeEq 3
            mov   al, 5
            call  WriteCountByte
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
            AssertOutLow
            AssertByteCeEq 1
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = cr = 5
            AssertOutHi
            AssertByteCeEq 5
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 4
            AssertOutHi
            AssertByteCeEq 4
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 3
            AssertOutHi
            AssertByteCeEq 3

            mov   ax, 1
            ret
Mode2_Datasheet3 ENDP
