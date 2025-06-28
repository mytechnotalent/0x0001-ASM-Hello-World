;===============================================================================
; File:     main.asm
; Purpose:  CRT-free 64-bit EXE that displays a message box via Ui.asm helper.
;===============================================================================

extrn   UI_ShowMessage :PROC

.data
    msgText    db "Hello World", 0
    msgTitle   db "Lean Loader", 0

.code
WinMainCRTStartup PROC


    lea     rcx, msgText         ; RCX = &"Hello World"
    lea     rdx, msgTitle        ; RDX = &"Lean Loader"
    call    UI_ShowMessage       ; loads DLL, shows box, unloads DLL

    ret
WinMainCRTStartup ENDP

END                             ; end of main.asm
