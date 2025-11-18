; LocalVars.asm - Local Variables Demo
; Author: Stack Visualization Tool Project
; Description: Demonstrates local variable management on the stack
; Shows how local variables are allocated and deallocated in stack frames

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
    msgTitle BYTE "=== Local Variables Demo ===", 0Dh, 0Ah, 0
    msgExplanation BYTE 0Dh, 0Ah
                   BYTE "This demo shows local variable management:", 0Dh, 0Ah
                   BYTE "- Functions allocate space for local vars", 0Dh, 0Ah
                   BYTE "- Locals are stored in the stack frame", 0Dh, 0Ah
                   BYTE "- Variables are deallocated on return", 0Dh, 0Ah
                   BYTE "- Watch the stack frame grow and shrink!", 0Dh, 0Ah, 0Dh, 0Ah, 0
    
    msgCalling BYTE "Calling function with parameters...", 0Dh, 0Ah, 0
    msgInFunc BYTE "Inside function, allocating locals:", 0Dh, 0Ah, 0
    msgVar1 BYTE "  Local var1 = ", 0
    msgVar2 BYTE "  Local var2 = ", 0
    msgVar3 BYTE "  Local var3 = ", 0
    msgVar4 BYTE "  Local var4 = ", 0
    msgComputing BYTE "Computing with local variables...", 0Dh, 0Ah, 0
    msgCleaning BYTE "Cleaning up local variables...", 0Dh, 0Ah, 0
    msgResult BYTE "Function returned: ", 0

.code
main PROC
    ; Initialize logger
    call InitLogger
    
    ; Display title and explanation
    mov edx, OFFSET msgTitle
    call WriteString
    mov edx, OFFSET msgExplanation
    call WriteString
    
    ; Call function with two parameters
    mov edx, OFFSET msgCalling
    call WriteString
    
    push 25  ; Second parameter
    push 10  ; First parameter
    call ComputeWithLocals
    
    ; Display result
    mov edx, OFFSET msgResult
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
; ComputeWithLocals - Function with multiple local variables
; Receives: Two parameters on stack [ebp+8], [ebp+12]
; Returns: EAX = computed result
; Demonstrates local variable allocation and usage
;------------------------------------------------------------
ComputeWithLocals PROC
    push ebp
    mov ebp, esp
    
    ; Simulate entering function
    push 0ABCD1234h  ; Simulated return address
    call CallSim
    call NewFrameSim
    
    ; Get parameters
    mov eax, [ebp + 8]   ; First parameter
    mov ebx, [ebp + 12]  ; Second parameter
    
    ; Push parameters onto simulated stack
    push eax
    call PushSim
    push ebx
    call PushSim
    
    ; Display message
    mov edx, OFFSET msgInFunc
    call WriteString
    
    ; Allocate and initialize local variables
    ; Local var1 = param1 * 2
    mov eax, [ebp + 8]
    shl eax, 1  ; Multiply by 2
    push eax
    call PushSim
    mov edx, OFFSET msgVar1
    call WriteString
    call WriteDec
    call Crlf
    
    ; Local var2 = param2 * 3
    mov eax, [ebp + 12]
    mov ecx, 3
    mul ecx
    push eax
    call PushSim
    mov edx, OFFSET msgVar2
    call WriteString
    call WriteDec
    call Crlf
    
    ; Local var3 = var1 + var2
    call PopSim  ; Get var2
    mov ebx, eax
    call PopSim  ; Get var1
    add eax, ebx
    push eax
    call PushSim
    mov edx, OFFSET msgVar3
    call WriteString
    call WriteDec
    call Crlf
    
    ; Push var2 and var1 back
    push ebx
    call PushSim
    push eax
    call PushSim
    
    ; Local var4 = (var1 + var2) / 2
    call PopSim  ; var1 again
    push eax
    call PopSim  ; var2
    pop ecx  ; restore var1
    add eax, ecx
    shr eax, 1  ; Divide by 2
    push eax
    call PushSim
    mov edx, OFFSET msgVar4
    call WriteString
    call WriteDec
    call Crlf
    
    ; Display computing message
    mov edx, OFFSET msgComputing
    call WriteString
    
    ; Compute result: var3 + var4
    call PopSim  ; Get var4
    mov ebx, eax
    call PopSim  ; Get var3
    call PopSim  ; Get var2
    call PopSim  ; Get var1
    
    ; Result = var3 + var4 (stored in ebx and previous eax)
    mov eax, ebx  ; var4
    ; We'll just use var4 as result for simplicity
    
    ; Display cleaning message
    mov edx, OFFSET msgCleaning
    call WriteString
    
    ; Pop parameters
    call PopSim
    call PopSim
    
    ; Simulate leaving function
    call EndFrameSim
    call RetSim
    
    pop ebp
    ret 8  ; Clean up 2 parameters
ComputeWithLocals ENDP

END main
