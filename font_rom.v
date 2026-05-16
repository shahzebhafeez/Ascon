`timescale 1ns / 1ps

module font_rom (
    input  wire [7:0] char_code,
    input  wire [2:0] row,
    output reg  [7:0] pixels
);

    always @(*) begin
        pixels = 8'b00000000;

        case (char_code)
            8'h20: pixels = 8'b00000000; // space

            8'h3A: begin // :
                case (row)
                    3'd2: pixels = 8'b00011000;
                    3'd5: pixels = 8'b00011000;
                    default: pixels = 8'b00000000;
                endcase
            end

            8'h2D: begin // -
                case (row)
                    3'd3: pixels = 8'b01111110;
                    default: pixels = 8'b00000000;
                endcase
            end

            8'h30: begin // 0
                case (row)
                    3'd0: pixels = 8'b00111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01101110;
                    3'd3: pixels = 8'b01110110;
                    3'd4: pixels = 8'b01100110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b00111100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h31: begin // 1
                case (row)
                    3'd0: pixels = 8'b00011000;
                    3'd1: pixels = 8'b00111000;
                    3'd2: pixels = 8'b00011000;
                    3'd3: pixels = 8'b00011000;
                    3'd4: pixels = 8'b00011000;
                    3'd5: pixels = 8'b00011000;
                    3'd6: pixels = 8'b01111110;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h32: begin // 2
                case (row)
                    3'd0: pixels = 8'b00111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b00000110;
                    3'd3: pixels = 8'b00011100;
                    3'd4: pixels = 8'b00110000;
                    3'd5: pixels = 8'b01100000;
                    3'd6: pixels = 8'b01111110;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h33: begin // 3
                case (row)
                    3'd0: pixels = 8'b00111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b00000110;
                    3'd3: pixels = 8'b00011100;
                    3'd4: pixels = 8'b00000110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b00111100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h34: begin // 4
                case (row)
                    3'd0: pixels = 8'b00001100;
                    3'd1: pixels = 8'b00011100;
                    3'd2: pixels = 8'b00101100;
                    3'd3: pixels = 8'b01001100;
                    3'd4: pixels = 8'b01111110;
                    3'd5: pixels = 8'b00001100;
                    3'd6: pixels = 8'b00001100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h35: begin // 5
                case (row)
                    3'd0: pixels = 8'b01111110;
                    3'd1: pixels = 8'b01100000;
                    3'd2: pixels = 8'b01111100;
                    3'd3: pixels = 8'b00000110;
                    3'd4: pixels = 8'b00000110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b00111100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h36: begin // 6
                case (row)
                    3'd0: pixels = 8'b00111100;
                    3'd1: pixels = 8'b01100000;
                    3'd2: pixels = 8'b01111100;
                    3'd3: pixels = 8'b01100110;
                    3'd4: pixels = 8'b01100110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b00111100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h37: begin // 7
                case (row)
                    3'd0: pixels = 8'b01111110;
                    3'd1: pixels = 8'b00000110;
                    3'd2: pixels = 8'b00001100;
                    3'd3: pixels = 8'b00011000;
                    3'd4: pixels = 8'b00110000;
                    3'd5: pixels = 8'b00110000;
                    3'd6: pixels = 8'b00110000;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h38: begin // 8
                case (row)
                    3'd0: pixels = 8'b00111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01100110;
                    3'd3: pixels = 8'b00111100;
                    3'd4: pixels = 8'b01100110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b00111100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h39: begin // 9
                case (row)
                    3'd0: pixels = 8'b00111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01100110;
                    3'd3: pixels = 8'b00111110;
                    3'd4: pixels = 8'b00000110;
                    3'd5: pixels = 8'b00001100;
                    3'd6: pixels = 8'b00111000;
                    default: pixels = 8'b00000000;
                endcase
            end

            8'h41: begin // A
                case (row)
                    3'd0: pixels = 8'b00011000;
                    3'd1: pixels = 8'b00111100;
                    3'd2: pixels = 8'b01100110;
                    3'd3: pixels = 8'b01100110;
                    3'd4: pixels = 8'b01111110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b01100110;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h42: begin // B
                case (row)
                    3'd0: pixels = 8'b01111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01100110;
                    3'd3: pixels = 8'b01111100;
                    3'd4: pixels = 8'b01100110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b01111100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h43: begin // C
                case (row)
                    3'd0: pixels = 8'b00111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01100000;
                    3'd3: pixels = 8'b01100000;
                    3'd4: pixels = 8'b01100000;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b00111100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h44: begin // D
                case (row)
                    3'd0: pixels = 8'b01111000;
                    3'd1: pixels = 8'b01101100;
                    3'd2: pixels = 8'b01100110;
                    3'd3: pixels = 8'b01100110;
                    3'd4: pixels = 8'b01100110;
                    3'd5: pixels = 8'b01101100;
                    3'd6: pixels = 8'b01111000;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h45: begin // E
                case (row)
                    3'd0: pixels = 8'b01111110;
                    3'd1: pixels = 8'b01100000;
                    3'd2: pixels = 8'b01100000;
                    3'd3: pixels = 8'b01111100;
                    3'd4: pixels = 8'b01100000;
                    3'd5: pixels = 8'b01100000;
                    3'd6: pixels = 8'b01111110;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h46: begin // F
                case (row)
                    3'd0: pixels = 8'b01111110;
                    3'd1: pixels = 8'b01100000;
                    3'd2: pixels = 8'b01100000;
                    3'd3: pixels = 8'b01111100;
                    3'd4: pixels = 8'b01100000;
                    3'd5: pixels = 8'b01100000;
                    3'd6: pixels = 8'b01100000;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h47: begin // G
                case (row)
                    3'd0: pixels = 8'b00111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01100000;
                    3'd3: pixels = 8'b01101110;
                    3'd4: pixels = 8'b01100110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b00111100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h48: begin // H
                case (row)
                    3'd0: pixels = 8'b01100110;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01100110;
                    3'd3: pixels = 8'b01111110;
                    3'd4: pixels = 8'b01100110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b01100110;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h49: begin // I
                case (row)
                    3'd0: pixels = 8'b00111100;
                    3'd1: pixels = 8'b00011000;
                    3'd2: pixels = 8'b00011000;
                    3'd3: pixels = 8'b00011000;
                    3'd4: pixels = 8'b00011000;
                    3'd5: pixels = 8'b00011000;
                    3'd6: pixels = 8'b00111100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h4A: begin // J
                case (row)
                    3'd0: pixels = 8'b00011110;
                    3'd1: pixels = 8'b00001100;
                    3'd2: pixels = 8'b00001100;
                    3'd3: pixels = 8'b00001100;
                    3'd4: pixels = 8'b01101100;
                    3'd5: pixels = 8'b01101100;
                    3'd6: pixels = 8'b00111000;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h4B: begin // K
                case (row)
                    3'd0: pixels = 8'b01100110;
                    3'd1: pixels = 8'b01101100;
                    3'd2: pixels = 8'b01111000;
                    3'd3: pixels = 8'b01110000;
                    3'd4: pixels = 8'b01111000;
                    3'd5: pixels = 8'b01101100;
                    3'd6: pixels = 8'b01100110;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h4C: begin // L
                case (row)
                    3'd0: pixels = 8'b01100000;
                    3'd1: pixels = 8'b01100000;
                    3'd2: pixels = 8'b01100000;
                    3'd3: pixels = 8'b01100000;
                    3'd4: pixels = 8'b01100000;
                    3'd5: pixels = 8'b01100000;
                    3'd6: pixels = 8'b01111110;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h4E: begin // N
                case (row)
                    3'd0: pixels = 8'b01100110;
                    3'd1: pixels = 8'b01110110;
                    3'd2: pixels = 8'b01111110;
                    3'd3: pixels = 8'b01111110;
                    3'd4: pixels = 8'b01101110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b01100110;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h4F: begin // O
                case (row)
                    3'd0: pixels = 8'b00111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01100110;
                    3'd3: pixels = 8'b01100110;
                    3'd4: pixels = 8'b01100110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b00111100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h50: begin // P
                case (row)
                    3'd0: pixels = 8'b01111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01100110;
                    3'd3: pixels = 8'b01111100;
                    3'd4: pixels = 8'b01100000;
                    3'd5: pixels = 8'b01100000;
                    3'd6: pixels = 8'b01100000;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h51: begin // Q
                case (row)
                    3'd0: pixels = 8'b00111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01100110;
                    3'd3: pixels = 8'b01100110;
                    3'd4: pixels = 8'b01101110;
                    3'd5: pixels = 8'b00111100;
                    3'd6: pixels = 8'b00000110;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h52: begin // R
                case (row)
                    3'd0: pixels = 8'b01111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01100110;
                    3'd3: pixels = 8'b01111100;
                    3'd4: pixels = 8'b01111000;
                    3'd5: pixels = 8'b01101100;
                    3'd6: pixels = 8'b01100110;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h53: begin // S
                case (row)
                    3'd0: pixels = 8'b00111100;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01100000;
                    3'd3: pixels = 8'b00111100;
                    3'd4: pixels = 8'b00000110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b00111100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h54: begin // T
                case (row)
                    3'd0: pixels = 8'b01111110;
                    3'd1: pixels = 8'b00011000;
                    3'd2: pixels = 8'b00011000;
                    3'd3: pixels = 8'b00011000;
                    3'd4: pixels = 8'b00011000;
                    3'd5: pixels = 8'b00011000;
                    3'd6: pixels = 8'b00011000;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h55: begin // U
                case (row)
                    3'd0: pixels = 8'b01100110;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b01100110;
                    3'd3: pixels = 8'b01100110;
                    3'd4: pixels = 8'b01100110;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b00111100;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h58: begin // X
                case (row)
                    3'd0: pixels = 8'b01100110;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b00111100;
                    3'd3: pixels = 8'b00011000;
                    3'd4: pixels = 8'b00111100;
                    3'd5: pixels = 8'b01100110;
                    3'd6: pixels = 8'b01100110;
                    default: pixels = 8'b00000000;
                endcase
            end
            8'h59: begin // Y
                case (row)
                    3'd0: pixels = 8'b01100110;
                    3'd1: pixels = 8'b01100110;
                    3'd2: pixels = 8'b00111100;
                    3'd3: pixels = 8'b00011000;
                    3'd4: pixels = 8'b00011000;
                    3'd5: pixels = 8'b00011000;
                    3'd6: pixels = 8'b00011000;
                    default: pixels = 8'b00000000;
                endcase
            end

            default: pixels = 8'b00000000;
        endcase
    end

endmodule
