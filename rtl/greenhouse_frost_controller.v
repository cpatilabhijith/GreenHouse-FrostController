module greenhouse_frost_controller (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] temp_value,   // temperature = value - 40
    input  wire       manual_open,
    input  wire       manual_close,
    output reg        window_motor_close,
    output reg        window_motor_open,
    output reg        frost_alarm,
    output reg  [1:0] status
);

    // ---- FSM states (2-bit encoding) ----
    localparam [1:0] S_IDLE   = 2'b00;
    localparam [1:0] S_OPEN   = 2'b01;
    localparam [1:0] S_CLOSED = 2'b10;

    reg [1:0] state, next_state;

    // ---- Temperature thresholds (offset +40) ----
    localparam [7:0] TEMP_FROST = 8'd40; // 0 degC
    localparam [7:0] TEMP_CLOSE = 8'd42; // 2 degC
    localparam [7:0] TEMP_OPEN  = 8'd45; // 5 degC

    // ---- Sequential: state register ----
    always @(posedge clk) begin
        if (reset)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    
    // ---- Combinational: next-state and outputs ----
    always @(*) begin
        // safe defaults (also used during reset)
        next_state         = S_IDLE;
        window_motor_close = 1'b0;
        window_motor_open  = 1'b0;
        frost_alarm        = 1'b0;
        status             = 2'b00;

        if (reset) begin
            // During reset: all outputs held at safe defaults.
            // Nothing else drives them.
        end
        else begin
            // Frost alarm (independent of FSM)
            if (temp_value <= TEMP_FROST)
                frost_alarm = 1'b1;

            // Manual override (close has priority)
            if (manual_close) begin
                next_state         = S_CLOSED;
                window_motor_close = 1'b1;
                status             = 2'b01;
            end
            else if (manual_open) begin
                next_state        = S_OPEN;
                window_motor_open = 1'b1;
                status            = 2'b10;
            end
            else begin
                // Automatic mode
                if (temp_value <= TEMP_CLOSE) begin
                    next_state         = S_CLOSED;
                    window_motor_close = 1'b1;
                    status             = 2'b01;
                end
                else if (temp_value >= TEMP_OPEN) begin
                    next_state        = S_OPEN;
                    window_motor_open = 1'b1;
                    status            = 2'b10;
                end
                else begin
                    // Dead-band (2..5 degC): hold previous automatic direction
                    case (state)
                        S_OPEN: begin
                            next_state        = S_OPEN;
                            window_motor_open = 1'b1;
                            status            = 2'b10;
                        end
                        S_CLOSED: begin
                            next_state         = S_CLOSED;
                            window_motor_close = 1'b1;
                            status             = 2'b01;
                        end
                        default: begin
                            next_state = S_IDLE;
                            status     = 2'b00;
                        end
                    endcase
                end
            end
        end
    end
endmodule
