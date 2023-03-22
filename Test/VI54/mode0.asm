TestMode0  PROC NEAR
           push  cx
           mov   cx, 0
           call  Mode0_Datasheet1
           shl   ax, 0
           or    cx, ax
           mov   al, cl
           out   10h, al

           call  Mode0_Datasheet2
           shl   ax, 1
           or    cx, ax
           mov   al, cl
           out   10h, al

           call  Mode0_Datasheet3
           shl   ax, 2
           or    cx, ax
           mov   al, cl
           out   10h, al

           mov   ax, cx
           pop   cx
           ret
TestMode0  ENDP

Mode0_Datasheet1 PROC NEAR
           call  SetGateHi
           call  SetClkHi
           mov   al, 10h
           call  WriteCw
           AssertOutLow
           call  SetClkLow
           AssertOutLow
           call  SetClkHi
           AssertOutLow
           call  SetClkLow
           AssertOutLow
           mov   al, 4
           call  WriteCountByte ; cr = 4
           AssertOutLow
           call SetClkHi
    
           AssertOutLow
           call  SetClkLow; // ce = cr = 4
           AssertByteCeEq 4
           AssertOutLow
           call  SetClkHi;
           AssertOutLow
           call  SetClkLow; // ce = 3
           AssertByteCeEq 3
           AssertOutLow
           call  SetClkHi;
           AssertOutLow
           call  SetClkLow; // ce = 2
           AssertByteCeEq 2
           AssertOutLow
           call  SetClkHi;
           AssertOutLow
           call  SetClkLow; // ce = 1
           AssertByteCeEq 1
           AssertOutLow
           call  SetClkHi;
           AssertOutLow
           call  SetClkLow; // ce = 0
           AssertByteCeEq 0
           AssertOutHi
           call  SetClkHi;
           AssertOutHi
           call  SetClkLow; // ce = 0xffff
           AssertByteCeEq 0ffh
           AssertOutHi

           xor   cx, cx
Mode0_Datasheet1_M1:
           call  SetClkHi;
           AssertOutHi
           call  SetClkLow;
           AssertOutHi
           loop  Mode0_Datasheet1_M1
           
           mov   cx, 5
Mode0_Datasheet1_M2:
           call  SetClkHi;
           AssertOutHi
           call  SetClkLow;
           AssertOutHi
           loop  Mode0_Datasheet1_M2

           mov   ax, 1
           ret
Mode0_Datasheet1 ENDP

Mode0_Datasheet2 PROC NEAR
            call  SetGateHi
            call  SetClkHi
            mov   al, 10h
            call  WriteCw
            AssertOutLow
            call  SetClkLow
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow
            AssertOutLow
            mov   al, 3
            call  WriteCountByte ; cr = 3
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = cr = 3
            AssertByteCeEq 3
            AssertOutLow
            call  SetClkHi
            call  SetGateLow
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertByteCeEq 2
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertByteCeEq 2
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = 2
            AssertByteCeEq 2
            AssertOutLow
            call  SetGateHi
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
            
            mov   ax, 1
            ret
Mode0_Datasheet2 ENDP

Mode0_Datasheet3 PROC NEAR
            call  SetGateHi
            call  SetClkHi
            mov   al, 10h
            call  WriteCw
            AssertOutLow
            call  SetClkLow
            AssertOutLow
            call  SetClkHi
            AssertOutLow
            call  SetClkLow
            AssertOutLow
            mov   al, 3
            call  WriteCountByte ; cr = 3
            AssertOutLow
            call  SetClkHi
            AssertOutLow
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

            mov    al, 2
            call  WriteCountByte ; cr = 2
            call  SetClkHi
            AssertOutLow
            call  SetClkLow ; ce = cr = 2
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
            AssertOutHi
            AssertByteCeEq 0ffh

            mov   ax, 1
            ret
Mode0_Datasheet3 ENDP
