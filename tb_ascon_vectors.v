`timescale 1ns / 1ps

module tb_ascon_vectors();

    reg clk;
    reg reset_n;
    reg start;
    reg data_valid;
    wire ready;
    wire done;
    reg [159:0] key;
    reg [127:0] nonce;
    reg [63:0] data_in;
    wire [63:0] data_out;
    wire [127:0] tag_out;
    reg [63:0] ciphertext_block_0;
    reg [63:0] ciphertext_block_1;

    ascon_top uut (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .data_valid(data_valid),
        .ready(ready),
        .done(done),
        .key(key),
        .nonce(nonce),
        .data_in(data_in),
        .data_out(data_out),
        .tag_out(tag_out)
    );

    always #10 clk = ~clk;

    task inject_data;
        input [63:0] val;
        input is_plaintext;
        input pt_idx;
        begin
            wait(ready == 1'b1);
            @(negedge clk);
            data_in = val;
            data_valid = 1'b1;
            #1;
            if (is_plaintext) begin
                if (!pt_idx)
                    ciphertext_block_0 = data_out;
                else
                    ciphertext_block_1 = data_out;
            end
            @(negedge clk);
            data_valid = 1'b0;
        end
    endtask

    task run_vector;
        input [7:0] id;
        input [159:0] vector_key;
        input [127:0] vector_nonce;
        input [127:0] vector_ad;
        input [127:0] vector_pt;
        begin
            reset_n = 1'b0;
            start = 1'b0;
            data_valid = 1'b0;
            data_in = 64'd0;
            ciphertext_block_0 = 64'd0;
            ciphertext_block_1 = 64'd0;
            key = vector_key;
            nonce = vector_nonce;

            repeat (4) @(negedge clk);
            reset_n = 1'b1;
            wait(ready == 1'b1);

            @(negedge clk);
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;

            inject_data(vector_ad[127:64], 1'b0, 1'b0);
            inject_data(vector_ad[63:0], 1'b0, 1'b0);
            inject_data(vector_pt[127:64], 1'b1, 1'b0);
            inject_data(vector_pt[63:0], 1'b1, 1'b1);

            wait(done == 1'b1);
            #1;
            $display("TC%0d CT=%h%h TAG=%h", id, ciphertext_block_0, ciphertext_block_1, tag_out);
        end
    endtask

    initial begin
        clk = 1'b0;
        run_vector(8'd1,
                   160'h000102030405060708090A0B0C0D0E0F10111213,
                   128'h000102030405060708090A0B0C0D0E0F,
                   128'h534F43204C4142204153434F4E203031,
                   128'h434849505850525420534F43204C4142);
        run_vector(8'd2,
                   160'h00112233445566778899AABBCCDDEEFF00010203,
                   128'h102030405060708090A0B0C0D0E0F00,
                   128'h414420464F5220434849505850525421,
                   128'h534F43204C4142204348495058505254);
        run_vector(8'd3,
                   160'hFFEEDDCCBBAA99887766554433221100A0B0C0D0,
                   128'hF0E0D0C0B0A090807060504030201000,
                   128'h534F43204C4142205445535420303033,
                   128'h43484950585052542046504741212121);
        $stop;
    end

endmodule
