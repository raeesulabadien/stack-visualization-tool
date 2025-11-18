; SimpleFibonacci.asm - Standalone Fibonacci with full logging
; Calculates Fib(6)

INCLUDE Irvine32.inc
INCLUDE ..\StackSim.asm

.data
    msgCalc BYTE "Calculating Fibonacci(6) with stack simulation...", 0Dh, 0Ah, 0
    msgDone BYTE "Check stacklog.txt for visualization", 0Dh, 0Ah, 0

.code
main PROC
    call InitLogger
    
    mov edx, OFFSET msgCalc
    call WriteString
    
    ; Calculate Fib(6)
    push 6
    call FibonacciDemo
    
    mov edx, OFFSET msgDone
    call WriteString
    
    call CloseLogger
    call WaitMsg
    exit
main ENDP
END main
