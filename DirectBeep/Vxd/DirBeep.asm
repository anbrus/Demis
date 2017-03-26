    page    60, 132

;******************************************************************************
    title   DirectBeep

    .386p

    .XLIST
    INCLUDE VMM.Inc
    INCLUDE Debug.Inc
    .LIST

DirectBeep_Major_Ver      equ     01h
DirectBeep_Minor_Ver      equ     00h
DirectBeep_Device_ID      equ     Undefined_Device_ID

;==============================================================================
;           V I R T U A L   D E V I C E   D E C L A R A T I O N
;==============================================================================

Declare_Virtual_Device  DIRBEEP, DirectBeep_Major_Ver, DirectBeep_Minor_Ver,\
                        Control_Proc, DirectBeep_Device_ID,Undefined_Init_Order,,

;==============================================================================
;                  N O N - P A G E A B L E   D A T A
;==============================================================================

VxD_LOCKED_DATA_SEG

VxD_LOCKED_DATA_ENDS

VxD_LOCKED_CODE_SEG

;==============================================================================
;                      N O N P A G E A B L E   C O D E
;==============================================================================

BeginProc Control_Proc

    ; Dynamic load messages
    Control_Dispatch Sys_Dynamic_Device_Init, DynaDevice_Init
    Control_Dispatch Sys_Dynamic_Device_Exit, DynaDevice_Exit

    ; DeviceIOControl messages - send 'em to our C module...
    Control_Dispatch W32_DEVICEIOCONTROL,     CVXD_W32_DeviceIOControl, sCall, <ecx, ebx, edx, esi>

    clc
    ret

EndProc Control_Proc


BeginProc DynaDevice_Init

	clc
	ret

EndProc DynaDevice_Init


BeginProc DynaDevice_Exit

	clc
	ret

EndProc DynaDevice_Exit


VxD_LOCKED_CODE_ENDS

END

