;==============================================================================
; File:     Ui.asm
;
; Purpose:  UI Windows wrapper functionality written in Assembler.
;
; Platform: Windows x64
; Author:   Kevin Thomas
; Date:     2025-06-28
; Updated:  2025-06-28
;==============================================================================

extrn   LoadLibraryA   :PROC      ; kernel32.dll
extrn   GetProcAddress :PROC      ; kernel32.dll
extrn   FreeLibrary    :PROC      ; kernel32.dll

public  UIMessageBox

.data
        dllName          db "UiDll.dll",    0
        procUIMessageBox db "UIMessageBox", 0

.code

;------------------------------------------------------------------------------
; UIMessageBox PROC implementation wrapper for MessageBoxA
;
; int MessageBoxA(
;   [in, optional] HWND   hWnd,
;   [in, optional] LPCSTR lpText,
;   [in, optional] LPCSTR lpCaption,
;   [in]           UINT   uType
; );
;
; Parameters:
;   RCX = LPCSTR lpText
;   RDX = LPCSTR lpCaption
;
; Return:
;   IDOK = 1 - The OK button was selected.
;------------------------------------------------------------------------------
UIMessageBox PROC lpText:QWORD, lpCaption:QWORD
_UIMessageBox_Prologue:
  MOV    RSI, RCX                 ; RSI = preserve lpText
  MOV    RDI, RDX                 ; RDI = preserve lpCaption
  SUB    RSP, 28h                 ; reserve 32-byte shadow space, +8 16-b align 
_UIMessageBox_LoadDLL:
  LEA    RCX, dllName             ; RCX = address of UiDll.dll
  CALL   LoadLibraryA             ; call Win32 API
  MOV    RBX, RAX                 ; save module handle
_UIMessageBox_ResolveExport:
  MOV    RCX, RBX                 ; RCX = module handle
  LEA    RDX, procUIMessageBox    ; RDX = address of UIMessageBox
  CALL   GetProcAddress           ; call Win32 API
_UIMessageBox_InvokeExport:
  MOV   RCX, RSI			      ; RCX = lpText
  MOV   RDX, RDI			      ; RDX = lpCaption
  CALL  RAX                       ; call the resolved UIMessageBox function
_UIMessageBox_UnloadDLL:
  MOV   RCX, RBX                  ; RCX = module handle
  CALL  FreeLibrary               ; call Win32 API
_UIMessageBox_Epilogue:
  ADD   RSP, 28h                  ; restore 32-byte shadow space, +8 16-b align
  RET                             ; return to caller
UIMessageBox ENDP

END                               ; end of Ui.asm
