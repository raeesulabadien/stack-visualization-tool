# Stack Visualization Tool

A comprehensive educational tool for visualizing x86 assembly stack operations in real-time. This project combines low-level Assembly programming (MASM + Irvine32) with modern web technologies to provide an interactive learning experience for understanding stack frames, function calls, and memory management.

## 🚀 Quick Start (5 Minutes)

### Step 1: Build a Simple Example
```batch
cd assembly
ml /c /coff Programs\SimplePush.asm
link /SUBSYSTEM:CONSOLE Programs\SimplePush.obj Irvine32.lib kernel32.lib
```

### Step 2: Run It
```batch
Programs\SimplePush.exe
```
This creates `stacklog.txt` in the assembly folder.

### Step 3: Visualize
1. Open `web-viewer/index.html` in your browser
2. Click "Choose File" and select `assembly/stacklog.txt`
3. Click "Play" to see the stack animation!

### Example Output Format
```
PUSH,0x00000064,ESP=0x0012FF7C,EBP=0x0012FF80,SNAPSHOT=[0x00000064]
PUSH,0x000000C8,ESP=0x0012FF78,EBP=0x0012FF80,SNAPSHOT=[0x000000C8,0x00000064]
POP,0x000000C8,ESP=0x0012FF7C,EBP=0x0012FF80,SNAPSHOT=[0x00000064]
```

## 🎯 Features

- **Stack Simulator**: Complete x86-compatible stack implementation in Assembly
- **Multiple Stack Operations**: PUSH, POP, CALL, RET, and stack frame management
- **Real-time Logging**: All operations logged to files for playback
- **Web-based Visualizer**: Interactive animation of stack state changes
- **Colored Console Output**: Visual feedback during simulation
- **Demo Programs**: Pre-built examples demonstrating recursion and function calls

## 📁 Project Structure

```
stack-visualization-tool/
├── README.md                      # This file
├── assembly/                      # Assembly language implementation
│   ├── StackSim.asm              # Main stack simulator
│   ├── Display.asm               # Console display module
│   ├── Logger.asm                # File logging module
│   ├── Build.bat                 # Windows build script
│   └── Programs/                 # Demo programs
│       ├── Fibonacci.asm         # Fibonacci recursion
│       ├── Factorial.asm         # Factorial recursion
│       ├── NestedCalls.asm       # Nested function calls
│       └── LocalVars.asm         # Local variables demo
├── web-viewer/                    # Web-based visualization
│   ├── index.html                # Main HTML page
│   ├── style.css                 # Styling
│   ├── viewer.js                 # Log parser and animator
│   └── assets/                   # Visual assets
│       ├── esp-arrow.svg         # ESP pointer icon
│       └── ebp-arrow.svg         # EBP pointer icon
├── output/                        # Generated log files
│   └── .gitkeep
└── docs/                          # Documentation
    ├── ASSEMBLY_GUIDE.md         # Assembly code explanation
    ├── WEB_GUIDE.md              # Web viewer guide
    └── EXAMPLES.md               # Usage examples
```

## 🚀 Quick Start

### Prerequisites

- **Windows OS** (for Assembly programs)
- **MASM32** or **Visual Studio** with MASM
- **Irvine32 Library** ([Download here](http://asmirvine.com/))
- Modern web browser (for visualization)

### Building and Running

1. **Build the Assembly program:**
   ```batch
   cd assembly
   Build.bat StackSim.asm
   ```

2. **Run a demo program:**
   ```batch
   StackSim.exe
   ```

3. **View the visualization:**
   - Open `web-viewer/index.html` in a web browser
   - Click "Load Log File" and select a log from `output/`
   - Use playback controls to step through operations

## 🎓 Learning Path

1. **Start with the Documentation**
   - Read [`docs/ASSEMBLY_GUIDE.md`](docs/ASSEMBLY_GUIDE.md) for Assembly basics
   - Review [`docs/EXAMPLES.md`](docs/EXAMPLES.md) for usage scenarios

2. **Run Demo Programs**
   - Start with `Factorial.asm` for simple recursion
   - Progress to `Fibonacci.asm` for multiple recursive calls
   - Explore `LocalVars.asm` for stack frame understanding

3. **Visualize Operations**
   - Use the web viewer to see stack changes in real-time
   - Observe ESP and EBP pointer movements
   - Study stack frame structure

## 📊 Stack Operations

The simulator implements the following operations:

- **PushSim**: Push a value onto the stack
- **PopSim**: Pop a value from the stack
- **CallSim**: Simulate function call (save return address, create frame)
- **RetSim**: Simulate function return (restore frame, jump back)
- **NewFrameSim**: Create a new stack frame (save EBP, set new EBP)
- **EndFrameSim**: Destroy current stack frame (restore EBP)

## 🎨 Console Output

The console display uses colors to distinguish:
- **White**: Normal messages
- **Yellow**: Operation names
- **Cyan**: Values being pushed/popped
- **Green**: Success messages
- **Red**: Error messages

## 📝 Log File Format

Each operation is logged in CSV format:
```
OPERATION,VALUE,ESP=address,EBP=address
```

Example:
```
PUSH,42,ESP=0x00001000,EBP=0x00001004
POP,42,ESP=0x00001004,EBP=0x00001004
```

## 🌐 Web Viewer Features

- **File Upload**: Load log files via file picker
- **Step Controls**: Forward/backward navigation
- **Auto-play**: Automatic animation with adjustable speed
- **Visual Indicators**: Arrows showing ESP and EBP positions
- **Color Coding**: Different colors for different data types

## 🛠️ Development

### Modifying the Simulator

1. Edit the relevant `.asm` file
2. Run `Build.bat` to recompile
3. Test with demo programs
4. View results in web visualizer

### Creating New Demo Programs

1. Create a new `.asm` file in `assembly/Programs/`
2. Use the stack simulation procedures (PushSim, CallSim, etc.)
3. Build with `Build.bat`
4. Run and visualize

## 📚 Documentation

- **[ASSEMBLY_GUIDE.md](docs/ASSEMBLY_GUIDE.md)**: Detailed explanation of Assembly code
- **[WEB_GUIDE.md](docs/WEB_GUIDE.md)**: Web viewer usage and customization
- **[EXAMPLES.md](docs/EXAMPLES.md)**: Step-by-step usage examples

## 🤝 Contributing

This is an educational project. Contributions are welcome:
- Bug fixes
- New demo programs
- Improved visualizations
- Additional documentation

## 📄 License

This project is available for educational use.

## 🎯 Educational Goals

This tool helps students understand:
- How the x86 stack works at a low level
- Stack frame structure and management
- Function call conventions
- Recursion mechanics
- Memory addressing and pointers

## 🔗 Resources

- [MASM Documentation](https://docs.microsoft.com/en-us/cpp/assembler/masm/)
- [Irvine32 Library](http://asmirvine.com/)
- [x86 Assembly Guide](https://www.cs.virginia.edu/~evans/cs216/guides/x86.html)

## 💡 Tips

- Start with simple programs to understand basics
- Use the web viewer to visualize complex operations
- Compare console output with visual representation
- Experiment with modifying demo programs

---

**Happy Learning!** 🎉