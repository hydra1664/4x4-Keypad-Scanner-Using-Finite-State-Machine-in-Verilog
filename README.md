# 4x4 Keypad Scanner Using Finite State Machine

This project implements a 4x4 matrix keypad scanner in Verilog using a finite state machine (FSM). The design continuously scans the keypad, detects key presses, and outputs a 4-bit key code along with a validity signal.

All project files are organized inside the `Main` folder. Simulation was carried out using a testbench, and results were verified with GTKWave.

## Features
- 4x4 keypad matrix support (16 keys total)
- FSM-based row-by-row scanning
- 4-bit key code output for each key
- Validity flag for key press detection
- Clean Verilog implementation with testbench support

## Files in Main folder
- `keypad_scanner.v` – Verilog module for the FSM-based keypad scanner  
- `keypad_top.v` – Top-level module integration  
- `keypad_scanner_tb.v` – Testbench for simulation  
- `keypad_scanner.vcd` – Simulation output dump file  
- `keypad_sim` – GTKWave simulation file  

## Simulation
Simulation was done using the testbench which generated clock, reset, and simulated key presses by controlling the column inputs. The FSM cycles through all rows, detects key presses, and outputs the correct code.

### Example simulation results
- Pressing key `1` → Output `0001`  
- Pressing key `5` → Output `0101`  
- Pressing key `9` → Output `1001`  
- Pressing key `A` → Output `1010`  
- Pressing key `0` → Output `0000`  
- Pressing key `#` → Output `1111`  

## GTKWave Screenshot
The simulation waveform was analyzed using GTKWave. Below is the screenshot showing proper key detection and state transitions:

GTKWave Simulation ![image](https://github.com/user-attachments/assets/8d0e3e9f-2b0e-4177-88e7-45f8892aed02)


## Key Outcomes
- FSM transitions work reliably across all states  
- Key codes match expected outputs  
- Validity signal asserts correctly during key presses  
- No false detections in simulation  

## Future Improvements
- Add hardware-level debouncing  
- Enhance design for multi-key detection  
- Integrate with a display (LCD/7-segment) for direct key output  
