<img src="https://github.com/mytechnotalent/0x0000-ASM-Hello-World/blob/master/0x0001-ASM-Hello-World.png?raw=true">

## FREE Reverse Engineering Self-Study Course [HERE](https://github.com/mytechnotalent/Reverse-Engineering-Tutorial)

<br>

# 0x0001-ASM-Hello-World
0x0001-ASM-Hello-World Windows App written in Assembler.

<br>

## Comprehensive Deep Dive Supplemental Material
### Windows Internals Crash Course by Duncan Ogilvie
#### [SLIDES](https://mrexodia.github.io/files/wicc-2023-slides.pdf)
#### [VIDEO](https://youtu.be/I_nJltUokE0?si=Q1yOfZuIF5jOa_2U)

<br>

## Reverse Engineering

### 🧠 Windows Process Loader: Beginner-Friendly Breakdown

Let’s walk through what actually happens when a Windows process is created.

#### 1. 🧱 Process Creation by the Kernel

When a new process is spun up, the kernel:

- Maps the target *executable image* into memory  
- Loads *ntdll.dll*  
- Creates a *new thread* to eventually run the main function  

> At this point, the process has no initialized PEB, TEB, or imports — it’s just a shell.

#### 2. 🚀 Starting the Thread: `ntdll!LdrInitializeThunk()`

This function is always the initial thread entrypoint. It immediately calls:

- `ntdll!LdrpInitialize()` – this handles setup.

#### 3. 🏗️ Initialization via `ntdll!LdrpInitialize()`

This routine does two things:

- Sets up the *process* if it's not already initialized  
- Sets up the *current thread*

It checks the global flag:

- `ntdll!LdrpProcessInitialized`  
  - If `FALSE`, it calls `ntdll!LdrpInitializeProcess()`

#### 4. 🔧 What `LdrpInitializeProcess()` Does

- Initializes the *PEB*  
- Resolves the process’s *import table*  
- Loads any *required DLLs*

> This is where the environment gets fully fleshed out.

#### 5. 🏁 Launching the Process: `ZwContinue()` and Beyond

When initialization is done:

1. `LdrInitializeThunk()` calls `ZwContinue()`  
2. The kernel sets the instruction pointer to `ntdll!RtlUserThreadStart()`  
3. Finally, the process’s *entrypoint function* is called

> Now the executable starts for real.

<br>

## Code
```
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
```

```
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
```

```
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
```

<br>

## License
[MIT](https://github.com/mytechnotalent/0x0001-ASM-Hello-World/blob/master/LICENSE.txt)
