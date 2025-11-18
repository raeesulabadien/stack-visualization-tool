; Display.asm - Console Display Module for Stack Visualization
; Author: Stack Visualization Tool Project
; Description: Provides colored console output for stack operations
; Uses: Irvine32 library for colored text output

; Color Constants
; 0 = Black, 1 = Blue, 2 = Green, 3 = Cyan
; 4 = Red, 5 = Magenta, 6 = Brown, 7 = Light Gray
; 8 = Dark Gray, 9 = Light Blue, 10 = Light Green, 11 = Light Cyan
; 12 = Light Red, 13 = Light Magenta, 14 = Yellow, 15 = White

.data
    ; Display messages
    dispPushMsg BYTE "PUSH: ", 0
    dispPopMsg BYTE "POP: ", 0
    dispCallMsg BYTE "CALL: ", 0
    dispRetMsg BYTE "RET: ", 0
    dispFrameMsg BYTE "NEW FRAME", 0Dh, 0Ah, 0
    dispEndFrameMsg BYTE "END FRAME", 0Dh, 0Ah, 0
    dispESPMsg BYTE " ESP=", 0
    dispEBPMsg BYTE " EBP=", 0
    dispStackHeader BYTE 0Dh, 0Ah, "=== Stack State ===", 0Dh, 0Ah, 0
    dispStackAddr BYTE "Address: ", 0
    dispStackValue BYTE " Value: ", 0
    dispStackESP BYTE " <-- ESP", 0
    dispStackEBP BYTE " <-- EBP", 0
    dispSeparator BYTE "-------------------", 0Dh, 0Ah, 0

.code

;------------------------------------------------------------
; DisplayPush - Display a PUSH operation
; Receives: Value to push in [ebp+8] (parameter)
; Returns: Nothing
;------------------------------------------------------------
DisplayPush PROC
    push ebp
    mov ebp, esp
    push eax
    push edx
    
    ; Set color to yellow for operation
    mov eax, yellow + (black * 16)
    call SetTextColor
    
    ; Display "PUSH: "
    mov edx, OFFSET dispPushMsg
    call WriteString
    
    ; Set color to cyan for value
    mov eax, cyan + (black * 16)
    call SetTextColor
    
    ; Display value
    mov eax, [ebp + 8]
    call WriteHex
    
    ; Set color to light gray for registers
    mov eax, lightGray + (black * 16)
    call SetTextColor
    
    ; Display ESP
    mov edx, OFFSET dispESPMsg
    call WriteString
    mov eax, SimESP
    call WriteHex
    
    ; Display EBP
    mov edx, OFFSET dispEBPMsg
    call WriteString
    mov eax, SimEBP
    call WriteHex
    
    call Crlf
    
    ; Reset to white
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop eax
    pop ebp
    ret 4
DisplayPush ENDP

;------------------------------------------------------------
; DisplayPop - Display a POP operation
; Receives: Popped value in [ebp+8] (parameter)
; Returns: Nothing
;------------------------------------------------------------
DisplayPop PROC
    push ebp
    mov ebp, esp
    push eax
    push edx
    
    ; Set color to yellow for operation
    mov eax, yellow + (black * 16)
    call SetTextColor
    
    ; Display "POP: "
    mov edx, OFFSET dispPopMsg
    call WriteString
    
    ; Set color to cyan for value
    mov eax, cyan + (black * 16)
    call SetTextColor
    
    ; Display value
    mov eax, [ebp + 8]
    call WriteHex
    
    ; Set color to light gray for registers
    mov eax, lightGray + (black * 16)
    call SetTextColor
    
    ; Display ESP
    mov edx, OFFSET dispESPMsg
    call WriteString
    mov eax, SimESP
    call WriteHex
    
    ; Display EBP
    mov edx, OFFSET dispEBPMsg
    call WriteString
    mov eax, SimEBP
    call WriteHex
    
    call Crlf
    
    ; Reset to white
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop eax
    pop ebp
    ret 4
DisplayPop ENDP

;------------------------------------------------------------
; DisplayCall - Display a CALL operation
; Receives: Return address in [ebp+8] (parameter)
; Returns: Nothing
;------------------------------------------------------------
DisplayCall PROC
    push ebp
    mov ebp, esp
    push eax
    push edx
    
    ; Set color to light green for operation
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    
    ; Display "CALL: "
    mov edx, OFFSET dispCallMsg
    call WriteString
    
    ; Display return address
    mov eax, [ebp + 8]
    call WriteHex
    
    ; Set color to light gray for registers
    mov eax, lightGray + (black * 16)
    call SetTextColor
    
    ; Display ESP
    mov edx, OFFSET dispESPMsg
    call WriteString
    mov eax, SimESP
    call WriteHex
    
    call Crlf
    
    ; Reset to white
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop eax
    pop ebp
    ret 4
DisplayCall ENDP

;------------------------------------------------------------
; DisplayRet - Display a RET operation
; Receives: Return address in [ebp+8] (parameter)
; Returns: Nothing
;------------------------------------------------------------
DisplayRet PROC
    push ebp
    mov ebp, esp
    push eax
    push edx
    
    ; Set color to light green for operation
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    
    ; Display "RET: "
    mov edx, OFFSET dispRetMsg
    call WriteString
    
    ; Display return address
    mov eax, [ebp + 8]
    call WriteHex
    
    ; Set color to light gray for registers
    mov eax, lightGray + (black * 16)
    call SetTextColor
    
    ; Display ESP
    mov edx, OFFSET dispESPMsg
    call WriteString
    mov eax, SimESP
    call WriteHex
    
    call Crlf
    
    ; Reset to white
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop eax
    pop ebp
    ret 4
DisplayRet ENDP

;------------------------------------------------------------
; DisplayNewFrame - Display NEW FRAME operation
; Receives: Nothing
; Returns: Nothing
;------------------------------------------------------------
DisplayNewFrame PROC
    push eax
    push edx
    
    ; Set color to magenta
    mov eax, lightMagenta + (black * 16)
    call SetTextColor
    
    ; Display message
    mov edx, OFFSET dispFrameMsg
    call WriteString
    
    ; Reset to white
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop eax
    ret
DisplayNewFrame ENDP

;------------------------------------------------------------
; DisplayEndFrame - Display END FRAME operation
; Receives: Nothing
; Returns: Nothing
;------------------------------------------------------------
DisplayEndFrame PROC
    push eax
    push edx
    
    ; Set color to magenta
    mov eax, lightMagenta + (black * 16)
    call SetTextColor
    
    ; Display message
    mov edx, OFFSET dispEndFrameMsg
    call WriteString
    
    ; Reset to white
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop eax
    ret
DisplayEndFrame ENDP

;------------------------------------------------------------
; DisplayStack - Display current stack state
; Receives: Nothing
; Returns: Nothing
;------------------------------------------------------------
DisplayStack PROC
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    
    ; Display header
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov edx, OFFSET dispStackHeader
    call WriteString
    mov edx, OFFSET dispSeparator
    call WriteString
    
    ; Reset color
    mov eax, white + (black * 16)
    call SetTextColor
    
    ; Start from top of stack
    mov ebx, StackTop
    mov ecx, 0
    
DisplayLoop:
    cmp ecx, 32  ; Show top 32 entries
    jge DisplayDone
    cmp ebx, SimESP
    jl DisplayDone
    
    ; Display address
    mov edx, OFFSET dispStackAddr
    call WriteString
    mov eax, ebx
    call WriteHex
    
    ; Display value
    mov edx, OFFSET dispStackValue
    call WriteString
    mov eax, [ebx]
    call WriteHex
    
    ; Check if ESP points here
    cmp ebx, SimESP
    jne CheckEBP
    mov eax, cyan + (black * 16)
    call SetTextColor
    mov edx, OFFSET dispStackESP
    call WriteString
    mov eax, white + (black * 16)
    call SetTextColor
    jmp NextEntry
    
CheckEBP:
    ; Check if EBP points here
    cmp ebx, SimEBP
    jne NextEntry
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov edx, OFFSET dispStackEBP
    call WriteString
    mov eax, white + (black * 16)
    call SetTextColor
    
NextEntry:
    call Crlf
    sub ebx, 4
    inc ecx
    jmp DisplayLoop
    
DisplayDone:
    mov edx, OFFSET dispSeparator
    call WriteString
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret
DisplayStack ENDP
