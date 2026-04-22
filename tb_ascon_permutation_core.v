`timescale 1ns / 1ps

module tb_ascon_permutation_core();

    // Inputs
    reg [63:0] x0_in, x1_in, x2_in, x3_in, x4_in;
    reg [3:0]  round_idx;

    // Outputs
    wire [63:0] x0_out, x1_out, x2_out, x3_out, x4_out;

    // Instantiate the Unit Under Test (UUT)
    ascon_permutation_core uut (
        .x0_in(x0_in), .x1_in(x1_in), .x2_in(x2_in), .x3_in(x3_in), .x4_in(x4_in),
        .round_idx(round_idx),
        .x0_out(x0_out), .x1_out(x1_out), .x2_out(x2_out), .x3_out(x3_out), .x4_out(x4_out)
    );

    initial begin
        // 1. Apply Golden Input Vector (Example Initial State for Ascon-80pq)
        x0_in = 64'hA0400C06_00000000; // IV + Top of Key
        x1_in = 64'h01234567_89ABCDEF; // Key Mid
        x2_in = 64'hFEDCBA98_76543210; // Key Bot
        x3_in = 64'h00001111_22223333; // Nonce Top
        x4_in = 64'h44445555_66667777; // Nonce Bot
        round_idx = 4'd0; // Testing Round 0 (Constant = 0xF0)

        // 2. Wait for combinational logic propagation
        #10; 

        // 3. Display Results in Console
        $display("=== PERMUTATION CORE ROUND 0 RESULTS ===");
        $display("X0_OUT: %h", x0_out);
        $display("X1_OUT: %h", x1_out);
        $display("X2_OUT: %h", x2_out);
        $display("X3_OUT: %h", x3_out);
        $display("X4_OUT: %h", x4_out);

        // 4. Automated Verification (Replace these with exact C model outputs)
        // if (x0_out !== 64'hEXPECTED_HEX_VALUE) $error("X0 Mismatch!");
        
        $stop; // Pause simulation
    end

endmodule