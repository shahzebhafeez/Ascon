module ascon_substitution_layer (
    input  wire [63:0] x0_in, x1_in, x2_in, x3_in, x4_in,
    output wire [63:0] x0_out, x1_out, x2_out, x3_out, x4_out
);

    // Step 1: Add round constants & preliminary XORs
    wire [63:0] tx0 = x0_in ^ x4_in;
    wire [63:0] tx4 = x4_in ^ x3_in;
    wire [63:0] tx2 = x2_in ^ x1_in;
    wire [63:0] tx1 = x1_in;
    wire [63:0] tx3 = x3_in;

    // Step 2: Non-linear bitwise operations (The core of the S-box)
    wire [63:0] y0 = tx0 ^ (~tx1 & tx2);
    wire [63:0] y1 = tx1 ^ (~tx2 & tx3);
    wire [63:0] y2 = tx2 ^ (~tx3 & tx4);
    wire [63:0] y3 = tx3 ^ (~tx4 & tx0);
    wire [63:0] y4 = tx4 ^ (~tx0 & tx1);

    // Step 3: Final XORs for diffusion
    assign x0_out = y0 ^ y4;
    assign x1_out = y1 ^ y0;
    assign x2_out = ~y2;
    assign x3_out = y3 ^ y2;
    assign x4_out = y4;

endmodule