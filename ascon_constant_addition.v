module ascon_constant_addition (
    input  wire [63:0] x0_in, x1_in, x2_in, x3_in, x4_in,
    input  wire [3:0]  round_idx, // 4-bit round index (0 to 11)
    output wire [63:0] x0_out, x1_out, x2_out, x3_out, x4_out
);

    wire [7:0] round_constant;

    // Dynamically calculate the 8-bit round constant to save FPGA LUTs
    // Upper nibble is (15 - round_idx), Lower nibble is round_idx
    assign round_constant = { (4'd15 - round_idx), round_idx };

    // x0, x1, x3, and x4 pass through unchanged
    assign x0_out = x0_in;
    assign x1_out = x1_in;
    assign x3_out = x3_in;
    assign x4_out = x4_in;

    // XOR the 8-bit constant exclusively into the least significant byte of x2
    assign x2_out = x2_in ^ {56'h00000000000000, round_constant};

endmodule