`timescale 1ns / 1ps

module ascon_fsm (
    input  wire        clk,
    input  wire        reset_n,
    
    // External Triggers
    input  wire        start,
    input  wire        data_valid,
    
    // Status Outputs
    output reg         ready,
    output reg         done,
    
    // Control Signals TO Datapath
    output reg         ctrl_init_load,
    output reg         ctrl_update,
    output reg         ctrl_inject,
    output reg         ctrl_key_xor,
    output reg         ctrl_final_key_xor,
    output reg         ctrl_pad,
    output reg         ctrl_domain_sep, 
    
    // Control Signal TO Permutation Core
    output reg  [3:0]  round_idx
);

    localparam [4:0] ST_IDLE          = 5'd0,
                     ST_INIT_LOAD     = 5'd1,
                     ST_INIT_ROUNDS   = 5'd2,
                     ST_INIT_KEY_XOR  = 5'd3,
                     ST_WAIT_AD       = 5'd4,
                     ST_AD_INJECT     = 5'd5,
                     ST_AD_ROUNDS     = 5'd6,
                     ST_AD_PAD        = 5'd7,
                     ST_AD_PAD_ROUNDS = 5'd8,
                     ST_DOMAIN_SEP    = 5'd9,
                     ST_WAIT_DATA     = 5'd10,
                     ST_DATA_INJECT   = 5'd11,
                     ST_DATA_ROUNDS   = 5'd12,
                     ST_DATA_PAD      = 5'd13,
                     ST_FINAL_KEY_XOR = 5'd14,
                     ST_FINAL_ROUNDS  = 5'd15,
                     ST_DONE          = 5'd16;

    reg [4:0] current_state, next_state;
    reg [3:0] round_counter_reg, round_counter_next;
    
    // Block counter to track the 2 blocks of AD and 2 blocks of Plaintext
    reg [1:0] block_count_reg, block_count_next; 

    always @(posedge clk) begin
        if (!reset_n) begin
            current_state     <= ST_IDLE;
            round_counter_reg <= 4'd0;
            block_count_reg   <= 2'd0;
        end else begin
            current_state     <= next_state;
            round_counter_reg <= round_counter_next;
            block_count_reg   <= block_count_next;
        end
    end

    always @(*) begin
        // Default assignments
        next_state         = current_state;
        round_counter_next = round_counter_reg;
        block_count_next   = block_count_reg;
        
        // Default control signals (All zero unless explicitly set)
        ctrl_init_load     = 1'b0;
        ctrl_update        = 1'b0;
        ctrl_inject        = 1'b0;
        ctrl_key_xor       = 1'b0;
        ctrl_final_key_xor = 1'b0;
        ctrl_pad           = 1'b0;
        ctrl_domain_sep    = 1'b0;
        ready              = 1'b0;
        done               = 1'b0;
        round_idx          = round_counter_reg;

        case (current_state)
            ST_IDLE: begin
                ready = 1'b1;
                if (start) next_state = ST_INIT_LOAD;
            end

            ST_INIT_LOAD: begin
                ctrl_init_load     = 1'b1;
                round_counter_next = 4'd0; // p^a starts at round 0
                block_count_next   = 2'd0; 
                next_state         = ST_INIT_ROUNDS;
            end

            ST_INIT_ROUNDS: begin
                ctrl_update = 1'b1;
                if (round_counter_reg == 4'd11) next_state = ST_INIT_KEY_XOR;
                else round_counter_next = round_counter_reg + 4'd1;
            end

            ST_INIT_KEY_XOR: begin
                ctrl_key_xor = 1'b1;
                block_count_next = 2'd0; 
                next_state   = ST_WAIT_AD;
            end

            // ==========================================
            // ASSOCIATED DATA (AD) PHASE
            // ==========================================
            ST_WAIT_AD: begin
                ready = 1'b1; 
                if (data_valid) next_state = ST_AD_INJECT;
            end

            ST_AD_INJECT: begin
                ctrl_inject        = 1'b1;
                round_counter_next = 4'd6; // p^b starts at round 6
                next_state         = ST_AD_ROUNDS;
            end

            ST_AD_ROUNDS: begin
                ctrl_update = 1'b1;
                if (round_counter_reg == 4'd11) begin
                    if (block_count_reg == 2'd1) begin // Processed 2 blocks?
                        next_state = ST_AD_PAD;
                    end else begin
                        block_count_next = block_count_reg + 2'd1;
                        next_state = ST_WAIT_AD;
                    end
                end else begin
                    round_counter_next = round_counter_reg + 4'd1;
                end
            end

            ST_AD_PAD: begin
                ctrl_pad           = 1'b1;
                round_counter_next = 4'd6; // p^b after the padded empty AD block
                next_state         = ST_AD_PAD_ROUNDS;
            end

            ST_AD_PAD_ROUNDS: begin
                ctrl_update = 1'b1;
                if (round_counter_reg == 4'd11) next_state = ST_DOMAIN_SEP;
                else round_counter_next = round_counter_reg + 4'd1;
            end

            // ==========================================
            // DOMAIN SEPARATION 
            // ==========================================
            ST_DOMAIN_SEP: begin
                ctrl_domain_sep  = 1'b1;  // Flips x4[0] in Datapath
                block_count_next = 2'd0;  // Reset counter for Plaintext
                next_state       = ST_WAIT_DATA;
            end

            // ==========================================
            // PLAINTEXT PHASE
            // ==========================================
            ST_WAIT_DATA: begin
                ready = 1'b1; 
                if (data_valid) next_state = ST_DATA_INJECT;
            end

            ST_DATA_INJECT: begin
                ctrl_inject        = 1'b1;
                round_counter_next = 4'd6; // p^b starts at round 6
                next_state         = ST_DATA_ROUNDS;
            end

            ST_DATA_ROUNDS: begin
                ctrl_update = 1'b1;
                if (round_counter_reg == 4'd11) begin
                    if (block_count_reg == 2'd1) begin // Processed 2 blocks?
                        next_state = ST_DATA_PAD;
                    end else begin
                        block_count_next = block_count_reg + 2'd1;
                        next_state = ST_WAIT_DATA;
                    end
                end else begin
                    round_counter_next = round_counter_reg + 4'd1;
                end
            end

            ST_DATA_PAD: begin
                ctrl_pad   = 1'b1;
                next_state = ST_FINAL_KEY_XOR;
            end

            // ==========================================
            // FINALIZATION PHASE
            // ==========================================
            ST_FINAL_KEY_XOR: begin
                ctrl_final_key_xor = 1'b1;
                round_counter_next = 4'd0; // p^a starts at round 0
                next_state         = ST_FINAL_ROUNDS;
            end

            ST_FINAL_ROUNDS: begin
                ctrl_update = 1'b1;
                if (round_counter_reg == 4'd11) next_state = ST_DONE;
                else round_counter_next = round_counter_reg + 4'd1;
            end

            ST_DONE: begin
                done  = 1'b1;
                ready = 1'b1; 
                if (start) next_state = ST_INIT_LOAD;
            end

            default: next_state = ST_IDLE;
        endcase
    end
endmodule