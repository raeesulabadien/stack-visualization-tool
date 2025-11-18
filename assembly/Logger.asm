; Logger.asm - File Logging Module for Stack Visualization
; Author: Stack Visualization Tool Project
; Description: Logs all stack operations to a CSV file for web visualization
; Format: OPERATION,VALUE,ESP=address,EBP=address

.data
    ; Log file handle
    logFileHandle DWORD ?
    
    ; Log buffer
    logBuffer BYTE 256 DUP(0)
    
    ; CSV field strings
    logPush BYTE "PUSH,", 0
    logPop BYTE "POP,", 0
    logCall BYTE "CALL,", 0
    logRet BYTE "RET,", 0
    logNewFrame BYTE "NEWFRAME,0,", 0
    logEndFrame BYTE "ENDFRAME,0,", 0
    logESPLabel BYTE ",ESP=", 0
    logEBPLabel BYTE ",EBP=", 0
    logNewline BYTE 0Dh, 0Ah, 0
    
    ; Conversion buffer for hex to string
    hexBuffer BYTE 12 DUP(0)
    hexDigits BYTE "0123456789ABCDEF", 0
    
    ; Log file name (can be overridden)
    logFilePath BYTE "output/stacklog.txt", 0
    
    ; Error messages
    logErrorCreate BYTE "Error creating log file", 0Dh, 0Ah, 0
    logErrorWrite BYTE "Error writing to log file", 0Dh, 0Ah, 0

.code

;------------------------------------------------------------
; InitLogger - Initialize the log file
; Receives: Nothing
; Returns: Nothing
; Creates a new log file, overwriting if exists
;------------------------------------------------------------
InitLogger PROC
    push eax
    push edx
    
    ; Create/open file for writing
    mov edx, OFFSET logFilePath
    call CreateOutputFile
    
    cmp eax, INVALID_HANDLE_VALUE
    je InitError
    
    mov logFileHandle, eax
    jmp InitDone
    
InitError:
    mov edx, OFFSET logErrorCreate
    call WriteString
    
InitDone:
    pop edx
    pop eax
    ret
InitLogger ENDP

;------------------------------------------------------------
; CloseLogger - Close the log file
; Receives: Nothing
; Returns: Nothing
;------------------------------------------------------------
CloseLogger PROC
    push eax
    
    mov eax, logFileHandle
    call CloseFile
    
    pop eax
    ret
CloseLogger ENDP

;------------------------------------------------------------
; LogPush - Log a PUSH operation
; Receives: Value on stack [ebp+8]
; Returns: Nothing
;------------------------------------------------------------
LogPush PROC
    push ebp
    mov ebp, esp
    push eax
    push edx
    push esi
    push edi
    
    ; Clear buffer
    call ClearLogBuffer
    
    ; Build log entry: "PUSH,value,ESP=addr,EBP=addr\r\n"
    mov esi, OFFSET logBuffer
    
    ; Add "PUSH,"
    mov edi, OFFSET logPush
    call AppendString
    
    ; Add value
    mov eax, [ebp + 8]
    call AppendHex
    
    ; Add ",ESP="
    mov edi, OFFSET logESPLabel
    call AppendString
    
    ; Add ESP value
    mov eax, SimESP
    call AppendHex
    
    ; Add ",EBP="
    mov edi, OFFSET logEBPLabel
    call AppendString
    
    ; Add EBP value
    mov eax, SimEBP
    call AppendHex
    
    ; Add newline
    mov edi, OFFSET logNewline
    call AppendString
    
    ; Write to file
    call WriteLogBuffer
    
    pop edi
    pop esi
    pop edx
    pop eax
    pop ebp
    ret 4
LogPush ENDP

;------------------------------------------------------------
; LogPop - Log a POP operation
; Receives: Value on stack [ebp+8]
; Returns: Nothing
;------------------------------------------------------------
LogPop PROC
    push ebp
    mov ebp, esp
    push eax
    push edx
    push esi
    push edi
    
    ; Clear buffer
    call ClearLogBuffer
    
    ; Build log entry
    mov esi, OFFSET logBuffer
    
    ; Add "POP,"
    mov edi, OFFSET logPop
    call AppendString
    
    ; Add value
    mov eax, [ebp + 8]
    call AppendHex
    
    ; Add ",ESP="
    mov edi, OFFSET logESPLabel
    call AppendString
    
    ; Add ESP value
    mov eax, SimESP
    call AppendHex
    
    ; Add ",EBP="
    mov edi, OFFSET logEBPLabel
    call AppendString
    
    ; Add EBP value
    mov eax, SimEBP
    call AppendHex
    
    ; Add newline
    mov edi, OFFSET logNewline
    call AppendString
    
    ; Write to file
    call WriteLogBuffer
    
    pop edi
    pop esi
    pop edx
    pop eax
    pop ebp
    ret 4
LogPop ENDP

;------------------------------------------------------------
; LogCall - Log a CALL operation
; Receives: Return address on stack [ebp+8]
; Returns: Nothing
;------------------------------------------------------------
LogCall PROC
    push ebp
    mov ebp, esp
    push eax
    push edx
    push esi
    push edi
    
    ; Clear buffer
    call ClearLogBuffer
    
    ; Build log entry
    mov esi, OFFSET logBuffer
    
    ; Add "CALL,"
    mov edi, OFFSET logCall
    call AppendString
    
    ; Add return address
    mov eax, [ebp + 8]
    call AppendHex
    
    ; Add ",ESP="
    mov edi, OFFSET logESPLabel
    call AppendString
    
    ; Add ESP value
    mov eax, SimESP
    call AppendHex
    
    ; Add ",EBP="
    mov edi, OFFSET logEBPLabel
    call AppendString
    
    ; Add EBP value
    mov eax, SimEBP
    call AppendHex
    
    ; Add newline
    mov edi, OFFSET logNewline
    call AppendString
    
    ; Write to file
    call WriteLogBuffer
    
    pop edi
    pop esi
    pop edx
    pop eax
    pop ebp
    ret 4
LogCall ENDP

;------------------------------------------------------------
; LogRet - Log a RET operation
; Receives: Return address on stack [ebp+8]
; Returns: Nothing
;------------------------------------------------------------
LogRet PROC
    push ebp
    mov ebp, esp
    push eax
    push edx
    push esi
    push edi
    
    ; Clear buffer
    call ClearLogBuffer
    
    ; Build log entry
    mov esi, OFFSET logBuffer
    
    ; Add "RET,"
    mov edi, OFFSET logRet
    call AppendString
    
    ; Add return address
    mov eax, [ebp + 8]
    call AppendHex
    
    ; Add ",ESP="
    mov edi, OFFSET logESPLabel
    call AppendString
    
    ; Add ESP value
    mov eax, SimESP
    call AppendHex
    
    ; Add ",EBP="
    mov edi, OFFSET logEBPLabel
    call AppendString
    
    ; Add EBP value
    mov eax, SimEBP
    call AppendHex
    
    ; Add newline
    mov edi, OFFSET logNewline
    call AppendString
    
    ; Write to file
    call WriteLogBuffer
    
    pop edi
    pop esi
    pop edx
    pop eax
    pop ebp
    ret 4
LogRet ENDP

;------------------------------------------------------------
; LogNewFrame - Log a NEW FRAME operation
; Receives: Nothing
; Returns: Nothing
;------------------------------------------------------------
LogNewFrame PROC
    push eax
    push edx
    push esi
    push edi
    
    ; Clear buffer
    call ClearLogBuffer
    
    ; Build log entry
    mov esi, OFFSET logBuffer
    
    ; Add "NEWFRAME,0,"
    mov edi, OFFSET logNewFrame
    call AppendString
    
    ; Add "ESP="
    mov edi, OFFSET logESPLabel
    add edi, 1  ; Skip comma
    call AppendString
    
    ; Add ESP value
    mov eax, SimESP
    call AppendHex
    
    ; Add ",EBP="
    mov edi, OFFSET logEBPLabel
    call AppendString
    
    ; Add EBP value
    mov eax, SimEBP
    call AppendHex
    
    ; Add newline
    mov edi, OFFSET logNewline
    call AppendString
    
    ; Write to file
    call WriteLogBuffer
    
    pop edi
    pop esi
    pop edx
    pop eax
    ret
LogNewFrame ENDP

;------------------------------------------------------------
; LogEndFrame - Log an END FRAME operation
; Receives: Nothing
; Returns: Nothing
;------------------------------------------------------------
LogEndFrame PROC
    push eax
    push edx
    push esi
    push edi
    
    ; Clear buffer
    call ClearLogBuffer
    
    ; Build log entry
    mov esi, OFFSET logBuffer
    
    ; Add "ENDFRAME,0,"
    mov edi, OFFSET logEndFrame
    call AppendString
    
    ; Add "ESP="
    mov edi, OFFSET logESPLabel
    add edi, 1  ; Skip comma
    call AppendString
    
    ; Add ESP value
    mov eax, SimESP
    call AppendHex
    
    ; Add ",EBP="
    mov edi, OFFSET logEBPLabel
    call AppendString
    
    ; Add EBP value
    mov eax, SimEBP
    call AppendHex
    
    ; Add newline
    mov edi, OFFSET logNewline
    call AppendString
    
    ; Write to file
    call WriteLogBuffer
    
    pop edi
    pop esi
    pop edx
    pop eax
    ret
LogEndFrame ENDP

;------------------------------------------------------------
; Helper Procedures
;------------------------------------------------------------

;------------------------------------------------------------
; ClearLogBuffer - Clear the log buffer
; Receives: Nothing
; Returns: Nothing
;------------------------------------------------------------
ClearLogBuffer PROC
    push eax
    push ecx
    push edi
    
    mov edi, OFFSET logBuffer
    mov ecx, 256
    xor eax, eax
    rep stosb
    
    pop edi
    pop ecx
    pop eax
    ret
ClearLogBuffer ENDP

;------------------------------------------------------------
; AppendString - Append a null-terminated string to buffer
; Receives: ESI = current buffer position, EDI = string to append
; Returns: ESI = new buffer position
;------------------------------------------------------------
AppendString PROC
    push eax
    
AppendLoop:
    mov al, [edi]
    cmp al, 0
    je AppendDone
    mov [esi], al
    inc esi
    inc edi
    jmp AppendLoop
    
AppendDone:
    pop eax
    ret
AppendString ENDP

;------------------------------------------------------------
; AppendHex - Append a hex value to buffer (with 0x prefix)
; Receives: ESI = current buffer position, EAX = value
; Returns: ESI = new buffer position
;------------------------------------------------------------
AppendHex PROC
    push eax
    push ebx
    push ecx
    push edx
    
    ; Add "0x" prefix
    mov byte ptr [esi], '0'
    inc esi
    mov byte ptr [esi], 'x'
    inc esi
    
    ; Convert EAX to hex string
    mov ecx, 8  ; 8 hex digits
    
HexLoop:
    rol eax, 4
    mov ebx, eax
    and ebx, 0Fh
    mov dl, hexDigits[ebx]
    mov [esi], dl
    inc esi
    dec ecx
    jnz HexLoop
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
AppendHex ENDP

;------------------------------------------------------------
; WriteLogBuffer - Write log buffer to file
; Receives: Nothing
; Returns: Nothing
;------------------------------------------------------------
WriteLogBuffer PROC
    push eax
    push edx
    push ecx
    
    ; Get buffer length
    mov edi, OFFSET logBuffer
    xor ecx, ecx
CountLoop:
    cmp byte ptr [edi], 0
    je CountDone
    inc ecx
    inc edi
    jmp CountLoop
    
CountDone:
    ; Write to file
    mov eax, logFileHandle
    mov edx, OFFSET logBuffer
    call WriteToFile
    
    pop ecx
    pop edx
    pop eax
    ret
WriteLogBuffer ENDP
