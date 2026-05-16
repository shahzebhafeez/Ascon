`timescale 1ns / 1ps

module display_top (
    input  wire        clk,
    input  wire        reset_n,
    input  wire [159:0] key,
    input  wire [127:0] nonce,
    input  wire [127:0] plaintext,
    input  wire [127:0] associated_data,
    input  wire [127:0] ciphertext,
    input  wire [127:0] auth_tag,
    input  wire [1:0]   test_case_sel,
    input  wire         test_case_valid,
    output wire        vga_hsync,
    output wire        vga_vsync,
    output wire [7:0]  vga_red,
    output wire [7:0]  vga_green,
    output wire [7:0]  vga_blue,
    output wire        vga_clk,
    output wire        vga_blank_n,
    output wire        vga_sync_n
);

    reg pixel_clk_reg;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    wire video_on;

    always @(posedge clk) begin
        if (!reset_n)
            pixel_clk_reg <= 1'b0;
        else
            pixel_clk_reg <= ~pixel_clk_reg;
    end

    assign vga_clk = pixel_clk_reg;
    assign vga_blank_n = video_on;
    assign vga_sync_n = 1'b0;

    vga_controller u_vga_controller (
        .pixel_clk(pixel_clk_reg),
        .reset_n(reset_n),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .video_on(video_on)
    );

    text_renderer u_text_renderer (
        .pixel_clk(pixel_clk_reg),
        .reset_n(reset_n),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .video_on(video_on),
        .key(key),
        .nonce(nonce),
        .plaintext(plaintext),
        .associated_data(associated_data),
        .ciphertext(ciphertext),
        .auth_tag(auth_tag),
        .test_case_sel(test_case_sel),
        .test_case_valid(test_case_valid),
        .red(vga_red),
        .green(vga_green),
        .blue(vga_blue)
    );

endmodule
