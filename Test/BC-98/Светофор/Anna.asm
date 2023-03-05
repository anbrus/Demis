           title   Semaphore Driver 1.0 for Demis Beta
           subttl  (C)2002 by VS1-98 group. All rights reserved.
           .model  small
           .8086

SECLOOPLIM equ     800          ; 612(f=3MHz)

PRT_SENSOR equ     0000h        ; 1xIN
PRT_N      equ     0000h        ; 2xOUT
PRT_LTS    equ     0005h        ; 1xOUT
PRT_N1     equ     0010h        ; 1xOUT
PRT_N2     equ     0020h        ; 1xOUT
PRT_N3     equ     0030h        ; 1xOUT
PRT_N4     equ     0040h        ; 1xOUT
PRT_T      equ     0050h        ; 2xOUT

Data       segment at 00000h
Dpred      db      ?            ; D(t-dt)
D          db      ?            ; D(t)
N1         dw      ?            ; N1
N2         dw      ?            ; N2
N3         dw      ?            ; N3
N4         dw      ?            ; N4
N          dw      ?            ; N
S          dw      ?            ; S
T          dw      ?            ; T
SecLoop    dw      ?            ; SecLoop
           org     2048-2
StkTop     label   word
Data       ends

Code       segment
           assume  cs:Code, ds:Data, es:Data, ss:Data

; Init
Init       proc
           mov     Dpred, 0
           mov     D, 0
           mov     N1, 0
           mov     N2, 0
           mov     N3, 0
           mov     N4, 0
           mov     N, 0
           mov     S, 0
           mov     T, 0
           mov     SecLoop, 0
           ret
Init       endp

; X := [X<Xmin]*Xmin + [Xmin<=X<=Xmax] + [X>Xmax]*Xmax
NORM       macro   X, Xmin, Xmax
           mov     ax, X                  ; 10t
           sub     ax, Xmin               ; 4t
           sar     ax, 15                 ; 80t
           not     ax                     ; 3t
           and     X, ax                  ; 15t
           not     ax                     ; 3t
           and     ax, Xmin               ; 4t
           or      X, ax                  ; 15t
           mov     ax, Xmax               ; 4t
           sub     ax, X                  ; 10t
           sar     ax, 15                 ; 80t
           not     ax                     ; 3t
           and     X, ax                  ; 15t
           not     ax                     ; 3t
           and     ax, Xmax               ; 4t
           or      X, ax                  ; 15t
           endm                           ;=268t(MCC)

; ax := [A=B]*FFFFh
EQUAL      macro   A, B                   ; R  C  M
           mov     ax, A                  ; 2t/4t/10t
           cmp     ax, B                  ; 2t/4t/15t
           pushf                          ; 10t
           pop     ax                     ; 8t
           shl     ax, 9                  ; 56t
           sar     ax, 15                 ; 80t
           endm                           ;=158t(RR)/160t(RC)162t(CC)/173t(CM)/168t(MC)/178t(MM)

; ax := [A>B]*FFFFh
BIGGER     macro   A, B                   ; R  C  M
           mov     ax, B                  ; 2t/4t/10t
           sub     ax, A                  ; 3t/4t/15t
           sar     ax, 15                 ; 80t
           endm                           ;=85t(RR)84t(CC)/94t(CM)/99t(MC)/105t(MM)

; ShowAll
ShowAll    proc
           push    ds                     ; 10t
           mov     ax, cs                 ; 9t
           mov     ds, ax                 ; 9t
           lea     bx, ImgMap             ; 8t
; N1
           mov     al, byte ptr es:N1     ; 12t
           xlat                           ; 11t
           out     PRT_N1, al             ; 10t
; N2
           mov     al, byte ptr es:N2     ; 12t
           xlat                           ; 11t
           out     PRT_N2, al             ; 10t
; N3
           mov     al, byte ptr es:N3     ; 12t
           xlat                           ; 11t
           out     PRT_N3, al             ; 10t
; N4
           mov     al, byte ptr es:N4     ; 12t
           xlat                           ; 11t
           out     PRT_N4, al             ; 10t
; N
           mov     ax, es:N               ; 12t
           mov     cl, 10                 ; 10t
           div     cl                     ; 90t
           xchg    al, ah                 ; 3t
           xlat                           ; 11t
           out     PRT_N+0, al            ; 10t
           xchg    al, ah                 ; 3t
           xlat                           ; 11t
           out     PRT_N+1, al            ; 10t
; T
           mov     ax, es:T               ; 12t
           mov     cl, 10                 ; 10t
           div     cl                     ; 90t
           xchg    al, ah                 ; 3t
           xlat                           ; 11t
           out     PRT_T+0, al            ; 10t
           xchg    al, ah                 ; 3t
           xlat                           ; 11t
           out     PRT_T+1, al            ; 10t
; LTS
           mov     si, es:S               ; 16t
           mov     al, cs:LtMapX[si]      ; 20t
           out     PRT_LTS, al            ; 10t
; exit
           pop     ds                     ; 10t
           ret                            ; 8t
ShowAll    endp                           ;=552t

; CalcTime
CalcTime   proc
; SecLoop := SecLoop + 1
           inc     SecLoop                ; 21t
; SecLoop := [SecLoop<=SECLOOPLIM]*SecLoop
           cmp     SecLoop, SECLOOPLIM+1  ; 23t
           rcr     ax, 1                  ; 24t
           sar     ax, 15                 ; 80t
           and     SecLoop, ax            ; 15t
; T := T - 1*[SecLoop=0]
           cmp     SecLoop, 0+1           ; 23t
           sbb     T, 0                   ; 23t
; T := [T<0]*0 + [0<=X<=99] + [X>99]*99
           NORM    T, 0, 99               ; 268t
; exit
           ret                            ; 8t
CalcTime   endp                           ;=485t

; TestSensor
TestSensor proc
; D(t-dt) := D(t)
           mov     al, D                  ; 10t
           mov     Dpred, al              ; 10t
; D(t) := IN(PRT_SENSOR)
           in      al, PRT_SENSOR         ; 10t
           mov     D, al                  ; 10t
; CH := cl := SENSOR := D(t-dt) and not D(t)
           mov     cl, D                  ; 14t
           not     cl                     ; 3t
           and     cl, Dpred              ; 22t
           mov     ch, cl                 ; 2t
; N1 := N1+SENSOR[0]-SENSOR[1]
           rcr     cl, 1                  ; 24t
           adc     N1, 0                  ; 23t
           rcr     cl, 1                  ; 24t
           sbb     N1, 0                  ; 23t
; N2 := N2+SENSOR[2]-SENSOR[3]
           rcr     cl, 1                  ; 24t
           adc     N2, 0                  ; 23t
           rcr     cl, 1                  ; 24t
           sbb     N2, 0                  ; 23t
; N3 := N3+SENSOR[4]-SENSOR[5]
           rcr     cl, 1                  ; 24t
           adc     N3, 0                  ; 23t
           rcr     cl, 1                  ; 24t
           sbb     N3, 0                  ; 23t
; N4 := N4+SENSOR[6]-SENSOR[7]
           rcr     cl, 1                  ; 24t
           adc     N4, 0                  ; 23t
           rcr     cl, 1                  ; 24t
           sbb     N4, 0                  ; 23t
; N := N+SENSOR[0]+SENSOR[2]+SENSOR[4]+SENSOR[6]
           rcr     ch, 1                  ; 24t
           adc     N, 0                   ; 23t
           rcr     ch, 2                  ; 28t
           adc     N, 0                   ; 23t
           rcr     ch, 2                  ; 28t
           adc     N, 0                   ; 23t
           rcr     ch, 2                  ; 28t
           adc     N, 0                   ; 23t
; Nx = [Nx<0]*0 + [0<=Nx<=9]*Nx + [Nx>9]*9
           NORM    N1, 0, 9               ; 268t
           NORM    N2, 0, 9               ; 268t
           NORM    N3, 0, 9               ; 268t
           NORM    N4, 0, 9               ; 268t
; Nx = [N<0]*0 + [0<=N<=99]*N + [N>9]*99
           NORM    N, 0, 99               ; 268t
; exit
           ret                            ; 8t
TestSensor endp                           ;=2015t

; Update
Update     proc
; si := N13 := N1 + N3
           mov     si, N1                 ; 15t
           add     si, N3                 ; 22t
; di := N24 := N2 + N4
           mov     di, N2                 ; 15t
           add     di, N4                 ; 22t
; bp := [T=0]
           EQUAL   T, 0                   ; 168t
           mov     bp, ax                 ; 2t
; V(0-1) := [T=0][N13<>0][S=0]
           mov     bx, bp                 ; 2t
           EQUAL   si, 0                  ; 160t
           not     ax                     ; 3t
           and     bx, ax                 ; 3t
           EQUAL   S, 0                   ; 168t
           and     bx, ax                 ; 3t
           push    bx                     ; 10t
; V(1-2) := [T=0][S=1]
           mov     bx, bp                 ; 2t
           EQUAL   S, 1                   ; 168t
           and     bx, ax                 ; 3t
           push    bx                     ; 10t
; V(2-3) := [T=0][N24<>0][S=2]
           mov     bx, bp
           EQUAL   di, 0
           not     ax
           and     bx, ax
           EQUAL   S, 2
           and     bx, ax
           push    bx                     ;=349t
; V(3-0) := [T=0][S=3]
           mov     bx, bp
           EQUAL   S, 3
           and     bx, ax
           push    bx                     ;=186t
; ax := V(3-0), bx := V(2-3), cx := V(1-2), dx := V(0-1)
           pop     ax bx cx dx            ; 32t
           push    bx cx dx ax            ; 40t
; S := {S + [V(0-1)]*1 + [V(1-2)]*1 + [V(2-3)]*1 + [V(3-0)]*1}mod4
           or      ax, bx                 ; 3t
           or      ax, cx                 ; 3t
           or      ax, dx                 ; 3t
           and     ax, 1                  ; 4t
           add     S, ax                  ; 23t
           and     S, 03h                 ; 23t
; si := N13 + 1
           inc     si                     ; 2t
; di := N24 + 1
           inc     di                     ; 2t
; cx := Rhv := 5*(N13+1)/(N24+1)
           mov     ax, si                 ; 2t
           mov     cl, 5                  ; 4t
           mul     cl                     ; 71t
           mov     cx, di                 ; 2t
           div     cl                     ; 90t
           mov     cl, al                 ; 2t
; dx := Rvh := 5*(N24+1)/(N13+1)
           mov     ax, di
           mov     dl, 5
           mul     dl
           mov     dx, si
           div     dl
           mov     dl, al                 ;=171t
; bx := V(0-1)
           pop     bx                     ; 8t
; T := T + [V(3-0)]*(5 + Rvh)
           mov     ax, 5                  ; 4t
           add     ax, dx                 ; 3t
           and     ax, bx                 ; 3t
           add     T, ax                  ; 23t
; bx := V(1-2)
           pop     bx                     ; 8t
; T := T + [V(0-1)]*5
           mov     ax, 5                  ; 4t
           and     ax, bx                 ; 3t
           add     T, ax                  ; 23t
; bx := V(2-3)
           pop     bx                     ; 8t
; T := T + [V(1-3)]*(5 + Rhv)
           mov     ax, 5
           add     ax, cx
           and     ax, bx
           add     T, ax                  ;=33t
; bx := V(3-0)
           pop     bx                     ; 8t
; T := T + [V(2-3)]*5
           mov     ax, 5
           and     ax, bx
           add     T, ax                  ;=30t
; exit
           ret                            ; 8t
Update     endp                           ;=1757t

Start:     mov     ax, Data
           mov     ds, ax
           mov     es, ax
           mov     ss, ax
           lea     sp, StkTop
           call    Init

Cicle:     call    ShowAll      ; 19+552t
           call    CalcTime     ; 19+485t
           call    TestSensor   ; 19+2015t
           call    Update       ; 19+1757t
           jmp     Cicle        ; 15t      = 4900t

ImgMap     db      3Fh, 0Ch, 76h, 5Eh, 4Dh, 5Bh, 7Bh, 0Eh, 7Fh, 5Fh

LtMapX     db      01000001b    ; S=0
           db      00100011b    ; S=1
           db      00010100b    ; S=2
           db      00110010b    ; S=3

           org     00FF0h
           assume  cs:nothing
           jmp     far ptr Start
Code       ends
           end
