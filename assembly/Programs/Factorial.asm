; Factorial.asm - Factorial Recursion Demo
; Author: Stack Visualization Tool Project
; Description: Demonstrates recursive factorial calculation with stack visualization
; Calculates N! using recursion with full stack simulation

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
    msgTitle BYTE "=== Factorial Recursion Demo ===", 0Dh, 0Ah, 0
    msgPrompt BYTE "Enter N (factorial to calculate): ", 0
    msgComputing BYTE "Computing ", 0
    msgFactorial BYTE "!...", 0Dh, 0Ah, "Result: ", 0
    msgExplanation BYTE 0Dh, 0Ah
                   BYTE "This demo shows recursive factorial calculation:", 0Dh, 0Ah
                   BYTE "- Each recursive call creates a new stack frame", 0Dh, 0Ah
                   BYTE "- Base case: 0! = 1, 1! = 1", 0Dh, 0Ah
                   BYTE "- Recursive case: n! = n * (n-1)!", 0Dh, 0Ah
                   BYTE "- Observe how values accumulate on return!", 0Dh, 0Ah, 0Dh, 0Ah, 0

.code
main PROC
    ; Initialize logger
    call InitLogger
    
    ; Display title
    mov edx, OFFSET msgTitle
    call WriteString
    
    ; Display explanation
    mov edx, OFFSET msgExplanation
    call WriteString
    
    ; Prompt for N
    mov edx, OFFSET msgPrompt
    call WriteString
    call ReadInt
    mov ebx, eax  ; Save N
    
    ; Display what we're computing
    mov edx, OFFSET msgComputing
    call WriteString
    mov eax, ebx
    call WriteDec
    mov edx, OFFSET msgFactorial
    call WriteString
    
    ; Call Factorial with N
    push ebx
    call Factorial
    
    ; Display result
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
; Factorial - Recursive factorial calculation with stack simulation
; Receives: N on stack [ebp+8]
; Returns: EAX = N!
; Simulates all stack operations
;------------------------------------------------------------
Factorial PROC
    push ebp
    mov ebp, esp
    
    ; Simulate entering function
    push 22222222h  ; Simulated return address
    call CallSim
    call NewFrameSim
    
    ; Get N
    mov eax, [ebp + 8]
    
    ; Push N onto simulated stack (local variable)
    push eax
    call PushSim
    
    ; Base case: 0! = 1, 1! = 1
    cmp eax, 1
    jle FactBase
    
    ; Recursive case: n! = n * (n-1)!
    push ebx
    mov ebx, eax  ; Save N in EBX
    
    ; Calculate (n-1)!
    dec eax
    push eax
    call Factorial
    
    ; Multiply n * (n-1)!
    mul ebx  ; EAX = EAX * EBX = (n-1)! * n = n!
    
    pop ebx
    jmp FactDone
    
FactBase:
    mov eax, 1
    
FactDone:
    ; Pop local variable (N)
    call PopSim
    
    ; Simulate leaving function
    call EndFrameSim
    call RetSim
    
    pop ebp
    ret 4
Factorial ENDP

END main
