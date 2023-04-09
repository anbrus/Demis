TestMode5  PROC NEAR
            push  cx

            mov   cx, 0
            call  Mode5_Datasheet1_Gate_Low
            shl   ax, 0
            or    cx, ax
            mov   al, cl
            out   15h, al

            call  Mode5_Datasheet1_Gate_High
            shl   ax, 1
            or    cx, ax
            mov   al, cl
            out   15h, al

            call  Mode5_Datasheet2_Gate_Low
            shl   ax, 2
            or    cx, ax
            mov   al, cl
            out   15h, al

            call  Mode5_Datasheet2_Gate_High
            shl   ax, 3
            or    cx, ax
            mov   al, cl
            out   15h, al

            call  Mode5_Datasheet3_Gate_Low
            shl   ax, 4
            or    cx, ax
            mov   al, cl
            out   15h, al

            call  Mode5_Datasheet3_Gate_High
            shl   ax, 5
            or    cx, ax
            mov   al, cl
            out   15h, al

            mov   ax, cx
            pop   cx
            ret
TestMode5  ENDP

Mode5_Datasheet1_Gate_Low PROC NEAR
            call  SetGateLow

            call  SetClkHi
            mov   al, 1ah
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
            call  SetClkLow
            AssertOutHi
            call  SetGateHi
            AssertOutHi
            call  SetGateLow
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
            call  SetGateHi
            AssertOutLow
            call  SetClkLow ; ce = 0ffffh
            AssertOutHi
            AssertByteCeEq 0ffh
            call  SetGateLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 3
            AssertOutHi
            AssertByteCeEq 3
            
            mov   ax, 1
            ret
Mode5_Datasheet1_Gate_Low ENDP

Mode5_Datasheet1_Gate_High PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 1ah
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
            call  SetGateLow
            AssertOutHi
            call  SetClkLow
            AssertOutHi
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
            AssertOutHi
            AssertByteCeEq 1
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 0
            AssertOutLow
            AssertByteCeEq 0
            call  SetClkHi
            AssertOutLow
            call  SetGateLow
            AssertOutLow
            call  SetGateHi
            AssertOutLow
            call  SetClkLow ; ce = 0ffffh
            AssertOutHi
            AssertByteCeEq 0ffh
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 3
            AssertOutHi
            AssertByteCeEq 3

            mov   ax, 1
            ret
Mode5_Datasheet1_Gate_High ENDP

Mode5_Datasheet2_Gate_Low PROC NEAR
            call  SetGateLow

            call  SetClkHi
            mov   al, 1ah
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
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetGateHi
            AssertOutHi
            call  SetGateLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 3
            AssertOutHi
            AssertByteCeEq 3
            call  SetClkHi
            AssertOutHi
            call  SetGateHi
            AssertOutHi
            call  SetClkLow ; ce = 2
            AssertOutHi
            AssertByteCeEq 2
            call  SetGateLow
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

            mov   ax, 1
            ret
Mode5_Datasheet2_Gate_Low ENDP

Mode5_Datasheet2_Gate_High PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 1ah
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
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetGateLow
            AssertOutHi
            call  SetGateHi
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
            call  SetGateHi
            AssertOutHi
            call  SetClkLow ; ce = 2
            AssertOutHi
            AssertByteCeEq 2
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

            mov   ax, 1
            ret
Mode5_Datasheet2_Gate_High ENDP

Mode5_Datasheet3_Gate_Low PROC NEAR
            call  SetGateLow

            call  SetClkHi
            mov   al, 1ah
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
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetGateHi
            AssertOutHi
            call  SetGateLow
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
            mov   al, 5
            call  WriteCountByte
            AssertOutHi
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
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 0xfffe
            AssertOutHi
            AssertByteCeEq 0feh
            call  SetGateHi
            AssertOutHi
            call  SetGateLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 5
            AssertOutHi
            AssertByteCeEq 5
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 4
            AssertOutHi
            AssertByteCeEq 4

            mov   ax, 1
            ret
Mode5_Datasheet3_Gate_Low ENDP

Mode5_Datasheet3_Gate_High PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 1ah
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
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetGateLow
            AssertOutHi
            call  SetClkLow
            AssertOutHi
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
            mov   al, 5
            call  WriteCountByte
            AssertOutHi
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
            call  SetClkHi
            AssertOutHi
            call  SetGateLow
            AssertOutHi
            call  SetClkLow ; ce = 0fffeh
            AssertOutHi
            AssertByteCeEq 0feh
            call  SetGateHi
            AssertOutHi
            call  SetGateLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 5
            AssertOutHi
            AssertByteCeEq 5
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 4
            AssertOutHi
            AssertByteCeEq 4

            mov   ax, 1
            ret
Mode5_Datasheet3_Gate_High ENDP