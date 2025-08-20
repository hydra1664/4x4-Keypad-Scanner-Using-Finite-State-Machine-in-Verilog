// 4x4 Keypad Scanner using Finite State Machine
// This module scans a 4x4 matrix keypad and outputs the pressed key code

module keypad_scanner(
    input wire clk,           // System clock
    input wire reset,         // Reset signal (active high)
    input wire [3:0] col,     // Column inputs from keypad
    output reg [3:0] row,     // Row outputs to keypad
    output reg [3:0] key_code,// 4-bit code representing pressed key
    output reg key_valid      // High when a valid key press is detected
);

    // FSM State Definitions
    // We need 4 states to scan each row
    parameter SCAN_ROW0 = 2'b00;  // Scan row 0 (top row)
    parameter SCAN_ROW1 = 2'b01;  // Scan row 1
    parameter SCAN_ROW2 = 2'b10;  // Scan row 2  
    parameter SCAN_ROW3 = 2'b11;  // Scan row 3 (bottom row)
    
    // State register to hold current state
    reg [1:0] current_state, next_state;
    
    // Key mapping for 4x4 keypad
    // Standard keypad layout:
    //   Col0  Col1  Col2  Col3
    // Row0: 1    2    3    A
    // Row1: 4    5    6    B  
    // Row2: 7    8    9    C
    // Row3: *    0    #    D
    
    // Internal signals
    reg key_pressed;           // Flag indicating any key is pressed
    reg [3:0] detected_key;    // Temporary storage for detected key
    
    // Sequential logic - State register update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= SCAN_ROW0;  // Start from row 0 after reset
        end else begin
            current_state <= next_state;  // Move to next state
        end
    end
    
    // Combinational logic - Next state logic
    // This determines which state to go to next
    always @(*) begin
        case (current_state)
            SCAN_ROW0: next_state = SCAN_ROW1;  // After row 0, go to row 1
            SCAN_ROW1: next_state = SCAN_ROW2;  // After row 1, go to row 2
            SCAN_ROW2: next_state = SCAN_ROW3;  // After row 2, go to row 3
            SCAN_ROW3: next_state = SCAN_ROW0;  // After row 3, go back to row 0
            default:   next_state = SCAN_ROW0;  // Safety default
        endcase
    end
    
    // Output logic - Row scanning
    // We activate one row at a time by making it LOW (0)
    // while keeping other rows HIGH (1)
    always @(*) begin
        case (current_state)
            SCAN_ROW0: row = 4'b1110;  // Row 0 active (bit 0 = 0), others inactive
            SCAN_ROW1: row = 4'b1101;  // Row 1 active (bit 1 = 0), others inactive  
            SCAN_ROW2: row = 4'b1011;  // Row 2 active (bit 2 = 0), others inactive
            SCAN_ROW3: row = 4'b0111;  // Row 3 active (bit 3 = 0), others inactive
            default:   row = 4'b1111;  // All rows inactive (safety)
        endcase
    end
    
    // Key detection logic
    // Check if any column is LOW (indicating a key press in current row)
    always @(*) begin
        key_pressed = 1'b0;        // Default: no key pressed
        detected_key = 4'b0000;    // Default: no key code
        
        case (current_state)
            SCAN_ROW0: begin
                if (col != 4'b1111) begin      // If any column is LOW
                    key_pressed = 1'b1;
                    case (col)
                        4'b1110: detected_key = 4'b0001;  // Key '1' (Row0,Col0)
                        4'b1101: detected_key = 4'b0010;  // Key '2' (Row0,Col1)
                        4'b1011: detected_key = 4'b0011;  // Key '3' (Row0,Col2)
                        4'b0111: detected_key = 4'b1010;  // Key 'A' (Row0,Col3) - A=10
                        default: detected_key = 4'b0000;  // Invalid
                    endcase
                end
            end
            
            SCAN_ROW1: begin
                if (col != 4'b1111) begin      // If any column is LOW
                    key_pressed = 1'b1;
                    case (col)
                        4'b1110: detected_key = 4'b0100;  // Key '4' (Row1,Col0)
                        4'b1101: detected_key = 4'b0101;  // Key '5' (Row1,Col1)
                        4'b1011: detected_key = 4'b0110;  // Key '6' (Row1,Col2)
                        4'b0111: detected_key = 4'b1011;  // Key 'B' (Row1,Col3) - B=11
                        default: detected_key = 4'b0000;  // Invalid
                    endcase
                end
            end
            
            SCAN_ROW2: begin
                if (col != 4'b1111) begin      // If any column is LOW
                    key_pressed = 1'b1;
                    case (col)
                        4'b1110: detected_key = 4'b0111;  // Key '7' (Row2,Col0)
                        4'b1101: detected_key = 4'b1000;  // Key '8' (Row2,Col1)
                        4'b1011: detected_key = 4'b1001;  // Key '9' (Row2,Col2)
                        4'b0111: detected_key = 4'b1100;  // Key 'C' (Row2,Col3) - C=12
                        default: detected_key = 4'b0000;  // Invalid
                    endcase
                end
            end
            
            SCAN_ROW3: begin
                if (col != 4'b1111) begin      // If any column is LOW
                    key_pressed = 1'b1;
                    case (col)
                        4'b1110: detected_key = 4'b1110;  // Key '*' (Row3,Col0) - *=14
                        4'b1101: detected_key = 4'b0000;  // Key '0' (Row3,Col1)
                        4'b1011: detected_key = 4'b1111;  // Key '#' (Row3,Col2) - #=15
                        4'b0111: detected_key = 4'b1101;  // Key 'D' (Row3,Col3) - D=13
                        default: detected_key = 4'b0000;  // Invalid
                    endcase
                end
            end
        endcase
    end
    
    // Output register update
    // This stores the detected key and validity flag
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            key_code <= 4'b0000;
            key_valid <= 1'b0;
        end else begin
            if (key_pressed) begin
                key_code <= detected_key;  // Store the detected key
                key_valid <= 1'b1;        // Mark as valid
            end else begin
                key_valid <= 1'b0;        // No valid key
                // key_code retains previous value
            end
        end
    end

endmodule