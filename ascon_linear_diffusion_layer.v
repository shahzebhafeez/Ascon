module ascon_linear_diffusion_layer (
    input  wire [63:0] x0_in, x1_in, x2_in, x3_in, x4_in,
    output wire [63:0] x0_out, x1_out, x2_out, x3_out, x4_out
);

    // Σ0(x0) = x0 ⊕ (x0 ≫ 19) ⊕ (x0 ≫ 28)
    assign x0_out = x0_in ^ ((x0_in >> 19) | (x0_in << 45)) ^ ((x0_in >> 28) | (x0_in << 36));

    // Σ1(x1) = x1 ⊕ (x1 ≫ 61) ⊕ (x1 ≫ 39)
    assign x1_out = x1_in ^ ((x1_in >> 61) | (x1_in << 3))  ^ ((x1_in >> 39) | (x1_in << 25));

    // Σ2(x2) = x2 ⊕ (x2 ≫ 1) ⊕ (x2 ≫ 6)
    assign x2_out = x2_in ^ ((x2_in >> 1)  | (x2_in << 63)) ^ ((x2_in >> 6)  | (x2_in << 58));

    // Σ3(x3) = x3 ⊕ (x3 ≫ 10) ⊕ (x3 ≫ 17)
    assign x3_out = x3_in ^ ((x3_in >> 10) | (x3_in << 54)) ^ ((x3_in >> 17) | (x3_in << 47));

    // Σ4(x4) = x4 ⊕ (x4 ≫ 7) ⊕ (x4 ≫ 41)
    assign x4_out = x4_in ^ ((x4_in >> 7)  | (x4_in << 57)) ^ ((x4_in >> 41) | (x4_in << 23));

endmodule