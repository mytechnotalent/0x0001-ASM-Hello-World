;==============================================================================
; File:     Util.asm
;
; Purpose:  Utility Windows functionality written in Assembler.
;
; Platform: Windows x64
; Author:   Kevin Thomas
; Date:     2025-06-29
; Updated:  2025-06-29
;==============================================================================

extrn   ExitProcess :PROC          ; kernel32.dll

public  UtilExitProcess

.code

;------------------------------------------------------------------------------
; UtilExitProcess PROC implementation wrapper for ExitProcess
;
; void ExitProcess(
;   [in] UINT uExitCode
; );
;
; Parameters:
;   RCX = UINT uExitCode
;
; Return:
;   None
;------------------------------------------------------------------------------
UtilExitProcess PROC uExitCode:QWORD
_UtilExitProcess_Prologue:
  MOV    RSI, RCX                 ; RSI = preserve lpText
  MOV    RDI, RDX                 ; RDI = preserve lpCaption
  SUB    RSP, 28h                 ; reserve 32-byte shadow space, +8 16-b align 
_UtilExitProcess_CallFunction:
  MOV    RCX, 0                   ; RCX = uExitCode 0
  CALL   ExitProcess              ; call Win32 API
_UtilExitProcess_Epilogue:
  ADD   RSP, 28h                  ; restore 32-byte shadow space, +8 16-b align
  RET                             ; return to caller
UtilExitProcess ENDP

END                               ; end of Util.asm
