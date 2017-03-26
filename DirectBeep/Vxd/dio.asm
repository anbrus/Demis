;****************************************************************************
; dio.asm - 1998 James Finnegan - Microsoft Systems Journal                 *
;                                                                           *
; C Wrapper for async completion notification...                            *
;                                                                           *
;****************************************************************************

include local.inc

StartCDecl VWIN32_DIOCCompletionRoutine@4

        mov ebx, [esp+4] ; Get hEvent
        VxDCall VWIN32_DIOCCompletionRoutine
        ret 4

EndCDecl VWIN32_DIOCCompletionRoutine@4

END
