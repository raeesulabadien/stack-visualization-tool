; SimpleFactorial.asm - Standalone Factorial with full logging
; Calculates 5! = 120

INCLUDE Irvine32.inc
INCLUDE ..\StackSim.asm

.data
    msgCalc BYTE "Calculating 5! with stack simulation...", 0Dh, 0Ah, 0
    msgDone BYTE "Check stacklog.txt for visualization", 0Dh, 0Ah, 0

.code
main PROC
    call InitLogger
    
    mov edx, OFFSET msgCalc
    call WriteString
    
    ; Calculate 5!
    push 5
    call FactorialDemo
    
    mov edx, OFFSET msgDone
    call WriteString
    
    call CloseLogger
    call WaitMsg
    exit
main ENDP
END main
