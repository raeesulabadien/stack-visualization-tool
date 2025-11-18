# Usage Examples

Step-by-step examples for using the Stack Visualization Tool.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Example 1: Simple Push/Pop](#example-1-simple-pushpop)
3. [Example 2: Factorial Calculation](#example-2-factorial-calculation)
4. [Example 3: Fibonacci Sequence](#example-3-fibonacci-sequence)
5. [Example 4: Nested Function Calls](#example-4-nested-function-calls)
6. [Example 5: Local Variables](#example-5-local-variables)
7. [Creating Custom Programs](#creating-custom-programs)
8. [Debugging with the Visualizer](#debugging-with-the-visualizer)

## Quick Start

### Complete Workflow

**Step 1: Build the Main Simulator**
```batch
cd assembly
Build.bat StackSim.asm
```

**Step 2: Run Interactive Menu**
```batch
StackSim.exe
```

**Step 3: Try a Manual Operation**
```
Menu: Choose option 1 (Push Value)
Enter value: 42
Observe: Console shows colored output
Check: output/stacklog.txt created
```

**Step 4: Visualize in Browser**
```
1. Open web-viewer/index.html
2. Click "Choose File"
3. Select output/stacklog.txt
4. Click "Load File"
5. Click "Play" to watch animation
```

## Example 1: Simple Push/Pop

### Objective
Understand basic stack operations without functions.

### Assembly Code

Already in StackSim.asm menu options 1 and 2.

### Steps

**1. Run the Simulator:**
```batch
cd assembly
StackSim.exe
```

**2. Perform Operations:**
```
Choose: 1 (Push Value)
Enter: 10
[Observe yellow "PUSH: 0x0000000A" message]

Choose: 1 (Push Value)
Enter: 20
[Stack now has two values]

Choose: 1 (Push Value)
Enter: 30
[Stack now has three values]

Choose: 5 (Display Stack)
[See all three values with ESP/EBP indicators]

Choose: 2 (Pop Value)
[Returns 30]

Choose: 2 (Pop Value)
[Returns 20]

Choose: 2 (Pop Value)
[Returns 10]

Choose: 0 (Exit)
```

**3. Visualize:**
```
Open web-viewer/index.html
Load output/stacklog.txt
Watch the stack grow and shrink
```

### What to Observe

**Console Output:**
- Color-coded operations
- ESP decrements on PUSH (e.g., 0x1000 → 0xFFC → 0xFF8)
- ESP increments on POP (e.g., 0xFF8 → 0xFFC → 0x1000)
- Values stored and retrieved in LIFO order

**Web Visualization:**
- Stack items appear from top
- Blue highlight follows ESP
- Items disappear when popped
- Operation log shows sequence

### Key Concepts

✅ **LIFO Principle:** Last In, First Out
✅ **Stack Growth:** Downward (decreasing addresses)
✅ **ESP Movement:** -4 bytes per PUSH, +4 bytes per POP

## Example 2: Factorial Calculation

### Objective
See recursive function calls in action.

### Build and Run

**1. Build:**
```batch
cd assembly
Build.bat Programs\Factorial.asm
```

**2. Run:**
```batch
Factorial.exe
Enter N: 5
```

**3. Expected Output:**
```
Computing 5!...
Result: 120
```

### Understanding the Recursion

**Call Sequence for fact(5):**
```
fact(5) →
  fact(4) →
    fact(3) →
      fact(2) →
        fact(1) → returns 1
      returns 2 (2 * 1)
    returns 6 (3 * 2)
  returns 24 (4 * 6)
returns 120 (5 * 24)
```

### Stack Evolution

**During Call to fact(5):**
```
Initial:
┌──────────────┐
│ (empty)      │ ← ESP, EBP
└──────────────┘

After CALL fact(5):
┌──────────────┐
│ 0x22222222   │ ← Return address
│ Old EBP      │ ← EBP
│ 5            │ ← N (parameter)
│ 5            │ ← Local copy
└──────────────┘ ← ESP

After CALL fact(4):
┌──────────────┐
│ 0x22222222   │ ← fact(5) return
│ Old EBP      │ ← fact(5) EBP
│ 5            │
│ 5            │
│ 0x22222222   │ ← fact(4) return
│ Old EBP      │ ← fact(4) EBP
│ 4            │
│ 4            │ ← fact(4) locals
└──────────────┘ ← ESP

... continues deeper ...

Deepest (fact(1)):
[5 frames stacked]

Returns unwinding:
[Frames destroyed one by one]
[Results multiply on return path]
```

### What to Observe

**Console:**
1. Multiple NEWFRAME operations (one per call)
2. PUSH operations for parameters and locals
3. Deepening stack (ESP decreases)
4. ENDFRAME operations on return
5. Stack shrinking (ESP increases)

**Web Viewer:**
1. Load output/stacklog.txt
2. Step through slowly (2000ms speed)
3. Watch frames build up
4. Note return addresses
5. See EBP chain linking frames
6. Observe frame destruction

### Key Concepts

✅ **Recursion Depth:** Each call adds a frame
✅ **Base Case:** Stops the recursion (fact(1))
✅ **Return Path:** Computation happens unwinding
✅ **Stack Frames:** Isolated variable spaces

## Example 3: Fibonacci Sequence

### Objective
Observe multiple recursive calls per function.

### Build and Run

**1. Build:**
```batch
cd assembly
Build.bat Programs\Fibonacci.asm
```

**2. Run:**
```batch
Fibonacci.exe
Enter N: 4
```

**3. Expected Output:**
```
Computing Fibonacci(4)...
Result: 3
```

### Understanding Multiple Recursion

**Call Tree for fib(4):**
```
                    fib(4)
                   /      \
               fib(3)    fib(2)
              /     \    /     \
          fib(2) fib(1) fib(1) fib(0)
         /    \
     fib(1) fib(0)
     
Results:
fib(0) = 0
fib(1) = 1
fib(2) = fib(1) + fib(0) = 1 + 0 = 1
fib(3) = fib(2) + fib(1) = 1 + 1 = 2
fib(4) = fib(3) + fib(2) = 2 + 1 = 3
```

### Stack Complexity

**Key Difference from Factorial:**
- Factorial: Single recursive call per function
- Fibonacci: TWO recursive calls per function

**Stack Growth:**
```
fib(4) calls fib(3):
  fib(3) calls fib(2):
    fib(2) calls fib(1):
      [Base case, return 1]
    fib(2) calls fib(0):
      [Base case, return 0]
    [fib(2) returns]
  fib(3) calls fib(1):
    [Base case, return 1]
  [fib(3) returns]
fib(4) calls fib(2):
  ... similar pattern ...
[fib(4) returns final result]
```

### What to Observe

**Important Points:**
1. Stack grows and shrinks multiple times
2. Same function called at different depths
3. Multiple return addresses per level
4. Frame creation and destruction happen frequently

**Web Viewer Analysis:**
1. Load the log file
2. Count CALL operations (many!)
3. Notice duplicate values (same N, different times)
4. See branching pattern
5. Observe how results combine

### Performance Note

⚠️ **Fibonacci is exponential!**
- fib(5) → ~15 calls
- fib(10) → ~177 calls
- fib(15) → ~1973 calls

Start small (N ≤ 6) for clear visualization.

### Key Concepts

✅ **Binary Recursion:** Each call makes two more calls
✅ **Exponential Growth:** Stack operations multiply
✅ **Redundant Computation:** Same values calculated multiple times
✅ **Stack Reuse:** Frames created and destroyed repeatedly

## Example 4: Nested Function Calls

### Objective
Understand sequential function calls (A → B → C).

### Build and Run

**1. Build:**
```batch
cd assembly
Build.bat Programs\NestedCalls.asm
```

**2. Run:**
```batch
NestedCalls.exe
```

**3. Expected Output:**
```
Main calling FunctionA...
In FunctionA, calling FunctionB...
In FunctionB, calling FunctionC...
In FunctionC (deepest level)
Returning through call chain...
Final result: 215
```

### Call Chain

```
main
  ↓ call FunctionA(100)
  FunctionA
    ↓ call FunctionB(150)
    FunctionB
      ↓ call FunctionC(175)
      FunctionC
        ↓ computations
        ← return 180
      ← return 195
    ← return 215
  ← final result
```

### Stack at Deepest Point

**When FunctionC is executing:**
```
┌─────────────────────┐
│ main's frame        │
├─────────────────────┤
│ main's ret addr     │
│ old EBP             │
│ param: 100          │
│ local: 10           │
├─────────────────────┤
│ FunctionA ret addr  │
│ old EBP             │
│ param: 150          │
│ local: 20           │
│ local: 30           │
├─────────────────────┤
│ FunctionB ret addr  │
│ old EBP             │ ← EBP
│ param: 175          │
│ local: 40           │
│ local: 50           │
│ local: 60           │ ← ESP
└─────────────────────┘
```

### What to Observe

**Stack Building:**
1. Each function adds parameters
2. Each function adds locals
3. Return addresses separate frames
4. EBP values form a chain

**Stack Unwinding:**
1. FunctionC cleans locals
2. FunctionC destroys frame
3. FunctionB resumes, cleans up
4. Pattern continues to main

**Web Viewer:**
1. Three distinct frame creations
2. Clear EBP chain visible
3. Green highlights show EBP positions
4. Watch frame destruction in reverse order

### Key Concepts

✅ **Sequential Calls:** Unlike recursion, different functions
✅ **Frame Chain:** EBP links frames together
✅ **Local Isolation:** Each function has its own locals
✅ **Orderly Cleanup:** LIFO destruction

## Example 5: Local Variables

### Objective
See how local variables are managed on the stack.

### Build and Run

**1. Build:**
```batch
cd assembly
Build.bat Programs\LocalVars.asm
```

**2. Run:**
```batch
LocalVars.exe
```

**3. Expected Output:**
```
Calling function with parameters...
Inside function, allocating locals:
  Local var1 = 20
  Local var2 = 75
  Local var3 = 95
  Local var4 = 47
Computing with local variables...
Cleaning up local variables...
Function returned: 47
```

### Variable Allocation

**ComputeWithLocals receives:**
- param1 = 10 (at [ebp+8])
- param2 = 25 (at [ebp+12])

**Allocates locals:**
- var1 = param1 * 2 = 20
- var2 = param2 * 3 = 75
- var3 = var1 + var2 = 95
- var4 = (var1 + var2) / 2 = 47

### Stack Layout During Execution

```
┌─────────────────────┐
│ main's frame        │
├─────────────────────┤
│ return address      │
├─────────────────────┤
│ old EBP             │ ← EBP
├─────────────────────┤
│ param2 (25)         │ [ebp+12]
├─────────────────────┤
│ param1 (10)         │ [ebp+8]
├─────────────────────┤
│ param1 copy (10)    │
├─────────────────────┤
│ param2 copy (25)    │
├─────────────────────┤
│ var1 (20)           │
├─────────────────────┤
│ var2 (75)           │
├─────────────────────┤
│ var3 (95)           │
├─────────────────────┤
│ var4 (47)           │ ← ESP
└─────────────────────┘
```

### What to Observe

**Variable Lifetime:**
1. Parameters passed by caller
2. Function copies to stack
3. Locals allocated as needed
4. Computations use stack values
5. All cleaned up before return

**Accessing Variables:**
- Parameters: [ebp+8], [ebp+12], etc.
- Locals: [ebp-4], [ebp-8], etc. (or via PopSim)

**Memory Management:**
- Automatic allocation (PUSH)
- Automatic deallocation (POP)
- No manual memory management
- Stack cleanup on return

### Key Concepts

✅ **Automatic Storage:** Stack manages lifetime
✅ **Function Scope:** Variables local to function
✅ **Parameter Passing:** Via stack
✅ **Cleanup:** Automatic when function exits

## Creating Custom Programs

### Template

```assembly
INCLUDE Irvine32.inc

; Import stack operations
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
    ; Your data here
    msgTitle BYTE "=== My Custom Demo ===", 0Dh, 0Ah, 0

.code
main PROC
    ; Initialize
    call InitLogger
    
    ; Display title
    mov edx, OFFSET msgTitle
    call WriteString
    
    ; Your code here
    ; Use PushSim, PopSim, etc.
    
    ; Example: Simple function call
    push 42
    call MyFunction
    
    ; Display result
    call WriteDec
    call Crlf
    
    ; Cleanup
    call CloseLogger
    exit
main ENDP

MyFunction PROC
    push ebp
    mov ebp, esp
    
    ; Simulate function entry
    push 11111111h
    call CallSim
    call NewFrameSim
    
    ; Get parameter
    mov eax, [ebp + 8]
    
    ; Push to simulated stack
    push eax
    call PushSim
    
    ; Your logic here
    add eax, 10
    
    ; Pop from simulated stack
    call PopSim
    
    ; Simulate function exit
    call EndFrameSim
    call RetSim
    
    pop ebp
    ret 4
MyFunction ENDP

END main
```

### Building Your Program

```batch
cd assembly/Programs
..\Build.bat YourProgram.asm
YourProgram.exe
```

### Tips for Custom Programs

**1. Always Initialize/Close Logger:**
```assembly
call InitLogger
; ... your code ...
call CloseLogger
```

**2. Match Real and Simulated Operations:**
```assembly
push eax        ; Real stack
call PushSim    ; Simulated stack
```

**3. Use Descriptive Return Addresses:**
```assembly
push 0AAAA0001h  ; Function A, call 1
push 0BBBB0002h  ; Function B, call 2
```

**4. Comment Your Code:**
```assembly
; Calculate factorial of N
; Input: N in [ebp+8]
; Output: EAX = N!
```

**5. Test with Small Values:**
```assembly
; Start with N=3, then increase
; Deep recursion can overflow
```

## Debugging with the Visualizer

### Common Issues and Solutions

**Issue: Stack Overflow**

**Symptoms:**
- "ERROR: Stack Overflow!" message
- Program crashes
- Garbled visualization

**Debug:**
1. Load log file up to error
2. Count stack depth
3. Reduce recursion depth
4. Increase SimStack size if needed

**Issue: Incorrect Results**

**Symptoms:**
- Wrong output value
- Unexpected stack state

**Debug:**
1. Step through operations slowly
2. Compare expected vs actual stack
3. Check PUSH/POP matching
4. Verify parameter passing

**Issue: Memory Corruption**

**Symptoms:**
- Random crashes
- Strange values in stack

**Debug:**
1. Check stack bounds
2. Verify POP doesn't underflow
3. Ensure frame cleanup
4. Match CALL with RET

### Debugging Workflow

**1. Reproduce the Issue:**
```batch
Run program with specific input
Note the error or incorrect result
```

**2. Examine Console Output:**
```
Review colored operation messages
Check ESP/EBP values
Look for overflow/underflow
```

**3. Load in Web Viewer:**
```
Open visualization
Step through operations
Find where things go wrong
```

**4. Compare Expected vs Actual:**
```
Draw expected stack state on paper
Compare with visualizer
Identify divergence point
```

**5. Fix and Verify:**
```
Modify assembly code
Rebuild and run
Visualize again
Confirm fix
```

### Advanced Debugging

**Compare Two Runs:**
1. Run with working input → save log as good.txt
2. Run with failing input → save log as bad.txt
3. Compare files side-by-side
4. Find first difference

**Instrument Your Code:**
```assembly
; Add display calls at key points
call DisplayStack

; Add messages
mov edx, OFFSET debugMsg
call WriteString
```

**Validate Invariants:**
```assembly
; Check: ESP always 4-byte aligned
mov eax, SimESP
and eax, 3
jnz ERROR_ALIGNMENT
```

## Best Practices

### General

1. **Start Simple:** Master basic operations before complex programs
2. **Small Steps:** Test incrementally, visualize often
3. **Document:** Comment your code thoroughly
4. **Consistent Style:** Use clear naming conventions
5. **Error Handling:** Check bounds, handle edge cases

### Performance

1. **Limit Recursion:** Deep recursion is slow and hard to visualize
2. **Use Memoization:** Cache results in real programs
3. **Optimize Hot Paths:** Profile and improve critical sections

### Learning

1. **Predict Then Verify:** Guess stack state, then check
2. **Experiment:** Modify demo programs
3. **Compare:** Run different inputs, observe patterns
4. **Teach Others:** Explaining solidifies understanding

## Summary

You now have complete examples for:
- ✅ Basic stack operations
- ✅ Recursive functions (factorial, fibonacci)
- ✅ Nested function calls
- ✅ Local variable management
- ✅ Custom program creation
- ✅ Debugging techniques

**Next Steps:**
1. Try all demo programs
2. Create your own algorithms
3. Experiment with different patterns
4. Share your discoveries!

---

**Resources:**
- [ASSEMBLY_GUIDE.md](ASSEMBLY_GUIDE.md) - Deep technical details
- [WEB_GUIDE.md](WEB_GUIDE.md) - Viewer customization
