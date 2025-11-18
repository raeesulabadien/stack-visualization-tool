; Fibonacci.asm - Fibonacci Recursion Demo
; Author: Stack Visualization Tool Project
; Description: Demonstrates recursive Fibonacci calculation with stack visualization
; Calculates Fibonacci numbers using recursion with full stack simulation

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
    msgTitle BYTE "=== Fibonacci Recursion Demo ===", 0Dh, 0Ah, 0
    msgPrompt BYTE "Enter N (Fibonacci number to calculate): ", 0
    msgComputing BYTE "Computing Fibonacci(", 0
    msgResult BYTE ")...", 0Dh, 0Ah, "Result: ", 0
    msgExplanation BYTE 0Dh, 0Ah
                   BYTE "This demo shows recursive Fibonacci calculation:", 0Dh, 0Ah
                   BYTE "- Each recursive call creates a new stack frame", 0Dh, 0Ah
                   BYTE "- Base cases: fib(0)=0, fib(1)=1", 0Dh, 0Ah
                   BYTE "- Recursive case: fib(n) = fib(n-1) + fib(n-2)", 0Dh, 0Ah
                   BYTE "- Watch the stack grow with nested calls!", 0Dh, 0Ah, 0Dh, 0Ah, 0

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
    mov edx, OFFSET msgResult
    call WriteString
    
    ; Call Fibonacci with N
    push ebx
    call Fibonacci
    
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
; Fibonacci - Recursive Fibonacci calculation with stack simulation
; Receives: N on stack [ebp+8]
; Returns: EAX = fib(N)
; Simulates all stack operations
;------------------------------------------------------------
Fibonacci PROC
    push ebp
    mov ebp, esp
    
    ; Simulate entering function
    push 11111111h  ; Simulated return address
    call CallSim
    call NewFrameSim
    
    ; Get N
    mov eax, [ebp + 8]
    
    ; Push N onto simulated stack (local variable)
    push eax
    call PushSim
    
    ; Base case: fib(0) = 0
    cmp eax, 0
    je FibZero
    
    ; Base case: fib(1) = 1
    cmp eax, 1
    je FibOne
    
    ; Recursive case: fib(n) = fib(n-1) + fib(n-2)
    
    ; Save N
    push ebx
    push ecx
    mov ecx, eax  ; Save N in ECX
    
    ; Calculate fib(n-1)
    dec ecx
    push ecx
    call Fibonacci
    mov ebx, eax  ; Save fib(n-1) in EBX
    
    ; Calculate fib(n-2)
    mov ecx, [ebp + 8]
    sub ecx, 2
    push ecx
    call Fibonacci
    
    ; Add fib(n-1) + fib(n-2)
    add eax, ebx
    
    pop ecx
    pop ebx
    jmp FibDone
    
FibZero:
    xor eax, eax
    jmp FibDone
    
FibOne:
    mov eax, 1
    
FibDone:
    ; Pop local variable (N)
    call PopSim
    
    ; Simulate leaving function
    call EndFrameSim
    call RetSim
    
    pop ebp
    ret 4
Fibonacci ENDP

END main
