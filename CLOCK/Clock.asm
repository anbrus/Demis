;
;                                       They might or they might not,
;                                       You never can tell with bees.
;                                                    Winnie-the-Pooh.
;
;====== CONST =================================================================

OneSecondDelay  EQU     10

ptHourHi        EQU     0       ; ports
ptHourLo        EQU     1
ptMinHi         EQU     2
ptMinLo         EQU     3
ptSecHi         EQU     4
ptSecLo         EQU     5
ptButtons       EQU     6
ptMode          EQU     7
ptAlarm         EQU     8

btNone          EQU     00      ; masks for checking buttons
btMode          EQU     01
btSelect        EQU     02
btStart         EQU     04
btBack          EQU     08
btReset         EQU     10

mdShowTime      EQU     0       ; modes
mdSetAlarm      EQU     1
mdStopWatch     EQU     2
mdTimer         EQU     3
mdSetTime       EQU     4
mdSetDate       EQU     5
mdShowDate      EQU     6

chNone          EQU     0       ; choosed time
chHour          EQU     1
chMin           EQU     2
chSec           EQU     3

chDay           EQU     1       ;choosed date
chMonth         EQU     2
chYear          EQU     3
                                ; misc
FALSE           EQU     0       ; this means false
TRUE            EQU     0FFh    ; and this - true. understand ?

DELAY_SIZE      EQU     1300       ; delay


;====== DATA =================================================================
data    SEGMENT at 0BA00H

        old_ticks_l     dw      ?       ; ticks, that was taken last time
        old_ticks_h     dw      ?

        tick            db      ?       ; current values
        sec             db      ?
        min             db      ?
        hour            db      ?
        day             db      ?
        month           db      ?
        year            dw      ?
        days_in_month   db      ?

        dim_table       db      13      dup (?) ; days in month table

        current_mode    db      ?       ; mode
        pressed         db      ?       ;1 or 2 button pressed in mode

        alarm_on        db      ?       ; on or off
        alarm_ch        db      ?       ;choosed number(hours,minutes,seconds)
        alarm_hour      db      ?
        alarm_min       db      ?
        alarm_sec       db      ?

        st_on           db      ?
        st_begin        dw      ?
        st_end          dw      ?
        st_min          db      ?
        st_sec          db      ?
        st_tick         db      ?
        st_tenth        db      ?       ; десятые доли секунды
        st_real_on      db      ?

        timer_on        db      ?
        timer_was_on    db      ?
        timer_size      dw      ?
        timer_begin     dw      ?
        timer_end       dw      ?
        timer_min       db      ?
        timer_sec       db      ?

        set_time_ch     db      ?       ; choosed

        set_date_ch     db      ?

        map             db      0Ah     dup     (?)     ; font

        TickCounter     dd      ?
        TickSubCounter  dw      ?

data    ENDS                            ; there are no more variables...



;====== STACK ================================================================
stack   SEGMENT at 0BA80H       
        dw      50H dup (?)    
        StkTop  label   word    
stack   ENDS                    
                                


;====== CODE =================================================================
code    SEGMENT
        ASSUME cs:code, ds:data, ss:stack

;------ Delay ----------------------------------------------------------------
Delay           PROC
        mov     cx,delay_size
do_delay:
        loop    do_delay
        ret
Delay           ENDP

;------ GetTime --------------------------------------------------------------
GetTime         PROC
        xor     ah,ah                   ; get current ticks
        int     1Ah
        mov     ax,dx
        mov     dx,cx

        push    dx                      ; save current ticks
        push    ax

        sub     ax,old_ticks_l          ; check, how many ticks gone from
        sbb     dx,old_ticks_h          ; last time

        cmp     ax,0                    ; if computer too fast then
        jne     ___not_zero             ; repeat this next time
        cmp     dx,0
        jne     ___not_zero
        jmp     time_refreshed
___not_zero:

        xor     ch,ch
        mov     cl,18
        div     cx

        add     tick,dl
        cmp     tick,18
        jae     inc_sec
        jmp     time_refreshed
inc_sec:
        mov     tick,0
        inc     sec
        cmp     sec,60
        jae     inc_min
        jmp     time_refreshed
inc_min:
        mov     sec,0
        inc     min
        cmp     min,60
        jae     inc_hour
        jmp     time_refreshed
inc_hour:
        mov     min,0
        inc     hour
        cmp     hour,24
        jae     inc_day
        jmp     time_refreshed
inc_day:
        mov     hour,0
        inc     day
        mov     al,days_in_month
        cmp     day,al
        jae     inc_month
        jmp     time_refreshed
inc_month:
        mov     day,1
        inc     month
        call    SetDaysInMonth
        cmp     month,12
        jae     inc_year
        jmp     time_refreshed
inc_year:
        mov     month,1
        inc     year
        cmp     year,2080
        jbe     time_refreshed
        mov     year,1980

time_refreshed:
        pop     ax                      ; saving current ticks for next time
        mov     old_ticks_l,ax
        pop     dx
        mov     old_ticks_h,dx

        ret
GetTime         ENDP

;------ PackTime -------------------------------------------------------------
; in  : AL = min, DL = sec
; out : AX = time
PackTime        PROC
        mov     ch,60
        mul     ch
        xor     dh,dh
        add     ax,dx
        ret
PackTime        ENDP

;------ UnpackTime -----------------------------------------------------------
; in  : AX = time
; out : AL = min, AH = sec
UnpackTime      PROC
        mov     ch,60
        div     ch
        ret
UnpackTime      ENDP

;------ AdjustTime -----------------------------------------------------------
; in : ax = packed time
AdjustTime      PROC
        test    ax,8000h        ; if time is more than 60 minutes...
        jz      not_adjust
        neg     ax
not_adjust:
        ret
AdjustTime      ENDP

;------ GetPackedTime --------------------------------------------------------
GetPackedTime   PROC
        call    GetTime
        mov     al,min
        mov     dl,sec
        call    PackTime
        ret
GetPackedTime   ENDP

;--------------------------------------------------------SetDaysInMonth ------
SetDaysInMonth  PROC
        push    bx                      ; set new days_in_month
        mov     al,month
        lea     bx,dim_table
        xlat
        mov     days_in_month,al
        pop     bx

        cmp     day,al                  ; check if current day more
        jbe     day_in_month            ; than days_in_month
        mov     day,al
day_in_month:
        ret
SetDaysInMonth  ENDP

;------ ShowTime -------------------------------------------------------------
ShowTime        PROC
        call    GetTime
        mov     al,hour
        aam
        xlat
        out     1,al
        mov     al,ah
        xlat
        out     0,al
        mov     al,min
        aam
        xlat
        out     3,al
        mov     al,ah
        xlat
        out     2,al
        mov     al,sec
        aam
        xlat
        out     5,al
        mov     al,ah
        xlat
        out     4,al
        ret
ShowTime        ENDP

;------ ShowAlarmTime --------------------------------------------------------
ShowAlarmTime   PROC
        mov     al,alarm_hour
        aam
        xlat
        cmp     alarm_ch,chHour
        jne     choosed_not_hours1
        or      al,80h
choosed_not_hours1:
        out     1,al
        mov     al,ah
        xlat
        cmp     alarm_ch,chHour
        jne     choosed_not_hours2
        or      al,80h
choosed_not_hours2:
        out     0,al
        mov     al,alarm_min
        aam
        xlat
        cmp     alarm_ch,chMin
        jne     choosed_not_mins1
        or      al,80h
choosed_not_mins1:
        out     3,al
        mov     al,ah
        xlat
        cmp     alarm_ch,chMin
        jne     choosed_not_mins2
        or      al,80h
choosed_not_mins2:
        out     2,al
        xor     al,al
        out     4,al
        out     5,al
        ret
ShowAlarmTime   ENDP

;------ ShowStopWatch --------------------------------------------------------
ShowStopWatch   PROC
        cmp     st_on,TRUE
        jne     use_old_st_end
        call    GetPackedTime
        mov     st_end,ax

use_old_st_end:
        mov     ax,st_end
        sub     ax,st_begin
        call    AdjustTime
        call    UnpackTime
        mov     st_min,al
        mov     st_sec,ah

        mov     al,st_min
        aam
        xlat
        out     1,al
        mov     al,ah
        xlat
        out     0,al

        mov     al,st_sec
        aam
        xlat
        out     3,al
        mov     al,ah
        xlat
        out     2,al

        xor     al,al
        out     4,al


        cmp     st_on,TRUE
        je      show_tenth
        mov     al,st_tenth
        xlat
        out     5,al
        ret

show_tenth:
        mov     al,tick
        cmp     al,st_tick              ; abs( begin tick  - current tick )
        ja      tick_ok
        add     al,19
tick_ok:
        sub     al,st_tick
        xor     ah,ah
        mov     cl,2
        div     cl
        mov     st_tenth,al
        xlat
        out     5,al

        ret
ShowStopWatch   ENDP

;------ ShowTimer ------------------------------------------------------------
ShowTimer       PROC
        xor     al,al
        out     1,al
        out     0,al
        mov     al,timer_min
        aam
        xlat
        out     3,al
        mov     al,ah
        xlat
        out     2,al
        mov     al,timer_sec
        aam
        xlat
        out     5,al
        mov     al,ah
        xlat
        out     4,al
        ret
ShowTimer       ENDP

;------ ShowSetTime ----------------------------------------------------------
ShowSetTime     PROC
        call    GetTime
        mov     al,hour
        aam
        xlat
        cmp     set_time_ch,chHour
        jne     sst_choosed_not_hours1
        or      al,80h
sst_choosed_not_hours1:
        out     1,al
        mov     al,ah
        xlat
        cmp     set_time_ch,chHour
        jne     sst_choosed_not_hours2
        or      al,80h
sst_choosed_not_hours2:
        out     0,al
        mov     al,min
        aam
        xlat
        cmp     set_time_ch,chMin
        jne     sst_choosed_not_mins1
        or      al,80h
sst_choosed_not_mins1:
        out     3,al
        mov     al,ah
        xlat
        cmp     set_time_ch,chMin
        jne     sst_choosed_not_mins2
        or      al,80h
sst_choosed_not_mins2:
        out     2,al
        mov     al,sec
        aam
        xlat
        cmp     set_time_ch,chSec
        jne     sst_choosed_not_secs1
        or      al,80h
sst_choosed_not_secs1:
        out     5,al
        mov     al,ah
        xlat
        cmp     set_time_ch,chSec
        jne     sst_choosed_not_secs2
        or      al,80h
sst_choosed_not_secs2:
        out     4,al
        ret
ShowSetTime     ENDP

;------ ShowSetDate ----------------------------------------------------------
ShowSetDate     PROC
        call    GetTime
        mov     al,day
        aam
        xlat
        cmp     set_date_ch,chDay
        jne     sd_choosed_not_day1
        or      al,80h
sd_choosed_not_day1:
        out     1,al
        mov     al,ah
        xlat
        cmp     set_date_ch,chDay
        jne     sd_choosed_not_day2
        or      al,80h
sd_choosed_not_day2:
        out     0,al
        mov     al,month
        aam
        xlat
        cmp     set_date_ch,chMonth
        jne     sd_choosed_not_month1
        or      al,80h
sd_choosed_not_month1:
        out     3,al
        mov     al,ah
        xlat
        cmp     set_date_ch,chMonth
        jne     sd_choosed_not_month2
        or      al,80h
sd_choosed_not_month2:
        out     2,al

        mov     ax,year
        mov     dh,100
        div     dh
        mov     al,ah
        aam
        xlat
        cmp     set_date_ch,chYear
        jne     sd_choosed_not_year1
        or      al,80h
sd_choosed_not_year1:
        out     5,al
        mov     al,ah
        xlat
        cmp     set_date_ch,chYear
        jne     sd_choosed_not_year2
        or      al,80h
sd_choosed_not_year2:
        out     4,al
        ret
ShowSetDate     ENDP

;------ ShowDate -------------------------------------------------------------
ShowDate        PROC
        call    GetTime
        mov     al,day
        aam
        xlat
        out     1,al
        mov     al,ah
        xlat
        out     0,al
        mov     al,month
        aam
        xlat
        out     3,al
        mov     al,ah
        xlat
        out     2,al
        mov     ax,year
        mov     dh,100
        div     dh
        mov     al,ah
        aam
        xlat
        out     5,al
        mov     al,ah
        xlat
        out     4,al
        ret
ShowDate        ENDP

;------ Alarm ----------------------------------------------------------------
Alarm   PROC
        mov     ah,02
        mov     dl,7
        int     21h
        ret
Alarm   ENDP

;------------------------------------------------ ModePressedInSetAlarm ------
ModePressedInSetAlarm   PROC
        mov     alarm_ch,chNone
        cmp     pressed,TRUE
        jne     goto_stw_mode
        mov     current_mode,mdShowTime
        call    RestorePicture
        ret
goto_stw_mode:
        mov     current_mode,mdStopWatch
        mov     pressed,FALSE
        call    RestorePicture
        ret
ModePressedInSetAlarm   ENDP

;----------------------------------------------- ModePressedInStopWatch ------
ModePressedInStopWatch  PROC
        cmp     pressed,TRUE
        jne     goto_timer_mode
        mov     current_mode,mdShowTime
        call    RestorePicture
        ret
goto_timer_mode:
        mov     current_mode,mdTimer
        mov     pressed,FALSE
        call    RestorePicture
        ret
ModePressedInStopWatch  ENDP

;--------------------------------------------------- ModePressedInTimer ------
ModePressedInTimer      PROC
        cmp     pressed,TRUE
        jne     goto_set_time_mode
        mov     current_mode,mdShowTime
        call    RestorePicture
        ret
goto_set_time_mode:
        mov     current_mode,mdSetTime
        mov     pressed,FALSE
        call    RestorePicture
        ret
ModePressedInTimer      ENDP

;------ ModePressedInSetTime -------------------------------------------------
ModePressedInSetTime    PROC
        mov     set_time_ch,chNone

        cmp     pressed,TRUE
        jne     goto_set_date_mode
        mov     current_mode,mdShowTime
        call    RestorePicture
        ret
goto_set_date_mode:
        mov     pressed,FALSE
        mov     current_mode,mdSetDate
        call    RestorePicture
        ret
ModePressedInSetTime    ENDP

;------------------------------------------------- ModePressedInSetDate ------
ModePressedInSetDate    PROC
	mov	set_date_ch,chNone
        mov     current_mode,mdShowTime
        call    RestorePicture
        ret
ModePressedInSetDate    ENDP

;---------------------------------------------------------- ModePressed ------
ModePressed     PROC
        cmp     current_mode,mdShowTime
        jne     set_alarm_mode
        mov     current_mode,mdSetAlarm
        mov     pressed,FALSE
        call    RestorePicture
        ret
set_alarm_mode:
        cmp     current_mode,mdSetAlarm   ; define, what is current mode
        jne     stop_watch_mode
        call    ModePressedInSetAlarm
        ret
stop_watch_mode:
        cmp     current_mode,mdStopWatch
        jne     timer_mode
        call    ModePressedInStopWatch
        ret
timer_mode:
        cmp     current_mode,mdTimer
        jne     set_time_mode
        call    ModePressedInTimer
        ret
set_time_mode:
        cmp     current_mode,mdSetTime
        jne     set_date_mode
        call    ModePressedInSetTime
        ret
set_date_mode:
        call    ModePressedInSetDate
        ret
ModePressed     ENDP



;---------------------------------------------- SelectPressedInSetAlarm ------
SelectPressedInSetAlarm	PROC
        cmp     alarm_ch,chMin
        jne     al_increment
        mov     alarm_ch,-1
al_increment:
        inc     alarm_ch
        call    RestorePicture
	ret
SelectPressedInSetAlarm	ENDP

;--------------------------------------------- SelectPressedInStopWatch ------
SelectPressedInStopWatch PROC
        cmp     st_on,TRUE
        je      stop_watch_is_on
        cmp     st_real_on,TRUE
        je      st_on_but_hidden
        mov     st_begin,0
        mov     st_end,0
        mov     st_tenth,0
        call    RestorePicture
        ret
st_on_but_hidden:
        ; show display stopwatch
        mov     st_on,TRUE
        call    RestorePicture
        ret
stop_watch_is_on:
        ; stop display stopwatch and don't stop real stopwatch
        mov     st_on,FALSE
	ret
SelectPressedInStopWatch ENDP

;------------------------------------------------- SelectPressedInTimer ------
SelectPressedInTimer   PROC
        mov     timer_on,FALSE
        cmp     timer_was_on,TRUE
        jne     timer_was_not_started
        mov     timer_was_on,FALSE
        mov     timer_size,0
        mov     timer_begin,0
        mov     timer_end,0
        ret
timer_was_not_started:
        mov     ax,timer_size
        call    UnpackTime
        inc     al
        cmp     al,61
        jne     not_zero_timer
        xor     al,al
not_zero_timer:
        xor     dl,dl
        call    PackTime
        mov     timer_size,ax
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btSelect
        jnz     timer_was_not_started
        ret
SelectPressedInTimer   ENDP

;----------------------------------------------- SelectPressedInSetTime ------
SelectPressedInSetTime   PROC
        cmp     set_time_ch,chSec
        jne     set_time_ch_increment
        mov     set_time_ch,-1
set_time_ch_increment:
        inc     set_time_ch
        call    RestorePicture
        ret
SelectPressedInSetTime   ENDP

;----------------------------------------------- SelectPressedInSetDate ------
SelectPressedInSetDate   PROC
        cmp     set_date_ch,chYear
        jne     set_date_ch_increment
        mov     set_date_ch,-1
set_date_ch_increment:
        inc     set_date_ch
        call    RestorePicture
        ret
SelectPressedInSetDate   ENDP

;-------------------------------------------------------- SelectPressed ------
SelectPressed   PROC
        mov     pressed,TRUE

        cmp     current_mode,mdSetAlarm
        je      set_alarm_mode_
        cmp     current_mode,mdStopWatch
        je      stop_watch_mode_
        cmp     current_mode,mdTimer
        je      timer_mode_
        cmp     current_mode,mdSetTime
        je      set_time_mode_
        cmp     current_mode,mdSetDate
        je      set_date_mode_

show_time_mode_:				; default
        mov     current_mode,mdShowDate
        call    RestorePicture
        call    ReleaseKey
        mov     current_mode,mdShowTime
        call    RestorePicture
        ret

set_alarm_mode_:
        call    SelectPressedInSetAlarm
        ret

stop_watch_mode_:
	call	SelectPressedInStopWatch
        ret

timer_mode_:
        call    SelectPressedInTimer
        ret

set_time_mode_:
        call    SelectPressedInSetTime
        ret

set_date_mode_:
        call    SelectPressedInSetDate
        ret

SelectPressed   ENDP


;----------------------------------------------- StartPressedInSetAlarm ------
StartPressedInSetAlarm  PROC
        cmp     alarm_ch,chNone
        jne     change_alarm_time
        jmp     end_spisa_proc

change_alarm_time:
        cmp     alarm_ch,chHour
        jne     change_alarm_min

change_alarm_hour:
        inc     alarm_hour
        cmp     alarm_hour,24
        jne     alarm_hour_not_zero
        mov     alarm_hour,0

alarm_hour_not_zero:
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btStart
        jz      end_spisa_proc
        jmp     change_alarm_hour

change_alarm_min:
        inc     alarm_min
        cmp     alarm_min,60
        jne     alarm_min_not_zero
        mov     alarm_min,0
alarm_min_not_zero:
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btStart
        jz      end_spisa_proc
        jmp     change_alarm_min

end_spisa_proc:
        call    ReleaseKey
        ret
StartPressedInSetAlarm  ENDP

;---------------------------------------------- StartPressedInStopWatch ------
StartPressedInStopWatch PROC
        cmp     st_on,TRUE
        jne     check_st_real_on
        mov     st_on,FALSE
        mov     st_real_on,FALSE
        call    GetPackedTime
        mov     st_end,ax
        ret

check_st_real_on:
        cmp     st_real_on,TRUE
        jne     start_both_st
        mov     st_real_on,FALSE
        ret

start_both_st:
        mov     st_on,TRUE
        mov     st_real_on,TRUE
        cmp     st_begin,0
        jne     st_begin_again
        call    GetPackedTime           ; set begin stop-watch
        mov     st_begin,ax
        call    GetTime                 ; set tick stop-watch
        mov     al,tick
        mov     st_tick,al
        ret

st_begin_again:
        call    GetPackedTime   ; a-on-b-off-c -> b-on-c
        sub     ax,st_end
        call    AdjustTime
        add     st_begin,ax
        add     st_end,ax
        ret
StartPressedInStopWatch ENDP

;-------------------------------------------------- StartPressedInTimer ------
StartPressedInTimer     PROC
        cmp     timer_size,0
        jne     timer_set_not_zero
        call    Alarm
        call    Alarm
        call    Alarm
        ret
timer_set_not_zero:
        cmp     timer_on,TRUE
        jne     start_timer
        mov     timer_on,FALSE
        call    GetPackedTime
        mov     timer_end,ax
        ret

start_timer:
        mov     timer_was_on,TRUE
        mov     timer_on,TRUE
        call    GetPackedTime
        sub     ax,timer_end
        call    AdjustTime
        add     timer_begin,ax
        add     timer_end,ax
        call    RestorePicture
        ret
StartPressedInTimer     ENDP

;------------------------------------------------ StartPressedInSetTime ------
StartPressedInSetTime    PROC
        cmp     set_time_ch,chNone
        jne     change_time
        jmp     end_this_proc

change_time:
        cmp     set_time_ch,chMin
        je      change_min
        cmp     set_time_ch,chSec
        je      change_sec

change_hour:
        call    GetTime
        inc     hour
        cmp     hour,24
        jne     hour_not_zero
        mov     hour,0

hour_not_zero:
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btStart
        jz      end_this_proc
        jmp     change_hour

change_min:
        call    GetTime
        inc     min
        cmp     min,60
        jne     min_not_zero
        mov     min,0
min_not_zero:
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btStart
        jz      end_this_proc
        jmp     change_min

change_sec:
        mov     sec,0
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btStart
        jnz     change_sec

end_this_proc:
        call    ReleaseKey
        ret
StartPressedInSetTime    ENDP

;------------------------------------------------ StartPressedInSetDate ------
StartPressedInSetDate    PROC
        cmp     set_date_ch,chNone
        jne     change_date
        jmp     end_this_proc_

change_date:
        cmp     set_date_ch,chYear
        je      change_year
        cmp     set_date_ch,chMonth
        je      change_month

change_day:
        call    GetTime
        mov     al,day
        cmp     al,days_in_month
        jne     day_not_zero
        mov     day,0
day_not_zero:
        inc     day
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btStart
        jz      end_this_proc_
        jmp     change_day

change_month:
        call    GetTime
        inc     month
        cmp     month,13
        jne     month_not_zero
        mov     month,1
month_not_zero:
        call    SetDaysInMonth
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btStart
        jz      end_this_proc_
        jmp     change_month

change_year:
        call    GetTime
        inc     year
        cmp     year,2080
        jbe     year_not_zero
        mov     year,1980
year_not_zero:
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btStart
        jz      end_this_proc_
        jmp     change_year

end_this_proc_:
        call    ReleaseKey
        ret
StartPressedInSetDate    ENDP

;--------------------------------------------------------- StartPressed ------
StartPressed    PROC
        mov     pressed,TRUE

        cmp     current_mode,mdSetAlarm
        jne     not_set_alarm_mode
        call    StartPressedInSetAlarm
        ret

not_set_alarm_mode:
        cmp     current_mode,mdStopWatch
        jne     not_stop_watch_mode
        call    StartPressedInStopWatch
        ret

not_stop_watch_mode:
        cmp     current_mode,mdTimer
        jne     not_timer_mode
        call    StartPressedInTimer
        ret

not_timer_mode:
        cmp     current_mode,mdSetTime
        jne     not_set_time_mode
        call    StartPressedInSetTime
        ret

not_set_time_mode:
        cmp     current_mode,mdSetDate
        jne     not_set_date_mode
        call    StartPressedInSetDate
        ret

not_set_date_mode:
        not     alarm_on
        call    ReleaseKey
        ret

StartPressed    ENDP


;------------------------------------------------ BackPressedInSetAlarm ------
BackPressedInSetAlarm  PROC
        cmp     alarm_ch,chNone
        jne     change_alarm_time_
        jmp     end_bpisa_proc

change_alarm_time_:
        cmp     alarm_ch,chHour
        jne     change_alarm_min_

change_alarm_hour_:
        dec     alarm_hour
        cmp     alarm_hour,-1
        jne     alarm_hour_not_zero_
        mov     alarm_hour,23

alarm_hour_not_zero_:
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btBack
        jz      end_bpisa_proc
        jmp     change_alarm_hour_

change_alarm_min_:
        dec     alarm_min
        cmp     alarm_min,-1
        jne     alarm_min_not_zero_
        mov     alarm_min,59
alarm_min_not_zero_:
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btBack
        jz      end_bpisa_proc
        jmp     change_alarm_min_

end_bpisa_proc:
        call    ReleaseKey
        ret
BackPressedInSetAlarm  ENDP

;-------------------------------------------------- BackPressedInTimer ------
BackPressedInTimer     PROC
        mov     timer_on,FALSE
        cmp     timer_was_on,TRUE
        jne     timer_was_not_started_
        mov     timer_was_on,FALSE
        mov     timer_size,0
        mov     timer_begin,0
        mov     timer_end,0
        ret
timer_was_not_started_:
        mov     ax,timer_size
        call    UnpackTime
        dec     al
        cmp     al,-1
        jne     not_zero_timer_
        mov     al,60
not_zero_timer_:
        xor     dl,dl
        call    PackTime
        mov     timer_size,ax
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btBack
        jnz     timer_was_not_started_
        ret
BackPressedInTimer     ENDP

;------------------------------------------------- BackPressedInSetTime ------
BackPressedInSetTime    PROC
        cmp     set_time_ch,chNone
        jne     change_time_
        ret

change_time_:
        cmp     set_time_ch,chMin
        je      change_min_
        cmp     set_time_ch,chSec
        je      change_sec_

change_hour_:
        call    GetTime
        dec     hour
        cmp     hour,-1
        jne     hour_not_zero_
        mov     hour,23
hour_not_zero_:
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btBack
        jnz     change_hour_
        ret

change_min_:
        call    GetTime
        dec     min
        cmp     min,-1
        jne     min_not_zero_
        mov     min,59
min_not_zero_:
        call    RestorePicture
        call    Delay
        call    GetButtons
        test    al,btBack
        jnz     change_min_
        ret

change_sec_:
	call	ReleaseKey
	ret

BackPressedInSetTime    ENDP

;------------------------------------------------- BackPressedInSetDate ------
BackPressedInSetDate    PROC
        cmp     set_date_ch,chNone
        jne     change_date_
        ret

change_date_:
        cmp     set_date_ch,chYear
        je      change_year_
        cmp     set_date_ch,chMonth
        je      change_month_

change_day_:
        call    GetTime
        dec     day
        cmp     day,0
        jne     day_not_zero_
        mov     al,days_in_month
        mov     day,al
day_not_zero_:
        call    CheckRepeat
        test    al,btBack
        jnz     change_day_
        ret

change_month_:
        call    GetTime
        dec     month
        cmp     month,0
        jne     month_not_zero_
        mov     month,12
month_not_zero_:
        call    SetDaysInMonth
        call    CheckRepeat
        test    al,btBack
        jnz     change_month_
        ret

change_year_:
        call    GetTime
        dec     year
        cmp     year,word ptr 1979
        jg      year_not_zero_
        mov     year,word ptr 2080
year_not_zero_:
        call    CheckRepeat
        test    al,btBack
        jnz     change_year_
        ret

BackPressedInSetDate    ENDP

;---------------------------------------------------------- BackPressed ------
BackPressed    PROC
        mov     pressed,TRUE

        cmp     current_mode,mdSetAlarm
        jne     not_set_alarm_mode_
        call    BackPressedInSetAlarm
        ret

not_set_alarm_mode_:
        cmp     current_mode,mdStopWatch
        jne     not_stop_watch_mode_
        ret

not_stop_watch_mode_:
        cmp     current_mode,mdTimer
        jne     not_timer_mode_
        call    BackPressedInTimer
        ret

not_timer_mode_:
        cmp     current_mode,mdSetTime
        jne     not_set_time_mode_
        call    BackPressedInSetTime
        ret

not_set_time_mode_:
        cmp     current_mode,mdSetDate
        jne     not_set_date_mode_
        call    BackPressedInSetDate
        ret

not_set_date_mode_:
        not     alarm_on
        call    ReleaseKey
        ret

BackPressed    ENDP


;------ ResetPressed ---------------------------------------------------------
ResetPressed    PROC
        call    DefineVariables
        call    Alarm
        ret
ResetPressed    ENDP

;------ ReleaseKey -----------------------------------------------------------
ReleaseKey      PROC
key_not_released_yet:
        call    RestorePicture
        call    Delay
        call    GetButtons
        cmp     al,btNone
        jne     key_not_released_yet
        ret
ReleaseKey      ENDP

;---------------------------------------------------------- CheckRepeat ------
CheckRepeat     PROC
        call    RestorePicture
        call    Delay
        call    GetButtons
        ret
CheckRepeat     ENDP

;------ DefineVariables ------------------------------------------------------
DefineVariables PROC

        xor     ah,ah
        int     1Ah
        mov     old_ticks_l,dx
        mov     old_ticks_h,cx

        mov     tick,0
        mov     sec,0
        mov     min,0
        mov     hour,0
        mov     day,1
        mov     month,1
        mov     year,1980
        mov     days_in_month,31

        mov     dim_table+1,31
        mov     dim_table+2,28
        mov     dim_table+3,31
        mov     dim_table+4,30
        mov     dim_table+5,31
        mov     dim_table+6,30
        mov     dim_table+7,31
        mov     dim_table+8,31
        mov     dim_table+9,30
        mov     dim_table+10,31
        mov     dim_table+11,30
        mov     dim_table+12,31

        mov     bx,offset Map   ; fill digits table

        mov     Map[0], 3FH
        mov     Map[1], 0CH     ; why Map ? map - it is a paper with
        mov     Map[2], 76H     ; a painting on it... and this ?
        mov     Map[3], 05EH
        mov     Map[4], 4DH
        mov     Map[5], 5BH
        mov     Map[6], 7BH
        mov     Map[7], 0EH
        mov     Map[8], 7FH
        mov     Map[9], 5FH

        mov     current_mode,mdShowTime ; define other variables
        mov     pressed,FALSE
        mov     alarm_on,FALSE
        mov     alarm_ch,0
        mov     alarm_hour,0
        mov     alarm_min,0
        mov     alarm_sec,0
        mov     st_on,FALSE
        mov     st_begin,0
        mov     st_end,0
        mov     st_min,0
        mov     st_sec,0
        mov     st_tick,0
        mov     st_tenth,0
        mov     st_real_on,FALSE
        mov     timer_on,FALSE
        mov     timer_was_on,FALSE
        mov     timer_size,0
        mov     timer_begin,0
        mov     timer_end,0
        mov     timer_min,0
        mov     timer_sec,0
        mov     set_time_ch,chNone
        mov     set_date_ch,chNone
        ret
DefineVariables ENDP

;------ RestorePicture -------------------------------------------------------
RestorePicture  PROC

        ; show current mode
        mov     al,current_mode
        xlat
        out     7,al

        ;show alarm on/off and current_mode at binary indicator
        cmp     alarm_on,TRUE
        jne     not_show_alarm_on
        mov     al,1
        mov     cl,current_mode
        inc     cl
        shl     al,cl
        or      al,1
        out     ptAlarm,al
        jmp     alarm_showed

not_show_alarm_on:
        ;show current_mode at binary indicator
        mov     al,1
        mov     cl,current_mode
        inc     cl
        shl     al,cl
        out     ptAlarm,al       

alarm_showed:

        ;check alarm
        cmp     alarm_on,TRUE
        jne     do_not_wake_user
        call    GetTime
        mov     al,hour
        cmp     al,alarm_hour
        jne     do_not_wake_user
        mov     al,min
        cmp     al,alarm_min
        jne     do_not_wake_user
        mov     al,sec
        cmp     al,alarm_sec
        jne     do_not_wake_user
        call    Alarm
do_not_wake_user:

        ;increment timer
        cmp     timer_on,TRUE
        jne     do_not_increment_timer
        call    GetPackedTime
        mov     timer_end,ax
do_not_increment_timer:
        mov     ax,timer_size
        add     ax,timer_begin
        sub     ax,timer_end
        call    AdjustTime
        call    UnpackTime
        mov     timer_min,al
        mov     timer_sec,ah
        cmp     timer_size,0
        je      timer_must_work
        cmp     al,0
        jne     timer_must_work
        cmp     ah,0
        jne     timer_must_work
        mov     timer_on,FALSE
        mov     timer_begin,0
        mov     timer_end,0
        mov     timer_size,0
        call    Alarm
        call    Alarm
        call    Alarm
timer_must_work:


        ;choose mode
        cmp     current_mode,mdSetAlarm
        je      show_set_alarm
        cmp     current_mode,mdStopWatch
        je      show_stop_watch
        cmp     current_mode,mdTimer
        je      show_timer
        cmp     current_mode,mdSetTime
        je      show_set_time
        cmp     current_mode,mdSetDate
        je      show_set_date
        cmp     current_mode,mdShowDate
        je      show_show_date
        ; default
show_time:
        call    ShowTime
        ret
show_set_alarm:
        call    ShowAlarmTime
        ret
show_stop_watch:
        call    ShowStopWatch
        ret
show_timer:
        call    ShowTimer
        ret
show_set_time:
        call    ShowSetTime
        ret
show_set_date:
        call    ShowSetDate
        ret
show_show_date:
        call    ShowDate
        ret

RestorePicture  ENDP

;------ GetButtons -----------------------------------------------------------
GetButtons      PROC
        in      al,ptButtons
        ret
GetButtons      ENDP

;------ ProcessButtons -------------------------------------------------------
ProcessButtons  PROC
        cmp     al,btNone       ; buttons is free ?
        jne     check_mode      ; no...it most be mode button pressed...
        ret                     ; yes...check it again next time...

check_mode:                     ; no...defining, what button is pressed...
        test    al,btMode
        jz      check_select    ; not mode button...well, maybe start ?...
        call    ModePressed     ; come on, mode pressed, do something...
        call    ReleaseKey      ; off the button ! i said : OFF THE BUTTON !!!
        ret                     ; ok, that's better

check_select:
        test    al,btSelect     ; checking start...
        jz      check_start     ; not start... at last, check select button
        call    SelectPressed   ; huh, now we can to break clock. joke.
        call    ReleaseKey      ; please, user, release the button, please...
        ret                     ; well, it's done, what's next ?

check_start:
        test    al,btStart      ; checking start...
        jz      check_back      ; not start..., check back button
        call    StartPressed    ; as you already guess, start button pressed
        ret

check_back:
        test    al,btBack       ; checking start...
        jz      check_reset     ; not back ?  then it must be reset button
        call    BackPressed     ; as you maybe guess, back button pressed
        ret

check_reset:                    ; because there are only 3 buttons,
                                ; so don't testing which is pressed
        call    ResetPressed    ; reset computer...
        call    ReleaseKey      ; press any key to start
        ret                     ;
ProcessButtons  ENDP



;------ main -----------------------------------------------------------------
begin:
        mov ax,data             ; initialisation - written by unknown
        mov ds,ax               ; programmer...
        mov ax,stack            
        mov ss,ax               
        mov sp,offset StkTop    

        call SetIntHandlers

        call    DefineVariables ; we have a lot of variables, so they all
                                ; must be filled with something...
clock_must_work:
        call    RestorePicture  ; paint something on display...
        call    GetButtons      ; look at this buttons -
                                ; maybe some of them are pressed ?
        call    ProcessButtons  ; let's look what we have to do...
        jmp     clock_must_work ; have you listen about white bull ?

SetIntHandlers proc near
          push es
          mov  ax,0
          mov  es,ax
          mov  es:[4*1Ah],Offset Handler1A
          mov  es:[4*1Ah+2],cs
          mov  es:[4*21h],Offset Handler21
          mov  es:[4*21h+2],cs
          pop  es
          mov  Word Ptr TickCounter,0
          mov  Word Ptr TickCounter+2,0
          mov  TickSubCounter,OneSecondDelay
          ret
SetIntHandlers endp

Handler21 proc
          push cx
          mov cx,0
H21Wait:  loop H21Wait
          pop cx
          iret
Handler21 endp

Handler1A proc
          push ds
          mov ax,Data
          mov ds,ax
          dec TickSubCounter
          jnz NoChangeCounter
          mov TickSubCounter,OneSecondDelay
          add Word Ptr TickCounter,1
          adc Word Ptr TickCounter,0
NoChangeCounter:
          mov dx,Word Ptr TickCounter
          mov cx,Word Ptr TickCounter+2
          pop ds
          iret
Handler1A endp

       org 0FF0H                
       assume cs:nothing
start: jmp far ptr begin                

code    ENDS                    ; there is no more code segment...

        END     start           
                                
