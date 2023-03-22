TestMode1  PROC NEAR
           push  cx
           mov   cx, 0
           call  Mode1_Datasheet1GateLow
           shl   ax, 0
           or    cx, ax
           mov   al, cl
           out   11h, al

           call  Mode1_Datasheet1GateHi
           shl   ax, 1
           or    cx, ax
           mov   al, cl
           out   11h, al

           call  Mode1_Datasheet2GateLow
           shl   ax, 2
           or    cx, ax
           mov   al, cl
           out   11h, al

           call  Mode1_Datasheet2GateHi
           shl   ax, 3
           or    cx, ax
           mov   al, cl
           out   11h, al

           call  Mode1_Datasheet3GateLow
           shl   ax, 4
           or    cx, ax
           mov   al, cl
           out   11h, al

           call  Mode1_Datasheet3GateHi
           shl   ax, 5
           or    cx, ax
           mov   al, cl
           out   11h, al

           mov   ax, cx
           pop   cx
           ret
TestMode1  ENDP

Mode1_Datasheet1GateLow PROC NEAR
            call  SetGateLow

            call  SetClkHi
            mov   al, 12h
            call  WriteCw
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            mov   al, 3
            call  WriteCountByte
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetGateHi
            call  SetClkLow
            AssertOutHi
            call  SetGateLow
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 3
            AssertByteCeEq 3
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertByteCeEq 2
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 1
            AssertByteCeEq 1
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 0
            AssertByteCeEq 0
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 0ffffh
            AssertByteCeEq 0ffh
            AssertOutHi
            call  SetGateHi
            call  SetClkHi
            AssertOutHi
            call  SetGateLow
            AssertOutHi
            call  SetClkLow ; ce = cr = 3
            AssertByteCeEq 3
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertByteCeEq 2
            AssertOutLow
            call  SetClkHi
            AssertOutLow

            mov   ax, 1
            ret
Mode1_Datasheet1GateLow ENDP

Mode1_Datasheet1GateHi PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 12h
            call WriteCw
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            mov   al, 3
            call  WriteCountByte
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            call  SetGateLow
            AssertOutHi
            call  SetGateHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 3
            AssertByteCeEq 3
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertByteCeEq 2
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 1
            AssertByteCeEq 1
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 0
            AssertByteCeEq 0
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetGateLow
            AssertOutHi
            call  SetClkLow ; ce = 0ffffh
            AssertByteCeEq 0ffh
            AssertOutHi
            call  SetGateHi
            call  SetClkHi
            AssertOutHi
            call  SetGateLow
            AssertOutHi
            call  SetClkLow ; ce = cr = 3
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertOutLow
            call  SetClkHi
            AssertOutLow

            mov   ax, 1
            ret
Mode1_Datasheet1GateHi ENDP

Mode1_Datasheet2GateLow PROC NEAR
            call  SetGateLow

            call  SetClkHi
            mov   al, 12h
            call  WriteCw
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            mov   al, 3
            call WriteCountByte
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetGateHi
            call  SetClkLow
            AssertOutHi
            call  SetGateLow
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 3
            AssertByteCeEq 3
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertByteCeEq 2
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetGateHi
            AssertOutLow
            call  SetClkLow ; ce = 1
            AssertByteCeEq 1
            AssertOutLow
            call  SetGateLow
            AssertOutLow
            AssertByteCeEq 1
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = cr = 3
            AssertOutLow
            AssertByteCeEq 3
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertByteCeEq 2
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 1
            AssertByteCeEq 1
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 0
            AssertByteCeEq 0
            AssertOutHi

            mov   ax, 1
            ret
Mode1_Datasheet2GateLow ENDP

Mode1_Datasheet2GateHi PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 12h
            call  WriteCw
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            mov   al, 3
            call  WriteCountByte
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetGateLow
            AssertOutHi
            call  SetGateHi
            call  SetClkLow
            AssertOutHi
            call  SetGateLow
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 3
            AssertByteCeEq 3
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertByteCeEq 2
            AssertOutLow
            call  SetGateLow
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetGateHi
            AssertOutLow
            call  SetClkLow ; ce = 1
            AssertByteCeEq 1
            AssertOutLow
            call  SetGateLow
            AssertOutLow
            AssertByteCeEq 1
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = cr = 3
            AssertOutLow
            AssertByteCeEq 3
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertByteCeEq 2
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 1
            AssertByteCeEq 1
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 0
            AssertByteCeEq 0
            AssertOutHi

            mov   ax, 1
            ret
Mode1_Datasheet2GateHi ENDP

Mode1_Datasheet3GateLow PROC NEAR
            call  SetGateLow

            call  SetClkHi
            mov   al, 12h
            call  WriteCw
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            mov   al, 2
            call  WriteCountByte
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetGateHi
            call  SetClkLow
            AssertOutHi
            call  SetGateLow
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 2
            AssertByteCeEq 2
            AssertOutLow
            call  SetClkHi
            mov   al, 4
            call  WriteCountByte
            call  SetClkLow ; ce = 1
            AssertByteCeEq 1
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 0
            AssertByteCeEq 0
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 0ffffh
            AssertByteCeEq 0ffh
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 0fffeh
            AssertOutHi
            call  SetGateHi
            AssertByteCeEq 0feh
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetGateLow
            AssertOutHi
            call  SetClkLow ; ce = cr = 4
            AssertOutLow
            AssertByteCeEq 4
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 3
            AssertOutLow
            AssertByteCeEq 3

            mov   ax, 1
            ret
Mode1_Datasheet3GateLow ENDP

Mode1_Datasheet3GateHi PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 12h
            call  WriteCw
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            mov   al, 2
            call  WriteCountByte
            call  SetClkLow
            AssertOutHi
            call  SetGateLow
            call  SetClkHi
            AssertOutHi
            call  SetGateHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 2
            AssertByteCeEq 2
            AssertOutLow
            call  SetClkHi
            mov   al, 4
            call  WriteCountByte
            call  SetClkLow ; ce = 1
            AssertByteCeEq 1
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 0
            AssertByteCeEq 0
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 0ffffh
            AssertByteCeEq 0ffh
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 0fffeh
            call  SetGateLow
            AssertOutHi
            call  SetGateHi
            AssertByteCeEq 0feh
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 4
            AssertOutLow
            AssertByteCeEq 4
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 3
            AssertOutLow
            AssertByteCeEq 3

            mov   ax, 1
            ret
Mode1_Datasheet3GateHi ENDP
