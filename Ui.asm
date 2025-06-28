;==============================================================================
; File:     Ui.asm
; Purpose:  CRT-free helper DLL loader and invoker for UIMessageBox
;
; Exports:
;   UI_ShowMessage(lpText, lpCaption) : int
;     - Loads UiDll.dll
;     - Resolves UIMessageBox
;     - Calls UIMessageBox(lpText, lpCaption)
;     - Unloads UiDll.dll
;     - Returns IDOK (1) when the user clicks OK
;
; Calling Convention: Microsoft x64
;   RCX = lpText    ; pointer to null-terminated text string
;   RDX = lpCaption ; pointer to null-terminated caption string
;   Caller must reserve 32-byte shadow space on the stack
;==============================================================================

extrn   LoadLibraryA    :PROC    ; kernel32.dll
extrn   GetProcAddress  :PROC    ; kernel32.dll
extrn   FreeLibrary     :PROC    ; kernel32.dll

includelib kernel32.lib          ; import stubs for loader APIs

public  UI_ShowMessage

.data
dllName   db "UiDll.dll",     0
procName  db "UIMessageBox",  0

.code

;------------------------------------------------------------------------------
; Function: UI_ShowMessage
; Prototype:
;   int UI_ShowMessage(
;       LPCSTR lpText,      ; RCX
;       LPCSTR lpCaption    ; RDX
;   );
;
; Behavior:
;   1) LoadLibraryA("UiDll.dll")
;   2) GetProcAddress(hMod, "UIMessageBox")
;   3) Call UIMessageBox(lpText, lpCaption)
;   4) FreeLibrary(hMod)
;   5) Return value from MessageBoxA (IDOK=1)
;------------------------------------------------------------------------------
UI_ShowMessage PROC lpText:QWORD, lpCaption:QWORD
    ; save user arguments
    mov     rsi, rcx            ; rsi = lpText
    mov     rdi, rdx            ; rdi = lpCaption

    sub     rsp,28h             ; reserve 32-byte shadow space

    ; load the DLL
    lea     rcx, dllName        ; RCX = address of "UiDll.dll"
    call    LoadLibraryA        ; RAX = module handle
    mov     rbx, rax            ; save module handle

    ; resolve the export
    mov     rcx, rbx            ; RCX = module handle
    lea     rdx, procName       ; RDX = address of "UIMessageBox"
    call    GetProcAddress      ; RAX = address of UIMessageBox

    ; invoke the export
    mov     rcx, rsi            ; RCX = lpText
    mov     rdx, rdi            ; RDX = lpCaption
    call    rax                 ; call UIMessageBox

    ; unload the DLL
    mov     rcx, rbx            ; RCX = module handle
    call    FreeLibrary

    add     rsp,28h             ; restore shadow space
    ret                         ; RAX holds IDOK
UI_ShowMessage ENDP

END                             ; end of Ui.asm
