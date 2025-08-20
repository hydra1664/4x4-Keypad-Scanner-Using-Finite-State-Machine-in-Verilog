// Top-level module for 4x4 Keypad Scanner
// This is the main module that would be used in actual hardware implementation
`include "keypad_scanner.v"
module keypad_top(
    input wire clk_in,          // Input clock (from external oscillator)
    input wire reset_btn,       // Reset button (active high)
    input wire [3:0] keypad_col,// Physical keypad column connections
    output wire [3:0] keypad_row,// Physical keypad row connections  
    output wire [3:0] led_out,  // LEDs to display key code
    output wire key_detected    // LED to show when key is pressed
);

    // Internal signals
    wire [3:0] internal_key_code;
    wire internal_key_valid;
    
    // Clock divider to slow down the scanning
    // Real keypads need slower scanning than simulation
    reg [15:0] clk_div_counter;
    reg scan_clk;
    
    // Clock divider - creates slower clock for keypad scanning
    always @(posedge clk_in or posedge reset_btn) begin
        if (reset_btn) begin
            clk_div_counter <= 16'b0;
            scan_clk <= 1'b0;
        end else begin
            clk_div_counter <= clk_div_counter + 1;
            if (clk_div_counter == 16'hFFFF) begin
                scan_clk <= ~scan_clk;  // Toggle scan clock
            end
        end
    end
    
    // Instantiate the keypad scanner
    keypad_scanner main_scanner (
        .clk(scan_clk),             // Use divided clock
        .reset(reset_btn),
        .col(keypad_col),
        .row(keypad_row),
        .key_code(internal_key_code),
        .key_valid(internal_key_valid)
    );
    
    // Output assignments
    assign led_out = internal_key_code;   // Show key code on LEDs
    assign key_detected = internal_key_valid; // Show detection status
    
endmodule