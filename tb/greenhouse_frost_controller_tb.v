`timescale 1ns / 1ps

module greenhouse_frost_controller_tb;

    reg        clk;
    reg        reset;
    reg  [7:0] temp_value;
    reg        manual_open;
    reg        manual_close;
    wire       window_motor_close;
    wire       window_motor_open;
    wire       frost_alarm;
    wire [1:0] status;

    integer fail_count = 0;

    greenhouse_frost_controller uut (
        .clk(clk),
        .reset(reset),
        .temp_value(temp_value),
        .manual_open(manual_open),
        .manual_close(manual_close),
        .window_motor_close(window_motor_close),
        .window_motor_open(window_motor_open),
        .frost_alarm(frost_alarm),
        .status(status)
    );

    always #5 clk = ~clk;

    task check;
        input [8*40:1] label;
        input         cond;
        begin
            if (!cond) begin
                $display("%0s FAILED", label);
                fail_count = fail_count + 1;
            end else begin
                $display("%0s PASSED", label);
            end
        end
    endtask

    initial begin
        $dumpfile("greenhouse_frost_controller.vcd");
        $dumpvars(0, greenhouse_frost_controller_tb);

        clk         = 0;
        reset       = 1;
        temp_value  = 8'd55; // 15 degC
        manual_open = 0;
        manual_close= 0;

        // ---- Test 1: during reset, all outputs must be 0 ----
        #10;
        check("Test 1", (status === 2'b00) &&
                        (frost_alarm === 1'b0) &&
                        (window_motor_open === 1'b0) &&
                        (window_motor_close === 1'b0));
        reset = 0;

        // ---- Test 2: 8 degC -> OPEN ----
        temp_value = 8'd48;
        #20;
        check("Test 2", (window_motor_open === 1'b1) && (status === 2'b10));

        // ---- Test 3: 2 degC -> CLOSED ----
        temp_value = 8'd42;
        #20;
        check("Test 3", (window_motor_close === 1'b1) && (status === 2'b01));

        // ---- Test 4: 0 degC -> alarm + CLOSED ----
        temp_value = 8'd40;
        #20;
        check("Test 4", (frost_alarm === 1'b1) && (window_motor_close === 1'b1));

        // ---- Test 5: 5 degC -> OPEN (hysteresis upper) ----
        temp_value = 8'd45;
        #20;
        check("Test 5", (window_motor_open === 1'b1) && (status === 2'b10));

        // ---- Test 6: manual close at 10 degC -> CLOSED ----
        temp_value   = 8'd50;
        manual_close = 1;
        #20;
        check("Test 6", (window_motor_close === 1'b1) && (status === 2'b01));

        // ---- Test 7: release manual close at 10 degC -> OPEN ----
        manual_close = 0;
        #20;
        check("Test 7", (window_motor_open === 1'b1) && (status === 2'b10));

        // ---- Test 8: dead-band 3 degC, previous = OPEN -> hold OPEN ----
        temp_value = 8'd43;
        #20;
        check("Test 8", (window_motor_open === 1'b1) && (status === 2'b10));

        // ---- Test 9: dead-band 3 degC, previous = CLOSED -> hold CLOSED ----
        temp_value = 8'd42;  // force CLOSED
        #20;
        temp_value = 8'd43;  // dead-band
        #20;
        check("Test 9", (window_motor_close === 1'b1) && (status === 2'b01));

        // ---- Test 10: motor interlock (never both active) ----
        check("Test 10", !((window_motor_open === 1'b1) &&
                           (window_motor_close === 1'b1)));

        if (fail_count == 0)
            $display("=== All tests PASSED ===");
        else
            $display("=== %0d test(s) FAILED ===", fail_count);

        $finish;
    end

endmodule
