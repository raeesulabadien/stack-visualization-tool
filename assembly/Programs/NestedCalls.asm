; NestedCalls.asm - Nested function calls demonstration
; Shows: main -> A -> B -> C

INCLUDE Irvine32.inc
INCLUDE ..\StackSim.asm

.data
    msgA BYTE "Function A", 0Dh, 0Ah, 0
    msgB BYTE "Function B", 0Dh, 0Ah, 0
    msgC BYTE "Function C", 0Dh, 0Ah, 0

.code
FuncC PROC
    push 0CCCCCCCCh
    call CallSim
    call NewFrameSim
    
    mov edx, OFFSET msgC
    call WriteString
    
    push 999
    call PushSim
    
    call EndFrameSim
    call RetSim
    ret
FuncC ENDP

FuncB PROC
    push 0BBBBBBBBh
    call CallSim
    call NewFrameSim
    
    mov edx, OFFSET msgB
    call WriteString
    
    push 777
    call PushSim
    
    call FuncC
    
    call EndFrameSim
    call RetSim
    ret
FuncB ENDP

FuncA PROC
    push 0AAAAAAAAh
    call CallSim
    call NewFrameSim
    
    mov edx, OFFSET msgA
    call WriteString
    
    push 555
    call PushSim
    
    call FuncB
    
    call EndFrameSim
    call RetSim
    ret
FuncA ENDP

main PROC
    call InitLogger
    
    push 123
    call PushSim
    
    call FuncA
    
    call CloseLogger
    call WaitMsg
    exit
main ENDP
END main

