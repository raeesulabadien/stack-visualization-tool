; StackSim.asm - Stack Simulator with Logging and Display
; Author: Stack Visualization Tool Project
; Description: Complete x86 stack simulator with console display and file logging
; Uses: Irvine32 library for I/O operations

INCLUDE Irvine32.inc
INCLUDE Display.asm
INCLUDE Logger.asm

.data
    ; Simulated Stack (256 DWORDs = 1024 bytes)
    SimStack DWORD 256 DUP(0)
    
    ; Simulated Stack Pointer (ESP) - Points to top of stack
    ; Starts at highest address (grows downward)
    SimESP DWORD OFFSET SimStack + (255 * 4)
    
    ; Simulated Base Pointer (EBP) - Points to current frame base
    SimEBP DWORD OFFSET SimStack + (255 * 4)
    
    ; Stack bounds for overflow/underflow detection
    StackBottom DWORD OFFSET SimStack
    StackTop DWORD OFFSET SimStack + (255 * 4)
    
    ; Messages
    msgWelcome BYTE "=== Stack Visualization Tool ===", 0Dh, 0Ah, 0
    msgMenu BYTE 0Dh, 0Ah, "Menu:", 0Dh, 0Ah
                BYTE "1. Push Value", 0Dh, 0Ah
                BYTE "2. Pop Value", 0Dh, 0Ah
                BYTE "3. Simulate Call", 0Dh, 0Ah
                BYTE "4. Simulate Return", 0Dh, 0Ah
                BYTE "5. Display Stack", 0Dh, 0Ah
                BYTE "6. Run Fibonacci Demo", 0Dh, 0Ah
                BYTE "7. Run Factorial Demo", 0Dh, 0Ah
                BYTE "0. Exit", 0Dh, 0Ah
                BYTE "Choice: ", 0
    msgEnterValue BYTE "Enter value to push: ", 0
    msgPushing BYTE "Pushing: ", 0
    msgPopping BYTE "Popping: ", 0
    msgCallAddr BYTE "Calling function at address: ", 0
    msgReturning BYTE "Returning from function", 0Dh, 0Ah, 0
    msgStackFull BYTE "ERROR: Stack Overflow!", 0Dh, 0Ah, 0
    msgStackEmpty BYTE "ERROR: Stack Underflow!", 0Dh, 0Ah, 0
    msgEnterN BYTE "Enter N (for Fibonacci/Factorial): ", 0
    msgResult BYTE "Result: ", 0
    logFileName BYTE "output/stacklog.txt", 0
    
.code
main PROC
    ; Initialize log file
    call InitLogger
    
    ; Display welcome message
    mov edx, OFFSET msgWelcome
    call WriteString
    call Crlf
    
MenuLoop:
    ; Display menu
    mov edx, OFFSET msgMenu
    call WriteString
    call ReadInt
    
    cmp eax, 1
    je DoPush
    cmp eax, 2
    je DoPop
    cmp eax, 3
    je DoCall
    cmp eax, 4
    je DoRet
    cmp eax, 5
    je DoDisplay
    cmp eax, 6
    je DoFibDemo
    cmp eax, 7
    je DoFactDemo
    cmp eax, 0
    je ExitProgram
    jmp MenuLoop
    
DoPush:
    mov edx, OFFSET msgEnterValue
    call WriteString
    call ReadInt
    push eax
    call PushSim
    jmp MenuLoop
    
DoPop:
    call PopSim
    jmp MenuLoop
    
DoCall:
    mov edx, OFFSET msgCallAddr
    call WriteString
    call ReadInt
    push eax
    call CallSim
    jmp MenuLoop
    
DoRet:
    call RetSim
    jmp MenuLoop
    
DoDisplay:
    call DisplayStack
    jmp MenuLoop
    
DoFibDemo:
    mov edx, OFFSET msgEnterN
    call WriteString
    call ReadInt
    push eax
    call FibonacciDemo
    mov edx, OFFSET msgResult
    call WriteString
    call WriteInt
    call Crlf
    jmp MenuLoop
    
DoFactDemo:
    mov edx, OFFSET msgEnterN
    call WriteString
    call ReadInt
    push eax
    call FactorialDemo
    mov edx, OFFSET msgResult
    call WriteString
    call WriteInt
    call Crlf
    jmp MenuLoop
    
ExitProgram:
    call CloseLogger
    exit
main ENDP

;------------------------------------------------------------
; PushSim - Push a value onto simulated stack
; Receives: Value on real stack (parameter)
; Returns: Nothing
; Modifies: SimESP
;------------------------------------------------------------
PushSim PROC
    push ebp
    mov ebp, esp
    push eax
    push ebx
    
    ; Check for stack overflow
    mov eax, SimESP
    sub eax, 4
    cmp eax, StackBottom
    jl StackOverflow
    
    ; Get value from parameter
    mov eax, [ebp + 8]
    
    ; Decrement ESP (stack grows down)
    mov ebx, SimESP
    sub ebx, 4
    mov SimESP, ebx
    
    ; Store value at new ESP location
    mov [ebx], eax
    
    ; Display operation
    call DisplayPush
    
    ; Log operation
    push eax
    call LogPush
    
    jmp PushDone
    
StackOverflow:
    mov edx, OFFSET msgStackFull
    call WriteString
    
PushDone:
    pop ebx
    pop eax
    pop ebp
    ret 4
PushSim ENDP

;------------------------------------------------------------
; PopSim - Pop a value from simulated stack
; Receives: Nothing
; Returns: EAX = popped value
; Modifies: SimESP
;------------------------------------------------------------
PopSim PROC
    push ebp
    mov ebp, esp
    push ebx
    
    ; Check for stack underflow
    mov eax, SimESP
    cmp eax, StackTop
    jge StackUnderflow
    
    ; Get current ESP
    mov ebx, SimESP
    
    ; Load value from stack
    mov eax, [ebx]
    
    ; Display operation
    push eax
    call DisplayPop
    
    ; Log operation
    push eax
    call LogPop
    
    ; Increment ESP (stack shrinks)
    add ebx, 4
    mov SimESP, ebx
    
    jmp PopDone
    
StackUnderflow:
    mov edx, OFFSET msgStackEmpty
    call WriteString
    xor eax, eax
    
PopDone:
    pop ebx
    pop ebp
    ret
PopSim ENDP

;------------------------------------------------------------
; CallSim - Simulate function call
; Receives: Return address on real stack (parameter)
; Returns: Nothing
; Modifies: SimESP
;------------------------------------------------------------
CallSim PROC
    push ebp
    mov ebp, esp
    push eax
    
    ; Get return address parameter
    mov eax, [ebp + 8]
    
    ; Push return address onto simulated stack
    push eax
    call PushSim
    
    ; Log CALL operation
    push eax
    call LogCall
    
    pop eax
    pop ebp
    ret 4
CallSim ENDP

;------------------------------------------------------------
; RetSim - Simulate function return
; Receives: Nothing
; Returns: EAX = return address
; Modifies: SimESP
;------------------------------------------------------------
RetSim PROC
    push ebp
    mov ebp, esp
    
    ; Pop return address
    call PopSim
    ; EAX now contains return address
    
    ; Log RET operation
    push eax
    call LogRet
    
    pop ebp
    ret
RetSim ENDP

;------------------------------------------------------------
; NewFrameSim - Create new stack frame
; Receives: Nothing
; Returns: Nothing
; Modifies: SimESP, SimEBP
;------------------------------------------------------------
NewFrameSim PROC
    push ebp
    mov ebp, esp
    push eax
    
    ; Push old EBP
    mov eax, SimEBP
    push eax
    call PushSim
    
    ; Set new EBP = current ESP
    mov eax, SimESP
    mov SimEBP, eax
    
    ; Log operation
    call LogNewFrame
    
    pop eax
    pop ebp
    ret
NewFrameSim ENDP

;------------------------------------------------------------
; EndFrameSim - Destroy current stack frame
; Receives: Nothing
; Returns: Nothing
; Modifies: SimESP, SimEBP
;------------------------------------------------------------
EndFrameSim PROC
    push ebp
    mov ebp, esp
    
    ; Restore ESP from EBP
    mov eax, SimEBP
    mov SimESP, eax
    
    ; Pop old EBP
    call PopSim
    mov SimEBP, eax
    
    ; Log operation
    call LogEndFrame
    
    pop ebp
    ret
EndFrameSim ENDP

;------------------------------------------------------------
; FibonacciDemo - Demonstrate Fibonacci recursion
; Receives: N on real stack (parameter)
; Returns: EAX = Fibonacci(N)
;------------------------------------------------------------
FibonacciDemo PROC
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    
    mov eax, [ebp + 8]  ; Get N
    
    ; Base case: fib(0) = 0, fib(1) = 1
    cmp eax, 0
    je FibBase0
    cmp eax, 1
    je FibBase1
    
    ; Recursive case: fib(n) = fib(n-1) + fib(n-2)
    
    ; Simulate call to fib(n-1)
    push 12345678h  ; Dummy return address
    call CallSim
    call NewFrameSim
    
    dec eax
    push eax
    call FibonacciDemo
    mov ebx, eax  ; Save fib(n-1)
    
    call EndFrameSim
    call RetSim
    
    ; Simulate call to fib(n-2)
    push 87654321h  ; Dummy return address
    call CallSim
    call NewFrameSim
    
    mov eax, [ebp + 8]
    sub eax, 2
    push eax
    call FibonacciDemo
    
    call EndFrameSim
    call RetSim
    
    ; Add results
    add eax, ebx
    jmp FibDone
    
FibBase0:
    xor eax, eax
    jmp FibDone
    
FibBase1:
    mov eax, 1
    
FibDone:
    pop ecx
    pop ebx
    pop ebp
    ret 4
FibonacciDemo ENDP

;------------------------------------------------------------
; FactorialDemo - Demonstrate Factorial recursion
; Receives: N on real stack (parameter)
; Returns: EAX = N!
;------------------------------------------------------------
FactorialDemo PROC
    push ebp
    mov ebp, esp
    push ebx
    
    mov eax, [ebp + 8]  ; Get N
    
    ; Base case: 0! = 1, 1! = 1
    cmp eax, 1
    jle FactBase
    
    ; Recursive case: n! = n * (n-1)!
    
    ; Simulate call to fact(n-1)
    push 11111111h  ; Dummy return address
    call CallSim
    call NewFrameSim
    
    mov ebx, eax  ; Save N
    dec eax
    push eax
    call FactorialDemo
    
    call EndFrameSim
    call RetSim
    
    ; Multiply N * fact(N-1)
    mul ebx
    jmp FactDone
    
FactBase:
    mov eax, 1
    
FactDone:
    pop ebx
    pop ebp
    ret 4
FactorialDemo ENDP

END main
