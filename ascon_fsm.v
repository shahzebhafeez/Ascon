module ascon_fsm (
    input  wire        clk,
    input  wire        reset_n,
    
    // External Triggers (From AXI Bus / ARM Processor)
    input  wire        start,          // Pulse to begin encryption
    input  wire        data_valid,     // High when plaintext/AD is ready on the bus
    
    // Status Outputs (To AXI Bus / ARM Processor)
    output reg         ready,          // High when FSM can accept a new command
    output reg         done,           // High when encryption/tag generation is complete
    
    // Control Signals TO Datapath (Module 2)
    output reg         ctrl_init_load,
    output reg         ctrl_update,
    output reg         ctrl_inject,
    output reg         ctrl_key_xor,
    
    // Control Signal TO Permutation Core (Module 1)
    output reg  [3:0]  round_idx
);

    // State Encoding (Using localparams for readable, synthesis-safe states)
    localparam [3:0] ST_IDLE          = 4'd0,
                     ST_INIT_LOAD     = 4'd1,
                     ST_INIT_ROUNDS   = 4'd2,
                     ST_INIT_KEY_XOR  = 4'd3,
                     ST_WAIT_DATA     = 4'd4,
                     ST_DATA_INJECT   = 4'd5,
                     ST_DATA_ROUNDS   = 4'd6,
                     ST_FINAL_KEY_XOR = 4'd7,
                     ST_FINAL_ROUNDS  = 4'd8,
                     ST_DONE          = 4'd9;

    reg [3:0] current_state, next_state;
    reg [3:0] round_counter_reg, round_counter_next;

    // 1. Synchronous State & Counter Update
    always @(posedge clk) begin
        if (!reset_n) begin
            current_state     <= ST_IDLE;
            round_counter_reg <= 4'd0;
        end else begin
            current_state     <= next_state;
            round_counter_reg <= round_counter_next;
        end
    end

    // 2. Combinational Next-State & Output Logic
    always @(*) begin
        // Default assignments to prevent inferred latches
        next_state         = current_state;
        round_counter_next = round_counter_reg;
        
        // Default control signal outputs (all off)
        ctrl_init_load     = 1'b0;
        ctrl_update        = 1'b0;
        ctrl_inject        = 1'b0;
        ctrl_key_xor       = 1'b0;
        ready              = 1'b0;
        done               = 1'b0;
        round_idx          = round_counter_reg; // Route counter to Permutation Core

        case (current_state)
            
            ST_IDLE: begin
                ready = 1'b1;
                if (start) begin
                    next_state = ST_INIT_LOAD;
                end
            end

            ST_INIT_LOAD: begin
                ctrl_init_load     = 1'b1;     // Tell Datapath to load IV, Key, Nonce
                round_counter_next = 4'd0;     // Initialize counter for p^a (12 rounds)
                next_state         = ST_INIT_ROUNDS;
            end

            ST_INIT_ROUNDS: begin
                ctrl_update = 1'b1;            // Latch Permutation Core output
                if (round_counter_reg == 4'd11) begin
                    next_state = ST_INIT_KEY_XOR;
                end else begin
                    round_counter_next = round_counter_reg + 4'd1;
                end
            end

            ST_INIT_KEY_XOR: begin
                ctrl_key_xor = 1'b1;           // XOR Key into capacity post-initialization
                next_state   = ST_WAIT_DATA;
            end

            ST_WAIT_DATA: begin
                // In a full implementation, you would loop back here for multiple blocks
                if (data_valid) begin
                    next_state = ST_DATA_INJECT;
                end
            end

            ST_DATA_INJECT: begin
                ctrl_inject        = 1'b1;     // XOR Plaintext into the rate (x0)
                round_counter_next = 4'd6;     // **CRITICAL:** p^b starts at round index 6
                next_state         = ST_DATA_ROUNDS;
            end

            ST_DATA_ROUNDS: begin
                ctrl_update = 1'b1;            // Latch Permutation Core output
                if (round_counter_reg == 4'd11) begin
                    // Assuming 1 block of data for this DSD project scope. 
                    // Move directly to finalization.
                    next_state = ST_FINAL_KEY_XOR;
                end else begin
                    round_counter_next = round_counter_reg + 4'd1;
                end
            end

            ST_FINAL_KEY_XOR: begin
                ctrl_key_xor       = 1'b1;     // XOR Key to state prior to finalization
                round_counter_next = 4'd0;     // Reset counter for p^a (12 rounds)
                next_state         = ST_FINAL_ROUNDS;
            end

            ST_FINAL_ROUNDS: begin
                ctrl_update = 1'b1;            // Latch Permutation Core output
                if (round_counter_reg == 4'd11) begin
                    next_state = ST_DONE;
                end else begin
                    round_counter_next = round_counter_reg + 4'd1;
                end
            end

            ST_DONE: begin
                done = 1'b1;                   // Signal that Ciphertext and Tag are ready
                if (!start) begin              // Wait for software to lower start signal
                    next_state = ST_IDLE;
                end
            end

            default: next_state = ST_IDLE;
        endcase
    end

endmodule