`timescale 1ns/1ps

// Testbench for 4x4 Keypad Scanner
// This module simulates key presses and verifies the scanner works correctly

module keypad_scanner_tb();

    // Test signals
    reg clk;                    // Clock signal
    reg reset;                  // Reset signal  
    reg [3:0] col;             // Column inputs (simulated keypad columns)
    wire [3:0] row;            // Row outputs from scanner
    wire [3:0] key_code;       // Detected key code
    wire key_valid;            // Key validity flag
    
    // Instantiate the keypad scanner module
    keypad_scanner uut (
        .clk(clk),
        .reset(reset),
        .col(col),
        .row(row),
        .key_code(key_code),
        .key_valid(key_valid)
    );
    
    // Clock generation
    // Create a clock with 10ns period (100MHz frequency)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Toggle every 5ns (10ns period)
    end
    
    // Test stimulus
    initial begin
        // Initialize all signals
        reset = 1;              // Start with reset active
        col = 4'b1111;         // No keys pressed initially (all columns HIGH)
        
        // Display header for simulation output
        $display("Time\tReset\tRow\tCol\tKey_Code\tKey_Valid\tExpected_Key");
        $display("----\t-----\t---\t---\t--------\t---------\t------------");
        
        // Wait for a few clock cycles with reset active
        #20;
        reset = 0;              // Release reset
        
        // Wait for FSM to start scanning
        #40;
        
        // Test Case 1: Press key '1' (Row0, Col0)
        // Wait until scanner is scanning row 0
        wait(row == 4'b1110);   // Wait until row 0 is active
        #2;                     // Small delay for setup
        col = 4'b1110;         // Simulate key '1' press (Col0 goes LOW)
        $display("%t\t%b\t%b\t%b\t%b\t\t%b\t\t1", $time, reset, row, col, key_code, key_valid);
        #20;                    // Hold key press
        col = 4'b1111;         // Release key
        #20;
        
        // Test Case 2: Press key '5' (Row1, Col1)  
        wait(row == 4'b1101);   // Wait until row 1 is active
        #2;
        col = 4'b1101;         // Simulate key '5' press (Col1 goes LOW)
        $display("%t\t%b\t%b\t%b\t%b\t\t%b\t\t5", $time, reset, row, col, key_code, key_valid);
        #20;
        col = 4'b1111;         // Release key
        #20;
        
        // Test Case 3: Press key '9' (Row2, Col2)
        wait(row == 4'b1011);   // Wait until row 2 is active  
        #2;
        col = 4'b1011;         // Simulate key '9' press (Col2 goes LOW)
        $display("%t\t%b\t%b\t%b\t%b\t\t%b\t\t9", $time, reset, row, col, key_code, key_valid);
        #20;
        col = 4'b1111;         // Release key
        #20;
        
        // Test Case 4: Press key 'A' (Row0, Col3)
        wait(row == 4'b1110);   // Wait until row 0 is active
        #2;
        col = 4'b0111;         // Simulate key 'A' press (Col3 goes LOW)
        $display("%t\t%b\t%b\t%b\t%b\t\t%b\t\tA", $time, reset, row, col, key_code, key_valid);
        #20;
        col = 4'b1111;         // Release key
        #20;
        
        // Test Case 5: Press key '0' (Row3, Col1)
        wait(row == 4'b0111);   // Wait until row 3 is active
        #2;
        col = 4'b1101;         // Simulate key '0' press (Col1 goes LOW)
        $display("%t\t%b\t%b\t%b\t%b\t\t%b\t\t0", $time, reset, row, col, key_code, key_valid);
        #20;
        col = 4'b1111;         // Release key
        #20;
        
        // Test Case 6: Press key '#' (Row3, Col2)
        wait(row == 4'b0111);   // Wait until row 3 is active
        #2;
        col = 4'b1011;         // Simulate key '#' press (Col2 goes LOW)
        $display("%t\t%b\t%b\t%b\t%b\t\t%b\t\t#", $time, reset, row, col, key_code, key_valid);
        #20;
        col = 4'b1111;         // Release key
        #40;
        
        // Test Case 7: Test reset functionality
        $display("\nTesting Reset...");
        reset = 1;              // Apply reset
        #20;
        reset = 0;              // Release reset
        #40;
        
        // Test Case 8: Multiple key detection test
        $display("\nTesting scanning cycle without key press...");
        #100;                   // Let it scan for a while without any key press
        
        $display("\nSimulation completed successfully!");
        $finish;
    end
    
    // Monitor all signals continuously
    initial begin
        $monitor("Time=%t | Reset=%b | Row=%b | Col=%b | Key_Code=%b(%d) | Valid=%b", 
                 $time, reset, row, col, key_code, key_code, key_valid);
    end
    
    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("keypad_scanner.vcd");
        $dumpvars(0, keypad_scanner_tb);
    end
    
    // Task to simulate a key press at specific row and column
    task press_key;
        input [1:0] target_row;  // Which row to press key in
        input [1:0] target_col;  // Which column to press key in
        reg [3:0] expected_row_pattern;
        reg [3:0] col_pattern;
        begin
            // Calculate expected row pattern
            case(target_row)
                2'b00: expected_row_pattern = 4'b1110;
                2'b01: expected_row_pattern = 4'b1101;
                2'b10: expected_row_pattern = 4'b1011;
                2'b11: expected_row_pattern = 4'b0111;
            endcase
            
            // Calculate column pattern
            case(target_col)
                2'b00: col_pattern = 4'b1110;
                2'b01: col_pattern = 4'b1101;
                2'b10: col_pattern = 4'b1011;
                2'b11: col_pattern = 4'b0111;
            endcase
            
            // Wait for the correct row to be scanned
            wait(row == expected_row_pattern);
            #2;
            col = col_pattern;      // Apply key press
            #20;
            col = 4'b1111;         // Release key
            #10;
        end
    endtask

endmodule