module ascon_top (
    // Global Hardware Signals
    input  wire         clk,
    input  wire         reset_n,

    // Execution Control Interface (From AXI/Processor)
    input  wire         start,         // Pulse to begin cryptographic operation
    input  wire         data_valid,    // High when plaintext/AD is present on data_in
    output wire         ready,         // High when core is idle and can accept 'start'
    output wire         done,          // High when final tag/ciphertext is complete

    // Cryptographic Data Interface
    input  wire [159:0] key,           // 160-bit Ascon-80pq Key
    input  wire [127:0] nonce,         // 128-bit Nonce
    input  wire [63:0]  data_in,       // 64-bit plaintext or associated data block
    output wire [63:0]  data_out       // 64-bit ciphertext output
);

    // =========================================================================
    // INTERNAL WIRE DECLARATIONS (The Silicon Routing)
    // =========================================================================

    // 1. Control Bus (FSM -> Datapath)
    wire ctrl_init_load;
    wire ctrl_update;
    wire ctrl_inject;
    wire ctrl_key_xor;

    // 2. Control Bus (FSM -> Permutation Core)
    wire [3:0] round_idx;

    // 3. Forward Data Loop (Datapath -> Permutation Core)
    wire [63:0] state_x0, state_x1, state_x2, state_x3, state_x4;

    // 4. Return Data Loop (Permutation Core -> Datapath)
    wire [63:0] perm_x0, perm_x1, perm_x2, perm_x3, perm_x4;

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    // 1. Instantiate the Finite State Machine (The Brain)
    ascon_fsm u_fsm (
        .clk             (clk),
        .reset_n         (reset_n),
        .start           (start),
        .data_valid      (data_valid),
        .ready           (ready),
        .done            (done),
        .ctrl_init_load  (ctrl_init_load),
        .ctrl_update     (ctrl_update),
        .ctrl_inject     (ctrl_inject),
        .ctrl_key_xor    (ctrl_key_xor),
        .round_idx       (round_idx)
    );

    // 2. Instantiate the Datapath and State Registers (The Memory)
    ascon_datapath u_datapath (
        .clk             (clk),
        .reset_n         (reset_n),
        .ctrl_init_load  (ctrl_init_load),
        .ctrl_update     (ctrl_update),
        .ctrl_inject     (ctrl_inject),
        .ctrl_key_xor    (ctrl_key_xor),
        .data_in         (data_in),
        .key             (key),
        .nonce           (nonce),
        .perm_x0         (perm_x0),
        .perm_x1         (perm_x1),
        .perm_x2         (perm_x2),
        .perm_x3         (perm_x3),
        .perm_x4         (perm_x4),
        .state_x0        (state_x0),
        .state_x1        (state_x1),
        .state_x2        (state_x2),
        .state_x3        (state_x3),
        .state_x4        (state_x4),
        .data_out        (data_out)
    );

    // 3. Instantiate the Combinational Permutation Core (The Math Engine)
    ascon_permutation_core u_perm_core (
        .x0_in           (state_x0),
        .x1_in           (state_x1),
        .x2_in           (state_x2),
        .x3_in           (state_x3),
        .x4_in           (state_x4),
        .round_idx       (round_idx),
        .x0_out          (perm_x0),
        .x1_out          (perm_x1),
        .x2_out          (perm_x2),
        .x3_out          (perm_x3),
        .x4_out          (perm_x4)
    );

endmodule