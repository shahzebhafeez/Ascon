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
    reg  [159:0] key;
    reg  [127:0] nonce;
    reg  [63:0]  data_in;
    wire [63:0]  data_out;
    wire [127:0] tag_out; 

    // Registers to capture our hardware ciphertext
    reg [63:0] ciphertext_block_0;
    reg [63:0] ciphertext_block_1;

    
    ascon_top uut (
        .clk(clk), .reset_n(reset_n),
        .start(start), .data_valid(data_valid), .ready(ready), .done(done),
        .key(key), .nonce(nonce), .data_in(data_in), .data_out(data_out), .tag_out(tag_out)
    );

    always #10 clk = ~clk;

    
    task inject_data(input [63:0] val, input integer is_pt, input integer pt_idx);
    begin
        wait(ready == 1'b1);
        @(negedge clk);       
        data_in = val;
        data_valid = 1;

        #1;

        // Extract Ciphertext (C_i = P_i XOR State_x0)
        if (is_pt == 1) begin
            if (pt_idx == 0) ciphertext_block_0 = data_out;
            if (pt_idx == 1) ciphertext_block_1 = data_out;
        end

        @(negedge clk);       
        data_valid = 0;
        
    end
    endtask

    initial begin
        // --- 1. Reset & Setup ---
        clk = 0; reset_n = 0; start = 0; data_valid = 0; data_in = 0;
        key   = 160'h000102030405060708090a0b0c0d0e0f10111213;
        nonce = 128'h000102030405060708090a0b0c0d0e0f;
        
        #40 reset_n = 1;
        wait(ready == 1'b1);
        
        // --- 2. Initialization ---
        $display("[%0t] Pulse Start: Beginning Initialization...", $time);
        @(negedge clk); start = 1;
        @(negedge clk); start = 0;

        // --- 3. Associated Data (AD) ---
        $display("[%0t] Waiting for Ready to inject AD...", $time);
        // Arguments: (data, is_plaintext flag, block_index)
        inject_data(64'h0102030405060708, 0, 0);
        inject_data(64'h090a0b0c0d0e0f10, 0, 0);
        
        // --- 4. Plaintext (PT) ---
        $display("[%0t] Waiting for Ready to inject Plaintext...", $time);
        inject_data(64'haabbccddeeff1122, 1, 0);
        inject_data(64'h3344556677889900, 1, 1);

        // --- 5. Capture Output & Verify ---
        wait(done == 1'b1);
        $display("[%0t] Encryption Complete!", $time);
        
        // Give it a tiny delay for final combinational logic to settle
        #1;
        
        $display("\n=========================================================");
        $display("HARDWARE CIPHERTEXT: %h%h", ciphertext_block_0, ciphertext_block_1);
        $display("HARDWARE TAG:        %h", tag_out); 
        $display("---------------------------------------------------------");
        $display("GOLDEN CIPHERTEXT:   2807f5d65f80b54ca4b9c9187d07f315");
        $display("GOLDEN TAG:          1893ff6d630e9bca5b689ce158352dba");
        $display("=========================================================");

        
        if ({ciphertext_block_0, ciphertext_block_1, tag_out} == 256'h2807f5d65f80b54ca4b9c9187d07f3151893ff6d630e9bca5b689ce158352dba) begin
            $display("SUCCESS: Hardware implementation flawlessly matches the Golden Standard!");
        end else begin
            $display("FAILURE: Hardware mismatch detected.");
        end
        $display("=========================================================\n");

        $stop;
    end
endmodule