`timescale 1ns / 1ps

module ascon_datapath (
    input  wire         clk,
    input  wire         reset_n,         // Active-low synchronous reset

    // Control Signals (Driven by the FSM)
    input  wire         ctrl_init_load,  // Load IV, Key, and Nonce into state
    input  wire         ctrl_update,     // Standard round: capture Permutation Core output
    input  wire         ctrl_inject,     // XOR incoming data into the rate (x0)
    input  wire         ctrl_key_xor,    // Initialization key absorb at byte offset 20
    input  wire         ctrl_final_key_xor, // Finalization key absorb at byte offset 8
    input  wire         ctrl_pad,        // Apply ASCON 10* padding at byte offset 0
    input  wire         ctrl_domain_sep, // Domain separation for plaintext phase

    // External Data Inputs
    input  wire [63:0]  data_in,         // 64-bit plaintext or associated data block
    input  wire [159:0] key,             // 160-bit Ascon-80pq Key
    input  wire [127:0] nonce,           // 128-bit Nonce

    // Connections FROM Combinational Permutation Core
    input  wire [63:0]  perm_x0, perm_x1, perm_x2, perm_x3, perm_x4,

    // Connections TO Combinational Permutation Core
    output reg  [63:0]  state_x0, state_x1, state_x2, state_x3, state_x4,

    // Data Outputs
    output wire [63:0]  data_out,        // Ciphertext block output
    output wire [127:0] tag_out          // Final Authentication Tag output
);

    // Ascon-80pq specific 32-bit IV (Key size=160, Rate=64, a=12, b=6)
    // Hex: 0xA0 (160), 0x40 (64), 0x0C (12), 0x06 (6)
    localparam [31:0] ASCON_80PQ_IV = 32'hA0400C06;

    // ==========================================
    // COMBINATIONAL OUTPUT EXTRACTIONS
    // ==========================================
    
    // Ciphertext is generated before the permutation runs.
    // C_i = P_i XOR current state_x0
    assign data_out = state_x0 ^ data_in;

    // Tag extraction is combinationally applied to the final state.
    // Tag = Final state_x3/x4 XOR bottom 128 bits of the Key
    assign tag_out = {state_x3 ^ key[127:64], state_x4 ^ key[63:0]};

    // ==========================================
    // SYNCHRONOUS STATE UPDATES
    // ==========================================
    always @(posedge clk) begin
        if (!reset_n) begin
            state_x0 <= 64'b0;
            state_x1 <= 64'b0;
            state_x2 <= 64'b0;
            state_x3 <= 64'b0;
            state_x4 <= 64'b0;
        end else begin
            
            // Priority 1: Initialization
            if (ctrl_init_load) begin
                state_x0 <= {ASCON_80PQ_IV, key[159:128]}; // 32-bit IV + Top 32-bits of Key
                state_x1 <= key[127:64];                   // Next 64 bits of Key
                state_x2 <= key[63:0];                     // Bottom 64 bits of Key
                state_x3 <= nonce[127:64];                 // Top 64 bits of Nonce
                state_x4 <= nonce[63:0];                   // Bottom 64 bits of Nonce
            end
            
            // Priority 2: Data Injection 
            // XOR data into the existing state_x0, leave others untouched
            else if (ctrl_inject) begin
                state_x0 <= state_x0 ^ data_in; 
            end

            // Priority 3: ASCON padding at byte offset 0.
            // For an exact multiple of the 64-bit rate, the C reference still
            // applies an empty padded block: x0 byte 0 ^= 0x80.
            else if (ctrl_pad) begin
                state_x0 <= state_x0 ^ 64'h8000000000000000;
            end
            
            // Priority 4: Initialization key absorb at byte offset 20.
            else if (ctrl_key_xor) begin
                state_x2 <= state_x2 ^ key[159:128];
                state_x3 <= state_x3 ^ key[127:64];
                state_x4 <= state_x4 ^ key[63:0];
            end

            // Priority 5: Finalization key absorb at byte offset 8.
            else if (ctrl_final_key_xor) begin
                state_x1 <= state_x1 ^ key[159:96];
                state_x2 <= state_x2 ^ key[95:32];
                state_x3 <= state_x3 ^ {key[31:0], 32'b0};
            end
            
            // Priority 6: Domain Separation
            // Flip the LSB of existing state_x4
            else if (ctrl_domain_sep) begin
                state_x4[0] <= state_x4[0] ^ 1'b1; 
            end
            
            // Priority 7: Standard Permutation Loop
            // Latch the heavily scrambled outputs from the Permutation Core
            else if (ctrl_update) begin
                state_x0 <= perm_x0;
                state_x1 <= perm_x1;
                state_x2 <= perm_x2;
                state_x3 <= perm_x3;
                state_x4 <= perm_x4;
            end
            
        end
    end

endmodule