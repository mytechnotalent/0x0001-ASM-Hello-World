;==============================================================================
; File:     main.asm
;
; Purpose:  0x0001-ASM-Hello-World Windows App written in Assembler.
;
; Platform: Windows x64
; Author:   Kevin Thomas
; Date:     2025-06-28
; Updated:  2025-06-28
;==============================================================================

extrn  UIMessageBox    :PROC
extrn  UtilExitProcess :PROC

.data
       msgText  db "Hello World", 0
       msgTitle db "Lean Loader", 0

.code

;------------------------------------------------------------------------------
; WinMainCRTStartup PROC main entry point
;------------------------------------------------------------------------------
WinMainCRTStartup PROC
  LEA    RDX, msgTitle            ; RDX = &"Lean Loader"
  LEA    RCX, msgText             ; RCX = &"Hello World"
  CALL   UIMessageBox             ; call the UIMessageBox subroutine
  CALL   UtilExitProcess          ; call the UtilExitProcess subroutine
WinMainCRTStartup ENDP

END                               ; end of main.asm
