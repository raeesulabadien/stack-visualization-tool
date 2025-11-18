; NestedCalls.asm - Nested Function Calls Demo
; Author: Stack Visualization Tool Project
; Description: Demonstrates nested function calls with stack visualization
; Shows how stack frames are created and destroyed in sequence

INCLUDE Irvine32.inc

; Import from StackSim
EXTERN SimStack:DWORD
EXTERN SimESP:DWORD
EXTERN SimEBP:DWORD
EXTERN PushSim:PROC
EXTERN PopSim:PROC
EXTERN CallSim:PROC
EXTERN RetSim:PROC
EXTERN NewFrameSim:PROC
EXTERN EndFrameSim:PROC
EXTERN InitLogger:PROC
EXTERN CloseLogger:PROC
EXTERN DisplayStack:PROC

.data
    msgTitle BYTE "=== Nested Function Calls Demo ===", 0Dh, 0Ah, 0
    msgExplanation BYTE 0Dh, 0Ah
                   BYTE "This demo shows nested function calls:", 0Dh, 0Ah
                   BYTE "- FunctionA calls FunctionB", 0Dh, 0Ah
                   BYTE "- FunctionB calls FunctionC", 0Dh, 0Ah
                   BYTE "- Each creates its own stack frame", 0Dh, 0Ah
                   BYTE "- Watch frames build up and unwind!", 0Dh, 0Ah, 0Dh, 0Ah, 0
    
    msgCallingA BYTE "Main calling FunctionA...", 0Dh, 0Ah, 0
    msgInA BYTE "In FunctionA, calling FunctionB...", 0Dh, 0Ah, 0
    msgInB BYTE "In FunctionB, calling FunctionC...", 0Dh, 0Ah, 0
    msgInC BYTE "In FunctionC (deepest level)", 0Dh, 0Ah, 0
    msgReturning BYTE "Returning through call chain...", 0Dh, 0Ah, 0
    msgFinalResult BYTE "Final result: ", 0

.code
main PROC
    ; Initialize logger
    call InitLogger
    
    ; Display title and explanation
    mov edx, OFFSET msgTitle
    call WriteString
    mov edx, OFFSET msgExplanation
    call WriteString
    
    ; Call FunctionA with parameter
    mov edx, OFFSET msgCallingA
    call WriteString
    push 100  ; Parameter for FunctionA
    call FunctionA
    
    ; Display result
    mov edx, OFFSET msgFinalResult
    call WriteString
    call WriteDec
    call Crlf
    call Crlf
    
    ; Display final stack state
    call DisplayStack
    
    ; Close logger
    call CloseLogger
    
    exit
main ENDP

;------------------------------------------------------------
; FunctionA - First level function
; Receives: Value on stack [ebp+8]
; Returns: EAX = modified value
;------------------------------------------------------------
FunctionA PROC
    push ebp
    mov ebp, esp
    
    ; Simulate entering function
    push 0AAAA0001h  ; Simulated return address
    call CallSim
    call NewFrameSim
    
    ; Get parameter
    mov eax, [ebp + 8]
    
    ; Push parameter onto simulated stack
    push eax
    call PushSim
    
    ; Display message
    mov edx, OFFSET msgInA
    call WriteString
    
    ; Push local variable
    mov eax, 10
    push eax
    call PushSim
    
    ; Call FunctionB with modified value
    mov eax, [ebp + 8]
    add eax, 50  ; Add 50
    push eax
    call FunctionB
    
    ; Pop local variable
    call PopSim
    
    ; Add 20 to result
    add eax, 20
    
    ; Pop parameter
    call PopSim
    
    ; Simulate leaving function
    call EndFrameSim
    call RetSim
    
    pop ebp
    ret 4
FunctionA ENDP

;------------------------------------------------------------
; FunctionB - Second level function
; Receives: Value on stack [ebp+8]
; Returns: EAX = modified value
;------------------------------------------------------------
FunctionB PROC
    push ebp
    mov ebp, esp
    
    ; Simulate entering function
    push 0BBBB0002h  ; Simulated return address
    call CallSim
    call NewFrameSim
    
    ; Get parameter
    mov eax, [ebp + 8]
    
    ; Push parameter onto simulated stack
    push eax
    call PushSim
    
    ; Display message
    mov edx, OFFSET msgInB
    call WriteString
    
    ; Push local variables
    mov eax, 20
    push eax
    call PushSim
    
    mov eax, 30
    push eax
    call PushSim
    
    ; Call FunctionC with modified value
    mov eax, [ebp + 8]
    add eax, 25  ; Add 25
    push eax
    call FunctionC
    
    ; Pop local variables
    call PopSim
    call PopSim
    
    ; Add 15 to result
    add eax, 15
    
    ; Pop parameter
    call PopSim
    
    ; Simulate leaving function
    call EndFrameSim
    call RetSim
    
    pop ebp
    ret 4
FunctionB ENDP

;------------------------------------------------------------
; FunctionC - Third level function (deepest)
; Receives: Value on stack [ebp+8]
; Returns: EAX = modified value
;------------------------------------------------------------
FunctionC PROC
    push ebp
    mov ebp, esp
    
    ; Simulate entering function
    push 0CCCC0003h  ; Simulated return address
    call CallSim
    call NewFrameSim
    
    ; Get parameter
    mov eax, [ebp + 8]
    
    ; Push parameter onto simulated stack
    push eax
    call PushSim
    
    ; Display message
    mov edx, OFFSET msgInC
    call WriteString
    
    ; Push multiple local variables
    mov eax, 40
    push eax
    call PushSim
    
    mov eax, 50
    push eax
    call PushSim
    
    mov eax, 60
    push eax
    call PushSim
    
    ; Get parameter and modify it
    mov eax, [ebp + 8]
    add eax, 5  ; Add 5
    
    ; Pop local variables
    call PopSim
    call PopSim
    call PopSim
    
    ; Pop parameter
    call PopSim
    
    ; Display return message
    mov edx, OFFSET msgReturning
    call WriteString
    
    ; Simulate leaving function
    call EndFrameSim
    call RetSim
    
    pop ebp
    ret 4
FunctionC ENDP

END main
