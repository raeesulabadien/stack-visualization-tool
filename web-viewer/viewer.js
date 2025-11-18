// viewer.js - Stack Visualization Log Parser and Animator
// Author: Stack Visualization Tool Project
// Description: Parses CSV log files and animates stack operations

class StackVisualizer {
    constructor() {
        this.operations = [];
        this.currentStep = -1;
        this.isPlaying = false;
        this.playInterval = null;
        this.speed = 500; // milliseconds
        
        this.initializeElements();
        this.attachEventListeners();
    }

    initializeElements() {
        // File controls
        this.fileInput = document.getElementById('fileInput');
        this.loadBtn = document.getElementById('loadBtn');
        this.fileInfo = document.getElementById('fileInfo');

        // Playback controls
        this.firstBtn = document.getElementById('firstBtn');
        this.prevBtn = document.getElementById('prevBtn');
        this.playBtn = document.getElementById('playBtn');
        this.pauseBtn = document.getElementById('pauseBtn');
        this.nextBtn = document.getElementById('nextBtn');
        this.lastBtn = document.getElementById('lastBtn');
        this.speedSlider = document.getElementById('speedSlider');
        this.speedValue = document.getElementById('speedValue');

        // Status display
        this.currentOpDisplay = document.getElementById('currentOp');
        this.stepInfoDisplay = document.getElementById('stepInfo');
        this.espValueDisplay = document.getElementById('espValue');
        this.ebpValueDisplay = document.getElementById('ebpValue');

        // Visualization
        this.stackDisplay = document.getElementById('stackDisplay');
        this.espPointer = document.getElementById('espPointer');
        this.ebpPointer = document.getElementById('ebpPointer');
        this.operationLog = document.getElementById('operationLog');
    }

    attachEventListeners() {
        // File input
        this.fileInput.addEventListener('change', () => {
            this.loadBtn.disabled = !this.fileInput.files.length;
            if (this.fileInput.files.length) {
                this.fileInfo.textContent = `Selected: ${this.fileInput.files[0].name}`;
            }
        });

        this.loadBtn.addEventListener('click', () => this.loadFile());

        // Playback controls
        this.firstBtn.addEventListener('click', () => this.goToFirst());
        this.prevBtn.addEventListener('click', () => this.goToPrevious());
        this.playBtn.addEventListener('click', () => this.play());
        this.pauseBtn.addEventListener('click', () => this.pause());
        this.nextBtn.addEventListener('click', () => this.goToNext());
        this.lastBtn.addEventListener('click', () => this.goToLast());

        // Speed control
        this.speedSlider.addEventListener('input', (e) => {
            this.speed = parseInt(e.target.value);
            this.speedValue.textContent = `${this.speed}ms`;
            if (this.isPlaying) {
                this.pause();
                this.play();
            }
        });
    }

    async loadFile() {
        const file = this.fileInput.files[0];
        if (!file) return;

        try {
            const text = await file.text();
            this.parseLogFile(text);
            this.enableControls();
            this.goToFirst();
            this.fileInfo.textContent = `Loaded: ${this.operations.length} operations`;
        } catch (error) {
            console.error('Error loading file:', error);
            this.fileInfo.textContent = 'Error loading file';
        }
    }

    parseLogFile(text) {
        this.operations = [];
        const lines = text.split('\n');

        for (const line of lines) {
            if (!line.trim()) continue;

            // Parse CSV: OPERATION,VALUE,ESP=address,EBP=address
            const parts = line.split(',');
            if (parts.length < 4) continue;

            const operation = parts[0].trim();
            const value = parts[1].trim();
            const espPart = parts[2].trim();
            const ebpPart = parts[3].trim();

            // Extract ESP and EBP values
            const espMatch = espPart.match(/ESP=(.+)/);
            const ebpMatch = ebpPart.match(/EBP=(.+)/);

            if (espMatch && ebpMatch) {
                this.operations.push({
                    operation,
                    value,
                    esp: espMatch[1],
                    ebp: ebpMatch[1]
                });
            }
        }

        this.buildOperationLog();
    }

    buildOperationLog() {
        this.operationLog.innerHTML = '';
        
        this.operations.forEach((op, index) => {
            const entry = document.createElement('div');
            entry.className = `log-entry ${op.operation}`;
            entry.dataset.index = index;
            entry.textContent = `${index + 1}. ${op.operation} ${op.value} | ESP=${op.esp} EBP=${op.ebp}`;
            
            entry.addEventListener('click', () => {
                this.pause();
                this.goToStep(index);
            });
            
            this.operationLog.appendChild(entry);
        });
    }

    enableControls() {
        this.firstBtn.disabled = false;
        this.prevBtn.disabled = false;
        this.playBtn.disabled = false;
        this.nextBtn.disabled = false;
        this.lastBtn.disabled = false;
    }

    goToFirst() {
        this.pause();
        this.goToStep(0);
    }

    goToPrevious() {
        this.pause();
        if (this.currentStep > 0) {
            this.goToStep(this.currentStep - 1);
        }
    }

    goToNext() {
        if (this.currentStep < this.operations.length - 1) {
            this.goToStep(this.currentStep + 1);
        } else {
            this.pause();
        }
    }

    goToLast() {
        this.pause();
        this.goToStep(this.operations.length - 1);
    }

    goToStep(step) {
        if (step < 0 || step >= this.operations.length) return;

        this.currentStep = step;
        this.updateDisplay();
        this.highlightCurrentLogEntry();
    }

    play() {
        if (this.isPlaying) return;
        if (this.currentStep >= this.operations.length - 1) {
            this.goToFirst();
        }

        this.isPlaying = true;
        this.playBtn.style.display = 'none';
        this.pauseBtn.style.display = 'inline-block';
        this.pauseBtn.disabled = false;

        this.playInterval = setInterval(() => {
            this.goToNext();
            if (this.currentStep >= this.operations.length - 1) {
                this.pause();
            }
        }, this.speed);
    }

    pause() {
        this.isPlaying = false;
        this.playBtn.style.display = 'inline-block';
        this.pauseBtn.style.display = 'none';

        if (this.playInterval) {
            clearInterval(this.playInterval);
            this.playInterval = null;
        }
    }

    updateDisplay() {
        const op = this.operations[this.currentStep];
        if (!op) return;

        // Update status
        this.currentOpDisplay.textContent = `${op.operation} ${op.value}`;
        this.stepInfoDisplay.textContent = `${this.currentStep + 1} / ${this.operations.length}`;
        this.espValueDisplay.textContent = op.esp;
        this.ebpValueDisplay.textContent = op.ebp;

        // Update stack visualization
        this.renderStack(op);
    }

    renderStack(currentOp) {
        // Build stack state up to current operation
        const stackState = this.buildStackState(this.currentStep);
        
        this.stackDisplay.innerHTML = '';

        if (stackState.length === 0) {
            const empty = document.createElement('div');
            empty.className = 'empty-state';
            empty.innerHTML = '<p>Stack is empty</p>';
            this.stackDisplay.appendChild(empty);
            return;
        }

        // Render stack items (show top 32 entries)
        const displayCount = Math.min(stackState.length, 32);
        for (let i = 0; i < displayCount; i++) {
            const item = stackState[i];
            const stackItem = this.createStackItem(item, currentOp.esp, currentOp.ebp);
            this.stackDisplay.appendChild(stackItem);
        }

        // Update pointer positions
        this.updatePointers(currentOp.esp, currentOp.ebp);
    }

    buildStackState(upToStep) {
        // Simulate stack from beginning to current step
        const stack = [];
        const stackBase = 0x00100000; // Simulated base address
        let esp = stackBase;

        for (let i = 0; i <= upToStep; i++) {
            const op = this.operations[i];
            
            switch (op.operation) {
                case 'PUSH':
                    esp -= 4;
                    stack.push({ address: esp, value: op.value });
                    break;
                case 'POP':
                    if (stack.length > 0) {
                        stack.pop();
                        esp += 4;
                    }
                    break;
                case 'CALL':
                    esp -= 4;
                    stack.push({ address: esp, value: op.value, type: 'return' });
                    break;
                case 'RET':
                    if (stack.length > 0) {
                        stack.pop();
                        esp += 4;
                    }
                    break;
            }
        }

        return stack.reverse(); // Top of stack first
    }

    createStackItem(item, currentESP, currentEBP) {
        const div = document.createElement('div');
        div.className = 'stack-item';

        const espNum = this.parseHexValue(currentESP);
        const ebpNum = this.parseHexValue(currentEBP);
        const itemAddr = item.address;

        // Highlight if ESP or EBP points here
        const isESP = (itemAddr === espNum);
        const isEBP = (itemAddr === ebpNum);

        if (isESP && isEBP) {
            div.classList.add('both-highlight');
        } else if (isESP) {
            div.classList.add('esp-highlight');
        } else if (isEBP) {
            div.classList.add('ebp-highlight');
        }

        // Address
        const address = document.createElement('span');
        address.className = 'stack-address';
        address.textContent = this.formatAddress(itemAddr);

        // Value
        const value = document.createElement('span');
        value.className = 'stack-value';
        value.textContent = item.value;

        // Indicator
        const indicator = document.createElement('span');
        indicator.className = 'stack-indicator';
        if (isESP && isEBP) {
            indicator.innerHTML = '<span class="esp-indicator">← ESP</span> <span class="ebp-indicator">← EBP</span>';
        } else if (isESP) {
            indicator.innerHTML = '<span class="esp-indicator">← ESP</span>';
        } else if (isEBP) {
            indicator.innerHTML = '<span class="ebp-indicator">← EBP</span>';
        } else if (item.type === 'return') {
            indicator.textContent = '(return address)';
        }

        div.appendChild(address);
        div.appendChild(value);
        div.appendChild(indicator);

        return div;
    }

    updatePointers(esp, ebp) {
        // Show pointers
        this.espPointer.style.display = 'flex';
        this.ebpPointer.style.display = 'flex';

        // Calculate positions (simplified)
        // In a real implementation, you'd calculate based on stack item positions
        this.espPointer.style.top = '20px';
        this.ebpPointer.style.top = '60px';
    }

    highlightCurrentLogEntry() {
        // Remove previous highlights
        const entries = this.operationLog.querySelectorAll('.log-entry');
        entries.forEach(entry => entry.classList.remove('current'));

        // Highlight current
        const currentEntry = this.operationLog.querySelector(`[data-index="${this.currentStep}"]`);
        if (currentEntry) {
            currentEntry.classList.add('current');
            currentEntry.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    }

    parseHexValue(hexStr) {
        // Parse hex string like "0x00100000"
        if (hexStr.startsWith('0x') || hexStr.startsWith('0X')) {
            return parseInt(hexStr.slice(2), 16);
        }
        return parseInt(hexStr, 16);
    }

    formatAddress(addr) {
        return '0x' + addr.toString(16).toUpperCase().padStart(8, '0');
    }
}

// Initialize visualizer when page loads
document.addEventListener('DOMContentLoaded', () => {
    new StackVisualizer();
});
