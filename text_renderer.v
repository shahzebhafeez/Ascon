`timescale 1ns / 1ps

module text_renderer (
    input  wire        pixel_clk,
    input  wire        reset_n,
    input  wire [9:0]  pixel_x,
    input  wire [9:0]  pixel_y,
    input  wire        video_on,
    input  wire [159:0] key,
    input  wire [127:0] nonce,
    input  wire [127:0] plaintext,
    input  wire [127:0] associated_data,
    input  wire [127:0] ciphertext,
    input  wire [127:0] auth_tag,
    input  wire [1:0]   test_case_sel,
    input  wire         test_case_valid,
    output reg  [7:0]  red,
    output reg  [7:0]  green,
    output reg  [7:0]  blue
);

    wire [6:0] char_col;
    wire [5:0] char_row;
    wire [2:0] font_x;
    wire [2:0] font_y;
    wire [5:0] big_col;
    wire [4:0] big_row;
    wire [2:0] big_font_x;
    wire [2:0] big_font_y;

    reg  [7:0] char_code;
    reg  [7:0] big_char_code;
    reg  [3:0] selected_nibble;
    wire [7:0] hex_ascii;
    wire [7:0] font_pixels;
    wire [7:0] big_font_pixels;
    wire       text_pixel;
    wire       big_text_pixel;

    assign char_col = pixel_x[9:3];
    assign char_row = pixel_y[8:3];
    assign font_x   = pixel_x[2:0];
    assign font_y   = pixel_y[2:0];
    assign big_col = pixel_x[9:4];
    assign big_row = pixel_y[8:4];
    assign big_font_x = pixel_x[3:1];
    assign big_font_y = pixel_y[3:1];

    hex_to_ascii u_hex_to_ascii (
        .nibble(selected_nibble),
        .ascii(hex_ascii)
    );

    font_rom u_font_rom (
        .char_code(char_code),
        .row(font_y),
        .pixels(font_pixels)
    );

    font_rom u_big_font_rom (
        .char_code(big_char_code),
        .row(big_font_y),
        .pixels(big_font_pixels)
    );

    assign text_pixel = font_pixels[3'd7 - font_x];
    assign big_text_pixel = big_font_pixels[3'd7 - big_font_x];

    function [3:0] nibble160;
        input [159:0] value;
        input [5:0] index;
        reg [159:0] shifted;
        begin
            shifted = value >> ((6'd39 - index) * 4);
            nibble160 = shifted[3:0];
        end
    endfunction

    function [3:0] nibble128;
        input [127:0] value;
        input [5:0] index;
        reg [127:0] shifted;
        begin
            shifted = value >> ((6'd31 - index) * 4);
            nibble128 = shifted[3:0];
        end
    endfunction

    function [3:0] nibble64;
        input [63:0] value;
        input [5:0] index;
        reg [63:0] shifted;
        begin
            shifted = value >> ((6'd15 - index) * 4);
            nibble64 = shifted[3:0];
        end
    endfunction

    function [7:0] label_char;
        input [2:0] label_id;
        input [5:0] index;
        begin
            label_char = 8'h20;
            case (label_id)
                3'd0: begin // KEY 160:
                    case (index)
                        6'd0: label_char = 8'h4B; // K
                        6'd1: label_char = 8'h45; // E
                        6'd2: label_char = 8'h59; // Y
                        6'd3: label_char = 8'h20; // space
                        6'd4: label_char = 8'h31; // 1
                        6'd5: label_char = 8'h36; // 6
                        6'd6: label_char = 8'h30; // 0
                        6'd7: label_char = 8'h3A; // :
                        default: label_char = 8'h20;
                    endcase
                end
                3'd1: begin // NONCE 128:
                    case (index)
                        6'd0: label_char = 8'h4E; // N
                        6'd1: label_char = 8'h4F; // O
                        6'd2: label_char = 8'h4E; // N
                        6'd3: label_char = 8'h43; // C
                        6'd4: label_char = 8'h45; // E
                        6'd5: label_char = 8'h20; // space
                        6'd6: label_char = 8'h31; // 1
                        6'd7: label_char = 8'h32; // 2
                        6'd8: label_char = 8'h38; // 8
                        6'd9: label_char = 8'h3A; // :
                        default: label_char = 8'h20;
                    endcase
                end
                3'd2: begin // PLAINTEXT:
                    case (index)
                        6'd0: label_char = 8'h50; // P
                        6'd1: label_char = 8'h4C; // L
                        6'd2: label_char = 8'h41; // A
                        6'd3: label_char = 8'h49; // I
                        6'd4: label_char = 8'h4E; // N
                        6'd5: label_char = 8'h54; // T
                        6'd6: label_char = 8'h45; // E
                        6'd7: label_char = 8'h58; // X
                        6'd8: label_char = 8'h54; // T
                        6'd9: label_char = 8'h3A; // :
                        default: label_char = 8'h20;
                    endcase
                end
                3'd3: begin // AD:
                    case (index)
                        6'd0: label_char = 8'h41; // A
                        6'd1: label_char = 8'h44; // D
                        6'd2: label_char = 8'h3A; // :
                        default: label_char = 8'h20;
                    endcase
                end
                3'd4: begin // CIPHERTEXT:
                    case (index)
                        6'd0:  label_char = 8'h43; // C
                        6'd1:  label_char = 8'h49; // I
                        6'd2:  label_char = 8'h50; // P
                        6'd3:  label_char = 8'h48; // H
                        6'd4:  label_char = 8'h45; // E
                        6'd5:  label_char = 8'h52; // R
                        6'd6:  label_char = 8'h54; // T
                        6'd7:  label_char = 8'h45; // E
                        6'd8:  label_char = 8'h58; // X
                        6'd9:  label_char = 8'h54; // T
                        6'd10: label_char = 8'h3A; // :
                        default: label_char = 8'h20;
                    endcase
                end
                3'd5: begin // AUTH TAG:
                    case (index)
                        6'd0: label_char = 8'h41; // A
                        6'd1: label_char = 8'h55; // U
                        6'd2: label_char = 8'h54; // T
                        6'd3: label_char = 8'h48; // H
                        6'd4: label_char = 8'h20; // space
                        6'd5: label_char = 8'h54; // T
                        6'd6: label_char = 8'h41; // A
                        6'd7: label_char = 8'h47; // G
                        6'd8: label_char = 8'h3A; // :
                        default: label_char = 8'h20;
                    endcase
                end
                default: label_char = 8'h20;
            endcase
        end
    endfunction

    function [7:0] title_char;
        input [1:0] line_id;
        input [5:0] index;
        begin
            title_char = 8'h20;
            case (line_id)
                2'd0: begin // PROJECT ASCON-80PQ
                    case (index)
                        6'd0: title_char = 8'h50; // P
                        6'd1: title_char = 8'h52; // R
                        6'd2: title_char = 8'h4F; // O
                        6'd3: title_char = 8'h4A; // J
                        6'd4: title_char = 8'h45; // E
                        6'd5: title_char = 8'h43; // C
                        6'd6: title_char = 8'h54; // T
                        6'd7: title_char = 8'h20; // space
                        6'd8: title_char = 8'h41; // A
                        6'd9: title_char = 8'h53; // S
                        6'd10: title_char = 8'h43; // C
                        6'd11: title_char = 8'h4F; // O
                        6'd12: title_char = 8'h4E; // N
                        6'd13: title_char = 8'h2D; // -
                        6'd14: title_char = 8'h38; // 8
                        6'd15: title_char = 8'h30; // 0
                        6'd16: title_char = 8'h50; // P
                        6'd17: title_char = 8'h51; // Q
                        default: title_char = 8'h20;
                    endcase
                end
                2'd1: begin // CRYPTOGRAPHIC ACCELERATOR
                    case (index)
                        6'd0: title_char = 8'h43; // C
                        6'd1: title_char = 8'h52; // R
                        6'd2: title_char = 8'h59; // Y
                        6'd3: title_char = 8'h50; // P
                        6'd4: title_char = 8'h54; // T
                        6'd5: title_char = 8'h4F; // O
                        6'd6: title_char = 8'h47; // G
                        6'd7: title_char = 8'h52; // R
                        6'd8: title_char = 8'h41; // A
                        6'd9: title_char = 8'h50; // P
                        6'd10: title_char = 8'h48; // H
                        6'd11: title_char = 8'h49; // I
                        6'd12: title_char = 8'h43; // C
                        6'd13: title_char = 8'h20; // space
                        6'd14: title_char = 8'h41; // A
                        6'd15: title_char = 8'h43; // C
                        6'd16: title_char = 8'h43; // C
                        6'd17: title_char = 8'h45; // E
                        6'd18: title_char = 8'h4C; // L
                        6'd19: title_char = 8'h45; // E
                        6'd20: title_char = 8'h52; // R
                        6'd21: title_char = 8'h41; // A
                        6'd22: title_char = 8'h54; // T
                        6'd23: title_char = 8'h4F; // O
                        6'd24: title_char = 8'h52; // R
                        default: title_char = 8'h20;
                    endcase
                end
                default: title_char = 8'h20;
            endcase
        end
    endfunction

    function [7:0] status_char;
        input [5:0] index;
        input [1:0] sel;
        input valid;
        begin
            status_char = 8'h20;
            case (index)
                6'd0: status_char = 8'h52; // R
                6'd1: status_char = 8'h55; // U
                6'd2: status_char = 8'h4E; // N
                6'd3: status_char = 8'h4E; // N
                6'd4: status_char = 8'h49; // I
                6'd5: status_char = 8'h4E; // N
                6'd6: status_char = 8'h47; // G
                6'd7: status_char = 8'h20; // space
                6'd8: status_char = 8'h54; // T
                6'd9: status_char = 8'h45; // E
                6'd10: status_char = 8'h53; // S
                6'd11: status_char = 8'h54; // T
                6'd12: status_char = 8'h20; // space
                6'd13: status_char = 8'h43; // C
                6'd14: status_char = 8'h41; // A
                6'd15: status_char = 8'h53; // S
                6'd16: status_char = 8'h45; // E
                6'd17: status_char = 8'h20; // space
                6'd18: status_char = valid ? (8'h31 + {6'd0, sel}) : 8'h30;
                default: status_char = 8'h20;
            endcase
        end
    endfunction

    always @(*) begin
        char_code = 8'h20;
        big_char_code = 8'h20;
        selected_nibble = 4'h0;

        case (big_row)
            5'd1: begin
                if ((big_col >= 6'd11) && (big_col < 6'd29))
                    big_char_code = title_char(2'd0, big_col - 6'd11);
            end
            5'd3: begin
                if ((big_col >= 6'd7) && (big_col < 6'd32))
                    big_char_code = title_char(2'd1, big_col - 6'd7);
            end
            5'd5: begin
                if ((big_col >= 6'd10) && (big_col < 6'd29))
                    big_char_code = status_char(big_col - 6'd10, test_case_sel, test_case_valid);
            end
            default: big_char_code = 8'h20;
        endcase

        case (char_row)
            6'd15: begin
                if ((char_col >= 7'd4) && (char_col < 7'd12))
                    char_code = label_char(3'd0, char_col - 7'd4);
                else if ((char_col >= 7'd17) && (char_col < 7'd57)) begin
                    selected_nibble = nibble160(key, char_col - 7'd17);
                    char_code = hex_ascii;
                end
            end

            6'd20: begin
                if ((char_col >= 7'd4) && (char_col < 7'd14))
                    char_code = label_char(3'd1, char_col - 7'd4);
                else if ((char_col >= 7'd17) && (char_col < 7'd49)) begin
                    selected_nibble = nibble128(nonce, char_col - 7'd17);
                    char_code = hex_ascii;
                end
            end

            6'd25: begin
                if ((char_col >= 7'd4) && (char_col < 7'd14))
                    char_code = label_char(3'd2, char_col - 7'd4);
                else if ((char_col >= 7'd17) && (char_col < 7'd49)) begin
                    selected_nibble = nibble128(plaintext, char_col - 7'd17);
                    char_code = hex_ascii;
                end
            end

            6'd30: begin
                if ((char_col >= 7'd4) && (char_col < 7'd7))
                    char_code = label_char(3'd3, char_col - 7'd4);
                else if ((char_col >= 7'd17) && (char_col < 7'd49)) begin
                    selected_nibble = nibble128(associated_data, char_col - 7'd17);
                    char_code = hex_ascii;
                end
            end

            6'd35: begin
                if ((char_col >= 7'd4) && (char_col < 7'd15))
                    char_code = label_char(3'd4, char_col - 7'd4);
                else if ((char_col >= 7'd17) && (char_col < 7'd49)) begin
                    selected_nibble = nibble128(ciphertext, char_col - 7'd17);
                    char_code = hex_ascii;
                end
            end

            6'd40: begin
                if ((char_col >= 7'd4) && (char_col < 7'd13))
                    char_code = label_char(3'd5, char_col - 7'd4);
                else if ((char_col >= 7'd17) && (char_col < 7'd49)) begin
                    selected_nibble = nibble128(auth_tag, char_col - 7'd17);
                    char_code = hex_ascii;
                end
            end

            default: char_code = 8'h20;
        endcase
    end

    always @(posedge pixel_clk) begin
        if (!reset_n) begin
            red   <= 8'h00;
            green <= 8'h00;
            blue  <= 8'h00;
        end else if (video_on && big_text_pixel) begin
            red   <= 8'hA0;
            green <= 8'hE8;
            blue  <= 8'hFF;
        end else if (video_on && text_pixel) begin
            red   <= 8'hFF;
            green <= 8'hFF;
            blue  <= 8'hFF;
        end else begin
            red   <= 8'h00;
            green <= 8'h00;
            blue  <= 8'h20;
        end
    end

endmodule
