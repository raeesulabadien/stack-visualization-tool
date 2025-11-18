# Assembly Code Guide

Complete guide to understanding the Stack Visualization Tool assembly code.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Core Modules](#core-modules)
4. [Stack Operations](#stack-operations)
5. [Demo Programs](#demo-programs)
6. [Building and Running](#building-and-running)

## Overview

The Stack Visualization Tool is implemented in x86 Assembly language using:
- **MASM (Microsoft Macro Assembler)**
- **Irvine32 Library** for I/O operations
- **Modular design** with separate files for different concerns

### Design Philosophy

- **Simulated Stack**: Instead of using the real CPU stack, we maintain a simulated stack in memory
- **Dual Operation**: Each stack operation happens on both the real stack (for program execution) and simulated stack (for visualization)
- **Logging**: All operations are logged to a CSV file for web visualization
- **Console Display**: Real-time colored console output shows operations as they happen

## Architecture

```
┌─────────────────────────────────────────┐
│         StackSim.asm (Main)             │
│  - Simulated Stack Array                │
│  - ESP/EBP Simulation                   │
│  - Stack Operations                     │
│  - Demo Programs                        │
└─────────┬───────────────────────────────┘
          │
          ├──────────────┬─────────────────┐
          │              │                 │
    ┌─────▼─────┐  ┌────▼────┐   ┌───────▼────────┐
    │Display.asm│  │Logger   │   │Programs/       │
    │           │  │.asm     │   │ - Fibonacci    │
    │- Console  │  │         │   │ - Factorial    │
    │  Output   │  │- File   │   │ - NestedCalls  │
    │- Colors   │  │  I/O    │   │ - LocalVars    │
    └───────────┘  └─────────┘   └────────────────┘
```

## Core Modules

### StackSim.asm

The main module containing the stack simulator and demo integration.

#### Key Data Structures

```assembly
SimStack DWORD 256 DUP(0)      ; Simulated stack (256 DWORDs = 1024 bytes)
SimESP DWORD OFFSET SimStack + (255 * 4)  ; Stack pointer (top of stack)
SimEBP DWORD OFFSET SimStack + (255 * 4)  ; Base pointer
```

**Why 256 DWORDs?**
- Each DWORD = 4 bytes
- Total = 1024 bytes of stack space
- Enough for deep recursion and complex operations
- Easy to visualize (powers of 2)

**Stack Growth Direction:**
- Stack grows **downward** (decreasing addresses)
- ESP starts at highest address
- PUSH decrements ESP, POP increments ESP

#### Stack Operation Procedures

##### PushSim
```assembly
PushSim PROC
    ; 1. Check for overflow
    ; 2. Decrement SimESP by 4
    ; 3. Store value at new SimESP
    ; 4. Display operation
    ; 5. Log to file
PushSim ENDP
```

**Call Convention:**
```assembly
push 42        ; Push value onto real stack
call PushSim   ; Simulate push operation
```

##### PopSim
```assembly
PopSim PROC
    ; 1. Check for underflow
    ; 2. Load value from current SimESP
    ; 3. Display operation
    ; 4. Log to file
    ; 5. Increment SimESP by 4
    ; Returns: EAX = popped value
PopSim ENDP
```

**Call Convention:**
```assembly
call PopSim    ; EAX will contain popped value
```

##### CallSim
```assembly
CallSim PROC
    ; 1. Get return address parameter
    ; 2. Push return address onto simulated stack
    ; 3. Log CALL operation
CallSim ENDP
```

**Usage:**
```assembly
push 12345678h    ; Simulated return address
call CallSim
```

##### RetSim
```assembly
RetSim PROC
    ; 1. Pop return address from simulated stack
    ; 2. Log RET operation
    ; Returns: EAX = return address
RetSim ENDP
```

##### NewFrameSim
```assembly
NewFrameSim PROC
    ; 1. Push old EBP onto simulated stack
    ; 2. Set SimEBP = SimESP (new frame base)
    ; 3. Log NEW FRAME operation
NewFrameSim ENDP
```

**Call Convention:**
```assembly
; At function entry:
push ebp           ; Real stack
mov ebp, esp
call NewFrameSim   ; Simulated stack
```

##### EndFrameSim
```assembly
EndFrameSim PROC
    ; 1. Restore SimESP from SimEBP
    ; 2. Pop old EBP from simulated stack
    ; 3. Log END FRAME operation
EndFrameSim ENDP
```

**Call Convention:**
```assembly
; At function exit:
call EndFrameSim   ; Simulated stack
pop ebp            ; Real stack
ret
```

### Display.asm

Provides colored console output for visual feedback.

#### Color Scheme

| Operation | Color | Purpose |
|-----------|-------|---------|
| PUSH/POP | Yellow | Operation names |
| Values | Cyan | Pushed/popped values |
| CALL/RET | Light Green | Function calls |
| NEWFRAME/ENDFRAME | Light Magenta | Frame operations |
| ESP/EBP | Light Gray | Register values |

#### Key Procedures

##### DisplayPush
```assembly
DisplayPush PROC
    ; Format: "PUSH: 0x00000042  ESP=0x... EBP=0x..."
    ; Yellow for "PUSH:", Cyan for value
DisplayPush ENDP
```

##### DisplayStack
```assembly
DisplayStack PROC
    ; Shows top 32 stack entries
    ; Highlights ESP and EBP locations
    ; Format: Address: 0x... Value: 0x... <-- ESP/EBP
DisplayStack ENDP
```

### Logger.asm

Handles file logging for web visualization.

#### Log Format

CSV format with 4 fields:
```
OPERATION,VALUE,ESP=address,EBP=address
```

**Example:**
```
PUSH,0x0000002A,ESP=0x00100FFC,EBP=0x00101000
POP,0x0000002A,ESP=0x00101000,EBP=0x00101000
CALL,0x12345678,ESP=0x00100FF8,EBP=0x00101000
NEWFRAME,0,ESP=0x00100FF4,EBP=0x00100FF8
```

#### Key Procedures

##### InitLogger
```assembly
InitLogger PROC
    ; Creates/opens output/stacklog.txt
    ; Overwrites if exists
InitLogger ENDP
```

##### LogPush, LogPop, LogCall, LogRet
```assembly
; Each builds a CSV line and writes to file
; Uses helper procedures:
; - ClearLogBuffer: Reset buffer
; - AppendString: Add string to buffer
; - AppendHex: Add hex value to buffer
; - WriteLogBuffer: Write buffer to file
```

## Stack Operations

### Understanding Stack Frames

A stack frame is a section of the stack for one function call.

```
High Memory
┌──────────────────┐
│  Caller's Frame  │
├──────────────────┤ ← Old EBP
│  Return Address  │ ← Pushed by CALL
├──────────────────┤ ← EBP (frame base)
│  Saved EBP       │
├──────────────────┤
│  Local Var 1     │
├──────────────────┤
│  Local Var 2     │
├──────────────────┤ ← ESP (stack top)
│      ...         │
Low Memory
```

### Stack Frame Lifecycle

#### Function Entry
```assembly
MyFunction PROC
    ; 1. CALL pushes return address
    push 12345678h      ; Simulated return address
    call CallSim
    
    ; 2. Create new frame
    push ebp            ; Save old base pointer
    mov ebp, esp        ; Set new base pointer
    call NewFrameSim
    
    ; 3. Allocate locals
    push 10             ; Local variable
    call PushSim
```

#### Function Body
```assembly
    ; Access parameters: [ebp + 8], [ebp + 12], ...
    ; Access locals: use PopSim/PushSim
    
    mov eax, [ebp + 8]  ; Get parameter
    push eax
    call PushSim        ; Store as local
```

#### Function Exit
```assembly
    ; 1. Clean up locals
    call PopSim         ; Pop local variables
    
    ; 2. Destroy frame
    call EndFrameSim
    
    ; 3. Return
    call RetSim
    pop ebp
    ret 4               ; Clean up parameters
MyFunction ENDP
```

## Demo Programs

### Fibonacci.asm

**Demonstrates:** Recursive function calls with multiple branches

**Algorithm:**
```
fib(0) = 0
fib(1) = 1
fib(n) = fib(n-1) + fib(n-2)
```

**Key Features:**
- Multiple recursive calls per function
- Base cases that stop recursion
- Stack grows deep with recursion depth
- Shows how results combine on return

**Stack Behavior:**
```
fib(3) calls:
  fib(2) calls:
    fib(1) → returns 1
    fib(0) → returns 0
    returns 1
  fib(1) → returns 1
  returns 2
```

### Factorial.asm

**Demonstrates:** Simple linear recursion

**Algorithm:**
```
0! = 1
1! = 1
n! = n * (n-1)!
```

**Key Features:**
- Single recursive call per function
- Multiplication on return path
- Simpler than Fibonacci
- Good for beginners

**Stack Behavior:**
```
fact(4) calls:
  fact(3) calls:
    fact(2) calls:
      fact(1) → returns 1
      returns 2 (2*1)
    returns 6 (3*2)
  returns 24 (4*6)
```

### NestedCalls.asm

**Demonstrates:** Sequential function calls (A → B → C)

**Features:**
- Three levels of function nesting
- Each function has multiple local variables
- Non-recursive (simpler to trace)
- Shows frame building and unwinding

**Call Chain:**
```
main → FunctionA → FunctionB → FunctionC
```

**Stack Evolution:**
1. Main's frame
2. Main + A's frame
3. Main + A + B's frame
4. Main + A + B + C's frame
5. Unwinding: back to Main

### LocalVars.asm

**Demonstrates:** Local variable management

**Features:**
- Multiple local variables in one function
- Parameter passing
- Variable allocation and deallocation
- Computations using locals

**Local Variables:**
```
var1 = param1 * 2
var2 = param2 * 3
var3 = var1 + var2
var4 = (var1 + var2) / 2
```

## Building and Running

### Prerequisites

1. **MASM32** or **Visual Studio with MASM**
2. **Irvine32 Library**
   - Download from http://asmirvine.com/
   - Install in MASM32\include and MASM32\lib

### Build Process

#### Using Build.bat (Recommended)

```batch
cd assembly
Build.bat StackSim.asm
```

**What it does:**
1. Assembles with `ml /c /coff`
2. Links with `link /SUBSYSTEM:CONSOLE`
3. Includes Irvine32.lib
4. Produces executable

#### Manual Build

```batch
ml /c /coff StackSim.asm
link /SUBSYSTEM:CONSOLE StackSim.obj Irvine32.lib kernel32.lib user32.lib
```

### Running

```batch
StackSim.exe
```

**Menu Options:**
1. Push Value - Manually push a value
2. Pop Value - Manually pop a value
3. Simulate Call - Simulate function call
4. Simulate Return - Simulate function return
5. Display Stack - Show current stack state
6. Run Fibonacci Demo - Execute Fibonacci(N)
7. Run Factorial Demo - Execute Factorial(N)
0. Exit

### Output

**Console:**
- Colored real-time operation display
- Stack state visualization
- Results of computations

**Log File:**
- Created in `output/stacklog.txt`
- CSV format for web viewer
- Complete operation history

## Advanced Topics

### Error Handling

#### Stack Overflow
```assembly
; Check before PUSH
mov eax, SimESP
sub eax, 4
cmp eax, StackBottom
jl StackOverflow
```

#### Stack Underflow
```assembly
; Check before POP
mov eax, SimESP
cmp eax, StackTop
jge StackUnderflow
```

### Optimization Considerations

1. **Real vs Simulated Stack:**
   - Real stack for program execution (fast)
   - Simulated stack for visualization (slower but observable)

2. **Dual Operations:**
   - Every stack operation happens twice
   - Overhead acceptable for educational purposes

3. **Logging:**
   - File I/O is expensive
   - Keep operations atomic
   - Buffer could be added for performance

### Extending the Simulator

#### Adding New Operations

1. **Create the simulation procedure**
```assembly
MyNewOp PROC
    ; Implement operation logic
    ; Call display procedure
    ; Call logging procedure
MyNewOp ENDP
```

2. **Add display procedure** in Display.asm
3. **Add logging procedure** in Logger.asm
4. **Update menu** in main

#### Creating New Demos

1. Create new .asm file in Programs/
2. EXTERN the simulation procedures
3. Implement your algorithm using stack operations
4. Build and test

**Template:**
```assembly
INCLUDE Irvine32.inc

EXTERN SimStack:DWORD
EXTERN SimESP:DWORD
EXTERN SimEBP:DWORD
EXTERN PushSim:PROC
; ... other EXTERNs

.data
    ; Your data

.code
main PROC
    call InitLogger
    
    ; Your code using stack operations
    
    call CloseLogger
    exit
main ENDP

; Your procedures

END main
```

## Troubleshooting

### Common Issues

**Build Errors:**
- Ensure Irvine32 library is installed
- Check INCLUDE and LIB paths
- Verify MASM32 installation

**Runtime Errors:**
- Stack overflow: Reduce recursion depth
- File errors: Check output/ directory exists
- Missing procedures: Verify all EXTERN declarations

**Visualization Issues:**
- Log file not created: Check file permissions
- Empty log: Ensure InitLogger/CloseLogger are called
- Corrupted log: Check CSV format

## Best Practices

1. **Always initialize the logger** before operations
2. **Always close the logger** before exit
3. **Check stack bounds** in custom operations
4. **Use consistent return conventions**
5. **Comment your code** for educational clarity
6. **Test with small values** before large recursion
7. **Display stack state** at key points for debugging

## Resources

- [MASM Documentation](https://docs.microsoft.com/en-us/cpp/assembler/masm/)
- [Irvine32 Library Manual](http://asmirvine.com/)
- [x86 Instruction Reference](https://www.felixcloutier.com/x86/)
- [Stack Frame Conventions](https://en.wikipedia.org/wiki/Call_stack)

---

**Next Steps:**
- Read [WEB_GUIDE.md](WEB_GUIDE.md) for web viewer usage
- See [EXAMPLES.md](EXAMPLES.md) for practical examples
