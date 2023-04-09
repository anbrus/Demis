TestMode3  PROC NEAR
           push  cx
           mov   cx, 0
           call  Mode3_Datasheet1
           shl   ax, 0
           or    cx, ax
           mov   al, cl
           out   13h, al

           call  Mode3_Datasheet2
           shl   ax, 1
           or    cx, ax
           mov   al, cl
           out   13h, al

           call  Mode3_Datasheet3
           shl   ax, 2
           or    cx, ax
           mov   al, cl
           out   13h, al

           mov   ax, cx
           pop   cx
           ret
TestMode3  ENDP

Mode3_Datasheet1 PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 16h
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
            call  SetClkLow ; ce = 2
            AssertOutHi
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 4
            AssertOutLow
            AssertByteCeEq 4
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertOutLow
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = cr = 4
            AssertOutHi
            AssertByteCeEq 4
            
            mov  ax, 1
            ret
Mode3_Datasheet1 ENDP

Mode3_Datasheet2 PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 16h
            call  WriteCw
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            mov   al, 5
            call WriteCountByte
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 4
            AssertOutHi
            AssertByteCeEq 4
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 2
            AssertOutHi
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 0
            AssertOutHi
            AssertByteCeEq 0
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 4
            AssertOutLow
            AssertByteCeEq 4
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertOutLow
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = cr = 4
            AssertOutHi
            AssertByteCeEq 4
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 2
            AssertOutHi
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 0
            AssertOutHi
            AssertByteCeEq 0
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 4
            AssertOutLow
            AssertByteCeEq 4
            
            mov  ax, 1
            ret
Mode3_Datasheet2 ENDP

Mode3_Datasheet3 PROC NEAR
            call  SetGateHi

            call  SetClkHi
            mov   al, 16h
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
            call  SetClkLow ; ce = 2
            AssertOutHi
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 4
            AssertOutLow
            AssertByteCeEq 4
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertOutLow
            AssertByteCeEq 2
            call  SetGateLow
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutHi
            call  SetClkLow
            AssertOutHi
            AssertByteCeEq 2
            call  SetGateHi
            AssertOutHi
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 4
            AssertOutHi
            AssertByteCeEq 4
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = 2
            AssertOutHi
            AssertByteCeEq 2
            call  SetClkHi
            AssertOutHi
            call  SetClkLow ; ce = cr = 4
            AssertOutLow
            AssertByteCeEq 4
            
            mov  ax, 1
            ret
Mode3_Datasheet3 ENDP