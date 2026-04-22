`timescale 1ns / 1ps

module tb_ascon_top();

    // Global Signals
    reg clk;
    reg reset_n;

    // Control Signals
    reg start;
    reg data_valid;
    wire ready;
    wire done;

    // Data Signals
    reg [159:0] key;
    reg [127:0] nonce;
    reg [63:0]  data_in;
    wire [63:0] data_out;

    // Instantiate the Top-Level Wrapper
    ascon_top uut (
        .clk(clk), .reset_n(reset_n),
        .start(start), .data_valid(data_valid), .ready(ready), .done(done),
        .key(key), .nonce(nonce), .data_in(data_in), .data_out(data_out)
    );

    // 1. Generate 50 MHz Clock (20ns period)
    always #10 clk = ~clk;

    initial begin
        // 2. Initialize Signals & Reset System
        clk = 0;
        reset_n = 0;
        start = 0;
        data_valid = 0;
        key = 160'h000102030405060708090A0B0C0D0E0F10111213; // Example 160-bit Key
        nonce = 128'h000102030405060708090A0B0C0D0E0F;       // Example 128-bit Nonce
        data_in = 64'h32303236_44534421;                     // ASCII: "2026DSD!"

        // Hold reset for 40ns, then release
        #40 reset_n = 1;

        // 3. Wait for hardware to become Ready
        wait (ready == 1'b1);
        @(posedge clk);
        
        // 4. Trigger Initialization Phase
        $display("[%0t] Starting Initialization (Loading IV, Key, Nonce)...", $time);
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait for the 12 Initialization rounds to finish. 
        // The FSM will transition to ST_WAIT_DATA when done.
        // We simulate waiting a sufficient amount of time (15 cycles).
        repeat(15) @(posedge clk);

        // 5. Trigger Data Processing Phase
        $display("[%0t] Injecting Plaintext Data...", $time);
        data_valid = 1;
        @(posedge clk);
        data_valid = 0;

        // 6. Wait for Finalization and Hardware to flag 'Done'
        wait (done == 1'b1);
        $display("[%0t] Encryption Complete!", $time);
        $display("----------------------------------------");
        $display("FINAL CIPHERTEXT/TAG OUTPUT: %h", data_out);
        $display("----------------------------------------");

        $stop; // End Simulation
    end

endmodule