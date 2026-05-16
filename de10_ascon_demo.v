`timescale 1ns / 1ps

module de10_ascon_demo (
    input  wire        CLOCK_50,
    input  wire [1:0]  KEY,
    input  wire [2:0]  SW,
    output wire [9:0]  LEDR,
    output wire        VGA_HS,
    output wire        VGA_VS,
    output wire [7:0]  VGA_R,
    output wire [7:0]  VGA_G,
    output wire [7:0]  VGA_B,
    output wire        VGA_CLK,
    output wire        VGA_BLANK_N,
    output wire        VGA_SYNC_N
);

    localparam [3:0] ST_RESET_WAIT  = 4'd0,
                     ST_START       = 4'd1,
                     ST_START_DROP  = 4'd2,
                     ST_WAIT_READY  = 4'd3,
                     ST_SEND        = 4'd4,
                     ST_SEND_DROP   = 4'd5,
                     ST_WAIT_DONE   = 4'd6,
                     ST_DONE        = 4'd7;

    localparam [21:0] RESET_WAIT_CYCLES = 22'd2500000;

    reg [3:0] state;
    reg [2:0] block_index;
    reg [21:0] reset_count;
    reg       start_reg;
    reg       data_valid_reg;
    reg [63:0] data_in_reg;
    reg [63:0] selected_block;
    reg [63:0] ciphertext_block_0;
    reg [63:0] ciphertext_block_1;
    reg [1:0]  test_case_sel;
    reg        test_case_valid;
    reg [159:0] user_key_reg;
    reg [127:0] user_nonce_reg;
    reg [127:0] user_plaintext_reg;
    reg [127:0] user_associated_data_reg;
    reg [127:0] expected_ciphertext_reg;
    reg [127:0] expected_tag_reg;
    reg [23:0] led_div;
    reg [9:0]  led_status;
    reg        result_seen;
    reg        result_pass_latched;
    reg [1:0]  result_case_sel;
    reg        result_case_valid;
    reg       key1_sync_0;
    reg       key1_sync_1;
    reg       key1_sync_2;

    wire reset_n;
    wire ready;
    wire done;
    wire [63:0] data_out;
    wire [127:0] tag_out;
    wire [159:0] user_key;
    wire [127:0] user_nonce;
    wire [127:0] user_plaintext;
    wire [127:0] user_associated_data;
    wire [127:0] user_ciphertext;
    wire [127:0] expected_ciphertext;
    wire [127:0] expected_tag;
    wire [127:0] display_ciphertext;
    wire [127:0] display_tag;
    wire result_matches_selection;
    wire key1_pressed;
    wire run_pulse;
    wire ascon_result_valid;

    assign reset_n = KEY[0];
    assign key1_pressed = key1_sync_2 & ~key1_sync_1;
    assign run_pulse = key1_pressed;
    assign user_key = user_key_reg;
    assign user_nonce = user_nonce_reg;
    assign user_plaintext = user_plaintext_reg;
    assign user_associated_data = user_associated_data_reg;
    assign expected_ciphertext = expected_ciphertext_reg;
    assign expected_tag = expected_tag_reg;
    assign user_ciphertext = {ciphertext_block_0, ciphertext_block_1};
    assign ascon_result_valid = (state == ST_WAIT_DONE) && done;
    assign result_matches_selection = result_seen &&
                                      (result_case_sel == test_case_sel) &&
                                      (result_case_valid == test_case_valid);
    assign display_ciphertext = result_matches_selection ? user_ciphertext : expected_ciphertext;
    assign display_tag = result_matches_selection ? tag_out : expected_tag;

    always @(*) begin
        test_case_sel = 2'd0;
        test_case_valid = 1'b0;

        if (SW[0] && !SW[1] && !SW[2]) begin
            test_case_sel = 2'd0;
            test_case_valid = 1'b1;
        end else if (!SW[0] && SW[1] && !SW[2]) begin
            test_case_sel = 2'd1;
            test_case_valid = 1'b1;
        end else if (!SW[0] && !SW[1] && SW[2]) begin
            test_case_sel = 2'd2;
            test_case_valid = 1'b1;
        end
    end

    always @(*) begin
        user_key_reg = 160'hDEADBEEF00112233445566778899AABBCCDDEEFF;
        user_nonce_reg = 128'h01010101020202020303030304040404;
        user_associated_data_reg = 128'h4E4F20544553542053454C4543544544;
        user_plaintext_reg = 128'h4E4F20544553542053454C4543544544;
        expected_ciphertext_reg = 128'h11112222333344445555666677778888;
        expected_tag_reg = 128'h9999AAAABBBBCCCCDDDDEEEEFFFF0000;

        case (test_case_sel)
            2'd0: begin
                user_key_reg = 160'h000102030405060708090A0B0C0D0E0F10111213;
                user_nonce_reg = 128'h000102030405060708090A0B0C0D0E0F;
                user_associated_data_reg = 128'h534F43204C4142204153434F4E203031;
                user_plaintext_reg = 128'h434849505850525420534F43204C4142;
                expected_ciphertext_reg = 128'hC06D061C9534C386EBEE35F4214577C2;
                expected_tag_reg = 128'h03F81309373615FA7B993BF86ABA8176;
            end
            2'd1: begin
                user_key_reg = 160'h00112233445566778899AABBCCDDEEFF00010203;
                user_nonce_reg = 128'h102030405060708090A0B0C0D0E0F00;
                user_associated_data_reg = 128'h414420464F5220434849505850525421;
                user_plaintext_reg = 128'h534F43204C4142204348495058505254;
                expected_ciphertext_reg = 128'h2450DFA1FDE55977D1857ECE94D593B5;
                expected_tag_reg = 128'h1F1CD666442EC2B10A03A297DD587AA5;
            end
            2'd2: begin
                user_key_reg = 160'hFFEEDDCCBBAA99887766554433221100A0B0C0D0;
                user_nonce_reg = 128'hF0E0D0C0B0A090807060504030201000;
                user_associated_data_reg = 128'h534F43204C4142205445535420303033;
                user_plaintext_reg = 128'h43484950585052542046504741212121;
                expected_ciphertext_reg = 128'h71186D8E33CA03A797F75D3EB4D21767;
                expected_tag_reg = 128'h3DC6ACF0E86A62A144A1385651914A6C;
            end
            default: begin
                user_key_reg = 160'hDEADBEEF00112233445566778899AABBCCDDEEFF;
                user_nonce_reg = 128'h01010101020202020303030304040404;
                user_associated_data_reg = 128'h4E4F20544553542053454C4543544544;
                user_plaintext_reg = 128'h4E4F20544553542053454C4543544544;
                expected_ciphertext_reg = 128'h11112222333344445555666677778888;
                expected_tag_reg = 128'h9999AAAABBBBCCCCDDDDEEEEFFFF0000;
            end
        endcase
    end

    always @(posedge CLOCK_50) begin
        if (!reset_n) begin
            key1_sync_0 <= 1'b1;
            key1_sync_1 <= 1'b1;
            key1_sync_2 <= 1'b1;
        end else begin
            key1_sync_0 <= KEY[1];
            key1_sync_1 <= key1_sync_0;
            key1_sync_2 <= key1_sync_1;
        end
    end

    always @(*) begin
        case (block_index)
            3'd0: selected_block = user_associated_data[127:64];
            3'd1: selected_block = user_associated_data[63:0];
            3'd2: selected_block = user_plaintext[127:64];
            3'd3: selected_block = user_plaintext[63:0];
            default: selected_block = 64'd0;
        endcase
    end

    always @(posedge CLOCK_50) begin
        if (!reset_n) begin
            state          <= ST_RESET_WAIT;
            block_index    <= 3'd0;
            reset_count    <= 22'd0;
            start_reg      <= 1'b0;
            data_valid_reg <= 1'b0;
            data_in_reg    <= 64'd0;
            ciphertext_block_0 <= 64'd0;
            ciphertext_block_1 <= 64'd0;
            result_seen <= 1'b0;
            result_pass_latched <= 1'b0;
            result_case_sel <= 2'd0;
            result_case_valid <= 1'b0;
        end else begin
            start_reg      <= 1'b0;
            data_valid_reg <= 1'b0;

            case (state)
                ST_RESET_WAIT: begin
                    block_index <= 3'd0;
                    if (reset_count == RESET_WAIT_CYCLES)
                        state <= ST_DONE;
                    else
                        reset_count <= reset_count + 22'd1;
                end

                ST_START: begin
                    if (ready) begin
                        start_reg <= 1'b1;
                        ciphertext_block_0 <= 64'd0;
                        ciphertext_block_1 <= 64'd0;
                        result_seen <= 1'b0;
                        result_pass_latched <= 1'b0;
                        result_case_sel <= test_case_sel;
                        result_case_valid <= test_case_valid;
                        state <= ST_START_DROP;
                    end
                end

                ST_START_DROP: begin
                    state <= ST_WAIT_READY;
                end

                ST_WAIT_READY: begin
                    if (ready) begin
                        if (block_index < 3'd4)
                            state <= ST_SEND;
                        else
                            state <= ST_WAIT_DONE;
                    end
                end

                ST_SEND: begin
                    data_in_reg <= selected_block;
                    data_valid_reg <= 1'b1;
                    state <= ST_SEND_DROP;
                end

                ST_SEND_DROP: begin
                    if (block_index == 3'd2)
                        ciphertext_block_0 <= data_out;
                    else if (block_index == 3'd3)
                        ciphertext_block_1 <= data_out;
                    block_index <= block_index + 3'd1;
                    state <= ST_WAIT_READY;
                end

                ST_WAIT_DONE: begin
                    if (ascon_result_valid) begin
                        result_seen <= 1'b1;
                        result_case_sel <= test_case_sel;
                        result_case_valid <= test_case_valid;
                        result_pass_latched <= ({ciphertext_block_0, ciphertext_block_1} == expected_ciphertext) &&
                                               (tag_out == expected_tag);
                        state <= ST_DONE;
                    end
                end

                ST_DONE: begin
                    if (run_pulse && test_case_valid) begin
                        block_index <= 3'd0;
                        state <= ST_START;
                    end
                end

                default: begin
                    state <= ST_RESET_WAIT;
                end
            endcase
        end
    end

    always @(posedge CLOCK_50) begin
        if (!reset_n) begin
            led_div <= 24'd0;
            led_status <= 10'd0;
        end else begin
            led_div <= led_div + 24'd1;
            if (led_div == 24'd0) begin
                led_status[0] <= (test_case_sel == 2'd0) && test_case_valid;
                led_status[1] <= (test_case_sel == 2'd1) && test_case_valid;
                led_status[2] <= (test_case_sel == 2'd2) && test_case_valid;
                led_status[3] <= test_case_valid;
                led_status[4] <= (state == ST_RESET_WAIT);
                led_status[5] <= (state != ST_DONE) && (state != ST_RESET_WAIT);
                led_status[6] <= result_seen;
                led_status[7] <= result_seen && result_pass_latched;
                led_status[8] <= result_seen && !result_pass_latched;
                led_status[9] <= ~led_status[9];
            end
        end
    end

    ascon_top u_ascon_top (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .start(start_reg),
        .data_valid(data_valid_reg),
        .ready(ready),
        .done(done),
        .key(user_key),
        .nonce(user_nonce),
        .data_in(data_in_reg),
        .data_out(data_out),
        .tag_out(tag_out)
    );

    display_top u_display_top (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .key(user_key),
        .nonce(user_nonce),
        .plaintext(user_plaintext),
        .associated_data(user_associated_data),
        .ciphertext(display_ciphertext),
        .auth_tag(display_tag),
        .test_case_sel(test_case_sel),
        .test_case_valid(test_case_valid),
        .vga_hsync(VGA_HS),
        .vga_vsync(VGA_VS),
        .vga_red(VGA_R),
        .vga_green(VGA_G),
        .vga_blue(VGA_B),
        .vga_clk(VGA_CLK),
        .vga_blank_n(VGA_BLANK_N),
        .vga_sync_n(VGA_SYNC_N)
    );

    assign LEDR = led_status;

endmodule
