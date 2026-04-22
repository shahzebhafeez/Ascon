module ascon_permutation_core (
    input  wire [63:0] x0_in, x1_in, x2_in, x3_in, x4_in,
    input  wire [3:0]  round_idx,
    output wire [63:0] x0_out, x1_out, x2_out, x3_out, x4_out
);

    // Internal wires connecting Constant Addition (p_C) to Substitution (p_S)
    wire [63:0] pc_x0, pc_x1, pc_x2, pc_x3, pc_x4;

    // Internal wires connecting Substitution (p_S) to Linear Diffusion (p_L)
    wire [63:0] ps_x0, ps_x1, ps_x2, ps_x3, ps_x4;

    // 1. Instantiate Constant Addition Layer (p_C)
    ascon_constant_addition pC_inst (
        .x0_in(x0_in), .x1_in(x1_in), .x2_in(x2_in), .x3_in(x3_in), .x4_in(x4_in),
        .round_idx(round_idx),
        .x0_out(pc_x0), .x1_out(pc_x1), .x2_out(pc_x2), .x3_out(pc_x3), .x4_out(pc_x4)
    );

    // 2. Instantiate Substitution Layer (p_S)
    ascon_substitution_layer pS_inst (
        .x0_in(pc_x0), .x1_in(pc_x1), .x2_in(pc_x2), .x3_in(pc_x3), .x4_in(pc_x4),
        .x0_out(ps_x0), .x1_out(ps_x1), .x2_out(ps_x2), .x3_out(ps_x3), .x4_out(ps_x4)
    );

    // 3. Instantiate Linear Diffusion Layer (p_L)
    ascon_linear_diffusion_layer pL_inst (
        .x0_in(ps_x0), .x1_in(ps_x1), .x2_in(ps_x2), .x3_in(ps_x3), .x4_in(ps_x4),
        .x0_out(x0_out), .x1_out(x1_out), .x2_out(x2_out), .x3_out(x3_out), .x4_out(x4_out)
    );

endmodule