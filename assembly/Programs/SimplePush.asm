; SimplePush.asm - Simple PUSH/POP demonstration
; Can be assembled standalone: ml /c /coff SimplePush.asm
; Link: link /SUBSYSTEM:CONSOLE SimplePush.obj Irvine32.lib kernel32.lib

INCLUDE Irvine32.inc
INCLUDE ..\StackSim.asm

.code
main PROC
    call InitLogger
    
    ; Push three values
    push 100
    call PushSim
    
    push 200
    call PushSim
    
    push 300
    call PushSim
    
    ; Pop them back
    call PopSim
    call PopSim
    call PopSim
    
    call CloseLogger
    call WaitMsg
    exit
main ENDP
END main
