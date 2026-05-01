module ascon_top (
    input  wire         clk,
    input  wire         reset_n,
    input  wire         start,
    input  wire         data_valid,
    output wire         ready,
    output wire         done,
    input  wire [159:0] key,
    input  wire [127:0] nonce,
    input  wire [63:0]  data_in,
    output wire [63:0]  data_out,
    output wire [127:0] tag_out
);

    // 1. Control Bus (FSM -> Datapath)
    wire ctrl_init_load;
    wire ctrl_update;
    wire ctrl_inject;
    wire ctrl_key_xor;
    wire ctrl_domain_sep; // <--- NEW WIRE

    // 2. Control Bus (FSM -> Permutation Core)
    wire [3:0] round_idx;

    // 3. Forward Data Loop
    wire [63:0] state_x0, state_x1, state_x2, state_x3, state_x4;

    // 4. Return Data Loop
    wire [63:0] perm_x0, perm_x1, perm_x2, perm_x3, perm_x4;

    // Instantiate FSM
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
        .ctrl_domain_sep (ctrl_domain_sep), // <--- CONNECTED
        .round_idx       (round_idx)
    );

    // Instantiate Datapath
    ascon_datapath u_datapath (
        .clk             (clk),
        .reset_n         (reset_n),
        .ctrl_init_load  (ctrl_init_load),
        .ctrl_update     (ctrl_update),
        .ctrl_inject     (ctrl_inject),
        .ctrl_key_xor    (ctrl_key_xor),
        .ctrl_domain_sep (ctrl_domain_sep), // <--- CONNECTED
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
        .data_out        (data_out),
	.tag_out 	 (tag_out)
    );

    // Instantiate Permutation Core
    ascon_permutation_core u_perm_core (
        .x0_in(state_x0), .x1_in(state_x1), .x2_in(state_x2), .x3_in(state_x3), .x4_in(state_x4),
        .round_idx(round_idx),
        .x0_out(perm_x0), .x1_out(perm_x1), .x2_out(perm_x2), .x3_out(perm_x3), .x4_out(perm_x4)
    );

endmodule